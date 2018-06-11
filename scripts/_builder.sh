
builder::CreateProjectMetadata()
{
  # Usage: CreateProjectMetadata <in:project_dir> <in:platform> <in:flavor>
  local in_project_dir=$1
  local in_platform=$2
  local in_flavor=$3

  # script::ExecOnHost "false" "echo '*** Creating project metadata'"

  local module_dir="$(script::ExecOnHost "false" "cd ${in_project_dir} ; git rev-parse --show-toplevel")"
  local git_result="$(script::ExecOnHost "false" "
    cd ${module_dir} ; 
    echo '{'
    printf '\"%s\": \"%s\",' 'version' \"\$(git rev-parse --short HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'commit' \"\$(git rev-parse HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'branch' \"\$(git rev-parse --abbrev-ref HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'time' \"\$(git log -1 --date=iso --pretty=format:%cd)\" | echo \$(cat) ;
    # printf '\"%s\": \"%s\",' 'tag' \"\$(git describe --tags)\" | echo \$(cat) ;
    cd ..
    printf '\"%s\": \"%s\",' 'upper_module_dir' \"\$(git rev-parse --show-toplevel)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_version' \"\$(git rev-parse --short HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_commit' \"\$(git rev-parse HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_branch' \"\$(git rev-parse --abbrev-ref HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\"' 'upper_time' \"\$(git log -1 --date=iso --pretty=format:%cd)\" | echo \$(cat) ;
    # printf '\"%s\": \"%s\",' 'upper_tag' \"\$(git describe --tags)\" | echo \$(cat) ;
    echo '}'
  ")"

  local name="${module_dir##*/}"
  local platform="${in_platform}"
  local flavor="${in_flavor}"
  local version="$(json::GetValue "${git_result}" 'version')"
  local commit="$(json::GetValue "${git_result}" 'commit')"
  local branch="$(json::GetValue "${git_result}" 'branch')"
  local time="$(json::GetValue "${git_result}" 'time')"
  local tag="$(json::GetValue "${git_result}" 'tag')"
  local upper_module_dir="$(json::GetValue "${git_result}" 'upper_module_dir')"
  local upper_name="${upper_module_dir##*/}"
  local upper_version="$(json::GetValue "${git_result}" 'upper_version')"
  local upper_commit="$(json::GetValue "${git_result}" 'upper_commit')"
  local upper_branch="$(json::GetValue "${git_result}" 'upper_branch')"
  local upper_time="$(json::GetValue "${git_result}" 'upper_time')"
  local upper_tag="$(json::GetValue "${git_result}" 'upper_tag')"

  local source_location="${module_dir/${upper_module_dir}/}"
  # source_location="${source_location/${name}/}"
  # source_location="${source_location::-1}"
  local binary_location="/${platform}/${flavor}/${name}"
  local full_name="${upper_name}-${source_location}-${platform}-${flavor}"
  local full_version="${upper_branch}-${upper_version}-${branch}-${version}"
  full_name=${full_name//\//-}
  full_name=${full_name/--/-}
  full_version=${full_version/--/-}
  build_timestamp="$(date --utc +%FT%T.%3NZ)"

  json::VarsToJson name platform flavor version commit branch time tag upper_name upper_version upper_commit upper_branch upper_time upper_tag source_location binary_location full_name full_version build_timestamp
}

builder::BuildCmake()
{
  # Usage: BuildCmake <in:cmake_file_path> <in:project_dir> <in:platform> <in:flavor>
  local in_cmake_file_path=$1
  local in_platform=${2,,}
  local in_flavor=${3,,}
  
  local build_flavors=()
  case ${in_flavor} in
      all)
        build_flavors+=('Release')
        build_flavors+=('RelWithDebInfo')
        build_flavors+=('Debug')
        ;;
      release)
        build_flavors+=('Release')
        #TODO(Roger) - Enable the code below so we can have debug info on every release
        # build_flavors+=('RelWithDebInfo')
        ;;
      debug)
        build_flavors+=('Debug')
        ;;
      *)
        ;;
  esac

  local cmake_file_dir="${in_cmake_file_path%/*}"
  for build_flavor in "${build_flavors[@]}"; do
    local project_metadata=$(builder::CreateProjectMetadata "${cmake_file_dir}" "${in_platform}" "${build_flavors,,}")
    local full_name="$(json::GetValue "${project_metadata}" 'full_name')"
    local build_timestamp="$(json::GetValue "${project_metadata}" 'build_timestamp')"
    if [ "${build_timestamp}" == "" ]; then
      echo "[ ${full_name} ] - FAILED"
      continue
    fi

    local project_name="$(json::GetValue "${project_metadata}" 'name')"
    local relative_build_dir="build/${in_platform}-${build_flavor,,}"
    local build_dir="${cmake_file_dir}/${relative_build_dir}"
    local cmake_staging_parameters="-DCMAKE_BUILD_TYPE=${build_flavor} -DCMAKE_INSTALL_PREFIX=../../../stage/"
    local cmake_building_parameters="--config ${build_flavor} --clean-first --target install"
    local build_log="$(script::ExecOnHost "true" "
      echo '*** Creating Build directory and build information:'
      echo '- Build Directory: ${build_dir}'
      mkdir -p ${build_dir} ;
      echo '${project_metadata}' > ${build_dir}/build.json
      echo '#!/bin/bash' > ${build_dir}/build.sh
      echo 'cd \"\$(dirname \"\$0\")\"' >> ${build_dir}/build.sh
      echo 'cmake ../.. ${cmake_staging_parameters}' >> ${build_dir}/build.sh
      echo 'cmake --build . ${cmake_building_parameters}' >> ${build_dir}/build.sh
      cd "${cmake_file_dir}/.."
      workspace_dir=\"\$(pwd -P)\"
      echo \"- Workspace Directory: \${workspace_dir}\"
      echo '*** Building ${full_name}:'
      ${build_command}
      ./build/builder/${in_platform} ./${project_name}/${relative_build_dir}/build.sh
    ")"

    local binary_location="$(json::GetValue "${project_metadata}" 'binary_location')"

    # TODO(Roger) - Find a way to protect the build_log in this way I can add the line below to create the log of the build.
    # echo '${build_log}' > ./build_detail.log
    local build_metadata="$(script::ExecOnHost "false" "
      cd "${cmake_file_dir}/.."
      cd ./stage/"${binary_location}"
      cat ./build.json
    ")"

    if [ "$(json::GetValue "${build_metadata}" 'build_timestamp')" != "${build_timestamp}" ]; then
      echo "[ ${full_name} ] - FAILED"
      continue
    fi

    echo "[ ${full_name} ] - SUCCESS"
  done
}

builder::GetFullImageName()
{
  # Usage: GetFullImageName <in:image_name> <in:image_version> [<in:server>]
  local in_image_name=$1
  local in_image_version=$2
  local in_server=$3

  if [ "${in_server}" == "" ]; then
    echo "${in_image_name}:${in_image_version}"
    return 0
  fi

  echo "${in_server}/${in_image_name}:${in_image_version}"
}

builder::IsImageAvailable()
{
  # Usage: IsImageAvailable <in:image_name> <in:image_version> [<in:server> [<in:user> <in:password>]]
  local in_image_name=$1
  local in_image_version=$2
  local in_server=$3
  local in_user=$4
  local in_password=$5

  local image_full_name="$(builder::GetFullImageName "${in_image_name}" "${in_image_version}" "${in_server}")"
  local command_login="docker login --username ${in_user} --password ${in_password} ${in_server}"
  if [ "${in_user}" == "" ]; then
    command_login="echo ''"
  fi

  #TODO(Roger) - Find a way to do not show erro on the screen when the image does not exits
  local image_info="$(script::ExecOnHost "false" "
    echo '{'
    printf '\"%s\": \"%s\",' 'login_result' \"\$(${command_login})\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'pull_result' \"\$(docker pull ${image_full_name})\" | echo \$(cat) ;
    printf '\"%s\": \"%s\"' 'image' \"\$(docker images --format \"{{.Repository}}:{{.Tag}}\" --filter \"reference=${image_full_name}\")\" | echo \$(cat) ;
    echo '}'
  ")"

  local image_found="$(json::GetValue "${image_info}" 'image')"
  if [ "${image_found}" == "${image_full_name}" ]; then
    echo "true"
    return 0
  fi

  echo "false"
}

builder::GetDataImageInfo()
{
  # Usage: GetDataImageInfo <in:image_name>
  local in_image_name=$1

  # TODO(Roger) - I had to call twice because when the docker pull fails it stops everyting. I have to handle this
  local image_info="$(script::ExecOnHost "false" "
    pull_result=\$(/bin/bash -c 'docker pull "${in_image_name}"') 
  ")"

  image_info="$(script::ExecOnHost "false" "
    docker run --rm -it "${in_image_name}" cat /root/build.json
  ")"

  if [ "$(json::GetValue "${image_info}" 'name')" == "" ]; then
    log::Log "error" "1" "Could not find name on the image_info" ""
    return 0
  fi

  echo "${image_info}"
}

builder::CreateImage()
{
  # Usage CreateImage <in:build_metadata_path> <in:server>
  local in_build_metadata_path=$1
  local in_server=$2

  local build_metadata="$(script::ExecOnHost "false" "
    cat ${in_build_metadata_path}
  ")"
  local full_name=$(json::GetValue "${build_metadata}" 'full_name')
  local full_version=$(json::GetValue "${build_metadata}" 'full_version')
  local image_full_name="$(builder::GetFullImageName "${full_name}" "${full_version}" "${in_server}")"
  local build_dir="${in_build_metadata_path%/*}"
  local name=$(json::GetValue "${build_metadata}" 'name')
  local build_log="$(script::ExecOnHost "true" "
    echo '***  Creating image build configuration:'
    echo '- Build Directory: ${build_dir}'
    cd ${build_dir}
    echo 'FROM alpine:3.7' > ./build.docker
    echo 'WORKDIR /root/' >> ./build.docker
    echo 'RUN mkdir /root/${name}' >> ./build.docker
    echo 'COPY ./ /root/${name}/' >> ./build.docker
    echo 'COPY ./build.json /root/' >> ./build.docker
    echo '***   Removing existing image:'
    result=$(docker rmi \""${image_full_name}"\")
    echo '***   Building image:'
    docker build -f ./build.docker -t \""${image_full_name}\"" .
  ")"

  if [ "$(builder::IsImageAvailable "${full_name}" "${full_version}" "${in_server}")" == "true" ]; then
    echo "${image_full_name}"
  fi
}

builder::Deploy()
{
  # Usage Deploy <in:server> <in:build_metadata_path>
  local in_build_metadata_path=$1
  local in_server=$2
  local in_user=$3
  local in_password=$4

  local image_full_name=$(builder::CreateImage "${in_build_metadata_path}" "${in_server}")
  if [ "${image_full_name}" == "" ]; then
    log::Log "error" "1" "Could not find image full_name" ""
    return 0
  fi

  local deploy_log="$(script::ExecOnHost "true" "
    echo '***  Creating uploading "${image_full_name}":' ;
    docker login --username ${in_user} --password ${in_password} ${in_server} ;
    docker push "${image_full_name}" ;
    echo '***  Checking if image was properly uploaded:' ;
    docker rmi "${image_full_name}" ;
    docker pull "${image_full_name}" ;
    # echo '***  Getting image metadata:';
    # docker run -it --rm "${image_full_name}" cat ./build.json 
  ")"

  local local_metadata="$(script::ExecOnHost "false" "
    cat ${in_build_metadata_path}
  ")"
  local local_timestamp="$(json::GetValue "${local_metadata}" 'build_timestamp')"
  if [ "${local_timestamp}" == "" ]; then
    log::Log "error" "1" "Could not get the local timestamp" ""
    return 0
  fi

  local remote_metadata="$(script::ExecOnHost "false" "
    docker run -it --rm "${image_full_name}" cat ./build.json
  ")"
  local remote_timestamp="$(json::GetValue "${remote_metadata}" 'build_timestamp')"
  if [ "${local_timestamp}" != "${remote_timestamp}" ]; then
    log::Log "error" "1" "Remote image timestamp does not match the local image timestamp" ""
    return 0
  fi

  echo "${image_full_name}"
}

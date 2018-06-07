
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
    printf '\"%s\": \"%s\",' 'timestamp' \"\$(git log -1 --date=iso --pretty=format:%cd)\" | echo \$(cat) ;
    # printf '\"%s\": \"%s\",' 'tag' \"\$(git describe --tags)\" | echo \$(cat) ;
    cd ..
    printf '\"%s\": \"%s\",' 'upper_module_dir' \"\$(git rev-parse --show-toplevel)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_version' \"\$(git rev-parse --short HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_commit' \"\$(git rev-parse HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_branch' \"\$(git rev-parse --abbrev-ref HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\"' 'upper_timestamp' \"\$(git log -1 --date=iso --pretty=format:%cd)\" | echo \$(cat) ;
    # printf '\"%s\": \"%s\",' 'upper_tag' \"\$(git describe --tags)\" | echo \$(cat) ;
    echo '}'
  ")"

  local name="${module_dir##*/}"
  local platform="${in_platform}"
  local flavor="${in_flavor}"
  local version="$(json::GetValue "${git_result}" 'version')"
  local commit="$(json::GetValue "${git_result}" 'commit')"
  local branch="$(json::GetValue "${git_result}" 'branch')"
  local timestamp="$(json::GetValue "${git_result}" 'timestamp')"
  local tag="$(json::GetValue "${git_result}" 'tag')"
  local upper_module_dir="$(json::GetValue "${git_result}" 'upper_module_dir')"
  local upper_name="${upper_module_dir##*/}"
  local upper_version="$(json::GetValue "${git_result}" 'upper_version')"
  local upper_commit="$(json::GetValue "${git_result}" 'upper_commit')"
  local upper_branch="$(json::GetValue "${git_result}" 'upper_branch')"
  local upper_timestamp="$(json::GetValue "${git_result}" 'upper_timestamp')"
  local upper_tag="$(json::GetValue "${git_result}" 'upper_tag')"

  local location="${module_dir/${upper_module_dir}/}"
  location="${location/${name}/}"
  location="${location::-1}"
  local full_name="${upper_name}-${location}-${name}-${platform}-${flavor}"
  local full_version="${upper_branch}-${upper_version}-${branch}-${version}"
  full_name=${full_name//\//-}
  full_name=${full_name/--/-}
  full_version=${full_version/--/-}
  timestamp="$(date --utc +%FT%T.%3NZ)"

  json::VarsToJson name platform flavor version commit branch timestamp tag location upper_name upper_version upper_commit upper_branch upper_timestamp upper_tag upper_location full_name full_version timestamp
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
    local project_name="$(json::GetValue "${project_metadata}" 'name')"
    local full_name="$(json::GetValue "${project_metadata}" 'full_name')"
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

    local build_metadata="$(script::ExecOnHost "false" "
      cd "${cmake_file_dir}/.."
      cd "./stage/${in_platform,,}/${build_flavor,,}/${project_name,,}"
      echo '${build_log}' > ./build_detail.log
      cat ./build.json
    ")"

    if [ "$(json::GetValue "${build_metadata}" 'timestamp')" == "$(json::GetValue "${project_metadata}" 'timestamp')" ]; then
      echo "[ ${full_name} ] - SUCCESS"
    else
      echo "[ ${full_name} ] - FAILED"
    fi
  done
}

builder::IsImageAvailable()
{
  # Usage: IsImageAvailable <in:image_name> <in:image_version> [<in:server> [<in:user> <in:password>]]
  local in_image_name=$1
  local in_image_version=$2
  local in_server=$3
  local in_user=$4
  local in_password=$5

  local image_full_name="${in_server}/${in_image_name}:${in_image_version}"
  if [ "${in_server}" == "" ]; then
    image_full_name="${in_image_name}:${in_image_version}"
  fi

  local command_login="docker login --username ${in_user} --password ${in_password} devindusoft.azurecr.io"
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

builder::Deploy()
{
  # Usage Deploy <in:server> <in:build_metadata_path>
  local in_server=$1
  local in_build_metadata_path=$2

  # local build_dir="${in_build_metadata_path%/*}"
  local build_metadata="$(script::ExecOnHost "false" "
    cat ${in_build_metadata_path}
  ")"
  local full_name=$(json::GetValue "${build_metadata}" 'full_name')
  local full_version=$(json::GetValue "${build_metadata}" 'full_version')
  local docker_container_name="${in_server}/${function_name}:${full_version}"

  echo "$LINENO - ${build_metadata}"

}

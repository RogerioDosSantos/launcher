
builder::CreateProjectMetadata()
{
  # Usage: CreateProjectMetadata <in:project_dir>
  local in_project_dir=$1

  script::ExecOnHost "false" "echo '*** Creating project metadata'"

  local module_dir="$(script::ExecOnHost "false" "cd ${in_project_dir} ; git rev-parse --show-toplevel")"
  local git_result="$(script::ExecOnHost "false" "
    cd ${module_dir} ; 
    echo '{'
    printf '\"%s\": \"%s\",' 'version' \"\$(git rev-parse --short HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'commit' \"\$(git rev-parse HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'branch' \"\$(git rev-parse --abbrev-ref HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'timestamp' \"\$(git log -1 --date=iso --pretty=format:%cd)\" | echo \$(cat) ;
    cd ..
    printf '\"%s\": \"%s\",' 'upper_module_dir' \"\$(git rev-parse --show-toplevel)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_version' \"\$(git rev-parse --short HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_commit' \"\$(git rev-parse HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\",' 'upper_branch' \"\$(git rev-parse --abbrev-ref HEAD)\" | echo \$(cat) ;
    printf '\"%s\": \"%s\"' 'upper_timestamp' \"\$(git log -1 --date=iso --pretty=format:%cd)\" | echo \$(cat) ;
    echo '}'
  ")"

  local t1="$(echo "${git_result}" | python -c "import sys, json; print json.load(sys.stdin)['version']")"




  echo "${t1}"
  return 0

  local module_dir="$(script::ExecOnHost "false" "cd ${in_project_dir} ; git rev-parse --show-toplevel")"
  local name="${module_dir##*/}"
  local version="$(script::ExecOnHost "false" "cd ${in_project_dir} ; git rev-parse --short HEAD")"
  local commit="$(script::ExecOnHost "false" "cd ${in_project_dir} ; git rev-parse HEAD")"
  local branch="$(script::ExecOnHost "false" "cd ${in_project_dir} ; git rev-parse --abbrev-ref HEAD")"
  local timestamp="$(script::ExecOnHost "false" "cd ${in_project_dir} ; git log -1 --date=iso --pretty=format:%cd")"

  local upper_module_dir="$(script::ExecOnHost "false" "cd ${module_dir}/.. ; git rev-parse --show-toplevel")"
  local upper_name="${upper_module_dir##*/}"
  local upper_version="$(script::ExecOnHost "false" "cd ${module_dir}/.. ; git rev-parse --short HEAD")"
  local upper_commit="$(script::ExecOnHost "false" "cd ${module_dir}/.. ; git rev-parse HEAD")"
  local upper_branch="$(script::ExecOnHost "false" "cd ${module_dir}/.. ; git rev-parse --abbrev-ref HEAD")"
  local upper_timestamp="$(script::ExecOnHost "false" "cd ${module_dir}/.. ; git log -1 --date=iso --pretty=format:%cd")"


  local upper_location="${module_dir/${upper_module_dir}/}"

  local location="${config_location/${module_dir}/}"
  local full_name="${upper_name}-${name}-${location}"
  local full_version="${upper_branch}-${upper_version}-${branch}-${version}"
  full_name=${full_name/\//-}
  full_name=${full_name/--/-}
  full_version=${full_version/--/-}

  json_ret="{ 
    "\"name\"":"\"${name}\"",
    "\"version\"":"\"${version}\"",
    "\"commit\"":"\"${commit}\"",
    "\"branch\"":"\"${branch}\"",
    "\"timestamp\"":"\"${timestamp}\"",
    "\"location\"":"\"${location}\"",
    "\"upperName\"":"\"${upper_name}\"",
    "\"upperVersion\"":"\"${upper_version}\"",
    "\"upperCommit\"":"\"${upper_commit}\"",
    "\"upperBranch\"":"\"${upper_branch}\"",
    "\"upperTimeStamp\"":"\"${upper_timestamp}\"",
    "\"upperLocation\"":"\"${upper_location}\"",
    "\"fullName\"":"\"${full_name}\"",
    "\"fullVersion\"":"\"${full_version}\""

    echo "${json_ret}"
    if [ ${config_output_file_path} != "" ]; then 
      cd "${g_caller_dir}"
      echo "${json_ret}" > ${config_output_file_path}
    fi
  }"
}

builder::BuildCmake ()
{
  # Usage: BuildCmake <in:cmake_file_path>
  local in_cmake_file_path=$1

  echo "$LINENO - ${in_cmake_file_path}"
}

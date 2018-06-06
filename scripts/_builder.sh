
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
  local full_name="${upper_name}-${location}-${name}"
  local full_version="${upper_branch}-${upper_version}-${branch}-${version}"
  full_name=${full_name//\//-}
  full_name=${full_name/--/-}
  full_version=${full_version/--/-}

  json::VarsToJson name version commit branch timestamp tag location upper_name upper_version upper_commit upper_branch upper_timestamp upper_tag upper_location full_name full_version
}

builder::BuildCmake ()
{
  # Usage: BuildCmake <in:cmake_file_path>
  local in_cmake_file_path=$1

  echo "$LINENO - ${in_cmake_file_path}"
}

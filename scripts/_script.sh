#!/bin/bash

# echo "$LINENO - ${all_dependencies}"

script::GetDependencyFromConfig()
{
  #Usage: GetDependencyFromConfig <out:dependencies> <in:file_path>
  local out_dependencies=$1
  local in_file_path=$1

  #TODO(Roger) - Load JSON and get the dependencies from it

  # local dependencies=("helper" "log" "helper" "script" "log" "helper")
  local dependencies=("json" "helper" "log" "qa" "script" "helper_tests")
  local result=""
  printf -v "result" '%s\n' "${dependencies[@]}"
  printf -v "${out_dependencies}" '%s' "${result%?}"
}

script::GetScriptDependencies()
{
  # Usage: GetScriptDependencies <out:dependencies> <in:script>
  local out_dependencies=$1
  log::Log "info" "5" "out_dependencies" "${out_dependencies}"
  local in_script=$2
  log::Log "info" "5" "in_script" "${in_script}"

  helper::GetScriptDir ret_script_dir 

  local script_dir="${ret_script_dir}"
  local config_file_path="${script_dir}/_${in_script}.json"
  script::GetDependencyFromConfig ret_file_dependencies "${config_file_path}"

  # local file_dependencies="${ret_file_dependencies}"
  local file_dependencies=""
  printf -v "file_dependencies" '%s\n%s' "${in_script}" "${ret_file_dependencies}"
  local all_dependencies=""
  while read -r dependency; do
    # echo "$(echo "${all_dependencies}" | grep "${dependency}")"
    # local has_dependency="$( echo "${all_dependencies}" | grep "${dependency}" )"
    local has_dependency="$( echo "${all_dependencies}" | grep "${dependency}" | head -1 )"
    if [ "${has_dependency}" == "${dependency}" ]; then
      log::Log "info" "5" "Ignoring dependency" "${dependency}"
      continue
    fi
    printf -v "all_dependencies" '%s\n%s' "${all_dependencies}" "${dependency}"
    # log::Log "info" "5" "out_full_script" "${out_full_script}"
	done <<< "${file_dependencies}"

  all_dependencies=$( echo "${all_dependencies}" | sed -n '1!p' )
  printf -v "${out_dependencies}" '%s' "${all_dependencies}"
}

script::BuildScript()
{
  # Usage: BuildScript <out:full_script> <in:source_script>
  out_full_script=$1
  log::Log "info" "5" "out_full_script" "${out_full_script}"
  in_source_script=$2
  log::Log "info" "5" "in_source_script" "${in_source_script}"

  helper::GetScriptDir ret_script_dir 

  local script_dir="${ret_script_dir}"
  script::GetScriptDependencies ret_dependencies "${in_source_script}"

  local dependencies="${ret_dependencies}"
  local code=""
  while read -r dependency; do
    log::Log "info" "5" "Adding dependency" "${dependency}"
    local file_path="${script_dir}/_${dependency}.sh"
    if [ ! -f "${file_path}" ]; then
      log::Log "error" "1" "Could not find dependency file" "${file_path}"
      return 1
		fi

    # code="${code}$(cat "${file_path}" )"
    printf -v "code" "%s\n\n#### ${dependency} ####\n\n%s\n" "${code}" "$(cat "${file_path}" )"
	done <<< "${dependencies}"

  # code="${code}\n$(cat "${script_dir}/${source_script}.sh" )"
  # code="Dir: ${script_dir}"
  printf -v "${out_full_script}" '%s' "${code}"
}


#!/bin/bash

# echo "$LINENO - ${all_dependencies}"

script::GetDependencyFromConfig()
{
  #Usage: GetDependencyFromConfig <in:file_path>
  local in_file_path=$1


  #TODO(Roger) - Load JSON and get the dependencies from it
  if [ ! -f "${in_file_path}" ]; then
    log::Log "error" "1" "File does not exist" "${in_file_path}"
    echo ""
    return 0
  fi

  local index=0
  local dependencies=""
  while read -r dependency; do
    if [ "${dependency}" == "" ]; then
      continue
    fi

    dependency="${dependency/source \".\/_/}"
    dependency="${dependency/.sh\"/}"
    dependencies[${index}]="${dependency}"
    # echo "$LINENO - ${index} - ${dependency}"
    index=$[index + 1]
  done <<< "$(cat "${in_file_path}")"

  local result=""
  printf -v "result" '%s\n' "${dependencies[@]}"
  echo "${result%?}"
}

script::GetScriptDependencies()
{
  # Usage: GetScriptDependencies <in:script>
  local in_script=$1
  log::Log "info" "5" "in_script" "${in_script}"

  local script_dir="$(helper::GetScriptDir)"
  local config_file_path="${script_dir}/_${in_script}.dep"
  local file_dependencies="$(script::GetDependencyFromConfig "${config_file_path}")"
  printf -v "file_dependencies" '%s\n%s' "${in_script}" "${file_dependencies}"
  local all_dependencies=""
  while read -r dependency; do
    local has_dependency="$( echo "${all_dependencies}" | grep "${dependency}" | head -1 )"
    if [ "${has_dependency}" == "${dependency}" ]; then
      log::Log "info" "5" "Ignoring dependency" "${dependency}"
      continue
    fi
    printf -v "all_dependencies" '%s\n%s' "${all_dependencies}" "${dependency}"
    # log::Log "info" "5" "out_full_script" "${out_full_script}"
	done <<< "${file_dependencies}"

  all_dependencies=$( echo "${all_dependencies}" | sed -n '1!p' )
  echo "${all_dependencies}"
}

script::BuildScript()
{
  # Usage: BuildScript <in:source_script>
  in_source_script=$1
  log::Log "info" "5" "in_source_script" "${in_source_script}"

  local script_dir="$(helper::GetScriptDir)"
  local dependencies="$(script::GetScriptDependencies "${in_source_script}")"
  local code=""
  while read -r dependency; do
    log::Log "info" "5" "Adding dependency" "${dependency}"
    if [ "${dependency}" == "${in_source_script}" ]; then
      log::Log "warning" "1" "Cyclic Dependencies" "Script: ${in_source_script} ; File: ${file_path}"
      continue
    fi

    local file_path="${script_dir}/_${dependency}.sh"
    if [ ! -f "${file_path}" ]; then
      log::Log "warning" "1" "Could not find dependency file" "Script: ${in_source_script} ; File: ${file_path}"
      continue
		fi

    printf -v "code" "%s\n\n#### ${dependency} ####\n\n%s\n" "${code}" "$(cat "${file_path}" )"
	done <<< "${dependencies}"

  local file_path="${script_dir}/_${in_source_script}.sh"
  printf -v "code" "%s\n\n#### ${in_source_script} ####\n\n%s\n" "${code}" "$(cat "${file_path}" )"

  echo "${code}"
}


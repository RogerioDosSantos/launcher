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
  # Usage: BuildScript <in:name> <in:output_path>
  local in_name=$1
  local in_output_path="$2"
  log::Log "info" "5" "Parameters" "Name: ${in_name} ; Output: ${in_output_path}"

  local script_dir="$(helper::GetScriptDir)"
  local dependencies="$(script::GetScriptDependencies "${in_name}")"
  local code=""
  while read -r dependency; do
    log::Log "info" "5" "Adding dependency" "${dependency}"
    if [ "${dependency}" == "${in_name}" ]; then
      log::Log "warning" "1" "Cyclic Dependencies" "Script: ${in_name} ; File: ${file_path}"
      continue
    fi

    local file_path="${script_dir}/_${dependency}.sh"
    if [ ! -f "${file_path}" ]; then
      log::Log "warning" "1" "Could not find dependency file" "Script: ${in_name} ; File: ${file_path}"
      continue
		fi

    printf -v "code" "%s\n\n#### ${dependency} ####\n\n%s\n" "${code}" "$(cat "${file_path}" )"
	done <<< "${dependencies}"

  local file_path="${script_dir}/_${in_name}.sh"
  printf -v "code" "%s\n\n#### ${in_name} ####\n\n%s\n" "${code}" "$(cat "${file_path}" )"

  if [ "${in_output_path}" == "" ]; then
    echo "${code}"
    return 0
  fi

  echo "${code}" > "${in_output_path}"
}

script::RunScript()
{
  # Usage RunScript <in:script_function> <in:script_parameters>...
  local in_script_function="$1"
  local in_script_parameters="$2"
  log::Log "info" "5" "Parameters" "Function: ${in_script_function} ; Commands: ${in_script_parameters}"

  # local c1="sleep 15; echo 'finished 01'"
  # local c2="sleep 20; echo 'finished 02'"
  # local c3="sleep 25; echo 'finished 03'"
  # local status="while sleep 1; do echo \"still running\" ; done"
  # eval "${c1}" > "/session/c1.result" & pid1=$!
  # eval "${status}" & pids=$!
  # wait $pid1
  # kill $pids

  local script_name="$(echo "${in_script_function}" | cut -d: -f1)"
  local id="${script_name}_$(date +%s%N)"
  local script_path="/session/${id}.sh"
  local output_path="/session/${id}.out"
  local pid_path="/session/${id}.pid"
  log_config_file_path="/session/${id}.log"

  if [ "${script_config_debug}" == "1" ]; then
    log::Log "info" "5" "Debug: Dumping code to file" "${debug_script_path}"
    echo "${full_script}" > "${debug_script_path}"
    echo "${in_script_function} ${in_script_parameters}" >> "${debug_script_path}"
    return 0
  fi

  script::BuildScript "${script_name}" > ${script_path} 2> "${output_path}"
  echo "${in_script_function} ${in_script_parameters}" >> "${script_path}"
  /bin/bash -c "${script_path}" &> "${output_path}" &
  echo $! > ${pid_path}
  echo "${id}"
  
  # local full_script="$(script::BuildScript "${script_name}")"
  #
  # # echo $(echo "${full_script}" | grep "json::VarsToJson()")
  # eval "${full_script}"
  # eval "${in_script_function} ${in_script_parameters}"
}

script::RunTest()
{
  # Usage RunTest <in:test_name>
  local in_test_name=$1

  local script_name="$(echo "${in_test_name}" | cut -d: -f1)"
  script::RunScript "${script_name}::Run" "${in_test_name}"
}


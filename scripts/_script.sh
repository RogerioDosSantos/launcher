#!/bin/bash

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

# script::RunScript()
# {
#   # Usage RunScript <in:script_function> <in:script_parameters>...
#   local in_script_function="$1"
#   local in_script_parameters="$2"
#   log::Log "info" "5" "Parameters" "Function: ${in_script_function} ; Commands: ${in_script_parameters}"
#
#   # local c1="sleep 15; echo 'finished 01'"
#   # local c2="sleep 20; echo 'finished 02'"
#   # local c3="sleep 25; echo 'finished 03'"
#   # local status="while sleep 1; do echo \"still running\" ; done"
#   # eval "${c1}" > "/session/c1.result" & pid1=$!
#   # eval "${status}" & pids=$!
#   # wait $pid1
#   # kill $pids
#
#   local script_name="$(echo "${in_script_function}" | cut -d: -f1)"
#   local id="${script_name}_$(date +%s%N)"
#   local script_path="/session/${id}.sh"
#   local output_path="/session/${id}.out"
#   local pid_path="/session/${id}.pid"
#   log_config_file_path="/session/${id}.log"
#
#   if [ "${script_config_debug}" == "1" ]; then
#     log::Log "info" "5" "Debug: Dumping code to file" "${debug_script_path}"
#     echo "${full_script}" > "${debug_script_path}"
#     echo "${in_script_function} ${in_script_parameters}" >> "${debug_script_path}"
#     return 0
#   fi
#
#   script::BuildScript "${script_name}" > ${script_path} 2> "${output_path}"
#   echo "${in_script_function} ${in_script_parameters}" >> "${script_path}"
#   /bin/bash -c "${script_path}" &> "${output_path}" &
#   echo $! > ${pid_path}
#   echo "${id}"
#   
#   # local full_script="$(script::BuildScript "${script_name}")"
#   #
#   # # echo $(echo "${full_script}" | grep "json::VarsToJson()")
#   # eval "${full_script}"
#   # eval "${in_script_function} ${in_script_parameters}"
# }

# script::RunTest()
# {
#   # Usage RunTest <in:test_name>
#   local in_test_name=$1
#
#   local script_name="$(echo "${in_test_name}" | cut -d: -f1)"
#   script::RunScript "${script_name}::Run" "${in_test_name}"
# }

script::GetOutFilePath()
{
  # Usage GetOutFilePath <in:command_id>
  local in_command_id=$1

  echo "/root/${in_command_id}.out"
}

script::GetAnswerFilePath()
{
  # Usage GetAnswerFilePath <in:command_id>
  local in_command_id=$1

  echo "/root/${in_command_id}.answer"
}

script::GetScriptFilePath()
{
  # Usage GetScriptFilePath <in:command_id>
  local in_command_id=$1

  echo "/root/${in_command_id}.sh"
}

script::GetContainerName()
{
  echo "$(printenv 'CONTAINER_NAME')"
}

script::GetCommandModeString()
{
  echo "__$(printenv 'CONTAINER_NAME')__script::command_mode__"
}

script::GetDisplayModeString()
{
  echo "__$(printenv 'CONTAINER_NAME')__script::display_mode__"
}

script::GetExitModeString()
{
  echo "__$(printenv 'CONTAINER_NAME')__script::exit_mode__"
}

script::GetAnswerModeString()
{
  echo "__$(printenv 'CONTAINER_NAME')__script::answer_mode__"
}

script::SendExit()
{
  # Usage SendExit <in:command_id>
  local in_command_id=$1

  local out_file_path="$(script::GetOutFilePath "${in_command_id}")"
  echo "break" >> "${out_file_path}"
}

script::SendInstructions()
{
  # Usage <command> | SendInstructions <in:command_id>
  local in_command_id=$1

  local out_file_path="$(script::GetOutFilePath "${in_command_id}")"

  local command_mode="$(script::GetCommandModeString)"
  local exit_mode="$(script::GetExitModeString)"
  local display_mode="$(script::GetDisplayModeString)"
  local current_mode="${display_mode}"
  local command=""
  local input=""
  while [ "${input}" != "${exit_mode}" ]; do
    read input
    if [ "${input}" == "${display_mode}" ] || [ "${input}" == "${command_mode}" ] || [ "${input}" == "${exit_mode}" ]; then
      if [ "${command}" != "" ]; then
        echo "${command}" >> "${out_file_path}"
        command=""
      fi

      current_mode="${input}"
      continue
    fi 

    case "${current_mode}" in
        "${display_mode}")
          echo "echo \'${input}\'" >> "${out_file_path}"
          ;;
        "${command_mode}")
          printf -v "command" '%s\n%s' "${command}" "${input}"
          ;;
        *)
          ;;
    esac
  done

  script::SendExit "${in_command_id}"
}

script::GetInstructions()
{
  # Usage GetInstructions <in:command_id>
  local in_command_id=$1

  local out_file_path="$(script::GetOutFilePath "${in_command_id}")"
  while read line; do
    echo "$line"
  done < "${out_file_path}"

  exec 5<>"${out_file_path}"
  while read -t 0.5 line <& 5; do
    echo ${line}
	done
}

script::ExecOnHost()
{
  # Usage: ExecOnHost <in:display> <in:command>
  local in_display=$1
  local in_command=$2

  local index=0
  local commands[$index]=""

  # echo "$(script::GetCommandModeString)"

  if [ "${in_display}" == "true" ]; then
    commands[$index]=$(printf 'exec 5>&1 \n')
    index=$((index+1))
    commands[$index]=$(printf 'local script_command_answer="$(%s | tee >(cat - >&5))" \n' "${in_command}")
    index=$((index+1))
  else
    commands[$index]=$(printf 'local script_command_answer="$(%s)" \n' "${in_command}")
    index=$((index+1))
  fi

  local container_name="$(script::GetContainerName)"
  local answer_file_path="$(script::GetAnswerFilePath "${script__command_id}")"
  [ -p "${answer_file_path}"  ] || mkfifo "${answer_file_path}";
  commands[$index]=$(printf 'echo "${script_command_answer}" | docker exec -i "%s" /bin/bash -c "cat > %s" - \n' "${container_name}" "${answer_file_path}")
  index=$((index+1))

  local out_file_path="$(script::GetOutFilePath "${script__command_id}")"
  for line in "${commands[@]}"; do
    # printf '%s \n' "${line}"
    printf '%s \n' "${line}" > "${out_file_path}"
  done

  while read line; do
    echo "$line"
  done < "${answer_file_path}"
}

script::GetCommand()
{
  # Usage <in:command> <in:parameters>...
  local in_command=$1
  shift 1

  local old_ifs=$IFS
  IFS=$'\n'

	local configs=( $(xargs -n1 <<<"$(cat /scripts/_command_table | grep -w "${in_command/-/\\-}")") )
  IFS=${old_ifs}

  local command_to_run="${configs[0]}"
  for (( index=0; index<${configs[1]}; index++ )) ; do  
    if [[ $# == 0 ]]; then
      printf 'echo "Invalid Number of parameters" \n'
      return 0
    fi

    printf -v 'command_to_run' '%s "%s"' "${command_to_run}" "$1"
    shift 1
	done

  # printf 'echo "Result: %q" \n' "${command_to_run}" 
  printf '%s \n' "${command_to_run}" 
}

script::GetScriptFromCommand()
{
  # Usage: GetScriptFromCommand <in:command>
  local in_command=$1

  echo "$(echo "${in_command}"| cut -d: -f1)"
}

script::ExecScript()
{
  # Usage ExecScript <in:command_id> <in:commands>...
  local in_command_id=$1
  shift 1

  local index=0
  local commands[$index]="#! /bin/bash"
  local scripts[$index]="log"
  index=$((index+1))
  commands[$index]="trap \"echo $(script::GetExitModeString)\" EXIT"
  scripts[$index]=""
  index=$((index+1))
  commands[$index]="script__command_id=${in_command_id}"
  scripts[$index]=""

  local current_command=""
  while [[ $# != 0 ]]; do
      case $1 in
          -*)
            index=$((index+1))
            commands[$index]="$(script::GetCommand "$@")"
            scripts[$index]="$(script::GetScriptFromCommand "${commands[$index]}")"
            ;;
          *)
              ;;
      esac
      shift 1
  done

  local scripts_to_load="${scripts[0]}"
  for script in "${scripts[@]:1}"; do
    if [ "${script}" == "" ]; then 
      continue
    fi

    printf -v "scripts_to_load" '"%s" "%s"' "${script}"
  done

  local exec_script_path="$(script::GetScriptFilePath "${in_command_id}")"
  echo "${commands[0]}" > "${exec_script_path}"
  script::BuildScript "script_tests" >> "${exec_script_path}"
  for script in "${commands[@]:1}"; do
    echo "${script}" >> "${exec_script_path}"
  done

  local out_file_path="$(script::GetOutFilePath "${in_command_id}")"
  [ -p "${out_file_path}"  ] || mkfifo "${out_file_path}";
  /bin/bash "${exec_script_path}" 2>&1 | script::SendInstructions "${in_command_id}"
}


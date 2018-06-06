#!/bin/bash

script::GetCommandConfig()
{
  # Usage <in:command> <in:alternative>
  local in_command=$1
  shift 1

  local config="$(cat /scripts_library/_command_config | grep -w "\"${in_command/-/\\-}"\")"
  if [ "${config}" == "" ]; then
    config="$(cat /scripts/_command_config | grep -w "\"${in_command/-/\\-}"\")"
  fi

  echo "${config}"
}

script::CommandLineToOptionsConfig()
{
  # Usage : CommandLineToOptionsConfig <commands>...
  
  local current_config=""
  local current_parameters=""

  while [[ $# != 0 ]]; do
      case $1 in
          -*)
            if [ "${current_config}" != "" ]; then
              printf '%s \"%s\"\n' "${current_config}" "${current_parameters}"
            fi

            current_parameters=""
            current_config="$(script::GetCommandConfig "$1")"
            ;;
          *)
            if [ "${current_parameters}" == "" ]; then
              printf -v "current_parameters" '"%s"' "$1"
            else
              printf -v "current_parameters" '%s "%s"' "${current_parameters}" "$1"
            fi
            ;;
      esac
      shift 1
  done

  if [ "${current_config}" != "" ]; then
    printf '%s \"%s\"\n' "${current_config}" "${current_parameters}"
  fi
}

script::GetCommand()
{
  # Usage <in:command> <in:parameters>...
  local in_command=$1
  shift 1

  local old_ifs=$IFS
  IFS=$'\n'

	local configs=( $(xargs -n1 <<<"$(cat /scripts_library/_command_table | grep -w "${in_command/-/\\-}")") )
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

script::GetElementFromCommandLine()
{
  # Usage <in:element> <in:command_line>
  local in_element=$1
  shift 1

  local input_list="$(eval 'for word in '$@'; do echo "\"${word}\""; done')"
  printf '%s\n' "$(echo "${input_list}" | sed "${in_element}q;d")"

  # echo "${input_list}"
  # echo "$(echo "${input_list}" | sed "${in_element}q;d")"
}

script::HasInArray()
{
  # Usage HasInArray <in:value> <in:array_elements>...
  local in_value=$1
  shift 1

  while [[ $# != 0  ]]; do
    if [ "$1" == "${in_value}" ]; then
      echo "true"
      return 0
    fi

    shift 1
  done

  echo "false"
}

script::GetScriptDependencies1()
{
  # Usage GetScriptDependencies1 <in:script_name> <current_dependencies>...
  local in_script_name=$1
  shift 1

  if [ "$(script::HasInArray "${in_script_name}" "$@")" == "true" ]; then
    return 0
  fi

  local dependencies=("${in_script_name}")
  local dependency_file_path="/scripts_library/_${in_script_name}.dep"
  if [ ! -f "${dependency_file_path}" ]; then
    dependency_file_path="/scripts/_${in_script_name}.dep"
    if [ ! -f "${dependency_file_path}" ]; then
      log::Log "error" "1" "File does not exist" "${in_file_path}"
      echo "${in_script_name}"
      return 0
    fi
  fi

  dependencies+=($@)
  while read -r dependency; do
    if [ "${dependency}" == "" ]; then
      continue
    fi

    dependency="${dependency/.sh\"/}"
    dependency="${dependency/source \".\/_/}"
    if [ "$(script::HasInArray "${dependency}" "${dependencies[@]}")" == "true" ]; then
			continue
		fi

    # echo "$LINENO - ${dependency} "
    # return 0

    local additional_depencies="$(script::GetScriptDependencies1 "${dependency}" "${dependencies[@]}")"
    while read -r additional_dependency; do
      if [ "$(script::HasInArray "${additional_dependency}" "${dependencies[@]}")" == "true" ]; then
        continue
      fi

      dependencies+=("${additional_dependency}")
    done <<< "${additional_depencies}"

  done <<< "$(cat "${dependency_file_path}")"

  printf '%s\n' "${dependencies[@]}"
}

script::BuildScriptFromConfig()
{
  # Usage: <config> | BuildScriptFromConfig <in:command_id> <in:out_file_path>
  local in_command_id=$1
  local in_out_file_path=$2

  local commands=()
  local scripts=()
  local input=""


  while true; do
    # read input
    # if [ "$?" != "0" ]; then
    #   break;
    # fi

    input=$(/bin/bash -c 'read input; echo $input')
    if [ "${input}" == "" ]; then
      break;
    fi

    local exec_parameter="$(script::GetElementFromCommandLine "7" "${input}")"
    if [ "${exec_parameter}" == "\"\"" ]; then 
      exec_parameter=""
    fi

    local exec_function="$(script::GetElementFromCommandLine "3" "${input}")"
    exec_function="${exec_function//\"/}"

    local exec_command="${exec_function} ${exec_parameter}"
    commands+=("${exec_command}")

    local script_name="$(script::GetScriptFromCommand "${exec_command}")"
    if [ "$(script::HasInArray "${script_name}" "${scripts[@]}")" == "true" ]; then
			continue
		fi

    local dependencies="$(script::GetScriptDependencies1 "${script_name}" "${scripts[@]}")"
    while read -r dependency; do
      if [ "$(script::HasInArray "${dependency}" "${scripts[@]}")" == "true" ]; then
        continue
      fi

      scripts+=("${dependency}")
    done <<< "${dependencies}"

  done

  # echo "trap \"echo $(script::GetExitModeString)\" EXIT" >> "${in_out_file_path}"
  # echo "echo 'T1: "${scripts[@]}" '" >> "${in_out_file_path}"
  # return 0

  echo '#! /bin/bash' > "${in_out_file_path}"
  echo "trap \"echo $(script::GetExitModeString)\" EXIT" >> "${in_out_file_path}"
  echo "script__command_id=${in_command_id}" >> "${in_out_file_path}"
  for script in "${scripts[@]}"; do
    echo "#### ${script} ####" >> ${in_out_file_path}

    local script_file_path="/scripts_library/_${script}.sh"
    if [ ! -f "${script_file_path}" ]; then
      script_file_path="/scripts/_${script}.sh"
      if [ ! -f "${script_file_path}" ]; then
        #TODO(Roger) - Display Help
        echo "echo \"### Project not found: "${script}" ###\"" >> ${in_out_file_path}
        return 0
      fi
    fi

    cat "${script_file_path}" >> ${in_out_file_path}
  done

  echo "#### MAIN ####" >> "${in_out_file_path}"
  for command in "${commands[@]}"; do
    echo "${command}" >> "${in_out_file_path}"
    # echo "$LINENO - ${command}"
  done
}

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
    commands[$index]=$(printf 'local script_command_answer="$((%s) | tee >(cat - >&5))" \n' "${in_command}")
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

script::GetScriptFromCommand()
{
  # Usage: GetScriptFromCommand <in:command>
  local in_command=$1

  local current_command="$(echo "${in_command}"| cut -d\  -f1)"
  if [ "${current_command}" == "qa::Run" ]; then
    current_command="$(echo "${in_command/\"/}"| cut -d\  -f2)"
  fi

  echo "$(echo "${current_command}"| cut -d: -f1)"
}

script::ExecScript()
{
  # Usage ExecScript <in:command_id> <in:commands>...
  local in_command_id=$1
  shift 1

  local exec_script_path="$(script::GetScriptFilePath "${in_command_id}")"
  local config="$(script::CommandLineToOptionsConfig "$@")"
  echo "$config" | script::BuildScriptFromConfig "${in_command_id}" "${exec_script_path}"

  local out_file_path="$(script::GetOutFilePath "${in_command_id}")"
  [ -p "${out_file_path}"  ] || mkfifo "${out_file_path}";
  /bin/bash "${exec_script_path}" 2>&1 | script::SendInstructions "${in_command_id}"
}

script::Help()
{
  # TODO (Roger) 
  echo "Help Called"
}

script::RunFunction()
{
  # Usage RunFunction <in:function_name> <in_parameters>...
  local in_function_name=$1
  shift 1

  echo "$LINENO - ${in_function_name}"
}


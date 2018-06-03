
runner::GetContainerStatus()
{
  # Usage GetContainerStatus <in:container_name>
  local in_container_name=$1

  local container_id="$(docker ps -q -f name=${in_container_name})"
  if [ "${container_id}" == "" ]; then
    log::Log "info" "5" "Container does not exist" "${in_container_name}"
    echo "unexistent"
    return 0
  fi

  local is_running="$(docker inspect -f {{.State.Running}} ${container_id})"
  if [ "${is_running}" == "true" ]; then
    log::Log "info" "5" "Container is running" "Name: ${in_container_name} ; ID: ${container_id}"
    echo "running"
    return 0
  fi
  
  if [ "${is_running}" == "false" ]; then
    log::Log "info" "5" "Container is stopped" "Name: ${in_container_name} ; ID: ${container_id}"
    echo "stopped"
    return 0
  fi
  
  return 1
}

runner::StartContainer()
{
  # Usage: StartContainer <in:execution_type> <in:image_name> <in:container_name> <in_caller_dir>
  local in_execution_type=$1
  local in_image_name=$2
  local in_container_name=$3
  local in_caller_dir=$4

  local shell_command=""
  local container_status=$(runner::GetContainerStatus ${in_container_name});
  case "${container_status}" in
      running)
        return 0
        ;;
      stopped)
        shell_command="docker start ${in_container_name}"
        log::Log "info" "5" "Docker Command" "${shell_command}"
        return 0
        ;;
      unexistent)
        ;;
      *)
        log::Log "error" "1" "Unknown docker container status" "${container_status}"
        return 1
        ;;
  esac

  local script_dir=$(pwd -P) && cd ${in_caller_dir}
  local caller_dir="$(pwd -P)" && cd "${script_dir}/.."
  local workspace_dir="$(pwd -P)" && cd "${script_dir}"
  if [ "${in_execution_type}" == "debug" ]; then
    local docker_work_dir=$(docker::NormalizeDir "${workspace_dir}/debug/work")
    local docker_session_dir=$(docker::NormalizeDir "${workspace_dir}/debug/session")
    local docker_scripts_dir=$(docker::NormalizeDir "${workspace_dir}/scripts")
    local docker_doc_dir=$(docker::NormalizeDir "${workspace_dir}/doc")
    local image_name="${in_image_name}_base"
    shell_command="docker run -d -it --rm --name \"${in_container_name}\" -e CONTAINER_NAME=\"${in_container_name}\" -v ${docker_work_dir}:/work -v ${docker_session_dir}:/session -v ${docker_scripts_dir}:/scripts -v ${docker_doc_dir}:/doc ${image_name} -se"
  else
    local docker_work_dir=$(docker::NormalizeDir "${caller_dir}")
    local image_name="${in_image_name}"
    shell_command="docker run -d -it --rm --name \"${in_container_name}\" -e CONTAINER_NAME=\"${in_container_name}\" -v ${docker_work_dir}:/work ${image_name} -se"
  fi

  log::Log "info" "5" "Docker Command" "${shell_command}"
  local resp=$(bash -c "${shell_command}")
  log::Log "info" "5" "Execution result" "${resp}"
}

runner::StopContainer()
{
  # Usage: StopContainer <container_name>
  local container_name=$1

  #TODO(Roger) - Decide if I am going to stop the conatiner on release.
  return 0

  local shell_command="docker stop ${container_name}"
  log::Log "info" "5" "Execution shell" "${shell_command}"
  local result=$(/bin/bash -c "${shell_command}")
  if [ "${result}" != "${container_name}" ]; then
    log::Log "error" "1" "Could not stop container" "${container_name}"
    log::Log "error" "2" "Error Detail" "${result}"
  fi
}

runner::RunCommand()
{
  # Usage: RunCommand <container_name> <commands>...
  local container_name=$1
  shift 1

  local shell_command="docker exec launcher-debug /bin/bash -c \"/scripts/main.sh $@\""
  log::Log "info" "5" "Execution shell" "${shell_command}"
  command_id=$(/bin/bash -c "${shell_command}")
  echo "${command_id}"
}


runner::Runner()
{
  # echo "$(docker::IsVirtualBox)"
  # return 0

  # log_config_show_log="1"
  # log_config_log_enabled="1"
  # log_config_file_path="temp.log"

  # Usage Runner <in:execution_type> <in:image_name> <in:caller_dir> <in:parameters>...
  local in_execution_type=$1
  local in_image_name=$2
  local in_caller_dir=$3
  shift 3

  local container_id=$(if [ "${in_execution_type}" == "debug" ]; then echo "debug"; else echo ${RANDOM}; fi)
  local container_name="$(echo "${in_image_name}" | cut -d "/" -f 2)-${container_id}"
  runner::StartContainer "${in_execution_type}" "${in_image_name}" "${container_name}" "${in_caller_dir}"

  local command_id=$(runner::RunCommand "${container_name}" -rc "$@")
  if [ "${command_id}" == "-1" ] || [ "${command_id}" == "" ]; then
    log::Log "info" "5" "Could not find command" "${shell_command}"
    echo "Invalid command: $@"
    echo "$(runner::RunCommand ${container_name} -h)"
    runner::StopContainer "${container_name}"
    return 0
  fi

  while [ true ]; do
    local activity=$(runner::RunCommand "${container_name}" -gi "${command_id}")
    echo "$LINENO - Instruction=${activity}"
    echo "$LINENO - - - "
    eval "${activity}"
    # runner::RunCommand "${container_name}" -ai "${command_id}" "script_command_answer"
    echo "$LINENO - - - "
  done 
}


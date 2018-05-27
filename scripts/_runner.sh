#!/bin/bash

Init()
{
  # Setup - Go to the directory where the bash file is
  g_script_name="$(basename "$0")"
  g_caller_dir=$(pwd)
  cd "$(dirname "$0")"
  g_script_dir=$(pwd)

  # g_session_dir="${g_script_dir}/${RANDOM}_runner_${RANDOM}"
  # mkdir -p "${g_session_dir}"
}

End()
{
  # Log "info" "5" "Removing session directory" "${g_session_dir}"
  # rm -r "${g_session_dir}"

  Log "info" "5" "Returning to caller directory" "${g_caller_dir}"
  cd "${g_caller_dir}"
}

ScriptDetail()
{
  log::Log "info" "5" "Script Name" "${g_script_name}"
  log::Log "info" "5" "Caller Directory" "${g_caller_dir}"
  log::Log "info" "5" "Script Directory" "${g_script_dir}"
}

GetConfiguration()
{
  if [[ $# == 0  ]]; then
    DisplayHelp
    return 0
  fi

  config_log_level="1"
  config_log_type="all"
  config_debug="0"
  config_build_script=("0", "", "")
  config_run_script=("0", "", "")
  config_run_test=("0", "")
  while [[ $# != 0 ]]; do
      case $1 in
          --show_log|-ls)
            log_config_show_log="1"
            log_config_log_enabled="1"
            log_config_file_path=".temp_log_to_show_$(date '+%Y-%m-%d')"
            log::Log "info" "1" "Show Log Enabled" ""
            shift 1
            ;;
          --log_enable|-le)
            log_config_log_enabled="1"
            log::Log "info" "1" "Log Enabled" ""
            shift 1
            ;;
          --log_level|-le)
            config_log_level="$2"
            log::Log "info" "1" "Log Level" "${config_log_level}"
            shift 2
            ;;
          --log_type|-lt)
            config_log_type="$2"
            log::Log "info" "1" "Log Type" "${config_log_type}"
            shift 2
            ;;
          --debug|-d)
            config_debug="1"
            log::Log "info" "1" "Debug Enabled" ""
            shift 1
            ;;
          --build_script|-bs)
            if [[ $# < 3 ]]; then
              echo "build_script: Missing parameters $#"
              DisplayHelp
              return 0
            fi
            config_build_script[0]="1"
            config_build_script[1]="$2"
            config_build_script[2]="$3"
            log::Log "info" "1" "Requested build_script" "Name: ${config_build_script[1]} ; Output: ${config_build_script[2]}"
            shift 3
            ;;
          --run_script|-rs)
            if [[ $# < 2 ]]; then
              echo "run_script: Missing parameters $#"
              DisplayHelp
              return 0
            fi
            config_run_script[0]="1"
            config_run_script[1]="$2"
            shift 2
            printf -v "config_run_script[2]" '%q ' "$@"
            log::Log "info" "1" "Requested run_script" "Name: ${config_run_script[1]} ; Commands: ${config_run_script[2]}"
            return 0
            ;;
          --run_test|-rt)
            if [[ $# < 2 ]]; then
              echo "run_test: Missing parameters $#"
              DisplayHelp
              return 0
            fi
            config_run_test[0]="1"
            config_run_test[1]="$2"
            shift 2
            # printf -v "config_run_test[2]" '%q ' "$@"
            log::Log "info" "1" "Requested run_test" "Test Name: ${config_run_test[1]}"
            return 0
            ;;
          --)
              shift
              break
              ;;
          --help|-h)
              DisplayHelp
              exit
              ;;
          -*)
              log::Log "error" "1" "Unknown option" "$1"
              DisplayHelp
              exit
              ;;
          *)
              break
              ;;
      esac
  done
}

RunDocker()
{
  # Usage: RunDocker <image_name> <session_dir> <commands>

  local docker_image=$1
  shift 1
  local session_dir=$1
  shift 1

  local container_name="${docker_image/\//-}-${RANDOM}"
  cd ${g_caller_dir}
  local work_dir="$(pwd -P)"
  NormalizeDir work_dir "${work_dir}"
  NormalizeDir session_dir "${session_dir}"

  local shell_command="docker run -it --rm --name ${container_name} -v "${session_dir}":/session -v "${work_dir}":/work ${docker_image} $@"
  Log "info" "5" "Docker Command" "${shell_command}"
  eval ${shell_command}
  # docker run -it --rm --name ${container_name} -v "${session_dir}":/session -v "${work_dir}":/work ${docker_image} "$@"
}

MainFunction()
{
  local post_execution="${g_session_dir}/exec.sh"
  echo "" > "${post_execution}"

  # exec &> "${g_session_dir}/run_image.log"
  RunDocker "${config_image}" "${g_session_dir}" ${config_options}
  # exec &>/dev/tty

  ${post_execution}
}

# Main
set -E
trap 'log::ErrorHandler $LINENO' ERR

Init
GetConfiguration "$@"
ScriptDetail
MainFunction
End


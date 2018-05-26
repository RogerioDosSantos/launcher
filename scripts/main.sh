#!/bin/bash

Init()
{
  # Setup - Go to the directory where the bash file is
  g_script_name="$(basename "$0")"
  g_caller_dir=$(pwd)
  cd "$(dirname "$0")"
  g_script_dir=$(pwd)
  source "./_helper.sh"
  source "./_log.sh"
  source "./_script.sh"
  log::Init
}

End()
{
  log::Log "info" "5" "Returning to caller directory" "${g_caller_dir}"
  log::End
  cd "${g_caller_dir}"
}

ScriptDetail()
{
  log::Log "info" "5" "Script Name" "${g_script_name}"
  log::Log "info" "5" "Caller Directory" "${g_caller_dir}"
  log::Log "info" "5" "Script Directory" "${g_script_dir}"
}

DisplayHelp()
{
  echo "${g_script_name/.sh/} --<command> [<command_options>]"
  echo " "
  echo "- Commands:"
  echo "--help (h) : Display this command help"
  echo "--log_enable (-le) : Enable log"
  echo "--show_log (-ls) : Enable log and show it"
  echo "--log_level (-ll) <level>: Define the Log Level (Default: ${config_log_level})"
  echo "--log_type (-lt) <type>: Define the Log Type [Options: all, error, warning, info] (Default: ${config_log_type})"
  echo "--debug (-d) : Save the build script and runner the debug file prior running it."
  echo "--build_script (-bs) <name> <out_path>: Build a script and return the value on the screen or on a file."
  echo "--run_script (-rs) <name> [<commands>...]: Build and Run Script."
  echo " "
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

BuildScript()
{
  # Usage BuildScript <in:name> <in:output_path>
  local in_name="$1"
  local in_output_path="$2"

  log::Log "info" "5" "Parameters" "Name: ${in_name} ; Output: ${in_output_path}"

  local full_script=""
  script::BuildScript full_script "${in_name}" 
  if [ "${in_output_path}" == "" ]; then
    echo "${full_script}"
    return 0
  fi

  echo "${full_script}" > "${in_output_path}"
}

RunScript()
{
  # Usage BuildScript <in:name> <in:output_path>
  local in_name="$1"
  local in_commands="$2"

  log::Log "info" "5" "Parameters" "Name: ${in_name} ; Commands: ${in_output_path}"

  script::BuildScript ret_full_script "${in_name}" 
  local full_script="${ret_full_script}"
  if [ "${config_debug}" == "1" ]; then
    log::Log "info" "5" "Debug: Dumping code to file" ".temp_debug"
    echo "${full_script}" > "./.temp_debug"
    echo "${in_commands}" >> "./.temp_debug"
    ./.temp_debug
    return 0
  fi

  eval "${full_script}"
  eval "${in_commands}"
  return 0
}

MainFunction()
{
  log::Log "info" "5" "Main Execution" ""
  if [ "${config_build_script[0]}" == "1" ]; then BuildScript "${config_build_script[@]:1}"; fi
  if [ "${config_run_script[0]}" == "1" ]; then RunScript "${config_run_script[@]:1}"; fi
}

# Main

set -E
trap 'log::ErrorHandler $LINENO' ERR

Init
GetConfiguration "$@"
ScriptDetail
MainFunction
End


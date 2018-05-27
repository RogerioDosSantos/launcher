
main::Init()
{
  # Setup - Go to the directory where the bash file is
  log::Init
}

main::End()
{
  log::Log "info" "5" "Returning to caller directory" "${g_caller_dir}"
  log::End
  cd "${g_caller_dir}"
}

main::ScriptDetail()
{
  log::Log "info" "5" "Script Name" "${g_script_name}"
  log::Log "info" "5" "Caller Directory" "${g_caller_dir}"
  log::Log "info" "5" "Script Directory" "${g_script_dir}"
}

main::GetConfiguration()
{
  if [[ $# == 0  ]]; then
    doc::Help
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
              doc::Help "runner"
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
              doc::Help "runner"
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
              doc::Help "runner"
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
              doc::Help "./_${2}.md"
              exit
              ;;
          -*)
              log::Log "error" "1" "Unknown option" "$1"
              doc::Help "runner"
              exit
              ;;
          *)
              break
              ;;
      esac
  done
}

main::BuildScript()
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

main::RunScript()
{
  # Usage RunScript <in:name> <in:commands>
  local in_name="$1"
  local in_commands="$2"

  log::Log "info" "5" "Parameters" "Name: ${in_name} ; Commands: ${in_output_path}"

  local full_script="$(script::BuildScript "${in_name}")"
  if [ "${config_debug}" == "1" ]; then
    log::Log "info" "5" "Debug: Dumping code to file" ".temp_debug"
    echo "${full_script}" > "./.temp_debug"
    echo "${in_commands}" >> "./.temp_debug"
    ./.temp_debug
    return 0
  fi

  eval "${full_script}"
  eval "${in_commands}"
}

main::RunTest()
{
  # Usage RunTest <in:test_name>
  local test_name=$1
  main::RunScript "qa" "qa::Run ${test_name}"
}

main::Run()
{
  log::Log "info" "5" "Main Execution" ""
  if [ "${config_build_script[0]}" == "1" ]; then main::BuildScript "${config_build_script[@]:1}"; fi
  if [ "${config_run_script[0]}" == "1" ]; then main::RunScript "${config_run_script[@]:1}"; fi
  if [ "${config_run_test[0]}" == "1" ]; then main::RunTest "${config_run_test[1]}"; fi
}

main::Main()
{
  # Usage Main <parameters>...

  main::Init
  main::GetConfiguration "$@"
  main::ScriptDetail
  main::Run
  main::End
}


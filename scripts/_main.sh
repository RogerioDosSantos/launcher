
main::GetConfiguration()
{
  if [[ $# == 0  ]]; then
    doc::Help
    return 0
  fi

  script_config_debug="0"
  config_log_level="1"
  config_log_type="all"
  config_build_script=("0", "", "")
  config_run_script=("0", "", "")
  config_run_test=("0", "")
  config_docker_execute=("0", "")
  config_setup="0"
  config_get_activity=("0", "")
  config_serve="0"
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
            script_config_debug="1"
            log::Log "info" "1" "Debug Enabled" ""
            shift 1
            ;;
          --get_activity|-ga)
            if [[ $# < 1 ]]; then
              echo "get_activity: Missing parameters $#"
              doc::Help "runner"
              return 0
            fi
            config_get_activity[0]="1"
            config_get_activity[1]="$2"
            log::Log "info" "5" "get_activity requested" "Command ID: ${config_get_activity[1]}"
            shift 2
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
          --docker_execute|-de)
            config_docker_execute[0]="1"
            shift 1
            printf -v "config_docker_execute[1]" '%q ' "$@"
            log::Log "info" "1" "Requested docker_execute" "Commands: ${config_docker_execute[2]}"
            return 0
            ;;
          --setup|-s)
            config_setup="1"
            log::Log "info" "1" "Setup Requested" ""
            shift 1
            ;;
          --serv|-se)
            config_serve="1"
            shift 1
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

main::ScriptDetail()
{
  log::Log "info" "5" "Script Name" "${g_script_name}"
  log::Log "info" "5" "Caller Directory" "${g_caller_dir}"
  log::Log "info" "5" "Script Directory" "${g_script_dir}"
}

main::Alive()
{
  echo "Worked"
}

main::DockerExecute()
{
  bash -c "$@"
}

main::Setup()
{
  echo "#!/bin/bash"
  echo " "

  local script="$(script::BuildScript "runner")"
  echo "${script}"
  echo " "
  script=$(cat "./runner.sh" | sed -n '1!p')
  echo "${script}"
  echo " "
}

main::Serve()
{
  /bin/bash
}

main::Run()
{
  log::Log "info" "5" "Main Execution" ""
  if [ "${config_setup}" == "1" ]; then main::Setup; fi
  if [ "${config_serve}" == "1" ]; then main::Serve; fi
  if [ "${config_get_activity[0]}" == "1" ]; then _log::GetActivity "${config_get_activity[@]:1}"; fi
  if [ "${config_build_script[0]}" == "1" ]; then script::BuildScript "${config_build_script[@]:1}"; fi
  if [ "${config_run_script[0]}" == "1" ]; then script::RunScript "${config_run_script[@]:1}"; fi
  if [ "${config_run_test[0]}" == "1" ]; then script::RunTest "${config_run_test[1]}"; fi
  if [ "${config_docker_execute[0]}" == "1" ]; then main::DockerExecute "${config_docker_execute[1]}"; fi
}

main::Main()
{
  # Usage Main <parameters>...
  main::GetConfiguration "$@"
  main::ScriptDetail
  main::Run
}



log::Init()
{
  log_config_show_log="0"
  log_config_log_enabled="0"
  # log_config_file_path=".temp_log_$(date '+%Y-%m-%d')"
  log_config_file_path="../session/log"
}

log::End()
{
  log::ShowLog
}

log::Log()
{
  # Log <type> <level> <message> <detail>

  if [ "${log_config_log_enabled}" != "1" ]; then
    return 0
  fi

  local log_type=$1
  local log_level=$2
  local log_message=$3
  local log_detail=$4
  local log_date="$(date '+%Y-%m-%d %H:%M:%S')"
  local log_caller=${FUNCNAME[1]}
  local log_file_path="${log_config_file_path}"
  echo "${log_date},${log_type},${log_level},${log_caller},${log_message},${log_detail}" >> ${log_file_path}
}

log::ShowLog()
{
  if [ "${log_config_show_log}" != "1" ]; then 
    return 0
  fi

  echo " "
  echo "======= Log ======="
  cat "${log_config_file_path}"
  rm "${log_config_file_path}"
}

log::ErrorHandler()
{
  # Usage: ErrorHandler <in:last_line>
  local last_line=$1
  log::Log "error" "1" "Last line executed" "${last_line}"
  for function_name in "${FUNCNAME[@]:1}"; do
    log::Log "error" "2" "Stack" "${function_name}"
	done
  End
  exit 1
}

_log::GetActivity()
{
  # Usage GetActivity <in:command_id>
  local command_id=$1
  log::Log "info" "5" "command id" "${command_id}"
  echo "$LINENO - GetActivity ${command_id}" 
  sleep 5
  echo "$LINENO - GetActivity ${command_id}" 
  
}


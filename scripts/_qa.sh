
qa::Init()
{
  # Usage Init <test_name>
  local test_name="$1"
  qa_config_temp_test_file=".${test_name}_test_$(date '+%Y-%m-%d-%H-%M-%S')"
  echo "======= Test ${test_name} =======" > "${qa_config_temp_test_file}"
}

qa::End()
{
  cat "${qa_config_temp_test_file}"
  rm "${qa_config_temp_test_file}"
}

qa::AddTestResult()
{
  # Usage AddTestResult <test_name> <test_result> <error_message> <expected> <current>
  local in_test_name=$1
  local in_test_result=$2
  local in_error_message=$3
  local in_expected=$4
  local in_current=$5

  local caller=${FUNCNAME[2]}
  if [ "${in_test_result}" == "OK" ]; then
    echo "[ ${caller} - ${in_test_name} ] - OK" >> "${qa_config_temp_test_file}"
    return 0
  fi

  echo "[ ${caller} - ${in_test_name} ] - ${in_test_result}" >> "${qa_config_temp_test_file}"
  echo " - Reazon: ${in_error_message}" >> "${qa_config_temp_test_file}"
  echo " - Expected:" >> "${qa_config_temp_test_file}"
  echo "${in_expected}" >> "${qa_config_temp_test_file}"
  echo " - Current:" >> "${qa_config_temp_test_file}"
  echo "${in_current}" >> "${qa_config_temp_test_file}"
}

qa::AreEqual()
{
  # Usage: <test> | AreEqual <in:test_name> <in:error_message>
  local in_test_name=$1
  local in_error_message=$2
  local in_test_result=$(cat)

  #TODO(Roger) - Put it in its own function
  local function_name="${FUNCNAME[1]}"
  function_name="${function_name/::/-}"

  local test_file_path="../quality/${function_name}-${in_test_name}.txt"
  test_file_path="${test_file_path,,}"
  log::Log "info" "5" "Expected Test File Path" "${test_file_path}"
  if [ ! -f "${test_file_path}" ]; then
    log::Log "info" "5" "Test result not found. Creating it." "${test_file_path}"
    $(echo "${in_test_result}" > "${test_file_path}")
  fi

  local expected="$(cat ${test_file_path})"
  if [ "${expected}" == "${in_test_result}" ]; then
    log::Log "info" "5" "Test Passed" "${FUNCNAME[1]} - ${in_test_name}"
    qa::AddTestResult "${in_test_name}" "OK" "${in_error_message}" "${expected}" "${in_test_result}"
    return 0
  fi

  log::Log "info" "5" "Test Failed" "${FUNCNAME[1]} - ${in_test_name}"
  qa::AddTestResult "${in_test_name}" "FAILED" "${in_error_message}" "${expected}" "${in_test_result}"
}

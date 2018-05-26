
helper_tests::Run()
{
  # Usage [<in:test_to_run>]
  local in_test_to_run="$1" 
  log::Log "info" "5" "in_test_to_run" "${in_test_to_run}"

  g_qa=""
  if [ "${in_test_to_run}" != "all" ]; then
    eval "helper_tests::${in_test_to_run}"
    return 0
  fi

  # TODO(Roger) - Add logic to run all tests

  echo "${q_qa}"
}

helper_tests::TestReturn()
{
  g_qa=$(echo "This is cool" | qa::AreEqual "${g_qa}" "basic_test" "Could not validate basic_test")
  g_qa=$(echo "This is cool" | qa::AreEqual "${g_qa}" "basic_test" "Could not validate basic_test")
  echo "${g_qa}"

  # helper::Return "result" "'$*'" "json_file" "$(cat ./_helper.json )" | qa::AreEqual
}


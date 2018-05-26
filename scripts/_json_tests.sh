
json_tests::Run()
{
  # Usage [<in:test_to_run>]
  local in_test_to_run="$1" 
  log::Log "info" "5" "in_test_to_run" "${in_test_to_run}"
  qa::Init "json"
  if [ "${in_test_to_run}" != "all" ]; then
    eval "json_tests::${in_test_to_run}"
    qa::End
    return 0
  fi

  # TODO(Roger) - Add logic to run all tests
  qa::End
}

json_tests::VarsToJson()
{
  # echo "This is cool" | qa::AreEqual "basic_test" "Could not validate basic_test"

  local pr1="1"
  local pr2="2"
  local pr3="3"
  local pr4="4"
  json::VarsToJson pr1 pr2 pr3 pr4 | qa::AreEqual "4_assignments" "Wrong assignment"

  local weird_chars='This is an json with weird chars []{}+_""!@#$$%^^&*((?/))' | qa::AreEqual "weird_chars" "Could not support weird charecters."
  json::VarsToJson weird_chars
}


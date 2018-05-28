
helper_tests::Run()
{
  # Usage Run <in:test_name>
  local in_test_name=$1
  qa::Run "${in_test_name}"
}

helper_tests::TestReturn()
{
  echo "This is cool" | qa::AreEqual "basic_test" "Could not validate basic_test"
}


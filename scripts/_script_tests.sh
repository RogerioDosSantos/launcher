
script_tests::Run()
{
  # Usage Run <in:test_name>
  local in_test_name=$1
  qa::Run "${in_test_name}"
}

script_tests::GetDependencyFromConfig()
{
  script::GetDependencyFromConfig ../quality/script_tests-basic.dep | qa::AreEqual "basic_dependency_file" "Could not load a basic dependency file"
}


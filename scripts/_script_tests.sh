
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

script_tests::ExecOnHost()
{
  # script::ExecOnHost "uname -a" | qa::AreEqual "basic_execution_on_host" "Could not execut on host"
  # script::ExecOnHost "true" "uname -a"
  # script::ExecOnHost "false" "uname -a"
  # script::ExecOnHost "false" "ls -al"
  # script::ExecOnHost "false" "git status; uname -a"
  script::ExecOnHost "false" "docker images ; docker ps"
}


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
  script::ExecOnHost "true" "echo '*** Testing execution on Host Machine:'" | qa::AreEqual "basic_execution_on_host" "Could not execute on host"
  script::ExecOnHost "true" 'if [[ "$(docker images -q alpine:2.6 2> /dev/null)" == "" ]]; then docker pull alpine:2.6; fi' > /dev/null
  script::ExecOnHost "true" 'if [[ "$(docker images -q alpine:3.7 2> /dev/null)" == "" ]]; then docker pull alpine:3.7; fi' > /dev/null
  script::ExecOnHost "true" 'if [[ "$(docker images -q alpine/git:1.0.3 2> /dev/null)" == "" ]]; then docker pull alpine/git:1.0.3; fi' > /dev/null
  script::ExecOnHost "false" "docker inspect alpine:2.6" | qa::AreEqual "docker_inspect_alpine_26" "Could not execute docker command properly"
  script::ExecOnHost "false" "docker inspect alpine:3.7" | qa::AreEqual "docker_inspect_alpine_37" "Could not execute docker command properly"
  script::ExecOnHost "false" "docker inspect alpine/git:1.0.3" | qa::AreEqual "docker_inspect_alpine_git_103" "Could not execute docker command properly"
  script::ExecOnHost "false" "docker run --rm alpine/git:1.0.3 --version" | qa::AreEqual "docker_git_version_103" "Could not run docker image properly"
}

script_tests::GetCommand()
{
  script::GetCommand "-rt" "p1" | qa::AreEqual "basic_positice_case" "Could not solve command properly"
  script::GetCommand "-rt" "p1" "p2" | qa::AreEqual "number_of_parameters_superior" "Could not solve command properly"
  script::GetCommand "-rt" | qa::AreEqual "number_of_parameters_inferior" "Could not detect a number inferior of parameters"
}

script_tests::GetScriptFromCommand()
{
  script::GetScriptFromCommand "test::tq" | qa::AreEqual "basic_positice_case" "Could not resolve script"
  script::GetScriptFromCommand "script::GetScriptFromCommand" | qa::AreEqual "basic_positice_case_1" "Could not resolve script"
  script::GetScriptFromCommand "script_tests::GetCommand" | qa::AreEqual "basic_positice_case_2" "Could not resolve script"

  script::GetScriptFromCommand 'qa::Run "script_tests::GetScriptFromCommand"' | qa::AreEqual "qa_run_should_return_the_test_script" "qa::Run not handled properly"
}

script_tests::BuildScript()
{
  script::BuildScript "script_tests" | qa::AreEqual "t_" "-"
}


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

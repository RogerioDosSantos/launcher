
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

script_tests::GetCommandConfig()
{
  script::GetCommandConfig -rt "script_tests::CommandLineToOptionsConfig" | qa::AreEqual "basic_qa" "Could not get short option"
  script::GetCommandConfig --run_test "script_tests::CommandLineToOptionsConfig" | qa::AreEqual "basic_qa" "Could not get long option"
  script::GetCommandConfig --unexistent_option "p1" | qa::AreEqual "unexistent" "Found unexistent option"
  script::GetCommandConfig --h | qa::AreEqual "wrong_option" "Found wrong option"
}

script_tests::CommandLineToOptionsConfig()
{
  script::CommandLineToOptionsConfig -rt | qa::AreEqual "basic_1_command_0_parameter" "Invalid config options"
  script::CommandLineToOptionsConfig -rt "p1" | qa::AreEqual "basic_1_command_1_parameter" "Invalid config options"
  script::CommandLineToOptionsConfig -rt "p1" "p2" "p3" | qa::AreEqual "basic_qa_multiple_parameters" "Invalid config options"
  script::CommandLineToOptionsConfig -ls -rt "p1" | qa::AreEqual "basic_multi_configurations_ls_rt" "Invalid config options"
  script::CommandLineToOptionsConfig -ls -ll 5 -lt "warning" -rt "p1" | qa::AreEqual "basic_multi_configurations_and_parameters_ls_ll_lt_rt" "Invalid config options"
  script::CommandLineToOptionsConfig -rt "script_tests::CommandLineToOptionsConfig" | qa::AreEqual "basic_rt_config" "Invalid config options"
}

script_tests::GetElementFromCommandLine()
{
  script::GetElementFromCommandLine "2" '"p1" "p2" "p3" "p4"' | qa::AreEqual "basic_p2" "Could not get the proper element"
  script::GetElementFromCommandLine "4" '"p1" "p2" "p3" "p4"' | qa::AreEqual "basic_p4" "Could not get the proper element"
  script::GetElementFromCommandLine "2" '"p1" "" "p3" "p4"' | qa::AreEqual "basic_empty" "Could not get the proper element"
  script::GetElementFromCommandLine "2" '"p1" "This is another item"  "p3" "p4"' | qa::AreEqual "basic_with_space" "Could not get the proper element"
  script::GetElementFromCommandLine "2" '"p1" ""s1" "s2"" "p3" "p4"' | qa::AreEqual "basic_substring" "Could not get the proper element"
  script::GetElementFromCommandLine "2" '"p1" "AAA "CCC"  BBB"  "p3" "p4"' | qa::AreEqual "inner_string_double_quotes" "Could not get the proper element"
  script::GetElementFromCommandLine "2" '"p1" "AAA \"CCC\"  BBB"  "p3" "p4"' | qa::AreEqual "inner_string_double_quotes_in_the_result" "Could not get the proper element"
  script::GetElementFromCommandLine "3" '"--log_show" "-ls" "log::ShowLog" "0" "--log_show (-ls)" "Enable Log and show it at the end of the execution" ""' | qa::AreEqual "log_command_get_function" "Could not get the proper element"
  script::GetElementFromCommandLine "7" '"--log_show" "-ls" "log::ShowLog" "0" "--log_show (-ls)" "Enable Log and show it at the end of the execution" ""' | qa::AreEqual "log_command_get_parameters" "Could not get the proper element"
  script::GetElementFromCommandLine "7" '"--run_test" "-rt" "qa::Run" "1" "--run_test (-rt) <test_name>" "Execute the test informed." ""script_tests::CommandLineToOptionsConfig""' | qa::AreEqual "rt_command_get_parameters" "Could not get the proper element"
}

script_tests::GetScriptDependencies1()
{
  script::GetScriptDependencies1 "script_tests" 
}

script_tests::BuildScriptFromConfig()
{
  local config="$(script::CommandLineToOptionsConfig -ls -le -rt "script_tests::CommandLineToOptionsConfig")"
  echo "$config" | script::BuildScriptFromConfig "/quality/.temp_script.sh"
}

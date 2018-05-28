
script_tests::GetDependencyFromConfig()
{
  script::GetDependencyFromConfig ../quality/script_tests-basic.dep | qa::AreEqual "basic_dependency_file" "Could not load a basic dependency file"
}


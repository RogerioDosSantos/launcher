
script_tests::GetDependencyFromConfig()
{
  script::GetDependencyFromConfig ../quality/script_tests-basic.dep

  # json::VarsToJson pr1 pr2 pr3 pr4 | qa::AreEqual "4_assignments" "Wrong assignment"
}


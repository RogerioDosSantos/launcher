
json_tests::VarsToJson()
{
  # echo "This is cool" | qa::AreEqual "basic_test" "Could not validate basic_test"

  local pr1="1"
  local pr2="2"
  local pr3="3"
  local pr4="4"
  json::VarsToJson pr1 pr2 pr3 pr4 | qa::AreEqual "4_assignments" "Wrong assignment"

  local weird_chars='This is an json with weird chars []{}+_""!@#$$%^^&*((?/))'
  json::VarsToJson weird_chars | qa::AreEqual "weird_chars" "Could not support weird charecters."
}

json_tests::IsValid()
{
  json::IsValid '{"n1":"v1", "n2":"v2"}' | qa::AreEqual "simple_validation" "Json was not validated properly"
  json::IsValid '{"n1:"v1", "n2":"v2"}' | qa::AreEqual "missing_quote" "Json was not validated properly"
  json::IsValid '{"n1":"v1" "n2":"v2"}' | qa::AreEqual "missing_comma" "Json was not validated properly"
}

json_tests::GetValue()
{
  json::GetValue '{"n1":"v1", "n2":"v2"}' 'n1' | qa::AreEqual "getiing_n1" "Could not get value"
  json::GetValue '{"n1":"v1", "n2":"v2"}' 'non-existent' | qa::AreEqual "getting_non_existent" "Could get an unexistent value"
}


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
  json::GetValue '{"n1":"v1", "n2":"v2"}' 'n1' | qa::AreEqual "geting_n1" "Could not get value"
  json::GetValue '{"n1":"v1", "n2":"v2"}' 'non-existent' | qa::AreEqual "geting_non_existent" "Could get an unexistent value"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' | qa::AreEqual "geting_array" "Could get array"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1[0]' | qa::AreEqual "geting_array_element_0" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1[1]' | qa::AreEqual "geting_array_element_1" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1[2]' | qa::AreEqual "geting_array_element_2" "Could get array element"
  json::GetValue '{"n1":"v1", "n2":"v2"}' 'n1' 'sh' | qa::AreEqual "basic_with_format" "Could not get value"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1[2]' 'sh' | qa::AreEqual "format_array_sh_element" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' 'sh' | qa::AreEqual "format_array_sh" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' 'text' | qa::AreEqual "format_array_text" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' 'json' | qa::AreEqual "format_array_json" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' 'csv' | qa::AreEqual "format_array_csv" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' 'tsv' | qa::AreEqual "format_array_tsv" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' 'base64' | qa::AreEqual "format_array_base64" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' 'uri' | qa::AreEqual "format_array_uri" "Could get array element"
  json::GetValue '{"a1":["v1", "v2", "v3"]}' 'a1' 'html' | qa::AreEqual "format_array_html" "Could get array element"
}

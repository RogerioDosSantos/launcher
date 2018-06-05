
builder_tests::CreateProjectMetadata()
{
  builder::CreateProjectMetadata "~/indusoft/projects/hardware_validator"
}

builder_tests::BuildCmake()
{
  builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt"
}

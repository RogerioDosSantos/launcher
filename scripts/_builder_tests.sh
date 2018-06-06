
builder_tests::CreateProjectMetadata()
{
  builder::CreateProjectMetadata "." | grep 'full_name' | qa::AreEqual "launcher_metadata" "Could not create the proper unique name"
  # builder::CreateProjectMetadata "~/indusoft/projects/hardware_validator"
  # builder::CreateProjectMetadata "~/indusoft/projects/historian"
  # builder::CreateProjectMetadata "~/indusoft/projects/zeromq"
  # builder::CreateProjectMetadata "~/indusoft/projects/serialization"
  # builder::CreateProjectMetadata "~/indusoft/projects/service"
  # builder::CreateProjectMetadata "~/indusoft/projects/third-party/curl"
}

builder_tests::BuildCmake()
{
  builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt"
}

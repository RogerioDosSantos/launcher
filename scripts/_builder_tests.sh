
builder_tests::CreateProjectMetadata()
{
  builder::CreateProjectMetadata "." "linux-x86" "release" | grep 'full_name' | qa::AreEqual "unique_name-linux-x86-release" "Could not get an unique name"  
  builder::CreateProjectMetadata "." "linux-x64" "release" | grep 'full_name' | qa::AreEqual "unique_name-linux-x64-release" "Could not get an unique name"
  builder::CreateProjectMetadata "." "windows-x86" "release" | grep 'full_name' | qa::AreEqual "unique_name-windows-x86-release" "Could not get an unique name"
  builder::CreateProjectMetadata "." "windows-x64" "release" | grep 'full_name' | qa::AreEqual "unique_name-windows-x64-release" "Could not get an unique name"
  builder::CreateProjectMetadata "." "linux-armv7" "release" | grep 'full_name' | qa::AreEqual "unique_name-linux-armv7-release" "Could not get an unique name"
  builder::CreateProjectMetadata "." "linux-x86" "debug" | grep 'full_name' | qa::AreEqual "unique_name-linux-x86-debug" "Could not get an unique name"
  builder::CreateProjectMetadata "." "linux-x64" "debug" | grep 'full_name' | qa::AreEqual "unique_name-linux-x64-debug" "Could not get an unique name"
  builder::CreateProjectMetadata "." "windows-x86" "debug" | grep 'full_name' | qa::AreEqual "unique_name-windows-x86-debug" "Could not get an unique name"
  builder::CreateProjectMetadata "." "windows-x64" "debug" | grep 'full_name' | qa::AreEqual "unique_name-windows-x64-debug" "Could not get an unique name"
  builder::CreateProjectMetadata "." "linux-armv7" "debug" | grep 'full_name' | qa::AreEqual "unique_name-linux-armv7-debug" "Could not get an unique name"

  # builder::CreateProjectMetadata "~/indusoft/projects/hardware_validator" "linux-x86" "debug"
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

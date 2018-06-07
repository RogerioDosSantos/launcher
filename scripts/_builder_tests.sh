
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
}

builder_tests::BuildCmake()
{
  # TODO(Roger) - Finish unit test
  # builder::BuildCmake "~/indusoft/projects/boost/CMakeLists.txt" "linux-x86" "debug"
  # builder::BuildCmake "~/indusoft/projects/boost/CMakeLists.txt" "linux-x86" "release"
  builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-x86" "release"
  # builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-armv7" "all"
  # builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-x86" "all"
}

builder_tests::IsImageAvailable()
{
  local password=$(cat /quality/.temp_docker_registry_password)
  builder::IsImageAvailable "builder-linux-armv5" "latest" "devindusoft.azurecr.io" "devindusoft" "${password}" | qa::AreEqual "existing_image" "Did not find an existing image (With: Server, User, Password)" 
  builder::IsImageAvailable "alpine" "latest" | qa::AreEqual "existing_image" "Did not find an existing image (Without: Server)" 
  builder::IsImageAvailable "builder-linux-armv5" "latest" "devindusoft.azurecr.io" | qa::AreEqual "existing_image" "Did not find an existing image (With: Server)"
  builder::IsImageAvailable "unexistent-image" "unexistent-version" | qa::AreEqual "unexisting_image" "Found unexistent image"
}

builder_tests::Deploy()
{
  local password=$(cat /quality/.temp_docker_registry_password)
  # builder::IsImageAvailable "builder-linux-armv5" "latest" "devindusoft.azurecr.io" "devindusoft" "<password>" 
  # builder::Deploy "~/indusoft/projects/stage/linux-x86/release/hardware_validator/build.json" "devindusoft.azurecr.io" "devindusoft" "<password>"
}

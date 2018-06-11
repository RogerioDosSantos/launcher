
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
  # builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-x86" "release"
  # builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-x86" "release"
  # builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-armv7" "release"
  # builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-armv7" "all"
  # builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-x86" "all"
 	# builder::BuildCmake "~/indusoft/projects/openssl/CMakeLists.txt" "linux-armv7" "release"
 	# builder::BuildCmake "~/indusoft/projects/restclient-cpp/CMakeLists.txt" "linux-armv7" "release"

 	builder::BuildCmake "~/indusoft/projects/boost/CMakeLists.txt" "linux-x86" "release"
 	builder::BuildCmake "~/indusoft/projects/environment/CMakeLists.txt" "linux-x86" "release"
 	builder::BuildCmake "~/indusoft/projects/quality/CMakeLists.txt" "linux-x86" "release"
 	builder::BuildCmake "~/indusoft/projects/zeromq/CMakeLists.txt" "linux-x86" "release"
 	builder::BuildCmake "~/indusoft/projects/openssl/CMakeLists.txt" "linux-x86" "release"
 	builder::BuildCmake "~/indusoft/projects/restclient-cpp/CMakeLists.txt" "linux-x86" "release"
 	builder::BuildCmake "~/indusoft/projects/project_template_cpp/CMakeLists.txt" "linux-x86" "release"
 	builder::BuildCmake "~/indusoft/projects/hardware_validator/CMakeLists.txt" "linux-x86" "release"

 	# *builder::BuildCmake "~/indusoft/projects/serialization/CMakeLists.txt" "linux-x86" "release"
 	# *builder::BuildCmake "~/indusoft/projects/service/CMakeLists.txt" "linux-x86" "release"

 	builder::BuildCmake "~/indusoft/projects/historian/CMakeLists.txt" "linux-x86" "release"

 	# *builder::BuildCmake "~/indusoft/projects/remote_management/CMakeLists.txt" "linux-x86" "release"
}

builder_tests::GetFullImageName()
{
  builder::GetFullImageName 'image_name' 'image_version' 'server' | qa::AreEqual "basic_with_server" "Wrong image name"
  builder::GetFullImageName 'image_name' 'image_version' '' | qa::AreEqual "basic_without_server" "Wrong image name"
  builder::GetFullImageName 'image_name' 'image_version' | qa::AreEqual "basic_without_server" "Wrong image name"
  builder::GetFullImageName "builder-linux-armv5" "latest" "devindusoft.azurecr.io" | qa::AreEqual "armv5_latest" "Wrong image name"
}

builder_tests::IsImageAvailable()
{
  local password=$(cat /quality/.temp_docker_registry_password)
  builder::IsImageAvailable "builder-linux-armv5" "latest" "devindusoft.azurecr.io" "devindusoft" "${password}" | qa::AreEqual "existing_image" "Did not find an existing image (With: Server, User, Password)"
  builder::IsImageAvailable "alpine" "latest" | qa::AreEqual "existing_image" "Did not find an existing image (Without: Server)"
  builder::IsImageAvailable "builder-linux-armv5" "latest" "devindusoft.azurecr.io" | qa::AreEqual "existing_image" "Did not find an existing image (With: Server)"
  builder::IsImageAvailable "unexistent-image" "unexistent-version" | qa::AreEqual "unexisting_image" "Found unexistent image"
}

builder_tests::GetDataImageInfo()
{
  builder::GetDataImageInfo "devindusoft.azurecr.io/indusoft-projects-hardware_validator-linux-x86-release:master-d4d88a6-master-ac140ae"

}

builder_tests::CreateImage()
{
  builder::CreateImage "~/indusoft/projects/stage/linux-x86/release/hardware_validator/build.json" "devindusoft.azurecr.io"
}

builder_tests::Deploy()
{
  local password=$(cat /quality/.temp_docker_registry_password)
  builder::Deploy "~/indusoft/projects/stage/linux-x86/release/hardware_validator/build.json" "devindusoft.azurecr.io" "devindusoft" "${password}"
}


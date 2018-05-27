
runner::RunDocker()
{
  # Usage: RunDocker <in:image_name> <in:session> <in::commands>...

  local docker_image=$1
  shift 1
  local session=$1
  shift 1

  local container_name="${docker_image/\//-}-${session}"
  cd ${g_caller_dir}
  local work_dir="$(pwd -P)"
  work_dir=$(docker::NormalizeDir "${work_dir}")

  local shell_command="docker run -it --rm --name ${container_name} -v "${work_dir}":/work ${docker_image} $@"
  log::Log "info" "5" "Docker Command" "${shell_command}"
  # eval ${shell_command}
  bash -c "${shell_command}"
}

runner::Runner()
{
  # Usage Runner <parameters>...

  runner::RunDocker "rogersantos/launcher" "launcher_${RANDOM}" "$@"

}



docker::BuildImage()
{
  # Usage <image_name> <docker_file_dir>
  local in_image_name=$1
  local in_docker_file_dir=$2

  docker build -t "${in_image_name}" "${in_docker_file_dir}"
}

docker::IsVirtualBox()
{
  # Usage: IsVirtualBox

  local is_virtualbox_provider="$(docker info | grep provider=virtualbox)"
  if [ "${is_virtualbox_provider}" = "provider=virtualbox" ]; then
    echo "true"
    return 0
  fi

  echo "false"
}

docker::NormalizeDir()
{
  # Usage: NormalizeDir <in:directory> 
  local directory=$1

  #TODO(Roger) - Put platform and if docker is running on Ubuntu as parameter to make thin function testable
  local is_ubuntu_on_windows=$([ -e /proc/version ] && grep -l Microsoft /proc/version || echo "")
  local is_cygwin=$([ -e /proc/version ] && grep -l MINGW /proc/version || echo "")
  if [ -n "${is_ubuntu_on_windows}" ]; then
    log::Log "info" "5" "Script is being called from Ubuntu on Windows" ""
    if "$(docker::IsVirtualBox)" == "true"; then
      log::Log "info" "5" "Docker Server is running on VirtualBox" ""
      directory=${directory/\/mnt\//}
      directory="/${directory}"
      echo "${directory}"
      return 0
    fi

    log::Log "info" "5" "Docker Server is running natively" ""
    directory=${directory/\/mnt\//}
    directory=${directory/\//:\/}
    echo "${directory}"
    return 0
  fi

  if [ -n "${is_cygwin}" ]; then
      log::Log "info" "5" "Docker Server is running on VirtualBox" ""
      directory=${directory/\//}
      directory=${directory/\//:\/}
      echo "${directory}"
      return 0
  fi

  echo "${directory}"
}



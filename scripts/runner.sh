#!/bin/bash

Init()
{
  g_script_name="$(basename "$0")"
  g_caller_dir=$(pwd)
  cd "$(dirname "$0")"
  g_script_dir=$(pwd)

  local dependeny_path="./${g_script_name/.sh/.dep}"
  if [ -f "${dependeny_path}" ]; then
    source "${dependeny_path}"
  fi

  log::Init
}

End()
{
  log::Log "info" "5" "Returning to caller directory" "${g_caller_dir}"
  log::End
  cd "${g_caller_dir}"
}

set -E
trap 'log::ErrorHandler $LINENO' ERR

Init
runner::Runner "debug" "rogersantos/launcher" "${g_caller_dir}"  "$@"
# runner::Runner "release" "rogersantos/launcher" "${g_caller_di}" "$@"
End


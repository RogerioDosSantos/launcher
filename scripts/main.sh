#!/bin/bash

g_script_name="$(basename "$0")"
g_caller_dir=$(pwd)
cd "$(dirname "$0")"
g_script_dir=$(pwd)

source "./_main.sh"
source "./_helper.sh"
source "./_log.sh"
source "./_script.sh"
source "./_doc.sh"

set -E
trap 'log::ErrorHandler $LINENO' ERR

main::Main "$@"


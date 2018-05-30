#!/bin/bash

#Go to the current file folder
cd "$(dirname "$0")"
current_dir=$(pwd -P)

cd ..
workspace_dir=$(pwd -P)

docker exec -it launcher_debug ../scripts/main.sh "$@"


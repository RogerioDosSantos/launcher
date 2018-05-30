#!/bin/bash

#Go to the current file folder
cd "$(dirname "$0")"
current_dir=$(pwd -P)

cd ..
workspace_dir=$(pwd -P)

docker rm -f launcher_debug

source ./scripts/_docker.sh
source ./scripts/_log.sh

work_dir=$(docker::NormalizeDir "${workspace_dir}/debug/work")
session_dir=$(docker::NormalizeDir "${workspace_dir}/debug/session")
scripts_dir=$(docker::NormalizeDir "${workspace_dir}/scripts")
docs_dir=$(docker::NormalizeDir "${workspace_dir}/doc")

docker run -d -it --rm --name "launcher_debug" \
  -v "${work_dir}":/work \
  -v "${session_dir}":/session \
  -v "${scripts_dir}":/scripts \
  -v "${docs_dir}":/doc \
  rogersantos/launcher_base /bin/bash



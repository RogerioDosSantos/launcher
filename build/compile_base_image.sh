#!/bin/bash

#Go to the current file folder
cd "$(dirname "$0")"

echo "* $(basename "$0")"
echo " - Building base image"

proxy="$(printenv http_proxy)"

if [ "${proxy}" == "" ]; then
  docker build -f ./base_image.docker -t "rogersantos/launcher_base" .
else
  docker build -f ./base_image.docker --build-arg http_proxy="${proxy}" -t "rogersantos/launcher_base" .
fi




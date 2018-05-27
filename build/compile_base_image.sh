#!/bin/bash

#Go to the current file folder
cd "$(dirname "$0")"

echo "* $(basename "$0")"
echo " - Building base image"
docker build -f ./base_image.docker -t "rogersantos/launcher_base" .


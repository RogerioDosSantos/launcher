#!/bin/bash

#Go to the current file folder
cd "$(dirname "$0")"

echo "* $(basename "$0")"
echo " - Building image"
docker build -f ./project_image.docker -t "rogersantos/launcher" ..


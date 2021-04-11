#!/usr/bin/env bash
set -e 

echo "Cleaning the folder ..."
git clean -d -f -f -x .

echo "Downloading all folders ..."
cd scripts && bash bootstrap.sh && cd ..

echo "Building the Bluespec docker image ..."
docker build -t localhost/bsc-compiler --build-arg BJOBS=4 --build-arg USER=$USER \
    --build-arg UID=`id -u` --build-arg `id -g` .

echo "Done!"

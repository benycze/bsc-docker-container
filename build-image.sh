#!/usr/bin/env bash
set -e 

echo "Cleaning the folder ..."
git clean -d -f -f -x .

echo "Downloading all folders ..."
bash bootstrap.sh

echo "Building the Bluespec docker image ..."
docker build -t localhost/bsc-compiler --build-arg BJOBS=4 .

echo "Done!"

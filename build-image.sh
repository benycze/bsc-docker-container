#!/usr/bin/env bash
set -e 

# Check if docker/podman is available
CONTAINER_TOOL=""
if command -v docker > /dev/null; then
    CONTAINER_TOOL="docker"
elif command -v podman > /dev/null; then
    CONTAINER_TOOL="podman"
else
    echo "No container tool (podman, docker has been found)!"
    exit 1
fi

echo "${CONTAINER_TOOL} tool has been found ..."

# Clean the directory and buld the image
echo "Cleaning the folder ..."
git clean -d -f -f -x .

DOC_BUILD=${DOC:-0}
echo "Documentation build is: "
if [ $DOC_BUILD -eq 1 ]; then
    echo "  * Yes"
else
    echo "  * No"
fi

echo "Downloading all folders ..."
cd scripts && bash bootstrap.sh && cd ..

echo "Building the Bluespec docker image ..."
$CONTAINER_TOOL build --rm -t localhost/bsc-compiler --build-arg BJOBS=4 --build-arg USER=$USER \
    --build-arg UID=`id -u` --build-arg `id -g` --build-arg DOC=${DOC_BUILD} .

echo "Done!"

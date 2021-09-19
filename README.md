# Bluespec Compiler Docker

[![Build Status](https://benycze.semaphoreci.com/badges/bsc-docker-container/branches/master.svg?style=shields)](https://benycze.semaphoreci.com/projects/bsc-docker-container)

This repository contains a prepared build script of Bluespec compiler for the Docker tool. This is useful if you don't want to deal with dependencies in your favourite Linux distribution (or in Windows).

The only thing you need is to install the [Docker](https://www.docker.com/) or [Podman](https://podman.io/) (use the Podman tool because it is much better ;)).

The image  contains elementary development tools, [Bluespec compiler](https://github.com/B-Lang-org/bsc), [Bluespec contribution library](https://github.com/B-Lang-org/bsc-contrib) and [BSC Development Workstation](https://github.com/B-Lang-org/bdw).

## How to download and build the image

Clone the repository using this command (gets all dependencies):

```bash
git clone https://github.com/benycze/bsc-docker-container
cd scripts 
bootstrap.sh
```

If you need a specific version or update to fresh master you can do it on your own. Update everything to fresh master branches (in the case that you used the `boostrap.sh` file earlier):		
```bash
for i in bsc bsc-contrib doc; do (cd $i; git pull); done
```

Possibly, you can enter each module and select the right branch/version using the normal git tool. For example, if you need to switch the `bsc` submodule to devel branch just write:

```bash
cd bsc
git fetch origin
git checkout devel
```

## How to build the image

The image is then built quite easily (the following example is for docker but you can use the same command using the [podman](https://podman.io/) tool):

```bash
docker build --rm -t localhost/bsc-compiler --build-arg BJOBS=4 --build-arg USER=$USER --build-arg UID=`id -u` --build-arg `id -g` --build-arg DOC=1 .
```

This command builds the image named localhost/bsc-compiler and it also uses 4 jobs to build the tool. You can also adjust the BJOBS if you need to use less or more CPU cores to build the image. Image for docker is built using the `build-image.sh` (you can also run `env DOC=1 ./build-image.sh` if you want to enforce documentation build).
Variables UID, USER and GID are used for the creation of local account with admin rights via the `sudo` tool. THe DOC parameters is used for the documentation build - disabled by default because you can build it directly outside the docker image. However, it is possible to turn it on and copy files outside of running docker image (folder /doc) to host.

## How to run the image (just a console)

The following command can be used to runt the image and mount the local working directory.

```bash
docker run --rm -t -i --mount=type=bind,source=/home/user/bsc-work,destination=/bsc-work localhost/bsc-compiler bash
```

This command will do the following:

* Starts the container from the localhost/bsc-compiler image
* Mounts the local /home/user/bsc-work directory into /bsc-work directory inside the image
* Starts the container and attach the console

In a case that you want to run the image using a normal account:

```bash
docker run --user=$USER --rm -t -i --mount=type=bind,source=/home/user/bsc-work,destination=/bsc-work localhost/bsc-compiler bash
```

## How to run the X11 App - BDW tool

The image also contains the Bluespec Development Workstation together with possibility to run X11 apps
on your X window system. Basically you need export your local XAuthority variable and X11 socket from
your system into the container (detailed explemention [here](https://blog.artis3nal.com/2020-09-13-container-gui-app-pgmodeler/)).

Check your environment for these variables:
* XAUTHORITY (if not defined run the `export XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }')` command)
* DISPLAY (this should be defined :-))

After that, run the following command with docker:

 ```bash
docker run --rm -t -i -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix:ro -v $XAUTHORITY:$XAUTHORITY:ro --user=$USER --mount=type=bind,source=/home/user/bsc-work,destination=/bsc-work localhost/bsc-compiler /bin/bash
 ```

You should be fine to run the graphic app from the container image (you can check it using the `gvim`).
The example of image start script is inside the `run-example` folder.


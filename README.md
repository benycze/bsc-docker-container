# Bluespec Compiler Docker

This repository contains a prepared build script of Bluespec compiler for the Docker tool. This is useful if you don't want to deal with dependencies in your favourite Linux distribution (or in Windows).

The only thing you need is to install the [Docker](https://www.docker.com/) or [Podman](https://podman.io/) (use the Podman tool because it is much better ;)).

The image  contains elementary development tools, [Bluespec compiler](https://github.com/B-Lang-org/bsc), [Bluespec documentation and examples](https://github.com/BSVLang/Main.git) and [Bluespec contribution library](https://github.com/B-Lang-org/bsc-contrib).

## How to download and build the image

Clone the repository using this command (gets all dependencies):

```bash
git clone --recursive https://github.com/benycze/bsc-docker-container
```

I am trying to update and test everything as frequently as possible but if you need a specific version or update to fresh master you can do it on your own.

Update everything to fresh master branches

```bash
git submodule update --recursive --remote
```

Possibly, you can enter each submodule and select the right branch/version using the normal git tool. For example, if you need to switch the `bsc` submodule to devel branch just write:

```bash
cd bsc
git fetch origin
git checkout devel
```

## How to build the image

The image is then built quite easily (the following example is for docker but you can use the same command using the podman):

```bash
docker build -t localhost/bsc-compiler --build-arg BJOBS=4 .
```

This command builds the image named localhost/bsc-compiler and it also uses 4 jobs to build the tool. You can also adjust the BJOBS if you need to use less or more CPU cores to build the image.

## How to run the image

The following command can be used to runt the image and mount the local working directory.

```bash
TODO
```
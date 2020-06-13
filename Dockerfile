# Copyright 2019 by the bsc docker image contributors
# SPDX-License-Identifier: GPL-3.0-only
#
# Author(s): Pavel Benacek <pavel.benacek@gmail.com>

FROM ubuntu:18.04

ARG BJOBS=1
COPY bsc /bluespec/bsc
COPY build-new-package.sh /bluespec
COPY bsc-contrib /bluespec/bsc-contrib
COPY doc /bluespec/doc

RUN apt update && apt upgrade -y && DEBIAN_FRONTEND=noninteractive apt install -y tzdata sudo vim software-properties-common 
RUN add-apt-repository universe && apt update && apt upgrade -y
RUN cd /bluespec && bash ./build-new-package.sh 1.0.0 1.0.0 $BJOBS

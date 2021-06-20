# Copyright 2019 by the bsc docker image contributors
# SPDX-License-Identifier: GPL-3.0-only
#
# Author(s): Pavel Benacek <pavel.benacek@gmail.com>

FROM ubuntu:20.04

# Defeault argument values
ARG BJOBS=1
ARG USER=user
ARG UID=1000
ARG GID=1000
ARG PASS=password

# Copy downloaded repos
COPY scripts/reps /bluespec/
COPY scripts/build-new-package.sh /bluespec

# Install tooling a
RUN apt update && apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y tzdata sudo vim software-properties-common \
                                                sudo xauth vim-gtk graphviz
RUN add-apt-repository universe && apt update && apt upgrade -y

# Add user into the system
RUN groupadd --gid $GID $USER && \
    useradd --uid $UID --gid $GID --groups sudo --shell /bin/bash -m $USER && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admins && \
    echo "$USER:$PASS" | chpasswd

# Build Bluespec tools
RUN cd /bluespec && bash ./build-new-package.sh 1.0.0 1.0.0 1.0.0 $BJOBS

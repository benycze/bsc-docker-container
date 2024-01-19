# Copyright 2019 by the bsc docker image contributors
# SPDX-License-Identifier: GPL-3.0-only
#
# Author(s): Pavel Benacek <pavel.benacek@gmail.com>

FROM ubuntu:22.04

# Defeault argument values
ARG BJOBS=1
ARG USER=user
ARG UID=1000
ARG GID=1000
ARG PASS=password
ARG DOC=0
ARG GHC_VERSION="9.4.8"
ARG CABAL_VERSION="latest"

# Copy downloaded repos into image
COPY scripts/reps/bsc /bluespec/reps/bsc
COPY scripts/reps/bsc-contrib /bluespec/reps/bsc-contrib
COPY scripts/reps/bdw /bluespec/reps/bdw
COPY scripts/build-new-package.sh /bluespec

# Install tooling and editors
RUN apt update && apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y tzdata sudo vim software-properties-common \
                                                sudo xauth vim-gtk graphviz curl \
						build-essential libffi-dev libffi8ubuntu1 libgmp-dev \
						libgmp10 libncurses-dev libncurses5 libtinfo5
RUN add-apt-repository universe && apt update && apt upgrade -y

# Install GHC and its deps
RUN curl https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > /usr/local/bin/ghcup && \
    chmod +x /usr/local/bin/ghcup
RUN ghcup -v install ghc --isolate /usr/local --force $GHC_VERSION && \
    ghcup -v install cabal --isolate /usr/local/bin --force $CABAL_VERSION
RUN cabal update && cabal v1-install old-time regex-compat split syb

# Add user into the system
RUN groupadd --gid $GID $USER && \
    useradd --uid $UID --gid $GID --groups sudo --shell /bin/bash -m $USER && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admins && \
    echo "$USER:$PASS" | chpasswd

# Build Bluespec tools
RUN cd /bluespec && bash ./build-new-package.sh 1.0.0 1.0.0 1.0.0 $BJOBS $DOC

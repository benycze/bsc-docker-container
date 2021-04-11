#!/usr/bin/env bash

# Copyright 2020 by the bsc docker image contributors
# SPDX-License-Identifier: GPL-3.0-only
#
# Author(s): Pavel Benacek <pavel.benacek@gmail.com>

DOWNLOAD_PATH=`pwd`/reps

echo "Preparing all directories ..."

mkdir -p $DOWNLOAD_PATH && cd $DOWNLOAD_PATH

git clone --recursive https://github.com/B-Lang-org/bsc.git bsc
git clone --recursive https://github.com/B-Lang-org/bsc-contrib bsc-contrib
git clone --recursive https://github.com/BSVLang/Main.git doc
git clone --recursive https://github.com/B-Lang-org/bdw

echo "Reps downloaded"

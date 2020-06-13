#!/usr/bin/env bash

# Copyright 2020 by the bsc docker image contributors
# SPDX-License-Identifier: GPL-3.0-only
#
# Author(s): Pavel Benacek <pavel.benacek@gmail.com>


echo "Preparing all directories ..."

git clone --recursive https://github.com/B-Lang-org/bsc.git bsc
git clone --recursive https://github.com/B-Lang-org/bsc-contrib bsc-contrib
git clone --recursive https://github.com/BSVLang/Main.git doc

echo "Done!"

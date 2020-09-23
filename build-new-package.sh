#!/usr/bin/env bash

# Copyright 2019 by the bsc docker image contributors
# SPDX-License-Identifier: GPL-3.0-only
#
# Author(s): Pavel Benacek <pavel.benacek@gmail.com>

set -e

if [ $# -ne 3 ]; then
    echo "Insert the version of packages (bsc and then the version of the contrib) and number of jobs. For example (version 0.1.1 0.2.2 4)"
    echo "$0 0.1.1 4 0.2.2"
    exit 1
fi

BUILD_PACKAGES="build-essential autotools-dev autoconf git libfontconfig1-dev libx11-dev libxft-dev gperf flex bison ccache"
DEPS_PACKAGES="iverilog ghc libghc-regex-compat-dev libghc-syb-dev libghc-old-time-dev libghc-split-dev libelf-dev gcc-5 g++-5 tcl-dev itcl3-dev gcc-8 g++-8 tcl-dev tk-dev itk3-dev xvfb verilator"

echo "Checkinstall is required ..."
sudo apt install -y checkinstall

echo "Installing packages ..."
sudo apt-get  install -y $BUILD_PACKAGES $DEPS_PACKAGES

echo "Installing alternatives for older gcc ..."
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 30
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 40
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 50
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 30
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 40
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 50

# Export jobs
export JOBS=$3

# Preparing requirements for the checkinstall
export BSC_REQS=`echo $DEPS_PACKAGES | sed 's/\ /\,/g'`
export BSC_VERSION=$1


echo "Building package:"
echo "  - version: $BSC_VERSION"
echo "  - reqs: $BSC_REQS"

BSC_FOLDER="bsc_$1"
mkdir -p buildroot/$BSC_FOLDER
(cd bsc; make -j $JOBS GHCJOBS=$JOBS  PREFIX=/bluespec/buildroot/$BSC_FOLDER all)

echo "Preparing the bsc package metadata ..."
mkdir -p buildroot/$BSC_FOLDER/DEBIAN
cat << -EOF > buildroot/$BSC_FOLDER/DEBIAN/control
Package: bsc
Version: $BSC_VERSION
Section: base
Priority: optional
Architecture: $(dpkg --print-architecture)
Depends: $BSC_REQS
Maintainer: Pavel Benacek <pavel.benacek@gmail.com>
Description: Bluespec System Verilog Compiler
 Compiler from the Bluespec System Verilog which is used for the advanced and fast
 prototyping of digital designs. More information available from https://github.com/B-Lang-org/bsc
-EOF

(cd buildroot; dpkg-deb --build bsc_$BSC_VERSION; dpkg -i bsc_*.deb)

# Preparing data for the BSCC
export BSCC_VERSION=$2
export BSCC_DEPS="bsc"

echo "Building contrib package:"
echo "  - version: $BSCC_VERSION"
echo "  - reqs: $BSCC_DEPS"

BSC_CONTRIB_FOLDER="bsc-contrib_$2"
mkdir -p buildroot/$BSC_CONTRIB_FOLDER
(cd bsc-contrib; make -j $JOBS PREFIX=/bluespec/buildroot/$BSC_CONTRIB_FOLDER)


echo "Preparing the bsc-contrib package metadata ..."
mkdir -p buildroot/$BSC_CONTRIB_FOLDER/DEBIAN
cat << -EOF > buildroot/$BSC_CONTRIB_FOLDER/DEBIAN/control
Package: bsc-contrib
Version: $BSCC_VERSION
Section: base
Priority: optional
Architecture: $(dpkg --print-architecture)
Depends: $BSCC_DEPS
Maintainer: Pavel Benacek <pavel.benacek@gmail.com>
Description: Bluespec System Verilog Contributions
 Additional libs for Bluespec. Available from https://github.com/B-Lang-org/bsc-contrib.
-EOF

(cd buildroot; dpkg-deb --build bsc-contrib_$BSCC_VERSION; dpkg -i bsc-contrib*.deb)

echo "Removing build directory ..."
rm -rf buildroot

echo "Done!"

exit 0

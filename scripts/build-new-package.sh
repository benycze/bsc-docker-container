#!/usr/bin/env bash

# Copyright 2019 by the bsc docker image contributors
# SPDX-License-Identifier: GPL-3.0-only
#
# Author(s): Pavel Benacek <pavel.benacek@gmail.com>

set -e

# Helping function which converts the APT line to DEB package
# requirements string
function escape_to_reqs () {
    local ret=`echo $* | sed 's/\ /\,/g'`
    echo $ret
}


echo '# ###############################################################################'
echo '# # Deps install'
echo '# ###############################################################################'

if [ $# -ne 4 ]; then
    echo "Insert the version of packages (bsc and then the version of the contrib) and number of jobs. For example (version 0.1.1 0.2.2 4 0.5.6)"
    echo "$0 0.1.1 4 0.2.2 0.1.2 4"
    exit 1
fi

BUILD_PACKAGES="build-essential autotools-dev autoconf git libfontconfig1-dev libx11-dev libxft-dev gperf flex bison ccache"
BSC_DEPS_PACKAGES="iverilog ghc libghc-regex-compat-dev libghc-syb-dev libghc-old-time-dev libghc-split-dev libelf-dev gcc-8 g++-8 gcc-9 g++-9 gcc-10 g++-10 tcl-dev itcl3-dev tcl-dev tk-dev itk3-dev xvfb verilator"
BDW_DEPS_PACKAGES="gtkwave graphviz emacs vim-gtk"

echo "Checkinstall is required ..."
sudo apt install -y checkinstall

echo "Installing packages ..."
sudo apt-get  install -y $BUILD_PACKAGES $BSC_DEPS_PACKAGES $BDW_DEPS_PACKAGES

echo "Installing alternatives for older gcc ..."
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 50
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 70
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 50
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 60
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 70

# Export the number of build jobs
export JOBS=$4

# Common build root directory
pwd
ls
REPS_ROOT=`pwd`/reps
BUILD_ROOT=`pwd`/buildroot

echo '# ###############################################################################'
echo '# # Prepare the BSC '
echo '# ###############################################################################'

# Preparing requirements for the checkinstall
export BSC_REQS="$(escape_to_reqs $BSC_DEPS_PACKAGES)"
export BSC_VERSION=$1

echo "Building package:"
echo "  - version: $BSC_VERSION"
echo "  - reqs: $BSC_REQS"

BSC_FOLDER="bsc_$1"
BSC_BUILD_ROOT=$BUILD_ROOT/$BSC_FOLDER
mkdir -p $BSC_BUILD_ROOT
(cd $REPS_ROOT/bsc; make -j $JOBS GHCJOBS=$JOBS  PREFIX=$BSC_BUILD_ROOT all)

echo "Preparing the bsc package metadata ..."
mkdir -p $BSC_BUILD_ROOT/DEBIAN
cat << -EOF > $BSC_BUILD_ROOT/DEBIAN/control
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

(cd $BUILD_ROOT; dpkg-deb --build $BSC_FOLDER; dpkg -i bsc_*.deb)

echo '# ###############################################################################'
echo '# # Prepare the BSC Library'
echo '# ###############################################################################'

# Preparing data for the BSCC
export BSCC_VERSION=$2
export BSCC_DEPS="bsc"

echo "Building contrib package:"
echo "  - version: $BSCC_VERSION"
echo "  - reqs: $BSCC_DEPS"

BSC_CONTRIB_FOLDER="bsc-contrib_$BSCC_VERSION"
BSC_CONTRIB_BUILD_ROOT=$BUILD_ROOT/$BSC_CONTRIB_FOLDER
mkdir -p $BSC_CONTRIB_BUILD_ROOT
(cd $REPS_ROOT/bsc-contrib; make -j $JOBS PREFIX=$BSC_CONTRIB_BUILD_ROOT)

echo "Preparing the bsc-contrib package metadata ..."
mkdir -p $BSC_CONTRIB_BUILD_ROOT/DEBIAN
cat << -EOF > $BSC_CONTRIB_BUILD_ROOT/DEBIAN/control
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

(cd $BUILD_ROOT; dpkg-deb --build $BSC_CONTRIB_FOLDER; dpkg -i bsc-contrib*.deb)

echo '###############################################################################'
echo '# Prepare the BDW'
echo '###############################################################################'

# Preparing data for the BDW
export BDW_VERSION=$3
export BDW_DEPS="bsc,$(escape_to_reqs $BDW_DEPS_PACKAGES)"

echo "Building the bdw package:"
echo "  - version: $BDW_DEPS"
echo "  - reqs: $BDW_VERSION"

BDW_FOLDER="bdw_${BDW_VERSION}"
BDW_FOLDER_BUILD_ROOT=$BUILD_ROOT/$BDW_FOLDER
mkdir -p $BDW_FOLDER_BUILD_ROOT
(cd $REPS_ROOT/bdw; make PREFIX=$BDW_FOLDER_BUILD_ROOT)

echo "Preparing the bdw package metadata ..."
mkdir -p $BDW_FOLDER_BUILD_ROOT/DEBIAN
cat << -EOF > $BDW_FOLDER_BUILD_ROOT/DEBIAN/control
Package: bdw
Version: $BDW_VERSION
Section: base
Priority: optional
Architecture: $(dpkg --print-architecture)
Depends: $BDW_DEPS
Maintainer: Pavel Benacek <pavel.benacek@gmail.com>
Description: BSC Development Workstation tool.
    Available from https://github.com/B-Lang-org/bdw.
-EOF

(cd $BUILD_ROOT; dpkg-deb --build $BDW_FOLDER; dpkg -i bdw*.deb)

echo '###############################################################################'
echo '# Cleanup'
echo '###############################################################################'

echo "Removing build directory ..."
rm -rf $BUILD_ROOT

echo '###############################################################################'
echo '# Done!'
echo '###############################################################################'

exit 0

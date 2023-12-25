#!/bin/bash

# helper script
# downloads and installs custom gcc startup for brownelf / aout compilers

# Copyright 2007-2022 Pawel Goralski
#    
# This file is part of AMIDILIB.
# See license.txt for licensing information.
#

BUILD_ROOT=.
CURDIR=$(dirname "$0")

if [ -d "${BUILD_ROOT}/deps/atari-gcc-startup" ]; then
echo Deleting gcc startup folder
rm -rf ${BUILD_ROOT}/deps/atari-gcc-startup
fi

mkdir ./deps/atari-gcc-startup

if [ "${BUILD_ROOT}/atari-gcc-startup_latest.tgz" ]; then
echo Deleting old gcc startup archive
rm ${BUILD_ROOT}/atari-gcc-c-startup_latest.tgz
fi

if [ "${BUILD_ROOT}/atari-gcc-startup-brownelf_latest.tgz" ]; then
echo Deleting old brownelf gcc startup archive
rm ${BUILD_ROOT}/atari-gcc-brownelf-c-startup_latest.tgz
fi

echo Updating dependencies
wget -q https://bitbucket.org/nokturnal/atari-gcc-startup/downloads/atari-gcc-c-startup_latest.tgz -P ${BUILD_ROOT}/
wget -q https://bitbucket.org/nokturnal/atari-gcc-startup/downloads/atari-gcc-brownelf-c-startup_latest.tgz -P ${BUILD_ROOT}/

echo Unpacking minimal gcc startup
tar -zxvf ${BUILD_ROOT}/atari-gcc-c-startup_latest.tgz -C ${BUILD_ROOT}/deps/atari-gcc-startup --strip-components=2
tar -zxvf ${BUILD_ROOT}/atari-gcc-brownelf-c-startup_latest.tgz -C ${BUILD_ROOT}/deps/atari-gcc-startup --strip-components=2

echo Done!


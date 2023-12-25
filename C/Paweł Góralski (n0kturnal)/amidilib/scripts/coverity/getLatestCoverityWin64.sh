#!/bin/bash

# helper script
# downloads Coverity Scan suite Win64

# Copyright 2007-2022 Pawel Goralski
#    
# This file is part of AMIDILIB.
# See license.txt for licensing information.
#

BUILD_ROOT=.
COVERITY_VERSION=2022.6
COVERITY_MINOR_VERSION=0

if ! [ -f "${BUILD_ROOT}/scripts/coverity/cov-analysis-win64-${COVERITY_VERSION}.zip" ]; then
	echo "Getting coverity scan suite ..."
	wget -nc https://nokturnal.pl/downloads/atari/toolchains/cov-analysis-win64-${COVERITY_VERSION}.zip -P ${BUILD_ROOT}/scripts/coverity/
else
	echo "Coverity already downloaded!"
fi

if [ -f "${BUILD_ROOT}/scripts/coverity/cov-analysis-win64-${COVERITY_VERSION}.zip" ]; then
	echo Unpacking ...
	unzip -qq -o ${BUILD_ROOT}/scripts/coverity/cov-analysis-win64-${COVERITY_VERSION}.zip -d ${BUILD_ROOT}/scripts/coverity/

	if [ -d "${BUILD_ROOT}/scripts/coverity/cov-analysis-win64/" ]; then
		echo Removing old ${BUILD_ROOT}/scripts/coverity/cov-analysis-win64/
		rm -rf ${BUILD_ROOT}/scripts/coverity/cov-analysis-win64/
    fi

	mv ${BUILD_ROOT}/scripts/coverity/cov-analysis-win64-${COVERITY_VERSION}.${COVERITY_MINOR_VERSION}/ ${BUILD_ROOT}/scripts/coverity/cov-analysis-win64/
else
	echo "Coverity archive doesn't exist!"
fi

chmod +x ${BUILD_ROOT}/scripts/coverity/cov-analysis-win64/bin/*

echo "Done!"

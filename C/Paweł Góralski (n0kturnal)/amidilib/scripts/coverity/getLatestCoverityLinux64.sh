#!/bin/bash

# helper script
# downloads Coverity Scan suite Linux64

# Copyright 2007-2022 Pawel Goralski
#    
# This file is part of AMIDILIB.
# See license.txt for licensing information.
#

BUILD_ROOT=.
COVERITY_VERSION=2022.6
COVERITY_MINOR_VERSION=0

if ! [ -f "${BUILD_ROOT}/cov-analysis-linux64-${COVERITY_VERSION}.tar.gz" ]; then
	echo "Getting coverity scan suite"
	wget -nc https://nokturnal.pl/downloads/atari/toolchains/cov-analysis-linux64-${COVERITY_VERSION}.tar.gz -P ${BUILD_ROOT}/
else
	echo "Coverity already downloaded!"
fi

if [ -f "${BUILD_ROOT}/cov-analysis-linux64-${COVERITY_VERSION}.tar.gz" ]; then
	echo "Unpacking ..."
	
	if [ -d "${BUILD_ROOT}/src/cov-analysis-linux64/" ]; then
		rm -rf ${BUILD_ROOT}/src/cov-analysis-linux64/
	fi
	
	mkdir ${BUILD_ROOT}/src/cov-analysis-linux64/
	
	tar -xf ${BUILD_ROOT}/cov-analysis-linux64-${COVERITY_VERSION}.tar.gz --strip-components=1 -C ${BUILD_ROOT}/src/cov-analysis-linux64/
else
	echo "Coverity archive doesn't exist!"
fi

echo "Done!"

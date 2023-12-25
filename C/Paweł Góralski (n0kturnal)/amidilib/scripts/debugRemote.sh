#!/bin/bash

# helper script
# runs tos debugger on remote TOS machine with given ip
# and passes TOS executable name with commandline parameters
# to begin debugging session

# Copyright 2007-2022 Pawel Goralski
#    
# This file is part of AMIDILIB.
# See license.txt for licensing information.
#

CURDIR=$(dirname "$0")

REMOTE_MACHINE=192.168.66.15
REMOTE_PATH=/e/adebug
TOS_DEBUGGER=ADEBUG.TTP
TOS_ROOT=E:/ADEBUG
PRG=$TOS_ROOT/RELEASE/MIDIPLAY.TTP
PARAM=$TOS_ROOT/U8_ETHPL.MID

echo Launching Atari native debugger with $PRG and parameters: $PARAM

#URL=http://${REMOTE_MACHINE}${REMOTE_PATH}/${TOS_DEBUGGER}?run="${PRG} ${PARAM}"
#curl -0 $URL

${CURDIR}/uip/uip-run.py ${REMOTE_MACHINE}${REMOTE_PATH}/${TOS_DEBUGGER} ${PRG} ${PARAM}
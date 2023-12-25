#!/bin/bash
# build helper script

#    Copyright 2007-2022 Pawel Goralski
#    
#    This file is part of AMIDILIB.
#    See license.txt for licensing information.
#    This file is part of BadMood/Amidilib.

# exit on error
set -e

#clean all stuff
echo ############ Clean All
scons --sconstruct=./buildconfigs/SConstruct_020-40_release -c

#build
echo ############ Build All
scons --sconstruct=./buildconfigs/SConstruct_020-40_release

#remove all intermediate files

echo ############ Cleanup
find ./nktlib/ -name "*.o" -type f|xargs rm -f
rm ./nktlib/.sconsign.dblite
rm ./nktlib/DUMMY.TXT

tar czvf nktlib-020-40.tgz ./nktlib

echo Done


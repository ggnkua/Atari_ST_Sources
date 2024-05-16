#!/bin/sh
echo -----------------------------------------------------------------------
echo Building rmac...
echo -----------------------------------------------------------------------
cd rmac
make
cd ..
echo -----------------------------------------------------------------------
echo Assembling demo...
echo -----------------------------------------------------------------------
./rmac/rmac -ps -v main.s -o bin/xmas2015.tos
echo
echo -----------------------------------------------------------------------
echo
echo If all went well, you should now have an executable for 4MB STE in the
echo "bin" subfolder. Merry christmas!
echo


@ECHO OFF
set PATH=%PATH%;/cygdrive/c/cygwin/bin/
set PATH=%PATH%;/cygdrive/c/cygwin/usr/local/cross-mint/bin;/usr/local/bin/
set PATH=%PATH%;/cygdrive/c/MinGW/bin/
set nodosfilewarning=1
cd %1
c:/cygwin/bin/python ../build %2
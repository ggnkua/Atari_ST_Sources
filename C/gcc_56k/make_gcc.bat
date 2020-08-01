rem  $Id: make_gcc.bat,v 1.8 91/07/24 17:09:37 pete Exp $
rem icc == intel compiler
rem hc386 == highc

gcc -c -O -D_MSDOS gcc.c
rem gcc -c -O -D_MSDOS version.c
rem gcc -c -O -D_MSDOS alloca.c
rem gcc -c -O -D_MSDOS obstack.c
gcc gcc.o version.o obstack.o alloca.o -o g56k
copy /b d:\djgpp\bin\stub.exe+g56k g56k.exe

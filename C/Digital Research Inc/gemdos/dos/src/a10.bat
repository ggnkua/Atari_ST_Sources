
rem -- 
rem -- a10.bat - run asm src thru pre-proc and then asm with 68010 options
rem --

check %1
cp68 -p %1.a %1.i
as68 -t -l -s c:\tools\ %1.i
del %1.i

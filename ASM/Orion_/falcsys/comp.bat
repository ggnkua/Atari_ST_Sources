set path="C:\VBCC\bin"

vc +%path%\..\config\normal.pc -cpu=68030 -O2 -o falcdemo.prg main.c falcsys.c falcsysa.s

pause

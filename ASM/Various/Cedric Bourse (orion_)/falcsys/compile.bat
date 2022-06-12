set path="E:\Programmation\Falcon\VBCC\bin"

vc +%path%\..\config\normal.pc -cpu=68030 -O4 -o falcdemo.prg main.c falcsys.c falcsysa.s

pause

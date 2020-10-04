set VBCC=D:\Programmation\Falcon\VBCC
set path=%VBCC%\bin

vc +%VBCC%\config\tos -O2 -nostdlib -o sdextjoy.prg init.s main.c sd.c xbioshook.s spi_extjoy.s

pause

copy sdextjoy.prg D:\Programmation\AtariSTE\ROOT\MyProg\WorkLab\

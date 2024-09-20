echo off
echo Creating BITMAPS.IMG file (takes quite a while)
tm start/n
:loop
if "%1"=="" goto end
echo ** Assembling %1 **
if "%1"=="bitmaps" goto do_header
a68k %1.btx=%1.bit
shift
goto loop
:do_header
m68k =bitmaps
a68k bitmaps.btx=bitmaps
del bitmaps.a68
shift
goto loop
:end
qlink=bitmaps
makeimg bitmaps
del bitmaps.hex
tm stop/n

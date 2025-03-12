echo off
tm start /n
:loop
if "%1"=="" goto end
echo ** Assembling %1 **
m68k temp=%1.m68
a68k %1.ltx=header.m68
del temp.a68
shift
goto loop
:end
qlink =elite
image =elite
tx elite.img
tm stop /n

@echo off
set linkfile=elite.lnk
if "%1"=="atari" goto atari
if "%1"=="ATARI" goto atari
if "%1"=="amiga" goto amiga
if "%1"=="AMIGA" goto amiga
echo Error - please use ELITE AMIGA or ELITE ATARI
goto end
:atari
echo Copying Atari Elite onto e:
call fiz c:\elite\atari
e:
copy f:common.def > nul
copy f:macros.m68 > nul
copy f:header.m68 > nul
copy f:bitlist.m68 > nul
copy f:icons.m68 > nul
copy f:asm.bat > nul
copy f:linkit.bat > nul
copy f:go.bat > nul
copy f:sendit.bat > nul
copy f:free.* > nul
copy f:elite.lnk > nul
copy f:*.ltx > nul
attrib -a *.* > nul
goto end
:amiga
echo Copying Amiga Elite onto e:
call fiz c:\elite\amiga
e:
copy f:68000.mac > nul
copy f:amiga.mac > nul
copy f:elite.mac > nul
copy f:common.def > nul
copy f:amiga.def > nul
copy f:track.inf > nul
copy f:header.m68 > nul
copy f:bitlist.m68 > nul
copy f:icons.m68 > nul
copy f:asm.bat > nul
copy f:lnk.bat > nul
copy f:go.bat > nul
copy f:linkit.bat > nul
copy f:sendit.bat > nul
copy f:free.* > nul
copy f:elite.lnk > nul
copy f:*.ltx > nul
attrib -a *.* > nul
:end

@echo off

rem Quelo 68k ASM Version 1.0 Copyright (c) 1990 Mr. Micro Ltd.
rem Designed and coded by Rob Nicholson.

rem Check for /log paramater.

if not "%1"=="/log" goto endif3
	set log=yes
	delete errors
	writeln Logging output to ERRORS
	shift
:endif3

rem If no parameters given, then use MAKE utility to assemble any files
rem that have changed.

if not "%1"=="" goto endif1
	make quelo %linkfile% asmb.bat f:
	if errorlevel 1 quit
	asmb
:endif1

rem Loop for each file specified.

tm start/n/c1
:loop1
	if "%1"=="" goto break1
	bold
	if exist %1.m68 goto else1
		writeln Assembling %1 from F:
		normal
		if not "%log%"=="yes" goto else4
			writeln Assembling %1 from F: >> errors
			m68k temp=f:%1.m68 >> errors
			goto endif4
		:else4
			m68k temp=f:%1.m68
		:endif4
		goto endif2
	:else1
		writeln Assembling %1
		normal
		if not "%log%"=="yes" goto else5
			writeln Assembling %1 >> errors
			m68k temp=%1.m68 >> errors
			goto endif5
		:else5
			m68k temp=%1.m68
		:endif5
	:endif2
	if "%log%"=="yes" a68k %1=header.m68 >> errors
	if not "%log%"=="yes" a68k %1=header.m68
	delete temp.a68
	shift
goto loop1
:break1

rem Log how long the assembly took.

tm stop/n/c1
echo Assemble >> c:\sys\public\timelog
tm stop/c1/log/l >> c:\sys\public\timelog

rem Clear LOG flag.

set log=

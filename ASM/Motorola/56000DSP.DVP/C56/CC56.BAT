echo off
rem *
rem * Compile and link a single MICRO-C program
rem *
rem * Copyright 1988,1989 Dave Dunfield
rem *
rem Note: use of Microsoft or other C preprocessor is optional
echo Preprocessing '%1.c' to '%1.i'...
cl /P %1.c
if errorlevel 1 goto fail
echo Compiling '%1.i' to '%1.s'...
c56 %1.i %1.s -s -l
if errorlevel 1 goto fail
echo Optimizing '%1.s' to '%1.asm'...
o56 %1.s %1.asm
if errorlevel 1 goto fail
rem echo Assembling...
rem a56 %1
:fail

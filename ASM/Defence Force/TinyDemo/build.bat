@ECHO OFF
::
:: http://sun.hasenbraten.de/vasm/index.php?view=tutorial
:: http://sun.hasenbraten.de/vasm/release/vasm.html
::
del TinyDemo.prg 2>NUL

vasm.exe -m68000 -Ftos -noesc -no-opt -o TinyDemo.prg TinyDemo.s
IF ERRORLEVEL 1 GOTO ErrorVasm

pause
goto :End

:ErrorVasm
ECHO ------------------------ ERROR ------------------------
pause
goto :End


:End


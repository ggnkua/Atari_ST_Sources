@ECHO OFF

::
:: Convert the 408x200 picture of King Tung into an Atari format picture
::
PictConv.exe -m1 -f0 -p0 -o7 data\tutankhamun.png exported\tutankhamun.pi1


::
:: http://rmac.is-slick.com/manual/rmac.html#notes-for-migrating-from-other-68000-assemblers
::
:: -px  -> Generate executable with extended debug symbols
:: -v   -> Exports the list of all the sections
:: -s   -> Warns about non optimized jumps
:: 


del SineWave.PRG 2>NUL

SET RMAC=rmac_macro_error_test.exe
SET OPTIONS=-px -v -s -llisting.txt

ECHO Assembling
%RMAC% %OPTIONS% SineWave.s
IF ERRORLEVEL 1 GOTO ErrorVasm

::ECHO Copying into the emulator folder
::copy SineWave.PRG D:\_emul_\atari\_mount_\DEFENCEF.RCE\SineWave.PRG

pause
goto :End

:ErrorVasm
ECHO ------------------------ ERROR ------------------------
pause
goto :End


:End


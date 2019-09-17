echo off
:first
WHATNEXT What mode do you want to try? (S, M, L, or H) SMLH
if errorlevel 4 goto huge
if errorlevel 3 goto large
if errorlevel 2 goto medium
if errorlevel 1 goto small

WHATNEXT Do you really want to quit? (Y/N) YN
if errorlevel 2 goto first
goto done

:small
echo message - This is the small selected
goto first

:medium
echo message - This is the medium selected
goto first

:large
echo message - This is the large selected
goto first

:huge
echo message - This is the huge thing selected
goto first

:done
echo message - This is the end of this silly routine
echo on

xcopy empty.lst list.lst
:GOON
if "%1" == "" GOTO END
hccpm %1 >>list.lst
shift
goto GOON
:END



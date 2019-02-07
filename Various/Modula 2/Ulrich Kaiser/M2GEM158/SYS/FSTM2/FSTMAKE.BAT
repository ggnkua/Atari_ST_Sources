mc %1 /s 8000 32768 /c /m /d-
m2link %1 /s 8192 /h 4096 /o
cd c:\fstm2\work
del %1.app
ren %1.exe %1.app


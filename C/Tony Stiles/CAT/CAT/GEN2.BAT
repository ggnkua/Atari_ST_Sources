@cd csource
tcc -Ld:\pc\turboc -Id:\pc\turboc\include -ml -DPC -eADVENT.EXE *.c
@copy advent.exe ..
@cd ..


echo off
cls

utils\vasmm68k_mot -devpac -Ftos -o ti2st.prg ti2st.s
pause

::Test on STeem emulator
::copy ti2st.prg E:\Programmation\AtariSTE\ROOT\

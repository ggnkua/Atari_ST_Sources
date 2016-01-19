set myasm=C:\DEVPAC3\GEN
set myind=E:\AHSMOD\CURR\
set myoutd=E:\AHSMOD\CURR\BIN\
set myinc=E:\AHSMOD\CURR\LIB

%myasm% -I%myinc% %myind%SCC__TST.S -EXX_FOR_THIS=0 -O%myoutd%SCC.PRG
%myasm% -I%myinc% %myind%SCC__TST.S -EXX_FOR_THIS=1 -O%myoutd%ESCC.PRG
%myasm% -I%myinc% %myind%SCC__TST.S -EXX_FOR_THIS=3 -O%myoutd%ST_ESCC.PRG

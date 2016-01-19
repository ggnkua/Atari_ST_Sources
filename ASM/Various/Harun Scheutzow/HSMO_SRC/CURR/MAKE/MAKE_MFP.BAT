set myasm=C:\DEVPAC3\GEN
set myind=E:\AHSMOD\CURR\
set myoutd=E:\AHSMOD\CURR\BIN\
set myinc=E:\AHSMOD\CURR\LIB

%myasm% -I%myinc% %myind%MFP__TST.S -EXX_FOR_THIS=0 -O%myoutd%MFP.PRG
%myasm% -I%myinc% %myind%MFP__TST.S -EXX_FOR_THIS=1 -O%myoutd%MFP_TT.PRG
%myasm% -I%myinc% %myind%MFP__TST.S -EXX_FOR_THIS=2 -O%myoutd%MFP_FALC.PRG
%myasm% -I%myinc% %myind%MFP__TST.S -EXX_FOR_THIS=3 -O%myoutd%MFP_BAST.PRG
%myasm% -I%myinc% %myind%MFP__TST.S -EXX_FOR_THIS=4 -O%myoutd%MFP_MILA.PRG

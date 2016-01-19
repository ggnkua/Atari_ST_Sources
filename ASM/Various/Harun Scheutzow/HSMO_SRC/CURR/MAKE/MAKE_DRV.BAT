set myasm=C:\DEVPAC3\GEN
set myind=E:\AHSMOD\CURR\
set myoutd=E:\AHSMOD\CURR\BIN\
set myinc=E:\AHSMOD\CURR\LIB

%myasm% -I%myinc% %myind%DRVINTST.S -EEXTRASICHER=0 -O%myoutd%DRVIN.PRG
%myasm% -I%myinc% %myind%DRVINTST.S -EEXTRASICHER=1 -O%myoutd%DRVINSA.PRG

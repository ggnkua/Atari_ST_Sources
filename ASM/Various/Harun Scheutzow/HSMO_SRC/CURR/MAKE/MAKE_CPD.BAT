set myasm=C:\DEVPAC3\GEN
set myind=E:\AHSMOD\CURR\
set myoutd=E:\AHSMOD\CURR\BIN\
set myinc=E:\AHSMOD\CURR\LIB

%myasm% -I%myinc% %myind%CPDRVTST.S -O%myoutd%CPDRV.PRG

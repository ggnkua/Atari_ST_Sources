set myasm=C:\DEVPAC3\GEN
set myind=E:\AHSMOD\CURR\
set myoutd=E:\AHSMOD\CURR\BIN\
set myinc=E:\AHSMOD\CURR\LIB

%myasm% -I%myinc% %myind%UART_TST.S -EXX_FOR_THIS=0 -O%myoutd%UART_3F8.PRG
%myasm% -I%myinc% %myind%UART_TST.S -EXX_FOR_THIS=1 -O%myoutd%UART_2F8.PRG

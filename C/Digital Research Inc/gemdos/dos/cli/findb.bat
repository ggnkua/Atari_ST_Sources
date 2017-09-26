cp68 -i ..\gemrtl\ find.c x.i
c068 x.i x.1 x.2 x.3 
era x.i
c168 x.1 x.2 find.s
era x.1
era x.2
as68 -s ..\gemrtl\  -l -u find.s
era find.s

lo68 -s -r -u_nofloat -o find.rel  \devkits\s.o find.o \temp\clib\clib
relmod find.rel find.prg
era find.rel




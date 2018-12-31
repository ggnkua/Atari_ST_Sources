cp68 benchmrk.c benchmrk.i
c068 benchmrk.i benchmrk.1 benchmrk.2 benchmrk.3 -f
rm benchmrk.i
c168 benchmrk.1 benchmrk.2 benchmrk.s
rm benchmrk.1
rm benchmrk.2
as68 -l -u benchmrk.s
rm benchmrk.s

link68 [u,s] benchmrk.68k=gems,benchmrk,gemlib,osbind,libf
rm benchmrk.o
relmod benchmrk.68k benchmrk.tos
rm benchmrk.68k
wait

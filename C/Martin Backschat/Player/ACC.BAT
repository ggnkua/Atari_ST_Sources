cp68 %1.c %1.i
c068 %1.i %1.1 %1.2 %1.3 -f
rm %1.i
c168 %1.1 %1.2 %1.s
rm %1.1
rm %1.2
as68 -l -u %1.s
link68 [u] %1.68k=accstart,%1,osbind,vdibind,aesbind
relmod %1.68k %1.acc
rm %1.68k
rm %1.o
rm %1.s
wait


cp68 pictran.c pictran.i
c068 pictran.i pictran.1 pictran.2 pictran.3 -f
rm pictran.i
c168 pictran.1 pictran.2 pictran.s
rm pictran.1
rm pictran.2
as68 -l -u pictran.s
rm pictran.s
link68 [i] pictran,68k=apstart,pictran,vdibind,aesbind,osbind,graf
rm pictran.o
relmod pictran.68k,pictran.prg
rm pictran.68k
wait

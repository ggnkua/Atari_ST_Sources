cp68 iffread.c iffread.i
c068 iffread.i iffread.1 iffread.2 iffread.3 -f
rm iffread.i
c168 iffread.1 iffread.2 iffread.s
rm iffread.1
rm iffread.2
as68 -l -u iffread.s
rm iffread.s

link68 [u] iffread.68k=apstart,iffread,iffrtns,osbind,gemlib,aesbind,vdibind
rm iffread.o
relmod iffread.68k iffread.prg
rm iffread.68k
wait


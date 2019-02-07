cp68 iffwrite.c iffwrite.i
c068 iffwrite.i iffwrite.1 iffwrite.2 iffwrite.3 -f
rm iffwrite.i
c168 iffwrite.1 iffwrite.2 iffwrite.s
rm iffwrite.1
rm iffwrite.2
as68 -l -u iffwrite.s
rm iffwrite.s

link68 [u] iffwrite.68k=apstart,iffwrite,iffrtns,osbind,gemlib,aesbind,vdibind
rm iffwrite.o
relmod iffwrite.68k iffwrite.prg
rm iffwrite.68k
wait


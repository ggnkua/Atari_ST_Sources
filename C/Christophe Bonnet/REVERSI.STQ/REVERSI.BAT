cp68 reversi.c reversi.i
c068 reversi.i reversi.1 reversi.2 reversi.3 -f
rm reversi.i
c168 reversi.1 reversi.2 reversi.s
rm reversi.1
rm reversi.2
as68 -l -u reversi.s
rm reversi.s

link68 [u,s] reversi.68k=accstart,reversi,vdibind,aesbind,osbind 
rm reversi.o
relmod reversi.68k reversi.acc
rm reversi.68k
wait

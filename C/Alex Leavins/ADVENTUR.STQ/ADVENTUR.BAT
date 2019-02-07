cp68 adventur.c adventur.i
c068 adventur.i adventur.1 adventur.2 adventur.3 -f
rm adventur.i
c168 adventur.1 adventur.2 adventur.s
rm adventur.1
rm adventur.2
as68 -l -u adventur.s
rm adventur.s

link68 [u,s] adventur.68k=gems,adventur,gemlib,osbind,libf
rm adventur.o
relmod adventur.68k adventur.tos
rm adventur.68k
wait

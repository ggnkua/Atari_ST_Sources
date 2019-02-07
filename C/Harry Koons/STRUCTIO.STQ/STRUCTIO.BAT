cp68 structio.c structio.i
c068 structio.i structio.1 structio.2 structio.3 -f
rm structio.i
c168 structio.1 structio.2 structio.s
rm structio.1
rm structio.2
as68 -l -u structio.s
rm structio.s

link68 [co[structio.inp]]
rm structio.o
relmod structio.68k structio.tos
rm structio.68k
wait

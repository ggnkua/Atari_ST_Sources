as68  -l -u %2.s
wait.prg
link68 [u] %2.68k=%1.o,%2.o
relmod %2.68k %2.prg
rm %2.68k
rm %2.o

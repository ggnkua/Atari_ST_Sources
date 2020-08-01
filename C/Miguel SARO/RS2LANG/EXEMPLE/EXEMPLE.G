echo  ' compil‚ avec SOZOBON 1.33i'
echo  ' '
jas -l -u -V exinit.s -o exinit.o
cc -c -v -O exemple.c
ld -vpbt  exinit.o exemple.o -o exemple.prg   dlibs.a aesfast.a
rm *.o

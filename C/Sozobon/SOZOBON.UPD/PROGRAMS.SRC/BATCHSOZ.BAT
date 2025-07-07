EXEPATH  \sozobon\bin\
hcc.ttp  batchmon.c
top.ttp  batchmon.s g:batchmon.s
DELETE   batchmon.s
jas.ttp  g:batchmon.s -o g:batchmon.o
DEFPATH  \sozobon\lib\
ld.ttp   -p -o f:\batchmon.ttp dstart.o g:batchmon.o dlibs.a
DELETE   g:batchmon.s g:batchmon.o
WAIT


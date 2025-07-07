CP68         batchmon.C g:batchmon.I
C068       g:batchmon.I g:batchmon.1 g:batchmon.2 g:batchmon.3 -f
C168       g:batchmon.1 g:batchmon.2 g:batchmon.S
DELETE     g:batchmon.I g:batchmon.1 g:batchmon.2 
MAC        -6 -v -og:batchmon.o g:batchmon.s
DELETE     g:batchmon.S 

aln       -w -v -o batchmon.ttp \sozobon\lib\dstart.o g:batchmon.o \sozobon\lib\dlibs.a

WAIT


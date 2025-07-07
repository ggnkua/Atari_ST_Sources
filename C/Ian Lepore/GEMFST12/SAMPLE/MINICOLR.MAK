CFLAGS = -O

minicolr.acc: minicolr.o
+ aln.prg -v -w -o minicolr.acc accstart.o minicolr.o aesfast.a


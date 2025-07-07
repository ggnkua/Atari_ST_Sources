CFLAGS = -O

memfind.prg: memfind.o
+ aln.prg -v -w -o memfind.prg apstart.o memfind.o aesfast.a d:\printf.o dlibs.a


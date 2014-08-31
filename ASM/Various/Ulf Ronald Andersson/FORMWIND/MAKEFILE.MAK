CFLAGS = -O

OBJ = formwind.o

formwind.prg: $(OBJ)
    cc -o formwind.prg $(OBJ) aesfast.a vdifast.a dlibs.a


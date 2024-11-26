.c.obj:
    tcc -c $(CFLAGS) $*.c

.asm.obj:
    tasm /mx $*.asm


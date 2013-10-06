CFLAGS=/c
CC=cl
INCS=c56.h tokens.h

c56.obj: c56.c $(INCS)
	$(CC) $(CFLAGS) c56.c

c56io.obj: c56io.c $(INCS)
	$(CC) $(CFLAGS) c56io.c

c56cg.obj: c56cg.c $(INCS)
	$(CC) $(CFLAGS) c56cg.c

c56.exe: c56.obj c56io.obj c56cg.obj
	link c56.obj c56cg.obj c56io.obj,c56.exe;

o56.exe: o56.c
	cl o56.c

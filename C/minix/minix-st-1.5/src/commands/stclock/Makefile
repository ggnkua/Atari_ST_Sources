CFLAGS	= -O -I.


CMD	= megartc weidertc diskrtc diskset
CMDNEW	=
CMDNOT	=
OBJ	= megartc.o weidertc.o diskrtc.o diskset.o
HDR	= ioctl.c

all:	$(CMD) $(CMDNEW)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD) $(CMDNEW)

megartc: megartc.c
	$(CC) $(CFLAGS) $@.c -o $@
weidertc: weidertc.c
	$(CC) $(CFLAGS) $@.c -o $@
diskrtc: diskrtc.c $(HDR)
	$(CC) $(CFLAGS) diskrtc.c $(HDR) -o $@
diskset: diskset.c $(HDR)
	$(CC) $(CFLAGS) diskset.c $(HDR) -o $@

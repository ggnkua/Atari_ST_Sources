CFLAGS	= -O -I.


CMD	= anm aoutdump asize astrip cc cv tos format
CMDNEW	=
CMDNOT	=

all:	$(CMD) $(CMDNEW)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD) $(CMDNEW)

anm: anm.c
	$(CC) $(CFLAGS) $@.c -o $@
aoutdump: aoutdump.c
	$(CC) $(CFLAGS) $@.c -o $@
asize: asize.c
	$(CC) $(CFLAGS) $@.c -o $@
astrip: astrip.c
	$(CC) $(CFLAGS) $@.c -o $@
cc: cc.c
	$(CC) $(CFLAGS) $@.c -o $@
cv: cv.c
	$(CC) $(CFLAGS) $@.c -o $@
tos: tos.c
	$(CC) $(CFLAGS) $@.c -o $@
format: format.c
	$(CC) $(CFLAGS) $@.c -o $@

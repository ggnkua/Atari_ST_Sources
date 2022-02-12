CFLAGS	= -O -DVOLATILE= -I../..

CMD	= mdb
OBJ	= mdb.o mdbexp.o mdbdis.o
HDR	= user.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

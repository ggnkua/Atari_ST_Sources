CFLAGS	= -O

CMD	= bawk
OBJ	= bawk.o bawkact.o bawkdo.o bawkpat.o bawksym.o
HDR	= bawk.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

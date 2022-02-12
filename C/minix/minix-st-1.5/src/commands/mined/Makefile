CFLAGS	= -O

CMD	= mined
OBJ	= mined1.o mined2.o
HDR	= mined.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

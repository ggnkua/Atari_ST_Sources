CFLAGS	= -O -Dunix

CMD	= make
OBJ	= check.o input.o macro.o main.o make.o reader.o rules.o
HDR	= h.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

CFLAGS	= -O

CMD	= ic
OBJ	= ic.o ic_input.o ic_output.o
HDR	= ic.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

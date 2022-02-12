CFLAGS	= -DEXTENDED -O

CMD	= m4
OBJ	= main.o eval.o serv.o look.o misc.o expr.o
HDR	= mdef.h extr.h patchlevel.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ): $(HDR)

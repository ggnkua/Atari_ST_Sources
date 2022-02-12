CFLAGS	= -O -I. -DAAL

CMD	= ar
OBJ	= archiver.o rd_object.o wr_arhdr.o wr_object.o wr_ranlib.o
HDR	= arch.h byte_order.h object.h ranlib.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ): $(HDR)

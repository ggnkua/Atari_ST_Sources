CFLAGS	= -O

CMD	= indent
OBJ	= indent.o io.o lexi.o parse.o comment.o args.o
HDR	= codes.h globs.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

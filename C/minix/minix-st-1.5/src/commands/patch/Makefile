CFLAGS	= -O -DVOIDSIG -DCHARSPRINTF

CMD	= patch
OBJ	= patch.o pch.o inp.o util.o version.o
HDR	= EXTERN.h INTERN.h common.h config.h \
	  inp.h patchlevel.h pch.h util.h version.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

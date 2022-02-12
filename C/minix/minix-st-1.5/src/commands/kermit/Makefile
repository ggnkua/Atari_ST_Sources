CFLAGS	= -O -DV7 -DMINIX

CMD	= kermit
OBJ	= ckcmai.o ckucmd.o ckuusr.o ckuus2.o ckuus3.o \
	  ckcpro.o ckcfns.o ckcfn2.o ckucon.o ckutio.o \
	  ckufio.o ckudia.o ckuscr.o
HDR	= ckcdeb.h ckcker.h ckcsym.h ckucmd.h ckuusr.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

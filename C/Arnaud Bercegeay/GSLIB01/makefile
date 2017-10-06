#!make -f
# @(#)windom.mk, 
#
# make file for 'GSlib'
#

#CC=zcc
CFLAGS= -O
LDFLAGS=

OBJ = GSlib.o

all: GSlib.a

GSlib.a: $(OBJ)
	$(RM) GSlib.a
	$(AR) -r GSlib.a $(OBJ)
	
$(OBJ): GSlib.h

clean:
	rm -f *.o *.a
#eof

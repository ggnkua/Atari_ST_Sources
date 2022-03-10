CFLAGS = -I..\include\ -O

DELLIB = $(RM)
ADDLIB = ar.ttp q

LIB  = aesutil.a
OBJ1 = gramouse.o rcadjust.o rccopy.o rcequal.o rcinters.o
OBJ2 = rcunion.o  rcvtog.o rcgtov.o  rcscale.o 

$(LIB): $(OBJ1) $(OBJ2)
    $(DELLIB) $(LIB)
    $(ADDLIB) $(LIB) $(OBJ1) $(OBJ2)

cleanup:
    del *.o *.a
    
force: cleanup $(LIB)
    @echo

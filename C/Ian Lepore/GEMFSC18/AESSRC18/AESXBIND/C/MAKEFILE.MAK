
CFLAGS = -I..\include\ -O

DELLIB = $(RM)
ADDLIB = ar.ttp qv

LIB  = aesxbind.a
OBJ1 = evnxmult.o frmxcent.o frmxdial.o winxget.o winxcalc.o grfxdrag.o
OBJ2 = wndtop.o

$(LIB): $(OBJ1) $(OBJ2)
    $(DELLIB) $(LIB)
    $(ADDLIB) $(LIB) $(OBJ1) $(OBJ2)

cleanup:
    del *.o *.a
    
force: cleanup $(LIB)
    @echo
    


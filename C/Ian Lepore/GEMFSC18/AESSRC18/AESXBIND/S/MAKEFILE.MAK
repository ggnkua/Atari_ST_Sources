
DELLIB = $(RM)
ADDLIB = ar.ttp q

LIB  = aesxbind.a
OBJ1 = evnxmult.o frmxcent.o frmxdial.o winxget.o winxcalc.o grfxdrag.o
OBJ2 = wndtop.o

.s.o:
    mac.prg   $*.s
    globs.ttp $*.o

$(LIB): $(OBJ1) $(OBJ2)
    $(DELLIB) $(LIB)
    $(ADDLIB) $(LIB) $(OBJ1) $(OBJ2)

cleanup:
    del *.o *.a
    
force: cleanup $(LIB)
    @echo
    

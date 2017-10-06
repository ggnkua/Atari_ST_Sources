CFLAGS =-O

LIB  = browser.lib
LOBJ = brevent.o brmalloc.o brllist.o brfile.o braction.o dllutil.o

OBJ  = browse.o 
EXE  = browse.prg

$(EXE): $(OBJ) $(LIB) 
    cc -rminstart.o $(OBJ) $(LIB) aesfast.a vdifast.a dlibs.a
    
$(LIB): $(LOBJ)
    $(RM) $(LIB)
    ar.ttp qv $(LIB) $(LOBJ)

$(LOBJ): browser.h dllutil.h

cleanup:
    $(RM) $(EXE) $(OBJ)
    
force: cleanup $(EXE)
    $(ECHO) All remade!

archive:
    lharc a browse br*.c br*.h dl*.c dl*.h br*.mak br*.rs*
    
arcupd:
    lharc f browse *.*
    

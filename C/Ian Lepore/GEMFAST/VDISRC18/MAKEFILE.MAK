VERSION = 18

DELLIB = $(RM)

LIB  =  vdifast.a
VDIBIND  = vdibind

lib:
    $(PUSHDIR) $(VDIBIND)
    make -h- $(MAKEARGS)
    $(POPDIR)
    $(CP) $(VDIBIND)\$(LIB) $(LIB) 
    $(CP) $(LIB) c:\sozobon\lib\$(LIB)

archive:
    $(DELLIB) vdisrc$(VERSION).lzh
    lharc.ttp a -umpxr vdisrc$(VERSION) *.s* *.mak *.doc
    
arcupd:
    lharc.ttp f -umpxr vdisrc$(VERSION) *.*
    


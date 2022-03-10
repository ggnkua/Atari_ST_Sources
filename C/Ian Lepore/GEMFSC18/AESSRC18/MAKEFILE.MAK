VERSION = 18

DELLIB = $(RM)
CATLIB = appndlib.ttp

LIB  = aesfast.a

#
# the subdirectories where the individual libraries live...
#

AESFUNCS = aesfuncs
AESUTIL  = aesutil.s
AESXBIND = aesxbind.s
AESBIND  = aesbind

all: sublibs lib
    $(ECHO)
    
sublibs:
    $(PUSHDIR) $(AESFUNCS)
    make -h- $(MAKEARGS)
    $(POPDIR)
    $(PUSHDIR) $(AESUTIL)
    make -h- $(MAKEARGS)
    $(POPDIR)
    $(PUSHDIR) $(AESXBIND)
    make -h- $(MAKEARGS)
    $(POPDIR)
    $(PUSHDIR) $(AESBIND)
    make -h- $(MAKEARGS)
    $(POPDIR)
    
lib:
    $(DELLIB) $(LIB)
    $(CATLIB) $(LIB) $(AESFUNCS)\aesfuncs.a $(AESUTIL)\aesutil.a
    $(CATLIB) $(LIB) $(AESXBIND)\aesxbind.a $(AESBIND)\aesbind.a
    $(CP) $(LIB) c:\sozobon\lib\$(LIB)

archive:
    $(DELLIB) aessrc$(VERSION).lzh
    lharc.ttp a -umpxr aessrc$(VERSION) *.c *.s* *.h *.doc *.mak
    
arcupd:
    lharc.ttp f -umpxr aessrc$(VERSION) *.*
    

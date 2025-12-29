#makefile.qc from Craig Lawson.

PROJ    =SCM
DEBUG    =0
CC    =qcl
CFLAGS_G    = /AL /W1 /Ze
CFLAGS_D    = /Zi /Zr /Od
CFLAGS_R    = /O /Ot /DNDEBUG
CFLAGS    =$(CFLAGS_G) $(CFLAGS_R)
LFLAGS_G    = /CP:0xffff /NOI /SE:0x80 /ST:0x9c40
LFLAGS_D    = /CO
LFLAGS_R    =
LFLAGS    =$(LFLAGS_G) $(LFLAGS_R)
RUNFLAGS    =cc
OBJS_EXT =
LIBS_EXT =
 
all:    $(PROJ).exe
 
sys.obj:    sys.c scm.h config.h

time.obj:    time.c scm.h config.h
 
eval.obj:   eval.c scm.h config.h
 
subr.obj:   subr.c scm.h config.h
 
scm.obj:    scm.c scm.h config.h

repl.obj:    repl.c scm.h config.h
 
scl.obj:    scl.c scm.h config.h
 
sc2.obj:   sc2.c scm.h config.h
 
$(PROJ).exe:    sys.obj eval.obj subr.obj scm.obj repl.obj scl.obj \
		sc2.obj $(OBJS_EXT)
    echo >NUL @<<$(PROJ).crf
sys.obj +
eval.obj +
subr.obj +
scm.obj +
repl.obj +
scl.obj +
sc2.obj +
$(OBJS_EXT)
$(PROJ).exe
 
$(LIBS_EXT);
<<
    link $(LFLAGS) @$(PROJ).crf
 
run: $(PROJ).exe
    $(PROJ) $(RUNFLAGS)

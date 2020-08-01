#makefile.qc from Craig Lawson.

PROJ    =SCM
DEBUG    =0
CC    =qcl
CFLAGS_G    = /AH /W1 /Ze
CFLAGS_D    = /Zi /Zr /Od
CFLAGS_R    = /O /Ot /DNDEBUG /DFLOATS
CFLAGS    =$(CFLAGS_G) $(CFLAGS_R)
LFLAGS_G    = /CP:0xffff /NOI /SE:0x80 /ST:0x9c40
LFLAGS_D    = /CO
LFLAGS_R    =
LFLAGS    =$(LFLAGS_G) $(LFLAGS_R)
RUNFLAGS    =cc
OBJS_EXT =
LIBS_EXT =

all:    $(PROJ).exe

sys.obj:    sys.c scm.h scmfig.h

time.obj:    time.c scm.h scmfig.h

eval.obj:   eval.c scm.h scmfig.h

subr.obj:   subr.c scm.h scmfig.h

scm.obj:    scm.c scm.h scmfig.h

repl.obj:    repl.c scm.h scmfig.h

scl.obj:    scl.c scm.h scmfig.h

sc2.obj:   sc2.c scm.h scmfig.h

unif.obj:   unif.c scm.h scmfig.h

$(PROJ).exe:    sys.obj time.obj eval.obj subr.obj scm.obj repl.obj \
		scl.obj sc2.obj unif.obj $(OBJS_EXT)
    echo >NUL @<<$(PROJ).crf
sys.obj +
time.obj +
eval.obj +
subr.obj +
scm.obj +
repl.obj +
scl.obj +
sc2.obj +
unif.obj +
$(OBJS_EXT)
$(PROJ).exe

$(LIBS_EXT);
<<
    qlink $(LFLAGS) @$(PROJ).crf

run: $(PROJ).exe
    $(PROJ) $(RUNFLAGS)

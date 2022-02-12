AS=/usr/local/gnu/bin/gcc-as -mc68000
AR=gcc-ar
CC=gcc
CPP=/usr/local/gnu/bin/gcc-cpp
CFLAGS= -I../../.. -D_MINIX -D_POSIX_SOURCE $(XCFLAGS)
CRT0 = gcrtso.o
LIBRARY = ../../libc.olb
OBJSL =	$(LIBRARY)(__longjmperr.o)	\
	$(LIBRARY)(__sigreturn.o)	\
	$(LIBRARY)(brksz.o)		\
	$(LIBRARY)(receive.o)		\
	$(LIBRARY)(send.o)		\
	$(LIBRARY)(sendrec.o)		\
	$(LIBRARY)(setjmp.o)		\
	$(LIBRARY)(sndrec.o)

OBJS =	$(OBJSL) $(CRT0)

NOOBJS = catch.o edata.o em_end.o end.o etext.o ncrtso.o

all:	$(LIBRARY) $(CRT0)

$(LIBRARY): $(OBJSL)
	rm -f $(CRT0)
	$(AR) rv $(LIBRARY) *.o
	rm -f *.o

$(CRT0): ncrtso.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o $*.o -

clean:	
	@rm -rf *.o *.bak

clobber: clean

$(LIBRARY)(__longjmperr.o):	__longjmperr.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o __longjmperr.o -

$(LIBRARY)(__sigreturn.o):	__sigreturn.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o __sigreturn.o -

$(LIBRARY)(brksz.o):	brksz.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o brksz.o -

$(LIBRARY)(receive.o):	receive.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o receive.o -

$(LIBRARY)(send.o):	send.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o send.o -

$(LIBRARY)(sendrec.o):	sendrec.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o sendrec.o -

$(LIBRARY)(setjmp.o):	setjmp.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o setjmp.o -

$(LIBRARY)(sndrec.o):	sndrec.s
	../mot2mit.sh $< | $(CPP) $(CFLAGS) - | $(AS) -o sndrec.o -


CC	= cc
CFLAGS	= -I../../../include -D_MINIX -D_POSIX_SOURCE \
	-D_SETJMP_SAVES_REGS=0 -D__ACK__
CC1	= $(CC) $(CFLAGS) -c
LIBRARY	= ../../libc.a

CRT0	= ../../crtso.o
CFRT0	= ../../cfrtso.o
M2RT0	= ../../m2rtso.o
M2FRT0	= ../../m2frtso.o
PRT0	= ../../prtso.o
PFRT0	= ../../pfrtso.o
OBJSL = \
	$(LIBRARY)(__intsize.o)		\
	$(LIBRARY)(__longjmperr.o)	\
	$(LIBRARY)(__sigreturn.o)	\
	$(LIBRARY)(brksz.o)		\
	$(LIBRARY)(receive.o)		\
	$(LIBRARY)(send.o)		\
	$(LIBRARY)(sendrec.o)		\
	$(LIBRARY)(setjmp.o)		\
	$(LIBRARY)(sndrec.o)

OBJS =	$(OBJSL) $(CRT0) $(CFRT0) $(M2RT0) $(M2FRT0) $(PRT0) $(PFRT0)

NOOBJS = catch.o edata.o em_end.o end.o etext.o ncrtso.o

all:	$(LIBRARY) $(CRT0) $(CFRT0) $(M2RT0) $(M2FRT0) $(PRT0) $(PFRT0)

$(LIBRARY): $(OBJSL)
	rm -f crtso.o
	aal cr $(LIBRARY) *.o
	rm -f *.o

$(CRT0): ncrtso.s
	$(CC1) $<
	mv ncrtso.o $@

$(CFRT0): ncrtso.s
	$(CC1) -DFLOAT_STARTUP $<
	mv ncrtso.o $@

$(M2RT0): m2rtso.s
	$(CC1) $<
	mv m2rtso.o $@

$(M2FRT0): m2rtso.s
	$(CC1) -DFLOAT_STARTUP $<
	mv m2rtso.o $@

$(PRT0): prtso.s
	$(CC1) $<
	mv prtso.o $@

$(PFRT0): prtso.s
	$(CC1) -DFLOAT_STARTUP $<
	mv prtso.o $@

clean:	
	@rm -rf *.o *.bak

clobber: clean

$(LIBRARY)(__intsize.o):	__intsize.c
	$(CC1) $<

$(LIBRARY)(__longjmperr.o):	__longjmperr.s
	$(CC1) $<

$(LIBRARY)(__sigreturn.o):	__sigreturn.s
	$(CC1) $<

$(LIBRARY)(brksz.o):	brksz.s
	$(CC1) $<

$(LIBRARY)(receive.o):	receive.s
	$(CC1) $<

$(LIBRARY)(send.o):	send.s
	$(CC1) $<

$(LIBRARY)(sendrec.o):	sendrec.s
	$(CC1) $<

$(LIBRARY)(setjmp.o):	setjmp.s
	$(CC1) $<

$(LIBRARY)(sndrec.o):	sndrec.s
	$(CC1) $<



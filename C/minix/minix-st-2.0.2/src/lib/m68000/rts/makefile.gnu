# GNU Makefile fuer m68000/rts

base = ../..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CPPFLAGS = $(XCPPFLAGS) -DGNUOBJ
CFLAGS	= $(XCFLAGS) -DGNUOBJ
LIBRARY = $(LIBC)

OBJSL =	__longjmperr.o	\
	__sigreturn.o	\
	brksz.o		\
	receive.o	\
	send.o		\
	sendrec.o	\
	setjmp.o	\
	sndrec.o	\
	__intsize.o

OBJS =	$(OBJSL) $(CRT0)

NOOBJS = catch.o edata.o em_end.o end.o etext.o ncrtso.o

all:	$(LIBRARY) $(CRT0)

$(LIBRARY): $(OBJSL)
	rm -f $(CRT0)
	$(AR) rsv $(LIBRARY) *.o
	rm -f *.o

$(CRT0): ncrtso.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o $*.o -

clean:	
	@rm -rf *.o *.bak

clobber: clean

__longjmperr.o:	__longjmperr.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o __longjmperr.o -

__sigreturn.o:	__sigreturn.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o __sigreturn.o -

brksz.o:	brksz.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o brksz.o -

receive.o:	receive.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o receive.o -

send.o:	send.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o send.o -

sendrec.o:	sendrec.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o sendrec.o -

setjmp.o:	setjmp.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o setjmp.o -

sndrec.o:	sndrec.s
	../mot2mit.sh $< | $(CPP) $(CPPFLAGS) - | $(AS) -o sndrec.o -


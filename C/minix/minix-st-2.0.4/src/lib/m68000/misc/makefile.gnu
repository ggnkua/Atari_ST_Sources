# Makefile for m68000/misc

base = ../..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

LIBRARY	= $(LIBC)
CFLAGS	= $(XCPPFLAGS)

OBJS	= get_bp.o oneC_sum.o
LIBRARY = $(LIBC)

all:	$(OBJS)
	$(AR) $(ARFLAGS) $(LIBRARY) $(OBJS)
	$(RM) $(OBJS)

.s.o:
	../mot2mit.sh $*.s | $(CPP) $(CFLAGS) - | $(AS) -o $*.o -

clean:	
	@rm -rf *.o *.bak

clobber: clean

# Makefile for lib/m68000/fphook.

# The ACK ANSI C compiler has an nice trick to reduce the size of programs
# that do not use floating point.  If a program uses floating point then the
# compiler generates an external reference to the label '_fp_hook'.  This makes
# the loader bring in the floating point printing and conversion routines
# '_f_print' and 'strtod' from the library libd.a.  Otherwise two dummy
# routines are found in libc.a.  (The printf and scanf need floating point
# for the %f formats, whether you use them or not.)

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS)
CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= $(LIBC)
#OBJECTS = fltpr.o strtod.o
OBJECTS = fphook.o

all:	$(LIBRARY)

$(LIBC): $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $(OBJECTS)
	$(RM) *.o

clean:
	rm -f *.o

fltpr.o: fltpr.c
	$(CC1) fltpr.c

strtod.o: strtod.c
	$(CC1) strtod.c

fphook.o: fphook.c
	$(CC1) fphook.c

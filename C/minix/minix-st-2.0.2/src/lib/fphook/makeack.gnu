# Makefile for lib/m68000/fphook.

# The ACK ANSI C compiler has an nice trick to reduce the size of programs
# that do not use floating point.  If a program uses floating point then the
# compiler generates an external reference to the label '_fp_hook'.  This makes
# the loader bring in the floating point printing and conversion routines
# '_f_print' and 'strtod' from the library libd.a.  Otherwise two dummy
# routines are found in libc.a.  (The printf and scanf need floating point
# for the %f formats, whether you use them or not.)

AR	= gcc-ar
CC	= gcc
CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE -I../../include $(XCFLAGS)
CC1	= $(CC) $(CFLAGS) -c

LIBC	= ../libc.olb
OBJECTS = $(LIBC)(fltpr.o) $(LIBC)(strtod.o)

all:	$(LIBC)

$(LIBC): $(OBJECTS)
	$(AR) rv $@ *.o
	rm *.o

clean:
	rm -f *.o

$(LIBC)(fltpr.o): fltpr.c
	$(CC1) fltpr.c

$(LIBC)(strtod.o): strtod.c
	$(CC1) strtod.c

$(LIBC)(fphook.o): fphook.c
	$(CC1) fphook.c

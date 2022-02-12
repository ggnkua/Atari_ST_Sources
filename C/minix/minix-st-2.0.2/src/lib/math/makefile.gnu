# Makefile for lib/math.

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS)

LIBRARY	= $(LIBC)
all:	$(LIBRARY)

clean:
	$(RM) *.o

OBJECTS	= \
	asin.o \
	atan.o \
	atan2.o \
	ceil.o \
	exp.o \
	fabs.o \
	floor.o \
	fmod.o \
	hugeval.o \
	isnan.o \
	ldexp.o \
	log.o \
	log10.o \
	pow.o \
	sin.o \
	sinh.o \
	sqrt.o \
	tan.o \
	tanh.o \

$(LIBRARY):	$(OBJECTS)
	$(AR) $(ARFLAGS) $@ *.o
	$(RM) *.o

#	frexp.o \
#	modf.o \

# Makefile for m68000/string

base = ../..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS) -DGNUOBJ
LIBRARY = $(LIBC)

# assembler routines in Minix 2.0.2 
SRC =	memcpy.s memchr.s memcmp.s memset.s strcat.s strchr.s \
	strcmp.s strcpy.s strcspn.s strlen.s \
	strncat.s strncmp.s strncpy.s strrchr.s memmove.s \
	index.s rindex.s bcmp.s bcopy.s bzero.s strnlen.s

# C routines in Minix 2.0.2 (ansi)
SRC2 =	strcspn.s strpbrk.s strspn.s strstr.s strtok.s strxfrm.s \
	strcoll.s strerror.s
	
OBJS =	memcpy.o memchr.o memcmp.o memset.o strcat.o strchr.o \
	strcmp.o strcpy.o strcspn.o strlen.o \
	strncat.o strncmp.o strncpy.o strrchr.o memmove.o \
	index.o rindex.o bcmp.o bcopy.o bzero.o strnlen.o

OBJS2 =	strcspn.o strpbrk.o strspn.o strstr.o strtok.o strxfrm.o \
	strcoll.o strerror.o
	
.s.o:
	../mot2mit.sh $*.s | $(CPP) $(CFLAGS) - | $(AS) -o $*.o -

all:	$(LIBRARY)

OBJECTS	= \
	memcpy.o \
	memchr.o \
	memcmp.o \
	memset.o \
	strcat.o \
	strchr.o \
	strcmp.o \
	strcpy.o \
	strcspn.o \
	strlen.o \
	strncat.o \
	strncmp.o \
	strncpy.o \
	strpbrk.o \
	strrchr.o \
	strspn.o \
	strstr.o \
	strtok.o \
	strxfrm.o \
	memmove.o \
	strcoll.o \
	strerror.o


$(LIBRARY): $(OBJECTS)
	$(AR) rv $(LIBRARY) *.o
#	$(RM) *.o

clean:
	$(RM) $(OBJS)

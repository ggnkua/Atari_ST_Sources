# Make Konfiguration fuer gcc-ack 32bit

# $(base) wird vom aufrufenden Makefile geliefert und
# verweist relativ auf die Wurzel des lib Quellenverzeichnisses (/usr/src/lib)

# Zielverzeichnis fuer die Bibliotheken
LIBDIR	= $(base)/libs/gnu-gnu-16

# Namen der Bibliotheken
LIBC	= $(LIBDIR)/libc16.a
CURSESLIB = $(LIBDIR)/libcurses16.a
EDITLINE = $(LIBDIR)/libedit16.a
CRT0	= $(LIBDIR)/crt016.o
INSTDIR	= /usr/local/gnu/lib

# Standard Include
INCLUDE = -I$(base)/../include

# Optimierung
OPTIMIZE = -O

# Angaben zur Intergergroesse, die nicht automatisch definiert sind
# Hier geht es vor allem um alte Assemblerquellen in m68000/f64
SIZESPEC = -mshort -D__MSHORT__
AS_SIZESPEC = -D__MSHORT__
CPP_STRING_FLAGS = -P -D__ACK__ -DGNUOBJ

# Basis Flags fuer Praeprozessor und C-Compiler, die immer gelten
XCPPFLAGS = -D_MINIX -D_POSIX_SOURCE $(AS_SIZESPEC) $(INCLUDE)
XCFLAGS = -D_MINIX -D_POSIX_SOURCE $(SIZESPEC) $(INCLUDE) $(OPTIMIZE)

# Programme
RM	= rm -f
CP	= cp
AR	= gnu-ar
ARFLAGS	= rsv
CC	= gcc
#CPP	= gcc-ack -E
CPP	= /usr/local/gnu/bin/gcc-cpp -P
#CPP	= /usr/lib/cpp
AS	= /usr/local/gnu/bin/gcc-as -mc68000
CPPAS	= cc

# Make Konfiguration fuer soz-ack 32bit

# $(base) wird vom aufrufenden Makefile geliefert und
# verweist relativ auf die Wurzel des lib Quellenverzeichnisses (/usr/src/lib)

# Zielverzeichnis fuer die Bibliotheken
LIBDIR	= $(base)/libs/soz-ack-32

# Namen der Bibliotheken
LIBC	= $(LIBDIR)/libc32.a
LIBD	= $(LIBDIR)/libd32.a
LIBY	= $(LIBDIR)/liby32.a
LIBSYS	= $(LIBDIR)/libsys32.a
CURSESLIB = $(LIBDIR)/libcurses32.a
EDITLINE = $(LIBDIR)/libedit32.a
CRT0	= $(LIBDIR)/crtso32.o
CFRT0	= $(LIBDIR)/cfrtso32.o
END	= $(LIBDIR)/end.o
LIBMSOZ	= $(LIBDIR)/libm32.a
INSTDIR	= /usr/lib

# Standard Include
INCPATH = $(base)/../../include
INCLUDE = -I$(INCPATH)

# Optimierung
OPTIMIZE = -O2

# Angaben zur Intergergroesse, die nicht automatisch definiert sind
# Hier geht es vor allem um alte Assemblerquellen in m68000/f64
SIZESPEC = --long-int #-D__MLONG__	# __MLONG__ wird von cc definiert
AS_SIZESPEC = -D__MLONG__ -DNOLONGS
CPP_STRING_FLAGS = -P -D__ACK__
CPP_RTS_FLAGS = -D__ACK__ -D_SETJMP_SAVES_REGS=1

# Basis Flags fuer Praeprozessor und C-Compiler, die immer gelten
XCPPFLAGS = -D_MINIX -D_POSIX_SOURCE $(AS_SIZESPEC) $(INCLUDE) $(MCFLAGS)
XCFLAGS = -D_MINIX -D_POSIX_SOURCE $(SIZESPEC) $(INCLUDE) $(OPTIMIZE) $(MCFLAGS)

# Programme
RM	= rm -f
CP	= cp
AR	= aal
ARFLAGS	= cr
CC	= acc
#CPP	= gcc-ack -E
#CPP	= /usr/local/gnu/bin/gcc-cpp 
CPP	= /usr/lib/cpp
AS	= /usr/bin/as -
CPPAS	= acc

# SPECIAL_AS wird fuer die Uebersetzung der internen Routinen des
# GCC benutzt. Liegen in Sozobon oder GNU Assembler vor (gesteuert
# durch -DSOZOBON), muessen hier als ACK-Out erzeugt werden, deswegen Jas.
SPECIAL_AS = ackjas
SPECIAL_AS_FLAGS = -DSOZOBON -D__MLONG__ -DNOLONGS

# Filter zur Erzeugung von MIT-Syntax aus Motorola Syntax
# Wird benoetigt fuer die Assemblerroutinen in m68000/rts, m68000/string
# und m68000/misc
#MOT2MIT = ../mot2mit.sh
MOT2MIT	= ../strip-comm.sh

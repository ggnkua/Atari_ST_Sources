# Make Konfiguration fuer gcc-ack 16bit

# $(base) wird vom aufrufenden Makefile geliefert und
# verweist relativ auf die Wurzel des lib Quellenverzeichnisses (/usr/src/lib)

# Zielverzeichnis fuer die Bibliotheken
LIBDIR	= $(base)/libs/gnu-ack-16

# Namen der Bibliotheken
LIBC	= $(LIBDIR)/libc.a
LIBD	= $(LIBDIR)/libd.a
LIBY	= $(LIBDIR)/liby.a
LIBSYS	= $(LIBDIR)/libsys.a
CURSESLIB = $(LIBDIR)/libcurses.a
EDITLINE = $(LIBDIR)/libedit.a
CRT0	= $(LIBDIR)/crt0.o
CFRT0	= $(LIBDIR)/cfrt0.o
END	= $(LIBDIR)/end.o
INSTDIR	= /usr/local/gnu/liba

# Standard Include
INCPATH	= $(base)/../../include
INCLUDE = -I$(base)/../../include

# Optimierung
OPTIMIZE = -O

# Angaben zur Intergergroesse, die nicht automatisch definiert sind
# Hier geht es vor allem um alte Assemblerquellen in m68000/f64
SIZESPEC = -D__MSHORT__
AS_SIZESPEC = -D__MSHORT__
CPP_STRING_FLAGS = -D__ACK__
CPP_RTS_FLAGS = -D__ACK__ -D_SETJMP_SAVES_REGS=1

# Basis Flags fuer Praeprozessor und C-Compiler, die immer gelten
XCPPFLAGS = -D_MINIX -D_POSIX_SOURCE $(SIZESPEC) $(INCLUDE) $(MCFLAGS)
XCFLAGS = -D_MINIX -D_POSIX_SOURCE $(SIZESPEC) $(INCLUDE) $(OPTIMIZE) $(MCFLAGS)

# Programme
RM	= rm -f
CP	= cp -p
AR	= aal
ARFLAGS	= cr
CC	= gcc-ack -mshort
#CPP	= gcc-ack -E
CPP	= /usr/local/gnu/bin/gcc-ack-cpp 
#CPP	= /usr/lib/cpp
AS	= as -
CPPAS	= cc

# SPECIAL_AS wird fuer die Uebersetzung der internen Routinen des
# GCC benutzt. Liegen in Sozobon oder GNU Assembler vor (gesteuert
# durch -DSOZOBON).
SPECIAL_AS = ackjas
SPECIAL_AS_FLAGS = -DSOZOBON -DGNUNAMES

# Filter zur Erzeugung von MIT-Syntax aus Motorola Syntax
# Wird benoetigt fuer die Assemblerroutinen in m68000/rts, m68000/string
# und m68000/misc
#MOT2MIT = ../mot2mit.sh
MOT2MIT	= ../strip-comm.sh

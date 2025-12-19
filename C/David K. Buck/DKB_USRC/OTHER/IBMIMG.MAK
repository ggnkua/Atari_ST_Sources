# IBM Makefile for DKB Utilities by David Buck and Aaron Collins
# This file is released to the public domain.
#
# Note for the IBM Version:
# Uses system environment variable LIB for the linker's .LIB file path.
# (Example:  Set LIB=C:\LIB)  The system environment variable CMODEL also
# may be defined for the memory model of the compiler.  We are using the
# "Large" memory model (Example Set CMODEL=L).  If you don't want to
# use the DOS environment variables, uncomment the following two lines:
#
# MAKE Macros and Such...
#

#CMODEL =L
#LIB    =c:\lib
CC  =cl

LINKER  =link /PACKCODE /FARCALL /EXEPACK

# Uncomment for 8086/8088 instruction set usage
#
CFLAGS  =/A$(CMODEL) /Gmsr /FPi /H32 /c /J

# Uncomment for 80186/80268 (incl. V20!) instruction set usage  [/Gmsr2]
#
#CFLAGS =/A$(CMODEL) /Gmsr2 /FPi87 /H32 /c /J

# If you have OS/2 to compile under, fix directory name and add this option
# to CFLAGS above...
#
# /B2 C:\msc\c2l.exe
#

# MS's NMAKE implicit rules for making an .OBJ file from a .C file...
#
.c.obj :
 $(CC) $(CFLAGS) /Oaxz $*.c

#

all:    dump2i24.exe combdump.exe catdump.exe dump2mtv.exe \
        halftga.exe gluetga.exe dump2raw.exe tga2dump.exe ip2dkb.exe

dump2i24.exe:   dump2i24.obj
    $(LINKER) dump2i24;

combdump.exe:   combdump.obj
    $(LINKER) combdump;

catdump.exe:    catdump.obj
    $(LINKER) catdump;

dump2mtv.exe:   dump2mtv.obj
    $(LINKER) dump2mtv;

halftga.exe:    halftga.obj
    $(LINKER) halftga;

gluetga.exe:    gluetga.obj
    $(LINKER) gluetga;

dump2raw.exe:   dump2raw.obj
    $(LINKER) dump2raw;

tga2dump.exe:   tga2dump.obj
    $(LINKER) tga2dump;

ip2dkb.exe: ip2dkb.obj
    $(LINKER) ip2dkb;

dump2i24.obj:   dump2i24.c
combdump.obj:   combdump.c
catdump.obj:    catdump.c
dump2mtv.obj:   dump2mtv.c
halftga.obj:    halftga.c
gluetga.obj:    gluetga.c
tga2dump.obj:   tga2dump.c
ip2dkb.obj:     ip2dkb.c

dump2raw.obj:   dump2raw.c
 $(CC) $(CFLAGS) /Oaxz /DIBM $*.c

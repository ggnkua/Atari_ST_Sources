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

#CMODEL	=L
#LIB	=c:\lib
CC	=cl
BC	=bc

LINKER	=link /PACKCODE /FARCALL /EXEPACK

# Uncomment for 8086/8088 instruction set usage
#
CFLAGS	=/A$(CMODEL) /Gmsr /FPi /H32 /c /J

# Uncomment for 80186/80268 (incl. V20!) instruction set usage	[/Gmsr2]
#
#CFLAGS	=/A$(CMODEL) /Gmsr2 /FPi87 /H32 /c /J

# If you have OS/2 to compile under, fix directory name and add this option
# to CFLAGS above...
#
# /B2 C:\msc\c2l.exe
#

# MS's NMAKE implicit rules for making an .OBJ file from a .C file...
#
.c.obj :
 $(CC) $(CFLAGS) /Oaxz $*.c

# MS's NMAKE implicit rules for making an .OBJ file from a .BAS file...
# (unless the "ON ERROR..." handler switches /e or /x are needed...)
#
.bas.obj :
 $(BC) $* /o;

#

all: sa2dkb.exe twister.exe dxf2dkb.exe 3d2-dkb.exe chem2dkb.exe shellgen.exe \
     lissajou.exe splitdkb.exe diamond.exe gear.exe tce.exe font2dat.exe \
	 anima.exe star.exe

sa2dkb.exe : sa2dkb.obj
	$(LINKER) sa2dkb;

sa2dkb.obj : sa2dkb.c

twister.exe : twister.obj
	$(LINKER) twister;
		
twister.obj : twister.c

dxf2dkb.exe : dxf2dkb.obj
	$(LINKER) dxf2dkb;

dxf2dkb.obj : dxf2dkb.c

3d2-dkb.exe : 3d2-dkb.obj
	$(LINKER) 3d2-dkb;

3d2-dkb.obj : 3d2-dkb.c

chem2dkb.exe : chem2dkb.obj
	$(LINKER) chem2dkb;

chem2dkb.obj : chem2dkb.bas

shellgen.exe : shellgen.obj
	$(LINKER) shellgen;

shellgen.obj : shellgen.bas

lissajou.exe : lissajou.obj
	$(LINKER) lissajou;

lissajou.obj : lissajou.bas
	$(BC) $* /e/o;

splitdkb.exe : splitdkb.obj
	$(LINKER) splitdkb;

splitdkb.obj : splitdkb.bas

diamond.exe : diamond.obj
	$(LINKER) diamond;

diamond.obj : diamond.bas

gear.exe : gear.obj
	$(LINKER) gear;

gear.obj : gear.bas

tce.exe : tce.obj
	$(LINKER) tce;

tce.obj : tce.bas
	$(BC) $* /x/o;

font2dat.exe : font2dat.obj
	$(LINKER) font2dat;

font2dat.obj : font2dat.bas

anima.exe : anima.obj
	$(LINKER) anima;

anima.obj : anima.bas

star.exe : star.obj
	$(LINKER) star;

star.obj : star.bas


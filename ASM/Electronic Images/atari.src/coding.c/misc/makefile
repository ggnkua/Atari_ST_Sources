# Makefile for my modified stevie, that can be compiled with PURE_C.
# Kees Lemmens; 13-aug-92; lemmens@dv.twi.tudelft.nl

# a few remarks :

#- PURE_C uses tos.h instead of osbind.h, so this code cannot compile without
#  a trick: create a file osbind.h in the compilers search path with only one
#  line : #include <tos.h> and everything will work.
#- For those who prefer the PURE_C shell : I also added a PURE_C project file
#  that can be used.
#- The TMPDIR variable must be specified: fastest solution is a RAM disk
#- You will have to adapt the SHELL variable (only if it points to the wrong
#  directory) if you want to use this makefile.
#

# My modifications to the original source (stvisrc.arc)

# vt100 mode is now supported without using TERMCAP (reads TERM variable)
# This is convenient on a modemline because most of the terminal progs work
# in vt100 mode. (if TERM is not set vt52 code is used)

# Cursconf is removed: this doesn;t work under a multitasking window system
# like mint ! It causes an irritating flashing cursor on the window screen.

# The slash that was added after the drivename is removed so that also
# filenames in the current directory could be specified.

# System scans for LINES and COLUMNS variables and uses them to determine
# the vi work screen.


.SUFFIXES: .o .c

PCC = d:\pure_c
PCL = $(PCC)\lib

CC    = $(PCC)\pcc.ttp
LD    = $(PCC)\plink.ttp
SHELL = d:\usr\bin\tcsh.ttp

CFLAGS  = -I$(PCC)\include -I$(PCC)\werk\h
LDLST	= $(TMPDIR)\libs.lst
LDFLAGS = -C=$(LDLST)
STDLIB  = $(PCL)\pcbgilib.lib $(PCL)\pcfltlib.lib $(PCL)\pcstdlib.lib
GEMLIB  = $(PCL)\pcextlib.lib $(PCL)\pctoslib.lib $(PCL)\pcgemlib.lib
LDLIBS  = $(PCL)\pcstart.o $(STDLIB) $(GEMLIB)

COMPILE = $(CC) $(CFLAGS) $<
LINK	= @echo -O=$@ $(LDLIBS) $*.o >$(LDLST); $(LD) $(LDFLAGS)
# Pure Linker truncates long commandlines, so we need a temporary file !!

.c.o:
	$(COMPILE)

.o:
	@echo -O=$@.ttp $(LDLIBS) $< >$(LDLST)
	$(LD) $(LDFLAGS)
.c:
	$(COMPILE)
	@echo -O=$*.ttp $(LDLIBS) $*.o >$(LDLST)
	$(LD) $(LDFLAGS)

.o.ttp .o.tos .o.prg:
	$(LINK)

.c.ttp .c.tos .c.prg:
	$(COMPILE)
	$(LINK)

OBJ = main.o edit.o linefunc.o normal.o window.o \
      cmdline.o hexchars.o misccmds.o help.o

stevie:	$(OBJ)
	@echo -O=stevie.ttp $(LDLIBS) $(OBJ) >$(LDLST)
	$(LD) $(LDFLAGS)

clean:
	rm -f *.o



















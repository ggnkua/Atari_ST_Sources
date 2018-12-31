###########################################################################
# This program is Copyright (C) 1991-1996 by C.H.Lindsey, University of   #
# Manchester.  (X)JOVETOOL is provided to you without charge, and with no #
# warranty.  You may give away copies of (X)JOVETOOL, including sources,  #
# provided that this notice is included in all the files, except insofar  #
# as a more specific copyright notices attaches to the file (x)jovetool.c #
###########################################################################

# Makefile for xjove (XView) and jovetool (SunView)
#
# This makefile may be invoked directly, or by the main JOVE Makefile.
# A number of macros may need to be adjusted for any particular environment.
# If the Makefile is invoked by the main JOVE Makefile, most
# customization will be inherited from that Makefile automatically:
# DEFINES, CC, OPTFLAGS, SYSDEFS, XINSTALL, BINDIR, and INSTALLFLAGS.
# The remaining macros that may need attention are XJLDFLAGS and XJCFLAGS.
# Under Solaris 2, make sure that your OPENWINHOME environment variable
# is set.

# Select optimization level (flags passed to compiling and linking steps).
# On most systems, -g for debugging, -O for optimization.
# On the official Sun ANSI C compiler and the standard System V Release 4
# compiler, adding -Xa -v will increase compiler checking.
OPTFLAGS = -O

# For SunView:
# DEFINES=-DSUNVIEW
DEFINES=

# for Solaris 2.x:
SYSDEFS=-DSYSVR4
# -i: ignore any LD_LIBRARY_PATH setting
# -L<dir>: add <dir> to library search path
# -R<dir[:dir]>: specify library search directories to dynamic linker
XJLDFLAGS= -i -L$$OPENWINHOME/lib -R$$OPENWINHOME/lib

# for Sun0s4.x:
# XJLDFLAGS=-L$$OPENWINHOME/lib
# SYSDEFS=-DSUNOS41

CFLAGS = $(OPTFLAGS) -I.. $(SYSDEFS) $(DEFINES)
XJCFLAGS = -I$$OPENWINHOME/include

BINDIR = /usr/local/bin

# The install commands of BSD and System V differ in unpleasant ways:
# -c: copy (BSD); -c dir: destination directory (SysV)
# -s: strip (BSD); -s: suppress messages (SysV)
# Also, the destination specification is very different.
# The result is that the System V install command must not be used.
# If you know that /bin/install is the BSD program, you can use it.
# "cp" will work reasonably well, but be aware that any links continue
# referencing the old file with new contents.

INSTALLFLAGS = # -g bin -o root

# to install executable files
XINSTALL=cp
#XINSTALL=/usr/ucb/install $(INSTALLFLAGS) -c -m 755 # -s

C_SRC = jovetool.c xjove.c jovewindows.c xjovewindows.c jovemenu.c \
	exts.h jovewindows.h mousemsg.h xjovewindows.h
ICONS = jove.icon jove.cursor copy.cursor cut.cursor paste.cursor
MISC = Makefile README
BACKUPS = $(C_SRC) $(ICONS) $(MISC)

default:		xjove

install:	installxjove

.filelist: $(BACKUPS)
	@ls $(BACKUPS) >.filelist

installxjove:	xjove
		$(XINSTALL) xjove $(BINDIR)/xjove

installjovetool:	jovetool
		$(XINSTALL) jovetool $(BINDIR)/jovetool

jovetool:	jovetool.o jovewindows.o
		$(CC) $(OPTFLAGS) $(LDFLAGS) -o jovetool jovetool.o jovewindows.o -lsuntool -lsunwindow -lpixrect

jovetool.o:	jovetool.c exts.h mousemsg.h $(ICONS)

jovewindows.o:	jovewindows.c jovemenu.c exts.h jovewindows.h ../tune.h

xjove:	xjove.o xjovewindows.o
		$(CC) $(OPTFLAGS) $(LDFLAGS) $(XJLDFLAGS) -o xjove xjove.o xjovewindows.o -lxview -lolgx -lX11

xjove.o:	xjove.c exts.h mousemsg.h $(ICONS)
		$(CC) $(CFLAGS) $(XJCFLAGS) -c xjove.c

xjovewindows.o:	xjovewindows.c jovemenu.c exts.h xjovewindows.h ../tune.h
		$(CC) $(CFLAGS) $(XJCFLAGS) -c xjovewindows.c

tags:	$(C_SRC)
	ctags -w $(C_SRC)

# override CIFLAGS with something like:
# CIFLAGS = -m'some reason for change' -u4.14.10.n -q

ciall:
	ci $(CIFLAGS) $(BACKUPS)

clean:
		rm -f a.out core *.o jovetool xjove '#'*~ .filelist

clobber:	clean
	rm -f *.orig *.rej

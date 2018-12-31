########################################################################
# This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  #
# provided to you without charge, and with no warranty.  You may give  #
# away copies of JOVE, including sources, provided that this notice is #
# included in all the files.                                           #
########################################################################

# wmake -f makefile.wat [<targets>]

# Makefile for Watcom C 10.0
#
# - supported targets:
#   + jjove.exe (build JOVE, but don't install it)
#   + jovedosx.zoo (build executable JOVE kit)
#   + jovedosx.zip (build executable JOVE kit)
#   + clean
#
# - to install, do the following:
#   + copy jjove.exe where you wish
#   + copy doc/cmds.doc to <SHAREDIR>/cmds.doc
#   + optional: copy some jove rc (none supplied) file to <SHAREDIR>/jove.rc

# Watcom Quirks:
# - "&" is used instead of "\" as the continuation character
# - .SYMBOLIC is needed it a rule doesn't create the target (eg. "clean")
# - .AUTODEPEND picks up dependencies recorded in .obj files
# - stack size is specified using -k
# - "*" at the start of a command will work around >128 char args.
#   For some reason, I couldn't get this to work, so I used *.obj
#   in the link step -- a bit fragile!
# - To get wild-card processing of command-line args, we must
#   link in wildargv.obj (which we must build -- see below).

# ===================================================================
# Jove configuration: default JOVE paths.
# Note that all these can be set from environment variables as well;
# see README.DOS for details.
#
# TMPDIR is where the tmp files get stored, usually /tmp or /usr/tmp.
# RECDIR is the directory in which RECOVER looks for JOVE's tempfiles.
# LIBDIR is for the PORTSRV and RECOVER programs.
# SHAREDIR is for online documentation, and the system-wide jove.rc file.
## BINDIR is where to put the executables JOVE and TEACHJOVE.
# DFLTSHELL is the default shell invoked by JOVE and TEACHJOVE.

TMPDIR = c:/tmp
RECDIR = c:/tmp
LIBDIR = c:/jove
SHAREDIR = $(LIBDIR)
# BINDIR = c:/jove
DFLTSHELL = command

# Compiler:

CC = wcc

# Watcom Compiler Flags:
#
# -d2		full symbolic debugging information
# -fo=<file_name> set object or preprocessor output file name
# -i=<directory>	another include directory
# -m{s,m,c,l,h}	memory model (Small,Medium,Compact,Large,Huge)
# -w<number>	set warning level number
# -wx		generate all warnings
# -zq		operate quietly (diagnostics are not suppressed)
#
# Same as UNIX:
# -d<name>[=text] precompilation #define name [text]
# NOTE: quotes around the macro body in a -D are actually taken as part
# of that body!!

# predefined automatically:__WATCOMC__

CFLAGS = -mm -wx -zq

# Linker:

LD = wcl

# Watcom wcl (Watcom Compile/Link) Link Flags:
#
# -fe=<file_name> set .exec output file name
# -kN		allocate N bytes for stack
# -x		make case of names significant

LDFLAGS = $(CFLAGS) -x

# ===================================================================
# Implicit rules.

.c.obj:	.AUTODEPEND
	$(CC) $(CFLAGS) $<

.obj.exe:
	$(LD) $(LDFLAGS) $<


OBJECTS = keys.obj commands.obj abbrev.obj ask.obj buf.obj c.obj &
	case.obj jctype.obj delete.obj extend.obj argcount.obj insert.obj &
	io.obj jove.obj macros.obj marks.obj misc.obj mouse.obj move.obj &
	paragrap.obj proc.obj re.obj reapp.obj scandir.obj list.obj &
	keymaps.obj util.obj vars.obj wind.obj fmt.obj disp.obj term.obj &
	fp.obj screen.obj msgetch.obj ibmpcdos.obj

HEADERS = abbrev.h argcount.h ask.h buf.h c.h case.h chars.h commands.h &
	jctype.h dataobj.h delete.h disp.h extend.h externs.h &
	fmt.h fp.h insert.h io.h iproc.h jove.h &
	keymaps.h list.h loadavg.h mac.h macros.h marks.h &
	misc.h mouse.h move.h paragraph.h proc.h &
	re.h reapp.h rec.h scandir.h screen.h &
	sysdep.h sysprocs.h temp.h term.h ttystate.h &
	tune.h util.h vars.h version.h wind.h

# This is what we really want to use, but Zortech's make doesn't work
# when a target appears in more than one rule.  So, as it stands,
# changing a header will *not* force recompilation :-(
#
# $(OBJECTS):	$(HEADERS)
#
# For this reason, we can only force the building of paths.h
# by adding it to the dependencies for explicit targets.
# In the hope that it is built soon enough, we put it at the front.

#	* $(LD) $(LDFLAGS) -k8196 -fe=$* $(OBJECTS)
jjove.exe:	paths.h $(OBJECTS) wildargv.obj
	$(LD) $(LDFLAGS) -k8196 -fm -fe=$* *.obj

jovedosx.zoo:	paths.h jjove.exe
	-del jovedosx.zoo
	-del jove.exe
	rename jjove.exe jove.exe
	zoo -add jovedosx.zoo jove.exe doc\cmds.doc doc\jove.man doc\jove.doc paths.h README.dos

jovedosx.zip:	paths.h jjove.exe
	-del jovedosx.zip
	-del jove.exe
	rename jjove.exe jove.exe
	pkzip -aP jovedosx.zip jove.exe doc\cmds.doc doc\jove.man doc\jove.doc paths.h README.dos

# Note that quotes are not stripped by the shell that will
# execute the recipe for paths.h

paths.h:	Makefile.wat
	echo /* Changes should be made in Makefile, not to this file! */ > paths.h
	echo $#define TMPDIR "$(TMPDIR)" >> paths.h
	echo $#define RECDIR "$(RECDIR)" >> paths.h
	echo $#define LIBDIR "$(LIBDIR)" >> paths.h
	echo $#define SHAREDIR "$(SHAREDIR)" >> paths.h
	echo $#define DFLTSHELL "$(DFLTSHELL)" >> paths.h

setmaps.exe:	commands.tab keys.txt setmaps.c
	wcl $(CFLAGS) setmaps.c -fe=setmaps.exe
	del setmaps.obj

keys.c:	setmaps.exe keys.txt
	setmaps < keys.txt > keys.c

# Note: it may be necessary to manually copy the source file from
# the distribution CDROM to the installation.  On the CDROM, the
# file's path is \watcom\src\startup\wildargv.c.
# At least with some versions, wildargv.c does not accept tabs as
# argument delimiters.  This should be fixed.
# Change line 82 from:
#	    while( *p == ' ' ) ++p;	/* skip over blanks */
# to:
#	    while( *p == ' ' || *p == '\t' ) ++p;	/* skip over blanks */
# Change line 103 from:
#		    if( *p == ' ' ) break;
# to:
#		    if( *p == ' ' || *p == '\t' ) break;

wildargv.obj:	$(%WATCOM)\src\startup\wildargv.c
	$(CC) $(CFLAGS) $(%WATCOM)\src\startup\wildargv.c

clean:	.SYMBOLIC
	-del *.obj
	-del *.exe
	-del *.bak
	-del *.map
	-del keys.c
	-del paths.h

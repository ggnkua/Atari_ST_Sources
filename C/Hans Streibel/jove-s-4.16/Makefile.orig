########################################################################
# This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  #
# provided to you without charge, and with no warranty.  You may give  #
# away copies of JOVE, including sources, provided that this notice is #
# included in all the files.                                           #
########################################################################

# TMPDIR is where the tmp files get stored, usually /tmp or /usr/tmp.  If
# your system, or reboot, removes files in /tmp, but not those in /usr/tmp,
# then it makes sense to make TMPDIR be /usr/tmp.
# But if you want to recover buffers on system crashes, you should create a
# directory that doesn't get cleaned upon reboot, and use that instead.
# You would probably want to clean out that directory periodically with
# /etc/cron.
# RECDIR is the directory in which RECOVER looks for JOVE's tempfiles.
#
# JOVEHOME is the directory in which pieces of JOVE are kept.  It is only used
#	in the default definitions of SHAREDIR, LIBDIR, BINDIR, and MANDIR.
# SHAREDIR is for online documentation, and the system-wide jove.rc file.
# LIBDIR is for the PORTSRV and RECOVER programs.
# BINDIR is where to put the executables JOVE and TEACHJOVE.
# MANDIR is where the manual pages go for JOVE, RECOVER and TEACHJOVE.
# MANEXT is the extension for the man pages, e.g., jove.1 or jove.l or jove.m.
# DFLTSHELL is the default shell invoked by JOVE and TEACHJOVE.
#
# If they don't exist, this makefile will try to create the directories
# LIBDIR and SHAREDIR.  All others must already exist.

SHELL = /bin/sh
TMPDIR = /usr/tmp
RECDIR = /usr/preserve

JOVEHOME = /usr/local
SHAREDIR = $(JOVEHOME)/lib/jove
LIBDIR = $(JOVEHOME)/lib/jove
BINDIR = $(JOVEHOME)/bin
MANDIR = $(JOVEHOME)/man/man$(MANEXT)
MANEXT = 1
DFLTSHELL = /bin/csh

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

# to install text files
TINSTALL=cp
#TINSTALL=/usr/ucb/install $(INSTALLFLAGS) -c -m 644

# These should all just be right if the above ones are.
# You will confuse JOVE if you move anything from LIBDIR or SHAREDIR.

JOVE = $(BINDIR)/jove
TEACHJOVE = $(BINDIR)/teachjove
RECOVER = $(LIBDIR)/recover
PORTSRV = $(LIBDIR)/portsrv
JOVERC = $(SHAREDIR)/jove.rc
TERMSDIR = $(SHAREDIR)
CMDS.DOC = $(SHAREDIR)/cmds.doc
TEACH-JOVE = $(SHAREDIR)/teach-jove
JOVEM = $(MANDIR)/jove.$(MANEXT)
TEACHJOVEM = $(MANDIR)/teachjove.$(MANEXT)
XJOVEM = $(MANDIR)/xjove.$(MANEXT)
JOVETOOLM = $(MANDIR)/jovetool.$(MANEXT)

# Select optimization level (flags passed to compiling and linking steps).
# On most systems, -g for debugging, -O for optimization.
# On the official Sun ANSI C compiler and the standard System V Release 4
# compiler, adding -Xa -v will increase compiler checking.
# On DEC OSF/1, -std1 -O

OPTFLAGS = -O

# For making dependencies under BSD systems
DEPENDFLAG = -M
# or, using the official Sun ANSI C compiler
# DEPENDFLAG = -xM

# Select the right libraries for your system.
#	2.10BSD:LIBS = -ltermcap
#	v7:	LIBS = -ltermcap
#	4.1BSD:	LIBS = -ltermcap -ljobs
#	4.2BSD:	LIBS = -ltermcap
#	4.3BSD:	LIBS = -ltermcap
#	SysV Rel. 2: LIBS = -lcurses
#	SCO Xenix: LIBS = -ltermcap -lx
#	SCO: LIBS = -lcurses
#	AIX on the R6000s: LIBS = -lcurses -ltermcap -ls
#	MIPS: LIBS = -ltermcap

LIBS = -ltermcap

#	2.10BSD:LDFLAGS =
#	v7:	LDFLAGS =
#	4.1BSD:	LDFLAGS =
#	4.2BSD:	LDFLAGS =
#	4.3BSD:	LDFLAGS =
#	SysV Rel. 2: LDFLAGS = -Ml
#	SCO Xenix: LDFLAGS = -Ml -F 3000
#	SCO Unix: LDFLAGS =
#	AIX Unix: LDFLAGS = -bloadmap:$@.map # only if loadmap
#
# To optimize the use of the address spaces, add to the LDFLAGS:
#	PDP-11 with separate I&D: -i
#	PDP-11 without separate I&D: -n


LDFLAGS =

# define a symbol for your OS if it hasn't got one.  See sysdep.h.
# Jove has very few defaults, you will almost certainly need to define
# *something*.
#
#	Apple A/UX on macIIs		SYSDEFS=-DA_UX
#	BSD4.2,4.3			SYSDEFS=-DBSD4
#	BSDI, 386BSD, BSD4.4		SYSDEFS=-DBSDPOSIX
#	Consensys V4			SYSDEFS=-DSYSVR4 -DGRANTPT_BUG
#	DEC OSF R1.3MK			SYSDEFS=-DSYSVR4
#	DEC OSF/1 V1.3			SYSDEFS=-BSDPOSIX -DNO_TIOCREMOTE -DNO_TIOCSIGNAL
#	DEC OSF/1 V2.0 and later	SYSDEFS=-DSYSVR4
#	DEC Ultrix 4.2			SYSDEFS=-DBSDPOSIX
#	DEC Ultrix 4.3			SYSDEFS=-DBSDPOSIX -DJVDISABLE=255
#	DG AViiON 5.3R4			SYSDEFS=-DSYSVR4 -DBSD_SIGS
#	HP/UX 8 or 9			SYSDEFS=-DHPUX -Ac
#	IBM RS6000s			SYSDEFS=-DAIX3_2
#	Irix 3.3-4.0.5			SYSDEFS=-DIRIX -DIRIX4
#	Irix 5.0 onwards		SYSDEFS=-DIRIX -prototypes
#	LINUX				SYSDEFS=-DBSDPOSIX
#	MIPS RiscOS4.x			SYSDEFS=-systype bsd43 -DBSD4
#	SCO Unix			SYSDEFS=-DSCO
#	SunOS3.x			SYSDEFS=-DSUNOS3
#	SunOS4.0*			SYSDEFS=-DSUNOS40
#	SunOS4.1*			SYSDEFS=-DSUNOS41
#	SunOS5.0/Solaris 2.0		SYSDEFS=-DSYSVR4 -DGRANTPT_BUG
#	SunOS5.[1234]/Solaris 2.[1234]	SYSDEFS=-DSYSVR4
#	Sys III, Sys V R 2,3		SYSDEFS=-DSYSV
#	Sys V Release 4.0		SYSDEFS=-DSYSVR4 -DGRANTPT_BUG
#	Sys V Release 4.?		SYSDEFS=-DSYSVR4
#
# Some systems based on System V release 4 have a bug affecting interactive
# processes.  This bug can be worked around by defining GRANTPT_BUG.
# Read the explanation of GRANTPT_BUG in sysdep.doc.
#
# Some of the MIPS based Ultrix (upto 4.2 at least), RiscOS and Irix (up to
# 3.3 at least) also need -DMIPS_CC_BUG.
#
# Some (all?) versions of the HPUX C compiler have a bug in handling forward
# struct tag declarations.  Using the -Ac flag in place of -Ae will avoid
# this problem (and reduce the compiler's error checking, unfortunately).
#
# Add -DUSE_EXIT if you're profiling or using purify (this causes Jove
# to exit using exit(), instead of _exit()).
#
# You can just say 'make SYSDEFS=-Dwhatever' on these systems.

SYSDEFS =

# for SCO Xenix, set
#	MEMFLAGS = -Mle
#	CFLAGS = -LARGE -O -F 3000 -K -Mle  (say -Mle2 for an 80286)

CFLAGS = $(OPTFLAGS) $(SYSDEFS)

# For SYSVR4 (/usr/ucb/cc will NOT work because of setjmp.h):
# CC = /usr/bin/cc
# To use the SunPro compiler under SunOS 4.n:
# CC = acc
# To use the official Sun compiler under Solaris 2.n:
# CC = /opt/SUNWspro/bin/cc
# For DG AViiON, expect compile errors unless you use the GNU C compiler:
# CC=gcc

# Load invocation of cc.
# LDCC = purify $(CC)

LDCC = $(CC)

# For cross compiling Jove, set CC to the cross compiler, and LOCALCC
# to the local C compiler. LOCALCC will be used for compiling setmaps,
# which is run as part of the compilation to generate the keymaps.
# Set LOCALCFLAGS and LOCALLDFLAGS appropriately too. For Xenix, note
# that LOCALCFLAGS must be set to $(MEMFLAGS)

LOCALCC = $(CC)
LOCALCFLAGS = $(CFLAGS)	# $(MEMFLAGS)
LOCALLDFLAGS = $(LDFLAGS)

# Objects are grouped into overlays for the benefit of (at least) 2.xBSD.

BASESEG = commands.o keys.o argcount.o ask.o buf.o jctype.o delete.o \
	  disp.o insert.o io.o jove.o marks.o misc.o re.o \
	  screen.o termcap.o unix.o util.o vars.o list.o keymaps.o \
	  mouse.o
OVLAY1 = abbrev.o rec.o paragraph.o fmt.o
OVLAY2 = c.o wind.o fp.o move.o
OVLAY3 = extend.o macros.o
OVLAY4 = iproc.o reapp.o
OVLAY5 = proc.o scandir.o term.o case.o

OBJECTS = $(BASESEG) $(OVLAY1) $(OVLAY2) $(OVLAY3) $(OVLAY4) $(OVLAY5)

NROFF = nroff
TROFF = troff -Tpost
TROFFPOST = | /usr/lib/lp/postscript/dpost - >troff.out.ps

MANUALS = $(JOVEM) $(TEACHJOVEM) $(XJOVEM) $(JOVETOOLM)

C_SRC = commands.c commands.tab abbrev.c argcount.c ask.c buf.c c.c case.c jctype.c \
	delete.c disp.c extend.c fp.c fmt.c insert.c io.c iproc.c \
	jove.c list.c macros.c marks.c misc.c move.c paragraph.c \
	proc.c re.c reapp.c rec.c scandir.c screen.c term.c termcap.c unix.c \
	util.c vars.c vars.tab wind.c msgetch.c mac.c keymaps.c ibmpcdos.c \
	mouse.c win32.c

SOURCES = $(C_SRC) portsrv.c recover.c setmaps.c teachjove.c

HEADERS = abbrev.h argcount.h ask.h buf.h c.h case.h chars.h commands.h \
	jctype.h dataobj.h delete.h disp.h extend.h externs.h \
	fmt.h fp.h insert.h io.h iproc.h jove.h \
	keymaps.h list.h mac.h macros.h marks.h \
	misc.h mouse.h move.h paragraph.h proc.h \
	re.h reapp.h rec.h recover.h resource.h scandir.h screen.h \
	select.h sysdep.h sysprocs.h temp.h term.h ttystate.h \
	tune.h util.h vars.h version.h wind.h

DOCTERMS =	doc/jove.rc.sun doc/keychart.sun \
	doc/jove.rc.sun-cmd doc/keychart.sun-cmd \
	doc/jove.rc.vt100 doc/keychart.vt100 \
	doc/jove.rc.wyse doc/keychart.wyse \
	doc/jove.rc.xterm doc/keychart.xterm \
	doc/jove.rc.z29 doc/keychart.z29 \
	doc/jove.rc.3022 doc/keychart.3022 \
	doc/keychart. \
	doc/XTermresource

DOCS =	doc/README doc/teach-jove doc/jove.qref \
	doc/intro.nr doc/cmds.macros.nr doc/cmds.nr doc/contents.nr \
	doc/jove.nr doc/teachjove.nr doc/xjove.nr doc/jovetool.nr \
	doc/jove.rc doc/example.rc $(DOCTERMS)

MISC =	Makefile Makefile.bcc Makefile.msc Makefile.wat Makefile.zor \
	README README.dos README.mac README.w32 sysdep.doc tune.doc

SUPPORT = teachjove.c recover.c setmaps.c portsrv.c keys.txt \
	menumaps.txt mjovers.Hqx jjoveico.uue jjove.rc

BACKUPS = $(HEADERS) $(C_SRC) $(SUPPORT) $(MISC)

all:	jjove recover teachjove portsrv doc/cmds.doc

jjove:	$(OBJECTS)
	$(LDCC) $(LDFLAGS) $(OPTFLAGS) -o jjove $(OBJECTS) $(LIBS)
	@-size jjove

# For 2.xBSD: link jove as a set of overlays.  Not tested recently.

ovjove:	$(OBJECTS)
	ld $(LDFLAGS) $(OPTFLAGS) -X /lib/crt0.o \
		-Z $(OVLAY1) \
		-Z $(OVLAY2) \
		-Z $(OVLAY3) \
		-Z $(OVLAY4) \
		-Z $(OVLAY5) \
		-Y $(BASESEG) \
		-o jjove $(LIBS) -lc
	@-size jjove

# portsrv is only needed if IPROCS are implemented using PIPEPROCS
# Making PORTSRVINST null will supress building and installing portsrv.

PORTSRVINST=$(PORTSRV)

portsrv:	portsrv.o
	$(CC) $(LDFLAGS) $(OPTFLAGS) -o portsrv portsrv.o $(LIBS)

recover:	recover.o
	$(CC) $(LDFLAGS) $(OPTFLAGS) -o recover recover.o $(LIBS)

teachjove:	teachjove.o
	$(CC) $(LDFLAGS) $(OPTFLAGS) -o teachjove teachjove.o $(LIBS)

# don't optimize setmaps.c because it produces bad code in some places
# for some reason

setmaps:	setmaps.o
	$(LOCALCC) $(LOCALLDFLAGS) -o setmaps setmaps.o

setmaps.o:	setmaps.c
	$(LOCALCC) $(LOCALCFLAGS) -c setmaps.c

keys.c:	setmaps keys.txt
	./setmaps < keys.txt > keys.c

keys.o:	keys.c tune.h sysdep.h jove.h keymaps.h dataobj.h commands.h

paths.h: Makefile
	-rm -f paths.h
	@echo "/* Changes should be made in Makefile, not to this file! */" > paths.h
	@echo "" >> paths.h
	@echo \#define TMPDIR \"$(TMPDIR)\" >> paths.h
	@echo \#define RECDIR \"$(RECDIR)\" >> paths.h
	@echo \#define LIBDIR \"$(LIBDIR)\" >> paths.h
	@echo \#define SHAREDIR \"$(SHAREDIR)\" >> paths.h
	@echo \#define DFLTSHELL \"$(DFLTSHELL)\" >> paths.h

makexjove:
	( cd xjove ; make CC="$(CC)" OPTFLAGS="$(OPTFLAGS)" SYSDEFS="$(SYSDEFS)" $(TOOLMAKEEXTRAS) xjove )

installxjove:
	( cd xjove ; make CC="$(CC)" OPTFLAGS="$(OPTFLAGS)" SYSDEFS="$(SYSDEFS)" XINSTALL="$(XINSTALL)" BINDIR="$(BINDIR)" INSTALLFLAGS="$(INSTALLFLAGS)" $(TOOLMAKEEXTRAS) installxjove )

makejovetool:
	( cd xjove ; make CC="$(CC)" OPTFLAGS="$(OPTFLAGS)" SYSDEFS="$(SYSDEFS)" DEFINES=-DSUNVIEW $(TOOLMAKEEXTRAS) jovetool )

installjovetool:
	( cd xjove ; make CC="$(CC)" OPTFLAGS="$(OPTFLAGS)" SYSDEFS="$(SYSDEFS)" DEFINES=-DSUNVIEW XINSTALL="$(XINSTALL)" BINDIR="$(BINDIR)" INSTALLFLAGS="$(INSTALLFLAGS)" $(TOOLMAKEEXTRAS) installjovetool )

install: $(LIBDIR) $(SHAREDIR) \
	 $(TEACH-JOVE) $(CMDS.DOC) $(TERMSDIR)docs \
	 $(PORTSRVINST) $(RECOVER) $(JOVE) $(TEACHJOVE) $(MANUALS)
	$(TINSTALL) doc/jove.rc $(JOVERC)
	@echo See the README about changes to /etc/rc or /etc/rc.local
	@echo so that the system recovers jove files on reboot after a crash

$(LIBDIR)::
	test -d $(LIBDIR) || mkdir $(LIBDIR)

$(SHAREDIR)::
	test -d $(SHAREDIR) || mkdir $(SHAREDIR)

$(TEACH-JOVE): doc/teach-jove
	$(TINSTALL) doc/teach-jove $(TEACH-JOVE)

doc/cmds.doc:	doc/cmds.macros.nr doc/cmds.nr
	$(NROFF) doc/cmds.macros.nr doc/cmds.nr > doc/cmds.doc

doc/jove.man:	doc/intro.nr doc/cmds.nr
	( cd doc; tbl intro.nr | $(NROFF) -ms - cmds.nr >jove.man )

troff-man:
	( cd doc; tbl intro.nr | $(TROFF) -ms - cmds.nr contents.nr $(TROFFPOST) )

$(CMDS.DOC): doc/cmds.doc
	$(TINSTALL) doc/cmds.doc $(CMDS.DOC)

$(JOVERC): doc/jove.rc
	$(TINSTALL) doc/jove.rc $(JOVERC)

$(TERMSDIR)docs: $(DOCTERMS)
	$(TINSTALL) $(DOCTERMS) $(TERMSDIR)

$(PORTSRV): portsrv
	$(XINSTALL) portsrv $(PORTSRV)

$(RECOVER): recover
	$(XINSTALL) recover $(RECOVER)

$(JOVE): jjove
	$(XINSTALL) jjove $(JOVE)

$(TEACHJOVE): teachjove
	$(XINSTALL) teachjove $(TEACHJOVE)

$(JOVEM): doc/jove.nr
	@sed -e 's;<TMPDIR>;$(TMPDIR);' \
	     -e 's;<LIBDIR>;$(LIBDIR);' \
	     -e 's;<SHAREDIR>;$(SHAREDIR);' \
	     -e 's;<SHELL>;$(DFLTSHELL);' doc/jove.nr > /tmp/jove.nr
	$(TINSTALL) /tmp/jove.nr $(JOVEM)
	rm /tmp/jove.nr

# doc/jove.doc is the formatted manpage (only needed by DOS)
# Building it should be like building $(JOVEM) except that we
# don't know what to substitue for <TMPDIR> etc. because they
# are not fixed yet, and because we must do the formatting.

doc/jove.doc: doc/jove.nr
	$(NROFF) -man doc/jove.nr >doc/jove.doc

$(TEACHJOVEM): doc/teachjove.nr
	@sed -e 's;<TMPDIR>;$(TMPDIR);' \
	     -e 's;<LIBDIR>;$(LIBDIR);' \
	     -e 's;<SHAREDIR>;$(SHAREDIR);' \
	     -e 's;<SHELL>;$(DFLTSHELL);' doc/teachjove.nr > /tmp/teachjove.nr
	$(TINSTALL) /tmp/teachjove.nr $(TEACHJOVEM)
	rm /tmp/teachjove.nr

$(XJOVEM): doc/xjove.nr
	$(TINSTALL) doc/xjove.nr $(XJOVEM)

$(JOVETOOLM): doc/jovetool.nr
	@sed -e 's;<MANDIR>;$(MANDIR);' \
	     -e 's;<MANEXT>;$(MANEXT);' doc/jovetool.nr > /tmp/jovetool.nr
	$(TINSTALL) /tmp/jovetool.nr $(JOVETOOLM)
	rm /tmp/jovetool.nr

echo:
	@echo $(C-FILES) $(HEADERS)

lint:
	lint -n $(C_SRC) keys.c
	@echo Done

tags:	$(C_SRC) $(HEADERS)
	ctags -w $(C_SRC) $(HEADERS)

# .filelist is a trick to get around a make limit:
# the list of files is too long to fit in a command generated by make
# The actual contents of the file depend only on Makefile, but by
# adding extra dependencies, dependants of .filelist can have shorter
# dependency lists.  Note: since we have no list of xjove files,
# we alway force a make of xjove/.filelist.  This forces .filelist
# to be rebuilt every time it is needed.

.filelist:	$(BACKUPS) $(DOCS) .xjfilelist
	@ls $(BACKUPS) >.filelist
	@ls $(DOCS) >>.filelist
	@sed -e 's=^=xjove/=' xjove/.filelist >>.filelist

.xjfilelist:
	@( cd xjove ; make .filelist )

# override CIFLAGS with something like:
# CIFLAGS="-m'some reason for change' -u4.14.10.n -q"

ciall:	.filelist
	ci $(CIFLAGS) `cat .filelist`

coall:	.filelist
	co $(BACKUPS) `cat .filelist`

jove.shar:	.filelist
	shar .filelist > jove.shar

tar:
	@tar cvf - `find . -type f -print | \
		egrep -v '(,v|\.o|jjove|portsrv|setmaps|~)$$' | \
		sort`

backup.Z: .filelist
	rm -f backup backup.Z
	tar cf backup `cat .filelist`
	compress backup

backup.gz: .filelist
	rm -f backup backup.gz
	tar cf backup `cat .filelist`
	gzip backup

tape-backup:	.filelist
	tar cf /dev/rst8 `cat .filelist`

# System V sum can be made to match BSD with a -r flag.
# To get this effect, override with SUM = sum -r
SUM = sum

checksum:	.filelist
	$(SUM) `cat .filelist`

# MSDOS isn't a full-fledged development environment.
# Preparing a distribution for MSDOS involves discarding some things
# and pre-building others.  All should have \n converted to CR LF
# but zoo doesn't do this.
# From SUPPORT: only setmaps.c and keys.txt [would like teachjove.c, recover.c]
# From MISC: all but Makefile and README.mac
# Preformatted documentation. [would like a joverc]
# tags

DOSSRC = $(HEADERS) $(C_SRC) setmaps.c keys.txt \
	Makefile.bcc Makefile.msc Makefile.wat Makefile.zor \
	README README.dos README.w32 sysdep.doc tune.doc \
	jjoveico.uue jjove.rc \
	doc/cmds.doc doc/jove.man doc/jove.doc tags

jovedoss.zoo:	$(DOSSRC) jjove.ico
	-rm -f jovedoss.zoo
	zoo a jovedoss.zoo $(DOSSRC) jjove.ico

jovedoss.zip:	$(DOSSRC) jjove.ico
	-rm -f jovedoss.zip
	zip -k jovedoss.zip jjove.ico -l $(DOSSRC)

jjove.ico:	jjoveico.uue
	uudecode jjoveico.uue

touch:
	touch $(OBJECTS)

clean:
	rm -f a.out core *.o keys.c jjove portsrv recover setmaps \
		teachjove paths.h \#* *~ make.log *.map jjove.ico \
		doc/cmds.doc doc/jove.man doc/jove.doc doc/troff.out.ps \
		jjove.pure_* tags ID .filelist

cleanall: clean
	( cd xjove ; make clean )

clobber: clean
	rm -f *.orig *.rej
	( cd xjove ; make clobber )

# This version only works under 4.3BSD
dependbsd:
	@echo '"make depend" only works under 4.3BSD'
	sed -e '/^# DO NOT DELETE THIS LINE/q' Makefile >Makefile.new
	for i in ${SOURCES} ; do \
		$(CC) ${CFLAGS} ${DEPENDFLAG} $$i | \
		awk ' /[/]usr[/]include/ { next } \
			{ if ($$1 != prev) \
		    { if (rec != "") print rec; rec = $$0; prev = $$1; } \
		    else { if (length(rec $$2) > 78) { print rec; rec = $$0; } \
		    else rec = rec " " $$2 } } \
		    END { print rec } ' >>Makefile.new; \
	done
	echo '# DEPENDENCIES MUST END AT END OF FILE' >>Makefile.new
	echo '# IF YOU PUT STUFF HERE IT WILL GO AWAY' >>Makefile.new
	echo '# see "make depend" above' >>Makefile.new
	@echo 'New makefile is in "Makefile.new".  Move it to "Makefile".'

# This version should work with any UNIX
# It records all dependencies, including ones that are #ifdef'ed out.
# It assumes that only jove.h and tune.h include other headers

depend:
	@sed -e '/^# DO NOT DELETE THIS LINE/q' Makefile >Makefile.new
	for i in tune.h jove.h ${SOURCES} ; do \
		( ( echo "$$i:"; sed -n -e 's/^#[ 	]*include[ 	]*"\([^"]*\)".*/\1/p' $$i ) | \
		sed -e 's/^jove\.h$$/$$(JOVE_H)/' -e 's/^tune\.h$$/$$(TUNE_H)/' \
			-e 's/^jove\.h:$$/JOVE_H = jove.h/' -e 's/^tune\.h:$$/TUNE_H = tune.h/' \
			-e 's/\.c:$$/.o:/' | \
		tr "\012" "\040" ; echo ) | sed -e 's/ $$//' -e '/:$$/d' >>Makefile.new ; \
	done
	@echo '# DEPENDENCIES MUST END AT END OF FILE' >>Makefile.new
	@echo '# IF YOU PUT STUFF HERE IT WILL GO AWAY' >>Makefile.new
	@echo '# see "make depend" above' >>Makefile.new
	@if cmp -s Makefile Makefile.new ; \
		then echo '*** Makefile is already up to date' ; \
		else echo '*** New makefile is in "Makefile.new".  Move it to "Makefile".' ; \
	fi

# DO NOT DELETE THIS LINE -- "make depend" uses it
TUNE_H = tune.h sysdep.h
JOVE_H = jove.h $(TUNE_H) buf.h io.h dataobj.h keymaps.h argcount.h util.h externs.h
commands.o: $(JOVE_H) jctype.h extend.h macros.h mouse.h abbrev.h c.h case.h commands.h delete.h disp.h insert.h sysprocs.h iproc.h marks.h misc.h move.h paragraph.h proc.h reapp.h wind.h commands.tab
abbrev.o: $(JOVE_H) fp.h jctype.h abbrev.h ask.h commands.h delete.h insert.h disp.h fmt.h move.h wind.h
argcount.o: $(JOVE_H) jctype.h
ask.o: $(JOVE_H) jctype.h chars.h disp.h fp.h scandir.h screen.h ask.h delete.h insert.h extend.h fmt.h marks.h move.h mac.h
buf.o: $(JOVE_H) jctype.h disp.h ask.h extend.h fmt.h insert.h macros.h marks.h move.h sysprocs.h proc.h wind.h fp.h iproc.h mac.h
c.o: $(JOVE_H) re.h c.h jctype.h disp.h delete.h insert.h fmt.h marks.h misc.h move.h paragraph.h
case.o: $(JOVE_H) disp.h case.h jctype.h marks.h move.h
jctype.o: $(JOVE_H) jctype.h
delete.o: $(JOVE_H) jctype.h disp.h delete.h insert.h marks.h move.h
disp.o: $(JOVE_H) jctype.h chars.h fp.h disp.h ask.h extend.h fmt.h insert.h sysprocs.h iproc.h move.h macros.h screen.h term.h wind.h mac.h
extend.o: $(JOVE_H) fp.h jctype.h chars.h commands.h disp.h re.h ask.h extend.h fmt.h insert.h move.h sysprocs.h proc.h vars.h mac.h
fp.o: $(JOVE_H) fp.h jctype.h disp.h fmt.h mac.h
fmt.o: $(JOVE_H) chars.h fp.h jctype.h disp.h extend.h fmt.h mac.h
insert.o: $(JOVE_H) jctype.h list.h chars.h disp.h abbrev.h ask.h c.h delete.h insert.h fmt.h macros.h marks.h misc.h move.h paragraph.h screen.h sysprocs.h proc.h wind.h re.h
io.o: $(JOVE_H) list.h fp.h jctype.h disp.h scandir.h ask.h fmt.h insert.h marks.h sysprocs.h proc.h wind.h rec.h mac.h re.h temp.h
iproc.o: $(JOVE_H) re.h jctype.h disp.h fp.h sysprocs.h iproc.h ask.h extend.h fmt.h insert.h marks.h move.h proc.h wind.h select.h ttystate.h
jove.o: $(JOVE_H) fp.h jctype.h chars.h disp.h re.h reapp.h sysprocs.h rec.h ask.h extend.h fmt.h macros.h marks.h mouse.h paths.h proc.h screen.h term.h version.h wind.h iproc.h select.h mac.h
list.o: $(JOVE_H) list.h
macros.o: $(JOVE_H) jctype.h fp.h chars.h disp.h ask.h commands.h macros.h extend.h fmt.h
marks.o: $(JOVE_H) fmt.h marks.h disp.h
misc.o: $(JOVE_H) jctype.h disp.h ask.h c.h delete.h insert.h extend.h fmt.h marks.h misc.h move.h paragraph.h
move.o: $(JOVE_H) re.h chars.h jctype.h disp.h move.h screen.h
paragraph.o: $(JOVE_H) jctype.h disp.h delete.h insert.h fmt.h marks.h misc.h move.h paragraph.h re.h
proc.o: $(JOVE_H) jctype.h fp.h re.h disp.h sysprocs.h ask.h delete.h extend.h fmt.h insert.h iproc.h marks.h misc.h move.h proc.h wind.h
re.o: $(JOVE_H) re.h jctype.h ask.h disp.h fmt.h marks.h
reapp.o: $(JOVE_H) fp.h re.h jctype.h chars.h disp.h ask.h fmt.h marks.h reapp.h wind.h mac.h
rec.o: $(JOVE_H) fp.h sysprocs.h rec.h fmt.h recover.h
scandir.o: $(JOVE_H) scandir.h
screen.o: $(JOVE_H) fp.h chars.h jctype.h disp.h extend.h fmt.h term.h mac.h screen.h wind.h
term.o: $(JOVE_H) term.h fp.h
termcap.o: $(JOVE_H) term.h disp.h fmt.h fp.h jctype.h screen.h
unix.o: $(JOVE_H) fp.h chars.h term.h ttystate.h util.h
util.o: $(JOVE_H) jctype.h disp.h fp.h ask.h chars.h fmt.h insert.h macros.h marks.h move.h rec.h mac.h
vars.o: $(JOVE_H) extend.h vars.h abbrev.h ask.h c.h jctype.h disp.h insert.h sysprocs.h iproc.h mac.h mouse.h paragraph.h proc.h re.h reapp.h rec.h screen.h term.h ttystate.h wind.h vars.tab
wind.o: $(JOVE_H) chars.h disp.h ask.h extend.h commands.h mac.h reapp.h wind.h screen.h
msgetch.o: $(JOVE_H) chars.h disp.h
mac.o: $(TUNE_H) $(JOVE_H) mac.h ask.h chars.h disp.h extend.h fp.h commands.h fmt.h marks.h misc.h move.h screen.h scandir.h term.h vars.h version.h wind.h
keymaps.o: $(JOVE_H) list.h fp.h jctype.h chars.h disp.h re.h ask.h commands.h macros.h extend.h fmt.h screen.h vars.h sysprocs.h iproc.h
ibmpcdos.o: $(JOVE_H) fp.h chars.h screen.h term.h
mouse.o: $(JOVE_H) disp.h misc.h ask.h delete.h fmt.h insert.h marks.h move.h wind.h term.h jctype.h mouse.h xjove/mousemsg.h
win32.o: $(JOVE_H) fp.h chars.h screen.h disp.h
portsrv.o: $(JOVE_H) sysprocs.h iproc.h
recover.o: $(JOVE_H) temp.h sysprocs.h rec.h paths.h recover.h scandir.c jctype.h
setmaps.o: $(JOVE_H) chars.h commands.h vars.h commands.tab vars.tab
teachjove.o: $(TUNE_H) paths.h
# DEPENDENCIES MUST END AT END OF FILE
# IF YOU PUT STUFF HERE IT WILL GO AWAY
# see "make depend" above

# Makefile for GNU C compiler.
#   Copyright (C) 1987, 1988 Free Software Foundation, Inc.

#	$Id: Makefile,v 1.30 92/04/03 20:50:34 pete Exp $

#This file is part of GNU CC.

#GNU CC is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 1, or (at your option)
#any later version.

#GNU CC is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with GNU CC; see the file COPYING.  If not, write to
#the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.


# Variables that exist for you to override.
# See below for how to change them for certain systems.

#CFLAGS = -g $(XCFLAGS)
CFLAGS = $(XCFLAGS) -O
CC = cc
#CC = /usr/local/gnu/bin/gcc
BISON = bison
BISONFLAGS = -v
AR = ar
SHELL = /bin/sh
# on sysV, define this as cp.
INSTALL = install -c

# for use in rt-test
DSPINSTALL = mv

# Compiler to use for compiling gnulib.
# OLDCC should not be the GNU C compiler.
OLDCC = cc

# CFLAGS for use with OLDCC, for compiling gnulib.
# NOTE: -O does not work on some Unix systems!
# On them, you must take it out.
CCLIBFLAGS=-O

# CFLAGS for use with OLDCC, for compiling hard-params.
HARD_PARAMS_FLAGS=

# Directory where sources are, from where we are.
srcdir = .
# Directory in which to put the executable for the command `gcc'
bindir = $(prefix)/usr/local/bin
# Directory in which to put the subprograms used by the compiler.
libdir = $(prefix)/usr/local
# Directory in which to put man pages.
mandir = $(prefix)/usr/local/man/man1
# Number to put in man-page filename.
manext = 1

# Additional system libraries to link with.
CLIB=

# Change this to a null string if obstacks are installed in the
# system library.
OBSTACK=obstack.o

# Directory to link to, when using the target `maketest'.
DIR = ../gcc

# End of variables for you to override.


# Variables you should change for certain systems.

# These are what you would need on HPUX:
# CFLAGS = -Wc,-Ns2000 -Wc,-Ne700 -Wc,-Np300
# If you are using the GNU assembler and linker on HPUX,
# add -I../hp-include to CFLAGS.
# -g is desirable in CFLAGS, but a compiler bug in HPUX version 5
# bites whenever tree.def, rtl.def or machmode.def is included
# (ie., on every source file).
# If you have a floating point accelerator, you might want -lsetjmp as well.
# CCLIBFLAGS = -Wc,-Ns2000 -Wc,-Ne700 -O
# HARD_PARAMS_FLAGS = -Wc,-Ns2000 -Wc,-Ne700
# For CCLIBFLAGS you might want to specify the switch that
# forces only 68000 instructions to be used.

# On the Sequent, you may need to set CCLIBFLAG to empty.

# On the 3b1, this line may help you compile gnulib
# if you already have a prior version of gcc installed.
# CCLIBFLAGS = -B/usr/local/lib/gcc- -tp -Wp,-traditional

# If you are making gcc for the first time, and if you are compiling it with
# a non-gcc compiler, and if your system doesn't have a working alloca() in any
# of the standard libraries (as is true for HP/UX or Genix),
# then get alloca.c from GNU Emacs and un-comment the following line:
# ALLOCA = alloca.o
# But don't do that if compiling using GCC.

# If your system has alloca() in /lib/libPW.a, un-comment the following line:
# CLIB= -lPW

# On a pyramid, you need to uncomment the following line:
# CLIB = -lc /usr/.attlib/libPW.a

# If your system's malloc() routine fails for any reason (as it does on
# certain versions of Genix), try getting the files
# malloc.c and getpagesize.h from GNU Emacs and un-comment the following line:
# MALLOC = malloc.o

# If you are running GCC on an Apollo (SR10.x),
# go into a Berkeley environment and use this:
# CFLAGS = -g -A nansi -A cpu,3000 -A runtype,bsd4.3 -A systype,any -DSHORT_ENUM_BUG
# (Says vasta@apollo.com.)


# Dependency on obstack, alloca, malloc or whatever library facilities
# are not installed in the system libraries.
LIBDEPS= $(OBSTACK) $(ALLOCA) $(MALLOC)

# How to link with both our special library facilities
# and the system's installed libraries.
LIBS = $(OBSTACK) $(ALLOCA) $(MALLOC) $(CLIB)

# Specify the directories to be searched for header files.
# Both . and srcdir are used, in that order,
# so that tm.h and config.h will be found in the compilation
# subdirectory rather than in the source directory.
INCLUDES = -I. -I$(srcdir) -I$(srcdir)/config
SUBDIR_INCLUDES = -I.. -I../$(srcdir) -I../$(srcdir)/config

# Always use -I$(srcdir)/config when compiling.
.c.o:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(INCLUDES) $<

# Language-specific object files for C.
C_OBJS = c-parse.tab.o c-decl.o c-typeck.o c-convert.o

# Language-specific object files for C++.
# (These are not yet released.)
CPLUS_OBJS = cplus-parse.o cplus-decl.o cplus-typeck.o \
   cplus-cvt.o cplus-search.o cplus-lex.o \
   cplus-class.o cplus-init.o cplus-method.o

# Language-independent object files.
OBJS = toplev.o version.o tree.o print-tree.o stor-layout.o fold-const.o \
 rtl.o rtlanal.o expr.o stmt.o expmed.o explow.o optabs.o varasm.o \
 symout.o dbxout.o sdbout.o emit-rtl.o insn-emit.o \
 integrate.o jump.o cse.o loop.o flow.o stupid.o combine.o \
 regclass.o local-alloc.o global-alloc.o reload.o reload1.o caller-save.o \
 insn-peep.o final.o recog.o insn-recog.o insn-extract.o insn-output.o

# Files to be copied away after each stage in building.
STAGE_GCC=gcc
STAGESTUFF = *.o insn-flags.h insn-config.h insn-codes.h \
 insn-output.c insn-recog.c insn-emit.c insn-extract.c insn-peep.c \
 stamp-flags.h stamp-config.h stamp-codes.h \
 stamp-output.c stamp-recog.c stamp-emit.c stamp-extract.c stamp-peep.c \
 genemit genoutput genrecog genextract genflags gencodes genconfig genpeep \
 cc1 cpp cccp # cc1plus

# Members of gnulib.
LIBFUNCS = _eprintf _builtin_new _builtin_New _builtin_del \
   _umulsi3 _mulsi3 _udivsi3 _divsi3 _umodsi3 _modsi3 \
   _lshrsi3 _lshlsi3 _ashrsi3 _ashlsi3 \
   _divdf3 _muldf3 _negdf2 _adddf3 _subdf3 _cmpdf2 \
   _fixunsdfsi _fixdfsi _floatsidf _truncdfsf2 _extendsfdf2 \
   _addsf3 _negsf2 _subsf3 _cmpsf2 _mulsf3 _divsf3

# Library members defined in gnulib2.c.
LIB2FUNCS = _adddi3 _subdi3 _muldi3 _divdi3 _moddi3 _udivdi3 _umoddi3 _negdi2 \
    _anddi3 _iordi3 _xordi3 _lshrdi3 _lshldi3 _ashldi3 _ashrdi3 _one_cmpldi2  \
    _bdiv _cmpdi2 _ucmpdi2 _fixunsdfdi _fixdfdi _floatdidf _varargs

# Header files that are made available to programs compiled with gcc.
USER_H = stddef.h stdarg.h assert.h va-*.h limits.h

# The files that "belong" in CONFIG_H are deliberately omitted
# because having them there would not be useful in actual practice.
# All they would do is cause complete recompilation every time
# one of the machine description files is edited.
# That may or may not be what one wants to do.
# If it is, rm *.o is an easy way to do it.
CONFIG_H = config.h tm.h
# CONFIG_H =
RTL_H = rtl.h rtl.def machmode.def
TREE_H = tree.h real.h tree.def machmode.def
CPLUS_TREE_H = $(TREE_H) cplus-tree.h c-tree.h

# Note that dependencies on obstack.h are not written
# because that file is not part of GCC.
# Dependencies on gvarargs.h are not written
# because all that file does, when not compiling with GCC,
# is include the system varargs.h.

all: config.status gnulib gcc cc1 cpp float.h gnulib2 # cc1plus

dsp: config.status gcc cc1 cpp		# DSP

lang-c: config.status gnulib gcc cc1 cpp gnulib2
# lang-cplus: config.status gnulib gcc cc1plus cpp gnulib2

config.status:
	@echo You must configure gcc.  Look at the INSTALL file for details.
	@false

doc: $(srcdir)/cpp.info $(srcdir)/gplus.info $(srcdir)/gcc.info

compilations: ${OBJS}

gcc: gcc.o version.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o gccnew gcc.o version.o $(LIBS)
# Go via `gccnew' to avoid `file busy' if $(CC) is `gcc'.

cc1: $(C_OBJS) $(OBJS) $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o cc1 $(C_OBJS) $(OBJS) $(LIBS)

cc1plus: $(CPLUS_OBJS) $(OBJS) $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o cc1plus $(CPLUS_OBJS) $(OBJS) $(LIBS)

#Library of arithmetic subroutines
# Don't compile this with gcc!
# (That would cause most arithmetic functions to call themselves.)
gnulib: gnulib.c $(CONFIG_H)
	-rm -f stamp-gnulib2
	rm -f tmpgnulib gnulib; \
	for name in $(LIBFUNCS); \
	do \
	  echo $${name}; \
	  rm -f $${name}.c; \
	  cp $(srcdir)/gnulib.c $${name}.c; \
	  $(OLDCC) $(CCLIBFLAGS) $(INCLUDES) -c -DL$${name} $${name}.c; \
	  $(AR) qc tmpgnulib $${name}.o; \
	  rm -f $${name}.[co]; \
	done
	if [ -f /usr/bin/ranlib -o -f /bin/ranlib ] ; then ranlib tmpgnulib ;fi
# Actually build it in tmpgnulib above, then rename now,
# so that gnulib itself remains nonexistent if compilation is aborted.
	mv tmpgnulib gnulib
# On HPUX, if you are working with the GNU assembler and linker,
# the previous two command lines must be replaced with the following line.
# No change is needed here if you are using the HPUX assembler and linker.
#	../hp-bin/hpxt tmpgnulib gnulib

gnulib2: stamp-gnulib2;
stamp-gnulib2: gnulib2.c gnulib cc1 gcc cpp $(CONFIG_H)
	for name in $(LIB2FUNCS); \
	do \
	  echo $${name}; \
	  ./gcc -B./ -fstrength-reduce -O $(INCLUDES) $(GNULIB2_CFLAGS) -c -DL$${name} $(srcdir)/gnulib2.c -o $${name}.o; \
	  $(AR) rc gnulib $${name}.o; \
	  rm -f $${name}.o; \
	done
	if [ -f /usr/bin/ranlib -o -f /bin/ranlib ] ; then  ranlib gnulib ;fi
# On HPUX, if you are working with the GNU assembler and linker,
# the previous line must be commented out.
# No change is needed here if you are using the HPUX assembler and linker.
	touch stamp-gnulib2

float.h:
# Originally, we used `make' rather than $(MAKE), to avoid propagating
# a CC=gcc command option.  However, since hard-params is now made
# with $(OLDCC) explicitly, this is no longer important.
# However, $(MAKE) fails on some systems where it isn't defined.
# `make' has the disadvantage of sometimes running the system's make,
# instead of GNU make.  And the system's make might not support VPATH.
# However, the compilation of hard-params should not need to use VPATH,
# due to the explicit use of `$(srcdir)'.
	make hard-params
	-./hard-params -f > float.h

# Compile hard-params with standard cc.  It avoids some headaches.
hard-params: hard-params.o
	$(OLDCC) $(HARD_PARAMS_FLAGS) $(LDFLAGS) hard-params.o -o $@
hard-params.o: $(srcdir)/hard-params.c
	-cp $(srcdir)/hard-params.c . > /dev/null 2>&1
	$(OLDCC) $(HARD_PARAMS_FLAGS) $(CPPFLAGS) -DNO_SC -c hard-params.c

# C language specific files.

c-parse.tab.o : $(srcdir)/c-parse.tab.c $(CONFIG_H) $(TREE_H) c-parse.h c-tree.h input.h
	$(CC) $(CFLAGS) $(CPPFLAGS) $(INCLUDES) -c $(srcdir)/c-parse.tab.c
$(srcdir)/c-parse.tab.c : $(srcdir)/c-parse.y
	$(BISON) $(BISONFLAGS) $(srcdir)/c-parse.y -o $@

c-decl.o : c-decl.c $(CONFIG_H) $(TREE_H) c-tree.h c-parse.h flags.h
c-typeck.o : c-typeck.c $(CONFIG_H) $(TREE_H) c-tree.h flags.h
c-convert.o : c-convert.c $(CONFIG_H) $(TREE_H)

# C++ language specific files.

cplus-parse.o : $(srcdir)/cplus-parse.c $(CONFIG_H) $(CPLUS_TREE_H) flags.h
	$(CC) -c $(CFLAGS) $(INCLUDES) \
  -DPARSE_OUTPUT=\"$(PWD)/cplus-parse.output\" \
  `echo $(srcdir)/cplus-parse.c | sed 's,^\./,,'`

$(srcdir)/cplus-parse.h $(srcdir)/cplus-parse.c : $(srcdir)/cplus-parse.y
	@echo expect 49 shift/reduce conflicts and 4 reduce/reduce conflicts
	$(BISON) $(BISONFLAGS) -d -o $(srcdir)/cplus-parse.c $(srcdir)/cplus-parse.y

cplus-lex.o : cplus-lex.c $(CONFIG_H) $(CPLUS_TREE_H) $(srcdir)/cplus-parse.h
cplus-decl.o : cplus-decl.c $(CONFIG_H) $(CPLUS_TREE_H) flags.h
cplus-typeck.o : cplus-typeck.c $(CONFIG_H) $(CPLUS_TREE_H) flags.h
cplus-class.o : cplus-class.c $(CONFIG_H) $(CPLUS_TREE_H)
cplus-init.o : cplus-init.c $(CONFIG_H) $(CPLUS_TREE_H)
cplus-method.o : cplus-method.c $(CONFIG_H) $(CPLUS_TREE_H)
cplus-cvt.o : cplus-cvt.c $(CONFIG_H) $(CPLUS_TREE_H)
cplus-search.o : cplus-search.c $(CONFIG_H) $(CPLUS_TREE_H)
new-method.o : new-method.c $(CONFIG_H) $(CPLUS_TREE_H)

# Language-independent files.

gcc.o: gcc.c $(CONFIG_H)
	$(CC) $(CFLAGS) $(INCLUDES) \
  -DSTANDARD_STARTFILE_PREFIX=\"$(libdir)/dsp/lib/\" \
  -DSTANDARD_EXEC_PREFIX=\"$(libdir)/dsp/bin/gcc-\" -c \
  `echo $(srcdir)/gcc.c | sed 's,^\./,,'`

version.o: version.c
obstack.o: obstack.c

tree.o : tree.c $(CONFIG_H) $(TREE_H) flags.h
print-tree.o : print-tree.c $(CONFIG_H) $(TREE_H)
stor-layout.o : stor-layout.c $(CONFIG_H) $(TREE_H) $(RTL_H)
fold-const.o : fold-const.c $(CONFIG_H) $(TREE_H)
toplev.o : toplev.c $(CONFIG_H) $(TREE_H) flags.h input.h

rtl.o : rtl.c $(CONFIG_H) $(RTL_H)

rtlanal.o : rtlanal.c $(CONFIG_H) $(RTL_H)

varasm.o : varasm.c $(CONFIG_H) $(TREE_H) $(RTL_H) flags.h expr.h \
   insn-codes.h hard-reg-set.h
stmt.o : stmt.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h  \
   insn-flags.h insn-config.h insn-codes.h expr.h regs.h hard-reg-set.h recog.h
expr.o : expr.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h  \
   insn-flags.h insn-codes.h expr.h insn-config.h recog.h
expmed.o : expmed.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h  \
   insn-flags.h insn-codes.h expr.h insn-config.h recog.h
explow.o : explow.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h expr.h insn-codes.h
optabs.o : optabs.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h  \
   insn-flags.h insn-codes.h expr.h insn-config.h recog.h
symout.o : symout.c $(CONFIG_H) $(TREE_H) $(RTL_H) symseg.h gdbfiles.h
dbxout.o : dbxout.c $(CONFIG_H) $(TREE_H) $(RTL_H) flags.h
sdbout.o : sdbout.c $(CONFIG_H) $(TREE_H) $(RTL_H)

emit-rtl.o : emit-rtl.c $(CONFIG_H) $(RTL_H) regs.h insn-config.h real.h

integrate.o : integrate.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h expr.h \
   insn-flags.h insn-codes.h

jump.o : jump.c $(CONFIG_H) $(RTL_H) flags.h regs.h
stupid.o : stupid.c $(CONFIG_H) $(RTL_H) regs.h hard-reg-set.h

cse.o : cse.c $(CONFIG_H) $(RTL_H) regs.h hard-reg-set.h flags.h real.h
loop.o : loop.c $(CONFIG_H) $(RTL_H) insn-config.h insn-codes.h \
   regs.h hard-reg-set.h recog.h flags.h expr.h
flow.o : flow.c $(CONFIG_H) $(RTL_H) basic-block.h regs.h hard-reg-set.h
combine.o : combine.c $(CONFIG_H) $(RTL_H) flags.h  \
   insn-config.h regs.h basic-block.h recog.h
regclass.o : regclass.c $(CONFIG_H) $(RTL_H) hard-reg-set.h flags.h \
   basic-block.h regs.h insn-config.h recog.h 
local-alloc.o : local-alloc.c $(CONFIG_H) $(RTL_H) flags.h basic-block.h regs.h \
   hard-reg-set.h insn-config.h recog.h
global-alloc.o : global-alloc.c $(CONFIG_H) $(RTL_H) flags.h  \
   basic-block.h regs.h hard-reg-set.h insn-config.h

reload.o : reload.c $(CONFIG_H) $(RTL_H) flags.h \
   reload.h recog.h hard-reg-set.h insn-config.h regs.h
reload1.o : reload1.c $(CONFIG_H) $(RTL_H) flags.h  \
   reload.h regs.h hard-reg-set.h insn-config.h basic-block.h recog.h
caller-save.o : caller-save.c $(CONFIG_H) $(RTL_H) flags.h \
   reload.h regs.h hard-reg-set.h insn-config.h basic-block.h recog.h
final.o : final.c $(CONFIG_H) $(RTL_H) flags.h regs.h recog.h conditions.h \
   gdbfiles.h insn-config.h real.h output.h
recog.o : recog.c $(CONFIG_H) $(RTL_H)  \
   regs.h recog.h hard-reg-set.h insn-config.h real.h

# Normally this target is not used; but it is used if you
# define ALLOCA=alloca.o.  In that case, you must get a suitable alloca.c
# from the GNU Emacs distribution.
# Note some machines won't allow $(CC) without -S on this source file.
alloca.o:	alloca.c
	$(CC) $(CFLAGS) -S `echo $(srcdir)/alloca.c | sed 's,^\./,,'`
	as alloca.s -o alloca.o

# Now the source files that are generated from the machine description.

.PRECIOUS: insn-config.h insn-flags.h insn-codes.h \
  insn-emit.c insn-recog.c insn-extract.c insn-output.c insn-peep.c

# The following pair of rules has this effect:
# genconfig is run only if the md has changed since genconfig was last run;
# but the file insn-config.h is touched only when its contents actually change.

# Each of the other insn-* files is handled by a similar pair of rules.

insn-config.h: stamp-config.h ;
stamp-config.h : md genconfig
	./genconfig md > tmp-config.h
	$(srcdir)/move-if-change tmp-config.h insn-config.h
	touch stamp-config.h

insn-flags.h: stamp-flags.h ;
stamp-flags.h : md genflags
	./genflags md > tmp-flags.h
	$(srcdir)/move-if-change tmp-flags.h insn-flags.h
	touch stamp-flags.h

insn-codes.h: stamp-codes.h ;
stamp-codes.h : md gencodes
	./gencodes md > tmp-codes.h
	$(srcdir)/move-if-change tmp-codes.h insn-codes.h
	touch stamp-codes.h

insn-emit.o : insn-emit.c $(CONFIG_H) $(RTL_H) expr.h real.h insn-codes.h \
  insn-config.h insn-flags.h
	$(CC) $(CFLAGS) $(INCLUDES) -c insn-emit.c

insn-emit.c: stamp-emit.c ;
stamp-emit.c : md genemit
	./genemit md > tmp-emit.c
	$(srcdir)/move-if-change tmp-emit.c insn-emit.c
	touch stamp-emit.c

insn-recog.o : insn-recog.c $(CONFIG_H) $(RTL_H) insn-config.h real.h recog.h
	$(CC) $(CFLAGS) $(INCLUDES) -c insn-recog.c

insn-recog.c: stamp-recog.c ;
stamp-recog.c : md genrecog
	./genrecog md > tmp-recog.c
	$(srcdir)/move-if-change tmp-recog.c insn-recog.c
	touch stamp-recog.c

insn-extract.o : insn-extract.c $(CONFIG_H) $(RTL_H)
	$(CC) $(CFLAGS) $(INCLUDES) -c insn-extract.c

insn-extract.c: stamp-extract.c ;
stamp-extract.c : md genextract
	./genextract md > tmp-extract.c
	$(srcdir)/move-if-change tmp-extract.c insn-extract.c
	touch stamp-extract.c

insn-peep.o : insn-peep.c $(CONFIG_H) $(RTL_H) regs.h real.h
	$(CC) $(CFLAGS) $(INCLUDES) -c insn-peep.c

insn-peep.c: stamp-peep.c ;
stamp-peep.c : md genpeep
	./genpeep md > tmp-peep.c
	$(srcdir)/move-if-change tmp-peep.c insn-peep.c
	touch stamp-peep.c

insn-output.o : insn-output.c $(CONFIG_H) $(RTL_H) regs.h real.h conditions.h \
    hard-reg-set.h insn-config.h insn-flags.h output.h aux-output.c
	$(CC) $(CFLAGS) $(INCLUDES) -c insn-output.c

insn-output.c: stamp-output.c ;
stamp-output.c : md genoutput
	./genoutput md > tmp-output.c
	$(srcdir)/move-if-change tmp-output.c insn-output.c
	touch stamp-output.c

# Now the programs that generate those files.
# $(CONFIG_H) is omitted from the deps of the gen*.o
# because these programs don't really depend on anything 
# about the target machine.  They do depend on config.h itself,
# since that describes the host machine.

genconfig : genconfig.o rtl.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o genconfig genconfig.o rtl.o $(LIBS)

genconfig.o : genconfig.c $(RTL_H) config.h

genflags : genflags.o rtl.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o genflags genflags.o rtl.o $(LIBS)

genflags.o : genflags.c $(RTL_H) config.h

gencodes : gencodes.o rtl.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o gencodes gencodes.o rtl.o $(LIBS)

gencodes.o : gencodes.c $(RTL_H) config.h

genemit : genemit.o rtl.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o genemit genemit.o rtl.o $(LIBS)

genemit.o : genemit.c $(RTL_H) config.h

genrecog : genrecog.o rtl.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o genrecog genrecog.o rtl.o $(LIBS)

genrecog.o : genrecog.c $(RTL_H) config.h

genextract : genextract.o rtl.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o genextract genextract.o rtl.o $(LIBS)

genextract.o : genextract.c $(RTL_H) config.h

genpeep : genpeep.o rtl.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o genpeep genpeep.o rtl.o $(LIBS)

genpeep.o : genpeep.c $(RTL_H) config.h

genoutput : genoutput.o rtl.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o genoutput genoutput.o rtl.o $(LIBS)

genoutput.o : genoutput.c $(RTL_H) config.h

# Making the preprocessor
cpp: cccp
	-rm -f cpp
	ln cccp cpp
cccp: cccp.o cexp.o version.o $(LIBDEPS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o cccp cccp.o cexp.o version.o $(LIBS)
cexp.o: $(srcdir)/cexp.c $(CONFIG_H)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(INCLUDES) -c $(srcdir)/cexp.c
$(srcdir)/cexp.c: $(srcdir)/cexp.y
	$(BISON) -o $(srcdir)/cexp.c $(srcdir)/cexp.y
cccp.o: cccp.c $(CONFIG_H)
	$(CC) $(CFLAGS) $(INCLUDES) \
          -DGCC_INCLUDE_DIR=\"$(libdir)/dsp/include\" \
          -DGPLUSPLUS_INCLUDE_DIR=\"$(libdir)/g++-include\" \
	  -c `echo $(srcdir)/cccp.c | sed 's,^\./,,'`

$(srcdir)/cpp.info: $(srcdir)/cpp.texinfo
	makeinfo `echo $(srcdir)/cpp.texinfo | sed 's,^\./,,'`

$(srcdir)/gplus.info: $(srcdir)/gplus.texinfo
	makeinfo `echo $(srcdir)/gplus.texinfo | sed 's,^\./,,'`

$(srcdir)/gcc.info: $(srcdir)/gcc.texinfo
	makeinfo `echo $(srcdir)/gcc.texinfo | sed 's,^\./,,'`

# gnulib is not deleted because deleting it would be inconvenient
# for most uses of this target.
clean:
	-rm -f $(STAGESTUFF) $(STAGE_GCC)
# Delete the temp files made in the course of building gnulib.
	-rm -f tmpgnulib
	for name in $(LIBFUNCS); do rm -f $${name}.c; done
	-rm -f stamp-*.[ch] tmp-*
	-rm -f *.s *.s[0-9] *.co *.greg *.lreg *.combine *.flow *.cse *.jump *.rtl *.tree *.loop *.dbr *.jump2
	-rm -f core float.h hard-params
	-rm -f *.exp *.exe *.map *.obj

# Like clean but also delete the links made to configure gcc.
# Also removes gnulib, since that is desirable if you are changing cpus.
cleanconfig: clean
	-rm -f tm.h aux-output.c config.h md config.status gnulib stamp-gnulib2

# Get rid of every file that's generated from some other file (except INSTALL).
realclean: pcclean cleanconfig 
	-rm -f cpp.aux cpp.cps cpp.fns cpp.info cpp.kys cpp.pgs cpp.tps cpp.vrs
#	-rm -f cplus-parse.tab.c cplus-parse.output
	-rm -f c-parse.tab.c c-parse.output c-parse.tab.output
	-rm -f gnulib cexp.c TAGS 
	-rm -f cpp.info* cpp.?? cpp.??s cpp.log cpp.toc cpp.*aux
	-rm -f gcc.info* gcc.?? gcc.??s gcc.log gcc.toc gcc.*aux
	-rm -f gplus.info* gplus.?? gplus.??s gplus.log gplus.toc gplus.*aux
	-rm -f *.dvi

# Copy the DSP files into directories where they will be run.
installdsp56: gccnew cc1 cpp
	$(DSPINSTALL) gccnew $(INSTALLDIR)/g56k
	$(DSPINSTALL) cc1 $(INSTALLDIR)/g56-cc1
	$(DSPINSTALL) cpp $(INSTALLDIR)/mcpp

installdsp96: gccnew cc1 cpp
	$(DSPINSTALL) gccnew $(INSTALLDIR)/g96k
	$(DSPINSTALL) cc1 $(INSTALLDIR)/g96-cc1
	$(DSPINSTALL) cpp $(INSTALLDIR)/mcpp

# Copy the files into directories where they will be run.
install: all
	-mkdir $(libdir)
	-if [ -f cc1 ] ; then $(INSTALL) cc1 $(libdir)/gcc-cc1 ;fi
	-if [ -f cc1plus ] ; then $(INSTALL) cc1plus $(libdir)/gcc-cc1plus ;fi
	$(INSTALL) gnulib $(libdir)/gcc-gnulib
	-if [ -f /usr/bin/ranlib ] ; then (cd $(libdir); ranlib gcc-gnulib) ;fi
	$(INSTALL) cpp $(libdir)/gcc-cpp
	$(INSTALL) gcc $(bindir)
	-mkdir $(libdir)/gcc-include
	-chmod ugo+rx $(libdir)/gcc-include
	for file in $(USER_H); do \
	     for eachfile in  $(srcdir)/$${file} ; do \
		$(INSTALL) $${eachfile} $(libdir)/gcc-include; \
	     done ; done
	$(INSTALL) float.h $(libdir)/gcc-include/float.h
	$(INSTALL) $(srcdir)/gvarargs.h $(libdir)/gcc-include/varargs.h
	$(INSTALL) $(srcdir)/gcc.1 $(mandir)/gcc.$(manext)

# do make -f ../gcc/Makefile maketest DIR=../gcc
# in the intended test directory to make it a suitable test directory.
maketest:
	ln -s $(DIR)/*.[chy] .
	ln -s $(DIR)/config .
	ln -s $(DIR)/*.def .
	-rm -f =*
	ln -s $(DIR)/.gdbinit .
	-ln -s $(DIR)/bison.simple .
	ln -s $(DIR)/config.gcc .
	ln -s $(DIR)/move-if-change .
# The then and else were swapped to avoid a problem on Ultrix.
	if [ ! -f Makefile ] ; then ln -s $(DIR)/Makefile . ; else false; fi
	-rm tm.h aux-output.c config.h md
	make clean
# You must then run config.gcc to set up for compilation.

bootstrap: all force
	$(MAKE) stage1
	$(MAKE) CC="stage1/gcc -Bstage1/" CFLAGS="-O $(CFLAGS)" libdir=$(libdir)
	$(MAKE) stage2
	$(MAKE) CC="stage2/gcc -Bstage2/" CFLAGS="-O $(CFLAGS)" libdir=$(libdir)

bootstrap2: force
	$(MAKE) CC="stage1/gcc -Bstage1/" CFLAGS="-O $(CFLAGS)" libdir=$(libdir)
	$(MAKE) stage2
	$(MAKE) CC="stage2/gcc -Bstage2/" CFLAGS="-O $(CFLAGS)" libdir=$(libdir)

bootstrap3: force
	$(MAKE) CC="stage2/gcc -Bstage2/" CFLAGS="-O $(CFLAGS)" libdir=$(libdir)

# Copy the object files from a particular stage into a subdirectory.
stage1: force
	-mkdir stage1
	-mv $(STAGESTUFF) $(STAGE_GCC) stage1
	-rm -f stage1/gnulib
	-ln gnulib stage1 || (cp gnulib stage1 && ranlib stage1/gnulib)

stage2: force
	-mkdir stage2
	-mv $(STAGESTUFF) $(STAGE_GCC) stage2
	-rm -f stage2/gnulib
	-ln gnulib stage2 || (cp gnulib stage2 && ranlib stage2/gnulib)

stage3: force
	-mkdir stage3
	-mv $(STAGESTUFF) $(STAGE_GCC) stage3
	-rm -f stage3/gnulib
	-ln gnulib stage3 || (cp gnulib stage3 && ranlib stage3/gnulib)

stage4: force
	-mkdir stage4
	-mv $(STAGESTUFF) $(STAGE_GCC) stage4
	-rm -f stage4/gnulib
	-ln gnulib stage4 || (cp gnulib stage4 && ranlib stage4/gnulib)

TAGS: force
	mkdir temp
	-mv c-parse.tab.c cplus-parse.c cplus-parse.h cexp.c temp
	etags *.y *.h *.c
	mv temp/* .
	rmdir temp

includes: force
	LIB=$(libdir) ./fixincludes

#In GNU Make, ignore whether `stage*' exists.
.PHONY: stage1 stage2 stage3 stage4 clean realclean TAGS bootstrap pcsetup \
	pcclean

force:

# a special target which gets things ready for a pc build.

pcclean:
	rm -f cpt.c cccp.h a??.c a??.obj iflags.h icodes.h iconfig.h \
	      hardrset.h typeclas.h bblock.h conds.h aoutput.c a??.c
	./dos2unix alloca.c
	./dos2unix config.h
	./dos2unix gcc.c
	./dos2unix gcc.h
	./dos2unix tm.h
	./dos2unix obstack.h
	./dos2unix obstack.c
	./dos2unix version.c


pcsetup:	$(srcdir)/c-parse.tab.c insn-emit.c insn-peep.c insn-recog.c \
		insn-extract.c insn-output.c insn-flags.h insn-config.h \
		insn-codes.h \
		$(srcdir)/cexp.c pcclean
	touch cccp.h
	echo -n "#define GCC_INCLUDE_DIR " >> cccp.h
	echo "\"c:\\\\dsp\\\\include\"" >> cccp.h
	echo -n "#define GPLUSPLUS_INCLUDE_DIR " >> cccp.h
	echo "\"c:\\\\dsp\\\\include\"" >> cccp.h
	rm config.h
	ln -s config/xm-i386.h config.h
	ln insn-flags.h iflags.h
	ln insn-codes.h icodes.h
	ln insn-config.h iconfig.h
	ln hard-reg-set.h hardrset.h
	ln typeclass.h typeclas.h
	ln basic-block.h bblock.h
	ln conditions.h conds.h
	ln aux-output.c aoutput.c
	ln alloca.c a01.c
	ln c-parse.tab.c a02.c
	ln c-decl.c a03.c
	ln c-typeck.c a04.c
	ln c-convert.c a05.c
	ln toplev.c a06.c
	ln version.c a07.c
	ln tree.c a08.c
	ln print-tree.c a09.c
	ln stor-layout.c a10.c
	ln fold-const.c a11.c
	ln rtl.c a12.c
	ln rtlanal.c a13.c
	ln obstack.c a14.c
	ln expr.c a15.c
	ln stmt.c a16.c
	ln expmed.c a17.c
	ln explow.c a18.c
	ln optabs.c a19.c
	ln varasm.c a20.c
	ln symout.c a21.c
	ln dbxout.c a22.c
	ln sdbout.c a23.c
	ln emit-rtl.c a24.c
	ln insn-emit.c a25.c
	ln integrate.c a26.c
	ln jump.c a27.c
	ln cse.c a28.c
	ln loop.c a29.c
	ln flow.c a30.c
	ln stupid.c a31.c
	ln combine.c a32.c
	ln regclass.c a33.c
	ln local-alloc.c a34.c
	ln global-alloc.c a35.c
	ln reload.c a36.c
	ln reload1.c a37.c
	ln caller-save.c a38.c
	ln insn-peep.c a39.c
	ln final.c a40.c
	ln recog.c a41.c
	ln insn-recog.c a42.c
	ln insn-extract.c a43.c
	ln insn-output.c a44.c
	./unix2dos alloca.c
	./unix2dos config.h
	./unix2dos gcc.c
	./unix2dos gcc.h
	./unix2dos tm.h
	./unix2dos obstack.h
	./unix2dos obstack.c
	./unix2dos version.c
	@ echo "all set to run make -f makefile.pc all"
	@ echo "make sure *NOT* to run config.gcc dsp?6k-pc386."

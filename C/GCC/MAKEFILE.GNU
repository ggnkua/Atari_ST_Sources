# Makefile for GNU C compiler.
#   Copyright (C) 1987 Free Software Foundation, Inc.

#This file is part of GNU CC.

#GNU CC is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY.  No author or distributor
#accepts responsibility to anyone for the consequences of using it
#or for whether it serves any particular purpose or works at all,
#unless he says so in writing.  Refer to the GNU CC General Public
#License for full details.

#Everyone is granted permission to copy, modify and redistribute
#GNU CC, but only under the conditions described in the
#GNU CC General Public License.   A copy of this license is
#supposed to have been given to you along with GNU CC so you
#can know your rights and responsibilities.  It should be in a
#file named COPYING.  Among other things, the copyright notice
#and this notice must be preserved on all copies.


CFLAGS = -g
CC = cc
# OLDCC should not be the GNU C compiler.
OLDCC = cc
BISON = bison
AR = ar
SHELL = /bin/sh

bindir = /usr/local
libdir = /usr/local/lib

# These are what you would need on HPUX:
# CFLAGS = -Wc,-Ns2000 -Wc,-Ne700
# -g is desirable in CFLAGS, but a compiler bug in HPUX version 5
# bites whenever tree.def, rtl.def or machmode.def is included
# (ie., on every source file).
# CCLIBFLAGS = -Wc,-Ns2000 -Wc,-Ne700
# For CCLIBFLAGS you might want to specify the switch that
# forces only 68000 instructions to be used.

# If you are making gcc for the first time, and if you are compiling it with
# a non-gcc compiler, and if your system doesn't have a working alloca() in any
# of the standard libraries (as is true for HP/UX), then get alloca.c from
# GNU Emacs and un-comment the following line:
# CLIB = alloca.o

# If your system has alloca() in /lib/libPW.a, un-comment the following line:
# CLIB= -lc -lPW

# For System V based systems, you will also have to comment out the `ranlib'
# command below.

# If you are running GCC on an Apollo, you will need this:
# CFLAGS = -g -O -M 3000 -U__STDC__ -DSHORT_ENUM_BUG

# How to link with obstack
OBSTACK=obstack.o
# Dependency on obstack
OBSTACK1=obstack.o

LIBS = $(OBSTACK) $(CLIB)
DIR = ../gcc

OBJS = toplev.o version.o parse.tab.o tree.o print-tree.o \
 decl.o typecheck.o stor-layout.o fold-const.o \
 rtl.o expr.o stmt.o expmed.o explow.o optabs.o varasm.o \
 symout.o dbxout.o sdbout.o emit-rtl.o insn-emit.o \
 integrate.o jump.o cse.o loop.o flow.o stupid.o combine.o \
 regclass.o local-alloc.o global-alloc.o reload.o reload1.o insn-peep.o \
 final.o recog.o insn-recog.o insn-extract.o insn-output.o

# Files to be copied away after each stage in building.
STAGE_GCC=gcc
STAGESTUFF = *.o insn-flags.h insn-config.h insn-codes.h \
 insn-output.c insn-recog.c insn-emit.c insn-extract.c insn-peep.c \
 genemit genoutput genrecog genextract genflags gencodes genconfig genpeep \
 cc1 cpp cccp

# Members of gnulib.
LIBFUNCS = _eprintf \
   _umulsi3 _mulsi3 _udivsi3 _divsi3 _umodsi3 _modsi3 \
   _lshrsi3 _lshlsi3 _ashrsi3 _ashlsi3 \
   _divdf3 _muldf3 _negdf2 _adddf3 _subdf3 _cmpdf2 \
   _fixunsdfsi _fixunsdfdi _fixdfsi _fixdfdi \
   _floatsidf _floatdidf _truncdfsf2 _extendsfdf2 \
   _addsf3 _negsf2 _subsf3 _cmpsf2 _mulsf3 _divsf3

# If you want to recompile everything, just do rm *.o.
# CONFIG_H = config.h tm.h
CONFIG_H =
RTL_H = rtl.h rtl.def machmode.def
TREE_H = tree.h tree.def machmode.def

all: gnulib gcc cc1 cpp

doc: cpp.info internals

compilations: ${OBJS}

gcc: gcc.o version.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o gccnew gcc.o version.o $(LIBS)
# Go via `gccnew' to avoid `file busy' if $(CC) is `gcc'.
	mv gccnew gcc

gcc.o: gcc.c $(CONFIG_H)
	$(CC) $(CFLAGS) -c -DSTANDARD_EXEC_PREFIX=\"$(libdir)/gcc-\" gcc.c

cc1: $(OBJS) $(OBSTACK1)
	$(CC) $(CFLAGS) -o cc1 $(OBJS) $(LIBS)

#Library of arithmetic subroutines
# Don't compile this with gcc!
gnulib: gnulib.c
	-mkdir libtemp
	cd libtemp; \
	rm -f gnulib; \
	for name in $(LIBFUNCS); \
	do \
	  echo $${name}; \
	  rm -f $${name}.c; \
	  ln ../gnulib.c $${name}.c; \
	  $(OLDCC) $(CCLIBFLAGS) -O -I.. -c -DL$${name} $${name}.c; \
	  $(AR) qc gnulib $${name}.o; \
	done
	mv libtemp/gnulib .
	rm -rf libtemp
	if [ -f /usr/bin/ranlib ] ; then  ranlib gnulib ;fi
# On HPUX, if you are working with the GNU assembler and linker,
# the previous line must be replaced with
# No change is needed here if you are using the HPUX assembler and linker.
#	mv gnulib gnulib-hp
#	hpxt gnulib-hp gnulib

decl.o : decl.c $(CONFIG_H) $(TREE_H) flags.h c-tree.h parse.h
typecheck.o : typecheck.c $(CONFIG_H) $(TREE_H) c-tree.h flags.h
tree.o : tree.c $(CONFIG_H) $(TREE_H)
print-tree.o : print-tree.c $(CONFIG_H) $(TREE_H)
stor-layout.o : stor-layout.c $(CONFIG_H) $(TREE_H)
fold-const.o : fold-const.c $(CONFIG_H) $(TREE_H)
toplev.o : toplev.c $(CONFIG_H) $(TREE_H) flags.h

parse.tab.o : parse.tab.c $(CONFIG_H) $(TREE_H) parse.h c-tree.h flags.h

parse.tab.c : parse.y
	$(BISON) -v parse.y

rtl.o : rtl.c $(CONFIG_H) $(RTL_H)

varasm.o : varasm.c $(CONFIG_H) $(TREE_H) $(RTL_H) flags.h expr.h
stmt.o : stmt.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h  \
   insn-flags.h expr.h insn-config.h regs.h 
expr.o : expr.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h  \
   insn-flags.h insn-codes.h expr.h insn-config.h recog.h
expmed.o : expmed.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h  \
   insn-flags.h insn-codes.h expr.h insn-config.h recog.h
explow.o : explow.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h expr.h
optabs.o : optabs.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h  \
   insn-flags.h insn-codes.h expr.h insn-config.h recog.h
symout.o : symout.c $(CONFIG_H) $(TREE_H) $(RTL_H) symseg.h gdbfiles.h
dbxout.o : dbxout.c $(CONFIG_H) $(TREE_H) $(RTL_H)
sdbout.o : sdbout.c $(CONFIG_H) $(TREE_H) $(RTL_H) c-tree.h

emit-rtl.o : emit-rtl.c $(CONFIG_H) $(RTL_H) regs.h insn-config.h

integrate.o : integrate.c $(CONFIG_H) $(RTL_H) $(TREE_H) flags.h expr.h insn-flags.h

jump.o : jump.c $(CONFIG_H) $(RTL_H) flags.h regs.h
stupid.o : stupid.c $(CONFIG_H) $(RTL_H) regs.h hard-reg-set.h

cse.o : cse.c $(CONFIG_H) $(RTL_H) insn-config.h regs.h hard-reg-set.h
loop.o : loop.c $(CONFIG_H) $(RTL_H) insn-config.h regs.h recog.h
flow.o : flow.c $(CONFIG_H) $(RTL_H) basic-block.h regs.h hard-reg-set.h
combine.o : combine.c $(CONFIG_H) $(RTL_H) flags.h  \
   insn-config.h regs.h basic-block.h recog.h
regclass.o : regclass.c $(CONFIG_H) $(RTL_H) flags.h regs.h \
   insn-config.h recog.h hard-reg-set.h
local-alloc.o : local-alloc.c $(CONFIG_H) $(RTL_H) basic-block.h regs.h \
   insn-config.h recog.h hard-reg-set.h
global-alloc.o : global-alloc.c $(CONFIG_H) $(RTL_H) flags.h  \
   basic-block.h regs.h hard-reg-set.h insn-config.h

reload.o : reload.c $(CONFIG_H) $(RTL_H)  \
   reload.h recog.h hard-reg-set.h insn-config.h regs.h
reload1.o : reload1.c $(CONFIG_H) $(RTL_H) flags.h  \
   reload.h regs.h hard-reg-set.h insn-config.h basic-block.h
final.o : final.c $(CONFIG_H) $(RTL_H) regs.h recog.h conditions.h gdbfiles.h
recog.o : recog.c $(CONFIG_H) $(RTL_H)  \
   regs.h recog.h hard-reg-set.h insn-config.h

# Now the source files that are generated from the machine description.

.PRECIOUS: insn-config.h insn-flags.h insn-codes.h \
  insn-emit.c insn-recog.c insn-extract.c insn-output.c insn-peep.c

insn-config.h : md genconfig
	./genconfig md > tmp-insn-config.h
	./move-if-change tmp-insn-config.h insn-config.h

insn-flags.h : md genflags
	./genflags md > tmp-insn-flags.h
	./move-if-change tmp-insn-flags.h insn-flags.h

insn-codes.h : md gencodes
	./gencodes md > tmp-insn-codes.h
	./move-if-change tmp-insn-codes.h insn-codes.h

insn-emit.o : insn-emit.c $(CONFIG_H) $(RTL_H) expr.h insn-config.h
	$(CC) $(CFLAGS) -c insn-emit.c

insn-emit.c : md genemit
	./genemit md > tmp-insn-emit.c
	./move-if-change tmp-insn-emit.c insn-emit.c

insn-recog.o : insn-recog.c $(CONFIG_H) $(RTL_H) insn-config.h
	$(CC) $(CFLAGS) -c insn-recog.c

insn-recog.c : md genrecog
	./genrecog md > tmp-insn-recog.c
	./move-if-change tmp-insn-recog.c insn-recog.c

insn-extract.o : insn-extract.c $(RTL_H)
	$(CC) $(CFLAGS) -c insn-extract.c

insn-extract.c : md genextract
	./genextract md > tmp-insn-extract.c
	./move-if-change tmp-insn-extract.c insn-extract.c

insn-peep.o : insn-peep.c $(CONFIG_H) $(RTL_H) regs.h
	$(CC) $(CFLAGS) -c insn-peep.c

insn-peep.c : md genpeep
	./genpeep md > tmp-insn-peep.c
	./move-if-change tmp-insn-peep.c insn-peep.c

insn-output.o : insn-output.c $(CONFIG_H) $(RTL_H) regs.h insn-config.h insn-flags.h conditions.h output.h aux-output.c
	$(CC) $(CFLAGS) -c insn-output.c

insn-output.c : md genoutput
	./genoutput md > tmp-insn-output.c
	./move-if-change tmp-insn-output.c insn-output.c

# Now the programs that generate those files.

genconfig : genconfig.o rtl.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o genconfig genconfig.o rtl.o $(LIBS)

genconfig.o : genconfig.c $(RTL_H)
	$(CC) $(CFLAGS) -c genconfig.c

genflags : genflags.o rtl.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o genflags genflags.o rtl.o $(LIBS)

genflags.o : genflags.c $(RTL_H)
	$(CC) $(CFLAGS) -c genflags.c

gencodes : gencodes.o rtl.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o gencodes gencodes.o rtl.o $(LIBS)

gencodes.o : gencodes.c $(RTL_H)
	$(CC) $(CFLAGS) -c gencodes.c

genemit : genemit.o rtl.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o genemit genemit.o rtl.o $(LIBS)

genemit.o : genemit.c $(RTL_H)
	$(CC) $(CFLAGS) -c genemit.c

genrecog : genrecog.o rtl.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o genrecog genrecog.o rtl.o $(LIBS)

genrecog.o : genrecog.c $(RTL_H)
	$(CC) $(CFLAGS) -c genrecog.c

genextract : genextract.o rtl.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o genextract genextract.o rtl.o $(LIBS)

genextract.o : genextract.c $(RTL_H)
	$(CC) $(CFLAGS) -c genextract.c

genpeep : genpeep.o rtl.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o genpeep genpeep.o rtl.o $(LIBS)

genpeep.o : genpeep.c $(RTL_H)
	$(CC) $(CFLAGS) -c genpeep.c

genoutput : genoutput.o rtl.o $(OBSTACK1)
	$(CC) $(CFLAGS) -o genoutput genoutput.o rtl.o $(LIBS)

genoutput.o : genoutput.c $(RTL_H)
	$(CC) $(CFLAGS) -c genoutput.c

# Making the preprocessor
cpp: cccp
	-rm -f cpp
	ln cccp cpp
cccp: cccp.o cexp.o version.o
	$(CC) $(CFLAGS) -DGCC_INCLUDE_DIR=\"$(libdir)/gcc-include\" \
          -DGPLUSPLUS_INCLUDE_DIR=\"$(libdir)/g++-include\" -c cccp.c
cexp.o: cexp.c
cexp.c: cexp.y
	$(BISON) cexp.y
	mv cexp.tab.c cexp.c
cccp.o: cccp.c

cpp.info: cpp.texinfo
	makeinfo $<

internals: internals.texinfo
	makeinfo $<

# gnulib is not deleted because deleting it would be inconvenient
# for most uses of this target.
clean:
	-rm -f $(STAGESTUFF) $(STAGE_GCC)
	-rm -f *.s *.s[0-9] *.co *.greg *.lreg *.combine *.flow *.cse *.jump *.rtl *.tree *.loop
	-rm -f core

# Copy the files into directories where they will be run.
install: all
	install cc1 $(libdir)/gcc-cc1
	install -c -m 755 gnulib $(libdir)/gcc-gnulib
	if [ -f /usr/bin/ranlib ] ; then  ranlib $(libdir)/gcc-gnulib ;fi
	install cpp $(libdir)/gcc-cpp
	install gcc $(bindir)

# do make -f ../gcc/Makefile maketest DIR=../gcc
# in the intended test directory to make it a suitable test directory.
maketest:
	ln -s $(DIR)/*.[chy] .
	ln -s $(DIR)/*.def .
	ln -s $(DIR)/*.md .
	ln -s $(DIR)/.gdbinit .
	-ln -s $(DIR)/bison.simple .
	ln -s $(DIR)/gcc .
	ln -s $(DIR)/move-if-change .
	ln -s $(DIR)/Makefile test-Makefile
	-rm tm.h aux-output.c
	make -f test-Makefile clean
# You must create the necessary links tm.h, md and aux-output.c

# Copy the object files from a particular stage into a subdirectory.
stage1: force
	-mkdir stage1
	mv $(STAGESTUFF) $(STAGE_GCC) stage1
	ln gnulib stage1

stage2: force
	-mkdir stage2
	mv $(STAGESTUFF) $(STAGE_GCC) stage2
	ln gnulib stage2

stage3: force
	-mkdir stage3
	mv $(STAGESTUFF) $(STAGE_GCC) stage3
	ln gnulib stage3

.PHONY: stage1 stage2 stage3 #In GNU Make, ignore whether `stage*' exists.
force:

TAGS: force
	etags *.y *.h *.c
.PHONY: TAGS

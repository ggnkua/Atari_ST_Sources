#
# Makefile for mouse
#

SHELL = /bin/sh
SUBDIRS = 

srcdir = .
top_srcdir = ../../../../..
subdir = mouse
toscommon_srcdir = ../../../tos-common
hidcommon_srcdir = ../hid-common

default: help

include ./MOUSEDEFS

include $(top_srcdir)/CONFIGVARS
include $(top_srcdir)/RULES
include $(top_srcdir)/PHONY

SGENFILES = crtinit.c entry.S hid.c hid.h hidparse.c hidparse.h setstack.S

all-here: all-targets

# default overwrites

# default definitions
compile_all_dirs = .compile_*
GENFILES = $(compile_all_dirs) *.udd *.prg

help:
	@echo '#'
	@echo '# targets:'
	@echo '# --------'
	@echo '# - all'
	@echo '# - $(mousetargets)'
	@echo '#'
	@echo '# - clean'
	@echo '# - distclean'
	@echo '# - bakclean'
	@echo '# - strip'
	@echo '# - help'
	@echo '#'

strip:
	$(STRIP) .compile_prg/*.prg
	@set fnord $(MAKEFLAGS); amf=$$2; \
	for i in $(mousetargets); do \
		if [ "$$i" = "prg" ]; then continue; fi; \
		(set -x; \
		($(STRIP) .compile_$$i/*.udd) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac); \
	done && test -z "$$fail"

all-targets:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	for i in $(mousetargets); do \
		echo "Making $$i"; \
		($(MAKE) $$i) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done && test -z "$$fail"

$(mousetargets): $(SGENFILES)
	$(MAKE) buildmouse mouse=$@

# Link common TOS files
crtinit.c: $(toscommon_srcdir)/crtinit.c
	ln -sf $< $(srcdir)/$@
entry.S: $(toscommon_srcdir)/entry.S
	ln -sf $< $(srcdir)/$@
setstack.S: $(toscommon_srcdir)/setstack.S
	ln -sf $< $(srcdir)/$@

# Link common hid files
hid.c: $(hidcommon_srcdir)/hid.c
	ln -sf $< $(srcdir)/$@
hid.h: $(hidcommon_srcdir)/hid.h
	ln -sf $< $(srcdir)/$@
hidparse.c: $(hidcommon_srcdir)/hidparse.c
	ln -sf $< $(srcdir)/$@
hidparse.h: $(hidcommon_srcdir)/hidparse.h
	ln -sf $< $(srcdir)/$@

#
# multi target stuff
#

ifneq ($(mouse),)

compile_dir = .compile_$(mouse)
mousetarget = _stmp_$(mouse)
realtarget = $(mousetarget)

$(mousetarget): $(compile_dir)
	cd $(compile_dir); $(MAKE) all

$(compile_dir): Makefile.objs
	$(MKDIR) -p $@
	$(CP) $< $@/Makefile

else

realtarget =

endif

buildmouse: $(realtarget)

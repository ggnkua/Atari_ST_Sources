#
# Makefile for keyboard
#

SHELL = /bin/sh
SUBDIRS =

srcdir = .
top_srcdir = ../../../../../..
subdir = keyboard
toscommon_srcdir = ../../../tos-common

default: help

include ./KEYBOARDDEFS

include $(top_srcdir)/CONFIGVARS
include $(top_srcdir)/RULES
include $(top_srcdir)/PHONY

SGENFILES = crtinit.c entry.S setstack.S

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
	@echo '# - $(keyboardtargets)'
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
	for i in $(keyboardtargets); do \
		if [ "$$i" = "prg" ]; then continue; fi; \
		(set -x; \
		($(STRIP) .compile_$$i/*.udd) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac); \
	done && test -z "$$fail"

all-targets:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	for i in $(keyboardtargets); do \
		echo "Making $$i"; \
		($(MAKE) $$i) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done && test -z "$$fail"

$(keyboardtargets): $(SGENFILES)
	$(MAKE) buildkeyboard keyboard=$@

# Link common TOS files
crtinit.c: $(toscommon_srcdir)/crtinit.c
	ln -sf $< $(srcdir)/$@
entry.S: $(toscommon_srcdir)/entry.S
	ln -sf $< $(srcdir)/$@
setstack.S: $(toscommon_srcdir)/setstack.S
	ln -sf $< $(srcdir)/$@

#
# multi target stuff
#

ifneq ($(keyboard),)

compile_dir = .compile_$(keyboard)
keyboardtarget = _stmp_$(keyboard)
realtarget = $(keyboardtarget)

$(keyboardtarget): $(compile_dir)
	cd $(compile_dir); $(MAKE) all

$(compile_dir): Makefile.objs
	$(MKDIR) -p $@
	$(CP) $< $@/Makefile

else

realtarget =

endif

buildkeyboard: $(realtarget)

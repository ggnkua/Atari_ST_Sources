#
# Makefile for netusbee
#

SHELL = /bin/sh
SUBDIRS = 

srcdir = .
top_srcdir = ../../../..
subdir = netusbee
toscommon_srcdir = ../../tos-common

default: help

include ./NETUSBEEDEFS

include $(top_srcdir)/CONFIGVARS
include $(top_srcdir)/RULES
include $(top_srcdir)/PHONY

SGENFILES = crtinit.c delayasm.S entry.S setstack.S

all-here: all-targets

# default overwrites

# default definitions
compile_all_dirs = .compile_*
GENFILES = $(compile_all_dirs) *.ucd *.prg

help:
	@echo '#'
	@echo '# targets:'
	@echo '# --------'
	@echo '# - all'
	@echo '# - $(netusbeetargets)'
	@echo '#'
	@echo '# - clean'
	@echo '# - distclean'
	@echo '# - bakclean'
	@echo '# - strip'
	@echo '# - help'
	@echo '#'

strip:
	$(STRIP) .compile_prg/*.prg
	$(STRIP) .compile_prg_000/*.prg
	@set fnord $(MAKEFLAGS); amf=$$2; \
	for i in $(netusbeetargets); do \
		if [ "$$i" = "prg" -o "$$i" = "prg_000" ]; then continue; fi; \
		(set -x; \
		($(STRIP) .compile_$$i/*.ucd) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac); \
	done && test -z "$$fail"

all-targets:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	for i in $(netusbeetargets); do \
		echo "Making $$i"; \
		($(MAKE) $$i) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done && test -z "$$fail"

$(netusbeetargets): $(SGENFILES)
	$(MAKE) buildnetusbee netusbee=$@

# Link common TOS files
crtinit.c: $(toscommon_srcdir)/crtinit.c
	ln -sf $< $(srcdir)/$@
delayasm.S: $(toscommon_srcdir)/delayasm.S
	ln -sf $< $(srcdir)/$@
entry.S: $(toscommon_srcdir)/entry.S
	ln -sf $< $(srcdir)/$@
setstack.S: $(toscommon_srcdir)/setstack.S
	ln -sf $< $(srcdir)/$@

#
# multi target stuff
#

ifneq ($(netusbee),)

compile_dir = .compile_$(netusbee)
netusbeetarget = _stmp_$(netusbee)
realtarget = $(netusbeetarget)

$(netusbeetarget): $(compile_dir)
	cd $(compile_dir); $(MAKE) all

$(compile_dir): Makefile.objs
	$(MKDIR) -p $@
	$(CP) $< $@/Makefile

else

realtarget =

endif

buildnetusbee: $(realtarget)

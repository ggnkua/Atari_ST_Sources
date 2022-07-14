#
# Makefile for ehci
#

SHELL = /bin/sh
SUBDIRS = 

srcdir = .
top_srcdir = ../../../..
subdir = ehci
toscommon_srcdir = ../../tos-common

default: help

include ./EHCIDEFS

include $(top_srcdir)/CONFIGVARS
include $(top_srcdir)/RULES
include $(top_srcdir)/PHONY

SGENFILES = cache.S crtinit.c delayasm.S entry.S pci_bios.c pci_xbios.S setstack.S

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
	@echo '# - $(ehcitargets)'
	@echo '#'
	@echo '# - clean'
	@echo '# - distclean'
	@echo '# - bakclean'
	@echo '# - strip'
	@echo '# - help'
	@echo '#'

strip:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	for i in $(ehcitargets); do \
		(set -x; \
        if [ "$$i" = "prg" ]; then ($(STRIP) .compile_$$i/*.prg);continue; fi; \
		($(STRIP) .compile_$$i/*.ucd) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac); \
	done && test -z "$$fail"

all-targets:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	for i in $(ehcitargets); do \
		echo "Making $$i"; \
		($(MAKE) $$i) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done && test -z "$$fail"

$(ehcitargets): $(SGENFILES)
	$(MAKE) buildehci ehci=$@

# Link common TOS files
cache.S: $(toscommon_srcdir)/cache.S
	ln -sf $< $(srcdir)/$@
crtinit.c: $(toscommon_srcdir)/crtinit.c
	ln -sf $< $(srcdir)/$@
delayasm.S: $(toscommon_srcdir)/delayasm.S
	ln -sf $< $(srcdir)/$@
entry.S: $(toscommon_srcdir)/entry.S
	ln -sf $< $(srcdir)/$@
pci_bios.c: $(toscommon_srcdir)/pci_bios.c
	ln -sf $< $(srcdir)/$@
pci_xbios.S: $(toscommon_srcdir)/pci_xbios.S
	ln -sf $< $(srcdir)/$@
setstack.S: $(toscommon_srcdir)/setstack.S
	ln -sf $< $(srcdir)/$@

#
# multi target stuff
#

ifneq ($(ehci),)

compile_dir = .compile_$(ehci)
ehcitarget = _stmp_$(ehci)
realtarget = $(ehcitarget)

$(ehcitarget): $(compile_dir)
	cd $(compile_dir); $(MAKE) all

$(compile_dir): Makefile.objs
	$(MKDIR) -p $@
	$(CP) $< $@/Makefile

else

realtarget =

endif

buildehci: $(realtarget)

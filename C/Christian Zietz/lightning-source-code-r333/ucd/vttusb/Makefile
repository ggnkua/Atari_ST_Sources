#
# Makefile for vttusb
#

SHELL = /bin/sh
SUBDIRS = 

srcdir = .
top_srcdir = ../../../..
subdir = vttusb
toscommon_srcdir = ../../tos-common

default:

include ./VTTUSBDEFS

include $(top_srcdir)/CONFIGVARS
include $(top_srcdir)/RULES
include $(top_srcdir)/PHONY

SGENFILES = crtinit.c delayasm.S entry.S setstack.S

all-here: all-targets

# default overwrites

# default definitions
compile_all_dirs = .compile_*
GENFILES = $(compile_all_dirs) *.ucd *.prg

all-targets:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	for i in $(vttusbtargets); do \
		echo "Making $$i"; \
		($(MAKE) $$i) \
		|| case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done && test -z "$$fail"

$(vttusbtargets): $(SGENFILES)
	$(MAKE) buildvttusb vttusb=$@

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

ifneq ($(vttusb),)

compile_dir = .compile_$(vttusb)
vttusbtarget = _stmp_$(vttusb)
realtarget = $(vttusbtarget)

$(vttusbtarget): $(compile_dir)
	cd $(compile_dir); $(MAKE) all

$(compile_dir): Makefile.objs
	$(MKDIR) -p $@
	$(CP) $< $@/Makefile

else

realtarget =

endif

buildvttusb: $(realtarget)

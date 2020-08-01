#==============================================================================
# Makefile for UnZip, UnZipSFX & fUnZip:  Atari ST               Chris Herborth
# Version:  UnZip 5.11, MiNT, GNU C                                14 July 1994
#==============================================================================

# Based on the original unix Makefile and modified by Chris Herborth
# (cherborth@semprini.waterloo-rdp.on.ca), Nov.13/93.
#
# $Id: Makefile 1.7 1993/12/28 18:52:52 root Exp $

# Be sure to test your new UnZip (and UnZipSFX and fUnZip); successful com-
# pilation does not always imply a working program.


#####################
# MACRO DEFINITIONS #
#####################

# Defaults most systems use (use LOCAL_UNZIP in environment to add flags, 
# such as -DDOSWILD).

# UnZip flags
# NOTE: 'cgcc' is my cross-compiler; you'll probably use 'gcc' instead.
CC = cgcc
LD = cgcc
LOC = $(LOCAL_UNZIP) -ansi -D__MINT__ -U__STRICT_ANSI__

CF = -mbaserel -mpcrel -O2 -fomit-frame-pointer -I. $(LOC)
# CF = -O -I. $(LOC)
# CF = -mbaserel -O -I. $(LOC)
LF = -mbaserel -mpcrel -o unzip.ttp
LF2 = -s -lbiio

# UnZipSFX flags
XC = -DSFX
XL = -mbaserel -mpcrel -o unzipsfx.ttp
XL2 = $(LF2)

# fUnZip flags
FC = -DFUNZIP
FL = -mbaserel -mpcrel -o funzip.ttp
FL2 = $(LF2)

# general-purpose stuff
CP = cp
LN = ln -s
RM = rm -f
E = .ttp
O = .o
M = atari
SHELL = /bin/sh

# object files
OBJS1 = unzip$O crypt$O envargs$O explode$O extract$O file_io$O
OBJS2 = inflate$O match$O unreduce$O unshrink$O zipinfo$O
OBJS = $(OBJS1) $(OBJS2) $M$O
LOBJS = $(OBJS)
OBJX = unzip_$O crypt$O extract_$O file_io$O inflate$O match$O $M_$O
OBJF = funzip$O crypt_$O inflate_$O

# installation
INSTALL = cp#	probably can change this to 'install' if you have it
# on some systems, manext=l and MANDIR=/usr/man/man$(manext) may be appropriate
manext = 1
MANDIR = /usr/local/man/man$(manext)#	where to install man pages
BINDIR = /usr/local/bin#		where to install executables
#
UNZIPS = unzip$E unzipsfx$E funzip$E zipinfo$E
MANS = unzip.$(manext) unzipsfx.$(manext) zipinfo.$(manext) funzip.$(manext)
DOCS = unzip.doc unzipsfx.doc zipinfo.doc funzip.doc
# this is a little ugly...
INSTALLED = $(BINDIR)/unzip$E $(BINDIR)/zipinfo$E $(BINDIR)/funzip$E \
	$(BINDIR)/unzipsfx$E $(MANDIR)/unzipsfx.$(manext) \
	$(MANDIR)/unzip.$(manext) $(MANDIR)/zipinfo.$(manext) \
	$(MANDIR)/funzip.$(manext)

###############################################
# BASIC COMPILE INSTRUCTIONS AND DEPENDENCIES #
###############################################

.c$O:
	$(CC) -c $(CF) $*.c


all:		unzips
unzips:		$(UNZIPS)
docs:		$(DOCS)
unzipsman:	unzips docs
unzipsdocs:	unzips docs


clean:
	rm -f $(OBJS) $(OBJF) $(OBJX) $(UNZIPS)

install:	$(UNZIPS) $(MANS)
	$(INSTALL) $(UNZIPS) $(BINDIR)
	$(LN) $(BINDIR)/unzip$E $(BINDIR)/zipinfo$E
	$(INSTALL) unix/unzip.1 $(MANDIR)/unzip.$(manext)
	$(INSTALL) unix/unzipsfx.1 $(MANDIR)/unzipsfx.$(manext)
	$(INSTALL) unix/zipinfo.1 $(MANDIR)/zipinfo.$(manext)
	$(INSTALL) unix/funzip.1 $(MANDIR)/funzip.$(manext)

# alternatively, could use zip method:  -cd $(BINDIR); rm -f $(UNZIPS)  [etc.]
uninstall:
	rm -f $(INSTALLED)


unzip$E:	$(OBJS)			# add `&' if parallel makes supported
	$(LD) $(LF) $(LOBJS) $(LF2)

unzipsfx$E:	$(OBJX)			# add `&' if parallel makes supported
	$(LD) $(XL) $(OBJX) $(XL2)

funzip$E:	$(OBJF)			# add `&' if parallel makes supported
	$(LD) $(FL) $(OBJF) $(FL2)

zipinfo$E:	unzip$E
	@echo\
 '  This is a Unix-inspired target.  If your filesystem does not support'
	@echo\
 '  symbolic links, copy unzip.ttp to zipinfo.ttp rather than linking it,'
	@echo\
 '  or else invoke as "unzip -Z".'
	$(LN) unzip$E zipinfo$E


crypt$O:	crypt.c unzip.h zip.h crypt.h
envargs$O:	envargs.c unzip.h
explode$O:	explode.c unzip.h
extract$O:	extract.c unzip.h crypt.h
file_io$O:	file_io.c unzip.h crypt.h tables.h
funzip$O:	funzip.c unzip.h crypt.h tables.h
inflate$O:	inflate.c inflate.h unzip.h
match$O:	match.c unzip.h
unreduce$O:	unreduce.c unzip.h
unshrink$O:	unshrink.c unzip.h
unzip$O:	unzip.c unzip.h version.h
zipinfo$O:	zipinfo.c unzip.h

crypt_$O:	crypt.c unzip.h zip.h crypt.h		# funzip only
	$(CP) crypt.c crypt_.c
	$(CC) -c $(CF) $(FC) crypt_.c
	$(RM) crypt_.c

inflate_$O:	inflate.c inflate.h unzip.h crypt.h	# funzip only
	$(CP) inflate.c inflate_.c
	$(CC) -c $(CF) $(FC) inflate_.c
	$(RM) inflate_.c

unzip_$O:	unzip.c unzip.h version.h		# unzipsfx only
	$(CP) unzip.c unzip_.c
	$(CC) -c $(CF) $(XC) unzip_.c
	$(RM) unzip_.c

extract_$O:	extract.c unzip.h crypt.h		# unzipsfx only
	$(CP) extract.c extract_.c
	$(CC) -c $(CF) $(XC) extract_.c
	$(RM) extract_.c

# atari$O:	atari/atari.c unzip.h			# Atari only
#	$(CC) -c $(CF) atari/atari.c

atari$O:	atari.c unzip.h

atari_$O:	atari.c unzip.h				# unzipsfx only
	$(CP) atari.c atari_.c
	$(CC) -c $(CF) $(XC) atari_.c
	$(RM) atari_.c

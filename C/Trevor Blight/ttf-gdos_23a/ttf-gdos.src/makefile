######### (c) Trevor Blight 1995-2002 ##########
#
# $Id: makefile 3296 2021-09-16 08:13:17Z trevor $
#
# this is the makefile for ttf-gdos
#
# ttf-gdos is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#######################################################
#
# make one of three builds for ttf-gdos:
# development build, debug build, release build
# debug build includes lots of debug output,
# release build embeds revision number in sign on message
# development build embeds build timestamp in sign on message
# assume a gulam shell, may need some mods for other shells
#
################################################

### modify this for each new release ###
MAJ_REV = 2
MIN_REV = 3
RELEASE_LABEL = Release-$(MAJ_REV)_$(MIN_REV)

.DEFAULT:
	@echo $@ not found
	touch $@

CFLAGS = -DGDOS -DMAJ_REV=$(MAJ_REV) -DMIN_REV=$(MIN_REV) -O
TARGET = ttf-gdos.prg
#CC = gcc -mshort
CC = cc

INSTALL = cp $(TARGET) \auto

SRCS = ttf-gdos.c font.c ttf.c glyph.c cache.c bezier.c
OBJS = ttf-gdos.o font.o ttf.o glyph.o cache.o bezier.o
HDRS = ttf-gdos.h ttf-defs.h ttf.h

UTILS = ass-conv.ttp chpr.acc chq.acc fix-fwid.prg ifonts.ttp
TESTS = tv1.prg tv6.prg

.c.o:
	$(CC) -c $(CFLAGS) $<

.c.i:
	$(CC) -E $(CFLAGS) $<

$(TARGET):  $(OBJS) $(HDRS)
	@echo 'const char sign_on_msg[] = "ttf-gdos (" __DATE__ " " __TIME__ ")\r\n";' > sign_on.c
	$(CC) -s -o $(TARGET) -nostdlib $(CFLAGS) -DNDEBUG $(OBJS) sign_on.c -liio16 -lgnu16
	ls -l $(TARGET)
	$(INSTALL)

debug:  $(OBJS) $(HDRS)
	@echo 'const char sign_on_msg[] = "ttf-gdos (debug, " __DATE__ " " __TIME__ ")\r\n";' > sign_on.c
	$(CC) -s -o $(TARGET) -nostdlib $(CFLAGS) $(OBJS) sign_on.c -liio16 -lgnu16
	ls -l $(TARGET)
	$(INSTALL)

release:
	#@echo 'foreach i { $(SRCS) $(HDRS) }' > get_src.g
	#@echo 'co -f$(RELEASE_LABEL) $(RCS_DIR)\$$i' >> get_src.g
	#@echo endfor >> get_src.g
	#get_src.g
	@echo 'const char sign_on_msg[] = "ttf-gdos release $(MAJ_REV).$(MIN_REV)\r\n";' > sign_on.c
	$(CC) -s -o $(TARGET) -nostdlib $(CFLAGS) -DNDEBUG $(SRCS) sign_on.c -liio16 -lgnu16
	ls -l $(TARGET)

freeze:
	rcs -N$(RELEASE_LABEL): $(RCS_DIR)\*.*

help:
	@echo 'make		default target, make development build'
	@echo 'make debug	make debug build'
	@echo 'make release	make release build'
	@echo 'make freeze	add release name to rcs archive'

$(OBJS): $(HDRS)

$(UTILS): ttf-gdos.h

ass-conv.ttp: ass-conv.c
	cc -O -s $*.c -o $@ -l iio16

.c.acc:
	cc -O -s $*.c -o $@ -l iio16 -l gem16

.c.ttp:
	cc -O -s $*.c -o $@ -l iio16

.c.prg:
	cc -O -s $*.c -o $@ -l iio16 -l gem16


############# end of makefile #############



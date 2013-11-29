######### (c) Trevor Blight 1995-2002 ##########
#
# $Id: makefile 1.10 2001/03/31 23:50:40 tbb Exp $
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
MIN_REV = 2
RELEASE_LABEL = Release-$(MAJ_REV)_$(MIN_REV)
RCS_DIR = a:\rcs

.DEFAULT:
	cp a:\$@ .\

CC = cc
CFLAGS = -DGDOS -DMAJ_REV=$(MAJ_REV) -DMIN_REV=$(MIN_REV) -O
TARGET = ttf-gdos.prg

SRCS = ttf-gdos.c font.c ttf.c glyph.c cache.c bezier.c
OBJS = ttf-gdos.o font.o ttf.o glyph.o cache.o bezier.o
HDRS = ttf-gdos.h ttf-defs.h ttf.h

.c.o:
	$(CC) -c -z $(CFLAGS) $<

.c.i:
	$(CC) -E $(CFLAGS) $<

$(TARGET):  rmerr $(SRCS) $(HDRS)
	@echo 'const char sign_on_msg[] = "ttf-gdos (" __DATE__ " " __TIME__ ")\r\n";' > sign_on.c
	$(CC) -t -s -o $(TARGET) -nostdlib $(CFLAGS) -DNDEBUG $(SRCS) sign_on.c -liio16 -lgnu16
	ls -l $(TARGET)

debug:  $(OBJS)
	@echo 'const char sign_on_msg[] = "ttf-gdos (debug, " __DATE__ " " __TIME__ ")\r\n";' > sign_on.c
	$(CC) -O -t -s -o $(TARGET) -nostdlib $(OBJS) dsgn_on.c -liio16 -lgnu16
	ls -l $(TARGET)

release:
	@echo 'foreach i { $(SRCS) $(HDRS) }' > get_src.g
	@echo 'co -f$(RELEASE_LABEL) $(RCS_DIR)\$$i' >> get_src.g
	@echo endfor >> get_src.g
	get_src.g
	@echo 'const char sign_on_msg[] = "ttf-gdos release $(MAJ_REV).$(MIN_REV)\r\n";' > sign_on.c
	$(CC) -t -s -o $(TARGET) -nostdlib $(CFLAGS) -DNDEBUG $(SRCS) sign_on.c -liio16 -lgnu16
	ls -l $(TARGET)

freeze:
	rcs -N$(RELEASE_LABEL): $(RCS_DIR)\*.*

help:
	@echo 'make		default target, make development build'
	@echo 'make debug	make debug build'
	@echo 'make release	make release build'
	@echo 'make freeze	add release name to rcs archive'

rmerr:
	-rm compile.err

$(OBJS): $(HDRS)

bezier.o: bezier.c

cache.o: cache.c

font.o: font.c

ttf.o: ttf.c

glyph.o: glyph.c

ttf-gdos.o: ttf-gdos.c

############# end of makefile #############



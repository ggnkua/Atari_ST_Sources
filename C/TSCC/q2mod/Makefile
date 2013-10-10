##########################################################
#
# q2mod
#  03.02.2000 by Settel <uno4@rz.uni-karlsruhe.de>
#

# settings #fold00
OBJS = main.o
DST = q2mod

#VERSION := $(shell head -n 1 VERSION)
#VERSIONDATE := $(shell head -n 2 VERSION | tail -n 1)

CFLAGS = -O2 -fno-strength-reduce -Wall -W
LFLAGS = 
CC = gcc
MAKE = gmake
TAR = gtar
SHELL = bash

.PHONY:	all clean tar disk desktop depend
.SUFFIXES:	.c

# standard targets #fold00
all:	$(DST)
	./q2mod Zonk

$(DST): $(OBJS)
	gcc -o $(DST) $(OBJS) -lm
        
# tool targets #fold00
clean:	
	rm -f *~ *.bak *.o
	rm -f sotb.mod
	rm -f $(DST)
	rm -rf tmp/

tar:	clean
	(cd .. ; tar czf q2mod.tgz q2mod/ )

disk:	tar
	mcopy -o ../q2mod.tgz a: && rm ../q2mod.tgz

desktop:
	cp fte-desktop $(HOME)/.fte-desktop

depend:
	@makedepend -Y -- $(CFLAGS) -- *.c *.h  2>/dev/null

# dependencies #fold00
# DO NOT DELETE

main.o: pattern.h voice.h common.h mod.h

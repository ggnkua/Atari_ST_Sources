ARCH       = linux-i386
INSTALLDIR = ../bin-$(ARCH)

#vbcc
export TARGET = m68k
#m68k : use 32 bit int
#m68ks: use 16 bit int (warning, use also 16 bit int for arithmetic : #$4000*2 = $FFFF8000 = -1 !

#vasm
export CPU    = m68k
export SYNTAX = mot

.PHONY: all vasm vbcc vlink install

all: vbcc vasm vlink

install:
	mkdir -p $(INSTALLDIR)
	cp vasm/vasmm68k_mot                 $(INSTALLDIR)/
	strip -s $(INSTALLDIR)/vasmm68k_mot

clean:
	cd vasm  && make clean
	cd vasm  && rm -f vobjdump obj/vobjdump.o

vasm:
	if [ ! -d vasm ]; then tar xfz vasm_1.5d.tar.gz; fi
	cd vasm  && make

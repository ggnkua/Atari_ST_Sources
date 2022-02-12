# Makefile for lib/m68000

MAKE	= exec make -$(MAKEFLAGS)

install:
	test "$$CC" = acc || { cd em && $(MAKE); }
	cd head && $(MAKE)
	cd misc && $(MAKE)
	cd rts && $(MAKE)
	cd string && $(MAKE)

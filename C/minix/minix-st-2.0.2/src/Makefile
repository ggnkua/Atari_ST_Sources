# Master Makefile to compile everything in /usr/src except the kernel.

MAKE	= exec make -$(MAKEFLAGS)

usage:
	@echo "Usage:" >&2
	@echo "	make all        # Compile everything" >&2
	@echo "	make world      # Install the result (run as bin!)" >&2
	@echo "	make clean      # Remove all compiler results" >&2
	@echo "	(Run 'make' in tools to make a kernel)" >&2; exit 1

world:	install

install clean::
	cd lib && $(MAKE) $@	# Libraries first!

all::
	@echo "Are the libraries up to date?"; sleep 2

all install clean::
	cd boot && $(MAKE) $@
	test ! -d commands || { cd commands && $(MAKE) $@; }
	cd tools && $(MAKE) $@

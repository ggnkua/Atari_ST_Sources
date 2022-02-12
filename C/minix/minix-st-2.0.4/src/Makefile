# Master Makefile to compile everything in /usr/src except the kernel.

MAKE	= exec make -$(MAKEFLAGS)

usage:
	@echo "Usage:" >&2
	@echo "	make world      # Compile everything (libraries & commands)" >&2
	@echo "	make libraries  # Compile libraries" >&2
	@echo "	make all        # Compile commands, but don't install" >&2
	@echo "	make install    # Compile and install commands" >&2
	@echo "	make clean      # Remove all compiler results" >&2
	@echo "	(Run 'make' in tools to make a kernel)" >&2; exit 1

world:	libraries install

libraries:
	cd lib && $(MAKE) install

all::
	@echo "Are the libraries up to date?"; sleep 2

clean::
	cd lib && $(MAKE) $@

all install clean::
	cd boot && $(MAKE) $@
	test ! -f commands/Makefile || { cd commands && $(MAKE) $@; }
	cd inet && $(MAKE) $@
	cd tools && $(MAKE) $@

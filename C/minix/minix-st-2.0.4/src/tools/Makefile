# Makefile for the kernel image.
#
u=/usr
CC=	exec cc
CFLAGS=	-O -D_MINIX -D_POSIX_SOURCE
MDEC=	/usr/mdec
MAKE=	exec make -$(MAKEFLAGS)
PROGRAMS=	../kernel/kernel ../mm/mm ../fs/fs init

programs:
	cd ../kernel && $(MAKE)
	cd ../mm && $(MAKE)
	cd ../fs && $(MAKE)
	$(MAKE) image

image:	$(PROGRAMS)
	installboot -image $@ $(PROGRAMS)

init:	init.c
	$(CC) $(CFLAGS) init.c -o $@
	install -S 192w $@

ps:	ps.c /usr/include/minix/config.h /usr/include/minix/const.h \
		../kernel/const.h ../kernel/type.h \
		../kernel/proc.h ../mm/mproc.h \
		../fs/fproc.h ../fs/const.h
	$(CC) -i $(CFLAGS) -o $@ ps.c
	install -S 32kw $@

/usr/bin/ps:	ps
	install -cs -o bin -g kmem -m 2755 $? $@

bootable:
	exec su root mkboot bootable

hdboot:	programs
	exec sh mkboot $@

fdboot:	programs
	exec su root mkboot $@

all install clean::
	cd ../kernel && $(MAKE) $@
	cd ../mm && $(MAKE) $@
	cd ../fs && $(MAKE) $@

all::	ps

install::	/usr/bin/ps

clean::
	rm -f *.bak init ps image

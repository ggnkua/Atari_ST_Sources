# Makefile for the kernel image.
#
u=/usr
CC=	exec cc
CFLAGS=	-O -D_MINIX -D_POSIX_SOURCE
MDEC=	/usr/mdec
MAKE=	exec make -$(MAKEFLAGS)
inet=
PROGRAMS=	../kernel/kernel ../mm/mm ../fs/fs $(inet) init

programs:
	cd ../kernel && $(MAKE)
	cd ../mm && $(MAKE)
	cd ../fs && $(MAKE)
	@if [ `exec ./tell_config ENABLE_NETWORKING` = 0 ]; then \
		$(MAKE) image; \
	else \
		echo "cd ../inet && $(MAKE)" && \
		(cd ../inet && $(MAKE)) && \
		$(MAKE) image inet=../inet/inet; \
	fi

image:	$(PROGRAMS)
	installboot -image $@ $(PROGRAMS)

init:	init.c
	$(CC) $(CFLAGS) init.c -o $@
	install -S 192w $@

ps:	ps.c /usr/include/minix/config.h ../kernel/const.h \
		../kernel/type.h ../kernel/proc.h ../mm/mproc.h \
		../fs/fproc.h ../fs/const.h
	$(CC) -i $(CFLAGS) -m -o $@ ps.c
	install -S 16kw $@

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
	cd ../inet && $(MAKE) $@

all::	ps

install::	/usr/bin/ps

clean::
	rm -f *.bak init ps image

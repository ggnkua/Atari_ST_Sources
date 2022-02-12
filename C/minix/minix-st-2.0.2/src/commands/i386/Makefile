# Makefile for commands/i386.

CFLAGS	= -D_MINIX -D_POSIX_SOURCE
CCLD	= $(CC) -i $(CFLAGS)
MAKE	= exec make -$(MAKEFLAGS)

all:	acd
	cd asmconv && $(MAKE) $@

acd:	acd.c
	$(CCLD) -o $@ -DARCH=\"`arch`\" -DDESCR=\"/usr/lib/descr\" $?
	install -S 25kw $@

install:	/usr/bin/acd /usr/bin/cc /usr/bin/m2 /usr/bin/pc
	cd asmconv && $(MAKE) $@

/usr/bin/acd:	acd
	install -cs -o bin $? $@

/usr/bin/cc /usr/bin/m2 /usr/bin/pc:	/usr/bin/acd
	install -l $? $@

clean:
	rm -rf a.out core acd
	cd asmconv && $(MAKE) $@

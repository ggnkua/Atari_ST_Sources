# Makefile for commands/ibm.

# See commands/simple/Makefile for a description.

CFLAGS	= -D_MINIX -D_POSIX_SOURCE
CCLD	= $(CC) -i $(CFLAGS)
MAKE	= exec make -$(MAKEFLAGS)

all:	bin \
	bin/cdplay \
	bin/dosread \
	bin/fdisk \
	bin/format \
	bin/loadfont \
	bin/loadkeys \
	bin/mixer \
	bin/part \
	bin/partition \
	bin/playwave \
	bin/postmort \
	bin/readclock \
	bin/recwave \
	bin/repartition \
	bin/screendump \
	bin/sdump \

bin:
	mkdir bin

bin/cdplay:	cdplay.c
	$(CCLD) -o $@ -m $? -lcurses
	install -S 4kw $@

bin/dosread:	dosread.c
	$(CCLD) -o $@ $?
	install -S 16kw $@

bin/fdisk:	fdisk.c
	$(CCLD) -o $@ $?
	install -S 4kw $@

bin/format:	format.c
	$(CCLD) -m -o $@ $?
	install -S 4kw $@

bin/loadfont:	loadfont.c
	$(CCLD) -o $@ $?
	install -S 4kw $@

bin/loadkeys:	loadkeys.c
	$(CCLD) -o $@ $?
	install -S 4kw $@

bin/mixer:	mixer.c
	$(CCLD) -o $@ -m $? -lcurses
	install -S 4kw $@

bin/part:	part.c
	$(CCLD) -m -o $@ $?
	install -S 11kw $@

bin/partition:	partition.c
	$(CCLD) -o $@ $?
	install -S 4kw $@

bin/playwave:	playwave.c
	$(CCLD) -o $@ $?
	install -S 4kw $@

bin/postmort:	postmort.c
	$(CCLD) -m -o $@ $?
	install -S 4kw $@

bin/readclock:	readclock.c
	$(CCLD) -o $@ $?
	install -S 4kw $@

bin/recwave:	recwave.c
	$(CCLD) -o $@ $?
	install -S 4kw $@

bin/repartition:	repartition.c
	$(CCLD) -o $@ $?
	install -S 4kw $@

bin/screendump:	screendump.c
	$(CCLD) -o $@ $?
	install -S 8kw $@

bin/sdump:	sdump.c
	$(CCLD) -m -o $@ $?
	install -S 4kw $@

install:	bin \
	/usr/bin/cdplay \
	/usr/bin/dosread \
		/usr/bin/dosdir \
		/usr/bin/doswrite \
	/usr/bin/fdisk \
	/usr/bin/format \
	/usr/bin/loadfont \
	/usr/bin/loadkeys \
	/usr/bin/mixer \
	/usr/bin/part \
	/usr/bin/partition \
	/usr/bin/playwave \
	/usr/bin/postmort \
	/usr/bin/readclock \
	/usr/bin/recwave \
	/usr/bin/repartition \
	/usr/bin/screendump \
	/usr/bin/sdump \
	/bin/loadkeys \
	/bin/readclock \

/usr/bin/cdplay:	bin/cdplay
	install -cs -o bin $? $@

/usr/bin/dosread:	bin/dosread
	install -cs -o bin $? $@

/usr/bin/dosdir /usr/bin/doswrite:	/usr/bin/dosread
	install -l $? $@

/usr/bin/fdisk:	bin/fdisk
	install -cs -o bin $? $@

/usr/bin/format:	bin/format
	install -cs -o root -m 4755 $? $@

/usr/bin/loadfont:	bin/loadfont
	install -cs -o bin $? $@

/usr/bin/loadkeys:	bin/loadkeys
	install -cs -o bin $? $@

/usr/bin/mixer:	bin/mixer
	install -cs -o bin $? $@

/usr/bin/part:	bin/part
	install -cs -o bin $? $@

/usr/bin/partition:	bin/partition
	install -cs -o bin $? $@

/usr/bin/playwave:	bin/playwave
	install -cs -o bin $? $@

/usr/bin/postmort:	bin/postmort
	install -cs -o bin $? $@

/usr/bin/readclock:	bin/readclock
	install -cs -o bin $? $@

/usr/bin/recwave:	bin/recwave
	install -cs -o bin $? $@

/usr/bin/repartition:	bin/repartition
	install -cs -o bin $? $@

/usr/bin/screendump:	bin/screendump
	install -cs -o bin $? $@

/usr/bin/sdump:	bin/sdump
	install -cs -o bin $? $@

/bin/loadkeys:	/usr/bin/loadkeys
	install -lcs $? $@

/bin/readclock:	/usr/bin/readclock
	install -lcs $? $@

clean:
	rm -rf a.out core bin

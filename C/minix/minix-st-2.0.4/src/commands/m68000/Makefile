CC=exec /usr/bin/cc
CFLAGS	= -O -I. -D_MINIX -D_POSIX_SOURCE -I../../include

CMDAUTIL = anm asize
CMD	= aoutdump astrip cv tos loadfont \
	  mdb diskrtc diskset megartc weidertc ttrtc
CMDNEW	= binconv xformat chkrelo setvt \
	  slipmaster slipslave
CMDNOT	= cc format slip partition repartition

all:	$(CMD) $(CMDNEW)
	cd mdb; make

clean:
	rm -f *.o $(CMD) $(CMDNEW)
	cd mdb; make clean

clobber:
	rm -f $(CMD) $(CMDNEW)
	cd mdb ; make clobber

anm: anm.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 32kw $@
aoutdump: aoutdump.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 4kw $@
asize: asize.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 4kw $@
astrip: astrip.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 32kw $@
cc: cc.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 32kw $@
cv: cv.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 32kw $@
tos: tos.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 32k $@
format: format.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 16kw $@
loadfont: loadfont.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 4kw $@
megartc: megartc.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 2kw $@
ttrtc: ttrtc.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 2kw $@
weidertc: weidertc.c
	$(CC) $(CFLAGS) $@.c -o $@
	install -S 2kw $@
diskrtc: diskrtc.c
	$(CC) $(CFLAGS) diskrtc.c -o $@
	install -S 2kw $@
diskset: diskset.c
	$(CC) $(CFLAGS) diskset.c -o $@
	install -S 2kw $@
binconv: binconv.c
	$(CC) $(CFLAGS) binconv.c -o $@
	install -S 16k $@
xformat: xformat.c
	$(CC) $(CFLAGS) xformat.c -o $@
	install -S 16k $@
chkrelo: chkrelo.c
	$(CC) $(CFLAGS) chkrelo.c -o $@
	install -S 6k $@
setvt: setvt.c
	$(CC) $(CFLAGS) setvt.c -o $@
	install -S 4k $@
partition: partition.c
	$(CC) $(CFLAGS) partition.c -o $@
	install -S 4kw $@
repartition: repartition.c
	$(CC) $(CFLAGS) repartition.c -o $@
	install -S 4kw $@
#slip: slip.c
#	$(CC) $(CFLAGS) slip.c -o $@
#	install -S 2200 $@
slipmaster: slip2p.c
	$(CC) $(CFLAGS) -DMASTER slip2p.c -o $@
	install -S 9k $@
slipslave: slip2p.c
	$(CC) $(CFLAGS) slip2p.c -o $@
	install -S 9k $@

install:	\
	/usr/bin/aoutdump	\
	/usr/bin/astrip		\
	/usr/lib/cv		\
	/usr/bin/tos		\
		/usr/bin/tosdir		\
		/usr/bin/tosread	\
		/usr/bin/toswrite	\
	/usr/bin/format		\
	/usr/bin/loadfont	\
	/usr/bin/megartc	\
	/usr/bin/ttrtc		\
	/usr/bin/weidertc	\
	/usr/bin/diskrtc	\
	/usr/bin/diskset	\
	/usr/bin/binconv	\
	/usr/bin/xformat	\
	/usr/bin/chkrelo	\
	/usr/bin/setvt		\
	/usr/bin/slip		\
	/usr/bin/slipslave

#	/usr/bin/cc		\
#	/usr/bin/anm		\
#	/usr/bin/asize
#	/usr/bin/partition	\
#	/usr/bin/repartition	\

/usr/bin/aoutdump:	aoutdump
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/astrip:	astrip
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/cc:	cc
	install	-cs -o bin -g bin -m 555 $? $@

/usr/lib/cv:	cv
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/tos:	tos
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/tosdir:	/usr/bin/tos
	install	-lcs $? $@

/usr/bin/tosread:	/usr/bin/tos
	install	-lcs $? $@

/usr/bin/toswrite:	/usr/bin/tos
	install	-lcs $? $@

/usr/bin/format:	format
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/loadfont:	loadfont
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/megartc:	megartc
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/ttrtc:	ttrtc
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/weidertc:	weidertc
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/diskrtc:	diskrtc
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/diskset:	diskset
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/binconv:	binconv
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/xformat:	xformat
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/chkrelo:	chkrelo
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/setvt:	setvt
	install	-cs -o bin -g bin -m 555 $? $@

/usr/bin/partition:	partition
	install -cs -o bin -g bin -m 555 $? $@

/usr/bin/repartition:	repartition
	install -cs -o bin -g bin -m 555 $? $@

/usr/bin/slip:	slipmaster
	install -cs -o bin -g bin -m 555 $? $@

/usr/bin/slipslave:	slipslave
	install -cs -o bin -g bin -m 555 $? $@

#/usr/bin/slip:	slip
#	install -cs -o bin -g bin -m 555 $? $@

#/usr/bin/anm:
#	install	-cs -o bin -g bin -m 555 $? $@

#/usr/bin/asize:
#	install	-cs -o bin -g bin -m 555 $? $@


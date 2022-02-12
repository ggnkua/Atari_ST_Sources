CFLAGS	= -O
SRC1	= build.c boot.s type.s init.c menu.c
SRC2	= outmix.h fakeunix.c getstruc.c putstruc.c

PARTS	= ../kernel/kernel.mix ../mm/mm.mix ../fs/fs.mix init.mix menu.mix
ALL	= minix.img
LD	= /usr/lib/ld
CV	= /usr/lib/cv
l	= /usr/lib


all:	$(ALL)

cp cmp:	all

clean:
	rm -f *.o

clobber:
	rm -f $(ALL) build boot_?d type_?d minix_?d init.mix menu.mix

build:	build.c outmix.h getstruc.c putstruc.c
	cc $(CFLAGS) -DATARI_ST build.c -o $@

minix.img:	build boot_fd $(PARTS)
	./build boot_fd $(PARTS) $@

minix_fd:	build boot_fd $(PARTS)
	./build boot_fd $(PARTS) $@

minix_dd:	build boot_dd $(PARTS)
	./build boot_dd $(PARTS) $@

type_fd type_dd:	type.s
	cp type.s $@.s
	$(CC) $(CFLAGS) -DACK -D$@ -c $@.s
	$(LD) -c -o $@.out $@.o
	$(CV) =510 $@.out $@.mix
	dd if=$@.s of=$@.tmp bs=1 count=1 seek=512
	{ \
		dd if=$@.mix bs=1 skip=32; \
		dd if=$@.tmp; \
	} | dd obs=1b | dd of=$@ count=1
	rm -f $@.s $@.o $@.out $@.mix $@.tmp

boot_fd boot_dd:	boot.s
	cp boot.s $@.s
	$(CC) $(CFLAGS) -DACK -D$@ -c $@.s
	$(LD) -s -c -o $@.out $@.o
	$(CV) =510 $@.out $@.mix
	dd if=$@.mix of=$@ bs=1 skip=32
	rm -f $@.s $@.o $@.out $@.mix

init.mix:	init.o $l/head.o $l/libc.a $l/end.o
	$(LD) -c -o init.out $l/head.o init.o $l/libc.a $l/end.o
	$(CV) init.out $@
	rm -f init.out

menu.mix:	menu.o $l/head.o $l/libc.a $l/end.o
	$(LD) -c -o menu.out $l/head.o menu.o $l/libc.a $l/end.o
	$(CV) menu.out $@
	rm -f menu.out

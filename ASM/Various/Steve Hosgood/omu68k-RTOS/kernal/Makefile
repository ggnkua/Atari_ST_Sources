################################################################################
#	OMU kernal makefile
################################################################################
#
#Test options are -DTKERNAL -DTKCALLS -DTXEQ -DTFORK -DTKILL -DTEXIT -DTEXEC
#		  -DTSWAP -DTWAIT -DTPSWITCH -DTCONCUR -DTTRAPS -DTPIPES
#		  -DTEVENT
#OPTIONS= -DMBOMU -DDATESET -DVIWINDOWS
OPTIONS=-DVIWINDOWS
TEST=
#TEST=-DTEXEC
CC=cc -OPS $(TEST) $(OPTIONS)
AS=as68k

omu.o:	mcexcep.o mc.o bcache.o bio.o c.o cio.o fio.o icache.o inode.o\
	messg.o physmap.o\
	super.o sys.o uft.o exec.o bytecp.o sh.o inbin.o syscall.o\
	swap.o mount.o excep.o pipe.o new.o concur.o machine.o\
	signal.o memory.o mmu.o tsys.o event.o dmodule.o linkld.o win.o
	ld -x -r -o omu.o mcexcep.o mc.o c.o uft.o fio.o bio.o cio.o\
		inode.o icache.o\
		bcache.o super.o physmap.o sys.o exec.o messg.o\
		bytecp.o sh.o inbin.o syscall.o swap.o mount.o\
		excep.o pipe.o new.o concur.o machine.o\
		signal.o memory.o mmu.o tsys.o event.o dmodule.o linkld.o win.o

mc.o: mc.68k
	$(AS) -o mc.o mc.68k

mcexcep.o: mcexcep.68k
	$(AS) -o mcexcep.o mcexcep.68k

syscall.o: syscall.68k
	$(AS) -o syscall.o syscall.68k

bytecp.o: bytecp.68k
	$(AS) -o bytecp.o bytecp.68k

bcache.o: bcache.c ../include/buf.h ../include/dev.h ../include/param.h
bio.o: bio.c ../include/buf.h ../include/inode.h ../include/file.h\
	../include/dev.h ../include/param.h ../include/procs.h\
	../include/signal.h
c.o: c.c ../include/dev.h ../include/memory.h ../include/param.h
cio.o: cio.c ../include/file.h ../include/dev.h
concur.o: concur.c ../include/param.h ../include/inode.h ../include/procs.h\
	../include/excep.h ../include/memory.h ../include/state.h\
	../include/signal.h
dmodule.o: dmodule.c  ../include/inode.h ../include/file.h\
	../include/dev.h ../include/param.h ../include/stat.h\
	../include/dmodule.h
event.o: event.c ../include/param.h ../include/inode.h ../include/procs.h\
	../include/signal.h ../include/file.h
exec.o: exec.c ../include/param.h ../include/inode.h\
	../include/procs.h ../include/memory.h ../include/swap.h\
	../include/dev.h ../include/file.h ../include/signal.h\
	../include/inbin.h ../include/stat.h
excep.o: excep.c ../include/excep.h ../include/param.h ../include/inode.h\
	../include/procs.h ../include/signal.h
fio.o: fio.c ../include/buf.h ../include/inode.h ../include/file.h\
	../include/dev.h ../include/param.h ../include/procs.h\
	../include/signal.h ../include/stat.h
icache.o: icache.c ../include/file.h ../include/ino.h ../include/buf.h\
	../include/dev.h ../include/inode.h ../include/param.h\
	../include/stat.h
inode.o: inode.c ../include/file.h ../include/inode.h ../include/dev.h\
	../include/mount.h ../include/procs.h ../include/param.h\
	../include/signal.h ../include/stat.h
linkld.o: linkld.c ../include/file.h
machine.o: machine.c
memory.o: memory.c ../include/param.h ../include/inode.h\
	../include/procs.h ../include/memory.h ../include/signal.h
mmu.o: mmu.c ../include/param.h ../include/inode.h\
	../include/procs.h ../include/memory.h ../include/signal.h
mount.o: mount.c ../include/dev.h ../include/inode.h ../include/mount.h \
	../include/param.h ../include/stat.h
physmap.o: physmap.c ../include/inode.h ../include/buf.h ../include/param.h
pipe.o:	pipe.c ../include/param.h ../include/inode.h ../include/procs.h\
	../include/file.h ../include/dev.h ../include/signal.h
signal.o: signal.c ../include/param.h ../include/inode.h ../include/procs.h\
	../include/signal.h
super.o: super.c ../include/filsys.h ../include/fblk.h ../include/buf.h\
	../include/inode.h ../include/dev.h ../include/ino.h ../include/procs.h\
	../include/param.h ../include/signal.h
sys.o: sys.c ../include/inode.h ../include/param.h\
	../include/procs.h ../include/memory.h ../include/state.h\
	../include/signal.h ../include/dev.h ../include/stat.h
swap.o: swap.c ../include/param.h ../include/inode.h ../include/state.h\
	../include/procs.h ../include/memory.h ../include/swap.h\
	../include/file.h ../include/signal.h ../include/stat.h
sh.o: sh.c ../include/stat.h ../include/inbin.h ../include/state.h
inbin.o: inbin.c ../include/dev.h ../include/buf.h ../include/memory.h\
	../include/inbin.h ../include/stat.h ../include/param.h
uft.o: uft.c ../include/file.h ../include/inode.h ../include/param.h\
	../include/procs.h ../include/signal.h ../include/stat.h
new.o: new.c ../include/inode.h ../include/param.h\
	../include/procs.h ../include/file.h ../include/dev.h\
	../include/excep.h ../include/signal.h ../include/stat.h
linkld.o: linkld.c
win.o:	win.c
tsys.o:	tsys.c ../include/param.h ../include/procs.h ../include/signal.h

sort.o: sort.c ../include/filsys.h ../include/fblk.h ../include/buf.h\
	../include/inode.h ../include/dev.h ../include/ino.h

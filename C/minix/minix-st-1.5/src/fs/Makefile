CFLAGS	= -O

LD	= /usr/lib/ld
CV	= /usr/lib/cv
l	= /usr/lib
i	= /usr/include


OBJ	= main.o open.o read.o write.o pipe.o device.o \
	  path.o mount.o link.o super.o inode.o cache.o filedes.o \
	  stadir.o protect.o time.o misc.o utility.o table.o putc.o
HDR	= buf.h const.h dev.h file.h \
	  fproc.h fs.h glo.h inode.h \
	  param.h proto.h super.h type.h
DEP	= $i/errno.h $i/fcntl.h $i/limits.h $i/signal.h \
	  $i/minix/boot.h $i/minix/callnr.h $i/minix/com.h \
	  $i/minix/config.h $i/minix/const.h $i/minix/type.h \
	  $i/sys/stat.h $i/sys/types.h $(HDR)
ALL	= fs.mix

all:	$(ALL)

cp cmp:	all

clean:
	rm -f $(OBJ)

clobber:
	rm -f $(ALL) fs.out

fs.mix:	$(OBJ) $l/head.o $l/libc.a $l/end.o
	$(LD) -c -o fs.out $l/head.o $(OBJ) $l/libc.a $l/end.o
	$(CV) fs.out $@
	rm -f fs.out

$(OBJ):	$(DEP)

CFLAGS	= -O

LD	= /usr/lib/ld
CV	= /usr/lib/cv
l	= /usr/lib
i	= /usr/include


OBJ	= main.o forkexit.o break.o exec.o signal.o getset.o \
	  alloc.o utility.o table.o putc.o trace.o
HDR	= const.h glo.h mm.h mproc.h \
	  param.h proto.h type.h
DEP	= $i/errno.h $i/limits.h $i/signal.h \
	  $i/minix/callnr.h $i/minix/com.h $i/minix/config.h \
	  $i/minix/const.h $i/minix/type.h \
	  $i/sys/stat.h $i/sys/types.h $(HDR)
ALL	= mm.mix

all:	$(ALL)

cp cmp:	all

clean:
	rm -f $(OBJ)

clobber:
	rm -f $(ALL) mm.out

mm.mix:	$(OBJ) $l/head.o $l/libc.a $l/end.o
	$(LD) -c -o mm.out $l/head.o $(OBJ) $l/libc.a $l/end.o
	$(CV) mm.out $@
	rm -f mm.out

$(OBJ):	$(DEP)

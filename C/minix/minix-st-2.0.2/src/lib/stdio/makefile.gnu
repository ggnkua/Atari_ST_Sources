# Makefile for lib/stdio.

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS)

CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= $(LIBC)
all:	$(LIBRARY)

OBJECTS	= \
	clearerr.o \
	data.o \
	doprnt.o \
	doscan.o \
	ecvt.o \
	fclose.o \
	feof.o \
	ferror.o \
	fflush.o \
	fgetc.o \
	fgetpos.o \
	fgets.o \
	fileno.o \
	fillbuf.o \
	flushbuf.o \
	fopen.o \
	fprintf.o \
	fputc.o \
	fputs.o \
	fread.o \
	freopen.o \
	fscanf.o \
	fseek.o \
	fsetpos.o \
	ftell.o \
	fwrite.o \
	getc.o \
	getchar.o \
	gets.o \
	icompute.o \
	perror.o \
	printf.o \
	putc.o \
	putchar.o \
	puts.o \
	remove.o \
	rewind.o \
	scanf.o \
	setbuf.o \
	setvbuf.o \
	sprintf.o \
	sscanf.o \
	tmpfile.o \
	tmpnam.o \
	ungetc.o \
	vfprintf.o \
	vprintf.o \
	vscanf.o \
	vsprintf.o \
	vsscanf.o \

$(LIBRARY):	$(OBJECTS)
	$(AR) $(ARFLAGS) $@ *.o
	$(RM) *.o

clean:
	$(RM) *.o

clearerr.o:	clearerr.c
	$(CC1) clearerr.c

data.o:	data.c
	$(CC1) data.c

doprnt.o:	doprnt.c
	$(CC1) doprnt.c

doscan.o:	doscan.c
	$(CC1) doscan.c

ecvt.o:	ecvt.c
	$(CC1) ecvt.c

fclose.o:	fclose.c
	$(CC1) fclose.c

feof.o:	feof.c
	$(CC1) feof.c

ferror.o:	ferror.c
	$(CC1) ferror.c

fflush.o:	fflush.c
	$(CC1) fflush.c

fgetc.o:	fgetc.c
	$(CC1) fgetc.c

fgetpos.o:	fgetpos.c
	$(CC1) fgetpos.c

fgets.o:	fgets.c
	$(CC1) fgets.c

fileno.o:	fileno.c
	$(CC1) fileno.c

fillbuf.o:	fillbuf.c
	$(CC1) fillbuf.c

flushbuf.o:	flushbuf.c
	$(CC1) flushbuf.c

fopen.o:	fopen.c
	$(CC1) fopen.c

fprintf.o:	fprintf.c
	$(CC1) fprintf.c

fputc.o:	fputc.c
	$(CC1) fputc.c

fputs.o:	fputs.c
	$(CC1) fputs.c

fread.o:	fread.c
	$(CC1) fread.c

freopen.o:	freopen.c
	$(CC1) freopen.c

fscanf.o:	fscanf.c
	$(CC1) fscanf.c

fseek.o:	fseek.c
	$(CC1) fseek.c

fsetpos.o:	fsetpos.c
	$(CC1) fsetpos.c

ftell.o:	ftell.c
	$(CC1) ftell.c

fwrite.o:	fwrite.c
	$(CC1) fwrite.c

getc.o:	getc.c
	$(CC1) getc.c

getchar.o:	getchar.c
	$(CC1) getchar.c

gets.o:	gets.c
	$(CC1) gets.c

icompute.o:	icompute.c
	$(CC1) icompute.c

perror.o:	perror.c
	$(CC1) perror.c

printf.o:	printf.c
	$(CC1) printf.c

putc.o:	putc.c
	$(CC1) putc.c

putchar.o:	putchar.c
	$(CC1) putchar.c

puts.o:	puts.c
	$(CC1) puts.c

remove.o:	remove.c
	$(CC1) remove.c

rewind.o:	rewind.c
	$(CC1) rewind.c

scanf.o:	scanf.c
	$(CC1) scanf.c

setbuf.o:	setbuf.c
	$(CC1) setbuf.c

setvbuf.o:	setvbuf.c
	$(CC1) setvbuf.c

sprintf.o:	sprintf.c
	$(CC1) sprintf.c

sscanf.o:	sscanf.c
	$(CC1) sscanf.c

tmpfile.o:	tmpfile.c
	$(CC1) tmpfile.c

tmpnam.o:	tmpnam.c
	$(CC1) tmpnam.c

ungetc.o:	ungetc.c
	$(CC1) ungetc.c

vfprintf.o:	vfprintf.c
	$(CC1) vfprintf.c

vprintf.o:	vprintf.c
	$(CC1) vprintf.c

vscanf.o:	vscanf.c
	$(CC1) vscanf.c

vsprintf.o:	vsprintf.c
	$(CC1) vsprintf.c

vsscanf.o:	vsscanf.c
	$(CC1) vsscanf.c

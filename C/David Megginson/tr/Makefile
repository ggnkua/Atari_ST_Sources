#################################################################
#	Makefile for tr(1v) character translation filter
#################################################################

#	Flags for DEF
#	-DBUFFER_SIZE=n		i/o buffer memory (default 50000)
#	-DCHARSET_SIZE=n	character set size (default 256)
#	-DSKIP_CR		try to handle CRLF
DEF =
OPT = -O -fcombine-regs -fstrength-reduce -fomit-frame-pointer

#
#	Options for compiler and linker
#
CFLAGS = $(OPT) $(DEF)
LDFLAGS = -s
OBJ = tr.o

#
#	Extra libraries to link with.
#
LIBES = -liio

#
#	Target program name and directory for binary.
#
PROG = tr.ttp
BINDIR = e:/bin

#
#	Production rules
#
$(PROG): $(OBJ)
	$(CC) -o $@ $(LDFLAGS) $(OBJ) $(LIBES)

tr.zoo: $(PROG) Makefile README $(PROG)
	rm -f $@
	zoo a $@ README tr.c Makefile $(PROG)

tr.uue: tr.zoo
	rm -f $@
	uue tr.zoo

install: $(PROG)
	cp $(PROG) $(BINDIR)

clean:
	rm -f $(OBJ) core

clobber: clean
	rm -f $(PROG) tr.zoo tr.uue

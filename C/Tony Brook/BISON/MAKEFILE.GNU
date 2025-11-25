# Makefile for bison

DESTDIR=
# where the installed binary goes
BINDIR = $(DESTDIR)/usr/local

# where the parsers go
PARSERDIR = $(DESTDIR)/usr/local/lib

# names of parser files
PFILE = bison.simple
PFILE1 = bison.hairy

# It is unwise ever to compile a program without symbols.
CFLAGS = -g

PFILES = -DXPFILE=\"$(PARSERDIR)/$(PFILE)\" \
	 -DXPFILE1=\"$(PARSERDIR)/$(PFILE1)\"

OBJECTS = LR0.o allocate.o closure.o conflicts.o derives.o files.o	\
	  getargs.o gram.o lalr.o					\
	  lex.o main.o nullable.o output.o print.o reader.o symtab.o	\
	  warshall.o

start: bison

clean:
	rm -f *.o core bison

install: bison
	install bison $(BINDIR)
	cp $(PFILE) $(PFILE1) $(PARSERDIR)

bison: $(OBJECTS)
	$(CC) $(LDFLAGS) -o bison $(OBJECTS)

# This file is different to pass the parser file names
# to the compiler.
files.o: files.c files.h new.h gram.h
	$(CC) -c $(CFLAGS) $(PFILES) files.c

LR0.o: machine.h new.h gram.h state.h
closure.o: machine.h new.h gram.h
conflicts.o: machine.h new.h files.h gram.h state.h
derives.o: new.h types.h gram.h
getargs.o: files.h
lalr.o: machine.h types.h state.h new.h gram.h
lex.o: files.h symtab.h lex.h
main.o: machine.h
nullable.o: types.h gram.h new.h
output.o: machine.h new.h files.h gram.h state.h
print.o: machine.h new.h files.h gram.h state.h
reader.o: files.h new.h symtab.h lex.h gram.h
symtab.o: new.h symtab.h gram.h
warshall.o: machine.h

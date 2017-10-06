# Makefile for the turingol parser

# Set all this junk if you're running GNU.
# CFLAGS = -g -Wall
#LEX = flex
#LFLAGS = -s
#YACC = bison
#YFLAGS = -d -y
YFLAGS = -d

VERSION=1.0.0

objects = parser.o lexer.o symtabs.o output.o tape.o
others = parser.c lexer.c y.tab.h

all: turingol

turingol: $(objects)
	$(CC) -o turingol $(objects)

parser.o: parser.c

parser.c: parser.y lexer.h symtabs.h output.h

lexer.o: lexer.c y.tab.h

lexer.c: lexer.l lexer.h 

symtabs.o: symtabs.c symtabs.h y.tab.h tape.h

output.o: output.c output.h symtabs.h

tape.o: tape.c tape.h symtabs.h

clean:
	rm -f turingol $(objects) $(others) core turingol-$(VERSION).tar.gz

# For distribution.
SRC = README,COPYING,*.[ylch],doc,progs,*.html,Makefile
turingol-$(VERSION).tar.gz:
	@-mv turingol turingol.bin
	(cd ..; ln -sf turingol turingol-$(VERSION))
	(cd ..; tar -czf turingol-$(VERSION).tar.gz turingol/{$(SRC)})
	mv -f ../turingol-$(VERSION).tar.gz .
	rm -f ../turingol-$(VERSION) turingol
	@-mv turingol.bin turingol

dist: turingol-$(VERSION).tar.gz






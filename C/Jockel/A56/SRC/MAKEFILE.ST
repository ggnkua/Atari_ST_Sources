#######################################################
#
#  a56 - a DSP56001 assembler
#
#  Written by Quinn C. Jensen
#  July 1990
#
#######################################################

# environment definitions
# uncomment the ones you like

# generic unix
#CC = cc
#HOSTCC = cc
#YACC = yacc
#CCDEFS =
#MV = mv
#YTABC = y.tab.c
#YTABH = y.tab.h
#POSTPROCESS = echo

# gcc & bison
#CC = gcc
#HOSTCC = gcc
#YACC = bison -y
#CCDEFS =
#MV = mv
#YTABC = y.tab.c
#YTABH = y.tab.h
#POSTPROCESS = echo

# Delorie's DOS gcc (from ftp://omnigate.clarkson.edu/pub/msdos/djgpp)
#CC = gcc
#HOSTCC = gcc
#YACC = bison -y
#CCDEFS =
#MV = ren
#YTABC = y_tab.c
#YTABH = y_tab.h
#POSTPROCESS = coff2exe

# gcc cross-compile to go32 environment
#CC = i386-go32-gcc
#HOSTCC = cc
#YACC = yacc
#CCDEFS =
#MV = mv
#YTABC = y.tab.c
#YTABH = y.tab.h
#POSTPROCESS = coff2exe

# gcc cross-compile for atari computers
CC = cgcc
HOSTCC = gcc
YACC = bison -y
CCDEFS =
MV = mv
YTABC = y.tab.c
YTABH = y.tab.h
POSTPROCESS = echo

#######################################################

# -O or -g
DEBUG = -O

SRCS = main.c a56.y lex.c subs.c getopt.c kparse.key
OBJS = main.o gram.o lex.o toktab.o subs.o getopt.o kparse.o

DEFINES = $(CCDEFS)
#DEFINES = -DYYDEBUG -DLDEBUG $(CCDEFS)

CFLAGS = $(DEBUG) $(DEFINES)

all:	keybld a56 toomf

a56:	$(OBJS)
	$(CC) $(CFLAGS) -o a56.ttp $(OBJS)
	@$(POSTPROCESS) a56.ttp
	xstrip a56.ttp

keybld:	keybld.o ksubs.o
	$(HOSTCC) $(CFLAGS) -o keybld keybld.o ksubs.o
	@$(POSTPROCESS) keybld

keybld.o:	keybld.c
	$(HOSTCC) $(CFLAGS) -c keybld.c

ksubs.o:	subs.c
	$(HOSTCC) $(CFLAGS) -c subs.c
	$(MV) subs.o ksubs.o

lex.o:	lex.c gram.h

kparse.c:	a56.key keybld
	keybld < a56.key > kparse.c

gram.c gram.h:	a56.y
	@echo "[expect 2 shift/reduce conflicts here]"
	$(YACC) -d a56.y
	$(MV) $(YTABC) gram.c
	$(MV) $(YTABH) gram.h

toktab.c:	gram.h
	awk -f tok.awk < gram.h > toktab.c

y.output:	a56.y
	$(YACC) -v a56.y

toomf:	toomf.o
	$(CC) -o toomf.ttp $(CFLAGS) toomf.o
	@$(POSTPROCESS) toomf.ttp
	xstrip toomf.ttp

tape:	toktab.c
	csh -c 'tar cvbf 1 - `cat files` | gzip > a56.tar.gz'

main.o gram.o lex.o:	a56.h

clean:	; rm -f a56 toomf y.output *.o *.out tmp *.bak a56.tar.gz keybld

spotless:	clean
	rm -f gram.c lexyy.c gram.h toktab.c kparse.c

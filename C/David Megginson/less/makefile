# Makefile for "less"

#
# Invoked as:
#	make all
#   or	make install
# Plain "make" is equivalent to "make all".
#
# If you add or delete functions, remake funcs.h by doing:
#	make newfuncs
# This depends on the coding convention of function headers looking like:
#	" \t public <function-type> \n <function-name> ( ... ) "
#
# Also provided:
#	make lint	# Runs "lint" on all the sources.
#	make clean	# Removes "less" and the .o files.
#	make clobber	# Pretty much the same as make "clean".

SHELL = g:/bin/init.prg

##########################################################################
# Compilation environment.
##########################################################################

# LIBS is the list of libraries needed.
LIBS = -ltermcap -liio

# INSTALL_LESS is a list of the public versions of less.
# INSTALL_KEY is a list of the public versions of lesskey.
# INSTALL_HELP is a list of the public version of the help file.
# INSTALL_LESSMAN is a list of the public versions of the less manual page.
# INSTALL_KEYMAN is a list of the public versions of the lesskey manual page.
INSTALL_LESS =		/dev/G/bin/less.ttp
INSTALL_KEY =		/dev/G/bin/lesskey.ttp
INSTALL_HELP =		/dev/E/etc/less.help
INSTALL_LESSMAN =	/dev/E/man/less.man
INSTALL_KEYMAN =	/dev/E/man/lesskey.man
LESS_MANUAL =		less.man
KEY_MANUAL =		lesskey.man
HELPFILE =		'(getenv("LESSHELP")?getenv("LESSHELP"):"less.help")'

DOCS = readme.st readme less.man lesskey.man less.nroff lesskey.nroff

# OPTIM is passed to the compiler and the loader.
# It is normally "-O" but may be, for example, "-g".
OPTIM = -O -fcombine-regs -fomit-frame-pointer

CFLAGS = $(OPTIM)
LDFLAGS = -s


##########################################################################
# Files
##########################################################################

SRC1 =	main.c option.c prim.c ch.c position.c input.c linenum.c
SRC2 =	screen.c prompt.c line.c signal.c os.c help.c ttyin.c command.c
SRC3 =	output.c decode.c tags.c version.c
SRC =	$(SRC1) $(SRC2) $(SRC3)
HEADERS = cmd.h defines.h funcs.h less.h position.h

OBJ =	main.o option.o prim.o ch.o position.o input.o output.o \
	screen.o prompt.o line.o signal.o os.o help.o ttyin.o \
	decode.o command.o linenum.o tags.o version.o


##########################################################################
# Rules for building stuff
##########################################################################

all: less.ttp lesskey.ttp
install: install_less install_help install_key install_lman install_kman


less.ttp: $(OBJ)
	$(CC) $(LDFLAGS) $(OPTIM) -o less.ttp $(OBJ) $(LIBS) $(LDLIBS)

lesskey.ttp: lesskey.o
	$(CC) $(LDFLAGS) $(OPTIM) -o lesskey.ttp lesskey.o $(LDLIBS)

# help.o depends on makefile for the definition of HELPFILE
help.o: makefile
	$(CC) $(CFLAGS) -c -DHELPFILE=$(HELPFILE) help.c

install_less: less.ttp
	cp less.ttp $(INSTALL_LESS)

install_key: lesskey.ttp
	cp lesskey.ttp $(INSTALL_KEY)

install_help: less.help
	cp less.help $(INSTALL_HELP)

install_lman: $(LESS_MANUAL) 
	cp $(LESS_MANUAL) $(INSTALL_LESSMAN)

install_kman: $(KEY_MANUAL)
	cp $(KEY_MANUAL) $(INSTALL_KEYMAN)


##########################################################################
# Maintenance
##########################################################################

zoo: lessbin.zoo lesssrc.zoo

lessbin.zoo: all
	zoo a lessbin less.ttp lesskey.ttp $(DOCS)

lesssrc.zoo: $(SRC)
	zoo a lesssrc $(DOCS) makefile mkfuncs.awk $(SRC) $(HEADERS) linstall

lint:
	lint -hp $(SRC)

newfuncs funcs.h:
	awk -f mkfuncs.awk $(SRC) >funcs.h

clean:
	rm -f $(OBJ) lesskey.o

clobber:
	rm -f $(OBJ) lesskey.o less.ttp lesskey.ttp


##########################################################################
# Dependencies
##########################################################################

$(OBJ): less.h funcs.h defines.h position.h
command.o decode.o: cmd.h
lesskey.o: less.h funcs.h defines.h cmd.h


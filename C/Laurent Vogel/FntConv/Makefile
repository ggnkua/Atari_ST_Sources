#
# Makefile suitable for Linux and Cygwin setups
#

#
# crude machine detection (Unix or Cygwin)
#

ifneq (,$(findstring CYGWIN,$(shell uname)))
# CYGWIN-dependent stuff
EXE = .exe
else
# ordinary Unix stuff
EXE = 
endif

#
# compiler flags
#

CC = gcc
CFLAGS = -Wall

#
# main targets
#

OBJ = fntconv.o

all: fntconv$(EXE)

fntconv$(EXE): $(OBJ)
	$(CC) -o $@ $(OBJ)

#
# Automatic build rules
#

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

#
# test
#

test:	fntconv$(EXE) Test/test.txt Test/result.txt
	@rm -f tmp.fnt tmp.txt
	./fntconv Test/test.txt -o tmp.fnt 
	./fntconv tmp.fnt -o tmp.txt
	diff Test/result.txt tmp.txt
	@echo "test succeeds"
	@rm -f tmp.fnt tmp.txt

#
#
#

clean:
	rm -f $(OBJ) tmp.fnt tmp.txt

distclean: clean
	rm -f fntconv$(EXE)

#
# create a tgz archive named project-nnnnnn.tgz,
# where nnnnnn is the date.
#

HERE = $(shell pwd)
HEREDIR = $(shell basename $(HERE))
TGZ = $(shell echo $(HEREDIR)-`date +%y%m%d`|tr A-Z a-z).tgz

tgz:	distclean
	cd ..;\
	tar -cf - --exclude '*CVS' $(HEREDIR) | gzip -c -9 >$(TGZ)


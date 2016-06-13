#
# makefile for ppm2fli
#

# ---------------- Config Section ----------------------------------
# Compiler to be used
CC=gcc

#
# Cflags
#
CFLAGS=-O2 -Wall
# ------------------------------------------------------------------

.c.o:
	$(CC) $(CFLAGS) -c $*.c

#
# All targets
#
all: ppm2fli unflick

#
# Objects for ppm2fli
#
OBJA = \
	amain.o \
	alist.o \
	aoctree.o \
	aimage.o \
	aframe.o \
	acolor.o \
	abrun.o \
	alc.o \
	adelta.o \
	ainput.o \
	appm.o \
	afbm.o

#
# Objects for unflick
#
OBJU = \
	umain.o \
	uunfli.o \
	uwchunks.o \
	uoutput.o

#
# Executables
#
ppm2fli: $(OBJA)
	gcc -o $@ $(OBJA)

unflick: $(OBJU)
	gcc -o $@ $(OBJU)

#
# Dependecies
#
$(OBJA) : apro.h
$(OBJU) : upro.h

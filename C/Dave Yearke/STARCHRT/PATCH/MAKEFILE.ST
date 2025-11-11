#
# Author: Petri Launiainen, Intrinsic Oy, Tampere, FINLAND (pl@intrin.FI)
#
# Based on the work of Alan W. Paeth
#
# Modified by Dave Yearke (dgy@sigmast) for the Atari ST,
# using Mark Williams C, version 3.0.6.

LOCAL=-DST_MWC
#
# put the Yale Star Catalog file path here: because the yale.star is
# static (stars don't change so often :->), consider using some static
# library path here - relative one is used for quick testing

STAR = "yale.str"

# similarly assign the Messier file path:

MESS = "messier.str"

# and the constellation finder file:

CONS = "con.loc"

# put the planet position file path here: it should be preferably
# relative, thus allowing everyone to change planet positions according
# to their interests.  This file changes when the 'planet' program is
# executed

PLANET = "planet.str"

# notice that starchart.o and planet are made dependent on Makefile, due
# to the STARFILE, MESSFILE, CONSTFILE and PLANETFILE definitions here

CFLAGS = -VCOMPAC -VPEEP -DSTARFILE='$(STAR)' -DPLANETFILE='$(PLANET)' \
         -DCONSTFILE='$(CONS)' -DMESSFILE='$(MESS)' $(LOCAL)
# MWC needs -f to include floating point printf() routines
LFLAGS = -s -f
LIBS= -lm

# star chart calculation routine file

COBJ = starchrt.o

# default binary names: if you change these, change also the corresponding
# make tags

BINS = epoch.ttp moonphse.tos planet.ttp starlase.ttp starpost.ttp starst.ttp

test:
	starst -c ori

all:	\
	planet.ttp\
	starpost.ttp\
	starlase.ttp\
	starst.ttp\
	epoch.ttp\
	moonphse.tos
	@echo Everything has been compiled.

starchrt.o: starchrt.c Makefile starchrt.h

moonphse.tos: moonphse.c
	cc $(CFLAGS) $(LFLAGS) moonphse.c $(LIBS) -o $@

epoch.ttp: epoch.c
	cc $(CFLAGS) $(LFLAGS) epoch.c $(LIBS) -o $@

# DO NOT use -DCOMPAC on planet or the linker will go nuts!
test.ttp: test.c Makefile
	cc $(LFLAGS) $(LOCAL) -DPLANETFILE='$(PLANET)' -VPEEP \
	   test.c $(LIBS) -o $@

planet.ttp: planet.c Makefile
	cc $(LFLAGS) $(LOCAL) -DPLANETFILE='$(PLANET)' -VPEEP \
	   planet.c $(LIBS) -o $@

starlase.ttp: $(COBJ) starlase.o starimag.o
	cc $(LFLAGS) $(COBJ) starlase.o starimag.o $(LIBS) -o $@

starpost.ttp: $(COBJ) starpost.o
	cc $(LFLAGS) $(COBJ) starpost.o $(LIBS) -o $@

# Recompile starchrt.o to elide the die() function.
starst.ttp: starst.o
	cc $(CFLAGS) -DINTERACTIVE -c starchrt.c
	cc $(LFLAGS) $(COBJ) starst.o $(LIBS) -laes -lvdi -o $@
	rm starchrt.o

starargs.tos: starargs.c
	cc -s -VSMALL -VPEEP starargs.c -o $@

staranim.ttp: staranim.c
	cc -s -VSMALL -VPEEP staranim.c -o $@
clean:
	rm -f *.o mlog core

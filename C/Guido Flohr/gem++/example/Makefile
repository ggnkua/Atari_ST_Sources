SRC=ex_canv.cc ex_clock.cc ex_desk.cc ex_dupl.cc ex_fly.cc ex_font.cc \
	ex_fsel.cc ex_img.cc ex_key.cc ex_menu.cc ex_parts.cc ex_var.cc \
	ex_text.cc

MAINSRC=example.cc acc.cc
PROGS=example.prg acc.acc
OBJ=$(subst .cc,.o,$(SRC))
#LDLIBS=-lgem++ext -lgem++ -lgem -lg++
LDLIBS=-L../ -lgempp -lgem -lg++
LDFLAGS=

GXXINC:=$(INC),$(GXXINC)

CXXFLAGS:=$(CXXFLAGS) -Wall -O2 -I. -I.. -I../.. -DHAVE_CONFIG_H

current: example.prg

all:	$(PROGS)

tfont: tfont.o
	$(LINK.o) $(LDFLAGS) $^ $(LDLIBS) -o $@

acc.acc: acc.o
	$(LINK.o) $(LDFLAGS) $^ $(LDLIBS) -o $@

example.prg: example.o
	$(LINK.o) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(PROGS):	$(OBJ)

clean:
	rm $(OBJ) $(subst .cc,.o,$(MAINSRC))

clobber: clean
	rm $(PROGS)

depend:
	-$(CC) -MM $(SRC) $(MAINSRC) >/tmp/make.123
	sed 's/[a-z]:[^ ]*//g' /tmp/make.123 >depends
	rm /tmp/make.123

#include depends

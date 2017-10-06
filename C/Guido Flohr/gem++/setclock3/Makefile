SRC=sc.cc clkmenu.cc clk_main.cc clk_kbd.cc ex_key.cc
LDLIBS=-L.. -lgempp -lgem
LDFLAGS=
CPPFLAGS=-Wall -O2 -I. -I.. -I../.. -DHAVE_CONFIG_H
OBJ=$(subst .cc,.o,$(SRC))

sc.app: sc.o
	rm -f sc.app
	$(LINK.o) $(LDFLAGS) $^ $(LDLIBS) -o $@

sc.app:	$(OBJ) ../libgempp.a

clean:
	rm -f $(OBJ)

VERSION=0.1

DEBUG=-g # -D_DEBUG=1

CXXFLAGS+=-Wall -O3 -ffast-math -DVERSION=\"$(VERSION)\" $(DEBUG)
LDFLAGS+=$(DEBUG)

OBJS=error.o ctp.o

all: ctp

ctp: $(OBJS)
	$(CXX) -Wall -W $(OBJS) $(LDFLAGS) -o ctp

install: ctp
	cp ctp $(PREFIX)/bin

clean:
	rm -f $(OBJS) ctp

package: clean
	mkdir cad3d_to_pov-$(VERSION)
	cp *.c* Makefile readme.txt license.txt cad3d_to_pov-$(VERSION)
	tar czf cad3d_to_pov-$(VERSION).tgz cad3d_to_pov-$(VERSION)
	rm -rf cad3d_to_pov-$(VERSION)

check:
	cppcheck -v --enable=all --std=c++11 --inconclusive -I. . 2> err.txt

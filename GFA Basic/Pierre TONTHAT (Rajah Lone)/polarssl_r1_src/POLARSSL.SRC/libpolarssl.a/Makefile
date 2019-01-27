
DESTDIR=/opt/cross-mint/m68k-atari-mint

all:
	cd library  && $(MAKE) libpolarssl.a && cd ..

	cp -r include/polarssl/*.h $(DESTDIR)/include/polarssl

clean:
	cd library  && $(MAKE) clean && cd ..

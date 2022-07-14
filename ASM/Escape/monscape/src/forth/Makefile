CROSS_DEV_PREFIX := ../../tool/install/bin/m68k-

default: forth.prg

forth.o: app.f app.s

forth.prg: forth.o
	$(CROSS_DEV_PREFIX)ld forth.o -o $@

forth.o: forth.s
	$(CROSS_DEV_PREFIX)as -march=68030 $< -o $@

clean:
	rm -f *.o forth.prg

CROSS_DEV_PREFIX := ../../../tool/install/bin/m68k-

default: replay.prg

wrap.o: replay.s pt_src50.s wrap.s $(MAKEFILE_LIST)

wrap.o: nomore.mod

nomore.mod:
	ln -s ../ray/$@ $@

replay.prg: wrap.o
	$(CROSS_DEV_PREFIX)ld --mprg-flags 3 $< -o $@

%.o: %.s
	$(CROSS_DEV_PREFIX)as --mri -march=68030 $< -o $@

clean:
	rm -f *.o replay.prg nomore.mod

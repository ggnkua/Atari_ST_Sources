CROSS_DEV_PREFIX := ../../tool/install/bin/m68k-

PWD    := $(shell pwd)
TARGET ?= $(addsuffix .prg,$(notdir $(PWD)))

default: $(TARGET)

$(TARGET): forth.o
	$(CROSS_DEV_PREFIX)ld --mprg-flags 3 $^ -o $@

ASM_DEPS := $(wildcard ../lib/*.s ../forth/*.s *.s)

forth.o: app.f $(ASM_DEPS) $(MAKEFILE_LIST)

forth.o: forth.s
	$(CROSS_DEV_PREFIX)as -march=68030 $< -o $@

vpath forth.s ../forth/

clean_objects:
	rm -f *.o

clean_target:
	rm -f $(TARGET)

clean: clean_objects clean_target

ifneq (yes,$(VERBOSE))
	Q=@
else
	Q=
endif

ifneq (,$(filter $(COMPILE_ELF),Y yes))
CC=m68k-atari-mintelf-gcc
else
CC=m68k-atari-mint-gcc
endif
APP=dirent.tos

BUILD_FAST=$(shell if $(CC) -mfastcall -E - < /dev/null >/dev/null 2>&1; then echo Y; else echo N; fi)
ifeq ($(BUILD_FAST), Y)
LIBDIR = ../../build/$(shell $(CC) -mfastcall -print-multi-directory)
MFASTCALL = -mfastcall
else
LIBDIR:=../../build/$(shell $(CC) -print-multi-directory)
MFASTCALL =
endif

INCLUDE=-I../../include
LIBS=-nostdlib -L$(LIBDIR) -lcmini -lgcc -lcmini
OBJS=dirent.o
CFLAGS=\
	-mcpu=68000 $(MFASTCALL) \
	-fomit-frame-pointer\
	-Os\
	$(INCLUDE)

all: $(APP)

$(APP): $(LIBDIR)/libcmini.a $(OBJS)
	$(Q)echo "CC $(@)"
	$(Q)$(CC) ../../build/objs/crt0.o -s -o $(APP) $(OBJS) $(CFLAGS) $(LIBS)

	
clean:
	- $(Q)rm -f $(APP) $(OBJS) 

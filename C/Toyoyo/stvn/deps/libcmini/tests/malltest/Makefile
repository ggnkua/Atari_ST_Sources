ifneq (yes,$(VERBOSE))
	Q=@
else
	Q=
endif

CROSS=Y

ifneq (,$(filter $(COMPILE_ELF),Y yes))
CROSSBINDIR_IS_Y=m68k-atari-mintelf-
else
CROSSBINDIR_IS_Y=m68k-atari-mint-
endif
CROSSBINDIR_IS_N=

BUILD_CF=N
BUILD_FAST=$(shell if $(CC) -mfastcall -E - < /dev/null >/dev/null 2>&1; then echo Y; else echo N; fi)

CROSSBINDIR=$(CROSSBINDIR_IS_$(CROSS))

UNAME := $(shell uname)
ifeq ($(CROSS), Y)
ifeq ($(UNAME),Linux)
PREFIX=m68k-atari-mint
HATARI=hatari
else
PREFIX=m68k-atari-mint
HATARI=/usr/local/bin/hatari
endif
else
PREFIX=/usr
endif

DEPEND=depend

INCLUDE=-I../../include -nostdlib
LIBS=-lcmini -nostdlib -lgcc -lcmini

CC=$(CROSSBINDIR)gcc
STRIP=$(CROSSBINDIR)strip
STACK=$(CROSSBINDIR)stack

APP=malltest.ttp
TEST_APP=$(APP)

CFLAGS=\
	-O3\
	-g\
	-Wl,-Map,mapfile\
	-Wall
	
SRCDIR=sources
INCDIR=include
INCLUDE+=-I$(INCDIR)

CSRCS=\
	$(SRCDIR)/malltest.c

COBJS=$(patsubst $(SRCDIR)/%.o,%.o,$(patsubst %.c,%.o,$(CSRCS)))
AOBJS=$(patsubst $(SRCDIR)/%.o,%.o,$(patsubst %.S,%.o,$(ASRCS)))
OBJS=$(COBJS) $(AOBJS)

TRGTDIRS=. ./m68020-60 ./mshort ./m68020-60/mshort
ifeq ($(BUILD_FAST), Y)
	TRGTDIRS += ./mfastcall ./m68020-60/mfastcall ./mshort/mfastcall ./m68020-60/mshort/mfastcall
endif
ifeq ($(BUILD_CF), Y)
	TRGTDIRS += ./m5475 ./m5475/mshort
	ifeq ($(BUILD_FAST), Y)
	TRGTDIRS += ./m5475/mfastcall ./m5475/mshort/mfastcall
	endif
endif

OBJDIRS=$(patsubst %,%/objs,$(TRGTDIRS))

all: dirs $(patsubst %,%/$(APP),$(TRGTDIRS))

#
# multilib flags. These must match m68k-atari-mint-gcc -print-multi-lib output
#
m68020-60/$(APP): CFLAGS += -m68020-60
m5475/$(APP): CFLAGS += -mcpu=5475
mshort/$(APP): CFLAGS += -mshort
m68020-60/mshort/$(APP): CFLAGS += -m68020-60 -mshort
m5475/mshort/$(APP): CFLAGS += -mcpu=5475 -mshort
m5475/mshort/mfastcall/$(APP): CFLAGS += -mcpu=5475 -mshort -mfastcall
m5475/mfastcall/$(APP): CFLAGS += -mcpu=5475 -mfastcall
mfastcall/$(APP): CFLAGS += -mfastcall
m68020-60/mfastcall/$(APP): CFLAGS += -m68020-60 -mfastcall
mshort/mfastcall/$(APP): CFLAGS += -mshort -mfastcall
m68020-60/mshort/mfastcall/$(APP): CFLAGS += -m68020-60 -mshort -mfastcall

MULTILIBDIRECTORY = `$(CC) $$(CFLAGS) -print-multi-directory`


dirs::
	mkdir -p $(TRGTDIRS) $(OBJDIRS)

ifneq ($(DEVKITMINT),) 
# ardi's toolchain stuff
APP := $(APP:.ttp=.elf)
STRIP := @echo "dont strip ELF-file befor tostool is done --> skip stripping of "

ctest: $(TEST_APP:.elf=.ttp)

%.ttp: %.elf
	tostool $< $@
	rm $<
else

ctest: $(TEST_APP)

endif

#
# generate pattern rules for multilib object files.
#
define CC_TEMPLATE
$(1)/objs/%.o:$(SRCDIR)/%.c
	$(Q)echo "CC $$(@)"
	$(Q)$(CC) $$(CFLAGS) $(INCLUDE) -c $$< -o $$@

$(1)/%.o:$(SRCDIR)/%.S
	$(Q)echo "CC $$(@)"
	$$(Q)$(CC) $$(CFLAGS) $(INCLUDE) -c $$< -o $$@

$(1)_OBJS=$(patsubst %,$(1)/objs/%,$(OBJS))
$(1)/$(APP): $$($(1)_OBJS)
	$$(Q)echo "CC $$(@)"
	$$(Q)$(CC) $$(CFLAGS) -o $$@ ../../build/$(1)/objs/crt0.o $$($(1)_OBJS) -L../../build/$(1) $(LIBS)
endef
$(foreach DIR,$(TRGTDIRS),$(eval $(call CC_TEMPLATE,$(DIR))))

$(DEPEND): $(ASRCS) $(CSRCS)
	$(Q)-rm -f $(DEPEND)
	$(Q)for d in $(TRGTDIRS);\
		do $(CC) $(CFLAGS) $(INCLUDE) -M $(ASRCS) $(CSRCS) | sed -e "s#^\(.*\).o:#$$d/objs/\1.o:#" >> $(DEPEND); \
    done


clean:
	@rm -f $(patsubst %,%/objs/*.o,$(TRGTDIRS)) $(patsubst %,%/$(APP),$(TRGTDIRS))
	@rm -f $(DEPEND) mapfile

.PHONY: printvars
printvars:
	@$(foreach V,$(.VARIABLES), $(if $(filter-out environment% default automatic, $(origin $V)),$(warning $V=$($V))))
	 
ifneq (clean,$(MAKECMDGOALS))
-include $(DEPEND)
endif

test: $(TEST_APP)
	$(HATARI) --grab -w --tos ../emutos/etos512k.img \
	--machine falcon -s 14 --cpuclock 32 --cpulevel 3 --vdi true --vdi-planes 4 \
	--vdi-width 640 --vdi-height 480 -d . $(APP)

ftest: $(TEST_APP)
	$(HATARI) --grab -w --tos /usr/share/hatari/TOS404.IMG \
	--machine falcon --cpuclock 32 --cpulevel 3 \
	-d . $(APP)
	
sttest: $(TEST_APP)
	$(HATARI) --grab -w --tos "/usr/share/hatari/tos106de.img" \
	--machine st --cpuclock 32 --cpulevel 3  --vdi true --vdi-planes 4 \
	--vdi-width 640 --vdi-height 480 \
	-d . $(APP)

CC=gcc
AS=as

ifndef BETA
BETA=1
endif

CFLAGS = -O2 -pipe -Wall -Wmissing-prototypes -Winline -fomit-frame-pointer -m68040 -mshort -DBETA=$(BETA)
ASFLAGS = -m68030

ifneq ($(BETA),0)
  OBJDIR=objs_beta
else
  OBJDIR=objs_rel
endif
CFILES=main.c pci_lib.c printf.c delay.c scsidrv.c globals.c
SFILES=cookie.s
ifeq ($(BETA),0)
SFILES += serial.s
endif

OBJS = $(SFILES:%.s=$(OBJDIR)/%.o) $(CFILES:%.c=$(OBJDIR)/%.o) 

all: $(OBJDIR) $(OBJDIR)/scsi8xx.prg

test:
	@echo $(OBJS)

clean:
	rm $(OBJDIR)/*

$(OBJDIR):
	-mkdir $@

$(OBJDIR)/scsi8xx.prg:	$(OBJS)
	@echo "# Linking $@ ..."
	@$(CC) -s -L mylib -nostdlib mylib/crt0.o $(CFLAGS) -o $@ $^ -lmylib
	@toglclr --quiet --fram- --frun- $@
ifneq ($(BETA),0)
	tools/makerompkg -t AUTOPRG -i 1 -n "scsi8xx.prg" \
	-d "Sym53C8xx SCSI driver BETA" $(OBJDIR)/scsi8xx.prg >$(OBJDIR)/scsi8xx.pkg
endif

$(OBJDIR)/%.o: %.c
	@echo "# Compiling $*.c ..."
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: %.s
	@echo "# assembling $*.c ..."
	$(AS) $(ASFLAGS) $< -o $@

script.h: script.scr
	@echo assembling $<
	@cpp -traditional -DCHIP=810 - <$< | grep -v '^#' | script_asm

backup:
	tar cvfz /c/backup.tgz .

dist:
	@strip $(OBJDIR)/scsi8xx.prg
	@cp -v $(OBJDIR)/scsi8xx.prg /c/auto/scsi8xx.pr?
	@cp -v $(OBJDIR)/scsi8xx.pkg /c/pc/flash
	@cp -v $(OBJDIR)/scsi8xx.pkg /c/flash
	rm -rf tmp/*
	-mkdir tmp
	@cp objs_beta/scsi8xx.pkg README.TXT tmp
	cd tmp; rm scsibeta.lzh; /c/util/lharc scsibeta *
	
# Dependencies
$(OBJDIR)/main.o: ncrreg.h script.h pci_lib.h globals.h
$(OBJDIR)/scsidrv.o: scsidefs.h globals.h
$(OBJDIR)/globals.o: globals.h


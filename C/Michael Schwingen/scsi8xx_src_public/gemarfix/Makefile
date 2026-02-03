CC=gcc
AS=as

CFLAGS = -O2 -pipe -Wall -Wmissing-prototypes -Winline -fomit-frame-pointer -m68000 -mshort
ASFLAGS = -m68000

OBJDIR=.

CFILES=printf.c scsidrv.c
SFILES=cookie.s

OBJS = $(SFILES:%.s=$(OBJDIR)/%.o) $(CFILES:%.c=$(OBJDIR)/%.o) 

all: $(OBJDIR) $(OBJDIR)/gemarfix.prg

test:
	@echo $(OBJS)

$(OBJDIR):
	-mkdir $@

$(OBJDIR)/gemarfix.prg:	$(OBJS)
	@echo "# Linking $@ ..."
	@$(CC) -s -L ../mylib -nostdlib ../mylib/crt0.o $(CFLAGS) -o $@ $^ -lmylib

$(OBJDIR)/%.o: %.c
	@echo "# Compiling $*.c ..."
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: %.s
	@echo "# assembling $*.c ..."
	$(AS) $(ASFLAGS) $< -o $@

dist:
	strip $(OBJDIR)/gemarfix.prg
	cp -v $(OBJDIR)/gemarfix.prg /c/apps/gemar306
	

# Dependencies

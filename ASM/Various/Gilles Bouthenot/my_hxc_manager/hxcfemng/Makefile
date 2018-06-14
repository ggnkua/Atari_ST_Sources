
##########################
# You must fill ARCH
# and C, CFLAGS, LFLAGS
# before compiling !
#########################

# Part 1 : Arch
# Arch is the system used to build the project.
# Supplied arch : linux-i386, linux-amd64, cygwin
ARCH             = cygwin




GCCBIN           = m68k-atari-mint-gcc
GCCOPT           = -Os -Ifat32 -I.
GCLOPT           = -Os -nostdlib -Wl,-Map,symbols.map -Wl,--traditional-format -fomit-frame-pointer -m68000

VASMBIN          = ../build-tools/vbcc/bin-$(ARCH)/vasmm68k_mot
VASMOPT          = -Faout -showopt -m68000 -spaces -quiet

# GCC : PRG size about 44054 bytes
C                = $(GCCBIN)
CFLAGS           = $(GCCOPT) -mshort

#LFLAGS           = $(GCLOPT) -s    # STRIP SYMBOLS
LFLAGS           = $(GCLOPT)  	    # KEEP SYMBOLS (debug)

EXEC             = HXCFEMNG.PRG


.PHONY: all clean push-mina push-gbo-dsi push-gbo-pc

all: $(EXEC)

clean:
	rm -rf $(EXEC) *.o *.d fat32/*.o fat32/*.d libc/*.o libc/*.d libc/snprintf/*.o libc/snprintf/*.d symbols.map

push-mina: $(EXEC)
	rsync --perms $< Gilles@mina.openvpn:/cygdrive/c/data/dropbox/emul/atari/hd/c/tmp/

push-gbo-dsi: $(EXEC)
	rsync --perms $< gbouthen@gbo-dsi.openvpn:/cygdrive/c/data/dropbox/emul/atari/hd/c/tmp/

push-gbo-pc: $(EXEC)
	rsync --perms $< gbouthenot@gbo-pc.openvpn:/cygdrive/c/data/dropbox/emul/atari/hd/c/tmp/


OBJSWALL = atari_hw.o dir.o fectrl.o filelist.o gui_filelist.o hxcfeda.o instajump.o viewer.o screen.o screen_layout.o libc/snprintf/snprintf.o gui_utils.o
OBJSW0   = fat32/fat_access.o fat32/fat_filelib.o fat32/fat_misc.o fat32/fat_string.o fat32/fat_table.o fat32/fat_write.o fat32/fat_cache.o
OBJSW1   =
OBJSW2   = libc/mStartup.o
OBJSC    = $(OBJSWALL) $(OBJSW0) $(OBJSW1) $(OBJSW2)

OBJSASM  = libc/mStartupAsmC.o quickersort.o gui_asm.o

OBJS     = $(OBJSASM) $(OBJSC)


# link
$(EXEC):          $(OBJS)
	$(C)          $(LFLAGS)           $^ -o $@
	m68k-atari-mint-strip $@
	ls -l $@
	md5sum $@



# pull in dependency info for *existing* .o files
-include $(OBJS:.o=.d)


#
# c files: compile and generate dependency info
# -MMD is used to generated a .d file containing dependencies
#
# credits t:
# http://scottmcpeak.com/autodepend/autodepend.html
# http://make.paulandlesley.org/autodep.html
%.o: %.c
	@if  [ -n "$(filter $@,$(OBJSWALL))" ]; then \
		echo $(C) -MMD -c $(CFLAGS) $*.c -o $*.o -Wall; \
		     $(C) -MMD -c $(CFLAGS) $*.c -o $*.o -Wall; \
	elif [ -n "$(filter $@,$(OBJSW0))" ]; then \
		echo $(C) -MMD -c $(CFLAGS) $*.c -o $*.o; \
		     $(C) -MMD -c $(CFLAGS) $*.c -o $*.o; \
	elif [ -n "$(filter $@,$(OBJSW1))" ]; then \
		echo $(C) -MMD -c $(CFLAGS) $*.c -o $*.o -Wall -Wno-missing-braces; \
		     $(C) -MMD -c $(CFLAGS) $*.c -o $*.o -Wall -Wno-missing-braces; \
	elif [ -n "$(filter $@,$(OBJSW2))" ]; then \
		echo $(C) -MMD -c $(CFLAGS) $*.c -o $*.o -Wall -Wno-unused-value; \
		     $(C) -MMD -c $(CFLAGS) $*.c -o $*.o -Wall -Wno-unused-value; \
	fi

#
# Assembly files
#
%.o: %.s
	@if [ -n "$(filter $@,$(OBJSASM))" ]; then \
		echo $(VASMBIN)    $(VASMOPT)          $< -o $@; \
		     $(VASMBIN)    $(VASMOPT)          $< -o $@; \
	fi




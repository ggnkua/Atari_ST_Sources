APP=rune

CIBLEDIR=d:\rune
TOSINC=$(INCDIR)zlib.i $(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i
LINK_OBJC=main.o wintype.o messages.o dav.o browser.o routs.o
ROUT=$(CIBLEDIR)\routines.obj
WTDIR=$(CIBLEDIR)\win
DISKDIR=$(CIBLEDIR)\disk
##############################################################
#Les dependances
new.prg: $(APP).s $(LINK_OBJC)
	$(MAK) -C $(ZLIBDIR)
	$(CP) $(ZLIBDIR)system.o $(CIBLEDIR)\system.o
	$(CLINK) TTLOAD TTMALLOC VER err.log FROM $(LINK_OBJC) system.o TO $@
#	$(CLINK) TTLOAD TTMALLOC ADDSYM VER err.log WITH link.m TO $@
	$(CP) NEW.PRG ..\RUNE.DMO\RUNE.PRG
	$(CP) RUNE.RSC ..\RUNE.DMO\RUNE.RSC

#	clink $(LINK_OBJC) $(ZLIBDIR)system.o TO $@ ADDSYM VERBOSE TTLOAD TTMALLOC

$(APP).s: $(APP).h
	$(H2S) $(CIBLEDIR)\$(APP).h

routs.o: routs.s $(TOSINC) memory.s macro.i $(INCDIR)util.i $(INCDIR)structs.s

dav.o: dav.s

browser.o: browser.s $(TOSINC)

main.o: main.s $(TOSINC) $(APP).s $(INCDIR)util.i $(INCDIR)tosinit.i

messages.o: messages.s

wintype.o: $(WTDIR)\formul.s $(WTDIR)\fbrows.s rune.s $(TOSINC) $(INCDIR)structs.s
	$(MAK) -C $(WTDIR)

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -fv *.o *.bak
	$(ECHO)    ...done !
	$(MAK) -C $(WTDIR) clean
	$(MAK) -C $(ZLIBDIR) clean
	$(MAK) -C $(INCDIR) clean

all:
	$(MAK) -C $(CIBLEDIR) clean
	$(MAK) -C $(CIBLEDIR)



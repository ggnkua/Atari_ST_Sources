#.DEBUG:
CIBLE_DIR=D:\CODE\ZVUE
LINK_OBJC=main.o loadpic.o imgwin.o formul.o inslut.o
TOSINC=$(INCDIR)zlib.i $(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i
ROUT=$(CIBLE_DIR)\ROUTINES.OBJ
WTDIR=$(CIBLE_DIR)\WINTYPE
##############################################################
#Les regles de compilations
.SUFFIXES:
.SUFFIXES: .o .s .h
.s.prg:
	$(ASM) $(PFLAG) $(CIBLE_DIR)\$< -o=$(CIBLE_DIR)\$@
.s.o:
	$(ASM) $(OFLAG) -y -G -i$(INCDIR) $(CIBLE_DIR)\$< -o=$(CIBLE_DIR)\$@
##############################################################
#Les dependances
new.prg: rsc.s $(LINK_OBJC)
	$(MAK) -C $(ZLIBDIR)
	$(LINK) $(LINK_OBJC) $(ZLIBDIR)system.o -L -G -O=$@

run:
	d:\code\zvue\new.prg 

rsc.s: rsc.h
	$(H2S) $(CIBLE_DIR)\rsc.h

main.o: main.s $(TOSINC) rsc.s

imgwin.o: imgwin.s

loadpic.o: loadpic.s

formul.o: formul.s

inslut.o: inslut.s

#clean:
#	@echo cleaning directory...
#	rm -rfv *.o
#	cd $(ZLIBDIR)
#	rm -rvf *.o
#	cd $(CIBLE_DIR)


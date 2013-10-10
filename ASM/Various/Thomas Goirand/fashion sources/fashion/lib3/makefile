CIBLEDIR=$(ZLIBDIR)

LINK_OBJC=gemdos.o aesvdi.o fonction.o zlib.o
TOS_INC=$(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i $(INCDIR)zlib.i

################################################################################

system.o: $(LINK_OBJC)
	$(CLINK) PRELINK ADDSYM FROM $(LINK_OBJC) TO system.o

################################################################################

gemdos.o: $(ZLIBDIR)gemdos\gemdinit.s $(ZLIBDIR)gemdos\gemdoser.s $(TOS_INC) $(ZLIBDIR)gemdos\makefile
	$(MAK) -C $(ZLIBDIR)gemdos

aesvdi.o: $(ZLIBDIR)aesvdi\av_init.s $(ZLIBDIR)aesvdi\aes.s $(ZLIBDIR)aesvdi\vdi.s $(TOS_INC) $(ZLIBDIR)aesvdi\makefile
	$(MAK) -C $(ZLIBDIR)aesvdi

fonction.o: $(ZLIBDIR)fonction\macros.s $(ZLIBDIR)fonction\util.s $(TOS_INC) $(ZLIBDIR)fonction\makefile
	$(MAK) -C $(ZLIBDIR)fonction

zlib.o: $(ZLIBDIR)zlib\evnt.s $(ZLIBDIR)zlib\redraw.s $(ZLIBDIR)zlib\window.s $(ZLIBDIR)zlib\mem_mang.s $(ZLIBDIR)zlib\mem_tst.s $(TOSINC) $(ZLIBDIR)zlib\makefile
	$(MAK) -C $(ZLIBDIR)zlib

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -vf *.o *.bak
	$(ECHO)    ...done !
	$(MAK) -C $(ZLIBDIR)gemdos clean
	$(MAK) -C $(ZLIBDIR)aesvdi clean
	$(MAK) -C $(ZLIBDIR)fonction clean
	$(MAK) -C $(ZLIBDIR)zlib clean



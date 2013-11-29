CIBLEDIR=$(ZLIBDIR)zlib

LINK_OBJC=evnt.o redraw.o window.o mem_mang.o mem_tst.o
TOSINC=$(INCDIR)gemdos.i $(INCDIR)zlib.i $(INCDIR)xbios.i

##############################################################

zlib.o: $(LINK_OBJC)
	$(CLINK) PRELINK ADDSYM FROM $(LINK_OBJC) TO zlib.o
	$(COPY) zlib.o ..

##############################################################
#Les dependances

evnt.o: evnt.s $(TOSINC)

window.o: window.s $(TOSINC)

redraw.o: redraw.s $(TOSINC)

mem_mang.o: mem_mang.s $(INCDIR)zlib.i $(INCDIR)gemdos.i

mem_tst.o: mem_tst.s $(INCDIR)zlib.i $(INCDIR)gemdos.i

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -vf *.o *.bak
	$(ECHO)    ...done !



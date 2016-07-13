CIBLEDIR=$(ZLIBDIR)gemdos

LINK_OBJC=gemdinit.o gemdoser.o
TOSINC=$(INCDIR)gemdos.i $(INCDIR)zlib.i $(INCDIR)xbios.i $(INCDIR)aes.i

##############################################################

gemdos.o: $(LINK_OBJC) $(TOSINC)
	$(CLINK) PRELINK ADDSYM FROM $(LINK_OBJC) TO gemdos.o
	$(COPY) gemdos.o ..

##############################################################

gemdinit.o: gemdinit.s $(TOSINC)

gemdoser.o: gemdoser.s $(TOSINC)

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -vf *.o *.bak
	$(ECHO)    ...done !



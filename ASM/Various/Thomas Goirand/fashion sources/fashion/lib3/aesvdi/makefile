CIBLEDIR=$(ZLIBDIR)aesvdi

LINK_OBJC=aes.o vdi.o av_init.o
TOS_INC=$(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i $(INCDIR)zlib.i

##############################################################

aesvdi.o: $(LINK_OBJC) $(TOS_INC)
	$(CLINK) PRELINK ADDSYM FROM $(LINK_OBJC) TO aesvdi.o
	$(COPY) aesvdi.o ..

##############################################################

aes.o: aes.s $(TOS_INC)

vdi.o: vdi.s $(TOS_INC)

av_init.o: av_init.s $(TOS_INC)

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -vf *.o *.bak
	$(ECHO)    ...done !



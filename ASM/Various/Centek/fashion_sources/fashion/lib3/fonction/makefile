CIBLEDIR=$(ZLIBDIR)fonction

LINK_OBJC=macros.o util.o
TOS_INC=$(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i $(INCDIR)zlib.i

##############################################################

fonction.o: $(LINK_OBJC) $(TOS_INC)
	$(CLINK) PRELINK ADDSYM FROM $(LINK_OBJC) TO fonction.o
	$(COPY) fonction.o ..

##############################################################

util.o: util.s $(TOS_INC)

macros.o: macros.s $(TOS_INC)

mulu.o: mulu.s

rsload2.o: rsload2.s

my_pexec.o: my_pexec.s

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -vf *.o *.bak
	$(ECHO)    ...done !



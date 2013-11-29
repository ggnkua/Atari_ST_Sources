CIBLEDIR=D:\rune\win

LINK_OBJC=formul.o fbrows.o
TOSINC=$(INCDIR)zlib.i $(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i

#################################################

wintype.o: $(LINK_OBJC) $(TOSINC)
	$(CLINK) PRELINK ADDSYM FROM $(LINK_OBJC) TO wintype.o
	$(COPY) wintype.o ..

#################################################

formul.o: formul.s $(TOSINC) ..\rune.s

fbrows.o: fbrows.s $(TOSINC) ..\rune.s

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -fv *.o *.bak
	$(ECHO)    ...done !



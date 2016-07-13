CIBLEDIR=D:\fashion\fashion\wintype

LINK_OBJC=formul.o toolbox2.o drag.o winobjet.o colorwin.o flagwin.o tedinfo.o edmenu.o gline.o alrt_ed.o
TOSINC=$(INCDIR)zlib.i $(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i

#################################################

wintype.o: $(LINK_OBJC) $(TOSINC)
	$(CLINK) PRELINK ADDSYM WITH link.m TO wintype.o
	$(COPY) wintype.o ..

#################################################

formul.o: formul.s $(TOSINC) ..\fashion.s

toolbox2.o: toolbox2.s $(INCDIR)gemdos.i $(INCDIR)zlib.i $(INCDIR)structs.s ..\macro.i

drag.o: drag.s $(TOSINC) $(INCDIR)structs.s $(INCDIR)util.i ..\fashion.s ..\macro.i

winobjet.o: winobjet.s $(TOSINC) ..\memory.s ..\fashion.s

colorwin.o: colorwin.s ..\fashion.s $(INCDIR)structs.s $(INCDIR)zlib.i $(INCDIR)aes.i

colorwin.o: gline.s ..\fashion.s $(INCDIR)structs.s $(INCDIR)zlib.i $(INCDIR)aes.i

flagwin.o: flagwin.s ..\fashion.s $(INCDIR)structs.s $(INCDIR)zlib.i $(INCDIR)aes.i

tedinfo.o: tedinfo.s $(TOSINC) $(INCDIR)structs.s ..\fashion.s

edmenu.o: edmenu.s $(TOSINC) $(INCDIR)structs.s ..\fashion.s ..\macro.i

alrt_ed.o: alrt_ed.s $(TOSINC) $(INCDIR)zlib.i

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -fv *.o *.bak
	$(ECHO)    ...done !



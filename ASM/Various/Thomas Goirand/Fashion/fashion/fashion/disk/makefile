CIBLEDIR=d:\fashion\fashion\disk

LINK_OBJC=newload.o newsave.o oldsave.o oldload.o hrd_load.o hrd_save.o src_save.o
TOSINC=$(INCDIR)zlib.i $(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i

##############################################################

disk.o: $(LINK_OBJC) $(TOSINC)
	$(CLINK) PRELINK ADDSYM FROM $(LINK_OBJC) TO disk.o
	$(COPY) disk.o ..

newload.o: newload.s $(INCDIR)structs.s $(TOSINC) ..\memory.s ..\fashion.s

newsave.o: newsave.s $(INCDIR)structs.s $(TOSINC) ..\memory.s

oldsave.o: oldsave.s $(INCDIR)structs.s $(TOSINC) ..\memory.s

oldload.o: oldload.s $(INCDIR)structs.s $(TOSINC) ..\memory.s ..\fashion.s

hrd_load.o: hrd_load.s $(INCDIR)structs.s $(TOSINC) ..\memory.s hrd.i

hrd_save.o: hrd_save.s $(INCDIR)structs.s $(TOSINC) ..\memory.s hrd.i

src_save.o: src_save.s $(INCDIR)structs.s $(TOSINC) ..\memory.s

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -fv *.o *.bak
	$(ECHO)    ...done !



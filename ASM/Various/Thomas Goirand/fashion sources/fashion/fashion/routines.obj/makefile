CIBLEDIR=d:\fashion\fashion\routines.obj

LINK_OBJC=ob_real.o efface.o copy_obj.o attrb.o update.o del_tree.o ob_spec.o chg_type.o

##############################################################

routines.o: $(LINK_OBJC) $(TOSINC)
	$(CLINK) PRELINK ADDSYM FROM $(LINK_OBJC) TO routines.o
	$(COPY) routines.o ..

##############################################################

ob_real.o: ob_real.s $(INCDIR)structs.s $(INCDIR)zlib.i

efface.o: efface.s $(INCDIR)aes.i $(INCDIR)structs.s $(INCDIR)zlib.i ..\macro.i

copy_obj.o: copy_obj.s $(TOSINC) $(INCDIR)structs.s ..\macro.i

attrb.o: attrb.s $(INCDIR)structs.s $(INCDIR)zlib.i $(INCDIR)aes.i ..\fashion.s

update.o: update.s $(INCDIR)structs.s $(INCDIR)zlib.i $(INCDIR)aes.i ..\fashion.s

del_tree.o: del_tree.s $(INCDIR)zlib.i $(INCDIR)structs.s

ob_spec.o: $(INCDIR)zlib.i $(INCDIR)aes.i $(INCDIR)structs.s $(INCDIR)util.i ..\fashion.s

chg_type.o: chg_type.s chgtyp\gbox.s chgtyp\gtext.s chgtyp\gboxtext.s chgtyp\gimage.s chgtyp\gprogdef.s \
		chgtyp\gibox.s chgtyp\gbutton.s chgtyp\gftext.s chgtyp\gfbxtext.s chgtyp\gicon.s chgtyp\gcicon.s \
		chgtyp\gpix.s chgtyp\gline.s \
		..\macro.i ..\fashion.s $(INCDIR)structs.s $(INCDIR)aes.i $(INCDIR)zlib.i

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -fv *.o *.bak
	$(ECHO)    ...done !



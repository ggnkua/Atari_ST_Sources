CIBLEDIR=d:\fashion\fashion
TOSINC=$(INCDIR)zlib.i $(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i
LINK_OBJC=main.o routines.o wintype.o disk.o rsrcload.o menu.o userdef.o messages.o dav.o
ROUT=$(CIBLEDIR)\routines.obj
WTDIR=$(CIBLEDIR)\wintype
DISKDIR=$(CIBLEDIR)\disk
##############################################################
#Les dependances
new.prg: fashion.s $(LINK_OBJC)
	$(MAK) -C $(ZLIBDIR)
	$(CP) $(ZLIBDIR)system.o $(CIBLEDIR)\system.o
#	$(CLINK) TTLOAD TTMALLOC FROM $(LINK_OBJC) system.o TO $@
	$(CLINK) TTLOAD TTMALLOC ADDSYM VER err.log WITH link.m TO $@
	$(CP) NEW.PRG ..\FASHION.DMO\FASHION.PRG
	$(CP) FASHION.RSC ..\FASHION.DMO\FASHION.RSC

#	clink $(LINK_OBJC) $(ZLIBDIR)system.o TO $@ ADDSYM VERBOSE TTLOAD TTMALLOC

fashion.s: fashion.h
	$(H2S) $(CIBLEDIR)\fashion.h

main.o: main.s $(TOSINC) fashion.s $(INCDIR)util.i $(INCDIR)tosinit.i memory.s

#lib_rsrc.o: lib_rsrc.s lib_trnf.s dav.s $(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i $(INCDIR)zlib.i
rscrload.o: rsrcload.s lib_trnf.s $(INCDIR)gemdos.i $(INCDIR)aes.i $(INCDIR)vdi.i $(INCDIR)zlib.i

dav.o: dav.s

menu.o: menu.s $(TOSINC) $(INCDIR)structs.s $(INCDIR)util.i memory.s fashion.s macro.i

messages.o: messages.s

userdef.o: userdef.s $(INCDIR)vdi.i

routines.o: $(ROUT)\EFFACE.S $(ROUT)\OB_REAL.S $(ROUT)\copy_obj.s $(ROUT)\attrb.s $(ROUT)\update.s $(ROUT)\del_tree.s \
		$(ROUT)\chg_type.s $(ROUT)\chgtyp\gbox.s $(ROUT)\chgtyp\gtext.s $(ROUT)\chgtyp\gboxtext.s \
		$(ROUT)\chgtyp\gimage.s $(ROUT)\chgtyp\gprogdef.s $(ROUT)\chgtyp\gibox.s $(ROUT)\chgtyp\gbutton.s \
		$(ROUT)\chgtyp\gftext.s $(ROUT)\chgtyp\gfbxtext.s $(ROUT)\chgtyp\gicon.s $(ROUT)\chgtyp\gcicon.s \
		$(ROUT)\chgtyp\gpix.s $(ROUT)\chgtyp\gline.s \
		$(ROUT)\ob_spec.s $(TOSINC) $(INCDIR)structs.s $(INCDIR)util.i macro.i fashion.s
	$(MAK) -C $(ROUT)

wintype.o: $(WTDIR)\formul.s $(WTDIR)\toolbox2.s $(WTDIR)\drag.s $(WTDIR)\winobjet.s $(WTDIR)\colorwin.s $(WTDIR)\flagwin.s $(WTDIR)\gline.s $(WTDIR)\tedinfo.s $(WTDIR)\edmenu.s fashion.s macro.i $(TOSINC) $(INCDIR)structs.s $(WTDIR)\alrt_ed.s
	$(MAK) -C $(WTDIR)

disk.o: $(DISKDIR)\makefile $(DISKDIR)\newload.s $(DISKDIR)\newsave.s $(DISKDIR)\oldsave.s $(DISKDIR)\hrd_load.s $(DISKDIR)\hrd_save.s $(DISKDIR)\hrd.i $(DISKDIR)\oldload.s $(TOSINC) memory.s $(INCDIR)structs.s fashion.s $(DISKDIR)\src_save.s
	$(MAK) -C $(DISKDIR)

clean:
	$(ECHO)    Cleaning directory $(CIBLEDIR)...
	$(RM) -fv *.o *.bak
	$(ECHO)    ...done !
	$(MAK) -C $(ROUT) clean
	$(MAK) -C $(WTDIR) clean
	$(MAK) -C $(DISKDIR) clean
	$(MAK) -C $(ZLIBDIR) clean
	$(MAK) -C $(INCDIR) clean

all:
	$(MAK) -C $(CIBLEDIR) clean
	$(MAK) -C $(CIBLEDIR)



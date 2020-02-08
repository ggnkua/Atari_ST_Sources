
' [DIALOG.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION Cstring_alertaddr(BYVAL button,BYVAL addr&)
	POKEW PEEKL(GB+8),button : POKEL PEEKL(GB+16),addr&
	GEMSYS(52) : Cstring_alertaddr=PEEKW(PEEKL(GB+12))
END FUNCTION


FUNCTION Cstring_alert(BYVAL object,BYVAL button)
STATIC alertaddr&

junk=rsrc_gaddr(type_string,object,alertaddr&)
Cstring_alert=Cstring_alertAddr(button,alertaddr&)
END FUNCTION


FUNCTION alert(BYVAL button,BYVAL dummy$)
alert=Cstring_alertaddr(button,VARPTR(dummy$))
END FUNCTION


FUNCTION getobj_tednumber# (BYVAL object)
	getobj_tednumber#=VAL(getobj_text$(object))
END FUNCTION


FUNCTION get_groupbutton(BYVAL parent)
STATIC dummy

dummy=getobj_head(parent)
DO
	dummy=getobj_next(dummy)
LOOP UNTIL (dummy=parent) OR enquire_state(dummy,mask_selected)
get_groupbutton=dummy
END FUNCTION


SUB setobj_tednumber (BYVAL object,BYVAL value#)
	setobj_text object,MID$(STR$(value#),2)
END SUB


SUB set_groupbutton (BYVAL parent,BYVAL button)
STATIC dummy

dummy=getobj_head(parent)
DO
	IF dummy=button THEN
		include_state dummy,mask_selected
	ELSE
		remove_state dummy,mask_selected
	END IF
	dummy=getobj_next(dummy)
LOOP UNTIL dummy=parent
END SUB


FUNCTION dialog(BYVAL treeno,BYVAL edit_obj)
STATIC x,y,w,h,but,old_tree&

old_tree&=tree& : SelectTree treeno
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
but=form_do(tree&,edit_obj) AND &h7fff
form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
IF getobj_type(but)=G_BUTTON THEN remove_state but,mask_selected
dialog=but : tree&=old_tree&
END FUNCTION

'[*END OF FILE*]

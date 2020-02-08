
' [NEWDESK.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

SUB SetDeskAddr (BYVAL dummy&)
STATIC x,y,w,h

desktree&=dummy&
junk=wind_get(0,WF_WORKXYWH,x,y,w,h)
junk=wind_set(0,WF_NEWDESK,PEEKW(VARPTR(dummy&)),PEEKW(VARPTR(dummy&)+2),0,0)
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
END SUB


SUB SetDesk (BYVAL treeno,BYVAL object)
STATIC dummy&,x,y,w,h,x1,y1,w1,h1

IF treeno=-1 THEN
	SetDeskAddr 0
ELSE
	junk=rsrc_gaddr(type_tree,treeno,dummy&)
	SelectTreeAddr dummy&
	junk=wind_get(0,WF_WORKXYWH,x,y,w,h)
	setobj_x 0,x : setobj_y 0,y : setobj_width 0,w
	setobj_height 0,h
	IF object<>0 THEN
		w1=getobj_width(object) : h1=getobj_height(object)
		setobj_x object,((w-w1)/2) : setobj_y object,((h-h1)/2)
	END IF
	SetDeskAddr dummy&
END IF
END SUB

'[*END OF FILE*]
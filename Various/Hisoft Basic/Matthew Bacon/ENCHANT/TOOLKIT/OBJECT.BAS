
' [OBJECT.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones


SUB ObjectExtent(BYVAL object,x,y,w,h)
STATIC object_spec&,type,border,offset
STATIC mask3d,w1,h1

junk=objc_offset(tree&,object,x,y)
w=getobj_width(object) : h=getobj_height(object)
object_spec&=getobj_spec&(object)

IF getobj_flags(object) AND mask_indirect THEN object_spec&=PEEKL(object_spec&)
type=getobj_type(object) AND &hFF
SELECT CASE type
CASE G_TEXT,G_BOXTEXT,G_FBOXTEXT,G_FTEXT
	border=PEEKW(object_spec&+te_thickness)
CASE G_BOXCHAR
	border=(object_spec&>>16) AND &hFF
	IF border>127 THEN border=border-256
CASE G_BUTTON
	border=-1
	IF getobj_flags(object) AND mask_default THEN DECR border
	IF getobj_flags(object) AND mask_exit THEN DECR border
CASE ELSE
	border=0
END SELECT

IF border>=0 THEN offset=0 ELSE offset=border : border=-border
IF getobj_state(object) AND mask_outlined THEN IF offset>-3 THEN offset=-3

x=x+offset : y=y+offset : w=w-offset*2 : h=h-offset*2

IF aes_version>=&h340 THEN
	mask3d=getobj_flags(object) AND mask_3d
	IF mask3d=fl3dind OR mask3d=fl3dact THEN
		junk=objc_sysvar( 0,AD3DVALUE,0,0,w1,h1)
		x=x-w1 : y=y-h1 : w=w+w1*2 : h=h+h1*2
	END IF
END IF				
IF getobj_state(object) AND mask_shadowed THEN w=w+border*2 : h=h+border*2
END SUB

'[*END OF FILE*]

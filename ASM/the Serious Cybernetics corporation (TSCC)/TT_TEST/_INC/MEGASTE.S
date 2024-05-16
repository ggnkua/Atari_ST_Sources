
;//// MegaSTE trick by GGN/KUA
	move.l $8,-(sp)
	move.l #ggntrap,$8
	clr.b $ffff8e21
ggntrap:
	move.l (sp)+,$8

source:	macro
	move.l	\1,$ffff8a24.w
	endm

largeur:	macro
	move.w	\1,$ffff8a36.w
	endm
	
hauteur:	macro
	move.w	\1,$ffff8a38.w
	endm
	
inchs:	macro
	move.w	\1,$ffff8a20.w
	endm
	
incvs:	macro
	move.w	\1,$ffff8a22.w
	endm
	
masque1:	macro
	ifnc	"\1","#0"
	move.w	\1,$ffff8a28.w
	else
	clr.w	$ffff8a28.w
	endc
	endm

masque2:	macro
	ifnc	"\1","#0"
	move.w	\1,$ffff8a2a.w
	else
	clr.w	$ffff8a2a.w
	endc
	endm
	
masque3:	macro
	ifnc	"\1","#0"
	move.w	\1,$ffff8a2c.w
	else
	clr.w	$ffff8a2c.w
	endc
	endm

destination:macro
	move.l	\1,$ffff8a32.w
	endm
	
inchd:	macro
	move.w	\1,$ffff8a2e.w
	endm
	
incvd:	macro
	move.w	\1,$ffff8a30.w
	endm
	
oplog:	macro	
	ifnc	"\1","#0"
	move.b	\1,$ffff8a3b.w
	else
	clr.b	$ffff8a3b.w
	endc
	endm
	
hop:	macro
	ifnc	"\1","#0"
	move.b	\1,$ffff8a3a.w
	else
	clr.b	$ffff8a3a.w
	endc
	endm
	
mode:	macro	x
	ifnc	"\1","#0"
	move.b	\1,$ffff8a3d.w
	else
	clr.b	$ffff8a3d.w
	endc
	endm

controle:	macro
	ifnc	"\1","#0"
	move.b	\1,$ffff8a3c.w
	else
	clr.b	$ffff8a3c.w
	endc
	endm
	
demiteinte:	macro
ad	set	$ffff8a00
	rept	8
	move.l	(\1)+,ad.w
ad	set	ad+$4
	endr
	endm
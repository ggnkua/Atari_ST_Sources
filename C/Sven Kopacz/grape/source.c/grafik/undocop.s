;Breite und H”he JEWEILS -1 !(word)
.EXPORT uc_height, uc_width

;Zeilenoffset der Source (long)
.EXPORT uc_ldif

;Zeiger auf Undo-End (long)
;Muž nachher ausgelesen werden
.EXPORT uc_uend

;Zeiger auf Sourceplanes (Erster zu kopierender Pixel) (long)
.EXPORT uc_c, uc_m, uc_y

;Kopieren 3 Planes oder 1 Plane
.EXPORT undo_copy_cmy, undo_copy_m

;Mit Undopuffer vertauschen 3 oder 1 Plane
.EXPORT undo_swap_cmy, undo_swap_m

undo_swap_cmy:
	movem.l	a0-a3/d0-d6,-(sp)

	move.l	uc_uend, a0
;Bl”de Reihenfolge, weil Undo-Puffer RGB-Organisiert
	move.l	uc_m, a1
	move.l	uc_y, a2
	move.l	uc_c, a3
	
	move.l	uc_ldif, d0
	
	move.w	uc_height,d1
	move.w	uc_width, d3
yloops:
	move.w	d3, d2
xloops:
	move.b	(a0),d4
	move.b	1(a0),d5
	move.b	2(a0),d6
	
	move.b	(a1),(a0)+
	move.b	(a2),(a0)+
	move.b	(a3),(a0)+

	move.b	d4,(a1)+
	move.b	d5,(a2)+
	move.b	d6,(a3)+
	
	dbra		d2,xloops

	add.l		d0,a1
	add.l		d0,a2
	add.l		d0,a3
	dbra		d1,yloops
	
	move.l	a0,uc_uend
	
	movem.l	(sp)+,a0-a3/d0-d6
	rts


undo_swap_m:
	movem.l	a0-a1/d0-d4,-(sp)

	move.l	uc_uend, a0
	move.l	uc_m, a1
	
	move.l	uc_ldif, d0
	
	move.w	uc_height,d1
	move.w	uc_width, d3
yloopsm:
	move.w	d3, d2
xloopsm:
	move.b	(a0),d4
	move.b	(a1),(a0)+
	move.b	d4,(a1)+
	dbra		d2,xloopsm

	add.l		d0,a1
	dbra		d1,yloopsm
	
	move.l	a0,uc_uend
	
	movem.l	(sp)+,a0-a1/d0-d4
	rts


undo_copy_cmy:
	movem.l	a0-a3/d0-d3,-(sp)

	move.l	uc_uend, a0
;Bl”de Reihenfolge, weil Undo-Puffer RGB-Organisiert
	move.l	uc_m, a1
	move.l	uc_y, a2
	move.l	uc_c, a3
	
	move.l	uc_ldif, d0
	
	move.w	uc_height,d1
	move.w	uc_width, d3
yloop:
	move.w	d3, d2
xloop:
	move.b	(a1)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	dbra		d2,xloop

	add.l		d0,a1
	add.l		d0,a2
	add.l		d0,a3
	dbra		d1,yloop
	
	move.l	a0,uc_uend
	
	movem.l	(sp)+,a0-a3/d0-d3
	rts


undo_copy_m:
	movem.l	a0-a1/d0-d3,-(sp)

	move.l	uc_uend, a0
	move.l	uc_m, a1
	
	move.l	uc_ldif, d0
	
	move.w	uc_height,d1
	move.w	uc_width, d3
yloopm:
	move.w	d3, d2
xloopm:
	move.b	(a1)+,(a0)+
	dbra		d2,xloopm

	add.l		d0,a1
	dbra		d1,yloopm
	
	move.l	a0,uc_uend
	
	movem.l	(sp)+,a0-a1/d0-d3
	rts
	

uc_height:
	.DS.W	1
uc_width:
	.DS.W	1
uc_ldif:
	.DS.L	1
uc_uend:
	.DS.L	1
uc_c:
	.DS.L 1
uc_m:
	.DS.L 1
uc_y:
	.DS.L 1
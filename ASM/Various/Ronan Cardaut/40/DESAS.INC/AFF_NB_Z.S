	movem.l	a0-a2/d0-d2,-(sp)
	lea	nombre(pc),a1
	lea	nom_mem(pc),a0
	lea	table(pc),a2
	move.l	d0,(a0)
	move.w	#3,d2
.loop	
	move.b	(a0),d1
	lsr.b	#4,d1
	and.l	#$f,d1
	move.b	(a2,d1),(a1)+
	move.b	(a0)+,d1
	and.l	#$f,d1
	move.b	(a2,d1),(a1)+
	dbra	d2,.loop
	clr.b	(a1)

;suppression des zero de d‚buts

	
	
.sort
	movem.l	(sp)+,d0-d2/a0-a2
	rts
	
affiche_nombre_2::
	movem.l	a0-a2/d0-d2,-(sp)
	lea	nombre(pc),a1
	lea	nom_mem(pc),a0
	lea	table(pc),a2
	move.l	d0,d1
	lsr.b	#4,d1
	and.l	#$f,d1
	move.b	(a2,d1),(a1)+
	and.l	#$f,d0
	move.b	(a2,d0),(a1)+
	clr.b	(a1)

;suppression des zero de d‚buts

	
	
.sort
	movem.l	(sp)+,d0-d2/a0-a2
	rts

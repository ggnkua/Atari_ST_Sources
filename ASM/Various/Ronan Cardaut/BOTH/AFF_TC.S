	bra	CONVERT_PAL
;------------------------------------------------------------------------------
;affiche une ligne de texte avec choix des coordonn‚es
;------------------------------------------------------------------------------
	cnop	0,16
AFF_XY_TC

	movem.l	d0-d7/a0/a1/a2/a3,-(sp)

; a0=ligne … afficher (terminee par 0)

	lea	LINE,a0
	moveq	#0,d0
	move	(a0)+,d0	;X
	move	(a0)+,d1	;Y
	lsl.l	#4,d0		;X*16
	mulu	LSCR,d1
	lsl.l	#4,d1
	move.l	LOG,a1
	add.l	d1,a1
	add.l	d0,a1

.CAR
	move.w	(a0)+,d0	;r‚cupere un char
	bmi	.FIN

	move.l	a1,a3
	add	#8*2,a1

	move	d0,d2
	and	#$ff,d0
	add	d0,d0
	lea	(FONT.l,d0.w*8),a2
	
	moveq	#0,d0		;fond=noir
	lsr	#8,d2
	move	d2,d1
	and	#$f,d1
	move	(PAL_TC.l,d1.w*2),d1
	btst	#6,d2
	beq.s	.NO_INV
	not	d0
	not	d1
.NO_INV	
	move	LSCR,d5
	sub	#8*2,d5

.LOOP_AFF
	moveq	#16-1,d7
.Y	move.b	(a2)+,d3
	moveq	#8-1,d6
.X	move	d0,d2	
	add.b	d3,d3
	bcc	.OK0
	move	d1,d2
.OK0	move	d2,(a3)+
	dbra	d6,.X
	add	d5,a3
	dbra	d7,.Y


	bra	.CAR

.FIN	
	movem.l	(sp)+,d0-d7/a0/a1/a2/a3
	rts

CONVERT_PAL::
	xref	PALETTE
	
	lea	PALETTE,a0
	lea	PAL_TC,a1
	move	#16-1,d7
.LOOP
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	addq	#1,a0
	move.b	(a0)+,d2

	and	#$f8,d0
	and	#$f8,d1
	and	#$f8,d2
	
	lsl	#11-3,d0
	lsl	#6-3,d1
	lsr	#3,d2

	or	d1,d0
	or	d2,d0
	
	move	d0,(a1)+

	dbra	d7,.LOOP

	rts
	
			
	BSS
			
PAL_TC	ds	16

	TEXT

	IFNE	0

LSCR	dc	800*2
		
FONT	incbin	BLUE16.FNT


LOG	dc.l	$d0000000


LINE	
	dc	10,10

	incbin	about.bin	
	
	dc.b	1,'A',2,'B',3,'C',$80,00
	
PAL	incbin	DEFAULT.PAL

	xref	PAL_TC
	xref	PAL_TC
	ENDC	
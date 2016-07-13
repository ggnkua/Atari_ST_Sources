; Routine de decompression de A(quarium)crunchy
; A0=source
; A1=destination
; bsr decompress	

decompress:
	movem.l	d0-a6,-(sp)
	move.l	(a0)+,d0
	cmp.l	#'AQC!',d0
	bne	noaqc
	move.l	a0,savedeb
	move.l	a0,debutd
	add.l	2(a0),a0
	move.l	a0,savefin
	move.l	a0,find
	move.l	a1,savedest
	move.l	a1,destd
	rept 3
	bsr.s	letdoit
	endr
noaqc	movem.l	(sp)+,d0-a6
	rts

	even
savedeb	dc.l 0
savefin	dc.l 0
savedest
	dc.l 0
debutd:	dc.l 0
find:	dc.l 0
destd:	dc.l 0
	
	
letdoit:
	clr.l	d0
	move.l	debutd,a4
	move.l	destd,a0
	move.l	4(a4),a5
	add.l	a4,a5
	move.l	a5,a3
	addq.l	#8,a4
	addq.l	#7,a5
aqua0
	cmp.b	#8,d0
	bne.s	aqua1
	clr.b	d0
	tst.b	(a4)+
	cmp.l	a4,a3
	beq.s	aqua2
aqua1:	btst	d0,(a4)
	beq.s	aqua3
	move.b	(a5)+,(a0)+
	addq.b	#1,d0
	bra.s	aqua0
aqua3
	clr.b	(a0)+
	addq.b	#1,d0
	bra.s	aqua0
aqua2:
	move.l	debutd,a4
	move.l	(a4),a3
	add.l	a4,a3
	subq.l	#1,a0
aqua4
	cmp.l	a5,a3
	bmi.s	aqua5
	move.b	(a5)+,(a0)+
	bra.s	aqua4
aqua5:
	move.l	a0,d0
	sub.l	destd,d0
	move.l	debutd,find
	add.l	d0,find
	move.l	destd,a0
	move.l	debutd,a1
aqua6	move.b	(a0)+,(a1)+
	dbf	d0,aqua6
	move.l	debutd,a0
	move.l	find,a1
	move.b	(a0)+,d0
	move.b	(a0),d1
	move.b	d1,d2
aqua7	add.b	d0,d1
	move.b	d1,(a0)+
	cmpa.l	a0,a1
	beq.s	finaqua7
	move.b	(a0),d1
	move.b	d2,d0
	add.b	d1,d2
	bra.s	aqua7
finaqua7:
	move.l	savedeb,debutd
	move.l	savedest,destd
	rts	
; fin rout de decompression
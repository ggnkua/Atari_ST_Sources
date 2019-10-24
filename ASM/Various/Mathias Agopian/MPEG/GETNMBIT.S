		.xdef	get_numBitsAlowed_I,get_ScaleFactors,get_samples
		.xdef	My_Dsp_BlkBytes,My_Dsp_BlkWords
		.xdef	numBitsAlowed_tbl

;	a0 contient l'adresse du tableau de destination
;	a1 contient l'adresse de la trame

get_numBitsAlowed_I:
		movem.l	d1/d2/d7/a0/a1/a2,-(sp)
		lea		numBitsAlowed_tbl,a2
		moveq	#4,d0
		clr.l	d1
		moveq	#64-1,d7
.next:	bfextu	(a1){d1:d0},d2
		add.l	d0,d1
		move.b	(a2,d2.w),(a0)+
		dbf		d7,.next
		move.l	d1,PosBit
		movem.l	(sp)+,d1/d2/d7/a0/a1/a2
		rts

;	a0 contient l'adresse du tableau de destination (facteurs d'‚chelles)
;	a1 contient l'adresse du tableau des nombre de bit allou‚
;	4(sp) contient l'adresse de la trame

get_ScaleFactors:
		move.l	4(sp),d0
		movem.l	d1/d2/d7/a0/a1/a2,-(sp)
		move.l	d0,a2
		moveq	#6,d0
		move.l	PosBit,d1
		moveq	#64-1,d7
.next:	tst.b	(a1)+
		beq.s	.zero
		bfextu	(a2){d1:d0},d2
		add.l	d0,d1
		move.b	d2,(a0)+
		dbf		d7,.next
		bra		.fin
.zero:	clr.b	(a0)+
		dbf		d7,.next
.fin:	move.l	d1,PosBit
		movem.l	(sp)+,d1/d2/d7/a0/a1/a2
		rts

; a0 = adresse destination
; a1 = table des nombre de bits allou‚s
; 4(sp) = adresse de la frame

get_samples:
		move.l	4(sp),d0
		movem.l	d1/d2/d6/d7/a0/a1/a2/a3,-(sp)
		move.l	PosBit,d1
		move.l	d0,a2
		clr.l	d0
		move.l	a1,a3
		moveq	#12-1,d7
.next:	move.l	a3,a1
		moveq	#64-1,d6
.sb:	clr.w	d2
		move.b	(a1)+,d0
		beq.s	.zero
		bfexts	(a2){d1:d0},d2
		add.l	d0,d1
.zero:	move.w	d2,(a0)+
		dbf		d6,.sb
		dbf		d7,.next
		move.l	d1,PosBit		
		movem.l	(sp)+,d1/d2/d6/d7/a0/a1/a2/a3
		rts


My_Dsp_BlkBytes:
		lea		$FFFFA200.W,a1
		subq.w	#1,d0
.wait:	btst	#1,2(a1)
		beq.s	.wait
		clr.w	5(a1)
.send:	move.b	(a0)+,7(a1)
		dbf	d0,.send
		rts
		
My_Dsp_BlkWords:
		lea		$FFFFA200.W,a1
		subq.w	#1,d0
.wait:	btst	#1,2(a1)
		beq.s	.wait
		clr.b	5(a1)
.send:	move.w	(a0)+,6(a1)
		dbf	d0,.send
		rts


		.data
PosBit:	dc.l	0

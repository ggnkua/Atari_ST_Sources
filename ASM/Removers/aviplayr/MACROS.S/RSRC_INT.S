rsrc_intgr:
	movem.l	d0-d3/a0-a1,-(sp)
	move.l	6*4+4(sp),a0		; Adr rsc en m‚moire
	move.l	a0,d0			; rsrc_delta
	btst.b	#7,34(a0)
	beq.s	.not_yet_relocated
	sub.l	12(a0),d0
.not_yet_relocated:
	tst.l	d0
	beq	.no_relocation

	move.w	18(a0),d1
	move.w	22(a0),d2
	moveq	#4,d3
	bsr	rsrc_raddr	; Arbres
	move.w	4(a0),d1
	move.w	24(a0),d2
	moveq	#28,d3
	bsr	rsrc_raddr	; te_ptext
	move.w	4(a0),d1
	addq.w	#4,d1
	move.w	24(a0),d2
	moveq	#28,d3
	bsr	rsrc_raddr	; te_ptmplt
	move.w	4(a0),d1
	addq.w	#8,d1
	move.w	24(a0),d2
	moveq	#28,d3
	bsr	rsrc_raddr	; te_pvalid
	move.w	6(a0),d1
	move.w	26(a0),d2
	moveq	#34,d3
	bsr	rsrc_raddr	; ib_pmask
	move.w	6(a0),d1
	addq.w	#4,d1
	move.w	26(a0),d2
	moveq	#34,d3
	bsr	rsrc_raddr	; ib_pdata
	move.w	6(a0),d1
	addq.w	#8,d1
	move.w	26(a0),d2
	moveq	#34,d3
	bsr	rsrc_raddr	; ib_ptext
	move.w	8(a0),d1
	move.w	28(a0),d2
	moveq	#14,d3
	bsr	rsrc_raddr	; bi_pdata
	move.w	10(a0),d1
	move.w	30(a0),d2
	moveq	#4,d3
	bsr	rsrc_raddr	; chaines libres
	move.w	16(a0),d1
	move.w	32(a0),d2
	moveq	#4,d3
	bsr	rsrc_raddr	; images libres

	move.w	2(a0),d1	
	lea	(a0,d1.w),a1		; Adr objets
	move.w	20(a0),d1		; Nb objets
.relocate_obspec:
	tst.w	d1			; Tant qu'il y a des objets
	ble.s	.no_relocation
	move.w	6(a1),d2		; Type d'objets
	cmp.w	#20,d2
	beq.s	.no_obspec
	cmp.w	#25,d2
	beq.s	.no_obspec
	cmp.w	#27,d2
	beq.s	.no_obspec
	add.l	d0,12(a1)		; On reloge
.no_obspec:
	btst.b	#7,34(a0)
	bne.s	.no_first_relocation
	movem.l	d0-d2/a0-a1,-(sp)
	Rsrc_obfix	a1,#0
	movem.l	(sp)+,d0-d2/a0-a1
.no_first_relocation:
	lea	24(a1),a1
	subq.w	#1,d1
	bra.s	.relocate_obspec
.no_relocation:
	move.w	18(a0),d1
	lea	(a0,d1.w),a1
	move.l	a1,global+10
	move.l	a0,global+14
	bset.b	#7,34(a0)
	move.w	34(a0),global+18
	move.l	a0,12(a0)
	movem.l	(sp)+,d0-d3/a0-a1
	rts
	
rsrc_raddr:
; D1 : rsrc_pter
; D2 : rsrc_count
; D3 : rsrc_length
	lea	(a0,d1.w),a1
.relocate_structs:
	tst.w	d2
	ble.s	.end_structs_relocation
	add.l	d0,(a1)
	lea	(a1,d3.w),a1
	subq.w	#1,d2
	bra.s	.relocate_structs
.end_structs_relocation:
	rts

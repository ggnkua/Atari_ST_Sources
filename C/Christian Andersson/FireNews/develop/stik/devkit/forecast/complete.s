
	SECTION TEXT,CODE

	XDEF	_test_point,_get_point,_clear_mfdb,_move_mfdb

_test_point:
	movea.l	4(sp),a0	; Pointer to MFDB
	move.w	8(sp),d1	; Word x offset
	move.w	10(sp),d0	; Word y offset
	movea.l	(a0),a1		; .fd_addr
	move.w	8(a0),d2	; .fd_wdwidth
	ext.l	d0
	ext.l	d1
	ext.l	d2
	lsl		#1,d2
	muls.l	d2,d0
	move.l	d1,d2
	lsr		#3,d2
	add.l	d2,d0
	adda.l	d0,a1		; 2*wordwidth*y+x>>3 = byte offset into memory
	lsl		#3,d2
	sub.l	d2,d1		; x-(x>>3)<<3 = bit offset into memory
	clr.l	d0
	clr.l	d2
	move.b	(a1),d2
	btst	d1,d2
	sne		d0			; If Z is set, then bit is zero
	rts

_get_point:
	movea.l	4(sp),a0	; pointer to MFDB
	movea.l	(a0),a1		; .fd_addr
	move.w	6(a0),d1	; .fd_height
	move.w	8(a0),d2	; .fd_wdwidth
	movea.l	a1,a0
	muls	d2,d1
	ext.l	d2
	lsl.l	#1,d2
G1:	subq.l	#2,d1
	bmi.s	G4
	move.l	(a1)+,d0
	tst.l	d0
	beq.s	G1
	suba.l	#4,a1
G2:	move.b	(a1)+,d0
	tst.b	d0
	beq.s	G2
	suba.l	#1,a1
	move.l	a1,d1
	sub.l	a0,d1
	divs	d2,d1
	swap	d1
	lsl.w	#3,d1
	subq.w	#1,d1
G3:	addq.w	#1,d1
	lsl.b	#1,d0
	bcc.s	G3
	move.l	d1,d0
	rts
G4:	addq.l	#1,d1
	bne.s	G5
	move.w	(a1),d0
	tst.w	d0
	bne.s	G2
G5:	moveq.l	#-1,d0
	rts

_clear_mfdb:
	movea.l	4(sp),a0			; pointer to MFDB
	move.w	12(a0),d0			; .fd_height
	muls	8(a0),d0			; .fd_wdwidth
	muls	6(a0),d0			; .fd_nplanes
	movea.l	(a0),a0				; .fd_addr
	movem.l	d1-d7/a1,-(sp)
	moveq.l #0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	movea.l	d1,a1
Z1:	subi.l	#16,d0
	bmi.s	Z2
	movem.l	d1-d7/a1,(a0)		; Push zeros to address
	lea		32(a0),a0
	bra.s	Z1					; Go until the 16words are gone
Z2:	addi.l	#16,d0
	andi.l	#$F,d0
	subq.l	#1,d0
	bmi.s	ZE
Z3:	move.w	d1,(a0)+
	dbra	d0,Z3
ZE:	movem.l	(sp)+,d1-d7/a1
	rts

_move_mfdb:
	movea.l	4(sp),a0
	movea.l	8(sp),a1
	move.w	12(a0),d0
	muls	8(a0),d0
	muls	6(a0),d0
	movea.l	(a0),a0
	movea.l	(a1),a1
	movem.l	d1-d7/a2,-(sp)
M1:	subi.l	#16,d0
	bmi.s	M2
	movem.l	(a0)+,d1-d7/a2		; Push zeros to address
	movem.l	d1-d7/a2,(a1)
	lea		32(a1),a1
	bra.s	M1					; Go until the 16words are gone
M2:	addi.l	#16,d0
	subq.l	#1,d0
	bmi.s	ME
M3:	move.w	(a0)+,(a1)+
	dbra	d0,M3
ME:	movem.l	(sp)+,d1-d7/a2
	rts
	END
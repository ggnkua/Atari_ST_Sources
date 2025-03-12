	opt s-
	move.l 4(sp),a0
	pea $200
	pea (a0)
	move.w #0,-(sp)
	move.w #$4a,-(sp)
	trap #1
	add.l #12,sp
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,$20.w
	lea trap0,a0
	lea $1000,a1
ff	move.l (a0)+,(a1)+
	cmp.l #text,a0
	ble ff
	pea text
	move.w #9,-(sp)
	trap #1
	lea 6(sp),sp
	move.w #7,-(sp)
	trap #1
	lea 2(sp),sp
	move.l #$1000,$80.w
	move.l $20.w,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	pea env
	pea com
	pea file
	move.w #0,-(sp)
	move.w #$4b,-(sp) 
	trap #1
	clr.w -(sp)
	trap #1

trap0	movem.l d1-a6,$12a0
	move.l (a0),a0
	bsr decrunch
	movem.l $12a0,d1-a6
	move.w (sp),4(sp)
	lea 4(sp),sp
	rte

decrunch:	move.w $ffff8240.w,-(sp)
		move.l d0,-(sp)			; save registers
		cmpi.l	#'Ice!',(a0)+		; Data packed?
		bne.s	ice2_07			; no!
		move.l	(a0)+,d0
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		lea	108(a0),a4
		movea.l a4,a6
		adda.l	(sp),a6
		movea.l a6,a3
		movea.l a6,a1			; save 120 bytes
		lea	ice2_21+120(pc),a2	; at the end of the
		moveq	#$77,d0			; unpacked data
ice2_00:	move.b	-(a1),-(a2)
		dbra	d0,ice2_00
		bsr	ice2_0c
		bsr.s	ice2_08
ice2_04:	move.l	(sp),d0			; move all data to
		lea	-120(a4),a1		; 120 bytes lower
ice2_05:	move.b	(a4)+,(a1)+
		dbra	d0,ice2_05
		subi.l	#$010000,d0
		bpl.s	ice2_05
		moveq	#$77,d0			; restore saved data
		lea	ice2_21+120(pc),a2
ice2_06:	move.b	-(a2),-(a3)
		dbra	d0,ice2_06
ice2_07:	move.l (sp)+,d0			; restore registers
		move.w (sp)+,$ffff8240.w
		rts
ice2_08:	bsr.s	ice2_10
		bcc.s	ice2_0b
		moveq	#0,d1
		bsr.s	ice2_10
		bcc.s	ice2_0a
		lea	ice2_1e(pc),a1
		moveq	#4,d3
ice2_09:	move.l	-(a1),d0
		bsr.s	ice2_13
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice2_09
		add.l	20(a1),d1
ice2_0a:	move.b	-(a5),-(a6)
		move.b (a6),$ffff8240.w
		dbra	d1,ice2_0a
ice2_0b:	cmpa.l	a4,a6
		bgt.s	ice2_16
		rts
ice2_0c:	moveq	#3,d0
ice2_0d:	move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice2_0d
		rts
ice2_0e:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_0f
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice2_15
ice2_0f:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice2_15
ice2_10:	add.l	d7,d7
		beq.s	ice2_11
		rts
ice2_11:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_12
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice2_12:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice2_13:	moveq	#0,d1
ice2_14:	add.l	d7,d7
		beq.s	ice2_0e
ice2_15:	addx.w	d1,d1
		dbra	d0,ice2_14
		rts
ice2_16:	lea	ice2_1f(pc),a1
		moveq	#3,d2
ice2_17:	bsr.s	ice2_10
		dbcc	d2,ice2_17
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice2_18
		bsr.s	ice2_13
ice2_18:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice2_1a
		lea	ice2_20(pc),a1
		moveq	#1,d2
ice2_19:	bsr.s	ice2_10
		dbcc	d2,ice2_19
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice2_13
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice2_1c
ice2_1a:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice2_10
		bcc.s	ice2_1b
		moveq	#8,d0
		moveq	#$40,d2
ice2_1b:	bsr.s	ice2_13
		add.w	d2,d1
ice2_1c:	lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice2_1d:	move.b	-(a1),-(a6)
		dbra	d4,ice2_1d
		bra	ice2_08
		dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
		dc.b $00,$07,$00,$02,$00,$03,$00,$01
		dc.b $00,$03,$00,$01
ice2_1e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
		dc.b $00,$00,$00,$07,$00,$00,$00,$04
		dc.b $00,$00,$00,$01
ice2_1f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
		dc.b $01,$00
ice2_20:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
		dc.b $00,$20
ice2_21:	ds.w 60			; free space (can be put in BSS)

env	dc.l 0
com	dc.l 0
file	dc.b 'streets.zip',0
text	dc.b 27,'E',27,'f',27,'w'
	dc.b "TMB of THE CORPORATION PRESENTS",10,10,13
	dc.b "MEAN STREETS",10,10,13
	dc.b "CRACKED AND PACKED BY ZIPPY",10,10,10,13
	DC.B "THIS GAME WAS ON TWO DOUBLE SIDED 11",10,13
	DC.B "SECTOR DISKS, NOW IT'S BEEN PACKED ONTO",10,13
	DC.B "2 10 SECTORS DISKS WITH ANOTHER TWO",10,13
	DC.B "GAMES !!!"
	even
	dc.w 0

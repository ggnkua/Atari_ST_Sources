;**************************************************************************
; Unpacking Routine for Pack-Ice 2.34. Written by Axe/Superior
; This routine unpacks any packed datafile onto itself.
; Input:  a0: Address of packed Data
; Output: d0: Length of unpacked data
;**************************************************************************
ice_decrunch_2:
	link	a3,#-$78
	movem.l d0-a6,-(sp)
	lea	120(a0),a4
	movea.l a4,a6
	bsr.s	L0009
	cmpi.l	#'ICE!',d0
	bne	L0008
	bsr.s	L0009
	lea	-8(a0,d0.l),a5
	bsr.s	L0009
	move.l	d0,(sp)
	adda.l	d0,a6
	movea.l a6,a1
	moveq	#$77,d0
L0000:	move.b	-(a1),-(a3)
	dbra	d0,L0000
	movea.l a6,a3
	move.b	-(a5),d7
	bsr.s	L000A
	movea.l a3,a6
	bsr.s	L000E
	bcc.s	L0005
	move.w	#$0f9f,d1
	bsr.s	L000E
	bcc.s	L0001
	moveq	#$0f,d0
	bsr.s	L0010
L0001:	move.w	d1,d7
L0002:	moveq	#3,d6
L0003:	move.w	-(a3),d4
	moveq	#3,d5
L0004:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,L0004
	dbra	d6,L0003
	movem.w d0-d3,(a3)
	dbra	d7,L0002
L0005:	movem.l (sp),d0-a3
L0006:	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	L0006
	moveq	#$77,d0
L0007:	move.b	-(a3),-(a6)
	dbra	d0,L0007
L0008:	movem.l (sp)+,d0-a6
	unlk	a3
	rts
L0009:	bra.s	L0013
L000A:	bsr.s	L000E
	bcc.s	L000D
	moveq	#0,d1
	bsr.s	L000E
	bcc.s	L000C
	lea	L001D(pc),a1
	moveq	#4,d3
L000B:	move.l	-(a1),d0
	bsr.s	L0010
	swap	d0
	cmp.w	d0,d1
	dbne	d3,L000B
	add.l	20(a1),d1
L000C:	move.b	-(a5),-(a6)
	dbra	d1,L000C
L000D:	cmpa.l	a4,a6
	bgt.s	L0015
	rts
L000E:	add.b	d7,d7
	bne.s	L000F
	move.b	-(a5),d7
	addx.b	d7,d7
L000F:	rts
L0010:	moveq	#0,d1
L0011:	add.b	d7,d7
	bne.s	L0012
	move.b	-(a5),d7
	addx.b	d7,d7
L0012:	addx.w	d1,d1
	dbra	d0,L0011
	rts
L0013:	moveq	#3,d1
L0014:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,L0014
	rts
L0015:	lea	L001E(pc),a1
	moveq	#3,d2
L0016:	bsr.s	L000E
	dbcc	d2,L0016
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	L0017
	bsr.s	L0010
L0017:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	L0019
	lea	L001F(pc),a1
	moveq	#1,d2
L0018:	bsr.s	L000E
	dbcc	d2,L0018
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	L0010
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	L001B
	sub.w	d4,d1
	bra.s	L001B
L0019:	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	L000E
	bcc.s	L001A
	moveq	#8,d0
	moveq	#$3f,d2
L001A:	bsr.s	L0010
	add.w	d2,d1
L001B:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
L001C:	move.b	-(a1),-(a6)
	dbra	d4,L001C
	bra	L000A
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
L001D:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
L001E:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
L001F:	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f
;**************************************************************************

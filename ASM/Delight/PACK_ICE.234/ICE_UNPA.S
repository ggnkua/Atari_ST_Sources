;**************************************************************************
; Unpacking Routine for Pack-Ice 2.34. Written by Axe/Superior
; This unpack routines unpacks packed data to any address in memory:
; Input:  a0: Beginning of packed data
;         a1: Target address for unpacked data
; Output: d0: Length of unpacked data
; Watch out that the unpacked data does not overwrite the packed data.
;**************************************************************************
ice_decrunch:
	movem.l d0-a6,-(sp)
	bsr.s	L0005
	cmpi.l	#'ICE!',d0
	bne.s	L0004
	bsr.s	L0005
	lea	-8(a0,d0.l),a5
	bsr.s	L0005
	move.l	d0,(sp)
	movea.l a1,a4
	movea.l a1,a6
	adda.l	d0,a6
	movea.l a6,a3
	move.b	-(a5),d7
	bsr.s	L0007
	bsr.s	L000B
	bcc.s	L0004
	move.w	#$0f9f,d1
	bsr.s	L000B
	bcc.s	L0000
	moveq	#$0f,d0
	bsr.s	L000D
L0000:	move.w	d1,d7
L0001:	moveq	#3,d6
L0002:	move.w	-(a3),d4
	moveq	#3,d5
L0003:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,L0003
	dbra	d6,L0002
	movem.w d0-d3,(a3)
	dbra	d7,L0001
L0004:	movem.l (sp)+,d0-a6
	rts
L0005:	moveq	#3,d1
L0006:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,L0006
	rts
L0007:	bsr.s	L000B
	bcc.s	L000A
	moveq	#0,d1
	bsr.s	L000B
	bcc.s	L0009
	lea	L0018(pc),a1
	moveq	#4,d3
L0008:	move.l	-(a1),d0
	bsr.s	L000D
	swap	d0
	cmp.w	d0,d1
	dbne	d3,L0008
	add.l	20(a1),d1
L0009:	move.b	-(a5),-(a6)
	dbra	d1,L0009
L000A:	cmpa.l	a4,a6
	bgt.s	L0010
	rts
L000B:	add.b	d7,d7
	bne.s	L000C
	move.b	-(a5),d7
	addx.b	d7,d7
L000C:	rts
L000D:	moveq	#0,d1
L000E:	add.b	d7,d7
	bne.s	L000F
	move.b	-(a5),d7
	addx.b	d7,d7
L000F:	addx.w	d1,d1
	dbra	d0,L000E
	rts
L0010:	lea	L0019(pc),a1
	moveq	#3,d2
L0011:	bsr.s	L000B
	dbcc	d2,L0011
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	L0012
	bsr.s	L000D
L0012:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	L0014
	lea	L001A(pc),a1
	moveq	#1,d2
L0013:	bsr.s	L000B
	dbcc	d2,L0013
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	L000D
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	L0016
	sub.w	d4,d1
	bra.s	L0016
L0014:	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	L000B
	bcc.s	L0015
	moveq	#8,d0
	moveq	#$3f,d2
L0015:	bsr.s	L000D
	add.w	d2,d1
L0016:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
L0017:	move.b	-(a1),-(a6)
	dbra	d4,L0017
	bra	L0007
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
L0018:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
L0019:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
L001A:	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f
;*************************************************************************


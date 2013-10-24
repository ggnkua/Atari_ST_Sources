; This is the unpacking source for Pack-Ice.
; Pack-Ice and this unpacking source were written by Axe of Delight.
; The unpacking routine is called with "bsr unpack".
; a0: is a pointer on the packed data
; d0: indicates the length of the packed data
; In return, you will get the new length in d0

unpack: movem.l d0-a6,-(sp)

	lea	$ffff8240.w,a4		these two lines only required
	move.w	(a4),d6			if you want the color flashing

	lea	0(a0,d0.l),a5
	bsr.s	L0017
	cmpi.l	#'Ice!',d7
	bne.s	L0012
	adda.w	#$78,a0
	bsr.s	L0017
	move.l	d7,(sp)
	lea	0(a0,d7.l),a6
	movea.l a6,a3
	movea.l a6,a1
	lea	savemem+$78(pc),a2
	moveq	#$77,d0
L000F:	move.b	-(a1),-(a2)
	dbra	d0,L000F
	bsr.s	L0017
	bsr.s	L0013
	move.l	(sp),d0
	lea	-120(a0),a1
L0010:	move.b	(a0)+,(a1)+
	dbra	d0,L0010
	subi.l	#$010000,d0
	bpl.s	L0010
	moveq	#$77,d0
	lea	savemem+$78(pc),a2
L0011:	move.b	-(a2),-(a3)
	dbra	d0,L0011
L0012:	movem.l (sp)+,d0-a6
	rts
L0013:	bsr.s	L001B
	bcc.s	L0016
	moveq	#0,d1
	bsr.s	L001B
	bcc.s	L0015
	lea	L0028(pc),a1
	moveq	#3,d3
L0014:	move.l	-(a1),d0
	bsr.s	L001E
	swap	d0
	cmp.w	d0,d1
	dbne	d3,L0014
	add.l	16(a1),d1
L0015:	move.b	-(a5),-(a6)
	dbra	d1,L0015
L0016:
	move.w	d2,(a4)		these two lines do the color flashing
	move.w	d6,(a4)		during depack

	cmpa.l	a0,a6
	bgt.s	L0020
	rts
L0017:	moveq	#3,d0
L0018:	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,L0018
	rts
L0019:	move.w	a5,d7
	btst	#0,d7
	bne.s	L001A
	move.l	-(a5),d7
	addx.l	d7,d7
	addx.w	d1,d1
	dbra	d0,L001F
	rts
L001A:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	addx.w	d1,d1
	dbra	d0,L001F
	rts
L001B:	add.l	d7,d7
	beq.s	L001C
	rts
L001C:	move.w	a5,d7
	btst	#0,d7
	bne.s	L001D
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
L001D:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
L001E:	moveq	#0,d1
L001F:	add.l	d7,d7
	beq.s	L0019
	addx.w	d1,d1
	dbra	d0,L001F
	rts
L0020:	lea	L0029(pc),a1
	moveq	#3,d2
L0021:	bsr.s	L001B
	dbcc	d2,L0021
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	L0022
	bsr.s	L001E
L0022:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	L0024
	lea	L002A(pc),a1
	moveq	#1,d2
L0023:	bsr.s	L001B
	dbcc	d2,L0023
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	L001E
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	L0026
L0024:	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	L001B
	bcc.s	L0025
	moveq	#8,d0
	moveq	#$40,d2
L0025:	bsr.s	L001E
	add.w	d2,d1
L0026:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
L0027:	move.b	-(a1),-(a6)
	dbra	d4,L0027
	bra	L0013

	  dc.b $03,$FF,$00,$09,$00,$07,$00,$02
	  dc.b $00,$03,$00,$01,$00,$03,$00,$01
L0028:	  dc.b $00,$00
	  dc.b $00,$0E,$00,$00,$00,$07,$00,$00
	  dc.b $00,$04,$00,$00,$00,$01
L0029:	  dc.b $09,$01,$00,$FF,$FF,$08,$04,$02
	  dc.b $01,$00
L002A:	  dc.b $0B,$04,$07,$00,$01,$20,$00,$00
	  dc.b $00,$20

savemem:  ds.b 120
start	incbin	"a:\doc_2_2.bak"

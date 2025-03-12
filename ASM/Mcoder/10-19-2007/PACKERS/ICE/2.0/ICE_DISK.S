begin:	movea.l	#freespace+$0270,sp
	move.l	sp,d0
	subi.l	#begin-$0120,d0
	move.l	d0,-(sp)
	pea	begin-$0100(pc)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#$0c,sp
	bsr.s	l0004
	move.l	$84.w,l0008+2
	move.l	#l0006,$84.w
	bsr.s	l0005
	pea	l0002(pc)
	pea	l0002(pc)
	pea	filename(pc)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	bsr.s	l0004
	move.l	l0008+2(pc),$84.w
	bsr.s	l0005
	clr.w	-(sp)
	trap	#1

l0002:	dc.l 0
filename: dc.b 'resource.del',0
	even

l0004:	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7
	rts
l0005:	move.l	d7,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
l0006:	movea.l	sp,a0
	btst	#$0d-8,(sp)
	bne.s	l0007
	move	usp,a0
	subq.l	#6,a0
l0007:	addq.l	#6,a0
	cmpi.w	#$3f,(a0)
	beq.s	l000a
l0008:	jmp	$00
l000a:	move.l	8(a0),freespace+$78
	move.l	2(sp),l000c+2
	move.l	#l000b,2(sp)
	bra.s	l0008
l000b:	tst.w	2(sp)
	bmi.s	l000c
	movea.l	freespace+$78(pc),a0
	bsr.s	l000e
l000c:	jmp	$00
l000e:	movem.l	d0-a6,-(sp)
	lea	0(a0,d0.l),a5
	bsr.s	l0017
	cmpi.l	#'Ice!',d7
	bne.s	l0012
	adda.w	#$78,a0
	bsr.s	l0017
	move.l	d7,(sp)
	lea	0(a0,d7.l),a6
	movea.l	a6,a3
	movea.l	a6,a1
	lea	freespace+$78(pc),a2
	moveq	#$77,d0
l000f:	move.b	-(a1),-(a2)
	dbra	d0,l000f
	bsr.s	l0017
	bsr.s	l0013
	move.l	(sp),d0
	lea	-120(a0),a1
l0010:	move.b	(a0)+,(a1)+
	dbra	d0,l0010
	subi.l	#$010000,d0
	bpl.s	l0010
	moveq	#$77,d0
	lea	freespace+$78(pc),a2
l0011:	move.b	-(a2),-(a3)
	dbra	d0,l0011
l0012:	movem.l	(sp)+,d0-a6
	rts
l0013:	bsr.s	l001b
	bcc.s	l0016
	moveq	#0,d1
	bsr.s	l001b
	bcc.s	l0015
	lea	l0028(pc),a1
	moveq	#3,d3
l0014:	move.l	-(a1),d0
	bsr.s	l001e
	swap	d0
	cmp.w	d0,d1
	dbne	d3,l0014
	add.l	16(a1),d1
l0015:	move.b	-(a5),-(a6)
	dbra	d1,l0015
l0016:	cmpa.l	a0,a6
	bgt.s	l0020
	rts
l0017:	moveq	#3,d0
l0018:	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,l0018
	rts
l0019:	move.w	a5,d7
	btst	#0,d7
	bne.s	l001a
	move.l	-(a5),d7
	addx.l	d7,d7
	addx.w	d1,d1
	dbra	d0,l001f
	rts
l001a:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	addx.w	d1,d1
	dbra	d0,l001f
	rts
l001b:	add.l	d7,d7
	beq.s	l001c
	rts
l001c:	move.w	a5,d7
	btst	#0,d7
	bne.s	l001d
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
l001d:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
l001e:	moveq	#0,d1
l001f:	add.l	d7,d7
	beq.s	l0019
	addx.w	d1,d1
	dbra	d0,l001f
	rts
l0020:	lea	l0029(pc),a1
	moveq	#3,d2
l0021:	bsr.s	l001b
	dbcc	d2,l0021
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	l0022
	bsr.s	l001e
l0022:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	l0024
	lea	l002a(pc),a1
	moveq	#1,d2
l0023:	bsr.s	l001b
	dbcc	d2,l0023
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	l001e
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	l0026
l0024:	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	l001b
	bcc.s	l0025
	moveq	#8,d0
	moveq	#$40,d2
l0025:	bsr.s	l001e
	add.w	d2,d1
l0026:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
l0027:	move.b	-(a1),-(a6)
	dbra	d4,l0027
	bra	l0013

	dc.b $03,$ff,$00,$09,$00,$07,$00,$02
	dc.b $00,$03,$00,$01,$00,$03,$00,$01
l0028:	dc.b $00,$00
	dc.b $00,$0e,$00,$00,$00,$07,$00,$00
	dc.b $00,$04,$00,$00,$00,$01
l0029:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b $01,$00
l002a:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
	dc.b $00,$20

	bss
freespace:ds.b 644




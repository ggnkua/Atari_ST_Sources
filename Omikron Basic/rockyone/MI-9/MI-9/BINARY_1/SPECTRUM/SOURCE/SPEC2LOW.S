; source:  SYNTHETIC ART v1

	OPT O+,W-
	INCLUDE super.s
	
	movem.l	Gray(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.l	$ffff8200.w,d0
	lsl.w	#8,d0
	and.l	#$ffff00,d0
	move.l	d0,Logic

	move.l	d0,-(sp)
	pea	Palettes(pc)
	pea	Picture(pc)
	bsr	SpectrumConvert
	lea	12(sp),sp
	
WaitKey	moveq	#-96,d0
	and.b	$fffffc00.w,d0
	beq.s	WaitKey
	move.b	$fffffc02.w,d0
	cmp.b	#$39,d0
	bne.s	WaitKey
	rts


SpectrumConvert
	lea	ConvTable+320*16,a0
	move.w	#160,d5
	move.w	#319,d6	x
PreCalcXL	moveq	#15,d7	c
PreCalcCL	move.w	d7,d1	c'
	moveq	#10,d0
	mulu	d7,d0	x1=c*10
	addq.w	#1,d0	
	btst	#0,d7
	beq	.Even
	subq.w	#6,d0
.Even	cmp.w	d6,d0
	bgt	.Next
	add.w	#16,d1
	add.w	d5,d0
	cmp.w	d6,d0
	bgt	.Next
	add.w	#16,d1
.Next	add.w	d1,d1
	move.b	d1,-(a0)
	dbf	d7,PreCalcCL
	dbf	d6,PreCalcXL

	move.l	8(sp),a0
	move.w	#16*3*199-1,d7
	moveq	#0,d6
ConvColor	and.b	#15,d6
	bne.s	.Skip
	clr.w	(a0)+
	bra	.Cont
.Skip	moveq	#$7,d0
	and.b	(a0)+,d0
	moveq	#$7,d1
	move.b	(a0),d2
	and.w	d2,d1
	lsr.b	#4,d2
	add.b	d1,d0
	add.b	d2,d0
	add.w	d0,d0
	divu	#3,d0
	move.b	d0,(a0)+
.Cont	addq.b	#1,d6
	dbf	d7,ConvColor
	
	move.l	4(sp),a0		Bitmap
	move.l	8(sp),a1		Colors
	move.l	12(sp),a2		Destination
	lea	ConvTable,a3	ConvTable
	move	#198,d7		LineIndex (1-199)
	lea	160(a0),a0
	lea	160(a2),a2
LineLoop	moveq	#19,d6
	lea	LineBuffer,a4
	lea	ConvTable,a3

XLoop1	movem.w	(a0)+,d0-d3
	moveq	#15,d5
XSLoop1	moveq	#0,d4
	add.w	d3,d3
	addx.w	d4,d4
	add.w	d2,d2
	addx.w	d4,d4
	add.w	d1,d1
	addx.w	d4,d4
	add.w	d0,d0
	addx.w	d4,d4
	move.b	0(a3,d4.w),d4
	move.b	1(a1,d4.w),(a4)+
	lea	16(a3),a3
	dbf	d5,XSLoop1
	dbf	d6,XLoop1
	lea	32*3(a1),a1

	lea	LineBuffer,a4
	moveq	#19,d6
XLoop2	moveq	#15,d5
XSLoop2	move.b	(a4)+,d4
	lsr.b	#1,d4
	addx.w	d0,d0
	lsr.b	#1,d4
	addx.w	d1,d1
	lsr.b	#1,d4
	addx.w	d2,d2
	lsr.b	#1,d4
	addx.w	d3,d3
	dbf	d5,XSLoop2
	movem.w	d0-d3,(a2)
	lea	8(a2),a2
	dbf	d6,XLoop2
	dbf	d7,LineLoop
	rts
	
	SECTION DATA
Gray	dc.w	0,$888,$111,$999,$222,$aaa,$333,$bbb
	dc.w	$444,$ccc,$555,$ddd,$666,$eee,$777,$fff
Picture	INCBIN	d:\test.spu
Palettes	=	Picture+32000

	SECTION BSS
ConvTable	ds.b	320*16
LineBuffer	ds.b	320
Logic	ds.l	1

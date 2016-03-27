*************************************
* SECOND PROTECTION FOR MY DEMO !!! *
*************************************
	*OPT	X+
	moveq	#0,d7
	lea	File(pc),a0
	lea	$7d00.w,a1
	move.w	#2779,d7
Åberx	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d7,Åberx



	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.w	#6,a7
	lea	$140.w,a0
	lea	PROGRAM(pc),a1
	moveq	#10,d7
Zab	rept	6
	move.l	(a1)+,(a0)+
	endr
	dbf	d7,Zab
Lajt	move.l	a0,a0
	move.l	a1,a1
	move.l	a2,a2
	move.l	a3,a3
	move.l	a4,a4
	move.l	a5,a5
	move.l	a6,a6
	move.l	a7,a7
	dbf	d7,Lajt
	jmp	$140.w
PROGRAM
	move.b	#2,$ffff8260.w
	moveq	#0,d0
	move.l	d0,$fffffa06.w
	move.l	d0,$fffffa12.w
L152	clr.l	$400.w
	clr.l	$426.w
	clr.b	$42a.w
	move.b	#$12,$fffffc02.w
	move.b	#$13,$fffffc02.w
	clr.b	$ffff8260.w
	move.l	$462.w,d0
	addq.w	#3,d0
Syncuj	cmp.l	$462.w,d0
	bne.s	Syncuj
	move.w	#$2300,sr
	move.b	#2,$ffff820a.w
	move.l	$466.w,d0
	addq.w	#3,d0
Syncuj2	cmp.l	$466.w,d0
	bne.s	Syncuj2
	nop
	lea	$7d00.w,a0
	move.w	#2779,d7
	lea	$ffff8209.w,a1
Ntw	move.b	(a1),d0
	beq.s	Ntw
	not.w	d0
	lsl.w	d0,d0
L196	clr.l	$26.w
	move.w	$1a6.w,d0
	move.b	(a1),d1
	add.b	(a1),d1
	add.b	(a1)+,d1
	add.w	d1,d1
	lsl.w	#2,d1
	moveq	#$10,d2
	add.w	$7e1c(a1),d1
	exg	d2,a1
	add.w	d0,d1
	move.l	(a1),$234.w
	move.l	#$232,(a1)
	move.w	sr,d0
	or.b	-$607(a1),d0
	add.w	d1,d0
	move.w	d0,d2
	abcd	d1,d2
	ror.w	#8,d2
	sbcd	d1,d2
	muls	d2,d2
	swap	d0
	move.w	d2,d0
	and.w	#$ab0f,sr
Zakod
	move.l	(a0),d2
	eor.l	d0,d2
	move.l	d2,(a0)+
	add.l	$16(a1),d1
	move.w	sr,d3
	swap	d3
	move.w	sr,d3
	add.l	d3,d1
	move.l	(a0),d2
	eor.l	d1,d2
	move.l	d2,(a0)+
	move.b	d1,-$7e06(a1)
	dbf	d7,Zakod
	move.b	#2,-$7e06(a1)
	moveq	#0,d0
loop	jmp	$7d00.w
	bra.s	loop
	dc.b	'Jestes juz tutaj'
	dc.b	' maly lamerze!!!'
Vbel	add.l	#$BE0DEAD,$400.w
	rte
File	incbin	\quast_6d.bin

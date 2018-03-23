	pea	truc
	move.w	#38,-(sp)
	trap	#14
	lea	6(sp),sp
	clr.w	-(sp)
	trap	#1

truc
	clr.w	-(sp)
	pea	-1.l
	pea	-1.l
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	$1f8000,a5
	lea	picture+34,a0
	lea	Bitplane1,a1
	lea	Bitplane2,a2
	lea	Bitplane3,a3
	lea	Bitplane4,a4
	move.w	#32000/8-1,d0
yop	move.w	(a0),(a5)+
	move.w	(a0)+,(a1)+
	move.w	(a0),(a5)+
	move.w	(a0)+,(a2)+
	move.w	(a0),(a5)+
	move.w	(a0)+,(a3)+
	move.w	(a0),(a5)+
	move.w	(a0)+,(a4)+
	dbra	d0,yop

Routine_Conversion

	lea	buffer,a6
	lea	Bitplane1,a1
	lea	Bitplane2,a2
	lea	Bitplane3,a3
	lea	Bitplane4,a4
	lea	Bitplane5,a5

	move.w	#(20*200)-1,d0
Boucle1
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6

	move.w	(a1)+,d1
	move.w	(a2)+,d2
	move.w	(a3)+,d3
	move.w	(a4)+,d4
	move.w	(a5)+,d5

	move.w	#15,d7
boucle2	
	add.w	d5,d5
	addx.w	d6,d6
	add.w	d4,d4
	addx.w	d6,d6
	add.w	d3,d3
	addx.w	d6,d6
	add.w	d2,d2
	addx.w	d6,d6
	add.w	d1,d1
	addx.w	d6,d6
	and.w	#$f,d6
	move.b	d6,(a6)+
	dbra	d7,boucle2

	dbra	d0,boucle1


	lea	buffer,a0
	lea	buffer,a1
	lea	tab_couls,a6
	lea	$1f8000,a2
	lea	$1f0000,a3

	move.w	#(20*200)-1,d7
boucle4
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4

	move.w	#15,d6
boucle3
 	moveq	#0,d0
	moveq	#0,d5
	move.b	(a0)+,d0
	add.w	d0,d0
	move.b	(a6,d0.w),d5
	lsr	d5
	addx	d1,d1
	lsr	d5
	addx	d2,d2
	lsr	d5
	addx	d3,d3
	lsr	d5
	addx	d4,d4
	dbra	d6,boucle3
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d4,(a2)+

	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4

	move.w	#15,d6
boucle5
 	moveq	#0,d0
	moveq	#0,d5
	move.b	(a1)+,d0
	add.w	d0,d0
	move.b	1(a6,d0.w),d5
	lsr	d5
	addx	d1,d1
	lsr	d5
	addx	d2,d2
	lsr	d5
	addx	d3,d3
	lsr	d5
	addx	d4,d4
	dbra	d6,boucle5
	move.w	d1,(a3)+
	move.w	d2,(a3)+
	move.w	d3,(a3)+
	move.w	d4,(a3)+


	dbra	d7,boucle4

loop	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp
	
	move.l	log,d0
	move.l	phys,log
	move.l	d0,phys
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	cmpi.b	#$39,$fffffc02.w
	bne	loop

	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp
	rts

log	dc.l	$1f8000
phys	dc.l	$1f0000
tab_couls
	dc.b	0,0
	dc.b	1,10
	dc.b	2,2
	dc.b	3,14
	dc.b	4,4
	dc.b	5,9
	dc.b	6,15
	dc.b	7,1
	dc.b	8,8
	dc.b	9,5
	dc.b	10,2
	dc.b	11,4
	dc.b	12,6
	dc.b	13,8
	dc.b	14,1
	dc.b	15,7


picture	incbin	b:kity.pi1
bufferp	ds.b	40*200*5
Bitplane1	equ	bufferp
Bitplane2	equ	bufferp+40*200
Bitplane3	equ	bufferp+40*200*2
Bitplane4	equ	bufferp+40*200*3
Bitplane5	equ	bufferp+40*200*4

buffer	ds.b	320*200
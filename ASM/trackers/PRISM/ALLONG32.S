*
*	convert 32 instruments for volume replay routine
*


ecart	equ	500

debut:
	lea	module+$3b8,a0
	move.w	#128-1,d5
	moveq	#0,d1
.loop1:
	move.b	(a0)+,d0
	cmp.b	d1,d0
	blt.s	.ok1
	move.b	d0,d1
.ok1:
	dbf	d5,.loop1

	addq.w	#1,d1
	mulu	#1024,d1
	move.l	d1,adr300


	lea	module,a0
	lea	20(a0),a0

	lea	module+$43c,a1
	add.l	d1,a1
	lea	tab,a3
	moveq	#0,d7
	move.w	#31-1,d1
loop1:
	moveq	#0,d0
	lea	22(a0),a0
	move.w	(a0),d0		nb mots ins
	add.l	d0,d0		nb octets ins
	move.l	d0,(a3)+
	add.l	d0,d7
	lea	8(a0),a0
	dbf	d1,loop1

	lea	module+$43c,a0
	add.l	adr300,a0
	lea	ins,a1
	move.l	a1,a2
	add.l	d7,a2
loop2:
	move.b	(a0)+,d0
	bclr	#0,d0
	move.b	d0,(a1)+
	
*	move.b	(a0)+,(a1)+	recopie des ins
	cmp.l	a2,a1
	bne.s	loop2


	lea	module+$43c,a1
	add.l	adr300,a1
	lea	ins,a0
	lea	tab,a2
	move.w	#31-1,d0
loop3:
	move.l	(a2)+,d1
	beq.s	cont
	move.l	a1,a3
	add.l	d1,a3
loop4:
	move.b	(a0)+,(a1)+
	cmp.l	a3,a1
	blt.s	loop4

	move.w	#ecart-1,d1
loop5:
	move.b	#$0,(a1)+
	dbf	d1,loop5
cont
	dbf	d0,loop3

	lea	module,a0
	subq.l	#1,a1

	illegal

	section	data

module:	incbin	"swing.mod"
	even
	section	bss
	ds.w	ecart*32


adr300	ds.l	1

tab:	ds.L	64

ins:
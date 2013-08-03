* Ett litet sug-„lg-sperma-Ceasar-intro
* Av Mind-design 1998
* K†dat av deez till ingen nytta alls faktiskt...
*
* This is how we do it!! ;)



	move.w	#2,-(sp)
	trap	#14
	move.l	d0,a5			* screen

	lea.l	blob_data(pc),a0
	move.l	a0,a3

	move.l	#32768/4,d1
	moveq.w	#110,d5
	move.w	#200-1,d6
loop1	move.w	#320-1,d7
loop	move.w	d7,d2
	move.w	d6,d3
	sub.w	d5,d2
	sub.w	d5,d3
	muls.w	d2,d2
	muls.w	d3,d3
	add.l	d2,d3
	cmp.l	d1,d3
	blt.s	.less
	clr.w	d4
	bra.s	gott
.less	divu.w	d5,d3
	move.w	d5,d4
	sub.w	d3,d4
	mulu.w	d4,d4
	mulu.w	d4,d4
	swap.w	d4
	asr.w	#5,d4
gott	move.w	d4,(a0)+
	dbra	d7,loop
	dbra	d6,loop1

	fmove.w	d5,fp1
draw	fadd.s	#0.05,fp1
	fsin.x	fp1,fp0
	fmul.w	d5,fp0
	fmove.l	fp0,d0

	lea.l	(a3,d1.w*2),a1
	lea.l	(a3,d0.w*2),a2

	move.l	a5,a0
	move.w	#320*200-1,d7
bobb	move.w	(a1)+,d0
	add.w	(a2)+,d0
	move.w	d0,(a0)+
	dbra	d7,bobb
	subq.w	#2,d1
	bra.s	draw

	section	bss
		ds.l	1000
blob_data	ds.l	320*200

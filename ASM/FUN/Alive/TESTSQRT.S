	move.l	#5617,d1
	move.l	d1,-(sp)
	bsr	CALC_ATARISQRT
	move.l	(sp)+,d1
	mulu.l	d0,d2:d0
	move.w	d2,d0

	clr.w	-(sp)
	trap	#1

* Very fast and accurate squareroot algorithm.
* Quite lengthy, though: 64 bytes.
* INPUT: d1.l: value to calculate the squareroot of (integer)
* OUTPUT: d0.l: squareroot of value (16.16 fixed point)
CALC_ATARISQRT:
	moveq	#1,d2
	ror.l	#2,d2
	moveq	#$F,d3
.loop1:	cmp.l	d2,d1
	bgt.s	.endloop1
	add.l	d1,d1
	lsr.l	#1,d2
	dbf	d3,.loop1
	bra.s	.end
.endloop1:

	sub.l	d2,d1
	move.l	d2,d0
	lsr.l	#1,d2
.loop2:	lsr.l	#1,d2
	add.l	d2,d0
	cmp.l	d0,d1
	bgt.s	.endloop2
	sub.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2
	bra.s	.end
.endloop2:

	sub.l	d0,d1
	add.l	d2,d0
	add.l	d1,d1
	dbf	d3,.loop2

.end:	add.l	d0,d0
	addi.l	#$00008000,d0
	rts

* Fast, but inaccurate squareroot algorithm.
* Very short, though: only 26 bytes.
* INPUT: d0.l: value to calculate the squareroot of (integer)
* OUTPUT: d0.w: squareroot of value (integer)
CALC_AMISQRT:
	moveq	#1,d3
	ror.l	#2,d3
	moveq	#32,d2		
.l2n:	move.l	d3,d4
	rol.l	d2,d4
	add.w	d3,d3
	cmp.l	d4,d0
	bcs.s	.no
	addq.w	#1,d3
	sub.l	d4,d0
.no:	subq.w	#2,d2
	bgt.b	.l2n
	move.l	d3,d0
	rts
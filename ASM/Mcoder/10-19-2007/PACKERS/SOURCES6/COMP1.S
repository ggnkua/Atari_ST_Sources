;
; 1Šre m‚thode : r‚p‚tition avec bytes
;
debut:	equ	$20000
fin:	equ	debut+20000
repeat:	equ	$40000

	lea	debut,a0
	lea	fin,a1
	moveq	#0,d6
	lea	repeat,a6
	moveq	#0,d0
rept:	move.b	(a0)+,d0
	cmp.b	(a0),d0
	beq.s	same
suite:	cmp.l	a1,a0
	blo.s	rept
	illegal

same:
	cmp.b	1(a0),d0
	bne.s	suite
	moveq	#0,d7
count:	addq	#1,d7
	cmp.b	(a0)+,d0
	beq.s	count
	subq	#1,a0
	move	d7,(a6)+
	move	d0,(a6)+
	subq	#1,d7
	add.l	d7,d6
	bra.s	suite



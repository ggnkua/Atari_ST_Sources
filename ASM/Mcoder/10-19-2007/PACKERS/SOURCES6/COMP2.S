;
; 1Šre m‚thode : r‚p‚tition avec bytes
;
debut:	equ	$20000
fin:	equ	debut+224094
repeat:	equ	$57000

	lea	debut,a0
	lea	fin,a1
	moveq	#0,d6
	lea	repeat,a6
	moveq	#0,d0
rept:	move.l	(a0)+,d0
	cmp.l	(a0),d0
	beq.s	same
suite:	cmp.l	a1,a0
	blo.s	rept
	illegal

same:
	cmp.l	4(a0),d0
	bne.s	suite
	moveq	#0,d7
count:	addq	#1,d7
	cmp.l	(a0)+,d0
	beq.s	count
	subq	#4,a0
	move	d7,(a6)+
	move.l	d0,(a6)+
	subq	#1,d7
	add.l	d7,d6
	bra.s	suite



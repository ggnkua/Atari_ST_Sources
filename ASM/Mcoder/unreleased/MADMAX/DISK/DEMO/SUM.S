long=408482
;MUSICS=408482 (158674),$55DC1161,$BCA5A15F

	lea	$80000,a0
	move.l	a0,a1
	add.l	#long&-4,a1
	moveq	#0,d0
	moveq	#0,d1
sum:
	move.l	(a0)+,d2
	eor.l	d2,d0
	add.l	d2,d1
	cmp.l	a1,a0
	blo.s	sum
	illegal

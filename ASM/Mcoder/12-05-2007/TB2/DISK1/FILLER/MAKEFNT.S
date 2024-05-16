
	lea	dest,a1
	lea	pic,a0
loop1:
	move.w	(a0)+,d0
	lsr.w	#8,d0
	move.b	d0,(a1)+

	cmp.l	#fpic,a0
	blt.s	loop1

	illegal

pic:
	incbin	fnt.bin
fpic:

dest:	ds.b	5000
	
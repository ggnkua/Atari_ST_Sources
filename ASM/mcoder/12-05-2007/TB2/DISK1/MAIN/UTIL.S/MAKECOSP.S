
	lea	pic+34,a0
	lea	dest+64,a1

	move.w	#15,d1

loop1:
	move.w	(a0),d0
	or.w	2(a0),d0
	or.w	4(a0),d0
	or.w	6(a0),d0
	move.w	d0,(a1)+
	addq.w	#2,a1
	lea	160(a0),a0
	dbf	d1,loop1

	illegal

	section	data

pic:	incbin	"a:\sprite.pi1"
	even

	section	bss

dest:
	ds.b	64*3


	lea	pic+34,a0
	lea	dest,a1
	move.w	#43-1,d0
loop1:
	move.w	#40-1,d1
loop2:
	move.l	(a0)+,(a1)+
	dbf	d1,loop2

	dbf	d0,loop1

	illegal

	section	data

pic:	incbin	"infopic.pi1"
	even

	section	bss

dest:	ds.b	160*43


	lea	dest,a0
	lea	dest+64,a1

	move.w	#15-1,d2
loop2:
	move.w	#16-1,d0
loop1:
	move.w	(a0),d1
	swap	d1
	move.w	2(a0),d1
	lsr.l	#1,d1
	move.w	d1,2(a1)
	swap	d1
	move.w	d1,(a1)

	lea	4(a0),a0
	lea	4(a1),a1

	dbf	d0,loop1

	dbf	d2,loop2

	illegal

	section	data

dest:
	incbin	"a:\maskspr.ter"
	ds.b	15*64
fin:	end
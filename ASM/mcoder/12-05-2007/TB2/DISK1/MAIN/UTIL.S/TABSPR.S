* transforme le colspr en juste le mask du spr


	lea	col,a0
	lea	dest,a1
	move.w	#15,d0
loop1:
	lea	4*16(a0),a0
	move.w	#(4*16)-1,d1
loop2:
	move.b	(a0)+,(a1)+
	dbf	d1,loop2
	lea	4*16(a0),a0
	dbf	d0,loop1

	illegal

	section	data

col:	incbin	"a:\spr.col"
	even

dest:
	ds.b	1024
fin:	end
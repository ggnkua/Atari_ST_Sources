
	lea	map,a0
	lea	fmap,a1
	lea	dest,a3
loop:
	move.w	(a0)+,d0
	move.b	d0,(a3)+
	cmp.l	a1,a0
	blt.s	loop

	illegal

	section	data

map:
	incbin	"map.map"
fmap:

dest:
	ds.b	10000
	end
	
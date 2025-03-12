	bsr make
	illegal

make	movem.l r,d0-7
	rept 27
	movem.l d0-7,(a0)
	lea 32(a0),a0
	endr
	movem.l r+32,d0-7
	rept 173
	movem.l d0-7,(a0)
	lea 32(a0),a0
	endr
	rts

r	incbin "credits.pal"
	even
ss	ds.b 3600
ee
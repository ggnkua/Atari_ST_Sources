
	lea	pic+34,a0
	lea	dest,a1

	move.w	#15,d0
l1:
	move.w	(a0),(a1)+
	move.w	#0,(a1)+
	lea	160(a0),a0
	dbf	d0,l1

	illegal

pic:	incbin	"a:\sprites\mask.pi1"
	even

dest:	ds.b	3200

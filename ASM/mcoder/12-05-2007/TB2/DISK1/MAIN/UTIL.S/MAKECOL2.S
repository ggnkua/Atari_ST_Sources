tata:
	lea	pic+34,a0
	lea	dest,a1

	move.w	#2,d1
.loop2:

	move.w	#15,d0
.loop1:
	move.w	(a0),(a1)+
	lea	160(a0),a0
	dbf	d0,.loop1

	lea	-160*16(a0),a0
	lea	8(a0),a0

	dbf	d1,.loop2


	illegal

	section	data

pic:	incbin	"a:\col2.pi1"
	even

	section	bss

dest:	ds.b	8000*2
	end
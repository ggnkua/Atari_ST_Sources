
	lea	image+34,a0
	lea	sprite,a1
	move.w	#14,d7	* 16 lignes de haut
loop:
	move.w	(a0),d0
	or.w	2(a0),d0
	or.w	4(a0),d0
	or.w	6(a0),d0
	not.w	d0
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	#-1,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	lea	160(a0),a0
	dbf	d7,loop
	
	illegal

	section	data

image:	incbin	"sprite.pi1"
	even

	section	bss

sprite:
	ds.b	360
fin:	end
	


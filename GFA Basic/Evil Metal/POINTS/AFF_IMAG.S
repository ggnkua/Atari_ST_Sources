
	move.w	#0,-(sp)		basse resolutoin fonction
	move.l	#-1,-(sp)		xbios 5
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp		jusque ici                 

	move.l	#$f8000,a0		adresse ecran dans a0
	lea	image,a1		adresse image dans a1
	lea	34(a1),a1		a1=a1+34
	
	move.w	#8000-1,d1		d1=nb fois
affimg
	move.l	(a1)+,(a0)+	aff
	dbf	d1,affimg		boucle de d1

	clr	-(sp)		quitte
	trap	#1

image	incbin	a:\code\*.pi1


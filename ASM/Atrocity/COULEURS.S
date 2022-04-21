; Retour de la couleur 1
; ZANAK / ATROCITY
	
	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.w	#$fff,$ffff8240.w
	
	clr	-(sp)
	trap	#1
	
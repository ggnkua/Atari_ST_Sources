; Rejouer des soundchips de type Megatyser en assembleur.
; Phillips Yoann pour Start Micro Magazine


	pea	$0	on passe en superviseur
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	jsr	zik	init la zik
	
	move.w	#$25,-(sp)	on fait un vsync 
	trap	#14	avant de mettre
	addq.l	#2,sp	la routine en 
	move.l	#zik+8,$4d2	VBL Queue
	
wait	cmp.b	#$39,$fffffc02.w	attend la pression
	bne	wait		de la touche space 
	
	bsr	zik+4	on arrete la zik
		
	clr.l	$4d2.w	on remet $4d2 a 0
	
	clr.w	-(sp)	on quit...
	trap	#1
	
zik	incbin	zikk.zik	la zik
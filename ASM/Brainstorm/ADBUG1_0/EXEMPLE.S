	;exemple.s exemple de programme Ö tracer pour Adebug.

	opt	d+

	TEXT
Start:
	move.w	#$1234,d0
	moveq	#2,d1
	;fläche vers le bas ''
	bsr	routin_1
	move.w	#$4321,d0
	moveq	#-2,d1
	;[Ctl_A]
	bsr	routin_1
	moveq	#-2,d0
	move.w	#$4321,d1
	;[W]atch
	bsr	routin_2
	;PTerm
	clr.w	-(sp)
	trap	#1

routin_1:
	nop
	dbf	d0,routin_1
	rts
routin_2:
	nop
	dbf	d1,routin_2
	rts
	END



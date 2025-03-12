*	Rwabs sector reader

	clr.w	-(a7)		;drive
	move.w	#309,-(a7)	;start sector
	move.w	#10,-(a7)	;number to read
	pea	buffer(pc)	;read address
	move.w	#2,-(a7)	;read and ignore disk change
	move.w	#4,-(a7)
	trap	#13
	add.l	#14,a7
	
	clr.w	-(a7)
	trap	#1
	
	
buffer	ds.l	1
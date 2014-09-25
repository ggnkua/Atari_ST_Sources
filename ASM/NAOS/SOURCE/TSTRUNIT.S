	opt x+
	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,UserStack

	move.l	#prg,d0
	move.l	#back,d1
	jmp	run_it
back	
	
	move.l	UserStack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1

UserStack	ds.l	1
Sav	ds.l	20

run_it	include	e:\final\source\run_it.s

prg	incbin	e:\final\unpacked\main.tos

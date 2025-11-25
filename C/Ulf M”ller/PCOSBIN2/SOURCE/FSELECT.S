
	.TEXT
	
	.globl Fselect
Fselect:
	move.l	a2, -(sp)
	
	move.l	8(sp), -(sp)
	move.l	a1, -(sp)
	move.l	a0, -(sp)
	move.w	d0, -(sp)
	move.w	#$11d, -(sp)
	trap	#1
	lea	16(sp), sp
	
	move.l (sp)+, a2
	rts
	
	.END


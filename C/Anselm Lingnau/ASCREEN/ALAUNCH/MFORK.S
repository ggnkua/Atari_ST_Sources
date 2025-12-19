* Binding f"ur die MultiGEM-Mfork-Routine

	globl Mfork
	text
Mfork:
	move.l	a2, -(sp)
	move.l	a1, -(sp)
	move.w	#$5aa7, -(sp)
	move.l	a0, -(sp)
	move.w	#112, -(sp)
	trap	#1
	add.l	#12, sp
	move.l	(sp)+, a2
	rts
	
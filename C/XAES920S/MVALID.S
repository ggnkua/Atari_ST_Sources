	globl	Mvalidate

	text
Mvalidate:
	pea 	(a2)
	move.l	d1,-(sp)
	move.l	a0,-(sp)
	move 	d0,-(sp)
	move	#0x141,-(sp)
	trap	#1
	lea 	12(sp),sp
	move.l	(sp)+,a2
	rts

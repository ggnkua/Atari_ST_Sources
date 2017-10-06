	.globl	Ssystem
Ssystem:
;	SYS_WLL GEMDOS,#$154,d0,d1,d2
	pea 	(a2)
	movem.l	d0-d2,-(sp)
	move	#$154,(sp)
	trap	#1
	lea 	12(sp),sp
	move.l	(sp)+,a2			
	rts

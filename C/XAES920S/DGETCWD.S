	globl	Dgetcwd

	text
Dgetcwd:
	pea 	(a2)
	move	d1,-(sp)
	move	d0,-(sp)
	pea 	(a0)
	move	#0x13b,-(sp)
	trap	#1
	lea 	10(sp),sp
	move.l	(sp)+,a2
	rts

* long Ssystem(short mode, long arg1, long arg2);

			globl	Ssystem

			MODULE	Ssystem

			move.l	a2,-(a7)

			move.l	d2,-(a7)
			move.l	d1,-(a7)
			move	d0,-(a7)
			move	#$154,-(a7)
			trap	#1
			lea		12(a7),a7

			move.l	(a7)+,a2
			rts

			ENDMOD

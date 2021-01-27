*	Created by TT-Digger v8
*	?? 32 57 1 352 204 109

*	TT-Digger v7

	globl setjmp, longjmp

MODULE setjmp

	movea.l	(a7)+,a1
	movem.l	d3-d7/a1-a7,(a0)
	moveq	#0,d0
	jmp	(a1)
ENDMOD

MODULE longjmp

	movem.l	(a0),d3-d7/a1-a7
	tst	d0
	bne.s	L1822
	moveq	#1,d0
L1822:
	jmp	(a1)
ENDMOD

	end


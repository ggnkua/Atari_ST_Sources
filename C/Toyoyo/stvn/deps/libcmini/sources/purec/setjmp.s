			GLOBL setjmp
			GLOBL longjmp

			MODULE setjmp
			movea.l   (a7)+,a1
			movem.l   d3-d7/a1-a7,(a0)
			moveq.l   #0,d0
			jmp       (a1)
			ENDMOD

			MODULE longjmp
			movem.l   (a0),d3-d7/a1-a7
			jmp       (a1)
			ENDMOD

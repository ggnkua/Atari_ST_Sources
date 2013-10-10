
extern setjmp(), longjmp();

static foo()
/*
	setjmp -- establish a jump buffer
*/
{
#ifndef LINT
	asm {
		setjmp:
			move.l  4(A7),A0
			clr.l 	D0
			move.l  (A7),A1
			movem.l	A1-A3/A6-A7/D4-D7, (A0)
			rts
/*
	longjmp -- restore control to a jump buffer
*/
		longjmp:
			move.l	4(A7),A0
			move	8(A7),D0
			bne		notscrewed
			moveq	#1,D0
		notscrewed:
			movem.l	(A0),A1-A3/A6-A7/D4-D7
			move.l 	A1,(A7)
			rts
	}
#endif
}

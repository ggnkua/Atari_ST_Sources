overlay "megamax"

_lmul(num1, num2)
long num1, num2;
{
    int   negate;
    long  result;

#ifndef LINT
    asm {
		move.l	D0, -(A7)
		clr.w	negate(A6)
		tst.l	num1(A6)
		bge	notneg1
		addq.w	#1, negate(A6)
		neg.l	num1(A6)
      notneg1:	tst.l	num2(A6)
		bge	notneg2
		addq.w	#1, negate(A6)
		neg.l	num2(A6)
      notneg2:
		move.w	num1+2(A6), D0
		mulu	num2+2(A6), D0
		move.l	D0, result(A6)
		move.w	num1(A6), D0
		mulu	num2+2(A6), D0
		add.w	D0, result(A6)
		move.w	num1+2(A6), D0
		mulu	num2(A6), D0
		add.w	D0, result(A6)
		andi.w	#1, negate(A6)
		beq	notneg3
		neg.l	result(A6)
      notneg3:
		move.l	(A7)+, D0
		move.l	result(A6), num2(A6)
		unlk	A6
		move.l	(A7)+, (A7)
		tst.l	4(A7)
		rts
    }
#endif
}

_ulmul(num1, num2)
long num1, num2;
{
    long  result;

#ifndef LINT
    asm {
		move.l	D0, -(A7)
		move.w	num1+2(A6), D0
		mulu	num2+2(A6), D0
		move.l	D0, result(A6)
		move.w	num1(A6), D0
		mulu	num2+2(A6), D0
		add.w	D0, result(A6)
		move.w	num1+2(A6), D0
		mulu	num2(A6), D0
		add.w	D0, result(A6)
		move.l	(A7)+, D0
		move.l	result(A6), num2(A6)
		unlk	A6
		move.l	(A7)+, (A7)
		tst.l	4(A7)
		rts
    }
#endif
}

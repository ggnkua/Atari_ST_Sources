overlay "megamax"

_ldiv(divisor, dividend)
long   dividend, divisor;
{
    int    negate;

#ifndef LINT
    asm {
	       movem.l D0-D3, -(A7)
	       move.l  divisor(A6), D2
	       bne     ok
	       divu    #0, D0		;divide by zero error
	       clr.l   D0		;for debugging lets return something
	       clr.l   D1
	       bra     dontneg
      ok:
	       move.l  dividend(A6), D1
	       clr.w   negate(A6)
	       tst.l   D1
	       bge     skip1
	       addq.w  #3, negate(A6)
	       neg.l   D1
      skip1:   tst.l   D2
	       bge     skip2
	       addq.w  #1, negate(A6)
	       neg.l   D2
      skip2:
	       moveq   #1, D3
      rotate:  cmp.l   D1, D2
	       bcc     endrot
	       asl.l   #1, D2
	       asl.l   #1, D3
	       bra     rotate
      endrot:
	       clr.l   D0
      dodiv:   cmp.l   D1, D2
	       bhi     nosub
	       or.l    D3, D0
	       sub.l   D2, D1
      nosub:
	       lsr.l   #1, D2
	       lsr.l   #1, D3
	       bcc     dodiv
	       cmpi.w  #3, negate(A6)
	       blt     posrem
	       neg.l   D1
      posrem:  lsr.w   negate(A6)
	       bcc     dontneg
	       neg.l   D0
      dontneg:
	       move.l  D0, divisor(A6)
	       move.l  D1, dividend(A6)
	       movem.l (A7)+, D0-D3
    }
#endif
}

_uldiv(divisor, dividend)
long   dividend, divisor;
{
#ifndef LINT
    asm {
	       movem.l D0-D3, -(A7)
	       move.l  divisor(A6), D2
	       bne     ok
	       divu    #0, D0	;divide by zero error
	       clr.l   D0		;for debugging lets return something
	       clr.l   D1
	       bra     dontneg
      ok:
	       move.l  dividend(A6), D1
	       clr.l   D0
	       moveq   #1, D3
      rotate:  cmp.l   D1, D2
	       bcc     dodiv
	       asl.l   #1, D2
	       bcc     keepgoing
	       roxr.l  #1, D2
	       bra     dodiv
      keepgoing:
	       asl.l   #1, D3
	       bra     rotate

      dodiv:   cmp.l   D1, D2
	       bhi     nosub
	       or.l    D3, D0
	       sub.l   D2, D1
      nosub:
	       lsr.l   #1, D2
	       lsr.l   #1, D3
	       bcc     dodiv
      dontneg:
	       move.l  D0, divisor(A6)
	       move.l  D1, dividend(A6)
	       movem.l (A7)+, D0-D3
    }
#endif
}

( Trig.Fth
  Includes the trigonometric functions: SIN, COS , and D>R (degrees to
  radians).
  
  SIN uses the Taylor expansion.  Drop terms at high values and use a 
  linear correction factor. 0-74 7th order,74-90 5th order with correction.
  
  Trying as much as possible to optimize for space. See how you can mix
  Forth and assembly language? That's because there's no difference between
  the two.)
  
  
DECIMAL

CODE D>R ( deg  -  rad*10000 ) 		( accurate up to 12304 degrees)
	MOVE.L	#31415927,-(A6)
	MOVE.L	#180,-(A6)
	*/
	MOVE.L	#500,-(A6)
	TST.L	4(A6)
	BGE.S	@1
	NEG.L	(A6)
@1	JSR	+
	MOVE.L	#1000,-(A6)
	JSR	/
	RTS
END-CODE


CODE TAYLOR  ( high-orderlimit-in-D5  -  sum-of-terms)
	MOVE.L	D6,-(A6) 		( first term for sin series)
	MOVEQ.L	#3,D4			( power for the 2nd term in 
					  odd series & loop ctr)
@1	MOVE.L	D6,-(A6)
	MOVE.L	D4,(A3)
	SUBQ.L	#1,(A3)			( (A3) holds the inner loop count)
@2	MOVE.L	D6,-(A6)
	MOVE.L	#10000,-(A6)
	JSR	*/
	SUBQ.L	#1,(A3)
	BNE.S	@2
	CMPI.L	#5,D4
	BEQ.S	@3
	NEG.L	(A6)
@3	MOVE.L	D4,-(A6)

	MOVEQ.L	#1,D0			( these five lines are a 16-bit 
					  factorial)
@4	MULU.W	2(A6),D0
	SUBQ.L	#1,(A6)
	BNE.S	@4
	MOVE.L	D0,(A6)
	
	/
	+
	ADDQ.L	#2,D4
	CMP.L	D5,D4
	BLT.S	@1
	RTS
END-CODE


( 5th order for 74-90 deg with a linear corr at end. +0% -.04%)

CODE DO2SIN 
	MOVEQ.L	#6,D5  			( because I want to go up till 
					  the 5th order term)
	JSR	TAYLOR
	SUB.L	#12915,D6
	MOVE.L	D6,-(A6)
	MOVE.L	#34,-(A6)
	MOVE.L	#2792,-(A6)
	JSR	*/
	MOVE.L	(A6)+,D0
	ADDI.L	#11,D0
	SUB.L	D0,(A6)
	RTS
END-CODE

CODE COS ( angle-in-rads*10000   -   cos(angle)*10000)  
	ADDI.L	#15708,(A6)	( Ho! Execution just falls thru to SIN)
END-CODE

CODE SIN ( angle-in-radians*10000   -   sin(angle)*10000   )
	MOVEM.L	D4-D7,-(A7)		( D7 is the sign flag)
	MOVE.L	#31416,-(A6)		( D6 holds theta)
	MOVEQ.L	#1,D7			( D5 holds the upper do limit)
	JSR	/MOD			( D4 holds the do index)
	TST.L	4(A6)			( for the main Taylor loop)
	BGE.S	@1
	NEG.L	D7
@1	ADDQ.L	#4,A6
	BTST	#0,-1(A6)		( see if even/odd mult of pi )
	BEQ.S	@2
	NEG.L	D7
@2	JSR	ABS
	MOVE.L	#15708,D4
	SUB.L	D4,(A6)
	JSR	ABS
	SUB.L	D4,(A6)
	JSR	ABS
	MOVE.L	(A6)+,D6
	CMP.L	#12915,D6		( theta >74 deg? )
	BGT.S	@3
					( for doing a series from 0-74 deg;
					  =>bad at 75 deg  )
	MOVEQ.L	#8,D5			( because I want to go up till the 
					  7th order term)
	JSR	TAYLOR
	BRA.S	@4
@3	JSR	DO2SIN
@4	MOVE.L	D7,-(A6)
	JSR	*
	MOVEM.L	(A7)+,D4-D7
	RTS
END-CODE


( Example:  45 D>R COS is 7071)
( SIN and COS take radian input where 0-90 degrees is 0-15708
  ten-thousandths of a radian. You can, of course redefine things to be:
  : SIN D>R SIN ; : COS D>R COS ; so that they take degrees)



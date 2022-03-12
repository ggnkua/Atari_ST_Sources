( GrafTrig.Fth
  This is a cryptic version of Trig.asm which should only be used with
  pixel graphics. Eight times faster but not accurate.
  Accuracy is about +/- 50 out of 10000. Alas, this made little difference
  in the graphics demo programs.)
    
  
DECIMAL

CODE D>R ( deg  -  rad*10000 )
	MOVE.L	(A6)+,D0	( deg)
	MULS.W	#175,D0		( * pi*10000/180)
	MOVE.L	D0,-(A6)	( = rad*10000)
	RTS
END-CODE

: TAYLOR5  { z -  sum-of-terms }
	z		( z is on stack)	

	z z * 
	10000 /
	z *
	60000 /
	negate			( z,-z^3/6 is on stack)


	z z *
	10000 /
	DUP *
	10000 /
	z *
	1200000
	/
				( z,-z^3/6,z^5/120  on stack)
	+ +			( answer is now on stack)
	;

CODE T/MOD ( angle 31416 - rem quot)
	( faster than real /MOD when angle not too big)
	MOVEQ.L	#1,D3		( sign flag)
	MOVE.L	(A6)+,D0
	MOVE.L	(A6)+,D1	( angle-remainder)
	BGE.S	@More
	NEG.L	D1
	NEG.L	D3
@More	MOVEQ.L	#0,D2		( quotient)
@loop	CMP.L	D0,D1
	BLT.S	@Done
	SUB.L	D0,D1
	ADDQ.L	#1,D2
	BRA.S	@loop
@Done	TST.L	D3
	BGT.S	@Exit
	NEG.L	D2
	NEG.L	D1
@Exit	MOVE.L	D1,-(A6)
	MOVE.L	D2,-(A6)
	RTS
END-CODE

CODE COS ( angle-in-rads*10000   -   cos(angle)*10000)  
	ADDI.L	#15708,(A6)	( Ho! Execution just falls thru to SIN)
END-CODE

CODE SIN ( angle-in-radians*10000   -   sin(angle)*10000   )
	MOVEM.L	D4-D7,-(A7)		( D7 is the sign flag)
	MOVE.L	#31416,-(A6)		( D6 holds theta)
	MOVEQ.L	#1,D7			( D5 holds the upper do limit)
	JSR	T/MOD			( D4 holds the do index)
	TST.L	4(A6)			( for the main Taylor loop)
	BGE.S	@1
	NEG.L	D7
@1	ADDQ.L	#4,A6
	BTST	#0,-1(A6)		( see if even/odd mult of pi )
	BEQ.S	@2
	NEG.L	D7
@2	JSR	ABS
	MOVE.L	#15708,D4	( pi/2)
	SUB.L	D4,(A6)
	JSR	ABS
	SUB.L	D4,(A6)
	JSR	ABS
	JSR	TAYLOR5	( do 5th order Taylor)
	TST.L	D7
	BGT.S	@5
	NEG.L	(A6)
@5	MOVEM.L	(A7)+,D4-D7
	RTS
END-CODE


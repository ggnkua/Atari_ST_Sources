
BINDEC
	CLR.L	STRIN2
	MOVE.L	#STRIN2,A0

bindec 	movem.l	d0-d1/a0,-(A7) 
	MOVE.B	#' ',D1
	TST.W	D0
	BPL.S	notneg
	MOVE.B	#"-",D1
	NEG.W	D0
notneg	MOVE.B	D1,(A0)+
	ADDA.L	#4,A0		this figure previously 5 but some
	MOVE.W	#4,D1	failure on display caused a change to 4...
binloop EXT.L	D0
	DIVS	#10,D0
	SWAP	D0
	MOVE.B	D0,-(A0)
	ADD.B	#"0",(A0)
	SWAP	D0
	DBRA	D1,binloop

	MOVE.L	#4,D4			;REMOVE ALL LEADING ZEROES
	LEA	STRIN2(PC),A3
CHK	CMP.B	#"0",(A3)
	BGT.S	OVER
	MOVE.B	#" ",(A3)	
	ADD.W	#1,A3
	DBF	D4,CHK
OVER	movem.l	(A7)+,d0-d1/a0
	RTS
STRING	DS.L	1
STRIN2	DS.L	1
	DC.B	0,0,0,0

;--------------- PTDecompacter ----------------

Decompact
	MOVE.B	(A0)+,D1
	CMP.B	#181,D1
	BEQ.s	DecodeIt
	MOVE.B	D1,(A1)+
decom2	SUBQ.L	#1,D0
	BNE.s	Decompact
	RTS

DecodeIt
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
dcdloop	MOVE.B	D2,(A1)+
	DBRA	D1,dcdloop
	SUBQ.L	#2,D0
	BRA.s	decom2


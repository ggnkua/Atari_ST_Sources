; Use this to make helpfile offsets
; load file at $40000, run and save from
; $40000-1024 to $40000+filelength

main	LEA	$40000,A0
mloop	CMP.B	#94,(A0)+
	BEQ	nose
	CMP.L	#$50000,A0
	BNE	mloop
	RTS

nose	MOVE.L	A0,A1
	SUB.L	#$40001,A1
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	SUB.B	#'0',D0
	CMP.B	#9,D0
	BLS	nose2
	SUBQ.B	#7,D0
nose2	LSL.B	#4,D0
	MOVE.B	(A0)+,D1
	SUB.B	#'0',D1
	CMP.B	#9,D1
	BLS	nose3
	SUBQ.B	#7,D1
nose3	OR.B	D1,D0
	LSL.W	#2,D0
	LEA	$40000-1024,A2
	ADD.L	D0,A2
	MOVE.L	A1,(A2)
	BRA	mloop


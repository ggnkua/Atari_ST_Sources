Relocate
; a1- Address of program to relocate !
	Movem.l	d0-a6,-(sp)
	LEA	$1C(A1),A3
	move.l	a3,a6
	MOVEM.L	-$1A(A3),D0-D3
	LEA	0(A3,D0.L),A0
	ADDA.L	D1,A0
	ADDA.L	D3,A0
	MOVE.L	A6,D0
	MOVE.L	(A0)+,D1
	BEQ.S	exit
	ADDA.L	D1,A3
	MOVEQ	#0,D1
L562F2	ADD.L	D0,(A3)
L562F4	MOVE.B	(A0)+,D1
	BEQ.S	exit
	CMPI.B	#1,D1
	BNE.S	L56304
	ADDA.W	#$FE,A3
	BRA.S	L562F4
L56304	ADDA.L	D1,A3
	BRA.S	L562F2
exit	Movem.l	(sp)+,d0-a6
	Rts

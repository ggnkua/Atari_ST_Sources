	LEA	exec(PC),A0
       	LEA	$3224E,A1
        MOVE.W	#22000/4-1,D0
RECOPIE:	MOVE.L	(A0)+,(A1)+
	DBF	D0,RECOPIE

	LEA	data(PC),A0
	LEA	$60000,A1
	MOVE.W	#$3E8,D0
L30E9A	MOVE.L	(A0)+,(A1)+
	DBF	D0,L30E9A

	CLR.L	D0
        jsr        $3525E
	
        move.l	#$3485A,$4DA
        rts

data:      incbin     soccer.b
exec:      incbin     soccer1.exe

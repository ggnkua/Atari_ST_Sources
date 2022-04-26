INITVU:
	MOVE.W	#160,VU1
	MOVE.W	#160,VU2
	MOVE.W	#160,VU3
	MOVE.W	#160,VU4
	RTS
*****************************
SHOWVU:
	JSR	CLRVU
	JSR	FIXVU
	JSR	PUTVU
	JSR	COPYVU
	RTS
*****************************
FIXVU:	CMP.W	#0,VOICE1
	BEQ	NO1
	MOVE.W	#160*30,VU1
	JMP	VUC2
NO1:	CMP.W	#160,VU1
	BEQ	VUC2
	SUB.W	#160,VU1
VUC2:	CMP.W	#0,VOICE2
	BEQ	NO2
	MOVE.W	#160*30,VU2
	JMP	VUC3
NO2:	CMP.W	#160,VU2
	BEQ	VUC3
	SUB.W	#160,VU2
VUC3:	CMP.W	#0,VOICE3
	BEQ	NO3
	MOVE.W	#160*30,VU3
	JMP	VUC4
NO3:	CMP.W	#160,VU3
	BEQ	VUC4
	SUB.W	#160,VU3
VUC4:	CMP.W	#0,VOICE4
	BEQ	NO4
	MOVE.W	#160*30,VU4
	JMP	RET1
NO4:	CMP.W	#160,VU4
	BEQ	RET1
	SUB.W	#160,VU4
RET1:	RTS	
*****************************
PUTVU:	MOVE.l	scrbase,A1
	ADD.l	#6+160*100+64,A1
	MOVE.l	A1,D2		;For comparision
	MOVE.W	VUDAT,D0
	SUB.W	VU1,A1
	
PUTLP1:	MOVE.W	D0,(A1)
	LEA	160(A1),A1
	CMP.l	D2,A1
	BNE	PUTLP1
	
	MOVE.l	scrbase,A1
	ADD.l	#6+160*100+64+8,A1
	MOVE.l	A1,D2		;For comparision
	MOVE.W	VUDAT,D0
	SUB.W	VU2,A1

PUTLP2:	MOVE.W	D0,(A1)
	LEA	160(A1),A1
	CMP.l	D2,A1
	BNE	PUTLP2

	MOVE.l	scrbase,A1
	ADD.l	#6+160*100+64+16,A1
	MOVE.l	A1,D2		;For comparision
	MOVE.W	VUDAT,D0
	SUB.W	VU3,A1
	
PUTLP3:	MOVE.W	D0,(A1)
	LEA	160(A1),A1
	CMP.l	D2,A1
	BNE	PUTLP3
	
	MOVE.l	scrbase,A1
	ADD.l	#6+160*100+64+24,A1
	MOVE.l	A1,D2		;For comparision
	MOVE.W	VUDAT,D0
	SUB.W	VU4,A1

PUTLP4:	MOVE.W	D0,(A1)
	LEA	160(A1),A1
	CMP.l	D2,A1
	BNE	PUTLP4
	RTS
*****************************
CLRVU:	MOVE.l	scrbase,A0
	ADD.l	#6+160*70+64,A0
	MOVE.W	#29,D0

CLRLP1:	CLR.W	(A0)
	CLR.W	8(A0)
	CLR.W	16(A0)
	CLR.W	24(A0)
	LEA	160(A0),A0
	DBRA	D0,CLRLP1
	RTS
*****************************
COPYVU:	MOVE.l	scrbase,A0
	ADD.l	#6+160*70+64,A0
	MOVE.W	#29,D0
	LEA	(A0),A1
	ADD.l	#60*160,A1
	
LP1:	MOVE.W	(A0),(A1)
	MOVE.W	8(A0),8(A1)
	MOVE.W	16(A0),16(A1)
	MOVE.W	24(A0),24(A1)
	LEA	160(A0),A0
	LEA	-160(A1),A1
	DBRA	D0,LP1
	RTS
*****************************

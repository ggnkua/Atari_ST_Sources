*** BOOT SECTEUR - CODED BY ZANAK ***
*** (C) 1994 , ATROCITY/ATLANTIDE ***

	OPT O+
	
	SECTION TEXT
	
SUPER	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
DEBUT	PEA	TEXT
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
WAIT	CMP.B	#$3B,$FFFFFC02.W	; F1
	BEQ	BOOT1
	CMP.B	#$3C,$FFFFFC02.W	; F2
	BEQ	BOOT2
	CMP.B	#$3D,$FFFFFC02.W	; F3
	BEQ	GREETS
	CMP.B	#$3E,$FFFFFC02.W	; F4
	BEQ	FIN
	BRA	WAIT
	
BOOT1	PEA	TEXT1
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
BOOT11	CMP.B	#$39,$FFFFFC02.W
	BNE	BOOT11
	CLR.B	$FFFFFC02.W
	
	MOVE.L	#FIN_BOOT1,D0
	SUB.L	#BOOTS1,D0
	CMP.W	#452,D0
	BGT	FIN
	MOVE.L	#FIN_BOOT1,FIN_BOOT
	MOVE.L	#BOOTS1,BOOT
	BRA	READ_BOOT

BOOT2	PEA	TEXT1
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
BOOT22	CMP.B	#$39+$80,$FFFFFC02.W
	BNE	BOOT22
	
	MOVE.L	#FIN_BOOT2,D0
	SUB.L	#BOOTS2,D0
	CMP.W	#452,D0
	BGT	FIN
	MOVE.L	#FIN_BOOT2,FIN_BOOT
	MOVE.L	#BOOTS2,BOOT
	BRA	READ_BOOT
	
GREETS	PEA	TEXT3
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
GREETS1	CMP.B	#$39+$80,$FFFFFC02.W
	BNE	GREETS1
	CLR.B	$FFFFFC02.W
	
	BRA	DEBUT
	
READ_BOOT	MOVE.W	#1,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#1,-(SP)
	MOVE.W	#0,-(SP)
	CLR.L	-(SP)
	MOVE.L	#BUFFER,-(SP)
	MOVE.W	#8,-(SP)
	TRAP	#14
	LEA	20(SP),SP
	
EXE_BOOT	LEA	BUFFER,A0
	MOVE.W	#$601C,(A0)
	MOVE.W	#'  ',2(A0)
	MOVE.L	#'ACY ',4(A0)
	
	MOVE.L	BOOT,A1
	MOVE.L	FIN_BOOT,A2
	LEA	30(A0),A3
SUITE	MOVE.B	(A1)+,(A3)+
	CMP.L	A1,A2
	BHI	SUITE
	
	CLR.W	510(A0)
	LEA	BUFFER,A1
	MOVE.W	#$FF,D7
	MOVEQ.L	#0,D0
	
CHECK_SUM	ADD.W	(A1)+,D0
	DBF	D7,CHECK_SUM
	
	MOVE.W	#$1234,D1
	SUB.W	D0,D1
	MOVE.W	D1,510(A0)
	
WRITE_BOOT	MOVE.W	#1,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#1,-(SP)
	MOVE.W	#0,-(SP)
	CLR.L	-(SP)
	MOVE.L	#BUFFER,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#14
	LEA	20(SP),SP

TEXTE2	PEA	TEXT2
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	BRA	DEBUT
	
FIN	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.W	-(SP)
	TRAP	#1
	
	SECTION DATA
	
BOOTS1	INCLUDE	F:\SOURCES.ZAK\BOOT1.S
FIN_BOOT1
	EVEN
	
BOOTS2	INCLUDE	F:\SOURCES.ZAK\BOOT2.S
FIN_BOOT2
	EVEN

TEXT	DC.B	27,'E',10,13
	DC.B	'*****************************************',10,13
	DC.B	'*** ATROCITY / ATLANTIDE BOOT SECTEUR ***',10,13
	DC.B	'***   CODED BY ZANAK - JANVIER 1995   ***',10,13
	DC.B	'*****************************************',10,13
	DC.B	'***                                   ***',10,13
	DC.B	'***     F1 - BOOT SECTEUR 1           ***',10,13
	DC.B	'***    *** ATROCITY / ATLANTIDE ***   ***',10,13
	DC.B	'***                                   ***',10,13
	DC.B	'***     F2 - BOOT SECTEUR 2           ***',10,13              
	DC.B	'***     *** ATLANTIDE Software ***    ***',10,13
	DC.B	'***                                   ***',10,13  
	DC.B	'***     F3 - CREDITS & GREETS         ***',10,13
	DC.B	'***                                   ***',10,13
	DC.B	'***     F4 - QUIT                     ***',10,13
	DC.B	'***                                   ***',10,13 
	DC.B	'*****************************************',10,13,0
TEXT1	DC.B	'***     -> INSERT DISK IN DRIVE A     ***',10,13
	DC.B	'***          & SPACE TO BEGIN         ***',10,13
	DC.B	'*****************************************',10,13,0
	
TEXT2	DC.B	'BOOT OK !!',10,13,10,13,0

TEXT3	DC.B	27,'E','*** ATROCITY / ATLANTIDE BOOT SECTEUR ***',10,13,10,13
	DC.B	'SGT SLAYER       ZANAK',10,13
	DC.B	'PHILOU           JJ',10,13
	DC.B	'TT-AXEL S        SQUAT          ...',10,13,0
	
	SECTION BSS
	
BUFFER	DS.B	512
BOOT	DS.L	1
FIN_BOOT	DS.L	1	

	

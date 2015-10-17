******************
*PRINTING ROUTINE*
******************

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	BSR	INITS
	BSR	CLS
	BSR	PALETTE	
	clr.l	d2
	clr.l	d0
	clr.l	d1
	clr.l	d3
	MOVE.L	XB,A2
	ADD.L	#5120+2560,A2
	JMP	BOUCLE

********************************BOUCLE PRINCIPALE******************
BOUCLE:
	MOVE.L	D3,-(SP)
	move.l	$466.w,d3		; vsync
SYNC:	cmp.l	$466.w,d3
	beq.s	SYNC
	MOVE.L	(SP)+,D3
	CMPI.W	#112,D3
	BEQ.S	SUITE
	BSR	PRINTING
	ADDQ.W	#1,D3
SUITE	cmpi.b	#57,$ffffc02
	bne.s	BOUCLE
	JMP	SORTIE
*********************ROUTINE POUR LE PRINTING*************
PRINTING
	LEA	FONTE+34,A0
	LEA	TEXTE+2,A1
	ADD.W	D2,A1
	CMPI.B	#16,D1
	BNE.S	NO_CLEAR
	CLR.B	D1
	SUB	#16*8,A2
	ADD.W	#2560,A2	
NO_CLEAR
	ADD.W	(A1),A0
	BSR	FONT
	ADDQ.B	#1,D1
	ADDQ.W	#8,A2
	ADDQ.W	#2,D2
*	MOVE.W	#7,-(SP)
*	TRAP	#1
*	ADDQ.L	#2,SP
	RTS	
	
************************INITS**************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,XB
	
	MOVE.W	#0,-(SP)	
	MOVE.L	XB,-(SP)
	MOVE.L	XB,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	RTS
*******************************SOUS ROUTINES***********************
FONT:
	MOVE.L	(A0),(A2)
	MOVE.L	4(A0),4(A2)
	MOVE.L	160(A0),160(A2)
	MOVE.L	164(A0),164(A2)
	MOVE.L	320(A0),320(A2)
	MOVE.L	324(A0),324(A2)
	MOVE.L	480(A0),480(A2)
	MOVE.L	484(A0),484(A2)
	MOVE.L	640(A0),640(A2)
	MOVE.L	644(A0),644(A2)
	MOVE.L	800(A0),800(A2)
	MOVE.L	804(A0),804(A2)
	MOVE.L	960(A0),960(A2)
	MOVE.L	964(A0),964(A2)
	MOVE.L	1120(A0),1120(A2)
	MOVE.L	1124(A0),1124(A2)
	MOVE.L	1280(A0),1280(A2)
	MOVE.L	1284(A0),1284(A2)
	MOVE.L	1440(A0),1440(A2)
	MOVE.L	1444(A0),1444(A2)
	MOVE.L	1600(A0),1600(A2)
	MOVE.L	1604(A0),1604(A2)
	MOVE.L	1760(A0),1760(A2)
	MOVE.L	1764(A0),1764(A2)
	MOVE.L	1920(A0),1920(A2)
	MOVE.L	1924(A0),1924(A2)
	MOVE.L	2080(A0),2080(A2)
	MOVE.L	2084(A0),2084(A2)
	MOVE.L	2240(A0),2240(A2)
	MOVE.L	2244(A0),2244(A2)
	RTS

CLS:
	MOVE.L	XB,A2	
	MOVE.L	#7999,D0
SCREEN	
	CLR.L	(A2)+
	DBF	D0,SCREEN
	RTS

PALETTE
	PEA	FONTE+2		adresse image 
	MOVE.W	#6,-(SP)   mise en place par Xbios(6)
	TRAP	#14
	ADDQ.L	#6,SP
	RTS	
****************FIN********************************************
SORTIE
	bsr	cls
	MOVE.W	#1,-(SP)
	MOVE.L	XB,-(SP)
	MOVE.L	XB,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP	
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	CLR.W	-(SP)
	TRAP	#1
*************************************************************
	SECTION DATA

TEXTE:	INCBIN	C:\UTILS\GEN_ASM\FALCBOBS.S\TEXT.INL
FONTE:	INCBIN	C:\UTILS\GEN_ASM\FALCBOBS.S\FNT.INL
	
XB:	DC.L	0
PHYSIC:	DC.L	0
LOGIC:	DC.L	0
REZ:	DC.W	0
MODE:	DC.W	0
	END
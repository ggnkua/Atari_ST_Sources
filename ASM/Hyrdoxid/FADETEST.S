	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	
	MOVE.L	$44E,A0
	MOVE.W	#0,-(SP)
	MOVE.L	A0,-(SP)
	MOVE.L	A0,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	PEA	CLR
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	MOVE.L	$44E,A0
	LEA	LOGO+34,A1
	MOVE.W	#2000,D1	

AFF_IMG	
	MOVE.L	(A1)+,(A0)+
	DBF	D1,AFF_IMG
	PEA	LOGO
	MOVE.W	#0,-(SP)
	BSR	TRUE_FADE_OUT_NEW
	ADDQ.L	#6,SP
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	PEA	LOGO
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT_NEW
	ADDQ.L	#6,SP

	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

VBL	MOVE.L	D3,-(SP)
	move.l	$466.w,d3
SYNC	cmp.l	$466.w,d3
	beq.s	SYNC
	MOVE.L	(SP)+,D3
	RTS
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\RVB_FADE.S"
	SECTION	DATA
LOGO	INCBIN	"E:\GRAPHS\HYDROXID.PI1\SAYA\1123.PI1"
	SECTION BSS
CLR	DS.L	32
	END
				 	  																																																					 	 															?																					 	 				 																																					 	 
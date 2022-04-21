**************************************
*** MULTI-CONVERT - Coded By ZANAK ***
***  (C) NOVEMBRE 1994 , ATROCITY  ***
**************************************

	OPT	O+
	
	SECTION TEXT	
	
	INCLUDE	"D:\TOTF\SYSTEME.S"

***************************************
	
SUPER	PEA	0.W
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP

FSETDATA	PEA	DISK_TRAN_ADR
	MOVE.W	#$1A,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
TEXT	PEA	TEXTE(PC)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

WAIT_KEY	MOVE.W	#2,-(SP)
	MOVE.W	#1,-(SP)
	TRAP	#13
	ADDQ.L	#4,SP
	TST.W	D0
	BEQ	WAIT_KEY
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	SWAP	D0
	CMP.W	#$3B,D0	; F1 ASCII->ADISP
	BEQ.S	ASC_GFA
	CMP.W	#$3C,D0	; F2 HP 48->IFF
	BEQ.S	GFA_ASC
	CMP.W	#$3D,D0	; F3 HELP
	BEQ.S	CREDITS
	CMP.W	#$3E,D0	; F4 QUIT
	BEQ.S	BYE
	BRA	WAIT_KEY

CREDITS	PEA	CREDIT(PC)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	BRA	TEXT

ASC_GFA	BSR.S	LOAD_DATA
	LEA	FILE_ASC,A0
	LEA	FILE_GFA,A1
	MOVE.L	SIZE_FILE,D1
	MOVE.L	#15000,D1
ENCORE	MOVE.B	(A0)+,D0
	CMP.B	#13,D0
	BEQ.S	DELETE
	CMP.W	#10,D0
	BEQ.S	DELETE
	MOVE.B	D0,(A1)+
	SUBQ.L	#1,D1
	CMP	#0,D1
	BNE	ENCORE
	BSR.S	SAVE_DATA
	BRA	WAIT_KEY
DELETE	LEA	1(A0),A0
	BRA	ENCORE

GFA_ASC	BRA	WAIT_KEY

ASC_HP	BRA	WAIT_KEY

	
***************************************

BYE	MOVE.W	#32,-(SP)
	TRAP	#1
 	ADDQ.L	#6,SP

	CLR	-(SP)
	TRAP	#1

******* SUB ROUTS *********************
LOAD_DATA
OPEN	MOVE.W	#0,-(SP)
	MOVE.L	#FILENAME_ASC,-(SP)
	MOVE.W	#$3D,-(SP)
	TRAP	#1
	ADDA.L	#8,SP
	MOVE.W	D0,HANDLE

	MOVE.L	DISK_TRAN_ADR+26,D0
	MOVE.L	D0,SIZE_FILE
	
READ	MOVE.L	#FILE_ASC,-(SP)
	MOVE.L	SIZE_FILE,-(SP)
	MOVE.W	HANDLE,-(SP)
	MOVE.W	#$3F,-(SP)
	TRAP	#1
	ADDA.L	#12,SP
	
CLOSE_A	MOVE.W	HANDLE,-(SP)
	MOVE.W	#$3E,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	RTS

SAVE_DATA	
CREATE	MOVE.W	#0,-(SP)
	MOVE.L	#FILENAME_GFA,-(SP)
	MOVE.W	#$3C,-(SP)
	TRAP	#1
	ADDA.L	#8,SP
	
WRITE	MOVE.L	#FILE_GFA,-(SP)
	MOVE.L	SIZE_FILE,-(SP)
	MOVE.W	HANDLE,-(SP)
	MOVE.W	#$40,-(SP)
	TRAP	#1
	ADDA.L	#$C,SP
	
CLOSE_B	MOVE.W	HANDLE,-(SP)
	MOVE.W	#$3E,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	RTS

***************************************

	SECTION DATA

TEXTE	DC.B	27,"E",10,13,10,13,10,13
	DC.B	"**********************************",10,13
	DC.B	"* HPLINK ASCII  Convertisseur    *",10,13
	DC.B	"*    (C) NOV 94 , ZANAK/ATROCITY *",10,13
	DC.B	"**********************************",10,13
	DC.B	"*   F1  -  ASCII ST -> ADISP     *",10,13
	DC.B	"*   F2  -  HP 48    -> IFF !!    *",10,13
	DC.B	"*   F3  -  CEKOIDON ??           *",10,13
	DC.B	"*   F4  -  QUIT                  *",10,13
	DC.B	"**********************************",10,13,0
	EVEN

CREDIT	DC.B	27,"E"
	DC.B	"MULTI-CONVERT EST UN PETIT UTILITAIRE DE CONVERTION",10,13
	DC.B	"DE FICHIERS ASCII HP/ST : 	                ",10,13,10,13
	DC.B	"  - ASCII ST -> ADISP : TRANSFORME LES FICHIERS    ",10,13
	DC.B	"    ASCII ST AU FORMAT ASCII HP (POUR LES VIEWER)  ",10,13
	DC.B	"    COMME ADISP PAR EXEMPLE (BY DBV !!) CECI EN    ",10,13
	DC.B	"    ENLEVANT LES CARACTERES CR DE RETOUR .         ",10,13,10,13
	DC.B	"  - HP48 -> IFF : TRANSFORME LES FICHIERS ASCII HP ",10,13
	DC.B	"    EN ENLEVANT LE HPHP48-x .                      ",10,13,10,13
	DC.B	"             HP LINK 1994                          ",0 	
	EVEN
	
FILENAME_ASC	DC.B	"E:\ASC.ZAK",0
FILENAME_GFA	DC.B	"E:\GFA.ZAK",0
	
	SECTION BSS

FILE_ASC	DS.W	50000
FILE_GFA	DS.W	50000
PILE_END	DS.L	512
PILE	DS.L	1
HANDLE	DS.W	1
SIZE_FILE	DS.L	1
DISK_TRAN_ADR	DS.B	44
	END
	
	

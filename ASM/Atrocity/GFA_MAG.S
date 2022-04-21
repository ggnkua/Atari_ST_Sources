*** GFA Mag Convertisseur ***
*** By ZANAK/ATROCITY  94 ***

	OPT	O+

	SECTION TEXT

SUPER	PEA	0.W
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP

	BSR	FSETDTA
	MOVE.W	#$19,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	ADD.B	#'A',D0
	MOVE.B	D0,PATH

	CLR	-(SP)
	PEA	PATH+1(PC)
	MOVE.W	#$47,-(SP)
	TRAP	#1
	ADDQ.L	#8,SP
	
	LEA	PATH+1(PC),A0
	MOVE.B	#':',(A0)+
ENDPATH	TST.B	(A0)+
	BNE.S	ENDPATH
	
	MOVE.B	#'\',-1(A0)
	MOVE.B	#'*',(A0)+
	MOVE.B	#'.',(A0)+
	MOVE.B	#'*',(A0)+
	CLR.B	(A0)+
		
TEXT	PEA	TEXTE(PC)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	BRA	BUF_CLAVIER
	
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
	CMP.W	#$3B,D0	; F1
	BEQ.S	ASC_GFA
	CMP.W	#$3C,D0	; F2
	BEQ.S	GFA_ASC
	CMP.W	#$3D,D0	; F3
	BEQ.S	ASC_HP
	CMP.W	#$3E,D0	; F4
	BEQ.S	CREDITS
	CMP.W	#$3F,D0	; F5
	BEQ	BYE
	BRA	WAIT_KEY
	
ASC_GFA	BSR.S	FILESELECT
	BSR	LOADFILE
;	LEA	FICHIER,A0
	LEA	FICHIER_2(PC),A1
	MOVE.L	LENGHTFILE(PC),D1
ENCORE	MOVE.B	(A0)+,D0
	CMP.B	#13,D0
	BEQ	DELETE
	CMP.W	#10,D0
	BEQ	DELETE
	MOVE.B	D0,(A1)+
	SUBQ.L	#1,D1
	CMP	#0,D1
	BNE	ENCORE
	BRA	WAIT_KEY
	
CREDITS	PEA	CREDIT(PC)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	BRA	TEXT
	
GFA_ASC	BRA	WAIT_KEY

ASC_HP	BRA	WAIT_KEY

FILESELECT	DC.W	$A009
	MOVE.L	#PARAM,D1
	MOVE.L	#200,D0
	TRAP	#2
	DC.W	$A00A
	TST	INT_OUT+2
	BEQ.S	CANCEL
	LEA	PATH(PC),A0
	LEA	PATHNAME(PC),A1
COPYPATH	MOVE.B	(A0)+,(A1)+
	BNE.S	COPYPATH
NOSHLASH	CMP.B	#'\',-(A1)
	BNE.S	NOSHLASH
	ADDQ.L	#1,A1
	LEA	FILENAME(PC),A0
COPYNAME	MOVE.B	(A0)+,(A1)+
	BNE.S	COPYNAME
	MOVEQ	#-1,D0
CANCEL	RTS

LOADFILE	CLR	-(SP)
	PEA	PATHNAME(PC)
	MOVE.W	#$4E,-(SP)
	TRAP	#1
	ADDQ.L	#8,SP
	TST	D0
	BMI.S	LOADERROR

	LEA	FILE(PC),A0
	MOVE.L	DTABUFFER+26(PC),D0
	MOVE.L	D0,LENGHTFILE
	ADD.L	A0,D0
	MOVE.L	D0,ADRFILE2		; Adresse du deuxiŠme fichier

	CLR	-(SP)
	PEA	PATHNAME(PC)
	MOVE.W	#$3D,-(SP)
	TRAP	#1		; fopen
	ADDQ.L	#8,SP
	MOVE.W	D0,FILEHANDLE

	PEA	FILE(PC)
	MOVE.L	LENGHTFILE(PC),-(SP)
	MOVE.W	D0,-(SP)
	MOVE.W	#$3F,-(SP)
	TRAP	#1		; fread
	LEA	12(SP),SP

	MOVE.W	FILEHANDLE(PC),-(SP)
	MOVE.W	#$3E,-(SP)
	TRAP	#1		; fclose
	ADDQ.L	#4,SP

	MOVEQ	#0,D0
LOADERROR	RTS

BUF_CLAVIER	MOVE.W	#2,-(SP)
	MOVE.W	#1,-(SP)
	TRAP	#13
	ADDQ.L	#4,SP
	TST.W	D0
	BEQ	WAIT_KEY
	MOVE.W	#2,-(SP)
	MOVE.W	#2,-(SP)
	TRAP	#13
	ADDQ.L	#4,SP
	TST.W	D0
	BRA	BUF_CLAVIER
	
BYE	MOVE.W	#32,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR	-(SP)
	TRAP	#1
			
DELETE	LEA	1(A0),A0
	BRA	ENCORE
	
FSETDTA	PEA	DTABUFFER(PC)
	MOVE.W	#$1A,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	RTS

	SECTION DATA
	
CREDIT	DC.B	27,"E"
	DC.B	"  ATROCITY MEMBERS :                        ",10,13
	DC.B	"    - SGT SLAYER           - DR SKULL      ",10,13
	DC.B	"    - ACRYLIC              - ZANAK         ",10,13
	DC.B	"    - ARTEK                - BLACK BRAIN   ",10,13
	DC.B	"    - FLASHBACK            - GOR           ",10,13
	DC.B	"    - EXXOS                                ",10,13,10,13                
	DC.B	"  HI TO :                                    ",10,13
	DC.B	"  ATLANTIDE, EKO, SUPREMACY, EUROSWAP, DUNE, ",10,13
	DC.B	"  ETC ...  MERDE TU FINIRAS WILLIAM !!!     ",0
	EVEN
	
TEXTE	DC.B	27,"E"
	DC.B	"       ********************************",10,13
	DC.B	"       * ATROCITY ASCII Convertisseur *",10,13
	DC.B	"       * (C) OCT 94 , ZANAK/ATROCITY  *",10,13
	DC.B	"       ********************************",10,13
	DC.B	"       *   F1  -  ASCII   -> GFA MAG  *",10,13
	DC.B	"       *   F2  -  GFA MAG -> ASCII    *",10,13
	DC.B	"       *   F3  -  ASCII   -> HP 48    *",10,13
	DC.B	"       ********************************",10,13
	DC.B	"       *   F4  -  CREDITS             *",10,13
	DC.B	"       *   F5  -  QUIT                *",10,13
	DC.B	"       ********************************",0
	EVEN

PARAM	DC.L	CONTROL,GLOBAL,INT_IN,INT_OUT,ADR_IN,ADR_OUT
CONTROL	DC.W	90,0,2,2,0
GLOBAL	DC.W	0
INT_IN	DC.W	0
ADR_IN	DC.L	PATH,FILENAME

	SECTION BSS
	
FICHIER_2	DS.B	10000
KEYBOARD	DS.W	1
FILEHANDLE	DS.W	1
PATH	DS.B	80
FILENAME	DS.B	14
PATHNAME	DS.B	80
INT_OUT	DS.W	2
ADR_OUT	DS.L	1
DTABUFFER	DS.B	44
LENGHTFILE	DS.L	1
ADRFILE2	DS.L	1
FILE	DS.B	50000

	END
	
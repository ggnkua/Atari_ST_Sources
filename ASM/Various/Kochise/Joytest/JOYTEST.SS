; /// > JoyPAD DRIVER Test - KOSS 2000 < ///
;

; *** Equates Zone ************************************************************

	; *** Commands for Assembly

	OPT	p=68030/68882
	comment	HEAD=7	; FastLoad

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////	
	
	movea.l	(4,SP),A6	; Adresse de la BASEPAGE
	move.l	($C,A6),D0	; Taille du SEGMENT TEXT
	add.l	($14,A6),D0	; Additionne la taille du SEGMENT DATA … D0
	add.l	($1C,A6),D0	; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0	; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0	; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1	; Copie D0 dans D1 (Taille … r‚server)
	move.l	D0,D7
	add.l	A6,D1	; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1	; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	subq.l	#8,D1	; Garde de la place pour l'adresse de la BASEPAGE
	move.l	(4,SP),D2	; Sauvegarde l'adresse de la BASEPAGE
	movea.l	D1,SP	; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D2,(4,SP)	; R‚installe l'adresse de la BASEPAGE
	move.l	D0,-(SP)	; EmPILE la taille … r‚server
	move.l	A6,-(SP)	; EmPILE l'adresse du programme
	clr.w	-(SP)	; R‚serv‚
	move.w	#$4A,-(SP)	; - M_SHRINK -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	move.l	#JoyPAD_A_Table,JOYPAD_A_ADDR_TABLE
	move.l	#JoyPAD_B_Table,JOYPAD_B_ADDR_TABLE
	
	move.l	#JFCE,JOYPAD_OldJPadRoutine

Loopa	clr.l	-(SP)
	move.w	#$20,-(SP)	; - SUPER -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	move.l	D0,OldSP
	
	pea	Return

	pea	CLS
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JOYPAD_ConvertRoutine

Return	move.l	OldSP,-(SP)
	move.w	#$20,-(SP)	; - SUPER -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP

	move.w	#2,-(SP)
	move.w	#1,-(SP)	; - BCONSTAT -
	TRAP	#13	; *** BIOS ***
	addq.l	#4,SP
	
	tst.w	D0
	BEQ	Loopa

	move.w	D0,-(SP)
	move.w	#$4C,-(SP)	; - P_TERM -
	trap	#1	; *** GEMDOS ***

JoyADir	move.l	D0,D7

	pea	JADir
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JDir

JoyAFire	move.l	D0,D7

	pea	JAFire
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JFire

JoyASpecial	move.l	D0,D7

	pea	JASpecial
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JSpecial

JoyAPause	move.l	D0,D7

	pea	JAPause
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JPause
	
JoyAOption	move.l	D0,D7

	pea	JAOption
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JOption

JoyAReset	move.l	D0,D7

	pea	JAReset
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JReset

JoyAMusic	move.l	D0,D7

	pea	JAMusic
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JMusic

JoyANum	move.l	D0,D7

	pea	JANum
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JNum

JoyBDir	move.l	D0,D7

	pea	JBDir
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JDir

JoyBFire	move.l	D0,D7

	pea	JBFire
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JFire

JoyBSpecial	move.l	D0,D7

	pea	JBSpecial
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JSpecial

JoyBPause	move.l	D0,D7

	pea	JBPause
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JPause
	
JoyBOption	move.l	D0,D7

	pea	JBOption
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JOption

JoyBReset	move.l	D0,D7

	pea	JBReset
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JReset

JoyBMusic	move.l	D0,D7

	pea	JBMusic
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JMusic

JoyBNum	move.l	D0,D7

	pea	JBNum
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JNum

	

	RTS


JDir	btst.l	#0,D7
	BEQ	JDLow
		
	pea	JHi
	BSR	PRINT
	addq.l	#4,SP

	RTS
	
JDLow	btst.l	#1,D7
	BEQ	JDLeft
	
	pea	JLow
	BSR	PRINT
	addq.l	#4,SP
	
	RTS
	
JDLeft	btst.l	#2,D7
	BEQ	JDRight
	
	pea	JLeft
	BSR	PRINT
	addq.l	#4,SP
	
	RTS
	
JDRight	btst.l	#3,D7
	BEQ	JDEnd
	
	pea	JRight
	BSR	PRINT
	addq.l	#4,SP
	
JDEnd	RTS

JFire	btst.l	#0,D7
	BEQ	JFEA
	
	pea	JFireA
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JFCB
	
JFEA	pea	JFireE
	BSR	PRINT
	addq.l	#4,SP
	
JFCB	btst.l	#1,D7
	BEQ	JFEB
	
	pea	JFireB
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JFCC
	
JFEB	pea	JFireE
	BSR	PRINT
	addq.l	#4,SP
	
JFCC	btst.l	#2,D7
	BEQ	JFEC
	
	pea	JFireC
	BSR	PRINT
	addq.l	#4,SP
	
	BRA	JFCE
	
JFEC	pea	JFireE
	BSR	PRINT
	addq.l	#4,SP
	
JFCE	RTS

JSpecial	pea	JSpec
	BSR	PRINT
	addq.l	#4,SP
	
	RTS

JPause	pea	JPauz
	BSR	PRINT
	addq.l	#4,SP
	
	RTS

JOption	pea	JOpt
	BSR	PRINT
	addq.l	#4,SP
	
	RTS

JReset	pea	JRst
	BSR	PRINT
	addq.l	#4,SP
	
	RTS

JMusic	pea	JMus
	BSR	PRINT
	addq.l	#4,SP
	
	RTS

JNum	move.l	#11,D0
	lea	JNb,A0

JNLoop	btst.l	D0,D7

	BEQ	JN0
	
	move.b	#"1",(A0)+
	
	BRA	JNNext
	
JN0	move.b	#"0",(A0)+

JNNext	DBF	D0,JNLoop

	pea	JNb
	BSR	PRINT
	addq.l	#4,SP
	
	RTS

PRINT	move.l	(4,SP),-(SP)
	move.w	#9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	RTS

	include	JOYPADS.SS

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////	
	
CLS	dc.b	27,"E",0

JADir	dc.b	27,"Y",32+1,32,0
JAFire	dc.b	27,"Y",32+2,32,0
JASpecial	dc.b	27,"Y",32+3,32,0
JAPause	dc.b	27,"Y",32+4,32,0
JAOption	dc.b	27,"Y",32+5,32,0
JAReset	dc.b	27,"Y",32+6,32,0
JAMusic	dc.b	27,"Y",32+7,32,0
JANum	dc.b	27,"Y",32+8,32,0

JBDir	dc.b	27,"Y",32+1,32+20,0
JBFire	dc.b	27,"Y",32+2,32+20,0
JBSpecial	dc.b	27,"Y",32+3,32+20,0
JBPause	dc.b	27,"Y",32+4,32+20,0
JBOption	dc.b	27,"Y",32+5,32+20,0
JBReset	dc.b	27,"Y",32+6,32+20,0
JBMusic	dc.b	27,"Y",32+7,32+20,0
JBNum	dc.b	27,"Y",32+8,32+20,0

JHi	dc.b	"Dir:HI",0
JLow	dc.b	"Dir:LOW",0
JLeft	dc.b	"Dir:LEFT",0
JRight	dc.b	"Dir:RIGHT",0

JFireA	dc.b	"FireA ",0
JFireB	dc.b	"FireB ",0
JFireC	dc.b	"FireC ",0
JFireE	dc.b	"      ",0

JSpec	dc.b	"Special",0

JPauz	dc.b	"PAUSE",0

JOpt	dc.b	"OPTION",0

JRst	dc.b	"RESET",0

JMus	dc.b	"MUSIC",0

JNb	ds.b	13
	
OldSP	ds.l	1
	
JoyPAD_A_Table	dc.l	JoyADir
	dc.l	JoyAFire
	dc.l	JoyASpecial
	dc.l	JoyAPause
	dc.l	JoyAOption
	dc.l	JoyAReset
	dc.l	JoyAMusic
	dc.l	JoyANum

JoyPAD_B_Table	dc.l	JoyBDir
	dc.l	JoyBFire
	dc.l	JoyBSpecial
	dc.l	JoyBPause
	dc.l	JoyBOption
	dc.l	JoyBReset
	dc.l	JoyBMusic
	dc.l	JoyBNum

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////	

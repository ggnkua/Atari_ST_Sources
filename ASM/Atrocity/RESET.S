**********************************************************************
************** ATROCITY RESET DEMO ST ********************************
************** CODED BY ZANAK (C)1994 ********************************
**********************************************************************

	OPT	O+

	SECTION TEXT
	
**********************************************************************
************** MEMOIRE - ECRANS **************************************
**********************************************************************

	MOVE.L	4(SP),A0
	
	MOVE.L	12(A0),D0	; TAILLE SECTION TEXT	
	ADD.L	20(A0),D0	; TAILLE SECTION DATA
	ADD.L	28(A0),D0	; TAILLE SECTION BSS
	ADDI.L	#256,D0		; TAILLE BASEPAGE
	ADDI.L	#256,D0		; TAILLE ERROR

	MOVE.L	D0,-(SP)	; TAILLE BLOCK ENTIER
	MOVE.L	A0,-(SP)	; ADRESSE BLOCK
	MOVE.W	#0,-(SP)
	MOVE.W	#$4A,-(SP)	; MSHRINK
	TRAP	#1		; CALL GEMDOS
	ADD.L	#12,SP
	
	TST.L	D0		; TESTE SI ERREUR ...
	BMI	BYE		; SI OUI FIN SINON
				; ON CONTINUE ...

**********************************************************************

	CLR.L	-(SP)

	MOVE.W	#$20,-(SP)	; SUPERVISEUR
	TRAP	#1
	ADDQ.L	#6,SP

**********************************************************************
	
	MOVE.L	D0,-(SP)	; OLD REZ 
	
**********************************************************************
	
	MOVE.W	#2,-(SP)	; OU EST L'ECRAN PHYSIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PSCR		; IL EST LA ...
	
	MOVE.W	#3,-(SP)	; OU EST L'ECRAN LOGIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LSCR		; IL EST LA AUSSI ...
	
	MOVE.W	#-1,-(SP)	; ET LA RESOLUTION ?
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	MOVE.W	D0,REZ		; ELLE EST LA ...

**********************************************************************

	MOVE.L	#SIZE1,D0	; TAILLE 1
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN1	; CONFIG ECRAN1
	
	MOVE.L	#SIZE2,D0	; TAILLE 2
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN2	; CONFIG ECRAN2
	
**********************************************************************

	MOVE.W	#%100010,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1,-(SP)
	MOVE.L	ECRAN2,-(SP)
	MOVE.W	#5,-(SP)	; VSETMODE
	TRAP	#14
	ADD.L	#14,SP
	
**********************************************************************

	MOVE.B	$484.W,KEYBOARD	; COUPE LE CLAVIER
	CLR.B	$484.W
	
	DC.W	$A00A
	MOVE.B	#$12,$FFFFFC02.W	; COUPE LA SOURIS
	
**********************************************************************
ZAX	MOVEQ	#1,D0
	BSR	ZAXX
CALL	MOVE.L	#ZAXX+8,$4D2.W



**********************************************************************

WAIT	CMP.B	#$39+$80,$FFFFFC02.W
	nop
	nop
	nop
	nop
	nop
	nop
	nop
 	BNE	WAIT	

BYE	DC.W	$A009
	MOVE.B	#8,$FFFFFC02.W
	MOVE.B	KEYBOARD,$484.W

	MOVE.W	REZ,-(SP)	; REMET LA REZ
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR,-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR,-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP

	CLR.L	$4D2.W
	MOVEQ	#0,D0
	BSR	ZAXX
	MOVEA.W	#$8800,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)

	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1

*********************************************************************
	SECTION DATA
********************************************************************* 

ZAXX	INCBIN	"E:\ENCOURS.S\FUZION.MAX"
	EVEN

IMAGE1	INCBIN	"E:\ENCOURS.S\ATRO2.PI1"
	EVEN

IMAGE2	INCBIN	"E:\ENCOURS.S\M1.PI1"
	EVEN

IMAGE3	INCBIN	"E:\ENCOURS.S\M2.PI1"
	EVEN

IMAGE4	INCBIN	"E:\ENCOURS.S\M3.PI1"
	EVEN

IMAGE5	INCBIN	"E:\ENCOURS.S\M4.PI1"
	EVEN

IMAGE6	INCBIN	"E:\ENCOURS.S\M5.PI1"
	EVEN

IMAGE7	INCBIN	"E:\ENCOURS.S\M6.PI1"
	EVEN

*********************************************************************
	SECTION BSS
*********************************************************************

SIZE1	DS.W	320*200+128
SIZE2	DS.W	320*200+128
PSCR	DS.W	2
LSCR	DS.W	2
REZ	DS.W	1
ECRAN1	DS.W	2
ECRAN2	DS.W	2
KEYBOARD	DS.B	1

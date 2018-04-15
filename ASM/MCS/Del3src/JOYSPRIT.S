* 7 sprites 4 plans sur fond 4 plans
* g‚r‚s par souris et joystick
* (c)1990 GADGET

* CHERCHER "$FF8240" ET ENLEVER POUR EXECUTION (TEST TEMPS)
	
	OPT	O+

	CLR.W	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,SAVESSP

	DC.W	$A00A
	
	MOVE.W	#0,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADDA.L	#12,SP
 
	

	LEA	NOM,A0
	MOVE.L	#$78000-128,A1
	MOVE.L	#32128,A2
	BSR	LOAD
	MOVE.L	#$78000-124,-(A7)
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

	LEA	BOULE,A0
	LEA	MASQUE,A1
	MOVEQ	#31,D6         

MASKK	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	MOVE.L	D0,D4
	OR.W	D1,D4
	OR.W	D2,D4
	OR.W	D3,D4
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	OR.W	D0,D4
	OR.W	D1,D4
	OR.W	D2,D4
	OR.W	D3,D4
	NOT.L	D4
	MOVE.L	D4,(A1)+
	DBRA	D6,MASKK

	MOVE.L	#$70000,A0
	MOVE.L	A0,FOND
	MOVE.L	#32000/4,D0
	MOVE.L	FOND,A0
	MOVE.L	#$78000,A1
AFFOND	MOVE.L	(A1)+,(A0)+
	DBRA	D0,AFFOND

LOOP	*MOVE.W	#$777,$FF8240
	JSR	MOUSE		;test souris
	JSR	JOYSTICK		;test joystick
	JSR	TESTBORDS
	MOVE.W	KM,D0
	TST.W	D0
	BNE	FINFIN

 	LEA	BUFFER1,A2
	
	*MOVE.W	#$700,$FF8240
	*MOVE.W	X6,D1
	*MOVE.W	Y6,D0
	*LEA	BOULE,A0
	*BSR	AFFSPRITE

	*MOVE.W	#$070,$FF8240
	*MOVE.W	X5,D1
	*MOVE.W	Y5,D0
	*LEA	BOULE,A0
	*BSR	AFFSPRITE

	*MOVE.W	#$007,$FF8240
	*MOVE.W	X4,D1
	*MOVE.W	Y4,D0
	*LEA	BOULE,A0
	*BSR	AFFSPRITE

	*MOVE.W	#$700,$FF8240
	*MOVE.W	X3,D1
	*MOVE.W	Y3,D0
	*LEA	BOULE,A0
	*BSR	AFFSPRITE

	*MOVE.W	#$770,$FF8240
	*MOVE.W	X2,D1
	*MOVE.W	Y2,D0
	*LEA	BOULE,A0
	*BSR	AFFSPRITE

	*MOVE.W	#$707,$FF8240
	*MOVE.W	X2,D1
	*MOVE.W	Y2,D0
	*LEA	BOULE,A0
	*BSR	AFFSPRITE

	*MOVE.W	#$077,$FF8240
	MOVE.W	X,D1
	MOVE.W	Y,D0	
	LEA	BOULE,A0
	BSR	AFFSPRITE

	*MOVE.W	#$000,$FF8240
	MOVE.W	X5,X6
	MOVE.W	Y5,Y6
	MOVE.W	X4,X5
	MOVE.W	Y4,Y5
	MOVE.W	X3,X4
	MOVE.W	Y3,Y4
	MOVE.W	X2,X3
	MOVE.W	Y2,Y3
	MOVE.W	X1,X2
	MOVE.W	Y1,Y2
	MOVE.W	X,X1
	MOVE.W	Y,Y1
        	MOVE.W	#37,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	LEA	BUFFER1,A1	
	BSR	RESTITUE
	BRA	LOOP

FINFIN	MOVE.W	#0,$ff8240		;***TEST TEMPS***
	MOVE.L	#SAVESSP,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.W	-(SP)
	TRAP	#1

*---------------------------------------------------------------
*               Chargement du fichier Data
*--------------------------------------------------------------

;      A0: adresse du nom
;      A1: adresse du buffer
;      A2: longueur

LOAD	MOVE.W	#0,-(SP)
	MOVE.L	A0,-(SP)
	MOVE.W	#$3D,-(SP)
	TRAP	#1
	ADDQ.L	#8,SP
	TST.W	D0
	BPL	READ

ERROR	PEA	ERRORTXT
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.L	-(SP)
	TRAP	#1
      
READ	MOVE.W	D0,D3
	MOVE.L	A1,-(SP)
	MOVE.L	A2,-(SP)
	MOVE.W	D3,-(SP)
	MOVE.W	#$3F,-(SP)
	TRAP	#1
	ADDA.L	#12,SP

CLOSE	MOVE.W	D3,-(SP)
	MOVE.W	#$3E,-(SP)
	TRAP	#1	
	ADDQ.L	#4,SP
	RTS
      
NOM	DC.B	'IRONBAL.NEO',0
	EVEN
ERRORTXT	DC.B	'ERREUR: voir si le fichier',$0D,$0A,34
	DC.B	'PICTURE.PI1',34,' existe sur le disk!',0
	EVEN

*----------------------------------------------------------------
*         Gestion des sprites baladeurs sur l'ecran
*----------------------------------------------------------------
* entree : D1 coordonnee x
*          D0 coordonnee y
*          A2 adresse buffer de sauvegarde
*          A0 adresse du sprite a afficher
 
AFFSPRITE	
	ANDI.L	#$FF,D0
	MULU	#160,D0
	MOVE.W	D1,D7
	ANDI.L	#$1F0,D1
	LSR.W	#1,D1
	ADD.W	D1,D0
	MOVE.L	D0,(A2)+        * sauve add sprite
	ADD.L	#$78000,D0
	MOVEA.L	D0,A1           * adresse ecran de l'affichage
	ANDI.L	#15,D7
	LEA	MASQUE,A3
	MOVEQ	#30,D6          * sprite 16 lignes
	MOVE.W	#$444,$FF8240
AFF1	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	MOVE.L	(A3),D4        * mask dans D4
	ROR.L	D7,D0
	ROR.L	D7,D1
	ROR.L	D7,D2
	ROR.L	D7,D3
	ROR.L	D7,D4
	AND.W	D4,(A1)
	OR.W	D0,(A1)+
	AND.W	D4,(A1)
	OR.W	D1,(A1)+
	AND.W	D4,(A1)
	OR.W	D2,(A1)+
	AND.W	D4,(A1)
	OR.W	D3,(A1)+ 
	SWAP	D0
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	AND.W	D4,(A1)
	OR.W	D0,(A1)+
	AND.W	D4,(A1)
	OR.W	D1,(A1)+
	AND.W	D4,(A1)
	OR.W	D2,(A1)+
	AND.W	D4,(A1)
	OR.W	D3,(A1)+ 
	;ADDA.L	#$90,A1
	;ADDA.L #$8,A0
	;DBRA	D6,AFF1
	;MOVE.W	#$0,$FF8240
	;RTS

	SUBQ.L	#8,A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	MOVE.L	(A3)+,D4        * mask dans D4
	ROR.L	D7,D0
	ROR.L	D7,D1
	ROR.L	D7,D2
	ROR.L	D7,D3
	ROR.L	D7,D4
	AND.W	D4,(A1)
	OR.W	D0,(A1)+
	AND.W	D4,(A1)
	OR.W	D1,(A1)+
	AND.W	D4,(A1)
	OR.W	D2,(A1)+
	AND.W	D4,(A1)
	OR.W	D3,(A1)+ 
	SWAP	D0
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	AND.W	D4,(A1)
	OR.W	D0,(A1)+
	AND.W	D4,(A1)
	OR.W	D1,(A1)+
	AND.W	D4,(A1)
	OR.W	D2,(A1)+
	AND.W	D4,(A1)
	OR.W	D3,(A1)+ 

	ADDA.L	#$90-8,A1
	DBRA	D6,AFF1
	MOVE.W	#$0,$FF8240
	RTS
 
*--------------------------------------------
*   restitution
*--------------------------------------------
* A1=buffer
*
*

RESTITUE	MOVEM.L	A0-A6/D0-D2,-(SP)
	MOVE.L	#6,D2

SUIVANT	MOVE.L	FOND,A0
	MOVE.L	#$78000,A2

	ADD.L	(A1),A0
	ADD.L	(A1)+,A2
N SET 0
	REPT 31
	MOVEM.L	N(A0),A3-A6/D0-D2
	MOVEM.L	A3-A6/D0-D2,N(A2)
N SET N+160
	ENDR

 	MOVEM.L	(SP)+,A0-A6/D0-D2
	RTS
 
MOUSE	LEA	$EA0,A0		;lecture coords
	CLR.W	D0
	CLR.W	D1
	CLR.W	D2
	MOVE.B	(A0),D0
	MOVE.B	1(A0),D1
	MOVE.B	2(A0),D2	
	CLR.B	1(A0)
	CLR.B	2(A0)
	SUB.W	#$F8,D0
	EXT	D1
	EXT	D2
	MOVE.W	D0,KM
	LSL	#1,D1
	LSL	#1,D2
	ADD.W	D1,X
	ADD.W	D2,Y
	RTS

JOYSTICK	LEA	$EAB,A0		;lecture port 1
	CLR.W	D0
	CLR.W	D1
	CLR.W	D2
	MOVE.B	(A0),D0
	CMP.W	#0,D0		;joy relach‚
	BNE	N0
	CLR.W	D5
	MOVE.W	#1,JOYINTER
	BRA	JOYSUITE
N0	MOVE.W	JOYCOMPTEUR,D5	;acc‚l‚ration
	ADD.W	#1,D5
	CMP.W	#48,D5
	BLE	CALCJOY
	MOVE.W	#48,D5
CALCJOY	MOVE.W	D5,D6
	LSR	#2,D6
	MOVE.W	JOYINTER,D3
	ADD.W	D6,D3
	MOVE.W	D3,D4
	NEG	D4
	CMP.W	#1,D0		;haut
	BNE	N1
	MOVE.W	D4,D2
	BRA	JOYSUITE
N1	CMP.W	#9,D0		;haut droite
	BNE	N9
	MOVE.W	D3,D1
	MOVE.W	D4,D2
	BRA	JOYSUITE
N9	CMP.W	#8,D0		;droite
	BNE	N8
	MOVE.W	D3,D1
	BRA	JOYSUITE
N8	CMP.W	#$A,D0		;bas droite
	BNE	N10
	MOVE.W	D3,D1
	MOVE.W	D3,D2
	BRA	JOYSUITE
N10	CMP.W	#2,D0		;bas
	BNE	N2
	MOVE.W	D3,D2
	BRA	JOYSUITE
N2	CMP.W	#6,D0		;bas gauche
	BNE	N6
	MOVE.W	D4,D1
	MOVE.W	D3,D2
	BRA	JOYSUITE
N6	CMP.W	#4,D0		;gauche
	BNE	N4
	MOVE.W	D4,D1
	BRA	JOYSUITE
N4	CMP.W	#5,D0		;haut gauche
	BNE	JOYSUITE
	MOVE.W	D4,D1
	MOVE.W	D4,D2		
JOYSUITE	ADD.W	D1,X
	ADD.W	D2,Y
	MOVE.W	D5,JOYCOMPTEUR
	RTS

TESTBORDS	MOVE.W	X,D0
	CMP.W	#0,D0
	BGT	HORIZON
	CLR.W	D0
	BRA	SCRIN
HORIZON	CMP.W	#319-16,D0
	BLT	SCRIN
	MOVE.W	#319-15,D0
SCRIN	MOVE.W	D0,X
	MOVE.W	Y,D0
	CMP.W	#0,D0
	BGT	VERTIC
	CLR.W	D0
	BRA	SCRIN2
VERTIC	CMP.W	#200-16,D0
	BLT	SCRIN2
	MOVE.W	#200-15,D0
SCRIN2	MOVE.W	D0,Y
	RTS
		
KM	DC.W	0
X	DC.W	0
Y	DC.W	0
X1	DC.W	0
Y1	DC.W	0
X2	DC.W	0
Y2	DC.W	0
X3	DC.W	0
Y3	DC.W	0
X4	DC.W	0
Y4	DC.W	0
X5	DC.W	0
Y5	DC.W	0
X6	DC.W	0
Y6	DC.W	0

JOYCOMPTEUR	DC.W	0
JOYINTER	DC.W	1
SAVESSP	DC.L	0
 
BOULE 	
	INCBIN	BALL1.Z

PALETTE	DC.W	$0000,$0724,$0703,$0602,$0502,$0401,$0301,$0200
	DC.W	$0357,$0020,$0030,$0040,$0050,$0060,$0147,$0755

FOND	DC.L	0

BUFFER1	DS.L	7        
MASQUE	DS.L	512/4
	
	
	END
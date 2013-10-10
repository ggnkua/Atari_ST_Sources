***********************************
*	ZOOMER ROUTINE by 	  *
*      Cristalion/Hydroxid        *
*    the ....... 		  *
***********************************


;pour le facteur on prend comme point de repere 320,ok ???
*facteur=	250
largeur=	319
hauteur=	199

	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BSR	INITS
	BSR	MAKE_PAL
**************************BOUCLE PRINCIPALE*************************************************
LOOP
	bsr	VBL
	CLR.W	$FFFF8240
	BSR	ZOOMMM
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_SHIFT
	ADDQ.W	#2,FACTEUR
NO_SHIFT
*	MOVE.W	#$5,$FFFF8240
	CMPI.B	#57,$FFFFC02
	BNE.S	LOOP
	BRA	FIN
***************************INITIALISATIONS*********************************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		*
	MOVE.W	#88,-(SP)		*
	TRAP	#14			*
	ADDQ.L	#4,SP			*
	MOVE.W	D0,OLDMODECODE		*

	MOVE.W	#0,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	subi.l #$9B00,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR

	MOVE.W	#0,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	RTS
***********************SOUS ROUTINES****************************************************
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
AFF_IMG
	MOVE.L	AFFECR,A0
	LEA	IMAGE+34,A1
	MOVE.W	#7999,D1
OK
	MOVE.L	(A1)+,(A0)+
	DBF	D1,OK
	RTS
MAKE_PAL
	MOVE.L	#$FFFF8240,A0
	MOVEQ	#15,D1
	LEA	IMAGE+2,A1
PAL
	BSR	VBL
	MOVE.W	(A1)+,(A0)+
	DBF	D1,PAL
	RTS
********************ZZZOOOOOOOOOOOOOOOOOOOOOOOMMMMMMMMMMMMMMMMMM**********************************
ZOOMMM
;on prend les addresses de base(A0,A1,D1,D2)
	LEA	IMAGE+34,A0
	MOVE.L	AFFECR,A1
	MOVE.W	facteur,D1	;D1 compteur pour x
	MOVE.W	D1,D2		;D2 compteur pour y
	MOVE.W	#largeur,D3	;D3 fait les 320 pix
	MOVE	#hauteur,D4	;D4 fait 40 lignes
	MOVEQ	#0,D5		;D5 compteur pour numero du pts image
	MOVEQ	#0,D6		;D6 .......... ecran		
;on fait le zoom
ZOOMER_Y
	ADD.W	facteur,D2
	CMPI.W	#320,D2
	BLE	ZOOMER_X
OXO	SET 	0
	REPT	80
	MOVE.W	OXO(A0),OXO(A1)
OXO	SET 	OXO+2
	ENDR
	LEA	160(A1),A1	;ligne ecran suivante
	SUB.W	#320,D2
ZOOMER_X
*	ADDQ.W	#1,D5
*	ADD.W	D1,D1	
*	CMPI.W	#320,D1		;si facteur>320 affiche le point
*	BLE.S	NO_POINT
*	BSR	AFF_POINT
*	MOVE.W	#facteur,D1
*NO_POINT
*	DBF	D3,ZOOMER_X
*	MOVEQ	#0,D5		;remise a 0 pour nouvelle ligne
	LEA	160(A0),A0	;ligne image suivante
	DBF	D4,ZOOMER_Y
	RTS

;procedure chargee de voir quel point il faut afficher
AFF_POINT
	RTS
*******************c'est FI-NI********************************************************************

FIN	
	CLR.L	$4D2
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	BSR	VBL
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

		SECTION	DATA
IMAGE		INCBIN	"E:\GRAPHS\HYDROXID.PI1\nytrik\grosnain.pi1"
AFFECR:		DC.L 	0
WORKECR:	DC.L 	0
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
FACTEUR		DC.W	2

		SECTION BSS
	DS.L 2000
PILE	DS.L 10
	END

			
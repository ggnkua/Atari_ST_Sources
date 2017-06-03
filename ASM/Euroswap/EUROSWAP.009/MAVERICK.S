	SECTION	TEXT
	opt	d-
	
	;INITIALISTATION DE PROGRAMME.
	
	MOVEA.L	4(A7),A5	prend l'adresse de la page de base.

	ADD.L	12(A5),D0	la longueur de la section text +...
	ADD.L	20(A5),D0	la longueur de la section data +...
	ADD.L	28(A5),D0	la longueur de la section bss +...
	ADD.L	#256,D0	      	la longueur de la page de base.
	
	MOVE.L	D0,-(A7)	envoie le resultat sur la pile.
	MOVE.L	A5,-(A7)	debut de la page de base.
	PEA	$4A0000
	TRAP	#1	      	retrecit la memoire utilisee
	LEA	12(SP),SP

 	PEA	PILE	      	installe la nouvelle pile.
	MOVE.W	#$20,-(SP)
	TRAP	#1	      	passe en mode superviseur.
	MOVE.L	D0,UTILIS
	
	MOVE.B	#$12,$FFFFFC02.W 	d‚sactive la souris.
	sf	$484.w	d‚sactive clic et r‚p‚tition clavier.

	LEA	$FFFF8240.W,A0
	LEA	PALETTE,A1
	MOVEQ	#15,D0	       	sauve la palette...
COLOR	MOVE.W	(A0)+,(A1)+     ...de couleurs.
	DBF	D0,COLOR
		
	MOVE.B	$ffff8260.w,RESOL	sauve la resolution.	
	sf	$FFFF8260.W  	change la resolution. 

IERA	EQU	$FFFFFA07	*absolu court gain 4 cycles par instructions
IERB	EQU	$FFFFFA09
ISRA	EQU	$FFFFFA0F
ISRB	EQU	$FFFFFA11
IMRA	EQU	$FFFFFA13
IMRB	EQU	$FFFFFA15
TBDR	EQU	$FFFFFA21
TBCR	EQU	$FFFFFA1B

	LEA	MFP,A0
	MOVE.B	IERA.W,(A0)+
	MOVE.B	IERB.W,(A0)+
	MOVE.B	ISRA.W,(A0)+		sauve les registres...
	MOVE.B	ISRB.W,(A0)+		...du MFP.
	MOVE.B	IMRA.W,(A0)+
	MOVE.B	IMRB.W,(A0)+
	MOVE.B	TBDR.W,(A0)+
	MOVE.B	TBCR.W,(A0)+
	MOVE.L	$70.w,OLD_VBL	sauve la VBL.
	MOVE.L	$120.w,OLD_TIMERB	sauve le timer B.
	MOVE.L	$44E.w,OLD_SCREEN	sauve l'adresse de l'ecran.

	BCLR	#4,IERB.W		stop le timer D.
	BCLR	#5,IERB.W		stop le timer C.
	
	MOVEQ	#0,D0		*appel musique	(lotus)
	bsr	MUSIC
	bsr	MUSIC+18


	MOVE.L	#FONTES1+2,$45A.W	installe la palette.

	bsr	efface
	
	MOVE.L	$44E.W,A0	
	LEA	FONTES1+34+4160,A1	adresse source.
	MOVE.W	#1599,D0
AFFLOGO	MOVE.L	(A1)+,(A0)+	affiche euroswap
	DBF	D0,AFFLOGO	

	BSR	AFF_TEXTE		affiche le contenu du cd

	BCLR	#0,IERA.W
	BCLR	#0,IMRA.W
	MOVE.L	#NEW_TIMEB,$120.W	installe TIMER B (les rasters).
	BSET	#0,IERA.W
	BSET	#0,IMRA.W
	BCLR #3,$FFFFFA17.W		aei=> le mfp annule l'interruption en cours tout seul,permet de gagner 16 cycles par interruption...
	MOVE.B	#32,SIZE		largeur d'une lettre du screx.
	move.l	#vbl,$70.w
	MOVE.W	#37,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	

	
getkey	cmpi.b	#$00,$fffffc02.w
	beq.s	getkey
key1	cmpi.b	#$3b,$fffffc02.w	;F1
	bne.s	key2
	move.w	#$3100,$5a0.w
	bra.s	out
key2	cmpi.b	#$3c,$fffffc02.w	;F2
	bne.s	key3
	move.w	#$3200,$5a0.w
	bra.s	out
key3	cmpi.b	#$3d,$fffffc02.w	;F3
	bne.s	key4
	move.w	#$3300,$5a0.w
	bra.s	out
key4	cmpi.b	#$3e,$fffffc02.w	;F4
	bne.s	key5
	move.w	#$3400,$5a0.w
	bra.s	out
key5	cmpi.b	#$3f,$fffffc02.w	;F5
	bne.s	getkey
	move.w	#$3500,$5a0.w


out	move	#$2700,sr
	moveq	#0,d0
	move.b	d0,IERA.W
	MOVE.b	d0,IERB.W
	MOVE.b	d0,IMRA.W
	MOVE.b	d0,IMRB.W
	MOVE.L	itnul,$70.w
	 
	MOVEQ	#-1,D0		*STOP musique
	bsr	MUSIC
	bsr	MUSIC+22
	
	MOVE.L	#$08080000,$FFFF8800.W	*stop son
	MOVE.L	#$09090000,$FFFF8800.W
	MOVE.L	#$0A0A0000,$FFFF8800.W

	
	MOVE.L	OLD_VBL,$70.w
	MOVE.L	OLD_TIMERB,$120.w
	MOVE.B	OLD_SCREEN+1,$FFFF8201.W
	MOVE.B	OLD_SCREEN+2,$FFFF8203.W
		
	LEA	MFP,A0
	MOVE.B	(A0)+,IERA.W
	MOVE.B	(A0)+,IERB.W
	MOVE.B	(A0)+,ISRA.W		restore les registres...
	MOVE.B	(A0)+,ISRB.W		...du MFP.
	MOVE.B	(A0)+,IMRA.W
	MOVE.B	(A0)+,IMRB.W
	MOVE.B	(A0)+,TBDR.W
	MOVE.B	(A0)+,TBCR.W
	BSET #3,$FFFFFA17.W            restaure le sei
	MOVE.W #$2300,SR		retablit l'interruption Vbl,la palette peut etre restaur‚(merci Maverick)
	MOVE.B	RESOL,$FFFF8260.W	restore la resolution.
	MOVE.L	#PALETTE,$45A.w	restore la palette.

	MOVE.B	#$F,$484.w	r‚instal le clic et la repetition clavier.
	MOVE.B	#$8,$FFFFFC02.W	r‚active la souris.	
	bsr	efface

	MOVE.L	UTILIS,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1	r‚instal l'ancienne pile superviseur.
	LEA	10(SP),SP

	CLR.W	-(SP)
	TRAP	#1	fin du programme.

vbl	
	*ST $FFFF8240.W
	bsr	MUSIC+26
	lea	coul2,a5
	LEA	coul1,A6
	LEA (A6),A3
	LEA (A6),A2
	MOVE.W	coul1,396(A6)	
*INC1	SET	2
*INC2	SET	0
	ADDQ.L #2,A2
	REPT	198
	MOVE.W	(A2)+,(A3)+	cycling de couleurs avec postincrementation
*INC1	SET	INC1+2		gain plus de 8*198 cycles par Vbl
*INC2	SET	INC2+2	
	ENDR
	
	
	CLR.B	TBCR.W
	MOVE.B	#1,TBDR.W		raster sur 1 bande.
	MOVE.B	#8,TBCR.W		MODE COMPTAGE
	BSR.s	SCREX		routine du scrolltext.
	bsr	vumetre
	*SF $FFFF8240.W
	rte
	
	
	
	
efface	MOVE.L	$44E.W,A0
	MOVE.W	#7999,D0
CLS	CLR.L	(A0)+		vide l'ecran.
	DBF	D0,CLS
	rts


itnul	rte

NEW_TIMEB
	
	MOVE.W	(A6)+,$FFFF8240.W	affiche le raster du fond
	move.w	(a5)+,$ffff8244.w	affiche le raster fonte
	*BCLR	#0,ISRA.W               plus de sei,gain 16*200 cycles par Vbl!
	RTE
		
SCREX	CMP.B	#32,SIZE
	BNE.S	PART_4
	CLR.B	SIZE
PART_0	MOVE.L	POINTEUR,A0
	CLR.W	D0
	MOVE.B	(A0)+,D0		
	MOVE.L	A0,POINTEUR
	TST.B	D0
	BNE.S	PART_1
 	MOVE.L	#ADR_TEXTE,POINTEUR
	BRA.S	PART_0
PART_1	
	LEA	FONTES2+34,A0
	LEA	POSITION2,A1
	SUB.W	#32,D0
	asl.w	d0		
	ADDA.W	0(A1,D0.W),A0			
	
	LEA	BUFFER,A1
	MOVEQ	#32,D0		hauteur d'une lettre.
PART_2	
	MOVE.W	2(A0),(A1)+
	MOVE.W	6(A0),(A1)+		
	MOVE.W	10(A0),(A1)+		
	MOVE.W	14(A0),(A1)+		
	LEA	160(A0),A0
	DBF	D0,PART_2
PART_4
	BSR.s	PART_5
	BSR.s	PART_5
	BSR	PART_5
PART_5			
	LEA	BUFFER,A1
	MOVEA.L	$44E.W,A0
	
	LEA	25760(A0),A0	;position du screxx
	MOVEQ	#31,D0		;partie a afficher(lignes)
PART_6

INC	SET	146	PLAN 2
 	ROXL	4(A1)
 	ROXL	(A1)
	REPT	18
	ROXL	INC(A0)
INC	SET	INC-8
	ENDR


	LEA	160(A0),A0
	ADDQ.L	#8,A1
	DBF	D0,PART_6
	ADDQ.B	#1,SIZE
	RTS

vumetre	move.l	$44e.w,a0
	lea	8330(a0),a0	;position vumetre
CHANGE	MOVEQ.W #0,D0
	MOVEQ.W #0,D1
	MOVEQ.W #0,D2
	MOVEQ	#-1,D6
	MOVE.B #8,$FFFF8800.W  	
	MOVE.B $FFFF8800.W,D0
	MOVE.B #9,$FFFF8800.W   
	MOVE.B $FFFF8800.W,D1
	MOVE.B #10,$FFFF8800.W  
	MOVE.B $FFFF8800.W,D2
	BTST #4,D0              
	BEQ.s .L1
	MOVEQ #10,D0           
.L1	BTST #4,D1    		
       	BEQ.s .L2
	MOVEQ #10,D1
.L2	BTST #4,D2		
	BEQ.s .L3
	MOVEQ #10,D2
.L3 	
	MULU	#15,D0
	MULU	#15,D1
	MULU	#15,D2
	MOVEQ #0,D3
	BSR	CH_1
	BSR	CH_2
	BSR	CH_3
STOP_NOW
	RTS
	
*ROUTINES TO DRAW VOLUME BARS

CH_1
	MOVE.L	#VOL,A1
	ADD.W	D0,A1
	LEA	(A0),A2
	LEA 16008(A2),A2
	MOVEQ	#14,D4
CH_1_L
	MOVE.B	(A1)+,D5
	CMP.B	#1,D5
	BEQ.s	CH_1_DRAW
	MOVE.W	D3,(A2)
	MOVE.W	D3,8(A2)
	MOVE.W	D3,16(A2)
	MOVE.W	D3,24(A2)
	MOVE.W	D3,160(A2)
	MOVE.W	D3,168(A2)
	MOVE.W	D3,176(A2)
	MOVE.W	D3,184(A2)
CH_1_LL
	LEA	-640(A2),A2
	DBF	D4,CH_1_L
	RTS
CH_1_DRAW
	MOVE.W	D6,(A2)
	MOVE.W	D6,8(A2)
	MOVE.W	D6,16(A2)
	MOVE.W	D6,24(A2)
	MOVE.W	D6,160(A2)
	MOVE.W	D6,168(A2)
	MOVE.W	D6,176(A2)
	MOVE.W	D6,184(A2)
	BRA.s	CH_1_LL
***************************
CH_2
	MOVE.L	#VOL,A1
	ADD.W	D1,A1
	MOVE.L	A0,A2
	LEA 16056(A2),A2
	MOVEQ	#14,D4
CH_2_L
	MOVE.B	(A1)+,D5
	CMP.B	#1,D5
	BEQ.s	CH_2_DRAW
	MOVE.W	D3,(A2)
	MOVE.W	D3,8(A2)
	MOVE.W	D3,16(A2)
	MOVE.W	D3,24(A2)
	MOVE.W	D3,160(A2)
	MOVE.W	D3,168(A2)
	MOVE.W	D3,176(A2)
	MOVE.W	D3,184(A2)
CH_2_LL
	LEA	-640(A2),A2
	DBF	D4,CH_2_L
	RTS
CH_2_DRAW
	MOVE.W	D6,(A2)
	MOVE.W	D6,8(A2)
	MOVE.W	D6,16(A2)
	MOVE.W	D6,24(A2)
	MOVE.W	D6,160(A2)
	MOVE.W	D6,168(A2)
	MOVE.W	D6,176(A2)
	MOVE.W	D6,184(A2)
	BRA.s	CH_2_LL

****************************
CH_3
	MOVE.L	#VOL,A1
	ADD.W	D2,A1
	MOVE.L	A0,A2
	LEA 16104(A2),A2
	MOVEQ	#14,D4
CH_3_L
	MOVE.B	(A1)+,D5
	CMP.B	#1,D5
	BEQ.s	CH_3_DRAW
	MOVE.W	D3,(A2)
	MOVE.W	D3,8(A2)
	MOVE.W	D3,16(A2)
	MOVE.W	D3,24(A2)
	MOVE.W	D3,160(A2)
	MOVE.W	D3,168(A2)
	MOVE.W	D3,176(A2)
	MOVE.W	D3,184(A2)
CH_3_LL
	LEA	-640(A2),A2
	DBF	D4,CH_3_L
	RTS
CH_3_DRAW
	MOVE.W	D6,(A2)
	MOVE.W	D6,8(A2)
	MOVE.W	D6,16(A2)
	MOVE.W	D6,24(A2)
	MOVE.W	D6,160(A2)
	MOVE.W	D6,168(A2)
	MOVE.W	D6,176(A2)
	MOVE.W	D6,184(A2)
	BRA.s	CH_3_LL



AFF_TEXTE	
	LEA	POSITION1,A4
	LEA	MESSAGE,a2
	MOVE.L	$44E.W,a1
	MOVE.W	#44,COUNTER	nb de lignes avant debut
			 
.DEBUT_1	MOVEQ	#1,D7	
.DEBUT_2	LEA	FONTES1+34,A3
	CLR.W	D0
	MOVE.B	(a2)+,D0
	TST	D0		fin du texte.
	BEQ.S	 FIN
	CMP.B	#"@",D0		retour a la ligne.
	BNE.S	.SUITE	

	MOVE.W	#160,D0
	MULU.W	COUNTER,D0
	MOVE.L	$44E.W,a1
	ADD.L	D0,a1
	ADD.W	#9,COUNTER
	BRA.s	.DEBUT_1	

.SUITE	SUB.W	#32,D0	
	lsl.W	#1,D0
	ADDA.W	0(A4,D0.W),A3
			
	MOVEQ	#7,D0
.BOUCLE	
	MOVE.B	(A3),(a1)
	MOVE.B	2(A3),2(a1)
	MOVE.B	4(A3),4(a1)
	MOVE.B	6(A3),6(a1)
	LEA	160(A3),A3
	LEA	160(a1),a1
	DBF	D0,.BOUCLE
	LEA	-1280(A1),a1	
	ADD.W	D7,a1

	CMP.B	#$1,D7
	BNE.S	.DEBUT_1
	MOVEQ	#$7,D7
	BRA.S	.DEBUT_2
FIN	RTS	

	section data
	
VOL	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	1,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	1,1,1,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	1,1,1,1,0,0,0,0,0,0,0,0,0,0,0
	DC.B	1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
	DC.B    1,1,1,1,1,1,0,0,0,0,0,0,0,0,0
	DC.B    1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
	DC.B    1,1,1,1,1,1,1,1,0,0,0,0,0,0,0
	DC.B    1,1,1,1,1,1,1,1,1,0,0,0,0,0,0
	DC.B    1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
	DC.B    1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
	DC.B    1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
	DC.B    1,1,1,1,1,1,1,1,1,1,1,1,1,0,0
	DC.B    1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	DC.B    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	EVEN

POINTEUR	DC.L	ADR_TEXTE

POSITION1	DC.W	$000,$001,$008,$000,$000,$000,$000,$019,$020,$021
	DC.W	$028,$000,$030,$031,$038,$000,$040,$041,$048,$049
 	DC.W	$050,$051,$058,$059,$060,$061,$068,$000,$070,$071
	DC.W	$078,$079,$000
	DC.W	$6E0,$6E1,$6E8,$6E9,$6F0,$6F1,$6F8,$6F9,$700,$701
	DC.W	$708,$709,$710,$711,$718,$719,$720,$721,$728,$729
	DC.W	$730,$731,$738,$739,$740,$741

POSITION2	DC.W	0,16,32,48,64,80,96,112,128,144,5120,5136,5152,5168,5184,5200
	DC.W	5216,5232,5248,5264,10240,10256,10272,10288,10304,10320,10336,10352,10368
	DC.W	10384,15360,15376,15392,15408,15424,15440,15456,15472,15488,15504
	DC.W	20480,20496,20512,20528,20544,20560,20576,20592,20608,20624,25600
	DC.W	25616,25632,25648,25664,25680,25696,25712,25728

ADR_TEXTE	
	DC.B	"  YEAAAAAH !!!!!!      DARKO OF PASSWORDS IS HAPPY TO PRESENT YOU THIS NEW COMPACT DISK "
	DC.B	"   CREDITS FOR THIS INTRO : CODE BY DARKO AND SHIVER , DIGIDRUM BY LOTUS .    "
	
	incbin	greetz.txt	;LISTE DES MEMBRES ET GREETINGS
	
	dc.b	"  YOU CAN CONTACT US ON 3615 RTEL , BAL PASSWORDS OR NOTARIUS "
	DC.B	"  OK , TIME TO WRAP !  BYE AND SEE YOU SOON   ...             "
	DC.B	"                ",0
	EVEN	;.........|.........20........|.........40
MESSAGE	DC.B	"@****************************************@"
	DC.B	"* EUROSWAP  CD 967 - DONE BY PASSWORDS *@"
	DC.B	"* F1 : GRAHAM TAYLOR SOCCER CHALLENGE  *@"
	DC.B	"* F2 : LIVERPOOL FC    F3 : ROBIN HOOD *@"
	DC.B	"* F4 : THE CD-LIST     F5 : DISK CHECK *@"
	DC.B	"****************************************@"
	DC.B	0
	EVEN
	
MUSIC	INCBIN	eternal\BUBBLE.mus

FONTES1	INCBIN	FONTES01.PI1		

FONTES2	INCBIN	FONTES03.PI1	

coul2	incbin	rasters\raster_2.hbl
	
coul1	incbin	rasters\rouge.hbl
	


***************************************************************************
	SECTION	BSS
***************************************************************************	
	EVEN
	DS.B	100
PILE	DS.L	1
MFP	DS.B	8
PALETTE	DS.W	16
OLD_VBL	DS.L	1
OLD_TIMERB	DS.L	1
OLD_SCREEN	DS.L	1
UTILIS	DS.L	1
RESOL	DS.B	1
	EVEN
BUFFER	DS.B	312
COUNTER	DS.W	1
SIZE	DS.B	1
MARK	DS.B	1
	END			
	


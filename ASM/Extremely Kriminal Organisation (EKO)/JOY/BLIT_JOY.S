************************************************************************
**                                                                    **
**              Utilisation du Joystick & du Blitter  (STE\FALCON)    **
** Source venant du jeu de MAXI,qu'il m'a demande de terminee, ainsi  **
** que sa protection dont je ne comprend pas le 1/3 des lignes ...    **
** Dommage qu'il n'est pas fini ce jeu car je pense que la protection **
** aurait ete beton... Les gfx en plus sur le disk sont fait par Alfa **
** membre de Mad'Vision qui a arrete de faire des gfx . Il est a dans **
** l'armee ...  Cette source est codee a la brute car M.A.X.I ne sait **
** pas faire autrement,mais elle a l 'avantage de marcher et d ' etre **
** assez simple malgre tout ... C'etait aussi la premiere que j'ai vu **
** sur le blitter ( mais quand meme elle est depassee car trop borde- **
** -lique, voir l 'article sur le blitter)                            **
** de l'excellent CREATEUR ....                                       **
**                                                                    **
**             Explication par M'V ( = E.K.O )                        ** 
**             ( Extremely Kangourou organs )                         **
**                                                                    **
** Notes:M.A.X.i est dans E.K.O mais dans la section PC !!!           **
** section qui ne fait rien !!!!!    Donc sa specialite !!!           ** 
**                                                                    **
************************************************************************


	OPT	D+
*
*	Initialisation.
*

	DC.W	$A00A		* Cache la souris

	CLR.W	-(SP)		* Basse resolution
	PEA	-1.W
	MOVE.L	(SP),-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	$C(A7),A7

	PEA	$400.W		* Mode supervieur
	MOVE.W	#$20,-(SP)
	TRAP	#1
	
	MOVEA.L	$42E.W,A7	*Limite de la RAM...
	MOVE.W	#15999,D0
EFD	CLR.L	-(A7)
	DBRA	D0,EFD
	MOVE.L	A7,D0
	MOVE.L	D0,ASC
	ADD.L	#$50,D0
	MOVE.W	D0,D1
	ROR.W	#8,D0
	MOVE.L	D0,$FFFF8200.W		* Affichage video
	MOVE.W	D1,$FFFF820C.W		* video base adresse
	MOVE.W	#$50,$FFFF820E.W	* Offset pour la ligbne suivante
	CLR.W	$FFFF8264.W		* Video base Offset Pixel
	MOVE.L	A7,A2

	LEA	IMG1+$80,A0
	LEA	IMG2+$80,A1

*	
* Preparation des 2 images pour le hard-scroll
* Voir prochain de HOW TO CODE pour test complet du hard scroll
*

	MOVE.W	#200-1,D1
JN0	MOVE.W	#$27,D0			*40 fois (4*40=160 octet)
JN1	
	MOVE.L	(A0)+,(A2)+		
	DBRA	D0,JN1
	MOVEQ	#$27,D0
JN2	
	MOVE.L	(A1)+,(A2)+
	DBRA	D0,JN2
	DBRA	D1,JN0	
	
	MOVEM.L	IMG3+4,D0-D7		*Sauvegarde de la palette
	MOVEM.L	D0-D7,$FFFF8240.W
	MOVE.L	$70.W,-(SP)
	MOVE.L	$118.W,-(SP)
	MOVE.B	#$40,$FFFFFA09.W
	MOVE.B	#$12,$FFFFFC02.W	* Nique la souris
	MOVE.L	#HBL,$120.W
	CLR.B	$FFFFFA1B.W
	MOVE.B	#1,$FFFFFA07.W
	MOVE.B	#1,$FFFFFA13.W
	MOVE.L	#IMG3+$80,ADS
	LEA	VBL(PC),A0
	MOVE.L	A0,$70.W
	LEA	JOY(PC),A0
	MOVE.L	A0,$118.W		* Met la routine joy en $118
	STOP	#$2300			
	MOVE.B	#$16,$FFFFFC02.W	* Renseignement sur le joystick
					* Demande l'etat du JOY

**********************
* Routine principale *
**********************

ZZZ:	
	TST.W	FLG			
	BEQ.S	ZZZ			

* Mieux que le $25 trap #14 dans la rapidite,mais y fo une vbl
* Attend le fin de la vbl pour mettre le flag a 1 ...

 
	CLR.W	FLG

* Voir SAV ...

	BSR	SAV2

* Gestion des sprites suivant l'etat du joy !!!!

	BSR	ANAL	

* Scroll-hard horizontal !!!!

	MOVE.L	ASC,D0		
	MOVE.L	DEC2,D1		
	MOVE.L	D1,D2
	AND.L	#$F,D2
	SUB.L	D2,D1
	LSR.L	#1,D1
	ADD.L	D1,D0
	ADD.L	#$140*$64,D0
	EXG.L	D0,D2
	MOVEM.L	D0/D2,DN0
	MOVEM.L	ASC,D0-D1
	MOVE.L	D1,D2
	AND.L	#$F,D2
	SUB.L	D2,D1
	LSR.L	#1,D1
	ADD.L	D1,D0
	MOVE.W	D0,D1
	ROR.W	#8,D0
	MOVE.L	D0,$FFFF8200.W		* Affichage video
	MOVE.W	D1,$FFFF820C.W		* video base adresse
	MOVE.W	D2,$FFFF8264.W		* Video base Offset Pixel
	MOVE.W	#$50,$FFFF820E.W	* Offset pour la ligbne suivante
	TST.W	D2
	BEQ.S	EEE
	MOVE.W	#$4C,$FFFF820E.W	* Offset different ...

* Je vous le dirai la prochaine fois pour cette histoire d'offset a quoi ce
* sert car sinon je sais pas de quoi on va bien pouvoir parler !!! C'est
* tres bete a comprendre,il faut l'avoir fais une fois ... 
					
EEE:	

* Save le sprite a recopier en memoire.	
	BSR	SAV
* C'est pas le top voir article blitter.	
	BSR	CACM
* Mise en place du mask
	BSR	MVSK
* Colle le sprite
	BSR	MVO
		
	MOVE.B	#$16,$FFFFFC02.W	* Test du joystick

* 1 octet Header=$FE ou $FF pour joystick 1 ou 0 
* Bits 0 a 3 pour la position(1 bit par direction)
* Bits 7 pour le bouton !!!!
 	
	CMP.B	#$66,TOUCH	* Test de la touche magique ( * ) pour  
	BNE	ZZZ		* Sortir de l'ecran et revenir a Genst.

****************** Fin,restabilise tout !!!! ********************** 
	
 	MOVE.L	(SP)+,$118.W		* Remise en place des vecteurs
	MOVE.L	(SP)+,$70.W		* Pour la sortie ...
	MOVE.B	#$64,$FFFFFA09.W
	MOVE.B	#8,$FFFFFC02.W
	CLR.W	$FFFF820E.W
	CLR.W	$FFFF8264.W
	MOVE.W	#-1,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	CLR.B	$FFFFFA07.W
	MOVE.W	#1,-(SP)
	PEA	$1F8000
	MOVE.L	(SP),-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	$C(A7),A7
	DC.W	$A009
	CLR.W	-(SP)
	TRAP	#1

********************** THE END **************************


* Data pour les masques !!!
* Suivant le pixel .... o bit pres 

EEF	DC.L	$FFFF0000,$7FFF8000,$3FFFC000,$1FFFE000
	DC.L	$0FFFF000,$07FFF800,$03FFFC00,$01FFFE00
	DC.L	$00FFFF00,$007FFF80,$003FFFC0,$001FFFE0
	DC.L	$000FFFF0,$0007FFF8,$0003FFFC,$0001FFFE


FLG	DC.W	0
ASC	DC.L	0
DEC	DC.L	160
DEC2	DC.L	300

***************
* Routine VBL *
***************

VBL	CLR.B	$FFFFFA1B.W		* Configure HBL
	MOVE.W	#198,$8.W
	MOVE.B	#9,$FFFFFA21.W		* HBL toue les 9 ligne
	MOVE.B	#8,$FFFFFA1B.W
	clr.w	$ffff8240.w
	RTE
CMT	DC.W	0


***************
* Routine HBL *
***************


HBL	
	SUB.W	#9,$8.W
	BNE.S	EEH
	MOVE.W	#1,FLG
EEH	BCLR	#0,$FFFFFA0F.W
	RTE


* Affichage des sprites masques *
* en 4 fois ( 4 plan ).

MVO	
	MOVEM.L	DN0,D3/D7
	MOVE.W	#8,$FFFF8A20.W
	MOVE.W	#8,$FFFF8A2E.W
	MOVE.W	#$80,$FFFF8A22.W	
	MOVE.W	#$A0+$80,$FFFF8A30.W	
	MOVE.B	#2,$FFFF8A3A.W
	MOVE.B	#7,$FFFF8A3B.W
	MOVE.B	D3,$FFFF8A3D.W
	LSL.W	#2,D3
	LEA	EEF(PC),A0		*Masque de debut ligne
	MOVE.L	(A0,D3.W),D3		*suivant le pixel a l'ecrant !!!!
	MOVE.W	D3,$FFFF8A2C.W
	SWAP	D3
	MOVE.W	D3,$FFFF8A28.W
	MOVE.W	#$FFFF,$FFFF8A2A.W
	MOVE.L	ADS,D6
	ADD.L	DIFG,D6
	MOVE.L	#$50042,D5
	MOVE.L	D5,$FFFF8A36.W
	MOVE.L	D7,$FFFF8A32.W
	MOVE.L	D6,$FFFF8A24.W
	bsr	blit
	ADDQ.L	#2,D7			*plan suivant
	ADDQ.L	#2,D6			*plan suivant
	MOVE.L	D5,$FFFF8A36.W
	MOVE.L	D7,$FFFF8A32.W
	MOVE.L	D6,$FFFF8A24.W
	bsr	blit
	ADDQ.L	#2,D7
	ADDQ.L	#2,D6
	MOVE.L	D5,$FFFF8A36.W
	MOVE.L	D7,$FFFF8A32.W
	MOVE.L	D6,$FFFF8A24.W
	bsr	blit
	ADDQ.L	#2,D7
	ADDQ.L	#2,D6
	MOVE.L	D5,$FFFF8A36.W
	MOVE.L	D7,$FFFF8A32.W
	MOVE.L	D6,$FFFF8A24.W
	bsr	blit
	RTS

*
* Lance le blitter !!!!!
*

blit:	move.b	#$80,$ffff8a3c.w	*Lance le blitter
					*$80=%10000000
	NOP
bli2:	bset	#7,$ffff8a3c.w		*Test pour voir si le Blitter
					*travaille .
	nop
	bne.s	bli2			*S'il travaille ben on continue
	rts				*Sinon on se casse !!!

MVSK:	
	*Copie du mask en 4 fois (4 plans )

	MOVEM.L	DN0,D3/D7
	MOVE.W	#2,$FFFF8A20.W
	MOVE.W	#8,$FFFF8A2E.W
	MOVE.W	#2,$FFFF8A22.W	
	MOVE.W	#$A0+$80,$FFFF8A30.W	
	MOVE.B	#2,$FFFF8A3A.W
	MOVE.B	#4,$FFFF8A3B.W
	MOVE.B	D3,$FFFF8A3D.W
	LSL.W	#2,D3
	LEA	EEF(PC),A0
	MOVE.L	(A0,D3.W),D3
	MOVE.W	D3,$FFFF8A2C.W
	SWAP	D3
	MOVE.W	D3,$FFFF8A28.W
	MOVE.W	#$FFFF,$FFFF8A2A.W
	MOVE.L	#MSK,D6
	MOVE.L	#$50042,D5
	MOVE.L	D5,$FFFF8A36.W
	MOVE.L	D7,$FFFF8A32.W
	MOVE.L	D6,$FFFF8A24.W
	bsr	blit
	ADDQ.L	#2,D7
	MOVE.L	D5,$FFFF8A36.W
	MOVE.L	D7,$FFFF8A32.W
	MOVE.L	D6,$FFFF8A24.W
	bsr	blit
	ADDQ.L	#2,D7
	MOVE.L	D5,$FFFF8A36.W
	MOVE.L	D7,$FFFF8A32.W
	MOVE.L	D6,$FFFF8A24.W
	bsr	blit
	ADDQ.L	#2,D7
	MOVE.L	D5,$FFFF8A36.W
	MOVE.L	D7,$FFFF8A32.W
	MOVE.L	D6,$FFFF8A24.W
	bsr	blit
	RTS

* 
* Voir article sur le blitter
*

SAV	
	MOVE.W	#2,$FFFF8A20.W		*Incr horizontal source mod 2
	MOVE.W	#2,$FFFF8A2E.W		*Incr destination mod 2
	
	*Adresse a laquelle debute la copie source.
	MOVE.L	DN0+4,$FFFF8A24.W	
	
	*Adresse a laquelle debute la copie destination.
	MOVE.L	#RNGMEM,$FFFF8A32.W	
	
	MOVE.W	#$7A+$A0,$FFFF8A22.W	*Incr vertical source  
	MOVE.W	#2,$FFFF8A30.W		*Incr vert destination			
	MOVE.B	#2,$FFFF8A3A.W		*No Demi-teinte 
	MOVE.B	#3,$FFFF8A3B.W		*No operation logique
	MOVE.B	#0,$FFFF8A3D.W		*Control
	MOVE.W	#-1,$FFFF8A28.W		*Masques
	MOVE.W	#-1,$FFFF8A2A.W		*Masques
	MOVE.W	#-1,$FFFF8A2C.W		*Masques

* Nombre de ligne = 14 et nombre de mots = 42
	
	MOVE.L	#$140042,$FFFF8A36.W	
	bsr	blit			*Lance le blitter
	MOVE.W	#1,SAVF
	RTS


SAVF	DC.W	0

***************************
* Voir routine precedente *
***************************

SAV2	
	TST.W	SAVF	*Test pour savoir si l'on a deja fait SAV
	BEQ	SAV3
	CLR.W	SAVF
	MOVE.W	#2,$FFFF8A20.W
	MOVE.W	#2,$FFFF8A2E.W
	MOVE.L	#RNGMEM,$FFFF8A24.W
	MOVE.L	DN0+4,$FFFF8A32.W
	MOVE.W	#2,$FFFF8A22.W	
	MOVE.W	#$7A+$A0,$FFFF8A30.W	
	MOVE.B	#2,$FFFF8A3A.W
	MOVE.B	#3,$FFFF8A3B.W
	MOVE.B	#0,$FFFF8A3D.W
	MOVE.W	#-1,$FFFF8A28.W
	MOVE.W	#-1,$FFFF8A2A.W
	MOVE.W	#-1,$FFFF8A2C.W
	MOVE.L	#$140042,$FFFF8A36.W
	bsr	blit
SAV3	RTS



* Routine du Calcul du Masque *
*

CACM:	
	MOVE.L	ADS,A0
	ADD.L	DIFG,A0
	LEA	MSK,A1
	MOVEQ	#$41,D0
CAC1	MOVE.W	(A0)+,D2
	OR.W	(A0)+,D2
	OR.W	(A0)+,D2
	OR.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	OR.W	(A0)+,D3
	OR.W	(A0)+,D3
	OR.W	(A0)+,D3
	MOVE.W	(A0)+,D4
	OR.W	(A0)+,D4
	OR.W	(A0)+,D4
	OR.W	(A0)+,D4
	MOVE.W	(A0)+,D5
	OR.W	(A0)+,D5
	OR.W	(A0)+,D5
	OR.W	(A0)+,D5
	MOVE.W	(A0)+,D6
	OR.W	(A0)+,D6
	OR.W	(A0)+,D6
	OR.W	(A0)+,D6
	MOVEM.W	D2-D6,(A1)
	LEA	$A(A1),A1
	LEA	$78(A0),A0
	DBRA	D0,CAC1
	RTS	

TOUCH	DC.W	0	

* Routine joystick mis mise en $118 !!!!
* Revoir l'article de Major-X si vous ne comprenez pas ...  


JOY	MOVE.W	D0,-(SP)		* Sauvegarde d0 
JOYY	BSR.S	TGB			* Appel de la routine joy
	BTST	#4,$FFFFFA01.W		
	BEQ.S	JOYY			* Si CHR recu entre temps
	BCLR	#6,$FFFFFA11.W
	MOVE.W	(SP)+,D0		* Remet D0
	RTE

*
* Ouf,la gestion des sprites a la MaXi ya plus simple mais 
* ca donne une petite idee de comment il faut faire ...
* Je conseille de faire une table des adresses des sprites.
* Comme c'est plus simple !!!!
*

TGB:			

* 1 octet Header=$FE ou $FF pour joystick 1 ou 0 
* Bits 0 a 3 pour la position(1 bit par direction)
* Bits 7 pour le bouton !!!!
	
	
	MOVE.B	$FFFFFC02.W,D0
	TST.B	TOUCH+1		 * + 1 car octet fort 
	BNE.S	JOY4	
	CMP.B	#$F6,D0
	BHI.S	JOY3	
	TST.B	D0
	BMI.S	JOY2
	MOVE.B	D0,TOUCH
	RTS

JOY2	CLR.B	TOUCH
	RTS

JOY4	SUBQ.B	#1,TOUCH+1
	BNE.S	JOY6
	TST.B	TOUC2
	BEQ.S	JOY6
	CLR.B	TOUC2
	MOVE.B	D0,TOUC2+1

JOY6	RTS

JOY3	AND.W	#$FF,D0
	SUB.W	#$F6,D0
	MOVE.B	NBN(PC,D0.W),TOUCH+1		
	CMP.W	#8,D0
	BEQ.S	JOY7
	CMP.W	#9,D0
	BNE.S	JOY5

JOY7	MOVE.B	#1,TOUC2

JOY5	RTS

NBN	DC.B	7,5,2,2,2,2,6,2,1,1
TOUC2	DC.W	0
UYT	DC.W	0

* Test de l'etat du joystick et mise des sprites en place ...
* 1 octet Header=$FE ou $FF pour joystick 1 ou 0 
* Bits 0 a 3 pour la position(1 bit par direction)
* Bits 7 pour le bouton !!!!
 

ANAL	
	TST.W	UYT
	BEQ.S	EDC
	SUBQ.W	#1,UYT
	BEQ.S	EDC
	RTS

EDC	
	BTST	#7,TOUC2+1
	BNE	BOUTON
	BSR	REST
	RTS

* Ouch gestion des sprites quand ya bouton de tir 

BOUTON	
	BTST	#3,TOUC2+1
	BNE	BPD
	BTST	#2,TOUC2+1
	BNE	BPG
	BSR	REST
	RTS


BPD	MOVE.L	#IMG3+$80,ADS
	ADD.L	#$28,DIFG
	MOVE.W	#1,BFI
	CMP.L	#$A0,DIFG
	BNE.S	BPD2
	MOVE.L	#$78,DIFG
	MOVE.W	#2,UYT
BPD2	RTS

BPG	MOVE.L	#IMG3+$80+72*$A0,ADS
	ADD.L	#$28,DIFG
	MOVE.W	#1,BFI
	CMP.L	#$A0,DIFG
	BNE.S	BPG2
	MOVE.L	#$78,DIFG
	MOVE.W	#2,UYT
BPG2	RTS

REST	SUB.L	#$28,DIFG
	BPL.S	RES2
	CLR.L	DIFG

RES2	RTS

BFI	DC.W	0

DIFG	DC.L	0

DROITE	MOVE.L	#IMG3+$A8,ADS
	MOVE.B	#1,DRO
	TST.B	GAU
	BEQ.S	DROI1
	CLR.W	KKK
	CLR.B	GAU
DROI1	BSR	FVT
	MOVE.L	DEC2,D1
	SUB.L	DEC,D1
	CMP.W	#160,D1
	BGE.S	CV5
	SUB.L	D0,DEC
CV5	SUB.L	D0,DEC2
	TST.W	DEC
	BMI.S	CV1
	RTS

CV1	SUBQ.W	#2,KKK
	BPL.S	CV7
	CLR.W	KKK
CV7	CLR.L	DEC
	CMP.L	#$10,DEC2
	BGE.S	CV3
	MOVE.L	#$10,DEC2
	CLR.W	GAU
	CLR.W	KKK
CV3	RTS

GAU	DC.B	0
DRO	DC.B	0

GAUCHE	MOVE.L	#IMG3+$80,ADS
	MOVE.B	#1,GAU
	TST.B	DRO
	BEQ.S	GAUC1
	CLR.W	KKK
	CLR.B	DRO
GAUC1	BSR	FVT
	MOVE.L	DEC2,D1
	SUB.L	DEC,D1
	CMP.W	#140,D1
	BLE.S	CV6
	ADD.L	D0,DEC
CV6	ADD.L	D0,DEC2
	CMP.L	#320,DEC
	BGT.S	CV2	
	RTS
CV2	SUBQ.W	#2,KKK
	BPL.S	CV8
	CLR.W	KKK
CV8	MOVE.L	#320,DEC
	CMP.L	#640-80,DEC2
	BLE.S	CV4
	MOVE.L	#640-80,DEC2
	CLR.W	KKK
CV4	CLR.W	GAU
	RTS
FVT	BTST	#0,TOUC2+1
	BEQ.S	HAUT
	MOVE.W	KKK,D0
	ADDQ.W	#1,D0
	CMP.W	#EFU-VIT,D0
	BNE.S	DCF
	MOVEQ	#EFU-VIT-1,D0
DCF	MOVE.W	D0,KKK
	MOVE.B	VIT(PC,D0.W),D0
	EXT.W	D0
	EXT.L	D0
	RTS
HAUT	MOVEQ	#3,D0
	RTS
KKK	DC.W	0
VIT	DC.B	3
	dc.b	4
	DC.B	5
	dc.b	6
	DC.B	7
	dc.b	8
	dc.b	9
	dc.b	10
	dc.b	11
	dc.b	12
EFU	EVEN
ADS	DC.L	0
DN0	DC.L	0,0
MSK	DS.B	$28*$42
*
* Fichier inclu sur la diskette...
*
IMG1	INCBIN	"a:\JOYSTICK\ROAD.NEO"
IMG2	INCBIN	"a:\JOYSTICK\WORK.NEO"
IMG3	INCBIN	"a:\JOYSTICK\EXEMPLE.NEO"
RNGMEM

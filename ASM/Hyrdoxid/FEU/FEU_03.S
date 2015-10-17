;essaie de feu en true color:384*70 pixels
;------------------------
;etape 1: afficher 1 ligne de couleur aleatoire(blanc ou noir) en bas de l'ecran
;------------------------
;etape 2:_faire la moyenne des huits pixels entourant le pixel du bas(a+b+c.../8)
;_soustraire 1 a cette moyenne
;_repeter pour toute la largeur et la hauteur du feu
;_chaque pixel possede ainsi ds la tableau une valeur de 0 a 255(=1couleur)
;_proceder de bas en haut ou de haut en bas ...
;------------------------
;etape 3:afficher le feu grace au tableau rempli et a la table de couleurs
;			THE END

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	lea	colors,a0
	move.l	#$fafa00f6,254*4(a0)
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	move.b	$ffffa09,OLD_A09
	bsr	INITS
	bsr	CLS
	bsr	MAKE_YTABLE
	bsr	PREP_PAL
	move.l	#$ff,$ffff9800	
	movem.l	clr,d0-d6/a0-a6
	LEA	CURVE,A6
LOOP
	CLR.L	$FFFF9800
	lea	CURVE+192*2*20,a5
	cmp.l	a5,a6
	blt.s	NO_LEA
	LEA	CURVE,A6
NO_LEA
	bsr.w	LINE1
	bsr.w	DO_TABLEAU	
	bsr.w	AFF_FEU
	bsr	SYNCHRO
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	move.l	#$ff,$ffff9800
NO_ALT
	ADDQ	#1,COMPT_VBL
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE.S	LOOP
	BRA	SORTIE
***************************INITIALISATIONS*********************************************************
INITS
	MOVEC	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR

	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	move.l	$44E.W,OLDXBIOS2
	
	MOVE.L	#XBIOS2,D0
	ANDI.L	#$FFFFFFFF-2,D0
	MOVE.L	D0,AFFECR

	MOVE.L	#XBIOS3,D0
	ANDI.L	#$FFFFFFFF-2,D0
	MOVE.L	D0,WORKECR
	BSR	TRUE_COLOR
	BSR	SYNCHRO
	RTS
SYNCHRO
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	move.b 	affecr+3,$ffff820d.w
	RTS
TRUE_COLOR:
	CLR.B	$FFFF8260.W
	MOVE	#384,$FFFF8210.W	;TAILLE EN MOT
*	MOVE	#384,$FFFF820E.W	;TAILLE EN MOT
	MOVE	#256,$FFFF8266.W	;256=TC
	MOVE	#254,$FFFF8282.W	;NBRE DE DEMI-LINES
	MOVE	#203,$FFFF8284.W	;FIN LIGNE HORIZONTALE
	MOVE	#39,$FFFF8286.W	;DEBUT LIGNE HORIZONTALE
	MOVE	#14,$FFFF8288.W	;FULL GAUCHE	
	MOVE	#175,$FFFF828A.W	;FULL DROIT
	MOVE	#216,$FFFF828C.W	;SYNCHRO HORIZONTAL
	MOVE	#625,$FFFF82A2.W	;NBRE DE CHAMPS
	MOVE	#613,$FFFF82A4.W	;FIN SCREEN
	MOVE	#47,$FFFF82A6.W	;DEBUT ECRAN
	MOVE	#87,$FFFF82A8.W	;FULL HAUT
	MOVE	#567,$FFFF82AA.W	;FULL BAS
	MOVE	#619,$FFFF82AC.W	;SYNCHRO VERTICAL
	MOVE	#385,$FFFF82C0.W	;????
	move	#1,$FFFF82C2.W	;PIXEL OPTIONS
	RTS
*******************************SOUS ROUTINES*****************************************

PREP_PAL
;on met cette couleur car y'a un oubli ds la palette ?!?!
	lea	COLORS,a0
	move.l	#$fafa00f6,254*4(a0)
	move	#11,d4
	move	#5,d5
;converti les couleurs vga en true-color
	lea	COLORS_TAB,a1
	move	#255,d0
	move.l	#$3111,d7		;coupe cache
	movec.l	d7,CACR
.LOOP_COL
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d6
	move.b	(a0),d1		;R(0-255)
	move.b	1(a0),d2		;V(...)
	move.b	3(a0),d3		;B(...)
	asr	#3,d1		;R/8(0-31)
	asr	#2,d2		;V/4(0-63)
	asr	#3,d3		;B/8(0-31)

	asl	d4,d1
	asl	d5,d2
	or	d1,d6
	or	d2,d6
	or	d3,d6
	move	d6,(a1)+
	move	d6,(a1)+
	addq.l	#4,a0
	dbf	d0,.LOOP_COL
	move.l	#$2510,d7		;coupe cache
	movec.l	d7,CACR
	rts

LINE1
;affiche la premiere ligne(celle du bas, qui donne naissance au feu)
	lea	TABLEAU,a0		;+2 pour la bande noire du cote gauche
	moveq	#31,d0		;boucle 48* au lieu de 49 pour bande noire sur le cote droit
	moveq	#5,d1
	move.l	#$3111,d7		;coupe cache
	movec.l	d7,CACR
.FIRST_LINE
	move	(a6),(a0)+
	dbf	d1,.FIRST_LINE
	moveq	#5,d1
	addq	#2,a6
 	dbf	d0,.FIRST_LINE
	move.l	#$2510,d7		;coupe cache
	movec.l	d7,CACR	
	rts
DO_TABLEAU
	move.l	a6,-(sp)
	lea	TABLEAU+(96*2),A0
	lea	-194(a0),a1
	lea	-192(a0),a2
	lea	-190(a0),a3
	lea	2(a0),a4
	lea	194(a0),a5
	lea	192(a0),a6
	lea	-2(a0),a0
;calcul de la moyenne pour chaque point
	moveq	#90,d0		;hauteur de 91 pix
	move	#96-3,d1		;largeur de 96 pix(-les bandes noires)
	addq	#2,a0
	addq	#2,a1
	addq	#2,a2
	addq	#2,a3
	addq	#2,a4
	addq	#2,a5
	addq	#2,a6
	moveq	#0,d5
	move.l	#$3111,d7		;coupe cache
	movec.l	d7,CACR
LOOP_FEU
;prend les valeurs de 8 pts du contour
	move	(a0),d2
	add	(a1),d2
	add	(a2),d2
	add	(a3),d2
	add	(a4),d2
	add	(a5),d2
	add	(a6),d2
	add	-2(a6),d2
	asr	#3,d2		;divise par 8
	subq	#1,d2
	addx	d5,d2
	move	d2,(a6)
	addq	#2,a0	
	addq	#2,a1	
	addq	#2,a2	
	addq	#2,a3	
	addq	#2,a4
	addq	#2,a5	
	addq	#2,a6
	dbf	d1,LOOP_FEU	
	addq	#4,a0
	addq	#4,a1
	addq	#4,a2
	addq	#4,a3
	addq	#4,a4
	addq	#4,a5
	addq	#4,a6
	move	#96-3,d1		;48 pix de large+bandes noires=50
 	dbf	d0,LOOP_FEU
	move.l	#$2510,d7		;coupe cache
	movec.l	d7,CACR
	move.l	(sp)+,a6
	rts

AFF_FEU
	lea	TABLEAU+(96*6),a0
	lea	COLORS_TAB,a1
	move.l	WORKECR,a2
	add.l	#768*119,a2
	move	#91-4,d0
	move.l	#$3111,d7
	movec.l	d7,CACR
.LOOP	
	rept	12
	movem	(a0)+,d1-d7/a3
	move.l	(a1,d1.w*4),d1
	move.l	(a1,d2.w*4),d2
	move.l	(a1,d3.w*4),d3
	move.l	(a1,d4.w*4),d4
	move.l	(a1,d5.w*4),d5
	move.l	(a1,d6.w*4),d6
	move.l	(a1,d7.w*4),d7
	move.l	(a1,a3.w*4),a3
	move.l	d1,(a2)+
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	move.l	d2,(a2)+
	move.l	d3,(a2)+
	move.l	d3,(a2)+
	move.l	d4,(a2)+
	move.l	d4,(a2)+
	move.l	d5,(a2)+
	move.l	d5,(a2)+
	move.l	d6,(a2)+
	move.l	d6,(a2)+
	move.l	d7,(a2)+
	move.l	d7,(a2)+
	move.l	a3,(a2)+
	move.l	a3,(a2)+
	endr
	lea	-768-96*2*4(a2),a2
	dbf	d0,.LOOP
	move.l	#$2510,d7		;coupe cache
	movec.l	d7,CACR
	rts

MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE	#300,D1
	MOVEQ.L	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#768,D2
	DBF	D1,MAKE
	RTS
NEW_VBL
	addq	#1,$466.w
	rte
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	move.l 	workecr,a1
	MOVEQ.L	#0,D1
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
	MOVE.W	#60000,D0
OK
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A1)+
	DBF	D0,OK
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
SORTIE
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
	move.b	OLD_A09,$ffffa09
	move.l	OLD_VBL,$70.w
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

	SECTION DATA
COLORS	INCBIN	C:\UTILS\CODE_UTI.LS\GEN_ASM\FEU\PAL_FEU.HDX
CURVE	INCBIN	C:\UTILS\CODE_UTI.LS\GEN_ASM\FEU\FEU.INL
	SECTION	BSS
COLORS_TAB		DS.B	257*4*2
TABLEAU		DS.B	40000
COMPT_VBL		DS.W	1
OLD_CACR		DS.L	1
OLD_VBL		DS.L	1
OLD_A09		DS.B	1
AFFECR:		DS.L 	1
WORKECR:		DS.L 	1
Y_TABLE		DS.L	400
OLDXBIOS2:		DS.L	1
OLDMODECODE	DS.W	1
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
		EVEN
		DS.B	4
XBIOS2:		DS.B	768*280
		DS.B	4
XBIOS3:		DS.B	768*280
	END																																																																																															 	  																																		  																																																														
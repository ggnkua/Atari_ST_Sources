* ROUT LINE FULL -DSP-
NBR_DROITE=3

	OPT	O+,W-

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE	#32,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	BSR	CLS
	MOVE	#-1,-(SP)		
	MOVE	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE	D0,OLDMODECODE	
	MOVE.L	SP,SAVE_SP

	MOVE.B	#18,$FFFFFC02.W
	MOVE.B	#21,$FFFFFC02.W
	CLR.B	$484.W
	MOVE.B	#5,$FFFF8007.W

* EXCEPTIONS
	MOVE.L	#FIN,$10	;INSTRUCTION ILLEGALE
	MOVE.L	#FIN,$8	;ERREUR BUS
	MOVE.L	#ENABLE,$14;/0
	MOVE.L	#FIN,$C	;ERREUR D'ADRESSE

	BSR.W	VBL
 	BSR.W	INITS
	BSR.W	SYNCHRO
	BSR.W	TRUE_COLOR
	CLR.L	$FFFF9800.W
	BSR.W	CLS_TRUE

* Programme DSP
	move.w	#113,-(sp)		; DSP_RequestUniqueAbility
	trap	#14						; XBios
	addq.l	#2,sp

	move.w	d0,-(sp)			; No Ability
	move.l	#(DSP_END-DSP_CODE)/3,-(sp)	; Longueur en Mots DSP
 	pea.l	DSP_CODE		; Adresse du code binaire
	move.w	#109,-(sp)			; Dsp_ExecProg
	trap	#14						; XBios
	lea.l	12(sp),sp

Connect	move.l	#87654321,$ffffa204.w		;ENVOI VAL
	moveq	#0,d0

Conct_Get	btst.b	#0,$ffffa202.w	;LU ???
	bne.s	DSP_Test
	addq.l	#1,d0
	cmp.l	#100000,d0
	beq.W	FIN
	bra.s	Conct_Get

DSP_Test	
	move.l	$ffffa204.w,d0	;OUI ?

.NOO	BTST.B	#1,$FFFFA202.W	;PLEIN ? OUI
	BEQ.S	.NOO		;NON =>

* INIT EFFECT
	MOVE.L	$70.W,SAVE_VBL
	MOVE.B	$FFFFFA07.W,SAVE_A07
	MOVE.B	$FFFFFA09.W,SAVE_A09

	MOVE.L	#NEW_VBL,$70.W
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA13.W
	CLR.B	$FFFFFA09.W
	CLR.B	$FFFFFA15.W

	MOVEM	CLEAR(PC),A0-A6/D0-D7
	CLR	X_ANGLE
	CLR	Y_ANGLE
	CLR	Z_ANGLE
BOUCLE:
	BSR.W	VBL
;	CLR.L	$FFFF9800.W

* ATTEND LE DSP
LET_GO	MOVE.B	$FFFFA207.W,D0
	CMPI.B	#$99,D0
	BNE.S	LET_GO

	BSR.W	SYNCHRO

********	

	CMPI.B	#1,$FFFFFC02.W
	BEQ.S	.NOY
	;ADDQ	#2,X_ANGLE
	CMPI	#720,X_ANGLE
	BLT.S	.NOX
	CLR	X_ANGLE
.NOX
	;ADDQ	#2,Y_ANGLE
	CMPI	#720,Y_ANGLE
	BLT.S	.NOY
	CLR	Y_ANGLE
.NOY

	ADDQ	#2,Z_ANGLE
	CMPI	#720,Z_ANGLE
	BLT.S	.NOZ
	CLR	Z_ANGLE
.NOZ

	BSR.W	TRIGO

* BIT 0 => RECEIVE REGISTER DATA = 1 (FULL) / 0 (EMPTY) -- READ
* BIT 1 => TRANSMIT DATA REGISTER = 0 (FULL) / 1 (EMPTY) -- WRITE
* BIT 2 => TRANSMITTER READY, BOTH REGISTER ARE READY TO FIGHT !!
	MOVEQ	#9,D0
	MOVEC	D0,CACR

** ENVOI AU DSP LE NBR D'ITERATION
	MOVE	#NBR_DROITE*2,D0
	MOVE.L	D0,$FFFFA204.W

	LEA	VAR_3D,A0
	LEA	$FFFFA206.W,A1

	MOVEQ	#9-1,D0
.LOOP1:
	MOVE	(A0)+,(A1)
	DBF	D0,.LOOP1

** ENVOI POS 3D
	LEA	POSITION(PC),A0

	MOVE	#(NBR_DROITE*2)-1,D0	;NBR DE POINTS A CALCULER
.LOOP4:
	MOVE	(A0)+,(A1)	;X
	MOVE	(A0)+,(A1)	;Y
	MOVE	(A0)+,(A1)	;Z
	DBF	D0,.LOOP4

** ENVOI ADR ECRAN AU DSP
	MOVE.L	WORKECR,$FFFFA204.W

** ATTEND LES RESULTATS DU DSP=>030
	MOVEQ	#9,D0
	MOVEC	D0,CACR

.NOO	BTST.B	#0,$FFFFA202.W	;PLEIN ? OUI
	BEQ.S	.NOO		;NON =>
** RECUPERE INFO/DSP
	lea	$FFFFA206.W,A0

	move	#NBR_DROITE-1,D0
	lea	TAB_DROITES,a3
	lea	XP,a4
	lea	YP,a5
.LOOP3:
	MOVE	(a0),(a3)+	;COEFF
	MOVE	(a0),(a3)+	;X DEP
	MOVE	(a0),(a3)+	;Y DEP
	MOVE	(a0),(a4)+	;X1
	MOVE	(a0),(a5)+	;Y1
	MOVE	(a0),(a4)+	;X2
	MOVE	(a0),(a5)+	;Y2
	MOVE	(a0),(a3)+	;INC X
	MOVE	(a0),(a3)+	;INC Y
	MOVE	(a0),(a3)+	;DIST LIGNE
	MOVE	(a0),(a3)+	;COL DEP
	MOVE	(a0),(a3)+	;COEFF COL
	MOVE	(a0),(a3)+	;INC COL
	MOVE	(a0),(a3)+	;CONDITION
;0:horizontale
;1:verticale
;2:dy>dx
;3:dx>dy


	DBF	D0,.LOOP3	
	MOVEQ	#0,D0
	MOVEC	D0,CACR

	bsr	INIT_FACE
	bsr	LIGNE_TAB
	
	CMPI.B	#56,$FFFFFC02.W
	BNE.S	NO_TIME
	MOVE.L	#$88000088,$FFFF9800.W
NO_TIME	CMPI.B	#57,$FFFFFC02.W
	BNE.W	BOUCLE

VBL:
	move.l	$466.w,d0
VSYNC:	cmp.l	$466.W,D0
	BEQ.S	VSYNC
	RTS

INITS:
	move.l	$44E.W,OLDXBIOS
	
	MOVE.L	#XBIOS2+(120*768),D0
	ANDI.L	#$FFFFFFFD,D0
	MOVE.L	D0,AFFECR

	MOVE.L	#XBIOS3+(120*768),D0
	ANDI.L	#$FFFFFFFD,D0
	MOVE.L	D0,WORKECR
	rts
SYNCHRO:
	MOVE.L	AFFECR(PC),D0
	MOVE.L	WORKECR(PC),AFFECR
	MOVE.L	D0,WORKECR

	MOVE.B	AFFECR+1(PC),$FFFF8201.W
	move.b 	AFFECR+2(PC),$ffff8203.w
	move.b 	AFFECR+3(PC),$ffff820D.w

	RTS

RESTORE:
	MOVE.B	OLDXBIOS+1,$FFFF8201.W
	move.b 	OLDXBIOS+2,$ffff8203.w
	move.b 	OLDXBIOS+3,$ffff820D.w
	RTS

CLS:
	MOVE.L	$44E,A0
	MOVE	#7999,D0
LOOP_CLS:
	CLR.L	(A0)+
	DBF	D0,LOOP_CLS
	RTS

CLS_TRUE:
	MOVEQ	#9,D0
	MOVEC	D0,CACR

	MOVEQ	#0,D1
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE	#(192*245)-1,D0
LOOP_CLS2:
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A1)+
	DBF	D0,LOOP_CLS2
	RTS

TRUE_COLOR:
	CLR.B	$FFFF8260.W
	MOVE	#384,$FFFF8210.W	;TAILLE EN MOT
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
	CLR	$FFFF82C2.W	;PIXEL OPTIONS
	RTS

NEW_VBL:
	ADDQ.L	#1,$466.W	
	RTE

ENABLE:
	RTE

********************************************************
*precalculs trigonometriques			*
*en entree:x_angle,y_angle,z_angle(angle de rotation)  *	
*en sortie:A,B,C,D,E,F,G,H,I*512		       	*				
********************************************************
TRIGO:
	LEA	COS_TAB,A4
	LEA	SIN_TAB,A5
	LEA	X_ANGLE,A6
	MOVE.W	(A6)+,D2	;d2=x angle
	MOVE.W	(A6)+,D1	;d1=y ...
	MOVE.W	(A6)+,D0	;d0=z ...

	MOVE.W	(A5,D2.W),D5	;d5=sinx
	MOVE.W	(A4,D2.W),D4	;d4=cosx
	MOVE.W	(A5,D1.W),D3	;d3=siny
	MOVE.W	(A4,D1.W),D2	;d2=cosy
	MOVE.W	(A5,D0.W),D1	;d1=sinz
	MOVE.W	(A4,D0.W),D0	;d0=cosz

	LEA	VAR_3D,A6		;zone sauvegarde calc intermediaire
	MOVEQ	#9,D7		;nombre de decalages pour/512

	;**********CALCUL DE C************
SP_C
	MOVE	D3,D6		;siny
	NEG	D6		;-siny	
	MOVE	D6,(A6)+
	;**********CALCUL DE F************
SP_F	
	MOVE	D2,D6		;cosy
	MULS	D5,D6		;cosy*sinx
	LSR.L	D7,D6		;/512
	MOVE	D6,(A6)+
	;**********CALCUL DE I************
SP_I
	MOVE	D2,D6		;cosy
	MULS	D4,D6		;cosy*cosx
	LSR.L	D7,D6		;/512
	MOVE	D6,(A6)+		
	;**********CALCUL DE A************
SP_A
	MOVE	D0,D6		;cosz
	MULS	D2,D6		;cosz*cosy
	LSR.L	D7,D6		
	MOVE	D6,(A6)+
	;**********CALCUL DE D************
SP_D
	MOVE	D1,D6		;sinz	
	MULS	D4,D6		;sinz*cosx
	LSR.L	D7,D6
	MOVE	D6,A4

	MOVE	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	LSR.L	D7,D6		
	MULS	D5,D6		;cosz*siny*sinx
	LSR.L	D7,D6
	SUB	A4,D6		;(cosz*siny*sinx)-(sinz*cosx)
	MOVE	D6,(A6)+
	;**********CALCUL DE G************
SP_G
	MOVE	D7,D6		;sinz
	MULS	D5,D6		;sinz*sinx
	LSR.L	D7,D6
	MOVE	D6,A4

	MOVE	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	LSR.L	D7,D6
	MULS	D4,D6		;cosz*siny*cosx
	LSR.L	D7,D6
	ADD	A4,D6		;(cosz*siny*cosx)+(sinz*sinx)
	MOVE	D6,(A6)+
	;**********CALCUL DE B************
SP_B
	MOVE	D1,D6		;sinz		
	MULS	D2,D6		;sinz*cosy
	LSR.L	D7,D6
	MOVE	D6,(A6)+
	;**********CALCUL DE E************
SP_E
	MOVE	D0,D6		;cosz
	MULS	D4,D6		;cosz*cosx
	LSR.L	D7,D6
	MOVE	D6,A4

	MOVE	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny
	LSR.L	D7,D6
	MULS	D5,D6		;sinz*siny*sinx
	LSR.L	D7,D6
	ADD	A4,D6		;(sinz*siny*sinx)+(cosz*cosx)
	MOVE	D6,(A6)+	
	;**********CALCUL DE H*************
SP_H
	MOVE	D0,D6		;cosz
	MULS	D5,D6		;cosz*sinx
	LSR.L	D7,D6	
	MOVE	D6,A4

	MOVE	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny		
	LSR.L	D7,D6
	MULS	D4,D6		;sinz*siny*cosx
	LSR.L	D7,D6
	SUB	A4,D6		;(sinz*siny*cosx)-(cosz*sinx)
	MOVE	D6,(A6)+
	RTS
********************************************************************
LIGNE_TAB
;	move	(a0)+,d1		;COEF
;	move	(a0)+,a2		;xdep
;	move	(a0)+,a2		;ydep
;	move	(a0)+,a5		;incx
;	move	(a0)+,a4		;incy
;	move	(a0)+,d2		;dist ligne
;	move	(a0)+,d4		;col_dep
;	move	(a0)+,d3		;coef col
;	move	(a0)+,d6		;inc col
;	moveq	#0,d5
;0:horizontale: bye...
;1:verticale: incremente juste les y
;2:dy>dx: les x ds le test
;3:dx>dy: les y ds le test	
	lea	TAB_DROITES,a0
	move	9*2(a0),d0
	cmp	#0,d0
	beq	END_LINE
	cmp	#1,d0
	beq.s	VERTICAL
	cmp	#2,d0
	beq	Y_DRAW
	cmp	#3,d0
	beq.s	X_DRAW
	move.l	#$ff000000,$ffff9800
	rts
VERTICAL
	move	YMIN,d1
	move	2(a0),d0		;xdep
	move	4(a0),a6		;ydep
	move	8(a0),a4		;incy
	move	10(a0),d2		;dist ligne
	move	12(a0),d4		;col_dep
	move	14(a0),d3		;coef col
	move	16(a0),d6		;inc col
	lea	XMAX,a0
	lea	XMIN,a1
	lea	XMAX_COL,a2
	lea	XMIN_COL,a3
	move	d3,d7
	move.l	#$ff,$ffff9800
.LOOP2:	
	move	a6,d5
	sub	d1,d5

	cmp.w	(a0,d5.w*2),d0			;x>xmax
	ble.s	.NO_XMAX
	move	d0,(a0,d5.w*2)
	move	d4,(a2,d5.w*2)	
.NO_XMAX
	cmp.w	(a1,d5.w*2),d0			;x<xmin
	bgt.s	.NO_XMIN
	move	d0,(a1,d5.w*2)
	move	d4,(a3,d5.w*2)
.NO_XMIN

  	add.l	a4,a6

	subq	#1,d7
	bge.s	.NO3
	move	d3,d7
	add	d6,d4	;couleur du pix en d4
.NO3
	dbf	d2,.LOOP2
	rts

X_DRAW
	move.l	#$ff0000ff,$ffff9800
	rts
Y_DRAW
	move.l	#$ffff0000,$ffff9800
	rts
********
END_LINE
	move.l	#$ff000,$ffff9800
	rts
**************************
INIT_FACE
	movem.L	CLEAR,a0-a6/d0-d7
	lea	YP,a0		;zone de coord des pts
	move	#(NBR_DROITE*2)-1,d7
	moveq	#-1,d0		;d0=ymax
	move	#$FFF,d1		;d1=ymin
	MOVE.L	#$3111,D6		;cache on	
	MOVEC.L	D6,CACR
;recherche des ymax et ymin et calcul de la hauteur du polygone
TRI_Y
	move.w	(a0,d2.w),d3	
	addq.w	#2,d2
	cmp.w	d3,d1
	ble.s	NO_YMIN
	move.w	d3,d1		;D1=new ymin
NO_YMIN
	cmp.w	d3,d0
	bgt.s	NO_YMAX
	move.w	d3,d0		;D0=new ymax
NO_YMAX
	DBF	d7,TRI_Y

	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		

	move	d0,YMAX
	move	d1,YMIN	
	sub	d1,d0		;D0=hauteur	
	move	d0,HAUTEUR
;initialisation des tableaux des xmin et xmax
	lea	XMAX,a0
	lea	XMIN,a1
	MOVE.L	#$3111,D6		;cache on	
	MOVEC.L	D6,CACR
INIT_X	
	move.w	#-1,(a0)+
	move.w	#$FFF,(a1)+
	dbf	d0,INIT_X
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	rts
*********************************SORTIE*****************************
FIN:	
	MOVE.L	SAVE_SP,SP
	BSR.W	CLS_TRUE
	MOVE.L	SAVE_VBL,$70.W
	MOVE.B	SAVE_A07,$FFFFFA07.W
	MOVE.B	SAVE_A07,$FFFFFA13.W
* VIDE BUFFE CLAVIER
CLEAR_00:	MOVE.B	$FFFFFC02.W,D0
	BTST.B	#0,$FFFFFC00.W
	BNE.S	CLEAR_00
	MOVE.B	SAVE_A09,$FFFFFA09.W
	MOVE.B	SAVE_A09,$FFFFFA15.W

	BSR.W	VBL

	MOVE	OLDMODECODE,-(SP)
	MOVE	#3,-(SP)	
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	MOVE	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		

	MOVE	#105,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP

	BSR.W	VBL
	BSR.W	RESTORE
	BSR.W	CLS
	MOVE.B	#8,$FFFFFC02.W
	MOVE.B	#15,$484.W

	CLR.L	-(SP)
	MOVE	#32,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.L	-(SP)
	TRAP	#1


	SECTION	DATA

COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
DSP_CODE:	INCBIN	E:\DSP\FILL.P56
DSP_END	EVEN
POSITION:	
		DC	0,40,0
		DC	-40,-40,0

		DC	-40,-40,0
		DC	40,-40,0

		DC	40,-40,0
		DC	0,40,0

	SECTION	BSS
HAUTEUR		DS	1
YMAX		DS	1
YMIN		DS	1
XMAX		DS	500
XMIN		DS	500
XMAX_COL		DS	500
XMIN_COL		DS	500
XP		DS	NBR_DROITE*2+2
YP		DS	NBR_DROITE*2+2
TAB_DROITES	DS.W	(10*NBR_DROITE)+100
CLEAR:		DS.L	16
AFFECR:		DS.L	1
SAVE_A07:		DS.B	1
SAVE_A09:		DS.B	1
SAVE_VBL:		DS.L	1
OLDXBIOS:		DS.L	1
WORKECR:		DS.L	1
OLDMODECODE:	DS.L	1
SAVE_SP:		DS.L	1
		DS.L	2000
PILE		DS.L	10

X_ANGLE		DS.W	1
Y_ANGLE		DS.W	1
Z_ANGLE		DS.W	1

VAR_3D		DS.W	9	
		EVEN
		DS.B	4
XBIOS2:		DS.B	(768*240)*2
		DS.B	4
XBIOS3:		DS.B	(768*240)*2
	END
LINE_NEW
	bsr	clr_registers
	lea	XMIN1,a0	
	lea	XMAX1,a1
	move.w	CX1,d6			;x debut
 	move.w 	CX2,d7			;x fin	
	move.w	CY1,d3			;y debut
	move.w	CY2,d4			;y fin
;regarde si la droite est horizontale,si oui casos !!!
	cmp.w	d3,d4
	bne.s	NO_CASOS
	rts
NO_CASOS	
;verifie les distances: si dx>dy ou dy>dx
	sub.w	d3,d4
	bpl.s	NO_SUB1
	neg	d4
NO_SUB1
	sub.w	d6,d7
	bpl.s	NO_SUB22
	neg	d7
NO_SUB22
	cmp.w	d7,d4
	bhi	LIGNEY
***********************CAS DX>DY************************************************
LIGNEX
	clr.b	IND
	move.w	CX1,d6			;x debut
 	move.w 	CX2,d7			;x fin	
	move.w	CY1,d3			;y debut
	move.w	CY2,d4			;y fin
	move.w	d3,d0		
;verifie si xb>xa ou yb>ya
	cmp.w	d6,d7
	bhi.s	NO_SWAPX
	exg	d6,d7
	move.w	d6,CX1
	exg	d3,d4
	move.w	d3,d0
NO_SWAPX	
	cmp.w	d3,d4			
	bhi.s	NO_SWAPY
	exg	d3,d4			
	move.b	#1,IND			;indicateur pour type de pente
NO_SWAPY
;calcul de pente
	moveq	#16,d5
	sub.w	d6,d7
	andi.l	#$ffff,d7
	sub.l	d3,d4
	lsl.l	d5,d4			;de la division
	divu.l	d7,d4
	cmpi.l	#$10000,d4			;au cas ou dx=dy	
	beq	OTHER_TRACE
	move	d4,a2
;calcul de la position du point x de depart
	move.w	CX1,d6
	moveq	#0,d4
	addq	#1,d7
;calcul de la position du point x+y de depart
	MOVE.L	#$3111,D5			;cache on		
	MOVEC.L	D5,CACR
 	moveq.w 	#0,d1			;Compteur de pente
	move.w	YMIN,d5			;D5=YMIN
	cmpi.b	#1,IND
	beq.s	LINE_XB
**********TRACE LIGNE/XA*******
LINE_XA	
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	cmp.w	(a1,d2.w*2),d6			;x>xmax
	ble.s	NO_XMAX
	move.w	d6,(a1,d2.w*2)
NO_XMAX
	cmp.w	(a0,d2.w*2),d6			;x<xmin
	bgt.s	NO_XMIN
	move.w	d6,(a0,d2.w*2)
NO_XMIN
	addq.w	#1,d6			;x suivant
 	add.w 	a2,d1			; pente 
 	addx	d4,d0			;y suivant
 	dbf	d7,LINE_XA
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts
**********TRACE LIGNE/XB*******
LINE_XB
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	cmp.w	(a1,d2.w*2),d6			;x>xmax
	ble.s	NO_XMAX2
	move.w	d6,(a1,d2.w*2)
NO_XMAX2
	cmp.w	(a0,d2.w*2),d6			;x<xmin
	bgt.s	NO_XMIN2
	move.w	d6,(a0,d2.w*2)
NO_XMIN2
	addq.w	#1,d6			;x suivant
 	add.w 	a2,d1			; pente 
	subx	d4,d0			;y suivant
 	dbf	d7,LINE_XB
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts
****************************************************************
OTHER_TRACE
;calcul de la position du point x de depart
	move.w	CX1,d6
;calcul de la position du point x+y de depart
	MOVE.L	#$3111,D5			;cache on		
	MOVEC.L	D5,CACR
 	moveq.w 	#0,d1			;Compteur de pente
	move.w	YMIN,d5			;D5=YMIN
	cmpi.b	#1,IND
	beq.s	LINE_XB3
**********SI PENTE DE 1************************************************
LINE_XA3	
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	cmp.w	(a1,d2.w*2),d6			;x>xmax
	ble.s	NO_XMAX3
	move.w	d6,(a1,d2.w*2)
NO_XMAX3
	cmp.w	(a0,d2.w*2),d6			;x<xmin
	bgt.s	NO_XMIN3
	move.w	d6,(a0,d2.w*2)
NO_XMIN3
	addq.w	#1,d6			;x suivant
 	addq.w	#1,d0			;y suivant
 	dbf	d7,LINE_XA3
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts
**********TRACE LIGNE/XB*******
LINE_XB3
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	cmp.w	(a1,d2*2),d6			;x>xmax
	ble.s	NO_XMAX23
	move.w	d6,(a1,d2.w*2)
NO_XMAX23
	cmp.w	(a0,d2.w*2),d6			;x<xmin
	bgt.s	NO_XMIN23
	move.w	d6,(a0,d2.w*2)
NO_XMIN23
	addq.w	#1,d6			;x suivant
 	subq.w	#1,d0			;y suivant
 	dbf	d7,LINE_XB3
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts
************************CAS DY>DX***********************************************
LIGNEY
	clr.b	IND
	move.w	CX1,d6			;x debut
 	move.w 	CX2,d7			;x fin	
	move.w	CY1,d3			;y debut
	move.w	CY2,d4			;y fin
	move.w	d3,d0
;verifie si xb>xa ou yb>ya
	cmp.w	d6,d7
	bhi.s	NO_SWAPX2
	exg	d6,d7
	move.w	d6,CX1
	exg	d3,d4
	move.w	d3,d0
NO_SWAPX2 				
	cmp.w	d3,d4			
	bhi.s	NO_SWAPY2		
	exg	d3,d4			
	move.b	#1,IND			;indicateur pour type de pente
NO_SWAPY2	 
;calcul de pente
	moveq	#16,d5
	sub.w	d3,d4
	andi.l	#$ffff,d4
	sub.l	d6,d7
	lsl.l	d5,d7			;*65536
	divu.l	d4,d7
	move	d7,a2
;calcul de la position du point x de depart
	moveq	#0,d7
	move.w	CX1,d6
;calcul de la position du point x+y de depart
	MOVE.L	#$3111,D5		;cache on		
	MOVEC.L	D5,CACR
 	moveq.w 	#0,d1			;Compteur de pente
	move.w	YMIN,d5			;D5=YMIN
	cmpi.b	#1,IND
	beq.s	LINE_YB
**********TRACE LIGNE/YA*******
LINE_YA
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	cmp.w	(a1,d2.w*2),d6			;x>xmax
	ble.s	.NO_XMAX3
	move.w	d6,(a1,d2.w*2)
.NO_XMAX3
	cmp.w	(a0,d2.w*2),d6			;x<xmin
	bgt.s	.NO_XMIN3
	move.w	d6,(a0,d2.w*2)
.NO_XMIN3
	addq.w	#1,d0			; y suivant
	add.w 	a2,d1			; pente 
	addx	d7,d6			; x suivant
 	dbf	d4,LINE_YA
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts
**********TRACE LIGNE/YB*******
LINE_YB
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	cmp.w	(a1,d2*2),d6			;x>xmax
	ble.s	NO_XMAX4
	move.w	d6,(a1,d2.w*2)
NO_XMAX4
	cmp.w	(a0,d2*2),d6			;x<xmin
	bgt.s	NO_XMIN4
	move.w	d6,(a0,d2.w*2)
NO_XMIN4
	subq.w	#1,d0			; y suivant
	add.w 	a2,d1			; pente 
	addx	d7,d6			; x suivant
 	dbf	d4,LINE_YB
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts	 	  																																		  																																																														
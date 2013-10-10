 * ROUT LINE FULL -DSP-
NBR_DROITE=3

	OPT	O+,W-

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
	CLR.L	$FFFF9800.W

* ATTEND LE DSP
LET_GO	MOVE.B	$FFFFA207.W,D0
	CMPI.B	#$99,D0
	BNE.S	LET_GO

	BSR.W	SYNCHRO

********	

	CMPI.B	#1,$FFFFFC02.W
	BEQ.S	.NOY
	ADDQ	#2,X_ANGLE
	CMPI	#720,X_ANGLE
	BLT.S	.NOX
	CLR	X_ANGLE
.NOX
	ADDQ	#2,Y_ANGLE
	CMPI	#720,Y_ANGLE
	BLT.S	.NOY
	CLR	Y_ANGLE
.NOY

	*ADDQ	#4,Z_ANGLE
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
	move.l	#$ffff00ff,$ffff9800
** RECUPERE INFO/DSP
	LEA	$FFFFA204.W,A0
	LEA	$FFFFA206.W,A1

	MOVE	#NBR_DROITE-1,D0
.LOOP3:
	MOVE	(A1),D1	;COEFF
	MOVE	(A1),A6	;X DEP
	MOVE	(A1),D6	;Y DEP
	MOVE	(A1),A5	;INC X
	MOVE	(A1),A4	;INC Y
	MOVE	(A1),D2	;DIST LIGNE
	MOVE	(A1),D4	;COL DEP
	MOVE	(A1),D3	;COEFF COL
	MOVE	(A1),A3	;INC COL
*******
	LEA	([WORKECR],A6.W*2),A2
	MULU	#768,D6
	LEA	(A2,D6.L),A2
******
	MOVEQ	#0,D5
	MOVE	D3,D7
.LOOP2:	
	ADD	D1,D5
	BCC.S	.NO2
	ADD.L	A4,A2
.NO2

	SUBQ	#1,D7
	BGE.S	.NO3
	MOVE	D3,D7
	ADD	A3,D4	
.NO3

	CMP	(A2),D4
	BLE.S	.NO
	MOVE	D4,(A2)
.NO

	ADD.L	A5,A2
	DBF	D2,.LOOP2

	DBF	D0,.LOOP3	

	MOVEQ	#0,D0
	MOVEC	D0,CACR

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
	MOVE	#14+8,$FFFF8288.W	;FULL GAUCHE	
	MOVE	#175+8,$FFFF828A.W	;FULL DROIT
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
INIT_FACE
	bsr	CLR_REGISTERS
	lea	DY,a0		;zone de coord des pts
	add.w	d1,a0		;offset de depart
	move.w	#nbpts-1,d7
	move.w	#-1,d0		;d0=ymax
	move.w	#$FFF,d1		;d1=ymin
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
	move.w	d0,YMAX
	move.w	d1,YMIN	
	sub.w	d1,d0		;D0=hauteur	
	move.w	d0,HAUTEUR
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

CLEAR:	DS.L	16
AFFECR:	DS.L	1
SAVE_A07:	DS.B	1
SAVE_A09:	DS.B	1
SAVE_VBL:	DS.L	1
OLDXBIOS:	DS.L	1
WORKECR:	DS.L	1
OLDMODECODE:DS.L	1
SAVE_SP:	DS.L	1
POS_3D:	DS	12*NBR_DROITE

X_ANGLE	DS.W	1
Y_ANGLE	DS.W	1
Z_ANGLE	DS.W	1

VAR_3D	DS.W	9	
	DS.B	4
XBIOS2:	DS.B	(768*240)*2
	DS.B	4
XBIOS3:	DS.B	(768*240)*2
	END
;essaie de mapping by Hawkmoon/OH-

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	BSR	INITS
 	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	MAKE_YTABLE
	BSR	CLR_REGISTERS
LOOP
	rept	1000
	moveq	#4,d0
	divu	#2,d0
	endr
;	CLR.L	$FFFF9800
	BSR.W	MAKE_CUBE
	bsr.w	AFF_FACE	
	BSR.W	SYNCHRO
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$00FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
	BRA	SORTIE
*********************
MAKE_CUBE
*	ADD.W	#4,X_ANGLE
	CMPI.W	#720,X_ANGLE
	BLT.S	NO_STOP
	CLR.W	X_ANGLE
NO_STOP
*	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP2 
	CLR.W	Y_ANGLE
NO_STOP2
;	ADD.W	#4,Z_ANGLE
	move	#60,z_angle
	CMPI.W	#720,Z_ANGLE
	BLT.S	NO_STOP3
	CLR.W	Z_ANGLE
NO_STOP3
	BSR	TRIGO
	LEA	COORD,A0
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#4-1,D0
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
	MOVEQ.W	#9,D6
LOOP_TRIGO
	MOVEM.L	D0/A1-A2,-(SP)		
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	LEA	XDEP,A3
	MOVEM.W	(A3)+,D3-D5
	ASL.L	D6,D3		;xdep*512
	ASL.L	D6,D4		;ydep*512
	ASL.L	D6,D5		;zdep*512
	MOVE.L	D3,A1
	MOVE.L	D4,A2
	MOVE.L	D5,A3

	LEA	VAR_3D,A6
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5

	MULS	(A6)+,D3		;d3=c*xe*512
	MULS	(A6)+,D4		;d4=f*ye*512
	MULS	(A6)+,D5		;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	ASR.L	#8,D5
	
	MOVE.W	#512,D7
	SUB.W	D5,D7		;d7=512*q
				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze

	MULS	(A6)+,D3		;d3=a*xe*512
	MULS	(A6)+,D4		;d4=d*ye*512
	MULS	(A6)+,D5		;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	ADD.L	A1,D5
	DIVS	D7,D5		;d5=new_xe/q

	MULS	(A6)+,D0		;d0=b*xe*512
	MULS	(A6)+,D1		;d1=e*ye*512
	MULS	(A6)+,D2		;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	ADD.L	A2,D2
	DIVS	D7,D2		;d2=new_ye/q
	ADD.W	#192,D5	
	ADD.W	#120,D2
	MOVEM.L	(SP)+,D0/A1-A2
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	DBF	D0,LOOP_TRIGO
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
	MOVEC.L	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	
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

	BSR	SYNCHRO
	BSR	TRUE_COLOR
	RTS
SYNCHRO:
	MOVE.L	AFFECR,D0
	MOVE.L	WORKECR,AFFECR
	MOVE.L	D0,WORKECR

	move.b AFFECR+1,$ffff8201.w
	move.b AFFECR+2,$ffff8203.w
	move.b AFFECR+3,$ffff820D.w
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
*******************************SOUS ROUTINES*****************************************
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
	MOVE.W	#(11520*2)-1,D0
	MOVEQ	#0,D1
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
OK
	MOVE.L	D1,(A0)+
	MOVE.L 	D1,(a1)+
	DBF	D0,OK
	MOVE.L	#$2510,D6		;cache off
	MOVEC.L	D6,CACR		
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d7/a0-a6
	rts
MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE	#250,D1
	MOVEQ.L	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#768,D2
	DBF	D1,MAKE
	RTS
*****************************
AFF_FACE
	moveq	#4-1,d7		;nb pts de la face
	bsr	INIT_FACE
	lea	DX,a0
	lea	DY,a1
	lea	OBJET,a2
	lea	XT,a3
	lea	YT,a4
	moveq	#4-1,d0		;nb droites de la face
.LOOP
	move	(a2)+,d1
	move	(a2),d2
	move	(a0,d1.w*2),XA
	move	(a1,d1.w*2),YA
	move	(a0,d2.w*2),XB
	move	(a1,d2.w*2),YB
	move	(a3,d1.w*2),XT1
	move	(a4,d1.w*2),YT1
	move	(a3,d2.w*2),XT2
	move	(a4,d2.w*2),YT2
	bsr	WRITE_TABLE
	dbf	d0,.LOOP
	bsr	MAP_PIC
	rts
*******************************
WRITE_TABLE
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	clr,d0-d7/a0-a6
	move	XA,d0
	move	YA,d1
	move	XB,d2
	move	YB,d3
	move	XT1,d4
	move	YT1,d5
	move	XT2,d6
	move	YT2,d7
;si ya=yb bye !!!
	cmp	d3,d1
	beq	CASOS
;regarde si la droite sera en X_MIN ou X_MAX
	cmp	d1,d3
	bgt.s	.NO_XMIN
	lea	XMIN,a0
	exg	d1,d3
	exg	d0,d2
	exg	d4,d6
	exg	d5,d7
	jmp	.NO_XMAX
.NO_XMIN
	lea	XMAX,a0
.NO_XMAX
CASOS
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*******************************
INIT_FACE
;recherche de ymax et ymin et calcul de la hauteur
	movem.l	clr,d0/d2-d6/a0-a6
	lea	DY,a0		;zone de coord des pts
	moveq	#-1,d0		;d0=ymax
	move	#$FFF,d1		;d1=ymin
	MOVE.L	#$3111,D6		;cache on	
	MOVEC.L	D6,CACR
TRI_Y
	move	(a0,d2.w),d3	
	addq	#2,d2
	cmp	d3,d1
	ble.s	NO_YMIN
	move	d3,d1		;D1=new ymin
NO_YMIN
	cmp	d3,d0
	bgt.s	NO_YMAX
	move	d3,d0		;D0=new ymax
NO_YMAX
	dbf	d7,TRI_Y
	move.l	#$2510,D6		;cache off	
	movec.l	D6,CACR		
	move	d0,YMAX
	move	d1,YMIN	
	sub	d1,d0		;D0=hauteur	
	move	d0,HAUTEUR
	rts
****************************
MAP_PIC
	move.l	#$ff,$ffff9800
	movem.l	clr,d0-d7/a0-a6
	moveq	#12,d7
	lea	XMIN,a0
	lea	XMAX,a1
	move.l	WORKECR,a2
	lea	Y_TABLE,a3
	moveq	#0,d1
	move	YMIN,d1
	add.l	(a3,d1.w*4),a2	;a2=ecran+ymin*768
	add	#2,d1
	mulu	#6,d1
	add.l	d1,a0		;a0=xmin+ymin*6
	add.l	d1,a1		;a1=xmax+ymin*6
	move	HAUTEUR,d0
	subq	#4,d0		;pour le dbf
	cmp	#1,d0
	ble	BYE
.LOOP
	dbf	d0,.LOOP
BYE
	rts
****************************ROUTINE DE CALCUL************************************
********************************************************
*precalculs trigonometriques			*
*en entree:x_angle,y_angle,z_angle(angles de rotation) *	
*en sortie:(A,B,C,D,E,F,G,H,I)*512		*				
********************************************************


TRIGO
	MOVEM.L	D0-D7/A4-A6,-(SP)
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
	MOVEQ	#9,D7
	;**********CALCUL DE C************
SP_C
	MOVE.W	D3,D6		;siny
	NEG.W	D6		;-siny	
	MOVE.W	D6,(A6)+
	;**********CALCUL DE F************
SP_F	
	MOVE.W	D2,D6		;cosy
	MULS	D5,D6		;cosy*sinx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+
	;**********CALCUL DE I************
SP_I
	MOVE.W	D2,D6		;cosy
	MULS	D4,D6		;cosy*cosx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+		
	;**********CALCUL DE A************
SP_A
	MOVE.W	D0,D6		;cosz
	MULS	D2,D6		;cosz*cosy
	ASR.L	D7,D6		
	MOVE.W	D6,(A6)+
	;**********CALCUL DE D************
SP_D
	MOVE.W	D1,D6		;sinz	
	MULS	D4,D6		;sinz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6		
	MULS	D5,D6		;cosz*siny*sinx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(cosz*siny*sinx)-(sinz*cosx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE G************
SP_G
	MOVE.W	D7,D6		;sinz
	MULS	D5,D6		;sinz*sinx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6
	MULS	D4,D6		;cosz*siny*cosx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(cosz*siny*cosx)+(sinz*sinx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE B************
SP_B
	MOVE.W	D1,D6		;sinz		
	MULS	D2,D6		;sinz*cosy
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+
	;**********CALCUL DE E************
SP_E
	MOVE.W	D0,D6		;cosz
	MULS	D4,D6		;cosz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny
	ASR.L	D7,D6
	MULS	D5,D6		;sinz*siny*sinx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(sinz*siny*sinx)+(cosz*cosx)
	MOVE.W	D6,(A6)+	
	;**********CALCUL DE H*************
SP_H
	MOVE.W	D0,D6		;cosz
	MULS	D5,D6		;cosz*sinx
	ASR.L	D7,D6	
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny		
	ASR.L	D7,D6
	MULS	D4,D6		;sinz*siny*cosx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(sinz*siny*cosx)-(cosz*sinx)
	MOVE.W	D6,(A6)+
	MOVEM.L	(SP)+,D0-D7/A4-A6
	RTS
SORTIE
	MOVE.L	OLD_VBL,$70.W
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
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
PIC		INCBIN	F:MAPPING.TPI
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	

OBJET	DC	0,1,2,3,0
COORD	
pt0	DC	40,40,0
pt1	DC	-40,40,0
pt2	DC	-40,-40,0
pt3	DC	40,-40,0
*****************
XT		DC	33,1,1,33
YT		DC	1,1,33,33
XDEP		DC.W	0
YDEP		DC.W	0
ZDEP		DC.W	0
X_ANGLE		DC.W	0
Y_ANGLE		DC.W	0
Z_ANGLE		DC.W	0
	SECTION	BSS
XT1		DS	1
XT2		DS	1
YT1		DS	1
YT2		DS	1
XA		DS	1
XB		DS	1
YA		DS	1
YB		DS	1
YMAX		DS	1
YMIN		DS	1
HAUTEUR		DS	1
OLD_VBL		DS.L	1
OLD_CACR		DS.L	1
IND		DS.B	1
SAVE		DS	10
AFFECR:		DS.L 	1
WORKECR:		DS.L 	1
OLDXBIOS2:		DS.L	1
OLDMODECODE	DS	1
DX		DS	50
DY		DS	50
VAR_3D		DS	9
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
		DS.B	4
XBIOS2:		DS.B	768*250
		DS.B	4
XBIOS3:		DS.B	768*250
XMIN		DS	300
XMAX		DS	300
Y_TABLE		DS.L	300
	END																		
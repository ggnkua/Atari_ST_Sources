	OPT	O+,W-,D+
xtaille=100
ytaille=100

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

	MOVE.B	#18,$FFFFFC02.W
	MOVE.B	#21,$FFFFFC02.W
	CLR.B	$484.W
	MOVE.B	#5,$FFFF8007.W

* SAVE EXCEPTIONS
	MOVE.L	$10,ILLEGAL
	MOVE.L	$8,BUS
	MOVE.L	$14,DIVIDE
	MOVE.L	$C,ADRESSE
* INSTAL EXCEPTIONS
	MOVE.L	#FIN,$10	;INSTRUCTION ILLEGALE
	MOVE.L	#FIN,$8	;ERREUR BUS
	MOVE.L	#ENABLE,$14;/0
	MOVE.L	#FIN,$C	;ERREUR D'ADRESSE

	BSR.W	VBL
	CLR.L	$FFFF9800.W
 	BSR.W	INITS
	BSR.W	SYNCHRO
	BSR.W	CLS_TRUE
	BSR.W	TRUE_COLOR

* INIT INTERRUPTIONS
	MOVE.L	$70.W,SAVE_VBL
	MOVE.B	$FFFFFA07.W,SAVE_A07
	MOVE.B	$FFFFFA09.W,SAVE_A09

	MOVE	#11,NEWX
	MOVE	#11,NEWY
	BSR.W	VBL
	MOVEM	CLEAR,A0-A6/D0-D7
BOUCLE:
	BSR.W	VBL
	CLR.L	$FFFF9800.W
	cmpi.b	#78,$ffffc02
	bne.s	NO_PLUS
	addq	#4,NEWX
	addq	#4,NEWY
NO_PLUS
	cmpi.b	#74,$ffffc02
	bne.s	NO_MINUS
	subq	#4,NEWX
	subq	#4,NEWY
NO_MINUS
	move	#xtaille,d0
	move	newx,d1
	cmp.w	d0,d1
	bls	OTHER_ZOOM
	bsr	zoom_IN
	bra.s	OTHER_ZOOM2
OTHER_ZOOM
	bsr	zoom_OUT
OTHER_ZOOM2
	BSR.W	SYNCHRO
	MOVE.L	#$FF,$FFFF9800
	CMPI.B	#57,$FFFFFC02.W
	BNE.S	BOUCLE
	BRA	FIN

***********************SOUS ROUTINES*********************************************************************

VBL:
	move.l	$466.w,d0
VSYNC:	cmp.l	$466.W,D0
	BEQ.S	VSYNC
	RTS

INITS:
	move.l	$44E.W,OLDXBIOS
	
	MOVE.L	#XBIOS2,D0
	ANDI.L	#$FFFFFFFD,D0
	MOVE.L	D0,AFFECR

	MOVE.L	#XBIOS3,D1
	ANDI.L	#$FFFFFFFD,D1
	MOVE.L	D1,WORKECR
	RTS

SYNCHRO:
	MOVE.L	WORKECR,D0
	MOVE.L	AFFECR,WORKECR
	MOVE.L	D0,AFFECR

	MOVE.B	AFFECR+1,$FFFF8201.W
	move.b 	AFFECR+2,$ffff8203.w
	move.b 	AFFECR+3,$ffff820D.w
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
	MOVEQ	#0,D1
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE	#(192*245)-1,D0

	MOVEQ	#9,D7
	MOVEC	D7,CACR
LOOP_CLS2:
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A1)+
	DBF	D0,LOOP_CLS2

	MOVEQ	#1,D7
	MOVEC	D7,CACR
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
	clr	$FFFF82C2.W	;PIXEL OPTIONS
	RTS
NEW_VBL:
	ADDQ.L	#1,$466.W	
	RTE

ENABLE:
	RTE
ZOOM_OUT
;calcul des coefficients x et y
	move	#xtaille,d0
	move	#ytaille,d1
	move	newx,d2
	move	newy,d3
	moveq	#0,d6
	moveq	#0,d7
	move	#384,d6
	sub	d0,d6
	subq	#1,d6
	lsl.l	d6
	move	#16,d4
	lsl.l	d4,d2
	lsl.l	d4,d3
	divu	d0,d2		;facteur x
	divu	d1,d3		;facteur y
	moveq	#0,d5
	lea	PIC+128,a0
	move.l	WORKECR,a1
	move	#ytaille,d0
	MOVE	#$3111,D4
	MOVEC	D4,CACR
	moveq	#0,d4
LOOP_Y
	moveq	#0,d4
	move	#xtaille,d1
	move.l	a1,a3
	add.l	d7,a3
LOOP_X
	add	d2,d4
	bcc.s	NO_NEW_X_ECRAN
	move	(a0),(a3)+
NO_NEW_X_ECRAN
	addq	#2,a0
	dbf	d1,LOOP_X
	add	d3,d5
	bcc.s	NO_Y_ECRAN
	add.l	#384*2,d7
NO_Y_ECRAN	
	add.l	d6,a0
	dbf	d0,LOOP_Y
	MOVE	#$2510,D7
	MOVEC	D7,CACR
	rts
ZOOM_IN
	move	#xtaille,d0
	move	#ytaille,d1
	move	newx,d2
	move	newy,d3
	moveq	#0,d6
	moveq	#0,d7
	move	#384,d6
	sub	d2,d6
	subq	#1,d6
	lsl.l	d6
	move	#16,d4
	lsl.l	d4,d0
	lsl.l	d4,d1
	divu	d2,d0		;facteur x
	divu	d3,d1		;facteur y
	moveq	#0,d4
	moveq	#0,d5
	lea	PIC+128,a0
	move.l	WORKECR,a1
	move	newy,d2
	MOVE	#$3111,D7
	MOVEC	D7,CACR
	moveq	#0,d7
LOOP_Y2
	moveq	#0,d4
	move.l	a0,a2
	move	newx,d3
	add.l	d7,a2
LOOP_X2
	add	d0,d4
	bcc.s	NO_NEW_X_PIC
	addq	#2,a2
NO_NEW_X_PIC
	move	(a2),(a1)+
	dbf	d3,LOOP_X2
	add	d1,d5
	bcc.s	NO_Y_PIC
	add.l	#384*2,d7
NO_Y_PIC
	add.l	d6,a1
	dbf	d2,LOOP_Y2
	MOVE	#$2510,D7
	MOVEC	D7,CACR
	rts
***********************SORTIE*********************************************************************
FIN:	BSR.W	CLS_TRUE
* RESTORE INTERRUPTIONS
	BSR.W	VBL
	MOVE.L	SAVE_VBL,$70.W
	MOVE.B	SAVE_A07,$FFFFFA07.W
	MOVE.B	SAVE_A07,$FFFFFA13.W
* VIDE BUFFE CLAVIER
CLEAR_00:	MOVE.B	$FFFFFC02.W,D0
	BTST.B	#0,$FFFFFC00.W
	BNE.S	CLEAR_00
	MOVE.B	SAVE_A09,$FFFFFA09.W
	MOVE.B	SAVE_A09,$FFFFFA15.W
* RESTORE EXCEPTIONS
	MOVE.L	ILLEGAL,$10
	MOVE.L	BUS,$8
	MOVE.L	DIVIDE,$14
	MOVE.L	ADRESSE,$C

	MOVE	#105,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP

	BSR.W	VBL
	MOVE	OLDMODECODE,-(SP)
	MOVE	#3,-(SP)	
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	MOVE	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		

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
PIC		INCBIN	"c:\utils\code_uti.ls\gen_asm\zoom\oeil.TPI"
	SECTION	BSS
NEWX		DS.W	1
NEWY		DS.W	1
CLEAR:		DS.L	16
SAVE_A07:		DS.B	1
SAVE_A09:		DS.B	1
SAVE_VBL:		DS.L	1
OLDXBIOS:		DS.L	1
WORKECR:		DS.L	1
AFFECR:		DS.L	1 
OLDMODECODE:	DS.L	1
BUS:		DS.L	1
DIVIDE:		DS.L	1
ILLEGAL:		DS.L	1
ADRESSE:		DS.L	1
		DS.B	4
XBIOS2:		DS.B	1536*260
		DS.B	4
XBIOS3:		DS.B	1536*260
	END	
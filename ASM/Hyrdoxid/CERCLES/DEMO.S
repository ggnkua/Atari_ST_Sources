;7 cercles 1 plan ... ~130 pix de diametre
;by  Hawkmoon/Hydroxid
;last update 02/01/95

	section 	TEXT

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	move.l	$70.w,OLD_VBL
	move.b	$ffffa09,OLD_A09
	move.b	$ffffa07,OLD_A07
	bsr	INITS
 	bsr	CLS
	bsr	CLR_REGISTERS
	bsr	MAKE_YTABLE
	bsr	CLR_REGISTERS
	move.l	#NEW_VBL,$70.w
	bsr	GEN_CODE
	bsr	PREC_CERCLE
	bsr	PAL_CERCLES	
	clr	COMPT_VBL
	move.b	#$1,$ffffa07
	move.b	#$40,$ffffa09
LOOP
	clr.l	$ffff9800
	addq	#1,COMPT_VBL
	lea	EFFA2,a0
	cmpi.w	#192,DECA
	ble.s	GREAT2
	lea	EFFA,a0
	subq	#1,DECA
GREAT2
	jsr	(a0)
	cmpi.b	#56,$ffffc02
	bne.s	NO_ALT2
	MOVE.L	#$550000,$FFFF9800
NO_ALT2
	bsr	MAKE_PTS
	bsr	CERCLES
	cmpi	#700,COMPT_VBL
	blt.s	NO_INTERPOL
	bsr	INTERPOL
NO_INTERPOL
	bsr	SYNCHRO
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$00FF,$FFFF9800
NO_ALT
	bsr	VBL
	CMPI	#930,COMPT_VBL
	BNE.S	LOOP
	
END
	BSR	FADE_TO_BLANC
	BSR	CLS
	BSR	AFF_IMG
	BSR	FADE_TO_PAL
	BSR	VBL
	CLR.W	COMPT_VBL		
LOOP2
	BSR	VBL
	ADD	#1,COMPT_VBL
	CMPI.W	#300,COMPT_VBL
	BNE.S	LOOP2
	BSR	CLS
	BRA	LOOP
	BRA	SORTIE
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
	SUB.L	#50*768,D0
	MOVE.L	D0,WORKECR2

	BSR	SYNCHRO
	BSR	VGA
	RTS
*******************************SOUS ROUTINES*****************************************
INTERPOL
	lea	XC,a0
	move	#13,d0
	MOVE.L	#$3111,D7		;coupe cache
	MOVEC.L	D7,CACR
LOOP_INTER
	move	(a0),d1
	move	4(a0),d3

	cmpi.w	#0,d1
	beq.s	SUITE1
	ble.s	NO_SUB
	sub.w	#1,(a0)
	bra.s	SUITE1
NO_SUB	
	add.w	#1,(a0)
SUITE1
	cmpi.w	#0,d3
	beq.s	SUITE2
	ble.s	NO_SUB2
	sub.w	#1,4(a0)
	bra.s	SUITE2
NO_SUB2
	add.w	#1,4(a0)
SUITE2
	addq.l	#6,a0
	dbf	d0,LOOP_INTER
	MOVE.L	#$2510,D7		;coupe cache
	MOVEC.L	D7,CACR
	rts
PAL_CERCLES
	lea	PAL,a0
	lea	$ffff9800,a1
	move	#15,d0
PAL2
	move.l	(a0)+,(a1)+
	dbf	d0,PAL2
	bsr	VBL
	rts

FADE_TO_BLANC
	lea	$ffff9800,a0
	lea	PAL,a1
	move	#62,d1
	move	#16,d0	
	move.b	#0,FADE_COMPT
	MOVE.L	#$3111,D7		;coupe cache
	MOVEC.L	D7,CACR
	bsr	VBL
LOOP_BLANC
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6	
	move.b	FADE_COMPT,d6
	move.b	3(a1),d3
	add	d6,d3
	cmpi.w	#$fe,d3
	bls.s	STOP4
	move.w	#$ff,d3
STOP4
	move.b	1(a1),d4
	add	d6,d4
	cmpi.w	#$fe,d4
	bls.s	STOP5
	move.w	#$ff,d4
STOP5
	move.b	(a1),d5
	add	d6,d5
	cmpi.w	#$fe,d5
	bls.s	STOP6
	move.w	#$ff,d5
STOP6
	asl.l	#8,d4
	asl.l	#8,d4
	or.l	d4,d3
	asl.l	#8,d5
	asl.l	#8,d5
	asl.l	#8,d5
	or.l	d5,d3
	move.l	d3,(a0)+
	addq.l	#4,a1
	dbf	d0,LOOP_BLANC
	bsr	VBL
	lea	$ffff9800,a0
	lea	PAL,a1
	move	#16,d0	
	add.b	#4,FADE_COMPT
	dbf	d1,LOOP_BLANC
	MOVE.L	#$2510,D7		;coupe cache
	MOVEC.L	D7,CACR
	rts
FADE_TO_PAL	
	moveq	#0,d6
	lea	$ffff9800,a0
	lea	MOON,a1
	move	#62,d0
	move.l	#60,d1
	move.b	#0,FADE_COMPT
	MOVE.L	#$3111,D7		;coupe cache
	MOVEC.L	D7,CACR
	bsr	VBL	

FADE	
	move.l	#$ff,d3
	move.l	#$ff,d4
	move.l	#$ff,d5
	move.b	FADE_COMPT,d6
	sub	d6,d3
	cmp.b	3(a1),d3
	bhi.s	STOP
	move.b	3(a1),d3
STOP
	sub	d6,d4
	cmp.b	1(a1),d4
	bhi.s	STOP2
	move.b	1(a1),d4
STOP2
	sub	d6,d5
	cmp.b	(a1),d5
	bhi.s	STOP3
	move.b	(a1),d5
STOP3
	asl.l	#8,d4
	asl.l	#8,d4
	or.l	d4,d3
	asl.l	#8,d5
	asl.l	#8,d5
	asl.l	#8,d5
	or.l	d5,d3
	move.l	d3,(a0)+
	addq.l	#4,a1
	dbf	d1,FADE

	bsr	VBL
	lea	$ffff9800,a0
	move.l	#60,d1
	lea	MOON,a1
	add.b	#4,FADE_COMPT
	dbf	d0,FADE
	MOVE.L	#$2510,D7		;coupe cache
	MOVEC.L	D7,CACR
	rts
PREC_CERCLE
	MOVE.L	#$3111,D7		;active cache
	MOVEC.L	D7,CACR
	move.w	#14,RAYON
	lea	XMAX1,a1
	lea	XMIN1,a2
	lea	XMAX_AD,a6
	lea	XMIN_AD,a4			
	move	#120-15-1,d3
	lea	14*4(a6),a6
	lea	14*4(a4),a4
BOUCLE_CERCLE
	move.w	RAYON,d0
	moveq	#0,d1
	moveq	#0,d2		;y=d2
	move	#3,a5
	sub.w	d1,a5		;c=d3
	move	#192,d1		;centre x 
	move	RAYON,a0		;centre y
**
Loop_Trace
	cmp.w	d2,d0		;si y#x
	beq.s	Equal
	move	d1,d6
	add	d0,d6
	move	a0,d7
	add	d2,d7
 	move	d6,(a1,d7.w*2)		;sauve x/y
	move	d1,d6
	add	d2,d6
	move	a0,d7
	sub	d0,d7
	move	d6,(a1,d7.w*2)		;sauve x/y
	move	d1,D6
	sub	d0,d6
	move	a0,D7
	sub	d2,d7
	move	d6,(a2,d7.w*2)		;sauve x/y
	move	d1,D6
	sub	d2,d6
	move	a0,D7
	add	d0,d7
	move	d6,(a2,d7.w*2)		;sauve x/y
Equal
	tst.w	d2			;si y#0
	beq.s	Equal2
	move	d1,d6
	add	d0,d6
	move	a0,d7
	sub	d2,d7
	move	d6,(a1,d7.w*2)		;sauve x/y
	move	d1,d6
	sub	d2,d6
	move	a0,d7
	sub	d0,d7
	move	d6,(a2,d7.w*2)		;sauve x/y
	move	d1,d6
	sub	d0,d6
	move	a0,d7
	add	d2,d7
	move	d6,(a2,d7.w*2)		;sauve x/y
	move	d1,D6
	add	d2,d6
	move	a0,D7
	add	d0,d7
	move	d6,(a1,d7.w*2)		;sauve x/y
Equal2
	tst.w	a5
;si c<0 c=c+4*y+6
	bpl.s	Great
	lea	6(a5,d2.w*4),a5
	bra.s	Less
Great
;sinon c=c-4*x+4*y+10=c+4(y-x)+10  y=d2 x=d0
	move	d2,d4
	sub	d0,d4
	lea	10(a5,d4.w*4),a5
;x=x-1
	subq	#1,d0
Less
;y=y+1
	addq	#1,d2
	cmp	d2,d0
	bge	Loop_Trace
	
	moveq	#0,d0
	move.l	a1,(a6)+
	move.l	a2,(a4)+
	move.w	RAYON,d0
	lea	(a1,d0.w*4),a1
	lea	(a2,d0.w*4),a2
	addq	#1,RAYON
	dbf	d3,BOUCLE_CERCLE
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	rts
********************
CERCLES
	bsr	Calc_Ray

	move	#0,d1
	cmpi	#800,COMPT_VBL
	ble.s	NO_ZOOM
	move	#6,d1
	cmpi.l	#512*120,Z_DEP
	bgt.s	NO_ZOOM
	add.l	#512,Z_DEP
NO_ZOOM

	move	DX,CX 
	move	DY,CY 
	move	Ray1,Rayon
	move	d1,PLAN
	move	DY,d4
	move	RAYON,d5
	sub	d5,d4
	move	d4,YMIN
	bsr	REMPLI

	cmpi	#800,COMPT_VBL
	bgt	PAS_CERCLE
	move	DX+4,CX 
	move	DY+4,CY
	move	Ray2,Rayon
	move	#2,PLAN
	move	DY+4,d4
	move	RAYON,d5
	sub	d5,d4
	move	d4,YMIN
	bsr	REMPLI

	move	DX+8,CX 
	move	DY+8,CY
	move	Ray3,Rayon
	move	#4,PLAN
	move	DY+8,d4
	move	RAYON,d5
	sub	d5,d4
	move	d4,YMIN
	bsr	REMPLI

	move	DX+12,CX 
	move	DY+12,CY
	move	Ray4,Rayon
	move	#0,PLAN
	move	DY+12,d4
	move	RAYON,d5
	sub	d5,d4
	move	d4,YMIN
	bsr	REMPLI

	move	DX+16,CX 
	move	DY+16,CY
	move	Ray5,Rayon
	move	#2,PLAN
	move	DY+16,d4
	move	RAYON,d5
	sub	d5,d4
	move	d4,YMIN
	bsr	REMPLI

	move	DX+20,CX 
	move	DY+20,CY
	move	Ray6,Rayon
	move	#4,PLAN
	move	DY+20,d4
	move	RAYON,d5
	sub	d5,d4
	move	d4,YMIN
	bsr	REMPLI

	move	DX+24,CX 
	move	DY+24,CY
	move	Ray7,Rayon
	move	#2,PLAN
	move	DY+24,d4
	move	RAYON,d5
	sub	d5,d4
	move	d4,YMIN
	bsr	REMPLI
PAS_CERCLE	
	rts
SYNCHRO:
	MOVE.L	AFFECR,D0
	MOVE.L	WORKECR,AFFECR
	MOVE.L	D0,WORKECR
	SUB.L	#50*768,D0
	MOVE.L	D0,WORKECR2

	move.b AFFECR+1,$ffff8201.w
	move.b AFFECR+2,$ffff8203.w
	move.b AFFECR+3,$ffff820D.w
	RTS
VGA:
	MOVE	#192,$FFFF8210.W	;TAILLE EN MOT
	MOVE	#192,$FFFF820E.W	;TAILLE EN MOT(ECRAN VIRTUEL)
	MOVE	#16,$FFFF8266.W	;16=VGA & 256=TC
	MOVE	#254,$FFFF8282.W	;NBRE DE DEMI-LINES
	MOVE	#203-10,$FFFF8284.W	;FIN LIGNE HORIZONTALE
	MOVE	#47-10,$FFFF8286.W	;DEBUT LIGNE HORIZONTALE
	MOVE	#764,$FFFF8288.W	;FULL GAUCHE	
	MOVE	#157,$FFFF828A.W	;FULL DROIT
	MOVE	#216,$FFFF828C.W	;SYNCHRO HORIZONTAL
	MOVE	#625,$FFFF82A2.W	;NBRE DE CHAMPS
	MOVE	#613,$FFFF82A4.W	;FIN SCREEN
	MOVE	#47,$FFFF82A6.W	;DEBUT ECRAN
	MOVE	#85,$FFFF82A8.W	;FULL HAUT
	MOVE	#566,$FFFF82AA.W	;FULL BAS
	MOVE	#619,$FFFF82AC.W	;SYNCHRO VERTICAL
	MOVE	#385,$FFFF82C0.W	;????
	CLR	$FFFF82C2.W	;PIXEL OPTIONS	
	RTS
CALC_RAY
	lea	XC,a0
	lea	NEW_Z,a1
	lea	RAY1,a2
	move	#6,d6
	moveq	#9,d7
	MOVE.L	#$3111,D0		;coupe cache
	MOVEC.L	D0,CACR
LOOP_RAY
	moveq	#0,d1
	moveq	#0,d2
	move	2(a0),d1
	move	8(a0),d2
	move.l	(a1),d4
	asl.l	#8,d1
	asl.l	#8,d2
	move.l	#131072,d3
	sub.l	d4,d3		;512-2*ZE=Q*512*256
	asr.l	d7,d3
	divs	d3,d1		;Y1=Y/Q
	divs	d3,d2		;Y2=Y/Q
	sub	d1,d2
	lea	12(a0),a0
	addq.l	#8,a1
	move	d2,(a2)+
	dbf	d6,LOOP_RAY
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	rts
EFFA
	move.l	WORKECR,a0
	lea	768*20(a0),a0
	moveq	#0,d1
	move	#199,d0
	MOVE.L	#$3111,D7		;active cache
	MOVEC.L	D7,CACR
CLR_2PL
ASM	set	48
	rept	21
	move.l	d1,ASM(a0)
	move.w	d1,ASM+4(a0)
ASM	set	ASM+16
	endr
	lea	768(a0),a0
	dbf	d0,CLR_2PL
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	rts
EFFA2
	move.l	WORKECR,a0
	lea	768*20(a0),a0
	moveq	#0,d1
	move	#199,d0
	MOVE.L	#$3111,D7		;active cache
	MOVEC.L	D7,CACR
CLR_2PL2
ASM	set	32
	rept	21
	move.l	d1,ASM(a0)
	move.w	d1,ASM+4(a0)
ASM	set	ASM+16
	endr
	lea	768(a0),a0
	dbf	d0,CLR_2PL2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	rts
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
	MOVE.L	WORKECR,A1
	MOVE.W	#(11520*4)-1,D0
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
	movem.l	clr,d0-d6/a0-a6
	rts
MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE	#280,D1
	MOVEQ.L	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#768,D2
	DBF	D1,MAKE
	RTS
REMPLI
	lea	Y_TABLE,a4
	move.l	WORKECR2,a2
	add	PLAN,a2
	move	RAYON,d1
	lea	XMAX_AD,a0
	lea	XMIN_AD,a5
	move.l	(a0,d1.w*4),a3
	move.l	(a5,d1.w*4),a1

	asl	d1		;rayon*2=hauteur du cercle
	move	YMIN,d0
	move	#70,d3
;clipping y
	cmpi	#70,d0
	bhi.s	NO_CLIP_Y1
	sub	d0,d3
	lea	(a3,d3.w*2),a3
	lea	(a1,d3.w*2),a1
	sub	d3,d1
	move	#70,d0
NO_CLIP_Y1

	move	d0,d4
	add	d1,d4
	cmpi	#269,d4
	blt.s	NO_CLIP_Y2
	sub	#269,d4
	sub	d4,d1
NO_CLIP_Y2

	add.l	(a4,d0.w*4),a2	;pos y de depart du polygone
	sub	#192,CX
	move	CX,d2
	move.l	a2,d3
	cmpi.w	#0,d1
	bgt.s	REMPLI_OK
	rts
REMPLI_OK
	lea	RETOUR,a2
	lea	ADR_TAB,a5
	lea	PIX_TAB,a6
	MOVE.L	#$3111,D6		;cache on		
	MOVEC.L	D6,CACR
*********************
AFF_FACE2
	move.l	d3,a0		;restitue adresse ecran
	move.w	(a3)+,d7		;xmax
	move.w	(a1)+,d6		;xmin
	add	d2,d7
	add	d2,d6
****
	move	d6,d4
	sub.w	d6,d7

	andi.w	#$fff0,d6	
	andi.w	#$f,d4		;valeur du bloc de depart
	add.w	(a6,d4.w*2),d7	;fixe pixel de depart
	add.w	d6,a0
	move.l	(a5,d7.w*4),a4
	jmp	(a4.l)
RETOUR
	add.l	#768,d3		;new ligne
	dbf	d1,AFF_FACE2
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	rts

NEW_VBL
	cmpi.b	#57,$ffffc02
	beq	SORTIE
	addq.l	#1,$466
	rte
MAKE_PTS
	ADD.W	#6,X_ANGLE
	CMPI.W	#720,X_ANGLE
	BLT.S	NO_STOP2 
	CLR.W	X_ANGLE
NO_STOP2
	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP3
	CLR.W	Y_ANGLE
NO_STOP3 
	BSR	TRIGO
	LEA	XC,A0
	LEA	NEW_Z,A1
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#13,D0
	LEA	VAR_3D,A6
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
	MOVEQ.W	#9,D6
LOOP_TRIGO
	MOVE.W	(A0),A3
	MOVE.W	2(A0),D1
	MOVE.W	4(A0),D2

	MOVE.W	A3,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5

	MULS	(A6),D3		;d3=c*xe*512
	MULS	2(A6),D4		;d4=f*ye*512
	MULS	4(A6),D5		;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	Z_DEP,D5
	MOVE.L	D5,A2
	ASR.L	#8,D5
	
	MOVE.W	#512,D7
	SUB.W	D5,D7		;d7=512*q
				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	A3,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze

	MULS	6(A6),D3		;d3=a*xe*512
	MULS	8(A6),D4		;d4=d*ye*512
	MULS	10(A6),D5		;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	DIVS	D7,D5		;d5=new_xe/q

	MOVE	A3,D3
	MULS	12(A6),D3		;d0=b*xe*512
	MULS	14(A6),D1		;d1=e*ye*512
	MULS	16(A6),D2		;d2=h*ze*512
	ADD.L	D3,D1		
	ADD.L	D1,D2
	DIVS	D7,D2		;d2=new_ye/q
	ADD.W	DECA,D5	
	ADD.W	#120+50,D2
	ADDQ	#6,A0
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	MOVE.L	A2,(A1)+
	DBF	D0,LOOP_TRIGO
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
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

	LEA	VAR_3D,A6	;zone sauvegarde calc intermediaire
	MOVEQ.W	#9,D7		;nombre de decalages pour/512

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

AFF_IMG
	lea	MOON+1024,a0
	move.l	WORKECR,a1
	lea	15*768(a1),a1
	move	#224,d0
AFF_PIC
OXO	set	0
	rept	96
	move.l	OXO(a0),OXO(a1)
OXO	set	OXO+4
	endr
	lea	768(a1),a1
	lea	384(a0),a0
	dbf	d0,AFF_PIC
	bsr	SYNCHRO
	rts

SORTIE
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
	move.b	OLD_A09,$ffffa09
	move.b	OLD_A07,$ffffa07
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

	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\NEW_FACE\GEN_04.S"

	SECTION 	DATA
PLAN		DC.W	0
X_ANGLE		DC.W	0
Y_ANGLE		DC.W	0
Z_ANGLE		DC.W	0
XDEP		DC.W	0
YDEP		DC.W	0
Z_DEP		DC.L	3*512
CX		DC.W	0
CY		DC.W	0
YMIN		DC.W	0
HAUTEUR		DC.W	0
RAYON		DC.W	0
RAY1		DC.W	0
RAY2		DC.W	0
RAY3		DC.W	0
RAY4		DC.W	0
RAY5		DC.W	0
RAY6		DC.W	0
RAY7		DC.W	0
OLD_CACR		DC.L	0
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
WORKECR2:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLD_A09		DC.B	0
OLD_A07		DC.B	0
OLD_VBL		DC.L	0
FADE_COMPT		DC.B	0
OLDMODECODE	DC.W	0
SCREEN_ADD		DC.L	0
COMPT_VBL		DC.W	0
DECA		DC.W	192*3
PIX_TAB		
		DC.W	0
		DC.W	385
		DC.W	(385+384)
		DC.W	(385+384+383)
		DC.W	(385+384+383+382)
		DC.W	(385+384+383+382+381)
		DC.W	(385+384+383+382+381+380)
		DC.W	(385+384+383+382+381+380+379)
		DC.W	(385+384+383+382+381+380+379+378)
		DC.W	(385+384+383+382+381+380+379+378+377)
		DC.W	(385+384+383+382+381+380+379+378+377+376)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375+374)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375+374+373)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375+374+373+372)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375+374+373+372+370)
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
XC		INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\CERCLES\COORD.INL"
MOON		INCBIN	F:MOON.HDX
PAL		INCBIN	F:PAL.HDX
	SECTION	BSS
GEN		DS.B	485000
		DS.B	10
ADR_TAB		DS.B	25000
DX		DS.W	50
DY		DS.W	50
VAR_3D		DS.W	9
Y_TABLE		DS.L	300
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
XBIOS2:		DS.B	768*242
		DS.B	4
XBIOS3:		DS.B	768*242
XMAX_AD		DS.B	150*4
XMIN_AD		DS.B	150*4
XMAX1		DS.B	30000
XMIN1		DS.B	30000
NEW_Z		DS.B	100*4
	END																																																																																											
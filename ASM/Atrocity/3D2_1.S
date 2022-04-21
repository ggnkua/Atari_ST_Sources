**********************************************************************
************** EUROPARK SCREEN - Aout 94 - ZANAK *********************
**********************************************************************

Points	equ	20
Cos	equ	64
Centre_X	equ	160
Centre_Y	equ	100
Save_size	equ	3001
Ligne_seq	equ	%1111101101101111

	SECTION TEXT
	
**********************************************************************
************** MEMOIRE - ECRANS **************************************
**********************************************************************
	MOVE.L	4(SP),A0
	
	MOVE.L	12(A0),D0	; TAILLE SECTION TEXT	
	ADD.L	20(A0),D0	; TAILLE SECTION DATA
	ADD.L	28(A0),D0	; TAILLE SECTION BSS
	ADDI.L	#256,D0	; TAILLE BASEPAGE
	ADDI.L	#256,D0	; TAILLE ERROR

	MOVE.L	D0,-(SP)	; TAILLE BLOCK ENTIER
	MOVE.L	A0,-(SP)	; ADRESSE BLOCK
	MOVE.W	#0,-(SP)
	MOVE.W	#$4A,-(SP)	; MSHRINK
	TRAP	#1	; CALL GEMDOS
	ADD.L	#12,SP
	
	TST.L	D0	; TESTE SI ERREUR ...
	BMI	BYE	; SI OUI FIN SINON
			; ON CONTINUE ...

**********************************************************************

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)	; SUPERVISEUR
	TRAP	#1
	ADDQ.L	#6,SP

**********************************************************************
	
	MOVE.L	D0,-(SP)	; OLD REZ 
	LEA	VAR,A6	; VARIABLES

**********************************************************************
	
	MOVE.W	#2,-(SP)	; OU EST L'ECRAN PHYSIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PSCR(A6)	; IL EST LA ...
	
	MOVE.W	#3,-(SP)	; OU EST L'ECRAN LOGIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LSCR(A6)	; IL EST LA AUSSI ...
	
	MOVE.W	#-1,-(SP)	; ET LA RESOLUTION ?
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	MOVE.W	D0,REZ(A6)	; ELLE EST LA ...

**********************************************************************

	MOVE.L	#SIZE1,D0	; TAILLE 1
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN1(A6)	; CONFIG ECRAN1
	
	MOVE.L	#SIZE2,D0	; TAILLE 2
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN2(A6)	; CONFIG ECRAN2
	
**********************************************************************

	MOVE.W	#%100010011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1(A6),-(SP)
	MOVE.L	ECRAN2(A6),-(SP)
	MOVE.W	#5,-(SP)	; VSETMODE
	TRAP	#14
	ADD.L	#14,SP
	
**********************************************************************

	MOVE.L	#MOUSOFF,-(SP)	; COUPE LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ	#8,SP
			
**********************************************************************
**********************************************************************
	lea	Ecran1(a6),a5
	
	bsr.s	Generation_du_Sin_et_Cos
	bsr	BYE

Generation_du_Sin_et_Cos:
	lea	SIN(pc),a2
Make:	lea	Sincos+64(a5),a1
	
	movea.l	a1,a0
	moveq	#31,d7
Sin_1:	move.b	(a2)+,d5
	move.w	d5,-(a1)
	move.w	d5,(a0)+
	dbf	d7,Sin_1
	
	movea.l	a1,a6
	moveq	#95,d7
Sin_2:	move.w	(a1)+,(a0)
	neg.w	(a0)+
	dbf	d7,Sin_2

	move.l	$70.w,-(sp)
	pea	Let_s_go(pc)
	move.l	(sp)+,$70.w

Wait	tst.b	$fffffc02.w
	ble.s	Wait
	move.l	(sp)+,$70.w
	move.l	(sp)+,d6
	rts
		
Let_s_go:
	movea.l	$432.w,a5
	addq.b	#2,(a5)
	moveq	#0,d7
	move.b	(a5)+,d7
	movea.l	a6,a0
	adda.w	d7,a0
	addq.b	#3,(a5)
	move.b	(a5)+,d7
	andi.w	#$00fe,d7
	movea.l	a6,a1
	adda.w	d7,a1
	
	lea	Fin_coord(pc),a3
	moveq	#Points,d6

Calcul_des_points:
	move.b	-(a3),d1
	move.b	-(a3),d0
	ext.w	d0
	ext.w	d1
	
	move.w	d0,d2
	muls.w	Cos(a0),d0
	muls.w	(a0),d2
	asl.w	#7,d1
	
	move.w	d1,d3
	move.w	d2,d4
	muls.w	(a1),d4
	muls.w	Cos(a1),d1
	sub.l	d4,d1
	
	muls.w	(a1),d3
	muls.w	Cos(a1),d2
	add.l	d3,d2
	
	asr.l	#7,d1
	asr.l	#7,d2
	
	moveq	#127,d4
	asr.w	#8,d2
	sub.w	d2,d4
	divs	d4,d0
	divs	d4,d1
	addi.w	#Centre_X,d0
	addi.w	#Centre_Y,d1
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	subq.w	#1,d6
	bne.s	Calcul_des_points	
	
Affichage:
	eori.w	#Save_size*4,(a5)
	adda.w	(a5)+,a5
	movea.l	(a5)+,a4
	movea.l	a5,a3
Cls:	move.l	(a3)+,d0
	beq.s	Ligne
	movea.l	d0,a2
	move.w	d6,(a2)
	bra.s	Cls
	
Ligne:
	move.l	a4,d5
	lsr.w	#8,d5
	move.l	d5,$ffff8200.w
	move.w	#Ligne_seq,d6
	
Tra‡age_de_la_ligne:
	bcs.s	Lbcl
	move.w	(sp)+,d0
	move.w	(sp)+,d1
Lbcl:	move.w	(sp)+,d2
	move.w	(sp)+,d3

Traces:
	movem.w	d0-3/d6,-(sp)
	move.l	d0,d4
	sub.w	d2,d4
	bpl.s	Traces_1
	neg.w	d4
	exg	d1,d3
	move.w	d2,d0
	
Traces_1:	move.w	#160,d6
	sub.w	d1,d3
	bpl.s	Traces_2
	neg.w	d3
	neg.w	d6
	
Traces_2	mulu.w	#160,d1
	move.l	a4,a0
	ror.l	#4,d0
	lsl.w	#3,d0
	add.w	d0,d1
	adda.w	d1,a0
	rol.l	#4,d0
	not.w	d0
	moveq	#0,d1
	bset	d0,d1
	swap	d1
	cmp.w	d4,d3
	bgt.s	Traces_suite_1
	
	move.w	d4,d2
	move.w	d4,d5
	lsr.w	#1,d2
	
Traces_3:	or.w	d1,(a0)
	move.l	a0,(a5)+
	rol.w	#1,d1
	bcc.s	Traces_4
	subq.l	#8,a0
	
Traces_4:	sub.w	d3,d2
	bgt.s	Traces_5
	adda.w	d6,a0
	add.w	d4,d2
	
Traces_5:	subq.w	#1,d5
	bgt.s	Traces_3
	
Traces_fin:	movem.w	(sp)+,d0-3/d6
	move.w	d3,d1
	move.w	d2,d0
	add.w	d6,d6
	bne.s	Tra‡age_de_la_ligne
	clr.l	(a5)
	rte
	
Traces_suite_1:
	move.w	d3,d2
	move.w	d3,d5
	lsr.w	#1,d2
Traces_suite_2:
	or.w	d1,(a0)
	move.l	a0,(a5)+
	adda.w	d6,a0
	sub.w	d4,d2
	bgt.s	Traces_suite_3
	add.w	d3,d2
	rol.w	#1,d1
	bcc.s	Traces_suite_3
	subq.l	#8,a0
Traces_suite_3:
	subq.w	#1,d5
	bpl.s	Traces_suite_2
	bra.s	Traces_fin
	



	
		

**********************************************************************
**********************************************************************

BYE	MOVE.L	#MOUSON,-(SP)	; REMET LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
	
**********************************************************************

	MOVE.W	REZ(A6),-(SP)	; REMET LA REZ
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR(A6),-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR(A6),-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP
	
**********************************************************************

	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
		
**********************************************************************
	SECTION DATA
**********************************************************************

MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0

Debut_Coord:
	dc.b	-50,-20
	dc.b	-30,15
	dc.b	-20,-2
	dc.b	-20,15
	dc.b	15,15
	dc.b	25,5
	dc.b	30,15
	dc.b	40,15
	dc.b	20,-20
	dc.b	10,-20
	dc.b	20,-5
	dc.b	10,5
	dc.b	-10,5
	dc.b	-10,-10
	dc.b	5,-10
	dc.b	5,-20
	dc.b	-20,-20
	dc.b	-30,-3
	dc.b	-40,-20
	dc.b	-50,-20
Fin_coord:

SIN:	dc.b	128,128,127,126,125,123,122,119
	dc.b	117,117,111,108,105,101,097,093
	dc.b	088,084,079,074,068,063,058,052
	dc.b	046,040,034,028,022,016,009,003	
		
Sincos:	rs.w	160

**********************************************************************
	SECTION BSS
**********************************************************************

SIZE1	DS.W	320*200+128
SIZE2	DS.W	320*200+128

VAR	DS.W	48

PSCR	RS.W	2
LSCR	RS.W	2
REZ	RS.W	1
ECRAN1	RS.W	2
ECRAN2	RS.W	2
		
	END
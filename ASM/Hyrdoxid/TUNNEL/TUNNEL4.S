;tunnel:88*45=3960 pts+shade

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	move.b	$ffffa09,OLD_A09
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	bsr	MAKE_YTABLE_T
	bsr	MAKE_COL_TAB
	bsr	CALC_PTS_TUNNEL
	bsr	PREP_COMPT
	MOVE.L	#SAVE_POINT,SAVE1
	MOVE.L	#SAVE_POINT2,SAVE2	
	clr.L	COMPT_T	
LOOP_TUNNEL
	CLR.L	$FFFF9800
	ADD.L	#8,COMPT_T
	cmpi.l	#4*360,COMPT_T
	BNE.S	.NO_CLR
	CLR.L	COMPT_T
.NO_CLR
	bsr	EFFA_TUNNEL
	bsr	AFF_DOTS_TUNNEL
	ADDQ.L	#1,COMPT_VBL_T
	BSR	SYNCHRO
	MOVE.L	SAVE1,A1		;swap zones de sauvegarde
	MOVE.L	SAVE2,SAVE1
	MOVE.L	A1,SAVE2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	move.l	#$ff,$ffff9800
NO_ALT2
	CMPI.B	#57,$FFFFC02
	BNE.S	NO_ALT
	BRA	SORTIE
NO_ALT
	BSR	VBL
	BRA	LOOP_TUNNEL
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
	BSR	TRUE_COLOR_TUNNEL
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
TRUE_COLOR_TUNNEL:
	CLR.B	$FFFF8260.W
	MOVE	#384,$FFFF8210.W	;TAILLE EN MOT
	MOVE	#384,$FFFF820E.W	;TAILLE EN MOT
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
MAKE_YTABLE_T
	LEA	Y_TABLE,A1
	MOVE	#399,D1
	MOVEQ.L	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#768*2,D2
	DBF	D1,MAKE
	RTS
CALC_PTS_TUNNEL
	lea	TUNNEL_TAB,a0
	lea	COORD_T,a2
	lea	Y_TABLE,a1
	move	#(90)-1,d5		;nb de cercles
	move	#44,d4		;nb de pts par cercle
	move	#$3111,d7
	movec	d7,CACR
LOOP_PTS
	add	#5,8(a2)
	move	#512,d3
	sub	8(a2),d3	;512-2*ZE=Q*512
;-----------------------------
;2)calcul de X=XE/Q
;Q=D3    XE=D1  X=D1
;-----------------------------
	move.l	(a2),d1
	divs	d3,d1		;XE*512/Q*512=X
	add	#192+384,d1	;CENTRE LES X
;-----------------------------
;3)calcul des Y=YE/Q
;Y=D2
;-----------------------------
	move.l	4(a2),d2
	divs	d3,d2
	add.l	#120+60,d2
	andi.l	#$ffff,d2
;affiche le pt
	andi.l	#$ffff,d1
	asl	d1
	add.l	(a1,d2.l*4),d1
	move.l	d1,(a0)+	
	lea	10(a2),a2
	dbf	d4,LOOP_PTS
	move	#44,d4		;nb de pts par cercle
	lea	COORD_T,a2
	dbf	d5,LOOP_PTS	
	move	#$2510,d7
	movec	d7,CACR
	rts
PREP_COMPT
	lea	COMPTEUR_T,a0
	move	#45*4,d0
	move	#89,d1
	moveq	#0,d2
.LOOP
	move.l	d2,4(a0)
	addq.l	#8,a0
	add	d0,d2
	dbf	d1,.LOOP
	rts

AFF_DOTS_TUNNEL
	lea	COL_TAB,a5
	lea	TUNNEL_TAB,a0
	lea	COMPTEUR_T,a2
	move.l	WORKECR,a1
	add.l	#-60*768*2-768,a1
	move.l	a1,a6
	move.l	CENTRE,d5
	move.l	SAVE1,a3
	lea	SINUS_T,a4
	add.l	COMPT_T,a4
	move.l	(a4),d4
	move.l	#0,a4
	move	#87,d0
	move	#45-1,d2
	move	#45*4,d6
	move	#$3111,d7
	movec	d7,CACR
AFF_DOTS3
	moveq	#45-1,d2
	lea	TUNNEL_TAB,a0
	move.l	(a2)+,d3
	add.l	(a2),a0
;couleur du cercle
	move.l	(a2),d7
	move	(a5,d7.w*2),d7
;centrage
	sub.l	d5,d3

AFF_DOTS2
	move.l	(a0)+,d1
	add.l	d3,d1
	move.l	d1,(a3)+
	move	d7,(a1,d1.l)
	dbf	d2,AFF_DOTS2

	add.l	#45*4,(a2)
	cmpi.l	#88*4*45,(a2)+
	bne.s	NO_CLR_COMPT
	clr.l	-4(a2)
	move.l	-8(a2),a4
	move.l	d4,-8(a2)
NO_CLR_COMPT
	dbf	d0,AFF_DOTS3
	move	#$2510,d6
	movec	d6,CACR
	move.l	a4,CENTRE
	rts
NEW_VBL
	addq	#1,$466.w
	rte
MAKE_COL_TAB
	lea	COL,a0
	lea	COL_TAB,a1
	move	#45*4*4,d1
	move	#21,d0
	move	(a0)+,d2
.LOOP
	move	d2,(a1)+
	dbf	d1,.LOOP
	move	#45*4*4,d1
	move	(a0)+,d2
	dbf	d0,.LOOP
	rts
EFFA_TUNNEL
	MOVE.L	WORKECR,A0		
	add.l	#-60*768*2-768,a0
	MOVE.W	#((45*88)/30)-1,D1
	MOVEQ.W	#0,D4
	MOVE.L	SAVE1,A1
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
EFF2
	REPT	30
	MOVE.L	(A1)+,D3
	MOVE.W	D4,(A0,D3.L)
	ENDR
	DBF	D1,EFF2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS

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

CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts
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
COORD_T	INCBIN	E:\REALM.S\TUNNEL\TUNNEL.INL
SINUS_T	INCBIN	E:\REALM.S\TUNNEL\SINUS.INL
COL
	dc.w	%0011100111000111
	dc.w	%0100001000001000
	dc.w	%0100101001001001
	dc.w	%0101001010001010
	dc.w	%0101101011001011
	dc.w	%0110001100001100
	dc.w	%0110101101001101
	dc.w	%0111001110001110
	dc.w	%0111101111001111
	dc.w	%1000010000010000
	dc.w	%1000110001010001
	dc.w	%1001010010010010
	dc.w	%1001110011010011
	dc.w	%1010010100010100
	dc.w	%1010110101010101
	dc.w	%1011010110010110
	dc.w	%1011110111010111
	dc.w	%1100011000011000
	dc.w	%1100111001011001
	dc.w	%1101011010011010
	dc.w	%1101111011011011
	dc.w	-1
	SECTION	BSS
COL_TAB		DS.W	45*4*4*22
CENTRE		DS.L	1
TUNNEL_TAB		DS.B	20000
OLD_CACR		DS.L	1
COMPT_T		DS.l	1
COMPT_VBL_T	DS.l	1
OLD_VBL		DS.L	1
OLD_A09		DS.B	1
AFFECR:		DS.L 	1
WORKECR:		DS.L 	1
Y_TABLE		DS.L	400
OLDXBIOS2:		DS.L	1
OLDMODECODE	DS.W	1
SAVE1		DS.L	1
SAVE2		DS.L	1
SAVE_POINT		DS.B	30000
SAVE_POINT2	DS.B	30000
COMPTEUR_T		DS.B	1800
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
		EVEN
		DS.B	4+60*2*768
XBIOS2:		DS.B	768*280*2
		DS.B	4+60*2*768
XBIOS3:		DS.B	768*280*2
	END																																																																																															 	  																																		  																																																														

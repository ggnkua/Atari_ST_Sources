* rq: sortie fleches clavier
*
******************************
*   INTRO CODED BY: MEKANO   *
*   ( COMPLET PC RELATIF )   *
*       SALUT A : YODA	     *
***************************************************************
* AIDE (SELON LE JEU MODIFIER) :			      *
* 1/ MODIFIER LE TEXTE (d'abord options YES/NO puis chiffres) *
* 2/ TOP_NUMBER ('1' A '9')				      *
* 3/ TEST DES RESULTATS TAPES PAR L'UTILISATEUR		      *
***************************************************************
	opt	x-
TOP_NUMBER   equ	'7'	*MODIFIABLE

TEXT
	pea	STRT(PC)
	MOVE.W	#$26,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7

	clr.w	-(sp)
	trap	#1

STRT	bsr TRAINER
	lea	SAV_OPTION-TXT(a4),a0
GAG1	*cmp.b	#$ff,(a0)	        *test de l'option F1 (ff=yes,fe=no)
	*bne.s	GAG2
	*move..........	
GAG2	*cmp.b	#$ff,1(a0)	        *test de l'option F2 (ff=yes,fe=no)
	*bne.s	GAG3
	*move..........	
GAG3	*cmp.b	#$ff,3(a0)	        *test de l'option F3 (ff=yes,fe=no)
	*bne.s	GAG4
	*move..........	
GAG4	*move.b 4(a0),...               *test de l'option F4 (chiffres)
	*............
	*.............
	rts

TRAINER	lea	TXT(pc),a4
	bsr	INIT
	bsr	AFF_TXT
	bsr	RAST_ON
	bsr	KEY
	bsr	RAST_OFF
	bsr	INIT_OLD
	bsr	SAV_RESULT
	rts

RAST_ON
	move.w	#$2700,sr
	lea	RASTER-TXT(a4),a5
	lea	NB_LINE-TXT(a4),a6
	move.b	$fffffa07.w,OLD_A07-TXT(a4)
	move.b	$fffffa09.w,OLD_A09-TXT(a4)
	move.b	$fffffa13.w,OLD_A13-TXT(a4)
	move.l  $70.w,OLD_VBL-TXT(a4)
	move.l	$120.w,OLD_TB-TXT(a4)
	and.b	#$00,$fffffa07.w
	and.b	#$40,$fffffa09.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	lea	NEW_VBL-TXT(a4),a0
	move.l	a0,$70.w
	move.w	#$2300,sr
	rts

NEW_VBL	clr.b	$fffffa1b.w
	clr.w	$ffff8240.w
	move.b	#1,$fffffa21.w
	lea	HBL_1-TXT(a4),a5
	move.l	a5,$120.w
	lea	RASTER-TXT(a4),a5
	lea	NB_LINE-TXT(a4),a6
	move.b	#8,$fffffa1b.w
	rte

HBL_1 	move.w	(a5)+,$ffff8240.w
	clr.b	$fffffa1b.w
	move.b	(a6)+,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

RAST_OFF
	move.w	#$2700,sr
	move.b	OLD_A07-TXT(a4),$fffffa07.w
	move.b	OLD_A09-TXT(a4),$fffffa09.w
	move.b	OLD_A13-TXT(a4),$fffffa13.w
	move.l  OLD_VBL-TXT(a4),$70.w
	move.l	OLD_TB-TXT(a4),$120.w
	move.w	#$2300,sr
	rts

INIT	lea	SAV_OPTION-TXT(a4),a6
	move.l	a6,CURRENT_POS-TXT(a4)
	dc.w	$a00a
	move.b	#$12,$fffffc02.w
	move.b	$44c.w,OLD_REZ2-TXT(a4)
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,OLD_COL-TXT(a4)
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	movem.l PAL-TXT(a4),d0-d7
	movem.l d0-d7,$ffff8240.w
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,d6
	move.l	d0,OLD_ECR-TXT(a4)
	clr.b	$484.w
	lea	TXT-TXT(a4),a6
	move.l	a6,d7
	lea	160*5(a3),a3
	rts

SAV_RESULT lea	SAV_OPTION-TXT(a4),a0
	move.l	a0,a1
	moveq	#9,d0
CONG	move.b	5(a0),(a1)
	lea	6(a0),a0
	cmp.b	#'E',(a1)
	bne.s	TLB
	move.b	#$ff,(a1)+
	bra.s	TLB2
TLB	cmp.b	#'1',(a1)
	bmi.s	TLB1
	cmp.b	#'9',(a1)
	bhi.s	TLB1
	sub.b	#'1'-1,(a1)+
	bra.s	TLB2
TLB1	move.b	#$fe,(a1)+	
TLB2	dbra	d0,CONG
	rts

INIT_OLD move.b	#7,$484.w
	movem.l OLD_COL-TXT(a4),d0-d7
	movem.l d0-d7,$ffff8240.w
	dc.w	$a009
	move.b	#$08,$fffffc02.w
	move.l	OLD_ECR-TXT(a4),a0
	move.w	#7999,d0
CLS	clr.l	(a0)+
	dbra	d0,CLS
	move.w	OLD_REZ1-TXT(a4),-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	rts

AFF_TXT	move.l	d7,a0
	cmp.b	#-1,(a0)
	beq.s	EAT
	move.l	a0,a1
SCA	tst.b	(a1)+
	bne.s	SCA
	move.l	a1,d5
	sub.l	a0,a1
	subq.l	#1,a1
	moveq	#40,d2
	sub.l	a1,d2
	lsr.l	#1,d2
	btst	#0,d2
	bne.s	IMPAIRE
	lsl.l	#2,d2
	bra.s	AP
IMPAIRE lsl.l	#2,d2
	subq.l	#3,d2
AP	move.l	#0,a2
	move.l	d2,a2
	add.l	d6,a2
	move.l	a2,d4
	bsr	AFF
	cmp.l	#160*186,a3
	bhi.s	EAT
	move.l	d5,d7
	bra.s	AFF_TXT
EAT	rts

AFF	moveq	#7,d1
AFF2	lea	YODAMI-TXT(a4),a1
	cmp.l	a1,a0
	bne.s	NOTHAT
	move.l	#160*185,a3
NOTHAT	moveq	#0,d2
	lea	FNT-TXT(a4),a1
	move.b	(a0)+,d2
	beq	LE_RTS
	cmp.b	#'&',d2
	bne.s   NO_TOP
	lea	-2(a0),a6
	move.b	(a6),d7
	sub.b	#$30,d7	
	add.b	d7,TOP_TOP+3-TXT(a4)
NO_TOP	cmp.b	#'A',d2
	bmi.s	NO
	cmp.b	#'Z',d2
	bhi.s	NO
	sub.b	#'A',d2
	bra.s	NO6
NO	cmp.b	#'0',d2
	bmi.s	NO2
	cmp.b	#'9',d2
	bhi.s	NO2
	sub.b	#'0'-26,d2	
	bra.s	NO6
NO2	cmp.b	#':',d2
	bne.s	NO3
	move.b	#36,d2
	bra.s	NO6
NO3	cmp.b	#'!',d2
	bne.s	NO4
	move.b	#37,d2
	bra.s	NO6
NO4	cmp.b	#'-',d2
	bne.s	NO5
	move.b	#38,d2
	bra.s	NO6
NO5	move.b	#39,d2	
NO6	btst	#0,d2
	bne.s	IMPAI
	lsl.l	#2,d2		*1
	bra.s	COQ
IMPAI	lsl.l	#2,d2		*1
	subq.l	#3,d2		*1
COQ	add.l	d2,a1
	add.l	a3,a2
	lea	-1(a0),a6
	cmp.b	#'$',(a6)
	bne.s	ICO
	move.l	CURRENT_POS-TXT(a4),a6
	move.l	a2,(a6)+
	move.b	(a0),(a6)+
	move.b	1(a0),(a6)+
	move.l	a6,CURRENT_POS-TXT(a4)
ICO	move.b	(a1),(a2)
	move.b	2(a1),2(a2)
	lea	160(a1),a1	*80
	lea	160(a2),a2
	dbra	d1,ICO
	btst	#0,d4
	bne.s	IMP
	addq.l	#1,d4
	bra.s	CLO
IMP	addq.l	#7,d4
CLO	move.l	d4,a2
	bra	AFF
LE_RTS	lea	160*10(a3),a3
	rts

KEY	bclr	#6,$fffffa09.w
KEY2	lea	-1(a6),a0
	cmp.b   #1,(a0)
	bne.s	KEY2	
KEY3	lea	-1(a6),a0
	cmp.b   #92,(a0)
	bne.s	KEY3	
	bset	#6,$fffffa09.w
TEMPO	move.b	$fffffc02.w,d0
	cmp.b	d5,d0
	beq.s	KEY
	move.b	d0,d5
	lea	SAV_OPTION-TXT(a4),a0
	cmp.b	#$3b,d0
	bmi.s	SPACE
TOP_TOP	cmp.b	#$3a,d0
	bhi.s	SPACE
	sub.b	#$3b,d0
	mulu	#6,d0
	add.l	d0,a0
	cmp.b	#'E',5(a0)
	beq.s	YN
	cmp.b	#'N',5(a0)
	beq.s	YN
	bsr	NUMBER
	bra.s	TEMPO
YN	bsr	AFF_YN
SPACE	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	cmp.b	#$39,$fffffc02.w
	bne.s	KEY
	rts

NUMBER	cmp.b	#TOP_NUMBER,5(a0)
	bne.s	POP
	move.b	#'1',5(a0)
	bra.s	POP2
POP	addq.b	#1,5(a0)
POP2	lea	FNT-TXT(a4),a1
	move.l	(a0),a2
	moveq	#7,d0
	moveq	#0,d1
	move.b	5(a0),d1
	sub.l	#'0',d1
	btst	#0,d1
	bne.s	INL
	lea	104(a1),a1		*52
	bra.s	OKL
INL	lea	105(a1),a1		*53
	subq.l	#1,d1
OKL	lsl.l	#2,d1			*1
	add.l	d1,a1
OKL2	move.b	(a1),8(a2)
	move.b	2(a1),10(a2)
	lea	160(a1),a1		*80
	lea	160(a2),a2
	dbra	d0,OKL2
	rts

AFF_YN	lea	FNT-TXT(a4),a1
	move.l	(a0),a2
	move.l	a2,d2
	moveq	#7,d0
	cmp.b	#'E',5(a0)
	bne.s	NOT_Y
Y	move.b	#'N',5(a0)
	btst	#0,d2
	bne.s	OINPER
OPER	move.b	153(a1),01(a2)	*77(a1)  | 
	move.b	155(a1),03(a2)	*79(a1)  |
	move.b	 49(a1),08(a2)	*25(a1)  |N
	move.b	 51(a1),10(a2)	*27(a1)  |
	move.b	 56(a1),09(a2)	*28(a1)	 |O
	move.b	 58(a1),11(a2)	*30(a1)  |
	lea	160(a1),a1	*80
	lea	160(a2),a2
	dbra	d0,OPER
	rts

OINPER	move.b	153(a1),07(a2)	*77(a1)  | 
	move.b	155(a1),09(a2)	*79(a1)  |
	move.b	 49(a1),08(a2)	*25(a1)  |N
	move.b	 51(a1),10(a2)	*27(a1)  |
	move.b	 56(a1),15(a2)	*28(a1)	 |O
	move.b	 58(a1),17(a2)	*30(a1)  |
	lea	160(a1),a1	*80
	lea	160(a2),a2
	dbra	d0,OINPER
	rts

NOT_Y	move.b	#'E',5(a0)
	btst    #0,d2
	bne.s	OINPER2
OPER2	move.b	 96(a1),01(a2)	*48(a1)  |Y 
	move.b	 98(a1),03(a2)	*50(a1)  |
	move.b	 16(a1),08(a2)	*08(a1)  |E
	move.b	 18(a1),10(a2)	*10(a1)  |
	move.b	 72(a1),09(a2)	*36(a1)	 |S
	move.b	 74(a1),11(a2)	*38(a1)  |
	lea	160(a1),a1	*80
	lea	160(a2),a2
	dbra	d0,OPER2
	rts

OINPER2	move.b	 96(a1),07(a2)	*48(a1)  |Y 
	move.b	 98(a1),09(a2)	*50(a1)  |
	move.b	 16(a1),08(a2)	*08(a1)  |E
	move.b	 18(a1),10(a2)	*10(a1)  |
	move.b	 72(a1),15(a2)	*36(a1)	 |S
	move.b	 74(a1),17(a2)	*38(a1)  |
	lea	160(a1),a1	*80
	lea	160(a2),a2
	dbra	d0,OINPER2
	rts

* caracteres disponibles:
* A B....Z 0 1....9 : ! - espace
* attention n'utilisez pas la touche TAB !!!!!!!
TXT	   dc.b	   '-- ELITE --',0
	   DC.B	   ' ',0
	   dc.b	   'THE EMPIRE - NOKTURNAL - HOTLINE - MCA',0
	   dc.b	   ' ',0 
	   dc.b	   'PROUDLY PRESENTS',0
	   dc.b	   ' ',0
	   dc.b	   'NOM DU SHIT',0
	   dc.b    ' ',0
;	   dc.b	   'TRAINER OPTIONS:',0
;	   dc.b    ' ',0
	   dc.b	   'F1 OPTION 1        $ NO',0
	   dc.b	   'F2 OPTION 2        $YES',0
	   dc.b	   'F3 OPTION 3        $ NO',0
	   DC.B	   'F4 OPTION 4        $YES',0
	   DC.B    'F5 OPTION 5        $ NO',0
	   dc.b	   'F6&STARTING LEVEL   $ 1',0
;******* ne pas oublier le '&' ci dessus pour preciser au
;******* programme que c'est la derniere option.
;	   dc.b	   ' ',0
;	   dc.b	   'SALUT !!!!!!!!',0
	   dc.b	   ' ',0
	   dc.b    'CRACKED AND TRAINED BY',0
	   dc.b	   'THE LIGHT FROM THE EMPIRE',0
	   dc.b	   ' ',0
YODAMI	   dc.b	   'CODED BY MEKANO AND BAGHEERA',0
	   dc.b	   -1
PAL	   dc.w	   $000,$777,$333,$444
	   ds.w	   12
RASTER	   dc.w	   $777,$300,$777,$000,$777,$003
	   dc.w	   $777,$000,$777,$300,$777,$000
NB_LINE	   dc.b	   1,53+20,1,6,1,112-20,1,6,1,12,1,10
	   even
FNT	   incbin	shit.blk
	   even
OLD_A07	   dc.b    0
OLD_A09	   dc.b    0
OLD_A13	   dc.b    0
	   dc.b	   0 
OLD_VBL	   dc.b	   0,0,0,0
OLD_TB	   dc.b	   0,0,0,0
OLD_COL	   ds.b	  32
OLD_REZ1   dc.b    0
OLD_REZ2   dc.b    0
OLD_ECR    dc.b    0,0,0,0
CURRENT_POS dc.b   0,0,0,0
OLD_SUP	   dc.b    0,0,0,0
SAV_OPTION rept   10
	   dc.b    0,0
	   dc.b    0,0,0,0
	   endr
	   end


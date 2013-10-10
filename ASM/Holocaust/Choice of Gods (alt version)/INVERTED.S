***************************************************************************
*                       - - INVERTED LANDSCAPES - -                       *
* Buffer texte: 70K                                                       *
* Buffer assemblage: 170K                                                 *
***************************************************************************

; Vous aviez du mal … en croire vos yeux quand vous avez vu l'‚cran ?
; Ne changez rien!
; En voyant le source, vous allez carr‚ment vous suicider!

; Me croirez-vous en effet si je vous dis que j'utilise les routines
; parues dans STMag et la Line A ?!
; Nooooooooon?  SI!

; Comme quoi, quand on est un g‚nie, on fait des chefs d'oeuvres avec
; n'importe quoi. ( En l'occurence, des routines nullissimes. )

; (C) 1992 - ZAPPY OF HOLOCAUST

;PS: je n'ai pas inclus l'image du d‚but, ni la musique de BIG ALEC
;parce que je ne les ai pas retrouv‚s!!!

FG_BP1	EQU	24
FG_BP2	EQU	26
FG_BP3	EQU	28
FG_BP4	EQU	30
WRT_MOD	EQU	36
Y1	EQU	40
PATPTR	EQU	46
PATMSK	EQU	50
MULTIFILL	EQU	52
CLIP	EQU	54
XMN_CLIP	EQU	56
YMN_CLIP	EQU	58
XMX_CLIP	EQU	60
YMX_CLIP	EQU	62

SEG=(92+4*16)/4
NB_PTS=4*SEG
PAS=1
NB_POS=(360/PAS)/4

NB_PTSCUB=16+8+8
NB_SEG=NB_PTSCUB/2
PAS_CUB=1
NB_POS_CUB=360/PAS_CUB/4

DEBUT:	LEA.L 	NEW_PILE,A7

	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	LEA	BOURRE,A0
	MOVE	#$9999,(A0)
	
	MOVE.L	#FIN,$8.W
	MOVE.L	#FIN,$C.W
	MOVE.L	#FIN,$10.W
	MOVE.L	#FIN,$14.W
	MOVE.L	#FIN,$18.W
	MOVE.L	#FIN,$1c.W
	MOVE.L	#FIN,$20.W

	CLR	-(SP)
	PEA	-1.W
	PEA	-1.W
	MOVE	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

	MOVE.L	#BUFFERSCR,d0	
	CLR.B	D0
	MOVE.L	D0,SCREEN1
	ADD.L	#32000,D0
	MOVE.L	D0,SCREEN2
	
	move.l	SCREEN2,d0
	lsr.l	#8,d0
	move.l	#$ffff8201,a0
	movep	d0,(a0)
	
;	LEA	ZAP+2,A0
;	MOVEM.L	(A0),D0-D7
;	MOVEM.L	D0-D7,$FFFF8240.W
	
;	LEA	ZAP+34,A0
;	MOVE.L	SCREEN2,A1
;	MOVE	#7999,D0
;COPIMG	MOVE.L	(A0)+,(A1)+
;	DBF	D0,COPIMG

	MOVE.L	#VBL_DEB,$70.W
	MOVE	#$2300,SR
	BRA	demo

VBL_DEB	MOVEM.L	D0-A6,-(SP)
	CMPI.L	#8,NB_PART
	BNE.S	SUITV0
	BSR	TEST_LET
	CLR.L	NB_PART
SUITV0	BSR	SCROLL
	BSR	SCROLL
	MOVEM.L	(SP)+,D0-A6
	RTE

SCROLL	MOVE.L	SCREEN2,A0
	LEA	BUF_LET,A1
	REPT	8
	ROXL	(A1)
	ROXL	154(A0)
	ROXL	146(A0)
	ROXL	138(A0)
	ROXL	130(A0)
	ROXL	122(A0)
	ROXL	114(A0)
	ROXL	106(A0)
	ROXL	98(A0)
	ROXL	90(A0)
	ROXL	82(A0)
	ROXL	74(A0)
	ROXL	66(A0)
	ROXL	58(A0)	
	ROXL	50(A0)
	ROXL	42(A0)
	ROXL	34(A0)
	ROXL	26(A0)
	ROXL	18(A0)
	ROXL	10(A0)
	ROXL	2(A0)
	LEA	160(A0),A0
	ADDQ.L	#2,A1
	ENDR
	ADDI.L	#1,NB_PART
	RTS

TEST_LET	MOVEQ	#0,D0
	LEA	TEXT1,A0	
	ADDA.L	POINT,A0
	LEA	FONT8_8,A1
	CMPI.B	#$FF,(A0)
	BNE	SUITTST
	CLR.L	POINT
	LEA	TEXT1,A0
SUITTST	MOVE.B	(A0),D0	
	SUBI.B	#32,D0	
	LSL.W	#3,D0	
	ADDA.L	D0,A1	
	LEA	BUF_LET,A2
	MOVE.B	(A1)+,(A2)
	MOVE.B	(A1)+,2(A2)
	MOVE.B	(A1)+,4(A2)
	MOVE.B	(A1)+,6(A2)
	MOVE.B	(A1)+,8(A2)
	MOVE.B	(A1)+,10(A2)
	MOVE.B	(A1)+,12(A2)
	MOVE.B	(A1)+,14(A2)
	ADDI.L	#1,POINT
	RTS
TEXT1
 DC.B "                                        "
 DC.B '"WARNING !! THIS SCREEN CAN CAUSE HEART ATTACKS!!"'
 dc.b "   So, boys, you still can press the RESET button... "
 dc.b "   The screen you're about to see is called: "
 dc.b '"INVERTED LANDSCAPES"...'
 dc.b "      Line routy by ZERIOUL. Scroll routy by DAN NATO."
 dc.b " Landscapes/Gfxs/Puting together by ZAPPY. Music by BIG ALEC of DELTA FORCE. "
 dc.b "    This is the good way to obtain a 3D overdose...  Huerk...       "
 DC.B "                                        "
 DC.B "               ",$FF
 even
 
FONT8_8	
	dc.l	$00000000,$00000000,$00181818,$18001800,$00666666 
	dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
	dc.l	$00666C18,$30664600,$1C361C38,$6F663B00,$00181818 
	dc.l	$00000000,$000E1C18,$181C0E00,$00703818,$18387000 
	dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000 
	dc.l	$00181830,$0000007E,$00000000,$00000000,$00181800 
	dc.l	$00060C18,$30604000,$003C666E,$76663C00,$00183818 
	dc.l	$18187E00,$003C660C,$18307E00,$007E0C18,$0C663C00 
	dc.l	$000C1C3C,$6C7E0C00,$007E607C,$06663C00,$003C607C 
	dc.l	$66663C00,$007E060C,$18303000,$003C663C,$66663C00 
	dc.l	$003C663E,$060C3800,$00001818,$00181800,$00001818 
	dc.l	$00181830,$060C1830,$180C0600,$00007E00,$007E0000 
	dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E 
	dc.l	$6E603E00,$00183C66,$667E6600,$007C667C,$66667C00 
	dc.l	$003C6660,$60663C00,$00786C66,$666C7800,$007E607C 
	dc.l	$60607E00,$007E607C,$60606000,$003E6060,$6E663E00 
	dc.l	$0066667E,$66666600,$007E1818,$18187E00,$00060606 
	dc.l	$06663C00,$00666C78,$786C6600,$00606060,$60607E00 
	dc.l	$0063777F,$6B636300,$0066767E,$7E6E6600,$003C6666 
	dc.l	$66663C00,$007C6666,$7C606000,$003C6666,$666C3600 
	dc.l	$007C6666,$7C6C6600,$003C603C,$06063C00,$007E1818 
	dc.l	$18181800,$00666666,$66667E00,$00666666,$663C1800 
	dc.l	$0063636B,$7F776300,$0066663C,$3C666600,$0066663C 
	dc.l	$18181800,$007E0C18,$30607E00,$001E1818,$18181E00 
	dc.l	$00406030,$180C0600,$00781818,$18187800,$00081C36 
	dc.l	$63000000,$00000000,$0000FF00,$00183C7E,$7E3C1800 
	dc.l	$00003C06,$3E663E00,$0060607C,$66667C00,$00003C60 
	dc.l	$60603C00,$0006063E,$66663E00,$00003C66,$7E603C00 
	dc.l	$000E183E,$18181800,$00003E66,$663E067C,$0060607C 
	dc.l	$66666600,$00180038,$18183C00,$00060006,$0606063C 
	dc.l	$0060606C,$786C6600,$00381818,$18183C00,$0000667F 
	dc.l	$7F6B6300,$00007C66,$66666600,$00003C66,$66663C00 
	dc.l	$00007C66,$667C6060,$00003E66,$663E0606,$00007C66 
	dc.l	$60606000,$00003E60,$3C067C00,$00187E18,$18180E00 
	dc.l	$00006666,$66663E00,$00006666,$663C1800,$0000636B 
	dc.l	$7F3E3600,$0000663C,$183C6600,$00006666,$663E0C78 
	dc.l	$00007E0C,$18307E00,$00183C7E,$7E183C00,$18181818 
	dc.l	$18181818,$007E787C,$6E660600,$08183878,$38180800 
	even

POINT	DC.L	0
NB_PART	DC.L	8
BUF_LET	DS.B	(1*8)*2
	EVEN

demo:
	MOVE.L	#text,TEXT_EC
	move.l	#COURB1,COURB_EC
	MOVE	#128-1,COLONNE

	JSR	LINE_A_INIT

	MOVE	#1,FG_BP1(A0)
	CLR	FG_BP2(A0)
	CLR	FG_BP3(A0)
	CLR	FG_BP4(A0)
	
	CLR	WRT_MOD(A0)
	
	MOVE.L	#FILL,PATPTR(A0)
	
	MOVE	#1,PATMSK(A0)
	CLR	MULTIFILL(A0)
	MOVE	#1,CLIP(A0)
	move	#1,XMN_CLIP(A0)
	move	#1,YMN_CLIP(A0)
	move	#319,XMX_CLIP(A0)
	move	#199,YMX_CLIP(A0)

	move.l a0,lineA_tab

	move.l #pattern,46(a0)
	move #0,50(a0)
	move #0,36(a0)
	move #-1,24(a0)
	move #0,26(a0)
	move #0,28(a0)
	move #0,30(a0)

	move #$2300,sr
	
	bsr text_convert
	
	lea text_buffer_end,a0
	MOVEA.L	TEXT_EC,a1
	lea font,a2
	moveq #0,d0
	move d0,d1
	move #30-1,d7	;30*5=150
text_lp:
	move.b (a1)+,d0
	move.b 3(a2,d0.w),-(a0)
	move.b 2(a2,d0.w),-(a0)
	move.b 1(a2,d0.w),-(a0)
	move.b 0(a2,d0.w),-(a0)
	move.b d1,-(a0)
	dbra d7,text_lp
	move.l a1,text_pt

	lea compteurs,a3
	
	bsr construction
	
	lea ad_routines,a0
	move.l 16(a0),a2
	move #-4,(a3)
	move #-20,2(a3)
	
	lea text_buffer_deb,a5
	move.l a5,text_buff_pt
	MOVEM.L	D0-A6,SAVE_ALL
	
LETSGO:
	clr	x_angle
	clr	y_angle
	clr	z_angle

	CLR.L	POINTEUR
	
	LEA	DATA_X,A1
	
	MOVE	#90*2,x_angle
	MOVE	#90*2,y_angle

	move	#256,z_pt_fuite

	move.l	#(NB_POS)-1,d7
ici	CLR.L	POINTEUR
	jsr	trigo
	ADD.L	#2,POINTEUR2
	rept	NB_PTS
	jsr	sp_to_pl
	jsr	ROUTINE
	endr
	SUB	#2*PAS,y_angle
	dbf	d7,ici

	moveq	#1,d0
	jsr	sound

	JSR	LINE_A_INIT

	MOVE	#1,FG_BP1(A0)
	CLR	FG_BP2(A0)
	CLR	FG_BP3(A0)
	CLR	FG_BP4(A0)
	
	CLR	WRT_MOD(A0)
	
	MOVE.L	#FILL,PATPTR(A0)
	
	MOVE	#1,PATMSK(A0)
	CLR	MULTIFILL(A0)
	MOVE	#1,CLIP(A0)
	move	#1,XMN_CLIP(A0)
	move	#1,YMN_CLIP(A0)
	move	#319,XMX_CLIP(A0)
	move	#199,YMX_CLIP(A0)

	LEA	BUFCOD,A0
	MOVE.L	A0,SAVEA0
	LEA	TABLE,A4
	MOVE.L	A4,SAVEA4
	
mainloop	MOVE.L	#NB_POS-1,D0
GEN
	MOVE.L	D0,SAVED0
	JSR	EFF
	REPT	SEG
	bsr	poly
	ENDR

	MOVE	#3999,D0
	MOVE.L	SCREEN1,A0
	LEA	BUF2,A1
	LEA	BUF1,A2
KL	MOVE	(A1),(A2)+
	MOVE	(A0),(A1)+
	LEA	8(A0),A0
	dbf	d0,KL

	JSR	GENERE1
	MOVEQ	#0,D0
	MOVEQ	#0,D3
	LEA	DATAS,A0
	LEA	FINAL,A1
	LEA	-8(A0),A0
LOOPED	LEA	8(A0),A0
	MOVE.L	(A0),D2
	MOVE.L	4(A0),D1
	CMPI.L	#0,(A0)
	BEQ.S	OKVAZY
	CMP.L	D0,D1
	BLE.S	LOOPED
	MOVE.L	D1,D0
	MOVE.L	D2,D4
;	MOVE.L	#1,4(A0)
	BRA.S	LOOPED
	
OKVAZY	
	LEA	DATAS,A0	;
	LEA	-8(A0),A0	;
BOUI	LEA	8(A0),A0	;
	CMP.L	(A0),D4	;
	BNE.S	BOUI	;
	CLR.L	4(A0)	;

	MOVE.L	D4,(A1)+
	MOVE.L	D0,(A1)+
	CMPI.L	#7,D3
	BEQ.S	LP
	ADDQ.L	#1,D3
	MOVEQ	#0,D0
	LEA	DATAS,A0
	LEA	-8(A0),A0
	BRA.S	LOOPED
	
LP	LEA	DATAS,A0
	MOVE	#1999,D0
P	CLR.L	(A0)+
	DBF	D0,P
	JSR	GENERE2

	MOVE.L	SAVED0,D0
	DBF	D0,GEN
GEN2
	MOVE.L	D0,SAVED0
	JSR	EFF
	CLR.L	PNT
	REPT	SEG
	bsr	poly
	ENDR

	MOVE	#3999,D0
	MOVE.L	SCREEN1,A0
	LEA	BUF2,A1
	LEA	BUF1,A2
KLD	MOVE	(A1),(A2)+
	MOVE	(A0),(A1)+
	LEA	8(A0),A0
	dbf	d0,KLD

	JSR	GENERE1
	MOVEQ	#0,D0
	MOVEQ	#0,D3
	LEA	DATAS,A0
	LEA	FINAL,A1
	LEA	-8(A0),A0
QLOOPED	LEA	8(A0),A0
	MOVE.L	(A0),D2
	MOVE.L	4(A0),D1
	CMPI.L	#0,(A0)
	BEQ.S	QOKVAZY
	CMP.L	D0,D1
	BLE.S	QLOOPED
	MOVE.L	D1,D0
	MOVE.L	D2,D4
;	MOVE.L	#1,4(A0)
	BRA.S	QLOOPED
	
QOKVAZY	
	LEA	DATAS,A0	;
	LEA	-8(A0),A0	;
DBOUI	LEA	8(A0),A0	;
	CMP.L	(A0),D4	;
	BNE.S	DBOUI	;
	CLR.L	4(A0)	;

	MOVE.L	D4,(A1)+
	MOVE.L	D0,(A1)+
	CMPI.L	#7,D3
	BEQ.S	QLP
	ADDQ.L	#1,D3
	MOVEQ	#0,D0
	LEA	DATAS,A0
	LEA	-8(A0),A0
	BRA.S	QLOOPED
	
QLP	LEA	DATAS,A0
	MOVE	#1999,D0
QP	CLR.L	(A0)+
	DBF	D0,QP
	JSR	GENERE2

	MOVE.L	SAVED0,D0
	MOVE	#$2700,SR
	JSR	EFF
	JSR	EFF2

	CLR.L	$FFFF8240.W
	CLR.L	$FFFF8244.W
	CLR.L	$FFFF8248.W
	CLR.L	$FFFF824C.W
	CLR.L	$FFFF8250.W
	CLR.L	$FFFF8254.W
	CLR.L	$FFFF8258.W
	CLR.L	$FFFF825C.W

	MOVE.L	SCREEN1,A0
	LEA	2(A0),A0
	MOVE	#7999,D0
PLAN2	MOVE	#$FFFF,(A0)
	LEA	8(A0),A0
	DBF	D0,PLAN2
	
	MOVE.L	SCREEN1,A0
	LEA	TABLE,A1
	MOVE.L	(A1),A1
	MOVEM.L	(A1),D0-D7
	JSR	8*4(A1)
	MOVE.L	SCREEN2,A0
	LEA	TABLE,A1
	MOVE.L	(A1),A1
	MOVEM.L	(A1),D0-D7
	JSR	8*4(A1)
	
	LEA	TABLE+4,A1

	MOVEM.L	D0-A6,-(SP)

	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	CLR.B	$FFFFFA13.W
	CLR.B	$FFFFFA15.W
	
	MOVE.L	#VBL_IR,$70.W
	MOVE.L	#TB0_IR,$120.W
	
	MOVE.B	#$12,$FFFFFC02.W
	
	CLR.B	$FFFFFA1B.W
	BSET	#0,$FFFFFA07.W
	BSET	#0,$FFFFFA13.W
	
	clr	x_angle
	clr	y_angle
	MOVE	#90*2,y_angle
	clr	z_angle
	CLR.L	POINTEUR
	LEA	DATA_X,A1
	move	#256,z_pt_fuite
	move.l	#NB_POS_CUB-1,d7
Xici	CLR.L	POINTEUR
	jsr	trigo
	MOVE.L	#NB_PTSCUB-1,D6
OP1	jsr	sp_to_pl2
	jsr	ROUTINE
	DBF	D6,OP1
;	ADD	#2*PAS_CUB,x_angle
	SUB	#2*PAS_CUB,y_angle
;	ADD	#2*PAS_CUB,z_angle
	dbf	d7,Xici

	MOVEM.L	(SP)+,D0-A6
	CLR.L	PNT
	MOVE	#$2300,SR
J	BRA.S	J

TB0_IR
	MOVE	#$666,$FFFF8246.W
	MOVE	#$666,$FFFF8254.W
	MOVE	#$006,$FFFF8244.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB1_IR,$120.W
	MOVE.B	#20,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE	
TB1_IR
	MOVE	#$555,$FFFF8246.W
	MOVE	#$555,$FFFF8254.W
	MOVE	#$005,$FFFF8244.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB2_IR,$120.W
	MOVE.B	#15,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE	
TB2_IR
	MOVE	#$444,$FFFF8246.W
	MOVE	#$444,$FFFF8254.W
	MOVE	#$004,$FFFF8244.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB3_IR,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE	
TB3_IR
	MOVE	#$333,$FFFF8246.W
	MOVE	#$333,$FFFF8254.W
	MOVE	#$003,$FFFF8244.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB4_IR,$120.W
	MOVE.B	#5,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE	
TB4_IR
	MOVE	#$222,$FFFF8246.W
	MOVE	#$222,$FFFF8254.W
	MOVE	#$002,$FFFF8244.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB5_IR,$120.W
	MOVE.B	#3,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE	
TB5_IR
	MOVE	#$111,$FFFF8246.W
	MOVE	#$111,$FFFF8254.W
	MOVE	#$001,$FFFF8244.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB5B_IR,$120.W
	MOVE.B	#23,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
TB5B_IR
	MOVE	#$100,$FFFF8250.W
	MOVE	#$100,$FFFF8252.W
	MOVE	#$100,$FFFF8254.W
	MOVE	#$100,$FFFF8256.W
;	MOVE	#$700,$FFFF8258.W
;	MOVE	#$700,$FFFF825A.W
;	MOVE	#$700,$FFFF825C.W
;	MOVE	#$700,$FFFF825E.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB6_IR,$120.W
	MOVE.B	#23,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
TB6_IR
	MOVE	#$222,$FFFF8246.W
	MOVE	#$002,$FFFF8244.W
	MOVE	#$200,$FFFF8250.W
	MOVE	#$200,$FFFF8252.W
	MOVE	#$200,$FFFF8254.W
	MOVE	#$200,$FFFF8256.W

	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB7_IR,$120.W
	MOVE.B	#3,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE	
TB7_IR
	MOVE	#$333,$FFFF8246.W
	MOVE	#$003,$FFFF8244.W
	MOVE	#$300,$FFFF8250.W
	MOVE	#$300,$FFFF8252.W
	MOVE	#$300,$FFFF8254.W
	MOVE	#$300,$FFFF8256.W

	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB8_IR,$120.W
	MOVE.B	#5,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
TB8_IR
	MOVE	#$444,$FFFF8246.W
	MOVE	#$004,$FFFF8244.W
	MOVE	#$400,$FFFF8250.W
	MOVE	#$400,$FFFF8252.W
	MOVE	#$400,$FFFF8254.W
	MOVE	#$400,$FFFF8256.W

	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB9_IR,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
TB9_IR
	MOVE	#$555,$FFFF8246.W
	MOVE	#$005,$FFFF8244.W
	MOVE	#$500,$FFFF8250.W
	MOVE	#$500,$FFFF8252.W
	MOVE	#$500,$FFFF8254.W
	MOVE	#$500,$FFFF8256.W

	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB10_IR,$120.W
	MOVE.B	#15,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
TB10_IR
	MOVE	#$666,$FFFF8246.W
	MOVE	#$006,$FFFF8244.W
	MOVE	#$600,$FFFF8250.W
	MOVE	#$600,$FFFF8252.W
	MOVE	#$600,$FFFF8254.W
	MOVE	#$600,$FFFF8256.W

	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB11_IR,$120.W
	MOVE.B	#20,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
TB11_IR
	MOVE	#$777,$FFFF8246.W
	MOVE	#$007,$FFFF8244.W
	MOVE	#$700,$FFFF8250.W
	MOVE	#$700,$FFFF8252.W
	MOVE	#$700,$FFFF8254.W
	MOVE	#$700,$FFFF8256.W

	CLR.B	$FFFFFA1B.W
;	MOVE.L	#TB11_IR,$120.W
;	MOVE.B	#20,$FFFFFA21.W
;	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
VBL_IR
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB0_IR,$120.W
	MOVE.B	#82-56-3,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W

;0000	40  FOND NOIR
	SF	$FFFF8240.W
;0001	42  DAMIER+PLAN2 VIDE
	ST	$FFFF8242.W
;0010	44  PLAN2 PLEIN BLEU
	MOVE	#$007,$FFFF8244.W
;0011	46  BLEU+BLANC=BLANC
	ST	$FFFF8246.W
;0100	48  CUBE SEUL/PLAN2 VIDE=SCROL VISIBLE
	MOVE	#$070,$FFFF8248.W
;0101	4A  CUBE+DAM BLANC/PLAN2 VIDE
	MOVE	#$070,$FFFF824A.W
;0110	4C  CUBE+DAM BLEU=CUBE VERT
	MOVE	#$070,$FFFF824C.W
;0111	4E  CUBE+DAMS=CUBE VERT
	MOVE	#$070,$FFFF824E.W
;1000	50  DAM/PLAN2 VIDE
	ST	$FFFF8250.W
;1001	52
	ST	$FFFF8252.W
;1010	54
	ST	$FFFF8254.W
;1011	56
	ST	$FFFF8256.W
;1100	58
	MOVE	#$070,$FFFF8258.W
;1101	5A
	MOVE	#$070,$FFFF825A.W
;1110	5C
	MOVE	#$070,$FFFF825C.W
;1111	5E
	MOVE	#$070,$FFFF825E.W


	MOVEM.L	D0-A6,-(SP)
	JSR	sound+8
	JSR	EFECR
***CUBE
	REPT	NB_SEG
	LEA	DATA_X,A0
	ADDA.L	PNT,A0
	MOVE	(A0)+,D0
	MOVE	(A0)+,D1
	MOVE	(A0)+,D2
	MOVE	(A0)+,D3
	ADD.L	#4*2,PNT
	jsr	trace
	ENDR

	CMPI.L	#4*2*NB_SEG*NB_POS_CUB,PNT
	BNE.S	NO_P
	CLR.L	PNT
NO_P	
****

	MOVEM.L	(SP)+,D0-A6

	MOVE.L	(A1)+,A2
	CMPI.L	#0,-4(A1)
	BNE.S	ROUL
	LEA	TABLE+4,A1
	MOVE.L	(A1)+,A2
ROUL	MOVEM.L	(A2),D0-D7
	MOVE.L	SCREEN1,A0
	JSR	8*4(A2)
	MOVE.L	SCREEN2,A0
	JSR	8*4(A2)

	MOVEM.L	D0-A6,-(SP)
	MOVE.L	SCREEN1,A1	*
	MOVE.L	SCREEN1,A0	*
	LEA	160*199(A0),A0
N	SET	0
N2	SET	0
	REPT	82
	MOVE	N+6(A1),N2(A0)
	MOVE	N+8(A1),N2+8(A0)
;	MOVE.L	N+6(A1),N+6(A0)

	MOVE	N+6+16(A1),N2+16(A0)
	MOVE	N+8+16(A1),N2+8+16(A0)
;	MOVE.L	6+16(A1),N+6+16(A0)

	MOVE	N+6+32(A1),N2+32(A0)
	MOVE	N+8+32(A1),N2+8+32(A0)
;	MOVE.L	6+32(A1),6+32(A0)

	MOVE	N+6+48(A1),N2+48(A0)
	MOVE	N+8+48(A1),N2+8+48(A0)
;	MOVE.L	6+48(A1),6+48(A0)

	MOVE	N+6+64(A1),N2+64(A0)
	MOVE	N+8+64(A1),N2+8+64(A0)
;	MOVE.L	6+64(A1),6+64(A0)

	MOVE	N+6+80(A1),N2+80(A0)
	MOVE	N+8+80(A1),N2+8+80(A0)
;	MOVE.L	6+80(A1),6+80(A0)

	MOVE	N+6+96(A1),N2+96(A0)
	MOVE	N+8+96(A1),N2+8+96(A0)
;	MOVE.L	6+96(A1),6+96(A0)

	MOVE	N+6+112(A1),N2+112(A0)
	MOVE	N+8+112(A1),N2+8+112(A0)
;	MOVE.L	6+112(A1),6+112(A0)

	MOVE	N+6+128(A1),N2+128(A0)
	MOVE	N+8+128(A1),N2+8+128(A0)
;	MOVE.L	6+128(A1),6+128(A0)

	MOVE	N+6+144(A1),N2+144(A0)
	MOVE	N+8+144(A1),N2+8+144(A0)
;	MOVE.L	6+144(A1),6+144(A0)
	
;	LEA	-160(A0),A0
;	LEA	160(A1),A1
N	SET	N+160
N2	SET	N2-160
	ENDR

	MOVEM.L	(SP)+,D0-A6

	SF	$FFFF8240.W
	
KK
	JSR	FLEXI_ROUTY

	movem.l	d0-a6,-(sp)
	move.l	SCREEN1,d0
	MOVE.L	SCREEN2,SCREEN1
	MOVE.L	D0,SCREEN2
	lsr.l	#8,d0
	move.l	#$ffff8201,a0
	movep	d0,(a0)
	movem.l	(sp)+,d0-a6

	CMPI.B	#$39,$FFFFFC02.W
	BEQ.S	FIN
	RTE
FIN:	MOVE.L	4.W,A0
	JMP	(A0)

FLEXI_ROUTY
	MOVEM.L	D0-A6,-(SP)
	MOVEM.L	SAVE_ALL,D0-A6
	moveq #0,d0
	moveq #1,d1
	moveq #2,d2
	moveq #3,d3
	moveq #4,d4

	move.l	#$ffffffff,d6
	move.l text_buff_pt,a5
	move.l SCREEN1,a6
	LEA	160*30+6(A6),A6
	jsr (a2)
	move.l (a0)+,a1
	jsr (a1)

	addQ #1,(a3)
	bne END_ROUTY

	move #-4,(a3)
	lea ad_routines,a0
	sub.l d1,text_buff_pt
	
	addQ #1,2(a3)
	bne END_ROUTY
	
	move #-20,2(a3)
	lea text_buffer_deb,a5
	move.l a5,text_buff_pt
	movem.l 70(a5),d0-d7/a1/a6
	movem.l d0-d7/a1/a6,90(a5)
	movem.l 30(a5),d0-d7/a1/a6
	movem.l d0-d7/a1/a6,50(a5)
	movem.l -10(a5),d0-d7/a1/a6
	movem.l d0-d7/a1/a6,10(a5)
	movem.w -20(a5),d0-d4
	movem.w d0-d4,(a5)
	
	move.l text_pt,a1
	lea font,a6
	moveq #0,d0
	move d0,d1
	move #4-1,d7	;4*5=20
text_lp2:
	move.b (a1)+,d0
	cmpi.b	#255,d0
	bne.s	pas_la_fin
	MOVEA.L	TEXT_EC,A1
	move.l a1,text_pt
	move.b (a1)+,d0
pas_la_fin
	move.b 3(a6,d0.w),-(a5)
	move.b 2(a6,d0.w),-(a5)
	move.b 1(a6,d0.w),-(a5)
	move.b 0(a6,d0.w),-(a5)
	move.b d1,-(a5)
	dbra d7,text_lp2
	move.l a1,text_pt
END_ROUTY	
	MOVEM.L	D0-A6,SAVE_ALL
	MOVEM.L	(SP)+,D0-A6
	RTS

EFECR	

	movea.l	SCREEN1,a0	*
	lea	4+46*160+56-8(a0),a0
	moveQ	#0,d0
efecr1
N	SET	0
	REPT	103
	move	d0,N(a0)
	move	d0,N+8(a0)
	move	d0,N+16(a0)
	move	d0,N+24(a0)
	move	d0,N+32(a0)
	move	d0,N+40(a0)
	move	d0,N+48(a0)
	move	d0,N+56(a0)
N	SET	N+160
	ENDR
	RTS

EFF	move.l	SCREEN1,a0
	MOVE	#7999,D0
HA	CLR.L	(A0)+
	DBF	D0,HA
	RTS	
EFF2	move.l	SCREEN2,a0
	MOVE	#7999,D0
HA2	CLR.L	(A0)+
	DBF	D0,HA2
	RTS	

SAVED0	DS.L	1
SAVEA0	DS.L	1
SAVEA4	DS.L	1
GENERE1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.L	#-16+6,D7	OFFSET
	LEA	BUF1,A1
	LEA	BUF2,A2
	LEA	DATAS,A6
;	MOVE.L	SAVEA0,A0
;	MOVE.L	SAVEA4,A4
;	MOVE.L	A0,(A4)+
;	MOVE.L	A4,SAVEA4
	
LOOP	ADD.L	#16,D7
	CMPI	#32000,D7
	BGT	FINI
	MOVE	(A1)+,D0
	MOVE	(A1)+,D1
	MOVE	(A2)+,D2
	MOVE	(A2)+,D3

	CMP	D0,D2
	BEQ.S	SAME_MOT1
	CMP	D1,D3
	BEQ.S	SAME_MOT2
	CMPI	#0,D3
	BEQ.S	PLAN2_VIDE
MOVEL	;MOVE	#$217C,(A0)+
	;MOVE	D2,(A0)+
	;MOVE	D3,(A0)+


	MOVE	D2,D5
	SWAP	D5
	MOVE	D3,D5
	JSR	DO_IT
	
	;MOVE	D7,(A0)+
	BRA.S	LOOP
PLAN2_VIDE	CMPI	#0,D2
	BNE.S	MOVEL
	;MOVE	#$42A8,(A0)+
	;MOVE	D7,(A0)+
	BRA.S	LOOP

SAME_MOT2	CMPI	#0,D2
	BNE.S	MOVE_PLAN1
CLR_PLAN1	;MOVE	#$4268,(A0)+
	;MOVE	D7,(A0)+
	BRA.S	LOOP
MOVE_PLAN1	;MOVE	#$317C,(A0)+
	;MOVE	D2,(A0)+
	;MOVE	D7,(A0)+
	BRA.S	LOOP

SAME_MOT1	CMP	D1,D3
	BEQ.S	LOOP
	CMPI	#0,D3
	BNE.S	MOVE_PLAN2
CLR_PLAN2	;MOVE	#$4268,(A0)+
	;MOVE	D7,(A0)
	;ADDQ	#2,(A0)+
	BRA.S	LOOP
MOVE_PLAN2	;MOVE	#$317C,(A0)+
	;MOVE	D3,(A0)+
	;MOVE	D7,(A0)
	;ADDQ	#2,(A0)+
	BRA	LOOP
	
FINI	;MOVE	#$4E75,(A0)+
	;MOVE.L	A0,SAVEA0
	RTS

GENERE2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D6
	MOVE.L	#-16+6,D7	OFFSET
	LEA	BUF1,A1
	LEA	BUF2,A2
	LEA	FINAL,A6
	MOVE.L	SAVEA0,A0
	MOVE.L	SAVEA4,A4
	MOVE.L	A0,(A4)+
	MOVE.L	A4,SAVEA4
	REPT	8
	MOVE.L	(A6)+,(A0)+
	MOVE.L	(A6)+,D0
	ENDR
	MOVEQ	#0,D0
WLOOP	ADD.L	#16,D7
	CMPI	#32000,D7
	BGT	WFINI
	MOVE	(A1)+,D0
	MOVE	(A1)+,D1
	MOVE	(A2)+,D2
	MOVE	(A2)+,D3

	CMP	D0,D2
	BEQ	WSAME_MOT1
	CMP	D1,D3
	BEQ.S	WSAME_MOT2
	CMPI	#0,D3
	BEQ.S	WPLAN2_VIDE
WMOVEL	

	MOVE.B	#$40,D6
	LEA	FINAL,A6
	MOVE	D2,D5
	SWAP	D5
	MOVE	D3,D5
	LEA	-8(A6),A6
TROUVE	LEA	8(A6),A6
	CMP.L	(A6),D5
	BEQ.S	C_LE_MEME
	ADDQ.B	#1,D6
	CMPI.B	#$48,D6
	BEQ.S	PADFRQ
	BRA.S	TROUVE
C_LE_MEME	MOVE.B	#$21,(A0)+
	MOVE.B	D6,(A0)+
	MOVE	D7,(A0)+
	BRA.S	WLOOP
PADFRQ	
	MOVE	#$217C,(A0)+
	MOVE	D2,(A0)+
	MOVE	D3,(A0)+
	MOVE	D7,(A0)+
	BRA.S	WLOOP
WPLAN2_VIDE	CMPI	#0,D2
	BNE.S	WMOVEL
	MOVE	#$42A8,(A0)+
	MOVE	D7,(A0)+
	BRA.S	WLOOP

WSAME_MOT2	CMPI	#0,D2
	BNE.S	WMOVE_PLAN1
WCLR_PLAN1	MOVE	#$4268,(A0)+
	MOVE	D7,(A0)+
	BRA.S	WLOOP
WMOVE_PLAN1	
	MOVE.B	#$40,D6
	LEA	FINAL,A6
	MOVE	D2,D5
	LEA	-8(A6),A6
TROUVE2	LEA	8(A6),A6
	CMP	2(A6),D5
	BEQ.S	C_LE_MEME2
	ADDQ.B	#1,D6
	CMPI.B	#$48,D6
	BEQ.S	PADFRQ2
	BRA.S	TROUVE2
C_LE_MEME2	MOVE.B	#$31,(A0)+
	MOVE.B	D6,(A0)+
	MOVE	D7,(A0)+
	BRA	WLOOP
PADFRQ2

	MOVE	#$317C,(A0)+
	MOVE	D2,(A0)+
	MOVE	D7,(A0)+
	BRA	WLOOP

WSAME_MOT1	CMP	D1,D3
	BEQ	WLOOP
	CMPI	#0,D3
	BNE.S	WMOVE_PLAN2
WCLR_PLAN2	MOVE	#$4268,(A0)+
	MOVE	D7,(A0)
	ADDQ	#2,(A0)+
	BRA	WLOOP
WMOVE_PLAN2	
	MOVE.B	#$40,D6
	LEA	FINAL,A6
	MOVE	D3,D5
	LEA	-8(A6),A6
TROUVE3	LEA	8(A6),A6
	CMP	2(A6),D5
	BEQ.S	C_LE_MEME3
	ADDQ.B	#1,D6
	CMPI.B	#$48,D6
	BEQ.S	PADFRQ3
	BRA.S	TROUVE3
C_LE_MEME3	MOVE.B	#$31,(A0)+
	MOVE.B	D6,(A0)+
	MOVE	D7,(A0)
	ADDQ	#2,(A0)+
	BRA	WLOOP
PADFRQ3


	MOVE	#$317C,(A0)+
	MOVE	D3,(A0)+
	MOVE	D7,(A0)
	ADDQ	#2,(A0)+
	BRA	WLOOP
	
WFINI	MOVE	#$4E75,(A0)+
	MOVE.L	A0,SAVEA0
	RTS

DO_IT	MOVEM.L	D0-A6,-(SP)
	LEA	DATAS,A0
HERE	CMPI.L	#0,(A0)
	BEQ.S	OKEY
	CMP.L	(A0),D5
	BEQ.S	IDEM
	LEA	8(A0),A0
	BRA.S	HERE
IDEM	LEA	4(A0),A0
	ADDQ.L	#1,(A0)+
	BRA.S	HER
	
OKEY	MOVE.L	D5,(A0)+
	MOVE.L	#1,(A0)+
HER	MOVEM.L	(SP)+,D0-A6
	RTS

text_convert:
	MOVEA.L	TEXT_EC,A0
	moveq #-1,d1
convert_lp:
	moveq #0,d0
	move.b (a0),d0
	cmp.b d1,d0
	bne.S convert_suite
	cmp.b #255,1(a0)
	beq.S convert_fin
	addq #1,a0
	bra.s convert_lp
convert_suite:
	cmp.b #$20,d0
	blo.s int2_conv
	cmp.b #$21,d0
	bhi.s int2_conv
	sub #$20,d0
	bra.S next_octet
int2_conv:
	cmp.b #$41,d0
	blo.s int3_conv
	cmp.b #$5a,d0
	bhi.s int3_conv
	sub #$3f,d0
	bra.S next_octet
int3_conv:
	cmp.b #$30,d0
	blo.s int4_conv
	cmp.b #$39,d0
	bhi.s int4_conv
	sub #$14,d0
	bra.S next_octet
int4_conv:
	cmp.b #$27,d0
	blo.s int5_conv
	cmp.b #$29,d0
	bhi.s int5_conv
	addQ #$2,d0
	bra.S next_octet
int5_conv:
	cmp.b #$2e,d0
	bne.s int6_conv
	subQ #$8,d0
	bra.S next_octet
int6_conv:
	cmp.b #$3a,d0
	bne.s int7_conv
	sub #$13,d0
	bra.S next_octet
int7_conv:
	cmp.b #$2c,d0
	bne.s int8_conv
	subQ #$4,d0
next_octet:
	lsl #2,d0
	move.b d0,(a0)+
	bra.S convert_lp
convert_fin:
	rts
int8_conv:
	jmp	FIN

construction:
	movem.l a0-a6/d1/d7,-(sp)
	
	lea off_bolean,a6
	move #125-1,d7
	moveq #0,d6
off_bol_lp:
	move.l d6,(a6)+
	dbra d7,off_bol_lp

	move.l #ad_routines,routs_pt
	lea	_PTSIN,a3
	move.l a3,usp
	move.l	COURB_EC,a4
	
	move.l lineA_tab,a6
	lea routines,a5

	move #4-1,d7	;4 pas
pas_lp:
	move d7,-(sp)
	move.l routs_pt,a0
	move.l a5,(a0)+
	move.l a0,routs_pt

	move COLONNE,d7
col_lp:

	move #$1e1d,(a5)+
	move #5-1,d6
ligne_lp:

	CLR	D5
	move.b d6,d5
	
	MOVE	#$0807,(A5)+
	move	d5,(a5)+

	move.l a5,-(sp)
	move #$6700,(a5)+

	move.l (a4),(a3)+	;l,c
	move.l 4(a4),(a3)+	;l+1,c
	move.l 4+24(a4),(a3)+	;l+1,c+1
	move.l 24(a4),(a3)+	;l,c+1
	move.l (a4),(a3)	;l,c
	move.l usp,a3
	addq #4,a4

	move #+30000,d4	;ymin
	move #-30000,d5	;ymax
	move 2(a3),d3	;recherche de ymin et ymax
	cmp d3,d4
	ble.s pas_inf1
	move d3,d4
pas_inf1:
	cmp d3,d5
	bge.s pas_sup1
	move d3,d5
pas_sup1:
	move 6(a3),d3
	cmp d3,d4
	ble.s pas_inf2
	move d3,d4
pas_inf2:
	cmp d3,d5
	bge.s pas_sup2
	move d3,d5
pas_sup2: 
	move 10(a3),d3
	cmp d3,d4
	ble.s pas_inf3
	move d3,d4
pas_inf3:
	cmp d3,d5
	bge.s pas_sup3
	move d3,d5
pas_sup3:	
	move 14(a3),d3
	cmp d3,d4
	ble.s pas_inf4
	move d3,d4
pas_inf4:
	cmp d3,d5
	bge.s pas_sup4
	move d3,d5
pas_sup4:
	sub d4,d5	;ymax-ymin
	move d5,d3	;sauve le compteur en y

	move d4,40(a6)
aff_lp:	
	MOVEM.L	D0-D7/A0-A6,-(A7)
	jsr	FILL1
	MOVEM.L	(A7)+,D0-D7/A0-A6

	addQ #1,40(a6)
	dbra d5,aff_lp

	REPT 4
	move.l (a3)+,38(a6)
	move.l (a3),42(a6)

	movem.l d0-d7/a0-a6,-(a7)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	MOVE	38(a6),D0
	MOVE	40(a6),D1
	
	MOVE	42(a6),D2
	MOVE	44(a6),D3

	bsr	DRAW_A_LINE


	movem.l (a7)+,d0-d7/a0-a6

	ENDR
	
	move.l usp,a3

	move #+30000,d0	;xmin
	move #-30000,d1	;xmax
	move (a3),d2	;recherche de xmin et xmax
	cmp d2,d0
	ble.s xpas_inf1
	move d2,d0
xpas_inf1:
	cmp d2,d1
	bge.s xpas_sup1
	move d2,d1
xpas_sup1:
	move 4(a3),d2
	cmp d2,d0
	ble.s xpas_inf2
	move d2,d0
xpas_inf2:
	cmp d2,d1
	bge.s xpas_sup2
	move d2,d1
xpas_sup2: 
	move 8(a3),d2
	cmp d2,d0
	ble.s xpas_inf3
	move d2,d0
xpas_inf3:
	cmp d2,d1
	bge.s xpas_sup3
	move d2,d1
xpas_sup3:	
	move 12(a3),d2
	cmp d2,d0
	ble.s xpas_inf4
	move d2,d0
xpas_inf4:
	cmp d2,d1
	bge.s xpas_sup4
	move d2,d1
xpas_sup4:
	lsr #4,d0	;on obtient le num‚ro du groupe de 16 pixels
	lsr #4,d1
	sub d0,d1	;compteur
	lsl #3,d0	;*8 => offset en x
	muls #160,d4	;ymin*160 => offset en y
	add d4,d0	;offset / ad ‚cran en .w

	move.l SCREEN1,a0

	move d6,-(sp)
	move d7,-(sp)
	move.l a6,-(sp)
	lea off_bolean,a6
scan_y:		;rep‚rage du polygone
	move d0,d4	;sauvegarde des compteurs
	move d1,d2
scan_x:
	move (a0,d4.w),d5
	beq.s or_nul
	clr (a0,d4.w)	;effa‡age

;	cmp	#$ffff,d5
;	beq.s	move1
	move #$006e,(a5)+	;or #$uuuu,vv(a6)
	move d5,(a5)+	;$uuuu
	move d4,(a5)+	;vv=d16
	bra.s	okay
move1	move #$3d46,(a5)+	;move d6,vv(a6)
	move d4,(a5)+	;vv=d16
okay	move d4,d6	;note l'offset pour l'effa‡age (tjs >=0)
	lsr #3,d6
	move d6,d7
	and #$0007,d6
	lsr #3,d7
	bset.b d6,(a6,d7.w)
or_nul:
	addq #8,d4	;groupe suivant
	dbra d2,scan_x

	add #160,d0	;ligne suivante
	dbra d3,scan_y

	move.l (sp)+,a6
	move (sp)+,d7
	move (sp)+,d6

	move.l a5,d0	;on peut calculer l'offset pour beq.s
	move.l (sp)+,a1
	sub.l a1,d0
	subq #2,d0
	cmp #127,d0	;ok pour beq.S ?
	blo.s offset_short
	move #$6700,(a1)+	;beq.l
	move.l a5,a0
	move d0,d1
	addq #2,d0
	lsr #1,d1
off_l_lp:
	move -(a0),2(a0)
	dbra d1,off_l_lp
	move d0,(a1)+
	addq #2,a5
	bra.s off_l_fin
offset_short:
	move.b d0,1(a1)		;offset pour le beq.s
off_l_fin:

	cmp.l #routines+70000,a5
	blo.s mem_ok
	jmp	FIN
mem_ok:

	dbra d6,ligne_lp
	addq #4,a4

	dbra d7,col_lp
	add #24,a4

	move (sp)+,d7
	move #$4e75,(a5)+	;rts
	dbra d7,pas_lp



	move.l routs_pt,a0
	move.l a5,(a0)+
	move.l a0,routs_pt

	move #$2E3C,(a5)+	;moveq #0,d7
	move.L #$0,(a5)+	;moveq #0,d7
	lea off_bolean,a0	;routine d'effa‡age: les bits concernent
	moveq #0,d5	; les mots du premier plan,dans l'ordre;
	move #500-1,d7	; bit=1 effacer plan 1 de ce groupe de 16 
off_oct_lp:		; pixels, ne rien faire sinon.
	move.b (a0)+,d5
	moveq #8-1,d6
off_bit_lp:
	btst d6,d5
	beq.s bit_nul_off
	move #$3d47,(a5)+	;move d7,xx(a6)
	move #499,d4
	sub d7,d4
	lsl #3,d4
	add d6,d4
	lsl #3,d4
	move d4,(a5)+		;offset
	
	cmp.l #routines+70000,a5
	blo.s mem_ok2
	jmp	FIN
mem_ok2:

bit_nul_off:
	dbra d6,off_bit_lp
	dbra d7,off_oct_lp
	
	move #$4e75,(a5)+	;rts

	movem.l (sp)+,a0-a6/d1/d7
	rts

trigo	movem.l d0-d7/a4-a6,-(a7)

	lea cos_tab,a4
	lea sin_tab,a5

	lea x_angle,a6
	move.w (a6)+,d2
	move.w (a6)+,d1
	move.w (a6)+,d0
	
	move.w 0(a5,d2.w),d5
	move.w 0(a4,d2.w),d4
	move.w 0(a5,d1.w),d3
	move.w 0(a4,d1.w),d2
	move.w 0(a5,d0.w),d1
	move.w 0(a4,d0.w),d0

	lea var_3d,a6
	moveq #9,d7
sp_c	move.w d3,d6
	neg.w d6
	move.w d6,(a6)+
sp_f	move.w d2,d6
	muls d5,d6
	asr.l d7,d6
	move.w d6,(a6)+
sp_i	move.w d2,d6
	muls d4,d6
	asr.l d7,d6
	move.w d6,(a6)+

sp_a	move.w d0,d6
	muls d2,d6
	asr.l d7,d6
	move.w d6,(a6)+

sp_d	move.w d1,d6
	muls d4,d6
	asr.l d7,d6
	movea.w d6,a4

	move.w d0,d6
	muls d3,d6
	asr.l d7,d6
	muls d5,d6

	asr.l d7,d6
	sub.w a4,d6

	move.w d6,(a6)+	

sp_g	move.w d1,d6
	muls d5,d6
	asr.l d7,d6
	movea.w d6,a4

	move.w d0,d6
	muls d3,d6
	asr.l d7,d6
	muls d4,d6
		
	asr.l d7,d6
	add.w a4,d6
		
	move.w d6,(a6)+	

sp_b	move.w d1,d6
	muls d2,d6
	asr.l d7,d6
	move.w d6,(a6)+

sp_e	move.w d0,d6
	muls d4,d6
	asr.l d7,d6
	movea.w d6,a4
	
	move.w d1,d6
	muls d3,d6
	asr.l d7,d6
	muls d5,d6
		
	asr.l d7,d6
	add.w a4,d6
		
	move.w d6,(a6)+	
	
sp_h	move.w d0,d6
	muls d5,d6
	asr.l d7,d6
	movea.w d6,a4
	
	move.w d1,d6
	muls d3,d6
	asr.l d7,d6
	muls d4,d6
		
	asr.l d7,d6
	sub.w a4,d6
		
	move.w d6,(a6)+	
	
	movem.l (a7)+,d0-d7/a4-a6
	rts

sp_to_pl2 movem.l d0-d7/a1-a6,-(a7)
	
	lea 	pointsCUBE,a6
	ADDA.L	POINTEUR,A6
	move.w (a6)+,d0
	move.w (a6)+,d1
	move.w (a6)+,d2
	ADD.L	#6,POINTEUR
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	JMP	SUITE
sp_to_pl movem.l d0-d7/a1-a6,-(a7)
	
	lea 	points,a6
	ADDA.L	POINTEUR,A6
	move.w (a6)+,d0
	move.w (a6)+,d1
	moveq	#0,d2
;	ADD	#30,D2
	ADD.L	#4,POINTEUR
	SUB	#160,D0
	SUB	#100,D1
	
	lea depla,a3
	adda.l	POINTEUR2,A3
	move.w #0,d3	;xdep
	clr.l	d4	;ydep
	move.w (a3)+,d5	;zdep
	move	#-25,d4
;	clr	d5
	move	#85,D5

;	move	d5,d4
;	add	d2,d4
;	cmpi.l	#255,d4
;	bgt.s	oh_no
;	bra.s	oh_yes
;	
;oh_no	sub	#255,D5
;oh_yes	clr.l	d4
	
SUITE	ext.l d3
	ext.l d4
	ext.l d5
	moveq #9,d6
	asl.l d6,d3 	;xdep*512
	asl.l d6,d4		;ydep*512
	asl.l d6,d5		;zdep*512
	movea.l d3,a1	
	movea.l d4,a2
	movea.l d5,a3
	
	lea var_3d,a6	;pointe zone de
			;calcul 
			;intermediaire

	move.w d0,d3	;d3=xe
	move.w d1,d4	;d4=ye
	move.w d2,d5	;d5=ze

	muls (a6)+,d3	;d3=c*xe*512
	muls (a6)+,d4	;d4=f*ye*512
	muls (a6)+,d5	;d5=i*ze*512
	add.l d4,d5		; + f*ye*512
	add.l d3,d5		; + c*xe*512
	add.l a3,d5		; + zdep*512
	move.l d5,a5	;a5=new_ze*512
	divs z_pt_fuite,d5	;d5=new_ze/z_pt_fuite

	move.w #512,d7
	sub.w d5,d7		;d7=512*q
			;d7=512*
			;(1-new_ze/z_pt_fuite)
	
	move.w d0,d3	;d3=xe
	move.w d1,d4	;d4=ye	
	move.w d2,d5	;d5=ze
		
	muls (a6)+,d3	;d3=a*xe*512
	muls (a6)+,d4	;d4=d*ye*512
	muls (a6)+,d5	;d5=g*ze*512
	add.l d4,d5		;+ a*xe*512
	add.l d3,d5		;+ d*xe*512
	add.l a1,d5		;+ xdep*512
	move.l d5,a4	;a4=new_xe*512
	divs d7,d5		;d5.w=
			;(new_xe*512)/(q*512)
			;d5=new_xe/q
	
	muls (a6)+,d0	;d0=b*xe*512
	muls (a6)+,d1	;d1=e*ye*512
	muls (a6)+,d2	;d2=h*ze*512
	add.l d0,d1		; + b*xe*512
	add.l d1,d2		; + e*ye*512
	add.l a2,d2		; + ydep*512
	move.l d2,d6	;d6=new_ye*512
	divs d7,d2		;d2.w=new_ye/q
	
	lea xp,a6		;a6 pointe zone
			;sauvergarde coords
			;plane qu'on
			;centre … l'‚cran

	add.w #160,d5	;d5=xp+160
	move.w d5,(a6)+	;xp
	
	add.w #100,d2	;d2=yp+100
	move.w d2,(a6)+	;yp

	move.l a4,d5	;new_xe*512
	move.l a5,d7	;new_ze*512
	moveq #9,d0
	asr.l d0,d5		;new_xe
	asr.l d0,d6		;new_ye
	asr.l d0,d7		;new_ze
			
			;sauve nouvelles 
			;coords spatiales
	move.w d5,(a6)+	;new_xe
	move.w d6,(a6)+	;new_ye
	move.w d7,(a6)+	;new_ze
	MOVE	D7,ZA	
	movem.l (a7)+,d0-d7/a1-a6
	rts

ROUTINE
	MOVE	xp,(A1)+
	MOVE	yp,(A1)+
	RTS

	
trace:
	movea.l	SCREEN1,a0	*
	LEA	4(A0),A0	
	cmp.w	d0,d2
	bge.s 	suit1
	exg.l	d0,d2
	exg.l	d1,d3 
suit1
	move.w	d1,d7	

	cmp.w	d1,d3
	bge.s 	suit2
	
	exg.l	d1,d3	
	move.w	#-160,d5
	bra.s	suit2s
suit2
	move.w	#160,d5
suit2s
			*_a retoucher
	move.w	d2,d4	*
	sub.w	d0,d2	
	sub.w	d1,d3
	
	add.w	d0,d0	*pour posinit a0
	lea.l	posx(pc),a1		
	move.w	(a1,d0.w),d1
	add.w	d7,d7
	lea.l	posy(pc),a1		
	move.w 	(a1,d7.w),d7	
	add.w	d1,d7
	lea.l	(a0,d7.w),a0
	
	cmp.w	d2,d3
	bge.w	point2
	
	cmp.w	#17,d2
	ble	point11
	
	lea.l	fdpx(pc),a1		;d4=x2
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a1,d4.w),d4
	move.w	d4,saut+2
	swap	d4
	
	lea.l	ddpx(pc),a1		
	add.w	d0,d0	
	move.l	(a1,d0.w),a1
	add.w	d4,a1
	
point1
	addq.l	#1,d2
	swap	d3
	divu	d2,d3	
	moveq.w	#0,d4

	move.w	d3,a2
	move.w	d5,a5
	move.w	#7,d0
	move.w	#6,d1
	move.w	#5,d2
	move.w	#4,d6
	move.w	#3,d7
	move.w	#2,d3
	move.w	#1,d5
	
	jmp	(a1)
lignt	macro

	bset.b	d0,(a0)
	add.w	a2,d4		8
	bcc.s	point111\@1
	add.w	a5,a0
point111\@1	
	bset.b	d1,(a0)		8
	add.w	a2,d4
	bcc.s	point112\@1
	add.w	a5,a0
point112\@1	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	point113\@1		8
	add.w	a5,a0
point113\@1	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	point114\@1		8
	add.w	a5,a0
point114\@1	
	bset.b	d7,(a0)
	add.w	a2,d4		8
	bcc.s	point115\@1
	add.w	a5,a0
point115\@1	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	point116\@1		8
	add.w	a5,a0
point116\@1	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	point117\@1		8
	add.w	a5,a0
point117\@1	
	bset.b	#0,(a0)
	add.w	a2,d4
	addq.l	#1,a0		12
	bcc.s	point118\@1
	add.w	a5,a0			
point118\@1
	bset.b	d0,(a0)		8
	add.w	a2,d4
	bcc.s	point119\@1
	add.w	a5,a0
point119\@1	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	point1110\@1	8
	add.w	a5,a0		
point1110\@1	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	point1111\@1	8
	add.w	a5,a0
point1111\@1			
	bset.b	d6,(a0)
	add.w	a2,d4	8
	bcc.s	point1112\@1
	add.w	a5,a0
point1112\@1	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	point1113\@1	8
	add.w	a5,a0
point1113\@1	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	point1114\@1	8	
	add.w	a5,a0
point1114\@1	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	point1115\@1	8
	add.w	a5,a0
point1115\@1	
	bset.b	#0,(a0)
	add.w	a2,d4	12
	addq.l	#7,a0
	bcc.s	point1115\@1+12
	add.w	a5,a0

	endm
trace11
n	set	0
	rept	20
	lignt	n
n	set	n+1	
	endr
	
saut	bra	ftrac1
ftrac1
	rts

ftrac2	
	bset.b	d0,(a0)
	rts

ftrac3	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf31
	add.w	a5,a0
pointf31	
	bset.b	d1,(a0)
	rts

ftrac4	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf41
	add.w	a5,a0
pointf41	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf42
	add.w	a5,a0
pointf42	
	bset.b	d2,(a0)
	rts

ftrac5	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf51
	add.w	a5,a0
pointf51	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf52
	add.w	a5,a0
pointf52	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf53
	add.w	a5,a0
pointf53	
	bset.b	d6,(a0)
	rts

ftrac6	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf61
	add.w	a5,a0
pointf61	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf62
	add.w	a5,a0
pointf62	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf63
	add.w	a5,a0
pointf63	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf64
	add.w	a5,a0
pointf64	
	bset.b	d7,(a0)
	rts

ftrac7	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf71
	add.w	a5,a0
pointf71	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf72
	add.w	a5,a0
pointf72	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf73
	add.w	a5,a0
pointf73	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf74
	add.w	a5,a0
pointf74	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf75
	add.w	a5,a0
pointf75	
	bset.b	d3,(a0)
	
	rts

ftrac8	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf81
	add.w	a5,a0
pointf81	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf82
	add.w	a5,a0
pointf82	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf83
	add.w	a5,a0
pointf83	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf84
	add.w	a5,a0
pointf84	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf85
	add.w	a5,a0
pointf85	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf86
	add.w	a5,a0
pointf86	
	bset.b	d5,(a0)
	
	rts

ftrac9	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf91
	add.w	a5,a0
pointf91	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf92
	add.w	a5,a0
pointf92	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf93
	add.w	a5,a0
pointf93	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf94
	add.w	a5,a0
pointf94	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf95
	add.w	a5,a0
pointf95	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf96
	add.w	a5,a0
pointf96	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	pointf97
	add.w	a5,a0
pointf97	
	bset.b	#0,(a0)
	
	rts

ftrac10	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf101
	add.w	a5,a0
pointf101	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf102
	add.w	a5,a0
pointf102	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf103
	add.w	a5,a0
pointf103	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf104
	add.w	a5,a0
pointf104	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf105
	add.w	a5,a0
pointf105	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf106
	add.w	a5,a0
pointf106	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	pointf107
	add.w	a5,a0
pointf107	
	bset.b	#0,(a0)
	add.w	a2,d4
	addq.l	#1,a0
	bcc.s	pointf108
	add.w	a5,a0
pointf108	
	bset.b	d0,(a0)
	rts

ftrac11	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf111
	add.w	a5,a0
pointf111	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf112
	add.w	a5,a0
pointf112	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf113
	add.w	a5,a0
pointf113	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf114
	add.w	a5,a0
pointf114	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf115
	add.w	a5,a0
pointf115	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf116
	add.w	a5,a0
pointf116	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	pointf117
	add.w	a5,a0
pointf117	
	bset.b	#0,(a0)
	add.w	a2,d4
	addq.l	#1,a0
	bcc.s	pointf118
	add.w	a5,a0
pointf118	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf119
	add.w	a5,a0
pointf119
	bset.b	d1,(a0)
	rts
	
ftrac12
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf121
	add.w	a5,a0
pointf121	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf122
	add.w	a5,a0
pointf122	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf123
	add.w	a5,a0
pointf123	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf124
	add.w	a5,a0
pointf124	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf125
	add.w	a5,a0
pointf125	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf126
	add.w	a5,a0
pointf126	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	pointf127
	add.w	a5,a0
pointf127	
	bset.b	#0,(a0)
	add.w	a2,d4
	addq.l	#1,a0
	bcc.s	pointf128
	add.w	a5,a0
pointf128	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf129
	add.w	a5,a0
pointf129
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf1210
	add.w	a5,a0
pointf1210
	bset.b	d2,(a0)
	rts
	
ftrac13	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf131
	add.w	a5,a0
pointf131	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf132
	add.w	a5,a0
pointf132	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf133
	add.w	a5,a0
pointf133	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf134
	add.w	a5,a0
pointf134	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf135
	add.w	a5,a0
pointf135	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf136
	add.w	a5,a0
pointf136	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	pointf137
	add.w	a5,a0
pointf137	
	bset.b	#0,(a0)
	add.w	a2,d4
	addq.l	#1,a0
	bcc.s	pointf138
	add.w	a5,a0
pointf138	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf139
	add.w	a5,a0
pointf139
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf1310
	add.w	a5,a0
pointf1310
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf1311
	add.w	a5,a0
pointf1311
	bset.b	d6,(a0)
	rts
	
ftrac14	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf141
	add.w	a5,a0
pointf141	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf142
	add.w	a5,a0
pointf142	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf143
	add.w	a5,a0
pointf143	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf144
	add.w	a5,a0
pointf144	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf145
	add.w	a5,a0
pointf145	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf146
	add.w	a5,a0
pointf146	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	pointf147
	add.w	a5,a0
pointf147	
	bset.b	#0,(a0)
	add.w	a2,d4
	addq.l	#1,a0
	bcc.s	pointf148
	add.w	a5,a0
pointf148	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf149
	add.w	a5,a0
pointf149
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf1410
	add.w	a5,a0
pointf1410
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf1411
	add.w	a5,a0
pointf1411
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf1412
	add.w	a5,a0
pointf1412
	bset.b	d7,(a0)
	rts
	
ftrac15	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf151
	add.w	a5,a0
pointf151	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf152
	add.w	a5,a0
pointf152	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf153
	add.w	a5,a0
pointf153	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf154
	add.w	a5,a0
pointf154	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf155
	add.w	a5,a0
pointf155	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf156
	add.w	a5,a0
pointf156	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	pointf157
	add.w	a5,a0
pointf157	
	bset.b	#0,(a0)
	add.w	a2,d4
	addq.l	#1,a0
	bcc.s	pointf158
	add.w	a5,a0
pointf158	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf159
	add.w	a5,a0
pointf159
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf1510
	add.w	a5,a0
pointf1510
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf1511
	add.w	a5,a0
pointf1511
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf1512
	add.w	a5,a0
pointf1512
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf1513
	add.w	a5,a0
pointf1513
	bset.b	d3,(a0)
	rts
	
ftrac16	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf161
	add.w	a5,a0
pointf161	
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf162
	add.w	a5,a0
pointf162	
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf163
	add.w	a5,a0
pointf163	
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf164
	add.w	a5,a0
pointf164	
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf165
	add.w	a5,a0
pointf165	
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf166
	add.w	a5,a0
pointf166	
	bset.b	d5,(a0)
	add.w	a2,d4
	bcc.s	pointf167
	add.w	a5,a0
pointf167	
	bset.b	#0,(a0)
	add.w	a2,d4
	addq.l	#1,a0
	bcc.s	pointf168
	add.w	a5,a0
pointf168	
	bset.b	d0,(a0)
	add.w	a2,d4
	bcc.s	pointf169
	add.w	a5,a0
pointf169
	bset.b	d1,(a0)
	add.w	a2,d4
	bcc.s	pointf1610
	add.w	a5,a0
pointf1610
	bset.b	d2,(a0)
	add.w	a2,d4
	bcc.s	pointf1611
	add.w	a5,a0
pointf1611
	bset.b	d6,(a0)
	add.w	a2,d4
	bcc.s	pointf1612
	add.w	a5,a0
pointf1612
	bset.b	d7,(a0)
	add.w	a2,d4
	bcc.s	pointf1613
	add.w	a5,a0
pointf1613
	bset.b	d3,(a0)
	add.w	a2,d4
	bcc.s	pointf1614
	add.w	a5,a0
pointf1614
	bset.b	d5,(a0)
	rts	
	
point11
	lea.l	ppxpet(pc),a1
	add.w	d0,d0
	add.w	d0,a1
	
	tst.w	d3
	beq	point12
	move.w	d3,d6
	
	subq.l	#1,d6
	move.w	d2,d4
	addq.l	#2,a1
	move.w	(a1)+,d0
bpoint11
	bset.b	d0,(a0)
	add.w	(a1)+,a0
	move.w	(a1)+,d0
	sub.w	d3,d4
	bge.s	bpoint11
	add.w	d5,a0
	add.w	d2,d4
spoint11
	dbra.w	d6,bpoint11
	rts
point12
	subq.l	#1,d2
	addq.l	#2,a1
	move.w	(a1)+,d0
bpoint12	
	bset	d0,(a0)
	add.w	(a1)+,a0
	move.w	(a1)+,d0
	dbra.w	d2,bpoint12
	rts
point2
	addq.l	#1,d3
	swap	d2
	divu	d3,d2	
	moveq.w	#0,d4
	lea.l	ppxpet(pc),a1
	add.w	d0,d0
	add.w	d0,a1
	addq.l	#2,a1
	move.w	(a1)+,d0
	muls.w	#12,d3
	neg	d3
	lea.l	linvt(pc),a2
	jmp	(a2,d3.w)


lign	macro
	bset.b	d0,(a0)
	add.w	d5,a0
	add.w	d2,d4
	bcc.s	ligv\@1	
	add.w	(a1)+,a0
	move.w	(a1)+,d0
ligv\@1		
	endm

n	set	0
	rept	201
	lign	n
n	set	n+1	
	endr
linvt	
	
	rts

poly:
	JSR	LINE_A_INIT
	
	LEA	DATA_X,A5
	ADDA.L	PNT,A5
	CMPI	#$9999,(A5)
	BNE.S	OKAY3
	CLR.L	PNT
	LEA	DATA_X,A5
	BRA.S	OKAY2
OKAY3	ADD.L	#4*4,PNT
OKAY2	
	moveq	#0,d3

	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move	2(a5),d4
	move	6(a5),d5
	move	10(a5),d6
	move	14(a5),d7

	cmp	d4,d5
	bgt	d5_pg
	move	d4,d5
d5_pg	
	cmp	d6,d5
	bgt	d5_pg2
	move	d6,d5
d5_pg2	
	cmp	d7,d5
	bgt	d5_pg3
	move	d7,d5
d5_pg3	addq	#1,d5
	move	d5,ymax

	moveq	#0,d3

	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move	2(a5),d4
	move	6(a5),d5
	move	10(a5),d6
	move	14(a5),d7

	cmp	d4,d5
	blt	d5_pgh
	move	d4,d5
d5_pgh
	cmp	d6,d5
	blt	d5_pg2h
	move	d6,d5
d5_pg2h	
	cmp	d7,d5
	blt	d5_pg3h
	move	d7,d5
d5_pg3h	subq	#1,d5
	move	d5,ymin
	
;	LEA	TAB,A5
	LEA	_PTSIN,A6
	MOVE.L	(A5)+,(A6)+
	MOVE.L	(A5)+,(A6)+
	MOVE.L	(A5)+,(A6)+
	MOVE.L	(A5)+,(A6)+
	LEA	-4*4(A5),A5
	MOVE.L	(A5)+,(A6)+
	
	MOVE	ymin,D3
LOOP1	MOVE	D3,Y1(A0)
	MOVE.L	A0,-(SP)
;	DC	POLYGON
	cmp	#0,d3
	blt.s	sautX
	cmp	#100,d3
	bge.s	sautX
	JSR	LINE_A_POLYGON
sautX
	MOVE.L	(SP)+,A0
	ADDQ	#1,D3
	CMP	ymax,D3
	BNE	LOOP1

	RTS
ymin	ds	1
ymax	ds	1
LINE_A_INIT
	LEA	EMUL_LINEA,A0
;	LEA	$299A,A0
	MOVE.L	A0,D0
;	LEA	$FCA002,A1
;	LEA	$FC9FC2,A2
	RTS
FILL1
LINE_A_POLYGON
	MOVEM.L	D3-D7/A3-A5,-(SP)
	JSR	_FCA0D6
	MOVEM.L	(SP)+,D3-D7/A3-A5
	RTS

_FCA0D6	;MOVEA.L	$299E,A0
	;MOVE.W	2(A0),D0
	;SUBQ.W	#1,D0
	MOVEQ	#3,D0      NB DE POINTS-1
	
;	MOVEA.L	$29A6,A0
	LEA	_PTSIN,A0
	
;	LEA	$16DA,A1
	LEA	BUF16DA,A1
;	CLR.W	$261E
	CLR.W	PNT_261E
	
LFCA0F4	MOVE.W	6(A0),D1
	MOVE.W	2(A0),D2
	SUB.W	D2,D1
	BEQ.S	LFCA13E
	MOVE.W	EMUL_LINEA-$299A+$29C2,D3
;	MOVE.W	$29C2,D3
	MOVE.W	D3,D4
	SUB.W	D2,D4
	SUB.W	6(A0),D3
	MOVE.W	D4,D2
	EOR.W	D3,D2
	BPL.S	LFCA13E
	MOVE.W	4(A0),D2
	SUB.W	0(A0),D2
	ADD.W	D2,D2
	MULS.W	D2,D4
	DIVS.W	D1,D4
	BPL.S	LFCA12E
	NEG.W	D4
	ADDQ.W	#1,D4
	ASR.W	#1,D4
	NEG.W	D4
	BRA.S	LFCA132
LFCA12E	ADDQ.W	#1,D4
	ASR.W	#1,D4
LFCA132	ADD.W	0(A0),D4
	MOVE.W	D4,(A1)+
;	ADDQ.W	#1,$261E
	ADDQ.W	#1,PNT_261E
	
LFCA13E	LEA	4(A0),A0
	DBF	D0,LFCA0F4
;	MOVE.W	$261E,D0
	MOVE.W	PNT_261E,D0
	BNE.S	LFCA150
	RTS
LFCA150	
	;LEA	$16DA,A0
	LEA	BUF16DA,A0
	BSR	LFCA1DC
;	MOVE.W	$261E,D0
	MOVE.W	PNT_261E,D0
	ASR.W	#1,D0
	SUBQ.W	#1,D0
	TST.W	EMUL_LINEA+$29D0-$299A
	BNE.S	LFCA18A
LFCA16C	
	MOVE.W	(A1)+,EMUL_LINEA+$29C0-$299A
	MOVE.W	(A1)+,EMUL_LINEA+$29C4-$299A
;	MOVE.W	(A1)+,$29C0
;	MOVE.W	(A1)+,$29C4
	MOVE.W	D0,-(A7)
	MOVE.L	A1,-(A7)
	BSR	_FCA5F6
	MOVEA.L	(A7)+,A1
	MOVE.W	(A7)+,D0
	DBF	D0,LFCA16C
	RTS
LFCA18A	
	MOVE.W	(A1)+,EMUL_LINEA+$29C0-$299A
	MOVE.W	(A1)+,EMUL_LINEA+$29C4-$299A
;	MOVE.W	(A1)+,$29C0
;	MOVE.W	(A1)+,$29C4

	MOVE	EMUL_LINEA+$29D2-$299A,D1
	MOVE	EMUL_LINEA+$29C0-$299A,D2
	MOVE	EMUL_LINEA+$29C4-$299A,D3
;	MOVE.W	$29D2,D1
;	MOVE.W	$29C0,D2
;	MOVE.W	$29C4,D3
	CMP.W	D1,D2
	BGE.S	LFCA1B6
	CMP.W	D1,D3
	BLT.S	LFCA1D6
;	MOVE.W	D1,$29C0
	MOVE.W	D1,EMUL_LINEA+$29C0-$299A
LFCA1B6	
	MOVE.W	EMUL_LINEA+$29D6-$299A,D1
;	MOVE.W	$29D6,D1
	CMP.W	D1,D3
	BLE.S	LFCA1CA
	CMP.W	D1,D2
	BGT.S	LFCA1D6
;	MOVE.W	D1,$29C4
	MOVE.W	D1,EMUL_LINEA+$29C4-$299A
LFCA1CA	MOVE.W	D0,-(A7)
	MOVE.L	A1,-(A7)
	BSR	_FCA5F6
	MOVEA.L	(A7)+,A1
	MOVE.W	(A7)+,D0
LFCA1D6	DBF	D0,LFCA18A
	RTS
LFCA1DC	SUBQ.W	#2,D0
	BCS.S	LFCA1FC
	MOVE.W	D0,D1
	MOVEA.L	A0,A1
LFCA1E4	MOVE.W	D1,D0
	MOVEA.L	A1,A0
LFCA1E8	MOVE.W	(A0)+,D2
	CMP.W	(A0),D2
	BLE.S	LFCA1F4
	MOVE.W	(A0),-2(A0)
	MOVE.W	D2,(A0)
LFCA1F4	DBF	D0,LFCA1E8
	DBF	D1,LFCA1E4
LFCA1FC	RTS
	MOVEQ	#1,D1
	MOVE.W	6(A7),D0
	MULS.W	4(A7),D0
	BGE.S	LFCA20C
	NEG.W	D1
LFCA20C	MOVE.W	8(A7),D2
	DIVS.W	D2,D0
	TST.W	D2
	BGE.S	LFCA21A
	NEG.W	D1
	NEG.W	D2
LFCA21A	MOVE.L	D3,-(A7)
	MOVE.L	D0,D3
	BGE.S	LFCA222
	NEG.L	D3
LFCA222	SWAP	D3
	ADD.W	D3,D3
	CMP.W	D2,D3
	BLT.S	LFCA22C
	ADD.W	D1,D0
LFCA22C	MOVE.L	(A7)+,D3
	RTS
	MOVE.W	D2,-(A7)
	MOVE.W	D3,-(A7)
;	MULS.W	$2998,D1
	MULS.W	#160,D1

	MOVE.W	EMUL_LINEA,D3
	MOVE.B	_FCA259(PC,D3.W),D3
	MOVE.W	D0,D2
	EXT.L	D2
	AND.W	#$FFF0,D2
	ASR.W	D3,D2
	ADD.L	D2,D1
	AND.W	#$F,D0
	MOVE.W	(A7)+,D3
	MOVE.W	(A7)+,D2
	RTS
_FCA259	DC.L	$03020001
	DC.L	$00000000

_FCA5D4	DC	$FFFF
_FCA5D6	DC.L	$7FFF3FFF
	DC.L	$1FFF0FFF
	DC.L	$07FF03FF
	DC.L	$01FF00FF
	DC.L	$007F003F
	DC.L	$001F000F
	DC.L	$00070003
	DC.L	$00010000
_FCA5F6
	LEA	EMUL_LINEA,A4
	MOVEM.W	$26(A4),D4-D6
	MOVE.W	D5,D0
	AND.W	$32(A4),D0
	ADD.W	D0,D0
	MOVEA.L	$2E(A4),A0
	ADDA.W	D0,A0
	TST.W	$34(A4)
	SNE	D0
	AND.W	#$20,D0
	MOVE.W	D4,D1
	ASR.W	#4,D1
	MOVE.W	D6,D2
	ASR.W	#4,D2
	MOVEQ	#$F,D3
	AND.W	D3,D4
	ADD.W	D4,D4
	MOVE.W	_FCA5D4(PC,D4.W),D4
	AND.W	D3,D6
	ADD.W	D6,D6
	MOVE.W	_FCA5D6(PC,D6.W),D6
	NOT.W	D6
	SUB.W	D1,D2
	BNE.S	LFCA63C
	AND.W	D6,D4
LFCA63C	MOVEA.L	$9A(A4),A5
;TEST	JMP	(A5)
;	JMP	LFD1B58
	
LFD1B58
	MOVEA.L	SCREEN1,A1
;	MULS.W	-2(A4),D5
	MULS.W	#160,D5
	
	ADDA.L	D5,A1
	MOVEA.W	D0,A2
;	MOVE.W	0(A4),D7

	MOVE.W	#4,D7
	
	MOVE.W	D7,D0
	ADD.W	D0,D0
	MULS.W	D0,D1
	ADDA.L	D1,A1
	SUBQ.W	#1,D7
	LEA	$18(A4),A3
	MOVE.W	$24(A4),D1
	ADD.W	D1,D1
TST	LEA	_FD1B86(PC,D1.W),A5
	ADDA.W	(A5),A5
;	JMP	(A5)
	JMP	LFD1C52
	
_FD1B86	DC.L	$00CC0130
	DC.L	$009C014A
	DC.L	$4E56FFEC

LFD1C52

	NOT.W	D4
	NOT.W	D6
LFD1C56	MOVEA.L	A1,A4
	MOVE.W	D2,D5
	MOVE.W	(A0),D3
	ADDA.W	A2,A0
	TST.W	(A3)+
	BNE.S	LFD1C88
	MOVE.W	D4,D1
	AND.W	D1,(A1)+
	SUBQ.W	#1,D5
	BCS.S	LFD1C7E
	SUBQ.W	#1,D5
	BCS.S	LFD1C78
	CLR.W	D1
LFD1C70	ADDA.W	D0,A4
	MOVE.W	D1,(A4)
	DBF	D5,LFD1C70
LFD1C78	MOVE.W	D6,D1
	ADDA.W	D0,A4
	AND.W	D1,(A4)
LFD1C7E	DBF	D7,LFD1C56
	NOT.W	D4
	NOT.W	D6
	RTS
LFD1C88	MOVE.W	(A4),D1
	EOR.W	D3,D1
	AND.W	D4,D1
	EOR.W	D3,D1
	MOVE.W	D1,(A1)+
	SUBQ.W	#1,D5
	BCS.S	LFD1CAE
	SUBQ.W	#1,D5
	BCS.S	LFD1CA2
LFD1C9A	ADDA.W	D0,A4
	MOVE.W	D3,(A4)
	DBF	D5,LFD1C9A
LFD1CA2	ADDA.W	D0,A4
	MOVE.W	(A4),D1
	EOR.W	D3,D1
	AND.W	D6,D1
	EOR.W	D3,D1
	MOVE.W	D1,(A4)
LFD1CAE	DBF	D7,LFD1C56
	NOT.W	D4
	NOT.W	D6
	RTS

	
DRAW_A_LINE
	cmp.w	d1,d3
	beq	DRAW_HORIZONTAL
	cmp.w	d0,d2
	beq	DRAW_VERTICAL

	move.w	d0,d5
	move.w	d1,d6
	ext.l	d5
	ext.l	d6
	lsl.w	#1,d6
	lea	SCREEN_Y_TABLE,a0
	move.l	#0,a1
	move.w	(a0,d6),a1
	movea.l	SCREEN1,a0
	add.l	a1,a0
	and.l	#$fffffff0,d5
	lsr.w	#1,d5
	add.l	d5,a0
	move.w	d0,d5
	eor.w	#$0f,d5
	and.w	#$0f,d5
	clr.w	d6
	bset	d5,d6
	move.w	d6,d7
	not.w	d6

	sub.w	d0,d2
	sub.w	d1,d3

	move.l	#0,a1
	move.l	#0,a2
	move.l	#0,a3
	move.l	#0,a4
	
	tst.w	d2
	bpl.s	.dr_1
	beq.s	.dr_2
	move.w	#-1,a1
	neg.w	d2
	bra.s	.dr_2
.dr_1
	move.w	#1,a1
.dr_2
	tst.w	d3
	bpl.s	.dr_3
	beq.s	.dr_4
	move.w	#-1,a2
	neg.w	d3
	bra.s	.dr_4
.dr_3
	move.w	#1,a2
.dr_4
	cmp.w	d2,d3
	blt.s	.dr_5
	move.w	a2,a4
	exg	d2,d3
	bra.s	.dr_6
.dr_5
	move.w	a1,a3
.dr_6 
	move.w	d2,d0
	lsr.w	#1,d0
	move.w	d2,d1
.dr_7
	or.w	d7,(a0)
	add.w	d3,d0
	cmp.w	d0,d2
	bgt.s	.dr_8
	sub.w	d2,d0
	cmp.w	#0,a1
	beq.s	.dr_A5
	bmi.s	.dr_A6
	ror.w	#1,d6
	ror.w	#1,d7
	bcc.s	.dr_A5
	addq.l	#8,a0
	bra.s	.dr_A5
.dr_A6
	rol.w	#1,d6
	rol.w	#1,d7
	bcc.s	.dr_A5
	subq.l	#8,a0
.dr_A5
	cmp.w	#0,a2
	beq.s	.dr_A3
	bmi.s	.dr_A8
	lea	160(a0),a0
	bra.s	.dr_A3
.dr_A8
	lea	-160(a0),a0
	bra.s	.dr_A3
.dr_8
	cmp.w	#0,a3
	beq.s	.dr_A1
	bmi.s	.dr_A2
	ror.w	#1,d6
	ror.w	#1,d7
	bcc.s	.dr_A3
	addq.l	#8,a0
	bra.s	.dr_A3
.dr_A2
	rol.w	#1,d6
	rol.w	#1,d7
	bcc.s	.dr_A3
	subq.l	#8,a0
	bra.s	.dr_A3
.dr_A1
	cmp.w	#0,a4
	bmi.s	.dr_A4
	lea	160(a0),a0
	bra.s	.dr_A3
.dr_A4
	lea	-160(a0),a0
.dr_A3
	dbf	d1,.dr_7
	rts

DRAW_HORIZONTAL
	cmp.w	d0,d2
	bne.s	.dr_h_1
	rts
.dr_h_1
	bgt.s	.dr_h_2
	exg	d0,d2
.dr_h_2
	move.w	d0,d5
	move.w	d1,d6
	ext.l	d5
	ext.l	d6
	lsl.w	#1,d6
	lea	SCREEN_Y_TABLE,a0
	move.l	#0,a1
	move.w	(a0,d6),a1
	movea.l	SCREEN1,a0
	add.l	a1,a0
	and.l	#$fffffff0,d5
	lsr.w	#1,d5
	add.l	d5,a0

	move.w	d2,d3
	move.w	d0,d6
	
	and.w	#$fff0,d6
	lsr.w	#4,d6
	and.w	#$fff0,d2
	lsr.w	#4,d2
	
	sub.w	d6,d2

	lea	PIXEL_TABLE_LEFT,a1
	and.w	#$000f,d0
	lsl.w	#1,d0
	move.w	(a1,d0),d0
	lea	PIXEL_TABLE_RIGHT,a1
	and.w	#$000f,d3
	lsl.w	#1,d3
	move.w	(a1,d3),d3

	tst	d2
	bne.s	.dr_h_7
	
	and.w	d0,d3
	move.w	d3,d6
	move.w	d3,d7
	not.w	d7
	bra.s	.dr_h_m_1
.dr_h_7
	subq.w	#1,d2
	bne.s	.dr_h_8
	
	move.w	d0,d6
	move.w	d0,d7
	not.w	d7
	bsr.S	.dr_h_m_1
	
	move.w	d3,d6
	move.w	d3,d7
	not.w	d7
	bra.s	.dr_h_m_1
.dr_h_8
	move.w	d0,d6
	move.w	d0,d7
	not.w	d7
	bsr.S	.dr_h_m_1

	subq.w	#1,d2
	move.w	#$ffff,d6
	clr.w	d7
.dr_h_9
	bsr.S	.dr_h_m_1
	dbf	d2,.dr_h_9
	
	move.w	d3,d6
	move.w	d3,d7
	not.w	d7

.dr_h_m_1
	or.w	d6,(a0)
	lea	8(a0),a0
	rts

DRAW_VERTICAL
	cmp.w	d1,d3
	bgt.s	.dr_v_1
	exg	d1,d3
.dr_v_1
	move.w	d0,d5
	move.w	d1,d6
	ext.l	d5
	ext.l	d6
	lsl.w	#1,d6
	lea	SCREEN_Y_TABLE,a0
	move.l	#0,a1
	move.w	(a0,d6),a1
	movea.l	SCREEN1,a0
	add.l	a1,a0
	and.l	#$fffffff0,d5
	lsr.w	#1,d5
	add.l	d5,a0

	eor.w	#$0f,d0
	and.w	#$0f,d0
	clr.w	d6
	bset	d0,d6
	move.w	d6,d7
	not.w	d7

	sub.w	d1,d3
.dr_v_m_1
	or.w	d6,(a0)

	lea	160(a0),a0
	dbf	d3,.dr_v_m_1
	rts


	DATA


SCREEN_Y_TABLE
	dc.w	0,160,320,480,640,800,960,1120,1280,1440,1600,1760,1920,2080,2240
	dc.w	2400,2560,2720,2880,3040,3200,3360,3520,3680,3840,4000,4160,4320,4480,4640
	dc.w	4800,4960,5120,5280,5440,5600,5760,5920,6080,6240,6400,6560,6720,6880,7040
	dc.w	7200,7360,7520,7680,7840,8000,8160,8320,8480,8640,8800,8960,9120,9280,9440
	dc.w	9600,9760,9920,10080,10240,10400,10560,10720,10880,11040,11200,11360,11520,11680,11840
	dc.w	12000,12160,12320,12480,12640,12800,12960,13120,13280,13440,13600,13760,13920,14080,14240
	dc.w	14400,14560,14720,14880,15040,15200,15360,15520,15680,15840,16000,16160,16320,16480,16640
	dc.w	16800,16960,17120,17280,17440,17600,17760,17920,18080,18240,18400,18560,18720,18880,19040
	dc.w	19200,19360,19520,19680,19840,20000,20160,20320,20480,20640,20800,20960,21120,21280,21440
	dc.w	21600,21760,21920,22080,22240,22400,22560,22720,22880,23040,23200,23360,23520,23680,23840
	dc.w	24000,24160,24320,24480,24640,24800,24960,25120,25280,25440,25600,25760,25920,26080,26240
	dc.w	26400,26560,26720,26880,27040,27200,27360,27520,27680,27840,28000,28160,28320,28480,28640
	dc.w	28800,28960,29120,29280,29440,29600,29760,29920,30080,30240,30400,30560,30720,30880,31040
	dc.w	31200,31360,31520,31680,31840
PIXEL_TABLE_LEFT
	dc.w	%1111111111111111
	dc.w	%0111111111111111
	dc.w	%0011111111111111
	dc.w	%0001111111111111
	dc.w	%0000111111111111
	dc.w	%0000011111111111
	dc.w	%0000001111111111
	dc.w	%0000000111111111
	dc.w	%0000000011111111
	dc.w	%0000000001111111
	dc.w	%0000000000111111
	dc.w	%0000000000011111
	dc.w	%0000000000001111
	dc.w	%0000000000000111
	dc.w	%0000000000000011
	dc.w	%0000000000000001
PIXEL_TABLE_RIGHT
	dc.w	%1000000000000000
	dc.w	%1100000000000000
	dc.w	%1110000000000000
	dc.w	%1111000000000000
	dc.w	%1111100000000000
	dc.w	%1111110000000000
	dc.w	%1111111000000000
	dc.w	%1111111100000000
	dc.w	%1111111110000000
	dc.w	%1111111111000000
	dc.w	%1111111111100000
	dc.w	%1111111111110000
	dc.w	%1111111111111000
	dc.w	%1111111111111100
	dc.w	%1111111111111110
	dc.w	%1111111111111111

MESS_X_COORD	dc.w	0
MESS_Y_COORD	dc.w	0

pattern:	dc.w $ffff

COURB1	incbin	para.dat
	
text:
 dc.b "                           "
 dc.b "                           "
 dc.b "                           "
 DC.B "HOLOCAUST DID IT ONCE AGAIN !!!          WOW!   HOW "
 DC.B "MARVELLOUS IT IS!    THIS SCREEN IS CALLED...   'INVERTED LANSCAPES'..."
 DC.B "   IT WAS CODED BY THE WORKING ONE...  ZAPPY!     USING ZERIOUL'S"
 DC.B " POWERFULL LINE ROUTY!                      "
 DC.B "THIS IS AGAIN A MASTERPIECE IN CHOICE OF GODS..."
 dc.b "   BUT I'M REALLY BORED...  I'M FED UP WITH 3D.  BLENK VECTORS, GLENZ, RUBBER, AAAARG!      I PREFER WRAP HERE.  "
 dc.b 255,255	 *2!

	even
font:
	dc.b %00000,%00000,%00000,%00000	;' '
	dc.b %00000,%11101,%11101,%00000	;!
	dc.b %01111,%10100,%10100,%01111	;a
	dc.b %01010,%10101,%10101,%11111	;b
	dc.b %10001,%10001,%10001,%11111	;c
	dc.b %01110,%10001,%10001,%11111	;d
	dc.b %10001,%10101,%10101,%11111	;e

	dc.b %10000,%10100,%10100,%11111	;f
	dc.b %10110,%10101,%10001,%01110	;g
	dc.b %11111,%00100,%00100,%11111	;h
	dc.b %00000,%10001,%11111,%10001	;i
	dc.b %00000,%10000,%11111,%10001	;j
	dc.b %11011,%00100,%00100,%11111	;k
	dc.b %00001,%00001,%00001,%11111	;l
	dc.b %11111,%01000,%01000,%11111	;m
	dc.b %01111,%10000,%10000,%11111	;n
	dc.b %11111,%10001,%10001,%11111	;o
	dc.b %01000,%10100,%10100,%11111	;p
	dc.b %11111,%10011,%10001,%11111	;q
	dc.b %11101,%10110,%10100,%11111	;r
	dc.b %10010,%10101,%10101,%01001	;s
	dc.b %00000,%10000,%11111,%10000	;t
	dc.b %11111,%00001,%00001,%11111	;u
	dc.b %11110,%00001,%00001,%11110	;v
	dc.b %11111,%00010,%00010,%11111	;w
	dc.b %11011,%00100,%00100,%11011	;x
	dc.b %00000,%11100,%00111,%11100	;y
	dc.b %10001,%11001,%10101,%10011	;z
	dc.b %01110,%10001,%10001,%01110	;0
	dc.b %00000,%00001,%11111,%01001	;1
	dc.b %01001,%10101,%10011,%00001	;2
	dc.b %01010,%10101,%10101,%10001	;3
	dc.b %00010,%11111,%01010,%00110	;4
	dc.b %10010,%10101,%10101,%11101	;5
	dc.b %00010,%10101,%10101,%01110	;6
	dc.b %11000,%10100,%10010,%10001	;7
	dc.b %01010,%10101,%10101,%01010	;8
	dc.b %01110,%10101,%10101,%01001	;9
	dc.b %00000,%00011,%00011,%00000	;.
	dc.b %00000,%01001,%00000,%00000	;:
	dc.b %00000,%00010,%00001,%00000	;,
	dc.b %00000,%00000,%11000,%00000	;'
	dc.b %00000,%10001,%01110,%00000	;(
	dc.b %00000,%01110,%10001,%00000	;)

*equivalence:
*	dc.b " !ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.:,'()"


FILL	
	DC.L	-1
	DC.L	-1
	DC.L	-1
	DC.L	-1
	
TAB	
	DC	50,70
	DC	12,175
	DC	120,190
	DC	410,150

	DC	50,70

cos_tab	incbin '\COSIN.DAT'	;tables sinus cosinus
sin_tab	equ cos_tab+720

points	

 DC 144+64*2,84+32*4
 DC 144+64*2,116+32*4
 DC 176+64*2,116+32*4
 DC 176+64*2,84+32*4

 DC 144+64,84+32*4
 DC 144+64,116+32*4
 DC 176+64,116+32*4
 DC 176+64,84+32*4

; DC 144-64-64,84+32*4
; DC 144-64-64,116+32*4
; DC 176-64-64,116+32*4
; DC 176-64-64,84+32*4

 DC 144-64,84+32*4
 DC 144-64,116+32*4
 DC 176-64,116+32*4
 DC 176-64,84+32*4

 DC 144,84+32*4
 DC 144,116+32*4
 DC 176,116+32*4
 DC 176,84+32*4


 DC 144+64+32,84+32*3
 DC 144+64+32,116+32*3
 DC 176+64+32,116+32*3
 DC 176+64+32,84+32*3

; DC 144+32-64-64,84+32*3
; DC 144+32-64-64,116+32*3
; DC 176+32-64-64,116+32*3
; DC 176+32-64-64,84+32*3

 DC 144+32-64,84+32*3
 DC 144+32-64,116+32*3
 DC 176+32-64,116+32*3
 DC 176+32-64,84+32*3

 DC 144+32,84+32*3
 DC 144+32,116+32*3
 DC 176+32,116+32*3
 DC 176+32,84+32*3



 DC 144+64*2,84-32*4
 DC 144+64*2,116-32*4
 DC 176+64*2,116-32*4
 DC 176+64*2,84-32*4

 DC 144+64,84-32*4
 DC 144+64,116-32*4
 DC 176+64,116-32*4
 DC 176+64,84-32*4

 DC 144-64-64,84-32*4
 DC 144-64-64,116-32*4
 DC 176-64-64,116-32*4
 DC 176-64-64,84-32*4

 DC 144-64,84-32*4
 DC 144-64,116-32*4
 DC 176-64,116-32*4
 DC 176-64,84-32*4

 DC 144,84-32*4
 DC 144,116-32*4
 DC 176,116-32*4
 DC 176,84-32*4


 DC 144+64+32,84-32*3
 DC 144+64+32,116-32*3
 DC 176+64+32,116-32*3
 DC 176+64+32,84-32*3

 DC 144+32-64-64,84-32*3
 DC 144+32-64-64,116-32*3
 DC 176+32-64-64,116-32*3
 DC 176+32-64-64,84-32*3

 DC 144+32-64,84-32*3
 DC 144+32-64,116-32*3
 DC 176+32-64,116-32*3
 DC 176+32-64,84-32*3

 DC 144+32,84-32*3
 DC 144+32,116-32*3
 DC 176+32,116-32*3
 DC 176+32,84-32*3

 DC 144,84
 DC 144,116
 DC 176,116
 DC 176,84
 
 DC 176,116
 DC 176,148
 DC 208,148
 DC 208,116

 DC 176,52
 DC 176,84
 DC 208,84
 DC 208,52

 DC 208,84
 DC 208,116
 DC 240,116
 DC 240,84

 DC 208,20
 DC 208,52
 DC 240,52
 DC 240,20

 DC 240,52
 DC 240,84
 DC 272,84
 DC 272,52

 DC 240,116
 DC 240,148
 DC 272,148
 DC 272,116

 DC 208,148
 DC 208,180
 DC 240,180
 DC 240,148

 DC 272,148
 DC 272,180
 DC 304,180
 DC 304,148

 DC 272,84
 DC 272,116
 DC 304,116
 DC 304,84

 DC 272,20
 DC 272,52
 DC 304,52
 DC 304,20

 DC 144,20
 DC 144,52
 DC 176,52
 DC 176,20

 DC 144,148
 DC 144,180
 DC 176,180
 DC 176,148

 DC 112,116
 DC 112,148
 DC 144,148
 DC 144,116

 DC 112,52
 DC 112,84
 DC 144,84
 DC 144,52

 DC 80,20
 DC 80,52
 DC 112,52
 DC 112,20

 DC 80,84
 DC 80,116
 DC 112,116
 DC 112,84

 DC 80,148
 DC 80,180
 DC 112,180
 DC 112,148

 DC 48,116
 DC 48,148
 DC 80,148
 DC 80,116

 DC 48,52
 DC 48,84
 DC 80,84
 DC 80,52

 DC 16,20
 DC 16,52
 DC 48,52
 DC 48,20

 DC 16,84
 DC 16,116
 DC 48,116
 DC 48,84

 DC 16,148
 DC 16,180
 DC 48,180
 DC 48,148

depla		
	dc	255
	
PART1	DC.W	%1111111111111111
	DC.W	%0111111111111111
	DC.W	%0011111111111111
	DC.W	%0001111111111111
	DC.W	%0000111111111111
	DC.W	%0000011111111111
	DC.W	%0000001111111111
	DC.W	%0000000111111111
	DC.W	%0000000011111111
	DC.W	%0000000001111111
	DC.W	%0000000000111111
	DC.W	%0000000000011111
	DC.W	%0000000000001111
	DC.W	%0000000000000111
	DC.W	%0000000000000011
	DC.W	%0000000000000001

PART2	DC.W	%1000000000000000
	DC.W	%1100000000000000
	DC.W	%1110000000000000
	DC.W	%1111000000000000
	DC.W	%1111100000000000
	DC.W	%1111110000000000
	DC.W	%1111111000000000
	DC.W	%1111111100000000
	DC.W	%1111111110000000
	DC.W	%1111111111000000
	DC.W	%1111111111100000
	DC.W	%1111111111110000
	DC.W	%1111111111111000
	DC.W	%1111111111111100
	DC.W	%1111111111111110
	DC.W	%1111111111111111

PNTS
N	SET	32768
	REPT	16
	DC.W	N
N	SET	N/2
	ENDR


ddpx	
n	set	0
	rept	20
	dc.l	trace11+n,trace11+n+8,trace11+n+16,trace11+n+24,trace11+n+32,trace11+n+40
	dc.l	trace11+n+48,trace11+n+56,trace11+n+68,trace11+n+76,trace11+n+84,trace11+n+92
	dc.l	trace11+n+100,trace11+n+108,trace11+n+116,trace11+n+124
n	set	n+136
	endr

fdpx
n	set	20*136
	rept	20
	dc.w 	n,ftrac2-saut-2,n,ftrac3-saut-2
	dc.w 	n,ftrac4-saut-2,n,ftrac5-saut-2
	dc.w 	n,ftrac6-saut-2,n,ftrac7-saut-2
	dc.w 	n,ftrac8-saut-2,n,ftrac9-saut-2
	dc.w 	n,ftrac10-saut-2,n,ftrac11-saut-2
	dc.w 	n,ftrac12-saut-2,n,ftrac13-saut-2
	dc.w 	n,ftrac14-saut-2,n,ftrac15-saut-2
	dc.w 	n,ftrac16-saut-2,n-136,ftrac1-saut-2
n	set	n-136
	endr

posx	
n	set	0
	rept	160/8
	dc.w	n,n,n,n
	dc.w	n,n,n,n
	dc.w	n+1,n+1,n+1,n+1
	dc.w	n+1,n+1,n+1,n+1
n	set	n+8
	endr  

posy:	
	
n	set 	-160*3
	rept	206	
	dc.w	n	
n	set n+160
	endr

ppxpet
	rept	(160/8)
	dc.w	7,7,0,6,0,5,0,4
	dc.w	0,3,0,2,0,1,0,0
	dc.w	1,7,0,6,0,5,0,4
	dc.w	0,3,0,2,0,1,0,0
	endr

pointsCUBE
	dc	40,40,40
	dc	40,-40,40
	dc	40,-40,40
	dc	-40,-40,40
	dc	-40,-40,40
	dc	-40,40,40
	dc	-40,40,40
	dc	40,40,40
	dc	40,40,-40
	dc	40,-40,-40
	dc	40,-40,-40
	dc	-40,-40,-40
	dc	-40,-40,-40
	dc	-40,40,-40
	dc	-40,40,-40
	dc	40,40,-40
	dc	40,40,40
	dc	40,40,-40
	dc	40,-40,40
	dc	40,-40,-40
	dc	-40,-40,40
	dc	-40,-40,-40
	dc	-40,40,40
	dc	-40,40,-40
	dc	40,40,40
	dc	-40,-40,-40
	dc	40,40,-40
	dc	-40,-40,40
	dc	40,-40,40
	dc	-40,40,-40
	dc	40,-40,-40
	dc	-40,40,40

;ZAP	INCBIN	MANGACOL.PI1
sound	incbin	land6.mus
	EVEN

	section bss
DEB_BSS
	DS.L 	128	
NEW_PILE	DS.L 	1	

xe	ds.w 1		;coordonnees spatiales
ye	ds.w 1
ze	ds.w 1

xdep	ds.w 1		;d‚placements
ydep	ds.w 1
zdep	ds.w 1

xp	ds.w 1		;coordonnees planes
yp	ds.w 1

new_xe	ds.w 1		;nouvelles coords 
new_ye	ds.w 1		;aprŠs rotation
new_ze	ds.w 1

x_angle	ds.w 1		;angles de rotation
y_angle	ds.w 1
z_angle	ds.w 1	
 
z_pt_fuite	ds.w 1		;coordonn‚es z du 
			;du point de fuite

var_3d	ds.w 9                  ;tableau pour calculs
POINTEUR	DS.L	1
POINTEUR2	DS.L	1
DATA_X
	DS	NB_POS*NB_PTS*2
BOURRE	DS	1
ANC_VBL	DS.L	1
ANC_TB	DS.L	1
MFP1	DS.B	1
MFP2	DS.B	1
MFP3	DS.B	1
MFP4	DS.B	1
MFP5	DS.B	1
MFP6	DS.B	1
MFP7	DS.B	1
MFP8	DS.B	1
MFP9	DS.B	1
MFP10	DS.B	1
	even
CNT	DS.L	1
CNT2	DS.L	1
ZA	DS	1	
PNT_X	DS.L	1
PNT_Y	DS.L	1
PNT	DS.L	1

*LINE_A_EMUL

PNT_261E	DS	1
EMUL_LINEA	DS.B	100
BUF16DA	DS.B	512
BUF299A	DS.B	512
	even
_PTSIN	DS.B	100
	even
	DS.B	256
BUFFERSCR	DS.B	64000
	even
TABLE	DS.L	360
SCREEN1	DS.L	1
SCREEN2	DS.L	1
BUF1	DS.B	8000
BUF2	DS.B	8000
FINAL	DS.L	16
DATAS	DS.B	8000
BUFCOD	DS.B	206000
***
routines
	ds.b 70000
**
lineA_tab:	ds.l 1
routs_pt:	ds.l 1
text_pt:	ds.l 1
text_buff_pt:	ds.l 1
compteurs:	ds.w 2
ad_routines:	ds.l 5
text_buffer:	ds.b 150
text_buffer_deb	equ text_buffer+20
text_buffer_end:ds.l 1
off_bolean:	ds.b 500
SAVE_ALL	DS.L	16
*****
COURB_EC	DS.L	1
TEXT_EC	DS.L	1
COLONNE	DS	1
END_COD


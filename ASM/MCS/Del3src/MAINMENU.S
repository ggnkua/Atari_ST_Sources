	opt d+
	OPT	O+
	;MOVE.L	#$B0000,-(A7)
	;MOVE.W #$20,-(A7)
	;TRAP #1
	;DC.W	$A00A

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.L	#0,$4D2
	MOVE.L	#0,$4D6
	move.w	#0,$FF8900
	MOVE.W	#$486,$FFFF8922
	bclr.b #0,$484
	CMP.W	#$520,$AA9A	
	BNE	DDD
	MOVE.L	#$78000,A0
	BRA	FFF
DDD	MOVE.L	#$F8000,A0
FFF	move.w #0,-(a7)
	move.l A0,-(a7)
	move.l A0,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7
prg	lea PAL,a0
	lea $ff8240,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	CMP.W	#1,$AAA0
	BEQ	ST8
	PEA	TXT
	MOVE.W	#9,-(A7)
	TRAP #1
	ADDQ.L	#6,A7
RT1	MOVE.B	$FFFC02,D1
	CMP.B	#$6d,D1
	BEQ	ST1
	CMP.B	#$6E,D1
	BNE	RT1
	MOVE.W	#1,$AA9C
	move.b #$8,$fffc02
	BRA	ST4
ST1	MOVE.W	#0,$AA9C
ST2    PEA	TXT2
	MOVE.W	#9,-(A7)
	TRAP #1
	ADDQ.L	#6,A7
RT5	CMP.B	$FFFC02,D1
	BEQ	RT5
	MOVE.B	#0,D1
RT2	MOVE.B	$FFFC02,D1
	CMP.B	#$6E,D1
	BEQ	ST3
	CMP.B	#$6D,D1
	BNE	RT2
	MOVE.W	#0,$AA9E
	BRA	ST4
ST3	MOVE.W	#1,$AA9E
ST4	PEA	TXT3
	MOVE.W	#9,-(A7)
	TRAP #1
	ADDQ.L	#6,A7
RT6	CMP.B	$FFFC02,D1
	BEQ	RT6
	MOVE.B	#0,D1
RT3	MOVE.B	$FFFC02,D1
	CMP.B	#$6E,D1
	BEQ	ST5
	CMP.B	#$6D,D1
	BNE	RT3
	MOVE.W	#0,$AAA0
	BRA	ST6
ST5	MOVE.W	#1,$AAA0
ST6	PEA	TXT4
	MOVE.W	#9,-(A7)
	TRAP #1
	ADDQ.L	#6,A7
ST7	CMP.B	#1,$FFFFC02
	BNE	ST7
ST8	PEA	TXT5
	MOVE.W  #9,-(A7)
	TRAP #1
	ADDQ.L	#6,A7
	CMP.W	#$1040,$AA9A
	BNE	NO1040
	CMP.W	#1,$92
	BEQ	ICI
	MOVE.W	#7,$AAA2
	MOVE.W	#1,$92
	BRA	CHARGE
NO1040
	MOVE.W	#6,$AAA2
CHARGE	LEA	$FF8240,A0
	REPT	8
	MOVE.L	#0,(A0)+
	ENDR
CHARGE1	
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D3
	LEA	MUZEXX,A0
	MOVE.W	$AAA2,D0
	MULU 	#6,D0
	LEA	$AAA4,A1
	ADD.L	D0,A1
	MOVE.W	(A1)+,D0
	MOVE.W	(A1)+,D1
	MOVE.W	(A1)+,D3
	JSR	LOAD
	TST.W	D4
	BNE	CHARGE1
	JSR	DECRUNCH
ICI	bsr inter
	jsr	MZIK
	CMP.W	#1,$AA9C
	BNE	SUITR
	MOVE.B	#8,$FFFC02
	BRA	SUITS
SUITR	MOVE.B #$12,$FFFC02
SUITS	MOVE.W	SPRX,XS
	MOVE.W	SPRY,YS
	MOVE.W #16,X
	MOVE.W #16,Y
	MOVE.W #160*3,LS
	MOVE.L	#IMAGES,SOURCE
	MOVE.L #FOND,DEST
	MOVE.W #8,LD
	MOVE.W #0,XD
	MOVE.W #0,YD
	MOVE.W #4,PLAN
	MOVE.W #3,FONC
	BSR	blit_it
	lea PAL,a0
	lea $ff8240,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	move.l	#VBL,$4D2
	MOVE.L	#MZIK+8,$4D6
	MOVE.W  #0,$AAA2

KEY	CMP.W  #0,$AAA2
	BNE 	FINMENU
	BRA	KEY
FINMENU
	move.l s120,$120
	move.b sa21,$fffa21
	move.b sa1b,$fffa1b
	move.b sa07,$fffa07
	move.b sa13,$fffa13
	move.b sa09,$fffa09
	move.w	#0,$FF8200
	move.b	#0,$FF820F
	move.b	#0,$FF8265
	move.w	#0,$FF8900
	move.l	#0,$4D2
	move.l	#0,$4D6
	move.b #$12,$fffc02
	BSR	EFFSPR
	JMP	$8C
	;DC.W	$A009
	;CLR.W -(A7)
	;TRAP #1

inter
	move.l $120,s120
	move.b $fffa21,sa21
	move.b $fffa1b,sa1b
	move.b $fffa07,sa07 
 	move.b $fffa13,sa13
	move.b $fffa09,sa09
	CMP.W	#1,$AA9C
	BEQ	RETURN
 	and.b #$ef,$fffa13
 	and.b #$ef,$fffa0f
 	and.b #$ef,$fffa0b
 	clr.b $fffa07
	clr.b $fffa09
 	clr.b $fffa1b
 	or.b #1,$fffa07
 	or.b #1,$fffa13
RETURN	rts
s120	dc.l 0
s70	dc.l 0
sa21	dc.l 0
sa1b	dc.l 0
sa07	dc.l 0
sa13	dc.l 0
sa09	dc.l 0

VBL
	MOVE.L	#I,$120
	MOVE.B #2,$FFFA21
	MOVE.B #8,$FFFA1B
	MOVEM.L D0-D7/A0-A6,-(A7)
	BSR	EFFSPR
	BSR	KB
	BSR	GMOUSE
	BSR	JOYSTICK
	BSR	TSTBORD
	BSR	CALC
	BSR	RASTER
	BSR	BOING
	BSR	AFFSPR
	BSR	TEST
	MOVEM.L (A7)+,D0-D7/A0-A6
	RTS

TEST	;CMP.W  #1,$AA9C
	;BNE	NOMOUSE
	;TST.W	KM
	;CMP.B	#$F8,$EA0
	;BEQ	THATSOK
	;BNE	THATSOK
	;BRA	Q5
NOMOUSE
	MOVE.B $fffc02,d1
	cmp.b #$39,d1
	BEQ 	THATSOK
	RTS
THATSOK
	MOVE.W	SPRX,D0
	MOVE.W	SPRY,D1
	CMP.W	#233*3,D0
	BLT	Q1
	CMP.W	#50*3,D1
	BGT	Q1
	MOVE.W	#2,$AAA2
	BRA	Q5
Q1	CMP.W	#286*3,D0
	BLT	Q2
	CMP.W	#132*3,D1
	BLT	Q2
	CMP.W	#182*3,D1
	BGT	Q2
	MOVE.W	#3,$AAA2
	BRA	Q5
Q2	CMP.W	#113*3,D0
	BLT	Q3
	CMP.W	#143*3,D0
	BGT	Q3
	CMP.W	#151*3,D1
	BLT	Q3
	CMP.W	#184*3,D1
	BGT	Q3
	MOVE.W	#4,$AAA2
	BRA	Q5
Q3	CMP.W	#102*3,D0
	BGT	Q5
	CMP.W	#140*3,D1
	BLT	Q5
	CMP.W	#182*3,D1
	BGT	Q5
	MOVE.W	#5,$AAA2
Q5	RTS
RASTER
	CMP.W	#1,$AA9C
	BEQ	RAST2
	CMP.W	#1,$AA9E
	BNE	SRAST
	ADD.L	#2,CLIGN
	CMP.L	#4,CLIGN
	BNE	SRAST
	MOVE.L	#0,CLIGN
SRAST	MOVEQ	#0,D0
	LEA	HBL,A0
	MOVE.W	SCRY,D0
	LSR.L	#1,D0
	ADD.L	D0,A0
	ADD.L	CLIGN,A0
	LEA	I+2,A1
	MOVE.W (A0)+,$FF825E
M SET 0
	REPT	99
	MOVE.W	(A0)+,M(A1)
M SET M+26
	ENDR
	RTS
RAST2	MOVEQ	#0,D0
	MOVE.W	SCRY,D0
	DIVU	#6,D0
	SWAP	D0
	MOVE.W	#0,D0
	SWAP	D0
	BCLR	#0,D0
	LEA	HBL,A0
	ADD.L	D0,A0
	ADD.L	#12,A0
	MOVE.W (A0),$FF825E
	RTS

BOING	CMP.W #0,BONG
	BEQ	FINBONG
	ADD.W	#1,TEMPO
	CMP.W	#2,TEMPO
	BNE	SUIT2
	MOVE.W	#0,TEMPO
	LEA	STRY,A0
	ADD.L	STORY,A0
	CMP.L	#-1,(A0)
	BNE	SUITSTORY
	MOVE.L	#0,STORY
	LEA	STRY,A0
SUITSTORY
	MOVE.L (A0),A0
	ADD.L	POINT,A0
	CMP.L	#-1,(A0)
	BNE	SUIT1
	MOVE.W	#0,BONG
	MOVE.W #1,TEMPO
	MOVE.L #0,POINT
	MOVE.L	#CURS1,CURSOR
	RTS
SUIT1	MOVE.L (A0),CURSOR
	ADD.L #4,POINT
SUIT2	CMP.W	#1,BONG
	BEQ	OUPF1
	CMP.W	#2,BONG
	BEQ	OUPF2
	CMP.W	#3,BONG
	BEQ	OUPF3
	SUB.W	#4,SPRY
	CMP.W	#492,SPRY
	BGT	EE1
	SUB.W	#4,SCRY
EE1	RTS
OUPF3	ADD.W	#4,SPRY
	CMP.W	#92,SPRY
	BLT	EE2
	ADD.W  #4,SCRY
EE2	RTS
OUPF2	SUB.W  #4,SPRX
	CMP.W	#640+152,SPRX
	BGT	EE3
	SUB.W	#4,SCRX
EE3	RTS
OUPF1	ADD.W  #4,SPRX
	CMP.W	#152,SPRX
	BLT	FINBONG
	ADD.W  #4,SCRX
FINBONG
	RTS
CALC
	LEA IMAGES,A0
	MOVE.W	SCRX,D0
	MOVE.W	D0,D1
	DIVU	#16,D1
	SWAP	D1
	TST.W	D1
	BEQ	CC1
	MOVE.B	#(80*2)-4,$FF820F
	BRA	CC2
CC1	MOVE.B	#80*2,$FF820F
CC2	MOVE.B	D1,$FF8265
	MOVE.W	#0,D1
	SWAP	D1
CC3	MULU	#8,D1
	MOVE.W	SCRY,D0
	MULU	#160,D0
	MOVE.L	D0,D4
	ADD.L	D4,D0
	ADD.L	D4,D0
	ADD.L	D0,D1
	ADD.L	D1,A0
	MOVE.L A0,D0
	MOVE.B D0,$FF8209
	LSR.W #8,D0
	MOVE.B D0,$FF8207
	SWAP D0
	MOVE.B D0,$FF8205
	RTS
AFFSPR	MOVE.W	SPRX,XS
	MOVE.W	SPRY,YS
	LEA	CURSOR,A1
	MOVE.L	(A1),A1
	MOVE.W #16,X
	MOVE.W #16,Y
	MOVE.W #160*3,LS
	MOVE.L	#IMAGES,SOURCE
	MOVE.L #FOND,DEST
	MOVE.W 12(A1),LD
	MOVE.W #0,XD
	MOVE.W #0,YD
	MOVE.W #4,PLAN
	MOVE.W #3,FONC
	BSR	blit_it

	MOVE.W	SPRX,XD
	MOVE.W	SPRY,YD
	MOVE.L	#IMAGES,DEST
	MOVE.L	18(A1),SOURCE
	MOVE.W 4(A1),XS	
	MOVE.W 6(A1),YS
	MOVE.W 8(A1),X
	MOVE.W 10(A1),Y
	MOVE.W	#2,LS
	MOVE.W #160*3,LD
	MOVE.W 14(A1),PLAN
	MOVE.W #4,FONC
	MOVE.W	#1,MASK
	BSR	blit_it
	MOVE.L (A1),SOURCE
	MOVE.W 12(A1),LS
	MOVE.W #6,FONC
	MOVE.W	#0,MASK
	BSR	blit_it
	RTS

EFFSPR 
	MOVEQ #0,D0
	MOVEQ #0,D1
	MOVE.W	SPRX,XD
	MOVE.W	SPRY,YD
	MOVE.W	#160*3,LD
	LEA	CURSOR,A1
	MOVE.L	(A1),A1
	MOVE.L	#IMAGES,DEST
	MOVE.L	#FOND,SOURCE
	MOVE.W #0,XS
	MOVE.W #0,YS
	MOVE.W #16,X
	MOVE.W #16,Y
	MOVE.W 12(A1),LS
	MOVE.W #4,PLAN
	MOVE.W #3,FONC
	BSR	blit_it
	RTS

GMOUSE	CMP.W	#0,BONG
	BNE	ZE
	CMP.W	#1,$AA9C
	BEQ	YESM
	RTS
YESM	LEA	$EA0,A0	
	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	MOVE.B	(A0),D0
	MOVE.B	1(A0),D1
	MOVE.B	2(A0),D2	
	CLR.B	1(A0)
	CLR.B	2(A0)
	SUB.W	#$F8,D0
	EXT	D1
	EXT	D2
	MOVE.W	D0,KM
	LSL	#1,D1
	LSL	#1,D2
	CMP.W	#640+152,SPRX
	BGT	ZA
	CMP.W	#152,SPRX
	BLT	ZA
	ADD.W	D1,SCRX
	MOVE.W	SCRX,SPRX
	ADD.W	#152,SPRX
	BRA	ZB
ZA	ADD.W	D1,SPRX
ZB	CMP.W	#482,SPRY
	BGT	ZF
	CMP.W	#82,SPRY
	BLT	ZF	
	ADD.W	D2,SCRY
	MOVE.W	SCRY,SPRY
	ADD.W	#82,SPRY
	BRA	ZE
ZF	ADD.W	D2,SPRY
ZE	RTS
JOYSTICK
	CMP.W	#1,$AA9C
	BEQ	YESJ
	RTS
YESJ	CMP.W	#0,BONG
	BNE	FINJ
	LEA	$EAB,A0		;lecture port 1
	CLR.W	D0
	CLR.W	D1
	CLR.W	D2
	MOVE.B	(A0),D0
	CMP.W	#0,D0		;joy relach‚
	BNE	N0
	MOVE.W	#0,D5
	MOVE.W	#1,JOYINTER
	BRA	FIJ
N0	
	MOVE.W	#10,D5
CALCJOY	MOVE.W	D5,D6
	LSR	#2,D6
	MOVE.W	JOYINTER,D3
	ADD.W	D6,D3
	MOVE.W	D3,D4
	NEG	D4
	CMP.W	#1,D0		;haut
	BNE	N1
	MOVE.W	D4,D2
	BRA	JOYSUITE
N1	CMP.W	#9,D0		;haut droite
	BNE	N9
	MOVE.W	D3,D1
	MOVE.W	D4,D2
	BRA	JOYSUITE
N9	CMP.W	#8,D0		;droite
	BNE	N8
	MOVE.W	D3,D1
	BRA	JOYSUITE
N8	CMP.W	#$A,D0		;bas droite
	BNE	N10
	MOVE.W	D3,D1
	MOVE.W	D3,D2
	BRA	JOYSUITE
N10	CMP.W	#2,D0		;bas
	BNE	N2
	MOVE.W	D3,D2
	BRA	JOYSUITE
N2	CMP.W	#6,D0		;bas gauche
	BNE	N6
	MOVE.W	D4,D1
	MOVE.W	D3,D2
	BRA	JOYSUITE
N6	CMP.W	#4,D0		;gauche
	BNE	N4
	MOVE.W	D4,D1
	BRA	JOYSUITE
N4	CMP.W	#5,D0		;haut gauche
	BNE	JOYSUITE
	MOVE.W	D4,D1
	MOVE.W	D4,D2		
JOYSUITE	
	CMP.W	#640+152,SPRX
	BGT	WA
	CMP.W	#152,SPRX
	BLT	WA
	ADD.W	D1,SCRX
	MOVE.W	SCRX,SPRX
	ADD.W	#152,SPRX
	BRA	WB
WA	ADD.W	D1,SPRX
WB	CMP.W	#482,SPRY
	BGT	WF
	CMP.W	#82,SPRY
	BLT	WF	
	ADD.W	D2,SCRY
	MOVE.W	SCRY,SPRY
	ADD.W	#82,SPRY
	BRA	FIJ
WF	ADD.W	D2,SPRY
FIJ	MOVE.W	D5,JOYCOMPTEUR
FINJ	RTS

KB	CMP.W	#0,BONG
	BNE 	R4
	MOVE.B $FFFC02,D5
	CMP.B	#$48,D5
	BNE	R1
	SUB.W	#4,SPRY
	CMP.W	#482,SPRY
	BGT	E1
	SUB.W	#4,SCRY
E1	RTS
R1	CMP.B	#$50,D5
	BNE	R2
	ADD.W  #4,SPRY
	CMP.W	#82,SPRY
	BLT	E2
	ADD.W  #4,SCRY
E2	RTS
R2	CMP.B	#$4B,D5
	BNE	R3
	SUB.W	#4,SPRX
	CMP.W	#640+152,SPRX
	BGT	E3
	SUB.W	#4,SCRX
E3	RTS
R3	CMP.B	#$4D,D5
	BNE	R4
	ADD.W  #4,SPRX
	CMP.W	#152,SPRX
	BLT	R4
	ADD.W  #4,SCRX
R4	RTS
TSTBORD	
	CMP.W	#0,BONG
	BNE	FINKB
	MOVE.W	SCRX,D0
	CMP.W	#0,D0
	BGT	HORI
	CLR.W	D0
	BRA	SCRIN
HORI	CMP.W	#641,D0
	BLT	SCRIN
	MOVE.W	#640,D0
SCRIN	MOVE.W	D0,SCRX
	MOVE.W	SCRY,D0
	CMP.W	#0,D0
	BGT	VERTIC
	CLR.W	D0
	BRA	SCRIN2
VERTIC	CMP.W	#401,D0
	BLT	SCRIN2
	MOVE.W	#400,D0
SCRIN2	MOVE.W	D0,SCRY
	MOVE.W	SPRX,D0
	CMP.W	#0,D0
	BGT	HOI
	CLR.W	D0
	MOVE.W #1,BONG
	ADD.L	#4,STORY
	BRA	SCIN
HOI	CMP.W	#641+320-16,D0
	BLT	SCIN
	MOVE.W #2,BONG
	ADD.L	#4,STORY
	MOVE.W	#640+320-16,D0
SCIN	MOVE.W	D0,SPRX
	MOVE.W	SPRY,D0
	CMP.W	#0,D0
	BGT	VERIC
	MOVE.W #3,BONG
	ADD.L	#4,STORY
	CLR.W	D0
	BRA	SCIN2
VERIC	CMP.W	#600-16,D0
	BLT	SCIN2
	MOVE.W	#600-16,D0
	MOVE.W #4,BONG
	ADD.L	#4,STORY
SCIN2	MOVE.W	D0,SPRY
FINKB	RTS
	
KM	DC.W 	0
SCRX	DC.W   0
SCRY	DC.W   0
SPRX	DC.W   152
SPRY	DC.W   92
BONG	DC.W   0
TEMPO	DC.W   1
STORY	DC.L   0
JOYCOMPTEUR	DC.W	0
JOYINTER	DC.W	1
CLIGN	DC.L	0


I	move.w #$f,$FF825E
	move.l #I1,$120.w
	bclr #0,$fffa0f
	rte
I1	move.w #$7,$FF825E
	move.l #I2,$120.w
	bclr #0,$fffa0f
	rte
I2	move.w #$e,$FF825E
	move.l #I3,$120.w
	bclr #0,$fffa0f
	rte
I3	move.w #$6,$FF825E
	move.l #I4,$120.w
	bclr #0,$fffa0f
	rte
I4	move.w #$d,$ff825E
	move.l #I5,$120.w
	bclr #0,$fffa0f
	rte
I5	move.w #$5,$FF825E
	move.l #I6,$120.w
	bclr #0,$fffa0f
	rte
I6	move.w #$c,$FF825E
	move.l #I7,$120.w
	bclr #0,$fffa0f
	rte
I7	move.w #$4,$ff825E
	move.l #I8,$120.w
	bclr #0,$fffa0f
	rte
I8	move.w #$b,$FF825E
	move.l #I9,$120.w
	bclr #0,$fffa0f
	rte
I9	move.w #$3,$FF825E
	move.l #I10,$120.w
	bclr #0,$fffa0f
	rte
I10	move.w #$a,$FF825E
	move.l #I11,$120.w
	bclr #0,$fffa0f
	rte
I11	move.w #$2,$FF825E
	move.l #I12,$120.w
	bclr #0,$fffa0f
	rte
I12	move.w #$9,$FF825E
	move.l #I13,$120.w
	bclr #0,$fffa0f
	rte
I13	move.w #$1,$FF825E
	move.l #I14,$120.w
	bclr #0,$fffa0f
	rte
I14	move.w #$a,$FF825E
	move.l #I15,$120.w
	bclr #0,$fffa0f
	rte
I15	move.w #$2,$FF825E
	move.l #I16,$120.w
	bclr #0,$fffa0f
	rte
I16	move.w #$a,$FF825E
	move.l #I17,$120.w
	bclr #0,$fffa0f
	rte
I17	move.w #$2,$FF825E
	move.l #I18,$120.w
	bclr #0,$fffa0f
	rte
I18	move.w #$a,$FF825E
	move.l #I19,$120.w
	bclr #0,$fffa0f
	rte
I19	move.w #$2,$FF825E
	move.l #I20,$120.w
	bclr #0,$fffa0f
	rte
I20	move.w #$a,$FF825E
	move.l #I21,$120.w
	bclr #0,$fffa0f
	rte
I21	move.w #$2,$FF825E
	move.l #I22,$120.w
	bclr #0,$fffa0f
	rte
I22	move.w #$a,$FF825E
	move.l #I23,$120.w
	bclr #0,$fffa0f
	rte
I23	move.w #$2,$FF825E
	move.l #I24,$120.w
	bclr #0,$fffa0f
	rte
I24	move.w #$2,$FF825E
	move.l #I25,$120.w
	bclr #0,$fffa0f
	rte
I25	move.w #$a,$FF825E
	move.l #I26,$120.w
	bclr #0,$fffa0f
	rte
I26	move.w #$2,$FF825E
	move.l #I27,$120.w
	bclr #0,$fffa0f
	rte
I27	move.w #$a,$FF825E
	move.l #I28,$120.w
	bclr #0,$fffa0f
	rte
I28	move.w #$2,$FF825E
	move.l #I29,$120.w
	bclr #0,$fffa0f
	rte
I29	move.w #$a,$FF825E
	move.l #I30,$120.w
	bclr #0,$fffa0f
	rte
I30	move.w #$2,$FF825E
	move.l #I31,$120.w
	bclr #0,$fffa0f
	rte
I31	move.w #$a,$FF825E
	move.l #I32,$120.w
	bclr #0,$fffa0f
	rte
I32	move.w #$2,$FF825E
	move.l #I33,$120.w
	bclr #0,$fffa0f
	rte
I33	move.w #$a,$FF825E
	move.l #I34,$120.w
	bclr #0,$fffa0f
	rte
I34	move.w #$2,$FF825E
	move.l #I35,$120.w
	bclr #0,$fffa0f
	rte
I35	move.w #$a,$FF825E
	move.l #I36,$120.w
	bclr #0,$fffa0f
	rte
I36	move.w #$2,$FF825E
	move.l #I37,$120.w
	bclr #0,$fffa0f
	rte
I37	move.w #$a,$FF825E
	move.l #I38,$120.w
	bclr #0,$fffa0f
	rte
I38	move.w #$2,$FF825E
	move.l #I39,$120.w
	bclr #0,$fffa0f
	rte
I39	move.w #$a,$FF825E
	move.l #I40,$120.w
	bclr #0,$fffa0f
	rte
I40	move.w #$2,$FF825E
	move.l #I41,$120.w
	bclr #0,$fffa0f
	rte
I41	move.w #$a,$FF825E
	move.l #I42,$120.w
	bclr #0,$fffa0f
	rte
I42	move.w #$2,$FF825E
	move.l #I43,$120.w
	bclr #0,$fffa0f
	rte
I43	move.w #$a,$FF825E
	move.l #I44,$120.w
	bclr #0,$fffa0f
	rte
I44	move.w #$2,$FF825E
	move.l #I45,$120.w
	bclr #0,$fffa0f
	rte
I45	move.w #$a,$FF825E
	move.l #I46,$120.w
	bclr #0,$fffa0f
	rte
I46	move.w #$2,$FF825E
	move.l #I47,$120.w
	bclr #0,$fffa0f
	rte
I47	move.w #$2,$FF825E
	move.l #I48,$120.w
	bclr #0,$fffa0f
	rte
I48	move.w #$a,$FF825E
	move.l #I49,$120.w
	bclr #0,$fffa0f
	rte
I49	move.w #$2,$FF825E
	move.l #I50,$120.w
	bclr #0,$fffa0f
	rte
I50	move.w #$f,$FF825E
	move.l #I51,$120.w
	bclr #0,$fffa0f
	rte
I51	move.w #$7,$FF825E
	move.l #I52,$120.w
	bclr #0,$fffa0f
	rte
I52	move.w #$e,$FF825E
	move.l #I53,$120.w
	bclr #0,$fffa0f
	rte
I53	move.w #$6,$FF825E
	move.l #I54,$120.w
	bclr #0,$fffa0f
	rte
I54	move.w #$d,$ff825E
	move.l #I55,$120.w
	bclr #0,$fffa0f
	rte
I55	move.w #$5,$FF825E
	move.l #I56,$120.w
	bclr #0,$fffa0f
	rte
I56	move.w #$c,$FF825E
	move.l #I57,$120.w
	bclr #0,$fffa0f
	rte
I57	move.w #$4,$ff825E
	move.l #I58,$120.w
	bclr #0,$fffa0f
	rte
I58	move.w #$b,$FF825E
	move.l #I59,$120.w
	bclr #0,$fffa0f
	rte
I59	move.w #$3,$FF825E
	move.l #I60,$120.w
	bclr #0,$fffa0f
	rte
I60	move.w #$a,$FF825E
	move.l #I61,$120.w
	bclr #0,$fffa0f
	rte
I61	move.w #$2,$FF825E
	move.l #I62,$120.w
	bclr #0,$fffa0f
	rte
I62	move.w #$9,$FF825E
	move.l #I63,$120.w
	bclr #0,$fffa0f
	rte
I63	move.w #$1,$FF825E
	move.l #I64,$120.w
	bclr #0,$fffa0f
	rte
I64	move.w #$a,$FF825E
	move.l #I65,$120.w
	bclr #0,$fffa0f
	rte
I65	move.w #$2,$FF825E
	move.l #I66,$120.w
	bclr #0,$fffa0f
	rte
I66	move.w #$a,$FF825E
	move.l #I67,$120.w
	bclr #0,$fffa0f
	rte
I67	move.w #$2,$FF825E
	move.l #I68,$120.w
	bclr #0,$fffa0f
	rte
I68	move.w #$a,$FF825E
	move.l #I69,$120.w
	bclr #0,$fffa0f
	rte
I69	move.w #$2,$FF825E
	move.l #I70,$120.w
	bclr #0,$fffa0f
	rte
I70	move.w #$a,$FF825E
	move.l #I71,$120.w
	bclr #0,$fffa0f
	rte
I71	move.w #$2,$FF825E
	move.l #I72,$120.w
	bclr #0,$fffa0f
	rte
I72	move.w #$a,$FF825E
	move.l #I73,$120.w
	bclr #0,$fffa0f
	rte
I73	move.w #$2,$FF825E
	move.l #I74,$120.w
	bclr #0,$fffa0f
	rte
I74	move.w #$2,$FF825E
	move.l #I75,$120.w
	bclr #0,$fffa0f
	rte
I75	move.w #$a,$FF825E
	move.l #I76,$120.w
	bclr #0,$fffa0f
	rte
I76	move.w #$2,$FF825E
	move.l #I77,$120.w
	bclr #0,$fffa0f
	rte
I77	move.w #$a,$FF825E
	move.l #I78,$120.w
	bclr #0,$fffa0f
	rte
I78	move.w #$2,$FF825E
	move.l #I79,$120.w
	bclr #0,$fffa0f
	rte
I79	move.w #$a,$FF825E
	move.l #I80,$120.w
	bclr #0,$fffa0f
	rte
I80	move.w #$2,$FF825E
	move.l #I81,$120.w
	bclr #0,$fffa0f
	rte
I81	move.w #$a,$FF825E
	move.l #I82,$120.w
	bclr #0,$fffa0f
	rte
I82	move.w #$2,$FF825E
	move.l #I83,$120.w
	bclr #0,$fffa0f
	rte
I83	move.w #$a,$FF825E
	move.l #I84,$120.w
	bclr #0,$fffa0f
	rte
I84	move.w #$2,$FF825E
	move.l #I85,$120.w
	bclr #0,$fffa0f
	rte
I85	move.w #$a,$FF825E
	move.l #I86,$120.w
	bclr #0,$fffa0f
	rte
I86	move.w #$2,$FF825E
	move.l #I87,$120.w
	bclr #0,$fffa0f
	rte
I87	move.w #$a,$FF825E
	move.l #I88,$120.w
	bclr #0,$fffa0f
	rte
I88	move.w #$2,$FF825E
	move.l #I89,$120.w
	bclr #0,$fffa0f
	rte
I89	move.w #$a,$FF825E
	move.l #I90,$120.w
	bclr #0,$fffa0f
	rte
I90	move.w #$2,$FF825E
	move.l #I91,$120.w
	bclr #0,$fffa0f
	rte
I91	move.w #$a,$FF825E
	move.l #I92,$120.w
	bclr #0,$fffa0f
	rte
I92	move.w #$2,$FF825E
	move.l #I93,$120.w
	bclr #0,$fffa0f
	rte
I93	move.w #$a,$FF825E
	move.l #I94,$120.w
	bclr #0,$fffa0f
	rte
I94	move.w #$2,$FF825E
	move.l #I95,$120.w
	bclr #0,$fffa0f
	rte
I95	move.w #$a,$FF825E
	move.l #I96,$120.w
	bclr #0,$fffa0f
	rte
I96	move.w #$2,$FF825E
	move.l #I97,$120.w
	bclr #0,$fffa0f
	rte
I97	move.w #$2,$FF825E
	move.l #I98,$120.w
	bclr #0,$fffa0f
	rte
I98	move.w #$a,$FF825E
	move.l #I99,$120.w
	bclr #0,$fffa0f
	rte
I99	move.w #$2,$FF825E
	CLR.B	$FFFA21
	CLR.B	$FFFA1B
	bclr #0,$fffa0f
	rte
     	


BLITTER        equ       $FF8A00
demiteinte     equ       0         
Src_Xinc       equ       32        
Src_Yinc       equ       34        
Src_Addr       equ       36        
Endmask1       equ       40        
Endmask2       equ       42        
Endmask3       equ       44        
Dst_Xinc       equ       46        
Dst_Yinc       equ       48        
Dst_Addr       equ       50        
largeur        equ       54        
hauteur        equ       56        
HOP            equ       58        
OP             equ       59        
Line_Num       equ       60        
Oblique        equ       61        
fHOP_Source   	equ       1
fHOP_demiteinte  	equ       0
fObliqueFXSR      	equ       7
fObliqueNFSR      	equ       6
fLineBusy      	equ       7
fLineHog       	equ       6
fLineSmudge    	equ       5
mHOP_Source    	equ       $02
mHOP_demiteinte  	equ       $01
mObliqueFXSR      	equ       $80
mObliqueNFSR      	equ       $40
mLineBusy      	equ       $80
mLineHog       	equ       $40
mLineSmudge    	equ       $20
lf_endmask
     dc.w      $FFFF
rt_endmask
     dc.w      $7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF			
     dc.w      $00FF,$007F,$003F,$001F,$000F,$0007,$0003,$0001,0			
blit_it:
	movem.l a0-a6/d0-d7,-(a7)
     lea       BLITTER,a5       
     lea	 PARA,a4
     move.w    WIDTH(a4),d6
     subq.w    #1,d6            
     move.w    SRC_XMIN(a4),d0  
     move.w    d0,d1            
     add.w     d6,d1            
     move.w    DST_XMIN(a4),d2  
     move.w    d2,d3            
     add.w     d6,d3            
     moveq     #$0F,d6          
     move.w    d2,d4            
     and.w     d6,d4            
     add.w     d4,d4            
     move.w    lf_endmask(pc,d4.w),d4
     move.w    d3,d5            
     and.w     d6,d5            
     add.w     d5,d5            
     move.w    rt_endmask(pc,d5.w),d5
     not.w     d5               
     move.w    d2,d7            
     and.w     d6,d7            
     and.w     d0,d6            
     sub.w     d6,d7            
     clr.w     d6               
     addx.w    d6,d6            
     lsr.w     #4,d0            
     lsr.w     #4,d1            
     sub.w     d0,d1            
     lsr.w     #4,d2            
     lsr.w     #4,d3            
     sub.w     d2,d3            
     bne       set_endmasks     
     and.w     d5,d4            
     addq.w    #4,d6            
set_endmasks:
     move.w    d4,Endmask1(a5)  
     move.w    #$FFFF,Endmask2(a5)
     move.w    d5,Endmask3(a5)  
     cmp.w     d1,d3            
     bne       set_count        
     addq.w    #2,d6            
set_count:
     move.w    d3,d4
     addq.w    #1,d4            
     move.w    d4,largeur(a5)   
     move.l    SRC_BASE(a4),a0  
     move.w    SRC_YMIN(a4),d4  
     move.w    SRC_NXLN(a4),d5  
     mulu      d5,d4            
     add.l     d4,a0            
     move.w    SRC_NXWD(a4),d4  
     move.w    d4,Src_Xinc(a5)  
     mulu      d4,d0            
     add.l     d0,a0            
     mulu      d4,d1            
     sub.w     d1,d5            
     move.w    d5,Src_Yinc(a5)  
     move.l    DST_BASE(a4),a1  
     move.w    DST_YMIN(a4),d4  
     move.w    DST_NXLN(a4),d5  
     mulu      d5,d4            
     add.l     d4,a1            
     move.w    DST_NXWD(a4),d4  
     move.w    d4,Dst_Xinc(a5)  
     mulu      d4,d2            
     add.l     d2,a1            
     mulu      d4,d3            
     sub.w     d3,d5            
     move.w    d5,Dst_Yinc(a5)  
     and.b     #$0F,d7          	       
     or.b      Oblique_flags(pc,d6.w),d7  
     move.b    d7,Oblique(a5)      	
     move.b    #mHOP_Source,HOP(a5)	
     move.W	 FONC,d6
     move.b    d6,OP(a5)        		
     lea       Line_Num(a5),a2  		
     move.b    #6,d2    		;partage ou occupation du bus
     move.w    PLANES(a4),d7    		
     bra       begin
Oblique_flags:
     dc.b      mObliqueNFSR        
     dc.b      mObliqueFXSR        
     dc.b      0                   
     dc.b      mObliqueNFSR+mObliqueFXSR 
     dc.b      0                
     dc.b      mObliqueFXSR     
     dc.b      0                
     dc.b      0                
next_plane:
     move.l    a0,Src_Addr(a5)  		
     move.l    a1,Dst_Addr(a5)  		
     move.w    HEIGHT(a4),hauteur(a5)	
     move.b    #mLineBusy,(a2)  		
     CMP.W #1,MASK
     BEQ	SSD
     add.w     SRC_NXPL(a4),a0  		
SSD  add.w     DST_NXPL(a4),a1  		
restart:
     bset.b    d2,(a2)          
     nop                        
     bne       restart          
begin:
     dbra      d7,next_plane    
	movem.l (a7)+,a0-a6/d0-d7
     rts
MASK		 DC.W 	    0
SRC_BASE       equ       0
SRC_NXWD       equ       4
SRC_NXLN       equ       6
SRC_NXPL       equ       8
SRC_XMIN       equ      10
SRC_YMIN       equ      12
DST_BASE       equ      14
DST_NXWD       equ      18
DST_NXLN       equ      20
DST_NXPL       equ      22
DST_XMIN       equ      24
DST_YMIN       equ      26
WIDTH          equ      28
HEIGHT         equ      30
PLANES         equ      32
PARA	
SOURCE	dc.l	FOND
	dc.w	8
LS	dc.w   16
	dc.w   2
XS	dc.w  	0
YS	dc.w	100

DEST	dc.l	$F8000
	dc.w	8
LD	dc.w	160*3
	dc.w	2
XD	dc.w	0
YD	dc.w	0

X	dc.w	32
Y	dc.w	29
PLAN	dc.w	3
FONC	dc.W	3
	even

	
	*	NOM DU DESSIN SOURCE
       *	NOM DU MASK
	*	XS , YS = POSITION DANS DESSIN SOURCE
	*	X  , Y  = TAILLE DU BOB
	*	LS      = (LARGEUR DU DESSIN SOURCE)/2
	*	PLAN	 = NBR DE PLANS A TRANSFERER
	*	FONC	 : 3=REPLACE , 6=OR , 7=EOR
	*	XS,YS,X,Y,LS,PLAN,FONC
STRY	DC.L	S1,S1,S2,S3,S4,S5,S6,-1,-1
S1	DC.L	CURS1,CURS2,CURS3,CURS4,CURS5,CURS6
	DC.L	BUL2,BUL2,BUL2,BUL2,BUL2,BUL2,BUL2
	DC.L	BUL2,BUL2,BUL2,BUL2,BUL2,BUL2,BUL2
	DC.L	BUL2,BUL2,BUL2,BUL2,BUL2,BUL2,BUL2
	DC.L	-1
S2	DC.L	CURS1,CURS2,CURS3,CURS4,CURS5,CURS6
	DC.L	BUL1,BUL1,BUL1,BUL1,BUL1,BUL1,BUL1
	DC.L	BUL1,BUL1,BUL1,BUL1,BUL1,BUL1,BUL1
	DC.L	BUL1,BUL1,BUL1,BUL1,BUL1,BUL1,BUL1
	DC.L	-1
S3	DC.L	CURS1,CURS2,CURS3,CURS4,CURS5,CURS6
	DC.L	BUL3,BUL3,BUL3,BUL3,BUL3,BUL3,BUL3
	DC.L	BUL3,BUL3,BUL3,BUL3,BUL3,BUL3,BUL3
	DC.L	BUL3,BUL3,BUL3,BUL3,BUL3,BUL3,BUL3
	DC.L	-1
S4	DC.L	CURS1,CURS2,CURS3,CURS4,CURS5,CURS6
	DC.L	BUL4,BUL4,BUL4,BUL4,BUL4,BUL4,BUL4
	DC.L	BUL4,BUL4,BUL4
	DC.L	BUL5,BUL5,BUL5,BUL5,BUL5,BUL5,BUL5
	DC.L	BUL5,BUL5,BUL5,BUL5,BUL5
	DC.L	BUL7,BUL7,BUL7,BUL7,BUL7,BUL7,BUL7
	DC.L	BUL7,BUL7,BUL7,BUL7,BUL7
	DC.L	BUL9,BUL9,BUL9,BUL9,BUL9,BUL9,BUL9
	DC.L	BUL9,BUL9,BUL9,BUL9,BUL9
	DC.L	-1
S5	DC.L	CURS1,CURS2,CURS3,CURS4,CURS5,CURS6
	DC.L	BUL4,BUL4,BUL4,BUL4,BUL4,BUL4,BUL4
	DC.L	BUL4,BUL4,BUL4
	DC.L	BUL8,BUL8,BUL8,BUL8,BUL8,BUL8,BUL8
	DC.L	BUL8,BUL8,BUL8
	DC.L	BUL7,BUL7,BUL7,BUL7,BUL7,BUL7,BUL7
	DC.L	BUL7,BUL7,BUL7,BUL7
	DC.L	BUL9,BUL9,BUL9,BUL9,BUL9,BUL9,BUL9
	DC.L	BUL9,BUL9,BUL9,BUL9,BUL9
	DC.L	BUL10,BUL10,BUL10,BUL10,BUL10,BUL10,BUL10
	DC.L	BUL10,BUL10,BUL10,BUL10,BUL10
	DC.L	-1
S6	DC.L	CURS1,CURS2,CURS3,CURS4,CURS5,CURS6
	DC.L	BUL6,BUL6,BUL6,BUL6,BUL6,BUL6,BUL6
	DC.L	BUL6,BUL6,BUL6,BUL6,BUL6,BUL6,BUL6
	DC.L	-1

POINT	DC.L	0
CURSOR	DC.L   CURS1
CURS1	DC.L	C1
	DC.W	0,0,16,15,8,4,6
	DC.L   C1M
CURS2	DC.L	C2
	DC.W	0,0,16,13,8,4,6
	DC.L   C2M
CURS3	DC.L	C3
	DC.W	0,0,16,12,8,4,6
	DC.L   C3M
CURS4	DC.L	C4
	DC.W	0,0,16,11,8,4,6
	DC.L   C4M
CURS5	DC.L	C5
	DC.W	0,0,16,11,8,4,6
	DC.L   C5M
CURS6	DC.L	C6
	DC.W	1,0,16,14,8,4,6
	DC.L   C6M
BUL1	DC.L	B10
	DC.W	0,0,15,15,8,4,6
	DC.L	M10
BUL2	DC.L	B9
	DC.W	0,0,15,15,8,4,6
	DC.L	M9
BUL3	DC.L	B8
	DC.W	0,0,15,15,8,4,6
	DC.L	M8
BUL4	DC.L	B7
	DC.W	0,0,15,15,8,4,6
	DC.L	M7
BUL5	DC.L	B6
	DC.W	0,0,15,15,8,4,6
	DC.L	M6
BUL6	DC.L	B5
	DC.W	0,0,15,15,8,4,6
	DC.L	M5
BUL7	DC.L	B4
	DC.W	0,0,15,15,8,4,6
	DC.L	M4
BUL8	DC.L	B3
	DC.W	0,0,15,15,8,4,6
	DC.L	M3
BUL9	DC.L	B2
	DC.W	0,0,15,15,8,4,6
	DC.L	M2
BUL10	DC.L	B1
	DC.W	0,0,15,15,8,4,6
	DC.L	M2

C1	INCBIN	COPYB11.IMG
C2	INCBIN	COPYB12.IMG
C3	INCBIN	COPYB13.IMG
C4	INCBIN	COPYB14.IMG
C5	INCBIN	COPYB15.IMG
C6	INCBIN	COPYB16.IMG
C1M	INCLUDE COPYB11.M
C2M	INCLUDE COPYB12.M
C3M	INCLUDE COPYB13.M
C4M	INCLUDE COPYB14.M
C5M	INCLUDE COPYB15.M
C6M	INCLUDE COPYB16.M
B10	INCBIN	COPYB10.IMG
M10	INCLUDE COPYB10.M
B9	INCBIN	COPYB9.IMG
M9	INCLUDE COPYB9.M
B8	INCBIN	COPYB8.IMG
M8	INCLUDE COPYB8.M
B7	INCBIN	COPYB7.IMG
M7	INCLUDE COPYB7.M
B6	INCBIN	COPYB6.IMG
M6	INCLUDE COPYB6.M
B5	INCBIN	COPYB5.IMG
M5	INCLUDE COPYB5.M
B4	INCBIN	COPYB4.IMG
M4	INCLUDE COPYB4.M
B3	INCBIN	COPYB3.IMG
M3	INCLUDE COPYB3.M
B2	INCBIN	COPYB2.IMG
M2	INCLUDE COPYB2.M
B1	INCBIN	COPYB1.IMG
M1	INCLUDE COPYB1.M

FOND	DS.L	512
	
PAL		dc.w	$0000,$0020,$0040,$0060,$0220,$0332,$0554,$0200
		dc.w	$0310,$0520,$0631,$0757,$0760,$0777,$0537,$0444

HBL	
		;dc.w	$0,$0,$8,$8,$1,$1,
		dc.w	$9,$9,$2,$2,$A,$A,$3,$3,$B,$B
		dc.w	$4,$4,$C,$C,$5,$5,$D,$D,$6,$6,$E,$E,$7,$7,$F,$F

		dc.w	$8F,$8F,$001F,$1F,$009F,$9F,$002F,$2F,$00AF,$AF,$003F,$3F,$00BF,$BF
		dc.w	$004F,$4F,$00CF,$CF,$005F,$5F,$00DF,$DF,$006F,$6F,$00EF,$EF,$007F,$7F,$FF,$FF

		dc.w	$087F,$87F,$01EF,$1EF,$096F,$96F,$02DF,$2DF,$0A5F,$A5F,$03CF,$3CF,$0B4F,$B4F
		dc.w	$04BF,$4BF,$0C3F,$C3F,$05AF,$5AF,$0D2F,$D2F,$069F,$69F,$0E1F,$E1F,$078F,$78F,$0F0F

		dc.w	$0F07,$F07,$0F0E,$F0E,$0F06,$F06,$0F0D,$F0D,$0F05,$F05,$0F0C,$F0C,$0F04,$F04
		dc.w	$0F0B,$F0B,$0F03,$F03,$0F0A,$F0A,$0F02,$F02,$0F09,$F09,$0F01,$F01,$0F08,$F08,$0F00,$F00,$F00,$F00,$F00,$F00

		dc.w	$0F80,$F80,$0F10,$F10,$0F90,$F90,$0F20,$F20,$0FA0,$FA0,$0F30,$F30,$0FB0,$FB0
		dc.w	$0F40,$F40,$0FC0,$FC0,$0F50,$F50,$0FD0,$FD0,$0F60,$F60,$0FE0,$FE0,$0F70,$F70
	
		dc.w	$FF0,$FF0,$770,$770,$EE0,$EE0,$660,$660,$DD0,$DD0,$550,$550,$CC0,$CC0,$440,$440
		dc.w	$BB0,$BB0,$330,$330,$AA0,$AA0,$220,$220,$990,$990,$110,$110,$880,$880,$0,$0

wait	dc.b 0
	even
TXT	DC.B $1B,"E    So this is the MAIN MENU of this",$d,$a
	dc.b "              DELIRIOUS  III",$d,$a,$d,$a
	dc.b "   Before entering this mad world you",$d,$a
	dc.b "    have to enter some parameters  :",$d,$a,$d,$a
	dc.b " Would you use :",$d,$a
	dc.b " 1 - The keyboard (arrows and space bar)",$d,$a
	dc.b " 2 - The mouse/joystick",0
	even
TXT2	dc.b $d,$a,$d,$a
	dc.b "Ok  for the keyboard,and now would you",$d,$a
	dc.b " 1 - Have the standard palette (4096)",$d,$a
	dc.b " 2 - Or   the extanded palette (32768)",0
	even
TXT3	dc.b $d,$a,$d,$a
	dc.b "OK And the next time would you want me",$d,$a
	dc.b "to ask you these questions again ?",$d,$a
	dc.b " 1 - Yes please",$d,$a
	dc.b " 2 - Not at all",0
	even
	      ****************************************
TXT4	dc.b $1b,'E',$d,$a
	dc.b 'Just a little word to say this menu',$d,$a
	dc.b "use a soundtrack at 25 Khz",$d,$a
	dc.b 'and the loader at 12.5 Khz',$d,$a
	dc.b 'and both are',$d,$a
	dc.b 'Coded by AXEL F.',$d,$a
	dc.b 'Graph by ALF',$d,$a
	dc.b 'Music  ???  I never know who made these',$d,$a
	dc.b 'great tunes',$d,$a,$d,$a
	dc.b 'The Boot Screen was coded by DOCTOR NO',$d,$a
	dc.b '(And me, but at the end)',$d,$a
	dc.b 'Graph and sounds by MARIO',$d,$a,$d,$a
	dc.b '  So, take your hammer and throw it',$d,$a
	dc.b '  to the ESC key',0 
	even
TXT5	dc.b $1b,'E',0
	EVEN
DECRUNCH:	movem.l d0-a6,-(sp)		
		cmpi.l	#'Ice!',(a0)+		
		bne.s	ice2_07		
		move.l	(a0)+,d0		
		lea	-8(a0,d0.l),a5	
		move.l	(a0)+,(sp)
		lea	108(a0),a4
		movea.l a4,a6
		adda.l	(sp),a6
		movea.l a6,a3
		movea.l a6,a1			
		lea	ice2_21+120(pc),a2	
		moveq	#$77,d0		
ice2_00:	move.b	-(a1),-(a2)
		dbra	d0,ice2_00
		bsr	ice2_0c
		bsr.s	ice2_08
ice2_04:	move.l	(sp),d0		
		lea	-120(a4),a1		
ice2_05:	move.b	(a4)+,(a1)+
		dbra	d0,ice2_05
		subi.l	#$010000,d0
		bpl.s	ice2_05
		moveq	#$77,d0		
		lea	ice2_21+120(pc),a2
ice2_06:	move.b	-(a2),-(a3)
		dbra	d0,ice2_06
ice2_07:	
		movem.l (sp)+,d0-a6		
		rts
ice2_08:	bsr.s	ice2_10
		bcc.s	ice2_0b
		moveq	#0,d1
		bsr.s	ice2_10
		bcc.s	ice2_0a
		lea	ice2_1e(pc),a1
		moveq	#4,d3
ice2_09:	move.l	-(a1),d0
		bsr	ice2_13
		move.b #$e,$ff8800
		bchg.b #2,$ff8802
		bchg.b #1,$ff8802
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice2_09
		add.l	20(a1),d1
ice2_0a:	move.b	-(a5),-(a6)
		dbra	d1,ice2_0a
ice2_0b:	cmpa.l	a4,a6
		bgt.s	ice2_16
		rts
ice2_0c:	moveq	#3,d0
ice2_0d:	move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice2_0d
		rts
ice2_0e:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_0f
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice2_15
ice2_0f:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice2_15
ice2_10:	add.l	d7,d7
		beq.s	ice2_11
		rts
ice2_11:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_12
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice2_12:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice2_13:	moveq	#0,d1
ice2_14:	add.l	d7,d7
		beq.s	ice2_0e
ice2_15:	addx.w	d1,d1
		dbra	d0,ice2_14
		rts
ice2_16:	lea	ice2_1f(pc),a1
		moveq	#3,d2
ice2_17:	bsr.s	ice2_10
		dbcc	d2,ice2_17
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice2_18
		bsr.s	ice2_13
ice2_18:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice2_1a
		lea	ice2_20(pc),a1
		moveq	#1,d2
ice2_19:	bsr.s	ice2_10
		dbcc	d2,ice2_19
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice2_13
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice2_1c
ice2_1a:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice2_10
		bcc.s	ice2_1b
		moveq	#8,d0
		moveq	#$40,d2
ice2_1b:	bsr.s	ice2_13
		add.w	d2,d1
ice2_1c:	lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice2_1d:	move.b	-(a1),-(a6)
		dbra	d4,ice2_1d
		bra	ice2_08
		dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
		dc.b $00,$07,$00,$02,$00,$03,$00,$01
		dc.b $00,$03,$00,$01
ice2_1e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
		dc.b $00,$00,$00,$07,$00,$00,$00,$04
		dc.b $00,$00,$00,$01
ice2_1f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
		dc.b $01,$00
ice2_20:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
		dc.b $00,$20
ice2_21:	ds.w 60	
	even

LOAD  MOVE.W  D1,D2 
      SUBQ.W  #1,D2 
      BMI.S   L0003 
      EXT.L   D0
      DIVU    #$A,D0
      MOVE.L  D0,D1 
      SWAP    D1
      ADDQ.W  #1,D1 
      BSR     L001C 
L0000
	BSR     L0004 
      TST.W   D4
      BNE.S   L0002 
      ADDQ.W  #1,D1 
      CMP.W   #$A,D1
      BLE.S   L0001 
      MOVEQ   #1,D1 
      ADDQ.W  #1,D0 
L0001:DBF     D2,L0000
L0002:BSR     L001F 
      TST.W   D4
      RTS 
L0003:MOVEQ   #-1,D4
      RTS 
L0004:MOVE.W  #2,L3B12
      TST.W   L3B10 
      BPL.S   L0006 
L0005:BSR     L0029 
L0006:CMP.W   L0033(PC),D0
      BEQ.S   L0007 
      BSR     L0025 
L0007:MOVE.B  L0031(PC),-$79F3.W
      MOVE.B  L0030(PC),-$79F5.W
      MOVE.B  L002F(PC),-$79F7.W
      MOVE.W  #$84,(A6) 
      MOVE.W  D1,(A5) 
      BSR.S   L000A 
      MOVE.W  #$90,(A6) 
      MOVE.W  #$190,(A6)
      MOVE.W  #$90,(A6) 
      MOVE.W  #1,(A5) 
      MOVE.W  #$80,(A6) 
      MOVE.W  #$80,(A5) 
      BSR.S   L000D 
      MOVEQ   #4,D4 
      SWAP    D4
L0008:BTST    #5,-$5FF.W
      BEQ.S   L0009 
      SUBQ.L  #1,D4 
      BNE.S   L0008 
      BSR     L002D 
      MOVEQ   #-1,D4
      RTS 
L0009:MOVE.W  (A5),D4 
      ANDI.W  #$18,D4 
      BEQ.S   L000B 
      SUBQ.W  #1,L3B12
      BEQ.S   L0005 
      BCC.S   L0007 
L000A:RTS 
L000B:MOVE.W  #$90,(A6) 
      MOVE.W  (A6),D4 
      NOT.W   D4
      ANDI.W  #1,D4 
      BNE.S   L000C 
      ADDI.L  #$200,L3B08 
      TST.W   D4
L000C:RTS 
L000D:MOVEQ   #$A,D7
L000E:DBF     D7,L000E
      RTS 

L001C:LEA     -$79FA.W,A6 
      LEA     -$79FC.W,A5 
      BSR.S   L001D 
      MOVE.L  A0,L3B08
      RTS 
L001D:MOVE.W  L0032(PC),D6
      ADDQ.B  #1,D6 
      LSL.B   #1,D6 
      OR.W    L3B0E,D6
      EORI.B  #7,D6 
      ANDI.B  #7,D6 
      BSR.S   L0023 
      MOVE.W  #$82,(A6) 
      MOVE.W  L0033(PC),(A5)
      BSR     L001E 
L001E:RTS 
L001F:MOVE.W  #$1C2,D6
L0020:MOVE.W  #$1000,D7 
L0021:DBF     D7,L0021
      BSR     L0024 
      BEQ.S   L0022 
      SUBQ.W  #1,D6 
      BNE.S   L0020 
      BSR     L002D 
L0022:MOVEQ   #7,D6 
L0023:MOVE    SR,-(A7)
      ORI.W   #$700,SR
      MOVE.B  #$E,-$7800.W
      MOVE.B  -$7800.W,D7 
      MOVE.B  D3,D7 
      NOP 
      MOVE.B  D7,-$77FE.W 
      MOVE    (A7)+,SR
      RTS 
L0024:MOVE    SR,-(A7)
      ORI.W   #$700,SR
      MOVE.W  #$80,(A6) 
      MOVE.W  (A5),D7 
      MOVE    (A7)+,SR
      BTST    #7,D7 
      RTS 
L0025:MOVE.W  #$86,(A6) 
      MOVE.W  D0,(A5) 
      BSR.S   L0028 
      MOVE.W  #$80,(A6) 
      MOVE.W  #$13,(A5) 
      BSR     L000D 
      MOVEQ   #8,D4 
      SWAP    D4
L0026:BTST    #5,-$5FF.W
      BEQ.S   L0027 
      SUBQ.L  #1,D4 
      BNE.S   L0026 
      BSR     L002D 
      MOVEQ   #-1,D4
      RTS 
L0027:MOVE.W  D0,L3B10
      MOVE.W  (A5),D4 
      ANDI.W  #$10,D4 
L0028:RTS 
L0029:MOVE.W  #$80,(A6) 
      MOVE.W  #3,(A5) 
      BSR     L000D 
L002A:BTST    #5,-$5FF.W
      BNE.S   L002A 
L002B:MOVE.W  (A5),D4 
      BCHG    #2,D4 
      ANDI.W  #4,D4 
      MOVE.W  #$82,(A6) 
      CLR.W   (A5)
      BSR.S   L002C 
      CLR.W   L3B10 
      TST.W   D4
L002C:RTS 
L002D:MOVE.W  #$80,(A6) 
      MOVE.W  #$D0,(A5) 
      MOVEQ   #$20,D4 
L002E:DBF     D4,L002E
      MOVE.W  (A5),D4 
      RTS 
L3B08	DC.L 0
L3B0E	DC.W 0
L3B10	DC.W 0
L3B12	DC.W 0
L3B16	DC.W 0
ZUEND DCB.W 8,0
L002F EQU L3B08+1 
L0030 EQU L3B08+2 
L0031 EQU L3B08+3 
L0032 EQU ZUEND+4 
L0033 EQU ZUEND+8
	EVEN	



MZIK
	BSR	INIT_MUZEXX
	BRA	PLAY_MUZEXX
	BRA	PLAY_MUZ

INIT_MUZEXX
	LEA		SEQ,A0
	LEA		PAT,A1
	LEA		NBR_INS,A2
	MOVE.L		#MUZEXX,A3
	MOVE	#$1D8,(A0)
	MOVE	#$258,(A1)
	MOVE	#15,(A2)
	CMP.L	#'M.K.',$438(A3)
	BNE		REAL_DOCs_MODULE
	MOVE	#$3B8,(A0)
	MOVE	#$43C,(A1)
	MOVE	#31,(A2)
REAL_DOCs_MODULE

	MOVE.L		#MUZEXX,A0
	ADD		SEQ,A0
	MOVE.L	#$80,D0
	MOVEQ	#0,D1
INIT_MUZEXX1
	MOVE.L	D1,D2
	SUBQ	#1,D0
INIT_MUZEXX2
	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	INIT_MUZEXX1
	DBF		D0,INIT_MUZEXX2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	MOVE.L		#MUZEXX,A0
	ADD		PAT,A0
	ADD.L	D2,A0
	MOVE.L		#MUZEXX,A1
	ADD.L		#20,A1
	LEA		16+INS,A2
	MOVE	NBR_INS,D0
	SUBQ	#1,D0
INIT_MUZEXX3
	MOVE.L	A0,4(A2)
	MOVEQ	#0,D1
	MOVE	22(A1),D1
	LSL.L	#1,D1
	MOVE.L	D1,(A2)
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE	24(A1),D1
	BEQ		INIT_MUZEXX4
	SUBQ	#1,D1
INIT_MUZEXX4
	MOVE	D1,12(A2)
	MOVEQ	#0,D1
	MOVE	28(A1),D1
	LSL.L	#1,D1
	CMP.L	#2,D1
	BNE		INIT_MUZEXX5
	MOVEQ	#0,D1
INIT_MUZEXX5
	SWAP	D1
	MOVE.L	D1,8(A2)
	LEA		30(A1),A1
	LEA		16(A2),A2
	DBRA	D0,INIT_MUZEXX3

	LEA 		MU,A0
	MOVE.W		#2520,D0
CCLR	MOVE.L 	#0,(A0)+
	DBF		D0,CCLR
 	
	MOVE.W	#2,$FF8920  

	LEA		MUSIQUE_END,A0	
	MOVE.L		A0,D0
	MOVE.W		D0,$FF8912
	ROR.L		#8,D0
	MOVE.W		D0,$FF8910
	ROR.L		#8,D0
	MOVE.W		D0,$FF890E

	LEA		MU,A0
	MOVE.L		A0,D0
	MOVE.W		D0,$FF8906
	ROR.L		#8,D0
	MOVE.W		D0,$FF8904
	ROR.L		#8,D0
	MOVE.W		D0,$FF8902
	MOVE.L		#$33fc0003,rt
	MOVE.L		#$00ff8900,rt+4
	
	RTS


PLAY_MUZEXX
ON	
	MOVE	#6,SPD+2
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	MOVE.L		#MUZEXX,A0
	ADD		SEQ,A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF,A0
	LEA		OFF,A1
	LEA		OFF,A2
	LEA		OFF,A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	MOVE.W	#20160/4,D0
	LEA	MU,A0
CLRR	MOVE.L #0,(A0)+
	DBF D0,CLRR
         move.w  #$552,d0    ;fort volume
         bsr     PLAY_SAMP
         move.w  #$552,d0    
         bsr     PLAY_SAMP
         move.w  #$512,d0    
         bsr     PLAY_SAMP
         move.w  #$512,d0    
         bsr     PLAY_SAMP
         move.w  #$48a,d0    ;aigu maxi
         bsr     PLAY_SAMP
         move.w  #$48a,d0    
         bsr     PLAY_SAMP
         move.w  #$447,d0    ;grave maxi
         bsr     PLAY_SAMP
         move.w  #$447,d0    
         bsr     PLAY_SAMP

	LEA	MU,A0
	MOVE.L	A0,SA4
	MOVE.L	A0,MDEB
	LEA	MUSIQUE_END,A0
	MOVE.L	A0,MFIN
	rts
PLAY_SAMP:        move.w  #$7FF,$FFFF8924  ;    MASK PROCESSEUR SON
                  cmpi.w  #$7FF,$FFFF8924  ;    PRET A RECEVOIR ??
                  bne.s   PLAY_SAMP       
                  move.w  d0,$FFFF8922     ;    REGLAGE VOLUME + FILTRES
                  rts

L0	MOVE.L		#0,D0
F0	MOVE.L		#0,V0+2
	BRA.S		V1
L1	MOVE.L		#0,D1
F1	MOVE.L		#0,V1+2
	BRA.S		V2
L2	MOVE.L		#0,D2
F2	MOVE.L		#0,V2+2
	BRA.S		V3
L3	MOVE.L		#0,D3
F3	MOVE.L		#0,V3+2
	BRA.S		OUT


AMIGA	
	MOVE.L		SA4,A4
;AMM
	MOVEQ		#0,D7
	MOVE.W		#504,D6
AM2
	SWAP		D0					;2 DOUBLE CYCLES	
	SWAP		D1					;2
	SWAP		D2					;2
	SWAP		D3					;2
V0	SUB.L		#0,D0					;8
	BMI.S		L0					;4
V1	SUB.L		#0,D1					;8
	BMI.S		L1					;4
V2	SUB.L		#0,D2					;8
	BMI.S		L2					;4
V3	SUB.L		#0,D3					;8
	BMI.S		L3					;4
OUT	SWAP		D0					;2
	SWAP		D1					;2
	SWAP		D2					;2
	SWAP		D3					;2
	MOVE.B		0(A0,D0),D4				;7
	MOVE.B		0(A2,D2),D5				;7
	ADD.B		0(A1,D1),D4				;7
	ADD.B		0(A3,D3),D5				;7	
 *	La ligne 525 est ici
	MOVE.B		D4,(A4)+			
	MOVE.B		D5,(A4)+
	DBF 		D6,AM2					;5
	CMP.L		MFIN,A4
	BLT		AM5
	MOVE.L		MDEB,A4	
AM5	MOVE.L 	A4,SA4
rt	MOVE.W 	#3,$FF8900
	MOVE.W		#$4E75,rt	* ceci evite le bug durant
					* les 6 premieres minutes
	RTS

SA4	DC.L	0
MDEB	DC.L	0
MFIN	DC.L	0	
	

PLAY_MUZ
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEM.L	REGIS,D0-D6/A0-A6
	;MOVE.W		#$700,$FF8240
	JSR		AMIGA
	;MOVE.W		#7,$FF8240
	SUBQ.B	#1,SPEED
	BEQ.S	PLAY
	;MOVE.W		#5,$FF8240
	JSR		EFFECT
END_VBL
	;MOVE.W		#$0,$FF8240
	MOVEM.L	D0-D6/A0-A6,REGIS
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

PLAY
NO_KEYBOARD1
	MOVEM.L	D0-D1/A0-A5,-(SP)
SPD	MOVE.B	#6,SPEED
	SUBQ.B	#1,POS
	BNE		NO_NEW_PATTERN
	MOVE.B	#64,POS
	ADDQ.L	#1,MUS+2
	SUBQ.B	#1,TRK
	BMI		RESTART
	MOVEQ	#0,D0
MUS	MOVE.B	$0,D0
	SWAP	D0
	LSR.L	#6,D0
	MOVE.L		#MUZEXX,A0
	ADD		PAT,A0
	ADD.L	D0,A0
	MOVE.L	A0,ADD_IN_PAT
NO_NEW_PATTERN
	MOVE.L	ADD_IN_PAT,A0
	LEA		FRQ,A1
	LEA		INS,A2
	LEA		COMMAND,A3
	LEA		VOICE0,A4
	BSR		LOAD_VOICE
	LEA		VOICE1,A4
	BSR		LOAD_VOICE
	LEA		VOICE2,A4
	BSR		LOAD_VOICE
	LEA		VOICE3,A4
	BSR		LOAD_VOICE
	MOVE.L	A0,ADD_IN_PAT
	MOVEM.L	(SP)+,D0-D1/A0-A5
	MOVEM.L	D4/A5,-(SP)
	LEA		VOICE0,A5
	TST.B	20(A5)
	BEQ.S	CONT0
	MOVE.L	(A5),D0
	MOVE.L	4(A5),A0
	MOVE.L	8(A5),D4
	MOVE.L	D4,L0+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V0+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F0+2
CONT0
	CLR.B	20(A5)
	LEA		VOICE1,A5
	TST.B	20(A5)
	BEQ.S	CONT1
	MOVE.L	(A5),D1
	MOVE.L	4(A5),A1
	MOVE.L	8(A5),D4
	MOVE.L	D4,L1+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V1+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F1+2
CONT1
	CLR.B	20(A5)
	LEA		VOICE2,A5
	TST.B	20(A5)
	BEQ.S	CONT2
	MOVE.L	(A5),D2
	MOVE.L	4(A5),A2
	MOVE.L	8(A5),D4
	MOVE.L	D4,L2+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V2+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F2+2
CONT2
	CLR.B	20(A5)
	LEA		VOICE3,A5
	TST.B	20(A5)
	BEQ.S	CONT3
	MOVE.L	(A5),D3
	MOVE.L	4(A5),A3
	MOVE.L	8(A5),D4
	MOVE.L	D4,L3+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V3+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F3+2
CONT3
	CLR.B	20(A5)
	MOVEM.L	(SP)+,D4/A5

	BRA		END_VBL

LOAD_VOICE
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE	D0,30(A4)
	MOVE	(A0)+,D0
	BEQ.S	COMMAND?
	BTST	#12,D0
	BEQ.S	CONT_FRQ
	AND		#$FFF,D0
	MOVE	#$100,D1
CONT_FRQ
	MOVE.B	#1,20(A4)
	MOVE	D0,24(A4)
	ADD		D0,D0
	ADD		D0,D0		
	MOVE.L	(A1,D0.W),D0
	MOVE.L	D0,12(A4)
	TST.L	16(A4)
	BEQ.S	CONT_LOAD_FRQ
	MOVE.L	D0,16(A4)
CONT_LOAD_FRQ
	OR.B	(A0),D1
	AND		#$FF0,D1	
	BEQ.S	COMMAND?
	MOVE.L	12(A4),16(A4)
	MOVE.L	0(A2,D1.W),(A4)
	MOVE.L	4(A2,D1.W),4(A4)
	MOVE.L	8(A2,D1.W),8(A4)
	BNE.S	REPEAT
	CLR.L	16(A4)
REPEAT
COMMAND?
	MOVE	(A0)+,D0
	MOVE.B	D0,D1
	AND		#$F00,D0
	LSR		#6,D0
	MOVE.L	(A3,D0.W),A5
	JMP		(A5)

NO_COMMAND
	RTS

ARPEGGIO
	TST.B	D1
	BEQ.S	NO_ARPEGGIO
	MOVE.B	#0,22(A4)
	MOVE.B	D1,23(A4)
	MOVE.B	#1,21(A4)		
	MOVE	#1,30(A4)
NO_ARPEGGIO
	RTS

PORTAMENTO_UP
	MOVE.B	#1,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

PORTAMENTO_DOWN
	MOVE.B	#2,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

POSITION_JUMP
	MOVE.L		#MUZEXX,A5
	ADD		SEQ,A5
	LEA		-1(A5),A5
	MOVE.B	#1,POS
	MOVE.L	A5,D0
	ADD.L	D1,D0
	MOVE.L	D0,MUS+2
	MOVE.B	-1(A5),D0
	SUB		D1,D0
	MOVE.B	D0,TRK
	RTS

SET_VOLUME
	TST.B	D1
	BNE.S	NO_CHANGE		
	CLR.L	12(A4)			
	MOVE.B	#1,20(A4)		
NO_CHANGE
	RTS

PATTERN_BREAK
	MOVE.B	#1,POS
	RTS

SET_FILTER
	RTS

SET_SPEED
	MOVE.B	D1,SPD+3
	MOVE.B	D1,SPEED
	RTS

COMMAND		DC.L	ARPEGGIO,PORTAMENTO_UP,PORTAMENTO_DOWN,NO_COMMAND
			DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,NO_COMMAND
			DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,POSITION_JUMP
			DC.L	SET_VOLUME,PATTERN_BREAK,SET_FILTER,SET_SPEED

EFFECT
	MOVEM.L	D4-D6/A4-A6,-(SP)
	LEA		FRQ,A5
	LEA		VOICE0,A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT1
	BSR		DO_EFFECT
	MOVE.L	26(A6),V0+2
	TST.L	F0+2
	BEQ.S	CONT_EFFECT1
	MOVE.L	26(A6),F0+2
CONT_EFFECT1
	LEA		VOICE1,A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT2
	BSR		DO_EFFECT
	MOVE.L	26(A6),V1+2
	TST.L	F1+2
	BEQ.S	CONT_EFFECT2
	MOVE.L	26(A6),F1+2
CONT_EFFECT2
	LEA		VOICE2,A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT3
	BSR		DO_EFFECT
	MOVE.L	26(A6),V2+2
	TST.L	F2+2
	BEQ.S	CONT_EFFECT3
	MOVE.L	26(A6),F2+2
CONT_EFFECT3
	LEA		VOICE3,A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT4
	BSR		DO_EFFECT
	MOVE.L	26(A6),V3+2
	TST.L	F3+2
	BEQ.S	CONT_EFFECT4
	MOVE.L	26(A6),F3+2
CONT_EFFECT4
	MOVEM.L	(SP)+,D4-D6/A4-A6
	RTS

DO_EFFECT
	MOVE.B	22(A6),D4
	BEQ.S	ARPEGGIO_ROUT
	CMP.B	#1,D4
	BEQ.S	PORTUP
	CMP.B	#2,D4
	BEQ.S	PORTDOWN
	RTS

PORTUP
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	SUB		D4,D5
	CMP		#$71,D5
	BPL.S	OK_PORTUP
	MOVEQ	#$71,D5
OK_PORTUP
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

PORTDOWN
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	ADD		D4,D5
	CMP		#$358,D5
	BMI.S	OK_PORTDOWN
	MOVE	#$358,D5
OK_PORTDOWN
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

ARPEGGIO_ROUT
	MOVE.B	21(A6),D4
	CMP.B	#1,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#2,D4
	BEQ.S	ARP_ROUT2
	CMP.B	#3,D4
	BEQ.S	ARP_ROUT3
	CMP.B	#4,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#5,D4
	BEQ.S	ARP_ROUT2
	RTS

ARP_ROUT1
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	LSR.B	#4,D4
	BRA.S	ARP_ROUT
ARP_ROUT2
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	AND.B	#$0F,D4
	BRA.S	ARP_ROUT
ARP_ROUT3
	MOVE	24(A6),D6
	BRA.S	END_ARP_ROUT2
ARP_ROUT
	ADD		D4,D4
	MOVE	24(A6),D5
	LEA		ARPEGGIO_DATA,A4
ARP_LOOP
	CMP		(A4),D5
	BEQ.S	END_ARP_ROUT1
	LEA		2(A4),A4
	BRA.S	ARP_LOOP
END_ARP_ROUT1
	MOVE	(A4,D4),D6
END_ARP_ROUT2
	ADD		D6,D6
	ADD		D6,D6
	MOVE.L	(A5,D6),26(A6)
	ADDQ.B	#1,21(A6)
	RTS

RESTART
	MOVEM.L	(SP)+,D0-D1/A0-A5
	MOVE	#6,SPD+2 
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	MOVE.L		#MUZEXX,A0
	ADD		SEQ,A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF,A0
	LEA		OFF,A1
	LEA		OFF,A2
	LEA		OFF,A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	BRA		PLAY
END_OF_MUZEXX
	RTS
IMAGES
	INCBIN	MAIN.STE
	EVEN

OFF			DC.L	0
SPEED		DC.B	0
POS			DC.B	0
TRK			DC.B	0
SEQ			DS.W	1
PAT			DS.W	1
NBR_INS		DS.W	1
FRQ			incbin '25_khz.frq',0
ARPEGGIO_DATA	DC.W	$0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
				DC.W	$023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
				DC.W	$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0
				DC.W	$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097
				DC.W	$008F,$0087,$007F,$0078,$0071,$0000,$0000,$0000

VOICE0		DS.L	8
VOICE1		DS.L	8
VOICE2		DS.L	8
VOICE3		DS.L	8
ADD_IN_PAT	DS.L	1
REGIS		DS.L	14
INS			DS.L	32*4
MU			DS.W 		504*23
MUSIQUE_END		DS.L		10
	DS.L	10
MUZEXX			


			;INCBIN	3VOIES.MUS
	end


	

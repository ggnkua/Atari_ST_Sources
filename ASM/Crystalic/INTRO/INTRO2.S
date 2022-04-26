START:
  MOVE.L A7,A5
  MOVE.L #UNDERSTACK,A7
  MOVE.L 4(A5),A5
  MOVE.L A5,BEGIN_BASE
  MOVE.L #PROEND,A4
  SUB.L #START,A4
  ADD.L #$100,A4
  MOVE.L A4,LANG_PROG
  MOVE.L LANG_PROG,-(SP)
  MOVE.L BEGIN_BASE,-(SP)
  CLR.W -(SP)
  MOVE.W #$4A,-(SP)
  TRAP #1
  ADD.L #12,SP

	JMP		main
LOAD1:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL1,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
LOAD2:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL2,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
LOAD3:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL3,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
LOAD4:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL4,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
LOAD5:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL5,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
LOAD6:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL6,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
LOAD7:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL7,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
LOAD8:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL8,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
LOAD9:
	move.l #NUL,-(sp)	
	move.l #NUL,-(sp)	
	move.l #FIL9,-(sp)
	CLR.w	-(sp)	
	move.w	#$4B,-(sp)
	trap	#1
	add.l	#16,sp
***************************************************
******************************************************************
PROEND:
********************************************************************
save_ints
	MOVE.B	$FFFFFA07.W,OLD07
	MOVE.B	$FFFFFA09.W,OLD09
	MOVE.B	$FFFFFA1B.W,OLD1B
	MOVE.L	$120.W,OLDHBL
	MOVE.L	$70.W,oldvbl
	rts
init_ints
	MOVE.W #$2700,SR		STOP INTERRUPTS
	MOVE.L #vbi,$70.W		NEW VBL VECTOR
	MOVE.L #TIMER_B,$120.W		NEW TIMER B INTERRUPT HANDLER
	CLR.B $FFFFFA07.W		MFP RESET
	CLR.B $FFFFFA09.W
	ORI.B #1,$FFFFFA07.W		ENABLE TIMER B
	ORI.B #1,$FFFFFA13.W
	CLR.B $FFFFFA1B.W		STOP TIMER B
	MOVE.W #$2300,SR		ENABLE INTERRUPTS
	rts
ret_ints
	MOVE.B	OLD07,$FFFFFA07.W
	MOVE.B	OLD09,$FFFFFA09.W
	MOVE.B	OLD1B,$FFFFFA1B.W
	MOVE.L	OLDHBL,$120.W
	MOVE.L	oldvbl,$70.W
	rts
main:
	pea	0			*supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,physbase
	move.l	usp,a0			*save usp
	move.l	a0,save_usp
	move.l	$44e,scrbase

	jsr	save_ints

	move.w	#0,-(sp)
	move.l	#$30000,-(sp)
	move.l	#$30000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	jsr	scrlinit
	jsr	setpic
	JSR	SPRITEVAR
	
	jsr	init_ints			*init. interrupts
	clr.w	wfnc


	lea	font+2,a0
	move.l	#$ff8240,a1
	rept	8
	move.l	(A0)+,(a1)+
	endr

	JSR	SETMUSIC
demo_loop:
	cmp.w	#1,wfnc	
	bne	demo_loop
	clr.w	wfnc

	CMP.B	#$02,$FFFC02
	BEQ		TAN1
	CMP.B	#$03,$FFFC02
	BEQ		TAN2
	CMP.B	#$04,$FFFC02
	BEQ		TAN3
	CMP.B	#$05,$FFFC02
	BEQ		TAN4
	CMP.B	#$06,$FFFC02
	BEQ		TAN5
	CMP.B	#$07,$FFFC02
	BEQ		TAN6
	CMP.B	#$08,$FFFC02
	BEQ		TAN7
	CMP.B	#$09,$FFFC02
	BEQ		TAN8
	CMP.B	#$0A,$FFFC02
	BEQ		TAN9

	bne		demo_loop
TAN1:
	jsr		CLEANALL
	jmp		LOAD1
TAN2:
	jsr		CLEANALL
	jmp		LOAD2
TAN3:
	jsr		CLEANALL
	jmp		LOAD3
TAN4:
	jsr		CLEANALL
	jmp		LOAD4
TAN5:
	jsr		CLEANALL
	jmp		LOAD5
TAN6:
	jsr		CLEANALL
	jmp		LOAD6
TAN7:
	jsr		CLEANALL
	jmp		LOAD7
TAN8:
	jsr		CLEANALL
	jmp		LOAD8
TAN9:
	jsr		CLEANALL
	jmp		LOAD9
CLEANALL:
	jsr	ret_ints

	MOVE.L	save_stk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts	
*****************************************************
plane4	move.l	#$30000,a0
	add.l	#160*187,a0
	move.w	#38,d1
nextline	movep.l	1(a0),d0		;byte 1-8 av 39
	movep.l	d0,(a0)
	movep.l	8(a0),d0
	movep.l	d0,1(a0)
	movep.l	9(a0),d0
	movep.l	d0,8(a0)
	movep.l	16(a0),d0
	movep.l	d0,9(a0)
	movep.l	17(a0),d0
	movep.l	d0,16(a0)
	movep.l	24(a0),d0
	movep.l	d0,17(a0)
	movep.l	25(a0),d0
	movep.l	d0,24(a0)
	movep.l	32(a0),d0
	movep.l	d0,25(a0)
	movep.l	33(a0),d0		;byte 9-16 av 39
	movep.l	d0,32(a0)
	movep.l	40(a0),d0
	movep.l	d0,33(a0)
	movep.l	41(a0),d0
	movep.l	d0,40(a0)
	movep.l	48(a0),d0
	movep.l	d0,41(a0)
	movep.l	49(a0),d0
	movep.l	d0,48(a0)
	movep.l	56(a0),d0
	movep.l	d0,49(a0)
	movep.l	57(a0),d0
	movep.l	d0,56(a0)
	movep.l	64(a0),d0
	movep.l	d0,57(a0) 
	movep.l	65(a0),d0		;byte 17-24 av 39
	movep.l	d0,64(a0)
	movep.l	72(a0),d0
	movep.l	d0,65(a0)
	movep.l	73(a0),d0
	movep.l	d0,72(a0)
	movep.l	80(a0),d0
	movep.l	d0,73(a0)
	movep.l	81(a0),d0
	movep.l	d0,80(a0)
	movep.l	88(a0),d0
	movep.l	d0,81(a0)
	movep.l	89(a0),d0
	movep.l	d0,88(a0)
	movep.l	96(a0),d0
	movep.l	d0,89(a0) 
	movep.l	97(a0),d0		;byte 25-32 av 39
	movep.l	d0,96(a0)
	movep.l	104(a0),d0
	movep.l	d0,97(a0)
	movep.l	105(a0),d0
	movep.l	d0,104(a0)
	movep.l	112(a0),d0
	movep.l	d0,105(a0)
	movep.l	113(a0),d0
	movep.l	d0,112(a0)
	movep.l	120(a0),d0
	movep.l	d0,113(a0)
	movep.l	121(a0),d0
	movep.l	d0,120(a0)
	movep.l	128(a0),d0
	movep.l	d0,121(a0)
	movep.l	129(a0),d0		;byte 33-39 av 39
	movep.l	d0,128(a0)
	movep.l	136(a0),d0
	movep.l	d0,129(a0)
	movep.l	137(a0),d0
	movep.l	d0,136(a0)
	movep.l	144(a0),d0
	movep.l	d0,137(a0)
	movep.l	145(a0),d0
	movep.l	d0,144(a0)
	movep.l	152(a0),d0
	movep.l	d0,145(a0)
	movep.l	153(a0),d0
	movep.l	d0,152(a0)
	lea	160(a0),a0
	dbra.w	d1,nextline
	addq.b	#$01,stepcount
	cmp.b	#$04,stepcount
	bne.w	jump1
	jsr	nextchar
	jmp	plup
jump1	cmp.b	#$02,stepcount
	beq.w	blup1
	addq.l	#$1,fontdat
	jmp	plup
blup1	addq.l	#$7,fontdat
plup	move.l	#$30000,a1
	add.l	#160*187+152,a1

	move.l	fontdat,a0
	move.w	#38,d0 
moredat	movep.l	(a0),d1
	movep.l	d1,(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	dbra.w	d0,moredat
	rts
	
scrlinit
	move.l	#font+34,fontstart
	move.l	#scrltxt,txtcount
	move.b	#$03,stepcount
	rts
*******************************	4plane32line-scroll-subs
nextchar	
	clr.b	stepcount
	clr.l	d0
	addq.l	#$1,txtcount
	move.l	txtcount,a0
	move.b	(a0),d0
	sub.b	#32,d0
	cmp.b	#$d0,d0
	bne	jump2
	jsr	scrlwrap
jump2	clr.l	flum
	mulu	#$4,d0
	move.w	d0,flum+2
	move.b	#$00,flum+2
	move.l	flum,d0
	move.l	fontstart,d1
	lea	fontvect,a0
	add.l	d0,a0
	add.l	(a0),d1
	move.l	d1,fontdat
	rts
scrlwrap	lea	txtcount,a0
	lea	scrltxt,a1
	move.l	a1,(a0)
	move.l	(a0),d0
	move.l	d0,a0
	move.l	#$00000000,d0
	move.b	(a0),d0
	sub.b	#32,d0
	rts
scrltxt
 DC.B	"  AA BB CC DD EE FF GG HH II JJ KK LL MM NN OO PP QQ RR SS TT UU VV WW XX YY ZZ .. !! '' -- ,,      "

	dc.b	$f0
	even
SETMUSIC:
	MOVE.L	$70,MUSVBL
	MOVEQ	#1,D0
	JSR	MUSIC
	MOVE.L	#NEWMUS,$70
	RTS
NEWMUS:
	MOVEM	D0-A6,-(SP)
	JSR	MUSIC+8
	MOVEM	(SP)+,D0-A6
	MOVE.L	MUSVBL,-(SP)
	RTS
LEAVEMUSIC:
	MOVE.L	MUSVBL,$70
	RTS
vbi:
	movem.l	d0-d5/a0-a1,-(sp)		*save registers

	MOVEQ.W #0,D0
	MOVEQ.W #0,D1
	MOVEQ.W #0,D2
	MOVE.B #8,$FFFF8800.W  	;CHANNEL A
	MOVE.B $FFFF8800.W,D0
	MOVE.B #9,$FFFF8800.W   ;CHANNEL B
	MOVE.B $FFFF8800.W,D1
	MOVE.B #10,$FFFF8800.W  ;CHANNEL C
	MOVE.B $FFFF8800.W,D2
	BTST #4,D0              ;IS CHANNEL A AN ENVELOPE?
	BEQ .L1
	MOVE.B #10,D0           ;SET VOLUME IF IT IS
.L1	BTST #4,D1    		;IS CHANNEL B AN ENVELOPE?
       	BEQ .L2
	MOVE.B #10,D1
.L2	BTST #4,D2		;IS CHANNEL C AN ENVELOPE?
	BEQ .L3
	MOVE.B #10,D2
.L3	ADD.B D0,D0		;WORD ALIGNMENT
	ADD.B D1,D1
	ADD.B D2,D2

	LEA	$30000+160*171,A0
	MOVEQ	#3,D3
VUCLLOOP:
	REPT	40
	CLR.L	(A0)+
	ENDR
	ADD.W	#320,A0
	DBF.W	D3,VUCLLOOP
	
	LEA	$30000+160*171+80,A0
	LEA	$30000+160*171+72,A1
	DIVU	#4,D0
VU1:
*	REPT	2
	MOVE.W	#$FFFF,(A0)
*	MOVE.W	#$FFFF,2(A0)
*	MOVE.W	#$FFFF,4(A0)
*	MOVE.W	#$FFFF,6(A0)
	MOVE.W	#$FFFF,(A1)
*	MOVE.W	#$FFFF,2(A1)
*	MOVE.W	#$FFFF,4(A1)
*	MOVE.W	#$FFFF,6(A1)
*	ADD.W	#160,A0
*	ADD.W	#160,A1
*	ENDR
	ADDQ.W	#8,A0
	SUBQ.W	#8,A1
*	SUB.W	#312,A0
*	SUB.W	#328,A1
	DBF.W	D0,VU1

	LEA	$30000+160*174+80,A0
	LEA	$30000+160*174+72,A1
	DIVU	#4,D1
VU2:
*	REPT	2
*	MOVE.W	#$FFFF,(A0)
	MOVE.W	#$FFFF,2(A0)
*	MOVE.W	#$FFFF,4(A0)
*	MOVE.W	#$FFFF,6(A0)
*	MOVE.W	#$FFFF,(A1)
	MOVE.W	#$FFFF,2(A1)
* 	MOVE.W	#$FFFF,4(A1)
*	MOVE.W	#$FFFF,6(A1)
*	ADD.W	#160,A0
*	ADD.W	#160,A1
*	ENDR
	ADDQ.W	#8,A0
	SUBQ.W	#8,A1
	DBF.W	D1,VU2

	LEA	$30000+160*177+80,A0
	LEA	$30000+160*177+72,A1
	DIVU	#4,D2
VU3:
*	REPT	2
	MOVE.W	#$FFFF,(A0)
	MOVE.W	#$FFFF,2(A0)
*	MOVE.W	#$FFFF,4(A0)
*	MOVE.W	#$FFFF,6(A0)
	MOVE.W	#$FFFF,(A1)
	MOVE.W	#$FFFF,2(A1)
*	MOVE.W	#$FFFF,4(A1)
*	MOVE.W	#$FFFF,6(A1)
*	ADD.W	#160,A0
*	ADD.W	#160,A1
*	ENDR
	ADDQ.W	#8,A0
	SUBQ.W	#8,A1
	DBF.W	D2,VU3 

	lea		logopal,a3
	move.l	#$ff8240,a4
	rept	8
	move.l	(a3)+,(a4)+
	endr

	CLR.B $FFFFFA1B.W		STOP TIMER B
	MOVE.B #60,$FFFFFA21		OCCUR ON LAST SCANLINE
	move.l	#palhbi2,$120
	MOVE.B #8,$FFFFFA1B.W		START TIMER B


	JSR	PUTSPRITES
	jsr	plane4
*	MOVE.W	#160*4,D0
*PROLANG:
*	DBF.W	D0,PROLANG

	move.w	#1,wfnc			*set video flag

	movem.l	(sp)+,d0-d5/a0-a1		*pop registers
	rte
palhbi:
	CLR.B $FFFFFA1B.W		STOP TIMER
	lea	font+2,a3
	lea	$ff8240,a4
	rept	8
	move.l	(a3)+,(a4)+
	endr

	MOVE.B #14,$FFFFFA21		OCCUR ON LAST SCANLINE
	move.l	#TIMER_B,$120
	MOVE.B #8,$FFFFFA1B.W		START TIMER B
	BCLR #0,$FFFFFA0F.W		ACKNOWLEDGE
	rte
palhbi2:
	CLR.B $FFFFFA1B.W		STOP TIMER
	lea	pic+2,a3
	lea	$ff8240,a4
	rept	8
	move.l	(a3)+,(a4)+
	endr

	MOVE.B #125,$FFFFFA21		OCCUR ON LAST SCANLINE
	move.l	#palhbi,$120
	MOVE.B #8,$FFFFFA1B.W		START TIMER B
	BCLR #0,$FFFFFA0F.W		ACKNOWLEDGE
	rte
TIMER_B
	CLR.B $FFFFFA1B.W		STOP TIMER
	MOVEM.L D0/A0,-(A7)	
	MOVEA.W #$FA21,A0
	MOVE.B #200,(A0)
	MOVE.B #8,$FFFFFA1B.W		START TIMER
	MOVE.B (A0),D0
WAIT2	CMP.B (A0),D0			
	BEQ WAIT2
	CLR.B $FFFF820A.W		INTO 60 HZ

	MOVEQ.W #2,D0
LOOP1	NOP
	DBF D0,LOOP1
	MOVE.B #2,$FFFF820A.W		INTO 50 HZ
	MOVEM.L (A7)+,D0/A0
	BCLR #0,$FFFFFA0F.W		ACKNOWLEDGE
	CLR.B $FFFFFA1B.W		STOP TIMER B
*	MOVE.B #189,$FFFFFA21		OCCUR ON LAST SCANLINE
*	move.l	#palhbi,$120
*	MOVE.B #8,$FFFFFA1B.W		START TIMER B
	RTE				BUGGER OFF
setpic:
	lea	pic+34,a0
	move.l	#$30000,a1
	move.w	#8000,d0
picloop:
	move.l	(a0)+,(a1)+
	dbf.w	d0,picloop

	move.w	#40*70,d0
clearboard:
	clr.l	(a1)+
	dbf.w	d0,clearboard
	rts
CLEARPIC:
	
***************************************
	include	b:\putsprit.sss	
****************************************
oldvbl		dc.l	0
OLDHBL		dc.l	0
OLD1B		dc.B	0
OLD09		dc.B	0
OLD07		dc.B	0
	even
scrbase		ds.l	1 
flum		ds.l	1
fontstart	ds.l	1
txtcount	ds.l	1
stepcount	ds.l	1
fontdat		ds.l	1
	EVEN
pic:
	incbin	b:\ser_logo.pi1
	EVEN
MUSIC:
	INCBIN	B:\FLETCH.MUS
font
	incbin	B:\CUDDLY.PI1
	EVEN
fontvect
	dc.l	18800,12592,18800,18800,18800,18800,18800,12608,18800,18800
	dc.l	18800,18800,19360,12624,12576,18800,18800,18800,18800,18800
	dc.l	18800,18800,18800,18800,18800,18800,18800,18800,18800,18800
	dc.l	18800,18800,18800,0,$10,$20,$30,$40,$50,$60
	dc.l	$70,$80,$90,6240,6256,6272,6288,6304,6320,6336
	dc.l	6352,6368,6384,12480,12496,12512,12528,12544,12560,12576
	dc.l	18800,18800,18800,18800,18800,18800,18800,18800,18800,18800
	dc.l	18800,18800,18800,18800,18800,18800,18800,18800,18800,18800
	dc.l	18800,18800,18800,18800,18800,18800,18800,18800,18800,18800
	even
logopal:
	DC.W	$000,$577,$466,$133,$707,$404,$506,$303
	DC.W	$477,$367,$256,$145,$034,$355,$244,$700
***************************************
ScrollYTab:	include	a:\XSIN.dat
ScrollYTab2:	include	a:\SCROLLY.dat
**************************************
	even
LANG_PROG:	DC.L	0
BEGIN_BASE:	DC.L	0
NUL:		dc.w 0
*****************************
FIL1: dc.b "A:\INTRO.PRG",0
FIL2: dc.b "A:\INTRO.PRG",0
FIL3: dc.b "A:\INTRO.PRG",0
FIL4: dc.b "A:\INTRO.PRG",0
FIL5: dc.b "A:\INTRO.PRG",0
FIL6: dc.b "A:\INTRO.PRG",0
FIL7: dc.b "A:\INTRO.PRG",0
FIL8: dc.b "A:\INTRO.PRG",0
FIL9: dc.b "A:\INTRO.PRG",0
******************************
OVERSTACK:	DS.W	$1000
UNDERSTACK:	DS.W	$10
	even
save_usp	dc.l	0
physbase	ds.l    1
wfnc		dc.w	0
save_stk	dc.l	0
COUNT:		DC.W	0		
MUSVBL:		DC.L	0
		                                                  
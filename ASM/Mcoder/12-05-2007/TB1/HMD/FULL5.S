 	opt	o+
ecran = $68000
TEST = 1	;0=TEST FULL SCREEN

	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	lea	super,sp
;	jsr	debugger

	move.l	#ecran,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)
	move.b	#$40,$fffffa17.w

	bsr	clrpal

;	MOVE.L	#$0707FFFF,$FFFF8800.W
;	MOVE.L	#$0E0E0707,$FFFF8800.W

	lea	fullscr,a0
	lea	ecran,a1
	move	#274-1,d0	;nb lignes
.1	move	#230/2-1,d1
.2	move	(a0)+,(a1)+
	dbra	d1,.2
	dbra	d0,.1

	move.l	#firstvbl,$70.w
	move	#$2300,sr
	clr	sync
.wvbl	tst	sync
	beq.s	.wvbl

	move.b	#2,$ffff820a.w		;fr‚quence
	clr.b	$ffff8260.w

	MOVE.L	#compteurlignes,$70.w
	clr	sync
.w2	tst	sync
	beq.s	.w2

	CMP	#$D5,NBLIG
	BNE.S	.NEWSHIFT
	MOVE	#$E2-$10,OLDSH1+2
	MOVE	#$2C+$10,OLDSH2+2
.NEWSHIFT
	move	#$035,$ffff8240.w
	move	#$025,$ffff8242.w
	move	#$777,$ffff8244.w
	move	#$001,$ffff8246.w
	move	#$740,$ffff8248.w
	LEA	$FFFF8209.W,A0
	LEA	$FFFF8260.W,A1
	LEA	$FFFF820A.W,A2
	CLR.B	D0
	MOVEQ	#2,D1

	move.l	#inter0,$70.w
	CLR	sync
syn0:
	cmp	#250,sync
	bne.s	syn0
	ifeq	TEST
	bra.s	syn0
	endc

	move	#$2700,sr

	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)
	move.b	#$48,$fffffa17.w

	move.l	#newvblmcoder,$70.w
	move	#$2300,sr
	bsr	clrpal
	lea	ecran,a0
	move	#32000/4-1,d0
	moveq	#0,d1
.cls	move.l	d1,(a0)+
	dbra	d0,.cls

	lea	ecran+160*80+16,a2
	lea	ecran2,a1
	move	#41*40,d1
aaff0:
	move.l	(a1)+,(a2)+
	dbf	d1,aaff0

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move	#150,d0
	bsr	waitvbl		;150 vbls

	bsr	clrpal

	lea	imager+34,a0
	lea	ecran,a1
	move	#32000/4-1,d0
homo	move.l	(a0)+,(a1)+
	dbra	d0,homo

	move	#$000,$ffff8240.w
	move	#$700,$ffff8242.w
	move	#$700,$ffff8244.w
	move	#$700,$ffff8246.w
	move	#$700,$ffff8248.w
	move	#$000,$ffff824a.w
	move	#$700,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$700,$ffff8242.w
	move	#$700,$ffff8244.w
	move	#$700,$ffff8246.w
	move	#$700,$ffff8248.w
	move	#$700,$ffff824a.w
	move	#$700,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$700,$ffff8242.w
	move	#$700,$ffff8244.w
	move	#$000,$ffff8246.w
	move	#$000,$ffff8248.w
	move	#$000,$ffff824a.w
	move	#$000,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$700,$ffff8242.w
	move	#$000,$ffff8244.w
	move	#$700,$ffff8246.w
	move	#$700,$ffff8248.w
	move	#$700,$ffff824a.w
	move	#$700,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$700,$ffff8242.w
	move	#$000,$ffff8244.w
	move	#$700,$ffff8246.w
	move	#$700,$ffff8248.w
	move	#$000,$ffff824a.w
	move	#$700,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$000,$ffff8242.w
	move	#$700,$ffff8244.w
	move	#$700,$ffff8246.w
	move	#$700,$ffff8248.w
	move	#$000,$ffff824a.w
	move	#$000,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep	
	move	#50,d0
	bsr	waitvbl

	move	#$700,$ffff8242.w
	move	#$700,$ffff8244.w
	move	#$700,$ffff8246.w
	move	#$000,$ffff8248.w
	move	#$000,$ffff824a.w
	move	#$700,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$700,$ffff8242.w
	move	#$700,$ffff8244.w
	move	#$700,$ffff8246.w
	move	#$000,$ffff8248.w
	move	#$700,$ffff824a.w
	move	#$700,$ffff824c.w
	move	#$000,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$000,$ffff8242.w
	move	#$700,$ffff8244.w
	move	#$000,$ffff8246.w
	move	#$000,$ffff8248.w
	move	#$000,$ffff824a.w
	move	#$000,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$700,$ffff8242.w
	move	#$700,$ffff8244.w
	move	#$000,$ffff8246.w
	move	#$700,$ffff8248.w
	move	#$700,$ffff824a.w
	move	#$700,$ffff824c.w
	move	#$700,$ffff824e.w
	bsr	beep
	move	#50,d0
	bsr	waitvbl

	move	#$2700,sr
	bsr	clrpal

	lea	ecran,a1
	move	#300*40,d2
cop	clr.l	(a1)+
	dbra	d2,cop
	lea	ecran,a1
	lea	200*160(a1),a1
	lea	tsg,a0
	move	#40*37,d0
copy2	move.l	(a0)+,(a1)+
	dbf	d0,copy2
	lea	ecran,a1
	lea	logo+34,a0
	move	#40*199,d0
aff	move.l	(a0)+,(a1)+
	dbra	d0,aff

	ADD.L	#mus-$7d52,mus+$1AA
	ADD.L	#mus-$7d52,mus+$828
	ADD.L	#mus-$7d52,mus+$83C
	LEA	mus+$C3E,A0
	MOVE.L	#mus-$7D52,D0
	MOVEQ	#4-1,D1
homo2e:	ADD.L	D0,(A0)+
	DBRA	D1,homo2e

	moveq	#2,d0		* Numero de la zik ( 1 - 4 )
	JSR	mus
	jsr	mus+8
	move.l	#text,ptrtext
	clr	delir
	move.l	#vbl_ir,$70.w
	movem.l	logo+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move	#$2300,sr
bcl:
	clr	sync
	move.b	#10,$ffff8800.w
	MOVE.B	$FFFF8800.W,D0
	btst	#3,D0
	bne.s	.1
	move.l	#$0e0e0303,$ffff8800.w
	bra.s	.2
.1	move.l	#$0e0e0404,$ffff8800.w
.2
	move.b	#11,$ffff8800.w
	MOVE.B	$FFFF8800.W,D0
	btst	#3,D0
	bne.s	.3
	move	#$777,$ffff825c.w
	bra.s	.4
.3	move	#$444,$ffff825c.w
.4
	jsr	mus+4

	bsr	scroll
	bsr	refresh

.wvbl	tst	sync
	beq.s	.wvbl

	cmp.b	#$39,$fffffc02.w
	bne.s	bcl

	jsr	mus+12
;	illegal
;	jmp	$500.w			;retour au loader
	clr	-(sp)
	trap	#1

vbl_ir
	clr.b	$fffffa1b.w
	move.l	#ixion1,$120.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
firstvbl:addq	#1,sync
	rte

ixion1
	move	#$2700,sr
	CLR.B	$FFFFFA1B.W
	MOVE.L	D0,-(SP)
	PEA	(A0)
	LEA	$FFFF8209.W,A0
.1	MOVE.B	(A0),D0
	CMP.B	(A0),D0
	BEQ.S	.1
.2	move.b	(A0),d0
	cmp.b	(A0),d0
	bne.s	.2
	move.b	#0,$ffff820a.w
	dcb.w	28*3/4,$4e71
	move.b	#2,$ffff820a.w
	move.l	(sp)+,A0
	move.l	(sp)+,d0
	clr.b	$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte
scroll:
	lea	ecran+160*122,a2
	moveq	#30-1,d6
who
	move.b	1+160*0(a2),(a2)
	move.b	8+160*0(a2),1+160*0(a2)
	move.b	9+160*0(a2),8+160*0(a2)
	move.b	16+160*0(a2),9+160*0(a2)
	move.b	17+160*0(a2),16+160*0(a2)
	move.b	24+160*0(a2),17+160*0(a2)
	move.b	25+160*0(a2),24+160*0(a2)
	move.b	32(a2),25+160*0(a2)
	move.b	33(a2),32(a2)
	move.b	40+160*0(a2),33(a2)
	move.b	41+160*0(a2),40+160*0(a2)
	move.b	48+160*0(a2),41+160*0(a2)
	move.b	49+160*0(a2),48+160*0(a2)
	move.b	56+160*0(a2),49+160*0(a2)
	move.b	57+160*0(a2),56+160*0(a2)
	move.b	64+160*0(a2),57+160*0(a2)
	move.b	65+160*0(a2),64+160*0(a2)
	move.b	72+160*0(a2),65+160*0(a2)
	move.b	73+160*0(a2),72+160*0(a2)
	move.b	80+160*0(a2),73+160*0(a2)
	move.b	81(a2),80+160*0(a2)
	move.b	88(a2),81(a2)
	move.b	89+160*0(a2),88(a2)
	move.b	96+160*0(a2),89+160*0(a2)
	move.b	97+160*0(a2),96+160*0(a2)
	move.b	104+160*0(a2),97+160*0(a2)
	move.b	105+160*0(a2),104+160*0(a2)
	move.b	112+160*0(a2),105+160*0(a2)
	move.b	113+160*0(a2),112+160*0(a2)
	move.b	120+160*0(a2),113+160*0(a2)
	move.b	121+160*0(a2),120+160*0(a2)
	move.b	128+160*0(a2),121+160*0(a2)
	move.b	129+160*0(a2),128+160*0(a2)
	move.b	136(a2),129+160*0(a2)
	move.b	137(a2),136(a2)
	move.b	144(a2),137(a2)
	move.b	145(a2),144(a2)
	move.b	152(a2),145(a2)
	move.b	153(a2),152(a2)
	
	lea	160(a2),a2
	dbra	d6,who
	rts

refresh
	move.l	ptrtext,a6
	clr	d2
	move.b	(a6),d2
	cmp.b	#$ff,d2
	bne.s	.nul
	lea	text,a6
	move.b	(a6),d2
.nul
	sub	#32,d2
	mulu	#32*16/4,d2

	lea	buf,a3
	add	delir,a3
	addq	#1,delir
	and	#3,delir
	bne.s	.refresh
	addq	#1,a6
.refresh
	add.l	d2,a3
	lea	ecran,a5
x	set	0
	rept	30
	move.b	x*4(a3),160*122+152+1+x*160(a5)
x	set	x+1
	endr
	move.l	a6,ptrtext
	rts

clrpal:	moveq	#0,d0
	lea	$ffff8240.w,a0
	rept	8
	move.l	d0,(a0)+
	endr
	rts

waitvbl:clr	sync
.ww	cmp	sync,d0
	bne.s	.ww
	rts
newvblmcoder
	tst	count
	bne.s	.noclose
	move.l	#$08080000,$ffff8800.w
	move.l	#$0707ffff,$ffff8800.w
	bra.s	.close
.noclose
	subq	#1,count
.close
	addq	#1,sync
	rte
beep
	move.l	#$0000bfbf,$ffff8800.w
	move.l	#$01010101,$ffff8800.w
	move.l	#$08080f0f,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	move.l	#$0707fefe,$ffff8800.w
	move	#10,count
	rts
WAIT	MACRO
N3	SET	(\1-7)-((\1-7)/5)*5
BEST	SET	3
MIN	SET	N3		;RECORD A BATTRE

N2	SET	(\1-6)&3
	IFLE	N2-MIN
BEST	SET	2
MIN	SET	N2
	ENDC

N1	SET	(\1-5)-((\1-5)/3)*3
	IFLE	N1-MIN
BEST	SET	1
MIN	SET	N1
	ENDC

	IFEQ	BEST-1
	MOVEQ	#(\1-5)/3,\2
\@	DBRA	\2,\@
	IFNE	N1
	DCB.W	N1,$4E71
	ENDC
	ENDC

	IFEQ	BEST-2
	MOVEQ	#(\1-6)/4,\2
\@	NOP
	DBRA	\2,\@
	IFNE	N2
	DCB.W	N2,$4E71
	ENDC
	ENDC

	IFEQ	BEST-3
	MOVEQ	#(\1-7)/5,\2
\@	NOP
	NOP
	DBRA	\2,\@
	IFNE	N3
	DCB.W	N3,$4E71
	ENDC
	ENDC

	ENDM

compteurlignes
	MOVE	D0,-(SP)
	MOVE	#$59B-1-10,D0
.L3:	DBF	D0,.L3		;17244
	DCB.W	5,$4E71
	MOVE.B	#0,$FFFF820A.W
	WAIT	(10*12+32)/4,D0
	MOVE.B	#2,$FFFF820A.W
	CLR.B	$FFFFFA1B.W
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	move.l	#ADD1,$120.w
	CLR	NBLIG
	MOVE.B	#1,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1b.W
	MOVE	(SP)+,D0
	MOVE.L	#NEXTVBL,$70.W
	RTE
NEXTVBL:
	CLR.B	$FFFFFA1B.W
	ADDQ	#1,sync
	RTE
ADD1:	ADDQ	#1,NBLIG
	RTE
NBLIG:	DC.W	0

inter0:
	MOVE	#$59B-1-10,D2
L3:	DBF	D2,L3		;17244
	DCB.W	4,$4E71
	MOVEQ	#$10,D2
	MOVE.B	D0,(A2)
	WAIT	10*12/4,D3
	WAIT	32/4,D3
	MOVE.B	D1,(A2)
L4:	MOVE.B	(A0),D3
	BEQ.S	L4
	SUB.B	D3,D2
	LSL.B	D2,D3
	WAIT	(380-4)/4,D3
OLDSH1	MOVE	#$E2,D2
L5:
	NOP
	MOVE.B	D1,(A1)		;DEBUGGAGE STE !!!
	NOP
	MOVE.B	D0,(A1)
	WAIT	356/4,D3
	MOVE.B	D0,(A2)
	MOVE.B	D1,(A2)
	WAIT	52/4,D3
	MOVE.B	D1,(A1)
	NOP
	MOVE.B	D0,(A1)
	WAIT	(36-4)/4,D3
	DBF	D2,L5

	MOVE.B	D1,(A1)
	NOP
	MOVE.B	D0,(A1)
	WAIT	356/4,D3
	MOVE.B	D0,(A2)
	MOVE.B	D1,(A2)
	WAIT	52/4,D3
	MOVE.B	D1,(A1)
	NOP
	MOVE.B	D0,(A1)
	MOVE.B	D0,(A2)		;8
	WAIT	28/4,D3		;28
OLDSH2	MOVE	#$2C,D2		;8
	MOVE.B	D1,(A2)		;8
L6:	MOVE.B	D1,(A1)
	MOVE.B	D0,(A1)
	WAIT	356/4,D3
	MOVE.B	D0,(A2)
	MOVE.B	D1,(A2)
	WAIT	52/4,D3
	MOVE.B	D1,(A1)
	NOP
	MOVE.B	D0,(A1)
	WAIT	40/4,D3
	DBF	D2,L6
	addq	#1,sync
	RTE
pal:	dc.w	$000,$346,$135,$556
	dc.w	$246,$300,$456,$100
	dc.w	$025,$410,$532,$543
	dc.w	$200,$014,$432,$760
text
	DC.B	"      HELLO !!!    SKYRACE FROM HEMOROIDS ISN'T PROUD"
	dc.b	" TO PRESENT HIS VERY LAME INTRO AT THE CODING-PARTY"
	dc.b	" ORGANISED BY THE SERGEANT. IT'S 5H40 IN THE MORNING"
	dc.b	" AND WE ARE VERY TIRED. THE CREW WHO ARE AT THE"
	dc.b	" CODING-PARTY ARE : FUZION,"
	DC.B	" MAD-VISION, PENDRAGONS, OVERLANDERS, EQUINOX, PHENIX,"
	dc.b	" THE BLACK CATS AND THE BUSHWACKERS. STRANGLERS (TSG)"
	dc.b	" IS AN ALLIANCE COMPOSED OF HEMOROIDS AND FUZION. CREDITS"
	dc.b	" : BAD CODING BY SKYRACE AND GRAFIX BY WOODY."
	DC.B	" HEMOROIDS MEMBERS ARE : CKAOS, SKYRACE, GLUEV, PARANOIDS,"
	dc.b	" SINK, SKYHAWK, DOCTOR BIT, WOODY. AND FUZION'S MEMBERS ARE :"
	dc.b	" THE DRAGON, FULCRUM, DOCNO, DARKLIGHT, ORION, SPEEDER,"
	dc.b	" SQUAT."
	DC.B	" WE SEND OUR BEST REGARDS TO : THE EMPIRE (V8), PENDRAGONS,"
	dc.b	" OVERLANDERS, FUZION, PHENIX, MAD-VISION, FUTURE MINDS,"
	dc.b	" FIRE-CRACKERS, ST CONNEXION, EQUINOX, SOFTTRACKS, IMPACT,"
	dc.b	" NEXT, MCODER, RICK, PLAY, JOYDEATH,"
	DC.B	" CHED, THE BLACK CATS, ALGERNON, ERENDIL, BLOODY OF OCG,"
	dc.b	" X-RAY AND ALL THE OTHERS I HAVE FORGOTTEN AND NOW A"
	dc.b	" GIGA-MEGA-FUCKING TO JERRY OF OCG, THE BIGGEST LAMER"
	dc.b	" ON THE ST !!! AND NOW I MUST LEAVE YOU.... BYE.... BYE...."
	DC.B	" CONTACT US ON RTEL BAL : SKYRACE, HEMOROIDS, GLUEV,"
	dc.b	" PARANOIDS, SINK, SKYHAWK ...... BYE ......"
 	DC.B	$FF
	even	
	IFEQ	TEST
mus:
fullscr:incbin	B:full.scr
ecran2:
imager
buf:
logo:
tsg:
	ELSEIF
mus:	incbin	B:\BUG\chamber2.mus
fullscr:incbin	B:full.scr
ecran2:	incbin	B:\BUG\no.blk
imager	incbin	B:\BUG\kuartz.pi1
buf:	incbin	B:\BUG\NEWFONTE.bin
logo:	incbin	B:\BUG\pic.pi1
tsg:	incbin	B:\BUG\tsg.blk
	ENDC

;debugger:incbin	debugger.bin
count:	dc.w	0
sync:	dc.w	0
ptrtext:dc.l	0
delir	dc.w	0

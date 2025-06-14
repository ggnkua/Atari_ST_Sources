		opt c+,d-,o+
		opt	W-
		ttl	"LSD DEPACKER V2.0"

;SET TABS TO 10 FOR DISASSEMBLY
		move.l 	$4(a7),a5	;return memory to gem
		move.l 	#$100,-(a7)
		move.l 	a5,-(a7)
s8800		move.l 	#$4a0000,-(a7)
		trap 	#1
xa01		dc.w 	$a00a		;pointer off
s134		clr.l	-(a7)		;supervisor mode on
		move.w	#$20,-(a7)
		trap 	#1
		move.l 	d0,savesp
		pea 	moff		;mouse off
		move.l 	#$190001,-(a7)
		trap 	#14
main		move.l	#$80000,a7
		clr.w 	-(sp)		;set screen
		pea 	$78000
		move.l 	(a7),-(a7)
		move.w 	#5,-(a7)
		trap 	#14
		move.l	#$80000,a7
		lea	$ff8240,a0	;save default palette
		moveq.l	#7,d0
		lea	$1000,a1
scol		move.l	(a0)+,(a1)+
		dbf	d0,scol
		clr.b	$484		;keyboard click off
		
picture		lea 	$5ffde,a1	
		lea	DATA1,a0
		move.w	#$7d22,d0
		bsr	copyup
		lea	$5ffe0,a0	;insert picture palette
		lea	$ffff8240,a1
		move.w	#$7,d0
coloop		move.l	(a0)+,(a1)+
		dbf	d0,coloop

FONT		lea	$57fde,a1	;depack font
		lea	DATA2,a0
		move.w	#$7d22,d0
		BSR	copyup

music_on		lea	$140AC,a1	;depack music
		lea	music,a0
		move.w	#(nomore-music),d0
		BSR	copyup
		move.l	#$15b7c,a0
clrloop		clr.b	(a0)+
		cmp.l	#$20000,a0
		bne.s	clrloop	
		MOVE.L	#VBL,$4da	;put music on vbl
		MOVE.W	#$0,D0		;start music
		JSR	$1462a
		
FIZZ		lea	$67e00,a5	;RANDOM BUFFER
		lea	$60000,a4	;SOURCE PICTURE
		lea	$78000,a3	;DESTINATION
		BSR.S	FIZZMAIN
		BRA	enda
		

FIZZMAIN		MOVE.W	#$C7,D7
RALOOP		MOVE.W	#$11,-(A7)
		TRAP	#14
		ADDQ.L	#2,A7
		ANDI.W	#$1F,D0
		MOVE.B	D0,(A5)+
		DBF	D7,RALOOP
FIZZ1		LEA	-$C8(A5),A5
		CLR.W	D7
		MOVE.W	#$63,D6
FIZZ1a		SUBQ.B	#1,(A5)+
		BPL	FIZZ4
		MOVE.B	-1(A5),D0
		EXT.W	D0
		ADDI.W	#$14,D0
		BPL.S	FIZZ2
		ADDQ.W	#1,D7
		ADDQ.B	#1,-1(A5)
		BRA.S	FIZZ4
FIZZ2		ASL.W	#3,D0
		LEA	0(A4,D0.W),A0
		LEA	$98(A3),A1
		MOVE.W	#$12,D0
FIZZ3		MOVE.L	-4(A1),4(A1)
		MOVE.L	-8(A1),(A1)
		LEA	-8(A1),A1
		DBF	D0,FIZZ3
		MOVE.L	4(A0),4(A1)
		MOVE.L	(A0),(A1)
FIZZ4		LEA	$A0(A3),A3
		LEA	$A0(A4),A4
		SUBQ.B	#1,(A5)+
		BPL	FIZZ5
		MOVE.B	-1(A5),D0
		EXT.W	D0
		NOT.W	D0
		CMP.W	#$14,D0
		BNE.S	FIZZ6
		ADDQ.W	#1,D7
		ADDQ.B	#1,-1(A5)
		BRA.S	FIZZ5
FIZZ6		ASL.W	#3,D0
		LEA	0(A4,D0.W),A0
		LEA	(A3),A1
		MOVE.W	#$12,D0
FIZZ7		MOVE.L	8(A1),(A1)
		MOVE.L	$C(A1),4(A1)
		LEA	8(A1),A1
		DBF	D0,FIZZ7
		MOVE.L	(A0),(A1)
		MOVE.L	4(A0),4(A1)
FIZZ5		LEA	$A0(A3),A3
		LEA	$A0(A4),A4
		DBF	D6,FIZZ1a
		LEA	-$7D00(A3),A3
		LEA	-$7D00(A4),A4
		CMP.W	#$C8,D7
		BNE	FIZZ1
		RTS

VBL		MOVEM.L	D0-D7/A0-A6,-(A7)
		JSR	$14638
		MOVEM.L	(A7)+,D0-D7/A0-A6
		RTS
	
vflag		dc.b	0

enda		move.l	$118,save118	;save keyboard interupt
		move.l	#keyget,$118	;new key fetch routine
		bra.s	ALLDONE
keyget		move.l	d0,-(sp)	;keyboard routine
		move.b	$fffc02,d0
		cmp.b	#$b,d0
		bgt.s	noway
		bne.s	nohz
		eor.b	#2,$ff820a
nohz		move.b	d0,keyval
noway		move.l	(a7)+,d0
		dc.w 	$4ef9
save118		dc.l	0
keyval		dc.w	$ffff

;  scroller from here
ALLDONE		LEA	TEXT(PC),A0
		LEA	$50000,A1
		LEA	$78000+($a0*158),A2
L10		tst.b 	$257ad
		bne.s 	l10a
		move.b 	#2,$24cc4
l10a		move.b 	keyval,d0
		cmp.b 	#$b,d0
		bne.s 	nthz
		move.b 	#$ff,keyval
		bra 	co
nthz		cmp.b 	#$6,d0
		bcc 	co
		bra	noquit

clrsnd		move.w	#$2700,sr		;interupts off
		move.l	save118,$118	;replace keyboard ints
		CLR.L	$4DA
		move.l	#$8080000,$ff8800	;clear sound channels
		move.l	#$9090000,$ff8800
		move.l	#$a0a0000,$ff8800
		pea	mon		;start mouse
		move.l	#$190001,-(sp)
		trap	#14
		addq.l	#8,sp
		move.w	#$2300,sr		;interupts on
		move.w	#$0,-(a7)		;set screen
		move.l	#$78000,-(a7)
		move.l	#$78000,-(a7)
		move.w	#$5,-(a7)
		trap	#14
		add.l	#$c,a7
		rts

moff		dc.w 	$1a12
mon		dc.w 	$1408
sd0		dc.w 	0
savesp		dc.l	0

noquit		lea 	g1(pc),a0
		subq.b	#$2,d0
		move.w	d0,sd0
td0		cmp.b	#0,d0
		beq	load
		add.l	#$d,a0
		subq.b	#1,d0
		bra.s	td0
co		moveq.l	#0,d0
nex		MOVE.B	(A0)+,D0
		BEQ	ALLDONE
		bpl.s	GOON2
		cmp.b	#$fe,d0
		beq.s	nfe1
		bra.s	nfe
nfe1		moveq.l	#$8,d5
		move.l	a0,-(sp)
llpp		moveq.l #$20,d0
		bsr.s	GOON
		dbf	d5,llpp
		move.l	(a7)+,a0
		bra.s	co
nfe		MOVE.W	#$FFFF,D0
ILOOP		MOVE.W	#$20,D1
OLOOP		DBF	D1,OLOOP
		cmp.b	#$2,keyval
		bcs	l10r
		cmp.b	#$c,keyval
		bcs	L10
l10r		DBF	D0,ILOOP
		BRA	L10
GOON2		bsr.s	GOON
		bra	L10
GOON		MOVEM.L	A0-A2,-(A7)
		BSR	L6
		MOVEQ	#7,D7
		movem.l	(a7)+,a0-a2
L4		move.w	#$a00,d0
.loop		dbf	d0,.loop
		BSR.S	L5
		BSR.S	L5
		movem.l	d0-d7/a0-a6,-(a7)
		move.w	#$25,-(a7)
		trap	#14
		addq.l	#2,a7
		movem.l	(a7)+,d0-d7/a0-a6
		dbf	d7,L4
		rts
		
		
L5		MOVEM.L	A1-A3,-(A7)
		MOVEQ	#15,D0
L11		MOVEQ	#3,D1
L7		LSL	(A1)
		ROXL	$68(A2)
		ROXL	$60(A2)
		ROXL	$58(A2)
		ROXL	$50(A2)
		ROXL	$48(A2)
		ROXL	$40(A2)
		ROXL	$38(A2)
		ROXL	$30(A2)
		ROXL	$28(A2)
		ROXL	$20(A2)
		ROXL	$18(A2)
		ROXL	$10(A2)
		ROXL	$8(A2)
		ROXL	(A2)
		ADDQ.L	#2,A1
		ADDQ.L	#2,A2
		DBF	D1,L7
		LEA	$98(A1),A1
		LEA	$98(A2),A2
		DBF	D0,L11
		MOVEM.L	(A7)+,A1-A3
		RTS


L6		MOVEM.L	D0-D2/A0-A1,-(A7)	;get char position
		sub.w	#$20,d0
		clr.l	d1
		move.w	d0,d1
		and.w	#$f,d0
		and.w	#$f0,d1
		lsl.w	#3,d0
		move.w	d1,d2
		lsl.w	#5,d1
		lsl.w	#7,d2
		add	d2,d1
		add.w	d0,d1
		move.l	#$58000,a0
		add.l	d1,a0
		lea	$50000,a1
		moveq.l	#15,d0
pl1		movem.l	(a0),d1-d2
		movem.l	d1-d2,(a1)
		lea	$a0(a0),a0
		lea	$a0(a1),a1
		dbf	d0,pl1
		movem.l	(sp)+,d0-d2/a0-a1
		rts
		
;    end of scroller
TEXT		DC.B	$60,$61,$62,$63,$64,$65,$66,$67,$68,"  DISK 70        "
		DC.B	"DEDICATED TO THOSE WONDERFUL PEOPLE AT ",$69,$6A
		DC.B	"        IF YOU DON'T READ THIS FINE MAG, YOU ARE BORINGGGGG!    "
		DC.B	"COMPLAINTS DIVISION - WE HAVE HAD SOME COMPLAINTS ABOUT US RELEASING "
		DC.B	"2 DISK 69'S        WELL TOUGH, WE THOUGHT IT WAS A GOOD IDEA "
		DC.B	"AND STILL DO, WHO WANTS TO FOLLOW CONVENTIONS, NOT US!          "
		DC.B	"TO THOSE WHO THINK THAT IT IS AGAINST THE 'RULES' TO BREAK "
		DC.B	"THE 1,2,3..  CONVENTION       WELL, SOFTWARE PIRACY IS ILLEGAL "
		DC.B	"AND WE ARE ALL DOING IT!(HOW ELSE HAVE YOU GOT THIS DISK!)         "
		DC.B	"          YET AGAIN THE 'AUTOMATION SELL SOFTWARE' GANG "
		DC.B	"HAVE REARED THERE UGLY HEADS, WELL IF WE WERE SELLING SOFTWARE, "
		DC.B	"BY NOW WE WOULD HAVE MADE A WAD OF MONEY AND WOULD NOT BE SCRIMPING "
		DC.B	"ROUND FOR BLANK DISKS, SO,  (SWEAR WORD COMING UP),           "
		DC.B	"WE DON'T SELL SOFTWARE, SO GO GET FUCKED!!                       "
		DC.B	"   SWEAR WORDS!(WELL IT IS A ",$69,$6A," MENU                     "
		DC.B	0


****************************************

copyup		move.b	(a0)+,(a1)+
		dbf	d0,copyup
		rts
		
load		move.l	a0,fadd+2
		move.l	#$77ff0,a7
		bsr	clrsnd
		move.l	savesp,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.w 	sd0,d0
tt1		nop
tt2		cmp.b 	#0,d0		;MENU CHOICE 1?
		bne.s 	tt3
		lea 	fold1(pc),a0
		bra.s	openfol
tt3		cmp.b	#1,d0		;MENU CHOICE 2?
		bne.s	tt4
		lea	fold2(pc),a0
		bra.s	openfol
tt4		cmp.b	#2,d0
		bne.s	tt5
		lea	fold3(pc),a0
openfol		move.l	a0,-(sp)
		move.w	#$3b,-(sp)
		trap	#1
tt5		move.l	#$60000,a4		;clear screen
clrloop2		clr.b	(a4)+
		cmp.l	#$67e00,a4
		bne.s	clrloop2
		lea	$67e00,a5	;RANDOM BUFFER
		lea	$60000,a4	;SOURCE PICTURE
		lea	$78000,a3	;DESTINATION
		BSR	FIZZMAIN

		clr.l	$60000
		clr.w	-(sp)
		pea	$60000
		pea	$60000
fadd		move.l	#$ffffffff,-(sp)
		move.l	#$4b0000,-(sp)
		trap	#1

fold1		dc.b	"\BALISTIX\",0
fold2		dc.b 	"\REALGHST\",0
fold3		dc.b	"\WARLOCK\",0
g1		dc.b	"BALISTIX.LSD",0	;MUST BE 13 BYTES
g2		dc.b 	"START.LSD",0,0,0,0
g3		dc.b	"QUEST.LSD",0,0,0,0
g4		dc.b	"INFO.AUT",0
		even
		
DATA2		INCBIN	"FONT_70.PI1"
DATA1		INCBIN	"MENU_70.PI1"
music		INCBIN	"140AC.RAW"
nomore
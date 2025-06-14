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
		pea 	$70000
		move.l 	(a7),-(a7)
		move.w 	#5,-(a7)
		trap 	#14
		move.l	#$80000,a7
		lea	$ff8240,a0	;save default palette
		moveq.l	#7,d0
		lea	$1dfc0,a1
scol		move.l	(a0)+,(a1)+
		dbf	d0,scol
		clr.b	$484		;keyboard click off
		lea 	$5ffde,a1		;depack picture
		lea	l_020,a0
		move.w	#$7d21,d0
		bsr 	copy
		lea	$5ffe0,a0	;insert picture palette
		lea	$ffff8240,a1
		move.w	#$7,d0
coloop		move.l	(a0)+,(a1)+
		dbf	d0,coloop
		lea	$57fde,a1		;depack font
		lea	l_030,a0
		move.w	#$7d21,d0
		BSR	copy
		lea	$20000,a1	;depack music
		lea	music,a0
		move.w	#$1000,d0
		BSR	copy
		MOVE.L	#VBL,$4d2		;put music on vbl
		MOVE.W	#$1,D0		;start music
		JSR	$20000
		move.l	#$fffa00,a0
		movep.w	$7(a0),d0
		move.w	d0,olda07
		movep.w	$13(a0),d0
		move.w	d0,olda13
		
FIZZ		lea	$67e00,a5	;RANDOM BUFFER
		lea	$60000,a4	;SOURCE PICTURE
		lea	$70000,a3	;DESTINATION
		BSR.S	FIZZMAIN
		BRA	enda
		
savesp		dc.l	0
sd0		dc.l	0
olda07		dc.w	0
olda13		dc.w	0
SEMA		DC.L	0
moff		dc.w	$1a12
mon		dc.w	$1408
hzflg		dc.b	$ff

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
		JSR	$2000E
		clr.b	$fffa1b
		move.l	#hblank,$120
		move.b	#$c6,$fffa21
		move.b	#$8,$fffa1b
		MOVEM.L	(A7)+,D0-D7/A0-A6
		RTS
	
hblank		CLR.B	$FFFA1B
		BCLR	#0,$FFFA0F
		MOVE.W	#$2200,SR
		MOVE.L	#SERVICE.TWO,$120
		MOVE.B	#1,$FFFA21
		MOVE.B	#8,$FFFA1B
		ST	SEMA
NOSE		TST.B	SEMA
		BNE.S	NOSE
		RTE
		
SERVICE.TWO	CLR.B	$FFFA1B
		MOVE.L	D0,-(A7)
		MOVE.W	#$26,D0
hloop1		DBF	D0,hloop1
		move.b	#$0,$ff820a
		MOVE.W	#1,D0
hloop2		DBF	D0,hloop2
		MOVE.B	#2,$FF820A
		SF	SEMA
		MOVE.L	#SERVICE.THREE,$120
		MOVE.B	#8,$FFFA1B
		BCLR	#0,$FFFA0F
		MOVE.L	(A7)+,D0
		RTE
		
SERVICE.THREE	CLR.B	$FFFA1B
		MOVEM.L	D0/A0,-(A7)
		BCLR	#0,$FFFA0F
		MOVE.B	#8,$FFFA1B
		MOVEM.L	(A7)+,D0/A0
		RTE

enda		move.l	#$fffa00,a0
		move.w	#$140,d0
		movep.w	d0,$07(a0)
		movep.w	d0,$13(a0)
;  scroller from here
ALLDONE		LEA	TEXT(PC),A0
		LEA	$50000,A1
		LEA	($77d00+($a0*5)),A2
L10		tst.b	$257ad
		bne.s	l10a
		move.b	#2,$24cc4
l10a		move.w	#$ff,-(a7)
		move.w	#$6,-(a7)
		trap	#$01
		addq.l	#4,a7
		sub.b	#$30,d0
		move.w	d0,sd0
		cmp.b	#$0,d0
		bne.s	nthz
		eor.w	#$111,$ff8240
		eor.b	#1,hzflg
		bra	co
nthz		cmp.b	#$1,d0
		blt	co
		cmp.b	#$3,d0
		beq.s	quit
		cmp.b	#$6,d0
		beq.s	quit
		cmp.b	#$6,d0
		bgt	co
		bra	load
		
quit		lea	$1dfc0,a0
		lea	$ff8240,a1
		moveq.l	#7,d0
q1		move.l	(a0)+,(a1)+
		dbf	d0,q1
		move.l	#$77f00,a7
		bsr 	clrsnd
		clr.w 	-(sp)
		trap 	#1


clrsnd		move.w	#$2700,sr
		clr.l	$4d2
		move.l	#$8080000,$ff8800
		move.l	#$9090000,$ff8800
		move.l	#$a0a0000,$ff8800
		move.l	#$fffa00,a0
		move.w	olda07,d0
		movep.w	d0,$7(a0)
		move.w	olda13,d0
		movep.w	d0,$13(a0)
		cmp.b	#$fe,hzflg
		bne.s	hz50
		eori.b	#$2,$ff820a
hz50		pea	mon
		move.l	#$190001,-(sp)
		trap	#14
		addq.l	#8,sp
		move.w	#$2300,sr
		move.w	#$0,-(a7)
		move.l	#$78000,-(a7)
		move.l	#$78000,-(a7)
		move.w	#$5,-(a7)
		trap	#14
		add.l	#$c,a7
		rts
		
co		moveq.l	#0,d0
nex		MOVE.B	(A0)+,D0
		BEQ	ALLDONE
		bpl.s GOON2
		cmp.b #$fe,d0
		beq.s nfe1
		bra.s nfe
nfe1		moveq.l #$8,d5
		move.l a0,-(sp)
llpp		moveq.l #$20,d0
		bsr.s GOON
		dbf d5,llpp
		move.l (a7)+,a0
		bra.s co
nfe		MOVE.W	#$FFFF,D0
ILOOP		MOVE.W	#$20,D1
OLOOP		DBF	D1,OLOOP
l10r		DBF	D0,ILOOP
		BRA	L10
GOON2		bsr.s GOON
		bra L10
GOON		MOVEM.L	A0-A2,-(A7)
		BSR	L6
		MOVEQ	#7,D7
		movem.l	(a7)+,a0-a2
L4		movem.l d0-d7/a0-a1,-(sp)
		move.w #$25,-(sp)
		trap #14
		addq.l #2,sp
		movem.l (sp)+,d0-d7/a0-a1
		BSR.S	L5
		BSR.S	L5
		dbf d7,L4
		rts	
L5		MOVEM.L	A1-A2,-(A7)
		MOVEQ	#15,D0
L11		MOVEQ	#3,D1
L7		LSL	(A1)
		ROXL	$98(A2)
		ROXL	$90(A2)
		ROXL	$88(A2)
		ROXL	$80(A2)
		ROXL	$78(A2)
		ROXL	$70(A2)
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
		MOVEM.L	(A7)+,A1-A2
		RTS



L6		MOVEM.L	D0-D2/A0-A1,-(A7)	;get char position
		clr.l	d1
		sub.w	#$20,d0
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
		moveq.l #15,d0
pl1		movem.l (a0),d1-d2
		movem.l d1-d2,(a1)
		lea $a0(a0),a0
		lea $a0(a1),a1
		dbf d0,pl1
		movem.l (sp)+,d0-d2/a0-a1
		rts
		
;    end of scroller
TEXT		DC.B	"THIS IS DISK 51   -   ISSUE 2                 "
		DC.B	"EH!!!         YES INDEED WE DECIDED TO REISSUE THIS DISK, "
		DC.B	"WHY?         WELL WITH OUR NEW PACKER WE CAN CRAM EVEN MORE ONTO A DISK "
		DC.B	"   SO YOU NOW HAVE 2 OTHER GAMES AS WELL AS THE FIRST FOUR (NOTE... "
		DC.B	"PETER BEARDSLEY FOOTBALL IS NOW 100 PERCENT!)         SO ALL YOU HAVE TO DO "
		DC.B	"IS COPY THIS OVER YOUR OLD 51, NOT ONLY DO WE PACK MORE STUFF THAN ANY "
		DC.B	"ONE ELSE, BUT WE MAINTAIN OUR COLLECTION, BOTH FIXING FAULTS AND GETTING "
		DC.B	"EVEN MORE ONTO A DISK                 WELL, I SUPPOSE YOU ARE ALL WAITING "
		DC.B	"FOR OUR 'BORING REALLY' GREETINGS                THIS TIME TO      HAL (WHERE'S BATMAN?), "
		DC.B	"THE PRESIDENT(HOT SWAPS!), REPLICANTS(ACE HACKS), MCA(NICE HACKS), "
		DC.B	"BBC(NICE 1 MEG FILES), KEN + MAC-MAN, SERVO, TURNIP AND ALL IN LEEDS!!!                          HERE WE GO AGAIN"                   
		DC.B	0


****************************************

copy		move.b	(a0)+,(a1)+
		dbf	d0,copy
		rts

load		lea	g1,a0
loadnex		cmp.b	#$1,d0
		beq.s	goload
		subq.l	#$1,d0
		add.l	#$d,a0
		bra.s	loadnex
goload		move.l	a0,fadd+2
		move.l	#$77ff0,a7
		bsr	clrsnd
		move.l	savesp,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.w 	sd0,d0
tt1		nop
tt4		clr.l	$60000
		clr.w	-(sp)
		pea	$60000
		pea	$60000
fadd		move.l	#$ffffffff,-(sp)
		move.l	#$4b0000,-(sp)
		trap	#1

g1		dc.b	"PB_FBALL.LAW",0	;MUST BE 13 BYTES
g2		dc.b 	"IMPACK.JEK",0,0,0
g3		dc.b	"PROHIBIT.PRG",0
g4		dc.b	"TAUCETI.JEK",0,0
g5		dc.b	"IBALL.JEK",0
		even
		
l_030		INCBIN	"FONT51.DAT"
l_020		INCBIN	"MENU51.pi1"
music		INCBIN	"MUS.DAT"

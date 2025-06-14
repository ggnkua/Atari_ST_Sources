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
		lea	$1dfc0,a1
scol		move.l	(a0)+,(a1)+
		dbf	d0,scol
		clr.b	$484		;keyboard click off
		lea	$20000,a1	;depack music
		lea	music(pc),a0
		BSR	depack
		move.l	$70,save70	;save vbl
		MOVE.L	#VBL,$70	;put music on vbl
		MOVE.W	#$3,D0		;start music
		JSR	$20000
		lea 	$5ffde,a1	;depack picture
		lea	l_020(pc),a0
		bsr 	depack
		lea	$5ffe0,a0	;insert picture palette
		lea	$ffff8240,a1
		move.w	#$7,d0
coloop		move.l	(a0)+,(a1)+
		dbf	d0,coloop
		
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
		JSR	$2000E
		MOVEM.L	(A7)+,D0-D7/A0-A6
		move.b	#$ff,vflag
		RTE
	
vflag		dc.b	0

enda		move.l	$118,save118	;save keyboard interupt
		move.l	#keyget,$118	;new key fetch routine
		bra.s	superon
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
superon		lea	$57fde,a1	;depack font
		lea	l_030,a0
		BSR	depack
;  scroller from here
ALLDONE		LEA	TEXT(PC),A0
		LEA	$50000,A1
		LEA	$78000+($a0*184),A2
L10		tst.b 	$257ad
		bne.s 	l10a
		move.b 	#2,$24cc4
l10a		move.b 	keyval,d0
		cmp.b 	#$b,d0
		bne.s 	nthz
		move.b 	#$ff,keyval
		bra 	co
		cmp.b	#$3,d0
		beq.s	quit
nthz		cmp.b 	#$4,d0
		bcc 	co
		bra	noquit
quit		lea	$1dfc0,a0			;replace default palette
		lea	$ff8240,a1
		moveq.l	#7,d0
q1		move.l	(a0)+,(a1)+
		dbf	d0,q1
		move.l	#$77f00,a7
		bsr 	clrsnd
		clr.w 	-(sp)			;exit to gem
		trap 	#1

clrsnd		move.w	#$2700,sr		;interupts off
		move.l	save70,$70		;replace vbl
		move.l	save118,$118		;replace keyboard ints
		move.l	#$8080000,$ff8800	;clear sound channels
		move.l	#$9090000,$ff8800
		move.l	#$a0a0000,$ff8800
		pea	mon			;start mouse
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
save70		dc.l	0
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
vbltest2		cmp.b	#$ff,vflag
		bne.s	vbltest2
		clr.b	vflag
		dbf	d7,L4
		rts
		
		
L5		MOVEM.L	A1-A3,-(A7)
		MOVE.L	#($78000+(15*$A0)),A3
		MOVEQ	#15,D0
L11		MOVEQ	#3,D1
L7		MOVE.L	(A1),D3
		LSL	(A1)
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
		LSL.L	D3
		ROXR	(A3)
		ROXR	$8(A3)
		ROXR	$10(A3)
		ROXR	$18(A3)
		ROXR	$20(A3)
		ROXR	$28(A3)
		ROXR	$30(A3)
		ROXR	$38(A3)
		ROXR	$40(A3)
		ROXR	$48(A3)
		ROXR	$50(A3)
		ROXR	$58(A3)
		ROXR	$60(A3)
		ROXR	$68(A3)
		ROXR	$70(A3)
		ROXR	$78(A3)
		ROXR	$80(A3)
		ROXR	$88(A3)
		ROXR	$90(A3)
		ROXR	$98(A3)
		ADDQ.L	#2,A1
		ADDQ.L	#2,A2
		ADDQ.L	#2,A3
		DBF	D1,L7
		LEA	$98(A1),A1
		LEA	$98(A2),A2
		LEA	-$A8(A3),A3
		DBF	D0,L11
		MOVEM.L	(A7)+,A1-A3
		RTS


L6		MOVEM.L	D0-D2/A0-A1,-(A7)	;get char position
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
TEXT		DC.B	"YES ITS DISK 69 - PART 2           WHAT!!!       "
		DC.B	"WHY HAVE WE RELEASED A SECOND DISK 69, WELL NO REASON "
		DC.B	"REALLY, BUT WE THOUGHT IT MIGHT CONFUSE PEOPLE A BIT "
		DC.B	"AND TOTALLY KNACKER ALL THOSE PEOPLE WHO KEEP THERE "
		DC.B	"DISKS IN NICE LITTLE BOXES WITH DIVIDERS, FIT THIS ONE IN GUYS!       "
		DC.B	"      ANYWAY. WE THOUGHT 1,2,3 ETC...   WAS GETTING REALLY BORING, "
		DC.B	"SO THIS IS THE END RESULT, HA HA!!        ANYWAY TIME TO SAY A FEW "
		DC.B	"          NO I DON'T THINK I WILL BOTHER, GREETINGS ARE BORING, SO THATS "
		DC.B	"YOUR LOT, GO AWAY         WAS(NOT WAS) IS GOING TO HATE US FOR DOING THIS      "
		DC.B	"          COME ON WAS, STOP COMPLAINING ABOUT US MESSING ABOUT, SO WE FOLLOWED DISK "
		DC.B	"66 WITH DISK 84, THAT CAUGHT A LOT OF PEOPLE OUT, BET THIS ONE DOES TOO!!                      "                   
		DC.B	0


****************************************


depack		ADDQ.L	#$4,A0
		MOVE.L	A0,A4
		MOVE.L	(A0)+,D5
		ADDA.L	D5,A1
		ADDA.L	(A0),A0
		SUBA.L	#4,A0
		TST.W	-(A0)
		BPL.S	L_1
		SUBQ.L	#1,A0
L_1		MOVE.B	-(A0),D0
L_2		LSL.B	#1,D0
		BNE.S	L_3
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_3		BCC.S	L_10
		CLR.W	D1
		LSL.B	#1,D0
		BNE.S	L_4
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_4		BCC.S	L_9
		LEA	NUMS(PC),A3
		MOVEQ	#3,D3
L_5		CLR.W	D1
		MOVE.B	0(A3,D3.W),D2
		EXT.W	D2
		MOVEQ	#-1,D4
		LSL.W	D2,D4
		NOT.W	D4
		SUBQ.W	#1,D2
L_6		LSL.B	#1,D0
		BNE.S	L_7
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_7		ROXL.W	#1,D1
		DBF	D2,L_6
		TST.W	D3
		BEQ.S	L_8
		CMP.W	D1,D4
		DBNE	D3,L_5
L_8		MOVE.B	4(A3,D3.W),D2
		EXT.W	D2
		ADD.W	D2,D1
		BRA	L_9

NUMS		DC.B	$0A,$03,$02,$02,$0E,$07,$04,$01

L_9		MOVE.B	-(A0),-(A1)
		DBF	D1,L_9
L_10		MOVE.L	A4,A3
		ADDQ.L	#$8,A3
		CMPA.L	A3,A0
		BLE	BYENOW
		LEA	NUMS2(PC),A3
		MOVEQ	#3,D2
L_11		LSL.B	#1,D0
		BNE.S	L_12
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_12		BCC.S	L_13
		DBF	D2,L_11
L_13		CLR.W	D1
		ADDQ.W	#1,D2
		MOVE.B	0(A3,D2.W),D3
		BEQ.S	L_16
		EXT.W	D3
		SUBQ.W	#1,D3
L_14		LSL.B	#1,D0
		BNE.S	L_15
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_15		ROXL.W	#1,D1
		DBF	D3,L_14
L_16		MOVE.B	5(A3,D2.W),D3
		EXT.W	D3
		ADD.W	D3,D1
		BRA	L_161

NUMS2		DC.B	$0A,$02,$01,$00,$00,$0A,$06,$04,$03,$02

L_161		CMPI.W	#2,D1
		BEQ.S	L_22
		LEA	NUMS3(PC),A3
		MOVEQ	#1,D3
L_17		LSL.B	#1,D0
		BNE.S	L_18
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_18		BCC.S	L_19
		DBF	D3,L_17
L_19		ADDQ.W	#1,D3
		CLR.W	D2
		MOVE.B	0(A3,D3.W),D4
		EXT.W	D4
L_20		LSL.B	#1,D0
		BNE.S	L_21
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_21		ROXL.W	#1,D2
		DBF	D4,L_20
		LSL.W	#1,D3
		ADD.W	4(A3,D3.W),D2
		BRA.S	L_26

NUMS3		DC.B	$0B,$04,$07,$00,$01,$20,$00,$00
		DC.B	$00,$20,$00,$00

L_22		CLR.W	D2
		MOVEQ	#5,D3
		CLR.W	D4
		LSL.b	#1,D0
		BNE.S	L_23
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_23		BCC.S	L_24
		MOVEQ	#8,D3
		MOVEQ	#$40,D4
L_24		LSL.B	#1,D0
		BNE.S	L_25
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_25		ROXL.W	#1,D2
		DBF	D3,L_24
		ADD.W	D4,D2
L_26		LEA	0(A1,D2.W),A2
		EXT.L	D1
		ADDA.L	D1,A2
		SUBQ.W	#1,D1
L_27		MOVE.B	-(A2),-(A1)
		DBF	D1,L_27
		BRA	L_2
BYENOW		RTS


load		move.l	a0,fadd+2
		move.l	#$77ff0,a7
		bsr	clrsnd
		move.w	$fc0018,$1000
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
openfol		move.l	a0,-(sp)
		move.w	#$3b,-(sp)
		trap	#1
tt4		clr.l	$60000
		clr.w	-(sp)
		pea	$60000
		pea	$60000
fadd		move.l	#$ffffffff,-(sp)
		move.l	#$4b0000,-(sp)
		trap	#1

fold1		dc.b	"\BARB2\",0
fold2		dc.b 	"\LASTDUEL\",0
g1		dc.b	"BARB.LSD",0,0,0,0,0	;MUST BE 13 BYTES
g2		dc.b 	"DUEL.LSD",0
		even
		
l_030		INCBIN	"FONT_69.DAT"
l_020		INCBIN	"MENU_69B.DAT"
music		INCBIN	"ROADMUS.DAT"

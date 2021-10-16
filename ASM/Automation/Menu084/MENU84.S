		opt c+,d-,o+
		ttl	"LSD DEPACKER V1.0"

;SET TABS TO 10 FOR DISASSEMBLY
		move.l 	$4(a7),a5
		move.l 	#$100,-(a7)
		move.l 	a5,-(a7)
s8800		move.l 	#$4a0000,-(a7)
		trap 	#1
xa01		dc.w 	$a00a
s134		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap 	#1
		move.l 	d0,savesp
		pea 	moff
		move.l 	#$190001,-(a7)
		trap 	#14
main		move.l	#$80000,a7
		clr.w 	-(sp)
		pea 	$78000
		move.l 	(a7),-(a7)
		move.w 	#5,-(a7)
		trap 	#14
		move.l	#$80000,a7
		lea $ff8240,a0
		moveq.l #7,d0
		lea $1dfc0,a1
scol		move.l (a0)+,(a1)+
		dbf d0,scol
		moveq.l #7,d0
		lea $ff8240,a0
blk		clr.l (a0)+
		dbf d0,blk
		clr.b $484
		lea	$54bc2,a1
		lea	music(pc),a0
		BSR	depack
		JSR	$54CC8
		lea 	$5ffde,a1
		lea	l_020(pc),a0
		bsr 	depack
		lea	$5ffe0,a0
		lea	$ffff8240,a1
		move.w	#$7,d0
coloop		move.l	(a0)+,(a1)+
		dbf	d0,coloop
		lea $7Fd00,a0
		lea $67d00,a1
ma		lea $78000,a2
		lea -$a0(a1),a1
		cmp.l #$5ffff,a1
		ble.s superon
again		movem.l (a1)+,d0-d7
		bsr.s do
		movem.l (a1)+,d0-d7
		bsr.s do
		movem.l (a1)+,d0-d7
		bsr.s do
		movem.l (a1)+,d0-d7
		bsr.s do
		movem.l (a1)+,d0-d7
		bsr.s do
		lea -$a0(a1),a1
		cmpa.l a0,a2
		bne.s again
		lea -$a0(a0),a0
		bra.s ma
do		movem.l d0-d7,(a2)
		lea $20(a2),a2
		moveq.l #$4,d0
do1		dbf d0,do1
		rts

keyval		dc.w $ffff
superon		lea	$57fde,a1
		lea	l_030,a0
		BSR	depack
		lea $4f300,a0
		lea $50000,a1
ii		clr.l (a0)+
		cmpa.l a0,a1
		bne.s ii
;  scroller from here
ALLDONE		LEA	TEXT(PC),A0
		LEA	$50000,A1
		LEA	$78000+($a0*184),A2
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
		eor.b #2,$ff820a
		bra	co
nthz		cmp.b	#$1,d0
		blt	co
		cmp.b	#$3,d0
		beq.s	quit
		cmp.b	#$4,d0
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


clrsnd		move.w #$2700,sr
		clr.l $4d2
;		move.l s118,$118
		move.l #$8080000,$ff8800
		move.l #$9090000,$ff8800
		move.l #$a0a0000,$ff8800
		pea mon
		move.l #$190001,-(sp)
		trap #14
		addq.l #8,sp
		move.w #$2300,sr
		move.w	#$0,-(a7)
		move.l	#$78000,-(a7)
		move.l	#$78000,-(a7)
		move.w	#$5,-(a7)
		trap	#14
		add.l	#$c,a7
		rts
moff		dc.w $1a12
mon		dc.w $1408
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
		cmp.b #$2,keyval
		bcs l10r
		cmp.b #$c,keyval
		bcs L10
l10r		DBF	D0,ILOOP
		BRA	L10
GOON2		bsr.s GOON
		bra L10
GOON		MOVEM.L	A0-A2,-(A7)
		BSR	L6
		MOVEQ	#7,D7
		movem.l	(a7)+,a0-a2
L4		BSR.S	L5
		BSR.S	L5
		movem.l d0-d7/a0-a1,-(sp)
		move.w #$25,-(sp)
		trap #14
		addq.l #2,sp
		movem.l (sp)+,d0-d7/a0-a1
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

L6		MOVEM.L	D0-D2/A0-A1,-(A7)
		sub.b	#$20,d0
		bpl.s	plus
		clr.l d0
plus		rol.l	#2,d0
		lea fdat(pc),a0
		add.l d0,a0
		move.l (a0),a0
		lea $50000,a1
		moveq.l #15,d0
pl1		movem.l (a0),d1-d2
		movem.l d1-d2,(a1)
		lea $a0(a0),a0
		lea $a0(a1),a1
		dbf d0,pl1
		movem.l (sp)+,d0-d2/a0-a1
		rts
fdat		dc.l $58000,$58008,$58010,$58018,$58020,$58028,$58030,$58038,$58040,$58048
		dc.l $58050,$58058,$58060,$58068,$58070,$58078,$58080,$58088,$58090,$58098
		dc.l $58a00,$58a08,$58a10,$58a18,$58a20,$58a28,$58a30,$58a38,$58a40,$58a48
		dc.l $58a50,$58a58,$58a60,$58a68,$58a70,$58a78,$58a80,$58a88,$58a90,$58a98
		DC.L $59400,$59408,$59410,$59418,$59420,$59428,$59430,$59438,$59440,$59448
		DC.L $59450,$59458,$59460,$59468,$59470,$59478,$59480,$59488,$59490,$59498
		DC.L $59E00,$59E08,$59E10,$59E18,$59E20,$59E28,$59E30,$59E38,$59E40,$59E48
		dc.l $59e50,$59e58,$59e60,$59e68,$59e70
;    end of scroller
savesp		dc.l $0
TEXT		DC.B	"WELCOME TO AUTOMATION DISK 84           "
		DC.B	"WELL HERE WE ARE AGAIN    -   NOTE THERE HAVE MADE A CHANGE "
		DC.B	" IN OUR SYSTEM.       I.E. WE ARE NOW USING A "
		DC.B	"80 TRACK 10 SECTOR FORMAT , MAKE SURE YOU USE DECENT "
		DC.B	"DISKS AND NOT SINGLE-SIDED RUBBISH.          "
		DC.B	"WE HAVE BEEN HEARING ABOUT OTHER GROUPS THAT THINK THEY ARE BETTER "
		DC.B	"AT COMPACTING THAN US , WELL THINK AGAIN GUYS YOU ARE NOT IN OUR LEAGUE. "
		DC.B	"       IF YOU ARE WAITING FOR THE GREETINGS, TOUGH LUCK THERE ARE NONE!     "
		DC.B	"        SO GO ON, SOD OFF!                               "
		DC.B	0


****************************************


crunpos	dc.l	0

depack		ADDQ.L	#$4,A0
		MOVE.L	A0,crunpos
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
L_10		MOVE.L	crunpos,A3
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


sd0		dc.w $0
load		lea	g1(pc),a0
		move.w	d0,sd0
		subq.l	#$1,d0
td0		cmp.b	#0,d0
		beq	load2
		add.l	#$d,a0
		subq.b	#1,d0
		bra.s	td0

load2		move.l	a0,fadd+2
		move.l	#$77ff0,a7
		bsr	clrsnd
		move.w	$fc0018,$1000
		move.l	savesp,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.w 	sd0,d0
tt1		nop
tt2		cmp.b 	#2,d0
		bne.s 	tt3
		lea 	fold2(pc),a0
		bra.s	openfol
tt3		cmp.b	#1,d0
		bne.s	tt4
		lea	fold1(pc),a0
openfol		move.l a0,-(sp)
		move.w #$3b,-(sp)
		trap #1
tt4		clr.l $60000
		clr.w -(sp)
		pea $60000
		pea $60000
fadd		move.l #$ffffffff,-(sp)
		move.l #$4b0000,-(sp)
		trap #1
fold1		dc.b	"\DRAGON\",0
fold2		dc.b 	"\HKM\",0
g1		dc.b "SCAPE.LSD",0,0,0,0
g2		dc.b "S_FIGHT2.LSD",0
g3		dc.b "ROAD.LSD",0,0,0,0,0
g4		dc.b "TROOPER.LSD",0
		even
		
l_030		INCBIN	"MENU84\FNT_84.DAT"
l_020		INCBIN	"MENU84\MEN_84.DAT"
music		INCBIN	"MENU84\54BC2.DAT"

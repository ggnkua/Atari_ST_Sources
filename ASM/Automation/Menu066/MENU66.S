		opt c+,d-,o+
		ttl	"LSD DEPACKER V1.0"

;SET TABS TO 10 FOR DISASSEMBLY
		move.l $4(a7),a5
		move.l #$100,-(sp)
		move.l a5,-(sp)
s8800		move.l #$4a0000,-(sp)
		trap #1
xa01		dc.w $a00a
s134		clr.l -(sp)
		move.w #32,-(sp)
		trap #1
		move.l d0,savesp
		pea moff
		move.l #$190001,-(sp)
		trap #14
main		move.l	#$80000,a7
		clr.w -(sp)
		pea $78000
		move.l (a7),-(sp)
		move.w #5,-(sp)
		trap #14
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
		lea	$20000,a1
		lea	music(pc),a0
		BSR	depack
		move.l #$20000,$4d2
		move.b	#$30,$21d0c
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
		ble.s enda
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

enda		move.l $118,s118
		move.l #keyget,$118
		bra.s superon
keyget		move.l d0,-(sp)
		move.b $fffc02,d0
		cmp.b #$b,d0
		bgt.s noway
		bne.s nohz
		eor.b #2,$ff820a
nohz		move.b d0,keyval
noway		move.l (a7)+,d0
		dc.w $4ef9
s118		dc.l $0
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
L10		tst.b $257ad
		bne.s l10a
		move.b #2,$24cc4
l10a		move.b keyval,d0
		cmp.b #$b,d0
		bne.s nthz
		move.b #$ff,keyval
		bra co
nthz		cmp.b #$6,d0
		bcc co
		cmp.b	#5,d0
		bne	noquit
quit		lea $1dfc0,a0
		lea $ff8240,a1
		moveq.l #7,d0
q1		move.l (a0)+,(a1)+
		dbf d0,q1
		move.l	#$77f00,a7
		bsr 	clrsnd
		clr.w 	-(sp)
		trap 	#1
clrsnd		move.w #$2700,sr
		clr.l $4d2
		move.l s118,$118
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
sd0		dc.w $0
noquit		lea g1(pc),a0
		subq.b #$2,d0
		move.w d0,sd0
td0		cmp.b #0,d0
		beq load
		add.l #$d,a0
		subq.b #1,d0
		bra.s td0
co		moveq.l #0,d0
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
TEXT		DC.B	"WELCOME TO AUTOMATION DISK 66           "
		DC.B	"YET MORE GOODIES FROM THE BEST IN THE BUSINESS!             "
		DC.B	"A MESSAGE TO THE POWER GENERATION   -   NICE PACKER GUYS , STOP "
		DC.B	"JUST BOLTING A DEPACKER ON THE FRONT END OF THINGS AND YOU MAY "
		DC.B	"YET COMPETE ON OUR LEVEL , WHY DO I SAY THIS , WELL   1. CAPTAIN "
		DC.B	"FIZZ   A. METHINKS THERE ARE SOME TITLE PAGES AND MUSIC MISSING , WE USED TO SLAG "
		DC.B	"BIRDY FOR DOING THE SAME THING     B. WHY DIDN'T YOU SINGLE PART IT , EVERYBODY ELSE DID!"
		DC.B	"           2. LED STORM , YOU CAN NOT BE SERIOUS USING THE SCREEN FOR A BUFFER "
		DC.B	"ON 1.9 MACHINES           3. MARIAS  XMAS BOX , IT IS NOT EVEN PACKED!!!   "
		DC.B	"       THAT WILL DO FOR NOW.    HEY TERMINATOR , NICE BORDERLESS SCROLLERS       "
		DC.B	"           AUTOMATION ARE   WAS (NOT WAS) , L.S.D.(OZZ , MARL AND REBEL) "
		DC.B	", SHARAZ JEK , IAN.C AND THE UN-NAMEABLES(NICE WORK GUYS!  -  OZZ).          "
		DC.B	"      COMPETITION (BUT NOT IN OUR LEAGUE) GREETINGS GO TO    "
		DC.B	"  BIRDY , MEDWAY BOYS AND THE POWER GENERATION.           "
		DC.B	"   THE 'WHAT KIND OF A GINGER HAIRED NIGGER IS THAT THEN' GREETINGS GO TO   "
		DC.B	"PIRASOFT/ACU , SERVO , TURNIP , THE ELITE SQUAD , SEWER SOFTWARE , EDIT-MAN , "
		DC.B	"ANGELS OF MERCY , KEN , MAC-MAN , KAM , A-HA , MTM AND ALL AT THE SWINTON CLUB "
		DC.B	"          TO ALL THE PEOPLE WHO TAMPER OR CHANGE OUR DISKS , MAY YOU ROT "
		DC.B	"IN HELL , YOU WILL IF WE CATCH YOU , HA HA HA HA                    "
		DC.B	0


****************************************

depack		movem.l	(a0)+,d0-d1/d5
		movea.l	a1,a2
		adda.l	d0,a0
		adda.l	d1,a2
		move.l	-(a0),d0
		eor.l	d0,d5
l_001		lsr.l	#1,d0
		bne.s	l_002
		bsr	l_016
l_002		bcs.s	l_009
		moveq	#8,d1
		moveq	#1,d3
		lsr.l	#1,d0
		bne.s	l_003
		bsr	l_016
l_003		bcs.s	l_011
		moveq	#3,d1
		clr.w	d4
l_004		bsr	l_017
		move.w	d2,d3
		add.w	d4,d3
l_005		moveq	#7,d1
l_006		lsr.l	#1,d0
		bne.s	l_007
		bsr.s	l_016
l_007		roxl.l	#1,d2
		dbf	d1,l_006
		move.b	d2,-(a2)
		dbf	d3,l_005
		bra.s	l_013
l_008		moveq	#8,d1
		moveq	#8,d4
		bra.s	l_004
l_009		moveq	#2,d1
		bsr.s	l_017
		cmpi.b	#2,d2
		blt.s	l_010
		cmpi.b	#3,d2
		beq.s	l_008
		moveq	#8,d1
		bsr.s	l_017
		move.w	d2,d3
		move.w	#12,d1
		bra.s	l_011
l_010		move.w	#9,d1
		add.w	d2,d1
		addq.w	#2,d2
		move.w	d2,d3
l_011		bsr.s	l_017
l_012		subq.w	#1,a2
		move.b	0(a2,d2.w),(a2)
		dbf	d3,l_012
l_013
		cmpa.l	a2,a1
		blt.s	l_001
		tst.l	d5
		bne.s	l_014
		RTS		;done crunch
l_014
		move.w	#$FFFF,d0
l_015		move.w	d0,$FFFF8240
		dbf	d0,l_015
		moveq	#-1,d0
		rts
l_016		move.l	-(a0),d0
		eor.l	d0,d5
		move.b	#$0010,ccr
		roxr.l	#1,d0
		rts
l_017		subq.w	#1,d1
		clr.w	d2
l_018		lsr.l	#1,d0
		bne.s	l_019
		move.l	-(a0),d0
		eor.l	d0,d5
		move.b	#$0010,ccr
		roxr.l	#1,d0
l_019		roxl.l	#1,d2
		dbf	d1,l_018
		rts
load		move.l a0,fadd+2
		move.l	#$77ff0,a7
		bsr clrsnd
		move.w	$fc0018,$1000
		move.l savesp,-(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,sp
		move.w 	sd0,d0
tt1		nop
tt2		cmp.b 	#0,d0
		bne.s 	tt3
		lea 	fold2(pc),a0
		bra.s	openfol
tt3		cmp.b	#3,d0
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
fold1		dc.b	"\TERRA\",0
fold2		dc.b 	"\ISS\",0
g1		dc.b "ISS.LSD",0,0,0,0,0,0
g2		dc.b "FLUNK.LSD",0,0,0,0
g3		dc.b "FUSION.LSD",0,0,0
g4		dc.b "TERRA.LSD",0
		even
		
l_030		INCBIN	"A:\FNT_66.DAT"
l_020		INCBIN	"A:\TIME.DAT"
music		INCBIN	"A:\20000.DAT"

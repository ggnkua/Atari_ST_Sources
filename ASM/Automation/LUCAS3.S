		opt c+,d-

;SET TABS TO 10 FOR DISASSEMBLY

	
main	MOVEA.L	4(A7),A5
;	lea $77ff8,a7
	move.l a5,$4(a7)
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$100,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	move.l #$4a0000,-(sp)
	trap #1
	lea $c(a7),a7
CHEAT	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01
	ADDQ.L	#6,A7
	LEA	SUPERLNG(PC),A6
	MOVE.L	D0,(A6)
	MOVE.L	$84,tr1
	MOVE.L	#T1,$84
	move.l #$4fc0,-(sp)
	move.w #$48,-(sp)
	trap #1
	move.l d0,addr3
	MOVE.L	SUPERLNG(PC),-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01
	ADDQ.L	#6,A7
	clr.w -(sp)
	pea $ffffffff
	move.l (a7),-(sp)
	move.w #5,-(sp)
	trap #14
	lea $c(a7),a7
	pea text
	move.w #9,-(sp)
	trap #1
stkk	addq.l #6,sp
	clr.l $60000
	pea $60000
	move.l (a7),-(sp)
	pea fil
	move.l #$4b0000,-(sp)
	trap #1
SUPERLNG	DC.L	0
ope		dc.w $0
T1		movem.l	a0-a6/d0-d7,reg
		movea.l	a7,a1
		addq.l 	#6,a1
		move.w 	(a7),d0
		btst 	#$d,d0
		bne.s 	ok1
		move.l 	usp,a1
ok1		cmpi.w 	#$3d,(a1)
		bne 	notopen
		cmp.w #$ffff,nd
		beq.s open
		move.w #$ffff,ope
		move.l $2(a1),a1
		cmp.b #$31,$3(a1)
		beq.s open2
		clr.w vol
		move.l $2(a7),ex3d
		move.l #dohan,$2(a7)
open		movem.l 	reg,a0-a6/d0-d7
bye		dc.w 	$4ef9
tr1		dc.l 	$0
open2		move.w #$ffff,vol
		bra.s open
vol		dc.w 0
loadit		dc.l 0
add1a		dc.l 0
mai		dc.l 0
dohan		movem.l a0-a6/d0-d7,-(sp)
		move.w #$ffff,flag
		move.w d0,han
		tst.w d0
		bmi ex3d2
n9		move.l addr3,-(sp)
		move.l #$3ffff,-(sp)
		move.w han,-(sp)
		move.w #$3f,-(sp)
		trap #1
		lea $c(a7),a7
		move.l addr3,a0
		move.l a0,addr1
		move.l a0,addr1+4
ex3d2		clr.w flag
		movem.l (sp)+,a0-a6/d0-d7
		move.w han,d0
		dc.w $4ef9
ex3d		dc.l 0
flag		dc.w 0
han		dc.w 0
siz2		dc.l 0
notopen		cmpi.w 	#$3f,(a1)
		bne 	not3f
		cmp.w #$ffff,nd
		beq open
		cmp.w #$ffff,vol
		beq open
		move.l $8(a1),loadit
		cmp.w #$ffff,flag
		beq.s nff
		clr.w ope
		move.l $4(a1),siz2
		move.l $4(a1),d0
		sub.l d0,siz3
		move.l siz3,d1
		tst.l d1
		bpl.s okx
		add.l d0,d1
		move.l d1,d0
		move.l d0,siz2
okx		lea addr1(pc),a0
		move.l a0,-(sp)
		move.l $4(a0),a0
		move.l $8(a1),a1
lp1		move.b (a0)+,(a1)+
		subq.l #1,d0
		cmp.l #0,d0
		bne.s lp1
		move.l (a7)+,a2
		move.l a0,$4(a2)
ex3f		movem.l reg,d0-d7/a0-a6
		move.l siz2,d0
		rte
nff		move.l $4(a1),siz2
		move.l $2(a7),xread
		move.l #dp,$2(a7)
		bra open
dp		movem.l d0-d7/a0-a6,-(sp)
		move.l d0,siz2
		move.l d0,siz3
		move.l d0,mai
		move.l d0,addr2
		pea close
		move.w #$26,-(sp)
		trap #14
		addq.l #6,sp
		movem.l (a7)+,d0-d7/a0-a6
		move.l siz2,d0
		dc.w $4ef9
xread		dc.l 0
siz3		dc.l 0
close		move.l loadit,a1
		cmp.b #$4c,(a1)
		bne gg
		cmp.b #$53,$1(a1)
		bne gg
		cmp.b #$44,$2(a1)
		bne gg
		cmp.b #$21,$3(a1)
		bne gg
		move.l $4(a1),addr2
		move.l $4(a1),siz3
		move.l $4(a1),mai
		move.l $4(a1),siz2
		sub.l #$40,a1
		lea 	savdat(pc),a0
		moveq.l 	#$3f,d0
kk		move.b 	(a1)+,(a0)+
		dbf 	d0,kk
		move.l loadit,a0
		move.l a0,a1
		sub.l #$40,a1
		move.l a7,stksav
		lea stkk(PC),A7
		move.l $8(a0),d0
		addq.l #4,d0
xc		move.b (a0)+,(a1)+
		subq.l #1,d0
		cmp.l #0,d0
		bne.s xc
		move.l	loadit,a0
		move.l a0,a1
		sub.l	#$40,a0
		bsr	DEPACK
		move.l loadit,a0
		sub.l	#$40,a0
		lea	savdat(pc),a1
		moveq.l	#$3f,d0
kk2		move.b	(a1)+,(a0)+
		dbf	d0,kk2
		move.l stksav,a7
gg		rts
reg		dc.l $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
savdat		dc.l $0,$0,$0,$0,$0,$0,$0,$0,0,0,0,0,0,0,0,0
crunpos		dc.l 0
DEPACK		adda.l #4,a0
		move.w $ff8240,-(sp)
		move.l a0,crunpos
		move.l (a0)+,d5
		adda.l d5,a1
		adda.l (a0),a0
		subq.l #4,a0
		tst.w -(a0)
		bpl.s L_1
		subq.l #1,a0
L_1		move.b -(a0),d0
L_2		lsl.b #1,d0
		bne.s L_3
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
		MOVE.W	d0,$FFFF8240
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
BYENOW		move.w (a7)+,$ff8240
		RTS
stksav		dc.l 0
fw		dc.w 0
amt		dc.l 0
not3f		cmp.w #$1a,(a1)
		bne.s n1a
		move.l $2(a1),add1a
		add.l #$1a,add1a
		bra open
n1a		cmp.w #$2f,(a1)
		bne.s n2f
		move.l $2(a7),ex2f
		move.l #en2f,$2(a7)
		bra open
en2f		move.l d0,add1a
		add.l #$1a,add1a
		dc.w $4ef9
ex2f		dc.l 0
n2f		cmp.w #$4e,(a1)
		bne not3fb
		move.l $2(a7),ex4e
		move.l $2(a1),nm
		move.l #en4e,$2(a7)
		bra open
en4e		movem.l a0-a1/d0-d0,-(sp)
		move.l nm,a1
		cmp.b #$31,$3(a1)
		beq.s exxx
		cmp.w #0,ope
		beq.s need
		move.l add1a,a0
		move.l mai,d0
		move.l d0,(a0)
exxx		movem.l (a7)+,a0-a1/d0-d0
exx		dc.w $4ef9
ex4e		dc.l 0
nd		dc.w 0
nm		dc.l 0
eight		dc.l 0,0
str		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
need		move.w #$ffff,nd
		movem.l (a7)+,a0-a1/d0-d0
		movem.l a0-a6/d0-d7,str
		clr.w -(sp)
		move.l nm,-(sp)
		move.w #$3d,-(sp)
		trap #1
		addq.l #8,sp
		move.w d0,d5
		pea eight
		move.l #8,-(sp)
		move.w d5,-(sp)
		move.w #$3f,-(sp)
		trap #1
		lea $c(a7),a7
		move.w d5,-(sp)
		move.w #$3e,-(sp)
		trap #1
		addq.l #4,sp
		cmp.l #$4c534421,eight
		bne.s cvv
		move.l eight+4,d0
		move.l add1a,a0
		move.l d0,(a0)
cvv		clr.w nd
		movem.l str,a0-a6/d0-d7
		bra exx
not3fb		cmp.w #$42,(a1)
		bne open
		cmp.w #$ffff,vol
		beq open
		move.w $6(a1),han
		move.l $2(a1),amt
		move.w $8(a1),fw
		move.l $2(a7),ttt
		move.l #more,$2(a7)
		movem.l reg,d0-d7/a0-a6
		rte
more		movem.l d0-d7/a0-a6,-(sp)
		move.l addr2,siz3
		lea addr1(pc),a0
		move.l a0,a1
		add.l #4,a1		
		move.l amt,d0
		cmp.w #0,fw
		beq.s pos
		cmp.w #2,fw
		beq.s neg
		cmp.l #0,amt
		bne.s n000
		move.l addr1+4,d0
		move.l d0,siz42
		move.l addr3,d0
		sub.l d0,siz42
		bra.s ex42
n000		cmp.w #1,posneg
		beq.s ispos
isneg		sub.l d0,(a1)
		move.l siz3,d1
		sub.l d0,d1
		sub.l d1,siz3
		bra ex42
ispos		add.l d0,(a1)
		sub.l d0,siz3
		bra ex42
pos		move.l (a0),a2
		add.l d0,a2
		move.l a2,(a1)
		move.w #1,posneg
		move.l d0,siz42
		bra ex42
neg		move.l (a0),a2
		add.l addr2,a2
		lea addr2,a0
		move.l (a0),siz42
		move.l siz42,amt
		sub.l d0,a2
		move.l a2,(a1)
		clr.w posneg
ex42		movem.l (a7)+,d0-d7/a0-a6
;		move.l siz42,d0
		move.l amt,d0
		dc.w $4ef9
ttt		dc.l 0
siz42		dc.l 0
posneg		dc.w 0
filflg		dc.w 0,0,0,0
addr1		dc.l $0,$0
addr2		dc.l 0
addr3		dc.l 0	
fil		dc.b "afrvap",0
text		dc.b "VAPOUR PRESENTS . . .",0
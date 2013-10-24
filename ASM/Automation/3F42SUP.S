		opt c+,d-

;SET TABS TO 10 FOR DISASSEMBLY

	
main	MOVEA.L	4(A7),A5
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
stkk	clr.l $60000
	pea $60000
	move.l (a7),-(sp)
	move.l #gam,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea $10(a7),a7
	clr.w -(sp)
	trap #1
SUPERLNG	DC.L	0


T1		movem.l	a0-a6/d0-d7,reg
		movea.l	a7,a1
		addq.l 	#6,a1
		move.w 	(a7),d0
		btst 	#$d,d0
		bne.s 	ok1
		move.l 	usp,a1
ok1		nop
next1		cmpi.w 	#$3d,(a1)
		bne.s 	notopen
		move.l 	$2(a1),a1
		cmpi.b 	#$3a,$1(a1)
		bne.s 	n1a
		addq.l 	#2,a1
n1a		cmpi.b 	#$5c,(a1)
		bne.s 	open
		addq.l 	#1,a1
open		movem.l 	reg,a0-a6/d0-d7
bye		dc.w 	$4ef9
tr1		dc.l 	$0
loadit		dc.l 	$0
notopen		cmpi.w  #$42,(a1)
		beq	finsiz
		cmpi.w 	#$3f,(a1)
		bne.s 	open
		move.l 	$8(a1),loadit
		move.l $2(a7),ex3f
		move.l #cls,$2(a7)
		bra.s open
siz2		dc.l 0
cls		movem.l d0-d7/a0-a6,-(sp)
		move.l d0,siz2
		pea close
		move.w #$26,-(sp)
		trap #14
		addq.l #6,sp
		movem.l (a7)+,d0-d7/a0-a6
		move.l siz2,d0
		dc.w $4ef9
ex3f		dc.l 0
flg		dc.w 0
close		move.l loadit,a1
		cmp.w #$ffff,flg
		beq ret
		cmp.b #$4c,(a1)
		bne ret
		cmp.b #$53,$1(a1)
		bne ret
		cmp.b #$44,$2(a1)
		bne ret
		cmp.b #$21,$3(a1)
		bne ret
		move.l $4(a1),siz2
gg		sub.l #$20,a1
		lea 	savdat(pc),a0
		moveq.l 	#$1f,d0
kk		move.b 	(a1)+,(a0)+
		dbf 	d0,kk
		move.l loadit,a0
		move.l a0,a1
		sub.l #$20,a1
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
		sub.l	#$20,a0
		bsr	DEPACK
		move.l loadit,a0
		sub.l	#$20,a0
		lea	savdat(pc),a1
		moveq.l	#$1f,d0
kk2		move.b	(a1)+,(a0)+
		dbf	d0,kk2
		move.l stksav,a7
ret		rts
reg		dc.l $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
savdat		dc.l $0,$0,$0,$0,$0,$0,$0,$0
crunpos		dc.l 0
eight		dc.l 0,0
han		dc.w 0
finsiz		cmp.w #2,$8(a1)
		bne open
		move.l $2(a7),end
		move.w $6(a1),han
		move.l #getsiz,$2(a7)
		bra open
getsiz		movem.l a0-a6/d1-d7,-(sp)
		clr.w -(sp)
		move.w han,-(sp)
		clr.l -(sp)
		move.w #$42,-(sp)
		move.l d0,siz42
		trap #1
		lea $a(a7),a7
		move.w #$ffff,flg
		pea eight
		move.l #8,-(sp)
		move.w han,-(sp)
		move.w #$3f,-(sp)
		trap #1
		lea $c(a7),a7
		lea eight(pc),a0
		cmp.l #$4c534421,(a0)
		bne.s lki
		move.l $4(a0),siz42
lki		move.l siz42,d0
		movem.l (a7)+,a0-a6/d1-d7
		clr.w flg
		dc.w $4ef9
end		dc.l 0
siz42		dc.l 0
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
gam		dc.b "FILE.DAT",0
text		dc.b "HANK PRESENTS . . .",0
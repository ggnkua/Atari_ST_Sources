	MOVE.L A7,A5
	MOVE.L #OURSTACK,A7
	MOVE.L 4(A5),A5
	MOVE.L #$400,-(SP)
	MOVE.L A5,-(SP)
	CLR.W -(A7)
	MOVE.W #$4A,-(SP)
	TRAP #1
	ADD.L #12,SP
	TST.L D0
	BNE EXIT
	dc.w $a00a
	bra	PICTURE

HERE	MOVE.L #0,-(A7)
	MOVE.L #0,-(A7)
	MOVE.L #NAME,-(A7)
	CLR.W -(A7)
	MOVE.W #$4B,-(A7)
	TRAP #1
	ADDA.L #$E,A7

EXIT	CLR.W -(A7)
	TRAP #1
	DS.L 100
OURSTACK	DS.L 1
NAME	DC.B "POWER.PRG",0
	EVEN
PICTURE
	move.l #graphix+2,-(a7)
	move.w #6,-(sp)
	trap #14
	addq.l #6,sp
	move.w #2,-(sp)
	trap #14
	addq.l #2,sp
	move.l d0,a1
	lea graphix,a0
	lea $22(a0),a0
	move.w #$FA0,d6
jere	move.l (a0)+,(a1)+
	MOVE.L (A0)+,(A1)+
	dbf d6,jere
	BRA HERE
graphix	incbin "powtir.pi1"
MYTRAP	LEA	TRAINER(PC),A4
	BSR	PRINT
CHECK	BSR	WAITKEY	

	SWAP	D0
	CMP.B	#$15,D0		;YES
	BEQ	ALTER
	CMP.B	#$31,D0		;NO
	BNE	CHECK
	MOVE.L	#1000,D1
	BRA	put
	
ALTER	LEA	amount(PC),A4
	BSR	PRINT

top	bsr	HARDKEY
	cmp.b	#2,d0
	bne	two
	move.l	#10000,d1
	bra	put

two	cmp.b	#3,d0
	bne	three
	move.l	#100000,d1
	bra	put

three	cmp.b	#4,d0
	bne	four
	move.l	#1000000,d1
	bra	put

four	cmp.b	#5,d0
	bne	five
	move.l	#2000000,d1
	bra	put

five	cmp.b	#6,d0
	bne	six
	move.l	#3000000,d1

six	cmp.b	#7,d0
	bne	seven
	move.l	#4000000,d1

seven	cmp.b	#8,d0
	bne	eight
	move.l	#5000000,d1

eight	cmp.b	#9,d0
	bne	nine
	move.l	#6000000,d1

nine	cmp.b	#10,d0
	bne	top
	move.l	#7000000,d1

put	move.l	a6,a5
	add.l	#398992-28,a5
	move.l	d1,(a5)
	clr.b	$fffffc02
	
GO	JMP	(A6)
	RTE

amount	dc.b	27,"E"
	dc.b	"Choose amount of credits to start the game with",13,10,10,10
	dc.b	"1 - $1000",13,10,10
	dc.b	"2 - $10000",13,10,10
	dc.b	"3 - $100000",13,10,10
	dc.b	"4 - $200000",13,10,10
	dc.b	"5 - $300000",13,10,10
	dc.b	"6 - $400000",13,10,10
	dc.b	"7 - $500000",13,10,10
	dc.b	"8 - $600000",13,10,10
	dc.b	"9 - $700000",13,10,10,10
	dc.b	"PS - This music from the game is also on this disk along with the replay code."
	dc.b	0
	even

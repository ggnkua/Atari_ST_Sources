*********************************
*				*
* 	Frontier Intro Code	*
*				*
*	   By Dr Dynac		*
*				*
*********************************


HEADER: MOVE.L	A7,A5
	MOVE.L	#USTK,A7
	MOVE.L	4(A5),A5
	MOVE.L	12(A5),D0
	ADD.L	20(A5),D0
	ADD.L	28(A5),D0
	ADD.L	#$100,D0
	MOVE.L	D0,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#$4A,-(A7)
	TRAP	#1
	ADD.L	#12,A7

	MOVE.L	D0,D7
	
	MOVE.W	#1,-(A7)
RES	PEA	-1
	PEA	-1
	MOVE.W	#5,-(A7)
	TRAP	#14
	ADD.L	#12,A7

	CLR.L	D7
	BSR	MODE

	MOVE.L	#MYTRAP,$A8
		
	CLR.W	$FFFF8240
	MOVE.W	#$773,$FFFF8246

	LEA	MESS(PC),A4
	BSR	PRINT

	MOVE.L	#MYTRAP,$A8

LOAD	PEA	0
	PEA	0
	PEA	ELITE2(PC)
	MOVE.W	#0,-(A7)
	MOVE.W	#$4B,-(A7)
	TRAP	#1
	ADD.L	#16,A7
	BRA	EXIT

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

top	bsr	WAITKEY
	cmp.b	#"1",d0
	bne	two
	move.l	#10000,d1
	bra	put

two	cmp.b	#"2",d0
	bne	three
	move.l	#100000,d1
	bra	put

three	cmp.b	#"3",d0
	bne	four
	move.l	#1000000,d1
	bra	put

four	cmp.b	#"4",d0
	bne	five
	move.l	#2000000,d1
	bra	put

five	cmp.b	#"5",d0
	bne	six
	move.l	#3000000,d1
	bra	put

six	cmp.b	#"6",d0
	bne	seven
	move.l	#4000000,d1
	bra	put

seven	cmp.b	#"7",d0
	bne	eight
	move.l	#5000000,d1
	bra	put

eight	cmp.b	#"8",d0
	bne	nine
	move.l	#6000000,d1
	bra	put

nine	cmp.b	#"9",d0
	bne	top
	move.l	#7000000,d1
	bra	put

put	move.l	a6,a5
	add.l	#398992-28,a5
	move.l	d1,(a5)

flush	BTST.B 	#0,$FFFFFC00		; any waiting?
	BEQ.S  	GO			; exit if none waiting.
	MOVE.B 	$FFFFFC02,D0		; get next in queue
	BRA.S  	flush			; and continue
	

GO	JMP	(A6)


EXIT	CLR.W	-(A7)
	TRAP	#1

HARDKEY	MOVE.B	$FFFFFC02,D0
	CMP.B	#10,D0
	BGT	HARDKEY
	RTS


MODE	MOVE.L	D7,-(A7)
	MOVE.W	#32,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,D7
	RTS

PRINT	MOVE.L	A4,-(A7)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	RTS
	
WAITKEY	MOVE.W	#7,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	RTS
	rte

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
	dc.b	"PS - The music from the game is also on this disk along with the replay code."
	dc.b	0
	even
	
ELITE2	DC.B	"FRONTIER.PRG",0

MESS	DC.B	27,"E"
	DC.B	27,"b",1
	DC.B	27,"Y",32+1,32+27
	DC.B	"T"

	dc.b	27,"b",3
	dc.b	"he "

	dc.b	27,"b",1
	dc.b	"C"

	dc.b	27,"b",3
	dc.b	"asualty "

	dc.b	27,"b",1
	dc.b	"D"

	dc.b	27,"b",3
	dc.b	"epartment"

	dc.b	27,"b",3
	DC.B	27,"Y",32+4,32+34
	DC.B	"Presents"

	DC.B	27,"b",2
	DC.B	27,"Y",32+7,32+29
	DC.B	"FRONTIER (ELITE II)"

	DC.B	27,"b",3
	DC.B	27,"Y",32+11,32+29
	DC.B	"Cracked By"

	DC.B	" Dr Dynac"

	DC.B	27,"b",3
	DC.B	27,"Y",32+14,32+33
	DC.B	"PLEASE WAIT",0

	EVEN

TRAINER	DC.B	27,"Y",32+17,32+23
	DC.B	"DO YOU WANT TO CHEAT? [Y]es [N]o",0
	even

	DS.B	256
USTK	DS.B	256


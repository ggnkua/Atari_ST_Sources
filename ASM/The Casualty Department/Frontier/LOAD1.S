HEADER:
	MOVE.L	A7,A5
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
	
	CLR.W	$FFFF8240
	MOVE.W	#$773,$FFFF8246

	BSR	MODE	

	LEA	MESS(PC),A4
	BSR	PRINT


LOAD	PEA	0
	PEA	0
	PEA	ELITE2(PC)
	MOVE.W	#3,-(A7)
	MOVE.W	#$4B,-(A7)
	TRAP	#1
	ADD.L	#16,A7
	TST.L	D0
	BMI	EXIT

	MOVE.L	D0,A6
	ADD.L	#256,A6


	LEA	TRAINER(PC),A4
	BSR	PRINT
	BSR	WAITKEY	

CH	SWAP	D0
	CMP.B	#$15,D0
	BEQ	ALTER
	CMP.B	#1,D0

ALTER

GO	JMP	(A6)

EXIT	CLR.W	-(A7)
	TRAP	#1

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

INPUT	PEA	INP(PC)
	MOVE.W	#10,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	RTS
	
INP	DC.B	7
	DC.B	0
	DC.B	7

	EVEN

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

TRAINER	DC.B	27,"Y",32+17,32+25
	DC.B	"DO YOU WANT TO CHEAT? [Y]es [N]o",0
	even

CREDITS	dc.b	27,"Y",32+19+32+14
	DC.B	"Start with how many credits? (max=9999999)",0
	even


	DS.B	256
USTK	DS.B	256
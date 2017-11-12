BSS SEG "bss"
_base:/* global */
	.WORD	#4
CODE SEG "init!"
_init:/* global */
CODE SEG "main"
_main:/* global */
	MOVE.L	4(A7),A5
	MOVE.L	28(A5),D6
	MOVE.L	12(A5),D0
	ADD.L	20(A5),D0
	ADD.L	D6,D0
	ADD.L	#2256,D0
	MOVE.L	D0,D1
	ADD.L	A5,D0
	ANDI	#-2,D0
	MOVE.L	D0,A7
	MOVE.L	D1,-(A7)
	MOVE.L	A5,-(A7)
	CLR	-(A7)
	MOVE	#74,-(A7)
	TRAP	#1
	ADDA	#12,A7
	MOVE.L	24(A5),A0
	MOVE.L	A0,A1
	ADDA.L	D6,A1
	MOVE.L	20(A5),D0
	SUBQ.L	#1,D0
	BLE.S	L0swapcont
L0swap:
	MOVE.B	-(A0),-(A1)
	DBF	D0,L0swap
L0swapcont:
	MOVE.L	16(A5),A0
	MOVE.L	D6,D0
	MOVE.L	A0,A4
	ADDA.L	D6,A4
	SUBQ.L	#1,D0
L0clear:
	CLR.B	(A0)+
	DBF	D0,L0clear
	MOVE.L	A5,_base(A4)
	MOVE.L	8(A5),A5
	JSR	_init(PC)
	JMP	main(PC)

BSS SEG "bss"
_base:/* global */
	.WORD	#4
CODE SEG "init!"
_init:/* global */
CODE SEG "main"
_main:/* global */
	MOVE.L	A7,A5
	MOVE.L	4(A5),A5
	MOVE.L	12(A5),D0
	ADD.L	20(A5),D0
	ADD.L	28(A5),D0
	ADD.L	#8448,D0
	MOVE.L	D0,D1
	ADD.L	A5,D1
	AND.L	#-2,D1
	MOVE.L	D1,A7
	MOVE.L	24(A5),A0
	MOVE.L	24(A5),A1
	ADDA.L	28(A5),A1
	MOVE.L	20(A5),D0
	SUBQ.L	#1,D0
	BLE	L0swapcont(PC)
L0swap:
	MOVE.B	-(A0),-(A1)
	DBF	D0,L0swap
L0swapcont:
	MOVE.L	16(A5),A0
	MOVE.L	28(A5),D0
	SUBQ.L	#1,D0
L0clear:
	CLR.B	(A0)+
	DBF	D0,L0clear
	MOVE.L	16(A5),A4
	ADDA.L	28(A5),A4
	MOVE.L	A5,_base(A4)
	MOVE.L	8(A5),A5
	JSR	_init(PC)
	JSR	main(PC)

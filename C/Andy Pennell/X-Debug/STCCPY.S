	opt	ALINK

* disassembled from 1989 compiler libraries

	XREF	_strncpy
	XDEF	_stccpy

_stccpy	LINK	A6,#0
	MOVE.L	$10(A6),-(A7)
	MOVE.L	$C(A6),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	_strncpy(PC)
	MOVEA.L	8(A6),A0
	MOVE.L	$10(A6),D1
	CLR.B	0(A0,D1.L)
	SUB.L	8(A6),D0
	ADDQ.L	#1,D0
	UNLK	A6
	RTS

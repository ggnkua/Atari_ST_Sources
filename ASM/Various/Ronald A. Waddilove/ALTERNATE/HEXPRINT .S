*********************************
*	Print hex number	*
*	By R.A.Waddilove	*
*    Atari ST User Oct 1989	*
*********************************

p_term		EQU 0
c_conin		EQU 1
c_conout	EQU 2

* -------------------------------------
* 	Program start
* -------------------------------------

	MOVE #$1234,D0		Number
	BSR hexprint
	MOVE #c_conin,-(A7)
	TRAP #1			Wait for keypress
	ADDQ.L #2,A7
	MOVE #p_term,-(A7)
	TRAP #1			Gemdos 0 - exit

* -------------------------------------
* Print hex number in D0
* Uses D0,D1
* -------------------------------------

hexprint
	MOVE D0,D1		Save number
	LSR #8,D0		Get 1st nybble
	LSR #4,D0
	BSR printchar
	MOVE D1,D0
	LSR #8,D0		Get 2nd nybble
	BSR printchar
	MOVE D1,D0
	LSR #4,D0		Get 3rd nybble
	BSR printchar
	MOVE D1,D0
printchar
	AND #$000F,D0		Isolate nybble
	ADD #'0',D0
	CMP #'9',D0
	BLE ok
	ADD #7,D0
ok
	MOVE D0,-(A7)
	MOVE #c_conout,-(A7)
	TRAP #1
	ADDA.L #4,A7
	RTS

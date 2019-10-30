*	Speed up floppy disc accesses by switching off the
*	write verify option and setting a fast seek rate
*	By R.A.Waddilove

	PEA subr		stack address of subroutine
	MOVE.W #$26,-(SP)	stack XBIOS SUPERX function number
	TRAP #14		call subr in supervisor mode
	ADD.L #2,A7		restore stack
	MOVE.W #0,-(A7)		return to DESKTOP
	TRAP #1


* 	Entered in supervisor mode
subr:
	MOVE.W #0,($444)	write verify flag=off
	MOVE.W #2,($440)	seek rate=2ms
	RTS

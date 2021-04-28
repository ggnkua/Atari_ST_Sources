
*	PROGRAM I...Input a number from the keyboard

	MOVE.W #1,-(A7)		Put function number 1 (CONIN) on stack
        TRAP #1			Call the GEMDOS part of TOS
	ADD.L #2,A7		Restore stack to old value

*	RTS			Use this if called from another program

	MOVE.W #0,-(A7)		Put function number 0 on stack
	TRAP #1			Return to Desktop


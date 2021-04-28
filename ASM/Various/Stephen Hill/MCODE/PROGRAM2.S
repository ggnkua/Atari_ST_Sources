
*	PROGRAM II...Print the letter 'S' on the screen

	MOVE.W #'S',-(A7)	Put ASCII value of 'S' on stack
	MOVE.W #2,-(A7)		Put function number 2 (CONOUT) on stack
        TRAP #1			Call the GEMDOS part of TOS
	ADD.L #4,A7		Restore stack to value before TRAP

*	RTS			Use this if called from another program

	MOVE.W #0,-(A7)		Put function number 0 on stack
	TRAP #1			Return to Desktop


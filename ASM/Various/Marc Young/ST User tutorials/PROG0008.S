*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0008.S   *
*  This program should be assembled to disk as PROG0008.PRG or  *
*  PROG0008.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*****************************************************************
* This program is an example of using passing parameters to and	*
* from subroutines.						*
*****************************************************************
start:
	MOVE.W	#'S',-(SP)	;Move ASCII for 'S' onto the stack
	BSR	print		;execute the print subroutine
	ADD.L	#2,SP		;correct the stack.

	MOVE.W	#'T',-(SP)	;Move ASCII 'T' onto the stack
	BSR	print		;execute the print subroutine
	ADD.L	#2,SP		;correct the stack
*
	MOVE.W	#1,-(SP)	;Wait for a key
	TRAP	#1
	ADDQ.L	#2,SP

* .. and finally exit back to the desktop
	CLR.W	-(SP)		;0 is TERM
	TRAP	#1		;Call GEMDOS
*****************************************************************
*             S U B R O U T I N E S    S T A R T   H E R E      *

print:
* Print prints the character whose ASCII code has been put on the
* stack before executing the subroutine.

	MOVE.W	4(SP),-(SP)	;Move character onto top of stack
	MOVE.W	#2,-(SP)	;GEMDOS 2
	TRAP	#1		;used to print the character
	ADDQ.L	#4,SP		;correct the stack
	RTS			;end the subroutine.


	
*****************************************************************
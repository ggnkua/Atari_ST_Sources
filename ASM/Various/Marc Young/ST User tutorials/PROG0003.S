*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0003.S   *
*  This program should be assembled to disk as PROG0003.PRG or  *
*  PROG0003.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*****************************************************************
* This program, together with PROG0004.S, demonstrates the      *
* importance of the EVEN assembler instruction.                 *
* This program will crash as the address of label is odd.       *
* PROG0004.S is O.K. because of the use of the EVEN instruction *
*****************************************************************
start:
	MOVE.L	#label,A0	;Move the Address of label to A0
	MOVE.W	(A0),D0		;Move word at address in A0 to D0
*
	MOVE.W	#1,-(SP)	;GEMDOS 1 waits for a keypress
	TRAP	#1
	ADDQ.L	#2,SP
*
* .. and finally exit back to the desktop
	CLR.W	-(SP)		;0 is TERM
	TRAP	#1		;Call GEMDOS
******************************************************************
* The section of program following contains the Data used by the *
* program which is assembled and saved as part of the program.   *
	SECTION DATA
*
dummy:	DC.B	1	;Dummy byte to force odd address
label:	DC.B	2,3,4	;string of bytes to be read by program

	
*****************************************************************
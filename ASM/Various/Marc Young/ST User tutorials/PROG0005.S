*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0005.S   *
*  This program should be assembled to disk as PROG0005.PRG or  *
*  PROG0005.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*****************************************************************
* This program is an example of using the CoMPare and Branch	*
* instructions to control the execution of a program.		*
* It will ask you to press two keys. It will then compare the   *
* values of the two, and tell you which one was the higher.     *
* To exit the program, simply press the same key twice.         *
*****************************************************************
start:
	MOVE.L	#text1,-(SP)	;Move the address of the text
	MOVE.W	#9,-(SP)	;GEMDOS 9 Prints a string
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#6,SP		;Correct the stack
*
	MOVE.W	#1,-(SP)	;GEMDOS 1 gets a keypress
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#2,SP		;Correct the stack
	MOVE.B	D0,D1		;Store the first key in D1
*
	MOVE.L	#text2,-(SP)	;Move the address of the text
	MOVE.W	#9,-(SP)	;GEMDOS 9 Prints a string
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#6,SP		;Correct the stack
*
	MOVE.W	#1,-(SP)	;GEMDOS 1 gets a keypress
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#2,SP		;Correct the stack
	MOVE.B	D0,D2		;Store the second key in D2
*
	CMP.B	D1,D2		;CoMPare the two keys
	BEQ.S	exit		;One = Two so exit
	BGT.S	two_lt		;Two was Less than One
	BLT.S	one_lt		;One was Less than Two
*
* The program can't drop through to here as one of the above three
* must be satisfied. In fact, by re-ordering the tests, one test could
* have been omitted, and the program left to drop through to the remaining
* option. But that wouldn't have demonstrated three compare and branch
* instructions.
*
two_lt:	MOVE.L	#text3,-(SP)	;Move the address of the text
	MOVE.W	#9,-(SP)	;GEMDOS 9 Prints a string
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#6,SP		;Correct the stack
*
	BRA	start
*
one_lt:	MOVE.L	#text4,-(SP)	;Move the address of the text
	MOVE.W	#9,-(SP)	;GEMDOS 9 Prints a string
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#6,SP		;Correct the stack
*
	BRA	start
*
exit:	MOVE.L	#text5,-(SP)	;Move the address of the text
	MOVE.W	#9,-(SP)	;GEMDOS 9 Prints a string
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#6,SP		;Correct the stack
*
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
text1:	DC.B	13,10,'Please press the first key: ',0
text2:	DC.B	13,10,'Now press the second key: ',0
text3:	DC.B	13,10,'The first key was less than the second.',0
text4:	DC.B	13,10,'The second key was less than the first.',0
text5:	DC.B	13,10,'Both keys were the same - Time to go.',0



	
*****************************************************************
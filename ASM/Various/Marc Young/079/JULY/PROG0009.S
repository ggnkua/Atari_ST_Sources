*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0009.S   *
*  This program should be assembled to disk as PROG0009.PRG or  *
*  PROG0009.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*****************************************************************
* This program is an example of using Macros 			*
*****************************************************************
* Define our Macros up front. Notice that the code between the
* MACRO statement and the ENDM statement is only assembled into
* the final program when the 'print' label is used as an instruction.
*
print:	MACRO
* The print Macro prints a single character which is passed as
* a parameter.
*
	MOVE.W	\1,-(SP)
	MOVE.W	#2,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	ENDM

exit:	MACRO
* The end Macro terminates the program,
	CLR.W	-(SP)
	TRAP	#1
	ENDM 

getkey:	MACRO
* The getkey macro waits for a keypress
	MOVE.W	#1,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP

	ENDM
*************************************************
* The program proper starts here		*
start:
	print	#'A'
	print	#'t'
	print	#'a'
	print	#'r'
	print	#'i'
*
	getkey
*
	exit

	
*****************************************************************
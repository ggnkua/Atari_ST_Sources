*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0001.S   *
*  This program should be assembled to disk as PROG0001.PRG or  *
*  PROG0001.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*****************************************************************

start:
* Firstly print the letter A on the screen..
	MOVE.W	#65,-(SP)	;65 is ASCII for 'A'
	MOVE.W	#2,-(SP)	;2 is CONOUT
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#4,SP		;Adjust the Stack
* ..then wait for a keypress..
	MOVE.W	#1,-(SP)	;1 is CONIN
	TRAP	#1		;Call GEMDOS
	ADDQ.L	#2,SP		;Adjust the Stack
* .. and finally exit back to the desktop
	CLR.W	-(SP)		;0 is TERM
	TRAP	#1		;Call GEMDOS
	
*****************************************************************
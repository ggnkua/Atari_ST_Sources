*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0002.S   *
*  This program should be assembled to disk as PROG0002.PRG or  *
*  PROG0002.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*****************************************************************

start:
* Firstly, we clear the screen
	MOVE.L	#cls,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
* Display the greeting
	MOVE.L	#greet,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
* Input the name
	MOVE.L	#name_in,-(SP)
	MOVE.W	#10,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
* Print Hello There
	MOVE.L	#person,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
* Print the name as entered
	MOVE.L	#name_out,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
* Print goodbye
	MOVE.L	#bye,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
* Print Press a Key message...
	MOVE.L	#keyp,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP	
* Wait for a key press
	MOVE.W	#1,-(SP)
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
cls:	DC.B	27,'E',0	;The sequence ESC E clears the screen
				;ASCII 27 is ESCAPE
				;ASCII 0 terminates the string
*
	EVEN
greet:	DC.B	10,10,10,10,10	;First skip a few lines (ASCII 10 is
				;LINEFEED).
	DC.B	'Hello, and welcome to',13,10
				;ASCII 13 is carriage return.
	DC.B	27,'p'		;The sequence ESC p Inverts the text.
	DC.B	"Atari ST User's",13,10
	DC.B	27,'q'		;The sequence ESC q returns text to normal
	DC.B	'Assembler Tutorial.',13,10,10
	DC.B	'Please Type Your Name and press Return',13,10,10,0
*
	EVEN
person:	DC.B	13,10,'Well, hello there ',0
	EVEN
name_in:	DC.B	20,0		;Only allow 20 characters to be input
	EVEN
name_out:
	DS.B	20
*
	EVEN
bye:	DC.B	13,10,10,"That's enough playing - ",13,10
	DC.B	'on with the tutorial...',0
*
	EVEN
keyp:	DC.B	13,10,10,10,10,10
	DC.B	'    PRESS A KEY TO END ',0


	
*****************************************************************
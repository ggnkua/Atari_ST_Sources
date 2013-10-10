*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0006.S   *
*  This program should be assembled to disk as PROG0006.PRG or  *
*  PROG0006.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*****************************************************************
* This program is an example of using the CoMPare and Branch	*
* instructions to control the execution of a program.		*
* When run, a ball bounces about the screen. The CMP and TST    *
* instructions are used to check for the ball hitting the edge  *
* and also for a key being pressed.				*
*****************************************************************
start:
*
	MOVE.W	#4,-(SP)	;XBIOS 4 returns the screen mode
	TRAP	#14		;in register D0
	ADDQ.L	#2,SP		;Correct the Stack Pointer
*
	TST.W	D0		;Test Screen Mode...
	BEQ	low_res		;0 = Low Resolution
* We must be in Medium or High resolution
	MOVE.B	#80,width	;Make screen width 80 characters
	BRA	cont		;and carry on.
low_res:
	MOVE.B	#40,width	;Make screen width 40 characters
cont:
	MOVE.B	#1,D7		;Use D7 as X velocity
	MOVE.B	#1,D6		;Use D6 as Y velocity
	MOVE.B	#20,D5		;Use D5 as X position
	MOVE.B	#20,D4		:Use D4 as Y position
	MOVE.B	D5,x_pos	;Store X pos (see comments later
	ADD.B	#31,x_pos	;for explanation of adding 31)
	MOVE.B	D4,y_pos	;Store Y pos
	ADD.B	#31,y_pos
*
	MOVE.L	#cls,-(SP)	;Clear screen
	MOVE.W	#9,-(SP)	;using GEMDOS 9 to print
	TRAP	#1		;call GEMDOS
	ADD.L	#6,SP		;Correct the Stack
*
loop:
	MOVE.L	#pos,-(SP)	;Position the cursor by printing
	MOVE.W	#9,-(SP)	;the sequence at pos using GEMDOS 9
	TRAP	#1		;call GEMDOS
	ADD.L	#6,SP		;Correct the Stack
*
	MOVE.W	#' ',-(SP)	;Now print a space to erase the ball
	MOVE.W	#2,-(SP)	;using GEMDOS 2
	TRAP	#1
	ADD.L	#4,SP		;Correct the Stack
*
	ADD.B	D7,D5		;Update the x position
	ADD.B	D6,D4		;Update the y position
	MOVE.B	D5,x_pos	;Store X pos (see comments later
	ADD.B	#31,x_pos	;for explanation of adding 31)
	MOVE.B	D4,y_pos	;Store Y pos
	ADD.B	#31,y_pos
*
	MOVE.L	#pos,-(SP)	;Position the cursor by printing
	MOVE.W	#9,-(SP)	;the sequence at pos using GEMDOS 9
	TRAP	#1		;call GEMDOS
	ADD.L	#6,SP		;Correct the Stack
*
	MOVE.W	#'O',-(SP)	;Now print an 'O' as the ball
	MOVE.W	#2,-(SP)	;using GEMDOS 2
	TRAP	#1
	ADD.L	#4,SP		;Correct the Stack
*
test:	CMP.B	width,D5	;Check X position for edge of screen
	BLT	ok_1		;X < edge - carry on
*
	MOVE.B	#-1,D7		;Change X velocity to move left
	BRA	check_y		;Now go check Y position
*
ok_1:	CMP.B	#2,D5		;Check X position for left edge
	BGE	check_y		;X > edge - carry on
*
	MOVE.B	#1,D7
*
check_y:
	CMP.B	depth,D4	;Check Y position for bottom of screen
	BLT	ok_2		;Y < bottom - carry on
*
	MOVE.B	#-1,D6		;Change Y velocity to go up
	BRA	ok_3		;and carry on
*
ok_2:	CMP.B	#2,D4		;Check Y position for top of screen
	BGE	ok_3		;Y > top - carry on
*
	MOVE.B	#1,D6
*
ok_3:	MOVE.W	#$B,-(SP)	;GEMDOS $B checks for key presses
	TRAP	#1		;Call GEMDOS
	ADD.L	#2,SP		;Correct the stack
	TST.W	D0		;Test D0 (returned from GEMDOS $B
	BEQ	loop		; No key pressed - keep looping

* .. and finally exit back to the desktop
	CLR.W	-(SP)		;0 is TERM
	TRAP	#1		;Call GEMDOS
******************************************************************
* The section of program following contains the Data used by the *
* program which is assembled and saved as part of the program.   *
	SECTION DATA
*
width:	DC.B	0
depth:	DC.B	24
*
*
cls:	DC.B	27,'E',27,'f',0	;Clear screen and make sure cursor off
	EVEN
*
* A little explanation of the below may be in order. To position *
* the cursor the sequence of characters 27,'Y',y,x can be used.  *
* In this case, y is actually the row number on the screen + 31, *
* and x is the column number + 31.                               *
*
pos:	DC.B	27,'Y'
y_pos:	DC.B	40		;Y position of ball
x_pos:	DC.B	40		;X position of ball
	DC.B	0		;Terminating 0

	
*****************************************************************
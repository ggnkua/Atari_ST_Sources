*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0010.S   *
*  This program should be assembled to disk as PROG0010.PRG or  *
*  PROG0010.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*  Note that this program looks for the two Degas format files  *
*  SOURCE.PI1 and DEST.PI1 in the same folder from which the    *
*  program was run.						*
*****************************************************************
* This program demonstrates the use of the BLIT routine and     *
* Logical Operations. As set up, it uses logical operation 7    *
* which is 'OR'. Change the line commented to any value from    *
* 0 to 15 to see different effects.				*
*****************************************************************
start:	MOVE.L	#stack,SP	;Set up our own stack
	BSR	init		;Initialize everything
	BSR	show_blit	;Do a few blits
finish:
	MOVE.W	#1,-(SP)	;Get a key
	TRAP	#1
	ADDQ.L	#2,SP
* Reset the screen resolution
	MOVE.W	old_rez,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
*
	CLR.W	-(SP)		;Finish the program
	TRAP	#1
**************************************************
* INIT - Initialize the variables ready to start *
**************************************************
init:	
* Store the current screen resolution (so we can return to it on exit)
	MOVE.W	#4,-(SP)	;XBIOS 4 returns graphics resolution
	TRAP	#14		;in D0 (0-Low, 1-Medium, 2-High)
	ADDQ.L	#2,SP
	MOVE.W	D0,old_rez	;Store resolution
* And set Low resolution
	CLR.W	-(SP)		;0 = low resolution
	MOVE.L	#-1,-(SP)	;Don't change screen addresses
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
* Get addresses of two screens
	MOVE.W	#2,-(SP)	;XBIOX 2 returns current screen address
	TRAP	#14		;in D0
	ADDQ.L	#2,SP
	MOVE.L	D0,screen_1	;Store as screen 1
	SUB.L	#32000,D0	;Subtract 32000
	MOVE.L	D0,screen_2	;and store as screen 2
	SUB.L	#32000,D0	;Subtract 32000
*
* Now load the destination screen into memory
	MOVE.L	screen_1,A3	;Address to load it
	MOVE.L	#dst_file,A1	;Address of file name
	MOVE.L	#pic_mode,A2	;Address to store mode/palette
	BSR	PI1_load	;Subroutine to load PI1 files
* Set the colour palette
	PEA	palette
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
*
* Now load the source picture into memory
	MOVE.L	screen_2,A3	;Address to load it
	MOVE.L	#src_file,A1	;Address of file name
	MOVE.L	#pic_mode,A2	;Address to store mode/palette
	BSR	PI1_load	;Subroutine to load PI1 files
	RTS
**********************************************
* PI1_load - Loads a Degas PI1 picture file. *
* A3 - Holds address to load picture data    *
* A1 - Holds address of file name            *
* A2 - Holds address to put first 34 bytes   *
**********************************************
PI1_load:	
* First open the file.
	MOVE.W	#0,-(SP)	;Open for reading
	MOVE.L	A1,-(SP)	;File Name to open
	MOVE.W	#$3D,-(SP)	;Open file
	TRAP	#1
	ADDQ.L	#8,SP	
*
	TST.L	D0		;Error?
	BMI	file_error	;Yep - give up and go home!
*
	MOVE.W	D0,handle	;Store file handle
*
	MOVE.L	A2,-(SP)	;Where to put first 34 bytes
	MOVE.L	#34,-(SP)	;How many bytes to read
	MOVE.W	D0,-(SP)	;Which file?
	MOVE.W	#$3F,-(SP)	;Read
	TRAP	#1
	LEA	12(SP),SP	;Correct stack
*
	TST.L	D0		;Error?
	BMI	file_error	;Yep - Oh well, better luck next time!
*
	MOVE.L	A3,-(SP)	;Where to put last 32000 bytes
	MOVE.L	#32000,-(SP)	;How many bytes to read
	MOVE.W	handle,-(SP)	;Which file?
	MOVE.W	#$3F,-(SP)	;Read
	TRAP	#1
	LEA	12(SP),SP	;Correct stack
*
	TST.L	D0		;Error?
	BMI	file_error	;Yep - Oh well, better luck next time!
*
	RTS
*
****************************************************************
* file_error label handles any file error - not very well, but *
* at least we let the player know that something is wrong!     *
file_error:
	PEA	err1		;Print an error message
	MOVE.W	#9,-(SP)	
	TRAP	#1
	ADDQ.L	#6,SP
*
	MOVE.W	#1,-(SP)	;Get a Keypress
	TRAP	#1
	ADDQ.L	#2,SP
*
	CLR.W	-(SP)		;End the Program
	TRAP	#1
*************************************************************************
* show_blit - A demonstration of the different logical operators when   *
* used with the Blit routine.						*
*************************************************************************
show_blit:
	MOVE.L	screen_2,A0	;Address of Source Screen
	MOVE.L	screen_1,A1	;Address of Destination Screen
	MOVE.W	#0,D0		;Left From
	MOVE.W	#0,D1		;Top From
	MOVE.W	#0,D2		;Left To
	MOVE.W	#0,D3		;Top To
	MOVE.W	#320,D4		;Width
	MOVE.W	#12,D5		;Height
	MOVE.B	#07,D7		;Logical Operation (OR)
* Change the above value to anything from 0-15 to see the other effects.

sb_loop:
	BSR	blit		;Blit it
	ADD.W	#13,D3		;Update Destination Y coordinate
	CMP.W	#194,D3		;Finished?
	BLT.S	sb_loop		;No - Continue round the loop
	RTS
*************************************************************************
* BLIT - Perform a blit from screen to screen. Uses, but preserves	*
* the following registers...						*
* A0 - Address of screen FROM.						*
* A1 - Address of screen TO.						*
* D0 - Left FROM							*
* D1 - Top FROM								*
* D2 - Left TO								*
* D3 - Top TO								*
* D4 - WIDTH								*
* D5 - HEIGHT								*
* D6 - unused								*
* D7 - Logical Operation 						*
*************************************************************************
blit:	MOVEM.L	D0-D7/A0-A6,-(SP)	;Preserve Registers
	LEA	bitblt(PC),A6		;Address of blit table
	MOVE.L	A0,18(A6)		;Store 'From' address
	MOVE.L	A1,32(A6)		;Store 'To' Address
	MOVE.W	D0,14(A6)		;Store Left from position
	MOVE.W	D1,16(A6)		;Store Top from position
	MOVE.W	D2,28(A6)		;Store Left To position
	MOVE.W	D3,30(A6)		;Store Top To position
	MOVE.W	D4,0(A6)		;Store width. 
	MOVE.W	D5,2(A6)		;Store height.
*
low_rez:
	MOVE.W	#4,4(A6)		;Set up Blit variables
	MOVE.W	#8,22(A6)		;for Low resolution
	MOVE.W	#8,36(A6)
*
any_rez:
	MOVE.L	#0,42(A6)		;Set up Blit variables 
	MOVE.B	D7,10(A6)		;for any resolution
	MOVE.W	#0,6(A6)
	MOVE.W	#0,8(A6)
*
	DC.W	$A007			;Do the Blit!
blit_exit:
	MOVEM.L	(SP)+,D0-D7/A0-A6	;Restore registers

	RTS				;and return.
*
*****************************
* Data for the Blit Routine *
*****************************
	EVEN
bitblt:	DC.W	0	;Width
	DC.W	0	;Height
	DC.W	0	;No. Planes
	DC.W	0	;fg_col
	DC.W	0	;bg_col
	DC.B	0,0,0,0	;log. ops
	DC.W	0	;left source x
	DC.W	0	;top source y
	DC.L	0	;Source screen top address
	DC.W	8	;word in line (8=low 4=med)
	DC.W	160	;160 for med/low
	DC.W	2
	DC.W	0	;left dest x
	DC.W	0	;top dest y
	DC.L	0	;dest screen top address
	DC.W	8	;word in line
	DC.W	160	;line in plane
	DC.W	2
	DC.L	0	;Pattern Address
	DC.W	0
	DC.W	0
	DC.W	0
	DS.B	30
*************************
* End of BLIT Data      *
*************************
	EVEN
old_rez:	DC.W	0	;Used to store old screen rez.
*
handle:		DC.W	0	;File Handle
*
screen_1:	DC.L	0	;Address of the screens
screen_2:	DC.L	0	;Address of another screen
*
pic_mode:	DS.W	1	;1 word for picture's mode
palette:	DS.W	16	;16 words for palette
*
* An error message, just in case the program can't find the pictures.
*
err1:		DC.B	27,'E'
		DC.B	'Unable to load necessary file',13,10
		DC.B	'Press a key',0
		EVEN
* The file name of our Source screen. You can change this to hold
* the full pathname if necessary.
src_file:	DC.B	'source.pi1',0
		EVEN
* The file name of our Destination screen
dst_file:	DC.B	'dest.pi1',0
		EVEN
		DS.L	100	;Save some space for the Stack
stack
*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0014.S   *
*  This program should be assembled to disk as PROG0014.PRG or  *
*  PROG0014.TOS. It can then be executed by double-clicking on  *
*  the program file created.					*
*  Note that this program looks for the two Degas format files  *
*  SPRITES.PI1 and BACKGRND.PI1 in the same folder from which   *
*  the program was run.						*
*****************************************************************
* This program differs from PROG0013 simply in that you can use *
* capital or lower case input.					*
*****************************************************************
grid_width	EQU	19	;Define width of grid-1
grid_height	EQU	11	;Define height of grid-1
left_key	EQU	'Z'	;Key to add 'left' bat.
right_key	EQU	'X'	;Key to add 'right' bat.
*
start:	MOVE.L	#stack,SP	;Set up our own stack
	BSR	init		;Initialize everything
main_l:	BSR	disp_ball	;Display the ball on hidden screen
	BSR	swap_screens	;show hidden screen & hide visible screen
	BSR	clear_ball	;erase ball from hidden screen
	BSR	update_ball	;update ball's position
	BSR	input		;get user input
	BSR	update		;Update screen
	CMP.W	#'Q',key	;end if Q pressed
	BEQ.S	finish
	BRA	main_l		Otherwise, loop round
finish:
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
* Get addresses of three screens
	MOVE.W	#2,-(SP)	;XBIOS 2 returns current screen address
	TRAP	#14		;in D0
	ADDQ.L	#2,SP
	MOVE.L	D0,screen_1	;Store as screen 1
	SUB.L	#32000,D0	;Subtract 32000
	MOVE.L	D0,screen_2	;and store as screen 2
	SUB.L	#32000,D0	;Subtract 32000
	MOVE.L	D0,backgrnd	;Store as backgrnd
	SUB.L	#32000,D0	;Subtract another 32000
	MOVE.L	D0,sprites	;Store as sprites
*
* Now load the background screen into memory
	MOVE.L	backgrnd,A3	;Address to load it
	MOVE.L	#back_file,A1	;Address of file name
	MOVE.L	#pic_mode,A2	;Address to store mode/palette
	BSR	PI1_load	;Subroutine to load PI1 files
* Set the colour palette
	PEA	palette
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
*
* Now load the sprite picture into memory
	MOVE.L	sprites,A3	;Address to load it
	MOVE.L	#sprt_file,A1	;Address of file name
	MOVE.L	#pic_mode,A2	;Address to store mode/palette
	BSR	PI1_load	;Subroutine to load PI1 files
*
* Copy the background screen to dual screens
	BSR	 scr_copy

	RTS
*************************************************
* INPUT - See if a key has been pressed, and    *
* deal with it					*
*************************************************
input:	MOVE.W	#$B,-(SP)	;GEMDOS $B - Test keyboard
	TRAP	#1
	ADDQ.L	#2,SP
*
	CLR.W	key
	TST.W	D0		;Key pressed?
	BEQ	in_end		;No - exit
*
in_loop:
	MOVE.W	#8,-(SP)	;GEMDOS 8 - Get Key
	TRAP	#1
	ADDQ.L	#2,SP
*
	CMP.W	#32,D0		;Space Bar pressed?
	BEQ.S	in_loop		;Loop until another key
* Convert to Upper case
	AND.B	#223,D0
	MOVE.W	D0,key		;Save key pressed
*
in_end:	RTS
*************************************************
* UPDATE_BALL - Updates the X and Y coordinates *
* of the ball after saving the 'old' position   *
*************************************************
update_ball:
	MOVE.W	ball_ox,ball_vox	;Store old
	MOVE.W	ball_x,ball_ox		;position of 
	MOVE.W	ball_oy,ball_voy	;ball so we can
	MOVE.W	ball_y,ball_oy		;erase it later
*
	TST.W	ball_dx		;Is ball moving horizontally?
	BEQ	updt_vert	;No - do vertical movement
*
updt_horiz:
	MOVE.W	off_x,D0	;Store current offset in D0
	ADD.W	ball_dx,D0	;Add DX to it
	AND.W	#$F,D0		;Mask right four bits only
	BEQ.S	X_big_jump	;offset = 0
*
	MOVE.W	ball_X,D1	;Get X coord in squares
	LSL.W	#4,D1		;Multiply by 16
	ADD.W	D0,D1		;Add on offset
	MOVE.W	D1,ball_x	;and store as x coord in pixels
	MOVE.W	D0,off_x	;store new offset
	BRA 	updt_end	;End of Update routine
*
X_big_jump:
* The ball has completed a journey between two squares on the grid.
	TST.W	ball_dx		;Test X velocity
	BMI.S	X_left		;Moving left?
X_right:
	MOVE.W	ball_X,D0	;Get X coord in squares.
	ADD.W	#1,D0		;Update
	CMP.W	#grid_width,D0	;Hit edge?
	BEQ.S	X_r_bounce
	MOVE.W	D0,ball_X	;Store new X
	MOVE.W	D0,ball_toX	;Store destination X
	ADD.W	#1,ball_toX	;as square to the right.
	CLR.W	off_x		;and new offset
	BRA	updt_end	;End of Update routine
*
X_r_bounce:
	MOVE.W	#-1,ball_dx	;reverse direction
	MOVE.W	#15,off_x	;start offset at right
	MOVE.W	D0,ball_toX	;store destination X
	SUB.W	#1,ball_toX	;as one square to the left
	BRA	updt_end	;End of Update routine
*
X_left:
	TST.W	ball_X		;Test where we are
	BEQ.S	X_l_bounce	;Bounce if on edge.
*
	SUB.W	#1,ball_X	;Update X
	SUB.W	#1,ball_toX	;and update destination X
	MOVE.W	#16,off_x	;and offset
	BRA	updt_end	;End of Update rouine
*
X_l_bounce:
	MOVE.W	#1,ball_dx
	ADD.W	#1,ball_toX	;update destination X
	BRA	updt_end	;End of Update routine
*
updt_vert:
	MOVE.W	off_y,D0	;Store current offset in D0
	ADD.W	ball_dy,D0	;Add DY to it
	AND.W	#$F,D0		;Mask right four bits only
	BEQ.S	Y_big_jump	;offset = 0
*
	MOVE.W	ball_Y,D1	;Get Y coord in squares
	LSL.W	#4,D1		;Multiply by 16
	ADD.W	D0,D1		;Add on offset
	MOVE.W	D1,ball_y	;and store as x coord in pixels
	MOVE.W	D0,off_y	;store new offset
	BRA	updt_end	;End of Update routine
*
Y_big_jump:
* The ball has completed a journey between two squares on the grid.
	TST.W	ball_dy		;Test Y velocity
	BMI	Y_up		;Moving up?
Y_down:
	MOVE.W	ball_Y,D0	;Get Y coord in squares.
	ADD.W	#1,D0		;Update
	CMP.W	#grid_height,D0	;Hit edge?
	BEQ.S	Y_u_bounce
	MOVE.W	D0,ball_Y	;Store new Y
	MOVE.W	D0,ball_toY	;Store new destionation Y as
	ADD.W	#1,ball_toY	;square below.
	CLR.W	off_y		;Store new offset
	BRA	updt_end	;End of Update routine
*
Y_u_bounce:
	MOVE.W	#-1,ball_dy	;reverse direction
	MOVE.W	#15,off_y	;start offset at right
	MOVE.W	D0,ball_toY	;Update destination Y as
	SUB.W	#1,ball_toY	;square above.
	BRA	updt_end	;End of Update routine
*
Y_up:
	TST.W	ball_Y		;Test where we are
	BEQ.S	Y_b_bounce	;Bounce if on edge.
*
	SUB.W	#1,ball_Y	;Update X
	SUB.W	#1,ball_toY	;and destination Y
	MOVE.W	#16,off_y	;and offset
	BRA	updt_end	;End of Update rouine
*
Y_b_bounce:
	MOVE.W	#1,ball_dy
	ADD.W	#1,ball_toY	;Update destination Y
	BRA	updt_end	;End of Update routine


*
updt_end:
*
	RTS
***********************************************
* UPDATE - Handles updating the screen etc.   *
***********************************************
update:
	CMP.W	#left_key,key 	;Left Key Pressed?
	BNE.S	not_lk		;No - carry on
* Left key pressed.
* Firstly, update the table.
	BSR	calc_indx	;Get index to table
	LEA	squares(PC),A0	;Address of table into A0
	MOVE.B	#1,(A0,D0)	;Put 1 into the byte.
* Now draw the 'bat' sprite.
	CLR.W	D0		;X Coord of sprite in SPRITES screen
	MOVE.W	#16,D1		;Y Coord of sprite in SPRITES screen
	BSR	draw_bat	;Draw the bat!
	BRA	upend		;All done!
not_lk:	CMP.W	#right_key,key	;Right Key Pressed?
	BNE.S	upend
* Right Key Pressed.
* Firstly update the table.
	BSR	calc_indx	;Get index to table
	LEA	squares(PC),A0	;Address of table into A0
	MOVE.B	#2,(A0,D0)	;Put 2 into the byte.
* Now draw the 'bat' sprite.
	MOVE.W	#16,D0		;X Coord of sprite in SPRITES screen
	MOVE.W	#16,D1		;Y Coord of sprite in SPRITES screen
	BSR	draw_bat	;Draw the bat!
upend:	RTS
**************************************************
* CALC_INDX - calculates the index to be used to *
* access the table 'squares' from the ball_toX   *
* and ball_toY values.				 *
* The index is returned in D0.			 *
**************************************************
calc_indx:
	MOVE.W	ball_toY,D0	;Get Y.
	MULU.W	#(grid_width+1),D0 ;and multiply by the width in squares
	ADD.W	ball_toX,D0	;Add on X.
* Calculation is (Y * width) + X
	RTS
*************************************************
* DRAW_BAT - handles drawing a bat on the screen*
* D0 and D1 must be set to the X and Y offsets  *
* of the sprite within the SPRITES screen.      *
*************************************************
draw_bat:
	MOVE.L	sprites,A0	;Address of Sprites screen
	MOVE.L	backgrnd,A1	;Address of background screen
	MOVE.W	ball_toX,D2	;X coord in squares
	MULU.W	#16,D2		;convert to pixels
	MOVE.W	ball_toY,D3	;Y coord in squares
	MULU.W	#16,D3		;convert to pixels
	MOVE.W	#16,D4		;Width
	MOVE.W	#16,D5		;Height
	MOVE.L	#$03030303,D7	;Logical Operation
	BSR	blit
	RTS
*************************************************
***********************************************
* SCR_COPY - Copies 32000 bytes from backgrnd *
* screen to both dual screens.                *
***********************************************
scr_copy:
	MOVE.L	backgrnd,A0	;Address of background screen
	MOVE.L	screen_1,A1	;Address of screen 1
	MOVE.L	screen_2,A2	;Address of screen 2
	MOVE.L	#999,D7		;Loop 1000 times (8 * 4 * 1000 = 32000)
scr_loop:
	MOVEM.L	(A0)+,D0-D6/A3	;Move 8 long words into registers
	MOVEM.L	D0-D6/A3,(A1)	;Move them to screen 1
	MOVEM.L	D0-D6/A3,(A2)	;Move them to screen 2
	ADD.L	#32,A1		;Update pointers to screen
	ADD.L	#32,A2
	DBF	D7,scr_loop	;Loop until D7 less than 0
	RTS
*******************************************************
* disp_ball Displays the ball at its current position *
*******************************************************
disp_ball:
*				;Get x coordinate in D2
	MOVE.W	ball_X,D2	;X position of ball (in squares)
	MULU.W	#16,D2		;Multiplied by 16
	ADD.W	off_x,D2	;Add the offset
	MOVE.W	D2,ball_ox	;And store as old x (in pixels)
*
*				;Get y coordinate in D3
	MOVE.W	ball_Y,D3	;Y position of ball (in squares)
	MULU.W	#16,D3		;Multiplied by 16
	ADD.W	off_y,D3	;Add the offset
	MOVE.W	D3,ball_oy	;And store as old y (in pixels)
*				
	MOVE.L	sprites,A0	;Address of sprite screen in A0
	MOVE.L	screen_2,A1	;Address of screen 2 in A1
	MOVE.W	#0,D0		;Ball sprite is at (0,0)
	MOVE.W	#0,D1
	MOVE.W	#16,D4		;and is 16 x 16 pixels
	MOVE.W	#16,D5
	MOVE.L	#$07070707,D7	;Logical Operation is OR
*
	BSR	blit		;Blit the Ball
	RTS
*

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
****************************************************	
* clear_ball - erases ball from hidden screen      *
* by bliting a sprite-sized square from the        *
* background screen onto the hidden screen.        *
****************************************************
clear_ball:
	MOVE.W	ball_vox,D0	;Very old X coordinate in D0
	MOVE.W	D0,D2		;and D2
*
	MOVE.W	ball_voy,D1	;Very old Y coordinate in D1
	MOVE.W	D1,D3		;and D3
*
	MOVE.L	backgrnd,A0	;Address of background screen in A0
	MOVE.L	screen_2,A1	;Address of screen 2 in A1
	MOVE.W	#16,D4		;width to erase
	MOVE.W	#16,D5		;height to erase
	MOVE.L	#$03030303,D7	;Logical operation 'move'
*
	BSR	blit		;blit
	RTS
************************************************************
* swap_screens - Shows hidden screen and hides visible one *
************************************************************
swap_screens:
*
	MOVE.W	#37,-(SP)	;XBIOS 37 - wait for Vsync
	TRAP	#14
	ADDQ.L	#2,SP
*
	MOVE.L	screen_1,D0	;Address of screen 1 in D0
	MOVE.L	screen_2,D1	;Address of screen 2 in D1
	MOVE.L	D0,screen_2	;Swap 'em
	MOVE.L	D1,screen_1
	MOVE.W	#-1,-(SP)	;Don't change resolution
	MOVE.L	D1,-(SP)	;change logical screen
	MOVE.L	D0,-(SP)	;change physical screen
	MOVE.W	#5,-(SP)	;using XBIOS 5
	TRAP	#14
	LEA	12(SP),SP
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
screen_1:	DC.L	0	;Address of one screen
screen_2:	DC.L	0	;Address of another screen
backgrnd:	DC.L	0	;Address of backgrnd screen
sprites:	DC.L	0	;Address of sprite data
*
pic_mode:	DS.W	1	;1 word for picture's mode
palette:	DS.W	16	;16 words for palette
*
*
ball_X:		DC.W	2	;X Coordinate of Ball(in squares)
ball_x:		DC.W	32	;X coordinate of Ball(in pixels)
ball_ox:	DC.W	32	;Last X Coordinate of Ball(in pixels)
ball_vox:	DC.W	32	;Last but one Coordinate of ball(in pixels)
ball_toX	DC.W	3	;Destination X coordinate(in squares)
*
ball_Y:		DC.W	10	;Y Coordinate of Ball(in squares)
ball_y:		DC.W	16	;Y coordinate of ball(in pixels)
ball_oy:	DC.W	16	;Last Y Coordinate of Ball(in pixels)
ball_voy:	DC.W	16	;Last but one Y Coordinate of ball(in pixels)
ball_toY	DC.W	10	;Destinatino Y coordinate(in squares)
*
off_x:		DC.W	0	;x coordinate offset of ball in pixels
off_y:		DC.W	0	;y coordinate offset of ball in pixels
*
ball_dx:	DC.W	1	;x speed of ball(1,0 or -1)
ball_dy:	DC.W	0	;y speed of ball(1,0 or -1)
*
key		DC.W	0	;The key just pressed


*
* An error message, just in case the program can't find the pictures.
*
err1:		DC.B	27,'E'
		DC.B	'Unable to load necessary file',13,10
		DC.B	'Press a key',0
		EVEN
* The file name of our Source screen. You can change this to hold
* the full pathname if necessary.
back_file:	DC.B	'BACKGRND.PI1',0
		EVEN
* The file name of our Destination screen
sprt_file:	DC.B	'SPRITES.PI1',0
		EVEN
squares		DS.B	(grid_width+1) * (grid_height+1)
		DS.L	100	;Save some space for the Stack
stack:



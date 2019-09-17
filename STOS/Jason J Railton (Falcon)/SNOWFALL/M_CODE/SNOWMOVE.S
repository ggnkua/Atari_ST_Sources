**************************************************************************
*                                                                        *
*    Snow fall source code, by Jason J Railton for ICTARI user group.    *
*                                                                        *
*                            12 December 1996                            *
*                                                                        *
**************************************************************************

*NOTE: This progam CANNOT work on its own.  You MUST work it in as a
*subroutine to your code.

*I prefer to assemble this code as 'SNOWMOVE.PRG', then load it into a STOS
*memory bank.  Then you simply call it with the following lines of BASIC:

*	areg(0)=physic
*	call 15

*This is for the program in bank 15 (use: LOAD "SNOWMOVE.PRG",15) and
*operating on the PHYSIC screen.  You could use PHYSIC, BACK, LOGIC or
*even START(10) for example, if bank 10 is reserved as a screen.


*This code will move any pixel drawn in the fourth bit plane (i.e. in
*colour 8) down the screen one pixel, if there is nothing immediately below it.
*it. If there is an obstruction, it may move diagonally down and to the
*right or left, again if it is not obstructed.  Anything drawn in any 
*colour other than 0 counts as an obstruction, so colour 8 pixels  will
*pile up and flow down other colour 8 pixels.

*Note that anything drawn in colours 9-15 will also count.  The value of 8
*will drop away as a colour 8 pixel, leaving the pixel's colour reduced by
*a value of 8. 


start
	move.l	a0,a1		|The screen address should be in a0 on
	move.l	a0,a2		|entry.
	add.w	#31838,a1	|Last word (colour 8 plane) of line 198.
	add.w	#31984,a2	|Last 16 bytes (last 32 pix) on screen.
	
	move.w	#3978,d0	|199_lines * 20_columns - 1_column - 1
*				|(Counter is 1 less than required)


*The last column (ie 16-pixel wide block) of the last line is done
*initially on its own, to start off the routine.  Some data (the current
*and next masks) are passed from one cycle to the next, so the first
*step is to prepare initial values:

first_word
	move.w	(a2)+,d2	|
	or.w	(a2)+,d2	|
	or.w	(a2)+,d2	|Make a mask in d2 of 16 pixels from
	or.w	(a2)+,d2	|address a2.

	move.w	(a2)+,d3	|
	or.w	(a2)+,d3	|
	or.w	(a2)+,d3	|
	or.w	(a2),d3		|Make a mask from next (last) 16 pixels.
	subq.w	#6,a2

	move.w	(a1),d1		|Get colour 8 snow from the line above.
	

	move.w	d3,d5		|Invert the mask from below the snow, to
	not.w	d5		|find the holes in it.
	and.w	d1,d5		|Match the snow to the holes.
	or.w	d5,d3		|Add the moved snow to the mask...
	or.w	d5,6(a2)	|...and to the screen.
	
	not.w	d5		|Invert the moving snow...
	and.w	d5,d1		|and cut it from the original snow.
	

	swap	d1		|Put the original snow high.
	clr.w	d1		|Clear the rest of the long word...
	ror.l	#1,d1		|...and shift the snow to the right.
	
	swap	d3		|Put the mask high.
	move.w	#$ffff,d3	|Fill the rest of the long word.

	move.l	d3,d5		|
	not.l	d5		|
	and.l	d1,d5		|Isolate any snow which can now fall.
	
	move.l	d5,d6		|Copy it...

	or.l	d5,d3		|Add it to the mask...
	swap	d5		|
	or.w	d5,6(a2)	|...and to the screen.

	not.l	d6		|
	and.l	d6,d1		|Then cut it from the original snow.
	
	
	swap	d1		|Put the snow back low, and
	rol.l	#2,d1		|shift it left.
	
	move.w	d2,d3		|Put the mask from the left with the mask
	swap	d3		|from below, in order.

	move.l	d3,d5		|
	not.l	d5		|
	and.l	d1,d5		|Isolate snow which can now fall.
	
	move.l	d5,d6		|Copy it.

	or.l	d5,d3		|
	or.w	d5,6(a2)	|Put it in the mask...
	swap	d5		|
	or.w	d5,-2(a2)	|...and on the screen.

	not.l	d6		|
	and.l	d6,d1		|Cut it from the original snow.
	ror.l	#1,d1		|Re-align any remaining snow...
	move.w	d1,(a1)		|...and put it back on screen.
	

	sub.w	#8,a1		|Move back through the
	sub.w	#16,a2		|screen memory.
	
	move.w	d3,d4		|This puts the current mask (from d3)
	swap	d3		|into the right-hand mask (d4), and the
*				|mask from the left (d2) in d3, ready for
*				|the next 16 pixels.


loop
	move.w	(a2)+,d2	|Now, we only have to obtain the mask to
	or.w	(a2)+,d2	|the left of the current column.  The
	or.w	(a2)+,d2	|central and right-hand masks come in d3
	or.w	(a2)+,d2	|and d4 from the previous cycle.

	move.w	(a1),d1		|Get snow.
	
	move.w	d3,d5		|Move some straight down...
	not.w	d5
	and.w	d1,d5
	or.w	d5,d3
	or.w	d5,6(a2)	

	not.w	d5
	and.w	d5,d1	
	

	swap	d1		|Move some down and to the right...
	clr.w	d1
	ror.l	#1,d1
	
	swap	d3
	move.w	d4,d3		|This is the only change from the first
*				|block.  This uses the mask from below
*				|the snow (d3) with the same mask from
*				|the previous cycle (d4).

	move.l	d3,d5
	not.l	d5
	and.l	d1,d5

	move.l	d5,d6
	
	or.l	d5,d3
	or.w	d5,14(a2)
	swap	d5
	or.w	d5,6(a2)
	
	not.l	d6
	and.l	d6,d1
	
	
	swap	d1		|Down and to the left...
	rol.l	#2,d1
	
	move.w	d2,d3
	swap	d3

	move.l	d3,d5
	not.l	d5
	and.l	d1,d5

	move.l	d5,d6	

	or.l	d5,d3
	or.w	d5,6(a2)
	swap	d5
	or.w	d5,-2(a2)

	not.l	d6
	and.l	d6,d1
	ror.l	#1,d1
	move.w	d1,(a1)		|What's left goes back on screen.
	
	sub.w	#8,a1		|
	sub.w	#16,a2		|Move back through the screen.
	
	move.w	d3,d4		|
	swap	d3		|Store masks for next cycle.


	dbf	d0,loop
	
	rts


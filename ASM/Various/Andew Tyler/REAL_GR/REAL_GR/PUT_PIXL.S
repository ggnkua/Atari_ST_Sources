* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991  put_pixl.s                              *
* A program to plot a pixel using the Line A routine number $a001 *
* with the minimum of fuss. Pull the plug to stop it.             *
* The system takes care of the screen resolution.                 *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

*	SECTION TEXT

put_pix:	
* Initialization: get the pointer to the Line A Variable Structure.
	dc.w	$a000		set up the Line A table pointer
* The address of the table is in a0. Get the pointers to the arrays.
	move.l	8(a0),a4	pointer to intin array
	move.l	12(a0),a5	pointer to ptsin array
* Enter the x and y coordinates of the pixel in screen coordinates.
	move.w	#200,(a5)	x = 200, first ptsin word
	move.w	#100,2(a5)	y = 100, second ptsin word
* Set the colour number - only the lowest bit works in high resolution.
* In low resolution this is the standard palette no. for red.
	move.w	#1,(a4)		colour red, first intin word
* Set the pixel
	dc.w	$a001		Line A Put Pixel 
	bra	put_pix		repeat
	
	END


		opt	a+		


USE_BACKGROUND	equ	0			* Define this for background picture
*DISPLAY_VSYNC	equ	0			* Define this for CPU time border indication


PALETTE_0	equ	$ff8240

NUMLINES	equ	4			* Number of lines of characters on the DEGAS screen
CHPERLINE	equ	20			* Number of characters per line on the DEGAS screen
NUMCHARS	equ	NUMLINES*CHPERLINE 	* Total number of characters in the DUOASCII font

SIZECHAR	equ	4*16*4			* Size of one shifted character
SIZESHIFTEDSET	equ	SIZECHAR*NUMCHARS 	* Size of one shifted set

		section	data

wafflement:	
	dc.b	"RIGHT THEN     OFF WE GO!          "
	dc.b	"THIS IS ANOTHER MENU FROM DODGYSOFT!          DO YOU THINK THIS SCROLLTEXT IS A BIT SLOW?     IF YES "
	dc.b	"PRESS 'Y' IF NO PRESS 'N'....................................WELL! MORE OF YOU PRESSED 'Y' SO HERE WE GO!                    ~2     "
	dc.b	"     DODGYSOFT ARE:-     DODGY KING,     DODGY QUEEN,     ROYAL JESTER     AND     BROKEN LANCE.     "
	DC.B	"CREDTIS GO TO:-          DODGY KING (FOR THE CODE AND FONT),     DODGY QUEEN (FOR THE MUSIC RIPPING),     "
	DC.B	"BROKEN LANCE (FOR THE GRAPHICS)......           WE MUST SPEED THIS THING UP AGAIN!     DUE TO THE AMOUNT OF PEOPLE THAT PRESSED 'Y' (FOR THE SPEED)                        ~3          "
	DC.B	"IT'S EGO TRIP TIME!          GREETZ GO TO :-          CAPTAIN WIBBLE,          AUTOMATION,          THE MEDWAY BOYS,          THE REPLICANTS,          THE EMPIRE,          "
	DC.B	"HOTLINE,          BBC,          FCC          AND          YOU!.....            "	
	dc.b	0			
		
waffle_end:	dc.b	0

		section	data
		
waffle_codes:	dcb.w	0,4096		* Character offset buffer

		section	text

start:		bsr	setup		* Load in the font and picture and set the palette
		bsr	shiftfont	* Preshift the font data
		lea	wafflement,a0	* Convert the text to offsets
		lea	waffle_codes,a1
		bsr.s	conv_text
		bsr.s	testshift	* Do the shift
		bsr	clearup

		* Return with zero error code

		clr	-(sp)
		move	#$4c,-(sp)
		trap	#1

*****************************************************************
* Convert the string at a0 to a list of character offsets at
* a1. The following control codes are currently recognized :
*
*	0 	: End of string
*	~n 	: Set scroll speed to n pixels per frame (1-9)
*
* Coming soon perhaps : (well, you never know !!!)
*
*	~-	: Upside down text
*	~+	: Upside up text
*	~~	: Oscillating text
*	~-	: Non-oscillating text
*
*****************************************************************

conv_text:	
		move	#CHPERLINE-1,d0
clr_starttxt:	clr	(a1)+		* Fill the end up with spaces
		dbra	d0,clr_starttxt

		moveq	#0,d0
convert:	move.b	(a0)+,d0
		beq.s	conv_exit
		cmp.b	#'~',d0
		beq.s	control_code
		
		sub	#' ',d0
		mulu	#SIZECHAR,d0
		move	d0,(a1)+
		bra.s	convert
		
conv_exit:	move	#CHPERLINE-1,d0
clr_endtxt:	clr	(a1)+		* Fill the end up with spaces
		dbra	d0,clr_endtxt
		move	#-1,(a1)
		rts
		
control_code:	move.b	(a0)+,d0
		cmp.b	#'1',d0
		blt.s	convert
		cmp.b	#'9',d0
		bgt.s	convert
		
		move.b	#-1,(a1)+
		sub	#'0',d0
		move.b	d0,(a1)+
		bra.s	convert
		
*****************************************************************
*****************************************************************

testshift:	* Test routine to display a single charactradiddle
		
		pea	scroll_demo
		move	#38,-(sp)
		trap	#14
		lea	6(sp),sp
		rts
		
		section	data
		
current_waffle:	dc.l	0
scroll_speed:	dc.w	2

		section	text
		
scroll_demo:	move.l	#waffle_codes,current_waffle	* Initialise text start
next_scroll:	moveq	#0,d4				* Shift position

nextshift:	move.l	current_waffle,a6			* Text to display (list of offsets)
		move.l	screenbase,a5			* Where to put it
		add.l	#160*(200-16),a5 			* Bottom area of screen
		move	#19-1,d7				* Number of characters across screen
		moveq	#0,d5				* Character position

		ifd	DISPLAY_VSYNC
 	        move.w	#0,PALETTE_0			* Black border
 		endc
		
		move.l	a5,a0			* Display address
.skip_ctrl:	move	(a6)+,d0			* Offset of 1st char to display
		blt.s	.skip_ctrl
		move	d4,d1			* Shift size
		bsr	put_1st_char		* Display 1st character
		
disp_chars:	move.l	a5,a0			* Display address
		move	d5,d6			* Char posn.
		addq	#1,d5			* Inc for next time
		lsl	#3,d6			* Make pos an offset
		add	d6,a0			* and add to screen addr
		
.skip_ctrl:	move	(a6)+,d0		* Get char to display
		blt.s	.skip_ctrl
		move	d4,d1			* Shift position
		bsr.s	put_char		* Display character
		dbra	d7,disp_chars		* Next character
	
		move.l	a5,a0			* Display address
		move	d5,d6			* Char posn.
		addq	#1,d5			* Inc for next time
		lsl	#3,d6			* Make pos an offset
		add	d6,a0			* and add to screen addr
do_last_char:		
		move	(a6)+,d0		* Get char to display
		blt.s	check_ctrl		* -ve = control code
		
		move	d4,d1			* Shift position
		bsr	put_last_char		* Display character		
		
		ifd	DISPLAY_VSYNC
	        move	 #$777,PALETTE_0	* White border
		endc
		
		move	#37,-(sp)		* Wait for vsync
		trap	#14
		lea	2(sp),sp
			
		add	scroll_speed,d4
		cmp	#16,d4
		blt.s	nextshift		* Next shift posn
		
		move.l	current_waffle,a0
.skip_ctrl	addq.l	#2,a0
		tst	(a0)
		blt.s	.skip_ctrl
		move.l	a0,current_waffle
		
		bra.s	next_scroll		* Do it all again
		
check_ctrl:
		cmp	#-1,d0
		beq.s	exit_scroll

		move	#1,d2
		ext	d0
		lsl	d0,d2
		move	d2,scroll_speed		* New scroll speed
		bra.s	do_last_char
		
exit_scroll:	rts

*****************************************************************
* Test routine to display the charcter whose offset is in D0 at 
* address A0 on the screen, shifted sidewardsly by D1 pustules
*
* Register Usage : A0-A2/D0-D1
* 
*****************************************************************

		section	data
		
set_offsets:	dc.l	0*SIZESHIFTEDSET
		dc.l	1*SIZESHIFTEDSET
		dc.l	2*SIZESHIFTEDSET
		dc.l	3*SIZESHIFTEDSET
		dc.l	4*SIZESHIFTEDSET
		dc.l	5*SIZESHIFTEDSET
		dc.l	6*SIZESHIFTEDSET
		dc.l	7*SIZESHIFTEDSET
		dc.l	8*SIZESHIFTEDSET
		dc.l	9*SIZESHIFTEDSET
		dc.l	10*SIZESHIFTEDSET
		dc.l	11*SIZESHIFTEDSET
		dc.l	12*SIZESHIFTEDSET
		dc.l	13*SIZESHIFTEDSET
		dc.l	14*SIZESHIFTEDSET
		dc.l	15*SIZESHIFTEDSET

		section	text
		
put_char:	lea	(font).l,a1	* Start of font data
		lea	set_offsets,a2	* Offsets for each shift
		lsl	#2,d1		* Get offset into offset table
		add.l	(a2,d1),a1	* Add start address of shifted font
		add	d0,a1		* Add it onto the start address
		
		lea	8(a0),a0
		
		rept	16
					*Do each plane of one row
		move	(a1)+,d1
		or	d1,-8(a0)
		move	(a1)+,(a0)+
		move	(a1)+,d1
		or	d1,-8(a0)
		move	(a1)+,(a0)+
		move	(a1)+,d1
		or	d1,-8(a0)
		move	(a1)+,(a0)+
		move	(a1)+,d1
		or	d1,-8(a0)
		move	(a1)+,(a0)+
		
		* Move to the next row
		lea	160-8(a0),a0
		endr
		
		rts
		

*****************************************************************
* Put the leftmost character on the screen.
* Displays the character with offset D0 at A0 on the screen, shifted
* by D1
*
* Register Usage : A0-A2/D0-D1
* 
*****************************************************************

put_1st_char:	lea	(font).l,a1	* Start of font data
		lea	set_offsets,a2	* Offsets for each shift
		lsl	#2,d1		* Get offset into offset table
		add.l	(a2,d1),a1	* Add start address of shifted font
		add	d0,a1		* Add it onto the start address
		
		rept	16
		 			* Do each plane of one row
		lea	2(a1),a1	* Skip all upper words
		move	(a1)+,(a0)+	* Do lower word as usual
		lea	2(a1),a1
		move	(a1)+,(a0)+
		lea	2(a1),a1
		move	(a1)+,(a0)+
		lea	2(a1),a1
		move	(a1)+,(a0)+
		
		 			* Move to the next row
		lea	160-8(a0),a0
		endr
		
		rts

*****************************************************************
* Put the rightmost character on the screen.
*
* Displays the charcter whose offset is in D0 at 
* address A0 on the screen, shifted sidewardsly by D1 pustules
*
* Register Usage : A0-A2/D0-D1
* 
*****************************************************************

put_last_char:	lea	(font).l,a1	* Start of font data
		lea	set_offsets,a2	* Offsets for each shift
		lsl	#2,d1		* Get offset into offset table
		add.l	(a2,d1),a1	* Add start address of shifted font
		add	d0,a1		* Add it onto the start address
		
		rept	16
		 			* Do each plane of one row
		move	(a1)+,d1	* Do upper words as normal
		or	d1,(a0)+
		lea	2(a1),a1	* But skip lower ones
		move	(a1)+,d1
		or	d1,(a0)+
		lea	2(a1),a1
		move	(a1)+,d1
		or	d1,(a0)+
		lea	2(a1),a1
		move	(a1)+,d1
		or	d1,(a0)+
		lea	2(a1),a1
		
		 			* Move to the next row
		lea	160-8(a0),a0
		endr
		
		rts

*****************************************************************
* Preshift the font data, slightly converting it's format in the 
* process.
*****************************************************************

shiftfont:	lea	(our_font).l,a2	* DEGAS screen of font
		lea	(font).l,a1	* Preshifted font data area

		moveq	#0,d3		* For quick unsigned word->long extension
	
		move	#NUMLINES-1,d0	* # of lines of chars

do_charline:	move	#CHPERLINE-1,d1	* # of chars per line
	
nextchar:	move.l	a2,a0		* Working pointer to character
		move	#16-1,d2	* # of lines
	
					* Do one line of the character
	
storechar:	move	(a0)+,d3	* Convert 4 planes of
		move.l	d3,(a1)+	* words into
		move	(a0)+,d3	* 4 planes
		move.l	d3,(a1)+	* of longs
		move	(a0)+,d3	* with the
		move.l	d3,(a1)+	* upper
		move	(a0)+,d3	* word set
		move.l	d3,(a1)+	* to zero
	
		lea	160-8(a0),a0	* Next line
		dbra	d2,storechar
	
		lea	8(a2),a2	* Next word on screen
			
		dbra	d1,nextchar	* Do the next character on the line
		
		lea	160*15(a2),a2	* Move to the top of the next line of characters
	
		dbra	d0,do_charline	* And do dem as well
	

		* Now shift the data
	
		lea	(font).l,a2		* Pointer to unshifted set
		move	#NUMCHARS*SIZECHAR-1,d1	* Number of longs in set
	
shiftset:	move	#15-1,d0		* Number of shifts to do
		move.l	a2,a0			* A0=working pointer

		move.l	(a0),d2			* Get a line of a character
shiftlong:	lsl.l	d2			* Shift it
		lea	NUMCHARS*SIZECHAR(a0),a0	* Move to the next shifted set along
		move.l	d2,(a0)			* Store the line
		dbra	d0,shiftlong		* and do the next longword of the set
	
		lea	4(a2),a2			* Move to next long in unshifted set
		dbra	d1,shiftset		* and shift THAT one along
	
		rts
	
*****************************************************************
* Set up the screen, saving the old parameters.			*
*****************************************************************

setup:		* Get the current resolution
	
		move	#4,-(sp)
		trap	#14
		lea	2(sp),sp
		move	d0,old_resolution
	
		* Get the current screen address

		move	#2,-(sp)
		trap	#14
		lea	2(sp),sp
		move.l	d0,screenbase

		* Set low-res mode and the screen location

		clr	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move	#5,-(sp)
		trap	#14
		lea	12(sp),sp

		ifd	USE_BACKGROUND
		
		* Zonk the screen from the data section to the real screen like an happen
	
		lea	 our_screen,a6
		move.l	 screenbase,a5
		move	 #32000/4/4-1,d0
	
.zonkscreen:	movem.l	(a6)+,a0-a3
		move.l	 a0,(a5)+
		move.l	 a1,(a5)+
		move.l	 a2,(a5)+
		move.l	 a3,(a5)+
		dbra	 d0,.zonkscreen
	
		* Save the current palette and put our new one in

		bsr.s	 swappal

		endc
		
		rts
	
*****************************************************************
* Restore the old resolution, screen address and palette	*
*****************************************************************

clearup:	* Set original screen mode and location

		move	old_resolution,-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move	#5,-(sp)
		trap	#14
		lea	12(sp),sp

		ifd	DISPLAY_BACKGROUND
		
		* Restore the original palette

		move	 #$777,our_palette	* Tomb of the unknown bodgecode
		pea	 our_palette
		move	 #6,-(sp)
		trap	 #14
		lea	 6(sp),sp

		endc
		rts
	
**********************************************************************
* Swap the current and saved palettes over
**********************************************************************

swappal:	pea	wibblepalette
		move	#$26,-(sp)
		trap	#14
		lea	6(sp),sp
		rts
	
wibblepalette:	lea	(PALETTE_0).l,a0
		lea	our_palette,a1
		move	#15,d0
.storepal:	move	(a0),d1
		move	(a1),(a0)+
		move	d1,(a1)+
		dbra	d0,.storepal
		rts

**********************************************************************
**********************************************************************

		section	data

screenbase:		dc.l	0
old_resolution: 	dc.w	0

picture:	incbin	'A:\PIC.PI1'
fontpic:	incbin	'A:\FONT.PI1'

our_screen	equ	picture+34
our_font	equ	fontpic+34
our_palette	equ	picture+2

**********************************************************************
**********************************************************************


		section	bss
		
font:		ds.l	SIZECHAR*NUMCHARS*4	* 96 chars, 16 lines, 16 copies, 4 planes


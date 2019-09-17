
	ttl	'Calamus Font Demo Program by Peter Hibbs'

;This code was first published in ICTARI disk magazine March 1995.
;
; This program is a simple demonstration program for the Calamus Font
; display routines. It just displays the letters A-Z across the centre
; of the screen, each chr size increased by 4 points. The relevant code is
; in the 'main' sub-routine, the rest is a standard GEM shell program.
;
; In this example (to keep it simple) the font file is included as a binary
; file with the 'incbin' pseudo-op although a practical program would
; probably load the required font file/s into a memory buffer first.
;
; For the same reason the font routines themselves are also 'included'
; although in a practical program it would be better to import the source
; code into the program source code because some of the routines or
; RAM buffers can be omitted (depending on the methods used to display
; the font characters).
;
; This version is set up to operate in high resolution. To use in a colour
; mode the values marked (** LR/MR nn) should be changed, i.e. if in low rez
; change the value marked with (**LR=125) to 125.
;  Thus  the instruction:-    move   #250,d0  (** LR=125)
;          would become :-    move   #125,d0
; It won't matter much if you don't, the screen will be just messed up a bit.
; If colour modes are being used, try changing the last two parameters
; in the vrt_cpyfm function in the 'show_char' sub-routine.


	include	gemmacro.i	use HiSoft Macros

;The program proper

start_of_pgm	move.l	4(sp),a3	base page
	move.l	#stack,sp	move SP
	move.l	12(a3),d0	text len
	add.l	20(a3),d0	data len
	add.l	28(a3),d0	BSS len
	add.l	#256,d0	basepage

	move.l	d0,-(sp)	shrink memory
	move.l	a3,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	appl_init		initialise application
	move	d0,ap_id	and store the app ident
	graf_handle		fetch graf handle code
	move	d0,current_handle  and store VDI handle

	lea	intin,a0	initialise intin array
	moveq	#10-1,d0	
shell1	move	#1,(a0)+	most params are 1
	dbra	d0,shell1
	move	#2,(a0)+	use RC system
	v_opnvwk		open work station
	v_hide_c		hide mouse
	v_clrwk		clr screen
	vs_clip	#1,#0,#0,#639,#399
	vsl_color	#1

shell2	bsr	main	run main program

	v_show_c	#0	show mouse
shell3	v_clsvwk		close workstation
	appl_exit		close application

	clr	-(sp)	status code
	move	#$4c,-(sp)	P_TERM
	trap	#1	exit pgm


;--------------------- Main program sub-routine ------------------------

main	

;Display font name in bit image mode (just to check it works).

	lea	font_buffer,a0	display font name
	move	#200,d0	(** LR=125)
	move	#10,d1
	bsr	show_image


;Initialise registers. d7=initial start letter (A). d6=initial point size (4).
;                      d5=initial x co-ord (0).     d4=y co-ord (200 or 100).

	move	#'A'-32,d7	initial letter=A
	move	#4,d6	initial point size=4
	move	#0,d5	initial x co-ord=0
	move	#200,d4	initial y=100 (** LR/MR=100)

;Calculate divide value from current point size and screen resolution.
;Copy result into d2.

main1	move	font_buffer+$1d6,d2  fetch top-bottom diff
	mulu	#72,d2	     multiply by point/inch
	divu	#80,d2	     divide by scrn res
	and.l	#$ffff,d2
	divu	d6,d2	     divide by point size

;Calculate chr cell height and width, top offset, base line offset 
;& chr count. d2 copied to (font_size) for divide value.

	move	d2,font_size	     copy to scale store
	lea	font_buffer,a0	     set variables
	bsr	calc_top
	
;This section clears the new image buffer to zero.
;(font_height) and (char_width) set up by 'calc_top'

	lea	img_buff,a1	locate image buffer
	bsr	clr_buffer	and clear it
		
;Generate the image in the img_buff RAM buffer.

	move.l	#img_buff,chr_addr
	bsr	make_image	make chr image
	tst	d0
	bne	exit	abort if error

;Fetch and calculate x and y co-ordinates and display character image.

	lea	img_buff,a0	locate image data
	move	d5,d0	set x co-ord
	move	d4,d1	calc y co-ord
	sub	base_line,d1	allow for baseline offset
	bsr	blit_char	and display chr

;Change variables for next character in sequence.

	add	#4,d6	inc point size by 4

	move	img_buff+6,d0	calc next x co-ord (no kerning)
	sub	img_buff+4,d0	d0=chr width
	add	d0,d5	add to current x co-ord
	add	#2,d5	add 2 to give small gap
	
	add	#1,d7	inc chr code
	cmp	#'Z'-32+1,d7	all done
	bne	main1	loop if not
	
	move	#2,-(sp)	wait for any keypress
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp

exit	rts		& exit program

; Main Calamus font routines included here.

	include	L:\ROUTINES\CFN_CODE.S
		
	SECTION	data	global constants

;Calamus Font file included here as a binary file but would probably
;be loaded from disk into a buffer in a normal program. Make sure font
;used has the characters A-Z.

font_buffer	incbin	G:\CALAMUS\FONTS\ADVERT.CFN	select reqd font and path
	
	SECTION	bss	temporary data

ap_id	ds.w 	1	application ident
	ds.l	100	stack space (400 bytes)
stack	ds.w	1	(stacks go backwards)

	include	aeslib.s	use HiSoft libraries
	include	vdilib.s

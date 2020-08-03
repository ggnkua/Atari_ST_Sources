*	INCLUDE 4  November 23, 1989
*---------------------------------------------------------------*
* FNT_8 (16)	Camy's font routine
* SET_SCREEN	trap 14 call
* LEAD_ZERO	Kane's erase leading zeroes
* VERT		Gareth's vertical screen scroll (selected planes)
* JEFF_SCROLL	adapted from Jeff Lawson's super fast vertical scroll
*---------------------------------------------------------------*
* access to font routines [ C. Maertens March 88 ]
* after a DC.W $A000 call, A0 returns a pointer to A-line variables
* which I stored in a_line_start
* while A1 returns address of 3 system fonts
* this routine expects the address of customized font data in A1
* otherwise a zero (L) must be passed in A1 to use system font.
* in this routine here, A0  points to font header (not A-line)
* A4 will point to A-line
* the fonts used are a1 or a2 fonts as defined by Jeremy Hughes
* in his Fontkit PD program: 2096 bytes in mono, 4116 in color
* there is a routine in ST World Dec 88 that will copy system font
* to a soft location and change a single character and
* commute between rom and soft font
* we now have a macro that will handle this routine!
* Full example in Shell.s and all Budgie games

fnt_8	move.l	fontaddress_8,a0	$fc96ca/fd2ca6 tos8/9
	bra	fnta
fnt_16	move.l	fontaddress_16,a0	$fc9cce/fd3702 tos8/9
fnta	move.l	a_line_start,a4	$293a /2994?
	suba.l	#6,a4		deduct 6 bytes (why?)
	move.w	$52(a0),d0	height of character (82 dec in the header)
	move.w	d0,-$28(a4)	merken?
	move.w	$8(a4),d1	bytes per screen line
	mulu	d0,d1		times height of character
	move.w	d1,-$22(a4)	yields bytes per line
	moveq	#0,d1		
	move.w	$2(a4),d1	raster lines on screen
	divu	d0,d1		divide by font height
	subq.w	#1,d1		minus
	move.w	d1,-$24(a4)	yields max cursor line
	moveq	#0,d1
	move.w	-6(a4),d1	screen width in bits
	divu	$34(a0),d1	divide by max char width
	subq.w	#1,d1		minus 1
	move.w	d1,-$26(a4)	yields max cursor column
	move.w	$50(a0),-8(a4)	width of form
	move.w	$24(a0),-$a(a4)	smallest ascii code in font
	move.w	$26(a0),-$c(a4)	largest
	cmp.l	#0,a1		if zero, use standard data
	beq	fnt1a		
	move.l	a1,-$10(a4)	else use mine
	bra	fnt2a
fnt1a	move.l	$4c(a0),-$10(a4)	standard data
fnt2a	move.l	$48(a0),-$4(a4)	pointer to offset table
	rts
a_line_start  dc.l 0
fontaddress_8	dc.l 0
fontaddress_16	dc.l 0
* there is a macro called font 8  (font 16) that will activate
* any font previously loaded. See shell.s for full details
*---------------------------------------------------------
* a font is 4096 bytes in hi-res (256 characters * 16 lines)
* 512 bytes * 8 sectors = 4096
* the first 256 bytes cover the top line of the 256 characters,
* the next 256 bytes cover the next scan line etc..
* IMG files are 32*32
*--------------------
set_screen
	move.w	d0,-(sp)		;do a set_screen operation
	move.l	a0,-(sp)		;rez in d0
	move.l	a0,-(sp)		;base addr in a0
	move.w	#5,-(sp)		;sets logbase and physbase
	trap	#14
	add.l	#12,sp
	rts
*------------
res_mem
	move.l	d0,-(sp)		;reserve memory
	move.w	#$48,-(sp)		;amount in d0
	trap	#1
	addq.l	#6,sp
	rts
*------------
* edit a string of ASCII decimal characters by replacing
* leading zeroes with blanks    [ G.Kane 1986 ]
* string to be edited expected in A0 (L) (or pointer?)
* length of string expected in D2
* examples in Speculator and Final Lap
lead_zeroes
char_0	equ	'0'
blank_sp	equ	' '
	movem.l d0-d2/a0,-(sp)
	moveq	#char_0,d0	initialize with ascii 0
	moveq	#blank_sp,d1	same
	tst.w	d2
	beq.s	lead9		if length =0 then done	
	subq.w	#1,d2		adjust ctr for dbra
lead1	cmp.b	(a0)+,d0		is current char zero?
	bne.s	lead9
	move.b	d1,-1(a0)		replace zero with blank
	dbra	d2,lead1
lead9	movem.l	(sp)+,d0-d2/a0
	rts
* see examples in shell.s  in speculator, final lap and moneyspinner
* used for scores, time and other numeric variables
* usually called prior to printing an ascii value on screen
*------------
* adapted from JL's vertical scroll routine  [ January 1989 ]
* Full working example in 'Operation Angelica' and 'Sea King'
* address of variables block expected in A6
* image_start in -12 (L)  logical_screen in -8  physical_screen in -4
* scroll_index in 0    scroll_direction in +2   image_size-200 in +6 (w)
* scroll_stepper in scroll_stepper (w)
* weird effects when origin and destination are same or nearby 
* see end of this section
jeff_scroll
main_loop
	movea.l	logical_screen,a0	logical screen to write to
	add.l	#20*160,a0	sea king line ONLY
	movea.l	image_start,a1	origin screen (image start)
	move	scroll_index,d0		the pointer along the origin (1 line a time)
	bsr	scroll_120	120 bytes wide (3/4 screen wide)
* at this point we	bsr	toggle_screens
	rts			(bra	main_loop )
*-------------------------------	
scroll_120
	movem.l	d1-d7/a2-a6,-(a7)	save registers
	mulu #160,d0 
	adda.l	d0,a1		final start address
	move.l	a1,image_position	store for subsequent use
	move	#163-1,-(a7)  	number of lines on screen (normally 199)
scroll_frame_lp2
	movem.l	(a1)+,d0-d7/a2-a6	52 bytes
	movem.l	d0-d7/a2-a6,(a0)
	movem.l	(a1)+,d0-d7/a2-a6	52+52=104 bytes
	movem.l	d0-d7/a2-a6,52(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,104(a0)		104+28=120		
	lea	160(a0),a0   	to start of line 2 destination
	add.l	#40,a1		to start of line 2 origin (160-120=40)
	subq	#1,(a7)		deduct 1 from loop counter
	bne.s	scroll_frame_lp2
	addq.l	#2,a7		reset the stack pointer
	movem.l	(a1)+,d0-d7/a2-a4	now the last line
	movem.l	d0-d7/a2-a4,(a0)    	44 bytes  
	movem.l	(a1)+,d0-d7/a2-a4
	movem.l	d0-d7/a2-a4,44(a0)	+44 again
	movem.l	(a1)+,d0-d7
	movem.l d0-d7,88(a0)       	+32=120
	movem.l	(a7)+,d1-d7/a2-a6	restore registers
	rts
*---------------	
scroll160
	movea.l	logical_screen,a0	
	movea.l	image_start,a1	
	move	scroll_index,d0		
	bsr	scroll_160	160 bytes wide 
* at this point we	bsr	toggle_screens
	rts			(bra	main_loop )
scroll_160		* this one scrolls the whole width (160 bytes)
	movem.l	d1-d7/a2-a6,-(a7)	
	mulu #160,d0		
	adda.l	d0,a1
	move	#113,-(a7)  	number of loops required 153
scroll_lp2
	movem.l	(a1)+,d0-d7/a2-a6	52 bytes
	movem.l	d0-d7/a2-a6,(a0)
	movem.l	(a1)+,d0-d7/a2-a6	52+52=104 bytes
	movem.l	d0-d7/a2-a6,52(a0)
	movem.l	(a1)+,d0-d7/a2-a6	now 156
	movem.l	d0-d7/a2-a6,104(a0)
	movem.l	(a1)+,d0-d7/a2-a6	now 208
	movem.l	d0-d7/a2-a6,156(a0)
	lea	208(a0),a0   	to start of line 2 destination
	subq	#1,(a7)		deduct 1 from loop counter
	bne.s	scroll_lp2
	addq.l	#2,a7		reset the stack pointer
	movem.l	(a1)+,d0-d7/a2-a4	now the last line
	movem.l	d0-d7/a2-a4,(a0)    	44 bytes  
	movem.l	(a1)+,d0-d7/a2-a4
	movem.l	d0-d7/a2-a4,44(a0)	+44 again

	movem.l	(a1)+,d0-d7/a2-a4	
	movem.l	d0-d7/a2-a4,88(a0)  
	movem.l	(a1)+,d0-d7/a2-a4
	movem.l	d0-d7/a2-a4,132(a0)	
	movem.l	(a7)+,d1-d7/a2-a6	restore registers
	rts
* total 147046 cycles
*---------------	
* scroll_variables	
scroll_index		dc.w	0    vert scroll index	 offset 0
scroll_direction	dc.w	1    scroll direction     	+2
scroll_stepper		dc.w	0    scroll incr     
image_size		dc.w   	400  size of scenery minus 200
image_start		dc.l	0
image_position		dc.l	0    image_start + scroll_index * 160
*--------------------------------------------
	


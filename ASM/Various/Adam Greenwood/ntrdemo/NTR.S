* STE No Through Road Demo
* Hardware scrolling, blitter chip sprites, DMA sound,
* volume/tone control, cookie jar and joystick port demo.
* Copyright c.1991 Adam Greenwood
* Feel free to change and use this code
* Written for/with Devpac 2
* This program can be run from medium res

* ALWAYS SAVE THIS CODE BEFORE TESTING
* since the method of directly reading the keyboard 
* is not gaurenteed to work with debuggers etc.
* For debugging replace the direct keyboard read
* with bdos call 6 or similar 'proper' routine, or 
* keyboard will not work in debugger

* If this program is assembled to memory ensure that the filenames
* in the DATA section include the full path name, if the files 
* are not in the root directory

* The timing has been worked out to allow for 60 Hz. At 50 Hz only
* more sprites can be used.

* Three screens are used for the horizontal scroll, rather
* than 4, since the two pairs which are double buffered can 
* be overlapped. This only works where the background data 
* stays the same, and would not work for a mapped background
* Two screens are used for restoring background behind the 
* sprites.

* constants:

key_data	equ	$fffc02		keyboard data register

* screen address and scrolling constants

scrnbase	equ	$44e		original screen base

vbasehi	equ	$ff8201		screen base address high
vbasemd	equ	$ff8203		screen base address middle
vbaselo	equ	$ff820d		screen base address low		

shiftmd	equ	$ff8260		shift mode
rgb	equ	$ff8240		rgb colour registers

linewid	equ	$ff820f		over-length line width
hscroll	equ	$ff8265		pixel scroll value

* blitter chip constants

blitter	equ	$ff8a00		blitter chip address

* offsets for all blitter chip registers

halfton	equ	0		halftone RAM registers (16)

srcxinc	equ	$20		source x increment
srcyinc	equ	$22		source y increment
srcaddr	equ	$24		source address

endmsk1	equ	$28		left end mask
endmsk2	equ	$2a		middle mask
endmsk3	equ	$2c		right end mask

dstxinc	equ	$2e		destination x increment
dstyinc	equ	$30		destination y increment
dstaddr	equ	$32		destination address

xcount	equ	$36		x count
ycount	equ	$38		y count

hop	equ	$3a		halftone operation
op	equ	$3b		logical operation
linenum	equ	$3c		line number/smudge/HOG/busy
skew	equ	$3d		source shift

* DMA Sound chip registers
mode	equ	$ff8920		stereo/Mono & frequency
enable	equ	$ff8900		enable register
f_strt_h	equ	$ff8902		frame start high
f_end_h	equ	$ff890e		frame end high

* System variables for interrupts
timera	equ	$134		timer A vector

* MFP 68901 Addresses
iea	equ	$fffa07		interrupt enable A
ieb	equ	$fffa09		interrupt enable B
isra	equ	$fffa0f		in service A
ima	equ	$fffa13		interrupt mask A
tacr	equ	$fffa19		timer A control
tadr	equ	$fffa1f		timer A data

* Microwire constants for volume/tone

mw_data	equ	$ff8922		microwire data register
mw_mask	equ	$ff8924		microwire mask register

* Joystick registers

fire	equ	$ff9200		fire button register
udlr	equ	$ff9202		direction register

cookies	equ	$5a0		address of cookie pointer

* The names of the official Atari cookies so far

_vdo	equ	'_VDO'		video cookie
_snd	equ	'_SND'		sound chip cookie

* Constants for program

sprt_no1	equ	2		3 32x32 sprites
sprt_no2	equ	3		4 32x12 sprites
sprt_no3	equ	16		17 16x16 sprites

* Start of program

start	move.l	a7,a5
	addq	#4,a7
	move.l	4(a5),a5		get basepage
	move.l	$c(a5),d0		get legth of text segment
	add.l	$14(a5),d0	add length of data segment
	add.l	$1c(a5),d0	add length of uninit BSS
	add.l	#$100,d0		add length of basepage
	move.l	d0,-(A7)		push length to reserve
	move.l	a5,-(a7)		start address to modify
	move.w	#0,-(a7)		zero
	move.w	#$4a,-(a7)	shrink memory
	trap	#1
	add.l	#$c,a7
        
	move.w	#-1,-(a7)
	move.w	#0,-(a7)
	move.w	#21,-(a7)		turn cursor off
	trap	#14
	addq	#6,a7

	clr.l	-(a7)		set supervisor mode
	move.w	#32,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,save_stk	save old stack
	
	move.l	#intr_mess,a1	print intro message
	jsr	do_mess		to screen

	move.w	#$80,-(a7)	disable and get status
	move.w	#64,-(a7)		blitmode
	trap	#14
	addq	#4,a7
	
	btst	#1,d0		check blitter exists
	beq	.no_blit		if not finish
	move.l	#blit_mess,a1	message to confirm blitter
	jsr	do_mess
	
	move.l	cookies,a0	address of cookie jar
	beq	.no_jar		if 0 no cookie jar

* now loop round reading each pair of longwords until
* the empty longword is reached

.loop	move.l	(a0)+,d0		cookie name
	move.l	(a0)+,d1		cookie value 
	cmp.l	#0,d0		check for empty longword
	beq	.done		if empty finished

	cmp.l	#_vdo,d0		check for _vdo cookie
	bne.s	.snd
	swap	d1		value is in high word
	cmp.w	#0,d1		check for standard v/s
	beq	.no_vid		if standard out
	cmp.w	#1,d1		check for STE shifter
	bne.s	.TT
	move.l	#STE_mess,a1	message
	jsr	do_mess
	bra	.loop		get next cookie
.TT	move.l	#TT_mess,a1	check for TT chip
	jsr	do_mess		message
	bra	.loop	

.snd	cmp.l	#_snd,d0		check for _snd cookie
	bne.s	.loop
	btst	#1,d1		check for DMA sound
	beq	.no_dma
	move.l	#dma_mess,a1
	jsr	do_mess
	bra	.loop

.done	jsr	save_regs		save all registers
	jsr	get_mem		allocate memory

	move.l	#message1,a1
	jsr	do_mess		print screen message
	jsr	load_all		load pictures

	move.l	#new_pal,a6		
	jsr	rest_pal		set new palette

	jsr	playit		start the music!
	
	jsr	sprites		jump to main routine
	
	jsr	rel_mem		release memory
	jsr	rest_regs		restore registers
	jmp	fin		finish

* Messages in case machin does not have the hardware to 
* run this demo

.no_blit	move.l	#xblt_mess,a1	no blitter chip
	jsr	do_mess
	jmp	getout
	
.no_jar	move.l	#xjar_mess,a1	no cookie jar
	jsr	do_mess		therefore not STE
	jmp	getout
	
.no_vid	move.l	#xvid_mess,a1	only standard video shifter
	jsr	do_mess
	jmp	getout
	
.no_dma	move.l	#xdma_mess,a1	no DMA sound chip
	jsr	do_mess
	jmp	getout
	
getout	move.l	#out_mess,a1	print message and wait 
	jsr	do_mess		for key press
	jsr	wait_key
	jmp	term

* Main routine which initialises and looks after the sprites,
* swaps the screens etc.

sprites	jsr	waitv		synchronise

* first initialise our variables

	move.b	#0,hs_buff	hscroll buffer
	move.w	#0,screen_x	x coords of screen
	move.w	#0,screen_y	y coords of screen
	move.l	#y_list,y_ptr	pointer to coords list

	move.l	#0,control0	no joystick control

	move.w	#0,sprt_frm	start on frame 0
	move.b	#0,frame_dir	start on direction 0

	move.b	#0,shiftmd	set low resolution


* initialise the tables of sprite information for the three 
* sets of different sized sprites. 

	move.l	#sprt_inf1,a0	table 1 (32x32)
	move.w	#sprt_no1,d0
	move.l	#coords1,a1	start of coordinates list
.init1	move.l	a1,(a0)		address of coords
	move.l	#0,4(a0)		background offset
	add.l	#12,a0		next entry
	add.l	#152,a1		move along coords list
	dbra	d0,.init1

	move.l	#sprt_inf2,a0	table 2 (32x16)
	move.l	#coords2,a1	start of coordinates list
	move.w	#sprt_no2,d0	no. of sprites - 1
.init2	move.l	a1,(a0)		address of coords
	move.l	#0,4(a0)		background offset
	add.l	#12,a0		next entry
	add.l	#124,a1		move along coords list
	dbra	d0,.init2		

	move.l	#sprt_inf3,a0	table 3 (16x16)
	move.l	#coords3,a1	start of coordinates list
	move.w	#sprt_no3,d0	no. of sprites - 1
.init3	move.l	a1,(a0)		address of coords
	move.l	#0,4(a0)		background offset
	add.l	#12,a0		next entry
	add.l	#36,a1		move along coords list
	dbra	d0,.init3		

	move.l	scrn1_mem,a5	off screen 
	move.l	scrn2_mem,a4	on screen
	move.l	a5,d0		off screen
	jsr	set_scrn		set screen address
	
.loop	jsr	do_sprt1		do 32x32 sprites
	jsr	do_sprt3		do 16x16 sprites
	jsr	do_sprt2		do 32x16 sprites
	
	exg.l	a4,a5		swap screens
	move.l	a5,d0		next on screen
	jsr	waitv		synchronise
	jsr	scroll		scroll screen
	jsr	joystick		check joysticks

	move.l	#back1_set,a0
	jsr	init_back		set up background restore

	move.l	#sprt_inf1,a3	table 1
	move.w	#sprt_no1,d7	no. of sprites - 1
	move.w	#32,d3		32 lines
	jsr	undo_sprt		restore background
	
	move.l	#back3_set,a0	
	jsr	init_back		set up background restore

	move.l	#sprt_inf3,a3	table 3 (16x16)
	move.w	#sprt_no3,d7		no. of sprites - 1
	move.w	#31,d3		no. of lines
	jsr	undo_all		restore background

	move.l	#back2_set,a0
	jsr	init_back		set up background restore

	move.l	#sprt_inf2,a3	table 2 (32x16)
	move.w	#sprt_no2,d7	no. of sprites - 1
	move.w	#12,d3		no. of lines
	jsr	undo_sprt		restore background

	move.b	key_data,d0	check for key press

	cmp.b	#57,d0		57 = space = quit
	beq	.out
	
	jsr	set_vt		set volume/tone
	
	bra	.loop
	
.out	rts

* Routine to monitor joystick ports, and hand over 
* control of sprites when necessary

joystick	movem.l	d0-d7/a0-a6,-(a7)

	move.l	#joy_0x,a0	address of coords variables
	move.l	#control0,a1	address of control variables
	move.l	#sprt_inf2,a2	address of sprite info

	move.w	fire,d0		fire buttons

* first we have to swap the fire button bits for
* joysticks 1 and 2

	move.w	d0,d1
	move.w	d0,d2
	and.w	#$0009,d0		clear bits 1 and 2
	and.w	#$0004,d1		bit 2 only
	and.w	#$0002,d2		bit 1 only
	lsr.w	d1		bit 2 > bit 1
	lsl.w	d2		bit 1 > bit 2
	or.w	d1,d0		rebuild d0
	or.w	d2,d0		d0 = fire bits

	move.w	udlr,d1		d1 = direction bits
	move.w	#3,d7		d7 = loop count
	
.loop	move.b	(a1),d5		control

	btst	#0,d0		test fire bit
	bne	.udlr	

	cmp.b	#0,d5		if control already 1
	bne.s	.udlr		do nothing

	move.l	(a2),a3		address of coords 

	move.w	(a3),(a0)		set joy x
	move.w	2(a3),2(a0)	set joy y
	move.b	#1,(a1)		set control to 1	

.udlr	cmp.b	#0,d5		check control
	beq	.nextone		if 0 ignore this stick

	move.w	(a0),d2		x position
	move.w	2(a0),d3		y position

	btst	#0,d1		check for right
	bne.s	.left
	cmp.w	#270,d2		check for maximum
	bge.s	.down		
	add.w	#2,d2		increase y
	bra	.down

.left	btst	#1,d1		check for left
	bne.s	.down
	cmp.w	#2,d2		check for minimum
	ble.s	.down
	sub.w	#2,d2		decrease y

.down	btst	#2,d1		check for down
	bne.s	.up
	cmp.w	#182,d3		check for maximum
	bge.s	.up
	add.w	#2,d3		increase x
	bra.s	.save
		
.up	btst	#3,d1		check for up
	bne.s	.save
	cmp.w	#2,d3		check for minimum
	ble.s	.save
	sub.w	#2,d3		decrease y
	
.save	move.w	d2,(a0)		save x and y coords
	move.w	d3,2(a0)
	
.nextone	addq	#4,a0		next set of coords
	addq	#1,a1		next control variable
	add.w	#12,a2		next info entry

	lsr.b	d0		next fire button bit
	lsr.w	#4,d1		next udlr nibble
	
	dbra	d7,.loop		do it again
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts		
	
* Routine to look after scrolling of screen, horizontal 
* and vertical

* a5 = base address of off screen

scroll	movem.l	d0-d3/a0/a5,-(a7)

	move.b	hs_buff,d0	get hscroll from buffer

	move.b	d0,hscroll	set hscroll
	move.b	#156,linewid	value if hscroll non 0
	cmp.b	#0,d0		set linewid depending on
	bne.s	.done		whether hscroll is 0
	move.b	#160,linewid	value if hscroll 0

.done	move.l	y_ptr,a0		screen  y coord list pointer
	move.w	(a0)+,d0		screen y coords	
	cmp.w	#100,d0		check for end of list
	bne.s	.set_y		
	move.l	#y_list,a0	wrap back to start of list
	move.l	(a0)+,d0		and get value
		
.set_y	move.w	d0,screen_y	save screen y coord

* it is important to maintain the screen x and y coords
* as global variables as the sprites need for their coords
* which are relative to the screen

	mulu	#480,d0		convert to lines		 
	move.l	a0,y_ptr		save pointer

* the x coord is just incremented to give a constant horizontal
* scroll speed

	move.w	screen_x,d1	get x current position
	add.w	#2,d1		increase x
	move.w	d1,d2
	sub.w	#320,d2
	blt.s	.xset		check for maximum
	move.w	d2,d1		wrap around
.xset	move.w	d1,screen_x

	ext.l	d1
	divu	#16,d1		no. of word blocks
	move.l	d1,d2		
	mulu	#8,d1		no. of bytes to add to 
	add.l	d0,a5		base address
	add.l	d1,a5		add right no. of lines

	swap	d2		no. of pixels to scroll
	move.b	d2,hs_buff	buffer pixel value

	move.l	a5,d0		set screen address
	jsr	set_scrn
	
	movem.l	(a7)+,d0-d3/a0/a5
	rts

* routine to look after 32 x 32 sprites
* these sprites are animated, and follow a predefined
* path around the screen.
* in:	a5 = address of off screen

do_sprt1	move.l	#sprt1_set,a0	dimensions for blit
	jsr	init_sprt		set up blitter for sprite

	move.l	#sprt_inf1,a3	table 1 (32x32)
	move.l	sprt_mem,a0	sprite memory
	move.w	sprt_frm,d0	frame no. for animation
	cmp.b	#0,frame_dir	direction we are running
	beq.s	.add		through the frames
	sub.w	#1,d0		previous frame
	cmp.w	#0,d0		if start go through in
	bgt.s	.doit		opposite direction
	move.b	#0,frame_dir	
	bra.s	.doit

.add	add.w	#1,d0		next frame
	cmp.w	#16,d0		if end go through in reverse
	blt.s	.doit
	move.b	#1,frame_dir

.doit	move.w	d0,sprt_frm	save frame number
	ext.l	d0	
	divu	#10,d0		use frame number to index
	move.l	d0,d1		the sprites and so to
	mulu	#5120,d0		set the actual source 
	swap	d1		address
	mulu	#16,d1
	add.w	d0,d1
	add.w	d1,a0

	move.w	#32,d3		32 lines per sprite
	move.l	#coords1,d6	start of coords list
	move.w	#sprt_no1,d7

.loop	move.l	(a3),a2		address of coords
	move.w	(a2)+,d0		d0 = x coord
	cmp.w	#400,d0		wrap around if x > 400
	ble 	.less
	move.l	d6,a2		start of coordinates list
	move.w	(a2)+,d0		d0 = x coord
.less	move.w	(a2)+,d1		d1 = y coord
	move.l	a2,(a3)		save list pointer

	add.w	screen_x,d0	
	add.w	screen_y,d1
	jsr	convert		d2 = skew, a6 = offset

	move.l	a5,a1		screen address
	add.l	a6,a1		add offset
	move.l	a6,8(a3)		save offset for undraw
	jsr 	sprt_blit		blit sprite

	add.l	#12,a3		next info entry
 	dbra	d7,.loop		repeat for all sprites
	
	rts

* routine to look after 32 x16 sprites
* these sprites follw a pre defined path unless one of the 
* joystick fire buttons is pressed, in which case they are
* under joystick control.
* in:	a5 = address of off screen

do_sprt2	movem.l	d4/a4,-(a7)

	move.l	#sprt2_set,a0	dimensions for blit
	jsr	init_sprt		set up blitter for sprite

	move.l	#sprt_inf2,a3	table 2 (32x16)
	move.w	#sprt_no2,d7	no. of sprites - 1
	move.l	sprt_mem,a0	sprite memory
	add.l	#5392,a0		offset for 32x16 sprite

	move.w	#12,d3		12 lines per sprite
	move.l	#coords2,d6	start of coords list

	move.l	#control0,a4	control 
	move.l	#joy_0x,d4	joystick x/y coords

.loop	move.b	(a4)+,d2		check if under joy control
	bne.s	.joy		if non zero use joystick

* this is the code for not under joystick control

	move.l	(a3),a2		address of coords
	move.w	(a2)+,d0		d0 = x coord
	cmp.w	#400,d0		wrap around if x > 400
	ble 	.less
	move.l	d6,a2		start of coordinates list
	move.w	(a2)+,d0		d0 = x coord
.less	move.w	(a2)+,d1		d1 = y coord
	move.l	a2,(a3)		save list pointer

	bra	.no_joy

* This is the code for a sprite under joystick control

.joy	move.l	d4,a1		coords pointer
	move.w	(a1),d0		x coord
	move.w	2(a1),d1		y coord

* since x and y are relative to the screen position: 

.no_joy	add.w	screen_x,d0	screen offsets
	add.w	screen_y,d1
	jsr	convert		d2 = skew, a6 = offset

	move.l	a5,a1		screen address
	add.l	a6,a1		add offset
	move.l	a6,8(a3)		save offset for undraw
	jsr 	sprt_blit		blit sprite

	add.l	#12,a3		next info entry
	add.l	#4,d4		next coords
 	dbra	d7,.loop

	movem.l	(a7)+,a4/d4	
	rts

* routine to handle the 16x16 note sprites in the
* centre of the screen.
* these sprites are drawn individually but all undrawn
* in one go.
* a5 = screen address

do_sprt3	move.l	#sprt3_set,a0	dimensions for blit
	jsr	init_sprt		set up blitter for sprite

	move.l	#sprt_inf3,a3	table 3 (16x16)
	move.w	#sprt_no3,d7	no. of sprites - 1
	move.l	sprt_mem,a0	address of sprite memory
	add.l	#5424,a0
	move.w	#16,d3		16 lines per sprite
	move.l	#coords3,d6	start of coords list

	move.w	#80,d0		x coord of whole block
	move.w	#85,d1		y coord of whole block
	add.w	screen_x,d0	make relative to screen
	add.w	screen_y,d1
	jsr	convert		d2 = skew, a6 = offset
	move.l	a6,8(a3)		only one offset	

.loop	move.l	(a3),a2		address of coords
	move.w	(a2)+,d0		d0 = x coord
	cmp.w	#400,d0		wrap around if x > 400
	ble 	.less
	move.l	d6,a2		start of coordinates list
	move.w	(a2)+,d0		d0 = x coord
.less	move.w	(a2)+,d1		d1 = y coord
	move.l	a2,(a3)		save list pointer

	add.w	screen_x,d0	relative for individual	
	add.w	screen_y,d1	sprite
	jsr	convert		d2 = skew, a6 = offset

	move.l	a5,a1		screen address
	add.l	a6,a1		add offset
	jsr 	note_blit		blit sprite

	add.l	#12,a3		next info entry
 	dbra	d7,.loop		repeat for all sprites
	
	rts
	
* routine to restore background where a sprite was
* for one set of sprites
* restores on off screen, so uses last but one background adderss

undo_sprt	move.l	4(a3),a6		old save address
	move.l	8(a3),d6		new save address
	move.l	d6,4(a3)		old = new

	move.l	a6,d5		since the screen is 3 pics
	divu	#480,d5		wide but the background used
	move.l	d5,d4		to restore only 2, we divide
	swap	d4		by 480 and then multiply by 
	mulu	#320,d5		320 to get the no. of lines
	add.w	d4,d5
	
	move.l	a5,a1		off screen
	add.l	a6,a1		background offset
	move.l	back_mem,a0	background pic
	add.l	d5,a0		
	jsr	back_blit		restore background

	add.l	#12,a3		next entry
	dbra	d7,undo_sprt
	
	rts

* routine to restore background where a sprite was
* for set of 16x16 sprites
* restores on off screen, so uses last but one background adderss
* this particular restore cheats by restoring in one block
* for all the 16x16 sprites at once. It does this by finding
* the left most sprite at any time and using the offset
* for that sprite to blit a 160 pixel wide block of 
* background which will cover all sprites

undo_all	move.l	#$ffffff,d0	theoretical 16Mb max

	move.l	4(a3),a6		old save address
	move.l	8(a3),d6		new save address
	move.l	d6,4(a3)		old = new

	move.l	a6,d5		again, convert from 
	divu	#480,d5		3 pic to 2 pic by 
	move.l	d5,d4		div 480, mul 320
	swap	d4
	mulu	#320,d5
	add.w	d4,d5
	
	move.l	a5,a1		off screen
	add.l	a6,a1		background offset
	move.l	back_mem,a0	background pic
	add.l	d5,a0		
	jsr	back_blit		restore background

	rts


* routine to convert x and y coordinates into screen base offset 
* and skew value
* in : d0.w = x
*      d1.w = y
* out: d2.w = shift value
*      a6.l = address offset

convert	movem.l	d0-d1,-(a7)

	mulu	#480,d1		address of correct line
	move.l	d1,a6		offset for lines

	ext.l	d0
	divu	#16,d0		address of block 
	swap	d0		
	move.w	d0,d2		d2.w	= shift no.
	swap	d0		remainder
	mulu	#8,d0		amount to shift
	add.l	d0,a6		a6 = offset

	movem.l	(a7)+,d0-d1
	rts

* routine to initialise blitter chip for a sprite routine
* a0 = address of set up table, which is simply a list 
* of the correct values for the blitter registers needed
* to set up the blitter chip
* The setup tables are in the data section at the
* bottom of the file

init_sprt	movem.l	a0-a1,-(a7)

	move.l	#blitter,a1		blitter address
	
	move.w	(a0)+,xcount(a1)		words per dest. line
	move.w	(a0)+,srcxinc(a1)		bytes offset next word
	move.w	(a0)+,srcyinc(a1)		bytes to skip after line
	move.w	(a0)+,dstxinc(a1)		bytes offset next word
	move.w	(a0)+,dstyinc(a1)		bytes to skip
	move.b	#2,hop(a1)		use source direct

	movem.l	(a7)+,a0-a1
 	rts

* routine to initialise blitter chip for a background restore
* using list of values as above

init_back	movem.l	a0-a1,-(a7)

	lea	blitter,a1		blitter address

	move.w	(a0)+,xcount(a1)		words per line dest
	move.w	(a0)+,srcxinc(a1)		bytes offset next word
	move.w	(a0)+,srcyinc(a1)          	bytes to skip after line
	move.w	(a0)+,dstxinc(a1)		bytes offset next word
	move.w	(a0)+,dstyinc(a1)        	bytes to skip
	move.b	#2,hop(a1)        		use source only

	move.w	#$ffff,endmsk1(a1)		no mask, since 
	move.w	#$ffff,endmsk2(a1)		data is not shifted
	move.w	#$ffff,endmsk3(a1)

	movem.l	(a7)+,a0-a1
 	rts

* Routine to blit block onto background
* a0.l = address of block
* a1.l = address in background
* d2.w = shift value
* d3.w = y count (no. of lines)

sprt_blit	movem.l a0-a3/d0-d3,-(a7)
	
	lea	blitter,a2	blitter chip address
	
	move.w	#$ffff,d0		
	lsr.w	d2,d0		mask off left edge
	move.w	d0,endmsk1(a2)	Left end mask
	move.w	#$ffff,endmsk2(a2)  mid mask
	not.w	d0
	move.w	d0,endmsk3(a2)      Right end mask
	move.b	d2,skew(a2)	shift data right

	move.b	#1,op(a2)		AND mode
	move.l	#3,d0		mask all 4 bit planes

.mask	move.l	a0,srcaddr(a2)	source address
	move.l	a1,dstaddr(a2)	dest address
	move.w	d3,ycount(a2)	no. of lines
	move.b	#192,linenum(a2)	start blit (HOG mode)
	addq	#2,a1		next bit plane
	dbra	d0,.mask

	move.b	#7,op(a2)		OR mode
	move.l	#2,d0		OR data over 3 planes
	addq	#2,a0		skip mask plane
	subq	#6,a1		start at second plane
	
.blit	move.l	a0,srcaddr(a2)	source address
	move.l	a1,dstaddr(a2)	dest address
	move.w	d3,ycount(a2)	no. of lines
	move.b	#192,linenum(a2)	start blit (HOG mode)
	addq	#2,a0		next source plane
	addq	#2,a1		next dest plane
	dbra	d0,.blit

	movem.l	(a7)+,a0-a3/d0-d3
	rts

* Routine to blit 16x16 block onto background
* a0.l = address of block
* a1.l = address in background
* d2.w = shift value
* d3.w = y count (no. of lines)
* This uses a slightly different method, since 
* we only need one colour we and all planes
* to give colour 0 only.

note_blit	movem.l a0-a3/d0-d3,-(a7)
	
	lea	blitter,a2	blitter chip address
	
	move.w	#$ffff,d0		
	lsr.w	d2,d0		mask off left edge
	move.w	d0,endmsk1(a2)	Left end mask
	move.w	#$ffff,endmsk2(a2)  mid mask
	not.w	d0
	move.w	d0,endmsk3(a2)      Right end mask
	move.b	d2,skew(a2)	shift data right

	move.b	#1,op(a2)		AND mode
	move.l	#3,d0		mask all 4 bit planes

.mask	move.l	a0,srcaddr(a2)	source address
	move.l	a1,dstaddr(a2)	dest address
	move.w	d3,ycount(a2)	no. of lines
	move.b	#192,linenum(a2)	start blit (HOG mode)
	addq	#2,a1		next bit plane
	dbra	d0,.mask

	movem.l	(a7)+,a0-a3/d0-d3
	rts

* Blitter routine to save\restore background
* a0 = source address
* a1 = destination address
* d3 = y count (no. of lines)

back_blit	movem.l	a0-a3/d3,-(a7)

	lea	blitter,a2	blitter base address
	move.b	#0,skew(a2)	no skew
	move.b	#3,op(a2)		replace mode

	move.l	a0,srcaddr(a2)	source address
	move.l	a1,dstaddr(a2)	dest address
	move.w	d3,ycount(a2)	no. of lines

	move.b	#192,linenum(a2)	start blit (HOG mode)

	movem.l	(a7)+,a0-a3/d3
	rts

* Subroutine to save pallette to address in A6

save_pal	movem.l	d0/a0,-(a7)

	move.l	#rgb,a0		colour register address
	move.l	#15,d0		all 16 colours
.save	move.w	(a0)+,(a6)+	copy them
	dbra	d0,.save
	
	movem.l	(a7)+,d0/a0	
	rts

* restore pallette at address in a6

rest_pal	movem.l	d0/a0,-(a7)

	move.l	#rgb,a0		colour register address
	move.l	#15,d0		all 16 colours
.rest	move.w	(a6)+,(a0)+	copy them
	dbra	d0,.rest
	
	movem.l	(a7)+,d0/a0	
	rts

* wait for Vblank & return

waitv	movem.l	a0-a3/d0-d3,-(a7)
	move.w	#37,-(a7)
	trap	#14		wait for Vblank
	addq	#2,a7
	movem.l	(a7)+,a0-a3/d0-d3
	rts

* routine to set screen base address, which will take effect 
* next vblank

set_scrn	movem.l	d0-d1,-(a7)

	move.l	d0,d1
	lsr.l	#8,d0
	move.b	d0,vbasemd	middle byte
	lsr.l	#8,d0
	move.b	d0,vbasehi	high byte
	move.b	d1,vbaselo	low byte

	movem.l	(a7)+,d0-d1
	rts

wait_key	movem.l	d0-d4/a0-a4,-(a7)
	move.w	#7,-(a7)
	trap	#1
	addq	#2,a7
	movem.l	(a7)+,d0-d4/a0-a4
	rts

* Save all the memory-mapped configuration registers which
* the program is going to change

save_regs	move.l	#old_pal,a6
	jsr	save_pal		save old palette
	
	move.l	scrnbase,oldbase

	move.b	shiftmd,oldmode
	move.b	hscroll,oldhscr
	move.b	linewid,oldline

	rts
	
* restore all the registers which have been changed

rest_regs	jsr	waitv		synchronise

	move.b	oldline,linewid
	move.b	#0,hscroll
	move.l	#old_pal,a6
	jsr	rest_pal		restore old palette

	move.l	oldbase,d0
	jsr	set_scrn
	move.b	oldmode,shiftmd

	jsr	waitv
	
	rts

* print message to screen, then turn cursor off

do_mess	movem.l	d0-d4/a0-a4,-(a7)

	move.l	a1,-(a7)
	move.w	#9,-(a7)		write string to screen
	trap	#1
	addq	#6,a7

	movem.l	(a7)+,d0-d4/a0-a4
	rts

* Subroutine to allocate memory to this program

get_mem	move.l	#224002,-(a7)   	room for 5 screens + sprites
	move.w	#72,-(a7)		allocate memory
	trap	#1
	addq	#6,a7
        	
	addq	#1,d0		
	bclr	#0,d0        	put address on word boundary

	move.l	d0,scrn1_mem	save new screen address
	move.l	d0,d1
	add.l	#160,d0
	move.l	d0,scrn2_mem	address of second screen

	move.l	d1,d0
	add.l	#115200,d0
	move.l	d0,back_mem	address of third screen

	add.l	#76800,d0
	move.l	d0,sprt_mem	address of sprite memory
	
	rts

* release memory previously allocated

rel_mem	move.l	scrn1_mem,-(a7)
	move.w	#73,-(a7)		release memory
	trap	#1	
	addq	#6,a7
	
	rts

* routine to load background and sprite pictures and
* interleave them, and load and set up samples

load_all	move.l	#scrn_file,a6	background picture
	move.l	sprt_mem,a5	load into spare memory
	move.w	#200,d7		load 200 lines
	jsr	load_pic		load it

	move.w	#200,d0		200 lines
	move.l	scrn1_mem,a6	into screen memory
	jsr	inter_3		interleave 3 pictures
	add.l	#160,a6		to give one wide screen
	jsr	inter_3		which is three pics wide
	add.l	#160,a6
	jsr	inter_3

	move.l	back_mem,a6	into background memory
	jsr	inter_2		interlave 2 pics for sprite
	add.l	#160,a6		restoring
	jsr	inter_2
	
	move.l	#sprt_file,a6	sprite pic
	move.l	sprt_mem,a5
	move.w	#104,d7		cut down picture
	jsr	load_pic
	
	add.l	#10240,a5		skip 64 lines
	move.w	#40,d0		40 lines
	
	move.l	scrn1_mem,a6	interleave the bottom
	add.l	#96000,a6		part of the sprite pic
	jsr	inter_3		as the lower part of the
	add.l	#160,a6		screen pic, to give a
	jsr	inter_3		pic higher than the screen
	add.l	#160,a6		for vertical scrolling
	jsr	inter_3
	
	move.l	back_mem,a6	do the same for the background pic
	add.l	#64000,a6
	jsr	inter_2
	add.l	#160,a6
	jsr	inter_2

	move.l	#message2,a1	tell them we are onto
	jsr	do_mess		loading samples

	move.l	#file0,a6		filename
	move.w	#0,d0		sample 0
	jsr	load_spl		load
		
	move.l	#file1,a6		filename
	move.w	#1,d0		sample 1
	jsr	load_spl		load
	
* now we create somw new sample records which point
* to parts of the samples we have, allowing us to play 
* smaller parts of the main samples if we wish
* ie, there are only two actual samples, but more than 
* two sets of start and end addresses to play parts
* of them

	move.l	#sam_recs,a0	record 0
	move.l	(a0)+,d0		start address
	move.l	(a0)+,d1		end address
	
	move.l	#sam_recs,a0
	add.l	#16,a0		record 2
	move.l	d0,d2		start address
	add.l	#14534,d2		new start
	move.l	d2,(a0)+		save start
	move.l	d1,(a0)+		original end

	move.l	#sam_recs,a0
	add.l	#24,a0		record 3
	move.l	d0,d2
	add.l	#19189,d2		new start
	move.l	d0,d1
	add.l	#14534,d1
	move.l	d1,(a0)+		save start
	move.l	d2,(a0)+		original end

	move.l	#sam_recs,a0
	add.l	#32,a0		record 4
	move.l	d0,d2
	add.l	#14534,d2
	move.l	d0,(a0)+		save start
	move.l	d2,(a0)+		original end

	rts

* Routine to load a picture into memory
* A6 = address of pathname, A5 = address of memory
* d7 = no. of lines to read

load_pic	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#0,-(a7)		read/write
	move.l	a6,-(a7)		filename
	move.w	#61,-(a7)		open file
	trap	#1
	move.w	d0,d6		d6 = file handle
	addq	#8,a7

	move.l	#pic_mode,-(a7)	dump palette & mode info
	move.l	#34,-(a7)		34 bytes
	move.w	d6,-(a7)		file handle
	move.w	#63,-(a7)		read palette/mode
	trap	#1
	add.w	#12,a7

	mulu	#160,d7
	move.l	a5,-(a7)		address of memory
	move.l	d7,-(a7)		no. of bytes
	move.w	d6,-(a7)		file handle
	move.w	#63,-(a7)		read picture
	trap	#1
	add.w	#12,a7

	move.w	d6,-(a7)		file handle
	move.w	#62,-(a7)		close file
	trap	#1
	addq	#4,a7        
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Routine to interleave a picture into memory, 2 pictures wide
* in: a6 = address of source, a6 = address of dest
* d0 = no. of lines

inter_2	movem.l	d0-d7/a0-a6,-(a7)

	move.w	d0,d7
	sub.w	#1,d7
.loop1	move.w	#39,d6
.loop2	move.l	(a5)+,(a6)+
	dbra	d6,.loop2
	add.l	#160,a6		skip 160 bytes to interleave
	dbra	d7,.loop1		lines into one line 320 bytes long

	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Routine to interleave a picture into memory, 3 pictures wide
* in: a6 = address of source, a6 = address of dest
* d0 = no. of lines

inter_3	movem.l	d0-d7/a0-a6,-(a7)

	move.w	d0,d7
	sub.w	#1,d7
.loop1	move.w	#39,d6
.loop2	move.l	(a5)+,(a6)+
	dbra	d6,.loop2
	add.l	#320,a6		skip 160 bytes to interleave
	dbra	d7,.loop1		lines into one line 320 bytes long

	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Routine to load a sample into memory
* Gets length of sample, allocates memory
* then loads sample
* d0.w = sample no.
* a6 = filename address
* Assumes file exists

load_spl	movem.l	d0-d7/a0-a6,-(a7)
	
	move.l	#sam_recs,a5	
	mulu	#8,d0
	add.w	d0,a5		a5 = sample record address
	
	move.w	#2,-(a7)		find file
	move.l	a6,-(a7)		d0.l = -33 fnf
	move.w	#78,-(a7)		else d0.l = DTA address
	trap	#1		creates DTA including
	addq	#8,a7		file size
	
	move.w	#47,-(a7)		get DTA address
	trap	#1
	addq	#2,a7

	move.l	d0,a0
	move.l	26(a0),d7		d7 = length of file
	sub.l	#4,d7		skip header
	bclr	#0,d7
	
	move.l	d7,-(a7)
	move.w	#72,-(a7)
	trap	#1
	addq	#6,a7
	
	addq	#1,d0
	bclr	#0,d0		ensure even address
	
	move.l	d0,d6
	add.l	d7,d0

	move.l	d6,(a5)+		save start/end addresses
	move.l	d0,(a5)+

	move.w	#0,-(a7)
	move.l	a6,-(a7)
	move.w	#61,-(a7)		open file
	trap	#1
	move.w	d0,d5
	add.w	#8,a7

	move.w	#0,-(a7)
	move.w	d5,-(a7)
	move.l	#4,-(a7)		skip header
	move.w	#66,-(a7)
	trap	#1
	add.w	#10,a7

	move.l	d6,-(a7)
	move.l	d7,-(a7)		read sample
	move.w	d5,-(a7)
	move.w	#63,-(a7)
	trap	#1
	add.w	#12,a7

	move.w	d5,-(a7)
	move.w	#62,-(a7)		close file
	trap	#1
	addq	#4,a7
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Routine which sets up and plays samples
* Once this is done the sequence can be left to play
* and the rest of the program can do what it wants

playit	jsr	initsound		init. volume/tone

	move.w	#0,d0
	move.b	freq,d0		combine frequency and 
	move.w	ster,d1		stereo/mono
	or.w	d1,d0		to set mode	
	move.w	d0,mode

	move.l	#smpl_list,a1	sample list
	move.l	#loop_list,a2	loop list 
	
	move.l	#sam_recs,a0	
	move.w	#0,d0
	move.b	(a1)+,d0		get index and use it
	mulu	#8,d0		to find sample
	add.w	d0,a0
	move.l	(a0)+,d0		get sample addresses
	move.l	(a0)+,d1
 	jsr	sample_ad		set addresses
	move.w	#3,enable		enable sound, repeat mode

	jsr	init_int		initialise timer A interrupt

* Now get next sample ready so that we are looking ahead
* 1 sample

	move.b	(a2)+,d3		repeat for first sample
	sub.b	#1,d3		check whether need to
	bne.s	.set		load next address

	move.w	#0,d0		get index
	move.b	(a1)+,d0		for second sample
	move.l	#sam_recs,a0	
	mulu	#8,d0		
	add.w	d0,a0		
	move.l	(a0)+,d0		start address of next sample
	move.l	(a0)+,d1		end address of next sample
	jsr	sample_ad		next sample ready for end
	move.b	(a2)+,d3		of current
	
.set	move.b	#0,tacr		set timer A countdown to 
	move.b	d3,tadr		correct number of loops
	move.b	#8,tacr		using event countdown	

	move.l	a1,smpl_ptr	save list pointers
	move.l	a2,loop_ptr
	
	rts

* Routine to initialise Timer A 
* STE provides interrupt after sample has finished playing
* Using event countdown mode we only get the interrupt after
* the sample has played the correct number of times

init_int	move.b	iea,old_iea	save state of MFP
	move.b	ima,old_ima
	move.b	ieb,old_ieb
	move.b	tadr,old_tadr
	move.b	tacr,old_tacr
	move.l	timera,old_vec	save old timer A vector

	and.b	#$9f,ieb		turn off 200Hz interrupt
				;and keyboard/midi
	and.b	#$df,iea		disable Timer Interrupt
	move.l	#tim_rtn,timera	address of our routine
	or.b	#$20,iea		re-enable Timer A interrupt
	or.b	#$20,ima		set Timer A Mask
	rts
	
* Interrupt handler called when sample finished.
* This is the routine which actually loads up the address of the 
* next sample.
* Using event countdown this is called after a specified
* number of interrupts

tim_rtn	movem.l	d0-d3/a0-a2,-(a7)
				
	move.b	#0,tacr		stop timer

	move.l	smpl_ptr,a0	get index of next sample
	move.l	loop_ptr,a2	get number of times to play
	
	move.b	(a2),d0		repeat for next sample			
	cmp.b	#0,d0		check for end
	bne	.doit
	move.l	#smpl_list,a0	if end back to start
	move.l	#loop_list,a2
	
.doit	move.l	#sam_recs,a1
	clr.l	d0
	move.b	(a0)+,d0		use index to get
	mulu	#8,d0		start and end address
	add.w	d0,a1		of sample
	move.l	(a1)+,d0
	move.l	(a1)+,d1
	jsr	sample_ad
	move.b	(a2)+,tadr	set repeat

.noctrl	move.l	a0,smpl_ptr	move along list
	move.l	a2,loop_ptr
		
	bclr	#5,isra		re-enbale lower level interupts
	move.b	#8,tacr		restart timer

	movem.l	(a7)+,d0-d3/a0-a2
	rte
	
* Routine to set start and end addresses for a sample
* d0.l = start address
* d1.l = end address
* uses movep to set alternate bytes

sample_ad	movem.l	d0-d1/a0,-(a7)

	move.l	#f_strt_h,a0	Frame start high
	movep.w	d0,3(a0)		Set start mid & low
	swap	d0
	move.b	d0,1(a0)		Set start high
	
	move.l	#f_end_h,a0	Frame end high
	movep.w	d1,3(a0)		Set end mid & low
	swap	d1
	move.b	d1,1(a0)		Set end high

	movem.l	(a7)+,d0-d1/a0
	rts

* routine to look after volume/tone 
* in: d0 = keyscan code.

set_vt	movem.l	d0-d7/a0-a6,-(a7)

	move.b	delay,d1		since we are reading
	beq.s	.ok		keyboard data direct 
	sub.b	#1,d1		we have to allow a delay
	move.b	d1,delay		to simulate key repeat rate
	bra	.out	
	
.ok	move.l	#m_vol,a0		address of vol/tone settings
	move.l	#vt_max,a1	address of max settings
	
	move.b	d0,d7		d7 = keyscan code
	move.w	#0,d1		d1 = parameter no.
	move.b	#59,d6		code for f1
	move.b	#60,d5		code for f2
	
.loop	move.b	(a0),d0		parameter value
	move.b	(a1)+,d2		parameter max
	
	cmp.b	d6,d7		test for down
	bne.s	.up
	cmp.b	#0,d0		check for 0		
	beq	.out		invalid, so out
	sub.b	#1,d0		parameter down
	bra	.set_it

.up	cmp.b	d5,d7		check for up
	bne.s	.next

	cmp.b	d2,d0		check for max		
	beq	.out		invalid, so out
	add.b	#1,d0		

.set_it	move.b	d0,(a0)
	jsr	setparams
	move.b	#7,delay
	bra	.out		

.next	cmp.w	#4,d1
	beq	.out
	
	addq	#1,a0		next parameter
	add.b	#2,d6		next pair of f keys
	add.b	#2,d5
	add.w	#1,d1		next param
		
	bra	.loop
	
.out	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
* Routine to initialise volume/tone settings
* The addresses here are storage in this program, the
* Setparams routine uses these to set actual volume/tone

initsound	movem.l	d0-d1/a0,-(a7)

	move.b	#40,m_vol
	move.b	#20,l_vol
	move.b	#20,r_vol
	move.b	#6,treble
	move.b	#6,bass
	move.b	#2,mix 

	move.l	#m_vol,a0
	move.w	#0,d1
.loop	move.b	(a0)+,d0		loop round getting
	jsr	setparams		value and calling routine
	add.w	#1,d1		for each setting
	cmp.w	#6,d1
	blt.s	.loop

	movem.l	(a7)+,d0-d1/a0
	rts

* Routine to set volume & tone
* in: d0.b = parameter level
* Ranges are: master volume, 0 - 40
*	    left/right volume, 0 - 20
* 	    treble/bass, 0 - 12 (6 centre)
* d1.w = parameter no.
* 0 = master volume
* 1 = left volume
* 2 = right volume
* 3 = treble
* 4 = treble
* 5 = mix GI (sound chip)
* Uses microwire to set.

setparams	movem.l	d0-d4/a0-a3,-(a7)

	move.l	#voltone,a0	microwire settings
	move.l	#mw_data,a2	microwire data register
	move.l	#m_vol,a3		parameter Values
	add.w	d1,a3
	mulu	#2,d1
	add.w	d1,a0
	
	move.b	(a3)+,d1		setting for data
	move.w	(a0)+,d2		microwire address
	or.b	d1,d2		combine them
	move.w	(a2),d4		previous value of microwire data
	move.w	#$7ff,mw_mask	set microwire mask for vol/tone
	move.w	d2,(a2)		set data - send data

.wait	move.w	(a2),d2
	cmp.w	d4,d2		current value of microwire data
	bne.s	.wait		data sent when returns to previous

	movem.l	(a7)+,d0-d4/a0-a3
	rts


* Return to user mode and exit

fin	move.w	#0,enable		turn off sound
	
	move.w	sr,-(a7)		save status register
	move.w	#$2700,sr		disable all interrupts
	move.l	old_vec,timera	restore Timer A vector
	move.b	old_iea,iea	restore MFP
	move.b	old_ima,ima	
	move.b	old_ieb,ieb
	move.b	old_tadr,tadr
	move.b	old_tacr,tacr
	move.w	(a7)+,sr		restore status register

	jsr	initsound		set vol/tone to default
	move.b	#1,mix		mix GI (old sound chip)
	move.w	#5,d1		set mix
	jsr	setparams

term	move.l	save_stk,-(a7)
	move.w	#32,-(a7)
	trap	#1		Return to user mode
	addq	#6,a7

	move.w	#0,-(a7)
	trap	#1
	addq	#2,a7
	
* this code is for debugging, as the debug display
* is messed up if hscroll and linewid are non-zero.
* when the debugger is invoked, save the PC to a register,
* set PC to debug, single step 2 instructions then restore
* PC. This has to be done 'blind', so type carefully!

debug	move.b	#0,hscroll
	move.b	#0,linewid

	section bss

oldbase	ds.l	1	old screen base
oldmode	ds.b	1	old screen mode
oldhscr	ds.b	1	old hscroll value
oldline	ds.b	1	old linewid value

pic_mode	ds.w	1	used to dump first word of pic
new_pal	ds.w	16	next 16 are palette
old_pal	ds.w	16	stores original palette

scrn1_mem	ds.l	1	start of first screen
scrn2_mem	ds.l	1	start of second screen 
back_mem	ds.l	1	start of background memory
sprt_mem	ds.l	1	start of sprite memory

sprt_inf1	ds.l	60	info on 32x32 sprites
sprt_inf2	ds.l	60	info on 32x16 sprites
sprt_inf3	ds.l	60	info on 16x16 sprites

sprt_frm	ds.w	1	frame no. for 32x32
frame_dir	ds.b	1	direction of animation

	even

* scroll variables

y_ptr	ds.l	1	pointer to list of y coords
screen_x	ds.w	1	saved x coord of screen
screen_y	ds.w	1	saved y coord of screen
hs_buff	ds.b	1	buffer to synchronise hscroll set

	even

save_stk	ds.l	1	old stack pointer

old_vec	ds.l	1	initial interrupt vector
old_iea	ds.b	1	initial state of MFP:
old_ima	ds.b	1
old_ieb	ds.b	1
old_tadr	ds.b	1
old_tacr	ds.b	1

	even

sam_recs	ds.l	20	table of sample records
smpl_ptr	ds.l	1	pointer to sample list
loop_ptr	ds.l	1	pointer to loop list

* storage for volume/tone settings

m_vol	ds.b	1	master volume
l_vol	ds.b	1	left volume
r_vol	ds.b	1	right volume
treble	ds.b	1	treble
bass	ds.b	1	bass
mix	ds.b	1	mix/don't mix GI

delay	ds.b	1	loop counter to set key repeat

	even
	
control0	ds.b	4	indicate whether 32x16 sprite is
			; under joystick control
joy_0x	ds.w	8	joystick x and y coords 

	section data
	
sprt_file	dc.b	'NTR_SPR.PIC',0	sprite pic
scrn_file	dc.b	'NTR.PI1',0	background pic

intr_mess	dc.b	'The STE No Through Road Demo',10,13,10,13
	dc.b	'Copyright ',189,'1991 Adam Greenwood',10,13,10,13
	dc.b	'This is a source code demo',10,13,10,13
	dc.b	'All code and graphics by Adam Greenwood',13,10
	dc.b	'Music by No Through Road, ',189,'1990',13,10,13,10,0
	
blit_mess	dc.b	'Blitter Chip Present.',13,10,13,10,0
STE_mess	dc.b	'STE Video Shifter Present',13,10,13,10,0
TT_mess	dc.b	'TT Graphics Chip Present',13,10,13,10,0
dma_mess	dc.b	'DMA Sound Chip Present',13,10,13,10,0

xblt_mess	dc.b	'Blitter Chip not present',13,10,0
xjar_mess	dc.b	'No Cookie Jar, machine is not STE/TT',13,10,0
xvid_mess	dc.b	'Standard Video Shifter only',13,10,0
xdma_mess	dc.b	'DMA sound chip not present',13,10,0

out_mess	dc.b	'Sorry, cannot run on this machine',13,10
	dc.b	'Press any key',0

message1	dc.b	'Loading Pic and Sprites...',13,10,13,10,0

message2	dc.b	'Loading Samples...',0

	even

* sample filenames:

file0	dc.b	'NTR_SPL1.STE',0
file1	dc.b	'NTR_SPL2.STE',0

* Sample and loop lists
* Minimum of two entries per list, plus list terminator (0)
* smpl_list gives the number of the sample, ie
* The first file listed above is 0, the second 1 etc

smpl_list	dc.b	2,0,4,3,1
	
loop_list	dc.b	1,4,1,1,1,0

* Playback frequency for ALL samples
* 0 = 6.25 KHz, 1 = 12.5 KHz, 2 = 25 KHz, 3 = 50 KHz

freq	dc.b	1

	even
	
* Stereo/Mono mode
* $00 = stereo, $80 = mono

ster	dc.w	$80

* microwire values for volume/tone

voltone	dc.w	%10011000000	Master volume
	dc.w	%10101000000	Left channel volume
	dc.w	%10100000000	Right channel volume
	dc.w	%10010000000	Treble
	dc.w	%10001000000	Bass
	dc.w	%10000000000	Mix

* maximum values for volume and tone settings:

vt_max	dc.b	40
	dc.b	20
	dc.b	20
	dc.b	12
	dc.b	12


* Data used to initialise blitter chip for each operation

sprt1_set	dc.w	3		x count
	dc.w	8		source x inc.
	dc.w	144		source y inc.
	dc.w	8		dest x inc.
	dc.w	464		dest y inc.

sprt2_set	dc.w	3
	dc.w	8
	dc.w	144
	dc.w	8
	dc.w	464
	
sprt3_set	dc.w	2
	dc.w	8
	dc.w	152
	dc.w	8
	dc.w	472

back1_set	dc.w	12		
	dc.w	2		
	dc.w	298          	
	dc.w	2		
	dc.w	458        	

back2_set	dc.w	12		
	dc.w	2		
	dc.w	298          	
	dc.w	2		
	dc.w	458        	

back3_set	dc.w	44		
	dc.w	2		
	dc.w	234          	
	dc.w	2		
	dc.w	394        	

* three sets of coordinates which the three sets of sprites 
* follow around the screen.

coords1	dc.w	254,79,253,86
	dc.w	252,92,248,102,244,107,240,112,236,117
	dc.w	232,121,228,124,224,127,220,129,216,132
	dc.w	212,134,208,136,204,138,200,139,196,140
	dc.w	192,142,188,143,184,144,180,145,176,146
	dc.w	172,147,168,147,164,147,160,147,156,147
	dc.w	152,147,148,147,144,147,140,147,136,147
	dc.w	132,147,128,147,124,147,120,147,116,147
	dc.w	112,146,108,145,104,144,100,143,96,142
	dc.w	92,140,88,139,84,138,80,136,76,134
	dc.w	72,132,68,129,64,127,60,124,56,121
	dc.w	52,117,48,112,44,107,40,102,36,92
	dc.w	35,86,34,79,35,74
	dc.w	36,66,40,56,44,51,48,46,52,41
	dc.w	56,37,60,34,64,31,68,29,72,26
	dc.w	76,24,80,22,84,20,88,19,92,18
	dc.w	96,16,100,15,104,14,108,12,112,12
	dc.w	116,11,120,11,124,11,128,11,132,11
	dc.w	136,11,140,11,144,11,148,11,152,11
	dc.w	156,11,160,11,164,11,168,11,172,11
	dc.w	176,12,180,13,184,14,188,15,192,16
	dc.w	196,18,200,19,204,20,208,22,212,24
	dc.w	216,26,220,29,224,31,228,34,232,37
	dc.w	236,41,240,46,244,51,248,56,252,66
	dc.w	253,74
	
	dc.w	450
	
coords2	dc.w	60,30
	dc.w	62,31,64,32,66,33,68,34,70,35
	dc.w	72,36,74,37,76,38,78,39,80,40
	dc.w	82,41,84,42,86,43,88,44,90,45
	dc.w	092,46,94,47,96,48,98,49,100,50
	dc.w	102,51,104,52,106,53,108,54,110,55
	dc.w	112,56,114,57,116,58,118,59,120,60
	dc.w	122,61,124,62,126,63,128,64,130,65
	dc.w	132,66,134,67,136,68,138,69,140,70
	dc.w	142,71,144,72,146,73,148,74,150,75
	dc.w	152,76,154,77,156,78,158,79,160,80
	dc.w	162,81,164,82,166,83,168,84,170,85
	dc.w	172,86,174,87,176,88,178,89,180,90
	dc.w	182,91,184,92,186,93,188,94,190,95
	dc.w	192,96,194,97,196,98,198,99,200,100
	dc.w	202,101,204,102,206,103,208,104,210,105
	dc.w	212,106,214,107,216,108,218,109,220,110
	dc.w	222,111,224,112,226,113,228,114,230,115
	dc.w	232,116,234,117,236,118,238,119,240,120
	dc.w	242,121,244,122,246,123,248,124,250,125
	dc.w	252,126,254,127,256,128,258,129
	dc.w	259,130,260,131,261,133,262,135,262,137
	dc.w	262,139,262,141,262,143,261,145,260,147
	dc.w	259,149,258,150,257,151,256,152,255,153
	dc.w	253,154,251,155,249,156,247,157,245,157
	dc.w	243,157,241,157,239,157,237,157,235,157
	dc.w	233,156,231,156,229,155,227,154
	dc.w	225,153,223,152,221,151,219,150,217,149
	dc.w	215,148,213,147,211,146,209,145,207,144
	dc.w	205,143,203,142,201,141,199,140,197,139
	dc.w	195,138,193,137,191,136,189,135,187,134
	dc.w	185,133,183,132,181,131,179,130,177,129
	dc.w	175,128,173,127,171,126,169,125,167,124
	dc.w	165,123,163,122,161,121,159,120,157,119
	dc.w	155,118,153,117,151,116,149,115,147,114
	dc.w	145,113,143,112,141,111,139,110,137,109
	dc.w	135,108,133,107,131,106,129,105,127,104
	dc.w	125,103,123,102,121,101,119,100,117,99
	dc.w	115,98,113,97,111,96,109,95,107,94
	dc.w	105,93,103,92,101,91,99,90,97,89
	dc.w	95,88,93,87,91,86,89,85,87,84
	dc.w	85,83,83,82,81,81,79,80,77,79
	dc.w	75,78,73,77,71,76,69,75,67,74
	dc.w	65,73,63,72,61,71,59,70,57,69
	dc.w	55,68,53,67,51,66,49,65,47,64
	dc.w	45,63,43,62,41,61,39,60,37,59
	dc.w	35,58,33,57
	dc.w	32,56,31,55,30,54,29,53
	dc.w	28,51,27,49,27,47,27,45,27,43
	dc.w	27,41,28,39,29,37,30,36,31,34
	dc.w	33,33,35,32,37,31,39,30,41,29
	dc.w	43,28,45,28,47,28,49,28,51,28
	dc.w	53,28,55,28,57,29,59,29

	dc.w	450

coords3	dc.w	80,85,82,85,84,85,86,85,88,85
	dc.w	90,85,92,85,94,85,96,85,98,85
	dc.w	100,85,102,85,104,85,106,85,108,85
	dc.w	110,85,112,85,114,85,116,85,118,85
	dc.w	120,85,122,85,124,85,126,85,128,85
	dc.w	130,85,132,85,134,85,136,85,138,85
	dc.w	140,85,142,85,144,85,146,85,148,85
	dc.w	150,85,152,85,154,85,156,85,158,85
	dc.w	160,85,162,85,164,85,166,85,168,85
	dc.w	170,85,172,85,174,85,176,85,178,85
	dc.w	180,85,182,85,184,85,186,85,188,85
	dc.w	190,85,192,85,194,85,196,85,198,85
	dc.w	200,85,202,85,204,85,206,85,208,85
	dc.w	210,85,212,85,214,85,216,85,218,85
	dc.w	220,85
	dc.w	220,87,220,89,220,91,220,93,220,95
	dc.w	220,97,220,99
	dc.w	218,99,216,99,214,99,212,99,210,99
	dc.w	208,99,206,99,204,99,202,99,200,99
	dc.w	198,99,196,99,194,99,192,99,190,99
	dc.w	188,99,186,99,184,99,182,99,180,99
	dc.w	178,99,176,99,174,99,172,99,170,99
	dc.w	168,99,166,99,164,99,162,99,160,99
	dc.w	158,99,156,99,154,99,152,99,150,99
	dc.w	148,99,146,99,144,99,142,99,140,99
	dc.w	138,99,136,99,134,99,132,99,130,99
	dc.w	128,99,126,99,124,99,122,99,120,99
	dc.w	118,99,116,99,114,99,112,99,110,99
	dc.w	108,99,106,99,104,99,102,99,100,99
	dc.w	98,99,96,99,94,99,92,99,90,99
	dc.w	88,99,86,99,84,99,82,99,80,99
	dc.w	80,97,80,95,80,93,80,91,80,89
	dc.w	80,87
	dc.w	450

y_list	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w	16,17,18,19,20,21,22,23,24,25,26,27,28
	dc.w	29,30,31,32,33,34,35,36,37,38,39
	dc.w	40,40,40,40,40,40,40,40,40,40,40
	dc.w	40,40,40,40,40,40,40,40,40,40
	dc.w	40,40,40,40,40,40,40,40,40,40
	dc.w	40,40,40,40,40,40,40,40,40,40
	dc.w	39,38,37,36,35,34,33,32,31,30,29,28,27
	dc.w	26,25,24,23,22,21,20,19,18,17,16,15,14
	dc.w	13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,100

	end

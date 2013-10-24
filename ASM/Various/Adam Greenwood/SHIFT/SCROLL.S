* STE Video Shifter example program A
* Hardware vertical and horizontal scrolling
* Copyright c.1991 Adam Greenwood
* Feel free to change and use this code
* Written for/with Devpac 2
* This program can be run from medium res

* screen mode and colour constants

rgb	equ	$ff8240		colour registers
shiftmd	equ	$ff8260		shift mode

* screen address and scrolling constants

vbasehi	equ	$ff8201		screen base address high
vbasemd	equ	$ff8203		screen base address middle

vbaselo	equ	$ff820d		screen base address low		
linewid	equ	$ff820f		over-length line width
hscroll	equ	$ff8265		pixel scroll value

* The actual code starts here

start	move.l	a7,a5           
	move.l	#mystk,a7
	move.l	4(a5),a5		basepage
	move.l	$c(a5),d0		legth of text segment
	add.l	$14(a5),d0	length of data segment
	add.l	$1c(a5),d0	length of BSS
	add.l	#$100,d0		length of basepage
	move.l	d0,-(a7)		
	move.l	a5,-(a7)		
	move.w	#0,-(a7)		
	move.w	#$4a,-(a7)	shrink memory
	trap	#1
	add.l	#$c,a7

	clr.l	-(a7)
	move.w	#32,-(a7)		set supervisor mode
	trap	#1
	addq	#6,a7
	move.l	d0,save_stk	save old value of stack

* jump to routines which do actual work

	jsr	save_regs
	jsr	do_mess
	jsr	get_mem
	jsr	load_x4

	jsr	scroll

	jsr	rel_mem
	jsr	rest_regs
	
	bra	fin

* Save all the memory-mapped configuration registers which
* the program is going to change

save_regs	move.l	#spal,a6
	jsr	save_pal		save old palette
	
	move.b	vbasehi,oldvbhi	save registers
	move.b	vbasemd,oldvolo	
	move.b	vbaselo,oldvblo
	move.b	linewid,oldwid
	move.b	hscroll,oldhscr
	move.b	shiftmd,oldmode

	rts

* restore all the registers which have been changed

rest_regs	move.l	#spal,a6
	jsr	rest_pal		restore old palette

	move.b	oldvbhi,vbasehi	restore registers
	move.b	oldvolo,vbasemd
	move.b	oldvblo,vbaselo
	move.b	oldwid,linewid
	move.b	oldhscr,hscroll
	move.b	oldmode,shiftmd
	
	rts

* print message to screen, then turn cursor off

do_mess	move.l	#message,-(a7)
	move.w	#9,-(a7)		write string to screen
	trap	#1
	addq	#6,a7
	
	move.w	#-1,-(a7)
	move.w	#0,-(a7)
	move.w	#21,-(a7)		turn cursor off
	trap	#14
	addq	#6,a7

	rts

* Subroutine to allocate memory to this program

get_mem	move.l	#128002,-(a7)   	room for 4 screens 
	move.w	#72,-(a7)		allocate memory
	trap	#1
	addq	#6,a7
        	
	addq	#1,d0		
	bclr	#0,d0        	put address on word boundary
	move.l	d0,scrn_mem	save new screen address

	rts

* release memory previously allocated

rel_mem	move.l	scrn_mem,-(a7)
	move.w	#73,-(a7)		release memory
	trap	#1	
	addq	#6,a7
	
	rts

* Routine to load the same picture into memory 4 times.
* The first and second pairs of pictures are interleaved
* to give two levels each with a line length of 320 bytes,
* ie 640 pixels, ie two screens wide.

load_x4	move.l	#filename,a6	
	move.l	scrn_mem,a5
	jsr	load_pic
	add.l	#160,a5		
	jsr	load_pic

	move.l	scrn_mem,a5
	add.l	#64000,a5
	jsr	load_pic
	add.l	#160,a5
	jsr	load_pic
	
	rts

* Routine to load and interleave a picture into memory
* in: a6 = address of pathname, a5 = address of memory

load_pic	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#0,-(a7)
	move.l	a6,-(a7)
	move.w	#61,-(a7)		open file
	trap	#1
	move.w	d0,d6		d6 = file pointer
	addq	#8,a7
	
	move.w	#0,-(a7)		skip screen mode
	move.w	d6,-(a7)
	move.l	#2,-(a7)
	move.w	#66,-(a7)
	trap	#1
	add.l	#10,a7

	move.l	#palette,-(a7)	read palette
	move.l	#32,-(a7)
	move.w	d6,-(a7)
	move.w	#63,-(a7)
	trap	#1
	add.l	#12,a7

	move.l	#199,d5
loadit	move.l	a5,-(a7)
	move.l	#160,-(a7)	read picture 160 bytes
	move.w	d6,-(a7)		at a time
	move.w	#63,-(a7)
	trap	#1
	add.l	#12,a7
	add.l	#320,a5		skip 160 bytes to interleave
	dbra	d5,loadit		lines into one line 320 bytes long

	move.w	d6,-(a7)
	move.w	#62,-(a7)		close file
	trap	#1
	addq	#4,a7        

	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Routine to set up and look after scroll

scroll	move.l	#palette,a6
	jsr	rest_pal		set correct palette for pic
	move.b	#0,shiftmd	set low resolution

	move.l	scrn_mem,d3	screen base address (even)
	move.l	d3,d4

	lsr.l	#8,d3
	move.b	d3,vbasemd	middle byte
	lsr.l	#8,d3
	move.b	d3,vbasehi	high byte
	move.b	d4,vbaselo	low byte

	move.b	#0,hs_buff	hscroll buffer

	move.w	#0,screen_x	x position
	move.w	#0,screen_y	y position
	move.w	#2,h_speed	horizonatal speed
	move.w	#2,v_speed	vertical speed
	move.b	#0,h_direct	horizontal direction
	move.b	#0,v_direct	vertical direction

.loop	jsr	waitv		wait for vblank

	move.b	hs_buff,d0	get hscroll from buffer

	move.b	d0,hscroll	set hscroll
	move.b	#76,linewid
	cmp.b	#0,d0		set linewid depending on
	bne.s	.done		whether hscroll is 0
	move.b	#80,linewid

.done	move.w	screen_x,d0
	move.w	screen_y,d1	get current position
	move.w	h_speed,d2	and speed
	move.w	v_speed,d3
	
	move.b	h_direct,d4	horizontal direction
	beq.s	.addx		
	sub.w	d2,d0		scroll right
	bge.s	.x_set
	move.w	#320,d2		wrap around if <=0
	add.w	d0,d2
	move.w	d2,d0		
	bra.s	.x_set

.addx	add.w	d2,d0		scroll left
	move.w	d0,d2
	sub.w	#320,d2
	blt.s	.x_set		wrap around if >=320
	move.w	d2,d0

.x_set	move.b	v_direct,d5	vertical direction
	beq.s	.addy
	sub.w	d3,d1		scroll down
	bge.s	.y_set
	move.w	#200,d3		if <=0 wrap around
	add.w	d1,d3
	move.w	d3,d1
	bra.s	.y_set

.addy	add.w	d3,d1		scroll up
	move.w	d1,d3
	sub.w	#200,d3
	blt.s	.y_set		if >= 200 wrap around
	move.w	d3,d1

.y_set	move.w	d0,screen_x	save x and y position
	move.w	d1,screen_y

	move.l	scrn_mem,d3	screen memory base	

	mulu	#320,d1
	add.l	d1,d3		add y lines
	
	ext.l	d0
	divu	#16,d0
	move.l	d0,d2		no. of pixels to scroll
	mulu	#8,d0		no. of bytes to add to 
	add.l	d0,d3		base address

	swap	d2		
	move.b	d2,hs_buff	buffer pixel value
	move.l	d3,d4	
	lsr.l	#8,d3
	move.b	d3,vbasemd	base address middle
	lsr.l	#8,d3
	move.b	d3,vbasehi	base address high
	move.b	d4,vbaselo	base address low

* now monitor key presses and change speed/direction
* plus check for space in order to quit

	jsr	get_key
	swap	d0
	cmp.b	#57,d0		space = quit
	beq	.out

	cmp.b	#59,d0		f1
	bne.s	.f2
	move.w	h_speed,d0
	cmp.w	#0,d0
	ble	.loop
	sub.w	#1,d0		reduce horizontal speed
	move.w	d0,h_speed
	bra	.loop

.f2	cmp.b	#60,d0		f2
	bne.s	.f3
	move.w	h_speed,d0
	cmp.w	#4,d0
	bge	.loop
	add.w	#1,d0		increase horizontal speed
	move.w	d0,h_speed
	bra	.loop

.f3	cmp.b	#61,d0		f3
	bne.s	.f4
	move.w	v_speed,d0
	cmp.w	#0,d0
	ble	.loop
	sub.w	#1,d0		reduce vertical speed
	move.w	d0,v_speed
	bra	.loop

.f4	cmp.b	#62,d0		f4
	bne.s	.f5
	move.w	v_speed,d0
	cmp.w	#4,d0
	bge	.loop
	add.w	#1,d0		increase vertical speed
	move.w	d0,v_speed
	bra	.loop

.f5	cmp.b	#63,d0		f5
	bne.s	.f6
	bchg	#0,h_direct	change horizontal direction
	bra	.loop
	
.f6	cmp.b	#64,d0		f6
	bne.s	.f7
	bchg	#0,v_direct	change vertical direction
	bra	.loop

.f7	bra	.loop	

.out	rts

* Routine to get key press
* 0 if no character ready

get_key	movem.l	d1-d7/a0-a6,-(a7)
	clr.l	d0
	move.w	#255,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq	#4,a7
	movem.l	(a7)+,d1-d7/a0-a6
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

* Return to user mode and exit

fin     	move.l	save_stk,-(a7)
	move.w	#32,-(a7)
	trap	#1              	return to user mode
	addq	#6,a7

	move.w	#0,-(a7)		exit
	trap	#1	

	section	bss

* global variables

* old register values

oldvbhi	ds.b	1
oldvolo	ds.b	1
oldvblo	ds.b	1
oldwid	ds.b	1
oldhscr	ds.b	1
oldmode	ds.b	1
	even
spal	ds.w	16

* screen memory address

scrn_mem	ds.l	1

* new palette

palette	ds.b	32    

* old stack

save_stk	ds.l	1

* scroll variables

screen_x	ds.w	1
screen_y	ds.w	1
h_speed	ds.w	1
v_speed	ds.w	1
h_direct	ds.b	1
v_direct	ds.b	1

hs_buff	ds.b	1

	even
	
* New stack

	ds.l	250
mystk	ds.l	1

	section	data

filename	dc.b	'SCROLL.PI1',0

message	dc.b	'STE Hardware Scrolling Demo',13,10,13,10
	dc.b	'Copyright ',189,'1991 Adam Greenwood',13,10,13,10
	dc.b	'Loading Pictures...',13,10,13,10
	dc.b	'Once Loaded, Function keys',13,10
	dc.b	'control scroll:',13,10,13,10
	dc.b	'F1/F2 - Horizontal Speed 0-4',13,10
	dc.b	'F3/F4 - Vertical Speed 0-4',13,10
	dc.b	'F5 - Change vertical direction',13,10
	dc.b	'F6 - Change horizontal direction',0 

	end
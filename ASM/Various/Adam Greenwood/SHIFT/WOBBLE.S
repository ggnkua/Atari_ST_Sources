* STE Video Shifter Example Program B
* Improved palette and hardware screen 'wobble'
* Copyright c.1991 A Greenwood
* Feel free to change and use this code
* Written with/for Devpac 2
* This program can be run from medium res.

* screen register constants

rgb	equ	$ff8240		colour registers
shiftmd	equ	$ff8260		shift mode register

* screen address and scrolling
* constants
	
vbasehi	equ	$ff8201		screen base address high
vbasemd	equ	$ff8203		screen base address mid
vbaselo	equ	$ff820d		screen base address low
linewid	equ	$ff820f		over-length line width
hscroll	equ	$ff8265		pixel scroll value

* System variables for interrupts

vblno	equ	$454		no of Vblank routines
vblqu	equ	$456		Vblank queue
hblank	equ	$120		Hblank vector
keyhnd	equ	$118		key handler vector

* MC68901 MFP Addresses

iea	equ	$fffa07		interrupt enable A
ieb	equ	$fffa09		interrupt enable B
isra	equ	$fffa0f		interrupt in service A
ima	equ	$fffa13		interrupt mask A
tbcr	equ	$fffa1b		Timer B control
tbdr	equ	$fffa21		Timer B data

* The actual code

start	move.l	a7,a5           
	move.l	#mystk,a7
	move.l	4(a5),a5		basepage
	move.l	$c(a5),d0		length of text segment
	add.l	$14(a5),d0	length of data segment
	add.l	$1c(a5),d0	length of uninit BSS
	add.l	#$100,d0		length of basepage
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.w	#0,-(a7)
	move.w	#$4a,-(a7)	shrink memory
	trap	#1
	add.l	#$c,a7

	clr.l	-(a7)		set supervisor mode
	move.w	#32,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,save_stk	save old value of stack

	jsr	save_regs		save hardware registers used
	jsr	do_mess		message to screen
	jsr	get_mem		allocate memory
	
	move.l	#filename,a6	
	move.l	scrn_mem,a5
	jsr	load_pic		load picture

	jsr	init_fade		initialise palette
	
	jsr	wobble		initialise wobble
	jsr	fade		main loop of program

	jsr	rel_mem		release memory
	jsr	rest_int		tidy up interrupts
	jsr	rest_regs		restore hardware registers
	
	bra	fin		end of program

* routine to save all screen registers changed by this program

save_regs	move.l	#spal,a6		save old palette
	jsr	save_pal
	
	move.b	vbasehi,oldvbhi	save screen address high
	move.b	vbasemd,oldvbmd	..middle
	move.b	vbaselo,oldvblo	..and low
	move.b	linewid,oldwid	line width
	move.b	hscroll,oldhscr	hscroll register
	move.b	shiftmd,oldmode	screen mode

	rts

* routine to restore all screen registers as saved above

rest_regs	move.b	oldvbhi,vbasehi	
	move.b	oldvbmd,vbasemd
	move.b	oldvblo,vbaselo
	move.b	oldwid,linewid
	move.b	oldhscr,hscroll
	move.b	oldmode,shiftmd

	move.l	#spal,a6
	jsr	rest_pal		restore palette
	
	rts

* routine to write intro message to screen

do_mess	move.l	#message,-(a7)	intro message
	move.w	#9,-(a7)		write string
	trap	#1
	addq	#6,a7

	move.w	#-1,-(a7)		turn cursor off
	move.w	#0,-(a7)
	move.w	#21,-(a7)
	trap	#14
	addq	#6,a7

	rts

* routine to allocate memory to this program

get_mem	move.l	#33602,-(a7)   	room for 1 screen plus 
	move.w	#72,-(a7)		16 pixels at end of 
	trap	#1		each line
	addq	#6,a7
        
	addq	#1,d0		set to even boundary
	bclr	#0,d0        
	move.l	d0,scrn_mem	screen memory address
	
	move.l	d0,a0
	add.l	#35200,d0
.clear	move.l	#0,(a0)+		clear screen memory
	cmp.l	d0,a0	
	ble.s	.clear

	move.l	#5120,-(a7)   	room for all palettes
	move.w	#72,-(a7)
	trap	#1
	addq	#6,a7
        
	addq	#1,d0		set to even address
	bclr	#0,d0        
	move.l	d0,fade_mem	palette memory address

	rts
	
* routine to release all memory allocated back to the operating system

rel_mem	move.l	fade_mem,-(a7)	release palette memory
	move.w	#73,-(a7)
	trap	#1
	addq	#6,a7
	
	move.l	#scrn_mem,-(a7)	release screen memory
	move.w	#73,-(a7)
	trap	#1
	addq	#6,a7
	
	rts

* Routine to load a picture into memory
* a6 = address of pathname, a5 = address of memory

load_pic	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#0,-(a7)
	move.l	a6,-(a7)
	move.w	#61,-(a7)		open file
	trap	#1
	move.w	d0,d6		d6 = file pointer
	addq	#8,a7

	move.w	#0,-(a7)
	move.w	d6,-(a7)
	move.l	#34,-(a7)		skip mode and palette info
	move.w	#66,-(a7)
	trap	#1
	add.l	#10,a7

	move.l	#199,d5
.loadit	move.l	a5,-(a7)
	move.l	#160,-(a7)	read picture 160 bytes
	move.w	d6,-(a7)		at a time
	move.w	#63,-(a7)
	trap	#1
	add.l	#12,a7
	add.l	#168,a5		leave a space at end of line
	dbra	d5,.loadit

	move.w	d6,-(a7)
	move.w	#62,-(a7)		close file
	trap	#1
	addq	#4,a7        

	movem.l	(a7)+,d0-d7/a0-a6
	rts

* routine to load all the predefined 'fades' and get the first
* one ready. This routine also sets low resolution

init_fade	move.l	#fadenames,a6	filenames
	move.l	fade_mem,a5	space for palettes
	move.l	#fades,a4		table of addresses

.loop	move.l	a5,(a4)+		store address of 'fade'
	jsr	load_fade		load 16 palettes
	add.l	#512,a5
.find0	move.b	(a6)+,d0
	bne.s	.find0		find end of filename
	move.b	(a6),d0		if next byte not 0
	bne.s	.loop		load next file
	
	move.l	#fades,a0		set current palette to 
	move.l	(a0),a6		last palette of first fade
	add.l	#480,a6
	jsr	rest_pal
	move.w	#0,cur_fade
	
	move.b	#0,shiftmd	set low resolution
	
	rts

* Routine to load a fade into memory
* a6 = address of filename, a5 = address of memory

load_fade	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#0,-(a7)
	move.l	a6,-(a7)
	move.w	#61,-(a7)		open file
	trap	#1
	move.w	d0,d6		d6 = file pointer
	addq	#8,a7

	move.l	a5,-(a7)	
	move.l	#512,-(a7)	read 512 bytes
	move.w	d6,-(a7)
	move.w	#63,-(a7)
	trap	#1
	add.l	#12,a7

	move.w	d6,-(a7)
	move.w	#62,-(a7)		close file
	trap	#1
	addq	#4,a7        

	movem.l	(a7)+,d0-d7/a0-a6
	rts

* routine to get keypress and set palette fade accordingly

fade	move.l	#fades,a0
	move.l	(a0),a6
	jsr	fade_in		fade in first palette

.loop	jsr	wait_key		wait for key press
	cmp.b	#32,d0		if space quit
	beq.s	.out
	
	swap	d0		get scan code
	
	sub.b	#59,d0		check if it is a function
	blt.s	.loop		key
	cmp.b	#9,d0
	bgt.s	.loop
	
	ext.w	d0
	move.w	d0,d1

	move.w	cur_fade,d0	index of current 'fade'
	move.l	#fades,a0		table of fade addresses
	mulu	#4,d0	
	add.w	d0,a0
	move.l	(a0),a6		address of current fade
	jsr	fade_out		fade out current palette
	
	move.w	d1,cur_fade	use f-key no. to index
	move.l	#fades,a0		table of fade addresses
	mulu	#4,d1		for new fade
	add.w	d1,a0
	move.l	(a0),a6
	jsr	fade_in		fade in new palette
	
	bra	.loop		back for next key press

.out	move.l	#fades,a0		fade out current palette
	move.w	cur_fade,d0
	mulu	#4,d0
	add.w	d0,a0
	move.l	(a0),a6
	jsr	fade_out

	rts

* Routine to wait for a key 
* press and return code in d0.l

wait_key	movem.l	d1-d7/a0-a6,-(a7)
	clr.l	d0
	move.w	#7,-(a7)		get key press
	trap	#1
	addq	#2,a7
	movem.l	(a7)+,d1-d7/a0-a6
	rts

* Routine to wait for Vblank & return

waitv	movem.l	a0-a3/d0-d3,-(a7)
	move.w	#37,-(a7)
	trap	#14		wait for Vblank
	addq	#2,a7
	movem.l	(a7)+,a0-a3/d0-d3
	rts
	
* Subroutine to save pallette to address in A6

save_pal	movem.l	d0/a0/a6,-(a7)

	move.l	#rgb,a0		rgb registers
	move.w	#15,d0		16 colours
.save	move.w	(a0)+,(a6)+	copy
	dbra	d0,.save
	
	movem.l	(a7)+,d0/a0/a6	
	rts

* Subroutine to Restore Pallette at address in A6

rest_pal	movem.l	d0/a0/a6,-(a7)

	move.l	#rgb,a0		rgb registers
	move.w	#15,d0		16 colours
.rest	move.w	(a6)+,(a0)+	copy
	dbra	d0,.rest
	
	movem.l	(a7)+,d0/a0/a6	
	rts

* routine to fade in through a 
* series of palettes.
* in: a6 = address of palettes

fade_in	movem.l	d1/a6,-(a7)

	add.l	#480,a6		last palette
	move.w	#15,d1		16 palettes
.loop	jsr	waitv		synchronise
	jsr	rest_pal		set palette
	sub.l	#32,a6		next palette
	dbra	d1,.loop
	
	movem.l	(a7)+,d1/a6
	rts

* routine to fade out through a 
* series of palettes.
* in: a6 = address of palettes

fade_out	movem.l	d1/a6,-(a7)

	move.w	#15,d1		16 palettes
.loop	jsr	waitv		synchronise
	jsr	rest_pal		set palette
	add.l	#32,a6		next palette
	dbra	d1,.loop
	
	movem.l	(a7)+,d1/a6
	rts

* Now the code for the hardware 'wobble':

* routine which sets up and starts hardware screen wobble

wobble	move.l	scrn_mem,d3	screen memory address
	move.l	d3,d4
	lsr.l	#8,d3		set screen address:
	move.b	d3,vbasemd	middle byte
	lsr.l	#8,d3
	move.b	d3,vbasehi	high byte
	move.b	d4,vbaselo	low byte

	move.b	#0,linewid	skip 4 words (4-4=0)
	move.b	#8,hscroll	middle position
	
* Set up variables for hblank list

	move.l	#hlist,wobstrt	start of list
	move.w	#0,lcount		line count to move wobble
	move.b	#9,vcount		slow down wobble change
	
	jsr	init_int		initialise interrupts

	rts
	
* routine to initialise all the interrupts used to control 
* the screen wobble

init_int	movem.l	d0-d7/a0-a6,-(a7)

* First replace key handler to avoid flicker from mouse

	move.l	#keyhnd,a0
	move.l	(a0),a1		address of current routine
	move.l	keyhnd,oldkey	save it
	move.l	#newoky,a2
	addq	#2,a2		give address to new routine
	move.l	a1,(a2)
	move.l	#newkey,(a0)	replace old with new one

* now replace vblank queue with new queue which has our vblank routine
* added to it

	jsr	waitv		do it just after vblank
	moveq	#0,d0   
	move.w	vblno,d0		get old number of vblank routines
	move.w	d0,d7
	move.w	d0,oldvbn		save old number
	move.l	vblqu,a6		get old Vblank queue address
	move.l	a6,oldvbq		save old address

	move.w	d0,d2
	mulu	#4,d2
	addq	#4,d2		old queue size + 1 address
	
	move.l	d2,-(a7)   	room for new vblank queue
	move.w	#72,-(a7)
	trap	#1
	addq	#6,a7
        
	addq	#1,d0
	bclr	#0,d0        
	move.l	d0,qu_mem		save address of new queue
	
	move.l	d0,a1
	move.w	d7,d0       
	subq	#1,d0

copyqu	move.l	(a6)+,(a1)+	copy old queue into our new one
	dbra	d0,copyqu
	move.l	qu_mem,vblqu	set our queue as new one

	move.l	#vbl_rtn,(a1)+	add new routine to queue
	addq	#1,d7           
	move.w	d7,vblno		add one to number of routines
        
* save mk registers

	move.b	ieb,oldieb
	move.b	iea,oldiea
	move.b	ima,oldima
	move.b	tbdr,oldtbdr
	move.b	tbcr,oldtbcr

	move.l	hblank,oldhbv	save old hblank vector

	and.b	#$df,ieb		disable 200Hz Interrupt
	and.b	#$fe,iea		disable Hblank Interrupt

	move.l	#hbl_rtn,hblank 	set new hblank routine

	move.b	#0,tbcr		stop timer

	or.b	#1,iea		Re-enable Hblank interrupt
	or.b	#1,ima

	movem.l	(a7)+,d0-d7/a0-a6
	rts

* routine to clean up after the interrupts

rest_int	move.w	sr,-(a7)		save status register
	move.w	#$2700,sr		disable all interrupts

	move.l	oldkey,keyhnd	restore all registers
	move.l	oldhbv,hblank	and vectors which were
	move.b	oldieb,ieb	changed
	move.b	oldiea,iea
	move.b	oldima,ima
	move.b	oldtbcr,tbcr
	move.b	oldtbdr,tbdr
	move.w	oldvbn,vblno
	move.l	oldvbq,vblqu
	
	move.l	qu_mem,-(a7)	release memory used by
	move.w	#73,-(a7)		vblank queue
	trap	#1
	addq	#6,a7

	move.w	(a7)+,sr		restore status register
	rts

* Interrupt Handlers:

* New key handling routine to stop mouse disrupting display

newkey	move.w	#$2500,sr
newoky	jmp	$0		jump to old routine

* Vblank routine which is added to queue and called every Vblank

vbl_rtn	movem.l	a0/d0-d1,-(a7)

	move.b	#0,tbcr		stop timer B

	move.w	lcount,d0		move wobble up 1 line every 
	add.w	#1,d0		vblank
	cmp.w	#36,d0
	blt.s	.save
	move.w	#0,d0
.save	move.w	d0,lcount

	move.l	wobstrt,a0	address of set of data

	move.b	vcount,d1		change set every 9 vblanks
	sub.b	#1,d1		( this can be any no.)
	bne.s	.set_up
	move.b	#9,d1

	add.l	#37,a0		move on to next set of data
	cmp.l	#endlst,a0	wrap if necessary
	bne.s	.set_up
	move.l	#hlist,a0
.set_up	move.l	a0,wobstrt	address of data set
	move.b	d1,vcount		

	add.w	d0,a0
	move.b	(a0)+,d0		next wobble value
	move.b	d0,hscroll	set hscroll for first line
	move.l	a0,wobptr		save list pointer

	move.b	#1,tbdr		interrupt every line
	move.b	#8,tbcr		restart timer
	movem.l	(a7)+,a0/d0-d1

	rts
        
* HBlank routine called every line

hbl_rtn	movem.l	a0-a1/d0-d1,-(a7) 

	move.l	wobptr,a0		list pointer
	move.b	(a0)+,d1		next value from list
	cmp.b	#20,d1		if 20, end of list
	bne.s	.doit
	move.l	wobstrt,a0	so back to start
	move.b	(a0)+,d1	
.doit	move.b	d1,hscroll	set hscroll for next line
	move.l	a0,wobptr		save pointer
	
	move.b	#1,tbdr		interrupt on next line
	bclr	#0,isra         	re-enbale lower level interupts

	movem.l	(a7)+,a0-a1/d0-d1
	rte

* Return to user mode and exit

fin     	move.l	save_stk,-(a7)
	move.w	#32,-(a7)
	trap	#1		return to user mode
	addq	#6,a7

	move.w	#0,-(a7)		exit
	trap	#1

	section	bss

* global variables

* storage for saved vectors and registers

oldkey	ds.l	1   
oldvbn	ds.w	1
oldvbq	ds.l	1
oldhbv	ds.l	1
oldieb	ds.b	1
oldiea	ds.b	1
oldima	ds.b	1
oldtbcr	ds.b	1
oldtbdr	ds.b	1

	even

qu_mem	ds.l	1		address of  new Vblank queue

wobstrt	ds.l	1		address of set of data
wobptr	ds.l	1		pointer to next item
lcount	ds.w	1		start line
vcount	ds.b	1		vblank count

* storage for screen registers

oldvbhi	ds.b	1
oldvbmd	ds.b	1
oldvblo	ds.b	1
oldwid	ds.b	1
oldhscr	ds.b	1
oldmode	ds.b	1
	even
	
* Memory addresses

scrn_mem	ds.l	1
fade_mem	ds.l	1

* Fade table

fades	ds.l	10
cur_fade	ds.w	1

save_stk	ds.l	1		original stack
spal	ds.w	16		original palette

	ds.l	250
mystk	ds.l	1		new stack

	section	data

* DEGAS picture filename

filename	dc.b	'WOBBLE.PI1',0

* filenames for files of 16 palettes from STEPal

fadenames	dc.b	'FADES\GREY1.ALP',0
	dc.b	'FADES\RED.ALP',0
	dc.b	'FADES\GREEN.ALP',0
	dc.b	'FADES\BLUE.ALP',0
	dc.b	'FADES\CYAN.ALP',0
	dc.b	'FADES\MAGENTA.ALP',0
	dc.b	'FADES\YELLOW.ALP',0
	dc.b	'FADES\BROWN.ALP',0
	dc.b	'FADES\INV_BLUE.ALP',0
	dc.b	'FADES\INVERSE.ALP',0
	dc.b	0
	
* intro message

message	dc.b	'STE Special Effects Demo',13,10,13,10
	dc.b	'Copyright ',189,'1991 Adam Greenwood',13,10,13,10
	dc.b	'Loading Picture and Palette data...',13,10,13,10
	dc.b	'Once loaded, F Keys change palette.',0

* lists of offsets for consecutive lines, each list being
* a set of data for a particular size sine wave

hlist	dc.b	8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,20

	dc.b	8,8,8,9,9,9,9,9,9,9,9,9
	dc.b	9,9,9,9,8,8,8,8,8,7,7,7
	dc.b	7,7,7,7,7,7,7,7,7,7,8,8,20
	
	dc.b	8,8,9,9,9,10,10,10,10,10,10,10
	dc.b	10,10,9,9,9,8,8,8,7,7,7,6
	dc.b	6,6,6,6,6,6,6,6,7,7,7,8,20
	
	dc.b	8,9,9,10,10,10,11,11,11,11,11,11
	dc.b	11,10,10,10,9,9,8,7,7,6,6,6
	dc.b	5,5,5,5,5,5,5,6,6,6,7,7,20
	
	dc.b	8,9,9,10,11,11,11,12,12,12,12,12
	dc.b	11,11,11,10,9,9,8,7,7,6,5,5
	dc.b	5,4,4,4,4,4,5,5,5,6,7,7,20
	
	dc.b	8,9,10,11,11,12,12,13,13,13,13,13
	dc.b	12,12,11,11,10,9,8,7,6,5,5,4
	dc.b	4,3,3,3,3,3,4,4,5,5,6,7,20
	
	dc.b	8,9,10,11,12,13,13,14,14,14,14,14
	dc.b	13,13,12,11,10,9,8,7,6,5,4,3
	dc.b	3,2,2,2,2,2,3,3,4,5,6,7,20
	
	dc.b	8,9,10,11,12,13,14,15,15,15,15,15
	dc.b	14,13,12,11,10,9,8,7,6,5,4,3
	dc.b	2,1,1,1,1,1,2,3,4,5,6,7,20

	dc.b	8,9,10,11,12,13,13,14,14,14,14,14
	dc.b	13,13,12,11,10,9,8,7,6,5,4,3
	dc.b	3,2,2,2,2,2,3,3,4,5,6,7,20

	dc.b	8,9,10,11,11,12,12,13,13,13,13,13
	dc.b	12,12,11,11,10,9,8,7,6,5,5,4
	dc.b	4,3,3,3,3,3,4,4,5,5,6,7,20

	dc.b	8,9,9,10,11,11,11,12,12,12,12,12
	dc.b	11,11,11,10,9,9,8,7,7,6,5,5
	dc.b	5,4,4,4,4,4,5,5,5,6,7,7,20

	dc.b	8,9,9,10,10,10,11,11,11,11,11,11
	dc.b	11,10,10,10,9,9,8,7,7,6,6,6
	dc.b	5,5,5,5,5,5,5,6,6,6,7,7,20

	dc.b	8,8,9,9,9,10,10,10,10,10,10,10
	dc.b	10,10,9,9,9,8,8,8,7,7,7,6
	dc.b	6,6,6,6,6,6,6,6,7,7,7,8,20

	dc.b	8,8,8,9,9,9,9,9,9,9,9,9
	dc.b	9,9,9,9,8,8,8,8,8,7,7,7
	dc.b	7,7,7,7,7,7,7,7,7,7,8,8,20

endlst	dc.b	0
	
	end

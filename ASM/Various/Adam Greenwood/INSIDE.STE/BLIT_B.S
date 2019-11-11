* STE Blitter Chip example program A
* Multiple Blitter Chip Sprites on double buffered background
* Copyright c.1991 Adam Greenwood
* Feel free to change and use this code
* Written for/with Devpac 2
* This program can be run from medium res

* If this program is assembled to memory ensure that the filenames
* in the DATA section include the full path name, if the files 
* are not in the root directory

* This program uses 3 background pictures, two for display and 
* a 'spare' which simulates the ability in a mapped game to 
* rebuild the background behind a sprite without having to
* save it.

* constants:

* screen address and scrolling constants

vbasehi	equ	$ff8201		screen base address high
vbasemd	equ	$ff8203		screen base address middle
vbaselo	equ	$ff820d		screen base address low		

shiftmd	equ	$ff8260		shift mode
rgb	equ	$ff8240		rgb colour registers

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

sprt_no1	equ	1		2 32x32 sprites
sprt_no2	equ	7		8 32x16 sprites
sprt_no3	equ	5		6 16x16 sprites

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
        
	clr.l	-(a7)		set supervisor mode
	move.w	#32,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,save_stk

	move.w	#$80,-(a7)	disable and get status
	move.w	#64,-(a7)		blitmode
	trap	#14
	addq	#4,a7
	
	btst	#1,d0		check blitter exists
	beq	fin		if not finish

	jsr	save_regs		save all registers
	jsr	get_mem		allocate memory

	jsr	do_mess		print screen message
	jsr	load_all		load pictures

	move.l	#new_pal,a6		
	jsr	rest_pal		set new palette

	jsr	sprites		jump to main routine
	
	jsr	rel_mem		release memory
	jsr	rest_regs		restore registers
	bra	fin		finish

* Main routine which initialises and looks after the sprites,
* swaps the screens etc.

sprites	jsr	waitv		synchronise
	move.b	#0,shiftmd	set low resolution
	move.l	scrn2_mem,d0	on screen
	jsr	set_scrn		set screen address
	jsr	waitv		wait for new screen

* initialise the tables of sprite information for the three 
* sets of different sized sprites. 

	move.l	#sprt_inf1,a0	table 1 (32x32)
	move.l	#coords1,a1	start of coordinates list
	move.w	#sprt_no1,d0	no. of sprites - 1
.init1	move.l	a1,(a0)		address of coords
	move.l	#0,4(a0)		background offset
	add.l	#12,a0		next entry
	add.l	#252,a1		move along coords list
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
	add.l	#20,a1		move along coords list
	dbra	d0,.init3		

	move.l	scrn1_mem,a5	off screen 
	move.l	scrn2_mem,a4	on screen
	
.loop	move.l	#sprt3_set,a0	dimensions for blit
	jsr	init_sprt		set up blitter for sprite

	move.l	#sprt_inf3,a3	table 3 (16x16)
	move.w	#sprt_no3,d7	no. of sprites - 1
	move.l	sprt_mem,a0	address of sprite memory
	add.l	#32,a0		offset for 16x16 sprite
	move.w	#16,d3		16 lines per sprite
	move.l	#coords3,d6	start of coords list
	jsr	do_sprite		draw all 16x16 sprites
	
	move.l	#sprt2_set,a0	dimensions for blit
	jsr	init_sprt		set up blitter for sprite

	move.l	#sprt_inf2,a3	table 2 (32x16)
	move.w	#sprt_no2,d7	no. of sprites - 1
	move.l	sprt_mem,a0	sprite memory
	add.l	#16,a0		offset for 32x16 sprite
	move.w	#16,d3		16 lines per sprite
	move.l	#coords2,d6	start of coords list
	jsr	do_sprite		draw all 32x16 sprites

	move.l	#sprt1_set,a0	dimensions for blit
	jsr	init_sprt		set up blitter for sprite

	move.l	#sprt_inf1,a3	table 1 (32x32)
	move.w	#sprt_no1,d7	no. of sprites - 1
	move.l	sprt_mem,a0	sprite memory
	move.w	#32,d3		32 lines per sprite
	move.l	#coords1,d6	start of coords list
	jsr	do_sprite		draw all 32x32 sprites
	
	exg.l	a4,a5		swap screens
	move.l	a4,d0		new on screen
	jsr	set_scrn		set new on screen
	jsr	waitv		synchronise

	move.l	#back3_set,a0	
	jsr	init_back		set up background restore

	move.l	#sprt_inf3,a3	table 3 (16x16)
	move.w	#sprt_no3,d7	no. of sprites - 1
	move.w	#16,d3		no. of lines
	jsr	undo_sprt		restore background

	move.l	#back2_set,a0
	jsr	init_back		set up background restore

	move.l	#sprt_inf2,a3	table 2 (32x16)
	move.w	#sprt_no2,d7	no. of sprites - 1
	move.w	#16,d3		no. of lines
	jsr	undo_sprt		restore background

	move.l	#back1_set,a0
	jsr	init_back		set up background restore

	move.l	#sprt_inf1,a3	table 1
	move.w	#sprt_no1,d7	no. of sprites - 1
	move.w	#32,d3		32 lines
	jsr	undo_sprt		restore background
	
	jsr	get_key		check for key press
	swap	d0		use high word (scan code)
	cmp.b	#57,d0		57 = space = quit
	bne	.loop

	rts

* routine to look after one set of sprites
* in:	d7 = no. of sprites - 1
*	a0 = address of sprite
*	a3 = address of sprite info table
* 	d3 = y count (no. of lines)
* 	a5 = address of off screen
*	d6 = address of start of coords list

do_sprite	move.l	(a3),a2		address of coords
	move.w	(a2)+,d0		d0 = x coord
	cmp.w	#400,d0		wrap around if x > 400
	ble 	.less
	move.l	d6,a2		start of coordinates list
	move.w	(a2)+,d0		d0 = x coord
.less	move.w	(a2)+,d1		d0 = y coord
	move.l	a2,(a3)		save list pointer
	
	jsr	convert		d2 = skew, a6 = offset

	move.l	a5,a1		screen address
	add.l	a6,a1		add offset
	move.l	a6,8(a3)		save offset for undraw
	jsr 	sprt_blit		blit sprite

	add.l	#12,a3		next info entry
	dbra	d7,do_sprite
	
	rts
	
* routine to restore background where a sprite was
* for one set of sprites
* restores on off screen, so uses last but one background adderss

undo_sprt	move.l	4(a3),a6		old save address
	move.l	8(a3),d6		new save address
	move.l	d6,4(a3)		old = new

	move.l	a5,a1		off screen
	add.l	a6,a1		background offset
	move.l	back_mem,a0	background pic
	add.l	a6,a0		
	jsr	back_blit		restore background

	add.l	#12,a3		next entry
	dbra	d7,undo_sprt
	
	rts

* routine to convert x and y coordinates into screen base offset 
* and skew value
* in : d0.w = x
*      d1.w = y
* out: d2.w = shift value
*      a6.l = address offset

convert	movem.l	d0-d1,-(a7)

	mulu	#160,d1		address of correct line
	move.l	d1,a6		

	ext.l	d0
	divu	#16,d0		address of block 
	swap	d0		
	move.w	d0,d2		d2.w	= shift no.
	swap	d0		remainder
	mulu	#8,d0		amount to shift
	add.w	d0,a6		a6 = offset

	movem.l	(a7)+,d0-d1
	rts

* routine to initialise blitter chip for a sprite routine
* a0 = address of set up table, which is simply a list 
* of the correct values for the blitter registers needed
* to set up the blitter chip

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

* Save all the memory-mapped configuration registers which
* the program is going to change

save_regs	move.l	#old_pal,a6
	jsr	save_pal		save old palette
	
	move.b	vbasehi,oldvbhi	save registers
	move.b	vbasemd,oldvbmd	
	move.b	vbaselo,oldvblo
	move.b	shiftmd,oldmode

	rts

* restore all the registers which have been changed

rest_regs	jsr	waitv		synchronise

	move.l	#old_pal,a6
	jsr	rest_pal		restore old palette

	move.b	oldmode,shiftmd
	move.b	oldvbhi,vbasehi	restore registers
	move.b	oldvbmd,vbasemd
	move.b	oldvblo,vbaselo
	
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

get_mem	move.l	#128002,-(a7)   	room for 3 screens + sprites
	move.w	#72,-(a7)		allocate memory
	trap	#1
	addq	#6,a7
        	
	addq	#1,d0		
	bclr	#0,d0        	put address on word boundary
	move.l	d0,scrn1_mem	save new screen address
	add.l	#32000,d0
	move.l	d0,scrn2_mem	address of second screen
	add.l	#32000,d0
	move.l	d0,back_mem	address of third screen
	add.l	#32000,d0
	move.l	d0,sprt_mem	address of sprite memory
	
	rts

* release memory previously allocated

rel_mem	move.l	scrn1_mem,-(a7)
	move.w	#73,-(a7)		release memory
	trap	#1	
	addq	#6,a7
	
	rts

* routine to load background and sprite pictures

load_all	move.l	#sprt_file,a6	sprite pic
	move.l	sprt_mem,a5
	jsr	load_pic

	move.l	#scrn_file,a6	screen 1
	move.l	scrn1_mem,a5
	jsr	load_pic

	move.l	#scrn_file,a6	screen 2
	move.l	scrn2_mem,a5
	jsr	load_pic

	move.l	#scrn_file,a6	background for restore
	move.l	back_mem,a5
	jsr	load_pic
	
	rts
	

* Routine to load a picture into memory
* A6 = address of pathname, A5 = address of memory

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

	move.l	a5,-(a7)		address of memory
	move.l	#32000,-(a7)	32k bytes
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

* Return to user mode and exit

fin	move.l	save_stk,-(a7)
	move.w	#32,-(a7)
	trap	#1		Return to user mode
	addq	#6,a7

	move.w	#0,-(a7)
	trap	#1
	addq	#2,a7

	section bss

oldmode	ds.b	1
oldvbhi	ds.b	1
oldvbmd	ds.b	1
oldvblo	ds.b	1

pic_mode	ds.w	1
new_pal	ds.w	16
old_pal	ds.w	16

scrn1_mem	ds.l	1
scrn2_mem	ds.l	1
back_mem	ds.l	1	
sprt_mem	ds.l	1

sprt_inf1	ds.l	60
sprt_inf2	ds.l	60
sprt_inf3	ds.l	60

save_stk	ds.l	1

	section data

sprt_file	dc.b	'SPRITES.PI1',0	sprite pic
scrn_file	dc.b	'BLIT.PI1',0	background pic

message	dc.b	'Blitter Chip Multi Sprite Demo',10,13,10,13
	dc.b	'Copyright ',189,'1991 Adam Greenwood',10,13,10,13
	dc.b	'Loading Pic and Sprites...',0

	even

* Data used to initialise blitter chip for each operation

sprt1_set	dc.w	3		x count
	dc.w	8		source x inc.
	dc.w	144		source y inc.
	dc.w	8		dest x inc.
	dc.w	144		dest y inc.

sprt2_set	dc.w	3
	dc.w	8
	dc.w	144
	dc.w	8
	dc.w	144
	
sprt3_set	dc.w	2
	dc.w	8
	dc.w	152
	dc.w	8
	dc.w	152

back1_set	dc.w	12		
	dc.w	2		
	dc.w	138          	
	dc.w	2		
	dc.w	138        	

back2_set	dc.w	12		
	dc.w	2		
	dc.w	138          	
	dc.w	2		
	dc.w	138        	

back3_set	dc.w	8		
	dc.w	2		
	dc.w	146          	
	dc.w	2		
	dc.w	146        	

* three sets of coordinates which the three sets of sprites 
* follow around the screen.

coords1	dc.w	254,079
	dc.w	253,086
	dc.w	252,092,248,102,244,107,240,112,236,117
	dc.w	232,121,228,124,224,127,220,129,216,132
	dc.w	212,134,208,136,204,138,200,139,196,140
	dc.w	192,142,188,143,184,144,180,145,176,146
	dc.w	172,147,168,147,164,147,160,147,156,147
	dc.w	152,147,148,147
	dc.w	144,147
	dc.w	140,147,136,147
	dc.w	132,147,128,147,124,147,120,147,116,147
	dc.w	112,146,108,145,104,144,100,143,096,142
	dc.w	092,140,088,139,084,138,080,136,076,134
	dc.w	072,132,068,129,064,127,060,124,056,121
	dc.w	052,117,048,112,044,107,040,102,036,092
	dc.w	035,086
	dc.w	034,079
	dc.w	035,074
	dc.w	036,066,040,056,044,051,048,046,052,041
	dc.w	056,037,060,034,064,031,068,029,072,026
	dc.w	076,024,080,022,084,020,088,019,092,018
	dc.w	096,016,100,015,104,014,108,012,112,012
	dc.w	116,011,120,011,124,011,128,011,132,011
	dc.w	136,011,140,011
	dc.w	144,011
	dc.w	148,011,152,011
	dc.w	156,011,160,011,164,011,168,011,172,011
	dc.w	176,012,180,013,184,014,188,015,192,016
	dc.w	196,018,200,019,204,020,208,022,212,024
	dc.w	216,026,220,029,224,031,228,034,232,037
	dc.w	236,041,240,046,244,051,248,056,252,066
	dc.w	253,074
	
	dc.w	450
	
coords2	dc.w	060,030
	dc.w	062,031,064,032,066,033,068,034,070,035
	dc.w	072,036,074,037,076,038,078,039,080,040
	dc.w	082,041,084,042,086,043,088,044,090,045
	dc.w	092,046,094,047,096,048,098,049,100,050
	dc.w	102,051,104,052,106,053,108,054,110,055
	dc.w	112,056,114,057,116,058,118,059,120,060
	dc.w	122,061,124,062,126,063,128,064,130,065
	dc.w	132,066,134,067,136,068,138,069,140,070
	dc.w	142,071,144,072,146,073,148,074,150,075
	dc.w	152,076,154,077,156,078,158,079,160,080
	dc.w	162,081,164,082,166,083,168,084,170,085
	dc.w	172,086,174,087,176,088,178,089,180,090
	dc.w	182,091,184,092,186,093,188,094,190,095
	dc.w	192,096,194,097,196,098,198,099,200,100
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
	dc.w	125,103,123,102,121,101,119,100,117,099
	dc.w	115,098,113,097,111,096,109,095,107,094
	dc.w	105,093,103,092,101,091,099,090,097,089
	dc.w	095,088,093,087,091,086,089,085,087,084
	dc.w	085,083,083,082,081,081,079,080,077,079
	dc.w	075,078,073,077,071,076,069,075,067,074
	dc.w	065,073,063,072,061,071,059,070,057,069
	dc.w	055,068,053,067,051,066,049,065,047,064
	dc.w	045,063,043,062,041,061,039,060,037,059
	dc.w	035,058,033,057
	dc.w	032,056,031,055,030,054,029,053
	dc.w	028,051,027,049,027,047,027,045,027,043
	dc.w	027,041,028,039,029,037,030,036,031,034
	dc.w	033,033,035,032,037,031,039,030,041,029
	dc.w	043,028,045,028,047,028,049,028,051,028
	dc.w	053,028,055,028,057,029,059,029

	dc.w	450
	
coords3	dc.w	050,93,050,93,050,93,050,93,050,93
	dc.w	051,93,052,93,053,93,054,93,055,93
	dc.w	057,93,059,93,061,93,063,93,065,93
	dc.w	068,93,071,93,074,93,077,93,080,93
	dc.w	083,93,086,93,089,93,093,93,095,93
	dc.w	098,93,101,93,104,93,107,93,110,93
	dc.w	113,93,116,93,119,93,122,93,125,93
	dc.w	128,93,131,93,134,93,137,93,140,93
	dc.w	143,93,146,93,149,93,152,93,155,93
	dc.w	158,93,161,93,164,93,167,93,170,93
	dc.w	173,93,176,93,179,93,182,93,185,93
	dc.w	188,93,191,93,194,93,197,93,200,93
	dc.w	203,93,206,93,209,93,212,93,215,93
	dc.w	218,93,221,93,224,93,227,93,230,93
	dc.w	233,93,236,93,239,93,242,93,245,93
	dc.w	248,93
	dc.w	250,93,252,93,254,93,256,93,258,93
	dc.w	259,93,260,93,261,93,262,93,263,93
	dc.w	263,93,263,93,263,93,263,93,263,93

	dc.w	450

	end

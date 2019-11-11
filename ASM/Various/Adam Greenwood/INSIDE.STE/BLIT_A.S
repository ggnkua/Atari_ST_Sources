* STE Blitter Chip example program A
* Single Blitter Chip Sprite
* Copyright c.1991 Adam Greenwood
* Feel free to change and use this code
* Written for/with Devpac 2
* This program can be run from medium res

* If this program is assembled to memory ensure that the filenames
* in the DATA section include the full path name, if the files 
* are not in the root directory

* screen address constants

vbasehi	equ	$ff8201		screen base address high
vbasemd	equ	$ff8203		screen base address middle
vbaselo	equ	$ff820d		screen base address low		

shiftmd	equ	$ff8260		shift mode
rgb	equ	$ff8240		rgb colour registers

* blitter chip constants

blitter	equ	$ff8a00		blitter chip base address

* offsets for all blitter chip registers

halfton	equ	0		16 half tone RAM registers

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
	beq	fin		if not straight out

	jsr	save_regs		save all registers
	jsr	get_mem		allocate memory

	jsr	do_mess		print screen message
	jsr	load_all		load pictures

	move.l	#new_pal,a6		
	jsr	rest_pal		set new palette

	jsr	sprite		main routine
	
	jsr	rel_mem		release memory
	jsr	rest_regs		restore registers
	bra	fin

* routine to handle one blitter chip sprite travelling around
* the screen on a pre-defined path

sprite	jsr	waitv		synchronise
	move.b	#0,shiftmd	set low resolution
	move.l	scrn_mem,d0	screen memory address
	jsr	set_scrn		set screen address

	move.l	#coords,a2	start of coordinates list
	move.l	#32,d2		no. of lines

	jsr	init_back		set up background save

.loop	move.w	(a2)+,d0		d0 = x coord
	cmp.w	#400,d0		wrap around if x > 400
	ble 	.less
	move.l	#coords,a2	start of coordinates list
	move.w	(a2)+,d0		d0 = x coord
.less	move.w	(a2)+,d1		d0 = y coord

	jsr	convert		d2 = skew, a6 = offset

	move.l	scrn_mem,a0	screen address
	add.l	a6,a0		add offset
	move.l	save_mem,a1	background save memory
	jsr	back_blit		save background

	move.l	a0,a1		screen address
	move.l	sprt_mem,a0	address of sprite
	jsr	init_sprt		set up sprite blit
	jsr 	sprt_blit		blit sprite

	jsr	waitv		synchronise

	jsr	init_back		set up background restore
	move.l	save_mem,a0	background save memory
	jsr	back_blit		restore background

	jsr	get_key		check for key press
	swap	d0		use high word
	cmp.b	#57,d0		space = quit
	bne	.loop

	rts

* routine to convert x and y coordinates into screen base offset 
* and skew value
* in : d0.w = x
*      d1.w = y
* out: d2.w = shift value
*      a6.l = address offset

convert	movem.l	d0-d1,-(a7)

	mulu	#160,d1		line length x no. of lines
	move.l	d1,a6		

	ext.l	d0		
	divu	#16,d0		distance along line
	swap	d0
	move.w	d0,d2		d2.w = shift no.
	swap	d0
	mulu	#8,d0		d0 = bytes to add
	add.w	d0,a6		screen address offset

	movem.l	(a7)+,d0-d1
	rts

* routine to initialise blitter for background save/restore

init_back	move.l	a0,-(a7)

	lea	blitter,a0		blitter address

	move.w	#12,xcount(a0)		12 words per line dest
	move.w	#2,srcxinc(a0)		2 bytes offset next word
	move.w	#138,srcyinc(a0)          	skip 160-(24-2) words
	move.w	#2,dstxinc(a0)		2 bytes offset next word
	move.w	#138,dstyinc(a0)        	skip 138 bytes each line
	move.b	#2,hop(a0)		set half tone

	move.w	#$ffff,endmsk1(a0)		no mask since data
	move.w	#$ffff,endmsk2(a0)		is not shifted
	move.w	#$ffff,endmsk3(a0)

	move.l	(a7)+,a0
 	rts

* routine to initialise blitter chip for 32x32 sprite

init_sprt	move.l	a0,-(a7)

	lea	blitter,a0		blitter address
	move.w	#3,xcount(a0)		3 words per line dest (2 + 1)
	move.w	#8,srcxinc(a0)		8 bytes between words
	move.w	#144,srcyinc(a0)		skip 160-(24-8)=144 bytes
	move.w	#8,dstxinc(a0)		8 bytes between words
	move.w	#144,dstyinc(a0)		skip 144 bytes each line
	move.b	#2,hop(a0)		use source direct

	move.l	(a7)+,a0
 	rts

* Blitter routine to save\restore background
* a0 = source address
* a1 = destination address
* d0 = x coord
* d1 = y coord

back_blit	movem.l	a0-a3/d0-d3,-(a7)

	lea	blitter,a2	blitter base address
	move.b	#0,skew(a2)	no skew
	move.b	#3,op(a2)		replace mode

	move.l	a0,srcaddr(a2)	source address
	move.l	a1,dstaddr(a2)	dest address
	move.w	#32,ycount(a2)

	move.b	#%11000000,linenum(a2)	start blit (HOG mode)

	movem.l	(a7)+,a0-a3/d0-d3
	rts

* Routine to blit block onto background
* a0.l = address of block
* a1.l = address in background
* d2 = shift value

sprt_blit	movem.l a0-a3/d0-d3,-(a7)
	
	lea	blitter,a2	blitter address
	
	move.w	#$ffff,d0
	lsr.w	d2,d0		shift right
	move.w	d0,endmsk1(a2)	Left end mask
	move.w	#$ffff,endmsk2(a2)	mid mask
	not.w	d0
	move.w	d0,endmsk3(a2)      Right end mask
	move.b	d2,skew(a2)	skew value

	move.b	#1,op(a2)		AND mode for mask
	move.l	#3,d0		mask all 4 planes destination

.mask	move.l	a0,srcaddr(a2)	source address
	move.l	a1,dstaddr(a2)	dest address
	move.w	#32,ycount(a2)	32 lines
	move.b	#192,linenum(a2)	start blit (HOG mode)
	addq 	#2,a1		nest destination plane
	dbra	d0,.mask		loop

	move.b	#7,op(a2)		OR mode for sprite data
	move.l	#2,d0		over last 3 planes
	addq	#2,a0		skip mask plane
	subq	#6,a1		second dest plane
	
.blit	move.l	a0,srcaddr(a2)	source address
	move.l	a1,dstaddr(a2)	dest address
	move.w	#32,ycount(a2)	32 lines
	move.b	#192,linenum(a2)	start blit (HOG mode)
	addq	#2,a0		next source plane
	addq	#2,a1		next dest plane
	dbra	d0,.blit		loop

	movem.l	(a7)+,a0-a3/d0-d3
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

* routine to set screen base address
* in: d0.l = screen address

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

rest_regs	move.l	#old_pal,a6
	jsr	rest_pal		restore old palette

	jsr	waitv
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

get_mem	move.l	#69122,-(a7)   	room for 2 screens + save area 
	move.w	#72,-(a7)		allocate memory
	trap	#1
	addq	#6,a7
        	
	addq	#1,d0		
	bclr	#0,d0        	put address on word boundary
	move.l	d0,scrn_mem	save new screen address
	add.l	#32000,d0
	move.l	d0,sprt_mem	address of sprite memory
	add.l	#32000,d0
	move.l	d0,save_mem	address of save memory
	
	rts

* release memory previously allocated

rel_mem	move.l	scrn_mem,-(a7)
	move.w	#73,-(a7)		release memory
	trap	#1	
	addq	#6,a7
	
	rts

load_all	move.l	#scrn_file,a6
	move.l	scrn_mem,a5	load screen pic
	jsr	load_pic

	move.l	#sprt_file,a6
	move.l	sprt_mem,a5	load sprite pic
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

scrn_mem	ds.l	1
sprt_mem	ds.l	1
save_mem	ds.l	1

save_stk	ds.l	1

	section data

sprt_file	dc.b	'SPRITES.PI1',0
scrn_file	dc.b	'BLIT.PI1',0

message	dc.b	'Blitter Chip Single Sprite Demo',10,13,10,13
	dc.b	'Copyright ',189,'1991 Adam Greenwood',10,13,10,13
	dc.b	'Loading Pic and Sprites...',0

	even

* list of coordinates

coords	dc.w	254,079
	dc.w	253,085
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
	dc.w	035,085
	dc.w	034,079
	dc.w	035,073
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
	dc.w	253,073
	
	dc.w	450

	end

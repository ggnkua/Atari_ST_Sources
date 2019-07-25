***************************************************************************
* ST Format Demo V1.0 - Source code (C) 1993 James Boulton		    *
*		  - Set your tabs to 10!!!			    *
*		  - Assemble with GENST V2
***************************************************************************

	bsr	checkres		check it's low / medium resolution
	bsr	setup		setup all routines

mainlp	cmp.b	#57,$fffffc02	is space pressed?
	bne	mainlp		no, keep looping!

	bra	exit		time to quit...

***************************************************************************
* CHECK RESOLUTION						    *
* See if it can run in this resolution, if high res then it quits!	    *
***************************************************************************

checkres	move.w	#4,-(sp)		xbios 4, get screen resolution
	trap	#14		xbios call
	addq.l	#2,sp		tidy stack

	cmp.b	#2,d0		is it high resolution??
	bne	okres		low / medium resolution, carry on!

	clr.l	-(sp)		highres, quit!! bios 0, pterm
	trap	#1		bios call

okres	move.w	d0,oldres		save previous resolution

	rts			

***************************************************************************
* SETUP							    *
* Setup all routines, scroller, distorter, vblank, super mode, etc...     *
***************************************************************************

setup	clr.l	-(sp)		keep same stack address
	move.w	#32,-(sp)		supervisor mode toggle
	trap	#1		bios call
	addq.l	#6,sp		tidy stack
	move.l	d0,oldsp		save the address of the old stack

	move.l	#pattern,distort	set position within distort data
	move.l	#text,point

	bsr	shiftlogo		preshift the STF logo 16 times
	bsr	setscreen		setup screen swapping, resolution
	bsr	initmusic		setup music routine
	bsr	copylogo		draw my logo at the bottom!
	bsr	vbion		turn on all interupts
	bsr	setpal		set demo palette

	rts

***************************************************************************
* EXIT							    *
* Reset all changed and quit!					    *
***************************************************************************

exit	bsr	vbioff		turn off all interupts
	bsr	stopmusic		stop any sounds lingering
	bsr	oldpal		reset old palette

	move.w	oldres,-(sp)	set old resolution
	move.l	oldscr,-(sp)	old screen address
	move.l	oldscr,-(sp)
	move.w	#5,-(sp)		setscreen
	trap	#14		xbios call
	add.l	#12,sp		tidy stack

	move.l	oldsp,-(sp)	reset old stack address
	move.w	#32,-(sp)		supervisor mode toggle
	trap	#1		bios call
	addq.l	#6,sp		tidy stack

	clr.l	-(sp)		pterm call (quit)
	trap	#1		bios call

***************************************************************************
* SAVE AND SET PALETTE					    *
***************************************************************************

setpal	movem.l	$ffff8240,d0-d7	get entire palette
	movem.l	d0-d7,savepal	save palette
	
	movem.l	palette,d0-d7	get entire new palette
	movem.l	d0-d7,$ffff8240	set new palette

	rts

***************************************************************************
* RESET OLD PALETTE						    *
***************************************************************************

oldpal	movem.l	savepal,d0-d7	get old palette
	movem.l	d0-d7,$ffff8240	set old palette

	rts

***************************************************************************
* COPY MY LOGO						    *
***************************************************************************

copylogo	move.l	#jimlogo,a0	address of my logo 288 x 26 x 2
	move.l	physcreen,a1	address of physical screen
	move.l	logscreen,a2	address of logical screen
	add.l	#160*230+8,a1
	add.l	#160*230+8,a2

	move.w	#26-1,d0		number of lines
copyllp	move.w	#18-1,d1		number of chunks
copyxlp	move.l	(a0),(a1)		copy planes 1+2 (physical)
	move.l	(a0)+,(a2)	copy planes 1+2 (logical)
	add.l	#8,a1
	add.l	#8,a2
	dbra	d1,copyxlp
	add.l	#16,a1
	add.l	#16,a2
	dbra	d0,copyllp
	rts

***************************************************************************
* SETUP MUSIC PLAYING ROUTINE					    *
* Inits music. Chip music written by Jochen Hippel (alias Mad Max)	    *
* Entitled : 'Bach To The Future'				    *
***************************************************************************

initmusic	moveq	#1,d0		music number 1
	jsr	music		setup music
	rts

***************************************************************************
* STOP MUSIC PLAYING					    *
* Stops music. Chip music written by Jochen Hippel (alias Mad Max)	    *
* Entitled : 'Bach To The Future'				    *
***************************************************************************

stopmusic	moveq	#0,d0		music number 0, (none)
	jsr	music		setup music

	move.b	#8,$ffff8800	ask for chanel a amplitude
	clr.b	$ffff8802		set to no volume
	move.b	#9,$ffff8800	ask for chanel b amplitude
	clr.b	$ffff8802		set to no volume
	move.b	#10,$ffff8800	ask for chanel c amplitude
	clr.b	$ffff8802		set to no volume

	rts

***************************************************************************
* SETUP SCREEN PARAMETERS					    *
* Set low resolution and physical screen address.			    *
***************************************************************************

setscreen	move.w	#3,-(sp)		screen address
	trap	#14		xbios call
	addq.l	#2,sp		tidy stack
	move.l	d0,oldscr		save old screen

	move.l	#log,d0		logical screen address
	add.l	#256,d0		add 256 because of anding it
	and.l	#$ffffff00,d0	put it on a 256 byte boundary
	move.l	d0,logscreen	set logical screen address
	move.l	d0,screen		screen to draw on!

	move.l	#phy,d0		physical screen address
	add.l	#256,d0		add 256 because of anding it
	and.l	#$ffffff00,d0	put it on a 256 byte boundary
	move.l	d0,physcreen	set physical screen address

	move.w	#0,-(sp)		low resolution
	move.l	physcreen,-(sp)	physical screen address
	move.l	physcreen,-(sp)	logical screen address
	move.w	#5,-(sp)		xbios 5, setscreen
	trap	#14		xbios call
	add.l	#12,sp		tidy stack

	rts

***************************************************************************
* LOGO PRE-SHIFT ROUTINE					    *
* This routine will pre-shift the STF logo 16 times to make it very fast  *
* to do a distorter because you can plot it by the pixel.		    *
***************************************************************************

shiftlogo	move.l	#logo,a0		address of the 2 bit-plane logo
	move.l	#ldata,a1		where to put the preshifted data
	
	move.w	#2595-1,d2	173 lines high * 15 preshifts
llines	move.w	#14-1,d1		number of x-chunks to shift

lchunks	clr.l	d0		empty d0   ** PLANE ONE **
	move.w	(a0)+,d0		get plane one of logo
	swap	d0		get plane in upper word
	lsr.l	d0		shift it right one pixel
	move.w	d0,4(a1)		write second half of the plane
	swap	d0		get plane into lower word
	or.w	d0,(a1)+		write first half of plane
	
	clr.l	d0		empty d0   ** PLANE TWO **
	move.w	(a0)+,d0		get plane one of logo
	swap	d0		get plane in upper word
	lsr.l	d0		shift it right one pixel
	move.w	d0,4(a1)		write second half of the plane
	swap	d0		get plane into lower word
	or.w	d0,(a1)+		write first half of plane
	
	dbra	d1,lchunks	shift the rest of the chunks
	dbra	d2,llines		shift the rest of the lines

	rts

***************************************************************************	
* SWAP LOGICAL AND PHYSICAL SCREENS				    *
* Stops flicker of the graphics.				    *
***************************************************************************	

swap	move.l	physcreen,d0
	move.l	logscreen,physcreen
	move.l	d0,logscreen
	move.l	d0,screen
	
	move.w	#-1,-(sp)		same resolution
	move.l	physcreen,-(sp)	set physical screen address
	move.l	physcreen,-(sp)	set physical screen address
	move.w	#5,-(sp)		setscreen
	trap	#14		xbios call
	lea	12(sp),sp		tidy stack

	rts

***************************************************************************
* DRAW THE THREE VOLUME BARS					    *
***************************************************************************

vumeter	move.l	#vubars,a0	volume bars data for 1
	move.l	#vubars,a1	volume bars data for 2
	move.l	#vubars,a2	volume bars data for 3
	move.l	screen,a3		logical screen address
	add.l	#15*160,a3	start at line 15!

	moveq	#0,d0		empty d0 for amplitude
	move.b	#8,$ffff8800	ask for chanel a amplitude
	move.b	$ffff8800,d0	get amplitude
	cmp.b	#16,d0
	blt	oka1
	move.w	#16,d0
oka1	mulu	#1200,d0		get offset to correct bar graphics
	add.l	d0,a0		address of bar 1

	moveq	#0,d0		empty d0 for amplitude
	move.b	#9,$ffff8800	ask for chanel b amplitude
	move.b	$ffff8800,d0	get amplitude
	cmp.b	#16,d0
	blt	oka2
	move.w	#16,d0
oka2	mulu	#1200,d0		get offset to correct bar graphics
	add.l	d0,a1		address of bar 2

	moveq	#0,d0		empty d0 for amplitude
	move.b	#10,$ffff8800	ask for chanel b amplitude
	move.b	$ffff8800,d0	get amplitude
	cmp.b	#16,d0
	blt	oka3
	move.w	#16,d0
oka3	mulu	#1200,d0		get offset to correct bar graphics
	add.l	d0,a2		address of bar 2

d	set	0
s	set	0
	rept	150

	move.l	s(a0),d(a3)	copy planes 1+2 bar 1
	move.l	s(a0),d+152(a3)	copy planes 1+2 bar 1
	move.l	s+4(a0),d+4(a3)	copy planes 3+4 bar 1
	move.l	s+4(a0),d+156(a3)	copy planes 3+4 bar 1

	move.l	s(a1),d+8(a3)	copy planes 1+2 bar 2
	move.l	s(a1),d+144(a3)	copy planes 1+2 bar 2
	move.l	s+4(a1),d+12(a3)	copy planes 3+4 bar 2
	move.l	s+4(a1),d+148(a3)	copy planes 3+4 bar 2

	move.l	s(a2),d+16(a3)	copy planes 1+2 bar 3
	move.l	s(a2),d+136(a3)	copy planes 1+2 bar 3
	move.l	s+4(a2),d+20(a3)	copy planes 3+4 bar 3
	move.l	s+4(a2),d+140(a3)	copy planes 3+4 bar 3

d	set	d+160		next screen line
s	set	s+8		next bar line

	endr

	rts

***************************************************************************	
* UPDATE DISTORTER TABLE					    *
* Scrolls distorter back by a byte and puts the new byte in.	    *
***************************************************************************	

wibble	move.l	#table,a0

x	set	0
	rept	173
	move.b	x+1(a0),x(a0)
x	set	x+1
	endr
	add.l	#173,a0

again	move.l	distort,a1
	add.l	#1,distort	next shift
	moveq	#0,d0		empty d0 (for shift)
	move.b	(a1),d0		get shift
	cmp.b	#255,d0		end of pattern??
	bne	ok_shft		no, draw
	move.l	#pattern,distort	reset pointer
	bra	again		get shift
	
ok_shft	move.b	d0,(a0)		set bottom line

	bsr	draw_logo		draw the distorting logo
	rts
	
***************************************************************************	

draw_logo	move.l	#table,a0
	move.l	screen,a2		physical screen address
	add.l	#(3*8)+160*4,a2	centre of screen, 4 lines down

s	set	0
d	set	0
	move.l	#logo,a3		address of 16 shifted logos

	rept	173
	moveq	#0,d1
	move.l	a3,a1		address of 16 shifted logos
	move.b	(a0)+,d1		get offset for line (0-15)
	mulu	#9688,d1		offset address of shifted logo
	add.l	d1,a1		address of shifted logo

	move.l	s(a1),d(a2)
	move.l	s+4(a1),d+8(a2)
	move.l	s+8(a1),d+16(a2)
	move.l	s+12(a1),d+24(a2)
	move.l	s+16(a1),d+32(a2)
	move.l	s+20(a1),d+40(a2)
	move.l	s+24(a1),d+48(a2)
	move.l	s+28(a1),d+56(a2)
	move.l	s+32(a1),d+64(a2)
	move.l	s+36(a1),d+72(a2)
	move.l	s+40(a1),d+80(a2)
	move.l	s+44(a1),d+88(a2)
	move.l	s+48(a1),d+96(a2)
	move.l	s+52(a1),d+104(a2)

s	set	s+56		next logo line
d	set	d+160		next screen line
	endr

	rts

***************************************************************************
* INSTALL INTERUPTS						    *
* Install all mfp, vbl and hbl interupts			    *
***************************************************************************

vbion	lea	mfpstore,a0	where to store the mfp registers
	move.b	$fffffa07,(a0)+	interupt enable a (top)
	move.b	$fffffa09,(a0)+	interupt enable b (bottom)
	move.b	$fffffa13,(a0)+	interupt mask a
	move.b	$fffffa15,(a0)+	interupt mask b
	move.b	$fffffa19,(a0)+	timer a control
	move.b	$fffffa1b,(a0)+	timer b control
	move.b	$fffffa1f,(a0)+	timer a data
	move.b	$fffffa21,(a0)+	timer b data (scan line)
	move.l	$68,(a0)+		horizontal blank
	move.l	$70,(a0)+		vertical blank
	move.l	$120,(a0)+	timer b interupt
	move.l	$134,(a0)+	timer a interupt
	clr.b	$fffffa1b		empty timer b data
	clr.b	$fffffa19		empty timer a data
	move.b	#$21,$fffffa07	disable interupt a
	clr.b	$fffffa09		disable interupt b
	move.b	#$21,$fffffa13	set mask a
	clr.b	$fffffa15		set mask b
	bclr	#3,$fffffa17	reset vector base
	move.l	#topbord,$134	put top border rout in timer a
	move.l	#bottom,$120	put bottom border rout in timer b
	move.l	#vblank,$70	new vertical blank rout
	move.w	#$2300,sr		turn on all interupts
	rts

***************************************************************************
* RESET INTERUPTS						    *
* Reset all mfp, vbl and hbl interupts				    *
***************************************************************************

vbioff	move.w	#$2700,sr		stop all interupts
	lea	mfpstore,a0	address of saved registers
	move.b	(a0)+,$fffffa07	interupt enable a (top)
	move.b	(a0)+,$fffffa09	interupt enable b (bottom)
	move.b	(a0)+,$fffffa13	interupt mask a
	move.b	(a0)+,$fffffa15	interupt mask b
	move.b	(a0)+,$fffffa19	timer a control
	move.b	(a0)+,$fffffa1b	timer b control
	move.b	(a0)+,$fffffa1f	timer a data
	move.b	(a0)+,$fffffa21	timer b data (scan line)
	move.l	(a0)+,$68		hbl interupt
	move.l	(a0)+,$70		vbl
	move.l	(a0)+,$120	timer b interupt
	move.l	(a0)+,$134	timer a interupt
	bset	#3,$fffffa17	reset mfp vector base
	move.w	#$2300,sr		all interupts on
	rts

***************************************************************************
* TOP BORDER REMOVING ROUTINE					    *
* Removes the top border, uses timer A. Routine courtesy of Mike Johnson. *
***************************************************************************

topbord	move.w	#$2100,sr		set status register
	stop	#$2100		wait for interupt
	clr.b	$fffffa19		disable timer a
	rept	78		repeat
	nop			nop (pause for 4*78 cycles)
	endr			78 times
	clr.b	$ffff820a		set 60hz
	nop			nop
	nop			nop (pause for 4*2 cycles)
	move.b	#2,$ffff820a	set 50hz (no top border)
	rte			return from interupt

***************************************************************************
* This just points to an rte so interupts can be removed		    *
***************************************************************************

phbl	rte			retern directly

***************************************************************************
* BOTTOM BORDER REMOVING ROUTINE				    *
* Removes the bottom border, timer B. Routine courtesy of Mike Johnson.   *
***************************************************************************

bottom	move.w	d0,-(sp)		save d0 as it's used later on...
	rept	32		repeat
	nop			nop (pause 4 cycles)
	endr			32 times!
	clr.w	d0		empty d0
	move.b	$ffff8209,d0	get low screen address
	neg.b	d0		negate it
	add.b	#192,d0		add 192
	lsl.b	d0,d0		used as a pause to the next line
	move.w	#18,d0		pause to get the correct place
pause	dbra	d0,pause		wait...
	move.b	#0,$ffff820a	set 60hz
	rept	12		repeat
	nop			nop (pause 4 cycles)
	endr			12 times
	move.b	#2,$ffff820a	set 50hz, remove bottom border!
	move.w	(sp)+,d0		restore d0
	rte			retern from interupt

***************************************************************************
* VBLANK ROUTINE						    *
* Called every vbl, 50 times per second.			    *
***************************************************************************

vblank	clr.b	$fffffa19		stop timer a
	move.b	#100,$fffffa1f	set timer a data
	move.b	#4,$fffffa19	start timer a

	clr.b	$fffffa1b		stop timer b
	move.b	#228,$fffffa21	line 228, bottom border
	move.l	#bottom,$120	bottom border rout address
	move.b	#8,$fffffa1b	start timer b (rasters)

	jsr	music+8		play 'Bach to the future' music
	bsr	vumeter		draw volume bars on each side
	bsr	scroll		do the scroller
	bsr	wibble		do the distorter
	bsr	swap		swap screens
	rte			retern from interupt

***************************************************************************

scroll	move.b	shift,d0		get the char shift, 0-3
	cmp.b	#4,d0		is it less that 4?
	blt	okpos		yep, all ok

	clr.b	shift		reset shift to 0
	add.l	#1,point		next character
	move.l	point,a0		where the text is
	moveq	#0,d0		clear d0
	move.b	(a0),d0		get character
	cmp.w	#255,d0		end of text?
	bne	okpos		no, ok
	move.l	#text,point	reset scroll text position

okpos	move.b	shift,d0		get char shift
	and.b	#1,d0		make it 0 or 1 (which buffer!)
	tst.b	d0		is it 0?
	beq	rout1		alter buffer1
	bra	rout2		alter buffer2
	
rout1	moveq	#0,d0		empty d0
	move.l	point,a0		where the text is
	move.b	(a0),d0		get one character
	mulu	#96,d0		get offset in fontset
	move.l	#font,a0		address of the fontset
	add.l	d0,a0		a0 = address of the character

	moveq	#0,d0		empty d0
	move.b	shift,d0		position within char (0-3)

	add.l	d0,a0		a0 = address of chunk to draw

	move.l	#buffer1,a1	address of buffer1
	add.w	position,a1	a1 = address to put character

so	set	0		set var so (Source Offset) to 0
do	set	0		set var do (Data Offset) to 0
	rept	24		repeat code 24 (lines high) times
	move.w	so(a0),do(a1)	copy one chunk to buffer
	move.w	so(a0),do+42(a1)	copy one chunk to buffer
so	set	so+4		add 4 to source
do	set	do+84		add 84 to dest
	endr			end of repeat

	move.l	#buffer1,a0	address of buffer
	add.w	position,a0	where to draw from
	add.l	#2,a0		a0 = source address
	move.l	screen,a1		a1 = dest address
	add.l	#(160*190),a1	where to put the scroller

	bsr	draw		draw the buffer

	add.b	#1,shift		next shift
	
	add.w	#2,position	next shift position
	cmp.w	#40,position	end of buffer yet?
	ble	end		no, carry on
	clr.w	position		yes, reset buffer

end	rts


rout2	moveq	#0,d0		empty d0
	move.l	point,a0		where the text is
	move.b	(a0),d0		get one character
	mulu	#96,d0		get offset in fontset
	move.l	#font,a0		address of the fontset
	add.l	d0,a0		a0 = address of the character

	moveq	#0,d0		empty d0
	move.b	shift,d0		position within char (0-3)
	and.b	#2,d0		make it 0 or 2
	add.l	d0,a0		a0 = address of chunk to draw

	move.l	#buffer2,a1	address of buffer2
	add.w	position,a1	a1 = address to put character
	sub.l	#1,a1		plot it 8 pixels to the left!

so	set	0		set var so (Source Offset) to 0
do	set	0		set var do (Data Offset) to 0
	rept	24		repeat code 24 (lines high) times
	move.b	so(a0),do(a1)	copy one chunk to buffer
	move.b	so+1(a0),do+1(a1)	copy one chunk to buffer
	move.b	so(a0),do+42(a1)	copy one chunk to buffer
	move.b	so+1(a0),do+43(a1)	copy one chunk to buffer
so	set	so+4		add 4 to source
do	set	do+84		add 84 to dest
	endr			end of repeat

	move.l	#buffer2,a0	address of buffer
	add.w	position,a0	what position to draw
	add.l	#2,a0		a0 = where to draw from
	move.l	screen,a1		a1 = where to draw to
	add.l	#(160*190),a1	where to put the scroller

	bsr	draw		draw the buffer on the screen
	
	add.b	#1,shift		next shift
                 	
	rts

***************************************************************************

draw	
s	set	0
d	set	0
	rept	24
	move.w	s(a0),d(a1)
	move.w	s+2(a0),d+8(a1)
	move.w	s+4(a0),d+16(a1)
	move.w	s+6(a0),d+24(a1)
	move.w	s+8(a0),d+32(a1)
	move.w	s+10(a0),d+40(a1)
	move.w	s+12(a0),d+48(a1)
	move.w	s+14(a0),d+56(a1)
	move.w	s+16(a0),d+64(a1)
	move.w	s+18(a0),d+72(a1)
	move.w	s+20(a0),d+80(a1)
	move.w	s+22(a0),d+88(a1)
	move.w	s+24(a0),d+96(a1)
	move.w	s+26(a0),d+104(a1)
	move.w	s+28(a0),d+112(a1)
	move.w	s+30(a0),d+120(a1)
	move.w	s+32(a0),d+128(a1)
	move.w	s+34(a0),d+136(a1)
	move.w	s+36(a0),d+144(a1)
	move.w	s+38(a0),d+152(a1)

s	set	s+84
d	set	d+160
	endr
	rts
	
***************************************************************************

jimlogo	incbin	'jimslogo.dat'	my logo, 288 x 26 x 2
font	incbin	'font.dat'	32 x 24 x 1 scroller font
palette	incbin	'palette.dat'	palette for the logo and bars
vubars	incbin	'vu.dat'		4 bit plane volume meter data
music	incbin	'awe.mus'		nice chip music
table	dcb.b	174,8		distorter table, 1 byte per line
pattern	incbin	'distort.dat'	data for the distort pattern
	dc.b	255		indicate end of data
	even			put on even address
text	incbin	'text.dat'	the scrolltext in sprite format
	dc.b	255 
	even
logo	incbin	'stf_logo.dat'	224*173 STF logo, 2 bit-planes

	section	bss		from here on no data is stored

ldata	ds.b	9688*15		space for the 15 preshifted logos
log	ds.b	43856		space for logical display
phy	ds.b	43856		space for physical display
buffer1	ds.b	2016		672 x 24 buffer
buffer2	ds.b	2016		672 x 24 buffer, offset 8 bits
savepal	ds.b	32		space for old palette
mfpstore	ds.b	24		space for saving vectors
position	ds.w	1		where to put the char
point	ds.l	1		what text address you're at
shift	ds.w	1		distance through char
oldsp	ds.l	1		old stack pointer address
screen	ds.l	1		ALLWAYS logical screen
logscreen	ds.l	1		logical screen address
physcreen	ds.l	1		physical screen address
oldres	ds.b	2		old resolution, medium or low
oldscr	ds.l	4		space for old screen address
distort	ds.l	1		current address in distorter table
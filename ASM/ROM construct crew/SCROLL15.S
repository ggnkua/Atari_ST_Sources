YES=1
yes=YES
NO=0
no=NO


DOWNLOAD=yes

	ifne	DOWNLOAD
****************************************************************
* ST downloader test program.
	include	"transmit.s"
	org	$20000
Code_Start
Exec_Addr
	endc



DEBUG	equ	1	0=DEBUG ON, kill interrupts,etc. 1 =off




*
* ROM CONSTRUCT CREW 3D VEKTORS
* With mega scroller, version 1. Will use character set FONTISH
* which is a small, cuddly font. Then makes each character 16 times
* bigger in X ,4 in Y. Then displays as a scrolline. Graphic
* equalisers based on The Respectables demo in the ULM demo.
* Logos by me (Dixie), sorry they're rubbish. 3D
* vektors started by ZAPH on a PC in 'C', then hacked to 68000
* by both of us.
* Initial version complete :	10/06/1991
* Final   version complete :	06/07/1991
*
* THANX FOR BEING PATIENT LINDA!
*
* First, some very useful equates.
*
IERA	equ	$fffffa07		interrupt enable register A
IERB	equ	$fffffa09		interrupt enable register B
IPRA	equ	$fffffa0b		interrupt pending register A
IPRB	equ	$fffffa0d		interrupt pending register B
ISRA	equ	$fffffa0f		interrupt in-service register A
ISRB	equ	$fffffa11		interrupt in-service register B
IMRA	equ	$fffffa13		interrupt mask register A
IMRB	equ	$fffffa15		interrupt mask register B
TACR	equ	$fffffa19		timer A control register
TBCR	equ	$fffffa1b		timer B control register
TCDCR	equ	$fffffa1d		timer C/D control register
TADR	equ	$fffffa1f		timer A data register
TBDR	equ	$fffffa21		timer B data register
TCDR	equ	$fffffa23		timer C data register
TDDR	equ	$fffffa25		timer D data register

PAL_00	equ	$ffff8240		palette	0
PAL_01	equ	$ffff8242		palette	1
PAL_02	equ	$ffff8244		palette	2
PAL_03	equ	$ffff8246		palette	3
PAL_04	equ	$ffff8248		palette	4
PAL_05	equ	$ffff824a		palette	5
PAL_06	equ	$ffff824c		palette	6
PAL_07	equ	$ffff824e		palette	7
PAL_08	equ	$ffff8250		palette	8
PAL_09	equ	$ffff8252		palette	9
PAL_10	equ	$ffff8254		palette	10
PAL_11	equ	$ffff8256		palette	11
PAL_12	equ	$ffff8258		palette	12
PAL_13	equ	$ffff825a		palette	13
PAL_14	equ	$ffff825c		palette	14
PAL_15	equ	$ffff825e		palette	15
ACIA	equ	$fffffc02		keyboard data
VBAS	equ	$ffff8200		video base (really $f8201)
SYNC	EQU	$ffff820a		sync mode 50/60 hz
PSG	equ	$ffff8800		YM2149 register select/read/write
*
*	as always, supervisor mode
*
	ifeq	DOWNLOAD
	clr.l	-(sp)  		
	move.w	#32,-(sp) 
	trap	#1
	addq.l	#6,sp
	lea	thestack,a7
	endc
	move.w	#$2300,sr
*
*	hide the mouse
	dc.w	$a000
	dc.w	$a00a
*
*	Quickset background black
*
	IFNE	DEBUG
	move.w	#0,PAL_00
	ENDC
*
*	clear all ram for the two screens
*
	move.l	#0,D0
	BSR	tune


	move.l	#$64000,a0
	move.l	#$75000,a1
	move.l	#9216,d0
	moveq	#0,d1
clearit
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbra		d0,clearit	
*
* set low res
*
	clr.w	-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap		#14
	lea		$0c(a7),a7


*	A6 is a static pointer to all variables used. it's easier
*	to reference variables as nnnn(A6) rather than $nnnnnnnn

	lea	variables(pc),a6     
	move.l	#scrollit,scrol_buf(a6)		store start address
	move.l	#bigchars,bigset(a6)
	move.l	#scrol_txt,txt_comp(a6)

*	now pre-build all the characters we'll need in expanded form.
	moveq	#0,d6
	move.l	bigset(a6),a3
charsbld
* the outer loop (set_txt) is performed once per character in the
* normal format
set_txt
	lea	load_addr,a0		where charset is
	move.l	d6,d0
* the fontish char is 16x16 pixels. So, for each word starting at
* (a4), we have to turn each bit into a byte of 1s or 0s.
* This loop is performed 16 times (once per line of height)
next_char
	lsl.w	#5,d0		multiply by 32
	lea	0(a0,d0.w),a4	get addr of char in font
	moveq	#15,d1
	moveq	#0,d2
set_char
	move.w	(a4)+,d0		get 16 bits
	moveq	#0,d5
* And finally, this inner loop is done 8 times, once per bit pair
	moveq	#7,d4
set_line
	lsl.w	#1,d0		shift a bit to the X flag
	moveq	#0,d3
	subx.b	d2,d3		or d3=d3-d2-Xflag, ie
*						   d3=0-0-(0or1)=0or-1
	move.b	d3,0(a3,d5.w)	save it
	addq.w	#1,d5
	lsl.w	#1,d0		shift a bit to the X flag
	moveq	#0,d3
	subx.b	d2,d3		or d3=d3-d2-Xflag, ie
*						   d3=0-0-(0or1)=0or-1
	move.b	d3,0(a3,d5.w)	save it
	add.l	#31,d5
	dbra	d4,set_line
	addq.l	#2,a3
	dbra	d1,set_char
	lea	224(a3),a3
	addq	#1,d6
	cmp.b	#64,d6
	bne	set_txt
*	set all pointers in the buffer to the space character.
	move.l	txt_comp(a6),a2
	moveq.l	#$20,d0		get space char
	sub.b	#$20,d0		1st 32 not in charset
	lsl.w	#8,d0		multiply by 256
	move.l	a2,txt_comp(a6)
	move.l	bigset(a6),a1	where charset is
	lea	0(a1,d0.w),a4	get addr of char in font
	move.l	scrol_buf(a6),a0
	moveq	#19,d0
buff_space
	move.l	a4,(a0)+
	dbra	d0,buff_space
* put the dixie logo onscreen - both screens remember
	lea	dixie2,a0
	lea	$64000+4,a1
	lea	$75000+4,a2
	moveq	#$21,d0
dixlp	move.w	(a0),(a1)
	addq.l	#8,a1
	move.w	(a0)+,(a2)
	addq.l	#8,a2
	move.w	(a0),(a1)
	addq.l	#8,a1
	move.w	(a0)+,(a2)
	addq.l	#8,a2
	move.w	(a0),(a1)
	addq.l	#8,a1
	move.w	(a0)+,(a2)
	addq.l	#8,a2
	lea	136(a1),a1
	lea	136(a2),a2
	dbra	d0,dixlp	
* put the zaph logo onscreen
	lea	zaph,a0
	lea	$64000+15*8+160*5+4,a1
	lea	$75000+15*8+160*5+4,a2
	moveq	#$19,d0
zaphlp	move.w	(a0),(a1)
	addq.l	#8,a1
	move.w	(a0)+,(a2)
	addq.l	#8,a2
	move.w	(a0),(a1)
	addq.l	#8,a1
	move.w	(a0)+,(a2)
	addq.l	#8,a2
	move.w	(a0),(a1)
	addq.l	#8,a1
	move.w	(a0)+,(a2)
	addq.l	#8,a2
	move.w	(a0),(a1)
	addq.l	#8,a1
	move.w	(a0)+,(a2)
	addq.l	#8,a2
	move.w	(a0),(a1)
	addq.l	#8,a1
	move.w	(a0)+,(a2)
	addq.l	#8,a2
	lea	120(a1),a1
	lea	120(a2),a2
	dbra	d0,zaphlp	

*	draw two borders, top and bottom
	lea	$64000+(35*160),a0
	lea	$75000+(35*160),a1
	lea	$64000+(164*160),a2
	lea	$75000+(164*160),a3
	moveq	#-1,d0
	move.l	#159,d1
bordloop
	move.l	d0,(a0)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d0,(a3)+
	dbra	d1,bordloop

*
*	create a table of all 512 colours. Each colour is repeated 4
*	times in the table. Seems a waste, but it saves time in the 
*	horizontal blank routine.
*
	moveq	#7,d0
	lea	allcols,a0
alloop3	moveq	#7,d1
alloop2	moveq	#7,d2
alloop1	move.w	d0,d3
	asl.w	#4,d3
	add.w	d1,d3
	asl.w	#4,d3
	add.w	d2,d3
	move.w	d3,(a0)+
	move.w	d3,(a0)+
	move.w	d3,(a0)+
	move.w	d3,(a0)+
	dbra		d2,alloop1
	dbra		d1,alloop2
	dbra		d0,alloop3

*	Generate a table of colours for the 3d shapes. To explain :
*	each shape is on screen for 500 * 0.04 seconds. As the time
*	begins to expire, we want to fade the drawing colour from
*	white (777) to black (000), then as the next shape comes in
*	we reverse back up to 777. To do this means a lot of faffing
*	about, but the easy way is to define a value for each of the 500
*	frames.
*
	moveq	#6,d0
	moveq	#0,d1
	lea	drawcol,a0
	lea	drawcol+500,a1
eachcol	moveq	#4,d2
dfinecol	move.w	d1,(a0)+
	move.w	d1,-(a1)
	dbra	d2,dfinecol
	add.w	#$0111,d1
	dbra	d0,eachcol
allothers
	move.w	d1,(a0)+
	cmp.l	a0,a1
	bne 	allothers
*	generate the code to move the scroll.
	moveq	#19,d0
	lea	drawscroll,a0
line	move.w	#$205a,(a0)+		move.l (a2)+,a0
	moveq	#0,d1
	moveq	#14,d2
column	move.w	#$3018,(a0)+		move.w	(a0)+,d0
	moveq	#3,d3
chunk	move.w	#$3740,(a0)+		move.w	d0,nnnn(a3)
	move.w	d1,(a0)+			that's the nnnn
	add.l	#160,d1
	dbra	d3,chunk
	dbra	d2,column
	move.w	#$508b,(a0)+		addq.l	#8,a3
	dbra	d0,line
	move.w	#$4e75,(a0)		rts

*	generate the code to wipe the screen. (Single Bitplane)

	move.l	#122*20,d0		20 words * 123 lines
	moveq	#0,d1
	lea	wipe,a0
wipeit	move.w	#$3140,(a0)+		move.w	d0,nnnn(a0)
	move.w	d1,(a0)+			that's the nnnn
	addq	#8,d1
	dbra	d0,wipeit
	move.w	#$4e75,(a0)		rts

*	generate the code to display the graphic equalisers.
*	sixteen variations.

	move.l	#graphix,a0
	lea	equitab,a1
	moveq	#15,d0
	moveq	#0,d1
	move.l	a0,(a1)+
allblank
	move.w	#$3342,(a0)+		move.w	d2,nnnn(a1)
	move.w	d1,(a0)+			that's the nnnn
	addq	#8,d1
	move.w	#$3342,(a0)+		move.w	d2,nnnn,(a1)
	move.w	d1,(a0)+			that's the nnnn
	add.w	#312,d1
	dbra	d0,allblank
	move.w	#$4e75,(a0)+		rts

	moveq	#0,d1
	moveq	#14,d2
eachequi
	move.l	d1,d3
	move.l	d2,d4
	moveq	#0,d5
	move.l	a0,(a1)+
thisequi
	move.w	#$3342,(a0)+
	move.w	d5,(a0)+
	addq		#8,d5
	move.w	#$3342,(a0)+
	move.w	d5,(a0)+
	add.w	#312,d5
	dbra	d4,thisequi
thatequi
	move.w	#$3343,(a0)+
	move.w	d5,(a0)+
	addq	#8,d5
	move.w	#$3343,(a0)+
	move.w	d5,(a0)+
	add.w	#312,d5
	dbra	d3,thatequi
	move.w	#$4e75,(a0)+
	addq	#1,d1
	dbra	d2,eachequi

*	Build the multiply by 160 table.
	moveq	#0,d0
	move.l	#199,d1
	lea	multab,a0
multibld
	move.l	d0,(a0)+
	add.l	#160,d0
	dbra	d1,multibld

*	bits and bobs. bitshift as 1 will force transfer of the first
*	scrollchar straight away.
	move.b	#1,bitshift(a6)
	move.w	#0,xangle(a6)
	move.w	#0,yangle(a6)
	move.w	#0,zangle(a6)
	move.w	#$0777,PAL_04
	move.w	#$0500,PAL_15
	move.w	#1,timer(a6)
	move.l	#shapend+16,shapptr(a6)			
	move.l	#allcols,logocol
	move.w	#5,delayer(a6)

*	kill current keyboard interrupt and replace.

	IFNE	DEBUG
	move.b	#$12,ACIA
	lea	key(pc),a0
	move.l	a0,$118

*	kill timer c ?
	move.w	#5,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq.l	#4,a7

	ori.b	#1,IERA
	ori.b	#1,IMRA
	ENDC

*	start custom Vertical Blank Interrupt
	lea	vbl(pc),a0	get my vbl up and running
	move.l	a0,$70

* now VSYNC, and start scrolling. 

scroller
	move.l	#$64000,d0
	move.l	d0,scrn_base(a6)
	lsr.w	#8,d0
	move.l	d0,VBAS
	IFNE	DEBUG
	move.w	#$700,$ffff8240.w
	jsr	tune+8
	bsr		the_volume
	bsr 		the_scroll
	ENDC

*	every 500 frames, we change the shape on display. This is done
*	by accessing a shape table pointed to by shapptr. We then get the
*	program to modify itself(!) to set the new offsets for the three
*	shapes we display.

	sub.w	#1,timer(a6)
	bne.s	nonewshp
	move.w	#500,timer(a6)
	move.l	shapptr(a6),a0
	lea	-16(a0),a0
	tst.w	(a0)
	bne.s	noteoshp
	lea	shapend,a0
noteoshp
	move.l	a0,shapptr(a6)
	move.w	12(a0),d0
	move.w	d0,tag1+2
	move.w	d0,tag3+2
	move.w	d0,tag5+2
	move.w	d0,tag7+2
	move.w	d0,tag9+2
	move.w	d0,tag11+2
	move.w	14(a0),d0
	move.w	d0,tag2+2
	move.w	d0,tag4+2
	move.w	d0,tag6+2
	move.w	d0,tag8+2
	move.w	d0,tag10+2
	move.w	d0,tag12+2
nonewshp
	move.l	scrn_base(a6),a0
	lea	(39*160)+6(a0),a0
	moveq	#0,d0
	jsr	wipe

*	move the shape, by changing the x,y,z projection values.

	move.w	xangle(a6),d0
	move.w	yangle(a6),d1
	move.w	zangle(a6),d2
	addq	#2,d1			try changing...
	andi.w	#1023,d1
	move.w	d1,yangle(a6)
	addq	#4,d0			...these values...
	andi.w	#1023,d0
	move.w	d0,xangle(a6)
	addq	#6,d2			...between say 0 and 8
	andi.w	#1023,d2
	move.w	d2,zangle(a6)

*	rotate generates the matrix, according to the new x,y,z from
*	above.

	bsr	rotate

*	project puts each of the shape's points through the matrix.

	bsr	project
	move.l	shapptr(a6),a0
	moveq	#0,d4
	move.w	(a0),d4
	move.l	2(a0),a0

*	this draws the shape, by finding the edges and drawing lines
*	between them.
little
	lea	newpts,a1
	move.w	(a0)+,d5
	move.w	0(a1,d5.w),d0
	move.w	2(a1,d5.w),d1
	move.w	(a0)+,d5
	move.w	0(a1,d5.w),d2
	move.w	2(a1,d5.w),d3
	movem.l	d4/a0,-(sp)

*	add the origin. In this case it's the centre of the screen,
*	but a few lines of code could make it movable.

	add.w	#160,d0
	add.w	#100,d1
	add.w	#160,d2
	add.w	#100,d3
	bsr	the_line
	movem.l	(sp)+,d4/a0
	dbra	d4,little

vbl1	tst.b 	vbiflag(a6)
	beq	vbl1
	clr.b 	vbiflag(a6)
	move.l 	#$75000,d0
	move.l 	d0,scrn_base(a6)
	lsr.w 	#8,d0
	move.l 	d0,VBAS
	IFNE	DEBUG
	bsr	the_volume
	bsr 	the_scroll
	ENDC

	move.l	scrn_base(a6),a0
	lea	(39*160)+6(a0),a0
	moveq	#0,d0
	jsr	wipe
	move.w	xangle(a6),d0
	move.w	yangle(a6),d1
	move.w	zangle(a6),d2
	addq	#2,d1
	andi.w	#1023,d1
	move.w	d1,yangle(a6)
	addq	#4,d0
	andi.w	#1023,d0
	move.w	d0,xangle(a6)
	addq	#6,d2
	andi.w	#1023,d2
	move.w	d2,zangle(a6)
	bsr	rotate
	bsr	project
	move.l	shapptr(a6),a0
	moveq	#0,d4
	move.w	(a0),d4
	move.l	2(a0),a0
litt2	lea	newpts,a1
	move.w	(a0)+,d5
	move.w	0(a1,d5.w),d0
	move.w	2(a1,d5.w),d1
	move.w	(a0)+,d5
	move.w	0(a1,d5.w),d2
	move.w	2(a1,d5.w),d3
	movem.l	d4/a0,-(sp)
	add.w	#160,d0
	add.w	#100,d1
	add.w	#160,d2
	add.w	#100,d3
	bsr	the_line
	movem.l	(sp)+,d4/a0
	dbra	d4,litt2

	move.w	#$000,$ffff8240.w

vbl2	tst.b 	vbiflag(a6)
	beq 	vbl2
	clr.b 	vbiflag(a6)
	jmp	scroller(pc)

the_scroll
*	shift 20 long pointers 1 pointer left
	move.l	scrol_buf(a6),a0		the scrollbuffer
	movem.l	(a0)+,d0-d7/a1-a5		get 52 bytes (13 longs)
	movem.l	d1-d7/a1-a5,-52(a0)		that's the 1st bit,scroll done
	movem.l	(a0)+,d0-d6			get 28 bytes (7 longs)
	movem.l	d0-d6,-32(a0)			and shuffle left

	move.l	currchar(a6),a4
	lea	32(a4),a4
	move.l	a4,currchar(a6)
	subq.b	#1,bitshift(a6)
	bne	more_bits

*	each character is 8 words (columns) wide. Once we've displayed
*	all of them, we need to start the next character.
	moveq	#0,d0				
	move.l	txt_comp(a6),a2
	move.b	(a2)+,d0				get a character
	bpl	nowrap
	lea	scrol_txt(pc),a2
	moveq	#$20,d0
nowrap
	sub.b	#$20,d0				1st 32 not in charset
	lsl.w	#8,d0				multiply by 256
	move.l	a2,txt_comp(a6)
	move.l	bigset(a6),a1			where charset is
	lea	0(a1,d0.w),a4			get addr of char in font
	move.l	a4,currchar(a6)
	move.b	#8,bitshift(a6)
more_bits
	move.l	a4,-4(a0)				next bit of character

*	now the reaaalllyy boring bit. Each LONG in the buffer points
*	to a group of 16 words, each word being 1 row of the character.
*	The code we pregenerated earlier gets JSR'd, so it's FAST.

draw_it
	move.l	scrol_buf(a6),a2
	move.l	scrn_base(a6),a3
	lea	160*170(a3),a3
	jsr	drawscroll
	rts

*	Get the volume of each of the three channels and display
*	in graphic equalizer form. 

the_volume
	lea	PSG,a3
	move.l	scrn_base(a6),a0
	lea	42(a0),a1
	lea	equitab,a2
	moveq	#0,d2
	moveq	#-1,d3
	moveq	#0,d0
	move.b	#8,(a3)
	move.b	(a3),d0
	btst	#4,d0
	beq	notenv8
	moveq	#10,d0
notenv8
	move.b	d0,beeper(a6)
	asl.w	#2,d0
	move.l	0(a2,d0.w),a5
	jsr	(a5)

	lea	24(a1),a1
	moveq	#0,d0
	move.b	#9,(a3)
	move.b	(a3),d0
	btst	#4,d0
	beq	notenv9
	moveq	#10,d0

notenv9
	add.b	d0,beeper(a6)			
	asl.w	#2,d0
	move.l	0(a2,d0.w),a5
	jsr	(a5)

	lea	24(a1),a1
	moveq	#0,d0
	move.b	#10,(a3)
	move.b	(a3),d0
	btst	#4,d0
	beq	notenv10
	moveq	#10,d0

notenv10
	asl.w	#2,d0
	move.l	0(a2,d0.w),a5
	jsr	(a5)
	rts

*	rotate generates the matrix. Remember, since this is integer
*	maths, we can't use incremental co-ords or the rounding errors
*	eventually collapse our object to nothing!
*	input: x,y,z angles, all words, *2. In d0,d1,d2
*	THIS WILL MURDER CPU TIME!!!
*
rotate
	lea	sintab,a0
	lea	costab,a1
	lea	matrix,a2
	move.w	0(a0,d0.w),a3	a3=sin(x)
	move.w	0(a0,d1.w),a4	a4=sin(y)
	move.w	0(a0,d2.w),a5	a5=sin(z)
	move.w	0(a1,d0.w),d0	d0=cos(x)
	move.w	0(a1,d1.w),d1	d1=cos(y)
	move.w	0(a1,d2.w),d2	d2=cos(z)
	move.w	a4,d3		d3=sin(y)
	move.w	d3,d4		d4=sin(y)
	move.w	a3,d5
	muls.w	d5,d3		d3=sin(y)*sin(x)
	add.l	d3,d3		faster than asl.l #1,d3
	swap	d3		d3=t1
	muls.w	d0,d4		d4=sin(y)*cos(x)
	add.l	d4,d4		faster than asl.l #1,d4
	swap	d4		d4=t2
	move.w	d2,d5		d5=cos(z)
	muls.w	d1,d5		d5=cos(z)*cos(y)
	add.l	d5,d5		faster than asl.l #1,d5
	swap	d5
	move.w	d5,(a2)+		a2 base=R[0][0]
	move.w	d2,d5		d5=cos(z)
	muls.w	d3,d5		d5=cos(z)*t1
	move.w	a5,d6		d6=sin(z)
	muls.w	d0,d6		d6=sin(z)*cos(x)
	add.l	d5,d6		d6=cos(z)*t1+sin(z)*cos(x)
	add.l	d6,d6		faster than asl.l #1,d6
	swap	d6 
	move.w	d6,(a2)+		a2+2=R[0][1]

	move.w	d2,d5		d5=cos(z)
	muls.w	d4,d5		d5=cos(z)*t2
	move.w	a5,d6		d6=sin(z)
	move.w	a3,d7
	muls.w	d7,d6		d6=sin(z)*sin(x)
	sub.l	d6,d5		d5=cos(z)*t2-sin(z)*sin(x)
	add.l	d5,d5		faster than asl.l #1,d5
	swap	d5
	move.w	d5,(a2)+		a2+4=R[0][2]

	move.w	a5,d5		d5=sin(z)
	muls.w	d1,d5		d5=sin(z)*cos(y)
	add.l	d5,d5		faster than asl.l #1,d5
	swap	d5
	neg.w	d5		d5=-(sin(z)*cos(y))
	move.w	d5,(a2)+		a2+6=R[1][0]

	move.w	d2,d5		d5=cos(z)
	muls.w	d0,d5		d5=cos(z)*cos(x)
	move.w	a5,d6		d6=sin(z)
	muls.w	d3,d6		d6=sin(z)*t1
	sub.l	d6,d5		d5=cos(z)*cos(x)-sin(z)*t1
	add.l	d5,d5		faster than asl.l #1,d5
	swap	d5
	move.w	d5,(a2)+		a2+8=R[1][1]

	move.w	a5,d5		d5=sin(z)
	muls.w	d4,d5		d5=sin(z)*t2
	move.w	d2,d6		d6=cos(z)
	move.w	a3,d7	
	muls.w	d7,d6		d6=cos(z)*sin(x)
	add.l	d5,d6		d6=sin(z)*t2+cos(z)*sin(x)
	add.l	d6,d6		faster than asl.l #1,d6
	swap	d6
	neg.w	d6		d6=-(sin(z)*t2+cos(z)*sin(x))
	move.w	d6,(a2)+		a2+10=R[1][2]

	move.w	a4,d5		d5=sin(y)
	neg.w	d5		d5=-sin(y)
	move.w	d5,(a2)+		a2+12=R[2][0]

	move.w	d1,d5		d5=cos(y)
	move.w	a3,d7
	muls.w	d7,d5		d5=cos(y)*sin(x)
	add.l	d5,d5		faster than asl.l #1,d5
	swap	d5
	move.w	d5,(a2)+		a2+14=R[2][1]

	move.w	d1,d5		d5=cos(y)
	muls.w	d0,d5		d5=cos(y)*cos(x)
	add.l	d5,d5		faster than asl.l #1,d5
	swap	d5
	move.w	d5,(a2)		a2+16=R[2][2]
	rts

*	PROJECT takes each point in turn, multiplies it by the matrix
*	and perspects it, ready for the draw cycle.
*	If rotate doesn't kill CPU, PROJECT will. Do this once per point!
project
	move.l	shapptr(a6),a0
	moveq	#0,d7
	move.w	6(a0),d7
	move.l	8(a0),a1
	lea	newpts,a0		where they're going
	lea	matrix,a2
	move.l	a2,a3
projloop
	move.l	a3,a2		matrix multiplier
	move.w	(a1)+,d0		d0=x
	move.w	(a1)+,d1		d1=y
	move.w	(a1)+,d2		d2=z
	addq	#2,a1		skip the dummy
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a2)+,d3		d3=x*R[0][0]
	muls.w	(a2)+,d4		d4=y*R[0][1]
	muls.w	(a2)+,d5		d5=z*R[0][2]
	add.l	d3,d4
	add.l	d4,d5
	add.l	d5,d5		fast shift left
	swap	d5
	move.w	d5,d6		d6=temp.x

	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a2)+,d3		d3=x*R[1][0]
	muls.w	(a2)+,d4		d4=y*R[1][1]
	muls.w	(a2)+,d5		d5=z*R[1][2]
	add.l	d3,d4
	add.l	d4,d5
	add.l	d5,d5		fast shift left
	swap	d5

	move.w	d0,d3
	move.w	d5,d0		d0=temp.y here to save me
	move.w	d1,d4		having to move it to an
	move.w	d2,d5		address register

	muls.w	(a2)+,d3		d3=x*R[2][0]
	muls.w	(a2)+,d4		d4=y*R[2][1]
	muls.w	(a2),d5		d5=z*R[2][2]
	add.l	d3,d4
	add.l	d4,d5
	add.l	d5,d5		fast shift left
	swap	d5		d5=temp.z

	asr.w	#8,d6
	move.w	d6,(a0)+		x
	asr.w	#8,d0
	move.w	d0,(a0)+		y
	asr.w	#8,d5
	move.w	d5,(a0)+		z
	addq	#2,a0		skip dummy
	dbra	d7,projloop
	rts

*	the line drawer (ho-ho). Always draws, never undraws. Parameters
*	are D0=X1,D1=Y1,D2=X2,D3=Y2 ALL TRASHED!

the_line
*	First, if	X1>X2, swap values, as we always draw left to right

	move.l	#160,linedir(a6)	
	move.w	d2,d4
	sub.w	d0,d4		d4=x2-x1
	beq	vertline		if equal, must be vertical
	bpl	noswap1		eg 10-9=1,ie x2>x1, right way round
	neg.w	d4		negate, ie 9-10=-1, negate to 1
	exg	d0,d2		swap x
	exg	d1,d3		swap y
noswap1
*	Now calculate dy=abs(y2-y1)

	move.w	d3,d5
	sub.w	d1,d5		d5=y2-y1
	beq	horiline		if equal, must be vertical
	bpl	noswap2		if positive, that's fine
	neg.w	d5		otherwise make it so
	neg.l	linedir(a6)	reverse direction
noswap2
*	decide which linerout to use, low or high line
	lea	loslope,a5	assume low
	cmp.w	d4,d5			
	ble	calcx
	lea	hislope,a5	nope, high
	exg	d4,d5
calcx
* Now calc d, AINCR and BINCR
*	where d4=dx,d5=dy
	add.w	d5,d5		d5=2*dy		BINCR
	move.w	d5,d6
	sub.w	d4,d6		d6=2*dy-dx	d
	move.w	d6,d7
	sub.w	d4,d7		d7=2*(dy-dx)	AINCR
*	So in summary, d5=bincr,d6=d,d7=AINCR
*	The original co-ords are still in d0-d1
*	We're going to trash them now.
set_pix1
	move.w	d0,d3
	asr.w	#1,d0
	and.w	#%1111111111111000,d0
	movea.w	d0,a0
	adda.l	scrn_base(a6),a0
	lea	6(a0),a0		bitplane offset	
	lea	multab,a1
	lsl.w	#2,d1
	adda.l	0(a1,d1.w),a0

	andi.w	#$0f,d3
	add.w	d3,d3
	lea	pixlook,a1
	move.w	0(a1,d3.w),d0	

*	ok, the super hoopy-doopy low and high line drawer branch
*	and a5 says where to go,so...
	move.l	linedir(a6),d3	yincr
	jmp (a5)

*	d4=no. of pixels to draw,a0=address of 16 bit group,
*	d0=mask for 1st pixel,d7=AINCR,d5=BINCR,d4=yincr,d6=d
loslope
	move.w	d0,d2		start value
nxtbit	or.w	d0,d2
	ror.w	#1,d0		go right!
	bcs.s	maskout		off right hand edge of 16 bits
	tst.w	d6
	bpl.s	goinup
	add.w	d5,d6		d=d+aincr
	dbra	d4,nxtbit
	or.w	d2,(a0)
tag1	or.w	d2,32(a0)		TAGGED
tag2	or.w	d2,64(a0)		TAGGED
	rts
goinup	add.w	d7,d6		d=d+bincr
	or.w	d2,(a0)
tag3	or.w	d2,32(a0)		TAGGED
tag4	or.w	d2,64(a0)		TAGGED
	adda.l	d3,a0
	dbra	d4,loslope
	rts
maskout	or.w	d2,(a0)
tag5	or.w	d2,32(a0)		TAGGED
tag6	or.w	d2,64(a0)		TAGGED
	addq.l	#8,a0		ie. right one group
	tst.w	d6
	bpl.s	goinup2
	add.w	d5,d6
	dbra	d4,loslope
	rts
goinup2	add.w	d7,d6		d=d+bincr
	adda.l	d3,a0		addr=addr+line
	dbra	d4,loslope
	rts

*	d4=no. of pixels to draw,a0=address of 16 bit group,
*	d0=mask for 1st pixel,d7=AINCR,d5=BINCR,d4=yincr,d6=d,d3=yincr
hislope	or.w	d0,(a0)
tag7	or.w	d0,32(a0)		TAGGED
tag8	or.w	d0,64(a0)		TAGGED
	add.l	d3,a0
	tst.w	d6
	bpl	shiftmsk
	add.w	d5,d6
	dbra	d4,hislope
	rts
shiftmsk
	add.w	d7,d6
	ror.w	#1,d0
	bcc.s	noright
	addq.l	#8,a0
noright	dbra	d4,hislope
	rts

*	Vertical line drawer, for extra speed.
vertline
	move.w	d3,d5
	sub.w	d1,d5		d5=y2-y1
	bpl	noinv2
	neg.w	d5		d5=abs(y2-y1)	no. of pixels
	move.w	d3,d1		nope.start at y2
noinv2	move.l	#160,d7		draw in line increments

*	address of pixel indicated by d0,d1 (x1,y1)
set_pix3
	move.w	d0,d3
	asr.w	#1,d0
	and.w	#%1111111111111000,d0
	movea.w	d0,a0
	adda.l	scrn_base(a6),a0
	lea	6(a0),a0		bitplane offset	
	lea	multab,a1
	lsl.w	#2,d1
	adda.l	0(a1,d1.w),a0

	andi.w	#$0f,d3
	asl.w	#1,d3
	lea	pixlook,a1
	move.w	0(a1,d3.w),d0	

*	a0=first screen location word. d0=bitmask. d5=no. pixels.
*	d7=size of line in bytes

vtloop	or.w	d0,(a0)
tag9	or.w	d0,32(a0)		TAGGED
tag10	or.w	d0,64(a0)		TAGGED
	add.l	d7,a0
	dbra	d5,vtloop
	rts

horiline	
*	horizontal line draw.
*	d4 already holds x2-x1, ie the number of pixels to draw.

set_pix4
	move.w	d0,d3
	asr.w	#1,d0
	and.w	#%1111111111111000,d0
	movea.w	d0,a0
	adda.l	scrn_base(a6),a0
	lea	6(a0),a0			bitplane offset	
	lea	multab,a1
	lsl.w	#2,d1
	adda.l	0(a1,d1.w),a0

	andi.w	#$0f,d3
	asl.w	#1,d3
	lea	pixlook,a1
	move.w	0(a1,d3.w),d0
	andi.w	#$fff0,sr			clear X flag	

*	a0=address of 1st 16 bit block, d0=bitmask, d4=no. of pixels.
hlloop	or.w	d0,(a0)
tag11	or.w	d0,32(a0)			TAGGED
tag12	or.w	d0,64(a0)			TAGGED
	roxr.w	#1,d0
	bne	noaddon
	addq.l	#8,a0			next group
noaddon	dbra	d4,hlloop
	rts

*	D0=X D1=Y, bitplane assumed to be zero at the mo.
set_pixel
	move.w	d0,d3
	asr.w	#1,d0
	and.w	#%1111111111111000,d0
	movea.w	d0,a0
	adda.l	scrn_base(a6),a0
	
	lea	multab,a1
	lsl	#2,d1
	adda.l	0(a1,d1.w),a0
	andi.w	#$0f,d3
	asl.w	#1,d3
	lea	pixlook,a1
	move.w	0(a1,d3.w),d0	
	or.w	d0,(a0)			was 0(a0,d2.w)
	rts

*	The vertical blank routine.
vbl	movem.l	d0-d7/a0-a6,-(sp)
	IFNE	DEBUG
	clr.b	TBCR		timer b control off
	lea	hbl1(pc),a0
	move.l	a0,$120		set interrupt event vector
	move.b	#2,TBDR		interrupt occurs nnn hbl from now
	move.b	#8,TBCR		timer b running
	ENDC
	lea	variables(pc),a0
	move.b	#1,vbiflag(a0)
	move.b	#8,vbicnt
	move.l	#coltab,starcol
	move.l	logocol,a1
	sub.w	#1,delayer(a0)
	bne	notlogend
	move.w	#4,delayer(a0)
	addq	#2,a1
	cmp.l	#allcols+512-16,a1
	bne	notlogend
	lea	allcols,a1
notlogend
	move.l	a1,logocol
	move.l	a1,logotemp
	move.w	(a1),d0
	move.w	d0,PAL_04
	move.b	#15,logcnt
	move.w	timer(a0),d0
	and.w	#$fffe,d0			ie make it even!
	lea	drawcol,a0
	move.w	0(a0,d0.w),PAL_08
noshow	movem.l	(sp)+,d0-d7/a0-a6
	rte
*	Horizontal blank routine 1. Change the colours in the logos.
hbl1
	move.l	a0,-(sp)
	move.l	logotemp,a0
	move.w	(a0)+,PAL_04
	sub.b	#1,logcnt
	bne	notlog
	clr.b	TBCR
	move.b	#131,TBDR
	move.l	#hbl1a,$120
	move.b	#8,TBCR
notlog
	move.l	a0,logotemp
	move.l	(sp)+,a0	
	bclr	#0,ISRA
	rte

*	Horizontal blank routine 1a. Sets the colour registers for the
*	scroller, and kicks off HBL2 every 4 hblanks
hbl1a
	clr.b	TBCR		timer b control off
	move.b	#4,TBDR		interrupt occurs 4 hbl from now
	move.l	#hbl2,$120
	move.b	#8,TBCR		timer b running	
	move.w	#$000,PAL_01
	bclr	#0,ISRA
	rte

*	Alter scroller colours every 4 hblanks, and when we get near
*	bottom border, kick in the border buster, a.k.a. HBL3
hbl2	move.l	a0,-(sp)
	move.l	starcol,a0
	move.w	(a0)+,PAL_01
	sub.b	#1,vbicnt
	bne	noteoc
	clr.b	TBCR
	move.b	#6,TBDR
	move.l	#hbl3,$120
	move.b	#8,TBCR
noteoc	move.l	a0,starcol
	move.l	(sp)+,a0	
	bclr	#0,ISRA
	rte

*	In theory, this busts the bottom border by changing screen
*	rates at odd times, so the MMU forgets to go back to the
*	top straight away. Is it STE compatible ???	YES!
* 	Once busted, puts HBL2 back in the driving seat.
hbl3	clr.b   	TBCR		timer stop
	move.l 	d0,-(sp)
	move.l	a0,-(sp)
	move.w  	#$fa21,a0
	move.b  	#200,(a0)	
	move.b  	#8,TBCR	
	move.b  	(a0),d0
wait4	cmp.b   	(a0),d0		wait last scanline
	beq     	wait4		
	clr.b   	SYNC		60 Hz
	moveq   	#2,d0
nopi2	nop
	dbf     	d0,nopi2
	move.b  	#2,SYNC		50 Hz
	move.l	(sp)+,a0
	move.l	(sp)+,d0
	clr.b   	TBCR				
	move.b	#4,TBDR
	move.l	#hbl2,$120
	move.b	#8,TBCR
	bclr    	#0,ISRA			
	rte						
*	The new timer C keyboard routine - do nothing as we don't have
*	the time to spare.
key	move.w	#$2500,sr
	bclr	#6,ISRB
	rte

vbstop	dc.w	0
starcol	ds.l	1
logocol	ds.l	1
logotemp	ds.l	1

zaph	dc.w	$00CF,$0000,$0000,$0000,$0000,$0140,$8000,$0000
	dc.w	$0000,$0000,$0247,$0000,$0000,$0000,$0000,$03E8
	dc.w	$0000,$0000,$0000,$0000,$004F,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$01FF,$E01E
	dc.w	$01FF,$81E1,$E000,$03FF,$C03C,$03FF,$03C3,$C000
	dc.w	$0003,$C0FF,$03C3,$C3C3,$C000,$0007,$81FE,$0787
	dc.w	$8787,$8000,$001E,$0787,$8787,$8787,$8000,$003C
	dc.w	$0F0F,$0F0F,$0F0F,$0000,$00F0,$0F0F,$0FFC,$0FFF
	dc.w	$0000,$01E0,$1E1E,$1FF8,$1FFE,$0000,$0780,$1FFE
	dc.w	$1E00,$1E1E,$0000,$0F00,$3FFC,$3C00,$3C3C,$0000
	dc.w	$3C00,$3C3C,$3C00,$3C3C,$0000,$7800,$7878,$7800
	dc.w	$7878,$0000,$7FF8,$7878,$7800,$7878,$0000,$FFF0
	dc.w	$F0F0,$F000,$F0F0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0678,$0000,$0000,$0000
	dc.w	$0000,$0A04,$0000,$0000,$0000,$0000,$1238,$0000
	dc.w	$0000,$0000,$0000,$1F40,$0000,$0000,$0000,$0000
	dc.w	$027C,$0000

dixie2	dc.w	$0400,$0000,$0000,$0604,$0000,$0000,$0745,$0000
	dc.w	$0000,$0745,$0000,$0000,$076D,$4000,$0000,$076D
	dc.w	$C400,$0000,$FFFF,$FFFF,$FFFE,$06A9,$2200,$0000
	dc.w	$06A9,$2000,$0000,$06A9,$0000,$0000,$02A8,$0000
	dc.w	$0000,$02A0,$0000,$0000,$0290,$0000,$0000,$0210
	dc.w	$0000,$0000,$0210,$0000,$0000,$0210,$0000,$0000
	dc.w	$0200,$0000,$0000,$0001,$F45F,$0000,$0000,$4450
	dc.w	$0000,$0000,$47DE,$0000,$0000,$4450,$0000,$0000
	dc.w	$445F,$0000,$0000,$0000,$0000,$0078,$E44E,$7C00
	dc.w	$0044,$4284,$4000,$0040,$4104,$7800,$0044,$4284
	dc.w	$4000,$0078,$E44E,$7C00,$0000,$0000,$0000,$F907
	dc.w	$3E41,$C8BE,$8108,$8840,$8CA0,$F10F,$8840,$8ABC
	dc.w	$8108,$8840,$89A0,$81E8,$8879,$C8BE

*	SINTAB is the sine table.
	include	sintab.s

*	And...COSTAB is the COS table.
	include	costab.s

coltab1		dc.w	$111,$111,$222,$333,$444,$555,$666,$777
		dc.w	$666,$555,$444,$333,$222,$111,$111,$000
coltab		dc.w	$001,$002,$003,$004,$005,$006,$007,$007
		dc.w	$007,$006,$005,$004,$003,$002,$001,$000
allcols		ds.w	2048
drawcol		ds.w	501
scrol_txt	
	dc.b	"........WOW!!! THIS IS THE FIRST DEMO BY....."
	DC.B "***ROM CONSTRUCT CREW***  CONSISTING OF   ZAPH"
	DC.B " AND   THE DIXIE FLATLINE. THANX FOR WRITING, "
	DC.B "IT'S GOOD TO HEAR THERE ARE OTHER BEGINNERS "
	DC.B "OUT THERE BESIDES MYSELF AND ZAPH! TO EXPLAIN: "
	DC.B "THE DIXIE FLATLINE IS CODER FOR RCC. ZAPH IS "
	DC.B "DEEP BACKGROUND - EG. THE MATHS FOR THIS DEMO "
	DC.B "WERE WORKED OUT BY ZAPH (EVEN IF I COULDN'T "
	DC.B "QUITE FIT IT ALL IN ONE VBLANK!) AND THE SECOND "
	dc.b "DEMO NOW UNDER CONSTRUCTION WILL HAVE A STARFIELD "
	dc.b "WORKED OUT BY ZAPH. HE'S MORE A 'C' AND PC TYPE, "
	dc.b "BUT DON'T HOLD THAT AGAINST HIM. MIND LIKE A"
	dc.b "RAZOR!         STILL THERE ? OK. IF YOU GET "
	dc.b "BORED	TRYING TO READ THIS FASTSCROLL, THE DEMO "
	dc.b "SOURCE IN THE FOLDER IS MUCH EASIER TO READ. "	
	dc.b "ANYWAY, THE OBJECTIVES OF RCC ARE : 1. PRODUCE "
	dc.b "GOOD, SIMPLE DEMOS (TO START WITH), PROPERLY "
	dc.b "DOCUMENTED AS PER THIS ONE, TO BE RELEASED INTO "
	dc.b "THE PUBLIC DOMAIN WHEN COMPLETE, SOURCE AND ALL. "
	dc.b "THIS IS TO HELP AND ENCOURAGE NEW CODERS, SINCE "
	dc.b "THE BIG CREWS HIDE THEIR TECHNIQUES AND CODE, "
	dc.b "MAKING IT DAMN DIFFICULT FOR STARTERS LIKE US. "
	dc.b "2. NO CRACKED CODE, NO RIPPED CODE, BUT PD FONTS "
	dc.b "AND MUSIX ARE OK, EG. TRACKER MODULES. THE WHOLE "
	dc.b "POINT IS TO LEARN, NOT TO STEAL!   3. MODULAR "
	dc.b "DESIGN - IE. WE AGREE THE DEMO DESIGN, DISCUSS THE "
	dc.b "TECHNIQUES NEEDED, THEN ASSIGN EACH FACET OF THE "
	DC.B "PROGRAM TO A MEMBER TO DEVELOP. NO DEADLINES, AND "
	DC.B "NOT A FULL-TIME JOB (I'VE GOT ONE - SYSTEMS "
	DC.B "ANALYST FOR AN INSURANCE COMPANY - YEP, AS BORING "
	DC.B "AS IT SOUNDS - WHY DO YOU THINK I WRITE DEMOS!! "
	DC.B "4. NO SWEARING IN THE CODE/SCROLLS - EVEN THOUGH "
	DC.B "WE MIGHT SWEAR PLENTY WHEN WRITING IT!! "
	dc.b "THANX FOR THE DISKS, I'M RETURNING THE MUSIX ONE "
	DC.B "FOR THE REASON ABOVE. ONE OF THE FONTS HAS ALREADY "
	DC.B "BEEN PRESSED INTO SERVICE FOR SOME LETTER SPRITES "
	DC.B "AND LOOKING GOOD TOO! FOR GOD'S SAKE, DON'T WORRY "
	DC.B "ABOUT BEING A BEGINNER. IT'S A SLOW PROCESS - WE "
	DC.B "TOOK SIX MONTHS TO BUILD THIS DEMO FROM KNOWING "
	DC.B "NOTHING ABOUT 68000 MACHINE CODE OR THE ST HARDWARE "
	DC.B "SO FIVE WEEKS TO ACTUALLY GET SOMETHING WORKING IS "
	DC.B "DAMN GOOD! HOPEFULLY, THE DEMO SOURCE ON THIS DISK "
	DC.B "WILL HELP, AS THAT'S THE WHOLE POINT OF RCC. IF YOU "
	DC.B "DO WANT TO JOIN A CREW AT ANY TIME IN THE FUTURE, "
	DC.B "LET ME KNOW. I HAD ONE OTHER REPLY TO THE AD, SO "
	DC.B "RCC MAY JUST HAVE INCREASED IN SIZE BY 50 PERCENT! "
	DC.B "ANYTIME YOU FEEL LIKE WRITING, OR ANY QUESTIONS YOU "
	DC.B "HAVE, FEEL FREE, SAME ADDRESS. DEMO 2 IS IN "
	DC.B "PROGRESS AS WE SPEAK! "
	DC.B "MARC FREEBURY, AKA THE DIXIE FLATLINE. "
	DC.B -1
	even

*	points is the x,y,z of each point in the shape, *256
points
	dc.w	-9216,3072,-3072,0
	dc.w	-3072,9216,-3072,0
	dc.w	3072,9216,-3072,0
	dc.w	9216,3072,-3072,0
	dc.w	9216,-3072,-3072,0
	dc.w	3072,-9216,-3072,0
	dc.w	-3072,-9216,-3072,0
	dc.w	-9216,-3072,-3072,0

	dc.w	-9216,3072,3072,0
	dc.w	-3072,9216,3072,0
	dc.w	3072,9216,3072,0
	dc.w	9216,3072,3072,0
	dc.w	9216,-3072,3072,0
	dc.w	3072,-9216,3072,0
	dc.w	-3072,-9216,3072,0
	dc.w	-9216,-3072,3072,0

points2
	dc.w	-6400,-6400,6400,0
	dc.w	-6400,6400,6400,0
	dc.w	6400,6400,6400,0
	dc.w	6400,-6400,6400,0
	dc.w	-6400,-6400,-6400,0
	dc.w	-6400,6400,-6400,0
	dc.w	6400,6400,-6400,0
	dc.w	6400,-6400,-6400,0
points3
	dc.w	0,0,0,0
	dc.w	-6400,6400,6400,0
	dc.w	-6400,6400,-6400,0
	dc.w	6400,6400,-6400,0
	dc.w	6400,6400,6400,0
	dc.w	-6400,-6400,6400,0
	dc.w	-6400,-6400,-6400,0
	dc.w	6400,-6400,-6400,0
	dc.w	6400,-6400,6400,0

points4
;	dc.w	-12800,2560,0,0
;	dc.w	-7680,2560,0,0
;	dc.w	-12800,-2560,0,0
;	dc.w	-7680,-2560,0,0
;	dc.w	-5120,-2560,0,0
;	dc.w	-3840,0,0,0
;	dc.w	-2560,2560,0,0
;	dc.w	-1280,0,0,0
;	dc.w	0,-2560,0,0
;	dc.w	1280,-2560,0,0
;	dc.w	1280,0,0,0
;	dc.w	1280,2560,0,0
;	dc.w	5120,2560,0,0
;	dc.w	7680,2560,0,0
;	dc.w	7680,0,0,0
;	dc.w	7680,-2560,0,0
;	dc.w	12800,2560,0,0
;	dc.w	12800,0,0,0
;	dc.w	12800,-2560,0,0
;	dc.w	5120,1280,0,0
;
points5
	dc.w	0,-6144,0,0
	dc.w	-3072,-3584,0,0
	dc.w	-1536,-2560,0,0
	dc.w	-7168,1024,0,0
	dc.w	-7168,-6656,0,0
	dc.w	-10240,3072,0,0
	dc.w	-9216,4096,0,0
	dc.w	-3584,2560,0,0
	dc.w	3584,2560,0,0
	dc.w	9216,4096,0,0
	dc.w	10240,3072,0,0
	dc.w	7168,-6656,0,0
	dc.w	7168,1024,0,0
	dc.w	1536,-2560,0,0
	dc.w	3072,-3584,0,0
	dc.w	0,-3584,-2560,0
	dc.w	0,-3584,2560,0
	dc.w	0,2560,-2560,0
	dc.w	0,2560,2560,0
	dc.w	0,-2560,0,0

;points6
;	dc.w	-15360,-3840,0,0
;	dc.w	-15360,3840,0,0
;	dc.w	-11520,3840,0,0
;	dc.w	-10240,2560,0,0
;	dc.w	-10240,-2560,0,0
;	dc.w	-11520,-3840,0,0
;	dc.w	-5120,3840,0,0
;	dc.w	-5120,-3840,0,0
;	dc.w	-2560,3840,0,0
;	dc.w	2560,-3840,0,0
;	dc.w	2560,3840,0,0
;	dc.w	-2560,-3840,0,0
;	dc.w	5120,3840,0,0
;	dc.w	5120,-3840,0,0
;	dc.w	10240,3840,0,0
;	dc.w	15360,3840,0,0
;	dc.w	10240,0,0,0
;	dc.w	15360,0,0,0
;	dc.w	10240,-3840,0,0
;	dc.w 15360,-3840,0,0
;
points7
	dc.w	-6400,-7680,0,0
	dc.w	-6400,8960,0,0
	dc.w	6400,8960,0,0
	dc.w	6400,2560,0,0
	dc.w	-6400,2560,0,0
	dc.w	-6400,5632,0,0
	dc.w	6400,5632,0,0
	dc.w	-3840,-2560,0,0
	dc.w	-3840,-7680,0,0
	dc.w	-1280,-7680,0,0
	dc.w	-1280,-2560,0,0
	dc.w	2560,-2560,0,0
	dc.w	2560,-7680,0,0
	dc.w	2560,-5120,0,0
	dc.w	6400,-3840,0,0
	dc.w	6400,-7680,0,0
	dc.w	0,8960,0,0
	dc.w	0,2560,0,0

points8
	dc.w	-12800,0,0,0
	dc.w	-10240,-1280,-1280,0
	dc.w	-10240,1280,0,0
	dc.w	-10240,-1280,1280,0
	dc.w	6400,0,0,0
	dc.w	12800,-2560,-2560,0
	dc.w	12800,2560,0,0
	dc.w	12800,-2560,2560,0
	dc.w	0,8960,-6400,0
	dc.w	0,-8960,-6400,0
	dc.w	0,8960,6400,0
	dc.w	0,-8960,6400,0

*	edges is the point-to-point drawing of lines.
edges
	dc.w	0*8,3*8
	dc.w	3*8,4*8
	dc.w	4*8,7*8
	dc.w	7*8,0*8

	dc.w	1*8,2*8
	dc.w	2*8,5*8
	dc.w	5*8,6*8
	dc.w	6*8,1*8

	dc.w	9*8,10*8
	dc.w	10*8,13*8
	dc.w	13*8,14*8
	dc.w	14*8,9*8

	dc.w	8*8,11*8
	dc.w	11*8,12*8
	dc.w	12*8,15*8
	dc.w	15*8,8*8

	dc.w	0*8,8*8
	dc.w	1*8,9*8
	dc.w	2*8,10*8
	dc.w	3*8,11*8
	dc.w	4*8,12*8
	dc.w	5*8,13*8
	dc.w	6*8,14*8
	dc.w	7*8,15*8

edges2
	dc.w	0*8,3*8
	dc.w	3*8,7*8			cube front
	dc.w	7*8,4*8
	dc.w	4*8,0*8

	dc.w	1*8,2*8
	dc.w	2*8,6*8
	dc.w	6*8,5*8			cube back
	dc.w	5*8,1*8

	dc.w	0*8,1*8
	dc.w	2*8,3*8
	dc.w	4*8,5*8			cube connectors
	dc.w	6*8,7*8
edges3
	dc.w	0*8,1*8
	dc.w	0*8,2*8
	dc.w	0*8,3*8
	dc.w	0*8,4*8
	dc.w	0*8,5*8
	dc.w	0*8,6*8
	dc.w	0*8,7*8
	dc.w	0*8,8*8
	dc.w	1*8,2*8
	dc.w	2*8,3*8
	dc.w	3*8,4*8
	dc.w	4*8,1*8
	dc.w	5*8,6*8
	dc.w	6*8,7*8
	dc.w	7*8,8*8
	dc.w	8*8,5*8

;edges4
;	dc.w	0*8,1*8
;	dc.w	1*8,2*8		'Z'
;	dc.w	2*8,3*8
;
;	dc.w	4*8,6*8
;	dc.w	6*8,8*8		'A'
;	dc.w	5*8,7*8
;
;	dc.w	9*8,11*8
;	dc.w	11*8,12*8		'P'
;	dc.w	12*8,19*8
;	dc.w	19*8,10*8
;
;	dc.w	13*8,15*8
;	dc.w	16*8,18*8		'H'
;	dc.w	14*8,17*8

edges5
	dc.w	0*8,1*8
	dc.w	1*8,2*8
	dc.w	2*8,5*8
	dc.w	3*8,4*8
	dc.w	5*8,6*8
	dc.w	6*8,7*8
	dc.w	8*8,9*8
	dc.w	9*8,10*8
	dc.w	10*8,13*8
	dc.w	11*8,12*8
	dc.w	13*8,14*8
	dc.w	14*8,0*8

	dc.w	2*8,15*8
	dc.w	13*8,15*8
	dc.w	15*8,0*8

	dc.w	2*8,16*8
	dc.w	13*8,16*8
	dc.w	16*8,0*8

	dc.w	7*8,17*8
	dc.w	8*8,17*8
	dc.w	17*8,19*8

	dc.w	7*8,18*8
	dc.w	8*8,18*8
	dc.w	18*8,19*8

;edges6
;	dc.w	0*8,1*8
;	dc.w	1*8,2*8
;	dc.w	2*8,3*8			'D'
;	dc.w	3*8,4*8
;	dc.w	4*8,5*8
;	dc.w	5*8,0*8
;
;	dc.w	6*8,7*8			'I'
;
;	dc.w	8*8,9*8
;	dc.w	10*8,11*8		'X'
;
;	dc.w	12*8,13*8		'I'
;
;	dc.w	14*8,15*8
;	dc.w	16*8,17*8		'E'
;	dc.w	18*8,19*8
;	dc.w	14*8,18*8
edges7
	dc.w	0*8,1*8
	dc.w	1*8,2*8
	dc.w	2*8,3*8
	dc.w	3*8,4*8
	dc.w	4*8,2*8
	dc.w	1*8,3*8
	dc.w	5*8,6*8
	dc.w	16*8,17*8

	dc.w	7*8,8*8
	dc.w	8*8,9*8
	dc.w	9*8,10*8

	dc.w	11*8,12*8
	dc.w	13*8,14*8
	dc.w	13*8,15*8
;edges8
;	dc.w	0*8,1*8
;	dc.w	0*8,2*8
;	dc.w	0*8,3*8
;
;	dc.w	1*8,2*8
;	dc.w	2*8,3*8
;	dc.w	3*8,1*8
;
;	dc.w	0*8,4*8
;	dc.w	4*8,5*8
;	dc.w 4*8,6*8
;	dc.w	4*8,7*8
;
;	dc.w	5*8,6*8
;	dc.w	6*8,7*8
;	dc.w	7*8,5*8
;
;	dc.w	5*8,8*8
;	dc.w	8*8,9*8
;	dc.w	9*8,5*8
;
;	dc.w	7*8,10*8
;	dc.w	10*8,11*8
;	dc.w	11*8,7*8
;
*	data structure holding info about the shapes above. First
*	entry is a dummy. Format is number of edges,address,number
*	of points,address,offset shape 1,offset shape 2. To add a new
*	shape to the demo, work out the co-ords an a 40x40 grid, multiply
*	each by 256, and place in POINTSx, in the form x,y,z,dummy(0).
*	Then work out the lines connecting the points (remember the first
*	point is point zero!), and place each from/to pair in EDGESx.
*	Lastly, just after label SHAPSTART below, add your new shape.
*	Remember if you have 20 edges and 19 points, and this is shape
*	10, the entry will be :
*		dc.w	19 (ie. number of edges -1!)
*		dc.l	EDGES10
*		dc.w	18 (ie. number of points -1)
*		dc.l	POINTS10
*		dc.w	0
*		dc.w	0	experiment. Must be pos/neg multiples of 8. 
	dc.w 0
	dc.l	0
	dc.w	0
	dc.l	0
	dc.w	0
	dc.w	0
shapstart
;	dc.w	18
;	dc.l	edges8
;	dc.w	11
;	dc.l	points8
;	dc.w	0
;	dc.w	0

	dc.w	13
	dc.l	edges7
	dc.w	17
	dc.l	points7
	dc.w	0
	dc.w	0

;	dc.w	13
;	dc.l	edges6
;	dc.w	19
;	dc.l	points6
;	dc.w	0
;	dc.w	0

;	dc.w	23
;	dc.l	edges5
;	dc.w	19
;	dc.l	points5
;	dc.w	-32
;	dc.w	+32

;	dc.w	12
;	dc.l	edges4
;	dc.w	19
;	dc.l	points4
;	dc.w	-32+(160*10)
;	dc.w	+32-(160*10)

	dc.w	23
	dc.l	edges
	dc.w	15
	dc.l	points
	dc.w	-32
	dc.w	+32

	dc.w	15
	dc.l	edges3
	dc.w	8
	dc.l	points3
	dc.w	-24
	dc.w	+24

	dc.w	11
	dc.l	edges2
	dc.w	7
	dc.l	points2
	dc.w	-32-(160*10)
	dc.w	32+(160*10)	

	dc.w	11
	dc.l	edges2
	dc.w	7
	dc.l	points2
	dc.w	0
	dc.w	32+(160*10)	

shapend
*		shapend must be at start of last shape!
	dc.w	11
	dc.l	edges2
	dc.w	7
	dc.l	points2
	dc.w	0
	dc.w	0	

logcnt		ds.w	1
vbicnt		ds.w	1
colours		ds.w	1
matrix		ds.w	9
newpts		ds.w	30*4		points,x,y,z and dummy
equitab		ds.l	16

* rs.b is a way of defining a label as an offset for a (a6) -
* eg load_addr(a6) easier to understand than 0(a6)
variables		ds.l	1024
scrol_buf		rs.l	1
txt_comp		rs.l	1
bitshift		rs.b	1
vbiflag		rs.b	1
bigset		rs.l	1
currchar		rs.l	1
scrn_base		rs.l	1
showimg		rs.l	1
imgcnt		rs.b	1
beeper		rs.b	1
linedir		rs.l	1
xangle		rs.w	1
yangle		rs.w	1
zangle		rs.w	1
shapptr		rs.l 1
timer		rs.w 1
delayer		rs.w	1

*	pixel lookup. The position of the first pixel in a word
*	when working out first pixel position in a line.
pixlook
	dc.w	%1000000000000000
	dc.w	%0100000000000000
	dc.w	%0010000000000000
	dc.w	%0001000000000000
	dc.w	%0000100000000000
	dc.w	%0000010000000000
	dc.w	%0000001000000000
	dc.w	%0000000100000000
	dc.w	%0000000010000000
	dc.w	%0000000001000000
	dc.w	%0000000000100000
	dc.w	%0000000000010000
	dc.w	%0000000000001000
	dc.w	%0000000000000100
	dc.w	%0000000000000010
	dc.w	%0000000000000001

load_addr	include	fontish.s
	even

tune	incbin	g:\music\new_rips.msd\music.mus
	ds.l	200

thestack
	ds.l	1

*	The bit below is a partial answer to the fact that DEVPAC 1
*	doesn't support BSS, ie. all DS directives are placed in the
*	object file. This should get round it making the object smaller.
bigchars
* bigchars is 64*16*16 long
scrollit		equ	bigchars+64*16*16
* scrollit is 40*16 long
drawscroll	equ	scrollit+40*16
*drawscroll is 6144 long(very approx!)
multab		equ	drawscroll+6144
*multab is 800 long (200*4)
wipe			equ	multab+200*4
*wipe is 10240 long (approx)
graphix		equ wipe+10240
*graphix is 16*32*4 plus a bit, say 3072
	ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	endc

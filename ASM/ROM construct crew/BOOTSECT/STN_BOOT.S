shortvers	equ 1		1=full code, 0=just bootsector
**************************************************************
	bra	doitall
boot_code
	opt o+
*
*	The Rom Construct Crew Bid-for-fame Bootsector!
*	Produced for ST News, in the hope they'll use it!
*	programmed by the Dixie Flatline.
*
*	Started : 20/09/91
*	Finished:	28/09/91	- it's been a bad week at work!
*
*	A brief note : no screen-flipping employed, It seems ok
*	without it. Also, this code is fairly well behaved, minimal
*	direct-to-hardware stuff, so it's compatible with
*	all mods/revs of the ST (hmmm.)
*
*	First, some very useful equates.
*
IERA		equ	$fffffa07		interrupt enable register A
IERB		equ	$fffffa09		interrupt enable register B
IPRA		equ	$fffffa0b		interrupt pending register A
IPRB		equ	$fffffa0d		interrupt pending register B
ISRA		equ	$fffffa0f		interrupt in-service register A
ISRB		equ	$fffffa11		interrupt in-service register B
IMRA		equ	$fffffa13		interrupt mask register A
IMRB		equ	$fffffa15		interrupt mask register B
TACR		equ	$fffffa19		timer A control register
TBCR		equ	$fffffa1b		timer B control register
TCDCR		equ	$fffffa1d		timer C/D control register
TADR		equ	$fffffa1f		timer A data register
TBDR		equ	$fffffa21		timer B data register
TCDR		equ	$fffffa23		timer C data register
TDDR		equ	$fffffa25		timer D data register

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

ACIAC		equ	$fffffc00		keyboard control
ACIAD		equ	$fffffc02		keyboard data

VBAS		equ	$ffff8200		video base (really $f8201)
SYNC		EQU	$ffff820a		sync mode 50/60 hz

PSG		equ	$ffff8800		YM2149 register select/read/write

	even
*
*	as always, supervisor mode. This is for development only.
*	When on a bootsector, it's not needed as boot code is
*	automatically run in supervisor mode.
*
*	clr.l	-(sp)  		
*	move.w	#32,-(sp) 
*	trap	#1
*	addq.l	#6,sp

*
*	Mono monitor detect. If mono, jump straight out.
*
	btst	#7,$fffffa01.w
	beq	monomon


*
*	Hide mouse
*

	dc.w	$a00a


*
* Set low res. Again, only needed for dev. Colour STs will boot
* to low-res automatically.
*
*	clr.w	-(a7)
*	moveq	#-1,d0
*	move.l	d0,-(a7)
*	move.l	d0,-(a7)
*	move.w	#5,-(a7)
*	trap	#14
*	lea	$0c(a7),a7
*
* Bitplane 3 'ST' fill, using a-line rectangle. (shortest code)
*

	dc.w	$a000		get A-LINE variables address
	clr.l	$18(a0)		bitplanes 1 & 2 zero(1 word each)
	move.l	#$ffff0000,$1c(a0)	bitplane 3=1 and 4=0
	clr.l	$26(a0)		x1=0,y1=0
	move.l	#$013f00c7,$2a(a0)	x2=319,y2=199 (1 word each)
	move.w	#6,$32(a0)	size of fill pattern in lines
	lea	filler2(pc),a1	where it is
	move.l	a1,$2e(a0)
	dc.w	$a005		fill it
*
*	Use the 'filled rectangle' A-LINE for the big '7.1' in
*	bitplane 2 (if you number your bitplanes 1-4)
*
	lea	coords(pc),a6	drawing 4 rectangles
	moveq	#3,d6
rectang
	dc.w	$a000
	move.l	#$0000ffff,$18(a0)	bitplane 2
	clr.l	$1c(a0)
	move.l	(a6)+,$26(a0)	x1,y1
	move.l	(a6)+,$2a(a0)	x2,y2
	clr.w	$32(a0)		1 line of pattern
	lea	fillpat(pc),a1	which is a -1 word
	move.l	a1,$2e(a0)
	dc.w	$a005
	dbra	d6,rectang
*
*	Set relative priorities of screen layers
*
			
	move.w	#0,PAL_00.w	background black
	move.w	PAL_01.w,PAL_03.w	scroller over big '7.1'
	move.w	PAL_01.w,PAL_05.w	scroller over 'ST' fill
	move.w	#$0444,PAL_04.w	'ST' fill to white
*
*	Clear Blank Storage.
*
	lea	$70000,a5
	move.l	a5,a0
	move.l	#130*160,d0
clearit
	sf	(a0)+		smaller than move.b #0
	dbra	d0,clearit
*
*	Install myvbl. Just flags the fact that a vbl's happened.
*

	lea	shiftcnt(pc),a0
	move.l	$70.w,2(a0)
	lea	myvbl(pc),a1
	move.l	a1,$70.w
	lea	scrtxt(pc),a1

scrloop
	moveq	#1,d7		shift scroll 2 pixels
twoshift
	subq.b	#1,(a0)		need a new character ?
	bne.s	scrollon
	move.b	#63,(a0)
	tst.b	(a1)		end of text ?
	bpl.s	notend
	lea	scrtxt(pc),a1
notend
	moveq	#5,d2		6 lines high
	move.l	a5,a4
hiloop
	move.b	(a1)+,d1
	moveq	#7,d4		8 bytes wide/line of height
wiloop
	addx.b	d1,d1		shift bit to x
	scs	(a4)+		turn it into a 1/0 byte
	dbra	d4,wiloop
	dbra	d2,hiloop
scrollon
	lea	(8*8)+(40*8)(a5),a3	end of scroll buffer
	lea	6*8(a5),a4	end of shift buffer
	moveq	#5,d2		for each line of height:
rhshift
	lsl.w	-(a4)		shift the shift...
	roxl.w	-(a4)		buffer 1 bit left
	roxl.w	-(a4)
	roxl.w	-(a4)
	moveq	#19,d3		
linroxl
	roxl.w	-(a3)
	dbra	d3,linroxl	and then shift the scroll
	dbra	d2,rhshift	buffer 1 bit left
	dbra	d7,twoshift
*
*	Ok, buffer shifted. VSYNC and display.
*
vbsync
	tst.b	1(a0)
	beq.s	vbsync
	sf	1(a0)
		
	move.l	$44e.w,a2
	lea	160*70(a2),a2
	moveq	#5,d2
hilop2
	moveq	#19,d3
wilop2
	move.w	#160*20,d4
dlop2
	move.w	(a3),(a2,d4.w)
	sub.w	#160,d4
	bpl.s	dlop2
		
	addq	#8,a2
	addq	#2,a3
	dbra	d3,wilop2		
	lea	160*21(a2),a2
	dbra	d2,hilop2
*
*	Spacebar to exit.
*
	cmp.b	#$39,ACIAD.w
	bne	scrloop
	move.l	2(a0),$70.w	put back VBL
	move.w	#$0777,PAL_00.w 	important colour
	dc.w	$a009		restore mouse
	move.l	$44e.w,a0		clear the screen
	move.l	#32000/4,d0	for neatness
clearend
	clr.l	(a0)+
	dbra	d0,clearend
*
*	mono monitors come straight here...sorry!
*
monomon
	rts

*
*	VBL routine. Just flag it and out.
*
		even
myvbl
	move.l	a0,-(sp)
	lea	shiftcnt+1(pc),a0
	st	(a0)
	move.l	(sp)+,a0
	rte	
*
*	Be very careful not to move this stuff around!
*
	even
shiftcnt	dc.b	1		bits shifted (64=1 char)
myvbflag	dc.b	0		
	even
oldvbl	ds.l	1
	even
*
* The custom text characters for the scroller.
*
scrtxt
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01000000
		dc.b	%01111110				'S'
		dc.b	%00000110
		dc.b	%01111110

		dc.b	%01111110
		dc.b	%00011000
		dc.b	%00011000
		dc.b	%00011000				'T'
		dc.b	%00011000
		dc.b	%00011000

		dc.b	%00000000
		dc.b	%00000000
		dc.b	%00000000
		dc.b	%00000000				' '
		dc.b	%00000000
		dc.b	%00000000

		dc.b	%01100001
		dc.b	%01010001
		dc.b	%01001001				'N'
		dc.b	%01001001
		dc.b	%01000101
		dc.b	%01000011

		dc.b	%01111110
		dc.b	%01111110		
		dc.b	%01000000		
		dc.b	%01111110				'E'
		dc.b	%01000000		
		dc.b	%01111110
		
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01011010		
		dc.b	%01011010				'W'
		dc.b	%01100110		
		dc.b	%01100110		

		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01000000
		dc.b	%01111110				'S'
		dc.b	%00000110
		dc.b	%01111110


		dc.b	%00000000
		dc.b	%00000000
		dc.b	%00000000
		dc.b	%00000000				' '
		dc.b	%00000000
		dc.b	%00000000
*
* This end-of-text marker doubles as a fill pattern, so don't
* change it from word to byte!
*
fillpat		dc.w	-1
	even
*
* The 'ST' fill pattern.
*
filler2
		dc.w	%0111111001111110
		dc.w	%0100000000011000
		dc.w	%0100000000011000
		dc.w	%0111111000011000				'S'
		dc.w	%0000011000011000
		dc.w	%0111111000011000
		dc.w	%0000000000000000
*
* The co-ords of the rectangles for the big '7.1'
*
coords
	dc.w	30,0,150,40,120,30,150,199,170,180,190,199,210,0,240,199

		even
*******************************************************************
*
* the code to install the bootsector. Read current, modify and
* write back.
*******************************************************************	
doitall
	IFNE shortvers
*
* read the boot sector
*
	move.w	#1,-(sp)	number of sectors to read (1-9)
	move.w	#0,-(sp)	side number selected  (0-1)
	move.w	#0,-(sp)	track number (0-79)
	move.w	#1,-(sp)	sector number (0-9)
	move.w	#0,-(sp)	device: 0 for A etc..
	clr.l	-(sp)	filler  (unused)
	move.l	#boot_buff,-(sp) 512 bytes times sectors read
	move.w	#8,-(sp)
	trap	#14
	lea	20(sp),sp
*
* Copy the code from up there to the boot buffer just read.
*
	lea	boot_buff,a0	just read
	move.w	#$6038,(a0)	ie. BRA.S to the code
	add.l	#$3a,a0		first $3A bytes reserved
	lea	boot_code,a1	the new code
	move.w	#452,d7		452+$3A=510
movin	move.b	(a1)+,(a0)+	

	dbra	d7,movin
*
* It's been said a thousand times before, but just one more time...
* The system checksums the bootsector when it reads it. If that
* checksum doesn't equal $1234, it isn't executable. So, we use
* an O/S routine to modify the last two bytes of the buffer (510/511)
* so that the checksum DOES equal $1234. So, don't use the last two
* bytes for code!

	move.w	#1,-(sp)		executable
	move.w	#-1,-(sp)		disk type no change
	move.l	#-1,-(sp)		same serial number
	move.l	#boot_buff,-(sp)
	move.w	#18,-(sp)
	trap	#14
	lea	14(sp),sp
*
* So, read done, modify done, checksum done, so WRITE IT BACK!
*

	move.w	#1,-(sp)	1 sector to write
	move.w	#0,-(sp)	on side 0
	move.w	#0,-(sp)	track zero
	move.w	#1,-(sp)	sector 1 (not zero)
	move.w	#0,-(sp)	drive A
	clr.l	-(sp)
	move.l	#boot_buff,-(sp)
	move.w	#9,-(sp)
	trap	#14
	lea	20(sp),sp
nasty	bra.s	nasty		nasty ending	

boot_buff	ds.b	512

	ENDC
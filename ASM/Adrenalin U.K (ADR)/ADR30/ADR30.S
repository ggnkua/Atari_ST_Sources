*************************************************************************
*				ADR MENU				*
*				--------				*
*									*
* Coded by: SPACEMAN SPIFF						*
*									*
*									*
* Art by: BIOFEEDBACK							*
*									*
*									*
* Music by:								*
*									*
*									*
*************************************************************************

TBDR	equ	$fffffa21		;TimerB Data Register
TBCR	equ	$fffffa1b		;TimerB Control Register


	opt	o+,w-

YES	equ	1
yes	equ	YES
NO	equ	0
no	equ	NO




AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
DOWNLOAD	equ	NO

		ifne	DOWNLOAD
		include	sttx1.s
		org	$2000
Code_Start
Exec_Addr
		ENDC


		ifeq	DOWNLOAD

*******************************
	SECTION TEXT
*******************************



*~~~~~~~~~~~~~~~~~~~~~~~ HERE GOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset		;always reset on return from prog
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	ENDC
	endc

		bsr	clear_bss
		ifeq	DOWNLOAD
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_stack
		endc

		move.b	#$12,$fffffc02.w
		move.l	$44e.w,screen_base
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal
		move.b	$ffff8260.w,old_rez
		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	$ffff8260.w,old_rez
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		clr.b	$ffff8260.w
		bsr	print_titles
		bsr	set_up_stars
		bsr	set_up
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

*****
***** Section1 menu 6 music
***** Ripped by MSD/POV
*****
		moveq	#1,d0
		jsr	music

		bsr	start_interrupts

main_loop	bsr	set_screen
		bsr	vsync
;		move.w	#$123,$ffff8240.w
		bsr	scroll
		bsr	bounce_adr
		bsr	stars
;		move.w	pic+2,$ffff8240.w

		moveq	#0,d0
		move.b	$fffffc02.w,d0

		cmp.w	#1,d0			;escape?
		beq	exit			;yes get out...

		cmp.w	#$b,d0			;0 key
		beq	zero

		cmp.w	#$70,d0			;0 keypad
		beq	zero

check_keys	lea	key_codes,a5
.loop		cmp.w	#-1,(a5)	;end of table?
		beq.s	main_loop	;yes
		cmp.w	(a5)+,d0	;is key one we want?
		beq.s	load		;yes so load demo
		move.w	(a5)+,d6	;NO so get offset
		bra.s	.loop		;check another key code

load		move.w	(a5),d0
		and.l	#$f,d0
		lea	filename_table,a0
		lsl.w	#2,d0		;multiply D0 by 4 (one long word)
		add.w	d0,a0
		move.l	(a0),a1		;get filename address

*** now move filename into $200 for AUTORUN4 to find
		lea	$200.w,a0
		movem.l	(a1),d0/d1/d2/d3	;move 16 bytes
		movem.l	d0-d3,(a0)		;into $200

		bsr	vsync

		move.w	#$2700,sr
		jsr	music+4
		move.l	old_120,$120.w
		move.l	old_70,$70.w
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w

		lea	$ffff8800,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	old_rez,$ffff8260.w
		move.b	#$8,$fffffc02.w
		move.w	#$2300,sr

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

*** now check hertz and exit cleanly...
		tst.w	hertz_switch		;has hertz been pressed?
		beq.s	.hz50			;no so it stays in 50Hz
		eor.b	#2,$ffff820a.w		;yes so go 60Hz
.hz50		move.b	#8,$fffffc02.w		;mouse back on

		ifeq	DOWNLOAD
		move.l	old_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		endc

		ifeq	DOWNLOAD
		ifeq	AUTORUN4
		bra	exec
		ELSEIF
		clr.w	-(sp)		;exit to desktop
		trap	#1
		ENDC
		endc

zero		tst.w	zero_counter
		bne	check_keys
		eor.w	#$102,pic+2		;show a hertz change
		eor.w	#$ffff,hertz_switch	;toggle a check
		move.w	#10,zero_counter	;delay in between hertz switches
		bra	main_loop

exit		bsr	vsync

		move.w	#$2700,sr
		jsr	music+4
		move.l	old_120,$120.w
		move.l	old_70,$70.w
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w

		lea	$ffff8800,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	old_rez,$ffff8260.w
		move.b	#$8,$fffffc02.w
		move.w	#$2300,sr

		move.l	screen_base,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		ifeq	DOWNLOAD
		move.l	old_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		elseif
		move.l	4.w,a0
		jmp	(a0)
		endc

		clr.w	-(sp)
		trap	#1

*********************** Subroutines *************************************


DEPTH	equ	32

scroll	move.l	scr_now,a1
	lea	160*84(a1),a1
	lea	font_offsets,a2		;font lookup table
	lea	font,a3			;font itself
	move.l	scroll_pointer,a4	;pointer into text
	move.l	a4,a5

	moveq	#40,d5			;40 words across screen
	move.w	char_offset,d6		;char offset is a toggle
					;for bytes/words
	moveq	#0,d4
next_char
	move.b	(a5),d7			;get a letter
	sub.b	#32,d7			;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0	;find correct offset
	mulu	#8*DEPTH,d0	;8 bytes wide * DEPTH
	add.w	d0,a0		;add to font start
	move.w	d6,d0		;char offset
	lsl.w	#5,d0		;*DEPTH
	add.w	d0,a0		;we now point to character in A0

.column
OFF	set	0
	REPT	DEPTH
	move.b	(a0)+,d3
	move.b	d3,OFF(a1)
OFF	set	OFF+1*160		;go down a line
	ENDR

	subq.w	#1,d5		;column value
	beq.s	.finish		;last column then finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next byte
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#7,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#7,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)		;is scroll text end?
	bpl.s	.end		;NO!
	lea	scroll_text,a4	;reset scroll text
.end	move.l	a4,scroll_pointer
	rts







DISTANCE_BETWEEN_BOBS	equ	14
BOB_DEPTH		equ	18

bounce_adr	lea	last_pos_tab,a4
		moveq	#0,d4

		move.l	scr_last,a3
		lea	8(a3),a3
		move.l	a3,a5


		move.w	#9-1,d2		;ADR bobs
.cloop		move.l	a5,a3
		move.w	(a4)+,d1
		add.w	d1,a3

OFF_CLEAR	set	0
		rept	BOB_DEPTH
		move.w	d4,OFF_CLEAR(a3)
		move.w	d4,OFF_CLEAR+8(a3)
OFF_CLEAR	set	OFF_CLEAR+160
		endr
		add.w	#16,a5
		add.w	#2,d3
		dbf	d2,.cloop

		lea	last_pos_tab,a4
		lea	sine_table,a6	;start of sine table
		lea	adr,a0		;ADRENALIN graphics
		move.w	sine_offset,d7	;offset into sine table
		move.w	d7,d6		;stash this
		and.w	#1023,d6	;make from 0-1023
		move.w	0(a6,d6.w),d5	;get screen offset from sine table
		move.w	d5,(a4)+	;save present pos in sine tab for clearing
		move.l	scr_now,a1
		lea	8(a1),a1
		move.l	a1,a5
		add.w	d5,a1

		move.w	#9-1,d0		;ADRENALIN=9 letters long
.loop

LINE_OFFSET	set	0
		rept	BOB_DEPTH
		move.w	(a0)+,LINE_OFFSET(a1)
		move.w	(a0)+,LINE_OFFSET+8(a1)
LINE_OFFSET	set	LINE_OFFSET+160
		endr

		add.w	#16,a5		;2 words across screen for nxt letter
		move.l	a5,a1
		sub.w	#DISTANCE_BETWEEN_BOBS,d7
		move.w	d7,d6
		and.w	#1023,d6
		moveq	#0,d2
		move.w	0(a6,d6.w),d5
		move.w	d5,(a4)+	;save present pos in sine tab for clearing
		add.l	d5,a1

		dbf	d0,.loop
		add.w	#2,sine_offset	;increase pointer within bob sine tab

		rts





***************************************
*				      *
* Nice random number routine by Boris *
*				      *
***************************************

random
	move.l	seed,d0
	mulu	#$1afb,d0
	add.l	#$1fccd,d0
	move.l	d0,seed
	rts

seed	dc.l	53

***************************************

;;;; this code was written to cope with 1 star per line in this case
;;;; I have made the stars area 78 lines long if you try to print more
;;;; it will screw up (you have been warned!!!)
NO_STARS	equ	77	(0-77=78)
stars
	move.l	scr_now,a4
	move.l	scr_last,a2
	moveq	#0,d7		; Now used for fast clearing star.
	lea	star_table,a0
	move.w	#NO_STARS-1,d6	;number of stars
.loop	bsr	do_stars
	addq.w	#8,a0
	dbf	d6,.loop
	rts

do_stars
	move.w	2(a0),d0	;word offset
	moveq	#0,d1		; Make sure high word is clear for later.
	move.w	4(a0),d1	;bit offset
	move.l	a2,a1

	add.w	(a0),a1		; Line offset.
	add.w	d0,a1		;add word offset

	move.l	a4,a3
	add.w	(a0),a3		; Line offset.
	add.w	d0,a3		;add word offset
	move.w	d7,2(a3)	; Faster clear old star.

;calc new pos
	move.w	6(a0),d2	;speed of shift
	ror.l	d2,d1		; 'Dot' might be shifted into
				; high word so not lost!
	tst.w	d1		; 'Dot' shifted into next column?
	bne.s	no_word		; No!
	swap	d1		; Yes, get back new 'dot' value.

;word overlap so add to next word
	addq.w	#8,d0		;goto next word
	cmp.w	#160,d0		;is word over screen width?
	blt.s	.no		;NO!!
	move.w	d7,2(a0)	; Clear word offset.
	move.w	d1,4(a0)	;save star shift for next VBL
	rts

.no	move.w	d0,2(a0)
	move.w	d1,2+8(a1)
	move.w	d1,4(a0)	;save star shift for next VBL
	rts

no_word	move.w	d1,2(a1)
	move.w	d1,4(a0)
	rts





set_up_stars
	clr.w	d5
	lea	star_table,a6
	move.w	#NO_STARS-1,d7		;number of stars
.loop
	move.w	d5,(a6)+	; Store line offset.
	add.w	#(160*(78/NO_STARS)),d5	; Next line offset.

;now get a RANDOM number for shifts,speed and line offset
	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp
	and.l	#$7fff,d0

	divu	#160,d0
	swap	d0		; Get number within width of screen.
	and.w	#$f8,d0	; Place on column boundary.
	move.w	d0,(a6)+	;word offset

	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp

	and.w	#15,d0
	move.w	#$8000,d1
	ror.w	d0,d1
	move.w	d1,(a6)+	;pixel shift

	move.w	#$11,-(sp)
	trap	#14
	addq.w	#2,sp

	and.w	#7,d0
	addq.w	#1,d0		; Make sure not stopped!
	move.w	d0,(a6)+	;speed

	dbf	d7,.loop
	rts







*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.2 - now supports 6*6 font				*
* Date:		20/10/92						*
* By:		MSD 							*
*									*
* More comments added to allow others to understand			*
*									*
*************************************************************************
*
* Now is fully masking to give black line around letters.
*
* Here is a little option to allow you to print the titles in any colour
* simply enable the planes you require..
*
* If you disable them all the titles will be colour 0


ENABLE_PLANE1	equ	NO
ENABLE_PLANE2	equ	YES
ENABLE_PLANE3	equ	NO
ENABLE_PLANE4	equ	NO

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*100,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

		move.w	#16-1,d0	;max titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#6,d1		;chars are 12 bytes each

BYTE_OFF	set	0
LINE_OFF	set	0

		REPT	6
		move.b	BYTE_OFF(a2,d1.w),d5	;get char
		move.b	BYTE_OFF(a3,d1.w),d3	;get char mask

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ELSE	
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d3,d4			;and mask with scrn data
		or.b	d5,d4			;or char data into mask
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d3,d4			;use same mask calculated previously
		or.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ENDC
		ENDC


BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR


BYTE_OFF	set	0
LINE_OFF	set	0
		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII

		mulu	#6,d1		;chars are 6 bytes each

		REPT	6
		move.b	BYTE_OFF(a2,d1.w),d5
		move.b	BYTE_OFF(a3,d1.w),d3

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ELSE
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ENDC
		ENDC

BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR

		lea	8(a0),a0
		dbf	d6,.loop2
		lea	160*6(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts










set_up		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		move.w	#160*150,d0		;set up initial bounce clear
		lea	last_pos_tab,a1
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
sho		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,sho

set_screen	move.l	scr_now,d6
		move.l	d6,scr_last
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts



vsync		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		rts

clear_bss	lea	bss_start,a0
.clear		clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	.clear
		rts


****************************** interrupts *******************************

new_vbl		clr.b	TBCR.w
		move.l	#timerb,$120.w
		move.b	#1,TBDR.w
		move.l	#rasters+2,raster_pos
		move.w	rasters,$ffff8242.w
		move.w	#77,raster_offset
		move.w	rasters,raster_
		move.l	#lower_colours,lower_pos
		move.b	#8,TBCR.w

		clr.w	vsync_flag
		movem.l	d0-a6,-(sp)
		bsr	music+8
		movem.l	(sp)+,d0-a6
		rte

timerb		clr.b	TBCR.w
		move.w	#0,$ffff8242.w
raster_		equ	*-4
		tst.w	raster_offset
		bne.s	.no_reset
		move.w	pic+4,$ffff8242.w
		move.b	#4,TBDR.w
		move.l	#timerb_part2_set,$120.w
		move.b	#8,TBCR.w
		rte

.no_reset	movem.l	d0/a0,-(sp)
		move.l	raster_pos,a0
		move.w	(a0)+,raster_
		move.l	a0,raster_pos
		sub.w	#1,raster_offset
		movem.l	(sp)+,d0/a0
		move.b	#8,TBCR.w
		rte

timerb_part2_set
		clr.b	TBCR.w
		move.l	#timerb_part2,$120.w
		move.b	#2,TBDR.w
		move.l	#scroller_rasters,raster_pos
		move.w	#17,raster_offset
		move.b	#8,TBCR.w
		rte
timerb_part2	clr.b	TBCR.w
		move.l	a0,-(sp)
		move.l	raster_pos,a0
		move.w	(a0)+,$ffff8242.w
		move.l	a0,raster_pos
		move.l	(sp)+,a0
		sub.w	#1,raster_offset
		beq.s	.set_timerb3
		move.b	#8,TBCR.w
		rte
.set_timerb3	move.l	#timerb_part3,$120.w
		move.b	#1,TBDR.w
		move.b	#8,TBCR.w
		rte
timerb_part3	move.l	a0,-(sp)
		move.l	lower_pos,a0
		move.l	rasters-lower_colours-4(a0),$ffff8244.w
		move.l	rasters-lower_colours-4(a0),$ffff8244+16.w
		move.w	(a0),$ffff8242.w
		move.w	(a0)+,$ffff8242+16.w
		move.l	a0,lower_pos
		move.l	(sp)+,a0
		rte

		
start_interrupts
		move.w	#$2700,sr
		move.l	$70.w,old_70
		move.l	$120.w,old_120
		move.b	$fffffa07.w,olda07
		move.b	$fffffa09.w,olda09
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w
		move.l	#new_vbl,$70.w
		move.l	#timerb,$120.w
		or.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		clr.b	$fffffa09.w
		bclr	#3,$fffffa17.w		;enable auto A-INTERRUPT IN SERVICE clear
		move.w	#$2300,sr
		rts


	ifeq	DOWNLOAD
*******************************
	SECTION DATA
*******************************
	endc

pic	incbin	pic.pi1

music	incbin	section1.mus

raster_offset	dc.w	0
raster_pos	dc.l	rasters
rasters	dc.w	$200,$a00,$300,$b00,$400,$c00,$500,$d00
	dc.w	$600,$e00,$700,$f00,$f80,$f10,$f90,$f20
	dc.w	$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60
	dc.w	$fe0,$f70,$ff0,$7f8,$ef1,$6f9,$df2,$5fa
	dc.w	$cf3,$4fb,$bf4,$3fc,$af5,$2fd,$9f6,$1fe
	dc.w	$8f7,$0ff,$07f,$0ef,$06f,$0df,$05f,$0cf
	dc.w	$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f
	dc.w	$00f,$80f,$10f,$90f,$20f,$a0f,$30f,$b0f
	dc.w	$40f,$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f
	dc.w	$f07,$f0e,$f06,$f0d,$f05

scroller_rasters
	dc.w	$001,$012,$023,$034,$045,$056,$067,$0ff
	dc.w	$0ff,$067,$056,$045,$034,$023,$012,$001

lower_pos	dc.l	lower_colours
lower_colours
 dc.w	$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$80f
 dc.w	$10f,$90f,$20f,$a0f,$30f,$b0f,$40f,$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07,$f0e
 dc.w	$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03,$f0a,$f02,$f09,$f01,$f08,$f00,$f80,$f10,$f90
 dc.w	$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$f70,$ff0,$770,$ee0,$660,$dd0
 dc.w	$550,$cc0,$448,$bb1,$339,$2a2,$a2a,$393,$b1b,$484,$c0c,$505,$d0d,$606,$e0e,$707
 dc.w	$717,$727,$737



scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "           ADRENALIN COMPACT DISK 30.   "
 DC.B "CREDITS FOR THIS DISK ARE AS FOLLOWS....   CODING BY   SPACEMAN SPIFF, "
 DC.B "   GRAFIX BY  BIOFEEDBACK,   MUSIC BY   ?? OF THK, "
 dc.b "      GREETINGS TO    "
 DC.B "ANIMAL MINE,     "
 DC.B "ADMIRABLES,     "
 DC.B "ANTHRAX,     "
 DC.B "BREAKPOINT SOFTWARE,     "
 DC.B "CYNIX,     "
 DC.B "CRACKDOWN (ESP. INSPIRAL),     "
 DC.B "CHRIS H (YORK),     "
 DC.B "CHRIS H (MID GLAM),     "
 DC.B "CHRIS H (STAFFS),     "
 DC.B "D-BUG,     "
 DC.B "ELITE,     "
 DC.B "THE EDGE,     "
 DC.B "(E) TRIPPER,     "
 DC.B "FUZION,     "
 DC.B "HOTLINE (ESP. SIDEWINDER),     "
 DC.B "KGB,      "
 DC.B "MAD VISION,     "
 DC.B "MUG U.K.,     "
 DC.B "MICRO MANIAC,     "
 DC.B "PERSISTENCE OF VISION (ESP. MAC SYS DATA AND BORIS),     "
 DC.B "POMPEY PIRATES,     "
 DC.B "PULSION,     "
 DC.B "PURE ENERGY,     "
 DC.B "REPLICANTS,     "
 DC.B "RIPPED OFF (ESP. STICK AND BILBO),     "
 DC.B "RED LICHTIE,     "
 DC.B "SYNDICATE,     "
 DC.B "SUPERIOR,     "
 DC.B "SPECIAL FX,     "
 DC.B "SAFARI (ESP. PANTHER AND RHINO),     "
 DC.B "SCANZ,     "
 DC.B "SONIC,     "
 DC.B "TIM,     "
 DC.B "UNTOUCHABLES (ESP. MAT)   AND   "
 DC.B "WILD! (ESP. SNAZ)     "
 DC.B "                          "
 DC.B "                          "
 dc.b $ff
	even



font	dcb.b	DEPTH*8,0
 dc.l	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 dc.l	$7FFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFEFEFE,-1,-1,$FFFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	-1,-1,$FF000000,-1,-1,$FF000000,0,0
 DC.L	-1,-1,$FF000000,-1,-1,$FF000000,0,0
 DC.L	-1,-1,$FF7F7F7F,-1,-1,$FF7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	$FEFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFF8F8FF,-1,-1,$F8F8FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FF0000FF,-1,-1,$0000FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FF0000FF,-1,-1,$0000FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FF1F1FFF,-1,-1,$1F1FFFFF,-1,$FFFFFF00
 DC.L	$FEFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFE00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$F8F8E0E0,$F8F8FEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	$7FFFFFFF,-1,-1,-1,-1,-1,-1,$FFFF7F00
 DC.L	-1,-1,$FFFFFFFE,$FEFEFEFE,$FEFEFEFE,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF8000,0,0,$80FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFE0000,0,0,$00FEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFEFE,$FEFEFEFE,$FEFEFEFE,$FEFFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0100,0,0,$01FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFF7F,$7F7F7F7F,$7F7F7F7F,-1,-1,$FFFFFF00
 DC.L	$FEFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFE00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	$7FFFFFFF,-1,-1,-1,-1,-1,-1,$FFFF7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF80FF,-1,-1,$80FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00F8,$F8F8F8F8,$F8F8F8F8,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFE0000,0,0,$00FEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,0,0,0,-1,-1,$FFFF00FF,-1,-1,0,0,0
 DC.L	-1,-1,$FFFF00F0,$F0F0F0F0,$F0F0F0F0,0,0,0
 DC.L	-1,-1,$FFFF0000,0,0,0,0,0
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFC0000,0,0,0,0,0
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,$FFFFFF3F,$3F0F0000
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFFFC,$FCFCFCFC,$FCFCFCFC,$FCFFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$00FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFC0000,$F0FCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFC00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFCFCFF,-1,-1,$FFFCFCFC,$FCFCFCFC,$FCFCFC00
 DC.L	0,0,$000000FF,-1,-1,$FF000000,0,0
 DC.L	0,0,$000000FF,-1,-1,$FF000000,0,0
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7FFF,-1,-1,$FF7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	0,0,0,0,0,0,0,0
 DC.L	$01010101,$01010101,$01000000,0,0,$00000101,$01010101,$01010100
 DC.L	-1,-1,$FF070707,$07070707,$07070707,$0707FFFF,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFF8F8F8,$F8F8F8F8,$F8F8F8F8,$F8F8FFFF,-1,$FFFFFF00
 DC.L	$E0E0E0E0,$E0E0E0E0,$E0000000,0,0,$0000E0E0,$E0E0E0E0,$E0E0E000
 DC.L	0,0,0,0,0,0,0,0
 DC.L	0,0,0,$00007F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	0,0,0,$0000FFFF,-1,-1,-1,$FFFF7F00
 DC.L	0,0,0,$0000FEFE,$FEFEFEFE,-1,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$80FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$01FFFFFF,-1,$FFFFFF00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFE00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,-1,$FFFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	0,0,$01071F7F,-1,$FF7F1F07,$01000000,0,0
 DC.L	0,$01071F7F,-1,-1,-1,$FF7F1F07,$01000000,0
 DC.L	$01071F7F,-1,-1,$FFFEF8FE,-1,-1,$FF7F1F07,$01000000
 DC.L	-1,-1,$FFFEF8E0,$80000000,$80E0F8FE,-1,-1,$FF7F1F00
 DC.L	$F8FEFEFE,$FEFEF8E0,$80000000,0,0,$80E0F8FE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$00FEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$80E0F8FE,-1,-1,-1,$FFFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	0,$80E0F8FE,-1,-1,$FF7F1F07,$01000000,0,0
 DC.L	0,$01071F7F,-1,-1,$FFFEF8E0,$80000000,0,0
 DC.L	$01071F7F,-1,-1,-1,$FF7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$E0F8F8FE,-1,-1,-1,$FFFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	0,$80E0F8FE,-1,-1,$FF7F1F07,$01000000,0,0
 DC.L	0,0,$80E0F8FE,-1,-1,$FF7F1F07,$01000000,0
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,-1,-1,-1,$FF7F1F07,$01000000
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FF7F1F00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	$7FFFFFFF,-1,-1,-1,-1,-1,-1,$FFFF7F00
 DC.L	-1,-1,$FFFFFFFE,$FEFEFEFE,$FEFEFEFE,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF8000,0,0,$80FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0100,0,0,$01FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFF7F,$7F7F7F7F,$7F7F7F7F,-1,-1,$FFFFFF00
 DC.L	$FEFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFE00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFCFCFC,-1,-1,$FFFCFCFC,$FCFCFCFC,$FCFCFC00
 DC.L	-1,-1,$FF000000,-1,-1,$FF000000,0,0
 DC.L	-1,-1,$FF000000,-1,-1,$FF000000,0,0
 DC.L	-1,-1,-1,-1,-1,$FF000000,0,0
 DC.L	$FCFFFFFF,-1,-1,-1,-1,$FC000000,0,0
 DC.L	$00C0F0F0,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCF0F0C0,0,0,0
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,$FFFFFF3F,$3F0F0000
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFFFFFC,$FCFCFCFC,$FCFCFCFC,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0000,0,0,$00F3FCFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF0300,0,$00030F3F,$FFFFFF3F,$CFF3FCFF,$FFFFFF00
 DC.L	-1,-1,-1,-1,$3FCFF3FC,-1,$FFFFFF3F,$CFF3FC00
 DC.L	$FCFFFFFF,-1,-1,-1,-1,$3FCFF3FC,-1,$FFFCF000
 DC.L	$00C0F0F0,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$3CCCF0C0,0
 DC.L	$000F3F3F,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFCFCFC,-1,-1,$FFFCFCFC,$FCFCFCFC,$FCFCFC00
 DC.L	-1,-1,$FF000000,-1,-1,$FF3F0F03,0,0
 DC.L	-1,-1,$FF000000,-1,-1,-1,$7F1F0701,0
 DC.L	-1,-1,$FF7F7F7F,-1,-1,-1,-1,$7F1F0700
 DC.L	$FEFFFFFF,-1,-1,-1,-1,$FEE0F8FE,-1,$FFFFFF00
 DC.L	$00E0F8F8,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEF8F8E0,0,$80E0F8FE,$FEFEFE00
 DC.L	$00071F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F1F1F07,$00007F7F,$7F7F7F7F,$7F7F7F00
 DC.L	$7FFFFFFF,-1,-1,-1,-1,$0000FFFF,-1,$FFFFFF00
 dc.l	-1,-1,-1,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF80FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$7F7FFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FE,-1,-1,-1,-1,$FFFFFE00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFE0000,$E0F8F8FE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F0000,0,0,0,0,0,-1,-1,$FFFF0000,0
 DC.L	0,0,0,0,-1,-1,$FFFF0707,$7070707,$7070707,$7070707
 DC.L	$7070707,$7070700,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,-1,-1,$FFFFF8F8,$F8F8F8F8,$F8F8F8F8,$F8F8F8F8
 DC.L	$F8F8F8F8,$F8F8F800,-1,-1,$FFFF0000,0,0,0,0,0
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFE0000,0,0,0,0,0,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000,-1,-1,-1,-1
 DC.L	-1,-1,-1,$FFFF7F00,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE
 DC.L	$FEFEFEFE,-1,-1,$FFFFFF00,0,0,0,0,0,$80FFFFFF
 DC.L	-1,$FFFFFF00,0,0,0,0,0,$1FFFFFF,-1,$FFFFFF00,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,-1,-1,$FFFFFF00,-1,-1
 DC.L	-1,-1,-1,-1,-1,$FFFFFE00,$FEFEFEFE,$FEFEFEFE
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F7F7F7F,$7F7F7F7F,$1F070100,0,0,0,-1,-1,-1,-1
 DC.L	$FFFFFF7F,$1F070100,0,0,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,-1,$FFFFFF7F
 DC.L	$1F070100,0,0,0,0,0,$80E0F8FE,-1,$FFFFFF7F,$1F070100,0,0,0,0
 DC.L	$1071F7F,-1,$FFFFFFFE,$F8E08000,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
 DC.L	-1,$FFFFFFFE,$F8E08000,0,-1,-1,-1,-1
 DC.L	$FFFFFFFE,$F8E08000,0,0,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$F8E08000,0
 DC.L	0,0,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFF,-1,-1,$FFFFFFFE,$F8E08000
 DC.L	0,0,1,$71F7FFF,-1,-1,$F8E08000,0,0,0,$80,$E0F8FEFF
 dc.L	-1,-1,$1F070100,0,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7FFF
 DC.L	-1,-1,$FFFFFF7F,$7F7F7F00,-1,-1,-1,-1
 DC.L	-1,-1,-1,$FFFFFF00,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE
 DC.L	$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$FEFEFE00,$7F7F7F7F,$7F1F0701,0,0
 DC.L	0,$1071F7F,$7F7F7F7F,$7F7F1F00,-1,-1,$7F1F0701,0
 DC.L	$1071F7F,-1,-1,$FEF8E000,$E0F8FEFF,-1,-1,$7F1F1F7F
 DC.L	-1,-1,$FEF8E080,0,$80,$E0F8FEFF,-1,-1
 DC.L	-1,$FEF8E080,0,0,0,$1071FFF,-1,-1,-1,$7F1F0701
 DC.L	0,0,$1071F7F,-1,-1,$FFFEF8FE,-1,-1
 DC.L	$7F1F0701,0,-1,-1,$FFFEF8E0,$80000000,$80E0F8FE,-1
 DC.L	-1,$7F1F0700,$FEFEFEFE,$FEFEF8E0,$80000000,0,0,$80E0F8FE
 DC.L	$FEFEFEFE,$FEFEF800,$7F7F7F7F,$7F1F0701,0,0,0,0,0,0
 DC.L	-1,-1,$7F1F0701,0,0,0,0,0,$E0F8FEFF,-1
 DC.L	-1,$7F1F0707,$7070707,$7070707,$7070707,$7070700,$80,$E0F8FEFF
 DC.L	-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	0,$1071FFF,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$1071F7F,-1,-1,$FFFEF8F8,$F8F8F8F8,$F8F8F8F8,$F8F8F8F8,$F8F8F800
 DC.L	-1,-1,$FFFEF8E0,$80000000,0,0,0,0,$FEFEFEFE,$FEFEF8E0
 DC.L	$80000000,0,0,0,0,0,-1,-1,$FF000000,0,0,$30F
 DC.L	$3FFFFFFF,$FFFFFF00,-1,-1,$FF000000,0,$30F,$3FFFFFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FF000000,$30F,$3FFFFFFF,-1
 DC.L	-1,$FFFFFF00,-1,-1,$FF00030F,$3FFFFFFF,-1,-1
 DC.L	-1,$FFFFFF00,-1,-1,-1,-1,$FFFFFFFC,$F0C0FFFF
 DC.L	-1,$FFFFFF00,-1,-1,-1,$FFFFFFFC,$F0C00000,$FFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FFFFFFFC,$F0C00000,0,$FFFF
 DC.L	-1,$FFFFFF00,$FCFCFCFC,$FCFCFCFC,$F0C00000,0,0,$FCFC
 DC.L	$FCFCFCFC,$FCFCFC00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,$10101,$1010007,$7070700,0,0,0,0,0,$FFFFFF,$FFFF1FFF,$FFFFFF00
 DC.L	0,0,0,0,0,$FFFFFF,-1,$FFFE8000,0,0,0,0,0,$E0E0E0,$E0E0E0E0,$E0000000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,0,$10101,$1010101,$1010100,0,0,0,0,0,$FFFFFF,-1,$FFFFFF00
 DC.L	0,0,0,0,0,$FFFFFF,-1,$FFFFFF00,0,0,0,0,0,$E0E0E0,$E0E0E0E0,$E0E0E000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	$1F1F1F,$1F1F1F1F,$1F000000,$707,$7070700,$1F1F1F1F,0,0,$FFFFFF,-1
 DC.L	$FF000000,$FFFF,$FFFFFF7F,$FFFFFFFE,0,0,$FFFFFF,-1,$FF000000,$FFFF
 DC.L	-1,$FFFFF800,0,0,$808080,$80808080,$80000000,$8080,$80808080,$80800000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	$1F1F1F,$1F1F1F1F,$1F000000,$1F1F,$1F1F1F1F,$1F1F0000,0,0,$FFFFFF,-1
 DC.L	$FF000000,$FFFF,-1,$FFFF0000,0,0,$FFFFFF,-1,$FF000000,$FFFF
 DC.L	-1,$FFFF0000,0,0,$E0E0E0,$E0E0E0E0,$E0000000,$E0E0,$E0E0E0E0,$E0E00000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


 DC.L	$F3F3F,-1,-1,-1,-1,-1,$FFFFFF3F,$3F0F0000,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,-1,-1,$FFFFFFFC,$FCFCFFFF,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF030F,$3FFFFFFF,-1,-1,-1,$FFFFFF00,-1,-1,-1,-1
 DC.L	$FFFFFFFC,$F3FFFFFF,-1,$FFFFFF00,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,$FCFFFFFF,-1,-1,-1,-1,-1,-1,$FFFFFC00
 DC.L	$C0F0F0,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCF0,$F0C00000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	$30F3F,-1,-1,$3030303,$3030303,$303FFFF,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00,-1,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFF00,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFFFF,-1,$FFFFFF00,0,0,0,0,0,$F0F0
 DC.L	$F0F0F0F0,$F0F0F000,0,0,0,0,0,0,0,0,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F7F0000,$71F1F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000
 DC.L	-1,-1,$FFFF007F,-1,-1,-1,-1,$FFFF7F00,-1,-1,$FFFF00FF,-1
 DC.L	-1,$FEFEFFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF1FFF,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1,-1,-1
 DC.L	$FFFFFFFE,$FFFF,-1,$FFFFFF00,$80F8FEFE,$FEFEFEFE
 DC.L	$FEFEFEFE,$FEFEFEFE,$F8F8E000,$FEFE,$FEFEFEFE,$FEFEFE00
 DC.L	$3F3F3F3F,$3F3F3F3F,$3F3F0000,0,0,$3F3F3F,$3F3F3F3F,$3F3F3F00
 DC.L	-1,-1,$FFFF0000,0,0,$FFFFFF,-1,$FFFFFF00,-1,-1
 DC.L	$FFFF000F,$F0F0F0F,$F0F0F0F,$FFFFFF,-1,$FFFFFF00,-1,-1
 DC.L	$FFFF00FF,-1,-1,$FFFFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1
 DC.L	-1,$FFFFFF,-1,$FFFFFF00,-1,-1,$FFFF0FFF,-1,-1,$FFFFFFF
 DC.L	-1,$FFFFFF00,-1,-1,-1,-1,-1,-1,-1,$FFFFFF00,$F0FCFCFC,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCF00000
 DC.L	0,0,$30F3F3F,$3F3F3F3F,$3F3F3F3F,$3F000000,0,0,0,$30F3FFF
 DC.L	-1,-1,-1,$FF000000,0,0,$30F3FFF,-1,-1,-1,-1,$FF000000
 DC.L	0,0,-1,-1,$FFFCF0FF,-1,-1,$FF000000,0,0,-1,-1,$FF,-1
 DC.L	-1,$FF000000,0,0,-1,-1,$3F3F3FFF,-1,-1,$FF3F3F3F
 DC.L	$3F3F3F3F,$3F3F3F00,-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00,-1,-1,-1,-1,-1,$FFFF
 DC.L	-1,$FFFFFF00,-1,-1,-1,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1
 DC.L	-1,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$3F3FFFFF,-1,$FFFFFF00,-1,-1
 DC.L	$FFFF00FC,-1,-1,-1,-1,$FFFFFC00,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFC0000,$C0F0F0FC,$FCFCFCFC,$FCFCFCFC,$FCFCFCF0,$F0C00000
 DC.L	$F3F3F,-1,-1,-1,-1,-1,$FFFFFF3F,$3F0F0000,-1,-1,-1,-1
 DC.L	-1,-1,-1,$FFFFFF00,-1,-1,-1,-1,-1,$FCFCFFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FFFF00FF,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1
 DC.L	-1,$FFFF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$3F3FFFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FFFF00FC,-1,-1,-1,-1,$FFFFFC00
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFC0000,$C0F0F0FC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCF0,$F0C00000,$7F7F7F7F,$7F7F7F7F,$7F000000,0
 DC.L	0,$107,$1F7F7F7F,$7F7F7F00,-1,-1,$FF000000,0
 DC.L	$107,$1F7FFFFF,-1,$FFFFFF00,-1,-1,$FF000000,$107
 DC.L	$1F7FFFFF,-1,$FFFFFFFE,$F8E08000,-1,-1,$FF000107,$1F7FFFFF
 DC.L	-1,$FFFFFFFE,$F8E08000,0,-1,-1,$FF7FFFFF,-1
 DC.L	$FFFFFFFE,$F8E08000,0,0,-1,-1,-1,$FFFFFFFE,$F8E08000,0
 DC.L	0,0,-1,-1,$FFFFFFFE,$F8E08000,0,0,0,0,$FEFEFEFE,$FEFEFEFE
 DC.L	$F8E08000,0,0,0,0,0,$71F1F,$7F7F7F7F,$7F7F7F7F,$1F1F0707
 DC.L	$1F1F7F7F,$7F7F7F7F,$7F7F7F1F,$1F070000,$7FFFFFFF,-1
 DC.L	-1,-1,-1,-1,-1,$FFFF7F00,-1,-1,$FFFEFEFF,-1,-1,$FEFEFFFF
 DC.L	-1,$FFFFFF00,-1,-1,$FF0000FF,-1,-1,$FFFF,-1,$FFFFFF00
 DC.L	-1,-1,$FF0000FF,-1,-1,$FFFF,-1,$FFFFFF00,-1,-1
 DC.L	$FF1F1FFF,-1,-1,$1F1FFFFF,-1,$FFFFFF00,$FEFFFFFF,-1
 DC.L	-1,-1,-1,-1,-1,$FFFFFE00,$E0F8F8,$FEFEFEFE,$FEFEFEFE,$F8F8E0E0
 DC.L	$F8F8FEFE,$FEFEFEFE,$FEFEFEF8,$F8E00000,$71F1F,$7F7F7F7F
 DC.L	$7F7F7F7F,$7F7F7F7F,$7F1F1F07,0,0,0,$7FFFFFFF,-1,-1,-1
 DC.L	-1,$7F000000,0,0,-1,-1,$FFFEFEFF,-1,-1,$FF000000,0,0
 DC.L	-1,-1,$FF0000FF,-1,-1,$FF000000,0,0,-1,-1,$FF0000FF,-1
 DC.L	-1,$FF000000,0,0,-1,-1,$FF0F0FFF,-1,-1,$FF3F3F3F
 DC.L	$3F3F3F3F,$3F3F3F00,-1,-1,-1,-1,-1,-1,-1,$FFFFFF00
 DC.L	$F0FCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFC00,0,0,0,0,0,0,0,0,0,$3030303
 DC.L	$3030303,$3030303,$3030303,$3030303,$3030300,0
 DC.L	$33FFFFF,-1,-1,-1,-1,-1,-1,$FF3F0300,-1,-1,-1,-1
 DC.L	-1,-1,-1,$FFFFFF00,-1,-1,$FFFFFCF0,$F0F0F0F0,$F0F0F0F0,$FCFFFFFF
 DC.L	-1,$FFFFFF00,$FCFCFCFC,$FCFCFCFC,$FCFC0000,0,0,$FCFCFC
 DC.L	$FCFCFCFC,$FCFCFC00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,0,0,0,0,$3030303,$3030303,$3030000,0,0,$30303
 DC.L	$3030303,$3030300,-1,-1,$FFFF0300,0,0,$3FFFFFF,-1,$FFFFFF00
 DC.L	-1,-1,-1,-1,-1,-1,-1,$FFFFFF00,$FCFFFFFF,-1,-1,-1,-1,-1
 DC.L	-1,$FFFFFC00,$C0F0F0,$FCFCFCFC,$FCFCFCFC,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFCFC,$FCFCFCF0,$F0C00000,0,0,0,0,0,0
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,$3F3F3F,$3F3F3F3F,0,0,0,0,0
 DC.L	0,$FFFFFF,-1,0,0,0,0,0,0,$FFFFFF,-1,0,0,0,0,0,0,$FFFFFF
 DC.L	-1,0,0,0,0,0,0,$FFFFFF,-1,0,0,0,0,0,0,$FFFFFF,-1,0
 DC.L	0,0,0,0,0,$FFFFFF,-1,0,0,0,0,0,0,$808080,$80808080,0
 DC.L	0,0,$1F7F7F7F,$7F1F0701,0,$1F7F7F,$7F7F7F1F,0
 DC.L	$1071F7F,$7F7F7F1F,$FEFFFFFF,-1,$7F1F0701,$FFFFFF
 DC.L	-1,$1071F7F,-1,$FFFFFFFE,$80E0F8,$FEFFFFFF,-1,$7FFFFFFF
 DC.L	-1,-1,$FFFFFFFE,$F8E08000,0,$80E0F9,-1,-1,-1,-1
 DC.L	$F9E08000,0,1,$71F7FFF,-1,-1,-1,-1,$FF7F1F07,$1000000
 DC.L	$71F7FFF,-1,$FFFFFEF8,$E0FFFFFF,-1,$F8FEFFFF,-1,$FF7F1F07
 DC.L	-1,$FFFFFEF8,$E0800000,$FFFFFF,-1,$80E0,$F8FEFFFF,-1
 DC.L	$80E0E0E0,$E0800000,0,$80E0E0,$E0E0E080,0,$80E0,$E0E0E080
 DC.L	0,0,0,0,1,$107071F,$1F7F7F7F,$7F7F7F1F,0,0,1,$107071F
 DC.L	$1F7F7FFF,-1,-1,$FFFEFEF8,1,$107071F,$1F7F7FFF,-1
 DC.L	-1,$FFFEFEF8,$F8E0E080,$80000000,$1F7F7FFF,-1,-1,$FFFEFEF8
 DC.L	$F8E0E080,$80000000,0,0,$F8FEFEFE,$FEFEFEF8,$F8E0E080,$80000000
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,$71F1F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
 DC.L	$7F1F1F07,$7F,$7F7F7F7F,$7F7F7F00,$7FFFFFFF,-1,-1,-1
 DC.L	-1,$7F0000FF,-1,$FFFFFF00,$80F8FEFE,-1,-1,-1,$FFFEFEF8,$800000FF
 DC.L	-1,$FFFFFF00,0,$80808080,$80808080,$80808080,$80000000,$80
 DC.L	$80808080,$80808000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1
 DC.L	$FFFF0000,$F3F3FFF,-1,$FFFF00FF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1
 DC.L	-1,$FFFF00FF,-1,$FFFFFF00,-1,-1,$FFFF00FF,-1,-1,$FCFC00F0
 DC.L	$F0F0F0F0,$F0F0F000,-1,-1,$FFFF00FF,-1,-1,0,0,0,-1,-1
 DC.L	$FFFF00FF,-1,-1,0,0,0,-1,-1,$FFFF3FFF,-1,-1,0,0,0
 DC.L	$FCFFFFFF,-1,-1,-1,$FFFFFFFC,0,0,0,$C0F0F0,$FCFCFCFC
 DC.L	$FCFCFCFC,$FCFCFCFC,$F0F0C000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,$F0F0F0F,$F003F3F,$3F3F0000,0,0,0,0,0,-1,-1
 DC.L	$FFFC0000,0,0,0,0,0,-1,-1,$F0000000,0,0,0,0,0,0,0,0,0,0,0
 DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,46,48,00,00,00,00,48,41,42,44,00,27,43,28,45

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	31,32,33,34,35,36,37,38,39,40,30,29,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,41,00,42,00,00,48,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z
 dc.b	22,23,24,25,26

	even

adr	incbin	adr.dat

sine_table	incbin	sine.tab







*** star table is made up in the following way..
*
* word:  line offset for screen
* word:  word off on line
* word:  dot shift
* word:  speed dot moves
star_table
	REPT	NO_STARS
	dcb.w	4
	ENDR




screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"               ADRENALIN 30             "
	dc.b	"                                        "
	dc.b	"        1: ISHAR - LEGEND OF THE        "
	dc.b	"        2: ISHAR CHARACTER EDITOR       "
	dc.b	"        3: ISHAR DOCS                   "
	dc.b	"        4: ESCAPADE DOCS                "
	dc.b	"        5: PIC SWITCH DOCS              "
	dc.b	"        6: A320 AIRBUS DOCS             "
	dc.b	"        7: ALCATRAZ DOCS                "
	dc.b	"        8: SENSIBLE SOCCER DOCS         "
	dc.b	"                                        "
	dc.b	"              0: 50/60 HZ               "
	even

screen_titles_font	incbin	6x6_font.dat
	even


key_codes		;comment out keys you don't want to use
	dc.w	2,0	;key 1
	dc.w	3,1	;key 2
	dc.w	4,2	;key 3
	dc.w	5,3	;key 4
	dc.w	6,4	;key 5
	dc.w	7,5	;key 6
	dc.w	8,6	;key 7
	dc.w	9,7	;key 8
;	dc.w	10,8	;key 9

	dc.w	$6d,0	;keypad 1
	dc.w	$6e,1	;keypad 2
	dc.w	$6f,2	;keypad 3
	dc.w	$6a,3	;keypad 4
	dc.w	$6b,4	;keypad 5
	dc.w	$6c,5	;keypad 6
	dc.w	$67,6	;keypad 7
	dc.w	$68,7	;keypad 8
;	dc.w	$69,8	;keypad 9

	dc.w	-1	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5
		dc.l	filename6
		dc.l	filename7
		dc.l	filename8
;		dc.l	filename9


**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"ISHAR.ADR",0
	even
filename2	dc.b	"$$ISHAR_CE.PRG",0
	even
filename3	dc.b	"\DOCS\1.ADR",0
	even
filename4	dc.b	"\DOCS\2.ADR",0
	even
filename5	dc.b	"\DOCS\3.ADR",0
	even
filename6	dc.b	"\DOCS\4.ADR",0
	even
filename7	dc.b	"\DOCS\5.ADR",0
	even
filename8	dc.b	"\DOCS\6.ADR",0
	even
;filename9	dc.b	"",0
;	even



	ifeq	DOWNLOAD
*******************************
	SECTION BSS
*******************************
	endc


bss_start
hertz_switch	ds.w	1
zero_counter	ds.w	1
old_stack	ds.l	1
screen_base	ds.l	1
old_pal		ds.w	16
old_70		ds.l	1
old_120		ds.l	1
vsync_flag	ds.w	1
old_rez		ds.b	1
olda07		ds.b	1
olda09		ds.b	1
	even
char_offset	ds.w	1
sine_offset	ds.w	1
black		ds.w	16

last_pos	ds.w	1
last_pos_tab	;9 letters in ADR
		ds.w	10		;look up for clearing ADR bobs


scr_now		ds.l	1
scr_xor		ds.l	1
scr_last	ds.l	1
		ds.b	256
screens		ds.b	32000
		ds.b	32000


bss_end
	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC


*************************************************************************
*			     PURE ENERGY MENU				*
*			     ----------------				*
*									*
*									*
*									*
* Written By: 	MAC SYSTEM DATA of PERSISTENCE OF VISION		*
*									*
*									*
* Date:		26th Feb 1994						*
*									*
*									*
* Music by: 	NO-MORE of ANIMAL MINE					*
*									*
*									*
*									*
*			All code ½ P.O.V. 1992,1993,1994		*
* 									*
*************************************************************************
*
* Menu with;
*		Large scroller
*		Spectrum analyzer
*		Rippler
*		Rasters
*

yes=1
no=0
YES=yes
NO=no
		opt	o+,w-

AUTORUN4=no	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here
		;If AUTORUN4 is used you can exit to the desktop to
		;double click a program or use the POV autogem/d_click.prg

		ifeq	AUTORUN4
begin		bra	start
		ds.l	100
ustack		ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec		pea	blank(pc)
		pea	blank(pc)
		pea	$200
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	.reset(pc)		;always reset on return from prog
		move.w	#$26,-(sp)
		trap	#14
.reset		move.l	4.w,-(sp)
		rts

blank		dc.l	0

*******************************************************************
start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		ENDC

		bsr	set_up
main_loop	bsr	vsync
		bsr	set_screen	;screen flip
;		move.w	#$123,$ffff8240.w

		bsr	scroll
		bsr	rippler
		jsr	music+6
		bsr	clear_spec
		bsr	calc_spec

;		move.w	pic+2,$ffff8240.w

		move.w	key,d0

		cmp.w	#1,d0
		beq.s	assem

		cmp.b	#$b,d0			;0 key
		beq	zero

check_keys	lea	key_codes,a6
.loop		cmp.b	#$ff,(a6)	;end of table?
		beq.s	main_loop	;yes
		cmp.b	(a6)+,d0	;is key one we want?
		beq.s	load		;yes so load demo
		move.b	(a6)+,d6	;NO so get offset
		bra.s	.loop		;check another key code

load		move.b	(a6),-(sp)
		bsr	shut_down
		moveq	#0,d0
		move.b	(sp)+,d0	;get key value off stack

		lea	filename_table,a0
		lsl.w	#2,d0		;multiply D0 by 4 (one long word)
		add.w	d0,a0
		move.l	(a0),a1		;get filename address

*** now move filename into $200 for AUTORUN4 to find
		lea	$200.w,a0
		movem.l	(a1),d0-d3	;move 16 bytes
		movem.l	d0-d3,(a0)		;into $200

*** now check hertz and exit cleanly...
		tst.w	hertz_switch		;has hertz been pressed?
		beq.s	hz50			;no so it stays in 50Hz
		eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50
		bsr	set_user

		ifeq	AUTORUN4
		bra	exec
		ELSE
		clr.w	-(sp)		;exit to desktop
		trap	#1
		ENDC

assem		bsr	shut_down
		bsr	set_user
		clr.w	-(sp)
		trap	#1

zero		tst.w	zero_counter
		bne	check_keys
		eor.w	#$002,hertz_switch	;show a hertz change
		move.w	#10,zero_counter	;delay in between hertz switches
		bra	main_loop





*******************
* CUSTOM ROUTINES *
*******************
DEPTH	equ	32
WIDTH	equ	8
ANDVALUE	equ	WIDTH-1
scroll	move.l	scr_now,a1
	lea	16+(69*160)(a1),a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
	moveq	#36,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#WIDTH*DEPTH,d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#DEPTH,d0
	add.w	d0,a0

.column
OFF	set	0
	REPT	DEPTH
	move.b	(a0),OFF(a1)
	move.b	(a0)+,OFF+160(a1)
OFF	set	OFF+320
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#ANDVALUE,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#ANDVALUE,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts





RIPPLER_WIDTH	equ	2
RIPPLER_DEPTH	equ	194

rippler		move.l	ripple_table_pos,a3
		cmp.l	#reset_ripple_flag,a3
		blt.s	.do_rout
		move.l	#ripple_table,ripple_table_pos
.do_rout	lea	ripple_data,a4
		move.l	scr_now,a5
		add.w	#((200-RIPPLER_DEPTH)*160)+2,a5
		move.w	#RIPPLER_DEPTH-1,d2
.loop		move.b	(a3)+,d0
		move.b	(a3)+,d1
		move.l	a5,a1
		move.l	a4,a0
		and.l	#$ff,d0
		and.l	#$ff,d1
		lsl.w	#3,d0		;word offset *8
		mulu	#RIPPLER_WIDTH*2*RIPPLER_DEPTH,d1	;ripple number
		add.l	d1,a0
		add.w	d0,a1
offset	set	0
		rept	RIPPLER_WIDTH
		move.w	(a0)+,offset(a1)
offset	set	offset+8
		endr
		add.w	#RIPPLER_WIDTH*2,a4
		lea	160(a5),a5
		dbf	d2,.loop
		addq.l	#2,ripple_table_pos
		rts



******************************
*                            *
* Spectrum Analyser routines *
*                            *
******************************

MAX_BARS	equ	80-8
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

clear_spec
	move.l	scr_now,a1
	add.w	#16+(160*(39-20)),a1
	moveq	#0,d0
	move.w	#26-1,d1
.loop
offset	set	0
	REPT	MAX_BARS/4
	move.w	d0,offset(a1)
offset	set	offset+8
	endr
	lea	160(a1),a1
	dbf	d1,.loop
	rts

calc_spec
	lea	spec_values,a0
	moveq	#(MAX_BARS-1),d0
.cnt_down
	tst.w	(a0)+
	beq.s	.next
	subq.w	#1,-2(a0)
.next
	dbf	d0,.cnt_down

	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_data,a3
	moveq	#12,d2

	move.b	#AAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	bchan
	moveq	#0,d0
	move.b	#ACOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	bchan
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************
bchan
	move.b	#BAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	cchan
	moveq	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	cchan
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************
cchan
	move.b	#CAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	ps
	moveq	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	ps
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************** print speccy *******************
ps
	move.l	scr_now,a0
	add.w	#16+((51-20)*160),a0

	lea	spec_values,a2
	moveq	#(MAX_BARS/4)-1,d1
.loop
	move.w	(a2)+,d0
	beq.s	.nib2
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%11100000,d2
.loop1	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2
	move.w	(a2)+,d0
	beq.s	.nib3
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	move.w	(a2)+,d0
	beq.s	.nib4
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%11100000,d2
.loop3	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	move.w	(a2)+,d0
	beq.s	.nonib
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%00001110,d2
.loop4	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4

.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts


***********************
* SUBROUTINES SECTION *
***********************
vsync		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts


set_old_palette	lea	old_palette,a0
set_pal		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts




set_up		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette

		lea	storage,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		bsr	 shift_pe

		lea	pic+34+(160*8),a0
		move.w	#192-1,d0
		moveq	#0,d1
.clear_rippler_area
		move.w	d1,(a0)
		move.w	d1,8(a0)
		lea	160(a0),a0
		dbf	d0,.clear_rippler_area

		bsr	print_titles
		bsr	print_disc_title

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

		bsr	set_screen

		jsr	music

		move.w	#$2700,sr
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#new_vbl,$70.w
		move.l	#new_kbd,$118.w
		move.l	#timerb,$120.w
		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.w	#$2300,sr
		rts

shut_down	move.w	#$2700,sr
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		lea	storage,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		jsr	music+2
		move.w	#$2300,sr

		bsr	set_old_palette

		move.w	#1,-(sp)
		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.b	#$8,$fffffc02.w

		rts

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

shift_pe	lea	ripple_data,a1
		move.w	#16-1,d1
.loop2		lea	pic+34+((200-RIPPLER_DEPTH)*160),a0
		move.w	#RIPPLER_DEPTH-1,d0
OFF		set	0
.loop		REPT	RIPPLER_WIDTH
		move.w	OFF(a0),(a1)+
OFF		set	OFF+8
		ENDR
		lea	160(a0),a0
		dbf	d0,.loop

		lea	pic+34,a0
		move.w	#RIPPLER_DEPTH-1,d2
		sub.w	d0,d0		;clear carry flag before shifting
OFF		set	0
.scroll		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR

		lea	160(a0),a0
		dbf	d2,.scroll
		dbf	d1,.loop2
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


ENABLE_PLANE1	equ	yes
ENABLE_PLANE2	equ	no
ENABLE_PLANE3	equ	no
ENABLE_PLANE4	equ	no

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#(160*134),a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(80*6),a3

		move.w	#11-1,d0	;max titles per menu
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

print_disc_title
		lea	pic+34,a0
		lea	disc_title,a1
		lea	screen_titles_font,a2
		move.w	#(40/2)-1,d0
.loop		moveq	#0,d1
		move.b	(a1)+,d1
		sub.w	#32,d1
		mulu	#6,d1
		move.b	0(a2,d1.w),d2
		move.b	d2,2(a0)
		move.b	d2,4(a0)
		move.b	d2,6(a0)
		move.b	1(a2,d1.w),d2
		move.b	d2,162(a0)
		move.b	d2,164(a0)
		move.b	d2,166(a0)
		move.b	2(a2,d1.w),d2
		move.b	d2,322(a0)
		move.b	d2,324(a0)
		move.b	d2,326(a0)
		move.b	3(a2,d1.w),d2
		move.b	d2,482(a0)
		move.b	d2,484(a0)
		move.b	d2,486(a0)
		move.b	4(a2,d1.w),d2
		move.b	d2,642(a0)
		move.b	d2,644(a0)
		move.b	d2,646(a0)
		move.b	5(a2,d1.w),d2
		move.b	d2,802(a0)
		move.b	d2,804(a0)
		move.b	d2,806(a0)

		moveq	#0,d1
		move.b	(a1)+,d1
		sub.w	#32,d1
		mulu	#6,d1
		move.b	0(a2,d1.w),d2
		move.b	d2,3(a0)
		move.b	d2,5(a0)
		move.b	d2,7(a0)
		move.b	1(a2,d1.w),d2
		move.b	d2,163(a0)
		move.b	d2,165(a0)
		move.b	d2,167(a0)
		move.b	2(a2,d1.w),d2
		move.b	d2,323(a0)
		move.b	d2,325(a0)
		move.b	d2,327(a0)
		move.b	3(a2,d1.w),d2
		move.b	d2,483(a0)
		move.b	d2,485(a0)
		move.b	d2,487(a0)
		move.b	4(a2,d1.w),d2
		move.b	d2,643(a0)
		move.b	d2,645(a0)
		move.b	d2,647(a0)
		move.b	5(a2,d1.w),d2
		move.b	d2,803(a0)
		move.b	d2,805(a0)
		move.b	d2,807(a0)

		add.w	#8,a0
		dbf	d0,.loop
		rts




new_vbl		clr.w	vsync_flag
		move.w	#0,$ffff8240.w
hertz_switch	equ	*-4
		clr.b	$fffffa1b.w
		move.b	#6,$fffffa21.w
		move.l	#timerb,$120.w
		move.l	raster_col,rippler_col
		move.l	#raster_col+4,raster_col_pos
		move.b	#8,$fffffa1b.w
		tst.w	zero_counter
		bne.s	.dec
		rte
.dec		sub.w	#1,zero_counter
		rte

timerb		clr.b	$fffffa1b.w
		move.b	#2,$fffffa21.w
		move.l	#timerb_main,$120.w
		move.b	#8,$fffffa1b.w
		rte

timerb_main	move.l	#0,$ffff8242.w
rippler_col	equ	*-6
		move.l	a0,-(sp)
		move.l	raster_col_pos,a0
		move.l	(a0)+,rippler_col
		move.l	a0,raster_col_pos
		move.l	(sp)+,a0
		rte

new_kbd		movem.l	d0,-(sp)
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1
		bclr	#6,$fffffa11.w
		movem.l	(sp)+,d0
		rte

*******************
   SECTION DATA
*******************
pic	incbin	"pic.pi1"


scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "          PURE ENERGY PRESENTS COMPILATION 73.        "
 dc.b "ALL CODING BY MAC SYS DATA OF PERSISTENCE OF VISION (YOU CAN'T TELL CAN YOU!), "
 dc.b "GRAFIX BY HARLEQUIN AND MSD, MUSIC BY NOMORE OF AM.       "
 DC.B "             BYE!                    "
 DC.B "                             "
 dc.b $ff
	even
char_offset	dc.w	0
font		dcb.b	DEPTH*WIDTH,0
		incbin	"new_font.fnt"
font_offsets:
;           !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	00,38,00,00,00,00,00,45,42,43,00,00,41,00,41,00
;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,39,44,00,00,00,37,00
;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17
;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `
 dc.b	18,19,20,21,22,23,24,25,26,00,00,00,00,00,00
;        a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17
;        r  s  t  u  v  w  x  y  z  {  |  }  ~ DEL
 dc.b	18,19,20,21,22,23,24,25,26,00,00,00,00,00

	even
ripple_table_pos	dc.l	init_ripple_table
init_ripple_table

ripple_table	incbin	sine1.dat
		incbin	sine1.dat
		incbin	sine2.dat
		incbin	sine1.dat
		incbin	sine3.dat
		incbin	sine1.dat
		incbin	sine3.dat
reset_ripple_flag
		incbin	sine1.dat
	even
raster_col
 dc.w	$000,$708,$000,$e01,$000,$609,$000,$d02,$000,$50a,$200,$c03,$300,$40b,$400
 dc.w	$b04,$500,$30c,$600,$a05,$700,$20d,$f00,$906,$f00,$10e,$700,$807,$600,$00f
 dc.w	$500,$08f,$400,$01f,$300,$09f,$200,$02f,$000,$0af,$000,$03f,$000,$0bf,$000
 dc.w	$04f,$000,$0cf,$000,$05f,$000,$0df,$000,$06f,$000,$0ef,$000,$07f,$000,$0ff
 dc.w	$ff0,$07f,$f70,$0ef,$fe0,$06f,$f60,$0df,$fd0,$05f,$f50,$0cf,$fc0,$04f,$f40
 dc.w	$0bf,$fb0,$03f,$f30,$0af,$fa0,$02f,$f20,$09f,$f90,$01f,$f10,$08f,$f80
 dc.w	$00f,$f00,$807,$f80,$10e,$f10,$906,$f90,$20d,$f20,$a05,$fa0,$30c,$f30
 dc.w	$b04,$fb0,$40b,$f40,$c03,$fc0,$50a,$f50,$d02,$fd0,$609,$f60,$e01,$fe0
;                                                     --- Titles rasters start from here
 dc.w	$708,$f70,$f00,$ff0,$f80,$ff0,$f10,$000,$f90,$202,$f20,$a0a,$fa0,$303
 dc.w	$f30,$b0b,$fb0,$404,$f40,$c0c,$fc0,$505,$f50,$d0d,$fd0,$606,$f60,$e0e
 dc.w	$fe0,$707,$f70,$f0f,$ff0,$f0f,$7f0,$f0f,$ef0,$f0f,$6f0,$f0f,$df0,$f0f
 dc.w	$5f0,$f0f,$cf0,$f0f,$4f0,$f0f,$bf0,$f0f,$3f0,$f0f,$af0,$707,$2f0,$e0e
 dc.w	$9f0,$606,$1f0,$d0d,$8f0,$505,$0f0,$c0c,$070,$404,$0e0,$b0b,$060,$303
 dc.w	$000,$a0a,$000,$202


disc_title
;          ------1234567890123456789012345678901234567890------
	dc.b	"--------- PURE ENERGY DISC 73 ----------"

screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"    aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"    g                                  h"
	dc.b	"    g   1: ISHAR - LEGEND OF THE       h"
	dc.b	"    g   2: ISHAR CHARACTER EDITOR      h"
	dc.b	"    g   3: ISHAR DOCS                  h"
	dc.b	"    g   4: ALCATRAZ DOCS               h"
	dc.b	"    g   5: SENSIBLE SOCCER DOCS        h"
	dc.b	"    g   6: DOCS                        h"
	dc.b	"    g                                  h"
	dc.b	"    g         0: 50/60 HZ              h"
	dc.b	"    dffffffffffffffffffffffffffffffffffc"
	even

screen_titles_font
	dc.l	0,$1818,$18001800,$66660000,$6cfe,$6cfe6c00,$3e583c1a
	dc.l	$7c00666c,$18326600,0,$1818,0,$c181818,$c003018
	dc.l	$18183000,$663cff3c,$66001818,$7e181800,0,$30600000,$7e000000
	dc.l	0,$1800060c,$18306000,$3c666e76,$3c001838,$18187e00,$3c660c18
	dc.l	$3e007e0c,$1c463c00,$1c3c6c7e,$c007e60,$7c067c00,$3c607c66,$3c007e0c
	dc.l	$18303000,$3c663c66,$3c003c66,$3e063c00,$180018,$18,$183000
	dc.l	$c183018,$c00007e,$7e0000,$30180c18,$30003c46,$c001800,$3e626c60
	dc.l	$7e003c66,$667e6600,$7c667c66,$7c003c66,$60663c00,$7c666666,$7c007e60
	dc.l	$7c607e00,$7e607c60,$60003e60,$6e663e00,$66667e66,$66003c18,$18183c00
	dc.l	$6060666,$3c006c78,$70786c00,$60606060,$7e00eefe,$d6c6c600,$767e7e6e
	dc.l	$66003c66,$66663c00,$7c667c60,$60003c66,$666c3600,$7c667c6c,$66003c60
	dc.l	$3c063c00,$7e181818,$18006666,$66663e00,$66666624,$1800c6c6,$d6eec600
	dc.l	$663c183c,$66006666,$3c181800,$7e0c1830,$7e001e18,$18181e00,$6030180c
	dc.l	$6007818,$18187800,$386cc600,0,$fe00,$c0603000,$ff80
	dc.l	$80808080,$ff010101,$1010101,$10101ff,$80808080,$80ffff00,0
	dc.l	0,$ff8080,$80808080,$1010101,$1010000,0,0
	dc.l	0,0,0,0,0,0,0
	dc.l	0,$ffffffff,$ffffc3c3,$c3c3c3c3,$ff,$ffff0000,1
	dc.l	0,$10000,0,$ffffffff,$ffffc3c3,$c3ffffff,$c1c1c3c1
	dc.l	$c1e18383,$c3838387,0,$c300,$c3c3,$ffffff87,$707ff00
	dc.l	$ffff,$ffffffc3,$c3c3e0c0,$8103070f,0,$818383,$83000000
	dc.l	$80,$80800000,$81,$81010000,$e10000,1,$1010000
	dc.l	$810000,$81838787,0,$810000,$808081,$c3c3c3c3,$c3ffc3c3
	dc.l	$c3838387,$c1818381,$c1e10000,$ff,$8381c181,$83870000,$c1c3c3
	dc.l	0,0,0,0,$10000,$81,0
	dc.l	$10000,$1000000,$101,$f0f0000,$80,0,$8181
	dc.l	$c3818181,$f0f00000,$810101,$3010101,$f0f0f00,0,$1010
	dc.l	0,0,$81,1,$f0f0000,$80,0
	dc.l	$101,$808081,$c3c3,$c3c30000,$80,0,$81c31000
	dc.l	$10,$8100,0,$81c3c3,$8100,$c0c0,$c3c0c0c0
	dc.l	$70381c0,$e0f00303,$c3030303,$1000010,$ffffffff,$ff000000,$f070787
	dc.l	$ffff007f,$7f7f7fff,$fcfcfc,$fcfffcfc,$fcfc00ff,$3f3f3f3f,$ffffff
	dc.l	$ffffffff,$ffffffff,$ff3f3f,$3f3f3fff,$fcfcfcfc,$fcffffff,$ffffffff
	dc.l	$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff
	dc.l	$ffffffff,$ffffffff



spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.w	MAX_BARS,0


music		incbin	deep.sid

		even


key_codes		;comment out keys you don't want to use
	dc.b	2,0	;key 1
	dc.b	3,1	;key 2
	dc.b	4,2	;key 3
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
	dc.b	7,5	;key 6
;	dc.b	8,6	;key 7
;	dc.b	9,7	;key 8
;	dc.b	10,8	;key 9

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1	;keypad 2
	dc.b	$6f,2	;keypad 3
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$6c,5	;keypad 6
;	dc.b	$67,6	;keypad 7
;	dc.b	$68,7	;keypad 8
;	dc.b	$69,8	;keypad 9

	dc.b	$ff	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5
		dc.l	filename6
		dc.l	filename7
		dc.l	filename8
		dc.l	filename9


**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"pov138.prg",0
	even
filename2	dc.b	"adr.prg",0
	even
filename3	dc.b	"p_base.msd",0
	even
filename4	dc.b	"ninja_3.msd",0
	even
filename5	dc.b	"copier.pov",0
	even
filename6	dc.b	"filename.ext",0
	even
filename7	dc.b	"filename.ext",0
	even
filename8	dc.b	"filename.ext",0
	even
filename9	dc.b	"filename.ext",0
	even

*******************
   SECTION BSS
*******************
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
vsync_flag	ds.w	1
key		ds.w	1
zero_counter	ds.w	1
scr_now		ds.l	1
scr_xor		ds.l	1
raster_col_pos	ds.l	1

storage		ds.b	16

ripple_data	ds.b	(4*200)*16	;4 bytes per line

		ds.b	256
screens		ds.b	32000
		ds.b	32000

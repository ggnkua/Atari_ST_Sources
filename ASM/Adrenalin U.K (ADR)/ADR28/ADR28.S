;------------------------------------------------------------------------
;|				ADRENALIN 28				|
;|				------------				|
;|									|
;| Coded By: SPACEMAN SPIFF						|
;|									|
;|									|
;| Graphics by: Biofeedback & Spaceman Spiff				|
;|									|
;|									|
;| Music by: ? from Chronicles music demo				|
;|									|
;|									|
;| Date: 20th October 1992						|
;|									|
;|									|
;| Reduced INCBINs for floppy disc users				|
;|									|
;------------------------------------------------------------------------
;
; NOTE:	There is less than 100 cycles left on this menu with this tune
;	and it may go into 2 frames on some machines. I've optimized
;	the routines for speed not space so watch any changes you make.
;	SPACEMAN SPIFF 23rd October 1992
;
TBDR	equ	$fffffa21		;TimerB Data Register
TBCR	equ	$fffffa1b		;TimerB Control Register


	opt	o+,w-

YES=1
yes=1
NO=0
no=0

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

	IFEQ	DOWNLOAD
***************************
	SECTION TEXT
***************************
	ENDC

*~~~~~~~~~~~~~~~~~~~~~~~ HERE GOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	opt	o+


	IFEQ	DOWNLOAD
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
	ENDC

adr		bsr	clear_bss

		IFEQ	DOWNLOAD
		bsr	set_super		;set supervisor mode
		ENDC
		clr.w	$200.w			;clear file to run
		move.b	#$12,$fffffc02.w	;Disable mouse
		move.l	$44e.w,old_base		;get present screen base
		move.b	$ffff8260.w,org_rez
		movem.l	$ffff8240.w,d0-d7	;save old colours
		movem.l	d0-d7,old_pal
		movem.l	black,d0-d7		;make all colours black
		movem.l	d0-d7,$ffff8240.w

		bsr	shift_logo
		bsr	print_titles		;game titles
		bsr	calc_screen		;calc our own screen address
		move.l	screen_1,a0		;new screen base
		clr.b	$ffff8260.w		;go into low rez
		move.l	screen_1,present_base
		move.l	screen_2,last_base

		move.b	$484.w,old484		;save keyboard click/speed, etc
		clr.b	$484.w			;disable repeat/click/bell

		bsr	save_all

*****************************************************************************
**************** Blipblop-Part of Chronicle Musics Demo *********************
********************** 18 Pieces of cool musaxxs ****************************
******* Ripped by M.C. (the fuckin' best Musaxxs Ripper (Penguin)) **********
*****************************************************************************
                lea     song(pc),a6
                bsr     player
                move.l  a6,tune_isr
		bsr	set_palette		;set new colours
		bsr	show_pic
		bsr	set_isr
		bsr	flush			;flush keyboard buffer
main_loop	bsr	flip_screen
		move.w	#$ffff,vsync_flag	;vsync
.sync		tst.w	vsync_flag
		bne.s	.sync

;	move.w	#$070,$ffff8240.w


*********** SPECIAL TUNE JSR 'COS OF BLIP BLOPPER***************
		jsr	$1234.l
tune_isr	equ	*-4		;do tune isr here to stop raster jitter
****************************************************************

		jsr	rippler
		jsr	scroll
		jsr	set_rasters
;	move.w	pic+2,$ffff8240.w



		move.b	$fffffc02.w,d0		;OLD but trusty key routine

		cmp.b	#01,d0			;escape?
		beq	exit			;yes get out...

		cmp.b	#$b,d0			;0 key
		beq	zero

		cmp.b	#$70,d0			;0 keypad
		beq	zero

check_keys	and.l	#$ff,d0
		lea	key_codes,a5
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

		bsr	vsync			;shut the interrupts down
		move.w	#$2700,sr		;quick before she blows up!!
		move.l	old70,$70.w
		move.l	old_timerb,$120.w

		lea	$ffff8800.w,a0		;silence sound chip
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)

		move.b	olda07,$FFFFFA07.w
		move.b	olda09,$FFFFFA09.w
		move.b	olda0d,$fffffa0d.w
		move.b	save0f,$fffffa0f.w
		move.b	save11,$fffffa11.w
		move.b	save13,$fffffa13.w
		move.b	olda15,$fffffa15.w
		move.b	olda17,$FFFFFA17.w
		move.b	olda1b,TBCR.w
		move.b	olda1d,$fffffa1d.w
		move.b	olda21,TBDR.w
		move.w	#$2300,sr

		move.l	old_base,d0		;put screen back to original
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		move.b	org_rez,$ffff8260.w	;go org rez for assembler/desktop
		bsr	restore_pal		;restore colours
		move.b	#8,$fffffc02.w		;mouse back on
		move.b	old484,$484.w		;keyclick, etc
		bsr	flush			;clear keyboard buffer

*** now check hertz and exit cleanly...
		tst.w	hertz_switch		;has hertz been pressed?
		beq.s	hz50			;no so it stays in 50Hz
		eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50		move.b	#8,$fffffc02.w		;mouse back on

		IFEQ	DOWNLOAD
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		lea	adr,a0		;clear memory used by menu
		move.l	#bss_end-adr,d0
.loop		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.loop

		ifeq	AUTORUN4
		bra	exec
		ELSEIF
		clr.w	-(sp)		;exit to desktop
		trap	#1
		ENDC
		ENDC

		move.w	#$2300,sr

		clr.w	-(sp)
		trap	#1



zero		tst.w	zero_counter		;HERTZ FLIP ROUTINE
		bne	check_keys
		eor.w	#$200,pic+2		;show a hertz change
		eor.w	#$ffff,hertz_switch	;toggle a check
		move.w	#10,zero_counter	;delay in between hertz switches
		bra	main_loop

exit		bsr	vsync			;shut the interrupts down
		move.w	#$2700,sr		;quick before she blows up!!
		move.l	old70,$70.w
		move.l	old_timerb,$120.w

		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)

		MOVE.B	olda07,$FFFFFA07.w
		MOVE.B	olda09,$FFFFFA09.w
		move.b	olda0d,$fffffa0d.w
		move.b	save0f,$fffffa0f.w
		move.b	save11,$fffffa11.w
		move.b	save13,$fffffa13.w
		move.b	olda15,$fffffa15.w
		MOVE.B	olda17,$FFFFFA17.w
		move.b	olda1b,TBCR.w
		move.b	olda1d,$fffffa1d.w
		move.b	olda21,TBDR.w
		move.w	#$2300,sr

		move.l	old_base,d0		;put screen back to original
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		move.b	org_rez,$ffff8260.w	;go org rez for assembler/desktop
		bsr	restore_pal		;restore colours
		move.b	#8,$fffffc02.w		;mouse back on
		move.b	old484,$484.w		;keyclick, etc
		bsr	flush			;clear keyboard buffer

		IFNE	DOWNLOAD
		move.l	4.w,-(sp)
		rts
;;;;;;;;	trap	#0	;usual download trigger
		ENDC

		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)			;assembler/desktop
		trap	#1			;BYE!


***************
* Subroutines *
***************

set_rasters
		lea	rast_colours,a0
		moveq	#0,d0
		rept	200/2
		move.l	d0,(a0)+
		endr

		lea	colour_bar,a0
		lea	rast_colours,a1
		lea	raster_path,a2
		move.w	path_ptr,d2
		REPT	10		;number of rasterbars
		move.l	a0,a4
		move.l	a1,a3
		add.w	(a2,d2.w),a3
		move.l	(a4)+,(a3)+	;width of bar - 1 line =word
		move.l	(a4)+,(a3)+

****************** read the line below!!!!!!!*************
		add.w	#26,d2	;gap between lines alter this in increments of 2
**********************************************************

		and.w	#(2*1024)-1,d2
		addq.w	#2,a0		;increase through colours
		ENDR

		addq.w	#6,path_ptr
		and.w	#(2*1024)-1,path_ptr
		rts



DEPTH	equ	32

scroll	move.l	last_base,a1
	add.l	#160*202,a1
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
	move.b	(a0),OFF(a1)
	move.b	(a0)+,OFF+160(a1)
OFF	set	OFF+2*160		;go down a line
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



RIPPLER_WIDTH	equ	8
RIPPLER_DEPTH	equ	40

rippler		move.l	ripple_table_pos,a3
		cmp.l	#reset_ripple_flag,a3
		blt.s	.do_rout
		move.l	#ripple_table,ripple_table_pos
.do_rout	lea	ripple_data,a4
		move.l	last_base,a5
		add.l	#160*214+2,a5
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
		move.w	(a0)+,(a1)
		move.w	(a0)+,8(a1)
		move.w	(a0)+,16(a1)
		move.w	(a0)+,24(a1)
		move.w	(a0)+,32(a1)
		move.w	(a0)+,40(a1)
		move.w	(a0)+,48(a1)
		lea	RIPPLER_WIDTH*2(a4),a4
		lea	160(a5),a5
		dbf	d2,.loop
		addq.l	#2,ripple_table_pos
		rts

********************
* SERVICE ROUTINES *
********************

flip_screen	move.l	present_base,last_base
		move.l	screen_1,a0
		move.w	screen_number,d0
		beq	.1
		move.l	screen_2,a0
.1		move.l	a0,present_base
		eor.w	#-1,screen_number
		move.l	a0,d0
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts


flush		btst.b	#0,$fffffC00.w	;flush keyboard
		beq.s	flush2
		move.b	$fffffC02.w,d0
		bra.s	flush
flush2		rts


vsync		move.w	#$ffff,vsync_flag	;custom routine to wait
vs		tst.w	vsync_flag		;for screen refresh
		bne.s	vs
		rts


set_super
	move.l	d7,user_stack

	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts



restore_pal			;put back original colours
		lea	old_pal,a0
		bra.s	set_p
set_palette	lea	pic+2,a0
set_p		lea	$ffff8240.w,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts


calc_screen	;calc our own screen address...
		lea	screen,a0
		move.l	a0,d0
		clr.b	d0
		move.l	d0,screen_1
		add.l	#49152,d0
		move.l	d0,screen_2
		rts


show_pic	lea	pic+34,a0
		move.l	present_base,a1
		move.l	screen_2,a2		;for flip screen

**********************************************************
;extend length of pic to 160*228 if titles are lowered
**********************************************************
		move.w	#160*200/4-1,d1

.copy		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d1,.copy
		rts

clear_bss	lea	bss_start,a0
.clear		clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	.clear
		rts


save_all	move.l	$70.w,old70
		move.l	$120.w,old_timerb
		move.b	$fffffa07.w,olda07
		move.b	$fffffa09.w,olda09
		move.b	$fffffa0d.w,olda0d
		move.b	$fffffa0f.w,save0f
		move.b	$fffffa11.w,save11
		move.b	$fffffa13.w,save13
		move.b	$fffffa15.w,olda15
	 	move.b	$fffffa17.w,olda17
		move.b	$fffffa1b.w,olda1b
		move.b	$fffffa1d.w,olda1d
		move.b	$fffffa21.w,olda21
		rts

set_isr		move.w	#$2700,sr
		clr.b	$fffffa1d.w
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w
		move.l	#new_vbl,$70.w
		move.l	#new_timerb,$120.w
		or.b	#1,$fffffa07.w

		clr.b	$fffffa09.w

		ori.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w		;enable auto A-INTERRUPT IN SERVICE clear
		move.w	#$2300,sr
		rts


shift_logo	lea	ripple_data,a1
		move.w	#16-1,d1
.loop2		lea	logo+34,a0
		move.w	#RIPPLER_DEPTH-1,d0
OFF		set	0
.loop		REPT	RIPPLER_WIDTH
		move.w	OFF(a0),(a1)+
OFF		set	OFF+8
		ENDR
		lea	160(a0),a0
		dbf	d0,.loop

		lea	logo+34,a0
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
ENABLE_PLANE2	equ	yes
ENABLE_PLANE3	equ	yes
ENABLE_PLANE4	equ	yes

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

*********
* ISRs  *
*********
new_vbl		move.w	#$2700,sr		;stop ISRs
		movem.l	d0-d7,-(sp)
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		move.l	d0,-(sp)
		move.w	#$57e,d0
.aaa		dbf	d0,.aaa
		clr.b	$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w
		move.l	(sp)+,d0

		clr.w	vsync_flag
		clr.b	TBCR.w
		move.b	#1,TBDR.w
		move.w	#200,timerb_line_count
		move.b	#8,TBCR.w

		move.l	a0,-(sp)
		move.l	raster_pos,a0
		move.w	(a0)+,$300.w
		move.l	a0,raster_pos
		move.l	#rast_colours,raster_pos
		move.l	(sp)+,a0

		tst.w	zero_counter
		bne.s	.dec
		rte
.dec		sub.w	#1,zero_counter
		rte


timerb_line_count	dc.w	0

SCROLLER_COLOUR	equ	$ffff8242


new_timerb	move.w	$300.w,$ffff8240.w
		sub.w	#1,timerb_line_count
		beq	.set_scroller_timerb
		movem.l	d6/a6,-(sp)
		move.l	raster_pos,a6
		move.w	(a6)+,$300.w
		move.l	a6,raster_pos
		movem.l	(sp)+,d6/a6
		rte

.set_scroller_timerb
		move.w	pic+2,$ffff8240.w
		clr.b	TBCR
		dcb.w	117,$4e71	;wait with some NOPs
		movem.l	d0/a0/a1,-(sp)
		lea	colours(pc),a1	;do colours prior to border
		move.w	#27-1,d0
.loop		move.w	colours2-colours(a1),SCROLLER_COLOUR+2.w
		move.w	SCROLLER_COLOUR+2.w,SCROLLER_COLOUR+4.w
		move.w	(a1)+,SCROLLER_COLOUR.w
		dcb.w	111,$4e71
		dbf	d0,.loop

		dcb.w	89,$4e71	;wait with some NOPs

;We have now reached the last line on the screen so we have to open the
;lower border...
;
;This takes careful timing so don't change these DCB.W instructins

		clr.b	$ffff820a.w	;60Hz

		dcb.w	18,$4e71	;wait a while
	
		move.b	#2,$ffff820a.w	;50Hz

		move.w	#DEPTH-1,d0	;do some more colours
.loop2		move.w	colours2-colours(a1),SCROLLER_COLOUR+2.w
		move.w	SCROLLER_COLOUR+2.w,SCROLLER_COLOUR+4.w
		move.w	(a1)+,SCROLLER_COLOUR
		dcb.w	111,$4e71	;wait with some NOPs
		dbf	d0,.loop2
		movem.l	(sp)+,d0/a0/a1
		rte



	IFEQ	DOWNLOAD
******************************
	SECTION DATA
******************************
	ENDC


colour_offset	dc.w	0

colours
 dc.w	$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$08f
 dc.w	$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff,$080,$010
 dc.w	$090,$020,$0a0,$030,$0b0,$040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0,$8f0,$1f0,$9f0
 dc.w	$2f0,$af0,$3f0,$bf0,$4f0,$cf0,$5f0,$df0,$6f0,$ef0,$7f0,$ff0,$ff0,$ff0

colours2
 dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,$200,$a00,$300,$b00,$400,$c00,$500,$d00,$600,$e00,$700,$f00
 dc.w	$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$ff0,$ff0
 dc.w	$f78,$fe1,$f69,$fd2,$f5a,$fc3,$f4b,$fb4,$f3c,$fa5,$f2d,$f96


scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "           ADRENALIN COMPACT DISK 28.   "
 DC.B "CREDITS FOR THIS DISK ARE AS FOLLOWS....   CODING BY   SPACEMAN SPIFF, "
 DC.B "   GRAFIX BY  BIOFEEDBACK,   MUSIC FROM CRONICLES MUSIC DEMO, "
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
 dc.B "HELLO GUYS THIS IS SPACEMAN SPIFF ON THE KEYBOARD, AS YOU "
 DC.B "CAN SEE I'VE ADDED SOME RASTER BARS TO THIS BORING MENU AS "
 DC.B "MOOKIE WAS COMPLAINING THAT I HADN'T DONE ANYTHING FOR AGES. "
 DC.B "       SO WHAT IS IT THAT HAS STOPPED ME WRITING MENUS?   WELL "
 DC.B "I RECENTLY BOUGHT A MODEM FROM A RADIO RALLY AND I'VE "
 DC.B "BEEN RECODING SOME ANCIENT BBS SOFTWARE SO I CAN GET A BBS GOING. "
 DC.B "   IF ANYONE OUT THERE HAS SOME DECENT SOFTWARE TO RUN A BBS THEN "
 DC.B "SEND IT TO THE USUAL ADDRESS.      THE MODEM I BOUGHT SUPPORTS "
 DC.B "ALL SPEEDS UPTO 9600 (NOT V42 BIS THOUGH) AND HAS ERROR "
 DC.B "CORRECTION UPTO MNP 5 BUT ONLY AT 4800 BAUD.  IT IS AN AUTOANSWER, "
 DC.B "AUTOBAUD/DIAL ONE AND IT COMFORMS TO MOST OF THE HAYES COMMANDS. "
 DC.B "     IF I EVER GET IT GOING I'LL RELEASE A PHONE NUMBER FOR "
 DC.B "YOU TO CALL....        WELL WHERE ARE ALL THE GAMES?      I'VE "
 DC.B "HAD BUGGER ALL FOR AGES NOW, THE LAST DECENT ONE WAS VROOM DATA "
 DC.B "DISK 2! I SUPPOSE I'LL HAVE TO WAIT UNTIL XMAS TO GET SOMETHING "
 DC.B "DECENT.            WELL THAT'S ALL I'VE GOT TO SAY AS MOOKIE "
 DC.B "WANTS MORE MENU CODE AND I'VE GOT SOME STUFF TO FILE SO IT'S "
 DC.B "GOODBYE FROM SPACEMAN SPIFF.                        "
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


****************************************************************
player	INCBIN 'BLIPBLOP.ROT'
	even
song	INCBIN 'song3'
****************************************************************

		even

pic		incbin	pic.pi1		;main menu pic
		dcb.b	160*50,0

logo		incbin	logo.pi1


raster_path	incbin	RASTER.PTH

colour_bar
 dc.w	$00f,$206,$405,$602,$f00,$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40


rast_colours	dcb.w	200,0
		dc.w	0000	;null byte due to the way I did it



screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"aeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb"
	dc.b	"g              ADRENALIN 28            h"
	dc.b	"g                                      h"
	dc.b	"g       1: ISHAR - LEGEND OF THE       h"
	dc.b	"g       2: ISHAR CHARACTER EDITOR      h"
	dc.b	"g       3: ISHAR DOCS                  h"
	dc.b	"g       4: ESCAPADE DOCS               h"
	dc.b	"g       5: PIC SWITCH DOCS             h"
	dc.b	"g       6: A320 AIRBUS DOCS            h"
	dc.b	"g       7: ALCATRAZ DOCS               h"
	dc.b	"g       8: SENSIBLE SOCCER DOCS        h"
	dc.b	"g             0: 50/60 HZ              h"
	dc.b	"dffffffffffffffffffffffffffffffffffffffc"
	even

screen_titles_font	incbin	6x6_font.dat
	even

ripple_table_pos	dc.l	init_ripple_table
init_ripple_table

ripple_table		incbin	sine1.dat
			incbin	sine1.dat
			incbin	sine2.dat
			incbin	sine3.dat
reset_ripple_flag	incbin	sine1.dat


********** valid key press table
key_codes		;comment out keys you don't want to use
	dc.w	2,0	;key 1
	dc.w	3,1	;key 2
	dc.w	4,2	;key 3
	dc.w	5,3	;key 4
	dc.w	6,4	;key 5
	dc.w	7,5	;key 6
	dc.w	8,6	;key 7
	dc.w	9,7	;key 8
	dc.w	10,8	;key 9

	dc.w	$6d,0	;keypad 1
	dc.w	$6e,1	;keypad 2
	dc.w	$6f,2	;keypad 3
	dc.w	$6a,3	;keypad 4
	dc.w	$6b,4	;keypad 5
	dc.w	$6c,5	;keypad 6
	dc.w	$67,6	;keypad 7
	dc.w	$68,7	;keypad 8
	dc.w	$69,8	;keypad 9

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
		dc.l	filename9


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
filename9	dc.b	"",0
	even



	IFEQ	DOWNLOAD
*************************
	SECTION BSS	
*************************
	ENDC
bss_start
user_stack	ds.l	1

old_base	ds.l	1		;old screen address
old484		ds.w	1
stack_save	ds.l	1

old_pal		ds.b	32		;old colours

zero_counter	ds.w	1
screen_number	ds.w	1
present_base	ds.l	1
last_base	ds.l	1
screen_1	ds.l	1
screen_2	ds.l	1
vsync_flag	ds.w	1

old70		ds.l	1
old_timerb	ds.l	1
olda07		ds.b	1
olda09		ds.b	1
olda0d		ds.b	1
olda15		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda1d		ds.b	1
olda21		ds.b	1
save0f		ds.b	1
save11		ds.b	1
save13		ds.b	1
	even
path_ptr		ds.w	1

raster_pos		ds.l	1

black			ds.b	32	;32 bytes of nothing...

char_offset		ds.w	1

org_rez			ds.b	1	;original rez
		even
hertz_switch		ds.w	1	;hertz toggle check


ripple_data		ds.b	(RIPPLER_WIDTH*2*RIPPLER_DEPTH)*16
ripple_end
	even

	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	49152		;two screens
	ds.b	49152
bss_end

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC

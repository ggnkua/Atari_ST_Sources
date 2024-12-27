*************************************************************************
*				P.O.V. 121				*
*				----------				*
*									*
* Written By MACHINE SYSTEM DATA of PERSISTENCE OF VISION		*
* Date: 11/8/92								*
*									*
* All code ½ P.O.V. 1992						*
* 									*
*************************************************************************

BORDER_COLOUR=0		;Change this for border colours

	opt	o+,w-


YES=1
NO=0

AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here
		;If AUTORUN4 is used you can exit to the desktop to
		;double click a program or use the POV autogem/d_click.prg


TO_DISC=NO	;removes unwanted code for disc version

***************************
	SECTION TEXT
***************************
	IFNE	TO_DISC
	opt	d-
	ENDC

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

	bsr	clear_bss
	bsr	set_super		;set supervisor mode
	move.b	#$12,$fffffc02.w	;Disable mouse
	bsr	save_pal		;save old palette
	bsr	get_base		;get present screen base
	bsr	get_rez
	bsr	black_out		;make all colours black
	bsr	calc_screen		;calc our own screen address
	move.l	screen_1,a0		;new screen base
	bsr	set_low_rez		;go into low rez
	move.l	screen_1,present_base
	move.l	screen_2,last_base
	bsr	shift_bob
	move.b	$484.w,old484		;save keyboard click/speed, etc
	clr.b	$484.w			;disable repeat/click/bell

	moveq	#1,d0
	bsr	tune

	bsr	do_bob
	bsr	flip_screen
	bsr	set_palette		;set new colours
	bsr	set_for_border		;knock out lower border
	bsr	show_pic
	bsr	flush			;flush keyboard buffer
main_loop
	bsr	vsync
	bsr	flip_screen
;	move.w	#$070,$ffff8240.w
	bsr	return_screen
	bsr	do_bob
	bsr	scroll
	bsr	sort_border_rasters
;	move.w	pic+2,$ffff8240.w

	move.w	key,d0

	IFEQ	TO_DISC			;keep if assem to memory
	cmp.w	#1,d0			;escape?
	beq	exit			;yes get out...
	ENDC

	IFNE	TO_DISC			;for final version enable SPACE to exit
	cmp.w	#$39,d0			;for ANIMAL MINE DISCS.
	beq	exit
	ENDC

	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero

	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
	beq	reset

	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	main_loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run	lsr.w	#8,d1
	and.w	#$f,d1
	lsl.w	#2,d1
	lea	filename_table,a0
	move.l	(a0,d1.w),a0
	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

	bsr	vsync			;shut the interrupts down
	move.w	sr,-(sp)
	move.w	#$2700,sr		;quick before she blows up!!
	move.l	old70,$70.w
	move.l	old_118,$118.w
	move.l	old_timerb,$120.w

	moveq	#0,d0
	bsr	tune

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	move.w	(sp)+,sr

	move.l	old_base,a0		;put screen back to original
	bsr	set_org_rez		;go org rez for assembler/desktop
	bsr	restore_pal		;restore colours
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer

*** now check hertz and exit cleanly...
	tst.w	hertz_switch		;has hertz been pressed?
	beq.s	hz50			;no so it stays in 50Hz
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50	move.b	#8,$fffffc02.w		;mouse back on

	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	ifeq	AUTORUN4
	bra	exec
	ELSE

	clr.w	-(sp)		;exit to desktop
	trap	#1
	ENDC


zero	tst.w	zero_counter
	bne	main_loop
	eor.w	#$003,bor+2		;show a hertz change
	eor.w	#$ffff,hertz_switch	;toggle a check
	move.w	#10,zero_counter	;delay in between hertz switches
	bra	main_loop

reset	move.l	4.w,-(sp)
	rts


exit	bsr	vsync			;shut the interrupts down
	move.w	sr,-(sp)
	move.w	#$2700,sr		;quick before she blows up!!
	move.l	old70,$70.w
	move.l	old_118,$118.w
	move.l	old_timerb,$120.w

	moveq	#0,d0
	bsr	tune

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	move.w	(sp)+,sr

	move.l	old_base,a0		;put screen back to original
	bsr	set_org_rez		;go org rez for assembler/desktop
	bsr	restore_pal		;restore colours
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer

	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			;assembler/desktop
	trap	#1			;BYE!


***************
* Subroutines *
***************

DEPTH	equ	32

scroll	move.l	last_base,a1
	add.l	#(160*201),a1		;into border
	lea	font_offsets,a2		;font lookup table
	lea	font,a3			;font itself
	move.l	scroll_pointer,a4	;pointer into text
	move.l	a4,a5

	moveq	#40,d5			;40 words across screen
	move.w	char_offset,d6		;char offset is a toggle
					;for bytes/words
	moveq	#0,d4
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0	;find correct offset
	lsl.w	#7,d0
	add.w	d0,a0		;add to font start
	move.w	d6,d0		;char offset
	lsl.w	#5,d0
	add.w	d0,a0		;we now point to character in A0

** this bit prints 1 byte wide blocks of the font, this method makes
** it possible to redraw the scroller every screen refresh and makes
** it so the we do not have to shift the scroller. The bad part is that
** it scrolls bloody fast at 8 bits every screen refresh.

.column
OFF	set	0
	REPT	DEPTH
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160		;go down a line
	ENDR

	subq.w	#1,d5		;column value
	beq.s	.finish		;last column then finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next byte
	addq.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)		;is scroll text end?
	bpl.s	.end		;NO!
	lea	scroll_text,a4	;reset scroll text
.end	move.l	a4,scroll_pointer
	rts


sort_border_rasters
		move.w	raster_offset,d0
		lea	colours,a0
		lea	scroller_rasters,a1
UP		set	34
DOWN		set	32
		REPT	DEPTH/2+1
		move.w	0(a0,d0.w),UP(a1)
		move.w	0(a0,d0.w),DOWN(a1)
UP		set UP-2
DOWN		set DOWN+2
		addq.w	#2,d0
		and.w	#127,d0
		ENDR
		addq.w	#2,raster_offset
		rts






return_screen	move.l	last_position,d0
		move.l	present_base,a0
		add.w	d0,a0
		lea	pic+34,a1
		add.w	d0,a1
		REPT	39
		movem.l	(a1),d0-d7/a2-a6
		movem.l	d0-d7/a2-a6,(a0)
		lea	160(a0),a0
		lea	160(a1),a1
		ENDR
		rts


;
; This bob rout calculates the bob position by adding 2 seperate
; sine tables together. If used with multiple bobs this will make the
; bob 'float' around the screen instead of tracking a pre-determined path
;

do_bob	lea	table_pos1,a6
	lea	table_pos2,a5
	bsr.s	do
;	lea	table_pos3,a6		;use this for NON tracking multiple bobs
;	lea	table_pos4,a5
;	bsr	do
	rts

do	move.l	(a6),a0
	cmp.w	#-1,(a0)
	bne.s	.no_reset
	lea	sine1,a0
.no_reset
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.w	(a0)+,d0	;word/offset
	move.w	(a0)+,d1	;y offset (post*160)
	move.l	a0,(a6)
	move.b	d0,d2
	move.l	d0,d5

	move.l	(a5),a0
	cmp.w	#-1,(a0)
	bne.s	.no_reset2
	lea	sine2,a0
.no_reset2
	moveq.l	#0,d0
	move.w	(a0)+,d0	;word/offset
	add.w	(a0)+,d1	;y offset (post*160)
	move.l	a0,(a5)
	add.b	d0,d2
	add.w	d5,d0
	lsr.w	#4,d0		;word offset 
	lsl.w	#3,d0		;*8
	add.w	d1,d0

	move.l	last_base,a0
	add.w	d0,a0
	move.l	d0,last_position
	lea	bob,a1		;grafix
	and.w	#$f,d2
	mulu	#(8*6*39),d2
	add.w	d2,a1		;grafix
	add.w	d2,a1		;mask
	lea	8*6*39(a1),a2	;masks
	move.w	#39-1,d7
.loop	REPT	6
	move.l	(a2)+,d1	;mask data
	move.l	(a0),d0		;screen data
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+

	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	ENDR
	add.w	#160-(6*8),a0

	dbf	d7,.loop
	rts

********************
* SERVICE ROUTINES *
********************

flip_screen	;flip between 2 screens to stop bob flickering
	move.l	present_base,last_base
	move.l	screen_1,a0
	move.w	screen_number,d0
	beq.s	.1
	move.l	screen_2,a0
.1	move.l	a0,present_base
	eor.w	#-1,screen_number
	move.l	a0,d0
	lsr.l	#8,d0
	lea	$fffff8201.w,a0
	movep.w	d0,(a0)
	rts


flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts


vsync	move.w	#$ffff,vsync_flag	;custom routine to wait
vs	tst.w	vsync_flag		;for screen refresh
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


save_pal			;save old colours
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


restore_pal			;put back original colours
	lea	old_pal,a0
	bra.s	set_p

set_palette
	lea	pic+2,a0
set_p	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts


get_base			;get org screen address
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts


get_rez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,org_rez
	rts


calc_screen	;calc our own screen address...
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_1
	add.l	#40192,d0
	move.l	d0,screen_2
	rts


set_med_rez
	move.w	#1,-(sp)
	bra.s	set_rez
set_org_rez
	move.w	org_rez,-(sp)
	bra.s	set_rez
set_low_rez
	clr.w	-(sp)
set_rez
	move.l	a0,-(sp)	;screen address is in A0
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


show_pic			;show the pic
	lea	pic+34,a0
	move.l	present_base,a1

	lea	32000-160(a0),a2
	lea	32000-160(a1),a3

	move.w	#200/2-1,d7
.loop	bsr	vsync
	movem.l	(a0),d0-d6	;28 bytes
	movem.l	d0-d6,(a1)
	movem.l	28(a0),d0-d6	;56
	movem.l	d0-d6,28(a1)
	movem.l	56(a0),d0-d6	;84
	movem.l	d0-d6,56(a1)
	movem.l	84(a0),d0-d6	;112
	movem.l	d0-d6,84(a1)
	movem.l	112(a0),d0-d6	;140
	movem.l	d0-d6,112(a1)
	movem.l	140(a0),d0-d4	;160
	movem.l	d0-d4,140(a1)
	lea	320(a0),a0
	lea	320(a1),a1

	movem.l	(a2),d0-d6	;28 bytes
	movem.l	d0-d6,(a3)
	movem.l	28(a2),d0-d6	;56
	movem.l	d0-d6,28(a3)
	movem.l	56(a2),d0-d6	;84
	movem.l	d0-d6,56(a3)
	movem.l	84(a2),d0-d6	;112
	movem.l	d0-d6,84(a3)
	movem.l	112(a2),d0-d6	;140
	movem.l	d0-d6,112(a3)
	movem.l	140(a2),d0-d4	;160
	movem.l	d0-d4,140(a3)
	lea	-320(a2),a2
	lea	-320(a3),a3
	dbf	d7,.loop

	move.l	present_base,a0		;copy to second screen
	move.l	screen_2,a1		;for flip screen
	move.w	#32000/4-1,d1
copy	move.l	(a0)+,(a1)+
	dbf	d1,copy
	rts


black_out				;all colours black
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts


v_sync	movem.l	d0-d3/a0-a3,-(sp)	;ROM wait for screen update
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts


clear_bss
	lea	bss_start,a0
.clear	clr.l	(a0)+
	cmp.l	#bss_end,a0
	blt.s	.clear
	rts


set_for_border			;save old interrupt values
		ori.w	#$700,sR
		move.l	$70.W,old70
		move.l	$118.w,old_118
		move.l	$120.W,old_timerb
		move.b	$fffffa07.W,olda07
		move.b	$fffffa09.W,olda09
	 	move.b	$fffffa17.W,olda17
		move.b	$fffffa1b.W,olda1b
		move.b	$fffffa21.W,olda21
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w

		move.l	#new_70,$70.w		;set new interrupt values
		move.l	#new_kbd,$118.w
		move.l	#new_timerb,$120.w

		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w		;auto ISR enable at RTE
		clr.b	$fffffa1b.w		;stop timerb
		clr.b	$fffffa21.w		;clear timerb data
		move.w	#$2300,SR
		rts				;ISRs are now running



shift_bob	lea	bob,a1
		move.w	#16-1,d7
shift_loop	lea	bob_pic+34,a0
		move.l	a0,a6
		addq.w	#8,a0
		move.w	#39-1,d2
repeat
OFF	set	0
		REPT 6			;6 words
		move.l	OFF(a0),(a1)+
OFF	SET OFF+4
		move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	ENDR
		add.w	#160,a0
		dbf	d2,repeat

	add.w	#160*8,a0
	move.w	#39-1,d2
repeat2
OFF	set	0
	REPT 6				;6 words
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	ENDR
	add.w	#160,a0
	dbf	d2,repeat2
	move.l	a6,a0
	move.w	#39+39+8-1,d6
.loop	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	addq.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	addq.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	addq.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	addq.w	#2,a0
	subq.w	#8,a0
	add.w	#160,a0
	dbf	d6,.loop
	dbf	d7,shift_loop
	rts




new_kbd	movem.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,d0
	rte

*********
* ISRs  *
*********
new_70	;every screen update...
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7		;set colours after isr
	movem.l	d0-d7,$ffff8240.w
	bsr	tune+6
	clr.w	vsync_flag		;own screen update rout
	tst.w	zero_counter
	beq.s	.clear
	subq.w	#1,zero_counter
.clear	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#199,$fffffa21.w	;next interrupt to occur 199 lines down
	move.b	#8,$fffffa1b.w		;set interrupt method
	rte				;let's leave before interrupt occurs


new_timerb
	clr.b	$fffffa1b.w	;DI all other interrupts
ll	tst.b	$fffff8209.w
	bne.s	ll
	clr.b	$ffff820a.w	;60 hertz

	movem.l	d0/a0/a1,-(sp)	;save regs
	move.w	#DEPTH-1,d0	;set up D0 here to save time later
	lea	scroller_rasters,a0	;colours for spectrum anal

lll	tst.b	$fffff8209.w
	bne.s	lll

	move.w	#DEPTH-1,d0

	move.b	#2,$ffff820a.w	;back to 50 hertz

bor	move.w	#BORDER_COLOUR,$ffff8240.w	;hertz color show

**** WOW dudes we are in the lower border.......

.loop	move.w	(a0)+,$ffff8242.w	;show colours in scroll
	REPT	113+8
	nop
	ENDR
	dbf	d0,.loop
	movem.l	(sp)+,d0/a0/a1
	rte

******************************
	SECTION DATA
******************************

colours	dc.w	$200,$300,$400,$500,$600,$700,$710,$720
	dc.w	$730,$740,$750,$760,$770,$670,$570,$470
	dc.w	$370,$271,$172,$073,$074,$075,$076,$077
	dc.w	$067,$057,$047,$037,$027,$017,$007,$106
	dc.w	$205,$304,$403,$502,$601,$700,$710,$720
	dc.w	$730,$740,$750,$760,$770,$671,$572,$473
	dc.w	$374,$275,$176,$077,$167,$257,$347,$437
	dc.w	$527,$617,$707,$706,$705,$604,$503,$402

scroll_pointer	dc.l	scroll_text
scroll_text
 dc.b "                    "
 dc.b "WELCOME TO PERSISTENCE OF VISION DISC 121.        "
 dc.b "CREDITS:      MENU CODED BY MAC SYS DATA,   "
 dc.b "GRAFIX BY OZ AND MUSIC BY FRAZOR.  "
 dc.b "RELEASE DATE 16 AUGUST 1992.     "
 DC.B "   OLD MENU CODE USING A PICTURE THAT IS AT LEAST 12 MONTHS OLD!   "
 DC.B "YES ONCE AGAIN I'VE USED OLD MENU CODE ALTHOUGH THE BOB ROUTINE AND "
 DC.B "BORDER CODE HAS BEEN RE-WRITTEN.      THIS IS MAC SYS DATA AT THE "
 DC.B "KEYBOARD ATTEMPTING TO ADD SOME HUMEROUS TEXT BUT FAILING "
 DC.B "MISERABLY.      THIS MENU WAS KNOCKED TOGETHER BECAUSE ALL MY "
 DC.B "NEW MENUS HAVE BEEN USED BY ANOTHER CREW AND I PROMISED NOT "
 DC.B "TO USE THE SAME MENU ON BOTH.   THE ONLY PROBLEM IS THAT I "
 DC.B "HAVE TO CODE TWICE AS MANY MENUS TO KEEP BOTH CREWS GOING. "
 DC.B "   I CAN'T TELL YOU THE NAME OF THE CREW I JOINED 'COS IT'S A "
 DC.B "SECRET BUT I THINK IT WILL BE OBVIOUS WHEN YOU SEE THEIR MENUS. "
 DC.B "         HAVE YOU ALL SENT YOUR INVITATIONS TO THE GREAT BRITISH "
 DC.B "INTERNATIONAL ST PARTY OFF?     IF YOU DON'T KNOW WHAT I'M "
 DC.B "TALKING ABOUT THEN LISTEN UP.....  THERE IS GOING TO BE THE BIGGEST "
 DC.B "CODING PARTY EVER HELD IN THE UK AT THE START OF SEPTEMBER 1992.  "
 DC.B "NEARLY ALL THE UK CREWS ARE GOING INCLUDING P.O.V., IT IS BEING "
 DC.B "HELD IN THE NORTH OF ENGLAND AND IS BEING ORGANISED BY OUR "
 DC.B "FRIENDS 'RIPPED OFF'.     IF YOU'RE GOING I'LL SEE YOU THERE, IF "
 DC.B "YOU AIN'T GOING THEN LOOK OUT FOR THE CODING PARTY DEMO.   "
 DC.B "   MOST CREWS ARE DOING SCREENS FOR THE DEMO BUT I'VE NO TIME TO WRITE ONE "
 DC.B "SO UNFORTUNATELY NO SCREEN FOR US  "
 DC.B "      I'LL BE TAKING LOADS OF PHOTOS WHEN I'M THERE "
 DC.B "SO A FEW FACES MAY APPEAR ON P.O.V. DISCS AS SOON AS I GET "
 DC.B "MY AMIGA FIXED SO I CAN USE MY DIGITIZER.        "
 DC.B "TODAY I'VE UPGRADED MY HARD DISC, I'VE REMOVED MY 45 MEG MECHANISM "
 DC.B "AND REPLACED IT WITH A 120 MEG ONE.   THE NEW DRIVE IS ONLY 1 INCH "
 DC.B "HIGH, 6 INCHES LONG AND JUST OVER 3.5 INCHES WIDE.   THE NEW DRIVE "
 DC.B "IS VERY QUIET AND TRANSFERS DATA AT 968K A SECOND. IT HAS A "
 DC.B "64K BUILT IN CACHE AND A SEEK SPEED OF 15 MS WHICH IS VERY FAST.   "
 DC.B "I MODIFIED MY HARD DISC CASE AND CONNECTIONS BY ADDING A "
 DC.B "SWITCH TO THE FAN AS THE NEW MECHINISM DOESN'T GET AS HOT AS THE OLD ONE. "
 DC.B "               ***** IMPORTANT MESSAGE TO ST-USER *****    "
 DC.B "  REVIEW SOME DEMOS YA BASTARD, IF A DEMO DOESN'T HAVE A FANCY "
 DC.B "PICTURE AND A SAMPLED SOUND YOU SLAG IT OFF.   IF A CODER HAS "
 DC.B "KNOCKED OUT ALL BORDERS, ADDED A TRACKER AND 300 COLOURS YOU "
 DC.B "SLAG IT OFF!    CAN YOU DO BETTER?          I DON'T THINK SO!  "
 DC.B "     I SEE ST-FORMAT (A TOTALLY BETTER MAGAZINE) REVIEWED "
 DC.B "QUITE A FEW DEMOS IN THEIR LATEST EDITION.      WHY DOES "
 DC.B "ST-USER REVIEW SHITTY UTILITIES WRITTEN IN HI-SOFT BASIC THAT "
 DC.B "DO BUGGER ALL EXCEPT EXECUTE SIMPLE TASKS AND STILL GIVE THEM "
 DC.B "99 PERCENT?    APPROX 90 PERCENT OF THE UTILITIES ARE OVER 20K "
 DC.B "AND PERFORM CRAP ROUTINES, THE SAME PROGRAM COULD BE WRITTEN IN "
 DC.B "MACHINE CODE IN UNDER 2K.       COME ON ST-USER GET TO GRIPS "
 DC.B "WITH THE REAL WORLD AND SACK YOUR CRAP STAFF. THE ADVICE YOU "
 DC.B "GIVE TO PEOPLE IN YOUR LETTERS PAGE IS CRAP.  THE BLOKE "
 DC.B "OBVIOUSLY DOESN'T KNOW A THING ABOUT AN ST, HE PROBABLY DOESN'T "
 DC.B "EVEN HAVE ONE.  I THINK ALL ST-USER STAFF ARE DUMB MOTHER F*****S "
 DC.B "WHO IF THEY GOT HOLD OF AN ST WOULD ONLY USE IT FOR RUN "
 DC.B "CRAP MIDI PROGRAMS, 1ST WORD AND DTP CRAP. THE ATTITUDE OF 'WELL "
 DC.B "WE TAKE THE ST SERIOUSLY' IS A LOAD OF BOLLOCKS, THE ST IS "
 DC.B "CAPABLE OF DOING A LOT MORE THAN 'SERIOUS' STUFF AND MOST PEOPLE "
 DC.B "DON'T BOTHER WITH ANYTHING BUT DEMOS AND GAMES.  THE MAGAZINES SEEM TO PLACE USERS "
 DC.B "IN 1 OF 3 CATAGORIES ---  1... THE GAMES PLAYER, A PERSON WITH "
 DC.B "LOADS OF MONEY WHO CAN GO OUT AND SPEND 200 POUNDS A MONTH ON "
 DC.B "CRAP GAMES THAT EVEN MY ZX SPECTRUM WOULD SHOW UP.    "
 DC.B "2... THE 'SERIOUS' USER, A PERSON WHO HAS BUILT HIS SOFTWARE COLLECTION "
 DC.B "UP SO HE HAS ALL DTP AND MIDI PROGRAMS AVAILABLE AND NEVER, "
 DC.B "EVEN USES IT FOR ANYTHING ELSE.    3... THE WEIRD ONES, PEOPLE WHO "
 DC.B "SIT IN FRONT OF THEIR ST'S ALL NIGHT USING THEM TO WRITE 'USELESS' "
 DC.B "PROGRAMS IN ASSEMBLY. THESE PEOPLE ARE SCUM 'COS THEY ARE ALL "
 DC.B "HACKERS WHO ARE RIPPING THE SOFTWARE COMPANIES OFF AND KILLING THE "
 DC.B "ST.       WELL I THINK I'M IN CATAGORY 3.   I AM NOT A HACKER AND "
 DC.B "I DON'T SIT IN FRONT OF MY ST ALL NIGHT.   I USE MY ST FOR WRITING "
 DC.B "LETTERS, I USE A DTP FOR PRINTING LABELS AND I CODE MENUS, PACK DEMOS "
 DC.B "'COS I LIKE A CHALLENGE. MY COMPUTER IS A HOBBY LIKE SOME PEOPLE "
 DC.B "COLLECT STAMPS.   SO ST-USER PULL YOUR HEAD FROM UP YOU'RE ARSES AND TAKE "
 DC.B "A LOOK AROUND.    IF YOU WANT TO RESPOND TO THIS TEXT PLEASE WRITE TO "
 DC.B "THE USUAL PO BOX NUMBER GIVEN LATER ON....        "
 DC.B "ONE THING TO NOTE....  I HAVE A 4 MEG RAM STE, A 200 MEG HARD DRIVE, A PHILIPS "
 DC.B "CM8833 MONITOR AND A STAR LC24-20 PRINTER.     HOW MANY 'SERIOUS' "
 DC.B "USERS CAN MATCH THAT?     IF I'M KILLING THE ST SCENE I'M GOING "
 DC.B "ABOUT IT IN A FUNNY WAY!       "
 DC.B "OKAY I'LL GIVE YOU SOME TIME TO GET A PEN, MEAN WHILE HERE ARE "
 DC.B "THE GREETINGS, HI TO..     "
 DC.B "ADRENALIN,   "
 DC.B "ANIMAL MINE,   "
 DC.B "BLIND BASTARD,   "
 DC.B "CYNIX,   "
 DC.B "D-BUG,   "
 DC.B "DELTA FORCE,   "
 DC.B "DR SYNE,   "
 DC.B "ERIK PLANKTON,   "
 DC.B "EQUINOX,   "
 DC.B "FUSION,   "
 DC.B "GENESIS INC.,   "
 DC.B "GEORGE (BART),   "
 DC.B "INNER CIRCLE,   "
 DC.B "JSD,   "
 DC.B "KGB,   "
 DC.B "MAD VISION,   "
 DC.B "MUG UK,   "
 DC.B "NEXT,   "
 DC.B "NOD,   "
 DC.B "PAL PD,   "
 DC.B "PIXEL TWINS,   "
 DC.B "POMPEY PIRATES,   "
 DC.B "PROPHECY PD,   "
 DC.B "PURE ENERGY,   "
 DC.B "REPLICANTS,   "
 DC.B "RIPPED OFF,   "
 DC.B "SEWER SOFTWARE,   "
 DC.B "SLAYTANIC CULT,   "
 DC.B "ST CNX,   "
 DC.B "STRANGER,   "
 DC.B "TCB,   "
 DC.B "THE SOURCE,   "
 DC.B "THE SYNDICATE,   "
 DC.B "UNITY,   "
 DC.B "UTOS   AND   "
 DC.B "WILD!          "
 DC.B "OK HERE IS THE ADDRESS..      WRITE TO      P.O.V.,            "
 DC.B "P.O. BOX 40,            THORNTON-CLEVELEYS,            LANCASHIRE,"
 DC.B "            FY5 3PH,            UK.               I WON'T REPEAT "
 DC.B "IT, IF YOU WANT TO SEE IT AGAIN THEN I SUGGEST YOU UNPACK THE FILE "
 DC.B "AND USE A DISC EDITOR OR DISASSEMBLER.            "
 DC.B "I GOTTA GO AS I'M HALF WAY THROUGH WRITING 2 NEW MENUS."
 DC.B "                                                  "
 DC.B "                                                  "
 DC.B "                                                  "
 DC.B "                                                  "
 DC.B "                                                  "
 dc.b $ff
	even


font	dcb.b	DEPTH*4,0
	incbin	1plane.fnt


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


tune	incbin	digi.mus
	even

pic	incbin	pic.PI1			;main menu pic

bob_pic		incbin	bob.pi1
last_position	dc.l	0
table_pos1	dc.l	sine1
table_pos2	dc.l	sine2
sine1		incbin	sine1.dat
		dc.w	$ffff,$ffff
		even
sine2		incbin	sine2.dat
		dc.w	-1,-1
		even

table_pos3	dc.l	sine1+(4*12)
table_pos4	dc.l	sine2

********** valid key press table
demo_keys	;comment out keys you don't want to use
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5
		dc.l	filename6
		dc.l	filename7
		dc.l	filename8
		dc.l	filename9


*** filenames no longer need to be 16 bytes long but must end
*** in 0 and must be on an even address...
****
**** If using POV AUTORUN and you wish to exit to the desktop simply
**** start the filename off with $$
****

filename1	dc.b	"FUSION",0
	even
filename2	dc.b	"KGBINTRO",0
	even
filename3	dc.b	"DNT",0
	even
filename4	dc.b	"P_DOME_1",0
	even
filename5	dc.b	"P_DOME_2",0
	even
filename6	dc.b	"MAGGIE_9",0
	even
filename7	dc.b	"COPIER.POV",0
	even
filename8	dc.b	"filename.ext",0
	even
filename9	dc.b	"filename.ext",0
	even




*************************
	SECTION BSS	
*************************
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
key		ds.w	1

*** store for old ISR data
old70		ds.l	1
old_timerb	ds.l	1
old_118		ds.l	1
olda07		ds.b	1
olda09		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
	even

black			ds.b	32	;32 bytes of nothing...

raster_offset		ds.w	1

scroller_rasters	ds.w	DEPTH+8


char_offset		ds.w	1

org_rez			ds.w	1	;original rez
hertz_switch		ds.w	1	;hertz toggle check

	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	40192		;two screens
	ds.b	40192

bob	ds.b	59904

bss_end
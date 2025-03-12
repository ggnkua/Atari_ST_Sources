	opt	o+,w-
*************************************************************************
*				P.O.V. 93				*
*				---------				*
*									*
* Written By MACHINE SYSTEM DATA of PERSISTENCE OF VISION		*
* Date: 10/8/91								*
*									*
* All code ½ P.O.V. 1991						*
* 									*
*************************************************************************
BOB_DEPTH=72	;bob depth in pixels
BOB_WIDTH=9	;bob width in words

BORDER_COLOUR=0		;Change this for border colours
	bsr	set_super		;set supervisor mode
	move.l	#go,$24.w
go	move.b	#$12,$fffffc02.w	;Disable mouse
	bsr	save_pal		;save old palette
	bsr	get_base		;get present screen base
	bsr	get_rez
	bsr	black_out		;make all colours black
	bsr	calc_screen		;calc our own screen address
					;so we are not restricted
					;to a fixed screen address
					;512 + 1024K compatable

	move.l	screen_1,a0		;new screen base
	bsr	set_low_rez		;go into low rez
	move.l	screen_1,present_base
	move.l	screen_2,last_base
	bsr	shift_bob		;draw bob to screen and shift 16 times
	bsr	clear_below_screen	;clear area below screen
	move.b	$484,old484		;save keyboard click/speed, etc
	clr.b	$484			;disable repeat/click/bell

;************************************************************************
;*                            UNKNOWN                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 14/08/91 19:45                     *
;*      From: AUTOMATION disc 474                                       *
;* Include files:-                                                      *
;*                 474.IMG into TUNE                                    *
;************************************************************************
;* music by NIK ALDERTON

;****************************************************************
; There is more than one tune in this code....
; 0=off with music
; 1=tune 1
; 2=tune 2
; 3=tune 3
; 4=sound effect
; 5=sound effect
; 6=sound effect
; 7=sound effect
; 8=sound effect
; 9=sound effect

	move.l	#1,D0
	BSR	tune

	bsr	set_palette		;set new colours
	bsr	set_for_border		;knock out lower border
	bsr	show_pic
	bsr	flush			;flush keyboard buffer
main_loop
	bsr	flip_screen
	bsr	vsync
; 	move.w	#$123,$ffff8240.w
	bsr	return_screen
;	move.w	#$700,$ffff8240.w
	bsr	do_bob
;	move.w	#$070,$ffff8240.w
	bsr	scroll
;	move.w	#$707,$ffff8240.w
	bsr	clear_spec
;	move.w	#$321,$ffff8240.w
	bsr	calc_spec
;	move.w	pic+2,$ffff8240.w

	move.b	$fffffc02.w,d0

;	cmp.b	#01,d0			;escape?
;	beq	exit			;yes get out...

	cmp.b	#$b,d0			;0 key
	beq.s	zero


check_keys
	lea	key_codes,a6
.loop	cmp.b	#$ff,(a6)	;end of table?
	beq.s	main_loop	;yes
	cmp.b	(a6)+,d0	;is key one we want?
	beq.s	load		;yes so load demo
	move.b	(a6)+,d6	;NO so get offset
	bra.s	.loop		;check another key code


load	move.b	(a6),-(sp)	;store offset on stack for later use
	bsr	isr_off		;turn interrupts off
	move.l	old_base,a0	;put screen base back to original value
	bsr	set_low_rez	;go low rez (again?)
	bsr	black_out	;all black (where am I?)

	moveq	#0,d0		;clear D0.L
	move.b	(sp)+,d0	;get key value off stack

*** new piece of filename selector....
	lea	filename_table,a0
	lsl.w	#2,d0		;multiply D0 by 4 (one long word)
	add.w	d0,a0
	move.l	(a0),a1		;get filename address

*** now move filename into $200 for AUTORUN4 to find
	lea	$200.w,a0
	movem.l	(a1),d0/d1/d2/d3	;move 16 bytes
	movem.l	d0-d3,(a0)		;into $200


*** now check hertz and exit cleanly...
	tst.w	hertz_switch		;has hertz been pressed?
	beq.s	hz50			;no so it stays in 50Hz
	eor.b	#2,$ffff820a.w		;yes so go 60Hz
hz50	move.b	#8,$fffffc02.w		;mouse back on
	bsr	user_mode		;go user mode
	clr.w	-(sp)			;exit to next prog in AUTO folder
	trap	#1			;or desktop


zero	tst.w	zero_counter
	bne.s	check_keys
	eor.w	#$123,bor+2		;show a hertz change
	eor.w	#$ffff,hertz_switch	;toggle a check
	move.w	#10,zero_counter	;delay in between hertz switches
	bra	main_loop


exit	bsr	isr_off			;off with the interrupts
	move.l	old_base,a0		;put screen back to original
	bsr	set_org_rez		;go org rez for assembler/desktop
	bsr	restore_pal		;restore colours
	move.b	#8,$fffffc02.w		;mouse back on
	move.b	old484,$484.w		;keyclick, etc
	bsr	flush			;clear keyboard buffer
	bsr	user_mode		;use mode
	clr.w	-(sp)			;assembler/desktop
	trap	#1			;BYE!


***************
* Subroutines *
***************

******************************
*                            *
* Spectrum Analyser routines *
*                            *
******************************

MAX_BARS	equ	80
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
	move.l	last_base,a1
	add.l	#(160*204),a1
	moveq	#0,d0
	REPT	(20*26)
	move.w	d0,(a1)
	addq.w	#8,a1
	ENDR
	rts

calc_spec
	lea	spec_values,a0
	moveq	#(MAX_BARS-1),d0
.cnt_down
	tst.b	(a0)+
	beq.s	.next
	subq.b	#1,-1(a0)
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
	move.b	d2,(a2,d0)

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
	move.b	d2,(a2,d0)

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
	move.b	d2,(a2,d0)

******************** print speccy *******************
ps
	move.l	last_base,a0
	add.l	#32000+(16*160),a0

	lea	spec_values,a2
	move.w	#(80/4)-1,d1
.loop
	move.l	a0,a1
	lea	160(a0),a3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib2
		and.w	#15,d0
	move.b	#%11100000,d2
.loop1	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2	move.b	(a2)+,d0
	beq.s	.nib3
		and.w	#15,d0
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib4
		and.w	#15,d0
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%11100000,d2
.loop3	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nonib
		and.w	#15,d0
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%00001110,d2
.loop4	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4

.nonib	add.w	#8,a0
	dbf	d1,.loop
	rts


**************************************************


return_screen		;wipe over old bob
	move.l	mid_pos,d0
	move.l	last_position,mid_pos
	move.l	last_base,a0
	add.l	d0,a0
	lea	pic+34,a1
	add.l	d0,a1

*****************************************************************
***** Customized return bob routine for MINI_POV (saves CPU time)
*****************************************************************
* BOB is 10 words wide in 16 colours......

	REPT	9
	movem.l	24(a1),d0-d3
	movem.l	d0-d3,24(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR

	REPT	16
	movem.l	16(a1),d0-d7
	movem.l	d0-d7,16(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR

	REPT	17
	movem.l	8(a1),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,8(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR

	REPT	BOB_DEPTH-(9+16+17)
	movem.l	(a1),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a0)
	movem.l	48(a1),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,48(a0)
	movem.l	96(a1),d0-d5
	movem.l	d0-d5,96(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
	rts


* the bob path is a table of values with a Y offset and a X offset
* the table is calculated in FAST BASIC and the file created is
* INCBINed into the assembler. To change the table edit the SINE.BSC
* file and run it in FAST BASIC the output file is automatically
* made.

do_bob	move.l	table_pos,a0	;get position in SINE table
	cmp.w	#-1,(a0)	;is end of table?
	bne.s	.no_reset	;NO
	lea	sine,a0		;YES
	move.l	a0,table_pos
.no_reset
	moveq.l	#0,d0		;clear 3 registers
	move.l	d0,d1
	move.l	d0,d2

	move.w	(a0)+,d0	;get word/offset
	move.w	(a0)+,d1	;get y offset (post*160)
	move.l	a0,table_pos	;update SINE table pos

* Calculate the word offset across the screen...
	move.b	d0,d2
	lsr.w	#4,d0		;word offset 
	lsl.w	#3,d0		;*8

	add.w	d1,d0		;add to Y line offset
	move.l	last_base,a0
	add.w	d0,a0		;address on screen of bob

* store offset from screen base for clear bob routine later..
	move.l	d0,last_position


	lea	bob,a1		;grafix
	and.w	#$f,d2		;calculate which grafix to use (1 of 16)
	mulu	#(8*BOB_WIDTH*BOB_DEPTH),d2
	add.l	d2,a1		;add to first grafix
	add.l	d2,a1		;add again to get over mask

	lea	8*BOB_WIDTH*BOB_DEPTH(a1),a2	;find mask for that grafic


**************************************************
;  CUSTOM PRINT BOB ROUTINE FOR **MINI_POV** BOB
**************************************************
	REPT	9
	move.l	24(a2),d1	;get mask data
	move.l	24(a0),d0	;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	24(a1),d0	;put grafix into hole
	move.l	d0,24(a0)	;put grafix on screen

	move.l	28(a0),d0
	and.l	d1,d0		;same mask as first word
	or.l	28(a1),d0
	move.l	d0,28(a0)

	move.l	32(a2),d1	;get mask data
	move.l	32(a0),d0	;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	32(a1),d0	;put grafix into hole
	move.l	d0,32(a0)	;put grafix on screen

	move.l	36(a0),d0
	and.l	d1,d0
	or.l	36(a1),d0
	move.l	d0,36(a0)
	add.w	#BOB_WIDTH*8,a1
	add.w	#BOB_WIDTH*8,a2
	lea	160(a0),a0
	ENDR

	REPT	16
	move.l	16(a2),d1	;get mask data
	move.l	16(a0),d0	;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	16(a1),d0	;put grafix into hole
	move.l	d0,16(a0)	;put grafix on screen

	move.l	20(a0),d0
	and.l	d1,d0
	or.l	20(a1),d0
	move.l	d0,20(a0)

	move.l	24(a2),d1	;get mask data
	move.l	24(a0),d0	;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	24(a1),d0	;put grafix into hole
	move.l	d0,24(a0)	;put grafix on screen

	move.l	28(a0),d0
	and.l	d1,d0
	or.l	28(a1),d0
	move.l	d0,28(a0)

	move.l	32(a2),d1	;get mask data
	move.l	32(a0),d0	;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	32(a1),d0	;put grafix into hole
	move.l	d0,32(a0)	;put grafix on screen
	move.l	36(a0),d0
	and.l	d1,d0
	or.l	36(a1),d0
	move.l	d0,36(a0)

	move.l	40(a2),d1	;get mask data
	move.l	40(a0),d0	;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	40(a1),d0	;put grafix into hole
	move.l	d0,40(a0)	;put grafix on screen
	move.l	44(a0),d0
	and.l	d1,d0
	or.l	44(a1),d0
	move.l	d0,44(a0)

	add.w	#BOB_WIDTH*8,a1
	add.w	#BOB_WIDTH*8,a2
	lea	160(a0),a0
	ENDR


	add.w	#8,a0
	add.w	#8,a1
	add.w	#8,a2
	REPT	17
	move.l	(a2)+,d1	;get mask data
	move.l	(a0),d0		;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	(a1)+,d0	;put grafix into hole
	move.l	d0,(a0)+	;put grafix on screen
	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+

	move.l	(a2)+,d1	;get mask data
	move.l	(a0),d0		;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	(a1)+,d0	;put grafix into hole
	move.l	d0,(a0)+	;put grafix on screen
	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+

	move.l	(a2)+,d1	;get mask data
	move.l	(a0),d0		;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	(a1)+,d0	;put grafix into hole
	move.l	d0,(a0)+	;put grafix on screen
	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+

	move.l	(a2)+,d1	;get mask data
	move.l	(a0),d0		;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	(a1)+,d0	;put grafix into hole
	move.l	d0,(a0)+	;put grafix on screen
	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+

	move.l	(a2)+,d1	;get mask data
	move.l	(a0),d0		;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	(a1)+,d0	;put grafix into hole
	move.l	d0,(a0)+	;put grafix on screen
	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+

	move.l	(a2)+,d1	;get mask data
	move.l	(a0),d0		;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	(a1)+,d0	;put grafix into hole
	move.l	d0,(a0)+	;put grafix on screen
	move.l	(a2)+,d1
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+

	add.w	#16+8,a0
	add.w	#16+8,a1
	add.w	#16+8,a2
	add.w	#160-(BOB_WIDTH*8),a0
	ENDR

	sub.w	#8,a0
	sub.w	#8,a1
	sub.w	#8,a2
	move.w	#(BOB_DEPTH-(9+16+17))-1,d7
.loop	REPT	BOB_WIDTH

* do first word (8 colours)
	move.l	(a2),d1	;get mask data
	move.l	(a0),d0		;get screen data
	and.l	d1,d0		;get rid of screen within mask
	or.l	(a1)+,d0	;put grafix into hole
	move.l	d0,(a0)+	;put grafix on screen

* do second word (8 colours)
	move.l	(a0),d0
	and.l	d1,d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	addq.w	#8,a2
	ENDR

	add.w	#160-(BOB_WIDTH*8),a0	;drop down one screen line
	dbf	d7,.loop	;do until finsihed
	rts



*-------------------------------------------------------------------

scroll	move.l	last_base,a1
	add.l	#(160*200)+2,a1		;into border
	lea	font_offsets,a2		;font lookup table
	lea	font,a3			;font itself
	move.l	scroll_pointer,a4	;pointer into text
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5			;40 words across screen
	move.w	char_offset,d6		;char offset is a toggle
					;for bytes/words

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
** If I didn't use this then the bob may have to be made smaller 'cause
** of the CPU time...

.column
OFF	set	0
	REPT	32		;32 lines deep font
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160		;go down a line
	ENDR

	subq.w	#1,d5		;column value
	beq.s	.finish		;last column then finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next byte
	add.w	#6,a1		;else goto next word on screen
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



********************
* SERVICE ROUTINES *
********************

flip_screen	;flip between 2 screens to stop bob flickering
	move.l	present_base,last_base
	move.l	screen_1,a0
	move.w	screen_number,d0
	beq	.1
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
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts


user_mode
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
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


clear_below_screen			;clear crap under screen for
	move.l	present_base,a0		;border code
	lea	32000(a0),a0
	move.l	a0,a1
	add.l	#40192,a1
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts


set_for_border			;save old interrupt values
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#vert_isr,$70.W		;set new interrupt values
	MOVE.L	#new120,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	bclr	#3,$fffffa17.w		;enable auto A-INTERRUPT IN SERVICE clear
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts				;ISRs are now running


isr_off	bsr	vsync			;shut the interrupts down
	move.w	#$2700,sr		;quick before she blows up!!
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	MOVE.W	#$2300,SR


endmusic				;turn da music off man!
	moveq	#0,d0
	bsr	tune
	rts


shift_bob			;make 16 values of bob so smooth scroll
	lea	bob_pic+34,a0
	move.l	present_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop

	lea	bob,a1
	move.w	#16-1,d7
shift_loop
	move.l	present_base,a0
	move.l	a0,a6
	add.w	#8,a0

	move.w	#BOB_DEPTH-1,d2
repeat
OFF	set	0
	REPT	BOB_WIDTH		;in words
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	ENDR
	add.w	#160,a0
	dbf	d2,repeat

	move.w	#BOB_DEPTH-1,d2
repeat2
OFF	set	0
	REPT	BOB_WIDTH		;in words
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
OFF	SET OFF+4
	ENDR
	add.w	#160,a0
	dbf	d2,repeat2
	move.l	a6,a0

	move.w	#(BOB_DEPTH*2)+8-1,d6
.loop	sub.w	d4,d4
OFF	set	0
	REPT	BOB_WIDTH
	roxr.w	OFF(a0)
OFF	SET OFF+8
	ENDR
	add.w	#2,a0
	sub.w	d4,d4

OFF	set	0
	REPT	BOB_WIDTH
	roxr.w	OFF(a0)
OFF	SET OFF+8
	ENDR
	add.w	#2,a0
	sub.w	d4,d4

OFF	set	0
	REPT	BOB_WIDTH
	roxr.w	OFF(a0)
OFF	SET OFF+8
	ENDR
	add.w	#2,a0
	sub.w	d4,d4

OFF	set	0
	REPT	BOB_WIDTH
	roxr.w	OFF(a0)
OFF	SET OFF+8
	ENDR

	sub.w	#6,a0
	add.w	#160,a0
	dbf	d6,.loop
	dbf	d7,shift_loop

;now clear screen
	move.l	present_base,a0
	moveq	#0,d0
	move.w	#32000/4-1,d1
loop	move.l	d0,(a0)+
	dbf	d1,loop
	rts



*********
* ISRs  *
*********
vert_isr	;every screen update...
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7		;set colours after isr
	movem.l	d0-d7,$ffff8240.w
	bsr	tune+2			;do COUNT ZERO music
	clr.w	vsync_flag		;own screen update rout
	tst.w	zero_counter
	beq.s	.clear
	sub.w	#1,zero_counter
.clear	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w		;set interrupt method
	move.b	#199,$fffffa21.w	;next interrupt to occur 199 lines down
	rte				;let's leave before interrupt occurs


new120	clr.b	$fffffa1b.w	;DI all other interrupts
	REPT	102		;wait until we are next to right border
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz

*** this bit of code here is important for timing the border
*** do NOT change or you will lose STE compatability and probably the
*** lower border
***
*** I do the following 3 lines here to prevent the use from seeing
*** the colour change in the scroller
***
	movem.l	d0/a0/a1,-(sp)	;save regs
	move.l	colours_pos,a0	;colours for font
	lea	spec_colours,a1	;colours for spectrum anal
	move.w	#32-1,d0	;set up D0 here to save time later

***
***
	REPT	31-28		;wait a while
	nop
	ENDR
bor	move.w	#BORDER_COLOUR,$ffff8240.w	;hertz color show
	move.b	#2,$ffff820a.w	;back to 50 hertz

**** WOW dudes we are in the lower border.......

.loop	move.w	(a0),$ffff8244.w	;show colours in scroll
	move.w	(a0)+,$ffff8246.w
	move.w	(a1)+,$ffff8242.w	;speecy colours
	REPT	113
	nop
	ENDR
	dbf	d0,.loop
	move.w	#BORDER_COLOUR,$ffff8240.w
	add.l	#2,colours_pos
	move.l	colours_pos,a0
	cmp.l	#colours_end,a0
	bge.s	.reset_cols
	movem.l	(sp)+,d0/a0/a1
	rte
.reset_cols
	move.l	#colours,colours_pos
	movem.l	(sp)+,d0/a0/a1
	rte

********
* Data *
********
	SECTION DATA
colours_pos	dc.l	colours
colours	dc.w	0		;for scroller
	dc.w	$200,$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$271,$172,$073,$074
	dc.w	$075,$076,$077,$067,$057,$047,$037
	dc.w	$027,$017,$007
	dc.w	$106,$205,$304,$403,$502,$601,$700
	dc.w	$710,$720,$730,$740,$750,$760,$770
	dc.w	$671,$572,$473,$374,$275,$176,$077
	dc.w	$167,$257,$347,$437,$527,$617,$707
	dc.w	$706,$705,$604,$503,$402,$301
colours_end
	dc.w	$200,$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$271,$172,$073,$074
	dc.w	$075,$076,$077,$067,$057,$047,$037
	dc.w	$027,$017,$007

zero_counter	dc.w	0
screen_number	dc.w	0
present_base	dc.l	0
last_base	dc.l	0
screen_1	dc.l	0
screen_2	dc.l	0
vsync_flag	dc.w	0

*** store for old ISR data
old70		dc.l	0
old120		dc.l	0
olda07		dc.b	0
olda09		dc.b	0
olda17		dc.b	0
olda1b		dc.b	0
olda21		dc.b	0
	even
org_rez		dc.w	0		;original rez
hertz_switch	dc.w	0		;hertz toggle check

scroll_pointer	dc.l	scroll_text+7
scroll_text
 DC.B "                                          "
 dc.b "P.O.V. 93.        CREDITS:      MENU CODED BY M.S.D. (THANX "
 dc.b "TO BORIS FOR OPTIMISING MY SPECTRUM ANALYSER ROUTINE - ONLY SLIGHTLY FASTER)"
 dc.b ",         "
 dc.b "GRAFIX BY OZ      AND      MUSIC BY COUNT ZERO (WHERE FROM?).        "
 DC.B "HERE ARE THE GREETINGS..     "
 DC.B "AUTOMATION,     "
 DC.B "ABC CREW,     "
 DC.B "BLACK CATS,     "
 dc.b "DEL,     "
 DC.B "DR.SYNE,     "
 DC.B "ERIK PLANKTON (LIKE THE NEW DEMO - KNOCK, KNOCK!!!),     "
 DC.B "EMPIRE,     "
 DC.B "EQUINOX,     "
 DC.B "GEORGE S,     "
 DC.B "INNER CIRCLE,     "
 DC.B "KGB (FRANCE),     "
 DC.B "LOST BOYS,     "
 DC.B "MARTIAN,     "
 DC.B "MEDWAY BOYS,     "
 dc.b "NOW 5,     "
 DC.B "NORTH SIDE,     "
 DC.B "OBERJE,     "
 DC.B "POMPEY PIRATES,     "
 DC.B "REPLICANTS,     "
 DC.B "RIPPED OFF,     "
 DC.B "SEWER SOFTWARE,     "
 DC.B "SKUNK,     "
 DC.B "SLAYTANIC CULTS,     "
 DC.B "SOURCE,     "
 DC.B "ST CNX,     "
 DC.B "TEX,     "
 DC.B "TCB,     "
 dc.b "TNT CREW,     "
 DC.B "AND     "
 DC.B "WATCHMEN.     "
 dc.b "     WELL IT APPEARS THAT SOME PEOPLE DON'T LIKE WHAT WE "
 DC.B "DO, I MEAN WE MUST BE THE WORST PACKING CREW EVER IN THE "
 DC.B "HISTORY OF THE ST ACCORDING TO A CERTAIN ANON PERSON.    "
 DC.B "HERE IS A QUOTE 'THE DISK CONTENTS AND PACKING ARE TERRIBLE, "
 DC.B "JUST CHECK OUT SOME OF THE RIPPED OFF CD'S, NEARLY ALL FILES "
 DC.B "ARE SMALLER - SOME UP TO 180K SMALLER.'        WELL DO YOU "
 DC.B "AGREE?            I WILL ADMIT THAT RIPPED OFF PUT A LOT OF "
 DC.B "SMALL DEMOS ON THEIR DISCS AND WE PUT LARGE SAMPLE DEMOS ON "
 DC.B "OURS, WE WILL CHANGE THAT WHEN WE GET SOME NEW STUFF.    AS "
 DC.B "FOR OTHER PEOPLES PACKS BEING SMALLER THAN MINE, WELL I HAVE "
 DC.B "AN EXTREMELY GOOD SOURCE OF INFORMATION (BILBO OF RIPPED OFF) "
 DC.B "THAT THEY ALTER SAMPLES TO ENABLE THEM TO PACK THEM SMALLER.     "
 DC.B "WHEN I PACK A SAMPLE I DO NOT ALTER IT IN ANY WAY SO THE "
 DC.B "QUALITY IS EXACTLY AS THE DEMO WRITER WANTED.     I FIND IT "
 DC.B "STRANGE THAT IF I CANNOT PACK DEMOS THEN WHY AM I NOW SUPPLYING 'RIPPED OFF' "
 DC.B "WITH PACKED DEMOS FOR THEIR DISCS?    AND WHY AM I GETTING "
 DC.B "THEIR DISCS, UNPACKING THE FILES AND REPACKING THEM SMALLER?    "
 DC.B "   WHY DO ALL OUR PACKS ALLOW THE DEMOS TO RUN IN THE MEMORY "
 DC.B "CONFIGURATION THAT THEY WERE ORIGINALLY MADE FOR (IF THE UNPACKED "
 DC.B "DEMO WORKS IN 512K SO WILL MY PACK).         WELL MR ANON. IF "
 DC.B "WE ARE SO CRAP AT PACKING, WHY DON'T YOU GET OFF YOUR ARSE "
 DC.B "AND START PACKING SEEING YOU (QUOTE) 'KNOW WHAT YOU ARE TALKING "
 DC.B "ABOUT'.          FUCK YOU ASSHOLE, EAT SHIT AND DIE.  IF YOU "
 DC.B "DON'T LIKE WHAT YOU SEE THEN STOP GETTING P.O.V. DISCS YOU "
 DC.B "DICK WART.                ONE LAST NOTE,   WE AT P.O.V. WRITE ALL "
 DC.B "OUR OWN MENUS AND RIP ALL OUR MUSIC, BOTH 'RIPPED OFF' AND "
 DC.B "'THE SOURCE' GET OTHER PEOPLE TO CODE THEIR MENUS.          "
 DC.B "WELL THAT'S IT FOR THIS DISC, I'LL BRING YOU SOME MORE "
 DC.B "POOR PACKS AS SOON AS I CAN GET SOMEBODY ELSE TO CODE "
 DC.B "ME A MENU!!!!!        BYE - M.S.D. 7-9-91.      "
 DC.B "                                                   "
 DC.B "                                                   "
 dc.b $ff
	even


char_offset	dc.w	0
font	dcb.b	32*4,0
	incbin	1plane.fnt


font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,38,43,00,00,00,00,43,40,41,45,00,44,42,39,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,45,00,00,00,00,37,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,00,00,00,00,00

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even



tune	incbin	474.img			;count zero music
	even


pic	incbin	pic.PI1			;main menu pic


bob_pic	incbin	bob.pi1			;pic with bob in top left


mid_pos		dc.l	0		;buffer for bob
last_position	dc.l	0		;last bob pos
table_pos	dc.l	sine		;pointer into SINE table
sine	incbin	sine.dat		;here is the sine table
	dc.w	-1,-1			;end of sine table


black	dcb.b	32,0			;32 bytes of nothing...


spec_colours
	dc.w	0,0,0,0
	dc.w	$300,$b80,$410,$c90,$520,$da0,$630
	dc.w	$eb0,$740,$fc0,$f50,$fd0,$f60,$fe0
	dc.w	$f70,$ff0,$040,$050,$060,$070,$071
	dc.w	$072,$073,$074,$075,$076


spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.b	MAX_BARS,0


********** valid key press table
key_codes
	dc.b	2,0	;key 1, offset 0
	dc.b	3,1	;key 2, offset 1
	dc.b	4,2	;key 3, offset 2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5

	dc.b	$6d,0	;keypad 1, offset 0
	dc.b	$6e,1	;keypad 2, offset 1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,3	;keypad 5

	dc.b	$ff	;end of table
	even


filename_table	dc.l	filename1
		dc.l	filename2
		dc.l	filename3
		dc.l	filename4
		dc.l	filename5


*** filenames no longer need to be 16 bytes long but must end
*** in 0 and must be on an even address...
filename1
	dc.b	"def_pack.MSD"
	dc.b	0
	even

filename2
	dc.b	"gen_pack.msd"
	dc.b	0
	even

filename3
	dc.b	"$$p_base.msd"
	dc.b	0
	even

filename4
	dc.b	"ninja_3.msd"
	dc.b	0
	even

filename5
	dc.b	"copier.pov"
	dc.b	0
	even



*************************
	SECTION BSS	
*************************

old_base	ds.l	1		;old screen address
old484		ds.w	1
stack_save	ds.l	1

old_pal	ds.b	32		;old colours

bob	ds.b	BOB_DEPTH*(BOB_WIDTH*8)*16	;grafix
	ds.b	BOB_DEPTH*(BOB_WIDTH*8)*16	;masks

	even

	ds.b	256		;workspace so screen in on 256 bytes boundry
screen	ds.b	40192		;two screens
	ds.b	40192

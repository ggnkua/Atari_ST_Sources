*************************************************************************
*			PERSISTENCE OF VISION 30			*
*			------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music from:	So-Watt demo						*
*									*
*									*
* Grafix by: 	Oz							*
*									*
*									*
* Date:				30-8-90					*
* Revised for this release:	8-7-94					*
*									*
* Released:			2-SEP-1997				*
*									*
*		½ Persistence Of Vision 1990/1994			*
*									*
*************************************************************************
*
* I cannot be bothered to re-write some of these routines but they work
* anyway, if you want to have some nice routines then take a look at
* POV 29 menu as I've tidied it up really well and re-written most of
* the routines.
*

	opt	o+,w-
WIDTH		equ	32
BUFFER_SIZE	EQU	136

		dc.w	$a00a		;hide mouse
		bsr	set_super	;set supervisor mode
		bclr	#2,$ffff820a.w	;50 Hz
		bsr	hide_cursor	;disable mouse
		bsr	save_pal	;store present pal
		bsr	set_palette	;set new one
		bsr	get_base	;store present screen base
		bsr	calc_new_base	;calc new one
		move.l	screen_base,a0	;set low rez on our base
		bsr	set_low_rez
		bsr	clear_below_screen
		moveq	#1,d0		;init tune
		bsr	tune
		bsr	set_for_border	;init ISRs

		move.b	$484,old484	;store keyboard values
		move.b	#2,$484		;turn off keyclick
		bsr	vsync		;sync
		bsr	transfer	;show pic routine
		bsr	vsync		;sync again for some reason!
		bsr	ripple		;do rippler
		move.l	speed,d6
		move.w	mask,d7
		bsr	vsync
		bsr	scroll		;init scroller
		bsr	vsync
		clr.b	$fffffc02.w
main_loop	bsr	vsync
;		move.w	#$123,$ffff8240.w
		bsr	restore		;put screen back where rippler was
		bsr	ripple		;do rippler
		bsr	scroll		;do scroll
;		move.w	pic+2,$ffff8240.w

		move.b	$fffffc02.w,d0	;get keyboard data

		cmp.b	#1,d0		;escape ********************
		beq	exit

		cmp.b	#$53,d0		;ALT CONTROL DEL
		beq	reset

		cmp.b	#$b,d0		;0 key
		bne.s	not_zero

		tst.w	zero_counter
		bne.s	aa

	eor.w	#$020,lbc+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra	main_loop

not_zero	tst.w	zero_counter
		beq.s	car
aa		sub.w	#1,zero_counter
car
		cmp.b	#$3b,d0		;F1
		beq	f1
		cmp.b	#$3c,d0		;F2
		beq	f2

		cmp.b	#2,d0		;1 key
		blt	main_loop
		cmp.b	#8,d0		;7 key
		bge	main_loop	
		move.l	d0,-(sp)
		bsr	isr_off
		move.l	old_base,a0	;screen_base
		bsr	set_low_rez

		tst.w	toggle
		beq.s	hz50
		eor.b	#2,$ff820a
hz50:
	move.l	old_base,a0
	bsr	set_low_rez
	bsr	show_cursor
	move.b	old484,$484
	dc.w	$a009

	lea	$ffff8240.w,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	(a0)

	move.l	(sp)+,d0
;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	move.l	old_base,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+

	bsr	user_mode

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1	;byyyyeeeeeeee!!!!!!!


f1:	move.w	#$000f,new_mask
	move.l	#4,new_speed
	bra	main_loop
f2:	move.w	#$00ff,new_mask
	move.l	#8,new_speed
	bra	main_loop

reset:	move.l	4,a0
	jmp	(a0)
exit:
	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484
	bsr	user_mode
	dc.w	$a009
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

****************
* custom routs *
****************
restore:
	move.w	ripple1_recover,d0
	bsr	do_recover
	move.w	ripple2_recover,d0
	bsr	do_recover
	move.w	ripple3_recover,d0
	bsr	do_recover
	move.w	ripple4_recover,d0
	bsr	do_recover
	move.w	ripple5_recover,d0
	bsr	do_recover
	move.w	ripple6_recover,d0
	bsr	do_recover
	rts

do_recover
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pic+34,a0
	add.w	d0,a0
	REPT	11
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	add.w	#160-72,a0
	add.w	#160-72,a1
	ENDR
	rts


ripple:	move.l	ripple1_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	no_ripple1_reset
	lea	ripple1_table,a0
	move.l	a0,ripple1_pos
no_ripple1_reset
	moveq	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0	;word offset
	move.b	(a0)+,d1	;ripple number
	move.l	a0,ripple1_pos

	move.l	screen_base,a1
	add.w	#40*160,d0
	move.w	d0,ripple1_recover
	add.w	d0,a1

	mulu	#4752,d1
	lea	titles,a0
	add.l	d1,a0
	bsr	print_titles


*************** R I P P L E   2 *****************
	move.l	ripple2_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	no_ripple2_reset
	lea	ripple2_table,a0
	move.l	a0,ripple2_pos
no_ripple2_reset
	moveq	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0	;word offset
	move.b	(a0)+,d1	;ripple number
	move.l	a0,ripple2_pos

	move.l	screen_base,a1
	add.w	#60*160,d0
	move.w	d0,ripple2_recover
	add.w	d0,a1

	mulu	#4752,d1
	lea	titles+792,a0
	add.l	d1,a0
	bsr	print_titles


**************** RIPPLE 3 ************
	move.l	ripple3_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	no_ripple3_reset
	lea	ripple3_table,a0
	move.l	a0,ripple3_pos
no_ripple3_reset
	moveq	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0	;word offset
	move.b	(a0)+,d1	;ripple number
	move.l	a0,ripple3_pos

	move.l	screen_base,a1
	add.w	#80*160,d0
	move.w	d0,ripple3_recover
	add.w	d0,a1

	lea	titles+792+792,a0
	mulu	#4752,d1
	add.l	d1,a0
	bsr	print_titles


*********** RIPPLE 4 **********
	move.l	ripple4_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	no_ripple4_reset
	lea	ripple4_table,a0
	move.l	a0,ripple4_pos
no_ripple4_reset
	moveq	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0	;word offset
	move.b	(a0)+,d1	;ripple number
	move.l	a0,ripple4_pos

	move.l	screen_base,a1
	add.w	#100*160,d0
	move.w	d0,ripple4_recover
	add.w	d0,a1

	lea	titles+792+792+792,a0
	mulu	#4752,d1
	add.l	d1,a0
	bsr	print_titles


*************ripple 5**********
	move.l	ripple5_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	no_ripple5_reset
	lea	ripple5_table,a0
	move.l	a0,ripple5_pos
no_ripple5_reset
	moveq	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0	;word offset
	move.b	(a0)+,d1	;ripple number
	move.l	a0,ripple5_pos

	move.l	screen_base,a1
	add.w	#120*160,d0
	move.w	d0,ripple5_recover
	add.w	d0,a1

	lea	titles+(792*4),a0
	mulu	#4752,d1
	add.l	d1,a0
	bsr	print_titles

*************ripple 6**********
	move.l	ripple6_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	no_ripple6_reset
	lea	ripple6_table,a0
	move.l	a0,ripple6_pos
no_ripple6_reset
	moveq	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0	;word offset
	move.b	(a0)+,d1	;ripple number
	move.l	a0,ripple6_pos

	move.l	screen_base,a1
	add.w	#140*160,d0
	move.w	d0,ripple6_recover
	add.w	d0,a1

	lea	titles+(792*5),a0
	mulu	#4752,d1
	add.l	d1,a0
	bsr	print_titles

	rts

print_titles:
				* from A0 to A1 *
	move.w	#11-1,d0
.loop	move.w	(a0),d1
	or.w	2(a0),d1
	or.w	4(a0),d1
	or.w	6(a0),d1
	not.w	d1

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

;mask on last word
	move.w	(a0),d1
	or.w	2(a0),d1
	or.w	4(a0),d1
	or.w	6(a0),d1
	not.w	d1

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	add.w	#160-72,a1
	dbf	d0,.loop

	rts

***************
* Subroutines *
***************
scroll:	tst.w	delay
	beq.s	carry_on
	sub.w	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	add.l	#1,line_ptr
	move.w	#80,delay
	rts
delay:	dc.w	0
no_delay:
	cmp.b	#$ff,(a6)
	bne	not_wrap_scroll
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr

not_wrap_scroll:
	tst.w	scroll_number
	bgt	loop2
	move.w	#WIDTH,scroll_number
	moveq	#0,d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.b	#32,d0
	lea	font_table,a6
	lsl.w	#1,d0	;*2
	add.w	d0,a6
	move.w	(a6),d0
	lea	font,a6
	add.l	d0,a6	;letter address is in a6

;transfer letter into buffer
	lea	buffer,a1
	REPT	136/4
	move.l	(a6)+,(a1)+
	ENDR

	move.w	new_mask,mask
	move.l	new_speed,speed

loop2:	move.l	screen_base,a6
	add.w	#32000+480,a6
	move.l	a6,a2

	move.w	mask,d6
	move.l	speed,d7
	sub.w	d7,scroll_number

	moveq	#0,d1
OFF	set	(160*(34-1))+152

	REPT	(34*20)
	moveq	#0,d0
	move.w	OFF(a6),d0
	lsl.l	d7,d0
	or.w	d1,d0
	move.w	d0,OFF(a6)
	swap	d0
	move.w	d0,d1
OFF	set	OFF-8
	ENDR

	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling

	move.w	#34-1,d2
loop
	moveq	#0,d0	
	move.w	2(a1),d0
	lsl.l	d7,d0
	move.w	d0,2(a1)

	swap	d0
	move.w	d0,d1

	moveq	#0,d0	
	move.w	(a1),d0
	lsl.l	d7,d0
	or.w	d1,d0
	move.w	d0,(a1)

	swap	d0
	and.w	d6,d0		;mask data coming onto screen
	eor.w	#$ffff,d6	;invert mask
	and.w	d6,(a2)		;mask data already on screen to prevent wrap
	or.w	d0,(a2)		;or coming on over already there!
	eor.w	#$ffff,d6	;invert mask back to original

	addq.w	#4,a1
	add.w	#160,a2		;increase screen
	dbf	d2,loop
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p
set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

set_med_rez:
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez:
	clr.w	-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_pic:
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
d_pic:	move.l	(a0)+,(a1)+
	dbf	d0,d_pic
	rts

hide_cursor:
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

clear_below_screen:
	move.l	screen_base,a0
	add.w	#32000,a0
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts

set_for_border:
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts


isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21

	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

transfer:
	move.l	screen_base,a1
	lea	pic+34,a0
	move.l	a0,a2
	add.w	#199*160,a2
	move.l	a1,a3
	add.w	#199*160,a3
	move.w	#99,d0
.loop:
	bsr	vsync
	REPT	40
	move.l	(a0)+,(a1)+
	move.l	(a2)+,(a3)+
	ENDR
	sub.w	#480,a2
	sub.w	#480,a3
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop
	rts

vsync:	move.w	#$ffff,vsync_flag
vs:	tst.w	vsync_flag
	bne.s	vs
	rts

wait_for_drive:
wfd:	tst.w	$43e
	bne.s	wfd
get:	move.w	$ff8604,d0
	btst	#7,d0
	bne.s	get
	rts

calc_new_base:
;calc new screen address from BSS
	lea	screen,a0	;get buffer of 32000
	move.l	a0,d0
	and.l	#$ffffff00,d0	;mask off upper words so to get rid of
				;byte off=256 byte boundry!
	move.l	d0,screen_base	;save it
	rts

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	bsr	tune+8
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	pic+4,$ffff8242.w
	clr.w	vsync_flag
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	RTE

horiz_isr:
	move.b	#4,$fffffa21.w	;4 lines per isr 
	move.l	#go_border,$120.w
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan:
	REPT	99
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz
	REPT	31
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz
	move.l	#lower_border,$120.w
	rte

lower_border:
lbc:	move.w	#$022,$ffff8240.w
	clr.b	$fffffa1b.w	;DI all other interrupts
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#34-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	move.w	pic+2,$ffff8240.w
	bclr	#0,$fffa0f
	rte
pal_table:
	DC.w	$100,$200,$300
	dc.w	$400,$500,$600,$700,$710,$720,$730,$740
	dc.w	$750,$760,$770,$670
	dc.w	$570,$470,$370,$270,$170,$071,$072,$073,$074,$075
	dc.w	$076,$077,$067,$057,$047,$037,$027,$017,$007

********
* Data *
********
	SECTION DATA
screen_save	dc.l	0
screen_base	dc.l	0
zero_counter:	dc.w	0	;used as a delay for 50/60 hertz
old484:	dc.w	0
scroll_number:	dc.w	32
stack_save:	dc.l	0
toggle:		dc.w	0	;hertz toggle
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
vsync_flag:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

ei_mouse:	dc.b	$14,8
di_mouse:	dc.b	$12,$1a
	even
mask:		dc.w	$000f	;mask for scroller
new_mask:	dc.w	$000f
speed:		dc.l	4	;speed of scroller - 4 bits default
new_speed:	dc.l	4
line_ptr:	dc.l	scroll_line
scroll_line:
 dc.b " % PERSISTENCE OF VISION % PRESENT THEIR DEMO COMPILATION DISC 30.      "
 DC.B "ALL CODING BY MAC SYS DATA WITH GRAPHIX FROM & AND MUSIC BY MAD "
 DC.B "MAX.      MEMBERS OF P.O.V. ARE -    MAC SYS DATA,    BORIS,    "
 DC.B "OZYMANDIAS,   ALY   AND   DR.SYNE.      "
 DC.B "PRESS F1 AND F2 FOR SCROLLINE SPEED CONTROL.   PRESS ALT+CONTROL+DELETE "
 dc.b "TO RESET YOUR ST (THIS WILL WORK ON ANY ST ON THIS AND FUTURE MENUS)     "
 dc.b "TODAYS DATE IS 12/9/90, THIS DISC WILL BE RELEASED ON SATURDAY THE 15/9/90 "
 DC.B "AT THE C.E.S. SHOW IN LONDON.          "
;
;scroll text has been removed
;
 DC.B "     WELL I'VE HAD ENOUGH OF THIS "
 DC.B "TYPING LARK SO I'M GOING ---- GET READY FOR THE COUNTDOWN "
 DC.B "TO WRAP, BYE........... "
 DC.B "               5        4        3        2        1        "
 dc.b	$ff,$ff
	even
buffer:		dcb.b	BUFFER_SIZE,0
	even
font:	dcb.b	136,0
	incbin	"shryn.fnt"
	even
font_table:
	dc.w	0	space
	dc.w	6256	!
	dc.w	0	"
	dc.w	0	#
	dc.w	0	$
	dc.w	6664	%-POV sign
	dc.w	6800	&-OZ sign
	dc.w	6528	'
	dc.w	5576	(
	dc.w	5712	)
	dc.w	5984	*
	dc.w	0	+
	dc.w	3672	,
	dc.w	5848	-
	dc.w	3808	.
	dc.w	6120	/
	dc.w	4216	0
	dc.w	4352	1
	dc.w	4488	2
	dc.w	4624	3
	dc.w	4760	4
	dc.w	4896	5
	dc.w	5032	6
	dc.w	5168	7
	dc.w	5304	8
	dc.w	5440	9
	dc.w	4080	:
	dc.w	3944	;
	dc.w	0	<
	dc.w	0	=
	dc.w	0	>
	dc.w	6392	?
	dc.w	0	@
;letters
	dc.w	136,272,408,544,680,816,952,1088,1224,1360,1496,1632
	dc.w	1768,1904,2040,2176,2312,2448,2584,2720,2856,2992,3128,3264,3400,3536

tune:	incbin "sowhat3.mus"
	even
pic:	incbin	"pov30.pi1"

titles	incbin	titles.dat
ripple1_recover:	dc.w	0
ripple1_pos	dc.l	init_ripple1_table
init_ripple1_table
	dc.b	48,0
	dc.b	48,1
	dc.b	48,2
	dc.b	48,3
	dc.b	48,5
	dc.b	48,7
	dc.b	48,10
	dc.b	48,13
	dc.b	56,0
	dc.b	56,4

ripple1_table
	dc.b	56,9
	dc.b	56,14
	dc.b	64,3
	dc.b	64,8
	dc.b	64,12
	dc.b	72,0
	dc.b	72,3
	dc.b	72,6
	dc.b	72,8
	dc.b	72,10
	dc.b	72,11
	dc.b	72,12
	dc.b	72,13
	dc.b	72,12
	dc.b	72,11
	dc.b	72,10
	dc.b	72,8
	dc.b	72,6
	dc.b	72,3
	dc.b	72,0
	dc.b	64,12
	dc.b	64,8
	dc.b	64,3
	dc.b	56,14
	dc.b	56,9
	dc.b	56,4
	dc.b	48,15
	dc.b	48,10
	dc.b	48,5
	dc.b	48,0
	dc.b	40,11
	dc.b	40,6
	dc.b	40,1
	dc.b	32,12
	dc.b	32,8
	dc.b	32,4
	dc.b	32,1
	dc.b	24,15
	dc.b	24,12
	dc.b	24,10
	dc.b	24,8
	dc.b	24,6
	dc.b	24,5
	dc.b	24,4
	dc.b	24,3

	dc.b	24,4
	dc.b	24,5
	dc.b	24,6
	dc.b	24,8
	dc.b	24,10
	dc.b	24,12
	dc.b	24,15

	dc.b	32,1
	dc.b	32,4
	dc.b	32,8
	dc.b	32,12
	dc.b	40,1
	dc.b	40,6
	dc.b	40,11
	dc.b	48,0
	dc.b	48,5
	dc.b	48,10
	dc.b	48,15
	dc.b	56,4

	dc.b	$ff
ripple2_recover:	dc.w	0
ripple2_pos:	dc.l	init_ripple2_table
init_ripple2_table
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,1
	dc.b	48,2
	dc.b	48,3
	dc.b	48,5
	dc.b	48,7
	dc.b	48,10
	dc.b	48,13
	dc.b	56,0
	dc.b	56,4

ripple2_table
	dc.b	56,9
	dc.b	56,14
	dc.b	64,3
	dc.b	64,8
	dc.b	64,12
	dc.b	72,0
	dc.b	72,3
	dc.b	72,6
	dc.b	72,8
	dc.b	72,10
	dc.b	72,11
	dc.b	72,12
	dc.b	72,13
	dc.b	72,12
	dc.b	72,11
	dc.b	72,10
	dc.b	72,8
	dc.b	72,6
	dc.b	72,3
	dc.b	72,0
	dc.b	64,12
	dc.b	64,8
	dc.b	64,3
	dc.b	56,14
	dc.b	56,9
	dc.b	56,4
	dc.b	48,15
	dc.b	48,10
	dc.b	48,5
	dc.b	48,0
	dc.b	40,11
	dc.b	40,6
	dc.b	40,1
	dc.b	32,12
	dc.b	32,8
	dc.b	32,4
	dc.b	32,1
	dc.b	24,15
	dc.b	24,12
	dc.b	24,10
	dc.b	24,8
	dc.b	24,6
	dc.b	24,5
	dc.b	24,4
	dc.b	24,3

	dc.b	24,4
	dc.b	24,5
	dc.b	24,6
	dc.b	24,8
	dc.b	24,10
	dc.b	24,12
	dc.b	24,15

	dc.b	32,1
	dc.b	32,4
	dc.b	32,8
	dc.b	32,12
	dc.b	40,1
	dc.b	40,6
	dc.b	40,11
	dc.b	48,0
	dc.b	48,5
	dc.b	48,10
	dc.b	48,15
	dc.b	56,4

	dc.b	$ff

ripple3_recover:	dc.w	0
ripple3_pos:	dc.l	init_ripple3_table
init_ripple3_table
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,1
	dc.b	48,2
	dc.b	48,3
	dc.b	48,5
	dc.b	48,7
	dc.b	48,10
	dc.b	48,13
	dc.b	56,0
	dc.b	56,4

ripple3_table
	dc.b	56,9
	dc.b	56,14
	dc.b	64,3
	dc.b	64,8
	dc.b	64,12
	dc.b	72,0
	dc.b	72,3
	dc.b	72,6
	dc.b	72,8
	dc.b	72,10
	dc.b	72,11
	dc.b	72,12
	dc.b	72,13
	dc.b	72,12
	dc.b	72,11
	dc.b	72,10
	dc.b	72,8
	dc.b	72,6
	dc.b	72,3
	dc.b	72,0
	dc.b	64,12
	dc.b	64,8
	dc.b	64,3
	dc.b	56,14
	dc.b	56,9
	dc.b	56,4
	dc.b	48,15
	dc.b	48,10
	dc.b	48,5
	dc.b	48,0
	dc.b	40,11
	dc.b	40,6
	dc.b	40,1
	dc.b	32,12
	dc.b	32,8
	dc.b	32,4
	dc.b	32,1
	dc.b	24,15
	dc.b	24,12
	dc.b	24,10
	dc.b	24,8
	dc.b	24,6
	dc.b	24,5
	dc.b	24,4
	dc.b	24,3

	dc.b	24,4
	dc.b	24,5
	dc.b	24,6
	dc.b	24,8
	dc.b	24,10
	dc.b	24,12
	dc.b	24,15

	dc.b	32,1
	dc.b	32,4
	dc.b	32,8
	dc.b	32,12
	dc.b	40,1
	dc.b	40,6
	dc.b	40,11
	dc.b	48,0
	dc.b	48,5
	dc.b	48,10
	dc.b	48,15
	dc.b	56,4

	dc.b	$ff

ripple4_recover:	dc.w	0
ripple4_pos:	dc.l	init_ripple4_table
init_ripple4_table
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,1
	dc.b	48,2
	dc.b	48,3
	dc.b	48,5
	dc.b	48,7
	dc.b	48,10
	dc.b	48,13
	dc.b	56,0
	dc.b	56,4

ripple4_table
	dc.b	56,9
	dc.b	56,14
	dc.b	64,3
	dc.b	64,8
	dc.b	64,12
	dc.b	72,0
	dc.b	72,3
	dc.b	72,6
	dc.b	72,8
	dc.b	72,10
	dc.b	72,11
	dc.b	72,12
	dc.b	72,13
	dc.b	72,12
	dc.b	72,11
	dc.b	72,10
	dc.b	72,8
	dc.b	72,6
	dc.b	72,3
	dc.b	72,0
	dc.b	64,12
	dc.b	64,8
	dc.b	64,3
	dc.b	56,14
	dc.b	56,9
	dc.b	56,4
	dc.b	48,15
	dc.b	48,10
	dc.b	48,5
	dc.b	48,0
	dc.b	40,11
	dc.b	40,6
	dc.b	40,1
	dc.b	32,12
	dc.b	32,8
	dc.b	32,4
	dc.b	32,1
	dc.b	24,15
	dc.b	24,12
	dc.b	24,10
	dc.b	24,8
	dc.b	24,6
	dc.b	24,5
	dc.b	24,4
	dc.b	24,3

	dc.b	24,4
	dc.b	24,5
	dc.b	24,6
	dc.b	24,8
	dc.b	24,10
	dc.b	24,12
	dc.b	24,15

	dc.b	32,1
	dc.b	32,4
	dc.b	32,8
	dc.b	32,12
	dc.b	40,1
	dc.b	40,6
	dc.b	40,11
	dc.b	48,0
	dc.b	48,5
	dc.b	48,10
	dc.b	48,15
	dc.b	56,4

	dc.b	$ff

ripple5_recover:	dc.w	0
ripple5_pos:	dc.l	init_ripple5_table
init_ripple5_table
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,1
	dc.b	48,2
	dc.b	48,3
	dc.b	48,5
	dc.b	48,7
	dc.b	48,10
	dc.b	48,13
	dc.b	56,0
	dc.b	56,4

ripple5_table
	dc.b	56,9
	dc.b	56,14
	dc.b	64,3
	dc.b	64,8
	dc.b	64,12
	dc.b	72,0
	dc.b	72,3
	dc.b	72,6
	dc.b	72,8
	dc.b	72,10
	dc.b	72,11
	dc.b	72,12
	dc.b	72,13
	dc.b	72,12
	dc.b	72,11
	dc.b	72,10
	dc.b	72,8
	dc.b	72,6
	dc.b	72,3
	dc.b	72,0
	dc.b	64,12
	dc.b	64,8
	dc.b	64,3
	dc.b	56,14
	dc.b	56,9
	dc.b	56,4
	dc.b	48,15
	dc.b	48,10
	dc.b	48,5
	dc.b	48,0
	dc.b	40,11
	dc.b	40,6
	dc.b	40,1
	dc.b	32,12
	dc.b	32,8
	dc.b	32,4
	dc.b	32,1
	dc.b	24,15
	dc.b	24,12
	dc.b	24,10
	dc.b	24,8
	dc.b	24,6
	dc.b	24,5
	dc.b	24,4
	dc.b	24,3

	dc.b	24,4
	dc.b	24,5
	dc.b	24,6
	dc.b	24,8
	dc.b	24,10
	dc.b	24,12
	dc.b	24,15

	dc.b	32,1
	dc.b	32,4
	dc.b	32,8
	dc.b	32,12
	dc.b	40,1
	dc.b	40,6
	dc.b	40,11
	dc.b	48,0
	dc.b	48,5
	dc.b	48,10
	dc.b	48,15
	dc.b	56,4

	dc.b	$ff

ripple6_recover:	dc.w	0
ripple6_pos:	dc.l	init_ripple6_table
init_ripple6_table
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,0
	dc.b	48,1
	dc.b	48,2
	dc.b	48,3
	dc.b	48,5
	dc.b	48,7
	dc.b	48,10
	dc.b	48,13
	dc.b	56,0
	dc.b	56,4

ripple6_table
	dc.b	56,9
	dc.b	56,14
	dc.b	64,3
	dc.b	64,8
	dc.b	64,12
	dc.b	72,0
	dc.b	72,3
	dc.b	72,6
	dc.b	72,8
	dc.b	72,10
	dc.b	72,11
	dc.b	72,12
	dc.b	72,13
	dc.b	72,12
	dc.b	72,11
	dc.b	72,10
	dc.b	72,8
	dc.b	72,6
	dc.b	72,3
	dc.b	72,0
	dc.b	64,12
	dc.b	64,8
	dc.b	64,3
	dc.b	56,14
	dc.b	56,9
	dc.b	56,4
	dc.b	48,15
	dc.b	48,10
	dc.b	48,5
	dc.b	48,0
	dc.b	40,11
	dc.b	40,6
	dc.b	40,1
	dc.b	32,12
	dc.b	32,8
	dc.b	32,4
	dc.b	32,1
	dc.b	24,15
	dc.b	24,12
	dc.b	24,10
	dc.b	24,8
	dc.b	24,6
	dc.b	24,5
	dc.b	24,4
	dc.b	24,3

	dc.b	24,4
	dc.b	24,5
	dc.b	24,6
	dc.b	24,8
	dc.b	24,10
	dc.b	24,12
	dc.b	24,15

	dc.b	32,1
	dc.b	32,4
	dc.b	32,8
	dc.b	32,12
	dc.b	40,1
	dc.b	40,6
	dc.b	40,11
	dc.b	48,0
	dc.b	48,5
	dc.b	48,10
	dc.b	48,15
	dc.b	56,4

	dc.b	$ff
	even
filenames:
	dc.b	"ACID2.ANC",0,0,0,0,0
	dc.b	"DEMON.MSD",0,0,0,0,0
	dc.b	"AON.MSD",0,0,0,0,0,0,0
	dc.b	"CST.MSD",0,0,0,0,0,0,0
	dc.b	"INFO30.POV",0,0,0,0
	dc.b	"COPIER.POV",0,0
	even


	SECTION BSS
old_pal		ds.b	32
		ds.b	256
screen		ds.b	32000
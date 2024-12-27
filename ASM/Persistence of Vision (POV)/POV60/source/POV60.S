***************************
*        P.O.V. 60        *
*        ---------        *
* WRITTEN BY MAC SYS DATA *
***************************
;* Screen flipping menu
;* Present screen pointed to label PRESENT SCREEN

	bsr	set_super
	bsr	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out
	move.l	screen_base,a0
	move.l	a0,present_base
	bsr	set_low_rez
	move.b	$484,old484
	clr.b	$484

;************************************************************************
;*                            ATOMIX                                    *
;*                            ------                                    *
;************************************************************************

	move.l	#1,D0
	jsr	tune

	bsr	shift_pov
	bsr	v_sync
	bsr	show_pic
	bsr	set_for_border
	bsr	set_palette
	bsr	set_bounce_count
	bsr	flush
	bsr	disc_number
main_loop:
	bsr	flip_screen
;	move.w	#$123,$ffff8240.w
	bsr	return_screen
	bsr	disc_number
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	beq.s	zero

	cmp.b	#$70,d0		;0 keypad
	beq.s	zero

car	cmp.b	#$53,d0
	beq	do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

zero	tst.w	zero_counter
	bne.s	car
	eor.w	#$4,fontpal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra.s	main_loop

load	move.b	(a0),d0
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	(sp)+,d0
	and.l	#$ff,d0
	lea	filenames,a6
	mulu	#16,d0
	add.w	d0,a6
	lea	$200,a0
	movem.l	(a6),d0-d3
	movem.l	d0-d3,(a0)
	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	#$8,$fffffc02.w
	move.b	old484,$484
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4,a0
	jmp	(a0)
exit	bsr	isr_off
	bsr	flush
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	clr.w	-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************
* Subroutines *
***************
return_screen
	move.l	last_position,d0
	move.l	last_base,a0
	add.w	d0,a0
	lea	pic+34,a1
	add.w	d0,a1
	REPT	39
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	add.w	#160-(8*7),a0
	add.w	#160-(8*7),a1
	ENDR
	rts


disc_number
	move.l	table_pos,a0
	cmp.w	#-1,(a0)
	bne.s	.no_reset
	lea	sine,a0
	move.l	a0,table_pos
.no_reset
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.w	(a0)+,d0	;word/offset
	move.w	(a0)+,d1	;y offset (post*160)
	move.l	a0,table_pos
	move.b	d0,d2
	lsr.w	#4,d0		;word offset 
	lsl.w	#3,d0		;*8
	add.w	d1,d0
	move.l	present_base,a0
	add.w	d0,a0
	move.l	d0,last_position
	lea	pov,a1		;grafix
	and.w	#$f,d2
	mulu	#(8*6*39),d2
	add.w	d2,a1		;grafix
	add.w	d2,a1		;mask
	lea	8*6*39(a1),a2	;masks
	move.w	#39-1,d7
.loop
	REPT	6
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

scroll	move.l	present_base,a6
	lea	160*204(a6),a6
	movem.l	black,d0-d7/a0-a5
OFF	set 0
	REPT	120
	movem.l	d0-d7/a0-a5,OFF(a6)
OFF	set	OFF+56
	ENDR

	move.w	sine_number,d0
	cmp.w	sine_count,d0
	blt.s	.no_reset
	moveq	#0,d0
	move.w	d0,sine_number
.no_reset
	add.w	d0,d0
	lea	sine_table,a1
	add.w	d0,a1
	move.w	(a1),d0
	lsl.l	#5,d0
	move.w	d0,d1
	lsl.l	#2,d0
	add.l	d1,d0
	add.w	#1,sine_number
	move.l	present_base,a1
	lea	160*204(a1),a1
	add.w	d0,a1
	move.l	a1,last_scroll
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#124*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#124,d0		;character depth * 4 (31*4)
	add.w	d0,a0
.column
OFF	set	0
	REPT	31
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
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
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts

vsync:	move.w	#$ffff,vsync_flag
vs:	tst.w	vsync_flag
	bne.s	vs
	rts

flip_screen
	move.l	present_base,last_base
	eor.w	#-1,screen_toggle
	tst.w	screen_toggle
	bne.s	.no_reset
	clr.w	screen_toggle
.no_reset
	moveq.l	#0,d0
	move.l	screen_base,a0
	tst.w	screen_toggle
	beq.s	set
	add.l	#49152,a0
set	move.l	a0,present_base
	move.l	a0,d0
	lsr.l	#8,d0
	lea	$ffff8201,a0
	movep.w	d0,(a0)
	bsr	vsync
	rts

flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffc02.w,d0
	bra.s	flush
flush2	rts

set_super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
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
set_p	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

calc_screen:
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_base
	bsr	clear_below_screen
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
	move.l	screen_base,a1
	move.l	a1,a2
	add.l	#49152,a2
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,d2
	move.l	d2,(a1)+
	move.l	d2,(a2)+
	dbf	d0,.loop
	rts


wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive
	rts

v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

clear_below_screen:
	move.l	screen_base,a0
	add.w	#32000,a0
	move.w	#1005,d7
	movem.l	black,d0-d6/a1
.loop	movem.l	d0-d6/a1,(a0)
	movem.l	d0-d6/a1,32(a0)
	movem.l	d0-d6/a1,64(a0)
	movem.l	d0-d6/a1,96(a0)
	movem.l	d0-d6/a1,128(a0)
	lea	160(a0),a0
	dbf	d7,.loop
	rts

black_out
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

shift_pov
	lea	pov_pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop

	lea	pov,a1
	move.w	#16-1,d7
shift_loop
	move.l	screen_base,a0
	move.l	a0,a6
	add.w	#8,a0
	move.w	#39-1,d2
repeat
OFF	set	0
	REPT 6				;6 words
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
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
;	move.l	#-1,OFF(a0)
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
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
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	add.w	#2,a0
	sub.w	#8,a0
	add.w	#160,a0
	dbf	d6,.loop
	dbf	d7,shift_loop
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
	bsr	vsync
	move.w	#$2700,sr
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	MOVE.W	#$2300,SR

endmusic:
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

set_bounce_count
	lea	sine_table,a0
	moveq.l	#0,d0
.loop	add.w	#1,d0
	cmp.w	#-1,(a0)+
	bne.s	.loop
	sub.w	#1,d0
	move.w	d0,sine_count
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	jsr	tune+8
	clr.w	vsync_flag
	tst.w	zero_counter
	beq.s	not_z
	sub.w	#1,zero_counter
not_z	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	rte

horiz_isr:
	move.b	#4,$fffffa21.w	;4 lines per isr 
	move.l	#go_border,$120.w
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan:
	REPT	98
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
	move.w	fontpal,$ffff8240.w
	movem.l	fontpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr.b	$fffffa1b.w	;DI all other interrupts
	bclr	#0,$fffa0f
	rte

********
* Data *
********
	SECTION DATA
fontpal:
	dc.w	$000,$777,$677,$667,$566,$556,$455,$445
	dc.w	$344,$334,$233,$223,$126,$112,$011,$001

zero_counter:	dc.w	0
screen_base:	dc.l	0
present_base:	dc.l	0
last_base	dc.l	0
old484:	dc.w	0
stack_save:	dc.l	0
vsync_flag:	dc.w	0
old70:	dc.l	0
old120:	dc.l	0
old118:	dc.l	0
olda07:	dc.b	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
screen_toggle	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 60.    "
 dc.b "ALL CODE BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC FROM ATOMIX. "
 dc.b "   IF YOU DON'T LIKE THE LANGUAGE IN THE PICTURE THEN TOUGH "
 DC.B "'CAUSE I AIN'T CHANGING IT......   I THINK THERE ARE TOO MANY "
 DC.B "ARSE HOLES IN THIS WORLD TRYING TO TELL PEOPLE WHAT THEY CAN "
 DC.B "AND CAN'T DO, IF YOU DON'T LIKE THE MENUS THEN DON'T "
 DC.B "GET THEM.    THESE COMPILATION DISCS ARE A HOBBY, I DO NOT GET "
 DC.B "ANY MONEY FOR THEM SO I DON'T WANT ANY PD LIBRARY "
 DC.B "TRYING TO TELL ME WHAT I CAN AND CAN'T PUT ON A MENU..... "
 DC.B "    I WILL NOW REEL OFF A FEW PD LIBRARY NAMES WHO HAVE "
 DC.B "STARTING DISTRIBUTING OUR DISCS "
 DC.B "    I'M SORRY IF I MISS A COUPLE OF NAMES BUT MARTIAN "
 DC.B "IS OUR DISTRIBUTION MASTER......)     ALL P.O.V. MENUS CAN "
 DC.B "BE FOUND AT....  "
 DC.B "CALEDONIAN PDL,   "
 DC.B "DEMO CLUB,   "
 DC.B "EMPDL,   "
 DC.B "LAPD,   "
 DC.B "MT SOFTWARE,   "
 DC.B "NBS,   "
 DC.B "PARADISE,   "
 DC.B "ST-CLUB,   "
 DC.B "SWSL,   "
 DC.B "TRUST PD   "
 DC.B "AND   "
 DC.B "WIZARD PD.   "
 DC.B "SOME P.O.V. DISCS CAN BE FOUND AT... "
 DC.B "B-SOFT,   "
 DC.B "EUPD   "
 DC.B "GOODMAN PDL   "
 DC.B "AND   "
 DC.B "MPH.   "
 DC.B "   ADVERTISEMENT TIME.....     GO AND BUY '30 SOMETHING' BY "
 DC.B "A GROUP CALLED 'CARTER THE UNSTOPPABLE SEX MACHINE'.  THE "
 DC.B "LP CAME OUT ON 18-2-91 AND I HAVE IT ON CD, IT IS BRILLIANT. "
 DC.B "   IF YOU CAN'T AFFORD A COPY THEN STEAL ONE FROM A SHOP!! "
 DC.B "    IF YOU STEAL ONE THEN THE SHOP WILL HAVE TO BUY ANOTHER "
 DC.B "AND THUS THE BAND WILL GO INTO THE CHARTS QUICKER.  HOWEVER "
 DC.B "IF YOU TAPE YOUR MATES COPY THEN THE BAND WILL GET BUGGER ALL "
 DC.B "AND THUS DISAPPEAR.....  PLEASE, PLEASE, PLEASE WILL EVERYBODY "
 DC.B "MAKE HUNDREDS OF COPIES OF KYLIE MINOGUES LP'S!!!    (ARF, ARF). "
 DC.B "   TODAYS DATE IS 24-2-91 AND I'VE JUST RECEIVED LOADS OF "
 DC.B "DEMOS SENT VIA MARTIAN BY TRUST PD AND SOMEONE ELSE (I CAN'T "
 DC.B "REMEMBER WHO) BUT I NOW HAVE 30-40 DEMOS FOR FUTURE "
 DC.B "MENUS.    I MAY RELEASE A COUPLE OF 'PLAIN BORING' MENUS WITH "
 DC.B "NOTHING MOVING TO GET RID OF SOME OF THEM (EVEN THOUGH THIS MENU "
 DC.B "ONLY TOOK ME 3 HOURS TO KNOCK UP).    IF YOU CAN WRITE "
 DC.B "MENUS AND WISH TO APPEAR ON A P.O.V. MENU THEN GET IN TOUCH VIA "
 DC.B "ANY PD LIBRARY MENTIONED EARLIER.         "
 dc.b "HEY MEDWAY BOYS - FIX YOUR VIRUS FREE BOOTSECTOR VERSION 3 'CAUSE "
 dc.b "IT DON'T WORK ON A 4 MEG STE... (TWO BOMBS).        "
 DC.B "HERE THEY COME..... THE CREDITS!!    HI TO    "
 DC.B "DR.SYNE,   MARTIAN,   THE MEDWAY BOYS,   THE REPLICANTS,   EMPIRE,   "
 DC.B "POMPEY PIRATES,   AXE OF DELIGHT,   EQUINOX,   AUTOMATION,   "
 DC.B "SEWER SOFTWARE,   CARTER U.S.M.,   OBERJE,   RIPPED OFF,   "
 DC.B "GEORGE,   G-FORCE   AND   TELESCAN PD (AMIGA).          "
 DC.B "IT'S TIME TO WRAP 'CAUSE I CAN'T THINK OF ANYTHING ELSE TO SAY, SO "
 DC.B "PRESS A KEY OR DIE......       "
 DC.B "                                                       "
 dc.b $ff
	even
char_offset	dc.w	0
font:		incbin	pp43.fnt
font_offsets:
 dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
 dc.b	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58
 dc.b	59,60,61,62,63
	even
last_scroll	dc.l	0
sine_count	dc.w	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	1,1,1
	dc.w	2,2
	dc.w	3,4
	dc.w	6
	dc.w	8
	dc.w	10
	dc.w	8
	dc.w	6
	dc.w	4,3
	dc.w	2,2
	dc.w	1,1,1
	dc.w	$ffff
black	dcb.b	64,0

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$ff
	even

;*************************
tune:	incbin	atomix.mus
pic	incbin	pov60.PI1
pov_pic	incbin	pov.pi1
last_position	dc.l	0
table_pos	dc.l	sine
sine	incbin	sine.dat
	dc.w	$ffff,$ffff
	even
filenames:
	dc.b	"PYTHON.MSD",0,0,0,0,0,0
	dc.b	"YOUNG.MSD",0,0,0,0,0,0,0
	dc.b	"KEEKS2.MSD",0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
pov	ds.b	59904
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	46000

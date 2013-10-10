***********************************
*              POV 29             *
*              ------             *
* Written by                      *
*           MAC SYS DATA          *
*             27-7-90             *
***********************************

	opt	o+,w-
BUFFER_SIZE:	EQU	30*8
BASE:		equ	$66000	;lower to 66000 for final assembly

	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$C(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1C(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	bsr	set_super
	bsr	wait_for_drive
	bsr	hide_cursor
	bsr	save_pal
	bsr	set_palette
	bsr	get_base
	move.l	#BASE,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	bsr	set_for_border

	move.b	$484,old484
	move.b	#2,$484		;no sound from IKBD
	moveq	#1,d0		;start tune
	bsr	tune
	bsr	transfer
	move.w	#$ffff,vsync_flag
main_loop:
	tst.w	vsync_flag
	bne.s	main_loop
;	move.w	#$070,$ffff8240.w
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	MOVE.W	#$FFFF,vsync_flag
	move.b	$fffc02,d0

;	cmp.b	#01,d0		;escape ********************
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$222,pic+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra	main_loop
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter
car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#5,d0		;4 key
	bge	main_loop	
	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	move.l	old_base,a0
	bsr	set_low_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484

	lea	$ffff8240.w,a0	;clear colours
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	(a0)
	bsr	user_mode

	move.l	old_base,a0	;move filename to screen
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

exit:
;	bsr	isr_off
;	move.l	old_base,a0
;	bsr	set_med_rez
;	bsr	restore_pal
;	bsr	show_cursor
;	move.b	old484,$484
;	bsr	user_mode
;	clr.w	-(sp)
;	move.w	#$4c,-(sp)
;	trap	#1
;	addq.l	#4,sp
;	rts


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
	move.w	#320,delay
	rts
delay:	dc.w	0
no_delay:
	cmp.b	#$ff,(a6)
	bne	not_wrap_scroll
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr

not_wrap_scroll:
	tst.w	scroll_number
	bne	loop2
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	lea	width_table,a5
	add.w	d0,a5
	moveq	#0,d4
	move.b	(a5),d4
	move.w	d4,scroll_number
	mulu	#30*6,d0
	lea	font,a6
	add.l	d0,a6	;letter address is in a6

;transfer letter into buffer
	lea	buffer,a1
	move.w	#30-1,d0
.loop:	move.w	(a6)+,(a1)+
	move.w	(a6)+,(a1)+
	move.w	(a6)+,(a1)+
	dbf	d0,.loop

loop2:	move.l	#BASE+32000+480,a6
	move.l	a6,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#30-1,d1
loop
	roxl.w	4(a1)	;scroll
	roxl.w	2(a1)	;scroll
	roxl.w	(a1)	;letter
	move.w	sr,d0	;get the X flag (extra bit scrolled from letter)
	and.w	#1,d0	;mask off lowest bit
	or.w	d0,(a2)	;put onto screen
	sub.w	d4,d4	;clear carry flag to prevent crap appearing at top of letters
	add.w	#6,a1	;increase buffer position
	add.w	#160,a2	;increase screen
	dbf	d1,loop

	move.w	#30-1,d0
loopy:	roxl.w	152(a6)
	roxl.w	144(a6)
	roxl.w	136(a6)
	roxl.w	128(a6)
	roxl.w	120(a6)
	roxl.w	112(a6)
	roxl.w	104(a6)
	roxl.w	96(a6)
	roxl.w	88(a6)
	roxl.w	80(a6)
	roxl.w	72(a6)
	roxl.w	64(a6)
	roxl.w	56(a6)
	roxl.w	48(a6)
	roxl.w	40(a6)
	roxl.w	32(a6)
	roxl.w	24(a6)
	roxl.w	16(a6)
	roxl.w	8(a6)
	roxl.w	(a6)
	sub.w	d4,d4	;clear X flag to stop wrapping.
	add.w	#160,a6
	dbf	d0,loopy
	sub.w	#1,scroll_number
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
	move.w	#16-1,d0
save_p:
	move.w	(a0)+,(a1)+
	dbf	d0,save_p
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
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
	move.l	#BASE,a1
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

;pause:	move.w	d0,-(sp)
;	move.w	#1000,d0
;.loop:	nop
;	dbf	d0,.loop
;	move.w	(sp)+,d0
;	rts

clear_below_screen:
	move.l	#BASE+32000,a0
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
	lea	pic+32034,a0	;Clear data at end of a DEGAS pic
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	#BASE,a0
	lea	pic+34,a1
	move.w	#200-1,d0
.loop1	bsr	vsync
	bsr	display_all
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop1
	rts

display_all
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#160/4-1,d0
.loop1	move.l	(a1)+,(a0)+
	dbf	d0,.loop1
	lea	offset_table,a2
	move.w	#31,d0
.loop2	move.w	(a2)+,d2
	move.l	a1,a3
	add.w	d2,a3
	move.w	#160/4-1,d1
.loop3	move.l	(a3)+,(a0)+
	dbf	d1,.loop3
	dbf	d0,.loop2
	movem.l	(sp)+,d0-d7/a0-a6
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

*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	clr.w	vsync_flag

	bsr	tune+8

	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	movem.l	(sp)+,d0-d7/a0-a6
	move.w	pic+4,$ffff8242.w
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
	move.w	#$022,$ffff8240.w
	clr.b	$fffffa1b.w	;DI all other interrupts
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#30-1,d0
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
	dc.w	$076,$077,$177,$277,$377

********
* Data *
********
	SECTION DATA
zero_counter:	dc.w	0	;used as a delay for 50/60 hertz
old484:	dc.w	0
scroll_number:	dc.w	10
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
;Font - \=OZ   [=POV
line_ptr:	dc.l	scroll_line
scroll_line:
 DC.B "HELLO EVERYBODY, YES IT'S     [ 29     ",$7F,"MENU CODED BY MAC SYS DATA,  "
 DC.B "ART BY \,  MUSIC BY MAD MAX.        WELL WHAT DO YOU THINK OF THIS "
 DC.B "PROPORTIONAL SCROLLER?   I HAD TO WRITE ONE BECAUSE \ DESIGNED THIS "
 DC.B "FONT AND EVERY LETTER IS A DIFFERENT SIZE (THANKS \!!!!)     "
 dc.b "I MUST APOLOGISE TO HALF MEG OWNERS FOR PUTTING ANOTHER 1 MEG ONLY "
 DC.B "DEMO ON THIS DISC.  IF I HAD SOME 1/2 MEG DEMOS THEN I'D PACK THEM "
 DC.B "AND PUT THEM ON A MENU IN RECORD TIME.    AS WE HAVE NOT BEEN SENT "
 DC.B "ANY 1/2 MEG DEMOS, BORIS IS NOW WRITING SOME (AREN'T YOU BORIS?).   "
 DC.B "WELL I'M BUSY DOING MENUS AND PACKING,   BORIS IS WRITING DEMOS,   "
 DC.B "\ IS BUSY DOING GRAFIX,   DR.SYNE IS BUSY PLAYING GAMES   AND ALY IS "
 DC.B "BUSY DOING NOTHING AT ALL.     "
 DC.B "WELL I'LL LEAVE THE GREETINGS FOR ANOTHER "
 DC.B "TIME SO YOU MAY AS WELL GET PRESSING SOME KEYS.......          BYE "
 DC.B "               5        4        3        2        1        "
 dc.b	$ff,$ff
	even
buffer:		dcb.b	BUFFER_SIZE,0
	even
font:	incbin	"font1.dat"
	incbin	"font2.dat"
	even
tune:	Incbin "sowhat4.mus"
	even

width_table:
	dc.b	24,6,14,18,22,14,16,14,15,15,18,14,14,24,14,14
	dc.b	32,9,26,23,25,23,24,27,24,24,14,14,18,22,18
	dc.b	23,22,33,25,29,24,24,24,31,26,6,24,27,24,48
	dc.b	24,32,23,34,23,24,30,26,33,48,33,27,32,32,32

	even
offset_table
	dc.w	160*($28+62),160*($28+56)
	dc.w	160*($28+52),160*($28+49)
	dc.w	160*($28+46),160*($28+44)
	dc.w	160*($28+42),160*($28+40)
	dc.w	160*($28+39),160*($28+38)
	dc.w	160*($28+37),160*($28+36)
	dc.w	160*($28+35),160*($28+34)
	dc.w	160*($28+33),160*($28+32)
	dc.w	160*($28+31),160*($28+30)
	dc.w	160*($28+29),160*($28+28)
	dc.w	160*($28+27),160*($28+26)
	dc.w	160*($28+25),160*($28+24)
	dc.w	160*($28+23),160*($28+21)
	dc.w	160*($28+19),160*($28+17)
	dc.w	160*($28+14),160*($28+11)
	dc.w	160*($28+7),160*($28+1)

filenames:
	dc.b	"PSB",0,0,0,0,0,0,0,0,0,0,0
	dc.b	"LOADER.MSD",0,0,0,0
	dc.b	"COPIER.POV",0,0
	even
pic	incbin	"pov29.PI1"
	dcb.w	160*65,0

	SECTION BSS
old_pal:	ds.b	32

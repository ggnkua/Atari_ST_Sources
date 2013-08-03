




;-------------------------------------------------------------------------;
;       The following source code and art have been released by           ;
;       PERSISTENCE OF VISION for use by others for NON-Profit            ;
;   making purposes only. The code is supplied as is and no claim can     ;
;    be made against PERSISTENCE OF VISION for loses incured through      ;
;                    the use and/or missuse of it.                        ;
;                                                                         ;
;          All soundtracks are copyright of the original authors          ;
;-------------------------------------------------------------------------;
;
;                       This code was released on
;                         Persistence Of Vision
;                      Official Source Code Disc 1

*************************************
*              POV 27               *
*              ------               *
* Written by                        *
*           MAC SYS DATA            *
*             22-7-90               *
*************************************
* Assemble with GENST2 v2.08 onward *
* Code assembled using GENST2 v2.21 *
*************************************

**
** NOTE:	THIS MENU WAS WRITTEN FOR AUTORUN 4 SO IT WILL NOT P_EXEC
**	  	YOUR PROGRAM FROM HERE.
**		(that means it will not run your program from here!)
**		To make it work, put AUTORUN4.PRG in your AUTO folder
**		after this menu.
**


BUFFER_SIZE:	EQU	32*4
WIDTH:		EQU	32

		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
clear_bss	clr.b	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		move.l	#screen,d0
		clr.b	d0
		move.l	d0,new_base

		bsr	set_super
		bsr	wait_for_drive
		bsr	hide_cursor
		bsr	save_pal
		bsr	set_palette
		bsr	get_base
		move.l	new_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	bsr	set_for_border

*******************************
* Music from TCB soundtracker *
* Ripped by THE MEDWAY BOYS   *
*******************************

	move.b	$484.w,old484
	move.b	#2,$484.w		;no sound from IKBD
	moveq	#1,d0				music #1
	bsr	tune
	bsr	transfer

main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w

	move.w	speed_count,d0		;variable speed scroll
speed_loop:
	move.w	d0,-(sp)
	bsr	scroll
	move.w	(sp)+,d0
	dbf	d0,speed_loop

;	move.w	pic+2,$ffff8240.w

	move.b	$fffc02,d0
	cmp.b	#01,d0		;escape ********************
	beq	exit

	tst.w	key_delay
	beq.s	test_for_speed
	subq	#1,key_delay
	bra.s	on
test_for_speed:
	move.w	#6,key_delay
	cmp.b	#$4e,d0		;keypad +
	bne.s	not_plus
	cmp.w	#6,speed_count
	bgt.s	on
	addq	#1,speed_count
	bra.s	on
not_plus:
	cmp.b	#$4a,d0		;keypad -
	bne.s	on
	tst.w	speed_count
	ble.s	on
	subq	#1,speed_count


on:	cmp.b	#$b,d0		;0 key
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
aa:	subq	#1,zero_counter
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
	subq	#2,d0
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
	move.b	old484,$484.w

	lea	$200.w,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+

	bsr	user_mode
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq	#4,sp
	rts

exit:	bsr	isr_off
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484.w
	bsr	user_mode
	clr.w	-(sp)
	trap	#1

***************
* Subroutines *
***************
scroll:	
	tst.w	delay
	beq.s	carry_on
	subq	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	addq.l	#1,line_ptr
	move.w	#320,delay
	rts
delay:	dc.w	0
no_delay:
	cmp.b	#$ff,(a6)
	bne.s	not_wrap_scroll
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr

not_wrap_scroll:
	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	mulu	#32*4,d0
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
	lea	buffer,a1
	move.w	#32*4,d0
.loop:	move.b	(a6)+,(a1)+
	dbf	d0,.loop

loop2:	move.l	new_base,a6
	add.l	#32000+480,a6
	move.l	a6,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#32-1,d1
loop
	roxl.w	2(a1)	;scroll
	roxl.w	(a1)	;letter
	move.w	sr,d0	;get the X flag (extra bit scrolled from letter)
	and.w	#1,d0	;mask off lowest bit
	or.w	d0,(a2)	;put onto screen
	sub.w	d4,d4	;clear carry flag to prevent crap appearing at top of letters
	addq	#4,a1	;increase buffer position
	add.w	#160,a2	;increase screen
	dbf	d1,loop


	move.w	#32-1,d0
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
	subq	#1,scroll_number
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,stack_save
	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240.w,a0
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
	move.l	new_base,a1
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

pause:	move.w	d0,-(sp)
	move.w	#1000,d0
.loop:	nop
	dbf	d0,.loop
	move.w	(sp)+,d0
	rts

clear_below_screen:
	move.l	new_base,a0
	add.l	#32000,a0
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

	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w

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
	move.l	new_base,a0
	lea	pic+34,a1
	move.w	#200-1,d0
.loop1	bsr.s	vsync
	bsr.s	display_all
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop1


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
	clr.b	$fffa1b		;DI all other interrupts
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#32-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	bclr	#0,$fffa0f
	rte
pal_table:
	dc.w	$001
	dc.w	$002,$003,$004,$005,$106,$207,$307,$407
	dc.w	$507,$607,$706,$705,$704,$703,$702,$701
	dc.w	$710,$720,$730,$740
	dc.w	$750,$760,$770,$671,$572,$473,$374,$275,$176,$077


********
* Data *
********
	SECTION DATA
zero_counter:	dc.w	0	;used as a delay for 50/60 hertz
speed_count:	dc.w	4
key_delay:	dc.w	6
scroll_number:	dc.w	16
	even
vsync_flag:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0

ei_mouse:	dc.b	$14,8
di_mouse:	dc.b	$12,$1a
	even
line_ptr:	dc.l	scroll_line
scroll_line:
 DC.B "WELCOME TO P.O.V.  27 ",$7F,"     MENU CODED BY MAC SYS DATA, ROLL ON SCREEN CODED "
 DC.B "BY BORIS AND MAC SYS DATA,  ART BY OZ, "
 dc.b "MUSIC BY MAD MAX FROM THE TCB SOUNDTRACKER.       PRESS + AND - ON THE KEYPAD FOR SPEED CONTROL.        GREETINGS TO "
 dc.b "I DEDICATE THIS MENU TO A MATE (DARREN) WHO HAS RECENTLY BEEN KILLED IN A MOTORCYCLE ACCIDENT AT THE AGE OF 19 (R.I.P 19-7-90).  MAY ALL DOPEY CAR DRIVERS "
 DC.B "DIE A PAINFULL DEATH (ESPECIALLY ALL THOSE WHO ARE IN THE LANCASTER GOLF CLUB).                "
 DC.B "BORIS AND I HAVE JUST FINISHED WRITING A SOUNDTRACKER MENU FOR 'THE DEMO CLUB'.  IT "
 DC.B "ALLOWS YOU TO LOAD AND PLAY AMIGA SOUNDTRACKER FILES. THE DEMO CLUB WILL BE DISTRIBUTING DISCS FULL OF "
 DC.B "AMIGA MUSIC.        "
 DC.B " BYE                 "
 DC.B "                   "
 dc.b	$ff,$ff

	even
font:	incbin	"lost.fon"
	even
tune:	Incbin "tracker.mus"
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
	dc.b	"ALIEN.MSD",0,0,0,0,0
	dc.b	"TNT2.EEK",0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0
	even
cls:	dc.b	27,'E',0,0
	even
pic	incbin	"pov_boom.PI1"
	SECTION BSS
bssstart
	ds.w	160*65


old_pal		ds.b	32
stack_save	ds.l	1
new_base	ds.l	1
toggle		ds.w	1	;hertz toggle
old484		ds.w	1
old70		ds.l	1
old120		ds.l	1
olda07		ds.b	1
olda09		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
	even
buffer		ds.b	BUFFER_SIZE

	ds.b	256
screen	ds.b	32000+(160*48)
bssend
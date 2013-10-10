***************************
*        P.O.V. 77        *
*        ---------        *
* WRITTEN BY MAC SYS DATA *
***************************
;* Screen flipping menu
;* Present screen pointed to by label PRESENT_BASE

	bsr	set_super
	move.b	#$12,$fffffc02.w
	movem.l	black,d0-d3
	movem.l	d0-d3,$200	;wipe out old filename...
	bsr	wait_for_drive
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out
	move.l	screen_base,a0
	move.l	a0,present_base
	bsr	set_low_rez
	bsr	shift_sprite
	move.b	$484,old484
	clr.b	$484
	bsr	show_pre_pov

;************************************************************************
;*              PARALAX TUNE FROM INNER CIRCLE DECADE DEMO		*
;*              ------------------------------------------		*
;* Stolen by: MAC SYS DATA of P.O.V. 11/05/91 18:45			*
;*	From: DECADE DEMO						*
;* Include files:- 							*
;*			PARALAX.IMG into TUNE				*
;************************************************************************
;* tune by Count Zero
;* Nic Alderton
;* 16 Redington road
;* London
;* NW3 7RG
;*
;* Tel: 071-431-4915
;
;****************************************************************
; Only one tune.....
; 0=Sound off
; 1=tune

	moveq	#1,D0
	jsr	tune

	bsr	v_sync
	bsr	show_pic
	bsr	set_for_border
	bsr	set_palette
	bsr	flush
main_loop:
	bsr	flip_screen
;	move.w	#$400,$ffff8240.w
	bsr	scroll
;	move.w	#$040,$ffff8240.w
	bsr	clear_sprite
;	move.w	#$123,$ffff8240.w
	bsr	draw_sprite
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
	eor.w	#$4,fontpal+14
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
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bpl.s	.no
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
.no	bsr	flush
	bsr	user_mode
	clr.w	-(sp)
	trap	#1

***************
* Subroutines *
***************
clear_sprite
	move.l	last_pos+4,d0	;get last flip screen address
	move.l	present_base,a1
	add.l	d0,a1
	lea	pic+34,a0
	add.l	d0,a0
OFF	set 0
	REPT	17
	movem.l	OFF(a0),d0-d7/a2/a3/a4/a5
	movem.l	d0-d7/a2-a5,OFF(a1)
OFF	set OFF+12*4
	movem.l	OFF(a0),d0-d5
	movem.l	d0-d5,OFF(a1)
OFF	set OFF+160-(12*4)
	ENDR
	rts
	
draw_sprite
	move.l	last_pos,last_pos+4	;enable last flip screen addressing
	moveq	#0,d0
	move.l	d0,d1

	move.l	sprite_table_pos,a0
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	cmp.l	#sprite_table_end,a0
	blt.s	.no_reset
	lea	sprite_table,a0
.no_reset
	move.l	a0,sprite_table_pos
	move.w	d0,d2
	lsr.w	#4,d0		;word offset 
	lsl.w	#3,d0		;*8

	mulu	#160,d1
	add.w	d1,d0		;add Y pos
	move.l	d0,last_pos

	move.l	present_base,a2
	add.w	d0,a2

	and.w	#$f,d2
	mulu	#(8*9*17),d2
	lea	sprites,a0
	lea	masks,a1
	add.w	d2,a0
	add.w	d2,a1
OFF	set 0
	move.w	#17-1,d7
.loop	movem.l	(a0)+,d0/d1
	movem.l	(a1),d2/d3
	movem.l	OFF(a2),d4/d5
	and.l	d2,d4
	and.l	d3,d5
	or.l	d0,d4
	or.l	d1,d5
	movem.l	d4/d5,OFF(a2)
OFF	set OFF+8
	movem.l	(a0)+,d0/d1/d2/d3/d4/d5/d6
	movem.l	d0/d1/d2/d3/d4/d5/d6,OFF(a2)
OFF	set OFF+28
	movem.l	(a0)+,d0/d1/d2/d3/d4/d5/d6
	movem.l	d0/d1/d2/d3/d4/d5/d6,OFF(a2)
OFF	set OFF+28
	lea	72-8(a1),a1
	movem.l	(a0)+,d0/d1
	movem.l	(a1)+,d2/d3
	movem.l	OFF(a2),d4/d5
	and.l	d2,d4
	and.l	d3,d5
	or.l	d0,d4
	or.l	d1,d5
	movem.l	d4/d5,OFF(a2)
	add.w	#160,a2
	dbf	d7,.loop
	rts

	
scroll	move.l	present_base,a6
	lea	160*201(a6),a6
	movem.l	black,d0-d7/a0-a5
OFF	set 0
	REPT	106
	movem.l	d0-d7/a0-a5,OFF(a6)
OFF	set	OFF+56
	ENDR

	move.l	bounce_pos,a6
	cmp.l	#bounce_end,a6
	blt.s	.no_reset
	lea	bounce_start,a6
	move.l	a6,bounce_pos
.no_reset
	move.l	present_base,a1
	lea	160*201(a1),a1
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
	mulu	#25*4*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#25*4,d0	;character depth * 4 (31*4)
	add.w	d0,a0

.column
	move.l	a1,store1
	moveq	#0,d1
	move.w	(a6)+,d1
	add.w	d1,a1

OFF	set	0
	REPT	25
	move.l	(a0)+,d0
	movep.l	d0,OFF(a1)
OFF	set	OFF+160
	ENDR

	move.l	store1,a1
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
	add.l	#4,bounce_pos
	rts

store1	dc.l	0


vsync	move.w	#$ffff,vsync_flag
vs	tst.w	vsync_flag
	bne.s	vs
	rts

flip_screen
	bsr	vsync
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

show_pic
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

set_for_border:
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07.w,olda07
	move.b	$fffffa09.w,olda09
	move.b	$fffffa0f.w,olda0f
	move.b	$fffffa13.w,olda13
 	move.b	$fffffa17.w,olda17
	move.b	$fffffa1b.w,olda1b
	move.b	$fffffa21.w,olda21

	MOVE.L	#vert_isr,$70.W
	MOVE.L	#go_border,$120.W

	move.b	#1,$fffffa07.w
	clr.b	$fffffa09.w
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	MOVE.W	#$2300,SR
	rts


isr_off	bsr	vsync
	move.w	#$2700,sr
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$fffffa07.w
	MOVE.B	olda09,$fffffa09.w
	MOVE.B	olda17,$fffffa17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	move.b	olda0f,$fffffa0f.w
	move.b	olda13,$fffffa13.w

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.w	#$2300,sr
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

shift_sprite
	move.l	screen_base,a0
	lea	160*32(a0),a3
	lea	sprite,a1
	lea	17*(10*8)(a1),a2
	move.w	#10-1,d0
.loop
OFF	set	0
	REPT	17
	move.l	(a1)+,OFF(a0)
	move.l	(a1)+,OFF+4(a0)	;data
	move.l	(a2)+,OFF(a3)
	move.l	(a2)+,OFF+4(a3)	;mask
OFF	set OFF+160
	ENDR
	add.w	#8,a0
	add.w	#8,a3
	dbf	d0,.loop

;now shift... (ha,ha)
	lea	sprites,a2
	lea	masks,a3

	move.w	#16-1,d5
shifter	move.l	screen_base,a0
	add.w	#8,a0
	lea	160*32(a0),a1

	move.w	#17-1,d0		;17 lines down
OFF	set	0
.loop1
	REPT	9			;10 words across
	move.l	OFF(a0),(a2)+
	move.l	OFF+4(a0),(a2)+	;data

	move.l	OFF(a1),(a3)+
	move.l	OFF+4(a1),(a3)+	;mask
OFF	set OFF+8
	ENDR
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop1

	move.l	screen_base,a0
	lea	160*32(a0),a1
	move.w	#17-1,d1
.loop2	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)
	roxr.w	72(a0)
	roxr.w	80(a0)
	add.w	#2,a0

	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)
	roxr.w	72(a0)
	roxr.w	80(a0)
	add.w	#2,a0

	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)
	roxr.w	72(a0)
	roxr.w	80(a0)
	add.w	#2,a0

	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	roxr.w	64(a0)
	roxr.w	72(a0)
	roxr.w	80(a0)
	add.w	#2,a0


	roxr.w	(a1)
	roxr.w	8(a1)
	roxr.w	16(a1)
	roxr.w	24(a1)
	roxr.w	32(a1)
	roxr.w	40(a1)
	roxr.w	48(a1)
	roxr.w	56(a1)
	roxr.w	64(a1)
	roxr.w	72(a1)
	roxr.w	80(a1)
	add.w	#2,a1

	roxr.w	(a1)
	roxr.w	8(a1)
	roxr.w	16(a1)
	roxr.w	24(a1)
	roxr.w	32(a1)
	roxr.w	40(a1)
	roxr.w	48(a1)
	roxr.w	56(a1)
	roxr.w	64(a1)
	roxr.w	72(a1)
	roxr.w	80(a1)
	add.w	#2,a1

	roxr.w	(a1)
	roxr.w	8(a1)
	roxr.w	16(a1)
	roxr.w	24(a1)
	roxr.w	32(a1)
	roxr.w	40(a1)
	roxr.w	48(a1)
	roxr.w	56(a1)
	roxr.w	64(a1)
	roxr.w	72(a1)
	roxr.w	80(a1)
	add.w	#2,a1

	roxr.w	(a1)
	roxr.w	8(a1)
	roxr.w	16(a1)
	roxr.w	24(a1)
	roxr.w	32(a1)
	roxr.w	40(a1)
	roxr.w	48(a1)
	roxr.w	56(a1)
	roxr.w	64(a1)
	roxr.w	72(a1)
	roxr.w	80(a1)
	add.w	#2,a1

	add.w	#160-8,a1
	add.w	#160-8,a0
	dbf	d1,.loop2

	dbf	d5,shifter
	rts

show_pre_pov
	move.l	screen_base,a0
	moveq	#0,d1
	move.w	#32000/4-1,d0
.loo	move.l	d1,(a0)+
	dbf	d0,.loo

	movem.l	pre_pov+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	pre_pov+34,a6
	bsr	transfer

	move.w	#15,d6
.wait	move.w	#$fffe,d0
.wai	dbf	d0,.wai	
	dbf	d6,.wait
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

transfer
	lea	transfer_shape,a2
	move.w	#9-1,d3
.loop1:
	bsr	v_sync
	move.l	screen_base,a1
	move.l	a6,a0

	move.w	#12-1,d2
.loop2:
	move.w	#20-1,d1
.loop3:
	move.w	#16-1,d0
.loop4:
	move.w	(a2),d4
	move.w	(a0),d5
	and.w	d4,d5
	move.w	d5,(a1)

	move.w	(a2),d4
	move.w	2(a0),d5
	and.w	d4,d5
	move.w	d5,2(a1)

	move.w	(a2),d4
	move.w	4(a0),d5
	and.w	d4,d5
	move.w	d5,4(a1)

	move.w	(a2),d4
	move.w	6(a0),d5
	and.w	d4,d5
	move.w	d5,6(a1)

	add.w	#2,a2
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop4
	sub.w	#16*2,a2

	sub.w	#160*16,a0
	sub.w	#160*16,a1

	add.w	#8,a0
	add.w	#8,a1
	dbf	d1,.loop3

	add.w	#15*160,a0
	add.w	#15*160,a1
	dbf	d2,.loop2

	add.w	#16*2,a2
	sub.w	#32000,a0
	sub.w	#32000,a1
	dbf	d3,.loop1
	rts

*********
* ISRs  *
*********
vert_isr
	clr.b	$fffffa1b.w	;DI all other interrupts
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr.w	vsync_flag
	jsr	tune+2
	tst.w	zero_counter
	beq.s	not_z
	sub.w	#1,zero_counter
not_z	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

go_border
	clr.b	$fffffa1b.w	;DI all other interrupts
	REPT	100
	nop
	ENDR
	clr.b	$ffff820a.w	;60 hertz
	REPT	31
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz
lower_border
	move.w	fontpal,$ffff8240.w
	movem.l	fontpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bclr	#0,$fffffa0f.w
	rte

********
* Data *
********
	SECTION DATA
zero_counter	dc.w	0
screen_base	dc.l	0
present_base	dc.l	0
last_base	dc.l	0
old484		dc.w	0
stack_save	dc.l	0
vsync_flag	dc.w	0
old70		dc.l	0
old120		dc.l	0
olda07		dc.b	0
olda09		dc.b	0
olda17		dc.b	0
olda1b		dc.b	0
olda21		dc.b	0
olda0f		dc.b	0
olda13		dc.b	0
	even
screen_toggle	dc.w	0
old_base	dc.l	0
hertz_switch	dc.w	0

scroll_pointer	dc.l	scroll_text+7
scroll_text
 dc.b "                  PERSISTENCE OF VISION PACKED DEMO DISC 77.    "
 dc.b "ALL CODE BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC RIPPED BY "
 dc.b "MAC SYS DATA FROM THE INNER CIRCLE "
 dc.b "DECADE DEMO PARALLAX SCREEN.     THIS FONT MAY LOOK LIKE THE "
 dc.b "TCB FONT THAT'S 'CAUSE IT IS THE TCB "
 DC.B "FONT (I STOLE IT FROM THE CUDDLY DEMO) aaa bbb    "
 dc.b "   WELL I'VE JUST STOLE SOME DEMOS FROM THE MPH PD DISC CATALOGUE.   "
 DC.B "THERE WAS A HIDDEN TCB TRACKER MODULE ON ONE OF THE DEMOS SO I "
 DC.B "DUG OUT MY VERSION OF THE TCB TRACKER (I BOUGHT IT AND VERY SOON GOT "
 DC.B "ANGRY AT THE PROTECTION CODES SO I HACKED THEM OUT HA-HA-HA-HA-HA)  "
 DC.B "ADMITTEDLY I ONLY HAVE VERSION 1 BUT THE NUMBER OF TIMES IT "
 DC.B "CRASHES IS INCREDABLE, THE SOUND IS NOT AS CLEAR AS NOISETRACKER "
 DC.B "BUT THE TCB TRACKER DOES TAKE VERY LITTLE CPU TIME UP SO "
 DC.B "I SUPPOSE IT MAY HAVE IT'S USES IN GAMES AND DEMOS..... "
 DC.B "          RIGHT, ALL YOU STE PROGRAMMERS I NEED SOME INFORMATION ABOUT THE 'COOKIE JAR' "
 DC.B "ON THE STE.    IF YOU CAN SUPPLY ANY INFO ON IT THEN WRITE TO "
 DC.B "ME - MAC SYS DATA AT     P.O.V.,        P.O. BOX 40,        "
 DC.B "THORNTON CLEVELEYS,       BLACKPOOL,        FY5 3PH.      "
 DC.B "I WILL ANSWER ALL LETTERS FROM INTELLEGENT PEOPLE AND WILL "
 DC.B "IGNORE ALL LETTERS FROM LAMERS, SCROUNGERS AND GOOD FOR NOTHING "
 DC.B "PEOPLE (BORIS, DO NOT SEND TO THIS ADDRESS!!!!!              ONLY "
 DC.B "KIDDING, KEEP YOUR HAIR ON).        FLIPPIN' HECK, LOOK AT ALL THAT "
 DC.B "TEXT, IT'S AMAZING HOW MUCH I CAN GO ON WHEN I START WAFFLING (AS "
 DC.B "YOU WILL PROBABLY KNOW IF YOU'VE EVER PHONED ME UP).        "
 DC.B "WELL I HOPE THIS MENU SHUTS UP ALL YOU MOANING LOT WHO COMPLAIN "
 DC.B "THAT WE ONLY PUT 2 DEMOS ON SOME DISCS.   I COULD HAVE FITTED MORE "
 DC.B "DEMOS ON BY MAKING THE MENU SMALLER BUT WHO CARES?      OK, HERE "
 DC.B "ARE THE GREETS.. HI TO ALL AT BLACKPOOL COMPUTER CLUB - I BET "
 DC.B "YOU'RE MISSING ME AREN'T YOU?,      DR.SYNE,     GEORGE (TOWER PD),      "
 DC.B "RIPPED OFF,      D.W. STABLES PD,      NOW 5,      EMPIRE      AND      "
 DC.B "SEWER SOFTWARE.       NOT MANY GREETS THIS TIME 'CAUSE I'VE NOT "
 DC.B "HAD ANY SOFTWARE SENT TO ME FOR AGES SO I AIN'T SEEN ANYTHING NEW.       "
 DC.B "HOW MANY OF YOU REMEMBER P.O.V. 66?            YEH?         "
 DC.B "WELL IF YOU LIKED THE SOUNDTRACKER MODULE MENU, I'VE GOT SOME "
 DC.B "GOOD NEWS....... I'VE WRITTEN ANOTHER BUT THIS TIME I'VE "
 DC.B "SUSSED OUT HOW TO HAVE BORDER CODE AND A TRACKER.    THE MENU "
 DC.B "ALSO USES THE LATEST REPLAY ROUTINES FROM NOISETRACKER "
 dc.b "WHICH MAKES IT SOUND EVEN BETTER.   THE TRACKER STILL ONLY PLAYS "
 DC.B "AT 10KHZ BUT I MAY WRITE A VERSION THAT USES A HIGHER FREQUENCY "
 DC.B "BUT HAS A SMALLER SCROLLER.       DO ANY OF YOU DEMO FANS "
 DC.B "COLLECT PRODUCTION DEMOS? (E.G. GAME DEMOS, ETC.)   IF YOU "
 DC.B "DO THEN I'M SURE YOU'LL BE GLAD TO HEAR THAT I'M THINKING OF DOING "
 DC.B "A COMPILATION OF THOSE. IF I DO THEN THEY WILL NOT APPEAR AS A P.O.V. DEMO "
 DC.B "DISC BUT AS A P.O.V. GENERAL COMPILATION, I HAVEN'T THOUGHT "
 DC.B "ABOUT A TITLE FOR THE DISC YET BUT I WILL ONCE I'VE WRITTEN IT.  "
 DC.B "     DOES ANYBODY KNOW THE COOL CREW?       IF SO, GIVE THEM "
 DC.B "THIS DISC AND TELL 'EM TO CONTACT ME  -  TA!        "
 DC.B "OH YEH, HELLO TO 'MANI' (IS THAT CORRECT?), GET LEARNING "
 DC.B "68000 YOU LAAAAMER! (ARF, ARF).        RIGHT, THE SCROLLTEXT IS "
 DC.B "STARTING TO DETERIATE SO I'D BETTER SIGN OFF AND GET THIS THING "
 DC.B "TESTED ON MY 3 ST'S...... BYE FROM M.S.D. 11-6-91. "
 DC.B "                                                    "
 DC.B "                                               WRAP.."
 dc.b $ff
	even
char_offset	dc.w	0
font	dcb.b	16*25
		incbin	font.fnt
	even
font_offsets:
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,27,41,00,00,00,00,47,42,43,45,00,44,45,46,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	31,32,33,34,35,36,37,38,39,40,29,30,00,00,00,28,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,45,00,48,49,50

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	even
last_scroll	dc.l	0
bounce_pos	dc.l	bounce_start
bounce_start
	incbin	sine.dat
bounce_end
	incbin	sine.dat

black	dcb.b	64,0

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
	dc.b	7,5	;key 6

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$6c,5	;keypad 6
	dc.b	$ff
	even

;*************************
fontpal	dc.w	$000,$750,$760,$640,$530,$420,$310,$004
	dc.w	$100,$200,$300,$400,$500,$600,$700,$777

pic	incbin	pov77.PI1
	even
pre_pov	incbin	pre_pov.pi1
transfer_shape
	dc.w	%0100000000000000
	dc.w	%0000000000000110
	dc.w	%0000001000000000
	dc.w	%0000000000000000
	dc.w	%0000010000011000
	dc.w	%0000000000000000
	dc.w	%1000000000000010
	dc.w	%0000000100000000
	dc.w	%0000000010000000
	dc.w	%0001000000000100
	dc.w	%0001000000000000
	dc.w	%0000000001100000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0001000000000100
	dc.w	%0000100000001000

	dc.w	%0100000010000000
	dc.w	%0001000000000110
	dc.w	%0000001000000100
	dc.w	%0000000010000000
	dc.w	%0000010000011000
	dc.w	%0000000010000000
	dc.w	%1000000000010010
	dc.w	%0000000100000000
	dc.w	%0010000010000000
	dc.w	%0001000100000100
	dc.w	%0001000001000000
	dc.w	%0000000001100000
	dc.w	%0001000000001000
	dc.w	%0000000010000000
	dc.w	%0001000000000100
	dc.w	%0000100000001000

	dc.w	%0100010010010000
	dc.w	%0001010000000110
	dc.w	%0001001000000100
	dc.w	%0010000010000000
	dc.w	%1000010000011000
	dc.w	%0001000010000100
	dc.w	%1000001000011010
	dc.w	%0100001100010000
	dc.w	%0010000010000000
	dc.w	%0001000100000100
	dc.w	%1001000001000001
	dc.w	%0010100001100000
	dc.w	%0001000000001000
	dc.w	%0000100010000000
	dc.w	%0001001000000100
	dc.w	%0000100001001000

	dc.w	%0101010010010000
	dc.w	%0001010010000110
	dc.w	%0001001001000100
	dc.w	%0010000010000100
	dc.w	%1000010000011001
	dc.w	%0001000010000100
	dc.w	%1000001010011010
	dc.w	%0101001100010000
	dc.w	%0010100010000010
	dc.w	%0001100100010100
	dc.w	%1001001001000001
	dc.w	%0010100001100000
	dc.w	%0001001001001000
	dc.w	%1000100010111000
	dc.w	%1001001010000100
	dc.w	%0111100001001000

	dc.w	%0101010010010011
	dc.w	%0001010010000111
	dc.w	%0001001001110100
	dc.w	%0010100110101100
	dc.w	%1010100100101001
	dc.w	%1010000100000100
	dc.w	%1010010100101010
	dc.w	%0101001100011010
	dc.w	%0010100010101010
	dc.w	%0001100110010100
	dc.w	%1001001001000001
	dc.w	%0010100001101100
	dc.w	%0001001001001000
	dc.w	%1000100010111010
	dc.w	%1001001010000101
	dc.w	%0111100001001010

	dc.w	%1101010011010011
	dc.w	%0101010010100111
	dc.w	%1101001001110101
	dc.w	%1010100110101100
	dc.w	%1010110100101001
	dc.w	%1110100100110101
	dc.w	%1010110100101010
	dc.w	%0101001101011010
	dc.w	%0010111010101010
	dc.w	%0101100111010110
	dc.w	%1001001001001011
	dc.w	%0010101101101100
	dc.w	%0101001001001000
	dc.w	%1010101010111010
	dc.w	%1001011010000101
	dc.w	%1111111001101010

	dc.w	%1101110111110111
	dc.w	%0111011011101111
	dc.w	%1111011101110111
	dc.w	%1110110110111110
	dc.w	%1011110101111101
	dc.w	%1111110101111101
	dc.w	%1011110101111011
	dc.w	%1101011101111110
	dc.w	%0110111110111011
	dc.w	%1101110111110111
	dc.w	%1011011011101011
	dc.w	%1010111111101110
	dc.w	%1101101011001010
	dc.w	%1110111011111011
	dc.w	%1101011011100111
	dc.w	%1111111101111011

	dc.w	%1101111111110111
	dc.w	%1111011111101111
	dc.w	%1111111101111111
	dc.w	%1110110111111110
	dc.w	%1111110111111101
	dc.w	%1111111101111101
	dc.w	%1011111101111111
	dc.w	%1101011111111110
	dc.w	%0111111110111011
	dc.w	%1101110111111111
	dc.w	%1111111011101011
	dc.w	%1011111111101111
	dc.w	%1111101111101110
	dc.w	%1111111011111111
	dc.w	%1101111011101111
	dc.w	%1111111101111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

tune	incbin	paralax.img
	even
last_pos
	dc.l	0
	dc.l	0
sprite	incbin	sprites.dat
sprite_table_pos	dc.l	sprite_table
sprite_table
	incbin	sprite1.dat
	incbin	sprite3.dat
	incbin	sprite2.dat
	incbin	sprite4.dat
	incbin	sprite5.dat
	incbin	sprite6.dat
	incbin	sprite7.dat
	incbin	sprite8.dat
sprite_table_end
	incbin	sprite1.dat
	even
filenames:
	dc.b	"SCREAM_T.IME",0,0,0,0
	dc.b	"SINCLAIR.Z80",0,0,0,0
	dc.b	"TCB_TRAK.DEM",0,0,0,0
	dc.b	"QUARTZ.STS",0,0,0,0,0,0
	dc.b	"SPRITE.STS",0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

	SECTION BSS
old_pal	ds.b	32
sprites	ds.b	(9*8)*17*16
masks	ds.b	(9*8)*17*16
	ds.b	256
screen	ds.b	49152

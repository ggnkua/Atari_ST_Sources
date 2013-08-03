




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

***********************************
*              POV 28             *
*              ------             *
* Written by                      *
*           MAC SYS DATA          *
*             28-7-90             *
***********************************
* Assemble with 2.08+             *
***********************************
*
* Variable speed scroll
* scroller uses a LSL and not ROXL
*
	opt	o+,w-

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
		clr.w	pic+14
		bsr	save_pal
		bsr	set_palette
		bsr	get_base
		move.l	new_base,a0	;screen_base
		bsr	set_low_rez
		bsr	intro
		bsr	steal_pov_logo
		bsr	set_for_border

;************************************************************************
;*                            IRONLORD                                  *
;*                            --------                                  *
;* Stolen by: MAC SYS DATA of P.O.V. 21/07/90 17:37                     *
;*      From: The Medway Boys                                           *
;* Include files:-                                                      *
;*                 IRONLORD.IMG into TUNE                               *
;************************************************************************

	move.b	$484.w,old484
	move.b	#2,$484.w		;no sound from IKBD
; only one tune
	bsr	tune
	bsr	transfer
	move.w	#$ffff,vsync_flag
main_loop:
	tst.w	vsync_flag
	bne.s	main_loop
;	move.w	#$123,$ffff8240.w
	bsr	ripple
	bsr	animate_pov
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.w	#$ffff,vsync_flag
	move.b	$fffffc02.w,d0

	cmp.b	#01,d0		;escape ********************
	beq	exit

	tst.w	key_delay
	beq.s	do_test
	sub.w	#1,key_delay
	bra.s	do_rest
key_delay	dc.w	4
do_test
;test for speed changes in scroller
	cmp.b	#$4e,d0
	bne.s	not_plus
	cmp.w	#16,speed	;first +
	bge.s	do_rest
	move.l	speed_table_pos,a0
	move.w	(a0)+,new_speed
	move.w	(a0)+,new_mask
	move.l	a0,speed_table_pos
	move.w	#4,key_delay
	bra.s	do_rest
not_plus:			;now -
	cmp.b	#$4a,d0
	bne.s	do_rest
	cmp.w	#4,speed
	ble.s	do_rest
	move.l	speed_table_pos,a0
	sub.w	#4,a0
	move.l	a0,speed_table_pos
	move.w	(a0)+,new_speed
	move.w	(a0)+,new_mask
	move.w	#4,key_delay
	
do_rest:
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
	cmp.b	#6,d0		;5 key
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
hz50	move.l	old_base,a0
	bsr	set_low_rez
	bsr	restore_pal
	bsr	show_cursor
	move.b	old484,$484.w

	lea	$200.w,a0	;move filename to screen
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+

	bsr	user_mode

	clr.w	-(sp)
	trap	#1


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
scroll	tst.w	delay
	beq.s	carry_on
	sub.w	#1,delay
	rts
carry_on
	move.l	line_ptr,a6
	cmp.b	#'['-32,(a6)
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
	bne	loop2		;no new letter needed
;now test for new speed
	tst.w	new_speed
	beq.s	no_new_speed
	move.w	new_speed,speed
	move.w	new_mask,mask
	clr.l	new_speed	;clear speed and mask in one go
no_new_speed:
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	mulu	#32*4,d0
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
	lea	buffer,a1
	move.w	#32*4,d0
.loop:	move.b	(a6)+,(a1)+
	dbf	d0,.loop

loop2:
	move.l	new_base,a6
	add.l	#32000+480,a6
	move.l	a6,a2

	move.w	speed,d3	;bits per VBL scrolled
	sub.w	d3,scroll_number

	moveq	#0,d1
OFF	set	(160*31)+152
	REPT	(32*20)
	moveq	#0,d0
	move.w	OFF(a6),d0
	lsl.l	d3,d0
	or.w	d1,d0
	move.w	d0,OFF(a6)
	swap	d0
	move.w	d0,d1
OFF	set	OFF-8
	ENDR

	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#32-1,d2
loop
	moveq	#0,d0	
	move.w	2(a1),d0
	lsl.l	d3,d0
	move.w	d0,2(a1)

	swap	d0
	move.w	d0,d1

	moveq	#0,d0	
	move.w	(a1),d0
	lsl.l	d3,d0
	or.w	d1,d0
	move.w	d0,(a1)

	swap	d0
	moveq	#0,d1
	move.w	mask,d1
	and.w	d1,d0		;mask data coming onto screen
	eor.w	#$ffff,d1	;invert mask
	and.w	d1,(a2)		;mask data already on screen to prevent wrap
	or.w	d0,(a2)		;or coming on over already there!

	addq.w	#4,a1
	add.w	#160,a2	;increase screen
	dbf	d2,loop
	rts

***************************
* CUSTOM SUPPORT ROUTINES *
***************************
animate_pov:
	bsr	clear_pov_area
	move.l	new_base,a1
	add.l	#(160*153),a1
	move.l	animation_position,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_animation_reset
	lea	animation_table,a0
	move.l	a0,animation_position
no_animation_reset:
	moveq	#0,d0
	move.w	(a0),d0
	add.w	d0,a1
	lea	pov_logo,a0
	move.w	#17-1,d0
.loop:
	REPT	13
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	ENDR
	add.l	#160-(13*8),a1
	dbf	d0,.loop
	add.l	#2,animation_position
	rts

clear_pov_area:
	move.l	new_base,a0
	add.l	#160*153,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,a1
	move.l	a1,a2

	REPT	50
	movem.l d0-d6/a1/a2,(a0)
	add.w	#36,a0
	movem.l d0-d6/a1/a2,(a0)
	add.w	#36,a0
	movem.l	d0-d6/a1,(a0)
	add.w	#160-72,a0
	ENDR
	rts


********** ripple ***********
ripple:
	move.l	new_base,a6
	add.w	#96,a6
	move.l	ripple_pos,a4

	moveq	#0,d3
	move.w	#72-1,d7
.loop:
	lea	logos,a5
	add.w	d3,a5
	moveq	#0,d0
	cmp.b	#$ff,(a4)
	bne.s	.no
	lea	ripple_table,a4
	move.l	a4,ripple_pos
.no	move.b	(a4)+,d0
.loop2:
	mulu	#72*64,d0
	add.l	d0,a5

	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	add.w	#160-64,a6
	add.w	#64,d3
	dbf	d7,.loop
	add.l	#1,ripple_pos
	rts

***************************
steal_pov_logo:
	lea	pov_logo,a1
	lea	pic+34+(160*153),a0
	moveq	#0,d1
	move.w	#17-1,d0
.loop:
	REPT	13
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDR
	add.w	#160-(13*8),a0
	dbf	d0,.loop
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


set_for_border:
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
bp: 	move.b	$fffffa17,olda17
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
	move.l	new_base,a0
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

intro	pea	intro_mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	sr,-(sp)	;do loads of colours
	move.w	#$2700,sr	;di
	move.w	#$ffff,d7
	lea	$ffff825e.w,a0
colours:
	move.w	#$700,(A0)
	move.w	#$710,(A0)
	move.w	#$720,(A0)
	move.w	#$730,(A0)
	move.w	#$740,(A0)
	move.w	#$750,(A0)
	move.w	#$760,(A0)
	move.w	#$770,(A0)
	move.w	#$670,(A0)
	move.w	#$570,(A0)
	move.w	#$470,(A0)
	move.w	#$370,(A0)
	move.w	#$270,(A0)
	move.w	#$170,(A0)
	move.w	#$70,(A0)
	move.w	#$71,(A0)
	move.w	#$72,(A0)
	move.w	#$73,(A0)
	move.w	#$74,(A0)
	move.w	#$75,(A0)
	move.w	#$76,(A0)
	move.w	#$77,(A0)
	move.w	#$77,(A0)
	move.w	#$67,(A0)
	move.w	#$57,(A0)
	move.w	#$47,(A0)
	move.w	#$37,(A0)
	move.w	#$27,(A0)
	move.w	#$17,(A0)
	move.w	#$107,(A0)
	move.w	#$207,(A0)
	move.w	#$307,(A0)
	move.w	#$407,(A0)
	move.w	#$507,(A0)
	move.w	#$607,(A0)
	move.w	#$707,(A0)
	move.w	#$706,(A0)
	move.w	#$705,(A0)
	move.w	#$704,(A0)
	move.w	#$703,(A0)
	move.w	#$702,(A0)
	dbf	d7,colours
	move.w	(sp)+,sr
	move.w	pic+2,$ffff8240.w
	pea	cls
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
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

	bsr	tune+$1c2

	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	movem.l	(sp)+,d0-d7/a0-a6
	move.w	pic+4,$ffff8242.w
	clr.w	$ffff8240.w
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
	move.w	pic+2,$ffff8240.w
	lea	pal_table,a0
	move.w	#32-1,d0
col_loop:
	move.w	(a0)+,$ffff8242.w
	REPT 120
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	clr.w	$ffff8240.w
	bclr	#0,$fffa0f
	rte
pal_table:
	dc.w	$101
	dc.w	$202,$303,$404,$505,$406,$307,$207,$107
	dc.w	$007,$017,$027,$037,$047,$057,$067,$077
	dc.w	$076,$075,$074,$073
	dc.w	$072,$071,$170,$270,$370,$470,$570,$670,$770,$770
	rte

********
* Data *
********
	SECTION DATA
zero_counter:	dc.w	0	;used as a delay for 50/60 hertz
speed:		dc.w	4	;bits per VBL to scroll
mask:		dc.w	$000f	;mask for scroll
new_speed:	dc.w	0
new_mask:	dc.w	0

speed_table_pos:
	dc.l	speed_table
speed_table:
	dc.w	4,$000f
	dc.w	8,$00ff
	dc.w	16,$ffff

old484:		dc.w	0
scroll_number:	dc.w	16
old_pal:	ds.b	32
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
buffer:		dcb.b	BUFFER_SIZE,0
	even
**************************************
line_ptr:	dc.l	scroll_line
scroll_line:
	incbin	text.raw
 dc.b	$ff,$ff
	even
**************************************
font:	incbin	lost.fon
	even
**************************************
tune:	incbin	ironlord.img
	even
**************************************

intro_mess:
	dc.b	27,'E'
	dc.b	27,'Y%-',"Menu coded by"
	dc.b	27,"Y'.","MAC SYS DATA"
	dc.b	27,'Y*.',"All packs by"
	dc.b	27,'Y,.',"MAC SYS DATA"
	dc.b	27,"Y0'","Persistence Of Vision are"
	dc.b	27,'Y2.',"MAC SYS DATA"
	dc.b	27,'Y31',"BORIS"
	dc.b	27,'Y4/',"OZYMANDIAS"
	dc.b	27,'Y52',"ALY"
	dc.b	27,'Y60',"DR.SYNE",0
	even

cls:	dc.b	27,'E',0,0
	even

************* bouncy POV thingy **********
animation_position:     dc.l    animation_table
animation_table:
	dc.w    0,160,160,320,480,640
	dc.w    800,1120,1440
	dc.w    1760,2080,2560,3040,3520,4000
	dc.w    4640,4000,3520,3040,2560,2080,1760,1440,1120,800,640
	dc.w    480,320,160,160
	dc.w    $ffff

************* ripple data ************
logos:	incbin	8.dat
	incbin	7.dat
	incbin	6.dat
	incbin	5.dat
	incbin	4.dat
	incbin	3.dat
	incbin	2.dat
	incbin	1.dat
ripple_pos:	dc.l	init_ripple_table
init_ripple_table:
	dcb.b	72,0
	dcb.b	72,0
	dcb.b	72,0

ripple_table:
	dcb.b	72,0
	dc.b	1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8
	dc.b	9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15

	dc.b	14,14,14,14,13,13,13,13,12,12,12,12,11,11,11,11,10,10,10,10,9,9,9,9,8,8,8,8
	dc.b	7,7,7,7,6,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0

	dc.b	1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15
	dc.b	14,14,14,13,13,13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0

	dc.b	1,3,5,7,9,11,13,15,15,15,15,15,13,11,9,7,5,3,1,0,0,0,0,0
	dc.b	1,3,5,7,9,11,13,15,15,15,15,15,13,11,9,7,5,3,1,0,0,0,0,0

	dc.b	1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,6,4,2,0,2,4,6,8,10,12,14,12,10
	dc.b	8,6,4,2,0,2,4,6,8,10,12,14,12,10
	dc.b	9,8,7,6,5,4,3,2,1,0

	dc.b	1,2,3,4,5,7,9,11,14,15,15,15,15,15,15,15,15,15,15,15
	dc.b	14,13,11,9,6,3,1,0,1,3,6,9,11,13,14,15
	dc.b	15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
	dc.b	14,13,11,9,6,3,1,0,1,3,6,9,11,13,14,15
	dc.b	14,13,11,9,8
	dcb.b	60,8
	dc.b	7,7,6,6,5,5,4,4,3,2,1,0

	dc.b	1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15
	dc.b	14,14,14,13,13,13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0

	dc.b	1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
	dc.b	14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0

	dc.b	0,15,0,14,0,13,0,12,0,11,0,10,0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0

	dc.b	0,1,2,3,4,5,6,8,10,12,14,15,15,15,15,15
	dcb.b	40,15

	dc.b	14,15,13,15,12,15,11,14,10,13,9,12,8,11,7,10,6,9,5,8,4,7,3,6,2,5,1,4,0,3,0,2,0,1,0,0,0
	dc.b	1,0,2,0,3,0,4,1,5,2,6,3,7,4,8,5,9,6,10,7,11,8,12,9,13,10,14,11,15,12,15,13,15,14,15,15,15
	dc.b	14,15,13,15,12,15,11,14,10,13,9,12,8,11,7,10,6,9,5,8,4,7,3,6,2,5,1,4,0,3,0,2,0,1,0,0,0
	dc.b	1,0,2,0,3,0,4,1,5,2,6,3,7,4,8,5,9,6,10,7,11,8,12,9,13,10,14,11,15,12,15,13,15,14,15,15,15
	dc.b	14,15,13,15,12,15,11,14,10,13,9,12,8,11,7,10,6,9,5,8,4,7,3,6,2,5,1,4,0,3,0,2,0,1,0,0,0
	dc.b	1,0,2,0,3,0,4,1,5,2,6,3,7,4,8,5,9,6,10,7,11,8,12,9,13,10,14,11,15,12,15,13,15,14,15,15,15
	dc.b	14,15,13,15,12,15,11,14,10,13,9,12,8,11,7,10,6,9,5,8,4,7,3,6,2,5,1,4,0,3,0,2,0,1,0,0,0
	dc.b	1,0,2,0,3,0,4,1,5,2,6,3,7,4,8,5,9,6,10,7,11,8,12,9,13,10,14,11,15,12,15,13,15,14,15,15,15

	dc.b	14,13,12,11,10,9,8,7,6,5,4,3,2,1

	dc.b	1,2,3,4,5,6,7,8,8,8,8,8,7,6,7,8,9,10,10,10,10,10,9,8,9,10,11,12,13,14,15,15,15,15
	dc.b	15,15,15,15,15,15,15,13,11,9,11,13,15,15,15,15,15
	dc.b	15,15,15,15,15,15,15,15,15,15,15,15

	dc.b	14,14,13,13,12,11,9,6,3,0,3,6,8,9,10,11,12,13,13
	dc.b	12,11,9,7,4,1,0,3,6,7,8,8
	dc.b	7,6,4,2,0,2,4,6,7,7
	dc.b	6,5,3,1,0,2,4,5,6,6
	dc.b	5,4,2,1,0,2,3,4,5,5
	dc.b	4,3,1,0,2,3,4,4
	dc.b	3,1,0,1,2,3,3
	dc.b	2,1,0,1,2,2
	dc.b	1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,13,13,14,14,14,15,15,15,15
	dc.b	14,14,14,14,13,13,13,13,12,12,12,12
	dc.b	11,11,11,11,10,10,10,10,9,9,9,9,8,8,8,8,7,7,7,7,6,6,6,6,5,5,5,4,4,4,3,3,2,2,1,0,0,0,0
	dcb.b	72,0
	dc.b	$ff
**************************************
pic	incbin	"pov28.PI1"
	dcb.w	160*65,0

************ roll out screen data **********
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
******************************************

filenames:
	dc.b	"THE_RACE.DEM",0,0
	dc.b	"JUNGLE.BOS",0,0,0,0
	dc.b	"SYNC.MSD",0,0,0,0,0,0
	dc.b	"COPIER.POV",0,0,0,0
	EVEN

	SECTION	BSS
bssstart
new_base	ds.l	1

pov_logo	ds.b	13*8*17

		ds.b	256
screen		ds.b	32000+(160*48)
bssend
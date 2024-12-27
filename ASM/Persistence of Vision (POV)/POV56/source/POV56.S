****************
* P.O.V. 56    *
****************
	bra	over
 dc.b 	"So you're here again looking at my code eh BORIS!!!! "
 dc.b	" You may notice that this menu is slightly different "
 dc.b	"in the way that it detects the key presses and set the "
 dc.b	"correct filename to run... If you're really interested "
 dc.b	"I use a lookup table of valid keys and a second value "
 dc.b	"in the table is the value to multiply by 16 for the filename "
 dc.b	"offsets.   Well that about covers it for this menu... happy "
 dc.b	"hacking!                  "
	even
	dc.b	"HEY MENU CODE!!!"
	even
over	bsr	set_super
wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive

	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out
	move.l	screen_base,a0	;screen_base
	move.l	a0,a1
	add.l	#160*204,a1
	move.l	a1,last_scroll
	bsr	set_low_rez
	bsr	shift_logo
	bsr	clear_below_screen
	move.b	$484,old484
	clr.b	$484

;Music from Asteroth (vision factory on Amiga)
	move.l	#1,D0
	jsr	tune

	bsr	v_sync
	bsr	show_pic
	bsr	set_for_border
	bsr	set_palette
	bsr	flush
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	scroll
;	move.w	#$004,$ffff8240.w
	bsr	rippler
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$012,fontpal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#$53,d0
	beq	do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

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
hz50	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

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

do_reset
	move.l	4,a0
	jmp	(a0)
exit	bsr	isr_off
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
rippler	move.l	ripple_table_pos,a6
	cmp.b	#$ff,(a6)
	bne.s	.do_rout
	move.l	#ripple_table,ripple_table_pos
.do_rout
	lea	ripple_data,a4
	move.l	screen_base,a5
	move.w	#57-1,d7
.loop	move.w	d7,-(sp)
	cmp.b	#$ff,(a6)
	bne.s	.no_reset
	move.b	(a6)+,d0
.no_reset
	move.b	(a6)+,d0
	move.b	(a6)+,d1
	move.l	a5,a1
	move.l	a4,a0
	and.l	#$ff,d0
	and.l	#$ff,d1
	mulu	#8,d0		;word offset
	mulu	#96*57,d1	;ripple number
	add.l	d1,a0
	add.w	d0,a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,32(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,64(a1)
	add.w	#96,a4
	lea	160(a5),a5
	move.w	(sp)+,d7
	dbf	d7,.loop
	add.l	#2,ripple_table_pos
	rts

shift_logo
	lea	logo,a0
	move.l	screen_base,a1
	REPT	57
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,32(a1)
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,64(a1)
	lea	160(a1),a1
	ENDR

	lea	ripple_data,a1
	move.w	#16-1,d1
.loop2	move.l	screen_base,a0
	move.w	#57-1,d0
.loop	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	move.l	16(a0),(a1)+
	move.l	20(a0),(a1)+
	move.l	24(a0),(a1)+
	move.l	28(a0),(a1)+
	move.l	32(a0),(a1)+
	move.l	36(a0),(a1)+
	move.l	40(a0),(a1)+
	move.l	44(a0),(a1)+
	move.l	48(a0),(a1)+
	move.l	52(a0),(a1)+
	move.l	56(a0),(a1)+
	move.l	60(a0),(a1)+
	move.l	64(a0),(a1)+
	move.l	68(a0),(a1)+
	move.l	72(a0),(a1)+
	move.l	76(a0),(a1)+
	move.l	80(a0),(a1)+
	move.l	84(a0),(a1)+
	move.l	88(a0),(a1)+
	move.l	92(a0),(a1)+
	lea	160(a0),a0
	dbf	d0,.loop
	move.l	screen_base,a0	;scroll
	move.w	#57-1,d2
.scroll	roxr.w	(a0)
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
	roxr.w	88(a0)
	roxr.w	96(a0)
	sub.l	d4,d4
	roxr.w	2(a0)
	roxr.w	2+8(a0)
	roxr.w	2+16(a0)
	roxr.w	2+24(a0)
	roxr.w	2+32(a0)
	roxr.w	2+40(a0)
	roxr.w	2+48(a0)
	roxr.w	2+56(a0)
	roxr.w	2+64(a0)
	roxr.w	2+72(a0)
	roxr.w	2+80(a0)
	roxr.w	2+88(a0)
	roxr.w	2+96(a0)
	sub.l	d4,d4
	roxr.w	4(a0)
	roxr.w	4+8(a0)
	roxr.w	4+16(a0)
	roxr.w	4+24(a0)
	roxr.w	4+32(a0)
	roxr.w	4+40(a0)
	roxr.w	4+48(a0)
	roxr.w	4+56(a0)
	roxr.w	4+64(a0)
	roxr.w	4+72(a0)
	roxr.w	4+80(a0)
	roxr.w	4+88(a0)
	roxr.w	4+96(a0)
	sub.l	d4,d4
	roxr.w	6(a0)
	roxr.w	6+8(a0)
	roxr.w	6+16(a0)
	roxr.w	6+24(a0)
	roxr.w	6+32(a0)
	roxr.w	6+40(a0)
	roxr.w	6+48(a0)
	roxr.w	6+56(a0)
	roxr.w	6+64(a0)
	roxr.w	6+72(a0)
	roxr.w	6+80(a0)
	roxr.w	6+88(a0)
	roxr.w	6+96(a0)
	sub.l	d4,d4
	lea	160(a0),a0
	dbf	d2,.scroll
	dbf	d1,.loop2
	rts

scroll	move.l	last_scroll,a0
	movem.l	black,d0-d7
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	add.w	#160*31,a0
	movem.l	d0-d7,-320(a0)
	movem.l	d0-d7,-320+32(a0)
	movem.l	d0-d7,-320+64(a0)
	movem.l	d0-d7,-320+96(a0)
	movem.l	d0-d7,-320+128(a0)
	movem.l	d0-d7,-160(a0)
	movem.l	d0-d7,-160+32(a0)
	movem.l	d0-d7,-160+64(a0)
	movem.l	d0-d7,-160+96(a0)
	movem.l	d0-d7,-160+128(a0)
	movem.l	d0-d7,(a0)
	movem.l	d0-d7,32(a0)
	movem.l	d0-d7,64(a0)
	movem.l	d0-d7,96(a0)
	movem.l	d0-d7,128(a0)
	movem.l	d0-d7,160(a0)
	movem.l	d0-d7,160+32(a0)
	movem.l	d0-d7,160+64(a0)
	movem.l	d0-d7,160+96(a0)
	movem.l	d0-d7,160+128(a0)
	move.w	sine_number,d0
	cmp.w	#54-1,d0
	blt.s	.no_reset
	moveq	#0,d0
	move.w	d0,sine_number
.no_reset
	add.b	d0,d0
	lea	sine_table,a1
	add.w	d0,a1
	move.w	(a1),d0
	lsl.l	#5,d0
	move.w	d0,d1
	lsl.l	#2,d0
	add.l	d1,d0
	add.w	#1,sine_number
	move.l	screen_base,a1
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
	lea	$ffff8240.w,a1
set_p	movem.l	(a0),d0-d7
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
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
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
	move.w	#20,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts

black_out
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
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
	moveq.l	#0,d0
	jsr	tune
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
	clr.w	horiz_sync
	bsr	tune+8
	clr.w	vsync_flag
	movem.l	(sp)+,d0-d7/a0-a6
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
	dc.w	$000,$010,$021,$032,$043,$054,$065,$076
	dc.w	$030,$040,$050,$030,$151,$272,$274,$071

screen_base:	dc.l	0
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
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_number:	dc.w	0
scroll_buffer:	ds.b	44*35+4*35

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 56.    "
 dc.b "ALL CODE BY MAC SYS DATA WITH GRAFIX BY OZ AND FONT BY AUTOMATION. "
 dc.b " THE BRILLIANT MUSIC "
 DC.B "IS BY MAD MAX AND COMES FROM ASTAROTH (WELL IT DOES ON THE AMIGA ANYWAY). "
 dc.b "    HEY MR DEMO REVIEWER FROM ST FORMAT - CAN YOU READ WHAT THE "
 DC.B "LOGO SAYS AT THE TOP OF THE SCREEN?   IF YOU CAN'T THEN TOUGH "
 DC.B "SHIT!     HA-HA-HA-HA      WIBBLE, WOBBLE  (YUK-YUK!)     "
 dc.b "IF YOU DON'T UNDERSTAND THEN BUY ST-FORMAT YOU LAMER.     "
 DC.B "AS YOU CAN SEE THIS IS ANOTHER WELL WICKED MENU AND IT WASN'T CODED "
 DC.B "BY BORIS (SEE I CAN CODE - SOMETIMES!!!).    I'M SORRY FOR THE "
 DC.B "THALION SOUND DEMO BEING 1 MEG BUT NOBODY SEEMS TO HAVE AN "
 DC.B "ORIGINAL COPY THAT I CAN HACK TO MAKE A 512K VERSION.  "
 DC.B "      HEY MARTYN OF SWSL - IS THIS MENU AS GOOD AS DISC 51?   "
 DC.B "I MUST APPOLOGISE TO BORIS FOR THE LACK OF THE BOBS, MY "
 DC.B "EXCUSE IS THAT THERE WASN'T ENOUGH DISC SPACE LEFT SO I'LL "
 DC.B "PUT THEM ON ANOTHER MENU....      "
 DC.B "THERE IS VERY LITTLE SPACE FOR MORE TEXT BUT I SHOULD BE "
 DC.B "ABLE TO FIT A GREETINGS LIST IN.... HI TO DR.SYNE,   "
 DC.B "SWSL,   THE DEMO CLUB,   E.M.P.D.L.,   GEORGE,   "
 DC.B "POMPEY PIRATES,   THE EMPIRE,   AUTOMATION,   "
 DC.B "INNER CIRCLE,   TCB,   TLB,   OVERLANDERS, SEWER SOFTWARE "
 DC.B "   AND   PHALANX.        OK THAT'S ABOUT IT BUT I WILL "
 DC.B "GIVE A QUICK ADVERT FOR AN EXCELLENT GROUP CALLED 'CARTER "
 DC.B "THE UNSTOPPABLE SEX MACHINE' - GO OUT AND BUY 'BLOODSPORTS "
 DC.B "FOR ALL' ON CD SINGLE (MY BROTHER DAZ TRAVELS AROUND WITH THE "
 DC.B "BAND HELPING OUT).      OK - NO MORE, BYE!!!!      "
 DC.B "                                     "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	124*4,0
	incbin	"was254.fnt"
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even
last_scroll	dc.l	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0,0
	dc.w	1,1,1,1,1,1
	dc.w	2,2,2,2,2
	dc.w	3,3,3,3
	dc.w	4,4,4
	dc.w	5,5
	dc.w	6,7,8,10,8,7,6
	dc.w	5,5,4,4,4,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1

black	dcb.b	34,0

;*************************
	dc.b	"******** HEY LOOK A TUNE!!! ********"
	even
tune:	incbin	vision.img
	dc.b	"******** HEY LOOK A PICTURE!!! ********"
	even
pic	incbin	fly.PI1
	even

logo	incbin	shifted.dat
ripple_table_pos	dc.l	init_ripple_table
init_ripple_table
	dcb.w	600,$0405
	dc.b	4,5,4,4,4,3,4,2,4,1,4,0,3,15,3,14,3,13,3,12,3,11,3,10
	dc.b	3,9,3,8,3,7,3,6,3,5,3,4,3,3,3,2,3,1,3,0
	dc.b	3,1,3,2,3,4,3,6,3,8,3,9,3,11,3,13,3,11,3,9
	dc.b	3,8,3,6,3,4,3,2,3,1
	dc.b	3,2,3,6,3,10,3,14,4,2,4,6,4,10,4,14,5,2,5,6
	dc.b	5,10,5,14,6,2,6,6,6,10,6,14,7,2,7,5,7,8,7,10
	dc.b	7,12,7,13,7,14,7,15
	dc.b	7,14,7,13,7,12,7,10,7,6,7,2,6,14,6,10,6,6,6,2
	dc.b	5,14,5,10,5,6,5,2,4,14,4,10,4,6,4,2,3,14,3,10,3,6,3,2
	dc.b	2,15,2,12,2,9,2,6,2,3,2,0
	dc.b	1,14,1,11,1,8,1,5,1,2
	dc.b	0,14,0,11,0,8,0,5,0,3,0,2,0,1
ripple_table
	dc.b	0,0,0,1,0,2,0,3,0,5,0,7,0,10,0,13
	dc.b	1,2,1,6,1,10,1,14
	dc.b	2,2,2,6,2,10,2,14
	dc.b	3,2,3,6,3,10,3,14
	dc.b	4,2,4,6,4,10,4,14
	dc.b	5,2,5,6,5,10,5,14
	dc.b	6,2,6,6,6,10,6,14
	dc.b	7,2,7,6,7,10,7,14
	dc.b	8,2,8,5,8,8,8,10,8,12,8,13,8,14,8,15
	dc.b	8,14,8,13,8,12,8,10,8,8,8,5,8,2
	dc.b	7,14,7,10,7,6,7,2
	dc.b	6,14,6,10,6,6,6,2
	dc.b	5,14,5,10,5,6,5,2
	dc.b	4,14,4,10,4,6,4,2
	dc.b	3,14,3,10,3,6,3,2
	dc.b	2,14,2,10,2,6,2,2
	dc.b	1,14,1,10,1,6,1,2
	dc.b	0,14,0,10,0,7,0,5,0,3,0,2,0,1
	dc.b	0,0,0,1,0,2,0,3,0,5,0,7,0,10,0,13
	dc.b	1,2,1,6,1,10,1,14
	dc.b	2,2,2,6,2,10,2,14
	dc.b	3,2,3,6,3,10,3,14
	dc.b	4,2,4,6,4,10,4,14
	dc.b	5,2,5,6,5,10,5,14
	dc.b	6,2,6,6,6,10,6,14
	dc.b	7,2,7,6,7,10,7,14
	dc.b	8,2,8,5,8,8,8,10,8,12,8,13,8,14,8,15
	dc.b	8,14,8,13,8,12,8,10,8,8,8,5,8,2
	dc.b	7,14,7,10,7,6,7,2
	dc.b	6,14,6,10,6,6,6,2
	dc.b	5,14,5,10,5,6,5,2
	dc.b	4,14,4,10,4,6,4,2
	dc.b	3,14,3,10,3,6,3,2
	dc.b	2,14,2,10,2,6,2,2
	dc.b	1,14,1,10,1,6,1,2
	dc.b	0,14,0,10,0,7,0,5,0,3,0,2,0,1
	dc.b	0,0,0,1,0,2,0,3,0,5,0,7,0,10,0,13
	dc.b	1,2,1,6,1,10,1,14
	dc.b	2,2,2,6,2,10,2,14
	dc.b	3,2,3,6,3,10,3,14
	dc.b	4,2,4,6,4,10,4,14
	dc.b	5,2,5,6,5,10,5,14
	dc.b	6,2,6,6,6,10,6,14
	dc.b	7,2,7,6,7,10,7,14
	dc.b	8,2,8,5,8,8,8,10,8,12,8,13,8,14,8,15
	dc.b	8,14,8,13,8,12,8,10,8,8,8,5,8,2
	dc.b	7,14,7,10,7,6,7,2
	dc.b	6,14,6,10,6,6,6,2
	dc.b	5,14,5,10,5,6,5,2
	dc.b	4,14,4,10,4,6,4,2
	dc.b	3,14,3,10,3,6,3,2
	dc.b	2,14,2,10,2,6,2,2
	dc.b	1,14,1,10,1,6,1,2
	dc.b	0,14,0,10,0,7,0,5,0,3,0,2,0,1
	dc.b	0,0,0,1,0,2,0,3,0,5,0,7,0,10,0,13
	dc.b	1,2,1,6,1,10,1,14
	dc.b	2,2,2,6,2,10,2,14
	dc.b	3,2,3,6,3,10,3,14
	dc.b	4,2,4,6,4,10,4,14
	dc.b	5,2,5,6,5,10,5,14
	dc.b	6,2,6,6,6,10,6,14
	dc.b	7,2,7,6,7,10,7,14
	dc.b	8,2,8,5,8,8,8,10,8,12,8,13,8,14,8,15
	dc.b	8,14,8,13,8,12,8,10,8,8,8,5,8,2
	dc.b	7,14,7,10,7,6,7,2
	dc.b	6,14,6,10,6,6,6,2
	dc.b	5,14,5,10,5,6,5,2
	dc.b	4,14,4,10,4,6,4,2
	dc.b	3,14,3,10,3,6,3,2
	dc.b	2,14,2,10,2,6,2,2
	dc.b	1,14,1,10,1,6,1,2
	dc.b	0,14,0,10,0,7,0,5,0,3,0,2,0,1
	dc.b	0,0,0,1,0,2,0,3,0,5,0,7,0,10,0,13
	dc.b	1,2,1,6,1,10,1,14
	dc.b	2,2,2,6,2,10,2,14
	dc.b	3,2,3,6,3,10,3,14
	dc.b	4,2,4,6,4,10,4,14
	dc.b	5,2,5,6,5,10,5,14
	dc.b	6,2,6,6,6,10,6,14
	dc.b	7,2,7,6,7,10,7,14
	dc.b	8,2,8,5,8,8,8,10,8,12,8,13,8,14,8,15
	dc.b	8,14,8,13,8,12,8,10,8,8,8,5,8,2
	dc.b	7,14,7,10,7,6,7,2
	dc.b	6,14,6,10,6,6,6,2
	dc.b	5,14,5,10,5,6,5,2
	dc.b	4,14,4,10,4,6,4,2
	dc.b	3,14,3,10,3,6,3,2
	dc.b	2,14,2,10,2,6,2,2
	dc.b	1,14,1,10,1,6,1,2
	dc.b	0,14,0,10,0,7,0,5,0,3,0,2,0,1

	dc.b	0,0,0,2,0,4,0,6,0,8,0,10,0,12,0,14
	dc.b	1,0,1,2,1,4,1,6,1,8,1,10,1,12,1,14
	dc.b	2,0,2,2,2,4,2,6,2,8,2,10,2,12,2,14
	dc.b	3,0,3,2,3,4,3,6,3,8,3,10,3,12,3,14
	dc.b	4,0,4,2,4,4,4,5

	dc.b	4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5
	dc.b	4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5
	dc.b	4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5
	dc.b	4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5
	dc.b	4,6,4,4,4,7,4,3,4,8,4,2,4,9,4,1,4,10,4,0,4,11,3,15
	dc.b	4,12,3,13,4,13,3,12,4,14,3,11,4,15

	dc.b	3,12,4,14,3,13,4,13,3,14,4,12,3,15,4,11,4,0,4,10
	dc.b	4,1,4,9,4,2,4,8,4,3,4,7,4,4,4,5

	dcb.w	30,$0405
	dc.b	4,5,4,6,4,8,4,10,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,8,4,6,4,5,4,4,4,4,4,4,4,4,4,4,4,4
	dc.b	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	dc.b	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	dc.b	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	dc.b	4,15,4,12,4,7,4,4,4,1,4,4,4,7,4,12
	DC.B	4,10,4,8,4,6,4,5,4,4
	dc.b	4,5,4,6,4,7,4,8,4,9,4,10,4,11,4,12,4,13,4,14,4,15
 dc.b	5,0,5,1,5,2,5,3,5,4,5,5,5,6,5,7,5,8,5,9,5,10,5,11,5,12,5,13,5,14,5,15
 dc.b	5,15,5,14,5,15,5,13,5,15,5,12,5,15
 dc.b	5,11,5,15,5,10,5,15,5,9,5,15,5,8,5,15,5,7,5,15,5,6,5,15,5,5
 dc.b	5,15,5,4,5,15,5,3,5,15,5,2,5,15,5,1,5,15,5,0,5,15,5,1,5,15
 dc.b	5,2,5,15,5,3,5,15,5,4,5,5,5,5,5,15,5,6,5,15,5,7,5,15,5,8
 dc.b	5,15,5,9,5,15,5,10,5,15,5,11,5,15,5,12,5,15,5,13,5,15,5,14

 dc.b	5,15,5,15,5,15,5,15,5,15,5,15,5,15,5,15,5,15,5,15,5,15,5,15
 dc.b	6,0,6,2,6,4,6,6,6,8,6,6,6,4,6,2,6,0
 dc.b	5,14,5,12,5,10,5,8,5,6,5,4,5,2,5,0
 dc.b	4,14,4,12,4,10,4,8,4,10,4,12,4,13,4,14,4,15
 dc.b	4,14,4,13,4,12,4,10,4,8,4,6,4,4,4,2,4,0
 dc.b	3,14,3,12,3,10,3,8,3,6,3,4,3,2,3,0
 dc.b	2,14,2,12,2,10,2,8,2,6,2,4,2,2,2,0
 dc.b	1,14,1,12,1,10,1,8,1,6,1,4,1,2,1,0
 dc.b	0,14,0,12,0,10,0,8,0,6,0,5,0,4,0,3,0,2,0,1
 dc.b	0,3,0,6,0,9,0,12,0,15,1,3,1,6,1,9,1,12,1,15
 dc.b	2,3,2,6,2,9,2,12,2,15,3,3,3,6,3,9,3,12,3,15
 dc.b	4,2

 dc.b	4,3,4,2,4,1,4,0,3,9,3,8,3,7,3,6,3,5,3,4,3,3,3,2,3,1,3,0
 dc.b	2,15,2,14,2,13,2,12,2,11,2,10,2,9,2,8,2,7,2,6,2,5,2,4,2,3,2,2,2,1,2,0
 dc.b	1,15,1,14,1,13,1,12,1,11,1,10,1,9,1,8,1,7,1,6,1,5,1,4,1,3,1,2,1,1,1,0
 dc.b	0,15,0,14,0,13,0,12,0,11,0,10,0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0,0
 dc.b	$ff		;WOW reset flag!!!

	dc.b	0,0,0,1,0,2,0,3,0,5,0,7,0,10,0,13
	dc.b	1,2,1,6,1,10,1,14
	dc.b	2,2,2,6,2,10,2,14
	dc.b	3,2,3,6,3,10,3,14
	dc.b	4,2,4,6,4,10,4,14
	dc.b	5,2,5,6,5,10,5,14
	dc.b	6,2,6,6,6,10,6,14
	dc.b	7,2,7,6,7,10,7,14
	dc.b	8,2,8,5,8,8,8,10,8,12,8,13,8,14,8,15
	dc.b	8,14,8,13,8,12,8,10,8,8,8,5,8,2
	dc.b	7,14,7,10,7,6,7,2
	dc.b	6,14,6,10,6,6,6,2
	dc.b	5,14,5,10,5,6,5,2
	dc.b	4,14,4,10,4,6,4,2
	dc.b	3,14,3,10,3,6,3,2
	even
filenames:
	dc.b	"THALION.MSD",0,0,0,0,0
	dc.b	"FRENCH_K.ISS",0,0,0,0
	dc.b	"ULM.MSD",0,0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
ripple_data	ds.b	87552
ripple_end
	ds.b	256
screen:	ds.b	32000

****************
* P.O.V. 69    *
****************

	bsr	set_super
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
	bsr	shift_bobs
	bsr	shift_logo
	bsr	clear_below_screen
	move.b	$484,old484
	clr.b	$484

**** Music from WRATH OF THE DEMONS intro ***
**** MAD MAX TUNE ***
	move.l	#1,D0
	jsr	tune

;set up bobs
	move.l	present_table,a1
	move.l	a1,bob_v_pos
	add.w	#16,a1
	move.l	a1,bob_o_pos
	add.w	#16,a1
	move.l	a1,bob_p_pos

	bsr	v_sync
	lea	pic+34,a0
	move.w	#(160*59)/4-1,d0
clear_org_pov
	clr.l	(a0)+
	dbf	d0,clear_org_pov
	bsr	show_pic
	bsr	set_for_border
	bsr	set_palette
	bsr	flush
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	rippler
;	move.w	#$004,$ffff8240.w
	bsr	bobs
;	move.w	#$600,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	beq.s	zero

	cmp.b	#$70,d0		;0 keypad
	beq.s	zero


carry_on
	cmp.b	#$53,d0
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
hz50	bsr	restore_pal
	bsr	user_mode
	move.l	old_base,a0
	bsr	set_low_rez
	clr.w	-(sp)
	trap	#1

zero	tst.w	zero_counter
	bne.s	carry_on
	eor.w	#$012,fontpal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra	main_loop

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
	cmp.l	#reset_ripple_flag,a6
	blt.s	.do_rout
	move.l	#ripple_table,ripple_table_pos
.do_rout
	lea	ripple_data,a4
	move.l	screen_base,a5
	move.w	#59-1,d7
.loop	move.w	d7,-(sp)
	move.b	(a6)+,d0
	move.b	(a6)+,d1
	move.l	a5,a1
	move.l	a4,a0
	and.l	#$ff,d0
	and.l	#$ff,d1
	mulu	#8,d0		;word offset
	mulu	#96*59,d1	;ripple number
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

shift_bobs
	lea	bob_grafix,a0
	move.l	screen_base,a1
	move.w	#(16*6)-1,d0
.loop	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	move.l	(a0)+,16(a1)
	move.l	(a0)+,20(a1)
	lea	160(a1),a1
	dbf	d0,.loop

	lea	bob_shifts,a1
	move.w	#16-1,d7
shift	move.l	screen_base,a0
	addq.w	#8,a0
	move.w	#(16*6)-1,d0
sh1	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	add.w	#160,a0
	dbf	d0,sh1

	moveq.l	#0,d6
	move.w	#4-1,d5
.loop	move.l	screen_base,a0
	move.w	#(16*6)-1,d0
.sh2	roxr.w	0(a0,d6.w)
	roxr.w	8(a0,d6.w)
	roxr.w	16(a0,d6.w)
	lea	160(a0),a0
	sub.w	d4,d4
	dbf	d0,.sh2
	add.w	#2,d6
	dbf	d5,.loop
	dbf	d7,shift
	rts

shift_logo
	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.sho	move.l	(a0)+,(a1)+
	dbf	d0,.sho

	lea	ripple_data,a1
	move.w	#16-1,d1
.loop2	move.l	screen_base,a0
	move.w	#59-1,d0
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
	move.w	#59-1,d2
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

bobs	move.w	last_p_pos,d0
	bsr	return_bob
	move.w	last_o_pos,d0
	bsr	return_bob
	move.w	last_v_pos,d0
	bsr	return_bob

	move.l	#bob_v_pos,a6
	lea	bob_shifts+(16*16*2),a1
	bsr	do_bobs
	move.l	#bob_o_pos,a6
	lea	bob_shifts+(16*16),a1
	bsr	do_bobs
	move.l	#bob_p_pos,a6
	lea	bob_shifts,a1
	bsr	do_bobs
	rts

do_bobs	move.l	(a6),a0
	cmp.l	end_of_table,a0
	bne.s	.no_reset
	move.l	present_table,a0
.no_reset
	moveq	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.w	(a0)+,d0	;x
	move.w	(a0)+,d1	;y
	move.w	d0,d2
	move.l	a0,(a6)

	lsr.w	#1,d0
	and.w	#$1f8,d0

	and.w	#15,d2
	mulu	#16*6*16,d2

	add.w	d1,d0
	move.w	d0,4(a6)
	move.l	screen_base,a0
	add.w	d0,a0

	add.w	d2,a1
	lea	16*3*16(a1),a2
	REPT	16
	move.l	(a0),d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	and.l	d0,d2
	or.l	d1,d2
	move.l	d2,(a0)

	move.l	4(a0),d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	and.l	d0,d2
	or.l	d1,d2
	move.l	d2,4(a0)

	move.l	8(a0),d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	and.l	d0,d2
	or.l	d1,d2
	move.l	d2,8(a0)

	move.l	12(a0),d0
	move.l	(a1)+,d1
	move.l	(a2)+,d2
	and.l	d0,d2
	or.l	d1,d2
	move.l	d2,12(a0)

	add.w	#160,a0
	ENDR

	rts

return_bob
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pic+34,a0
	add.w	d0,a0
	REPT	16
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	ENDR
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
	jsr	tune+8
	clr.w	vsync_flag
	tst.w	zero_counter
	bne.s	dec_hertz
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	rte

dec_hertz
	sub.w	#1,zero_counter
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
	dc.w	$000,$555,$100,$555,$210,$555,$320,$555
	dc.w	$430,$555,$541,$555,$652,$555,$763,$555

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
old_base:	dc.l	0
counter:	dc.w	0
hertz_switch	dc.w	0

scroll_pointer:	dc.l	scroll_text+7
scroll_text:
 dc.b "                    PERSISTENCE OF VISION PACKED DEMO DISC 69.    "
 dc.b "ALL CODE BY MAC SYS DATA WITH GRAFIX BY OZ (SORRY I MADE THE "
 dc.b "PIC LOOK SO CLUTTERED).  "
 dc.b "THE BRILLIANT MUSIC IS BY MAD MAX AND WAS RIPPED FROM "
 dc.b "THE MEDWAYS BOYS (WRATH OF THE DEMON INTRO).   "
 DC.B "THIS DISC WAS CODED ON 6-4-91, TODAY IS A SPECIAL DAY 'CAUSE "
 DC.B "IT'S MY BIRTHDAY AND I'M 24 (OLD GIT).   THE TIME IS 19:06 "
 DC.B "AND YOU GET BET YOUR PANTS THAT I'LL BE DRINKING PLENTY "
 DC.B "OF THAITES BITTER TONIGHT.    ER, SPEAKING OF BETS, TODAY "
 DC.B "WAS THE GRAND NATIONAL BUT I FORGOT AND MISSED PUTTING A "
 DC.B "BET ON A TOTALLY DUFF HORSE THAT PROBABLY FELL AT THE FIRST FENCE!   "
 DC.B "   ANYWAY ONTO OTHER MATTERS...    IS THIS NOT AN EXCELLENT MENU?  "
 DC.B "  THE CODE TO MOVE ALL THE BITS AROUND IS PRETTY STRAIGHT "
 DC.B "FORWARD, THE MENU IS STUNNING BECAUSE WE HAVE THE "
 DC.B "BEST GRAFIX ARTIST IN LANCASHIRE - OZYMANDIAS.      "
 DC.B "P.O.V. COME FROM THE BLACKPOOL AREA AND ARE THE BEST DEMO "
 DC.B "PACKERS IN THE U.K.   YES, THERE ARE OTHER DEMO PACKERS WHO "
 DC.B "HAVE DONE MORE DISCS THAN WE HAVE BUT HAVE YOU SEEN THEIR MENUS? "
 DC.B "   WE PUT A CUSTOM MENU ONTO ALL OUR DISCS AND DO ALL OUR "
 DC.B "OWN CODING.    I HAVE SOME DEMO COMPILATIONS BY OTHER GROUPS "
 DC.B "AND THEY LOOK LIKE TRASH.   HOW CAN THEY GET AWAY WITH A 1 "
 DC.B "COLOUR SCROLLINE AND USE THE SAME TUNE ON 90 PERCENT OF THEIR DISCS? "
 DC.B "    I KNOW I'VE USE A 1 COLOUR SCROLLINE ABOUT TWICE BUT "
 DC.B "THAT WAS BECAUSE I WAS RUNNING TOP AND BOTTOM BORDER CODE "
 DC.B "WHICH INCORPORATED A SPECTRUM ANALYZER.   "
 DC.B "  TAKE A LOOK THROUGH THE P.O.V. DISCS AND SEE HOW MANY "
 DC.B "CRAPPY MENUS THERE ARE.................. WELL?       OKAY "
 DC.B "SO P.O.V. 63 WAS CRAP BUT BASICALLY SINCE DISC 22 WE HAVE RELEASED "
 DC.B "MENUS THAT LOOK AND SOUND GOOD.  THE WORST PART OF THE MENUS "
 DC.B "ARE MY SCROLL TEXTS WHICH CAN BE A BIT DODGY BUT THAT'S BECAUSE "
 DC.B "I RELEASE ABOUT A DISC A WEEK.   WHEN BORIS GETS BACK IN "
 DC.B "SUMMER WE WILL PROBABLY START RELEASING TWO DISCS A WEEK AS WE "
 DC.B "BOTH WILL BE CODING MENUS.       OKAY, IT'S TIME FOR SOME "
 DC.B "MORE OZ TALK SO OVER TO OUR GRAFIX ARTIST........      "
 DC.B "OZ HERE, AND TIME FOR ANOTHER RAMBLE.... WELL I'M LISTENING "
 DC.B "TO VIOLATOR BY DEPECHE MODE, AND IT'S REMINDED ME OF WHEN I "
 DC.B "SAW THEM ON THEIR WORLD VIOLATION TOUR AT HTE NEC.   STUNNING "
 DC.B "SHOW WITH PROJECTED VISUALS BY ANTON CORBIJN.  'WAITING FOR "
 DC.B "THE NIGHT' IS ON RIGHT NOW. AT THE CONCERT, THE LIGHTS WERE "
 DC.B "ALMOST OUT, AND EVERYONE HAD THEIR LIGHTERS HELD UP... "
 DC.B "QUITE AN EMOTIONAL ATMOSPHERE AND THE SOUND SYSTEM WAS "
 DC.B "SOOOOOO LOUD !!!!!    REACH OUT AND TOUCH FAITH !!!!!    "
 DC.B "I MAY AS WELL REVIEW SOME RECENTISH CD'S....    "
 DC.B "808 STATE....EX EL.   WOW WHAT A GREAT ALBUM! VERY "
 DC.B "INFLUENTIAL ON MY OWN BAND 'DIGITAL JUSTICE' AND QUITE "
 DC.B "INSPIRATIONAL FOR AN ARTIST....MY NEPHATITI PIC WAS "
 DC.B "INSPIRED BY THE SONG OF THE SAME NAME. FOUR STARS.       "
 DC.B "ELECTRIBE 101... THEY WERE THE SUPPORT ACT FOR "
 DC.B "DEPECHE MODE AT THE NEC, AND I WAS SO IMPRESSED THAT "
 DC.B "I WENT AND BOUGHT THE ALBUM AND T SHIRT. THEIR COVER OF "
 DC.B "INSIDE OUT IS UN-BLOODY-BELEIVEABLE!!!! FIVE STARS.       "
 DC.B "THE BELOVED...BLISSED OUT....  I BOUGHT THIS ON TAPE COZ "
 DC.B "YOU GET MORE TRACKS, AND IT IS A REMIX OF THE HAPPINESS ALBUM. "
 DC.B "SOME OF THE TRACKS ARE QUITE INCREDIBLE!! ACID LOVE IS A "
 DC.B "B SIDE FROM AN OLD SINGLE AND IS SO ATMOSPHERIC AND "
 DC.B "DANCEY AND GOOD !!!!!  FIVE STARS AGAIN.       "
 DC.B "BASSOMATIC... ERM.. A BIT OF A DISSAPOINTMENT THIS ONE, "
 DC.B "SO I TAPED IT AND TOOK IT BACK AND GOT THE ELECTRIBE 101 "
 DC.B "CD INSTEAD. IT WAS OK, BUT A BIT BORING AND IT HAS BEEN "
 DC.B "KNOWN TO SEND ME TO SLEEP... ERM   TWO STARS.      THAT'S "
 DC.B "ALL FOLKS.... I'LL LEAVE YOU WITH SOME DEPECHE MODE LYRICS "
 DC.B "THAT APPLY NICELY TO OUR TIMES....           YOU'LL SEE "
 DC.B "YOUR PROBLEMS MULTIPLY       WHEN YOU CONTINUILY DECEIDE     "
 DC.B "TO PAINFULLY PURSUE      A POLICY OF TRUTH       "
 DC.B "NEVER AGAIN IS WHAT YOU SWORE THE TIME BEFORE      "
 DC.B "NEVER AGAIN IS WHAT YOU SWORE THE TIME BEFORE        "
 DC.B "THANK YOU AND GOOD NIGHT.......... OZ TO ORSON, OVER AND OUT...."
 DC.B "     HELLO, IT'S ME (MAC SYS DATA).  OZ MENTIONED A "
 DC.B "NEPHATITI PIC IN HIS TEXT, WELL YOU AIN'T SEEN IT YET BUT "
 DC.B "I'LL TRY TO USE IT ABOUT DISC 72.      "
 dc.b "RIGHT-Y-O IT'S TIME TO QUIT AND GET THIS DISC FINISHED OFF "
 DC.B "SO UNTIL NEXT TIME... CHEERY-BYE!     "
 DC.B "                                     "
 dc.b $ff
	even
char_offset	dc.w	0
font:	dcb.b	124*4,0
	incbin	font.fnt"
font_offsets:
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,09,01,00,00,00,00,05,06,07,45,00,26,11,12,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	14,15,16,17,18,19,20,21,22,23,24,25,00,00,00,29,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	48,49,50,51,52,53,54,55,56,40,00,41,00,47,00,48,49,50

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
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
	even
tune:	incbin	WOTD.mus 
	even
pic	incbin	hand.PI1
	dcb.b	160,0
	even
ripple_table_pos	dc.l	init_ripple_table
init_ripple_table
	dcb.w	200,$0408
ripple_table
	incbin	sine1.dat
	incbin	sine1.dat
	incbin	sine2.dat
	incbin	sine2.dat
	incbin	sine3.dat
	incbin	sine4.dat
	incbin	sine5.dat
	incbin	sine6.dat
	incbin	sine3.dat
	incbin	sine7.dat
	incbin	sine8.dat
	incbin	sine9.dat
reset_ripple_flag
	incbin	sine1.dat

	even
bob_p_pos	dc.l	0
last_p_pos	dc.w	0
bob_o_pos	dc.l	0
last_o_pos	dc.w	0
bob_v_pos	dc.l	0
last_v_pos	dc.w	0

end_of_table	dc.l	endbobs
present_table	dc.l	bob1

bob1	incbin	bob1.dat
	incbin	bob2.dat
	incbin	bob3.dat
	incbin	bob4.dat
endbobs
bob_grafix	incbin	pov.dat
	even
zero_counter:	dc.w	0
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
filenames:
	dc.b	"BBC.MSD",0,0,0,0,0,0,0,0,0
	dc.b	"BIGSCROL.MSD",0,0,0,0
	dc.b	"SHADOW.MSD",0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

	SECTION BSS
old_pal:	ds.b	32
bob_shifts	ds.b	((16*16)*6)*16
ripple_data	ds.b	(96*59)*16
ripple_end
	ds.b	256
screen:	ds.b	32000

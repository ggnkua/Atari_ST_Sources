****************
* P.O.V. 57    *
****************
	bra	skip
	dc.b	"      ANOTHER BRILL MENU EH BORIS?????       "
 dc.b "OH YEAH... YOU WON'T FIND ANY ASCII TEXT IN THIS MENU 'COS "
 dc.b "I'VE CODED IT!!!!!!!!! HA-HA-HA-HA-HA-HA-HA-HA.......    "
	even
skip	bsr	set_super
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
	bsr	clear_below_screen
	move.b	$484,old484
	clr.b	$484

;Music from Pompey pirates 62
	move.l	#0,D0
	jsr	tune

	bsr	v_sync
	bsr	set_palette
	bsr	set_for_border
	bsr	show_pic

;set up bobs
	move.l	present_table,a1
	move.l	a1,bob_v_pos
	add.w	#16,a1
	move.l	a1,bob_o_pos
	add.w	#16,a1
	move.l	a1,bob_p_pos

	bsr	flush
main_loop:
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	bobs
;	move.w	#$700,$ffff8240.w
	bsr	scroll
;	move.w	pic+2,$ffff8240.w
	move.b	$fffffc02.w,d0

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	beq	zero

	cmp.b	#$70,d0		;keypad 0
	beq	zero
	
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#$53,d0
	beq	do_reset

	lea	sine_codes,a0
.sine	cmp.b	#$ff,(a0)
	beq.s	scan_for_keys
	cmp.b	(a0)+,d0
	beq.s	.new_sine
	move.b	(a0)+,d1
	bra.s	.sine
.new_sine
	move.b	(a0),d0
	and.w	#$ff,d0
	add.w	#1,d0
	cmp.w	old_table,d0	;compare old table + new to prevent
				;bobs being frozen due to keys being
				;held down.
	beq.s	main_loop	;same table so leave alone
	move.w	d0,new_table
	bra	main_loop

scan_for_keys
	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq	main_loop
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

zero	tst.w	zero_counter
	bne	aa
	eor.w	#$012,fontpal
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	bra	main_loop
zero_counter:	dc.w	0

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
bobs	move.w	last_p_pos,d0
	bsr	return_bob
	move.w	last_o_pos,d0
	bsr	return_bob
	move.w	last_v_pos,d0
	bsr	return_bob

	tst.w	new_table
	beq.s	.no_new_table
	moveq	#0,d0
	move.w	new_table,d1
	move.w	d1,old_table
	sub.w	#1,d1
	move.w	d0,new_table
	move.w	d1,d0
	lsl.w	#2,d0		;*4
	lea	tables,a1
	add.w	d0,a1
	move.l	(a1)+,a0
	move.l	a0,present_table
	move.l	a0,bob_v_pos
	add.w	#16,a0
	move.l	a0,bob_o_pos
	add.w	#16,a0
	move.l	a0,bob_p_pos
	move.l	(a1),end_of_table
.no_new_table
	move.l	#bob_v_pos,a6
	lea	logo+(16*16*2),a1
	bsr	do_bobs
	move.l	#bob_o_pos,a6
	lea	logo+(16*16),a1
	bsr	do_bobs
	move.l	#bob_p_pos,a6
	lea	logo,a1
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
	lea	pic+34,a2
	move.l	screen_base,a3
	move.w	#200-1,d6
	move.w	#%1111111100000000,d2
loop2	bsr	pause
	move.l	a2,a0
	move.l	a3,a1
	eor.w	#$ffff,d2
	REPT	20
	move.w	(a0),d0
	and.w	d2,d0
	move.w	d0,(a1)
	move.w	2(a0),d0
	and.w	d2,d0
	move.w	d0,2(a1)
	move.w	4(a0),d0
	and.w	d2,d0
	move.w	d0,4(a1)
	move.w	6(a0),d0
	and.w	d2,d0
	move.w	d0,6(a1)
	add.w	#8,a0
	add.w	#8,a1
	ENDR
	add.w	#160,a2
	add.w	#160,a3
	dbf	d6,loop2


	lea	pic+34,a2
	add.w	#160*199,a2
	move.l	screen_base,a3
	add.w	#160*199,a3
	move.w	#$ffff,d2
	move.w	#200-1,d6
loop3	bsr	pause
	move.l	a2,a0
	move.l	a3,a1
	REPT	20
	move.w	(a0),d0
	and.w	d2,d0
	move.w	d0,(a1)
	move.w	2(a0),d0
	and.w	d2,d0
	move.w	d0,2(a1)
	move.w	4(a0),d0
	and.w	d2,d0
	move.w	d0,4(a1)
	move.w	6(a0),d0
	and.w	d2,d0
	move.w	d0,6(a1)
	add.w	#8,a0
	add.w	#8,a1
	ENDR
	sub.w	#160,a2
	sub.w	#160,a3
	dbf	d6,loop3

pause	move.l	d0,-(sp)
	move.w	#2000,d0
.loop	nop
	dbf	d0,.loop
	move.l	(sp)+,d0
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
	lea	$ffff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
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
	bsr	tune+4
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
	movem.l	d0-d7,-(sp)
	movem.l	fontpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	clr.b	$fffffa1b.w	;DI all other interrupts
	bclr	#0,$fffa0f
	rte



********
* Data *
********
	SECTION DATA
fontpal:
	dc.w	$000,$776,$633,$744,$222,$522,$411,$210
	dc.w	$134,$245,$356,$467,$424,$525,$636,$757

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







scroll_pointer:	dc.l	scroll_text+7
scroll_text:
	incbin	s_text.dat
	dc.b $ff
	even

char_offset	dc.w	0
font:	dcb.b	124*4,0
	incbin	"was258.fnt"
font_offsets:
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,39,43,00,00,00,00,43,40,41,45,00,42,46,28,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	29,30,31,32,33,34,35,36,37,38,00,00,00,00,00,44,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,47,00,48,49,50

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
tune:	incbin	pp62.img
pic	incbin	POV57.PI1
	even

sine_codes
	dc.b	$3b,0	;F1
	dc.b	$3c,1	;F2
	dc.b	$3d,2	;F3
	dc.b	$3e,3	;F4
	dc.b	$3f,4	;F5
	dc.b	$40,5	;F6
	dc.b	$41,6	;F7
	dc.b	$42,7	;F8
	dc.b	$43,8	;F9
	dc.b	$44,9	;F10
	dc.b	$ff

	even

bob_p_pos	dc.l	0
last_p_pos	dc.w	0
bob_o_pos	dc.l	0
last_o_pos	dc.w	0
bob_v_pos	dc.l	0
last_v_pos	dc.w	0

old_table	dc.w	0
new_table	dc.w	0
end_of_table	dc.l	bob2
present_table	dc.l	bob1

tables	dc.l	bob1
	dc.l	bob2
	dc.l	bob3
	dc.l	bob4
	dc.l	bob5
	dc.l	bob6
	dc.l	bob7
	dc.l	bob8
	dc.l	bob9
	dc.l	bob10
	dc.l	endbobs

bob1	incbin	bob1.dat
bob2	incbin	bob2.dat
bob3	incbin	bob3.dat
bob4	incbin	bob4.dat
bob5	incbin	bob5.dat
bob6	incbin	bob6.dat
bob7	incbin	bob7.dat
bob8	incbin	bob8.dat
bob9	incbin	bob9.dat
bob10	incbin	bob10.dat
endbobs

logo	incbin	shifted.dat
	even

filenames:
	dc.b	"DOMINO.DEM",0,0,0,0,0,0
	dc.b	"MADONNA.DEM",0,0,0,0,0
	dc.b	"STARTREK.MSD",0,0,0,0
	dc.b	"COPIER.POV",0
	even
	SECTION BSS
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	32000

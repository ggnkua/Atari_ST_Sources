***************************
*        P.O.V. 65        *
*        ---------        *
* WRITTEN BY MAC SYS DATA *
***************************
;* Screen flipping menu
;* Present screen pointed to label PRESENT SCREEN
;

SPRITE_WIDTH	equ	5
SPRITE_DEPTH	equ	21

	bsr	set_super
	move.l	#msd,$24.w
msd	bsr	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	bsr	black_out
	move.l	screen_base,a0
	move.l	a0,present_base
	bsr	set_low_rez
	bsr	shift_pov
	bsr	intro
	move.b	$484,old484
	clr.b	$484

*** MAD MAX 1 ---- AXEL F

	move.l	#1,D0
	jsr	tune

	move.l	#tune+8,$4da
	bsr	cls
	bsr	set_palette
	bsr	show_pic
	bsr	set_for_border
	bsr	set_bounce_count
	bsr	flush
	bsr	disc_number
main_loop:
	bsr	flip_screen
;	move.w	#$123,$ffff8240.w
	bsr	return_screen
;	move.w	#$007,$ffff8240.w
	bsr	disc_number
;	move.w	#$040,$ffff8240.w
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
	eor.w	#$20,fontpal
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
;exit	bsr	isr_off
;	bsr	flush
;	move.l	old_base,a0
;	bsr	set_med_rez
;	bsr	restore_pal
;	move.b	#8,$fffffc02.w
;	move.b	old484,$484.w
;	bsr	user_mode
;	clr.w	-(sp)
;	trap	#1
;	addq.l	#4,sp
;	rts

***************
* Subroutines *
***************
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
	move.w	#SPRITE_DEPTH-1,d2
repeat
OFF	set	0
	REPT	SPRITE_WIDTH
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
OFF	SET OFF+4
	move.l	OFF(a0),(a1)+
;	move.l	#-1,OFF(a0)
OFF	SET OFF+4
	ENDR
	add.w	#160,a0
	dbf	d2,repeat

	add.w	#160*7,a0
	move.w	#SPRITE_DEPTH-1,d2
repeat2
OFF	set	0
	REPT	SPRITE_WIDTH
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
	move.w	#(SPRITE_DEPTH*2)+8-1,d6
.loop	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	add.w	#2,a0
	sub.w	d4,d4
	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	add.w	#2,a0
	sub.w	#8,a0
	add.w	#160,a0
	dbf	d6,.loop
	dbf	d7,shift_loop
	rts

return_screen
	move.l	last_position,d0
	move.l	last_base,a0
	add.w	d0,a0
	lea	pic+34,a1
	add.w	d0,a1
	REPT	SPRITE_DEPTH
	movem.l	(a1),d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,(a0)
	lea	160(a0),a0
	lea	160(a1),a1
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
	move.l	d0,last_position

	move.l	present_base,a0
	add.w	d0,a0
	lea	pov,a1		;grafix
	and.w	#$f,d2
	mulu	#(8*SPRITE_WIDTH*SPRITE_DEPTH),d2
	add.l	d2,a1		;grafix
	add.l	d2,a1		;mask
	lea	8*SPRITE_WIDTH*SPRITE_DEPTH(a1),a2	;masks
	move.w	#SPRITE_DEPTH-1,d7
.loop
	REPT	SPRITE_WIDTH
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
	add.w	#160-(SPRITE_WIDTH*8),a0
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
	mulu	#31*4*4,d0	;char depth * 4 *4
	add.w	d0,a0
	move.w	d6,d0
	mulu	#31*4,d0		;character depth * 4 (31*4)
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

vsync	move.w	#$ffff,vsync_flag
vs	tst.w	vsync_flag
	bne.s	vs
	rts

;set_screen
;	move.l	scr_now,d0
;	move.l	scr_xor,d1
;	eor.l	d1,d0
;	move.l	d0,scr_now
;	lsr.l	#8,d0
;	lea	$ffff8201.w,a0
;	movep.w	d0,(a0)
;	rts

flip_screen
	move.l	present_base,last_base
	move.l	screen_base,d0
	eor.w	#-1,screen_toggle
	beq.s	set
	add.l	#49152,d0
set	move.l	d0,present_base
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

cls	move.l	screen_base,a0
	move.w	#32000/4-1,d0
.cls	clr.l	(a0)+
	dbf	d0,.cls
	lea	pic+32032,a0
	moveq.l	#0,d7
	move.w	#18000/4-1,d0
.clear_below_pic
	move.l	d7,(a0)+
	dbf	d0,.clear_below_pic
	rts

show_pic:
	move.l	screen_base,a0
	lea	pic+34,a1
	move.w	#199,d0
.loop1	bsr	v_sync
	bsr	display_all
	add.w	#160,a0
	add.w	#160,a1
	dbf	d0,.loop1
	move.l	screen_base,a0
	move.l	a0,a1
	add.l	#49152,a1
	move.w	#32000/4-1,d0
copy	move.l	(a0)+,(a1)+
	dbf	d0,copy
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

display_last
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#160/4-1,d0
.loop1	move.l	(a1)+,(a0)+
	dbf	d0,.loop1
	lea	offset_table,a2
	add.w	d7,a2
.loop2	move.w	(a2)+,d2
	beq.s	.loop4
	move.l	a1,a3
	add.w	d2,a3
	move.w	#160/4-1,d1
.loop3	move.l	(a3)+,(a0)+
	dbf	d1,.loop3
	bra.s	.loop2
.loop4	movem.l	(sp)+,d0-d7/a0-a6
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
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
 	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	clr.l	$4da
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


intro	lea	intro_pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	lea	intro_pic+2,a1
	bsr	fadein
	move.w	#5000,d7
.pau	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	.ex
	dbf	d7,.pau
.ex	lea	black,a1
	bsr	fadein
	rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadein	MOVE #7,D6
	MOVE.L A1,A2
FADEIN1	LEA	PALREG,A0	;LEA PALREG+2,A0; TARGET IN A1
	move.w	#16-1,d7
FADEIN2	BSR	MODIFY
	addq.w	#2,a0
	addq	#2,a1
	dbf	d7,FADEIN2
	move.w	#4,d0
	BSR	WAIT
	MOVE.L A2,A1
	DBRA	D6,FADEIN1
	RTS

WAIT:	bsr	v_sync
	DBRA D0,WAIT
	RTS

PALREG:	EQU $FF8240

MODIFY:	MOVE (A0),D0 ;PALREG
	MOVE (A1),D1 ;TARGET
	MOVE D0,D4 ;NEW COL
	MOVE D0,D2
	MOVE D1,D3
	AND #$7,D2
	AND #$7,D3
	CMP D2,D3
	BEQ.S MOK1
	BMI.S MDN1
	ADDQ #1,D4
	BRA.S MOK1
 MDN1:	SUBQ #1,D4
 MOK1:	MOVE D0,D2
	MOVE D1,D3
	AND #$70,D2
	AND #$70,D3
	CMP D2,D3
	BEQ.S MOK2
	BMI.S MDN2
	ADD #$10,D4
	BRA.S MOK2
 MDN2:	SUB #$10,D4
 MOK2:	MOVE D0,D2
	MOVE D1,D3
	AND #$700,D2
	AND #$700,D3
	CMP D2,D3
	BEQ.S MOK3
	BMI.S MDN3
	ADD #$100,D4
	BRA.S MOK3
 MDN3:	SUB #$100,D4
 MOK3:	MOVE D4,(A0)
	RTS


*********
* ISRs  *
*********
vert_isr:
	movem.l	d0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#49,counter	;49 lines at 4 pixels each ISR
	move.l	#horiz_isr,$120.W
	jsr	tune+8
	clr.w	vsync_flag
	tst.w	zero_counter
	beq.s	not_z
	sub.w	#1,zero_counter
not_z	movem.l	(sp)+,d0-a6
	move.b	#8,$fffffa1b.w
	move.b	#3,$fffffa21.w
	rte

horiz_isr:
	move.b	#4,$fffffa21.w	;4 lines per isr 
	move.l	#go_border,$120.w
	rte

go_border
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan
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

lower_border
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
	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$120,$130,$240,$351,$461,$572,$774,$777

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
 dc.b "                   "
 dc.b "MAC SYS DATA AND CO. PRESENT.... PERSISTENCE OF VISION "
 DC.B "PACKED DEMO DISC 65.            "
 dc.b "ALL CODE BY MAC SYS DATA, GRAFIX BY OZ AND MUSIC BY MAD MAX.   "
 DC.B "THERE IS NOT A LOT OF SCROLL TEXT AS DISC SPACE IS TIGHT BUT "
 dc.b "HERE ARE THE GREETINGS.....  HI TO    "
 dc.b "ABC CREW,   AUTOMATION,   BLACK CATS,   DR.SYNE,   "
 DC.B "EMPIRE,   ERIK PLANKTON,   EQUINOX,   GEORGE,   "
 DC.B "INNER CIRCLE,   LOST BOYS,   MARTIAN,   MEDWAY BOYS,   "
 DC.B "OBERJE,   POMPEY PIRATES,   REPLICANTS,   RIPPED OFF,   "
 DC.B "SEWER SOFTWARE,   SLAYTANIC CULT,   TCB,   TEX   "
 DC.B "AND THE WATCHMEN.   WELL ANOTHER 1 MEG DISC IS FINISHED AND "
 DC.B "SO IS THIS SCROLL TEXT SO PRESS A KEY.... BYE!!    "
 DC.B "                           "
 DC.B "                                                  WRAP   "
 dc.b $ff
	even
char_offset	dc.w	0
font		dcb.b	31*4*4,0
		incbin	348.fnt
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
sine_count	dc.w	0
sine_number	dc.w	0
sine_table
	dc.w	0,0,0,0,0,0
	dc.w	1,1,1,1,1
	dc.w	2,2,2,2
	dc.w	3,3,3
	dc.w	4,4
	dc.w	5
	dc.w	6
	dc.w	8
	dc.w	10
	dc.w	8
	dc.w	6,5
	dc.w	4,4
	dc.w	3,3,3
	dc.w	2,2,2,2
	dc.w	1,1,1,1,1
	dc.w	$ffff
black	dcb.b	64,0

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
;	dc.b	5,3	;key 4
;	dc.b	6,4	;key 5

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
;	dc.b	$6a,3	;keypad 4
;	dc.b	$6b,3	;keypad 5
	dc.b	$ff
	even

******* show pic data *********
	dcb.w	160*70,0

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
*************************************************

last_position	dc.l	0
table_pos	dc.l	sine
sine	incbin	sine1.dat
	incbin	sine2.dat
	incbin	sine3.dat
	incbin	sine4.dat
	dc.w	$ffff,$ffff
	even


filenames:
	dc.b	"SCOOBY.MSD",0,0,0,0,0,0
	dc.b	"CODERS6.MSD",0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

;*************************
tune:	incbin	max1.mus
intro_pic
	incbin	intro.pi1
pov_pic	incbin	pov.pi1
pic	incbin	pov65.PI1


	SECTION BSS
	ds.b	18000
pov	ds.b	(SPRITE_DEPTH*(SPRITE_WIDTH*8)*16)*2
old_pal:	ds.b	32
	ds.b	256
screen:	ds.b	46000

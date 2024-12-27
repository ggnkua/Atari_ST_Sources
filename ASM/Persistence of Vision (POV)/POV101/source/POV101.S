**********************************
*
* Menu coded by MAC SYS DATA of P.O.V.................
*
*
**********************************

	OPT	o+,w-
	bsr	set_super
wait_for_drive
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	movem.l	spec_values,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	shift_pov
	bsr	clear_below_screen
	move.l	screen_base,a0
	add.l	#160*13,a0
	move.l	a0,spec_pos

;set up bobs
	move.l	present_table,a1
	move.l	a1,bob_v_pos
	add.w	#32,a1		;this alters the space between bobs
	move.l	a1,bob_o_pos
	add.w	#32,a1		;this alters the space between bobs
	move.l	a1,bob_p_pos

	move.b	$484.w,old484
	clr.b	$484.w

;************************************************************************
;*                ATOMINO TUNE						*
;*                ------------						*
;* Stolen by: MAC SYS DATA of P.O.V.                                    *
;*									*
;************************************************************************

	moveq	#1,d0	;only one tune
	jsr	tune

	bsr	set_palette
	bsr	save_isr
	bsr	vsync
	bsr	show_pic
	bsr	vsync
	bsr	flush
main_loop:
	bsr	vsync
;	move.w	#$070,$ffff8240.w
	bsr	bobs
;	move.w	#$770,$ffff8240.w
	bsr	scroll
;	move.w	#$700,$ffff8240.w
	bsr	clear_spec
;	move.w	#$007,$ffff8240.w
	bsr	calc_spec
;	move.w	pic+2,$ffff8240.w
	move.b	key,d0
	beq.s	main_loop

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	beq	zero
	cmp.b	#$70,d0
	beq	zero

no_switch
	cmp.b	#$53,d0
	beq.s	do_reset

	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

load	move.b	(a0),-(sp)
	bsr	flush
	bsr	reset_isr
bp	move.l	old_base,a0	;screen_base
	bsr	set_org_rez
	lea	$ffff8240.w,a1
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	move.b	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	mulu	#16,d0
	add.w	d0,a6
	lea	$200.w,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)
	tst.w	hertz_switch
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	bsr	user_mode
	clr.w	-(sp)
	trap	#1

do_reset
	move.l	4.w,a0
	jmp	(a0)

zero	tst.w	zero_counter
	bne	no_switch
	eor.w	#$ffff,hertz_switch
	move.w	#10,zero_counter
	move.w	hertz_switch,d0
	bne.s	.pal1
	movem.l	font_pal,d0-d7
	movem.l	d0-d7,present_pal
	bra	main_loop
.pal1	movem.l	font_pal+32,d0-d7
	movem.l	d0-d7,present_pal
	bra	main_loop

exit	bsr	reset_isr
	bsr	flush
	move.l	old_base,a0
	bsr	set_org_rez
	bsr	restore_pal
	move.b	#8,$fffffc02.w
	move.b	old484,$484.w
	bsr	user_mode
	clr.w	-(sp)
	trap	#1

***************
* Subroutines *
***************
bobs	move.w	last_p_pos,d0
	bsr	return_bob
	move.w	last_o_pos,d0
	bsr	return_bob
	move.w	last_v_pos,d0
	bsr	return_bob

	move.l	#bob_v_pos,a6
	lea	logo+(16*16)+(16*16),a1
	bsr.s	do_bobs
	move.l	#bob_o_pos,a6
	lea	logo+(16*16),a1
	bsr.s	do_bobs
	move.l	#bob_p_pos,a6
	lea	logo,a1
	bsr.s	do_bobs
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
	add.w	#160*29,a0

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
	add.w	#160*29,a1
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


shift_pov
	move.l	screen_base,a1
	add.w	#160*29,a1
	lea	pov,a0
	move.w	#6*16-1,d0
.loop	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	move.l	(a0)+,16(a1)
	move.l	(a0)+,20(a1)
	lea	160(a1),a1
	dbf	d0,.loop

	move.l	screen_base,a6
	add.w	#160*29,a6
	lea	logo,a1
	move.w	#16-1,d7
shift
	move.l	a6,a0
	addq.w	#8,a0
	move.w	#16*6-1,d3
.loop	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	add.w	#160,a0
	dbf	d3,.loop

	move.l	a6,a0
	move.w	#16*6-1,d3
.loop2	roxr.w	6(a0)
	roxr.w	14(a0)
	roxr.w	22(a0)
	add.w	#160,a0
	sub.w	d4,d4
	dbf	d3,.loop2

	sub.w	d4,d4
	move.l	a6,a0
	move.w	#16*6-1,d3
.loop3	roxr.w	4(a0)
	roxr.w	12(a0)
	roxr.w	20(a0)
	add.w	#160,a0
	sub.w	d4,d4
	dbf	d3,.loop3

	sub.w	d4,d4
	move.l	a6,a0
	move.w	#16*6-1,d3
.loop4	roxr.w	2(a0)
	roxr.w	10(a0)
	roxr.w	18(a0)
	add.w	#160,a0
	sub.w	d4,d4
	dbf	d3,.loop4

	sub.w	d4,d4
	move.l	a6,a0
	move.w	#16*6-1,d3
.loop5	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	add.w	#160,a0
	sub.w	d4,d4
	dbf	d3,.loop5
	dbf	d7,shift
	rts






******************************
*                            *
* Spectrum Analyser routines *
*                            *
******************************

MAX_BARS	equ	80
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

clear_spec
	move.l	screen_base,a1
	lea	160(a1),a1
	moveq	#0,d0
	REPT	(20*26)
	move.w	d0,(a1)
	addq.w	#8,a1
	ENDR
	rts

calc_spec
	lea	spec_values,a0
	moveq	#(MAX_BARS-1),d0
.cnt_down
	tst.w	(a0)+
	beq.s	.next
	subq.w	#1,-2(a0)
.next
	dbf	d0,.cnt_down

	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_data,a3
	moveq	#12,d2

	move.b	#AAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	bchan
	moveq	#0,d0
	move.b	#ACOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	bchan
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************
bchan
	move.b	#BAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	cchan
	moveq	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	cchan
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************
cchan
	move.b	#CAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	ps
	moveq	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	ps
	add.w	d0,d0
	move.w	d2,(a2,d0)

******************** print speccy *******************
ps
	move.l	screen_base,a0
	add.l	#(13*160),a0

	lea	spec_values,a2
	moveq	#(80/4)-1,d1
.loop
	move.w	(a2)+,d0
	beq.s	.nib2
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%11100000,d2
.loop1	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2
	move.w	(a2)+,d0
	beq.s	.nib3
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	move.w	(a2)+,d0
	beq.s	.nib4
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%11100000,d2
.loop3	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	move.w	(a2)+,d0
	beq.s	.nonib
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%00001110,d2
.loop4	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4

.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts

**************************************************
scroll:	move.l	screen_base,a1
	add.l	#160*232,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#31*4*4,d0		;30 * 4 (4 planes)
	add.w	d0,a0
	move.w	d6,d0
	mulu	#31*4,d0	;character depth * 4 (30*4)
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

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
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
set_p:	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

calc_screen:
	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,screen_base
	rts

set_org_rez
	move.w	original_rez,-(sp)
	bra.s	set_rez

set_med_rez
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
	add.w	#160*29,a1
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
	move.w	#30,d0
clr1:	move.w	#8*40-1,d1
clr2:	clr.l	(a0)+
	dbf	d1,clr2
	dbf	d0,clr1
	rts

flush	btst.b	#0,$fffffc00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffc02.w,d0
	bra.s	flush
flush2	rts

*********
* ISRs  *
*********
save_isr
	move.w	#$2700,sr
	move.l	$120.w,old120
	move.l	$118.w,old118
	move.l	$70.w,old70
	move.b	$fffffa11.w,save1
	move.b	$fffffa21.w,save2
	move.b	$fffffa07.w,save3
	move.b	$fffffa09.w,save4
	move.b	$fffffa0f.w,save5
	move.b	$fffffa13.w,save6
	move.b	$fffffa1b.w,save7
	move.b	$fffffa1d.w,save8
	clr.b	$fffffa1d.w
	andi.b	#$df,$fffffa09.w
	andi.b	#$fe,$fffffa07.w
	move.l	#new120,$120.w
	move.l	#new70,$70.w
	move.l	#new118,$118.w
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	move.b	#8,$fffffa1b.w
	move.w	#$2300,sr
	rts

reset_isr
	move.w	#$2700,sr
	move.l	old120,$120.w
	move.l	old118,$118.w
	move.l	old70,$70.w
	move.b	save3,$fffffa07.w
	move.b	save6,$fffffa13.w
	move.b	save4,$fffffa09.w
	move.b	save7,$fffffa1b.w
	move.b	save8,$fffffa1d.w
	move.b	save2,$fffffa21.w
	move.b	save1,$fffffa11.w
	move.b	save5,$fffffa0f.w
	moveq.l	#0,d0
	bsr	tune
	lea	$ffff8800.w,a0
	move.b	#7,(a0)
	move.b	(a0),d1
	ori.b	#$3f,d1
	moveq.w	#$c,d0
.loop	move.b	d0,(a0)
	clr.b	2(a0)
	dbf	d0,.loop
	move.b	#7,(a0)
	move.b	d1,2(a0)
	move.w	#$2300,sr
	rts

new120	clr.b	$fffffa1b.w		;lower border routine
	move.l	d0,-(sp)
	moveq	#$26,d0
.aaa	dbf	d0,.aaa
	move.b	#0,$ffff820a.w
	moveq	#1,d0
.bbb	dbf	d0,.bbb
	move.b	#2,$ffff820a.w
	move.w	present_pal,$ffff8240.w
	move.w	present_pal+2,$ffff8242.w
	move.w	present_pal+4,$ffff8244.w
	move.w	present_pal+6,$ffff8246.w
	move.w	present_pal+8,$ffff8248.w
	move.w	present_pal+10,$ffff824a.w
	move.w	present_pal+12,$ffff824c.w
	move.w	present_pal+14,$ffff824e.w
	move.w	present_pal+16,$ffff8250.w
	move.w	present_pal+18,$ffff8252.w
	move.w	present_pal+20,$ffff8254.w
	move.w	present_pal+22,$ffff8256.w
	move.w	present_pal+24,$ffff8258.w
	move.w	present_pal+26,$ffff825a.w
	move.w	present_pal+28,$ffff825c.w
	move.w	present_pal+30,$ffff825e.w
	bclr	#0,$fffffa0f.w
	clr.b	$fffffa1b.w
	move.l	(sp)+,d0
	rte

new70	move.w	#$2700,sr
	movem.l	d0-d7/a0,-(sp)
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	move.w	d0,-(sp)

	move.w	#$57e-2,d0
.aaa	dbf	d0,.aaa
	clr.b	$ffff820a.w
	moveq	#1,d0
.bbb	dbf	d0,.bbb

	move.w	#27-1,d0
	lea	colours,a0

	move.b	#2,$ffff820a.w


	clr.b	$fffffa1b.w
	move.b	#$e4,$fffffa21.w
	move.b	#8,$fffffa1b.w

.loop
	REPT	121
	NOP
	ENDR
	move.w	(a0)+,$ffff8242.w
	dbf	d0,.loop

	move.w	(sp)+,d0
	move.l	(sp)+,a0

	move.w	pic+4,$ffff8242.w
	clr.w	vsync_flag

	movem.l	d0-d7/a0-a6,-(sp)
	jsr	tune+8
	movem.l	(sp)+,d0-d7/a0-a6


	tst.w	zero_counter
	bne.s	dec
	rte

dec	subq.w	#1,zero_counter
	rte


new118	move.w	#$2500,sr
	move.b	$fffffc02.w,key
	bclr	#6,$fffffa11.w
	rte

********
* Data *
********
	SECTION DATA
screen_base	dc.l	0
original_rez	dc.w	0
old484		dc.w	0
zero_counter	dc.w	0
hertz_switch	dc.w	0
stack_save	dc.l	0
vsync_flag	dc.w	0
spec_pos	dc.l	0
old70		dc.l	0
old120		dc.l	0
old118		dc.l	0
key		dc.w	0
save1		dc.b	0
save2		dc.b	0
save3		dc.b	0
save4		dc.b	0
save5		dc.b	0
save6		dc.b	0
save7		dc.b	0
save8		dc.b	0
	even
old_base	dc.l	0
char_offset	dc.w	0

scroll_pointer	dc.l	init_scroll_text+7
init_scroll_text
 dc.b "                                                "
scroll_text
 dc.b "MAC SYS DATA PRESENTS - "
 dc.b "PERSISTENCE OF VISION 101.       RELEASE DATE 10TH DECEMBER 1991.    "
 dc.b "CODING AND MUSIC RIPPING BY MAC SYS DATA WITH GRAFIX BY OZ. "
 dc.b "  THE MUSIC IS FROM ATOMINO AND WAS WRITTEN BY THAT MAD HATTER MAX. "
 dc.b "    YO DUDES, YES THIS IS DISC 101 - WE BROKE THE CENTURY WITH STYLE.    "
 DC.B "   WE THINK WE ARE THE 5TH CREW TO REACH 100, THE DATE SHOULD PROVE IT.    "
 DC.B "    HEY SOURCE - WE BEAT YOU TO REACH 100!!!      YEAH!       JUST "
 DC.B "LOOK AT THIS DISC....... 7 DEMOS AND THE COPIER.       WHEN P.O.V. "
 DC.B "DO A COMPILATION THEY DO IT PROPERLY, WE DO NOT PUT MODS OR ANY OTHER CRAP "
 DC.B "ON THE DISC TO FILL IT UP UNLIKE OTHER CREWS I KNOW.      I WAS LOOKING "
 DC.B "AT ANOTHER CREWS DISCS THE OTHER DAY AND I DECIDED TO RUN A COUPLE "
 DC.B "OF DEMOS.    THE FIRST WAS A SAMPLE DEMO, IT LOADED AND STRAIGHT AWAY "
 DC.B "I COULD TELL IT WASN'T RIGHT. THE SAMPLE WAS VERY CRACKLY, I QUICKLY "
 DC.B "PUT THE P.O.V. PACKED DEMO ON AND IT WAS PERFECT.    THIS IS A TRICK "
 DC.B "THAT NEARLY EVERY OTHER DEMO PACKING CREW USES, THAT IS TO ALTER "
 DC.B "THE SAMPLE SO IT PACKS SMALLER BUT THE RESULT IS A POORER QUALITY "
 DC.B "SOUND.   WHEN WE AT P.O.V. PACK A SAMPLE DEMO IT IS PLAYED WITH "
 DC.B "THE SAME QUALITY AS IT WAS ORIGINALLY WRITTEN.       BACK TO THE "
 DC.B "OPPOSITIONS DISCS,    I LOADED A FEW OTHER BITS AND BOBS AND THEY "
 DC.B "WERE ALL PACKED WITH THE AUTOMATION CHUNKY PACKER.      THE LAMERS "
 DC.B "HAD NOT EVEN BOTHERED TO DETECT HOW MANY BYTES WERE LOADING TO MAKE "
 DC.B "A CUSTOM PACK OF THE DEMO.  THEY'D SIMPLY PACKED THE DATA "
 DC.B "IN ONE BIG BLOCK AND HAD USED THE CHUNKY OPTION TO SORT OUT THE LOADING. "
 DC.B "NOW THE CHUNKY PACKER "
 DC.B "OFTEN CREATED BIGGER BLOCKS THAN A SINGLE PASS PACK SO THE FILE WAS "
 DC.B "LARGER THAN IT SHOULD HAVE BEEN --- LAMERS!! "
 DC.B "    I MUST POINT OUT AT THIS POINT THAT BOTH P.O.V. AND RIPPED OFF "
 DC.B "ACTUALLY LOOK AT WHAT IS LOADING SO WE CAN MAKE THE MOST "
 DC.B "EFFICIENT PACK OF A DEMO.   WE ONLY USE CHUNKY WHEN PACKING "
 DC.B "SEQUENCE FILES FROM CYBERPAINT AS THESE LOAD LOTS OF BLOCKS "
 DC.B "OF SIMILAR SIZES AND ARE A PAIN TO PACK MANUALLY.         "
 DC.B "        RIGHT SOD THIS, HERE ARE THE GREETINMGS         NORTHSIDE,    "
 DC.B "NOW 5,    THUNDERFORCE,    THE SOURCE,    RIPPED OFF,    CAPTAIN HACKS,    "
 DC.B "GEORGE THE BART,    DEL,    NINJA OF THE ENTERPRISE,    DR.SYNE,    "
 DC.B "SLAYTANIC CULTS,    SEWER SOFTWARE,    BBC,    PIXEL TWINS,    "
 DC.B "D-BUG    AND    KGB.                  "
 dc.b "ON FUTURE DISCS I WILL TRY TO GET RID OF A LOAD OF OLD DEMOS "
 DC.B "THAT I HAVE SITTING AROUND.    THE DEMOS ARE MAINLY SAMPLES BUT "
 DC.B "THERE ARE SEVERAL PICTURE SHOWS AND I SHOULD BE DOING A FEW "
 DC.B "MODULE DISCS.      "
 dc.b "OH WELL, IT'S HERE ----- THE WRAP   BYE.        "
 DC.B "                                             "
 dc.b "                                             "
 dc.b $ff
	even
; colours for the spectrum analyzer rasters.....
colours	dc.w	$001,$002,$003,$004,$005,$006,$007,$017
	dc.w	$027,$036,$046,$057,$067
	dc.w	$310,$420
	dc.w	$530,$640,$750,$760,$670,$570,$460,$350
	dc.w	$240,$130,$020


present_pal
	dc.w	$000,$210,$320,$430,$540,$650,$760,$770
	dc.w	$774,$775,$070,$006,$203,$314,$435,$777

; lower border palette
font_pal	dc.w	$000,$210,$320,$430,$540,$650,$760,$770
		dc.w	$774,$775,$070,$006,$203,$314,$435,$777

	dc.w	$000,$002,$003,$004,$005,$006,$007,$017
	dc.w	$027,$037,$070,$006,$440,$550,$660,$777

font	dcb.b	31*4*4,0
	incbin	"4plane.fnt"
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	00,34,36,00,00,00,00,35,28,29,00,00,31,32,33,00

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	37,38,39,40,41,42,43,44,45,46,27,25,00,00,00,30,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,00,00,00,00,00,00,00

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

	even

tune	incbin	atom_1.mus
	even
pic	incbin	fender.PI1
	even

bob_p_pos	dc.l	0
last_p_pos	dc.w	0
bob_o_pos	dc.l	0
last_o_pos	dc.w	0
bob_v_pos	dc.l	0
last_v_pos	dc.w	0

end_of_table	dc.l	endbobs
present_table	dc.l	bob1

bob1
	incbin	bob1.dat
	incbin	bob2.dat
	incbin	bob3.dat
	incbin	bob4.dat
	incbin	bob5.dat
	incbin	bob6.dat
	incbin	bob7.dat
endbobs
	even
pov	incbin	bob.dat
	even

key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
	dc.b	7,5	;key 6
	dc.b	8,6	;key 7
	dc.b	9,7	;key 8

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$6c,5	;keypad 6
	dc.b	$67,6	;keypad 7
	dc.b	$68,7	;keypad 8
	dc.b	$ff
	even

; filenames are 16 bytes long (an old menu!!!)
filenames
	dc.b	"SCC2.PRG",0,0,0,0,0,0,0,0
	dc.b	"SCC3.PRG",0,0,0,0,0,0,0,0
	dc.b	"SCC4.PRG",0,0,0,0,0,0,0,0
	dc.b	"SCC5.PRG",0,0,0,0,0,0,0,0
	dc.b	"ABC4",0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"CONVENTN.PRG",0,0,0,0
	dc.b	"SYNC.PRG",0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.w	80,0

	SECTION BSS
old_pal	ds.b	32
logo	REPT	16
	ds.b	16*8*6
	ds.b	16*8*6
	ENDR

	ds.b	256
screen	ds.b	48000

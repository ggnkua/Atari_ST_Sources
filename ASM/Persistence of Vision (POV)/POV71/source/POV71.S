****************
* P.O.V. 71    *
****************
	OPT	o+
	bsr	set_super
wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive
	move.b	#$12,$fffffc02.w
	bsr	save_pal
	bsr	get_base
	bsr	calc_screen
	movem.l	spec_values,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	shift_pov
	move.l	screen_base,a0	;screen_base
	bsr	set_low_rez
	bsr	clear_below_screen
	move.l	screen_base,a0
	add.l	#160*13,a0
	move.l	a0,spec_pos

;set up bobs
	move.l	present_table,a1
	move.l	a1,bob_v_pos
	add.w	#16,a1
	move.l	a1,bob_o_pos
	add.w	#16,a1
	move.l	a1,bob_p_pos

	move.b	$484.w,old484
	clr.b	$484.w

;************************************************************************
;*                       KILLING GAME SHOW                              *
;*                       -----------------                              *
;* Stolen by: MAC SYS DATA of P.O.V. 14/04/91 12:35                     *
;*      From: KILLING GAME SHOW DEMO FROM ST USER                       *
;* Include files:-                                                      *
;*                 KILLING.IMG into TUNE                                *
;************************************************************************
;* Tune written by COUNT ZERO 11/12/90
;*
;* Nic Alderton
;* 16 redington road
;* London
;* NW3 7RG
;*
;* TEL: 071-431-4915
;*
;*

;****************************************************************
; There is more than one tune in this code....
; 0=Stop sound
; 1-21 =sound effects
; 22=tune 1
; 23=tune 2 (in game tune -ABSOLUTELY BRILLIANT!!!!!!!)
; 24=tune 3
	moveq.l	#23,D0
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
	bsr	spec
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
	bsr	set_low_rez
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
	lea	$200,a0
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
	eor.w	#$100,font_pal
	move.w	#10,zero_counter
	bra	main_loop

exit	bsr	reset_isr
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
bobs	move.w	last_p_pos,d0
	bsr	return_bob
	move.w	last_o_pos,d0
	bsr	return_bob
	move.w	last_v_pos,d0
	bsr	return_bob

	move.l	#bob_v_pos,a6
	lea	logo+(16*16*2),a1
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

clear_spec
	lea	spec_values,a0
	move.w	#(80/4)-1,d0
.cnt_down
	move.b	(a0)+,d1	
	beq.s	.next
	subq.b	#1,-1(a0)
.next	move.b	(a0)+,d1	
	beq.s	.next2
	subq.b	#1,-1(a0)
.next2	move.b	(a0)+,d1	
	beq.s	.next3
	subq.b	#1,-1(a0)
.next3	move.b	(a0)+,d1	
	beq.s	.next4
	subq.b	#1,-1(a0)
.next4	dbf	d0,.cnt_down

	move.l	spec_pos,a0
	sub.w	#(12*160),a0
	moveq	#0,d1
	REPT	25
	move.w	d1,(a0)
	move.w	d1,8(a0)
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	move.w	d1,32(a0)
	move.w	d1,40(a0)
	move.w	d1,48(a0)
	move.w	d1,56(a0)
	move.w	d1,64(a0)
	move.w	d1,72(a0)
	move.w	d1,80(a0)
	move.w	d1,88(a0)
	move.w	d1,96(a0)
	move.w	d1,104(a0)
	move.w	d1,112(a0)
	move.w	d1,120(a0)
	move.w	d1,128(a0)
	move.w	d1,136(a0)
	move.w	d1,144(a0)
	move.w	d1,152(a0)
	lea	160(a0),a0
	ENDR
	rts
	
************************************************
AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	
AAMP	equ	8
BAMP	equ	9
CAMP	equ	10

spec	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_lookup,a3

	moveq.l	#0,d0
	move.b	#AAMP,(a1)
	move.b	(a1),d0
	beq.s	bchan
	move.b	#ACOURSE,(a1)		;A course tune
	move.b	(a1),d0
	and.b	#$f,d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)	;A fine tune
	move.b	(a1),d0
	tst.w	d0
	beq.s	bchan

	move.w	#80-1,d1
loopa	cmp.w	(a3),d0
	bgt.s	bchan
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,loopa
	bra.s	bchan
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)

******************
bchan
	moveq.l	#0,d0
	move.b	#BAMP,(a1)
	move.b	(a1),d0
	beq.s	cchan
	lea	spec_lookup,a3
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	and.b	#$f,d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	cchan

	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	cchan
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,.loop
	bra.s	cchan
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)
******************
cchan	moveq.l	#0,d0
	move.b	#CAMP,(a1)
	move.b	(a1),d0
	beq.s	ps

	lea	spec_lookup,a3
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	and.b	#$f,d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	ps

	move.w	#80-1,d1
.loop	cmp.w	(a3),d0
	bgt.s	.yes
	beq.s	.yes
	addq.w	#4,a3
	dbf	d1,.loop
	bra.s	ps
.yes	move.w	2(a3),d0
	move.b	#12,(a2,d0.w)


******************** print speccy *******************
ps	move.l	spec_pos,a0
	lea	spec_values,a2
	move.w	#(80/4)-1,d1
.loop	move.l	a0,a1
	move.l	a0,a3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib2
	and.w	#$ff,d0
	move.b	#%11100000,d2
.loop1	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2	move.b	(a2)+,d0
	beq.s	.nib3
	and.w	#$ff,d0
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib4
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%11100000,d2
.loop3	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	moveq.l	#0,d0
	move.b	(a2)+,d0
	beq.s	.nonib
	move.l	a0,a1
	move.l	a0,a3
	move.b	#%00001110,d2
.loop4	or.b	d2,1(a1)
	or.b	d2,1(a3)
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
	mulu	#32*4*4,d0		;30 * 4 (4 planes)
	add.w	d0,a0
	move.w	d6,d0
	mulu	#32*4,d0	;character depth * 4 (30*4)
	add.w	d0,a0

.column
OFF	set	0
	REPT	32
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
	move.l	#coderte,$24.w
	rts

coderte	rte

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

endmusic:
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
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
	move.w	font_pal,$ffff8240.w
	move.w	font_pal+2,$ffff8242.w
	move.w	font_pal+4,$ffff8244.w
	move.w	font_pal+6,$ffff8246.w
	move.w	font_pal+8,$ffff8248.w
	move.w	font_pal+10,$ffff824a.w
	move.w	font_pal+12,$ffff824c.w
	move.w	font_pal+14,$ffff824e.w
	move.w	font_pal+16,$ffff8250.w
	move.w	font_pal+18,$ffff8252.w
	move.w	font_pal+20,$ffff8254.w
	move.w	font_pal+22,$ffff8256.w
	move.w	font_pal+24,$ffff8258.w
	move.w	font_pal+26,$ffff825a.w
	move.w	font_pal+28,$ffff825c.w
	move.w	font_pal+30,$ffff825e.w
	bclr	#0,$fffffa0f.w
	clr.b	$fffffa1b.w
	move.l	(sp)+,d0
	rte

new70	move.w	#$2700,sr
	movem.l	d0-d7,-(sp)
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	move.w	d0,-(sp)
	move.w	#$57e,d0
.aaa	dbf	d0,.aaa
	clr.b	$ffff820a.w
	moveq	#1,d0
.bbb	dbf	d0,.bbb
	move.b	#2,$ffff820a.w
	clr.w	vsync_flag
	clr.b	$fffffa1b.w
	move.b	#$e4,$fffffa21.w
	move.b	#8,$fffffa1b.w

	clr.w	$ffff8242.w
	move.l	a0,-(sp)
	lea	colours,a0
	move.w	#26-1,d0
.loop	REPT	121
	NOP
	ENDR
	move.w	(a0)+,$ffff8242.w
	dbf	d0,.loop
	move.w	pic+4,$ffff8242.w
	move.l	(sp)+,a0
	move.w	(sp)+,d0
	jsr	tune+6

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
counter		dc.w	0
char_offset	dc.w	0

scroll_pointer:	dc.l	init_scroll_text+7
init_scroll_text
 dc.b "                                           "
 dc.b "..........................................."
scroll_text:
 dc.b " MAC SYS DATA PRESENTS - "
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 71.       "
 dc.b "CODING AND MUSIC RIPPING BY MAC SYS DATA WITH GRAFIX BY OZ. "
 dc.b "  THE EXCELLENT MUSIC "
 DC.B "IS BY THE SUPERB COUNT ZERO, RIPPED "
 DC.B "FROM KILLING GAME SHOW DEMO (ON ST-USER DISC MAY '91). "
 dc.b "   I LOVE THIS MUSIC, I THINK IT'S THE BEST THE "
 DC.B "COUNT HAS DONE (HI NIK!).      "
 dc.b "NOW DOES THIS MENU LOOK GOOD OR WHAT????? "
 DC.B "  THE DOOZY SPECTRUM ANALYZER HAS RETURNED IN GOOD FASHION WEARING "
 DC.B "SOME 28 COLOURS, THE PIC HAS 16 COLOURS AND THE FONT CAN HAVE 16 "
 DC.B "COLOURS WHICH MEANS THERE ARE,     ER,     16 PLUS 28,     ER,  "
 DC.B "    PLUS 16,      THAT'S 12 COLOURS!      NO IT'S, I PRESSED "
 DC.B "THE WRONG BUTTON ON MY CALCULATOR,      ER,      IT'S 28 PLUS 16 PLUS 16  SO "
 DC.B "THAT'S      58 COLOURS!!!    ( I REALLY MUST GET A NEW SUN FOR "
 DC.B "MY SOLAR CALCULATOR! )         "
 DC.B "HAVE YOU ALL READ ABOUT THE NEW DISC DRIVES COMING OUT?     "
 DC.B "WELL THE DISC IN YOUR ST RIGHT NOW IS A 1 MEG DISC (UNFORMATTED), "
 DC.B "IBM PS2 SYSTEMS HAVE A 2 MEG DISC DRIVE AND AVAILABLE SOON "
 DC.B "IS A 4 MEG DISC DRIVE.   JUST THINK YOU COULD PUT SOME 3.4 MEG "
 DC.B "OF PROGRAMS ON YOUR FLOPPY DISCS.        THE FLOPPY IN YOUR ST GOES "
 DC.B "ROUND AT 300 RPM, THE NEW DRIVE WHIZZES IT'S DISCS AROUND AT 3000 RPM. "
 DC.B "      NOW WHAT HAPPENS WHEN YOU "
 DC.B "PUT THAT NASTY, CHEAP, LIGHT BLUE COLOURED DISC OF YOUR MATES "
 DC.B "INTO THE DRIVE?       JEP!  GOBBLE, GOBBLE, CRUNCH, CRACK  AND  "
 DC.B "KAPUT!     OUT COMES A DISC IN 2000 BITS JUST LIKE WHEN "
 DC.B "YOU LEFT ONE IN YOUR JEANS POCKET AND YOUR MUM PUT IT INTO "
 DC.B "THE WASHING MACHINE!!!!        THE PRICE OF THE NEW DRIVES "
 DC.B "IS ESTIMATED TO BE ABOUT 100 QUID AND THEY SHOULD BE READILY "
 DC.B "AVAILABLE IN NOVEMBER 1991.          "
 dc.b "I THINK IT'S ABOUT TIME FOR THE MOTORWAY SCENE REVIEW.... "
 DC.B "       IF I SEE ANOTHER RED METRO (X OR W REDG) THAT PULLS "
 DC.B "OUT FROM THE SLIP ROAD AND INTO THE SECOND LANE "
 DC.B "STRAIGHT IN FRONT OF ME AND THEN DOES 50 MPH, I'LL PULL "
 DC.B "IN FRONT OF IT AND SLAM MY BRAKES ON THEN GET OUT AND MAKE "
 DC.B "THE DRIVER'S HEAD INTO RED JELLY.         I HAVE MADE A "
 DC.B "HOT LIST OF CARS TO AVOID.......        1: ORION DRIVERS "
 DC.B "WHO STICK IN THE MIDDLE LANE DOING 60 MPH,        "
 DC.B "2: METRO DRIVERS WHO DON'T LOOK WHAT'S IN THE NEXT LANE,      "
 DC.B "3: SIERRA AND VOLVO DRIVERS WHO ACT LIKE THEY OWN THE ROAD,      "
 DC.B "4: ANY DRIVER WHO PULLS OUT AND THEN INDICATES AND WONDERS "
 DC.B "WHY YOU BLOW YOUR HORN AND TAKE SERVERE ACTION TO AVOID "
 DC.B "A COLLISION.      "
 DC.B "            "
 DC.B "OK IT'S GREETINGS TIME AGAIN.... HI TO   "
 DC.B "AUTOMATION,   MEDWAY BOYS,   POMPEY PIRATES,   "
 DC.B "GEORGE,   SKUNK,   DR.SYNE,   DTB,   ERIK PLANKTON,   "
 DC.B "INNER CIRCLE,   THE UNION,   THE REPLICANTS,   "
 DC.B "TCB,   THE LOST BOYS,   THE DEMO CLUB,   "
 DC.B "SEWER SOFTWARE,   RIPPED OFF,   MARTIAN   AND   THE WATCHMEN.        "
 dc.b "      I HAVE JUST BEEN TALKING TO MARTIAN ABOUT "
 dc.b "A CERTAIN PD LIBRARY, I'LL TELL YOU STRAIGHT AWAY "
 DC.B "THAT IT IS GOODMAN PDL.      REMEMBER P.O.V. 56?   "
 DC.B "WELL THERE IS A DEMO CALLED 'FRENCH KISS' OR "
 DC.B "THE 'BIMBO DEMO'.     THE DEMO SAYS ON THE MAIN SCREEN "
 DC.B "'EXCLUSIVE TO GOODMAN PDL', NOW WE RECEIVED IT FROM ANOTHER "
 DC.B "PD LIBRARY AND SEEING IT IS PD, PACKED IT.      MIKE GOODMAN "
 DC.B "DIDN'T LIKE THIS AS HE SAYS HE PAID THE PROGRAMMER TO WRITE "
 DC.B "THE DEMO AND STILL PAYS HIM ROYALTIES FOR EVERY COPY SOLD. "
 DC.B "   WELL HE WANTED US TO TAKE IT OFF THE MENU BUT WE SAID NO 'COS "
 DC.B "IT'S PD AND FREE TO COPY AND WE HAVE NOT BROKEN THE COPYRIGHT "
 DC.B "BECAUSE WE HAVN'T CHANGED THE DEMO IN ANY WAY (APART FROM PACKING "
 DC.B "IT BUT THAT DOESN'T CHANGE THE CODE OR THE MESSAGE ON THE TITLE "
 DC.B "SCREEN).     WE WERE THEN PUT IN CONTACT WITH THE AUTHOR "
 DC.B "OF THE DEMO AND HE SAID HE DIDN'T LIKE THE DEMO "
 DC.B "ON THE DISC BUT WE STILL SAID IT WAS PD AND THE PROGRAMMER "
 DC.B "SHUT UP.    NOW WE CAN'T SEE WHY WE SHOULD REMOVE IT 'CAUSE "
 DC.B "IT IS PD SOFTWARE AND IS DISTRIBUTED FROM MANY PD "
 DC.B "LIBRARIES AROUND THE COUNTRY NOT JUST GOODMAN PDL.   "
 dc.b "BECAUSE MR.GOODMAN SAYS "
 DC.B "I PAID THE GUY TO WRITE IT DOES NOT MAKE IT DIFFERENT TO "
 DC.B "ANY OTHER PD DEMO DOES IT?    MR. GOODMAN HAS NOW "
 DC.B "TAKEN ALL THE P.O.V. DISCS OUT OF HIS PD LIBRARY BECAUSE "
 DC.B "OF THE DISPUTE.   NOW I DON'T KNOW ABOUT YOU "
 DC.B "BUT I'VE HEARD MANY THINGS ABOUT MIKE GOODMAN AND IT SEEMS "
 DC.B "THAT MOST PEOPLE HAVE THE SAME OPINION THAT HE IS AN ARSEHOLE "
 DC.B "AND I FEEL THE SAME WAY.     THANK GOD HE ISN'T DISTRIBUTING "
 DC.B "OUR DISCS ANY MORE, WITH DICK HEADS LIKE THAT WHO NEEDS "
 DC.B "ENEMIES!!!!!         ONE WORD OF INFO...  IF A DEMO SAID "
 DC.B "THAT IT WAS LICENCEWARE OR SOME SIMILAR IDEA THEN WE WILL "
 DC.B "NOT PACK IT, IF A DEMO IS PD OR SHAREWARE THEN WE WILL - OK?    "
 DC.B "   WELL I'M NEAR THE END OF THIS SCROLLTEXT AS THE AMIGA "
 DC.B "IS DEMANDING ATTENTION - I'VE JUST GOT THE SILENTS 'GLOBAL TRASH DEMO' AND "
 DC.B "IT'S PRETTY GOOD.     I HOPE THE DEMO WRITERS GET CODING AND "
 DC.B "DO CONVERSIONS OF THE BETTER AMIGA DEMOS AS THE POOR ST LOOKS "
 DC.B "LIKE IT'S BEING LEFT BEHIND IN THE DEMOS AREA.       I WOULD "
 DC.B "CONVERT SOME MYSELF BUT IT TAKES AGES AND I'VE GOT LITTLE "
 DC.B "TIME DUE TO WORK AND DOING THESE P.O.V. DISCS.    "
 dc.b "OH WELL, IT'S HERE ----- THE WRAP.        "
 DC.B "                                    "
 dc.b "                                    "
 dc.b $ff
	even
colours	dc.w	$200,$300,$400,$500,$600,$700,$710,$720
	dc.w	$730,$740,$750,$760,$770,$670,$570
	dc.w	$470,$370,$270,$170,$071,$072,$073,$074
	dc.w	$075,$076,$077

font_pal	dc.w	$000,$070,$060,$050,$040,$040,$030,$020
		dc.w	$770,$770,$670,$560,$450,$340,$130,$777

font:	dcb.b	32*4*4,0
	incbin	"4plane.fnt"
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,45,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,25,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,47,00,48,49,50

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

	even

tune:	incbin	killing.img
	even
pic	incbin	pov71.PI1
	even
spec_lookup
	dc.w	$fd1,0
	dc.w	$bda,1
	dc.w	$bd9,2
	dc.w	$bd8,3
	dc.w	$a90,4
	dc.w	$a8f,5
	dc.w	$a8e,6
	dc.w	$a8d,7
	dc.w	$a8c,8
	dc.w	$968,9
	dc.w	$967,10
	dc.w	$966,11
	dc.w	$8e3,12
	dc.w	$8e2,13
	dc.w	$8e1,14
	dc.w	$8e0,15
	dc.w	$8df,16
	dc.w	$7ec,17
	dc.w	$7eb,18
	dc.w	$7ea,19
	dc.w	$7e9,20
	dc.w	$7e8,21
	dc.w	$7e7,22
	dc.w	$7e6,23
	dc.w	$711,24
	dc.w	$710,25
	dc.w	$70f,26
	dc.w	$70e,27
	dc.w	$70d,28
	dc.w	$70c,29
	dc.w	$70b,30
	dc.w	$70a,31
	dc.w	$709,32
	dc.w	$6aa,33
	dc.w	$6a9,34
	dc.w	$6a8,35
	dc.w	$6a7,36
	dc.w	$6a6,37
	dc.w	$6a5,38
	dc.w	$6a4,39
	dc.w	$6a3,40
	dc.w	$647,41
	dc.w	$5ee,42
	dc.w	$5ed,43
	dc.w	$5ec,44
	dc.w	$5eb,45
	dc.w	$5ea,46
	dc.w	$598,47
	dc.w	$54a,48
	dc.w	$549,49
	dc.w	$548,50
	dc.w	$547,51
	dc.w	$546,52
	dc.w	$545,53
	dc.w	$4fc,54
	dc.w	$4fb,55
	dc.w	$4fa,56
	dc.w	$472,57
	dc.w	$471,58
	dc.w	$470,59
	dc.w	$46f,60
	dc.w	$46e,61
	dc.w	$3f6,62
	dc.w	$3f5,63
	dc.w	$3f4,64
	dc.w	$3f3,65
	dc.w	$3f2,66
	dc.w	$386,67
	dc.w	$385,68
	dc.w	$384,69
	dc.w	$2f7,70
	dc.w	$2f6,71
	dc.w	$2cd,72
	dc.w	$2cc,73
	dc.w	$2cb,74
	dc.w	$2ca,75
	dc.w	$27f,76
	dc.w	$27e,77
	dc.w	$27d,78
	dc.w	$27c,79

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
pov	incbin	pov.dat
	even

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
	dc.b	"DOCKLAND",0,0,0,0,0,0,0,0
	dc.b	"REV",0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"NEXTGEN",0,0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

spec_values	dcb.b	80,0

	SECTION BSS
old_pal:	ds.b	32
logo	ds.b	24567
	ds.b	256
screen:	ds.b	48000

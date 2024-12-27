*************************************************************************
*				P.O.V. 79				*
*				---------				*
* Music using upper and lower border and a 2 table spectrum analyser	*
*									*
* Written by MAC SYS DATA of P.O.V.					*
*************************************************************************

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
;*                            MAD MAX                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 21/3/91 19:14                      *
;*      From: SEWER SOFTWARE DOC 27                                     *
;* Include files:-                                                      *
;*                 DOC27.MUS into TUNE                                  *
;************************************************************************

;****************************************************************
; There is more than one tune in this code....
; 0=
; 1=Sewer doc disc 27
; 2=tune 2
; 3=tune 3
; 4=tune 4
; 5=tune 5 - well known tune

	moveq	#1,D0
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

;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	beq	zero
	cmp.b	#$70,d0
	beq	zero

no_switch
	cmp.b	#$53,d0
	beq.s	do_reset

	cmp.b	#$32,d0		;'M' key for music change
	beq.s	music_change

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

music_change
	tst.w	music_counter
	beq.s	.flip_music
	bra	main_loop
.flip_music
	moveq	#0,d0
	jsr	tune
	eor.w	#4,spec_toggle		;we only use tunes 1 and 5
	moveq	#0,d0
	move.w	spec_toggle,d0
	move.l	d0,-(sp)
	jsr	tune
	move.l	(sp)+,d0
	subq.w	#1,d0
	lea	tables,a0
	add.w	d0,a0
	move.l	(a0),spec_table
	move.w	#20,music_counter
	bra	main_loop

zero	tst.w	zero_counter
	bne	no_switch
	eor.w	#$ffff,hertz_switch
	eor.w	#$010,font_pal
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
	move.l	spec_table,a3

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
	move.l	spec_table,a3
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

	move.l	spec_table,a3
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
	movem.l	d0-a6,-(sp)
	jsr	tune+8
	movem.l	(sp)+,d0-a6
	tst.w	music_counter
	beq.s	.next
	subq.w	#1,music_counter
.next	tst.w	zero_counter
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
music_counter	dc.w	0
hertz_switch	dc.w	0
stack_save	dc.l	0
vsync_flag	dc.w	0
spec_pos	dc.l	0
	even
old_base	dc.l	0
counter		dc.w	0
char_offset	dc.w	0

scroll_pointer	dc.l	init_scroll_text+7
init_scroll_text
 dc.b "                        a a a "
scroll_text
 dc.b "THE VISION LIVES ON a a a    PERSISTENCE OF VISION "
 dc.b "PACKED DEMO DISC 79.       "
 dc.b "CODING AND MUSIC RIPPING BY MAC SYS DATA WITH GRAFIX BY OZ. "
 DC.B "    THE MUSIC CAME FROM SEWER DOC DISC 27 AND I DON'T KNOW "
 DC.B "WHAT GAME IT IS FROM, CAN ANYONE TELL ME?       YOU CAN CHANGE THE TUNE "
 DC.B "BY PRESSING THE 'M' KEY AND CHANGE THE HERTZ BY PRESSING "
 DC.B "THE '0' KEY ON BOTH THE KEYBOARD AND THE KEYPAD.      "
 DC.B "            "
 DC.B "OK IT'S GREETINGS TIME AGAIN.... HI TO   "
 DC.B "AUTOMATION,   MEDWAY BOYS,   POMPEY PIRATES,   "
 DC.B "GEORGE,   SKUNK,   DR.SYNE,   ERIK PLANKTON,   "
 DC.B "INNER CIRCLE,   THE UNION,   THE REPLICANTS,   "
 DC.B "THE LOST BOYS,   THE DEMO CLUB,   DAL SNUFFS,   "
 DC.B "SEWER SOFTWARE,   RIPPED OFF (BILBO AND STICK),   "
 DC.B "MARTIAN,   DEREK AT D.W STABLES PD IN BLACKPOOL (SORRY I CALLED "
 DC.B "YOU DAVE!)   AND   THE WATCHMEN.        "
 DC.B "       YOU CAN CONTACT MEMBERS OF P.O.V. AT THE FOLLOWING ADDRESS..."
 DC.B "   a,   P.O. BOX 40,        THORNTON CLEVELEYS,        BLACKPOOL,        "
 DC.B "LANCS.,        ENGLAND,        FY5 3PH.            I'M SORRY "
 DC.B "BUT WE WILL NOT SUPPLY DISCS TO THE GENERAL PUBLIC FROM THIS "
 DC.B "ADDRESS BUT WILL SUPPLY ANY PD LIBRARY.     IF YOU WISH "
 DC.B "TO CONTACT A CERTAIN MEMBER TO SWAP CODE/IDEAS/DEMOS THEN "
 DC.B "PUT THE PERSONS NAME BEFORE THE ADDRESS.     MEMBERS OF "
 DC.B "P.O.V. ARE...       MAC SYS DATA (ME) - CODER/HACKER/PACKER,        "
 DC.B "BORIS - CODER/PACKER        AND        OZYMANDIAS - GRAFIX ARTIST.  "
 DC.B "      WE ARE NOT INTO SWAPPING PIRATED SOFTWARE SO DO NOT SEND ANY "
 DC.B "TO THIS ADDRESS.      IF YOU HAVE WRITTEN A DEMO THAT IS "
 DC.B "FAIRLY GOOD AND WOULD LIKE IT TO APPEAR ON A P.O.V. DISC SIMPLY SEND IT "
 DC.B "TO THE P.O. BOX WITH YOUR NAME AND ADDRESS.    IF I PACK IT, "
 DC.B "I WILL SEND THE COMPLETED P.O.V. DISC "
 DC.B "BACK TO YOU....... IF YOU COULD PUT A STAMP IN WITH YOUR DEMO "
 DC.B "YOUR DISC WILL BE RETURNED A.S.A.P OTHERWISE IT MAY BE DELAYED AS I HAVE VERY LITTLE "
 DC.B "ACCESS TO A POST OFFICE DUE TO THE TIMES I WORK.  I YOU DO NOT "
 DC.B "RECEIVE YOUR DISC FOR 6-7 WEEKS THEN DON'T WORRY AS I ALWAYS "
 DC.B "HAVE A STOCK OF PACKED DEMOS READY TO GO OUT.   THE "
 DC.B "QUALITY OF THE DEMO WILL DEFINE THE SPEED WITH WHICH IT WILL "
 DC.B "APPEAR ON A P.O.V. MENU, IF YOU DO A 760K SAMPLED DEMO WITH "
 DC.B "NAFF GRAFIX THEN I'LL NEVER PACK IT BUT IF IT IS A 200K "
 DC.B "DEMO WITH SUPER GRAFIX AND SPRITES THEN I'LL PACK IT WITHIN "
 DC.B "A FEW DAYS AND IT SHOULD APPEAR ON A DISC WITHIN 2 WEEKS. "
 DC.B "  I DO NOT WANT DEMOS THAT CONTAIN RIPPED GRAFIX MATCHED "
 DC.B "TO A NAFF SAMPLE USING MASTERSOUND.   IF ALL YOU CAN DO IS "
 DC.B "RIP GRAFIX AND DODGE A SAMPLE TOGETHER THEN FORGET IT AS "
 DC.B "YOU MUST BE A TOTAL PLANK   (NOTE: A PLANK IS A THICK BLOCK "
 DC.B "WITH ABSOLUTELY NO INTELLEGENCE - ASK SIMON MAYO). "
 dc.b "OK, TIME TO FINISH THIS OFF SO LET'S WRAP.        "
 DC.B "                                    "
 dc.b "                                    "
 dc.b $ff
	even
colours	dc.w	$200,$300,$400,$500,$600,$700,$710,$720
	dc.w	$730,$740,$750,$760,$770,$670,$570
	dc.w	$470,$370,$270,$170,$071,$072,$073,$074
	dc.w	$075,$076,$077

font_pal	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
		dc.w	$027,$037,$047,$057,$067,$077,$056,$777

font	dcb.b	32*4*4,0
	incbin	"4plane.fnt"
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,45,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,25,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,47,00,49,00,00

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

	even

tune	incbin	doc27.mus
	even
pic	incbin	pov79.PI1
	even
spec_toggle	dc.w	1
tables		dc.l	spec_lookup1
		dc.l	spec_lookup2
spec_table	dc.l	spec_lookup1
spec_lookup1
	dc.w	$c8e,0
	dc.w	$a17,1
	dc.w	$a07,2
	dc.w	$9f7,3
	dc.w	$9e7,4
	dc.w	$9d7,5
	dc.w	$967,6
	dc.w	$8e0,7
	dc.w	$861,8
	dc.w	$7e8,9
	dc.w	$787,10
	dc.w	$77f,11
	dc.w	$777,12
	dc.w	$76f,13
	dc.w	$767,14
	dc.w	$70b,15
	dc.w	$6a6,16
	dc.w	$647,17
	dc.w	$5ec,18
	dc.w	$5a7,19
	dc.w	$59f,20
	dc.w	$597,21
	dc.w	$58f,22
	dc.w	$587,23
	dc.w	$547,24
	dc.w	$4fb,25
	dc.w	$4b3,26
	dc.w	$470,27
	dc.w	$430,28
	dc.w	$3f4,29
	dc.w	$3bb,30
	dc.w	$385,31
	dc.w	$353,32
	dc.w	$323,33
	dc.w	$2f6,34
	dc.w	$2cb,35
	dc.w	$2a3,36
	dc.w	$27d,37
	dc.w	$259,38
	dc.w	$238,39
	dc.w	$218,40
	dc.w	$1fa,41
	dc.w	$1dd,42
	dc.w	$191,43
	dc.w	$169,44
	dc.w	$167,45
	dc.w	$165,46
	dc.w	$163,47
	dc.w	$161,48
	dc.w	$142,49
	dc.w	$140,50
	dc.w	$13e,51
	dc.w	$13c,52
	dc.w	$13a,53
	dc.w	$130,54
	dc.w	$12e,55
	dc.w	$12c,56
	dc.w	$12a,57
	dc.w	$128,58
	dc.w	$0ef,59
	dc.w	$0ee,60
	dc.w	$0ed,61
	dc.w	$0ec,62
	dc.w	$0c8,63
	dc.w	$0b2,64
	dc.w	$09f,65
	dc.w	$096,66
	dc.w	$077,67
	dc.w	$05e,68
	dc.w	$059,69
	dc.w	$03b,70
	dc.w	$098,71
	dc.w	$097,72
	dc.w	$096,73
	dc.w	$0ee,74
	dc.w	$0b2,75
	dc.w	$077,76
	dc.w	$05e,77
	dc.w	$059,78
	dc.w	$03b,79

spec_lookup2
	dc.w	$881,0
	dc.w	$871,1
	dc.w	$861,2
	dc.w	$851,3
	dc.w	$841,4
	dc.w	$787,5
	dc.w	$77f,6
	dc.w	$777,7
	dc.w	$76f,8
	dc.w	$767,9
	dc.w	$657,10
	dc.w	$64f,11
	dc.w	$647,12
	dc.w	$63f,13
	dc.w	$637,14
	dc.w	$5a7,15
	dc.w	$59f,16
	dc.w	$597,17
	dc.w	$58f,18
	dc.w	$587,19
	dc.w	$353,20
	dc.w	$1e1,21
	dc.w	$1df,22
	dc.w	$1dd,23
	dc.w	$1db,24
	dc.w	$1d9,25
	dc.w	$167,26
	dc.w	$14f,27
	dc.w	$13d,28
	dc.w	$11f,29
	dc.w	$110,30
	dc.w	$10f,31
	dc.w	$10e,32
	dc.w	$10d,33
	dc.w	$10c,34
	dc.w	$10a,35
	dc.w	$108,36
	dc.w	$0f2,37
	dc.w	$0f0,38
	dc.w	$0ef,39
	dc.w	$0ee,40
	dc.w	$0ed,41
	dc.w	$0ec,42
	dc.w	$0db,43
	dc.w	$0d3,44
	dc.w	$0c8,45
	dc.w	$0ab,46
	dc.w	$0a3,47
	dc.w	$09b,48
	dc.w	$093,49
	dc.w	$08b,50
	dc.w	$086,51
	dc.w	$077,52
	dc.w	$073,53
	dc.w	$06b,54
	dc.w	$065,55
	dc.w	$064,56
	dc.w	$063,57
	dc.w	$061,58
	dc.w	$05d,59
	dc.w	$05b,60
	dc.w	$053,61
	dc.w	$043,62
	dc.w	$03b,63
	dc.w	$032,64
	dc.w	$02d,65
	dc.w	$02b,66
	dc.w	$02a,67
	dc.w	$029,68
	dc.w	$025,69
	dc.w	$021,70
	dc.w	$020,71
	dc.w	$01f,72
	dc.w	$01d,73
	dc.w	$017,74
	dc.w	$016,75
	dc.w	$014,76
	dc.w	$00d,77
	dc.w	$00c,78
	dc.w	$00b,79

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
	dc.b	"POISON",0,0,0,0,0,0,0,0,0,0
	dc.b	"BATDANCE",0,0,0,0,0,0,0,0
	dc.b	"DRFG",0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

spec_values	dcb.b	80,0

	SECTION BSS
old70		ds.l	1
old120		ds.l	1
old118		ds.l	1
key		ds.w	1
save1		ds.b	1
save2		ds.b	1
save3		ds.b	1
save4		ds.b	1
save5		ds.b	1
save6		ds.b	1
save7		ds.b	1
save8		ds.b	1
	even
old_pal:	ds.b	32
logo	ds.b	24567
	ds.b	256
screen:	ds.b	48000

*************************************************************************
*				POV 112 MENU				*
*				------------				*
*									*
* Written by;-								*
*		Machine System Data of Persistence Of Vision		*
*									*
* Include files;-							*
*			POV112.PI1					*
*			E_A_INT.MUS					*
*			SINE1.DAT					*
*			FONT.DAT					*
*			SPECTRUM.DAT					*
*			BOMB.DAT					*
*									*
*************************************************************************

	OPT	o+,w-

	lea	bss_start,a0
clear	clr.b	(a0)+
	cmp.l	#bss_stop,a0
	blt.s	clear

	bsr	set_super
	or.b	#2,$ffff820a.w	;50Hz
	bsr	save_pal
	move.b	#$12,$fffffc02.w
	bsr	get_base
	bsr	set_up
	move.l	screen_base,a0
	bsr	set_low_rez
	bsr	set_screen

	bsr	intro

;************************************************************************
;*		E_A_INT.ACF	- From 'E.A. Intelligent'		*
;*			     from JUST BUGGIN				*
;*		-----------------------------------------		*
;* Stolen by: MUG UK							*
;************************************************************************
	moveq	#1,d0
	jsr	tune

	bsr	set_for_lower
	bsr	show_pic
	bsr	flush

main_loop
	bsr	vsync
	bsr	set_screen
	bsr	change_colours
;	move.w	#$070,$ffff8240.w
	bsr	clear_spec
;	move.w	#$007,$ffff8240.w
	bsr	calc_spec
;	move.w	#$700,$ffff8240.w
	bsr	scroll
;	move.w	#$077,$ffff8240.w
 	bsr	sentence
;	move.w	pic+2,$ffff8240.w

	move.b	$fffffc02.w,d0

	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$53,d0
	beq	do_reset

	cmp.b	#$b,d0		;0 key
	beq	zero

	cmp.b	#$70,d0		;0 keypad
	beq	zero


not_zero
	lea	key_codes,a0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

load	move.b	(a0)+,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.b	(sp)+,d0

;key is in D0.B
	and.l	#$ff,d0
	lsl.w	#2,d0
	lea	filenames,a6
	move.l	(a6,d0.w),a6
	lea	$200.w,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6),(a0)

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	#8,$fffffc02.w

	bsr	flush
	bsr	user_mode
	clr.w	-(sp)
	trap	#1

exit	bsr	isr_off
	bsr	flush
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	restore_pal
	move.b	#8,$fffffc02.w
	bsr	user_mode
	clr.w	-(sp)
	trap	#1


do_reset
	move.l	4.w,-(sp)
	rts

zero	tst.w	zero_counter
	bne	not_zero
	eor.w	#$001,pic+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra	main_loop

********************
* Special routines *
********************

change_colours
	sub.w	#1,new_pal?
	tst.w	new_pal?
	beq.s	.yes
	rts
.yes	move.l	main_pal_pos,a0
	cmp.w	#-1,(a0)
	bne.s	.no_reset
	lea	main_pals,a0
.no_reset
	move.w	(a0)+,new_pal?
	movem.l	(a0)+,d0-d4
	movem.l	d0-d4,pic+2+12
	move.l	a0,main_pal_pos
	rts
	
************
* sentence *
************
sentence
	bsr	clear_sentence
	move.l	screen_base,a1
	lea	(120*160)(a1),a1
	move.l	pos,a2
	cmp.b	#$ff,(a2)
	bne.s	do_build
	move.w	#-1,reset_detect
	addq.l	#1,pos
do_build
	tst.w	reset_detect
	beq.s	no_sentence_reset

	move.l	#table,pos
	clr.w	reset_detect
no_sentence_reset
	move.l	screen_base,a0
	lea	32320(a0),a0		;point to scroller in border
	move.w	#20-1,d7
bit_loop
	move.l	a1,a3
	moveq.l	#0,d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	.no_reset_token
	move.b	(a2)+,d1
	move.b	(a2)+,d1
.no_reset_token
	lsl.l	#5,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1	;D1 * 160
	add.w	d1,a1
	moveq.b	#-16,d3

OFF1	set	0
OFF2	set	160
OFF3	set	320
OFF4	set	480
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)

	move.l	a3,a1
	moveq	#0,d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	.no_reset_token3
	move.b	(a2)+,d1
	move.b	(a2)+,d1
.no_reset_token3
	lsl.l	#5,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.w	d2,d1	;D1 * 160
	add.w	d1,a1
	moveq.b	#%1111,d3

OFF1	set	0
OFF2	set	160
OFF3	set	320
OFF4	set	480
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)


OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)

	move.l	a3,a1
	moveq	#0,d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	.no_reset_token2
	move.b	(a2)+,d1
	move.b	(a2)+,d1
.no_reset_token2
	lsl.l	#5,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1	;D1 * 160
	add.w	d1,a1
	moveq.b	#-16,d3


OFF1	set	1
OFF2	set	161
OFF3	set	321
OFF4	set	481

	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640

	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)


OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)
	move.b	d6,OFF4(a1)


OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	move.b	d2,OFF1(a1)
	move.b	d4,OFF2(a1)
	move.b	d5,OFF3(a1)

	move.l	a3,a1
	moveq	#0,d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	.no_reset_token4
	move.b	(a2)+,d1
	move.b	(a2)+,d1
.no_reset_token4
	lsl.l	#5,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1	;D1 * 160
	add.w	d1,a1
	moveq.b	#%1111,d3

OFF1	set	1
OFF2	set	161
OFF3	set	321
OFF4	set	481
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)


OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
OFF4	set	OFF4+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	move.b	OFF4(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)
	or.b	d6,OFF4(a1)

OFF1	set	OFF1+640
OFF2	set	OFF2+640
OFF3	set	OFF3+640
	move.b	OFF1(a0),d2
	move.b	OFF2(a0),d4
	move.b	OFF3(a0),d5
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	or.b	d2,OFF1(a1)
	or.b	d4,OFF2(a1)
	or.b	d5,OFF3(a1)

	move.l	a3,a1
	addq.w	#8,a1
	addq.w	#8,a0
	dbf	d7,bit_loop
	addq.l	#1,pos
	rts

clear_sentence
	move.l	screen_base,a0
	lea	(160*120)(a0),a0
	moveq	#0,d1
	REPT	71
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

********************
* Service routines *
********************
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
	add.w	#(160*39),a1
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
	add.w	#(51*160),a0

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

vsync	move.w	#-1,vsync_flag
.no	tst.w	vsync_flag
	bne.s	.no
	rts



scroll	move.l	screen_base,a1
	add.l	#160*201,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	move.w	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#23*4,d0		;30
	add.w	d0,a0
	move.w	d6,d0
	mulu	#23,d0		;character depth * 4 bytes (word wide)
	add.w	d0,a0

.column
OFF	set	0
	REPT	23
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if byte_toggle=0 then do next word
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




********
* ISRs *
********
new_70	move.l	pic+2,$ffff8240.w
	move.l	pic+6,$ffff8244.w
	move.l	pic+10,$ffff8248.w
	move.l	pic+14,$ffff824c.w
	move.l	pic+18,$ffff8250.w
	move.l	pic+22,$ffff8254.w
	move.l	pic+26,$ffff8258.w
	move.l	pic+30,$ffff825c.w

	clr.b	counter		;set up border count down

	move.l	#new_120,$120.W

	clr.w	vsync_flag

	move.l	#colours,pal_pos

	movem.l	d0-d7/a0-a6,-(sp)
	jsr	tune+4
	movem.l	(sp)+,d0-d7/a0-a6

	bsr	vu


	tst.w	zero_counter
	beq.s	.no
	subq.w	#1,zero_counter
.no

	clr.b	$fffffa1b.w
	move.b	#36,$fffffa21.w		;start rasters on line 36
	move.b	#8,$fffffa1b.w
	rte


new_120	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w		;do it every 2 lines
	move.l	#new_120_part2,$120.w
	move.b	#8,$fffffa1b.w
	rte

new_120_part2
	move.l	a0,-(sp)
	move.l	pal_pos,a0
	move.w	(a0),$ffff8242.w
	move.w	(a0)+,$ffff8242+8.w
	move.l	a0,pal_pos
	move.l	(sp)+,a0
	add.b	#1,counter
	cmp.b	#15,counter
	beq.s	.set
	rte

.set	clr.b	$fffffa1b.w
	move.b	#52,$fffffa21.w
	move.l	#new_120_part3,$120.w
	move.b	#8,$fffffa1b.w
	clr.b	counter
	rte

new_120_part3
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.l	#new_120_part4,$120.w
	move.b	#8,$fffffa1b.w
	clr.b	counter
	rte

new_120_part4
	move.l	a0,-(sp)
	move.l	pal_pos,a0
	move.w	(a0)+,$ffff8242.w
	move.l	a0,pal_pos
	move.l	(sp)+,a0
	add.b	#1,counter
	cmp.b	#36,counter
	beq.s	.set
	rte
.set	move.l	#new_120_part5,$120.w
	clr.b	$fffffa1b.w
	move.b	#9,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte


new_120_part5
	clr.b	$fffffa1b.w		;DI all other interrupts
	move.w	#$010,$ffff8244.w	;top VU colour
	movem.l	d0/a0,-(sp)		;store these now to stop flicker

	REPT 60				;wait for 1/2 a screen width
	nop
	ENDR

.loop	tst.b	$ffff8209.w		;check low video pos
	bne.s	.loop
	nop				;do fuck all for a while
	nop
	nop
	nop
	nop
	nop
	clr.b	$ffff820a.w		;60Hz

	REPT 16
	nop
	ENDR
	MOVE.B	#2,$FFFF820A.W

	lea	pal_table,a0
	move.w	#24-1,d0	;colour the bottom scroller
col_loop
	move.w	(a0),$ffff8242.w
	move.w	(a0)+,$ffff8240+$a.w
	move.w	(vu_colours-pal_table)(a0),$ffff8240+8.w
	REPT 116
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	rte


isr_off	ORI.W	#$700,SR
	move.l	old120,$120.w
	move.l	old70,$70.w
	MOVE.B	olda07,$FFFFFA07.w
	MOVE.B	olda09,$FFFFFA09.w
	MOVE.B	olda13,$FFFFFA13.w
	MOVE.B	olda17,$FFFFFA17.w
	move.b	olda1b,$fffffa1b.w
	move.b	olda21,$fffffa21.w
	MOVE.W	#$2300,SR

endmusic
	moveq	#0,d0		; off music
	jsr	tune
	move.w	#2,d0
	moveq	#8,d1
stop1	move.b	d1,$ffff8800.w
	clr.b	$ff8802
	addq.l	#1,d1
	dbf	d0,stop1
	rts


flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts



vu	movem.l	d5-d7/a3-a6,-(sp)
	move.b	#$8,$ffff8800.w	;chan A
	move.b	$ffff8800.w,d7
	move.l	screen_base,a6
	add.l	#32000+1280+8+4,a6	;screen always in A6
	bsr.s	METER
	move.b	#$9,$ffff8800.w	;chan B
	move.b	$ffff8800.w,d7
	add.w	#160*5,a6
	bsr.s	METER
	move.b	#$a,$ffff8800.w	;chan C
	move.b	$ffff8800.w,d7
	add.w	#160*5,a6
	bsr.s	METER
;flash the disc drive light
	move.b	#$8,$ffff8800.w
	move.b	$ffff8800.w,d7
	cmp.b	#13,d7
	blt.s	no_flash
	move.b	#14,$ffff8800.w
	bclr	#1,$ffff8802.w
	bra.s	asdf
no_flash
	move.b	#14,$ffff8800.w
	or.b	#%00000010,$ffff8802.w
asdf	movem.l	(sp)+,d5-d7/a3-a6
	rts

METER	tst.b	d7
	blt	exit_vu		;less than no volume!
	and.w	#$ff,d7
	cmp.w	#15,d7
	bgt	exit_vu
	move.l	a6,a4
	add.w	#80,a4

	mulu	#16,d7

	lea	vu_block,a3
	add.w	d7,a3
	lea	vu2,a5
	add.w	d7,a5
	move.w	(a5),(a6)
	move.w	(a5),160(a6)
	move.w	(a5)+,320(a6)

	move.w	(a3),(a4)
	move.w	(a3),160(a4)
	move.w	(a3)+,320(a4)

	move.w	(a5),8(a6)
	move.w	(a5),168(a6)
	move.w	(a5)+,328(a6)
	move.w	(a3),8(a4)
	move.w	(a3),168(a4)
	move.w	(a3)+,328(a4)
	move.w	(a5),16(a6)
	move.w	(a5),160+16(a6)
	move.w	(a5)+,320+16(a6)
	move.w	(a3),16(a4)
	move.w	(a3),160+16(a4)
	move.w	(a3)+,320+16(a4)
	move.w	(a5),24(a6)
	move.w	(a5),160+24(a6)
	move.w	(a5)+,320+24(a6)
	move.w	(a3),24(a4)
	move.w	(a3),160+24(a4)
	move.w	(a3)+,320+24(a4)
	move.w	(a5),32(a6)
	move.w	(a5),160+32(a6)
	move.w	(a5)+,320+32(a6)
	move.w	(a3),32(a4)
	move.w	(a3),160+32(a4)
	move.w	(a3)+,320+32(a4)
	move.w	(a5),40(a6)
	move.w	(a5),160+40(a6)
	move.w	(a5)+,320+40(a6)
	move.w	(a3),40(a4)
	move.w	(a3),160+40(a4)
	move.w	(a3)+,320+40(a4)
	move.w	(a5),48(a6)
	move.w	(a5),160+48(a6)
	move.w	(a5)+,320+48(a6)
	move.w	(a3),48(a4)
	move.w	(a3),160+48(a4)
	move.w	(a3)+,320+48(a4)
	move.w	(a5),56(a6)
	move.w	(a5),160+56(a6)
	move.w	(a5),320+56(a6)
	move.w	(a3),56(a4)
	move.w	(a3),160+56(a4)
	move.w	(a3),320+56(a4)
exit_vu	rts

set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,screen_base
	move.l	d0,d1
	add.l	#41984,d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

set_screen
	lea	screen_base,a6
	move.l	(a6),d6
	move.l	d6,4(a6)
	move.l	scr_xor,d0
	eor.l	d0,d6
	move.l	d6,screen_base
	lsr.l	#8,d6
	lea	$ffff8201.w,a5
	movep.w	d6,(a5)
	rts


set_super
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

show_pic
	lea	pic+34,a0
	move.l	screen_base,a1
	move.l	screen_base+4,a2
	move.w	#32000/4-1,d0
.loop	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop
	rts

user_mode
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal
	lea	old_pal,a1
	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

restore_pal
	lea	old_pal,a0
	bra.s	set_p

set_palette
	lea	pic+2,a0
set_p	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
	rts

set_med_rez
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez
	clr.w	-(sp)
set_rez	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

set_for_lower
	clr.w	zero_counter
	ori.w	#$700,sr
	move.l	$70.w,old70
	move.l	$120.w,old120
	move.b	$fffffa07.w,olda07
	move.b	$fffffa09.w,olda09
 	move.b	$fffffa13.w,olda13
 	move.b	$fffffa17.w,olda17
	move.b	$fffffa1b.w,olda1b
	move.b	$fffffa21.w,olda21

	MOVE.L	#new_70,$70.W
	MOVE.L	#new_120,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts


intro	movem.l	bomb_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	screen_base,a0
	add.w	#(160*87)+64,a0
	lea	bombs,a1
OFF	set	0
	REPT	31
	move.l	(a1)+,OFF(a0)
	move.l	(a1)+,OFF+4(a0)
	move.l	(a1)+,OFF+8(a0)
	move.l	(a1)+,OFF+12(a0)
	move.l	(a1)+,OFF+16(a0)
	move.l	(a1)+,OFF+20(a0)
OFF	set OFF+160
	ENDR

.intro
	bsr	v_sync
	bsr	v_sync
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	beq.s	.no
.key?	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	beq.s	.stop
	bra.s	.key?

.no	tst.w	bomb_delay
	beq.s	.do
	sub.w	#1,bomb_delay
	bra.s	.intro

.do	move.w	bomb_number,d0
	cmp.w	#16,d0
	bne	.so

	move.w	#30-1,d0
.loop	eor.w	#$f00,$ffff8240.w
	bsr	v_sync
	dbf	d0,.loop

.stop	move.l	screen_base,a0
	add.w	#(160*87)+64,a0
	moveq	#0,d0
OFF	set	0
	REPT	31
	move.l	d0,OFF(a0)
	move.l	d0,OFF+4(a0)
	move.l	d0,OFF+8(a0)
	move.l	d0,OFF+12(a0)
	move.l	d0,OFF+16(a0)
	move.l	d0,OFF+20(a0)
OFF	set OFF+160
	ENDR
	bsr	flush
	rts

.so	move.w	#2,bomb_delay
	add.w	#1,bomb_number
	mulu	#24*31,d0
	move.l	screen_base,a0
	add.w	#(160*87)+64,a0
	lea	bombs,a1
	add.w	d0,a1

OFF	set	0
	REPT	31
	move.l	(a1)+,OFF(a0)
	move.l	(a1)+,OFF+4(a0)
	move.l	(a1)+,OFF+8(a0)
	move.l	(a1)+,OFF+12(a0)
	move.l	(a1)+,OFF+16(a0)
	move.l	(a1)+,OFF+20(a0)
OFF	set OFF+160
	ENDR
	bra	.intro


v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

bombs	incbin	bombs.dat
bomb_delay	dc.w	60

bomb_number	ds.w	1
bomb_pal	dc.w	$000,$710,$700,$600,$500,$400,$300,$200
		dc.w	$100,$111,$222,$333,$444,$555,$666,$777

*****************************
	SECTION DATA
*****************************
vu_block
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fe00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fe00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fe00,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$0000,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fe00,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$0000,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fe00,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$0000,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fe00,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$0000,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fe00,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$0000
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fe00

vu2	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$007f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$007f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$007f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$0000,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$007f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$0000,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
	dc.w	$007f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f


scroll_number	dc.w	16
pal_table
	dc.w	0
	dc.w	$088,$011,$099,$022,$0aa,$033,$0bb,$044,$0cc
	dc.w	$055,$0dd,$066,$0ee,$077,$0ff,$077,$0ee,$066
	dc.w	$0dd,$055,$0cc,$044,$0bb


vsync_flag	dc.w	0
old_base	dc.l	0
old_pal	ds.b	32

******************************
* letters variables and data *
******************************
reset_detect	dc.w	0
pos	dc.l	init_table
init_table
	dcb.b	60,0
table	incbin	sine1.dat
	dc.b $ff
	incbin	sine1.dat

	even
pal_pos	dc.l	colours
colours

 dc.w	$012,$023,$034,$045,$056,$067,$07f,$07f
 dc.w	$067,$056,$045,$034,$023,$012

 dc.w	$100,$200,$300,$400,$500,$600,$700,$710
 dc.w	$720,$730,$740,$750,$760,$ff0,$ff0,$671,$572
 dc.w	$473,$374,$275,$176,$077,$167,$257,$347
 dc.w	$437,$527,$617,$70f,$f06,$605,$504,$403
 dc.w	$302,$201,$100,$000


vu_colours		;change these for different VU colours...
	dcb.w	12,$00f
	dcb.w	 5,$005
	dcb.w	 5,$003


new_pal?	dc.w	500
main_pal_pos	dc.l	main_pals
main_pals	
	dc.w	500,$300,$500,$610,$720,$730,$740,$751,$762,$773,$777
	dc.w	004,$200,$400,$500,$610,$620,$630,$640,$651,$662,$666
	dc.w	004,$100,$300,$400,$500,$510,$520,$530,$540,$551,$555
	dc.w	004,$000,$200,$300,$400,$400,$410,$420,$430,$440,$444
	dc.w	004,$000,$100,$200,$300,$300,$300,$310,$320,$330,$333
	dc.w	004,$000,$000,$100,$200,$200,$200,$200,$210,$220,$222
	dc.w	004,$000,$000,$000,$100,$100,$100,$100,$100,$110,$111
	dc.w	004,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

	dc.w	004,$000,$000,$000,$001,$001,$001,$001,$001,$111,$011
	dc.w	004,$000,$000,$001,$002,$002,$002,$002,$012,$022,$022
	dc.w	004,$000,$001,$002,$003,$003,$003,$013,$023,$033,$033
	dc.w	004,$000,$002,$003,$004,$004,$014,$024,$034,$044,$144
	dc.w	004,$001,$003,$004,$005,$015,$025,$035,$045,$055,$255
	dc.w	004,$002,$004,$005,$016,$026,$036,$046,$056,$066,$366
	dc.w	400,$003,$005,$016,$027,$037,$047,$057,$067,$077,$477
	dc.w	004,$002,$004,$005,$016,$026,$036,$046,$056,$066,$366
	dc.w	004,$001,$003,$004,$005,$015,$025,$035,$045,$055,$255
	dc.w	004,$000,$002,$003,$004,$004,$014,$024,$034,$044,$144
	dc.w	004,$000,$001,$002,$003,$003,$003,$013,$023,$033,$033
	dc.w	004,$000,$000,$001,$002,$002,$002,$002,$012,$022,$022
	dc.w	004,$000,$000,$000,$001,$001,$001,$001,$001,$111,$011
	dc.w	004,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

	dc.w	004,$000,$000,$000,$000,$000,$000,$010,$010,$010,$010
	dc.w	004,$000,$000,$000,$000,$000,$010,$020,$020,$020,$020
	dc.w	004,$000,$000,$000,$000,$010,$020,$030,$030,$030,$030
	dc.w	004,$000,$000,$000,$010,$020,$030,$040,$040,$040,$040
	dc.w	004,$000,$000,$010,$020,$030,$040,$050,$050,$050,$051
	dc.w	004,$000,$010,$020,$030,$040,$050,$060,$060,$061,$062
	dc.w	400,$010,$020,$030,$040,$050,$060,$070,$071,$072,$073
	dc.w	004,$000,$010,$020,$030,$040,$050,$060,$060,$061,$062
	dc.w	004,$000,$000,$010,$020,$030,$040,$050,$050,$050,$051
	dc.w	004,$000,$000,$000,$010,$020,$030,$040,$040,$040,$040
	dc.w	004,$000,$000,$000,$000,$010,$020,$030,$030,$030,$030
	dc.w	004,$000,$000,$000,$000,$000,$010,$020,$020,$020,$020
	dc.w	004,$000,$000,$000,$000,$000,$000,$010,$010,$010,$010
	dc.w	004,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

	dc.w	004,$000,$000,$000,$100,$100,$100,$100,$100,$110,$111
	dc.w	004,$000,$000,$100,$200,$200,$200,$200,$210,$220,$222
	dc.w	004,$000,$100,$200,$300,$300,$300,$310,$320,$330,$333
	dc.w	004,$000,$200,$300,$400,$400,$410,$420,$430,$440,$444
	dc.w	004,$100,$300,$400,$500,$510,$520,$530,$540,$550,$555

	dc.w	-1

*******************************
* scroller variables and data *
*******************************

********** scroll text is now mapped across both higher and lower case
**********
**********
scroll_pointer	dc.l	init_scroll_text
init_scroll_text
	dc.b	"                     "
scroll_text
 dc.b "MAC SYS DATA OF P.O.V. PRESENTS DISC 112.        "
 DC.B "RELEASED DATE: 6/4/92          "
 dc.b "         CREDITS FOR THIS MENU GOTO......"
 dc.b "      CODING BY MAC SYS DATA,      MUSIC FROM JUST BUGGIN DEMO "
 dc.b "(E.A INTELLEGENT SCREEN) and was ripped by MUG uk.     "
 dc.b "             do you recognize this menu?           i sent "
 dc.b "it to several crews so you may have seen it before. "
 dc.b "   i have made a couple of slight alterations to the code "
 dc.b "like fade in and out of the main colours but i couldn't change it "
 dc.b "too much because there is virtually no CPU time left.     "
 dc.b "   what do you think of the music?       mug uk hacked it out "
 dc.b "and sent it with about 11 others so expect more of the same genere.           "
 dc.b "i recently bought some more speakers for my stereo so I can listed "
 dc.b "to music in quad stereo.     I've got yoshen hippel 'give it a try' "
 dc.b "blasting out - yeah!      if you haven't heard it then you "
 dc.b "haven't heard his best.      i'm pretty sure he develops the "
 dc.b "music on an Amiga but on the CD he added real guitars and "
 dc.b "other instruments. the disc is properly mixed and sounds "
 dc.b "out of this world.      if you want a copy then write to me "
 dc.b "at the usual address for information on where to get it.    if "
 dc.b "you don't know the usual address then go get a pen and paper "
 dc.b "'cause I'll tell you later on.......................... "
 dc.b " if any people out there are into bulletin boards (BBS) and "
 dc.b "like programming in assembly then phone up foundation "
 dc.b "bbs as i've uploaded some source code.       "
 dc.b "if there is someone out there who uses their modem a lot "
 dc.b "and would like to spread p.o.v. source code please get in "
 dc.b "touch as I'll send the source all LZH'ed and ready for "
 dc.b "uploading.         have you got a pen yet?          "
 dc.b "you have?         then put it to one side 'cause here are "
 dc.b "the greetings..........        mega greets to   "
 dc.b "  BART,    DEL,    MARTIAN,    BILBO,    BOMB SQUAD,    low life,    MUG UK,    "
 dc.b "SPEED,    DELTA FORCE,    ADRENALIN,    DR. SYNE,    "
 dc.b "INNER CIRCLE,    ERIK PLANKTON AND BLIND BASTARD,    "
 dc.b "UTOS,    THE ENTERPRISE,    ELECTRONIC,    "
 dc.b "KGB,    THE FORCE,    PIXEL TWINS,    NOD,    "
 dc.b "ZOGG AND THE WATCHMEN,    SEWER SOFTWARE,    EMPIRE,    "
 dc.b "FACTORY,    REPLICANTS,    ETERNAL DEVELOPMENT,    "
 dc.b "PURE ENERGY,    OXYGENE CREW,     GENESIS INC.,    "
 dc.b "MAD VISION,    CYNIX,    HOTLINE/MCA,    "
 dc.b "DELIGHT,    ALTAIR    AND    MR.X.          "
 dc.b "           oh well that's all I've time for so bye..."
 dc.b "                         "
 dc.b "                                "
 DC.B	$ff
	even

char_offset	dc.w	0
font	dcb.b	23*4,0
	incbin	font.dat
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,44,43,00,45,00,42,51,46,47,00,00,49,00,48,29

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	41,31,32,33,34,35,36,37,38,39,59,58,00,00,00,43,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,11,12,13,14,15,16,17,18

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	19,21,22,23,24,25,26,27,28,40,00,41,00,52,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,11,12,13,14,15,16,17,18,19,21,22,23

;        v  w  x  y  z  {  |  }  ~  
 dc.b	24,25,26,27,28,46,44,47,00,14

	even

tune	incbin	e_a_int.mus
pic	incbin	pov112.PI1

spec_data	incbin	SPECTRUM.DAT

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

filenames
	dc.l	exec1,exec2,exec3,exec4,exec5,exec6

exec1	dc.b	"union",0
	even
exec2	dc.b	"synth",0
	even
exec3	dc.b	"en_demo2",0
	even
exec4	dc.b	"fire",0
	even
exec5	dc.b	"mca1",0
	even
exec6	dc.b	"copier.pov",0
	even



*****************************
	SECTION BSS
*****************************
bss_start
stack_save	ds.l	1

black_pal	ds.w	16

toggle		ds.w	1	;50 hertz
screen_base	ds.l	1
		ds.l	1
scr_xor		ds.l	1

spec_values	ds.w	MAX_BARS

old70		ds.l	1
old120		ds.l	1
zero_counter	ds.w	1
olda07		ds.b	1
olda09		ds.b	1
olda13		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
counter		ds.b	1
	even

	ds.b	256
screens	ds.b	41984
	ds.b	41984
bss_stop
*************************************************************************
*				GAME/DEMO MENU				*
*				--------------				*
*									*
* Written by;-								*
*		Machine System Data of Persistence Of Vision		*
*				alias					*
*			    Erik Plankton				*
*									*
* Assemble with GENST2.23 or higher					*
*									*
* Written using DEVPAC DEVELOPER V2.23					*
*									*
*************************************************************************

	OPT	o+,w-

	bsr	set_super
	or.b	#2,$ffff820a.w	;50Hz
	bsr	save_pal
	move.b	#$12,$fffffc02.w
	bsr	get_base
	bsr	set_up
	move.l	screen_base,a0
	bsr	set_low_rez
	bsr	set_screen

;************************************************************************
;*			PREHISTORIC TALE				*
;*			----------------				*
;* Stolen by: MUG UK							*
;************************************************************************
;* IN GAME TUNE 1
;*
	moveq	#1,d0
	bsr	tune

	bsr	set_for_lower
	bsr	show_pic
	bsr	flush

main_loop
	bsr	vsync
	bsr	set_screen
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

	bsr	user_mode
	clr.w	-(sp)
	trap	#1

exit	bsr	isr_off
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
	jsr	tune+8
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
	move.w	(a0)+,$ffff8242.w
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
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
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
	cmp.b	#12,d7
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

	lea	screens,a0		;clear both screens + below both
.loop	clr.l	(a0)+
	cmp.l	#stop,a0
	blt.s	.loop

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

toggle		dc.w	0	;50 hertz
screen_base	dc.l	0
		dc.l	0
scr_xor		dc.l	0

scroll_number	dc.w	16
pal_table
	dc.w	0
	dc.w	$088,$011,$099,$022,$0aa,$033,$0bb,$044,$0cc
	dc.w	$055,$0dd,$066,$0ee,$077,$0ff,$077,$0ee,$066
	dc.w	$0dd,$055,$0cc,$044,$0bb

black_pal	dcb.w	16,0

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
	dc.b $ff,$ff
	incbin	sine1.dat

	even
pal_pos	dc.l	colours
colours

 dc.w	$100,$200,$300,$400,$500,$600,$700,$710
 dc.w	$720,$730,$740,$750,$760,$770

 dc.w	$100,$200,$300,$400,$500,$600,$700,$710
 dc.w	$720,$730,$740,$750,$760,$ff0,$ff0,$671,$572
 dc.w	$473,$374,$275,$176,$077,$167,$257,$347
 dc.w	$437,$527,$617,$70f,$f06,$605,$504,$403
 dc.w	$302,$201,$100,$000


vu_colours		;change these for different VU colours...
	dcb.w	12,$00f
	dcb.w	 5,$005
	dcb.w	 5,$003

	
*******************************
* scroller variables and data *
*******************************

********** scroll text is now mapped across both higher and lower case
**********
**********
scroll_pointer	dc.l	init_scroll_text
init_scroll_text
	dc.b	"                          "
scroll_text
 dc.b "ERIK PLANKTON OF NORTHSIDE PRESENTS DISC 25.        "
 DC.B "RELEASED DATE: 1/2/92          "
 dc.b "         CREDITS FOR THIS MENU GOTO......"
 dc.b "      CODING BY ERIK PLANKTON/MAC SYS DATA,      MUSIC FROM PREHISTORIC TALE.     "
 dc.b "                                                "
 dc.b "erik plankton sends his greetings to all members of p.o.v.,   "
 dc.b "ripped off,     bbc,     tmb     and     elite.        fuckings to    "
 dc.b "now 5,    the source (fucking lame bastards),     "
 dc.b "untouchables (mega fucking lamers),     thunderforce     "
 dc.b "and    text changers.            "
 dc.b "if you want to get off my fuck off list then write your own "
 dc.b "stuff and do your own hacks you lame bastards.    if you "
 dc.b "have to go begging to other crews for menus then you're shit. "
 dc.b "   if you can't code a menu then you'll never crack a game so "
 dc.b "learn 68000 and stop stealing other peoples work.       "
 dc.b "  it seems to me that there are too many small groups "
 dc.b "all proclaiming they are the best when realisticly there "
 dc.b "are 2 or 3 groups doing all the work  -   think about it.    "
 dc.b "                                "
 DC.B $ff
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

tune	incbin	in_game3.mus
pic	incbin	pic.PI1


spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.w	MAX_BARS,0


key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
;	dc.b	5,3	;key 4
;	dc.b	6,4	;key 5
;	dc.b	7,5	;key 6

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
;	dc.b	$6a,3	;keypad 4
;	dc.b	$6b,4	;keypad 5
;	dc.b	$6c,5	;keypad 6
	dc.b	$ff
	even

filenames
	dc.l	exec1,exec2,exec3

exec1	dc.b	"filename.1",0
	even
exec2	dc.b	"filename.2",0
	even
exec3	dc.b	"filename.3",0
	even



*****************************
	SECTION BSS
*****************************
stack_save	ds.l	1
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
stop
*************************************************************************
*			Persistence Of Vision menu 160			*
*			------------------------------			*
*									*
* Written by;-								*
*		Machine System Data of Persistence Of Vision		*
*									*
* Assemble with GENST2.08 or higher					*
*									*
*									*
*									*
* Date:  31/12/91 revised for POV160 30-9-97				*
*									*
*									*
*************************************************************************
	OPT	o+,w-

******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
DOWNLOAD	equ	NO

	ifne	DOWNLOAD
	include	transmit.s
	org	$20000

Code_Start
Exec_Addr
	ENDC
***********************************************************************


begin	bra	start

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

	ifeq	DOWNLOAD
	bsr	set_super
	endc

	bsr	save_pal
	move.b	#$12,$fffffc02.w		;no mouse
	bsr	get_base			;get screen
	bsr	set_up				;create new screen space
	move.l	screen_base,a0			;go for low rez
	bsr	set_low_rez
	bsr	set_screen			;set screen to new position

;************************************************************************
;*          PUNISH YOUR MACHINE 'SICKEST OF THEM ALL SCREEN'		*
;*          -----------------------------------------------		*
;************************************************************************
	moveq	#1,d0				;init music
	bsr	music

	bsr	set_for_lower			;start interrupts, etc.
	bsr	show_pic
	bsr	flush				;empty keyboard buffer

main_loop
	bsr	vsync				;sync to our new VBL
	bsr	set_screen			;flip screen
	bsr	clear_spec			;clear old spec anal
	bsr	calc_spec			;calc and print new one
	bsr	scroll				;do the scroll
 	bsr	sentence			;copy scroll to wavey one
;	move.w	#$123,$ffff8240.w		;show CPU time left (NOT A LOT!)

	move.w	key,d0

	ifne	DOWNLOAD
	cmp.w	#1,d0		;ESC
	bne.s	assem
	move.l	4.w,-(sp)
	rts
	endc
assem
	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero

	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
	beq	reset

	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	main_loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run	lsr.w	#8,d1
	and.w	#$f,d1
	lsl.w	#2,d1
	lea	filename_table,a0
	move.l	(a0,d1.w),a0
	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

	bsr	isr_off

	move.l	old_base,a0	;screen_base
	bsr	set_low_rez

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ffff820a.w
hz50	move.b	#8,$fffffc02.w

	ifeq	DOWNLOAD
	bsr	user_mode
	else
	move.l	4.w,-(sp)
	rts
	endc

	bra	exec


exit	bsr	isr_off

	move.l	old_base,a0
	bsr	set_med_rez

	bsr	restore_pal

	move.b	#8,$fffffc02.w
	
	bsr	user_mode

	clr.w	-(sp)
	trap	#1

reset	move.l	4.w,-(sp)
	rts



zero	tst.w	zero_counter
	bne	main_loop

	eor.w	#$001,pic+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra	main_loop

do_reset
	move.l	4.w,a0
	jmp	(a0)

********************
* Special routines *
********************

************
* sentence *
************
*** 4 pixel wave scroller....
sentence
	bsr	clear_sentence
	move.l	screen_base,a1
	lea	120*160(a1),a1
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


;this clears the whole wavescroll area, it's slow and a lazy way
;but who cares?
clear_sentence
	move.l	screen_base,a0
	lea	160*120(a0),a0
	moveq	#0,d1
	REPT	70
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
	lea	(160*39)+(160*40)+4(a1),a1
	moveq	#0,d0
	REPT	26
	move.w	d0,(a1)
	move.w	d0,8(a1)
	move.w	d0,16(a1)
	move.w	d0,24(a1)
	move.w	d0,32(a1)
	move.w	d0,40(a1)
	move.w	d0,48(a1)
	move.w	d0,56(a1)
	move.w	d0,64(a1)
	move.w	d0,72(a1)
	move.w	d0,80(a1)
	move.w	d0,88(a1)
	move.w	d0,96(a1)
	move.w	d0,104(a1)
	move.w	d0,112(a1)
	move.w	d0,120(a1)
	move.w	d0,128(a1)
	move.w	d0,136(a1)
	move.w	d0,144(a1)
	move.w	d0,152(a1)
	lea	160(a1),a1
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
	add.w	#(51*160)+(160*40)+4,a0

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




; 8 pixel every VBL scroller
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
	mulu	#23*4,d0
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



vu	movem.l	d5-d7/a3-a6,-(sp)
	move.b	#AAMP,$ffff8800.w	;chan A
	move.b	$ffff8800.w,d7
	move.l	screen_base,a6
	add.l	#32000+1280+8+4,a6	;screen always in A6
	bsr.s	METER
	move.b	#BAMP,$ffff8800.w	;chan B
	move.b	$ffff8800.w,d7
	add.w	#160*5,a6
	bsr.s	METER
	move.b	#CAMP,$ffff8800.w	;chan C
	move.b	$ffff8800.w,d7
	add.w	#160*5,a6
	bsr.s	METER
;flash the disc drive light
	move.b	#BAMP,$ffff8800.w
	move.b	$ffff8800.w,d7
	cmp.b	#15,d7
	blt.s	no_flash
	move.b	#14,$ffff8800.w
	bclr	#1,$ffff8802.w
	bra.s	asdf
no_flash
	move.b	#14,$ffff8800.w
	or.b	#%00000010,$ffff8802.w
asdf:	movem.l	(sp)+,d5-d7/a3-a6
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


********
* ISRs *
********
new_kbd	;new keyboard handler - returns GEM VDI low byte in key.w
	movem.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,d0
	rte


newvbl
	clr.b	counter		;set up border count down

	move.l	#new_120,$120.W

	clr.w	vsync_flag

	move.l	#colours,pal_pos
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	music+4			;do tune
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6

	bsr	vu

	tst.w	zero_counter		;prevent 0 being pressed too fast
	beq.s	.no
	subq.w	#1,zero_counter
.no
	clr.b	$fffffa1b.w		;stop timer B
	move.b	#64,$fffffa21.w		;start rasters on line 36
	move.b	#8,$fffffa1b.w		;restart timer B
	rte


new_120	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w		;do it every 2 lines
	move.l	#new_120_part2,$120.w
	move.b	#8,$fffffa1b.w
	rte

new_120_part2
	move.l	a0,-(sp)
	move.l	pal_pos,a0
	move.w	spec_cols-pal_pos(a0),$ffff8248.w	;spectrum colours
	move.w	(a0)+,$ffff8242.w
	move.w	$ffff8242.w,$ffff8248+2.w	;make demo titles infront of spectrum
	move.l	a0,pal_pos
	move.l	(sp)+,a0
	add.b	#1,counter
	cmp.b	#27,counter
	beq.s	.set
	rte

.set	move.l	#new_120_part4,$120.w
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

	REPT	16
	nop
	ENDR
	MOVE.B	#2,$FFFF820A.W

	lea	pal_table,a0
	move.w	#24-1,d0	;colour the bottom scroller
col_loop
	move.w	(a0),$ffff8242.w
	move.w	(a0)+,$ffff8240+$a.w
	move.w	vu_colours-pal_table(a0),$ffff8240+8.w
	REPT 116
	nop
	ENDR
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	rte


isr_off	ORI.W	#$700,SR
	move.l	old120,$120.w
	move.l	old118,$118.w
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



vsync	move.w	#-1,vsync_flag
.no	tst.w	vsync_flag
	bne.s	.no
	rts


flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2	rts



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
set_rez
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


set_for_lower
;set up for no bottom border
	lea	stop,a0
.loop	clr.l	-(a0)
	cmp.l	#screens,a0
	bgt.s	.loop

	ori.w	#$700,sr
	move.l	$70.w,old70
	move.l	$118.w,old118
	move.l	$120.w,old120
	move.b	$fffffa07.w,olda07
	move.b	$fffffa09.w,olda09
 	move.b	$fffffa13.w,olda13
 	move.b	$fffffa17.w,olda17
	move.b	$fffffa1b.w,olda1b
	move.b	$fffffa21.w,olda21

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w

	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#new_120,$120.w

	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	clr.b	$fffffa1b.w
	clr.b	$fffffa21.w
	move.w	#$2300,sr
	rts


	IFEQ	DOWNLOAD
**************************
	SECTION DATA
**************************
	endc
demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
;	dc.b	4, $06		;key 5
;	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
;	dc.b	4, $6b		;keypad 5
;	dc.b	5, $6c		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"necromun.prg",0
	even
exec2	dc.b	"farewell.prg",0
	even
exec3	dc.b	"demo3.prg",0
	even
exec4	dc.b	"copier.pov",0
	even
exec5	dc.b	"filename.ext",0
	even
exec6	dc.b	"filename.ext",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even
exec9	dc.b	"filename.ext",0
	even



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

toggle		dc.w	0	;50/60 hertz

pal_table
	dc.w	0
	dc.w	$088,$011,$099,$022,$0aa,$033,$0bb,$044,$0cc
	dc.w	$055,$0dd,$066,$0ee,$077,$0ff,$077,$0ee,$066
	dc.w	$0dd,$055,$0cc,$044,$0bb

black_pal	dcb.w	16,0

vsync_flag	dc.w	0
old_base	dc.l	0
old_pal:	ds.b	32

******************************
* letters variables and data *
******************************
reset_detect	dc.w	0
pos		dc.l	init_table
init_table
	dcb.b	60,0
table	incbin	sine1.dat
	dc.b $ff,$ff
	incbin	sine1.dat

	even
pal_pos	dc.l	colours
colours
	dc.w	$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006
	dc.w	$00e,$007,$00f,$08f,$01f,$09f,$02f,$0af,$03f
	dc.w	$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f

	dc.w	$100,$200,$300,$400,$500,$600,$700,$710
	dc.w	$720,$730,$740,$750,$760,$ff0,$ff0,$671,$572
	dc.w	$473,$374,$275,$176,$077,$167,$257,$347
	dc.w	$437,$527,$617,$70f,$f06,$605,$504,$403
	dc.w	$302,$201,$100,$000


spec_cols	;spectrum analyzer colours...
	dc.w	0,0,0,0,0,0,0,0
	dc.w	$020,$0a0,$030,$0b0,$040,$0c0,$050,$0d0,$060
	dc.w	$0e0,$070,$0f0,$0f8,$0f1
	dcb.w	12,0


vu_colours	;colours for VU meters
	dcb.w	12,$070
	dcb.w	5,$050
	dcb.w	5,$030

	
*******************************
* scroller variables and data *
*******************************

scroll_pointer	dc.l	init_scroll_text
init_scroll_text
	dc.b	"                          "
scroll_text
 dc.b "PERSISTENCE OF VISION DISC 160.        "
 DC.B "RELEASED DATE: 1/10/97          "
 dc.b "hello everyone in atari and pacifist land. here is another pov "
 dc.b "demo compilation so soon after the last one.    i recently came "
 dc.b "home from my holiday and decided to clear my computer room up.  i "
 dc.b "found many demos that i had forgotten about so i started packing "
 dc.b "some.  the first to be packed was necro munda, this demo has some "
 dc.b "parts that only work on 1 meg but the demo will work perfectly on "
 dc.b "half meg machines.           "
 dc.b "well i went to the cinema last night (30-september-1997) at uci in "
 dc.b "preston, lancs. when i came out some bastard had vandalized my "
 dc.b "brand new car by making a hugh scratch in the bonnet.  if i ever "
 dc.b "found out who it was, i'd break every finger on their hands.   i am "
 dc.b "going to have the bonnet re-sprayed now at my expense. if the cost "
 dc.b "of the respray is too high, i will be able to claim some on my insurance.   "
 dc.b "        if you have access to the internet you can now visit the official "
 dc.b "pov site at    www.fatal-design.com      here you will find the 'little "
 dc.b "green desktop' plus the pov site.     if you like coding in assembly then "
 dc.b "you may be interested that i have released the second official source code "
 dc.b "disk. you should be able to download it soon from the web site. you can "
 dc.b "e-mail my from the web site if you wish to contact me.         "
 dc.b "            CREDITS FOR THIS MENU GOTO......"
 dc.b "      CODING BY MAC SYS DATA OF P.O.V.,      MUSIC RIPPED "
 dc.b "BY M.U.G. UK from Misfits demo 'Epilsons Nightmare' screen.       "
 dc.b "       i start college again soon so i do not think i will be able to "
 dc.b "release many pov disks. i have only one subject to complete between october and "
 dc.b "feb 1998 and it is maths which means i should be able to do some coding as "
 dc.b "you do not get assignments in maths!       the second part of the year "
 dc.b "i will be studying cad and cad/cam.   after this year i will have gained a "
 dc.b "hnd in mechatronics.  after this i will start doing my degree.        "
 dc.b "         if you are into motorcycles then you may see me at the "
 dc.b "international motorcycle show in birmingham on the 10th of november 1997. "
 dc.b "i will be taking my girl with me, i will probably be wearing a carter usm "
 dc.b "t shirt so be on the look out.       well, this must be enough as a "
 dc.b "scroll text so press a key.                                  "
 dc.b "                                                "
 DC.B $ff
	even

char_offset	dc.w	0
font	dcb.b	23*4,0
	incbin	font.dat

*
* This FONT_OFFSET refers to the FONT.PI1 pic.
* Each line in the PIC has 10 characters on it numbered
*  1-10
* 11-20
* 21-30
* 31-40
*     The table below set the ASCII character to the position
*     on the pic. It allows you to have the FONT.PI1 in any order.
*
*     Use the NIK_FONT.S to remove the font from the FONT.PI1
*
*	Using the table you can also have characters pointing to
*	more than one character, e.g. ALL brackets ()[]{} point to ( and )
*
*	OR you can draw a logo in the FONT.PI1 and make some characters
*	point to the logo, e.g xyz (lower case)...
*
*			All 0 make character a space.
*

font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,44,43,00,45,00,42,51,46,47,00,00,49,00,48,29

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	41,31,32,33,34,35,36,37,38,39,59,58,00,00,00,43,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,11,12,13,14,15,16,17,18

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	19,21,22,23,24,25,26,27,28,46,00,47,00,47,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,11,12,13,14,15,16,17,18,19,21,22,23

;        v  w  x  y  z  {  |  }  ~
 dc.b	24,25,26,27,28,46,00,47,00

	even
music	incbin	misfit15.mus
	even


pic	incbin	thunder.PI1


spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.w	MAX_BARS,0



	IFEQ	DOWNLOAD
	SECTION BSS
	endc

screen_base	ds.l	1
		ds.l	1
scr_xor		ds.l	1
stack_save	ds.l	1
old70		ds.l	1
old118		ds.l	1
old120		ds.l	1
olda07		ds.l	1
zero_counter	ds.w	1
key		ds.w	1
olda09		ds.b	1
olda13		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
counter		ds.b	1
	even

	ds.l	100
ustack	ds.l	1

	ds.b	256
screens	ds.b	41984
	ds.b	41984
stop
	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC

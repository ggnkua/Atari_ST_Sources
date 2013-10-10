*************************************************************************
*			Persistence Of Vision 102			*
*			-------------------------			*
*									*
*									*
* Written by:	Mac Sys Data						*
*									*
*       Date:	31-12-97						*
*									*
*     Art by:	Oz							*
*									*
*   Music by:	Frazor							*
*									*
*									*
*									*
*									*
*									*
*************************************************************************


******* DOWNLOAD DEVELOPMENT SWITCHES ***********************************
*The download development is used for code on a master Atari and down	*
*load the executable code to a slave Atari.				*
*************************************************************************
YES	equ	1
NO	equ	0
no=NO
yes=YES
DOWNLOAD	equ	YES
	ifne	DOWNLOAD
	include	transmit.s
	org	$10000
Code_Start
Exec_Addr
	ENDC

************************************************************************
*Code starts here...

*clear BSS as some packers don't
	lea	bssstart,a0
	move.l	#bssend-bssstart,d0
clear	clr.b	(a0)+
	sub.l	#1,d0
	bne.s	clear

	ifeq	DOWNLOAD		;if using download, do not go into Super mode
	bsr	set_super
	endc

	bsr	set_up		;initialise menu (tune, screen base, etc.)

main_loop	bsr	vsync		;sync to vertical interrupt
;		move.w	#$123,$ffff8240.w
		bsr	set_screen	;flip screen
		bsr	rippler
		bsr	clear_scroll
		bsr	scroll
		bsr	logo_switch
;		move.w	pic+2,$ffff8240.w

	cmp.w	#1,key		;esc
	beq	exit

	cmp.w	#$b,key		;0 key
	beq	zero

	cmp.w	#$70,key	;0 keypad
	beq	zero
no_hertz_change

; now scan keys for valid press
	lea	key_codes,a0
	move.b	key+1,d0
.loop	cmp.b	#$ff,(a0)
	beq.s	main_loop
	cmp.b	(a0)+,d0
	beq.s	load
	move.b	(a0)+,d1
	bra.s	.loop

load	move.b	(a0),-(sp)	;key press offset

	bsr	isr_off

	moveq	#0,d0
	move.b	(sp)+,d0
	lsl.w	#2,d0		*4
	lea	filenames,a0
	move.l	(a0,d0),a0
	lea	$200.w,a1
	move.l	(a0)+,(a1)+		;AUTORUN 4 load system
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50
	move.b	#$8,$fffffc02.w
	move.b	old484,$484.w
	bsr	set_old_palette
	bsr	set_org_rez

	lea	$ffff8800.w,a0	;*turn off sound chip
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	ifeq	DOWNLOAD
	move.l	stack_save,a0
	move.w	#$0300,sr
	move.l	a0,sp		;frig the stack a bit
				;to user stack and alter SR to user
	endc

	clr.w	-(sp)
	TRAP	#1

exit	bsr	isr_off
	move.b	#$8,$fffffc02.w
	move.b	old484,$484.w
	bsr	set_old_palette
	bsr	set_org_rez

	lea	$ffff8800.w,a0	;*turn off sound chip
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	ifne	DOWNLOAD
	move.w	4.w,-(sp)
	rts
	endc

	ifeq	DOWNLOAD
	move.l	stack_save,a0
	move.w	#$0300,sr
	move.l	a0,sp		;frig the stack a bit
				;to user stack and alter SR to user
	endc

	clr.w	-(sp)
	TRAP	#1


zero	tst.w	zero_counter
	bne	no_hertz_change
	eor.w	#$002,present_pal
	move.w	#10,zero_counter
	eor.w	#-1,hertz_toggle
	bra	main_loop

*******************
* CUSTOM ROUTINES *
*******************
logo_switch
	tst.w	in_progress
	bne	try

	move.l	logo_timer,d0
	beq.s	.do
	subq.l	#1,logo_timer
	rts

.do	eor.w	#$ffff,in_progress
	move.w	logo_number,d0
	lsl.w	#3,d0		*8
	lea	logo_table,a0
	move.l	(a0,d0.w),logo_timer	;D1 for Z flag set (not Ax)
	move.l	4(a0,d0.w),d1		;D1 for Z flag set (not Ax)
	bpl.s	.no_reset
	clr.w	logo_number
	move.l	4(a0),d1
	move.l	(a0),logo_timer
.no_reset
	move.l	d1,a0		;logo in A0

*** get routine to print with....
	move.l	sequence_pointer,a4
	cmp.l	#-1,(a4)
	bpl.s	.no_restart
	lea	sequence,a4
.no_restart
	move.w	(a4)+,d6
	move.l	a4,sequence_pointer
	lea	routine_table,a6
	move.l	0(a6,d6.w),present_routine


	move.w	(a0)+,d7	;test for a live palette to show logo
	beq.s	.over

;if pal=$fff then instantly black out pal

	movem.l	(a0)+,d0-d6
	movem.l	d0-d6,present_pal+2
	move.w	(a0)+,present_pal+30

.over	move.l	a0,present_logo
	addq.w	#1,logo_number

;print logo
try	move.l	present_routine,a6
	jmp	(a6)

routine_1
	move.l	present_logo,a0
	move.l	screen_base,a1
	move.l	a1,d1
	move.l	scr_xor,d7
	eor.l	d7,d1
	move.l	d1,a2

	move.w	logo_offset,d0
	cmp.w	#40*160,d0
	bne.s	.not_all_done
	clr.w	in_progress
	clr.w	logo_offset
	rts
.not_all_done
	add.w	d0,a1
	add.w	d0,a2
	add.w	d0,a0
	add.w	#160,logo_offset
	bra	routine_common_draw

routine_2
	move.w	#160*40,logo_offset
	move.l	#routine_2a,present_routine
	rts
routine_2a
	move.l	present_logo,a0
	move.l	screen_base,a1
	move.l	a1,d1
	move.l	scr_xor,d7
	eor.l	d7,d1
	move.l	d1,a2

	move.w	logo_offset,d0
	bne.s	.not_all_done
	clr.w	in_progress
	clr.w	logo_offset
	rts

.not_all_done
	subq.w	#4,d0
	add.w	d0,a1
	add.w	d0,a2
	add.w	d0,a0

	move.l	(a0),(a1)
	move.l	(a0),(a2)
	move.l	-(a0),-(a1)
	move.l	(a0),-(a2)
	REPT	19			;print 1 line of logo
	move.l	-(a0),-(a1)
	move.l	(a0),-(a2)
	move.l	-(a0),-(a1)
	move.l	(a0),-(a2)
	ENDR
	sub.w	#160,logo_offset
	rts

routine_3
	move.l	present_logo,a0
	move.l	screen_base,a1
	move.l	a1,d1
	move.l	scr_xor,d7
	eor.l	d7,d1
	move.l	d1,a2

	move.w	logo_offset,d0
	cmp.w	#20*160,d0
	bne.s	.not_done

	clr.w	in_progress
	clr.w	logo_offset
	clr.w	routine3_xor
	rts

.not_done
	tst.w	routine3_xor
	beq.s	.not
	add.w	#160*20,d0
	add.w	#160,logo_offset
.not	add.w	d0,a1
	add.w	d0,a2
	add.w	d0,a0
	not.w	routine3_xor
	bra.s	routine_common_draw




routine_4
	move.l	present_logo,a0
	move.l	screen_base,a1
	move.l	a1,d1
	move.l	scr_xor,d7
	eor.l	d7,d1
	move.l	d1,a2

	move.w	logo_offset,d0
	cmp.w	#5*160,d0
	bne.s	.not_done

	clr.w	in_progress
	clr.w	logo_offset
	clr.w	routine4_count
	rts

.not_done
	move.w	routine4_count,d4
	cmp.w	#8,d4
	bne.s	.not
	add.w	#160,logo_offset
	clr.w	d4
	move.w	d4,routine4_count
.not	mulu	#5*160,d4
	add.w	d4,d0
	add.w	d0,a1
	add.w	d0,a2
	add.w	d0,a0
	addq.w	#1,routine4_count

routine_common_draw
	REPT	20			;print 1 line of logo
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	ENDR
	rts



rippler	move.l	ripple_table_pos,a6
	cmp.l	#reset_ripple_flag,a6
	blt.s	.do_rout
	move.l	#ripple_table,ripple_table_pos
.do_rout
	move.l	screen_base,a5
	move.l	a5,d1
	move.l	scr_xor,d7
	eor.l	d7,d1
	move.l	d1,a5

	add.w	#42*160,a5

	lea	ripple_data,a4
	move.w	#40-1,d7
.loop
	move.b	(a6)+,d0
	move.b	(a6)+,d1
	move.l	a5,a1		;store for later
	lea	52*160(a5),a3
	lea	52*160(a3),a2
	move.l	a4,a0		;store for later
	and.l	#$ff,d0
	and.l	#$ff,d1
	lsl.w	#3,d0		;word offset
	mulu	#28*40,d1	;ripple number
	add.w	d1,a0
	add.w	d0,a1
	add.w	d0,a2
	add.w	d0,a3

	move.l	(a0),(a1)
	move.l	(a0),(a2)
	move.l	(a0)+,(a3)

	move.l	(a0),8(a1)
	move.l	(a0),8(a2)
	move.l	(a0)+,8(a3)

	move.l	(a0),16(a1)
	move.l	(a0),16(a2)
	move.l	(a0)+,16(a3)

	move.l	(a0),24(a1)
	move.l	(a0),24(a2)
	move.l	(a0)+,24(a3)

	move.l	(a0),32(a1)
	move.l	(a0),32(a2)
	move.l	(a0)+,32(a3)

	move.l	(a0),40(a1)
	move.l	(a0),40(a2)
	move.l	(a0)+,40(a3)

	move.l	(a0),48(a1)
	move.l	(a0),48(a2)
	move.l	(a0)+,48(a3)

	lea	28(a4),a4		;drop down a line within logo
	lea	160(a5),a5		;down a line on screen
	dbf	d7,.loop
	addq.l	#2,ripple_table_pos
	rts

shift_logo		;7 words wide
	lea	ripple_data,a1
	move.w	#16-1,d1
.loop2	lea	logo_pic+34,a0
	sub.w	d4,d4
	move.w	#40-1,d0
.loop	move.w	(a0),(a1)+
	move.w	2(a0),(a1)+

	move.w	8(a0),(a1)+
	move.w	10(a0),(a1)+

	move.w	16(a0),(a1)+
	move.w	18(a0),(a1)+

	move.w	24(a0),(a1)+
	move.w	26(a0),(a1)+

	move.w	32(a0),(a1)+
	move.w	34(a0),(a1)+

	move.w	40(a0),(a1)+
	move.w	42(a0),(a1)+

	move.w	48(a0),(a1)+
	move.w	50(a0),(a1)+

	lea	160(a0),a0
	dbf	d0,.loop
	lea	logo_pic+34,a0	;scroll
	move.w	#40-1,d2
.scroll	roxr.w	(a0)
	roxr.w	8(a0)
	roxr.w	16(a0)
	roxr.w	24(a0)
	roxr.w	32(a0)
	roxr.w	40(a0)
	roxr.w	48(a0)
	roxr.w	56(a0)
	sub.l	d4,d4
	roxr.w	2(a0)
	roxr.w	2+8(a0)
	roxr.w	2+16(a0)
	roxr.w	2+24(a0)
	roxr.w	2+32(a0)
	roxr.w	2+40(a0)
	roxr.w	2+48(a0)
	roxr.w	2+56(a0)
	sub.w	d4,d4
	lsr.w	#8,d4
	lea	160(a0),a0
	dbf	d2,.scroll
	dbf	d1,.loop2
	rts

clear_scroll
	move.l	old_wave_pointer,a1
	move.l	(a1),a1
	move.w	#40-1,d0
	moveq	#0,d2
	move.w	d2,d3
	move.w	d2,d4
.loop	move.l	screen_base,a0
	move.w	(a1)+,d1
	addq.w	#6,a0
	move.l	a0,a2
	add.w	d1,a0
	REPT	11
	move.b	d3,(a0,d2.w)
	lea	160(a0),a0
	ENDR
	lea	12*160(a0),a0
	REPT	8
	move.b	d3,(a0,d2.w)
	lea	160(a0),a0
	ENDR

	not.w	d4
	bpl.s	.word
	addq.w	#1,d2
	bra.s	.la
.word	addq.w	#7,d2
.la	move.l	a2,a0
	dbf	d0,.loop
	rts

scroll	move.l	screen_base,a1
	addq.w	#6,a1
	cmp.l	#waves_end,wave_pointer
	blt.s	.no_reset
	move.l	#waves,wave_pointer
.no_reset
	move.l	wave_pointer,a6

	move.l	old_wave_pointer,a5
	move.l	a6,(a5)

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
	mulu	#(31*4),d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#31,d0		;char depth 31 deep
	add.w	d0,a0

.column
	moveq	#0,d1
	move.w	(a6)+,d1
	move.l	a1,-(sp)
	add.w	d1,a1
OFF	set	0
	REPT	31
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	move.l	(sp)+,a1

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
	addq.l	#4,wave_pointer
	rts

***********************
* SUBROUTINES SECTION *
***********************
set_super
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

get_old_palette
	lea	$ffff8240.w,a0
	lea	old_palette,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_new_palette
	lea	pic+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,present_pal
	bra.s	set_pal

set_old_palette
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_screen_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,org_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,org_rez
	rts

set_org_rez
	move.w	org_rez,-(sp)
	move.l	org_base,screen_base
	bra.s	set_rez
set_low_rez
	clr.w	-(sp)
	bra.s	set_rez
set_med_rez
	move.w	#1,-(sp)
set_rez
	move.l	screen_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


show_pic
	move.l	screen_base,a1
	move.l	a1,a2
	add.l	#32768,a2
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0),(a2)+
	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

*Initial setup routines
set_up
	move.b	#$12,$fffffc02.w	;turn mouse off
	bsr	get_screen_base		;get present screen base
	bsr	get_old_palette		;get present palette
	bsr	get_original_rez	;get present resolution
	bsr	set_new_palette		;set new colours
	bsr	shift_logo		;preshift our logo

	move.l	#screens,d0		;calculate our screen
	clr.b	d0
	move.l	d0,screen_base
	move.l	d0,d1
	add.l	#32768,d1
	eor.l	d0,d1
	move.l	d1,scr_xor

	bsr	set_low_rez		;got low ST rez
	bsr	show_pic		;show picture
	move.b	$484.w,old484		;get present keyboard settings
	clr.b	$484.w			;clear keyboard repeat, etc.

;set up wave switching..............
	lea	old_wave_1,a0
	lea	old_wave_2,a1
	move.l	a0,d0
	move.l	a1,d1
	eor.l	d0,d1
	move.w	d1,old_wave_switch

	move.w	#$2700,sr		;turn off interrupts
	lea	storage,a0
	move.l	$70.w,(a0)+		;store old vertical interrupt
	move.l	$118.w,(a0)+		;store old keyboard vector
	move.l	$120.w,(a0)+		;store old horizontal interrupt
	move.l	$134.w,(a0)+		;store old timera vector
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+	;store old interrupt masks/data
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa19.w,(a0)+

	move.w	#$700,$ffff8240.w
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#new_120,$120.w		;make horizontal interrupt point to ours
	move.l	#new_70,$70.w		;make vertical interrupt point to ours
	move.l	#new_118,$118.w		;make keyboard interrupt point to ours
	bclr	#3,$fffffa17.w		;set automatically interrupt enable mode
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w

*init tune here in this case as it messes with the interrupt values then
*starts the interrupts. (if you don't you may get 2 bombs!)
	jsr	music	;only one tune in this piece


	move.w	#$2300,sr		;start interrupts
	rts



set_screen
	move.l	screen_base,d6
	move.l	scr_xor,d7
	eor.l	d7,d6
	move.l	d6,screen_base
	lsr.l	#8,d6
	lea	$ffff8201.w,a6
	movep.w	d6,(a6)
	rts



******* ISRs ************
new_118	movem.l	d0,-(sp)
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

new_120	clr.b	$fffffa1b.w	;timer B
	move.l	a0,-(sp)	;$120
	move.l	isr_data,a0
	move.w	(a0)+,$ffff8240+16.w
	move.l	a0,isr_data

	lea	logo_pic+4,a0
	move.l	(a0)+,$ffff8242.w
	move.l	(a0)+,$ffff8246.w
	move.l	(a0)+,$ffff824a.w
	move.l	(a0),$ffff824e.w

	move.l	(sp)+,a0

	move.l	#new_120_part2,$120.w

	move.b	#2,$fffffa21.w		;2 lines of each colour.....
	move.b	#8,$fffffa1b.w
	rte

new_120_part2
	clr.b	$fffffa1b.w	;timer B DI
	movem.l	d0/a0,-(sp)	;$120
	move.l	isr_data,a0

	move.l	30(a0),d0
	move.l	d0,$ffff8240+8.w	;make P.O.V. rippler behind
	move.l	d0,$ffff8240+12.w

	move.l	(a0),d0
	move.l	d0,$ffff8240+16.w	;make scroller over whole lot
	move.l	d0,$ffff8240+20.w
	move.l	d0,$ffff8240+24.w
	move.l	d0,$ffff8240+28.w
	add.l	#2,isr_data
	movem.l	(sp)+,d0/a0

	cmp.w	#24,counter
	blt.s	noa

c1	move.l	#$00000640,$ffff8242.w
c2	move.w	#$0754,$ffff8240+6.w
	clr.w	counter
	move.l	#$04100520,c1+2
	move.w	#$0730,c2+2

noa	addq.w	#1,counter

	move.b	#8,$fffffa1b.w
	rte

new_70	clr.b	$fffffa1b.w	;timer B

	move.w	old_wave_switch,d0
	and.l	#$ff,d0
	eor.l	d0,old_wave_pointer

	movem.l	d0-d7/a0-a6,-(sp)
	lea	isr_data(pc),a0
	move.l	#b_line,(a0)
	move.l	#new_120,$120.w
	clr.w	vsync_flag

	jsr	music+$20

	clr.w	counter
	move.l	#$00310053,c1+2
	move.w	#$0075,c2+2
	movem.l	present_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	tst.w	zero_counter
	beq.s	.ok
	sub.w	#1,zero_counter
.ok	move.b	#40,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

vsync	move.w	#-1,vsync_flag
.vs	tst.w	vsync_flag
	bne.s	.vs
	rts

isr_off	move.w	#$2700,sr
	lea	storage,a0
	move.l	(a0)+,$70.w		;store old vertical interrupt
	move.l	(a0)+,$118.w		;store old keyboard vector
	move.l	(a0)+,$120.w		;store old horizontal interrupt
	move.l	(a0)+,$134.w		;store old timera vector
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w	;store old interrupt masks/data
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa19.w
	move.w	#$2300,sr
	rts

	ifeq	DOWNLOAD
*******************************
	SECTION DATA
*******************************
	endc
stack_save	dc.l	0
screen_base	dc.l	0
org_rez		dc.w	0
org_base	dc.l	0
old484		dc.w	0
scr_xor		dc.l	0
	even
key		dc.w	0
vsync_flag	dc.w	0
line_count	dc.w	0	;count of horizontal line down screen for new_120
isr_data	dc.l	b_line
b_line
 dc.w	$080,$010,$090,$020,$0a0,$030,$0b0,$040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
 dc.w	$8f0,$1f0,$9f0,$2f0,$af0,$3f0,$bf0,$4f0,$cf0,$5f0,$df0,$6f0,$ef0,$7f0,$ff0
 dc.w	$f70,$fe0,$f60,$fd0,$f50,$fc0,$f40,$fb0,$f30,$fa0,$f20,$f90,$f10,$f80,$f00
 dc.w	$708,$e01,$609,$d02,$50a,$c03,$40b,$b04,$30c,$a05,$20d,$906,$10e,$807,$00f
 dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
 dc.w	$0ff,$07f,$0ef,$06f,$0df,$05f,$0cf,$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f
 dc.w	$00f,$807,$10e,$906,$20d,$a05,$30c,$b04,$40b,$c03,$50a,$d02,$609,$e01,$708
 dc.w	$f00,$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$f70
 dc.w	$ff0,$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0
 dc.w	$0f0,$070,$0e0,$060,$0d0,$050,$0c0,$040,$0b0,$030,$0a0,$020,$090,$010,$080
 dcb.w	10,0
	even

pic	incbin	pov102.pi1

scroll_pointer	dc.l	scroll_text+7
scroll_text
 DC.B "                            "
 dc.b "PERSISTENCE OF VISION PACKED DEMO DISC 102.    RELEASE DATE: 1ST MARCH 1992.      "
 dc.b "MENU CODED BY msd.   THE FRAZOR DIGI-DRUM MUSIC WAS RIPPED "
 dc.b "BY msd.     ALTHOUGH BORIS IS STILL LISTED AS A MEMBER OF POV, HE HAS "
 DC.B "NO INPUT TO THE MENUS. HE IS STILL PART OF POV AS WE MAY RELEASE SOME SOFTWARE ON "
 DC.B "THE PC IN THE FUTURE ALTHOUGH WE WILL APPEAR UNDER A DIFFERENT CREW NAME.         "
 DC.B "THIS MENU WAS CODED ON THE 31-DECEMBER-1997.                                    "
 DC.B "    RIGHT THAT'S ALL FOR NOW, SEE YOU IN THE NEXT EPISODE OF "
 DC.B "msd'S ESCAPE TO THE PUB DOCUMENTARY.      "
 DC.B "                             "
 dc.b $ff
	even
char_offset	dc.w	0
font	dcb.b	31*4,0
	incbin	"1plane.fnt"
	even
old_wave_switch	dc.w	0
old_wave_pointer
	dc.l	old_wave_1
old_wave_1	dc.l	waves
old_wave_2	dc.l	waves
wave_pointer	dc.l	waves
waves		incbin	"sine1.dat"
waves_end	incbin	"sine1.dat"
	even
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,00,00,00,00,00

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	50,00,00,00,00,00,00,00,00,48,00,00,00,00,00,49,00,00

	even

music	incbin	frazor.mus
	even



************ LOGO BITS ************
present_logo	dc.l	0
in_progress	dc.w	0
logo_offset	dc.w	0
logo_timer	dc.l	400
logo_number	dc.w	0

*	length of time on screen, address of grafic
logo_table
	dc.l	1,blank
	dc.l	300,logo_pov
	dc.l	1,blank
	dc.l	200,logo_members
	dc.l	1,blank
	dc.l	100,logo_msd
	dc.l	1,blank
	dc.l	100,logo_boris
	dc.l	1,blank
	dc.l	300,logo_credits
	dc.l	-1,-1

;**** tables for logos ****
* xxxx.w * 16 = 16 word palette
*
* xxxx.w 160*40 bytes of logo
*
*
logo_pov	dc.w	$fff	;live palette (NOT BLANK GRAFIC)
		dc.w	$100,$111,$316,$505,$700,$740,$750
		dc.w	$750,$660,$460,$160,$064,$055,$046,$127
		incbin	logo.pov

logo_members	dc.w	$fff
		dc.w	$777,$777,$777,$777,$777,$777,$777
		dc.w	$200,$310,$420,$530,$640,$750,$760,$773
		incbin	logo.mem

logo_msd	dc.w	$fff
		dc.w	$700,$710,$720,$730,$740,$750,$760
		dc.w	$002,$112,$223,$334,$445,$556,$667,$777
		incbin	logo.msd

logo_boris	dc.w	$fff
		dc.w	$510,$720,$730,$740,$750,$760,$770
		dc.w	$010,$030,$040,$050,$260,$470,$670,$777
		incbin	logo.bos

logo_credits	dc.w	$fff
		dc.w	$700,$710,$720,$730,$740,$750,$760
		dc.w	$002,$112,$223,$334,$445,$556,$667,$777
		incbin	logo.cre

blank		dc.w	$000
		dcb.w	160*40,0


***** order in which logos are show *
* 0=routine 1
* 4=routine 2
* 8=routine 2
sequence_pointer
	dc.l	sequence

sequence
 dc.w	0,0,4,0,0,4,0,4,0,4,0
 dc.w	0,0,4,8,8,4,4,8,4,8,12,0,0,4,-1

present_routine	dc.l	routine_2
routine_table	dc.l	routine_1
		dc.l	routine_2
		dc.l	routine_3
		dc.l	routine_4

routine3_xor	dc.w	0
routine4_count	dc.w	0


ripple_table_pos	dc.l	init_ripple_table
init_ripple_table
	dcb.w	200,$0702
ripple_table
	incbin	xsine1.dat
	incbin	xsine2.dat

reset_ripple_flag
	incbin	xsine1.dat
	even
logo_pic	incbin	logo.pi1
	even
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

filenames	dc.l	exec1,exec2,exec3,exec4,exec5,exec6

exec1	dc.b	"abc6",0
	even
exec2	dc.b	"sewer",0
	even
exec3	dc.b	"vaxslide",0
	even
exec4	dc.b	"dma2",0
	even
exec5	dc.b	"blt_2",0
	even
exec6	dc.b	"copier.pov",0
	even


	ifeq	DOWNLOAD
*************************
	SECTION BSS
*************************
	endc
bssstart
zero_counter	ds.w	1

hertz_toggle	ds.w	1

counter		ds.w	1

old_palette	ds.w	16

present_pal	ds.w	16

ripple_data	ds.b	(56*40)*16
ripple_end

storage	ds.b	26

	ds.b	256
screens	ds.b	32768
	ds.b	32000

bssend 
	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC

***************************
* POV 22                  *
***************************

BUFFER_SIZE:	EQU	32
WIDTH:		EQU	16
BASE:		EQU	$66000	;put screen at $66000 when finally assembling
				;for 512K machines.
start:
	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$C(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1C(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

	lea	$24-3,a6	;set up a6 ready to stop TRACE function!!!
	bsr	set_super
wait_for_drive:
	tst.w	$43e
	bne.s	wait_for_drive

	bsr	save_pal

	lea	old_pal,a0
	lea	black_pal,a1
	bsr	fadein
	move.l	#-1,$24		;stop TRACE

	bsr	hide_cursor
	bsr	get_base
	move.l	#BASE,a0	;screen_base
	clr.w	$ff8264		;STE bit wise shift
	move.w	#$ff00,$ff820e
	bsr	set_low_rez

;************************************************************************
;* Tune driver by MSD of P.O.V - play DUGGER music                      *
;************************************************************************
;************************************************************************
;* Load DUGGER.IMG into TUNE before running                             *
;************************************************************************
; MAD MAX TUNE!
;shift tune data to position for playing
	lea	TUNE,A0
	move.l	#$7E000,A1
	move.w	#8191-1,D0
SHIFT:	move.b	(A0)+,(A1)+
	dbra	D0,SHIFT

;4 versions are available in this tune code, the standard tune starts
;automatically. To change to a different tune put the number 0-3 into
;D0.L and JSR $7E000
;0=small fanfare 1
;1=small fanfare 2
;2=was (not was) 52
;3=was (not was) 54
;4=was (not was) 55
;5+=ping!

	bsr	show_intro_pic
	lea	black_pal,a0
	lea	intro_pic+2,a1
	bsr	fadein

	move.w	#100,d7		;wait a while
delay:	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	dbf	d7,delay

	lea	intro_pic+2,a0
	lea	black_pal,a1
	bsr	fadein

	move.l	#4,D0	;play different tune
	jsr	$7e000

	move.l	#BASE,a0
	move.w	#32000/4-1,d0
clear_scrn:
	clr.l	(a0)+
	dbf	d0,clear_scrn

	lea	pic+2,a1
	lea	black_pal,a0
	bsr	fadein

	bsr	set_for_lower
	bsr	nik_sentence
	bsr	print_first_man
	bsr	transfer

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
;	move.w	$ffff8240.w,-(sp)
;	move.w	#$070,$ffff8240.w
	bsr	print_one_man
	bsr	logo
	bsr	scroll
	bsr	scroll
	bsr	scroll
;	move.w	(sp)+,$ffff8240.w
	MOVE.W	#$FFFF,horiz_sync
	move.b	$fffc02,d0
;	cmp.b	#01,d0		;escape
;	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$111,pic+2
	eor.w	#$ffff,toggle
	move.w	#10,zero_counter
	bra.s	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#4,d0		;3 key
	bge	main_loop	

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	bsr	user_mode
	move.l	old_base,a0
	add.w	#199*160,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
exit:
	bsr	isr_off

;reset rez
	move.l	old_base,a0
	bsr	set_med_rez
;	bsr	set_low_rez

	bsr	restore_pal

	bsr	show_cursor
	
	bsr	user_mode

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

********************
* Special routines *
********************

**********
* Runner *
**********
print_first_man:
	lea	men,a0
	lea	pic+34+(160*162)+136,a1
	move.w	#40-1,d0
.loop:
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	add.w	#160,a1
	dbf	d0,.loop
	rts

print_one_man:
	tst.w	man_toggle
	beq.s	do_man
	sub.w	#1,man_toggle
	rts
do_man:
	move.w	#3,man_toggle
	cmp.w	#10,man_number
	bne.s	no_reset_man
	clr.w	man_number
no_reset_man:
	move.w	man_number,d0
	add.w	#1,man_number
	lea	men,a0
	mulu	#640,d0
	add.w	d0,a0

	move.l	#BASE+(160*162)+136,a1
	move.w	#40-1,d0
.loop:
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	add.w	#160,a1
	dbf	d0,.loop
	rts

************
* sentence *
************
logo:	tst.w	sentence_count
	beq.s	draw
	sub.w	#1,sentence_count
	rts

draw:	move.w	#1,sentence_count
	bsr	clear_sentence
	lea	sentence,a0
	move.l	#BASE+160*90,a1
	move.l	pos,a2

	cmp.b	#$ff,(a2)
	bne.s	do_build
	move.w	#$ffff,reset_detect
	add.l	#1,pos
do_build:
	tst.w	reset_detect
	beq.s	no_logo_reset
	move.l	#table,pos
	clr.w	reset_detect
no_logo_reset:
;now print a line of text.............
	move.w	#20-1,d0
logo_print:
	move.l	a1,a3
	clr.w	d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	no_reset_token
	move.b	(a2)+,d1
no_reset_token:
	mulu	#160,d1
	add.w	d1,a1

	move.b	(a0)+,(a1)
	move.b	(a0)+,160(a1)
	move.b	(a0)+,320(a1)
	move.b	(a0)+,480(a1)
	move.b	(a0)+,640(a1)
	move.b	(a0)+,800(a1)
	move.b	(a0)+,960(a1)
	move.b	(a0)+,960+160(a1)
	move.b	(a0)+,960+320(a1)

	move.l	a3,a1
	clr.w	d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	no_reset_token2
	move.b	(a2)+,d1
no_reset_token2:
	mulu	#160,d1
	add.w	d1,a1

	move.b	(a0)+,1(a1)
	move.b	(a0)+,161(a1)
	move.b	(a0)+,321(a1)
	move.b	(a0)+,481(a1)
	move.b	(a0)+,641(a1)
	move.b	(a0)+,801(a1)
	move.b	(a0)+,961(a1)
	move.b	(a0)+,960+161(a1)
	move.b	(a0)+,960+321(a1)
	move.l	a3,a1
	add.w	#8,a1
	dbf	d0,logo_print
	add.l	#1,pos
	rts

clear_sentence:
	move.l	#BASE+160*90,a0
	clr.w	d1
	move.w	#60-1,d0
.loop:	
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
	add.w	#160,a0
	dbf	d0,.loop
	rts

sentence_count:	dc.w	1
********************
* Service routines *
********************
scroll:	
	move.l	line_ptr,a6
	cmp.b	#$ff,(a6)
	bne	loop3
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr
loop3:	
	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	lsl.w	#5,d0	;*32 (single plane char set)
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
	lea	buffer,a1
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6),(a1)

loop2:	move.l	#BASE,a6
	add.l	#32000+320,a6
	move.l	a6,a2
	add.w	#152,a2

	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
loop:	roxl.w	(a1)
	move.w	(a1)+,d0
	and.w	#1,d0
	or.w	d0,2(a2)
	add.w	#160,a2
	dbf	d1,loop

	move.w	#16-1,d0
loopy:	roxl.w	152+2(a6)
	roxl.w	144+2(a6)
	roxl.w	136+2(a6)
	roxl.w	128+2(a6)
	roxl.w	120+2(a6)
	roxl.w	112+2(a6)
	roxl.w	104+2(a6)
	roxl.w	96+2(a6)
	roxl.w	88+2(a6)
	roxl.w	80+2(a6)
	roxl.w	72+2(a6)
	roxl.w	64+2(a6)
	roxl.w	56+2(a6)
	roxl.w	48+2(a6)
	roxl.w	40+2(a6)
	roxl.w	32+2(a6)
	roxl.w	24+2(a6)
	roxl.w	16+2(a6)
	roxl.w	8+2(a6)
	move.w	2(a6),d7
	and.w	#$3fff,d7
	roxl.w	#1,d7
	move.w	d7,2(a6)
	add.w	#160,a6
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts

********
* ISRs *
********
vert_isr:
	CLR.B	$FFFF8260.W
	clr.w	$ff8264	;STE bit wise shift
	move.w	#$ff00,$ff820e

	MOVEM.L	D0-d7,-(A7)

	MOVEM.L	pic+2(PC),d0-d7
	MOVEM.L	d0-d7,$FFFF8240.W

	MOVEM.L	(A7)+,D0-d7
	MOVE.B	#49,counter	;49/50 of a second

	MOVE.L	#horiz_isr,$120.W
	clr.w	horiz_sync

	movem.l	D0-D7/A0-A6,-(sp)
	jsr	$7E012
	movem.l	(sp)+,D0-D7/A0-A6

	BSR	vu
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.B	#3,$FFFFFA21.W
	rte

horiz_isr:
	move.b	#4,$fffffa21.w	  ;4/50 of a second (a frame) makes it in the
	move.l	#go_border,$120.w ;border. (at the start of a refresh)
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan
	rte

extended_scan:
	REPT 98
	nop
	ENDR
	CLR.B	$FFFF820A.W
	REPT 29
	nop
	ENDR
	MOVE.B	#2,$FFFF820A.W


	move.w	#$040,$ffff8248.w	;middle vu
	move.w	#$020,$ffff8250.w	;bottom vu

f1:	MOVE.L	#in_the_border,$120.W
	rte

in_the_border:
	clr.b	$fffa1b		;DI all other interrupts
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#40-1,d0
col_loop:
	move.w	(a0)+,$ff8244

	REPT 120
	nop
	ENDR

	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	bclr	#0,$fffa0f
	rte


isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120
	move.l	old70,$70
	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21
	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


; ISR to animate the VU METER
vu:	movem.l	d5-d7/a3-a6,-(sp)
	move.b	#$8,$ff8800	;chan A
	move.b	$ff8800,d7
	move.l	#BASE+32000+1280+1280+320+320,a6	;screen always in A6
	bsr.s	METER
	move.b	#$9,$ff8800	;chan B
	move.b	$ff8800,d7
	add.w	#160*5,a6
	bsr.s	METER
	move.b	#$a,$ff8800	;chan C
	move.b	$ff8800,d7
	add.w	#160*5,a6
	bsr.s	METER
;flash the disc drive light
	move.b	#$9,$ff8800
	move.b	$ff8800,d7
	cmp.b	#14,d7
	blt.s	no_flash
	move.b	#14,$ff8800
	bclr	#1,$ff8802
	bra.s	asdf
no_flash:
	move.b	#14,$ff8800
	or.b	#%00000010,$ff8802
asdf:	movem.l	(sp)+,d5-d7/a3-a6
	rts
METER:	tst.b	d7
	blt	exit_vu		;less than no volume!
	and.w	#$ff,d7
	cmp.w	#15,d7
	bgt	exit_vu
	add.w	#2,a6
	move.l	a6,a4
	add.l	#96,a4
	mulu	#16,d7
	lea	vu_block,a5
	add.l	d7,a5
	lea	vu2,a3
	add.l	d7,a3
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
exit_vu:
	rts

set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	clr.l	3(a6)
	rts

transfer:
	lea	pic+34,a0
	move.l	#BASE,a1
	move.w	#20-1,d7
.loop:	move.l	a0,a5
	move.l	a1,a6
	move.w	#8-1,d5
.loop3:	move.w	#200/8-1,d6
.loop2:	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	add.w	#8*160,a0
	add.w	#8*160,a1
	bsr	pause
	dbf	d6,.loop2
	sub.w	#200*160,a0
	sub.w	#200*160,a1
	add.w	#160,a0
	add.w	#160,a1
	dbf	d5,.loop3
	move.l	a5,a0
	move.l	a6,a1
	add.w	#8,a0
	add.w	#8,a1
	dbf	d7,.loop
	rts

pause:	move.w	d0,-(sp)
	move.w	#200,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
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
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
	rts

get_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_base
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

hide_cursor:
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts
ei_mouse:
	dc.b	$14,8
	even
di_mouse:
	dc.b	$12,$1a
	even

set_for_lower:
;set up for no botton border
	move.l	#BASE+32000,a0
	move.w	#45-1,d0
.loop:	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d0,.loop

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

nik_sentence:
	lea	pic+34,a0
	add.w	#160*90,a0
	lea	sentence,a1
	move.w	#40-1,d0
nik:
	move.b	(a0),(a1)+
	move.b	160(a0),(a1)+
	move.b	320(a0),(a1)+
	move.b	480(a0),(a1)+
	move.b	640(a0),(a1)+
	move.b	800(a0),(a1)+
	move.b	960(a0),(a1)+
	move.b	1120(a0),(a1)+
	move.b	1280(a0),(a1)+

	move.b	1(a0),(a1)+
	move.b	161(a0),(a1)+
	move.b	321(a0),(a1)+
	move.b	481(a0),(a1)+
	move.b	641(a0),(a1)+
	move.b	801(a0),(a1)+
	move.b	961(a0),(a1)+
	move.b	1121(a0),(a1)+
	move.b	1281(a0),(a1)+

	add.w	#8,a0
	dbf	d0,nik
	rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadein:	move	#7,d6
	move.l	a1,a2
fadein1:
	lea	palreg,a0	;LEA PALREG+2,A0; TARGET IN A1
	move.w	#14,d7
fadein2:
	bsr	modify
	addq	#2,a0
	addq	#2,a1
	dbf	d7,fadein2
	move.w	#4,d0
	bsr	fadedelay
	move.l	a2,a1
	dbf	d6,fadein1
	rts

fadedelay:
	bsr	owvbl
	dbf	d0,fadedelay
	rts

owvbl:	movem.l d0-d2/a0-a2,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l (sp)+,d0-d2/a0-a2
	rts
palreg:	EQU $FF8240


modify:	move.w	(a0),d0
	move.w	(a1),d1
	move.w	d0,d4
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$7,d2
	and.w	#$7,d3
	cmp.w	d2,d3
	beq	mok1
	bmi	mdn1
	addq	#1,d4
	bra	mok1
mdn1:	subq	#1,d4
mok1:	move.w	d0,d2
	move.w	d1,d3
	and.w	#$70,d2
	and.w	#$70,d3
	cmp.w	d2,d3
	beq	mok2
	bmi	mdn2
	add.w	#$10,d4
	bra	mok2
mdn2:	sub.w	#$10,d4
mok2:	move.w	d0,d2
	move.w	d1,d3
	and.w	#$700,d2
	and.w	#$700,d3
	cmp.w	d2,d3
	beq	mok3
	bmi	mdn3
	add	#$100,d4
	bra	mok3
mdn3:	sub.w	#$100,d4
mok3:	move.w	d4,(a0)
	rts

show_intro_pic:
	move.l	#BASE,a1
	lea	intro_pic+34,a0
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

********
* Data *
********
vu_block:
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

vu2:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
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

toggle:	dc.w	0	;50 hertz
scroll_number:	dc.w	16
pal_table:
	dc.w	$200,$200,$300,$400,$500,$600,$700,$700
	dc.w	$700,$600,$500,$400,$300,$200,$200
	DC.W	$070,$070,$070,$070,$070	;top VU colour
stack_save:	dc.l	0
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
black_pal:	dcb.w	0,16

horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0
old_pal:	ds.b	32

*********************
* Athlete variables *
*********************
man_toggle:		dc.w	3
man_number:	dc.w	0
men:	incbin	"runner.dat"
	even

******************************
* letters variables and data *
******************************
reset_detect:	dc.w	0
temp_table:	ds.b	40
pos:	dc.l	init_table
init_table:
	dcb.l	0,20
table:
 dcb.l	0,10
 dc.b 0,1,2,3,5,7,9,12,15,18,22,26,30,35,40,45,52
 dc.b 51,50,49,47,45,43,40,37,34,29,25,21,18,15,11,9,7,5,4,3,2,1,0,0,0,0,0,0
 dc.b 0,1,2,3,4,5,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40
 dc.b 42,44,46,48,50
 dc.b 50,48,44,40,38,36,34,32,30,28,26,24
 dcb.b 24,40
 dc.b 23,22,20,18,19,21,23,24,25,26,27,28,29,30
 dc.b 29,28,27,26,25,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
 dc.b 23,22,20,18,14,12,10,9,8,8,8,8,9,10,12,14,18,22,26,30,32,34,35,36,36,36,36
 dc.b 35,34,32,30,28,27,26,25
 dcb.b 24,40
 dc.b 23,22,20,18,16,13,10,7,5,3,2,1
 dc.b 0,1,2,3,5,7,10,13,16,20,24,28,33,38,42,45,47,48,49,50,49,48,47,45,42,38,33,28,24,20,16,13,10,7,5,3,2,1
 dc.b 0,1,2,3,5,7,10,13,16,20,24,28,33,38,42,45,47,48,49,50,49,48,47,45,42,38,33,28,24,20,16,13,10,7,5,3,2,1
 dc.b 0,1,2,3,5,7,10,13,16,20,24,28,33,38,42,45,47,48,49,50,49,48,47,45,42,38,33,28,24,20,16,13,10,7,5,3,2,1
 dc.b 0,1,2,3,5,7,10,13,16,20,24,28,33,38,42,45,47,48,49,50,49,48,47,45,42,38,33,28,24,20,16,13,10,7,5,3,2,1
 dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
 dc.b 28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,50,50,50,50,50,50,50,50,50,50,50
 dc.b 50,50,50,50,40,30,20,10,0,10,20,30,40,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
 dc.b 45,40,35,30,25,20,15,10,8,6,4,3,2,1,0,1,2,3,5,7,9,11,13,15,18,21,24,28,32,36,41,46,50,50,50,50
 dc.b 50,49,48,47,46,45,43,41,39,37,34,31,28,24,20,16,12,7,2,0,2,4,6,8,10,12,14,16,18,19,20,21,22,23,24,25
 dc.b 27,29,31,34,37,40,44,48,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,49,48,47,46,45
 dc.b 45,45,45,45,45,45,46,46,47,48,49,50,50,50,50,50,50,50,50
 dc.b 49,48,47,46,45,44,43,42,40,38,36,34,32,30,27,24,21,17,13,8,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 1,3,5,7,9,11,13,15,17,19,21,23,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
 dc.b 25,26,27,29,31,33,37,41,46,48,49,50,49,48,46,41,37,33,31,29,27,26,25,24,23,22,21,19,17,15,12,9,5,3,2,1,0,1,2,3,5,9,12,17,19,21,22,23,24
 dc.b 25,26,27,29,31,33,37,41,46,48,49,50,49,48,46,41,37,33,31,29,27,26,25,24,23,22,21,19,17,15,12,9,5,3,2,1,0,1,2,3,5,9,12,17,19,21,22,23,24
 dc.b 25,26,27,29,31,33,37,41,46,48,49,50,49,48,46,41,37,33,31,29,27,26,25,24,23,22,21,19,17,15,12,9,5,3,2,1,0,1,2,3,5,9,12,17,19,21,22,23,24
 dc.b 25,26,27,29,31,33,37,41,46,48,49,50,49,48,46,41,37,33,31,29,27,26,25,24,23,22,21,19,17,15,12,9,5,3,2,1,0,1,2,3,5,9,12,17,19,21,22,23,24
 dc.b 25,26,27,29,31,33,37,41,46,48,49,50,49,48,46,41,37,33,31,29,27,26,25,24,23,22,21,19,17,15,12,9,5,3,2,1,0,1,2,3,5,9,12,17,19,21,22,23,24
 dc.b 25,26,27,28,29,30,31,32,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15
 dc.b 16,17,18,19,20,21,22,23,24
 dc.b 22,20,18,16,14,12,11,10,9,9,8,8,8,8,8,8,8,8,8,8,8,9,10,11,12,13,15,17,19,22,25,29,33,38,43,50
 dcb.b	50,30
 dc.b 49,48,47,45,43,41,39,36,33,30,33,36,39,41,43,45,47,48,49,50
 dc.b 49,48,47,45,43,41,39,36,33,30,33,36,39,41,43,45,47,48,49,50
 dc.b 49,48,47,45,43,41,39,36,33,30,33,36,39,41,43,45,47,48,49,50
 dc.b 49,48,47,45,43,41,39,36,33,30,33,36,39,41,43,45,47,48,49,50
 dc.b 49,48,47,46,44,42,40,38,37,36,37,38,40,42,44,46,47,48,49,50
 dc.b 49,48,47,45,43,41,39,36,33,30,33,36,39,41,43,45,47,48,49,50
 dc.b 49,48,47,46,44,42,40,38,37,36,37,38,40,42,44,46,47,48,49,50
 dc.b 49,48,47,45,43,41,38,35,31,26,20,14,7,0
 dc.b 5,10,14,18,21,23,24,25,24,21,17,12,7,2,0
 dc.b 3,6,9,11,16,12,8,5,3,1,0
 dc.b 2,4,7,11,7,4,2,0,1,2,4,7,3,0,2,3,1,0,2,0,1,0,1,0,1,0,0,0,0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,6,8,11,14,19,25,33,42,50
 dcb.b 50,30
 dc.b 49,48,47,45,43,42,41,40,40,40,40,40,40,40,40,40,41,42,43,45,47,48,49,50
 dc.b 50,50,50,50,49,48,47,45,43,41,38,36,34,33,32,31,30,30,30,30,30,30,30
 dc.b 30,31,32,33,35,37,41,43,44,45,44,43,41,37,35,33,32,31,30,31,32,33,35,37,41,43,44,45
 dc.b 44,43,41,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,7,5,3,1,0,0,0,0,0,0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,4,6,4,2,0,2,4,6,8,6,4,2,0,2,4,6,8,10,8,6,4,2,0
 dc.b 2,4,6,8,10,12,10,8,6,4,2,0,1,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,28,26,24,23,22,23,24
 dc.b 26,28,30,32,34,36,38,40,42,44,46,48,50
 dc.b 49,48,47,46,44,42,40,38,36,34,32,30,28,26,24,22,20,18,16,14,12,10,8,6,5,4,3,2,1,0
 dc.b $ff
 dcb.l	0,20	;pad out end with 0
	even
sentence:	ds.b	160*9
	even
*******************************
* scroller variables and data *
*******************************
line_ptr:
	dc.l	scroll_line
buffer:	dcb.b	0,BUFFER_SIZE

scroll_line:
 dc.b "            M.S.D. PRESENTS P.O.V. 22.       "
 dc.b "WELL M.S.D. (AS THE ONLY ACTIVE MEMBER OF P.O.V.) "
 dc.b "DOES IT AGAIN TO BRING YOU "
 DC.B "THE ST CONNEXIONS SOUND-TRACKER AND THE OFFICIAL STE DEMO. "
 DC.B "     THE STE DEMO WAS A BOOT-BLOCK LOADER AND IT LOADED IT'S "
 DC.B "DATA USING DMA - IT IS NOW FULLY HACKED AND PACKED INTO FILES!   "
 DC.B "THE CONSTELLATIONS WROTE THE STE DEMO AND USE THE SAME TYPE OF "
 DC.B "LOADER ON THEIR FIRST DEMO SO I SHOULD BE ABLE TO RIP IT APART.... LET'S WAIT AND SEE...    "
 DC.B "WHAT DO YOU THINK OF THE BOUNCY TEXT ABOVE?     NOT BAD EH?      I GOT THE IDEA "
 DC.B "FROM THE AMIGA BUT I HAD SOME MAJOR PROBLEMS CODING IT SO I NEVER RELEASED THE FIRST VERSION. "
 DC.B " THIS IS THE SECOND ATTEMPT AND AS YOU CAN SEE, IT IS BRILLIANT!!    THE ROUTINE "
 DC.B "IS SO WICKED AND FAST THAT I ONLY EXECUTE IT EVERY OTHER VBL, IF I LET IT EXECUTE EVERY "
 DC.B "VBL THEN IT GOES SUPER FAST AND IT'S A BIT HARD ON THE EYES TRYING TO KEEP UP WITH IT.       "
 DC.B "I'VE BEEN TAKING A LITTLE TIME TO TRY SOME NEW IDEAS LATELY WHICH MEANS THAT YOU "
 DC.B "WILL SEE A COUPLE OF NEW MENUS (THIS IS PRETTY NEW).     I THINK I'LL WRITE ANOTHER 2 OR 3 "
 DC.B "AND THEN GET THEM OUT REAL FAST.    I HAVE ENOUGH PACKED DEMOS TO GOTO DISC 27 BUT THEY WON'T "
 DC.B "BE TOTALLY FULL, I THEREFORE PROPOSE TO WRITE A COUPLE OF INTROS TO FILL THE DISCS UP OR I MAY "
 DC.B "INCLUDE A COUPLE OF INTROS FROM THE REPLICANTS (GREAT INTRO CODERS - ESPECIALLY RATBOY).       "
 DC.B "        INFO:  IF YOU HAVE A COPY OF THE 'SWEDISH NEW YEAR DEMO 2' THEN "
 DC.B "READ THE NEXT BIT VERY CAREFULLY..... TURN YOUR ST OFF, PUT THE DISC "
 DC.B "IN THE DRIVE, PRESS AND HOLD THE LEFT SHIFT BUTTON, TURN YOUR ST ON, "
 DC.B "WAIT A WHILE AND THE HIDDEN SCREEN SHOULD APPEAR - IF IT DOESN'T TRY "
 DC.B "IT AGAIN (IT SOMETIMES NEEDS YOUR ST TURNING OFF FOR ABOUT 2 MINUTES BUT "
 DC.B "IT USUALLY WORKS AFTER 2 OR 3 ATTEMPTS).     THE MUSIC ON THIS MENU IS FROM DUGGER AND WAS WRITTEN "
 dc.b "BY JOCHEN HIPPEL (MAD MAX).         "
 DC.B "     IF THIS IS YOUR FIRST P.O.V. DISC THEN GET THE REST 'COS WE'RE THE "
 DC.B "BEST DEMO PACKERS IN THE TRADE.  WE ARE THE GUYS WHO BROUGHT YOU - "
 DC.B "MICROMIX 1 + 2 ON ONE DISC,  ROBOMIX DEMO,  THE POWER DEMO,  MEGABANG 1 + 2,  "
 DC.B "TCB JUNK DEMO,  LEVEL 16 NO BORDER DEMOS,  THE S.U.C.C.E.S.S. DEMO,  TNT DEMOS,  "
 DC.B "ATG DEMO AND MANY, MANY MORE.     IF YOU HAVE AN STE THEN LOOK OUT FOR MORE STE "
 DC.B "ONLY DEMOS COMING SOON......         WELL LYING AROUND MY DESK THERE IS APPROX. "
 DC.B "70 DISCS ALL WAITING TO BE PACKED OR RELEASED, LETS HAVE A LOOK....  ER.. TNT 2, "
 DC.B "YELLO DEMO, SAS DEMO (I SENT THIS TO BORIS FOR POV 7 AND HAVN'T SEEN IT SINCE!), MICROMIX 3, "
 DC.B "TLT DEMO, TNT 1, SHINY BUBBLES, SWEDISH NEW YEAR TWO (WAITING TO BE HACKED!), TCB SOUND-TRACKER "
 DC.B "AND A MASSIVE STACK OF MASTERSOUND DEMOS WHICH ARE BASICALLY UNPACKABLE AND USUALLY TURN OUT "
 DC.B "TO BE 1 MEG PACKS.     THE TROUBLE WITH A LOT OF DEMOS THAT I RECEIVE IS THAT THEY READ FILES "
 DC.B "A BIT AT A TIME WHICH MAKES THEM A PAIN TO PACK, IF YOU WRITE A DEMO AND WANT TO SEE IT PACKED "
 DC.B "THEN MAKE IT A SINGLE PART ONE OR MAKE IT READ THE DATA FILES ALL IN ONE GO.  "
 DC.B " ONCE WRITTEN, SEND IT TO THE DEMO CLUB AND ASK FOR IT TO BE SENT TO ME (MAC SYS DATA).  "
 DC.B "     IF YOU ALREADY HAVE ALL THE POV SERIES EXCEPT 7 (LIKE ME!) THEN DON'T WORRY 'COS DISC "
 DC.B "7 HASN'T BEEN RELEASED (YET - 12/6/90). I SENT THE NEW PICTURE AND THE SAS DEMO TO BORIS "
 DC.B "SOME 4 DAYS AGO, SO HE SHOULD BE WORKING ON IT NOW!   IF HE ISN'T THEN HE WILL IN ABOUT 2 WEEKS "
 DC.B "BECAUSE HE FINISHES UNIVERSITY THEN FOR SUMMER AND IS GOING TO DO SOME MEGA-CODING ON OUR OWN "
 DC.B "DEMO.         HOLD ON........... RIGHT I'VE GOT A GREAT IDEA FOR FUTURE MENUS - COPY AMIGA DEMOS.. "
 DC.B "  YEP, THAT SURE IS A GOOD IDEA EXCEPT I'LL HAVE TO WRITE A LOAD OF NEW CODE AND I HATE WRITING "
 DC.B "NEW STUFF 'COS MY DEVELOPMENT RATE IF RATHER SLOW, I'M NOT SAYING THAT IT IS A SNAILS PACE BUT "
 DC.B "I DEVELOP CODE IN A RATHER STRANGE WAY... FIRST I WRITE NEARLY ALL THE CODE THAT I'LL NEED IN "
 DC.B "SMALL MODULES THEN PUT THEM ALL TOGETHER, AT WHICH POINT NOTHING USUALLY WORKS.   I MESS ABOUT "
 DC.B "WITH THE CODE GUESSING WHAT IS WRONG AND USUALLY MAKE THINGS WORSE, FINALLY I GIVE UP AND GOTO "
 DC.B "THE PUB.  AT THE PUB I OFTEN HAVE BRAIN STORMS AND REALISE WHY IT DOESN'T WORK. NEXT DAY I "
 DC.B "RETURN TO MY STE AND FIX A BIT THEN PONDER ON THE NEXT BUG.... THIS CONTINUES FOR A WEEK OR SO "
 DC.B "UNTIL FINALLY A FINISHED PIECE OF CODE EMERGES FROM MY HARD DISC.   ONE WEEK LATER I WILL "
 DC.B "POSSIBLY RETURN TO THE PIECE OF CODE AND START OPTIMIZING IT FOR SPEED UNTIL I CAN GET IT NO "
 DC.B "FASTER.  IF IT IS STILL TOO SLOW I WILL SCRAP IT AND START AGAIN, THE SECOND OR THIRD ATTEMPT "
 DC.B "IS THE ONE THAT WILL BE RELEASED.      THE OTHER WAY I WRITE IS - GOTO THE PUB, RETURN AND CODE "
 DC.B "UNTIL EARLY IN THE MORNING. THE CODE IS USUALLY PRETTY GOOD AND GOES LIKE HOT SH*T OFF A SHOVEL BUT "
 DC.B "I OFTEN CAN'T WORK OUT HOW THE HELL IT WORKS 'COS I NEVER PUT REMARKS IN THE CODE WHEN I'M PISSED!!! "
 DC.B "         RIGHT, GET PRESSING KEYS AND WHEN YOU'RE BORED WITH THESE THEN DIG OUT YOUR HISOFT/GFA BASIC "
 DC.B "OR DEVPAC/K_SEKA AND GET WRITING A DEMO....        BYE.     "
 DC.B "                                               "
	dc.b	$ff,$ff,$ff,$ff
	even

font:
	incbin	"med_font.dat"
	even
TUNE:	Incbin "dugger.IMG"
pic	incbin	"pov22.PI1"
intro_pic:	incbin	intro.pi1
filenames:
	dc.b	"sonix.MSD",0,0,0,0,0
	dc.b	"ste.MSD",0,0,0,0,0,0,0

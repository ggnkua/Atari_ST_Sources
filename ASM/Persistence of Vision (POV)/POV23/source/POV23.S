***************************
* POV 23                  *
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

	bsr	set_super
wait_for_drive:
	tst.w	$43e
	bne.s	wait_for_drive

	bsr	save_pal
	bsr	hide_cursor
	bsr	get_base
	move.l	#BASE,a0	;screen_base
	clr.w	$ff8264	;STE bit wise shift
	move.w	#$ff00,$ff820e
	bsr	set_low_rez

;************************************************************************
;* Tune driver by MSD of P.O.V - play DUGGER music                      *
;************************************************************************

;************************************************************************
;* Load DUGGER.IMG into TUNE before running                             *
;************************************************************************

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

	move.l	#2,D0	;play different tune
	jsr	$7e000
	bsr	set_for_lower
	bsr	transfer

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
;	move.w	$ffff8240.w,-(sp)
;	move.w	#$070,$ffff8240.w
	bsr	logo
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
	cmp.b	#6,d0		;5 key
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
	bsr	show_cursor
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

************
* sentence *
************
logo:	bsr	clear_sentence
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


	move.l	#BASE+32000+320+160,a0

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

	move.b	#%11110000,d3
	move.b	(a0),d2
	move.b	160(a0),d4
	move.b	320(a0),d5
	move.b	480(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,(a1)
	move.b	d4,160(a1)
	move.b	d5,320(a1)
	move.b	d6,480(a1)
	move.b	640(a0),d2
	move.b	800(a0),d4
	move.b	960(a0),d5
	move.b	1120(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,640(a1)
	move.b	d4,800(a1)
	move.b	d5,960(a1)
	move.b	d6,1120(a1)
	move.b	1280(a0),d2
	move.b	1440(a0),d4
	move.b	1280+320(a0),d5
	move.b	1280+480(a0),d6
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	and.b	d3,d6
	move.b	d2,1280(a1)
	move.b	d4,1280+160(a1)
	move.b	d5,1280+320(a1)
	move.b	d6,1280+480(a1)
	move.b	1280+640(a0),d2
	move.b	1280+800(a0),d4
	move.b	1280+960(a0),d5
	and.b	d3,d2
	and.b	d3,d4
	and.b	d3,d5
	move.b	d2,1280+640(a1)
	move.b	d4,1280+800(a1)
	move.b	d5,1280+960(a1)


	move.l	a3,a1
	clr.w	d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	no_reset_token3
	move.b	(a2)+,d1
no_reset_token3:
	mulu	#160,d1
	add.w	d1,a1

	move.b	#%1111,d3
	move.b	(a0),d2
	and.b	d3,d2
	or.b	d2,(a1)

	move.b	160(a0),d2
	and.b	d3,d2
	or.b	d2,160(a1)

	move.b	320(a0),d2
	and.b	d3,d2
	or.b	d2,320(a1)

	move.b	480(a0),d2
	and.b	d3,d2
	or.b	d2,480(a1)

	move.b	640(a0),d2
	and.b	d3,d2
	or.b	d2,640(a1)

	move.b	800(a0),d2
	and.b	d3,d2
	or.b	d2,800(a1)

	move.b	960(a0),d2
	and.b	d3,d2
	or.b	d2,960(a1)

	move.b	1120(a0),d2
	and.b	d3,d2
	or.b	d2,1120(a1)

	move.b	1280(a0),d2
	and.b	d3,d2
	or.b	d2,1280(a1)

	move.b	1280+160(a0),d2
	and.b	d3,d2
	or.b	d2,1280+160(a1)

	move.b	1280+320(a0),d2
	and.b	d3,d2
	or.b	d2,1280+320(a1)

	move.b	1280+480(a0),d2
	and.b	d3,d2
	or.b	d2,1280+480(a1)

	move.b	1280+640(a0),d2
	and.b	d3,d2
	or.b	d2,1280+640(a1)

	move.b	1280+800(a0),d2
	and.b	d3,d2
	or.b	d2,1280+800(a1)

	move.b	1280+960(a0),d2
	and.b	d3,d2
	or.b	d2,1280+960(a1)


	move.l	a3,a1
	clr.w	d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	no_reset_token2
	move.b	(a2)+,d1
no_reset_token2:
	mulu	#160,d1
	add.w	d1,a1

	move.b	#%11110000,d3
	move.b	1(a0),d2
	and.b	d3,d2
	move.b	d2,1(a1)

	move.b	161(a0),d2
	and.b	d3,d2
	move.b	d2,161(a1)

	move.b	321(a0),d2
	and.b	d3,d2
	move.b	d2,321(a1)

	move.b	481(a0),d2
	and.b	d3,d2
	move.b	d2,481(a1)

	move.b	641(a0),d2
	and.b	d3,d2
	move.b	d2,641(a1)

	move.b	801(a0),d2
	and.b	d3,d2
	move.b	d2,801(a1)

	move.b	961(a0),d2
	and.b	d3,d2
	move.b	d2,961(a1)

	move.b	1121(a0),d2
	and.b	d3,d2
	move.b	d2,1121(a1)

	move.b	1281(a0),d2
	and.b	d3,d2
	move.b	d2,1281(a1)

	move.b	1280+161(a0),d2
	and.b	d3,d2
	move.b	d2,1280+161(a1)

	move.b	1280+321(a0),d2
	and.b	d3,d2
	move.b	d2,1280+321(a1)

	move.b	1280+481(a0),d2
	and.b	d3,d2
	move.b	d2,1280+481(a1)

	move.b	1280+641(a0),d2
	and.b	d3,d2
	move.b	d2,1280+641(a1)

	move.b	1280+801(a0),d2
	and.b	d3,d2
	move.b	d2,1280+801(a1)

	move.b	1280+961(a0),d2
	and.b	d3,d2
	move.b	d2,1280+961(a1)


	move.l	a3,a1
	clr.w	d1
	move.b	(a2)+,d1
	cmp.b	#$ff,d1
	bne.s	no_reset_token4
	move.b	(a2)+,d1
no_reset_token4:
	mulu	#160,d1
	add.w	d1,a1

	move.b	#%1111,d3
	move.b	1(a0),d2
	and.b	d3,d2
	or.b	d2,1(a1)

	move.b	161(a0),d2
	and.b	d3,d2
	or.b	d2,161(a1)

	move.b	321(a0),d2
	and.b	d3,d2
	or.b	d2,321(a1)

	move.b	481(a0),d2
	and.b	d3,d2
	or.b	d2,481(a1)

	move.b	641(a0),d2
	and.b	d3,d2
	or.b	d2,641(a1)

	move.b	801(a0),d2
	and.b	d3,d2
	or.b	d2,801(a1)

	move.b	961(a0),d2
	and.b	d3,d2
	or.b	d2,961(a1)

	move.b	1121(a0),d2
	and.b	d3,d2
	or.b	d2,1121(a1)

	move.b	1281(a0),d2
	and.b	d3,d2
	or.b	d2,1281(a1)

	move.b	1280+161(a0),d2
	and.b	d3,d2
	or.b	d2,1280+161(a1)

	move.b	1280+321(a0),d2
	and.b	d3,d2
	or.b	d2,1280+321(a1)

	move.b	1280+481(a0),d2
	and.b	d3,d2
	or.b	d2,1280+481(a1)

	move.b	1280+641(a0),d2
	and.b	d3,d2
	or.b	d2,1280+641(a1)

	move.b	1280+801(a0),d2
	and.b	d3,d2
	or.b	d2,1280+801(a1)

	move.b	1280+961(a0),d2
	and.b	d3,d2
	or.b	d2,1280+961(a1)

	move.l	a3,a1
	add.w	#8,a1
	add.w	#8,a0
	dbf	d0,logo_print
	add.l	#1,pos
	rts

clear_sentence:
	move.l	#BASE+160*90,a0
	clr.w	d1
	move.w	#65-1,d0
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
	tst.w	delay
	beq.s	carry_on
	sub.w	#1,delay
	rts
carry_on:
	move.l	line_ptr,a6
	cmp.b	#$7f,(a6)
	bne.s	no_delay
	add.l	#1,line_ptr
	move.w	#320,delay
	rts
delay:	dc.w	0
no_delay:
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

loop2:	move.l	#BASE+32000+320,a6
	move.l	a6,a2
	add.w	#152,a2

	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#16-1,d1
loop:	roxl.w	(a1)
	move.w	(a1)+,d0
	and.w	#1,d0
	or.w	d0,(a2)
	add.w	#160,a2
	dbf	d1,loop

	add.w	#160,a6
	move.w	#15-1,d0
loopy:	roxl.w	152(a6)
	roxl.w	144(a6)
	roxl.w	136(a6)
	roxl.w	128(a6)
	roxl.w	120(a6)
	roxl.w	112(a6)
	roxl.w	104(a6)
	roxl.w	96(a6)
	roxl.w	88(a6)
	roxl.w	80(a6)
	roxl.w	72(a6)
	roxl.w	64(a6)
	roxl.w	56(a6)
	roxl.w	48(a6)
	roxl.w	40(a6)
	roxl.w	32(a6)
	roxl.w	24(a6)
	roxl.w	16(a6)
	roxl.w	8(a6)
	move.w	(a6),d7
	and.w	#$3fff,d7
	roxl.w	#1,d7
	move.w	d7,(a6)
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

	move.l	pic+2,$ffff8240.w
	move.l	pic+6,$ffff8244.w
	move.l	pic+10,$ffff8248.w
	move.l	pic+14,$ffff824c.w
	move.l	pic+18,$ffff8250.w
	move.l	pic+22,$ffff8254.w
	move.l	pic+26,$ffff8258.w
	move.l	pic+30,$ffff825c.w

	move.b	#98,counter		;set up border count down

	move.l	#horiz_isr,$120.W
	clr.w	horiz_sync

	move.l	#colours,pal_pos
	movem.l	D0-D7/A0-A6,-(sp)	;tune isr
	jsr	$7E012
	movem.l	(sp)+,D0-D7/A0-A6

	BSR	vu
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.B	#3,$FFFFFA21.W
	rte

horiz_isr:
	move.b	#2,$fffffa21.w	;do it every 2 lines
	move.l	#go_border,$120.w ;border. (at the start of a refresh)
	rte

go_border:
	subq.b	#1,counter
	beq.s	extended_scan

	move.l	a0,-(sp)
	move.l	pal_pos,a0
	move.w	196(a0),$ffff8240.w
	move.w	(a0)+,$ffff8242.w
	move.l	a0,pal_pos
	move.l	(sp)+,a0
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

	clr.w	$ffff8240.w
	move.w	#$040,$ffff8248.w	;middle vu
	move.w	#$020,$ffff8250.w	;bottom vu

	MOVE.L	#in_the_border,$120.W
	rte

in_the_border:
	clr.b	$fffa1b		;DI all other interrupts
	move.w	#$070,$ffff8244.w	;top VU colour
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#18-1,d0	;colour the bottom scroller
col_loop:
	move.w	(a0)+,$ffff8242.w

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
	move.b	#$8,$ff8800
	move.b	$ff8800,d7
	cmp.b	#15,d7
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
	dc.w	$0,$0
	dc.w	$022,$022,$023,$034,$045,$056,$067,$067
	dc.w	$067,$056,$045,$034,$023,$022,$022,$000
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

******************************
* letters variables and data *
******************************
reset_detect:	dc.w	0
pos:	dc.l	init_table
init_table:
	dcb.l	0,20
table:
 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,11,11,12,12,13,13,14,14,15,15
 dc.b 16,16,17,17,18,18,19,20,21,22,23,24,25,26,27,28,29,30,32,34,36,38,40,42,45,48,50,48,45,42,40,38,36,34,32,30
 dc.b 28,26,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
 dc.b 23,22,21,20,19,18,17,15,13,11,10,9,8,7,7,7,8,9,10,11,13,15,17,19,21,23,25,27,29,31,33,35,36,37,38,39,40,40,40,39,37,35,33,31,29,27,25
 dc.b 23,21,19,17,15,13,11,10,9,8,7,7,7,8,9,10,11,13,15,17,19,21,23,25,27,29,31,33,35,36,37,38,39,40,40,40,39,37,35,33,31,29,27,25
 dc.b 23,21,19,17,15,13,11,10,9,8,7,7,7,8,9,10,11,13,15,17,19,21,23,25,27,29,31,33,35,36,37,38,39,40,40,40,39,37,35,33,31,29,27,25
 dc.b 23,21,19,17,15,13,11,10,9,8,7,7,7,8,9,10,11,13,15,17,19,21,23,25,27,29,31,33,35,36,37,38,39,40,40,40,39,37,35,33,31,29,27,25
 dc.b 23,21,19,17,15,13,11,10,9,8,7,7,7,8,9,10,11,13,15,17,19,21,23,25,27,29,31,33,35,36,37,38,39,40,40,40,39,37,35,33,31,29,27,25
 dc.b 23,21,19,17,15,13,11,10,9,8,7,7,7,8,9,10,11,13,15,17,19,21,23,25,27,29,31,33,35,36,37,38,39,40,40,40,39,37,35,33,31,29,27,25
 dcb.b 24,80
 DC.B 25,25,25,25,26,26,27,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50
 dc.b 49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

 dc.b 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50
 dc.b 49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,47,48,48,49,49,49,50,50,50
 dc.b 49,49,49,48,48,47,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,47,48,48,49,49,49,50,50,50
 dc.b 49,49,49,48,48,47,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,47,48,48,49,49,49,50,50,50
 dc.b 49,49,49,48,48,47,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,47,48,48,49,49,49,50,50,50
 dc.b 49,49,49,48,48,47,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,3,2,2,1,1,0,0,0,0,0

 dc.b 0,0,0,0,0,0,0,1,2,3,4,5,7,9,11,13,15,17,19,21,23,25,27,29,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,50,50,50,50,50,50,50,50,50,49,49,49,49,49,49
 dc.b 48,48,48,48,47,47,47,47,46,46,46,45,45,45,44,44,43,42,41,40,38,36,34,32,29,26,23,20,16,12,8,4,0,0,0,0,0,0,2,4,6,8,10,12,14,16,18,20,22,24,24,24,24,24,24,24,24,24
 dc.b 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,23,22,21,20,18,16,14,13,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12,12
 dc.b 11,11,12,12,13,14,16,18,20,22,24,26,28,30,32,34,36,37,38,39,39,40,40,39,39,38,37,36,34,32,30,28,26,24,22,20,18,16,14,13,12
 dc.b 10,8,6,4,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,5,6,7,8,9,10,12,14,16,18,21,24,27,31,35,39,44,50,50,50,50,50,50,50,50,50,50,50
 dc.b 50,50,50,50,50,50,49,48,47,46,45,44,44,43,43,43,42,42,42,42,42,42,43,43,44,44,45,46,47,48,49,50,50,50,50
 dc.b 49,48,47,45,43,41,38,36,35,34,33,32,32,31,31,31,30,30,30,30,30,31,31,31,32,32,33,34,35,36,38,41,43,45,47,48,49,49,50,50,50,50,50
 dc.b 50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,49,48,47,46,45,44,43,42,41,40,41,42,43,44,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30
 dc.b 31,32,33,34,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,21,22,23,24,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,11,12,13,14,15,14,13,12,11,10
 dc.b 9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,4,3,2,1,0,0,0,0,0

 dc.b $ff

 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0
 dc.b 0,1,1,2,2,3,3,4,5,6,7,8,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,48,48,49,49,50,50
 dc.b 50,49,49,48,48,47,45,43,41,39,37,35,33,31,29,27,25,23,21,19,17,15,13,11,9,8,7,6,5,4,3,3,2,2,1,1,0,0

	even
pal_pos:	dc.l	colours
colours:
 dc.w $760,$760,$760,$760,$760,$760,$760,$760
 dc.w $760,$760,$760,$760,$760,$760,$760,$760
 dc.w $760,$760,$760,$760,$760,$760,$760,$760
 dc.w $760,$760,$760,$760,$760,$760,$760,$760
 dc.w $760,$760,$760,$760,$760,$760,$760,$760
 dc.w $760,$760

 dc.w	$100,$200,$300,$400,$500,$600,$700,$710
 dc.w	$720,$730,$740,$750,$760,$770,$671,$572
 dc.w	$473,$374,$275,$176,$077,$167,$257,$347
 dc.w	$437,$527,$617,$707,$706,$605,$504,$403
 dc.w	$302,$201,$110
 dc.w	$760,$760,$070,$070,$070,$070,$070,$070
 dc.w	$070,$070,$070,$070,$070,$070,$070,$070
 dc.w	$070,$070,$070,$070

colors2:
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000


 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 dc.w 0,0,$000
 dc.w	$111,$111,$111,$111,$111,$111,$111,$111
 dc.w	$111,$111,$111,$111,$111,$111,$111,$111
 dc.w	$111,$111,$111,$111,$000


*******************************
* scroller variables and data *
*******************************
line_ptr:
	dc.l	scroll_line
buffer:	dcb.b	0,BUFFER_SIZE

scroll_line:
 dc.b " MAC SYS DATA    ",$7f," PRESENTS         P.O.V. DISC 23   ",$7f
 dc.b "  ALL CODING/GRAPHIX/PACKS BY M.S.D.         MUSIC IS FROM DUGGER AND WAS WRITTEN BY JOCHEN HIPPEL (MAD MAX).     "
 DC.B "HELLO TO -    THE REPLICANTS,   AUTOMATION,   SLIPSTREAM,   THE DEMO CLUB,   "
 DC.B "VISION FACTORY,   DPS,   ABE,   STEWART,   DR.SYNE,   BORIS,   ALY,   THE LOST BOYS,   "
 DC.B "TCB,   ST-SQUAD,   THE MEDWAY BOYS,   POMPEY PIRATES,   THE UNION,   SEWER SOFTWARE   AND   "
 DC.B "ANY OTHER MAJOR CREW I'VE MISSED.                WELL WHAT DO YOU THINK OF THIS NEW 'SINUS' "
 DC.B "SCROLLER?        I GOT THE IDEA FROM SLIPSTREAM ON THE AMIGA, IT CHANGES THE HEIGHT OF THE TEXT "
 DC.B "EVERY 4 PIXELS (A NIBBLE) AND IS DISPLAYED IN 1 PLANE. "
 DC.B "I THINK I COULD MAKE IT FASTER AND ALSO MAKE IT RUN IN 4 PLANES.        THE MENU WAS WRITTEN "
 DC.B "ON 16-6-90, I EXPECT THE SCROLL ROUTINE WILL APPEAR ON OTHER CREWS MENUS PRETTY SOON AS EVERYONE "
 DC.B "STEALS FROM EACH OTHER (DID YOU HEAR THAT OBERJE?)    IF YOU'RE INTO PROGRAMMING THEN GET A LOAD OF THIS..."
 DC.B " I WROTE A VERSION OF THIS SINE SCROLL THAT CHANGED THE WAVEFORM EVERY 2 PIXELS, THE EFFECT IS EXCELLENT BUT IT "
 DC.B "TAKES A LOT OF PROCESSOR TIME...    THE RESULT WAS A SLIGHT CLIPPING ON THE RIGHT HAND SIDE OF THE SCREEN WHERE "
 DC.B "THE RASTER WAS OVER RUNNING THE SCROLL.  IF I RE-WRITE THE CRAPPY ROXL SCROLL ROUTINE AND OPTIMISE THE SINE ROUTINE "
 DC.B "THEN I MAY BE ABLE TO USE IT ON A FUTURE DISC (I'D ALSO HAVE TO GET A DIFFERENT TUNE AS THIS ONE TAKES UP LOADS OF "
 DC.B "CYCLES!) - IF YOU'RE NOT INTO PROGRAMMING THEN YOU PROBABLY WON'T HAVE UNDERSTOOD A WORD SO THERE IS ONLY ONE ANSWER - "
 DC.B "LEARN 68000 ASSEMBLY LANGUAGE NOW.              I'VE JUST PLAYED LEAVIN TERAMIS BY SOME FOREIGN CREW (WHO ALSO WRITE "
 DC.B "DEMOS) AND I THOUGHT I RECOGNIZED THE STYLE OF THE TUNE, IT WAS WRITTEN BY MAD MAX AND IS PRETTY GOOD.     IF YOU'RE "
 DC.B "CAN HACK FILES, THEN DEPACK THIS ONE AND LOOK THROUGH THE CODE UNTIL YOU FIND THE TUNE 'COS IT'S GOT A CONTACT "
 DC.B "PHONE NUMBER FOR MAD MAX (WELL HIS BOSS'S PHONE NUMBER).              "
 DC.B "THIS IS MY 22ND DISC IN 8 MONTHS - NOT BAD SEEING I ONLY SUSSED OUT HOW TO PACK DATA FILES SOME 6 MONTHS AGO.   P.O.V. "
 DC.B "HAS BEEN GOING FOR JUST OVER 12 MONTHS, THE FIRST DISC WAS RELEASED WHEN AUTOMATION WERE ON DISC 48 (I SHOULD KNOW 'COS "
 DC.B "I RIPPED THE TUNE OUT OF IT).     I DIDN'T HAVE A HALF DECENT PACKER IN THOSE DAYS BUT I SURVIVED ON ONE THAT I HAD WRITTEN (LET "
 DC.B "IT REST IN PEACE!).      ONE I GOT THE JON PACKER, I WAS OFF.  A QUICK BIT OF CODE RIPPING AND THERE YOU HAVE IT, A DATA FILE "
 DC.B "DEPACKER... THING WAS THAT I DIDN'T KNOW HOW TO INTERCEPT THE LOAD ROUTINE IN THOSE DAYS SO I WAS BUGGERED.    BUT ONE DAY IT CAME "
 DC.B "TO ME IN A FLASH WHEN I WAS READING THE 'CONCISE 68000 REFERENCE MANUAL' AND THE NEXT DAY -  WHAM!!  IT WAS DONE.     I HAD A FEW "
 DC.B "PROBLEMS TRYING TO WORK OUT THE STACK VALUES BUT I MADE IT IN THE END.   I USED THAT ROUTINE UNTIL RECENTLY WHEN I RECEIVED A COPY "
 DC.B "OF THE 2.3R PACKER, SO I RIPPED A DEPACK ROUTINE FROM WAS (NOT WAS) AND BOLTED IT INTO MY LOAD INTERCEPTION ROUTINE AND AFTER 2 "
 DC.B "REVISIONS HERE IT IS.    IN THE OLD DAYS I USED TO LOAD DEMOS USING A CRAPPY ROUTINE HELD WITHIN THE MENU UNTIL BORIS HAD AN IDEA "
 DC.B "OF USING A REMOTE LOADER, I QUICKLY RATTLED UP A PIECE OF CODE TO DO THE TRICK AND THE 'AUTO-RUN' METHOD WAS MADE - THIS FIRST "
 DC.B "APPEARED ON DISC 15.     ONE HEADACHE I USED TO HAVE WAS THAT SOME DEMOS WOULD NOT RUN IN HALF A MEG WHEN THE MENU EXECUTED THEM. "
 DC.B "THE REASON BEING THAT GEM IS A BASTARD FOR NOT RELEASING MEMORY WHEN YOU TELL IT TO HOWEVER, USING THE AUTO-RUN METHOD I RARELY "
 DC.B "HAVE ANY PROBLEMS.         OH YES, I THOUGHT I'D JUST TELL YOU THAT THESE DISCS ARE A HOBBY. I HAVE A FULL TIME JOB WORKING AS "
 DC.B "A DATA COMMUNICATIONS ENGINEER (I INSTALL ETHERNET EQUIPMENT (DECSERVERS, ETC.), TERMINALS, PRINTERS, MODEMS, FIBRE OPTIC REPEATERS/BRIDGES, "
 DC.B "MULTIPLEXORS AND A WHOLE HOST OF OTHER BITS AND BOBS, I ALSO GET THE COMMS SOFTWARE GOING ON PC'S BECAUSE ALL THE SOFTWARE BOYS WHERE I "
 DC.B "WORK ARE A BUNCH OF WANKERS AND KNOW NOTHING (AND TO THINK, THEY TURNED ME DOWN WHEN I APPLIED TO BE A PROGRAMMER - WHAT A LOAD "
 DC.B "OF LOSERS).         ARE THERE ANY BIKERS OUT THERE?     YES?     ARE ANY OF YOU FEMALE?     WOULD YOU LIKE TO MEET A MALE BIKER WHO "
 DC.B "RUNS ABOUT ON A Z650 (WITH MANY MODIFICATIONS)?      WHAT DO YOU MEAN NO?      LOOK, I MAY NOT BE THE MOST HANDSOME HUNK AROUND BUT "
 DC.B "MY BIKE GOES LIKE A ROCKET ONCE IT HITS 7000 RPM!      IF YOU LIVE IN THE BLACKPOOL AREA, THEN LOOK OUT FOR A VERY NOISY GREEN Z650 "
 DC.B "FLYING AROUND ON SATURDAYS 'COS IT'LL BE ME! (DON'T TRY AND STOP ME 'COS I NEARLY KILLED 3 OLD WOMEN WHO DID THAT NEAR THE BUS "
 DC.B "STATION ONE DAY!) HE-HE.         WHAT DO YOU CALL A VOLVO DRIVER WHO PULLS STRAIGHT OUT IN FRONT OF YOU WHEN YOU'RE ON YOUR BIKE?     "
 DC.B "YOU CAN CALL HIM ANYTHING 'COS ALL VOLVO DRIVERS ARE IGNORANT BASTARD WHO DON'T GIVE A SHIT WHAT THEY DO.  (QUITE A FEW HAVE GOT "
 DC.B "LARGE DINTS IN THEIR DRIVERS SIDE DOORS WHERE I KICKED THEM WHENEVER THEY PULL OUT ON ME - GOD I HATE DRIVERS WHO DON'T LOOK.)     THERE "
 DC.B "ARE OTHER DRIVERS WHO DESERVE TO DIE, THEY'RE THE ONES WHO GET READY TO PULL OUT FROM A GARAGE AND EVEN THOUGH THERE IS A HUGE GAP "
 DC.B "IN THE TRAFFIC BETWEEN THE CAR IN FRONT AND ME, THEY ALWAYS WAIT UNTIL I'M ABOUT 20 METERS AWAY UNTIL THEY PULL OUT.... AND WHENEVER "
 DC.B "THAT HAPPENS I PULL UP ALONG SIDE AND GIVE THEM THE TWO FINGER TREATMENT! (AND I DON'T MEAN THE VICTORY SIGN!).         "
 DC.B "WELL I THINK I'VE WAFFLED ON FOR FAR TOO SERIOUSLY LONG BY HALF, SO I'LL SAY BYE AND SEE YOU ON DISC 24 "
 DC.B ".................."
 DC.B "                                               "
	dc.b	$ff,$ff,$ff,$ff
	even

font:
	incbin	"med_font.dat"
	even
TUNE:	Incbin	"dugger.IMG"
pic	incbin	"pov23.PI1"
filenames:
	dc.b	"TRACKER.TCB",0,0,0
	dc.b	"MICROMIX.003",0,0
	dc.b	"TLT_DEMO.MSD",0,0
	dc.b	"YELLO.DEM",0,0,0,0,0

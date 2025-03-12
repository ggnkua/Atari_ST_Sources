***************************
* POV 14                  *
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

	bsr	hide_cursor
	bsr	save_pal
	bsr	set_palette
	bsr	get_base
	move.l	#BASE,a0	;screen_base
	bsr	set_low_rez

;set up for no botton border
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

	lea	pov,a0
	move.l	#BASE,a1
	add.w	#32000,a1
	move.w	#43-1,d0
.loop:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.loop

;init tune
;*******************************************
;* There is more than one tune here.....
;* 1=AUTOMATION 51
;* 2=TUNE 2
	move.w	#1,c2

	move.w	#2,d1
lo:	move.w	#65000,d0
halt:	nop
	dbf	d0,halt
	dbf	d1,lo

	bsr	transfer

;initialise system scroller
	lea	scroll_line,a0
	move.l	a0,line_ptr

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
;	move.w	$ffff8240.w,-(sp)
;	move.w	#$070,$ffff8240.w
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
	blt.s	main_loop
	cmp.b	#5,d0		;4 key
	bge.s	main_loop	

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
	move.l	#0,-(sp)
	pea	laddr
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	bsr	set_super
	move.w	#$123,$ffff8240.w
pop:	add.w	#1,$ffff8240.w
	nop
	nop
	bra.s	pop
exit:
	bsr	isr_off

;reset rez
	move.l	old_base,a0
	bsr	set_med_rez
	bsr	set_low_rez

	bsr	restore_pal

	bsr	show_cursor
	
	bsr	user_mode

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

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


vert_isr:
	CLR.B	$FFFF8260.W
	MOVEM.L	D0-d7,-(A7)

	MOVEM.L	pic+2(PC),d0-d7
	MOVEM.L	d0-d7,$FFFF8240.W

	MOVEM.L	(A7)+,D0-d7
	MOVE.B	#49,counter	;49/50 of a second

	MOVE.L	#horiz_isr,$120.W
	clr.w	horiz_sync
	bsr	tuneisr
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
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	CLR.B	$FFFF820A.W
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
 	nop
	nop
	nop
	nop
	MOVE.B	#2,$FFFF820A.W
f1:	MOVE.L	#L3DBD0,$120.W
	rte

L3DBD0	;move.b	#0,$ffff8260.w	;set rez (can be changed to get a med rez scroller)
	clr.b	$fffa1b
	movem.l	d0/a0,-(sp)
	lea	pal_table,a0
	move.w	#40-1,d0
col_loop:
	move.w	22(a0),$ff8244
	move.w	(a0)+,$ff8242
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;10
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;20
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;30
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;40
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;50
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;60
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;70
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;80
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;90
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;100
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	;110
	nop
	nop
	nop
	nop
	dbf	d0,col_loop
	movem.l	(sp)+,d0/a0
	bclr	#0,$fffa0f
	rte
pal_table:
	dc.w	$430,$340,$250
	dc.w	$160,$071,$062,$053,$044,$035,$026,$017
	dc.w	$106,$205,$304,$403,$502,$601,$700,$710
	dc.w	$720,$730,$740,$750,$760,$770,$671,$572
	dc.w	$473,$374,$275,$176,$077,$177,$277,$377
	dc.w	$477,$577,$677,$766,$755

stack_save:	dc.l	0
old70:	dc.l	0
old120:	dc.l	0
olda07:	dc.l	0
olda09:	dc.b	0
olda17:	dc.b	0
olda1b:	dc.b	0
olda21:	dc.b	0
	even
horiz_sync:	dc.w	0
old_base:	dc.l	0
counter:	dc.w	0


; ISR to animate the VU METER
vu:	movem.l	d5-d7/a3-a6,-(sp)
	move.b	#$8,$ff8800	;chan A
	move.b	$ff8800,d7
	move.l	#BASE,a6	;screen always in A6
	add.w	#160*184,a6
	bsr.s	METER
	move.b	#$9,$ff8800	;chan B
	move.b	$ff8800,d7
	add.w	#160*5,a6
	bsr.s	METER
	move.b	#$a,$ff8800	;chan C
	move.b	$ff8800,d7
	add.w	#160*5,a6

;flash the disc drive light
	cmp.b	#14,d7
	blt.s	no_flash
	move.b	#14,$ff8800
	bclr	#1,$ff8802
	bra.s	do_meter
no_flash:
	move.b	#14,$ff8800
	or.b	#%00000010,$ff8802
do_meter:

	bsr.s	METER
	movem.l	(sp)+,d5-d7/a3-a6
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
	add.l	#32000+160+160,a6
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

	move.w	#38-1,d0
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
	move.w	#8-1,d7
rows:	move.w	#23-1,d6
columns:
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	move.l	16(a0),16(a1)
	move.l	20(a0),20(a1)
	move.l	24(a0),24(a1)
	move.l	28(a0),28(a1)
	move.l	32(a0),32(a1)
	move.l	36(a0),36(a1)
	move.l	40(a0),40(a1)
	move.l	44(a0),44(a1)
	move.l	48(a0),48(a1)
	move.l	52(a0),52(a1)
	move.l	56(a0),56(a1)
	move.l	60(a0),60(a1)
	move.l	64(a0),64(a1)
	move.l	68(a0),68(a1)
	move.l	72(a0),72(a1)
	move.l	76(a0),76(a1)
	move.l	80(a0),80(a1)
	move.l	84(a0),84(a1)
	move.l	88(a0),88(a1)
	move.l	92(a0),92(a1)
	move.l	96(a0),96(a1)
	move.l	100(a0),100(a1)
	move.l	104(a0),104(a1)
	move.l	108(a0),108(a1)
	move.l	112(a0),112(a1)
	move.l	116(a0),116(a1)
	move.l	120(a0),120(a1)
	move.l	124(a0),124(a1)
	move.l	128(a0),128(a1)
	move.l	132(a0),132(a1)
	move.l	136(a0),136(a1)
	move.l	140(a0),140(a1)
	move.l	144(a0),144(a1)
	move.l	148(a0),148(a1)
	move.l	152(a0),152(a1)
	move.l	156(a0),156(a1)
	add.w	#160*8,a0
	add.w	#160*8,a1
	bsr	pause
	dbra	d6,columns
	sub.w	#23*160*8,a0
	sub.w	#23*160*8,a1
	add.w	#160,a1
	add.w	#160,a0
	dbf	d7,rows
	rts

pause:	move.w	d0,-(sp)
	move.w	#1000,d0
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

	ds.l	40
tuneisr:
	movem.l	d0-d7/a0-a6,-(sp)
	addq.w	#1,c1
	tst.w	c2
	beq.s	skip
	bmi	spook
	move.w	d0,-(sp)
	move.w	c2,d0
	subq.w	#1,d0
	jsr	TUNE
	move.w	(sp)+,d0
	bra	top
spook:	jsr	TUNE+$1c
top:	clr.w	c2
skip:	tst.w	c3
	beq.s	nomore
	move.w	d0,-(sp)
	move.w	c3,d0
	jsr	TUNE+$2a
	move.w	(sp)+,d0
	clr.w	c3
nomore:	jsr	TUNE+$e
	movem.l	(sp)+,d0-d7/a0-a6
	rts
c1:	dc.w	0
c2:	dc.w	0
c3:	dc.b	0	;laser if <>0
c4:	dc.b	0	;other sounds!

;C4:
; 1=laser			b=fire2
; 2=a hit low			c=hit
; 3=a hit high			d=collect item
; 4=warble			e=thug
; 5=whoop 1			f=blurble
; 6=whoop 2			10=hit
; 7=laser 2			11=hit
; 8=blurp!!			12=fart
; 9=white noise			13=hit
; a=fire1			14+=whishy washy

TUNE:	Incbin "WAS51.IMG"
pic	incbin	"pov14.PI1"
pov:	include "copyb1.s"
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
	dc.w	$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fefe,$fefe

vu2:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$007f
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
	dc.w	$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f

toggle:	dc.w	0	;50 hertz
scroll_number:	dc.w	16
old_pal:	ds.b	32
line_ptr:
	dc.l	scroll_line
buffer:	dcb.b	0,BUFFER_SIZE

scroll_line:
 dc.b "   WELCOME TO POV 14.        CREDITS:   MENU CODED BY MAC SYS DATA,    GRAFIX BY MAC SYS DATA (I GOT THE ALF PIC FROM A PD LIBRARY),  "
 dc.b "    THE MUSIC IS FROM BEYOND THE ICE PALACE.          MEMBERS OF P.O.V. ARE ;-     "
 dc.b "MAC SYS DATA,    BORIS,    DR.SYNE    AND ALY.            "
 dc.b "HI TO;-    ALAN R,  GEORGE,  BASHER,  VAPOUR,  NIEL OF COR BLIMEY AND THE LOST BOYS.       "
 DC.B "       IF YOU WISH TO CONTACT US THEN GET ONTO THE "
 DC.B "NATIONAL 'JANET' SYSTEM AVAILABLE AT POLYTECHNICS, UNIVERSITIES AND ON MICROLINK, THE USER ID IS ;-     MOFFAT-AS  (THE MINUS IS MEANT TO BE AN UNDERSCORE)    THE SITE;-   "
 DC.B "LANCS P.P2.       THE MESSAGE WILL BE PASSED ON BY ALY AT LANCASHIRE POLY (IN PRESTON).           IF YOU WISH TO COLLECT MORE PERSISTENCE "
 DC.B "OF VISION DISCS, THEY ARE AVAILABLE DIRECTLY FROM THE BLACKPOOL CLUB OR KEEP AN EYE ON THE PD LIBRARIES BECAUSE WE ARE ABOUT TO DISTRIBUTE THROUGH PD.        "
 DC.B "BYEEEEEEE..................                  LOOK OUT FOR P.O.V. 7 COMING SOON!             PLEASE NOTE, DUE TO RESTRICTED ACCESS TO A 1/2 MEG "
 dc.b "MACHINE, I WAS UNABLE TO TEST SOME DISCS. AS A RESULT SOME DISCS WERE RELEASED WITH DEMOS THAT WOULD NOT RUN ON SOME MACHINES, I HAVE NOW FIXED "
 dc.b "MOST OF THE DISCS OR INDICATED WHICH FILES WILL NOT RUN IN 1/2 MEG. PLEASE COPY THE NEW VERSIONS OF THE FOLLOWING DISCS --- P.O.V. DISCS   6, "
 dc.b "10 AND 12. DISC 13 HAS BEEN RE-DONE TO REMOVE THE SLIGHT GLITCH THAT APPEARED ON A 1/2 MEG ST (I DOUBT ANYBODY ACTUALLY GOT HOLD OF IT UNLESS YOU "
 DC.B "KNOW MAC SYS DATA OR DR.SYNE BECAUSE THEY WERE THE ONLY PEOPLE WITH COPIES).   IS THAT CLEAR?            YES?          RIGHT, TIME TO WRAP.       "
 DC.B "                                               "
	dc.b	$ff,$ff,$ff,$ff
	even

font:
	incbin	"med_font.dat"
	even
filenames:
	dc.b	"SCARLET.MSD",0,0,0
	dc.b	"GB.MSD",0,0,0,0,0,0,0,0
	dc.b	"bap.",0,0,0,0,0,0,0,0,0,0
laddr:	dc.l	0

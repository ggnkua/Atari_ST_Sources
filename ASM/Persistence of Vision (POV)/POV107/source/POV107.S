*************************************************************************
*			P.O.V. 107 menu					*
*			---------------					*
*									*
* Written by MAC SYS DATA						*
*									*
*									*
* Music the CHARTS 6 by LAP (tune #28)					*
*									*
*************************************************************************
	OPT	o+,w-

BUFFER_SIZE	EQU	16*8
WIDTH		EQU	10
FINAL		equ	0	;0=in assembler 1=final menu for disc

	bsr	set_super
	move.b	#$12,$fffffc02.w
	or.b	#2,$ffff820a.w	;50Hz
	move.b	$484.w,old484
	clr.b	$484.w

	lea	bss_start,a0
clr	clr.l	(a0)+
	cmp.l	#stopper,a0
	blt.s	clr

	bsr	get_screen_base
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_palette
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	ifeq	FINAL
	bsr	get_original_rez
	bsr	set_low_rez
	ENDC
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,screen_base
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)

	bsr	intro
	bsr	show_pic

;
; Next Charts #6, Music by LAP - Hacked by MUG U.K
;


	moveq.l	#1,d0
	jsr	tune
	bsr	save_isr


main_loop
	clr.w	vsync_flag
wai	tst.w	vsync_flag
	beq.s	wai

;	move.w	#$700,$ffff8244.w
	bsr	clear_spec
	jsr	tune+$22
	bsr	calc_spec
	bsr	scroll
	bsr	scroll
	bsr	barrel
;	move.w	pic+2,$ffff8244.w

	move.w	key,d0

	ifeq	FINAL
	cmp.b	#1,d0			;escape
	beq	exit
	ENDC

	cmp.b	#$b,d0		;0 key
	beq	zero

	cmp.b	#$70,d0		;0 keypad
	beq	zero
no_hertz_change

	cmp.w	#$c53,d0
	beq	reset

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

	bsr	reset_isr

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
hz50	move.b	old484,$484.w
	movem.l	old_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	set_low_rez
	move.b	#8,$fffffc02.w
	bsr	set_user
	clr.w	-(sp)
	trap	#1


	ifeq	FINAL
exit	bsr	reset_isr
	movem.l	old_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	set_med_rez
	move.b	#8,$fffffc02.w
	bsr	set_user
	clr.w	-(sp)
	TRAP	#1
	ENDC


zero	tst.w	zero_counter
	bne	no_hertz_change
	eor.w	#$002,border_hz+2
	move.w	#10,zero_counter
	eor.w	#-1,hertz_toggle
	bra	main_loop

reset	move.l	4.w,-(sp)
	rts

*******************
* CUSTOM ROUTINES *
*******************
scroll	move.l	line_ptr,a0	;need a new letter?
	cmp.b	#$ff,(a0)
	bne.s	loop3
	lea	scroll_line,a0	;restart message
	move.l	a0,line_ptr
loop3:	tst.w	scroll_number
	bne.s	loop2
	move.w	#WIDTH,scroll_number
	moveq.l	#0,d0
	move.l	d0,d1
	move.b	(a0)+,d0
	move.l	a0,line_ptr
	sub.w	#32,d0
	mulu	#15*2,d0	;15 by 2 bytes
	lea	font,a0
	add.w	d0,a0	;letter address is in A0
;transfer letter into buffer
	lea	buffer,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0),(a1)

loop2	move.l	screen_base,a0
	add.w	#(160*10),a0
	move.l	a0,a2
	add.w	#152,a2
	lea	buffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	sub	d0,d0		;clear carry to stop crap appearing at top of scroller
	REPT	16
	roxl.w	(a1)
	move.w	(a1)+,d0
	and.w	#1,d0
	or.w	d0,(a2)
	lea	160(a2),a2
	ENDR

	sub	d0,d0		;clear carry to stop crap appearing at top of scroller
	move.w	#16-1,d0
loopy:	roxl.w	152(a0)
	roxl.w	144(a0)
	roxl.w	136(a0)
	roxl.w	128(a0)
	roxl.w	120(a0)
	roxl.w	112(a0)
	roxl.w	104(a0)
	roxl.w	96(a0)
	roxl.w	88(a0)
	roxl.w	80(a0)
	roxl.w	72(a0)
	roxl.w	64(a0)
	roxl.w	56(a0)
	roxl.w	48(a0)
	roxl.w	40(a0)
	roxl.w	32(a0)
	roxl.w	24(a0)
	roxl.w	16(a0)
	roxl.w	8(a0)
	move.w	(a0),d7
	and.w	#$7fff,d7
	roxl.w	#1,d7
	move.w	d7,(a0)
	add.w	#160,a0
	dbf	d0,loopy
	subq.w	#1,scroll_number

	move.l	screen_base,a0
	lea	160*11(a0),a0
	move.l	a0,a1
	add.l	#32002+160*25,a1
	move.w	#15-1,d0
OFFSET	set 0
.loop
	REPT	20
	move.w	OFFSET(a0),OFFSET(a1)
OFFSET	set OFFSET+8
	ENDR
	lea	160(a0),a0
	lea	160(a1),a1
	dbf	d0,.loop
	rts


barrel	moveq	#0,d0
	move.l	barrel_offset_pos,a0
	move.w	(a0)+,d0
	bpl.s	.no_reset
	lea	barrel_offset,a0
	move.w	(a0)+,d0
.no_reset
	move.l	a0,barrel_offset_pos
	
	lea	barrel_grafic,a0
	add.w	d0,a0

	lea	barrel_rotate,a2
	move.l	screen_base,a1
	add.w	#160*60+112,a1
	move.w	#35-1,d0
.loop	move.w	(a2)+,d2
	add.w	d2,a0
	movem.l	(a0),d1-d7/a3/a4/a5
	movem.l	d1-d7/a3-a5,(a1)
	movem.l	d1-d7/a3-a5,160(a1)
	lea	320(a1),a1
	dbf	d0,.loop
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
	add.l	#160*214+(160*16),a1
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
.next	dbf	d0,.cnt_down

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
	add.l	#(26*160)+160*216,a0

	lea	spec_values,a2
	moveq	#(80/4)-1,d1
.loop	move.w	(a2)+,d0
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

save_isr
	clr.l	hertz_toggle
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
	move.l	#null,$120.w
	move.l	#new70,$70.w
	move.l	#new118,$118.w
	bclr	#3,$fffffa17.w		set AEI mode
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
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.w	#$2300,sr
	move.b	old484,$484.w
	rts



***********************
* SUBROUTINES SECTION *
***********************
show_pic
	move.l	screen_base,a1
	add.w	#160*29,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

set_super
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

set_new_palette
	lea	pic+2,a0
	bra.s	set_pal
set_old_palette
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	rts

get_screen_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,org_base
	rts

	ifeq	FINAL
get_original_rez
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts
	ENDC

set_low_rez
	clr.w	-(sp)

	ifeq	FINAL
	bra.s	set_rez
set_med_rez
	move.w	#1,-(sp)
	ENDC
set_rez	move.l	org_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts


******************************
*     INTERRUPT ROUTINES     *
******************************


new120	move.w	next_colour,$ffff8240.w		;poke straight away
	move.l	a0,-(sp)
	move.l	isr_data,a0
	move.w	(a0)+,next_colour
	move.l	a0,isr_data
	move.l	(sp)+,a0
	cmp.w	#6,counter
	bne.s	.no
	move.l	#new120_part2,$120.w
.no	addq.w	#1,counter
	rte

new120_part2
	move.w	next_colour,$ffff8240.w		;poke straight away
scroll_raster
	move.w	#$010,$ffff8242.w
	move.l	a0,-(sp)	;$120		to stop jitter

	move.l	top_raster_pos,a0
	move.w	(a0)+,scroll_raster+2
	move.l	a0,top_raster_pos

	move.l	isr_data,a0
	move.w	(a0)+,next_colour
	move.l	a0,isr_data

	move.l	(sp)+,a0

	cmp.w	#8+17,counter
	bne.s	.no
	move.l	#new120_part3,$120.w
	move.w	pic+4,$ffff8242.w

.no	addq.w	#1,counter
	rte

new120_part3
	move.w	next_colour,$ffff8240.w		;poke straight away
	move.l	a0,-(sp)	;$120		to stop jitter
	move.l	isr_data,a0
	move.w	(a0)+,next_colour
	move.l	a0,isr_data
	move.l	(sp)+,a0

	cmp.w	#226,counter
	beq.s	.do
	addq.w	#1,counter
	rte

.do	clr.w	counter
	move.l	#border,$120.w
	rte

border	movem.l	d0/a0,-(sp)
	move.w	#37,d0
.aaa	dbf	d0,.aaa
	nop
	nop
	nop
	nop
	nop
	move.b	#0,$ffff820a.w
border_hz
	move.w	#$000,$ffff8240.w
	nop
	nop
	nop
	nop
	nop
	move.b	#2,$ffff820a.w
	lea	border_rasters,a0
	move.w	#27-1,d0
col_loop
	move.w	54(a0),$ffff8240+4.w
	move.w	(a0),$ffff8242.w
	move.w	(a0)+,$ffff8240+6.w	;make spectrum go over scroll
	REPT	120-4-4
	nop
	ENDR
	dbf	d0,col_loop

	move.w	pic+4,$ffff8242.w
	move.w	pic+6,$ffff8244.w
	move.w	pic+8,$ffff8246.w
	move.w	pic+10,$ffff8248.w
	move.w	pic+12,$ffff824a.w
	move.w	pic+14,$ffff824c.w
	move.w	pic+16,$ffff824e.w
	move.w	pic+18,$ffff8250.w
	move.w	pic+20,$ffff8252.w
	move.w	pic+22,$ffff8254.w
	move.w	pic+24,$ffff8256.w
	move.w	pic+26,$ffff8258.w
	move.w	pic+28,$ffff825a.w
	move.w	pic+30,$ffff825c.w
	move.w	pic+32,$ffff825e.w
	clr.b	$fffffa1b.w
	movem.l	(sp)+,d0/a0
	move.l	#null,$120.w
null	rte


new70	move.w	#$2700,sr
	movem.l	d0-d7,-(sp)
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d6

	move.w	#$580,d7
.aaa	dbf	d7,.aaa

	clr.b	$ffff820a.w

	move.w	#0,$ffff8240.w		;used as timing
	nop

	move.b	#2,$ffff820a.w

	move.l	(sp)+,d7
	st	vsync_flag
	move.l	#new120,$120.w
	move.l	#raster_colours,isr_data
	move.l	#top_rasters,top_raster_pos
	move.w	#$010,scroll_raster+2
	tst.w	zero_counter
	beq.s	.no
	subq.w	#1,zero_counter
.no
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

new118	movem.l	d0,-(sp)
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






**********************************************************************
intro	bsr	black_out
	move.l	screen_base,a1
	lea	(160*70)+72(a1),a1
	lea	bar,a0

	move.w	#60-1,d0
OFF	set	0
.loop
	REPT	3
	move.l	(a0)+,OFF(a1)
	move.l	(a0)+,OFF+4(a1)
OFF	set OFF+8
	ENDR
	lea	160(a1),a1
	dbf	d0,.loop

	lea	bar_pal,a1
	bsr	fade

	move.w	#5000,d7
.pau	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	.ex
	dbf	d7,.pau
.ex	lea	black,a1
	bsr	fade
	rts

black_out
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fade	move.w	#7,d6
	move.l	a1,a2
next_value
	lea	$ffff8240.w,a0

	move.w	#16-1,d7
.loop	bsr	modify
	add.w	#2,a0
	add.w	#2,a1
	dbf	d7,.loop

	move.w	#4,d0
	bsr	vbl
	move.l	a2,a1
	dbf	d6,next_value
	RTS

vbl	movem.l	d0-d3/d7/a0-a3,-(sp)
	move.l	d0,d7
.loop	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	dbf	d7,.loop
	movem.l	(sp)+,d0-d3/d7/a0-a3
	rts

PALREG:	EQU $FF8240


modify	move.w	(a0),d0		;get color value
	move.w	(a1),d1		;target pal
	move.w	d0,d4		;NEW COL
	move.w	d0,d2
	move.w	d1,d3
	and.w	#$7,d2
	and.w	#$7,d3
	cmp.w	d2,d3
	beq.s	MOK1
	bmi.s	MDN1
	addq.w	#1,d4
	bra.s	MOK1
 MDN1:	SUBQ #1,D4
 MOK1:	MOVE D0,D2
	MOVE D1,D3
	AND #$70,D2
	AND #$70,D3
	CMP D2,D3
	BEQ.S MOK2
	BMI.S MDN2
	ADD #$10,D4
	BRA.S MOK2
 MDN2:	SUB #$10,D4
 MOK2:	MOVE D0,D2
	MOVE D1,D3
	AND #$700,D2
	AND #$700,D3
	CMP D2,D3
	BEQ.S MOK3
	BMI.S MDN3
	ADD #$100,D4
	BRA.S MOK3
 MDN3:	SUB #$100,D4
 MOK3:	MOVE D4,(A0)
	RTS





****************
 SECTION DATA
****************

******************* isr details **************************
counter	dc.w	0

black	ds.b	32
pic	incbin	pov_beer.pi1
tune	incbin	lap_next.mus

isr_data	dc.l	raster_colours

next_colour	dc.w	$000

raster_colours
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$001,$000,$001,$000,$001,$001,$000,$001,$001,$001
	dc.w	$001,$001,$001,$001
	dc.w	$001,$002,$001,$001,$002,$001,$002,$002,$001,$002
	dc.w	$002,$003,$002,$002,$003,$002,$003,$003,$002,$003
	dc.w	$003,$004,$003,$003,$004,$003,$004,$004,$003,$004
	dc.w	$004,$005,$004,$004,$005,$004,$005,$005,$004,$005
	dc.w	$005,$105,$005,$005,$105,$005,$105,$105,$005,$105
	dc.w	$105,$205,$105,$105,$205,$105,$205,$205,$105,$205
	dc.w	$205,$215,$205,$205,$215,$205,$215,$215,$205,$215
	dc.w	$215,$324,$215,$215,$324,$215,$324,$324,$215,$324
	dc.w	$324,$424,$324,$324,$424,$324,$424,$424,$324,$424
	dc.w	$424,$433,$424,$424,$433,$424,$433,$433,$424,$433
	dc.w	$433,$532,$433,$433,$532,$433,$532,$532,$433,$532
	dc.w	$532,$632,$532,$532,$632,$532,$632,$632,$532,$632
	dc.w	$632,$732,$632,$632,$732,$632,$732,$732,$632,$732
	dc.w	$732,$742,$732,$732,$742,$732,$742,$742,$732,$742
	dc.w	$742,$742,$742,$742,$742,$742,$742,$732,$742,$732
	dc.w	$742,$732,$632,$732,$632,$732,$732,$632,$532,$632
	dc.w	$532,$433,$532,$433,$424,$433,$424,$324,$424,$324
	dc.w	$215,$324,$215,$205,$215,$205,$105,$005,$003,$002
	dc.w	$001

 dc.w	0,0,0,0,0,0,0,0,0,0
	even

************** Scroller bits and pieces ******************
scroll_number	dc.w	16
line_ptr	dc.l	scroll_line
buffer		dcb.b	BUFFER_SIZE,0
**********************************************************

********************** Scroll text ***********************
scroll_line
 dc.b "   PERSISTENCE OF VISION PACKED DEMO DISC 107.    RELEASE DATE 1ST MARCH 1992.   "
 DC.B "    CREDITS: MENU CODED BY M.S.D.,   "
 DC.B "GRAFIX BY OZ AND MUSIC FROM LAP (COMPOSITION 28).    "
 dc.b "   ANOTHER MENU WITH A RASTER BACKDROP, LOOKS GOOD EH?     WHEN "
 DC.B "I MENTIONED TO OZ THAT HE DIDN'T HAVE TO STICK TO 16 COLOURS "
 DC.B "HE WENT BERSERK AND STARTED ON THESE RASTER PICS.    "
 DC.B "IT'S A BLEEDIN' PAIN IN THE ARSE TYPING IN THE COLOURS BUT "
 DC.B "LIKE OZ SAYS - JUST DO IT!     (HEY OZ, I'VE DONE ANOTHER TRACKER "
 DC.B "SLIDESHOW WITH BORDER CODE AND IT WORKS ON TOS 1.62 NOW - HONEST!),       "
 DC.B "        MEGA GREETS TO   OZ,   BORIS,   BILBO (RIPPED OFF),   "
 dc.b "SPEED (THE SOURCE),   DR.SYNE (ZEN),   MUG UK (THE SOURCE),   "
 DC.B "GEORGE (TOWER PD)   AND   DEL (D.W. STABLES PD).                   END OF TEST SIGNAL "
 DC.B "AS THERE IS NO MORE DISC SPACE LEFT.                                                             "
 dc.b	$ff
***********************************************************

************************* font bits ***********************
font	incbin	medway_9.dAT	;9 pixel wide medway boys font.
***********************************************************


*************** spectrum analyzer bits and bobs ***********
spec_data	incbin	SPECTRUM.DAT
spec_values	dcb.w	MAX_BARS,0
***********************************************************

top_raster_pos

top_rasters
 dc.w	$100,$200,$300,$400,$500,$600
 dc.w	$700,$710,$720,$730,$740,$750,$760
 dc.w	$770,$670,$570,$470,$370,$270,$170

border_rasters
	dc.w	$080,$010,$090,$020,$0a0,$030,$0b0,$040
	dc.w	$0c0,$050,$0d0,$060,$0e0,$070,$0f0
	dc.w	$0f0,$070,$0e0,$060,$0d0,$050,$0c0,$040
	dc.w	$0b0,$030,$0a0,$020

;now colours for lower scroll
	dc.w	0,0,0,0,0,0
	dc.w	$00f,$08f,$01f,$09f,$02f,$0af,$03f,$0bf
	dc.w	$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
	dc.w	0,0,0,0,0
key_codes
	dc.b	2,0	;key 1
	dc.b	3,1
	dc.b	4,2
	dc.b	5,3	;key 4
	dc.b	6,4	;key 5
	dc.b	7,5	;key 6
	dc.b	8,6	;key 7

	dc.b	$6d,0	;keypad 1
	dc.b	$6e,1
	dc.b	$6f,2
	dc.b	$6a,3	;keypad 4
	dc.b	$6b,4	;keypad 5
	dc.b	$6c,5	;keypad 6
	dc.b	$67,6	;keypad 7
	dc.b	$ff
	even

filenames	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7

exec1	dc.b	"sny",0
	even
exec2	dc.b	"$$3615gen4",0
	even
exec3	dc.b	"abc22",0
	even
exec4	dc.b	"dma1",0
	even
exec5	dc.b	"tsv",0
	even
exec6	dc.b	"kgbdemo2",0
	even
exec7	dc.b	"copier",0
	even

bar	incbin	bar.dat
bar_pal	incbin	bar.col


barrel_offset_pos	dc.l	barrel_offset
barrel_offset
	incbin	barrel.pth
	dc.w	-1
	
barrel_rotate
	dc.w	40+40+40+40+40
	dc.w	40+40+40+40
	dc.w	40+40+40
	dc.w	40+40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	0
	dc.w	40
	dc.w	0,0,0,0,0
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40
	dc.w	40+40
	dc.w	40
	dc.w	40+40
	dc.w	40+40+40
	dc.w	40+40+40+40
	dc.w	40+40+40+40+40


barrel_grafic
	dcb.b	40*60,0
	incbin	barrel.dat

*****************************
	SECTION BSS
*****************************
bss_start
	ds.b	(8*5)*70	;space for gap below POV logo grafic

stack_save	ds.l	1
screen_base	ds.l	1
org_base	ds.l	1
	ifeq	FINAL
original_rez	ds.w	1
	ENDC
vsync_flag	ds.w	1

old120	ds.l	1
old70	ds.l	1
old118	ds.l	1
save1	ds.b	1
save2	ds.b	1
save3	ds.b	1
save4	ds.b	1
save5	ds.b	1
save6	ds.b	1
save7	ds.b	1
save8	ds.b	1
	even
old_palette	ds.w	16

hertz_toggle	ds.w	1
zero_counter	ds.w	1

old484		ds.b	1
key		ds.w	1
	even
	ds.b	256
screens	ds.b	160*29
	ds.b	160*200
	ds.b	160*47
stopper

*
* POV 'LIFE' MENU (disc 86)
*

	opt	o+,w-,ow2-,ow3-


KBD_VEC		equ	$118
VERT_ISR	equ	$70
HORIZ_ISR	equ	$120


	SECTION	TEXT

start
	lea	clock,a0
.clear	clr.w	(a0)+
	cmp.l	#finish,a0
	blt.s	.clear
	bsr	super_mode
	bsr	black_palette
	bsr	vsync
	move.b	#2,$ffff820a.w
	clr.b	$ffff8260.w
	bsr	set_up
	bsr	show_pic
	bsr	set_palette
	bsr	start_tune

	bsr	vsync
	move.w	sr,d0
	or.w	#$700,sr
	move.l	HORIZ_ISR,hbc_bak
	move.l	VERT_ISR,vbl_bak
	move.b	$fffffa07.w,a07_bak
	move.b	$fffffa13.w,a13_bak
	clr.b	$fffffa1b.w
	move.l	#null,HORIZ_ISR
	move.l	#vbl_isr,VERT_ISR
	or.b	#1,$fffffa07.w
	move.b	#$40,$fffffa09.w
	or.b	#1,$fffffa13.w
	move.l	KBD_VEC,kbd_bak
	move.l	#new_kbd,KBD_VEC
	move.w	d0,sr
	moveq	#0,d1
	bsr	change_grid

.loop
	bsr	set_screen
	move.w	#-1,vsync_flag
.wait	tst.w	vsync_flag
	bne.s	.wait
	bsr	calc_grid
	eor.w	#(42*27),buf_off
	bsr	display_grid

	move.w	key,d0
	and.w	#$ff7f,d0
	cmp.w	#$3b,d0
	blt.s	.cont
	cmp.w	#$42,d0
	bgt.s	.cont
	move.w	d0,d1
	sub.w	#$3b,d1
	bsr	change_grid
	clr.w	key
.cont	bsr	change_hz
	cmp.w	#$c53,d0
	beq	reset
	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	.loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run
	lsr.w	#4,d1
	and.w	#$fff0,d1
	lea	filenames,a0
	lea	$200.w,a1
	add.w	d1,a0
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

isr_off
	move.w	sr,d0
	or.w	#$700,sr
	move.l	kbd_bak,KBD_VEC
	move.l	vbl_bak,VERT_ISR
	move.l	hbc_bak,HORIZ_ISR
	and.b	#$fe,$fffffa07.w
	move.b	#$64,$fffffa09.w
	and.b	#$fe,$fffffa13.w
	move.w	d0,sr

	bsr	stop_tune
	cmp.l	#"OVR.",$200.w
	beq.s	do_message
cont	bsr	black_palette
	bsr	low_res
	tst.w	hz_col
	beq.s	.skip
	clr.b	$ffff820a.w
.skip	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	beq.s	.end
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bra.s	.skip
.end
	bsr	user_mode
exit
	clr.w	-(sp)		; Exit.
	trap	#1

do_message
.skip	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	beq.s	.end
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bra.s	.skip
.end	clr.w	$ffff8240.w
	move.w	#$fff,$ffff825e.w
	bsr	low_res
	pea	message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra.s	cont

***************
* Subroutines *
***************

change_grid
	lea	pre_sets,a0
	mulu	#(42*27),d1
	add.w	d1,a0
	lea	buffer,a1
	move.l	a1,a2
	add.w	#(42*27),a2
	move.w	#(42*27/2)-1,d1
.loop	move.w	(a0)+,(a1)+
	clr.w	(a2)+
	dbf	d1,.loop
	clr.w	buf_off
	rts


clear_spec
	lea	spec_values,a0
	move.w	#80-1,d0
.cnt_down
	tst.b	(a0)+
	beq.s	.next
	subq.b	#1,-1(a0)
.next
	dbf	d0,.cnt_down

	move.l	scr_pre,a0
	add.w	#(160*202)+4,a0
	moveq	#0,d1

	REPT	32
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
	lea	spec_data,a3

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

	lsl.w	#1,d0
	move.w	(a3,d0),d0
	bmi.s	bchan
	lsr.w	#1,d0
	move.b	d1,(a2,d0)

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

	lsl.w	#1,d0
	move.w	(a3,d0),d0
	bmi.s	cchan
	lsr.w	#1,d0
	move.b	d1,(a2,d0)

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

	lsl.w	#1,d0
	move.w	(a3,d0),d0
	bmi.s	ps
	lsr.w	#1,d0
	move.b	d1,(a2,d0)

******************** print speccy *******************
ps
	move.l	scr_pre,a0
	add.l	#(160*217)+4,a0

	lea	spec_values,a2
	move.w	#20-1,d1
.loop
	moveq	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib2
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%11100000,d2
.loop1	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2
	moveq	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib3
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3
	moveq	#0,d0
	move.b	(a2)+,d0
	beq.s	.nib4
	move.l	a0,a1
	lea	160(a0),a3
	move.b	#%11100000,d2
.loop3	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4
	moveq	#0,d0
	move.b	(a2)+,d0
	beq.s	.nonib
	move.l	a0,a1
	lea	160(a0),a3
	move.l	a0,a1
.loop4	or.b	d2,1(a1)
	or.b	d2,1(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4

.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts

**************************************************


calc_grid
	lea	buffer+43,a0
	move.l	a0,a1
	move.w	buf_off,d0
	add.w	d0,a0
	eor.w	#(42*27),d0
	add.w	d0,a1
	moveq	#24,d0
.loopy
	moveq	#39,d1
.loopx
	moveq	#0,d2
	add.b	-43(a0),d2
	add.b	-42(a0),d2
	add.b	-41(a0),d2
	add.b	-1(a0),d2
	add.b	1(a0),d2
	add.b	41(a0),d2
	add.b	42(a0),d2
	add.b	43(a0),d2
	move.b	(a0),d3
	cmp.b	#2,d2
	beq.s	.ok
	moveq	#1,d3
	cmp.b	#3,d2
	beq.s	.ok
	moveq	#0,d3
.ok	move.b	d3,(a1)+
	addq.w	#1,a0
	dbf	d1,.loopx
	addq.w	#2,a0
	addq.w	#2,a1
	dbf	d0,.loopy
	rts

display_grid
	lea	buffer,a0
	add.w	buf_off,a0
	lea	43(a0),a0
	move.l	scr_now,a1
	lea	picture+34,a2
	moveq	#24,d0
.loopy
	moveq	#19,d1
.loopx
	moveq	#0,d2
	tst.b	(a0)+
	beq.s	.skip1
	move.l	#$7e7e7e7e,d2
.skip1
OFF	set	160
	REPT	6
	movep.l	OFF(a2),d3
	or.l	d2,d3
	movep.l	d3,OFF(a1)
OFF	set	OFF+160
	ENDR
	moveq	#0,d2
	tst.b	(a0)+
	beq.s	.skip2
	move.l	#$7e7e7e7e,d2
.skip2
OFF	set	161
	REPT	6
	movep.l	OFF(a2),d3
	or.l	d2,d3
	movep.l	d3,OFF(a1)
OFF	set	OFF+160
	ENDR
	addq.w	#8,a1
	addq.w	#8,a2
	dbf	d1,.loopx
	add.w	#(160*7),a1
	add.w	#(160*7),a2
	addq.w	#2,a0
	dbf	d0,.loopy
	rts


big_scroll
	lea	font,a5
	move.l	scr_pre,a1
	add.w	#(160*202),a1
	move.l	text_ptr,a4
	move.l	a4,a3
	move.w	char_offset,d6
	moveq	#0,d2
	moveq	#39,d1
.loop	moveq	#0,d0
	move.b	(a3),d0
	bpl.s	.cont
	lea	text_start,a3
	bra.s	.loop
.cont	move.l	a5,a0
	lsl.w	#8,d0
	add.w	d0,a0
	move.w	d6,d0
	lsl.w	#6,d0
	add.w	d0,a0
OFF	set	0
	REPT	32
	move.w	(a0)+,d0
	movep.w	d0,OFF(a1)
OFF	set	OFF+160
	ENDR
	addq.w	#1,d6
	and.w	#3,d6
	bne.s	.ok
	addq.w	#1,a3
	tst.b	(a3)
	bpl.s	.ok
	lea	text_start,a3
.ok	addq.w	#1,a1
	tst.w	d2
	beq.s	.next
	addq.w	#6,a1
.next	not.w	d2
	dbf	d1,.loop
	addq.w	#1,d6
	and.w	#3,d6
	move.w	d6,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	text_start,a4
.end	move.l	a4,text_ptr
	rts


show_pic
	lea	picture+34,a0
	move.l	scr_now,a1
	move.l	a1,a2
	add.l	#(160*248),a2
	move.w	#(160*200/4)-1,d0
.loop1	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop1
	move.w	#(160*48/4)-1,d0
.loop2	clr.l	(a1)+
	clr.l	(a2)+
	dbf	d0,.loop2
	rts


reset
	move.l	$4.w,-(sp)
	rts


change_hz
	tst.w	clock
	bne.s	.end
	move.w	key,d0
	cmp.b	#$0b,d0
	beq.s	.ok
	cmp.b	#$70,d0
	beq.s	.ok
	rts
.ok	eor.w	#$112,hz_col
	move.w	#2,clock
	clr.w	key
	rts
.end	subq.w	#1,clock
	rts


set_up
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#(160*248),d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

set_screen
	move.l	scr_now,d0
	move.l	d0,scr_pre
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	move.l	scr_now,d0
	move.l	scr_xor,d1
	eor.l	d1,d0
	move.l	d0,scr_now
	rts


super_mode
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk
	rts

user_mode
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	rts


low_res
	bsr	vsync
	clr.w	-(sp)
	move.l	$44e.w,-(sp)
	move.l	$44e.w,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts


set_palette
	movem.l	picture+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

black_palette
	lea	$ffff8240.w,a0
	REPT	8
	clr.l	(a0)+
	ENDR
	rts


vsync
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts


new_kbd
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


vbl_isr
	clr.b	$fffffa1b.w
	movem.l	d0-d6/a0-a5,-(sp)
	clr.w	vsync_flag
	move.l	#raster,HORIZ_ISR
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	and.w	#$f3ff,sr
	jsr	tune+$8
	move.l	colour_ptr,a6
	addq.w	#2,a6
	tst.w	(a6)
	bpl.s	.skip
	lea	colours,a6
.skip	move.l	a6,colour_ptr
	move.w	#198,d7
	movem.l	picture+2,d0-d6/a0
	movem.l	d0-d6/a0,$ffff8240.w
	bsr	big_scroll
	bsr	clear_spec
	bsr	spec
	movem.l	(sp)+,d0-d6/a0-a5
	rte

raster
	clr.b	$fffffa1b.w
	move.w	(a6)+,$ffff825e.w
	tst.w	(a6)
	bpl.s	.cont
	lea	colours,a6
.cont	subq.w	#1,d7
	bne.s	.skip
	move.l	#border_isr,HORIZ_ISR
.skip	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

border_isr
	or.w	#$700,sr
	clr.b	$fffffa1b.w
	movem.l	d0/a0,-(sp)
	moveq	#0,d0
.wait1	cmp.b	#$60,$ffff8209.w
	bne.s	.wait1
	REPT	8
	nop
	ENDR
	lea	.nops(pc),a0
	move.b	$ffff8209.w,d0
	sub.b	#$60,d0
	add.w	d0,a0
	jmp	(a0)
.nops	REPT	38
	nop
	ENDR
	moveq	#18,d0
.wait2	dbf	d0,.wait2
	clr.b	$ffff820a.w
	move.w	hz_col,$ffff8240.w
	nop
	move.b	#2,$ffff820a.w
	move.w	#$500,$ffff8242.w
	move.l	#$07300343,$ffff8244.w
	move.l	#$07700770,$ffff8248.w
	move.l	#$07700770,$ffff824c.w
	movem.l	(sp)+,d0/a0
null	bclr	#0,$fffffa0f.w
	rte


start_tune
	moveq	#1,d0
	jmp	tune

stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


********************
* Initialised data *
********************

	SECTION	DATA

colour_ptr
	dc.l	colours
colours
	REPT	25
	dc.w	$222, $aaa, $333, $bbb
	dc.w	$444, $ccc, $555, $ddd
	dc.w	$666, $eee, $777, $fff
	dc.w	$fff, $777, $eee, $666
	dc.w	$ddd, $555, $ccc, $444
	dc.w	$bbb, $333, $aaa, $222
	dc.w	$999
	ENDR
	dc.w	-1

picture		incbin	"PLANE.PI1"

font		incbin	"SLANT32C.FNT"

char_offset	dc.w	0
text_ptr	dc.l	text_start
text_start
	incbin	"SCROLLER.TXT"
	dc.b	-1
	even

tune
	incbin	"MSD.IMG"
	even

pre_sets
; Pattern 1
	dcb.b	42,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
	dc.b	0,0,0,0,1,0,1,1,1,1,0,0,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,0,0,1,1,1,1,0,1,0,0,0,0
	dc.b	0,0,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,0,1,0,0,0
	dc.b	0,0,1,0,1,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,1,0,1,0,0
	dc.b	0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0
	dc.b	0,0,0,1,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,1,1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0,0
	dc.b	0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
	dc.b	0,0,0,1,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,1,0,0,1,0,1,1,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0
	dc.b	0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0
	dc.b	0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
	dc.b	0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0
	dc.b	0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0
	dc.b	0,0,0,1,0,1,0,1,1,1,0,0,0,0,0,0,1,1,1,0,0,0,0,1,1,1,0,0,0,0,0,0,1,1,1,0,1,0,1,0,0,0
	dc.b	0,0,0,0,1,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,0,0,0,0
	dc.b	0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
	dcb.b	42,0
	dcb.b	42,0

; Pattern 2
	REPT	11
	dcb.b	42,0
	ENDR
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	REPT	11
	dcb.b	42,0
	ENDR

; Pattern 3
	REPT	11
	dcb.b	42,0
	ENDR
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	REPT	12
	dcb.b	42,0
	ENDR

; Pattern 4
	REPT	11
	dcb.b	42,0
	ENDR
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	REPT	11
	dcb.b	42,0
	ENDR

; Pattern 5
	dcb.b	42,0
	dc.b	0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	REPT	6
	dcb.b	42,0
	ENDR
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	REPT	7
	dcb.b	42,0
	ENDR
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0
	dcb.b	42,0

; Pattern 6
	REPT	7
	dcb.b	42,0
	ENDR
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	REPT	7
	dcb.b	42,0
	ENDR

; Pattern 7
	REPT	4
	dcb.b	42,0
	ENDR
	dc.b	0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
	dcb.b	42,0
	dc.b	0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
	REPT	4
	dcb.b	42,0
	ENDR

; Pattern 8
	REPT	27
	dcb.b	42,1
	ENDR

spec_data	incbin	"SPECTRUM.DAT"
spec_values	dcb.b	80,0

demo_keys
	dc.b	0, $02
	dc.b	1, $03
	dc.b	2, $04
	dc.b	3, $05
	dc.b	4, $06
	dc.b	0, $6d
	dc.b	1, $6E
	dc.b	2, $6F
	dc.b	3, $6A
	dc.b	4, $6B
	dc.b	-1, -1
filenames
	dc.b	"SWS_DEMO.PRG",0,0,0,0
	dc.b	"VICE.PRG",0,0,0,0,0,0,0,0
	dc.b	"OVR.PRG",0,0,0,0,0,0,0,0,0
	dc.b	"SIT_COM.PRG",0,0,0,0,0
	dc.b	"COPIER.POV",0
	even

message	dc.b	27,'E'
 dc.b	27,'Y',32+0,32+16,"OVR DEMO"
 dc.b	27,'Y',32+4,32+0,"This demo has two parts, the first part"
 dc.b	27,'Y',32+5,32+0,"is basically a scroller and works on all"
 dc.b	27,'Y',32+6,32+14,"ST machines."
 dc.b	27,'Y',32+8,32+0,"The second part is a full screen 3D dots"
 dc.b	27,'Y',32+9,32+1,"demo which makes a mess on the STE due"
 dc.b	27,'Y',32+10,32+0,"to the full screen. It also flickers on"
 dc.b	27,'Y',32+11,32+1,"both my STFMs but it is good so enjoy!"
	dc.b	0

	even
**********************
* Uninitialised data *
**********************

	SECTION	BSS

clock		ds.w	1

hz_col		ds.w	1

vsync_flag	ds.w	1

save_stk	ds.l	1

key		ds.w	1

kbd_bak		ds.l	1
vbl_bak		ds.l	1
hbc_bak		ds.l	1
a07_bak		ds.b	1
a13_bak		ds.b	1

scr_now		ds.l	1
scr_xor		ds.l	1
scr_pre		ds.l	1

buf_off		ds.w	1
buffer		ds.b	(42*27*2)

		ds.b	256
screens		ds.b	(160*248*2)
finish	even

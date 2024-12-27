;Ivor Biggun intro.

	bsr	set_super
	move.l	#stack,sp
	dc.w	$a00a		;hide mouse
	move.b	#$12,$fffffc02.w
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez

;************************************************************************
;*                            UNKNOWN                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 16/08/90 18:04                     *
;*      From: DELIRIUS DEMO ADVERT                                      *
;* Include files:-                                                      *
;*                 ADVERT.IMG into TUNE                                 *
;************************************************************************
;* music by MAD MAX
;*
	move.b	$484.w,old484
	move.b	#2,$484.w

;****************************************************************
; There is more than one tune in this code....
; 0=no music
; 1=no music
; 2=tune 1
; 3=tune 2 - pretty good (On an Automation menu as well I think)
; 4=tune 3 - weird start but brill!
; 5=tune 4 - only uses 2 channels!
; 6=jingle
; 7=sound effect - bleeps
; 8=tune 5
	moveq.l	#3,d0
	bsr	music
	bsr	set_isr
	bsr	sync25
	bsr	print_erik
	bsr	sync50
	bsr	drop_erik
	bsr	draw_line
	bsr	draw_top_logo
	bsr	set_up_barrel
	bsr	draw_barrel

wait:	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	scroll
	bsr	ivor_bit
	bsr	ripple
	bsr	logo_bounce
;	move.w	pal,$ffff8240.w
	bsr	tst_key
	tst.l	d0
	beq.s	wait
	bsr	get_key

	bsr	isr_off
	move.b	old484,$484.w
	bsr	set_old_palette
	bsr	set_med_rez
	move.b	#$8,$fffffc02.w
	dc.w	$a009
	bsr	set_user

	clr.w	-(sp)
	trap	#1
ERR:	bra.s	ERR

*******************
* CUSTOM ROUTINES *
*******************

ripple:
	move.l	screen_base,a6
	add.w	#160*172,a6
	add.w	#24,a6
	move.l	ripple_pos,a4
	moveq	#0,d3
	move.w	#28-1,d7
.loop:	lea	logo,a5
	add.w	d3,a5
	moveq	#0,d0
	cmp.b	#$ff,(a4)
	bne.s	.no
	lea	ripple_table,a4
	move.l	a4,ripple_pos
.no	move.b	(a4)+,d0
.loop2	mulu	#128*28,d0
	add.l	d0,a5
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	add.w	#160-128,a6
	add.w	#128,d3
	dbf	d7,.loop
	add.l	#1,ripple_pos
	rts

print_erik:
	move.l	screen_base,a1
	sub.w	#160*28,a1
	add.w	#24,a1
	movea.l	a1,a2
	add.w	#160,a2
	bsr	print_logo
	REPT	28
	bsr	vsync
	move.l	a2,a1
	add.w	#160,a2
	bsr	print_logo
	ENDR
	rts

drop_erik:
	move.w	#43-1,d7
	lea	fall_table,a2
.loop:	bsr	vsync
	move.l	screen_base,a1
	add.w	#24,a1
	move.w	old_position,d0
	add.w	d0,a1
	move.w	d7,-(sp)
	bsr	clear_old
	move.w	(sp)+,d7
	move.l	screen_base,a1
	add.w	#24,a1
	move.w	(a2)+,d0
	move.w	d0,old_position
	add.w	d0,a1
	move.w	d7,-(sp)
	bsr.s	print_logo
	move.w	(sp)+,d7
	dbf	d7,.loop
	rts

print_logo:
	lea	logo,a0
print_img
	REPT	28
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a1)
	add.w	#32,a0
	add.w	#32,a1
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a1)
	add.w	#32,a0
	add.w	#32,a1
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a1)
	add.w	#32,a0
	add.w	#32,a1
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/d7
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a1)
	add.w	#32,a0
	add.w	#64,a1
	ENDR
	rts

clear_old:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,d7
	REPT	28
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a1)
	add.w	#32,a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a1)
	add.w	#32,a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a1)
	add.w	#32,a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a1)
	add.w	#32,a1
	add.w	#160-128,a1
	ENDR
	rts

draw_line
	move.l	screen_base,a0
	add.w	#168*160,a0
	move.w	#20-1,d0
.loop:	bsr	vsync
	move.l	#-1,(a0)+
	move.l	#-1,(a0)+
	dbf	d0,.loop
	rts

logo_bounce
	bsr	clear_prev
	move.l	logo2_pointer,a0
	cmp.b	#$ff,(a0)
	bne.s	no_logo2_rst
	lea	logo2_table,a0
	move.l	a0,logo2_pointer
no_logo2_rst
	moveq	#0,d0
	move.b	(a0)+,d0
	move.l	a0,logo2_pointer
	mulu	#160,d0
	move.l	d0,old_pos
	move.l	screen_base,a1
	add.w	d0,a1
	lea	logo2,a0
	move.w	#9-1,d0
.loop	REPT	160/4
	move.l	(a0)+,(a1)+
	ENDR
	dbf	d0,.loop
	rts
draw_top_logo
	move.l	screen_base,a1
	lea	logo2,a0
	move.w	#20-1,d7
.words	move.w	#$c000,d0
	move.w	#8-1,d6
.bits	bsr	vsync
	move.w	#9-1,d5
.lines	move.w	(a0),d4
	move.w	2(a0),d3
	move.w	4(a0),d2
	move.w	6(a0),d1
	and.w	d0,d4
	and.w	d0,d3
	and.w	d0,d2
	and.w	d0,d1
	move.w	d4,(a1)
	or.w	d3,2(a1)
	or.w	d2,4(a1)
	or.w	d1,6(a1)
	add.w	#160,a0
	add.w	#160,a1
	dbf	d5,.lines
	sub.w	#9*160,a0
	sub.w	#9*160,a1
	move.w	d0,d2
	lsr.w	#1,d2
	or.w	d2,d0
	lsr.w	#1,d2
	or.w	d2,d0
	dbf	d6,.bits
	add.w	#8,a1
	add.w	#8,a0
	dbf	d7,.words
	rts

clear_prev
	move.l	old_pos,d0
	move.l	screen_base,a1
	add.l	d0,a1
	move.w	#9-1,d0
	moveq	#0,d1
.loop	REPT	160/4
	move.l	d1,(a1)+
	ENDR
	dbf	d0,.loop
	rts

****************************************
ivor_bit	;barrel
roll_barrel
	lea	barrel_data,a2
	move.l	screen_base,a1
	add.w	#160*47,a1
	move.l	barrel_offset,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_end
	lea	offset_table,a0
	move.l	a0,barrel_offset
no_end	moveq	#0,d0
	move.w	(a0)+,d0
	move.l	a0,barrel_offset
	mulu	#160,d0
	lea	ivor_data,a0
	add.l	d0,a0
	move.w	#34-1,d0
.loop	move.l	d0,-(sp)
	moveq	#0,d1
	move.b	(a2)+,d1
	mulu	#160,d1
	add.w	d1,a0
	move.l	a0,a6
	bsr	print_ivor
	move.l	a6,a0
	move.l	(sp)+,d0
	dbf	d0,.loop
	rts

print_ivor
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	add.w	#32,a0
	add.w	#32,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	add.w	#32,a0
	add.w	#32,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	add.w	#32,a0
	add.w	#32,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	add.w	#32,a0
	add.w	#32,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	add.w	#32,a0
	add.w	#32,a1
	rts

set_up_barrel
************** set up barrel ************
	lea	ivor_pic,a0
	lea	ivor_pic+34,a1
	move.w	#32000/4-1,d0
seb	move.l	(a1)+,(a0)+
	dbf	d0,seb
	lea	ivor_pic+32000,a0
	move.w	#68/4-1,d0
seb2	move.l	#$ffffffff,(a0)+
	dbf	d0,seb2
	rts

draw_barrel
	lea	ivor_pic,a0
	move.l	screen_base,a1
	add.w	#160*81,a1
	move.w	#34-1,d0
.loop	bsr	vsync
	REPT	160/4
	move.l	-(a0),-(a1)
	ENDR
	dbf	d0,.loop
	rts

	rts

***********************
* SUBROUTINES SECTION *
***********************
scroll:	move.l	screen_base,a1
	add.w	#160*84,a1
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
	mulu	#120,d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#30,d0
	add.w	d0,a0
.column
OFF	set	0
	REPT	30
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR
	subq.w	#1,d5
	beq.s	.finish
	add.w	#1,a1
	tst.w	d4
	beq.s	.skip
	add.w	#6,a1
.skip	not.w	d4
	addq.w	#1,d6
	and.w	#3,d6
	bne	.column
	addq.w	#1,a5
	tst.b	(a5)
	bpl	next_char
	lea	scroll_text,a5
	bra	next_char

.finish	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts

tst_key	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

set_super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

set_user:
	move.l	(sp)+,a6
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	jmp	(a6)

get_old_palette:
	lea	$ffff8240.w,a0
	lea	old_palette,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_new_palette:
	lea	pal,a0
	bra.s	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_low_rez:
	clr.w	-(sp)
	bra.s	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

set_isr	move.w	#$2700,sr
	move.l	$120,hbc
	move.l	$70,v_blank
	move.b	$FFFa09,a09
	move.b	$FFFa07,a07
	move.b	$FFFa13,a13
	and.b	#$DF,$FFFA09
	and.b	#$FE,$FFFA07
	move.l	#isr1,$120
	move.l	#isr2,$70
	or.b	#1,$FFFA07	;EI
	or.b	#1,$FFFA13	;EI
	move.w	#$2300,sr
	rts

isr_off	move.w	#$2700,sr
	move.l	v_blank,$70
	and.b	#$DF,$FFFA09
	and.b	#$FE,$FFFA07
	move.l	hbc,$120
	move.b	a07,$FFFa07
	move.b	a09,$FFFa09
	move.b	a13,$fffa13

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.w	#$2300,sr
	rts

********
* ISRs *
********
isr1	move.b	#0,$fffffa1b.w
	move.l	#isr1a,$120
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w		;HBC timer
	bclr	#0,$fffffa0f.w	;EI
	rte

isr1a:	move.b	#0,$fffffa1b.w
	move.l	a0,-(sp)
	move.l	isr_data,a0
	move.w	(a0)+,$ffff8242.w
	move.l	(sp)+,a0
	add.l	#2,isr_data
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w		;HBC timer
	bclr	#0,$fffffa0f.w	;EI
	rte

isr2:	;$70
	move.b	#0,$FFFA1B	;reset timer B
	move.l	#b_line,isr_data
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	music+8
	bsr	vu
	movem.l	(sp)+,d0-d7/a0-a6
	clr.w	vsync_flag
	move.w	pal+2,$ffff8242.w
	move.b	#84,$FFFA21
	move.b	#8,$FFFA1B
	rte

vu:	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	#15,d1
	and.w	#15,d0
	sub.w	d0,d1
	move.l	screen_base,a0
	add.w	#160*123+40,a0
	bsr	draw

	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	#15,d1
	and.w	#15,d0
	sub.w	d0,d1
	move.l	screen_base,a0
	add.w	#160*123+64+40,a0
	bsr	draw

	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	#15,d1
	and.w	#15,d0
	sub.w	d0,d1
	move.l	screen_base,a0
	add.w	#160*123+16+40,a0
	bsr	draw

	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	#15,d1
	and.w	#15,d0
	sub.w	d0,d1
	move.l	screen_base,a0
	add.w	#(160*123)+16+16+16+40,a0
	bsr	draw

	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	#15,d1
	and.w	#15,d0
	sub.w	d0,d1
	move.l	screen_base,a0
	add.w	#160*123+32+40,a0
	bsr	draw
	rts

draw	tst.w	d1
	beq.s	.loop2
.loop	clr.w	(a0)
	add.w	#480,a0
	sub.w	#1,d1
	bne.s	.loop
	tst.w	d0
	beq.s	ez
.loop2	move.w	#$ffff,(a0)
	add.w	#480,a0
	sub.w	#1,d0
	bne.s	.loop2
ez	rts

*******************************

sync25:	move.w	#25,d0
	bra.s	del
sync50	move.w	#50,d0
del:	bsr.s	vsync
	dbf	d0,del
	rts

vsync:	move.w	#$ffff,vsync_flag
vsyn:	tst.w	vsync_flag
	bne.s	vsyn
	rts

****************
* DATA SECTION *
****************
	SECTION DATA
stack_save:	dc.l	0
screen_base	dc.l	0
old484:		dc.w	0
original_rez:	dc.w	0
pal:	dc.w	$000,$667,$556,$445,$334,$223,$112,$060,$007,$006,$005,$004,$003,$222,$444,$777
music:	incbin	E:\ivor\advert.img
	even
old_position:	dc.w	0
fall_table:
	dc.w	0,160,320,480,640
	dc.w	960,1280,1600
	dc.w	2080,2560
	dc.w	3360,4160
	dc.w	5120,6080,7040,8000,8960,9920,10880,11840,12800,13760

	dc.w	14720,15680,16640,17600,18560,19520,20480,21440,22400
	dc.w	23360,24160
	dc.w	24960,25440
	dc.w	25920,26240,26560
	dc.w	26880,27040,27200,27360,27520
***************************
hbc:	dc.l	0
v_blank:	dc.l	0
a09:	dc.l	0
a07:	dc.l	0
a13:	dc.l	0
vsync_flag:	dc.w	$ffff
line_count:	dc.w	0	;count of horizontal line down screen for ISR1
isr_data:	dc.l	b_line
b_line:
	dc.w	$807,$00f
	dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
	dc.w	$0ff,$07f,$0ef,$06f,$0df,$05f,$0cf,$04f,$0bf,$03f,$0af,$02f,$09f,$01f,$08f
 dc.w	$00f,$807,$10e,$906,$20d,$a05,$30c,$b04,$40b,$c03,$50a,$d02,$609,$e01,$708
 dc.w	$f00,$f80,$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0,$f50,$fd0,$f60,$fe0,$f70
 dc.w	$ff0,$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0
 dc.w	$0f0,$070,$0e0,$060,$0d0,$050,$0c0,$040,$0b0,$030,$0a0,$020,$090,$010,$080
	dcb.w	150,0
	dc.w	0,0,0
	even


ripple_pos:	dc.l	init_ripple_table
init_ripple_table:
	dcb.b	72,0
	dcb.b	72,0
	dcb.b	72,0

ripple_table:
	dcb.b	72,0
	dc.b	1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8
	dc.b	9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15

	dc.b	14,14,14,14,13,13,13,13,12,12,12,12,11,11,11,11,10,10,10,10,9,9,9,9,8,8,8,8
	dc.b	7,7,7,7,6,6,6,6,5,5,5,5,4,4,4,4,3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0

	dc.b	1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15
	dc.b	14,14,14,13,13,13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0

	dc.b	1,3,5,7,9,11,13,15,15,15,15,15,13,11,9,7,5,3,1,0,0,0,0,0
	dc.b	1,3,5,7,9,11,13,15,15,15,15,15,13,11,9,7,5,3,1,0,0,0,0,0

	dc.b	1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8
	dc.b	8,6,4,2,0,2,4,6,8,10,12,14,12,10
	dc.b	8,6,4,2,0,2,4,6,8,10,12,14,12,10
	dc.b	9,8,7,6,5,4,3,2,1,0

	dc.b	1,2,3,4,5,7,9,11,14,15,15,15,15,15,15,15,15,15,15,15
	dc.b	14,13,11,9,6,3,1,0,1,3,6,9,11,13,14,15
	dc.b	15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
	dc.b	14,13,11,9,6,3,1,0,1,3,6,9,11,13,14,15
	dc.b	14,13,11,9,8
	dcb.b	60,8
	dc.b	7,7,6,6,5,5,4,4,3,2,1,0

	dc.b	1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15
	dc.b	14,14,14,13,13,13,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0

	dc.b	1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
	dc.b	14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0

	dc.b	0,15,0,14,0,13,0,12,0,11,0,10,0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0

	dc.b	0,1,2,3,4,5,6,8,10,12,14,15,15,15,15,15
	dcb.b	40,15

	dc.b	14,15,13,15,12,15,11,14,10,13,9,12,8,11,7,10,6,9,5,8,4,7,3,6,2,5,1,4,0,3,0,2,0,1,0,0,0
	dc.b	1,0,2,0,3,0,4,1,5,2,6,3,7,4,8,5,9,6,10,7,11,8,12,9,13,10,14,11,15,12,15,13,15,14,15,15,15
	dc.b	14,15,13,15,12,15,11,14,10,13,9,12,8,11,7,10,6,9,5,8,4,7,3,6,2,5,1,4,0,3,0,2,0,1,0,0,0
	dc.b	1,0,2,0,3,0,4,1,5,2,6,3,7,4,8,5,9,6,10,7,11,8,12,9,13,10,14,11,15,12,15,13,15,14,15,15,15
	dc.b	14,15,13,15,12,15,11,14,10,13,9,12,8,11,7,10,6,9,5,8,4,7,3,6,2,5,1,4,0,3,0,2,0,1,0,0,0
	dc.b	1,0,2,0,3,0,4,1,5,2,6,3,7,4,8,5,9,6,10,7,11,8,12,9,13,10,14,11,15,12,15,13,15,14,15,15,15
	dc.b	14,15,13,15,12,15,11,14,10,13,9,12,8,11,7,10,6,9,5,8,4,7,3,6,2,5,1,4,0,3,0,2,0,1,0,0,0
	dc.b	1,0,2,0,3,0,4,1,5,2,6,3,7,4,8,5,9,6,10,7,11,8,12,9,13,10,14,11,15,12,15,13,15,14,15,15,15

	dc.b	14,13,12,11,10,9,8,7,6,5,4,3,2,1

	dc.b	1,2,3,4,5,6,7,8,8,8,8,8,7,6,7,8,9,10,10,10,10,10,9,8,9,10,11,12,13,14,15,15,15,15
	dc.b	15,15,15,15,15,15,15,13,11,9,11,13,15,15,15,15,15
	dc.b	15,15,15,15,15,15,15,15,15,15,15,15

	dc.b	14,14,13,13,12,11,9,6,3,0,3,6,8,9,10,11,12,13,13
	dc.b	12,11,9,7,4,1,0,3,6,7,8,8
	dc.b	7,6,4,2,0,2,4,6,7,7
	dc.b	6,5,3,1,0,2,4,5,6,6
	dc.b	5,4,2,1,0,2,3,4,5,5
	dc.b	4,3,1,0,2,3,4,4
	dc.b	3,1,0,1,2,3,3
	dc.b	2,1,0,1,2,2
	dc.b	1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,13,13,14,14,14,15,15,15,15
	dc.b	14,14,14,14,13,13,13,13,12,12,12,12
	dc.b	11,11,11,11,10,10,10,10,9,9,9,9,8,8,8,8,7,7,7,7,6,6,6,6,5,5,5,4,4,4,3,3,2,2,1,0,0,0,0
	dcb.b	72,0
	dc.b	$ff
	even
logo:	incbin	"e:\ivor\erik1.dat"
	even

************ logo 2 data *******************
old_pos		dc.l	0
logo2_pointer	dc.l	init_logo2_table
init_logo2_table
	dcb.b	200,0
logo2_table
	dc.b	0,1,2,3,4,5,7,9,11,14,17,20
	dc.b	24,28,32,35
	dc.b	31,27,23
	dc.b	19,16,13,10,8,6,4,3,2,1
	dc.b	$ff
	even
logo2	incbin	e:\ivor\erik2.dat
	even
************ scroller stuff ******************
scroll_pointer:	dc.l	init_scroll_text+7
init_scroll_text
	dc.b	"                                 "
scroll_text:
 dc.b "ERIK PLANKTON PRESENTS HIS FIRST DEMO ON THE ATARI ST -"
 DC.B " THE 'IVOR BIGGUN' DEMO.   NOTE: THIS DEMO REQUIRES 1 MEG RAM          "
 DC.B "ALL CODING BY ERIK PLANKTON, "
 DC.B "MUSIC FOR THIS INTRO WAS RIPPED FROM AN ADVERT FOR THE DELIRIOUS "
 DC.B "DEMO AND WAS WRITTEN BY MAD MAX (OR AN-COOL), THE FONT WAS STOLEN "
 DC.B "FROM A 'PERSISTENCE OF VISION' MENU.     AS THIS IS "
 DC.B "MY FIRST DEMO ON THE ST I'D BETTER INTRODUCE MYSELF - I AM 14 YEARS OLD "
 DC.B "AND HAVE BEEN CODING FOR NEARLY 2 YEARS ON THE ST.  I "
 DC.B "NOTICED THAT THERE WAS A LOT OF SAMPLED SOUND DEMOS FLOATING "
 DC.B "ABOUT SO I DECIDED TO GET ON THE BAND WAGON AND WRITE ONE BUT "
 DC.B "INSTEAD OF USING COMPILED BASIC (CRAP) I'VE CODED IT IN 68000.  "
 DC.B "I WROTE THIS INTRO TO HELP IT STAND OUT OF THE CROWD AND TO ENSURE "
 DC.B "YOU GET YOUR PENNIES WORTH OUT OF P.D. AS THERE SEEMS TO BE A LOT OF RUBBISH "
 dc.b "FLOATING ABOUT.               "
 DC.B "I SEND MY GREETINGS TO -    THE LOST BOYS (GREAT MINDBOMB DEMO),   "
 DC.B "TCB (I THINK CUDDLY IS STILL THE BEST),   P.O.V. (GREAT DEMO COMPILATIONS),   "
 DC.B "DYNAMIC DUO,   SKUNK,   THE ISLANDER AND ALL OTHER DEMO "
 DC.B "WRITERS.     ON SATURDAY THE 15TH OF SEPTEMBER 1990 I WENT TO "
 DC.B "THE C.E.S. SHOW AT EARLS COURT, AFTER QUEUEING FOR 2 HOURS I "
 DC.B "FINALLY GOT IN. THERE WAS LOADS OF PEOPLE AT THE SHOW AND A "
 DC.B "NUMBER OF GROUPS, I SAW SAMMY JOE OF THE LOST BOYS, AN-COOL OF TCB, "
 DC.B "TWO P.O.V. MEMBERS AND A MEMBER OF THE EXCEPTIONS.  IF YOU "
 DC.B "WAS THERE ON THE MPH STAND THEN I PROBABLY SAW YOU TOO.   "
 DC.B "    RIGHT I CAN'T BE BOTHERED TYPING ANYMORE SO PRESS A KEY TO "
 DC.B "START THE DEMO......... BYE - E.P. 19-9-90 20:27.          "
 DC.B "         "
 dc.b	$ff,$ff
	even
char_offset	dc.w	0
font:	dcb.b	120,0
	incbin	"e:\ivor\was274.fnt"
	even
font_offsets:
 dc.b	0,41,43,0,0,0,0,46,44,45,0,0,38,42,39,48
 dc.b	27,28,29,30,31,32,33,34,35,36,40,0,0,0,0,47,0
 dc.b	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
 dc.b	41,0,42,0,0
	even

************* ivor pic bit ************
barrel_data
	dc.b	5,4,4,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,4,4,5
	dc.b	$ff
	dc.b	5,4,4,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,4,4,5
	even
barrel_offset	dc.l	offset_table
offset_table
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
	dc.w	21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
	dc.w	41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60
	dc.w	61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80
	dc.w	81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100
	dc.w	101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120
	dc.w	121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140
	dc.w	141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160
	dc.w	161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180
	dc.w	181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200
	dc.w	201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220
	dc.w	221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240
	dc.w	241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260
	dc.w	261,262,263,264,265
	dc.w	$ffff
	even

ivor_data
	dcb.w	(33*160),$ffff
ivor_pic
	incbin	e:\ivor\erikmain.pi1
	dcb.w	(33*160),$ffff
	even
	SECTION BSS
old_palette:	ds.w	16
eoc:
	ds.l	100
stack

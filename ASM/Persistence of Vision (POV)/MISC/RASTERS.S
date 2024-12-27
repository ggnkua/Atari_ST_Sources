
	bsr	set_super
	or.b	#$2,$ffff820a.w
	dc.w	$a00a
	move.b	#$12,$fffffc02.w
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	bsr	show_picture

	move.w	#$2700,sr
; Store original vector slots
	move.l	$120.w,hbc
	move.l	$70.w,v_blank
	move.b	$fffffa09.w,a09
	move.b	$fffffa07.w,a07
	move.b	$fffffa13.w,a13
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#new_120,$120.w
	move.l	#new_70,$70.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.w	#$2300,sr

	bsr	get_key

	bsr	isr_off

	bsr	set_old_palette
	bsr	set_med_rez
	move.b	#8,$fffffc02.w
	dc.w	$a009
	bsr	set_user

	clr.w	-(sp)
	trap	#1


new_120
	add.w	#1,line_count
	cmp.w	#200,line_count
	blt.s	.do
	clr.w	$ffff8240.w
	clr.w	.do+2
	rte
.do	move.w	#0,$ffff8240.w
	movem.l	d0/a0,-(sp)	;$120
	move.w	colour_offset,d0
	and.w	#1023,d0
	lea	colours,a0
	move.w	(a0,d0.w),.do+2
	add.w	#2,colour_offset
	movem.l	(sp)+,d0/a0
	rte

new_70	;$70
	clr.b	$fffffa1b.w	;di timer B
	add.w	#2,colour_offset_last_vbl
	move.w	colour_offset_last_vbl,colour_offset
	clr.w	vsync_flag
	clr.w	line_count
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

vsync:	move.w	#-1,vsync_flag
vsyn:	tst.w	vsync_flag
	bne.s	vsyn
	rts

***********************
* SUBROUTINES SECTION *
***********************

isr_off:
	move.w	#$2700,sr
	move.l	v_blank,$70.w
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	hbc,$120.w
	move.b	a07,$fffffa07.w
	move.b	a09,$fffffa09.w
	move.b	a13,$fffffa13.w
	move.w	#$2300,sr
	rts

tst_key:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

clear_screen:
	pea	CLS
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

set_super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

get_old_palette:
	lea	$ffff8240.w,a0
	lea	old_palette,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_new_palette:
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ffff8240.w,a1
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
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

show_picture:
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	rts

****************
* DATA SECTION *
****************
	SECTION DATA
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
CLS:		dc.b	27,'E',0,0
hbc:		dc.l	0
v_blank:	dc.l	0
a09:		dc.b	0
a07:		dc.b	0
a13:		dc.b	0
	even
vsync_flag:	dc.w	1
colour_offset_last_vbl	dc.w	0
colour_offset	dc.w	0
line_count	dc.w	0


isr_data	dc.l	colours
colours
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
 dc.w	$800,$180,$910,$290,$a20,$3a0,$b30,$4b0,$c40,$5c0,$d50,$6d0,$e60,$7e0,$f70
 dc.w	$ff0,$7f0,$ef0,$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0
 dc.w	$0f0,$070,$0e0,$060,$0d0,$050,$0c0,$040,$0b0,$030,$0a0,$020,$090,$010,$080
 dc.w	$001,$002,$003,$004,$005,$006,$007,$006,$005,$004,$003,$002,$001
 dc.w	-1


pic:	incbin	"pic.pi1"

	SECTION BSS
old_palette:	ds.w	16

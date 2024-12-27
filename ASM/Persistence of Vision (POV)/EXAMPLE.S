*************************************************************************
*	Example code by MAC SYS DATA of PERSISTENCE OF VISION
*
*	This code is meant as a simple example and not a maximum
*	efficient piece of code.
*
*
*
* M.S.D. 14/5/92
*

	bsr	set_super
	move.b	#$12,$fffffc02.w	;di mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	bsr	set_up		;create our own screens for compatability


wait	bsr	v_sync
	bsr	set_screen	;screen flip
;	move.w	#$123,$ffff8240.w
	bsr	print_grafic
;	move.w	pic+2,$ffff8240.w

	bsr	tst_key
	tst.l	d0
	beq.s	wait

	bsr	set_old_palette
	bsr	set_med_rez
	move.b	#$8,$fffffc02.w
	bsr	set_user

	clr.w	-(sp)
	trap	#1



*******************
* CUSTOM ROUTINES *
*******************
print_grafic	;print a grafic from NEO cut buffer

		lea	neo_cut+32,a0	;start of logo
		move.l	scr_now,a1	;get present screen base
		move.w	#$21-1,d0	;grafic is $21 lines deep
.loop		move.l	(a0)+,(a1)+	;move 2 planes
		move.l	(a0)+,(a1)+	;move next 2 planes

		move.l	(a0)+,(a1)+	;2nd word
		move.l	(a0)+,(a1)+

		move.l	(a0)+,(a1)+	;3rd
		move.l	(a0)+,(a1)+

		add.w	#160-(3*8),a1	;add to screen to goto start of next line down

		dbf	d0,.loop
		rts

***********************
* SUBROUTINES SECTION *
***********************
v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
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

get_old_palette
	lea	$ffff8240.w,a0
	lea	old_palette,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

set_new_palette
	lea	neo_cut,a0
	bra	set_pal
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
	move.l	d0,screen_base
	rts

get_original_rez
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_low_rez
	clr.w	-(sp)
	bra	set_rez
set_med_rez
	move.w	#1,-(sp)
set_rez	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now
	move.l	d0,d1
	add.l	#32000,d1
	eor.l	d0,d1
	move.l	d1,scr_xor

set_screen
	move.l	scr_now,d6
	move.l	scr_xor,d7
	eor.l	d7,d6
	move.l	d6,scr_now
	lsr.l	#8,d6
	lea	$ffff8201.w,a6
	movep.w	d6,(a6)
	rts

*******************
   SECTION DATA
*******************
;Mike, here is the NEO cut buffer, it says that it is $21 (33) pixels wide
;  so as 1 word is 16 pixels then the logo is 3 words wide (okay).
;
;  The logo depth is $21 lines high.
;
;

neo_cut
*
*  NEOchrome cut buffer contents (left justified):
*
*    pixels/scanline    = $0021 - 33 decimal (bytes/scanline: $0018 - 24 decimal)
*  # scanlines (height) = $0021 - 33 decimal
*
*  Hardware color pallet  (color 0 to 15):
*
pal	dc.w	$0002,$0003,$0004,$0005,$0006,$0007,$0700,$0730
	dc.w	$0740,$0760,$0222,$0750,$0333,$0444,$0666,$0777
*
*
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$03FF,$03FF,$0000
	dc.w	$0000,$FFC0,$FFC0,$0000,$0000,$0000,$0000,$0000
	dc.w	$019F,$0FFF,$0FFF,$0000,$F980,$FFF0,$FFF0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0730,$1F70,$1F70,$008F
	dc.w	$0CE0,$0EF8,$0EF8,$F100,$0000,$0000,$0000,$0000
	dc.w	$0C27,$1C67,$1C60,$039F,$E430,$E638,$0638,$F9C0
	dc.w	$0000,$0000,$0000,$0000,$09AF,$39EC,$3860,$079F
	dc.w	$F590,$379C,$061C,$F9E0,$0000,$0000,$0000,$0000
	dc.w	$1BAF,$3B68,$3860,$079F,$F5D8,$16DC,$061C,$F9E0
	dc.w	$0000,$0000,$0000,$0000,$0000,$3FFF,$3FFF,$0000
	dc.w	$0000,$FFFC,$FFFC,$0000,$0000,$0000,$0000,$0000
	dc.w	$1780,$3440,$3040,$0F80,$01E8,$022C,$020C,$01F0
	dc.w	$0000,$0000,$0000,$0000,$1780,$3640,$3040,$0F80
	dc.w	$01E8,$026C,$020C,$01F0,$0000,$0000,$0000,$0000
	dc.w	$1380,$33C0,$3040,$0F80,$01C8,$03CC,$020C,$01F0
	dc.w	$0000,$0000,$0000,$0000,$1800,$3840,$3840,$0780
	dc.w	$0018,$021C,$021C,$01E0,$0000,$0000,$0000,$0000
	dc.w	$0F80,$3FFF,$3FFF,$0000,$01F0,$FFFC,$FFFC,$0000
	dc.w	$0000,$0000,$0000,$0000,$003F,$3FFF,$3FFF,$0000
	dc.w	$FC00,$FFFC,$FFFC,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$3000,$3000,$0FFF,$0000,$000C,$000C,$FFF0
	dc.w	$0000,$0000,$0000,$0000,$07FF,$27FF,$2000,$1FFF
	dc.w	$FFE0,$FFE4,$0004,$FFF8,$0000,$0000,$0000,$0000
	dc.w	$0FFF,$2C00,$2000,$1FFF,$FFF0,$0034,$0004,$FFF8
	dc.w	$0000,$0000,$0000,$0000,$07FF,$27FF,$2000,$1FFF
	dc.w	$FFE0,$FFE4,$0004,$FFF8,$0000,$0000,$0000,$0000
	dc.w	$0000,$3000,$3000,$0FFF,$0000,$000C,$000C,$FFF0
	dc.w	$0000,$0000,$0000,$0000,$003F,$3FFF,$3FFF,$0000
	dc.w	$FC00,$FFFC,$FFFC,$0000,$0000,$0000,$0000,$0000
	dc.w	$0F80,$3FFF,$3FFF,$0000,$01F0,$FFFC,$FFFC,$0000
	dc.w	$0000,$0000,$0000,$0000,$1800,$3840,$3840,$0780
	dc.w	$0018,$021C,$021C,$01E0,$0000,$0000,$0000,$0000
	dc.w	$1380,$33C0,$3040,$0F80,$01C8,$03CC,$020C,$01F0
	dc.w	$0000,$0000,$0000,$0000,$1780,$3640,$3040,$0F80
	dc.w	$01E8,$026C,$020C,$01F0,$0000,$0000,$0000,$0000
	dc.w	$1780,$3640,$3040,$0F80,$01E8,$022C,$020C,$01F0
	dc.w	$0000,$0000,$0000,$0000,$0000,$3FC0,$3FC0,$0000
	dc.w	$0000,$03FC,$03FC,$0000,$0000,$0000,$0000,$0000
	dc.w	$1780,$3440,$3040,$0F80,$01E8,$022C,$020C,$01F0
	dc.w	$0000,$0000,$0000,$0000,$1780,$3640,$3040,$0F80
	dc.w	$01E8,$026C,$020C,$01F0,$0000,$0000,$0000,$0000
	dc.w	$1380,$33C0,$3040,$0F80,$01C8,$03CC,$020C,$01F0
	dc.w	$0000,$0000,$0000,$0000,$1800,$3840,$3840,$0780
	dc.w	$0018,$021C,$021C,$01E0,$0000,$0000,$0000,$0000
	dc.w	$0F00,$3FC0,$3FC0,$0000,$00F0,$03FC,$03FC,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$1F80,$1F80,$0000
	dc.w	$0000,$01F8,$01F8,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000




*******************
   SECTION BSS
*******************
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1


		ds.b	256
screens		ds.b	32000
		ds.b	32000

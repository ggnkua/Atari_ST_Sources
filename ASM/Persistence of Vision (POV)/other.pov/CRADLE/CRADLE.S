;Neutons cradle re-write

	bsr	set_super
	dc.w	$a00a
	move.b	#$12,$fffffc02.w
	bsr	get_oldbase
	move.l	oldbase,a0
	bsr	set_low_rez
	move.b	$484,old484
	move.b	#2,$484
	moveq	#0,d0
	move.w	d0,$ffff8240.w
	move.w	d0,$ffff825e.w
	lea	instructions1,a0
	bsr	print_string
	bsr	fadein
	bsr	sync100
	bsr	fadeout
	lea	instructions2,a0
	bsr	print_string
	bsr	fadein
	bsr	sync100
	bsr	fadeout

	bsr	calc_new_base

	move.l	screen_base,a1
	lea	screen,a0
	move.l	#screenend-screen,d1
	lsr.l	#2,d1	;/4
trans:	move.l	(a0)+,(a1)+
	sub.l	#1,d1
	bne.s	trans
	move.l	screen_base,a0
	bsr	set_low_rez

	bsr	set_new_palette

;************************************************************************
;*                              WARP                                    *
;*                              ----                                    *
;* Stolen by: MAC SYS DATA of P.O.V. 29/09/90 13:30                     *
;*      From: AUTOMATION disc 278                                       *
;* Include files:-                                                      *
;*                 WARP.IMG into TUNE                                   *
;************************************************************************

;****************************************************************
; There is more than one tune in this code....
; 0=tune 0
; 1=tune 1 (same as tune 0)
; 2=tune 2 - repeats a jingle

	move.l	#1,D0
	bsr	tune
	move.l	#tune+$8,$4da		;use VBL to play tune
wait:	move.w	v_count,d7
sy	bsr	v_sync
	sub.w	#1,d7
	bne.s	sy

;	move.w	#$123,$ffff8240.w
	bsr	flip_screen
;	move.w	pal,$ffff8240.w
	bsr	tst_key
	tst.l	d0
	beq.s	wait

	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	cmp.b	#27,d0
	beq.s	exit
	cmp.b	#" ",d0
	beq.s	reset
	cmp.b	#"-",d0
	beq.s	faster
	cmp.b	#"+",d0
	beq.s	slower
	bra.s	wait

faster	cmp.w	#10,v_count
	bge.s	wait
	add.w	#1,v_count
	bra.s	wait
slower	cmp.w	#1,v_count
	ble.s	wait
	sub.w	#1,v_count
	bra.s	wait

reset	move.l	4,a0
	jmp	(a0)

exit:	bsr	endmus
	move.l	oldbase,a0
	bsr	set_med_rez
	move.b	#$8,$fffffc02.w
	dc.w	$a009
	move.b	old484,$484
	bsr	set_user

	clr.w	-(sp)
	trap	#1
ERR:	bra.s	ERR


*******************
* CUSTOM ROUTINES *
*******************
flip_screen:
	tst.w	direction
	bne.s	backward
forward
	add.w	#1,screen_number
	move.w	screen_number,d0
	cmp.w	#10,d0
	bne.s	no_dir_change
	eor.w	#$ffff,direction
no_dir_change
	and.l	#$ff,d0
	mulu	#32000,d0
	move.l	screen_base,a0
	add.l	d0,a0
	move.l	a0,d0
	bsr	set_screen_address
	rts
backward
	sub.w	#1,screen_number
	move.w	screen_number,d0
	tst.w	d0
	bne.s	no_dir_change2
	eor.w	#$ffff,direction
no_dir_change2
	and.l	#$ff,d0
	mulu	#32000,d0
	move.l	screen_base,a0
	add.l	d0,a0
	move.l	a0,d0
	bsr	set_screen_address
	rts

set_screen_address
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	rts

***********************
* SUBROUTINES SECTION *
***********************
fadein	move.w	#7-1,d0
.loop	add.w	#$111,$ffff825e.w
	move.w	#4,d1
.loop2	bsr	v_sync
	dbf	d1,.loop2
	dbf	d0,.loop
	rts

fadeout	move.w	#7-1,d0
.loop	sub.w	#$111,$ffff825e.w
	move.w	#4,d1
.loop2	bsr	v_sync
	dbf	d1,.loop2
	dbf	d0,.loop
	rts

sync100	move.w	#100,d0
.loop	bsr	v_sync
	dbf	d0,.loop
	rts
v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

print_string
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
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

set_new_palette:
	lea	pal,a0
	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

get_oldbase:
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldbase
	rts

set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

calc_new_base:
;calc new screen address from BSS
	lea	screen,a0	;get buffer of 32000
	move.l	a0,d0
	clr.b	d0		;make screen on 256 byte boundary
	move.l	d0,screen_base	;save it
	rts

endmus:	clr.l	$4da
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


****************
* DATA SECTION *
****************
oldbase:	dc.l	0
pal	dc.w	$000,$210,$200,$730,$420,$070,$400,$010
	dc.w	$600,$410,$620,$776,$740,$040,$220,$030
stack_save:	dc.l	0
screen_base	dc.l	0
v_count		dc.w	3
direction	dc.w	0
screen_number	dc.w	0
old484		dc.w	0
tune:		incbin	g:\music\warp.img
instructions1	dc.b	27,'E'
	dc.b	27,'Y',32+8,32+11,"NEUTONS CRADLE DEMO"
	dc.b	27,'Y',32+9,32+11,"-------------------"
	dc.b	27,'Y',32+12,32+15,"Recoded by"
	dc.b	27,'Y',32+14,32+14,"MAC SYS DATA"
	dc.b	0

instructions2	dc.b	27,'E'
	dc.b	27,'Y',32+8,32+14,"INSTRUCTIONS"
	dc.b	27,'Y',32+9,32+14,"------------"
	dc.b	27,'Y',32+12,32+15,"+ = faster"
	dc.b	27,'Y',32+14,32+15,"- = slower"
	dc.b	27,'Y',32+16,32+11,"SPACE = exit"
	dc.b	0

	ds.b	256
screen	incbin	cradle\1.pic
	incbin	cradle\2.pic
	incbin	cradle\3.pic
	incbin	cradle\4.pic
	incbin	cradle\5.pic
	incbin	cradle\6.pic
	incbin	cradle\7.pic
	incbin	cradle\8.pic
	incbin	cradle\9.pic
	incbin	cradle\a.pic
	incbin	cradle\b.pic
screenend
* INFINITY DEVELOPMENTS intro.............


	bsr	set_super
	move.b	#$12,$fffffc02.w	;DI mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	bsr	set_up

	lea	routine_list,a0
do_routines
	tst.l	(a0)
	bmi.s	wait

	move.l	(a0)+,a1
	move.l	a0,-(sp)
	jsr	(a1)
	move.l	(sp)+,a0
	bra.s	do_routines



wait	bsr	get_key

	bsr	set_old_palette
	bsr	set_org_rez
	move.b	#$8,$fffffc02.w
	bsr	set_user

	clr.w	-(sp)
	trap	#1



*******************
* CUSTOM ROUTINES *
*******************
show_twinkle
	lea	dat1,a0
	move.w	#10-1,d0
.loop	bsr	v_sync3
	move.l	scr_now,a1
	add.w	#160*57+8,a1
	REPT	26
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	lea	160(a1),a1
	ENDR
	dbf	d0,.loop

	move.w	#6,d0
.delay	bsr	v_sync2
	dbf	d0,.delay
	rts


draw_triangle
	lea	triangle+8+(7*8*12),a0
	move.l	scr_now,a1
	add.w	#70*160+16,a1

	move.l	#%10000000000000001000000000000000,d7
	move.w	#16-1,d0
.bits	bsr	v_sync
	move.l	(a0),d1
	move.l	4(a0),d2
	and.l	d7,d1
	and.l	d7,d2
	move.l	d1,(a1)
	move.l	d2,4(a1)
	move.l	d7,d6
	lsr.l	#1,d7
	or.l	d6,d7
	dbf	d0,.bits
	add.w	#8,a0
	add.w	#8,a1

	move.w	#5-1,d5
.words	move.l	#%11000000000000001100000000000000,d7
	move.w	#8-1,d0
.bits2	bsr	v_sync
	move.l	(a0),d1
	move.l	4(a0),d2
	and.l	d7,d1
	and.l	d7,d2
	move.l	d1,(a1)
	move.l	d2,4(a1)
	move.l	d7,d6
	lsr.l	#1,d7
	or.l	d6,d7
	lsr.l	#1,d7
	or.l	d6,d7
	dbf	d0,.bits2
	addq	#8,a0
	addq	#8,a1
	dbf	d5,.words
	lea	8*13(a1),a1

	bsr	v_sync2
	move.w	#3-1,d5
.x1	bsr	v_sync2
	REPT	7
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDR
	lea	8*13(a1),a1
	dbf	d5,.x1

	move.w	#4-1,d5
.x2	bsr	v_sync2
	REPT	7
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDR
	lea	8*13(a1),a1
	REPT	7
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDR
	lea	8*13(a1),a1
	dbf	d5,.x2

	move.w	#84/3-1,d0
.down	bsr	v_sync2
	REPT	3
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a1)
	lea	12*4(a1),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	8*13(a1),a1
	ENDR
	dbf	d0,.down
	rts


split_triangle
	lea	dat3,a0
	move.w	#9-1,d0		;9 frames
.loop	bsr	v_sync3
	move.l	scr_now,a1
	add.w	#160*58+40,a1
	REPT	60
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	move.l	(a0)+,16(a1)
	move.l	(a0)+,20(a1)
	lea	160(a1),a1
	ENDR
	dbf	d0,.loop
	rts


bounce_ball
	lea	bounce_table,a2

.bounce	bsr	v_sync

	lea	dat3+(8*24*60),a0
	move.l	scr_now,a1
	add.w	#160*58+40,a1
	REPT	8
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	move.l	(a0)+,16(a1)
	move.l	(a0)+,20(a1)
	lea	160(a1),a1
	ENDR

	lea	pic+34+(8*3)-160*6,a3
	lea	ball,a0
	move.l	scr_now,a1
	add.w	#8*3,a1
	sub.w	#39*160,a1
	move.w	(a2)+,d4
	bmi	.stop
	and.l	#$ff,d4
	mulu	#160,d4
	add.w	d4,a1
	add.w	d4,a3

	lea	ball,a0
	REPT	33
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)
	move.l	(a0)+,16(a1)
	move.l	(a0)+,20(a1)
	lea	160(a1),a1
	ENDR
	REPT	12
	move.l	(a3),d1
	or.l	(a0)+,d1
	move.l	d1,(a1)
	move.l	4(a3),d1
	or.l	(a0)+,d1
	move.l	d1,4(a1)
	move.l	8(a3),d1
	or.l	(a0)+,d1
	move.l	d1,8(a1)
	move.l	12(a3),d1
	or.l	(a0)+,d1
	move.l	d1,12(a1)
	move.l	16(a3),d1
	or.l	(a0)+,d1
	move.l	d1,16(a1)
	move.l	20(a3),d1
	or.l	(a0)+,d1
	move.l	d1,20(a1)
	lea	160(a1),a1
	lea	160(a3),a3
	ENDR
	dbf	d0,.bounce
.stop	rts

flash_ball
	lea	flash,a0
	lea	flash_pals,a3


	move.w	#4-1,d0
.loop	bsr	v_sync3

	move.l	(a3)+,$ffff8240+2.w
	move.l	(a3)+,$ffff8240+6.w
	move.l	(a3)+,$ffff8240+10.w
	move.l	(a3)+,$ffff8240+14.w

	move.l	scr_now,a1
	add.w	#2*8,a1

	REPT	65
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)

	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)

	move.l	(a0)+,16(a1)
	move.l	(a0)+,20(a1)

	move.l	(a0)+,24(a1)
	move.l	(a0)+,28(a1)

	move.l	(a0)+,32(a1)
	move.l	(a0)+,36(a1)
	lea	160(a1),a1
	ENDR
	dbf	d0,.loop

	move.l	pic+4,$ffff8240+2.w
	move.l	pic+8,$ffff8240+6.w
	move.l	pic+12,$ffff8240+10.w
	move.l	pic+16,$ffff8240+14.w
	rts


fade_infinity
	lea	infinity_text,a0

	move.w	#6-1,d0
.loop	bsr	v_sync3
	move.l	scr_now,a1
	lea	160*92+(8*8)(a1),a1

	REPT	54
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)

	move.l	(a0)+,8(a1)
	move.l	(a0)+,12(a1)

	move.l	(a0)+,16(a1)
	move.l	(a0)+,20(a1)

	move.l	(a0)+,24(a1)
	move.l	(a0)+,28(a1)

	move.l	(a0)+,32(a1)
	move.l	(a0)+,36(a1)

	move.l	(a0)+,40(a1)
	move.l	(a0)+,44(a1)

	move.l	(a0)+,48(a1)
	move.l	(a0)+,52(a1)

	move.l	(a0)+,56(a1)
	move.l	(a0)+,60(a1)

	move.l	(a0)+,64(a1)
	move.l	(a0)+,68(a1)

	move.l	(a0)+,72(a1)
	move.l	(a0)+,76(a1)

	move.l	(a0)+,80(a1)
	move.l	(a0)+,84(a1)

	lea	160(a1),a1
	ENDR
	dbf	d0,.loop
	rts

	
***********************
* SUBROUTINES SECTION *
***********************
v_sync3
	bsr	v_sync
v_sync2
	bsr	v_sync
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
	lea	pic+2,a0
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
set_org_rez
	move.w	original_rez,-(sp)
set_rez	move.l	screen_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,scr_now

set_screen
	move.l	scr_now,d6
	lsr.l	#8,d6
	lea	$ffff8201.w,a6
	movep.w	d6,(a6)
	rts

*******************
   SECTION DATA
*******************
routine_list	dc.l	show_twinkle
		dc.l	draw_triangle
		dc.l	split_triangle
		dc.l	bounce_ball
		dc.l	flash_ball
		dc.l	fade_infinity
		dc.l	-1

pic	incbin	"in.pi1"


dat1	incbin	1.dat

triangle	incbin	2.dat

dat3	incbin	3.dat

ball	incbin	ball.dat

bounce_table	dc.w	0,1,2,4,6,8,10,12,14,17,20,23,27,30,33,36
		dc.w	40,44,48,52,56,60,64,60,56,52,48,44,40,36
		dc.w	33,30,27,24,21,18,16,14,12,10,8,7,6,5,4,3,2,2,3

		dc.w	4,5,6,8,10,12,14,17,20,23,27,30,33,36
		dc.w	40,44,48,52,56,60,64,60,56,52,48,45,42,40
		dc.w	38,37,36,35,34,34,34,34,35,35,36,37,38,40
		dc.w	42,44,48,52,56,60,64,61,58,56,54,53,52,51,50
		dc.w	49,48,47
		dc.w	-1

flash		incbin	flash.dat
flash_pals	dc.w	$666,$666,$666,$666,$666,$667,$767,$767
		dc.w	$545,$545,$546,$656,$656,$657,$767,$767
		dc.w	$334,$434,$435,$535,$546,$647,$757,$757
		dc.w	$213,$313,$314,$425,$536,$637,$747,$757

infinity_text	incbin	in_fade1.dat
		incbin	in_fade2.dat

*******************
   SECTION BSS
*******************
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1

		ds.b	256
		ds.b	160*39
screens		ds.b	32000


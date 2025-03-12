 
*********************
   SECTION TEXT
*********************

	bsr	set_super
	move.b	#$12,$fffffc02.w	;DI mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	bsr	set_up

	bsr	set_screen	;screen flip
	bsr	do_sequence

wait	bsr	tst_key
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
do_sequence
		move.w	#11-1,d7
		lea	grafix,a0
.loop		bsr	v_sync
		bsr	v_sync
		bsr	.do_single
		dbf	d7,.loop
		move.w	#20-1,d7
.wait		bsr	v_sync
		bsr	v_sync
		dbf	d7,.wait
		move.w	#(30-11)-1,d7
.loop2		bsr	v_sync
		bsr	v_sync
		bsr	v_sync
		bsr	.do_single
		dbf	d7,.loop2

		rts

.do_single	move.l	scr_now,a1
		lea	80*160(a1),a1 q
		move.w	#29-1,d0
.do		REPT	20
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		ENDR
		dbf	d0,.do
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

	lea	pic+34,a0
	move.l	scr_now,a1
	move.l	a1,a2
	add.l	#32000,a2
	move.w	#32000/4-1,d0
sho	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,sho

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
pic	incbin	"main.pi1"

grafix	incbin	sequence.adr

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

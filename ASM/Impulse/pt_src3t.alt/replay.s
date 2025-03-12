;Example program how to use PT_SRC50.S
;Generates a 50 Hz interrupt using TimerA.
; made by: Lance
	opt	a+,o+

	pea	sup_rout
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

sup_rout	bsr	mt_init
	bsr	init_inter
main	bsr	wait_sync
	bsr	mt_update
; call lower priority TRASH routs from here ->
	cmp.b	#185,$fffffc02.w
	bne.s	main

	bsr	stop_inter

	bsr	mt_end

	rts

wait_sync	clr.w	sync
.wait_sync	tst.w	sync
	beq.s	.wait_sync
	rts

init_inter	lea	$fffffa00.w,a6

	move.w	#$2700,sr

	lea	save_eab,a0
	movep.w	$7(a6),d0
	move.w	d0,(a0)

	lea	save_mab,a0
	movep.w	$13(a6),d0
	move.w	d0,(a0)

	moveq	#$20,d0
	or.b	d0,$7(a6)
	or.b	d0,$13(a6)

	bclr.b	#5,$f(a6)

	lea	save_TimerA,a0
	move.l	$134.w,(a0)
	lea	TimerA,a0
	move.l	a0,$134.w

	lea	save_TADR,a0
	move.b	$1f(a6),(a0)
	lea	save_TACR,a0
	move.b	$19(a6),(a0)

	move.b	#1,$1f(a6)
	move.b	#8,$19(a6)

	move.l	mt_replay_frames,d0
	lea	$ffff8900.w,a0
	movep.l	d0,$1(a0)
	add.l	mt_replay_len,d0
	movep.l	d0,$d(a0)
	move.w	mt_frequency,$20(a0)
	move.w	#1,(a0)
	move.w	#$2300,sr

	rts

stop_inter	move.w	#$2700,sr
	lea	$fffffa00.w,a6

	move.w	save_eab,d0
	movep.w	d0,$7(a6)
 
	move.w	save_mab,d0
	movep.w	d0,$13(a6)

	move.l	save_TimerA,$134.w
	move.b	save_TADR,$1f(a6)
	move.b	save_TACR,$19(a6)
	move.w	#$2300,sr
	clr.w	$ffff8900.w
	rts

TimerA	movem.l	d0-d7/a0-a6,-(sp)
	move.w	sr,d0
	move.w	(sp),d1
	andi.w	#$f8ff,d0
	andi.w	#$0700,d1
	or.w	d0,d1
	move.w	d1,sr
	lea	sync,a0
	move.w	#$ffff,(a0)
	bclr.b	#5,$fffffa0f.w
	bsr	mt_vbl
; your cool code from here ->
	movem.l	(sp)+,d0-d7/a0-a6
	rte
sync	dc.w	0
save_eab	dc.w	0
save_mab	dc.w	0
save_TACR	dc.w	0
save_TADR	dc.w	0
save_TimerA	dc.l	0
	include	"pt_src3t\pt_src50.s"

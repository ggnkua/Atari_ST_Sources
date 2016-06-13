;Uses the VBL as 50 Hz (colour monitors only)

	opt	a+,o+

	pea	sup_rout
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

sup_rout
	lea	save_sync,a0
	move.w	$448.w,(a0)+
	move.w	$ffff820a.w,(a0)+

	move.w	#$ff,$448.w
	or.b	#$2,$ffff820a.w	

	bsr	mt_init

main	bsr	wait_sync
	bsr	mt_Paula
	bsr	mt_music
	cmp.b	#185,$fffffc02.w
	bne.s	main
	
	bsr	mt_end

	lea	save_sync,a0
	move.w	(a0)+,$448.w
	move.w	(a0)+,$ffff820a.w

	rts

wait_sync	move.l	$466.w,d0	;System friendly VBL wait
.wait_sync	cmp.l	$466.w,d0
	beq.s	.wait_sync
	rts
save_sync	dc.w	0,0

	include	"m:\pt_rep\pt_rep.s"

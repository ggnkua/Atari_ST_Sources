;Example program how to use PT_SRC**.S.
;this source shows you how much time PT_SRC50.S takes
;formula for calcuating the time in procents:
;n = the number of raster lines the routine takes
; % = 200*n/625
	opt	a+,o+

	pea	sup_rout
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

sup_rout	bsr	mt_init

main	bsr	wait_sync

	lea	$ffff8209.w,a6	;wait until the screen
	move.b	(a6),d0	;starts drawings
.clop	cmp.b	(a6),d0
	beq.s	.clop
	not.w	$ffff8240.w	;invert pal
	bsr	mt_Paula
	not.w	$ffff8240.w	;restore pal
	bsr	mt_music
	cmp.b	#185,$fffffc02.w
	bne.s	main

	bsr	mt_end
	rts

wait_sync
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts

	include	"pt_src3\pt_src50.s"

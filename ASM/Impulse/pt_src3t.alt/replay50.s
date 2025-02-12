;Example program how to use PT_SRC50.S.
;this source shows you how much time PT_SRC50.S takes
;formula for calcuating the time in procents:
;n = the number of raster lines the routine takes
; % = 200*n/625
	opt	a+,o+,ow-
	include	d:\coding.s\misc\bits\030cache.s
	pea	sup_rout
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

sup_rout
	MOVE.L 	#ENABLE_DATA_CACHE,D0
	MOVEC.L	D0,CACR

	bsr	mt_init
	lea	save_vbi,a0
	move.l	$70.w,(a0)
	lea	vbl,a0
	move.l	a0,$70.w
	
main	bsr	wait_sync

	lea	$ffff8209.w,a6	;wait until the screen
	move.b	(a6),d0	;starts drawings
.clop	cmp.b	(a6),d0
	beq.s	.clop
	not.w	$ffff8240.w
	bsr	mt_update
; call lower priority TRASH routs from here ->
	not.w	$ffff8240.w
	cmp.b	#185,$fffffc02.w
	bne.s	main

	move.l	save_vbi,$70.w
	bsr	mt_end
	rts

wait_sync
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts
vbl	movem.l	d0-d7/a0-a6,-(sp)
	bsr	mt_vbl	;must be first in vbl
; your cool code from here ->

	movem.l	(sp)+,d0-d7/a0-a6
	dc.w	$4ef9
save_vbi	dc.l	0
	include	"pt_src50.s"

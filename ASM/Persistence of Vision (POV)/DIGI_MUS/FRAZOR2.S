;************************************************************************
;* FRAZOR DIGI TUNE
;*
;* Stolen by: MAC SYS DATA of P.O.V.
;*
;* Include files:-
;*                 FRAZOR.MUS into TUNE
;************************************************************************

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk

	move.l	USP,a0
	move.l	a0,uspsave

	move.w	#$2700,sr
	lea	store,a0
	move.l	$fffffa06.w,(a0)+
	move.l	$fffffa12.w,(a0)+
	move.l	$fffffa18.w,(a0)+
	move.l	$134.w,(a0)+
	move.w	#$2300,sr

;****************************************************************
; There is only one tune in this code....

	moveq	#0,d0
	bsr	tune

	move.l	#tune+$6,$4d2.w

	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp

	clr.l	$4d2.w

	move.w	#$2700,sr
	lea	store,a0
	move.l	(a0)+,$fffffa06.w
	move.l	(a0)+,$fffffa12.w
	move.l	(a0)+,$fffffa18.w
	move.l	(a0)+,$134.w
	move.w	#$2300,sr

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
stop_tune
	move.l	uspsave,a6
	move.l	a6,USP

	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1


save_stk	ds.l	1
uspsave	ds.l	1

store	ds.l	18
tune
	incbin	"frazor2.MUS"
	even

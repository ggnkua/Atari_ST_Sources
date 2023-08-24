;************************************************************************
;* BLIP BLOPPER TUNE by ???
;*
;* Stolen by: MAC SYS DATA of P.O.V.
;*
;* Include files:-
;*                 BLIP.MUS into TUNE
;************************************************************************

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk

;****************************************************************
; There is only one tune in this code....
; 0=off music
; 1=tune 1

	moveq	#1,d0
	bsr	tune

	move.l	#tune+16,$4da

	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp

	clr.l	$4da
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
stop_tune
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1


save_stk	ds.l	1

tune
	incbin	"blip.MUS"
	even

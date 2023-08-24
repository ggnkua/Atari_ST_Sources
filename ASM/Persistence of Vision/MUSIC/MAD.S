;************************************************************************
;*                            MAD MAX                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 26/11/91 19:06                     *
;*      From: MAGGIE 5							*
;* Include files:-                                                      *
;*                 MAX.MUS into TUNE					*
;************************************************************************
;* MAD MAX music

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

	move.l	#tune+8,$4da

	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp

	clr.l	$4da
	moveq	#0,d0
	bsr	tune

stop_tune
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1


save_stk	ds.l	1

tune
	incbin	"mad.MUS"
	even

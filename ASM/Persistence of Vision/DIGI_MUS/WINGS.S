;************************************************************************
;*                          WINGS OF DEATH                              *
;*                          --------------                              *
;* Stolen by: MAC SYS DATA of P.O.V. 5/09/91 21:00                      *
;*      From: TOILET DEMO 2        					*
;* Include files:-                                                      *
;*			WINGS.MUS into TUNE				*
;************************************************************************
* MAD MAX digi-drum tune
*
* Note: NO digi-drum tune runs correctly under K_SEKA!!!!!!
*
*

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk

**** more than 1 tune here
*
* 1=main theme (brill)
* 2=tune 2
* 3=tune 3 - same as AUTOMATION 420
* 4=tune 4 (similar to 3)
* 5=tune 5
* 6=loader (PLEASE WAIT)
* 7=tune 7
* 8=no tune
* 9=tune 9
*10=tune 10
*11=tune 11

	moveq	#1,d0
	bsr	tune+$4
	bsr	tune+$8

	move.l	#tune,$4da
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp

	clr.l	$4da
	bsr	tune+$c

stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1


save_stk	ds.l	1

tune
	incbin	"wings.MUS"
	even

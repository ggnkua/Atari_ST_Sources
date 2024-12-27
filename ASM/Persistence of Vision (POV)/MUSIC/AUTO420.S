;************************************************************************
;*                       WINGS OF DEATH tune 3                          *
;*                       ---------------------                          *
;* Stolen by: MAC SYS DATA of P.O.V. 5/4/91 15:45                       *
;*      From: AUTOMATION disc 420a                                      *
;* Include files:-                                                      *
;*                 AUTO420.IMG into TUNE                                *
;************************************************************************
;* MAD MAX
;* DIGIDRUM tune uses 200Hz clock so use this driver only...
;*
;*
	clr.l	-(sp)		;set super mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stksv

	move.b	#2,$484		;off with keyclick/bell
;****************************************************************
; There is more than 1 tune in this code....
; 0=stop music
; 1=tune 1

	move.l	#1,D0
	BSR	tune+0
	BSR	tune+8

	move.l	#tune+4,$4da		;use VBL to play tune

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	bsr	ENDMUS
	clr.w	-(sp)
	trap	#1

ENDMUS:	clr.l	$4da
	bsr	tune+12
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts

stksv:	dc.l	0
tune	incbin	auto420.img"
	even
end:


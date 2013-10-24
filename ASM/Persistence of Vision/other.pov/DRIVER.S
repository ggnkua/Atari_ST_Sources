;************************************************************************
;*                             TITLE                                    *
;*                             -----                                    *
;* Stolen by: MAC SYS DATA of P.O.V. 00/00/00 00:00                     *
;*      From: AUTOMATION disc xx                                        *
;* Include files:-                                                      *
;*                 FILENAME.IMG into TUNE                               *
;************************************************************************

	clr.l	-(sp)		;set super mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stksv

	move.b	#2,$484		;off with keyclick/bell

;****************************************************************
; There is more than one tune in this code....
; 0=
; 1=
; 2=
	move.l	#1,D0
	BSR	tune
	move.l	#tune+2,$4d2		;use VBL to play tune

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

ENDMUS:	clr.l	$4D2
	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)
	clr.w	-(sp)
	trap	#1

stksv:	dc.l	0
tune	incbin	g:\sentry.xma\modules.xms\faster.xms




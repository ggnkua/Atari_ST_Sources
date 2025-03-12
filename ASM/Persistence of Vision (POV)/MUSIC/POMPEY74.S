;************************************************************************
;*                            UNKNOWN                                   *
;*                            -------                                   *
;* Stolen by: MAC SYS DATA of P.O.V. 30/06/91 16:25                     *
;*      From: POMPEY 74                                                 *
;* Include files:-                                                      *
;*                 POMPEY74.IMG into TUNE                               *
;************************************************************************

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stksv

	move.b	#2,$484		;off with keyclick/bell

;****************************************************************
; There is only one tune in this code....
; 1=menu 74
	move.b	#1,tune+4	
	move.l	#tune,$4d2		;use VBL to play tune
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
	rts


stksv:	dc.l	0
tune	incbin	g:\music\pompey74.img
end:


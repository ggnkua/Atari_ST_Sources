;************************************************************************
;*                      WRATH OF THE DEMONS				*
;*                      -------------------                             *
;* Stolen by: MAC SYS DATA of P.O.V. 14/08/91 19:28                     *
;*      From: AUTOMATION disc 464a                                      *
;* Include files:-                                                      *
;*                 464a.IMG into TUNE					*
;************************************************************************
;* music written by David Whittaker

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stksv

	move.b	#2,$484

;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION 464a
; 1=tune 1
; 2=tune 2
; 3=tune 3
; 4=tune 4
; 5=tune 5
; 6=tune 6
; 7=tune 7
; 8=tune 8
	move.l	#0,D0
	BSR	tune
	move.l	#tune+$e,$4d2		;use VBL to play tune

	rts

ENDMUS:	clr.l	$4D2
	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)
	rts

stksv:	dc.l	0
TUNE:	blk.b	10370
end:

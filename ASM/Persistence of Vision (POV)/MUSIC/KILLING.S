;************************************************************************
;*                       KILLING GAME SHOW                              *
;*                       -----------------                              *
;* Stolen by: MAC SYS DATA of P.O.V. 14/04/91 12:35                     *
;*      From: KILLING GAME SHOW DEMO FROM ST USER                       *
;* Include files:-                                                      *
;*                 KILLING.IMG into TUNE                                *
;************************************************************************
;* Tune written by COUNT ZERO 11/12/90
;*
;* Nic Alderton
;* 16 redington road
;* London
;* NW3 7RG
;*
;* TEL: 071-431-4915
;*
;*
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stksv

	move.b	#2,$484		;off with keyclick/bell

;****************************************************************
; There is more than one tune in this code....
; 0=Stop sound
; 1-21 =sound effects
; 22=tune 1
; 23=tune 2 (in game tune -ABSOLUTELY BRILLIANT!!!!!!!)
; 24=tune 3

	move.l	#24,D0
	BSR	tune
	move.l	#tune+2,$4d2		;use VBL to play tune
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	clr.l	$4D2

	lea	$ff8800,A0
	move.l	#$8080000,(A0)
	move.l	#$9090000,(A0)
	move.l	#$a0a0000,(A0)

	clr.w	-(sp)
	trap	#1

stksv:	dc.l	0
tune	incbin	killing.img
end:


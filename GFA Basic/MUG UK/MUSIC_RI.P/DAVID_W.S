;------------------------------------------------------
; David Whittaker Test Player by MUG U.K for Maggie 5.0
;------------------------------------------------------
;
; Alter the 'tune_no' to be the tune you want to hear.  Once you
; sussed out what first value in 'tune_no' screws up (ie. bombs !!)
; then enter that value into 'max_tune'.
;

tune_no	equ	0
max_tune	equ	8

super	clr.l -(a7)		; Supervisor Mode
	move.w #$20,-(a7)
	trap #1
	addq.l #6,a7
	move.l d0,old_sp		; store old value

	move.l #tune_no,D0		; we'll play 'tune_no'
	jsr play			; start music

wait	move.w #7,-(sp)		; wait for a key
	trap #1
	addq.l #2,sp

	jsr stop			; switch off music

	move.l #old_sp,-(a7)	; restore user mode
	move.w $20,-(a7)
	trap #1	
	addq.l #6,a7

	move.w #$4c,-(a7)		; and quit back to GenST
	trap #1

play	cmp.l #max_tune,d0	; Check 'tune_no' doesn't exceed max.
	bge exit

	bclr #0,$484	; key click off
	jsr music		; initialise music player with 'tune_no'

	move.l #music+$e,$4d6 ; Set address for the musics' VBL routine
exit	rts

stop	jsr music+$1c	; This calls DW's music off routine
	clr.l $4d6	; Clear this VBL address
	bset #0,$484.w	; Re-instate key click
	rts

old_sp	dc.l 0

;
; Change this to the David Whittaker file you require
;
music	incbin "dan_dare.inl"

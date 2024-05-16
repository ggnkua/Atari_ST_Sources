; TAO SOUNDCHIP PLAYER 1
; (C)1992 MORGAN/DUNE/ANARCHY

tune_no		equ	1
max_tune	equ	15

super	clr.l -(a7)		; Supervisor Mode
	move.w #$20,-(a7)
	trap #1
	addq.l #6,a7
	move.l d0,old_sp	; store old value

	move.l #tune_no,D0	; we'll play 'tune_no'
	jsr play		; start music

wait	move.w #7,-(sp)		; wait for a key
	trap #1
	addq.l #2,sp

	jsr stop		; switch off music

	move.l #old_sp,-(a7)	; restore user mode
	move.w $20,-(a7)
	trap #1	
	addq.l #6,a7

	move.w #$4c,-(a7)	; and quit back to GenST
	trap #1

play	cmp.l #max_tune,d0	; Check 'tune_no' doesn't exceed max.
	bge exit

	bclr #0,$484		; key click off
	jsr music		; initialise music player with 'tune_no'

	move.l #music+4,$4d6 ; Set address for the musics' VBL routine
exit	rts

stop
	move.l #0,D0		; we'll play 'tune_no'
	jsr music		; This calls TAO's music off routine
	clr.l $4d6		; Clear this VBL address
	bset #0,$484.w		; Re-instate key click
	rts

	section	data
;
; Change this to the TAO file you require
;
music	incbin A:\TAO1.ACF\feel_it.tao

	section	bss

old_sp	ds.l 1

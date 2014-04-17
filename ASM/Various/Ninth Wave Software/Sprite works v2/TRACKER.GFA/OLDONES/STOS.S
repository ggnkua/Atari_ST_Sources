;
; Ninja 3 Module Replay Routine
; -----------------------------
;
; GFA/STOS (?) Front-end by MUG U.K !!
;
; ST/STE & Falcon within 1 play routine


*= The replay test bit. =======================================================

	opt	o+,p+

start	bsr	on
	bsr	off

	dc.b	"Ninja Replayer v3.2 Frontend by MUG U.K!!",0
	even

on	lea	old_vbl(pc),a4
	move.l	$70.w,(a4)

	jsr	music(pc)
	jsr	music+4(pc)

	lea	new_vbl(pc),a4
	move.l	(a4),$70.w
	rts

;---------------------------

off	jsr	music+8(pc)
	lea	old_vbl(pc),a4
	move.l	(a4),$70.w
	rts

;------------------------

new_vbl	movem.l	a0-a4/d0-d6,-(a7)
;	move.w	#$770,$ffff8240.w
	jsr	music+12(pc)
;	move.w	#$777,$ffff8240.w
	movem.l	(a7)+,a0-a4/d0-d6
	rte


;------------------------

old_vbl	dc.l	0

	opt	p-


	section	data

music	incbin	'ninja342.bin'
	even


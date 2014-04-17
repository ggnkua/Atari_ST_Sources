; Ninja III interface code by MUG U.K
; -----------------------------------
;
; For: GFA BASIC v3.5 !!
;
; ~C:ninja%(l:module%,w:Khz&,w:Playback&)

	opt o+,p+

	bra	mod_on
	bra	mod_off
	
mod_on	movem.l	d1-7/a0-6,-(a7)
	move.l	60(a7),a0		Module address
	move.w	62(a7),d0		Khz rate
	move.w	64(a7),d1		Playback type

	bsr.s	super

	lea	old_vbl(pc),a4	; Store old vbl address
	move.l	$70.w,(a4)

	bsr.s	replay
	lea	new_vbl(pc),a4	; New vbl address
	move.l	(a4),$70.w
	bsr.s	replay+4

	bsr.s	user

	movem.l	(a7)+,d1-7/a0-6
	rts

mod_off	movem.l	d1-7/a0-6,-(a7)
	bsr.s	super
	bsr.s	replay+8
	lea	old_vbl(pc),a4	; Restore old vbl address
	move.l	(a4),$70.w
	bsr.s	user
	movem.l	(a7)+,d1-7/a0-6
	rts

new_vbl	movem.l	a0-a4/d0-d6,-(a7)
	bsr.s	replay+12
	movem.l	(a7)+,a0-a4/d0-d6
	rte

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	old_sp(pc),a4
	move.w	d0,(a4)
	rts

user	lea	old_sp(pc),a4
	move.l	(a4),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

old_vbl	ds.l	1
old_sp	ds.l	1

replay	incbin	'ninja342.bin'
	even
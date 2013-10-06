* play a sample...

	opt	x+,o-,ow-


	include	\includes\macros.s

	free_mem
	cls
	super_on

	lea	beat(pc),a0
	bsr	load_unsign	; load in the sample & de-sign it

	move.l	d0,beat_len
	move.l	a6,beat_address


* initialise sound chip
	move.w	#$8800,a0

	move.l	#init_mus,a2

do_init_mus:
	move.w	(a2)+,d0
	bmi.s	end_init_mus

	movep.w	d0,(a0)
	bra.s	do_init_mus

init_mus:
	dc.w	$0000
	dc.w	$0100
	dc.w	$0200
	dc.w	$0300
	dc.w	$0400
	dc.w	$0500
	dc.w	$0600
	dc.b	$07,%01111111
	dc.w	$0d00

	dc.w	-1

end_init_mus:


	move.l	beat_len,d0

	move.w	sr,-(a7)
	or.w	#$0700,sr

	move.w	#$8240,a4
	move.w	(a4),d2
	move.w	#$f00,d1
	
play:
	move.w	d1,(a4)

	moveq	#0,d7
	move.b	(a6)+,d7	; get sample byte
	add.w	d7,d7
	add.w	d7,d7

	move.l	#table,a5
	add.l	d7,a5		; get sound data

	move.b	(a5)+,voice_a
	move.b	(a5)+,voice_b
	move.b	(a5)+,voice_c

	movem.l	sound,d4-6
	movem.l	d4-6,$ffff8800.w

	move.w	d2,(a4)

* pause
	move.w	#85,d3
.wait:
	dbra	d3,.wait

	subq.l	#1,d0
	bne.s	play


	move.w	(a7)+,sr

* turn sound off!
	clr.b	voice_a
	clr.b	voice_b
	clr.b	voice_c

	movem.l	sound,d4-6
	movem.l	d4-6,$ffff8800.w


	super_off
	
	clr.w	-(a7)
	trap	#1

sound:
	dc.b	8,8
voice_a	dc.b	0,0
	dc.b	9,9
voice_b	dc.b	0,0
	dc.b	10,10
voice_c	dc.b	0,0
	

	include	\includes\samples.s

beat:
	dc.b	"\includes\sample_1.avr",0
	even

table:
	incbin	\includes\sound.bin


	section	bss

beat_len	ds.l	1
beat_address	ds.l	1

	old


	ds.b	5000
stack:

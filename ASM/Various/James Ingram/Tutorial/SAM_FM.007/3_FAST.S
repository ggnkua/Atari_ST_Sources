* play a sample...
* using interrupts!
* FAST player routine!
* by James Ingram, May 1994


	opt	x+,o-,ow-

count	equ	39
freq	equ	2


	include	\includes\macros.s

	free_mem

	super_on

	bsr	initialise

	keep_timers
* turn off timer C
	c_off

	lea	beat(pc),a0
	bsr	load_unsign	; load in the sample & de-sign it

	move.l	d0,beat_len
	move.l	d0,len

	move.l	a6,a0
	move.l	#sam_exp,a1
	move.l	a1,pointer
	move.l	a1,beat_address
	bsr	expand_sample	; convert sample bytes to sound chip data

* initialise sound chip
	init_chip


	clr.b	b_control	; timer B off!
	bclr	#3,vector.w	; Automatic end of interrupt mode!
	move.l	#my_120,$120.w

	bset	#bit_b,enable_a.w
	bset	#bit_b,mask_a.w		; mask it in

	move.b	#count,b_data.w		; set counter
	move.b	#freq,b_control.w	; set it going!

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7

	c_on
	restore_timers

* turn sound off!
	clr.b	voice_a
	clr.b	voice_b
	clr.b	voice_c

	movem.l	sound,d4-6
	movem.l	d4-6,$ffff8800.w

	bsr	restore

	super_off
	
	clr.w	-(a7)
	trap	#1


expand_sample:
* expand the sample
* a0 = sample addr
* a1 = expand buffer
* d0 = sample length

.loop:
	moveq	#0,d7
	move.b	(a0)+,d7	; get sample byte
	add.w	d7,d7
	add.w	d7,d7

	move.l	#table,a2
	add.l	d7,a2
	
	move.b	(a2)+,voice_a
	move.b	(a2)+,voice_b
	move.b	(a2)+,voice_c

	movem.l	sound,d5-7
	movem.l	d5-7,(a1)
	lea	12(a1),a1

	subq.l	#1,d0
	bne.s	.loop


	rts


	
my_120:
	move.w	#$f00,$ffff8240.w

	move.l	a6,-(a7)

	move.l	pointer,a6

	move.l	(a6)+,$ffff8800.w
	move.l	(a6)+,$ffff8800.w
	move.l	(a6)+,$ffff8800.w


	subq.l	#1,len
	bne.s	.not_end

	move.l	beat_address,a6
	move.l	beat_len,len

.not_end:
	move.l	a6,pointer

	move.l	(a7)+,a6
	move.w	#$fff,$ffff8240.w

	rte

sound:
	dc.b	8,8
voice_a	dc.b	0,0
	dc.b	9,9
voice_b	dc.b	0,0
	dc.b	10,10
voice_c	dc.b	0,0
	

	include	\includes\samples.s
	include	\includes\init.s

beat:
	dc.b	"\includes\sample_1.avr",0
	even

table:
	incbin	\includes\sound.bin


	section	bss

beat_len	ds.l	1
beat_address	ds.l	1
pointer	ds.l	1
len	ds.l	1

	old

sam_exp:
	ds.b	24578*12
bbb:

	ds.b	5000
stack:

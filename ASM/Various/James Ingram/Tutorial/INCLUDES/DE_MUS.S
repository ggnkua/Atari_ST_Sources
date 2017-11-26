* routine to de-compress the music data
* will also re-arrange from seperate channels back into
* one long list.

de_mus:

	move.l	#comp_music,a0	; get addr of compressed music
	move.l	#music_data,a1	; addr to put it at

	moveq	#11-1,d0	; no of channels to do

.all:
	pea	(a1)		; keep addr of music data
	moveq	#0,d1		; counter - bytes put in so far for this channel!
.channel:
	cmp.w	#$1002,d1
	beq	.end_chan

	move.b	(a0)+,d7	; get byte
	btst	#7,d7
	beq.s	.list		; branch if list

* Got a block!
	bclr	#7,d7
	tst.b	d7
	bne.s	.not_128

* 0 = 128 bytes!
	move.w	#128,d7

.not_128:
* get byte from data
	move.b	(a0)+,d6

* slap it in...
.slap:
	move.b	d6,(a1)
	lea	11(a1),a1
	addq.w	#1,d1
	subq.w	#1,d7
	bne.s	.slap

	bra.s	.channel

.list:
	tst.b	d7
	bne.s	.not_128_2

* 0 = 128 bytes!
	move.w	#128,d7

.not_128_2:
* now slap in data from list...
.slap2:
	move.b	(a0)+,(a1)
	lea	11(a1),a1
	addq.w	#1,d1
	subq.w	#1,d7
	bne.s	.slap2

	bra.s	.channel

.end_chan:
	move.l	(a7)+,a1
	addq.l	#1,a1
	dbra	d0,.all
	rts

comp_music:
	incbin	\includes\mus.cmp
	even

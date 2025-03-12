* convert MUS.DAT to seperate out each channel....

	opt	x+,o-,ow-

	move.l	#music,a0
	move.l	#my_mus,a1
	
	moveq	#11-1,d1		; do all channels
all_chans:
	pea	(a0)			; keep addr in music
	move.w	#chan_len-1,d0		; do all channel data
.one_chan:
	move.b	(a0),(a1)+		; store 1 byte
	lea	11(a0),a0		; next byte in channel
	dbra	d0,.one_chan

	move.l	(a7)+,a0		; get music addr back
	addq.l	#1,a0			; next channel data
	dbra	d1,all_chans


	lea	chan(pc),a0
	move.l	#my_mus,a1
	move.l	#mus_len,d0
	bsr	save_file

	clr.w	-(a7)
	trap	#1

chan:	dc.b	"channel.bin",0


	include	\includes\save.s

music:
	incbin	mus.bin
mus_len	equ	*-music
chan_len	equ	mus_len/11

	section	bss
my_mus:
	ds.b	mus_len

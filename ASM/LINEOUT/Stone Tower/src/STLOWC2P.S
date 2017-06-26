	bsr	INIT_STLOWC2PTABLE

	clr.w	-(sp)
	trap	#1

* Initializes a <<chunky -2- planar>> lookup table for ST-LOW.
* Chunky buffer   = 160*100 4bpp
* Bitplane buffer = 320*200 4bpl (word interleaved)
INIT_STLOWC2PTABLE:
	lea	temp_buf,a0
	lea	.mask_tbl(pc),a1
	moveq	#0,d7

.loop:	move.w	d7,d1
	moveq	#16-1,d6
	moveq	#0,d0
	movea.l	a1,a2

.bitloop:
	add.w	d1,d1
	bcc.s	.nosetbit
	move.l	(a2)+,d2
	or.l	d2,d0
	dbra	d6,.bitloop
	bra.s	.endbitloop
.nosetbit:
	addq	#4,a2
	dbra	d6,.bitloop
.endbitloop:

	move.l	d0,(a0)+
	addq.w	#1,d7
	bne.s	.loop
	rts

* 100*20 = 2000 chunks to go...
* INPUT: a0: screenbuffer address
*        a1: chunkybuffer address
PLOT_STLOWC2P:
	lea	temp_buf+((1<<18)/2),a2
	lea	160(a0),a3
	move.w	#160*100/8-1,d7
.loop:	movem.w	(a1)+,d0-d1			* 20
	add.l	d0,d0			* 4
	add.l	d1,d1			* 4
	add.l	d0,d0			* 4
	add.l	d1,d1			* 4
	move.l	(a2,d0.l),d0			* 18
	move.l	(a2,d1.l),d1			* 18
	movep.l	d0,(a0)			* 24
	movep.l	d1,1(a0)			* 24
	move.l	(a0)+,(a3)+			* 20
	move.l	(a0)+,(a3)+			* 20
* 160 * 2000 = 320000 cycles per frame (2 vbl on ST)
	dbra	d7,.loop
	rts

.mask_tbl:
	DC.L	$c0000000,$00c00000,$0000c000,$000000c0
	DC.L	$30000000,$00300000,$00003000,$00000030
	DC.L	$0c000000,$000c0000,$00000c00,$0000000c
	DC.L	$03000000,$00030000,$00000300,$00000003

	BSS

temp_buf:
	DS.L	1<<16

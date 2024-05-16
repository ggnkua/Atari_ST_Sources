	COMMENT	HEAD=%111

degassize:	=	32066
cutstartblock:	=	0
cutstartline:	=	0
cutblocks:	=	4
cutlines:	=	64
cutblocksize:	=	cutblocks*8*cutlines

	bra	START

	INCLUDE	IO.S
	TEXT

START:	lea	picturefile_txt,a0
	lea	pic_buf,a1
	move.l	#degassize,d0
	bsr	load

	lea	pic_buf,a1
	lea	texture_buf,a0
	bsr	CUT_TEXTURE

	lea	palfile_txt,a0
	lea	pic_buf+2,a1
	moveq	#32,d0
	bsr	save

	lea	texture_buf,a1
	lea	shifttxt_buf,a0
	bsr	SHIFT_TEXTURE

	lea	shifttxt_buf,a1
	lea	texturefile_txt,a0
	move.l	#cutblocksize*4,d0
	bsr	save

	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

CUT_TEXTURE:
	lea	34+cutstartblock*8+cutstartline*160(a1),a1
	move.l	#-cutblocks*8+160,d5
	moveq	#cutlines-1,d7

.yloop:	moveq	#cutblocks-1,d6

.xloop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d6,.xloop

	adda.l	d5,a1
	dbra	d7,.yloop
	rts

* Make two versions of the original 4 bpl texture.
* Version 1: one byte per pixel, byte contains left shifted nibble.
* Version 2: one byte per pixel, byte contains right shifted nibble.
SHIFT_TEXTURE:
	lea	.nibble_buf,a2
	move.w	#cutblocksize/8-1,d7
.convloop:
	move.w	d7,-(sp)
	movem.w	(a1)+,d0-d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#8-1,d6
	moveq	#31-3,d7

.convbitloop:
	add.w	d0,d0
	bcc.s	.skipbpl0
	bset	d7,d4
.skipbpl0:
	addq.w	#1,d7
	add.w	d1,d1
	bcc.s	.skipbpl1
	bset	d7,d4
.skipbpl1:
	addq.w	#1,d7
	add.w	d2,d2
	bcc.s	.skipbpl2
	bset	d7,d4
.skipbpl2:
	addq.w	#1,d7
	add.w	d3,d3
	bcc.s	.skipbpl3
	bset	d7,d4
.skipbpl3:
	subq.w	#7,d7
	dbra	d6,.convbitloop

	move.l	d4,(a2)+
	moveq	#8-1,d6
	moveq	#31-3,d7
	moveq	#0,d4

.convbit2loop:
	add.w	d0,d0
	bcc.s	.skipbpl20
	bset	d7,d4
.skipbpl20:
	addq.w	#1,d7
	add.w	d1,d1
	bcc.s	.skipbpl21
	bset	d7,d4
.skipbpl21:
	addq.w	#1,d7
	add.w	d2,d2
	bcc.s	.skipbpl22
	bset	d7,d4
.skipbpl22:
	addq.w	#1,d7
	add.w	d3,d3
	bcc.s	.skipbpl23
	bset	d7,d4
.skipbpl23:
	subq.w	#7,d7
	dbra	d6,.convbit2loop

	move.l	d4,(a2)+
	move.w	(sp)+,d7
	dbra	d7,.convloop

	lea	.nibble_buf,a1
	lea	cutblocksize*2(a0),a2
	moveq	#$fffffff0,d4
	move.b	#$0000000f,d5
	move.w	#cutblocksize-1,d7

.loop:	move.b	(a1)+,d0
	move.b	d0,d1
	move.b	d0,d2
	move.b	d0,d3
	and.b	d4,d0
	lsr.b	#4,d1
	lsl.b	#4,d2
	and.b	d5,d3
	move.b	d0,(a0)+
	move.b	d1,(a2)+
	move.b	d2,(a0)+
	move.b	d3,(a2)+
	dbra	d7,.loop
	rts

	BSS

.nibble_buf:
	DS.B	cutblocksize

	TEXT

******** DATA AND INCLUDES ********

	DATA

picturefile_txt:
	DC.B	"F:\PICTURES\WALL-X64.PI1",0
texturefile_txt:
	DC.B	"D:\CODING\UCM15INT\DUNG100.RAW",0
palfile_txt:
	DC.B	"D:\CODING\UCM15INT\DUNGEON.PAL",0
	EVEN

******** RESERVES ********

	BSS

pic_buf:
	DS.B	degassize
texture_buf:
	DS.B	cutblocksize
shifttxt_buf:
	DS.B	cutblocksize*4
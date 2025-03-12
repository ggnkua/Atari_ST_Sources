	COMMENT	HEAD=%111

degassize:	=	32066
cutstartblock:	=	0
cutstartline:	=	64
cutblocks:	=	4
cutlines:	=	64

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

	lea	texturefile_txt,a0
	lea	texture_buf,a1
	move.l	#cutblocks*cutlines*8,d0
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

******** DATA AND INCLUDES ********

	DATA

picturefile_txt:
	DC.B	"F:\WALLTEXT.PI1",0
texturefile_txt:
	DC.B	"WALLTEXT.RAW",0
palfile_txt:
	DC.B	"WALLTEXT.PAL",0
	EVEN

******** RESERVES ********

	BSS

pic_buf:
	DS.B	degassize
texture_buf:
	DS.W	cutblocks*4*cutlines
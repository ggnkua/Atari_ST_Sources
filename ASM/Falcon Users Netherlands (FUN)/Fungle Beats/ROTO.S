START

	lea	texture_pic,a1
	adda.l	#(256*256)+256,a1
	bsr	PLOT_ROTOZOOM

	clr.w	-(sp)
	trap	#1

rotlinewidth	equ	320

* Routine that plots a rotozoom of a 256*256 highcolor texture. Uses
* precalculation of an offset-table.
* INPUT:	d0.w: 8.8 X-scale
*		d1.w: 8.8 Y-scale
*		d2.w: 8.8 X-start
*		d3.w: 8.8 Y-start
*		a1: address to center of texture
PLOT_ROTOZOOM
	lea	(a1),a6				* Backup texturestart.
	lea	.offset_tbl,a2
	movea.w	d2,a3				* Backup start-X.
	movea.w	d3,a4                           * Backup start-Y.
	moveq	#0,d2
	moveq	#0,d3
	move.w	#rotlinewidth-1,d7

.prelop	move.w	d3,d4
	move.w	d2,d5
	lsr.w	#8,d5
	move.b	d5,d4
	move.w	d4,(a2)+
	add.w	d0,d2
	add.w	d1,d3
	dbra	d7,.prelop

	move.l	scr,a0
;	lea	scrxbytes/2-....(a0),a0
	neg.w	d0
	move.w	a3,d2
	move.w	a4,d3
	move.w	#scrlines-1,d7

.yloop	lea	-rotlinewidth*2(a2),a2
	move.w	d3,d4
	move.w	d2,d5
	lsr.w	#8,d5
	move.b	d5,d4
	lea	(a6,d4.w*2),a1
	moveq	#rotlinewidth/4-1,d6
.xloop	movem.w	(a2)+,d4/d5/a3/a4
	move.w	(a1,d4.l*2),(a0)+
	move.w	(a1,d5.l*2),(a0)+
	move.w	(a1,a3.l*2),(a0)+
	move.w	(a1,a4.l*2),(a0)+
	dbra	d6,.xloop
	add.w	d0,d3
	add.w	d1,d2
	lea	scrxbytes-(rotlinewidth*2)(a0),a0
	dbra	d7,.yloop
	rts

	bss

.offset_tbl
	ds.w	rotolinewidth

	text

	data

texture_pic
	INCBIN	HOUT1.RAW

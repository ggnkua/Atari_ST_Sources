******************************************************************
**          S I M P L E    D A R K E N    F I L T E R           **
******************************************************************
** ESCAPE PAINT MODULE ** BY NORMAN FESKE (NO/ESCAPE)    07'96  **
******************************************************************


EVEN

darken_filter:
	;d0:	x1
	;d1:	y1
	;a0:	EP stucture

	;auf vsync warten
	movem.l	d0-a6,-(sp)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-a6

	move.l	d0,d2
	addq.l	#4,d2
	cmpi.l	#320,d2
	blt		xclip_ok
	move.l	#320-1,d2
xclip_ok:
	move.l	d1,d3
	addq.l	#4,d3
	cmpi.l	#240,d3
	blt		yclip_ok
	move.l	#240-1,d3
yclip_ok:

	subq.l	#4,d0
	bge		xclip0_ok
	moveq	#0,d0
xclip0_ok:
	subq.l	#4,d1
	bge		yclip0_ok
	moveq	#0,d1
yclip0_ok:
	
	;calculate width and height
	sub.l	d0, d2
	;d2:	width
	sub.l	d1, d3
	;d3:	height
	
	;calculate offset of the first pixel
	mulu.w	#320, d1								;offset = y*x_res+x
	add.l	d0, d1
	lsl.l	d1									;1 pixel = 1 word
	;d1:	screenoffset of the first pixel

	;calculate lineoffset (x_res - width)
	move.l	#320,d4
	sub.l	d2, d4
	subq.l	#1, d4
	lsl.l	#1, d4								;1 pixel = 1 word
	;d4:	lineoffset
	
	;get screenadress
	movea.l	(a0), a1

	;add screenoffset of the first pixel
	adda.l	d1, a1
	;a1:	adress of the first pixel
	
	;height (d3) is y-counter
darken_y_loop:
	
	;width (d2)is x-counter
	move.l	d2, d1
darken_x_loop:

	;darken pixel
	move.w	(a1), d7							;get pixel
	
	;darken red value
	move.w	d7, d5
	andi.l	#%1111100000000000, d5
	sub.l	#%0000100000000000, d5				;red - 1
	cmpi.l	#%0000100000000000, d5
	bge		red_ok								;red < 0 ?
	move.w	#%0000000000000000, d5
red_ok:

	;darken green value
	move.w	d7, d6
	andi.l	#%11111100000, d6
	sub.w	#%00001000000, d6					;green - 1
	cmpi.w	#%00000100000, d6
	bge		green_ok							;green < 0 ?
	move.w	#%00000000000, d6
green_ok:

	;darken blue value
	andi.w	#%11111, d7
	sub.w	#%00001, d7							;blue - 1
	cmpi.w	#%00001, d7
	bge		blue_ok								;blue < 0 ?
	move.w	#%00000, d7
blue_ok:

	;add values
	add.w	d5, d6								;red+green
	add.w	d6, d7								;red+green+blue=16bit
	;d7:	result: new 16bit value

	;set new pixel
	move.w	d7, (a1)+

	dbf		d1, darken_x_loop
	
	;add lineoffset
	adda.l	d4, a1
	
	dbf		d3, darken_y_loop
	
rts
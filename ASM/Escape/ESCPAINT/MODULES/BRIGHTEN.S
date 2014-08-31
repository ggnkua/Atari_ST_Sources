******************************************************************
**        S I M P L E    B R I G H T E N    F I L T E R         **
******************************************************************
** ESCAPE PAINT MODULE ** BY NORMAN FESKE (NO/ESCAPE)    07'96  **
******************************************************************


EVEN

brighten_filter:
	;d0:	x1
	;d1:	y1
	;d2:	x2
	;d3:	y2
	;a0:	EP stucture
	
	;calculate width and height
	sub.l	d0, d2
	;d2:	width
	sub.l	d1, d3
	;d3:	height
	
	move.l	#320,d4
	;d4:	x-resolution
	
	;calculate offset of the first pixel
	mulu.w	d4, d1								;offset = y*x_res+x
	add.l	d0, d1
	lsl.l	d1									;1 pixel = 1 word
	;d1:	screenoffset of the first pixel

	;calculate lineoffset (x_res - width)
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
brighten_y_loop:
	
	;width (d2)is x-counter
	move.l	d2, d1
brighten_x_loop:

	;brighten pixel
	move.w	(a1), d7							;get pixel
	
	;brighten red value
	move.w	d7, d5
	andi.l	#%1111100000000000, d5
	add.l	#%0000100000000000, d5				;red + 1
	cmpi.l	#%1111100000000000, d5
	ble		red_ok								;red > max ?
	move.w	#%1111100000000000, d5
red_ok:

	;brighten green value
	move.w	d7, d6
	andi.w	#%11111100000, d6
	add.w	#%00001000000, d6					;green + 1
	cmpi.w	#%11111100000, d6
	ble		green_ok							;green > max ?
	move.w	#%11111100000, d6
green_ok:

	;brighten blue value
	andi.w	#%11111, d7
	add.w	#%00001, d7							;blue + 1
	cmpi.w	#%11111, d7
	ble		blue_ok								;blue > max ?
	move.w	#%11111, d7
blue_ok:

	;add values
	add.w	d5, d6								;red+green
	add.w	d6, d7								;red+green+blue=16bit
	;d7:	result: new 16bit value

	;set new pixel
	move.w	d7, (a1)+

	dbf		d1, brighten_x_loop
	
	;add lineoffset
	adda.l	d4, a1
	
	dbf		d3, brighten_y_loop
	
rts
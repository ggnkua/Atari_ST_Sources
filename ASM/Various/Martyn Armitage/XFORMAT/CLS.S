*****************************************
* Routine name	: CLS			*
* Function	: To clear clear the	*
* screen inside of a window, or to	*
* clear a rectangle			*
* ------------------------------------- *
* Programmer	: Martyn Armitage	*
* Generates	: P.I.C.		*
* Written	: 12/01/1988		*
* Updated	: 06/07/1989		*
*		  12/06/1989		*
*****************************************

* clear the current window
cls		move.w	window_handle(a6),d0
		move.w	#4,d1
		bsr	get_wind_info		get window area
		add.w	d0,d2			get x2 coord
		add.w	d1,d3			get y2 coord
		lea	fill_type(a6),a0	variables
		move.w	#1,(a0)+		solid fill
		clr.w	(a0)+			white
		move.w	#1,(a0)			replace
		
* fill a rectangle with white
* enter with  x,y in d0-d1 and x2,y2 in d2-d3
fill_rect	movem.w	d0-d3,-(sp)		save coords
		bsr	hide_mouse
		bsr.s	set_fill_col		set colour
		bsr.s	set_fill_type		set type
		bsr	set_char_mode		set mode type
		movem.w	(sp)+,d0-d3		get coords
		subq.w	#1,d2			{ adjust coords 
		subq.w	#1,d3			{ by one pixel
		lea	ptsin(a6),a0		ptsin array
		movem.w	d0-d3,(a0)		pass coords
		move.w	#2,contrl+2(a6)		two points
		clr.w	contrl+4(a6)
		clr.w	contrl+6(a6)
		clr.w	contrl+8(a6)
		move.w	device(a6),contrl+12(a6)
		vdi	VR_RECFL
		bsr	show_mouse
		rts

* set the fill type
* enter with fill type in 'FILL_TYPE'
set_fill_type	clr.w	contrl+2(a6)
		clr.w	contrl+4(a6)
		move.w	#1,contrl+6(a6)
		move.w	#1,contrl+8(a6)
		move.w	device(a6),contrl+12(a6)
		move.w	fill_type(a6),intin(a6)
		vdi	VSF_INTERIOR
		rts

* set the fill colour
* enter with required colour in 'FILL_COLOUR'
set_fill_col	clr.w	contrl+2(a6)
		clr.w	contrl+4(a6)
		move.w	#1,contrl+6(a6)
		move.w	#1,contrl+8(a6)
		move.w	device(a6),contrl+12(a6)
		move.w	fill_colour(a6),intin(a6)
		vdi	VSF_COLOUR
		move.w	intout(a6),d0		get set colour
		rts

* set the character mode
set_char_mode	lea	contrl+2(a6),a0
		clr.l	(a0)+
		move.l	#$00010001,(a0)
		move.w	device(a6),contrl+12(a6)
		move.w	draw_mode(a6),intin(a6)
		vdi	VSWR_MODE
		move.w	intout(a6),d0		get mode set
		rts

fill_type	rs.w	1	fill type required
fill_colour	rs.w	1	fill colour requried
draw_mode	rs.w	1	drawing mode

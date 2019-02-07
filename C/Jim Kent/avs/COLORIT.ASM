
	dseg
	public _colors_4_4


_colors_4_4
	dc.l	$00000000
	dc.l	$ffff0000
	dc.l	$0000ffff
	dc.l	$ffffffff

	cseg
	public _color_lines

	;color_lines - set lines # of lines to color starting at screen 
	;	address start
	;color_lines(start, lines, color)
firstp	set	4
start	set firstp
lines	set	firstp+4
color	set firstp+6
_color_lines
	move.l	#_colors_4_4,a0
	move.w	color(sp),d0
	asl.w	#2,d0
	adda.w	d0,a0
	move.l	(a0)+,d0
	move.l	start(sp),a0
	move.w	lines(sp),d2
	add.w	d2,d2
	add.w	d2,d2	; x4 cause each loop only 1/4 of a line
	bra		zcl_llp
cl_llp	
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
zcl_llp	dbra d2,cl_llp
	rts


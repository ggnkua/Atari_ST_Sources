
	dseg
	public _cscreen
	public _bitmasks
	public _brush_ix
	public _clip_brush
	public _clipping

	cseg
	public _draw_shifted
	public _do_paste
	public getdot

cel_xoff	equ 0
cel_yoff	equ	2
cel_width	equ 4
cel_height	equ 6

_plot_clip
	move.l	_clipping,a0;
	cmp.l	#0,a0
	beq		_plot_nobrush
	sub		#12,sp
	move.l	cel_xoff(a0),8(sp)	;save offset
	move.l	#0,cel_xoff(a0)		;zero offset
	move.l	a0,0(sp)
	move.w	16(sp),d0
	move.w	cel_width(a0),d1
	lsr.w	#1,d1
	sub.w	d1,d0
	move.w	d0,4(sp)
	move.w	18(sp),d0
	move.w	cel_height(a0),d1
	lsr.w	#1,d1
	sub.w	d1,d0
	move.w	d0,6(sp)
	jsr		_do_paste
	move.l	_clipping,a0;
	move.l	8(sp),cel_xoff(a0)
	add		#12,sp
	rts



	;plot(x, y, color)
	;	draw just a dot, or brush that's been pre-shifted
	;	depending if brush_ix is zero
	public	_plot
	public	_plot_nobrush
_plot
	tst.w	_clip_brush
	bne		_plot_clip
_plot_nobrush
	tst.w	_brush_ix
	beq _putdot
	move.w	8(sp),-(sp)	; transport color to new stack frame
	move.l	6(sp),-(sp) ; transport xy to new stack frame
	subq.w	#8,(sp)	; adjust the "hot spot" to middle of brush
	subq.w	#8,2(sp)	; adjust the "hot spot" to middle of brush
	jsr	_draw_shifted
	add	#6,sp
	rts


	;	putdot(x, y, color)
	;		fast one dot on screen
	public _putdot
_putdot
	move.w	6(sp),d0	; get y coordinate
	bmi		putdotz
	cmp.w	#200,d0
	bge		putdotz
	move.l	_cscreen,a0
	lsl.w	#5,d0
	adda.w	d0,a0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a0	; effectively multiply y coordinate by 160 = 128+32
	move.w	4(sp),d0	; get x coordinate
	bmi		putdotz
	cmp.w	#320,d0
	bge		putdotz
	move.w	d0,d1
	and.w	#$fff0,d1	
	lsr.w	#1,d1
	adda	d1,a0	; point a0 to the right word even ... 
	move.l	#_bitmasks,a1
	and.w	#$000f,d0	; find place in word
	add.w	d0,d0	;convert to word index
	move.w	0(a1,d0.w),d0	;  now have mask in word
	move.w	8(sp),d1	; get color parameter
	add.w	d1,d1
	add.w	d1,d1		;convert to pointer value
	move.l	#dots,a1
	move.l	0(a1,d1.w),a1	; get rest of routine for this color
	jmp		(a1)
putdotz	rts

dot0:	
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	rts

dot1: 
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	rts

dot2: 
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
	rts

dot3:
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	rts

dot4:
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	addq	#4,a0
	and.w	d0,(a0)
	rts

dot5:
	or.w	d0,(a0)
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,6(a0)
	rts

dot6:
	or.w	d0,2(a0)
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,6(a0)
	rts

dot7:
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	rts

dot8:	
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)
	rts

dot9: 
	or.w	d0,(a0)+
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	rts

dota: 
	or.w	d0,2(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,4(a0)
	rts

dotb:
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,(a0)
	rts

dotc:
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts

dotd:
	or.w	d0,(a0)
	or.w	d0,4(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,2(a0)
	rts

dote:
	or.w	d0,2(a0)
	or.w	d0,4(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	rts

dotf:
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts


	dseg
dots dc.l 	dot0,dot1,dot2,dot3,dot4,dot5,dot6,dot7
	dc.l	dot8,dot9,dota,dotb,dotc,dotd,dote,dotf



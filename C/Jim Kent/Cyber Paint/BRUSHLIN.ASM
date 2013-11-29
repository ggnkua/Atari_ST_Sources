
	dseg
	public _ccolor

	cseg
	public _plot
	public _draw_shifted

	;brush_line(x1, y1, x2, y2)
	;	draw a circle of radius rad about center x,y in color
	public _brush_line


param1	equ	6*4+4+6	; offset on stack to first parameter after register saved
x1	equ	param1
y1	equ  param1+2
x2 equ	param1+4
y2 equ param1+6
_brush_line
	movem.l	d2/d3/d4/d5/d6/d7,-(sp)
	subq.l	#6,sp	; make room for parameters to plot

	move.w x1(sp),d2
	move.w y1(sp),d5
	move.w x2(sp),d6
	move.w y2(sp),d7

drawcolr:        
		cmp.w   d6,d2   ; Swap axes if x2>x1
        bls.s   cswapx21
        exg     d2,d6
        exg     d5,d7

cswapx21:        
		move.w	d2,0(sp)
		move.w	d5,2(sp) ; init plot coordinates on stack
		move.w	_ccolor,4(sp)	; set up color parameter for plot
	;now adjust for hot spot of brush
		subq.w #8,0(sp)
		subq.w #8,2(sp)
		move.w  d6,d4   ; Find absolute diff of x2-x1 and y2-y1
        sub.w   d2,d4
		;beq		bru_yline
		move.w	#1,d6	; init iny for down
        move.w  d7,d3
        sub.w   d5,d3
		;beq		bru_xline
		bgt.s	cgodown
		neg.w	d3	; negate absolute value
		neg.w	d6	; negate incy
        
cgodown: 
        cmp.w   d3,d4   ; Which axis is major?
        bhi.s   cxmajor

cymajor:
		move.w	d3,d5
		asr.w	#1,d5	;init error term in d5
		move.w	d3,d7	; dot count to d7
cyline	jsr _draw_shifted
        sub.w   d4,d5
        blt.s   cxstepn
		add.w	d6,2(sp) ; y = y+1
        dbf    d7,cyline
		bra		end_brush_line

cxstepn:        add.w   d3,d5   ; add to the error term.
		add.w	#1,0(sp) ; x = x+1
		add.w	d6,2(sp) ; y = y+1
        dbf    d7,cyline
end_brush_line
		addq.l	#6,sp	; clean off parameters to plot
		movem.l	(sp)+,d2/d3/d4/d5/d6/d7
        rts



cxmajor: 
		move.w	d4,d5
		asr.w	#1,d5	;init error term in d5
		move.w	d4,d7	; dot count to d7
cxline	jsr _draw_shifted
        sub.w   d3,d5
        blt.s   cystepn
		add.w	#1,0(sp) ; x = x+1
        dbf    d7,cxline
		bra		end_brush_line

cystepn:        add.w   d4,d5   ; add to the error term.
		add.w	#1,0(sp) ; x = x+1
		add.w	d6,2(sp) ; y = y+1
        dbf    d7,cxline
		bra end_brush_line


	; brush_polyline(points, count)
	public _brush_polyline
_brush_polyline
	movem.l	a3/d7,-(sp)
	move.l	12(sp),a3
	move.w	16(sp),d7
	sub	#8,sp
	subq.w	#1,d7	;	one less line than # of vertices ... 
	bra plinez
plineloop	move.l	(a3)+,(sp)
	move.l	(a3),4(sp)
	bsr		_brush_line
plinez dbra	d7,plineloop
	add		#8,sp
	movem.l	(sp)+,a3/d7
	rts


	;brush_hline(y1, x0, x1);
	public _brush_hline
_brush_hline
	movem.l	d5/d6/d7,-(sp)
	sub		#8,sp
	move.w	_ccolor,4(sp)
	move.w	#1,d5
	move.w	8+4*4+0(sp),2(sp)
	move.w	8+4*4+2(sp),d6
	move.w	8+4*4+4(sp),d7
	sub.w	d6,d7
	bpl	bhnoswap
	neg.w	d7
	neg.w	d5
	move.w	8+4*4+4(sp),d6
bhnoswap 
	sub.w	#8,2(sp)	; offset hot spot
	sub.w	#8,d6
	move.w	d6,0(sp)
bhlloop	jsr	_draw_shifted
	add.w	d5,0(sp)
	dbra	d7,bhlloop
	add		#8,sp
	movem.l	(sp)+,d5/d6/d7
	rts

	;brush_vline(x0, y0, y1);
	public _brush_vline
_brush_vline
	movem.l	d5/d6/d7,-(sp)
	sub		#8,sp
	move.w	_ccolor,4(sp)
	move.w	#1,d5
	move.w	8+4*4+0(sp),0(sp)
	move.w	8+4*4+2(sp),d6
	move.w	8+4*4+4(sp),d7
	sub.w	d6,d7
	bpl	bvnoswap
	neg.w	d7
	neg.w	d5
	move.w	8+4*4+4(sp),d6
bvnoswap 
	sub.w	#8,0(sp)	; offset hot spot
	sub.w	#8,d6
	move.w	d6,2(sp)
bvlloop	jsr	_draw_shifted
	add.w	d5,2(sp)
	dbra	d7,bvlloop
	add		#8,sp
	movem.l	(sp)+,d5/d6/d7
	rts


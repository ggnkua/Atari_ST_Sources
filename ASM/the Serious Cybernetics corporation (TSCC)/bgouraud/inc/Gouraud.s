;==============================
;=
;= Calculate length and "direction"
;= of the longest triangle row and
;= calculate color delta
;=
;==============================

_3dGCalcDelta	macro
		move.l	d0,d3		; Calculate length of longest row
		sub.l	d1,d3		; x1-x2|y1-y2

		swap.w	d3
		move.w	d3,d4		; x1-x2
		clr.w	d3		; y1-y2  16.16 fixed

		ext.l	d7
		divs.l	d7,d3
		asr.l	#8,d3		; t = (y1-y2)/(y3-y1)  24.8 fixed

		move.l	d2,d5
		sub.l	d0,d5
		swap.w	d5
		ext.l	d5
		muls.l	d3,d5
		asr.l	#8,d5
		sub.w	d5,d4		; l = (x1-x2)-t(x3-x1)
		beq.w	.return		; Triangle less than 1 pixel wide


		move.w	a2,d5		; Compute color delta
		sub.w	a0,d5		; c3-c1
		ext.l	d5

		muls.l	d3,d5		; t(c3-c1)
		asr.l	#8,d5

		move.l	a0,d3		; an's get long extened all the time
		sub.l	d5,d3		; so there's no need for an ext.l
		sub.l	a1,d3
		add.l	d3,d3		; *2 (words)
		divs.w	d4,d3
		
	ifne	method
		move.w	d3,$ffff8a20.w	; _SrcXinc = Dc = (c1-c2)-t(c3-c1)/l
	else
		bclr.l	#0,d3		; Even value
		movea.w	d3,a6
	endc
		endm



;==============================
;=
;= Scan convert a (possibly shaded)
;= triangle section
;=
;==============================

_3dGScanSection macro	destiation,p1,p2,ShadeFlag,c1,c2

		move.l	\3,d3
		movea.l	\2,a5
		sub.l	a5,d3		; x2-x1|y2-y1

		move.w	d3,d4
		beq.s	.\@reject	; Reject zero height sections

		ext.l	d4
		divs.l	d4,d3		; Dx = (x2-x1)/(y2-y1)  16.16 fixed

	ifne	\4			; Step shades along the left
		movea.w	\5,a4		; section only
		move.w	\6,d5
		sub.w	a4,d5
		ext.l	d5
		divs.w	d4,d5		; Dc = (c2-c1)/(y2-y1)  8.8 fixed
	endc

		suba.w	a5,a5		; x = x1  16.16 fixed


		subq.w	#1,d4

.\@scan_loop	move.l	a5,d6
		swap.w	d6
		move.w	d6,(\1)+	; store int(x)
		adda.l	d3,a5		; x += Dx

	ifne	\4	
		move.w	a4,(\1)+	; Store color
		adda.w	d5,a4		; c += Dc
	endc
		dbra	d4,.\@scan_loop
.\@reject
		endm




;==============================
;=
;= Draw a gouruad shaded triangle
;=
;= d0.l-d2.l : (x1|y1)-(x3|y3)
;= a0.w-a2.w : c1-c3    8.8 fixed
;=
;= Kills d0-d7/a0-a6
;==============================

		section	text
_3d.GouraudShadeTriangle
.On	=	1			; Shade flag for the scan converter
.Off	=	0
		
		cmp.w	d0,d2		; Sort points from top to bottom
		bgt.s	.y3_greater
		exg.l	d0,d2
		exg.l	a0,a2
		
.y3_greater	cmp.w	d0,d1
		bgt.s	.y2_greater
		exg.l	d0,d1
		exg.l	a0,a1
		
.y2_greater	cmp.w	d1,d2
		bgt.s	.y2_smaller
		exg.l	d1,d2
		exg.l	a1,a2

.y2_smaller	move.w	d2,d7		; Height of this triangle (y3-y1)
		sub.w	d0,d7
		beq.w	.return		; Less than one row high, exit


; Determine which sections are on the left or right

		_3dGCalcDelta


; Scan left and right section

		tst.w	d4		; Determine placing of x2
		bpl.w	.x2_left	; and scan convert, accordingly

		lea.l	_3d.LeftEdge,a3		; x2 is on the right side
		_3dGScanSection a3,d0,d2,.On,a0,a2
		lea.l	_3d.RightEdge,a3
		_3dGScanSection a3,d0,d1,.Off
		_3dGScanSection a3,d1,d2,.Off

		bra.w	.map
		
	
.x2_left	lea.l	_3d.LeftEdge,a3		; x2 is on the left side
		_3dGScanSection a3,d0,d1,.On,a0,a1
		_3dGScanSection a3,d1,d2,.On,a1,a2
		lea.l	_3d.RightEdge,a3
		_3dGScanSection a3,d0,d2,.Off


; Fill triangle row by row

.map		moveq.l	#0,d1		; Keep upper word clean for
		move.l	d1,d2		; faster (an,dn.l) addressing

	ifne	method
		moveq.l	#1,d3
		moveq.l	#%11<<6,d4	; Blitter busy & HOG bit
	endc

		movea.l	Screen,a0
		adda.l	(_3d.X_resMul,pc,d0.w*4),a0 ; Point to topmost row

		lea.l	_3d.LeftEdge,a1
		lea.l	_3d.RightEdge,a2
		movea.l	_3d.gradient(pc),a4


		subq.w	#1,d7		; dbra

.fill		move.w	(a2)+,d0	; ScreenX (right)
		move.w	(a1)+,d1	; ScreenX (left)
		move.w	(a1)+,d2	; Shade at the left edge

		sub.w	d1,d0		; Width
		ble.s	.nextrow	; Less then one pixel wide

		lea.l	(a0,d1.l*2),a3	; Point to left pixel


	ifne	method

; Now do this instead of using an innerloop
	
		lea.l	$ffff8a24.w,a5

		lea.l	(a4,d2.l*2),a6
		move.l	a6,(a5)+	; _SrcAddr = &gradient[c1]
		lea.l	10(a5),a5
		
		move.l	a3,(a5)+	; _DstAddr

		move.w	d0,(a5)+	; _XCount = width
		move.w	d3,(a5)+	; _YCount = 1
		
		or.b	d4,2(a5)	; Leave the rest up to the
	else				; blitter, finally


; Alternative cpu-innerloop

		lea.l	(a4,d2.l*2),a5

		subq.w	#1,d0
		
.innerloop	move.w	(a5),(a3)+
		adda.l	a6,a5		; Color += Dc
		dbra	d0,.innerloop
	endc



.nextrow	lea.l	2*x_res(a0),a0	; Point to next row
		dbra	d7,.fill

.return		rts


_3d.gradient	ds.l	1	; Pointer to upscaled gradient


		section	data
_3d.X_resMul			; Avoid a mul. during screenoffset
.ofs	set	0		; calculation
	rept	y_res
		dc.l	.ofs
.ofs	set	.ofs+2*x_res
	endr


		section	bss
_3d.LeftEdge	ds.w	2*y_res	; ScreenX|shade along the left edge (interleaved)
_3d.RightEdge	ds.w	y_res	; ScreenX along right edge
********************************************
*  void plotMandel()
*
* Draw a mandelbrot fractal using the iteration
* method described in my alive #12 article.
********************************************

		section	text
xMin		ds.w	1
xMax		ds.w	1
yMin		ds.w	1
yMax		ds.w	1
	
plotMandel	moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4

		move.w	xMax(pc),d0	; dx = (xMax-xMin)/XRES
		sub.w	xMin(pc),d0
		ext.l	d0
		divu.w	#XRES,d0
		movea.w	d0,a2

		move.w	yMax(pc),d0	; dy = (yMax-xMin)/YRES
		movea.w	yMin(pc),a4
		sub.w	a4,d0
		ext.l	d0
		divu.w	#YRES,d0
		move.w	d0,-(sp)

		move.l	actScreen(pc),a0	; Center destination window
		adda.w	#((PHYSX-XRES)/2+PHYSX*((PHYSY-YRES)/2))&-16,a0
		move.l	a0,-(sp)
		lea.l	lineBuffer,a0	; Dst (8(6)bpp)
		
		lea.l	sqrTable,a6


		move.w	#YRES-1,d0
.yloop		movea.w	xMin(pc),a5	; Reset the x

		lea.l	(MAXRAD*MAXRAD)>>FRACBITS.w,a1

		move.w	#XRES-1,d1
.xloop		moveq.l	#MAXITER-1,d7	; iter = 0
		moveq.l	#0,d6		; a0 = 0
		moveq.l	#0,d5		; b0 = 0

.iter		move.w	(a6,d6.l*2),d2	; a^2
		move.w	(a6,d5.l*2),d3	; b^2

		movea.l d2,a3		; (a^2+b^2) > MAXRAD^2?
		adda.l	d3,a3
		cmpa.l	a1,a3
		bhs.s	.break

		move.w	d6,d4		; (a+b)^2
		add.w	d5,d4
		move.w	(a6,d4.l*2),d5

		sub.w	a3,d5		; b(+1) = (a+b)^2 - (a^2+b^2) = 2ab
		add.w	a4,d5		; += Cy

		move.w	d2,d6		; a(+1) = a^2 - b^2 + Cx
		sub.w	d3,d6
		add.w	a5,d6
		
		dbra	d7,.iter	; --iter < 0?

.break	 	addq.b	#1,d7		; *lineBuffer++ = iter+1
		move.b	d7,(a0)+

		adda.w	a2,a5		; x += dx
		dbra	d1,.xloop

		lea.l	lineBuffer,a0	; Blit the scanline that has
		movea.l	(sp)+,a1	; just been computed
		bsr.w	blit6bpp

		adda.w	(sp),a4		; y += dy
		move.l	a1,-(sp)

		dbra	d0,.yloop

		addq.l	#6,sp
		rts


********************************************
*  void buildSqrTable()
*
* Blit s^2 lookup table used to increase the speed
* of the mandelbrot iteration loop
********************************************

buildSqrTable	moveq.l	#0,d0
		moveq.l	#0,d3
		moveq.l	#FRACBITS,d2
		lea.l	sqrTable,a0

.sqrloop	move.w	d0,d1
		muls	d1,d1
		lsr.l	d2,d1
		addx.w	d3,d1
		move.w	d1,(a0)+
		addq.w	#1,d0
		bne.s	.sqrloop
		rts

		section	bss
sqrTable	ds.w	$10000


********************************************
*  void slctArea()
*
* Select the fractal area to be zoomed on into
********************************************

		section	text
slctLeft	dc.w	XMIN		; Fractal coordinates of the new
slctRight	dc.w	XMAX		; bounding box
slctTop		dc.w	YMIN
slctBot		dc.w	YMAX

SCALEFACTOR	=	$00009000	; Static rescale factor (90%), 16.16 fixed

slctArea	move.w	xMax(pc),d0	; Current width
		sub.w	xMin(pc),d0
		move.w	yMax(pc),d1	; Current height
		sub.w	yMin(pc),d1

		move.w	mX(pc),d2	; Translate mouse origin into (0,0)
		sub.w	#XRES/2,d2
		move.w	mY(pc),d3
		sub.w	#YRES/2,d3
		muls.w	d0,d2		; Normalize to homogenous coordinates, 8.8 fixed
		muls.w	d1,d3
		divs.w	#XRES/2,d2
		divs.w	#YRES/2,d3

		add.w	xMin(pc),d2	; Retranslate origin
		add.w	yMin(pc),d3

		move.w	d0,d4		; Perform the rescaling
		move.w	d1,d5
		mulu.w	#SCALEFACTOR,d4	; width  *= SCALEFACTOR
		mulu.w	#SCALEFACTOR,d5	; height *= SCALEFACTOR
		swap.w	d4
		swap.w	d5

		sub.w	d4,d0		; Center new window
		sub.w	d5,d1
		lsr.w	d0
		lsr.w	d1
		add.w	d0,d2
		add.w	d1,d3
			
		lea.l	slctLeft(pc),a0

		cmpi.w	#XCLIPLEFT,d2	; Clip coordinates
		bge.s	.xleft_ok
		move.w	#XCLIPLEFT,d2
.xleft_ok	move.w	d4,d6
		add.w	d2,d6
		
		cmpi.w	#XCLIPRIGHT,d6
		ble.s	.xright_ok
		move.w	#XCLIPRIGHT,d6
		move.w	d6,d2		; Fixup x1 as well
		sub.w	d4,d2
		
.xright_ok	move.w	d2,(a0)+
		move.w	d6,(a0)+
		
		cmpi.w	#YCLIPTOP,d3	; Same for the y value
		bge.s	.ytop_ok
		move.w	#YCLIPTOP,d3
.ytop_ok	move.w	d5,d6
		add.w	d3,d6
		
		cmpi.w	#YCLIPBOT,d6
		ble.s	.ybot_ok
		move.w	#YCLIPBOT,d6
		move.w	d6,d3
		sub.w	d5,d3
		
.ybot_ok	move.w	d3,(a0)+
		move.w	d6,(a0)+
		rts


********************************************
*  void setGradient()
*		
* Set up a hardcoded blue->red->yellow gradient colortable.
********************************************

setGradient	lea.l	colorTable+4*(48+3),a0
		moveq.l	#-1,d0		; Color	50 = white
		move.l	d0,-(a0)
		clr.l	-(a0)		; Color 49 = black
		
		moveq.l	#16,d2
		
		moveq.l	#0,d0		; Black->Blue gradient
.genPalB	lsl.b	#4,d0
		move.w	d0,-(a0)
		clr.w	-(a0)
		lsr.b	#4,d0
		addq.b	#1,d0
		cmp.b	d2,d0
		bne.s	.genPalB
		
		moveq.l	#0,d0		; Blue->Red gradient
.genPalR	lsl.b	#4,d0
		
		move.w	#$f0,d1
		sub.w	d0,d1
	
		move.w	d1,-(a0)
		move.w	d0,-(a0)

		lsr.b	#4,d0
		addq.b	#1,d0
		cmp.b	d2,d0
		bne.s	.genPalR

		moveq.l	#0,d0		; Red->Yellow gradient
.genPalY	ror.w	#4,d0
		move.w	d0,-(a0)
		move.w	#$ff,-(a0)
		rol.w	#4,d0
		addq.w	#1,d0
		cmp.b	d2,d0
		bne.s	.genPalY

		clr.l	-(a0)
		bra.w	setPalette

		section	bss
colorTable	ds.l	256

;stcline.asm - fetch parameters from pogo parameter pointer and
;clip line before calling fast line drawing routine in stline.asm

	dseg
	public	_in_graphics
	public _cscreen
	public lcolor

	cseg
	public _flashred
	public	_to_graphics
	public	drawcolr

	public _pline
color equ -20
x1	equ -16
y1	equ -12
x2	equ -8
y2	equ -4

        
_pline:	
	;1st make sure in graphics mode.
	move.w	_in_graphics,d0
	bne		gotg
	jsr		_to_graphics
gotg
	move.l	4(sp),a0	;fetch parameter pointer.
	movem.l d2/d3/d4/d5/d6/d7,-(sp)	;save C registers we need to use

;now move all parameters where drawcolr line routine expects them
	move.w	color(a0),d0
	and.w	#15,d0	;make sure color is 0 to 15
	move.w	d0,lcolor
	move.w x1(a0),d4
	move.w y1(a0),d5
	move.w x2(a0),d6
	move.w y2(a0),d7
;make sure x1 <= x2
	cmp.w   d6,d4   ; Swap axes if x2<x1
	ble.s   cswapped
	exg     d4,d6
	exg     d5,d7
cswapped:        

;now do gnarly clipping...
;clip against left side (x < 0)
	tst.w	d6		;right side off-screen???
	bmi		clippedout
	tst.w	d4
	bpl		rightclip
;here 1st endpoint is off screen, 2nd endpoint on screen.  
	move.w	d7,d1
	sub.w	d5,d1		;d1 = delta y
	muls	d4,d1		
	move.w	d6,d0
	sub.w	d4,d0
	divs	d0,d1
	sub.w	d1,d5
;y0 += (windowX0-x0)*dy/dx
;y0 -= x0*dy/dx
	clr.w	d4

rightclip:
	move.w	#319,d0		;d0 is right edge of window
	cmp.w	d4,d0
	bmi		clippedout	;left end of line past right edge of screen
	sub.w	d6,d0
	bpl		vclip
;here 2nd endpoint is off screen to right, 1st endpoint on screen.  
	move.w	d7,d1
	sub.w	d5,d1
	muls	d0,d1
	move.w	d6,d0
	sub.w	d4,d0
	divs	d0,d1
	add.w	d1,d7
;y1 += (windowX1-x1)*dy/dx
	move.w	#319,d6

vclip:		;do vertical part of clipping
	cmp.w	d7,d5
	ble		firstup
;ok, here the second endpoint is less than the 1st y-wise

	tst.w	d5		;bottom side off-screen???
	bmi		clippedout
	tst.w	d7
	bpl		downclip
;here 1st endpoint is off screen, 2nd endpoint on screen.  
	move.w	d4,d1
	sub.w	d6,d1		;d1 = delta x
	muls	d7,d1		
	move.w	d5,d0
	sub.w	d7,d0
	divs	d0,d1
	sub.w	d1,d6
;x0 += (windowY0-y0)*dx/dy
;x0 -= y0*dx/dy
	clr.w	d7

downclip:
	move.w	#199,d0		;d0 is bottom edge of window
	cmp.w	d7,d0
	bmi		clippedout	;left end of line past right edge of screen
	sub.w	d5,d0
	bpl		doline
;here 2nd endpoint is off screen to bottom, 1st endpoint on screen.  
	move.w	d4,d1
	sub.w	d6,d1
	muls	d0,d1
	move.w	d5,d0
	sub.w	d7,d0
	divs	d0,d1
	add.w	d1,d4
;x1 += (windowY1-y1)*dx/dy
	move.w	#199,d5

	bra		doline

firstup:	;here the 1st endpoint is less than the second
	tst.w	d7		;bottom side off-screen???
	bmi		clippedout
	tst.w	d5
	bpl		downclip1
;here 1st endpoint is off screen, 2nd endpoint on screen.  
	move.w	d6,d1
	sub.w	d4,d1		;d1 = delta x
	muls	d5,d1		
	move.w	d7,d0
	sub.w	d5,d0
	divs	d0,d1
	sub.w	d1,d4
;x0 += (windowY0-y0)*dx/dy
;x0 -= y0*dx/dy
	clr.w	d5

downclip1:
	move.w	#199,d0		;d0 is bottom edge of window
	cmp.w	d5,d0
	bmi		clippedout	;left end of line past right edge of screen
	sub.w	d7,d0
	bpl		doline
;here 2nd endpoint is off screen to bottom, 1st endpoint on screen.  
	move.w	d6,d1
	sub.w	d4,d1
	muls	d0,d1
	move.w	d7,d0
	sub.w	d5,d0
	divs	d0,d1
	add.w	d1,d6
;x1 += (windowY1-y1)*dx/dy
	move.w	#199,d7


doline:
	jsr drawcolr
clippedout:
	movem.l	(sp)+,d2/d3/d4/d5/d6/d7
	rts


allregs	reg	a0-a6/d0-d7

flashred
	movem.l	allregs,-(sp)
	jsr	_flashred
	movem.l	(sp)+,allregs
	rts

	public _plot
	public _ahline
	public _aline

; useful aline offsets
x1		equ	38

;clipping constants
XMAX	equ	320	
YMAX	equ	200

	public _disk
_disk
param1	equ	7*4+4	; offset on stack to first parameter after register saved
x		equ	param1
y		equ  param1+2
rad 	equ	param1+4
color 	equ param1
	movem.l	d3/d4/d5/d6/d7/a2/a3,-(sp)

	move.w	x(sp),d6	; save center xy
	move.w	y(sp),d7
	move.w	rad(sp),d4	; xoffset starts out radius
	bne		nontrivd	; it's not zero radius...do a disk
	move.w	d6,(sp)
	move.w	d7,2(sp)
	jsr		_plot		; else just plot one point... 
	bra		enddloop
nontrivd
	move.l	_aline,a3	; get "aline" pointer
	add.l	#x1,a3		; and move it to the x1,y1,x2 area
	move.w	#0,d5		; yoffset starts out zero
	move.w	d4,d3
	neg.w	d3
	asr.w	#1,d3		; d3 = error = -rad/2


dloop
	;	plot upper line
	move.w	d6,d0	
	sub.w	d4,d0	; 	find left side of hline
	bpl		lclipok	;	off screen to left?
	move.w	#0,d0	;   then make it start on left edge
lclipok	move.w	d0,(a3)	; save left edge in aline structure "x1"
	move.w	d6,d0	
	add.w	d4,d0
	cmp.w	#XMAX,d0	; calculate right edge and see if offscreen
	blt		rclipok
	move.w	#XMAX-1,d0	; if offscreen make it end on right edge
rclipok	move.w	d0,4(a3) ; and save right edge in aline structure "x2"
	move.w	d7,d0
	sub.w	d5,d0	;   calculate absolute y coordinate
	bmi		lline	;	clipped above screen?
	move.w	d0,2(a3) ; 	and save y position in "y1" slot of aline structure
	dc.w $a004	; call aline horizontal line

lline
	move.w	d7,d0
	add.w	d5,d0	; calc y coordinate of lower line
	cmp.w	#YMAX,d0
	bge		nextxy	; if below screen don't plot it
	move.w	d0,2(a3)
	dc.w	$a004	; and draw 2nd horizontal line

	; now do stuff to figure out where next hlines will be
nextxy
	tst.w	d3		; check sign of error term
nexty
	bmi		stepy
	subq.w	#1,d4
	bmi		enddloop
	sub.w	d4,d3
	bra		nexty
stepy
	addq.w	#1,d5	; increment y offset
	add.w	d5,d3	; update error term
	bra 	dloop

enddloop
	movem.l	(sp)+,d3/d4/d5/d6/d7/a2/a3
	rts


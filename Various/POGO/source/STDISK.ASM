	public _putdot
	public _ahline
	public _aline
	public init_hli
	public hli

; useful aline offsets

;clipping constants
XMAX	equ	320	
YMAX	equ	200

	public _disk
_disk
param1	equ	(8*4)+4+8 ;offset on stack to first parameter after register saved
x		equ	param1
y		equ  param1+2
rad 	equ	param1+4
color 	equ param1+6
py	equ 0
px1 equ 2
px2 equ 4
pcolor equ 6
err equ 8

	movem.l	d3/d4/d5/d6/d7/a2/a3/a4,-(sp)
	sub		#8,sp

	move.w	x(sp),d6	; save center xy
	move.w	y(sp),d7
	move.w	color(sp),d0
	and		#15,d0		;make sure it's an ok value
	move.w	rad(sp),d4	; xoffset starts out radius
	bne		nontrivd	; it's not zero radius...do a disk

	;	here just plot a dot cause radius zero
	move.w	d6,(sp)
	move.w	d7,2(sp)
	move.w	d0,4(sp)
	jsr		_putdot		; else just plot one point... 
	bra		enddloop

nontrivd
	jsr init_hli
	move.w	#0,d5		; yoffset starts out zero
	move.w	d4,d3
	neg.w	d3
	asr.w	#1,d3		; d3 = error = -rad/2
	move.w	d3,err(sp)


dloop
	;	plot upper line
	move.w	d6,d0	
	sub.w	d4,d0	; 	find left side of hline
	bpl		lclipok	;	off screen to left?
	move.w	#0,d0	;   then make it start on left edge
lclipok	
	cmp.w	#XMAX,d0	; left edge
	bge		nextxy		;off screen to right? Nothing left then.
	move.w	d0,2(sp)	; save left edge
	move.w	d6,d0	
	add.w	d4,d0
	blt		nextxy		; off screen to left
	cmp.w	#XMAX,d0	; calculate right edge and see if offscreen
	blt		rclipok
	move.w	#XMAX-1,d0	; if offscreen make it end on right edge
rclipok	
	move.w	d0,4(sp) ; and save right edge
	move.w	d7,d0
	sub.w	d5,d0	;   calculate absolute y coordinate
	bmi		lline	;	clipped above screen?
	cmp.w	#YMAX,d0	;clipped below screen?
	bge		lline
	move.w	d0,0(sp) ; 	and save y position
	jsr		hli

lline
	move.w	d7,d0
	add.w	d5,d0	; calc y coordinate of lower line
	bmi		nextxy
	cmp.w	#YMAX,d0
	bge		nextxy	; if below screen don't plot it
	move.w	d0,0(sp) ; save y position
	jsr		hli

	; now do stuff to figure out where next hlines will be
nextxy
	move.w	err(sp),d3
nexty
	bmi		stepy
	subq.w	#1,d4
	bmi		enddloop
	sub.w	d4,d3
	bra		nexty
stepy
	addq.w	#1,d5	; increment y offset
	add.w	d5,d3	; update error term
	move.w	d3,err(sp)
	bra 	dloop

enddloop
	add		#8,sp
	movem.l	(sp)+,d3/d4/d5/d6/d7/a2/a3/a4
	rts


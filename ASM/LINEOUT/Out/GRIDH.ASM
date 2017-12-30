; gouraud lines on dsp:
;
; rotation + translation
; ->
; z clipping and culling (also depthculling!)
; ->
; perspectivation
; ->
; x/y clipping
; ->
; sorting
; ->
; transmission
;
; yep, host only does actual bresenham + some interpolation.
;
; todo: z intersection in x/y clip..
;
; quite well optimised, even max optimised cpu always has to wait..

;======== GLOBAL EQUATES ========

PBC:				=	$FFE0			; Port B Control Register
HSR:				=	$FFE9			; Host Status Register
HTX:				=	$FFEB			; Host Transmit Register

; Host Status Register Bit Flags
HRDF:				=	0			; Host Receive Data Full
HTDE:				=	1			; Host Transmit Data Empty

INVBUF_SIZE:			=	4095
MAX_LINES:			=	1000
MAX_VERTICES:			=	1000

CULLDIST:			=	1550

;======= Vertex

; That's right. For speedreasons the Y comes before the X!
Vertex.Y:	=	0
Vertex.X:	=	1
Vertex.Z:	=	2
Vertex.SIZE:	=	3

;======== Matrix

Matrix.MAX_DEPTH:	=	8				; max number of rotations in the world

Matrix.XX:		=	0
Matrix.XY:		=	1
Matrix.XZ:		=	2
Matrix.YX:		=	3
Matrix.YY:		=	4
Matrix.YZ:		=	5
Matrix.ZX:		=	6
Matrix.ZY:		=	7
Matrix.ZZ:		=	8
Matrix.SIZE:		=	9

;======== GLOBAL MACROS ========

get:	MACRO
	jclr	#0,X:<<HSR,*
	movep	X:<<HTX,\1
	ENDM

send:	MACRO
	jclr	#1,X:<<HSR,*
	movep	\1,X:<<HTX
	ENDM

;======== P-Memory Code ========

	ORG	P:$0000
	jmp	<start

	ORG	P:$0040
start:	jsr	<InitPipeline

_loop:
; synced to host: reception of rot+trans
	jsr	<ReceiveTranslation
	jsr	<ReceiveRotation

; parallel with host: transformation, clipping, sorting
; beware, r0-r5 must be set with correct addys!
	jsr	<Matrix.generate
	jsr	<transform
	jsr	<clipZ
;	jsr	<cullZ
	move			x:<visibleLines,a
	tst	a
	jeq	<_send
	jsr	<perspectivate
	jsr	<clipXY
	jsr	<cullShit
	jsr	<sort

; synced to host: send lines
_send:	jsr	<sendLines

	jmp	<_loop

; Receives rotation cos/sin values from CPU.
ReceiveRotation:
	move			#<SineX,r0
	move			#<CosineX,r1
	move			#<SineY,r2
	move			#<CosineY,r3
	move			#<SineZ,r4
	move			#<CosineZ,r5
	get	x:(r0)
	get	x:(r1)
	get	x:(r2)
	get	x:(r3)
	get	y:(r4)
	get	y:(r5)
	rts

ReceiveTranslation:
	move			#<TransX,r0
	do	#3,_loop
	get	x:(r0)+
_loop:	rts

transform:
	move			#<Matrix,r4
	move			#>-8,n4
	move			#>transformedVertices,r5
	move			#>vertices,r0
	move			#<TransX,r1
	move			#>-2,n1
	move			x:(r1)+,a			; a=TX
	move			x:(r0)+,x0	y:(r4)+,y0
	do	x:<numVertices,_loop
	mac	x0,y0,a		x:(r0)+,x1	y:(r4)+,y0	; x * MXX +
	mac	x1,y0,a		x:(r0)-,x1	y:(r4)+,y0	; y * MXY +
	macr	x1,y0,a				y:(r4)+,y0	; z * MXZ
	move			x:(r1)+,a	a,y:(r5)+	; Store X.
	mac	x0,y0,a		x:(r0)+,x1	y:(r4)+,y0	; x * MYX +
	mac	x1,y0,a		x:(r0)-,x1	y:(r4)+,y0	; y * MYY +
	macr	x1,y0,a				y:(r4)+,y0	; z * MYZ
	move			x:(r1)+n1,a	a,y:(r5)+	; Store Y.
	mac	x0,y0,a		x:(r0)+,x1	y:(r4)+,y0	; x * MZX +
	mac	x1,y0,a		x:(r0)+,x1	y:(r4)+n4,y0	; y * MZY +
	macr	x1,y0,a		x:(r0)+,x0	y:(r4)+,y0	; z * MZZ
	move			x:(r1)+,a	a,y:(r5)+	; Store Z.
_loop:	rts	

; This uses the transformed vertices and line-structures as input.
; It outputs transformed edgestructures without references.
; Also outputs z averages used later on..
; Now z culls and depthculls too!
clipZ:	move			#>lines,r0
	move			#>transformedVertices,r4
	move			#>ZCenterTable,r1		; count=0
	move			#>TransformedLines,r5
	move			#<Vertex.SIZE,n6
	move			#<Vertex.SIZE,n3
	move			r1,n4				; Zlinebufstart
	move			#>-2,n1
	do	x:<numLines,_loop
	move			x:(r0)+,b
	asl	b		b,x0
	add	x0,b		r4,y1				; b=v1offset
	add	y1,b						; b=v1adr
	move			b,r6				; y:(r6):v1
	move			x:(r0)+,a
	move					y:(r6)+,x0	; x0=v1.x
	asl	a		a,x1		y:(r6)+,y0	; y0=v1.y
	add	x1,a				y:(r6)+,b	; a=v2offset, b=v1.z
	add	y1,a						; a=v2adr
	move			a,r6				; y:(r6):v2
	move			r5,r3				; r3: current trans. line

	IFNE	1
; special depthculling!!!
	move			#>CULLDIST,x1
	cmp	x1,b
	jlt	<_bla

	move			(r6)+
	move					y:(r6)+,y1	; y1=v2.y
	move					y:(r6)-,a	; a=v2.z
	cmp	x1,a				y:-(r6),x1	; x1=v2.x
	move			(r6)+n6
	jge	<_next
	tst	a		r5,r6				; r6: current trans. line
	jmi	<_clip2						; just cull..
	jsr	<_store
	jmp	<_next
	ENDC

_bla:	move					y:(r6)+,x1	; x1=v2.x
	move					y:(r6)+,y1	; y1=v2.y
	tst	b				y:(r6)+,a	; a=v2.z
	jmi	<_clip
	tst	a		r5,r6				; r6: current trans. line
	jmi	<_clip2						; just cull..
	jsr	<_store
_next:	move			r1,a				; a=zlineadr
_loop:	move			n4,x0				; x0=zlinebuf
	sub	x0,a						; a=zlineoffset
	lsr	a						; a=#lines
	move			a,x:<visibleLines		; Store #unculled_lines.
	rts

; Clip the goddamn edge against the z-plane.
; v1 outside, v2 dunno yet
_clip:	tst	a		r5,r6
	jmi	<_next
	jsr	<_store
	move			#<0,x0
	move			(r6)+
	move			(r6)+
	do	#2,_iloop
	move					y:(r6),x1	; x1='ystart'=v1.z
	move					y:(r3),y1	; y1='xstart'=v1.x/y
	move					y:(r6+n6),a	; a='yend'=v2.x
	sub	x1,a				y:(r3+n3),b	; a='dy', b='xend'=v2.x/y
	jsr	<intersect
	add	y1,a
	move					a,y:(r3)+	; Store intersected coord, proceed to next coord.
_iloop:	move					x0,y:(r6)	; Store cut.
	move					x0,y:(r1+n1)	; adjust z_avg!
	jmp	<_next

; Clip the goddamn edge against the z-plane.
; v2 outside, v1 inside
_clip2:	jsr	<_store
	move			#<0,x0
	move			(r6)+
	move			(r6)+
	do	#2,_iloop2
	move					y:(r6+n6),x1	; x1='ystart'=v1.z
	move					y:(r3+n3),y1	; y1='xstart'=v1.x/y
 	move					y:(r6),a	; a='yend'=v2.z
	sub	x1,a				y:(r3),b	; a='dy', b='xend'=v2.x/y
	jsr	<intersect
	add	y1,a
	move					a,y:(r3+n3)	; Store intersected coord, proceed to next coord.
	move			(r3)+
_iloop2:move					x0,y:(r6+n6)	; Store cut.
	move					x0,y:(r1+n1)	; adjust z_avg!
	jmp	<_next

; Just store..
_store:	move					x0,y:(r5)+
	move					y0,y:(r5)+
	move					b,y:(r5)+
	move					x1,y:(r5)+
	move					y1,y:(r5)+
	add	a,b				a,y:(r5)+
	move					b,y:(r1)+	; Store average and increase linecount.
	move					r3,y:(r1)+	; Store zlineadr.
	rts

; Perspectivate the transformed lines..
; Also transforms to screenspace (ie. centers it to screen coords).
perspectivate:
	move			#>TransformedLines,r0
	move			#<Vertex.SIZE,n0
	move			#>$80,y1
	move			x:<visibleLines,a
	lsl	a		#>InverseTable+$100,r1
	do	a,_loop
	IFNE	1
	move					y:(r0)+,x0	; x0=X
	mpy	x0,y1,a				y:(r0)+,x0	; a=$100X,x0=Y
	move					y:(r0)-,n1	; n1=Z
	mpy	x0,y1,a		a0,x0				; a=$100Y, x0=$100X
	move			a0,y0
	clr	b		x:(r1+n1),x1			; x1=1/(Z+$100)
	move			x1,y1
	mpy	x1,y1,a		#>$80,y1
	rep	#15
	asr	a
	move			a0,x1
	clr	a		#<100,b1
	mac	x1,y0,b		#<160,a1			; b=Y'=$100Y/(Z+$100)
	mac	x1,x0,a				b,y:(r0)-	; a=X'=$100X/(Z+$100), Store Y'.
	move					a,y:(r0)+n0	; Store X'.
	ELSE
	move					y:(r0)+,x0	; x0=X
	mpy	x0,y1,a				y:(r0)+,x0	; a=$100X,x0=Y
	move					y:(r0)-,n1	; n1=Z
	mpy	x0,y1,a		a0,x0				; a=$100Y, x0=$100X
	move			a0,y0
	clr	b		x:(r1+n1),x1			; x1=1/(Z+$100)
	clr	a		#<100,b1
	mac	x1,y0,b		#<160,a1			; b=Y'=$100Y/(Z+$100)
	mac	x1,x0,a				b,y:(r0)-	; a=X'=$100X/(Z+$100), Store Y'.
	move					a,y:(r0)+n0	; Store X'.
	ENDC
_loop:	rts

; Cull out unwanted edges..
cullShit:
; 3: collapse z_avg table to remove culled lines..
	move			#<0,r3				; visible count=0
	move			#>ZCenterTable,r0		; y:(r0):source
	move			#<1,n0
	move			r0,r1				; y:(r1):dest
	move					y:(r0)+,a
	do	x:<visibleLines,_cloop
	tst	a				y:(r0)+,b
	jmi	<_cnext
	move					a,y:(r1)+
	move					b,y:(r1)+
	move			(r3)+				; Increase visible count.
_cnext:	move					y:(r0)+,a
_cloop:	move			r3,x:<visibleLines		; Store # visible lines.
	rts

	IFNE	0
; Separate z culling function.
; Edges too far away are culled, but also ones that are behind the camera.
; PRE: z avg table needs to be filled!
cullZ:
; 2: Apply depthculling first..
	move			#>ZCenterTable,r0
	move			#>-2,n0
	move			#>CULLDIST,y0			; y0=culling depth
	move			#<2,n1
	move					y:(r0)+,a	; a=z(cullflag)
	do	x:<visibleLines,_dloop
	tst	a				y:(r0)+,r1	; y:(r1): edge.
	jmi	<_dnext
	move			(r1)+n1				; y:(r1): z1
	move					y:(r1)+,a	; a=z1
	cmp	y0,a				y:(r1+n1),b	; b=z2
	jlt	<_dnext
	cmp	y0,b		#<$FF,x0
	jlt	<_dnext
	move					x0,y:(r0+n0)	; Mark as culled.
_dnext:	move					y:(r0)+,a	; a=z(cullflag)
_dloop:
	rts
	ENDC

; Clips the lines against the sides of the screen..
; This also marks entries in the z_avg table as culled..
clipXY:	move			#>TransformedLines,r0
	move			#>ZCenterTable,r5
	move			#<2,n5
	move			#<Vertex.SIZE,n1
	move			#<2,n0
	move			r0,r1				; y:(r1): current line
	do	x:<visibleLines,_lineloop

; left
	move					y:(r0)+,a
	move					y:(r0+n0),y1
	or	y1,a		a,b
	jpl	<_left_done
	and	y1,b		b,a
	jmi	<_cull
	tst	a		#<0,x0				; x0='cut_y'
	jpl	<_left2nd
	move			a,x1		y:(r0)+n0,y1	; x1='ystart'=v1.x, y1='xstart'=v1.y
	move					y:(r0)+,a	; a='yend'=v2.x
	sub	x1,a				y:(r0),b	; a='dy', b='xend'=v2.y
	jsr	<intersect
	add	y1,a				x0,y:(r1)+	; Store cut.
	move					a,y:(r1)-	; Store intersected coord.
	jmp	<_left_done	
_left2nd:
	move					y:(r0)+n0,b	; b='xend'=v1.y
	move					y:(r0)+,x1	; x1='ystart'=v2.x
	sub	x1,a				y:(r0)-,y1	; a='dy', y1='xstart'=v2.y
	jsr	<intersect
	add	y1,a				x0,y:(r0)+	; Store cut.
	move					a,y:(r0)	; Store intersected coord.
_left_done:

; right
	move			r1,r0
	move			#>320-1,x0			; x0='cut_y'
	move					y:(r0)+,a
	cmp	x0,a				y:(r0+n0),b
	jgt	<_right1st
	cmp	x0,b
	jle	<_right_done
	move			a,x1		y:(r0)+n0,y1	; x1='ystart'=v1.x, y1='xstart'=v1.y
	move					y:(r0)+,a	; a='yend'=v2.x
	sub	x1,a				y:(r0)-,b	; a='dy', b='xend'=v2.y
	jsr	<intersect
	add	y1,a				x0,y:(r0)+	; Store cut.
	move					a,y:(r0)	; Store intersected coord.
	jmp	<_right_done	
_right1st:
	cmp	x0,b
	jgt	<_cull
	move					y:(r0)+n0,b	; b='xend'=v1.y
	move					y:(r0)+,x1	; x1='ystart'=v2.x
	sub	x1,a				y:(r0)-,y1	; a='dy', y1='xstart'=v2.y
	jsr	<intersect
	add	y1,a				x0,y:(r1)+	; Store cut.
	move					a,y:(r1)-	; Store intersected coord.
_right_done:

; above
	move			r1,r0
	move			#<0,x0				; x0='cut_y'
	move			(r0)+
	move					y:(r0)+,x1
	move					y:(r0+n0),b
	and	x1,b		b,a
	jmi	<_cull						; both above? -> cull it!
	or	x1,a		x1,a
	jpl	<_above_done
	tst	a		(r0)-n0
	jpl	<_above2nd
	move			a,x1		y:(r0)+n0,y1	; x1='ystart'=v1.y, y1='xstart'=v1.x
	move					y:(r0+n0),a	; a='yend'=v2.y
	sub	x1,a				y:(r1+n1),b	; a='dy', b='xend'=v2.x
	jsr	<intersect
	add	y1,a				x0,y:-(r0)	; Store intersected coord.
	move					a,y:-(r0)	; Store cut.
	jmp	<_above_done	
_above2nd:
	move					y:(r0)+n0,b	; b='xend'=v1.x
	move					y:(r0+n0),x1	; x1='ystart'=v2.y
	sub	x1,a				y:(r1+n1),y1	; a='dy', y1='xstart'=v2.x
	jsr	<intersect
	add	y1,a				x0,y:(r0+n0)	; Store cut.
	move					a,y:(r1+n1)	; Store intersected coord.
_above_done:

; under
	move			r1,r0
	move			#>200-1,x0			; x0='cut_y'
	move			(r0)+
	move					y:(r0)+,a
	cmp	x0,a				y:(r0+n0),b
	jle	<_under2nd
	cmp	x0,b		(r0)-n0
	jgt	<_cull						; Both under -> cull!
	move					y:(r0)+n0,b	; b='xend'=v1.x
	move					y:(r0+n0),x1	; x1='ystart'=v2.y
	sub	x1,a				y:(r1+n1),y1	; a='dy', y1='xstart'=v2.x
	jsr	<intersect
	add	y1,a				x0,y:-(r0)	; Store intersected coord.
	move					a,y:-(r0)	; Store cut.
	jmp	<_under_done
_under2nd:
	cmp	x0,b		(r0)-n0
	jle	<_under_done					; Both above -> leave it!
	move			a,x1		y:(r0)+n0,y1	; x1='ystart'=v1.y, y1='xstart'=v1.x
	move					y:(r0+n0),a	; a='yend'=v2.y
	sub	x1,a				y:(r1+n1),b	; a='dy', b='xend'=v2.x
	jsr	<intersect
	add	y1,a				x0,y:(r0+n0)	; Store cut.
	move					a,y:(r1+n1)	; Store intersected coord.
_under_done:

; Check x after y clipping is done (due to inaccuracies of clipping!).
	move					y:(r1),a
	move			#>320,x0
	cmp	x0,a				y:(r1+n1),b
	jhs	<_cull
	cmp	x0,b
	jhs	<_cull

_inc:	move			(r1)+n1
	move			(r1)+n1				; y:(r1): next edge
	move			r1,r0				; y:(r0): next edge
	move			(r5)+n5				; y:(r5): next z_avg
_lineloop:

; z culling was here!

_end:	rts

_cull:	move			#<$FF,x0
	move					x0,y:(r5)	; Mark as invisible.
	jmp	<_inc

; Generic intersection routine.
; INPUT:
; x0: cut_y
; x1: ystart
; y1: xstart
; a: yend - ystart (=dy)
; b: xend
; OUTPUT:
; a0: intersected coord
intersect:
	IFNE	1

; Warning, we assume r2,n2 isn't used!
	sub	y1,b		x0,x:<shit			; b=dx
	move			#>$000040,x0		b,y0	; x0=scalar, y0=dx
	mpy	x0,y0,b		#<InverseTable,r2		; b0=dx<<8
	move			a,n2
	abs	b		b0,a				; n2=dy
	move			b0,y0				; y0=dx<<8
	move			x:(r2+n2),x0			; x0=1/dy
	mpyr	y0,x0,b						; b=dx<<8/dy
	tst	a
	jpl	<_ok
	neg	b
_ok:	move						b,y0
	mpy	-x1,y0,a	x:<shit,x0
;	mac	+x0,y0,a
;	rep	#8
;	asr	a		
;	move			a0,a
	mac	+x0,y0,a	#>$008000,x1
	move			a0,y0
	mpy	x1,y0,a

	ELSE

	sub	y1,b		a,x:<bla			; b= xend-xstart (=dx)
	tfr	b,a						; a=dx, Store dy.
	abs	b		x0,x:<shit			; b=abs(dx)
	move			#>$000080,x0		b,y0	; x0=scalar, y0=abs(dx)
	mpy	x0,y0,b		x:<shit,x0			; b=abs(dx)<<8
	tst	a		x:<bla,y0			; test denominator, y0=dy
	andi	#$fe,ccr					; carry bit cleared by mpy
	rep	#24
	div	y0,b						; b := dx/dy (=slope)
	jpl	<_divisorpos
	neg	b
_divisorpos:
	move			b0,y0				; a= yi= cut_y-ystart, y0= int(slope)
; a := yi(frac) * slope(fixedpoint)
	mpy	+x0,y0,a
	mac	-x1,y0,a
	rep	#8
	asr	a		
	move			a0,a

	ENDC

	rts

; Combsort implementation. In place sorting, not the fastest available
; algorithm... With little RAM there is no choice I'm afraid.
sort:	clr	a		x:<visibleLines,b
	move			#<1,a1
	cmp	a,b		#<2,n1
	jle	<_end
	move			#<2,n2
	move			#<2,n3				; n3=element size
	move			#>ZCenterTable,r0
	lsr	b		b,y0				; b=gapsize[0]=#elements/2
	jmp	<_end_calculate_gap
	
_loop:	cmp	x0,b		#>0.769230769,y1
	tlt	x0,b
	move			b,x1
	mpy	y1,x1,b						; b=gapsize
_end_calculate_gap:
	tfr	y0,a		b,x1
	sub	x1,a		n3,x0
	mpy	x0,x1,a		a,n6
	asr	a		#<0,r4				; r4=swapcount=0
	move			a0,n0
	move			r0,r2
	lua	(r0)+n0,r1

	do	n6,_element_loop
	move					y:(r2)+n2,a	; a=z1
	move					y:(r1)+n1,x0	; b=z2
	cmp	x0,a						; Decrement swapcount (assuming we'll correct it later)..
	jge	<_no_swap
	move					y:-(r2),x1	; x1=adr1
	move					y:-(r1),y1	; y1=adr2
	move					x1,y:(r1)-	; Store adr1.
	move					y1,y:(r2)-	; Store adr2.
	move					a,y:(r1)+n1	; Store z1.
	move					x0,y:(r2)+n2	; Store z2.
	move			(r4)+				; Increment swapcount.
_no_swap:
	nop
_element_loop:

	move			r4,a
	tst	a		#>2,x0
	jne	<_loop
	cmp	x0,b
	jge	<_loop

_end:	rts

; Send lines (2*[x,y,z]) to host..
sendLines:
	move			#>ZCenterTable+1,r0
	move			#<InverseTable,r2
	move			#>5,y1				; Scalar to transform to fixedpoint.
	move			#<2,n0
	move			x:<visibleLines,a
	tst	a		#<3,n1
	send	a
	jeq	<_end
	do	a,_edgeloop
	move					y:(r0)+n0,r1	; Fetch edge addy.
	move			#<$05,y0			; Scalar to transform to integer.
	move					y:(r1+n1),x0	; x0=X2
 	move					y:(r1)+,a	; a=X1
	send	a						; Send X1.
	sub	x0,a				y:(r1+n1),x1	; a=dX=X2-X1, x1=Y2
	move					y:(r1)+,b	; b=Y1
	send	b						; Send Y1.
	send	x0						; Send X2.
	sub	x1,b		a,x0				; b=dY=Y2-Y1, x0=dX
	send	x1						; Send Y2.
	cmpm	b,a						; If a > b..
	tgt	x0,b						; .. d=dX, else d=dY
	abs	b				y:(r1)+n1,x0	; b=|d|, x0=g1
	mpy	x0,y0,a		b,n2				; a=g1 (int), n2=|d|
	send	a						; Send g1 (int).
	mpy	-x0,y1,a			y:(r1)+,x0	; a0=-g1 (fp), x0=g2
	mac	+x0,y1,a	x:(r2+n2),x0			; a0=dg=g2-g1 (fp), x0=1/|d|
	move			a0,x1				; x1=dg (fp)
	mpy	x0,x1,a						; a=g_step=dg/|d| (fp)
	send	a						; Send g_step.
_edgeloop:
_end:	rts

;======== non time-crucial stuff, all in external P-RAM ========

; This initialises the pipeline in pixel-mode.
InitPipeline:
; Set to linear addressing!
	movec	#$FFFF,m0
	movec	m0,m1
	movec	m0,m2
	movec	m0,m3
	movec	m0,m4
	movec	m0,m5
	movec	m0,m6

	jsr	<GetInvTable
	jsr	<GetObject
	rts

; Calculates 1/n table.
GetInvTable:
	move			#<InverseTable,r0
	clr	a		#>1,x0
	do	#INVBUF_SIZE,_loop
	move			a,x1
	move			x0,b
	rep	#24
	div	x1,b
	add	x0,a		b0,x:(r0)+
_loop:	rts

; Gets wireframe object from host..
GetObject:
	get	a
	lsl	a		a,x0
	add	x0,a		x0,x:<numVertices		; a=3*#vertices
	move			#>vertices,r0
	do	a,_vloop
	get	x:(r0)+
_vloop:	get	a
	move			a,x:<numLines
	lsl	a		#>lines,r0			; a=2*#lines
	do	a,_lloop
	get	x:(r0)+
_lloop:	rts

;======== Matrix

; This is perfection.
; Total cycles on 56001: 58 (!)
; INPUT:
; r0: X-sine
; r1: X-cosine
; r2: Y-sine
; r3: Y-cosine
; r4: Z-sine
; r5: Z-cosine
Matrix.generate:
	move			#<Matrix,r6

; XX := + x*cos(b)*cos(c)
; XY := - y*cos(b)*sin(c)
; XZ := + z*sin(b)
	move			x:(r3),x1	y:(r5),y1
; x0:-- x1:r3 y0:-- y1:r5
	mpyr	+x1,y1,a	x:(r0),x0	y:(r4),y0	; r3*r5

; x0:r0 x1:r3 y0:r4 y1:r5
	mpyr	-x1,y0,a	x:(r2),x1	a,y:(r6)+	; -r3*r4
; x0:r0 x1:r3 y0:r2 y1:r5
	move					a,y:(r6)+

	move					x1,y:(r6)+	; r2
	
; YX := + x*sin(a)*sin(b)*cos(c)+cos(a)*sin(c)
; YY := + y*cos(a)*cos(c)-sin(a)*sin(b)*sin(c)
; YZ := - z*sin(a)*cos(b)
	mpyr	+x0,x1,a			y:(r5),y0	; r0*r2
; x0:r0 x1:r3 y0:r5 y1:r5
	move			a,y1
	mpy	+y0,y1,a	x:(r1),x1	y:(r4),y1	; a*r5
; x0:r0 x1:r1 y0:r5 y1:r4
	macr	+x1,y1,a			y:(r5),y1	; a+r1*r4
; x0:r0 x1:r1 y0:r5 y1:r5

	mpy	+x1,y1,a	x:(r2),x1	a,y:(r6)+	; r1*r5
; x0:r0 x1:r2 y0:r5 y1:r5
	mpyr	-x0,x1,b			y:(r4),y0	; r0*r2
; x0:r0 x1:r2 y0:r4 y1:r5
	move			b,y1
	macr	+y0,y1,a	x:(r3),x1	y:(r4),y1	; a+b*r4
; x0:r0 x1:r3 y0:r4 y1:r4

	mpyr	-x0,x1,a	x:(r2),x1	a,y:(r6)+	; r0*r3
; x0:r0 x1:r2 y0:r4 y1:r4

; ZX := + x*sin(a)*sin(c)-cos(a)*sin(b)*cos(c)
; ZY := + y*cos(a)*sin(b)*sin(c)+sin(a)*cos(c)
; ZZ := + z*cos(a)*cos(b)
	mpy	+x0,y1,a	x:(r1),x0	a,y:(r6)+	; r0*r4
; x0:r1 x1:r2 y0:r4 y1:r4
	mpyr	-x0,x1,b	x:(r2),x0	y:(r5),y1	; r1*r2
; x0:r2 x1:r2 y0:r4 y1:r5
	move			b,x1
	macr	+x1,y1,a	x:(r1),x1	y:(r4),y0	; a+b*r5
; x0:r2 x1:r1 y0:r4 y1:r5

	mpyr	+x1,x0,a	x:(r3),x0	a,y:(r6)+	; r1*r2
; x0:r3 x1:r1 y0:r4 y1:r5
	move			a,y1
	mpy	+y0,y1,a	x:(r0),x1	y:(r5),y1	; a*r4
; x0:r3 x1:r0 y0:r4 y1:r5
	macr	+x1,y1,a	x:(r1),x1			; r0*r5
; x0:r3 x1:r1 y0:r4 y1:r5

	mpyr	+x1,x0,a			a,y:(r6)+	; r1*r3

	move					a,y:(r6)+
	rts

p_memory_end:

;======== X-Memory Code ========

	ORG	X:$0000

SineX:	DS	1
CosineX:DS	1
SineY:	DS	1
CosineY:DS	1

TransX:	DS	1
TransY:	DS	1
TransZ:	DS	1

numVertices:
	DS	1
numLines:
	DS	1
visibleLines:
	DS	1
bla:	DS	1
shit:	DS	1

InverseTable:
	DS	INVBUF_SIZE

;======== EXTERNAL X RAM

vertices:
	DS	Vertex.SIZE*MAX_VERTICES
lines:	DS	2*MAX_LINES

x_memory_end:
; X<$3000 !!

	ORG	X:$3BDB						; for mixer

;======== Y-Memory Code ========

	ORG	Y:$0000

SineZ:	DS	1
CosineZ:DS	1

;======== Matrix

Matrix:	DS	Matrix.SIZE

;======== EXTERNAL Y RAM

	ORG	Y:p_memory_end					; out of range from p-code

;======== PrimitiveMesh

transformedVertices:
	DS	Vertex.SIZE*MAX_VERTICES
TransformedLines:
	DS	Vertex.SIZE*2*MAX_LINES
ZCenterTable:
	DS	MAX_LINES*2					; z, linenum
y_memory_end:
; Y<$3BF2 !!

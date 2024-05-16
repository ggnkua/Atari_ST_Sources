; Marching cubes + field generator with dsp. Balltrajects done by host.
; Host is now some sort of slave.
; 12bit precision and 64*64 texture, but it looks decent enough..
; coding by earx 2002

; oops: inaccuracy, normalisation in some spots doesn't work causing
; intersection of normals to go wrong. the resultant shadevector will be
; too short.
; also the same approach causes many unneeded normalcalculations.
; still it's a damn amount faster than a cpu version, hahaha!

; You can change these to your likings, but beware of allowed limits!
NUM_BALLS:	=	3					; #balls in blob
;ISOLEVEL:	=	480					; Change to your liking [0..4095]
WIDTH:		=	10					; #points in gridside, <14 !
DISTANCE:	=	$A000					; Not too small, no clipping!
ROUND:		=	1					; rounding on sqrt (y/n)

; Don't touch the following equates.
PLANE_SIZE:	=	WIDTH*WIDTH
FIELD_SIZE:	=	WIDTH*WIDTH*WIDTH
CUBES:		=	WIDTH-1					; #cubes in a row
GWIDTH:		=	$4000					; width of entire grid
CUBEWIDTH:	=	GWIDTH/CUBES

HSR:		=	$FFE9
HTX:		=	$FFEB

get:	MACRO
	jclr	#0,x:<<HSR,*
	movep	x:<<HTX,\1
	ENDM

send:	MACRO
	jclr	#1,x:<<HSR,*
	movep	\1,x:<<HTX
	ENDM

	org	p:0
	jmp	<main

	org	p:$40

main:	jsr	<init

_loop:	jsr	<getBallPositions
	jmp	<keepstacklow					; yeah, laugh please!

;- graphical routines ------------------------------------------------------
;
;

; Polygonizes the grid and sends polygons to host.
; This works from back to front, so depthsorting is not required.
; Note: no subroutine, jumps back to mainloop!
paintGrid:
	move			#field,r0
	move			#gradfield,r1
	move			#>DISTANCE-CUBEWIDTH,x0
	move			x0,x:<posz

_zloop:	move			#>-GWIDTH/2,x0
	move			x0,x:<posy

_yloop:	move			#>-GWIDTH/2,x0
	move			x0,x:<posx

_xloop:
; Copy cube to table, order: lower square anticlock, upper square anticlock.
	move			#<WIDTH,n0
	move			#<cube,r4
	move			(r0)+n0
	move			#>PLANE_SIZE,n0
	move			x:(r0)+,b			; width
	move			x:(r0)+n0,a	b,y:(r4)+	; 1+width
	move			#>-WIDTH-PLANE_SIZE,n0
	move			x:(r0)-,b	a,y:(r4)+	; 1+width+planesize
	move			x:(r0)+n0,a	b,y:(r4)+	; width+planesize
	move			#>PLANE_SIZE,n0
	move			x:(r0)+,b	a,y:(r4)+	; 0
	move			x:(r0)+n0,a	b,y:(r4)+	; 1
	move			x:(r0)-,b	a,y:(r4)+	; 1+planesize
	move			x:(r0)+,a	b,y:(r4)+	; planesize
	move					a,y:(r4)+	; 
	move			(r0)-n0				; 1 (next cube)

; Get inside/outside flags..
	move			#<cube,r4
	move			x:<isolevel,b ;#>ISOLEVEL,b
	clr	a		#>$100,x1
	move					y:(r4)+,x0
	do	#8,_side_loop
	cmp	x0,b
	jlt	<_nextside
	or	x1,a
_nextside:
	lsr	a				y:(r4)+,x0
_side_loop:

; Only polygonize if cube contains polygons.
	move			#>edgeTable,r2
	move			a,n2
	move			a,x:<cubeIndex
	move			x:(r2+n2),a
	tst	a		a,x:<edgesCut
	jne	<polygonize
	
_next:	move			#<2,n1
	move			x:<posx,a
	move			#>CUBEWIDTH,x0
	add	x0,a		(r1)+n1				; Proceed to next cube.
	move			#>CUBEWIDTH*CUBES-GWIDTH/2,x0	; Compensate for steperror.
	cmp	x0,a		a,x:<posx
	jlt	<_xloop

	move			#<2,n1
	move			x:<posy,a
	move			#>CUBEWIDTH,x0
	add	x0,a		(r0)+				; Proceed to next cube in y direction.
	move			(r1)+n1
	move			#>CUBEWIDTH*CUBES-GWIDTH/2,x0	; Compensate for steperror.
	cmp	x0,a		a,x:<posy
	jlt	<_yloop

	move			#<WIDTH,n0
	move			#<WIDTH*2,n1
	move			x:<posz,a
	move			#>CUBEWIDTH,x0
	sub	x0,a		(r0)+n0				; Proceed to next cube in z direction.
	move			(r1)+n1
	move			#>DISTANCE-CUBEWIDTH*CUBES,x0
	cmp	x0,a		a,x:<posz
	jge	<_zloop

	send	#-1						; I'll be back!
	jmp	<main_loop

; Polygonizes the isosurface within a cube.
; Note: no subroutine, jumps back to paintGrid_next.
; INPUT:
; x:r0: grid (V)
; x:r1: grad (u,v)
polygonize:
	move			r0,x:<tempR0
	move			r1,x:<tempR1

; Store (x,y,z) vertices in cubevertices..
	move			#<posx,r2
	move			#<cubeSrcVertices,r5
	move			#<cubeDstVertices,r4
	move			#<5-2,n4

	do	#8,_vertexloop
	move			x:(r2)+,x0	y:(r5)+,a	; x0=tx, a=x
	add	x0,a		x:(r2)+,x0	y:(r5)+,b	; a=x+tx, x0=ty, b=y
	add	x0,b				a,y:(r4)+	; b=y+ty, Store x+tx.
	move					b,y:(r4)+	; Store y+ty.
	move			x:(r2)-,x0	y:(r5)+,a	; x0=tz, a=z
	add	x0,a		(r2)-				; a=z+tz
	move					a,y:(r4)+n4	; Store z+tz, Proceed to next dst vertex.
_vertexloop:

; Store normals (u,v) in cubevertices.
	move			#<WIDTH*2,n1
	move			#<cubeDstVertices+3,r4
	move			#<4,n4				; n4=vectorwidth-1
	move			(r1)+n1
	move			x:(r1)+,b			; width
	move			x:(r1)+,a	b,y:(r4)+
	move			#>PLANE_SIZE*2-1,n1
	move			x:(r1)+,b	a,y:(r4)+n4	; 1+width
	move			x:(r1)+n1,a	b,y:(r4)+
	move			#>-3,n1
	move			x:(r1)+,b	a,y:(r4)+n4	; 1+width+planesize
	move			x:(r1)+n1,a	b,y:(r4)+
	move			#>-(WIDTH+PLANE_SIZE)*2-1,n1
	move			x:(r1)+,b	a,y:(r4)+n4	; width+planesize
	move			x:(r1)+n1,a	b,y:(r4)+
	move			x:(r1)+,b	a,y:(r4)+n4	; 0
	move			x:(r1)+,a	b,y:(r4)+
	move			#>PLANE_SIZE*2-1,n1
	move			x:(r1)+,b	a,y:(r4)+n4	; 1
	move			x:(r1)+n1,a	b,y:(r4)+
	move			#>-3,n1
	move			x:(r1)+,b	a,y:(r4)+n4	; 1+planesize
	move			x:(r1)+n1,a	b,y:(r4)+
	move			x:(r1)+,b	a,y:(r4)+n4	; planesize
	move			x:(r1),a	b,y:(r4)+
	move					a,y:(r4)

; Calculate intersected vertices.
	move			#<edgesCut,r5
	move			#<cube,r0			; r0: cube containing field
	move			#<edgeRefTable,r2
	move			#<cubeDstVertices,r4
	move			#<vertexTable,r6
	move			#<5,n6
	move			x:(r5),a

_intersectloop:
	lsr	a				y:(r2)+,y0	; Test lsb, b=v1 index
	jcc	<_next_edge
	move			n6,x0				; x0=vectorsize
	mpy	y0,x0,b		y0,n0				; n0=v1 index
	asr	b		a,x:(r5)	y:(r2),y0	; b0=v1 offset, Store cutedges, y0=v2 index
	mpy	y0,x0,b		b0,n4				; n4=v1 offset
	asr	b				y:(r0+n0),x1	; b0=v2 offset, x1=value1
	lua	(r4)+n4,r3					; r3: vector1
	move			y0,n0				; n0=v2 index
	move			b0,n4				; n4=v2 offset
	move					y:(r0+n0),a	; a=value2
	move			x:<isolevel,b ;#>ISOLEVEL,b			; b=isolevel
	lua	(r4)+n4,r1					; r1: vector2
	jsr	<intersect					; Intersect the 5d line.

; Perspectivate the intersected vertex...
; todo: we're able to only do 16 div iterations, by prescaling Z.
	move			#>128,y1
	move			(r6)-n6
	move					y:(r6)+,x0	; x0=X
	mpy	y1,x0,a				y:(r6)+,x1	; x1=Y
	mpy	y1,x1,a		a0,x0				; x0=X<<8
	move			a0,x1				; x1=Y<<8
	move			#>1,a				; a=1
	move					y:(r6)-,y0	; y0=Z [1..8192]
	andi	#$FE,ccr
	rep	#24
	div	y0,a						; a0=1/Z
	move			a0,y0				; y0=1/Z
	move			#>100,a				; a=x_center
	move			#>160,b				; b=y_center
	macr	y0,x0,a		(r6)-				; a=X'
	macr	y0,x1,b				a,y:(r6)+	; b=Y', Store X'.
	move					b,y:(r6)-	; Store Y'.
	move			x:<edgesCut,a			; a=cut edges (shifted)

_next_edge:
	move			(r2)+				; Proceed to next indexpair.
	tst	a		(r6)+n6				; Proceed to next dst vertex.
	jne	<_intersectloop

; Generate the triangles...
	move			x:<cubeIndex,x0
	move			#8,x1
	mpy	x0,x1,a		#>triTable,r0
	move			a0,n0
	move			#<vertexTable,r6
	move			(r0)+n0

_triloop:
	move			#<triangle,r1
	move			x:(r0),a
	tst	a		#>5,x0				; End of triangle list?
	jmi	<_end

	do	#3,_trivertexloop
; Store (x,y) and unsign, scale and store (u,v).
	move			x:(r0)+,x1
	mpy	x0,x1,a		#<vertexTable,r6
	asr	a		#<$80,x1			; a0=offset to vertex, x1=signer
	move			a0,n6				; n6=offset to vertex
	move			#>$000800,y1			; y1=upscalar
	move			(r6)+n6				; r6: vertex
	move					y:(r6)+,a	; a= X'
	move			a,x:(r1)+	y:(r6)+,b	; b= Y', Store X'.
	move			b,x:(r1)+	y:(r6)+,a	; Store Y', dummy move.
	move					y:(r6)+,y0	; y0=u (12b)
	mpy	y1,y0,a				y:(r6),y0	; a0=u (23b), y0=v (12b)
	mpy	y1,y0,b		a0,a				; b0=v (23b)
	eor	x1,a		b0,b				; Sign u.
	eor	x1,b		#<triangle,r2			; Sign v.
	lsr	a		#<3,n2				; Adjust u range [0..$7FFFFF]
	lsr	b		a1,x:(r1)+			; Adjust v range [0..$7FFFFF], Store u (unsaturated).
	move			b1,x:(r1)+			; Store v (unsaturated).
_trivertexloop:

; Perform backface culling...
	move			x:(r2)+,a			; a=X1
	move			x:(r2)+n2,b			; b=Y1
	move			x:(r2)+,x0			; x0=X2
	sub	x0,a		x:(r2)+n2,x1			; a=X1-X2, x1=Y2
	sub	x1,b		x:(r2)+,a	a,y1		; b=Y1-Y2, a=X3, y1=X1-X2
	sub	x0,a		x:(r2),b	b,y0		; a=X3-X2, b=Y3, y0=Y1-Y2
	sub	x1,b		a,x0				; b=Y3-Y2, x0=X3-X2
	mpy	+x0,y0,a	b,x1				; a=-(X3-X2)(Y1-Y2), x1=Y3-Y2
	mac	-y1,x1,a	r0,x:<saveR0			; a=+(X1-X2)(Y3-Y2)-(X3-X2)(Y1-Y2), Save tritable pos.
	jle	<_triloop					; n.z<=0 ? -> cull it.

; Paint the triangle.. Note: no clipping!
	move			#<triangle,r0
	jsr	<Polygon.getDimensions
	move			#<triangle,r0
	move			#<triangle+3*4,r5
	move			r0,r6
	do	#4,_wraploop
	move			x:(r0)+,x0
	move			x0,x:(r5)+
_wraploop:	
	jmp	<paintTriangle
_next_tri:
	move			x:<saveR0,r0
	jmp	<_triloop

_end:	move			x:<tempR0,r0
	move			x:<tempR1,r1
	jmp	<paintGrid_next

; Intersect a 5d line. Coordinates should have 16bit signed range!
; slope = (isolevel-v1)/(v2-v1)
; timing: 75+2n+(4/2) cycles =>{n=24}=>123+(4/2)
; INPUT:
; b = isolevel
; x1= v1
; a = v2
; y:r3: vertex1
; y:r1: vertex2
; y:r6: dst vertex
; OUTPUT:
; y:r6: next dst vertex
intersect:
	sub	x1,b		#>256,y0			; b=isolevel-v1, y0=upscalar
	sub	x1,a				b,y1		; a=v2-v1, y1=isolevel-v1
	mpy	y0,y1,b		a,x0				; b0=(isolevel-v1)<<(8+n), x0=v2-v1 (denominator)
	abs	b				y:(r3)+,x1	; Make numerator positive (required by div), x1=p1[0]
	eor	y1,a				y:(r1)+,y0	; Get sign (saved for jpl), y0=p2[0]
	andi	#$FE,ccr					; Clear carrybit (required by div).
	rep	#24
	div	x0,b						; b= (isolevel-v1)<<8/(v2-v1) = slope
	jpl	<_signed					; Sign quotient if appropriate.
	neg	b
_signed:tfr	y0,b		b0,y1				; b=p2[0], y1=slope
	sub	x1,b		#>1<<14,x0			; a=p2[0]-p1[0]=d[0], x0=downscalar

	do	#5,_loop
	tfr	x1,a		b,y0				; a=p1[n], y0=d[n]
	mpy	y1,y0,b				y:(r3)+,x1	; b=slope*d[n], x1=p1[n+1]
	move			b0,y0				; y0=slope*d[n]
	macr	y0,x0,a				y:(r1)+,b	; a=p1[n]+slope*d[n]=coord, b=p2[n+1]
	sub	x1,b				a,y:(r6)+	; b=d[n+1], Store coord.
_loop:
	rts

;- polygon routines --------------------------------------------------------
;
;

; Not a subroutine, returns to polygonize_next_tri.
; Definetely the fastest scan converter around.
; USES:
; x:Polygon.vsize: 1=flat shade, 2=gouraud, 3=tmap, 4=gourtmap, 5=envtmap/bump
; INPUT:
; x:(r6): polygon table
; PRE:
; polygon must be wrapped
paintTriangle:
	move			#<3,n6
	move			#>InverseTable,r3
	move			#>Polygon.LeftEdge,r0
	move			#>Polygon.RightEdge,r1
	move			n6,n5
	move			n6,r4
	move			r6,r5
	move			(r4)+
	move			(r6)+n6				; to next point
	move			(r6)+
	move			r4,n4				; n4= offset to next point

; r5: pt1, r6: next pt
	do	x:<Polygon.points,_do_line
	move			x:(r5)+,a			; a=current point's y
	move			r6,r4
	move			x:(r6)+,b			; b=next point's y
	sub	a,b		x:<Polygon.top,y1
	jlt	<_do_left_side
	jeq	<_end_line
	move			b,n3
	move			r0,b
	jmp	<_end_swap
_do_left_side:
; Calculate start y offset.
; Swap left and right edges.
	add	b,a		r5,x0
	neg	b		r6,r5
	move			b,n3
	move			x0,r6
	move			r1,b
_end_swap:
	sub	y1,a		n6,x0 				; a=startoffset
	move			a,y1
	mpy	x0,y1,a						; a0=startoffset*vsize*2
	asr	a		n6,n2				; a0=startoffset*vsize 
	move			a0,x0
	add	x0,b		r0,y0
	move			b,r0

; Speedy.. but could be better when doing u and v in one go.
	do	n6,_coord_loop
	move			x:(r5)+,x0			; x0= left x
	tfr	x0,a		x:(r6)+,b			; a= left x, b= right x
	sub	x0,b				y:(r3+n3),y1	; b=x1-x0=dx, y1=1/dy
	move			b1,x1				; x1=dx
	mpy	x1,y1,b		r0,r2 				; b=x1/dy, r2=edge

; rep is shit with interrupts :(
;	rep	n3
	do	n3,_bla
	add	b,a				a1,y:(r2)+n2	; a=lx:=lx+step, store lx
_bla:

	move			(r0)+				; Proceed to next coord.
_coord_loop:
	move			y0,r0				; Back to x coord

_end_line:
	move			r4,r5				; r5=current point
	lua	(r4)+n4,r6					; r6=next point
_do_line:

; Paints (sends to host) a texturemapped polygon.
	send	x:<Polygon.top					; Send minimum y.
	move			x:<Polygon.height,a		; a=height
	send	a						; Send height.
	tst	a		a,n6				; n6=height
	jle	<polygonize_next_tri				; Next triangle..
	move			#>Polygon.LeftEdge,r0
	move			#>Polygon.RightEdge,r1
	move			#>InverseTable,r2
	move			#>texture,r4

; hline loop
	do	n6,_yloop

	move					y:(r0)+,x0
	send	x0						; Send lx.
	move					y:(r1)+,a	; a=rx.
	sub	x0,a				y:(r0)+,x0	; x0=u_start
	move			a1,n2				; n2=width
	send	a1						; Send width.
	move					y:(r1)+,x1	; x1=u_end
	move					y:(r0)+,y0	; y0=v_start
	move					y:(r1)+,b	; b=v_end
	tst	a		x1,a				; test for 0-width, a := u_end
	jle	<_skip_line
	sub	x0,a				y:(r2+n2),x1	; du=u_end-u_start, x1=divisor
	sub	y0,b		a1,y1				; dv=v_end-v_start, y1=du
	mpy	x1,y1,a		b1,y1				; a=u_step=du/divisor, y1=dv
	mpy	x1,y1,b		a1,x1				; b=v_step=dv/divisor, x1=u_step
	tfr	x0,a		b1,x0				; a1=u, x0=v_step
	move			y0,a0				; a0=v
	
; a1=u, a0=v, x1=u_step, x0=v_step
	move			x:<texturesize,y0
	move			x,l:<u0_step
	move			a1,y1

; Only nonnegative coords permitted!
; (0,0) (7FFFFF,0)
; x     x
;
;    x(3FFFFF,3FFFFF)
;
; x     x(7FFFFF,7FFFFF)
; (0,7FFFFF)

; 5 calculation instructions = 5*2 = 10 cycles
; 1 host send >= 8 or 10 cycles
; total >= 18 or 20 cycles per pixel
	do	n2,_send_pixel
	mpyr	y1,y0,b		l:<texturemask,x		; b=offset=u*texturesize, x1=width, x0=mask
	and	x0,b		a0,y1				; kill frag_u, y1=v
	mac	y1,x1,b		l:<u0_step,x			; offset:=offset+v, x1=u_step, x0=v_step
	add	x,a		b1,n4				; u:=u+u_step, v:=v+v_step
	move			a1,y1				; y1=u
	jclr	#1,x:<<HSR,*					; Wait until host is ready.
	movep	y:(r4+n4),x:<<HTX				; Send texturepixel.
_send_pixel:

_skip_line:
	nop
_yloop:	jmp	<polygonize_next_tri				; Next triangle..

; Get top and bottom of polygon.
; INPUT:
; x:(r0): polygon table
Polygon.getDimensions:
	move			#>$7FFFFF,a			; top := MAX_INT
	move			#<$80,b				; bottom := MIN_INT
	move			x:<Polygon.vsize,n0

	do	x:<Polygon.points,_loop
	move			x:(r0)+,y0			; Fetch Vertex.Y.
	cmp	y0,a		(r0)+n0				; Proceed to next Vertex.
	tgt	y0,a						; If new value is lower, set new top.
	cmp	y0,b
	tlt	y0,b						; If new value is higher, set new bottom.
_loop:
	sub 	a,b		a,x:<Polygon.top		; Store top, height := bottom-top
	move			b,x:<Polygon.height		; Store height.
	rts

;- field routines ----------------------------------------------------------
;
;

; Get centers of balls from host.
getBallPositions:
	get	x:isolevel
	move			#<posTable,r0
	move			#>GWIDTH*2/9,x1
	do	#3*NUM_BALLS,_loop
	get	x0
	mpy	x1,x0,a
	move			a,x:(r0)+			; Store coordinate.
_loop:	rts

; field and paint combined, no subrout, jumps back to main_loop.
keepstacklow:
;---------------------------------------------------------------------------
; Calculates a metaball field.. Pretty intense due to div and sqrt.
;
; n:  amount of balls
; bi: ball number i
; ri: radius of ball
;
;     2                2          2          2
; (ri)      =  (x-bi.x) + (y-bi.y) + (z-bi.z)
;
;              -- n
; V(x,y,z)  =  \        -2
;              /    (ri)
;              -- 1
;               
;              -- n
;              \          -4 [bi.x-x]
; grad(V)   =  /    2*(ri)  *[bi.y-y] (and then to normalise it..)
;              -- 1          [bi.z-z]
;
;---------------------------------------------------------------------------
; Preparations: calculate (squared) distances
	move			#<distTable,r1
	move			#distSTable,r4
	move			#>GWIDTH/2,a
	move			#>CUBEWIDTH,x1

	do	#WIDTH,_widthloop
	tfr	a,b		#<posTable,r0

	do	#NUM_BALLS*3,_coordloop
	move			x:(r0)+,x0			; x0=coord
	sub	x0,b						; b=distance
	move			b,x:(r1)+	b,y0		; Store distance.
	mpy	y0,y0,b						; Square distance.
	tfr	a,b		b,l:(r4)+			; b=gridoffset, Store square.
_coordloop:

	sub	x1,a						; a=next gridoffset
_widthloop:

; Calculate field and normals..
	move			#gradfield,x0
	move			#field,r0
	move			x0,x:<tempR1			; Save gradfield adr.
	move			#distSTable+2,r1
	move			#<distTable+2,r4
	move			#<3,n3
	move			#<3,n6

_zloop:	move			#distSTable+1,r2
	move			#<distTable+1,r5

	do	#WIDTH,_yloop
	move			#distSTable,r3
	move			#<distTable,r6

	do	#WIDTH,_xloop
	move			#<NUM_BALLS,n0

; Step 1: calculate actual field
	clr	a		r1,x:<zDistAdr			; Save dz adr.
	move			a,x:<val			; Clear value.
	move			#<3,n1
	move			#<3,n2

	do	#NUM_BALLS,_bloop
	clr	b		l:(r1)+n1,a			; a=dz^2
	move			l:(r2)+n2,x			; x=dy^2
	add	x,a		l:(r3)+n3,x			; a=dy^2+dz^2, x=dx^2
	add	x,a		#>$000800,y0			; a=r^2=dx^2+dy^2+dz^2, y0=downscalar
	move			a0,b1
	lsr	b		a1,x1				; shift b for frac dumbness
	mpy	y0,x1,b		b,x0				; b0=scaled r (int), x0=r (frac)
	mpy	y0,x0,a		b0,b				; a1=scaled r (frac), b=scaled r (int)
	addl	b,a		y0,b				; a1=scaled r, b=1<<shift
	move			a1,x0				; x0=scaled r
	rep	#24
	div	x0,b						; b0=r^-2
	move			x:<val,a0			; a0=partial value[n-1]
	add	b,a		b0,x0				; x0=r^-2, a0=partial value[n]
	mpy	x0,x0,a		a0,x:<val			; a0=r^-4, Store partial value[n].
	move			a,x:(r0)+			; Store r^-4.
_bloop:	move			x:<val,a1
	lsr	a		#<3,n4
	move			a1,x0
	mpy	y0,x0,a		#<3,n5				; a=downscaled value
	move			a1,x:<val			; Store value.

; Step 2: calculate gradient vector
	clr	a		(r0)-n0				; a=0, r0: first r^-4
	do	#NUM_BALLS,_gloopz
	move			x:(r0)+,x0			; x0=r^-4
	move			x:(r4)+n4,x1			; x1= dz
	mac	x0,x1,a						; a=dz/r^4+..
_gloopz:move			a,y0				; y0=dz/r^4+..
	clr	a		(r0)-n0				; a=0, r0: first r^-4
	do	#NUM_BALLS,_gloopy
	move			x:(r0)+,x0
	move			x:(r5)+n5,x1			; x1= dy
	mac	x0,x1,a						; a=dy/r^4+..
_gloopy:move			a,y1				; y1=dy/r^4+..
	clr	a		(r0)-n0				; a=0, r0: first r^-4
	do	#NUM_BALLS,_gloopx
	move			x:(r0)+,x0
	move			x:(r6)+n6,x1			; x1= dx
	mac	x0,x1,a						; a=dx/r^4+..
_gloopx:
	mpy	y0,y0,a		a,x0				; dx^2/r^8, x0=dx/r^4
	mac	x0,x0,a		y1,x1				; dx^2/r^8+dy^2/r^8, x1=dz/r^4
	mac	x1,y1,a		x0,y0				; dx^2/r^8+dy^2/r^8+dz^2/r^8, y0=dy/r^4
	asr	a		(r0)-n0				; Adjust fracshit, Save field adr.

	move			r0,x:<tempR0
	move			a0,a				; a1= int
	clr	b		#>1,x1				; b1 will be left_part(number) - (r0/2)**2
	move			b,r0				; r0 will be sqrt(number) * 2
	move			a1,b0				; b0= number [shifts left into b1]
	move			#<2,n1
	do	#12+ROUND,_loop					; 2 bits at a time for 24 bits in total
	asl	b		r0,n0
	asl	b						; b1= left_part(number)
	tfr	b,a		(r0)+n0				; a1/a0 is copy of b1/b0, r0:=2*r0
	sub	x1,a		r0,r1
	move	r0,x0
	sub	x0,a		(r1)+n1				; a1=b1-r0-1, r1=r0+2
	tpl	a,b		r1,r0				; if b1>r0 then b1:=b1-r0-1, r0:=r0+2
_loop:	move			r0,a				; a1=r0
	asr	a		x:<tempR0,r0			; a1=r0/2 = sqrt(number), r0: field 
	IFNE	ROUND
	move			#<2,a0				; Force round up not convergent rounding
	asr	a
	rnd	a						; Round up, a1=sqrt
	ENDC

	move			x:<tempR1,r1			; r1: gradfield
	clr	a		a1,x0				; x0=sqrt
	move			#>$7FFFFF,a0			; a=.999999
	rep	#24
	div	x0,a						; a0=1/sqrt(dx^2/r^8+dy^2/r^8+dz^2/r^8)
	move			a0,x0
	mpy	x0,y0,a		#>$000800,x1			; a=dy/r^4*sqrt(dx^2/r^8+dy^2/r^8+dz^2/r^8)=n.x, x1=downscalar
	mpy	x0,y1,b		a0,y0				; b=dx/r^4*sqrt(dx^2/r^8+dy^2/r^8+dz^2/r^8)=n.y, y0=n.x
	mpy	x1,y0,a		b0,y1				; a=scaled n.x, y1=n.y
	mpy	x1,y1,b		a,x:(r1)+			; b=scaled n.y, store n.x.
	move			b,x:(r1)+			; Store n.y.
	move			r1,x:<tempR1			; Save gradfield adr.

	move			x:<val,x0			; x0=value
	move			x0,x:(r0)+			; Store value at right place, and proceed to next.
	move			#<NUM_BALLS*3,n2
	move			#<NUM_BALLS*3,n4
	move			#<NUM_BALLS*3,n5
	move			x:<zDistAdr,r1			; r1: dz^2
	move			(r2)-n2				; Reset dy^2.
	move			(r4)-n4				; Reset dz.
	move			(r5)-n5				; Reset dy.
_xloop:

	move			#<NUM_BALLS*3,n2
	move			#<NUM_BALLS*3,n5
	move			(r2)+n2				; Proceed to next dy^2.
	move			(r5)+n5				; Proceed to next dy.
_yloop:

	move			#<NUM_BALLS*3,n1
	move			#<NUM_BALLS*3,n4
	move			(r1)+n1				; Proceed to next dz^2.
	move			(r4)+n4				; Proceed to next dz.
	move			r1,a
	move			#>distSTable+2+NUM_BALLS*3*WIDTH,x0
	cmp	x0,a						; Done all?
	jlt	<_zloop						; no -> loop
	jmp	<paintGrid					; yes -> end and paint

;- various -----------------------------------------------------------------
;
;

; Initialization routine..
init:
; Initialize poly stuff..
	move			#>3,x0
	move			x0,x:<Polygon.vsize
	move			x0,x:<Polygon.points

; Init trajectory thru host comms.
	send	#NUM_BALLS					; Request amount from host.

; Receive buffers.
	move			#>4096,n0
	move			#>texture,r0
	do	n0,_txtloop
	get	y:(r0)+
_txtloop:
	move			#>edgeTable,r0
	do	#256,_edgeloop
	get	x:(r0)+
_edgeloop:
	move			#>triTable,r0
	do	n0,_triloop
	get	x:(r0)+
_triloop:

; Calculate inversetable.
	move			#>InverseTable,r0
	clr	a		#>1,x0
	do	#200,_invloop
	tfr	x0,b		a,x1
	andi	#$FE,ccr
	rep	#24
	div	x1,b
	add	x0,a				b0,y:(r0)+
_invloop:

	rts

;= x memory ================================================================

	org	x:0

; poly paint stuff
texturewidth:
	dc	64						; texture v width
u0:	ds	1
u0_step:ds	1						; u_step storage
texturesize:
	dc	64*64						; texture size

posx:	ds	1
posy:	ds	1
posz:	ds	1

Polygon.top:
	ds	1
Polygon.height:
	ds	1
Polygon.points:
	ds	1
Polygon.vsize:
	ds	1
cubeIndex:
	ds	1
edgesCut:
	ds	1
tempR0:	ds	1
tempR1:	ds	1
saveR0:	ds	1
zDistAdr:
	ds	1
val:	ds	1
isolevel:
	ds	1

triangle:
	ds	4*4

posTable:
	ds	NUM_BALLS*3					; (x,y,z)
distTable:
	ds	WIDTH*NUM_BALLS*3				; a00(x,y,z),b01(x,y,z),....,

;= external x memory =======================================================

	org	x:$300

distSTable:
	ds	WIDTH*NUM_BALLS*3				; long mem crap, must be in phase with y mem!
edgeTable:
	ds	256
triTable:
	ds	4096
field:	ds	FIELD_SIZE+NUM_BALLS				; V, overflow required for opt!
gradfield:
	ds	FIELD_SIZE*2					; (u,v)
x_end:

;= internal y memory =======================================================

	org	y:0

; poly paint stuff
texturemask:
	dc	$000FC0						; v_frag mask
v0:	ds	1
v0_step:ds	1						; v_step storage
vertexTable:
	ds	12*5						; intersected vertices (x,y,z,u,v)
cubeSrcVertices:
	dc	0,CUBEWIDTH,CUBEWIDTH
	dc	CUBEWIDTH,CUBEWIDTH,CUBEWIDTH
	dc	CUBEWIDTH,CUBEWIDTH,0
	dc	0,CUBEWIDTH,0
	dc	0,0,CUBEWIDTH
	dc	CUBEWIDTH,0,CUBEWIDTH
	dc	CUBEWIDTH,0,0
	dc	0,0,0
edgeRefTable:
	dc	0,1,1,2,3,2,0,3					; front
	dc	4,5,5,6,7,6,4,7					; back
	dc	0,4,1,5,2,6,3,7					; joint
cube:	ds	8
cubeDstVertices:
	ds	8*5

;= external y memory =======================================================

	org	y:$300

;distSTable:
	ds	WIDTH*NUM_BALLS*3				; long mem crap, must be in phase with x mem!
InverseTable:
	ds	200
texture:ds	4096						; 64*64 highcolor texture
Polygon.LeftEdge:
	ds	3*200						; (x,u,v)*scans
Polygon.RightEdge:
	ds	3*200
y_end:

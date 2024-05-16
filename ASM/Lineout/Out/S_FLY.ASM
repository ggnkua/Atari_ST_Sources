; --------------------------------------------------------------------------
;
; human fly - dsp part
;
; Global:
;
; This is useable as both:
; - a serial CPU<->DSP pipeline
; - a parallel CPU<->DSP pipeline
;
; This program leaves enough DSP RAM free to enable the use of a dsp module
; player. Some sacrifices had to be made.
;
; Limitations:
; - max viewport width = 320
; - max viewport height = 200
;
; NOTE: you can increase these when you decrease #polys or don't want dsp
; mixer!
;
; Remote Procedure Calls and a command stack are provided to provide
; generic behaviour.
;
; Please note there are two ways to do texturemapping. The first is storing
; textures in dsp ram and sending pixels. This enables the fastest
; texturemapping. The second is sending offsets, which is somewhat slower.
; "Polygon.storeTexture" can store two highcolor and two 7bpp
; 64*64 textures.
;

; TODO: Optimise texture-vertex table -> in poly stuff
;       This would save loads of space!

; TODO: Optimize MeshElement to only 2 words. This saves alot of
;       X RAM. Requires changing TransformObject.transform,
;       PrimitiveMesh.sort and PrimitiveMesh.paint.
;       $oopppp:$--zzzz (o: object handle, p: primitive address, z: depth)

;======== GLOBAL EQUATES ========

PBC:				=	$FFE0			; Port B Control Register
HSR:				=	$FFE9			; Host Status Register
HRX:				=	$FFEB			; Host Receive Register
HTX:				=	$FFEB			; Host Transmit Register

; Host Status Register Bit Flags
HRDF:				=	0			; Host Receive Data Full
HTDE:				=	1			; Host Transmit Data Empty

INVBUF_SIZE:			=	320			; = max(MAX_X,MAX_Y)

	INCLUDE	H_FLYRPC.I

;======== Dispatcher

Dispatcher.MAX_COMMANDS:	=	512

;======== ObjectRegistry

Object.CAPACITY:		=	8192
Object.MAX_OBJECTS:		=	32			; max. amount of transformed objects

;======== BoundingBox

; yes it's true, there are 8 corners in a box, now go somewhere else,
; fartface. i.e. 2 corner notation..
BoundingBox.SIZE:		=	3*2

;======== Viewport

Viewport.MAX_Y:			=	200			; Unfortunate... But this eats mem!
Viewport.SIZE:			=	Viewport.settingsTableEnd-Viewport.settingsTable

;======== Polygon

Polygon.TEXTUREBUFFER_SIZE:	=	64*64*2			; able to store two 64*64 bitmaps

; wrappable texturing on/off
WRAPCRAP:			=	1

;======== PrimitiveMesh

PrimitiveMesh.MAX_ELEMENTS:	=	1000
PrimitiveMesh.MAX_VERTICES:	=	900			; Depends on MAX_Y.

;======= Vertex

; That's right. For speedreasons the Y comes before the X!
Vertex.Y:	=	0
Vertex.X:	=	1
Vertex.Z:	=	2
Vertex.SIZE:	=	3

;======= Primitive

Primitive.TYPE:	=	0					; primitive/shading/extended type

;======= Line

Line.TYPE:	=	0					; primitive/shading/extended type
Line.VERTEX1:	=	1					; offset to vertex 1
Line.VERTEX2:	=	2					; offset to vertex 2
Line.SIZE:	=	3

;======= Sprite

Sprite.TYPE:	=	0					; primitive/shading/extended type
Sprite.VERTEX:	=	1					; offset to vertex
Sprite.SIZE:	=	2

Primitive.SHADEMASK:	=	%1110000000000000
Primitive.SHADEMUL:	=	%10000000000

; Shade types for sprites
Sprite.REPLACED:	=	%0000000000000000
Sprite.MIXED:		=	%0010000000000000

; Shade types for polygons
Line.FLATSHADED:	=	%0000000000000000
Line.GOURAUDSHADED:	=	%0010000000000000
Line.PHONGSHADED:	=	%0100000000000000

; Shade types for polygons
Polygon.FLATSHADED:	=	%0000000000000000
Polygon.GOURAUDSHADED:	=	%0010000000000000
Polygon.PHONGSHADED:	=	%0100000000000000
Polygon.TEXTUREMAPPED:	=	%0110000000000000
Polygon.ENVMAPPED:	=	%1000000000000000
Polygon.ALPHATEXTURED:	=	%1010000000000000
Polygon.BUMPMAPPED:	=	%1100000000000000

; Primitive types
Primitive.TYPEMASK:	=	%0001110000000000
Primitive.TYPESHIFT:	=	10
Primitive.TYPEMUL:	=	1<<(-(Primitive.TYPESHIFT-23))
Primitive.SPRITETYPE:	=	%0000000000000000
Primitive.LINETYPE:	=	%0000010000000000
; Other types are polygons, %10 :== triangle, %11 :== quadrangle, etc.

; TableLookup mask
Primitive.TEXTUREMASK:	=	%0000001111111111

;======== MeshElement

MeshElement.BASE:	=	0				; startaddress of vertex table
MeshElement.REF:	=	1				; address of element
MeshElement.Z:		=	2				; Z coordinate of element
MeshElement.SIZE:	=	3

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
Matrix.TX:		=	9
Matrix.TY:		=	10
Matrix.TZ:		=	11
Matrix.SIZE:		=	12

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
	jmp	<START

	ORG	P:$0040

;======== TransformObject

; Now transform this puppy. Nasty thing is we only have a 256 word inverse
; table. With some algebra tricks we can use full range division, using
; little extra cycles. Better than some 32 cycles normally required for rep
; and 15 div combination.
; INPUT:
; x:(r0)=src vertices, x:(r1)=center coords, y:(r2)=invtable,
; y:(r3)=invtable (+offset), y:(r4)=matrix, y:(r5)=dst vertices
; y:(r6)=translation vector
; n4= matrix jumpback, n6= translation jumpback
; a=TZ, b=#vertices, x0=1st vertex.Y, y0=Matrix.ZX
Vertex.transInt:
	do	b,_vertexloop

; 32.000.0000 / 58 cycles > 550.000 rotate-perspectivations / sec.
; calc z
	mac	x0,y0,a		x:(r0)+,x1	y:(r4)+,y0
	mac	x1,y0,a		x:(r0)-,x1	y:(r4)+n4,y0
	macr	x1,y0,a		x:<Viewport.Focal,x1		; a := Z, x1 := focal length

; Calc 1/Z and prepare for the x coordinate.
	add	x1,a				a,y:(r5)-	; Z := Z + focal, Store Z.
	move			a,x1		y:(r3),y1	; x1 := Z, y1 := 1/128
	mpyr	x1,y1,a				y:(r6)+,b	; a := Z div 128, b := TX
	move			a,n2				; n2 := Z div 128
	move					y:(r4)+,y0
	mac	x0,y0,b				y:(r2+n2),y1	; y1 := 1 div (Z div 128)
	mpyr	y1,x1,a		x:(r0)+,x1	y:(r4)+,y0	; a := Z div (Z div 128)
	mac	x1,y0,b		a,n2				; n2 := Z div (Z div 128)
	move			x:(r0)-,x1	y:(r4)+,y0
	macr	x1,y0,b				y:(r2+n2),x1	; x1 := 1 div (Z div (Z div 128))
	mpyr	y1,x1,a		n3,x1				; a := (1 div (Z div 128))(1 div (Z div (Z div 128))) ~= 1 / Z, x1 := 128
	move			a,y1				; 
	mpy	x1,y1,a		x:(r1)+,b	b,y1		; a := (1/Z)<<8, b := XCenter, y1 := X

; calc x
	move					y:(r4)+,y0
	move			a0,x1				; x1 := 1/Z
	macr	y1,x1,b		x:<Viewport.Aspect,y1		; X' = b := XCenter + X * 1/Z, x1 := aspect ratio
	move					y:(r6)+,a	; a := TY

; calc y
	mac	x0,y0,a		x:(r0)+,x0	y:(r4)+,y0
	mac	x0,y0,a		x:(r0)+,x0	y:(r4)+,y0
	macr	x0,y0,a				b,y:(r5)-	; b := YCenter, store X'.
	move			a,x0				; x0 := Y

	mpy	x0,y1,a		x:(r1)-,b			; a = Ys := Y*aspect
	move					a,y1		; y1 := Ys
	mac	y1,x1,b				y:(r6)+n6,a	; Y' = b := YCenter + Y * 1/Z, a := TZ
	macr	y1,x1,b				y:(r4)+,y0
	move			x:(r0)+,x0	b,y:(r5)+n5	; Store Y'.
_vertexloop:
	rts

; INPUT:
; x:r0: stored parameter (object handle)
TransformObject.transformStored:
	move			x:(r0)+,n0

; INPUT:
; n0: objecthandle
TransformObject.transform:
	jsr	<BoundingBox.calcRectangle
	tst	a
	jeq	<_end

; n0: objecthandle
	jsr	<Object.get
; x:r0: object (untransformed)

; Increase baseHandle.
	move			x:>PrimitiveMesh.baseHandle,a
	move			#>1,x0
	add	x0,a		x:>PrimitiveMesh.nextVertex,r5
	move			a,x:>PrimitiveMesh.baseHandle

	move			x:(r0)+,b			; a= #vertices+#normals
	move			x:(r0)+,x0			; x0= #normals
	sub	x0,b		x0,n0				; b= #vertices, n0= #normals

	jsr	<Vertex.transform
; n0 = normalcount
; r4 = matrix
; r5 = dest. normals

	move			n0,a
	tst	a
	jeq	<_end_normals

; 32.000.0000 / 24 cycles = 1.333.333 normalrotations / sec.
	do	n0,_normalloop
	mpy	x0,y0,a		x:(r0)+,x1	y:(r4)+,y0	; x * MZX +
	mac	x1,y0,a		x:(r0)-,x1	y:(r4)+n4,y0	; y * MZY +
	mac	x1,y0,a				y:(r4)+,y0	; z * MZZ
	move					a,y:(r5)-	; Store Z.
	mpy	x0,y0,a		x:(r0)+,x1	y:(r4)+,y0	; x * MXX +
	mac	x1,y0,a		x:(r0)-,x1	y:(r4)+,y0	; y * MXY +
	mac	x1,y0,a				y:(r4)+,y0	; z * MXZ
	move					a,y:(r5)-	; Store X.
	mpy	x0,y0,a		x:(r0)+,x1	y:(r4)+,y0	; x * MYX +
	mac	x1,y0,a		x:(r0)+,x1	y:(r4)+,y0	; y * MYY +
	mac	x1,y0,a		x:(r0)+,x0	y:(r4)+,y0	; z * MYZ
	move					a,y:(r5)+n5	; Store Y.
_normalloop:
_end_normals:
	move			(r0)-
	move			(r5)-
	move			(r5)-

; Kick primitives onto mesh right here...
	move			x:>PrimitiveMesh.nextVertex,r6
	move			r5,x:>PrimitiveMesh.nextVertex	; Store address for next transformed vertices.
	move			#>PrimitiveMesh.primitiveTable,r2
	move			x:(r0)+,a			; a= number of 2d vertices
	asl	a		r0,y:(r6)			; Store address of 2d vertices.
	move			a,n0
	move			x:(r2)+,a			; a= primitivecounter
	move			a,r3
	asl	a		a,x0
	add	x0,a		r6,r5				; r5= address of transformed vertices
	move			a,n2				; n2= offset to next primitive in mesh
	move			(r0)+n0				; r0= primitivetable
	move			(r2)+n2				; r2= address of next primitive in mesh

	move			#>PrimitiveMesh.baseTable,r1
	move			x:>PrimitiveMesh.baseHandle,n1
	move			#<2,n2
	move			r5,x:(r1+n1)			; Store address of vertexbase in table.

	do	x:(r0)+,_calc_z_loop
	IFNE	1
	move			r5,x:(r2)+			; Store pointer to vertices-base.
	clr	a		r0,x:(r2)+			; Store object primitive address in the mesh.
	ELSE
; TODO: possibly introduce the efficient prim-table handling here.
	move			x:>PrimitiveMesh.baseHandle,x0
	move			#>$008000,x1
	mpy	x0,x1,b		r0,a
	move			b1,x0
	or	x0,a
	clr	a		a,x:(r2)+			; Store vertexbasehandle|primitive address
	ENDC
	move			x:(r0)+,a1			; a1= primitivetype
	move			a1,n3				; n3= primitivetype
	move			#>Primitive.TYPEMASK,x0
	and	x0,a		#>Primitive.LINETYPE,x0
	move			a1,n1
	move			r0,y:<PrimitiveMesh.primitive
	tst	a		x:(r0)+,y0			; y0= index of 1st vertex
	jne	<_not_sprite
	move			#>Vertex.SIZE,x0		; / Get offset to sprite vertex.
	mpy	x0,y0,a		(r5)+				; |
	asr	a		(r5)+				; |
	move			a0,n5				; \
	move			(r5)+
	move					y:(r5+n5),x0	; x0= z
	move			(r5)-
	tfr	x0,b		(r5)-				; b= z
	tst	b		#<1,n0
	jle	<_dont_store
	jmp	<_store_primitive
_not_sprite:
	cmp	x0,a		#>Vertex.SIZE,x0		; Get offset to line vertex.
	jne	<_not_line
	mpy	x0,y0,a		#<3,n5
	asr	a
	move			(r5)+n5
	move			a0,n5
	move			x:(r0)+,a
	asl	a		a,y0
	add	y0,a				y:(r5+n5),b
	move			a1,n5
	move			#<2,n0
	tfr	b,a				y:(r5+n5),x0
	or	x0,a		(r5)-				; v1 or v2 behind cam -> out
	move			(r5)-
	jmi	<_dont_store
	add	x0,b
	asr	b						; b=(v1.z+v2.z)/2
	move			b,x0
	jmp	<_store_primitive
_not_line:
_polygon:
	;move			#>Vertex.SIZE,x0		; / Get offset to p0 vertex.
	mpy	x0,y0,a		(r5)+				; |
	asr	a		x:(r0)+,y0			; |
	move			a0,n5				; \
	mpy	x0,y0,a
	lua	(r5)+n5,r1

	asr	a		x:(r0)+,y0			; 
	move			a0,n5				; 
	mpy	x0,y0,b				y:(r1)+,a	; a := p0.y
	lua	(r5)+n5,r6

	nop
	asr	b				y:(r6)+,x0	; x0= p1.y
	move			b0,n5				; 
	sub	x0,a				y:(r6)+,y1	; a= p0.y - p1.y, y1= p1.x
	move					y:(r6),b	; x1= p1.z
	lua	(r5)+n5,r6

	tst	b		b,x:<Polygon.z
	jle	<_dont_store

	move			a,x1		y:(r6)+,b	; b= p2.y, x1= p0.y - p1.y
	sub	x0,b				y:(r1)+,a	; a= p0.x
	sub	y1,a		b,y0				; y0= p2.y - p1.y
	move					y:(r6)+,b	; b= p2.x
	sub	y1,b		a,y1				; y1= p0.x - p1.x

	mpy	+y0,y1,a	b,x0		y:(r1),b	; a= (p0.x - p1.x)(p2.y - p1.y), x0= p2.x - p1.x, b= p0.z

	tst	b		x:<Polygon.z,y1
	jle	<_dont_store
	add	y1,b		n1,y0

; Okay fine.. now we need to test the other points for negative Z as well!
	move			#1<<(-(Primitive.TYPESHIFT-23)),y1
	mpy	y0,y1,b		b,x:<Polygon.z
	move			b,r1				; r1= points-1
	move			b,x:<Polygon.points
	move			(r1)-
	move			(r1)-				; r1= points-(1+2)
	move					y:(r6),b	; b=p2.z
_addloop:
	tst	b		x:<Polygon.z,y1
	jle	<_dont_store
	add	y1,b						; Add z to z total.
	move			b,x:<Polygon.z
	move			r1,b
	tst	b		x:(r0)+,b			; b= index
	jeq	<_all_done
	asl	b		b,y0
	add	y0,b		r5,y0				; b=index*3=offset
	add	y0,b		#<Vertex.Z,n6			; b=offset to next vertex
	move			b1,r6				; r6= vertex
	move			(r1)-				; Decrease loopcounter.
	move					y:(r6+n6),b	; b= Vertex.Z
	jmp	<_addloop
_all_done:

; Calculate z average and normal-direction.
	move			x:<Polygon.points,r1
	move			#>InverseTable,r4
	move			(r1)+
	move			r1,n4
	move			x:<Polygon.z,y0
	move					y:(r4+n4),y1
	mpyr	y0,y1,b						; b= ztotal/pointnum
	mac	-x0,x1,a	b,x0				; -(p0.y - p1.y)*(p2.x - p1.x)
_jmp_instr:
	jge	<_store_primitive
_dont_store:
	move			(r2)-n2				; Culled primitive, don't store base

; Increase sourceaddress to next primitive...
_end_calc_z_loop:
	clr	a		(r5)-
; Calculate tailsize of vertex-reference.
	move			n3,a1				; a= primitivetype
	move			#>1,b
	move			#>Primitive.SHADEMASK,x0
	and	x0,a		b,x1
	jeq	<_got_size
	add	x1,b		#>Polygon.ALPHATEXTURED,x0
	cmp	x0,a
	jlt	<_got_size
	add	x1,b
_got_size:
	move					y:<PrimitiveMesh.primitive,r0
	move			n1,x0
	tfr	x1,a		#1<<(-(Primitive.TYPESHIFT-23)),y0
	mac	x0,y0,a		b,n0				; a= (points-1+1)*tailsize
; Now add the tailsizes to get address of next primitive.
	rep	a
	move			(r0)+n0
_calc_z_loop:

; Store primitivecounter.
	move			r3,x:PrimitiveMesh.primitiveTable
_end:	rts

_store_primitive:
	move			x0,x:(r2)+			; Store Z.
	move			(r3)+				; Increase primitivecounter.
	jmp	<_end_calc_z_loop

;======== Polygon

EDGE_ROUNDING:	=	1					; 0: compatible with 68K, 1: more accurate

; Definetely the fastest scan converter around.
; USES:
; x:Polygon.vsize: 1=flat shade, 2=gouraud, 3=tmap, 4=gourtmap, 5=envtmap/bump
; INPUT:
; x:(r6): polygon table
Polygon.drawEdges:
	move			x:<Polygon.vsize,n6
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

; r5= pt1, r6= next pt
	do	x:<Polygon.points,_do_line
	move			x:(r5)+,a			; a=current point's y
	move			r6,r4
	move			x:(r6)+,b			; b=next point's y
	sub	a,b		x:<Polygon.top,y1
	jlt	<_do_left_side
	jeq	<_end_line
	move			b,n3
	move			r0,b0
	jmp	<_end_swap
_do_left_side:
; Calculate start y offset.
; Swap left and right edges.
	add	b,a		r5,x0
	neg	b		r6,r5
	move			b,n3
	move			x0,r6
	move			r1,b0
_end_swap:
	sub	y1,a		n6,x0 				; a=startoffset
	move			a,y1
	mpy	x0,y1,a				y:(r3+n3),y1	; a0=startoffset*vsize*2, y1=1/dy
	asr	a		n6,n2				; a0=startoffset*vsize 
	add	a,b		r0,y0
	move			b0,r0
	IFNE	EDGE_ROUNDING
	move			#<$80,x1
	ELSE
	move			#<0,x1
	ENDC

; Speedy.. but could be better when doing u and v in one go.
	do	n6,_coord_loop
	move			x:(r6)+,x0			; x0= right x
	mpy	+x0,y1,b	x:(r5)+,x0			; b= rx/dy, x0= left x
	tfr	x0,a		r0,r2				; a= left x, r2=edge
	mac	-x0,y1,b	x1,a0 				; b= dx/dy, a0=x.frac (for rounding)

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

	rts

; INPUT:
; r0=l edge, r1=r edge, n6=#scanlines
Polygon.paintFlat
	do	n6,_yloop
	send	y:(r0)+						; Send left x.
	send	y:(r1)+						; Send right x.
_yloop:	rts

; INPUT:
; r0=l edge, r1=r edge, r2=inv tbl, n6=#scanlines
Polygon.paintGouraudShaded:
	do	n6,_yloop
	move					y:(r0)+,x0	; x0= left x
	send	x0						; Send left x.
	move					y:(r1)+,a	; a= right x
	sub	x0,a				y:(r0)+,x0	; a= dx , x0= left u
	move			a1,n2				; n2= dx
	send	a1						; Send width.
	move					y:(r1)+,a	; a= right u
	sub	x0,a				y:(r2+n2),x1	; a=du= right u - left u, x1= divisor
	send	x0						; Send left u.
	move			a,y1				; y1= du
	mpy	x1,y1,a						; a1=u_step= du / divisor
	send	a1						; Send u_step.
_yloop:	rts

; INPUT:
; y0=texturenum, r3=HTX, r4=textureaddy
; r0=l edge, r1=r edge, r2=inv tbl, n6=#scanlines
Polygon.paintTextured:
	clr	a		#>64*64/2,y1
	move			r4,a0
	mac	y0,y1,a
	move			a0,r4

; hline loop
	do	n6,_yloop

	move					y:(r0)+,x0	; x0=lx
	move					y:(r1)+,a	; a=rx
	send	x0						; Send lx.
	sub	x0,a				y:(r0)+,x0	; x0=u_start
	move					y:(r0)+,y0	; y0=v_start
	move			a1,n2				; n2=width
	send	a1						; Send width.
	move					y:(r1)+,a	; a=u_end
	move					y:(r1)+,b	; b=v_end
	jle	<_skip_line

	IFNE	WRAPCRAP
	sub	x0,a				y:(r2+n2),x1	; du=u_end-u_start, x1=divisor
	sub	y0,b		a1,y1				; dv=v_end-v_start, y1=du
	mpy	x1,y1,a		b1,y1				; a=u_step=du/divisor, y1=dv
	mpy	x1,y1,b		a,n5	 			; b=v_step=dv/divisor, n5=u_step
	move					y:<v_scale,y1	; y1=scalar (int:frac->texturesize)
	mpy	y1,y0,a		b,x1				; a=v (12b), x1=v_step
	mpy	y1,x1,b		x0,r5				; b=v_step (12b), r5=u
	move			b1,x1
	tfr	a,b		#<0,x0	;b0,x0			; b=v (12b), x=v_step (12b)
	move			x:<u_scale,y0			; y0=scalar (int:frac -> int)
	move			#<0,b0
	ELSE
	sub	x0,a				y:(r2+n2),x1	; du=u_end-u_start, x1=divisor
	sub	y0,b		a1,y1				; dv=v_end-v_start, y1=du
	mpy	x1,y1,a		b1,y1				; a=u_step=du/divisor, y1=dv
	mpy	x1,y1,b		a1,x:<u0_step 			; b=v_step=dv/divisor, Store u_step.
	tfr	x0,a				b1,y:<u0_step 	; a1=u, Store v_step.
	move			y0,a0				; a0=v
; a1=u, a0=v, x1=u_step, x0=v_step
	move			x:<texturesize,y0
	move			a1,y1
	ENDC

; 5 calculation instructions = 5*2 = 10 cycles
; 1 host send >= 8 or 10 cycles
; total >= 18 or 20 cycles per pixel
	do	n2,_send_pixel
	IFNE	WRAPCRAP
	tfr	b,a				y:<texturemask,y1	; a=V[n] (12.24), y1=$FC0
	and	y1,a		r5,y1				; a=wrapped(int(V[n])), y1=U[n] (6:10)
	mac	y1,y0,a		(r5)+n5				; a=%VVVVVVUUUUUU[n], r1=u[n+1] (6:10)
	add	x,b		a1,n4				; b=V[n+1], n4=%VVVVVVUUUUUU[n] (=offset)
	ELSE
	mpyr	y1,y0,b		l:<texturemask,x		; b=offset=u*texturesize, x1=width, x0=mask
	and	x0,b		a0,y1				; kill frag_u, y1=v
	mac	y1,x1,b		l:<u0_step,x			; offset:=offset+v, x1=u_step, x0=v_step
	add	x,a		b1,n4				; u:=u+u_step, v:=v+v_step
	move			a1,y1				; y1=u
	ENDC
	jclr	#1,x:<<HSR,*					; Wait until host is ready.
_pixelinstruction:
	nop							; Send word.
_send_pixel:

_skip_line:
	nop
_yloop:	rts

; Alpha texturing requires interleaved textures in dsp ram.
; The pixels are aligned like so: iixxxx, aaxxxx, where 'a' denotes alpha
; and 'i' the index in a 256 color palette. the x denotes a highcolor word.
; Yes, that means alpha textures occupy the same space as normal textures!
; INPUT:
; y0=texturenum, r3=HTX, r4=colortexture, 5r=alphatexture
; r0=l edge, r1=r edge, r2=inv tbl, n6=#scanlines
Polygon.paintV4:
	move			#<4,n0				; #coordinates in edge-entry
	move			#<4,n1				; #coordinates in edge-entry

; hline loop
	do	n6,_scan_send_sides

	move					y:(r0)+,x0	; x0=lx
	send	x0						; Send left x.
	move					y:(r1)+,a	; a=rx
	sub	x0,a		#<u0,r6				; r6= start of uv-storage
	send	a1						; Send width.
	tst	a		a1,n2				; test for 0-width, n2 := width
	jgt	<_go_on

	move			(r0)+n0
	move			(r1)+n1
	jmp	<_skip_line

_go_on:	do	#2,_init_uv_loop
	move					y:(r0)+,x0	; x0= u_start
	move					y:(r1)+,a	; a= u_end
	move					y:(r0)+,y0	; y0= v_start
	move					y:(r1)+,b	; b= v_end
	sub	x0,a				y:(r2+n2),x1	; du= u_end - u_start, x1= divisor
	sub	y0,b		x0,x:(r6)	a,y1		; dv= v_end - v_start, store u_start, y1= du
	mpy	x1,y1,a		b,x0		y0,y:(r6)+	; u_step= du / divisor, x0= dv, store v_start
	mpy	x1,x0,b		a,x:(r6)			; v_step= dv / divisor, x1= u_step, store u_step
	move					b,y:(r6)+	; Store v_step.
_init_uv_loop:

	move			l:<u0,a
	move			l:<u0_step,x
	move			#>64*64,y0
	move					y:<Polygon.v4RoutineAddress,r6
	move			a,x0
	move			a,y1
	jsr	(r6)

_skip_line:
	nop
_scan_send_sides:
	rts

_send_alpha_hline:
; 16 instructions.. 32 cycles. Crappy, but better than a CPU implementation.
	do	n2,_send_alphapixel
	mpyr	y1,y0,b		l:<texturemask,x		; offset := u0 * v_width
; x1: 128, x0: -128
	and	x0,b				y:<v0,x0	; kill frag_u0
	mac	x0,x1,b		l:<u0_step,x			; offset := offset + v0
; x1: u0_step, x0: v0_step
	add	x,a		b1,n4
	move			l:<u1,b				; u0 := u0 + u0_step, v0 := v0 + v0_step
	move			a,l:<u0				; Store u0, v0.
	move			b,x0		y:(r4+n4),y1	; x0 := u1_step, y1 := color
	mpyr	x0,y0,a		l:<texturemask,x		; offset := u1 * v_width
; x1: 128, x0: -128
	and	x0,a		b0,x0				; kill frag_u1
	mac	x0,x1,a		l:<u1_step,x			; offset := offset + v1
; x1: u1_step, x0: v1_step
	add	x,b		a1,n5
	move			l:<colorshift,x			; Get shift value x1, mask in x0
	mpyr	x1,y1,b		b,l:<u1				; u1 := u1 + u1_step, v1 := v1 + v1_step, a1 := u0, a0 := v0
	and	x0,b		x:<alphashift,x1		; Mask off alpha bits, store u1, v1.
	move					y:(r5+n5),y1	; Shift color to b1's mid byte, y1 := alpha
	mac	x1,y1,b		l:<u0,a				; Shift alpha to b1's lsb, x0 := u0
	jclr	#1,x:<<HSR,*					; Wait until host is ready.
	move			b,x:(r3)	a,y1		; Send pixel.
_send_alphapixel:
	rts

_send_bump_hline:
; 14 instructions.. 28 cycles. Crappy, but better than a CPU implementation.
	do	n2,_send_bumppixel
	mpyr	x0,y0,b		l:<texturemask,x		; offset := u0 * v_width
; x1: 128, x0: -128
	and	x0,b				y:<v0,x0	; kill frag_u0
	mac	x0,x1,b		l:<u0_step,x			; offset := offset + v0
; x1: u0_step, x0: v0_step
	move			b1,n4
	move			l:<u1,b				; u0 := u0 + u0_step, v0 := v0 + v0_step
	add	x,a		b,x0		y:(r4+n4),y1	; x0 := u1_step
	move			a,l:<u0				; Store u0, v0.
	mpyr	x0,y0,a		l:<texturemask,x		; offset := u1 * v_width
; x1: 128, x0: -128
	and	x0,a		b0,x0				; kill frag_u1
	mac	x0,x1,a		l:<u1_step,x			; offset := offset + v1
; x1: u1_step, x0: v1_step
	add	x,b		x:<u0,x0			; u1 := u1 + u1_step, v1 := v1 + v1_step, x0 := u0
	add	y1,a		b,l:<u1				; Add bump-offset to offset, store u1, v1.
	move			a1,n5
	move			l:<u0,a
	send	y:(r5+n5)					; Send pixel to host.
_send_bumppixel:
	rts


;======== Code that only uses X memory, fits in Y memory nicely


;======== PrimitiveMesh

; Combsort implementation. In place sorting, not the fastest available
; algorithm... With little RAM there is no choice I'm afraid.
PrimitiveMesh.sort:
	move			#>PrimitiveMesh.primitiveTable,r0
	move			#<MeshElement.SIZE,n3
	move			x:(r0)+,a
	tst	a		a,b
	jeq	<_end
	lsr	b		a,y0				; Resize gap.
	jmp	<_end_calculate_gap
	
_loop:	move			#>2,x0
	cmp	x0,b
	jgt	<_calculate_gap
	tfr	x0,b
_calculate_gap:
	move			#>0.769230769,x0
	move			b,x1
	mpy	x0,x1,b
_end_calculate_gap:
	tfr	y0,a		b,x1
	sub	x1,a		n3,x0
	mpy	x0,x1,a		a,n6
	asr	a		#<0,r4				; swapcount := 0
	move			a0,n0
	move			#<MeshElement.SIZE,n2
	move			#<MeshElement.SIZE,n1
	move			r0,r2
	lua	(r0)+n0,r1

	do	n6,_element_loop
	move			(r2)+n2
	move			(r1)+n1
	move			x:-(r2),a
	move			x:-(r1),x0
	cmp	x0,a		(r2)+
	move			(r1)+
	jge	<_no_swap
	IFNE	1
	move			a,x:-(r1)
	move			x0,x:-(r2)
	move			x:-(r2),x0
	move			x:-(r1),x1
	move			x0,x:(r1)
	move			x1,x:(r2)
	move			x:-(r2),x0
	move			x:-(r1),x1
	move			x0,x:(r1)+n1
	move			x1,x:(r2)+n2
	ELSE
; TODO: When all routines are adapted for small elements, activate this!
	move			a,x:-(r1)
	move			x0,x:-(r2)
	move			x:-(r2),x0
	move			x:-(r1),x1
	move			x0,x:(r1)+n1
	move			x1,x:(r2)+n2
	ENDC
	move			(r4)+
_no_swap:
	nop
_element_loop:

	move			r4,a
	tst	a		#>2,x0
	jne	<_loop
	cmp	x0,b
	jge	<_loop

_end:	rts

;======== non time-crucial stuff, all in external P-RAM ========

START:	jsr	<InitPipeline

Dispatcher.dispatch:
; Receive command... This is parallel mode. I.e. fetch, store a number of
; commands. After this host-synchronized period, it starts running through
; all commands in parallel.
_store:	move			#>Dispatcher.commandTable,x0
	move			x0,x:>Dispatcher.commandTablePosition

_storebigloop:
	move			#>Dispatcher.commandSizeTable,r0
	move			x:>Dispatcher.commandTablePosition,r1
	move			#>RPC_PAINT_PRIMITIVES,x0

; First store all received commands including arguments.
_storeloop:
	get	n0
	move			n0,a
	cmp	x0,a		x:(r0+n0),b
	jeq	<_end_store
	tst	b		a,x:(r1)+
	jeq	<_storeloop
	jmi	<_execute_direct

; This is for asynchronous commands. They are stored and executed later on
; in parallel.
	do	b,_store_word_loop
	get	x:(r1)+
_store_word_loop:
	jmp	<_storeloop

; Some commands have to be completed synchronously! i.e. texture/object-
; storage!!!!
_execute_direct:
	move			#>Dispatcher.rpcTable,r2
	move			n0,n2
	move			(r1)-				; Correct last store (not needed!).
	move			x:(r2+n2),r2
	move			r1,x:>Dispatcher.commandTablePosition
	jsr	(r2)
	jmp	<_storebigloop

_end_store:
	move			a,x:(r1)+
	move			#>Dispatcher.commandTable,x0
	move			x0,x:>Dispatcher.commandTablePosition

; Then execute all commands.
_execute_loop
	move			x:>Dispatcher.commandTablePosition,r0
	move			#>Dispatcher.commandSizeTable,r1
	move			x:(r0)+,a
	move			#>RPC_PAINT_PRIMITIVES,x0
; Check for a paint command..
	cmp	x0,a		a,n1
	jeq	<_complete
	move			x:(r1+n1),n0			; Fetch command size.
	move			#>Dispatcher.storedRpcTable,r1
	lua	(r0)+n0,r2					; Jump to next command.
	move			x:(r1+n1),r1
; Store next command position and execute current.
	move			r2,x:>Dispatcher.commandTablePosition
	jsr	(r1)
	jmp	<_execute_loop

_complete:
	jsr	<PrimitiveMesh.paint
	jmp	<_store	

Dispatcher.doNothing:
	rts

; Receives rotation cos/sin values from CPU.
; INPUT:
; r0: X-sine
; r1: X-cosine
; r2: Y-sine
; r3: Y-cosine
; r4: Z-sine
; r5: Z-cosine
ReceiveRotation:
	get	x:(r0)
	get	x:(r1)
	get	x:(r2)
	get	x:(r3)
	get	y:(r4)
	get	y:(r5)
	rts

;======== Vertex

; INPUT:
; x:(r0): vertices
; y:(r5): transformed vertices (dest.)
; b: vertexcount (excluding normals!)
Vertex.transform:
	move			#<Viewport.XCenter,r1

; Get current matrix.
	move			x:<Matrix.stackTop,a
	move			#>1,x1
	sub	x1,a		#>Matrix.SIZE,x0
	move			a,x1
	mpy	x0,x1,a		#<Matrix.stack,r4
	asr	a		(r5)+				; Adjust for fractional madness, skip 2d vertex pointer.
	move			a0,n4
	move			#<Vertex.SIZE+2,n5
	move			(r4)+n4				; r4 := matrix
	move			#<Matrix.TZ,n4
	move			(r5)+
	lua	(r4)+n4,r6					; r6 := matrix.TZ

	move			#<Matrix.ZX,n4
	move			(r5)+
	move			(r4)+n4				; r4 := matrix.ZX
	move			#>-8,n4				; n4 := jumpbackvalue for matrix
	move			#>-2,n6				; n6 := jumpbackvalue for translation
	move			#>InverseTable,r3		; r3 := start of 1/Z table
	move			#<128,n3
	move			r3,r2				; r2 := start of 1/Z table
	move			(r3)+n3
	move					y:(r6)+n6,a	; a := TZ
	move			x:(r0)+,x0	y:(r4)+,y0
	move			#<127,n3
	jmp	<Vertex.transInt


;======== Polygon

; Reads polygon data from memory and decodes it's dimension, it's number of
; vertices and it's shading type.
; INPUT:
; y:(r1): 2d-vertices pointer, vertices
; x:(r2): primitive
Polygon.decode:
	clr	a		#<Polygon.polygonTable,r4
	clr	b		x:(r2),a1
	move			#>Primitive.TEXTUREMASK,x0

; Get texturenumber.
	and	x0,a		a1,b1
	move			a,x:<Polygon.textureNumber

; Get number of points in polygon.
	clr	a		#>Primitive.TYPEMASK,x0
	and	x0,b		#>Primitive.TYPEMUL,x1
	move			x:(r2)+,a1
	move			b,y0
	move			#>1,b
	mac	y0,x1,b		(r1)+
	move			b,x:<Polygon.points

; Get shadetype.
	move			#>Primitive.SHADEMASK,x0
	and	x0,a		#>Primitive.SHADEMUL,x1
	move			a,x0
	mpy	x0,x1,a		#>Polygon.shadeJumpTable,r6
	move			a,n6

; Fill the polygon table...
; y:(r1): vertices
; x:(r2): 1st index in primitive
; y:(r4): polygon table
	nop
	move			p:(r6+n6),r6
	nop
	jmp	(r6)

Polygon.shadeJumpTable:
	DC	Polygon.decodeFlatshaded
	DC	Polygon.decodeGouraudshaded
	DC	Polygon.decodePhongshaded
	DC	Polygon.decodeTextured
	DC	Polygon.decodeEnvmapped
	DC	Polygon.decodeAlphatextured
	DC	Polygon.decodeBumpmapped

; INPUT:
; x:(r4): end of polygon data
Polygon.copyLast:
; Copy the first point (wrap-crap).
	move			#<Polygon.polygonTable,r3
	nop
	move			x:(r3)+,x0
	move			x0,x:(r4)+
	do	x:<Polygon.vsize,_loop
	move			x:(r3)+,x0
	move			x0,x:(r4)+
_loop:
	rts

;-------- Polygon decoders

Polygon.decodeFlatshaded:
	clr	a		#>2-1,x0
	move			x0,x:<Polygon.vsize
	move			a,x:<Polygon.shadeType
	do	x:<Polygon.points,_loop
	move			x:(r2)+,a			; Get index of Vertex.
	asl	a		a,x0
	add	x0,a
	move			a,n1
	nop
	lua	(r1)+n1,r3
; Write points to the polygontable.
	do	#2,_coordloop
	move					y:(r3)+,x0
	move			x0,x:(r4)+
_coordloop:
	nop
_loop:
	jmp	<Polygon.copyLast

Polygon.decodeGouraudshaded:
	move			#>3-1,x0
	move			x0,x:<Polygon.vsize
	move			#>RPC_GOURAUDSHADED,x0
	move			x0,x:<Polygon.shadeType
	move			x:<Polygon.points,n2
	move			#>$8000,y0
	do	x:<Polygon.points,_loop
	move			x:(r2)+n2,a			; Get index of Vertex.
	asl	a		a,x0
	add	x0,a		x:(r2)-n2,x1			; Fetch gouraud value.
	mpy	x1,y0,a		a,n1				; Scale gouraud value.
	move			(r2)+				; Proceed to next index.
	lua	(r1)+n1,r3
; Write points to the polygontable.
	do	#2,_coordloop
	move					y:(r3)+,x0
	move			x0,x:(r4)+
_coordloop:
	move			a0,x:(r4)+			; Write gouraud value.
_loop:
	jmp	<Polygon.copyLast

Polygon.decodePhongshaded:
	move			#>3-1,x0
	move			x0,x:<Polygon.vsize
	move			#>RPC_GOURAUDSHADED,x0
	move			x0,x:<Polygon.shadeType
	move			x:<Polygon.points,n2
	move			#>127,x1
	move			#>$3FFF,y0
	do	x:<Polygon.points,_loop
	move			x:(r2)+n2,a			; a= vertex index.
	asl	a		a,x0
	add	x0,a		x:(r2)-n2,b			; b= gouraud index.
	move			a,n1
	asl	b		b,x0
	lua	(r1)+n1,r3					; r3= vertex
	add	x0,b		#<Vertex.Z,n5			; n5= offset to Z coordinate in normal
	move			b,n1
	move			(r2)+				; Proceed to next point.
	lua	(r1)+n1,r5					; r5= normal
; Write points to the polygontable.
	do	#2,_coordloop
	move					y:(r3)+,x0
	move			x0,x:(r4)+
_coordloop:
	move					y:(r5+n5),a	; Fetch gouraud value.
	add	x1,a
	move			a,x0
	mpy	x0,y0,a
	move			a0,x:(r4)+			; Write gouraud value.
_loop:
	jmp	<Polygon.copyLast

Polygon.decodeTextured:
	move					y:-(r1),r5	; r5= 2d vertices base.
	move			#>4-1,x0
	move			x0,x:<Polygon.vsize
	move			#>RPC_TEXTUREMAPPED,x0
	move			x0,x:<Polygon.shadeType
	move			x:<Polygon.points,n2
	move			(r1)+
	move			#>1<<7,x1		; 1<<14
	do	x:<Polygon.points,_loop
	move			x:(r2)+n2,a			; Get index of Vertex.
	asl	a		a,x0
	add	x0,a		x:(r2)-n2,b			; Fetch 2d Vertex index.
	asl	b		a,n1
	move			b,n5
	lua	(r1)+n1,r3					; r3 := Vertex
	move			(r2)+				; Proceed to next point.
	lua	(r5)+n5,r6					; r6 := 2d Vertex
; Write points to the polygontable.
	do	#2,_coordloop
	move					y:(r3)+,x0
	move			x0,x:(r4)+
_coordloop:
	move			x:(r6)+,x0			; Fetch u.
	mpy	x1,x0,a		x:(r6),x0			; Fetch v.
	mpy	x1,x0,a		a0,x:(r4)+			; Write u.
	move			a0,x:(r4)+			; Write v.
_loop:
	jmp	<Polygon.copyLast

Polygon.decodeEnvmapped:
	move			#<4-1,a1
	move			a1,x:<Polygon.vsize
	move			#<RPC_TEXTUREMAPPED,a1
	move			a1,x:<Polygon.shadeType
	move			x:<Polygon.points,n2
	IFNE	WRAPCRAP
	move			#>1<<7,x1
	move			#>$008000,y1
	ELSE
	move			#>1<<14,x1
	move			#>$400000,y1
	ENDC
	do	x:<Polygon.points,_loop
	move			x:(r2)+n2,a			; Get index of Vertex.
	asl	a		a,x0
	add	x0,a		x:(r2)-n2,b			; Fetch normal index.
	asl	b		b,x0
	add	x0,b		a,n1
	move			(r2)+				; Proceed to next point.
	lua	(r1)+n1,r3					; r3 := Vertex
	move			b,n1
; Write points to the polygontable.
	move					y:(r3)+,x0
	move			x0,x:(r4)+	y:(r3),y0
	lua	(r1)+n1,r3					; r3 := Normal
	clr	a		y0,x:(r4)+
	clr	b		y1,a0
	move			y1,b0
	move					y:(r3)+,x0	; Fetch Normal.X (=u).
	mac	x0,x1,a				y:(r3),y0	; Fetch Normal.Y (=v).
	mac	y0,x1,b		a0,x:(r4)+			; Write u.
	move			b0,x:(r4)+			; Write v.
_loop:	jmp	<Polygon.copyLast

Polygon.decodeAlphatextured:
	move			#>RPC_ALPHATEXTURED,x0
	move			x0,x:<Polygon.shadeType
	jsr	<Polygon.setV4AlphaMode
	jmp	<Polygon.decodeV4

Polygon.decodeBumpmapped:
	move			#>RPC_BUMPMAPPED,x0
	move			x0,x:<Polygon.shadeType
	jsr	<Polygon.setV4BumpMode

Polygon.decodeV4:
	move			#<6-1,n2
	move					y:-(r1),r5	; r5 := 2d vertices base.
	move			n2,x:<Polygon.vsize
	move			x:<Polygon.points,n2
	move			(r1)+
	lua	(r2)+n2,r0
	move			#>1<<14,x1
	move			#>$400000,y1
	do	n2,_loop
	move			x:(r2)+,a			; Get index of Vertex.
	asl	a		a,x0
	add	x0,a		x:(r0)+,b			; Fetch 2d vertex index.
	asl	b		a,n1
	move			x:(r0)+,a			; Fetch normal index.
	lua	(r1)+n1,r3					; r3 := Vertex
	asl	a		a,x0
	add	x0,a		b,n5
	move			a,n1
	lua	(r5)+n5,r6					; r6 := 2d vertex
; Write points to the polygontable.
	do	#2,_coordloop
	move					y:(r3)+,x0
	move			x0,x:(r4)+
_coordloop:
	move			x:(r6)+,x0			; Fetch u1.
	mpy	x0,x1,a		x:(r6),x0			; Fetch v1.
	mpy	x0,x1,b		a0,x:(r4)+			; Write u1.
	lua	(r1)+n1,r6					; r6 := Normal
	clr	a		b0,x:(r4)+			; Write v1.
	clr	b		y1,a0
	move			y1,b0
	move					y:(r6)+,y0	; Fetch Normal.X (=u2).
	mac	y0,x1,a				y:(r6),y0	; Fetch Normal.Y (=v2).
	mac	y0,x1,b		a0,x:(r4)+			; Write u2.
	move			b0,x:(r4)+			; Write v2.
_loop:
	jmp	<Polygon.copyLast

; Clips the polygon against the viewport. This subroutine is generic and
; works for all shadetypes. The used algorithm is sutherland hodgman.
; OUTPUT:
; a: =0 offscreen, >0 onscreen
Polygon.clip:
; First of all we check which sides of the viewport this baby clips against.
	move			#<Polygon.polygonTable,r0
	move			x:<Polygon.vsize,n0
	move			x:<Viewport.XStart,x0
	move			x:<Viewport.XEnd,x1
	move			x:<Viewport.YStart,y0
	move			#<%0001,n1
	move			#<%0010,n2
	move			#<%0100,n3
	move			#<%1000,n4
	move			#<$ffffff,r1			; Clear AND flags.
	move			#<0,r2				; Clear OR flags.
	do	x:<Polygon.points,_check_loop
	clr	b		x:(r0)+,a			; a := y
	cmp	y0,a		n1,y1
	jge	<_check_bottom
	or	y1,b						; if y above viewport, then raise flag
_check_bottom:
	move			x:<Viewport.YEnd,y1
	cmp	y1,a		n2,y1
	jlt	<_check_left
	or	y1,b						; if y below viewport, then raise flag
_check_left:
	move			x:(r0)+n0,a			; a := x, proceed to next point
	cmp	x0,a		n3,y1
	jge	<_check_right
	or	y1,b						; if x left of viewport, then raise flag
_check_right:
	cmp	x1,a		n4,y1
	jlt	<_not_right
	or	y1,b						; if x right of viewport, then raise flag
_not_right:
	move			r1,a
	move			b,y1
	and	y1,a		r2,b
	or	y1,b		a,r1				; Update AND flags.
	move			b,r2				; Update OR flags.
_check_loop:

	tst	a		#<Polygon.polygonTable,r0
	jeq	<_on_screen
_offscreen:
; All points are clipped at one side of the Viewport, no need to process it
; any further.
	clr	a
	rts
_on_screen:
	tst	b		b,x:<Polygon.clipFlags
	jeq	<_end						; No clipflags? Then don't clip at all!

; Here cumms tha clips. 8========D----*

; Here we scale the coordinates up for accuracy reasons.
	move			x:<Polygon.points,r1
	move			#1<<7,x0
	move			(r1)+
	do	r1,_scaleup_loop
	move			x:(r0)+,x1
	mpy	x0,x1,a		x:(r0)-,x1
	mpy	x0,x1,a		a0,x:(r0)+
	move			a0,x:(r0)+n0
_scaleup_loop:

; Clip this bitch against the Viewport according to the flags.
	move			#<Polygon.polygonTable,r0
	move			#<Polygon.polygonTable2,r1
	move			r0,r5
	move			r1,r6
	move			n0,n2

_cornerloop:
	jset	#0,x:<Polygon.clipFlags,_clip_top
	jset	#1,x:<Polygon.clipFlags,_clip_bottom
	jset	#2,x:<Polygon.clipFlags,_clip_left
	jset	#3,x:<Polygon.clipFlags,_clip_right
	jmp	<_end_cornerloop

; I.R. clipping top side.

_clip_top:
	move			x:<Viewport.YStart,x0		; x0 := Viewport.YStart
	move			#>_top,r4
	bclr	#0,x:<Polygon.clipFlags
	jmp	<_clip_corner
_clip_bottom:
	move			x:<Viewport.YEnd,x0		; x0 := Viewport.YEnd
	move			#>_bottom,r4
	bclr	#1,x:<Polygon.clipFlags
	jmp	<_clip_corner
_clip_left:
	move			x:<Viewport.XStart,x0		; x0 := Viewport.XStart
	move			#>_left,r4
	bclr	#2,x:<Polygon.clipFlags
	jmp	<_clip_corner
_clip_right:
	move			x:<Viewport.XEnd,x0		; x0 := Viewport.XEnd
	move			#>_right,r4
	bclr	#3,x:<Polygon.clipFlags
	jmp	<_clip_corner

_clip_corner:
	move			#1<<7,x1
	mpy	x0,x1,a		#<0,r3				; r3 := destination pointcounter = 0
	move			a0,x0				; x0 := Viewport.YStart << 8

	do	x:<Polygon.points,_cliploop
	jmp	(r4)
_end_loop:
	nop
_cliploop:

	move			r3,a
	tst	a		r6,r2
	jeq	<_offscreen

; wrap-crap...
	move			r3,x:<Polygon.points
	move			x:(r2)+,a
	move			a,x:(r1)+
	do	x:<Polygon.vsize,_lastloop
	move			x:(r2)+,a
	move			a,x:(r1)+
_lastloop:

	move			r5,x0
	move			r6,r5
	move			x0,r6
	move			r5,r0
	move			r6,r1

	jmp	<_cornerloop
_end_cornerloop:

; Here we scale the coordinates down again. Yawn.
	move			r0,r2
	move			x:<Polygon.points,r1
	move			#1<<(23-8),x0
	move			(r1)+
	do	r1,_scaledown_loop
	move			x:(r2)+,x1
	mpyr	x0,x1,a		x:(r2)-,x1
	mpyr	x0,x1,a		a,x:(r2)+
	move			a,x:(r2)+n2
_scaledown_loop:

; Polygon is visible and fully within the viewport.
_end:	move			#<1,a
	rts

;
;     /\
;------------        ------------
;   /    \     -->      /    \
;   \    /     -->      \    /
;    \  /                \  /
;     \/                  \/
;
; This clips an edge against the top of the Viewport.
;
_top:	move			x:(r0)+,a			; a := ystart
	cmp	x0,a		x:(r0+n0),b			; b := yend
	jlt	<_top_check_2ndout				; if 1st point is outside, jump.
	cmp	x0,b		r0,r2
	jge	<_inside					; if 2nd point is inside, jump.

; The source edge goes from inside to outside.
; Write the clipped point.
_top_inout:
	move			x0,x:(r1)+
	move			(r0)-
	do	x:<Polygon.vsize,_top_inoutloop
; Prepare for intersection with preset side.
	move			x:(r0)+,a			; x1 := ystart
	move			x:(r0+n0),x1			; a := yend
	sub	x1,a		x:(r2)+,b			; a := yend - ystart (=dy), y1 := xstart
	move			x:(r2+n2),y1			; b := xend
; a := xstart - yi(frac) * slope(fixedpoint)
	jsr	<_intersect
	add	y1,a						; Add xstart.
	move			a,x:(r1)+			; Store new x.
_top_inoutloop:
	move			(r3)+				; Increase pointcount.
	move			r2,r0
	jmp	<_end_loop
	
_top_check_2ndout:
	cmp	x0,b		r0,r2
	jge	<_top_outin

; Source edge is outside. Don't write it out.
	move			(r0)+n0
	jmp	<_end_loop

; The source edge goes from outside to inside.
; Write the clipped point and the inside point as well.
_top_outin:
	move			x0,x:(r1)+
	move			(r0)-
	do	x:<Polygon.vsize,_top_outinloop
; Prepare for intersection with preset side.
	move			x:(r0)+,x1			; x1 := ystart
	move			x:(r0+n0),a			; a := yend
	sub	x1,a		x:(r2)+,y1			; a := yend - ystart (=dy), y1 := xstart
	move			x:(r2+n2),b			; b := xend
; a := xstart + yi(frac) * slope(fixedpoint)
	jsr	<_intersect
	add	y1,a						; Add xstart.
	move			a,x:(r1)+			; Store new x.
_top_outinloop:

	move			(r0)+				; Adjust point position.
	move			(r3)+				; Increase pointcount.
	jmp	<_inside

;
;     /\                  /\
;    /  \                /  \
;   /    \     -->      /    \
;   \    /     -->      \    /
;------------        ------------
;     \/
;
; This clips an edge against the bottom of the Viewport.
;
_bottom:
	move			x:(r0)+,a			; a := ystart
	cmp	x0,a		x:(r0+n0),b			; b := yend
	jge	<_bottom_check_2ndout				; if 1st point is outside, jump.
	cmp	x0,b		r0,r2
	jlt	<_inside					; if 2nd point is inside, jump.

; The source edge goes from inside to outside.
; Write the clipped point.
_bottom_inout:
	move			x0,x:(r1)+
	move			(r0)-
	do	x:<Polygon.vsize,_bottom_inoutloop
; Prepare for intersection with preset side.
	move			x:(r0)+,a			; x1 := ystart
	move			x:(r0+n0),x1			; a := yend
	sub	x1,a		x:(r2)+,b			; a := yend - ystart (=dy), y1 := xstart
	move			x:(r2+n2),y1			; a := -dy, b := xend
; a := xstart + yi(frac) * slope(fixedpoint)
	jsr	<_intersect
	neg	a
	add	y1,a						; Add xstart.
	move			a,x:(r1)+			; Store new x.
_bottom_inoutloop:
	move			(r3)+				; Increase pointcount.
	move			r2,r0
	jmp	<_end_loop
	
_bottom_check_2ndout:
	cmp	x0,b		r0,r2
	jlt	<_bottom_outin

; Source edge is outside. Don't write it out.
	move			(r0)+n0
	jmp	<_end_loop

; The source edge goes from outside to inside.
; Write the clipped point and the inside point as well.
_bottom_outin:
	move			x0,x:(r1)+
	move			(r0)-
	do	x:<Polygon.vsize,_bottom_outinloop
; Prepare for intersection with preset side.
	move			x:(r0)+,x1			; x1 := ystart
	move			x:(r0+n0),a			; a := yend
	sub	x1,a		x:(r2)+,y1			; a := yend - ystart (=dy), y1 := xstart
	neg	a		x:(r2+n2),b			; a := -dy, b := xend
; a := xstart - yi(frac) * slope(fixedpoint)
	jsr	<_intersect
	neg	a
	add	y1,a						; Add xstart.
	move			a,x:(r1)+			; Store new x.
_bottom_outinloop:

	move			(r0)+				; Adjust point position.
	move			(r3)+				; Increase pointcount.
	jmp	<_inside

;
;    |/\                 |/\
;    |  \                |  \
;   /|   \     -->       |   \
;   \|   /     -->       |   /
;    |  /                |  /
;    |\/                 |\/
;
; This clips an edge against the left side of the Viewport.
;
_left:	move			(r0)+
	move			r0,r2
	move			x:(r0)+,a			; a := xstart
	move			x:(r0+n0),b			; b := xend
	cmp	x0,a		(r0)-
	jlt	<_left_check_2ndout				; if 1st point is outside, jump.
	cmp	x0,b		
	jge	<_inside					; if 2nd point is inside, jump.

; The source edge goes from inside to outside.
; Write the clipped point.
_left_inout:
	move			(r0)-				; x:(r0) : source y start
	move			(r1)+				; x:(r1) : dest. x start
	move			x0,x:(r1)-			; X := Viewport.XStart
								; x:(r1) : dest. y start
; Prepare for intersection with preset side.
	move			x:(r2)+,a			; y1 := xstart
	move			x:(r2+n2),x1			; a := xend
	sub	x1,a		x:(r0)+,b			; a := xend - xstart (=dx), y1 := ystart
	move			x:(r0+n0),y1			; b := yend
; a := ystart - xi(frac) * slope(fixedpoint)
	jsr	<_intersect
	add	y1,a		(r0)+				; Add ystart.
	move			a,x:(r1)+			; Store new y, x:(r1) : dest. x coord

; loopcounter = amount of coords except x,y
	move			x:<Polygon.vsize,a
	move			#>1,x1
	sub	x1,a		(r1)+				; Proceed to next dest. coord.
	jeq	<_end_left_inout

	do	a,_left_inoutloop
; Prepare for intersection with preset side.
	move			x:(r0)+,x1			; x1 := xstart
	move			x:(r0+n0),a			; a := xend
	sub	x1,a		x:(r2)+,y1			; a := xend - xstart (=dx), y1 := ustart
	move			x:(r2+n2),b			; b := uend
; a := ustart - xi(frac) * slope(fixedpoint)
	jsr	<_intersect
	neg	a
	add	y1,a						; Add ustart.
	move			a,x:(r1)+			; Store new u.
_left_inoutloop:
_end_left_inout:
	move			(r3)+				; Increase pointcount.
	move			r2,r0
	jmp	<_end_loop
	
_left_check_2ndout:
	cmp	x0,b
	jge	<_left_outin

; Source edge is outside. Don't write it out.
	move			(r0)+n0
	jmp	<_end_loop

; The source edge goes from outside to inside.
; Write the clipped point and the inside point as well.
_left_outin:
	move			(r1)+
	move			x0,x:(r1)-			; X := Viewport.XStart
	move			(r0)-

; Prepare for intersection with preset side.
	move			x:(r2)+,x1			; y1 := xstart
	move			x:(r2+n2),a			; a := xend
	sub	x1,a		x:(r0)+,y1			; a := xend - xstart (=dx), y1 := ystart
	move			x:(r0+n0),b			; b := yend
; a := xstart - yi(frac) * slope(fixedpoint)
	jsr	<_intersect
	add	y1,a		(r0)+				; Add ystart.
	move			a,x:(r1)+			; Store new y.

; loopcounter = amount of coords except x,y
	move			x:<Polygon.vsize,a
	move			#>1,x1
	sub	x1,a		(r1)+				; Proceed to next dest. coord.
	jeq	<_end_left_outin

	do	a,_left_outinloop
; Prepare for intersection with preset side.
	move			x:(r0)+,x1			; x1 := xstart
	move			x:(r0+n0),a			; a := xend
	sub	x1,a		x:(r2)+,y1			; a := xend - xstart (=dx), y1 := ustart
	move			x:(r2+n2),b			; b := uend
; a := ustart + xi(frac) * slope(fixedpoint)
	jsr	<_intersect
	add	y1,a						; Add ustart.
	move			a,x:(r1)+			; Store new u.
_left_outinloop:
_end_left_outin:
	move			(r3)+				; Increase pointcount.
	jmp	<_inside

;
;     /\|                 /\|
;    /  |                /  |
;   /   |\     -->      /   |
;   \   |/     -->      \   |
;    \  |                \  |
;     \/|                 \/|
;
; This clips an edge against the right side of the Viewport.
;
_right:	move			(r0)+
	move			r0,r2
	move			x:(r0)+,a			; a := xstart
	move			x:(r0+n0),b			; b := xend
	cmp	x0,a		(r0)-
	jge	<_right_check_2ndout				; if 1st point is outside, jump.
	cmp	x0,b		
	jlt	<_inside					; if 2nd point is inside, jump.

; The source edge goes from inside to outside.
; Write the clipped point.
_right_inout:
	move			(r0)-				; x:(r0) : source y start
	move			(r1)+				; x:(r1) : dest. x start
	move			x0,x:(r1)-			; X := Viewport.XStart
								; x:(r1) : dest. y start
; Prepare for intersection with preset side.
	move			x:(r2)+,a			; y1 := xstart
	move			x:(r2+n2),x1			; a := xend
	sub	x1,a		x:(r0)+,b			; a := xend - xstart (=dx), y1 := ystart
	move			x:(r0+n0),y1			; b := yend
; a := ystart - xi(frac) * slope(fixedpoint)
	jsr	<_intersect
	neg	a
	add	y1,a		(r0)+				; Add ystart.
	move			a,x:(r1)+			; Store new y, x:(r1) : dest. x coord

; loopcounter = amount of coords except x,y
	move			x:<Polygon.vsize,a
	move			#>1,x1
	sub	x1,a		(r1)+				; Proceed to next dest. coord.
	jeq	<_end_right_inout

	do	a,_right_inoutloop
; Prepare for intersection with preset side.
	move			x:(r0)+,x1			; x1 := xstart
	move			x:(r0+n0),a			; a := xend
	sub	x1,a		x:(r2)+,y1			; a := xend - xstart (=dx), y1 := ustart
	move			x:(r2+n2),b			; b := uend
; a := ustart - xi(frac) * slope(fixedpoint)
	jsr	<_intersect
	add	y1,a						; Add ustart.
	move			a,x:(r1)+			; Store new u.
_right_inoutloop:
_end_right_inout:
	move			(r3)+				; Increase pointcount.
	move			r2,r0
	jmp	<_end_loop
	
_right_check_2ndout:
	cmp	x0,b
	jlt	<_right_outin

; Source edge is outside. Don't write it out.
	move			(r0)+n0
	jmp	<_end_loop

; The source edge goes from outside to inside.
; Write the clipped point and the inside point as well.
_right_outin:
	move			(r1)+
	move			x0,x:(r1)-			; X := Viewport.XStart
	move			(r0)-

; Prepare for intersection with preset side.
	move			x:(r2)+,x1			; y1 := xstart
	move			x:(r2+n2),a			; a := xend
	sub	x1,a		x:(r0)+,y1			; a := xend - xstart (=dx), y1 := ystart
	move			x:(r0+n0),b			; b := yend
; a := xstart - yi(frac) * slope(fixedpoint)
	jsr	<_intersect
	neg	a
	add	y1,a		(r0)+				; Add ystart.
	move			a,x:(r1)+			; Store new y.

; loopcounter = amount of coords except x,y
	move			x:<Polygon.vsize,a
	move			#>1,x1
	sub	x1,a		(r1)+				; Proceed to next dest. coord.
	jeq	<_end_right_outin

	do	a,_right_outinloop
; Prepare for intersection with preset side.
	move			x:(r0)+,x1			; x1 := xstart
	move			x:(r0+n0),a			; a := xend
	sub	x1,a		x:(r2)+,y1			; a := xend - xstart (=dx), y1 := ustart
	move			x:(r2+n2),b			; b := uend
; a := ustart + xi(frac) * slope(fixedpoint)
	jsr	<_intersect
	neg	a
	add	y1,a						; Add ustart.
	move			a,x:(r1)+			; Store new u.
_right_outinloop:
_end_right_outin:
	move			(r3)+				; Increase pointcount.
	jmp	<_inside

; The source edge is inside -> write the second point to the destination.
_inside:
	move			(r0)+n0				; Proceed to next point.
	move			r0,r2
	move			(r3)+				; Increase pointcount.
	move			x:(r2)+,x1
	move			x1,x:(r1)+
	do	x:<Polygon.vsize,_copy_loop
	move			x:(r2)+,x1
	move			x1,x:(r1)+
_copy_loop:
	jmp	<_end_loop

; Generic intersection routine.
; INPUT:
; x1: ystart
; y1: xstart
; a: yend - ystart (=dy)
; b: xend
_intersect:
	sub	y1,b		a,y0				; b := xend - xstart (=dx), y0 := dy
	abs	b		b,a				; b := abs(b), a := dx
	move			b,b0
	move			#<0,b1
	rep	#8
	asl	b
	andi	#$fe,ccr
	rep	#24
	div	y0,b						; b := dx/dy (=slope)
	tst	a		b0,b
	jpl	<_divisorpos
	neg	b
_divisorpos:
	move			x0,a				; a := Viewport.YStart
	sub	x1,a		b,y0				; a := Viewport.YStart - ystart (=yi), y0 := int(slope)
	move			a,x1				; x1 := yi
; a := yi(frac) * slope(fixedpoint)
	mpy	+x1,y0,a	(r0)-
	rep	#8
	asr	a		
	move			a0,a
	rts

; Get top and bottom of polygon.
; INPUT:
; x:(r0): polygon table
Polygon.getDimensions:
	move			r0,r1
	move			#>$7fffff,a			; top := MAX_INT
	move			#>$800000,b			; bottom := MIN_INT
	move			x:<Polygon.vsize,n1

	do	x:<Polygon.points,_loop
	move			x:(r1)+,y0			; Fetch Vertex.Y.
	cmp	y0,a		(r1)+n1				; Proceed to next Vertex.
	tgt	y0,a						; If new value is lower, set new top.
	cmp	y0,b
	tlt	y0,b						; If new value is higher, set new bottom.
_loop:
	sub 	a,b		a,x:<Polygon.top		; Store top, height := bottom-top
	move			b,x:<Polygon.height		; Store height.
	rts

; Sends a mapped polygon over.
Polygon.send:
	move			x:<Polygon.textureNumber,y0
	send	y0						; Send texture number.

	send	x:<Polygon.top					; Send minimum y.

	move			x:<Polygon.height,a
	send	a						; Send height.
	tst	a		a,n6
	jgt	<_go_on
; Poly is 0 high, don't paint.
	rts
_go_on:
; x0=top, y0=texturenum, a=height

	move			x:<Polygon.vsize,b
	move			#>Polygon.LeftEdge,r0
	move			#>Polygon.RightEdge,r1
	move			#>1,x0
	sub	x0,b		#>InverseTable,r2
	jeq	<Polygon.paintFlat
	sub	x0,b		#>Polygon.texture,r4		; r4= (color) texture
	jeq	<Polygon.paintGouraudShaded
	sub	x0,b		#>HTX,r3
	jeq	<Polygon.paintTextured
	move			#>Polygon.texture+64*64,r5	; r5= alpha texture
	jmp	<Polygon.paintV4

; Receives polygon data from the cpu and stores it.
; This works for any shade type. (flat, gouraud, texture, gouraudtexture, alpha/bump)
Polygon.receive:
	move			#<Polygon.points,r0
	move			#<Polygon.vsize,r1
	move			#<Polygon.polygonTable,r2
	get			x:>Polygon.textureNumber	; Get texturenumber.
	get	x:(r0)						; Get number of points in polygon.
	get	x:(r1)						; Get number of coordinates-1 in point.
	move			x:(r1),r3
	move			#>$7fffff,a			; top := MAX_INT
	move			#>$800000,b			; bottom := MIN_INT

	do	x:(r0),_receiveloop
	get	y0
	cmp	y0,a		y0,x:(r2)+			; Store y.
	tgt	y0,a						; If new value is lower, set new top.
	cmp	y0,b
	tlt	y0,b						; If new value is higher, set new bottom.
	do	r3,_receivecoord
	get	x:(r2)+
_receivecoord:
	nop
_receiveloop:

; Copy first point as last also. (wrap-crap)
	move			(r3)+
	move			#<Polygon.polygonTable,r1
	do	r3,_repeatloop
	move			x:(r1)+,x0
	move			x0,x:(r2)+
_repeatloop:

	sub	a,b		a,x:<Polygon.top		; Store top, height := bottom-top.
	move			b,x:<Polygon.height		; Store height.
	rts

; This stores textures sent by the host.
; The texturebuffer allows up to 8192 interleaved (7b,16b) pixels
; (0aaaaaaahhhhhhhhhhhhhhhh).
Polygon.storeTexture:
	move			#>8192,n6
	move			#>$7F0000,x0
	move			#>Polygon.texture,r0

; We do this one for the alpha's. 8bpp -> 7bpp (for signed sillyness).
	do	n6,_rescale7bitloop
	get	a
	asr	a		a,b
	and	x0,a		#>$00FFFF,x1
	and	x1,b
	move			b,y0
	or	y0,a
	move					a1,y:(r0)+
_rescale7bitloop:

; Sets texturing to pixel-mode. Implies 64*64 mapping!
Polygon.setPixelMode:
	move			#>64,x0
	move			x:<Polygon.sendPixelInstruction,y0
	jmp	<Polygon.setTextureSize

; Sets texturing to offset-mode. Implies 256*256 mapping!
Polygon.setOffsetMode:
	move			#>256,x0
	move			x:<Polygon.sendOffsetInstruction,y0

; x0=dimension {2,4,8,16,32,64,128,256,...}
Polygon.setTextureSize:
	move	y0,p:>Polygon.paintTextured_pixelinstruction
	mpy	x0,x0,a		x0,x:<texturewidth
	asr	a		#>1,x1
	tfr	x0,b		a0,a
	sub	x1,a		a,x:<texturesize
	neg	b		a1,x1
	and	x1,b		#>64,y1
	mpy	x0,y1,a				b1,y:<texturemask
; U scaling (6:10 -> 6 or 8:8 -> 8) :
; $002000 for 64
; $008000 for 256
	move			a0,x:<u_scale
; V scaling (6:10 -> 6:6 or 8:8 -> 8:8) :
; $080000 for 64x64 $1000
; $800000 for 256x256 $10000 (isn't this negative?)
	move			#>$40,y1
	move			x:<texturesize,x0
	mpy	x0,y1,a
	move			a0,y:v_scale
	rts

Polygon.setV4AlphaMode:
	move	#Polygon.paintV4_send_alpha_hline,x0
	move	x0,y:<Polygon.v4RoutineAddress
	rts

Polygon.setV4BumpMode:
	move	#Polygon.paintV4_send_bump_hline,x0
	move	x0,y:<Polygon.v4RoutineAddress
	rts

; RPC call routine!
Polygon.paintReceivedClipped:
	jsr	<Polygon.receive
	jsr	<Polygon.clip
; a = clipped/unclipped flag, r0 = polygon table
	tst	a
	jeq	<_culled

; Send the shadetype.
	send	x:<Polygon.shadeType
	jmp	<Polygon.paintClipped_proceed

; Send negative shadetype = terminator!
_culled:send	#-1
	rts

Polygon.paintClipped:
; Clip the polyon..
	jsr	<Polygon.clip
; a = clipped/unclipped flag, r0 = polygon table
	tst	a
	jeq	<_end

; Send the shadetype first.
	send	x:<Polygon.shadeType

; Outline stuff.. Only needed when painted from mesh in dsp mem..
	move			x:>PrimitiveMesh.shadowOn,b
	tst	b		x:<Polygon.vsize,n1
	jeq	<_proceed

; Send outlines to host..
	move			#<1,n0
	move			x:<Polygon.points,x1
	send	x1						; Send #points.
	lua	(r0)+n0,r1					; r1: first x in polytable

	do	x1,_loop
	send	x:(r1)-						; Send x.
	send	x:(r1)+						; Send y.
	move			(r1)+n1
	move			(r1)+
_loop:

_proceed:
; Sends polygon scanlinewise.
; r0= polygontable
	jsr	<Polygon.getDimensions
	move			r0,r6
	jsr	<Polygon.drawEdges
	jmp	<Polygon.send

_end:	rts

; RPC call routine!
; Beware: unclipped painter!
Polygon.paint:
	jsr	<Polygon.receive
	move			#<Polygon.polygonTable,r6
	jsr	<Polygon.drawEdges
	jmp	<Polygon.send

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
	jsr	<Polygon.setPixelMode
	jsr	<Object.clear
	clr	a
	move			a,x:<Matrix.stackTop
	rts

; Calculates 1/n table.
GetInvTable:
	move			#>InverseTable,r0
	clr	a		#>1,x0
	move			#>$7FFF00,y0
	do	#INVBUF_SIZE,_loop
	move			a1,x1
	move			#>1,b
	rep	#24
	div	x1,b
	move			b0,b
	and	y0,b						; And to get same low precision as 68K
	add	x0,a				b,y:(r0)+
_loop:	rts

;======== Viewport

; Get new viewport settings from cpu.
Viewport.update:
	move			#<Viewport.settingsTable,r0
	do	#Viewport.SIZE,_loop
	get	x:(r0)+
_loop:
	move			x:<Viewport.Aspect,x0
	move			#1<<13,x1
	mpy	x0,x1,a
	move			a0,x:<Viewport.Aspect
	rts

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
	move			#<Matrix.temp,r6

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

; Set translation vector to origin.
	clr	a				a,y:(r6)+
	move					a,y:(r6)+
	move					a,y:(r6)+
	move					a,y:(r6)+
	rts

; INPUT:
; y:r0: matrix to multiply with (source)
; y:r3: (new) destination matrix
Matrix.multiply:
; Get source and destination matrices and flip them.
	move			#<Matrix.temp,r2
	move			r0,r4				; r4 := source
	move			r2,r5
	move			#<3,n2

; Multiply the matrix.
	do	#3,_row_loop
; Fetch new row.
	move					y:(r0)+,x0
	move					y:(r0)+,x1
	move					y:(r0)+,y0

	do	#3,_cell_loop
; Multiply column with row.
	move					y:(r2)+n2,y1
	mpy	x0,y1,a				y:(r2)+n2,y1
	mac	x1,y1,a				y:(r2)-n2,y1
	macr	y0,y1,a		(r2)-n2
	move					a,y:(r3)+	; Store product.
	move			(r2)+				; Proceed to next column.
_cell_loop:

	move			(r2)-n2				; Back to first column.
_row_loop:

; Multiply the object translation vector with the world matrix.
	move			#<Matrix.temp+Matrix.TX,r2
	move					y:(r4)+,y1
	move					y:(r2)+,x0
	move					y:(r2)+,x1
	move					y:(r2)+,y0
	do	#3,_transloop
	move					y:(r0)+,a	; a := source TX
	mac	x0,y1,a				y:(r4)+,y1	; TX * MXX +
	mac	x1,y1,a				y:(r4)+,y1	; TY * MXY +
	macr	y0,y1,a				y:(r4)+,y1	; TZ * MXZ
	move					a,y:(r3)+	; Store TX'.
_transloop:
	rts

Matrix.convertStoredQuaternion:
	rts

Matrix.convertQuaternion:
	rts

Matrix.convertRotation:
	move	#<SineX,r0
	move	#<CosineX,r1
	move	#<SineY,r2
	move	#<CosineY,r3
	move	#<SineZ,r4
	move	#<CosineZ,r5
	jsr	<ReceiveRotation
	jmp	<Matrix.generate

; INPUT:
; x:r0: sin/cos values
Matrix.convertStoredRotation:
	move			r0,r6
	move			#<SineX,r0
	move			#<CosineX,r1
	move			#<SineY,r2
	move			#<CosineY,r3
	move			#<SineZ,r4
	move			#<CosineZ,r5
	move			x:(r6)+,x0
	move			x0,x:(r0)
	move			x:(r6)+,x0
	move			x0,x:(r1)
	move			x:(r6)+,x0
	move			x0,x:(r2)
	move			x:(r6)+,x0
	move			x0,x:(r3)
	move			x:(r6)+,x0
	move					x0,y:(r4)
	move			x:(r6)+,x0
	move					x0,y:(r5)
	jmp	<Matrix.generate

Matrix.rpcTranslate:
	get	x0
	get	x1
	get	y0
	jmp	<Matrix.translate

; INPUT:
; x:r0: stored parameters
Matrix.translateStored:
	move			x:(r0)+,x0
	move			x:(r0)+,x1
	move			x:(r0)+,y0

; INPUT:
; x0: X
; x1: Y
; y0: Z
Matrix.translate:
	move			#<Matrix.temp+Matrix.TX,r0
	move			#<1,n0
	move					y:(r0)+,a
	add	x0,a				y:(r0)-,b
	add	x1,b				a,y:(r0)+
	move					y:(r0+n0),a
	add	y0,a				b,y:(r0)+
	move					a,y:(r0)
	rts

; Pushes a previously generated matrix on the stack.
Matrix.push:
; First check for stack overflow.
	move			#<Matrix.stack,r0
	move			x:<Matrix.stackTop,a
	tst	a		#>Matrix.MAX_DEPTH,x0
	jeq	<_first_entry
	cmp	x0,a		#>Matrix.SIZE,x0
	jhs	<_end
; The stack is not full..

_not_first_entry:
	move			a,x1
	mpy	x0,x1,a
	asr	a
	move			a0,n0				; n0 := offset to dest. matrix
	move			x0,n1
	move			(r0)+n0				; r0 := dest. matrix
	move			r0,r1
	move			r0,r3				; r3 := dest. matrix
	move			(r1)-n1				; r1 := source matrix
	move			r1,r0				; r0 := source matrix
	jsr	<Matrix.multiply
	jmp	<_end_multiply_matrix
; If this is the first matrix on the stack, then simply copy it.
_first_entry:
	move			#<Matrix.temp,r1
	do	#Matrix.SIZE,_copy_loop
	move					y:(r1)+,x0
	move					x0,y:(r0)+
_copy_loop:
_end_multiply_matrix:

; Increase the stacktop by one.
	move			x:<Matrix.stackTop,a
	move			#>1,x0
	add	x0,a
	move			a,x:<Matrix.stackTop

_end:	rts

; Pops the top matrix off the stack.
Matrix.pop:
	move			x:<Matrix.stackTop,a
	tst	a		#>1,x0
	jle	<_end
	sub	x0,a
	move			a,x:<Matrix.stackTop
_end:	rts

;======== PrimitiveMesh

; INPUT:
; x:r0: stored parameter (shadow-flag)
PrimitiveMesh.new:
; Store shadow-flag..
	move			x:(r0)+,a
	move			a,x:>PrimitiveMesh.shadowOn
; Reset pointers..
	clr	a		#>PrimitiveMesh.vertexTable,x0
	move			x0,x:>PrimitiveMesh.nextVertex
	move			a,x:>PrimitiveMesh.primitiveTable
	move			a,x:>BoundingBox.rectangleCount
	move			a,x:>PrimitiveMesh.baseHandle
	rts

; Paints all primitives.
PrimitiveMesh.paint:
	move			#<PrimitiveMesh.primitiveTable,r0
	nop
	move			x:(r0)+,a
	tst	a
	jeq	<_end

	do	a,_loop
	move			#>Primitive.TYPEMASK,x0
	IFNE	1
	move			x:(r0)+,r1			; r1= base of primitive's vertices
	move			x:(r0)+,r2			; r2= address of primitive
	ELSE
	move			x:(r0)+,x1
	move			#>$000080,x0
	mpy	x0,x1,a		#>PrimitiveMesh.baseTable,r1
	move			a1,n1				; r1= vertexbase handle
	move			x1,r2				; r2= address of primitive
	move			x:(r1+n1),r1			; r1= vertex base address
	ENDC
	clr	a		(r0)+
	move			x:(r2),a1			; a= primitive's type
	move			r0,p:>PrimitiveMesh.currentElement
	and	x0,a		#>Primitive.SPRITETYPE,x0
	cmp	x0,a		#>Primitive.LINETYPE,x0
	jgt	_test_line

; Handle a sprite.
_is_sprite:
	send	#RPC_SPRITE
	move			(r1)+
	send	x:(r2)+
	move			x:(r2)+,a			; Fetch vertex index.
	asl	a		a,x0
	add	x0,a		r1,b
	add	a,b
	move			b,r1
	do	#3,_spriteloop
	send	y:(r1)+
_spriteloop:
	move			(r1)-
	jmp	<_end_loop
_test_line:
	cmp	x0,a
	jgt	_is_polygon

; Handle a line.
_is_line:
	send	#RPC_LINE
	move			(r1)+
	move			x:(r2)+,x1
	send	x1
	do	#2,_lineloop
	move			x:(r2)+,a			; Fetch vertex index.
	asl	a		a,x0
	add	x0,a		r1,b
	add	a,b		r1,r3
	move			b,r1
	do	#2,_linecoordloop
	send	y:(r1)+
_linecoordloop:
	move			r3,r1
_lineloop:
	tfr	x1,a		#>Primitive.SHADEMASK,x0
	and	x0,a		#>Line.GOURAUDSHADED,x0
	cmp	x0,a
	jeq	<_gouraudshaded
	jgt	<_phongshaded
_flatshaded:
	move			(r1)-
	jmp	<_end_loop

_gouraudshaded:
	move			(r1)-
	send	x:(r2)+
	send	x:(r2)+
	jmp	<_end_loop

_phongshaded:
	move			#<Vertex.Z,n1
	move			#>$80,x1
	do	#2,_phongloop
	move			x:(r2)+,a			; Fetch vertex index.
	asl	a		a,x0
	add	x0,a		r1,b
	add	a,b		r1,r3
	move			b,r1
	nop
	move					y:(r1+n1),a
	add	x1,a
	asr	a		r3,r1
	send	a
_phongloop:
	move			(r1)-
	jmp	<_end_loop

; Handle a polygon.
_is_polygon:
	jsr	<Polygon.decode
	jsr	<Polygon.paintClipped

_end_loop:
	move			p:>PrimitiveMesh.currentElement,r0
_loop:

; All primitives are painted, now send the terminator: "I'll be back"... ;)
_end:	move			#>$ffffff,x0
	send	x0

; Now send them bounding rectangle critters.
	move			x:>BoundingBox.rectangleCount,a
	send	a						; Send rectanglecount.
	lsl	a		#>BoundingBox.rectangles,r0
	jeq	<_die
	lsl	a
	do	a,_rectloop
	send			x:(r0)+
_rectloop:
_die:	rts

PrimitiveMesh.currentElement:
	DS	1

;======== TransformObject

; RPC call routine!
TransformObject.rpcTransform:
	get	n0
	jmp	<TransformObject.transform

;======== ObjectRegistry

; Adds a 3d-object to the registry and returns a handle to host.
; Returns -1 if not added.
Object.set:
	move			x:>Object.newHandleAddress,r1
	get	a						; Get #objwords+#bufwords.
	move			#>Object.CAPACITY,x0
	cmp	x0,a		x:(r1)+,r0			; Get designated address in object-buffer.
	jgt	<_error
	move			r0,r2				; backup start of object
	move			#>Object.handlesEnd,b
	move			r1,x0
	cmp	x0,b		#<0,x0
; Inform the host the object is accepted (result = 0)..
	send	x0
	get	a						; Get #objwords

	do	a,_get_object_loop
	get	x:(r0)+						; Receive one object word from cpu.
_get_object_loop:

; Store pointer to next handle..
	move			r1,x:>Object.newHandleAddress
	move			#>Object.handleTable,n1
	move			r0,x:(r1)-			; Store start of free space.
	move			(r1)-n1
	move			r1,x0				; x0=boundingbox handle
	jmp	<BoundingBox.init

; Inform the host the object is rejected (result = -1)..
_error:	move			#>-1,a
	send	a
	rts

; Returns the objectaddress of the specified handle.
; No checking for invalid handles!!
; INPUT:
; n0: ObjectHandle
; OUTPUT:
; r0: ObjectAddress
Object.get:
	move			#>Object.handleTable,r0
	nop
	move			x:(r0+n0),r0
	rts

; Clears the registry. All handles become invalid.
Object.clear:
	move			#Object.handleTable,x0
	move			x0,x:>Object.newHandleAddress
	move			#Object.buffer,x0
	move			x0,x:>Object.handleTable
	rts

; Replaces object's primitives/vertices/normals/texels.
; Reads these from the host.
Object.replace:
	move			#>Object.handleTable,r0
	get	n0						; n0=handle
	get	a						; a=replacemode
	move			x:(r0+n0),r0			; r0=object
	move			n0,n6				; n6=handle
	move			r0,r6				; r6=object

; Calculate addresses of tables and lists.
	move			x:(r0)+,b			; b=#vertices+#normals
	lsl	b		b,x0
	add	x0,b		x:(r0)+,x0			; x0=#normals
	move			b1,n0				; n0=(#vertices+#normals)*3=offset to texels
	move			x0,b
	lua	(r0)+n0,r2
	asl	b
	add	x0,b
	move			b1,n2				; n2=#normals*3
	move			x:(r2)+,n3			; n3=#texels
	lua	(r2)-n2,r1
	move			r2,r3
	nop
	move			(r3)+n3
	move			(r3)+n3
; r0=vertices
; r1=normals
; r2=texels
; r3=primitives

; Get vertices..
	lsr	a
	jcc	<_end_vertices	
	get	b						; b=#words
	tst	b
	jeq	<_end_vertices
	do	b,_ver_loop

	get	x:(r0)+	
_ver_loop:
_end_vertices:

; Get normals..
	lsr	a
	jcc	<_end_normals
	get	b						; b=#words
	tst	b
	jeq	<_end_normals
	do	b,_nor_loop

	get	x:(r1)+	
_nor_loop:
_end_normals:

; Get texels..
	lsr	a
	jcc	<_end	
	get	b						; b=#words
	tst	b
	jeq	<_end
	do	b,_tex_loop

	get	x:(r2)+	
_tex_loop:

; Get primitives..
	lsr	a
	jcc	<_end
	get	b						; b=#words
	tst	b
	jeq	<_end
	do	b,_prim_loop

	get	x:(r3)+	
_prim_loop:

_end:	move			n6,x0				; x0=handle
	move			r6,r2				; r2=object
	jmp	<BoundingBox.init

; Processes an object into a bounding box.
; A bounding box is represented by axxiii (what's that spelled like?)
; Each axis has an upper and a lower bound.
; INPUT:
; x0: bounding box handle
; x:r2: ufly.2 object
BoundingBox.init:
; First initialize the destination structure.
	move			#>BoundingBox.SIZE,x1
	mpy	x0,x1,a		x1,n0
	asr	a		#>BoundingBox.table,x0
	move			a0,a
	add	x0,a		#>$800000,b			; initial highest
	move			a,r0
	move			#>$7fffff,a			; initial lowest
	do	#3,_resetloop
	move			a,x:(r0)+
	move			b,x:(r0)+
_resetloop:

	move			x:(r2)+,x0
	move			(r2)+
	move			(r0)-n0

	do	x0,_vertexloop
	do	#3,_coordloop
	move			x:(r0)+,a			; a= lowest
	move			x:(r2)+,x0			; x0= coord
	cmp	x0,a		x:(r0)-,b			; b= highest
	tgt	x0,a
	cmp	x0,b		a,x:(r0)+
	tlt	x0,b
	move			b,x:(r0)+
_coordloop
	move			(r0)-n0
_vertexloop:	
	rts

; Transforms a bounding box into a bounding rectangle.
; INPUT:
; n0: objecthandle
; OUTPUT:
; a: 1=visible, 0=invisible
BoundingBox.calcRectangle:
	move			n0,x0
	move			#>BoundingBox.SIZE,x1
	mpy	x0,x1,a		#>BoundingBox.decoded,r1
	asr	a		#>BoundingBox.table,r2
	move			a0,n2
	clr	a		#>1,x1
	move			(r2)+n2
	move			#<5,n2

; x:r0 = address of encoded box (src)
; x:r1 = address of decoded box (dst)
	move			#>%111,b
	do	#8,_loop
_do_x:	move			x:(r2)+,a
	move			x:(r2)+,x0
	jclr	#0,b,_no_x
	tfr	x0,a
_no_x:	move			a,x:(r1)+
_do_y:	move			x:(r2)+,a
	move			x:(r2)+,x0
	jclr	#1,b,_no_y
	tfr	x0,a
_no_y:	move			a,x:(r1)+
_do_z:	move			x:(r2)+,a
	move			x:(r2)-n2,x0
	jclr	#2,b,_no_z
	tfr	x0,a
_no_z:	sub	x1,b		a,x:(r1)+
_loop:

	move			#>BoundingBox.decoded,r0
	move			#>BoundingBox.transformed-1,r5
	move			#>8,b
	jsr	<Vertex.transform

; Check if behind cam...
	move			#>BoundingBox.transformed+2,r2
	move			#<3,n2
	clr	a
	move					y:(r2)+n2,x0
	rep	#7
	or	x0,a				y:(r2)+n2,x0

	tst	a
	jmi	<_invisible

; Transform the box into a rectangle...
; dim??? D1m??!?!?! That's sounds like *yich* BASIC! :P
	move			x:>BoundingBox.rectangleCount,a
	lsl	a		#>BoundingBox.transformed,r2
	lsl	a		#>BoundingBox.rectangles,x0
	add	x0,a		#<8*3-1,n2
	move			a,r1				; r1= new rectangle
	move			a,r3
	do	#2,_outloop
	move			#>$7fffff,a			; a= min
	move			#<$80,b				; b= max
	do	#8,_dimloop
	move					y:(r2)+,x0	; x0= coord
	cmp	x0,a		(r2)+
	tgt	x0,a
	cmp	x0,b		(r2)+
	tlt	x0,b
_dimloop:
	move			a,x:(r1)+			; Store min.
	move			b,x:(r1)+			; Store max.
	move			(r2)-n2
_outloop:

; Store rectangle....
	move			#<0,r0
	move			x:(r3)+,a
	move			x:(r3)+,b
	move			x:<Viewport.YStart,x0
	cmp	x0,b		x:<Viewport.YEnd,x1
	jgt	<_end_left
	move			#<1,r0
_end_left:
	cmp	x1,a		x:<Viewport.XStart,y0
	jle	<_end_right
	move			#<1,r0
_end_right:
	move			x:(r3)+,a
	move			x:(r3)+,b
	cmp	y0,b		x:<Viewport.XEnd,y1
	jgt	<_end_top
	move			#<1,r0
_end_top:
	cmp	y1,a
	jle	<_end_bottom
	move			#<1,r0
_end_bottom:

	nop
	move			r0,a
	tst	a
	jeq	<_visible

; Return the invisibility.
_invisible:
	clr	a
	rts

_visible:
	move			x:>BoundingBox.rectangleCount,r0
	move			#>1,a
	move			(r0)+
	move			r0,x:>BoundingBox.rectangleCount
	rts

p_memory_end:

;======== X-Memory Code ========

	ORG	X:$0000

texturewidth:
	DS	1						; texture v width
u_scale:DS	1
u0:	DS	1
u0_step:DS	1						; u_step storage
u1:	DS	1
u1_step:DS	1						; u_step storage
colorshift:
	DC	$008000
alphashift:
	DC	$000100

texturesize:
	DS	1						; texture size

spaceometer:
	DC	Polygon.TEXTUREBUFFER_SIZE

SineX:	DS	1
CosineX:DS	1
SineY:	DS	1
CosineY:DS	1

;======== Matrix

Matrix.stackTop:
	DC	0

;======== TransformObject

TransformObject.vertexadr:
	DS	1

;======== Viewport

Viewport.settingsTable:
Viewport.XScreen:
	DS	1
Viewport.YScreen:
	DS	1
Viewport.XStart:
	DS	1
Viewport.XEnd:
	DS	1
Viewport.YStart:
	DS	1
Viewport.YEnd:
	DS	1
Viewport.XCenter:
	DS	1
Viewport.YCenter:
	DS	1
Viewport.Focal:
	DS	1
Viewport.Aspect:
	DS	1						; 8:8 Y scale
Viewport.settingsTableEnd:

;======== Polygon

Polygon.points:
	DS	1
Polygon.vsize:
	DS	1
Polygon.z:
	DS	1
Polygon.clipFlags:
	DS	1
Polygon.height:
	DS	1
Polygon.top:
	DS	1
Polygon.shadeType:
	DS	1
Polygon.textureNumber:
	DS	1
Polygon.sendPixelInstruction:
	movep	y:(r4+n4),x:<<HTX				; Send texturepixel.
Polygon.sendOffsetInstruction:
	move			b,x:(r3)	a,y1		; Send textureoffset.
Polygon.polygonTable:
	DS	(12+1)*6					; max 12 points (x,y,u0,v0,u1,v1)
Polygon.polygonTable2:
	DS	(12+1)*6					; max 12 points (x,y,u0,v0,u1,v1)

;======== EXTERNAL X RAM

;======== PrimitiveMesh

PrimitiveMesh.shadowOn:
	DS	1
PrimitiveMesh.nextVertex:
	DS	1
PrimitiveMesh.baseHandle:
	DS	1
PrimitiveMesh.baseTable:
	DS	Object.MAX_OBJECTS				; space for transformed object pointers!
PrimitiveMesh.primitiveTable:
	DS	1
	DS	PrimitiveMesh.MAX_ELEMENTS*MeshElement.SIZE

;======== Object

Object.buffer:
	DS	Object.CAPACITY					; Maximum of 8192 words for all scene objects!
x_memory_end:
; X<$3000 !!

	ORG	X:$3BDB						; for mixer

;======== Object

Object.newHandleAddress:
	DS	1
Object.handleTable:
	DS	Object.MAX_OBJECTS
Object.handlesEnd:

;======== BoundingBox

BoundingBox.table:
	DS	Object.MAX_OBJECTS*BoundingBox.SIZE
BoundingBox.decoded:
	DS	8*3						; 8 points in decoded box
BoundingBox.rectangleCount:
	DS	1
BoundingBox.rectangles:
	DS	4*Object.MAX_OBJECTS

;======== Dispatcher

Dispatcher.commandTablePosition:
	DS	1
Dispatcher.commandTable:
	DS	Dispatcher.MAX_COMMANDS

Dispatcher.rpcTable:
	DC	Dispatcher.doNothing				; RPC_TRANSMISSION_END
	DC	Object.clear					; RPC_CLEAR_REGISTRY
	DC	Object.set					; RPC_REGISTER_OBJECT
	DC	PrimitiveMesh.new				; RPC_NEW_PRIMITIVEMESH
	DC	PrimitiveMesh.sort				; RPC_SORT_PRIMITIVEMESH
	DC	PrimitiveMesh.paint				; RPC_PAINT_PRIMITIVES
	DC	Matrix.convertRotation				; RPC_GENERATE_ROTMATRIX
	DC	Matrix.convertQuaternion			; RPC_GENERATE_QUATMATRIX
	DC	Matrix.push					; RPC_PUSH_MATRIX
	DC	Matrix.pop					; RPC_POP_MATRIX
	DC	Matrix.rpcTranslate				; RPC_TRANSLATE_MATRIX
	DC	TransformObject.rpcTransform			; RPC_TRANSFORM_OBJECT
	DC	Polygon.storeTexture				; RPC_STORE_TEXTURE
	DC	Polygon.setPixelMode				; RPC_SET_TEXTUREPIXEL
	DC	Polygon.setOffsetMode				; RPC_SET_OFFSETPIXEL
	DC	Polygon.paint					; RPC_PAINT_POLYGON
	DC	Viewport.update					; RPC_UPDATE_VIEWPORT
	DC	Polygon.setV4AlphaMode				; RPC_SET_V4ALPHA
	DC	Polygon.setV4BumpMode				; RPC_SET_V4BUMP
	DC	Polygon.paintReceivedClipped			; RPC_CLIPPAINT_POLYGON
	DC	Object.replace					; RPC_REPLACE_OBJECT

Dispatcher.storedRpcTable:
	DC	Dispatcher.doNothing				; RPC_TRANSMISSION_END
	DC	Object.clear					; RPC_CLEAR_REGISTRY
	DC	Object.set					; RPC_REGISTER_OBJECT
	DC	PrimitiveMesh.new				; RPC_NEW_PRIMITIVEMESH
	DC	PrimitiveMesh.sort				; RPC_SORT_PRIMITIVEMESH
	DC	PrimitiveMesh.paint				; RPC_PAINT_PRIMITIVES
	DC	Matrix.convertStoredRotation			; RPC_GENERATE_ROTMATRIX
	DC	Matrix.convertStoredQuaternion			; RPC_GENERATE_QUATMATRIX
	DC	Matrix.push					; RPC_PUSH_MATRIX
	DC	Matrix.pop					; RPC_POP_MATRIX
	DC	Matrix.translateStored				; RPC_TRANSLATE_MATRIX
	DC	TransformObject.transformStored			; RPC_TRANSFORM_OBJECT
	DC	Polygon.storeTexture				; RPC_STORE_TEXTURE
	DC	Polygon.setPixelMode				; RPC_SET_TEXTUREPIXEL
	DC	Polygon.setOffsetMode				; RPC_SET_OFFSETPIXEL
	DC	Polygon.paint					; RPC_PAINT_POLYGON
	DC	Viewport.update					; RPC_UPDATE_VIEWPORT
	DC	Polygon.setV4AlphaMode				; RPC_SET_V4ALPHA
	DC	Polygon.setV4BumpMode				; RPC_SET_V4BUMP
	DC	Polygon.paintReceivedClipped			; RPC_CLIPPAINT_POLYGON
	DC	Object.replace					; RPC_REPLACE_OBJECT

; -1 indicates synchronous commandmode.
Dispatcher.commandSizeTable:
	DC	0						; RPC_TRANSMISSION_END
	DC	-1						; RPC_CLEAR_REGISTRY
	DC	-1						; RPC_REGISTER_OBJECT
	DC	1						; RPC_NEW_PRIMITIVEMESH
	DC	0						; RPC_SORT_PRIMITIVEMESH
	DC	0						; RPC_PAINT_PRIMITIVES
	DC	6						; RPC_GENERATE_ROTMATRIX
	DC	4						; RPC_GENERATE_QUATMATRIX
	DC	0						; RPC_PUSH_MATRIX
	DC	0						; RPC_POP_MATRIX
	DC	3						; RPC_TRANSLATE_MATRIX
	DC	1						; RPC_TRANSFORM_OBJECT
	DC	-1						; RPC_STORE_TEXTURE
	DC	-1						; RPC_SET_TEXTUREPIXEL
	DC	-1						; RPC_SET_OFFSETPIXEL
	DC	-1						; RPC_PAINT_POLYGON
	DC	-1						; RPC_UPDATE_VIEWPORT
	DC	0						; RPC_SET_V4ALPHA
	DC	0						; RPC_SET_V4BUMP
	DC	-1						; RPC_CLIPPAINT_POLYGON
	DC	-1						; RPC_REPLACE_OBJECT

;======== Y-Memory Code ========

	ORG	Y:$0000

texturemask:
	DS	1						; v_frag mask
v_scale:DS	1
v0:	DS	1
v0_step:DS	1						; v_step storage
v1:	DS	1
v1_step:DS	1						; v_step storage
colormask:
	DC	$00ff00
Polygon.v4RoutineAddress:
	DS	1

next_texture:
	DC	Polygon.texture

SineZ:	DS	1
CosineZ:DS	1

;======== PrimitiveMesh

PrimitiveMesh.primitive:
	DS	1

;======== Matrix

Matrix.temp:
	DS	Matrix.SIZE
Matrix.stack:
	DS	Matrix.SIZE*Matrix.MAX_DEPTH			; stack containing multi rotation

;======== BoundingBox

BoundingBox.transformed:
	DS	8*3

;======== EXTERNAL Y RAM

	ORG	Y:p_memory_end					; out of range from p-code

;======== Polygon

Polygon.texture:
	DS	Polygon.TEXTUREBUFFER_SIZE			; room for the interleaved textures
Polygon.LeftEdge:
	DS	5*Viewport.MAX_Y				; (x,u0,v0,u1,v1)
Polygon.RightEdge:
	DS	5*Viewport.MAX_Y

;======== PrimitiveMesh

InverseTable:
	DS	INVBUF_SIZE
PrimitiveMesh.vertexTable:
	DS	PrimitiveMesh.MAX_VERTICES*Vertex.SIZE		; room for the transformed vertices
y_memory_end:
; Y<$3BF2 !!

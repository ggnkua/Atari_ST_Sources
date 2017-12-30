*==========================================================================*
*                                                      .                   *
*                       .    .   !       '       .                         *
*                        \.  ' ! | | '   | !   ' |   /                     *
*                         \\=|=|=|=|=|=|=|=|=|=|=|=//                      *
*                          \\ >>> HUMAN - FLY <<< //                       *
*                          // Falcon030 3D engine \\                       *
*                         //=|=|=|=|=|=|=|=|=|=|=|=\\                      *
*                        /   . | !   ! |   ' | !    '                      *
*                       '    ' ! '   ' !     ! '      '                    *
*                      /                                                   *
*                                  <v2.1>                                  *
*         3D world engine and rendering pipeline for ATARI Falcon          *
*==========================================================================*
*                            CPU CORE ROUTINES                             *
*                                                                          *
* This contains no implementation specific routines, such as primitive     *
* painters, dsp comms. or fpu code.                                        *
* Only the core doing all the high parts of the pipeline.                  *
* In order to use Human Fly, all interfaces defined here must be           *
* implemented.                                                             *
*--------------------------------------------------------------------------*
* All interfaces are finalized. Objects implementing these interfaces      *
* should not deviate from them.                                            *
* Finalized objects: (already implemented here!)                           *
* - KeyFramer                                                              *
* - MeshElement                                                            *
* - Primitive                                                              *
* - Quaternion                                                             *
* - QuatKey                                                                *
* - QuatKeyEntry                                                           *
* - QuatKeyBuf                                                             *
* - Vertex                                                                 *
* - Vertex2d                                                               *
* - VertexKey                                                              *
* - VertexKeyEntry                                                         *
* - VertexKeyBuf                                                           *
* - WorldNode                                                              *
* - WorldTree                                                              *
* Objects/subroutines outside core, _must_ be implemented:                 *
* - Line:                                                                  *
*   .paint                                                                 *
*   .paintFlat                                                             *
*   .paintGouraud                                                          *
*   .paintPhong                                                            *
* - Matrix:                                                                *
*   .convertQuaternion                                                     *
*   .generate                                                              *
*   .pop                                                                   *
*   .push                                                                  *
* - ObjectRegistry:                                                        *
*   .set                                                                   *
*   .clear                                                                 *
*   .replace                                                               *
* - Polygon:                                                               *
*   .init                                                                  *
*   .paintFlat                                                             *
*   .paintGouraudshaded                                                    *
*   .paintTextured                                                         *
*   .paintAlphatextured                                                    *
*   .paintBumpmapped                                                       *
*   .paintClippedFlat                                                      *
*   .paintClippedGouraudshaded                                             *
*   .paintClippedTextured                                                  *
*   .paintClippedAlphatextured                                             *
*   .paintClippedBumpmapped                                                *
*   .registerBumpmap                                                       *
* - Primitive:                                                             *
*   .setPaintMode                                                          *
*   .setScreenbuffer                                                       *
* - PrimitiveMesh:                                                         *
*   .new:                                                                  *
*   .sortZ:                                                                *
*   .paint:                                                                *
*   .paintUnclipped:                                                       *
* - Sprite:                                                                *
*   .clipAndPaint                                                          *
* - TransformObject:                                                       *
*   .transform                                                             *
* - Viewport:                                                              *
*   .paintRectangle                                                        *
*   .update                                                                *
*==========================================================================*

******** GLOBAL MACROS ********

******** HumanFly

HumanFly:

* Initialises global parts of the pipeline.
;HumanFly.init:

******** Rectangle

		RSRESET
Rectangle.Y0:	RS.W	1
Rectangle.Y1:	RS.W	1
Rectangle.X0:	RS.W	1
Rectangle.X1:	RS.W	1
Rectangle.SIZE:	RS.B	0

******** WorldNode

			RSRESET
WorldNode.OBJECTADR:	RS.L	1
WorldNode.MATRIXADR:	RS.L	1
WorldNode.ARRAYADR:	RS.L	1
WorldNode.SIZE:		RS.B	0

* Creates a new node with the specified parameters.
WorldNode_new:	MACRO	NodeAdr,ObjectAdr,ArrayAdr
	move.l	\1,a0
	move.l	\2,WorldNode.OBJECTADR(a0)
	move.l	\3,WorldNode.ARRAYADR(a0)
	movea.l	WorldNode.ARRAYADR(a0),a0
	clr.w	(a0)
	ENDM

* Returns the number of children this node has.
* INPUT: NodeAdr: node
* OUTPUT: d0.w: number of children
WorldNode_getChildCount:	MACRO	NodeAdr
	movea.l	\1,a0
	movea.l	WorldNode.ARRAYADR(a0),a0
	move.w	(a0),d0
	ENDM

* Returns a child of node. No boundscheck is done.
* INPUT: NodeAdr: node
*        ChildIndex: index of child
* OUTPUT: a0: child node
WorldNode_getChild:	MACRO	NodeAdr,ChildIndex
	movea.l	\1,a0
	movea.l	WorldNode.ARRAYADR(a0),a0
	move.w	ChildIndex,d0
	movea.l	2(a0,d0.w*4),a0
	ENDM

* Adds a child to node.
* INPUT: ParentAdr: worldnode to add child to
*        ChildAdr: child to add
WorldNode_addChild:	MACRO	ParentAdr,ChildAdr
	movea.l	WorldNode.ARRAYADR(\1),a0
	move.w	(a0),d0
	addq.w	#1,(a0)+
	move.l	\2,(a0,d0.w*4)
	ENDM	

* Removes child from node. No boundscheck is done.
* INPUT: NodeAdr: node to remove child from
*        ChildIndex: index of child
WorldNode_removeChild:	MACRO	NodeAdr,ChildIndex
	movea.l	WorldNode.ARRAYADR(\1),a0
	move.w	\2,d0
	move.w	(a0),d1
	beq.s	@\end
	subq.w	#1,(a0)+
	lea	(a0,d0.w*4),a0
 	lea	4(a0),a1
	sub.w	d0,d1
	subq.w	#1,d1
	bmi.s	@\end
@\loop:	move.l	(a1)+,(a0)+
	dbra	d1,@\loop
@\end:
	ENDM

******** ObjectRegistry

ObjectRegistry.VERTICES:=	%001
ObjectRegistry.NORMALS:	=	%010
ObjectRegistry.TEXELS:	=	%100

; TODO: maximum amount of objects!!
; Adds a 3d-object to the registry and returns a handle.
; INPUT:
; d0.l=size of object (bytes)
; a0: object
; OUTPUT:
; d0.w: >= 0: objecthandle, -1: error, not added!
;ObjectRegistry.set:

; Returns the objectaddress of the specified handle.
; No checking for invalid handles!!
; INPUT:
; d0.w=ObjectHandle
; OUTPUT:
; a0: object
;ObjectRegistry.get:

; Clears the registry. All handles become invalid.
;ObjectRegistry.clear:

; Updates specified object's primitives/vertices/normals/texels.
; INPUT:
; d0.w=objecthandle
; d1.w=replacemode (%ptnv)
;ObjectRegistry.replace:

******** Vertex

		RSRESET
Vertex.X:	RS.W	1
Vertex.Y:	RS.W	1
Vertex.Z:	RS.W	1
Vertex.SIZE:	RS.B	0

******** Vertex2d

		RSRESET
Vertex2d.X:	RS.W	1			* 8:8 fixed point
Vertex2d.Y:	RS.W	1			* 8:8 fixed point
Vertex2d.SIZE:	RS.B	0

******** Primitive

; Equates involving paintmodes.
Primitive.SIZEMASK:	=	%00011
Primitive.BYTE:		=	%00000
Primitive.WORD:		=	%00001
Primitive.24B:		=	%00010
Primitive.LONG:		=	%00011
Primitive.LOGICMASK:	=	%11100
Primitive.LOGICSHIFT:	=	2
Primitive.MOVE:		=	%00000
Primitive.OR:		=	%00100
Primitive.ADD:		=	%01000		; plain add
Primitive.CEILADD:	=	%01100		; add with ceiling for r,g,b

; Equates for palette handling.
Primitive.GRADIENTBITS:	=	7
Primitive.GRADIENTSIZE:	=	1<<(Primitive.GRADIENTBITS+1)

			RSRESET
Primitive.TYPE:		RS.W	1		; primitive/shading/extended type

			RSRESET
			RS.W	1		; primitive/shading/extended type
Sprite.VERTEX:		RS.W	1		; offset to vertex
Sprite.SIZE:		RS.B	0

			RSRESET
			RS.W	1		; primitive/shading/extended type
Line.VERTEX1:		RS.W	1		; offset to vertex 1
Line.VERTEX2:		RS.W	1		; offset to vertex 2
Line.SIZE:		RS.B	0

Primitive.SHADEMASK:	=	%1110000000000000
Primitive.SHADESHIFT:	=	13

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
Primitive.SPRITETYPE:	=	%0000000000000000
Primitive.LINETYPE:	=	%0000010000000000
; Other types are polygons, %10 :== triangle, %11 :== quadrangle, etc.

; TableLookup mask
Primitive.TEXTUREMASK:	=	%0000001111111111

; Standard Polygon types
Polygon.TRI:		=	(3-1)<<Primitive.TYPESHIFT
Polygon.QUAD:		=	(4-1)<<Primitive.TYPESHIFT
Polygon.PENT:		=	(5-1)<<Primitive.TYPESHIFT
Polygon.HEX:		=	(6-1)<<Primitive.TYPESHIFT

; Sets paintmode. This involves pixeltype, logic op, pixelskip. For
; discription of these, see paintmode equates.
; All primitives use the settings taken by this call.
; INPUT:
; d0.w=pixeltype and logic op
; d1.w=pixelskip (number of bytes to progress after each pixel)
; OUTPUT:
; d0.w: =0: success, <0: error
;Primitive.setPaintMode:

********* PolyPoint

		RSRESET
PolyPoint.X:	RS.W	1
PolyPoint.Y:	RS.W	1
PolyPoint.U1:	RS.W	1
PolyPoint.V1:	RS.W	1
PolyPoint.U2:	RS.W	1
PolyPoint.V2:	RS.W	1
PolyPoint.SIZE:	RS.B	0

********* MeshElement

			RSRESET
MeshElement.BASE:	RS.L	1			* startaddress of vertex table
MeshElement.REF:	RS.L	1			* address of primitive
MeshElement.Z:		RS.W	1			* avg. Z coordinate of primitive
MeshElement.SIZE:	RS.B	0

******** KeyFramer

			RSRESET
QuatKey.X:		RS.W	1
QuatKey.GX:		RS.W	1
QuatKey.Y:		RS.W	1
QuatKey.GY:		RS.W	1
QuatKey.Z:		RS.W	1
QuatKey.GZ:		RS.W	1
QuatKey.LOOKAT_X:	RS.W	1
QuatKey.GLOOKAT_X:	RS.W	1
QuatKey.LOOKAT_Y:	RS.W	1
QuatKey.GLOOKAT_Y:	RS.W	1
QuatKey.LOOKAT_Z:	RS.W	1
QuatKey.GLOOKAT_Z:	RS.W	1
QuatKey.LOOKAT_R:	RS.W	1
QuatKey.GLOOKAT_R:	RS.W	1
QuatKey.SIZE:		RS.B	0

			RSRESET
QuatKeyEntry.POS:	RS.B	QuatKey.SIZE
QuatKeyEntry.TIME:	RS.L	1
QuatKeyEntry.SIZE:	RS.B	0

			RSRESET
QuatKeyBuf.KEYNUM:	RS.W	1
QuatKeyBuf.STEPMATRIX:	RS.B	QuatKey.SIZE*2
QuatKeyBuf.BASEMATRIX:	RS.B	QuatKey.SIZE*2
QuatKeyBuf.SIZE:	RS.B	0

* Calculates the objects position from the trajectory (keyframe) table.
* INPUT:
* a0: destination quaternion
* a1: object's keyframe buffer
* a2: trajectory table
* a3: address of start time (long)
Keyframer.InterpolateQuaternion:
	move.l	a0,-(sp)
	pea	QuatKeyBuf.BASEMATRIX(a1)

.get_entry:
	move.w	(a2)+,d5
	move.w	QuatKeyBuf.KEYNUM(a1),d0
	move.l	$4ba.w,d1
	move.l	(a3),d2
	sub.l	d2,d1
	tst.w	d0
	bpl.s	.not_first_entry
	addq.w	#1,d0
	move.l	QuatKeyEntry.TIME(a2),d3
	cmp.l	d3,d1
	blt.s	.init_spline
	bra.s	.get_entry_loop
.not_first_entry:
	move.w	d0,d4
	mulu.w	#QuatKeyEntry.SIZE,d4
	move.l	QuatKeyEntry.TIME(a2,d4.l),d3
	cmp.l	d3,d1
	blt.s	.end_get_entry

.get_entry_loop:
	add.l	d3,d2
	sub.l	d3,d1
	ext.l	d0
	addq.w	#1,d0
	divu.w	d5,d0
	swap	d0
	move.w	d0,d4
	mulu.w	#QuatKeyEntry.SIZE,d4
	move.l	QuatKeyEntry.TIME(a2,d4.l),d3
	cmp.l	d3,d1
	bge.s	.get_entry_loop

	move.l	d2,(a3)

.init_spline:
	move.l	d3,-(sp)
	move.w	d1,-(sp)
	move.w	d0,QuatKeyBuf.KEYNUM(a1)
	move.w	d0,d4
	addq.w	#1,d4
	ext.l	d4
	divu.w	d5,d4
	swap	d4
	lea	QuatKeyBuf.STEPMATRIX(a1),a0
	mulu.w	#QuatKeyEntry.SIZE,d0
	mulu.w	#QuatKeyEntry.SIZE,d4
	lea	(a2,d4.l),a3
	lea	(a2,d0.l),a2
	moveq	#QuatKey.SIZE/2-1,d7
.fill_matrix_loop:
	move.w	(a2)+,(a0)+				* Copy start data.
	move.w	(a3)+,(a0)+				* Copy end data.
	dbra	d7,.fill_matrix_loop
	lea	QuatKeyBuf.STEPMATRIX(a1),a0
	lea	QuatKeyBuf.BASEMATRIX(a1),a1
	moveq	#QuatKey.SIZE/4,d0
	bsr	Spline.init
	move.w	(sp)+,d1
	move.l	(sp)+,d3
.end_init_spline:

.end_get_entry:

	movea.l	(sp)+,a0
	movea.l	(sp)+,a1

.calc_spline_position:
	move.l	#$7fff,d2
	divu.w	d3,d2
	mulu.w	d2,d1
	move.w	d1,d0
	moveq	#QuatKey.SIZE/4,d1
	bsr	Spline.calculate
.end_calc_spline_position:
	rts

			RSRESET
VertexKey.X:		RS.W	1
VertexKey.GX:		RS.W	1
VertexKey.Y:		RS.W	1
VertexKey.GY:		RS.W	1
VertexKey.Z:		RS.W	1
VertexKey.GZ:		RS.W	1
VertexKey.RX:		RS.W	1
VertexKey.GRX:		RS.W	1
VertexKey.RY:		RS.W	1
VertexKey.GRY:		RS.W	1
VertexKey.RZ:		RS.W	1
VertexKey.GRZ:		RS.W	1
VertexKey.SIZE:		RS.B	0

			RSRESET
VertexKeyEntry.POS:	RS.B	VertexKey.SIZE
VertexKeyEntry.TIME:	RS.L	1
VertexKeyEntry.SIZE:	RS.B	0

				RSRESET
VertexKeyBuf.KEYNUM:		RS.W	1
VertexKeyBuf.STEPMATRIX:	RS.B	VertexKey.SIZE*2
VertexKeyBuf.BASEMATRIX:	RS.B	VertexKey.SIZE*2
VertexKeyBuf.SIZE:		RS.B	0

* Calculates the objects position from the trajectory (keyframe) table.
* INPUT:
* a0: destination vertex
* a1: object's keyframe buffer
* a2: trajectory table
* a3: address of start time (long)
Keyframer.interpolateVertex:
	move.l	a0,-(sp)
	pea	VertexKeyBuf.BASEMATRIX(a1)

.get_entry:
	move.w	(a2)+,d5
	move.w	VertexKeyBuf.KEYNUM(a1),d0
	move.l	$4ba.w,d1
	move.l	(a3),d2
	sub.l	d2,d1
	tst.w	d0
	bpl.s	.not_first_entry
	addq.w	#1,d0
	move.l	VertexKeyEntry.TIME(a2),d3
	cmp.l	d3,d1
	blt.s	.init_spline
	bra.s	.get_entry_loop
.not_first_entry:
	move.w	d0,d4
	mulu.w	#VertexKeyEntry.SIZE,d4
	move.l	VertexKeyEntry.TIME(a2,d4.l),d3
	cmp.l	d3,d1
	blt.s	.end_get_entry

.get_entry_loop:
	add.l	d3,d2
	sub.l	d3,d1
	ext.l	d0
	addq.w	#1,d0
	divu.w	d5,d0
	swap	d0
	move.w	d0,d4
	mulu.w	#VertexKeyEntry.SIZE,d4
	move.l	VertexKeyEntry.TIME(a2,d4.l),d3
	cmp.l	d3,d1
	bge.s	.get_entry_loop

	move.l	d2,(a3)

.init_spline:
	move.l	d3,-(sp)
	move.w	d1,-(sp)
	move.w	d0,VertexKeyBuf.KEYNUM(a1)
	move.w	d0,d4
	addq.w	#1,d4
	ext.l	d4
	divu.w	d5,d4
	swap	d4
	lea	VertexKeyBuf.STEPMATRIX(a1),a0
	mulu.w	#VertexKeyEntry.SIZE,d0
	mulu.w	#VertexKeyEntry.SIZE,d4
	lea	(a2,d4.l),a3
	lea	(a2,d0.l),a2
	moveq	#VertexKey.SIZE/2-1,d7
.fill_matrix_loop:
	move.w	(a2)+,(a0)+				* Copy start data.
	move.w	(a3)+,(a0)+				* Copy end data.
	dbra	d7,.fill_matrix_loop
	lea	VertexKeyBuf.STEPMATRIX(a1),a0
	lea	VertexKeyBuf.BASEMATRIX(a1),a1
	moveq	#VertexKey.SIZE/4,d0
	bsr	Spline.init
	move.w	(sp)+,d1
	move.l	(sp)+,d3
.end_init_spline:

.end_get_entry:

	movea.l	(sp)+,a0
	movea.l	(sp)+,a1

.calc_spline_position:
	move.l	#$7fff,d2
	divu.w	d3,d2
	mulu.w	d2,d1
	move.w	d1,d0
	moveq	#VertexKey.SIZE/4,d1
	bsr	Spline.calculate
.end_calc_spline_position:
	rts

********* Matrix

		RSRESET
Matrix.XX:	RS.W	1
Matrix.XY:	RS.W	1
Matrix.XZ:	RS.W	1
Matrix.YX:	RS.W	1
Matrix.YY:	RS.W	1
Matrix.YZ:	RS.W	1
Matrix.ZX:	RS.W	1
Matrix.ZY:	RS.W	1
Matrix.ZZ:	RS.W	1
Matrix.TX:	RS.L	1
Matrix.TY:	RS.L	1
Matrix.TZ:	RS.L	1
Matrix.SIZE:	RS.B	0

		RSRESET
Quaternion.ORG_X:	RS.W	1
Quaternion.ORG_Y:	RS.W	1
Quaternion.ORG_Z:	RS.W	1
Quaternion.LOOK_X:	RS.W	1
Quaternion.LOOK_Y:	RS.W	1
Quaternion.LOOK_Z:	RS.W	1
;Quaternion.UP_X:	RS.W	1
;Quaternion.UP_Y:	RS.W	1
;Quaternion.UP_Z:	RS.W	1
Quaternion.ROLL:	RS.W	1
Quaternion.SIZE:	RS.B	0

* Calculates a hermite basis matrix.
* Our input matrix is a set of 4 points, each with 'n' dimensions.
* We therefore have a n x 4 matrix (width n, height 4).
* i.e.  [ a1 b1  ... ]
*       [ a2 b2      ]
*       [ a3 b3      ]
*       [ a4 b4      ]
* This is multiplied by the matrix ( 2 -2  1  1)
*                                  (-3  3 -2 -1)
*                                  ( 0  0  1  0)
*                                  ( 1  0  0  0) to give our ouput mtrx
* i.e. the first column is multiplied by 2,-2,1,1
* then -3,3,-2,-1 for the next value 
*
* INPUT: d0.w: number of columns
*        a0: input matrix (in "downwards" format)
*        a1: output matrix
Spline.init:
	lea	.matrix_tbl(pc),a2
	move.w	d0,d7				* Save the no of rows.
	subq.w	#1,d7
	movea.l	a0,a4
.row_loop:
	moveq	#4-1,d6
	movea.l	a2,a6				* a6: address of current input matrix

.column_loop:
	movea.l	a4,a5				* a5: address of current input row
* Now multiply this by our column:
	move.w	(a5)+,d0
	muls.w	(a6)+,d0
	move.w	(a5)+,d1
	muls.w	(a6)+,d1
	add.l	d1,d0
	move.w	(a5)+,d1
	muls.w	(a6)+,d1
	add.l	d1,d0
	move.w	(a5)+,d1
	muls.w	(a6)+,d1
	add.l	d1,d0
	move.w	d0,(a1)+			* Output the column.
* Move on to the next column:
	dbra	d6,.column_loop

* We have done each column, so move on to the next row of input
	addq	#4*2,a0
	movea.l	a0,a4
	dbra	d7,.row_loop
	rts

* The base matrix used
.matrix_tbl:
	DC.W	+2,-2,+1,+1
	DC.W	-3,+3,-2,-1
	DC.W	+0,+0,+1,+0
	DC.W	+1,+0,+0,+0

* Calculate a single point on the curve, given the basis matrix.
* INPUT: d0.w: value of "t" ($0000 t=0,  $7fff t=1)
*        d1.w: no. of columns
*        a0: basis matrix
*        a1: output matrix
Spline.calculate:
* First calculate our values of "t" and store in registers.
	ext.l	d0
	move.w	d1,d7		* counter
	move.w	d0,d1		* d0 = t
	muls.w	d1,d1
	add.l	d1,d1
	swap	d1		* d1 = t*t
	move.w	d1,d2
	muls.w	d0,d2		* d2 = t*t*t
	add.l	d2,d2
	swap	d2

* Now calculate "d7" values.
	subq.w	#1,d7
.calcloop:
	move.w	(a0)+,d6	* t*t*t term
	muls.w	d2,d6
	move.w	(a0)+,d5	* t*t term
	muls.w	d1,d5
	add.l	d5,d6
	move.w	(a0)+,d5	* t term
	muls.w	d0,d5
	add.l	d5,d6
	add.l	d6,d6
	swap	d6
	add.w	(a0)+,d6	* 1 term
	move.w	d6,(a1)+
	dbra	d7,.calcloop
	rts

******** Matrix

* Initializes the matrix, to enable generation of rotationmatrices,
* multiplications, translations and conversion of quaternions.
* INPUT: a1: address of sin/cos table
Matrix.init:
	lea	Matrix.sineTable,a0
	move.w	#sintbllen-1,d7
.loop:	move.l	(a1)+,(a0)+
	dbra	d7,.loop

	lea	Matrix.sineTable,a0
	move.w	#$8000,d0
	move.w	#sintbllen*2-1,d7
.adjustloop:
	cmp.w	(a0)+,d0
	bne.s	.no_adjust
	addq.w	#1,-2(a0)
.no_adjust:
	dbra	d7,.adjustloop
	rts

* Pushes a previously generated matrix on the stack.
;Matrix.push:

* Pops the top matrix off the stack.
;Matrix.pop:

* Generates a matrix out of a 3D vertex with it's X,Y,Z rotation.
* INPUT:
* a1: source vertex
Matrix.convertRotationVertex:
	move.l	a1,-(sp)
	movem.w	6(a1),d0-d2
	bsr	Matrix.generate
	movea.l	(sp)+,a1
	movem.w	(a1),d0-d2
	bsr	Matrix.translate
	rts

* Generates a matrix from a quaternion.
* This uses the roll.
*
* O = observer position (camera)
* A = aimpoint position (focus)
* R = direction point position (up)
* 
* N = normalize (Ax - Ox, Ay - Oy, Az - Oz)
* D = normalize (Rx - Ox, Ry - Oy, Rz - Oz)
* V = D - (D . N) * N
* U = V x N
*
*               | Ux Uy Uz |
* View Matrix = | Vx Vy Vz |
*               | Nx Ny Nz |
*
* a = angle for camera Z-panning (roll)
* D = [sin(a), cos(a), 0]
* INPUT: a0: destination matrix
*        a1: source quaternion
;Matrix.convertQuaternion:

* Seems to work ok, since there has been some patching on the overflow
* errors (caused by combination of finite accuracy and use of maximum range).
* INPUT: d0.w: X rotation (a)
*        d1.w: Y rotation (b)
*        d2.w: Z rotation (c)
*        a0: matrix table to output to
;Matrix.generate:

* Bad implementation.. Needs to be altered in order to work correctly
* with normals.
* INPUT: d0.w: X factor (-1.0 ... 1.0)
*        d1.w: Y factor (-1.0 ... 1.0)
*        d2.w: Z factor (-1.0 ... 1.0)
;Matrix.scaleMatrix:

******** TransformObject

TransformObject.BACKFACE_CULLING:	=	$00000001
TransformObject.PERSPECTIVATE:		=	$00000002
TransformObject.ROTATE_NORMALS:		=	1			* Enable/Disable rotation of normalvectors.

* INPUT: d0.l: flags
*        d1.w: original objecthandle
* Rotates & scales & translates object by it's matrix.
;TransformObject.transform:

******** Vertex

* Perform a linear morph between 3d vertices.
* INPUT: d0.w: 0-32767 morph index
*        a0: destination vertices
*        a1: begin vertices
*        a2: end vertices
Vertex.morph:
	move.w	#32767,d3
	sub.w	d0,d3
	addq	#2,a2
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
	bmi.s	.end

.loop:	REPT	3
	move.w	(a1)+,d1
	move.w	(a2)+,d2
	muls.w	d3,d1
	muls.w	d0,d2
	add.l	d1,d2
	add.l	d2,d2
	swap	d2
	move.w	d2,(a0)+
	ENDR	
	dbra	d7,.loop

.end:	rts

******** Viewport

			RSRESET
Viewport.XSCREEN:	RS.W	1		* X dimension of screenbuffer
Viewport.YSCREEN:	RS.W	1		* Y dimension of screenbuffer
Viewport.XSTART:	RS.W	1		* X start within screen
Viewport.XEND:		RS.W	1		* X end within screen
Viewport.YSTART:	RS.W	1		* Y start within screen
Viewport.YEND:		RS.W	1		* Y end within screen
Viewport.XCENTER:	RS.W	1		* Y start within screen
Viewport.YCENTER:	RS.W	1		* Y end within screen
Viewport.FOCAL:		RS.W	1		* Focal length
Viewport.ASPECT:	RS.W	1		* 8:8 Y scale
Viewport.SIZE:		RS.B	0

* INPUT: d0.w: left x
*        d1.w: upper y
*        d6.w: right x
*        d7.w: lower y
*        d4.l: color (2 words)
;Viewport.paintRectangle:

* Updates the viewport settings. Transfers configuration to any objects who
* need to know.
* USES: Viewport.settingsTable
;Viewport.update:

******** Primitive

* INPUT:
* a0: address of screenbuffer
;Primitive.setScreenbuffer:

******** Polygon

Polygon.USE_BLITGOURAUD:	=	0
Polygon.USE_BLITTER:		=	0

******** PrimitiveMesh

PrimitiveMesh.MAX_VERTICES:	=	10000
PrimitiveMesh.MAX_PRIMITIVES:	=	10000

* Marks the PrimitiveMesh as ready to roll.
;PrimitiveMesh.new:

* Sort the elements using radixsort.
;PrimitiveMesh.sortZ:

* INPUT:
* a0: destination rectangle table
;PrimitiveMesh.paint:

* Beware! No clipping on Polygons!!!!!!! Use this only when absolutely sure
* all polygons are within the viewport range.
* INPUT:
* a0: destination rectangle table
;PrimitiveMesh.paintUnclipped:

******** Polygon

* Initializes polygonpainter lookup tables.
* INPUT:
* a0: texture-address-table
* a1: gouraud-tables
* OUTPUT:
* d0.l: 0=ok, -1=error
;Polygon.init:

* Paints a flatshaded polygon. Must be within viewport!
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, x1.w, y1.w, x2.w, y2.w....)
;Polygon.paintFlatshaded:

* Paints a gouraudshaded polygon. Must be within viewport!
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, u0.w....)
;Polygon.paintGouraudshaded:

* Paints a textured polygon. Must be within viewport!
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, u0.w, v0.w....)
;Polygon.paintTextured:

* Paints a alphatextured polygon. Must be within viewport!
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, u0.w, v0.w, u1.w, v1.w....)
;Polygon.paintAlphatextured:

* Paints a bumpmapped polygon. Must be within viewport!
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, u0.w, v0.w, u1.w, v1.w....)
;Polygon.paintBumpmapped:

* Paints a flatshaded polygon.
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, x1.w, y1.w, x2.w, y2.w....)
;Polygon.paintClippedFlatshaded:

* Paints a gouraudshaded polygon.
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, u0.w....)
;Polygon.paintClippedGouraudshaded:

* Paints a textured polygon.
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, u0.w, v0.w....)
;Polygon.paintClippedTextured:

* Paints a alphatextured polygon.
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, u0.w, v0.w, u1.w, v1.w....)
;Polygon.paintClippedAlphatextured:

* Paints a bumpmapped polygon.
* INPUT:
* a1: polygon (texture.w, numofpoints.w, x0.w, y0.w, u0.w, v0.w, u1.w, v1.w....)
;Polygon.paintClippedBumpmapped:

* INPUT:
* a1: sprite structure
* a2: vertex table
;Sprite.paint:

* INPUT:
* a1: line structure
* a2: vertex table
;Line.paint:

******** WorldTree

* OUTPUT: a0: rootnode of tree
WorldTree_GetRootNode:	MACRO
	movea.l	WorldTree.rootNode,a0
	ENDM

* INPUT: RootNode: address of rootnode
WorldTree_SetRootNode:	MACRO	RootNode
	clr.l	WorldTree.matrixStack
	move.l	\1,WorldTree.rootNode
	ENDM

* Traverse the worldtree and execute the specified routine for every node.
* INPUT: RoutineAdr: routine to execute
WorldTree_TraverseTree:	MACRO
	bsr	WT_TRAVERSE_TREE
	ENDM

* Not working yet.. Let's do this baby in version 3 shall we?
* Routine traverses through the world tree and executes a routine for every
* node.
WT_TRAVERSE_TREE:
	WorldTree_GetRootNode
	bsr.s	.push_matrix
	bsr.s	.traverse_tree
	rts

* Recursive subroutine.
* INPUT: a0: address of node to traverse
.traverse_tree:
	movea.l	WorldNode.ARRAYADR(a0),a2
	tst.l	a2
	beq.s	.is_leaf
	move.w	(a2),-(sp)			* Push number of children on stack.

.nextnodeloop
	move.l	a0,-(sp)
	movea.l	WorldNode.ARRAYADR(a0),a0
	move.w	4(sp),d0
	subq.w	#1,d0
	movea.l	2(a0,d0.w*4),a0
	bsr.s	.push_matrix
	bsr.s	.traverse_tree
	movea.l	(sp)+,a0
	subq.w	#1,(sp)
	bgt.s	.nextnodeloop
.children_done:

	addq	#2,sp				* Pop number of children off stack.
	bsr.s	.pop_matrix
	rts
.is_leaf:
* TODO: Execute matrixstack on a new transformobject.
* final matrix := 3rd outer * 2nd outer * outer
* matrix := 2nd_outer * outer
* matrix := 3rd_outer * matrix
	move.l	WorldNode.MATRIXADR(a0),a0
;	bsr	Matrix.loadMatrix

.popstackloop:
;	bsr	Matrix.pop
;	lea	WorldTree.matrixStack,a1
;	adda.l	(a1)+,a1
;	bsr	Matrix.multiply
;	subi.l	#Matrix.SIZE,WorldTree.matrixStack
	bgt.s	.popstackloop

* TODO: Transform object here??????????

	addi.l	#Matrix.SIZE,WorldTree.matrixStack
	rts

* Routine that pushes the current node's matrix (rotation, scale & translation)
* onto the matrixstack.
* INPUT: a1: matrix
.push_matrix:
	movem.l	a0-a1,-(sp)

	lea	WorldTree.matrixStack,a0
	move.l	(a0),d0
	move.l	d0,d1
	addi.l	#Matrix.SIZE,d1
	move.l	d1,(a0)+
	moveq	#Matrix.SIZE/2-1,d7
.copyloop:
	move.w	(a1)+,(a0)+
	dbra	d7,.copyloop

	movem.l	(sp)+,a0-a1
	rts

* Routine that pops the top matrix off the matrixstack.
.pop_matrix:
	subi.l	#Matrix.SIZE,WorldTree.matrixStack
	rts

******** RESERVED SECTION ********

	BSS

******** Viewport

Viewport.settingsTable:
	DS.B	Viewport.SIZE

******** WorldTree

WorldTree.rootNode:
	DS.L	1				* address of rootnode
WorldTree.matrixStack:
	DS.L	1				* offset to top
	DS.W	1000

******** Matrix

Matrix.sineTable:
	DS.L	sintbllen

******** TransformObject 

TransformObject.2dvertexadr:			* address to 2d vertices array of object
	DS.L	1
TransformObject.vertexNum:			* number of vertices in object
	DS.W	1
TransformObject.primitiveNum:			* number of elements in object
	DS.W	1
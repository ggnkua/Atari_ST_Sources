* CPU ONLY implementation of the Human Fly engine 2.0.
* This is meant for 020 minimum CPU and highcolor memory mapped video.
* (That's a Falcon kids..)
* 
* This is implementation does not feature perspective-correction, but it
* has good linear shading on the polygons, i.e. no precalced step-tables.
* The latter would result in faster, but also less accurate routines.

	INCLUDE	HFLYCORE.S			* Include core routines.
	TEXT

HumanFly.init:
	rts

******** ObjectRegistry

ObjectRegistry.MAX_OBJECTS:	=	256

* Adds a 3d-object to the registry and returns a handle.
* This also initializes a boundingbox for the object.
* INPUT:
* a0: address of 3d object
* OUTPUT:
* d0.w: >= 0: objecthandle, -1: error, not added!
ObjectRegistry.set:
	lea	ObjectRegistry.regTable,a1
	move.w	(a1),d0
	cmpi.w	#ObjectRegistry.MAX_OBJECTS,d0
	bhs.s	.error
	move.w	d0,-(sp)
	addq.w	#1,(a1)+
	move.l	a0,(a1,d0.w*4)
	movea.l	a0,a1
	lea	ObjectRegistry.bbTable,a0
	mulu.w	#8*3*2,d0
	adda.l	d0,a0
	bsr	BoundingBox.init
	move.w	(sp)+,d0
	rts
.error:	moveq	#-1,d0
	rts

* Returns the objectaddress of the specified handle.
* No checking for invalid handles!!
* INPUT:
* d0.w: ObjectHandle
* OUTPUT:
* a0: ObjectAddress
ObjectRegistry.get:
	move.l	(ObjectRegistry.regTable+2,d0.w*4),a0
	rts

* Clears the registry. All handles become invalid.
ObjectRegistry.clear:
	clr.w	ObjectRegistry.regTable
	rts

******** Matrix

Matrix.MAX_DEPTH:	=	8

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
Matrix.convertQuaternion:
	movem.w	Quaternion.ORG_X(a1),a2-a4
	move.l	a2,d0
	move.l	a3,d1
	move.l	a4,d2
	swap	d0
	swap	d1
	swap	d2
	clr.w	d0
	clr.w	d1
	clr.w	d2
	movem.l	d0-d2,Matrix.TX(a0)
* N = normalize (Ax - Ox, Ay - Oy, Az - Oz)
	movem.w	Quaternion.LOOK_X(a1),d0-d2

;	sub.w	a2,d0
;	sub.w	a3,d1
;	sub.w	a4,d2
	movem.w	d0-d2,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	muls.w	d2,d2
	add.l	d0,d1
	add.l	d2,d1
	bsr	CALC_ATARISQRT
	swap	d0
	addq.w	#1,d0
	ext.l	d0

;	move.l	d0,d3
	move.l	#$7fffffff,d3
	divs.l	d0,d3

	movem.w	(sp)+,d0-d2

	muls.l	d3,d0
	muls.l	d3,d1
	muls.l	d3,d2
	swap	d0
	swap	d1
	swap	d2
;	swap	d0
;	clr.w	d0
;	swap	d1
;	clr.w	d1
;	swap	d2
;	clr.w	d2
;	divs.l	d3,d0
;	divs.l	d3,d1
;	divs.l	d3,d2
;	asr.l	#1,d0
;	asr.l	#1,d1
;	asr.l	#1,d2
	movem.w	d0-d2,Matrix.ZX(a0)

* D = normalize (Rx - Ox, Ry - Oy, Rz - Oz)
;	movem.w	quatUpX(a1),d3-d5
;	sub.l	a2,d3
;	sub.l	a3,d4
;	sub.l	a4,d5
;	muls.w	d3,d3
;	muls.w	d4,d4
;	muls.w	d5,d5
;	add.l	d3,d5
;	add.l	d4,d5
;	move.l	d5,d1
;	bsr	CALC_ATARISQRT
;	swap	d0
;	addq.w	#1,d0
;	ext.l	d0
;	move.l	#$7fff,d3
;	divs.w	d0,d3
;	movem.w	quatUpX(a1),d0-d2
;	muls.w	d3,d0
;	muls.w	d3,d1
;	muls.w	d3,d2

* D = [sin(roll), cos(roll), 0]
	move.w	Quaternion.ROLL(a1),d0
	Do_SinModulo	d0
	Get_SinCos	Matrix.sineTable,d0,d0,d1
	moveq	#0,d2

* V = D - (D . N) * N
	movem.w	Matrix.ZX(a0),d3-d5
	move.l	d0,d6
	move.l	d1,d7
	movea.l	d2,a2
	movea.l	d3,a3
	movea.l	d4,a4
	movea.l	d5,a5
* D . N <=> Dx*Nx + Dy*Ny + Dz*Nz
	muls.w	d0,d3
	muls.w	d1,d4
	muls.w	d2,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
* - (D . N) * N
	swap	d5
	neg.w	d5
	muls.w	d5,d0
	muls.w	d5,d1
	muls.w	d5,d2
	add.l	d0,d0
	add.l	d1,d1
	add.l	d2,d2
* - (D . N) * N + D
	swap	d0
	swap	d1
	swap	d2
	add.w	a3,d0
	add.w	a4,d1
	add.w	a5,d2
	movem.w	d0-d2,Matrix.YX(a0)
* U = V x N <=>
* Ux = Vy * Nz - Vz * Ny
* Uy = Vz * Nx - Vx * Nz
* Uz = Vx * Ny - Vy * Nx
	move.w	a2,d3
	muls.w	d1,d3
	move.w	d7,d4
	muls.w	d2,d4
	sub.l	d4,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,Matrix.XX(a0)
	move.w	d6,d3
	muls.w	d2,d3
	move.w	a2,d4
	muls.w	d0,d4
	sub.l	d4,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,Matrix.XY(a0)
	move.w	d7,d3
	muls.w	d0,d3
	move.w	d6,d4
	muls.w	d1,d4
	sub.l	d4,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,Matrix.XZ(a0)
	rts

* Test conversion. ? 
*  matrix[0][0] = 1.0 - 2*Y*Y - 2*Z*Z;
*  matrix[1][0] = 2*X*Y + 2*W*Z;
*  matrix[2][0] = 2*X*Z - 2*W*Y;
*
*  matrix[0][1] = 2*X*Y - 2*W*Z;
*  matrix[1][1] = 1.0 - 2*X*X - 2*Z*Z;
*  matrix[2][1] = 2*Y*Z + 2*W*X;
*
*  matrix[0][2] = 2*X*Z + 2*W*Y;
*  matrix[1][2] = 2*Y*Z - 2*W*X;
*  matrix[2][2] = 1.0 - 2*X*X - 2*Y*Y;
* Prolly x,y,z,w should be normalized.
* w seems a mystery.
	move.w	Quaternion.LOOK_Y(a1),d0
	muls.w	d0,d0
	move.w	Quaternion.LOOK_Z(a1),d1
	muls.w	d1,d1
	sub.l	d1,d0
	lsl.l	#2,d0
	move.w	#$7fff,d1
	sub.w	d0,d1
	rts

* Seems to work ok, since there has been some patching on the overflow
* errors (caused by combination of finite accuracy and use of maximum range).
* INPUT: d0.w: X rotation (a)
*        d1.w: Y rotation (b)
*        d2.w: Z rotation (c)
Matrix.generate:
	lea	Matrix.temp,a0
* 1> rotate 3 axis.
	Do_SinModulo	d0
	Do_SinModulo	d1
	Do_SinModulo	d2
	movea.w	d0,a3
	movea.w	d1,a4
	movea.w	d2,a5
	lea	Matrix.sineTable,a2

* X := + x*cos(b)*cos(c)
*      - y*cos(b)*sin(c)
*      + z*sin(b)
	Get_SinCos	a2,d1,d3,d4
	Get_SinCos	a2,d2,d5,d6
	muls.w	d4,d6				* / cos(b)*sin(c)
	add.l	d6,d6				* |
;	bvc.s	.skipxd6
;	subq.l	#1,d6
;.skipxd6:
	swap	d6				* \
	muls.w	d4,d5				* / -cos(b)*sin(c)
	add.l	d5,d5				* |
;	bvc.s	.skipxd5
;	subq.l	#1,d5
;.skipxd5:
	swap	d5				* |
	neg.w	d5				* \
	move.w	d6,(a0)+
	move.w	d5,(a0)+
	move.w	d3,(a0)+
	
* Y := + x*(sin(a)*sin(b)*cos(c)+cos(a)*sin(c))
*      + y*(cos(a)*cos(c)-sin(a)*sin(b)*sin(c))
*      - z*sin(a)*cos(b)
	Get_SinCos	a2,a3,d0,d1
	Get_Sin		a2,a4,d2
	Get_SinCos	a2,a5,d4,d5
	muls.w	d0,d2
	add.l	d2,d2
;	bvc.s	.skipyd2
;	subq.l	#1,d2
;.skipyd2:
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
;	bvc.s	.skipyd5
;	subq.l	#1,d5
;.skipyd5:
	swap	d5
	muls.w	d1,d4
	add.l	d4,d4
;	bvc.s	.skipyd4
;	subq.l	#1,d4
;.skipyd4:
	swap	d4
	add.w	d4,d5
	bvc.s	.skipyvd5
	addq.w	#1,d5
	neg.w	d5
.skipyvd5:
	move.w	d5,d3
	;Get_SinCos	a2,a3,d0,d1
	Get_Sin		a2,a4,d2
	Get_SinCos	a2,a5,d4,d5
	muls.w	d1,d5
	add.l	d5,d5
;	bvc.s	.skipy2d5
;	subq.l	#1,d5
;.skipy2d5:
	swap	d5
	muls.w	d0,d2
	add.l	d2,d2
;	bvc.s	.skipy2d2
;	subq.l	#1,d2
;.skipy2d2:
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	sub.w	d4,d5
	bvc.s	.skipyv2d5
	addq.w	#1,d5
	neg.w	d5
.skipyv2d5:
	Get_Cos		a2,a4,d4
	muls.w	d0,d4
	add.l	d4,d4
;	bvc.s	.skipy2d4
;	subq.l	#1,d4
;.skipy2d4:
	swap	d4
	neg.w	d4
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

* Z := + x*(sin(a)*sin(c)-cos(a)*sin(b)*cos(c))
*      + y*(cos(a)*sin(b)*sin(c)+sin(a)*cos(c))
*      + z*cos(a)*cos(b)
	Get_SinCos	a2,a3,d0,d1
	Get_Sin		a2,a4,d2
	Get_SinCos	a2,a5,d4,d5
	muls.w	d0,d4
	add.l	d4,d4
;	bvc.s	.skipzd4
;	subq.l	#1,d4
;.skipzd4:
	swap	d4
	muls.w	d1,d2
	add.l	d2,d2
;	bvc.s	.skipzd2
;	subq.l	#1,d2
;.skipzd2:
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
	swap	d5
	sub.w	d5,d4
	bvc.s	.skipzvd4
	addq.w	#1,d4
	neg.w	d4
.skipzvd4:
	move.w	d4,d3
	;Get_SinCos	a2,a3,d0,d1
	Get_Sin		a2,a4,d2
	Get_SinCos	a2,a5,d4,d5
	muls.w	d1,d2
	add.l	d2,d2
;	bvc.s	.skipz2d2
;	subq.l	#1,d2
;.skipz2d2:
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	muls.w	d0,d5
	add.l	d5,d5
;	bvc.s	.skipzd5
;	subq.l	#1,d5
;.skipzd5:
	swap	d5
	add.w	d4,d5
	bvc.s	.skipzvd5
	addq.w	#1,d5
	neg.w	d5
.skipzvd5:
	Get_Cos		a2,a4,d4
	muls.w	d1,d4
	add.l	d4,d4
;	bvc.s	.skipz2d4
;	subq.l	#1,d4
;.skipz2d4:
	swap	d4
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

* Translation vector := (0,0,0)
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	rts

* Give the object a unit-matrix and a translation of (0,0,0).
Matrix.loadUnity:
	move.w	#$7fff,d0
	moveq	#0,d1
	lea	Matrix.temp,a0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	rts

* Copy a matrix from, one location to the other.
* INPUT:
* a0: destination matrix
* a1: source matrix
Matrix.copy:
	moveq	#Matrix.SIZE/2-1,d7
.loop:	move.w	(a1)+,(a0)+
	dbra	d7,.loop
	rts

* Translate the matrix translation vector.
* INPUT: d0.w: X translation
*        d1.w: Y translation
*        d2.w: Z translation
Matrix.translate:
	lea	Matrix.temp,a0
	add.w	d0,Matrix.TX(a0)
	add.w	d1,Matrix.TY(a0)
	add.w	d2,Matrix.TZ(a0)
	rts

* Routine that multiplies the scale- and rotation-matrix AND also the
* translation vector. The matrix to be multiplied is the temporary matrix.
* This means this _must_ be inititialized.
* INPUT:
* a0: destination matrix
* a1: matrix to multiply with (source)
Matrix.multiply:
* Multiply matrix.
	movea.l	a0,a3
	lea	Matrix.temp,a0
	moveq	#3-1,d7

.rowloop:
	movem.w	(a1)+,d0-d2
	moveq	#3-1,d6

.columnloop:
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	Matrix.XX(a0),d3
	muls.w	Matrix.YX(a0),d4
	muls.w	Matrix.ZX(a0),d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	swap	d5
	move.w	d5,(a3)+
	addq	#2,a0
	dbra	d6,.columnloop

	subq	#2*3,a0
	dbra	d7,.rowloop

* Multiply (=rotate & scale) translation vector.
	lea	-2*3*3(a1),a1
	movem.l	Matrix.TX(a0),d0-d2
	moveq	#3-1,d7

.vectorloop:
	move.l	d0,d3
	move.w	(a1)+,d4
	ext.l	d4
	muls.l	d4,d4:d3
	add.l	d3,d3
	addx.l	d4,d4
	move.w	d4,d3
	swap	d3
	move.l	d1,d4
	move.w	(a1)+,d5
	ext.l	d5
	muls.l	d5,d5:d4
	add.l	d4,d4
	addx.l	d5,d5
	move.w	d5,d4
	swap	d4
	move.l	d2,d5
	move.w	(a1)+,d6
	ext.l	d6
	muls.l	d6,d6:d5
	add.l	d5,d5
	addx.l	d6,d6
	move.w	d6,d5
	swap	d5
	add.l	d3,d5
	add.l	d4,d5
	move.l	d5,(a3)+
	dbra	d7,.vectorloop

* Add new matrix's translation.
	movem.l	-12(a3),d0-d2
	add.l	(a1)+,d0
	add.l	(a1)+,d1
	add.l	(a1)+,d2
	movem.l	d0-d2,-12(a3)
	rts

* Pushes a previously generated matrix on the stack.
Matrix.push:
* First check for stack overflow.
	move.w	Matrix.stackTop,d0
	cmpi.w	#Matrix.MAX_DEPTH,d0
	bhs.s	.end
* The stack is not full..

* If this is the first matrix on the stack, then simply copy it.
.multiply_matrix:
	tst.w	d0
	bne.s	.not_first_entry
	lea	Matrix.stack,a0
	lea	Matrix.temp,a1
	bsr	Matrix.copy
	bra.s	.end_multiply_matrix
* Otherwise, multiply it with the previous entry.
.not_first_entry:
	lea	Matrix.stack,a0
	mulu.w	#Matrix.SIZE,d0
	adda.l	d0,a0				* a0 := address of current entry
	lea	-Matrix.SIZE(a0),a1		* a1 := address of previous entry
	bsr	Matrix.multiply
.end_multiply_matrix:

* Increase the stacktop by one.
	addq.w	#1,Matrix.stackTop
.end:	rts

* Pops the top matrix off the stack.
Matrix.pop:
	tst.w	Matrix.stackTop
	beq.s	.end
	subq.w	#1,Matrix.stackTop
.end:	rts

* Bad implementation.. Needs to be altered in order to work correctly with
* normals.
* INPUT: d0.w: X factor (-1.0 ... 1.0)
*        d1.w: Y factor (-1.0 ... 1.0)
*        d2.w: Z factor (-1.0 ... 1.0)
Matrix.scaleMatrix:
	lea	Matrix.temp,a0

	moveq	#3-1,d7
.xloop:	move.w	(a0),d3
	muls.w	d0,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a0)+
	dbra	d7,.xloop

	moveq	#3-1,d7
.yloop:	move.w	(a0),d3
	muls.w	d1,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a0)+
	dbra	d7,.yloop

	moveq	#3-1,d7
.zloop:	move.w	(a0),d3
	muls.w	d2,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a0)+
	dbra	d7,.zloop

	rts

******** TransformObject

* Rotates & scales & translates object by it's matrix.
* Also performs onscreen checks.
* INPUT:
* d0.w: flags
* d1.w: original objecthandle
* OUTPUT:
* d0.l: 1: visible, 0: invisible
TransformObject.transform:
	move.w	d0,.flags
	move.w	d1,d0
	bsr	ObjectRegistry.get
	movea.l	a0,a2

* Get current matrix...
	lea	Matrix.stack,a1
	move.w	Matrix.stackTop,d1
	ble	.invisible
	subq.w	#1,d1
	mulu.w	#Matrix.SIZE,d1
	adda.l	d1,a1

* Check visibility by using a boundingbox.
	movem.l	a1/a2,-(sp)
	lea	ObjectRegistry.bbTable,a1
	mulu.w	#8*3*2,d0
	adda.l	d0,a1
	bsr	PrimitiveMesh.getNextRectangle
	bsr	BoundingBox.calcRectangle
	movem.l	(sp)+,a1/a2
	tst.l	d0
	beq	.invisible
.object_visible:
	addq.w	#1,PrimitiveMesh.rectangleTable

* a1: matrix
* a2: untransformed object

	lea	Matrix.TX(a1),a3
	movea.l	PrimitiveMesh.nextadr,a0
	move.w	(a2)+,d7			* total amount of vertices
	move.w	(a2)+,a6			* amount of normal vectors
	sub.w	a6,d7				* amount of vertices

* Transform vertices...
.transform_vertices:
	subq.w	#1,d7
	movea.l	d7,a5
	movea.l	a0,a4
	addq	#4,a0

	move.w	a6,-(sp)

	movem.l	(a3),d6/a3/a6

.vertexloop:
	movem.w	(a2)+,d0-d2

* X
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	d6,d5				* Translate coordinate.
	swap	d5
	move.w	d5,(a0)+			* Store coordinate.
* Y
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	a3,d5				* Translate coordinate.
	swap	d5
	move.w	d5,(a0)+			* Store coordinate.
* Z
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	a6,d5				* Translate coordinate.
	swap	d5
	move.w	d5,(a0)+			* Store coordinate.

	lea	-3*6(a1),a1
	dbra	d7,.vertexloop

	movea.w	(sp)+,a6

.end_transform:

.perspectivation:
	lea	4(a4),a0
	move.w	a5,d7
	movem.w	Viewport.settingsTable+Viewport.XCENTER,d4/d5
	movem.w	Viewport.settingsTable+Viewport.FOCAL,d3/d6

	move.w	.flags(pc),d0
	andi.w	#TransformObject.PERSPECTIVATE,d0
	beq.s	.no_perspectivation

.loop:	movem.w	(a0),d0-d2
	lsl.l	#8,d0
	muls.w	d6,d1
	add.w	d3,d2
	divs.w	d2,d0
	divs.w	d2,d1
	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq	#2,a0
	dbra	d7,.loop
	bra.s	.end_perspectivation

.no_perspectivation:
.nploop:
	add.w	d4,(a0)+
	add.w	d5,(a0)+
	addq	#2,a0
	dbra	d7,.nploop

.end_perspectivation:

* Transform normal vectors...
.transform_normals:
	move.w	a6,d7
	subq.w	#1,d7
	bmi.s	.end_transformnormals

.normalloop:
	IFNE	TransformObject.ROTATE_NORMALS
	movem.w	(a2)+,d0-d2
	moveq	#3-1,d6

.normalcolumnloop:
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	swap	d5
	move.w	d5,(a0)+			* Store coordinate.
	dbra	d6,.normalcolumnloop

	lea	-3*6(a1),a1
	ELSE
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	ENDC
	dbra	d7,.normalloop
.end_transformnormals:

	move.w	(a2)+,d0
	move.l	a2,(a4)+			* Store 2dvertex address.
	lea	(a2,d0.w*Vertex2d.SIZE),a2	* address of primitives
	move.l	a0,PrimitiveMesh.nextadr

* Cull out all backfaced triangles and calculate Z.
	lea	PrimitiveMesh.primitiveTable,a0
	move.w	(a2)+,d7
	movea.l	a0,a6
	move.w	(a0)+,d0
	mulu.w	#MeshElement.SIZE,d0
	adda.l	d0,a0
	subq.w	#1,d7

	move.w	.flags(pc),d0
	andi.w	#TransformObject.BACKFACE_CULLING,d0
	beq	.no_culling

.cull_backfaces:
.calczloop:
	move.l	a2,MeshElement.REF(a0)
	move.l	a4,d1
	subq.l	#4,d1
	move.l	d1,MeshElement.BASE(a0)
.test_primitive:
	move.w	Primitive.TYPE(a2),d0
	andi.w	#Primitive.TYPEMASK,d0
	cmpi.w	#Primitive.SPRITETYPE,d0
	bne.s	.not_sprite
.sprite:
	move.w	Sprite.VERTEX(a2),d0
	mulu.w	#Vertex.SIZE,d0
	move.w	Vertex.Z(a4,d0.l),MeshElement.Z(a0)
	bmi	.end_calczloop
	addq.w	#1,(a6)
	lea	MeshElement.SIZE(a0),a0
	bra	.end_calczloop
.not_sprite:
	cmpi.w	#Primitive.LINETYPE,d0
	bne.s	.polygon
.line:	move.w	Line.VERTEX1(a2),d0
	mulu.w	#Vertex.SIZE,d0
	move.w	Vertex.Z(a4,d0.l),d1
	ext.l	d1
	move.w	Line.VERTEX2(a2),d0
	mulu.w	#Vertex.SIZE,d0
	move.w	Vertex.Z(a4,d0.l),d2
	ext.l	d2
	move.w	Primitive.TYPE(a2),d0
	andi.w	#Primitive.SHADEMASK,d0
	moveq	#2*2,d3
	cmpi.w	#Line.FLATSHADED,d0
	beq.s	.got_line_size
	add.l	d3,d3
.got_line_size:
	lea	2(a2,d3.l),a2
	add.l	d2,d1
	bmi	.end_calczloop
	asr.l	#1,d1
	move.w	d1,MeshElement.Z(a0)
	addq.w	#1,(a6)
	lea	MeshElement.SIZE(a0),a0
	bra	.end_calczloop
* This crap now tests if one of the vertices is behind the cam.
* Works good, but looks crappy.
.polygon:
* Backup number of points in polygon.
	moveq	#Primitive.TYPESHIFT,d1
	lsr.w	d1,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
* Backface culling first (only the first three points required).
	swap	d7
	move.w	2(a2),d0
	mulu.w	#Vertex.SIZE,d0
	movem.w	(a4,d0.l),d1/d2/a3
	move.w	a3,d7
	move.w	4(a2),d0
	mulu.w	#Vertex.SIZE,d0
	movem.w	(a4,d0.l),d3-d5
	adda.l	d5,a3
	or.w	d5,d7
	move.w	6(a2),d0
	mulu.w	#Vertex.SIZE,d0
	movem.w	(a4,d0.l),d5/d6/a5
	move.l	a5,d0
	adda.l	a5,a3
	or.w	d0,d7
	sub.w	d3,d1					* x1 - x2
	sub.w	d3,d5					* x3 - x2
	sub.w	d4,d2					* y1 - y2
	sub.w	d4,d6					* y3 - y2
	muls.w	d1,d6					* (x1-x2)(y3-y2)
	muls.w	d2,d5					* (x3-x2)(y1-y2)
	move.w	(sp)+,d1				* Get number of points in this polygon.
	move.w	d1,d2

	cmp.l	d6,d5					* (x3-x2)(y3-y2) (=d5) >= (x3-x2)(y1-y2) (=d6)?
	bpl.s	.backfaced
	subq.w	#3+1,d1
	bmi.s	.all_points_done
	lea	6(a2),a5
.addpoint_loop:
	move.w	(a5)+,d0
	mulu.w	#Vertex.SIZE,d0
	move.w	Vertex.Z(a4,d0.l),d0
	adda.w	d0,a3
	or.w	d0,d7
	dbra	d1,.addpoint_loop
.all_points_done:

	tst.w	d7
	bmi.s	.not_visible				* Dump primitive, if behind camera.
	move.l	a3,d0
	divu.w	d2,d0
	move.w	d0,MeshElement.Z(a0)
	lea	MeshElement.SIZE(a0),a0
	addq.w	#1,(a6)
.backfaced:
.not_visible:
* Proceed to next primitive...
	move.w	Primitive.TYPE(a2),d0
	andi.w	#Primitive.SHADEMASK,d0
	cmpi.w	#Polygon.FLATSHADED,d0
	beq.s	.got_primitive_size
	move.w	d2,d3
	add.w	d3,d2
	cmpi.w	#Polygon.ENVMAPPED,d0
	bls.s	.got_primitive_size
	add.w	d3,d2
.got_primitive_size:
	lea	2(a2,d2.w*2),a2
	swap	d7
.end_calczloop:
* ...and loop again.
	dbra	d7,.calczloop
	moveq	#1,d0
	rts

.no_culling:
.n_calczloop:
	move.l	a2,MeshElement.REF(a0)
	move.l	a4,d1
	subq.l	#4,d1
	move.l	d1,MeshElement.BASE(a0)
.n_test_primitive:
	move.w	Primitive.TYPE(a2),d0
	andi.w	#Primitive.TYPEMASK,d0
	cmpi.w	#Primitive.SPRITETYPE,d0
	bne.s	.n_not_sprite
.n_sprite:
	move.w	Sprite.VERTEX(a2),d0
	mulu.w	#Vertex.SIZE,d0
	move.w	Vertex.Z(a4,d0.l),MeshElement.Z(a0)
	bmi	.n_end_calczloop
	addq.w	#1,(a6)
	lea	MeshElement.SIZE(a0),a0
	bra	.n_end_calczloop
.n_not_sprite:
	cmpi.w	#Primitive.LINETYPE,d0
	bne.s	.n_polygon
.n_line:
	move.w	Line.VERTEX1(a2),d0
	mulu.w	#Vertex.SIZE,d0
	move.w	Vertex.Z(a4,d0.l),d1
	ext.l	d1
	move.w	Line.VERTEX2(a2),d0
	mulu.w	#Vertex.SIZE,d0
	move.w	Vertex.Z(a4,d0.l),d2
	ext.l	d2
	move.w	Primitive.TYPE(a2),d0
	andi.w	#Primitive.SHADEMASK,d0
	moveq	#2*2,d3
	cmpi.w	#Line.FLATSHADED,d0
	beq.s	.n_got_line_size
	add.l	d3,d3
.n_got_line_size:
	lea	2(a2,d3.l),a2
	add.l	d2,d1
	bmi	.n_end_calczloop
	asr.l	#1,d1
	move.w	d1,MeshElement.Z(a0)
	addq.w	#1,(a6)
	lea	MeshElement.SIZE(a0),a0
	bra	.n_end_calczloop
* This crap now tests if one of the vertices is behind the cam.
* Works good, but looks crappy.
.n_polygon:
* Backup number of points in polygon.
	moveq	#Primitive.TYPESHIFT,d1
	lsr.w	d1,d0
	addq.w	#1,d0
	move.w	d0,-(sp)
* Backface culling first (only the first three points required).
	swap	d7
	move.w	2(a2),d0
	mulu.w	#Vertex.SIZE,d0
	movem.w	(a4,d0.l),d1/d2/a3
	move.w	a3,d7
	move.w	4(a2),d0
	mulu.w	#Vertex.SIZE,d0
	movem.w	(a4,d0.l),d3-d5
	adda.l	d5,a3
	or.w	d5,d7
	move.w	6(a2),d0
	mulu.w	#Vertex.SIZE,d0
	movem.w	(a4,d0.l),d5/d6/a5
	move.l	a5,d0
	adda.l	a5,a3
	or.w	d0,d7
	sub.w	d3,d1
	sub.w	d3,d5
	sub.w	d4,d2
	sub.w	d4,d6
	muls.w	d1,d6
	muls.w	d2,d5
	move.w	(sp)+,d1				* Get number of points in this polygon.
	move.w	d1,d2
	cmp.l	d6,d5
	bpl.s	.n_backfaced
	move.w	d1,d2
	subq.w	#3-1,d1
	bmi.s	.n_all_points_done
	lea	6(a2),a5
.n_addpoint_loop:
	move.w	(a5)+,d0
	mulu.w	#Vertex.SIZE,d0
	move.w	Vertex.Z(a4,d0.l),d0
	adda.w	d0,a3
	or.w	d0,d7
	dbra	d1,.n_addpoint_loop
.n_all_points_done:

	tst.w	d7
	bmi.s	.n_not_visible				* Dump primitive, if behind camera.
	move.l	a3,d0
	divu.w	d2,d0
	move.w	d0,MeshElement.Z(a0)
	lea	MeshElement.SIZE(a0),a0
	addq.w	#1,(a6)
.n_backfaced:
.n_not_visible:
* Proceed to next primitive...
	move.w	Primitive.TYPE(a2),d0
	andi.w	#Primitive.SHADEMASK,d0
	cmpi.w	#Polygon.FLATSHADED,d0
	beq.s	.n_end_calczloop
	move.w	d2,d3
	add.w	d3,d2
	cmpi.w	#Polygon.ENVMAPPED,d0
	bls.s	.n_got_primitive_size
	add.w	d3,d2
.n_got_primitive_size:
	lea	2(a2,d2.w*2),a2
	swap	d7
.n_end_calczloop:
* ...and loop again.
	dbra	d7,.n_calczloop
	moveq	#1,d0
	rts

.invisible:	moveq	#0,d0
	rts

.flags:	DC.W	0

******** Primitive

* INPUT:
* a0: address of screenbuffer
Primitive.setScreenbuffer:
	move.l	a0,Primitive.screenadr
	rts

******** BoundingBox

* Performs boundingbox calculations. This returns a bounding rectangle.
* Uses the current Matrix to transform the box.
* INPUT:
* a0: destination rectangle
* a1: source (untransformed) bounding box
* OUTPUT:
* d0.l: 1=visible, 0=invisible
BoundingBox.calcRectangle:
	move.l	a0,-(sp)
	lea	.box_tbl(pc),a0
	bsr	BoundingBox.transform

.make_rectangle:
	lea	.box_tbl,a1
	bsr	BoundingBox.cullZ
	tst.l	d0
	bgt.s	.z_ok
	movea.l	(sp)+,a0
	clr.l	(a0)+
	clr.l	(a0)+
	moveq	#0,d0
	bra.s	.end
.z_ok:	lea	.box_tbl(pc),a1
	movea.l	(sp),a0
	bsr	BoundingBox.makeRect
	move.l	(sp)+,a1
	bsr	BoundingBox.cullXY
.end:	rts

.box_tbl:
	DS.W	8

* INPUT:
* a0: boundingbox-buffer to fill
* a1: object
BoundingBox.init:
	move.w	(a1)+,d7
	addq	#2,a1
* First find the highest and lowest x,y,z components..
	move.w	Vertex.X(a1),d0
	move.w	Vertex.Y(a1),d1
	move.w	Vertex.Z(a1),d2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	subq.w	#2,d7
	bmi.s	.endloop
	lea	Vertex.SIZE(a1),a1

.loop:	move.w	Vertex.X(a1),d6
	cmp.w	d6,d0
	ble.s	.nonewxl
	move.w	d6,d0
.nonewxl:
	cmp.w	d6,d3
	bge.s	.nonewxh
	move.w	d6,d3
.nonewxh:
	move.w	Vertex.Y(a1),d6
	cmp.w	d6,d1
	ble.s	.nonewyl
	move.w	d6,d1
.nonewyl:
	cmp.w	d6,d4
	bge.s	.nonewyh
	move.w	d6,d4
.nonewyh:
	move.w	Vertex.Z(a1),d6
	cmp.w	d6,d2
	ble.s	.nonewzl
	move.w	d6,d2
.nonewzl:
	cmp.w	d6,d5
	bge.s	.nonewzh
	move.w	d6,d5
.nonewzh:
	lea	Vertex.SIZE(a1),a1
	dbra	d7,.loop
.endloop:

* Now create a box (8 points) from the coordinates.
	move.w	d0,(a0)+			* / (xl,yl,zl)
	move.w	d1,(a0)+			* | 
	move.w	d2,(a0)+			* \
	move.w	d0,(a0)+			* / (xl,yl,zh)
	move.w	d1,(a0)+			* | 
	move.w	d5,(a0)+			* \
	move.w	d0,(a0)+			* / (xl,yh,zl)
	move.w	d4,(a0)+			* | 
	move.w	d2,(a0)+			* \
	move.w	d0,(a0)+			* / (xl,yh,zh)
	move.w	d4,(a0)+			* | 
	move.w	d5,(a0)+			* \
	move.w	d3,(a0)+			* / (xh,yl,zl)
	move.w	d1,(a0)+			* | 
	move.w	d2,(a0)+			* \
	move.w	d3,(a0)+			* / (xh,yl,zh)
	move.w	d1,(a0)+			* | 
	move.w	d5,(a0)+			* \
	move.w	d3,(a0)+			* / (xh,yh,zl)
	move.w	d4,(a0)+			* | 
	move.w	d2,(a0)+			* \
	move.w	d3,(a0)+			* / (xh,yh,zh)
	move.w	d4,(a0)+			* | 
	move.w	d5,(a0)+			* \
	rts

* Checks to see if a boundingbox is behind the camera.
* INPUT:
* a1: boundingbox
* OUTPUT:
* d0.l: 1=visible, 0=culled
BoundingBox.cullZ:
	moveq	#0,d0
	moveq	#8-1,d7
	addq	#4,a1

.loop:	tst.w	(a1)
	bpl.s	.corner_visible
	addq	#1,d0
.corner_visible:
	addq	#6,a1
	dbra	d7,.loop

	cmpi.w	#8,d0
	beq.s	.culled				* Culled if corners are behind cam.
.visible:
	moveq	#1,d0
	rts
.culled:
	moveq	#0,d0
	rts

* Checks a bounding window against the viewport.
* INPUT:
* a1: rectangle
* OUTPUT:
* d0.l: 1=visible, 0=culled
BoundingBox.cullXY:
	movem.w	Viewport.settingsTable+Viewport.XSTART,d0-d3
	moveq	#2-1,d7

.loop:	moveq	#0,d4
	move.w	(a1)+,d6
	move.w	2(a1),d5
.check_left:
	cmp.w	d5,d0				* XStart
	blt.s	.check_right
	addq.w	#%0010,d4
.check_right:
	cmp.w	d5,d1				* XEnd
	bgt.s	.check_above
	addq.w	#%0001,d4
.check_above:
	cmp.w	d6,d2				* YStart
	blt.s	.check_under
	ori.w	#%1000,d4
.check_under:
	cmp.w	d6,d3				* YEnd
	bgt.s	.end_check
	addq.w	#%0100,d4
.end_check:
	move.w	d4,-(sp)
	dbra	d7,.loop

	move.w	(sp)+,d0
	and.w	(sp)+,d0
	tst.w	d0
	beq.s	.visible
.culled:
	moveq	#0,d0
	rts
.visible:
	moveq	#1,d0
	rts

* INPUT:
* a0: destination bounding box
* a1: source boundingbox
BoundingBox.transform:

* Get current matrix...
	lea	Matrix.stack,a2
	move.w	Matrix.stackTop,d0
	bgt.s	.proceed
* The shit hit the fan, the matrixstack was empty!
	rts
.proceed:
	subq.w	#1,d0
	mulu.w	#Matrix.SIZE,d0
	adda.l	d0,a2

* Calculate the x-coordinates..
	moveq	#8-1,d7
	movem.l	Matrix.TX(a2),d6/a3/a6

.vertexloop:
	movem.w	(a1)+,d0-d2

* X
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a2)+,d3
	muls.w	(a2)+,d4
	muls.w	(a2)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	d6,d5				* Translate coordinate.
	swap	d5
	move.w	d5,(a0)+			* Store coordinate.
* Y
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a2)+,d3
	muls.w	(a2)+,d4
	muls.w	(a2)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	a3,d5				* Translate coordinate.
	swap	d5
	move.w	d5,(a0)+			* Store coordinate.
* Z
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a2)+,d3
	muls.w	(a2)+,d4
	muls.w	(a2)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	a6,d5				* Translate coordinate.
	swap	d5
	move.w	d5,(a0)+			* Store coordinate.

	lea	-3*6(a2),a2
	dbra	d7,.vertexloop
	rts

* Perspectivate the points and get the surrounding rectangle.
* a0: destination rectangle
* a1: bounding box
BoundingBox.makeRect:
	move.l	a0,-(sp)
	movea.l	a1,a0
	moveq	#8-2,d7
	movem.w	Viewport.settingsTable+Viewport.XCENTER,d3/d4
	movem.w	Viewport.settingsTable+Viewport.FOCAL,d5/d6

	movem.w	(a0)+,d1-d2
	move.w	(a0)+,d0
	bge.s	.pre_add
	move.w	d5,d0
	bra.s	.end_pre_add
.pre_add:
	add.w	d5,d0				* d0.w: scalefactor
.end_pre_add:
	lsl.l	#8,d1
	muls.w	d6,d2
	divs.w	d0,d1				* Scale x-coordinate.
	divs.w	d0,d2				* Scale y-coordinate.
	add.w	d3,d1				* Center x-coordinate.
	add.w	d4,d2				* Center y-coordinate.
	movea.w	d1,a1
	movea.w	d2,a2
	movea.w	d1,a5
	movea.w	d2,a6

.loop:	movem.w	(a0)+,d1-d2
	move.w	(a0)+,d0
	bge.s	.add
	move.w	d5,d0
	bra.s	.end_add
.add:	add.w	d5,d0				* d0.w: scalefactor
.end_add:
	lsl.l	#8,d1
	muls.w	d6,d2
	divs.w	d0,d1				* Scale x-coordinate.
	divs.w	d0,d2				* Scale y-coordinate.
	add.w	d3,d1				* Center x-coordinate.
	add.w	d4,d2				* Center y-coordinate.
	cmpa.w	d1,a1
	ble.s	.nonewxl
	movea.w	d1,a1
	bra.s	.endcmpx
.nonewxl:
	cmpa.w	d1,a5
	bge.s	.nonewxh
	movea.w	d1,a5
.nonewxh:
.endcmpx:
	cmpa.w	d2,a2
	ble.s	.nonewyl
	movea.w	d2,a2
	bra.s	.endcmpy
.nonewyl:
	cmpa.w	d2,a6
	bge.s	.nonewyh
	movea.w	d2,a6
.nonewyh:
.endcmpy:
	dbra	d7,.loop

* a1 = x0, a2 = y0, a5 = x1, a6 = y1
	subq	#1,a1				* / Make clearwindow
	subq	#1,a2				* \ a bit wider.
	move.l	a1,d0				* Backup x0.
	movea.l	a2,a1				* a1 = y0
	movea.l	a6,a2				* a2 = y1
	movea.l	a5,a6				* a6 = x1
	movea.l	d0,a5				* a5 = x0
	movea.l	(sp)+,a0			* Restore rectangle address.
	movem.w	a1-a2/a5-a6,(a0)		* Store rectangle.
	rts

******** Viewport

* Updates the viewport settings to any objects who need to know.
* USES: Viewport.settingsTable
Viewport.update:
	rts

* INPUT: d0.w: left x
*        d1.w: upper y
*        d6.w: right x
*        d7.w: lower y
*        d4.l: color (2 words)
*        a0: screen
Viewport.paintRectangle:
	lea	Viewport.settingsTable,a1

	cmp.w	Viewport.XSTART(a1),d0
	bpl.s	.testx0
	move.w	Viewport.XSTART(a1),d0
.testx0:
	cmp.w	Viewport.XEND(a1),d0
	blt.s	.endtestx0
	move.w	Viewport.XEND(a1),d0
	subq.w	#1,d0
.endtestx0:

	cmp.w	Viewport.YSTART(a1),d1
	bpl.s	.testy0
	move.w	Viewport.YSTART(a1),d1
.testy0:
	cmp.w	Viewport.YEND(a1),d1
	blt.s	.endtesty0
	move.w	Viewport.YEND(a1),d1
	subq.w	#1,d1
.endtesty0:

	cmp.w	Viewport.XSTART(a1),d6
	bpl.s	.testx1
	move.w	Viewport.XSTART(a1),d6
.testx1:
	cmp.w	Viewport.XEND(a1),d6
	blt.s	.endtestx1
	move.w	Viewport.XEND(a1),d6
	subq.w	#1,d6
.endtestx1:

	cmp.w	Viewport.YSTART(a1),d7
	bpl.s	.testy1
	move.w	Viewport.YSTART(a1),d7
.testy1:
	cmp.w	Viewport.YEND(a1),d7
	blt.s	.endtesty1
	move.w	Viewport.YEND(a1),d7
	subq.w	#1,d7
.endtesty1:

	move.w	d6,d2
	move.w	d7,d3
	addq.w	#1,d2
	andi.w	#$fffe,d2
	adda.w	d2,a0
	adda.w	d2,a0
	move.w	Viewport.XSCREEN(a1),d5
	add.w	d5,d5
	movea.w	d5,a4
	mulu.w	d5,d3
	adda.l	d3,a0
	sub.w	d0,d6
	addq.w	#1,d6
	sub.w	d1,d7
	move.l	d4,d0
	move.l	d4,d1
	move.l	d4,d2
	move.l	d4,d3
	movea.l	d4,a1
	movea.l	d4,a2
	movea.l	d4,a3
	lsr.w	#1,d6
	move.w	d6,d5
	add.w	d6,d5
	add.w	d5,d5
	suba.w	d5,a4
	ext.l	d6
	move.l	d6,d5
	andi.w	#$0007,d6
	lsr.w	#3,d5
	neg.l	d5
	neg.l	d6
	lea	(.endchunks.w,pc,d5.l*4),a5
	lea	(.endpix.w,pc,d6.l*2),a6

.yloop:	jmp	(a5)
	REPT	Viewport.MAX_X/16
	movem.l	d0-d4/a1-a3,-(a0)
	ENDR
.endchunks:
	jmp	(a6)
	REPT	7
	move.l	d0,-(a0)
	ENDR
.endpix:

	suba.l	a4,a0
	dbra	d7,.yloop
	rts

******** PrimitiveMesh

* Marks the PrimitiveMesh as ready to roll.
PrimitiveMesh.new:
	move.l	#PrimitiveMesh.vertexTable,PrimitiveMesh.nextadr
	clr.w	PrimitiveMesh.primitiveTable

.clearRectangles:
	clr.w	PrimitiveMesh.rectangleTable
	rts

* OUTPUT:
* a0: new rectangle structure
PrimitiveMesh.getNextRectangle:
	lea	PrimitiveMesh.rectangleTable,a0
	move.w	(a0)+,d0
	lea	(a0,d0.w*Rectangle.SIZE),a0
	rts

PrimitiveMesh.COMBSORT:		=	0
PrimitiveMesh.RADIXSORT:	=	1
PrimitiveMesh.SORT_ALGORITHM:	=	PrimitiveMesh.RADIXSORT

* Sort the elements using radixsort.
PrimitiveMesh.sortZ:

	IFEQ	PrimitiveMesh.SORT_ALGORITHM-PrimitiveMesh.COMBSORT

	lea	PrimitiveMesh.elementTable,a0
	move.w	(a0)+,d7			* d7.w: number of elements
	movea.l	a0,a6
	move.w	d7,d4
	subq.w	#1,d7
	ble.s	.endcombsort
	lsr.w	#1,d4				* d4.w: gapsize
	movea.w	#meshElemSize,a5
	bra.s	.endcalcgap
.combsortloop:
	cmpi.w	#2,d4				* / If the gapsize
	bhi.s	.calcgap			* | is already 1 or
	moveq	#1,d4				* | 2 then always
	bra.s	.endcalcgap			* \ set it to 1.
.calcgap:
	mulu.w	#((1<<16)*10)/13,d4		* / Resize
	swap	d4				* \ the gap.
.endcalcgap:
	move.w	d7,d6
	sub.w	d4,d6
	move.w	d4,d0
	mulu.w	#meshElemSize,d0
	lea	(a0,d0.l),a1
	moveq	#0,d5				* d5.w: number of swaps done in loop

.combsortinloop:
	move.w	meshElemZ(a0),d0
	move.w	meshElemZ(a1),d1
	cmp.w	d1,d0
	bge.s	.noswap
	movem.l	(a0),d2-d3
	move.l	(a1),(a0)+
	move.l	d2,(a1)+
	move.l	(a1),(a0)+
	move.l	d3,(a1)+
	move.w	d0,(a1)+
	move.w	d1,(a0)+
	addq.w	#1,d5
	dbra	d6,.combsortinloop
	bra.s	.combsortloopend
.noswap:	
	adda.l	a5,a0
	adda.l	a5,a1
	dbra	d6,.combsortinloop
.combsortloopend:
	movea.l	a6,a0
	move.w	d5,d5
	bne.s	.combsortloop
	cmpi.w	#1,d4
	bne.s	.combsortloop
.endcombsort:

.rts:	rts

	ELSE

* Radixsort implementation. It ain't that great. With over 250 elements
* however, it starts kicking every other algo's ass!
	lea	PrimitiveMesh.primitiveTable,a1
	lea	.elem_tbl,a0
	move.w	(a1)+,d7			* d7.w: number of elements
	subq.w	#1,d7
	bmi	.rts
	moveq	#MeshElement.SIZE,d2
	move.l	a1,a3
	move.w	d7,d6

	lea	.index_tbl,a2
	movea.l	a2,a5
	move.w	#129-1,d0
	moveq	#0,d1
.clearindex1_loop:
	move.l	d1,(a2)+
	dbra	d0,.clearindex1_loop

	movea.l	a5,a2
	moveq	#0,d0
.indexhigh1_loop:
	move.b	MeshElement.Z+1(a1),d0
	addq.w	#1,(a2,d0.l*2)
	adda.l	d2,a1
	dbra	d7,.indexhigh1_loop

	move.w	#256-1,d0
	lea	256*2(a5),a2
.addindex1_loop:
	move.w	(a2),d1
	add.w	d1,-(a2)
	dbra	d0,.addindex1_loop

	movea.l	a3,a1
	lea	2(a5),a2
	move.w	d6,d7
	moveq	#0,d0
.map1_loop:
	move.b	MeshElement.Z+1(a1),d0
	move.w	(a2,d0.l*2),d1
	mulu.w	d2,d1
	lea	(a0,d1.l),a4
	move.l	(a1)+,(a4)+
	move.l	(a1)+,(a4)+
	move.w	(a1)+,(a4)+
	addq.w	#1,(a2,d0.l*2)
	dbra	d7,.map1_loop

	lea	PrimitiveMesh.primitiveTable+2,a0
	lea	.elem_tbl,a1
	movea.l	a1,a3

	movea.l	a5,a2
	move.w	#129-1,d0
	moveq	#0,d1
.clearindex2_loop:
	move.l	d1,(a2)+
	dbra	d0,.clearindex2_loop

	movea.l	a5,a2
	move.w	d6,d7
	moveq	#0,d0
.indexhigh2_loop:
	move.b	MeshElement.Z(a1),d0
	addq.w	#1,(a2,d0.l*2)
	adda.l	d2,a1
	dbra	d7,.indexhigh2_loop

	move.w	#256-1,d0
	lea	256*2(a5),a2
.addindex2_loop:
	move.w	(a2),d1
	add.w	d1,-(a2)
	dbra	d0,.addindex2_loop

	movea.l	a3,a1
	lea	2(a5),a2
	move.w	d6,d7
	moveq	#0,d0
.map2_loop:
	move.b	MeshElement.Z(a1),d0
	move.w	(a2,d0.l*2),d1
	mulu.w	d2,d1
	lea	(a0,d1.l),a4
	move.l	(a1)+,(a4)+
	move.l	(a1)+,(a4)+
	move.w	(a1)+,(a4)+
	addq.w	#1,(a2,d0.l*2)
	dbra	d7,.map2_loop

.rts:	rts

	BSS

.index_tbl:
	DS.W	256+2
.elem_tbl:
	DS.W	1				* number of elements in mesh
	DS.B	PrimitiveMesh.MAX_PRIMITIVES*MeshElement.SIZE

	TEXT

	ENDC

* Total dummyness.
PrimitiveMesh.complete:
	rts

* Paints all primitives on the mesh to screen.
* INPUT:
* a0: destination storage for bounding rectangles
PrimitiveMesh.paint:
	move.l	a0,-(sp)
.painting:
	lea	PrimitiveMesh.primitiveTable,a0
	move.w	(a0)+,d7
	subq.w	#1,d7
	bmi.s	.end_of_painting

.loop:	move.w	d7,-(sp)
	move.l	a0,-(sp)

	movea.l	(a0)+,a2			meshElemBase(a0),a2
	movea.l	(a0)+,a1			meshElemRef(a0),a1
	move.w	(a1),d0				primitiveType(a1),d0
	move.w	d0,d1
	andi.w	#Primitive.TYPEMASK,d1
	cmpi.w	#Primitive.SPRITETYPE,d1
	beq.s	.sprite
	cmpi.w	#Primitive.LINETYPE,d1
	beq.s	.line
	moveq	#16-3,d2
	lsr.w	d2,d0
.triangle:
	moveq	#Primitive.TYPESHIFT,d2
	lsr.w	d2,d1
	jsr	.polygonjump_tbl(pc,d0.w*4)
	bra.s	.end_paint
.line:	bsr	Line.paint
	bra.s	.end_paint
.sprite:
	bsr	Sprite.paint
.end_paint:

	movea.l	(sp)+,a0
	move.w	(sp)+,d7

.end_loop:
	lea	MeshElement.SIZE(a0),a0
	dbra	d7,.loop
.end_of_painting:
	movea.l	(sp)+,a0

* Now copy all those bounding boxes..
.store_rectangles:
	lea	PrimitiveMesh.rectangleTable,a1
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	beq.s	.end_store_rectangles
	subq.w	#1,d7
.rect_loop:
	REPT	Rectangle.SIZE/2
	move.w	(a1)+,(a0)+
	ENDR
	dbra	d7,.rect_loop
.end_store_rectangles:
	rts

.polygonjump_tbl:
	bra.w	Polygon.paintClippedFlatshaded
	bra.w	Polygon.paintClippedGouraudshaded
	bra.w	Polygon.paintClippedPhongshaded
	bra.w	Polygon.paintClippedTextured
	bra.w	Polygon.paintClippedEnvmapped
	bra.w	Polygon.paintClippedAlphatextured
	bra.w	Polygon.paintClippedBumpmapped
	REPT	1
	rts
	DC.W	0
	ENDR

* Beware! No clipping on Polygons!!!!!!! Use this only when absolutely
* suer all polygons are within the viewport range.
PrimitiveMesh.paintUnclipped:
	lea	PrimitiveMesh.primitiveTable,a0
	move.w	(a0)+,d7
	subq.w	#1,d7
	bmi.s	.rts

.loop:	move.w	d7,-(sp)
	move.l	a0,-(sp)

	movea.l	(a0)+,a2			meshElemBase(a0),a2
	movea.l	(a0)+,a1			meshElemRef(a0),a1
	move.w	(a1),d0				primitiveType(a1),d0
	move.w	d0,d1
	andi.w	#Primitive.TYPEMASK,d1
	cmpi.w	#Primitive.SPRITETYPE,d1
	beq.s	.sprite
	cmpi.w	#Primitive.LINETYPE,d1
	beq.s	.line
	moveq	#16-3,d2
	lsr.w	d2,d0
.triangle:
	moveq	#Primitive.TYPESHIFT,d2
	lsr.w	d2,d1
	jsr	.polygonjump_tbl(pc,d0.w*4)
	bra.s	.end_paint
.line:	bsr	Line.paint
	bra.s	.end_paint
.sprite:
	bsr	Sprite.paint
.end_paint:

	movea.l	(sp)+,a0
	move.w	(sp)+,d7

.end_loop:
	lea	MeshElement.SIZE(a0),a0
	dbra	d7,.loop

.rts:	rts

.polygonjump_tbl:
	bra.w	Polygon.paintUnclippedFlatshaded
	bra.w	Polygon.paintUnclippedGouraudshaded
	bra.w	Polygon.paintUnclippedPhongshaded
	bra.w	Polygon.paintUnclippedTextured
	bra.w	Polygon.paintUnclippedEnvmapped
	bra.w	Polygon.paintUnclippedAlphatextured
	bra.w	Polygon.paintUnclippedBumpmapped
	REPT	1
	rts
	DC.W	0
	ENDR

******** Polygon

* Initializes polygonpainter lookup tables.
* INPUT:
* a0: texture-address-table
* a1: gouraud-tables
* OUTPUT:
* d0.l: 0=ok, -1=error
Polygon.init:
	move.l	a0,Polygon.textureadr
	move.l	a1,Polygon.coloradr

	bsr	Polygon.parseTextureTable

	bsr	Polygon.calcInvTable

	IFNE	Polygon.USE_BLITGOURAUD
	bsr	Polygon.initBlitGouraud
	tst.l	d0
	bmi.s	.error
	ENDC

.success:
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

* Parses a table containing APX block textures and resets all addresses
* to point to the start of the pixeldata.
* PRECONDITIONS:
* The texturetable points to APX blocks.
* The texturetable is null-terminated.
* INPUT:
* a0: texture table
Polygon.parseTextureTable:
.loop:	movea.l	(a0)+,a1
	tst.l	a1
	beq.s	.end
	move.l	(a1),d0
.test_byte_per_pixel:
	cmpi.l	#"Byte",d0
	bne.s	.end_test_byte_per_pixel
	lea	788(a1),a1
.end_test_byte_per_pixel:
.test_word_per_pixel:
	cmpi.l	#"Word",d0
	bne.s	.end_test_word_per_pixel
	lea	20(a1),a1
.end_test_word_per_pixel:
	move.l	a1,-4(a0)
	bra.s	.loop
.end:	rts

Polygon.calcInvTable:
	lea	Polygon.invTable,a0
	move.l	#$80000000,d1
	moveq	#2,d0
	move.l	d1,d2
	swap	d2
	move.w	#$7fff,(a0)+
	move.w	#$7fff,(a0)+

.posloop:
	move.l	d1,d2
	divu.l	d0,d2
	swap	d2
	move.w	d2,(a0)+
	addq.w	#1,d0
	cmpi.w	#Viewport.MAX_Y,d0
	blt.s	.posloop

	rts

* Calculates a 64K highcolor-word lookup table from two 256 truecolor
* palettes.
* INPUT: d7.w: start intensity of palette1
*        a0: highcolor lookuptable
*        a1: truecolor palette1
*        a2: truecolor palette2 (256 entries)
*        a5: number of entries in palette1
Polygon.calcMixtable:
	movea.l	#$0000ffff,a6

.palloop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a1)+,d0
	move.b	(a1)+,d1
	move.b	(a1)+,d2
	muls.w	d7,d0
	muls.w	d7,d1
	muls.w	d7,d2
	lsl.l	#1,d0
	lsl.l	#1,d1
	lsl.l	#1,d2
	moveq	#0,d6

.colorloop:
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.b	(a2)+,d3
	move.b	(a2)+,d4
	move.b	(a2)+,d5
	mulu.w	d6,d3
	mulu.w	d6,d4
	mulu.w	d6,d5
	add.l	d0,d3
	bpl.s	.red1_ok
	moveq	#0,d3
	bra.s	.red_ok
.red1_ok:
	cmp.l	a6,d3
	blt.s	.red_ok
	move.w	a6,d3
.red_ok:
	add.l	d1,d4
	bpl.s	.green1_ok
	moveq	#0,d4
	bra.s	.green_ok
.green1_ok:
	cmp.l	a6,d4
	blt.s	.green_ok
	move.w	a6,d4
.green_ok:
	add.l	d2,d5
	bpl.s	.blue1_ok
	moveq	#0,d5
	bra.s	.blue_ok
.blue1_ok:
	cmp.l	a6,d5
	blt.s	.blue_ok
	move.w	a6,d5
.blue_ok:
	andi.w	#%1111100000000000,d3
	lsr.w	#5,d4
	andi.w	#%0000011111100000,d4
	lsr.w	#8,d5
	lsr.w	#3,d5
	or.w	d4,d3
	or.w	d5,d3
	move.w	d3,(a0)+
	addq.b	#1,d6
	bne.s	.colorloop

	lea	-256*3(a2),a2
	addq.w	#1,d7
	cmp.w	a5,d7
	blt.s	.palloop

	rts

	IFNE	Polygon.USE_BLITGOURAUD

* Initialize all tables for fast gouraud routines.
Polygon.initBlitGouraud:
* Reserve memory for special gouraud tables.
	move.w	#(Polygon.USE_BLITTER-1)&1,-(sp)		* ST-RAM / TT-RAM select
	move.l	#256*256*2+4,-(sp)		* size of gouraudbuffer
	move.w	#$44,-(sp)			* Code $44: Mxalloc()
	trap	#1
	addq	#8,sp
	move.l	d0,d0				* Check if there is enough RAM.
	beq.s	.error
	addq.l	#3,d0
	andi.w	#$fffc,d0
	move.l	d0,Polygon.gouraudtbladr

	lea	color_tbl,a1
	moveq	#4-1,d0
	movea.l	Polygon.gouraudtbladr,a0
	bsr	Polygon.calcGouraudTable3

	bsr	Polygon.calcNormalizeTable

* Initialize blitter... Might be a bit wrong when also blitter sprites are
* to be used.
	andi.b	#$7f,$ffff8a3c.w
	move.w	#2,$ffff8a20.w			* source x increment
	move.w	#2,$ffff8a22.w			* source y increment
	move.w	#$ffff,$ffff8a28.w		* start mask
	move.w	#$ffff,$ffff8a2a.w		* mid mask
	move.w	#$ffff,$ffff8a2c.w		* end mask
	move.w	#2,$ffff8a2e.w			* end x increment
	move.w	#2,$ffff8a30.w			* end y increment
	move.b	#$02,$ffff8a3a.w		* halftone-op: source only
	move.b	#$03,$ffff8a3b.w		* logical op: source only
	move.b	#$c0,$ffff8a3d.w		* force extra source read | no final source read

.success:
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

Polygon.calcNormalizeTable:
	lea	Polygon.normalizeTable+128*256,a0
	moveq	#0,d0

.posloop:
	move.l	d0,d1
	move.l	d0,d2
	asr.w	#8,d1
	addq.w	#1,d1
	beq.s	.pos_skip
	divs.w	d1,d2
.pos_skip:
	not.b	d2
	move.b	d2,(a0)+
	addq.w	#1,d0
	bpl.s	.posloop

	lea	Polygon.normalizeTable,a0

.negloop:
	move.l	d0,d1
	move.l	d0,d2
	asr.w	#8,d1
	addq.w	#1,d1
	beq.s	.neg_skip
	divs.w	d1,d2
.neg_skip:
	not.b	d2
	move.b	d2,(a0)+
	addq.w	#1,d0
	bmi.s	.negloop
	rts

* INPUT: d0.w: number of shades -1 
*        a0: gouraud table address
*        a1: shades table
Polygon.calcGouraudTable3:
	move.w	d0,d6
	move.w	d0,d7

* Calculate g-shade tables.
* Calculate the indices to g-shade tables.
	lea	Polygon.gouraudlengthTable,a3
	lea	Polygon.gouraudindexTable,a2
	movea.l	a0,a6

.shadeloop:
	move.w	#$4000,d0
	moveq	#0,d4

.tableloop:
	move.w	d0,d1
	lsr.w	#6,d1
	moveq	#0,d2

	cmp.w	d6,d7
	bne.s	.nowriteindex
	move.l	a0,d3
	sub.l	a6,d3
	move.w	d3,(a2)+
.nowriteindex:

.pixelloop:
	move.w	d2,d3
	lsr.w	#8,d3
;	IFNE	testmode			* 1= debug (store index instead of color)
;	move.w	d3,(a0)+
;	ELSE
	move.w	(a1,d3.w*2),(a0)+
;	ENDC
	add.w	d1,d2
	cmpi.w	#$4000,d2
	blt.s	.pixelloop

	cmp.w	d6,d7
	bne.s	.nowritelength
	move.l	a0,d3
	sub.l	a6,d3
	lsr.w	#1,d3
	sub.w	d4,d3
	lsl.w	#2,d3				* precalc shift
	move.w	d3,(a3)+
	add.w	d3,d4
.nowritelength:

	subi.w	#$0040,d0
	cmpi.w	#$2000,d0
	bhi.s	.tableloop
.skip:
	dbra	d6,.shadeloop

	rts

	ENDC

* Dummy subroutine. Bumpmaps need not be registered in this implementation.
Polygon.registerBumpmap:
	rts

* FlatShadedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintClippedFlatshaded:
	move.w	d1,d7
	moveq	#0,d0
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	Polygon.coloradr,a0
	lea	Primitive.GRADIENTSIZE/2(a0),a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0
	move.w	(a0,d0.l),d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,Polygon.color
	addq	#2,a1
	addq	#4,a2
	moveq	#Vertex.SIZE,d6
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	addq.w	#1,d7
	move.w	d7,(a0)+
	move.w	(a1)+,d0
	mulu.w	d6,d0
	move.l	(a2,d0.l),(a0,d7.w*4)
	move.l	(a2,d0.l),(a0)+
	subq.w	#2,d7

.vertexloop:
	move.w	(a1)+,d0
	mulu.w	d6,d0
	move.l	(a2,d0.l),(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a0
	bra	Polygon.clipV0

* FlatShadedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintUnclippedFlatshaded:
	move.w	d1,d7
	moveq	#0,d0
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	Polygon.coloradr,a0
	lea	Primitive.GRADIENTSIZE/2(a0),a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0
	move.w	(a0,d0.l),d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,Polygon.color
	addq	#2,a1
	addq	#4,a2
	moveq	#Vertex.SIZE,d6
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	addq.w	#1,d7
	move.w	d7,(a0)+
	subq.w	#1,d7

.vertexloop:
	move.w	(a1)+,d0
	mulu.w	d6,d0
	move.l	(a2,d0.l),(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a1
	bra	Polygon.paintFlatshaded

* GouraudShadedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintClippedGouraudshaded:
	move.w	d1,d7
	moveq	#0,d0
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	Polygon.coloradr,a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0				* d0*(64*2)
	adda.l	d0,a0
	move.l	a0,Polygon.gradadr
	addq.w	#1,d7
	lea	2(a1,d7.w*2),a3
	addq	#2,a1
	addq	#4,a2
	moveq	#Vertex.SIZE,d6
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	move.w	d7,(a0)+
	move.w	(a1)+,d0
	move.w	(a3)+,d3
	mulu.w	d6,d0
	move.w	d7,d1
	mulu.w	#6,d1
	move.l	(a2,d0.l),(a0,d1.l)
	move.w	d3,4(a0,d1.l)
	move.l	(a2,d0.l),(a0)+
	move.w	d3,(a0)+
	subq.w	#2,d7

.vertexloop:
	move.w	(a1)+,d2
	move.w	(a3)+,d3
	mulu.w	d6,d2
	move.l	(a2,d2.l),(a0)+
	move.w	d3,(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a0
	bra	Polygon.clipV1

* GouraudShadedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintUnclippedGouraudshaded:
	move.w	d1,d7
	moveq	#0,d0
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	Polygon.coloradr,a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0				* d0*(64*2)
	adda.l	d0,a0
	move.l	a0,Polygon.gradadr
	addq.w	#1,d7
	lea	2(a1,d7.w*2),a3
	addq	#2,a1
	lea	4(a2),a4
	moveq	#Vertex.SIZE,d6
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	move.w	d7,(a0)+
	subq.w	#1,d7

.vertexloop:
	move.w	(a1)+,d0
	mulu.w	d6,d0
	move.l	(a4,d0.l),(a0)+
	move.w	(a3)+,(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a1
	bra	Polygon.paintGouraudshaded

* PhongShadedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintClippedPhongshaded:
	move.w	d1,d7
	moveq	#0,d0
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	Polygon.coloradr,a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0				* d0*(64*2)
	adda.l	d0,a0
	move.l	a0,Polygon.gradadr
	addq.w	#1,d7
	lea	2(a1,d7.w*2),a3
	addq	#2,a1
	addq	#4,a2
	moveq	#Vertex.SIZE,d6
	moveq	#127,d5
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	move.w	d7,(a0)+
	move.w	(a1)+,d0
	move.w	(a3)+,d3
	mulu.w	d6,d0
	mulu.w	d6,d3
	move.w	d7,d1
	mulu.w	#6,d1
	move.l	(a2,d0.l),(a0,d1.l)
	move.w	Vertex.Z(a2,d3.l),d2
	add.w	d5,d2
	lsr.w	#-(Primitive.GRADIENTBITS-8),d2
	move.w	d2,4(a0,d1.l)
	move.l	(a2,d0.l),(a0)+
	move.w	d2,(a0)+
	subq.w	#2,d7

.vertexloop:
	move.w	(a1)+,d2
	move.w	(a3)+,d3
	mulu.w	d6,d2
	mulu.w	d6,d3
	move.l	(a2,d2.l),(a0)+
	move.w	Vertex.Z(a2,d3.l),d2
	add.w	d5,d2
	lsr.w	#-(Primitive.GRADIENTBITS-8),d2
	move.w	d2,(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a0
	bra	Polygon.clipV1

* PhongShadedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintUnclippedPhongshaded:
	move.w	d1,d7
	moveq	#0,d0
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	Polygon.coloradr,a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0				* d0*(64*2)
	adda.l	d0,a0
	move.l	a0,Polygon.gradadr
	addq.w	#1,d7
	lea	2(a1,d7.w*2),a3
	addq	#2,a1
	addq	#4,a2
	moveq	#Vertex.SIZE,d6
	moveq	#127,d5
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	move.w	d7,(a0)+
	subq.w	#1,d7

.vertexloop:
	move.w	(a1)+,d2
	move.w	(a3)+,d3
	mulu.w	d6,d2
	mulu.w	d6,d3
	move.l	(a2,d2.l),(a0)+
	move.w	Vertex.Z(a2,d3.l),d2
	add.w	d5,d2
	lsr.w	#-(Primitive.GRADIENTBITS-8),d2
	move.w	d2,(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a1
	bra	Polygon.paintGouraudshaded

* TexturedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintClippedTextured:
	move.w	d1,d7
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	move.w	d0,Polygon.curtexture
	movea.l	(a2)+,a3
	addq	#2,a1
	addq.w	#1,d7
	lea	(a1,d7.w*2),a4
	moveq	#Vertex.SIZE,d6
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	move.w	d7,(a0)+
	move.w	(a1)+,d0
	mulu.w	d6,d0
	movea.w	(a4)+,a5
	move.l	(a2,d0.l),(a0,d7.w*8)
	move.l	(a3,a5.l*Vertex2d.SIZE),4(a0,d7.w*8)
	move.l	(a2,d0.l),(a0)+
	move.l	(a3,a5.l*Vertex2d.SIZE),(a0)+
	subq.w	#2,d7

.vertexloop:
	move.w	(a1)+,d0
	mulu.w	d6,d0
	move.l	(a2,d0.l),(a0)+
	movea.w	(a4)+,a5
	move.l	(a3,a5.l*Vertex2d.SIZE),(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a0
	bra	Polygon.clipV2

* TexturedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintUnclippedTextured:
	move.w	d1,d7
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	move.w	d0,Polygon.curtexture
	movea.l	(a2)+,a3
	addq	#2,a1
	addq.w	#1,d7
	lea	(a1,d7.w*2),a4
	moveq	#Vertex.SIZE,d6
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	move.w	d7,(a0)+
	subq.w	#1,d7

.vertexloop:
	move.w	(a1)+,d0
	mulu.w	d6,d0
	move.l	(a2,d0.l),(a0)+
	movea.w	(a4)+,a5
	move.l	(a3,a5.l*Vertex2d.SIZE),(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a1
	bra	Polygon.paintTexturemapped

* EnvironmentMappedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintClippedEnvmapped:
	move.w	d1,d7
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	move.w	d0,Polygon.curtexture
	addq	#4,a2
	addq	#2,a1
	addq.w	#1,d7
	lea	(a1,d7.w*2),a4
	movea.w	#$80,a6
	moveq	#Vertex.SIZE,d6
	lea	Polygon.polypointTable,a0
	movea.l	a0,a5
	move.w	d7,(a0)+
	move.w	(a1)+,d0
	move.w	(a4)+,d2
	mulu.w	d6,d0
	mulu.w	d6,d2
	move.l	(a2,d0.l),(a0,d7.w*8)
	movem.w	(a2,d2.l),d2-d3
	add.w	a6,d2
	add.w	a6,d3
	movem.w	d2-d3,4(a0,d7.w*8)
	move.l	(a2,d0.l),(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	subq.w	#2,d7

.vertexloop:
	move.w	(a1)+,d0
	move.w	(a4)+,d2
	mulu.w	d6,d0
	mulu.w	d6,d2
	move.l	(a2,d0.l),(a0)+
	movem.w	(a2,d2.l),d2-d3
	add.w	a6,d2
	add.w	a6,d3
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	dbra	d7,.vertexloop

	movea.l	a5,a0
	bra	Polygon.clipV2

* EnvironmentMappedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintUnclippedEnvmapped:
	move.w	d1,d7
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	move.w	d0,Polygon.curtexture
	addq	#4,a2
	addq	#2,a1
	addq.w	#1,d7
	lea	(a1,d7.w*2),a4
	movea.w	#$80,a6
	moveq	#Vertex.SIZE,d6
	lea	Polygon.polypointTable,a0
	movea.l	a0,a5
	move.w	d7,(a0)+
	subq.w	#1,d7

.vertexloop:
	move.w	(a1)+,d0
	move.w	(a4)+,d2
	mulu.w	d6,d0
	mulu.w	d6,d2
	move.l	(a2,d0.l),(a0)+
	movem.w	(a2,d2.l),d2-d3
	add.w	a6,d2
	add.w	a6,d3
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	dbra	d7,.vertexloop

	movea.l	a5,a1
	bra	Polygon.paintTexturemapped

* AlphaTexturedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintClippedAlphatextured:
	move.l	#Polygon.paintAlphatextured,Polygon.v4routadr
	bra.s	Polygon.paintClippedV4

* BumpmappedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintClippedBumpmapped:
	move.l	#Polygon.paintBumpmapped,Polygon.v4routadr
;	bra	Polygon.paintClippedV4

* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintClippedV4:
	move.w	d1,d7
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	Polygon.textureadr,a0
	move.l	(a0,d0.w*4),Polygon.curtexture
	move.l	4(a0,d0.w*4),Polygon.curtexture2
	movea.l	(a2)+,a3
	addq	#2,a1
	addq.w	#1,d7
	lea	(a1,d7.w*2),a4
	moveq	#Vertex.SIZE,d6
	move.w	#$80,d5
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	move.w	d7,(a0)+
	move.w	d7,d2
	mulu.w	#PolyPoint.SIZE,d2
	move.w	(a1)+,d3
	mulu.w	d6,d3
	move.l	(a2,d3.l),(a0,d2.l)
	movea.w	(a4)+,a5
	move.l	(a3,a5.l*Vertex2d.SIZE),4(a0,d2.l)
	move.w	(a4)+,d0
	mulu.w	d6,d0
	movem.w	(a2,d0.l),d0-d1
	add.w	d5,d0
	add.w	d5,d1
	movem.w	d0-d1,8(a0,d2.l)
	move.l	(a2,d3.l),(a0)+
	move.l	(a3,a5.l*Vertex2d.SIZE),(a0)+
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	subq.w	#2,d7

.vertexloop:
	move.w	(a1)+,d3
	mulu.w	d6,d3
	move.l	(a2,d3.l),(a0)+
	movea.w	(a4)+,a5
	move.l	(a3,a5.l*Vertex2d.SIZE),(a0)+
	move.w	(a4)+,d0
	mulu.w	d6,d0
	movem.w	(a2,d0.l),d0-d1
	add.w	d5,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a0
	bra	Polygon.clipV4

* AlphaTexturedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintUnclippedAlphatextured:
	move.l	#Polygon.paintAlphatextured,Polygon.v4routadr
	bra.s	Polygon.paintUnclippedV4

* BumpmappedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintUnclippedBumpmapped:
	move.l	#Polygon.paintBumpmapped,Polygon.v4routadr
;	bra	Polygon.paintUnclippedV4

* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintUnclippedV4:
	move.w	d1,d7
	move.w	Primitive.TYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	Polygon.textureadr,a0
	move.l	(a0,d0.w*4),Polygon.curtexture
	move.l	4(a0,d0.w*4),Polygon.curtexture2
	movea.l	(a2)+,a3
	addq	#2,a1
	addq.w	#1,d7
	lea	(a1,d7.w*2),a4
	moveq	#Vertex.SIZE,d6
	move.w	#$80,d5
	lea	Polygon.polypointTable,a0
	movea.l	a0,a6
	move.w	d7,(a0)+
	subq.w	#1,d7

.vertexloop:
	move.w	(a1)+,d3
	mulu.w	d6,d3
	move.l	(a2,d3.l),(a0)+
	movea.w	(a4)+,a5
	move.l	(a3,a5.l*Vertex2d.SIZE),(a0)+
	move.w	(a4)+,d0
	mulu.w	d6,d0
	movem.w	(a2,d0.l),d0-d1
	add.w	d5,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	dbra	d7,.vertexloop

	movea.l	a6,a1
	move.l	Polygon.v4routadr,a0
	jmp	(a0)


ClipEdges:	MACRO		LeftClipRoutine,RightClipRoutine,TopClipRoutine,BottomClipRoutine
.left_clip:
	btst	#1,.clipflags(pc)
	beq.s	.end_left_clip
	move.w	Viewport.settingsTable+Viewport.XSTART,d0
	lsl.w	#4,d0
	movea.w	d0,a2
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	bsr	\1
	movea.l	(sp)+,a0
	movea.l	(sp)+,a1
	tst.w	(a1)
	beq	.end
.end_left_clip:

.right_clip:
	btst	#0,.clipflags(pc)
	beq.s	.end_right_clip
	move.w	Viewport.settingsTable+Viewport.XEND,d0
	lsl.w	#4,d0
	movea.w	d0,a2
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	bsr	\2
	movea.l	(sp)+,a0
	movea.l	(sp)+,a1
	tst.w	(a1)
	beq.s	.end
.end_right_clip:

.top_clip:
	btst	#3,.clipflags(pc)
	beq.s	.end_top_clip
	move.w	Viewport.settingsTable+Viewport.YSTART,d0
	lsl.w	#4,d0
	movea.w	d0,a2
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	bsr	\3
	movea.l	(sp)+,a0
	movea.l	(sp)+,a1
	tst.w	(a1)
	beq.s	.end
.end_top_clip:

.bottom_clip:
	btst	#2,.clipflags(pc)
	beq.s	.end_bottom_clip
	move.w	Viewport.settingsTable+Viewport.YEND,d0
	lsl.w	#4,d0
	movea.w	d0,a2
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	bsr	\4
	movea.l	(sp)+,a0
	movea.l	(sp)+,a1
	tst.w	(a1)
	beq.s	.end
.end_bottom_clip:
	ENDM

* INPUT:
* a0: polygon
Polygon.clipV0:
	movea.l	a0,a1				* Backup polygon.
	move.w	(a0)+,d7
	subq.w	#1,d7	
	move.w	d7,d6
	movem.w	Viewport.settingsTable+Viewport.XSTART,d1-d4

.loop:	moveq	#0,d5				* Set point clipflags to 0.
	move.w	(a0)+,d0			* d0 := X
.check_left:
	cmp.w	d1,d0				* XSTART
	bge.s	.check_right
	addq.w	#%0010,d5
.check_right:
	cmp.w	d2,d0				* XEND
	blt.s	.end_check_right
	addq.w	#%0001,d5
.end_check_right:
	move.w	(a0)+,d0			* d0 := Y
.check_above:
	cmp.w	d3,d0				* YSTART
	bge.s	.check_under
	ori.w	#%1000,d5
.check_under:
	cmp.w	d4,d0				* YEND
	blt.s	.end_check
	addq.w	#%0100,d5
.end_check:
	move.w	d5,-(sp)
	dbra	d7,.loop

	subq.w	#1,d6
	move.w	(sp)+,d0
	move.w	d0,d1
.poeploop:
	move.w	(sp)+,d2
	or.w	d2,d0
	and.w	d2,d1
	dbra	d6,.poeploop

	tst.w	d1
	bne	.end

	tst.w	d0
	beq	Polygon.paintFlatshaded

	move.b	d0,.clipflags
	movea.l	a1,a6
	move.w	(a1)+,d7
	addq.w	#1,d7
	mulu.w	#2,d7
	subq.w	#1,d7
.scale_up_loop:
	move.w	(a1),d0
	lsl.w	#4,d0
	move.w	d0,(a1)+
	dbra	d7,.scale_up_loop
	movea.l	a6,a1
	lea	Polygon.polypointTable2,a0

	ClipEdges	Polygon.clipV0Left,Polygon.clipV0Right,Polygon.clipV0Top,Polygon.clipV0Bottom

	movea.l	a1,a0
	move.w	(a0)+,d7
	mulu.w	#2,d7
	subq.w	#1,d7
.scale_down_loop:
	move.w	(a0),d0
	asr.w	#4,d0
	move.w	d0,(a0)+
	dbra	d7,.scale_down_loop

	bra	Polygon.paintFlatshaded

.end:	rts

.clipflags:
	DC.W	0

IntersectV0Edge:	MACRO
	sub.w	d2,d3				* dy := y1-y0
	sub.w	d0,d1				* dx := x1-x0
	swap	d3
	sub.w	d3,d3
	ext.l	d1
	divs.l	d1,d3				* slope := dy/dx
	sub.w	a2,d0				* xi := x0-clipx
	neg.w	d0
	ext.l	d0
	muls.l	d0,d3				* dy/dx * -xi
	swap	d3
	tst.l	d3
	bpl.s	.\@no_round
	addq.w	#1,d3
.\@no_round:
	add.w	d2,d3				* Y = dy/dx * -xi + y0
	ENDM

* Clip a v0 polygon against the left side.
* INPUT: a0: destination v0-polygon
*        a1: source v0-polygon
*        a2.l: viewport x start
Polygon.clipV0Left:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	(a1),d0
.check_first:
	cmp.w	a2,d0
	blt.s	.check_second_outside
.check_second_inside:
	move.w	4(a1),d1
	cmp.w	a2,d1
	bge.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	2(a1),d3
	move.w	6(a1),d2
	exg	d0,d1				* swap x0, x1
	IntersectV0Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	addq	#4,a1
	addq.w	#1,d6
	bra.s	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#4,a1
	move.l	(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	4(a1),d1
	cmp.w	a2,d1
	blt.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	2(a1),d2
	move.w	6(a1),d3
	IntersectV0Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.l	4(a1),(a6)+			* Store next X,Y
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#4,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	rts

* Clip a v0 polygon against the right side.
* INPUT: a0: destination v0-polygon
*        a1: source v0-polygon
*        a2.l: viewport x end
Polygon.clipV0Right:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	(a1),d0
.check_first:
	cmp.w	a2,d0
	bge.s	.check_second_outside
* First point is inside.
.check_second_inside:
	move.w	4(a1),d1
	cmp.w	a2,d1
	blt.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	2(a1),d3
	move.w	6(a1),d2
	exg	d0,d1				* swap x0, x1
	IntersectV0Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	addq	#4,a1
	addq.w	#1,d6
	bra.s	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#4,a1
	move.l	(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	4(a1),d1
	cmp.w	a2,d1
	bge.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	2(a1),d2
	move.w	6(a1),d3
	IntersectV0Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.l	4(a1),(a6)+			* Store next X,Y
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#4,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	rts

* Clip a v0 polygon against the top.
* INPUT: a0: destination v0-polygon
*        a1: source v0-polygon
*        a2.l: viewport x start
Polygon.clipV0Top:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	2(a1),d0
.check_first:
	cmp.w	a2,d0
	blt.s	.check_second_outside
.check_second_inside:
	move.w	6(a1),d1
	cmp.w	a2,d1
	bge.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	0(a1),d3
	move.w	4(a1),d2
	exg	d0,d1				* swap y0, y1
	IntersectV0Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	addq	#4,a1
	addq.w	#1,d6
	bra.s	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#4,a1
	move.l	(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	6(a1),d1
	cmp.w	a2,d1
	blt.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	0(a1),d2
	move.w	4(a1),d3
	IntersectV0Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.l	4(a1),(a6)+			* Store next X,Y
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#4,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	rts

* Clip a v0 polygon against the bottom.
* INPUT: a0: destination v0-polygon
*        a1: source v0-polygon
*        a2.l: viewport x start
Polygon.clipV0Bottom:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	2(a1),d0
.check_first:
	cmp.w	a2,d0
	bge.s	.check_second_outside
.check_second_inside:
	move.w	6(a1),d1
	cmp.w	a2,d1
	blt.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	0(a1),d3
	move.w	4(a1),d2
	exg	d0,d1				* swap y0, y1
	IntersectV0Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	addq	#4,a1
	addq.w	#1,d6
	bra.s	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#4,a1
	move.l	(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	6(a1),d1
	cmp.w	a2,d1
	bge.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	0(a1),d2
	move.w	4(a1),d3
	IntersectV0Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.l	4(a1),(a6)+			* Store next X,Y
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#4,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	rts

* Splits a flatshaded polygon up into triangles and paints them.
* INPUT: a1: polygon
;Polygon.paintFlatshaded:

* INPUT:
* a1: v1 polygon
Polygon.clipV1:
	movea.l	a0,a1				* Backup polygon.
	move.w	(a0)+,d7
	subq.w	#1,d7	
	move.w	d7,d6
	movem.w	Viewport.settingsTable+Viewport.XSTART,d1-d4

.loop:	moveq	#0,d5				* Set point clipflags to 0.
	move.w	(a0)+,d0			* d0 := X
.check_left:
	cmp.w	d1,d0				* XSTART
	bpl.s	.check_right
	addq.w	#%0010,d5
.check_right:
	cmp.w	d2,d0				* XEND
	blt.s	.end_check_right
	addq.w	#%0001,d5
.end_check_right:
	move.w	(a0)+,d0			* d0 := Y
.check_above:
	cmp.w	d3,d0				* YSTART
	bpl.s	.check_under
	ori.w	#%1000,d5
.check_under:
	cmp.w	d4,d0				* YEND
	blt.s	.end_check
	addq.w	#%0100,d5
.end_check:
	move.w	d5,-(sp)
	addq	#2,a0
	dbra	d7,.loop

	subq.w	#1,d6
	move.w	(sp)+,d0
	move.w	d0,d1
.poeploop:
	move.w	(sp)+,d2
	or.w	d2,d0
	and.w	d2,d1
	dbra	d6,.poeploop

	tst.w	d1
	bne	.end

	tst.w	d0
	beq	Polygon.paintGouraudshaded

	move.b	d0,.clipflags
	movea.l	a1,a6
	move.w	(a1)+,d7
	addq.w	#1,d7
	mulu.w	#3,d7
	subq.w	#1,d7
.scale_up_loop:
	move.w	(a1),d0
	lsl.w	#4,d0
	move.w	d0,(a1)+
	dbra	d7,.scale_up_loop
	movea.l	a6,a1
	lea	Polygon.polypointTable2,a0

	ClipEdges	Polygon.clipV1Left,Polygon.clipV1Right,Polygon.clipV1Top,Polygon.clipV1Bottom

	movea.l	a1,a0
	move.w	(a0)+,d7
	mulu.w	#3,d7
	subq.w	#1,d7
.scaleloop:
	move.w	(a0),d0
	asr.w	#4,d0
	move.w	d0,(a0)+
	dbra	d7,.scaleloop

	bra	Polygon.paintGouraudshaded

.end:	rts

.clipflags:
	DC.W	0

IntersectV1Edge:	MACRO
	sub.w	d4,d5				* du := u1-u0
	sub.w	d2,d3				* dy := y1-y0
	sub.w	d0,d1				* dx := x1-x0
	swap	d3
	sub.w	d3,d3
	ext.l	d1
	divs.l	d1,d3				* slope := dy/dx
	ext.l	d5
	lsl.l	#8,d5
	divs.w	d1,d5				* uslope : = du/dx
	sub.w	a2,d0				* xi := x0-clipx
	neg.w	d0
	ext.l	d0
	muls.l	d0,d3				* dy/dx * -xi
	muls.w	d0,d5				* du/dx * -xi
	swap	d3
	tst.l	d3
	bpl.s	.\@no_round
	addq.w	#1,d3
.\@no_round:
	ror.l	#8,d5
	tst.l	d5
	bpl.s	.\@no_roundu
	addq.w	#1,d5
.\@no_roundu:
	add.w	d2,d3				* Y = dy/dx * -xi + y0
	add.w	d4,d5				* U = du/dx * -xi + u0
	ENDM

* Clip a v1 polygon against the left side.
* INPUT: a0: destination v1-polygon
*        a1: source v1-polygon
*        a2.l: viewport x start
Polygon.clipV1Left:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	(a1),d0
.check_first:
	cmp.w	a2,d0
	blt.s	.check_second_outside
.check_second_inside:
	move.w	6(a1),d1
	cmp.w	a2,d1
	bge.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	2(a1),d3
	move.w	8(a1),d2
	move.w	4(a1),d5
	move.w	10(a1),d4
	exg	d0,d1				* swap x0, x1
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U.
	addq	#6,a1
	addq.w	#1,d6
	bra.s	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#6,a1
	move.l	(a1),(a6)+
	move.w	4(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	6(a1),d1
	cmp.w	a2,d1
	blt.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	2(a1),d2
	move.w	8(a1),d3
	move.w	4(a1),d4
	move.w	10(a1),d5
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U.
	move.l	6(a1),(a6)+			* Store next X,Y.
	move.w	10(a1),(a6)+			* Store next U.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#6,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.w	4(a0),4(a6)
	rts

* Clip a v1 polygon against the right side.
* INPUT: a0: destination v1-polygon
*        a1: source v1-polygon
*        a2.l: viewport x end
Polygon.clipV1Right:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	(a1),d0
.check_first:
	cmp.w	a2,d0
	bge.s	.check_second_outside
* First point is inside.
.check_second_inside:
	move.w	6(a1),d1
	cmp.w	a2,d1
	blt.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	2(a1),d3
	move.w	8(a1),d2
	move.w	4(a1),d5
	move.w	10(a1),d4
	exg	d0,d1				* swap x0, x1
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U.
	addq	#6,a1
	addq.w	#1,d6
	bra.s	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#6,a1
	move.l	(a1),(a6)+
	move.w	4(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	6(a1),d1
	cmp.w	a2,d1
	bge.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	2(a1),d2
	move.w	8(a1),d3
	move.w	4(a1),d4
	move.w	10(a1),d5
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U.
	move.l	6(a1),(a6)+			* Store next X,Y
	move.w	10(a1),(a6)+			* Store next U.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#6,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.w	4(a0),4(a6)
	rts

* Clip a v1 polygon against the top.
* INPUT: a0: destination v1-polygon
*        a1: source v1-polygon
*        a2.l: viewport x start
Polygon.clipV1Top:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	2(a1),d0
.check_first:
	cmp.w	a2,d0
	blt.s	.check_second_outside
.check_second_inside:
	move.w	8(a1),d1
	cmp.w	a2,d1
	bge.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	0(a1),d3
	move.w	6(a1),d2
	move.w	4(a1),d5
	move.w	10(a1),d4
	exg	d0,d1				* swap y0, y1
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	addq	#6,a1
	addq.w	#1,d6
	bra.s	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#6,a1
	move.l	(a1),(a6)+
	move.w	4(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	8(a1),d1
	cmp.w	a2,d1
	blt.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	0(a1),d2
	move.w	6(a1),d3
	move.w	4(a1),d4
	move.w	10(a1),d5
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	move.l	6(a1),(a6)+			* Store next X,Y
	move.w	10(a1),(a6)+
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#6,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.w	4(a0),4(a6)
	rts

* Clip a v1 polygon against the bottom.
* INPUT: a0: destination v1-polygon
*        a1: source v1-polygon
*        a2.l: viewport x start
Polygon.clipV1Bottom:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	2(a1),d0
.check_first:
	cmp.w	a2,d0
	bge.s	.check_second_outside
.check_second_inside:
	move.w	8(a1),d1
	cmp.w	a2,d1
	blt.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	0(a1),d3
	move.w	6(a1),d2
	move.w	4(a1),d5
	move.w	10(a1),d4
	exg	d0,d1				* swap y0, y1
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	addq	#6,a1
	addq.w	#1,d6
	bra.s	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#6,a1
	move.l	(a1),(a6)+
	move.w	4(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	8(a1),d1
	cmp.w	a2,d1
	bge.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	0(a1),d2
	move.w	6(a1),d3
	move.w	4(a1),d4
	move.w	10(a1),d5
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	move.l	6(a1),(a6)+			* Store next X,Y
	move.w	10(a1),(a6)+			* Store next U.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#6,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.w	4(a0),4(a6)
	rts

* INPUT:
* a0: v2 polygon
Polygon.clipV2:
	movea.l	a0,a1				* Backup polygon.
	move.w	(a0)+,d7
	subq.w	#1,d7	
	move.w	d7,d6
	movem.w	Viewport.settingsTable+Viewport.XSTART,d1-d4

.loop:	moveq	#0,d5				* Set point clipflags to 0.
	move.w	(a0)+,d0			* d0 := X
.check_left:
	cmp.w	d1,d0				* XSTART
	bpl.s	.check_right
	addq.w	#%0010,d5
.check_right:
	cmp.w	d2,d0				* XEND
	blt.s	.end_check_right
	addq.w	#%0001,d5
.end_check_right:
	move.w	(a0)+,d0			* d0 := Y
.check_above:
	cmp.w	d3,d0				* YSTART
	bpl.s	.check_under
	ori.w	#%1000,d5
.check_under:
	cmp.w	d4,d0				* YEND
	blt.s	.end_check
	addq.w	#%0100,d5
.end_check:
	move.w	d5,-(sp)
	addq	#4,a0
	dbra	d7,.loop

	subq.w	#1,d6
	move.w	(sp)+,d0
	move.w	d0,d1
.poeploop:
	move.w	(sp)+,d2
	or.w	d2,d0
	and.w	d2,d1
	dbra	d6,.poeploop

	tst.w	d1
;	bne	.end
	bne	.offscreen

	tst.w	d0
	beq	Polygon.paintTexturemapped

	move.b	d0,.clipflags
	movea.l	a1,a6
	move.w	(a1)+,d7
	addq.w	#1,d7
	mulu.w	#4,d7
	subq.w	#1,d7
.scale_up_loop:
	move.w	(a1),d0
	lsl.w	#4,d0
	move.w	d0,(a1)+
	dbra	d7,.scale_up_loop
	movea.l	a6,a1
	lea	Polygon.polypointTable2,a0

	ClipEdges	Polygon.clipV2Left,Polygon.clipV2Right,Polygon.clipV2Top,Polygon.clipV2Bottom

	movea.l	a1,a0
	move.w	(a0)+,d7
	mulu.w	#4,d7
	subq.w	#1,d7
.scaleloop:
	move.w	(a0),d0
	asr.w	#4,d0
	move.w	d0,(a0)+
	dbra	d7,.scaleloop

	bra	Polygon.paintTexturemapped

.end:	rts
.offscreen:
	rts

.clipflags:
	DC.W	0

IntersectV2Edge:	MACRO
	sub.w	d4,d5				* dv := v1-v0
	ext.l	d5
	lsl.l	#8,d5
	divs.w	d1,d5				* vslope := dv/dx
	muls.w	d0,d5				* dv/dx * -xi
	ror.l	#8,d5
	tst.l	d5
	bpl.s	.\@no_roundu
	addq.w	#1,d5
.\@no_roundu:
	add.w	d4,d5				* V := dv/dx * -xi + v0
	ENDM

* Clip a v2 polygon against the left side.
* INPUT: a0: destination v2-polygon
*        a1: source v2-polygon
*        a2.l: viewport x start
Polygon.clipV2Left:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	(a1),d0
.check_first:
	cmp.w	a2,d0
	blt	.check_second_outside
.check_second_inside:
	move.w	8(a1),d1
	cmp.w	a2,d1
	bge.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	2(a1),d3
	move.w	10(a1),d2
	move.w	4(a1),d5
	move.w	12(a1),d4
	exg	d0,d1				* swap x0, x1
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U.
	move.w	6(a1),d5
	move.w	14(a1),d4
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V.
	addq	#8,a1
	addq.w	#1,d6
	bra	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#8,a1
	move.l	(a1),(a6)+
	move.l	4(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	8(a1),d1
	cmp.w	a2,d1
	blt.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	2(a1),d2
	move.w	10(a1),d3
	move.w	4(a1),d4
	move.w	12(a1),d5
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U.
	move.w	6(a1),d4
	move.w	14(a1),d5
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V.
	move.l	8(a1),(a6)+			* Store next X,Y.
	move.l	12(a1),(a6)+			* Store next U,V.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#8,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.l	4(a0),4(a6)
	rts

* Clip a v2 polygon against the right side.
* INPUT: a0: destination v2-polygon
*        a1: source v2-polygon
*        a2.l: viewport x end
Polygon.clipV2Right:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	(a1),d0
.check_first:
	cmp.w	a2,d0
	bge	.check_second_outside
* First point is inside.
.check_second_inside:
	move.w	8(a1),d1
	cmp.w	a2,d1
	blt.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	2(a1),d3
	move.w	10(a1),d2
	move.w	4(a1),d5
	move.w	12(a1),d4
	exg	d0,d1				* swap x0, x1
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U.
	move.w	6(a1),d5
	move.w	14(a1),d4
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V.
	addq	#8,a1
	addq.w	#1,d6
	bra	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#8,a1
	move.l	(a1),(a6)+
	move.l	4(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	8(a1),d1
	cmp.w	a2,d1
	bge.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	2(a1),d2
	move.w	10(a1),d3
	move.w	4(a1),d4
	move.w	12(a1),d5
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U.
	move.w	6(a1),d4
	move.w	14(a1),d5
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V.
	move.l	8(a1),(a6)+			* Store next X,Y.
	move.l	12(a1),(a6)+			* Store next U,V.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#8,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.l	4(a0),4(a6)
	rts

* Clip a v2 polygon against the top.
* INPUT: a0: destination v2-polygon
*        a1: source v2-polygon
*        a2.l: viewport x start
Polygon.clipV2Top:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	2(a1),d0
.check_first:
	cmp.w	a2,d0
	blt	.check_second_outside
.check_second_inside:
	move.w	10(a1),d1
	cmp.w	a2,d1
	bge.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	0(a1),d3
	move.w	8(a1),d2
	move.w	4(a1),d5
	move.w	12(a1),d4
	exg	d0,d1				* swap x0, x1
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	move.w	6(a1),d5
	move.w	14(a1),d4
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V.
	addq	#8,a1
	addq.w	#1,d6
	bra	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#8,a1
	move.l	(a1),(a6)+
	move.l	4(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	10(a1),d1
	cmp.w	a2,d1
	blt.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	0(a1),d2
	move.w	8(a1),d3
	move.w	4(a1),d4
	move.w	12(a1),d5
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	move.w	6(a1),d4
	move.w	14(a1),d5
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V.
	move.l	8(a1),(a6)+			* Store next X,Y.
	move.l	12(a1),(a6)+			* Store next U,V.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#8,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.l	4(a0),4(a6)
	rts

* Clip a v2 polygon against the bottom.
* INPUT: a0: destination v2-polygon
*        a1: source v2-polygon
*        a2.l: viewport x start
Polygon.clipV2Bottom:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	2(a1),d0
.check_first:
	cmp.w	a2,d0
	bge	.check_second_outside
.check_second_inside:
	move.w	10(a1),d1
	cmp.w	a2,d1
	blt.s	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	0(a1),d3
	move.w	8(a1),d2
	move.w	4(a1),d5
	move.w	12(a1),d4
	exg	d0,d1				* swap y0, y1
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	move.w	6(a1),d5
	move.w	14(a1),d4
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V.
	addq	#8,a1
	addq.w	#1,d6
	bra	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	addq	#8,a1
	move.l	(a1),(a6)+
	move.l	4(a1),(a6)+
	addq.w	#1,d6
	bra.s	.loop_end
.check_second_outside:
	move.w	10(a1),d1
	cmp.w	a2,d1
	bge.s	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	0(a1),d2
	move.w	8(a1),d3
	move.w	4(a1),d4
	move.w	12(a1),d5
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	move.w	6(a1),d4
	move.w	14(a1),d5
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V.
	move.l	8(a1),(a6)+			* Store next X,Y.
	move.l	12(a1),(a6)+			* Store next U,V.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	addq	#8,a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.l	4(a0),4(a6)
	rts

* INPUT:
* a0: v4 polygon
Polygon.clipV4:
	movea.l	a0,a1				* Backup polygon.
	move.w	(a0)+,d7
	subq.w	#1,d7	
	move.w	d7,d6
	movem.w	Viewport.settingsTable+Viewport.XSTART,d1-d4

.loop:	moveq	#0,d5				* Set point clipflags to 0.
	move.w	(a0)+,d0			* d0 := X
.check_left:
	cmp.w	d1,d0				* XSTART
	bpl.s	.check_right
	addq.w	#%0010,d5
.check_right:
	cmp.w	d2,d0				* XEND
	blt.s	.end_check_right
	addq.w	#%0001,d5
.end_check_right:
	move.w	(a0)+,d0			* d0 := Y
.check_above:
	cmp.w	d3,d0				* YSTART
	bpl.s	.check_under
	ori.w	#%1000,d5
.check_under:
	cmp.w	d4,d0				* YEND
	blt.s	.end_check
	addq.w	#%0100,d5
.end_check:
	move.w	d5,-(sp)
	addq	#8,a0
	dbra	d7,.loop

	subq.w	#1,d6
	move.w	(sp)+,d0
	move.w	d0,d1
.poeploop:
	move.w	(sp)+,d2
	or.w	d2,d0
	and.w	d2,d1
	dbra	d6,.poeploop

	tst.w	d1
	bne	.end

	tst.w	d0
	bne.s	.clipped
	move.l	Polygon.v4routadr,a0
	jmp	(a0)

.clipped:
	move.b	d0,.clipflags
	movea.l	a1,a6
	move.w	(a1)+,d7
	addq.w	#1,d7
	mulu.w	#6,d7
	subq.w	#1,d7
.scale_up_loop:
	move.w	(a1),d0
	lsl.w	#4,d0
	move.w	d0,(a1)+
	dbra	d7,.scale_up_loop
	movea.l	a6,a1
	lea	Polygon.polypointTable2,a0

	ClipEdges	Polygon.clipV4Left,Polygon.clipV4Right,Polygon.clipV4Top,Polygon.clipV4Bottom

	movea.l	a1,a0
	move.w	(a0)+,d7
	mulu.w	#6,d7
	subq.w	#1,d7
.scaleloop:
	move.w	(a0),d0
	asr.w	#4,d0
	move.w	d0,(a0)+
	dbra	d7,.scaleloop

	move.l	Polygon.v4routadr,a0
	jmp	(a0)

.end:	rts

.clipflags:
	DC.W	0

IntersectV4Edge:	MACRO	polyPoint1,polyPoint2
	move.w	PolyPoint.V1(\1),d4
	move.w	PolyPoint.V1(\2),d5
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V1.
	move.w	PolyPoint.U2(\1),d4
	move.w	PolyPoint.U2(\2),d5
	IntersectV2Edge
	move.w	d5,(a6)+			* Store U2.
	move.w	PolyPoint.V2(\1),d4
	move.w	PolyPoint.V2(\2),d5
	IntersectV2Edge
	move.w	d5,(a6)+			* Store V2.
	ENDM

* Clip a v4 polygon against the left side.
* INPUT: a0: destination v4-polygon
*        a1: source v4-polygon
*        a2.l: viewport x start
Polygon.clipV4Left:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	PolyPoint.X(a1),d0
.check_first:
	cmp.w	a2,d0
	blt	.check_second_outside
.check_second_inside:
	move.w	PolyPoint.SIZE+PolyPoint.X(a1),d1
	cmp.w	a2,d1
	bge	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	PolyPoint.Y(a1),d3
	move.w	PolyPoint.SIZE+PolyPoint.Y(a1),d2
	move.w	PolyPoint.U1(a1),d5
	move.w	PolyPoint.SIZE+PolyPoint.U1(a1),d4
	exg	d0,d1				* Swap x0, x1.
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U1.
	lea	PolyPoint.SIZE(a1),a3
	IntersectV4Edge	a3,a1
	lea	PolyPoint.SIZE(a1),a1
	addq.w	#1,d6
	bra	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	lea	PolyPoint.SIZE(a1),a1
	move.l	(a1),(a6)+
	move.l	4(a1),(a6)+
	move.l	8(a1),(a6)+
	addq.w	#1,d6
	bra	.loop_end
.check_second_outside:
	move.w	PolyPoint.SIZE+PolyPoint.X(a1),d1
	cmp.w	a2,d1
	blt	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	PolyPoint.Y(a1),d2
	move.w	PolyPoint.SIZE+PolyPoint.Y(a1),d3
	move.w	PolyPoint.U1(a1),d4
	move.w	PolyPoint.SIZE+PolyPoint.U1(a1),d5
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U1.
	lea	PolyPoint.SIZE(a1),a3
	IntersectV4Edge	a1,a3
	move.l	PolyPoint.SIZE(a1),(a6)+		* Store next X,Y.
	move.l	PolyPoint.SIZE+4(a1),(a6)+	* Store next U1,V1.
	move.l	PolyPoint.SIZE+8(a1),(a6)+	* Store next U2,V2.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	lea	PolyPoint.SIZE(a1),a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.l	4(a0),4(a6)
	move.l	8(a0),8(a6)
	rts

* Clip a v4 polygon against the right side.
* INPUT: a0: destination v4-polygon
*        a1: source v4-polygon
*        a2.l: viewport x end
Polygon.clipV4Right:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	PolyPoint.X(a1),d0
.check_first:
	cmp.w	a2,d0
	bge	.check_second_outside
* First point is inside.
.check_second_inside:
	move.w	PolyPoint.SIZE+PolyPoint.X(a1),d1
	cmp.w	a2,d1
	blt	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	PolyPoint.Y(a1),d3
	move.w	PolyPoint.SIZE+PolyPoint.Y(a1),d2
	move.w	PolyPoint.U1(a1),d5
	move.w	PolyPoint.SIZE+PolyPoint.U1(a1),d4
	exg	d0,d1
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U1.
	lea	PolyPoint.SIZE(a1),a3
	IntersectV4Edge	a3,a1
	lea	PolyPoint.SIZE(a1),a1
	addq.w	#1,d6
	bra	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	lea	PolyPoint.SIZE(a1),a1
	move.l	(a1),(a6)+
	move.l	4(a1),(a6)+
	move.l	8(a1),(a6)+
	addq.w	#1,d6
	bra	.loop_end
.check_second_outside:
	move.w	PolyPoint.SIZE+PolyPoint.X(a1),d1
	cmp.w	a2,d1
	bge	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	PolyPoint.Y(a1),d2
	move.w	PolyPoint.SIZE+PolyPoint.Y(a1),d3
	move.w	PolyPoint.U1(a1),d4
	move.w	PolyPoint.SIZE+PolyPoint.U1(a1),d5
	IntersectV1Edge
	move.w	a2,(a6)+			* Store X (=leftx).
	move.w	d3,(a6)+			* Store Y.
	move.w	d5,(a6)+			* Store U1.
	lea	PolyPoint.SIZE(a1),a3
	IntersectV4Edge	a1,a3
	move.l	PolyPoint.SIZE(a1),(a6)+		* Store next X,Y.
	move.l	PolyPoint.SIZE+4(a1),(a6)+	* Store next U1,V1.
	move.l	PolyPoint.SIZE+8(a1),(a6)+	* Store next U2,V2.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	lea	PolyPoint.SIZE(a1),a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.l	4(a0),4(a6)
	move.l	8(a0),8(a6)
	rts

* Clip a v4 polygon against the top.
* INPUT: a0: destination v4-polygon
*        a1: source v4-polygon
*        a2.l: viewport x start
Polygon.clipV4Top:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	PolyPoint.Y(a1),d0
.check_first:
	cmp.w	a2,d0
	blt	.check_second_outside
.check_second_inside:
	move.w	PolyPoint.SIZE+PolyPoint.Y(a1),d1
	cmp.w	a2,d1
	bge	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	PolyPoint.X(a1),d3
	move.w	PolyPoint.SIZE+PolyPoint.X(a1),d2
	move.w	PolyPoint.U1(a1),d5
	move.w	PolyPoint.SIZE+PolyPoint.U1(a1),d4
	exg	d0,d1
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	lea	PolyPoint.SIZE(a1),a3
	IntersectV4Edge	a3,a1
	lea	PolyPoint.SIZE(a1),a1
	addq.w	#1,d6
	bra	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	lea	PolyPoint.SIZE(a1),a1
	move.l	(a1),(a6)+
	move.l	4(a1),(a6)+
	move.l	8(a1),(a6)+
	addq.w	#1,d6
	bra	.loop_end
.check_second_outside:
	move.w	PolyPoint.SIZE+PolyPoint.Y(a1),d1
	cmp.w	a2,d1
	blt	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	PolyPoint.X(a1),d2
	move.w	PolyPoint.SIZE+PolyPoint.X(a1),d3
	move.w	PolyPoint.U1(a1),d4
	move.w	PolyPoint.SIZE+PolyPoint.U1(a1),d5
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	lea	PolyPoint.SIZE(a1),a3
	IntersectV4Edge	a1,a3
	move.l	PolyPoint.SIZE(a1),(a6)+		* Store next X,Y.
	move.l	PolyPoint.SIZE+4(a1),(a6)+	* Store next U1,V1.
	move.l	PolyPoint.SIZE+8(a1),(a6)+	* Store next U2,V2.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	lea	PolyPoint.SIZE(a1),a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.l	4(a0),4(a6)
	move.l	8(a0),8(a6)
	rts

* Clip a v4 polygon against the bottom.
* INPUT: a0: destination v4-polygon
*        a1: source v4-polygon
*        a2.l: viewport x start
Polygon.clipV4Bottom:
	lea	2(a0),a6			* Backup destination address.
	move.w	(a1)+,d7			* Get amount of source points.
	subq.w	#1,d7
	moveq	#0,d6				* Reset amount of destination points.

.loop:	move.w	PolyPoint.Y(a1),d0
.check_first:
	cmp.w	a2,d0
	bge	.check_second_outside
.check_second_inside:
	move.w	PolyPoint.SIZE+PolyPoint.Y(a1),d1
	cmp.w	a2,d1
	blt	.inside
* The source edge goes from inside to outside.
* Write the clipped point.
.clip_inside_outside:
	move.w	PolyPoint.X(a1),d3
	move.w	PolyPoint.SIZE+PolyPoint.X(a1),d2
	move.w	PolyPoint.U1(a1),d5
	move.w	PolyPoint.SIZE+PolyPoint.U1(a1),d4
	exg	d0,d1
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	lea	PolyPoint.SIZE(a1),a3
	IntersectV4Edge	a3,a1
	lea	PolyPoint.SIZE(a1),a1
	addq.w	#1,d6
	bra	.loop_end
* The source edge is inside -> write the first point to the destination.
.inside:
	lea	PolyPoint.SIZE(a1),a1
	move.l	(a1),(a6)+
	move.l	4(a1),(a6)+
	move.l	8(a1),(a6)+
	addq.w	#1,d6
	bra	.loop_end
.check_second_outside:
	move.w	PolyPoint.SIZE+PolyPoint.Y(a1),d1
	cmp.w	a2,d1
	bge	.outside
* The source edge goes from outside to inside.
* Write the clipped point and the inside point as well.
.clipped_outside_inside:
	move.w	PolyPoint.X(a1),d2
	move.w	PolyPoint.SIZE+PolyPoint.X(a1),d3
	move.w	PolyPoint.U1(a1),d4
	move.w	PolyPoint.SIZE+PolyPoint.U1(a1),d5
	IntersectV1Edge
	move.w	d3,(a6)+			* Store X.
	move.w	a2,(a6)+			* Store Y (clipy).
	move.w	d5,(a6)+			* Store U.
	lea	PolyPoint.SIZE(a1),a3
	IntersectV4Edge	a1,a3
	move.l	PolyPoint.SIZE(a1),(a6)+		* Store next X,Y.
	move.l	PolyPoint.SIZE+4(a1),(a6)+	* Store next U1,V1.
	move.l	PolyPoint.SIZE+8(a1),(a6)+	* Store next U2,V2.
	addq.w	#2,d6
* The source edge is outside, don't write.
.outside:
	lea	PolyPoint.SIZE(a1),a1
.loop_end:
	dbra	d7,.loop

	move.w	d6,(a0)+			* Write amount of destination points.
	move.l	(a0),(a6)			* Duplicate first point.
	move.l	4(a0),4(a6)
	move.l	8(a0),8(a6)
	rts

* Splits a flatshaded polygon up into triangles and paints them.
* INPUT: a1: polygon
Polygon.paintFlatshaded:
	move.w	(a1)+,d7
	movem.w	(a1)+,d0-d1
	subq.w	#3,d7
	movem.w	d0-d1,-(sp)

.loop:	movem.w	(a1)+,d2-d3
	movem.w	(a1),d4-d5
	move.w	d7,-(sp)
	move.l	a1,-(sp)
	bsr	PAINT_UNCLIPFLATTRIANGLE
	movea.l	(sp)+,a1
	move.w	(sp)+,d7
	movem.w	(sp),d0-d1
	dbra	d7,.loop
	addq	#4,sp
	rts

* Splits a flatshaded polygon up into triangles and paints them.
* INPUT: a1: polygon
Polygon.paintGouraudshaded:
	move.w	(a1)+,d7
	movem.w	(a1)+,d0-d2
	movea.l	d2,a0
	movem.w	d0/d1/a0,-(sp)
	subq.w	#3,d7

.loop:	movem.w	(a1)+,d2/d3/d6
	movea.l	d6,a2
	movem.w	(a1),d4-d6
	movea.l	d6,a6
	move.w	d7,-(sp)
	move.l	a1,-(sp)
	bsr	PAINT_UNCLIPGRADIENTTRIANGLE
	movea.l	(sp)+,a1
	move.w	(sp)+,d7
	movem.w	(sp),d0/d1/a0
	dbra	d7,.loop
	addq	#6,sp
	rts

* Splits a texturemapped polygon up into triangles and paints them.
* INPUT: a1: polygon
Polygon.paintTexturemapped:
	move.w	(a1)+,d7
	movem.w	(a1)+,d0-d1
	movea.l	(a1)+,a0
	movem.w	d0-d1,-(sp)
	move.l	a0,-(sp)
	subq.w	#3,d7

.loop:	move.w	d7,-(sp)

	movem.w	(a1)+,d2-d3
	movea.l	(a1)+,a3			* Sucky backup.
	move.l	a1,-(sp)

	movem.w	(a1),d4-d7
	swap	d6
	move.w	d7,d6
	movea.l	d6,a2

	movea.l	a3,a1

	bsr	PAINT_UNCLIPTEXTURETRIANGLE
	movea.l	(sp)+,a1
	move.w	(sp)+,d7
	movea.l	(sp),a0
	movem.w	4(sp),d0-d1
	dbra	d7,.loop
	addq	#8,sp
	rts

* Splits an alpha-texturemapped polygon up into triangles and paints them.
* INPUT: a1: polygon
Polygon.paintAlphatextured:
	move.l	#PAINT_UNCLIPALPHASCANS,Fragment.v4routadr
	lea	Polygon.extvertexTable,a0
	move.w	(a1)+,d7
	movem.w	(a1)+,d0-d5
	movem.w	d2-d5,(a0)
	movem.w	d0-d1,-(sp)
	subq.w	#3,d7

.loop:	move.w	d7,-(sp)

	lea	Polygon.extvertexTable+2*4,a0

	movem.w	(a1)+,d2-d3
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	a1,-(sp)

	movem.w	(a1)+,d4-d5
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	lea	-2*4*1(a0),a2
	lea	-2*4*2(a0),a1
	lea	-2*4*3(a0),a0

	bsr	PAINT_UNCLIPV4TRIANGLE
	movea.l	(sp)+,a1
	move.w	(sp)+,d7
	movem.w	(sp),d0-d1
	dbra	d7,.loop
	addq	#4,sp
	rts

* Splits an alpha-texturemapped polygon up into triangles and paints them.
* INPUT: a1: polygon
Polygon.paintBumpmapped:
	move.l	#PAINT_UNCLIPBUMPSCANS,Fragment.v4routadr
	lea	Polygon.extvertexTable,a0
	move.w	(a1)+,d7
	movem.w	(a1)+,d0-d5
	movem.w	d2-d5,(a0)
	movem.w	d0-d1,-(sp)
	subq.w	#3,d7

.loop:	move.w	d7,-(sp)

	lea	Polygon.extvertexTable+2*4,a0

	movem.w	(a1)+,d2-d3
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	a1,-(sp)

	movem.w	(a1)+,d4-d5
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	lea	-2*4*1(a0),a2
	lea	-2*4*2(a0),a1
	lea	-2*4*3(a0),a0

	bsr	PAINT_UNCLIPV4TRIANGLE
	movea.l	(sp)+,a1
	move.w	(sp)+,d7
	movem.w	(sp),d0-d1
	dbra	d7,.loop
	addq	#4,sp
	rts

******** Fragment

			RSRESET
Fragment.LSLOPE:	RS.L	1		* 16:16 fixed point
Fragment.RSLOPE:	RS.L	1		* 16:16 fixed point
Fragment.LX:		RS.W	1		* left X
Fragment.RX:		RS.W	1		* right X
Fragment.LUSTART:	RS.W	1		* 8:8 index
Fragment.LVSTART:	RS.W	1		* 8:8 index
Fragment.RUSTART:	RS.W	1		* 8:8 index
Fragment.RVSTART:	RS.W	1		* 8:8 index
Fragment.LUSLOPE:	RS.W	1		* 8:8 slope
Fragment.LVSLOPE:	RS.W	1		* 8:8 slope
Fragment.RUSLOPE:	RS.W	1		* 8:8 slope
Fragment.RVSLOPE:	RS.W	1		* 8:8 slope
Fragment.START:		RS.W	1		* start scanline of fragment
Fragment.HEIGHT:	RS.W	1		* height of fragment
Fragment.SIZE:		RS.B	0

Fragment.shadeMask:	=	%00000111
Fragment.shadeFlat:	=	%000
Fragment.shadeGradient:	=	%001
Fragment.shadeTexture:	=	%010
Fragment.shadeAlpha:	=	%011
Fragment.shadeBump:	=	%100
Fragment.maskMode:	=	%00001000
Fragment.clipMode:	=	%00010000

* Paints an unclipped triangle. No in-/off-screen check whatsoever!
* Make sure triangle is 100% IN SCREEN!
* INPUT: d0.l: X0
*        d1.l: Y0
*        d2.l: X1
*        d3.l: Y1
*        d4.l: X2
*        d5.l: X2
PAINT_UNCLIPFLATTRIANGLE:
* Sort points in Y-order.
.sort_y:
	cmp.l	d1,d3
	bgt.s	.first_y_ok
	exg	d0,d2
	exg	d1,d3
.first_y_ok:
	cmp.l	d1,d5
	bgt.s	.first_y_ok2
	exg	d0,d4
	exg	d1,d5
.first_y_ok2:
	cmp.l	d3,d5
	bgt.s	.second_y_ok
	exg	d2,d4
	exg	d3,d5
.second_y_ok:
	movea.l	d0,a0
	movea.l	d1,a1
	movea.l	d2,a2
	movea.l	d3,a3
	movea.l	d4,a4
	movea.l	d5,a5
.end_sort_y:

.calc_slopes_height:
* X2-X1 X3-X1 X3-X2
* Y2-Y1 Y3-Y1 Y3-Y2
	sub.l	d2,d4				* X3-X2
	sub.l	d0,d2				* X2-X1
	suba.l	d0,a4				* X3-X1
	move.l	d2,d0
	move.l	a4,d2
	sub.l	d3,d5				* Y3-Y2
	sub.l	d1,d3				* Y2-Y1
	suba.l	d1,a5				* Y3-Y1
	move.l	d3,d1
	move.l	a5,d3
	lea	Polygon.invTable,a6
	muls.w	(a6,d1.l*2),d0
	muls.w	(a6,d3.l*2),d2
	muls.w	(a6,d5.l*2),d4
	add.l	d0,d0
	add.l	d2,d2
	add.l	d4,d4
.end_calcslopes:

* side 1: upper point <-> middle point
* d0.l: 16:16 slope of side 1
* d1.l: height of side 1
* side 2: upper point <-> lower point
* d2.l: 16:16 slope of side 2
* d3.l: height of side 2
* side 3: middle point <-> lower point
* d4.l: 16:16 slope of side 3
* d5.l: heigth of side 3

* Special case for triangles that have a horizontal edge.
	tst.w	d1
	bne.s	.make_fragments
	move.w	d3,d7
	subq.w	#1,d7
	bmi	.end_paint_triangle
	move.l	d4,d3
	move.l	Polygon.color,d4
	moveq	#0,d0
	move.w	a0,d0
	swap	d0
	moveq	#0,d1
	move.w	a2,d1
	swap	d1
	cmp.l	d0,d1
	bgt.s	.start_x_okay
	exg	d0,d1
	exg	d2,d3
.start_x_okay:
	movea.l	Primitive.screenadr,a0
	move.w	a1,d6
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d6
	add.l	d6,d6
	adda.l	d6,a0
	bra	PAINT_UNCLIPFLATFRAGMENT

.make_fragments:
	lea	Polygon.fragmentTable,a6
	cmp.l	d0,d2
	blt.s	.make_fragments_rl

.make_fragments_lr:
	move.l	d4,(a6)+			* Store left slope.
	move.l	d2,(a6)+			* Store right slope.
	move.w	a2,(a6)+			* Store left x.
	move.w	#$8000,(a6)+			* Store right x.
	move.w	a3,(a6)+			* Store y.
	move.w	d5,(a6)+			* Store height.

	move.w	d1,d7
	move.l	Polygon.color,d4
	move.l	d2,d3
	move.l	d0,d2
	moveq	#0,d0
	move.w	a0,d0
	swap	d0
	move.l	d0,d1
	subq.w	#1,d7
	bmi.s	.end_paint_upper_lr
	movea.l	Primitive.screenadr,a0
	move.w	a1,d6
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d6
	add.l	d6,d6
	adda.l	d6,a0
	bsr	PAINT_UNCLIPFLATFRAGMENT
.end_paint_upper_lr:

 	bra.s	.end_make_fragments

.make_fragments_rl:
	move.l	d2,(a6)+			* Store left slope.
	move.l	d4,(a6)+			* Store right slope.
	move.w	#$8000,(a6)+			* Store left x.
	move.w	a2,(a6)+			* Store right x.
	move.w	a3,(a6)+			* Store y.
	move.w	d5,(a6)+			* Store height.

	move.w	d1,d7
	move.l	Polygon.color,d4
	move.l	d0,d3
	moveq	#0,d0
	move.w	a0,d0
	swap	d0
	move.l	d0,d1
	subq.w	#1,d7
	bmi.s	.end_paint_upper_rl
	movea.l	Primitive.screenadr,a0
	move.w	a1,d6
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d6
	add.l	d6,d6
	adda.l	d6,a0
	bsr	PAINT_UNCLIPFLATFRAGMENT
.end_paint_upper_rl:

.end_make_fragments:

.paint_lower_fragment:
;	bra	.end_paint_fragments
	lea	-16(a6),a6
	move.l	(a6)+,d2			* Get left slope.
	move.l	(a6)+,d3			* Get right slope.

.get_new_lx:
	moveq	#0,d7
	move.w	(a6)+,d7			* Get left x.
	cmpi.w	#$8000,d7
	beq.s	.end_get_new_lx
	move.l	d7,d0
	swap	d0
.end_get_new_lx:

.get_new_rx:
	move.w	(a6)+,d7			* Get right x.
	cmpi.w	#$8000,d7
	beq.s	.end_get_new_rx
	move.l	d7,d1
	swap	d1
.end_get_new_rx:

	movea.l	Primitive.screenadr,a0
	move.w	(a6)+,d7			* Get y.
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d7
	add.l	d7,d7
	adda.l	d7,a0
	move.w	(a6)+,d7			* Get height.
	subq.w	#1,d7
	bmi.s	.end_paint_fragments
	bra	PAINT_UNCLIPFLATFRAGMENT
.skip_lower_fragment:
.end_paint_fragments:

.end_paint_triangle:
	rts

* Subroutine that paints a flatshaded fragment.
* Horizontal clipping is implemented.
* Vertical clipping is NOT this routine's responsibility.
* INPUT: d0.l: 16:16 left X-start
*        d1.l: 16:16 right X-start
*        d2.l: 16:16 left stepvalue
*        d3.l: 16:16 right stepvalue
*        d4.l: 16:16 color (double highcolor)
*        d7.w: number of scanlines to paint - 1
*        a0: start of begin screenline
* OUTPUT: a0: start of next screenline
PAINT_UNCLIPFLATFRAGMENT:
	movea.w	Viewport.settingsTable+Viewport.XSCREEN,a5
	adda.l	a5,a5

.scanline_loop:
	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

	sub.w	d5,d6
	subq.w	#1,d6
	bmi.s	.end_scanline
	lea	(a0,d5.w*2),a1

.scanline_pixloop:
	move.w	d4,(a1)+
	dbra	d6,.scanline_pixloop

.end_scanline:
	adda.l	a5,a0
	add.l	d2,d0
	add.l	d3,d1
	dbra	d7,.scanline_loop
	rts

gradientBits:		=	7
gradientSize:		=	1<<(gradientBits+1)

			RSRESET
phongEdgeXSlope:	RS.L	1
phongEdgeISlope:	RS.W	1
phongEdgeXStart:	RS.W	1
phongEdgeYStart:	RS.W	1
phongEdgeIStart:	RS.W	1
phongEdgeDY:		RS.W	1
phongEdgeSize:		RS.B	0

PAINT_UNCLIPGRADIENTTRIANGLE:
	movea.l	a0,a3
	movea.l	a2,a4
	movea.l	a6,a5

* d0.l: X1
* d1.l: Y1
* d2.l: X2
* d3.l: Y2
* d4.l: X3
* d5.l: Y3
* a3: U1
* a4: U2
* a5: U3

* Sort points in Y-order.
.sort_y:
	cmp.l	d1,d3
	bgt.s	.first_y_ok
	exg	d0,d2
	exg	d1,d3
	exg	a3,a4
.first_y_ok:
	cmp.l	d1,d5
	bgt.s	.first_y_ok2
	exg	d0,d4
	exg	d1,d5
	exg	a3,a5
.first_y_ok2:
	cmp.l	d3,d5
	bgt.s	.second_y_ok
	exg	d2,d4
	exg	d3,d5
	exg	a4,a5
.second_y_ok:
.end_sort_y:

.calc_edges:
* edge1 edge2 egde3
* X2-X1 X3-X1 X3-X2
* Y2-Y1 Y3-Y1 Y3-Y2
* I2-I1 I3-I1 I3-I2

	IFNE	1

	lea	Polygon.invTable,a2
	lea	.edges_tbl,a0
	movea.l	a0,a6

	move.l	d2,d6
	move.l	d3,d7
	sub.l	d0,d6
	sub.l	d1,d7

;	swap	d6
;	sub.w	d6,d6
;	tst.l	d7
;	beq.s	.edge0_null
;	divs.l	d7,d6
;.edge0_null:
;	move.l	d6,(a0)+	phongEdgeXSlope(a0)
;	move.l	a4,d6
;	sub.l	a3,d6
;	lsl.l	#8,d6
;	tst.l	d7
;	beq.s	.edge0a_null
;	divs.w	d7,d6
;.edge0a_null:
;	move.w	d6,(a0)+	phongEdgeISlope(a0)
;	;move.w	d0,(a0)+	phongEdgeXStart(a0)
;	;move.w	d1,(a0)+	phongEdgeYStart(a0)
;	;move.w	a3,(a0)+	phongEdgeIStart(a0)
;	move.w	d7,(a0)+	phongEdgeDY(a0)
	muls.w	(a2,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,(a0)+	phongEdgeXSlope(a0)
	move.l	a4,d6
	sub.l	a3,d6
	muls.w	(a2,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,(a0)+	phongEdgeISlope(a0)
	;move.w	d0,(a0)+	phongEdgeXStart(a0)
	;move.w	d1,(a0)+	phongEdgeYStart(a0)
	;move.w	a3,(a0)+	phongEdgeIStart(a0)
	move.w	d7,(a0)+	phongEdgeDY(a0)

	movea.l	a0,a1

	move.l	d4,d6
	move.l	d5,d7
	sub.l	d0,d6
	sub.l	d1,d7

;	swap	d6
;	sub.w	d6,d6
;	tst.l	d7
;	beq.s	.edge1_null
;	divs.l	d7,d6
;.edge1_null:
;	move.l	d6,(a0)+	phongEdgeXSlope(a0)
;	move.l	a5,d6
;	sub.l	a3,d6
;	lsl.l	#8,d6
;	tst.l	d7
;	beq.s	.edge1a_null
;	divs.w	d7,d6
;.edge1a_null:
;	move.w	d6,(a0)+	phongEdgeISlope(a0)
;	;move.w	d0,(a0)+	phongEdgeXStart(a0)
;	;move.w	d1,(a0)+	phongEdgeYStart(a0)
;	;move.w	a3,(a0)+	phongEdgeIStart(a0)
;	addq	#6,a0
;	move.w	d7,(a0)+	phongEdgeDY(a0)
	muls.w	(a2,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,(a0)+	phongEdgeXSlope(a0)
	move.l	a5,d6
	sub.l	a3,d6
	muls.w	(a2,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,(a0)+	phongEdgeISlope(a0)
	;move.w	d0,(a0)+	phongEdgeXStart(a0)
	;move.w	d1,(a0)+	phongEdgeYStart(a0)
	;move.w	a3,(a0)+	phongEdgeIStart(a0)
	addq	#6,a0
	move.w	d7,(a0)+	phongEdgeDY(a0)

* edge 3

	move.l	d4,d6
	move.l	d5,d7
	sub.l	d2,d6
	sub.l	d3,d7
	move.w	d7,(a0)+	phongEdgeDY(a2)

;	swap	d6
;	sub.w	d6,d6
;	tst.l	d7
;	beq.s	.edge2_null
;	divs.l	d7,d6
;.edge2_null:
;	move.l	d6,(a0)+	phongEdgeXSlope(a2)
;	move.l	a5,d6
;	sub.l	a4,d6
;	lsl.l	#8,d6
;	tst.l	d7
;	beq.s	.edge2a_null
;	divs.w	d7,d6
;.edge2a_null:
;	move.w	d2,(a0)+	phongEdgeXStart(a2)
;	move.w	a4,(a0)+	phongEdgeIStart(a2)
;	move.w	d6,(a0)+	phongEdgeISlope(a2)
	muls.w	(a2,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,(a0)+	phongEdgeXSlope(a2)
	move.l	a5,d6
	sub.l	a4,d6
	muls.w	(a2,d7.l*2),d6
	asr.l	#7,d6
	move.w	d2,(a0)+	phongEdgeXStart(a2)
	move.w	a4,(a0)+	phongEdgeIStart(a2)
	move.w	d6,(a0)+	phongEdgeISlope(a2)

	;move.w	d3,(a0)+	phongEdgeYStart(a2)

	lea	-12(a0),a2
	movea.l	a6,a0

* Calculate horizontal intensity slope.
.calcslope:
	cmp.l	d1,d3
	bne.s	.not_edge1
	move.l	d2,d6
	sub.l	d0,d6
	addq.w	#1,d6
	move.l	a4,d7
	sub.l	a3,d7
	bra.s	.end_calcslope
.not_edge1:
	cmp.l	d3,d5
	bne.s	.not_edge3
	move.l	d4,d6
	sub.l	d2,d6
	addq.w	#1,d6
	move.l	a5,d7
	sub.l	a4,d7
	bra.s	.end_calcslope
.not_edge3:

* x_intersect := Edge1Slope * Edge0length + Edge1XStart
	move.l	phongEdgeXSlope(a1),d6

	;moveq	#0,d7
	;move.w	phongEdgeDY(a0),d7
	move.l	d3,d7
	sub.l	d1,d7
	addq.w	#1,d7

	muls.l	d7,d6
	swap	d6
	add.w	d0,d6				; add.w	phongEdgeXStart(a1),d3	* x_intersect
* i_intersect := Edge1ISlope * Edge0length + Edge1IStart
	muls.w	phongEdgeISlope(a1),d7
	asr.l	#8,d7
	add.w	a3,d7 				; add.w	phongEdgeIStart(a1),d4	* i_intersect
* i_horizontalslope := (x_intersect - I2) / (x_intersect - X2)
	sub.w	d2,d6 				; sub.w	phongEdgeXStart(a2),d3
	bmi.s	.fuk
	addq.w	#1,d6
	bra.s	.end_fuk
.fuk:	subq.w	#1,d6
.end_fuk:
	ext.l	d6
	sub.w	a4,d7				; sub.w	phongEdgeIStart(a2),d4
.end_calcslope:
	swap	d7
	sub.w	d7,d7
	divs.l	d6,d7
	swap	d7
	move.l	d7,d3
.end_calc_edges:

* Special case for triangles that have a horizontal edge.
	tst.w	6(a0)		phongEdgeDY(a0)
	bne.s	.make_fragments
	move.w	phongEdgeDY(a1),d7
	subq.w	#1,d7
	bmi	.end
	movea.l	Primitive.screenadr,a0
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d1
	add.l	d1,d1
	adda.l	d1,a0
;	move.w	phongEdgeXStart(a0),d0
	swap	d0
	moveq	#0,d1
	move.w	6(a2),d1		phongEdgeXStart(a2),d1
	swap	d1
	movea.l	phongEdgeXSlope(a1),a5
	movea.l	2(a2),a6		phongEdgeXSlope(a2),a3
	cmp.l	d0,d1
	bgt.s	.left_right
.right_left:
	exg	d0,d1
	exg	a5,a6
	move.w	8(a2),d2		phongEdgeIStart(a2),d2
	swap	d2
	sub.w	d2,d2
	move.w	10(a2),d4		phongEdgeISlope(a2),d4
	bra.s	.start_x_okay
.left_right:
	move.l	a3,d2	move.w	phongEdgeIStart(a1),d2
	swap	d2
	move.w	phongEdgeISlope(a1),d4
.start_x_okay:
	ext.l	d4
	lsl.l	#8,d4
	movea.l	d4,a4
	movea.l	Polygon.gradadr,a1
	movea.l	a5,a2
	movea.l	a6,a3
	bra	PAINT_UNCLIPGRADIENTFRAGMENT

.make_fragments:
	move.l	(a0)+,d6	phongEdgeXSlope(a0),d6
	move.l	phongEdgeXSlope(a1),d7
	cmp.l	d6,d7
	blt	.make_fragments_rl

* a0 /\ a1
*      \
.make_fragments_lr:
	movem.l	d7/a2,-(sp)
* Create upper fragment..
	swap	d0
	move.w	(a0)+,d4	phongEdgeISlope(a0),d4	Fragment.LUSlope(a6)
	ext.l	d4
	lsl.l	#8,d4
	movea.l	d4,a4
	move.l	a3,d2	phongEdgeIStart(a0),d2	Fragment.LUStart(a6)
	swap	d2
	movea.l	d6,a2	Fragment.LSlope(a6)
	movea.l	d7,a3	Fragment.RSlope(a6)
	move.w	(a0)+,d7	phongEdgeDY(a0),d7
	movea.l	Polygon.gradadr,a1
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d1
	add.l	d1,d1
	movea.l	Primitive.screenadr,a0
	adda.l	d1,a0
	move.l	d0,d1
	subq.w	#1,d7
	bmi.s	.lr_skip_upper_fragment
	bsr	PAINT_UNCLIPGRADIENTFRAGMENT
.lr_skip_upper_fragment:
	movem.l	(sp)+,a3/a6

* Create lower fragment..
	move.w	(a6)+,d7	phongEdgeDY(a6),d7	Fragment.height(a6),d7
	subq.w	#1,d7
	bmi.s	.lr_end_paint_triangle
	moveq	#0,d0
	movea.l	(a6)+,a2	phongEdgeXSlope(a6),a2	Fragment.LSlope(a6),a2
	movem.w	(a6)+,d0/d2/d4
	swap	d0
	swap	d2
	lsl.l	#8,d4
	movea.l	d4,a4
	bra	PAINT_UNCLIPGRADIENTFRAGMENT
.lr_end_paint_triangle:
.end:	rts

.make_fragments_rl:
	movem.l	d7/a2,-(sp)
* Create upper fragment..
	swap	d0
	move.w	phongEdgeISlope(a1),d4	Fragment.LUSlope(a6)
	ext.l	d4
	lsl.l	#8,d4
	movea.l	d4,a4
	move.l	a3,d2	phongEdgeIStart(a1),d2	Fragment.LUStart(a6)
	swap	d2
	movea.l	d7,a2	Fragment.LSlope(a6)
	movea.l	d6,a3	Fragment.RSlope(a6)
	move.w	2(a0),d7	phongEdgeDY(a0),d6
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d1
	add.l	d1,d1
	movea.l	Primitive.screenadr,a0
	adda.l	d1,a0
	movea.l	Polygon.gradadr,a1
	move.l	d0,d1
	subq.w	#1,d7
	bmi.s	.rl_skip_upper_fragment
	bsr	PAINT_UNCLIPGRADIENTFRAGMENT
.rl_skip_upper_fragment:
	movem.l	(sp)+,a2/a6

* Create lower fragment..
	move.w	(a6)+,d7	phongEdgeDY(a6),d7	Fragment.height(a6),d7
	subq.w	#1,d7
	bmi.s	.rl_end_paint_triangle
	movea.l	(a6)+,a3	phongEdgeXSlope(a6),a3	Fragment.RSlope(a6),a3
	moveq	#0,d1
	move.w	(a6)+,d1	phongEdgeXStart(a6),d1	Fragment.RX(a6),d7
	swap	d1
	bra	PAINT_UNCLIPGRADIENTFRAGMENT
.rl_end_paint_triangle:
	rts

	ELSE

	lea	.edges_tbl,a0
	movea.l	a0,a6

	move.l	d2,d6
	move.l	d3,d7
	sub.l	d0,d6
	sub.l	d1,d7
	swap	d6
	sub.w	d6,d6
	addq.w	#1,d7
	divs.l	d7,d6
	move.l	d6,(a0)+	phongEdgeXSlope(a0)
	move.l	a4,d6
	sub.l	a3,d6
	lsl.l	#8,d6
	divs.w	d7,d6
	move.w	d6,(a0)+	phongEdgeISlope(a0)
	move.w	d0,(a0)+	phongEdgeXStart(a0)
	move.w	d1,(a0)+	phongEdgeYStart(a0)
	move.w	a3,(a0)+	phongEdgeIStart(a0)
	subq.w	#1,d7
	move.w	d7,(a0)+	phongEdgeDY(a0)

	movea.l	a0,a1

	move.l	d4,d6
	move.l	d5,d7
	sub.l	d0,d6
	sub.l	d1,d7
	swap	d6
	sub.w	d6,d6
	addq.w	#1,d7
	divs.l	d7,d6
	move.l	d6,(a0)+	phongEdgeXSlope(a1)
	move.l	a5,d6
	sub.l	a3,d6
	lsl.l	#8,d6
	divs.w	d7,d6
	move.w	d6,(a0)+	phongEdgeISlope(a1)
	move.w	d0,(a0)+	phongEdgeXStart(a1)
	move.w	d1,(a0)+	phongEdgeYStart(a1)
	move.w	a3,(a0)+	phongEdgeIStart(a1)
	subq.w	#1,d7
	move.w	d7,(a0)+	phongEdgeDY(a1)

	movea.l	a0,a2

	move.l	d4,d6
	move.l	d5,d7
	sub.l	d2,d6
	sub.l	d3,d7
	swap	d6
	sub.w	d6,d6
	addq.w	#1,d7
	divs.l	d7,d6
	move.l	d6,(a0)+	phongEdgeXSlope(a2)
	move.l	a5,d6
	sub.l	a4,d6
	lsl.l	#8,d6
	divs.w	d7,d6
	move.w	d6,(a0)+	phongEdgeISlope(a2)
	move.w	d2,(a0)+	phongEdgeXStart(a2)
	move.w	d3,(a0)+	phongEdgeYStart(a2)
	move.w	a4,(a0)+	phongEdgeIStart(a2)
	subq.w	#1,d7
	move.w	d7,(a0)+	phongEdgeDY(a2)

	movea.l	a6,a0

* Calculate horizontal intensity slope.
.calcslope:
	cmp.l	d1,d3
	bne.s	.not_edge1
	move.l	d2,d6
	sub.l	d0,d6
	addq.w	#1,d6
	move.l	a4,d7
	sub.l	a3,d7
	bra	.end_calcslope
.not_edge1:
	cmp.l	d1,d5
	bne.s	.not_edge2
	move.l	d4,d6
	sub.l	d0,d6
	addq.w	#1,d6
	move.l	a5,d7
	sub.l	a3,d7
	bra.s	.end_calcslope
.not_edge2:
	cmp.l	d3,d5
	bne.s	.not_edge3
	move.l	d4,d6
	sub.l	d2,d6
	addq.w	#1,d6
	move.l	a5,d7
	sub.l	a4,d7
	bra.s	.end_calcslope
.not_edge3:

* x_intersect := Edge1Slope * Edge0length + Edge1XStart
	move.l	phongEdgeXSlope(a1),d6
	moveq	#0,d7
	move.w	phongEdgeDY(a0),d7
	muls.l	d7,d6
	swap	d6
	add.w	d0,d6				; add.w	phongEdgeXStart(a1),d3	* x_intersect
* i_intersect := Edge1ISlope * Edge0length + Edge1IStart
	muls.w	phongEdgeISlope(a1),d7
	asr.l	#8,d7
	add.w	a3,d7 				; add.w	phongEdgeIStart(a1),d4	* i_intersect
* i_horizontalslope := (x_intersect - I2) / (x_intersect - X2)
	sub.w	d2,d6 				; sub.w	phongEdgeXStart(a2),d3
	addq.w	#1,d6
	ext.l	d6
	sub.w	a4,d7				; sub.w	phongEdgeIStart(a2),d4
.end_calcslope:
	IFEQ	useOptiGrad
	swap	d7
	sub.w	d7,d7
	divs.l	d6,d7
	swap	d7
	move.l	d7,d3	.intensityslope
	ELSE
	ext.l	d7
	lsl.l	#8,d7
	divs.w	d6,d7
	move.w	d7,.intensityslope
	ENDC

.end_calc_edges:

.make_fragments:
	lea	.edges_tbl,a0
	move.l	phongEdgeXSlope(a0),d0
	move.l	phongEdgeXSlope(a1),d1
	cmp.l	d0,d1
	blt	.make_fragments_rl

* a0 /\ a1
*      \
.make_fragments_lr:
	movem.l	a1-a2,-(sp)
* Create upper fragment..
	move.w	phongEdgeISlope(a0),d4	Fragment.LUSlope(a6)
	ext.l	d4
	lsl.l	#8,d4
	movea.l	d4,a4
	moveq	#0,d2
	move.w	phongEdgeIStart(a0),d2	Fragment.LUStart(a6)
	swap	d2
	move.l	d0,a2	Fragment.LSlope(a6)
	move.l	d1,a3	Fragment.RSlope(a6)
	moveq	#0,d0
	move.w	phongEdgeXStart(a0),d0
	swap	d0
	moveq	#0,d1
	move.w	phongEdgeXStart(a1),d1	Fragment.RX(a6)
	swap	d1
	move.w	phongEdgeYStart(a0),d6	Fragment.start(a6)
	mulu.w	Viewport.settings_tbl+Viewport.XScreen,d6
	add.l	d6,d6
	move.w	phongEdgeDY(a0),d7
	move.w	phongEdgeDY(a1),d1
	movea.l	Polygon.gradadr,a1
	movea.l	Primitive.screenadr,a0
	adda.l	d6,a0
	cmp.w	d7,d1
	bhs.s	.lrskip
	move.w	d1,d7
.lrskip:
	subq.w	#1,d7
	bmi.s	.lr_skip_upper_fragment
	bsr	PAINT_UNCLIPGRADIENTFRAGMENT
.lr_skip_upper_fragment:
	movem.l	(sp)+,a5-a6

* Create lower fragment..
	move.w	phongEdgeDY(a6),d7	Fragment.height(a6),d7
	subq.w	#1,d7
	bmi.s	.lr_end_paint_triangle
	moveq	#0,d0
	move.w	phongEdgeXStart(a6),d0	Fragment.LX(a6),d7
	swap	d0
	moveq	#0,d2
	move.w	phongEdgeIStart(a6),d2	Fragment.LUStart(a6),d2
	swap	d2
	move.w	phongEdgeISlope(a6),d4	Fragment.LUSlope(a6),d4
	ext.l	d4
	lsl.l	#8,d4
	movea.l	d4,a4
	;movem.l	4(a6),a2-a3
	movea.l	phongEdgeXSlope(a6),a2	Fragment.LSlope(a6),a2
	movea.l	phongEdgeXSlope(a5),a3	Fragment.RSlope(a6),a3
	bra	PAINT_UNCLIPGRADIENTFRAGMENT
.lr_end_paint_triangle:
.end:	rts

.make_fragments_rl:
	movem.l	a1-a2,-(sp)
* Create upper fragment..
	move.w	phongEdgeISlope(a1),d4	Fragment.LUSlope(a6)
	ext.l	d4
	lsl.l	#8,d4
	movea.l	d4,a4
	moveq	#0,d2
	move.w	phongEdgeIStart(a1),d2	Fragment.LUStart(a6)
	swap	d2
	move.l	d1,a2	Fragment.LSlope(a6)
	move.l	d0,a3	Fragment.RSlope(a6)
	moveq	#0,d0
	move.w	phongEdgeXStart(a1),d0
	swap	d0
	moveq	#0,d1
	move.w	phongEdgeXStart(a0),d1	Fragment.RX(a6)
	swap	d1
	move.w	phongEdgeYStart(a1),d6	Fragment.start(a6)
	mulu.w	Viewport.settings_tbl+Viewport.XScreen,d6
	add.l	d6,d6
	move.w	phongEdgeDY(a1),d7
	move.w	phongEdgeDY(a0),d1
	movea.l	Polygon.gradadr,a1
	;move.l	.intensityslope(pc),d3
	movea.l	Primitive.screenadr,a0
	adda.l	d6,a0
	cmp.w	d7,d1
	bhs.s	.rlskip
	move.w	d1,d7
.rlskip:
	subq.w	#1,d7
	bmi.s	.rl_skip_upper_fragment
	bsr	PAINT_UNCLIPGRADIENTFRAGMENT
.rl_skip_upper_fragment:
	movem.l	(sp)+,a5-a6

* Create lower fragment..
	move.w	phongEdgeDY(a6),d7	Fragment.height(a6),d7
	subq.w	#1,d7
	bmi.s	.rl_end_paint_triangle
	moveq	#0,d1
	move.w	phongEdgeXStart(a6),d1	Fragment.RX(a6),d7
	swap	d1
	movea.l	phongEdgeXSlope(a5),a2	Fragment.LSlope(a6),a2
	movea.l	phongEdgeXSlope(a6),a3	Fragment.RSlope(a6),a3
	bra	PAINT_UNCLIPGRADIENTFRAGMENT
.rl_end_paint_triangle:
	rts

	ENDC

	IFNE	0

* BEWARE: high slope only!!!!!!!!!
* TODO: this crap ain't faster at all. Let this stay here for a while till
* some good benchmarks prove it is utter crap or maybe of some importance.
.paint_fragments:
	lea	Polygon.fragmentTable,a6
	movea.l	Primitive.screenadr,a0
	move.w	(a6)+,d5	Fragment.LUSlope(a6),d4
	move.w	(a6)+,d2	Fragment.LUStart(a6),d2
	lsl.w	#8,d2
	movea.l	(a6)+,a2	Fragment.LSlope(a6),a2
	movea.l	(a6)+,a3	Fragment.RSlope(a6),a3
	moveq	#0,d0
	move.w	(a6)+,d0	Fragment.LX(a6),d0
	swap	d0
	moveq	#0,d1
	move.w	(a6)+,d1	Fragment.RX(a6),d1
	swap	d1
	move.w	(a6)+,d7	Fragment.start(a6),d7
	mulu.w	Viewport.settings_tbl+Viewport.XScreen,d7
	add.l	d7,d7
	adda.l	d7,a0

	move.w	.intensityslope(pc),d3
	ext.l	d3
	spl	d6
	bpl.s	.i_pos
	neg.l	d3
.i_pos:	moveq	#0,d2
	move.b	(Primitive.normalizeTable+128*256,d3.l),d7
	lsr.w	#8,d3
	addq.w	#1,d3
	tst.b	d6
	bne.s	.i_was_pos
	neg.l	d3
.i_was_pos:
	add.l	d3,d3					* d3.l: blitstep
	movea.l	Polygon.gouraudtbladr,a1		* 
	add.w	(Primitive.gouraudindexTable,d7.l*2),a1				* d1.w: index of gouraud table
	move.w	(Primitive.gouraudlengthTable,d7.l*2),d4				* d4.w:	scale
* a1: gouraud table for appropriate slope
	mulu.w	d4,d2
	mulu.w	d4,d5
	movea.l	d5,a4

	move.w	(a6)+,d7	Fragment.height(a6),d7
	subq.w	#1,d7
	bmi.s	.skip_upper_fragment
	move.l	a6,-(sp)
	bsr	PAINT_UNCLIPGRADHIGHFRAGMENT
	movea.l	(sp)+,a6
.skip_upper_fragment:

.get_new_x:
	moveq	#0,d7
	move.w	12(a6),d7	Fragment.LX(a6),d7
	cmpi.w	#$8000,d7
	beq.s	.get_new_rx
	move.l	d7,d0
	swap	d0
	move.w	2(a6),d2	Fragment.LUStart(a6),d2
	lsl.w	#8,d2
	mulu.w	d4,d2
.get_new_rx:
	move.w	14(a6),d7	Fragment.RX(a6),d7
	cmpi.w	#$8000,d7
	beq.s	.end_get_x
	move.l	d7,d1
	swap	d1
.end_get_x:

	movem.l	4(a6),a2-a3
	;movea.l	4(a6),a2	Fragment.LSlope(a6),a2
	;movea.l	8(a6),a3	Fragment.RSlope(a6),a3

	mulu.w	(a6),d4	;Fragment.LUSlope(a6),d4
	movea.l	d4,a4

	move.w	18(a6),d7	Fragment.height(a6),d7
	subq.w	#1,d7
	bpl	PAINT_UNCLIPGRADHIGHFRAGMENT
.skip_lower_fragment:
.end_paint_fragments:

.end_paint_triangle:
	rts

	ENDC

.edges_tbl:
	DS.B	phongEdgeSize*3
.intensityslope:
	DS.L	1

useJumpTable:	=	0			* for fast gouraud low slope

* Subroutine that draws a phongfragment to screen.
* Horizontal clipping is NOT implemented.
* Vertical clipping is NOT this routine's responsibility.
* INPUT: d0.l: 16:16 (XXxx) left X-start
*        d1.l: 16:16 (XXxx) right X-start
*        d2.l: 16:16 (IIii) left intensity
*        d3.l: 16:16 (iiII) horizontal intensity-stepvalue
*        d7.w: number of scanlines to paint - 1
*        a0: start of screen scanline
*        a1: color table
*        a2.l: 16:16 (XXxx) left X-stepvalue
*        a3.l: 16:16 (XXxx) right X-stepvalue
*        a4.l: 16:16 (IIii) left intensity-stepvalue
* OUTPUT: a0: start of next scanline entry
PAINT_UNCLIPGRADIENTFRAGMENT:
	move.w	d7,d6
	moveq	#0,d7
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d7
	add.l	d7,d7

.scanline_loop:
	swap	d6
	swap	d1
	move.l	d0,d5
	move.w	d1,d6
	swap	d5
	sub.w	d5,d6
	subq.w	#1,d6
	bmi.s	.end_scanline
	move.l	d2,d4
	swap	d4
	lea	(a0,d5.w*2),a5

.pixelloop:
	move.w	(a1,d4.w*2),(a5)+
	addx.l	d3,d4
	dbra	d6,.pixelloop

.end_scanline:
	swap	d1
	swap	d6
	add.l	a2,d0
	add.l	a3,d1
	add.l	a4,d2
	adda.l	d7,a0
	dbra	d6,.scanline_loop
	rts

* Subroutine that draws a gradientfragment to screen.
* This is a fast version using special prestretched tables.
* Horizontal clipping is NOT implemented.
* Vertical clipping is NOT this routine's responsibility.
* INPUT: d0.l: 16:16 (XXxx) left X-start
*        d1.l: 16:16 (XXxx) right X-start
*        d2.l: 16:16 (IIii) left fractional index
*        d3.l: horizontal intensity-stepvalue
*        d4.w: scale
*        d7.w: number of scanlines to paint - 1
*        a0: start of screen scanline
*        a1: prestretched color table
*        a2.l: 16:16 (XXxx) left X-stepvalue
*        a3.l: 16:16 (XXxx) right X-stepvalue
*        a4.l: 16:16 (IIii) left index-stepvalue
* OUTPUT: a0: start of next scanline entry
PAINT_UNCLIPGRADHIGHFRAGMENT:
	move.w	d7,d6
	moveq	#0,d7
	lea	Viewport.settingsTable,a5
	move.w	Viewport.XSCREEN(a5),d7
	add.l	d7,d7

.scanline_loop:
	swap	d6
	add.l	a2,d0
	add.l	a3,d1
	add.l	a4,d2
	swap	d1

	move.l	d2,d5
	swap	d5
	lea	(a1,d5.w*2),a6

	move.l	d0,d5
	move.w	d1,d6
	swap	d5
	sub.w	d5,d6
	bmi.s	.end_scanline
;	addq.w	#1,d6
	lea	(a0,d5.w*2),a5

	IFEQ	Polygon.USE_BLITGOURAUD

	move.w	d6,d5
	andi.w	#$000f,d5
	neg.w	d5
	lsr.w	#4,d6
	jmp	.jumpend(pc,d5.w*4)

.pixelloop:
	REPT	16
	move.w	(a6),(a5)+
	adda.l	d3,a6
	ENDR
.jumpend:
	dbra	d6,.pixelloop

	ELSE

	moveq	#7,d5
	neg.w	d3				* why this?!?!?! buggy blitter? or buggy brain? =;-)
	move.w	d3,$ffff8a20.w			* source x increment
	move.w	d6,$ffff8a36.w			* words in line

.lineloop:
* Blitter highslope drawing. Kicks ass with standard falcon!
	move.l	a6,$ffff8a24.w			* source address
	move.l	a5,$ffff8a32.w			* destination address
	move.w	#1,$ffff8a38.w			* lines in block
	move.b	#$80,$ffff8a3c.w		* hog=off, blitter=busy

.again:	bset.b	d5,$ffff8a3c.w			* test and set again
	bne.s	.again

	ENDC

.end_scanline:
	swap	d1
	swap	d6
	adda.l	d7,a0
	dbra	d6,.scanline_loop
	rts

.d_scanline:

.d_scanline_loop:
* not implemented yet.
	rts

* Subroutine that draws a gradientfragment to screen.
* This is a fast version using special prestretched tables.
* Horizontal clipping is NOT implemented.
* Vertical clipping is NOT this routine's responsibility.
* INPUT: d0.l: 16:16 (XXxx) left X-start
*        d1.l: 16:16 (IIii) dI start
*        d2.l: 16:16 (IIii) left fractional index
*        d3.l: horizontal intensity-stepvalue
*        d7.w: number of scanlines to paint - 1
*        a0: start of screen scanline
*        a1: prestretched color table
*        a2.l: 16:16 (XXxx) left X-stepvalue
*        a3.l: 16:16 (IIii) dI stepvalue
*        a4.l: 16:16 (IIii) left index-stepvalue
* OUTPUT: a0: start of next scanline entry
PAINT_UNCLIPGRADLOWFRAGMENT:
	move.w	d7,d6
	moveq	#0,d7
	lea	Viewport.settingsTable,a5
	move.w	Viewport.XSCREEN(a5),d7
	add.l	d7,d7

.scanline_loop:
	swap	d6
	add.l	a2,d0
	add.l	a3,d1
	add.l	a4,d2
	swap	d1
	move.l	d0,d5
	move.w	d1,d6
	move.l	d2,d4
	swap	d5
	swap	d4
	sub.w	d5,d6
	bmi.s	.end_scanline
	lea	(a0,d5.w*2),a5
	lea	(a1,d4.w*2),a6

* Plot head.
	moveq	#0,d1
	sub.b	d2,d1
	mulu.w	d3,d1
	swap	d1
	subq.w	#1,d1
	bmi.s	.skip_head
.head_loop:
	move.w	(a6),(a5)+
	dbra	d1,.head_loop
	moveq	#0,d0
	adda.l	a2,a6
.skip_head:

	IFNE	useJumpTable

	cmpi.w	#$000f,d6
	bhs	.jump16
	jsr	.jump_tbl(pc,d6.w*4)

	ELSE

* TODO: Vette _KUTZOOI_ : registers omspitten!!!!
* Move base amount into d6.
.cool_y_loop:
	add.b	d2,d0
	move.w	d5,d6
	addx.b	d7,d6

.cool_loop:
	move.w	(a4),(a0)+
	dbra	d6,.cool_loop

	adda.l	a2,a4
	dbra	d3,.cool_y_loop

	ENDC

* Plot tail.
	andi.w	#$00ff,d0
	mulu.w	d3,d0
	swap	d0
	subq.w	#1,d0
	bmi.s	.skip_tail
.tail_loop:
	move.w	(a6),(a5)+
	dbra	d0,.tail_loop
.skip_tail:

.end_scanline:
	swap	d1
	swap	d6
	adda.l	d7,a0
	dbra	d6,.scanline_loop
	rts

.d_scanline_loop:
* not implemented yet.
	rts

	IFNE	useJumpTable

.jump_tbl:
	DC.L	0			* .loop1
	bra.w	.loop2
	bra.w	.loop3	
	bra.w	.loop4
	bra.w	.loop5	
	bra.w	.loop6
	bra.w	.loop7	
	bra.w	.loop8
	bra.w	.loop9	
	bra.w	.loop10
	bra.w	.loop11
	bra.w	.loop12
	bra.w	.loop13
	bra.w	.loop14
	bra.w	.loop15

.loop2:	add.b	d4,d0
	bcc.s	.skip2
	move.w	(a4),(a0)+
.skip2:	move.w	(a4),(a0)+
	move.w	(a4),(a0)+
	adda.l	a2,a4
	dbra	d3,.loop2
	rts

.loop3:	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip3
	move.w	d1,(a0)+
.skip3:	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	adda.l	a2,a4
	dbra	d3,.loop3
	rts

.loop4:	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip4
	move.w	d1,(a0)+
.skip4:	REPT	4
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop4
	rts

.loop5:	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip5
	move.w	d1,(a0)+
.skip5:	REPT	5
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop5
	rts

.loop6:	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip6
	move.w	d1,(a0)+
.skip6:	REPT	6
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop6
	rts

.loop7:	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip7
	move.w	d1,(a0)+
.skip7:	REPT	7
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop7
	rts

.loop8:	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip8
	move.w	d1,(a0)+
.skip8:	REPT	8
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop8
	rts

.loop9:	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip9
	move.w	d1,(a0)+
.skip9:	REPT	9
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop9
	rts

.loop10:
	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip10
	move.w	d1,(a0)+
.skip10:
	REPT	10
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop10
	rts

.loop11:
	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip11
	move.w	d1,(a0)+
.skip11:
	REPT	11
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop11
	rts

.loop12:
	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip12
	move.w	d1,(a0)+
.skip12:
	REPT	12
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop12
	rts

.loop13:
	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip13
	move.w	d1,(a0)+
.skip13:
	REPT	13
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop13
	rts

.loop14:
	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip14
	move.w	d1,(a0)+
.skip14:
	REPT	14
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop14
	rts

.loop15:
	move.w	(a4),d1
	add.b	d4,d0
	bcc.s	.skip15
	move.w	d1,(a0)+
.skip15:
	REPT	15
	move.w	d1,(a0)+
	ENDR
	adda.l	a2,a4
	dbra	d3,.loop15
	rts

* Beware: d5.w must not be decremented by 1!
* TODO: optimise this crap. totally vacuu-o-sucks!!!!!
.jump16:
.loop16:
	move.w	(a4),d1
	add.b	d4,d0
	move.w	d5,d6
	addx.b	d7,d6
	move.w	d6,d2
	lsr.w	#4,d2
	andi.w	#$000f,d6
	neg.w	d6
	
	jmp	.jumpin(pc,d6.w*2)
.jumploop:
	REPT	16
	move.w	d1,(a0)+
	ENDR
.jumpin:
	dbra	d2,.jumploop

	adda.l	a2,a4
	dbra	d3,.loop16
	rts

	ENDC


		RSRESET
tmapEdgeXSlope:	RS.L	1
tmapEdgeUSlope:	RS.W	1
tmapEdgeVSlope:	RS.W	1
tmapEdgeXStart:	RS.W	1
tmapEdgeYStart:	RS.W	1
tmapEdgeUStart:	RS.W	1
tmapEdgeVStart:	RS.W	1
tmapEdgeDY:	RS.W	1
tmapEdgeSize:	RS.B	0

* Subroutine that draws a textured fragment to a table.
* Vertical and horizontal clipping are NOT this routine's responsibility.
* INPUT: d0.l: 16:16 (XXxx) left X-start
*        d1.l: 16:16 (XXxx) right X-start
*        d2.l: 8:8 (00Uu) left U-start
*        d3.l: 8:8 (00Vv) left V-start
*        a1.l: 16:16 (XXxx) left X-step
*        a2.l: 16:16 (XXxx) right X-step
*        d4.l: 8:8 (00Uu) left U-step
*        d5.l: 8:8 (00Vv) left V-step
*        d7.w: number of scanlines to paint - 1
*        a0: startentry of scanline table
* OUTPUT: a0: start of next scanline entry
DRAW_TEXTUREFRAGMENT:
.scanline_loop:
	move.l	d0,d6				*  2
	swap	d6				*  4
	move.w	d6,(a0)+			* ?8
	move.l	d1,d6				*  2
	swap	d6				*  4
	move.w	d6,(a0)+			* ?8
	move.w	d2,(a0)+			* ?8
	move.w	d3,(a0)+			* ?8
	add.l	a1,d0				*  2
	add.l	a2,d1				*  2
	add.w	d4,d2				*  2
	add.w	d5,d3				*  2
	dbra	d7,.scanline_loop		*  6
						* 58
	rts

PAINT_UNCLIPTEXTURETRIANGLE:
	movea.l	a0,a3
	movea.l	a1,a4
	movea.l	a2,a5

* d0.l: X1
* d1.l: Y1
* d2.l: X2
* d3.l: Y2
* d4.l: X3
* d5.l: Y3
* a3.l: U1:V1
* a4.l: U2:V2
* a5.l: U3:V3

* Sort points in Y-order.
.sort_y:
	cmp.l	d1,d3
	bgt.s	.first_y_ok
	exg	d0,d2
	exg	d1,d3
	exg	a3,a4
.first_y_ok:
	cmp.l	d1,d5
	bgt.s	.first_y_ok2
	exg	d0,d4
	exg	d1,d5
	exg	a3,a5
.first_y_ok2:
	cmp.l	d3,d5
	bgt.s	.second_y_ok
	exg	d2,d4
	exg	d3,d5
	exg	a4,a5
.second_y_ok:
.end_sort_y:

.calc_edges:
* X2-X1 X3-X1 X3-X2
* Y2-Y1 Y3-Y1 Y3-Y2
* I2-I1 I3-I1 I3-I2

	lea	Polygon.invTable,a6

	lea	.edges_tbl,a0
	lea	tmapEdgeSize(a0),a1
	lea	tmapEdgeSize(a1),a2
	move.w	d0,tmapEdgeXStart(a0)
	move.w	d1,tmapEdgeYStart(a0)
	move.l	d2,d6
	move.l	d3,d7
	sub.l	d0,d6
	sub.l	d1,d7
	muls.w	(a6,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,tmapEdgeXSlope(a0)
	move.l	a3,tmapEdgeUStart(a0)		* u,v
	move.l	a4,d6
	move.w	a3,d6
	sub.l	a3,d6
	swap	d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,tmapEdgeUSlope(a0)
	move.w	a4,d6
	sub.w	a3,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,tmapEdgeVSlope(a0)
	move.w	d7,tmapEdgeDY(a0)

;	move.w	d0,tmapEdgeXStart(a1)
;	move.w	d1,tmapEdgeYStart(a1)
	move.l	d4,d6
	move.l	d5,d7
	sub.l	d0,d6
	sub.l	d1,d7
	muls.w	(a6,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,tmapEdgeXSlope(a1)
;	move.l	a3,tmapEdgeUStart(a1)		* u,v
	move.l	a5,d6
	move.w	a3,d6
	sub.l	a3,d6
	swap	d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,tmapEdgeUSlope(a1)
	move.w	a5,d6
	sub.w	a3,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,tmapEdgeVSlope(a1)
;	subq.w	#1,d7
;	move.w	d7,tmapEdgeDY(a1)

	move.w	d2,tmapEdgeXStart(a2)
	move.w	d3,tmapEdgeYStart(a2)
	move.l	d4,d6
	move.l	d5,d7
	sub.l	d2,d6
	sub.l	d3,d7
	muls.w	(a6,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,tmapEdgeXSlope(a2)
	move.l	a4,tmapEdgeUStart(a2)		* u,v
	move.l	a5,d6
	move.w	a4,d6
	sub.l	a4,d6
	swap	d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,tmapEdgeUSlope(a2)
	move.w	a5,d6
	sub.w	a4,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,tmapEdgeVSlope(a2)
	move.w	d7,tmapEdgeDY(a2)
.end_calc_edges:

* Calculate horizontal intensity slope.
.calcslope:
	cmp.l	d1,d3
	bne.s	.not_edge1
	move.l	d2,d7
	sub.l	d0,d7
	addq.w	#1,d7
	move.l	a4,d0
	move.w	a3,d0
	sub.l	a3,d0
	asr.l	#8,d0
	divs.w	d7,d0
	move.w	a4,d1
	sub.w	a3,d1
	ext.l	d1
	lsl.l	#8,d1
	divs.w	d7,d1
	bra.s	.end_calcslope
.not_edge1:
	cmp.l	d3,d5
	bne.s	.not_edge3
	move.l	d4,d7
	sub.l	d2,d7
	addq.w	#1,d7
	move.l	a5,d0
	move.w	a4,d0
	sub.l	a4,d0
	asr.l	#8,d0
	divs.w	d7,d0
	move.w	a5,d1
	sub.w	a4,d1
	ext.l	d1
	lsl.l	#8,d1
	divs.w	d7,d1
	bra.s	.end_calcslope
.not_edge3:

* x_intersect := Edge1Slope * Edge0length + Edge1XStart
	move.l	tmapEdgeXSlope(a1),d7
	moveq	#0,d3
	move.w	tmapEdgeDY(a0),d3
	muls.l	d3,d7
	swap	d7
	add.w	tmapEdgeXStart(a0),d7		a1* x_intersect
* i_intersect := Edge1ISlope * Edge0length + Edge1IStart
	move.w	tmapEdgeUSlope(a1),d0
	move.w	tmapEdgeVSlope(a1),d1
	muls.w	d3,d0
	muls.w	d3,d1
	asr.l	#8,d0
	asr.l	#8,d1
	add.w	tmapEdgeUStart(a0),d0		a1* i_intersect
	add.w	tmapEdgeVStart(a0),d1		a1
* i_horizontalslope := (x_intersect - I2) / (x_intersect - X2)
	sub.w	tmapEdgeXStart(a2),d7
	bmi.s	.fuk
	addq.w	#1,d7
	bra.s	.end_fuk
.fuk:	subq.w	#1,d7
.end_fuk:
	sub.w	tmapEdgeUStart(a2),d0
	sub.w	tmapEdgeVStart(a2),d1
	ext.l	d0
	ext.l	d1
	lsl.l	#8,d0
	lsl.l	#8,d1
	ext.l	d7
	beq.s	.slope0
	divs.w	d7,d0
	divs.w	d7,d1
.slope0:
.end_calcslope:

* d0.w: Uu
* d1.w: Vv
* d7.l: dx

	movem.w	d0/d1,Polygon.uvslopes

* Special case for triangles that have a horizontal edge.
	lea	.edges_tbl,a0
	tst.w	tmapEdgeDY(a0)
	bne.s	.make_fragments
	move.w	tmapEdgeDY(a2),d7
	subq.w	#1,d7
	movea.w	d7,a5
	bmi	.end_paint_triangle
	moveq	#0,d0
	move.w	tmapEdgeXStart(a0),d0
	swap	d0
	moveq	#0,d1
	move.w	tmapEdgeXStart(a2),d1
	swap	d1
	movea.l	tmapEdgeXSlope(a1),a4
	movea.l	tmapEdgeXSlope(a2),a6
	cmp.l	d0,d1
	bgt.s	.left_right
.right_left:
	exg	d0,d1
	exg	a4,a6
	move.w	tmapEdgeUStart(a2),d2
	lsl.w	#8,d2
	move.w	tmapEdgeVStart(a2),d3
	lsl.w	#8,d3
	move.w	tmapEdgeVSlope(a2),d5
	move.w	tmapEdgeUSlope(a2),d4
	bra.s	.start_x_okay
.left_right:
	move.l	a3,d2	tmapEdgeUStart(a1),d2
	sub.w	d2,d2
	lsr.l	#8,d2
	move.w	a3,d3	tmapEdgeVStart(a1),d3
	lsl.w	#8,d3
	moveq	#0,d4
	move.w	tmapEdgeVSlope(a1),d5
	move.w	tmapEdgeUSlope(a1),d4
.start_x_okay:
	movea.l	a4,a1
	movea.l	a6,a2
	movea.w tmapEdgeYStart(a0),a4
	lea	Polygon.scanlineTable,a0
	bsr	DRAW_TEXTUREFRAGMENT
 	bra	.end_draw_fragments

.make_fragments:
	move.l	tmapEdgeXSlope(a0),d0
	move.l	tmapEdgeXSlope(a1),d1
	cmp.l	d0,d1
	blt	.make_fragments_rl

* a0 /\ a1
*      \
.make_fragments_lr:
* Create upper fragment..
	movea.l	a2,a6
	movea.w	tmapEdgeYStart(a0),a4
	move.l	d0,a1
	move.l	d1,a2
	moveq	#0,d0
	move.w	tmapEdgeXStart(a0),d0
	swap	d0
	move.l	d0,d1
	move.w	tmapEdgeUStart(a0),d2
	lsl.w	#8,d2
	move.w	tmapEdgeVStart(a0),d3
	lsl.w	#8,d3
	move.w	tmapEdgeVSlope(a0),d5
	move.w	tmapEdgeUSlope(a0),d4
	move.w	tmapEdgeDY(a0),d7
	subq.w	#1,d7
	movea.w	d7,a5
	lea	Polygon.scanlineTable,a0
	bmi.s	.lr_skip_upper
	bsr	DRAW_TEXTUREFRAGMENT
.lr_skip_upper:

* Create lower fragment..
	move.w	tmapEdgeDY(a6),d7
	adda.w	d7,a5
	moveq	#0,d0
	move.w	tmapEdgeXStart(a6),d0
	swap	d0
	move.w	tmapEdgeUStart(a6),d2
	lsl.w	#8,d2
	move.w	tmapEdgeVStart(a6),d3
	lsl.w	#8,d3
	move.w	tmapEdgeVSlope(a6),d5
	move.w	tmapEdgeUSlope(a6),d4
	movea.l	tmapEdgeXSlope(a6),a1
	subq.w	#1,d7
	bmi.s	.lr_skip_lower
	bsr	DRAW_TEXTUREFRAGMENT
.lr_skip_lower:
 	bra	.end_draw_fragments

.make_fragments_rl:
* Create upper fragment..
	movea.l	a2,a6
	movea.w	tmapEdgeYStart(a0),a4
	move.l	d0,a2
	moveq	#0,d0
	move.w	tmapEdgeXStart(a0),d0
	swap	d0
	move.w	tmapEdgeUStart(a0),d2
	lsl.w	#8,d2
	move.w	tmapEdgeVStart(a0),d3
	lsl.w	#8,d3
	move.w	tmapEdgeVSlope(a1),d5
	move.w	tmapEdgeUSlope(a1),d4
	move.w	tmapEdgeDY(a0),d7
	move.l	d1,a1
	move.l	d0,d1
	subq.w	#1,d7
	movea.w	d7,a5
	lea	Polygon.scanlineTable,a0
	bmi.s	.rl_skip_upper
	bsr	DRAW_TEXTUREFRAGMENT
.rl_skip_upper:

* Create lower fragment..
	move.w	tmapEdgeDY(a6),d7
	adda.w	d7,a5
	moveq	#0,d1
	move.w	tmapEdgeXStart(a6),d1
	swap	d1
	movea.l	tmapEdgeXSlope(a6),a2
	subq.w	#1,d7
	bmi.s	.rl_skip_lower
	bsr	DRAW_TEXTUREFRAGMENT
.rl_skip_lower:
.end_draw_fragments:

	move.w	Polygon.curtexture,d0
	movea.l	Polygon.textureadr,a0
	movea.l	(a0,d0.w*4),a3
	movea.l	Primitive.screenadr,a0
	move.w	a4,d0	;move.w	Polygon.fragmentTable+2+Fragment.START(a6),d0
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d0
	add.l	d0,d0
	adda.l	d0,a0
	lea	Polygon.scanlineTable,a1
	move.w	a5,d7
	bpl.s	PAINT_UNCLIPTEXTURESCANS

.end_paint_triangle:
	rts

	BSS

.edges_tbl:
	DS.B	tmapEdgeSize*3
.step_tbl:
	DS.W	Viewport.MAX_X

	TEXT

* Draws a textured triangle to the screen.
* Horizontal clipping is implemented.
* INPUT: a0: start screenline
*        a1: start entry in scanline table
*        a3: texture
*        d7.w: number of scanlines to paint - 1
PAINT_UNCLIPTEXTURESCANS:
	movem.w	Polygon.uvslopes,d0/d5
	ror.l	#8,d5
	move.l	d5,d1
	move.w	d0,d1
	movea.l	d1,a5
	moveq	#0,d6
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d6
	add.l	d6,d6

.paint_yloop:
	movem.w	(a1)+,d0-d3
* d0.w: left x
* d1.w: right x
* d2.w: left Uu 8:8
* d3.w: left Vv 8:8
	sub.w	d0,d1
	ble.s	.end_paint_yloop
	lea	(a0,d0.l*2),a6
	ror.l	#8,d3
	move.l	d3,d4
	move.w	d2,d4				* d4.l: v0Uu left v, left Uu
	move.b	d3,d2				* d2.b: left V
	subq.w	#1,d1

.paint_xloop:
	move.w	d4,d0
	add.l	a5,d4
	move.b	d2,d0
	addx.b	d5,d2
	move.w	(a3,d0.l*2),(a6)+
	dbra	d1,.paint_xloop

.end_paint_yloop:
	adda.l	d6,a0
	dbra	d7,.paint_yloop
	rts

		RSRESET
v4EdgeXSlope:	RS.L	1
v4EdgeU0Slope:	RS.W	1
v4EdgeV0Slope:	RS.W	1
v4EdgeU1Slope:	RS.W	1
v4EdgeV1Slope:	RS.W	1
v4EdgeXStart:	RS.W	1
v4EdgeYStart:	RS.W	1
v4EdgeU0Start:	RS.W	1
v4EdgeV0Start:	RS.W	1
v4EdgeU1Start:	RS.W	1
v4EdgeV1Start:	RS.W	1
v4EdgeDY:	RS.W	1
v4EdgeSize:	RS.B	0

* Subroutine that draws a v4-textured fragment to a table.
* Vertical and horizontal clipping are NOT this routine's responsibility.
* INPUT:
* d0.l: 8:8:8:8 (000V) left V0-start
* d1.l: 8:8:8:8 (000V) left V1-start
* a5.l: 8:8:8:8 (v0Uu) left U0-step, left V0-step
* d3.l: 8:8:8:8 (000V) left V0-step
* a6.l: 8:8:8:8 (v0Uu) left U1-step, left V1-step
* d5.l: 8:8:8:8 (000V) left V1-step
* d7.w: number of scanlines to paint - 1
* a0: startentry of scanline table
* a1.l: 16:16 (XXxx) left X-start
* a2.l: 16:16 (XXxx) right X-start
* a3.l: 16:16 (XXxx) left X-step
* a4.l: 16:16 (XXxx) right X-step
* d2.l: 8:8:8:8 (v0Uu) left U0-start, left V0-start
* d4.l: 8:8:8:8 (v0Uu) left U1-start, left V1-start
* OUTPUT:
* a0: start of next scanline entry
DRAW_V4FRAGMENT:
.scanline_loop:
	move.l	a1,d6				*  2
	swap	d6				*  4
	move.w	d6,(a0)+			* ?8
	move.l	a2,d6				*  2
	swap	d6				*  4
	move.w	d6,(a0)+			* ?8
	move.w	d2,(a0)+			* ?8
	move.w	d0,(a0)+			* ?8
	move.w	d4,(a0)+			* ?8
	move.w	d1,(a0)+			* ?8
	adda.l	a3,a1				*  2
	adda.l	a4,a2				*  2
	add.w	a5,d2				*  2
	add.w	d3,d0				*  2
	add.w	a6,d4				*  2
	add.w	d5,d1				*  2
	dbra	d7,.scanline_loop		*  6
						* 74
	rts

* INPUT: d0.l: x0
*        d1.l: y0
*        d2.l: x1
*        d3.l: y1
*        d4.l: x2
*        d5.l: y2
*        a0: address of 1st uv-table (u0,v0,u1,v1)
*        a1: address of uv-table (u0,v0,u1,v1)
*        a2: address of uv-table (u0,v0,u1,v1)
PAINT_UNCLIPV4TRIANGLE:
	movea.l	a0,a3
	movea.l	a1,a4
	movea.l	a2,a5

* d0.l: X1
* d1.l: Y1
* d2.l: X2
* d3.l: Y2
* d4.l: X3
* d5.l: Y3
* a3.l: address of 1st uv-table
* a4.l: address of 2nd uv-table
* a5.l: address of 3rd uv-table

* Sort points in Y-order.
.sort_y:
	cmp.l	d1,d3
	bgt.s	.first_y_ok
	exg	d0,d2
	exg	d1,d3
	exg	a3,a4
.first_y_ok:
	cmp.l	d1,d5
	bgt.s	.first_y_ok2
	exg	d0,d4
	exg	d1,d5
	exg	a3,a5
.first_y_ok2:
	cmp.l	d3,d5
	bgt.s	.second_y_ok
	exg	d2,d4
	exg	d3,d5
	exg	a4,a5
.second_y_ok:
.end_sort_y:

.calc_edges:
* X2-X1 X3-X1 X3-X2
* Y2-Y1 Y3-Y1 Y3-Y2
* I2-I1 I3-I1 I3-I2

	lea	Polygon.invTable,a6
	lea	.edges_tbl,a0
	lea	v4EdgeSize(a0),a1
	lea	v4EdgeSize(a1),a2
	move.w	d0,v4EdgeXStart(a0)
	move.w	d1,v4EdgeYStart(a0)
	move.l	d2,d6
	move.l	d3,d7
	sub.l	d0,d6
	sub.l	d1,d7
	muls.w	(a6,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,v4EdgeXSlope(a0)
	move.l	(a3),v4EdgeU0Start(a0)		* u0,v0
	move.l	4(a3),v4EdgeU1Start(a0)		* u1,v1
	move.w	(a4)+,d6
	sub.w	(a3)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeU0Slope(a0)
	move.w	(a4)+,d6
	sub.w	(a3)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeV0Slope(a0)
	move.w	(a4)+,d6
	sub.w	(a3)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeU1Slope(a0)
	move.w	(a4)+,d6
	sub.w	(a3)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeV1Slope(a0)
	subq	#8,a3
	subq	#8,a4
	move.w	d7,v4EdgeDY(a0)

;	move.w	d0,v4EdgeXStart(a1)
;	move.w	d1,v4EdgeYStart(a1)
	move.l	d4,d6
	move.l	d5,d7
	sub.l	d0,d6
	sub.l	d1,d7
	muls.w	(a6,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,v4EdgeXSlope(a1)
;	move.l	a3,v4EdgeUStart(a1)		* u,v
	move.w	(a5)+,d6
	sub.w	(a3)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeU0Slope(a1)
	move.w	(a5)+,d6
	sub.w	(a3)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeV0Slope(a1)
	move.w	(a5)+,d6
	sub.w	(a3)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeU1Slope(a1)
	move.w	(a5)+,d6
	sub.w	(a3)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeV1Slope(a1)
	subq	#8,a3
	subq	#8,a5
;	move.w	d7,v4EdgeDY(a1)

	move.w	d2,v4EdgeXStart(a2)
	move.w	d3,v4EdgeYStart(a2)
	move.l	d4,d6
	move.l	d5,d7
	sub.l	d2,d6
	sub.l	d3,d7
	muls.w	(a6,d7.l*2),d6
	add.l	d6,d6
	move.l	d6,v4EdgeXSlope(a2)
	move.l	(a4),v4EdgeU0Start(a2)		* u0,v0
	move.l	4(a4),v4EdgeU1Start(a2)		* u1,v1
	move.w	(a5)+,d6
	sub.w	(a4)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeU0Slope(a2)
	move.w	(a5)+,d6
	sub.w	(a4)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeV0Slope(a2)
	move.w	(a5)+,d6
	sub.w	(a4)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeU1Slope(a2)
	move.w	(a5)+,d6
	sub.w	(a4)+,d6
	muls.w	(a6,d7.l*2),d6
	asr.l	#7,d6
	move.w	d6,v4EdgeV1Slope(a2)
	subq	#8,a4
	subq	#8,a5
	move.w	d7,v4EdgeDY(a2)
.end_calc_edges:

* Calculate horizontal intensity slope.
.calcslope:
	cmp.l	d1,d3
	bne.s	.not_edge1
	move.l	d2,d7
	sub.l	d0,d7
	addq.w	#1,d7
	move.w	(a4)+,d0
	sub.w	(a3)+,d0
	ext.l	d0
	lsl.l	#8,d0
	divs.w	d7,d0
	move.w	(a4)+,d1
	sub.w	(a3)+,d1
	ext.l	d1
	lsl.l	#8,d1
	divs.w	d7,d1
	move.w	(a4)+,d2
	sub.w	(a3)+,d2
	ext.l	d2
	lsl.l	#8,d2
	divs.w	d7,d2
	move.w	(a4)+,d3
	sub.w	(a3)+,d3
	ext.l	d3
	lsl.l	#8,d3
	divs.w	d7,d3
	bra	.end_calcslope
.not_edge1:
	cmp.l	d3,d5
	bne.s	.not_edge3
	move.l	d4,d7
	sub.l	d2,d7
	addq.w	#1,d7
	move.w	(a5)+,d0
	sub.w	(a4)+,d0
	ext.l	d0
	lsl.l	#8,d0
	divs.w	d7,d0
	move.w	(a5)+,d1
	sub.w	(a4)+,d1
	ext.l	d1
	lsl.l	#8,d1
	divs.w	d7,d1
	move.w	(a5)+,d2
	sub.w	(a4)+,d2
	ext.l	d2
	lsl.l	#8,d2
	divs.w	d7,d2
	move.w	(a5)+,d3
	sub.w	(a4)+,d3
	ext.l	d3
	lsl.l	#8,d3
	divs.w	d7,d3
	bra	.end_calcslope
.not_edge3:

* x_intersect := Edge1Slope * Edge0length + Edge1XStart
	move.l	v4EdgeXSlope(a1),d7
	moveq	#0,d4
	move.w	v4EdgeDY(a0),d4
	muls.l	d4,d7
	swap	d7
	add.w	v4EdgeXStart(a0),d7		a1* x_intersect
* i_intersect := Edge1ISlope * Edge0length + Edge1IStart
	move.w	v4EdgeU0Slope(a1),d0
	move.w	v4EdgeV0Slope(a1),d1
	move.w	v4EdgeU1Slope(a1),d2
	move.w	v4EdgeV1Slope(a1),d3
	muls.w	d4,d0
	muls.w	d4,d1
	muls.w	d4,d2
	muls.w	d4,d3
	asr.l	#8,d0
	asr.l	#8,d1
	asr.l	#8,d2
	asr.l	#8,d3
	add.w	v4EdgeU0Start(a0),d0		a1* i_intersect
	add.w	v4EdgeV0Start(a0),d1		a1
	add.w	v4EdgeU1Start(a0),d2		a1* i_intersect
	add.w	v4EdgeV1Start(a0),d3		a1
* i_horizontalslope := (x_intersect - I2) / (x_intersect - X2)
	sub.w	v4EdgeXStart(a2),d7
	bmi.s	.fuk
	addq.w	#1,d7
	bra.s	.end_fuk
.fuk:	subq.w	#1,d7
.end_fuk:
	sub.w	v4EdgeU0Start(a2),d0
	sub.w	v4EdgeV0Start(a2),d1
	sub.w	v4EdgeU1Start(a2),d2
	sub.w	v4EdgeV1Start(a2),d3
	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3
	lsl.l	#8,d0
	lsl.l	#8,d1
	lsl.l	#8,d2
	lsl.l	#8,d3
	ext.l	d7
	beq.s	.slope0
	divs.w	d7,d0
	divs.w	d7,d1
	divs.w	d7,d2
	divs.w	d7,d3
.slope0:
.end_calcslope:

* d0.w: Uu (0)
* d1.w: Vv (0)
* d2.w: Uu (1)
* d3.w: Vv (1)
* d7.l: dx

	movem.w	d0-d3,Polygon.uvslopes

* Special case for triangles that have a horizontal edge.
	lea	.edges_tbl,a0
	tst.w	v4EdgeDY(a0)
	bne	.make_fragments
	subq	#8,a3
	move.w	v4EdgeDY(a2),d7
	subq.w	#1,d7
	bmi	.end_paint_triangle
	move.w	d7,-(sp)
	moveq	#0,d0
	move.w	v4EdgeXStart(a0),d0
	swap	d0
	moveq	#0,d1
	move.w	v4EdgeXStart(a2),d1
	swap	d1
	move.l	v4EdgeXSlope(a1),d2
	move.l	v4EdgeXSlope(a2),d3
	cmp.l	d0,d1
	bgt.s	.left_right
.right_left:
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	move.w	v4EdgeU0Start(a2),d2
	lsl.w	#8,d2
	move.w	v4EdgeV0Start(a2),d0
	lsl.w	#8,d0
	move.w	v4EdgeU1Start(a2),d4
	lsl.w	#8,d4
	move.w	v4EdgeV1Start(a2),d1
	lsl.w	#8,d1
	move.w	v4EdgeU0Slope(a2),a5
	move.w	v4EdgeV0Slope(a2),d3
	move.w	v4EdgeU1Slope(a2),a6
	move.w	v4EdgeV1Slope(a2),d5
	bra.s	.start_x_okay
.left_right:
	move.l	d3,-(sp)
	move.l	d2,-(sp)
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	move.w	v4EdgeU0Slope(a1),a5
	move.w	v4EdgeV0Slope(a1),d3
	move.w	v4EdgeU1Slope(a1),a6
	move.w	v4EdgeV1Slope(a1),d5
	move.w	(a3)+,d2	v4EdgeU0Start(a1),d2
	lsl.l	#8,d2
	move.w	(a3)+,d0	v4EdgeV0Start(a1),d3
	lsl.w	#8,d0
	move.w	(a3)+,d4	v4EdgeU1Start(a1),d2
	lsl.w	#8,d4
	move.w	(a3)+,d1	v4EdgeV1Start(a1),d3
	lsl.w	#8,d1
.start_x_okay:
	movem.l	(sp)+,a1-a4
	move.w	v4EdgeYStart(a0),-(sp)
	lea	Polygon.scanlineTable,a0
	bsr	DRAW_V4FRAGMENT
 	bra	.end_draw_fragments

.make_fragments:
	move.l	v4EdgeXSlope(a0),d0
	move.l	v4EdgeXSlope(a1),d1
	cmp.l	d0,d1
	blt	.make_fragments_rl

* a0 /\ a1
*      \
.make_fragments_lr:
* Create upper fragment..
	movea.l	a2,a6
	move.w	v4EdgeDY(a0),d7
	subq.w	#1,d7
	move.w	d7,-(sp)
	move.w	v4EdgeYStart(a0),-(sp)
	tst.w	d7
	bmi.s	.lr_skip_upper
	move.l	a6,-(sp)
	move.l	d0,a3
	move.l	d1,a4
	moveq	#0,d0
	move.w	v4EdgeXStart(a0),d0
	swap	d0
	movea.l	d0,a1
	movea.l	d0,a2
	move.w	v4EdgeU0Start(a0),d2
	lsl.w	#8,d2
	move.w	v4EdgeV0Start(a0),d0
	lsl.w	#8,d0
	move.w	v4EdgeU1Start(a0),d4
	lsl.w	#8,d4
	move.w	v4EdgeV1Start(a0),d1
	lsl.w	#8,d1
	move.w	v4EdgeU0Slope(a0),a5
	move.w	v4EdgeV0Slope(a0),d3
	move.w	v4EdgeU1Slope(a0),a6
	move.w	v4EdgeV1Slope(a0),d5
	lea	Polygon.scanlineTable,a0
	bsr	DRAW_V4FRAGMENT
	movea.l	(sp)+,a6
.lr_skip_upper:

* Create lower fragment..
	move.w	v4EdgeDY(a6),d7
	add.w	d7,2(sp)
	moveq	#0,d0
	move.w	v4EdgeXStart(a6),d0
	swap	d0
	movea.l	d0,a1
	movea.l	v4EdgeXSlope(a6),a3
	move.w	v4EdgeU0Start(a6),d2
	lsl.w	#8,d2
	move.w	v4EdgeV0Start(a6),d0
	lsl.w	#8,d0
	move.w	v4EdgeU1Start(a6),d4
	lsl.w	#8,d4
	move.w	v4EdgeV1Start(a6),d1
	lsl.w	#8,d1
	move.w	v4EdgeU0Slope(a6),a5
	move.w	v4EdgeV0Slope(a6),d3
	move.w	v4EdgeV1Slope(a6),d5
	move.w	v4EdgeU1Slope(a6),a6
	subq.w	#1,d7
	bmi.s	.lr_skip_lower
	bsr	DRAW_V4FRAGMENT
.lr_skip_lower:
 	bra	.end_draw_fragments

.make_fragments_rl:
* Create upper fragment..
	movea.l	d0,a4
	movea.l	d1,a3
	move.w	v4EdgeDY(a0),d7
	subq.w	#1,d7
	move.w	d7,-(sp)
	move.w	v4EdgeYStart(a0),-(sp)
	tst.w	d7
	bmi.s	.rl_skip_upper
	move.l	a2,-(sp)
	moveq	#0,d6
	move.w	v4EdgeXStart(a0),d6
	swap	d6
	movea.l	d6,a2
	move.w	v4EdgeU0Start(a0),d2
	lsl.w	#8,d2
	move.w	v4EdgeV0Start(a0),d0
	lsl.w	#8,d0
	move.w	v4EdgeU1Start(a0),d4
	lsl.w	#8,d4
	move.w	v4EdgeV1Start(a0),d1
	lsl.w	#8,d1
	move.w	v4EdgeU0Slope(a1),a5
	move.w	v4EdgeV0Slope(a1),d3
	move.w	v4EdgeU1Slope(a1),a6
	move.w	v4EdgeV1Slope(a1),d5
	movea.l	a2,a1
	lea	Polygon.scanlineTable,a0
	bsr	DRAW_V4FRAGMENT
	movea.l	(sp)+,a2
.rl_skip_upper:

* Create lower fragment..
	move.w	v4EdgeDY(a2),d7
	add.w	d7,2(sp)
	moveq	#0,d6
	move.w	v4EdgeXStart(a2),d6
	swap	d6
	movea.l	v4EdgeXSlope(a2),a4
	movea.l	d6,a2
	subq.w	#1,d7
	bmi.s	.rl_skip_lower
	bsr	DRAW_V4FRAGMENT
.rl_skip_lower:
.end_draw_fragments:

	movea.l	Primitive.screenadr,a0
	move.w	(sp)+,d0				* Get Y start of triangle.
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d0
	add.l	d0,d0
	adda.l	d0,a0
	lea	Polygon.scanlineTable,a1
	move.w	(sp)+,d7
	bmi.s	.end_paint_triangle
	movea.l	Fragment.v4routadr,a3
	movem.w	Polygon.uvslopes,d0-d3
	ror.l	#8,d1
	move.l	d1,d4
	move.w	d0,d4
	movea.l	d4,a2
	ror.l	#8,d3
	move.l	d3,d4
	move.w	d2,d4
	movea.l	d4,a5
	move.w	d3,d6
	swap	d6
	move.w	d1,d6
	jmp	(a3)

.end_paint_triangle:
	rts

	BSS

.edges_tbl:
	DS.B	v4EdgeSize*3

	TEXT
	
* Draws a mixed-texture triangle to the screen.
* Horizontal clipping is implemented.
* INPUT: a0: start screenline
*        a1: start entry in scanline table
*        d7.w: number of scanlines to paint - 1
PAINT_UNCLIPALPHASCANS:
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d0
	add.w	d0,d0
	move.w	d0,-(sp)
	movem.l	Polygon.curtexture,a3/a4
	movea.l	Polygon.alphatableadr,a6

.paint_yloop:
	swap	d7
	move.l	a0,-(sp)
	movem.w	(a1)+,d0/d1
	lea	(a0,d0.l*2),a0
	sub.w	d0,d1
	moveq	#0,d2
	move.w	(a1)+,d0
	move.w	(a1)+,d2
	ror.l	#8,d2
	move.l	d2,d4
	move.w	d0,d4
	move.w	(a1)+,d0
	move.w	(a1)+,d3
	ror.l	#8,d3
	move.l	d3,d5
	move.w	d0,d5
	subq.w	#1,d1
	bmi.s	.end_paint_yloop

.paint_xloop:
	move.w	d4,d0
	add.l	a2,d4
	move.b	d2,d0
	addx.b	d6,d2
	move.w	(a3,d0.l),d7
	move.w	d5,d0
	add.l	a5,d5
	move.b	d3,d0
	swap	d6
	addx.b	d6,d3
	swap	d6
	move.b	(a4,d0.l),d7
	move.w	(a6,d7.w*2),(a0)+
	dbra	d1,.paint_xloop

.end_paint_yloop:
	movea.l	(sp)+,a0
	adda.w	(sp),a0
	swap	d7
	dbra	d7,.paint_yloop
	addq	#2,sp
	rts

* Draws a bump-textured triangle to the screen.
* Horizontal clipping is implemented.
* INPUT: a0: start screenline
*        a1: start entry in scanline table
*        d7.w: number of scanlines to paint - 1
PAINT_UNCLIPBUMPSCANS:
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d0
	add.w	d0,d0
	move.w	d0,-(sp)
	movem.l	Polygon.curtexture,a3/a4
	exg	a3,a4

.paint_yloop:
	swap	d7
	move.l	a0,-(sp)
	movem.w	(a1)+,d0/d1
	lea	(a0,d0.l*2),a0
	sub.w	d0,d1
	moveq	#0,d2
	move.w	(a1)+,d0
	move.w	(a1)+,d2
	ror.l	#8,d2
	move.l	d2,d4
	move.w	d0,d4
	move.w	(a1)+,d0
	move.w	(a1)+,d3
	ror.l	#8,d3
	move.l	d3,d5
	move.w	d0,d5
	subq.w	#1,d1
	bmi.s	.end_paint_yloop

.paint_xloop:
	move.w	d4,d0
	add.l	a2,d4
	move.b	d2,d0
	addx.b	d6,d2
	move.w	(a4,d0.l*2),d7
	move.w	d5,d0
	add.l	a5,d5
	move.b	d3,d0
	swap	d6
	addx.b	d6,d3
	swap	d6
	add.w	d7,d0
	move.w	(a3,d0.l*2),(a0)+
	dbra	d1,.paint_xloop

.end_paint_yloop:
	movea.l	(sp)+,a0
	adda.w	(sp),a0
	swap	d7
	dbra	d7,.paint_yloop
	addq	#2,sp
	rts

	IFNE	0

* Subroutine that paints a flatshaded fragment.
* Horizontal clipping is implemented.
* Vertical clipping is NOT this routine's responsibility.
* INPUT: d0.l: 16:16 left X-start
*        d1.l: 16:16 right X-start
*        d2.l: 16:16 left stepvalue
*        d3.l: 16:16 right stepvalue
*        d4.l: 16:16 color (double highcolor)
*        d7.w: number of scanlines to paint - 1
*        a0: start of begin screenline
*        a2: maskbuffer
* OUTPUT: a0: start of next screenline
PAINTM_UNCLIPFLATFRAGMENT:
	movea.w	Viewport.settingsTable+Viewport.XSCREEN,a5
	lea	Fragment.leftmaskTable,a3
	lea	Fragment.rightmaskTable,a4
	adda.l	a5,a5
.scanline_loop:
	add.l	d2,d0
	add.l	d3,d1
	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

	movea.w	d5,a5
	movea.w	d6,a6
	swap	d7
	move.w	d6,d7
	sub.w	d5,d7
	lsr.w	#4,d5					* left word in mask-line.
	lsr.w	#4,d6					* right word in mask-line.
	sub.w	d5,d6					* dWords
	subq.w	#1,d7
	bmi.s	.end_scanline
	lea	(a0,d5.w*2),a1

.scanline_pixloop:
	move.w	d4,(a1)+
	dbra	d7,.scanline_pixloop

.end_scanline:
	adda.l	a5,a0
	swap	d7
	dbra	d7,.scanline_loop
	rts

PAINTM_UNCLIPGRADIENTFRAGMENT:
	rts

PAINTM_UNCLIPTEXTURESCANS:
	rts

PAINTM_UNCLIPALPHASCANS:
	rts

PAINTM_UNCLIPBUMPSCANS:
	rts

	ENDC

******** Sprite

* INPUT:
* a1: sprite structure
* a2: vertex table
Sprite.paint:
	move.l	Polygon.textureadr,a0
	move.w	Primitive.SPRITETYPE(a1),d0
	move.w	d0,d3
	andi.w	#Primitive.TEXTUREMASK,d0
	andi.w	#Primitive.SHADEMASK,d3
	movea.l	(a0,d0.w*4),a0
* a0: address of sprite-data.
	move.w	Sprite.VERTEX(a1),d0
	mulu.w	#Vertex.SIZE,d0
	movem.w	4(a2,d0.l),d0-d2
* d0.l: X
* d1.l: Y
* d2.l: Z
	movea.l	a0,a1
	movea.l	Primitive.screenadr,a0
	movea.w	Viewport.settingsTable+Viewport.XSCREEN,a6
	adda.l	a6,a6
	cmpi.w	#Sprite.REPLACED,d3
	beq.s	Sprite.paintReplaced
	cmpi.w	#Sprite.MIXED,d3
	beq	Sprite.paintMixed
	rts

* Paints a highcolor rle sprite to the screen.
* This handles horizontal and vertical clipping as well.
* INPUT:
* d0.w: x position (mid)
* d1.w: y position (mid)
* a0: screen
* a1: sprite
* a6.l: screenwidth (bytes)
Sprite.paintReplaced:
	move.w	(a1)+,d6			* width of sprite
	move.w	(a1)+,d7			* height of sprite
	move.w	d6,d4
	lsr.w	#1,d4
	sub.w	d4,d0
	move.w	d7,d4
	lsr.w	#1,d4
	sub.w	d4,d1
	movem.w	Viewport.settingsTable+Viewport.XSTART,d4/d5/a4/a5
	movea.l	a1,a3
	lea	(a1,d7.w*2),a1

* d0.w: left x coordinate of sprite
* d1.w: top y coordinate of sprite
* d6.w: width of sprite
* d7.w: height of sprite

.clip_bottom:
	cmp.w	a5,d1				* YEnd
	bge	.end				* Beneath bottom?
	move.w	d1,d2
	add.w	d7,d2				* d2 := bottom line of sprite
	cmp.w	a5,d2
	blt.s	.end_clip_bottom
	move.w	d2,d3
	sub.w	a5,d3
	sub.w	d3,d7
.end_clip_bottom:

.clip_top:
	cmp.w	a4,d1				* YStart
	bge.s	.end_clip_top	
	cmp.w	a4,d2
	ble	.end				* Above top?
	move.w	d2,d7
	sub.w	a4,d7
	sub.w	a4,d1
	neg.w	d1
	lea	(a3,d1.w*2),a3
	move.w	a4,d1
.end_clip_top:

* d1.w: top y coordinate of sprite
* d7.w: height of sprite

.clip_left:
	moveq	#0,d3
	move.w	d0,d2
	add.w	d6,d2				* d2 := left x of sprite
	cmp.w	d4,d0				* XStart
	bgt.s	.end_clip_left
	cmp.w	d4,d2				* XStart
	ble	.end				* Left of viewport?
	move.w	d0,d3
	sub.w	d4,d3
	neg.w	d3
	move.w	d4,d0
.end_clip_left:

.clip_right:
	cmp.w	d5,d0				* XEnd
	bge	.end				* Right of viewport?
	cmp.w	d5,d2
	ble.s	.end_clip_right
	sub.w	d5,d2
	sub.w	d2,d6
.end_clip_right:

* d0.w: left x coordinate of sprite
* d3.w: number of left pixels to skip
* d6.w: number of pixels in spriteline

	move.w	d3,d2
	move.l	a6,d5
	mulu.w	d1,d5
	adda.l	d5,a0
	lea	(a0,d0.w*2),a0
	subq.w	#1,d7
	move.w	#$7fff,d0

.yloop:	moveq	#0,d1
	move.w	(a3)+,d1
	lea	(a1,d1.w),a4
	movea.l	a0,a2
	moveq	#0,d5				* linesize := 0

.skip_blocks:
	tst.w	d2
	beq.s	.end_handle_leftover

.skip_block_loop:
	move.w	(a4)+,d4
	move.w	d4,d3
	and.w	d0,d3
	add.w	d3,d5				* linesize := linesize + blocksize
	cmp.w	d5,d2
	ble.s	.end_skip_blocks
	cmp.w	d0,d4
	blo.s	.skip_unmasked
.skip_masked:
	lea	(a4,d3.w*2),a4			* Skip <d3> pixels.
.skip_unmasked:
	bra.s	.skip_block_loop
.end_skip_blocks:

.handle_leftover:
	move.w	d5,d1
	sub.w	d2,d1
	cmp.w	d0,d4
	blo.s	.leftover_unmasked
.leftover_masked:
	sub.w	d1,d3
	lea	(a4,d3.w*2),a4			* Skip <d3> pixels.
	subq.w	#1,d1
	bmi.s	.end_handle_leftover
.leftover_loop:
	move.w	(a4)+,(a2)+
	dbra	d1,.leftover_loop
	bra.s	.end_handle_leftover
.leftover_unmasked:
	lea	(a2,d1.w*2),a2			* Skip <d1> pixels.
.end_handle_leftover:

.block_loop:
	move.w	(a4)+,d4
	move.w	d4,d3
	and.w	d0,d3
	add.w	d3,d5				* linesize := linesize + blocksize
	cmp.w	d5,d6
	ble.s	.end_block_loop
	cmp.w	d0,d4
	blo.s	.unmasked
.masked:
	subq.w	#1,d3
.masked_loop:
	move.w	(a4)+,(a2)+
	dbra	d3,.masked_loop
	bra.s	.next_block
.unmasked:
	lea	(a2,d3.w*2),a2			* Skip <d3> pixels.
.next_block:
	bra.s	.block_loop
.end_block_loop:

* Not left-over, but "right-over", get it? RIght-Over?!? Ghweheheheh.
.handle_rightover:
	sub.w	d6,d5
	beq.s	.rightover_ok
	sub.w	d5,d3
	beq.s	.end_handle_rightover
.rightover_ok:
	cmp.w	d0,d4
	blo.s	.rightover_unmasked
.rightover_masked:
	subq.w	#1,d3
.rightover_masked_loop:
	move.w	(a4)+,(a2)+
	dbra	d3,.rightover_masked_loop
.rightover_unmasked:
.end_handle_rightover:

.next_line:
	adda.l	a6,a0
	dbra	d7,.yloop

.end:	rts

* Paints a highcolor rle sprite to the screen.
* This handles horizontal and vertical clipping as well.
* Note: sprites _must_ be half intensity!
* INPUT:
* d0.w: x position (mid)
* d1.w: y position (mid)
* a0: screen
* a1: sprite
* a6.l: screenwidth (bytes)
Sprite.paintMixed:
	move.w	(a1)+,d6			* width of sprite
	move.w	(a1)+,d7			* height of sprite
	move.w	d6,d4
	lsr.w	#1,d4
	sub.w	d4,d0
	move.w	d7,d4
	lsr.w	#1,d4
	sub.w	d4,d1
	movem.w	Viewport.settingsTable+Viewport.XSTART,d4/d5/a4/a5
	movea.l	a1,a3
	lea	(a1,d7.w*2),a1

* d0.w: left x coordinate of sprite
* d1.w: top y coordinate of sprite
* d6.w: width of sprite
* d7.w: height of sprite

.clip_bottom:
	cmp.w	a5,d1				* YEnd
	bge	.end				* Beneath bottom?
	move.w	d1,d2
	add.w	d7,d2				* d2 := bottom line of sprite
	cmp.w	a5,d2
	blt.s	.end_clip_bottom
	move.w	d2,d3
	sub.w	a5,d3
	sub.w	d3,d7
.end_clip_bottom:

.clip_top:
	cmp.w	a4,d1				* YStart
	bge.s	.end_clip_top	
	cmp.w	a4,d2
	ble	.end				* Above top?
	move.w	d2,d7
	sub.w	a4,d7
	sub.w	a4,d1
	neg.w	d1
	lea	(a3,d1.w*2),a3
	move.w	a4,d1
.end_clip_top:

* d1.w: top y coordinate of sprite
* d7.w: height of sprite

.clip_left:
	moveq	#0,d3
	move.w	d0,d2
	add.w	d6,d2				* d2 := left x of sprite
	cmp.w	d4,d0				* XStart
	bgt.s	.end_clip_left
	cmp.w	d4,d2				* XStart
	ble	.end				* Left of viewport?
	move.w	d0,d3
	sub.w	d4,d3
	neg.w	d3
	move.w	d4,d0
.end_clip_left:

.clip_right:
	cmp.w	d5,d0				* XEnd
	bge	.end				* Right of viewport?
	cmp.w	d5,d2
	ble.s	.end_clip_right
	sub.w	d5,d2
	sub.w	d2,d6
.end_clip_right:

* d0.w: left x coordinate of sprite
* d3.w: number of left pixels to skip
* d6.w: number of pixels in spriteline

	move.w	d3,d2
	move.l	a6,d5
	mulu.w	d1,d5
	adda.l	d5,a0
	lea	(a0,d0.w*2),a0
	subq.w	#1,d7
	move.w	#$7fff,d0
	move.w	#%0111101111101111,d4

.yloop:	moveq	#0,d1
	move.w	(a3)+,d1
	lea	(a1,d1.w),a4
	movea.l	a0,a2
	moveq	#0,d5				* linesize := 0

.skip_blocks:
	tst.w	d2
	beq.s	.end_handle_leftover

.skip_block_loop:
	move.w	(a4)+,a5
	move.w	a5,d3
	and.w	d0,d3
	add.w	d3,d5				* linesize := linesize + blocksize
	cmp.w	d5,d2
	ble.s	.end_skip_blocks
	cmp.w	d0,a5
	blo.s	.skip_unmasked
.skip_masked:
	lea	(a4,d3.w*2),a4			* Skip <d3> pixels.
.skip_unmasked:
	bra.s	.skip_block_loop
.end_skip_blocks:

.handle_leftover:
	move.w	d5,d1
	sub.w	d2,d1
	cmp.w	d0,a5
	blo.s	.leftover_unmasked
.leftover_masked:
	sub.w	d1,d3
	lea	(a4,d3.w*2),a4			* Skip <d3> pixels.
	subq.w	#1,d1
	bmi.s	.end_handle_leftover
.leftover_loop:
	move.w	(a2),d3
	lsr.w	#1,d3
	and.w	d4,d3
	add.w	(a4)+,d3
	move.w	d3,(a2)+
	dbra	d1,.leftover_loop
	bra.s	.end_handle_leftover
.leftover_unmasked:
	lea	(a2,d1.w*2),a2			* Skip <d1> pixels.
.end_handle_leftover:

.block_loop:
	move.w	(a4)+,a5
	move.w	a5,d3
	and.w	d0,d3
	add.w	d3,d5				* linesize := linesize + blocksize
	cmp.w	d5,d6
	ble.s	.end_block_loop
	cmp.w	d0,a5
	blo.s	.unmasked
.masked:
	subq.w	#1,d3
.masked_loop:
	move.w	(a2),d1
	lsr.w	#1,d1
	and.w	d4,d1
	add.w	(a4)+,d1
	move.w	d1,(a2)+
	dbra	d3,.masked_loop
	bra.s	.next_block
.unmasked:
	lea	(a2,d3.w*2),a2			* Skip <d3> pixels.
.next_block:
	bra.s	.block_loop
.end_block_loop:

* Not left-over, but "right-over", get it? RIght-Over?!? Ghweheheheh.
.handle_rightover:
	sub.w	d6,d5
	beq.s	.rightover_ok
	sub.w	d5,d3
	beq.s	.end_handle_rightover
.rightover_ok:
	cmp.w	d0,a5
	blo.s	.rightover_unmasked
.rightover_masked:
	subq.w	#1,d3
.rightover_masked_loop:
	move.w	(a2),d1
	lsr.w	#1,d1
	and.w	d4,d1
	add.w	(a4)+,d1
	move.w	d1,(a2)+
	dbra	d3,.rightover_masked_loop
.rightover_unmasked:
.end_handle_rightover:

.next_line:
	adda.l	a6,a0
	dbra	d7,.yloop

.end:	rts

******** Line

* INPUT:
* a1: line structure
* a2: vertex table
Line.paint:
	addq	#4,a2
	move.w	d0,d4
	move.w	Line.VERTEX1(a1),d5
	moveq	#Vertex.SIZE,d7
	move.w	Line.VERTEX2(a1),d6
	mulu.w	d7,d5
	mulu.w	d7,d6
	movem.w	(a2,d5.l),d0-d1
	movem.w	(a2,d6.l),d2-d3
	andi.w	#Primitive.SHADEMASK,d4
	cmpi.w	#Line.FLATSHADED,d4
	beq.s	Line.paintFlatshaded
	cmpi.w	#Line.GOURAUDSHADED,d4
	beq	Line.paintGouraudshaded
	cmpi.w	#Line.PHONGSHADED,d4
	beq	Line.paintPhongshaded
	rts

* INPUT:
* \1: flagnum
* \2: flagreg
* \3: edgereg
* \4: xreg
* \5: yreg
Line_clipEdgeX:	MACRO
	btst	\1,\2
	beq.s	\@end_clip
	move.l	d2,d4
	sub.l	d0,d4
	move.l	d3,d7
	sub.l	d1,d7
	swap	d7
	clr.w	d7
	tst.w	d4
	beq.s	\@skip_div
	divs.l	d4,d7
\@skip_div:
	move.l	d0,d4
	sub.l	\3,d4
	muls.l	d4,d7
	swap	d7
	move.w	d1,d4
	sub.w	d7,d4
	cmp.w	a5,d4
	blt.s	\@out_of_range
	cmp.w	a6,d4
	bgt.s	\@out_of_range
	move.w	d4,\5
	move.l	\3,\4
	ext.l	\5
	moveq	#0,\2
	bra.s	\@end_clip
\@out_of_range:
	bset	#4,\2
\@end_clip:
	ENDM

* INPUT:
* \1: flagnum
* \2: flagreg
* \3: edgereg
* \4: xreg
* \5: yreg
Line_clipEdgeY:	MACRO
	btst	\1,\2
	beq.s	\@end_clip
	move.l	d3,d4
	sub.l	d1,d4
	move.l	d2,d7
	sub.l	d0,d7
	swap	d7
	clr.w	d7
	tst.w	d4
	beq.s	\@skip_div
	divs.l	d4,d7
\@skip_div:
	move.l	d1,d4
	sub.l	\3,d4
	muls.l	d4,d7
	swap	d7
	move.w	d0,d4
	sub.w	d7,d4
	cmp.w	a3,d4
	blt.s	\@out_of_range
	cmp.w	a4,d4
	bgt.s	\@out_of_range
	move.w	d4,\4
	ext.l	\4
	move.l	\3,\5
	moveq	#0,\2
	bra.s	\@end_clip
\@out_of_range:
	bset	#4,\2
\@end_clip:
	ENDM

* INPUT:
* \1: flagnum
* \2: flagreg
* \3: edgereg
* \4: xreg
* \5: yreg
* \6: ireg
Line_clipGEdgeX:	MACRO
	btst	\1,\2
	beq.s	\@end_clip
	move.l	d2,d4
	sub.l	d0,d4
	move.l	d3,d7
	sub.l	d1,d7
	swap	d7
	clr.w	d7
	tst.w	d4
	beq.s	\@skip_div
	divs.l	d4,d7
\@skip_div:
	move.l	d0,d4
	sub.l	\3,d4				* d4.l: dx
	muls.l	d4,d7
	swap	d7
	move.w	d1,d4
	sub.w	d7,d4
	cmp.w	a5,d4
	blt.s	\@out_of_range
	cmp.w	a6,d4
	bgt.s	\@out_of_range
	move.w	d4,\5

	move.l	d2,d4
	sub.l	d0,d4
	move.l	a2,d7
	sub.l	a0,d7
	lsl.l	#8,d7
	tst.w	d4
	beq.s	\@skip_div2
	divs.w	d4,d7				* (di<<8)/x
\@skip_div2:
	move.l	d0,d4
	sub.l	\3,d4				* d4.l: dx
	muls.w	d4,d7
	asr.l	#8,d7	
	move.w	a0,d4
	sub.w	d7,d4
	move.w	d4,\6

	move.l	\3,\4
	ext.l	\5
	moveq	#0,\2
	bra.s	\@end_clip
\@out_of_range:
	bset	#4,\2
\@end_clip:
	ENDM

* INPUT:
* \1: flagnum
* \2: flagreg
* \3: edgereg
* \4: xreg
* \5: yreg
* \6: ireg
Line_clipGEdgeY:	MACRO
	btst	\1,\2
	beq.s	\@end_clip
	move.l	d3,d4
	sub.l	d1,d4
	move.l	d2,d7
	sub.l	d0,d7
	swap	d7
	clr.w	d7
	tst.w	d4
	beq.s	\@skip_div
	divs.l	d4,d7
\@skip_div:
	move.l	d1,d4
	sub.l	\3,d4
	muls.l	d4,d7
	swap	d7
	move.w	d0,d4
	sub.w	d7,d4
	cmp.w	a3,d4
	blt.s	\@out_of_range
	cmp.w	a4,d4
	bgt.s	\@out_of_range
	move.w	d4,\4

	move.l	d3,d4
	sub.l	d1,d4
	move.l	a2,d7
	sub.l	a0,d7
	lsl.l	#8,d7
	tst.w	d4
	beq.s	\@skip_div2
	divs.w	d4,d7				* (di<<8)/y
\@skip_div2:
	move.l	d1,d4
	sub.l	\3,d4				* d4.l: dy
	muls.w	d4,d7
	asr.l	#8,d7	
	move.w	a0,d4
	sub.w	d7,d4
	move.w	d4,\6

	ext.l	\4
	move.l	\3,\5
	moveq	#0,\2
	bra.s	\@end_clip
\@out_of_range:
	bset	#4,\2
\@end_clip:
	ENDM

* Paints a one-colour line to the screen. The line can be clipped in
* any way.
* INPUT:
* d0.l: x1
* d1.l: y1
* d2.l: x2
* d3.l: y2
Line.paintFlatshaded:
* Clip this baby first...
.clip:	movem.w	Viewport.settingsTable+Viewport.XSTART,a3-a6

	moveq	#0,d5				* Set point clipflags to 0.
.check_first_left:
	cmp.w	a3,d0				* XSTART
	bge.s	.check_first_right
	addq.w	#%0010,d5
.check_first_right:
	cmp.w	a4,d0				* XEND
	blt.s	.end_check_first_right
	addq.w	#%0001,d5
.end_check_first_right:
.check_first_above:
	cmp.w	a5,d1				* YSTART
	bge.s	.check_first_under
	ori.w	#%1000,d5
.check_first_under:
	cmp.w	a6,d1				* YEND
	blt.s	.end_first_check
	addq.w	#%0100,d5
.end_first_check:

	moveq	#0,d6				* Set point clipflags to 0.
.check_second_left:
	cmp.w	a3,d2				* XSTART
	bge.s	.check_second_right
	addq.w	#%0010,d6
.check_second_right:
	cmp.w	a4,d2				* XEND
	blt.s	.end_check_second_right
	addq.w	#%0001,d6
.end_check_second_right:
.check_second_above:
	cmp.w	a5,d3				* YSTART
	bge.s	.check_second_under
	ori.w	#%1000,d6
.check_second_under:
	cmp.w	a6,d3				* YEND
	blt.s	.end_second_check
	addq.w	#%0100,d6
.end_second_check:

	subq	#1,a4
	subq	#1,a6

	move.w	d5,d7
	and.w	d6,d7
	beq	.go_on
	rts
.go_on:	move.w	d5,d7
	or.w	d6,d7
	beq	Line.paintFlatshaded.end_clip

.clip_first_left:
	Line_clipEdgeX	#1,d5,a3,d0,d1
.end_clip_first_left:
.clip_first_right:
	Line_clipEdgeX	#0,d5,a4,d0,d1
.end_clip_first_right:
.clip_first_top:
	Line_clipEdgeY	#3,d5,a5,d0,d1
.end_clip_first_top:
.clip_first_bottom:
	Line_clipEdgeY	#2,d5,a6,d0,d1
.end_clip_first_bottom:

.clip_second_left:
	Line_clipEdgeX	#1,d6,a3,d2,d3
.end_clip_second_left:
.clip_second_right:
	Line_clipEdgeX	#0,d6,a4,d2,d3
.end_clip_second_right:
.clip_second_top:
	Line_clipEdgeY	#3,d6,a5,d2,d3
.end_clip_second_top:
.clip_second_bottom:
	Line_clipEdgeY	#2,d6,a6,d2,d3
.end_clip_second_bottom:

	or.w	d5,d6
	btst	#4,d6
	beq.s	.go_on
	rts
.go_on:

Line.paintFlatshaded.end_clip:

* The lineroutine has NO CLIPPING!!!
* The only real possible optimisations are using dedicated loops for certain
* angles(moving two pixels(longword) in one go) and drawing the line from
* both sides.
* The average speed is now 850.000 pix/sec.
	moveq	#0,d6
	move.w	Primitive.TYPE(a1),d6
	andi.w	#Primitive.TEXTUREMASK,d6
	movea.l	Polygon.coloradr,a1
	lea	gradientSize/2(a1),a1
	lsl.l	#gradientBits+1,d6
	move.w	(a1,d6.l),d6
* INPUT: d6.w: color of line
	movea.l	Primitive.screenadr,a0
	move.l	d2,d4
	move.l	d3,d5
	sub.l	d0,d2
	bpl.s	.ok
	neg.l	d2
.ok:	sub.l	d1,d3
	bpl.s	.ok2
	neg.l	d3
.ok2:	cmp.l	d2,d3
	bhs.s	.ver
	cmp.l	d0,d4
	bhs.s	.do2
	exg	d0,d4
	exg	d1,d5
.do2	moveq	#0,d2
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d2
	add.l	d2,d2
	sub.l	d0,d4
	sub.l	d1,d5
	mulu.w	d2,d1
	tst.l	d5
	bpl.s	.shit
	neg.l	d5
	neg.l	d2
.shit	add.l	d0,d0
	add.l	d0,a0
	add.l	d1,a0
	swap	d5
	clr.w	d5
	addq.w	#1,d4
	divu.w	d4,d5
	moveq	#0,d0
	subq.w	#1,d4
.lp2	add.w	d5,d0
	bcc.s	.mov
	adda.l	d2,a0
.mov:	move.w	d6,(a0)+
	dbra	d4,.lp2
.end:
.x_out:	rts

.ver	cmp.l	d0,d4
	bhs.s	.do
	exg	d0,d4
	exg	d1,d5
.do	moveq	#0,d2
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d2
	add.l	d2,d2
	sub.l	d0,d4
	sub.l	d1,d5
	mulu.w	d2,d1
	tst.l	d5
	bpl.s	.shitt
	neg.l	d5
	neg.l	d2
.shitt	add.l	d0,d0
	add.l	d0,a0
	add.l	d1,a0
	swap	d4
	clr.w	d4
	addq.w	#1,d5
	divu.w	d5,d4
	moveq	#0,d0
	subq.w	#1,d5
	swap	d4
	clr.w	d4
.lp	addx.l	d4,d0
	move.w	d6,(a0,d0.w*2)
	adda.l	d2,a0
	dbra	d5,.lp
.y_out:	rts

* Paints a gouraudshaded line to the screen. The line can be clipped in any
* way.
* INPUT:
* d0.l: x1
* d1.l: y1
* d2.l: x2
* d3.l: y2
Line.paintGouraudshaded:
	movem.w	Line.SIZE(a1),a0/a2

Line.paintGradiented:
* Clip this baby first...
.clip:	movem.w	Viewport.settingsTable+Viewport.XSTART,a3-a6

	moveq	#0,d5				* Set point clipflags to 0.
.check_first_left:
	cmp.w	a3,d0				* XSTART
	bge.s	.check_first_right
	addq.w	#%0010,d5
.check_first_right:
	cmp.w	a4,d0				* XEND
	blt.s	.end_check_first_right
	addq.w	#%0001,d5
.end_check_first_right:
.check_first_above:
	cmp.w	a5,d1				* YSTART
	bge.s	.check_first_under
	ori.w	#%1000,d5
.check_first_under:
	cmp.w	a6,d1				* YEND
	blt.s	.end_first_check
	addq.w	#%0100,d5
.end_first_check:

	moveq	#0,d6				* Set point clipflags to 0.
.check_second_left:
	cmp.w	a3,d2				* XSTART
	bge.s	.check_second_right
	addq.w	#%0010,d6
.check_second_right:
	cmp.w	a4,d2				* XEND
	blt.s	.end_check_second_right
	addq.w	#%0001,d6
.end_check_second_right:
.check_second_above:
	cmp.w	a5,d3				* YSTART
	bge.s	.check_second_under
	ori.w	#%1000,d6
.check_second_under:
	cmp.w	a6,d3				* YEND
	blt.s	.end_second_check
	addq.w	#%0100,d6
.end_second_check:

	subq	#1,a4
	subq	#1,a6

	move.w	d5,d7
	and.w	d6,d7
	beq	.go_on
	rts
.go_on:	move.w	d5,d7
	or.w	d6,d7
	beq	Line.paintGouraudshaded.end_clip

.clip_first_left:
	Line_clipGEdgeX	#1,d5,a3,d0,d1,a0
.end_clip_first_left:
.clip_first_right:
	Line_clipGEdgeX	#0,d5,a4,d0,d1,a0
.end_clip_first_right:
.clip_first_top:
	Line_clipGEdgeY	#3,d5,a5,d0,d1,a0
.end_clip_first_top:
.clip_first_bottom:
	Line_clipGEdgeY	#2,d5,a6,d0,d1,a0
.end_clip_first_bottom:

.clip_second_left:
	Line_clipGEdgeX	#1,d6,a3,d2,d3,a2
.end_clip_second_left:
.clip_second_right:
	Line_clipGEdgeX	#0,d6,a4,d2,d3,a2
.end_clip_second_right:
.clip_second_top:
	Line_clipGEdgeY	#3,d6,a5,d2,d3,a2
.end_clip_second_top:
.clip_second_bottom:
	Line_clipGEdgeY	#2,d6,a6,d2,d3,a2
.end_clip_second_bottom:

	or.w	d5,d6
	btst	#4,d6
	beq.s	.go_on
	rts
.go_on:

Line.paintGouraudshaded.end_clip:

* The lineroutine has NO CLIPPING!!!
* The only real possible optimisations are using dedicated loops for certain
* angles(moving two pixels(longword) in one go) and drawing the line from
* both sides.
* The average speed is now 850.000 pix/sec.
	move.l	a0,d6
	move.l	a2,d7
* d5,d6: gouraud indices
	moveq	#0,d4
	move.w	Primitive.TYPE(a1),d4
	andi.w	#Primitive.TEXTUREMASK,d4
	movea.l	Polygon.coloradr,a1
	lsl.l	#gradientBits+1,d4
	adda.l	d4,a1
	movea.l	Primitive.screenadr,a0
	move.l	d2,d4
	move.l	d3,d5
	sub.l	d0,d2
	bpl.s	.ok
	neg.l	d2
.ok:	sub.l	d1,d3
	bpl.s	.ok2
	neg.l	d3
.ok2:	cmp.l	d2,d3
	bhs.s	.ver
	cmp.l	d0,d4
	bhs.s	.do2
	exg	d0,d4
	exg	d1,d5
	exg	d6,d7
.do2	moveq	#0,d2
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d2
	add.l	d2,d2
	sub.l	d0,d4
	sub.l	d1,d5
	mulu.w	d2,d1
	tst.l	d5
	bpl.s	.shit
	neg.l	d5
	neg.l	d2
.shit	add.l	d0,d0
	add.l	d0,a0
	add.l	d1,a0
	sub.w	d6,d7
	ext.l	d7
	lsl.l	#8,d7
	swap	d5
	clr.w	d5
	addq.w	#1,d4
	divu.w	d4,d5
	divs.w	d4,d7
	lsl.w	#8,d6
	moveq	#0,d0
	subq.w	#1,d4
.lp2:	add.w	d7,d6
	move.w	d6,d3
	lsr.w	#8,d3
	add.w	d5,d0
	bcc.s	.mov
	adda.l	d2,a0
.mov:	move.w	(a1,d3.w*2),(a0)+
	dbra	d4,.lp2
.end:
.x_out:	rts

.ver:	cmp.l	d0,d4
	bhs.s	.do
	exg	d0,d4
	exg	d1,d5
	exg	d6,d7
.do	moveq	#0,d2
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d2
	add.l	d2,d2
	sub.l	d0,d4
	sub.l	d1,d5
	mulu.w	d2,d1
	tst.l	d5
	bpl.s	.shitt
	neg.l	d5
	neg.l	d2
.shitt	add.l	d0,d0
	add.l	d0,a0
	add.l	d1,a0
	swap	d4
	clr.w	d4
	sub.w	d6,d7
	ext.l	d7
	lsl.l	#8,d7
	addq.w	#1,d5
	divu.w	d5,d4
	divs.w	d5,d7
	moveq	#0,d0
	subq.w	#1,d5
	ext.l	d7
	swap	d7
	rol.l	#8,d7
	swap	d7
	clr.b	d7
	swap	d4
	move.w	d7,d4					* ii := ii
	swap	d4
	move.w	d4,d7					* xx := xx
	swap	d7
	clr.w	d4					* XX := 0
	andi.l	#$0000ffff,d6

* d4.l: iiXX, d0.l: iiXX
* d7.l: xxII, d6.l: xxII

.lp:	addx.l	d4,d0
	addx.l	d7,d6
	move.w	(a1,d6.w*2),(a0,d0.w*2)
	adda.l	d2,a0
	dbra	d5,.lp
.y_out:	rts

* Paints a gouraudshaded line to the screen. The line can be clipped in any
* way.
* INPUT:
* d0.l: x1
* d1.l: y1
* d2.l: x2
* d3.l: y2
* a1: Line structure
* a2: vertex table
Line.paintPhongshaded:
	movem.w	Line.SIZE(a1),d5/d6
	mulu.w	d7,d5
	mulu.w	d7,d6
	move.w	Vertex.Z(a2,d5.l),d5
	move.w	Vertex.Z(a2,d6.l),d6
	moveq	#$40,d7
	asr.w	d5
	asr.w	d6
	add.w	d7,d5
	add.w	d7,d6
	movea.w	d5,a0
	movea.w	d6,a2
	bra	Line.paintGradiented

	BSS

******** ObjectRegistry

ObjectRegistry.regTable:
	DS.W	1				* handle-count
	DS.L	ObjectRegistry.MAX_OBJECTS
* Storage for initialized boundingboxes.
ObjectRegistry.bbTable:
	DS.W	8*3*ObjectRegistry.MAX_OBJECTS

******** Matrix

Matrix.stackTop:
	DS.W	1
Matrix.temp:
	DS.B	Matrix.SIZE
Matrix.stack:				* page flipping transformation matrix
	DS.B	Matrix.SIZE*Matrix.MAX_DEPTH

******** PrimitiveMesh

PrimitiveMesh.rectangleTable:
	DS.W	1				* rectanglecount
	DS.B	Rectangle.SIZE*ObjectRegistry.MAX_OBJECTS

******** Primitive

Primitive.screenadr:
	DS.L	1

******** Polygon

Polygon.uvslopes:
	DS.W	4				* u0,v0,u1,v1
Polygon.invTable:
	DS.W	Viewport.MAX_Y
Polygon.fragmentTable:
	DS.W	1				* active fragment flags
	DS.B	Fragment.SIZE*4			* max 3 for quad, max 2 for triangle
Polygon.fragment2Table:
	DS.W	1				* active fragment flags
	DS.B	Fragment.SIZE*5			* max 5 for quad, max 4 for triangle
Polygon.scanlineTable:
	DS.W	1
	DS.W	3*Viewport.MAX_Y		* table for tmap and envmap scanlines
Polygon.shadeTable:
	DS.W	Vertex2d.SIZE*8			* (u,v) for each vertex
Polygon.extvertexTable:
	DS.W	4*3				* for each trianglevertex: u0,v0,u1,v1
Polygon.polypointTable:
	DS.W	1
	DS.B	PolyPoint.SIZE*16
Polygon.polypointTable2:
	DS.W	1
	DS.B	PolyPoint.SIZE*16

	IFNE	Polygon.USE_BLITGOURAUD
Polygon.gouraudindexTable:
	DS.W	128
Polygon.gouraudlengthTable:
	DS.W	128
Polygon.normalizeTable:
	DS.B	256*256
Polygon.gouraudtbladr:				* address of special gouraud table
	DS.L	1
	ENDC

******** Fragment

Fragment.v4routadr:
	DS.L	1
			RSRESET
Primitive.TYPE:		RS.W	1		; primitive/shading/extended type

; TableLookup mask
Primitive.TEXTUREMASK:	=	%0000001111111111

******** Vertex

;		RSRESET
;Vertex.X:	RS.W	1
;Vertex.Y:	RS.W	1
;Vertex.Z:	RS.W	1
;Vertex.SIZE:	RS.B	0

******** Vertex2d

		RSRESET
Vertex2d.X:	RS.W	1			* 8:8 fixed point
Vertex2d.Y:	RS.W	1			* 8:8 fixed point
Vertex2d.SIZE:	RS.B	0

********* PolyPoint

		RSRESET
PolyPoint.X:	RS.W	1
PolyPoint.Y:	RS.W	1
PolyPoint.U1:	RS.W	1
PolyPoint.V1:	RS.W	1
PolyPoint.U2:	RS.W	1
PolyPoint.V2:	RS.W	1
PolyPoint.SIZE:	RS.B	0

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

Viewport.MAX_X:		=	320		* Maximum X dimension
Viewport.MAX_Y:		=	200		* Maximum Y dimension

* TexturedTriangle
* INPUT:
* a1: primitive
* a2: vertices
Polygon.paintIClippedTextured:
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

IntersectV1Edge:	MACRO

	ifne	1

; pessimised 68000 version
	sub.w	d4,d5				; d5.w=du=u1-u0
	sub.w	d2,d3				; d3.w=dy=y1-y0
	sub.w	d0,d1				; d1.w=dx=x1-x0
	ext.l	d3
	lsl.l	#8,d3
	divs.w	d1,d3				; d3.w=slope=dy/dx [8:8]
	ext.l	d5
	lsl.l	#8,d5
	divs.w	d1,d5				; d5.w=uslope=du/dx [8:8]
	sub.w	a2,d0				; d0.w=xi=x0-clipx
	neg.w	d0
	muls.w	d0,d5				; d5.l= du/dx * -xi [24:8]
	muls.w	d0,d3				; d3.l= dy/dx * -xi [24:8]
	moveq	#0,d0
	asr.l	#8,d3				; d3.w= du/dx * -xi [truncated int]
	addx.w	d0,d3				; d3.w= du/dx * -xi [rounded int]
	asr.l	#8,d5				; d5.w= du/dx * -xi [truncated int]
	addx.w	d0,d5				; d5.w= du/dx * -xi [rounded int]
	add.w	d2,d3				; d3.w=y'= dy/dx * -xi + y0
	add.w	d4,d5				; d5.w=u'= du/dx * -xi + u0

	else

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

	endc

	ENDM

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
	beq	Polygon.paintTexturemapped2

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

	bra	Polygon.paintTexturemapped2

.end:	rts
.offscreen:
	rts

.clipflags:
	DC.W	0

IntersectV2Edge:	MACRO
	sub.w	d4,d5				; d5.w=v1-v0
	ext.l	d5
	lsl.l	#8,d5
	divs.w	d1,d5				; d5.w=vslope=dv/dx [8:8]
	muls.w	d0,d5				; d5.l=dv/dx * -xi [8:16]
	asr.l	#8,d5				; d5.l=dv/dx * -xi [8:8] [truncated]
	moveq	#0,d2
	addx.w	d2,d5				; d5.w=dv/dx * -xi [8:8] [rounded]
	add.w	d4,d5				; d5.w=V=dv/dx * -xi + v0
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

* Splits a texturemapped polygon up into triangles and paints them.
* INPUT: a1: polygon
Polygon.paintTexturemapped:
	move.w	(a1)+,Polygon.curtexture

Polygon.paintTexturemapped2:
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
	move.w	d7,tmapEdgeDY(a0)
	add.w	d7,d7
	muls.w	(a6,d7.w),d6			; *2
	add.l	d6,d6
	move.l	d6,tmapEdgeXSlope(a0)
	move.l	a3,tmapEdgeUStart(a0)		; u,v
	move.l	a4,d6
	move.w	a3,d6
	sub.l	a3,d6
	swap	d6
	muls.w	(a6,d7.w),d6			; *2
	asr.l	#7,d6
	move.w	d6,tmapEdgeUSlope(a0)
	move.w	a4,d6
	sub.w	a3,d6
	muls.w	(a6,d7.w),d6			; *2
	asr.l	#7,d6
	move.w	d6,tmapEdgeVSlope(a0)

;	move.w	d0,tmapEdgeXStart(a1)
;	move.w	d1,tmapEdgeYStart(a1)
	move.l	d4,d6
	move.l	d5,d7
	sub.l	d0,d6
	sub.l	d1,d7
	add.w	d7,d7
	muls.w	(a6,d7.w),d6			; *2
	add.l	d6,d6
	move.l	d6,tmapEdgeXSlope(a1)
;	move.l	a3,tmapEdgeUStart(a1)		* u,v
	move.l	a5,d6
	move.w	a3,d6
	sub.l	a3,d6
	swap	d6
	muls.w	(a6,d7.w),d6			; *2
	asr.l	#7,d6
	move.w	d6,tmapEdgeUSlope(a1)
	move.w	a5,d6
	sub.w	a3,d6
	muls.w	(a6,d7.w),d6			; *2
	asr.l	#7,d6
	move.w	d6,tmapEdgeVSlope(a1)

	move.w	d2,tmapEdgeXStart(a2)
	move.w	d3,tmapEdgeYStart(a2)
	move.l	d4,d6
	move.l	d5,d7
	sub.l	d2,d6
	sub.l	d3,d7
	move.w	d7,tmapEdgeDY(a2)
	add.w	d7,d7
	muls.w	(a6,d7.w),d6			; *2
	add.l	d6,d6
	move.l	d6,tmapEdgeXSlope(a2)
	move.l	a4,tmapEdgeUStart(a2)		; u,v
	move.l	a5,d6
	move.w	a4,d6
	sub.l	a4,d6
	swap	d6
	muls.w	(a6,d7.w),d6			; *2
	asr.l	#7,d6
	move.w	d6,tmapEdgeUSlope(a2)
	move.w	a5,d6
	sub.w	a4,d6
	muls.w	(a6,d7.w),d6			; *2
	asr.l	#7,d6
	move.w	d6,tmapEdgeVSlope(a2)
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
	
;	moveq	#0,d3
	move.w	tmapEdgeDY(a0),d3
;	muls.l	d3,d7
;	swap	d7
	asr.l	#8,d7				; d7.w=xslope [8:8]
	muls.w	d3,d7
	asr.l	#8,d7

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

	movea.l	Polygon.textureadr,a3
	movea.l	Primitive.screenadr,a0
	move.w	a4,d0	;move.w	Polygon.fragmentTable+2+Fragment.START(a6),d0
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d0
	adda.l	d0,a0
	lea	Polygon.scanlineTable,a1
	move.w	a5,d7
	bpl.s	PAINT_UNCLIPTEXTURESCANS

.end_paint_triangle:
	rts

	BSS

.edges_tbl:
	DS.B	tmapEdgeSize*3

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

.paint_yloop:
	movem.w	(a1)+,d0-d3
; d0.w= left x
; d1.w= right x
; d2.w= left Uu 8:8
; d3.w= left Vv 8:8
	sub.w	d0,d1
	ble.s	.end_paint_yloop
	lea	(a0,d0.l),a6
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
	move.b	(a3,d0.l),(a6)+
	dbf	d1,.paint_xloop

.end_paint_yloop:
	adda.l	d6,a0
	dbf	d7,.paint_yloop
	rts

;---------------------------------------------------------------------------

	bss

Polygon.curtexture:
	ds.w	1

Polygon.polypointTable:
	DS.W	1
	DS.B	PolyPoint.SIZE*16
Polygon.polypointTable2:
	DS.W	1
	DS.B	PolyPoint.SIZE*16

******** Viewport

Viewport.settingsTable:
	DS.B	Viewport.SIZE

;Polygon.invTable:
;	DS.W	Viewport.MAX_Y

Polygon.uvslopes:
	ds.w	2

Polygon.scanlineTable:
	DS.W	1
	DS.W	3*Viewport.MAX_Y		* table for tmap and envmap scanlines

Polygon.textureadr:
	ds.l	1

Primitive.screenadr:
	ds.l	1

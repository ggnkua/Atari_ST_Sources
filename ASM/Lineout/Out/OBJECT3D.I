; 3d object library.
; Designed for u-fly engine.
; Custom objects + generators.

; INPUT:
; d0.l=size
; a0: dst
; a1: src
Object3d.copy:
	lsr.l	d0
	beq.s	.end
	subq.w	#1,d0
.loop:	move.w	(a1)+,(a0)+
	dbf	d0,.loop
.end:	rts

; INPUT:
; d0.w=start vertex
; d1.w=#vertices
; d2.w=scalar (8:8)
; a0: object
Object3d.scale:
	mulu.w	#Vertex.SIZE,d0
	lea	4(a0,d0.l),a0
	mulu.w	#Vertex.SIZE/2,d1
	subq.w	#1,d1
	bmi.s	.end
.loop:	move.w	(a0),d0
	muls.w	d2,d0
	asr.l	#8,d0
	move.w	d0,(a0)+
	dbf	d1,.loop
.end:	rts

	DATA

Object3d.spikey:
	DC.W	(.end-.start)/Vertex.SIZE	* amount of vertices
	DC.W	(.end-.normstart)/Vertex.SIZE	* amount of normals
.start:	DC.W	-250,-250,-250
	DC.W	-250,250,-250
	DC.W	250,-250,-250
	DC.W	250,250,-250
	DC.W	-250,-250,250
	DC.W	-250,250,250
	DC.W	250,-250,250
	DC.W	250,250,250
	DC.W	-800,0,0
	DC.W	+800,0,0
	DC.W	0,-800,0
	DC.W	0,+800,0
	DC.W	0,0,-800
	DC.W	0,0,+800
.normstart:
	DC.W	-73,-73,-73
	DC.W	-73,73,-73
	DC.W	73,-73,-73
	DC.W	73,73,-73
	DC.W	-73,-73,73
	DC.W	-73,73,73
	DC.W	73,-73,73
	DC.W	73,73,73
	DC.W	-40,0,0
	DC.W	+40,0,0
	DC.W	0,-40,0
	DC.W	0,+40,0
	DC.W	0,0,-40
	DC.W	0,0,+40
.end:

	DC.W	(.end2d-.start2d)/Vertex2d.SIZE	* amount of 2d vertices
.start2d:
.end2d:

	DC.W	24				* amount of primitives

	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+0,1,12,+14,15,26
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+3,2,12,+17,16,26
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+1,3,12,+15,17,26
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+2,0,12,+16,14,26

	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+5,4,13,+19,18,27
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+6,7,13,+20,21,27
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+7,5,13,+21,19,27
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+4,6,13,+18,20,27

	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+0,4,8,+14,18,22
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+5,1,8,+19,15,22
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+1,0,8,+15,14,22
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+4,5,8,+18,19,22

	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+6,2,9,+20,16,23
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+3,7,9,+17,21,23
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+2,3,9,+16,17,23
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+7,6,9,+21,20,23

	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+0,2,10,+14,16,24
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+6,4,10,+20,18,24
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+4,0,10,+18,14,24
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+2,6,10,+16,20,24

	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+3,1,11,+17,15,25
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+5,7,11,+19,21,25
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+1,5,11,+15,19,25
	DC.W	Polygon.TRI|Polygon.ENVMAPPED|0,+7,3,11,+21,17,25
Object3d.spikeyEnd:

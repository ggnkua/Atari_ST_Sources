; CPU+DSP implementation of the Human Fly engine 2.1.
; Special one-off 'shadow' version!! Beware!!
;
; Ofcourse limited in terms of scene complexity, but handles this with
; various errorcodes.
;
; This is meant for >=68020 CPU and 56x01 DSP

; TODO: repair bumpmap init you numbskull!

	INCLUDE	HFLYCORE.S			; Include core routines.
	TEXT
	INCLUDE	H_FLYRPC.I

;======= MACROS

sendLongToDsp:	MACRO
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	move.l	\1,$ffffa204.w
	ENDM

receiveLongFromDsp:	MACRO
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	move.l	$ffffa204.w,\1
	ENDM

sendWordToDsp:	MACRO
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	move.w	\1,$ffffa206.w
	ENDM

receiveWordFromDsp:	MACRO
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	move.w	$ffffa206.w,\1
	ENDM

;======= HumanFly

; Initialises global parts of the pipeline.
; PRE:
; Dsp must have bootstrap code installed!
HumanFly.init:
; Requires Dsp.loadProgram function!
	move.l	#(HumanFly.endP56-HumanFly.p56)/3,d0
	lea	HumanFly.p56,a0
	bra	Dsp.loadProgram

;======= ObjectRegistry

ObjectRegistry.CAPACITY:	=	32

; Adds a 3d-object to the registry and returns a handle.
; INPUT:
; d0.l=size of object (bytes)
; a0: address of 3d object
; OUTPUT:
; d0.w: >= 0: objecthandle, -1: error, not added!
ObjectRegistry.set:
; Store handle->address stuff.
	move.w	ObjectRegistry.numberOfHandles,d1
	move.l	a0,(ObjectRegistry.table,d1.w*4)

	moveq	#RPC_REGISTER_OBJECT,d1
	sendLongToDsp	d1

; Now transfer our object to the dsp.
	lsr.l	#1,d0
	move.l	d0,d1
	add.l	ObjectRegistry.size,d1
	sendLongToDsp	d1			; Send total size of reg..
	tst.l	d0
	ble.s	.error
	receiveWordFromDsp	d3
	tst.w	d3				; Did the dsp accept?
	bmi.s	.error
	sendLongToDsp	d0			; Send objectsize.
	move.l	d1,ObjectRegistry.size
	lea	$FFFFA202.w,a1
	lea	$FFFFA204.w,a2
	subq.w	#1,d0

.loop:	move.w	(a0)+,d1
	ext.l	d1

.wait:	btst.b	#1,(a1)
	beq.s	.wait
	move.l	d1,(a2)
	dbra	d0,.loop

.success:
	addq.w	#1,ObjectRegistry.numberOfHandles
	move.w	d3,d0
	rts
.error:	moveq	#-1,d0
	rts

; Clears the registry. All handles become invalid.
ObjectRegistry.clear:
	clr.l	ObjectRegistry.size
	clr.w	ObjectRegistry.numberOfHandles
	moveq	#RPC_CLEAR_REGISTRY,d0
	sendLongToDsp	d0
	rts

; TODO: bugs out with replacement of texels.. why!?!?!?
; Replaces specified object's primitives/vertices/normals/texels.
; INPUT:
; d0.w=objecthandle
; d1.w=replacemode (%ptnv)
; d2.l=objectsize
; OUTPUT:
; d0.w =0:success, <0:error
ObjectRegistry.replace:
; Check if handle is valid...
	cmp.w	ObjectRegistry.numberOfHandles,d0
	bge	.error

	andi.w	#%1111,d1
	beq	.success

	move.l	d2,.size

	move.l	(ObjectRegistry.table,d0.w*4),a0	; a0: object
	movea.l	a0,a5

	move.w	(a0)+,d2				; d2.w=#vertices+#normals
	move.w	d2,d3
	mulu.w	#Vertex.SIZE,d3
	move.w	(a0)+,d4				; d4.w=#normals
	sub.w	d4,d2					; d2.w=#vertices
	move.w	d2,d5
	mulu.w	#Vertex.SIZE,d5
	lea	(a0,d5.l),a1
	lea	(a0,d3.l),a2
	move.w	(a2)+,d5				; d5.w=#texels
	lea	(a2,d5.w*Vertex2d.SIZE),a3
; a0: vertextable
; a1: normaltable
; a2: texeltable
; a3: primitivelist
; a6: object

; Call remote procedure on dsp.
	moveq	#RPC_REPLACE_OBJECT,d3
	sendLongToDsp	d3

; Send objecthandle to dsp.
	clr.l	d3
	move.w	d0,d3
	sendLongToDsp	d3

; Send replacemode to dsp.
	move.w	d1,d3
	sendLongToDsp	d3

	lea	$FFFFA204.w,a6

	lsr.w	d1
	bcc.s	.end_vertices
	mulu.w	#Vertex.SIZE/2,d2
	sendLongToDsp	d2
	subq.w	#1,d2
	bmi.s	.end_vertices
.vertex_loop:
	move.w	(a0)+,d0
	ext.l	d0
	move.l	d0,(a6)
	dbra	d2,.vertex_loop
.end_vertices:

	lsr.w	d1
	bcc.s	.end_normals
	mulu.w	#Vertex.SIZE/2,d4
	sendLongToDsp	d4
	subq.w	#1,d4
	bmi.s	.end_normals
.normal_loop:
	move.w	(a1)+,d0
	ext.l	d0
	move.l	d0,(a6)
	dbra	d4,.normal_loop
.end_normals:

	lsr.w	d1
	bcc.s	.end_texels
	mulu.w	#Vertex2d.SIZE/2,d5
	sendLongToDsp	d5
	subq.w	#1,d5
	bmi.s	.end_texels
.texel_loop:
	move.w	(a2)+,d0
	ext.l	d0
	move.l	d0,(a6)
	dbra	d5,.texel_loop
.end_texels:

	lsr.w	d1
	bcc.s	.end_primitives
	move.l	.size(pc),d2
	sub.l	a3,d2
	add.l	a5,d2
	lsr.l	#1,d2
	sendLongToDsp	d2
	subq.w	#1,d2
	bmi.s	.end_primitives
.primitive_loop:
	move.w	(a3)+,d0
	ext.l	d0
	move.l	d0,(a6)
	dbra	d2,.primitive_loop
.end_primitives:

.success:
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

.size:	DC.L	0

;======= Matrix

; Wiser to convert here, instead of dsp..
; INPUT:
; a0: quaternion
Matrix.convertQuaternion:
	moveq	#RPC_GENERATE_QUATMATRIX,d0
	sendLongToDsp	d0

	moveq	#Quaternion.SIZE/2,d7
.loop	move.w	(a0)+,d0
	ext.l	d0
	sendLongToDsp	d0
	dbra	d7,.loop
	rts

; INPUT:
; d0.w: X rotation (a)
; d1.w: Y rotation (b)
; d2.w: Z rotation (c)
Matrix.generate:
	lea	$FFFFA204.w,a4
	moveq	#RPC_GENERATE_ROTMATRIX,d7

	sendLongToDsp	d7
;	move.l	d7,(a4)

	move.w	#sintbllen-1,d3
	and.w	d3,d0
	and.w	d3,d1
	and.w	d3,d2
	lea	Matrix.sineTable,a2
	Get_SinCos	a2,d2,d4,d5
	Get_SinCos	a2,d1,d2,d3
	Get_SinCos	a2,d0,d0,d1
	lsl.l	#8,d0
	lsl.l	#8,d1
	lsl.l	#8,d2
	lsl.l	#8,d3
	lsl.l	#8,d4
	lsl.l	#8,d5
	sendLongToDsp	d0
	sendLongToDsp	d1
	IFNE	0
	move.l	d2,(a4)
	move.l	d3,(a4)
	move.l	d4,(a4)
	move.l	d5,(a4)
	ELSE
	sendLongToDsp	d2
	sendLongToDsp	d3
	sendLongToDsp	d4
	sendLongToDsp	d5
	ENDC
	rts

; Translate the matrix translation vector.
; INPUT:
; d0.w: X translation
; d1.w: Y translation
; d2.w: Z translation
Matrix.translate:
	lea	$FFFFA204.w,a4
	moveq	#RPC_TRANSLATE_MATRIX,d7

	sendLongToDsp	d7
;	move.l	d7,(a4)

	ext.l	d0
	ext.l	d1
	ext.l	d2
	IFNE	0
	move.l	d0,(a4)
	move.l	d1,(a4)
	move.l	d2,(a4)
	ELSE
	sendLongToDsp	d0
	sendLongToDsp	d1
	sendLongToDsp	d2
	ENDC
	rts

; Pushes a previously generated matrix on the stack.
Matrix.push:
	moveq	#RPC_PUSH_MATRIX,d0

	sendLongToDsp	d0
;	move.l	d0,$FFFFA204.w
	rts

; Pops the top matrix off the stack.
Matrix.pop:
	moveq	#RPC_POP_MATRIX,d0

	sendLongToDsp	d0
;	move.l	d0,$FFFFA204.w
	rts

;======= TransformObject

; INPUT:
; d0.l: flags
; d1.w: original objecthandle
; Rotates & scales & translates object by it's matrix.
TransformObject.transform:
	lea	$FFFFA204.w,a4
	moveq	#RPC_TRANSFORM_OBJECT,d7

; Send transformation command to the dsp.
	sendLongToDsp	d7
;	move.l	d7,(a4)

	ext.l	d1

	sendLongToDsp	d1
;	move.l	d1,(a4)
	rts

;======= Primitive

Primitive.PAINTMODE_ENABLED:	=	1

; INPUT:
; a0: address of screenbuffer
Primitive.setScreenbuffer:
	move.l	a0,Primitive.screenadr
	rts

; Sets paintmode. This involves pixeltype, logic op, pixelskip. For
; discription of these, see paintmode equates.
; All primitives use the settings taken by this call.
; WARNING: this is dirty rotten and festering! Code generation city!
; Well, first problems arise with 040 prolly.
; todo: if all fails, fuck up 040 caches. A shitty job really, doesn't
; belong in a user-mode engine.
; Unfortunately a more tidy way would drasticly increase the amount of
; routines (about 120 more routs needed!!!!)
; INPUT:
; d0.w=pixeltype and logic op
; d1.w=pixelskip (number of bytes to progress each pixel)
; OUTPUT:
; d0.w: =0: success, <0: error
Primitive.setPaintMode:
	IFNE	Primitive.PAINTMODE_ENABLED
	move.w	d0,d2
	andi.w	#Primitive.LOGICMASK,d0
	lsr.w	#Primitive.LOGICSHIFT,d0
	andi.w	#Primitive.SIZEMASK,d2
; d0.w=logic, d1.w=pixelskip, d2.w=pixelsize

	move.w	d1,Primitive.skipBytes
	move.w	d2,d3
	addq.w	#1,d3
	move.w	d3,Primitive.bytesPerPixel

	move.l	(Sprite.routTable,d0.w*4),Sprite.rout

	bsr	Polygon.setFlatShader
	bsr	Polygon.setGouraudShader
	bsr	Polygon.setOffsetMapper
	bsr	Polygon.setPixelMapper

; Lines still todo, but they're not of much practical use..
	ENDC

	clr.l	d0					; return 'success'
	rts

Polygon.setFlatShader:
; Move in pixel instruction for the flatshader.
	lea	Polygon.flatPixelInstr,a0
	move.l	(Polygon.flatRoutTable,d0.w*8),a2
	move.l	(Polygon.flatRoutTable+4,d0.w*8),d3
	move.w	d3,d4
	mulu.w	d2,d4
	adda.l	d4,a2
	lsr.w	#1,d3
	subq.w	#1,d3
	cmpi.w	#1,d2
	bne.s	.no_word
	clr.w	d3					; word loop always small!
.no_word:
.pixinstr_loop:
	move.w	(a2)+,(a0)+				; pump move, or, add, whatever
	dbra	d3,.pixinstr_loop
	tst.w	d1
	beq.s	.add_done
	move.w	#$D3CA,(a0)+				; Concatenate 'adda.l a2,a1'.
.add_done:
	lea	Polygon.flatTail,a1
	move.w	(a1)+,(a0)+
	addq	#2,a1
	move.l	#Polygon.flatPixelInstr,d3
	sub.l	a0,d3
	move.w	d3,(a0)+				; Kick in dbf offset.

	moveq	#Polygon.FLAT_TAILSIZE/2-3,d7
.concat_tail_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,.concat_tail_loop

	tst.w	d1
	beq.s	.end_outer_dbf_adjust
	subq.w	#2,-4(a0)				; Adjust outer dbf for concatenated 'adda'!
.end_outer_dbf_adjust:
	rts

Polygon.setGouraudShader:
; Move in pixel instruction for the gouraudshader.
	lea	Polygon.gouraudPixelInstr,a0
	move.l	(Polygon.gouraudRoutTable,d0.w*8),a2
	move.l	(Polygon.gouraudRoutTable+4,d0.w*8),d3
	move.w	d3,d7
	move.w	d3,d4
	lsr.w	#1,d7
	subq.w	#1,d7
	mulu.w	d2,d3
	adda.l	d3,a2
	cmpi.w	#1,d2
	bne.s	.no_word
	moveq	#2,d7					; word loop always small!
	tst.w	d0
	bne.s	.no_move
	subq.w	#1,d7
.no_move:
.no_word:
; Pump move, or, add, whatever.
.pump_loop:
	move.w	(a2)+,(a0)+
	dbf	d7,.pump_loop

	tst.w	d1
	beq.s	.add_done
	move.w	#$D1CB,(a0)+				; Concatenate 'adda.l a3,a0'.
.add_done:
	lea	Polygon.gouraudTail,a1
	move.w	(a1)+,(a0)+				; Kick 'addx.l'.
	move.w	(a1)+,(a0)+				; Kick 1st 'dbf d6,' word.
	addq	#2,a1
	move.w	d4,d3
	neg.w	d3
	subq.w	#4,d3
	tst.w	d1
	beq.s	.put_dbf_addy
	subq.w	#2,d3
.put_dbf_addy:
	move.w	d3,(a0)+				; Kick in dbf offset.

	moveq	#Polygon.GOURAUD_TAILSIZE/2-4,d7
.concat_tail_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,.concat_tail_loop

; Store offsetdata for outer dbf.
	subq	#4,a0					; a0: addy of dbf-data
	move.l	#Polygon.gouraudYloop,d3
	sub.l	a0,d3
	move.w	d3,(a0)					; Store offset.
	rts

Polygon.setOffsetMapper:
; Move in pixel instruction for the texturemapper.
	lea	Polygon.offsetPixelInstr,a0
	move.l	(Polygon.offsetRoutTable,d0.w*8),a2
	move.l	(Polygon.offsetRoutTable+4,d0.w*8),d3
	move.w	d3,d7
	move.w	d3,d4
	lsr.w	#1,d7
	subq.w	#1,d7
	mulu.w	d2,d3
	adda.l	d3,a2
; Pump move, or, add, whatever.
.pump_loop:
	move.w	(a2)+,(a0)+
	dbf	d7,.pump_loop

	tst.w	d1
	beq.s	.add_done
	move.w	#$D1CB,(a0)+				; Concatenate 'adda.l a2,a1'.
.add_done:
	lea	Polygon.offsetTail,a1
	move.w	(a1)+,(a0)+				; Kick 2st word of 'dbf d6,'.
	addq	#2,a1
	move.w	d4,d3
	neg.w	d3
	subq.w	#4,d3
	tst.w	d1
	beq.s	.put_dbf_addy
	subq.w	#2,d3
.put_dbf_addy:
	move.w	d3,(a0)+				; Kick in dbf offset.

	moveq	#Polygon.OFFSET_TAILSIZE/2-3,d7
.concat_tail_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,.concat_tail_loop

; Store offsetdata for outer dbf.
	subq	#4,a0					; a0: addy of dbf-data
	move.l	a0,d3
	move.l	#Polygon.offsetYloop,d3
	sub.l	a0,d3
	move.w	d3,(a0)					; Store offset.
	rts

; Note: this bitch only makes word-based pixelloops, due to optimisations.
; Also no pixelskipping is implemented. For a more complete but slower
; texturemapper, try the offset version.
Polygon.setPixelMapper:
; Move in pixel instruction for the texturemapper.
	lea	Polygon.texturePixelInstr,a0
	move.l	(Polygon.textureRoutTable,d0.w*8),a2
	movea.l	a2,a3
	move.l	(Polygon.textureRoutTable+4,d0.w*8),d3
	move.w	d3,d6
	move.w	d3,d4
	lsr.w	#1,d6
	subq.w	#1,d6
	move.w	d6,d5
	moveq	#1<<CHUNKLOG-1,d7

; Unroll pixeloop 2^CHUNKLOG times. This is nice and fast.
.instr_loop:
; Pump move, or, add, whatever.
.pump_loop:
	move.w	(a2)+,(a0)+
	dbf	d6,.pump_loop

	move.w	d5,d6
	movea.l	a3,a2
	dbf	d7,.instr_loop

; Create load jumptree instruction. Store the address data.
	move.l	a0,Polygon.textureLoadInstr+2		; 'lea jumptree,a2'

; Calc and store size for jump instruction {*1,*2,*4,*8}.
	move.w	Polygon.textureJmpInstr+2,d5
	andi.w	#%1111100111111111,d5
	lsl.w	#8,d3
	or.w	d3,d5
	move.w	d5,Polygon.textureJmpInstr+2

; Now kick in the dbf toghether with calculated offset data.
	lea	Polygon.textureTail,a1
	move.w	(a1)+,(a0)+				; Kick 2st word of 'dbf d6,'.
	addq	#2,a1
	move.l	#Polygon.texturePixelInstr,d3
	sub.l	a0,d3
	move.w	d3,(a0)+				; Kick in dbf offset.

	moveq	#Polygon.TEXTURE_TAILSIZE/2-3,d7
.concat_tail_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,.concat_tail_loop

; Store offsetdata for outer dbf.
	subq	#4,a0					; a0: addy of dbf-data
	move.l	a0,d3
	move.l	#Polygon.textureYloop,d3
	sub.l	a0,d3
	move.w	d3,(a0)					; Store offset.
	rts

;======= Viewport

Viewport.MAX_X:		=	320		; maximum x dimension
Viewport.MAX_Y:		=	200		; maximum y dimension

; Updates the viewport settings to the dsp.
; USES: Viewport.settingsTable
Viewport.update:
	lea	Viewport.settingsTable,a0
	moveq	#RPC_UPDATE_VIEWPORT,d0
	sendLongToDsp	d0
	moveq	#Viewport.SIZE/2-1,d7

.loop:	move.w	(a0)+,d0
	ext.l	d0
	sendLongToDsp	d0
	dbra	d7,.loop
	rts

; INPUT: d0.w: left x
;        d1.w: upper y
;        d6.w: right x
;        d7.w: lower y
;        d4.l: color (2 words)
Viewport.paintRectangle:
	movea.l	Primitive.screenadr,a0
	lea	Viewport.settingsTable,a1
	move.w	d6,d2

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
	move.w	d6,d2
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

	move.w	d7,d3
;	andi.w	#$FFFE,d2			; longeven startaddy! todo: make correct.
	adda.w	d2,a0
	adda.w	d2,a0
	move.w	Viewport.XSCREEN(a1),d5
	add.w	d5,d5
	movea.w	d5,a4
	mulu.w	d5,d3
	adda.l	d3,a0
; w=r-l+1, ceil(w/2)=(w+1)/2=(r-l+2)/2
	sub.w	d0,d6				; d6.w=r-l
	addq.w	#2,d6				; d6.w=r-l+2
	lsr.w	d6				; d6.w=(r-l+2)/2=ceil(w/2)
	sub.w	d1,d7
	move.l	d4,d0
	move.l	d4,d1
	move.l	d4,d2
	move.l	d4,d3
	movea.l	d4,a1
	movea.l	d4,a2
	movea.l	d4,a3
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

;======= PrimitiveMesh

; Marks the PrimitiveMesh as ready to roll.
PrimitiveMesh.new:
; Inform the dsp.
	moveq	#RPC_NEW_PRIMITIVEMESH,d0
	sendLongToDsp	d0

; Disable shadow handling.
	clr.l	d0
	move.w	d0,PrimitiveMesh.shadowsOn
	sendLongToDsp	d0
	rts

; Marks the PrimitiveMesh as ready to roll.
; INPUT:
; a0: shadow polygon buffer
PrimitiveMesh.newShadowed:
	moveq	#RPC_NEW_PRIMITIVEMESH,d0
	sendLongToDsp	d0

; Enable shadow handling.
	moveq	#1,d0
	move.w	d0,PrimitiveMesh.shadowsOn
	sendLongToDsp	d0
	move.l	a0,PrimitiveMesh.shadowStartAdr
	clr.w	(a0)+					; Clear counter.
	move.l	a0,PrimitiveMesh.shadowAdr
	rts

; Sort the elements.
PrimitiveMesh.sortZ:
	moveq	#RPC_SORT_PRIMITIVEMESH,d0
	sendLongToDsp	d0
	rts

; Indicate the mesh is ready for painting.
PrimitiveMesh.complete:
; Give the command..
	moveq	#RPC_PAINT_PRIMITIVES,d0
	sendLongToDsp	d0
	rts

; INPUT:
; a0: storage for bounding rectangles
PrimitiveMesh.paint:
	move.l	a0,-(sp)

; Now wait for a reply and paint them primitives.
.loop:	receiveWordFromDsp	d0		; d0=shadetype
	bmi.s	.end_paint			; d0<0 ? terminate!
	jsr	.jumpTable(pc,d0.w*4)
	bra.s	.loop
.end_paint:

; Killer! Now we receive all bounding rectangles in the scene.
	movea.l	(sp)+,a0
	receiveWordFromDsp	d7
	move.w	d7,(a0)+
	beq.s	.end
	lsl.w	#2,d7				; rectanglecount*words/rectangle = total words
	subq.w	#1,d7
.rect_loop:
	receiveWordFromDsp	(a0)+
	dbra	d7,.rect_loop

.end:	rts

.jumpTable:
	bra.w	Polygon.paintDspFlatshaded
	bra.w	Polygon.paintFastGouraudshaded
	bra.w	Polygon.paintDspTexturemapped
	bra.w	Polygon.paintDspAlphatextured
	bra.w	Polygon.paintDspBumpmapped
	bra.w	Sprite.paintReceived
	bra.w	Line.paintReceived

;======= Polygon

Polygon.MAX_TEXTURES:		=	32

Polygon.OFFSET_TEXTURING:	=	0
Polygon.PIXEL_TEXTURING:	=	1
Polygon.ALPHA_TEXTURING:	=	2
Polygon.BUMP_TEXTURING:		=	3
Polygon.FLAT_SHADING:		=	4
Polygon.GOURAUD_SHADING:	=	5

; Initializes polygonpainter lookup tables.
; INPUT:
; a0: texture-address-table
; a1: gouraud-tables
; OUTPUT:
; d0.l: 0=ok, -1=error
Polygon.init:
	move.l	a1,Polygon.coloradr

	bsr.w	Polygon.copyTextureTable

	tst.w	.mix_initialized(pc)
	bne.s	.done_mixing
	bsr.w	Primitive.initMsbMixTable
	bsr.w	Primitive.initLsbMixTable
	move.w	#1,.mix_initialized
.done_mixing:

	bsr.w	Polygon.deregisterBumpmaps

	bsr.w	Polygon.parseTextureTable

	move.w	d0,-(sp)
	bsr.w	Polygon.calcInvTable
	move.w	(sp)+,d0

	bsr.s	Polygon.setTextureMode

.success:
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

.mix_initialized:
	DC.W	0

; Copies specified texturetable to internal table.
Polygon.copyTextureTable:
	lea	Polygon.textureTable,a1
	moveq	#Polygon.MAX_TEXTURES-1,d7
.loop:	move.l	(a0)+,(a1)+
	dbeq	d7,.loop
	rts

; INPUT:
; d0.w=texturemode
Polygon.setTextureMode:
	move.w	d0,Polygon.texturemode

	cmpi.w	#Polygon.PIXEL_TEXTURING,d0
	beq.s	.end

.offset:cmpi.w	#Polygon.OFFSET_TEXTURING,d0
	bne.s	.end
; Set the dsp to sending back offsets.
	moveq	#RPC_SET_OFFSETPIXEL,d0
	sendLongToDsp	d0

.end:	rts

; Parses a table containing APX block textures and resets all addresses
; to point to the start of the pixeldata. Also installs all texturebuffers.
; PRECONDITIONS:
; The texturetable points to APX blocks.
; The texturetable is null-terminated.
; The texturetable does not contain over 16 highcolor and 8bpp textures.
; OUTPUT:
; d0.w=(Polygon.PIXEL_TEXTURING, Polygon.OFFSET_TEXTURING)
Polygon.parseTextureTable:
	lea	Polygon.textureTable,a0

; Get all textureaddresses and split them in the 8bpp and highcolor
; catagories.
.catagorization:
	clr.l	d1
	clr.l	d2
	clr.l	d3				; d3.l= #pixels (8bit)
	clr.l	d4				; d4.l= #pixels (16bit)
	lea	.wordTextureTable,a4
	lea	.byteTextureTable,a5

.storeloop:
	movea.l	(a0)+,a1
	tst.l	a1
	beq.s	.end_catagorization
	movem.w	12(a1),d6/d7			; d6.w=width, d7.w=height
	mulu.w	d6,d7				; d7.l=#pixels
	move.l	(a1),d0
.test_byte_per_pixel:
	cmpi.l	#"Byte",d0
	bne.s	.end_test_byte_per_pixel
	add.l	d7,d3
	addq.w	#1,d2
	move.l	a1,(a5)+			; Store 8bpp texture.
	lea	788(a1),a1
.end_test_byte_per_pixel:
.test_word_per_pixel:
	cmpi.l	#"Word",d0
	bne.s	.end_test_word_per_pixel
	add.l	d7,d4
	addq.w	#1,d1
	move.l	a1,(a4)+			; Store highcolor texture.
	lea	20(a1),a1
.end_test_word_per_pixel:
	move.l	a1,-4(a0)
.dont_send:
	bra.s	.storeloop
.end_catagorization:

; d1.w= number of highcolor textures
; d2.w= number of 8bpp textures
; d3.l= total 16bit pixels
; d4.l= total 8bit pixels
; If either the amount of 16bit or 8bit textures exceeds 2, use offsetmode.
	cmpi.w	#2,d1
	bgt	.init_offset_mode
	cmpi.w	#2,d2
	bgt	.init_offset_mode
; If either the amount of 16bit or 8bit pixels exceeds 8192, use offsetmode.
	cmpi.l	#8192,d3
	bgt	.init_offset_mode
	cmpi.l	#8192,d4
	bgt	.init_offset_mode

; Put all the textures toghether in a piece of texturecache.
; First the 16bit ones....
.cache_16bit:
	lea	Polygon.textureCache,a0
	lea	.wordTextureTable,a4
	subq.w	#1,d1
	bmi.s	.end_cache_16bit
.cache16bit_loop:
	movea.l	(a4)+,a1
	movem.w	12(a1),d6/d7
	lea	20(a1),a1
	mulu.w	d6,d7
	subq.w	#1,d7

.pixel16bitloop:
	addq	#1,a0
	move.w	(a1)+,(a0)+
	dbra	d7,.pixel16bitloop

	dbra	d1,.cache16bit_loop
.end_cache_16bit:

; Then the 8bit ones....
.cache_8bit:
	lea	Polygon.textureCache,a0
	lea	.byteTextureTable,a4
	subq.w	#1,d2
	bmi.s	.end_cache_8bit
.cache8bit_loop:
	movea.l	(a4)+,a1
	movem.w	12(a1),d6/d7
	lea	788(a1),a1
	mulu.w	d6,d7
	subq.w	#1,d7

.pixel8bitloop:
	move.b	(a1)+,(a0)+
	addq	#2,a0
	dbra	d7,.pixel8bitloop

	dbra	d2,.cache8bit_loop
.end_cache_8bit:

; Pump the texturecache over to the dsp.
	moveq	#RPC_STORE_TEXTURE,d7
	sendLongToDsp	d7
	lea	Polygon.textureCache,a1
	move.w	#8192-1,d7
.sendloop:
	move.b	(a1)+,d0
	swap	d0
	move.w	(a1)+,d0
	sendLongToDsp	d0
	dbra	d7,.sendloop

	move.w	#Polygon.PIXEL_TEXTURING,d0
.end:	rts

.init_offset_mode:
	move.w	#Polygon.OFFSET_TEXTURING,d0
	rts

; These store all textureaddresses found.
.wordTextureTable:
	DS.L	16
.byteTextureTable:
	DS.L	16

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
	cmpi.w	#Viewport.MAX_Y+1,d0
	blt.s	.posloop

	rts

; Calculates a 64K highcolor-word lookup table from two 256 truecolor
; palettes.
; INPUT: d7.w: start intensity of palette1
;        a0: highcolor lookuptable
;        a1: truecolor palette1
;        a2: truecolor palette2 (256 entries)
;        a5: number of entries in palette1
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

; Cuts bumpoffsets down to 12bits (0yyyyy0xxxxx).
; Converts a heightfield (8bpp) into a bumpmap (16bit).
; INPUT:
; a0: source APX heightmap (words)
Polygon.registerBumpmap:
	bsr	Polygon.addBumpmap
	movem.w	12(a0),d4/d7
	lea	20(a0),a0
	subq.w	#1,d7

.yloop:	move.w	d4,d6
	subq.w	#1,d6

.xloop:	moveq	#0,d0
	move.b	(a0),d0
	move.b	1(a0),d1
	lsr.b	#3,d0
	lsr.b	#3,d1
	lsl.w	#6,d0
	or.w	d1,d0
	move.w	d0,(a0)+
	dbra	d6,.xloop

	dbra	d7,.yloop
	rts

Polygon.deregisterBumpmaps:
	clr.w	Polygon.bumpmapTable
	rts

; INPUT:
; a0: bumpmap to add
Polygon.addBumpmap:
	lea	Polygon.bumpmapTable,a1
	move.w	(a1)+,d7
	move.l	a0,(a1,d7.w*4)
	addq.w	#1,-(a1)
	rts

; INPUT:
; a0: address of potential bumpmap (APX)
; OUTPUT:
; d0.l= 1: yes, 0: no
Polygon.isBumpmap:
	lea	Polygon.bumpmapTable,a1
	move.w	(a1)+,d7
	subq.w	#1,d7
	bmi.s	.no_match

.loop:	cmpa.l	(a1)+,a0
	beq.s	.match
	dbra	d7,.loop
.no_match:
	moveq	#0,d0
	rts
.match:	moveq	#1,d0				; You've been elected bumpmap of the day!
	rts

Polygon.flatRoutTable:
	DC.L	Polygon.pixelFlatMoved,2
	DC.L	Polygon.pixelFlatOrred,2
	DC.L	Polygon.pixelFlatAdded,2
	DC.L	Polygon.pixelFlatceilAdded,10
Polygon.gouraudRoutTable:
	DC.L	Polygon.pixelGouraudMoved,4
	DC.L	Polygon.pixelGouraudOrred,6
	DC.L	Polygon.pixelGouraudAdded,6
	DC.L	Polygon.pixelGouraudceilAdded,12
Polygon.offsetRoutTable:
	DC.L	Polygon.pixelOffsetMoved,4
	DC.L	Polygon.pixelOffsetOrred,6
	DC.L	Polygon.pixelOffsetAdded,6
	DC.L	Polygon.pixelOffsetceilAdded,2
Polygon.textureRoutTable:
	DC.L	Polygon.pixelTextureMoved,2
	DC.L	Polygon.pixelTextureOrred,4
	DC.L	Polygon.pixelTextureAdded,4
	DC.L	Polygon.pixelTextureceilAdded,2
	IFNE	0
Polygon.bumpRoutTable:
	DC.L	Polygon.pixelBumpMoved
	DC.L	Polygon.pixelBumpOrred
	DC.L	Polygon.pixelBumpAdded
	DC.L	Polygon.pixelBumpceilAdded
Polygon.alphaRoutTable:
	DC.L	Polygon.pixelAlphaMoved
	DC.L	Polygon.pixelAlphaOrred
	DC.L	Polygon.pixelAlphaAdded
	DC.L	Polygon.pixelAlphaceilAdded
	ENDC

Polygon.pixelFlatMoved:
	move.b	d4,(a1)+
	move.w	d4,(a1)+

Polygon.pixelFlatOrred:
	or.b	d4,(a1)+
	or.w	d4,(a1)+

Polygon.pixelFlatAdded:
	add.b	d4,(a1)+
	add.w	d4,(a1)+

Polygon.pixelFlatceilAdded:
	move.b	(a1),d3
	add.b	d4,d3
	scs	d2
	or.b	d2,d4
	move.b	d4,(a1)+
	move.w	d4,(a1)+

Polygon.flatTail:
	dbra	d6,*-2

	adda.l	a5,a0
	add.l	d2,d0
	add.l	d3,d1
	DC.W	$51CF,$FFD4			; dbra	d7,.yloop
	rts
Polygon.flatTailEnd:

Polygon.FLAT_TAILSIZE:	=	Polygon.flatTailEnd-Polygon.flatTail

Polygon.pixelGouraudMoved:
	move.b	(a2,d0.w*2),(a0)+
	move.w	(a2,d0.w*2),(a0)+

Polygon.pixelGouraudOrred:
	move.b	(a2,d0.w*2),d2
	or.b	d2,(a0)+
	move.w	(a2,d0.w*2),d2
	or.w	d2,(a0)+

Polygon.pixelGouraudAdded:
	move.b	(a2,d0.w*2),d2
	add.b	d2,(a0)+
	move.w	(a2,d0.w*2),d2
	add.w	d2,(a0)+

Polygon.pixelGouraudceilAdded:
	move.b	(a2,d0.w*2),d2
	add.b	(a0),d2
	scs	d3
	or.b	d3,d2
	move.b	d2,(a0)+
	move.w	(a2,d0.w*2),(a0)+

Polygon.gouraudTail:
	addx.l	d1,d0
	dbra	d6,*-2

	adda.l	d5,a6
	DC.W	$51CF,$FFC4			; dbra	d7,.yloop
	rts
Polygon.gouraudTailEnd:

Polygon.GOURAUD_TAILSIZE:=	Polygon.gouraudTailEnd-Polygon.gouraudTail

Polygon.pixelOffsetMoved:
	move.b	(a2,d1.l*2),(a0)+
	move.w	(a2,d1.l*2),(a0)+

Polygon.pixelOffsetOrred:
	move.b	(a2,d1.l*2),d0
	or.b	d0,(a0)+
	move.w	(a2,d1.l*2),d0
	or.w	d0,(a0)+

Polygon.pixelOffsetAdded:
	move.b	(a2,d1.l*2),d0
	add.b	d0,(a0)+
	move.w	(a2,d1.l*2),d0
	add.w	d0,(a0)+

Polygon.pixelOffsetceilAdded:
	nop
	nop

Polygon.offsetTail:
	dbra	d6,*

	adda.l	d5,a6
	dbra	d7,*
	rts
Polygon.offsetTailEnd:

Polygon.OFFSET_TAILSIZE:=	Polygon.offsetTailEnd-Polygon.offsetTail

Polygon.pixelTextureMoved:
	move.w	(a1),(a0)+

Polygon.pixelTextureOrred:
	move.w	(a1),d0
	or.w	d0,(a0)+

Polygon.pixelTextureAdded:
	move.w	(a1),d0
	add.w	d0,(a0)+

Polygon.pixelTextureceilAdded:
	move.w	(a1),(a0)+		; simple move replacement!

Polygon.textureTail:
	dbra	d6,*

	adda.l	d5,a6
	dbra	d7,*
	rts
Polygon.textureTailEnd:

Polygon.TEXTURE_TAILSIZE:=	Polygon.textureTailEnd-Polygon.textureTail

; INPUT:
; d0.l= color
; a1: shadow polygon table
Polygon.clearShadows:
	clr.l	PrimitiveMesh.background
	move.w	(a1)+,d7
	beq.s	.end
	subq.w	#1,d7
	move.l	d0,Polygon.color

.loop:	move.w	d7,-(sp)
	bsr.s	Polygon.paintFlatshadedC
	move.w	(sp)+,d7
	dbf	d7,.loop

.end:	rts

; INPUT:
; a0: background picture (same dimensions as viewport!)
; a1: shadow polygon table
Polygon.restoreShadows:
	move.l	a0,PrimitiveMesh.background
	move.w	(a1)+,d7
	beq.s	.end
	subq.w	#1,d7

.loop:	move.w	d7,-(sp)
	bsr.s	Polygon.paintFlatshadedC
	move.w	(sp)+,d7
	dbf	d7,.loop

.end:	rts

; Splits a flatshaded polygon up into triangles and paints them.
; INPUT:
; a1: polygon (col.w, #points.w, (x,y), (x,y), ...)
; OUTPUT:
; a1: end of poly
Polygon.paintFlatshaded:
	moveq	#0,d0
	move.w	(a1)+,d0
	movea.l	Polygon.coloradr,a0
	lea	Primitive.GRADIENTSIZE/2(a0),a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0
	move.w	(a0,d0.l),d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,Polygon.color

; Splits a flatshaded polygon up into triangles and paints them.
; INPUT:
; a1: polygon (#points.w, (x,y), (x,y), ...)
; OUTPUT:
; a1: end of poly
Polygon.paintFlatshadedC:
	move.w	(a1)+,d7
	movem.w	(a1)+,d0-d1
	subq.w	#3,d7
	movem.w	d0-d1,-(sp)			; Push first pair on stack.

.loop:	movem.w	(a1)+,d2-d3
	movem.w	(a1),d4-d5
	move.w	d7,-(sp)
	move.l	a1,-(sp)
	bsr	PAINT_UNCLIPFLATTRIANGLE
	movea.l	(sp)+,a1
	move.w	(sp)+,d7
	movem.w	(sp),d0-d1
	dbf	d7,.loop
	addq	#4,sp				; Pop first pair off.
	addq	#4,a1				; a1: end of poly
	rts

Polygon.FLATUNROLL:	=	0

; Splits a flatshaded polygon up into triangles and paints them.
; Receives the crap from the hostport.
Polygon.paintDspFlatshaded:
	clr.l	d0
	receiveWordFromDsp	d0
	movea.l	Polygon.coloradr,a0
	lea	Primitive.GRADIENTSIZE/2(a0),a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0
	move.w	(a0,d0.l),d2
	move.w	d2,d1
	swap	d2
	move.w	d1,d2
	bra.s	Polygon.paintDspFlatshaded3

Polygon.paintDspFlatshaded2:
	move.l	Polygon.color,d2
Polygon.paintDspFlatshaded3:
	movea.l	Primitive.screenadr,a0
	receiveWordFromDsp	d0		; d0.w=top y
	clr.l	d5
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d5
	add.l	d5,d5
	mulu.w	d5,d0
	adda.l	d0,a0
	receiveWordFromDsp	d7		; d7.w=#scans
	clr.l	d0
	clr.l	d1
	lea	$FFFFA206.w,a3
	subq.w	#1,d7
	bmi.s	.end

	IFNE	Polygon.FLATUNROLL
	moveq	#1<<5-1,d4
	lea	.pixeljumpend(pc),a2
	ENDC

.yloop:	move.w	(a3),d0				; d0.w=lx
	move.w	(a3),d1				; d1.w=rx
	sub.w	d0,d1				; d1.w=length=rx-lx
	ble.s	.next
	lea	(a0,d0.l*2),a1

	IFNE	0

	lsr.w	d0
	bcc.s	.end_1st
	move.w	d2,(a1)+
	subq.w	#1,d1
	ble.s	.next
.end_1st:
	move.w	d1,d0
	lsr.w	d1
	beq.s	.last
	subq.w	#1,d1
.pixloop:
	move.l	d2,(a1)+
	dbf	d1,.pixloop
.last:	lsr.w	d0
	bcc.s	.end_last
	move.w	d2,(a1)+
.end_last:

	ELSE

	IFNE	Polygon.FLATUNROLL

	move.l	d1,d3
	lsr.l	#5,d1
	and.w	d4,d3
	neg.l	d3
	jmp	(a2,d3.l*2)

	IFNE	*&2					; Put it longeven!
	nop
	ENDC
.chunkloop:
	REPT	1<<5
	move.w	d2,(a1)+
	ENDR
.pixeljumpend:
	dbf	d1,.chunkloop

	ELSE

	subq.w	#1,d1

.xloop:	move.w	d2,(a1)+
	dbf	d1,.xloop

	ENDC

	ENDC

.next:	adda.l	d5,a0
	dbf	d7,.yloop
.end:	rts

; Paints a gouraudshaded polygon.
; INPUT: a1: polygon
Polygon.paintGouraudshaded:
	move.w	(a1)+,Polygon.curtexture
	move.w	#Polygon.GOURAUD_SHADING,d0
	moveq	#2,d6
	bra	Polygon.paintDsp

; Paints a gouraudshaded polygon directly (slope recalc per scan included!).
; Receives tha crap from the hostport.
Polygon.paintFastGouraudshaded:
	move.w	#Polygon.GOURAUD_SHADING,d0
	moveq	#2,d6
	bra	Polygon.paintReceived

; Splits a texturemapped polygon up into triangles and paints them.
; INPUT: a1: polygon
Polygon.paintTextured:
	move.w	(a1)+,Polygon.curtexture
	move.w	Polygon.texturemode,d0
	moveq	#3,d6
	bra.s	Polygon.paintDsp

; Splits an alpha-texturemapped polygon up into triangles and paints them.
; INPUT: a1: polygon
Polygon.paintAlphatextured:
	move.w	(a1)+,Polygon.curtexture
	moveq	#RPC_SET_V4ALPHA,d0
	sendLongToDsp	d0
	move.w	#Polygon.ALPHA_TEXTURING,d0
	moveq	#5,d6
	bra.s	Polygon.paintDsp

; Splits an alpha-texturemapped polygon up into triangles and paints them.
; INPUT: a1: polygon
Polygon.paintBumpmapped:
	move.w	(a1)+,Polygon.curtexture
	moveq	#RPC_SET_V4BUMP,d0
	sendLongToDsp	d0
	move.w	#Polygon.BUMP_TEXTURING,d0
	moveq	#5,d6

; Sends polygon data to the dsp, receives incoming scanline data and paints
; it to the screen.
; This works for all shadetypes.
; INPUT:
; d0.w:	DSP texturing mode
; d6.w:	number of coordinates in point
;       (1=flat, 2=gouraud, 3=texture, 4=gouraudtexture, 5=alpha/bumpmap)
; a1: polygon table
Polygon.paintDsp:
	sendLongToDsp	#RPC_PAINT_POLYGON		; Call the DSP.

	clr.l	d1
	move.w	Polygon.curtexture,d1
	sendLongToDsp	d1				; Send texturenumber.
	clr.l	d7
	move.w	(a1)+,d7
	sendLongToDsp	d7				; Send number of points.
	move.l	d6,$ffffa204.w
	subq.w	#2,d6
	subq.w	#1,d7

.pointloop:
	movem.w	(a1)+,d1-d2
	;sendLongToDsp	d2				; Send Y.
	move.l	d2,$ffffa204.w
	;sendLongToDsp	d1				; Send X.
	move.l	d1,$ffffa204.w
	move.w	d6,d5
	bmi.s	.skip_coords

; Send u0,v0,u1,v1
.coordloop:
	moveq	#0,d1
	move.w	(a1)+,d1
	swap	d1
	lsr.l	#1,d1
	;sendLongToDsp	d1
	move.l	d1,$ffffa204.w
	dbra	d5,.coordloop
.skip_coords:

	dbra	d7,.pointloop

	lea	$FFFFA206.w,a1
	clr.l	d2
	receiveWordFromDsp	d2			; Get texture number.
	movea.l	Primitive.screenadr,a0
	moveq	#0,d5
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d5
	add.l	d5,d5
	;receiveWordFromDsp	d1			; Get top y.
	move.w	(a1),d1
	mulu.w	d5,d1
	adda.l	d1,a0
	movea.l	a0,a6
	;receiveWordFromDsp	d7			; Get height.
	move.w	(a1),d7
	subq.w	#1,d7
	bpl.s	.go_on
	rts
.go_on:	clr.l	d1
	cmpi.w	#Polygon.GOURAUD_SHADING,d0
	beq	PAINT_GOURAUDPOLY
	cmpi.w	#Polygon.PIXEL_TEXTURING,d0
	beq	PAINT_PIXELDSPPOLY
	cmpi.w	#Polygon.OFFSET_TEXTURING,d0
	beq	PAINT_OFFSETDSPPOLY
	cmpi.w	#Polygon.ALPHA_TEXTURING,d0
	beq	PAINT_ALPHADSPPOLY
	cmpi.w	#Polygon.BUMP_TEXTURING,d0
	beq	PAINT_BUMPDSPPOLY
	rts

; INPUT:
; a1: polygon table (texturenum.w, numofpoints.w, points)
Polygon.paintClippedFlatshaded:
	moveq	#0,d0
	move.w	(a1)+,d0
	movea.l	Polygon.coloradr,a0
	lea	Primitive.GRADIENTSIZE/2(a0),a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0
	move.w	(a0,d0.l),d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,Polygon.color
	move.w	#Polygon.FLAT_SHADING,d0
	moveq	#1,d6
	bra.s	Polygon.paintClipped

; INPUT:
; a1: polygon table (texturenum.w, numofpoints.w, points)
Polygon.paintClippedGouraudshaded:
	clr.l	d0
	move.w	(a1)+,d0
	movea.l	Polygon.coloradr,a0
	lsl.l	#Primitive.GRADIENTBITS+1,d0				; d0*(64*2)
	adda.l	d0,a0
	move.l	a0,Polygon.gradadr
	move.w	#Polygon.GOURAUD_SHADING,d0
	moveq	#2,d6
	bra.s	Polygon.paintClipped

; INPUT:
; a1: polygon table (texturenum.w, numofpoints.w, points)
Polygon.paintClippedTextured:
	move.w	(a1)+,Polygon.curtexture
	move.w	Polygon.texturemode,d0
	moveq	#3,d6
	bra.s	Polygon.paintClipped

; INPUT:
; a1: polygon table (texturenum.w, numofpoints.w, points)
Polygon.paintClippedAlphatextured:
	move.w	(a1)+,Polygon.curtexture
	moveq	#RPC_SET_V4ALPHA,d0
	sendLongToDsp	d0
	move.w	#Polygon.ALPHA_TEXTURING,d0
	moveq	#5,d6
	bra.s	Polygon.paintClipped

; INPUT:
; a1: polygon table (texturenum.w, numofpoints.w, points)
Polygon.paintClippedBumpmapped:
	move.w	(a1)+,Polygon.curtexture
	moveq	#RPC_SET_V4BUMP,d0
	sendLongToDsp	d0
	move.w	#Polygon.BUMP_TEXTURING,d0
	moveq	#5,d6

; Sends polygon data to the dsp, receives incoming scanline data and paints
; it to the screen. Ofcourse this clips as well! This is a HumanFly
; interface implementation!
; INPUT:
; d0.w:	DSP texturing mode
; d6.l:	number of coordinates in point
;       (1=flat, 2=gouraud, 3=texture, 4=gouraudtexture, 5=alpha/bumpmap)
; a1: polygon table (numofpoints.w, points)
Polygon.paintClipped:
	sendLongToDsp	#RPC_CLIPPAINT_POLYGON		; Call the DSP.

	clr.l	d1
	move.w	Polygon.curtexture,d1
	sendLongToDsp	d1				; Send texturenumber.
	move.w	(a1)+,d7
	ext.l	d7
	sendLongToDsp	d7				; Send number of points.
	;sendLongToDsp	d6				; Send pointsize.
	move.l	d6,$FFFFA204.w
	subq.w	#2,d6
	subq.w	#1,d7

.pointloop:
	movem.w	(a1)+,d1-d2
	;sendLongToDsp	d2				; Send Y.
	move.l	d2,$ffffa204.w
	;sendLongToDsp	d1				; Send X.
	move.l	d1,$ffffa204.w
	move.w	d6,d5
	bmi.s	.skip_coords

; Send u0,v0,u1,v1
.coordloop:
	moveq	#0,d1
	move.w	(a1)+,d1
	swap	d1
	lsr.l	#1,d1
	;sendLongToDsp	d1
	move.l	d1,$ffffa204.w
	dbf	d5,.coordloop
.skip_coords:

	dbf	d7,.pointloop

	receiveWordFromDsp	d7			; d7=cullstatus
	bmi.s	.end					; Culled off?
	clr.l	d2
	receiveWordFromDsp	d2			; Get texture number.

	cmpi.w	#Polygon.FLAT_SHADING,d0
	beq	Polygon.paintDspFlatshaded2

	lea	$ffffa206.w,a1
	movea.l	Primitive.screenadr,a0
	moveq	#0,d5
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d5
	add.l	d5,d5

	receiveWordFromDsp	d1			; Get top y.
	;move.w	(a1),d1

	mulu.w	d5,d1
	adda.l	d1,a0
	movea.l	a0,a6
	;receiveWordFromDsp	d7			; Get height.
	move.w	(a1),d7
	subq.w	#1,d7
	bpl.s	.go_on
.end:	rts
.go_on:	clr.l	d1
	cmpi.w	#Polygon.GOURAUD_SHADING,d0
	beq	PAINT_GOURAUDPOLY
	cmpi.w	#Polygon.PIXEL_TEXTURING,d0
	beq	PAINT_PIXELDSPPOLY
	cmpi.w	#Polygon.OFFSET_TEXTURING,d0
	beq	PAINT_OFFSETDSPPOLY
	cmpi.w	#Polygon.ALPHA_TEXTURING,d0
	beq	PAINT_ALPHADSPPOLY
	cmpi.w	#Polygon.BUMP_TEXTURING,d0
	beq	PAINT_BUMPDSPPOLY
	rts

; Splits a texturemapped polygon up into triangles and paints them.
; Receives shit over hostport.
Polygon.paintDspTexturemapped:
	move.w	Polygon.texturemode,d0
	moveq	#3,d6
	bra.s	Polygon.paintReceived

; Splits an alpha-texturemapped polygon up into triangles and paints them.
; Receives trash over hostport.
Polygon.paintDspAlphatextured:
	moveq	#RPC_SET_V4ALPHA,d0
	move.w	#Polygon.ALPHA_TEXTURING,d0
	moveq	#5,d6
	bra.s	Polygon.paintReceived

; Splits an alpha-texturemapped polygon up into triangles and paints them.
; Receives rotteness over hostport.
Polygon.paintDspBumpmapped:
	moveq	#RPC_SET_V4BUMP,d0
	move.w	#Polygon.BUMP_TEXTURING,d0
	moveq	#5,d6

; Receives incoming scanline data and paints it to the screen.
; This works for all shadetypes.
; INPUT:
; d0.w=	DSP texturing mode (shadetype)
; d6.w=	number of coordinates in point
;       (1=flat, 2=gouraud, 3=texture, 4=gouraudtexture, 5=alpha/bumpmap)
Polygon.paintReceived:
	lea	$FFFFA206.w,a1

; 1: Receive and store polygon outline...
	tst.w	PrimitiveMesh.shadowsOn
	beq.s	.outline_end

	movea.l	PrimitiveMesh.shadowStartAdr,a2
	addq.w	#1,(a2)					; Increase shadow poly count.
	movea.l	PrimitiveMesh.shadowAdr,a2

	receiveWordFromDsp	d5			; d5.w=#vertices
	;move.w	(a1),d5

	move.w	d5,(a2)+				; Store #vertices.
	subq.w	#1,d5
.outline_loop:
; Receive x.
	;receiveWordFromDsp	(a2)+
	move.w	(a1),(a2)+
; Receive y.
	;receiveWordFromDsp	(a2)+
	move.w	(a1),(a2)+
	dbf	d5,.outline_loop

	move.l	a2,PrimitiveMesh.shadowAdr
.outline_end:

; 2: Receive and handle painting info..
	clr.l	d2

	receiveWordFromDsp	d2			; Get shadetype.
	;move.w	(a1),d2
	;receiveWordFromDsp	d1			; Get top y.
	move.w	(a1),d1
	;receiveWordFromDsp	d7			; Get height.
	move.w	(a1),d7

	subq.w	#1,d7
	bpl.s	.go_on
	rts

; d1.w=top y
; d2.w=shadetype
; d7.w=height-1
.go_on:	movea.l	Primitive.screenadr,a0
	clr.l	d5
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d5
	add.l	d5,d5
	mulu.w	d5,d1
	adda.l	d1,a0
	movea.l	a0,a6
; a0=a6=screen pos
; d7.w=height-1

; 3: and paint..
	clr.l	d1
	cmpi.w	#Polygon.GOURAUD_SHADING,d0
	beq	PAINT_GOURAUDPOLY
	cmpi.w	#Polygon.PIXEL_TEXTURING,d0
	beq	PAINT_PIXELDSPPOLY
	cmpi.w	#Polygon.OFFSET_TEXTURING,d0
	beq	PAINT_OFFSETDSPPOLY
	cmpi.w	#Polygon.ALPHA_TEXTURING,d0
	beq	PAINT_ALPHADSPPOLY
	cmpi.w	#Polygon.BUMP_TEXTURING,d0
	beq	PAINT_BUMPDSPPOLY
	rts

; This should be both fast as well as accurate. At least.. faster than
; texturemapping. Prolly something like 1.500.000 pixels/s on standard
; Falcon.
PAINT_GOURAUDPOLY:
	movea.w	Primitive.skipBytes,a3
	movea.l	Polygon.coloradr,a2
	lsl.l	#Primitive.GRADIENTBITS+1,d2				; d0*(64*2)
	adda.l	d2,a2

Polygon.gouraudYloop:
.wait:	btst.b	#0,$ffffa202.w
	beq.s	.wait

	move.w	(a1),d1					; Get left x.
	lea	(a6,d1.w*2),a0
	move.w	(a1),d6					; Get width.
	clr.l	d0
	clr.l	d1
	receiveLongFromDsp	d0			; d0.l = left u
	swap	d0
	ext.w	d0
	receiveLongFromDsp	d1			; d1.l = u_step
	swap	d1
	ext.w	d1
	subq.w	#1,d6
	bpl.s	.go_on
	adda.l	d5,a6
	dbra	d7,Polygon.gouraudYloop	
	rts
.go_on:

Polygon.gouraudPixelInstr:
.xloop:	move.w	(a2,d0.w*2),(a0)+
	addx.l	d1,d0
	dbra	d6,.xloop

	adda.l	d5,a6
	dbra	d7,Polygon.gouraudYloop
	rts

	nop						; for code gen crap
	nop
	nop
	nop

CHUNKLOG:	=	4

; This is slow. But since it can do a polygon instead of only a triangle,
; I'm content. Speed on a plain falcon is 500.000 texels/s _including_
; overhead.
; INPUT:
; d2.w= texturenumber
PAINT_OFFSETDSPPOLY:
	clr.l	d1
	movea.w	Primitive.skipBytes,a3
	lea	Polygon.textureTable,a2
	movea.l	(a2,d2.w*4),a2

Polygon.offsetYloop:
	move.w	(a1),d1					; d1.w=lx
	lea	(a6,d1.l*2),a0
	receiveWordFromDsp	d6			; d6.w=width
	bgt.s	.go_on
	adda.l	d5,a6
	dbra	d7,Polygon.offsetYloop
	rts
.go_on:	subq.w	#1,d6

	move.w	(a1),d1
Polygon.offsetPixelInstr:
	move.w	(a2,d1.l*2),(a0)+
	dbra	d6,Polygon.offsetPixelInstr-2

	adda.l	d5,a6
	dbra	d7,Polygon.offsetYloop
	rts

	nop
	nop

DSP_SYNC:	=	1

; This is fast on a plain falcon. In fact, it kicks every other rout
; I've seen square in the nuts!!! =)) Speeds of 1.100.000 texels/s
; _including_ overhead are no exception!
; Though this unrolled jumptree sucks on ct2.
PAINT_PIXELDSPPOLY:
	moveq	#1<<CHUNKLOG-1,d4
Polygon.textureLoadInstr:
	lea	Polygon.pixeljumpend,a2
	clr.l	d6

Polygon.textureYloop:
.yloop:	move.w	(a1),d1					; Get left x.
	lea	(a6,d1.l*2),a0
	move.w	(a1),d6					; Get width.
	bgt.s	.go_on
	adda.l	d5,a6
	dbra	d7,.yloop
	rts
.go_on:	move.l	d6,d3
	lsr.l	#CHUNKLOG,d6
	and.l	d4,d3
	neg.l	d3
Polygon.textureJmpInstr:
	jmp	(a2,d3.l*2)

	IFNE	*&2					; Put it longeven!
	nop
	ENDC

Polygon.texturePixelInstr:
	REPT	1<<CHUNKLOG
	move.w	(a1),(a0)+
	ENDR
Polygon.pixeljumpend:
	dbf	d6,Polygon.texturePixelInstr

	adda.l	d5,a6
	dbf	d7,Polygon.textureYloop
	rts

	DS.W	1<<CHUNKLOG

; Speed of >500.000 texels/s _including_ overhead.
PAINT_ALPHADSPPOLY:
	movea.l	Polygon.alphatableadr,a2

.yloop:	move.w	(a1),d1					; Get left x.
	lea	(a6,d1.l*2),a0
	move.w	(a1),d6					; Get width.
	subq.w	#1,d6
	bmi.s	.end_xloop

.wait:	btst.b	#0,$FFFFA202.w
	beq.s	.wait

.xloop:	move.w	(a1),d1
	move.w	(a2,d1.l*2),(a0)+
; Shit! takes 14 cycles to sync on CT2.
	IFNE	DSP_SYNC
	rol.l	d0,d0
	rol.l	#4,d0
	ENDC
	dbra	d6,.xloop
.end_xloop:

	adda.l	d5,a6
	dbra	d7,.yloop

.end:	rts

; Speed of 800.000 texels/s _including_ overhead.
PAINT_BUMPDSPPOLY:
.yloop:	move.w	(a1),d1					; Get left x.
	lea	(a6,d1.l*2),a0
	move.w	(a1),d6					; Get width.
	subq.w	#1,d6
	bmi.s	.end_xloop

.wait:	btst.b	#0,$ffffa202.w
	beq.s	.wait

.xloop:	move.w	(a1),(a0)+
; Shit! takes 16 cycles to sync on CT2.
	IFNE	DSP_SYNC
	rol.l	d0,d0
	rol.l	d0,d0
	nop
	nop
	ELSE
	nop						; needed even on plain falcon!!
	nop
	ENDC
	dbra	d6,.xloop
.end_xloop:

	adda.l	d5,a6
	dbra	d7,.yloop

.end:	rts

;======= Fragment

			RSRESET
Fragment.LSLOPE:	RS.L	1		; 16:16 fixed point
Fragment.RSLOPE:	RS.L	1		; 16:16 fixed point
Fragment.LX:		RS.W	1		; left X
Fragment.RX:		RS.W	1		; right X
Fragment.LUSTART:	RS.W	1		; 8:8 index
Fragment.LVSTART:	RS.W	1		; 8:8 index
Fragment.RUSTART:	RS.W	1		; 8:8 index
Fragment.RVSTART:	RS.W	1		; 8:8 index
Fragment.LUSLOPE:	RS.W	1		; 8:8 slope
Fragment.LVSLOPE:	RS.W	1		; 8:8 slope
Fragment.RUSLOPE:	RS.W	1		; 8:8 slope
Fragment.RVSLOPE:	RS.W	1		; 8:8 slope
Fragment.START:		RS.W	1		; start scanline of fragment
Fragment.HEIGHT:	RS.W	1		; height of fragment
Fragment.SIZE:		RS.B	0

Fragment.shadeMask:	=	%00000111
Fragment.shadeFlat:	=	%000
Fragment.shadeGradient:	=	%001
Fragment.shadeTexture:	=	%010
Fragment.shadeAlpha:	=	%011
Fragment.shadeBump:	=	%100
Fragment.maskMode:	=	%00001000
Fragment.clipMode:	=	%00010000

; Paints an unclipped triangle. No in-/off-screen check whatsoever!
; Make sure triangle is 100% IN SCREEN!
; INPUT:
; d0.l: X0
; d1.l: Y0
; d2.l: X1
; d3.l: Y1
; d4.l: X2
; d5.l: X2
PAINT_UNCLIPFLATTRIANGLE:
; Sort points in Y-order.
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
; X2-X1 X3-X1 X3-X2
; Y2-Y1 Y3-Y1 Y3-Y2
	sub.l	d2,d4				; X3-X2
	sub.l	d0,d2				; X2-X1
	suba.l	d0,a4				; X3-X1
	move.l	d2,d0
	move.l	a4,d2
	sub.l	d3,d5				; Y3-Y2
	sub.l	d1,d3				; Y2-Y1
	suba.l	d1,a5				; Y3-Y1
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

; side 1: upper point <-> middle point
; d0.l: 16:16 slope of side 1
; d1.l: height of side 1
; side 2: upper point <-> lower point
; d2.l: 16:16 slope of side 2
; d3.l: height of side 2
; side 3: middle point <-> lower point
; d4.l: 16:16 slope of side 3
; d5.l: heigth of side 3

; Special case for triangles that have a horizontal edge.
	move.w	a3,.a3
	tst.l	PrimitiveMesh.background
	beq.s	.clear_it
	lea	RESTORE_UNCLIPFLATFRAG(pc),a4
	bra.s	.rout_set
.clear_it:
	lea	PAINT_UNCLIPFLATFRAGMENT(pc),a4
.rout_set:
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
	movea.l	PrimitiveMesh.background,a3
	move.l	a1,d6
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d6
	add.l	d6,d6
	adda.l	d6,a0
	adda.l	d6,a3

	jmp	(a4)

.make_fragments:
	lea	Polygon.fragmentTable,a6
	cmp.l	d0,d2
	blt.s	.make_fragments_rl

.make_fragments_lr:
	move.l	d4,(a6)+			; Store left slope.
	move.l	d2,(a6)+			; Store right slope.
	move.w	a2,(a6)+			; Store left x.
	move.w	#$8000,(a6)+			; Store right x.
	move.w	.a3(pc),(a6)+			; Store y.
	move.w	d5,(a6)+			; Store height.

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
	movea.l	PrimitiveMesh.background,a3
	move.w	a1,d6
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d6
	add.l	d6,d6
	adda.l	d6,a0
	adda.l	d6,a3

	jsr	(a4)

.end_paint_upper_lr:

 	bra.s	.end_make_fragments

.make_fragments_rl:
	move.l	d2,(a6)+			; Store left slope.
	move.l	d4,(a6)+			; Store right slope.
	move.w	#$8000,(a6)+			; Store left x.
	move.w	a2,(a6)+			; Store right x.
	move.w	.a3(pc),(a6)+			; Store y.
	move.w	d5,(a6)+			; Store height.

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
	movea.l	PrimitiveMesh.background,a3
	move.w	a1,d6
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d6
	add.l	d6,d6
	adda.l	d6,a0
	adda.l	d6,a3

	jsr	(a4)

.end_paint_upper_rl:

.end_make_fragments:

.paint_lower_fragment:
;	bra	.end_paint_fragments
	lea	-16(a6),a6
	move.l	(a6)+,d2			; Get left slope.
	move.l	(a6)+,d3			; Get right slope.

.get_new_lx:
	moveq	#0,d7
	move.w	(a6)+,d7			; Get left x.
	cmpi.w	#$8000,d7
	beq.s	.end_get_new_lx
	move.l	d7,d0
	swap	d0
.end_get_new_lx:

.get_new_rx:
	move.w	(a6)+,d7			; Get right x.
	cmpi.w	#$8000,d7
	beq.s	.end_get_new_rx
	move.l	d7,d1
	swap	d1
.end_get_new_rx:

	movea.l	Primitive.screenadr,a0
	movea.l	PrimitiveMesh.background,a3
	move.w	(a6)+,d7			; Get y.
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d7
	add.l	d7,d7
	adda.l	d7,a0
	adda.l	d7,a3
	move.w	(a6)+,d7			; Get height.
	subq.w	#1,d7
	bmi.s	.end_paint_fragments

	jmp	(a4)

.skip_lower_fragment:
.end_paint_fragments:

.end_paint_triangle:
	rts

.a3:	DC.W	0

; Subroutine that paints a flatshaded fragment. NO clipping!
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d4.l: 16:16 color (double highcolor)
; d7.w: number of scanlines to paint - 1
; a0: start of begin screenline
; OUTPUT: a0: start of next screenline
PAINT_UNCLIPFLATFRAGMENT:
	movea.w	Viewport.settingsTable+Viewport.XSCREEN,a5
	adda.l	a5,a5
	movea.w	Primitive.skipBytes,a2

Polygon.flatFragmentYloop:
.yloop:	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

	sub.w	d5,d6
	bgt.s	.go_on

	adda.l	a5,a0
	add.l	d2,d0
	add.l	d3,d1
	dbra	d7,.yloop
	rts

.go_on:	subq.w	#1,d6
	lea	(a0,d5.w*2),a1

Polygon.flatPixelInstr:
.xloop:	move.w	d4,(a1)+
	dbf	d6,.xloop

	adda.l	a5,a0
	add.l	d2,d0
	add.l	d3,d1
	dbf	d7,Polygon.flatFragmentYloop
	rts

	nop						; crap for code-gen
	nop
	nop
	nop

; TODO: prepare this for different paintmodes! (byte, skip)
; Subroutine that restores a fragment. NO clipping!
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d4.l: 16:16 color (double highcolor)
; d7.w: number of scanlines to paint - 1
; a0: dst screenline
; a3: src screenline
; OUTPUT:
; a0: next dst screenline
; a3: next src screenline
RESTORE_UNCLIPFLATFRAG:
	movea.w	Viewport.settingsTable+Viewport.XSCREEN,a5
	adda.l	a5,a5
	movea.w	Primitive.skipBytes,a2

Polygon.restoreFragmentYloop:
.yloop:	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

	sub.w	d5,d6
	bgt.s	.go_on

	adda.l	a5,a0
	adda.l	a5,a3
	add.l	d2,d0
	add.l	d3,d1
	dbra	d7,.yloop
	rts

.go_on:	lea	(a0,d5.w*2),a1
	lea	(a3,d5.w*2),a3
	add.w	d6,d5
	subq.w	#1,d6

Polygon.restorePixelInstr:
.xloop:	move.w	(a3)+,(a1)+
	dbf	d6,.xloop

	adda.l	a5,a0
	adda.l	a5,a3
	suba.w	d5,a3
	suba.w	d5,a3
	add.l	d2,d0
	add.l	d3,d1
	dbf	d7,Polygon.restoreFragmentYloop

	rts

	nop						; crap for code-gen
	nop
	nop
	nop


	IFNE	0

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

; Subroutine that draws a v4-textured fragment to a table.
; Vertical and horizontal clipping are NOT this routine's responsibility.
; INPUT:
; d0.l: 8:8:8:8 (000V) left V0-start
; d1.l: 8:8:8:8 (000V) left V1-start
; a5.l: 8:8:8:8 (v0Uu) left U0-step, left V0-step
; d3.l: 8:8:8:8 (000V) left V0-step
; a6.l: 8:8:8:8 (v0Uu) left U1-step, left V1-step
; d5.l: 8:8:8:8 (000V) left V1-step
; d7.w: number of scanlines to paint - 1
; a0: startentry of scanline table
; a1.l: 16:16 (XXxx) left X-start
; a2.l: 16:16 (XXxx) right X-start
; a3.l: 16:16 (XXxx) left X-step
; a4.l: 16:16 (XXxx) right X-step
; d2.l: 8:8:8:8 (v0Uu) left U0-start, left V0-start
; d4.l: 8:8:8:8 (v0Uu) left U1-start, left V1-start
; OUTPUT:
; a0: start of next scanline entry
DRAW_V4FRAGMENT:
.scanline_loop:
	move.l	a1,d6				;  2
	swap	d6				;  4
	move.w	d6,(a0)+			; ?8
	move.l	a2,d6				;  2
	swap	d6				;  4
	move.w	d6,(a0)+			; ?8
	move.w	d2,(a0)+			; ?8
	move.w	d0,(a0)+			; ?8
	move.w	d4,(a0)+			; ?8
	move.w	d1,(a0)+			; ?8
	adda.l	a3,a1				;  2
	adda.l	a4,a2				;  2
	add.w	a5,d2				;  2
	add.w	d3,d0				;  2
	add.w	a6,d4				;  2
	add.w	d5,d1				;  2
	dbra	d7,.scanline_loop		;  6
						; 74
	rts

; INPUT:
; d0.l: x0
; d1.l: y0
; d2.l: x1
; d3.l: y1
; d4.l: x2
; d5.l: y2
; a0: address of 1st uv-table (u0,v0,u1,v1)
; a1: address of uv-table (u0,v0,u1,v1)
; a2: address of uv-table (u0,v0,u1,v1)
PAINT_UNCLIPV4TRIANGLE:
	movea.l	a0,a3
	movea.l	a1,a4
	movea.l	a2,a5

; d0.l: X1
; d1.l: Y1
; d2.l: X2
; d3.l: Y2
; d4.l: X3
; d5.l: Y3
; a3.l: address of 1st uv-table
; a4.l: address of 2nd uv-table
; a5.l: address of 3rd uv-table

; Sort points in Y-order.
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
; X2-X1 X3-X1 X3-X2
; Y2-Y1 Y3-Y1 Y3-Y2
; I2-I1 I3-I1 I3-I2

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
	move.l	(a3),v4EdgeU0Start(a0)		; u0,v0
	move.l	4(a3),v4EdgeU1Start(a0)		; u1,v1
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
;	move.l	a3,v4EdgeUStart(a1)		; u,v
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
	move.l	(a4),v4EdgeU0Start(a2)		; u0,v0
	move.l	4(a4),v4EdgeU1Start(a2)		; u1,v1
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

; Calculate horizontal intensity slope.
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

; x_intersect := Edge1Slope ; Edge0length + Edge1XStart
	move.l	v4EdgeXSlope(a1),d7
	moveq	#0,d4
	move.w	v4EdgeDY(a0),d4
	muls.l	d4,d7
	swap	d7
	add.w	v4EdgeXStart(a0),d7		a1; x_intersect
; i_intersect := Edge1ISlope ; Edge0length + Edge1IStart
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
	add.w	v4EdgeU0Start(a0),d0		a1; i_intersect
	add.w	v4EdgeV0Start(a0),d1		a1
	add.w	v4EdgeU1Start(a0),d2		a1; i_intersect
	add.w	v4EdgeV1Start(a0),d3		a1
; i_horizontalslope := (x_intersect - I2) / (x_intersect - X2)
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

; d0.w: Uu (0)
; d1.w: Vv (0)
; d2.w: Uu (1)
; d3.w: Vv (1)
; d7.l: dx

	movem.w	d0-d3,Polygon.uvslopes

; Special case for triangles that have a horizontal edge.
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

; a0 /\ a1
;      \
.make_fragments_lr:
; Create upper fragment..
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

; Create lower fragment..
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
; Create upper fragment..
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

; Create lower fragment..
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
	move.w	(sp)+,d0				; Get Y start of triangle.
	mulu.w	Viewport.settingsTable+Viewport.XSCREEN,d0
	add.l	d0,d0
	adda.l	d0,a0
	lea	Polygon.scanlineTable,a1
	move.w	(sp)+,d7
	bmi.s	.end_paint_triangle
	movea.l	Polygon.v4routadr,a3
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
	
; Draws a mixed-texture triangle to the screen.
; Horizontal clipping is implemented.
; INPUT: a0: start screenline
;        a1: start entry in scanline table
;        d7.w: number of scanlines to paint - 1
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

; Draws a bump-textured triangle to the screen.
; Horizontal clipping is implemented.
; INPUT: a0: start screenline
;        a1: start entry in scanline table
;        d7.w: number of scanlines to paint - 1
PAINT_UNCLIPBUMPSCANS:
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d0
	add.w	d0,d0
	move.w	d0,-(sp)
	movem.l	Polygon.curtexture,a3/a4

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

	ENDC

;======= Sprite

Sprite.routTable:
	DC.L	Sprite.paintMoved
	DC.L	Sprite.paintOrred
	DC.L	Sprite.paintAdded
	DC.L	Sprite.paintceilAdded

; INPUT:
; a1: sprite structure
; a2: vertex table
Sprite.paint:
	lea	Polygon.textureTable,a0
	move.w	Primitive.SPRITETYPE(a1),d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	(a0,d0.w*4),a0
; a0: address of sprite-data.
	move.w	Sprite.VERTEX(a1),d0
	mulu.w	#Vertex.SIZE,d0
	movem.w	4(a2,d0.l),d0-d2
; d0.l: X
; d1.l: Y
; d2.l: Z
	movea.l	a0,a1
	bra.w	Sprite.clipAndPaint

Sprite.paintReceived:
	lea	Polygon.textureTable,a0
	receiveWordFromDsp	d0
	andi.w	#Primitive.TEXTUREMASK,d0
	movea.l	(a0,d0.w*4),a0
; a0: address of sprite-data.
	receiveWordFromDsp	d1
	receiveWordFromDsp	d0
	receiveWordFromDsp	d2
	ext.l	d0
	ext.l	d1
	ext.l	d2
; d0.l: X
; d1.l: Y
; d2.l: Z
	movea.l	a0,a1
	bra.w	Sprite.clipAndPaint

; Paints a highcolor rle sprite to the screen.
; This handles horizontal and vertical clipping as well.
; INPUT:
; d0.w: x position (mid)
; d1.w: y position (mid)
; a1: sprite
Sprite.clipAndPaint:
	movea.l	Primitive.screenadr,a0
	movea.w	Viewport.settingsTable+Viewport.XSCREEN,a6
	adda.l	a6,a6
	move.w	(a1)+,d6			; width of sprite
	move.w	(a1)+,d7			; height of sprite
	move.w	d6,d4
	lsr.w	#1,d4
	sub.w	d4,d0
	move.w	d7,d4
	lsr.w	#1,d4
	sub.w	d4,d1
	movem.w	Viewport.settingsTable+Viewport.XSTART,d4/d5/a4/a5
	movea.l	a1,a3
	lea	(a1,d7.w*2),a1

; d0.w: left x coordinate of sprite
; d1.w: top y coordinate of sprite
; d6.w: width of sprite
; d7.w: height of sprite

.clip_bottom:
	cmp.w	a5,d1				; YEnd
	bge	.end				; Beneath bottom?
	move.w	d1,d2
	add.w	d7,d2				; d2 := bottom line of sprite
	cmp.w	a5,d2
	blt.s	.end_clip_bottom
	move.w	d2,d3
	sub.w	a5,d3
	sub.w	d3,d7
.end_clip_bottom:

.clip_top:
	cmp.w	a4,d1				; YStart
	bge.s	.end_clip_top	
	cmp.w	a4,d2
	ble	.end				; Above top?
	move.w	d2,d7
	sub.w	a4,d7
	sub.w	a4,d1
	neg.w	d1
	lea	(a3,d1.w*2),a3
	move.w	a4,d1
.end_clip_top:

; d1.w: top y coordinate of sprite
; d7.w: height of sprite

.clip_left:
	moveq	#0,d3
	move.w	d0,d2
	add.w	d6,d2				; d2 := left x of sprite
	cmp.w	d4,d0				; XStart
	bgt.s	.end_clip_left
	cmp.w	d4,d2				; XStart
	ble	.end				; Left of viewport?
	move.w	d0,d3
	sub.w	d4,d3
	neg.w	d3
	move.w	d4,d0
.end_clip_left:

.clip_right:
	cmp.w	d5,d0				; XEnd
	bge	.end				; Right of viewport?
	cmp.w	d5,d2
	ble.s	.end_clip_right
	sub.w	d5,d2
	sub.w	d2,d6
.end_clip_right:

	movea.l	Sprite.rout,a5
	jsr	(a5)

.end:	rts

; d0.w= left x coordinate of sprite
; d3.w= #left pixels to skip
; d6.w= #pixels in spriteline
Sprite.paintMoved:
	move.w	d3,d2
	move.l	a6,d5
	mulu.w	d1,d5
	adda.l	d5,a0
	lea	(a0,d0.w*2),a0
	subq.w	#1,d7
	move.w	#$7fff,d0
	clr.l	d1
	clr.l	d3

.yloop:	move.w	(a3)+,d1
	lea	(a1,d1.l),a4
	movea.l	a0,a2
	moveq	#0,d5				; linesize := 0

.skip_blocks:
	tst.w	d2
	beq.s	.end_handle_leftover

.skip_block_loop:
	move.w	(a4)+,d4
	move.w	d4,d3
	and.w	d0,d3
	add.w	d3,d5				; linesize := linesize + blocksize
	cmp.w	d5,d2
	ble.s	.end_skip_blocks
	cmp.w	d0,d4
	blo.s	.skip_unmasked
.skip_masked:
	lea	(a4,d3.l*2),a4			; Skip <d3> pixels.
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
	lea	(a4,d3.l*2),a4			; Skip <d3> pixels.
	ble.s	.end_handle_leftover
	subq.w	#1,d1
.leftover_loop:
	move.w	(a4)+,(a2)+
	dbf	d1,.leftover_loop
	bra.s	.end_handle_leftover
.leftover_unmasked:
	lea	(a2,d1.l*2),a2			; Skip <d1> pixels.
.end_handle_leftover:

.block_loop:
	move.w	(a4)+,d4
	move.w	d4,d3
	and.w	d0,d3
	add.w	d3,d5				; linesize := linesize + blocksize
	cmp.w	d5,d6
	ble.s	.end_block_loop
	cmp.w	d0,d4
	blo.s	.unmasked
.masked:
	subq.w	#1,d3
.masked_loop:
	move.w	(a4)+,(a2)+
	dbf	d3,.masked_loop
	bra.s	.next_block
.unmasked:
	lea	(a2,d3.l*2),a2			; Skip <d3> pixels.
.next_block:
	bra.s	.block_loop
.end_block_loop:

; Not left-over, but "right-over", get it? RIght-Over?!? Ghweheheheh.
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
	dbf	d3,.rightover_masked_loop
.rightover_unmasked:
.end_handle_rightover:

.next_line:
	adda.l	a6,a0
	dbra	d7,.yloop

.end:	rts

; d0.w: left x coordinate of sprite
; d3.w: number of left pixels to skip
; d6.w: number of pixels in spriteline
Sprite.paintAdded:
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
	moveq	#0,d5				; linesize := 0

.skip_blocks:
	tst.w	d2
	beq.s	.end_handle_leftover

.skip_block_loop:
	move.w	(a4)+,a5
	move.w	a5,d3
	and.w	d0,d3
	add.w	d3,d5				; linesize := linesize + blocksize
	cmp.w	d5,d2
	ble.s	.end_skip_blocks
	cmp.w	d0,a5
	blo.s	.skip_unmasked
.skip_masked:
	lea	(a4,d3.w*2),a4			; Skip <d3> pixels.
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
	lea	(a4,d3.w*2),a4			; Skip <d3> pixels.
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
	lea	(a2,d1.w*2),a2			; Skip <d1> pixels.
.end_handle_leftover:

.block_loop:
	move.w	(a4)+,a5
	move.w	a5,d3
	and.w	d0,d3
	add.w	d3,d5				; linesize := linesize + blocksize
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
	lea	(a2,d3.w*2),a2			; Skip <d3> pixels.
.next_block:
	bra.s	.block_loop
.end_block_loop:

; Not left-over, but "right-over", get it? RIght-Over?!? Ghweheheheh.
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

; d0.w: left x coordinate of sprite
; d3.w: number of left pixels to skip
; d6.w: number of pixels in spriteline
Sprite.paintOrred:
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
	moveq	#0,d5				; linesize := 0

.skip_blocks:
	tst.w	d2
	beq.s	.end_handle_leftover

.skip_block_loop:
	move.w	(a4)+,a5
	move.w	a5,d3
	and.w	d0,d3
	add.w	d3,d5				; linesize := linesize + blocksize
	cmp.w	d5,d2
	ble.s	.end_skip_blocks
	cmp.w	d0,a5
	blo.s	.skip_unmasked
.skip_masked:
	lea	(a4,d3.w*2),a4			; Skip <d3> pixels.
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
	lea	(a4,d3.w*2),a4			; Skip <d3> pixels.
	subq.w	#1,d1
	bmi.s	.end_handle_leftover
.leftover_loop:
	move.w	(a4)+,d3
	or.w	d3,(a2)+
	dbf	d1,.leftover_loop
	bra.s	.end_handle_leftover
.leftover_unmasked:
	lea	(a2,d1.w*2),a2			; Skip <d1> pixels.
.end_handle_leftover:

.block_loop:
	move.w	(a4)+,a5
	move.w	a5,d3
	and.w	d0,d3
	add.w	d3,d5				; linesize := linesize + blocksize
	cmp.w	d5,d6
	ble.s	.end_block_loop
	cmp.w	d0,a5
	blo.s	.unmasked
.masked:
	subq.w	#1,d3
.masked_loop:
	move.w	(a4)+,d1
	or.w	d1,(a2)+
	dbf	d3,.masked_loop
	bra.s	.next_block
.unmasked:
	lea	(a2,d3.w*2),a2			; Skip <d3> pixels.
.next_block:
	bra.s	.block_loop
.end_block_loop:

; Not left-over, but "right-over", get it? RIght-Over?!? Ghweheheheh.
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
	move.w	(a4)+,d1
	or.w	d1,(a2)+
	dbf	d3,.rightover_masked_loop
.rightover_unmasked:
.end_handle_rightover:

.next_line:
	adda.l	a6,a0
	dbra	d7,.yloop

.end:	rts

; d0.w: left x coordinate of sprite
; d3.w: number of left pixels to skip
; d6.w: number of pixels in spriteline
Sprite.paintceilAdded:
	clr.l	d2
	move.w	d3,d2
	move.l	a6,d5
	mulu.w	d1,d5
	adda.l	d5,a0
	lea	(a0,d0.w*2),a0
	subq.w	#1,d7
	move.w	#$7fff,d0

.yloop:	move.w	d7,-(sp)
	move.w	(a3)+,d1
	lea	(a1,d1.w),a4
	movea.l	a0,a2
	clr.l	d5				; linesize := 0
	movem.l	a1/a3,-(sp)
	move.w	d2,-(sp)
	lea	Primitive.msbMixTable,a3
	lea	Primitive.lsbMixTable,a1

.skip_blocks:
	tst.w	d2
	beq.s	.end_handle_leftover

.skip_block_loop:
	move.w	(a4)+,a5
	move.w	a5,d3
	and.w	d0,d3
	add.w	d3,d5				; linesize := linesize + blocksize
	cmp.w	d5,d2
	ble.s	.end_skip_blocks
	cmp.w	d0,a5
	blo.s	.skip_unmasked
.skip_masked:
	lea	(a4,d3.w*2),a4			; Skip <d3> pixels.
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
	lea	(a4,d3.w*2),a4			; Skip <d3> pixels.
	subq.w	#1,d1
	bmi.s	.end_handle_leftover
.leftover_loop:

	IFNE	1
; rgb
	move.w	(a4)+,d2
	move.l	d2,d7
	move.w	(a2),d3
	move.b	(a2),d2				; d2.w=src_msb<<8+dest_msb
	move.b	(a3,d2.l),(a2)+			; Store res_msb.
	lsl.w	#8,d7
	move.b	d3,d7				; d7.w=src_lsb<<8+dest_lsb
	move.b	(a1,d7.l),(a2)+

	ELSE

	move.w	(a2),d3
	add.w	(a4)+,d3
	scs.b	d4
	ext.w	d4
	or.w	d4,d3
	move.w	d3,(a2)+

	ENDC

	dbf	d1,.leftover_loop
	bra.s	.end_handle_leftover
.leftover_unmasked:
	lea	(a2,d1.w*2),a2			; Skip <d1> pixels.
.end_handle_leftover:

.block_loop:
	move.w	(a4)+,a5
	move.w	a5,d3
	and.w	d0,d3
	add.w	d3,d5				; linesize := linesize + blocksize
	cmp.w	d5,d6
	ble.s	.end_block_loop
	cmp.w	d0,a5
	blo.s	.unmasked
.masked:
	subq.w	#1,d3
.masked_loop:
; in use: d0,d3,d5,d6,d7,a0,a1,a2,a4,a6

	IFNE	0

; linear
	move.w	(a2),d1
	add.w	(a4)+,d1
	scs.b	d4
	ext.w	d4
	or.w	d4,d1
	move.w	d1,(a2)+

	ELSE

; rgb
	move.w	(a4)+,d2
	move.l	d2,d7
	move.w	(a2),d1
	move.b	(a2),d2				; d2.w=src_msb<<8+dest_msb
	move.b	(a3,d2.l),(a2)+			; Store res_msb.
	lsl.w	#8,d7
	move.b	d1,d7				; d7.w=src_lsb<<8+dest_lsb
	move.b	(a1,d7.l),(a2)+

	ENDC
	dbf	d3,.masked_loop
	bra.s	.next_block
.unmasked:
	lea	(a2,d3.w*2),a2			; Skip <d3> pixels.
.next_block:
	bra.s	.block_loop
.end_block_loop:

; Not left-over, but "right-over", get it? RIght-Over?!? Ghweheheheh.
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

	IFNE	1

; rgb ceiladd!
	move.w	(a4)+,d2
	move.l	d2,d7
	move.w	(a2),d1
	move.b	(a2),d2				; d2.w=src_msb<<8+dest_msb
	move.b	(a3,d2.l),(a2)+			; Store res_msb.
	lsl.w	#8,d7
	move.b	d1,d7				; d7.w=src_lsb<<8+dest_lsb
	move.b	(a1,d7.l),(a2)+

	ELSE

; linear ceiladd!
	move.w	(a2),d1
	add.w	(a4)+,d1
	scs.b	d4
	ext.w	d4
	or.w	d4,d1
	move.w	d1,(a2)+

	ENDC

	dbf	d3,.rightover_masked_loop
.rightover_unmasked:
.end_handle_rightover:

.next_line:
	move.w	(sp)+,d2
	movem.l	(sp)+,a1/a3
	adda.l	a6,a0
	move.w	(sp)+,d7
	dbra	d7,.yloop

.end:	rts

; TODO: implement this!

	IFNE	0
	move.w	#%0000000000011111,d7
	move.w	#%0000011111100000,d6
	move.w	#%1111100000000000,d5

; Looks like almost 80 cycles :(
; Maybe try table?
	move.w	(a1)+,d0
	move.w	(a0),d1
	move.w	d0,d2
	move.w	d1,d3
	and.w	d7,d2
	and.w	d7,d3
	add.w	d2,d3
	cmp.w	d7,d3
	ble.s	.b_ok
	move.w	d7,d3
.b_ok:	move.w	d0,d2
	move.w	d1,d4
	and.w	d6,d2
	and.w	d6,d4
	sub.w	d2,d0
	sub.w	d4,d1
	add.w	d2,d4
	cmp.w	d6,d4
	ble.s	.g_ok
	move.w	d6,d4
.g_ok:	or.w	d4,d3
	add.w	d0,d1
	bcc.s	.r_ok
	move.w	d5,d1
.r_ok:	or.w	d1,d3
	move.w	d3,(a0)+
	ENDC

Primitive.initMsbMixTable:
	move.b	#%00000111,d6
	move.b	#%11111000,d5
	lea	Primitive.msbMixTable,a0
	clr.w	d7

.loop:	move.w	d7,d0
	lsr.w	#8,d0
	move.b	d7,d1
	move.b	d0,d2
	move.b	d1,d3
	and.b	d6,d0
	and.b	d6,d1
	sub.b	d0,d2
	sub.b	d1,d3
	add.b	d0,d1
	cmp.b	d6,d1
	blo.s	.g_ok
	move.b	d6,d1
.g_ok:	add.b	d2,d3
	bcc.s	.r_ok
	move.b	d5,d3
.r_ok:	or.b	d3,d1
	move.b	d1,(a0)+
	addq.w	#1,d7
	bne.s	.loop
	rts

Primitive.initLsbMixTable:
	move.b	#%00011111,d6
	move.b	#%11100000,d5
	lea	Primitive.lsbMixTable,a0
	clr.w	d7

.loop:	move.w	d7,d0
	lsr.w	#8,d0
	move.b	d7,d1
	move.b	d0,d2
	move.b	d1,d3
	and.b	d6,d0
	and.b	d6,d1
	sub.b	d0,d2
	sub.b	d1,d3
	add.b	d0,d1
	cmp.b	d6,d1
	blo.s	.b_ok
	move.b	d6,d1
.b_ok:	add.b	d2,d3
	bcc.s	.g_ok
	move.b	d5,d3
.g_ok:	or.b	d3,d1
	move.b	d1,(a0)+
	addq.w	#1,d7
	bne.s	.loop
	rts

	IFNE	0
; r,g,b hicolor word saturated add code.
	lea	Primitive.msbMixTable,a2
	lea	Primitive.lsbMixTable,a3
	clr.l	d2
	clr.b	d3

	move.w	(a1)+,d2
	move.w	d2,d0
	move.w	(a0),d1
	move.b	(a0),d2				; d2.w=src_msb<<8+dest_msb
	move.b	(a2,d2.l),d4			; d4.b=res_msb
	move.b	d1,d2
	lsl.w	#8,d2
	move.b	d0,d2				; d2.w=src_lsb<<8+dest_lsb
	move.b	d4,(a0)+
	move.b	(a3,d2.l),(a0)+

; 6+2+6+4+8+2+4+2+6+10=50 cycles (well..)
	ENDC

;======= Line

Line.paintReceived:
	receiveWordFromDsp	d4
	receiveWordFromDsp	d1
	receiveWordFromDsp	d0
	receiveWordFromDsp	d3
	receiveWordFromDsp	d2
	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3
	move.w	d4,d5
	andi.w	#Primitive.TEXTUREMASK,d5
	move.w	d5,Line.colorNum
	andi.w	#Primitive.SHADEMASK,d4
	cmpi.w	#Line.FLATSHADED,d4
	beq.s	Line.paintFlatshaded
	cmpi.w	#Line.GOURAUDSHADED,d4
	beq	Line.paintGouraudshaded
	cmpi.w	#Line.PHONGSHADED,d4
	beq	Line.paintPhongshaded
	rts

; INPUT:
; \1: flagnum
; \2: flagreg
; \3: edgereg
; \4: xreg
; \5: yreg
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

; INPUT:
; \1: flagnum
; \2: flagreg
; \3: edgereg
; \4: xreg
; \5: yreg
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

; INPUT:
; \1: flagnum
; \2: flagreg
; \3: edgereg
; \4: xreg
; \5: yreg
; \6: ireg
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
	sub.l	\3,d4				; d4.l: dx
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
	divs.w	d4,d7				; (di<<8)/x
\@skip_div2:
	move.l	d0,d4
	sub.l	\3,d4				; d4.l: dx
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

; INPUT:
; \1: flagnum
; \2: flagreg
; \3: edgereg
; \4: xreg
; \5: yreg
; \6: ireg
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
	divs.w	d4,d7				; (di<<8)/y
\@skip_div2:
	move.l	d1,d4
	sub.l	\3,d4				; d4.l: dy
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

; Paints a one-colour line to the screen. The line can be clipped in
; any way.
; INPUT:
; d0.l: x1
; d1.l: y1
; d2.l: x2
; d3.l: y2
Line.paintFlatshaded:
; Clip this baby first...
.clip:	movem.w	Viewport.settingsTable+Viewport.XSTART,a3-a6

	moveq	#0,d5				; Set point clipflags to 0.
.check_first_left:
	cmp.w	a3,d0				; XSTART
	bge.s	.check_first_right
	addq.w	#%0010,d5
.check_first_right:
	cmp.w	a4,d0				; XEND
	blt.s	.end_check_first_right
	addq.w	#%0001,d5
.end_check_first_right:
.check_first_above:
	cmp.w	a5,d1				; YSTART
	bge.s	.check_first_under
	ori.w	#%1000,d5
.check_first_under:
	cmp.w	a6,d1				; YEND
	blt.s	.end_first_check
	addq.w	#%0100,d5
.end_first_check:

	moveq	#0,d6				; Set point clipflags to 0.
.check_second_left:
	cmp.w	a3,d2				; XSTART
	bge.s	.check_second_right
	addq.w	#%0010,d6
.check_second_right:
	cmp.w	a4,d2				; XEND
	blt.s	.end_check_second_right
	addq.w	#%0001,d6
.end_check_second_right:
.check_second_above:
	cmp.w	a5,d3				; YSTART
	bge.s	.check_second_under
	ori.w	#%1000,d6
.check_second_under:
	cmp.w	a6,d3				; YEND
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

; The lineroutine has NO CLIPPING!!!
	moveq	#0,d6
	move.w	Line.colorNum,d6
	movea.l	Polygon.coloradr,a1
	lea	Primitive.GRADIENTSIZE/2(a1),a1
	lsl.l	#Primitive.GRADIENTBITS+1,d6
	move.w	(a1,d6.l),d6
	movea.l	Primitive.screenadr,a0
	clr.l	d5
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d5
	add.l	d5,d5
; d0.w=x0, d1.w=y0, d2.w=x1, d3.w=y1, d5.l=scrwidth, d6.w=color, a0: screen

; Calculate |dx|, |dy| and calculate x step, y step.
	moveq	#2,d4
	sub.w	d0,d2			; d2.w = dx
	bpl.s	.dx_positive
	neg.l	d4
	neg.w	d2
.dx_positive:
	movea.l	d4,a1			; a1 = x step
	move.l	d5,d4
	sub.w	d1,d3			; d3.w = dy
	bpl.s	.dy_positive
	neg.l	d4
	neg.w	d3
.dy_positive:
	movea.l	d4,a2			; a2 = y step
; d2.w = |dx|, d3.w = |dy|

; Calculate the startaddress on screen.
	ext.l	d0
	add.w	d0,d0
	mulu.w	d5,d1
	add.l	d0,d1
	adda.l	d1,a0

; Branch to appropriate routine, depending on |dx| < |dy|.
	cmp.w	d2,d3
	blt.s	Line.paintDy

; Paints a line with |dy| >= |dx|.
Line.paintDx:
	move.w	d3,d5
	beq.s	.end
	;subq.w	#1,d5
	move.w	d3,d0

.loop:	move.w	d6,(a0)
	sub.w	d2,d0
	bgt.s	.end_inc_x
	add.w	d3,d0
	adda.l	a1,a0
.end_inc_x:
	adda.l	a2,a0
	dbra	d5,.loop

.end:	rts

; Paints a line with |dx| < |dy|.
Line.paintDy:
	move.w	d2,d5
	beq.s	.end
	;subq.w	#1,d5
	move.w	d2,d0

.loop:	move.w	d6,(a0)
	sub.w	d3,d0
	bgt.s	.end_inc_y
	add.w	d2,d0
	adda.l	a2,a0
.end_inc_y:
	adda.l	a1,a0
	dbra	d5,.loop

.end:	rts

; Paints a gouraudshaded line to the screen. The line can be clipped in any
; way.
; INPUT:
; d0.l: x1
; d1.l: y1
; d2.l: x2
; d3.l: y2
Line.paintGouraudshaded:
	receiveWordFromDsp	a0
	receiveWordFromDsp	a2

Line.paintGradiented:
; Clip this baby first...
.clip:	movem.w	Viewport.settingsTable+Viewport.XSTART,a3-a6

	moveq	#0,d5				; Set point clipflags to 0.
.check_first_left:
	cmp.w	a3,d0				; XSTART
	bge.s	.check_first_right
	addq.w	#%0010,d5
.check_first_right:
	cmp.w	a4,d0				; XEND
	blt.s	.end_check_first_right
	addq.w	#%0001,d5
.end_check_first_right:
.check_first_above:
	cmp.w	a5,d1				; YSTART
	bge.s	.check_first_under
	ori.w	#%1000,d5
.check_first_under:
	cmp.w	a6,d1				; YEND
	blt.s	.end_first_check
	addq.w	#%0100,d5
.end_first_check:

	moveq	#0,d6				; Set point clipflags to 0.
.check_second_left:
	cmp.w	a3,d2				; XSTART
	bge.s	.check_second_right
	addq.w	#%0010,d6
.check_second_right:
	cmp.w	a4,d2				; XEND
	blt.s	.end_check_second_right
	addq.w	#%0001,d6
.end_check_second_right:
.check_second_above:
	cmp.w	a5,d3				; YSTART
	bge.s	.check_second_under
	ori.w	#%1000,d6
.check_second_under:
	cmp.w	a6,d3				; YEND
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

; The lineroutine has NO CLIPPING!!!
	move.l	a0,d6
	move.l	a2,d7
	clr.l	d4
	move.w	Line.colorNum,d4
	movea.l	Polygon.coloradr,a1
	lsl.l	#Primitive.GRADIENTBITS+1,d4
	adda.l	d4,a1
	movea.l	Primitive.screenadr,a0
; d0.w=x0, d1.w=y0, d2.w=x1, d3.w=y1, d6.w=g0 d7.w=g1, a0: screen, a1: pal

	clr.l	d5
	move.w	Viewport.settingsTable+Viewport.XSCREEN,d5
	add.l	d5,d5

; Calculate |dx|, |dy| and calculate x step, y step.
	moveq	#2,d4
	sub.w	d0,d2			; d2.w=dx
	bpl.s	.dx_positive
	neg.l	d4
	neg.w	d2
.dx_positive:
	movea.l	d4,a2			; a1= x step
	move.l	d5,d4
	sub.w	d1,d3			; d3.w=dy
	bpl.s	.dy_positive
	neg.l	d4
	neg.w	d3
.dy_positive:
	movea.l	d4,a3			; a2= y step
; d2.w = |dx|, d3.w = |dy|

; Calc dg.
	ext.l	d7
	ext.l	d6
	sub.l	d6,d7
	lsl.l	#8,d6
	move.l	d6,d4
	lsl.l	#8,d7

; Calculate the startaddress on screen.
	ext.l	d0
	add.l	d0,d0
	mulu.w	d5,d1
	add.l	d0,d1
	adda.l	d1,a0

; Branch to appropriate routine, depending on |dx| < |dy|.
	cmp.w	d2,d3
	blt.s	Line.paintGradDy

; Paints a line with |dy| >= |dx|.
Line.paintGradDx:
	move.w	d3,d5
	beq.s	.end
	divs.w	d5,d7
	;subq.w	#1,d5
	move.w	d3,d0

.loop:	move.l	d4,d1
	lsr.l	#8,d1
	move.w	(a1,d1.l*2),(a0)
	sub.w	d2,d0
	bgt.s	.end_inc_x
	add.w	d3,d0
	adda.l	a2,a0
.end_inc_x:
	add.w	d7,d4
	adda.l	a3,a0
	dbra	d5,.loop

.end:	rts

; Paints a line with |dx| < |dy|.
Line.paintGradDy:
	move.w	d2,d5
	beq.s	.end
	divs.w	d5,d7
	;subq.w	#1,d5
	move.w	d2,d0

.loop:	move.l	d4,d1
	lsr.l	#8,d1
	move.w	(a1,d1.l*2),(a0)
	sub.w	d3,d0
	bgt.s	.end_inc_y
	add.w	d2,d0
	adda.l	a3,a0
.end_inc_y:
	add.w	d7,d4
	adda.l	a2,a0
	dbra	d5,.loop

.end:	rts

; Paints a gouraudshaded line to the screen. The line can be clipped in any
; way.
; INPUT:
; d0.l: x1
; d1.l: y1
; d2.l: x2
; d3.l: y2
; a1: Line structure
; a2: vertex table
Line.paintPhongshaded:
	receiveWordFromDsp	a0
	receiveWordFromDsp	a2
	bra	Line.paintGradiented

	DATA

;======= HumanFly

HumanFly.p56:
	INCBIN	S_FLY.P56
HumanFly.endP56:
	EVEN

;======= Sprite

Sprite.rout:
	DC.L	Sprite.paintMoved

	BSS

;======= ObjectRegistry

ObjectRegistry.numberOfHandles:
	DS.W	1
ObjectRegistry.table:
	DS.L	ObjectRegistry.CAPACITY
ObjectRegistry.size:
	DS.L	1				; #words in dsp buffer already

;======= PrimitiveMesh

PrimitiveMesh.shadowAdr:			; points to actual shadow
	DS.L	1
PrimitiveMesh.shadowStartAdr:			; points to 1st shadow
	DS.L	1
PrimitiveMesh.background:			; backgroundaddress
	DS.L	1
PrimitiveMesh.shadowsOn:
	DS.W	1

;======= Primitive

Primitive.skipBytes:
	DS.W	1
Primitive.bytesPerPixel:
	DS.W	1
Primitive.screenadr:
	DS.L	1
Primitive.msbMixTable:
	DS.B	256*256
Primitive.lsbMixTable:
	DS.B	256*256

;======= Polygon

Polygon.gradadr:				; address of current gradient table
	DS.L	1
Polygon.textureTable:				; contains texturepointers (nullterminated)
	DS.L	Polygon.MAX_TEXTURES+1
Polygon.textureroutadr:
	DS.L	1
Polygon.v4routadr:
	DS.L	1
Polygon.alphatableadr:
	DS.L	1
Polygon.texturemode:
	DS.W	1
Polygon.v4texturemode:
	DS.W	1
Polygon.color:					; current color
	DS.L	1
Polygon.coloradr:				; base address of gradient tables
	DS.L	1
Polygon.curtexture:				; first current textureaddress
	DS.L	1
Polygon.curtexture2:				; second current textureaddress
	DS.L	1

Polygon.uvslopes:
	DS.W	4				; u0,v0,u1,v1
Polygon.invTable:
	DS.W	Viewport.MAX_Y+1
Polygon.fragmentTable:
	DS.W	1				; active fragment flags
	DS.B	Fragment.SIZE*4			; max 3 for quad, max 2 for triangle
Polygon.scanlineTable:
	DS.W	1
	DS.W	3*Viewport.MAX_Y		; table for tmap and envmap scanlines
Polygon.shadeTable:
	DS.W	Vertex2d.SIZE*8			; (u,v) for each vertex
Polygon.extvertexTable:
	DS.W	4*3				; for each trianglevertex: u0,v0,u1,v1
Polygon.bumpmapTable:
	DS.W	1
	DS.L	16
Polygon.textureCache:
	DS.B	3*8192

;======= Line

Line.colorNum:
	DS.W	1
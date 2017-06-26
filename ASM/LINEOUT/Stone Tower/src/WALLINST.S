	COMMENT	HEAD=%111

maxslicelen:	=	128
texturelen:	=	64

	bsr	CREATE_WALLROUTINES

	clr.w	-(sp)
	trap	#1

* Hardcoded textured wallsclices from the dungeons of hell! =)

CREATE_WALLROUTINES:
	lea	wallroutine_buf,a0
	lea	wallroutadr_tbl,a1
	moveq	#maxslicelen-1,d7		* max slicelength and number of routines.

.loop:	move.l	a0,(a1)+			* Store address of new routine.

* if (texturelen/slicelen < 1.0) then fast (an)+ loop
* else default d(an) offset loop
	move.l	#texturelen<<8,d1
	move.w	d7,d0
	addq.w	#1,d0
	divu.w	d0,d1
	andi.l	#$0000ffff,d1
	cmpi.w	#$100,d1
	bhs.s	.make_offset_loop

.make_addq_loop:
	move.w	d7,d6
	move.w	d6,d0
	subi.w	#100,d0
	bpl.s	.addq_clipped
	neg.w	d0
	lsr.w	#1,d0
	mulu.w	#80,d0
	move.w	d0,d3
	bra.s	.end_addqclipped
.addq_clipped:
	moveq	#100-1,d6
	moveq	#0,d3
	lsr.w	#1,d0
	move.w	#$43e9,(a0)+			* "LEA D(A1),A1"
	move.w	d0,(a0)+
.end_addqclipped:
	lsl.l	#8,d1
	moveq	#0,d2
	move.w	#$1019,(a0)+			* "MOVE.B (A1)+,D0"

.pixelloop:
	bcc.s	.skip_fetch
	move.w	#$1019,(a0)+			* "MOVE.B (A1)+,D0"
.skip_fetch:
	move.w	#$8128,(a0)+			* "OR.B D0,D(A0)"
	move.w	d3,(a0)+
	addi.w	#80,d3
	add.w	d1,d2
	dbra	d6,.pixelloop

	move.w	#$4e75,(a0)+			* "RTS"
	dbra	d7,.loop
	rts

.make_offset_loop:
	move.w	d7,d6
	move.w	d6,d0
	subi.w	#100,d0
	bpl.s	.offset_clipped
	neg.w	d0
	lsr.w	#1,d0
	mulu.w	#80,d0
	move.w	d0,d3
	moveq	#0,d2
	bra.s	.end_offsetclipped
.offset_clipped:
	moveq	#100-1,d6
	moveq	#0,d3
	lsr.w	#1,d0
	moveq	#0,d2
	move.w	d0,d2
	swap	d2
.end_offsetclipped:
	lsl.l	#8,d1

.offsetpixelloop:
	move.l	d2,d0
	swap	d0
	move.w	#$1029,(a0)+			* "MOVE.B D(A1),D0"
	move.w	d0,(a0)+
	move.w	#$8128,(a0)+			* "OR.B D0,D(A0)"
	move.w	d3,(a0)+
	addi.w	#80,d3
	add.l	d1,d2
	dbra	d6,.offsetpixelloop

	move.w	#$4e75,(a0)+			* "RTS"
	dbra	d7,.loop
	rts

	BSS

wallroutadr_tbl:
	DS.L	maxslicelen
wallroutine_buf:
	DS.L	10000
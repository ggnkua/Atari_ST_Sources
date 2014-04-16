
	section	text

;%%% Counting Sort %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

counting_sort:			;sort facelist in z order

	;first clear all counters
	lea	cntrs,a0
	move.w	#256-1,d7
.cc:
	clr.w	(a0)+
	dbra	d7,.cc


	;inc counters
	lea	cntrs,a0
	lea	facelst,a1
	move.w	NUMFACES,d7
	subq.w	#1,d7
.inc:
	move.l	(a1)+,d0	;face num : z val
	addq.w	#1,(a0,d0.w*2)	;inc counter
	dbra	d7,.inc

	;calc cumulative count
	lea	cntrs,a0
	move.w	#256-1-1,d7
.cumc:
	move.w	(a0)+,d0
	add.w	d0,(a0)
	dbra	d7,.cumc


	;copy elements
	lea	cntrs,a0
	lea	facelst,a1
	lea	facelst_sorted,a2
	move.w	NUMFACES,d7
	subq.w	#1,d7
.cpy:
	move.l	(a1,d7.w*4),d0	;face num : z val
	subq.w	#1,(a0,d0.w*2)	;dec cum counters
	move.w	(a0,d0.w*2),d1	;place for curr z val
	move.l	d0,(a2,d1.w*4)	
	dbra	d7,.cpy

	rts

get_faces:			;get avg z value for each face
	move.l	faces,a4
	lea	rotobj,a3
	lea	facelst,a5
	clr.l	d0
	move.w	NUMFACES,d7
	subq.w	#1,d7

	fmove.s	#-9999,fp7	;zmax
	fmove.s	#9999,fp6	;zmin

.faclop:
;	fsub	fp3,fp3		;avg z=0
;	move.w	#3,d6
;	move.w	d6,d0
;	subq.w	#1,d6
;.vertlop:
;	move.w	(a4)+,d1		;get index to coord
;	mulu	#VERTSIZE,d1		;x,y,z in unprojected coords
;	fadd.s	8(a3,d1.l),fp3		;z coord
;	dbra	d6,.vertlop

	;get min z

	move.w	(a4)+,d1		;get index to coord
	mulu	#VERTSIZE,d1		;x,y,z in unprojected coords
	fmove.s	VZ(a3,d1.l),fp3
	move.w	(a4)+,d1		;get index to coord
	mulu	#VERTSIZE,d1		;x,y,z in unprojected coords
	fmove.s	VZ(a3,d1.l),fp4
	move.w	(a4)+,d1		;get index to coord
	mulu	#VERTSIZE,d1		;x,y,z in unprojected coords
	fmove.s	VZ(a3,d1.l),fp5
;	fcmp	fp4,fp3
;	fble	.no1
;	fmove	fp4,fp3	
;.no1:
;	fcmp	fp5,fp3
;	fble	.no2
;	fmove	fp5,fp3	
;.no2:

	fadd	fp4,fp3
	fadd	fp5,fp3
	fmul.s	#0.33333,fp3

	add.l	#3*2+2+2,a4		;skip type and texture/color

	fcmp	fp3,fp7
	fbge	.nozmax
	fmove	fp3,fp7
.nozmax:
	fcmp	fp3,fp6
	fble	.nozmin
	fmove	fp3,fp6
.nozmin:

	fsub.s	zmiin,fp3
	fmul.s	zscale,fp3	;scale z
	fmove.l	fp3,d3
	neg.w	d3		;reverse sort order
	and.l	#$000000ff,d3	;z must be 0->255 for sorting!!
	swap	d3
	move.w	NUMFACES,d2
	subq.w	#1,d2
	sub.w	d7,d2		;face num
	move.w	d2,d3		;z-val:face num
	swap	d3		;face num : z val
	move.l	d3,(a5)+
	dbra	d7,.faclop

				; calc z range and z offset for next frame
	fmove.s	fp7,zmiin
	fsub	fp6,fp7
	fmove.s	#250,fp6
	fdiv	fp7,fp6
	fmove.s	fp6,zscale

	rts

zscale:	dc.s	0.1		;guess initial value
zmiin:	dc.s	0		;guess initial value

	section	bss

cntrs:	ds.w	256

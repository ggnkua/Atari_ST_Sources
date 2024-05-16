; Dungeon traject recorder.
; Precalc rules ;)
; Precalced for 4vbl animation..
; special size-reduced version: 152x90

; 1: use spline interpolation, 0: use linear interpolation
SPLINED:	=	1
VBLS:		=	4			; projected frametime in vbls.

FRAME_WIDTH:	=	152
FRAME_SIZE:	=	FRAME_WIDTH*2

sintbllen:	=	2048

		RSRESET
trajecttime:	RS.L	1
trajectx:	RS.W	1
trajecty:	RS.W	1
trajectangle:	RS.W	1
trajentrysize:	RS.B	0

maxslicelen:	=	200
dungeonxsize:	=	16
dungeonysize:	=	16

;- main code ---------------------------------------------------------------

; init some tables..
	bsr	INIT_TANTABLES
	bsr	INIT_ISINCOSTABLES
	bsr	CREATE_COSTABLE

; prepare to generate some output..
	clr.l	d7				; time[0]

	IFNE	SPLINED

	bsr	calcGradients
	clr.l	time
	move.w	#-1,vertex_buffer+VertexKeyBuf.KEYNUM

loop:	move.w	d7,-(sp)
	lea	playerx,a0
	lea	vertex_buffer,a1
	lea	splinetraject_tbl,a2
	lea	time,a3				; a3: time
	bsr	Keyframer.interpolateVertex

; Calculate frame and proceed to next..
	bsr	calc_columns

	move.w	(sp)+,d7
	addq.l	#VBLS,time
	addq.w	#VBLS,d7
	cmpi.w	#2300,d7
	blt	loop

	ELSE
loop:	lea	dungeontraject_tbl,a0
	move.w	(a0)+,d1
	move.w	trajectstep,d2
	cmp.w	d1,d2
	bhs	.end
	mulu.w	#trajentrysize,d2
	adda.l	d2,a0
	move.l	d7,d0
	move.l	trajentrysize(a0),d3
	move.l	(a0),d4
.test_nextentry:
	cmp.l	d3,d0
	blt.s	.not_nextentry
	addq.w	#1,trajectstep
	lea	trajentrysize(a0),a0
	move.l	trajentrysize(a0),d3
	move.l	(a0),d4
	bra.s	.test_nextentry
.not_nextentry:
	move.l	d0,d6
	sub.l	d4,d6				* Time elapsed since last event.
	sub.l	d4,d3				* Interval between events.
	bne.s	.div
	moveq	#0,d6
	beq.s	.interpolate
.div:	swap	d6
	divu.w	d3,d6				* Elapsed fraction of interval.
	lsr.w	#1,d6
.interpolate:
	move.w	trajectx(a0),d0
	move.w	trajecty(a0),d1
	move.w	trajectangle(a0),d2
	move.w	trajentrysize+trajectx(a0),d3
	move.w	trajentrysize+trajecty(a0),d4
	move.w	trajentrysize+trajectangle(a0),d5
	sub.w	d0,d3
	sub.w	d1,d4
	sub.w	d2,d5
	muls.w	d6,d3
	muls.w	d6,d4
	muls.w	d6,d5
	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	swap	d3
	swap	d4
	swap	d5
	add.w	d3,d0
	add.w	d4,d1
	add.w	d5,d2
	move.w	d0,playerx
	move.w	d1,playery
	move.w	d2,playerarc
.end:	

; Calculate frame and proceed to next..
	move.w	d7,-(sp)
	bsr	calc_columns
	move.w	(sp)+,d7

	addq.w	#VBLS,d7
	cmpi.w	#2300,d7
	blt	loop
	ENDC

; save file...
	move.l	a6,d0
	sub.l	#colbuf,d0				; d0.l=size
	move.l	d0,d1
	divu.w	#FRAME_SIZE,d1				; d1.w=#frames
	move.w	d1,frames				; Store #frames.
	addq.l	#2,d0					; d0.l=size+headersize
	lea	frames,a1
	lea	filename,a0
	bsr	save

	clr.w	-(sp)
	trap	#1

;- subroutines -------------------------------------------------------------

	INCLUDE	IO.S
	TEXT

			RSRESET
VertexKey.X:		RS.W	1
VertexKey.GX:		RS.W	1
VertexKey.Y:		RS.W	1
VertexKey.GY:		RS.W	1
VertexKey.R:		RS.W	1
VertexKey.GR:		RS.W	1
VertexKey.SIZE:		RS.B	0

			RSRESET
VertexKeyEntry.POS:	RS.B	VertexKey.SIZE
VertexKeyEntry.TIME:	RS.L	1
VertexKeyEntry.SIZE:	RS.B	0

			RSRESET
VertexKeyBuf.KEYNUM:	RS.W	1
VertexKeyBuf.STEPMATRIX:RS.B	VertexKey.SIZE*2
VertexKeyBuf.BASEMATRIX:RS.B	VertexKey.SIZE*2
VertexKeyBuf.SIZE:	RS.B	0

; totally stupid method, but too lazy to actually think..
calcGradients:
	lea	splinetraject_tbl,a2
	move.w	(a2)+,d7
	beq.s	.end

	addq	#2,a2
	REPT	VertexKey.SIZE/4
	clr.w	(a2)
	addq	#4,a2
	ENDR
	addq	#2,a2

	subq.w	#2,d7
	bmi.s	.end

.loop:	moveq	#VertexKey.SIZE/4-1,d6
	move.l	VertexKeyEntry.TIME(a2),d0		; d0.l=interval

.cloop:	move.w	+VertexKeyEntry.SIZE(a2),d1		; c1
	sub.w	-VertexKeyEntry.SIZE(a2),d1		; g=c1-c0
	ext.l	d1
	lsl.l	#5,d1
	divs.w	d0,d1
	addq	#2,a2
	move.w	d1,(a2)+				; store g (8:8)
	dbf	d6,.cloop

	addq	#4,a2					; Skip interval..
	dbf	d7,.loop
.end:	rts

* Calculates the objects position from the trajectory (keyframe) table.
* INPUT:
* a0: destination vertex
* a1: object's keyframe buffer
* a2: trajectory table
* a3: time (fraction!)
Keyframer.interpolateVertex:
	move.l	a0,-(sp)
	pea	VertexKeyBuf.BASEMATRIX(a1)

.get_entry:
	move.w	(a2)+,d5
	move.l	(a3),d1				; d1.l=time
	move.w	VertexKeyBuf.KEYNUM(a1),d0
	bpl.s	.not_first_entry
	addq.w	#1,d0
	move.l	VertexKeyEntry.TIME(a2),d3	; d3.l=key interval
	cmp.l	d3,d1
	blt.s	.init_spline
	bra.s	.get_entry_loop
.not_first_entry:
	move.w	d0,d4
	mulu.w	#VertexKeyEntry.SIZE,d4
	move.l	VertexKeyEntry.TIME(a2,d4.l),d3	; d3.l=key interval
	cmp.l	d3,d1
	blt.s	.end_get_entry

.get_entry_loop:
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

	move.l	d1,(a3)

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

CREATE_COSTABLE:
; copy cos..
	lea	sine_tbl+2,a1				;cos
	lea	costable,a0
	lea	costable+sintbllen*2,a2
	move.w	#sintbllen-1,d7
.loop:	move.w	(a1),(a0)+
	move.w	(a1),(a2)+
	addq	#4,a1
	dbf	d7,.loop
	rts

INIT_TANTABLES:
* First, precalc the tan and inverse tan tables..
	lea	itantbl,a2
	lea	tantbl,a0
	lea	sine_tbl,a1
	move.w	#sintbllen-1,d7
.loop:	movem.w	(a1)+,d0-d1			* Get sin(i) and cos(i).
	move.l	d1,d2
	lsl.l	#8,d1
	move.w	d0,d0
	beq.s	.notandiv
	divs.w	d0,d1				* 1/tan(i) = cos(i)/sin(i)
	bra.s	.endtandiv
.notandiv:

;	asr.l	#8,d1
	tst.l	d1
	bmi.s	.neg1
	move.w	#$7FFF,d1
	bra.s	.pos1
.neg1:	move.w	#$8001,d1
.pos1:

.endtandiv:
	lsl.l	#8,d0
	move.w	d2,d2
	beq.s	.noitandiv
	divs.w	d2,d0				* tan(i) = sin(i)/cos(i)
	bra.s	.enditandiv
.noitandiv:

;	asr.l	#8,d0
	tst.l	d0
	bmi.s	.neg2
	move.w	#$7FFF,d0
	bra.s	.pos2
.neg2:	move.w	#$8001,d0
.pos2:	

.enditandiv:
	move.w	d0,(a0)+			* STore tan(i).
	move.w	d1,(a2)+			* STore 1/tan(i).
	dbra	d7,.loop

* Second, precalc the Xstep table (based on tan table).
* 1st and 2nd quadrants must be positive.
; Note: we add resp. subtract 2 to compensate for 'invisible-corner' bug.
	lea	xysteptbl,a0
	lea	tantbl,a1
	move.w	#sintbllen/2-1,d7
.xsteploop1:
	move.w	(a1)+,d0
	bpl.s	.xpos
	neg.w	d0
.xpos:	addq.w	#2,d0
	move.w	d0,(a0)
	addq	#4,a0
	dbf	d7,.xsteploop1
* 3rd and 4th quadrants must be negative.
	move.w	#sintbllen/2-1,d7
.xsteploop2:
	move.w	(a1)+,d0
	bmi.s	.xneg
	neg.w	d0
.xneg:	subq.w	#2,d0
	move.w	d0,(a0)
	addq	#4,a0
	dbf	d7,.xsteploop2

* Third, precalc the Ystep table (based on itan table).
* 1st quadrant must be negative.
	lea	xysteptbl+2,a0
	lea	itantbl,a1
	move.w	#sintbllen/4-1,d7
.ysteploop1:
	move.w	(a1)+,d0
	bmi.s	.yneg1
	neg.w	d0
.yneg1:	subq.w	#2,d0
	move.w	d0,(a0)
	addq	#4,a0
	dbra	d7,.ysteploop1
* 2nd and 3rd quadrants must be positive.
	move.w	#sintbllen/2-1,d7
.ysteploop2:
	move.w	(a1)+,d0
	bpl.s	.ypos
	neg.w	d0
.ypos:	addq.w	#2,d0
	move.w	d0,(a0)
	addq	#4,a0
	dbra	d7,.ysteploop2
* 4th quadrant must be negative.
	move.w	#sintbllen/4-1,d7
.ysteploop3:
	move.w	(a1)+,d0
	bmi.s	.yneg2
	neg.w	d0
.yneg2:	subq.w	#2,d0
	move.w	d0,(a0)
	addq	#4,a0
	dbra	d7,.ysteploop3

; repeat it
	lea	xysteptbl+sintbllen*4,a0
	lea	xysteptbl,a1
	move.w	#sintbllen-1,d7
.repeat:move.l	(a1)+,(a0)+
	dbf	d7,.repeat
	rts

INIT_ISINCOSTABLES:
	lea	sine_tbl,a1
	lea	isinetbl,a0
	move.w	#sintbllen*2-1,d7
	move.l	#$007fffff,d0

.loop:	move.l	d0,d1
	move.w	(a1)+,d2
	bpl.s	.sin_is_pos
	cmpi.w	#$ff00,d2				; sin>-256 ?
	bgt.s	.sinroof
.sin_is_pos:
	cmpi.w	#$0100,d2
	blo.s	.sinroof
	divs.w	d2,d1
	bcc.s	.endsindiv
.sinroof:
	move.w	#$7fff,d1
.endsindiv:
	move.w	d1,d1
	bpl.s	.sinpos
	neg.w	d1
.sinpos:move.w	d1,(a0)+
	dbf	d7,.loop

; repeat it once..
	move.w	#sintbllen-1,d7
	lea	isinetbl,a1

.loop2:	move.l	(a1)+,(a0)+
	dbf	d7,.loop2
	rts

; The actual column calculator...
calc_columns:
	move.w	playerarc(pc),d7
	subi.w	#FRAME_WIDTH,d7
	andi.w	#sintbllen-1,d7
	lea	costable+(sintbllen-FRAME_WIDTH)*2,a0	; a0:cos(ray[0])
	lea	xysteptbl,a1
	lea	isinetbl,a2
	move.w	d7,d0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a1					; a1:xystep(a[0])
	adda.w	d0,a2					; a2:inv_sincos(a[0])
	lea	dungeonmap_tbl,a3
	movea.l	coltabadr,a6

.columnloop:
* Calculate castline and check for intersection with horizontal wall.
* distToNextXIntersection = fXStepTable[castArc];
.findxquad:
	move.w	(a1)+,d0			; d0=xstep
	movem.w	playerx(pc),d1/d6
	move.l	d6,d2
	clr.b	d6
	sub.l	d6,d2

	cmpi.w	#sintbllen/4,d7
	bhs.s	.xtestquad4
	subq.w	#1,d6				;d6.w=[playery]-0.01=[playery]-1+0.FF
	move.w	#-1<<8,d5
	muls.w	d0,d2
	asr.l	#8,d2
	add.w	d2,d1
	bra.s	.endfindxquad
.xtestquad4:
	cmpi.w	#(sintbllen/4)*3,d7
	bhs.s	.xquad4
	move.w	#1<<8,d5
	add.w	d5,d6				;d6.w=[playery]+1
	not.b	d2				;d2.w=0.FF-frac(playery)
	muls.w	d0,d2
	asr.l	#8,d2
	add.w	d2,d1
	bra.s	.endfindxquad
.xquad4:subq.w	#1,d6				;d6.w=[playery]-0.01=[playery]-1+0.FF
	move.w	#-1<<8,d5
	muls.w	d0,d2
	asr.l	#8,d2
	add.w	d2,d1
.endfindxquad:
	move.w	#dungeonxsize<<8,d4
	cmp.w	d4,d1			;out of range?
	bhs.s	.notfoundxintersect

.xintersectloop:
	move.l	d6,d2
	clr.b	d2
	move.w	d1,d3
	lsr.w	#4,d3
	move.b	d3,d2
	lsr.w	#4,d2
	tst.b	(a3,d2.w)
	bne.s	.foundxintersect
	add.w	d0,d1
	add.w	d5,d6
	cmp.w	d4,d1
	bcc.s	.notfoundxintersect
	cmp.w	d4,d6
	bcs.s	.xintersectloop
.notfoundxintersect:
	moveq	#-1,d4
	bra.s	.endxintersect
.foundxintersect:
	andi.w	#$00fc,d1			; align to longword (txt is 64 longs wide)
	movea.w	d1,a4				* Save X-intersection (for texture coord)
	sub.w	playery(pc),d6
	bpl.s	.xposy
	neg.w	d6
.xposy:	move.w	d6,d4				* Save dY (for distance calc)
.endxintersect:
	
* Calculate castline and check for intersection with vertical wall.
* distToNextYIntersection = fYStepTable[castArc];
.findyquad:
	move.w	(a1)+,d0			; d0=ystep
	addq	#4,a1
	movem.w	playerx(pc),d1/d6
	move.w	d1,d2
	clr.b	d1
	sub.w	d1,d2				* d2.w: X distance to first gridpoint

	cmpi.w	#sintbllen/2,d7
	bhs.s	.ytestquad34
	move.w	#$0100,d5
	add.w	d5,d1
	not.b	d2
	muls.w	d0,d2
	asr.l	#8,d2
	add.w	d2,d6
	bra.s	.endfindyquad
.ytestquad34:
	subq.w	#1,d1			;?
	move.w	#$ff00,d5
	muls.w	d0,d2
	asr.l	#8,d2
	add.w	d2,d6
.endfindyquad:
	cmpi.w	#dungeonysize<<8,d6
	bhs.s	.notfoundyintersect

.yintersectloop:
	move.w	d6,d2
	clr.b	d2
	move.w	d1,d3
	lsr.w	#4,d3
	move.b	d3,d2
	lsr.w	#4,d2
	tst.b	(a3,d2.w)
	bne.s	.foundyintersect
	add.w	d5,d1
	add.w	d0,d6
	move.w	#dungeonxsize<<8,d2
	cmp.w	d2,d1
	bcc.s	.notfoundyintersect
	cmp.w	d2,d6
	bcs.s	.yintersectloop
.notfoundyintersect:
	moveq	#-1,d1
	bra.s	.endyintersect
.foundyintersect:
	andi.w	#$00fc,d6
	movea.l	d6,a5
	sub.w	playerx(pc),d1
	bpl.s	.yposx
	neg.w	d1
.yposx:						* Save dX (for distance calc)
.endyintersect:

* Find out which intersection is nearest...
* The horizontal or the vertical...
	move.w	(a2)+,d2			; d2=1/sin
	move.w	(a2)+,d3			; d3=1/cos
	addq	#4,a2
	tst.w	d4
	bmi.s	.calc_verdist
	tst.w	d1
	bmi.s	.calc_hordist
	mulu.w	d3,d4
	mulu.w	d2,d1
	cmp.l	d4,d1
	blt.s	.end_getdist
	move.l	d4,d1
	movea.l	a4,a5
	bra.s	.end_getdist
.calc_hordist:
	mulu.w	d3,d4
	move.l	d4,d1
	movea.l	a4,a5
	bra.s	.end_getdist
.calc_verdist:
	tst.l	d1
	bpl.s	.okido
	clr.w	(a6)+				; Store 0 height..
	bra	.endcolumnloop
.okido:	mulu.w	d2,d1
.end_getdist:
	lsr.l	#7,d1

; range checking on d1 anyone?

; Compensate fishfuck effect.
	mulu.w	(a0),d1				; *cos(ray)
	addq	#4,a0
	swap	d1				; >>16

; Then calculate the slice height.
	move.l	#$00008000,d0			; 12
	divu.w	d1,d0				;~70 ?

	cmpi.w	#48,d0				; If high enough..
	blt.s	.oki
	cmpi.w	#maxslicelen-1,d0		; Clip sliceheight.
	bls.s	.oki
	move.w	#maxslicelen-1,d0		
.oki:	move.w	a5,d1
	move.b	d1,(a6)+			; Store texture offset.
	move.b	d0,(a6)+			; Store height.

; Next column..
.endcolumnloop:
	addq.w	#2,d7
	andi.w	#sintbllen-1,d7
	movea.l	coltabadr,a5
	lea	FRAME_WIDTH*2(a5),a5
	cmpa.l	a5,a6
	blt	.columnloop

; Store column table address for next frame.
	move.l	a6,coltabadr
	rts


;- data --------------------------------------------------------------------

dungeonmap_tbl:
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dc.b	1,0,1,1,0,1,1,1,1,1,1,0,1,1,0,1
	dc.b	1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1
	dc.b	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dc.b	1,0,1,0,0,1,1,0,0,1,1,0,0,1,0,1
	dc.b	1,0,1,0,0,1,0,0,0,0,1,0,0,1,0,1
	dc.b	0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0
	dc.b	1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1
	dc.b	1,0,1,0,0,1,0,0,0,0,1,0,0,1,0,1
	dc.b	1,0,1,0,0,1,1,0,0,1,1,0,0,1,0,1
	dc.b	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dc.b	1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1
	dc.b	1,0,1,1,0,1,1,1,1,1,1,0,1,1,0,1
	dc.b	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

dungeontraject_tbl:
	DC.W	((.end-.start)/trajentrysize)-1
.start:	DC.L	0
	DC.W	$0,$780
	DC.W	512

	DC.L	200
	DC.W	$180,$780
	DC.W	0

	DC.L	300
	DC.W	$180,$480
	DC.W	0

	DC.L	400
	DC.W	$140,$180
	DC.W	512

	DC.L	500
	DC.W	$480,$140
	DC.W	1024

	DC.L	550
	DC.W	$400,$300
	DC.W	700

	DC.L	650
	DC.W	$800,$380
	DC.W	900

	DC.L	750
	DC.W	$b80,$400
	DC.W	1024

	DC.L	800
	DC.W	$c00,$500
	DC.W	1200

	DC.L	850
	DC.W	$c40,$600
	DC.W	1400

	DC.L	900
	DC.W	$c40,$800
	DC.W	1600

	DC.L	1000
	DC.W	$b80,$800
	DC.W	1800

	DC.L	1100
	DC.W	$a00,$800
	DC.W	2048

	DC.L	1200
	DC.W	$800,$800
	DC.W	2048+256

	DC.L	1250
	DC.W	$800,$800
	DC.W	2048+512

	DC.L	1275
	DC.W	$800,$800
	DC.W	2048+1024

	DC.L	1300
	DC.W	$800,$800
	DC.W	2048+1536

	DC.L	1325
	DC.W	$800,$800
	DC.W	2048*2

	DC.L	1350
	DC.W	$800,$800
	DC.W	2048*2+512

	DC.L	1392
	DC.W	$800,$800
	DC.W	2048*2+1024

	DC.L	1425
	DC.W	$800,$800
	DC.W	2048*2+1400

	DC.L	1450
	DC.W	$800,$800
	DC.W	2048*2+1750

	DC.L	1475
	DC.W	$800,$800
	DC.W	2048*3+100

	DC.L	1500
	DC.W	$800,$800
	DC.W	2048*3+450

	DC.L	1525
	DC.W	$800,$800
	DC.W	2048*3+800

	DC.L	1550
	DC.W	$800,$800
	DC.W	2048*3+1024

	DC.L	1575
	DC.W	$800,$800
	DC.W	2048*3+1300

	DC.L	1600
	DC.W	$800,$800
	DC.W	2048*3+1500

	DC.L	1625
	DC.W	$800,$800
	DC.W	2048*3+1700

	DC.L	1675
	DC.W	$800,$800
	DC.W	2048*3+1900

	DC.L	1725
	DC.W	$800,$780
	DC.W	2048*4

	DC.L	1775
	DC.W	$800,$680
	DC.W	2048*4

	DC.L	1850
	DC.W	$880,$400
	DC.W	2048*4+200

	DC.L	1900
	DC.W	$900,$380
	DC.W	2048*4+512

	DC.L	1950
	DC.W	$a00,$3c0
	DC.W	2048*4+512

	DC.L	2000
	DC.W	$b00,$480
	DC.W	2048*4+600

	DC.L	2100
	DC.W	$e80,$480
	DC.W	2048*4+700

	DC.L	2150
	DC.W	$e80,$500
	DC.W	2048*4+1024

	DC.L	2200
	DC.W	$e80,$600
	DC.W	2048*4+1024

	DC.L	2250
	DC.W	$e80,$700
	DC.W	2048*4+700

	DC.L	2300
	DC.W	$fff,$780
	DC.W	2048*4+700
.end:

splinetraject_tbl:
	DC.W	(.end-.start)/VertexKeyEntry.SIZE

.start:	DC.W	$0,0				; X,GX
	DC.W	$780,0				; Y,GY
	DC.W	512,0				; R,GR
	DC.L	200				; interval

	DC.W	$180,0
	DC.W	$780,0
	DC.W	0,0
	DC.L	100

	DC.W	$180,0
	DC.W	$480,0
	DC.W	0,0
	DC.L	100

	DC.W	$140,0
	DC.W	$180,0
	DC.W	512,0
	DC.L	100

	DC.W	$480,0
	DC.W	$140,0
	DC.W	1024,0
	DC.L	50

	DC.W	$400,0
	DC.W	$300,0
	DC.W	700,0
	DC.L	100

	DC.W	$800,0
	DC.W	$380,0
	DC.W	900,0
	DC.L	50

	DC.W	$b80,0
	DC.W	$400,0
	DC.W	1024,0
	DC.L	50

	DC.W	$c00,0
	DC.W	$500,0
	DC.W	1200,0
	DC.L	50

	DC.W	$c40,0
	DC.W	$600,0
	DC.W	1400,0
	DC.L	100

	DC.W	$c40,0
	DC.W	$800,0
	DC.W	1600,0
	DC.L	100

	DC.W	$b80,0
	DC.W	$800,0
	DC.W	1800,0
	DC.L	100

	DC.W	$a00,0
	DC.W	$800,0
	DC.W	2048,0
	DC.L	100

	DC.W	$800,0
	DC.W	$800,0
	DC.W	2048,0
	DC.L	500

	DC.W	$800,0
	DC.W	$800,0
	DC.W	2048*4,0
	DC.L	100

	DC.W	$800,0
	DC.W	$680,0
	DC.W	2048*4,0
	DC.L	75

	DC.W	$880,0
	DC.W	$400,0
	DC.W	2048*4+200,0
	DC.L	50

	DC.W	$900,0
	DC.W	$3c0,0		;$380,0
	DC.W	2048*4+512,0
	DC.L	50

	DC.W	$a00,0
	DC.W	$3c0,0
	DC.W	2048*4+512,0
	DC.L	50

	DC.W	$b00,0
	DC.W	$480,0
	DC.W	2048*4+600,0
	DC.L	100

	DC.W	$e00,0
	DC.W	$480,0
	DC.W	2048*4+700,0
	DC.L	50

	DC.W	$e40,0
	DC.W	$500,0
	DC.W	2048*4+1024,0
	DC.L	50

	DC.W	$e40,0
	DC.W	$600,0
	DC.W	2048*4+1024,0
	DC.L	50

	DC.W	$e40,0
	DC.W	$700,0
	DC.W	2048*4+700,0
	DC.L	50

	DC.W	$fff,0
	DC.W	$780,0
	DC.W	2048*4+700,0
	DC.L	50
.end:
; last entry...
	DC.W	$fff,0
	DC.W	$780,0
	DC.W	2048*4+700,0
	DC.L	50

coltabadr:
	DC.L	colbuf

sine_tbl:
	INCBIN	SINUS.DAT

filename:
	DC.B	"H:\CODING\UCM15INT\FRAMES2.DAT",0
	EVEN

;- reserves ----------------------------------------------------------------

	BSS

trajectstep:
	DS.W	1
time:	DS.L	1

vertex_buffer:
	DS.B	VertexKeyBuf.SIZE

playerx:DS.W	1
playery:DS.W	1
playerarc:
	DS.W	1

frames:	DS.W	1
colbuf:	DS.B	FRAME_SIZE*((2300/VBLS)+1)

tantbl:	DS.W	sintbllen
itantbl:DS.W	sintbllen
isinetbl:
	DS.L	sintbllen*2		; 1/sin,1/cos,.. (doubled)
xysteptbl:
	DS.L	sintbllen*2		; x,y,x... (doubled)
costable:
	DS.W	sintbllen*2		; doubled

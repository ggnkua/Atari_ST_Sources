; todo:
; speed optimisation!!!!
; - limit background restoral (possibly delta clearing)
; - test width of poly for jump table or dbf filler!
; - delta polys when polys get too wide

PERSPECTIVE:=	1
OPT_MUL:=	1

WAIT_FOR_KEY:=	1

MAX_Y:=		200
MAX_VERTICES:=	100

		rsreset
Vertex.X_COORD:	rs.w	1
Vertex.Y_COORD:	rs.w	1
Vertex.SIZE:	rs.b	0

		rsreset
Matrix.XX:	rs.w	1
Matrix.XY:	rs.w	1
Matrix.XZ:	rs.w	1
Matrix.YX:	rs.w	1
Matrix.YY:	rs.w	1
Matrix.YZ:	rs.w	1
Matrix.ZX:	rs.w	1
Matrix.ZY:	rs.w	1
Matrix.ZZ:	rs.w	1
Matrix.TX:	rs.l	1
Matrix.TY:	rs.l	1
Matrix.TZ:	rs.l	1
Matrix.SIZE:	rs.b	0

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Stm1.mainloop
	dc.l	Stm1.init
	dc.l	Stm1.rt_init		; 2
	dc.l	Stm1.deinit
	dc.l	Stm1.set_no_rot		; 4
	dc.l	Stm1.start_rot		; 5
	dc.l	0

;- plugin routines ---------------------------------------------------------

Stm1.init:
	bsr	precalc_mul_table
	bsr	init_sincos_table
	bsr	Polygon.calcInvTable
	rts

Stm1.rt_init:
	move.l	#Stm1.init_pal,palirq

	;move.l	#screen,d0
	;clr.b	d0
	;move.l	d0,screen_adr

	bsr	Stm1.set_no_rot

	move.l	frmcnt,first_frame
	rts

Stm1.deinit:
	ifnd	DEMO_SYSTEM
	lea	.str2(pc),a4
	clr.l	d7
	move.w	$0468.w,d7
	bsr	mkhex4

	pea	.str(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	endc
	rts

.str:	dc.b	"grote kutactie lot nr: $"
.str2:	dc.b	"0123",10,13,0
	even

; input:
; d7.w=number
; a4: dst buffer..
mkhex4:	moveq	#4-1,d5
;	rol.l	#8,d7
	swap	d7
.hex1:	rol.l	#4,d7
	move.w	d7,d6
	and.w	#$f,d6
	add.b	#'0',d6
	cmp.b	#'9',d6
	bls.s	.br1
	addq.b	#'A'-'9'-1,d6
.br1:	move.b	d6,(a4)+
	dbf	d5,.hex1
	rts	

Stm1.mainloop:
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc

	move.l	frmcnt,d1
	sub.l	first_frame,d1
	subq.l	#2,d1
	bhs.s	.normal_clear
.first_clear:
	movea.l	scr,a0
	bsr	CLEAR_STSCREEN
	bra.s	.clear_done
.normal_clear:
	bsr	clear_square
.clear_done:

	ifeq	testmode
	move.w	#$0304,$FFFF8240.w
	endc

	move.w	$0468.w,d0
	sub.w	Stm1.rot_start,d0
	tst.w	Stm1.rot_on
	bne.s	.rot_calced
	moveq	#0,d0
.rot_calced:
	move.w	d0,d1
	move.w	d0,d2
	mulu.w	#3,d0
	mulu.w	#5,d1
	mulu.w	#7,d2
;	lsr.l	#1,d1
;	lsr.l	#2,d2
;	move.w	#100,d0
;	move.w	#200,d1
;	move.w	#1100,d2
	move.w	#600,d3
	bsr	Matrix.generate

	moveq	#0,d0
	moveq	#0,d1
	move.w	#400,d2
	bsr	Matrix.translate

	lea	transformed_object,a0
	lea	Matrix.temp,a1
	lea	object,a2
	bsr	Object.transform

	ifeq	testmode
	move.w	#$0440,$FFFF8240.w
	endc

	lea	polys,a1
	move.w	(a1)+,d7
	beq	.end_loop
	subq.w	#1,d7
	clr.l	vis_flags

.loop:	move.w	(a1)+,d0			; d0.w=plane index
	add.w	d0,d0				; d0.w=plane offset
	movea.l	scr,a0
	adda.w	d0,a0
	move.l	a0,Primitive.screenadr

	lea	transformed_object+2,a2
	lea	temp_poly(pc),a0
	move.w	(a1)+,d6
	move.w	d6,(a0)+
	subq.w	#1,d6

.vloop:	move.w	(a1)+,d0
	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	move.l	(a2,d0.w),(a0)+
	dbf	d6,.vloop

	movem.w	temp_poly+2(pc),d0-d5		; d0.w=x1, d1.w=y1, d2.w=x2, d3.w=y2, d4.w=x3, d5.w=y3
	sub.w	d2,d0				; d0.w=x1-x2
	sub.w	d3,d1				; d1.w=y1-y2
	sub.w	d2,d4				; d4.w=x3-x2
	sub.w	d3,d5				; d5.w=y3-y2
	muls.w	d1,d4				; d4.l=(x3-x2)(y1-y2)
	muls.w	d0,d5				; d5.l=(x1-x2)(y3-y2)
	sub.l	d4,d5
	ble.s	.skippy_the_bush_kangaroo

	movem.l	d7/a1,-(sp)
	lea	temp_poly(pc),a0
	bsr	paint_flat_poly
	movem.l	(sp)+,d7/a1

	move.w	vis_flags+2(pc),d0
	addq.w	#1,d0
	move.w	d0,vis_flags+2
.skippy_the_bush_kangaroo:
	move.l	vis_flags(pc),d0
	add.l	d0,d0
	move.l	d0,vis_flags
.next_poly:
	dbf	d7,.loop
.end_loop:

	ifeq	testmode
	move.w	#$0f00,$FFFF8240.w
	endc

	ifne	0

	move.w	#0,d0
	move.w	#0,d1
	move.w	#60,d2	#20,d2
	move.w	#22,d3	#100,d3
	moveq	#$F,d4
	movea.l	scr,a0
	lea	scan_table,a1
	lea	putpix_table,a2
	bsr	Line.paint

	else

; check for visibility of polygon with mouse buttons on top..
	move.l	vis_flags(pc),d0
	btst	#7-2,d0
	beq.s	.end_lines

	lea	lines,a4
	move.w	(a4)+,d7
	beq.s	.end_lines
	subq.w	#1,d7
	moveq	#$F,d4

.line_loop:
	movea.l	scr,a0
	move.w	(a4)+,d0
	add.w	d0,d0
	adda.w	d0,a0

	move.w	(a4)+,d0
	move.w	(a4)+,d2
	add.w	d0,d0				; d0.w=2i
	move.w	d0,d1				; d1.w=2i
	add.w	d0,d0				; d0.w=4i
	add.w	d1,d0				; d0.w=2i+4i=6i
	add.w	d2,d2
	move.w	d2,d1
	add.w	d2,d2
	add.w	d1,d2
	lea	transformed_object+2,a2
	movem.w	(a2,d0.w),d0-d1
	movem.w	(a2,d2.w),d2-d3
	lea	putpix_table,a2

	move.w	d7,-(sp)
	lea	scan_table,a1
	bsr	Line.paint
	move.w	(sp)+,d7

	dbf	d7,.line_loop
.end_lines:

	endc

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-4(a0)
	move.l	d0,(a0)

	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	ifeq	testmode
	clr.w	$FFFF8240.w
	endc

	move.w	$0468.w,d0
.wait:	cmp.w	$0468.w,d0
	beq.s	.wait

	rts

temp_poly:
	ds.w	100
first_frame:
	ds.l	1
vis_flags:
	ds.l	1

scan_table:
.offset	set	0
	rept	MAX_Y
	dc.w	.offset
.offset	set	.offset+160
	endr

putpix_table:
	dc.w	$8000,$4000,$2000,$1000
	dc.w	$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010
	dc.w	$0008,$0004,$0002,$0001

;--------------------------------------------------------------------------

Stm1.set_no_rot:
	clr.w	Stm1.rot_on
	rts

Stm1.start_rot:
	move.w	$468.w,Stm1.rot_start
	st	Stm1.rot_on
	rts

Stm1.init_pal:
	move.w	#$0222,$FFFF8242.w
	move.w	#$0333,$FFFF8244.w
	move.w	#$0222,$FFFF8246.w
	move.w	#$0444,$FFFF8248.w
	move.w	#$0222,$FFFF824A.w
	move.w	#$0444,$FFFF824C.w
	move.w	#$0222,$FFFF824E.w
	move.w	#$0FFF,$FFFF8250.w
	move.w	#$0FFF,$FFFF8252.w
	move.w	#$0FFF,$FFFF8254.w
	move.w	#$0FFF,$FFFF8256.w
	move.w	#$0FFF,$FFFF8258.w
	move.w	#$0FFF,$FFFF825A.w
	move.w	#$0FFF,$FFFF825C.w
	move.w	#$0FFF,$FFFF825E.w
	rts

precalc_mul_table:
	lea	mul_table+128*256*2,a0
	clr.w	d1

.yloop:	clr.w	d0

.xloop:	move.w	d0,d2
	move.w	d1,d3
	ext.w	d2
	ext.w	d3
	muls.w	d2,d3

	asr.w	#6,d3

	move.w	d0,d2
	lsl.w	#8,d2
	move.b	d1,d2
	ext.l	d2
	add.l	d2,d2
	move.w	d3,(a0,d2.l)
	addq.b	#1,d0
	bne.s	.xloop

	addq.b	#1,d1
	bne.s	.yloop
	rts

SINTABLE_LEN:	=	2048
SIN1:		=	13176774	; sin(2ã/2048)*2^32
COS1:		=	4294947083	; cos(2ã/2048)*2^32

; input:
; d0.l=s (sh,sl)
; d2.l=d (dh,dl)
; output:
; d1.l=rhi=sl*dl + (sl*dh).lo<<16 +(sh*dl).lo<<16
; d2.l=rlo=sh*dh + (sl*dh).hi+x0 + (sh*dl).hi+x1
lmulu:	move.l	d2,d3
	swap	d3			; d3.w=dh
	move.w	d3,d1			; d1.w=dh
	move.w	d2,d4			; d4.w=dl
	mulu.w	d0,d2			; d2.l=dl*sl
	mulu.w	d0,d3			; d3.l=dh*sl
	swap	d0			; d0.w=sh
	mulu.w	d0,d1			; d1.l=dh*sh
	mulu.w	d0,d4			; d4.l=dl*sh

	move.l	d3,d5
	swap	d5
	clr.w	d5			; d5.l=(dh*sl).lo<<16
	add.l	d5,d2			; d2.l=dl*sl + (dh*sl).lo<<16

	clr.w	d3
	swap	d3			; d3.l=(dh*sl).hi
	addx.l	d3,d1			; d1.l=dh*sh + (dh*sl).hi+x0

	move.l	d4,d5
	swap	d5
	clr.w	d5			; d5.l=(dl*sh).lo<<16
	add.l	d5,d2			; d2.l=rlo=dl*sl + (dh*sl).lo<<16 + (dl*sh).lo<<16

	clr.w	d4
	swap	d4			; d4.l=(dl*sh).hi
	addx.l	d4,d1			; d1.l=rhi=dh*sh + (dh*sl).hi+x0 + (dl*sh).hi+x1
	
	rts

init_sincos_table:
	lea	sine_tbl,a0
	moveq	#$ffffffff,d0
	lsr.l	#1,d0				; d0.l=cos[0]=.99999~=1
	moveq	#0,d1				; d1.l=sin[0]=0
	move.l	#SIN1,d6
	move.l	#COS1,d7
	suba.l	a1,a1
; n=1
.loop:	swap	d0				; d0.w=high word of cos[n]
	swap	d1				; d1.w=high word of sin[n]
	move.w	d1,2+(SINTABLE_LEN)*3(a0)	; copy +sin[n] in cos-4th quadrant
	move.w	d0,SINTABLE_LEN*1(a0)		; copy +cos[n] in sin-2nd quadrant
	sub.w	d1,2+(SINTABLE_LEN)*1(a0)	; copy -sin[n] in cos-2nd quadrant
	sub.w	d0,SINTABLE_LEN*3(a0)		; copy -cos[n] in sin-4th quadrant
	sub.w	d0,2+(SINTABLE_LEN)*2(a0)	; copy -cos[n] in cos-3rd quadrant
	sub.w	d1,SINTABLE_LEN*2(a0)		; copy -sin[n] in sin-3rd quadrant
	move.w	d1,(a0)+			; save sin[n] (16 bit signed value) in first quadrant
	move.w	d0,(a0)+			; save cos[n] (16 bit signed value) in first quadrant
	swap	d0				; d0.l=cos[n] (16:16)
	swap	d1				; d1.l=sin[n] (16:16)
	move.l	d1,d4				; d4.l=sin[n] (16:16)
	move.l	d0,d5				; d5.l=cos[n] (16:16)
	move.l	d1,d2				; d2.l=sin[n] (16:16)
	move.l	d0,d3				; d3.l=cos[n] (16:16)

	movem.l	d0/d2/d4/d5,-(sp)
	move.l	d6,d0
	move.l	d1,d2
	bsr	lmulu				; d6,d3:d1, d3.l=sin[1]*sin[n-1]
	move.l	d1,d3
	move.l	d2,d1
	movem.l	(sp)+,d0/d2/d4/d5

	movem.l	d1/d3-d5,-(sp)
	move.l	d0,d2
	move.l	d7,d0
	bsr	lmulu				; d7,d2:d0, d2.l=cos[1]*cos[n-1]
	move.l	d2,d0
	move.l	d1,d2
	movem.l	(sp)+,d1/d3-d5

	movem.l	d0/d2-d4,-(sp)
	move.l	d6,d0
	move.l	d5,d2
	bsr	lmulu				; d6,d1:d5, d0.l=sin[1]*cos[n-1]
	move.l	d2,d5
	movem.l	(sp)+,d0/d2-d4

	movem.l	d1-d3/d5,-(sp)
	move.l	d7,d0
	move.l	d4,d2
	bsr	lmulu				; d7,d0:d4, d1.l=cos[1]*sin[n-1]
	move.l	d2,d4
	move.l	d1,d0
	movem.l	(sp)+,d1-d3/d5

	sub.l	d3,d2				; d2.l=(cos1*cos[n-1])-(sin1*sin[n-1])
	add.l	d0,d1				; d1.l=sin[n+1]=(sin1*cos[n])+(cos1*sin[n])
	move.l	d2,d0				; d0.l=cos[n+1]=(cos1*cos[n])-(sin1*sin[n])
	addq	#1,a1
	cmpa.w	#SINTABLE_LEN/4,a1
	blt	.loop

	rts

;--------------------------------------------------------------------------
; vertex processing plant..
;--------------------------------------------------------------------------

; seems to work ok, since there has been some patching on the overflow
; errors (caused by combination of finite accuracy and use of maximum range).
; input:
; d0.w= x rotation (a)
; d1.w= y rotation (b)
; d2.w= z rotation (c)
; d3.w= z (for non-perspective scaled projection)
Matrix.generate:
	ifeq	PERSPECTIVE
	move.l	#$007FFFFF,d7
	divu.w	d3,d7
	endc
	lea	Matrix.temp,a0
; 1] rotate 3 axis.
	move.w	#2048-1,d3
	and.w	d3,d0
	and.w	d3,d1
	and.w	d3,d2
	movea.w	d0,a3				; a3=xrot=a
	movea.w	d1,a4				; a4=yrot=b
	movea.w	d2,a5				; a5=zrot=c
	adda.w	a3,a3
	adda.w	a3,a3				; a3=xrot*4=4a (addressing offset)
	adda.w	a4,a4
	adda.w	a4,a4				; a4=yrot*4=4b (addressing offset)
	adda.w	a5,a5
	adda.w	a5,a5				; a5=zrot*4=4c (addressing offset)
	lea	sine_tbl,a2

; x' = + x*cos(b)*cos(c)
;      - y*cos(b)*sin(c)
;      + z*sin(b)
	movem.w	(a2,a4.w),d3/d4
	movem.w	(a2,a5.w),d5/d6
	muls.w	d4,d6				; / cos(b)*sin(c)
	add.l	d6,d6				; |
	swap	d6				; \
	muls.w	d4,d5				; / -cos(b)*sin(c)
	add.l	d5,d5				; |
	swap	d5				; |
	neg.w	d5				; \
	ifeq	PERSPECTIVE
	muls.w	d7,d6
	muls.w	d7,d5
	muls.w	d7,d3
	add.l	d6,d6
	add.l	d5,d5
	add.l	d3,d3
	swap	d6
	swap	d5
	swap	d3
	endc
	move.w	d6,(a0)+
	move.w	d5,(a0)+
	move.w	d3,(a0)+
	
; y' = + x*(sin(a)*sin(b)*cos(c)+cos(a)*sin(c))
;      + y*(cos(a)*cos(c)-sin(a)*sin(b)*sin(c))
;      - z*sin(a)*cos(b)
	movem.w	(a2,a3.w),d0/d1
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d0,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d5
	add.l	d5,d5
	swap	d5
	muls.w	d1,d4
	add.l	d4,d4
	swap	d4
	add.w	d4,d5
	bvc.s	.skipyvd5
	addq.w	#1,d5
	neg.w	d5
.skipyvd5:
	move.w	d5,d3
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d1,d5
	add.l	d5,d5
	swap	d5
	muls.w	d0,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	sub.w	d4,d5
	bvc.s	.skipyv2d5
	addq.w	#1,d5
	neg.w	d5
.skipyv2d5:
	move.w	2(a2,a4.w),d4
	muls.w	d0,d4
	add.l	d4,d4
	swap	d4
	neg.w	d4
	ifeq	PERSPECTIVE
	muls.w	d7,d3
	muls.w	d7,d5
	muls.w	d7,d4
	add.l	d3,d3
	add.l	d5,d5
	add.l	d4,d4
	swap	d3
	swap	d5
	swap	d4
	endc
	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

	ifne	PERSPECTIVE

; z' = + x*(sin(a)*sin(c)-cos(a)*sin(b)*cos(c))
;      + y*(cos(a)*sin(b)*sin(c)+sin(a)*cos(c))
;      + z*cos(a)*cos(b)
	movem.w	(a2,a3.w),d0/d1
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d0,d4
	add.l	d4,d4
	swap	d4
	muls.w	d1,d2
	add.l	d2,d2
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
	move.w	(a2,a4.w),d2
	movem.w	(a2,a5.w),d4/d5
	muls.w	d1,d2
	add.l	d2,d2
	swap	d2
	muls.w	d2,d4
	add.l	d4,d4
	swap	d4
	muls.w	d0,d5
	add.l	d5,d5
	swap	d5
	add.w	d4,d5
	bvc.s	.skipzvd5
	addq.w	#1,d5
	neg.w	d5
.skipzvd5:
	move.w	2(a2,a4.w),d4
	muls.w	d1,d4
	add.l	d4,d4
	swap	d4

;	muls.w	d7,d3
;	muls.w	d7,d5
;	muls.w	d7,d4
;	add.l	d3,d3
;	add.l	d5,d5
;	add.l	d4,d4
;	swap	d3
;	swap	d5
;	swap	d4

	move.w	d3,(a0)+
	move.w	d5,(a0)+
	move.w	d4,(a0)+

	else

	addq	#6,a0

	endc

; translation vector = (0,0,0)
	clr.l	d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts

; translate the matrix translation vector.
; input:
; d0.w: x translation
; d1.w: y translation
; d2.w: z translation
Matrix.translate:
	lea	Matrix.temp,a0
	add.w	d0,Matrix.TX(a0)
	add.w	d1,Matrix.TY(a0)
	add.w	d2,Matrix.TZ(a0)
	rts

; input:
; a0: dst object
; a1: matrix
; a2: untransformed object
Object.transform:
	lea	Matrix.TX(a1),a3		; a3: translation vector
	move.w	(a2)+,d7			; d7.w=#vertices
	move.w	d7,(a0)+			; store #vertices in dst object.
	subq.w	#1,d7
	movea.l	d7,a5				; a5=#vertices
	move.l	a0,.dst
	lea	mul_table+128*256*2,a4

	ifne	OPT_MUL
	move.w	(a3),d6
	movea.w	8(a3),a6
	movea.w	4(a3),a3
	else
	movem.l	(a3),d6/a3/a6			; d6.l=tx,a3=ty,a6=tz [16:16]
	endc

.vertexloop:
	movem.w	(a2)+,d0-d2

	ifne	OPT_MUL

; 68000 optimised version! a4: multiply table
; x'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
;	asr.w	#6,d3
	add.w	d6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
; y'
	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
;	asr.w	#6,d3
	add.w	a3,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
; z'

	ifne	PERSPECTIVE

	movem.w	(a1)+,d3-d5

	move.b	d0,d3
	move.b	d1,d4
	move.b	d2,d5
	add.l	d3,d3
	add.l	d4,d4
	add.l	d5,d5
	move.w	(a4,d3.l),d3
	add.w	(a4,d4.l),d3
	add.w	(a4,d5.l),d3
;	asr.w	#6,d3
	add.w	a6,d3				; translate coordinate.
	move.w	d3,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	else

	addq	#2,a0
	lea	-2*6(a1),a1

	endc

	else

; x'
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	d6,d5				; translate coordinate.
	swap	d5
	move.w	d5,(a0)+			; store coordinate.
; y'
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	a3,d5				; translate coordinate.
	swap	d5
	move.w	d5,(a0)+			; store coordinate.
; z'
	ifne	PERSPECTIVE

	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls.w	(a1)+,d3
	muls.w	(a1)+,d4
	muls.w	(a1)+,d5
	add.l	d3,d5
	add.l	d4,d5
	add.l	d5,d5
	add.l	a6,d5				; translate coordinate.
	swap	d5
	move.w	d5,(a0)+			; store coordinate.
	lea	-3*6(a1),a1

	else

	addq	#2,a0
	lea	-2*6(a1),a1

	endc

	endc

	dbf	d7,.vertexloop

; perspectivate...
	movea.l	.dst,a0				; a0: dst object
	move.w	a5,d7				; d7.w=#vertices
	move.w	#160,d4
	move.w	#100,d5
	move.w	#$0100,d3			; d3.w=z_offset

	ifne	0

; nasty unroll optimisation!
	rept	86
	move.w	(a0),d0
	asr.w	d0
	add.w	d4,d0
	move.w	d0,(a0)+
	move.w	(a0),d1
	asr.w	d1
	add.w	d5,d1
	move.w	d1,(a0)+
	addq	#2,a0
	endr

	else

.loop:	movem.w	(a0),d0-d2
	ifne	PERSPECTIVE
	lsl.l	#8,d0
	lsl.l	#8,d1
	add.w	d3,d2
	divs.w	d2,d0
	divs.w	d2,d1
	else
; todo, scale when no perspective?
	asr.w	d0
	asr.w	d1
	endc
	add.w	d4,d0
	add.w	d5,d1
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq	#2,a0
	dbf	d7,.loop

	endc

	rts

.dst:	dc.l	0

CHUNKS:	=	8

;128/16=8
;8x24=192 cycles per scan
;(192+20)x128=16384+8192=24576+2560 cycles.. (better than ~70000)
	adda.w	d1,a0
	clr.l	d0
.yloop:
	rept	CHUNKS
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	endr
	lea	160-CHUNKS*8(a0),a0
	dbf	d7,.yloop

; fast but messes up rasters, tho..
; todo: flexible size (depending on bounding slab)
clear_square:
	movea.l	scr,a6
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	movea.l	d0,a0
	movea.l	d1,a1
	movea.l	d2,a2
	movea.l	d3,a3
	movea.l	d4,a4
	movea.l	d5,a5
	lea	(160-80)/2(a6),a6
; todo: clear regs..
.offset	set	160*24
	rept	152
	movem.l	d0-a5,.offset(a6)
	movem.l	d0-d5,.offset+8*7(a6)
.offset	set	.offset+160
	endr
	rts

;--------------------------------------------------------------------------

; input:
; d0.w=x0
; d1.w=y0
; d2.w=x1
; d3.w=y1
; d4.w=$F
; a0: screen
; a1: offset table
; a2: putpixel table
Line.paint:
	cmp.w	d0,d2
	bgt.s	.x_order_ok
	exg	d0,d2
	exg	d1,d3
.x_order_ok:
	sub.w	d0,d2				; d2.w=dx=abs(dx)
	sub.w	d1,d3				; d3.w=dy
	add.w	d1,d1
	move.w	d0,d5
	and.w	d4,d0				; d0.w=lx&$F
	sub.w	d0,d5				; d5.w=lx&$FFF0
	lsr.w	d5				; d5.w=chunk=(lx&$FFF0)>>2
	add.w	(a1,d1.w),d5			; d5.w=offset=y*160+chunk
	lea	(a0,d5.w),a6
	move.w	#160,d6				; d6.w=y increment
	move.w	d3,d7
	bpl.s	.y_abs
	neg.w	d7
	neg.w	d6				; negative increment!
.y_abs:	cmp.w	d2,d7
	bgt.s	.dy_greater

.dx_greater:
; todo: special masking shit!	
;	add.w	d0,d0
;	cmp.w	d0,d5
;	bgt.s	.mask_optimised
; choose a mask-optimised thingy or straight-forward put-pixel stuffs.
	
; for now we use a totally 100% pessimised (but simple) loop!
	move.w	d2,d5				; d5.w=abs(dx)
	move.w	d2,d3				; d3.w=abx(dx)
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	clr.w	d1

.hor_loop:
	or.w	d0,d1
	sub.w	d7,d5
	bgt.s	.next_hor
	add.w	d2,d5
	or.w	d1,(a6)
	clr.w	d1
	adda.w	d6,a6
.next_hor:
	ror.w	d0
	dbcs	d3,.hor_loop

	or.w	d1,(a6)
	clr.w	d1
	addq	#8,a6
	subq.w	#1,d3
	bpl.s	.hor_loop
	rts

; todo: use table to get rout decision?
.dy_greater:
	move.w	d7,d5				; d5.w=abs(dy)
	move.w	d7,d3
	add.w	d0,d0
	move.w	(a2,d0.w),d0
;	tst.w	d2
;	bmi.s	.rol_loop

.ror_loop:
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	.next_ror
	add.w	d3,d5
	ror.w	d0
	bcc.s	.next_ror
	addq	#8,a6
.next_ror:
	adda.w	d6,a6
	dbf	d7,.ror_loop
	rts

; never gets called with dx>=0
.rol_loop:
	or.w	d0,(a6)
	sub.w	d2,d5
	bgt.s	.next_rol
	add.w	d3,d5
	add.w	d0,d0
	bcc.s	.next_rol
	moveq	#1,d0
	subq	#8,a6
.next_rol:
	adda.w	d6,a6
	dbf	d7,.ror_loop
	rts

;--------------------------------------------------------------------------

Polygon.calcInvTable:
	lea	Polygon.invTable,a0
	move.l	#$8000,d1
	moveq	#2,d0
	move.w	#$7fff,(a0)+
	move.w	#$7fff,(a0)+

.posloop:
	move.l	d1,d2
	divu.w	d0,d2
	move.w	d2,(a0)+
	addq.w	#1,d0
	cmpi.w	#MAX_Y+1,d0
	blt.s	.posloop
	rts

; input:
; a0: old poly (frame n-1) (#vertices (V), (x,y)[0], .., (x,y)[n-1], (x,y)[n])
; a1: new poly (frame n)   (#vertices (V), (x,y)[0], .., (x,y)[n-1], (x,y)[n])
;
; notation:
; ve = (x,y)
paint_poly_deltas:
	move.w	(a1)+,d7	; d7.w=V
	beq.s	.end
	addq	#2,a0
	subq.w	#1,d7		; d7.w=V-1

.edge_loop:
; 1) calculate envelope of delta polygon..
	lea	edge_poly,a2
	move.l	(a0)+,d0	; d0.l=(x,y)[v,0], a0: (x,y)[v+1,0]
	move.l	(a0),d1		; d1.l=(x,y)[v+1,0]
	move.l	d1,(a2)+
	move.l	d0,(a2)+	; (a2-8): {(x,y)[v+1,0], (x,y)[v,0]}
	move.l	(a1)+,(a2)+	; a0: (x,y)[v+1,1]
	move.l	(a1),(a2)+	; (a2-16): {ve[v+1,0], ve[v,0], ve[v,1], ve[v+1,1]}

; 2) split envelope into new/old parts..
	dbf	d7,.edge_loop

.end:	rts

edge_poly:
	ds.l	4*2

;--------------------------------------------------------------------------

JUMPTREE:=	1

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a0: screen
; a1: left_edge_table
macro_hline1fat:	macro
	moveq	#$F,d4			; d4.w=$000F=mask
	move.w	d6,d7			; d7.w=x1
	and.w	d4,d7			; d7.w=x1&$F
	and.w	d5,d4			; d4.w=$F&x0=x0&$F
	sub.w	d4,d5			; d5.w=x0-(x0&$F)=x0&$FFF0=(x0>>4)<<4
	sub.w	d7,d6			; d6.w=x1-(x1&$F)=x1&$FFF0=(x0>>4)<<4
	sub.w	d5,d6			; d6.w=(x1>>4-x0>>4)<<4
	bne.s	.multi_chunk

.single_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	add.w	d4,d4
	add.w	d7,d7
	move.w	(a1,d4.w),d4
	and.w	32(a1,d7.w),d4
	or.w	d4,(a0,d5.w)
	bra.s	.end

.multi_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	lea	(a0,d5.w),a6		; a6: first chunk

	ifne	1 JUMPTREE

	lsr.w	#2,d6			; d6.w=#num_chunks*4=4(x1>>4-x0>>4) (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#4,d6			; d6.w=chunks-1
.end_left_chunk:

	moveq	#$FFFFFFFF,d4
	neg.w	d6
	jmp	.jump_end(pc,d6.w)
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
.jump_end:

	else

	lsr.w	#4,d6			; d6.w=#num_chunks=x1>>4-x0>>4 (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#1,d6			; d6.w=chunks-1
.end_left_chunk:

; body chunks..
	subq.w	#1,d6
	bmi.s	.end_body
	moveq	#$FFFFFFFF,d4
.loop:	move.w	d4,(a6)
	addq	#8,a6
	dbf	d6,.loop
.end_body:		

	endc

; rightmost chunk..
	add.w	d7,d7
	move.w	32(a1,d7.w),d5		; d5.w=mask
	or.w	d5,(a6)
.end_right_chunk:
.end:
	endm

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a0: screen
; a1: left_edge_table
macro_hline1slim:	macro
	moveq	#$F,d4			; d4.w=$000F=mask
	move.w	d6,d7			; d7.w=x1
	and.w	d4,d7			; d7.w=x1&$F
	and.w	d5,d4			; d4.w=$F&x0=x0&$F
	sub.w	d4,d5			; d5.w=x0-(x0&$F)=x0&$FFF0=(x0>>4)<<4
	sub.w	d7,d6			; d6.w=x1-(x1&$F)=x1&$FFF0=(x0>>4)<<4
	sub.w	d5,d6			; d6.w=(x1>>4-x0>>4)<<4
	bne.s	.multi_chunk

.single_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	add.w	d4,d4
	add.w	d7,d7
	move.w	(a1,d4.w),d4
	and.w	32(a1,d7.w),d4
	or.w	d4,(a0,d5.w)
	bra.s	.end

.multi_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	lea	(a0,d5.w),a6		; a6: first chunk

	ifne	0 JUMPTREE

	lsr.w	#2,d6			; d6.w=#num_chunks*4=4(x1>>4-x0>>4) (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#4,d6			; d6.w=chunks-1
.end_left_chunk:

	moveq	#$FFFFFFFF,d4
	neg.w	d6
	jmp	.jump_end(pc,d6.w)
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
	move.w	d4,(a6)
	addq	#8,a6
.jump_end:

	else

	lsr.w	#4,d6			; d6.w=#num_chunks=x1>>4-x0>>4 (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#1,d6			; d6.w=chunks-1
.end_left_chunk:

; body chunks..
	subq.w	#1,d6
	bmi.s	.end_body
	moveq	#$FFFFFFFF,d4
.loop:	move.w	d4,(a6)
	addq	#8,a6
	dbf	d6,.loop
.end_body:		

	endc

; rightmost chunk..
	add.w	d7,d7
	move.w	32(a1,d7.w),d5		; d5.w=mask
	or.w	d5,(a6)
.end_right_chunk:
.end:
	endm

; Subroutine that paints a flatshaded fragment. NO clipping!
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d7.w: number of scanlines to paint - 1
; a0: start of begin screenline
; a5: width (bytes)
; OUTPUT: a0: start of next screenline
paint_flatfragment_fat:
	movem.l	a1-a2/a6,-(sp)
	lea	left_edge_table(pc),a1
	movea.l	d2,a2				; a2: 16:16 left stepvalue
	move.w	d7,d2

.yloop:
; todo: nasty stack stuff this.. define a stack offset record?
	cmp.l	d0,d1
	blt	.end__

	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

;	cmp.w	d5,d6
;	blt	.end__

	macro_hline1fat
.end_hline:

	adda.w	a5,a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.end_:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.end__:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	addq	#4,sp
	rts

; Subroutine that paints a flatshaded fragment. NO clipping!
; INPUT:
; d0.l: 16:16 left X-start
; d1.l: 16:16 right X-start
; d2.l: 16:16 left stepvalue
; d3.l: 16:16 right stepvalue
; d7.w: number of scanlines to paint - 1
; a0: start of begin screenline
; a5: width (bytes)
; OUTPUT: a0: start of next screenline
paint_flatfragment_slim:
	movem.l	a1-a2/a6,-(sp)
	lea	left_edge_table(pc),a1
	movea.l	d2,a2				; a2: 16:16 left stepvalue
	move.w	d7,d2

.yloop:
; todo: nasty stack stuff this.. define a stack offset record?
	cmp.l	d0,d1
	blt	.end__

	move.l	d0,d5
	move.l	d1,d6
	swap	d5
	swap	d6

;	cmp.w	d5,d6
;	blt	.end__

	macro_hline1slim
.end_hline:

	adda.w	a5,a0
	add.l	a2,d0
	add.l	d3,d1
	dbf	d2,.yloop

.end_:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	rts

.end__:	move.l	a2,d2				; d2.l= left step (16:16)
	movem.l	(sp)+,a1-a2/a6
	addq	#4,sp
	rts

; input:
; d6.w=n
; a1: poly (x1.w, y1.w, ..., xn.w, yn.w)
check_width:
	moveq	#$FFFFFFFF,d0
	moveq	#$00000000,d1
	subq.w	#1,d6
.loop:	move.w	(a1),d2
	cmp.w	d0,d2
	bhs.s	.no_new_left
	move.w	d2,d0
.no_new_left:
	cmp.w	d1,d2
	bls.s	.no_new_right
	move.w	d2,d1
.no_new_right:
	addq	#4,a1
	dbf	d6,.loop	
; d0.w=left x, d1.w=right x

; decision making..
	sub.w	d0,d1
	cmpi.w	#32,d1
	blt.s	.slim
.fat:	lea	paint_flatfragment_fat(pc),a4
	rts
.slim:	lea	paint_flatfragment_slim(pc),a4
	rts

; input:
; a0: poly (#vertices, (x,y), (x,y) ...)
paint_flat_poly:
	move.w	(a0)+,d7

	;move.l	a0,a1
	;move.w	d7,d6
	;bsr.s	check_width

	;lea	rts(pc),a4

	lea	paint_flatfragment_fat(pc),a4

; INPUT:
; d4.l=color (optional)
; d7.w=#points
; a0: poly (without vertices header)
; a4: trapezoid paintrout
prest_paint_poly:
; Can you tell your head from your ass?
	bsr	prest_reorder

; if not anti-clockwise, you can make it..
; todo: do the test when required..
.anti_clockwise:
	lea	prest_left_table,a6
	lea	prest_right_table,a2
;	bra.s	.dir_done
;.clockwise:
;	lea	prest_left_table,a2
;	lea	prest_right_table,a6
;.dir_done:

	lea	Polygon.invTable,a5

	lea	prest_poly2(pc),a1
	movea.l	a6,a0
	move.w	prest_max(pc),d6
	bsr	prest_calc_left_points

	lea	prest_poly2(pc),a1
	movea.l	a2,a0
	move.w	prest_max(pc),d6
	bsr	prest_calc_right_points

; Now paint trapezoids..
; d4.l=color (optional)
; a4: trapezoid paintrout
; a6: left
; a2: right
	movem.w	prest_poly2(pc),d0-d1
	move.w	d1,d6				; d1.w=d6.w=top

; Set screenstart
;	movea.l	PrimitiveMesh.background,a3
	movea.l	Primitive.screenadr,a0
	move.w	d1,d2
	mulu.w	#160,d2
;	add.l	d2,d2
	adda.l	d2,a0
;	adda.l	d2,a3
	movea.w	#160,a5

; Head..
	cmp.w	(a6),d6
	beq	.horizontal_head_l
	cmp.w	(a2),d6
	beq.s	.horizontal_head_r
; Normal triangular head..
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	move.l	d0,d1				; d1.l=rx start (16:16)
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=r slope (16:16)

.loop:
; d6.w=y start
; a0: start of next screenline
	cmp.w	prest_max(pc),d6
	beq.s	.end
	move.w	(a6),d7
	cmp.w	(a2),d7
	bgt.s	.left_bigger
	blt.s	.right_bigger

; Both sides equal..
;  / \
; /   \
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_b
	jsr	(a4)
.skip_b:move.w	(a6)+,d6			; d6.w=y
	move.w	(a6)+,d0			; d0.w=lx start
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	move.w	2(a2),d1
	swap	d1
	move.w	d0,d1				; d1.l=rx start (16:16)
	addq	#4,a6				; a6: next left
	addq	#8,a2				; a2: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=r slope (16:16)
	bra.s	.loop

.right_bigger:
; Right bigger, proceed to next left..
; / \
;    \
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_r
	jsr	(a4)
.skip_r:move.w	(a6)+,d6
	move.w	(a6)+,d0
	swap	d0
	move.w	#$8000,d0			; d0.l=lx start (16:16)
	addq	#4,a6				; a6: next left
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	bra.s	.loop

.left_bigger:
; Left bigger, proceed to next right..
;  / \
; /
	move.w	(a2),d7
	sub.w	d6,d7
	subq.w	#1,d7				; d7.w=h-1
	bmi.s	.skip_l
	jsr	(a4)
.skip_l:move.w	(a2)+,d6
	move.w	(a2)+,d1
	swap	d1
	move.w	#$8000,d1			; d1.l=rx start (16:16)
	addq	#4,a2				; a2: next right
	move.l	4(a2),d3			; d3.l=r slope (16:16)
	bra.s	.loop

.end:	rts

; Special fucking cases..

;   o---r
;  /    :
; l
.horizontal_head_r:
	move.w	2(a2),d1
	swap	d1
	move.w	#$8000,d1			; d1.l=right x (16:16)
	swap	d0
	move.w	d1,d0				; d0.l=left x (16:16)
	addq	#8,a2				; a2: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

.horizontal_head_l:
	cmp.w	(a2),d1
	beq.s	.horizontal_head
; l---o
; :    \
;       r
	swap	d0
	move.w	#$8000,d0
	move.l	d0,d1				; d1.l=right x (16:16)
	move.w	2(a6),d0
	swap	d0
	move.w	d1,d0				; d0.l=left x (16:16)
	addq	#8,a6				; a6: next left
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

; l---o---r
; :       :
.horizontal_head:
	move.w	2(a6),d0
	swap	d0
	move.w	#$8000,d0			; d0.l=left x (16:16)
	move.w	2(a2),d1
	swap	d1
	move.w	d0,d1				; d1.l=right x (16:16)
	addq	#8,a6				; a6: next left
	addq	#8,a2				; a6: next right
	move.l	4(a6),d2			; d2.l=l slope (16:16)
	move.l	4(a2),d3			; d3.l=l slope (16:16)
	bra	.loop

; d7.w=pointcount >=3
; a0: point table count*(x.w,y.w)
prest_reorder:
; Find min y and max y.
	movea.l	a0,a1				; a1: backup src poly
	addq	#2,a0				; a0: y coords
	move.w	d7,d6
	move.w	d7,d1				; d1.w=count-index_min[0]
	move.w	d7,d3				; d3.w=count-index_max[0]
	subq.w	#1,d6
	moveq	#$FFFFFFFF,d0			; d0.w=min[0]
	moveq	#$00000000,d2			; d2.w=max[0]
.loop:	cmp.w	(a0),d0				; y[n]<min[n-1] ?
	blo.s	.try_max			; nope -> check next
	move.w	(a0),d0				; Set new min.
	move.w	d6,d1				; Set new minindex.
.try_max:
	cmp.w	(a0),d2
	bhi.s	.next
	move.w	(a0),d2				; Set new max.
	move.w	d6,d3				; Set new maxindex.
.next:	addq	#4,a0				; a0: next point
	dbf	d6,.loop
	move.w	d0,prest_min
	move.w	d2,prest_max

; Head up!
	lea	prest_poly2(pc),a0

; Rotate the point table using a barrel shift.
; The 
; a0: dst point table
; a1: src point table
; d1.w=count - split index
; d7.w=pointcount
	move.w	d7,d4
	subq.w	#1,d7				; d7.w=#points-1
	move.w	d7,d6
	sub.w	d1,d6				; d6.w=count-(count-split)=split

; todo: d6 should not exceed 16383!
	lsl.w	#2,d6
	lea	(a1,d6.w),a2			; a2: src tail
	lsr.w	#2,d6

	move.w	d1,d5				; d5.w=headsize
.headloop:
	move.l	(a2)+,(a0)+
	dbf	d5,.headloop

	subq.w	#1,d6
	bmi.s	.tail_done
.tailloop:
	move.l	(a1)+,(a0)+
	dbf	d6,.tailloop
.tail_done:

	move.w	d4,d7
	rts

; d6.w=btm
; a0: left table [(y.w,x.w,slope.l),(),...]
; a1: pointtable
; a5: invtable
prest_calc_left_points:
	clr.l	d2
	move.w	(a1)+,d1				; d0.w=y[0]
	move.w	(a1)+,d0				; d1.w=x[0]
.loop:
; a1: next point
	move.w	2(a1),d2				; d2.w=y[n]
	move.w	d2,(a0)+				; Store y.
	sub.w	d0,d2					; d2.w=dy
	move.w	(a1),d3					; d3.w=x[n]
	move.w	d3,(a0)+				; Store x.
	sub.w	d1,d3					; d1.w=dx

; todo: d2.w should not exceed 32767..
	add.l	d2,d2
	muls.w	(a5,d2.l),d3				; d3.l=dx<<16/dy

	add.l	d3,d3
	move.l	d3,(a0)+				; Store slope.
	move.w	(a1)+,d1				; d0.w=y[n]
	move.w	(a1)+,d0				; d1.w=x[n]
	cmp.w	d0,d6
	bne.s	.loop
.end:	rts

; d6.w=btm
; d7.w=#points
; a0: right table [(y.w,x.w,slope.l),(),...]
; a1: pointtable
; a5: invtable
prest_calc_right_points:
	clr.l	d2
	move.w	(a1)+,d1				; d0.w=y[0]
	move.w	(a1)+,d0				; d1.w=x[0]

	lsl.w	#2,d7
	lea	-8(a1,d7.w),a1
	lsr.w	#2,d7
.loop:
; a1: next point
	move.w	2(a1),d2				; d2.w=y[n]
	move.w	d2,(a0)+				; Store y.
	sub.w	d0,d2					; d2.w=dy
	move.w	(a1),d3					; d3.w=x[n]
	move.w	d3,(a0)+				; Store x.
	sub.w	d1,d3					; d1.w=dx

; todo: d2.w should not exceed 32767!
	add.l	d2,d2
	muls.w	(a5,d2.l),d3				; d3.l=dx<<16/dy

	add.l	d3,d3
	move.l	d3,(a0)+				; Store slope.
	move.w	(a1)+,d1				; d0.w=y[n]
	move.w	(a1)+,d0				; d1.w=x[n]
	subq	#8,a1
	cmp.w	d0,d6
	bne.s	.loop
.end:	rts

prest_max:
	ds.w	1
prest_min:
	ds.w	1
prest_poly2:
	ds.l	16
prest_left_table:
	ds.l	2*16
prest_right_table:
	ds.l	2*16

Polygon.invTable:
	DS.W	MAX_Y+1

Primitive.screenadr:
	ds.l	1


rts:	rts

;--------------------------------------------------------------------------

	ifne	0

; note: no more than 20 chunks (=320 pixels) in a row!
; input:
; d5.w=x0
; d6.w=x1
; a1: left_edge_table
hline1:	movea.l	a0,a6
	moveq	#$F,d4			; d4.w=$000F=mask
	move.w	d6,d7			; d7.w=x1
	and.w	d4,d7			; d7.w=x1&$F
	and.w	d5,d4			; d4.w=$F&x0=x0&$F
	sub.w	d4,d5			; d5.w=x0-(x0&$F)=x0&$FFF0=(x0>>4)<<4
	sub.w	d7,d6			; d6.w=x1-(x1&$F)=x1&$FFF0=(x0>>4)<<4
	sub.w	d5,d6			; d6.w=(x1>>4-x0>>4)<<4
	bne.s	.multi_chunk

.single_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	adda.w	d5,a6			; a6: first chunk
	add.w	d4,d4
	add.w	d7,d7
	move.w	(a1,d4.w),d5
	and.w	32(a1,d7.w),d5
	or.w	d5,(a6)
	rts

.multi_chunk:
	lsr.w	#1,d5			; d5.w=(x0>>4)<<3=offset to first chunk
	adda.w	d5,a6			; a6: first chunk

	ifne	1

	lsr.w	#2,d6			; d6.w=#num_chunks*4=4(x1>>4-x0>>4) (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#4,d6			; d6.w=chunks-1
.end_left_chunk:

	moveq	#$FFFFFFFF,d4
	neg.w	d6
	jmp	.jump_end(pc,d6.w)
	rept	20
	move.w	d4,(a6)
	addq	#8,a6
	endr
.jump_end:

	else

	lsr.w	#4,d6			; d6.w=#num_chunks=x1>>4-x0>>4 (right chunk excluded)

; leftmost chunk..
	add.w	d4,d4
	beq.s	.end_left_chunk
	move.w	(a1,d4.w),d4		; d4.w=mask
	or.w	d4,(a6)
	addq	#8,a6			; a6: next chunk
	subq.w	#1,d6			; d6.w=chunks-1
.end_left_chunk:

; body chunks..
	subq.w	#1,d6
	bmi.s	.end_body
	moveq	#$FFFFFFFF,d4
.loop:	move.w	d4,(a6)
	addq	#8,a6
	dbf	d6,.loop
.end_body:		

	endc

; rightmost chunk..
	add.w	d7,d7
	move.w	32(a1,d7.w),d5		; d5.w=mask
	or.w	d5,(a6)
.end_right_chunk:

	rts

	endc

; keep the tables toghether, please.
left_edge_table:
	dc.w	$FFFF,$7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF
	dc.w	$00FF,$007F,$003F,$001F,$000F,$0007,$0003,$0001
right_edge_table:
	dc.w	$0000,$8000,$C000,$E000,$F000,$F800,$FC00,$FE00
	dc.w	$FF00,$FF80,$FFC0,$FFE0,$FFF0,$FFF8,$FFFC,$FFFE

mixed_edge_table:
	dc.w	$FFFF,$0000,$7FFF,$8000,$3FFF,$C000,$1FFF,$E000
	dc.w	$0FFF,$F000,$07FF,$F800,$03FF,$FC00,$01FF,$FE00
	dc.w	$00FF,$FF00,$007F,$FF80,$003F,$FFC0,$001F,$FFE0
	dc.w	$000F,$FFF0,$0007,$FFF8,$0003,$FFFC,$0001,$FFFE

;--------------------------------------------------------------------------

	data

	ifne	0

test_poly:
	dc.w	4
	dc.w	22,47
	dc.w	59,10
	dc.w	12,08
	dc.w	10,40

old_test_poly:
	dc.w	3
	dc.w	19,10
	dc.w	5,20
	dc.w	27,40

	endc

.RAD:=	90

	ifne	1

	include tank-.s

	else

object:	dc.w	8
	dc.w	-.RAD,-.RAD,-.RAD
	dc.w	+.RAD,-.RAD,-.RAD
	dc.w	+.RAD,-.RAD,+.RAD
	dc.w	-.RAD,-.RAD,+.RAD
	dc.w	-.RAD,+.RAD,+.RAD
	dc.w	+.RAD,+.RAD,+.RAD
	dc.w	+.RAD,+.RAD,-.RAD
	dc.w	-.RAD,+.RAD,-.RAD

polys:	dc.w	6
	dc.w	2,4,7,6,1,0
	dc.w	0,4,6,5,2,1
	dc.w	1,4,0,1,2,3
	dc.w	2,4,5,4,3,2
	dc.w	1,4,4,5,6,7
	dc.w	0,4,0,3,4,7

lines:	dc.w	2
	dc.w	2,1,2
	dc.w	2,2,3

	endc

;--------------------------------------------------------------------------

	bss


Matrix.temp:
	ds.b	Matrix.SIZE

mul_table:
	ds.w	256*256

transformed_object:
	ds.w	1+MAX_VERTICES*3

Stm1.rot_on:
	ds.w	1
Stm1.rot_start:
	ds.w	1

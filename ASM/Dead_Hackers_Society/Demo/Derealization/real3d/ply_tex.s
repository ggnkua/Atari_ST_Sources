
	section	text

init_texmap:
	fpu_rnd_ceil

	rts

oldpolygon:	dc.l	0

dx_dz:		dc.s	0
dx_du:		dc.s	0
dx_dv:		dc.s	0
dy_dx_a:	dc.s	0
dy_dx_b:	dc.s	0
dy_du:		dc.s	0
dy_dv:		dc.s	0
scans_a:	dc.w	0
scans_b:	dc.w	0
dd:		dc.l	0  ;polygon area
clip_bits:	dc.l	0

poly1:		dc.l	fpolygon1
poly2:		dc.l	fpolygon2

;a0 polygon float x,y
;a1 screen
;d1 color
;d0 num vert (always 3)
;d1 type of polygon
;d2 texture or color

gizpoly:
	movem.l	d0-a6,-(sp)

	cmp.w	#POLY_NONE,d1
	beq	_nopoly

	move.w	d0,snumverts
	move.l	a0,oldpolygon
	move.l	a1,screen
	move.l	d2,a5		;texture, dont touch a5!!

	bsr	backface_poly
	ftst	fp4
	fbge	_nopoly
	fmove.s	fp4,dd

	clr.l	d6    	
; clip bits:  
; zmax | zmin | ymax | ymin | xmax | xmin

       	move.w	d0,d7
	subq.w	#1,d7
.ci:
    	fmove.s	VX(a0),fp0
    	fmove.s	VY(a0),fp1
    	fmove.s	VZ(a0),fp2
	fmove.l	fp0,d0
	fmove.l	fp1,d1
	fmove.l	fp2,d2

	add.l	d6,d6	
;	cmp.w	#iZMAX,d2
;	blt	.noizmax
;	addq.l	#1,d6
;.noizmax:
	add.l	d6,d6
	cmp.w	#iZMIN,d2
	bgt	.noizmin
	addq.l	#1,d6
.noizmin:	
	add.l	d6,d6

	cmp.w	#iYMAX,d1
	blt	.noiymax
	addq.l	#1,d6
.noiymax:	
	add.l	d6,d6
	cmp.w	#iYMIN,d1
	bgt	.noiymin
	addq.l	#1,d6
.noiymin:	
	add.l	d6,d6

	cmp.w	#iXMAX,d0
	blt	.noixmax
	addq.l	#1,d6
.noixmax:	
	add.l	d6,d6
	cmp.w	#iXMIN,d0
	bgt	.noixmin
	addq.l	#1,d6
.noixmin:
	add.l	#VERTSIZE,a0
	dbra	d7,.ci
	move.l	d6,clip_bits
	
	;now calc dx_du and dx_dv

	move.l	oldpolygon,a0

	;fp4=d,fp3=y2-y1,fp5=y3-y1 
	fmove.s	dd,fp4
	fmove.s VY+VERTSIZE(a0),fp3
	fsub.s	VY(a0),fp3
	fmove.s	VY+VERTSIZE*2(a0),fp5
	fsub.s	VY(a0),fp5

	fmove.s	#1.0,fp7
	fdiv	fp4,fp7		;1.0/d
	lea	VERTSIZE(a0),a1	;v2
	lea	VERTSIZE(a1),a2	;v3

;	fmove.s	VZ(a0),fp0	;z1
;	fmove.s	VZ(a1),fp1	;z2
;	fmove.s	VZ(a2),fp2	;z3
;	fsub	fp0,fp1		;z2-z1
;	fsub	fp0,fp2		;z3-z1
;	fmul	fp3,fp2		;we already got y2-y3 from backface calc
;	fmul	fp5,fp1
;	fsub	fp2,fp1
;	fmul	fp7,fp1		;dx_dz
;	fmove.s	fp1,dx_dz

	fmove.s	VU(a0),fp0	;u1
	fmove.s	VU(a1),fp1	;u2
	fmove.s	VU(a2),fp2	;u3
	fsub	fp0,fp1		;u2-u1
	fsub	fp0,fp2		;u3-u1
	fmul	fp3,fp2
	fmul	fp5,fp1
	fsub	fp1,fp2
	fmul	fp7,fp2		;dx_du
	fmove.s	fp2,dx_du

	fmove.s	VV(a0),fp0	;v1
	fmove.s	VV(a1),fp1	;v2
	fmove.s	VV(a2),fp2	;v3
	fsub	fp0,fp1		;v2-v1
	fsub	fp0,fp2		;v3-v1
	fmul	fp3,fp2
	fmul	fp5,fp1
	fsub	fp1,fp2
	fmul	fp7,fp2		;dx_dv
	fmove.s	fp2,dx_dv


	;now clip the polygon

	move.w	  #3,d0
	move.l	  oldpolygon,a0
	move.l	  clip_bits,d6
	tst.l	  d6	       	;polygon inside screen?
	beq	  _noclip

	move.l	  d6,d7
	and.l	  #%000001000001000001,d7
	cmp.l	  #%000001000001000001,d7
	beq	  _nopoly	;polygon above screen

	move.l	  d6,d7
	and.l	  #%000001000001000001<<1,d7
	cmp.l	  #%000001000001000001<<1,d7
	beq	  _nopoly	

	move.l	  d6,d7
	and.l	  #%000001000001000001<<2,d7
	cmp.l	  #%000001000001000001<<2,d7
	beq	  _nopoly	

	move.l	  d6,d7
	and.l	  #%000001000001000001<<3,d7
	cmp.l	  #%000001000001000001<<3,d7
	beq	  _nopoly	

	move.l	  d6,d7
	and.l	  #%000001000001000001<<4,d7
	cmp.l	  #%000001000001000001<<4,d7
	beq	  _nopoly	
	
;	move.l	  d6,d7
;	and.l	  #%000001000001000001<<5,d7
;	cmp.l	  #%000001000001000001<<5,d7
;	beq	  _nopoly	


	move.l	oldpolygon,a0
	move.l	poly2,a1

	bra	.nozmax
;	move.l	  clip_bits,d7
;	and.l	  #%100000100000100000,d7
;	beq	  .nozmax
;	bsr	clip_zmax
;	cmp.w	#3,d0
;	blt	_nopoly
;	move.l	poly1,a1
;	move.l	poly2,a0
;	move.l	a0,poly1
;	move.l	a1,poly2
.nozmax:

	move.l	  clip_bits,d7
	and.l	  #%10000010000010000,d7
	beq	  .nozmin	
	bsr	clip_zmin
	cmp.w	#3,d0
	blt	_nopoly
	move.l	poly1,a1
	move.l	poly2,a0
	move.l	a0,poly1
	move.l	a1,poly2
.nozmin:

	move.l	  clip_bits,d7
	and.l	  #%1000001000001000,d7
	beq	  .noymax
;	bra	  _nopoly
	bsr	  clip_ymax
	cmp.w	#3,d0
	blt	_nopoly
	move.l	poly1,a1
	move.l	poly2,a0
	move.l	a0,poly1
	move.l	a1,poly2
.noymax:

	move.l	  clip_bits,d7
	and.l	  #%100000100000100,d7
	beq	  .noymin
	bsr	clip_ymin
	cmp.w	#3,d0
	blt	_nopoly
	move.l	poly1,a1
	move.l	poly2,a0
	move.l	a0,poly1
	move.l	a1,poly2
.noymin:

	move.l	  clip_bits,d7
	and.l	  #%10000010000010,d7
	beq	  .noxmax
	bsr	clip_xmax
	cmp.w	#3,d0
	blt	_nopoly
	move.l	poly1,a1
	move.l	poly2,a0
	move.l	a0,poly1
	move.l	a1,poly2
.noxmax:
	move.l	  clip_bits,d7
	and.l	  #%1000001000001,d7
	beq	  .noxmin
	bsr	clip_xmin
	cmp.w	#3,d0
	blt	_nopoly
	move.l	poly1,a1
	move.l	poly2,a0
	move.l	a0,poly1
	move.l	a1,poly2
.noxmin:

;	move.l	clip_bits,d7
;	move.l	d7,d6
;	lsl.l	#1,d7
;	and.l	d6,d7
;	and.l	  #%10000010000010000,d7
;	bne	_nopoly
	
	move.w	d0,snumverts
_noclip:

	;now find top vertex

;	lea	fpolygon1,a0
	move.l	a0,a2
;	move.w	snumverts,d0
	move.w	d0,d2
	fmove.s	#256,fp3
	subq.w	#1,d2		;assume >0 !!
	move.w	d2,d4		;top index
_findymin:
;	addq.l	#4,a2		;skip x
	fmove.s	VY(a2),fp5
	fcmp	fp5,fp3
	fble	_noymin
	fmove	fp5,fp3
	move.l	d2,d4		;new index
_noymin:
	add.l	#VERTSIZE,a2
	dbra	d2,_findymin
	;fp3=ymin d4=indx of topvert

	move.w	d0,d2
	subq	#1,d2
	sub.w	d4,d2		;right order on index now, 0->numverts-1
	;d2=index to top

	fmove.l	fp3,d6
	mulu	#XSCR*scr_d,d6
	move.l	screen,a1
	add.l	d6,a1		;new base for screen
	;a1=screen adr

	move.w	d2,top_a
	move.w	d2,top_b
	clr.w	scans_a		;a
	clr.w	scans_b		;b

	;now fill the polygon

;	lea	texture+20+(256*128+128)*2,a5
	move.w	snumverts,d7
	subq	#2,d7
	move.w	d7,edgecnt
edgeloop:

	tst.w	scans_a		;is there any more scans on left edge?
	bgt	_noupdate_a	;if yes then dont update

	move.w	top_a,d5
	mulu	#VERTSIZE,d5
	fmove.s	VX(a0,d5.w),fp0	;x_a
	fmove.s	VY(a0,d5.w),fp7	;y0
	fmove.l	fp7,d6		;ceil(y0)
	fmove.s	VU(a0,d5.w),fp2	;u0
	fmove.s	VV(a0,d5.w),fp3	;v0

	move.w	top_a,d5
	subq.w	#1,d5
	bge.s	_q1
	move.w	snumverts,d5	;numvert-1
	subq.w	#1,d5
_q1:
	move.w	d5,top_a

	mulu	#VERTSIZE,d5
	fmove.s	VX(a0,d5.w),fp5	;x1
	fmove.s	VY(a0,d5.w),fp6	;y1
	fmove.w	fp6,scans_a	;ceil(y1)
	sub.w	d6,scans_a	;scans_a = ceil(y1)-ceil(y0)
	fsub	fp0,fp5		;x1-x_a
	fsub	fp7,fp6		;y1-y0
	fmove.s	#1.0,fp4
	fdiv	fp6,fp4
	fmul	fp4,fp5		;dy_dx_a

	fmove.s	fp5,dy_dx_a

	fsub.l	d6,fp7		;prestep = ceil(y0) - y0	
	fmul	fp7,fp5
	fsub	fp5,fp0		;x_a + prestep * dx1_dy1

	fmove.s	VU(a0,d5.w),fp5	;u1
	fsub	fp2,fp5		;u1-u0
	fmul	fp4,fp5
	fmove.s	fp5,dy_du
	fmul	fp7,fp5
	fsub	fp5,fp2		;subpixel

	fmove.s	VV(a0,d5.w),fp5
	fsub	fp3,fp5
	fmul	fp4,fp5
	fmove.s	fp5,dy_dv
	fmul	fp7,fp5
	fsub	fp5,fp3		;subpixel

_noupdate_a:

	tst.w	scans_b		;is there more scans to fill on right edge?
	bgt	_noupdate_b	;if yes then dont update

	move.w	top_b,d5
	mulu	#VERTSIZE,d5
	fmove.s	VX(a0,d5.w),fp1	;x_b
	fmove.s	VY(a0,d5.w),fp7	;y0
	fmove.l	fp7,d6

	move.w	top_b,d5
	addq.w	#1,d5
	cmp.w	snumverts,d5
	blt.s	_q2
	moveq	#0,d5
_q2:
	move.w	d5,top_b

	mulu	#VERTSIZE,d5
	fmove.s	VX(a0,d5.w),fp5	;x2
	fmove.s	VY(a0,d5.w),fp6	;y2
	fmove.w	fp6,scans_b	;ceil(y2)
	sub.w	d6,scans_b	;scans_b
	fsub	fp1,fp5		;x2-x_b
	fsub	fp7,fp6		;y2-y0
	fdiv	fp6,fp5		;dx2_dy2
	fmove.s	fp5,dy_dx_b

	fsub.l	d6,fp7
	fmul	fp7,fp5
	fsub	fp5,fp1		;x_b + prestep * dx2_dy2
_noupdate_b:

	;now interpolate edges

	move.w	 scans_b,d6
	cmp.w	scans_a,d6		;a>b, left or right edge longest?
	ble.s	_right_longest
_left_longest:
	move.w	scans_a,d6
_right_longest:
	sub.w	d6,scans_a
	sub.w	d6,scans_b
	subq.w	#1,d6		;y_lines
	blt	noedgeinterpol
	move.w	d6,edgeicnt

	;setup interpol consts outside loop
	fmove.s	dx_du,fp6
	fmove.s	dx_dv,fp7
	fmove.l	fp6,d2
	fmove.l	fp7,d3
	swap	d3
	ror.l	#8,d2
	move.w	d2,d4		;exg.w	d2,d3
	move.w	d3,d2
	move.w	d4,d3

edgeinterpol:
	fmove.l	fp0,d4		;x_a
	fmove.l	fp1,d5		;x_b

	lea	(a1,d4.l),a6	;adr to start of scanline
	;lea	(a1,d4.l*2),a6	;adr to start of scanline
	sub.l	d4,d5
	subq.w	#1,d5		;length of scanline
	blt	_nofill

	fmove	fp0,fp5
	fsub.l	d4,fp5		;-prestep
w03:
	fmove.s	dx_du,fp6
	fmove.s	dx_dv,fp7
;	fmove.l	fp6,d2
;	fmove.l	fp7,d3
w1:

	;sub texel
	fneg	fp5
	fmul	fp5,fp6
	fmul	fp5,fp7
	fadd	fp2,fp6
	fadd	fp3,fp7
	fmove.l	fp6,d6
	fmove.l	fp7,d7
w2:
	;setup 16:16 addx interpol
;	swap	d3
	swap	d7
	ror.l	#8,d6
;	ror.l	#8,d2
	move.w	d6,d4		;exg.w	d6,d7
	move.w	d7,d6
	move.w	d4,d7
;	move.w	d2,d4		;exg.w	d2,d3
;	move.w	d3,d2
;	move.w	d4,d3

	;preload addx flags...
	move.l	d3,d4
	clr.w	d4
	add.l	d4,d7
_xfill:
	move.w	d7,d4
	move.b	d6,d4
	move.b	(a5,d4.w),(a6)+
	;move.b	(a5,d4.w),d0
	;move.b	#-1,(a6)+
	addx.l	d2,d6
	addx.l	d3,d7
	dbra	d5,_xfill
_nofill:
	add.l	#XSCR*scr_d,a1		;next line
	fadd.s	dy_dx_a,fp0		;x_a+=dy_dx_a
	fadd.s	dy_dx_b,fp1		;x_b+=dy_dx_b
	fadd.s	dy_du,fp2
	fadd.s	dy_dv,fp3
	subq.w	#1,edgeicnt
	bge	edgeinterpol

;	movem.l	(sp)+,d0/d1
noedgeinterpol:

	subq.w	#1,edgecnt
	bge	edgeloop
_nopoly:
	movem.l	(sp)+,d0-a6
	rts

polyend:
top_a:		dc.w	0
top_b:		dc.w	0
edgecnt:	dc.w	0
edgeicnt:	dc.w	0

;	section		data

snumverts:		ds.w	1
screen:			ds.l	1

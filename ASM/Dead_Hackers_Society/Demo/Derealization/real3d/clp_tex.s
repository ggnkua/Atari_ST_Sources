
	section	text

XMIN:	dc.s	0
XMAX:	dc.s	320
YMIN:	dc.s	0
YMAX:	dc.s	180
;XMIN:	dc.s	50
;XMAX:	dc.s	270
;YMIN:	dc.s	50
;YMAX:	dc.s	190
ZMIN:	dc.s	10    ;0.1
ZMAX:	dc.s	100

iXMIN	=	0
iXMAX	=	320
iYMIN	=	0
iYMAX	=	180
iZMIN	=	0
iZMAX	=	100

clipstart:

get_visible_faces:
	lea	visible_faces,a0
	move.l	faces,a1
	move.w	NUMFACES,d7
	subq.w	#1,d7
.fl:
    	bsr	backface_poly    
	move.l	#0,(a0)+
	fmove.s	fp4,(a0)+
	dbra	d7,.fl
    	rts
	  


;in  polygon in a0
;out d0=1 if backface d0=0 otherwise
;    fp4 d
;    fp3 y2-y1
;    fp5 y3-y1
backface_poly:
	fmove.s	VX(a0),fp0	;x1
	fmove.s	VY(a0),fp1	;y1
	fmove.s	VX+VERTSIZE(a0),fp2	;x2
	fmove.s	VY+VERTSIZE(a0),fp3	;y2
	fmove.s	VX+VERTSIZE*2(a0),fp4	;x3
	fmove.s	VY+VERTSIZE*2(a0),fp5	;y3
	fsub	fp0,fp2		;x2-x1
	fsub	fp1,fp3		;y2-y1
	fsub	fp0,fp4		;x3-x1
	fsub	fp1,fp5		;y3-y1
	fmul	fp3,fp4
	fmul	fp5,fp2
	fsub	fp2,fp4
;	ftst	fp4
;	fble	.nopoly
;	moveq	#1,d0
	rts
;.nopoly:
;	moveq	#0,d0
;	rts


;clip_start:

; in  polygon in a0
;     numverts in d0
;     ptr to store clipped polygon in a1
; out polygon in a1
;     number of verts in d0

clip_xmax:
;	movem.l	d1-a6,-(sp)

	move.w	d0,clipverts
	mulu	#VERTSIZE,d0
	fmove.s	(a0),fp0	;x
	fmove.s	4(a0),fp1	;y
	fmove.s	8(a0),fp2
	fmove.s	fp0,0(a0,d0.l)
	fmove.s	fp1,4(a0,d0.l)
	fmove.s	fp2,8(a0,d0.l)
	move.l	12(a0),12(a0,d0.l)	;u
	move.l	16(a0),16(a0,d0.l)	;v

	clr.l	d0		;newvertex
	move.w	clipverts,d1	;numvertex
	subq.w	#1,d1
.xc:
	fmove.s	0(a0),fp0	;x1
	fmove.s	VERTSIZE(a0),fp1	;x2

	fcmp.s	XMAX,fp0	;if x1<=xmax
	fbge	.noxmin1

	fmove.s	fp0,0(a1)	;x
	fmove.s	4(a0),fp2
	fmove.s	fp2,4(a1)	;y
	fmove.s	8(a0),fp2
	fmove.s	fp2,8(a1)	;z
	move.l	12(a0),12(a1)	;u
	move.l	16(a0),16(a1)	;v

	addq	#1,d0		;
	add.l	#VERTSIZE,a1

	fcmp.s	XMAX,fp1	;x2>xmax
	fble	.noxmin3
.jox1:
	fmove.s	XMAX,fp2
	fsub	fp0,fp2		;xmax-x1
	fmove	fp1,fp3		;x2
	fsub	fp0,fp3		;x2-x1
	fdiv	fp3,fp2		;t = (xmax-x1)/(x2-x1)
	fmove.s	XMAX,fp7
	fmove.s	fp7,0(a1)	;new x
	fmove.s	4(a0),fp3	;y1
	fmove.s	4+VERTSIZE(a0),fp4	;y2
	fsub	fp3,fp4		;y2-y1
	fmul	fp2,fp4		;t*(y2-y1)
	fadd	fp4,fp3		;y1+t*(y2-y1)
	fmove.s	fp3,4(a1)	;new y

	fmove.s	12(a0),fp3		;x1
	fmove.s	12+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,12(a1)	;new y

	fmove.s	16(a0),fp3		;x1
	fmove.s	16+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,16(a1)	;new y


	addq	#1,d0
	add.l	#VERTSIZE,a1
	bra	.noxmin3
.noxmin1:
	fcmp.s	XMAX,fp1	;x2<=xmax
	fble	.jox1
.noxmin3:
	add.l	#VERTSIZE,a0
	dbra	d1,.xc

;	movem.l	(sp)+,d1-a6
	rts

clip_xmin:
;	movem.l	d1-a6,-(sp)

	move.w	d0,clipverts
	mulu	#VERTSIZE,d0
	fmove.s	(a0),fp0	;x
	fmove.s	4(a0),fp1	;y
	fmove.s	fp0,0(a0,d0.l)
	fmove.s	fp1,4(a0,d0.l)
	move.l	12(a0),12(a0,d0.l)	;u
	move.l	16(a0),16(a0,d0.l)	;v

	clr.l	d0		;newvertex
	move.w	clipverts,d1	;numvertex
	subq.w	#1,d1
.xc:
	fmove.s	0(a0),fp0	;x1
	fmove.s	VERTSIZE(a0),fp1	;x2

	fcmp.s	XMIN,fp0	;if x1<=xmax
	fblt	.noxmin1

	fmove.s	fp0,0(a1)	;x
	fmove.s	4(a0),fp2
	fmove.s	fp2,4(a1)	;y
	move.l	12(a0),12(a1)	;u
	move.l	16(a0),16(a1)	;v

	addq	#1,d0
	add.l	#VERTSIZE,a1

	fcmp.s	XMIN,fp1	;x2>xmax
	fbge	.noxmin3
.jox1:
	fmove.s	XMIN,fp2
	fsub	fp0,fp2		;xmax-x1
	fmove	fp1,fp3		;x2
	fsub	fp0,fp3		;x2-x1
	fdiv	fp3,fp2		;t = (xmax-x1)/(x2-x1)
	fmove.s	XMIN,fp7
	fmove.s	fp7,(a1)	;new x
	fmove.s	4(a0),fp3	;y1
	fmove.s	4+VERTSIZE(a0),fp4	;y2
	fsub	fp3,fp4		;y2-y1
	fmul	fp2,fp4		;t*(y2-y1)
	fadd	fp4,fp3		;y1+t*(y2-y1)
	fmove.s	fp3,4(a1)	;new y

	fmove.s	12(a0),fp3		;x1
	fmove.s	12+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,12(a1)	;new y

	fmove.s	16(a0),fp3		;x1
	fmove.s	16+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,16(a1)	;new y

	addq	#1,d0
	add.l	#VERTSIZE,a1
	bra	.noxmin3
.noxmin1:
	fcmp.s	XMIN,fp1	;x2<=xmax
	fbge	.jox1
.noxmin3:
	add.l	#VERTSIZE,a0
	dbra	d1,.xc

;	movem.l	(sp)+,d1-a6
	rts

clip_ymin:
;	movem.l	d1-a6,-(sp)

	move.w	d0,clipverts
	mulu	#VERTSIZE,d0
	fmove.s	(a0),fp0	;x
	fmove.s	4(a0),fp1	;y
	fmove.s	fp0,0(a0,d0.l)
	fmove.s	fp1,4(a0,d0.l)
	move.l	12(a0),12(a0,d0.l)	;u
	move.l	16(a0),16(a0,d0.l)	;v

	clr.l	d0		;newvertex
	move.w	clipverts,d1	;numvertex
	subq.w	#1,d1
.xc:
	fmove.s	4+0(a0),fp0	;y1
	fmove.s	4+VERTSIZE(a0),fp1	;y2

	fcmp.s	YMIN,fp0	;if y1<=ymax
	fblt	.noxmin1

	;fmove.s	fp0,(a1)+	;x
	fmove.s	0(a0),fp2
	fmove.s	fp2,(a1)	;y
	fmove.s	fp0,4(a1)
	move.l	12(a0),12(a1)	;u
	move.l	16(a0),16(a1)	;v

	addq	#1,d0		;
	add.l	#VERTSIZE,a1

	fcmp.s	YMIN,fp1	;y2>ymax
	fbge	.noxmin3
.jox1:
	fmove.s	YMIN,fp2
	fsub	fp0,fp2		;xmax-x1
	fmove	fp1,fp3		;x2
	fsub	fp0,fp3		;x2-x1
	fdiv	fp3,fp2		;t = (xmax-x1)/(x2-x1)
	fmove.s	YMIN,fp7
;	fmove.s	fp7,(a1)+	;new x
	fmove.s	0(a0),fp3	;y1
	fmove.s	0+VERTSIZE(a0),fp4	;y2
	fsub	fp3,fp4		;y2-y1
	fmul	fp2,fp4		;t*(y2-y1)
	fadd	fp4,fp3		;y1+t*(y2-y1)
	fmove.s	fp3,0(a1)	;new x
	fmove.s	fp7,4(a1)	;new y

	fmove.s	12(a0),fp3		;x1
	fmove.s	12+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,12(a1)	;new y

	fmove.s	16(a0),fp3		;x1
	fmove.s	16+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,16(a1)	;new y

	addq	#1,d0
	add.l	#VERTSIZE,a1
	bra	.noxmin3
.noxmin1:
	fcmp.s	YMIN,fp1	;x2<=xmax
	fbge	.jox1
.noxmin3:
	add.l	#VERTSIZE,a0
	dbra	d1,.xc

;	movem.l	(sp)+,d1-a6
	rts

clip_ymax:
;	movem.l	d1-a6,-(sp)

	move.w	d0,clipverts
	mulu	#VERTSIZE,d0
	fmove.s	(a0),fp0	;x
	fmove.s	4(a0),fp1	;y
	fmove.s	fp0,0(a0,d0.l)
	fmove.s	fp1,4(a0,d0.l)
	move.l	12(a0),12(a0,d0.l)	;u
	move.l	16(a0),16(a0,d0.l)	;v

	clr.l	d0		;newvertex
	move.w	clipverts,d1	;numvertex
	subq.w	#1,d1
.xc:
	fmove.s	4+0(a0),fp0	;y1
	fmove.s	4+VERTSIZE(a0),fp1	;y2

	fcmp.s	YMAX,fp0	;if y1<=ymax
	fbgt	.noxmin1

	;fmove.s	fp0,(a1)+	;x
	fmove.s	0(a0),fp2
	fmove.s	fp2,0(a1)	;y
	fmove.s	fp0,4(a1)
	move.l	12(a0),12(a1)	;u
	move.l	16(a0),16(a1)	;v

	addq	#1,d0		;
	add.l	#VERTSIZE,a1

	fcmp.s	YMAX,fp1	;y2>ymax
	fble	.noxmin3
.jox1:
	fmove.s	YMAX,fp2
	fsub	fp0,fp2		;xmax-x1
	fmove	fp1,fp3		;x2
	fsub	fp0,fp3		;x2-x1
	fdiv	fp3,fp2		;t = (xmax-x1)/(x2-x1)
	fmove.s	YMAX,fp7
;	fmove.s	fp7,(a1)+	;new x
	fmove.s	0(a0),fp3	;y1
	fmove.s	0+VERTSIZE(a0),fp4	;y2
	fsub	fp3,fp4		;y2-y1
	fmul	fp2,fp4		;t*(y2-y1)
	fadd	fp4,fp3		;y1+t*(y2-y1)
	fmove.s	fp3,0(a1)	;new x
	fmove.s	fp7,4(a1)	;new y

	fmove.s	12(a0),fp3		;x1
	fmove.s	12+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,12(a1)	;new y

	fmove.s	16(a0),fp3		;x1
	fmove.s	16+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,16(a1)	;new y

	addq	#1,d0
	add.l	#VERTSIZE,a1
	bra	.noxmin3
.noxmin1:
	fcmp.s	YMAX,fp1	;x2<=xmax
	fble	.jox1
.noxmin3:
	add.l	#VERTSIZE,a0
	dbra	d1,.xc

;	movem.l	(sp)+,d1-a6
	rts

clip_zmax:
;	movem.l	d1-a6,-(sp)

	move.w	d0,clipverts
	mulu	#VERTSIZE,d0
	fmove.s	(a0),fp0	;x
	fmove.s	4(a0),fp1	;y
	fmove.s	8(a0),fp2	;z
	fmove.s	fp0,0(a0,d0.l)
	fmove.s	fp1,4(a0,d0.l)
	fmove.s	fp2,8(a0,d0.l)
	move.l	12(a0),12(a0,d0.l)	;u
	move.l	16(a0),16(a0,d0.l)	;v

	clr.l	d0		;newvertex
	move.w	clipverts,d1	;numvertex
	subq.w	#1,d1
.xc:
	fmove.s	8+0(a0),fp0		;z1
	fmove.s	8+VERTSIZE(a0),fp1	;z2

	fcmp.s	ZMAX,fp0	;if y1<=ymax
	fbgt	.noxmin1

	fmove.s	0(a0),fp2
	fmove.s	fp2,0(a1)	;x
	fmove.s	4(a0),fp2
	fmove.s	fp2,4(a1)	;y
	fmove.s	fp0,8(a1)	;z
	move.l	12(a0),12(a1)	;u
	move.l	16(a0),16(a1)	;v

	addq	#1,d0		;
	add.l	#VERTSIZE,a1

	fcmp.s	ZMAX,fp1	;y2>ymax
	fble	.noxmin3
.jox1:
	fmove.s	ZMAX,fp2
	fsub	fp0,fp2		;zmax-z1
	fmove	fp1,fp3		;z2
	fsub	fp0,fp3		;z2-z1
	fdiv	fp3,fp2		;t = (zmax-z1)/(z2-z1)
	fmove.s	ZMAX,fp7

	fmove.s	0(a0),fp3		;x1
	fmove.s	0+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,0(a1)	;new x

	fmove.s	4(a0),fp3		;x1
	fmove.s	4+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,4(a1)	;new y

	fmove.s	fp7,8(a1)	;new z

	fmove.s	12(a0),fp3		;x1
	fmove.s	12+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,12(a1)	;new y

	fmove.s	16(a0),fp3		;x1
	fmove.s	16+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,16(a1)	;new y


	addq	#1,d0
	add.l	#VERTSIZE,a1
	bra	.noxmin3
.noxmin1:
	fcmp.s	ZMAX,fp1	;x2<=xmax
	fble	.jox1
.noxmin3:
	add.l	#VERTSIZE,a0
	dbra	d1,.xc

;	movem.l	(sp)+,d1-a6
	rts

clip_zmin:
;	movem.l	d1-a6,-(sp)

	move.w	d0,clipverts
	mulu	#VERTSIZE,d0
	fmove.s	(a0),fp0	;x
	fmove.s	4(a0),fp1	;y
	fmove.s	8(a0),fp2	;z
	fmove.s	fp0,0(a0,d0.l)
	fmove.s	fp1,4(a0,d0.l)
	fmove.s	fp2,8(a0,d0.l)
	move.l	12(a0),12(a0,d0.l)	;u
	move.l	16(a0),16(a0,d0.l)	;v

	clr.l	d0		;newvertex
	move.w	clipverts,d1	;numvertex
	subq.w	#1,d1
.xc:
	fmove.s	8+0(a0),fp0		;z1
	fmove.s	8+VERTSIZE(a0),fp1	;z2

	fcmp.s	ZMIN,fp0	;if y1<=ymax
	fble	.noxmin1

	fmove.s	0(a0),fp2
	fmove.s	fp2,0(a1)	;x
	fmove.s	4(a0),fp2
	fmove.s	fp2,4(a1)	;y
	fmove.s	fp0,8(a1)	;z
	move.l	12(a0),12(a1)	;u
	move.l	16(a0),16(a1)	;v

	addq	#1,d0		;
	add.l	#VERTSIZE,a1

	fcmp.s	ZMIN,fp1	;y2>ymax
	fbge	.noxmin3
.jox1:
	fmove.s	ZMIN,fp2
	fsub	fp0,fp2		;zmax-z1
	fmove	fp1,fp3		;z2
	fsub	fp0,fp3		;z2-z1
	fdiv	fp3,fp2		;t = (zmax-z1)/(z2-z1)
	fmove.s	ZMIN,fp7

	fmove.s	0(a0),fp3		;x1
	fmove.s	0+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,0(a1)	;new x

	fmove.s	4(a0),fp3		;x1
	fmove.s	4+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,4(a1)	;new y

	fmove.s	fp7,8(a1)	;new z

	fmove.s	12(a0),fp3		;x1
	fmove.s	12+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,12(a1)	;new y

	fmove.s	16(a0),fp3		;x1
	fmove.s	16+VERTSIZE(a0),fp4	;x2
	fsub	fp3,fp4		;x2-x1
	fmul	fp2,fp4		;t*(x2-x1)
	fadd	fp4,fp3		;x1+t*(x2-x1)
	fmove.s	fp3,16(a1)	;new y

	addq	#1,d0
	add.l	#VERTSIZE,a1
	bra	.noxmin3
.noxmin1:
	fcmp.s	ZMIN,fp1	;x2<=xmax
	fbge	.jox1
.noxmin3:
	add.l	#VERTSIZE,a0
	dbra	d1,.xc

;	movem.l	(sp)+,d1-a6
	rts

clip_end:

	section	bss

clipverts:	ds.w	1


;visible suface struct:
; 4byte clip info
; 4byte float value of polygon area
;
visible_faces:	ds.l	10000*(1+1)


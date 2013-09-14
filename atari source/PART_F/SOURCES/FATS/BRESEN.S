*************************************************
*						*
*  Bresenham's line draw algorithm		*
*  and Line A text stuff			*
*						*
*   last update: 28 Jan 86			*
*						*
*************************************************
*
*
*
	.include	"fatequ.s"
*
*
*  Public entry point..
*
	.globl	_ACT_SIZ
	.globl	linedraw,lineundo,textset,graftxt
	.globl	systxt6,systxt6i,systxt6t,systxt8
	.globl	screen0,full,handy
	.globl	_scrtchp
*
*
*  Public variables..
*
	.globl	txtbastp,rampcoll,rampcolr,brshbrez,brshptr
*
*  externally defined variables used here
*
	.globl	curscren,othscren
	.globl	colleft,colrite
	.globl	vdicall,box,cbarx,cbary,contrl,intin,ptsin
	.globl	textsize,textstyl,textalin
	.globl	drawq,invdrawq,txtcelht,half,selctcol
	.globl	scaleft,scalrite
*
*
	.globl	fillbox,unlineht,unlinetk
*
*
*  Textblt lineA offsets
*
	.globl	wrt_mode
	.globl	v_planes,v_lin_wr,clip,xmn_clip,ymn_clip,xmx_clip,ymx_clip
	.globl	xacc_dda,dda_inc,t_sclsts,mono_st,sourcex,sourcey
	.globl	destx,desty,delx,dely,fbase,fwidth,style,litemask,skewmask
	.globl	weight,r_off,l_off,scale,chup,text_fg,scrtchp,scrpt2,text_bg
	.globl	textblt,faceid,points,fontname,first_ad,last_ad,topline
	.globl	ascent,halfline,descent,botline,charwid,celwid,leftoff,riteoff
	.globl	thicken,undline,litemsk,skewmsk,fflags
	.globl	offsetp,fontdata,formwid,formhite,nextfont
*
	.globl	p_block,plane_ct,fg_col,bg_col,d_xmin,d_ymin
	.globl	bitblt,b_width,b_height
*
*
*
*
*  Local copy textblt globals..
*
	.globl	_TEXT_BL
	.globl	_v_planes,_v_lin_wr,_WRT_MOD,_CLIP,_XMN_CLI
	.globl	_YMN_CLI,_XMX_CLI,_YMX_CLI,_XACC_DD,_DDA_INC
	.globl	_T_SCLST,_MONO_ST,_SOURCEX,_SOURCEY,_DESTX,_DESTY
	.globl	_DELX,_DELY,_FBASE,_FWIDTH,_STYLE,_LITEMAS,_SKEWMAS
	.globl	_WEIGHT,_R_OFF,_L_OFF,_CHUP,_TEXT_FG,_scrtchp,_scrpt2,_TEXT_BG
	.globl	_v_bas_a
	.globl	_DOUBLE
*
*
*  Bresenham line draw routine
*
*
*  d0.w - x1		origin
*  d1.w - y1
*
*  d2.w - x2		destination
*  d3.w - y2
*
	.if	0
*
linedraw:
	bra.s	brshbrz8
*
	move.w	rampcolr,d7	;rightmost color
	move.w	rampcoll,d5	;leftmost color
*
	sub.w	d5,d7
	addq.w	#1,d7		;# of colors
	movea.w	d5,a3
*
	moveq	#0,d4		;reset bit 31 for increment x (if x is longest)
	moveq	#0,d5		;same for y (in case y is longest)
	move.l	#$8000FFFF,d6	;temp use for word 2's compliment & bit 31 set
*
	move.w	d2,d4		;copy x2 to find delta x
	sub.w	d0,d4		;d4 = signed delta x
	bcc.s	orgleft		;br if positive
	eor.l	d6,d4		;1's compliment of word & set bit 31
	addq.w	#1,d4		;d4.w = positive delta x
orgleft:
	move.w	d1,d5		;do same for y
	sub.w	d3,d5		;form signed delta y
	bcc.s	orgdwn
	eor.l	d6,d5
	addq.w	#1,d5		;d5.w = positive delta y, bit 31 set if was neg
orgdwn:
	cmp.w	d5,d4		;which delta larger, x or y?
	bcc.s	xbigr		;br if x is larger
ybigr:
*
*  y is largest, always increment y, selectively increment x
*
*
	move.w	d5,d6		;copy # of pixels to temp
	addq.w	#1,d6
	ext.l	d6
	divu	d7,d6		;divide by # of colors to get # pixels/color
	move.w	d6,colcnt
	move.w	d6,colcntc
	swap	d6
	subq.w	#1,d6
	move.w	d6,colrem
	bmi.s	colcok1
	addq.w	#1,colcntc
colcok1:
	move.w	d4,d6		;dx
	lsl.w	#1,d6		;2 * dx
	sub.w	d5,d6		;d6 = (2 * dx) - dy = d
*
	move.w	d4,d7		;dx
	sub.w	d5,d7		;dx - dy
	lsl.w	#1,d7		;d7 = 2 * (dx - dy) = incr2
*
	moveq	#-1,d3		;assume y increment (move up)
	tst.l	d5		;y1 or y2 top-most
	bpl.s	y1dwn		;br if y2 is top-most (increment assumption ok)
	moveq	#1,d3		;else, decrement y to move down
y1dwn:
	moveq	#-1,d2		;assume x decrement (move right)
	lsl.l	#1,d4		;d4 = 2 * dx = incr1 (bit 31 to cy)
	bcs.s	x1left1		;br if x1 left of x2
	moveq	#1,d2		;else, increment x to move left
x1left1:
	bra.s	yloopi		;enter loop at pixel plot
yloop:
	add.w	d3,d1		;advance y
	tst.w	d6		;d negative?
	bmi.s	incr1ad
	add.w	d7,d6
	add.w	d2,d0		;advance x
	bra.s	yloopi
incr1ad:
	add.w	d4,d6
yloopi:
	bsr	plotxy
	dbra	d5,yloop
	rts
*
*  x is largest, always increment x, selectively increment y
*
xbigr:
	move.w	d4,d6		;copy # of pixels to temp
	addq.w	#1,d6
	ext.l	d6
	divu	d7,d6		;divide by # of colors to get # pixels/color
	move.w	d6,colcnt
	move.w	d6,colcntc
	swap	d6
	subq.w	#1,d6
	move.w	d6,colrem
	bmi.s	colcok
	addq.w	#1,colcntc
colcok:
*
	move.w	d5,d6		;dy
	lsl.w	#1,d6		;2 * dy
	sub.w	d4,d6		;d6 = (2 * dy) - dx = d
*
	move.w	d5,d7		;dy
	sub.w	d4,d7		;dy - dx
	lsl.w	#1,d7		;d7 = 2 * (dy - dx) = incr2
*
	moveq	#1,d2		;assume x increment (move to right)
	tst.l	d4		;x1 or x2 leftmost
	bpl.s	x1left		;br if x1 is leftmost
	moveq	#-1,d2		;else, decrement x to move left
x1left:
	moveq	#1,d3		;assume y increment (move up)
	lsl.l	#1,d5		;d5 = 2 * dy = incr1 (bit 31 to cy)
	bcs.s	y1bot		;br if y1 below y2
	moveq	#-1,d3		;else, decrement y to move down
y1bot:
	bra.s	xloopi		;enter loop at pixel plot
xloop:
	add.w	d2,d0		;advance x
	tst.w	d6		;d negative?
	bmi.s	incr1add
	add.w	d7,d6
	add.w	d3,d1		;advance y
	bra.s	xloopi
incr1add:
	add.w	d5,d6
xloopi:
	bsr	plotxy
	dbra	d4,xloop
	rts
*
*
*  Plot pixel at x & y given in d0.w & d1.w respectively
*
plotxy:
	movem.l	a4/d0-d7,-(sp)
	move.l	curscren,a4
	mulu	#160,d1
*
	move.w	d0,d3
	moveq	#0,d2
	not.w	d3
	andi.w	#$f,d3
	bset.l	d3,d2
	move.w	d2,d3
	not.w	d3
*
	lsr.w	#1,d0
	andi.w	#$FFF8,d0
	add.w	d0,d1
	adda.w	d1,a4
*
	subq.w	#1,colcntc
	bpl.s	mocol
	move.w	colcnt,colcntc
	subq.w	#1,colrem
	bpl.s	mocol1
	subq.w	#1,colcntc
mocol1:
	addq.l	#1,a3
mocol:
	move.l	a3,d0
*
	move.w	#3,d1
plotlp:
	lsr.w	d0
	bcc.s	andit
	or.w	d2,(a4)+
	dbra	d1,plotlp
	bra.s	ploti
andit:
	and.w	d3,(a4)+
	dbra	d1,plotlp
ploti:
	movem.l	(sp)+,a4/d0-d7
	rts
*
	.endif
*
*
*
lineundo:
tempundo:
	movem.l	a4-a5/d0-d1,-(sp)
	move.l	othscren,a4
	move.l	screen0,a5
	move.w	#1999,d0
	tst.w	full
	bne.s	tmpu1
	move.w	handy,d1
	mulu	#160,d1
	add.l	d1,a5
	move.w	#999,d0
tmpu1:
	move.l	(a5)+,(a4)+
	move.l	(a5)+,(a4)+
	move.l	(a5)+,(a4)+
	move.l	(a5)+,(a4)+
	dbra	d0,tmpu1
	movem.l	(sp)+,a4-a5/d0-d1
	rts
*
*
*  Bresenham line undo routine
*
*  quick copy of screen0 to othscren/curscren to undo line drawn by linedraw
*
*
*  d0.w - x1		origin
*  d1.w - y1
*
*  d2.w - x2		destination
*  d3.w - y2
*
*  a5-> destination screen base
*
	.if	0
lineundo:
	bra.s	tempundo
	movem.l	a4-a5/d0-d7,-(sp)
	move.l	screen0,a4
	tst.w	full
	bne.s	lundo1
	move.w	handy,d4
	mulu	#160,d4
	adda.w	d4,a4
lundo1:
	move.w	d0,d5
	lsr.w	#1,d5
	andi.w	#$FFF8,d5
	move.w	d1,d4
	mulu	#160,d4
	add.w	d5,d4
	adda.w	d4,a4
	adda.w	d4,a5
*
	moveq	#0,d4		;reset bit 31 for increment x (if x is longest)
	moveq	#0,d5		;same for y (in case y is longest)
	move.l	#$8000FFFF,d6	;temp use for word 2's compliment & bit 31 set
*
	move.w	d2,d4		;copy x2 to find delta x
	sub.w	d0,d4		;d4 = signed delta x
	bcc.s	orgleft1		;br if positive
	eor.l	d6,d4		;1's compliment of word & set bit 31
	addq.w	#1,d4		;d4.w = positive delta x
orgleft1:
*
*  finished using d0, calculate dot position in word
*
	moveq	#0,d7
	not.w	d0
	andi.w	#$F,d0
	bset.l	d0,d7
	move.w	d7,d0		;bit mask for origin pixel
*
	move.w	d1,d5		;do same for y
	sub.w	d3,d5		;form signed delta y
	bcc.s	orgdwn1
	eor.l	d6,d5
	addq.w	#1,d5		;d5.w = positive delta y, bit 31 set if was neg
orgdwn1:
	cmp.w	d5,d4		;which delta larger, x or y?
	bcc.s	xbigr1		;br if x is larger
ybigr1:
*
*  y is largest, always increment y, selectively increment x
*
	move.w	d4,d6		;dx
	lsl.w	#1,d6		;2 * dx
	sub.w	d5,d6		;d6 = (2 * dx) - dy = d
*
	move.w	d4,d7		;dx
	sub.w	d5,d7		;dx - dy
	lsl.w	#1,d7		;d7 = 2 * (dx - dy) = incr2
*
	move.w	#-168,d3	;assume y increment (move up)
	tst.l	d5		;y1 or y2 top-most
	bpl.s	y1dwn1		;br if y2 is top-most (increment assumption ok)
	move.w	#152,d3		;else, decrement y to move down
y1dwn1:
	move.w	#-16,d2		;assume x decrement (move right)
	lsl.l	#1,d4		;d4 = 2 * dx = incr1 (bit 31 to cy)
	bcs.s	x1left2		;br if x1 left of x2
	moveq	#0,d2		;else, increment x to move left
x1left2:
	bra.s	yloopi1		;enter loop at pixel plot
yloop1:
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	adda.w	d3,a4
	adda.w	d3,a5
*
*	add.w	d3,d1		;advance y
*
	tst.w	d6		;d negative?
	bmi.s	incr1ad1
	add.w	d7,d6
*
	tst.w	d2
	bmi.s	xmovlef
	ror.w	d0
	bcc.s	xmovdon
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	bra.s	xmovdon	
xmovlef:
	rol.w	d0
	bcc.s	xmovdon
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	adda.w	d2,a4
	adda.w	d2,a5
xmovdon:
*	add.w	d2,d0		;advance x
	bra.s	yloopi1
incr1ad1:
	add.w	d4,d6
yloopi1:
	dbra	d5,yloop1
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	movem.l	(sp)+,a4-a5/d0-d7
	rts
*
*  x is largest, always increment x, selectively increment y
*
xbigr1:
	move.w	d5,d6		;dy
	lsl.w	#1,d6		;2 * dy
	sub.w	d4,d6		;d6 = (2 * dy) - dx = d
*
	move.w	d5,d7		;dy
	sub.w	d4,d7		;dy - dx
	lsl.w	#1,d7		;d7 = 2 * (dy - dx) = incr2
*
	moveq	#0,d2		;assume x increment (move to right)
	tst.l	d4		;x1 or x2 leftmost
	bpl.s	x1left3		;br if x1 is leftmost
	move.w	#-16,d2		;else, decrement x to move left
x1left3:
	move.w	#152,d3		;assume y increment (move up)
	lsl.l	#1,d5		;d5 = 2 * dy = incr1 (bit 31 to cy)
	bcs.s	y1bot1		;br if y1 below y2
	move.w	#-168,d3	;else, decrement y to move down
y1bot1:
	bra.s	xloopi1		;enter loop at pixel plot
xloop1:
*
*	add.w	d2,d0		;advance x
*
	tst.w	d2
	bmi.s	xmovlef1
	ror.w	d0
	bcc.s	xmovdon1
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	bra.s	xmovdon1
xmovlef1:
	rol.w	d0
	bcc.s	xmovdon1
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	adda.w	d2,a4
	adda.w	d2,a5	
xmovdon1:
	tst.w	d6		;d negative?
	bmi.s	incr2add
	add.w	d7,d6
*
*	add.w	d3,d1		;advance y
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	adda.w	d3,a4
	adda.w	d3,a5	
*
	bra.s	xloopi1
incr2add:
	add.w	d5,d6
xloopi1:
	dbra	d4,xloop1
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	movem.l	(sp)+,a4-a5/d0-d7
	rts
*
*
	.endif
	nop
*
*  Bresenham brush draw routine
*
*
*  d0.w - x1		destination
*  d1.w - y1
*
*
*  d3.w - x2		origin
*  d4.w - y2
*
*
brshbrez:
	movem.l	a2-a5/d0-d7,-(sp)
	movea.l	curscren,a3
	movea.l	a3,a4
	movea.l	a3,a2
	movea.l	brshptr,a5
	move.w	d3,d2
	move.w	d4,d3
	exg	d0,d2
	exg	d1,d3
*
	move.w	(a5)+,d5	;get brush width
	lsr.w	d5
	sub.w	d5,d0
	sub.w	d5,d2
	move.w	(a5),d5		;get brush heigh
	lsr.w	d5
	sub.w	d5,d1
	sub.w	d5,d3
*
	move.w	d1,d4
	muls	#160,d4
	move.w	d0,d5
	bpl.s	bbrez1a
	addi.w	#16,d5
	subq.w	#8,d4
bbrez1a:
	lsr.w	#1,d5
	andi.w	#$FFF8,d5
	add.w	d5,d4
	adda.w	d4,a4		;1st plane address for start pixel
	move.w	half,d4
	mulu	#160,d4
	adda.w	d4,a2		;bottom clip address
*
	moveq	#0,d4		;reset bit 31 for increment x (if x is longest)
	moveq	#0,d5		;same for y (in case y is longest)
	move.l	#$8000FFFF,d6	;temp use for word 2's compliment & bit 31 set
*
	move.w	d2,d4		;copy x2 to find delta x
	sub.w	d0,d4		;d4 = signed delta x
	bpl.s	bbrez1		;br if positive
	eor.l	d6,d4		;1's compliment of word & set bit 31
	addq.w	#1,d4		;d4.w = positive delta x
bbrez1:
	move.w	d1,d5		;do same for y
	sub.w	d3,d5		;form signed delta y
	bpl.s	bbrez2
	eor.l	d6,d5
	addq.w	#1,d5		;d5.w = positive delta y, bit 31 set if was neg
bbrez2:
	move.w	d0,d1		;save for clipping
	andi.w	#$F,d1		;finished using d1 as xpos, now its lsr.l count
*
	cmp.w	d5,d4		;which delta larger, x or y?
	bcc.s	bbrez10		;br if x is larger
bbrez3:
*
*  y is largest, always increment y, selectively increment x
*
	move.w	d4,d6		;dx
	lsl.w	#1,d6		;2 * dx
	sub.w	d5,d6		;d6 = (2 * dx) - dy = d
*
	move.w	d4,d7		;dx
	sub.w	d5,d7		;dx - dy
	lsl.w	#1,d7		;d7 = 2 * (dx - dy) = incr2
*
	move.w	#-160,d3	;assume y decrement (move up)
	tst.l	d5		;y1 or y2 top-most
	bpl.s	bbrez5		;br if y2 is top-most (increment assumption ok)
	move.w	#160,d3		;else, increment y to move down
bbrez5:
	moveq	#-1,d2		;assume x decrement (move right)
	lsl.l	#1,d4		;d4 = 2 * dx = incr1 (bit 31 to cy)
	bcs.s	bbrez6		;br if x1 left of x2
	moveq	#1,d2		;else, increment x to move left
bbrez6:
	bsr	brshblit	;plot start point
	bra.s	bbrez9		;enter loop at pixel plot
bbrez7:
	adda.w	d3,a4		;advance y
*
*	add.w	d3,d1		;advance y
*
	bsr	brshblit	;plot this change
	tst.w	d6		;d negative?
	bmi.s	bbrez8
	add.w	d7,d6
*
*	add.w	d2,d0		;advance x
*
	add.w	d2,d0
	add.w	d2,d1
	bmi.s	bbrez8a
	beq.s	bbrez8b
	andi.w	#$F,d1
	bne.s	bbrez8b
	addq.l	#8,a4		;need to
	bra.s	bbrez8b
bbrez8a:
	andi.w	#$F,d1
	subq.l	#8,a4
bbrez8b:
	bsr	brshblit	;plot x change
	bra.s	bbrez9
bbrez8:
	add.w	d4,d6
bbrez9:
	dbra	d5,bbrez7
	movem.l	(sp)+,a2-a5/d0-d7
	rts
*
*  x is largest, always increment x, selectively increment y
*
bbrez10:
	move.w	d5,d6		;dy
	lsl.w	#1,d6		;2 * dy
	sub.w	d4,d6		;d6 = (2 * dy) - dx = d
*
	move.w	d5,d7		;dy
	sub.w	d4,d7		;dy - dx
	lsl.w	#1,d7		;d7 = 2 * (dy - dx) = incr2
*
	moveq	#1,d2		;assume x increment (move to right)
	tst.l	d4		;x1 or x2 leftmost
	bpl.s	bbrez12		;br if x1 is leftmost
	moveq	#-1,d2		;else, decrement x to move left
bbrez12:
	move.w	#160,d3		;assume y increment (move up)
	lsl.l	#1,d5		;d5 = 2 * dy = incr1 (bit 31 to cy)
	bcs.s	bbrez13		;br if y1 below y2
	move.w	#-160,d3	;else, decrement y to move down
bbrez13:
	bsr.s	brshblit
	bra.s	bbrez16		;enter loop at pixel plot
bbrez14:
*
*	add.w	d2,d0		;advance x
*
	add.w	d2,d0
	add.w	d2,d1
	bmi.s	bbrez15a
	beq.s	bbrez15b
	andi.w	#$F,d1
	bne.s	bbrez15b
	addq.l	#8,a4		;need to
	bra.s	bbrez15b
bbrez15a:
	andi.w	#$F,d1
	subq.l	#8,a4
bbrez15b:
	bsr.s	brshblit
	tst.w	d6		;d negative?
	bmi.s	bbrez15
	add.w	d7,d6
*
*	add.w	d3,d1		;advance y
*
	adda.w	d3,a4
*
	bsr.s	brshblit
	bra.s	bbrez16
bbrez15:
	add.w	d5,d6
bbrez16:
	dbra	d4,bbrez14
	movem.l	(sp)+,a2-a5/d0-d7
	rts
*
*
*
*
*  Blit brush
*
* entry:
*  a2 -> left-most 1st plane word of line 1 below bottom clip line
*  a3 -> left-most 1st plane word of top line (curscren)
*  a4 -> current 1st plane word of current pixel
*  a5 -> current brush height (1 word) followed by height words of grafix data
*
*  d0.w - signed xpos
*  d1.w - x right shift count 
*
brshblit:
	movem.l	a2-a5/d0-d6,-(sp)
	cmpi.w	#-16,d0			;xpos less than or equal to -16?
	ble	bblitq			;br to exit, totally clipped off left
	cmpi.w	#320,d0			;xpos greater than or equal to 320?
	bge	bblitq			;br to exit, totally clipped off right
*
	tst.w	d0
	bpl.s	bblita
	subq.l	#8,a2
	subq.l	#8,a3
bblita:
	move.w	selctcol,d4
	bset.l	#4,d4			;tricky loop terminator
	move.w	(a5)+,d2		;get brush height
	bra.s	bblitlpi
bblitlp:
	moveq	#0,d3
	move.w	(a5)+,d3		;get grafix
	swap	d3
	cmpa.l	a2,a4			;below bottom clip line?
	bcc.s	bblitq			;br to exit if so
	cmpa.l	a3,a4			;above clip line?
	bcs.s	bblitlp2		;br to check next line if so
	lsr.l	d1,d3
	move.l	d3,d5
	not.l	d5
	move.w	d4,d6			;move color to temp
	move.l	a4,-(sp)
	tst.w	d0
	bmi.s	loonly
	cmpi.w	#320-16,d0
	bge.s	hionly
fullok:
	lsr.w	d6
	beq.s	bblitlp3
	bcc.s	full1
	or.w	d3,8(a4)
	swap	d3
	or.w	d3,(a4)+
	swap	d3
	bra.s	fullok
full1:
	and.w	d5,8(a4)
	swap	d5
	and.w	d5,(a4)+
	swap	d5
	bra.s	fullok
*
*  lo word only
*
loonly:
	addq.l	#8,a4
loonlylp:
	lsr.w	d6
	beq.s	bblitlp3
	bcc.s	lo1
	or.w	d3,(a4)+
	bra.s	loonlylp
lo1:
	and.w	d5,(a4)+
	bra.s	loonlylp
*
*  hi word only
*
hionly:
	swap	d3
	swap	d5
hionlylp:
	lsr.w	d6
	beq.s	bblitlp3
	bcc.s	hi1
	or.w	d3,(a4)+
	bra.s	hionlylp
hi1:
	and.w	d5,(a4)+
	bra.s	hionlylp
bblitlp3:
	move.l	(sp)+,a4
bblitlp2:
	adda.w	#160,a4
bblitlpi:
	dbra	d2,bblitlp
bblitq:
	movem.l	(sp)+,a2-a5/d0-d6
	rts
*
*********************************************************************
*
*
*
*  Bresenham 8-way rampable brush draw routine
*
*
*  d0.w - x1		origin
*  d1.w - y1
*
*
*  d2.w - x2		destination
*  d3.w - y2
*
*
linedraw:
brshbrz8:
	movem.l	a1-a5/d0-d7,-(sp)
*
	move.w	rampcolr,d7	;rightmost color
	move.w	rampcoll,d5	;leftmost color
*
	sub.w	d5,d7
	addq.w	#1,d7		;# of colors
	movea.w	d5,a1
*
	movea.l	othscren,a3
	movea.l	a3,a4
	movea.l	a3,a2
	movea.l	brshptr,a5
*
	move.w	(a5)+,d5	;get brush width
	lsr.w	d5
	sub.w	d5,d0
	sub.w	d5,d2
	move.w	(a5),d5		;get brush heigh
	lsr.w	d5
	sub.w	d5,d1
	sub.w	d5,d3
*
	move.w	d1,d4		;origin y to temp
	muls	#160,d4		
	move.w	d0,d5
	bpl.s	b8rez1a
	addi.w	#16,d5
	subq.w	#8,d4
b8rez1a:
	lsr.w	#1,d5
	andi.w	#$FFF8,d5
	add.w	d5,d4
	adda.w	d4,a4		;1st plane address for start pixel
	move.w	half,d4
	mulu	#160,d4
	adda.w	d4,a2		;bottom clip address
*
	moveq	#0,d4		;reset bit 31 for increment x (if x is longest)
	moveq	#0,d5		;same for y (in case y is longest)
	move.l	#$8000FFFF,d6	;temp use for word 2's compliment & bit 31 set
*
	move.w	d2,d4		;copy x2 to find delta x
	sub.w	d0,d4		;d4 = signed delta x
	bpl.s	b8rez1		;br if positive
	eor.l	d6,d4		;1's compliment of word & set bit 31
	addq.w	#1,d4		;d4.w = positive delta x
b8rez1:
	move.w	d1,d5		;do same for y
	sub.w	d3,d5		;form signed delta y
	bpl.s	b8rez2
	eor.l	d6,d5
	addq.w	#1,d5		;d5.w = positive delta y, bit 31 set if was neg
b8rez2:
	move.w	d0,d1		;save for clipping
	andi.w	#$F,d1		;finished using d1 as xpos, now its lsr.l count
*
	cmp.w	d5,d4		;which delta larger, x or y?
	bcc	b8rez10		;br if x is larger
b8rez3:
*
*  y is largest, always increment y, selectively increment x
*
	move.w	d5,d6		;copy # of pixels to temp
	addq.w	#1,d6
	ext.l	d6
	divu	d7,d6		;divide by # of colors to get # pixels/color
	move.w	d6,colcnt
	move.w	d6,colcntc
	swap	d6
	subq.w	#1,d6
	move.w	d6,colrem
	bmi.s	colcok18
	addq.w	#1,colcntc
colcok18:
*
	move.w	d4,d6		;dx
	lsl.w	#1,d6		;2 * dx
	sub.w	d5,d6		;d6 = (2 * dx) - dy = d
*
	move.w	d4,d7		;dx
	sub.w	d5,d7		;dx - dy
	lsl.w	#1,d7		;d7 = 2 * (dx - dy) = incr2
*
	move.w	#-160,d3	;assume y decrement (move up)
	tst.l	d5		;y1 or y2 top-most
	bpl.s	b8rez5		;br if y2 is top-most (increment assumption ok)
	move.w	#160,d3		;else, increment y to move down
b8rez5:
	moveq	#-1,d2		;assume x decrement (move right)
	lsl.l	#1,d4		;d4 = 2 * dx = incr1 (bit 31 to cy)
	bcs.s	b8rez6		;br if x1 left of x2
	moveq	#1,d2		;else, increment x to move left
b8rez6:
	bra.s	b8rez9		;enter loop at pixel plot
b8rez7:
	adda.w	d3,a4		;advance y
*
	tst.w	d6		;d negative?
	bmi.s	b8rez8
	add.w	d7,d6
*
	add.w	d2,d0
	add.w	d2,d1
	bmi.s	b8rez8a
	beq.s	b8rez9
	andi.w	#$F,d1
	bne.s	b8rez9
	addq.l	#8,a4		;need to
	bra.s	b8rez9
b8rez8a:
	andi.w	#$F,d1
	subq.l	#8,a4
	bra.s	b8rez9
b8rez8:
	add.w	d4,d6
b8rez9:
	bsr	brshblt8
	dbra	d5,b8rez7
	movem.l	(sp)+,a1-a5/d0-d7
	rts
*
*  x is largest, always increment x, selectively increment y
*
b8rez10:
*
	move.w	d4,d6		;copy # of pixels to temp
	addq.w	#1,d6
	ext.l	d6
	divu	d7,d6		;divide by # of colors to get # pixels/color
	move.w	d6,colcnt
	move.w	d6,colcntc
	swap	d6
	subq.w	#1,d6
	move.w	d6,colrem
	bmi.s	colcok8
	addq.w	#1,colcntc
colcok8:
*
*
	move.w	d5,d6		;dy
	lsl.w	#1,d6		;2 * dy
	sub.w	d4,d6		;d6 = (2 * dy) - dx = d
*
	move.w	d5,d7		;dy
	sub.w	d4,d7		;dy - dx
	lsl.w	#1,d7		;d7 = 2 * (dy - dx) = incr2
*
	moveq	#1,d2		;assume x increment (move to right)
	tst.l	d4		;x1 or x2 leftmost
	bpl.s	b8rez12		;br if x1 is leftmost
	moveq	#-1,d2		;else, decrement x to move left
b8rez12:
	move.w	#160,d3		;assume y increment (move up)
	lsl.l	#1,d5		;d5 = 2 * dy = incr1 (bit 31 to cy)
	bcs.s	b8rez13		;br if y1 below y2
	move.w	#-160,d3	;else, decrement y to move down
b8rez13:
	bra.s	b8rez16		;enter loop at pixel plot
b8rez14:
	add.w	d2,d0
	add.w	d2,d1
	bmi.s	b8rez15a
	beq.s	b8rez15b
	andi.w	#$F,d1
	bne.s	b8rez15b
	addq.l	#8,a4		;need to
	bra.s	b8rez15b
b8rez15a:
	andi.w	#$F,d1
	subq.l	#8,a4
b8rez15b:
	tst.w	d6		;d negative?
	bmi.s	b8rez15
	add.w	d7,d6
	adda.w	d3,a4
	bra.s	b8rez16
b8rez15:
	add.w	d5,d6
b8rez16:
	bsr.s	brshblt8
	dbra	d4,b8rez14
	movem.l	(sp)+,a1-a5/d0-d7
	rts
*
*
*
*
*  Blit rampable brush
*
* entry:
*  a1 = current color
*  a2 -> left-most 1st plane word of line 1 below bottom clip line
*  a3 -> left-most 1st plane word of top line (curscren)
*  a4 -> current 1st plane word of current pixel
*  a5 -> current brush height (1 word) followed by height words of grafix data
*
*  d0.w - signed xpos
*  d1.w - x right shift count 
*
brshblt8:
	movem.l	a2-a5/d0-d6,-(sp)
	cmpi.w	#-16,d0			;xpos less than or equal to -16?
	ble	b8litq			;br to exit, totally clipped off left
	cmpi.w	#320,d0			;xpos greater than or equal to 320?
	bge	b8litq			;br to exit, totally clipped off right
*
	tst.w	d0
	bpl.s	b8lita
	subq.l	#8,a2
	subq.l	#8,a3
b8lita:
	subq.w	#1,colcntc
	bpl.s	mocol8
	move.w	colcnt,colcntc
	subq.w	#1,colrem
	bpl.s	mocol18
	subq.w	#1,colcntc
mocol18:
	addq.l	#1,a1
mocol8:
	move.w	a1,d4			;current color
	bset.l	#4,d4			;tricky loop terminator
	move.w	(a5)+,d2		;get brush height
	bra.s	b8litlpi
b8litlp:
	moveq	#0,d3
	move.w	(a5)+,d3		;get grafix
	swap	d3
	cmpa.l	a2,a4			;below bottom clip line?
	bcc.s	b8litq			;br to exit if so
	cmpa.l	a3,a4			;above clip line?
	bcs.s	b8litlp2		;br to check next line if so
	lsr.l	d1,d3
	move.l	d3,d5
	not.l	d5
	move.w	d4,d6			;move color to temp
	move.l	a4,-(sp)
	tst.w	d0
	bmi.s	loonly8
	cmpi.w	#320-16,d0
	bge.s	hionly8
fullok8:
	lsr.w	d6
	beq.s	b8litlp3
	bcc.s	full18
	or.w	d3,8(a4)
	swap	d3
	or.w	d3,(a4)+
	swap	d3
	bra.s	fullok8
full18:
	and.w	d5,8(a4)
	swap	d5
	and.w	d5,(a4)+
	swap	d5
	bra.s	fullok8
*
*  lo word only
*
loonly8:
	addq.l	#8,a4
loonlyl8:
	lsr.w	d6
	beq.s	b8litlp3
	bcc.s	lo18
	or.w	d3,(a4)+
	bra.s	loonlyl8
lo18:
	and.w	d5,(a4)+
	bra.s	loonlyl8
*
*  hi word only
*
hionly8:
	swap	d3
	swap	d5
hionlyl8:
	lsr.w	d6
	beq.s	b8litlp3
	bcc.s	hi18
	or.w	d3,(a4)+
	bra.s	hionlyl8
hi18:
	and.w	d5,(a4)+
	bra.s	hionlyl8
b8litlp3:
	move.l	(sp)+,a4
b8litlp2:
	adda.w	#160,a4
b8litlpi:
	dbra	d2,b8litlp
b8litq:
	movem.l	(sp)+,a2-a5/d0-d6
	rts
*
*
*
*********************************************************************
*
*  Finds proper font based on textsize
*
*
*   Uses as input:	textsize
*
*  Sets as output:
*
*	Var name	VDI equiv	use
*	--------	---------	---
*
*	fonthead	N/A		currently selected font header ptr
*	scaleflg	scale(a0)	scaling on or off (0=off)
*	textscal	dda_inc(a0)	scaling factor
*	txtupdwn	t_sclsts(a0)	enlarge/shink (0=shrink, else enlarge)
*			
*
textset:
	.dc.w	$A000		;get ptr to 1st font ptr
	clr.w	scaleflg	;assume no scaling
	move.w	textsize,d0	;get intended text size
	move.l	a1,a4		;copy fontheader list ptr
	move.l	(a4)+,a2	;get 1st font header ptr
	moveq	#-1,d2		;set current minimum difference to large value
*
*  loop to check all available fonts for closest fit..
*
setfont1:
	move.w	topline(a2),d3	;check font size parm
	sub.w	d0,d3		;find difference from desired size
	beq.s	setfont6	;br if hit it on the head, use this font
	bcc.s	setfont2	;br if positive diff
	neg.w	d3		;  else, do absolute value
setfont2:
	cmp.w	d2,d3		;check diff against current minimum
	bcc.s	setfont3	;br if new minimum not found
	move.w	d3,d2		;  else, replace old minimum with new
	move.l	a2,a3		;  & remember this fonthead
setfont3:
	move.l	(a4)+,a2	;advance to next font
*	move.l	nextfont(a2),a2	;advance to next font
	cmpa.w	#0,a2
	bne.s	setfont1	;loop til all fonts exhausted
*
*  now check all fonts against double size for closest fit..
*
	move.l	a1,a4
	move.l	(a4)+,a2	;start with 1st font
setfontB:
	move.w	topline(a2),d1	;check font size parm
	lsl.w	#1,d1		;try exact double for match
	sub.w	d0,d1		;find difference from desired size
	beq.s	setfont6	;br if hit it on the head, use this font
	bcc.s	setfont4	;br if positive diff
	neg.w	d1		;  else, do absolute value
setfont4:
	cmp.w	d2,d1		;check against current minimum
	bcc.s	setfont5	;br if new minimum not found
	move.w	d1,d2		;  else, replace old minimum with new
	move.l	a2,a3		;  & remember this fonthead
setfont5:
	move.l	(a4)+,a2	;advance to next font
	cmpa.w	#0,a2
*	move.l	nextfont(a2),a2	;advance to next font
	bne.s	setfontB	;loop til all fonts exhausted
	bra.s	setfont7
*
*  gotta font..
*
setfont6:
	move.l	a2,a3		;save font head ptr for exact match
setfont7:
*
*  test code to force font 8x8
*	move.l	4(a1),a3
*
*  end test code
*
	move.l	a3,fonthead	;save chosen font ptr
	move.w	topline(a3),d1	;reget winning actual size
	cmp.w	d1,d0		;is desired size smaller or larger?
	beq.s	setfontq	;br if no scaling required
*
	bsr	_CLC_DDA
*
	move.w	d0,textscal
	not.w	scaleflg
*
*
*  font selection & scaling complete, now load up other font specific stuff..
*
setfontq:
*
*  form txtcelht from fonthead,textstyl
*
setadj:
	move.l	fonthead,a2
	move.w	topline(a2),d0
	bsr	_ACT_SIZ
	move.w	d0,txtbastp	;form mouse cursor hot spot distance from top
*
*	move.w	leftoff(a2),d0		;adjust left offset (for skew)
*	bsr	_ACT_SIZ
*	move.w	d0,scaleft
*
*	move.w	riteoff(a2),d0		;adjust rite offset (for skew)
*	bsr	_ACT_SIZ
*	move.w	d0,scalrite
*
	move.w	undline(a2),d0
	bsr.s	_ACT_SIZ
	move.w	d0,unlinetk		;form underline thickness
*
	move.w	leftoff(a2),d0		;adjust left offset (for skew)
	move.w	riteoff(a2),d1		;adjust rite offset (for skew)
	move.w	formhite(a2),d5
	move.w	d1,d3
	add.w	d0,d3
	move.w	d5,d2
	lsr.w	#1,d2
	sub.w	d3,d2
	add.w	d2,d1
	bpl.s	setadj1
	move.w	#0,d1
setadj1:
*	
	bsr.s	_ACT_SIZ
	move.w	d0,scaleft
*
	move.w	d1,d0
	bsr.s	_ACT_SIZ
	move.w	d0,scalrite
*
	move.w	d5,d0	
	bsr.s	_ACT_SIZ
*
	move.w	d0,d4
*
	move.w	textstyl,d0
	btst.l	#4,d0		;outline in effect?
	beq.s	sfnt
	addq.w	#2,d4
sfnt:
	btst.l	#3,d0		;underline in effect?
	beq.s	sfnt1
	move.w	d4,unlineht	;form underline distance from top
	add.w	unlinetk,d4
sfnt1:
	move.w	d4,txtcelht
	rts
*
*
*
*  Actual sizer routine copped from TEXTBLT
*  uses different registers tho
*
*  entry:
*	d0 = size to scale (DELY)
*		uses scaleflg,txtupdwn,textscal
*  exit:
*	d0 = actual size (final DELY)
*  destroys:d2,d3,d4
*
_ACT_SIZ:
	move.w	#$7FFF,d3		;d3 = accumulator = 1/2      (bx)
act_siz1:
	tst.w	scaleflg		;are we scalin'?
	beq.s	no_act			;br if not
	move.w	textscal,d2
	cmp.w	#$FFFF,d2
	beq.s	siz_doub
	moveq	#0,d4			;d4 = new count
	subq.w	#1,d0			;zero adjust DELY count
	bmi.s	siz_0			;if it was 0, just exit
	tst.w	txtupdwn		;check for shrink
	beq.s	sz_sm_lp		;br if so
sz_lp:
	add.w	d2,d3			;else, enlarge
	bcc.s	siz_tim1
	addq.w	#1,d4
siz_tim1:
	addq.w	#1,d4
	dbra	d0,sz_lp
siz_0:
	bra.s	act_exit
siz_doub:
	move.w	d0,d4
	lsl.w	#1,d4			;d4 = size * 2
	bra.s	act_exit
*
sz_sm_lp:
	add.w	d2,d3
	bcc.s	sz_sm_1
	addq.w	#1,d4
sz_sm_1:
	dbra	d0,sz_sm_lp
*
	tst.w	d4			;if d4 = 0, then make = 1
	bne.s	sz_sm_2
	addq.w	#1,d4
act_exit:
sz_sm_2:
	move.w	d4,d0
no_act:
	rts
*
*
*
******************************************************************
*
*  calculate DDA (as copped from TEXTBLT)
*
*  entry:
*     d1 = actual size
*     d0 = requested sie
*  exit:
*     d0    = DDA_INC
*
*
*
_CLC_DDA:
	cmp.w	d1,d0			;if actual =< requested
	ble.s	clc_smal		;  then scale down
*
	move.w	#1,txtupdwn		;set enlarge indicator
	sub.w	d1,d0
	cmp.w	d1,d0			;larger than 2x?
	blt.s	smal_ok			;br if not
clc_big:
	moveq	#-1,d0			;put $FFFF in d0 (max value, 2x)
	rts
*
clc_smal:
	clr.w	txtupdwn		;clear enlarge indicator (scale down)
	tst.w	d0			;check requested size
	bne.s	smal_ok			;br if non-zero
	moveq	#1,d0			;if 0 then make it 1 (minimum value)
smal_ok:
	swap	d0			;requested size to high word
	clr.w	d0			;clear lo word
	divu	d1,d0			;d0 = requested/actual
	rts
*
*
*  Put out system text 8x8
*
*  a0 -> text string
*  d0 - x starting position
*  d1 - y starting position
*
*
systxt8:
	move.w	#0,d3			;replace writing mode
	move.w	#0,d2			;plain style
	movem.l	a0/d0-d3,-(sp)
	.dc.w	$A000
	move.l	4(a1),a1		;use 2nd fonthead
	bra.s	systxt1
*
*
*  a0 -> text string
*  d0 - x starting position
*  d1 - y starting position
*  d2 - style
*
systxt6i:
	moveq	#2,d3			;inverse 6x6
	bra.s	systxt
systxt6t:
	moveq	#1,d3			;transparent 6x6
	bra.s	systxt
*
systxt6:
	moveq	#0,d3			;replace 6x6
systxt:
	movem.l	a0/d0-d3,-(sp)
	.dc.w	$A000
*
	move.l	(a1),a1			;use 1st fonthead
systxt1:
	clr.w	clip(a0)		;no clipping
	clr.w	scale(a0)		;no scaling
	movem.l	(sp)+,a0/d0-d3
	move.w	d2,d4
	moveq	#15,d2
	bra	linatext
*
*  Graphics text using line A for user (non-system) use..
*
*
*  entry:
*	a0 -> text string
*	d0 - starting x position
*	d1 - starting y position
*
graftxt:
	movem.l	a0/d0-d1,-(sp)
	.dc.w	$A000
	move.w	#-1,clip(a0)		;clip to full or half
	clr.w	xmn_clip(a0)
	clr.w	ymn_clip(a0)
	move.w	#319,xmx_clip(a0)
	move.w	half,d0
	subq.w	#1,d0
	move.w	d0,ymx_clip(a0)
*
	move.w	scaleflg,scale(a0)	;set up arbitrary scaling
	move.w	textscal,dda_inc(a0)
	move.w	txtupdwn,t_sclsts(a0)
	move.w	xacc_dda(a0),d3		;save in d3 for act_siz1
	movem.l	(sp)+,a0/d0-d1
*
	move.l	fonthead,a1
	move.w	textalin,d2
	beq.s	noalin
	movem.l	a0/d0-d1,-(sp)
	move.w	d2,d1
	moveq	#0,d5
	move.w	first_ad(a1),d6
	move.w	textstyl,d2
	moveq	#0,d7
	btst.l	#4,d2		;outline in effect?
	beq.s	leng1
	addq.w	#2,d7
leng1:
	btst.l	#0,d2		;thicken in effect?
	beq.s	leng2
	add.w	thicken(a1),d7
leng2:
	swap	d7
	move.w	last_ad(a1),d7
	move.l	offsetp(a1),a3
lengloop:
	move.b	(a0)+,d2
	beq.s	lenglpq	
*
	andi.w	#$FF,d2
	sub.w	d6,d2
	cmp.w	d7,d2
	bhi.s	lengloop		;br if text out of range
	lsl.w	#1,d2
	move.w	2(a3,d2.w),d0
	sub.w	(a3,d2.w),d0
*	bsr	_ACT_SIZ
	add.w	d0,d5
	swap	d5
	swap	d7
	add.w	d7,d5
	swap	d7
	swap	d5
	bra.s	lengloop
lenglpq:
	move.w	d5,d0
*
*  use XACC_DDA found in d3
*
	bsr	act_siz1
	swap	d5
	add.w	d0,d5
*	move.w	d0,d5
*
	cmpi.w	#1,d1			;mid align?
	bne.s	nmidalin
	lsr.w	d5
nmidalin:
	movem.l	(sp)+,a0/d0-d1
	sub.w	d5,d0
noalin:
	move.w	selctcol,d2
	moveq	#1,d3		;use transparent mode
	move.w	textstyl,d4
*
*  fall thru to...
*
*  Graphics text using line A
*
*
*  entry:
*	a0 -> text string
*	a1 -> fontheader ptr
*	d0 - starting x position
*	d1 - starting y position
*	d2 - color
*	d3 - writing mode (0-replace,1-transparent,2-XOR,3-inverse trans, etc.)
*	d4 - style
*
*  exit:
*	a0 -> next text string
*	d0 -  x position of next character
*
*	all others preserved
*
*
linatext:
	movem.l	a1-a6/d1-d7,-(sp)
*
	movem.l	a0-a1/d0-d4,-(sp)
	.dc.w	$A000
	move.l	a0,a2			;a2 -> vdi variables base addr
	movem.l	(sp)+,a0-a1/d0-d4
*
*  load up parms into VDI variables
*
	clr.w	mono_st(a2)		;never mono spaced
	move.w	d0,destx(a2)
	move.w	d1,desty(a2)
	move.w	d2,text_fg(a2)
	move.w	d3,wrt_mode(a2)
	move.w	d4,style(a2)
	move.l	fontdata(a1),fbase(a2)
	move.w	formwid(a1),fwidth(a2)
	move.w	formhite(a1),dely(a2)
	move.w	skewmsk(a1),skewmask(a2)
	move.w	#$AAAA,litemask(a2)
	move.w	thicken(a1),weight(a2)
	btst.l	#2,d4			;skew on?
	beq.s	lina1
	move.w	scaleft,l_off(a2)
	move.w	scalrite,r_off(a2)
	bra.s	lina2
lina1:
	clr.l	r_off(a2)
lina2:
*
*  may need to stuff more than stuffed above
*
	move.l	offsetp(a1),a3		;a3 -> offset table ptr
	move.b	(a0)+,d3		;if null string
	beq.s	charq1			;  skip underline section
	bra.s	charlp2			;else, jump into loop
charloop:
	move.b	(a0)+,d3		;get 1st char
	beq.s	charq			;exit if reached last one
charlp2:
	andi.w	#$FF,d3
	sub.w	first_ad(a1),d3		;subtract 1st
	cmp.w	last_ad(a1),d3
	bhi.s	charloop		;br if text out of range
	lsl.w	#1,d3

	move.w	(a3,d3.w),d5
	move.w	d5,sourcex(a2)	
	move.w	2(a3,d3.w),d6
	sub.w	d5,d6
	move.w	d6,delx(a2)
	movem.l	a0-a3/d0-d4,-(sp)
*
	.dc.w	textblt			;blit the character
*
*	bsr	vdiput			;this can be removed when local
*	bsr	_TEXT_BL		;textblt goes away
*	bsr	locput			;
*
	movem.l	(sp)+,a0-a3/d0-d4
*
	bra.s	charloop		;loop for next character
*
*  Reached end of string..
*
charq:
	btst.l	#3,d4			;underlinin'?
	beq.s	charq1			;br if not
	move.w	d2,d4			;save color for underline color
	move.w	destx(a2),d2
	subq.w	#1,d2
	add.w	unlineht,d1
	move.w	d1,d3
	add.w	unlinetk,d3
	subq.w	#1,d3
	moveq	#1,d5
*
	bsr	fillbox			;draw underline with fill box	
charq1:
	move.w	destx(a2),d0
	movem.l	(sp)+,a1-a6/d1-d7
	rts
*
*
*  the following routine can be eliminated when
*  local copy of textblt is eliminated
*
*  install vdi variables for local textblt
*
*vdiput:
*2	.dc.w	$a000
*	movea.l	#fakevdi,a1
*	move.w	#53,d0
*vdiloop:
*	move.w	(a0)+,(a1)+
*	dbra	d0,vdiloop
*
*	move.w	#3,-(sp)	;logical screen addr
*	trap	#14
*	addq.l	#2,sp
*	move.l	d0,_v_bas_a
*	rts
*
*
*
*locput:
*	.dc.w	$a000
*	movea.l	#fakevdi,a1
*8	move.w	#53,d0
*locloop:
*	move.w	(a1)+,(a0)+
*	dbra	d0,locloop
*
*	rts
*
*
*
*	.data
*
*
*  the following data (up to _TEXT_BG)
*  can be eliminated when local copy of textblt is no longer needed
*
*_v_bas_a:
*	.dc.l	0
*
*  stuff all these from vdi variables
*
*fakevdi:
*_v_planes:
*	.dc.w	4
*_v_lin_wr:
*	.dc.w	160
*	.dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
*_WRT_MOD:
*	.dc.w	0
*	.dc.w	0,0,0,0,0,0,0,0
*_CLIP:
*	.dc.w	0
*_XMN_CLI:
*	.dc.w	0
*_YMN_CLI:
*	.dc.w	0
*_XMX_CLI:
*	.dc.w	319
*_YMX_CLI:
*	.dc.w	199
*_XACC_DD:
*	.dc.w	0
*_DDA_INC:
*	.dc.w	0
*_T_SCLST:
*	.dc.w	0
*_MONO_ST:
*	.dc.w	0
*_SOURCEX:
*	.dc.w	0
*_SOURCEY:
*	.dc.w	0
*_DESTX:
*	.dc.w	0
*_DESTY:
*	.dc.w	0
*_DELX:
*	.dc.w	0
*_DELY:
*	.dc.w	0
*_FBASE:
*	.dc.l	0
*_FWIDTH:
*	.dc.w	0
*_STYLE:
*	.dc.w	0
*_LITEMAS:
*	.dc.w	0
*_SKEWMAS:
*	.dc.w	0
*_WEIGHT:
*	.dc.w	0
*_R_OFF:
*	.dc.w	0
*_L_OFF:
*	.dc.w	0
*_DOUBLE:
*	.dc.w	0
*_CHUP:
*	.dc.w	0
*_TEXT_FG:
*	.dc.w	0
*_scrtchp:
*	.dc.l	0
*_scrpt2:
*	.dc.w	$100
*_TEXT_BG:
*	.dc.w	0
*
*
*
	.bss
*
*  variables for use with ramped color line draw..
*
colrem:
	.ds.w	1
colcnt:
	.ds.w	1
colcntc:
	.ds.w	1
rampcolr:
	.ds.w	1	;rightmost ramp color
rampcoll:	
	.ds.w	1	;leftmost ramp color
*
*
*  variables set up by setfont..
*
fonthead:
	.ds.l	1	;current font header
scaleflg:
	.ds.w	1	;0=no text scaling
textscal:
	.ds.w	1	;text scaling factor dda_inc(a0)
txtupdwn:
	.ds.w	1	;shrink/expand (0=shrink)
unlineht:
	.ds.w	1	;underline displacement from top
unlinetk:
	.ds.w	1	;underline thickness
scaleft:
	.ds.w	1	;scaled left offset
scalrite:
	.ds.w	1	;scaled rite offset
txtbastp:
	.ds.w	1	;baseline to topline displacement

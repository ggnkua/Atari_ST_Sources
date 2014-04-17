*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemgrlib.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:23:29 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemgrlib.s,v $
* Revision 2.2  89/04/26  18:23:29  mui
* TT
* 
* Revision 2.1  89/02/22  05:26:52  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:34:03  lozben
* Initial revision
* 
*************************************************************************
*
*
*
*  GEMGRLIB.S   hand-compiled from GEMGRLIB.C
*		   *** Fresh Squozen ***
*		 by Dave Staugas  29-Jan-87
*
* assemble with MAS 900801 kbad
*	Took out gr_slidebox

	.globl	_rlr
	.globl	_drl
	.globl	_nrl
	.globl	_eul
	.globl	_dlr
	.globl	_zlr
	.globl	_elinkof
	.globl	_indisp
	.globl	_infork
	.globl	_fpt
	.globl	_fph
	.globl	_fpcnt
	.globl	_wind_sp
	.globl	_cda
	.globl	_curpid
	.globl	_gl_rscreen
	.globl	_gl_rzero
	.globl	_xrat
	.globl	_yrat
	.globl	_button
	.globl	_kstate
*	.globl	_gr_still
*
*
*
*
*   Globals that must be from the include files
*
	.globl	_ev_mult,_gsx_scl,_gsx_att,_gsx_mxm,_gsx_xcb,_gsx_xbo
	.globl	_gsx_mof,_gsx_mon,_rc_equa,_wm_upda,_rc_cons,_ob_actx
	.globl	_ob_chan,_ob_relx,_mul_div
*
*
*
	.text
*
*
*
*
*
*
*  Local routine for gr_stepcalc to evaluate:
*
* 	 (pt->g_w/2) - (orgw/2)
* 	 (pt->g_h/2) - (orgh/2)
*					;+16
steploc:
	move.w	4(a3,d2.w),d0		;d0 = pt->g_w
	lsr.w	#1,d0			;d0 = pt->g_w/2
*
	move.w	16+4(sp,d2.w),d1	;d1 = orgw
	lsr.w	#1,d1			;d1 = orgw/2
*
	sub.w	d1,d0			;d0 = (pt->g_w/2) - (orgw/2)
	rts
*
*
	.globl _gr_stepc
*
*
*
*				offset from sp at entry
*	entry:	.w	orgw	+4
*		.w	orgh	+6
*		.l	*pt	+8
*		.l	*pcx	+12
*		.l	*pcy	+16
*		.l	*pcnt	+20
*		.l	*pxstep	+24
*		.l	*pystep	+28
*	exit:	none
*
_gr_stepc:
	movem.l	a3-a5,-(sp)		;+12
	lea	12+8(sp),a0		;a0 => &pt
*
	movem.l	(a0)+,a3-a5		;a3 => *pt
*					;a4 => *pcx
*					;a5 => *pcy
*
	moveq	#0,d2			;start with pt->g_w / orgw
	bsr	steploc			;d0 = (pt->g_w/2) - (orgw/2) 
	move.w	d0,(a4)			;save in *pcx
*
	moveq	#2,d2			;now with pt->g_h / orgh
	bsr	steploc			;d0 = (pt->g_h/2) - (orgh/2)
	move.w	d0,(a5)			;save in *pcy
*
	addq.l	#8,a0			;a0 -> &pystep
	move.l	(a0),-(sp)		;+16 parm 5 &pystep
	move.l	-(a0),-(sp)		;+20 parm 4 &pxstep	
	move.l	-(a0),-(sp)		;+24 parm 3 &pcnt
	move.w	(a5),-(sp)		;+26 parm 2 *pcy
	move.w	(a4),-(sp)		;+28 parm 1 *pcx
*
	jsr	_gr_scale	;gr_scale(*pcx, *pcy, pcnt, pxstep, pystep);
*
	move.w	(a3)+,d0		;d0 = pt->g_x
	add.w	d0,(a4)			;*pcx += pt->g_x
*
	move.w	(a3),d0			;d0 = pt->g_y
	add.w	d0,(a5)			;*pcy += pt->g_y
*
	adda.w	#16,sp			;+12
	movem.l	(sp)+,a3-a5		
	rts
*
*
*
*
*  routine common to growbox & shrinkbox
*
*  gr_stepcalc(po->g_w, po->g_h, pt, &cx, &cy, &cnt, &xstep, &ystep);
*
*
*  entry:
*	sp level assumed +40
*
*  exit:
*	a5 = &pt
*	a4 = &po
*	a6 -> cx
*
grshcalc:
	movem.l	40+4(sp),a4-a5		;a4 = &po
*					;a5 = &pt
	lea	40-24(sp),a6		;a6-2 = &ystep
	moveq	#4,d0			;need to push 5 ptrs for stepcalc
ptrpsh:
	subq.l	#2,a6			;&ystep, &xstep, &cnt, &cy, &cx
	move.l	a6,-(sp)		;+4       +8     +12   +16  +20 
	dbra	d0,ptrpsh
*
	move.l	a5,-(sp)		;+24 &pt
	move.l	4(a4),-(sp)		;+28 po->g_w, po->g_h
*
	bsr	_gr_stepc	;gr_stepcalc(po->g_w,po->g_h,pt,&cx,...)
*
	adda.w	#28,sp
	rts
*
*
*
*	gr_growbox
*
*
*
*	locals:	.w	DUMMY		-32
*		.w	cx		-34
*		.w	cy		-32
*		.w	cnt		-30
*		.w	xstep		-28
*		.w	ystep		-26
*
*  reserves:	.l	preserved d5	-24
*		.l	preserved d6	-20
*		.l	preserved d7	-16
*		.l	preserved a4	-12
*		.l	preserved a5	-8
*		.l	preserved a6	-4
*
*				offset from sp at entry
*	entry:	.l	po		+4
*		.l	pt		+8
*
*	exit:	none
*
*
	.globl _gr_growb
*
*
_gr_growb:
	movem.l	d2-d7/a4-a6,-(sp)	;+36 reserve 12 bytes & d5-d7/a4-a6
	bsr	grshcalc
*
	move.l	(a6),-(sp)		;+40 cx , cy
	move.l	(a4)+,-(sp)		;+44 po->g_x, po->g_y
	move.l	(a4),-(sp)		;+48 po->g_w, po->g_h
*
	jsr	_gr_movebox
*
	jsr	_gsx_mof
*
	moveq	#1,d7			;loop twice
lab41:
	moveq	#1,d0			;load up TRUE
	move.w	d0,-(sp)		;+50 parm 9 TRUE
	move.l	6(a6),-(sp)		;+54 parm 7 8 xstep, ystep
	move.l	(a4),-(sp)		;+58 parm 5 6 po->g_w, po->g_h
	move.l	(a6),-(sp)		;+62 parm 3 4 cx , cy
	move.w	4(a6),-(sp)		;+64 parm 2 cnt
	move.w	d0,-(sp)		;+66 parm 1 TRUE
*
	bsr	_gr_xor
	adda.w	#18,sp			;+48
	dbra	d7,lab41
*
	jsr	_gsx_mon
*
	adda.w	#24,sp			;+24			
	movem.l	(sp)+,d5-d7/a4-a6	;+0
	rts
*
*
*
*	gr_shrinkbox
*
*
*
*	locals:	.w	DUMMY		-32
*		.w	cx		-34
*		.w	cy		-32
*		.w	cnt		-30
*		.w	xstep		-28
*		.w	ystep		-26
*
*  reserves:	.l	preserved d5	-24
*		.l	preserved d6	-20
*		.l	preserved d7	-16
*		.l	preserved a4	-12
*		.l	preserved a5	-8
*		.l	preserved a6	-4
*
*				offset from sp at entry
*	entry:	.l	po		+4
*		.l	pt		+8
*
*	exit:	none
*
*
	.globl _gr_shrin
*
*
*
_gr_shrin:
	movem.l	d2-d7/a4-a6,-(sp)	;+36 reserve 12 bytes & d5-d7/a4-a6
	bsr	grshcalc		;call gr_stepcalc just like growbox
*
	jsr	_gsx_mof
*
	moveq	#1,d7			;loop twice
lab46:
	addq.l	#4,a5			;a5 -> pt->g_w
	moveq	#1,d0			;load up TRUE
	move.w	d0,-(sp)		;+38 parm 9 TRUE
*
	move.w	8(a6),-(sp)		;+40 parm 8  ystep
	neg.w	(sp)			;           -ystep
*
	move.w	6(a6),-(sp)		;+42 parm 7  xstep
	neg.w	(sp)			;	    -xstep
*
	move.l	(a5),-(sp)		;+46 parm 5 6 pt->g_w, pt->g_h
	move.l	-(a5),-(sp)		;+50 parm 3 4 pt->g_x, pt->g_y
	move.w	4(a6),-(sp)		;+52 parm 2 cnt
	move.w	d0,-(sp)		;+54 parm 1 TRUE
*
	bsr	_gr_xor
	adda.w	#18,sp			;+36
	dbra	d7,lab46
*
	jsr	_gsx_mon
*
	move.l	(a4)+,-(sp)		;+40 po->g_x, po->g_y
	move.l	(a6),-(sp)		;+44 cx , cy
	move.l	(a4),-(sp)		;+48 po->g_w, po->g_h
*
	bsr	_gr_movebox
*
	adda.w	#24,sp			;+24
	movem.l	(sp)+,d5-d7/a4-a6	;+0
	rts
*
*
*
*
*
	.globl _gr_xor
*
*
*
*				offset from sp at entry
*	entry:	.w	clipped	+4
*		.w	cnt	+6
*		.w	cx	+8
*		.w	cy	+10
*		.w	cw	+12
*		.w	ch	+14
*		.w	xstep	+16
*		.w	ystep	+18
*		.w	dowdht	+20
*	exit:	none
*
_gr_xor:
	movem.l	d4-d7,-(sp)		;+16
	lea	16+4(sp),a0		;a0 -> clipped
	move.w	(a0)+,d4		;d4 = clipped
	move.w	(a0)+,d5		;d5 = cnt
*
	move.l	a0,-(sp)		;+20 parm 1 &cx
*
	addq.l	#8,a0			;a0 -> xstep
*
	move.w	(a0)+,d7		;d7 = xstep
	move.w	(a0)+,d6		;d6 = ystep
lab16:
	tst.w	d4			;test "clipped"
	beq	lab17			;br if false
*
	jsr	_gsx_xcb		;gsx_xcbox(&cx)
	bra	lab18
lab17:
	jsr	_gsx_xbo		;gsx_xbox(&cx)
lab18:
	lea	20+8(sp),a0		;a0 -> cx
	sub.w	d7,(a0)+		;cx -= xstep
	sub.w	d6,(a0)+		;cy -= ystep
*
	tst.w	20+20(sp)		;if(dowdht)
	beq	lab19			;br if FALSE
*
	move.w	d7,d0
	add.w	d0,d0
	add.w	d0,(a0)+		;cw += (2 * xstep)
*
	move.w	d6,d0
	add.w	d0,d0
	add.w	d0,(a0)+		;ch += (2 * ystep)
lab19:
	dbra	d5,lab16
	addq.l	#4,sp			;+16
	movem.l (sp)+,d4-d7
	rts
*
*
*	gr_movebox
*
*
*
*	locals:	.w	DUMMY		-32
*		.w	cnt		-30
*		.w	xstep		-28
*		.w	ystep		-26
*
*  reserves:	.l	preserved d3	-24
*		.l	preserved d4	-20
*		.l	preserved d5	-16
*		.l	preserved d6	-12
*		.l	preserved d7	-8
*		.l	preserved a5	-4
*
*				offset from sp at entry
*	entry:	.w	w		+4
*		.w	h		+6
*		.w	srcx		+8
*		.w	srcy		+10
*		.w	dstx		+12
*		.w	dsty		+14
*
*	exit:	none
*
*
*
	.globl _gr_movebox
*
*
_gr_movebox:
	movem.l	d1-d7/a5,-(sp)		;+32 8 bytes local space & d3-d7/a5
	move.l	sp,a5			;a5 ->DUMMY
	movem.l	32+4(sp),d5-d7		;d5[31:16]=w;    d5[15:00]=h
*					;d6[31:16]=srcx; d6[15:00]=srcy
*					;d7[31:16]=dstx; d7[15:00]=dsty
*
	move.w	d6,d4			;d4.w = srcy
	sub.w	d7,d4			;d4.w = srcy - dsty
*
	move.l	d6,d3			;d3[31:16] = srcx
	swap	d3
	swap	d7
	sub.w	d7,d3			;d3.w= srcx - dstx
*
	pea	32-26(sp)		;+36 parm 5 &ystep
	pea	36-28(sp)		;+40 parm 4 &xstep
	pea	40-30(sp)		;+44 parm 3 &cnt
*
	move.w	d3,d0			;d0 = srcx - dstx
	bpl	absxok
	neg.w	d0			;d0 = abs(srcx - dstx)
absxok:	
	swap	d0			;d0[31:16] = abs(srcx - dstx)
*
	move.w	d4,d0			;d0 = srcy - dsty
	bpl	absyok
	neg.w	d0			;d0 = abs(srcy - dsty)
absyok:	
	move.l	d0,-(sp)		;+48 parm 2 parm 1 
*
	bsr	_gr_scale
*
	move.l	(a5)+,d0		;d0[15:00] = cnt
*
	move.w	(a5)+,d7		;d7.w = xstep
	tst.w	d3			;check sign of (srcx - dstx)
	bpl	xnotneg			;negate xstep IFF sign was neg
	neg.w	d7
xnotneg:
	swap	d7			;d7[31:16] = signx*xstep
	move.w	(a5)+,d7		;d7[15:00] = ystep
	tst.w	d4			;check sign of (srcy - dsty)
	bpl	ynotneg			;negate ystep IFF sign was neg
	neg.w	d7		
ynotneg:
	moveq	#0,d4			;d4[31:16] = 0 FALSE
	move.w	d0,d4			;d4[15:00] = cnt 
*
	jsr	_gsx_mof
*
	exg	d5,d6			;this makes a reg "royal flush", i.e,
*					;d4[31:16] = FALSE; d4[15:00] = cnt;
*					;d5[31:16] = srcx;  d5[15:00] = srcy;
*					;d6[31:16] = w;     d6[15:00] = h;
*					;d7[31:16]=sx*xstep; d7[15:00]=sy*ystep
*
	moveq	#1,d3			;d3 = loop count (go twice thru)
lab36:
	clr.w	-(sp)			;+50 parm 9 FALSE
	movem.l	d4-d7,-(sp)		;+66 parms 8..1 (see royal flush above)
	jsr	_gr_xor
	adda.w	#18,sp			;+48
	dbra	d3,lab36
*
	jsr	_gsx_mon
*
	adda.w	#24,sp			;+24
	movem.l	(sp)+,d3-d7/a5		;+0
	rts
*
*
*
*
*
*
	.globl _gr_scale
*
*
*				offset from sp at entry
*	entry:	.w	xdist	+4
*		.w	ydist	+6
*		.l	pcnt	+8
*		.l	pxstep	+12
*		.l	pystep	+16
*
*	exit:	none
*
*
_gr_scale:
	movem.l d4-d7/a4-a6,-(sp)	;+28 we need regs!
*
	movem.l	28+4(sp),d7/a4-a6	;d7[31:16] = xdist; d7[15:00] = ydist
*					;a4 -> *pcnt
*					;a5 -> *pxstep
*					;a6 -> *pystep
*
	move.w	d7,d6			;d6 = ydist
	swap	d7			;d7 = xdist
*
	move.w	#1,-(sp)		;+30 parm 1 BLACK
	jsr	_gr_setup		;    gr_setup(BLACK)
	addq.l	#2,sp			;+28
*
*   This C code:
*		   dist = (xdist + ydist) / 2;
*
*		   for (i=0; dist; i++)
*		     dist /= 2;
*
*   is equivalent to the following 6 instructions:
*
	move.w	d7,d4			;d4 = xdist
	add.w	d6,d4			;d4 = xdist + ydist
	moveq	#-1,d5			;i = -1 (will go thru loop once)
lab9:
	addq.w	#1,d5			;i++
	lsr.w	#1,d4			;dist /= 2
	bne	lab9
*
lab6:
	moveq	#1,d0			;d0 = value for *pxstep
	moveq	#1,d1			;d1 = value for *pystep
*
	move.w	d5,(a4)			;*pcnt = i
	beq	lab10			;br if(*pcnt = i) is false =0
*
	ext.l	d7
	divs	d5,d7			;d7 = xdist / i
*
	cmp.w	d7,d0
	bge	d0bigr1
	move.w	d7,d0			;d0 = max(1, xdist / i)
d0bigr1:
	ext.l	d6
	divs	d5,d6			;d6 = ydist / i
*
	cmp.w	d6,d1
	bge	d0bigr2
	move.w	d6,d1			;d1 = max(1, ydist / i)
d0bigr2:
*
*  else..
*
lab10:
	move.w	d0,(a5)			;save value for pxstep
	move.w	d1,(a6)			;save value for pystep
*
	movem.l (sp)+,d4-d7/a4-a6
	rts
*
*
*
*	gr_watchbox
*
*
*
*	locals:	.w  t   g_x		-32
*		.w	g_y		-30
*		.w	g_w		-28
*		.w	g_h		-26
*
*  reserves:	.l	preserved d4	-24
*		.l	preserved d5	-20
*		.l	preserved d6	-16
*		.l	preserved d7	-12
*		.l	preserved a5	-8
*		.l	preserved a6	-4
*
*				offset from sp at entry
*	entry:	.l	tree		+4
*		.w	obj		+8
*		.w	instate		+10
*		.w	outstate	+12
*
*	exit:	d0 = out
*
*
*
*
	.globl _gr_watch
*
*
_gr_watch:
	movem.l	d2-d7/a5-a6,-(sp)	;+32 reserve 8 bytes & d4-d7/a5-a6
	lea	32+4(sp),a0
	move.l	(a0)+,a5		;a5 -> tree
	move.w	(a0)+,d5		;d5.w = obj
	move.l	(a0)+,d6		;d6[31:16]=instate; d6[15:00]=outstate
	move.l	sp,a6			;a6 = &t
*
	move.l	ez_glrsr+2(pc),-(sp)	;+36 pick this up from previous use
	jsr	_gsx_scl		;gsx_sclip(&gl_rscreen)
*
	move.l	a6,-(sp)		;+40 parm 3 &t
	move.w	d5,-(sp)		;+42 parm 2 obj
	move.l	a5,-(sp)		;+46 parm 1 tree
*
	jsr	_ob_actx		;ob_actxywh(tree,obj,&t)
*
	moveq	#0,d7			;out = FALSE
	moveq	#1,d4			;d4  = TRUE (constant)
*
*     do...while
*
lab50:
	swap	d6			;d6.w = instate or outstate alternately
	move.w	d4,-(sp)		;+48 parm 4 TRUE
	move.w	d6,-(sp)		;+50 parm 3 state (in/out)
	move.w	d5,-(sp)		;+52 parm 2 obj
	move.l	a5,-(sp)		;+56 parm 1 &tree
*
	jsr	_ob_chan		;ob_change(tree, obj, state, TRUE)
*
	eor.w	d4,d7			;out = !out
*
	addq.l	#4,a6			;a6 -> t->g_w
	move.l	(a6),-(sp)		;+60 parms 4 5  t.g_w, t.g_h
	move.l	-(a6),-(sp)		;+64 parms 2 3  t.g_x, t.g_y
	move.w	d7,-(sp)		;+66 parm 1 out
*
	jsr	_gr_still		;gr_still(out,t.g_x,t.g_y,t.g_w,t.g_h)
	adda.w	#20,sp			;+46
	tst.w	d0
	bne	lab50			;while(gr_still());
*
	move.w	d7,d0			;return(out)
	adda.w	#22,sp			;+24
	movem.l	(sp)+,d4-d7/a5-a6	;+0
	rts
*
*
*
*
*  gr_stilldn
*
*  Routine to watch the mouse while the button is down
*  and it stays inside/outside of the specified rectangle.
*  Return TRUE as long as the mouse is down.  Block until the
*  mouse moves into or out of the specified rectangle.
*
*	temps	.w	rets[0]	-12
*		.w	rets[1]	-10
*		.w	rets[2]	-8
*		.w	rets[3]	-6
*		.w	rets[4]	-4
*		.w	rets[5]	-2
*
*	entry:	.w	out	+4
*		.w	x	+6
*		.w	y	+8
*		.w	w	+10
*		.w	h	+12
*
*	exit:	d0.w	= 1 (true)	=0 (false)
*
*_gr_still:
	suba.w	#12,sp		;+12 make room on stack for 6 words: &rets[6]
	move.l	sp,-(sp)	;+16 parm 7 &rets[0]
	clr.l	-(sp)		;+20 parm 6 0x0L
	move.l	#$10100,-(sp)	;+24 parm 5 0x00010100L
	clr.l	-(sp)		;+28 parm 4 0x0L
	clr.l	-(sp)		;+32 parm 3 NULLPTR
	pea	32+4(sp)	;+36 parm 2 &out
	move.w	#6,-(sp)	;+38 parm 1 MU_BUTTON | MU_M1
*
	jsr	_ev_mult	;event multi
*
	adda.w	#38,sp		;restore stack
*
	lsr.w	#1,d0		;shift bit 1 (MU_BUTTON) to bit 0
	not.w	d0		;return FALSE if MU_BUTTON TRUE
	andi.w	#$1,d0		;else, return TRUE
*
	rts
*
*
*
*
*
*
	.globl _gr_draw
*
*
*
*				offset from sp at entry
*	locals:	.w  t	t.g_x		-20
*		.w	t.g_y		-18
*		.w	t.g_y		-16
*		.w	t.g_y		-14
*
*    reserves:	.l	preserved d7	-12
*		.l	preserved a4	-8
*		.l	preserved a5	-4
*
*	entry:	.w	have2box	+4
*		.l	po		+6
*		.l	poff		+10
*
*	exit:	none
*
*
*
_gr_draw:
	movem.l	d0-d1/d7/a4-a5,-(sp)	;+20 save d7/a4-a5 & reserve 8 bytes
	movem.l	20+2(sp),d7/a4-a5
*					;d7[31:16]=garbage; d7[15:00]=have2box
*					;a4 = &po
*					;a5 = &poff
*
	move.l	a4,-(sp)		;+24
	jsr	_gsx_xbo		;gsx_xbox(po);
	tst.w	d7			;is have2box TRUE
	beq	lab21			;br if FALSE
*
	lea	24-20(sp),a0		;a0 -> t
	move.l	a0,-(sp)		;+28 parm 1 for gsx_xbox
*
	moveq	#3,d1			;do x, y, w, & h
rsetquik:
	move.w	(a5)+,d0		;d0 = poff->g_x
	add.w	(a4)+,d0		;d0 = poff->g_x + po->g_x
	move.w	d0,(a0)+		;install in t
	dbra	d1,rsetquik
*
	jsr	_gsx_xbo		;use &t from previous
	addq.l	#4,sp			;+24
lab21:
	adda.w	#12,sp			;+12
	movem.l (sp)+,d7/a4-a5		;+0
	rts
*
*
*  Local routine for gr_wait
*
*  We do this in-line twice so instead let's call a subroutine twice:
*
ofdrawon:
	jsr	_gsx_mof		;gsx_moff()
*
	move.l	a4,-(sp)		;parm3 poff
	move.l	a5,-(sp)		;parm2 po
	move.w	d7,-(sp)		;parm1 have2box
*
	bsr	_gr_draw		;gr_draw(have2box, po, poff)
	adda.w	#10,sp
*
	bra	_gsx_mon		;return thru gsx_mon()
*
*
*
*
	.globl _gr_wait
*
*
*
*
*
*				offset from sp at entry
*
*	entry:	.l	po		+4
*		.l	poff		+8
*		.w	mx		+12
*		.w	my		+14
*
*	exit:	d0 = down
*
*
_gr_wait:
	movem.l	d5-d7/a4-a5,-(sp)	;+20
	movem.l	20+4(sp),d5/a4-a5	;a5 -> &po
	exg	d5,a5			;a4 -> &poff
*					;d5[31:16] = mx; d5[15:00] = my
*
	move.l	a4,-(sp)		;+24 parm 2 poff
ez_glr0:
*		;note: immed "gl_rzero" ref'd elsewhere via ez_glr0+2(pc)
	move.l	#_gl_rzero,-(sp)	;+28 parm 1 &gl_rzero
	jsr	_rc_equa		;
*
	bchg.l	#0,d0			;invert boolean result
	move.w	d0,d7			;have2box = !rc_equal(&gl_zero, poff)
*
	bsr	ofdrawon		
*
	moveq	#1,d0			;get a "1" or TRUE parm
	move.w	d0,-(sp)		;+30 parm 5 "1"
	move.w	d0,-(sp)		;+32 parm 4 "1"
	move.l	d5,-(sp)		;+36 parms 2, 3  mx, my
	move.w	d0,-(sp)		;+38 parm 1  TRUE
	jsr	_gr_still
*
	move.w	d0,d6			;d6=down = gr_stilldn(TRUE,mx,my,1,1)
*
	bsr	ofdrawon
*
	move	d6,d0			;    return(down)
	adda.w	#18,sp			;+20 adjust stack
	movem.l (sp)+,d5-d7/a4-a5	;+0
	rts
*
*
*
	.globl _gr_setup
*
*	entry:	.w	color	+4
*
*	exit:	none
*
*
_gr_setup:
ez_glrsr:
	move.l	#_gl_rscreen,-(sp)	;+4  parm 1 &gl_rscreen
	jsr	_gsx_scl		;    gsx_sclip(&gl_rscreen);
*
	move.w	4+4(sp),(sp)		;+4  parm 3 color
	moveq	#3,d0			;d0[31:16]=0=FALSE,d0[15:00]=3=MD_XOR
	move.l	d0,-(sp)		;+8 parm 1 FALSE : parm 2 MD_XOR
	jsr	_gsx_att		;    gsx_attr(FALSE, MD_XOR, color);
	addq.l	#8,sp
	rts
*
*
*
*
*
*
*	gr_rubbox
*
*
*
*   Stretch the free corner of a XOR box(w,h) that is pinned at
*   another corner based on mouse movement until the button comes
*   up.  This is also called a rubber-band box.
*
*
	.globl _gr_rubbo
*
*				offset from sp at entry
*
*		
*
*		.l	RETURN		+0
*	entry:	.w	xorigin		+4
*		.w	yorigin		+6
*		.w	wmin		+8
*		.w	hmin		+10
*		.l	pwend		+12
*		.l	phend		+16
*
*	exit:	none
*
_gr_rubbo:
	lea	16(sp),a0	;a0 -> phend
	move.l	(a0),-(sp)	;+4 parm 7 phend
	move.l	-(a0),-(sp)	;+8 parm 6 pwend
	move.l	ez_glr0+2(pc),-(sp) ;+12 parm 5 &_gl_rzero
	move.l	-(a0),-(sp)	;+16 parms 4 3 hmin    wmin
	move.l	-(a0),-(sp)	;+20 parms 2 1 yorigin xorigin
	bsr	_gr_rubwind	;gr_rubwind
	adda.w	#20,sp
	rts
*
*
*
*
*   gr_rubwind
*
*
*   Stretch the free corner of an XOR box(w,h) that is pinned at
*   another corner based on mouse movement until the button comes
*   up.  Also draw a second box offset from the stretching box.
*
*
	.globl _gr_rubwind
*
*	locals:	.w   o  o.g_x		-32
*		.w	o.g_y		-30
*		.w	o.g_w		-28
*		.w	o.g_h		-26
*
*  reserves:	.l	preserved d5	-24
*		.l	preserved d6	-20
*		.l	preserved a3	-16
*		.l	preserved a4	-12
*		.l	preserved a5	-8
*		.l	preserved a6	-4
*
*
*				offset from sp at entry
*	entry:	.w	xorigin		+4
*		.w	yorigin		+6
*		.w	wmin		+8
*		.w	hmin		+10
*		.l	poff		+12
*		.l	pwend		+16
*		.l	phend		+20
*
*	exit:	none
*
_gr_rubwind:
	movem.l	d3-d6/a3-a6,-(sp) ;+32 reserve 8 bytes of local & d5-d6/a3-a6
	move.w	#1,-(sp)	;+34 parm 1 TRUE
	jsr	_wm_upda	;wm_updat(TRUE)
*
	bsr	_gr_setup	;gr_setup(BLACK)  black is true!
*
	movem.l	34+4(sp),d5-d6/a4-a6 ;d5[31:16] = xorigin; d5[15:00] = yorigin
*				  ;d6[31:16] = wmin; d6[15:00] = hmin
*				  ;a4 = &poff
*				  ;a5 = &pwend
*				  ;a6 = &phend
*
*  the following is equivalent to:
*	r_set(&o, xorigin, yorigin, 0, 0)
*
*
	lea	34-32(sp),a3	;a3 -> o
	move.l	a3,a0		;a0 -> o
	move.l	d5,(a0)+	;o.g_x = xorigin; o.g_y = yorigin; 
	clr.w	(a0)+		;o.g_w = 0
	clr.w	(a0)		;o.g_h = 0
*
lab26:
	lea	6(a3),a0	;a0 -> o.g_h
	move.l	a0,-(sp)	;+38 parm 6 &o.g_h
	subq.l	#2,a0
	move.l	a0,-(sp)	;+42 parm 5 &o.g_w
	move.l	d6,-(sp)	;+46 parm 4 hmin; parm 3 wmin
	move.l	-(a0),-(sp)	;+50 parm 1 o.g_x; parm 2 o.g_y
*
	jsr	_gr_clamp	;gr_clanp(o.g_x, o.g_y, wmin, hmin, &o.g_w,
*				;		&o.g_h);
*
	moveq	#1,d1		;do for heigth then width
wdhtlp:
	move.w	50-30(sp),d0	;d0 = o.g_y
	add.w	50-26(sp),d0	;d0 = o.g_y + o.g_h
	subq.w	#1,d0		;d0 = o.g_y + o.g_h - 1
	move.w	d0,-(sp)	;+52 +54 parm 4 then parm 3
*
	dbra	d1,wdhtlp
*				;+54
	move.l	a4,-(sp)	;+58 parm 2 &poff
	move.l	a3,-(sp)	;+62 parm 1 &o
*
	jsr	_gr_wait	
*
	adda.w	#28,sp		;+34 adjust stack for loop
	tst.w	d0		;d0 = result "down"
	bne	lab26		;while(down)
*
	addq.l	#4,a3		;a3 -> o.g_w
	move.w	(a3)+,(a5)	;*pwend = o.g_w
	move.w	(a3),(a6)	;*phend = o.g_h
*
	clr.w	-(sp)		;+36 parm 1 FALSE
	jsr	_wm_upda	;wm_updat(FALSE)
	adda.w	#12,sp		;+24 adjust stack
	movem.l	(sp)+,d5-d6/a3-a6	;+0
	rts
*
*
*
*
*	gr_dragbox
*
*	Drag a moving XOR box(w,h) that tracks relative to the mouse
*	until the button comes up.  The starting x and y represent
*	the location of the upper left hand corner of the rectangle
*	relative to the mouse position.  This relative distance should
*	be maintained.  A constraining rectangle is also given.  The
*	box should not be able to be dragged out of the contraining
*	rectangle.
*
*
	.globl _gr_dragbox
*
*
*
*	locals:	.w	mx		-36
*		.w	my		-34
*
*		.w   o  o.g_x		-32
*		.w	o.g_y		-30
*		.w	o.g_w		-28
*		.w	o.g_h		-26
*
*		.w	offx		-24
*		.w	offy		-22
*
*  reserves:	.l	preserved d6	-20
*		.l	preserved d7	-16
*		.l	preserved a4	-12
*		.l	preserved a5	-8
*		.l	preserved a6	-4
*
*				offset from sp at entry
*	entry:	.w	w		+4
*		.w	h		+6
*		.w	sx		+8
*		.w	sy		+10
*		.l	*pc		+12
*		.l	*pdx		+16
*		.l	*pdy		+20
*
*	exit:	none
*
*
*
_gr_dragbox:
	movem.l	d2-d7/a4-a6,-(sp)	;+36 reserve 20 bytes & d6-d7/a4-a6 
	movem.l	36+4(sp),d6-d7/a4-a6	;d6[31:16] = w; d6[15:00] = h
*					;d7[31:16] = sx; d7[15:00] = sy
*					;a4 = &pc
*					;a5 = &pdx
*					;a6 = &pdy
*
	move.w	#1,-(sp)		;+38 parm 1 BLACK
	jsr	_wm_upda		;wm_update(BLACK)
	jsr	_gr_setup		;gr_setup(TRUE) black = true
*
*
	
	lea	38-32(sp),a0		;a0 => o
*
	move.l	d7,(a0)+	;r_set(&o, sx, sy, w, h);
	move.l	d6,(a0)+
*
	addq.l	#2,a0			;a0 -> offy
*
	move.l	a0,-(sp)		;+42 parm 6 &offy
	subq.l	#2,a0
	move.l	a0,-(sp)		;+46 parm 5 &offx
	clr.l	-(sp)			;+50 parm 4, 3   0,0
*
*  the following 2 instructions are too risky 
*  (sy+1 may cross - to + or overflo afecting sx+1)...
*
*	addi.l	#$00010001,d7
*	move.l	d7,-(sp)		;+54 parm 1 sx+1 parm 2 sy+1
*
* so let's be safe with these 5..
*
	moveq	#1,d0
	add.w	d0,d7
	swap	d0
	add.l	d0,d7
	move.l	d7,-(sp)
*
	jsr	_gr_clamp	;gr_clamp(sx+1, sy+1, 0, 0, &offx, &0ffy);
*
*   get box's x,y from
*   mouse's x,y then
*   constrain result
*
lab31:
	lea	54-34(sp),a0	;a0 => my
	move.l	a0,-(sp)	;+58 parm 2 &my
	subq.l	#2,a0
	move.l	a0,-(sp)	;+62 parm 1 &mx
*
	jsr	_gsx_mxm	;gsx_mxmy(&mx, &my)
*
	move.l	(sp)+,a0	;+58 a0 => mx
*
	move.w	(a0)+,d0	;d0 = mx
	sub.w	58-24(sp),d0	;d0 = mx - offx
*
	move.w	(a0)+,d1	;d1 = my
	sub.w	58-22(sp),d1	;d1 = my - offy
*
	move.w	d0,(a0)+	;o.g_x = mx - offx
	move.w	d1,(a0)		;o.g_y = my - offy
*
	subq.l	#2,a0
	move.l	a0,-(sp)	;+62 parm 2 &o
*
	move.l	a4,-(sp)	;+66 parm 1 &pc
	jsr	_rc_cons	;rc_constrain(pc, &o)
*
	lea	66-36(sp),a0	;a0 => mx
	move.l	(a0)+,-(sp)	;+70 parm 3 mx  parm 4 my
	move.l	ez_glr0+2(pc),-(sp)	;+74 parm 2 &gl_rzero
	move.l	a0,-(sp)	;+78 parm 1 &o
*
	jsr	_gr_wait	;gr_wait(&o, &gl_rzero, mx, my)
	adda.w	#24,sp		;+54 adjust stack for loop
	tst.w	d0
	bne	lab31
*
	move.w	54-32(sp),(a5)	;*pdx = o.g_x
*
	move.w	54-30(sp),(a6)	;*pdy = o.g_y
*
	clr.w	-(sp)		;+56
	jsr	_wm_upda	; wm_update(FALSE)
*
	adda.w	#36,sp		;+20
	movem.l	(sp)+,d6-d7/a4-a6	;+0
	rts
*
*
*
*
*
*  This routine belongs to gr_clamp, below
*					;+16
maxit0:
	move.w	16-4(sp,d2.w),d0	;d0 = mx
	sub.w	16+4(sp,d2.w),d0	;d0 = mx - xorigin
	addq.w	#1,d0			;d0 = mx - xorigin +1
	move.w	16+8(sp,d2.w),d1	;d1 = wmin
	cmp.w	d1,d0		;is wmin larger than (mx - xorigin + 1)?
	bge	d0bigger		;br if d0 is max
	move.w	d1,d0			;else use wmin
d0bigger:
	move.l	(a0)+,a1		;get &pneww or &pnewh 
	move.w	d0,(a1)			;save max in pneww/pnewh
	rts
*
*
	.globl _gr_clamp
*
*
*				offset from sp at entry
*	temps:	.w	mx	-4
*		.w	my	-2
*
*	entry:	.w	xorigin	+4
*		.w	yorigin	+6
*		.w	wmin	+8
*		.w	hmin	+10
*		.l	pneww	+12
*		.l	pnewh	+16
*
*	exit:	none
*
*
*
_gr_clamp:
	subq.l	#4,sp		;+4  make room on stack for local mx, my
	pea	4-2(sp)		;+8  parm 2 &my
	pea	8-4(sp)		;+12 parm 1 &mx
*
	jsr	_gsx_mxm	;  gsx_mxmy(&mx, &my)
*
	lea	12+12(sp),a0	;a0 => &pneww
*
	moveq	#0,d2		;start with mx / xorigin / wmin / *pneww
	bsr	maxit0		;*pneww = max(mx - xorigin + 1, wmin)
*
	moveq	#2,d2		;now with my / yorigin / hmin / *pnewh
	bsr	maxit0
*
	adda.w	#12,sp
	rts

*
*
*
*
*
*				offset from sp at entry
*	entry:	.l	pmx		+4
*		.w	pmy		+8
*		.w	pmstat		+12
*		.w	pkstat		+16
*
*	exit:	none
*
*
	.globl _gr_mksta
*
*
_gr_mksta:
	lea	mklist(pc),a0	;2
	lea	4(sp),a1	;4
	moveq	#3,d0		;5
mkstatlp:
	move.l	(a0)+,a2	;6
	move.w	(a2),d1		;7
	move.l	(a1)+,a2	;8
	move.w	d1,(a2)		;9
	dbra	d0,mkstatlp	;11
	rts			;12
*
*
*
mklist:
	.dc.l	_xrat
	.dc.l	_yrat
	.dc.l	_button
	.dc.l	_kstate
*



*\*	GEMGRLIB.C	4/11/84 - 01/07/85	Gregg Morris		*\
*\*	Reg Opt		03/08/85 - 04/26/85	Derek Mui		*\
*
*\*
**	-------------------------------------------------------------
**	GEM Application Environment Services		  Version 1.1
**	Serial No.  XXXX-0000-654321		  All Rights Reserved
**	Copyright (C) 1985			Digital Research Inc.
**	-------------------------------------------------------------
**\
*
*#include <portab.h>
*#include <machine.h>
*#include <struct88.h>
*#include <baspag88.h>
*#include <obdefs.h>
*#include <gemlib.h>
*						/* in GSX.EXE		*\
*EXTERN VOID	gsx_moff();
*EXTERN VOID	gsx_mon();
*
*EXTERN GRECT	gl_rscreen;
*EXTERN GRECT	gl_rzero;
*
*EXTERN WORD	xrat, yrat, button, kstate;
*
*\*
**	Routine to watch the mouse while the button is down and
**	it stays inside/outside of the specified rectangle.
**	Return TRUE as long as the mouse is down.  Block until the
**	mouse moves into or out of the specified rectangle.
**\
*
*	WORD
*gr_stilldn(out, x, y, w, h)
*	WORD		out, x, y, w, h;
*{
*	WORD		rets[6];
*					/* compiler had better	*\
*					/*   put the values out,*\
*					/*   x, y, w, h in the	*\
*					/*   right order on the	*\
*					/*   stack to form a	*\
*					/*   MOBLK		*\
*	if ( MU_BUTTON & ev_multi(MU_BUTTON | MU_M1, &out, NULLPTR, 0x0L,
*			0x00010100L, 0x0L, &rets[0]) )	/* 01ff00L *\
*	  return(FALSE);
*	return(TRUE);
*} /* gr_stilldn *\
*
*
*gr_setup(color)
*	WORD		color;
*{
*	gsx_sclip(&gl_rscreen);
*	gsx_attr(FALSE, MD_XOR, color);
*}
*
*
*gr_clamp(xorigin, yorigin, wmin, hmin, pneww, pnewh)
*	WORD		xorigin, yorigin;
*	WORD		wmin, hmin;
*	WORD		*pneww, *pnewh;
*{
*	WORD		mx, my;
*
*	gsx_mxmy(&mx, &my);
*	*pneww = max(mx - xorigin + 1, wmin);
*	*pnewh = max(my - yorigin + 1, hmin);
*}
*
*
*gr_scale(xdist, ydist, pcnt, pxstep, pystep)
*	REG WORD		xdist, ydist;
*	WORD		*pcnt;
*	REG WORD		*pxstep, *pystep;
*{
*	REG WORD		i;
*	REG WORD		dist;
*
*
*	gr_setup(BLACK);
*
*	dist = (xdist + ydist) / 2;
*
*	for(i=0; dist; i++)
*	  dist /= 2;
*
*	if (*pcnt = i)
*	{
*	  *pxstep = max(1, xdist / i);
*	  *pystep = max(1, ydist / i);
*	}
*	else
*	  *pxstep = *pystep = 1;
*}
*
*
*gr_stepcalc(orgw, orgh, pt, pcx, pcy, pcnt, pxstep, pystep)
*	WORD		orgw, orgh;
*	REG GRECT		*pt;
*	REG WORD		*pcx, *pcy;
*	WORD		*pcnt, *pxstep, *pystep;
*{
*	*pcx = (pt->g_w/2) - (orgw/2);
*	*pcy = (pt->g_h/2) - (orgh/2);
*
*	gr_scale(*pcx, *pcy, pcnt, pxstep, pystep);
*
*	*pcx += pt->g_x;
*	*pcy += pt->g_y;
*}
*
*
*gr_xor(clipped, cnt, cx, cy, cw, ch, xstep, ystep, dowdht)
*	WORD		clipped;
*	WORD		cnt;
*	WORD		cx, cy, cw, ch;
*	REG WORD		xstep, ystep;
*	WORD		dowdht;
*{
*	do
*	{
*	  if (clipped)
*	    gsx_xcbox(&cx);
*	  else
*	    gsx_xbox(&cx);
*	  cx -= xstep;
*	  cy -= ystep;
*	  if (dowdht)
*	  {
*	    cw += (2 * xstep);
*	    ch += (2 * ystep);
*	  }
*	} while (cnt--);
*}
*
*
*	VOID
*gr_draw(have2box, po, poff)
*	WORD		have2box;
*	REG GRECT		*po;
*	REG GRECT		*poff;
*{
*	GRECT		t;
*
*	gsx_xbox(po);
*	if (have2box)
*	{
*	  r_set(&t, po->g_x + poff->g_x, po->g_y + poff->g_y,
*		      po->g_w + poff->g_w, po->g_h + poff->g_h );
*	  gsx_xbox(&t);
*	}
*}
*
*
*	WORD
*gr_wait(po, poff, mx, my)
*	REG GRECT		*po;
*	REG GRECT		*poff;
*	WORD		mx, my;
*{
*	REG WORD		have2box;
*	REG WORD		down;
*
*	have2box = !rc_equal(&gl_rzero, poff);
*						/* draw old		*\
*	gsx_moff();
*	gr_draw(have2box, po, poff);
*	gsx_mon();
*						/* wait for change	*\
*	down = gr_stilldn(TRUE, mx, my, 1, 1);
*						/* erase old		*\
*	gsx_moff();
*	gr_draw(have2box, po, poff);
*	gsx_mon();
*						/* return exit event	*\
*	return(down);
*}
*
*
*\*
**	Stretch the free corner of an XOR box(w,h) that is pinned at
**	another corner based on mouse movement until the button comes
**	up.  Also draw a second box offset from the stretching box.
**\
*
*	VOID
*gr_rubwind(xorigin, yorigin, wmin, hmin, poff, pwend, phend)
*	WORD		xorigin, yorigin;
*	WORD		wmin, hmin;
*	GRECT		*poff;
*	WORD		*pwend, *phend;
*{
*	WORD		have2box, down;
*	GRECT		o;
*
*	wm_update(TRUE);
*	gr_setup(BLACK);
*
*	r_set(&o, xorigin, yorigin, 0, 0);
*						/* clamp size of rubber	*\
*						/*   box to no smaller	*\
*						/*   than wmin, hmin	*\
*	do
*	{
*	  gr_clamp(o.g_x, o.g_y, wmin, hmin, &o.g_w, &o.g_h);
*	  down = gr_wait(&o, poff, o.g_x+o.g_w-1, o.g_y+o.g_h-1);
*	} while (down);
*	*pwend = o.g_w;
*	*phend = o.g_h;
*	wm_update(FALSE);
*} /* gr_rubwind *\
*
*
*
*\*
**	Stretch the free corner of a XOR box(w,h) that is pinned at
**	another corner based on mouse movement until the button comes
**	up.  This is also called a rubber-band box.
**\
*	VOID
*gr_rubbox(xorigin, yorigin, wmin, hmin, pwend, phend)
*	WORD		xorigin, yorigin;
*	WORD		wmin, hmin;
*	WORD		*pwend, *phend;
*{
*	gr_rubwind(xorigin, yorigin, wmin, hmin, &gl_rzero, pwend, phend);
*}
*
*
*
*\*
**	Drag a moving XOR box(w,h) that tracks relative to the mouse
**	until the button comes up.  The starting x and y represent
**	the location of the upper left hand corner of the rectangle
**	relative to the mouse position.  This relative distance should
**	be maintained.  A constraining rectangle is also given.  The
**	box should not be able to be dragged out of the contraining
**	rectangle.
**\
*	VOID
*gr_dragbox(w, h, sx, sy, pc, pdx, pdy)
*	WORD		w, h;
*	REG WORD		sx, sy;
*	GRECT		*pc;
*	WORD		*pdx, *pdy;
*{
*	WORD		offx, offy, down;
*	GRECT		o;
*	WORD		mx, my;
*
*
*	wm_update(TRUE);
*	gr_setup(BLACK);
*
*	gr_clamp(sx+1, sy+1, 0, 0, &offx, &offy);
*	r_set(&o, sx, sy, w, h);
*
*						/* get box's x,y from	*\
*						/*   mouse's x,y then	*\
*						/*   constrain result	*\
*	do
*	{
*	  gsx_mxmy(&mx, &my);
*	  o.g_x = mx - offx;
*	  o.g_y = my - offy;
*	  rc_constrain(pc, &o);
*	  down = gr_wait(&o, &gl_rzero, mx, my);
*	} while (down);
*	*pdx = o.g_x;
*	*pdy = o.g_y;
*	wm_update(FALSE);
*} /* gr_dragbox *\
*
*
*\*
**	Draw a moving XOR box(w,h) that moves from a point whose upper
**	left corner is at src_x, src_y to a point at dst_x, dst_y
**\
*	VOID
*gr_movebox(w, h, srcx, srcy, dstx, dsty)
*	WORD		w, h;
*	REG WORD		srcx, srcy;
*	WORD		dstx, dsty;
*{
*	REG WORD		i;
*	REG WORD		signx, signy;
*	WORD		cnt, xstep, ystep;
*
*	signx = (srcx < dstx) ? -1 : 1;
*	signy = (srcy < dsty) ? -1 : 1;
*
*	gr_scale(signx*(srcx-dstx), signy*(srcy-dsty), &cnt, &xstep, &ystep);
*
*	gsx_moff();
*	for (i=0; i<2; i++)
*	  gr_xor(FALSE, cnt, srcx,srcy, w,h, signx*xstep, signy*ystep, FALSE);
*	gsx_mon();
*} /* gr_movebox *\
*
*
*\*
**	Draw an small box that moves from the origin x,y to a spot
**	centered within the rectangle and then expands to match the
**	size of the rectangle.
**\
*
*	VOID
*gr_growbox(po, pt)
*	REG GRECT		*po;
*	GRECT		*pt;
*{
*	REG WORD		i;
*	WORD		cx, cy;
*	WORD		cnt, xstep, ystep;
*
*	gr_stepcalc(po->g_w, po->g_h, pt, &cx, &cy, &cnt, &xstep, &ystep);
*	gr_movebox(po->g_w, po->g_h, po->g_x, po->g_y, cx, cy);
*	gsx_moff();
*	for (i=0; i<2; i++)
*	  gr_xor(TRUE, cnt, cx, cy, po->g_w, po->g_h, xstep, ystep, TRUE);
*	gsx_mon();
*} /* gr_growbox *\
*
*
*\*
**	Draw a box that shrinks from the rectangle given down around
**	a small box centered within the rectangle and then moves to the
**	origin point.
**\
*	VOID
*gr_shrinkbox(po, pt)
*	REG GRECT		*po;
*	REG GRECT		*pt;
*{
*	REG WORD		i;
*	WORD		cx, cy;
*	WORD		cnt, xstep, ystep;
*
*	gr_stepcalc(po->g_w, po->g_h, pt, &cx, &cy, &cnt, &xstep, &ystep);
*	gsx_moff();
*	for (i=0; i<2; i++)
*	  gr_xor(TRUE, cnt, pt->g_x, pt->g_y, pt->g_w, pt->g_h, 
*			-xstep, -ystep, TRUE);
*	gsx_mon();
*	gr_movebox(po->g_w, po->g_h, cx, cy, po->g_x, po->g_y);
*} /* gr_shrinkbox *\
*
*
*
*	WORD
*gr_watchbox(tree, obj, instate, outstate)
*	REG LONG		tree;
*	REG WORD		obj;
*	WORD		instate;
*	WORD		outstate;
*{
*	REG WORD		out;
*	REG WORD		state;
*	GRECT		t;
*
*	gsx_sclip(&gl_rscreen);
*	ob_actxywh(tree, obj, &t);
*	
*	out = FALSE;
*	do
*	{
*	  state = (out) ? outstate : instate;
*	  ob_change(tree, obj, state, TRUE);
*	  out = !out;
*	} while( gr_stilldn(out, t.g_x, t.g_y, t.g_w, t.g_h) );
*
*	return( out );
*}
*
*\*   CHANGED	*\
*	WORD
*gr_slidebox(tree, parent, obj, isvert)
*	REG LONG		tree;
*	WORD		parent;
*	WORD		obj;
*	WORD		isvert;
*{
*	REG GRECT	*pt, *pc;	/* new pointer for Reg Opt	*\
*	GRECT		t, c;
*	REG WORD		divnd, divis;
*
*	pt = &t;
*	pc = &c;
*
*	ob_actxywh(tree, parent, pc);
*	ob_relxywh(tree, obj, pt);
*\*	gr_dragbox(t.g_w, t.g_h, t.g_x + c.g_x, t.g_y + c.g_y, 
*			&c, &t.g_x, &t.g_y); 	*\
*
*	gr_dragbox(pt->g_w, pt->g_h, pt->g_x + pc->g_x, pt->g_y + pc->g_y, 
*			pc, &pt->g_x, &pt->g_y); 
*
*	if ( isvert )
*	{
*	  divnd = pt->g_y - pc->g_y;
*	  divis = pc->g_h - pt->g_h;
*	}
*	else
*	{
*	  divnd = pt->g_x - pc->g_x;
*	  divis = pc->g_w - pt->g_w;
*	}
*	if (divis)
*	  return( mul_div( divnd, 1000, divis) );
*	else
*	  return(0);
*}
*
*
*	VOID
*gr_mkstate(pmx, pmy, pmstat, pkstat)
*	WORD		*pmx, *pmy, *pmstat, *pkstat;
*{
*	*pmx = xrat;
*	*pmy = yrat;
*	*pmstat = button;
*	*pkstat = kstate;
*}
*

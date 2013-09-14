********************************************************
*
*	DEBUG.S
*
	.include	"equates.s"
*
*
*  test routine to allow debugger to view other buffers
*
*
*
view:
	movem.l	d0-d7/a0-a6,-(sp)
*
	move.w	#2,-(sp)
	trap	#14		;get current physical screen
	addq.l	#2,sp
*
	move.l	d0,screenx	;save base addr
*
	move.l	altscre,d0		;have we allocated before?
	bne	waitkey
*
	move.l	#153600+256,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp		;get memory if available
*
	tst.l	d0
	beq	viewq		;br if not enough memory avail
*
	addi.l	#255,d0
	clr.b	d0

	move.l	d0,altscre
*
*
waitkey:
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13		;conin
	addq.l	#4,sp
*
	tst.w	d0		;did we get func key
	beq	gotfunc
	cmpi.b	#" ",d0
	beq	viewq
	bra	waitkey
gotfunc:
	swap	d0
	subi.w	#$3b,d0		;func1
	bcs	waitkey
	move.w	d0,which
	cmpi.w	#7,d0
	bcc	waitkey
*
	tst.w	d0		;are we asking for original screen?
	beq	upscre		;br if so
*
*  f1 = original screen
*  f2 = world mask
*  f3 = world
*  f4 = curbrush mask
*  f5 = curbrush
*  f6 = latest brush made (in maxderivd)
*  f7 = latest brush mask
*
*  clear alternate screen
*
	move.l	altscre,a1
	move.w	#((320*480)/16)-1,d2
	moveq	#0,d3
dovspec3:
	move.l	d3,(a1)+
	move.l	d3,(a1)+
	move.l	d3,(a1)+
	move.l	d3,(a1)+
	dbra	d2,dovspec3
*
	cmpi.w	#1,d0		;do we just want worldmsk?
	beq	dowmask		;br if so
*
	cmpi.w	#2,d0
	beq	dowgraf		;let's see the world
*
	cmpi.w	#3,d0
	beq	dobmask
*
	cmpi.w	#4,d0
	beq	dobgraf
*
	cmpi.w	#5,d0
	beq	anybsh
*
*  any brush mask
*
	lea	bshmblk,a6
	move.w	#4,plane_ct(a6)
	move.w	#15,fg_col(a6)
	move.w	#0,bg_col(a6)
*
	move.l	altscre,d_form(a6)
	lea	bshblock,a2

*	move.w	bsh,d0
	move.w	maxderivd,d0
*	cmp.w	maxderivd,d0
*	bhi	waitkey

	lsl.w	#4,d0
	adda.w	d0,a2
	movem.w	(a2)+,d0-d1
	movem.w	d0-d1,b_width(a6)
	move.w	#640,d2
	sub.w	d0,d2
	lsr.w	#1,d2
	move.w	d2,d_xmin(a6)
	move.w	#480,d2
	sub.w	d1,d2
	lsr.w	#1,d2
	move.w	d2,d_ymin(a6)
	move.l	(a2)+,a0
	addq.l	#4,a2
	adda.w	(a2)+,a0
	move.l	a0,s_form(a6)
	move.w	(a2)+,d0
	lsr.w	#2,d0
	move.w	d0,s_nxln(a6)
*
	dc.w	bitblt
*
	bra	upscre	
*
*
*
anybsh:
*
*  any brush mask
*
	lea	bshblk,a6
	move.w	#4,plane_ct(a6)
*
	move.l	altscre,d_form(a6)
	lea	bshblock,a2
*	move.w	bsh,d0
	move.w	maxderivd,d0
*	cmp.w	maxderivd,d0
*	bhi	waitkey

	lsl.w	#4,d0
	adda.w	d0,a2
	movem.w	(a2)+,d0-d1
	movem.w	d0-d1,b_width(a6)
	move.w	#640,d2
	sub.w	d0,d2
	lsr.w	#1,d2
	move.w	d2,d_xmin(a6)
	move.w	#480,d2
	sub.w	d1,d2
	lsr.w	#1,d2
	move.w	d2,d_ymin(a6)
	move.l	(a2)+,s_form(a6)
	addq.l	#6,a2
	move.w	(a2)+,d0
	move.w	d0,s_nxln(a6)
	lsr.w	#2,d0
	move.w	d0,s_nxpl(a6)
*
	dc.w	bitblt
*
	bra	upscre	
*
*
*
dobgraf:
	lea	brgblk,a6
	move.w	#4,plane_ct(a6)
*
	move.l	altscre,d_form(a6)
	move.w	bsh_x,d_xmin(a6)
	move.w	bsh_y,d_ymin(a6)
	move.w	bsh_wid,d0
	move.w	d0,b_width(a6)
	beq	waitkey
	move.w	bsh_hite,b_height(a6)
	beq	waitkey
	add.w	#15,d0
	andi.w	#$fff0,d0
	lsr.w	#3,d0
	move.w	d0,s_nxpl(a6)
	lsl.w	#2,d0
	move.w	d0,s_nxln(a6)
*
	dc.w	bitblt
*
	bra	upscre	

*	
dobmask:
	lea	brmblk,a6
	move.w	#4,plane_ct(a6)
	move.w	#15,fg_col(a6)
	move.w	#0,bg_col(a6)
*
	move.l	altscre,d_form(a6)
	move.w	bsh_x,d_xmin(a6)
	move.w	bsh_y,d_ymin(a6)
	move.w	bsh_wid,d0
	move.w	d0,b_width(a6)
	beq	waitkey
	move.w	bsh_hite,b_height(a6)
	beq	waitkey
*
	add.w	#15,d0
	andi.w	#$fff0,d0
	lsr.w	#3,d0
	move.w	d0,s_nxln(a6)
*
	dc.w	bitblt
*
	bra	upscre	
*
dowmask:
	lea	bblk,a6
	move.w	#4,plane_ct(a6)
	move.w	#15,fg_col(a6)
	move.w	#0,bg_col(a6)
*
	move.l	altscre,d_form(a6)
	lea	wstruct,a5
	move.w	wx(a5),d_xmin(a6)
	move.w	wy(a5),d_ymin(a6)
	move.l	worldmsk,s_form(a6)
*
	dc.w	bitblt
	bra	upscre
*	
dowgraf:
	lea	wbgblk,a6
	move.w	#4,plane_ct(a6)
*
	move.l	altscre,d_form(a6)
	lea	wstruct,a5
	move.w	wx(a5),d_xmin(a6)
	move.w	wy(a5),d_ymin(a6)
	move.l	world,s_form(a6)
*
	dc.w	bitblt
*
*
*	
upscre:
	move.w	which,d0	
	lea	screenx,a0
	tst.w	d0
	beq	wescre
*
	addq.l	#4,a0
wescre:
	move.l	(a0),a0
*
	move.w	#-1,-(sp)
	move.l	a0,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14		;put up new screen
	adda.w	#12,sp
*
	bra	waitkey
*
*
*
viewq:
	move.w	#-1,-(sp)
	move.l	screenx,-(sp)	;restore original screen
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
*
*	move.l	altscre,d0
*	beq	viewqq
*	move.l	d0,-(sp)
*	move.w	#$49,-(sp)
*	trap	#1
*	addq.l	#6,sp			;free memory if available
viewqq:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*
*
*  put out the world mask
*
bblk:
	dc.w	256,384		;wid,hite
	dc.w	0		;plane_ct
	dc.w	15,0		;fg,bg
	dc.l	$000c030f	;op_tab
*
	dc.w	0,0		;s_xmin,s_ymin
	dc.l	worldmsk	;s_form
	dc.w	2,32,0
*
	dc.w	0,0
	dc.l	0		;d_form
	dc.w	8,320,2
*
	dc.l	0		;p_addr
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	
*
*
*  put out the world grafix
*
wbgblk:
	dc.w	256,384		;wid,hite
	dc.w	0		;plane_ct
	dc.w	0,0		;fg,bg
	dc.l	$03030303	;op_tab
*
	dc.w	0,0		;s_xmin,s_ymin
	dc.l	world		;s_form
	dc.w	8,128,2
*
	dc.w	0,0
	dc.l	0		;d_form
	dc.w	8,320,2
*
	dc.l	0		;p_addr
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	
*
*
*  put out the brush mask
*
brmblk:
	dc.w	0,0		;wid,hite
	dc.w	0		;plane_ct
	dc.w	15,0		;fg,bg
	dc.l	$000c030f	;op_tab
*
	dc.w	0,0		;s_xmin,s_ymin
	dc.l	grafmsk		;s_form
	dc.w	2,0,0
*
	dc.w	0,0
	dc.l	0		;d_form
	dc.w	8,320,2
*
	dc.l	0		;p_addr
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	
*
*
*  put out the brush graphics
*
brgblk:
	dc.w	0,0		;wid,hite
	dc.w	0		;plane_ct
	dc.w	15,0		;fg,bg
	dc.l	$03030303	;op_tab
*
	dc.w	0,0		;s_xmin,s_ymin
	dc.l	grafbsh		;s_form
	dc.w	2,0,0
*
	dc.w	0,0
	dc.l	0		;d_form
	dc.w	8,320,2
*
	dc.l	0		;p_addr
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
*
*	
*
*
bshblk:
	dc.w	0,0		;wid,hite
	dc.w	0		;plane_ct
	dc.w	0,0		;fg,bg
	dc.l	$03030303	;op_tab
*
	dc.w	0,0		;s_xmin,s_ymin
	dc.l	0		;s_form
	dc.w	2,0,0
*
	dc.w	0,0
	dc.l	0		;d_form
	dc.w	8,320,2
*
	dc.l	0		;p_addr
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	
bshmblk:
	dc.w	0,0		;wid,hite
	dc.w	0		;plane_ct
	dc.w	0,0		;fg,bg
	dc.l	$03030303	;op_tab
*
	dc.w	0,0		;s_xmin,s_ymin
	dc.l	0		;s_form
	dc.w	2,0,0
*
	dc.w	0,0
	dc.l	0		;d_form
	dc.w	8,320,2
*
	dc.l	0		;p_addr
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
*	
*
*
*
screenx:
	.dc.l	0
altscre:
	.dc.l	0
*
bsh:
	.dc.w	0	;put up this brush
which:
	.dc.w	0

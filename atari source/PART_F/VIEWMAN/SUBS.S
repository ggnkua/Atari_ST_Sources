*
*	SUBS.S
*
	.include	"equates.s"
*
	.text
*
*
*
*
*
*
ctrlkey:
	movem.l	a0/d0-d4,-(sp)
	move.w	keyz,d5
	eor.w	d2,d5
	move.w	d2,keyz		;any edges
	btst.l	#LEFTSHIFT,d5	;edge on left shift?
	beq	ck0		;br if no--do nothing
*
	btst.l	#LEFTSHIFT,d2	;is left shift key down?
	bne	ck1		;br if leading edge on left shift
*
*  trailing edge on left shift--exit contain mode
*
	move.w	d2,-(sp)
	movem.w	xmin_clp,d0-d3
	movem.w	d0-d3,Mclpxmn	;set contain world motion variables
	move.w	(sp)+,d2
	bra	ck0
*
*  leading edge on left shift--enter contain mode
*
ck1:
	movem.w	d2/d5,-(sp)
*
*  request for contain function--compute new clip rectangle
*
	movem.w	xmin_clp,d0-d3	;get current motion clip
	move.w	d0,d7
*  adjust xmin_clp
	move.w	bsh_wid,d5
	subq.w	#1,d5
	sub.w	xoffset(a5),d5
	bmi	ck00
	add.w	d5,d0		;adjust xmin_clp
ck00:
*  adjust xmax_clp
	sub.w	xoffset(a5),d7
	add.w	w_wid(a5),d7
	sub.w	bsh_wid,d7
	addq.w	#1,d7		;take the smaller
	cmp.w	d7,d2
	ble	ck01
	move.w	d7,d2
ck01:
*
	move.w	d1,d7
*  adjust ymin_clp
	move.w	bsh_hite,d5
	sub.w	#1,d5
	sub.w	yoffset(a5),d5
	bmi	ck02
	add.w	d5,d1		;adjust xmin_clp
ck02:
*  adjust ymax_clp
	sub.w	yoffset(a5),d7
	add.w	w_hite(a5),d7
	sub.w	bsh_hite,d7
	addq.w	#1,d7		;take the smaller
	cmp.w	d7,d3
	ble	ck03
	move.w	d7,d3
ck03:
	movem.w	bsh_x,d4-d5
*
	cmp	d4,d2
	blt	ck04
*
	cmp	d5,d3
	blt	ck04
*
	sub.w	wx(a5),d4
	add.w	xoffset(a5),d4
	bmi	ck04
*
	sub.w	wy(a5),d5
	add.w	yoffset(a5),d5
	bmi	ck04
*
	movem.w	d0-d3,Mclpxmn	;set contain world motion variables
ck04:
	movem.w	(sp)+,d2/d5
*
*
ck0:
	btst.l	#RITESHIFT,d5	;edge on right shift?
	beq	ck0x		;br if no--do nothing
*
	btst.l	#RITESHIFT,d2	;is right shift key down?
	bne	ck1x		;br if leading edge on right shift
*
*  trailing edge on left shift--exit constrain mode
*
	clr.w	constrain
	bra	ck0x
*
ck1x:
	move.w	#-1,constrain
*
*  check ALT key
*
*  fathold =	0 if ALT not down
*		2 if down
*	       -1 if leading edge down
*		1 if trailing edge up
ck0x:
	btst.l	#ALT,d5		;any edges
	beq	ck20x		;br if none
	moveq	#1,d0		;assume trailing
	btst.l	#ALT,d2
	beq	ck21x
	moveq	#-1,d0
	bra	ck21x
ck20x:
	moveq	#0,d0		;assume no activity
	btst.l	#ALT,d2		;up or down
	beq	ck21x
	moveq	#2,d0
ck21x:
	move.w	d0,fathold
*
*   Now do CTRL key check..
*
ck2x:
	tst.w	GridLock	;check for grid lock on
	beq	ck0off		;if grid lock is off--check manual
*
	tst.w	grid		;is this grid-init?
	bpl	ck0on		;init grid if not done already
	bra	ck10		;else, just continue grid
ck0off:
	btst.l	#CTRL,d5	;edge on CTRL?
	beq	ck10		;br if no--do nothing
*
	clr.w	grid		;assume clear grid
	btst.l	#CTRL,d2	;is left shift key down?
	beq	ck10		;br if trailing edge on left shift
ck0on:
	move.w	#1,grid		;enter grid mode
*
ck10:
	movem.l	(sp)+,a0/d0-d4
	rts	
*
*****************************************************
*
*
*	Some Subs for y'all
*
*
*
*
*************************************************
*
*   Cookie cut stamp to Screen, clipped by our clipping variables
*
*	d0 = screen DST x
*	d1 = screen DST y
*	d2 = width
*	d3 = height
*	d4 = mono mask scr_nxln
*
*	a0 -> mono mask s_form (or color if rect fill)
*	a3 -> 4-plane graphics s_form
*	a5 -> current wstruct
bdisplay:
*
*  Fill intermediate mask with all 1's
*
*
	lea	grafmsk,a1
	moveq	#-1,d7
	move.w	d2,d5
	add.w	#15,d5
	and.w	#$fff0,d5
	lsr.w	#3,d5
	move.w	d5,d6
*
	mulu	d3,d6		;d5 = # of bytes in mono-mask
	lsr.w	#2,d6		;d5 = # of longwords to init (cy = 1 if add word) 
	bra	maskini
maskinit:
	move.l	d7,(a1)+
maskini:
	dbra	d6,maskinit
	move.l	d7,(a1)+
	move.w	d7,(a1)+
maskd:
*
*  intermediate mask is full of 1's
*
*
	movem.l	a0/a3/a5/d0-d5,-(sp)
*
*  do we need to blit from world mask to intermediate?
*
	sub.w	wx(a5),d0		;adjust for window in screen
	add.w	xoffset(a5),d0	;d0 = d_xmin in world
	cmp.w	w_wid(a5),d0	;are we entirely to right of world?
	bge	skipint		;br if so--skip intermediate mono-mask blt
*
	sub.w	wy(a5),d1
	add.w	yoffset(a5),d1
	cmp.w	w_hite(a5),d1	;are we entirely below world?
	bge	skipint		;br if so
*
*  We need to blit into intermediate mask
*
	lea	mask2i,a6	;use world mask to intermediate blit
	move.w	d5,d_nxln(a6)
*
	bsr	worldclp	;clip for the world
	movem.w	d0-d1,s_xmin(a6)
	movem.w	d2-d3,b_width(a6)
	movem.w	d5-d6,d_xmin(a6)
*
*  We set some durables here until get get our act together..
*
	move.l	worldmsk,s_form(a6)
	move.l	#grafmsk,d_form(a6)
	move.w	#2,d_nxwd(a6)
	clr.w	d_nxpl(a6)
*	
	move.w	w_wrap,d0
	lsr.w	#2,d0
	move.w	d0,s_nxln(a6)
	move.w	#2,s_nxwd(a6)
	move.w	#0,s_nxpl(a6)
*
	move.l	#$01010101,op_tab(a6)	;D' = S and D
	move.w	#1,plane_ct(a6)
	.dc.w	bitblt			;blit mono to intermediate
skipint:
	movem.l	(sp)+,a0/a3/a5/d0-d5
*
	move.w	d3,d7		;height to d7
*
*  Now, using intermediate mono-mask, build intermediate grafix buffer
*
	movem.l	a0/a3/a5/d0-d5,-(sp)	;we need some regs
*
	lea	grafmsk,a1	;get mask ptr
	lea	grafbsh,a4	;get grafix DST ptr
*
	lsr.w	#1,d4		;# of words/mono scanline
	beq	ofillpe		;br if doing fill rectangle
*
	subq.w	#1,d4
	bra	ormsklpi
ormsklp0:
	moveq	#2,d2
ormsklp1:
	move.w	d4,d0
	move.l	a1,a2
ormsklp2:	
	move.w	(a3)+,d1	;get graphics
	and.w	(a2)+,d1
	move.w	d1,(a4)+
	dbra	d0,ormsklp2
	dbra	d2,ormsklp1
*
	move.w	d4,d0		;do last (#3) plane
	move.l	a1,a2
ormsklp3:
	move.w	(a3)+,d1	;get graphics
	move.w	(a2),d3
	and.w	d3,d1
	move.w	d1,(a4)+
	and.w	(a0)+,d3
	move.w	d3,(a2)+
	dbra	d0,ormsklp3
	move.l	a2,a1		;go on to next line of mask
ormsklpi:
	dbra	d7,ormsklp0
*
	bra	ormasko		;skip over fill rectangle stuff
*
*  This is for filled rectangles
*
ofillpe:
	sub.l	a3,a0		;get color from offset
	move.l	a0,d6		; of mask
*
	move.w	d5,d4
	lsr.w	#1,d4		;# of words/mono scanline
	subq.w	#1,d4
	bra	ofillpi
ofillp0:
	moveq	#0,d2
ofillp1:
	moveq	#0,d5
	btst.l	d2,d6
	beq	ofillp1a
	moveq	#-1,d5
ofillp1a:
	move.w	d4,d0
	move.l	a1,a2
ofillp2:	
	move.w	d5,d1		;get graphics
	and.w	(a2)+,d1
	move.w	d1,(a4)+
	dbra	d0,ofillp2
	addq.w	#1,d2
	cmpi.w	#3,d2
	bcs	ofillp1
*
*
	moveq	#0,d5
	btst.l	d2,d6
	beq	ofillp2a
	moveq	#-1,d5
ofillp2a:
	move.w	d4,d0		;do last (#3) plane
	move.l	a1,a2
ofillp3:
	move.w	d5,d1		;get graphics
	move.w	(a2),d3
	and.w	d3,d1
	move.w	d1,(a4)+
	move.w	d3,(a2)+
	dbra	d0,ofillp3
	move.l	a2,a1		;go on to next line of mask
ofillpi:
	dbra	d7,ofillp0
*
*
ormasko:
	movem.l	(sp)+,a0/a3/a5/d0-d5	;get our regs back
*
*
*  Now adjust d0-d3 for window clip..
*
	lea	bitblock,a6
	move.w	d5,s_nxln(a6)	;we need to save d5 here
*
*  check left clip
*
	moveq	#0,d5		;assume 0 = s_xmin
	cmp.w	xmin_clp,d0	;check for left clip
	bge	leffok
	move.w	d0,d5
	move.w	xmin_clp,d0
	sub.w	d0,d5
	neg.w	d5	
	sub.w	d5,d2
leffok:
*
*  check right clip
*
	move.w	d0,d7
	add.w	d2,d7	;find right-most position of block (+1)
	cmp.w	xmax_clp,d7
	ble	rittok	;br if doesn't exceed max
	sub.w	xmax_clp,d7
	sub.w	d7,d2
rittok:
*
*  check top clip
*
	moveq	#0,d6		;assume 0 = s_ymin
	cmp.w	ymin_clp,d1	;check for top clip
	bge	toppok
	move.w	d1,d6
	move.w	ymin_clp,d1
	sub.w	d1,d6
	neg.w	d6	
	sub.w	d6,d3
toppok:
*
*  check bottom clip
*
	move.w	d1,d7
	add.w	d3,d7	;find bottom-most position of block (+1)
	cmp.w	ymax_clp,d7
	ble	bottok	;br if doesn't exceed max
	sub.w	ymax_clp,d7
	sub.w	d7,d3
bottok:
*
*  
*	d0 = d_xmin
*	d1 = d_ymin
*	d2 = b_width
*	d3 = b_height
*
*	d5 = s_xmin
*	d6 = s_ymin
*
*   Now clipped for window (given by clipping rectagle xmin_clp etc.)
*
*  Now BLT to screen
*
*
	movem.w	d0-d1,d_xmin(a6)
	movem.w	d2-d3,b_width(a6)
	movem.w	d5-d6,s_xmin(a6)
*
	clr.l	p_addr(a6)		;*** this could be durable ***
	move.l	#grafmsk,s_form(a6)	;*** this could be durable ***
	move.w	#2,s_nxwd(a6)		;*** this could be durable ***
	clr.w	s_nxpl(a6)		;*** this could be durable ***
	move.l	#$04040404,op_tab(a6)
*
	bsr	copyund		;copy graphics under sprite 1st
*
	move.w	#4,plane_ct(a6)
*
	movem.l	a0/a3/a5/a6,-(sp)
	.dc.w	bitblt		;cookie cut a hole
	movem.l	(sp)+,a0/a3/a5/a6
*
	move.l	#grafbsh,s_form(a6)	;get graphics to OR into hole
	move.l	#$07070707,op_tab(a6)
	move.w	#4,plane_ct(a6)
	move.w	s_nxln(a6),d0
	move.w	d0,s_nxpl(a6)
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,s_nxln(a6)
*
	movem.l	a0/a3/a5/a6,-(sp)
	.dc.w	bitblt		;OR graphics into hole
	movem.l	(sp)+,a0/a3/a5/a6
	rts
*
*
*
*  
*   Cookie cut stamp to World, world-clipped.
*
*
*  It is assumed that wbblock (the blt parm block used) is properly
*    set-up for the world buffer as destination
*
*	d0 = DST x
*	d1 = DST y
*	d2 = width
*	d3 = height
*	d4 = mono mask scr_nxln
*
*	a0 -> mono mask s_form
*	a3 -> 4-plane graphics s_form
*
*
wldblit:
	lea	wbblock,a6		;use DST: world bitBLT block
*
	clr.w	s_nxpl(a6)
	move.w	#2,s_nxwd(a6)
*
	move.w	d4,s_nxln(a6)
	bne	wldblit0	;br if not a rect fill
*
	cmp.l	#grafbsh,a3	;is rect fill from expanded buffer? 
	bne	wldblit3	;br if not
*
	move.w	d2,d4
	addi.w	#15,d4
	andi.w	#$fff0,d4
	lsr.w	#3,d4
	move.w	d4,s_nxln(a6)
	bra	wldblit0
*
wldblit3:
	clr.w	s_nxwd(a6)
	move.l	a3,s_form(a6)
	bra	wldblit1	
wldblit0:	
	move.l	a0,s_form(a6)
wldblit1:
	bsr	worldclp
	movem.w	d0-d1,d_xmin(a6)
	movem.w	d2-d3,b_width(a6)
	movem.w	d5-d6,s_xmin(a6)
*
	move.l	#$04040404,op_tab(a6)
	move.w	#4,plane_ct(a6)
	clr.l	p_addr(a6)
*
	movem.l	a0/a3/a5/a6,-(sp)
	.dc.w	bitblt		;cookie cut a hole
	movem.l	(sp)+,a0/a3/a5/a6
*
	move.l	a3,s_form(a6)	;get graphics to OR into hole
	move.l	#$07070707,op_tab(a6)
	move.w	#4,plane_ct(a6)
	move.w	s_nxln(a6),d0
	move.w	d0,s_nxpl(a6)
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,s_nxln(a6)
	bne	wldblit2
	move.l	#$05050707,op_tab(a6)
	move.l	a0,d0
	sub.l	a3,d0
	move.w	d0,fg_col(a6)
	clr.w	bg_col(a6)
wldblit2:
*
	movem.l	a0/a3/a5/a6,-(sp)
	.dc.w	bitblt		;OR graphics into hole
	movem.l	(sp)+,a0/a3/a5/a6
	rts
*
*
*
*
*
*
*  Check world clip
*
*   Entry:
*	It is assumed that some part of the destination rectangle
*	falls within the world.
*
*	a6 -> bit block
*
*	d0	= d_xmin	relative to world
*	d1	= d_ymin
*	d2	= b_width
*	d3	= b_height
*	w_wid	= width of world in pixels
*	w_hite	= height of world in pixels
*
*   Exit:
*	d0-d3 are set for proper clip,  d5-d6 are s_xmin, s_ymin
*
worldclp:
*
*  check left clip
*
	moveq	#0,d5		;assume 0 = s_xmin
	tst.w	d0		;check for left clip
	bge	leffokw
	move.w	d0,d5
	moveq	#0,d0
	neg.w	d5	
	sub.w	d5,d2
leffokw:
*
*  check right clip
*
	move.w	d0,d7
	add.w	d2,d7	;find right-most position of block (+1)
	sub.w	w_wid(a5),d7
	ble	rittokw	;br if doesn't exceed max
	sub.w	d7,d2
rittokw:
*
*  check top clip
*
	moveq	#0,d6		;assume 0 = s_ymin
	tst.w	d1	;check for top clip
	bge	toppokw
	move.w	d1,d6
	moveq	#0,d1
	neg.w	d6	
	sub.w	d6,d3
toppokw:
*
*  check bottom clip
*
	move.w	d1,d7
	add.w	d3,d7	;find bottom-most position of block (+1)
	sub.w	w_hite(a5),d7
	ble	bottokw	;br if doesn't exceed max
	sub.w	d7,d3
bottokw:
*	move.w	d3,b_height(a6)
	rts
*
**********************************************
*
*
*  Toggle from original palette to that of 0th brush
*
switchpal:
	bchg	#0,butt
	bne	switch1
	pea	oldpal
	bra	switch2
*
*  Enter here from Palette change routine
*
switch1:
	lea	palblock,a0
	move.w	firstpal,d0
	bmi	switch2a
	lsl.w	#5,d0
	adda.w	d0,a0
	move.l	a0,-(sp)
switch2:
	move.w	#6,-(sp)
	trap	#14		;just restore old palette for now
	addq.l	#6,sp
switch2a:
*	bsr	getmouse	;d0=x,d1=y,d2=keycntrl,d3=mouse buttons
*	andi.w	#1,d3
*	bne	switch2a
	rts
*
*
*********************************************************
*
*   Check keyboard for any key that has come in
*    and re-prioritize if key commands it.
*
checkpri:
	movem.l	d0-d3/a0/a3,-(sp)	;we need to preserve these
*
	ror.w	#8,d4		;swap hi/lo bytes of key codes
*
	movem.w	bsh_x,d0-d3	;get our rectangle
*
	sub.w	wx(a5),d0		;adjust for world co-ords
	add.w	xoffset(a5),d0
	sub.w	wy(a5),d1
	add.w	yoffset(a5),d1
*
	add.w	d0,d2		;d2 = right edge +1
	add.w	d1,d3		;d3 = bottom edge +1
*
	move.l	wblkptr,a0	;get highest priority obj ptr 
	move.l	wblkcur,a1	;    current
	lea	worldblk,a2	;    lowest
	lea	bshblock,a3
*
	cmpi.b	#CLEAR_HOME,d4
	beq	top_pri
	cmpi.b	#INSERT,d4
	beq	bot_pri
	cmpi.b	#VERT_BAR,d4
	beq	up_pri
	cmpi.b	#KEYPAD4,d4
	beq	down_pri
*
	cmpi.b	#FUNC_1,d4
	bcs	notafunc
	cmpi.b	#FUNC_10,d4
	bls	do_func
*
	cmpi.b	#SH_FUNC_1,d4
	bcs	notafunc
	cmpi.b	#SH_FUNC_10,d4
	bls	do_unfunc
*
notafunc:
	ror.w	#8,d4		;check for Hflip, Vflip
	cmpi.b	#"a",d4
	bcs	notax
	subi.b	#$20,d4		;make upper case
notax:
	cmpi.b	#"H",d4		;want Hflip?
	beq	dohflip		;do H-flip
	cmpi.b	#"V",d4		;
	beq	dovflip
	cmpi.b	#"G",d4		;want to toggle gridlock?
	beq	dogridlk
	cmpi.b	#"A",d4		;how about alternate
	beq	doalt
*
*  any other keys go here
*
chkprix:
	movem.l	(sp)+,d0-d3/a0/a3
	rts
*
*
*
dogridlk:
	eori.w	#1,GridLock
	bne	gridlk0
	clr.w	grid
gridlk0:
	move.w	#-1,forceupd
	bra	chkprix
*
*   Make the selected object the highest priority in the local neighborhood
*
top_pri:
	moveq	#1,d7		;init overlap count in d7
	moveq	#0,d6		;init our priority in d6
	swap	d6		; we need reg for temp use
	bra	next_top
top_lp:
	move.w	-(a0),d5	;get next objects ypos
	move.w	-(a0),d4	;xpos
	sub.l	#2,a0		;skip special effects
	move.w	-(a0),d6	;brush #
*
	cmp.w	d2,d4	;check right edge of current with left edge of test
	bge	next_top	;br if current entirely to left of test
*
	cmp.w	d3,d5	;check bottom edge of current with top edge of test
	bge	next_top	;br if current entirely above test
*
	lsl.w	#4,d6		;index into bshblock
	add.w	(a3,d6.w),d4	;get right edge (+1) of object
	add.w	2(a3,d6.w),d5	;get bottom edge (+1) of object
*
	cmp.w	d0,d4	;check left edge of current with right edge of test
	ble	next_top	;br if current entirely to right of test
*
	cmp.w	d1,d5	;check top edge of current with bottom edge of test
	ble	next_top	;br if current entirely below test
*
*  We have overlap
*
	swap	d6		;have we set the priority already?
	tst.w	d6
	bne	top_lp1		;br if so
	move.l	a0,d4
	addq.l	#8,d4
	move.w	d7,d6		;
	move.l	d4,wblkcur	;adjust priority
top_lp1:
	swap	d6
	addq.w	#1,d7
*	
next_top:
	cmp.l	a0,a2		;have we reached bottom priority?
	bcs	top_lp		;br if not
	moveq	#1,d6
	swap	d6
re_prix:
	swap	d6		;d6 is count where priority was changed
*
	lea	priorma,a1
	move.w	d6,d0
	bsr	decitpad
*
	move.w	#"0",d0
re_prix2:
	cmp.b	-(a1),d0
	bhi	re_prix2
	addq.l	#1,a1
	move.b	#" ",(a1)+
	move.b	#"o",(a1)+
	move.b	#"f",(a1)+
	move.b	#" ",(a1)+
	move.w	d7,d0		;put out total count
	bsr	decitpad
	clr.b	(a1)+
*
	lea	priormsg,a0
	move.w	#LIBRARY,d0
	bsr	DaveInfo
*
	bsr	makemsk
	move.w	#-1,forceupd	;update this thing
*	move.l	mouseptr,a0
*	addq.w	#1,(a0)
*	subq.w	#1,bsh_x
re_prix1:
	bra	chkprix
*
*
*   Make the selected object the lowest priority in the local neighborhood
*
bot_pri:
	moveq	#1,d7		;init overlap count in d7
	moveq	#0,d6		;init our priority in d6
	swap	d6		; we need reg for temp use
	bra	next_bot
bot_lp:
	move.w	(a2)+,d6	;get next objects brush #
	addq.w	#2,a2		;skip special effects
	move.w	(a2)+,d4	;xpos
	move.w	(a2)+,d5	;ypos
*
	cmp.w	d2,d4	;check right edge of current with left edge of test
	bge	next_bot	;br if current entirely to left of test
*
	cmp.w	d3,d5	;check bottom edge of current with top edge of test
	bge	next_bot	;br if current entirely above test
*
	lsl.w	#4,d6		;index into bshblock
	add.w	(a3,d6.w),d4	;get right edge (+1) of object
	add.w	2(a3,d6.w),d5	;get bottom edge (+1) of object
*
	cmp.w	d0,d4	;check left edge of current with right edge of test
	ble	next_bot	;br if current entirely to right of test
*
	cmp.w	d1,d5	;check top edge of current with bottom edge of test
	ble	next_bot	;br if current entirely below test
*
*  We have overlap
*
	swap	d6
	tst.w	d6
	bne	bot_lp1
	move.w	d7,d6
	move.l	a2,d4
	subq.l	#8,d4
	move.l	d4,wblkcur	;adjust priority
bot_lp1:
	swap	d6
	addq.w	#1,d7
next_bot:
	cmp.l	a0,a2		;have we reached top priority?
	bcs	bot_lp		;br if not	
	move.w	d7,d6
	swap	d6
	bra	re_prix
*
*
*
*   Bump down the selected object's priority in the local neighborhood
*
down_pri:
	moveq	#1,d7
	moveq	#0,d6
	swap	d6
	bra	next_Top
*
Top_lp:
	move.w	-(a0),d5	;get next objects ypos
	move.w	-(a0),d4	;xpos
	sub.l	#2,a0		;skip special effects
	move.w	-(a0),d6	;brush #
*
	cmp.w	d2,d4	;check right edge of current with left edge of test
	bge	next_Top	;br if current entirely to left of test
*
	cmp.w	d3,d5	;check bottom edge of current with top edge of test
	bge	next_Top	;br if current entirely above test
*
	lsl.w	#4,d6		;index into bshblock
	add.w	(a3,d6.w),d4	;get right edge (+1) of object
	add.w	2(a3,d6.w),d5	;get bottom edge (+1) of object
*
	cmp.w	d0,d4	;check left edge of current with right edge of test
	ble	next_Top	;br if current entirely to right of test
*
	cmp.w	d1,d5	;check top edge of current with bottom edge of test
	ble	next_Top	;br if current entirely below test
*
*  We have overlap
*
	addq.w	#1,d7
	swap	d6		;have we set the priority already?
	tst.w	d6
	bne	Top_lp1		;br if so
	cmp.l	a0,a1
	bls	Top_lp1
	move.w	d7,d6		;
	move.l	a0,wblkcur	;adjust priority
Top_lp1:
	swap	d6
*	
next_Top:
	cmp.l	a0,a2		;have we reached bottom priority?
	bcs	Top_lp		;br if not
	swap	d6
	tst.w	d6
	bne	Top_lp3
	move.w	d7,d6
Top_lp3:
	swap	d6
	bra	re_prix
*
*
*   Bump up the selected object's priority in the local neighborhood
*
up_pri:
	moveq	#1,d7		;init overlap count in d7
	moveq	#0,d6		;init our priority in d6
	swap	d6		; we need reg for temp use
	bra	next_Bot
Bot_lp:
	move.w	(a2)+,d6	;get next objects brush #
	addq.w	#2,a2		;skip special effects
	move.w	(a2)+,d4	;xpos
	move.w	(a2)+,d5	;ypos
*
	cmp.w	d2,d4	;check right edge of current with left edge of test
	bge	next_Bot	;br if current entirely to left of test
*
	cmp.w	d3,d5	;check bottom edge of current with top edge of test
	bge	next_Bot	;br if current entirely above test
*
	lsl.w	#4,d6		;index into bshblock
	add.w	(a3,d6.w),d4	;get right edge (+1) of object
	add.w	2(a3,d6.w),d5	;get bottom edge (+1) of object
*
	cmp.w	d0,d4	;check left edge of current with right edge of test
	ble	next_Bot	;br if current entirely to right of test
*
	cmp.w	d1,d5	;check top edge of current with bottom edge of test
	ble	next_Bot	;br if current entirely below test
*
*  We have overlap
*
	addq.w	#1,d7
	swap	d6
	tst.w	d6
	bne	Bot_lp1
	cmp.l	a2,a1
	bcc	Bot_lp1
	move.w	d7,d6
	move.l	a2,wblkcur	;adjust priority
Bot_lp1:
	swap	d6
next_Bot:
	cmp.l	a0,a2		;have we reached top priority?
	bcs	Bot_lp		;br if not
	swap	d6
	tst.w	d6
	bne	Bop_lp3
	move.w	d7,d6
Bop_lp3:
	move.w	d7,d0
	sub.w	d6,d0
	move.w	d0,d6
	addq.w	#1,d6
	swap	d6
	bra	re_prix
*
*
*
*********************************************
*
*  Horizontal flip request on curbrush
*
dohflip:
	bsr	makehflp	;take curbrush, hflip and stuff in curbrush
*
	bra	doflip
*
*
**********************************************
*
*
*  Vertical flip request on curbrush
*
dovflip:
	bsr	makevflp
doflip:
	move.w	curbrush,d0
	bsr	upname		;put up the name
	bra	donew_bsh	;exit thru brush display
*
*
**************************************************
*
*
doalt:
	bsr	makealt
	bra	doflip
*
*
*   Take curbrush and build new curbrush (if not existing) that's lightened
*
makealt:	
	lea	bshblock,a0
*
	move.w	curbrush,d0		;check intrinsic or not
	move.w	maxintrins,d1
	cmp.w	d1,d0			;are we?
	bhi	aderivd			;br if derived
*
*  We're an intrinsic brush--search derived brushes for existing hflip
*
	bra	doa1
doa0:
	lsl.w	#4,d1
	move.l	8(a0,d1.w),a1		;get derived ptr
	lsr.w	#4,d1
*
	tst.w	4(a1)			;check for non-cluster
	bne	doa1			;br if cluster
	move.l	6(a1),d2		;get brush # & effect
	cmpi.w	#Alternate,d2		;is this an Hflip?
	bne	doa1
	swap	d2
	cmp.w	d2,d0			;is this Hflip of our brush
	beq	doa2			;br if so
doa1:	
	addq.w	#1,d1
	cmp.w	maxderivd,d1
	bls	doa0
*
*  existing not available--better make a new one
*
	bsr	bsh_alt
*
	move.w	maxderivd,d1
	bra	doa2
*
*  We're a derived brush--see if what we want is an intrinsic
*
aderivd:
	lsl.w	#4,d0
	move.l	8(a0,d0.w),a1	;get derived ptr for curbrush
	lsr.w	#4,d0
*
	tst.w	4(a1)		;check for non-cluster
	beq	doa2x		;br if non-cluster
	move.w	d0,d2
	swap	d2
	clr.w	d2
	bra	aderv0	
doa2x:
	move.l	6(a1),d2	;get 1st brush # & effect
	cmpi.w	#Alternate,d2	;can we just go back to intrinsic?
	bne	aderv0		;br if this alternate is not intrinsic
	swap	d2
	move.w	d2,d1
	bra	doa2
*
*  d1 = maxintrins
*
aderv0:
	eori.w	#Alternate,d2	;see if we can find this derived
	move.l	d2,d0
*
*  search derived brushes for desired hflip
*
	bra	doa11
doa10:
	lsl.w	#4,d1
	move.l	8(a0,d1.w),a1		;get derived ptr
	lsr.w	#4,d1
*
	tst.w	4(a1)		;check for non-cluster
	bne	doa11		;br if cluster
	move.l	6(a1),d2	;get brush # & effect
	cmp.l	d0,d2		;is this same effect & brush as desired
	beq	doa2		;br if so--needn't derive
doa11:
	addq.w	#1,d1
	cmp.w	maxderivd,d1
	bls	doa10
*
*  existing not available--better make a new one
*
	move.l	d0,-(sp)	;save intrinsic brush & effects
	bsr	bsh_alt
	move.w	maxderivd,d1
	move.l	(sp)+,d0
	move.w	d1,d2
	lsl.w	#4,d2
	move.l	8(a0,d2.w),a1
	move.l	d0,6(a1)	;put in intrinsic brush & effects
*
*  this is what we want--existing derived available
*
doa2:
	move.w	d1,curbrush
	rts
*	
*
*
*
*   Take curbrush and build new curbrush (if not existing) that's hflipp'd
*
makehflp:	
	lea	bshblock,a0
*
	move.w	curbrush,d0		;check intrinsic or not
	move.w	maxintrins,d1
	cmp.w	d1,d0			;are we?
	bhi	hderivd			;br if derived
*
*  We're an intrinsic brush--search derived brushes for existing hflip
*
	bra	doh1
doh0:
	lsl.w	#4,d1
	move.l	8(a0,d1.w),a1		;get derived ptr
	lsr.w	#4,d1
*
	tst.w	4(a1)			;check for non-cluster
	bne	doh1			;br if cluster
	move.l	6(a1),d2		;get brush # & effect
	cmpi.w	#Hflip,d2		;is this an Hflip?
	bne	doh1
	swap	d2
	cmp.w	d2,d0			;is this Hflip of our brush
	beq	doh2			;br if so
doh1:	
	addq.w	#1,d1
	cmp.w	maxderivd,d1
	bls	doh0
*
*  existing not available--better make a new one
*
	bsr	bsh_hflip
*
	move.w	maxderivd,d1
	bra	doh2
*
*  We're a derived brush--see if what we want is an intrinsic
*
hderivd:
	lsl.w	#4,d0
	move.l	8(a0,d0.w),a1	;get derived ptr for curbrush
	lsr.w	#4,d0
*
	tst.w	4(a1)		;check for non-cluster
	beq	doh2x		;br if non-cluster
	move.w	d0,d2
	swap	d2
	clr.w	d2
	bra	hderv0	
doh2x:
	move.l	6(a1),d2	;get 1st brush # & effect
	cmpi.w	#Hflip,d2	;can we just go back to intrinsic?
	bne	hderv0		;br if this hflip is not intrinsic
	swap	d2
	move.w	d2,d1
	bra	doh2
*
*  d1 = maxintrins
*
hderv0:
	eori.w	#Hflip,d2	;see if we can find this derived
	move.l	d2,d0
*
*  search derived brushes for desired hflip
*
	bra	doh11
doh10:
	lsl.w	#4,d1
	move.l	8(a0,d1.w),a1		;get derived ptr
	lsr.w	#4,d1
*
	tst.w	4(a1)		;check for non-cluster
	bne	doh11		;br if cluster
	move.l	6(a1),d2	;get brush # & effect
	cmp.l	d0,d2		;is this same effect & brush as desired
	beq	doh2		;br if so--needn't derive
doh11:
	addq.w	#1,d1
	cmp.w	maxderivd,d1
	bls	doh10
*
*  existing not available--better make a new one
*
	move.l	d0,-(sp)	;save intrinsic brush & effects
	bsr	bsh_hflip
	move.w	maxderivd,d1
	move.l	(sp)+,d0
	move.w	d1,d2
	lsl.w	#4,d2
	move.l	8(a0,d2.w),a1
	move.l	d0,6(a1)	;put in intrinsic brush & effects
*
*  this is what we want--existing derived available
*
doh2:
	move.w	d1,curbrush
	rts
	
*
*
***********************************************************
*
*
makevflp:
	lea	bshblock,a0
*
	move.w	curbrush,d0		;check intrinsic or not
	move.w	maxintrins,d1
	cmp.w	d1,d0			;are we?
	bhi	vderivd			;br if derived
*
*  We're an intrinsic brush--search derived brushes for existing hflip
*
	bra	dov1
dov0:
	lsl.w	#4,d1
	move.l	8(a0,d1.w),a1		;get derived ptr
	lsr.w	#4,d1
*
	tst.w	4(a1)			;check for non-cluster
	bne	dov1			;br if cluster
	move.l	6(a1),d2		;get brush # & effect
	cmpi.w	#Vflip,d2		;is this an Vflip?
	bne	dov1
	swap	d2
	cmp.w	d2,d0			;is this Vflip of our brush
	beq	doh2			;br if so
dov1:	
	addq.w	#1,d1
	cmp.w	maxderivd,d1
	bls	dov0
*
*  existing not available--better make a new one
*
	bsr	bsh_vflip
*
	move.w	maxderivd,d1
	bra	dov2
*
*  We're a derived brush--see if what we want is an intrinsic
*
vderivd:
	lsl.w	#4,d0
	move.l	8(a0,d0.w),a1	;get derived ptr for curbrush
	lsr.w	#4,d0
*
	tst.w	4(a1)			;check for non-cluster
	beq	dov2x			;exit if cluster
	move.w	d0,d2
	swap	d2
	clr.w	d2
	bra	vderv0
dov2x:
	move.l	6(a1),d2	;get brush # & effect
	cmpi.w	#Vflip,d2	;can we just go back to intrinsic?
	bne	vderv0		;br if this vflip is not intrinsic
	swap	d2
	move.w	d2,d1
	bra	dov2
*
*  d1 = maxintrins
*
vderv0:
	eori.w	#Vflip,d2	;see if we can find this derived
	move.l	d2,d0
*
*  search derived brushes for desired hflip
*
	bra	dov11
dov10:
	lsl.w	#4,d1
	move.l	8(a0,d1.w),a1		;get derived ptr
	lsr.w	#4,d1
*
	tst.w	4(a1)		;check for non-cluster
	bne	dov11		;br if cluster
	move.l	6(a1),d2	;get brush # & effect
	cmp.l	d0,d2		;is this same effect & brush as desired
	beq	dov2		;br if so--needn't derive
*
dov11:
	addq.w	#1,d1
	cmp.w	maxderivd,d1
	bls	dov10
*
*  existing not available--better make a new one
*
	move.l	d0,-(sp)	;save intrinsic brush # & effects
	bsr	bsh_vflip
	move.w	maxderivd,d1
	move.l	(sp)+,d0
	move.w	d1,d2
	lsl.w	#4,d2
	move.l	8(a0,d2.w),a1
	move.l	d0,6(a1)	;put in intrinsic brush # & effects
*
*  this is what we want--existing derived available
*
dov2:
	move.w	d1,curbrush
	rts
*
*
*
*
*
*
*
*	Function Key stuff
*
do_func:
	moveq	#0,d0
	move.b	d4,d0
	subi.b	#FUNC_1,d0	
	lsl.w	#8,d0
	bsr	Func_Key	;install new curbrush
*
donew_bsh:
*
	bsr	pastund		;erase old brush
*
	movem.l	a1/d4-d7,-(sp)
	movem.w	bsh_x,d0-d3
	lsr.w	#1,d2
	lsr.w	#1,d3
	add.w	d2,d0
	add.w	d3,d1		;d0-d1 is raw x/y
*
	lea	bshblock,a1		;get brush data block base
	move.w	curbrush,d2		;get desired brush #
	lsl.w	#4,d2
*
	adda.w	d2,a1
	move.w	(a1)+,d2		;get block width
	move.w	d2,bsh_wid		;save for use by move
*
	move.w	d2,d5			;copy width
	lsr.w	#1,d5
	sub.w	d5,d0			;adjust xpos by 1/2 width
*
	move.w	d0,bsh_x		;we allow bsh_x < 0
*
*
	move.w	(a1)+,d3		;get block height
	move.w	d3,bsh_hite		;save for use by move
*
	move.w	d3,d6
	lsr.w	#1,d6
	sub.w	d6,d1
*
	move.w	d1,bsh_y
*
	move.l	(a1)+,a3	;a3 -> s_form
	move.l	a3,a0
	addq.l	#4,a1		;skip obj_name string
*	move.l	(a1)+,a2	;object name string
*
	move.w	(a1)+,d4	;get mask_offset
	lea	(a3,d4.w),a0	;get mono mask src_form
*
	move.w	(a1)+,d4	;s_nxln for 4-plane brush
	lsr.w	#2,d4		;d4 = mono scr_nxln
	move.w	d4,bsh_monoln
*
*
*	d0 = DST x
*	d1 = DST y
*	d2 = width
*	d3 = height
*	d4 = mono mask scr_nxln
*
*	a0 -> mono mask s_form
*	a3 -> 4-plane graphics s_form
*
*
	bsr	bdisplay	;display brush, clipped to screen
	movem.l	(sp)+,a1/d4-d7
*
*chkprix:
*	movem.l	(sp)+,d0-d3/a0/a3
	movem.l	(sp)+,d0-d3
	addq.l	#8,sp		;allow a0 & a3 to be updated
	rts
*
*
*
do_unfunc:
	moveq	#0,d0
	move.b	d4,d0
	subi.b	#SH_FUNC_1,d0	
	lsl.w	#8,d0
	bsr	Shift_Func_Key
	bra	chkprix		;exit--no change
*
*
*   Copy a patch of the screen sufficient for the next
*	screen blt to be undone when pastund is called.
*
*    a6 -> BLT parm block
*
copyund:
	movem.l	a0-a1/d0-d3,-(sp)
*
*	moveq	#$f0,d3		;assembler doesn't like this
*
	move.w	#$fff0,d3	;get our mask ready
	move.l	d_form(a6),a0	;get base ptr of screen
	move.w	d_nxln(a6),d0	;d0 = line width
	move.w	d0,d1		;save in d1 to find span
	mulu	d_ymin(a6),d0	;* ypos to give offset to top line
	add.l	d0,a0		;add to ptr
*
	move.w	d_xmin(a6),d0	;find adjust due to x component
	move.w	b_width(a6),d2
	add.w	d0,d2
	subq.w	#1,d2
*
	and.w	d3,d0
	and.w	d3,d2
	sub.w	d0,d2
	lsr.w	#4,d2	;d2 = width of block in double long words (-1)
*
	lsr.w	#1,d0
	adda.w	d0,a0		;a0-> 1st word to transfer
	move.l	a0,undform
*
	move.w	d2,d0
	addq.w	#1,d0
	lsl.w	#3,d0
	sub.w	d0,d1		;d1 = line length - span

	move.w	b_height(a6),d0	;get height of blt
	subq.w	#1,d0
*
*	d0 = undhite (# scanlines high -1)
*	d1 = undspan (# bytes to finish screen span)
*	d2 = undwid  (# of double long words in splat line -1)
*
	movem.w	d0-d2,undhite
*
	lea	undbuf,a1
cund0:
	move.w	d2,d3
cund1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d3,cund1
*
	adda.w	d1,a0
	dbra	d0,cund0
*
*
	movem.l	(sp)+,a0-a1/d0-d3	
	rts
*
*
*
*
pastund:
	movem.l	a0-a1/d0-d3,-(sp)
	movem.w	undhite,d0-d2
*	
*
*	d0 = undhite (# scanlines high -1)
*	d1 = undspan (# bytes to finish screen span)
*	d2 = undwid  (# of double long words in splat line -1)
*
*
	tst.w	d0		;check for no und here
	bmi	pundx		;exit if no und to do
*
	lea	undbuf,a0
	move.l	undform,a1
pund0:
	move.w	d2,d3
pund1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d3,pund1
*
	adda.w	d1,a1
	dbra	d0,pund0
*
*
pundx:
	movem.l	(sp)+,a0-a1/d0-d3	
	rts
*
*  Build a library
*
makelib:
	move.l	library,a0	;first, clear out library buffer
	lea	wstruct+lxoffset,a5
	lea	libblock,a1
	bra	mwldi
*
*
**************************************************************8
*
*   Build a new world (and mask) from the data in the world block
*
*
*  uses wblkptr for worldblk end indicator
*	wblkcur for current priority in worldblk
*	w_wid, w_hite for world size info
*
makewld:
	move.l	world,a0	;first, clear out world buffer
	lea	wstruct,a5
	lea	worldblk,a1
mwldi:
	move.l	a1,-(sp)	;save ptr to begining of world entries
*
	move.w	w_wid(a5),d0
	move.w	d0,old_wid	;save last width used to build world
	addi.w	#15,d0
	andi.w	#$fff0,d0
	lsr.w	#1,d0		;d0 = world form_width
	move.w	d0,w_wrap	;save in world wrap
	move.w	d0,old_wrap	;save last wrap
*
	lsr.w	#3,d0		;get # of words in line of mask
	move.w	w_hite(a5),d1
	move.w	d1,old_hite	;save last height used to build world
	mulu	d1,d0		;* # of lines = worlds in mask
*
	move.l	a0,-(sp)
	moveq	#0,d1
	bra	clworli
clworl0:
	swap	d0
clworl:
	move.l	d1,(a0)+	;world initialized
	move.l	d1,(a0)+
clworli:	
	dbra	d0,clworl
	swap	d0
	dbra	d0,clworl0
*
	move.l	(sp)+,a0	
*
	move.l	a0,-(sp)
	move.w	w_wrap,d0
	mulu	w_hite(a5),d0
	add.l	d0,a0
	move.l	a0,worldmsk	;since we know the size of the world,
*				; we know where worldmsk begins
	lsr.l	#2,d0		;size of worldmsk is 1/4 of world
	add.l	d0,a0
	addq.l	#8,a0		;we may overshoot mask by 8 bytes
*
	move.l	a0,derivdgraf	;save ptr for derived graphics
*
	move.l	(sp)+,a0
*
*  Now put all the stamps in the world buffer..
*
*
*  Load up durable bshblock to world BitBlt parms..
*
	lea	wbblock,a6	;world build bitblt
	move.l	a0,d_form(a6)
*
	move.w	w_wrap,d_nxln(a6)
	move.w	#8,d_nxwd(a6)
	move.w	#2,d_nxpl(a6)
*
	move.w	#2,s_nxwd(a6)
*
	lea	bshblock,a2
*
*	Do we need a floor tile?
*
	move.w	worldtile,d2	;check world tile
	bmi	nowtile		;br if no tile to worry about
*
*   Yes, we tile this time
*
	lsl.w	#4,d2		;*16 to get index into brush block
	lea	(a2,d2.w),a4	;ptr to bshblock entry
*
	movem.w	initxtile,d0-d1		;get initial d_xmin,d_ymin
	movem.w	d0-d1,rowxtile		;save row start position
	movem.w	(a4)+,d2-d3		;get width & height
	move.l	(a4)+,s_form(a6)	;graphics SRC form
	addq.l	#6,a4			;skip id_string, mono-mask offset 
	move.w	(a4)+,d4		;get s_nxln
	move.w	d4,s_nxln(a6)
	lsr.w	#2,d4
	move.w	d4,s_nxpl(a6)
*
	move.l	#$07070707,op_tab(a6)	;or mode for tile
	bra	tilelpi
tilelp:
	movem.l	d0-d3/a5/a6,-(sp)
	bsr	worldclp	;clip to the world
	movem.w	d0-d1,d_xmin(a6)
	movem.w	d2-d3,b_width(a6)
	movem.w	d5-d6,s_xmin(a6)
	move.w	#4,plane_ct(a6)
	.dc.w	bitblt
	movem.l	(sp)+,d0-d3/a5/a6
*
*  calculate position of next item to right in row
*
nextcol:
	add.w	d2,d0
*
	add.w	rowthoff,d0
	add.w	rowtvoff,d1
*
tilelpi:
	bsr	worldon		;is it on the world?
	beq	tilelp		;br if so
*
*  off the world--keep going in this row until off to right
*
	btst.l	#0,d4		;have we gone too far right?
	beq	nextcol		;continue until we are
*
*  at end of row
*
	btst.l	#2,d4		;are we below
	beq	nextrow		;br if not
*
*  we are below and to right-- is rowtvoff negative?
*
	tst.w	rowtvoff	;check for upslope on row
	bmi	tiledone	;we're done if so
*
nextrow:
*
*  calculate position of next item down in leftmost column
*
	movem.w	rowxtile,d0-d1
*
	add.w	d3,d1

	add.w	colthoff,d0
	add.w	coltvoff,d1
*
*  check for xpos > 0
*
colchk:
	tst.w	d0
	blt	xnextok
*
*  do a negative row thang
*
	sub.w	d2,d0
*
	sub.w	rowthoff,d0
	sub.w	rowtvoff,d1
	bra	colchk
xnextok:
*
*
	movem.w	d0-d1,rowxtile
*
	bsr	worldon
	beq	tilelp		;br if on the world
*
	btst.l	#2,d4		;did we go below?
	beq	nextcol		;br if not--just do next item in this row
*
	tst.w	rowtvoff	;test for downslope on row
	bmi	nextcol
*
tiledone:
*
*  we're done
*
nowtile:
*
	move.l	(sp)+,a1	;reget ptr to begining of world
*
*	lea	worldblk,a1	;get pointer to begining of world blk
*
	lea	bshblock,a2
	bra	makwldi
makwld:
	movem.w	(a1)+,d2-d3	;get brush #, effects,
	movem.w	(a1)+,d0-d1	; & hpos, vpos
*
*  ignore effects for now
*
	cmp.w	maxderivd,d2	;did we exceed max brush #?
	bhi	makwldi		;br if so--this one's not available
*	
	lsl.w	#4,d2		;*16 to get index into brush block
	lea	(a2,d2.w),a4	;ptr to bshblock entry
*
	movem.w	(a4)+,d2-d3	;get width & height
	move.l	(a4)+,a3	;graphics SRC form
	move.l	a3,a0
	addq.l	#4,a4		;skip id_string
	adda.w	(a4)+,a0	;add offset to make mono mask SRC form base
	move.w	(a4)+,d4
	lsr.w	#2,d4		;get mono_mask s_nxln
*
	movem.l	a1-a2/a5,-(sp)
	bsr	wldblit		;stuff into world
	movem.l	(sp)+,a1-a2/a5
*
makwldi:
	cmp.l	wblkptr,a1	;reached end yet?
	bcs	makwld		;br if not.

	rts			;we finished the world
*
*
*   Generate the world mask buffer using wblkcur as priority indicator
*
*	This routine is called whenever priority is changed
*
makemsk:
*
*  clear the mask (put in all 1's)
*
	move.l	worldmsk,a0
	lea	wstruct,a5
	move.w	w_wid(a5),d0
	addi.w	#15,d0
	andi.w	#$fff0,d0
	lsr.w	#1,d0		;d0 = world form_width
	move.w	d0,w_wrap	;save in world wrap
*
	mulu	w_hite(a5),d0	;# of bytes in world graphics form
	lsr.l	#5,d0		;get # of double longwords in world mask form
	addq.l	#1,d0
*
	moveq	#-1,d1
	bra	setmski
setmsk0:
	swap	d0
setmsk:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
setmski:	
	dbra	d0,setmsk	;this may do up to 8 bytes too many	
*				 but who cares with this speed
*
	swap	d0
	dbra	d0,setmsk0
*
*   Now do bshblock to world_mask BLT's
*
	move.l	wblkcur,a0	;get pointer to current priority
*
*  Load up durable bshblock to world_mask BitBlt parms..
*
	lea	wbmblock,a6	;world mask build bitblt
	move.l	worldmsk,d_form(a6)
*
	move.w	w_wrap,d0
	lsr.w	#2,d0
	move.w	d0,d_nxln(a6)
	move.w	#2,d_nxwd(a6)
	move.w	#0,d_nxpl(a6)
*
*
	move.w	#0,s_nxpl(a6)
*
	move.l	#$04040404,op_tab(a6)	;D' = [not S] and D
	clr.l	p_addr(a6)
	lea	bshblock,a2
	bra	makmski
makmsk:
	movem.w	(a0)+,d2-d3	;get brush #, effects
	movem.w	(a0)+,d0-d1	; & hpos, vpos
*
*  ignore effects for now
*
	cmp.w	maxderivd,d2	;did we exceed max brush #?
	bhi	makwldi		;br if so--this one's not available
*	
	move.w	#2,s_nxwd(a6)	;assume normal mask
*
	lsl.w	#4,d2		;*16 to get index into brush block
	lea	(a2,d2.w),a3	;ptr to bshblock entry
*
	movem.w	(a3)+,d2-d3	;get width & height
*
	bsr	worldclp	;clip to the world
	movem.w	d0-d1,d_xmin(a6)
	movem.w	d2-d3,b_width(a6)
	movem.w	d5-d6,s_xmin(a6)
*
	move.l	(a3)+,a4	;a4 -> graphics form
	addq.l	#4,a3
	move.w	(a3)+,d0	;d0 = mask offset (or color if filled rect)

	move.w	(a3)+,d1	;get s_nxln
	lsr.w	#2,d1
	move.w	d1,s_nxln(a6)
	bne	makmsk1
	clr.w	s_nxwd(a6)
	bra	makmsk2
makmsk1:
	adda.w	d0,a4
makmsk2:
	move.l	a4,s_form(a6)
*
	move.w	#1,plane_ct(a6)
	movem.l	a0-a2/a5/a6,-(sp)
	.dc.w	bitblt
	movem.l	(sp)+,a0-a2/a5/a6
makmski:
	cmp.l	wblkptr,a0	;reached end yet?
	bcs	makmsk		;br if not.
*
	rts			;else, we're done
*
*
*
*
*  see if tile is completely off the world..
*
*  d0,d1,d2,d3 is x,y,w,h
*
*   returns Z if within world
*		d4,d5 destroyed
*	   NZ if outside world
*		d4 has bits set to indicate
*		   where its outside:	b3 - vert all above
*					b2 - vert all below
*					b1 - horz all left
*					b0 - horz all right
*
worldon:
	moveq	#0,d4
	cmp.w	w_wid(a5),d0	;are we completely to right?
	blt	noffr		;br if not
	bset.l	#0,d4
noffr:
	move.w	d0,d5		;are we completely to left?
	add.w	d2,d5
*	subq.w	#1,d5
*	bpl	noffl		;br if not
	bgt	noffl
*
	bset.l	#1,d4
noffl:
	cmp.w	w_hite(a5),d1	;are we completely below
	blt	nottb		;br if not
	bset.l	#2,d4
nottb:
	move.w	d1,d5
	add.w	d3,d5
*	subq.w	#1,d5
*	bpl	notta
	bgt	notta
*
	bset.l	#3,d4
notta:
	tst.w	d4
	rts
*
*
*
*
*
*
DaveClrWorld:
	movem.l	a0-a6/d0-d7,-(sp)
	lea	worldblk,a0
	move.l	a0,wblkptr
	move.l	a0,wblkcur
clearfloor:
	move.w	#-1,worldtile	;indicate no world tile
reworld:
	bsr	makewld
	bsr	makemsk
*
*	dc.w	$a00a		;hide mouse
*
*	movem.w	wx(a5),d0-d3
*	bsr	WindRefresh
*
*	dc.w	$a009		;show mouse
*
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
DaveTile:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	curbrush,worldtile
	moveq	#0,d0
	move.l	d0,initxtile
	move.l	d0,rowthoff
	move.l	d0,colthoff		;clear irregular stuff
	bra	reworld

DaveITile:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	curbrush,worldtile
*
	movem.w	Itile,d0-d5
	movem.w	d0-d5,initxtile
*	
	bra	reworld
*
NEW_BUT:
	tst	d0
	beq	place
	move.w	d0, BUT_STATE
	move.w	#1,d0			; always return left button
place:
	move.l	BUT_ADDR,-(sp)
	rts				; jmp to AES subroutine
*
*
*
*  Routine for sizing the world width and height
*
*     whenever this is called, derived graphics must be adjusted
*
DaveSize:
	movem.l	a0-a6/d0-d7,-(sp)
	lea	wstruct,a5
	movem.w	w_wid(a5),d4-d5		;get new width & height
*
DSz0:
	bsr	adjsize		;adjust buffers for new world
	beq	DSz1		;br if A-ok
	movem.w	d4-d5,-(sp)	;save proposed size
	bsr	TooBigRam	;ask user what to do
	movem.w	(sp)+,d4-d5
	tst.w	d0
	bne	DSz0		;retry with new
	movem.w	old_wid,d4-d5
*
DSz1:
	movem.w	d4-d5,wstruct+w_wid
*
*	Now, remove objects that fall off the new world..
*
	lea	worldblk,a0		;remove objects that fall off new	
	move.l	wblkptr,a1		;world
	move.l	wblkcur,a2
	bra	newsizi
newsizlp:
	movem.w	(a0)+,d0-d3	;get next entry
	cmp.w	d2,d4		;is this object off right side?
	ble	offobj		;br if so--object is out 'o this world
	cmp.w	d3,d5
	bgt	newsizi
*
*   remove the wholly clipped object
*
offobj:
	cmp.l	a0,a2		;is current priority object affected?
	bcs	offobj0		;br if current priority object not affected 
	subq.l	#8,a2		;else, adjust current priority object
offobj0:
	movem.l	a0/a2,-(sp)
	lea	-8(a0),a2
offobj1:
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	cmp.l	a1,a2
	bcs	offobj1	
	movem.l	(sp)+,a0/a2
	subq.l	#8,a0
	subq.l	#8,a1
newsizi:
	cmp.l	a1,a0
	bcs	newsizlp
	move.l	a1,wblkptr
	move.l	a2,wblkcur
	bra	reworld		;exit thru reworld
*
*
*
*
*
*  Entry:
*   d4 = proposed world width
*   d5 = proposed world height
*
*  Exit:
*    d0 = 0 if new size is approved and buffers rearranged
*    d0 = -1 if too big to fit, no change done; d4-d5 are sized to fit
*
adjsize:
*
*	Adjust derived graphics buffer placement & touch up all
*	derived graphics pointers..
*
	move.w	d4,d0
	addi.w	#15,d0
	andi.w	#$fff0,d0
	lsr.w	#1,d0		;determine new wrap
	mulu	d5,d0		;d0 = new world size
	move.l	d0,d1
	lsr.l	#2,d1
	addq.l	#8,d1		;d1 = new world's mask size
	add.l	d1,d0		;d0 = total ram requirements for new world
*
	move.l	derivdend,d1
	move.l	derivdgraf,d6	;d6 = base of derived graphics
	sub.l	d6,d1		;d1 = total dervided ram requirements
*
	move.l	world,d2	;d2 = base of world
	move.l	d2,d3
	add.l	d0,d3
	add.l	d1,d3
	cmp.l	malloend,d3	;are we exceeding RAM allocation?
	bcs	sizeok		;br if requested size is allowed
*
*   Size too big--find a good size that'll fit
*
	sub.l	malloend,d3	;d3 = how much we should shave off
	add.l	#256,d3		; give a little breathing room
*
	cmp.w	d4,d5		;which dimension is larger?
	bcc	hitebig		;br if height is larger
*
*  width is larger
*
	move.w	d5,d0		;copy hite to d0
	mulu	#10,d0		;d0 = amount each word of width adds
	divu	d0,d3
	addq.w	#1,d3
	lsl.w	#4,d3		;d3 = amount to subtract from width
	sub.w	d3,d4
	bra	sizenok
hitebig:
	move.w	d4,d0
	addi.w	#15,d0
	andi.w	#$fff0,d0
	lsr.w	#1,d0		;re-determine wrap
	move.w	d0,d1
	lsr.w	#2,d1
	add.w	d1,d0		;d0 = # of bytes needed/line of height
	divu	d0,d3
	addq.w	#1,d3
	sub.w	d3,d5
sizenok:
	moveq	#-1,d0
	rts
*
*   It fits, now adjust derived graphics ptrs
*
sizeok:
	move.l	d6,d3
	sub.l	d2,d3		;get old world ram requirements
*
*	d0.l	- new world RAM requirements
*	d1.l	- derived graphics RAM requirements
*	d2.l	- base of world
*	d3.l	- old world RAM requirements
*
*
*	d6.l	- old base of derived graphics
*
*
	move.l	d0,d7
	sub.l	d3,d7		;signed difference in RAM requirements
	beq	notouch		;br if no derived graphics need move
*
*   Touch up all derived graphics ptrs
*
	lea	bshblock,a2
	move.w	maxintrins,d3
	bra	touchlpi
touchlp:
	lsl.w	#4,d3
	add.l	d7,4(a2,d3.w)	;touch-up new base addr
	lsr.w	#4,d3
touchlpi:
	addq.w	#1,d3
	cmp.w	maxderivd,d3
	bls	touchlp
*
	add.l	d0,d2	;d2 = new base of derived graphics
*
	move.l	d6,a0		;old derived base
	move.l	d2,a1		;new derived base
	move.l	a1,derivdgraf	;save new ptr
	add.l	d1,d2
	move.l	d2,derivdend	;save new end
*
	tst.l	d7	;check for move up or down memory lane
	bpl	backup	;br if we're expanding
*
*  We're contracting, use low ends
*
	lsr.l	#2,d1	;# of longs in derived graphics (-1 or 0 adjust)
	bra	forlp0
forlp1:
	swap	d1
forlp0:
	move.l	(a0)+,(a1)+
forlpi:
	dbra	d1,forlp0
	swap	d1
	dbra	d1,forlp1
*
	bra	notouch		;we're done
*
*  We're expanding, use high ends
*
backup:
	adda.l	d1,a0	;old derived end (+1)
	adda.l	d1,a1	;new derived end (+1)
	lsr.l	#2,d1	;# of longs in derived graphics (-1 or 0 adjust)
	bra	backlp0
backlp1:
	swap	d1
backlp0:
	move.l	-(a0),-(a1)
backlpi:
	dbra	d1,backlp0
	swap	d1
	dbra	d1,backlp1
*
notouch:
	moveq	#0,d0
	rts
*
*
*
* New Grid Function - no inputs or outputs
* The new Grid Sizes are in the globals - gridx, gridy, gridw,gridh
DaveGrid:
	   rts
*
*
* New Mouse Movement Vector Function
NEW_MOV:
	move.l	MOV_ADDR,-(sp)
	rts
*
*
* Will be calling the Irregular Tile Setup dialog box.
* This function must set the global variables.
*     TileText - string array for object name - 10 characters max
*     All below are ints - max 999, tell me if more is necessary
*     tilex
*     tiley
*     tilexrow
*     tileyrow
*     tilexcol
*     tileycol
ITileSetup:
	lea	Itile+12,a4
*
*  entry
*  a4 -> destination string
*
*  a2, a3
gstring:
	move.w	curbrush,d0
	ext.l	d0	
	lsl.l	#4,d0		;*16 to get index into brush block
	lea	bshblock,a2
	adda.w	d0,a2
	move.l	8(a2),a3	;ptr to id_string
*
	moveq	#10,d0		;Cary sez only 11 chars allowed
itilp:
	move.b	(a3)+,d1
	cmpi.b	#" ",d1
	bls	itilpx
	move.b	d1,(a4)+
	dbra	d0,itilp
itilpx:
	clr.b	(a4)+
itiled:
	rts
*
*
*
GetCurObj:
	move.l	a0,a4
	bsr	gstring		;copy object ID string to a0
	move.l	(a2),4(a1)	;get width & height also
	rts
*
*
*
*
ClrFloor:
	movem.l	a0-a6/d0-d7,-(sp)
	bra	clearfloor
*
*
*
LoadPal:
	move.w	curbrush,d0
	cmp.w	maxintrins,d0
	bhi	loadpal0	
	move.w	d0,firstpal
loadpal0:
	bra	switch1
*
*
*
*  d0 = brush #
*  a0 -> bshblock
*
upname:
	movem.l	a0-a6/d0-d7,-(sp)
	bra	upn
*
* d0 - # of key ( 0 - 9 ) ( reads)
*
Func_Key:
	movem.l	a0-a6/d0-d7,-(sp)
	lsr.w	#7,d0
	lea	Func_Array,a0
	move.w	(a0,d0.w),d0
	cmp.w	maxderivd,d0
	bgt	funkey0		;br if we can't take this
*
	lea	bshblock,a0
	lsl.w	#4,d0
	tst.w	(a0,d0.w)	;are we a real brush
	beq	funkey0		;br if not real
*
	lsr.w	#4,d0
	move.w	d0,curbrush
*
*  Put out name (are we derived)
*
upn:	
	lea	brshfile,a1
	move.w	d0,d1
	lsl.w	#4,d0
	adda.w	d0,a0
	move.l	8(a0),a0

	cmp.w	maxintrins,d1
	bls	oname
*
*  we are derived
*
	move.l	(a0),a0
oname:
	move.b	(a0)+,d0
	move.b	d0,(a1)+
	cmpi.b	#" ",d0
	bhi	oname
	clr.b	-(a1)
	lea	brshfile,a0
	move.w	#LIBRARY,d0
	bsr	DaveInfo		
funkey0:
	movem.l	(sp)+,a0-a6/d0-d7
	bsr	Back2G
	rts
*
*
*
*
*   We call this whenever we go back to Cary (curbrush : cluster check)
*
Back2G:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	curbrush,d1
Back0:
	moveq	#0,d0		;assume non-cluster
	cmp.w	maxintrins,d1
	bls	Back1		;br if intrinsic
*
*  we may be a cluster
*
	moveq	#1,d0		;assume cluster
	lsl.w	#4,d1
	lea	bshblock,a0
	move.l	8(a0,d1.w),a1
	tst	4(a1)		;are we a cluster?
	bne	Back1		;br if so
*
*
	move.w	6(a1),d1	;get next indirect brush
	bra	Back0	
Back1:
	bsr	SetCluster	;set cluster active/inactive
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
* d0 - # of key ( 0 - 9 ) ( writes )
*
Shift_Func_Key:
	movem.l	a0-a6/d0-d7,-(sp)
	lsr.w	#7,d0
	lea	Func_Array,a0
	move.w	curbrush,(a0,d0.w)
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*

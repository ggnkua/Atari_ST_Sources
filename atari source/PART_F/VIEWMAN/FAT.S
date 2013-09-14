*
*
	.include	"equates.s"
*
*	a0 -> plane 0 of SRC
*	a1 -> plane 0 of DST
*	d5 = dot addr of left edge (0 mod 4, i.e left2rite 0,4,8,$c)
*	d6 = width in 4-pixel blocks (right fringe must end on word)
*	d7 = height in pixels
*
*
fat:
	movem.l	a0-a6/d0-d7,-(sp)
	lea	wstruct,a5
	tst.w	faton		;is fat initialized?
	bne	fatgo		;br if all set
*
*  is library window available?
*
	lea	w,a0
	movem.w	10(a0),d0-d3
	lea	l,a0
	movem.w	10(a0),d4-d7
	add.w	d0,d2	
	add.w	d1,d3
*	
	add.w	d4,d6	
	add.w	d5,d7	
	cmp.w	form_width,d6
	bcc	fatout
	cmp.w	form_height,d7
	bcc	fatout
*
	cmp.w	d0,d4	;is world left-edge left of library left-edge?
	bcc	lftwrd	;br if so
	cmp.w	d0,d6	;is world left-edge left of library rite-edge?
	bcs	noover	;br if no overlap
	bra	hitechk
lftwrd:
	cmp.w	d2,d4	;is world rite-edge left of library left-edge?
	bcc	noover	;exit if not
hitechk:
	cmp.w	d1,d5
	bcc	topwrd
	cmp.w	d1,d7
	bcc	fatout
	bra	noover
topwrd:
	cmp.w	d3,d5
	bcs	fatout
noover:
	move.w	#-1,faton
*
	clr.w	fatx
	clr.w	faty
	clr.w	fathold
*
	lea	fatblk,a6
	move.l	library,a0
	move.l	a0,s_form(a6)
*	
	move.l	oldphyz,a0
	move.l	a0,d_form(a6)
	move.w	l_wid(a5),d0
	add.w	#15,d0
	and.w	#$fff0,d0
	lsr.w	#1,d0
	move.w	d0,s_nxln(a6)
	move.w	scr_nxln,d0
	move.w	d0,d_nxln(a6)
	move.w	lxoffset(a5),s_xmin(a6)
	move.w	lyoffset(a5),s_ymin(a6)
	move.w	lx(a5),d_xmin(a6)
	move.w	ly(a5),d_ymin(a6)
	move.w	lwidth(a5),b_width(a6)
	move.w	lheight(a5),b_height(a6)
	move.w	#4,plane_ct(a6)
	dc.w	bitblt

fatgo:
	move.w	lx(a5),d0
	move.w	d0,d6
	add.w	lwidth(a5),d6
	add.w	#15,d0
	andi.w	#$fff0,d0
	andi.w	#$fff0,d6
	sub.w	d0,d6
	lsr.w	#2,d6		;here is our width
*	
	move.w	lheight(a5),d7
	lsr.w	#2,d7		;here is our height
*
	subq.w	#2,d7		;adjust for dbra
*
	move.l	oldphyz,a0
	move.l	a0,a1
*
	move.w	fathold,d1	;check for alt key
	beq	fat00		;br if off
	bpl	fat01x		;br if trail or on
	move.w	bsh_y,oldbshy	;leading edge--save ypos
	bra	fat00
fat01x:
	move.w	oldbshy,d0	;assume no edges
	cmp.w	#2,d1
	beq	fat00x		;br if no edges
*
*  trailing edge--compute new adjust
*
	sub.w	bsh_y,d0
	add.w	d0,faty
fat00:
	move.w	bsh_y,d0
fat00x:
	add.w	faty,d0
	move.w	d7,d1
	lsr.w	#1,d1
	sub.w	d1,d0
	bpl	fat0
	moveq	#0,d0
fat0:
	move.w	d0,d1
	add.w	d7,d1
	sub.w	form_height,d1
	bmi	fat0x
	sub.w	d1,d0
fat0x:
	mulu	scr_nxln,d0
	add.l	d0,a0
*

	move.w	fathold,d1	;check for alt key
	beq	fat10		;br if off
	bpl	fat11x		;br if trail or on
	move.w	bsh_x,oldbshx	;leading edge--save xpos
	bra	fat10
fat11x:
	move.w	oldbshx,d0	;assume no edges
	cmp.w	#2,d1
	beq	fat10x		;br if no edges
*
*  trailing edge--compute new adjust
*
	sub.w	bsh_x,d0
	add.w	d0,fatx
fat10:
	move.w	bsh_x,d0
fat10x:
	add.w	fatx,d0
	move.w	d6,d1
	lsr.w	#2,d6		;get 4-pixel blocks
	lsr.w	#1,d1
	sub.w	d1,d0
	bpl	fat1
	moveq	#0,d0
fat1:
	move.w	d0,d5
	not.w	d5
	andi.w	#$f,d5
	addq.w	#1,d5		;get long shift count
*
	andi.w	#$fff0,d0
	lsr.w	#1,d0
	add.w	d0,a0		;a0->SRC
*
	move.w	ly(a5),d0
	addq.w	#1,d0
	mulu	scr_nxln,d0
	adda.l	d0,a1
	move.w	lx(a5),d0
	add.w	#15,d0
	andi.w	#$fff0,d0
	lsr.w	#1,d0
	add.w	d0,a1		;a1 -> DST
*
	move.w	scr_nxln,d2

	lea	(a1,d2.w),a2
	lea	(a2,d2.w),a3
	lea	(a3,d2.w),a4
*
	move.l	a0,a5
	move.l	a1,a6
*
	swap	d5
fatlp0:
	move.w	d7,-(sp)
	move.w	d6,d5
fatlp1:
	swap	d5		;get dot addr
	movem.w	(a0)+,d0-d3	;pick up 4 planes worth
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	subq.l	#8,a0
	lsr.l	d5,d0
	lsr.l	d5,d1
	lsr.l	d5,d2
	lsr.l	d5,d3
	rol.w	#1,d0
	rol.w	#1,d1
	rol.w	#1,d2
	rol.w	#1,d3
	swap	d5
*
	moveq	#3,d7
fatlp:
	rol.w	#4,d0
	moveq	#$1e,d4
	and.w	d0,d4
	move.w	nibtab(pc,d4.w),d4
	move.w	d4,(a1)+
	move.w	d4,(a2)+
	move.w	d4,(a3)+
	clr.w	(a4)+
*
	rol.w	#4,d1
	moveq	#$1e,d4
	and.w	d1,d4
	move.w	nibtab(pc,d4.w),d4
	move.w	d4,(a1)+
	move.w	d4,(a2)+
	move.w	d4,(a3)+
	clr.w	(a4)+
*
	rol.w	#4,d2
	moveq	#$1e,d4
	and.w	d2,d4
	move.w	nibtab(pc,d4.w),d4
	move.w	d4,(a1)+
	move.w	d4,(a2)+
	move.w	d4,(a3)+
	clr.w	(a4)+
*
	rol.w	#4,d3
	moveq	#$1e,d4
	and.w	d3,d4
	move.w	nibtab(pc,d4.w),d4
	move.w	d4,(a1)+
	move.w	d4,(a2)+
	move.w	d4,(a3)+
	clr.w	(a4)+
	subq.w	#1,d5
	beq	newrow
	dbra	d7,fatlp
	bra	fatlp1
*	
nibtab:
	dc.w	%0000000000000000
	dc.w	%0000000000001110
	dc.w	%0000000011100000
	dc.w	%0000000011101110
	dc.w	%0000111000000000
	dc.w	%0000111000001110
	dc.w	%0000111011100000
	dc.w	%0000111011101110
	dc.w	%1110000000000000
	dc.w	%1110000000001110
	dc.w	%1110000011100000
	dc.w	%1110000011101110
	dc.w	%1110111000000000
	dc.w	%1110111000001110
	dc.w	%1110111011100000
	dc.w	%1110111011101110
*
newrow:
	move.w	scr_nxln,d4
	adda.w	d4,a5
	move.l	a5,a0
	move.w	d4,d5
	lsl.w	#2,d5
	adda.w	d5,a6
	move.l	a6,a1
	lea	(a1,d4.w),a2
	lea	(a2,d4.w),a3
	lea	(a3,d4.w),a4
	move.w	(sp)+,d7
	dbra	d7,fatlp0
fatout:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
fatquit:
	tst.w	faton
	beq	fatdone
	move.l	a0,-(sp)
	lea	wstruct,a0
	lea	lx(a0),a0
	bsr	LibraryDraw
	move.l	(sp)+,a0
	clr.w	faton
fatdone:
	rts
*
	
faton:
	dc.w	0		;0=fat not on
fathold:
	dc.w	0	;ALT key:0=not down,2=down,-1=lead,1=trail
fatx:
	dc.w	0		;hot spot adjust values
faty:
	dc.w	0
oldbshx:
	dc.w	0
oldbshy:
	dc.w	0
fatblk:
	dc.w	0,0,0,0,0
	dc.l	$0		;op_tab
	dc.w	0,0		;s_xmin,s_ymin
	dc.l	0		;s_form
	dc.w	8,0,2
*
	dc.w	0,0		;d_xmin,d_ymin
	dc.l	0		;d_form
	dc.w	8,0,2
*
	dc.l	0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0

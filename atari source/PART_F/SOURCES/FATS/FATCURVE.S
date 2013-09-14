*
*   Fatcurve.s    Shape drawing stuff
*
*
*  Latest update:  3 Aug 86
*
	.include	"fatequ.s"
*
	.globl	rect,rndrect,ellipse,polypnt,polyline,setxlate,_pblock
*
	.globl	brshupd,blitmask,constran,strainx,strainy,strain8
	.globl	physadd,curscren,othscren,shapebuf,hollow,screen0
	.globl	colleft,selctcol,undoyet,linethik
	.globl	contrl,ptsin,vdicall
	.globl	screnswp,handy,full
	.globl	upbutx,p_block,bitblt
	.globl	pointcnt,curpoint,slopex,slopey,matxupd
*
*
	.globl	fg_bp_1,fg_bp_2,fg_bp_3,fg_bp_4
	.globl	lstlin,ln_mask,wrt_mode,x1,y1,x2,y2
*
polyfill	equ	$a006
contrll	equ	4
ptsinn	equ	12
patptr	equ	46
patmsk	equ	50
*
*
*  rectangle draw
*
rect:
	movem.l	d0-d3,-(sp)
	moveq	#-1,d4
	move.w	d4,yadj
	move.w	d4,xstretch
	clr.w	cornadj
	move.w	selctcol,d4
	tst.w	hollow
	beq.s	rect1
	move.w	colleft,d4
rect1:
	move.w	d4,ellicol
	bra.s	boxit
*
corntab:
	.dc.b	16,16,16,16,18,18,20,20,22,16
*
*  rounded rectangle
*
rndrect:
	lea	shapebuf,a6
	move.w	(a6),d4
	move.b	corntab(pc,d4),d4
	ext.w	d4
	move.w	d4,cornadj
	movem.l	d0-d3,-(sp)
	clr.w	xstretch	;assume no horz adjustment
	move.w	d0,leftx	;save lefrtmost position
	move.w	d2,d4
	sub.w	cornadj,d4		;rounded corner is arc of diameter 16
	sub.w	d0,d4
	blt.s	noxstr		;br if no x stretch needed
	move.w	d4,xstretch	;we'll need this later
	add.w	d4,d0
noxstr:
	clr.w	yadj		;assume no vert stretch
	move.w	d3,d4
	sub.w	cornadj,d4		;vert diameter of corner arc is 16
	sub.w	d1,d4
	blt.s	noystr
	add.w	d4,d1
	mulu	#160,d4
	move.w	d4,yadj
noystr:
	bsr	ellit
	lsr.w	cornadj
boxit:
*
*	move.w	#-1,-(sp)
*	move.l	#-1,-(sp)
*	move.l	othscren,-(sp)
*	move.w	#5,-(sp)
*	trap	#14
*	adda.w	#12,sp
*
	movem.l	(sp)+,d0-d3
	move.w	yadj,d4
	beq.s	postl
	tst.w	hollow
	beq.s	postl
	movem.l	d0-d3,-(sp)
	add.w	cornadj,d1
	sub.w	cornadj,d3
	move.w	selctcol,d4
	moveq	#1,d5
	bsr	fillboxo
	movem.l	(sp)+,d0-d3
postl:
	lea	shapebuf,a6
	move.w	(a6),d6
	beq	postq
	subq.w	#1,d6
	move.w	ellicol,d4
	moveq	#1,d5
	tst.w	yadj
	beq.s	noyadj
	movem.w	d0-d3,-(sp)
	add.w	cornadj,d1
	sub.w	cornadj,d3
	move.w	d2,-(sp)
	move.w	d0,d2
	add.w	d6,d2
	cmp.w	(sp),d2
	blt.s	lefok
	move.w	(sp),d2
lefok:
	bsr	fillboxo
	move.w	(sp)+,d2
	move.w	d2,d0
	sub.w	d6,d0
	cmp.w	(sp),d0
	bgt.s	ritok
	move.w	(sp),d0
ritok:	
	bsr	fillboxo
	movem.w	(sp)+,d0-d3
noyadj:
	tst.w	xstretch
	beq.s	postq
	add.w	cornadj,d0
	sub.w	cornadj,d2
	move.w	d3,-(sp)
	move.w	d1,d3
	add.w	d6,d3
	cmp.w	(sp),d3
	blt.s	topok
	move.w	(sp),d3
topok:
	bsr	fillboxo
	move.w	(sp)+,d3
	move.w	d1,-(sp)
	move.w	d3,d1
	sub.w	d6,d1
	cmp.w	(sp),d1
	bgt.s	botok
	move.w	(sp),d1
botok:	
	bsr	fillboxo
	addq.l	#2,sp
postq:
	rts
*
*  poly-point
*
polypnt:
	move.w	d2,d7
	andi.w	#$c,d7			;any leading edges?
	beq.s	noplead
*
*  starting a new poly point
*
	clr.b	undoyet
	move.w	#500,d7		;put in a ridiculous value
	move.w	d7,slopex	;for previous point slopes
	move.w	d7,slopey
*
	move.w	d4,ymax
	move.w	d4,ymin
*
	move.w	selctcol,d7
	move.w	d7,plotcol
	tst.w	hollow
	beq.s	nocoleft
	move.w	colleft,d7
nocoleft:
	move.w	d7,selctcol
	move.l	#blitmask,a0		;use blitmask buffer for verrtices
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	move.l	a0,curpoint
	move.w	#1,pointcnt
	bra	contpnt
*
*
noplead:
	move.w	d2,d7
	andi.w	#$30,d7			;trailing edges?
	beq	noptrail
	addq.w	#1,pointcnt
*
*  terminate polypoint session
*
polype:
	cmpi.w	#2,pointcnt
	bcs	polyqq
*
	move.l	curpoint,a0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
*
	move.w	#3,d2
*
	bsr	brshupd
*
	move.w	d0,d3
	move.w	d1,d4
*
	lea	blitmask,a1
	move.w	(a1)+,d0
	move.w	(a1)+,d1
*
	move.w	d0,(a0)+
	move.w	d1,(a0)+
*
	bsr	brshupd
*
	move.w	plotcol,selctcol
	tst.w	hollow
	beq	polyqq
*
	move.l	screen0,a0
	move.l	othscren,a1
	move.l	a1,a2
	move.w	#1999,d7
	tst.w	full
	bne.s	dofull
	move.w	#999,d7
	move.w	handy,d6
	mulu	#160,d6
	adda.w	d6,a0
dofull:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,dofull
*
	move.w	#-1,-(sp)
	move.l	#-1,-(sp)
	move.l	a2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
*
*	bsr	setxlate
*	move.l	#blitmask,_pblock+8
*	lea	contrl,a0
*	move.w	#9,(a0)+
*	move.w	pointcnt,(a0)+
*	clr.l	(a0)+
*	bsr	vdicall
*	move.l	#ptsin,_pblock+8
*
	.dc.w	$a000			;line a init
	move.l	#blitmask,ptsinn(a0)	;ptsin array ptr
	move.l	#pointcnt-2,contrll(a0)	;contrl array ptr
	move.w	selctcol,d7		;load color
	lea	fg_bp_1(a0),a1
	moveq	#3,d5
fgcolp:
	move.w	d7,d6
	andi.w	#1,d6
	move.w	d6,(a1)+
	lsr.w	#1,d7
	dbra	d5,fgcolp
*
	clr.w	wrt_mode(a0)		;replace mode
	move.l	#all_ones,patptr(a0)
	clr.w	patmsk(a0)
*
	move.w	ymin,d0
	move.w	ymax,d7
	sub.w	d0,d7
	move.l	a0,a4
	move.w	d0,y1(a4)
polyylp:
	.dc.w	polyfill
	addq.w	#1,y1(a4)
	dbra	d7,polyylp
*
*  end new stuff
*
	tst.w	linethik
	beq.s	noline
	move.l	curscren,-(sp)
	move.l	othscren,curscren		;fool brush routine
	move.w	colleft,selctcol
	move.w	pointcnt,d7
	move.l	#blitmask,curpoint
	bra.s	brshe
brshloop:
	move.w	d7,-(sp)
	move.l	curpoint,a1
	move.w	(a1)+,d3
	move.w	(a1)+,d4
	move.l	a1,curpoint
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	moveq	#1,d2
	bsr	brshupd
	move.w	(sp)+,d7
brshe:
	dbra	d7,brshloop
*
	move.l	(sp)+,curscren
noline:
	move.w	plotcol,selctcol
	bsr	screnswp
polyqq:
	clr.w	pointcnt
	clr.b	undoyet
	rts
*
*
noptrail:
	move.w	d2,d7
	andi.w	#3,d7
	beq	polypq
*
*  continue with poly points
*
	tst.w	pointcnt
	beq	polypq
contpnt:
	addq.w	#1,pointcnt
	tst.w	hollow
	beq	dobrsh
	cmpi.w	#512,pointcnt
	bcc	polype
*
	move.l	curpoint,a0
	move.w	-2(a0),d6
	move.w	-4(a0),d5
	sub.w	d0,d5
	bne.s	formy
	tst.w	slopex
	bne.s	formy
	sub.w	d1,d6
	move.w	slopey,d7	;get prev
	move.w	d6,slopey
	eor.w	d6,d7		;sign change?
	bpl.s	noentry		;same sign, do noentry
	bra.s	addentry	;else, add entry
formy:
	sub.w	d1,d6
	bne.s	slopchk
	tst.w	slopey
	bne.s	slopchk
	move.w	slopex,d7	;get prev
	move.w	d5,slopex
	eor.w	d5,d7		;sign change?
	bmi.s	addentry	;if so, add this entry anyway
noentry:
	subq.w	#1,pointcnt
	move.w	d0,-4(a0)
	move.w	d1,-2(a0)
	bra.s	dobrsh
slopchk:
	move.l	d5,a1
	move.l	d6,a2
	tst.w	d5
	beq.s	addent
	ext.l	d6
	divs	d5,d6
	move.w	slopex,d5
	beq.s	addent
	move.w	slopey,d7
	ext.l	d7
	divs	d5,d7
	cmp.l	d7,d6
	beq.s	noentry
addent:
	move.w	a1,slopex
	move.w	a2,slopey
addentry:
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.l	a0,curpoint
dobrsh:
*
	bsr.s	updmxmin
*
*  end new stuff
*
	clr.b	constran
	bra	brshupd
polypq:
	rts
*
*
*  update max/min on y co-ordinate
*
updmxmin:
*  new stuff
	cmp.w	ymax,d1
	bls.s	noymax
	move.w	d1,ymax
noymax:
	cmp.w	ymin,d1
	bcc.s	noymin
	move.w	d1,ymin
noymin:
	rts
*
*************************************************
*
*
*    poly line routine
*
polyline:
	btst.l	#3,d2		;right leading edge?
	bne.s	polyle		;br over if so
*
polylx:
*
	btst.l	#2,d2		;left leading edge?
	beq	nopllead	;br if not
*
	tst.w	pointcnt	;poly line in progress?
	bne	nextpl1		;if so, just do next line (ignore leading edge)
*
	bra.s	notdoub
*
polyle:
	tst.w	pointcnt
	beq	polylq
*
*  terminate polyline
*
	addq.w	#1,pointcnt
polypex:
	clr.b	upbutx
*
	bsr	strain8
	clr.b	constran
	move.w	d0,d3
	move.w	d1,d4
*
*test	bsr	updmxmin	;this instruction omitted to test the testers
	bsr	updmxmin	;this instruction omitted to test the testers
*
	bra	polype
*
notdoub:
*
*  start a new poly line
*
	move.b	#1,upbutx
	move.w	selctcol,d7
	move.w	d7,plotcol
	tst.w	hollow
	beq.s	ncoleft
	move.w	colleft,d7
ncoleft:
	move.w	d7,selctcol
*
	movea.l	curscren,a0
	movea.l	othscren,a1
	movea.l	physadd,a2
	move.w	#1999,d7
	tst.w	full
	bne.s	notpfull
	move.w	#999,d7
notpfull:
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d7,notpfull	
*
	move.w	d1,ymin
	move.w	d1,ymax
	move.w	#1,pointcnt
	move.l	#blitmask,a0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.l	a0,curpoint
	move.w	d0,d3
	move.w	d1,d4
	bsr	brshupd
	rts	
nopllead:
	tst.w	pointcnt
	beq	polylq		;br to exit if none in progress
*
nextpl1:
	move.l	curpoint,a0
	move.w	-2(a0),d4
	move.w	-4(a0),d3
*
	btst.l	#4,d2		;left trailing edge?
	beq.s	nextpl		;br if not--do next poly line
*
	addq.w	#1,pointcnt
	cmpi.w	#512,pointcnt
	bcc	polypex
*
*  draw next line segment on othscren
*
nextpl:
	movea.l	physadd,a0	;clean up othscren
	movea.l	othscren,a1
	move.w	#1999,d7
	tst.w	full
	bne.s	itsfull
	move.w	#999,d7
itsfull:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,itsfull
*
	move.l	curscren,-(sp)
	move.l	othscren,curscren
	move.w	d2,-(sp)
	moveq	#1,d2
	bsr	brshupd
	move.w	(sp)+,d2
	move.l	(sp)+,curscren
*
	btst.l	#4,d2		;just finish a trailing edge?
	beq.s	doswap		;br if not
*
	move.l	curpoint,a0	;record this point
	move.w	d0,(a0)+
	move.w	d1,(a0)+
*
	move.l	a0,curpoint	;advance ptr
	bsr	updmxmin	;  to "permanently" record this vertex
	move.w	d0,strainx
	move.w	d1,strainy
*
	movea.l	othscren,a0	;record new line segment in background buffer
	movea.l	physadd,a1
	move.w	#1999,d7
	tst.w	full
	bne.s	fullok
	move.w	#999,d7
fullok:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,fullok
*
	tst.b	constran
	beq.s	doswap
	bset.b	#7,matxupd
doswap:
	bsr	screnswp
polylq:
	rts
*
*
*
*
*   8-way-step ellipse draw routine
*
*
*   input:
*		d0.w  = top/left x
*		d1.w  = top/left y
*		d2.w  = bot/rite x
*		d3.w  = bot/rite y
*
* internal use:  
*
*  ACM label	contents	68000 reg
*
*	x	current x	d0.w
*	y	current y
*	    right bit # (*4)	d1.w
*	t1	  a**2		
*	t2	2(a**2)		d2.l		
*	t3	4(a**2)		d3.l
*	t4	  b**2
*	     left bit #	(*4)	d4.w
*	     offset to upper	d5.w
*	      right addr	a0.l
*	       left addr	a1.l
*	t5	2(b**2)		a4.l
*	t6	4(b**2)		a5.l
*	t7     2a(b**2)
*	t8     4(b**2)x		a2.l
*	t9     4(a**2)y		a3.l
*	d1    region1 discrim	d6.l
*	d2    region2 discrim	d7.l
*
*		
*
*
ellipse:
	move.w	d0,leftx	;set this up for pure ellipse
	clr.w	yadj		
ellit:
	move.w	selctcol,ellicol
	tst.w	hollow		;do filled ellipse?
	beq.s	nofill		;br if not--outline is all
*
*  do filled portion 1st
*
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	#-1,dofill
	move.w	leftx,d4
	move.w	d4,-(sp)
	lea	shapebuf,a6
	cmpi.w	#2,(a6)
	bcs.s	nofadj
	addq.w	#1,d0
	addq.w	#1,d4
	subq.w	#1,d2
	cmp.w	d0,d2
	bgt.s	fadjok
	addq.w	#1,d2
	subq.w	#1,d0
	subq.w	#1,d4
fadjok:
	move.w	d4,leftx
	addq.w	#1,d1
	subq.w	#1,d3
	cmp.w	d1,d3
	bgt.s	nofadj
	addq.w	#1,d3
	subq.w	#1,d1
nofadj:
	bsr.s	ellie
	move.w	(sp)+,leftx		
	movem.l	(sp)+,a0-a6/d0-d7
	move.w	colleft,ellicol
nofill:
	clr.w	dofill
*
*  set-up for perimeter stuff
*
	movem.l	a0-a6/d0-d7,-(sp)
	lea	shapebuf,a6	;pick up adjusted thickness
	move.w	(a6),d4
	subq.w	#1,d4
	bls.s	noeladj
	move.w	d2,d5
	sub.w	d4,d2
	bcs.s	fixx
	cmp.w	d0,d2
	bcc.s	doyadj
fixx:
	bra.s	fillone
doyadj:
	sub.w	d4,d3
	bcs.s	fixy
	cmp.w	d1,d3
	bcc.s	noeladj
fixy:
	add.w	d4,d3
fillone:
	move.w	d5,d2
	move.w	#-1,dofill
noeladj:
	bsr.s	ellie
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*  ellipse routine proper
*
ellie:
	move.w	d2,d4
	sub.w	d0,d4
*
	move.w	d3,d5
	sub.w	d1,d5
	cmp.w	d5,d4
	blt	elliev
*
	lsr.w	#1,d4		;   = horz radius
*
	move.w	d2,d5		;right most xpos
	not.w	d5
	andi.w	#$f,d5		;d5 = bit # of rightmost pixel in word
	movea.w	d5,a6		;save in a6
*
	sub.w	d1,d3
	addq.w	#1,d3		;d3 = vert diameter
	clr.l	a5
	lsr.w	#1,d3		;d3 = vert radius
	bcs.s	radodd
	movea.w	#-160,a5
	addq.w	#1,d1
	subq.w	#1,d3
radodd:
	sub.w	yadj,a5		;adjust for vert stretch, if any
	add.w	d3,d1		;d1 = origin y
*
	move.l	othscren,a0	;get base address for this screen
	mulu	#160,d1		;add origin y offset
	adda.w	d1,a0		;  to a0
	move.l	a0,a1		;  save in a1 too
*
	move.w	d2,d5		;rightmost xpos
	lsr.w	#1,d5
	andi.w	#$fff8,d5
	adda.w	d5,a0		;a0=address of rightmost plane0 word
*
	move.w	leftx,d0	;get leftmost pixel; ellipse/round rectangle
	move.w	d0,d5		;d5 = leftmost pixel
	not.w	d5
	andi.w	#$f,d5		;d5 = bit # of leftmost pixel in word
	move.w	d5,a4		;save in a4
*
	lsr.w	#1,d0
	andi.w	#$fff8,d0
	adda.w	d0,a1		;a1=address of leftmost plane0 word
*
	move.w	d3,d1		;d1 = vert radius
	move.w	d4,d0		;d0 = horz radius
*
*  do previous stuff
*
	move.w	d0,d2		;a->d2
	mulu	d2,d2		;t1 = a**2
	move.l	d2,d7		
	lsr.l	#1,d7		;discriminator2 = t1 /2
	add.l	d2,d2		;t2 = 2(a**2)
	move.l	d2,d3
	add.l	d3,d3		;t3 = 4(a**2)
	mulu	d1,d1		;t4 = b**2
	move.l	d1,d6		;
	lsr.l	#1,d6		;discriminator1 = t4 /2
	move.l	d1,d4
	add.l	d4,d4		;t5 = 2(b**2)
	move.l	d4,d5		;t6
	add.l	d5,d5		;t6 = 4(b**2)
	move.l	d4,d1		;d1 = t5
	mulu	d0,d1		;t7 = a*t5
	sub.l	d1,d6		;discriminator1 = t4 /2 - t7
	add.l	d2,d6		;discriminator1 = t2 - t7 - t4 /2
	add.l	d1,d1
	move.l	d1,a2		;t8 = 2*t7
	moveq.l	#0,d1		;y = 0
	move.l	d1,a3		;t9 = 0
	sub.l	a2,d7		;discriminator2 = t1 /2 - t8
	add.l	d4,d7		;discriminator2 = t1 /2 - t8 + t5
*
	exg.l	a4,d4
	exg.l	a5,d5
	move.l	a6,d1
*
	lea	shapebuf,a6
*
*
*
*   now do region loops
*
doreg1:
	tst.l	d7		;d2 < 0 ?
	bpl.s	doreg2		;br to skip region 1 if not
*
*  region 1
*
	bsr	plotxy		;else setpixel(x,y)
*
	adda.w	#160,a0
	adda.w	#160,a1		;increment y regardless
	subi.w	#320,d5
*
	adda.l	d3,a3		;t9 := t9 + t3
*
	tst.l	d6		;d1 < 0 ?
	bpl.s	stepc
*
*  step to D if d1 < 0
*
	add.l	a3,d6
	add.l	d2,d6		;d1 := d1 + t9 + t2
*
	add.l	a3,d7		;d2 := d2 + t9
	bra.s	doreg1		;back to while test
*
*  step to C if d1 >= 0
*
stepc:
	subq.w	#1,d0		;x := x - 1
*
	addq.w	#1,d1		;move right bit # to the left
	andi.w	#$f,d1
	bne.s	stepc0
	subq.l	#8,a0
stepc0:
	subq.w	#1,d4		;move left bit # to the right
	bpl.s	stepc1
	moveq	#15,d4
	addq.l	#8,a1
stepc1:
*
	suba.l	a5,a2		;t8 := t8 - t6
*
	sub.l	a2,d6		
	add.l	a3,d6
	add.l	d2,d6		;d1 := d1 - t8 + t9 + t2
*
	sub.l	a2,d7
	add.l	a4,d7
	add.l	a3,d7		;d2 := d2 - t8 + t5 + t9
	bra.s	doreg1
*
*  Region 2 of ellipse..
*
doreg2:
	bsr	plotxy		;setpixel(x,y)
	suba.l	a5,a2		;t8 := t8 - t6
*
	tst.l	d7		;if d2 < 0
	bpl.s	stepb		;do next, else branch to step to B
*
*  step to pixel C
*
	adda.w	#160,a0
	adda.w	#160,a1
	subi.w	#320,d5
*
	adda.l	d3,a3		;t9 := t9 + t3
*
	sub.l	a2,d7
	add.l	a4,d7
	add.l	a3,d7		;d2 := d2 - t8 + t5 + t9
*
	bra.s	loopi
*
*  step to pixel B
*
stepb:
	sub.l	a2,d7
	add.l	a4,d7		;d2 := d2 - t8 + t5	
loopi:
	addq.w	#1,d1		;move right bit # to the left
	andi.w	#$f,d1
	bne.s	stepc2
	subq.l	#8,a0
stepc2:
	subq.w	#1,d4		;move left bit # to the right
	bpl.s	stepc3
	moveq	#15,d4
	addq.l	#8,a1
stepc3:
	dbra	d0,doreg2	;x := x - 1, repeat until x < 0
*
	rts
*
*  vertical axis is max ellipse routine
*
elliev:
	exg	d0,d1		;interchange x1/y1
	exg	d2,d3		;interchange x2/y2
*
	move.w	d2,d4
	sub.w	d0,d4
	move.w	d4,d5		;  = vert diameter -1
	muls	#-160,d5
	movea.l	d5,a5
	sub.w	yadj,a5		;adjust for vert stretch, if any
*
	lsr.w	#1,d4		;d4 = vert radius
*
	move.w	d1,d5
	move.w	d1,d6
	sub.w	d1,d3
	addq.w	#1,d3		;d3 = horz diameter
	lsr.w	#1,d3		;d3 = horz radius
*
	bcs.s	vradodd
	addq.w	#1,d5
	subq.w	#1,d3
vradodd:
	add.w	d3,d5
	add.w	d3,d6
pixcalc:
	move.w	d1,d7
	sub.w	leftx,d7
	sub.w	d7,d6		;adjusted left pixel address
*
	move.l	othscren,a0	;get base address for this screen
	mulu	#160,d2		;add bottom y offset
	adda.w	d2,a0		;  to a0
	move.l	a0,a1		;  save in a1 too
*
	move.w	d5,d7
	lsr.w	#1,d7
	andi.w	#$fff8,d7
	adda.w	d7,a0		;a0=address of rightmost plane0 word
*
	not.w	d5		;get bit # of rightmost pixel in word
	andi.w	#$f,d5		;
	movea.w	d5,a6		;save in a6
*
	move.w	d6,d7		;leftmost pixel
	lsr.w	#1,d7
	andi.w	#$fff8,d7
	adda.w	d7,a1		;a1=address of leftmost plane0 word
*
	not.w	d6		;get bit # of leftmost pixel in word
	andi.w	#$f,d6		;
	movea.w	d6,a4		;save in a4
*
	move.w	d3,d1		;d1 = horz radius
	move.w	d4,d0		;d0 = vert radius
*
*  do previous stuff
*
	move.w	d0,d2		;a->d2
	mulu	d2,d2		;t1 = a**2
	move.l	d2,d7		
	lsr.l	#1,d7		;discriminator2 = t1 /2
	add.l	d2,d2		;t2 = 2(a**2)
	move.l	d2,d3
	add.l	d3,d3		;t3 = 4(a**2)
	mulu	d1,d1		;t4 = b**2
	move.l	d1,d6		;
	lsr.l	#1,d6		;discriminator1 = t4 /2
	move.l	d1,d4
	add.l	d4,d4		;t5 = 2(b**2)
	move.l	d4,d5		;t6
	add.l	d5,d5		;t6 = 4(b**2)
	move.l	d4,d1		;d1 = t5
	mulu	d0,d1		;t7 = a*t5
	sub.l	d1,d6		;discriminator1 = t4 /2 - t7
	add.l	d2,d6		;discriminator1 = t2 - t7 - t4 /2
	add.l	d1,d1
	move.l	d1,a2		;t8 = 2*t7
	moveq.l	#0,d1		;y = 0
	move.l	d1,a3		;t9 = 0
	sub.l	a2,d7		;discriminator2 = t1 /2 - t8
	add.l	d4,d7		;discriminator2 = t1 /2 - t8 + t5
*
	exg.l	a4,d4
	exg.l	a5,d5
	move.l	a6,d1
*
	lea	shapebuf,a6
*
*
*
*   now do region loops
*
doreg1v:
	tst.l	d7		;d2 < 0 ?
	bpl.s	doreg2v		;br to skip region 1 if not
*
*  region 1
*
	bsr	plotxy		;else setpixel(x,y)
*
*  increment x regardless
*
	addq.w	#1,d4		;move left bit # to the left
	andi.w	#$f,d4
	bne.s	stepc0v
	subq.l	#8,a1
stepc0v:
	subq.w	#1,d1		;move right bit # to the right
	bpl.s	stepc1v
	moveq	#15,d1
	addq.l	#8,a0
stepc1v:
*
	adda.l	d3,a3		;t9 := t9 + t3
*
	tst.l	d6		;d1 < 0 ?
	bpl.s	stepcv
*
*  step to D if d1 < 0
*
	add.l	a3,d6
	add.l	d2,d6		;d1 := d1 + t9 + t2
*
	add.l	a3,d7		;d2 := d2 + t9
	bra.s	doreg1v		;back to while test
*
*  step to C if d1 >= 0
*
stepcv:
	subq.w	#1,d0		;y := y - 1
*
	suba.w	#160,a0
	suba.w	#160,a1		;advance y
	addi.w	#320,d5
*
	suba.l	a5,a2		;t8 := t8 - t6
*
	sub.l	a2,d6		
	add.l	a3,d6
	add.l	d2,d6		;d1 := d1 - t8 + t9 + t2
*
	sub.l	a2,d7
	add.l	a4,d7
	add.l	a3,d7		;d2 := d2 - t8 + t5 + t9
	bra.s	doreg1v
*
*  Region 2 of ellipse..
*
doreg2v:
	bsr.s	plotxy		;setpixel(x,y)
	suba.l	a5,a2		;t8 := t8 - t6
*
	tst.l	d7		;if d2 < 0
	bpl.s	stepbv		;do next, else branch to step to B
*
*  step to pixel C
*
	addq.w	#1,d4		;move left bit # to the left
	andi.w	#$f,d4
	bne.s	stepc2v
	subq.l	#8,a1
stepc2v:
	subq.w	#1,d1		;move right bit # to the right
	bpl.s	stepc3v
	moveq	#15,d1
	addq.l	#8,a0
stepc3v:
*
	adda.l	d3,a3		;t9 := t9 + t3
*
	sub.l	a2,d7
	add.l	a4,d7
	add.l	a3,d7		;d2 := d2 - t8 + t5 + t9
*
	bra.s	loopiv
*
*  step to pixel B
*
stepbv:
	sub.l	a2,d7
	add.l	a4,d7		;d2 := d2 - t8 + t5	
loopiv:
*
	suba.w	#160,a0
	suba.w	#160,a1
*
	addi.w	#320,d5
*
	dbra	d0,doreg2v	;x := x - 1, repeat until x < 0
*
	rts
*
*
*
*
*
*  Plot 4 pixels at 4-way mirror
*
*  entry:	a0 = right address
*		a1 = left address
*		a6 = pre-shift grafix base-ptr
*		d1 = right bit # in word (*4)
*		d4 = left bit # in word  (*4)
*		d5 = offset to upper (negative) quadrants
*
plotxy:
	movem.l	a0-a1/a5-a6/d0-d4/d6-d7,-(sp)
	tst.w	dofill
	beq	nofill1
*
*  fill plot here..
*
	add.w	d1,d1
	move.w	bitmask(pc,d1.w),d1
	not.w	d1
*
	add.w	d4,d4
	move.w	bitmask+2(pc,d4.w),d4
	bra.s	ovmask	
bitmask:
	.dc.w	$0000
	.dc.w	$0001
	.dc.w	$0003
	.dc.w	$0007
	.dc.w	$000F
	.dc.w	$001F
	.dc.w	$003F
	.dc.w	$007F
	.dc.w	$00FF
	.dc.w	$01FF
	.dc.w	$03FF
	.dc.w	$07FF
	.dc.w	$0FFF
	.dc.w	$1FFF
	.dc.w	$3FFF
	.dc.w	$7FFF
	.dc.w	$FFFF
ovmask:	
	cmp.l	a0,a1			;left/right within same word?
	bne.s	skipmsk
	and.w	d1,d4
	move.w	d4,d1
skipmsk:
	move.w	d1,d0
	not.w	d0
	move.w	d4,d2
	not.w	d2
	move.w	ellicol,d3
	moveq	#3,d6
filoop:
	lsr.w	d3
	bcc.s	andit1
	or.w	d1,(a0,d5.w)
	or.w	d4,(a1,d5.w)
	or.w	d1,(a0)+
	or.w	d4,(a1)+
	dbra	d6,filoop
	bra.s	filli
andit1:
	and.w	d0,(a0,d5.w)
	and.w	d2,(a1,d5.w)
	and.w	d0,(a0)+
	and.w	d2,(a1)+
	dbra	d6,filoop
filli:
	subq.l	#8,a0
	move.w	ellicol,d3
	ror.w	d3
	smi	d0
	ext.w	d0
	swap	d0
	ror.w	d3
	smi	d0
	ext.w	d0
	ror.w	d3
	smi	d1
	ext.w	d1
	swap	d1
	ror.w	d3
	smi	d1
	ext.w	d1
	bra.s	fillii
filllp:
	move.l	d0,(a1,d5.w)
	move.l	d0,(a1)+
	move.l	d1,(a1,d5.w)
	move.l	d1,(a1)+
fillii:
	cmp.l	a1,a0
	bhi.s	filllp
fillq:
	bra	plotey
*
*  Hollow plot	
*
nofill1:
	move.w	(a6)+,d7		;get thickness
	movea.l	a6,a5			;grafix preshift base-addr to a5
	lsl.w	#5,d1			;right bit # *32
	lsl.w	#5,d4			; left bit # *32
	adda.w	d1,a5			;preshifted right grafix ptr
	adda.w	d4,a6			;preshifted left grafix ptr
*
	bra	plotxyi
*
*  main plot loop
*
plotlp2:
	move.w	ellicol,d4
	moveq	#3,d6
	move.l	(a5)+,d0
	move.l	(a6)+,d1
	swap	d0
	swap	d1
	move.l	d0,d2
	move.l	d1,d3
	not.l	d2
	not.l	d3
plotlp:
	lsr.w	d4
	bcc.s	andit
	or.w	d0,(a0,d5)
	or.w	d1,(a1,d5)
	or.w	d0,(a0)+
	or.w	d1,(a1)+
	dbra	d6,plotlp
	bra.s	ploti
andit:
	and.w	d2,(a0,d5)
	and.w	d3,(a1,d5)
	and.w	d2,(a0)+
	and.w	d3,(a1)+
	dbra	d6,plotlp
ploti:
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	ellicol,d4
	moveq	#3,d6
plotlp1:
	lsr.w	d4
	bcc.s	andit2
	or.w	d0,(a0,d5.w)
	or.w	d1,(a1,d5.w)
	or.w	d0,(a0)+
	or.w	d1,(a1)+
	dbra	d6,plotlp1
	bra.s	ploti1
andit2:
	and.w	d2,(a0,d5.w)
	and.w	d3,(a1,d5.w)
	and.w	d2,(a0)+
	and.w	d3,(a1)+
	dbra	d6,plotlp1
ploti1:
	adda.w	#160-16,a0
	adda.w	#160-16,a1
plotxyi:
	dbra	d7,plotlp2
plotey:
	movem.l	(sp)+,a0-a1/a5-a6/d0-d4/d6-d7
	rts
*
*
*
* in:
*	d0	Xmin
*	d1	Ymin
*	d2	Xmax
*	d3	Ymax
*	d4	color
*	d5	writing mode
*
fillboxo:
	movem.l	a0-a6/d0-d7,-(sp)
	lea	p_block,a6
	move.l	a6,a5
	move.l	othscren,a0
*
	sub.w	d0,d2
	addq.w	#1,d2
	move.w	d2,(a5)+		; B_WD
	sub.w	d1,d3
	addq.w	#1,d3
	move.w	d3,(a5)+		; B_HT
	move.w	#4,(a5)+		; PLANES
	move.w	d4,(a5)+		; FG_COLOR
	clr.w	(a5)+			; BG_COLOR
	asl.w	#2,d5
	move.l	woptab-4(pc,d5.w),(a5)+	; OPTAB (writing mode op)
	clr.l	(a5)+			; S_XMIN S_YMIN
	move.l	a0,(a5)+		; S_FORM
	clr.l	(a5)+			; S_NXWD S_NXLN
	clr.w	(a5)+			; S_NXPL
	move.w	d0,(a5)+		; D_XMIN
	move.w	d1,(a5)+		; D_YMIN
	move.l	a0,(a5)+		; D_FORM
	move.w	#008,(a5)+		; D_NXWD
	move.w	#160,(a5)+		; D_NXLN
	move.w	#002,(a5)+		; D_NXPL
	clr.l	(a5)			; P_ADDR

	dc.w	bitblt
	movem.l	(sp)+,a0-a6/d0-d7
	rts

woptab:	dc.l	$00000F0F,$00000F0F,$0A0A0A0A,$00000F0F
*
*
*
ellicol:
	.dc.w	0		;color index for fill or line
dofill:
	.dc.w	0		;0 if line plot; -1 if fill plot
all_ones:
	.dc.w	$FFFF
*
*  additional variables used by ellipse to make round rectangle
*
leftx:
	.dc.w	0		;leftmost xpos (used by stretch ellipse)
yadj:
	.dc.w	0		;vert stretch (# lines * 160)
xstretch:
	.dc.w	0		;horz stretch
cornadj:
	.dc.w	0		;radius of rounded corners
upbutx:
	.dc.b	0		;"up button" upper screen ext if = 1
	.bss
curpoint:
	.ds.l	1		;current place in ptsin array
pointcnt:
	.ds.w	1		;# of points in array
plotcol:
	.ds.w	1		;current plotting color
slopex:
	.ds.w	1		;delta of previous x-coord
slopey:
	.ds.w	1		;delta of previous y-coord
ymax:
	.ds.w	1		;maximum y for poly point/line
ymin:
	.ds.w	1		;minimum y for poly point/line

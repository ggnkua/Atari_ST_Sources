*
*
*   Fat function II  (mainly the copy box stuff)
*
	.include	"fatequ.s"
*  public entry points
*
	.globl	copyi,copyd,copyupd,likesel,inotbox,back_spl,jackmode
	.globl	monomask,unantbox,antbox,killant,blackhol
	.globl	initscal,scalebox,movebox,stamp,stampx,setupbx
*
*  external ram variables
*
*	.globl	screen0,cpysrc,copystat,touch,curscren,funky,cpy_nxln,cut_nxln
*	.globl	originx,diagx,originy,diagy,scalemd,othscren,cpyscren
*	.globl	physadd,full,boxsrcx,boxsrcy,handy,othrorgx
*	.globl	boxwidth,othrorgy,boxhite,undoyet,p_block,b_width
*	.globl	b_height,s_form,blitmask,d_form,s_xmin,d_xmin,s_ymin,d_ymin
*	.globl	fg_col,bg_col,op_tab,s_nxwd,s_nxln,s_nxpl,d_nxwd
*	.globl	d_nxln,d_nxpl,bitblt,a_block,antptr,p_addr,plane_ct
*	.globl	blitmode,orgwidth,othwidth,orghite,othhite,lastfrm,frmcnt
*	.globl	scaler,half,hidem,showm
*
*  external entry points
*
*	.globl	updtxts,funkydo,chgxcur,chg2cur,clrstrch,putcpytx
*	.globl	unundo,screnswp,scale_man
*
*	.globl	straini,strain,constran
*
*
*   Jimmy's scaling code equates
*
*
STATUS	equ	0		;0:replace mode  1:transparent mode
*
SFORM	equ	2
SNXLN	equ	6
SXMIN	equ	8
SYMIN	equ	10
SWD	equ	12
SHT	equ	14
*
DFORM	equ	16
DNXLN	equ	20
DXMIN	equ	22
DYMIN	equ	24
DWD	equ	26
DHT	equ	28
*
*	
*   Copy functions -----------------------------------------
*
*   copystat    bit0--1 if box in existence
*		bit1--1 if origin in existence
*		bit2--1 if box is being dragged
*		bit3--1 if cursor is a pointer (within a box in existence)
*
*
*   copy init..
*
copyi:
	clr.b	scalemd			;turn off scale mode
	move.l	screen0,cpysrc
	move.w	#160,cpy_nxln
	clr.b	funky			;clear any pending function keys
*
*	tst.b	copystat
*	beq.s	copyix
*
*	nop
*copyix:
	rts
*
*  copy deinit
*
copyd:
*
*  exit copy loop
*
	btst.b	#0,copystat		;check for active box
	beq.s	nobox
*
	clr.b	copystat
*	clr.b	touch
	bsr	updtxts
*	movea.l	curscren,a1
	bsr	killant
nobox:
	rts
*
****************************************
*
*  copy update
*
copyupd:
	tst.b	d2			;any mouse button action here?
	bne.s	cpyupdd			;br if so--skip function key for now
*
	tst.b	funky			;check for function key
	bne	funkydo			;br & do function indicated
*
cpyupdd:
	btst.b	#0,copystat		;box in existence?
	beq.s	noptrchk		;br if not, needn't check cursor pos
	btst.b	#2,copystat		;draggin' box?
	bne.s	noptrchk		;br if yes, cursor already set
*
*  check for cursor within/without a box in existence
*
	bsr	inotbox			;check for inside or outside box
	bne.s	outsdbox
*
*
* inside existing box, check bit3
*
	bset.b	#3,copystat	;have we made cursor a ptr?
	bne.s	noptrchk	;br if so
*
*  else, set ptr cursor
*
	move.w	d0,-(sp)
	moveq	#15,d0
	bsr	chgxcur		;set mouse to arrow
	move.w	(sp)+,d0
*
	bra.s	noptrchk
*
*  outside existing box, check bit3
*
outsdbox:
	bclr.b	#3,copystat	;have we restored cursor to "plus" sign?
	beq.s	noptrchk	;br if so
	bsr	chg2cur		;  else, change back to "plus" sign
*
*
noptrchk:
	move.w	d2,d5			;check button change
	andi.w	#$3C,d5
	beq	nobutchg		;br if no
*
*	clr.b	touch			;this picture is touched
*
	btst.l	#2,d2			;leading edge on left?
	bne	llead			;br if leading on left
	btst.l	#4,d2			;trailing left?
	beq	chkrite			;br if not left trailing
*
*  trailing edge
*
setupbx:
	clr.b	constran		;exit constrain if any
	bclr.b	#2,copystat		;clear box drag bit
	btst.b	#0,copystat		;box in existence?
	beq	chkorg			;br to check new set-up if not
	move.b	scalemd,d5		;were we scaling?
	beq	chkrite			;br if not
	move.b	#-1,scalemd
	cmpi.b	#$85,d5
	bne.s	aprescal
*
	move.w	half,d6			;clean up othscren
	mulu	#10,d6
	subq.w	#1,d6
	movea.l	physadd,a0
	movea.l	othscren,a1
aprescl0:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d6,aprescl0
*
	bra	chkrite
aprescal:
*
*  copy scaled box into copy source area here
*
*
*	
	bsr	screp2th		;1st scale source to othscren
*
	lea	scaler,a6		;get values from scale-man
	move.w	DXMIN(a6),d4
	move.w	DYMIN(a6),d5
	move.w	DWD(a6),d6
	move.w	d6,boxwidth		;so resulting copy-box is clipped 
	move.w	DHT(a6),d7
	move.w	d7,boxhite		;  to visible area only
*
	move.w	d4,originx
	move.w	d4,boxsrcx
	move.w	d4,othrorgx
*
	move.w	d5,originy
	move.w	d5,boxsrcy
	move.w	d5,othrorgy
*
	add.w	d6,d4
	subq.w	#1,d4
	move.w	d4,diagx
	add.w	d7,d5
	subq.w	#1,d5
	move.w	d5,diagy
*
	movea.l	othscren,a0
	movea.l	cpyscren,a1
	movea.l	physadd,a2
	move.l	a1,cpysrc
	move.w	#160,cpy_nxln
	move.w	#1999,d5
	tst.w	full
	bne.s	scalful
	move.w	#999,d5
scalful:
	move.l	(a0),(a1)+
	move.l	(a2)+,(a0)+
	move.l	(a0),(a1)+
	move.l	(a2)+,(a0)+
	move.l	(a0),(a1)+
	move.l	(a2)+,(a0)+
	move.l	(a0),(a1)+
	move.l	(a2)+,(a0)+
	dbra	d5,scalful
*
	bsr	initscal		;set-up for next scale
*
	bsr	monomask		;form transparent mask
	bra	copyexit
chkorg:
	btst.b	#1,copystat		;origin in existence?
	beq	chkrite
*
*  Trailing edge on left button while expanding a box--
*
*  Set-up new box
*
	bset.b	#0,copystat		;set box in existence
	move.w	diagx,d7		;make originx/y top/left
	cmp.w	originx,d7
	bcc.s	noswap
	move.w	originx,diagx		;& diagx/y bottom/right
	move.w	d7,originx
noswap:
	move.w	diagy,d7
	cmp.w	originy,d7
	bcc.s	noswap1
	move.w	originy,diagy
	move.w	d7,originy
noswap1:
*
*
*  set-up source box in screen0..
*
	moveq	#0,d5
	tst.w	full
	bne.s	splatx
	move.w	handy,d5
splatx:
	move.w	originx,d7		;save this origin
	move.w	d7,othrorgx		;  as reasonable xpos for othscren
	move.w	diagx,d6
	sub.w	d7,d6
	addq.w	#1,d6
	move.w	d6,boxwidth		;save box width too
	move.w	d7,boxsrcx		;  use for box source in screen0
*
	move.w	originy,d7		;save this origin
	move.w	d7,othrorgy		;  as reasonable ypos for othscren
	move.w	diagy,d6
	sub.w	d7,d6
	addq.w	#1,d6
	move.w	d6,boxhite		;save box height too
	add.w	d5,d7
	move.w	d7,boxsrcy		;  use for box source in screen0
*
	bsr	initscal		;set up parms in case scaling
*
*  splat current screen to alternate screen
*
	bsr	unantbox		;29-Aug
*
	movea.l	curscren,a0
	movea.l	othscren,a1
	move.w	#1999,d5		;copy full screen to alternate
splatlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d5,splatlp
*
	move.l	curscren,a1
	bsr	antbox			;put ant box back
*
	bsr	monomask		;form un-background mask
*
	bsr	blackhol		;erase stuff under copybox
*
	bsr	updtxts			;update internal text string copy
	bsr	putcpytx		;update submode cut/copy etc faces
skiptxt:
*
	bra	gomatrix
*
*  leading left button trigger
*
llead:
	btst.b	#0,copystat		;box in existence?
	bne.s	isone			;br if yes
*
*  set box origin
*
	move.l	screen0,cpysrc		;use basic virgin source
	move.w	#160,cpy_nxln
*
	bset.b	#1,copystat		;set origin bit
	move.w	d0,originx		;get lastest x
	move.w	d1,originy		;& y
	move.w	d0,diagx
	move.w	d1,diagy
*
	movea.l	curscren,a0
	movea.l	physadd,a1
	move.w	#1999,d5
splatlp2:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d5,splatlp2
*
	clr.b	undoyet
	bsr	unundo			;save previous work
*
	move.l	curscren,a1
	bsr	antbox			;put up crawlin' ant box
*
	bra	gomatrix
*
*  Box already in existence when left button came down
*  Do we   a)Kill box or   b)Drag box
*
isone:
	clr.b	touch			;drag or kill touches
*
	btst.b	#3,copystat		;check inside/outside status
	beq	kbox			;br to kill box if outside
*	
*  Within box when left leading trigger detected, so
*
*  Start box drag
*
	bsr	straini			;initialize constrain
	bset.b	#2,copystat		;set box is being dragged
	tst.b	scalemd			;scale mode?
	beq	domatrix		;br to exit if not
*
*  find region of visible box where scale-drag begins..
*
*	-------------
*	| 0 | 1 | 2 |
*	-------------
*	| 4 | 5 | 6 |
*	-------------
*	| 8 | 9 | A |
*	-------------
*
	move.w	originy,d5		;get clippable box Y_MIN
	bpl.s	sbdrag0
	moveq	#0,d5
sbdrag0:
	move.w	diagy,d6		;get clippable box Y_MAX
	move.w	half,d7			;get 100 or 200 for Y_MAX clip boundary
	subq.w	#1,d7
	cmp.w	d7,d6			;exceeds boundary?
	ble.s	sbdrag1			;br if not
	move.w	d7,d6
sbdrag1:
	sub.w	d5,d6
	addq.w	#1,d6
	ext.l	d6
	divu	#3,d6
	moveq	#0,d7
	move.w	#1,d4
sbdrag2:
	add.w	d6,d5
	cmp.w	d1,d5
	bgt.s	sbdrag2x
	addq.w	#4,d7
	dbra	d4,sbdrag2
sbdrag2x:
*
	move.w	originx,d5		;get clippable box X_MIN
	bpl.s	sbdrag3
	moveq	#0,d5
sbdrag3:
	move.w	diagx,d6		;get clippable box X_MAX
	cmpi.w	#319,d6			;exceeds boundary?
	ble.s	sbdrag4			;br if not
	move.w	#319,d6
sbdrag4:
	sub.w	d5,d6
	addq.w	#1,d6
	ext.l	d6
	divu	#3,d6
	move.w	#1,d4
sbdrag5:
	add.w	d6,d5
	cmp.w	d0,d5
	bgt.s	sbdrag5x
	addq.w	#1,d7
	dbra	d4,sbdrag5
*
sbdrag5x:
	ori.b	#$80,d7
	move.b	d7,scalemd
*
	bra	domatrix		;finished
*
kbox:
	clr.b	copystat
	bsr	updtxts
	bsr	putcpytx		;update submode copy text faces
*
*  Request to cancel this box, entry point for copyd (copymode exit)
*
killbox:
*	clr.b	undoyet
	clr.b	copystat
*	movea.l	curscren,a1
	bsr	killant
	bra	gomatrix
*
*  checking right button edges
*
chkrite:
	btst.l	#3,d2			;leading edge on right?
	beq.s	nobutchg
*
*  right button trigger
*
	btst.b	#0,copystat		;box in existence?
	beq.s	nobutchg
*
*  leading edge on right button, stamp to screen
*
	clr.b	touch			;stamp touches
*
*  first, check left button down tho
*
	btst.l	#0,d2			;left down?
	beq.s	doblit			;br if no
*
*  left button down
*
	btst.b	#2,copystat		;check box draggin
	beq.s	doblit			;br if not draggin box
	tst.w	d2			;change in xy?
	bpl.s	doblit			;br if no change
	bsr	strain			;constrain movement
	tst.b	scalemd
	beq.s	normbox
	bsr	scalebox
	bra.s	doblit
normbox:
	bsr	movebox
*
*  blit contents to screen from save area
*
doblit:
	bsr	stamp
	bra.s	gomatrix
*
nobutchg:
	btst.l	#0,d2			;left down?
	beq.s	quietb			;br if no
*
*  left button down
*
	btst.b	#2,copystat		;check box draggin
	beq.s	notdrag			;br if not draggin box
	tst.w	d2
	bpl.s	quietb
*
*  drag box
*
	bsr	strain
	tst.b	scalemd
	beq.s	normbox1
	bsr	scalebox
	bra.s	gomatrix
normbox1:
	bsr	movebox
	bra.s	gomatrix
notdrag:
	btst.b	#1,copystat		;origin set?
	beq.s	quietb			;br if not
	btst.b	#0,copystat		;box in existence?
	bne.s	quietb			;br if so--skip expand box
	tst.w	d2			;any change in x/y?
	bpl.s	quietb			;br if not--needn't update expand
*
*  expand box
*
	bsr	unantbox		;erase old ant box
*
	move.w	d0,diagx
	move.w	d1,diagy
*
	move.l	curscren,a1
	bsr	antbox			;put up new ant box
*
quietb:	
domatrix:
gomatrix:
copyexit:
	rts
*
*  check for inside/outside box
*
inotbox:
	cmp.w	originx,d0
	blt.s	outsbox		;br if outside to left
	cmp.w	diagx,d0
	bgt.s	outsbox		;br if outside to right
	cmp.w	originy,d1
	blt.s	outsbox		;br if outside above
	cmp.w	diagy,d1
	bgt.s	outsbox		;br if outside below
	moveq	#0,d7
	rts
outsbox:
	moveq	#-1,d7
	rts

*
*
*
*  we need a monochrome non-background mask in case of transparent blits
*
*  (needn't clip--isn't used in cases where clipping can occur)
*
*
monomask:
	movem.l	d0-d7,-(sp)		;save regs
	movea.l	#p_block,a6		;base ptr for blt parm block
	move.w	boxwidth,b_width(a6)	;set width
	move.w	boxhite,b_height(a6)	;set height
	move.l	cpysrc,s_form(a6)	;get virgin copybox
	movea.l	#blitmask,a0
	move.l	a0,d_form(a6)	;and condense to monochrome in blitmask
	move.w	boxsrcx,d7
	move.w	d7,s_xmin(a6)
	move.w	d7,d_xmin(a6)
	move.w	boxsrcy,d7
	move.w	d7,s_ymin(a6)
	move.w	d7,d_ymin(a6)
	move.w	#4,plane_ct(a6)		;always refresh plane count
	move.w	#%1110,fg_col(a6)	;1st plane is replace mode
	move.w	#%0000,bg_col(a6)	;2nd thru 4th or'd 
	move.l	#$0C040404,op_tab(a6)	;
*
	move.w	cpy_nxln,d0
	move.w	#8,s_nxwd(a6)		;set source normal lo rez screen
	move.w	d0,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
*
	lsr.w	#2,d0
	move.w	#2,d_nxwd(a6)		;set destination virtual monochrome
	move.w	d0,d_nxln(a6)
	move.w	#0,d_nxpl(a6)
*
	.dc.w	bitblt
*
	movem.l	(sp)+,d0-d7
	rts
*
*
*
*  Unantbox
*
*  To be used only when defining a box (expanding rubber-band)
*
*  copy from screen0 those words necessary to erase
*  copybox outline
*
unantbox:
	movem.l	a0-a3/d0-d3,-(sp)
	move.l	screen0,a0		;get source addr (always screen0)
	move.l	curscren,a1		;dest addr
*
	tst.w	full			;adjust source addr?
	bne.s	uabx1			;br if full screen
	move.w	handy,d0
	mulu	#160,d0
	adda.w	d0,a0			;else, half-screen adjust
uabx1:
	move.w	originx,d0		;get current box bounds
	move.w	originy,d1
	move.w	diagx,d2
	move.w	diagy,d3
*
	lsr.w	#4,d0			;/16 one x boundary
	lsr.w	#4,d2			;/16 the other x boundary
	sub.w	d0,d2			;find # of 16 pixel blocks width (-1)
	bcc.s	uabx2			;br if d0 was smaller
	neg.w	d2			;  else adjsut
	sub.w	d2,d0			;  d0= left-most
uabx2:
	lsl.w	#3,d0			;*8 = horz address adjust
	sub.w	d1,d3
	bcc.s	uabx3
	neg.w	d3
	sub.w	d3,d1
uabx3:
	mulu	#160,d1
	add.w	d0,d1
	adda.w	d1,a0
	adda.w	d1,a1
	move.l	a0,a2
	move.l	a1,a3
	move.w	d2,d0
uabx4:
	move.l	(a2)+,(a3)+		;do top line
	move.l	(a2)+,(a3)+
	dbra	d2,uabx4
*
	move.w	#160-8,d2
	addq.l	#8,a0
	addq.l	#8,a1
	subq.w	#1,d3
	bmi.s	uabxx			;exit if only 1 line
	bra.s	uabx6
uabx5:
	move.l	(a0)+,(a1)+		;do side lines
	move.l	(a0)+,(a1)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
uabx6:
	adda.w	d2,a0
	adda.w	d2,a1
	adda.w	d2,a2
	adda.w	d2,a3
	dbra	d3,uabx5
*
uabx7:
	move.l	(a0)+,(a1)+		;do bottom line
	move.l	(a0)+,(a1)+
	dbra	d0,uabx7
uabxx:
	movem.l	(sp)+,a0-a3/d0-d3
	rts
*
*
*
*  Antbox
*
* input:
*   a1 -> screen base address on which to write box
*
*  uses its own bitblt parm block
*
antbox:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	originx,d0		;signed top/left xpos
	move.w	originy,d1		;signed top/left ypos
	move.w	diagx,d2		;bot/rite xpos
	move.w	diagy,d3		;bot/rite ypos
*
	cmp.w	d0,d2			;is d0 signed minimum xpos?
	bge.s	abx1			;br if so
	exg	d0,d2			;make d0 xmin
abx1:
	cmp.w	d1,d3			;is d1 signed minimum ypos?
	bge.s	abx2			;br if so
	exg	d1,d3
abx2:
*
*  code added to handle clipped copybox
*
	moveq	#0,d6			;clear box clip flags
	cmpi.w	#320,d2			;xmax exceed limit?
	blt.s	abx3			;br if not
	move.w	#319,d2			;put xmax to max
	ori.w	#$8,d6			;set right vert line clip
abx3:
	moveq	#100,d7
	tst.w	full
	beq.s	abx4
	add.w	d7,d7
abx4:
	cmp.w	d7,d3			;ymax exceed limits?
	blt.s	abx5
	move.w	d7,d3
	subq.w	#1,d3
	ori.w	#$2,d6			;set bottom line clip
abx5:
	tst.w	d0
	bpl.s	abx6
	clr.w	d0
	ori.w	#$4,d6			;set left line clip
abx6:
	tst.w	d1
	bpl.s	abx7
	clr.w	d1
	ori.w	#$1,d6
abx7:
*
*
	movea.l	#a_block,a6
	move.l	antptr,p_addr(a6)
	move.w	#2,p_addr+4(a6)
	move.w	#4,plane_ct(a6)
	move.w	#1,b_height(a6)	
	move.w	d0,d_xmin(a6)
	move.w	d0,d4
	addq.w	#1,d4
	andi.w	#$f,d4
	move.w	d4,s_xmin(a6)
	move.w	d1,d_ymin(a6)
	move.l	a1,d_form(a6)
	move.w	d2,d4
	sub.w	d0,d4
	addq.w	#1,d4
	move.w	d4,b_width(a6)
	lsr.w	d6
	bcs.s	abx8
	movem.l	a6/d1-d3/d6,-(sp)
	.dc.w	bitblt			;top horz line
	movem.l	(sp)+,a6/d1-d3/d6
*
abx8:
	move.l	antptr,p_addr(a6)
	move.w	#2,p_addr+4(a6)
	move.w	#4,plane_ct(a6)
	move.w	d3,d_ymin(a6)
	lsr.w	d6
	bcs.s	abx9
	movem.l	a6/d1-d3/d6,-(sp)
	.dc.w	bitblt			;bot horz line
	movem.l	(sp)+,a6/d1-d3/d6
*
abx9:
	move.l	antptr,p_addr(a6)
	move.w	#2,p_addr+4(a6)
	move.w	#4,plane_ct(a6)
	move.w	#1,b_width(a6)
	move.w	d1,d_ymin(a6)
	move.w	d3,d4
	sub.w	d1,d4
	addq.w	#1,d4
	move.w	d4,b_height(a6)
	lsr.w	d6
	bcs.s	abx10
	movem.l	a6/d2/d6,-(sp)
	.dc.w	bitblt			;left vert line
	movem.l	(sp)+,a6/d2/d6
*
abx10:
	move.l	antptr,p_addr(a6)
	move.w	#2,p_addr+4(a6)
	move.w	#4,plane_ct(a6)
	move.w	#1,b_width(a6)
	move.w	d2,d_xmin(a6)
	lsr.w	d6
	bcs.s	abx11
	.dc.w	bitblt			;right vert line
*
abx11:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*  Kill Ant Box
*
*   a1 -> screen base address on which to erase box
*
killant:
	move.l	d7,-(sp)
	move.b	likesel,d7	;save current tool
	ext.w	d7
	clr.b	likesel		;force jack knife (so movebox leaves off ants)
	swap	d7
	move.w	jackmode,d7
	cmpi.l	#$00020001,d7
	bne.s	ka1
	clr.w	jackmode	
ka1:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4		;fake out null move
	move.l	d7,-(sp)
	bsr	movebox		;put up box without ants
	move.l	(sp)+,d7
	move.w	d7,jackmode
	swap	d7
	move.b	d7,likesel	;restore mode
	move.l	(sp)+,d7
	rts
*
*
*  Put background in physadd buffer where copybox was..
*
blackhol:
	movem.w	d0-d7,-(sp)
	movea.l	#p_block,a6
	move.w	originx,d6
	move.w	d6,d_xmin(a6)
	move.w	d6,s_xmin(a6)
	move.w	boxwidth,b_width(a6)
	move.w	originy,d6
	move.w	d6,d_ymin(a6)
	move.w	d6,s_ymin(a6)
	move.w	boxhite,b_height(a6)
*
	move.w	#4,plane_ct(a6)		;always restore plane count
	move.l	#$0,op_tab(a6)		;fill with zeros
	move.l	physadd,d_form(a6)
	move.l	othscren,s_form(a6)
	move.w	#8,s_nxwd(a6)
	move.w	#160,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
	move.w	#8,d_nxwd(a6)
	move.w	#160,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
*
	.dc.w	bitblt
	movem.w	(sp)+,d0-d7
	rts
*
*  set up scale code original size parms
*
initscal:
	movem.l	a0-a1/d6,-(sp)
	move.w	boxwidth,d6
	move.w	d6,orgwidth
	move.w	d6,othwidth
	move.w	boxhite,d6
	move.w	d6,orghite
	move.w	d6,othhite
	btst.b	#0,copystat		;box in existence?
	beq.s	initsc1			;br if not
	move.l	physadd,a0
	move.l	othscren,a1
	move.w	#1999,d6
	tst.w	full
	bne.s	initsc2
	move.w	#999,d6
initsc2:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d6,initsc2
initsc1:
	movem.l	(sp)+,a0-a1/d6
	rts
*
*   Scaling routine equivalent to Movebox
*
scalebox:
	cmpi.b	#$85,scalemd		;are we in dead center?
	beq	movebox			;if so, this is same as movebox
*
	movem.w	d0-d7,-(sp)		;save regs
	move.w	othwidth,d6
	move.w	othhite,d7
	bsr	coverscl
*
	move.w	boxwidth,othwidth
	move.w	boxhite,othhite
	move.w	originx,othrorgx
	move.w	originy,othrorgy
*
	sub.w	d3,d0			;find delta x
	sub.w	d4,d1			;find delta y
*
	move.b	scalemd,d6
	andi.w	#$7F,d6
	btst.l	#2,d6			;in middle row?
	beq.s	sbx0			;br if not
	moveq	#0,d1			; if in middle, cancel delta y
sbx0:
	btst.l	#0,d6			;in middle column?
	beq.s	sbx1
	moveq	#0,d0			;cancel delta x if in middle column
sbx1:
	move.w	d6,d5
	andi.w	#$3,d5			;in left column?
	bne.s	sbx2
	neg.w	d0			;if so, negate delta x
sbx2:
	cmpi.b	#3,d6			;in top row?
	bgt.s	sbx3
	neg.w	d1			;if so, negate delta y
sbx3:
	move.w	boxwidth,d3		;find new proposed boxwidth
	add.w	d0,d3			;d0 = proposed boxwidth
	bgt.s	chkbigx			;br if not too small
*
*  horizontal flip over
*
	neg.w	d3
	addq.w	#2,d3
	move.w	diagx,d7
	move.w	originx,diagx
	move.w	d7,originx
	eor.b	#2,d6
	eor.b	#2,scalemd
	neg.w	d0
*
chkbigx:
chksmy:
	move.w	boxhite,d4		;find new proposed boxhite
	add.w	d1,d4			;d1 = proposed boxhite
	bgt.s	chkbigy			;br if not too small
*
*  vertical flip over
*
	neg.w	d4
	addq.w	#2,d4
	move.w	diagy,d7
	move.w	originy,diagy
	move.w	d7,originy
	eor.b	#8,d6
	eor.b	#8,scalemd
	neg.w	d1
*
chkbigy:
scalego:
*
*  new scaled height & width computed--proceed
*
	move.w	d3,boxwidth
	move.w	d4,boxhite
*
	move.w	d6,d5
	andi.w	#3,d5
	cmpi.w	#2,d5		;right column grab?
	bne.s	ngrabr
	add.w	d0,diagx	;expand with left side as anchor
ngrabr:
	tst.w	d5		;left column grab?
	bne.s	ngrabl		;br if not
	sub.w	d0,originx
ngrabl:
	cmpi.w	#8,d6		;bottom row grab?
	blt.s	ngrabb
	add.w	d1,diagy	;expand with top side as anchor
ngrabb:
	cmpi.w	#3,d6		;top row grab?
	bge.s	ngrabt
	sub.w	d1,originy
ngrabt:	
	move.w	#8,s_nxwd(a6)		;set source normal lo rez screen
	move.w	#160,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
*
	move.w	#8,d_nxwd(a6)		;set destination normal lo rez screen
	move.w	#160,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
*
	move.w	lastfrm,d7
sclwait:
	cmp.w	frmcnt,d7	;wait til previous swap becomes effective
	beq.s	sclwait
*
	.dc.w	bitblt			;blit background to cover old copybox
*
	bsr.s	scal2oth		;scale from source to dest
*
	movea.l	othscren,a1
	bsr	antbox
	bsr	screnswp
	move.w	frmcnt,lastfrm		;save frame count just after swap
noscale:
	movem.w	(sp)+,d0-d7
	rts	
*
*  Scale from cpysrc to othscren (always replace mode)
*
screp2th:
	movem.l	a0-a6/d0-d7,-(sp)
	moveq	#0,d7			;set for replace mode
	bra.s	scalebx1	
*
*  Scale from cpysrc to othscren (replace/or transparent mode)
*
scal2oth:
	movem.l	a0-a6/d0-d7,-(sp)
*
*  test for replace/transparent
*
	moveq	#0,d7			;assume replace mode
	tst.w	blitmode
	bpl.s	scalebx1		;skip transparent parm
	moveq	#1,d7			;else, do transparent color #0
scalebx1:
	lea	scaler,a6
	move.w	d7,STATUS(a6)		;tell 'em replace/transparent	
*
*  set-up scaling code
*
	move.l	cpysrc,SFORM(a6)
	move.l	othscren,DFORM(a6)
	move.w	#160,DNXLN(a6)
	move.w	cpy_nxln,SNXLN(a6)
*
	moveq	#0,d4			;x scale factor if clipping req'd
	move.w	orgwidth,d0		;src width
	move.w	boxwidth,d1		;dst width
	move.w	boxsrcx,d2		;src xmin
	move.w	originx,d3		;dst xmin
	bpl.s	clpscal0		;br if no left clip req'd
*
	move.w	d0,d4			;src width to scale factor
	ext.l	d4			;ready for divu
	lsl.w	#7,d4			;*128
	divu	d1,d4			;d4 = scale factor (*128)
	add.w	d3,d1			;adjust dst width for clip
	neg.w	d3			;make left clip amount positive
	mulu	d4,d3			;scale amount clipped on left
	lsr.w	#7,d3			;/128
	add.w	d3,d2			;adjust src xmin for clip
	sub.w	d3,d0			;adjust src width for clip
	moveq	#0,d3			;dst xmin = 0
*
*  check right clip..
*
clpscal0:
	move.w	d3,d5			;copy dst xmin to temp
	add.w	d1,d5			;add dst width
	subi.w	#320,d5			;check for bounds exceed
	ble.s	clpscal2		;br if ok
	tst.w	d4			;formed scale factor already?
	bne.s	clpscal1		;br if so
	move.w	d0,d4			;src width to scale factor
	ext.l	d4			;ready for divu
	lsl.w	#7,d4			;*128
	divu	d1,d4			;d4 = scale factor (*128)
clpscal1:
	sub.w	d5,d1			;adjust dst width
	mulu	d4,d5			;scale src width
	lsr.w	#7,d5			;/128
	sub.w	d5,d0			;adjust src width
clpscal2:
	move.w	d0,SWD(a6)		;src width
	move.w	d1,DWD(a6)		;dst width
	move.w	d2,SXMIN(a6)		;src xmin
	move.w	d3,DXMIN(a6)		;dst xmin
*
*  Now check clip in y
*
	moveq	#0,d4			;y scale factor if clipping req'd
	move.w	orghite,d0		;src hite
	move.w	boxhite,d1		;dst hite
	move.w	boxsrcy,d2		;src ymin
	move.w	originy,d3		;dst ymin
	bpl.s	clpscal3		;br if no left clip req'd
*
	move.w	d0,d4			;src hite to scale factor
	ext.l	d4			;ready for divu
	lsl.w	#7,d4			;*128
	divu	d1,d4			;d4 = scale factor (*128)
	add.w	d3,d1			;adjust dst hite for clip
	neg.w	d3			;make top clip amount positive
	mulu	d4,d3			;scale amount clipped off top
	lsr.w	#7,d3			;/128
	add.w	d3,d2			;adjust src ymin for clip
	sub.w	d3,d0			;adjust src hite for clip
	moveq	#0,d3			;dst ymin = 0
*
*  check bottom clip..
*
clpscal3:
	move.w	d3,d5			;copy dst ymin to temp
	add.w	d1,d5			;add dst hite
	sub.w	half,d5			;check for bounds exceed
	ble.s	clpscal5		;br if ok
	tst.w	d4			;formed scale factor already?
	bne.s	clpscal4		;br if so
	move.w	d0,d4			;src hite to scale factor
	ext.l	d4			;ready for divu
	lsl.w	#7,d4			;*128
	divu	d1,d4			;d4 = scale factor (*128)
clpscal4:
	sub.w	d5,d1			;adjust dst hite
	mulu	d4,d5			;scale src hite
	lsr.w	#7,d5			;/128
	sub.w	d5,d0			;adjust src hite
clpscal5:
	move.w	d0,SHT(a6)		;src hite
	move.w	d1,DHT(a6)		;dst hite
	move.w	d2,SYMIN(a6)		;src ymin
	move.w	d3,DYMIN(a6)		;dst ymin
*
	bsr	showm
	bsr	scale_man
	bsr	hidem
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
*  Blit a box of background to cover old position of previous
*  copybox in othrscren (indicated by othrorgx, othrorgy), then
*  blit current copybox on curscren at originx,originy,diagx,diagy
*  to calculated new position (using deltas determined from mouseget
*  registers d0-d4) on othrscren.
*  Update variables as shown:
*		originx -> othrorgx
*		originy -> othrorgy
*	delta x+originx -> originx
*	delta y+originy -> originy
*	delta x+diagx   -> diagx
*	delta y+diagy   -> diagy
*
*   Then swap alternate & current screens
*
*
movebox:
	movem.w	d0-d7,-(sp)		;save regs
	bsr	coverold
*
	move.w	originx,othrorgx
	move.w	originy,othrorgy
*
*
*
	sub.w	d0,d3			;find delta x
	sub.w	d1,d4			;find delta y
*
	move.w	originx,d7			
	sub.w	d3,d7			;find requested new originx
	cmpi.w	#320,d7
	blt.s	xnot320
	subi.w	#319,d7
	add.w	d7,d3
	move.w	#319,d7
xnot320:
	move.w	d7,originx
	sub.w	d3,diagx		;change diagx by delta x
	bpl.s	xnotneg
*
*  went to far left, adjust xpos'
*
	move.w	diagx,d3
	neg.w	d3
	add.w	d3,originx
	add.w	d3,diagx
xnotneg:
*
*  now do for y
*
	move.w	originy,d7			
	sub.w	d4,d7			;find requested new originy
	cmp.w	d6,d7
	blt.s	ynot320
	subq.w	#1,d6			;d6 = 97 or 197
	sub.w	d6,d7
	add.w	d7,d4
	move.w	d6,d7
ynot320:
	move.w	d7,originy
	sub.w	d4,diagy		;change diagy by delta y
	bpl.s	ynotneg
*
*  went to far up, adjust xpos'
*
	move.w	diagy,d4
	neg.w	d4
	add.w	d4,originy
	add.w	d4,diagy
ynotneg:
*
	move.w	lastfrm,d7
frmwait:
	cmp.w	frmcnt,d7	;wait til previous swap becomes effective
	beq.s	frmwait
*
	.dc.w	bitblt			;blit background to cover old copybox
*
	movea.l	#p_block,a6		;reset a6 to parm block (bitblt kills)
	move.w	#4,plane_ct(a6)		;this needs restoring too
*
	bsr	clipset
*
	move.l	othscren,d_form(a6)
*
*  test for transparent
*
	tst.w	blitmode
	bpl.s	movbox1
*
*  transparent, cut a hole in destination where source non-background is...
*
	move.w	cpy_nxln,d0
	lsr.w	#2,d0
	move.w	#2,s_nxwd(a6)		;set source for monochrome mask
	move.w	d0,s_nxln(a6)
	move.w	#0,s_nxpl(a6)
*
	move.w	#8,d_nxwd(a6)		;set destination normal lo rez screen
	move.w	#160,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
*
	move.l	#blitmask,s_form(a6)
*	move.l	#$01010101,op_tab(a6)
*
	bsr	mask_blt
*	.dc.w	bitblt
*
	movea.l	#p_block,a6		;reset a6 to parm block (bitblt kills)
	move.w	#4,plane_ct(a6)		;this needs restoring too
*
*
	move.l	#$07070707,op_tab(a6)
movbox1:
	move.w	#8,s_nxwd(a6)		;set source back to lo rez screen
	move.w	cpy_nxln,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
*
	move.l	cpysrc,s_form(a6)
	.dc.w	bitblt
*
	cmpi.b	#2,likesel		;are we a copybox?
	beq.s	movbox2			;br if so
	cmpi.w	#1,jackmode
	bne.s	movbox3
*
	movea.l	physadd,a0
*	tst.w	full
*	bne.s	movboxx
*	move.w	handy,d4
*	mulu	#160,d4
*	adda.w	d4,a0
*movboxx:
	movea.l	othscren,a1
	movea.l	#p_block,a6		;reset a6 to parm block (bitblt kills)
	move.w	d_xmin(a6),d4
	move.w	d_ymin(a6),d5
	move.w	b_width(a6),d6
	move.w	b_height(a6),d7
	bsr	back_spl
	bra.s	movbox3
movbox2:
	movea.l	othscren,a1
	bsr	antbox
movbox3:
	bsr	screnswp
	move.w	frmcnt,lastfrm		;save frame count just after swap
	movem.w	(sp)+,d0-d7
	rts	
*
*
*
*  set-up blt for othscren old box cover-up
*  used by both movebox & stamp
*
coverold:
	move.w	boxwidth,d6
	move.w	boxhite,d7
coverscl:
	movea.l	#p_block,a6		;base ptr for blt parm block
*
	move.w	#8,s_nxwd(a6)		;set source normal lo rez screen
	move.w	#160,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
*
	move.w	#8,d_nxwd(a6)		;set destination normal lo rez screen
	move.w	#160,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
*
	move.l	physadd,s_form(a6)	;get patch of background
	move.l	othscren,d_form(a6)	;from physadd to othscren
*
*  new clipping code
*
	move.w	othrorgx,d5		;get previous min x
	bpl.s	mbx1			;br if positive--no clip here
	add.w	d5,d6			;else, add neg to total width
	clr.w	d5			; & use 0 for xmin
mbx1:
	move.w	d5,s_xmin(a6)		;put in adjusted xmin
	move.w	d5,d_xmin(a6)
*
	add.w	d6,d5			;add width to xmin
	subi.w	#320,d5			;exceed max?
	ble.s	mbx2			;br if not
	sub.w	d5,d6			;adjust width by amount clipped on rite
mbx2:
	move.w	d6,b_width(a6)		;set width
*
*  now do the same for y
*
	moveq	#100,d6
	tst.w	full
	beq.s	mbx3
	add.w	d6,d6
mbx3:
	move.w	othrorgy,d5		;similiar stuff for 
	bpl.s	mbx4
	add.w	d5,d7
	clr.w	d5
mbx4:
	move.w	d5,s_ymin(a6)		;to cover old copybox
	move.w	d5,d_ymin(a6)
*
	add.w	d7,d5			;add width to ymin
	sub.w	d6,d5			;exceed max?
	ble.s	mbx5			;br if not
	sub.w	d5,d7			;adjust height by amount clipped on bot
mbx5:
	move.w	d7,b_height(a6)		;set height
*
	move.w	#4,plane_ct(a6)		;always refresh plane count
	move.l	#$03030303,op_tab(a6)
	rts
*
*
*
*   clip code common to stamp & movebox
*
clipset:
	move.w	boxwidth,d2
	move.w	boxhite,d3
	move.w	boxsrcx,d6
	move.w	boxsrcy,d7
	move.w	originx,d4
	bpl.s	mbx6
	add.w	d4,d2
	sub.w	d4,d6
	clr.w	d4
mbx6:
	move.w	originy,d5
	bpl.s	mbx7
	add.w	d5,d3
	sub.w	d5,d7
	clr.w	d5
mbx7:
	move.w	d4,d_xmin(a6)
	move.w	d5,d_ymin(a6)
	move.w	d6,s_xmin(a6)
	move.w	d7,s_ymin(a6)
*
	add.w	d2,d4
	subi.w	#320,d4
	ble.s	mbx8
	sub.w	d4,d2
mbx8:
	add.w	d3,d5
	sub.w	half,d5
	ble.s	mbx9
	sub.w	d5,d3
mbx9:
	move.w	d2,b_width(a6)
	move.w	d3,b_height(a6)
	rts
*
*
*  Stamp routine
*
*  A box of background from physadd is blitted over old copybox
*  on alternate screen using othrorgx,othrorgy
*  Then, copybox from current screen is blitted to originx,originy
*  on physadd buffer.  Logical screen is set to physadd and newbox
*  erases outline on physadd.  Logical screen is then restored to curscren
*
*	originx -> othrorgx and originy -> othrorgy
*
*
*  copybox from current screen is blitted to same corresponding
*  area of alternate screen
*
stamp:
	movem.w	d0-d7,-(sp)
	bsr	coverold
*
	move.l	a6,-(sp)
	.dc.w	bitblt
	move.l	(sp)+,a6
*
*  entry point if no othscren modify required
*
stampx:
	move.w	#4,plane_ct(a6)		;always restore plane count
	move.l	physadd,d_form(a6)
*
	bsr	clipset
*
	move.w	originx,othrorgx
	move.w	originy,othrorgy
*
*  test code
*
	tst.b	likesel
	bne.s	nrmstmp
	cmpi.w	#1,jackmode
	beq.s	poynstmp
	
nrmstmp:
*  end test
*
*  test for transparent
*
	tst.w	blitmode
	bpl.s	stamp1
poynstmp:
*
*  transparent, cut a hole in destination where source non-background is...
*
	move.w	cpy_nxln,d0
	lsr.w	#2,d0
*
	move.w	#2,s_nxwd(a6)		;set source for monochrome mask
	move.w	d0,s_nxln(a6)
	move.w	#0,s_nxpl(a6)
*
	move.l	#blitmask,s_form(a6)
	move.l	a6,-(sp)
*	move.l	#$01010101,op_tab(a6)
*
	bsr.s	mask_blt
*	.dc.w	bitblt
	move.l	(sp)+,a6
*
	move.w	#4,plane_ct(a6)		;this needs restoring too
*
*
	move.l	#$07070707,op_tab(a6)
stamp1:
	move.w	#8,s_nxwd(a6)		;set source back to lo rez screen
	move.w	cpy_nxln,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
*
	move.l	cpysrc,s_form(a6)
	.dc.w	bitblt
*
	tst.b	likesel
	bne.s	nrmstp1
	cmpi.w	#1,jackmode
	bne.s	nrmstp1
	movea.l	othscren,a0
	movea.l	physadd,a1
	movea.l	#p_block,a6		;reset a6 to parm block (bitblt kills)
	move.w	d_xmin(a6),d4
	move.w	d_ymin(a6),d5
*	tst.w	full
*	bne.s	nrmstp2
*	move.w	handy,d0
*	mulu	#160,d0
*	adda.w	d0,a0
*nrmstp2:
	move.w	b_width(a6),d6
	move.w	b_height(a6),d7
	bsr	back_spl
nrmstp1:
	movem.w	(sp)+,d0-d7
	rts
*
*
******************************************
*
* name:
*	maskblt.s
*
* purpose:
*
*	set up parameters for maskblt and thread together the appropriate
*	fragments
*
* author:
*
*	jim eisenstein
*	atari corp.
*
* creation date:
*
*	19-nov-85
*
* latest update:
*
*	20-nov-85
*
*
* in:
*
*	a6.l	points to frame (LINE A format) with following parameters set:
*
*		Ymin source, Ymax source, Ymin destination, Ymax destination
*		Xmin source, Xmax source, Xmin destination, Xmax destination
*		rectangle height, rectangle width, number of planes



*       FRAME PARAMETERS

B_WD	  equ	 00	; width of block in pixels			    +00
B_HT	  equ	 02	; height of block in pixels			    +02
PLANE_CT  equ	 04	; number of consequitive planes to blt		    +04

FG_COL	  equ	 06	; foreground color (logic op table index:hi bit)    +06
BG_COL	  equ	 08	; background color (logic op table index:lo bit)    +08
OP_TAB	  equ	 10	; logic ops for all fore and background combos	    +10

S_XMIN	  equ	 14	; minimum X: source				    +14
S_YMIN	  equ	 16	; minimum Y: source				    +16
S_FORM	  equ	 18	; source form base address			    +18
S_NXWD	  equ	 22	; offset to next word in line  (in bytes)	    +22
S_NXLN	  equ	 24	; offset to next line in plane (in bytes)	    +24
S_NXPL	  equ	 26	; offset to next plane from start of current plane  +26

D_XMIN	  equ	 28	; minimum X: destination			    +28
D_YMIN	  equ	 30	; minimum Y: destination			    +30
D_FORM	  equ	 32	; destination form base address			    +32
D_NXWD	  equ	 36	; offset to next word in line  (in bytes)	    +36
D_NXLN	  equ	 38	; offset to next line in plane (in bytes)	    +38
D_NXPL	  equ	 40	; offset to next plane from start of current plane  +40

P_ADDR	  equ	 42	; address of pattern buffer   (0:no pattern)	    +42
P_NXLN	  equ	 46	; offset to next line in pattern  (in bytes)	    +46
P_NXPL	  equ	 48	; offset to next plane in pattern (in bytes)	    +48
P_MASK	  equ	 50	; pattern index mask				    +50

***					    ***
***   these parameters are internally set   ***
***					    ***

P_INDX	  equ	 52	; initial pattern index				    +52

S_ADDR	  equ	 54	; initial source address 			    +54
S_XMAX	  equ	 58	; maximum X: source				    +58
S_YMAX	  equ	 60	; maximum Y: source				    +60

D_ADDR	  equ	 62	; initial destination address			    +62
D_XMAX	  equ	 66	; maximum X: destination			    +66
D_YMAX	  equ	 68	; maximum Y: destination			    +68

INNER_CT  equ	 70	; blt inner loop initial count			    +70
DST_WR	  equ	 72	; destination form wrap (in bytes)		    +72
SRC_WR	  equ	 74	; source form wrap (in bytes)			    +74


FRAME_LEN equ	 76




mask_blt:

	move.w	B_WD(a6),d1
	subq.w	#1,d1

	move.w	S_XMIN(a6),d0		; d0 <- X min source
	move.w	d0,d4
	add.w	d1,d4			; d4 <- X max source
	move.w	D_XMIN(a6),d2		; d2 <- X min destination
	move.w	d2,d6
	add.w	d1,d6			; d6 <- X max destination


	moveq.l	#$0F,d5			; d5 <- mod 16 mask

	move.w	d0,d1
	and.w	d5,d1			; d1 <- Xmin src mod 16 
	move.w	d2,d3
	and.w	d5,d3			; d3 <- Xmin dst mod 16

	lsr.w	#4,d0			; d0 <- Xmin source word offset
	lsr.w	#4,d2			; d2 <- Xmin destination word offset
	lsr.w	#4,d4			; d4 <- Xmax source word offset
	lsr.w	#4,d6			; d6 <- Xmax destination word offset

	sub.w	d0,d4			; d4 <- # source words -1
	sub.w	d2,d6			; d6 <- # destination words -1

	move.w	d4,d5
	sub.w	d6,d5			; d5 <- # src. words - # dst. words 

	sub.w	d3,d1			; d1 <- (Sxmin mod 16) - (Dxmin mod 16)	

*  in:
*	d1.w	(source Xmin mod 16)-(destination Xmin mod 16)
*	d4.w	words in source -1
*	d5.w	source words - destination words
*	d6.w	words in destination -1
*
* produce:
*
*	d4.w	rotation count
*	d5.w	configuration code:
*
*			bit  0	  logical shift direction
*
*				   0:left
*				   1:right
*
*			bit  1    actual shift direction:
*
*				   0: same direction as shift
*				   1: opposite of logical shift 
*
*			bit  2    source width : destination width
*				   
*				   0: source words =  destination words
*				   1: source words <> destination words 
*
*
*		note: width delta is either 1 word or 0 words


	move.w	d6,d0			; d6 <- destination words -1
	subq.w	#1,d0			; d0 <- initial inner loop counter
	move.w	d0,INNER_CT(a6)

	and.w	#1,d5			;    0:S=D     1:S<>D
	lsl.w	#2,d5			;  000:S=D   100:S<>D

	move.w	d4,d7			; d7 <- source words -1

	move.w	d1,d4			; d4 <- (Sxmin mod 16) - (Dxmin mod 16)
	move.w	d1,d2			; d2 might be used as tie breaker


*   set logical shift direction

	tst.w	d4
	bgt.s	act_shift		; Smod16 - Dmod16 > 0 => logical lf shf
	beq.s	start_addr		; zero is special case (pure lf rotate)

	neg.w	d4			; d4 <- positive shift value
	addq.w	#1,d5			; Smod16 - Dmod16 < 0 => logical rt shf
		
act_shift:	

	cmp.w	#8,d4
	blt.s	start_addr

	addq.w	#2,d5			; actual shift is opposite direction
	neg.w	d4			; from logical shift direction
	add.w	#16,d4


start_addr:

*   calculate starting addresses for source and destination

	moveq.l	#0,d0			; d0[31:16] <- 0

	move.w	S_XMIN(a6),d0		; src: 1 plane
	and.w	#$FFF0,d0
	lsr.w	#3,d0			; d0 <- x portion of offset

	move.w	S_YMIN(a6),d1
	move.w	S_NXLN(a6),d3		; d3 <- inter line offset
	muls	d3,d1			; d1 <- y portion of offset
	add.l	d0,d1			; d1 <- byte offset into memory form

	move.l	S_FORM(a6),a0		; a0 -> start of source form (0,0)
	add.l	d1,a0			; a0 -> word containing (x,y)

	addq.w	#1,d7			;????
	add.w	d7,d7			; d7 <- src width (bytes)
	sub.w	d3,d7
	neg.w	d7			; d7 <- SRC_WR


	move.w	D_XMIN(a6),d0		; dst: 4 planes
	and.w	#$FFF0,d0		
	lsr.w	#1,d0			; d0 <- X portion of offset

	move.w	D_YMIN(a6),d1
	move.w	D_NXLN(a6),d3		; d3 <- inter line offset
	muls	d3,d1			; d1 <- y portion of offset
	add.l	d0,d1			; d1 <- byte offset into memory form

	move.l	D_FORM(a6),a1		; a0 -> start of destination form (0,0)
	add.l	d1,a1			; a1 -> word containing (x,y)

	addq.w	#1,d6			;????
	asl.w	#3,d6			; d6 <- row width offset (destination)
	sub.w	d3,d6
	neg.w	d6			; d6 <- DST_WR (form wrap - row width)


big_fringe:

	move.w	d7,SRC_WR(a6)		; source wrap
	move.w	d6,DST_WR(a6)		; destination wrap


*   get right mask first


	move.w	D_XMIN(a6),d0		
	add.w	B_WD(a6),d0
	subq.w	#1,d0			; d0 <- Xmax of DST
	and.w	#$000F,d0		; d0 <- Xmax mod 16
	add.w	d0,d0			; d0 <- offset to right fringe mask
	move.w	fr_r_mask(pc,d0.w),d6	; d6 <- right fringe mask

	not.w	d6			; invert mask
	swap	d6			; d6(31:16) <- right fringe mask

*   now get the left mask

	move.w	D_XMIN(a6),d0		; d0 <- Xmin of DESTINATION
	and.w	#$000F,d0		; d0 <- Xmax mod 16
	add.w	d0,d0			; d0 <- offset to left fringe mask
	move.w	fr_l_mask(pc,d0.w),d6	; d6 <- left fringe mask


	asl.w	#3,d5			; d5(07:00) offset to fragment record

	move.l	frag_tab+04(pc,d5.w),a3	; a3 <- thread to inner loop
	move.l	frag_tab+00(pc,d5.w),a4	; a4 <- thread to 1st fringe
	
	tst.w	INNER_CT(a6)		; INNER_CT = -1  =>  Destination is 
	bge.s	pre_flight		; only one word wide. (a special case)

	move.l	d6,d0
	swap	d0
	or.w	d0,d6			; d6(15:00) <- single word fringe mask

	lea	f2_update,a3		; a3 <- thread that bypasses 2nd fringe

	btst.l	#5,d5			
	bne.s	pre_flight		; skip if source is 2 words wide

	lsr.w	#1,d5			; entries are 4 bytes wide
	and.w	#$000C,d5
	move.l	solo_tab(pc,d5.w),a4	; a4 <- thread to 1st fringe


pre_flight:

	move.w	B_HT(a6),d7		; d7(15:00) <- row count
	move.w	INNER_CT(a6),d5		; d5(15:00) <- inner loop counter
	jmp	(a4)			; cut the hole




*   fringe masks

fr_l_mask:

	dc.w	$0000	

fr_r_mask:

	dc.w	$8000,$C000,$E000,$F000,$F800,$FC00,$FE00,$FF00
	dc.w	$FF80,$FFC0,$FFE0,$FFF0,$FFF8,$FFFC,$FFFE,$FFFF


solo_tab:

	dc.l	f0_left			; no reverse logical lf  physical lf
	dc.l	f0_right		; no reverse logical rt  physical rt
	dc.l	f0_right		;    reverse logical lf  physical rt
	dc.l	f0_left			;    reverse logical rt  physical lf


                                                   
*	0000:l2rf1fll  0001:l2rf0f2r  0010:l2rf1flr  0011:l2rf0f2l
*	1000:l2rf1f2l  1001:l2rf0flr  1010:l2rf1f2r  1011:l2rf0fll
                                                   
frag_tab:                                          

*		    a4        a3

	dc.l	f1_l2r_lf,fl_l2r_lf	; l2rf1fll
	dc.l	f0_l2r_rt,f2_l2r_rt	; l2rf0f2r
	dc.l	f1_l2r_rt,fl_l2r_rt	; l2rf1flr
	dc.l   	f0_l2r_lf,f2_l2r_lf	; l2rf0f2l
	dc.l	f1_l2r_lf,f2_l2r_lf	; l2rf1f2l
	dc.l	f0_l2r_rt,fl_l2r_rt	; l2rf0flr
	dc.l	f1_l2r_rt,f2_l2r_rt	; l2rf1f2r
	dc.l   	f0_l2r_lf,fl_l2r_lf	; l2rf0fll



* name:
*	maskblt.s
*
* purpose:
*
*	these fragments may be threaded together to perform sprite
*	mask operations
*
* author:
*
*	jim eisenstein
*	atari corp.
*
* latest update:
*
*	19-nov-85
*
*
*  in:
*	d2.w		-
*	d3.w		-
*	d4.w		shift count
*	d5(15:00)	iterations of inner loop
*	d6(15:00)	initial fringe mask
*	d6(31:16)	final fringe mask
*	d7(15:00)	row counter
*
*
*	a0.l		points to first word of SOURCE
*	a1.l		points to first word of DESTINATION
*	a2.l		-
*	a3.l		thread to inner loop
*	a4.l		thread from update fragment back to 1st fringe fragment
*	a6.l		frame pointer
*
*	frame offsets
*
*	SRC_WR		offset from current word to 1st word of next row of src
*	DST_WR		offset from current word to 1st word of next row of dst
*	INNER_CT	inner loop count
*


	.eject

***					       ***
***   FIRST FRINGE FRAGMENTS:single transfer   *** 
***					       ***


f0_left:

	move.w	(a0)+,d0	; d0[31:16] <- most recent SRC word	 8
	rol.w	d4,d0		; d0[15:00] <- aligned word		 6-22
	or.w	d6,d0		; d0[15:00] <- mask the SRC word	 4
	and.w	d0,(a1)+	; cut hole in DST word 0		12
	and.w	d0,(a1)+	; cut hole in DST word 1		12
	and.w	d0,(a1)+	; cut hole in DST word 2		12
	and.w	d0,(a1)+	; cut hole in DST word 3		12

	jmp	(a3)		; jump to 2nd fringe fragment		 8


f0_right:

	move.w	(a0)+,d0	; d0[31:16] <- most recent SRC word	 8
	ror.w	d4,d0		; d0[15:00] <- aligned word		 6-22
	or.w	d6,d0		; d0[15:00] <- mask the SRC word	 4
	and.w	d0,(a1)+	; cut hole in DST word 0		12
	and.w	d0,(a1)+	; cut hole in DST word 1		12
	and.w	d0,(a1)+	; cut hole in DST word 2		12
	and.w	d0,(a1)+	; cut hole in DST word 3		12

	jmp	(a3)		; jump to 2nd fringe fragment		 8



	.eject

***			       ***
***   FIRST FRINGE FRAGMENTS   *** 
***			       ***

*	move from left to right.
*	fetch 2 Source words.
*	store 1 Destination fringe.
*	rotate right to achieve a net left shift.

f1_l2r_rt:

	move.w	(a0)+,d0	; d0 <- 1st SOURCE word			 8
	swap	d0		; d0[31:16] <- SRC 1st word (old)	 4


*	move from left to right.
*	fetch 1 Source word.
*	store 1 Destination fringe.
*	rotate right.

f0_l2r_rt:

	move.w	(a0)+,d0	; d0[15:00] <- SRC 2nd word (new)	 8
	move.l	d0,d1		;					 4
	swap	d1		; d1[31:16] <- SOURCE 2nd word		 4
	ror.l	d4,d0		; d0(15:00) <- aligned left fringe	 8-24

	or.w	d6,d0		; d0[15:00] <- mask the SRC word	 4
	and.w	d0,(a1)+	; cut hole in DST word 0		12
	and.w	d0,(a1)+	; cut hole in DST word 1		12
	and.w	d0,(a1)+	; cut hole in DST word 2		12
	and.w	d0,(a1)+	; cut hole in DST word 3		12

	jmp	(a3)		; jump to 2nd fringe fragment		 8


*	move from left to right.
*	fetch 2 Source words.
*	store 1 Destination fringe.
*	shift left.

f1_l2r_lf:

	move.w	(a0)+,d0	; d0 <- SOURCE 1st word			 8
	swap	d0		;					 4


*	move from left to right.
*	fetch 1 Source word.
*	store 1 Destination fringe.
*	shift left to achieve a net right shift.

f0_l2r_lf:

	move.w	(a0)+,d0	; d0(31:16) <- SOURCE 2nd word (new)	 8
	swap	d0		; d0(15:00) <- SOURCE 1st word (old)	 4
	move.l	d0,d1		; d1(31:16) <- set up for INNER LOOP	 4
	rol.l	d4,d0		; d0(15:00) <- aligned SRC left fringe	 8-24

	or.w	d6,d0		; d0[15:00] <- mask the SRC word	 4
	and.w	d0,(a1)+	; cut hole in DST word 0		12
	and.w	d0,(a1)+	; cut hole in DST word 1		12
	and.w	d0,(a1)+	; cut hole in DST word 2		12
	and.w	d0,(a1)+	; cut hole in DST word 3		12

	jmp	(a3)		; jump to 2nd fringe fragment		 8



	.eject

***			     ***
***   INNER LOOP FRAGMENTS   ***
***			     ***

i1_l2r_rt:

	move.l	d1,d0		; d0(31:16) <- old SOURCE word		 4
	move.w	(a0)+,d0	; d0(15:00) <- new SRC word		 8
	move.l	d0,d1		; d0(31:16) <- old SRC word		 4
	swap	d1		; d1(31:16) <- new SRC word (unaligned)	 4
	ror.l	d4,d0		; d0(15:00) <- alligned SOURCE: old|new	 8-24

	and.w	d0,(a1)+	; cut hole in DST word 0		12
	and.w	d0,(a1)+	; cut hole in DST word 1		12
	and.w	d0,(a1)+	; cut hole in DST word 2		12
	and.w	d0,(a1)+	; cut hole in DST word 3		12

	jmp	(a3)		; a3 -> inner loop control fragment	 8



i1_l2r_lf:

	move.l	d1,d0		; d0(31:16) <- old SOURCE word		 4
	move.w	(a0)+,d0	; d0(15:00) <- old SRC word		 8
	swap	d0		; d0(31:16) <- new SRC word		 4
	move.l	d0,d1		; d1(31:16) <- new SRC word (unaligned)	 4
	rol.l	d4,d0		; d0(15:00) <- alligned SOURCE: old|new  8-24

	and.w	d0,(a1)+	; cut hole in DST word 0		12
	and.w	d0,(a1)+	; cut hole in DST word 1		12
	and.w	d0,(a1)+	; cut hole in DST word 2		12
	and.w	d0,(a1)+	; cut hole in DST word 3		12

	jmp	(a3)		; a3 -> inner loop control fragment	 8



***							     ***
***   INNER LOOP COUNTER and SECOND FRINGE REQUIRING FETCH   ***
***							     ***

f2_l2r_rt:

	dbra	d5,i1_l2r_rt	; do another INNER LOOP cycle		10/14

  	move.l	d1,d0		; d0(31:16) <- next to last SRC word 	 4
  	move.w	(a0)+,d0	; d0(15:00) <- last SOURCE word		 8
  	ror.l	d4,d0		; d0(15:00) <- alligned SRC: old|new	 8-24

	bra.s	f2_out		; send fringe to DESTINATION		10



f2_l2r_lf:

	dbra	d5,i1_l2r_lf	; do another INNER LOOP cycle		10/14

  	move.l	d1,d0		; d0(31:16) <- next to last SOURCE word	 4
  	move.w	(a0)+,d0	; d0(15:00) <- last SOURCE word		 8
	rol.l	d4,d0		; d0(31:16) <- alligned SRC left fringe	 8-24

	bra.s	f2_flush	; send fringe to DESTINATION		10


	.eject

***							     ***
***   INNER LOOP COUNTER and SECOND FRINGE REQUIRING FLUSH   ***
***							     ***

fl_l2r_rt:

	dbra	d5,i1_l2r_rt	; do another INNER LOOP cycle		10/14
	bra.s	f2_flush	;					10

fl_l2r_lf:

	dbra	d5,i1_l2r_lf	; do another INNER LOOP cycle		10/14
****	bra.s	f2_flush	; fall through to f2_flush		10




	.eject

***					    ***
***   FINAL FRINGE OUTPUT and ROW CONTROL   ***
***					    ***

f2_flush:
	swap	d0		; d0(15:00) <- the target fringe	 4

f2_out:
  	swap	d6		; d6(15:00) <- 2nd fringe mask  	 4

	or.w	d6,d0		; d0[15:00] <- mask the SRC word	 4
	and.w	d0,(a1)+	; cut hole in DST word 0		12
	and.w	d0,(a1)+	; cut hole in DST word 1		12
	and.w	d0,(a1)+	; cut hole in DST word 2		12
	and.w	d0,(a1)+	; cut hole in DST word 3		12

  	swap	d6		; d6(15:00) <- 1st fringe mask		 4
  	move.w	INNER_CT(a6),d5	; reinit inner loop counter		12

f2_update:

	subq.w	#1,d7		; decrement row counter			 4
	beq.s	f2_end		;					10/8

  	adda.w	SRC_WR(a6),a0	; a0 -> last word of next line: SRC	16
  	adda.w	DST_WR(a6),a1	; a1 -> last word of next line: DST	16
  
	jmp	(a4)		; thread to first fringe fragment	 8


f2_end:	rts


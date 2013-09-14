*
*   FATMODE2 -- stuff originally in fatmode
*		having to do with jacknife & copybox
*
*   lat update: 27 May 86
*
	.include	"fatequ.s"
*
*   public entry points..
*
	.globl	jknfupd,cpybupd,canonscn,draw,undraw,stamp
	.globl	funkydo,hidem,showm,newjack1,outlin,jfunkydo
*
*
*   externally defined variables & entry points
*
*	.globl	cbarx,cbary,jackmode,jreptran,jackstat,othsame
*	.globl	cpysrc,othscren,blitmask,boxsrcx,boxsrcy,boxwidth
*	.globl	boxhite,jack_mas,shrink2f,originx,diagx,originy
*	.globl	diagy,physadd,full,movebox,lastfrm,frmcnt
*	.globl	jackant,jktxtd,invblock,cscrlupd,mouseget,cutfrm
*	.globl	funky,cpytxtd,updtxts,putcpytx,copystat,chg2cur
*	.globl	copyicon,invdrawq,drawq,scalemd,clrstrch,setstrch
*	.globl	initscal,blitmode,reptrans,cpyscren,monomask
*	.globl	contrl,vdicall,intin,cutscren,cutx,cuty,cutwidth
*	.globl	cuthite,othrorgx,othrorgy,curscren,undoyet,unundo
*	.globl	likesel,hflip,vflip,selctcol,edgemsk,p_block,b_width
*	.globl	b_height,s_form,d_form,d_xmin,s_xmin,d_ymin,s_ymin
*	.globl	s_nxwd,s_nxln,s_nxpl,d_nxwd,d_nxln,d_nxpl,plane_ct
*	.globl	op_tab,bitblt,fg_col,bg_col,colleft,colrite,bigram
*	.globl	swapclr,gridon,virhandy,virhandx,handy
*
*
*	.globl	cpy_nxln,cut_nxln
*	.globl	screnswp,half
*
*	.globl	touch
*
*	.globl	scale_ma,scaler
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
*************************************************************
*  
*   Jack knife mode update
*
*
*
jknfupd:
*
*  check mode update here..
*
	cmpi.w	#cbarx+76,d0
	bcs	ccpc			;br if cut/copy/paste/clear
*	
	move.w	d1,d3
	subi.w	#cbary+26,d3
	bcs	ccpc			;br if above all
*
*
*  check for mode changes
*
	cmpi.w	#20,d3
	bcs.s	normodz
*
*  "poiynt"  what-me-worry mode
*
	cmpi.w	#1,jackmode
	beq	ccpc
*
	moveq	#1,d3
	bra.s	newjackx
*
*			
normodz:
	move.w	d0,d3
	subi.w	#cbarx+80,d3		;within mode zone?
	bcs	ccpc			;br if no--check out cut/copy
	lsr.w	#4,d3
	cmpi.w	#2,d3
	bcc	nobcopy
	neg.w	d3
	cmp.w	jackmode,d3
	beq	nojkq
*
newjackx:
	move.w	d3,jackmode		;update transparent/replace
	bsr	jreptran		;display fo' the people
*
	btst.b	#0,jackstat		;jacknife active?
	beq	nojkq			;br if not active
*
*  update active jack knife in new writing mode
*
newjack:
	bsr	othsame
	bsr	canonscn		;make sure othscren is big one
newjack1:
*
*  get copy src in othscren...
*
	bsr	cpyscrst		;make sure cpysrc is from cpyscren
*
	movea.l	cpysrc,a0
	movea.l	othscren,a1
	movea.l	#blitmask,a2
*
	move.w	boxsrcx,d4
	move.w	boxsrcy,d5
	move.w	d4,d6
	move.w	d5,d7
	add.w	boxwidth,d6
	subq.w	#1,d6
	add.w	boxhite,d7
	subq.w	#1,d7
*
	movem.w	d4-d7,-(sp)
	jsr	jack_mas
	movem.w	(sp)+,d4-d7
*
doshrink:
	bsr	shrink2f
	beq	airhead
*
	move.w	d4,boxsrcx
	move.w	d5,boxsrcy
	sub.w	d4,d6
	addq.w	#1,d6
	move.w	d6,boxwidth
	sub.w	d5,d7
	addq.w	#1,d7
	move.w	d7,boxhite
	add.w	originx,d6
	subq.w	#1,d6
	move.w	d6,diagx
	add.w	originy,d7
	subq.w	#1,d7
	move.w	d7,diagy
*
	move.l	physadd,a0
	move.l	othscren,a1
	move.w	#1999,d0
	tst.w	full
	bne.s	jackflp
	move.w	#999,d0
jackflp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,jackflp
*
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	bsr	movebox
*
	move.w	lastfrm,d7
frmwt:
	cmp.w	frmcnt,d7
	beq.s	frmwt
*
	bsr	jackant
airhead:
nojkq:
	rts
*
*  check cut/copy/paste/clear
*
ccpc:
	btst.l	#2,d2			;left button positive edge?
	beq.s	nojkq			;br if no, exit
*
	cmpi.w	#cbarx+74,d0
	bcc.s	nojkq
	move.w	d1,d5
	subi.w	#cbary+27,d5
	bcs.s	nojkq
	ext.l	d5
	divu	#7,d5
	cmpi.w	#4,d5
	bcc.s	nojkq
*
* d5: 0-cut, 1-copy, 2-paste, 3-clear
*
	move.w	d5,d4
	mulu	#6,d4
	lea	jktxtd,a3
	tst.w	(a3,d4.w)
	bne.s	nojkq
*
*  invert selection block..
*
	bsr	invblock
*
*
*  loop here till left mouse button released..
*
jkylp:
	move.w	d5,-(sp)	;save inverted block #
	bsr	cscrlupd	;crawl some ants
	bsr	showm		;show cursor
	bsr	mouseget
	move.w	(sp)+,d5
*
	btst.l	#4,d2		;trailing edge on left?
	bne.s	jkylpq1		;br to perform action if so
*
	cmpi.w	#cbarx+74,d0	;within block bounds?
	bcc.s	jkylpq2		;br if not--turn off this block
	move.w	d1,d4
	subi.w	#cbary+27,d4
	bcs.s	jkylpq2		;turn off block
	ext.l	d4
	divu	#7,d4
	cmpi.w	#4,d4
	bcc.s	jkylpq2		;br if out of bounds
*
	move.w	d4,d6
	mulu	#6,d6
	lea	jktxtd,a3
	tst.w	(a3,d6.w)
	bne.s	jkylpq2		;br if new one isn't "on"
*
jwchinv:
	cmp.w	d4,d5		;new block same as old
	beq.s	jkylp		;br to loop if so--needn't refresh
*
*  moved to new block, erase old & draw new..
*
	bsr	hidem
*
	tst.w	d5		;was old block non-existent?
	bmi.s	jwchinv1	;br if so
	bsr	invblock	;else, undraw old inverse block
jwchinv1:
	move.w	d4,d5		;set up new one as our pick
	bsr	invblock	;draw new inverse block
	bsr	showm		;show cursor
	bra.s	jkylp		;loop till button released
*
*  button still down but mouse left domain of legal options
*
jkylpq2:
	tst.w	d5		;previous invert block real?
	bmi.s	jkylp		;br to loop if not
*
*  turn off previous block
*
	bsr	hidem
	bsr	invblock	;turn off previous
	move.w	#-1,d5		;put unreal value in
	bsr	showm		;show cursor
*
	bra.s	jkylp		;loop till button released
*
*  Button released
*  perform action & quit
*
jkylpq1:
	tst.w	d5		;was it a real function?		
	bmi	nocutx		;br to exit if not
	bsr	hidem
*
*  make block flash a bit
*
	move.w	#7,d6
jestlp1:
	bsr	invblock	;turn off/on
	move.w	frmcnt,cutfrm
frmjait:
	move.w	frmcnt,d7
	sub.w	cutfrm,d7
	cmpi.w	#2,d7
	bcs.s	frmjait
	dbra	d6,jestlp1
*
	move.w	d5,-(sp)
*
*  done with flash, now do something
*
* d5: 0-cut, 1-copy, 2-paste, 3-clear
*
	add.w	d5,d5
	add.w	d5,d5
	pea	jfuncret(pc)
	move.l	jfuncs(pc,d5),-(sp)
	rts
*
*
*
*
jfuncret:
	move.w	(sp)+,d5
	cmpi.w	#1,d5
	bne	nobufchg
	clr.b	touch
	bra	nobufchg	;update texts & exit
*
*
*
*
*
*
jfunc1:
	bclr.b	#4,jackstat		;stamp pending?
	beq.s	jfunc1a
	bsr.s	dstamp			;do delayed stamp
jfunc1a:
	bsr	cfunc2
jfunc4:
	bclr.b	#4,jackstat
	beq.s	jfunc4a
	bsr.s	dstamp			;do delayed stamp
jfunc4a:
	clr.b	jackstat
	bra	cfunc4
*
*
*
jfuncs:
	.dc.l	jfunc1	;cut
	.dc.l	cfunc2	;copy
	.dc.l	jfunc3	;paste
	.dc.l	jfunc4	;clear
*
*
*
************************************************************
*
*  jacknife function key call..
*
jfunkydo:
	move.b	funky,d5
	clr.b	funky
	subq.b	#1,d5
	ext.w	d5
	cmpi.w	#1,d5		;copy function?
	beq.s	jfkyd0
	clr.b	touch		;if not, this picture is touched
jfkyd0:
	move.w	d5,d6
	cmpi.w	#4,d6		;should be 0,1,2 or 3
	bcc	nofunky		;ring bell if not implimeted
	mulu	#6,d6
	lea	jktxtd,a0
	tst.w	(a0,d6.w)
	bne	nofunky
	move.w	d5,d6
	add.w	d6,d6
	add.w	d6,d6
	movem.w	d1/d5,-(sp)
	pea	jfkyd2(pc)
	move.l	jfuncs(pc,d6.w),-(sp)
	rts
*
*
dstamp:
	movea.l	othscren,a0	;clear other screen
	move.w	#1999,d7
	moveq	#0,d6
dstampl:
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	dbra	d7,dstampl
	bra	stamp		;return thru stamp routine
*
jfkyd2:
	movem.w	(sp)+,d1/d5
	cmp.w	half,d1		;cursor in drawing area?
	bhi	jfkyd1		;br if not
	tst.w	d5		;cut?
	beq.s	jfkyd3		;br if so
	cmpi.w	#3,d5		;clear?
	bne	jfkyd1		;br if not
*
*  cut/clear
*
jfkyd3:
	bsr	chg2cur
	bra	jfkyd1
*
************************************************************
*
*  copybox function key call..
*
funkydo:
	move.b	funky,d5
	clr.b	funky
	subq.b	#1,d5
	ext.w	d5
	cmpi.w	#1,d5		;copy function?
	beq.s	fkyd0
	clr.b	touch		;if not, this picture is touched
fkyd0:
	move.w	d5,d6
	cmpi.w	#9,d6
	beq.s	funkydod
	mulu	#6,d6
	lea	cpytxtd,a0
	tst.w	(a0,d6.w)
	bne.s	nofunky
	move.w	d5,d6
funkydod:
	add.w	d6,d6
	add.w	d6,d6
	move.w	d5,-(sp)
	pea	cfuncr(pc)
	move.l	cfuncs(pc,d6.w),-(sp)
	rts
cfuncr:
	move.w	(sp)+,d5
	cmpi.w	#4,d5
	bcc.s	cfuncr1
*	cmpi.w	#1,d5
*	beq.s	cfuncr1
	bsr	updtxts
	bsr	putcpytx
cfuncr1:
	rts
*
*
*
nfunk:
	addq.l	#6,sp	
nofunky:
*
*  ring the bell
*
	move.w	#7,-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	rts
*
cfuncs:
	.dc.l	cfunc1		;cut
	.dc.l	cfunc2		;copy
	.dc.l	cfunc3		;paste
	.dc.l	cfunc4x		;clear
	.dc.l	cfunc5		;rotate
	.dc.l	cfunc6		;h-flip
	.dc.l	cfunc7		;v-flip
	.dc.l	cfunc8		;t-edge
	.dc.l	cfunc9		;set/clear stretch mode
	.dc.l	cfunc10		;c-swap
*
cfunc4x:
	btst.b	#3,copystat		;is cursor within box?
	beq.s	cfunc4xx
	bsr	chg2cur			;make normal tool cursor
cfunc4xx:
	bra	cfunc4
*
*
cfunc1:
	bsr	cfunc2		;cut = copy + clear
	bra	cfunc4
*
*  Copy box tableau update
*
cpybupd:
*
*  check mode update here..
*
	cmpi.w	#cbarx+76,d0
	bcs	nobcopy			;br if in left column
*	
	move.w	d1,d3
	subi.w	#cbary+26,d3
	bcs	nobcopy			;br if above all
	cmpi.w	#20,d3
	bcs.s	modezone		;br if within mode zone
*
	cmpi.w	#38,d3
	bcs.s	strchzon		;br if within stretch zone
	cmpi.w	#40,d3
	bcs	nobcpyq
	cmpi.w	#58,d3
	bcc	nobcpyq
*
*  color swap zone
*
	btst.l	#2,d2			;left click on this zone?
	beq	nobcpyq			;exit if no
*
	movea.l	#copyicon+12,a0
	move.w	(a0)+,d2
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	moveq	#15,d3
	bsr	invdrawq		;draw inverse icon (select it)
*
*  call color swap function
*
	bsr	cfunc10			;do f10 -- color swap
*
*  restore color swap icon - we're done
*
	clr.b	touch			;picture has been touched
*
	movea.l	#copyicon+12,a0
	move.w	(a0)+,d2
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	moveq	#15,d3
	bsr	drawq			;draw inverse icon
	rts				;exit, we're done
*
*  end Dan's interface
*
*  in stretch icon zone..
*
cfunc9:
strchzon:
	tst.b	scalemd
	beq.s	strchzn1
	bsr	clrstrch
	bra.s	nobcpyq
strchzn1:
	bsr	setstrch		;set stretch mode
	bsr	initscal		;initalize parms for scaling
*
	bra.s	nobcpyq
*
modezone:
	move.w	d0,d3
	subi.w	#cbarx+80,d3		;within mode zone?
	bcs.s	nobcopy			;br if no--check out cut/copy
	lsr.w	#4,d3
	cmpi.w	#2,d3
	bcc.s	nobcopy
	neg.w	d3
	cmp.w	blitmode,d3
	beq.s	nobcpyq
	move.w	d3,blitmode		;update transparent/replace
	bsr	reptrans		;display fo' the people
	btst.b	#0,copystat		;copybox active?
	beq.s	nobcpyq			;br if not active
*
*  update active copybox in new writing mode
*
	movem.w	d0-d4,-(sp)
	bsr	othsame
	move.w	originx,d0
	move.w	originy,d1
	move.w	d0,d3
	move.w	d1,d4
	bsr	movebox
	movem.w	(sp)+,d0-d4
nobcpyq:
	rts
*
*  check cut/copy/paste
*
nobcopy:
	btst.l	#2,d2			;left button positive edge?
	beq	nocutx			;br if no, exit
*
	cmpi.w	#cbarx+74,d0
	bcc	nocutx
	move.w	d1,d5
	subi.w	#cbary+27,d5
	bcs	nocutx
	ext.l	d5
	divu	#7,d5
	cmpi.w	#8,d5
	bcc	nocutx
*
* d5: 0-cut, 1-copy, 2-paste, 3-clear, 4-rotate, 5-h-flip, 6-v-flip, 7-t-edge
*
	move.w	d5,d4
	mulu	#6,d4
	lea	cpytxtd,a3
	tst.w	(a3,d4.w)
	bne	nocutx
*
*  invert selection block..
*
doinvb:
	bsr	invblock
*
*
*  loop here till left mouse button released..
*
cpylp:
	move.w	d5,-(sp)	;save inverted block #
	bsr	cscrlupd	;crawl some ants
*
	bsr	showm		;show cursor
*
	bsr	mouseget
	move.w	(sp)+,d5
	btst.l	#4,d2		;trailing edge on left?
	bne.s	cpylpq1		;br to perform action if so
*
	cmpi.w	#cbarx+74,d0	;within block bounds?
	bcc.s	cpylpq2		;br if not--turn off this block
	move.w	d1,d4
	subi.w	#cbary+27,d4
	bcs.s	cpylpq2		;turn off block
	ext.l	d4
	divu	#7,d4
	cmpi.w	#8,d4
	bcc.s	cpylpq2		;br if out of bounds
*
	move.w	d4,d6
	mulu	#6,d6
	lea	cpytxtd,a3
	tst.w	(a3,d6.w)
	bne.s	cpylpq2		;br if new one isn't "on"
*
swchinv:
	cmp.w	d4,d5		;new block same as old
	beq.s	cpylp		;br to loop if so--needn't refresh
*
*  moved to new block, erase old & draw new..
*
	bsr	hidem
*
	tst.w	d5		;was old block non-existent?
	bmi.s	swchinv1	;br if so
	bsr	invblock	;else, undraw old inverse block
swchinv1:
	move.w	d4,d5		;set up new one as our pick
	bsr	invblock	;draw new inverse block
	bsr	showm		;show cursor
	bra.s	cpylp		;loop till button released
*
*  button still down but mouse left domain of legal options
*
cpylpq2:
	tst.w	d5		;previous invert block real?
	bmi.s	cpylp		;br to loop if not
*
*  turn off previous block
*
	bsr	hidem
	bsr	invblock	;turn off previous
	move.w	#-1,d5		;put unreal value in
	bsr	showm		;show cursor
*
	bra.s	cpylp		;loop till button released
*
*  Button released
*  perform action & quit
*
cpylpq1:
	tst.w	d5		;was it a real function?		
	bmi	nocutx		;br to exit if not
	bsr	hidem
*
*  make block flash a bit
*
	move.w	#7,d6
testlp1:
	bsr	invblock	;turn off
	move.w	frmcnt,cutfrm
frmwait:
	move.w	frmcnt,d7
	sub.w	cutfrm,d7
	cmpi.w	#2,d7
	bcs.s	frmwait
	dbra	d6,testlp1
*
*  done with flash, now do something
*
	cmpi.w	#1,d5		;copy?
	beq.s	itscpy
	clr.b	touch		;this picture is touched
itscpy:
	cmpi.w	#2,d5		;check on paste
	bne.s	docutcop	;br if cut/copy/clear/rotate
*
* do paste here
*
	bsr	cfunc3		;paste (function 3)
*
	move.w	#2,d5
	bra	nobufchg
*
*  cut/copy/clear/rotate in here...
*
docutcop:
*
docutcp:
	cmpi.w	#4,d5		;is it rotate?
	bne	notrota
*
*  do box rotate here
*
	bsr	cfunc5
*
	move.w	#4,d5
	bsr	invblock
	rts			;exit to main loop
*
*
*
*  Put a new copy box up...
*  othscren is temp buffer where new source was built
*  cpy_nxln has line wrap for othscren
*
boxupr:
	move.l	cpyscren,a0
	move.l	a0,cpysrc
	movea.l	othscren,a1
	movea.l	a1,a2
	move.w	#2240,d0
	tst.b	bigram
	bne.s	tocuti
	lsr.w	d0
	bra.s	tocuti
tocut:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
tocuti:
	dbra	d0,tocut
*
	movea.l	physadd,a1
	move.w	#1999,d0
	tst.w	full
	bne.s	tocut1
	move.w	#999,d0
tocut1:
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	dbra	d0,tocut1
*
boxupr1:
	tst.w	full
	bne.s	boxuprz
	bsr	othsame
boxuprz:
*
	bsr	monomask	;set up mask in case transparent is requested
*
*  now, blit in copybox
*
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	bsr	movebox
*
	movea.l	othscren,a0
	movea.l	physadd,a1
	move.w	#1999,d0
	tst.w	full
	bne.s	setoth
	move.w	#999,d0
setoth:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,setoth
	bsr	initscal		;set up scale parms just in case
	rts
*
*
*  check cut/copy/clear
*
notrota:
	cmpi.w	#5,d5		;h-flip?
	bne.s	nohflip
*
*  do h-flip here
*
	bsr	cfunc6
*
	move.w	#5,d5
	bsr	invblock		;restore select block
	rts
*
*  check on v-flip
*
nohflip:
	cmpi.w	#6,d5		;v-flip?
	bne.s	novflip
*
*  do v-flip here
*
	bsr	cfunc7

*
	move.w	#6,d5
	bsr	invblock		;restore select block
	rts
*
novflip:
	cmpi.w	#7,d5		;t-edge?
	bne.s	notedge
*
*  do t-edge here
*
	bsr	cfunc8
*
	move.w	#7,d5
	bsr	invblock		;restore select block
	rts
*
notedge:
	cmpi.w	#3,d5		;is it clear?
	beq.s	clearit		;br if so
*
*  cut/copy
*
	bsr.s	cfunc2
*
	cmpi.w	#1,d5		;copy?
	beq.s	nobufchg	;br if so--needn't cut hole in pic
*
*  cut requires more work..
*
clearit:
	bsr	cfunc4
*
*
nobufchg:
	bsr	invblock	;block back to normal please
*
jfkyd1:
	bsr	updtxts
	bsr	putcpytx	;put new text styles up here
	rts
*
*
nocutx:
*
*  hide cursor routine
*
hidem:
	move.w	#123,contrl+0
	bsr	vdicall		;hide cursor
	rts
*
*
*  Long awaited show cursor routine
*
showm:
	move.w	#122,contrl+0	;show cursor
	clr.w	contrl+2
	clr.w	intin+0
	move.w	#1,contrl+6
	bra	vdicall
*
*  copy box functions *******************
*
*
*
*
*  Function 2 -- copy to cut buffer
*  Function 1 -- copy to cut buffer, then do function 3 (clear)
*
cfunc2:
	move.l	cpysrc,a0
	cmpa.l	cutscren,a0	;is copy source from cut buffer already?
	beq.s	srcalrdy	;br if so--needn't do set-up again
*
*  save box specs.
*
	move.w	cpy_nxln,d6
	move.w	d6,cut_nxln
*
	move.w	boxsrcx,cutx
	clr.w	cuty
	move.w	boxsrcy,d7
	mulu	d6,d7
	adda.w	d7,a0
	lsr.w	#3,d6			;cpy_nxln/8 for 2 * copyloops/line
	move.w	boxwidth,cutwidth
	move.w	boxhite,d7
	move.w	d7,cuthite
	mulu	d6,d7
*
	movea.l	cutscren,a1
	bra.s	coplpi
coplp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
coplpi:
	dbra	d7,coplp
srcalrdy:
*
*  added for version 0.9h
	moveq	#-1,d6		;assume no paste alignment (neg)
	tst.b	gridon		;cut/copy while grid on?
	beq.s	srcalr1		;br if not on
	move.w	originx,d6
	add.w	virhandx,d6
	move.w	originy,d7
	add.w	virhandy,d7
	tst.w	full
	bne.s	srcalr2
	add.w	handy,d7
srcalr2:
	andi.w	#$7,d6
	andi.w	#$7,d7
srcalr1:
	move.b	d6,xgridalg
	move.b	d7,ygridalg
*  end addition
	rts
*
*
*   Function 3 -- Paste
*
jfunc3:
	move.b	#1,jackstat	;say jack knife in existence
	bra	cfunc3x
cfunc3:
dopaste:
	btst.b	#0,copystat	;box in existence?
	beq.s	normpste	;if not, do normal paste
	move.b	#1,copystat	;say only box is in existence
*
*  scale the cutbuffer to cpyscren
*
	lea	scaler,a5
	move.l	a5,a6
*
	clr.w	(a5)+		;status is replace
	move.l	cutscren,(a5)+	;src form is cutscren
	move.w	cut_nxln,(a5)+	;src wrap
	move.w	cutx,(a5)+	;src xmin
	move.w	cuty,(a5)+	;src ymin
	move.w	cutwidth,(a5)+	;src width
	move.w	cuthite,(a5)+	;src height
*
	move.l	cpyscren,(a5)+	;dst form is cpyscren
	move.w	cpy_nxln,(a5)+	;dst wrap
	move.w	boxsrcx,(a5)+	;dst xmin
	move.w	boxsrcy,(a5)+	;dst ymin
	move.w	boxwidth,(a5)+	;dst width
	move.w	boxhite,(a5)+	;dst height
*
	bsr	scale_ma	;scale it into cpy_src
	move.l	cpyscren,cpysrc
*	move.w	cut_nxln,cpy_nxln
	bra	pas0
*
normpste:
	move.b	#1,copystat	;say box is in existence
cfunc3x:
	move.l	cutscren,cpysrc	;copy source is from cut buffer now
*
	move.w	cut_nxln,cpy_nxln
	move.w	cutx,d6
	move.w	d6,boxsrcx
	move.w	cutwidth,d6
	move.w	d6,boxwidth
	move.w	#320,d7
	sub.w	d6,d7
	roxr.w	d7		;signed divide by 2
*
*  new code added for 0.9h version
	tst.b	gridon
	beq.s	noxalg
	tst.b	xgridalg
	bmi.s	noxalg
	add.w	virhandx,d7
	andi.w	#$FFF8,d7
	or.b	xgridalg,d7
	sub.w	virhandx,d7
noxalg:
*  end new addition
*
	move.w	d7,originx	;center new copybox
	move.w	d7,othrorgx
	add.w	d6,d7
	subq.w	#1,d7
	move.w	d7,diagx
*
	move.w	cuty,d6
	move.w	d6,boxsrcy
	move.w	cuthite,d6	;get cut box height
	move.w	half,d7		;get vert screen size
*
	move.w	d6,boxhite
	sub.w	d6,d7		;subtract hite from max
	roxr.w	d7		;signed divide by 2
*
*  new code added for 0.9h version
	tst.b	gridon
	beq.s	noxalg1
	tst.b	xgridalg
	bmi.s	noxalg1
	swap	d6
	move.w	virhandy,d6
	tst.w	full
	bne.s	noxalg2
	add.w	handy,d6
noxalg2:
	add.w	d6,d7
	andi.w	#$FFF8,d7
	or.b	ygridalg,d7
	sub.w	d6,d7
	swap	d6
noxalg1:
*  end new addition
*
	move.w	d7,originy	;center new copybox
	move.w	d7,othrorgy
	add.w	d6,d7
	subq.w	#1,d7
	move.w	d7,diagy
*
	movea.l	curscren,a0	;set up for copybox out of the blue
	movea.l	physadd,a1
	movea.l	othscren,a2
	move.w	#1999,d6
paste2:
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
*
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
*
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
*
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d6,paste2
*
	clr.b	undoyet
	bsr	unundo		;save previous work
*
	tst.b	likesel		;jacknife?
	beq	newjack		;br if not--skip jacknife stuff
*
pas0:
	bsr	monomask	;set up mask in case transparent is requested
*
*  now, blit in copybox
*
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	bsr	movebox
	bsr	initscal	;init scaling in case it's on
	rts
*
*
*  Function 4 -- clear
*
cfunc4:
	clr.b	copystat	;turn off copy box
	movea.l	physadd,a0	;& erase it from the screen
	movea.l	curscren,a1
	move.w	#1999,d6
	tst.w	full
	bne.s	cutloop
	move.w	#999,d6
cutloop:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d6,cutloop
	rts
*
*
*
*
*  Function 5 -- rotate
*
*
cfunc5:
	bsr	canonscn		;make sure othscren is big buffer
	movea.l	cpysrc,a0
	movea.l	othscren,a1
	move.w	boxsrcx,d0
	move.w	boxsrcy,d1
*
	move.w	cpy_nxln,d4
	mulu	d4,d1
	movea.w	d4,a2		;save source line wrap in a2
*
	adda.w	d1,a0		;a0 -> top/left source buffer
	move.w	d0,d1
	lsr.w	#4,d1
	lsl.w	#3,d1
	adda.w	d1,a0		;a0-> top/left of source box
	andi.w	#$f,d0		;d0= # left shifts til 1st word left justified
*
	move.w	#160,d1		;assume normal dest line wrap (160)
*
	move.w	boxwidth,d2
	move.w	d2,d5		;save original boxwidth
*
	move.w	boxhite,d3
	move.w	d3,d6		;save original boxhite
*
	cmp.w	half,d2		;can this width become height without problem?
	ble.s	widgood		;br if so
*
	add.w	#15,d6		;use new boxwidth
	lsr.w	#1,d6		;to calculate minimum form-width
	andi.w	#$FFF8,d6
	move.w	d6,d1		;set new dest wrap
	move.w	d3,d6
widgood:
	move.w	d3,boxwidth	;save new boxwidth (from old boxhite)
	movea.w	d1,a3		;save dest line wrap in a3
	move.l	#35840,d7	;get max buffer size
	tst.b	bigram
	bne.s	cpymaxok
	lsr.w	#1,d7		;small RAM allows only 1/2 cpysrc
cpymaxok:
	divu	d1,d7		;find max boxhite this buffer will allow
	cmp.w	d2,d7		;proposed hite exceed it?
	bcc.s	cpyhytok	;br if not
	move.w	d7,d2		;chop down new hite to fit
cpyhytok:
	move.w	d2,boxhite
*
*  center new box, as near old center-point as possible
*
	lsr.w	d5		;1/2 original boxwidth
	move.w	originx,d7	;left xpos
	add.w	d5,d7		;original center-point x
	move.w	d3,d5		;get new boxwidth (was hite)
	lsr.w	d5		;1/2 new boxwidth
	sub.w	d5,d7		;d7=new originx
	cmpi.w	#319,d7		;is it too far right?
	ble.s	func5w		;br if within bounds
	move.w	#319,d7		;force it to be somewhat visible
func5w:
	move.w	d7,d5		;d5=originx 
	add.w	d3,d5		;add new boxwidth
	subq.w	#1,d5		;hows rite side?
	bpl.s	func5x		;br if still on screen
*
	sub.w	d5,d7		;move originx right a bit
*
	move.w	d7,d5
	add.w	d3,d5
	subq.w	#1,d5
func5x:
	move.w	d7,originx
	move.w	d7,othrorgx
	move.w	d5,diagx
*
	lsr.w	d6		;1/2 original boxhite
	move.w	originy,d7
	add.w	d6,d7		;original center point y	
	move.w	d2,d5		;new boxhite
	lsr.w	d5		;1/2 new boxhite
	sub.w	d5,d7		;d7=new originy
	cmp.w	half,d7		;is it too far below?
	blt.s	func5z		;br if not, something visible
	move.w	half,d7
	subq.w	#1,d7		;make it just visible
func5z:
	move.w	d7,d5		;d5=originy
	add.w	d2,d5		;add new boxhite
	subq.w	#1,d5		;hows bottom?
*
	bpl.s	func5zzz	;br if low enough to see
*
	sub.w	d5,d7		;else, move originy down a bit
	move.w	d7,d5
	add.w	d2,d5
	subq.w	#1,d5
func5zzz:
	move.w	d7,originy
	move.w	d7,othrorgy
	move.w	d5,diagy
*
	clr.w	boxsrcx
	clr.w	boxsrcy
	move.w	a3,d4		;get destination line wrap
	lsr.w	#3,d4		;/8
	mulu	d2,d4		;* height for loop count
	moveq	#0,d5
	bra.s	othclri
othclr:
	move.l	d5,(a1)+	;clear destination
	move.l	d5,(a1)+
othclri:
	dbra	d4,othclr
	suba.w	a3,a1		;a1-> bottom/left corner of destination
*
	move.w	#$8000,d1	;destination mask
	bra.s	rotlp1i		;br to test portion of loop
rotlp1:
	movem.l	a0-a1,-(sp)
	move.w	(a0)+,d4	;load up with 1st
	move.w	(a0)+,d5
	move.w	(a0)+,d6
	move.w	(a0)+,d7
	tst.w	d0
	beq.s	noshif
	lsl.w	d0,d4
	lsl.w	d0,d5
	lsl.w	d0,d6
	lsl.w	d0,d7
noshif:
	movea.w	#15,a4
	suba.w	d0,a4
	swap	d0
	move.w	a4,d0
*
rotlp:
	lsl.w	#1,d4
	bcc.s	rot0
	or.w	d1,(a1)
rot0:
	lsl.w	#1,d5
	bcc.s	rot1
	or.w	d1,2(a1)
rot1:
	lsl.w	#1,d6
	bcc.s	rot2
	or.w	d1,4(a1)
rot2:
	lsl.w	#1,d7
	bcc.s	rot3
	or.w	d1,6(a1)
rot3:
	suba.w	a3,a1
	subq.w	#1,d2		;decrement new hite
	beq.s	nextrw
	dbra	d0,rotlp
*
	move.w	(a0)+,d4	;load up with more source line grafix
	move.w	(a0)+,d5
	move.w	(a0)+,d6
	move.w	(a0)+,d7
	move.w	#15,d0
	bra.s	rotlp
nextrw:
	movem.l	(sp)+,a0-a1
	move.w	boxhite,d2
	swap	d0
	ror.w	d1
	bcc.s	skip8
	addq.l	#8,a1
skip8:
	adda.w	a2,a0
rotlp1i:
	dbra	d3,rotlp1
	move.w	a3,cpy_nxln
	bsr	boxupr		;put new box up
	rts
*
*
*
*  Function 6 -- horizontal flip
*
cfunc6:
	movem.l	a0-a3/d0-d7,-(sp)
	bsr	canonscn		;get cpysrc in cpyscren
	movea.l	cpysrc,a0		;a0 -> src base addr
	movea.l	othscren,a1		;a1 -> dst base addr
	movea.w	cpy_nxln,a2		;a2 =  src form wrap
	move.l	a2,a3			;a3 =  dst form wrap
	move.w	boxsrcx,d0		;d0 = src xmin
	move.w	boxwidth,d2		;d2 = horz width in pixels
	move.w	d0,d1
	add.w	d2,d1
	subq.w	#1,d1			;d1 = xmax
	not.w	d1			
	and.w	#$f,d1
	move.w	d1,boxsrcx		;new boxsrcx is 
	move.w	boxsrcy,d1
	move.w	boxhite,d3
	bsr	hflip
	movem.l	(sp)+,a0-a3/d0-d7
	clr.w	boxsrcy
	bsr	boxupr
	rts
*
*  Function 7 -- vertical flip
*
*
cfunc7:
	movem.l	a0-a3/d0-d7,-(sp)
	bsr	canonscn
	movea.l	cpysrc,a0
	movea.l	othscren,a1
	movea.w	cpy_nxln,a2
	move.l	a2,a3
	move.w	boxsrcx,d0
	move.w	d0,d1
	andi.w	#$f,d1
	move.w	d1,boxsrcx
	move.w	boxsrcy,d1
	move.w	boxwidth,d2
	move.w	boxhite,d3
	bsr	vflip
	movem.l	(sp)+,a0-a3/d0-d7
	clr.w	boxsrcy
	bsr	boxupr
	rts
*
*
*
*  Function 8 -- trace edge
*
cfunc8:
	move.l	othscren,a0	;clear out to use as monochrome buffer
	move.l	a0,a1
	moveq	#0,d7
	move.w	#999,d6		;clear half a screen (should be enuf)
clrmono:
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	dbra	d6,clrmono
*
	move.l	cpysrc,a0
	move.w	boxsrcx,d0
	move.w	boxsrcy,d1
	move.w	boxhite,d2
	move.w	boxwidth,d3
*
*	move.w	d3,d4
*	andi.w	#$f,d4
*	add.w	d0,d4
*	eor.w	d0,d4
*	andi.w	#$10,d4
*	add.w	d4,d3
*
	add.w	d0,d3		;get xmax +1
	subq.w	#1,d3		;xmax
	lsr.w	#4,d3		;d3 = # of 16-pixel block where xmax is found
	move.w	d0,d4
	lsr.w	#4,d4		;d4 = # of 16-pixel block where xmin is found
	sub.w	d4,d3		;d3 = word span (-1)
*
	move.w	cpy_nxln,d4
	mulu	d4,d1
	adda.w	d1,a0
	lsr.w	#1,d0
	andi.w	#$fff8,d0
	adda.w	d0,a0		;a0 -> 1st (top/left) plane0 word of src form
*
*	addi.w	#15,d3		;add 15 to pixel width
*	lsr.w	#4,d3		;/16 (# of 16-pixel blocks in width)
*
	move.w	d3,d1
	addq.w	#3,d1		;add 1 word on either side of mono-form line
	add.w	d1,d1		;# of bytes per line in mono-form	
*
	adda.w	d1,a1
	adda.w	d1,a1		;start mono-form 2 lines down
	addq.l	#2,a1		; & 1 word right
*
*
*  a0  -> 1st (top/left) plane0 word of src form
*  a1  -> 1st (top/left) word of mono-form dst
*
*  d0.w = plane count
*  d1.w = mono-form width (# bytes)
*  d2.w = height in scanlines
*  d3.w = width in # of 16-pixel blocks
*
	moveq	#0,d0		;current plane #
*
	movea.l	a0,a2		;copy src ptr to temp
	movea.l	a1,a3		;copy mono ptr to temp
*
	move.w	d2,d5		;copy height to temp
	btst.b	d0,selctcol+1	
	beq.s	notlpii
	bra.s	yeslpii
yeslp1:
	movea.l	a2,a4
	movea.l	a3,a5
*
	move.w	d3,d6		;copy word-width -1 to temp
*	bra.s	yeslpi
yeslp:
	move.w	(a4),(a5)+
	addq.l	#8,a4
yeslpi:
	dbra	d6,yeslp
*
	adda.w	d4,a2
	adda.w	d1,a3
yeslpii:
	dbra	d5,yeslp1
	bra.s	doplanx
*
*
notlp1:
	movea.l	a2,a4
	movea.l	a3,a5
*
	move.w	d3,d6		;copy word-width to temp
*	bra.s	notlpi
notlp:
	move.w	(a4),d7
	not.w	d7
	move.w	d7,(a5)+
	addq.l	#8,a4
notlpi:
	dbra	d6,notlp
*
	adda.w	d4,a2
	adda.w	d1,a3
notlpii:
	dbra	d5,notlp1
*
*
nxtplane:
	movea.l	a0,a2		;copy src ptr to temp
	movea.l	a1,a3		;copy mono ptr to temp
*
	move.w	d2,d5		;copy height to temp
	btst.b	d0,selctcol+1	
	beq.s	ntlpii
	bra.s	yslpii
yslp1:
	movea.l	a2,a4
	movea.l	a3,a5
*
	move.w	d3,d6		;copy word-width to temp
*	bra.s	yslpi
yslp:
	move.w	(a4),d7
	and.w	d7,(a5)+
	addq.l	#8,a4
yslpi:
	dbra	d6,yslp
*
	adda.w	d4,a2
	adda.w	d1,a3
yslpii:
	dbra	d5,yslp1
	bra.s	doplanx
*
*
ntlp1:
	movea.l	a2,a4
	movea.l	a3,a5
*
	move.w	d3,d6		;copy word-width to temp
*	bra.s	ntlpi
ntlp:
	move.w	(a4),d7
	not.w	d7
	and.w	d7,(a5)+
	addq.l	#8,a4
ntlpi:
	dbra	d6,ntlp
*
	adda.w	d4,a2
	adda.w	d1,a3
ntlpii:
	dbra	d5,ntlp1
doplanx:
	addq.w	#1,d0		;next plane please
	addq.l	#2,a0		;offset to next
	cmpi.w	#4,d0		;past last plane?
	bcs.s	nxtplane
*
*  mono-form mask of selected color now built
*
*
*  now, mask fringes
*
	move.w	boxsrcx,d4
	move.w	d4,d5
	add.w	boxwidth,d5
	move.l	#edgemsk,a2
	not.w	d4
	andi.w	#$f,d4
	not.w	d5
	andi.w	#$f,d5
	add.w	d4,d4
	add.w	d5,d5
*
	move.w	2(a2,d4.w),d4	;pick up left mask
*
	move.w	2(a2,d5.w),d5
	not.w	d5		;pick up right mask
*
*	subq.w	#1,d3
*
	add.w	d3,d3
	movem.w	d1-d2,-(sp)
	bra.s	masslpi
*
masslp:
	move.l	a1,a2
	and.w	d4,(a2)
	adda.w	d3,a2
	and.w	d5,(a2)
	adda.w	d1,a1
masslpi:
	dbra	d2,masslp
*
*  fringes now masked..
*
	bsr	cpyscrst	;make sure copy source is from cpyscren
*
*  cookie-cut a hole in copy source
*
	movea.l	#p_block,a6		;base ptr for blt parm block
	move.w	boxwidth,b_width(a6)	;set width
	move.w	boxhite,b_height(a6)	;set height
	move.l	othscren,s_form(a6)
	move.l	cpyscren,d_form(a6)
	move.w	boxsrcx,d7
	move.w	d7,d_xmin(a6)
	andi.w	#$F,d7
	addi.w	#16,d7
	move.w	d7,s_xmin(a6)
	move.w	boxsrcy,d7
	move.w	d7,d_ymin(a6)
	move.w	#2,s_ymin(a6)
*
	move.w	#2,s_nxwd(a6)		;set source for monochrome mask
	move.w	d1,s_nxln(a6)
	move.w	#0,s_nxpl(a6)
*
	move.w	#8,d_nxwd(a6)		;set destination for cpysrc spec's
	move.w	cpy_nxln,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
*
	move.w	#4,plane_ct(a6)
*
	move.l	#$04040404,op_tab(a6)
	.dc.w	bitblt
	movem.w	(sp)+,d1-d2
*
*   Trace edge the contents of buffer
*
	movea.l	othscren,a0
	move.w	d2,d6
	addq.w	#2,d6
	move.w	d1,d7
	move.w	d7,a3
	bsr.s	outlin		;trace edge
*
*
*   outline is done, now blit this mono-form into source
*
	movea.l	#p_block,a6		;base ptr for blt parm block
	move.w	#4,plane_ct(a6)
	move.w	selctcol,fg_col(a6)
	clr.w	bg_col(a6)
*
	move.l	#$04040707,op_tab(a6)
	.dc.w	bitblt
*
	movea.l	physadd,a0
	movea.l	othscren,a1
	move.w	#999,d2
restlp1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d2,restlp1
	bsr	boxupr1			;put up new copybox
	rts
*
*
*
*  a0 -> top line of buffer (to be used as temp line buffer, assumed cleared)
*  d6 = # of vertical lines
*  d7 = form width in bytes (must be even)
*
outlin:
	lea	(a0,d7.w),a1	;bump mid line to "real" top line
outlin1:
	lea	(a1,d7.w),a2	;set up a2 to point to 1 line below current
	lsr.w	d7		;# of words in horz line
	subq.w	#1,d7		;for "dbra" sweetie
*
	bra	srt_lin
out_edge:
	movem.l	a0-a2/d6-d7,-(sp)	;save ptrs & counters
	moveq	#0,d5
	moveq	#0,d6
	move.l	(a2),d1		;get bottom line/left edge grafix data
	lsr.l	d1		;clear left-most bit too
*
*  within line loop entry point..
*
out_loop:
	move.l	(a0),d0		;get next top line grafix data
	move.b	d5,d0		;put bit to left of current data in bit 0
	ror.l	d0		;now its L 15 14 13 ... 1 0 R X X X...
*
	move.l	(a1),d2		;get current line data
	move.b	d6,d2		;same trick
	move.l	d2,d3		;d2 is left-shifted current
	ror.l	d3		;d3 is 0 shifted current
	move.l	d3,d4
	ror.l	d4		;d4 is right-shifted current
*
	move.l	d0,d5		;get copy of top line
	move.l	d0,d6		;get 2nd copy
	eor.l	d2,d0		;exclusive neighbor #1
	eor.l	d3,d5		;exclusive neighbor #2
	eor.l	d4,d6		;exclusive neighbor #3
	rol.l	d5		;adjust 0 shifted for final
	rol.l	#2,d6		;adjust right shifted too
	or.l	d5,d0		;form exclusive accumulator
	or.l	d6,d0
*
	move.l	d1,d5		;now start with a copy of bottom line
	move.l	d1,d6		;need second copy
	eor.l	d2,d1		;exclusive neighbor #4
	eor.l	d3,d5		;exclusive neighbor #5
	eor.l	d4,d6		;exclusive neighbor #6
	rol.l	d5		;adjust 0 shifted for final
	rol.l	#2,d6		;adjust right shifted too
	or.l	d1,d0
	or.l	d5,d0
	or.l	d6,d0
*
	eor.l	d3,d2		;exclusive neighbor #7
	eor.l	d3,d4		;exclusive neighbor #8
	rol.l	#2,d4
	or.l	d2,d0
	or.l	d4,d0
	swap	d0
*
	move.w	(a1),d6
	move.w	d6,d5
	eor.w	d0,d5
	and.w	d0,d5
*
	addq.l	#2,a2		;advance bottom line to next word
	move.l	(a2),d1		;get next bottom line grafix data
	move.b	-1(a2),d1	;same trick as with top line
	ror.l	d1		;now its L 15 14 13 ... 1 0 R X X X...
*
	move.w	d5,(a1)+
	move.w	(a0),d5
	move.w	d6,(a0)+
*
	dbra	d7,out_loop	;finish rest of line
*
	movem.l	(sp)+,a0-a2/d6-d7	;save ptrs & counters
	move.l	a2,a1
	adda.l	a3,a2
	cmpi.w	#1,d6
	bne.s	srt_lin
	move.l	a1,a2
srt_lin:
	dbra	d6,out_edge
	rts
*
*
*
*  Function 10-- color swap
*
cfunc10:
	lea	newcolrz(pc),a0
	move.w	#15,d1
newlp:
	move.b	d1,(a0,d1.w)
	dbra	d1,newlp
*
	move.w	colleft,d1
	move.w	colrite,d2
	move.w	selctcol,d3
	cmp.w	d3,d1			;is left ptr also selected color?
	beq.s	riteonly
	cmp.w	d3,d2			;is right ptr also selected color?
	bne.s	doboth
	move.b	d2,(a0,d1.w)
	bra.s	ovboth
*
*  color swap table
*
newcolrz:
	.dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
*
*
doboth:
	move.b	d2,(a0,d1.w)
riteonly:
	move.b	d1,(a0,d2.w)
ovboth:
	btst.b	#0,copystat	;box in existence?
	bne.s	nocundo		;skip un-undo if in existence
	move.b	likesel,d1
	clr.b	likesel		;fake-out undo
	clr.b	undoyet
	bsr	unundo		;save previous work
	move.b	d1,likesel
	bra.s	halfswap	
nocundo:
	bsr.s	cpyscrst	;make sure copy source is from cpyscren
*
	move.w	boxsrcx,d2
	move.w	boxsrcy,d3
	move.w	boxhite,a2
	move.w	boxwidth,d0
	bra.s	normswap
*
*
cpyscrst:
	movea.l	cpysrc,a1
	movea.l	cpyscren,a2
	cmpa.l	a2,a1
	beq.s	srcset
	move.w	#999,d2
	tst.b	bigram		;32k buffers?
	beq.s	cpyslp		;br if only 16k
	move.w	#1999,d2
cpyslp:
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	dbra	d2,cpyslp
	move.l	cpyscren,a1
	move.l	a1,cpysrc
srcset:
	rts
*
*
halfswap:
	movea.l	curscren,a1
	clr.w	d2
	clr.w	d3
	move.w	#200,a2
	tst.w	full
	bne.s	hswpx
	move.w	#100,a2
hswpx:
	move.w	#320,d0
	move.w	#160,cpy_nxln		;since no box exists, this can't hurt
normswap:
	bsr	swapclr
	btst.b	#0,copystat		;box in existence?
	beq.s	nouput			;br if so
*
	movea.l	physadd,a0
	movea.l	othscren,a1
	move.w	#999,d2
	tst.w	full
	beq.s	restlp
	move.w	#1999,d2
restlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d2,restlp
	bsr	boxupr1			;put up new copybox
nouput:
	rts
*
*
*  make sure othscren is "big one"
*
canonscn:
	movem.l	a0-a1/d0,-(sp)
	move.l	curscren,a0
	move.l	othscren,a1
	cmpa.l	a0,a1
	bgt.s	canon2			;br if othscren is big one, we're set
	move.w	#1999,d0
canon1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,canon1
	bsr	screnswp
canon2:
	movem.l	(sp)+,a0-a1/d0
	rts
*
	.bss
xgridalg:
	.ds.b	1	;mod 8 xpos of top/left corner when cut/copy & grid
*			or negative if no alignment
ygridalg:
	.ds.b	1	;mod 8 ypos of top/left corner when cut/copy & grid

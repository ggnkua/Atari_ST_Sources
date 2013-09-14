*********************************
*				*
*	Fat-bits Functions	*
*				*
*********************************
*
*
*    Programmer: Dave Staugas
*	  Start: March 1985
*   Last update: 14 Aug 1986
*
*
	.text
	.include	"fatequ.s"
*
*
	.globl	anii,anid,aniupd
*
*
*  temp globals
*
	.globl	cutwidth,cuthite,cutx,cuty
*
*  public globals
*
	.globl	screnswp,getnewfl,refile,matupd,shwboxz
	.globl	newtxtmd,texbasx,texbasy,textadj,touch,anistat,curcell
	.globl	cellwid,cellhite,chgxcur,cel2scr,scr2cell,needothr,othsame
	.globl	cellsize,anibase,aninext,aniend,scr02scr,cel2phys
	.globl	txstring,killclip,jackant,shrink2f
	.globl	scalemd,orgwidth,orghite,clrstrch,initscal
	.globl	a_block,othwidth,othhite,lastfrm,scaler,inotjack
	.globl	anistrng,aniblank
	.globl	doread,rezpalt
*
*
*  external globals
*
	.globl	scale_man,copyi,copyupd,jack_kni,outlin
	.globl	curfont,contrl,curscren,cutscren,cpyscren
	.globl	intin,int_in,int_out,colorz
	.globl	_pblock,ptsout,intout
	.globl	ptsin,addr_in,control,aes_pb
	.globl	likesel,undoyet,rezset,rezclr
	.globl	vcanbase,vircan,virhandx,virhandy,vpixwd,vpixht,vformwd
	.globl	vcansize,virtouch
	.globl	handd,handii
*
	.globl	straini,strain,constran,strain8,strainx,strainy,straindg
	.globl	rexboxld
	.globl	curpoint,pointcnt,slopex,slopey
*
	.globl	rect,rndrect,ellipse,polypnt,polyline
	.globl	hollow,linethik,shapesel,rethik,setxlate,lindthik,relthik
*
	.globl	cbarx,cbary,systxt6
	.globl	refunc,lastx,lasty
*
	.globl	vdicall,alertout,gemready
	.globl	objc_drw,form_do,form_alr,graf_mou,fsel_inp
	.globl	appl_int,graf_hdl,appl_ext
	.globl	loadcol,pointcol,leftpt,ritept,unleftpt,unritept
	.globl	newbox,unselbox
	.globl	aoriginx,aoriginy,adiagx,adiagy,animtxts,putanitx
	.globl	coninst,conin,cscroll,cscrolr,cscrlupd
	.globl	oncurtx,offcurtx,graftxt,matrix,uncolor,newband,othband
	.globl	draw,box,invdraw,undraw,mouseget,hotbox,unhotbox
	.globl	drawq,invdrawq,textd,copyd,blitmask,brshptr,jackdd
*
	.globl	shapebuf
*
	.globl	irqlev,henabl,curpalt,half,selctcol,colleft,colrite,cscrolst
	.globl	frmcnt,tcdifsav,tcdif,keysav,midi,timrcsav,lowc,csped
	.globl	hblksav,hblknull,vblksav,vblk,mouse,oldmouse
	.globl	mousped,xpos,ypos,textx,texty,updown,doubtiml,doubtimr
	.globl	p_block,diagx,originx,diagy,originy
	.globl	liconlst,matselx,matsely,handy,half,full
*
	.globl	inits,deinits,funcs,matxupd,conchar,funky,funkydo,jfunkydo
*
	.globl	physadd,fs_inpath,fs_insel,nofile,path,screen0,chg2cur
	.globl	copystat,othscren,textalin,txtcelht,txtbastp,textstyl
	.globl	jackstat,jackmwd
*
	.globl	linedraw,lineundo,rampcolr,rampcoll,antptr,antpatrn,antbox
	.globl	blitmode,jackmode,brshbrez,updtxts,putcpytx,movebox
*
	.globl	stamp,monomask,cpysrc,boxsrcx,boxsrcy,boxhite,boxwidth
	.globl	othrorgy,othrorgx,unundo,getpix,scaleft,scalrite,stampx
*
	.globl	cpy_nxln,cut_nxln
	.globl	brshupd
*
*	All equates from equate file...
*
*  ASCII control codes..
*
*	.globl	bs,lf,cr,esc,ctrlx,del
*	.globl	func1,func2,func3,func4,func5,func6,func7,func8,func9,func10
*
*  Hardware vectors..
*
*	.globl	vblankv,timercv,keybrdv,hblkcv,eventmc
*
*  Other hardware locations..
*
*	.globl	hpalet
*	.globl	iera,ierb,ipra,iprb,isra,isrb,imra,imrb,tbcr,tbdr,tcdcr,tcdr
*
*  Line A ABline offsets..
*
*	.globl	fg_bp_1,fg_bp_2,fg_bp_3,fg_bp_4
*	.globl	lstlin,ln_mask,wrt_mode,x1,y1,x2,y2,line
*
*  Line A Bitblt offsets..
*
*	.globl	b_width,b_height,plane_ct,fg_col,bg_col
*	.globl	op_tab
*	.globl	s_xmin,s_ymin,s_form,s_nxwd,s_nxln,s_nxpl
*	.globl	d_xmin,d_ymin,d_form,d_nxwd,d_nxln,d_nxpl
*	.globl	p_addr,bitblt
*
*  GEM Object resouces
*
*	.globl	G_BOX,G_TEXT,G_BOXTXT,G_BUTTON,G_STRING,G_FBOXTX
*	.globl	NONE,SELECTBL,DEFAULT,EXIT
*	.globl	EDITABLE,RBUTTON,LASTOB
*	.globl	NORMAL,SELECTED,CROSSED,CHECKED,DISABLED,OUTLINED,SHADOWED
*	.globl	WHITEBAK,WHITE,BLACK,RED,GREEN
*	.globl	IBM,TE_LEFT,TE_RIGHT,SYS_FG
*
*  Dialog Box size equates..
*
*	.globl	obdrxclp,obdryclp,obdrwclp,obdrhclp
*
*  Screen layout..
*
*	.globl	fatpxlnx,fatpxlny,fatpxlw,fatpxlh
*	.globl	fatblkx1,fatblky1,fatblkx2,fatblky2
*	.globl	targx,targy,hotpxlx1,hotpxly1,hotpxlx2,hotpxly2
*	.globl	pallx,pally,pallw,pallh
*	.globl	iconw,iconh
*	.globl	iconlx,iconly,iconlw,iconlh
*	.globl	iconrx,iconry,iconrw,iconrh
*
*
*   Initialize functions vectors
*
inits:
	.dc.l	jacki		;0-jack knife
	.dc.l	handi		;1-hand
	.dc.l	copyi		;2-copybox
	.dc.l	texti		;3-text
	.dc.l	pencli		;4-pencil
*
	.dc.l	ldrawi		;5-line draw
	.dc.l	filli		;6-fill bucket
	.dc.l	stubi		;7-test function
	.dc.l	stubi		;8
	.dc.l	brshi		;9-brush
*
	.dc.l	stubi		;A-diskette
	.dc.l	anii		;B-animate
	.dc.l	shapei		;9-shapes
	.dc.l	erasi		;E-eraser
	.dc.l	sprayi		;C-spray
*
*  De-initialize functions vectors..
*
deinits:
	.dc.l	jackd		;0-jack knife
	.dc.l	handd		;1-hand
	.dc.l	copyd		;2-copybox
	.dc.l	textd		;3-text
	.dc.l	pencld		;4-pencil
*
	.dc.l	ldrawd		;5-linedraw
	.dc.l	filld		;6-fillbucket
	.dc.l	stubd		;7
	.dc.l	stubd		;8
	.dc.l	brshd		;9-brush
*
	.dc.l	stubd		;A-diskette
	.dc.l	anid		;B-animate
	.dc.l	shaped		;9-shapes
	.dc.l	erasd		;E-eraser
	.dc.l	sprayd		;C-spray
*
*  Function update vectors..
*
funcs:
	.dc.l	jackupd		;0-jack knife
	.dc.l	handupd		;1-hand
	.dc.l	copyupd		;2-copybox
	.dc.l	textupd		;3-text
	.dc.l	penclupd	;0-pencil
*
	.dc.l	ldrawupd	;5-linedraw
	.dc.l	fillupd		;6-fillbucket
	.dc.l	stubupd		;7
	.dc.l	stubupd		;8
	.dc.l	brshupd		;D-brush
*
	.dc.l	stubupd		;A-diskette
	.dc.l	aniupd		;B-animate
	.dc.l	shapupd		;9-shapes
	.dc.l	erasupd		;E-erase
	.dc.l	sprayupd	;C-spray
*
*
*  Data in registers d0,d1,d2,d3,d4
*  input to all function updates is output from mouseget
*
* i.e., d0 - new mouse x
*	d1 - new mouse y
*	d2 - mouse buttons
*	d3 - old mouse x
*	d4 - old mouse y
*
*  Stub function-------------------------------------------
*
*
stubi:
	rts
stubd:
	rts
stubupd:
	rts
*
*
*  this code copies bottom layout to main buffer
*  for temporary screen layout use only
*  Remove for any release versions
*
	nop
	.if	0
*
testi:
	move.l	curscren,a0
	move.l	screen0,a1
	adda.w	#16000,a0
	adda.w	#16000,a1
	move.w	#3999,d3
testilp:
	move.l	(a0)+,(a1)+
	dbra	d3,testilp
	rts
	.endif
*
	nop
*
*  Needs to go into fatsub
*
*  turn off clipping
*
killclip:
	move.l	a0,-(sp)
	movea.l	#contrl,a0
	move.w	#129,(a0)+		;kill clip window
	move.w	#2,(a0)+
	addq.l	#2,a0
	move.w	#1,(a0)
	move.w	#0,intin
	bsr	vdicall
	move.l	(sp)+,a0
	rts
*
*
setclip:
	movem.l	a0/d7,-(sp)
	movea.l	#contrl,a0
	move.w	#129,(a0)+		;set clip window
	move.w	#2,(a0)+
	addq.l	#2,a0
	move.w	#1,(a0)
	move.w	#-1,intin
	movea.l	#ptsin,a0
	clr.w	(a0)+
	clr.w	(a0)+
	move.w	#319,(a0)+
	move.w	half,d7
	subq.w	#1,d7
	move.w	d7,(a0)
	bsr	vdicall
	movem.l	(sp)+,a0/d7
	rts
*
*
*  check undoyet for 1st alter, this mode
*  and if so, copy old to main
*
unundo:
	bset.b	#0,undoyet		;check for 1st alteration, 
	bne.s	unundox			;br if operation performed already
*
*  assume only half screen for now.
*
	movem.l	a0-a1/d0-d1,-(sp)
	movea.l	screen0,a1
	movea.l	curscren,a0
	move.b	likesel,d1
	cmpi.b	#2,d1			;in copy mode?
	bne.s	unundodo
	movea.l	physadd,a0		;get stuff from background buffer
unundodo:
	move.w	#1999,d0
	tst.w	full
	bne.s	unundolp		;if full br over half calculations
*
	move.w	handy,d1
	mulu	#160,d1
	adda.w	d1,a1
	move.w	#999,d0
unundolp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,unundolp
	movem.l	(sp)+,a0-a1/d0-d1
*
unundox:
	rts
*
*
*
*  Jack Knife function---------------------------------------
*
*   jackstat	bit0--1 if cut-out area completely defined
*		bit1--1 if cut-out area has been started
*		bit2--1 if cut-out area is being dragged
*		bit3--1 if cursor is inside jack (a pointer)
*		bit4--1 if stamp before drag start
*
jacki:
	clr.b	jackstat
	move.w	blitmode,obltmode
	move.w	#-1,blitmode
*
	clr.b	funky
	rts
*
*   jack knife de-init (use when leaving jack knife mode)
*
jackd:
	moveq	#0,d7
	move.w	obltmode,d7
	bra.s	jackddd
*
*  kill jack knife (use when dropping active jack knife)
*
jackdd:
	moveq	#-1,d7
	move.w	blitmode,d7
jackddd:
	tst.b	jackstat
	beq.s	jackd1
	bsr	jackosrt	;clean up trace-edge mask in othscren
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	move.l	d7,-(sp)
	bsr	movebox		;lay boxy lay--lay across my big brass bayd
	move.l	(sp)+,d7
	clr.b	jackstat
	bsr	updtxts
	tst.l	d7
	bpl.s	jackd1
	bsr	putcpytx
jackd1:
	move.w	d7,blitmode
	rts
*
*
*
jackupd:
	tst.b	d2			;any mouse button action here?
	bne.s	jckupdd			;go do it if so--function keys'll wait
*
	tst.b	funky
	bne	jfunkydo
*
jckupdd:
	move.b	jackstat,d5
	btst.l	#0,d5			;check for active jack
	bne	actjack			;br if jack is active
*
	btst.l	#1,d5			;started defining?
	bne.s	njklead			;br to continue defining
*
	move.w	d2,d7
	andi.w	#$c,d7			;any leading edges?
	beq	jackpq
*
*  starting a new jack knife
*
	move.b	#2,jackstat		;start new jack
	movea.l	othscren,a0		;copy current screen to other
	movea.l	curscren,a1
	move.w	#1999,d6
jackful:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d6,jackful
*
	clr.b	undoyet
	move.w	#500,d7		;put in a ridiculous value
	move.w	d7,slopex	;for previous point slopes
	move.w	d7,slopey
*
	move.l	physadd,a0	;use physadd buffer for vertices
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	move.l	a0,curpoint
	move.w	#1,pointcnt
	bra	contjack
*
*
njklead:
	move.w	d2,d7
	andi.w	#$30,d7			;trailing edges?
	beq	njktrail
	addq.w	#1,pointcnt		;yes, trailing edges
*
*  complete jack knife define
*
jacke:
	cmpi.w	#2,pointcnt
	bcs.s	jackqq
*
	move.l	curpoint,a0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
*
	move.w	#15,d2		;color #15
	moveq	#0,d5		;replace mode
*
	bsr	linedrw		;draw a line
*
	move.w	d0,d3
	move.w	d1,d4
*
	move.l	physadd,a1
	move.w	(a1)+,d0
	move.w	(a1)+,d1
*
	move.w	d0,(a0)+
	move.w	d1,(a0)+
*
	bsr	linedrw
*
jackqq:
	move.b	#1,jackstat	;jack complete now
*
	movea.l	othscren,a0	;source screen
	movea.l	cpyscren,a1	;destination screen
	move.l	a1,cpysrc
	move.w	#160,cpy_nxln
	move.l	#blitmask,a2	;mask buffer
	move.l	physadd,a3	;vdi format points list
	move.w	pointcnt,d0	;point count
	jsr	jack_kni	;generate mask & src form
*
	bsr	shrink2f	;shrink d4-d7 to fit
	beq	screnswp	;br to clear & exit if "air"
*
	move.w	d4,originx
	move.w	d4,boxsrcx
	move.w	d4,othrorgx
	move.w	d5,originy
	move.w	d5,boxsrcy
	move.w	d5,othrorgy
	move.w	d6,diagx
	move.w	d7,diagy
	sub.w	d4,d6
	addq.w	#1,d6
	move.w	d6,boxwidth
	sub.w	d5,d7
	addq.w	#1,d7
	move.w	d7,boxhite
*
*  copy good src to physadd & cut hole therein..
*  also, perform unundo function here
*	
	bset.b	#0,undoyet
	movea.l	physadd,a0
	movea.l	othscren,a1
	movea.l	#blitmask,a2
	movea.l	screen0,a3
	move.w	#3999,d6
	bsr	updtxts
	tst.w	full
	bne.s	jackfulp
	bsr	putcpytx
	move.w	handy,d7
	mulu	#160,d7
	adda.w	d7,a3
	move.w	#1999,d6
jackfulp:
	move.w	(a2)+,d7
*
	move.w	(a1)+,d5
	move.w	d5,(a3)+
	and.w	d7,d5
	move.w	d5,(a0)+
*	
	move.w	(a1)+,d5
	move.w	d5,(a3)+
	and.w	d7,d5
	move.w	d5,(a0)+
*	
	move.w	(a1)+,d5
	move.w	d5,(a3)+
	and.w	d7,d5
	move.w	d5,(a0)+
*	
	move.w	(a1)+,d5
	move.w	d5,(a3)+
	and.w	d7,d5
	move.w	d5,(a0)+
*	
	dbra	d6,jackfulp
*
	bsr	screnswp
*
	movea.l	curscren,a0
	movea.l	othscren,a1
	move.w	#1999,d6
jackful1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d6,jackful1
*
	clr.w	pointcnt
	clr.b	undoyet
	bra	jackant
*	rts
*
*
njktrail:
	move.w	d2,d7
	andi.w	#3,d7
	beq	jackpq
*
*  continue with jack knife define points
*
	tst.w	pointcnt
	beq	jackpq
contjack:
	addq.w	#1,pointcnt
	cmpi.w	#512,pointcnt
	bcc	jacke
*
	move.l	curpoint,a0
	move.w	-2(a0),d6
	move.w	-4(a0),d5
	sub.w	d0,d5
	bne.s	formy
	tst.w	slopex
	bne.s	formy
	sub.w	d1,d6
	move.w	slopey,d7
	move.w	d6,slopey
	eor.w	d6,d7
	bpl.s	nojktry
	bra.s	addentry
formy:
	sub.w	d1,d6
	bne.s	slopchk
	tst.w	slopey
	bne.s	slopchk
	move.w	slopex,d7
	move.w	d5,slopex
	eor.w	d5,d7
	bmi.s	addentry
nojktry:
	subq.w	#1,pointcnt
	move.w	d0,-4(a0)
	move.w	d1,-2(a0)
	bra.s	dojack
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
	beq.s	nojktry
addent:
	move.w	a1,slopex
	move.w	a2,slopey
addentry:
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.l	a0,curpoint
dojack:
	move.w	#15,d2
	moveq	#0,d5
	bra	linedrw
jackpq:
	rts
*
*
*
*  move jack stuff around
*
actjack:
*
	btst.b	#2,jackstat	;check box draggin?
	bne.s	njkcrchk	;skip cursor check if draggin'
*
*  check for cursor within jack area
*
	bsr	inotjack	;returns: z = inside; nz = outside
	bne.s	outsdjk		;br if outside jack
*
*  inside jack area
*
	bset.b	#3,jackstat	;have we made cursor a ptr?
	bne.s	njkcrchk
	move.w	d0,-(sp)
	moveq	#15,d0
	bsr	chgxcur
	move.w	(sp)+,d0
	bra.s	njkcrchk
*
*
*
outsdjk:
	bclr.b	#3,jackstat	;have we restored cursor to "jack" sign?
	beq.s	njkcrchk
	bsr	chg2cur
njkcrchk:
	move.w	d2,d7
	andi.w	#$3c,d7		;any button change?
	beq	nobtchg		;br if no button change
*
	btst.l	#2,d2		;left button clicked?
	beq.s	notlbt		;br if not
*
*  left button click
*
	clr.b	touch
*
	btst.b	#3,jackstat	;inside or outside jack?
	bne.s	injack
*	bsr	stamp		;why did I ever do this???
	bra	jackdd
injack:
	bsr	straini
	bset.b	#2,jackstat	;start box drag
	bclr.b	#4,jackstat	;delayed stamp request?
	beq.s	jackosrt	;br to set-up othscren & exit if not
	bsr.s	jackosrt	;else, clean up then stamp
	bra	antstamp	;exit thru stamp
*
*   we call this as a routine when terminating jack too
*
jackosrt:
	movea.l	physadd,a0
	movea.l	othscren,a1
	move.w	#1999,d0
	tst.w	full
	bne.s	injack1
	move.w	#999,d0
injack1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,injack1
jackkq:
	rts
*
notlbt:
	btst.l	#4,d2		;left release?
	beq	notlrel
*
	btst.l	#1,d2		;right button down?
	bne	notlrel		;skip box drag kill if right down
*
*  kill box drag
*
*kboxdrg:
	clr.b	constran
	bclr.b	#2,jackstat	;kill box drag
*
*  set-up jack ants
*
jackant:
*
*  blit mono-mask to mono trace-edge area..
*
	movea.l	#m2m_blk,a6	;blit block for mono-mask to trace edge buf
	move.w	#1,plane_ct(a6)	;always refresh plane count
	move.l	othscren,a1
	move.l	a1,d_form(a6)	;destination form
*
	move.w	cpy_nxln,d0
	lsr.w	#2,d0
	move.w	d0,s_nxln(a6)
*
	move.w	boxsrcx,s_xmin(a6)
	move.w	boxsrcy,s_ymin(a6)
	move.w	boxwidth,d0
	move.w	d0,b_width(a6)
	move.w	boxhite,d1
	move.w	d1,b_height(a6)
*
	moveq	#$F,d4
	move.w	originx,d2
	move.w	d2,d3
	and.w	d4,d3
	ori.w	#$10,d3
	move.w	d3,d_xmin(a6)	;force dest xmin to fall in 2nd word
*
	add.w	d2,d0		;d2 = dst xmin
	subq.w	#1,d0		;d0 = dst xmax
	not.w	d4		;d4 = $FFF0
	and.w	d4,d0		;clr lo nibble, dst xmax
	and.w	d4,d2		;clr lo nibble, dst xmin
	sub.w	d2,d0		;word difference
	lsr.w	#3,d0		;/8 for dst span - 2 in bytes
	addq.w	#6,d0		;d0 = dst form-width (2 + 4 more bytes padding)
	move.w	d0,jackmwd	;save
	move.w	d0,d_nxln(a6)	;tell bitblt too
	move.w	d0,d7
*
* a1 -> dst form (othscren)
* d0 = dst form width
* d1 = height
*
	move.l	a1,a0		;save dest address for outlin code in a0
	lsr.w	#1,d0		;width in words
	subq.w	#1,d0		;width -1
	moveq	#0,d2
	moveq	#-1,d3
	move.w	d0,d4
clrtoplp:
	move.w	d2,(a1)+	;clear top row
	dbra	d4,clrtoplp
*
	addq.w	#1,d1		;d1 = height + 1 (for 2 rows extra)
	move.w	d1,d6
	addq.w	#1,d6		;d6 = height + 2 for outlin code
clrtopl2:
	move.w	d0,d4
clrtopl1:
	move.w	d3,(a1)+	;all 1's to following row
	dbra	d4,clrtopl1	;next word, this row
	dbra	d1,clrtopl2	;next row
*
	movem.l	a0/d6-d7,-(sp)
	.dc.w	bitblt
	movem.l	(sp)+,a0/d6-d7
*
	move.w	d7,a3
	bsr	outlin
	rts
*
*******************************************************
*
*
*   check for inside or outside of jacknife area
*
inotjack:
	move.w	cpy_nxln,d5	;get form width
	add.w	d5,d5		;get xmax +1
*
	move.w	boxsrcx,d6	;map cursor position relative to originx
	sub.w	originx,d6	;onto mono-mask form
	add.w	d0,d6		
	bmi.s	outjk		;br as outsidejack if left of mono-mask form
	cmp.w	d5,d6		;check right bounds
	bge.s	outjk		;br as outsidejack if out on right side	
*
	lsr.w	#3,d5		;d5= blitmask form width
*  
	move.w	boxsrcy,d7
	sub.w	originy,d7
	add.w	d1,d7
	bmi.s	outjk
*
	mulu	d5,d7
*	
	move.w	d6,-(sp)		
	lsr.w	#4,d6
	lsl.w	#1,d6
	add.w	d6,d7
	move.w	(sp)+,d6
	cmpi.w	#8320,d7
	bge.s	outjk
*
	not.w	d6
	andi.w	#$F,d6
	movea.l	#blitmask,a0
	move.w	0(a0,d7.w),d7
	btst.l	d6,d7
	bne.s	outjk
	rts
outjk:
	moveq	#-1,d6
	rts
*
*******************************
*
*  now, shrink to fit jack knife mins & maxs
*
*entry:	d4 = xmin
*	d5 = ymin
*	d6 = xmax
*	d7 = ymax
*
*exit:
*	d4-d7 true min/max shrunken to fit non color 0 grafix
*  z - air ball
* nz - good non-color 0 grafixs
*
shrink2f:
	move.w	cpy_nxln,d2	;get form width of cpysrc
	lsr.w	#2,d2		;derive mono-mask width
*
	move.w	d5,d0		;d0=ymin
	mulu	d2,d0		;d0=offset to top of box
*
	movea.l	#blitmask,a0	;mono-mask base address
	move.l	a0,a1
	adda.w	d0,a0		;a0 -> start of top line of box
	move.w	d7,d0		;ymax
	addq.w	#1,d0		; 1 beyond ymax
	mulu	d2,d0		;d0=offset to 1 line below box
	adda.w	d0,a1		;a1 -> start of 1 line below bottom of box
	move.w	d2,d3		;d3=form width (bytes)
	lsr.w	#1,d3		;d3=form width (words)
*
*  look for any zeros in upper horz line on down..
*
toplp0:
	move.w	d3,d0		;loop count to temp
	moveq	#-1,d1
	bra.s	toplpi		;enter dbra part of loop
toplp:
	and.w	(a0)+,d1	;any zeros in here?
toplpi:
	dbra	d0,toplp	;finish line
*
	addq.l	#1,d1		;a0 -> start of line below tested one
	bne.s	topsiz		;br if not all $FFFF before addq #1
	addq.w	#1,d5		;else, we got all 1's--inc ymin count
	cmp.w	d7,d5		;exceeding ymax?
	ble.s	toplp0		;loop for next line if not
*
*  no 0's found in region, must be "air" ball--cancel this jack
*
	clr.b	jackstat
	clr.b	constran
	rts
topsiz:
*
*  got shrunken ymin in d5
*
*
*  Now, look for any zeros in lower horz line on up..
*
botlp0:
	move.w	d3,d0		;loop count to temp
	moveq	#-1,d1
	bra.s	botlpi		;enter dbra part of loop
botlp:
	and.w	-(a1),d1	;any zeros in here?
botlpi:
	dbra	d0,botlp	;finish line
*
	addq.l	#1,d1		;a1 -> start of line tested
	bne.s	botsiz		;br if not all $FFFF before addq #1
	subq.w	#1,d7		;else, we got all 1's--dec ymax count
	cmp.w	d7,d5		;still greater than ymin?
	bcs.s	botlp0		;loop for next line if so
	suba.w	d2,a1		;else, must be equal--put a1 at start of line
*
botsiz:
*
*  got shrunken ymax in d7
*
*  now do xmin/max
*
	suba.w	d2,a0		;a0->start of uppermost line with stuff in it
	andi.w	#$FFF0,d4	
	move.w	d4,d0
	lsr.w	#3,d0
	adda.w	d0,a0
	andi.w	#$FFE0,d6
	move.w	d6,d1
	lsr.w	#3,d1
	move.l	a1,a2
	adda.w	d1,a2
leflp:
	moveq	#-1,d0
	move.l	a0,a3
leflp1:
	and.l	(a3),d0
	adda.w	d2,a3
	cmpa.l	a3,a2
	bge.s	leflp1
*
	addq.l	#1,d0
	bne.s	lefsiz
	addq.l	#4,a0
	add.w	#32,d4
	cmp.w	d4,d6
	bge.s	leflp
*
lefsiz:	
	subq.l	#1,d0
	swap	d0
	cmpi.w	#$FFFF,d0
	bne.s	lefx1
	swap	d0
	add.w	#16,d4
lefx1:
	lsl.w	#1,d0
	bcc.s	lefx2
	addq.w	#1,d4
	bra.s	lefx1
lefx2:
*
*  got shrunken left min in d4
*
*  now do right xmax
*
	add.w	#31,d6			;we're lookin' from the rite now
	lsl.w	#3,d2
	cmp.w	d2,d6			;too far right?
	blt.s	ritlp0
	sub.w	#16,d6
	subq.l	#2,a2
ritlp0:
	lsr.w	#3,d2
ritlp:
	moveq	#-1,d0
	move.l	a2,a3
ritlp1:
	and.l	(a3),d0
	suba.w	d2,a3
	cmpa.l	a3,a0
	ble.s	ritlp1
*
	addq.l	#1,d0
	bne.s	ritsiz
	subq.l	#4,a2
	sub.w	#32,d6
*
*	bpl.s	ritsizx
*	addq.l	#2,a2
*	add.w	#16,d6
*ritsizx:
*
	cmp.w	d4,d6
	bge.s	ritlp
ritsiz:	
	subq.l	#1,d0
	cmpi.w	#$FFFF,d0
	bne.s	ritx1
	swap	d0
	sub.w	#16,d6
ritx1:
	lsr.w	#1,d0
	bcc.s	ritx2
	subq.w	#1,d6
	bra.s	ritx1
ritx2:
	moveq	#-1,d0		;set nz for success
	rts
*
*
notlrel:
	btst.l	#3,d2		;right click?
	beq	notrbt		;br if no right click
	clr.b	touch
*
	btst.b	#3,jackstat	;inside or outside jack?
	beq.s	jackbrsh	;br if outside--do normal stamp
	bsr.s	delystmp	;else, set stamp delay bit
	bra	injack		;start-up right button drag
*
*  rite button click, stamp to screen
*  but 1st check jack drag
*
jackbrsh:
*	btst.l	#0,d2		;left button down?
*	beq.s	delystmp	;br if no--ants up, delay stamp until move
*
	btst.b	#2,jackstat	;box drag?
	beq.s	delystmp	;br if not--ants up, etc.
*
*  left button down--we're draggin'
*
	tst.w	d2		;delta x or y?
	bpl.s	dostamp		;
	movem.w	d0-d1,-(sp)
	bsr	strain
	bsr	movebox
	movem.w	(sp)+,d0-d1
dostamp:
	bsr	stamp
btnotdwn:
	rts
delystmp:
	bset.b	#4,jackstat	;set delayed stamp request
	rts
antstamp:
	movem.w	d0-d7,-(sp)	;do stamp without othscren modify
	movea.l	#p_block,a6
	move.w	boxwidth,b_width(a6)
	move.w	boxhite,b_height(a6)
	move.l	#$03030303,op_tab(a6)
*
	move.w	#8,d_nxwd(a6)
	move.w	#160,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
*
	bra	stampx		;enter stamp routine after othscren modify
*
notrbt:
	btst.l	#5,d2		;right button release?
	beq.s	nobtchg		;br if not
	btst.l	#0,d2		;left button down
	bne.s	nobtchg		;br if so
	clr.b	constran
	bclr.b	#2,jackstat	;kill box drag
	bne	jackant		;br if we were right button draggin
nobtchg:
	btst.l	#1,d2		;right button dwn?
	bne	jackbrsh	;continuous jack brush
*
	btst.b	#2,jackstat	;check box draggin?
	beq.s	btnotdwn
	movem.w	d0-d1,-(sp)
	bsr	strain
	bsr	movebox
	movem.w	(sp)+,d0-d1
	rts
*
*
*
*
*
*  Pencil function-------------------------------------------
*
pencli:
	rts
pencld:
	rts
penclupd:
	move.w	d2,d7			;copy buttons to temp
	andi.w	#$3c,d7			;any edges?
	beq.s	nopenedg		;br if no edges
	andi.w	#$30,d7			;trailing edges?
	beq.s	notrledg		;br if not trailing edges
	clr.b	constran		;exit constrain mode if in effect
	clr.b	undoyet
	bra.s	nopenedg
notrledg:
	bsr	straini
	clr.b	touch
	bsr	unundo			;if 1st alter, copy to main
nopenedg:
	btst.l	#0,d2			;left button down?
	bne.s	pen1			;br to write if so
	btst.l	#1,d2			;right button down
	beq.s	penq
	moveq	#0,d2
	bra.s	pen2
pen1:
	move.w	selctcol,d2		;get selected color
pen2:
	movem.w	d0-d1,-(sp)
	bsr	strain
	move.w	#0,d5			;replace mode
	bsr	linedrw			;draw line from x
	movem.w	(sp)+,d0-d1
penq:
	rts
*
*  Line draw function-------------------------------------------
*
ldrawi:
	move.w	#-1,ldrworgx
	bsr	relthik
	rts
*
*
ldrawd:
	rts
*
*  Line draw update
*
ldrawupd:
	move.w	d2,d5
	andi.w	#$c,d5			;left or right leading edge?
	beq	ldra1			;br if not
*
	tst.w	ldrworgx		;origin set?
	bmi.s	ldrw4			;br if not, go set one
*
*  origin was set, so other button was clicked--cancel this line
*
	movem.w	d0-d1,-(sp)
	clr.b	constran
	move.w	ldrworgx,d0
	move.w	ldrworgy,d1
*
	move.w	d3,d2			;29-Aug
	move.w	d4,d3			;29-Aug
	move.l	curscren,a5
	bsr	lineundo		;29-Aug
*
	bsr	screnswp		;8-Jul
	movem.w	(sp)+,d0-d1
*
	move.w	#-1,ldrworgx
	clr.b	undoyet
	rts
*
*
ldrw4:
*	
*  left/right leading trigger
*
	move.l	curscren,a0		;8-Jul  Copy current screen to other
	move.l	othscren,a1
	move.w	#1999,d7
ldrw4lp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,ldrw4lp		;8-Jul
*
	bsr	straini
	clr.b	touch
	move.w	d5,linebut		;save button
	btst.l	#3,d5			;check which
	bne.s	ldrw2			;br if right button
*
*  left trigger, use selctcol monochrome
*
	move.w	selctcol,d5
	move.w	d5,rampcoll
	move.w	d5,rampcolr
	bra.s	ldrw3
*
*  right trigger, use ramp
*
ldrw2:
	move.w	colrite,rampcolr
	move.w	colleft,rampcoll
ldrw3:
	bsr	unundo			;save previous work
	move.w	d0,ldrworgx		;set origin
	move.w	d1,ldrworgy
	move.w	d0,d2			;29-Aug
	move.w	d1,d3			;29-Aug
	bsr	linedraw		;29-Aug
	movem.l	d0-d1,-(sp)
	bsr	screnswp		;8-Jul
	movem.l	(sp)+,d0-d1
	rts
*
*  No leading edge found, check trailing
*
ldra1:
	tst.w	ldrworgx		;origin set?
	bmi	ldraq			;exit if not
*
	move.w	d2,d5
	andi.w	#$30,d5			;left or right trailing edge?
	beq.s	ldra2			;br if not
*
	lsr.w	#2,d5
	cmp.w	linebut,d5		;trailing edge of button we're on?
	bne.s	ldra2			;br if not
*
	movem.w	d0-d1,-(sp)
	move.w	ldrworgx,d0
	move.w	ldrworgy,d1
*
	move.w	d3,d2			;29-Aug
	move.w	d4,d3			;29-Aug
	move.l	curscren,a5
	bsr	lineundo		;29-Aug
*
	movem.w	(sp)+,d0-d1
*
*  try new bresenham
*
	movem.l	d0-d4,-(sp)
	bsr	strain8
	clr.b	constran
	move.w	d0,d2
	move.w	d1,d3
	move.w	ldrworgx,d0
	move.w	ldrworgy,d1
	bsr	linedraw		;draw final line
	bsr	screnswp		;8-Jul
	movem.l	(sp)+,d0-d4
	move.w	#-1,ldrworgx
	clr.b	undoyet
	rts
*	
*  end new stuff
*	
ldra2:
	move.w	d2,d5
	andi.w	#3,d5
	beq.s	ldraq			;br if left/right button not down
	lsl.w	#2,d5
	cmp.w	linebut,d5
	bne.s	ldraq
*
*  left button down
*
	tst.w	d2			;change in x or y
	bpl.s	ldraq			;exit if not
	movem.w	d0-d2,-(sp)
	move.w	ldrworgx,d0
	move.w	ldrworgy,d1
	move.w	d3,d2			;29-Aug
	move.w	d4,d3			;29-Aug
	move.l	curscren,a5
	bsr	lineundo		;29-Aug
*
	movem.w	(sp)+,d0-d2
*
	movem.w	d0-d2,-(sp)		;29-Aug
	bsr	strain8
	move.w	d0,d2			;29-Aug
	move.w	d1,d3			;29-Aug
*
	move.w	ldrworgx,d0		;29-Aug
	move.w	ldrworgy,d1		;29-Aug
	bsr	linedraw		;29-Aug
	bsr	screnswp		;8-Jul
	movem.w	(sp)+,d0-d2		;29-Aug
*
ldraq:
	rts
*
*
*
*
* ------ Fill Bucket ------------------------
*
*
filli:
	rts
filld:
	rts
filxlate:
	.dc.b	0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1
*
setarcat:
	movem.l	a0/d2,-(sp)	
	move.w	#17,d2			;polyline color
	bra.s	setx1
setxlate:
	movem.l	a0/d2,-(sp)
	move.w	#25,d2			;fill color
setx1:
	movea.l	#contrl,a0
	move.w	d2,(a0)+
	clr.l	(a0)+
	move.w	#1,(a0)
	move.w	selctcol,d2		;get desired color
	move.b	filxlate(pc,d2.w),d2
	ext.w	d2
	move.w	d2,intin
	bsr	vdicall
	movem.l	(sp)+,a0/d2
	rts
*
fillupd:
	btst.l	#2,d2			;left button trigger?
	beq.s	fillq
*
	clr.b	touch	
	bsr	unundo			;save previous work
*
	bsr	getpix			;get color under cursor
	move.w	selctcol,d2		;get desired color
	cmp.w	d3,d2
	beq.s	fillq			;skip if same color
	bsr	setxlate
*
	bsr	setclip
*
*
	movea.l	#contrl,a0
	move.w	#103,(a0)+		;contour fill
	move.w	#1,(a0)+
	addq.l	#2,a0
	move.w	#1,(a0)+
	move.w	#-1,intin
	move.w	d0,ptsin+0
	move.w	d1,ptsin+2
	bsr	vdicall
*
	bsr	killclip
*
	clr.b	undoyet
fillq:
	rts
*
*
*
*
*
*
*
relthik:
	moveq	#0,d4
	move.w	lindthik,d4		;get line draw thickness
	bra.s	non0thik		;br to make variable brush
*
*	
*------- Shapes -----------------------------
*
*
shapei:
	move.w	#-1,shaporgx
rethik:
*2	lea	contrl,a0
*	move.w	#16,(a0)+		;set line thickness
*	move.w	#1,(a0)+
*	clr.l	(a0)
*	lea	ptsin,a0
*	move.w	linethik,(a0)+
*	clr.w	(a0)
*	bsr	vdicall
*
*  do pre-shift for midpoint method too
*
	moveq	#0,d4
	move.w	linethik,d4		;get thickness
	bne.s	non0thik		;br if non-zero
	cmpi.w	#3,shapesel
	bcc.s	need1
	tst.w	hollow			;is hollow in effect?
	bne.s	non0thik		;br if not
need1:
	moveq	#1,d4			;else, use effective 1 thick
non0thik:
	moveq	#0,d5
*	movea.l	physadd,a0
*
	lea	shapebuf,a0
	lea	514(a0),a2
	move.l	a2,brshptr		;save for brush brez
	move.w	d4,(a2)+		;width
	move.w	d4,(a2)+		;same for height
*
	move.w	d4,(a0)+
	lsl.w	#4,d4
	lea	brshtab(pc,d4.w),a1
	moveq	#7,d6
thiklp0:
	moveq	#0,d5
	move.w	(a1)+,d5
	move.w	d5,(a2)+		;save for brush brez
	movea.l	a0,a3
	move.w	#15,d4
thiklp1:
	add.l	d5,d5
	move.l	d5,(a0)
	adda.w	#32,a0
	dbra	d4,thiklp1	
*
	movea.l	a3,a0
	addq.l	#4,a0
	dbra	d6,thiklp0
*
	rts
*
brshtab:
	.dc.w	0,0,0,0,0,0,0,0
*
	.dc.w	%1000000000000000
	.dc.w	0,0,0,0,0,0,0
*
	.dc.w	%1100000000000000
	.dc.w	%1100000000000000
	.dc.w	0,0,0,0,0,0
*
	.dc.w	%0100000000000000
	.dc.w	%1110000000000000
	.dc.w	%0100000000000000
	.dc.w	0,0,0,0,0
*
	.dc.w	%0110000000000000
	.dc.w	%1111000000000000
	.dc.w	%1111000000000000
	.dc.w	%0110000000000000
	.dc.w	0,0,0,0
*
	.dc.w	%0111000000000000
	.dc.w	%1111100000000000
	.dc.w	%1111100000000000
	.dc.w	%1111100000000000
	.dc.w	%0111000000000000
	.dc.w	0,0,0
*
	.dc.w	%0011000000000000
	.dc.w	%0111100000000000
	.dc.w	%1111110000000000
	.dc.w	%1111110000000000
	.dc.w	%0111100000000000
	.dc.w	%0011000000000000
	.dc.w	0,0
*
	.dc.w	%0011100000000000
	.dc.w	%0111110000000000
	.dc.w	%1111111000000000
	.dc.w	%1111111000000000
	.dc.w	%1111111000000000
	.dc.w	%0111110000000000
	.dc.w	%0011100000000000
	.dc.w	0
*
	.dc.w	%0011110000000000
	.dc.w	%0111111000000000
	.dc.w	%1111111100000000
	.dc.w	%1111111100000000
	.dc.w	%1111111100000000
	.dc.w	%1111111100000000
	.dc.w	%0111111000000000
	.dc.w	%0011110000000000
*
*	
shaped:
	rts
*
*
shapupd:
	move.w	shapesel,d5
	subq.w	#3,d5
	beq	polypnt			;go process poly point
	bpl	polyline		;go process poly line
*
*  must be rectangle, rounded rectangle, or ellipse
*
	move.w	d2,d5
	andi.w	#$c,d5			;l/r leading edge?
	beq.s	shap1			;br if not
*	
*  left leading trigger
*
	bsr	straini
	clr.b	touch			;touched this picture
	clr.b	undoyet
	bsr	unundo			;save previous work
	movea.l	curscren,a0
	movea.l	othscren,a1
	move.w	#1999,d7
toothscn:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d7,toothscn
*
	move.w	d0,shaporgx		;set origin
	move.w	d1,shaporgy
*	bsr	setarcat
	move.w	d1,soldy
	move.w	d1,snewy
	clr.w	soldht
	clr.w	snewht
	move.w	d0,d3
	move.w	d1,d4
	move.w	d0,d5
	move.w	d1,d6
	bra	shap6
*
*  No leading edge found, check trailing
*
shap1:
	tst.w	shaporgx		;origin set?
	bmi	shapq			;exit if not
*
	move.w	d2,d7
	andi.w	#$30,d7			;l/r trailing edge?
	beq.s	shap2			;br if not
*
	clr.b	constran
	clr.b	undoyet
	move.w	#-1,shaporgx
	rts
shap2:
	move.w	d2,d7
	andi.w	#3,d7			;l/r button still down?
	beq	shapq			;br if not
*
*  draw an ellipse
*
	bsr	straindg		;constrain on diagonals if in effect
shap5:
	move.w	d0,d3
	move.w	d1,d4
	move.w	shaporgx,d5
	move.w	shaporgy,d6
	cmp.w	d3,d5
	bcc.s	shap3
	exg	d3,d5
shap3:
	cmp.w	d4,d6
	bcc.s	shap4
	exg	d4,d6
shap4:
shap7z:
*	cmp.w	d3,d5
*	bne.s	shap7
*	cmp.w	d4,d6
*	beq.s	shapq			;quit if no move
shap7:
*
	movea.l	othscren,a0
	movea.l	screen0,a1
	move.w	soldy,d7
	mulu	#160,d7
	adda.w	d7,a0
	adda.w	d7,a1
	tst.w	full
	bne.s	nfl
	move.w	handy,d7
	mulu	#160,d7
	adda.w	d7,a1
nfl:
	move.w	lastfrm,d7
frmwt1:
	cmp.w	frmcnt,d7
	beq.s	frmwt1
*
	move.w	soldht,d7
	addq.w	#1,d7
	lsl.w	#3,d7
	bra.s	nfli
nfl1:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
nfli:
	dbra	d7,nfl1
*
	move.w	d6,d7
	sub.w	d4,d7
	move.w	snewht,soldht
	move.w	snewy,soldy
	move.w	d7,snewht
	move.w	d4,snewy
*
shap6:
	move.w	d3,d0		;d0 = top/left x
	move.w	d4,d1		;d1 = top/left y
	move.w	d5,d2		;d2 = bot/rite x
	move.w	d6,d3		;d3 = bot/rite y
	move.w	shapesel,d4
	add.w	d4,d4
	add.w	d4,d4
	pea	return(pc)
	move.l	shapjmp(pc,d4.w),-(sp)
	rts
return:
	bsr	screnswp
	move.w	frmcnt,lastfrm
shapq:
	rts
*
shapjmp:
	.dc.l	rect			;rectangle
	.dc.l	rndrect			;rounded rectangle
	.dc.l	ellipse			;ellipse
*	.dc.l	polypnt			;poly point
*	.dc.l	polyline		;poly line
*
*
*  Eraser function------------------------------------------
*
erasi:
	btst.l	#6,d2		;left double click?
	bne	halferas	;br if so
	btst.l	#7,d2		;right double-click?
	beq	erasiq		;br if not
*
*  right double click on eraser is total picture erase
*
	tst.b	touch		;any work to be thrown away?
	bne.s	erasix		;br if wasn't touched
*
	bsr	gemready
	bsr	rezset
*
	move.l	#erasalrt,d0	;"erase all without UNDO"?
	bsr	alertout
	bsr	rezclr
	move.w	#-1,henabl
	move.w	#$2500,irqlev
*
	cmpi.w	#1,int_out
	bne	erasid
*
erasix:
	clr.w	handy		;reset hand ypos
	move.b	#-1,touch	;tell 'em untouched
	movem.l	a0/d0-d1,-(sp)
	move.l	screen0,a0
	moveq	#0,d0
	move.w	#1999,d1
erasixlp:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,erasixlp	
	tst.b	vircan		;virtual canvas?
	beq.s	erasixx		;br if not
	movea.l	vcanbase,a0
	move.l	#vcansize,d1
	lsr.l	#3,d1
	bra.s	erasiii
erasiilp:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
erasiii:
	dbra	d1,erasiilp
	clr.w	virhandy
	clr.w	virhandx
	bra.s	erasixx
*
*  clear entire visible screen
*
halferas:
	clr.b	touch
	clr.b	undoyet
	bsr	unundo		;save previous work
	movem.l	a0/d0-d1,-(sp)
erasixx:
	movea.l	curscren,a0
	moveq	#0,d0
	move.w	#999,d1
erasilp:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,erasilp
*
	movem.l	(sp)+,a0/d0-d1
erasid:
	adda.w	#10,sp
	move.w	lastx,d3
	move.w	lasty,d4
	bra	refunc
erasiq:
	rts
erasd:
	rts
erasupd:
	move.w	selctcol,-(sp)
	clr.w	selctcol
	move.w	d2,d7			;make all right buttons into left ones
	lsr.w	#1,d7
	or.w	d7,d2
	andi.w	#%1111111101010101,d2	;kill all right buttons
	bsr.s	brshupd
	move.w	(sp)+,selctcol
	rts
*
*
*
*  Brush function-------------------------------------------
*
brshi:
	rts
brshd:
	rts
*
*
brshupd:
	move.w	d2,d7			;copy buttons to temp
	andi.w	#$3c,d7			;any edges?
	beq.s	brsh2			;br if no edges
	andi.w	#$30,d7			;trailing edges?
	beq.s	brsh1			;br if not trailing edges
*
	clr.b	constran
	clr.b	undoyet
	bra.s	brsh2
brsh1:
*
	move.w	colrite,spraycol
	bsr	straini			;check for constrain
	clr.b	touch
	bsr	unundo			;if 1st alter, copy to main
brsh2:
	btst.l	#0,d2			;left button down?
	bne.s	brsh3			;br to write if so
	btst.l	#1,d2			;right button down
	beq.s	brshq
brsh3:
	movem.w	d0-d1,-(sp)
	cmpi.b	#12,likesel		;in shapes?
	bne.s	brsh4			;br if not
	bsr	strain8
	bsr	brshbrez
	addq.l	#4,sp
	rts
brsh4:
	bsr	strain			;perform constrain if set
brsh5:
	btst.l	#1,d2
	beq.s	brsh5x
	move.w	selctcol,-(sp)
	move.w	spraycol,d7
	addq.w	#1,d7
	cmp.w	colrite,d7
	ble.s	brsh5xx
	move.w	colleft,d7
brsh5xx:
	move.w	d7,spraycol
	move.w	d7,selctcol
	bsr	brshbrez
	move.w	(sp)+,selctcol
	bra.s	brsh6
brsh5x:
	bsr	brshbrez		;draw line from x
brsh6:
	movem.w	(sp)+,d0-d1
brshq:
	rts
*
*
*
*  Spray can function-------------------------------------------
*
sprayi:
	rts
sprayd:
	rts
sprayupd:
	move.w	d2,d7			;copy buttons to temp
	andi.w	#$3c,d7			;any edges?
	beq.s	spray2			;br if no edges
	andi.w	#$30,d7			;trailing edges?
	beq.s	spray1			;br if not trailing edges
*
*
	clr.b	constran		;exit constrain mode if in effect
	clr.b	undoyet
	bra	sprayq
spray1:
*
	bsr	straini			;check for constrain
	clr.b	touch
	bsr	unundo			;if 1st alter, copy to main
	move.w	colrite,spraycol
	bra.s	spray4
spray2:
	andi.w	#3,d2
*	move.w	#3,d6
*	btst.l	#0,d2			;left button down?
*	bne.s	spray3			;br if so to use 5
*	move.w	#8,d6
*	btst.l	#1,d2			;right button down?
	beq.s	sprayq			;br to exit if not
spray3:
	move.w	frmcnt,d5
	sub.w	sprayfrm,d5
*	cmp.w	d6,d5
	cmpi.w	#3,d5
	bcs.s	sprayq
spray4:
	move.w	frmcnt,sprayfrm
	move.w	d0,d3
	move.w	d1,d4
*
*  new code..
	move.w	selctcol,-(sp)
	btst.l	#1,d2			;right button
	beq.s	spray4x
	move.w	spraycol,d7
	addq.w	#1,d7
	cmp.w	colrite,d7
	ble.s	spray4xx
	move.w	colleft,d7
spray4xx:
	move.w	d7,spraycol
	move.w	d7,selctcol
spray4x:
*  end new code
*
	movem.w	d0-d1,-(sp)
	bsr	strain
	bsr	brshbrez		;splat one copy of nozzle
	movem.w	(sp)+,d0-d1
	move.w	(sp)+,selctcol
sprayq:
	rts
*
*
*
*  generalized Line draw routine
*
*  d0 - x1
*  d1 - y1
*  d2 - color #
*  d3 - x2
*  d4 - y2
*  d5 - writing mode
*
linedrw:
	movem.l	d0-d7/a0,-(sp)
	movem.w	d0-d4,-(sp)
	.dc.w	$a000			;get base ptr
	movem.w	(sp)+,d0-d4
	move.w	d0,x1(a0)
	move.w	d1,y1(a0)
	move.w	d3,x2(a0)
	move.w	d4,y2(a0)
	move.w	#-1,ln_mask(a0)
	move.w	d5,wrt_mode(a0)
	move.w	#3,d4
coload2:
	moveq	#0,d3
	lsr.w	#1,d2
	bcc.s	coload3
	moveq	#1,d3
coload3:
	move.w	d3,fg_bp_1(a0)
	addq.l	#2,a0
	dbra	d4,coload2
	.dc.w	line
	movem.l	(sp)+,d0-d7/a0
	rts
*
*  Hand function-------------------------------------------
*
*   perform right-hand color pick-up
*
rhandsel:
	btst.l	#3,d2		;leading on right button?
	beq.s	hand1
	tst.w	full
	bne.s	hand1		;no color pick-up in full screen
*
	move.w	d3,-(sp)
	bsr	getpix
	bsr	uncolor
	move.w	d3,selctcol
	bsr	pointcol
	bsr	othsame
	move.w	(sp)+,d3
hand1:
	rts
*
*
handi:
*
*  ***new code for virtual canvas
*
	tst.b	vircan
	beq.s	handix
	bsr	unundo
handii:
	movea.l	#scr2vir,a6
	movea.l	#vir2scr,a1
	move.l	vcanbase,d0
	move.l	d0,d_form(a6)
	move.l	d0,s_form(a1)
	move.l	screen0,s_form(a6)
	move.w	virhandx,d_xmin(a6)
	move.w	virhandy,d_ymin(a6)
	move.w	#200,b_height(a6)
	move.w	#4,plane_ct(a6)
	.dc.w	bitblt			;screen0 -> vircanvas
*
	bsr	othsame		;get ready to double buffer
handix:
*
*  ***end new code
*
	rts
handd:
	tst.b	vircan
	beq.s	handdx
	tst.w	virhandy
	bne.s	dovtch
	tst.w	virhandx
	beq.s	handdd
dovtch:
	clr.b	virtouch
handdd:
	movea.l	#vir2scr,a6
	move.l	vcanbase,s_form(a6)
	move.l	screen0,d_form(a6)
	move.w	virhandx,s_xmin(a6)
	move.w	virhandy,s_ymin(a6)
	move.w	#200,b_height(a6)
	move.w	#4,plane_ct(a6)
	.dc.w	bitblt			;vircanvas -> screen0
handdx:
	rts
*
*  added for v0.9h
shhandx:
	clr.b	constran
	rts
*  end addition
*
*
*  update hand
*
handupd:
	andi.w	#$f,d2		;left or right down or leading?
	beq.s	shhandx		;exit if not--nothin doin here
*
*  ***new code for virtual canvas
*
	tst.b	vircan		;virtual canvas?
	beq	normhand	;br if not
	bsr	rhandsel	;do right hand color pick-up
*
	moveq	#$C,d7		;left or right leading edge?
	and.w	d2,d7	
	beq.s	nothhand	;br if not
*
*  added for v0.9h
	bsr	straini
*  end addition
*
	tst.w	full
	bne.s	nothhnd
	bsr	othsame
nothhnd:
	rts
nothhand:
	movem.w	d0-d1,-(sp)
	bsr	strain
	move.w	d0,d5
	sub.w	d3,d5		;find delta x
	move.w	d1,d6
	movem.w	(sp)+,d0-d1
	sub.w	d4,d6		;find delta y
	bne.s	handmov
	tst.w	d5
	beq	shhand		;exit if no movement
handmov:
	movea.l	#vir2scr,a6
	move.l	othscren,d_form(a6)
	move.w	half,b_height(a6)
*	
	move.w	virhandx,d7	;get current x pos
	sub.w	d5,d7		;find proposed new virhandx
	bpl.s	handxok
	moveq	#0,d7
handxok:
	move.w	#vpixwd-320,d2
	cmp.w	d2,d7		;proposed virhandx larger than possible?
	ble.s	handxok1	;br if ok
	move.w	d2,d7
handxok1:
	move.w	d7,virhandx
	move.w	d7,s_xmin(a6)
*
*  now for ypos
*
	move.w	virhandy,d7	;d7=virhandy
	move.w	handy,d2	;d2=handy
	tst.w	full
	bne.s	hndyok1		;br to full screen ypos
*
*  on half screen..
*
	sub.w	d6,d2		;adjust handy 1st
	bpl.s	hndyok2		;br to handy max check
	clr.w	handy		;use minimum handy
	add.w	d2,d7		;else, less than handy--adjust virhandy
	bpl.s	handyok1	;ok--br to set virhandy
	moveq	#0,d7
	bra.s	handyok1
*
*  max check
*
hndyok2:
	moveq	#100,d6
	cmp.w	d6,d2
	ble.s	hndyok4
	move.w	d6,handy	;put max in handy
	sub.w	d6,d2		;find overage
	add.w	d2,d7		;add to virhandy
	bra.s	handyok
hndyok4:
	move.w	d2,handy
	bra.s	handyok1
*
*  full screen stuff
*
hndyok1:
	sub.w	d6,d7		;find proposed new virhandy
	bpl.s	handyok
	moveq	#0,d7
handyok:
	move.w	#vpixht-200,d2
	cmp.w	d2,d7		;proposed virhandy larger than possible?
	ble.s	handyok1	;br if ok
	move.w	d2,d7
handyok1:
	move.w	d7,virhandy
	tst.w	full
	bne.s	handyok6
	add.w	handy,d7
handyok6:
	move.w	d7,s_ymin(a6)
*
	move.w	#4,plane_ct(a6)
*
	move.w	lastfrm,d7
handwt:
	cmp.w	frmcnt,d7
	beq.s	handwt
*
	.dc.w	bitblt
	bsr	screnswp
	move.w	frmcnt,lastfrm
	rts
*
*  ***end new code
normhand:
	tst.w	full		;in full mode?
	bne.s	shhand		;exit if so-- hand inoperative in full mode
	bsr	rhandsel
*
*
	move.w	d1,d5		;copy new y position
	sub.w	d4,d5		;subtract old from new ypos
	beq.s	shhand		;exit if no change
	move.w	handy,d4
	sub.w	d5,d4
	bpl.s	handyoky
	moveq	#0,d4
handyoky:
	cmpi.w	#101,d4
	bcs.s	handok1
	move.w	#100,d4
handok1:
	bsr	unundo		;check for undo stuff
	move.w	d4,handy
	movea.l	screen0,a0	;get main screen ptr
	movea.l	curscren,a1
	mulu	#160,d4
	adda.w	d4,a0
	move.w	#999,d3
handlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d3,handlp
shhand:
	rts
*
*
*   Text functions -----------------------------------------
*
*      text initialize..
*
texti:
	move.w	#-1,texbasx
	rts
*
*
*      text de-initialize..
*
textd:
	tst.w	texbasx
	bmi.s	textd1
	bsr	offcurtx		;erase old cursor
	move.w	#-1,texbasx
textd1:
	rts
*
*
*
*	Update text...
*
textupd:
	btst	#2,d2			;left button leading trigger?
	beq.s	text2			;br if not setting new text cursor
*
*  set new text cursor
*
	tst.w	texbasx			;previous cursor set?
	bmi.s	text1			;br if not
	bsr	offcurtx			;else, erase old cursor
text1:
	clr.b	touch
	bsr	unundo			;save previous work, starting new
	movea.l	curscren,a0		;make oth screen the same
	movea.l	othscren,a1
	move.w	#1999,d5
textlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d5,textlp	
*
	move.w	d0,texbasx		;save text base position
	move.w	d0,textx
	move.w	d1,d4
	sub.w	txtbastp,d4
	bpl.s	text15
	moveq	#0,d4
text15:
	move.w	d4,texbasy
	move.l	#txstring,txtptr	;restore text string ptr
*
	move.w	d4,texty
	bsr	oncurtx			;write new cursor
*
*  entry point if no mouse clicks..
*
text2:	
	movem.w	d0-d2,-(sp)		;save matrix update regs
	move.w	textx,d0
	move.w	texty,d1
	move.l	conchar,d5		;check console character
	beq	text4			;br if no action here
	swap	d5			;check for undo
	cmpi.b	#$61,d5			;undo?
	beq	text4			;if so, br to skip clearing this one
	cmpi.b	#1,d5			;esc?
	beq	text4			;if so, br to skip clearing
*
	swap	d5
	tst.w	d5			;is this null char?
	beq	text3			;br if no action here
*
	tst.w	texbasx			;has text cursor been placed?
	bmi	text3			;br if not--ignore keyboard input
	bsr	offcurtx		;hide text cursor
*
	movea.l	txtptr,a0		;get current text ptr
	cmpi.b	#8,d5			;back space char?
	bne.s	text5			;br if not
*
*  Back space code here..
*
	cmpi.b	#13,-(a0)		;back up ptr, check for cr
	bne.s	text12			;br if no carriage return
*
*  backing up over carriage return..
*
	bsr	othband			;copy text band (line) to oth screen
*
	move.w	txtcelht,d5
	sub.w	d5,texty
	bra.s	text9a
text12:
	cmpa.l	#txstring,a0		;backed up too far?
	bcs	text6			;br if so--put text cursor back
	bne.s	text9a
	move.l	a0,txtptr
	move.w	texbasx,d2
	bsr	newband		;put background on text line on othscren
	bra	text11
text5:
	move.b	d5,(a0)+
*
	cmpi.b	#13,d5
	bne.s	text9
*
*  check for carriage return here..
*
*
	bsr	othband
*
	move.w	texbasx,textx
	move.w	txtcelht,d5
	add.w	d5,texty
	bra.s	text9a
text9:
	move.b	textadj,d6
	or.b	d6,-1(a0)
text9a:
	move.l	a0,txtptr
	clr.b	(a0)		;put terminator in string
*
*  back up to beginning of this line
*
text7:
	cmpi.b	#13,-(a0)
	beq.s	text8
	cmpa.l	#txstring,a0
	bcc.s	text7
text8:
	addq.l	#1,a0
*
	bsr	newband		;put background on text line on othscren
	move.l	a0,-(sp)
*
	move.w	#-1,-(sp)	;set logical screen to othscren
	move.l	#-1,-(sp)
	move.l	othscren,-(sp)
	move.w	#5,-(sp)	;set new logical screen
	trap	#14
	adda.w	#12,sp
*
	move.l	(sp)+,a0
*
	bsr	setclip		;set clip window (in case underline)
*
*  do align stuff here
*
	move.w	texbasx,d0
	move.w	texty,d1
	bsr	graftxt
*
*	d0 has final xpos
*
	move.w	d0,d2
text11:
	bsr	killclip
	move.w	d2,textx
	bsr	screnswp
*
*  exit point used by newtxtmd..
*
text6:
*
*  some code to fix skewed cursor bug
*
	btst.b	#2,textstyl+1		;skewed text?
	beq.s	nocurect		;br if not--needn't adjust cursor
	movea.l	txtptr,a0
	cmpa.l	#txstring,a0		;text pointer at beginning of buffer?
	beq.s	nocurect		;br if so--don't correct cursor pos
	cmpi.b	#13,-1(a0)		;previous character a carriage return?
	beq.s	nocurect		;br if so--on beginning of line
*
*  correct cursor positioning for skew overhang so cursor doesn't cut 
*  into the previous character
*
	move.w	scaleft,d0
	add.w	scalrite,d0
	add.w	d0,textx
nocurect:
	bsr	oncurtx
text19:
	clr.b	undoyet
	move.b	#$80,matxupd		;force matrix update
text3:
	clr.l	conchar
text4:
	movem.w	(sp)+,d0-d2
	rts
*
*
*  Redo all current text in new mode..
*
newtxtmd:
	movem.w	d0-d2,-(sp)
	tst.w	texbasx			;no text on screen?
	bmi	ntmdq			;br if not--skip this jive
*
*  erase full amount of old text
*
	movea.l	screen0,a0		
	movea.l	othscren,a1
	move.w	#1999,d0
	tst.w	full
	bne.s	ntmdx
	move.w	handy,d1
	mulu	#160,d1
	adda.w	d1,a0
	move.w	#999,d0
ntmdx:
ntmdlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,ntmdlp
*
	move.w	#-1,-(sp)	;set logical screen to othscren
	move.l	#-1,-(sp)
	move.l	othscren,-(sp)
	move.w	#5,-(sp)	;set new logical screen
	trap	#14
	adda.w	#12,sp
*
	bsr	setclip
*
	move.w	texbasy,texty
	movea.l	txtptr,a2
	movea.l	#txstring,a0
ntmdlp2:
	move.l	a0,a1
ntmdlp1:
	cmpa.l	a1,a2
	beq.s	ntmdlpq
	cmpi.b	#13,(a1)+
	bne.s	ntmdlp1
	clr.b	-(a1)
	move.w	texbasx,d0
	move.w	texty,d1
	move.l	a2,-(sp)
*
	bsr	graftxt
*
	move.l	(sp)+,a2
	move.b	#13,-1(a0)
	move.w	txtcelht,d0
	add.w	d0,texty
	bra.s	ntmdlp2
ntmdlpq:
	cmpi.b	#13,(a1)
	bne.s	ntmd3
	move.w	txtcelht,d0
	add.w	d0,texty
	move.w	texbasx,textx
	bra.s	ntmd4
ntmd3:
	clr.b	(a1)
	move.w	texbasx,d0
	move.w	texty,d1
	bsr	graftxt
	move.w	d0,textx
ntmd4:
	bsr	screnswp
*
	bsr	killclip
*
	movea.l	curscren,a0		
	movea.l	othscren,a1
	move.w	#1999,d0
	tst.w	full
	bne.s	ntmdlpx
	move.w	#999,d0
ntmdlpx:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,ntmdlpx
*
	bra	text6
ntmdq:
	movem.w	(sp)+,d0-d2
	rts
*
*
*
*
**************************************************
*
*   Load a new picture file
*
*  get new file
*
*
getnewfl:
	bsr	gemready		;disable h-blank, flush buttons
*
	move.w	#123,contrl+0		;hide cursor
	bsr	vdicall
*
	bsr	rezset
*
	move.w	#0,int_in+0
	bsr	graf_mou		;change mouse to arrow
*
	move.w	#122,contrl+0		;show cursor
	clr.w	contrl+2
	clr.w	intin
	move.w	#1,contrl+6
	bsr	vdicall
*
	bset.b	#0,pathgot
	bne.s	gotpath
*
	move.w	#$19,-(sp)		;get default drive
	trap	#1
	addq.l	#2,sp
*
	movea.l	#fs_inpat,a0
	move.b	d0,(a0)
	addi.b	#"A",(a0)+
	move.b	#":",(a0)+
*
	addq.b	#1,d0
	ext.w	d0
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$47,-(sp)		;get current directory
	trap	#1
	addq.l	#2,sp
	move.l	(sp)+,a0
	addq.l	#2,sp
*
getnull:
	tst.b	(a0)+
	bne.s	getnull
*
	move.b	#"\\",-(a0)
	addq.l	#1,a0
	move.b	#"*",(a0)+
	move.b	#".",(a0)+
	move.b	#"N",(a0)+
	move.b	#"E",(a0)+
	move.b	#"O",(a0)+
	move.b	#0,(a0)
*
gotpath:
	clr.w	int_out+0
	clr.w	int_out+2
	move.l	#fs_inpat,addr_in
	move.l	#fs_insel,addr_in+4
	bsr	fsel_inp
*
	move.w	#123,contrl+0		;hide cursor
	bsr	vdicall
*
	move.w	int_out+2,d0	;check exit type
	cmpi.b	#1,d0		;"ok" on select?
	bne	docancl
*
*  reading in new file
*
	tst.b	touch
	bne.s	doread
*
*  ask user if he wants to flush modified picture..
*
	bsr	rezset
*
	move.l	#abndalrt,d0
	bsr	alertout
	move.w	int_out,d1
	cmpi.w	#1,d1
	beq	rexboxld
*
doread:
	clr.w	handy
	move.w	#-1,nofile	;set for re-enter new file
*
	move.w	#1999,d0	;put up only previous picture
	movea.l	screen0,a0
	movea.l	curscren,a1
scr0clr:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,scr0clr
*
	bsr	rezclr
*
	movea.l	#fs_inpat,a0
	movea.l	#txstring,a1
patlp1:
	move.b	(a0),(a1)+
	tst.b	(a0)+
	bne.s	patlp1
*
patlp2:
	cmpi.b	#"\\",-(a1)
	bne.s	patlp2
*
	addq.l	#1,a1
	movea.l	#fs_insel,a0
	movea.l	#path,a2
patloop:
	move.b	(a0),(a2)+
	move.b	(a0)+,(a1)+
	bne.s	patloop
*
	move.w	#0,-(sp)		;open for read
	move.l	#txstring,-(sp)		;use this for total pathname
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
*
	bra	refile
*
docancl:
	move.w	#123,contrl+0		;hide cursor
	bsr	vdicall
*
	bsr	rezclr
*
	move.w	#-1,henabl
	move.w	#$2500,irqlev
*
	movea.l	#inits,a0
	move.b	likesel,d7
	lsl.w	#2,d7
	ext.w	d7
	move.l	(a0,d7.w),a0
	jsr	(a0)		;re-init function that was interrupted
*
	bsr	mouseget
	move.b	#$80,matxupd
	bra	matupd
*
*
*
*
screnswp:
	move.l	othscren,a0
	move.l	curscren,othscren
	move.l	a0,curscren
*
	move.w	#-1,-(sp)	;skip rez
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)	;set new screen base addr
	trap	#14
	adda.w	#12,sp
	rts
*
*
*	.ifne	0
*
*  test routine to allow debugger to view any of
*  6 screens:  screen0,physadd,curscren,othscren,cutscren,cpyscren
*
*
scrnz:
	.dc.l	screen0
	.dc.l	physadd
	.dc.l	curscren
	.dc.l	othscren
	.dc.l	cutscren
	.dc.l	cpyscren
*
*
view:
	movem.l	d0-d7/a0-a6,-(sp)
*
	move.w	#2,-(sp)
	trap	#14		;get current physical screen
	addq.l	#2,sp
*
	move.l	d0,-(sp)	;save current base addr
view1:
	bsr	conin
	tst.w	d0
	beq.s	view2
	cmpi.b	#" ",d0
	beq.s	viewx
	cmpi.b	#$1b,d0
	bne.s	view1
	addq.l	#4,sp
	bra.s	viewq
view2:
	swap	d0
	subi.w	#func1,d0
	bcs.s	view1
	cmpi.w	#6,d0
	beq	dovmsk
	bcc.s	view1
*
	lsl.w	#2,d0
	movea.l	scrnz(pc,d0.w),a0
	move.l	(a0),a0
	cmpi.w	#16,d0		;f5 or f6 (cut/cpy)?
	bcc.s	dovspec		;br if so (must perform transform)
setview:
	move.w	#-1,-(sp)
	move.l	a0,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
	bra.s	view1
*
viewx:
	move.l	(sp)+,d0
*
	move.w	#-1,-(sp)
	move.l	d0,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
viewq:
	move.l	screenx,d0
	beq.s	viewqq
	move.l	d0,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp			;free memory if available
viewqq:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*
screenx:
	.dc.l	0
dovspec:
	move.w	cut_nxln,d1
	cmpi.w	#16,d0			;cut screen?
	beq.s	dovspec2
	move.w	cpy_nxln,d1
dovspec2:
	move.l	screenx,d0
	bne.s	dovspec1
*
	movem.l	a0/d1,-(sp)		;save source screen/nxln
*
	move.l	#32256,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp			;get memory if available
*
	movem.l	(sp)+,a0/d1
	tst.l	d0
	beq	view1			;br if not enough memory avail
*
	move.l	d0,screenx
dovspec1:
	addi.l	#255,d0
	clr.b	d0
	move.l	d0,a1
	move.w	#1999,d2
	moveq	#0,d3
dovspec3:
	move.l	d3,(a1)+
	move.l	d3,(a1)+
	move.l	d3,(a1)+
	move.l	d3,(a1)+
	dbra	d2,dovspec3
*
	move.l	d0,a1
	move.w	#199,d2
dovspec5:
	move.w	d1,d3
	move.l	a1,a2
dovspec4:
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	subq.w	#8,d3
	bgt.s	dovspec4
	adda.w	#160,a1
	dbra	d2,dovspec5
*
	move.l	d0,a0
	bra	setview
*
*
*
dovmsk:
	move.l	screenx,d0
	bne.s	dovmsk1
	move.l	#32256,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp			;get memory if available
*
	tst.l	d0
	beq	view1			;br if not enough memory avail
*
	move.l	d0,screenx
dovmsk1:
	addi.l	#255,d0
	clr.b	d0
	move.l	d0,a0
	move.l	#blitmask,a1
*
	move.w	cpy_nxln,d2
	lsr.w	#2,d2
	move.w	d2,d3
	lsr.w	#1,d3
	move.w	#199,d5
viewmsk0:
	move.l	a0,a2
	move.l	a1,a3
	move.w	d3,d4
	bra.s	viewmski
viewmsk:
	move.w	(a3),(a2)+
	move.w	(a3),(a2)+
	move.w	(a3),(a2)+
	move.w	(a3)+,(a2)+
viewmski:
	dbra	d4,viewmsk
*
	adda.w	#160,a0
	adda.w	d2,a1
	dbra	d5,viewmsk0
*
	move.l	d0,a0
	bra	setview
*
*	.endc
*
*  initialized data
*
	.data
*
handy:
	.dc.w	0	;grabber hand y offset for half screen scroll
virhandx:
	.dc.w	0	;virtual canvas hand x offset
virhandy:
	.dc.w	0	;virtual canvas hand y offset
*
*
*  ant pattern bit blt block
*
a_block:
	.dc.w	0		;width of block
	.dc.w	0		;height of block
	.dc.w	4		;planes
	.dc.w	0		;fore col
	.dc.w	0		;back col
	.dc.l	$03030303	;all 1's	
	.dc.w	0
	.dc.w	0
	.dc.l	allffs		;source form address (dummy)
	.dc.w	0
	.dc.w	0
	.dc.w	0
*
	.dc.w	0		;dest min x
	.dc.w	0		;dest min y
	.dc.l	0		;dest form base addr
	.dc.w	8
	.dc.w	160
	.dc.w	2
*
	.dc.l	antpatrn
	.dc.w	2
	.dc.w	0
	.dc.w	$E
	.dc.w	0,0,0,0,0,0,0,0,0,0,0,0
*
antptr:
	.dc.l	antpatrn
*
allffs:
	.dc.w	$ffff
antpatrn:
	.dc.w	%1111000111110001
	.dc.w	%1110001111100011
	.dc.w	%1100011111000111
	.dc.w	%1000111110001111
	.dc.w	%0001111100011111
	.dc.w	%0011111000111110
	.dc.w	%0111110001111100	
	.dc.w	%1111100011111000	
*
	.dc.w	%1111000111110001
	.dc.w	%1110001111100011
	.dc.w	%1100011111000111
	.dc.w	%1000111110001111
	.dc.w	%0001111100011111
	.dc.w	%0011111000111110
	.dc.w	%0111110001111100	
	.dc.w	%1111100011111000	
*
*  mono-mask to mono trace edge buffer bitblt block
*
m2m_blk:
	.dc.w	0,0,1,0,0	;wd,ht,plane_ct,fg,bg
	.dc.l	$03030303	;op (replace)
	.dc.w	0,0		;s_xmin,s_ymin
	.dc.l	blitmask	;src form
	.dc.w	2,40,0
*
	.dc.w	0,2		;d_xmin,d_ymin
	.dc.l	0		;dst form (from othscren)
	.dc.w	2,40,0
	.dc.l	0
*	.ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
*
*  ***new code for virtual canvas
*
scr2vir:
	.dc.w	320,0,4,0,0	;wd,ht,plane_ct,fg,bg
	.dc.l	$03030303	;op (replace)
	.dc.w	0,0		;s_xmin,s_ymin
	.dc.l	0		;src form (othscren goes in here)
	.dc.w	8,160,2
*
	.dc.w	0,0		;d_xmin,d_ymin
	.dc.l	0		;dst form (virtual canvas)
	.dc.w	8,vformwd,2
	.dc.l	0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
*	.ds.b	30
*
*
vir2scr:
	.dc.w	320,0,4,0,0	;wd,ht,plane_ct,fg,bg
	.dc.l	$03030303	;op (replace)
	.dc.w	0,0		;s_xmin,s_ymin (virhandx,virhandy)
	.dc.l	0		;src form (virtual canvas goes in here)
	.dc.w	8,vformwd,2
*
	.dc.w	0,0		;d_xmin,d_ymin
	.dc.l	0		;dst form (curscren)
	.dc.w	8,160,2
	.dc.l	0
*	.ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
*
*  ***end new code
*
blitmode:
	.dc.w	-1	;copybox   0-replace, -1-background transparent
jackmode:
	.dc.w	-1	;jacknife  0-replace, -1 background transparent
copystat:
	.dc.b	0	;(.b) D0-box exists; D1-origin exists; D2-box draggin
jackstat:
	.dc.b	0	;same for jack knife
scalemd:
	.dc.b	0	;=0 if drag only (no scale); nz if scale only
pathgot:
	.dc.b	0	;bit0=0 if file selector path not established, else 1
virtouch:
	.dc.b	-1	;-1 if virtual canvas not used; 0=if used
abndalrt:
	.dc.b	"[2][ |Save changes|before Proceeding?][Yes|No]",0
erasalrt:
	.dc.b	"[2][ |Erase entire picture?| |(UNDO cannot restore)]"
	.dc.b	"[Yes|No]",0
*
*
*  Unintialized data
*
	.bss
othrorgx:
	.ds.w	1	;alternate screen previous copybox originx
othrorgy:
	.ds.w	1	;alternate screen previous copybox originy
cpysrc:
	.ds.l	1	;screen base address for source of copybox
cpy_nxln:
	.ds.w	1	;form width of copybox source (usually 160)
cut_nxln:
	.ds.w	1	;form width of cut buffer (usually 160)
boxsrcx:
	.ds.w	1	;top/left xpos of copy box in screen0
boxsrcy:
	.ds.w	1	;top/left ypos of copy box in screen0
boxwidth:
	.ds.w	1	;width in pixels of copy box in screen0
boxhite:
	.ds.w	1	;height in pixels of copy box in screen0
orgwidth:
	.ds.w	1	;original boxwidth before scaling
orghite:
	.ds.w	1	;original boxhite before scaling
othwidth:
	.ds.w	1	;alternate screen previous boxwidth (scaling)
othhite:
	.ds.w	1	;alternate screen previous boxhite (scaling)
jackmwd:
	.ds.w	1	;form width of jacknife ant mono mask
obltmode:
	.ds.w	1	;blitmode saved while in jack knife
scaler:
	.ds.w	34	;scale routine parameter block
snewy:
*			;current screen shape y-pos
ldrworgx:
	.ds.w	1	;origin x of rubber line draw
snewht:
*			;current screen shape height
ldrworgy:
	.ds.w	1	;origin y of rubber line draw
shaporgx:
	.ds.w	1	;origin x of shapes draw
shaporgy:
	.ds.w	1	;origin y of shapes draw
soldy:
	.ds.w	1	;previous (othscren) shape y-pos
soldht:
	.ds.w	1	;previous (othscren) shape height (scanlines)
lastfrm:
	.ds.w	1	;frame count just before last buffer switch occurred
linebut:
	.ds.w	1	;line draw button (bit3-right,bit2-left) to act upon
sprayfrm:
	.ds.w	1	;frame when spray was last splatted
*
*  text stuff..
*
txtptr:
	.ds.l	1	;current position in text buffer
spraycol:
texbasx:
	.ds.w	1	;text base x position
texbasy:
	.ds.w	1	;text base y position
rezpalt:
shapebuf:
txstring:
	.ds.b	1024	;text string for text mode

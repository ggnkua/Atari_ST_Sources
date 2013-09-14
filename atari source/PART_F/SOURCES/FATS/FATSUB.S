*****************************************
*					*
*	Fat-bits editor subroutines	*
*					*
*****************************************
*
*
*    Programmer: Dave Staugas
*	  Start: March 1985
*   Last update: 31 Jul 1986
*
*
	.text
*
	.include	"fatequ.s"
*
*  public globals (subroutines)
*
*
	.globl	neopaint,path,time3x,snapto,straini,strain,constran
	.globl	strain8,strainx,strainy,straindg
	.globl	hidem,showm,setupbx,drawa,invdrawa
	.globl	vdicall,alertout,gemready,edgemsk
	.globl	objc_drw,form_do,form_alr,graf_mou,fsel_inp,appl_int
	.globl	graf_hdl,appl_ext
	.globl	loadcol,pointcol,leftpt,ritept,unleftpt,unritept
	.globl	newbox,hotbox,unhotbox
	.globl	coninst,conin,cscroll,cscrolr,cscrlupd
	.globl	oncurtx,offcurtx,matrix,uncolor,draw,box,newband
	.globl	invdraw,undraw,mouseget,drawq,invdrawq,systxt6,systxt8,systxt6i
	.globl	midi,tcdif,lowc,hblknull,vblk,mouse,unselbox,chg2cur
	.globl	undo,chgxcur,big2palt,setc14,back2bot
	.globl	unlbigbx,bigbx,gemready,othband,othsame,textd,copyd,jackdd
	.globl	systxt6t,rezset,rezclr
	.globl	rezsav,horzmax,vertmax,colmax
*
	.globl	dura,upbutx,gridon,xaccum,yaccum
*
*
*  public Ram variables
*
	.globl	irqlev,henabl,genabl,curpalt,half,selctcol,colleft,colrite
	.globl	frmcnt,tcdifsav,keysav,timrcsav,hblksav,vblksav
	.globl	oldmouse,mousped,xpos,ypos,updown,matxupd,button,oldbuttn
	.globl	textx,texty,p_block,diagx,originx,diagy,originy
	.globl	aoriginx,aoriginy,adiagx,adiagy
	.globl	doubtiml,doubtimr,csped,cscrolst,palt,color14
	.globl	msg0,conchar,textalin,textstyl,textsize,txtcelht
*
*
*  external globals
*
*	.globl	contrl,curscren,othscren,rezpalt
*	.globl	intin,int_in,int_out,colorz,_pblock
*	.globl	ptsout,intout,ptsin
*	.globl	addr_in,rowz,control,aes_pb,paletsav
*
*	.globl	virhandx,virhandy
*
*	.globl	anistat,anisped,cellx2scr,curcell,screnswp,jackstat,ant_splat
*	.globl	jackmwd,putcpytx
*
*	.globl	iconlist,curslist,icons,bigpalt,handform
*	.globl	liconlst,likesel
*	.globl	matselx,matsely,screen0,handy,copystat,paltx,full
*	.globl	physadd
*	.globl	modedraw,drawa,invdrawa
*	.globl	antpatrn,antptr,antbox,cpyrite
*
*	.globl	clrneo
*
*
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
*	.globl	fatblkx1,fatblky1,fatblkx2,fatblky2,fatblkx3,fatblky3
*	.globl	targx,targy,hotpxlx1,hotpxly1,hotpxlx2,hotpxly2
*	.globl	pallx,pally,pallw,pallh
*	.globl	iconw,iconh
*	.globl	iconlx,iconly,iconlw,iconlh
*	.globl	iconrx,iconry,iconrw,iconrh
*	.globl	cbarx,cbary
*
*
*  Draw background colored cursor
*
*
on0curtx:
	movem.l	a0-a6/d0-d7,-(sp)
	.dc.w	$a000
*
	move.w	#0,fg_bp_1(a0)
	move.w	#0,fg_bp_2(a0)
	move.w	#0,fg_bp_3(a0)
	move.w	#0,fg_bp_4(a0)
	bra.s	curtx
*
*
*
*  draw new text cursor..
*
oncurtx:
	movem.l	a0-a6/d0-d7,-(sp)
	.dc.w	$a000
*
	move.w	#1,fg_bp_1(a0)
	move.w	#1,fg_bp_2(a0)
	move.w	#1,fg_bp_3(a0)
	move.w	#1,fg_bp_4(a0)
	move.b	#3,curstate	;set cursor flash (bit1), set color #15 (bit0)
curtx:
	move.w	frmcnt,cursfrm
	move.w	#-1,lstlin(a0)
	move.w	#$FFFF,ln_mask(a0)
	move.w	#0,wrt_mode(a0)		;replace mode
*
	move.w	texty,d0
	move.w	d0,y1(a0)
	move.w	half,d1
	cmp.w	d1,d0
	bcc.s	ncq
	add.w	txtcelht,d0
	sub.w	d0,d1
	bcc.s	ncok
	add.w	d1,d0
ncok:
	subq.w	#1,d0
	move.w	d0,y2(a0)
	move.w	textx,d0
	cmpi.w	#320,d0
	bcc.s	ncq
	move.w	d0,x1(a0)
	move.w	d0,x2(a0)
	.dc.w	line
ncq:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*
*
*  copy a strip of screen0 to place where text cursor was
*
offcurtx:
	movem.l	a0-a1/d0-d3,-(sp)
	bclr.b	#1,curstate		;turn off cursor flash
	move.w	textx,d0
	cmpi.w	#320,d0
	bcc	offcurx
*
	move.w	texty,d1
	move.w	half,d2
	cmp.w	d2,d1
	bcc	offcurx
*
	move.w	d1,d3
	add.w	txtcelht,d3
	sub.w	d3,d2
	bcc.s	offcur1
	add.w	d2,d3
offcur1:
	sub.w	d1,d3
	mulu	#160,d1
	movea.l	screen0,a0
	movea.l	curscren,a1
	tst.w	full
	bne.s	offcur2
	move.w	handy,d2
	mulu	#160,d2
	adda.w	d2,a0
offcur2:
	move.w	d0,d2
	lsr.w	#1,d2
	andi.w	#$FFF8,d2
	add.w	d2,d1		
	adda.w	d1,a0
	adda.w	d1,a1
	not.w	d0
	andi.w	#$F,d0
	moveq	#0,d2
	bset.l	d0,d2
	move.w	d2,d1
	not.w	d1
	bra.s	offcuri
offcur3:
	move.w	(a0)+,d0
	and.w	d2,d0
	and.w	d1,(a1)
	or.w	d0,(a1)+
*
	move.w	(a0)+,d0
	and.w	d2,d0
	and.w	d1,(a1)
	or.w	d0,(a1)+
*
	move.w	(a0)+,d0
	and.w	d2,d0
	and.w	d1,(a1)
	or.w	d0,(a1)+
*
	move.w	(a0)+,d0
	and.w	d2,d0
	and.w	d1,(a1)
	or.w	d0,(a1)+
	adda.w	#160-8,a0
	adda.w	#160-8,a1
offcuri:
	dbra	d3,offcur3	
offcurx:
	movem.l	(sp)+,a0-a1/d0-d3
	rts
*
*  copy a band of background from screen0 
*  to erase line of text on othscren
*
newband:
	movem.l	a0-a1/d0-d3,-(sp)
	move.w	texty,d0
	move.w	half,d1
	move.w	txtcelht,d2
	move.w	d0,d3
	add.w	d2,d3
	sub.w	d3,d1
	bcc.s	nb1
	add.w	d1,d2
	bmi.s	nbq
	beq.s	nbq
nb1:
	movea.l	screen0,a0
	movea.l	othscren,a1
	mulu	#160,d0
	adda.w	d0,a0
	adda.w	d0,a1
	tst.w	full
	bne.s	newband1
	move.w	handy,d1
	mulu	#160,d1
	adda.w	d1,a0
newband1:
	lsl.w	#3,d2
	bra.s	newband3
newband2:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
newband3:
	dbra	d2,newband2
nbq:
	movem.l	(sp)+,a0-a1/d0-d3
	rts
*
*
*  copy text band (line) from curscren
*  to othscren
*
othband:
	movem.l	a0-a1/d0-d3,-(sp)
	move.w	texty,d0
	move.w	half,d1
	cmp.w	d1,d0
	bcc.s	obq
*
	move.w	txtcelht,d2
	move.w	d0,d3
	add.w	d2,d3
	sub.w	d3,d1
	bcc.s	ob1
	add.w	d1,d2
	bmi.s	obq
	beq.s	obq
ob1:
	movea.l	curscren,a0
	movea.l	othscren,a1
	mulu	#160,d0
	adda.w	d0,a0
	adda.w	d0,a1
	lsl.w	#3,d2
	bra.s	othband3
othband2:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
othband3:
	dbra	d2,othband2
obq:
	movem.l	(sp)+,a0-a1/d0-d3
	rts
*
*
*  copy lower half of curscren to lower half of othscren
*
othsame:
	movem.l	a0-a1/d0,-(sp)
	move.l	curscren,a0
	move.l	othscren,a1
	move.w	#16000,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.w	#999,d0
othsamlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,othsamlp
	movem.l	(sp)+,a0-a1/d0
	rts
*
*
*
*  Resolution resolution..
*
*  Restores system to resolution it was upon entry
*  so that GEM doesn't fuck up
*
rezset:
	movem.l	a0-a1/d0-d2,-(sp)
*
	bset.b	#0,rezstat
	bne.s	rezset1
*
	move.b	gridon,gridtemp		;save in temp
	clr.b	gridon
*
rezset1:
	tst.w	rezsav		;this is assured to be 0 or 1 (lo or med rez)
	bne.s	tomed		;br if must make medium resolution
*
	movea.l	#rezpalt,a1
	movea.l	#colorz,a0

	move.l	a1,a2
	move.w	#7,d0
	move.w	(a0),d1
	eori.w	#$777,d1
rezset1a:
	move.l	(a0)+,(a1)+
	dbra	d0,rezset1a
	move.w	d1,-(a1)
*
	move.l	a2,curpalt
	move.l	a2,-(sp)		;use special pallet
	move.w	#6,-(sp)
	trap	#14			;set special pallet
	addq.l	#6,sp
*
*	
*	movea.l	#colorz+30,a0
*	move.w	(a0),save15
*	move.w	-30(a0),d0
*	eori.w	#$777,d0
*	move.w	d0,(a0)
*
	bra.s	rezs1		;called from lo rez, our job is easy
tomed:
	.dc.w	$A000
	move.w	horzmax,-692(a0)	;restore these variables
	move.w	vertmax,-690(a0)
	move.w	colmax,-666(a0)
*
	move.w	#-1,-(sp)		;set to system rez
	move.l	physadd,-(sp)		;& put 
	move.l	physadd,-(sp)
	move.w	#5,-(sp)
	trap	#14			
	adda.w	#12,sp
*
	move.w	rezsav,-(sp)		;set to system rez
	move.l	#-1,-(sp)		;& put 
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14			
	adda.w	#12,sp
*
	move.l	#paletsav,curpalt
	move.l	#paletsav,-(sp)		;use system pallet
	move.w	#6,-(sp)
	trap	#14			;set system pallet
	addq.l	#6,sp
	bra.s	rezs3
rezs1:
	movea.l	physadd,a0		;copy screen
	movea.l	curscren,a1
	move.w	#1999,d1
rezslp1:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d1,rezslp1
*
	suba.w	#(5*160)-56,a0
	move.l	#$FFFCFFFC,d0
	moveq	#0,d2
	move.w	#4,d1
blnklp:
	and.l	d0,(a0)+
	and.l	d0,(a0)+
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	adda.w	#160-40,a0
	dbra	d1,blnklp
*	
*	
rezs2:
*
	move.w	#-1,-(sp)		;set to system rez
	move.l	physadd,-(sp)		;& put 
	move.l	physadd,-(sp)
	move.w	#5,-(sp)
	trap	#14			
	adda.w	#12,sp
rezs3:
	movem.l	(sp)+,a0-a1/d0-d2
	rts
*
*
*
rezclr:
	movem.l	a0-a1/d0-d1,-(sp)
*
	clr.b	rezstat
	move.b	gridtemp,gridon	;restore from temp
*
	tst.w	rezsav		;this is assured to be 0 or 1 (lo or med rez)
	bne.s	tomedc
*
*	move.w	save15,colorz+30
*
	bra.s	rezc1		;if called from lo rez, our job is easy
tomedc:
	.dc.w	$A000
	move.w	#319,-692(a0)	;restore these variables
	move.w	#199,-690(a0)
	move.w	#16,-666(a0)
	move.w	#163,-602(a0)
	move.w	#106,-600(a0)
*
	move.w	#0,-(sp)		;set to our rez
	move.l	#-1,-(sp)		;& put up current screen
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14			
	adda.w	#12,sp
*
rezc1:
	move.l	#colorz,curpalt
	move.l	#colorz,-(sp)		;use our pallet
	move.w	#6,-(sp)
	trap	#14			;set our pallet
	addq.l	#6,sp
*
	move.w	#-1,-(sp)		;set to our rez
	move.l	curscren,-(sp)		;& put up current screen
	move.l	curscren,-(sp)
	move.w	#5,-(sp)
	trap	#14			
	adda.w	#12,sp
*
	movem.l	(sp)+,a0-a1/d0-d1
	rts
	
*
*
*  undraw color select box
*
unselbox:
	movem.w	d0-d7,-(sp)
	move.b	matselx,d0
	sub.b	paltx,d0
	bcs.s	nbigbox
	cmpi.b	#fatpxlnx,d0
	bcc.s	nbigbox
	ext.w	d0
	move.b	matsely,d1
	ext.w	d1
	bsr.s	unhotbox
*
	tst.w	d0
	beq.s	bigb
	tst.w	d1
	beq.s	bigb
	cmpi.w	#fatpxlnx-1,d0
	beq.s	bigb
	cmpi.w	#fatpxlny-2,d1
	bne.s	nbigbox
bigb:
	bsr.s	lbigbx			;draw "little" big box
nbigbox:
	movem.w	(sp)+,d0-d7
	rts
*
*  "Un" Draw master color pallet window outline (little "Big" box)
*
unlbigbx:
	movem.w	d0-d6,-(sp)
	moveq	#0,d4		;background color
	bra.s	lbigbx1
*
*  Draw fatbits window outline ("Big" box)
*
lbigbx:
	movem.w	d0-d6,-(sp)
	moveq	#$f,d4		;color 15
lbigbx1:
	move.w	#fatblkx3,d2
	move.w	#fatblky3,d3
	bra.s	bigbx2
*
*  Undraw fatbits window outline
*
unbigbx:
	movem.w	d0-d6,-(sp)
	moveq	#0,d4		;background color
	bra.s	bigbx1
*
*  Draw fatbits window outline ("Big" box)
*
bigbx:
	movem.w	d0-d6,-(sp)
	moveq	#$f,d4		;color 15
bigbx1:
	move.w	#fatblkx2,d2
	move.w	#fatblky2,d3
bigbx2:
	move.w	#fatblkx1,d0
	move.w	#fatblky1,d1
	moveq	#0,d5
	moveq	#-1,d6
	bsr.s	box
	movem.w	(sp)+,d0-d6
	rts
*
*
*  Enclose hot spot fat pix in a box
*
* entry:
*  d0.w - horizontal fat pixel #
*  d1.w - vertical fat pixel #
*
unhotbox:
	movem.l	d0-d7/a0,-(sp)
	moveq	#0,d4			;background color
	bra.s	hotbox1
hotbox:
	movem.l	d0-d7/a0,-(sp)
	move.w	#$F,d4			;system color
hotbox1:
	mulu	#fatpxlw,d0
	addi.w	#fatblkx1,d0
	mulu	#fatpxlh,d1
	addi.w	#fatblky1,d1
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#fatpxlw,d2
	addi.w	#fatpxlh,d3
	moveq	#0,d5			;writing mode
	moveq	#-1,d6		;line mask
	bra.s	box1
*
*
*  new animate box draw
*
newbox:
	movem.l	d0-d7/a0,-(sp)
	move.w	aoriginx,d0		;top/left x
	move.w	aoriginy,d1		;top/left y
	move.w	adiagx,d2		;bot/rite x
	move.w	adiagy,d3		;bot/rite y
	move.w	#2,d5			;xor writing mode
	move.w	#$f,d4			;color
	move.w	#$AAAA,d6		;line mask
	bra.s	box1
*
*****************************************************
*
*  draw a box with line A ABline
*
*	d0.w = top/left x
*	d1.w = top/left y
*	d2.w = bot/rite x
*	d3.w = bot/rite y
*	d4.w = color
*	d5.w = writing mode (0-replace, 1-transparent, 2-xor, 3-inverse transparent)
*	d6.w = line mask (normally $FFFF)
*  
box:
	movem.l	d0-d7/a0,-(sp)
box1:
	move.w	#123,contrl+0		;hide cursor
	bsr	vdicall
	movem.w	d0-d6,-(sp)
	.dc.w	$a000			;get a0 -> base of global variables
	movem.w	(sp)+,d0-d6
*
	move.w	#-1,lstlin(a0)
	move.w	d6,ln_mask(a0)
	move.w	d5,wrt_mode(a0)
	move.w	#3,d6
coload:
	moveq	#0,d5
	lsr.w	#1,d4
	bcc.s	coload1
	addq.w	#1,d5
coload1:
	move.w	d5,fg_bp_1(a0)
	addq.l	#2,a0
	dbra	d6,coload
	subq.l	#8,a0
*
	cmp.w	d0,d2
	beq	singline
	cmp.w	d1,d3
	beq	singline
*
	move.w	d0,x1(a0)
	move.w	d1,y1(a0)
	move.w	d2,x2(a0)
	move.w	d1,y2(a0)
	movem.l	d0-d3/a0,-(sp)
	.dc.w	line
	movem.l	(sp)+,d0-d3/a0
*
	move.w	d2,x1(a0)
	addq.w	#1,d1
	cmp	d1,d3
	bcc.s	closer0
	subq.w	#2,d1
closer0:
	move.w	d1,y1(a0)
	move.w	d2,x2(a0)
	move.w	d3,y2(a0)
	movem.l	d0-d3/a0,-(sp)
	.dc.w	line
	movem.l	(sp)+,d0-d3/a0
*
	addq.w	#1,d2
	cmp.w	d2,d0
	bcc.s	closer1
	subq.w	#2,d2
closer1:
	move.w	d2,x1(a0)
	move.w	d3,y1(a0)
	move.w	d0,x2(a0)
	move.w	d3,y2(a0)
	movem.l	d0-d4/a0,-(sp)
	.dc.w	line
	movem.l	(sp)+,d0-d4/a0
*
	cmp.w	d3,d1
	beq.s	closer3
	addq.w	#1,d3
	cmp	d3,d1
	bcc.s	closer2
	subq.w	#2,d3
closer2:
	move.w	d0,x1(a0)
	move.w	d3,y1(a0)
	move.w	d0,x2(a0)
	move.w	d1,y2(a0)
	.dc.w	line
closer3:
	movem.l	(sp)+,d0-d7/a0
	rts
*
singline:
	move.w	d0,x1(a0)
	move.w	d1,y1(a0)
	move.w	d2,x2(a0)
	move.w	d3,y2(a0)
	.dc.w	line
	movem.l	(sp)+,d0-d7/a0
	rts
*
*
*
*
*
*  Pre-digest mouse button events before giving
*  control to GEM...
*
gemready:
	move.w	#$2600,irqlev	;set timer c & mouse/keybrd to normal IPL
	clr.w	henabl		;disable h-blank (enables timer c extended)
*
	rts
*
*
*  fill in fat-bits square
*
matrix:
	tst.w	full			;on full screen
	beq.s	dohalf			;br if not
	movem.w	d0-d2,-(sp)		;full screen..
	bra	skippalt		;skip fat-bits update
dohalf:
	bclr.b	#1,updown		;need to change cursor?
	beq	nocurchg
	movem.w	d0-d2,-(sp)
	bsr	hidem			;hide cursor
	btst.b	#0,updown		;which half, up/down?
	beq.s	setptr			;br if lower
*
*  Set up upper half screen; draw function cursor
*
	bsr	unselbox		;undraw color select box (if any)
	bsr	unlbigbx		;erase little big box
	bsr	bigbx			;draw big box
*
	move.w	#targx,d0
	move.w	#targy,d1
	bsr	hotbox			;draw target box
*
	btst.b	#3,copystat
	bne	chgexit
*
	btst.b	#3,jackstat
	bne.s	chgexit
*
	bsr	chg2cur			;change to current cursor
*
	tst.b	cpyrite			;see if fancy NEOchrome is up
	ble.s	chgexit			;br if not
	bsr	clrneo			;else, clear it
	bra.s	chgexit
*
*  draw pointer cursor (we're on bottom half of screen)
*
setptr:
*
*	bclr.b	#3,copystat	;always request copybox cursor re-draw
*				 even if not in copy mode
	bsr	unbigbx		;undraw  big box
	bsr	lbigbx		;re-draw "little" big big box
*
	move.w	#$f,d0		;put up form 15 (normal pointer)
	bsr	chgxcur		;into mouse form
*
	bclr.b	#3,copystat	;in case copybox tell 'em we're "outside"
	move.b	copystat,d0
	andi.b	#3,d0
	cmpi.b	#2,d0		;origin in existence, but box not?
	bne.s	nofixx
	bsr	setupbx		;we left before we could fix box
nofixx:
*
	bsr	big2palt
*
	move.w	#targx,d0
	move.w	#targy,d1
	bsr	unhotbox
	move.b	matselx,d0
	sub.b	paltx,d0
	bcs.s	chgexit
	cmpi.b	#fatpxlnx,d0
	bcc.s	chgexit
	move.b	matsely,d1
	ext.w	d0
	ext.w	d1
	bsr	hotbox
*
chgexit:
	bsr	othsame
	movem.w	(sp)+,d0-d2
nocurchg:
	movem.w	d0-d2,-(sp)
	btst.b	#0,updown		;which half, up/down?
	beq	skippalt		;skip pallet draw if on lower half
*
*
*  Get pixels around cursor and stuff in fat bits matrix
*
*
	movea.l	curscren,a0		;a0 -> base of current screen
	lea	palt,a1			;a1 -> start of h-blank pallet list
	lea	colorz,a2		;a2 -> current user colors (0-15)
*
	move.w	#fatpxlny-1,temp0	;assume full # of rows
	move.w	#$FFFF,lftmsk		;assume no masking
	subi.w	#targy,d1		;start targy rows up from hot spot
	bcc.s	notopmsk		;br if no top masking necessary
	add.w	d1,temp0		;adjust row count by neg amount
	eori.w	#-1,d1			;get # of rows to clip (-1)
	move.w	(a2),d2			;get background color to d2
topmsk0:
	move.w	#fatpxlnx-1,d7		;elements per row (-1)
topmsk1:
	move.w	d2,(a1)+		;put in background color
	dbra	d7,topmsk1		;finish row
	dbra	d1,topmsk0		;finish clip area
	moveq	#0,d1			;start at row #0
notopmsk:
	mulu	#160,d1			;vpos * 160 bytes/row => offset from base
	subi.w	#targx,d0		;start targx columns left of hot spot
	bcc.s	noledge			;br if no left clipping necessary
*
*  need to left clip with mask
*
	add.w	#16,d0			;move right to 1st full word
	suba.w	#8,a0			;back up base pointer 16 low rez pixels
	move.w	d0,d2
	lsl.w	#1,d2			;form index into mask table
	move.w	edgemsk(pc,d2.w),lftmsk	;get mask
	bra.s	noledge			;br around embedded table
edgemsk:
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
noledge:
	move.w	d0,d2
	add.w	#fatpxlnx,d2		;check right clip
	subi.w	#320,d2			;within bounds?
	bls.s	noritmsk
*
*  the following instructions needn't be done at run time
*
	add.w	#16,d2			
	sub.w	#fatpxlnx,d2
*
*  if above 2 are ommitted, use "move.w edgemsk+16-fatpxlnx(pc,d2.w),d2
*  global equates won't permit this kind of expression
*
	lsl.w	#1,d2
	move.w	edgemsk(pc,d2.w),d2
	eori.w	#-1,d2
	move.w	d2,lftmsk
noritmsk:
	move.w	d0,d2
	andi.w	#$f,d2
	lsr.w	#1,d0			;/8 for byte
	andi.w	#$FFF8,d0
	add.w	d0,d1
rowloop:
	move.w	0(a0,d1.w),d3
	move.w	2(a0,d1.w),d4
	move.w	4(a0,d1.w),d5
	move.w	6(a0,d1.w),d6
	swap	d3
	swap	d4
	swap	d5
	swap	d6
	move.w	8(a0,d1.w),d3
	move.w	10(a0,d1.w),d4
	move.w	12(a0,d1.w),d5
	move.w	14(a0,d1.w),d6
	lsl.l	d2,d3
	lsl.l	d2,d4
	lsl.l	d2,d5
	lsl.l	d2,d6
*
	move.w	lftmsk,d7
	swap	d7
	or.w	#$FFFF,d7
	and.l	d7,d3
	and.l	d7,d4
	and.l	d7,d5
	and.l	d7,d6
*
	move.w	#fatpxlnx-1,d7
bitloop:
	moveq	#0,d0
	roxl.l	d6
	roxl.w	d0
	roxl.l	d5
	roxl.w	d0
	roxl.l	d4
	roxl.w	d0
	roxl.l	d3
	roxl.w	d0
	lsl.w	d0
	move.w	(a2,d0.w),(a1)+
	dbra	d7,bitloop
	addi.w	#160,d1
	subq.w	#1,temp0
	bpl.s	rowloop
*
skippalt:
	bsr	showm		;show mouse
*
*	move.w	#122,contrl+0		;show cursor
*	clr.w	intin
*	move.w	#1,contrl+6
*	bsr	vdicall
*
nocurz:
	movem.w	(sp)+,d0-d2
	rts
*
*  Update big pallet matrix based on paltx
*
big2palt:
	movem.l	a0-a1/d0-d1,-(sp)
	movea.l	#bigpalt,a0
	movea.l	#palt,a1
	move.b	paltx,d0
	ext.w	d0
	lsl.w	#5,d0		;*32
	adda.w	d0,a0
	move.w	#fatpxlnx-1,d1
palp1:
	move.l	a1,-(sp)
	move.w	#15,d0
palp:
	move.w	(a0)+,(a1)
	adda.w	#26,a1		;2*fatpxlnx
	dbra	d0,palp
	move.l	(sp)+,a1
	addq.w	#2,a1
	dbra	d1,palp1
*
	bsr.s	back2bot
*
	movem.l	(sp)+,a0-a1/d0-d1
	rts
*
*  set bottom row to background color
*
back2bot:
	movem.l	a0/d0-d1,-(sp)
	move.w	colorz,d0
	move.w	#fatpxlnx-1,d1
	movea.l	#palt+(2*13*16),a0	;fatpxlnx*(fatpxlny-1)
back2:
	move.w	d0,(a0)+
	dbra	d1,back2
	movem.l	(sp)+,a0/d0-d1
	rts

*  set up color 14
*
setc14:
	movem.l	a0-a1/d0-d7,-(sp)
	movea.l	#bigpalt,a0
	move.b	matselx,d0
	move.b	matsely,d1
	ext.w	d0
	ext.w	d1
	lsl.w	#4,d0		;*16
	add.w	d0,d1
	lsl.w	d1
	move.w	(a0,d1.w),d1
	move.w	d1,color14
*
*  display color nbr for jerome
*
	movea.l	#msgcnbr+3,a0
	move.w	#2,d3
msglp:
	move.w	d1,d2
	and.w	#$7,d2
	move.b	nibltab(pc,d2.w),-(a0)
	lsr.w	#4,d1
	dbra	d3,msglp
	move.w	#cbarx+14,d0
	move.w	#cbary+4,d1
	movea.l	#msgcnbr,a0
	bsr	systxt8
*
*  end jerome's stuff
*
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
nibltab:
	.dc.b	$10,$11,$12,$13,$14,$15,$16,$17
*
*  Install cursor indicated in d0
*
chgxcur:
	movem.l	d0/a0,-(sp)
	bra.s	chgcur
*
*  Install cursor appropriate to current mode..
*
chg2cur:
	movem.l	d0/a0,-(sp)
	move.b	likesel,d0
chgcur:
	ext.w	d0
	lsl.w	#2,d0
	movea.l	#curslist,a0
	move.l	(a0,d0.w),_pblock+4
	move.w	#111,contrl+0		;set mouse form
	move.w	#0,contrl+2
	move.w	#37,contrl+6
	bsr	vdicall
	move.l	#intin,_pblock+4
	movem.l	(sp)+,d0/a0
	rts
*
*
*  undo function  (to be called when undo key is struck)
*
*
undo:
	movem.l	a0-a3/d0-d7,-(sp)
*
	bsr	hidem
*
	move.l	screen0,a1
	move.w	#7999,d0
	tst.w	full
	bne.s	undo1
*
	move.w	handy,d0
	mulu	#160,d0
	adda.w	d0,a1
	move.w	#3999,d0
*
*  test for special cases..
*
undo1:
	move.b	likesel,d1		;check for copymode or jacknife
	bne.s	undo4			;br if not jacknife
	btst.b	#3,jackstat		;need jack cursor change?
	beq.s	undo5
	bsr	chg2cur
undo5:
	movem.l	a1/d0,-(sp)		;save screen0 & count
	bsr	jackdd			;terminate jack
	bsr	putcpytx
	movem.l	(sp)+,a1/d0
	bra.s	undo3
*	
undo4:
	cmpi.b	#2,d1
	bne.s	notcop
	btst.b	#3,copystat		;need copybox cursor change?
	beq.s	undo2
	bsr	chg2cur			;set back to copybox cursor
undo2:
	movem.l	a1/d0,-(sp)		;save screen0 & count
	bsr	copyd			;terminate copymode
	bsr	putcpytx
	movem.l	(sp)+,a1/d0
	bra.s	undo3
*
*  Not copymode..
*
notcop:
	cmpi.b	#3,d1		;in textmode?
	bne.s	undo3		;br if no
	bsr	textd		;kill textmode
undo3:
	movea.l	curscren,a0
undolp:
	move.l	(a0),d1
	move.l	(a1),(a0)+
	move.l	d1,(a1)+
	dbra	d0,undolp
*
undox:
*
	move.b	#$80,matxupd	;force matrix update
*	
	movem.l	(sp)+,a0-a3/d0-d7
	rts
*
*
vdicall:
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	#_pblock,d1
	move.l	#115,d0
	trap	#2
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*  Certified mouse input routine
*
*  exit:
*	d0 = current mouse x
*	d1 = current mouse y
*	d2 = button states
*	d3 = previous mouse x
*	d4 = previous mouse y
*
*  Button states in d2..
*
*		  the following are 1 if true:
*		bit0 - left button down
*		   1 - rite button down
*		   2 - left leading edge
*		   3 - rite leading edge
*		   4 - left trailing edge
*		   5 - rite trailing edge
*		   6 - left double click
*		   7 - rite double click
*
*		  14 - key is depressed
*		  15 - x or y have changed
mouseget:
	movea.l	#contrl,a0
	move.w	#124,(a0)+
	clr.w	(a0)
	clr.w	4(a0)
	bsr	vdicall			;sample mouse buttons
*
	move.w	intout,d2
	andi.w	#3,d2
	move.w	d2,-(sp)
	tst.l	conchar
	bne.s	keyd
	bsr	coninst			;check keyboard too
	beq.s	keyless
	bsr	conin
	move.l	d0,conchar
keyd:
	ori.w	#$4000,(sp)
keyless:
	move.w	(sp)+,d2
*
	movea.l	#ptsout,a0
	move.w	(a0)+,d0		;get new x
	move.w	(a0),d1			;new y
*
	movea.l	#oldmx,a0		;ptr to old values
	move.w	(a0)+,d3		;old x
	move.w	(a0)+,d4		;old y
	move.w	(a0),d5			;old buttons
*
	move.w	d2,(a0)			;put new in old
	move.w	d1,-(a0)		;y
	move.w	d0,-(a0)		;x
*
	eor.w	d2,d5			;change in buttons?
	btst.l	#0,d5			;change in left?
	beq.s	nolchg			;br if no change
	moveq	#2,d6			;assume leading
	btst.l	#0,d2			;leading or trailing?
	bne.s	llead			;br if assumption ok
*
*  left trailing edge
*
	move.b	#-10,doubtiml		;10 v-blanks max between
	moveq	#4,d6			;1st trailing & 2nd leading for double click
	bra.s	setledg
*
*  left leading edge
*
llead:
	tst.b	doubtiml		;left trailing edge within 30 v-blanks?
	bpl.s	setledg			;br if not
	bset.l	#6,d2			;else, set left double click
setledg:
	bset.l	d6,d2			;set left lead/trail edge
nolchg:
	btst.l	#1,d5			;change in right?
	beq.s	norchg			;br if no change
	moveq	#3,d6			;assume leading
	btst.l	#1,d2			;leading or trailing?
	bne.s	rlead			;br if assumption ok
*
*  rite trailing edge
*
	move.b	#-10,doubtimr
	moveq	#5,d6
	bra.s	setredg
*
*  rite leading edge
*
rlead:
	tst.b	doubtimr		;rite trailing edge within 30 v-blanks?
	bpl.s	setredg
	bset.l	#7,d2			;set rite double click
setredg:
	bset.l	d6,d2
norchg:
*
* new half-screen transition stuff
*
	move.b	updown,d7		;copy updown to temp
	move.w	d2,d5			;copy buttons to temp
	or.b	upbutx,d5		;set fake button down if set
	btst	#2,d7			;upper region extend bit on?
	beq.s	norchg2			;br if not
*
*  upper region extend to lower region mode in effect..
*
	andi.w	#$33,d5			;any buttons down or trailing edges?
	bne.s	norchg1			;br if so
	bclr	#2,d7			;else, clear region extend bit
	bset	#1,d7			;set matrix/cursor update bit
	bra.s	norchg2
norchg1:
	move.w	half,d6			;clip y to max for upper region
	subq.w	#1,d6
	cmp.w	d1,d6
	bcs.s	norchg3			;br if in lower region
	bclr	#2,d7			;clear region extend bit
	bra.s	norchg2
norchg3:
*
*  added 27-Jul
	tst.b	gridon			;check for grid
	beq.s	norchg3x		;br if no grid
	move.w	handy,d6
	andi.w	#7,d6
	move.b	tabline(pc,d6.w),d6
norchg3x:
	move.w	d6,d4
*  end 27-Jul
*
	move.w	d6,d1
	move.w	d1,oldmy
norchg2:	
	cmp.w	half,d1			;check mouse passed midline
	bcs.s	upm			;br if on upper half
*
*  moving in lower half
*
	clr.w	mousped			;normal mouse down under
	bclr	#0,d7			;set for lower
	beq.s	curchgx			;br if previous on lower
	andi.w	#3,d5			;any buttons down?
	bne.s	norchg5			;br if so, need to set extended region
	bclr.b	#0,reqgrdq		;grant grid exit request if requested
	bra.s	curchgg			; & do normal lower screen non-grid
*
*  extended region required here... set it up
*
norchg5:
	moveq	#5,d7			;set for upper-half still,ext region
	move.w	half,d1			;clip y to max for upper region
	subq.w	#1,d1
	tst.b	gridon
	beq.s	norchg4
	move.w	handy,d1
	andi.w	#7,d1
	move.b	tabline(pc,d1.w),d1
norchg4:
	move.w	d1,oldmy
	move.w	#-1,mousped		;use slower mose
	bra.s	curchgx
*
*  added 27-Jul
tabline:
	.dc.b	96,95,94,93,92,99,98,97
*  end addition
*
*
curchgg:
	bset	#1,d7
	bra.s	curchgx
*
*  moving in upper half
*
upm:
	move.w	#-1,mousped		;use slower mose
	bset	#0,d7
	bne.s	curchgx
	bset	#1,d7
	bclr	#2,d7
curchgx:
	move.b	d7,updown
*
*  end new half-screen transition stuff
*
	cmp.w	d0,d3			;change in x?
	bne.s	chgxy
	cmp.w	d1,d4
	bne.s	chgxy
	bclr.b	#7,matxupd		;check force change in x
	beq.s	nochgxy			;(for matrix update)
chgxy:
	ori.w	#$8000,d2		;set x or y change flag
nochgxy:
	cmp.w	half,d4			;need to clip previous y?
	bcs.s	noclipy			;br if not
	move.w	half,d4			;  else, clip to bottom line
	subq.w	#1,d4
	tst.b	gridon
	beq.s	clipy0
	move.w	handy,d4
	andi.w	#7,d4
	move.b	tabline(pc,d4.w),d4
clipy0:
noclipy:
	tst.w	d2
	rts
*
*
*
*
*
prt	equ	0
aux	equ	1
con	equ	2
*
chinst	equ	1
chinp	equ	2
choutp	equ	3
*
conin:
	move.w	#con,-(sp)
	move.w	#chinp,-(sp)
	trap	#13
	addq.l	#4,sp
	rts
*
coninst:
	move.w	#con,-(sp)
	move.w	#chinst,-(sp)
	trap	#13
	addq.l	#4,sp
	tst.w	d0
	rts
*
*
*
*
*  initialize constrain function
*
straini:
	movem.w	d0-d4,-(sp)
	move.w	d0,strainx
	move.w	d1,strainy
*
	move.w	#-1,-(sp)		;check shift bits
	move.w	#11,-(sp)
	trap	#13			;from keyboard
	addq.l	#4,sp
*
	moveq	#0,d1			;set constrain status
*
	btst.l	#1,d0			;left shift key down?
	beq.s	nostrain
	moveq	#$80,d1			;set bit 7
nostrain:
	move.b	d1,constran		;set constrain
	movem.w	(sp)+,d0-d4
	rts
*
*
*
*
straindg:
	tst.b	constran
	beq	strain8q
	movem.w	d2-d4,-(sp)
	moveq	#0,d2
	sub.w	strainx,d0
	bpl.s	strandga
	neg.w	d0
	addq.w	#4,d2
strandga:
	sub.w	strainy,d1
	bpl.s	strandgb
	neg.w	d1
	addq.w	#2,d2
strandgb:
	cmp.w	d0,d1
	bgt.s	strandgc	;br if x is min
	exg	d0,d1
	addq.w	#1,d2
*
*  now decide for diag & jump into strain8
*
*  d0 is min, d1 max
*
strandgc:
	bra.s	diagntry
*
*
*   d2 =
*
*	  \  6  |  2  /
*	   \    |    /
*	    \   |   /
*	     \  |  /  
*	 7    \ | /   3
*	       \|/
*   -----------------------
*	       /|\
*	 5    / | \   1
*	     /  |  \
*	    /   |   \
*	   /    |    \
*	  /  4  |  0  \
*		
*
strain8:
	tst.b	constran
	beq.s	strain8q
	movem.w	d2-d4,-(sp)
	moveq	#0,d2
	sub.w	strainx,d0
	bpl.s	strain8a
	neg.w	d0
	addq.w	#4,d2
strain8a:
	sub.w	strainy,d1
	bpl.s	strain8b
	neg.w	d1
	addq.w	#2,d2
strain8b:
	cmp.w	d0,d1
	bgt.s	strain8c	;br if x is min
	exg	d0,d1
	addq.w	#1,d2
*
*  now decide on horz/vert or diag
*
*  d0 is min, d1 max
*
strain8c:
	move.w	d1,d3
	sub.w	d0,d3			;find dif
	move.w	d0,d4
	add.w	d4,d4
	mulu	d3,d3
	mulu	d4,d4
	add.l	d3,d3
	cmp.l	d3,d4
	bcs.s	hvset
diagntry:
	move.w	d0,d1
	bra.s	diagset
hvset:
	moveq	#0,d0
diagset:
	lsr.w	#1,d2
	bcc.s	strain8d
	exg	d0,d1
strain8d:
	lsr.w	#1,d2
	bcc.s	strain8e
	neg.w	d1
strain8e:
	lsr.w	#1,d2
	bcc.s	strain8f
	neg.w	d0
strain8f:
	add.w	strainx,d0
	add.w	strainy,d1
	movem.w	(sp)+,d2-d4
strain8q:
	rts
*
*
*
*  continue constrain function
*
strain:
	move.w	d2,-(sp)
	move.b	constran,d2		;get status bits
	ext.w	d2
	beq	strain1			;br if no constrain requested
	bpl.s	strain2			;br if constrain in effect
*
*  wait for 2nd sample to determine constrain
*
	moveq	#0,d2
	cmp.w	strainx,d0
	beq.s	strain3
	addq.w	#4,d2
strain3:
	cmp.w	strainy,d1
	beq.s	strain4
	addq.w	#8,d2
strain4:
	tst.w	d2
	bne.s	strain4x
	move.w	d0,d3
	move.w	d1,d4
	move.w	(sp)+,d2
	rts
strain4x:
	cmpi.w	#12,d2
	bne.s	strain5			;br if horz/vert clear-cut
*
*  else, diagonal--see which dimension has greatest abs magnitude
*
	movem.w	d0-d1,-(sp)
	moveq	#0,d2
	sub.w	strainx,d0
	bpl.s	strain6
	neg.w	d0
	addq.w	#1,d2
strain6:
	sub.w	strainy,d1
	bpl.s	strain7
	neg.w	d1
	addq.w	#2,d2
strain7:
	cmp.w	d0,d1		;compare abs magnitudes
	bne.s	stran8		;if not equal, its clear-cut
	move.b	cflip(pc,d2.w),d2
	bra.s	strain9
cflip:
	.dc.b	4,8,4,8		;quads II,III,I, IV respectively
stran8:
	blt.s	domhorz
	moveq	#8,d2
	bra.s	strain9
domhorz:
	moveq	#4,d2
strain9:
	movem.w	(sp)+,d0-d1
strain5:
	move.b	d2,constran
*
*	d2 =	4  horz
*		8  vert
*
*  fall thru to...
*
*  perform constrain on d0, d1
*
strain2:
	move.l	strantab-4(pc,d2.w),-(sp)
	rts
*
*
strantab:
	.dc.l	horzdo
	.dc.l	vertdo
vertdo:
	move.w	strainx,d0
	move.w	d0,d3
	bra.s	strain1
horzdo:
	move.w	strainy,d1
	move.w	d1,d4
*	bra.s	strain1
*
strain1:
	move.w	(sp)+,d2
	rts
*
*
*
*
*  Frame synchronous stuff--
*  To be called each time around the main loop
*
*
*  continuous color scroll stuff
*
cscrlupd:
	move.w	cscrolst,d0		;check color scroll status
	beq.s	nocst			;br to exit if scroll not in effect
	move.w	frmcnt,d1
	sub.w	oldfrm,d1
	cmp.w	csped,d1
	bcs.s	nocst
	addq.w	#1,dura
	move.w	frmcnt,oldfrm
	btst.l	#0,d0			;scroll rite?
	beq.s	nocst1
	bsr	cscroll
	bra.s	nocst
nocst1:
	btst.l	#1,d0			;scroll left?
	beq.s	nocst
	bsr	cscrolr
*
*  New stuff for copybox crawling ants
*
nocst:
*
	move.b	copystat,d1		;any copybox action?
	beq.s	nocst3			;br if not
	btst.l	#2,d1			;dragging box?
	bne	csclxxx			;skip ant crawl if draggin' box
*
	move.w	frmcnt,d1
	sub.w	antfrm,d1
	cmp.w	#6,d1
	bcs	csclxxx
	move.w	frmcnt,antfrm
	move.l	antptr,a1
	subq.l	#4,a1
	cmpa.l	#antpatrn,a1
	bcc.s	nocst2
	adda.w	#16,a1
nocst2:
	move.l	a1,antptr
*
	bsr	hidem			;hide cursor
*
	move.l	curscren,a1
	bsr	antbox
	move.b	#$80,matxupd	;force matrix update
nocst3:
*
*   crawling ants for jack knife
*
	move.b	jackstat,d1		;any jacknife action?
	beq	nocst3x			;br if not
	andi.w	#5,d1			;check completed & drag bits
	cmpi.w	#1,d1			;skip ant crawl if draggin' jack or
	bne	csclxxx			;not complete
*
	move.w	frmcnt,d1
	sub.w	antfrm,d1
	cmp.w	#6,d1
	bcs	csclxxx
	move.w	frmcnt,antfrm
	move.l	antptr,a2
	subq.l	#4,a2
	cmpa.l	#antpatrn,a2
	bcc.s	nocst2x
	adda.w	#16,a2
nocst2x:
	move.l	a2,antptr
*
	bsr	hidem			;hide cursor
*
	move.l	othscren,a0
	move.l	curscren,a1
	movea.w	#160,a5
	move.w	jackmwd,d4
	move.w	d4,a4
	move.w	originx,d0
	bpl.s	ncs0
	neg.w	d0
	add.w	#15,d0
	lsr.w	#4,d0
*	addq.w	#1,d0
	add.w	d0,d0
	adda.w	d0,a0
	clr.w	d0
ncs0:
	move.w	originy,d1
	bpl.s	ncs1
	neg.w	d1
	mulu	d4,d1
	add.l	d1,a0
	clr.w	d1
ncs1:
	move.w	diagx,d2
	cmpi.w	#319,d2
	ble.s	ncs2
	move.w	#319,d2
ncs2:
	move.w	diagy,d3
	cmp.w	half,d3		;100 or 200
	blt.s	ncs3
	move.w	half,d3
	subq.w	#1,d3
ncs3:
	bsr	ant_splat	
	move.b	#$80,matxupd	;force matrix update
	bra	csclxxx
nocst3x:
*
*  more new stuff for cursor flash..
*
	btst.b	#1,curstate		;check for text cursor flash
	beq.s	nocst5
	move.w	frmcnt,d1
	sub.w	cursfrm,d1
	cmpi.w	#30,d1
	bcs	csclxxx
*
	bsr	hidem			;hide cursor
*
	move.b	#$80,matxupd	;force matrix update
	bchg.b	#0,curstate
	bne.s	nocst4
	bsr	oncurtx
	bra.s	csclxxx
nocst4:
	bsr	on0curtx
	bra.s	csclxxx
nocst5:
*
*  animate stuff
*
	move.b	likesel,d1
	cmpi.b	#11,d1		;is this animate?
	bne.s	nocst6		;exit if not animate
*
	move.b	anistat,d0
	btst.l	#4,d0		;continous animate set?
	beq.s	nocst6		;br if not
*
	move.l	curcell,d2
	beq.s	nocst6
	move.w	frmcnt,d1
	sub.w	anifrm,d1
	cmp.w	anisped,d1
	bcs.s	nocst6
	move.w	frmcnt,anifrm
	move.l	d2,a0
	btst.l	#5,d0		;animate rite?
	beq.s	nocst5x		;br if left
*
*  move 1 right (reverse)
*
	move.l	2(a0),curcell
	bra.s	nocst5y
nocst5x:
*
*  move 1 left (forward)
*
	move.l	6(a0),curcell
nocst5y:
	bsr	cellx2scr
	bsr	screnswp
	move.b	#$80,matxupd	;force matrix update
nocst6:
csclxxx:
	rts
*
*
*  scroll colors rite 1 place
*
cscrolr:
	movem.l	a0/d0-d4,-(sp)
	move.w	colleft,d0
	move.w	colrite,d1
	moveq	#-2,d2
	bra.s	doscrol
*
*  scroll colors left 1 place
*
cscroll:
	movem.l	a0/d0-d4,-(sp)
	move.w	colrite,d0
	move.w	colleft,d1
	moveq	#2,d2
*
doscrol:
	move.b	#$80,matxupd	;force matrix update
	movea.l	#colorz,a0
	lsl.w	#1,d0
	lsl.w	#1,d1
	move.w	(a0,d1.w),d3
scrolp:
	cmp.w	d0,d1
	beq.s	scrolq
	move.w	d1,d4
	add.w	d2,d1
	move.w	(a0,d1.w),(a0,d4.w)
	bra.s	scrolp
scrolq:
	move.w	d3,(a0,d1.w)
	tst.w	colleft			;check leftmost color
	bne.s	scrolq1			;br if background unchanged
	tst.w	full
	bne.s	scrolq1			;br if full screen
	bsr	back2bot		;else, update phantom bottom row
scrolq1:
	movem.l	(sp)+,a0/d0-d4
	rts
*
*
*  Draw lower half of screen
*  with color pallet, fat-bits matrix
*  and icons & stuff
*
*
* entry:
*  a0 is screen base address
*  d2 is starting ypos
*
* internal usage:
*  d0 is foreground color
*  d1 is xpos
*  d2 is ypos
*
*  d3 is column element count
*  d4 is row count     
*
loadcol:
	movem.w	d0-d1,-(sp)
	move.l	curscren,a0	;clear lower half of current screen
	adda.w	#16000,a0
	moveq	#0,d2
	move.w	#1999,d0
clearlp:
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	dbra	d0,clearlp
*
	moveq	#0,d2			;icon # (little box)
	move.w	#fatblky1,d1		;starting ypos
	move.w	#fatpxlny-1,d4
rowlp:
	move.w	#fatblkx1,d0		;starting xpos
	move.w	#fatpxlnx-1,d5
collp:
	move.w	#fatpxlnx,d3
	sub.w	d5,d3
	bsr	draw			;draw little boxes
	addi.w	#fatpxlw,d0
	dbra	d5,collp
	addi.w	#fatpxlh,d1
	dbra	d4,rowlp
*
*
*  Draw box around fat bits window
*  How big should it be?
*
	movem.w	(sp)+,d0-d1
	movem.w	d0-d1,-(sp)
*
	cmp.w	half,d1		;upper/lower half?
	bcs.s	upper
*
*  in lower region, smaller box is required
*
	bsr	lbigbx		;"little" big box
	move.b	matselx,d0
	sub.b	paltx,d0
	bcs.s	pallet
	cmpi.b	#fatpxlnx,d0
	bcc.s	pallet
	move.b	matsely,d1
	ext.w	d0
	ext.w	d1
	bsr	hotbox
	bra.s	pallet
*
upper:
	bsr	bigbx		;full sized fat bits window
*
	move.w	#targx,d0	;install centered target too
	move.w	#targy,d1
	bsr	hotbox
*
*  Draw pallet bar of 16 color patches..
*
pallet:
	moveq	#1,d2			;icon # (big pallet box)
	move.w	#pallx,d0
	move.w	#pally,d1
	move.w	#15,d4
collp1:
	move.w	#15,d3
	sub.w	d4,d3
	bsr	draw
	add.w	#pallw,d0
	dbra	d4,collp1
*
*  Draw color scrolling controller bar..
*
	moveq	#15,d4		;color #15
	moveq	#0,d5		;replace mode
	moveq	#-1,d6		;line mask
	move.w	#cbarx,d0
	move.w	#cbary,d1
	move.w	#cbarx+78,d2
	move.w	#cbary+14,d3
	bsr	box
	move.w	#cbarx+12,d0
	move.w	d0,d2
	bsr	box
	move.w	#cbarx+66,d0
	move.w	d0,d2
	bsr	box
*
	move.w	#cbarx+80,d0
	move.w	#cbarx+115,d2
	bsr	box			;undo box
*
	move.w	#cbarx+2,d0		;left arrow
	move.w	#cbary+2,d1
	move.w	#23,d2
	move.w	#15,d3
	btst.b	#0,cscrolst+1
	beq.s	ldraw
	bsr	invdraw
	bra.s	ldraw1
ldraw:
	bsr	draw
ldraw1:
*
	move.w	#cbarx+68,d0		;right arrow
	move.w	#cbary+2,d1
	move.w	#24,d2
	btst.b	#1,cscrolst+1
	beq.s	rdraw
	bsr	invdraw
	bra.s	rdraw1
rdraw:
	bsr	draw
rdraw1:
*
	move.w	#cbarx+41,d0
	move.w	#cbary+2,d1
	move.w	#25,d2
	move.w	#14,d3
	bsr	draw			;draw color #14 block
*
*  Draw this function's sub menu
*
	cmpi.b	#4,cpyrite
*	tst.b	cpyrite
	bne.s	nocpyr
	move.b	likesel,d0
	move.b	#15,likesel
	move.w	d0,-(sp)	
	bsr	modedraw		;put up vanity boiler plate
	move.w	(sp)+,d0
	move.b	d0,likesel
*
*  put up new NEOchrome grafic
*
	move.l	#neopaint,a0
	move.l	curscren,a1
	adda.w	#(132*160)+96,a1
	move.w	#$1c,d0
neolp1:
	move.w	#$F,d1
neolp:
	move.l	(a0)+,(a1)+
	dbra	d1,neolp
	adda.w	#160-64,a1
	dbra	d0,neolp1
*
*  end new stuff
*
	bra.s	nomdraw
nocpyr:
	bsr	modedraw		;put up sub menu
nomdraw:
*
*  draw exit box
*
	moveq	#0,d0
	move.w	#iconly-1,d1
	moveq	#16,d2			;icon #16 is exitbox (half screen)
	moveq	#15,d3
	bsr	draw
*
*  draw grid box
*
	moveq	#114,d0
	move.w	#iconly-1,d1
	moveq	#16,d2			;icon #16 is also grid box
	moveq	#15,d3
	moveq	#8,d5			;src x adjust for right half of data
	moveq	#0,d6
	bsr	drawa
*
	tst.b	gridon			;test for grid set
	beq.s	gridoff
	move.l	#$FFFF0008,d5
	move.l	#$FFFE0001,d6
	addq.w	#1,d1
	bsr	invdrawa
gridoff:
	moveq	#15,d4		;color #15
	moveq	#0,d5		;replace mode
*
*  draw left grid of function icons
*
	move.w	#iconly-1,d1		;left grid y origin
	move.w	#iconlh-1,d7		;# of blocks high
gridlp2:
	move.w	#iconlx-1,d0		;left grid x origin
	move.w	#iconlw-1,d6		;# of blocks wide
gridlp3:
	move.w	d6,-(sp)		;save # of horz blocks remaining
	move.w	#$FFFF,d6		;full line mask
	move.w	d0,d2			;set-up bot/right x
	move.w	d1,d3			;set-up bot/right y
	add.w	#iconw,d2		;add width to x
	add.w	#iconh,d3		;add height to y
	bsr	box			;draw a grid box
	move.w	(sp)+,d6		;reget remaining horz blocks
	add.w	#iconw,d0		;move x right by block width
	dbra	d6,gridlp3		;finish this row
*
	add.w	#iconh,d1		;move y down by block height
	dbra	d7,gridlp2		;finish this icon block
*
*  install left icons from icon list
*
	move.w	#iconlx+1,d0
	move.w	#iconly+1,d1
	movea.l	#liconlst,a0
	moveq	#0,d2			;clear upper half of low word
	move.w	#15,d3			;color #15
	move.w	#iconlh-1,d7		;# rows
	ext.l	d7
iconlp2:
	swap	d7
	move.w	d0,-(sp)
	move.w	#iconlw-1,d6		;# columns
iconlp3:
	move.b	(a0)+,d2		;get icon #
	beq.s	skdrw1			;if 0, skip icon draw
	cmp.b	likesel,d7
	beq.s	doinv1	
	bsr	drawq			;draw icon
	bra.s	skdrw1
doinv1:
	bsr	invdrawq		;draw select icon
skdrw1:
	addq.w	#1,d7
	add.w	#iconw,d0
	dbra	d6,iconlp3
*
	move.w	(sp)+,d0
	add.w	#iconh,d1
	swap	d7
	dbra	d7,iconlp2
*
*  put in version #
*
	tst.b	cpyrite
	bpl.s	itsmsg0
	bsr	time3x
	bra.s	itspath
itsmsg0:
	move.l	#msg0,a0		;"ST NEO v.x.yx"
	moveq	#0,d0			;start x position
	move.w	#182,d1			;start y position
	bsr	systxt8			;put up
*
itspath:
	move.l	#neovers,a0		;version #
	moveq	#0,d0			;
	move.w	#194,d1			;
	moveq	#0,d2
	bsr	systxt6			;put up
*
	move.l	#msgundo,a0		;"UNDO"
	move.w	#cbarx+82,d0		;start x position
	move.w	#cbary+4,d1		;start y position
	bsr	systxt8			;put up
*
	bsr	pointcol	;set pointer under currently selected color
	bsr.s	leftpt		;form arrow of left color pallet
	bsr.s	ritept		;ditto right arrow
*
	bsr	setc14		;set-up color14 display
*
	movem.w	(sp)+,d0-d1
	rts
*
*
*  selected op_tab values
*
*	00 03 0C 0F  inverse replace
*	00 0C 03 0F  replace
*	04 04 07 07  transparent
*	06 06 06 06  xor
*	01 0D 01 0D  inverse transparent
*
*  draw left pointer color
*
leftpt:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	colleft,d0
	bne.s	leftpt1
	move.w	#$f,d3
	bra.s	leftpt0
leftpt1:
	move.w	d0,d3
	mulu	#20,d0
	move.w	#101,d1
	move.w	#3,d2			;icon #3
	bra	drawi3			;inverse replace draw
ritept:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	colrite,d0
	bne.s	ritept1
	move.w	#$f,d3
	bra.s	ritept0
ritept1:
	move.w	d0,d3
	mulu	#20,d0
	add.w	#14,d0
	move.w	#101,d1
	move.w	#4,d2			;icon #4
	bra	drawi3			;inverse replace draw
unleftpt:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	colleft,d0
	move.w	d0,d3
	mulu	#20,d0
leftpt0:
	move.w	#101,d1
	move.w	#3,d2			;icon #3
*	lea	p_block,a6		;blit block
*	move.l	#$04040707,op_tab(a6)	;transparent draw
	move.l	#$04040707,d4		;transparent draw
	bra	drawi1
unritept:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	colrite,d0
	move.w	d0,d3
	mulu	#20,d0
ritept0:
	add.w	#14,d0
	move.w	#101,d1
	move.w	#4,d2			;icon #4
*
*	lea	p_block,a6		;blit block
	move.l	#$04040707,d4		;transparent draw
	bra	drawi1
*
*
*  put up pointer under selected color
*
pointcol:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	selctcol,d0
	mulu	#20,d0
	addq.w	#6,d0
	move.w	#110,d1
	move.w	#2,d2
	move.w	#15,d3
	bsr	draw
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*
*  remove pointer under selected color
*
uncolor:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	selctcol,d0
	mulu	#20,d0
	addq.w	#6,d0
	move.w	#110,d1
	move.w	#2,d2
	move.w	#15,d3
	bsr	undraw
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*
*  draw icon enclosed in a square
*
drawq:
	movem.w	d0-d1,-(sp)
	addq.w	#1,d0
	addq.w	#1,d1
	bsr	draw
	movem.w	(sp)+,d0-d1
	move.l	a0,-(sp)
	movem.w	d2-d6,-(sp)
	move.w	#0,d4		;color set
	bra.s	qbox
*
*
*	
invdrawq:
	movem.w	d0-d1,-(sp)
	addq.w	#1,d0
	addq.w	#1,d1
	bsr.s	invdraw
	movem.w	(sp)+,d0-d1
	move.l	a0,-(sp)
	movem.w	d2-d6,-(sp)
	move.w	#15,d4		;color set
qbox:
	move.w	#0,d5
	move.w	#-1,d6
	movea.l	#p_block,a0
	move.w	d0,d2
	move.w	d1,d3
	add.w	b_width(a0),d2
	add.w	b_height(a0),d3
	addq.w	#1,d2
	addq.w	#1,d3
	bsr	box
	movem.w	(sp)+,d2-d6
	move.l	(sp)+,a0
	rts
*
*  Draw/invdraw an icon allowing source x offset & width adjust
*
*  d5 = [15:00] src x offset
*  d5 = [31:16] src x width adjust (signed 2's compliment)
*  d6 = [15:00] src y offset
*  d6 = [31:16] src y height adjust (signed 2's compliment)
*
invdrawa:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$00030C0F,d4		;inverse replace draw
	bra.s	drawi4
drawa:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$000C030F,d4		;replace draw
	bra.s	drawi4
*
*
*  Draw/undraw/inverse draw an icon
*
*  d0 = x position
*  d1 = y position
*  d2 = icon #
*  d3 = color
*
undraw:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$000C030F,d4		;replace draw
	moveq	#0,d3
*
*	lea	p_block,a6		;blit block
*	move.l	#$000C030F,op_tab(a6)	;replace draw
*	move.w	#0,fg_col(a6)
	bra.s	drawi2
invdraw:
	movem.l	d0-d7/a0-a6,-(sp)
drawi3:
*	lea	p_block,a6		;blit block
*	move.l	#$00030C0F,op_tab(a6)	;inverse replace draw
	move.l	#$00030C0F,d4		;inverse replace draw
	bra.s	drawi1
draw:
	movem.l	d0-d7/a0-a6,-(sp)
*	lea	p_block,a6		;blit block
*	move.l	#$000C030F,op_tab(a6)	;replace draw
	move.l	#$000C030F,d4		;replace draw
drawi1:
drawi2:
	moveq	#0,d5
	moveq	#0,d6
drawi4:
	lea	p_block,a6		;blit block
	move.l	d4,op_tab(a6)
	move.w	d3,fg_col(a6)
	clr.w	bg_col(a6)
	move.w	d5,s_xmin(a6)
	move.w	d6,s_ymin(a6)
	swap	d5
	swap	d6
	lea	iconlist,a0
	lsl.w	#1,d2
	move.w	(a0,d2.w),d2
	lea	icons,a0
	lea	4(a0,d2.w),a0
	move.l	a0,s_form(a6)
	add.w	-4(a0),d5
	move.w	d5,b_width(a6)
	add.w	#15,d5
	lsr.w	#4,d5
	lsl.w	#1,d5
	move.w	#2,s_nxwd(a6)
	move.w	d5,s_nxln(a6)
	clr.w	s_nxpl(a6)
	move.w	#4,plane_ct(a6)
	add.w	-2(a0),d6
	move.w	d6,b_height(a6)
	move.l	curscren,d_form(a6)
	move.w	d0,d_xmin(a6)
	move.w	d1,d_ymin(a6)
	move.w	#8,d_nxwd(a6)
	move.w	#160,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
	.dc.w	bitblt
	movem.l	(sp)+,d0-d7/a0-a6
	rts
*
*
*
*  switch logical screen to othscren
*
logioth:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	#-1,-(sp)	;change logical screen to othscren
	move.l	#-1,-(sp)
	move.l	othscren,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
*
*  change logical screen to curscren..
*
logicur:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	#-1,-(sp)	;change logical screen back to current
	move.l	#-1,-(sp)
	move.l	curscren,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*   Snap cursor to grid point
*
*   cursor assumed to be in hidden state
*
snapto:
	tst.b	gridon			;is grid on?
	beq	snapq			;br to exit if not
	movem.l	a0-a6/d0-d7,-(sp)
	.dc.w	$a000
	lea	-602(a0),a0
	move.w	(a0)+,d0		;get xpos
	move.w	(a0),d1			;get ypos
	cmp.w	half,d1			;within gridded area?
	bge.s	snap2			;br to exit if not
*
	move.w	virhandy,d3		;new virtual canvas stuff
*	moveq	#0,d3
	cmpi.w	#100,half
	bne.s	nhndyadj
	add.w	handy,d3
nhndyadj:
	add.w	d3,d1
	move.w	virhandx,d4
	add.w	d4,d0		;vir can again
	addq.w	#4,d0
	addq.w	#4,d1
	moveq	#$f8,d2
	and.w	d2,d0
	and.w	d2,d1
	sub.w	d3,d1
	sub.w	d4,d0
	bpl.s	snap3
	addq.w	#8,d0
snap3:
	cmp.w	#320,d0
	blt.s	snap0
	subq.w	#8,d0
snap0:
	cmp.w	half,d1
	blt.s	snap1
	subq.w	#8,d1
snap1:
	move.w	d1,(a0)			;put back massaged values
	move.w	d0,-(a0)
	move.w	d0,xpos
	move.w	d1,ypos
	move.w	d0,oldmx
	move.w	d1,oldmy
	clr.b	xaccum
	clr.b	yaccum
snap2:
	movem.l	(sp)+,a0-a6/d0-d7
snapq:
	rts

*
**********************************************
*
*  Mouse button routine
*
button:
	tst.w	genabl			;is GEM "enabled"?
	bne.s	gemok			;br if enabled
	rts				;kill GEM's mouse buttons
gemok:
	.dc.w	$4ef9			;jmp abs
oldbuttn:
	.dc.l	0
*
*
**********************************************
*
*  Mouse irq-like routine
*
mouse:
	tst.b	gridon
	beq	normous
*
*  d0.w is new x-position
*  d1.w is new y_position
*
*  Check previous ypos for upper or lower half of split screen
*
	move.w	d1,-(sp)	;save new ypos on stack
	move.w	half,d1		;get half point (100 or 200)
	cmp.w	ypos,d1		;prev ypos in grid half of half screen?
	bgt.s	grid04		;br if so
	move.w	(sp)+,d1
*
*  previous cursor was on menu (lower) part
*
	cmp.w	half,d1		;check for moving to upper
	blt.s	ysnap		;br to snap on if in upper now
*
*  still in lower
*
	tst.b	reqgrdq		;grid exit request made?
	beq	grid00		;br if no
	btst.b	#0,reqgrdq	;request made: mouseget grant request?
	bne.s	grid04x		;br to gridding if request not granted
	clr.b	reqgrdq		;clear request pending
	bra	grid00		;br to non-gridded lower half screen
*
*  need to snap on to current canvass
*
ysnap:
	move.w	handy,d1	;y offset indicates alignment
	add.w	virhandy,d1
	andi.w	#7,d1
	move.b	linetab(pc,d1.w),d1
	add.w	virhandx,d0
	addq.w	#4,d0
	andi.w	#$FFF8,d0
	sub.w	virhandx,d0
	bpl.s	ysnap1
	addq.w	#8,d0
ysnap1:
	cmpi.w	#320,d0
	blt.s	grid00x
	subq.w	#8,d0
grid00x:
	move.w	d0,oldmx
	bra.s	grid00
*
*
linetab:
	.dc.b	96,95,94,93,92,99,98,97
*
grid04:
	move.w	(sp)+,d1	;get raw new ypos from stack
grid04x:
	sub.w	ypos,d1		;d1 is new delta (+ for down, - for up) 
	bmi.s	grid01		;br to check neg abs value
	cmpi.w	#1,d1		;greater than 1 click (moving fast)
	bgt.s	grid02		;br if so
	bra.s	grid03
*
grid01:
	cmpi.w	#-1,d1
	bge.s	grid03
grid02:
	lsl.w	#2,d1		;multiply by 4 if fast
grid03:
	add.b	d1,yaccum	;add to y accumulator
*
*  now check to turn off grid if below half screen
*
	cmpi.w	#100,half
	bne.s	normy		;br if not in half screen mode
	move.b	yaccum,d1
	ext.w	d1
	asr.w	#2,d1
	add.w	ypos,d1
	cmp.w	half,d1
	blt.s	normy
	move.b	#3,reqgrdq	;request from mouseget to exit grid
	bra.s	normy	
grid00:
	clr.b	yaccum
	clr.b	xaccum
	bra	mousex
normy:
	move.w	ypos,d1
	cmpi.b	#32,yaccum
	blt.s	chkup
	sub.b	#32,yaccum
	addq.w	#8,d1
	bra.s	grid4
chkup:
	cmpi.b	#-32,yaccum
	bgt.s	grid4
	add.b	#32,yaccum
	subq.w	#8,d1
grid4:
	tst.w	d1
	bpl.s	grid5
	addq.w	#8,d1
	bra.s	grid6
grid5:
	cmpi.w	#200,d1
	blt.s	grid7
	subq.w	#8,d1
grid6:
	clr.b	yaccum
grid7:
	move.w	d1,ypos
*
*  do x now
*
	sub.w	xpos,d0		;d0 is new delta (+ for right, - for left)
	bmi.s	grid05		;br to check neg abs value
	cmpi.w	#1,d0		;greater than 1 click (moving fast)
	bgt.s	grid06		;br if so
	bra.s	grid07
*
grid05:
	cmpi.w	#-1,d0
	bge.s	grid07
grid06:
	lsl.w	#2,d0		;multiply by 4 if fast
grid07:
	add.b	d0,xaccum	;add to x accumulator
	move.w	xpos,d0
	cmpi.b	#32,xaccum
	blt.s	chklft
	sub.b	#32,xaccum
	addq.w	#8,d0
	bra.s	grid0
chklft:
	cmpi.b	#-32,xaccum
	bgt.s	grid0
	add.b	#32,xaccum
	subq.w	#8,d0
grid0:
	tst.w	d0
	bpl.s	grid1
	addq.w	#8,d0
	bra.s	grid2
grid1:
	cmpi.w	#320,d0
	blt.s	grid3
	subq.w	#8,d0
grid2:
	clr.b	xaccum
grid3:
	move.w	d0,xpos
	bra	mousei	
*
normous:
	tst.w	henabl
	beq	mousex
hena:
	tst.w	mousped
	beq	mousei
*
*  exchange mouse movement vector routine--slow...
*
*  d0.w is new x-position
*  d1.w is new y_position
*
thresh	equ	4
*
mouses:
	movem.l	d0-d1,-(sp)
	sub.w	xpos,d0			;subtract old x from new
	bcc.s	nonneg			;br if new >= old, (moving right)
*
	cmpi.w	#-1,d0			;moving left more than 1?
	bcs	fast			;br if so, skip slow down
*
	tst.b	xaccum			;accumulatin' left values?
	bmi.s	nowneg			;br if so
	move.b	#$81,xaccum		;else, start up new left accum
	bra.s	doy			;go do ypos
nowneg:
	addq.b	#1,xaccum		;add 1 to left accum
	cmpi.b	#$80+thresh,xaccum	;reached threshold yet?
	bne.s	doy			;br if not
*
*  reached left threshold, advance position
*
	move.b	#$80,xaccum		;clear left accumulator
	subq.w	#1,xpos			;decrement left position
	bpl.s	doy			;do ypos
	move.w	#0,xpos
	bra.s	doy
*
*  moving right..
*
nonneg:
	beq.s	doy			;br if no change, do ypos
	cmpi.w	#2,d0			;2 or more
	bcc	fast			;if movin' fast, use normal values
	tst.b	xaccum			;check for right accum
	bpl.s	nowpos			;br if already right
	move.b	#1,xaccum		;else, set for right
	bra.s	doy			;do ypos
nowpos:
	addq.b	#1,xaccum		;add 1 to accum
	cmpi.b	#thresh,xaccum		;reached threshhold yet?
	bne.s	doy			;br if not, do ypos
*
*  reached right threshold, advance position 1 right
*
	move.b	#0,xaccum		;clear right accumulator
	addq.w	#1,xpos			;move right a notch
*
*  now check y-coordinate stuff..
*
doy:
	sub.w	ypos,d1
	bcc.s	nonneg1
	cmpi.w	#-1,d1
	bcs	fast
*
	tst.b	yaccum
	bmi.s	nowneg1
	move.b	#$81,yaccum
	bra.s	dout
nowneg1:
	addq.b	#1,yaccum
	cmpi.b	#$80+thresh,yaccum
	bne.s	dout
	move.b	#$80,yaccum
	subq.w	#1,ypos
	bpl.s	dout
	move.w	#0,ypos
	bra.s	dout
nonneg1:
	beq.s	dout
	cmpi.w	#2,d1
	bcc.s	fast
	tst.b	yaccum
	bpl.s	nowpos1
	move.b	#1,yaccum
	bra.s	dout
nowpos1:
	addq.b	#1,yaccum
	cmpi.b	#thresh,yaccum
	bne.s	dout
	move.b	#0,yaccum
	addq.w	#1,ypos
dout:
	addq.w	#8,sp
	move.w	xpos,d0
	move.w	ypos,d1
mousei:
	cmpi.w	#320,d0
	bcs.s	xok
	move.w	#319,d0
xok:
mousex:
	move.w	d0,xpos
	move.w	d1,ypos
	.dc.w	$4EF9		;jmp abs
oldmouse:
	.dc.l	rtsi
fast:
	movem.l	(sp)+,d0-d1
	bra.s	mousei
*
*  d0 -> alert string
*
alertout:
*
	move.w	#1,int_in+0
	move.l	d0,addr_in
*
	move.w	#122,contrl+0		;show cursor
	clr.w	intin
	move.w	#1,contrl+6
	bsr	vdicall
*
	bsr	form_alr
*
rtsi:
	rts
*
midi:
	move.w	irqlev,sr
	.dc.w	%0100111011111001	;jmp abs.l
keysav:
	.dc.l	0	
*
*  timer c
*
lowc:
	move.w	irqlev,sr
	.dc.w	%0100111011111001	;jmp abs.l
timrcsav:
	.dc.l	0	
*
*  timer c differed
*
tcdif:
	tst.w	henabl			;h-blank irq in operation?
	beq.s	dotcdif			;if not, do normal differed
	rts
dotcdif:
	.dc.w	%0100111011111001	;jmp abs.l
tcdifsav:
	.dc.l	0
	
******************************************
*
*  Horz blank interrupt routine
*
hblk:
	move.b	#0,tbcr			;stop timer
verify1:
	move.b	#fatpxlh,tbdr		;# lines each interrupt
	cmpi.b	#fatpxlh,tbdr		;# lines set?
	bne.s	verify1
	move.b	#8,tbcr			;set for event count mode
*
*	move.w	#fatpxlny,rowz
	move.w	#3,rowz
	move.l	#hblk1,hblkcv.l
	movem.l	d0-d1,-(sp)
	moveq	#-1,d1
	mulu	d1,d0
	mulu	d1,d0
	mulu	d1,d0
	mulu	d1,d0
	move.w	hpalet,d0
	eor.w	d1,d0
	move.w	d0,hpalet+30
	move.w	color14,hpalet+28
	movem.l	(sp)+,d0-d1
	bclr.b	#0,isra
	rte
*
*
*
hblk1:
*				;44	44
	movem.l	a0-a1,-(sp)	;24	68
	movea.l	#hpalet+2,a0	;12	80
	movea.l	curcol,a1	;20	100
*
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.w	(a1)+,(a0)+	;20	240
*
	move.l	a1,curcol	;20	260
	subq.w	#1,rowz
	bmi.s	hblke
	movem.l	(sp)+,a0-a1	;28	328
hblknull:
	bclr.b	#0,isra		;12	340
	rte			;20	360
*
hblke:
	move.w	altcol14,(a0)
	move.w	#fatpxlny-3,rowz
	move.l	#hblk2,hblkcv.l
*
	movem.l	(sp)+,a0-a1	;28	328
	bclr.b	#0,isra		;12	340
	rte			;20	360
*
*
*
hblk2:
*				;44	44
	movem.l	a0-a1,-(sp)	;24	68
	movea.l	#hpalet+2,a0	;12	80
	movea.l	curcol,a1	;20	100
*
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.l	(a1)+,(a0)+	;20
	move.w	(a1)+,(a0)+	;20	240
*
	move.l	a1,curcol	;20	260
	subq.w	#1,rowz
	bmi.s	hblke2
	movem.l	(sp)+,a0-a1	;28	328
	bclr.b	#0,isra		;12	340
	rte			;20	360
*
hblke2:
	move.b	#0,tbcr			;stop timer
*
	movem.l	(sp)+,a0-a1	;28	328
	bclr.b	#0,isra		;12	340
	rte			;20	360
*
hblksav:
	.dc.l	0
*
*
********************************************
*
*  Vertical blank interrupt routine
*
vblk:
	movem.l	a0-a1,-(sp)
	movea.l	curpalt,a1
	movea.l	#hpalet,a0
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
*
	addq.w	#1,frmcnt
*
	tst.b	doubtiml
	bpl.s	notimel
	addq.b	#1,doubtiml
notimel:
	tst.b	doubtimr
	bpl.s	notimer
	addq.b	#1,doubtimr
notimer:
	movem.l	(sp)+,a0-a1
*
	move.l	#palt,curcol
*
	move.b	#0,tbcr			;stop timer
	tst.w	henabl
	bne.s	dohb
	move.l	#hblknull,hblkcv.l
	bra.s	vblk1
dohb:
	move.l	#hblk,hblkcv.l
*
verify:
	move.b	#109,tbdr		;# lines each interrupt
	cmpi.b	#109,tbdr		;# lines set?
	bne.s	verify
*
	move.b	#8,tbcr			;set for event count mode
*
vblk1:
*
	.dc.w	%0100111011111001	;jmp abs.l
vblksav:
	.dc.l	$FC11A6			;vblank vector
*
*
evnt_mul:
	lea	evntmul(pc),a1
	bra.s	doaes
objc_drw:
	lea	objcdrw(pc),a1
	bra.s	doaes
form_do:
	lea	formdo(pc),a1
	bra.s	doaes
form_alr:
	lea	formalr(pc),a1
	bra.s	doaes
graf_mou:
	lea	grafmou(pc),a1
	bra.s	doaes
fsel_inp:
	lea	filesel(pc),a1
	bra.s	doaes
appl_int:
	lea	apple(pc),a1
	bra.s	doaes
graf_hdl:
	lea	grhand(pc),a1
	bra.s	doaes
appl_ext:
	lea	applx(pc),a1
doaes:
	lea	control,a0
	move.w	#4,d0
appl_lp1:
	move.w	(a1)+,(a0)+
	dbra	d0,appl_lp1
*
	move.w	#-1,genabl		;enable GEM (mouse buttons)
	move.w	#200,d0
	move.l	#aes_pb,d1
	trap	#2
	clr.w	genabl			;disable GEM (no buttons get thru)
	rts
*
*************************
*  non-modified data	*
*************************
*
*
*
apple:
	.dc.w	10,0,1,0,0
grhand:
	.dc.w	77,0,5,0,0
applx:
	.dc.w	19,0,1,0,0
filesel:
	.dc.w	90,0,2,2,0
grafmou:
	.dc.w	78,1,1,1,0
formalr:
	.dc.w	52,1,1,1,0
formdo:
	.dc.w	50,1,1,1,0
objcdrw:
	.dc.w	42,6,1,1,0
evntmul:
	.dc.w	25,16,7,1,0
*
*  
msg0:
	.dc.b	"NEOchrome "
neovers:
	.dc.b	"v0.9h",0
msgundo:
	.dc.b	"UNDO",0
msgcnbr:
	.dc.b	"000",0
*
*  modifiable initialized data
*                                                
	.data
conchar:
	.dc.l	0	;contents of d0 after conin call (0 if none)
csped:
	.dc.w	20	;frames till next color scroll
cscrolst:
	.dc.w	0	;d0 - scroll left, d1 - scroll rite (continuous)
mousped:
	.dc.w	0	;0 = normal speed
irqlev:
	.dc.w	$2600	;IPL for timer C & mouse ($2600 normal)
curpalt:
	.dc.l	paletsav	;current pallet ptr (used each v-blank)
half:
	.dc.w	100	;# of line where cursor changes
selctcol:
	.dc.w	1	;currently selected color (0-15)
colleft:
	.dc.w	1	;left point color
colrite:
	.dc.w	14	;right point color
oldmx:
	.dc.w	0	;previous mouse x position
oldmy:
	.dc.w	0	;previous mouse y
oldmbut:
	.dc.w	0	;prev buttons
*
*
txtcelht:
	.dc.w	6	;text cell height (for text mode cursor)
textalin:
	.dc.w	0	;text alignment (0-left, 1-center, 2-right)
textstyl:
	.dc.w	0	;bits0-4, respectively..thick,lite,skew,under,outline
textsize:
	.dc.w	4	;4-6x6; 6-8x8; 13-8x16
*
*
*  single byte ram allocation..
*
doubtiml:
	.dc.b	0	;double click timer, left (minus if active)
doubtimr:
	.dc.b	0	;double click timer, right (minus if active)
xaccum:
	.dc.b	0
yaccum:
	.dc.b	0
updown:
	.dc.b	0	;d0-in upper half; d1-need matrix/cursor change
matxupd:
	.dc.b	0	;0 if no matrix update (else, neg)
curstate:
	.dc.b	0	;b1 set if cursor flash, b0:1-color15,0-color0 
reqgrdq:
	.dc.b	0	;b1:set if irq requests grid exit; b0:clr if mouseget
*			    grants request (for upper to lower grid transits)
constran:
	.dc.b	0	;0=off, b7-set if wait for 2nd sample
*	 lower bits: 1-horz; 2-vert; 3-diag, +1 slope; 4-diag, -1 slope	 
*
rezstat:
	.dc.b	0	;bit 0 set if rezset not yet cleared by rezclr
*
*
	.bss
	.even
*
strainx:
	.ds.w	1		;constrain start xpos
strainy:
	.ds.w	1		;constrain start ypos
ostrainx:
	.ds.w	1		;previous constrain xpos
ostrainy:
	.ds.w	1		;previous constrain ypos
*
frmcnt:
	.ds.w	1	;frame counter
oldfrm:
	.ds.w	1	;frame counter at last color update
antfrm:
	.ds.w	1	;frame counter at last crawling ant update
anifrm:
	.ds.w	1	;frame counter at last animate state change
cursfrm:
	.ds.w	1	;frame counter at last flashing text cursor update
p_block:
	.ds.w	38	;bit blt parameter block
originx:
	.ds.w	1	;copy box top/left x
originy:
	.ds.w	1	;copy box top/left y
diagx:
	.ds.w	1	;copy box bot/right x
diagy:
	.ds.w	1	;copy box bot/right y
lftmsk:
	.ds.w	1	;temp left mask used by matrix 
henabl:
	.ds.w	1	;h-blank enable (non-zero enables)
genabl:
	.ds.w	1	;GEM enable (non-zero enables)
xpos:
	.ds.w	1	;mouse movement routine previous x position
ypos:
	.ds.w	1	;previous y position
textx:
	.ds.w	1	;current x position of text cursor
texty:
	.ds.w	1
temp0:
	.ds.w	1	;temp used by matrix, loadcol
rowz:
	.ds.w	1	;h-blank irq row count
curcol:
	.ds.l	1	;current color ptr for h-blank routine
color14:
	.ds.w	1	;color value selected for mixer box
altcol14:
	.ds.w	1	;color 14 below mixer box
gridtemp:
	.ds.w	1	;(used as .b) save grid state here when in rezset
palt:
	.ds.w	13*17	;pallet used in matrix, not in fat module

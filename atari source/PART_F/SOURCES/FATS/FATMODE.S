*****************************************
*					*
*  Submode Selection Handling		*
*  & Submode Tableau Drawing		*
*					*
*****************************************
*
*
*
*	Last update: 24 Jul 86
*
*
	.include	"fatequ.s"
*
*
	.globl	linethik,lindthik,hollow,shapesel,outlin
	.globl	rethik,relthik,chg2cur,edgemsk,liconlst
	.globl	swapclr,colleft,colrite,selctcol,vflip,hflip
	.globl	showm,hidem,bigram,fg_col,bg_col,cpyafunc,funky,funkydo
	.globl	jktxtad,xyplot,gridon,xaccum,yaccum,touch
*
	.globl	scalemd,clrstrch,initscal,jack_mas,jackant,shrink2f
	.globl	newjack1
*
	.globl	textsize,textalin,textstyl
	.globl	cbarx,cbary,textset
	.globl	drawq,invdrawq,draw,undraw,invdraw
	.globl	likesel,newtxtmd
	.globl	box,style,shwboxz,anistat,aoriginx,aoriginy,adiagx,adiagy
	.globl	curcell,cellwid,cellhite,cel2scr,cellx2scr,scr2cell,needothr
	.globl	contrl,intin,vdicall,ptsin,systxt6i,systxt6,systxt8
	.globl	cellsize,anibase,aninext,aniend,scr02scr,anisped,cel2phys
*
	.globl	gemready,rezset,int_in,graf_mou,int_out,addr_in,fsel_inp
	.globl	txstring,rezclr,henabl,irqlev,newbox
*
	.globl	animupd,holdptr,cpytxtd,invanibk,setanitx,anifitx,aniloadd
*
	.globl	screen0,cutscren,othscren,physadd,cpyscren
	.globl	monomask,cpysrc,copystat,boxsrcx,boxsrcy,boxhite,boxwidth
	.globl	originx,originy,othrorgx,othrorgy,handy,undoyet,unundo
	.globl	p_block,plane_ct,op_tab,d_form,diagx,diagy,full
	.globl	d_nxwd,d_nxln,d_nxpl,d_xmin,d_ymin,jackstat
	.globl	screnswp,stamp,bitblt,updtxts,putcpytx
*
	.globl	alertout,dskalrt0,dskalrt2,undopalt,back2bot
*
	.globl	b_width,b_height,s_xmin,s_ymin,s_nxwd,s_nxln,s_nxpl
	.globl	blitmask,s_form,cutwidth,cuthite,cutx,cuty
*
	.globl	unlineht,unlinetk
*
	.globl	modedraw,modeupd,othsame
	.globl	destx,fillbox,curscren
	.globl	brshform,iconlist,icons,blitmode,jackmode,brshptr
	.globl	clright,mouseget,cscrlupd,frmcnt,lastfrm,movebox,clrneo
	.globl	textadj
*
	.globl	animtxts,putanitx
*
	.globl	jreptran,jktxtd,invblock,cutfrm,copyicon,setstrch
	.globl	reptrans
	.globl	jknfupd,cpybupd
*
	.globl	drawlayo,grafptrs
*
	.globl	colorz
*
***************************************
*
*
*  Clear out fancy NEOchrome grafix
*
clrneo:
	movem.l	a0/d5-d7,-(sp)
	move.w	#30,d7
	bra.s	clrntry
*
*  clear right side submode tableau space..
*
clright:
	movem.l	a0/d5-d7,-(sp)
	move.w	#69,d7
clrntry:
	movea.l	curscren,a0		;clear right side
	adda.w	#20896,a0		;  mode draw area
	moveq	#0,d5
clrlp1:
	move.w	#7,d6
clrlp2:
	move.l	d5,(a0)+
	move.l	d5,(a0)+
	dbra	d6,clrlp2
	adda.w	#96,a0
	dbra	d7,clrlp1
	movem.l	(sp)+,a0/d5-d7
	rts
*
*
*  This routine draws the submode tableau
*  for the current tool..
*
*
modedraw:
	bsr	clright			;clear right side
*
*  Area is clear, draw boxes, icons & text associated with function
*
	move.b	likesel,d5
	ext.w	d5
	mulu	#5*2,d5
	move.l	#grafptrs,a4
	adda.w	d5,a4
	bsr	drawlayo		;draw layout
*
*  now, do any mode specific inits and return to caller
*
	move.b	likesel,d5
	ext.w	d5
	lsl.w	#1,d5
	movea.l	#fi,a0
	adda.w	modelist(pc,d5.w),a0
	jmp	(a0)			;do function specific inits
*
*  list of tableaus
*
modelist:
	.dc.w	jknfmode-fi	;0-jack knife
	.dc.w	handmode-fi	;1-hand
*	.dc.w	stubmode-fi	;1-hand
	.dc.w	copymode-fi	;2-copybox
	.dc.w	textmode-fi	;3-text
	.dc.w	stubmode-fi	;4-pencil
*
	.dc.w	lindmode-fi	;5-linedraw
	.dc.w	stubmode-fi	;6-fillbucket
	.dc.w	bltnmode-fi	;7-
	.dc.w	miscmode-fi	;8-miscellany
	.dc.w	brshmode-fi	;9-brush
*
	.dc.w	stubmode-fi	;A-diskette
	.dc.w	animode-fi	;B-animation
	.dc.w	shapmode-fi	;C-shapes
	.dc.w	erasmode-fi	;D-erase
	.dc.w	sprymode-fi	;E-spray can
*
	.dc.w	stubmode-fi	;F-dummy mode
*
*  Submode Draw routine for text
*
*
grafptrs:
	.dc.w	jackfill-gp	;fill boxes	function #0 (jack knife)
	.dc.w	jackopen-gp	;open boxes
	.dc.w	jacktxtd-gp	;text data
	.dc.w	jacktxts-gp	;text strings
	.dc.w	jackicon-gp	;icons
*
	.dc.w	handfill-gp	;fill boxes	function #1 (hand)
	.dc.w	handopen-gp	;open boxes
	.dc.w	handtxtd-gp	;text data
	.dc.w	handtxts-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
	.dc.w	copyfill-gp	;fill boxes	function #2 (copybox)
	.dc.w	copyopen-gp	;open boxes
	.dc.w	copytxtd-gp	;text data
	.dc.w	copytxts-gp	;text strings
	.dc.w	copyicon-gp	;icons
*
	.dc.w	textfill-gp	;fill boxes	function #3 (text)
	.dc.w	textopen-gp	;open boxes
	.dc.w	texttxtd-gp	;text data
	.dc.w	texttxts-gp	;text strings
	.dc.w	texticon-gp	;icons
*
	.dc.w	pencfill-gp	;fill boxes	function #4 (pencil)
	.dc.w	openstub-gp	;open boxes
	.dc.w	penctxtd-gp	;text data
	.dc.w	penctxts-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
*
	.dc.w	lindfill-gp	;fill boxes	function #5 (line draw)
	.dc.w	lindopen-gp	;open boxes
	.dc.w	lindtxtd-gp	;text data
	.dc.w	lindtxts-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
	.dc.w	fillfill-gp	;fill boxes	function #6 (fillbucket)
	.dc.w	openstub-gp	;open boxes
	.dc.w	filltxtd-gp	;text data
	.dc.w	filltxts-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
	.dc.w	fillstub-gp	;fill boxes	function #7
	.dc.w	openstub-gp	;open boxes
	.dc.w	txtdstub-gp	;text data
	.dc.w	txtsstub-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
	.dc.w	miscfill-gp	;fill boxes	function #8 (miscellany)
	.dc.w	miscopen-gp	;open boxes
	.dc.w	misctxtd-gp	;text data
	.dc.w	misctxts-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
	.dc.w	brshfill-gp	;fill boxes	function #9 (brush)
	.dc.w	brshopen-gp	;open boxes
	.dc.w	brshtxtd-gp	;text data
	.dc.w	brshtxts-gp	;text strings
	.dc.w	brshicon-gp	;icons
*
*
	.dc.w	fillstub-gp	;fill boxes	function #10 (diskette)
	.dc.w	openstub-gp	;open boxes
	.dc.w	txtdstub-gp	;text data
	.dc.w	txtsstub-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
	.dc.w	anifill-gp	;fill boxes	function #11 (animate)
	.dc.w	aniopen-gp	;open boxes
	.dc.w	anitxtd-gp	;text data
	.dc.w	anitxts-gp	;text strings
	.dc.w	aniicon-gp	;icons
*
	.dc.w	shapfill-gp	;fill boxes	function #12 (shapes)
	.dc.w	shapopen-gp	;open boxes
	.dc.w	shaptxtd-gp	;text data
	.dc.w	shaptxts-gp	;text strings
	.dc.w	shapicon-gp	;icons
*
	.dc.w	erasfill-gp	;fill boxes	function #13 (eraser)
	.dc.w	openstub-gp	;open boxes
	.dc.w	erastxtd-gp	;text data
	.dc.w	erastxts-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
	.dc.w	brshfill-gp	;fill boxes	function #14 (spray can)
	.dc.w	brshopen-gp	;open boxes
	.dc.w	brshtxtd-gp	;text data
	.dc.w	sprytxts-gp	;text strings
	.dc.w	brshicon-gp	;icons
*
	.dc.w	fillstub-gp	;fill boxes	boiler plate function #"15"
	.dc.w	titlopen-gp	;open boxes
	.dc.w	titltxtd-gp	;text data
	.dc.w	titltxts-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
	.dc.w	fillstub-gp	;fill boxes	jim & jerome vanity #"16"
	.dc.w	openstub-gp	;open boxes
	.dc.w	jjtxtd-gp	;text data
	.dc.w	jjtxts-gp	;text strings
	.dc.w	iconstub-gp	;icons
*
*
*  draw a4 -> layout
*
drawlayo:
	movem.l	a0-a1/d0-d7,-(sp)
*
	movea.l	#gp,a0
	adda.w	0(a4),a0
*	movea.l	#fillbtab,a0	;ptr to fill box data table
	moveq	#15,d4		;use color #15
	moveq	#1,d5		;replace mode
fbloop:
	move.w	(a0)+,d0	;get top/left x
	bmi.s	tsub1		;br to exit if negative terminator
	move.w	(a0)+,d1	;get top/left y
	move.w	(a0)+,d2	;get bot/rite x
	move.w	(a0)+,d3	;get bot/rite y
	bsr	fillbox		;draw filled box
	bra.s	fbloop		;do all until terminator
*
*  draw open boxes..
*
tsub1:
	moveq	#0,d5		;replace mode
	moveq	#-1,d6		;line mask for line draw
	movea.l	#gp,a0
	adda.w	2(a4),a0
*	movea.l	#openbtab,a0	;ptr to open box data table
obloop:
	move.w	(a0)+,d0	;get top/left x
	bmi.s	tsub2		;br to exit if negative terminator
	move.w	(a0)+,d1	;get top/left y
	move.w	(a0)+,d2	;get bot/rite x
	move.w	(a0)+,d3	;get bot/rite y
	bsr	box
	bra.s	obloop
tsub2:
*
*  Now do text strings
*
	move.w	#6,unlineht	;underline height
	move.w	#1,unlinetk	;underline thickness
*
	movea.l	#gp,a0
	move.l	a0,a3
	adda.w	4(a4),a3	;get string data ptr
	adda.w	6(a4),a0	;get string proper ptr
txtstrlp:
	move.w	(a3)+,d2
	bmi.s	tsub3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	bsr	systxt6i
	bra.s	txtstrlp
tsub3:
	movea.l	#gp,a0
	adda.w	8(a4),a0	;get icon table ptr
gagei:
	move.w	#15,d3		;system color
ikeloop:
	move.w	(a0)+,d2	;get icon #
	bmi.s	tsub4		;br to exit if negative terminator
	move.w	(a0)+,d0	;get top/left y
	move.w	(a0)+,d1	;get bot/rite x
	addq.w	#1,d0
	addq.w	#1,d1
	bsr	draw
	bra.s	ikeloop
tsub4:
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
reshape:
	movem.l	a0-a1/d0-d7,-(sp)
	lea	shpicon(pc),a0
	bra.s	gagei
*
*  re-draw copybox submode text with new styles
*
putcpytx:
	tst.w	full
	bne.s	putcpyti
	movem.l	a0-a3/d0-d7,-(sp)
	movea.l	curscren,a0
	adda.w	#22816-160,a0
	moveq	#0,d0
	move.l	#$ff00ff00,d3
	moveq	#55,d1
txclrlp:
	and.l	d3,(a0)+
	and.l	d3,(a0)+
*
	move.l	d0,(a0)+
	move.l	d0,(a0)+
*
	move.l	d0,(a0)+
	move.l	d0,(a0)+
*
	move.l	d0,(a0)+
	move.l	d0,(a0)+
*
	move.l	d0,(a0)+
	move.l	d0,(a0)+
*
	adda.w	#160-40,a0
	dbra	d1,txclrlp
*
	movea.l	#cpytxtd,a3
	movea.l	#cpytxts,a0
	tst.b	likesel
	bne.s	cpystrlp
	movea.l	#jktxtd,a3
	movea.l	#jktxts,a0
cpystrlp:
	move.w	(a3)+,d2
	bmi.s	cpystr1
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	bsr	systxt6
	bra.s	cpystrlp
cpystr1:
	bsr	othsame
	movem.l	(sp)+,a0-a3/d0-d7
putcpyti:
	rts
*
*  Re-draw animate submode number strings..
*
putanitx:
	movem.l	a0-a3/d0-d7,-(sp)
	movea.l	#animtxtd,a3
	movea.l	#animtxts,a0
anistrlp:
	move.w	(a3)+,d2
	bmi.s	anistr1
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	bsr	systxt6
	bra.s	anistrlp
anistr1:
	bsr	othsame
	movem.l	(sp)+,a0-a3/d0-d7
	rts
*
*  Re-draw animate file strings
*
anifitx:
	movem.l	a0-a3/d0-d7,-(sp)
	movea.l	#aniloadd,a3
	movea.l	#aniloads,a0
	move.w	(a3)+,d2
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	bsr	systxt6
	move.w	(a3)+,d2
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	bsr	systxt6
	bsr	othsame
	movem.l	(sp)+,a0-a3/d0-d7
	rts
*
*
newsystx:
	movem.l	a0-a3/d0-d7,-(sp)
	movea.l	#txtsysd,a3
	movea.l	#txtsyss,a0
systxlp:
	move.w	(a3)+,d2
	bmi.s	systxt1
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	bsr	systxt6
	bra.s	systxlp
systxt1:
	movem.l	(sp)+,a0-a3/d0-d7
	rts
	
*
*
*
*  sub-mode function tableau init code
*
fi:
stubmode:
	rts
*
*
*  test code
*
bltnmode:
	tst.w	cutwidth	;any stuff in cut buffer?
	beq.s	blitneoq
	movea.l	#p_block,a6
	move.w	cutwidth,b_width(a6)
	move.w	cuthite,b_height(a6)
	move.l	cutscren,s_form(a6)
	move.l	curscren,d_form(a6)
	move.w	cutx,s_xmin(a6)
	move.w	#192,d_xmin(a6)
	move.w	cuty,s_ymin(a6)
	move.w	#134,d_ymin(a6)
	move.w	#4,plane_ct(a6)
	move.l	#$03030303,op_tab(a6)
*
	move.w	#8,s_nxwd(a6)
	move.w	#160,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
*
	move.w	#8,d_nxwd(a6)
	move.w	#160,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
*
	.dc.w	bitblt
blitneoq:
	rts
*
handmode:
	rts
*
	.if	0
*
handmode:
	movem.l	a0-a1/d0-d7,-(sp)
*
	move.l	#-1,-(sp)	;see how much memory is left
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
*
	movea.l	#memdigit+6,a0
	move.w	#5,d2
handlp:
	move.w	d0,d1
	andi.w	#$F,d1
	move.b	hdig(pc,d1.w),-(a0)
	lsr.l	#4,d0
	dbra	d2,handlp
*
	movea.l	#memstrng,a0
	move.w	#cbarx+16,d0
	move.w	#cbary+30,d1
	move.w	#0,d2
	bsr	systxt6i
*
	movem.l	(sp)+,a0-a1/d0-d7
	rts	
hdig:
	.dc.b	"0123456789ABCDEF"
	.endif
	nop
textmode:
	movem.l	a0-a1/d0-d7,-(sp)
	bsr	selalign
	bsr	chkstyle
	bsr	chksize
	bsr	textset
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
*
*
brshmode:
	movem.l	a0-a1/d0-d7,-(sp)
	bsr	selbrsh
	bsr	bildbrsh
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
*
*
sprymode:
	movem.l	a0-a1/d0-d7,-(sp)
	bsr	selspry
	bsr	bildspry
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
*
shapmode:
	movem.l	a0-a1/d0-d7,-(sp)
	bsr	holofil
	bsr	chkthik
	bsr	invshape
	movem.l	(sp)+,a0-a1/d0-d7
	rts
lindmode:
	movem.l	a0-a1/d0-d7,-(sp)
	bsr	chklthik
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
copymode:
	movem.l	a0-a1/d0-d7,-(sp)
	bsr	reptrans
	tst.b	scalemd
	beq.s	cpymd1
	bsr.s	setstrch
cpymd1:
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
*
jknfmode:
	movem.l	a0-a1/d0-d7,-(sp)
	bsr.s	jreptran
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
*
*
setstrch:
	tst.w	full
	bne.s	sets1
	movea.l	#copyicon+6,a0
	move.w	(a0)+,d2
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	moveq	#15,d3
	bsr	invdrawq		;draw inverse icon (select it)
	bsr	othsame
sets1:
	move.b	#-1,scalemd
	rts
*
clrstrch:
	clr.b	scalemd
	tst.w	full
	bne.s	clrs1
	movem.l	a0/d0-d3,-(sp)	
	movea.l	#copyicon+6,a0
	move.w	(a0)+,d2
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	moveq	#15,d3
	bsr	drawq		;draw inverse icon (select it)
	bsr	othsame
	movem.l	(sp)+,a0/d0-d3
clrs1:
	rts
*
*
*  set checkmark next to current copy mode..
*  Replace or transparent?  (or poiynt??!!)
*
jreptran:
	move.w	jackmode,d1
	moveq	#2,d2
	moveq	#15,d3
*
	cmpi.w	#1,d1
	bne.s	rept2
*
	move.w	#cbarx+104,d0
	move.w	#cbarx+85,d4
*
	move.w	#cbary+42,d1
	bsr	undraw
*
	exg	d4,d0
	bsr	undraw
*
	move.w	#cbarx+94,d0
	move.w	#cbary+73,d1
	bsr	draw
*
	rts
rept2:
	move.w	d1,-(sp)
	move.w	#cbarx+94,d0
	move.w	#cbary+73,d1
	bsr	undraw
	move.w	(sp)+,d1
	bra.s	rept1
*
reptrans:
	move.w	blitmode,d1
rept1:
	move.w	#cbarx+85,d0
	move.w	#cbarx+104,d4
	tst.w	d1
	bpl.s	opaqmd
	exg	d4,d0
opaqmd:
	move.w	#cbary+42,d1
	move.w	#2,d2
	move.w	#15,d3
*
	bsr	draw
	exg	d4,d0
	bsr	undraw
	rts
*
*
*  set checkmark next to current shape mode..
*  Hollow or filled?
*
holofil:
	move.w	#cbarx+77,d0
	move.w	#cbarx+100,d4
	tst.w	hollow
	bpl.s	hollomd
	exg	d4,d0
hollomd:
	move.w	#cbary+78,d1
	move.w	#2,d2
	move.w	#15,d3
	bsr	draw
	exg	d4,d0
	bsr	undraw
	bsr	rethik
	rts
*
*
unshape:
	moveq	#-1,d4
	bra.s	shapedo
invshape:
	moveq	#0,d4
shapedo:
	movem.l	d0-d3/a0,-(sp)
	move.w	shapesel,d3
	mulu	#6,d3
	lea	shpicon(pc),a0
	adda.w	d3,a0
	move.w	(a0)+,d2
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	addq.w	#1,d0
	addq.w	#1,d1
	moveq	#15,d3
	tst.w	d4
	beq.s	doinv
	bsr	draw
	bra.s	shapeq
doinv:
	bsr	invdraw
shapeq:
	movem.l	(sp)+,d0-d3/a0
	rts
*
*
animode:
	btst.b	#0,anistat
	beq.s	anix	
	bsr	shwboxz	
anix:
	rts
*
*
*
erasmode:
	movem.l	a0-a1/d0-d2,-(sp)
	move.w	#66,d1		;eraser icon #
	bra.s	bildit1

*
*  Build spray cursor form from currently selected spray...
*
bildspry:
	movem.l	a0-a1/d0-d2,-(sp)
	move.w	spraynbr,d1
	bra.s	bildit
*
*  Build brush cursor form for currently selected brush..
*
bildbrsh:
	movem.l	a0-a1/d0-d2,-(sp)
	move.w	brushnbr,d1
bildit:
	add.w	#26,d1		;get icon #
bildit1:
	lsl.w	#1,d1
	movea.l	#iconlist,a0
	move.w	(a0,d1.w),d1
	movea.l	#icons,a0
	adda.w	d1,a0
	move.l	a0,brshptr	;save brush ptr
	movea.l	#brshform,a1
*
	move.w	(a0)+,d1	;get width
	lsr.w	#1,d1
	move.w	d1,(a1)+	;1/2 is x hot spot
*
	move.w	(a0)+,d1	;get height
	move.w	d1,d0
	lsr.w	#1,d0
	move.w	d0,(a1)+	;y hot spot
	addq.l	#6,a1
	moveq	#15,d0
	moveq	#0,d2
bildlp:
	subq.w	#1,d1
	bmi.s	bildlp1
	move.w	(a0),32(a1)
	move.w	(a0)+,(a1)+
	dbra	d0,bildlp
	bra.s	bildlp2
bildlp1:
	move.w	d2,32(a1)
	move.w	d2,(a1)+
	dbra	d0,bildlp1
bildlp2:
	movem.l	(sp)+,a0-a1/d0-d2
	rts
*
*
*
*  Put up nozzle box for currently selected spray can
*
selspry:
	move.w	spraynbr,d1
	bra.s	selit
*
*  Put up brush box for currently selected brush
*
selbrsh:
	move.w	brushnbr,d1
selit:
	ext.l	d1
	divu	#5,d1		;find column
	move.w	d1,d0		;column # in d0
	swap	d1		;row # in d1
	mulu	#13,d0
	add.w	#cbarx+2,d0	;got xpos	
	cmpi.w	#cbarx+93,d0	;gotta special case?
	bne.s	selb1		;br if not
*
*  1 of 3 special case jobs here
*
	lsl.w	#1,d1
	move.w	#cbarx+113,d2
	move.w	boty(pc,d1.w),d3
	move.w	topy(pc,d1.w),d1
	bra.s	selb2
topy:
	.dc.w	cbary+27
boty:
	.dc.w	cbary+48,cbary+65,cbary+82
*
*  Normal 8x8 brush here
*
selb1:
	mulu	#11,d1
	add.w	#cbary+27,d1	;got ypos
	move.w	d0,d2
	move.w	d1,d3
	add.w	#13,d2
	add.w	#11,d3
	cmpi.w	#cbary+82,d3
	bne.s	selb2
	addq.w	#1,d3
selb2:
	moveq	#15,d4
	moveq	#2,d5		;xor
	moveq	#-1,d6
	bsr	box
	rts
*
*
*  Mode tableau service
*
modeupd:
	move.b	likesel,d5
	ext.w	d5
	lsl.w	#2,d5
	movea.l	updlist(pc,d5.w),a0
	jmp	(a0)
*
*
updlist:
	.dc.l	jknfupd		;0-jack knife
	.dc.l	hanupd		;1-hand
	.dc.l	cpybupd		;2-copybox
	.dc.l	txtmdupd	;3-text
	.dc.l	stubupd		;4-pencil
*
	.dc.l	lindupd		;5-linedraw
	.dc.l	stubupd		;6-fillbucket
	.dc.l	stubupd		;7-
	.dc.l	miscupd		;8-miscellany
	.dc.l	brshupd		;9-brush
*
	.dc.l	stubupd		;A-diskette
	.dc.l	animupd		;B-animate
	.dc.l	shapeupd	;C-shapes
	.dc.l	stubupd		;D-eraser
	.dc.l	brshupd		;E-spray can
*	
*
*
stubupd:
	rts
*
*  check for secret click on bottom left-most pixel of "R" on "GRABBER"
*
hanupd:
	btst.l	#3,d2		;right click?
	beq.s	nohan
	cmpi.w	#$126,d0
	bne.s	nohan
	cmpi.w	#$86,d1
	bne.s	nohan
	move.b	#67,liconlst+11		;install funky animate tool
*
*  instant display
*
	movem.l	d0-d3,-(sp)
	moveq	#33,d0
	move.w	#159,d1
	moveq	#67,d2
	moveq	#15,d3
	bsr	draw
	movem.l	(sp)+,d0-d3
nohan:
	rts
*
*  A click occured in the text submode menu area..
*
*  This routine services such clicks
*
*  d3 = xpos-cbarx
*  d4 = ypos-(cbary+16)
*
txtmdupd:
	movem.l	a0-a1/d0-d7,-(sp)
*
*  check for text alignment change
*
	cmpi.w	#cbary+67,d1
	bcs.s	notalibx
	cmpi.w	#cbary+76,d1
	bcc.s	notalibx
	move.w	d0,d5
	subi.w	#cbarx+42,d5
	bcs.s	notalibx
	ext.l	d5
	divu	#12,d5
	cmpi.w	#3,d5
	bcc.s	notalibx
	move.w	textalin,d4
	move.w	d4,-(sp)	
	mulu	#6,d4
	movea.l	#texticon,a0
	move.w	(a0,d4.w),d2
	move.w	2(a0,d4.w),d0
	move.w	4(a0,d4.w),d1
	moveq	#15,d3
	bsr	drawq
	move.w	d5,textalin
	bsr	selalign
	move.w	(sp)+,d4
	cmp.w	d4,d5
	beq	doexit
	bra	donewtx
*
*  thats all for alignment stuff
*
notalibx:
*
*  check for style clicks
*
	move.w	textstyl,d3
	cmpi.w	#cbarx,d0
	bcs.s	notstyl
	cmpi.w	#cbarx+78,d0
	bcc.s	notstyl
	move.w	d1,d4
	subi.w	#cbary+25,d4
	bcs.s	notstyl
	lsr.w	#3,d4
	cmpi.w	#5,d4
	bcc.s	notstyl
	tst.w	d4
	bne.s	notplain
*
*  plain clicked..
*
	tst.w	d3
	beq.s	notstyl		;br if plain already in effect
	clr.w	textstyl
	bra.s	stylchk
notplain:
	cmpi.w	#1,d4		;bold selected?
	bne.s	notbold
	moveq	#0,d4
notbold:
	bchg.b	d4,textstyl+1
stylchk:
	bsr	chkstyle	;put checks up on styles
	bra.s	donewtx
notstyl:
*
*  check for size clicks
*
	move.w	textsize,d3
	cmpi.w	#cbarx+79,d0
	bcs.s	notsize
	cmpi.w	#cbarx+115,d0
	bcc.s	notsize
	move.w	d1,d4
	subi.w	#cbary+26,d4
	bcs.s	notsize
	lsr.w	#3,d4
	cmpi.w	#6,d4
	bcc.s	notsize
	movea.l	#siztab,a0
	move.b	(a0,d4.w),textsize+1
	bsr	chksize
	cmp.w	textsize,d3
	beq.s	doexit
donewtx:
	bsr	textset
	bsr	othsame
	bsr	newtxtmd
	movem.l	(sp)+,a0-a1/d0-d7
	rts
notsize:
*
*  now check for face clicks..
*
	cmpi.w	#cbary+77,d1
	bcs.s	notface
	cmpi.w	#cbarx+30,d0
	bcs.s	notface
	cmpi.w	#cbarx+114,d0
	bcc.s	notface
	bchg.b	#7,textadj
	movea.l	#txtsyss,a0
	movea.l	#txtsysxs,a1
swapface:
	move.b	(a0),d7
	move.b	(a1),(a0)+	
	move.b	d7,(a1)+
	bne.s	swapface
	bsr	newsystx
notface:	
doexit:
	bsr	textset
	bsr	othsame
	movem.l	(sp)+,a0-a1/d0-d7
	rts
*
************************************************************
*
*  Shapes tableau update
*
shapeupd:
	move.w	d1,d5
	subi.w	#cbary,d5
	bcs	shapq
	cmpi.w	#49,d5			;below shape icons?
	bcs	chkshap			;br if not
	cmpi.w	#cbarx,d0
	bcs	shapq
	cmpi.w	#cbarx+36,d0
	bcs.s	chkthin
	cmpi.w	#cbarx+68,d0
	bcc.s	chkhofil
*chkthik:
	moveq	#3,d4
	move.w	#5,linethik
thiklp:
	cmp.b	thiky(pc,d4.w),d5
	bcc.s	thikout
	dbra	d4,thiklp
	bra.s	thikout
chkthin:
	moveq	#4,d4
	clr.w	linethik
thinlp:
	cmp.b	thiny(pc,d4.w),d5
	bcc.s	thikout
	dbra	d4,thinlp
thikout:
	add.w	d4,linethik
	bsr	chkthik
	bsr	rethik
	bra	shapq
*
thiny:
	.dc.b	49,56,62,68,75,255
thiky:
	.dc.b	49,57,65,74
*
chkhofil:
	clr.w	hollow
	cmpi.w	#cbarx+92,d0
	bcs.s	nofill
	move.w	#-1,hollow
nofill:
	bsr	holofil
	lea	shpicon(pc),a0
	move.w	(a0),d4
	cmpi.w	#76,d4
	bne.s	chholer
	tst.w	hollow
	beq.s	shapq
*
*  redo to filled icon shapes
*
	moveq	#5,d5
	bra.s	setike
chholer:
	tst.w	hollow
	bmi.s	shapq
	moveq	#-5,d5
setike:
	moveq	#4,d4
setikelp:
	add.w	d5,(a0)
	addq.l	#6,a0
	dbra	d4,setikelp
*
	bsr	reshape
	bsr	invshape
	rts
*
chkshap:
	cmpi.w	#25,d5
	bcs.s	shapq
	move.w	d0,d5
	subi.w	#cbarx,d5
	bcs.s	shapq
	ext.l	d5
	divu	#23,d5
	bsr	unshape
	cmpi.w	#5,d5
	bcs.s	selok
	moveq	#4,d5
selok:
	move.w	d5,shapesel
	bsr	invshape
shapq:
	rts
*
*
miscmode:
	movem.l	a0/d0-d1,-(sp)
	movea.l	#undostrg,a0
	move.w	#cbarx+72,d0
	move.w	#cbary+34,d1
	bsr	systxt8
	bsr.s	mischk
	movem.l	(sp)+,a0/d0-d1
	rts
*
*  Miscellaneous update
*
miscupd:
*	cmpi.w	#cbary+45,d1		;in upper block
*	bcc.s	misc1
*	cmpi.w	#cbary+25,d1		;above action area?
*	bcs.s	miscq
*	cmpi.w	#cbarx+2,d0
*	bcs.s	miscq
*	cmpi.w	#cbarx+60,d0
*	bcc.s	miscq
*
	cmpi.w	#cbary+51,d1		;in lower area?
	bcc	misc1			;  br if in lower
	cmpi.w	#cbary+27,d1		;above upper area?
	bcs.s	miscql			;  exit if so--no action here
	cmpi.w	#cbarx+2,d0		;too far left?
	bcs.s	miscql			;br if so
	cmpi.w	#cbarx+61,d0		;within x: /y: check area?
	bcs.s	miscin			;br if so
	cmpi.w	#cbarx+114,d0		;too far right?
	bcc.s	miscql			;br if so, quit
*
*  within palette/color UNDO area--color or palette?
*
	clr.b	touch			;we've touched picture
	movea.l	#undopalt,a0
	movea.l	#colorz,a1
	moveq	#15,d7
	cmpi.w	#cbary+38,d1		;palette or color?
	bcc.s	unpaltdo		;br to undo whole palette
*
* undo just select color
*
	move.w	selctcol,d6
	add.w	d6,d6
	adda.w	d6,a0
	adda.w	d6,a1
	moveq	#0,d7
*
*  undo whole palette
*
unpaltdo:
	move.w	(a0),d6
	move.w	(a1),(a0)+
	move.w	d6,(a1)+
	dbra	d7,unpaltdo
	bsr	back2bot
miscql:
	rts
miscin:	
*
*  within mode select area
*
	cmpi.w	#cbary+35,d1	;x/y?
	bcc.s	miscql		;br to exit if in vacant lot below
	not.b	xyplot
*
*  Put up check mark next to x: /y: according to xyplot
*
mischk:
	movem.l	a0/d0-d5,-(sp)
	move.w	#cbarx+6,d0
	move.w	#cbary+25,d1
	move.w	#cbarx+13,d2
	move.w	#cbary+44,d3
	moveq	#0,d4
	move.w	#1,d5
	bsr	fillbox		;erase old checkmark, if any
*
	movea.l	#checktxt,a0
	move.w	#cbarx+8,d0
	move.w	#cbary+28,d1
	moveq	#0,d2
	tst.b	xyplot
	beq.s	mischk1
	bsr	systxt6i
mischk1:
	movem.l	(sp)+,a0/d0-d5
	rts
*  
misc1:
	btst.l	#2,d2			;left edge on mouse?
	beq	miscq
*
	move.w	d1,d5
	sub.w	#cbary+54,d5
	bmi	miscq
	lsr.w	#3,d5
	cmpi.w	#2,d5
	bcc	miscq
	bsr	invmscbk
msclp:
	move.w	d5,-(sp)
	bsr	cscrlupd
	bsr	showm
	bsr	mouseget
	move.w	(sp)+,d5
	btst.l	#4,d2			;trailing edge on left?
	bne.s	mscdo			;if so, perform action requested
	move.w	d1,d4
	sub.w	#cbary+53,d4		;still within bounds?
	bmi.s	mscdo1			;br if not
	lsr.w	#3,d4
	cmpi.w	#2,d4
	bcc.s	mscdo1			;br if out of bounds
	cmp.w	d4,d5			;new block same as old?
	beq.s	msclp
	bsr	hidem
	tst.w	d5
	bmi.s	swcheroo
	bsr	invmscbk
swcheroo:
	move.w	d4,d5
	bsr	invmscbk
	bsr	showm
	bra.s	msclp
mscdo1:
	tst.w	d5
	bmi.s	msclp
	bsr	hidem
	bsr	invmscbk
	moveq	#-1,d5
	bsr	showm
	bra.s	msclp
mscdo:
	tst.w	d5
	bmi	miscq
	bsr	hidem
*
*
*
	move.w	#7,d6
mscflsh:
	bsr	invmscbk
	move.w	frmcnt,cutfrm
mscwt:
	move.w	frmcnt,d7
	sub.w	cutfrm,d7
	cmpi.w	#2,d7
	bcs.s	mscwt
	dbra	d6,mscflsh
*
*  now, do function in d5 (0-cut buffer to .S file, 1-mask to .M file)
*
	move.w	d5,cutfrm	;save function in temp
*
*
dots:
	tst.w	cutwidth	;any stuff in cut buffer?
	bne.s	sends		;br if so
*
*  put up message that cut buffer is empty
*
	movea.l	#empmsg,a0
	bsr	msgit
	bra	misce
*
*  send out a file of cut buffer stuff
*
sends:
*
*  blit cut buffer to othscren to left align
*
	movea.l	#p_block,a6		;base ptr for blt parm block
	move.w	cutwidth,d2
	move.w	d2,b_width(a6)		;set width
	move.w	cuthite,d3		
	move.w	d3,b_height(a6)		;set height
	move.l	cutscren,s_form(a6)
	movea.l	othscren,a0
	move.l	a0,d_form(a6)
*
*    check size here 
*
	moveq	#0,d0			;clear destination 1st
	move.w	#7999,d1
freshlp:
	move.l	d0,(a0)+
	dbra	d1,freshlp
*
	move.w	cutx,s_xmin(a6)
	move.w	#0,d_xmin(a6)
	move.w	cuty,s_ymin(a6)
	move.w	#0,d_ymin(a6)
*
	move.w	#8,s_nxwd(a6)		;set source normal lo rez screen
	move.w	#160,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
*
	move.w	#4,plane_ct(a6)		;always refresh plane count
*
*  assume 16-color cut
*
	move.l	#$03030303,d5
	moveq	#8,d4			;bytes offset to next plane
	move.w	d2,d1
	addi.w	#15,d1
	lsr.w	#4,d1
	lsl.w	#3,d1			;d1=bytes in each line
*
	move.b	#"S",d0
	tst.w	cutfrm			;.S or .M?
	beq.s	sok			;br if .S, assumption ok
*
*  .M file, set up for mask
*
	move.l	#$03070707,d5
	move.w	#%1110,fg_col(a6)
	move.w	#%0000,bg_col(a6)
*
	moveq	#2,d4
	move.w	d2,d1
	addi.w	#15,d1
	lsr.w	#4,d1
	lsl.w	#1,d1			;d1=bytes in each line
*
	move.b	#"M",d0
sok:
	move.b	d0,spath+7
*
	move.w	d4,d_nxwd(a6)		;set for full/mask
	lsr.w	#2,d4
	move.w	d4,d_nxpl(a6)
*
	move.w	d1,d2
	move.w	d2,d_nxln(a6)		;d2= # bytes/scanline
	mulu	d2,d3
	lsr.w	#1,d3			;d3= # of words to send
*
	move.l	d5,op_tab(a6)
*
	movem.l	a6/d2-d3,-(sp)
	.dc.w	bitblt			;blit cutbuffer to othscren to align
*
**********************************************************
*
*
* Discover next available CPYBx.S filename
*
nameit:
	pea	dma
	move.w	#$1a,-(sp)		;set dma
	trap	#1
	addq.l	#6,sp
*
	move.w	#1,snapnbr
*
	clr.w	-(sp)
	pea	spath			;search for copyb*.s
	move.w	#$4e,-(sp)		;search 1st
	trap	#1
	addq.l	#8,sp
*
	tst.w	d0
	bmi.s	dostart			;br if none found
*
nextsnap:
	moveq	#0,d1
	lea	nexfile+5,a0
moredig:
	move.b	(a0)+,d0
	beq.s	dochk
	cmpi.b	#".",d0
	beq.s	dochk
	subi.b	#"0",d0
	bcs.s	skpsnap
	cmpi.b	#10,d0
	bcc.s	skpsnap
	mulu	#10,d1
	ext.w	d0
	add.w	d0,d1
	bra.s	moredig
dochk:
	cmp.w	snapnbr,d1
	bcs.s	dosnap
	addq.w	#1,d1
	move.w	d1,snapnbr
dosnap:
skpsnap:
	move.w	#$4f,-(sp)		;search next
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	bpl.s	nextsnap
*
dostart:
	lea	spath,a0
	lea	cutpath,a1
	move.w	#4,d0
setsnap:
	move.b	(a0)+,(a1)+
	dbra	d0,setsnap
*
	moveq	#0,d1
	move.w	snapnbr,d0
	ext.l	d0
	divu	#100,d0
	beq.s	not100
	addi.b	#"0",d0
	move.b	d0,(a1)+
	addq.w	#1,d1
not100:
	swap	d0
	ext.l	d0
	divu	#10,d0
	bne.s	yes10
	tst.w	d1
	beq.s	not10
yes10:
	addq.w	#1,d1
	addi.b	#"0",d0
	move.b	d0,(a1)+
not10:
	swap	d0
	addi.b	#"0",d0
	move.b	d0,(a1)+
	addq	#1,a0
	move.w	#2,d0
setsnap1:
	move.b	(a0)+,(a1)+
	dbra	d0,setsnap1
*
*  got file name, now use--but 1st, tell user filename he got
*
	movea.l	#filen,a0
	lea	10(a0),a3
	movea.l	#cutpath,a1
	move.l	a1,a2
seeklp:
	tst.b	(a1)+
	bne.s	seeklp
	subq.l	#1,a1
stufflp:
	move.b	-(a1),-(a3)
	cmp.l	a1,a2
	bne.s	stufflp
blnklp:
	cmp.l	a3,a0
	beq.s	blnkq
	move.b	#" ",-(a3)
	bra.s	blnklp
blnkq:
	movea.l	#sendmsg,a0
	bsr	msgit
*
**********************************************************
*
	clr.w	-(sp)
	pea	cutpath
	move.w	#$3c,-(sp)		;create file
	trap	#1
	addq.l	#8,sp
*
	movem.l	(sp)+,a6/d2-d3
	move.w	d3,d1			;copy total # of words
*
	move.l	sp,nrmstack		;save stack to use if failure exit
	move.w	d0,handles
*
	bmi	fwtbad			;handle this
*
	movea.l	physadd,a0		;use as ascii buffer
	movea.l	a0,a1
	adda.w	#1024,a0
*
	move.w	d2,-(sp)		;save bytes/scanline
	lea	cutmsg0(pc),a2		;"NEOchrome cut buffer contents"
	bsr	lineout
	move.w	cutwidth,d2		;"pixels/scanline   = "
	bsr	wordout
	lea	cutmsg0a(pc),a2		;"bytes/scanline:  "
	bsr	lineout
	move.w	(sp)+,d2		;reget bytes/scanline
*
	bsr	wordout
	lea	cutmsg1(pc),a2		;" scanlines (height)"
	bsr	lineout
	move.w	cuthite,d2
	bsr	wordout
*
	tst.w	cutfrm			;.S or .M?
	bne.s	msgstrng		;br to mask message if so
*
	lea	cutmsg6(pc),a2		;"Hardware pallet"
	bsr	lineout
	movea.l	#colorz,a3
	move.w	#1,d4
rptcol1:
	move.w	#6,d3
rptcol:
	move.w	(a3)+,d2
	bsr	wordout
	lea	cutmsg4(pc),a2
	bsr	lineout
	dbra	d3,rptcol
	move.w	(a3)+,d2
	bsr	wordout
	tst.w	d4
	beq.s	rptc1
	lea	cutmsg7(pc),a2
	bsr	lineout
rptc1:
	dbra	d4,rptcol1
	bra.s	dodata
*
msgstrng:
	lea	cutmsg8(pc),a2
	bsr	lineout
*
*
dodata:
	movea.l	othscren,a3
	lea	cutmsg2(pc),a2
	bsr	lineout
fileblp:
	lea	cutmsg3(pc),a2
	bsr	lineout
	move.w	#7,d4
filebyte:
	move.w	(a3)+,d2
	bsr	wordout
	subq.w	#1,d1			;dec word count
	beq.s	fileq
	tst.w	d4
	beq.s	fi1
	lea	cutmsg4(pc),a2
	bsr	lineout
fi1:
	dbra	d4,filebyte
	bra.s	fileblp
fileq:
	lea	cutmsg5(pc),a2
	bsr	lineout
*	
	movea.l	physadd,a0
	cmpa.l	a0,a1
	beq.s	clfile
	suba.l	a0,a1
*
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	move.w	handles,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.w	#12,sp
	cmp.l	-8(sp),d0
	bne.s	fwtbad1
*
clfile:	
	move.w	handles,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	movea.l	#blankmsg,a0
	bsr.s	msgit
	bra	misce
*
fwtbad1:
	pea	cutpath		;delete incomplete file
	move.w	#$41,-(sp)
	trap	#1
	addq.l	#6,sp
*
fwtbad:
	move.l	nrmstack,sp	;reget stack to use for error exit
	movea.l	#fwtrmsg,a0
	bsr.s	msgit
	bra	misce
*
*
msgit:
	move.w	#cbarx+6,d0
	move.w	#cbary+75,d1
	moveq	#0,d2
	bsr	systxt6
	rts
*
*
cutmsg0:
	.dc.b	"*",13,10
	.dc.b	"*  NEOchrome cut buffer contents (left justified):"
	.dc.b	13,10,"*",13,10
	.dc.b	"*    pixels/scanline    = $",0
cutmsg0a:
	.dc.b	" (bytes/scanline: $",0
cutmsg1:
	.dc.b	")",13,10
	.dc.b	"*  # scanlines (height) = $",0
cutmsg2:
	.dc.b	13,10,"*",13,10,"*",0
cutmsg3:
	.dc.b	13,10,9,".dc.w",9,"$",0
cutmsg4:
	.dc.b	",$",0
cutmsg5:
	.dc.b	13,10,$1a,0
cutmsg6:
	.dc.b	13,10
	.dc.b	"*",13,10
	.dc.b	"*  Hardware color pallet  (color 0 to 15):",13,10
	.dc.b	"*"
cutmsg7:
	.dc.b	13,10
	.dc.b	"*      $",0
cutmsg8:
	.dc.b	13,10
	.dc.b	"*",13,10
	.dc.b	"*  Monochrome mask (1 plane; background=0/non-background=1)"
	.dc.b	13,10
	.dc.b	"*",0
*
*
	.even
*
*  character in d3 is output
*
charout:
	movem.l	a2-a6/d0-d7,-(sp)
	andi.w	#$7F,d3
	move.w	d3,d2
	bsr.s	fileit
	movem.l	(sp)+,a2-a6/d0-d7
	rts
*
*  string pointed to by a2 is output
*
lineout:
	movem.l	a2-a6/d0-d7,-(sp)
lo1:
	move.b	(a2)+,d2
	beq.s	lineq
	bsr.s	fileit
	bra.s	lo1
lineq:
	movem.l	(sp)+,a2-a6/d0-d7
	rts
*
*  long word in d2 is output to console
*
longout:
	swap	d2
	bsr.s	wordout
	swap	d2
*
*  fall thru to..
*
*
*  word in d2 is output to console
*
wordout:
	move.w	d2,-(sp)
	lsr.w	#8,d2
	bsr.s	byteout
	move.w	(sp)+,d2
*
*  fall thru to..
*
*  byte in d2 is output to console
*
byteout:
	movem.l	a2-a6/d0-d7,-(sp)
	move.w	d2,-(sp)
	lsr.w	#4,d2
	bsr.s	nibout
	move.w	(sp)+,d2
	bsr.s	nibout
	movem.l	(sp)+,a2-a6/d0-d7
	rts
*
nibtab:
	.dc.b	"0123456789ABCDEF"
nibout:
	andi.w	#$F,d2
	move.b	nibtab(pc,d2),d2
	bsr.s	fileit
	rts
*
fileit:
	movem.l	a2-a6/d0-d7,-(sp)
	move.b	d2,(a1)+
	cmpa.l	a0,a1
	bne.s	choutx
	suba.w	#1024,a1
*
	move.l	a0,-(sp)
*
	move.l	a1,-(sp)
	move.l	#1024,-(sp)
	move.w	handles,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	adda.w	#8,sp
	move.l	(sp)+,a1
*
	move.l	(sp)+,a0
	cmpi.l	#1024,d0
	bne	fwtbad1
choutx:
	movem.l	(sp)+,a2-a6/d0-d7
	rts
*
misce:
	move.w	cutfrm,d5	;recall function from temp
	bsr	invmscbk
miscq:
	rts
*
*  Line draw tableau update
*
lindupd:
	move.w	d1,d5
	subi.w	#cbary,d5
	bcs.s	lindq
	cmpi.w	#48,d5			;in thickness select area?
	bcs.s	lindq			;br if not
	cmpi.w	#cbarx,d0
	bcs.s	lindq
	cmpi.w	#cbarx+36,d0
	bcs.s	chklthin
	cmpi.w	#cbarx+68,d0
	bcc.s	lindq
*chkthik:
	moveq	#3,d4
	move.w	#5,lindthik
thikllp:
	cmp.b	thikly(pc,d4.w),d5
	bcc.s	thiklout
	dbra	d4,thikllp
	bra.s	thiklout
chklthin:
	moveq	#4,d4
	clr.w	lindthik
thinllp:
	cmp.b	thinly(pc,d4.w),d5
	bcc.s	thiklout
	dbra	d4,thinllp
thiklout:
	add.w	d4,lindthik
	bne.s	lindok
	addq.w	#1,lindthik
lindok:
	bsr	chklthik
	bsr	relthik
lindq:
	rts
*
thinly:
	.dc.b	49,56,62,68,75,255
thikly:
	.dc.b	49,57,65,74
*
*
*
setanitx:
	movea.l	#animtxts+3,a0
	move.l	holdptr,d0
	bne.s	gothold
	bsr.s	xxit
	bra.s	ovhold
gothold:
	move.l	d0,a1
	moveq	#0,d0
holdloop:
	addq.w	#1,d0
	move.l	6(a1),a1
	cmpa.l	#0,a1
	bne.s	holdloop
	bsr.s	d02strng
ovhold:
	move.l	curcell,d0
	bne.s	gotcur
	bsr.s	xxit
	bsr.s	xxit
	bsr.s	xxit
	rts
gotcur:
	move.l	d0,a1
	move.l	2(a1),a2
	move.b	(a2),d0
	bsr.s	d02strng
	move.b	(a1),d0
	bsr.s	d02strng
	move.l	6(a1),a2
	move.b	(a2),d0
	bsr.s	d02strng
	rts
*
*
xxit:
	move.b	#"X",(a0)+
	move.b	#"X",(a0)+
	addq.l	#1,a0
	rts

d02strng:
	ext.w	d0
	beq.s	xxit
	ext.l	d0
	divu	#10,d0
	move.b	digtab1(pc,d0.w),(a0)+
	swap	d0
	move.b	digtab1(pc,d0.w),(a0)+
	addq.l	#1,a0
	rts
digtab1:
	.dc.b	"0123456789"			
*
*  update text strings
*
updtxts:
	movem.l	a0-a1/d4-d6,-(sp)
	lea	cpytxtd(pc),a0
	moveq	#0,d5		;assume active
	btst.b	#0,copystat	;copybox in existence?
	bne.s	emptybuf
	moveq	#3,d5		;no copy-box--set inactive
emptybuf:
	lea	jktxtd(pc),a1
	moveq	#0,d4		;assume active
	btst.b	#0,jackstat
	bne.s	mptybuf
	moveq	#3,d4
mptybuf:
	moveq	#7,d6
utxlp:
	move.w	d5,(a0)
	move.w	d5,54(a0)
	addq.l	#6,a0
	dbra	d6,utxlp
*
	moveq	#3,d6
utxlp1:
	move.w	d4,(a1)
	move.w	d4,24(a1)
	addq.l	#6,a1
	dbra	d6,utxlp1
*
	moveq	#3,d6
	move.w	d6,-36(a0)	;assume "paste" is off
	move.w	d6,18(a0)
*
	move.w	d6,-12(a1)
	move.w	d6,12(a1)
*
	tst.b	bigram
	bne.s	utxtstr0
	move.w	#-1,(a1)	;if small RAM, turn off function keys
utxtstr0:
	tst.w	cutwidth
	beq.s	nopast
	clr.w	-36(a0)
	clr.w	18(a0)
nopast:
	tst.w	d4
	beq.s	nopast1
	tst.w	cutwidth
	beq.s	nopast1
	clr.w	-12(a1)
	clr.w	12(a1)
nopast1:
	movem.l	(sp)+,a0-a1/d4-d6
	rts
*
*
addamt:
	.dc.w	22656,22656+(7*160),22656+(14*160),22656+(21*160)
	.dc.w	22656+(28*160),22656+(35*160),22656+(42*160),22656+(49*160)
*
*  invert block of text
*
*  d5 =  0-7  (indicating block to invert)
*
invblock:
	movem.l	a0/d0-d2,-(sp)
	movea.l	curscren,a0
	lsl.w	#1,d5
	adda.w	addamt(pc,d5.w),a0
	lsr.w	#1,d5
	move.l	#$00FF00FF,d0
	moveq	#-1,d1
	move.w	#6,d2
ivblklp:
	eor.l	d0,(a0)+
	eor.l	d0,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	adda.w	#160-40,a0
	dbra	d2,ivblklp
*
	movem.l	(sp)+,a0/d0-d2
	rts
*
*
addanmt:
	.dc.w	24616,24616+(8*160),24616+(16*160)
*
*  invert animate (load/save/new) block of text
*
*  d5 - 0,1, or 2 (indicating block to invert)
*
invanibk:
	movem.l	a0/d0-d2,-(sp)
	movea.l	curscren,a0
	lsl.w	#1,d5
	adda.w	addanmt(pc,d5.w),a0
	lsr.w	#1,d5
	move.l	#$FF00FF00,d0
	moveq	#-1,d1
	move.w	#6,d2
ivanilp:
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d0,(a0)+
	eor.l	d0,(a0)+
	adda.w	#160-24,a0
	dbra	d2,ivanilp
*
	movem.l	(sp)+,a0/d0-d2
	rts
*
addammt:
	.dc.w	167*160+96,175*160+96
*
*  invert misc block of text
*
*  d5 - 0 or 1 (indicating block to invert)
*
invmscbk:
	movem.l	a0/d0-d2,-(sp)
	movea.l	curscren,a0
	lsl.w	#1,d5
	adda.w	addammt(pc,d5.w),a0
	lsr.w	#1,d5
	move.l	#$00ff00ff,d0
	moveq	#-1,d1
	move.w	#6,d2
ivmsclp:
	eor.l	d0,(a0)+
	eor.l	d0,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	eor.l	d1,(a0)+
	not.l	d0
	eor.l	d0,(a0)+
	eor.l	d0,(a0)+
	not.l	d0
	adda.w	#160-64,a0
	dbra	d2,ivmsclp
*
	movem.l	(sp)+,a0/d0-d2
	rts
*
*
*
*  Brush mode update
*
brshupd:
	move.w	d0,d3
	subi.w	#cbarx,d3
	bcs	nobrsh
	cmpi.w	#115,d3
	bcc	nobrsh
	move.w	d1,d4
	subi.w	#cbary+27,d4
	bcs	nobrsh
	cmpi.w	#55,d4
	bcs.s	brshup1
	moveq	#54,d4
brshup1:
	ext.l	d3
	divu	#13,d3
	cmpi.w	#7,d3
	bcs.s	brshup2
	moveq	#35,d3
*
	moveq	#0,d5
	cmpi.w	#21,d4
	bcs.s	brshup4
	addq.w	#1,d5
	cmpi.w	#38,d4
	bcs.s	brshup4
	addq.w	#1,d5
brshup4:
	move.w	d5,d4
	bra.s	brshup3
brshup2:
	mulu	#5,d3
	ext.l	d4
	divu	#11,d4
brshup3:
	add.w	d4,d3
	cmpi.b	#14,likesel		;check for spray or brush
	bne.s	brshup5			;br if not spray--must be brush
*
*  spray update here..
*
	movem.l	d0-d3,-(sp)
	bsr	selspry
	movem.l	(sp)+,d0-d3
	move.w	d3,spraynbr
	movem.l	d0-d3,-(sp)
	bsr	selspry
	bsr	bildspry
	movem.l	(sp)+,d0-d3
	rts
*  
brshup5:
	movem.l	d0-d3,-(sp)
	bsr	selbrsh
	movem.l	(sp)+,d0-d3
	move.w	d3,brushnbr
	movem.l	d0-d3,-(sp)
	bsr	selbrsh
	bsr	bildbrsh
	movem.l	(sp)+,d0-d3
nobrsh:
	rts
*
*  Put check mark on linedraw line thickness selected
*  
chklthik:
	move.w	lindthik,d2
	bra.s	thikchk
*
*  Put check mark on shapes outline line thickness selected
*
chkthik:
	move.w	linethik,d2
thikchk:
	move.w	d2,-(sp)
	move.w	#cbarx+4,d0
	move.w	#cbary+51,d1
	move.w	#cbarx+10,d2
	move.w	#cbary+81,d3
	moveq	#0,d4
	move.w	#1,d5
	bsr	fillbox
	move.w	#cbarx+39,d0
	move.w	#cbarx+45,d2
	bsr	fillbox			;erase all previous checks
*
	move.w	(sp)+,d2
*
	movea.l	#checktxt,a0
	move.w	#cbarx+5,d0
*	move.w	linethik,d2
	cmpi.w	#5,d2
	bcs.s	chkxok
	move.w	#cbarx+40,d0
chkxok:
	move.b	chktab(pc,d2),d1
	ext.w	d1
	addi.w	#cbary,d1
	moveq	#0,d2			;plain
	bsr	systxt6i
*	
	rts
*
chktab:
	.dc.b	51,56,62,69,77,51,59,67,76,0
*
*  Check marks (or uncheck marks) all styles on menu according to textstyl
*
chkstyle:
	movem.l	a0/d0-d6,-(sp)
	move.w	#cbarx+1,d0
	move.w	#cbary+25,d1
	move.w	#cbarx+8,d2
	move.w	#cbary+65,d3
	moveq	#0,d4
	move.w	#1,d5
	bsr	fillbox			;erase all previous checks
*
	movea.l	#checktxt,a0
	move.w	#cbarx+3,d0
	move.w	#cbary+26,d1		;ypos for plain
	move.w	textstyl,d2
	bne.s	chkstyl1
	bsr	systxt6i
	bra.s	chkstylq
chkstyl1:
	addq.w	#8,d1			;ypos for bold
	lsr.w	#1,d2
	bcc.s	chkstyl2
	movem.l	a0/d0-d2,-(sp)
	moveq	#0,d2			;plain
	bsr	systxt6i
	movem.l	(sp)+,a0/d0-d2
chkstyl2:
	lsr.w	#1,d2			;skip over liten bit
	move.w	#2,d3
chkstylp:
	addq.w	#8,d1
	lsr.w	#1,d2
	bcc.s	chkstyl3
	movem.l	a0/d0-d3,-(sp)
	moveq	#0,d2
	bsr	systxt6i
	movem.l	(sp)+,a0/d0-d3
chkstyl3:
	dbra	d3,chkstylp
chkstylq:
	movem.l	(sp)+,a0/d0-d6
	rts
*
*  Check mark size entries
*
chksize:
	movem.l	a0/d0-d6,-(sp)
	move.w	#cbarx+80,d0
	move.w	#cbary+25,d1
	move.w	#cbarx+88,d2
	move.w	#cbary+73,d3
	moveq	#0,d4
	move.w	#1,d5
	bsr.s	fillbox			;erase all previous checks
*
	movea.l	#checktxt,a0
	move.w	#cbarx+82,d0
	move.w	#cbary+68,d1		;ypos for 6th size #
	move.w	textsize,d2
	move.w	#5,d3
sizelp:
	cmp.b	siztab(pc,d3),d2
	beq.s	sizelpq
	subq.w	#8,d1
	dbra	d3,sizelp
	bra.s	chksizeq
sizelpq:
	moveq	#0,d2
	bsr	systxt6i
chksizeq:
	movem.l	(sp)+,a0/d0-d6
	rts
*
siztab:
*	.dc.b	4,5,8,13,10,26
	.dc.b	4,6,8,13,12,26
*
*  Select draws alignment arrow to display current setting..
*
selalign:
	movem.l	a0/d0-d4,-(sp)
	move.w	#15,d3
	move.w	textalin,d4	
	mulu	#6,d4
	movea.l	#texticon,a0
	move.w	(a0,d4.w),d2
	move.w	2(a0,d4.w),d0
	move.w	4(a0,d4.w),d1
	bsr	invdrawq
	movem.l	(sp)+,a0/d0-d4
	rts
*
*
colxlat:
	.dc.b	0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1
*
*  Fill a box with solid color...
*
*  d0.w = top/left x
*  d1.w = top/left y
*  d2.w = bot/rite x
*  d3.w = bot/rite y
*  d4.w = fill area color
*  d5.w	= writing mode (1-replace,2-transparent,3-XOR,4-inverse transparent)
*
fillbox:
	movem.l	a0-a1/d0-d6,-(sp)
	movea.l	#contrl,a0
	movea.l	#intin,a1
*
	move.w	#32,(a0)+	;set writing mode
	clr.w	(a0)+
	move.w	#1,2(a0)
	move.w	d5,(a1)
	bsr	vdicall
*
	clr.w	(a1)
*
	subq.l	#4,a0
	move.w	#25,(a0)+	;set fill color index
	clr.w	(a0)+
	addq.l	#2,a0
	move.w	#1,(a0)
	move.b	colxlat(pc,d4.w),1(a1)
	bsr	vdicall
*
	subq.l	#6,a0
	move.w	#23,(a0)	;set fill interior solid
	move.w	#1,(a1)
	bsr	vdicall
*
	move.w	#9,(a0)+	;filled area
	move.w	#4,(a0)+	;# of vertices
	clr.l	(a0)
	movea.l	#ptsin,a1
	move.w	d0,(a1)+	;x1
	move.w	d1,(a1)+	;y1
*
	move.w	d2,(a1)+	;x2
	move.w	d1,(a1)+	;y2
*
	move.w	d2,(a1)+	;x3
	move.w	d3,(a1)+	;y3
*
	move.w	d0,(a1)+	;x4
	move.w	d3,(a1)		;y4
	bsr	vdicall
*
	movem.l	(sp)+,a0-a1/d0-d6
	rts
*
*
*
*
*
*
*	.data
*
*
*
*
*  grafix data including icons,boxes & strings
*
gp:
fillstub:
openstub:
txtdstub:
txtsstub:
iconstub:
	.dc.w	-1
*
*
handtxtd:
	.dc.w	0
	.dc.w	cbarx+22,cbary+18	;grabber
*
	.dc.w	-1
lindtxtd:
	.dc.w	0
	.dc.w	cbarx+7,cbary+29	;L. button = color
*
	.dc.w	0
	.dc.w	cbarx+8,cbary+37	;R. button = ramp
*
filltxtd:
	.dc.w	0
	.dc.w	cbarx+10,cbary+18	;line draw, area fill
*
	.dc.w	-1
*
jacktxtd:
	.dc.w	0			;jack knife
	.dc.w	cbarx+4,cbary+18
*
jktxtd:
	.dc.w	3
	.dc.w	cbarx+8,cbary+28	;cut
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+35	;copy
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+42	;paste
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+49	;clear
*
*  change following to 3 if larger RAM system available
*
jktxtad:
	.dc.w	-1
	.dc.w	cbarx+57,cbary+28	;f1
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+35	;f2
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+42	;f3
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+49	;f4
*
	.dc.w	-1
*
erastxtd:
shaptxtd:
penctxtd:
	.dc.w	0
	.dc.w	cbarx+25,cbary+18	;eraser, shapes, pencil
*
	.dc.w	-1
*
*
*  copy box submodes fill box table
*
handfill:
*	.dc.w	cbarx,cbary+16
*	.dc.w	cbarx+115,cbary+23
*	.dc.w	-1
pencfill:
fillfill:
erasfill:
jackfill:
miscfill:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+24
*
	.dc.w	-1
*
lindfill:
shapfill:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+24
*
	.dc.w	cbarx+14,cbary+59
	.dc.w	cbarx+32,cbary+59
*
	.dc.w	cbarx+14,cbary+64
	.dc.w	cbarx+32,cbary+65
*
	.dc.w	cbarx+14,cbary+70
	.dc.w	cbarx+32,cbary+72
*
	.dc.w	cbarx+14,cbary+78
	.dc.w	cbarx+32,cbary+81
*
	.dc.w	cbarx+48,cbary+51
	.dc.w	cbarx+66,cbary+55
*
	.dc.w	cbarx+48,cbary+58
	.dc.w	cbarx+66,cbary+63
*
	.dc.w	cbarx+48,cbary+66
	.dc.w	cbarx+66,cbary+72
*
	.dc.w	cbarx+48,cbary+75
	.dc.w	cbarx+66,cbary+82
*
	.dc.w	-1
*
*
shapicon:
	.dc.w	86			;open shapes icon
	.dc.w	cbarx+72,cbary+56
*
	.dc.w	19			;filled shapes icon
	.dc.w	cbarx+94,cbary+56
*
	.dc.w	87			;dotted line icon
	.dc.w	cbarx+13,cbary+52
*
shpicon:
	.dc.w	76			;rectangle
	.dc.w	cbarx+1,cbary+25
*
	.dc.w	77			;rounded rectangle
	.dc.w	cbarx+24,cbary+25
*
	.dc.w	78			;ellipse
	.dc.w	cbarx+47,cbary+25
*
	.dc.w	79			;kidney
	.dc.w	cbarx+70,cbary+25
*
	.dc.w	80			;polygon
	.dc.w	cbarx+93,cbary+25
*
	.dc.w	-1
handopen:
	.dc.w	cbarx,cbary+24
	.dc.w	cbarx+8,cbary+24
*
	.dc.w	cbarx+107,cbary+24
	.dc.w	cbarx+115,cbary+24
*
	.dc.w	cbarx+10,cbary+25
	.dc.w	cbarx+105,cbary+85
*
	.dc.w	-1
*
shapopen:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+48
*
	.dc.w	cbarx,cbary+48
	.dc.w	cbarx+68,cbary+85
*
	.dc.w	cbarx+68,cbary+48
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	-1
lindopen:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+47
*
	.dc.w	cbarx,cbary+47
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	-1
*
copyfill:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+74,cbary+24
*
	.dc.w	cbarx+76,cbary+16
	.dc.w	cbarx+115,cbary+24
*
	.dc.w	-1
*
*
copyopen:
	.dc.w	cbarx,cbary+24
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	cbarx+75,cbary+24
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	cbarx+75,cbary+47
	.dc.w	cbarx+115,cbary+65
*
	.dc.w	-1
*
*
copytxtd:
	.dc.w	0
	.dc.w	cbarx+13,cbary+18	;copy box
*
	.dc.w	0
	.dc.w	cbarx+85,cbary+18	;mode
*
cpytxtd:
	.dc.w	3
	.dc.w	cbarx+8,cbary+28	;cut
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+35	;copy
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+42	;paste
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+49	;clear
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+56	;rotate
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+63	;h-flip
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+70	;v-flip
*
	.dc.w	3
	.dc.w	cbarx+8,cbary+77	;t-edge
*
*  change the following to 3 if larger RAM system available
*
cpyafunc:
	.dc.w	-1
	.dc.w	cbarx+101,cbary+54	;f9
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+28	;f1
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+35	;f2
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+42	;f3
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+49	;f4
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+56	;f5
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+63	;f6
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+70	;f7
*
	.dc.w	3
	.dc.w	cbarx+57,cbary+77	;f8
*
	.dc.w	-1
*
copyicon:
	.dc.w	89
	.dc.w	cbarx+99,cbary+72	;"F10" icon
*
	.dc.w	75
	.dc.w	cbarx+77,cbary+49	;stretch icon
*
	.dc.w	74
	.dc.w	cbarx+77,cbary+67	;cswap icon
*
	.dc.w	64
	.dc.w	cbarx+81,cbary+26	;replace icon
*
	.dc.w	65
	.dc.w	cbarx+100,cbary+26	;transparent icon
*
	.dc.w	-1
jackicon:
	.dc.w	64
	.dc.w	cbarx+81,cbary+26	;replace icon
*
	.dc.w	65
	.dc.w	cbarx+100,cbary+26	;transparent icon
*
	.dc.w	90
	.dc.w	cbarx+88,cbary+50	;poiynt
*
	.dc.w	-1
*
*
*
titltxtd:
*	.dc.w	$10
*	.dc.w	cbarx+7,cbary+27	;SAMPLER
*
	.dc.w	0
	.dc.w	cbarx+35,cbary+51	;Designed
*
	.dc.w	0
	.dc.w	cbarx+29,cbary+59	;Programmed
*
	.dc.w	0
	.dc.w	cbarx+53,cbary+67	;by
*
	.dc.w	1
	.dc.w	cbarx+17,cbary+76	;DAVE STAUGAS
*
	.dc.w	-1
*
titlopen:
*	.dc.w	cbarx+7,cbary+35
*	.dc.w	cbarx+109,cbary+35
*
	.dc.w	-1
*
jjtxtd:
	.dc.w	0
	.dc.w	cbarx+14,cbary+27	;Smoke & Mirrors:
*
	.dc.w	1
	.dc.w	cbarx+11,cbary+35	;JIM EISENSTEIN
*
	.dc.w	0
	.dc.w	cbarx+34,cbary+51	;Graphics:
*
	.dc.w	1
	.dc.w	cbarx+11,cbary+59	;JEROME DOMURAT
*
*
	.dc.w	-1
*
*
*  Text submodes filled boxes data table..
*
textfill:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+24
*
	.dc.w	cbarx,cbary+67
	.dc.w	cbarx+40,cbary+75
*
	.dc.w	cbarx,cbary+77
	.dc.w	cbarx+29,cbary+85
*
	.dc.w	-1
*
*
*  Text submodes Open box data table..
*
textopen:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	cbarx,cbary+77
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	cbarx+78,cbary+16
	.dc.w	cbarx+115,cbary+77
*
	.dc.w	cbarx+40,cbary+67
	.dc.w	cbarx+78,cbary+75
*
	.dc.w	-1
*
*
*  text string placement data table..
*
texttxtd:
	.dc.w	$10
	.dc.w	cbarx+12,cbary+59	;outline
*
	.dc.w	0
	.dc.w	cbarx+14,cbary+18	;style
*
	.dc.w	0
	.dc.w	cbarx+85,cbary+18	;size
*
	.dc.w	0
	.dc.w	cbarx+6,cbary+69	;align
*
	.dc.w	0
	.dc.w	cbarx+3,cbary+79	;face
*
	.dc.w	0
	.dc.w	cbarx+13,cbary+26	;plain
*
	.dc.w	1
	.dc.w	cbarx+13,cbary+34	;bold
*
	.dc.w	4
	.dc.w	cbarx+13,cbary+42	;italic
*
	.dc.w	8
	.dc.w	cbarx+13,cbary+50	;underline
*
	.dc.w	$10
	.dc.w	cbarx+92,cbary+28	;6
*
	.dc.w	$10
	.dc.w	cbarx+92,cbary+36	;8
*
	.dc.w	0
	.dc.w	cbarx+91,cbary+45	;12
*
	.dc.w	$10
	.dc.w	cbarx+90,cbary+52	;14
*
	.dc.w	0
	.dc.w	cbarx+90,cbary+61	;16
*
	.dc.w	0
	.dc.w	cbarx+92,cbary+68	;28
*
txtsysd:
	.dc.w	0
	.dc.w	cbarx+32,cbary+79	;system
*
	.dc.w	-1
*
*
texticon:
	.dc.w	20
	.dc.w	cbarx+42,cbary+68	;left arrow
*
	.dc.w	21
	.dc.w	cbarx+54,cbary+68	;mid double bar
*
	.dc.w	22
	.dc.w	cbarx+66,cbary+68	;rite arrow
*
	.dc.w	-1
*
*
*
*
*
brshicon:
	.dc.w	26			;brush #1
	.dc.w	cbarx+7,cbary+31
*
	.dc.w	27			;brush #2
	.dc.w	cbarx+6,cbary+41
*
	.dc.w	28			;brush #3
	.dc.w	cbarx+6,cbary+52
*
	.dc.w	29			;brush #4
	.dc.w	cbarx+5,cbary+62
*
	.dc.w	30			;brush #5
	.dc.w	cbarx+4,cbary+72
*
*
	.dc.w	31			;brush #6
	.dc.w	cbarx+19,cbary+31
*
	.dc.w	32			;brush #7
	.dc.w	cbarx+19,cbary+41
*
	.dc.w	33			;brush #8
	.dc.w	cbarx+18,cbary+52
*
	.dc.w	34			;brush #9
	.dc.w	cbarx+18,cbary+63
*
	.dc.w	35			;brush #10
	.dc.w	cbarx+17,cbary+73
*
*
	.dc.w	36			;brush #11
	.dc.w	cbarx+32,cbary+31
*
	.dc.w	37			;brush #12
	.dc.w	cbarx+32,cbary+41
*
	.dc.w	38			;brush #13
	.dc.w	cbarx+32,cbary+52
*
	.dc.w	39			;brush #14
	.dc.w	cbarx+31,cbary+62
*
	.dc.w	40			;brush #15
	.dc.w	cbarx+30,cbary+73
*
*
	.dc.w	41			;brush #16
	.dc.w	cbarx+45,cbary+31
*
	.dc.w	42			;brush #17
	.dc.w	cbarx+45,cbary+41
*
	.dc.w	43			;brush #18
	.dc.w	cbarx+45,cbary+52
*
	.dc.w	44			;brush #19
	.dc.w	cbarx+44,cbary+62
*
	.dc.w	45			;brush #20
	.dc.w	cbarx+44,cbary+73
*
*
	.dc.w	46			;brush #21
	.dc.w	cbarx+59,cbary+31
*
	.dc.w	47			;brush #22
	.dc.w	cbarx+59,cbary+41
*
	.dc.w	48			;brush #23
	.dc.w	cbarx+59,cbary+52
*
	.dc.w	49			;brush #24
	.dc.w	cbarx+59,cbary+62
*
	.dc.w	50			;brush #25
	.dc.w	cbarx+59,cbary+73
*
*
	.dc.w	51			;brush #26
	.dc.w	cbarx+72,cbary+32
*
	.dc.w	52			;brush #27
	.dc.w	cbarx+71,cbary+43
*
	.dc.w	53			;brush #28
	.dc.w	cbarx+71,cbary+53
*
	.dc.w	54			;brush #29
	.dc.w	cbarx+70,cbary+64
*
	.dc.w	55			;brush #30
	.dc.w	cbarx+70,cbary+76
*
*
	.dc.w	56			;brush #31
	.dc.w	cbarx+85,cbary+32
*
	.dc.w	57			;brush #32
	.dc.w	cbarx+84,cbary+41
*
	.dc.w	58			;brush #33
	.dc.w	cbarx+83,cbary+51
*
	.dc.w	59			;brush #34
	.dc.w	cbarx+82,cbary+61
*
	.dc.w	60			;brush #35
	.dc.w	cbarx+82,cbary+72
*
*
	.dc.w	61			;brush #36
	.dc.w	cbarx+95,cbary+29
*
	.dc.w	62			;brush #37
	.dc.w	cbarx+96,cbary+51
*
	.dc.w	63			;brush #38
	.dc.w	cbarx+98,cbary+69
*
	.dc.w	-1
*
miscopen:
	.dc.w	cbarx+60,cbary+25
	.dc.w	cbarx+60,cbary+49
*
	.dc.w	cbarx+62,cbary+37
	.dc.w	cbarx+71,cbary+37
*
	.dc.w	cbarx+104,cbary+37
	.dc.w	cbarx+113,cbary+37
*
	.dc.w	cbarx,cbary+50
	.dc.w	cbarx+115,cbary+50
*
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	-1
jackopen:
	.dc.w	cbarx+75,cbary+16
	.dc.w	cbarx+115,cbary+85
*
brshopen:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	-1
brshfill:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+24
*
	.dc.w	-1
*
brshtxtd:
	.dc.w	0
	.dc.w	cbarx+22,cbary+18
*
	.dc.w	-1
*
misctxtd:
	.dc.w	0
	.dc.w	cbarx+28,cbary+18		;MISCELLANY
*
	.dc.w	0
	.dc.w	cbarx+19,cbary+28		;x: /y:
*
	.dc.w	0
	.dc.w	cbarx+74,cbary+27		;color
*
	.dc.w	0
	.dc.w	cbarx+68,cbary+43		;palette
*
	.dc.w	0
	.dc.w	cbarx+12,cbary+54		;CUT=>HEX .S FILE
*
	.dc.w	0
	.dc.w	cbarx+6,cbary+62		;MASK=>HEX .S FILE
*
	.dc.w	-1
*
anitxtd:
	.dc.w	0
	.dc.w	cbarx+22,cbary+18	;animate
*
	.dc.w	0
	.dc.w	cbarx+83,cbary+28	;file
aniloadd:
	.dc.w	0
	.dc.w	cbarx+80,cbary+40	;load
*
	.dc.w	3
	.dc.w	cbarx+80,cbary+48	;save
*
	.dc.w	0
	.dc.w	cbarx+84,cbary+56	;new
*
	.dc.w	0
	.dc.w	cbarx+80,cbary+69	;avail
*
	.dc.w	0
	.dc.w	cbarx+10,cbary+32	;add
*
	.dc.w	0
	.dc.w	cbarx+26,cbary+64	;del
*
animtxtd:
	.dc.w	0
	.dc.w	cbarx+90,cbary+78	;xx # avail
*
	.dc.w	0
	.dc.w	cbarx+39,cbary+32	;hold buffer #
*
	.dc.w	0
	.dc.w	cbarx+10,cbary+48	;previous #
*
	.dc.w	0
	.dc.w	cbarx+30,cbary+48	;current #
*
	.dc.w	0
	.dc.w	cbarx+52,cbary+48	;next #
*
	.dc.w	-1
*
anifill:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+24
*
	.dc.w	cbarx+72,cbary+26
	.dc.w	cbarx+115,cbary+34
*
	.dc.w	cbarx+72,cbary+67
	.dc.w	cbarx+115,cbary+75
*
	.dc.w	-1
*
aniopen:
	.dc.w	cbarx,cbary+16
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	cbarx+72,cbary+24
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	cbarx,cbary+75
	.dc.w	cbarx+115,cbary+85
*
	.dc.w	cbarx+7,cbary+30
	.dc.w	cbarx+29,cbary+38
*
	.dc.w	cbarx+36,cbary+30
	.dc.w	cbarx+51,cbary+38
*
	.dc.w	cbarx+26,cbary+45
	.dc.w	cbarx+44,cbary+55
*
	.dc.w	cbarx+27,cbary+46
	.dc.w	cbarx+43,cbary+54
*
	.dc.w	cbarx+23,cbary+62
	.dc.w	cbarx+45,cbary+70
*
	.dc.w	cbarx+8,cbary+46
	.dc.w	cbarx+22,cbary+54
*
	.dc.w	cbarx+50,cbary+46
	.dc.w	cbarx+64,cbary+54
*
	.dc.w	-1
*
aniicon:
	.dc.w	70
	.dc.w	cbarx+24,cbary+38
*
	.dc.w	70
	.dc.w	cbarx+44,cbary+38
*
	.dc.w	70
	.dc.w	cbarx+31,cbary+55
*
	.dc.w	69
	.dc.w	cbarx+37,cbary+38
*
	.dc.w	71
	.dc.w	cbarx+3,cbary+45
*
	.dc.w	72
	.dc.w	cbarx+63,cbary+45
*
	.dc.w	73
	.dc.w	cbarx+59,cbary+62
*
	.dc.w	-1
*
brushnbr:
	.dc.w	7		;currently selected brush
spraynbr:
	.dc.w	35		;currently selected spray can
cutx:
	.dc.w	0		;cut buffer box x position
cuty:
	.dc.w	0		;cut buffer box y position
cutwidth:
	.dc.w	0		;cut buffer box width (=0 if buffer free)
cuthite:
	.dc.w	0
hollow:
	.dc.w	0		;0=hollow shape, else = filled shape
linethik:
	.dc.w	1		;0-8, shapes perimeter line thickness
shapesel:
	.dc.w	2		;currently selected shape (0-4)
lindthik:
	.dc.w	1		;1-8, Linedraw line thickness
*
*
*  text strings go here
*
misctxts:
	.dc.b	"MISCELLANY",0
	.dc.b	"x: /y:",0
	.dc.b	"color",0
	.dc.b	"palette",0
	.dc.b	"CUT=>HEX .S FILE",0
	.dc.b	"MASK=>HEX .M FILE",0
copytxts:
	.dc.b	"COPY BOX",0
	.dc.b	"MODE",0
cpytxts:
	.dc.b	"CUT",0
	.dc.b	"COPY",0
	.dc.b	"PASTE",0
	.dc.b	"CLEAR",0
	.dc.b	"ROTATE",0
	.dc.b	"H-FLIP",0
	.dc.b	"V-FLIP",0
	.dc.b	"T-EDGE",0
*
	.dc.b	"F9",0
	.dc.b	"F1",0
	.dc.b	"F2",0
	.dc.b	"F3",0
	.dc.b	"F4",0
	.dc.b	"F5",0
	.dc.b	"F6",0
	.dc.b	"F7",0
	.dc.b	"F8",0
*
*	.dc.b	0
*
texttxts:
	.dc.b	"OUTLINE",0
	.dc.b	"S T Y L E",0
	.dc.b	"SIZE",0
	.dc.b	"ALIGN",0
	.dc.b	"FACE",0
	.dc.b	"PLAIN",0
	.dc.b	"BOLD",0
	.dc.b	"ITALIC",0
	.dc.b	"UNDERLINE",0
	.dc.b	"6 ",0
	.dc.b	"8 ",0
	.dc.b	"12 ",0
	.dc.b	"14",0
	.dc.b	"16",0
	.dc.b	"28",0
txtsyss:
	.dc.b	"SYSTEM       ",0
txtsysxs:
	.dc.b	"EXTENDED SYS.",0
*
titltxts:
	.dc.b	"Designed",0
	.dc.b	"Programmed",0
	.dc.b	"by",0
	.dc.b	"DAVE STAUGAS",0
*
jjtxts:
	.dc.b	"Smoke & Mirrors",0
	.dc.b	"JIM EISENSTEIN",0
	.dc.b	"Graphics",0
	.dc.b	"JEROME DOMURAT",0
*
jacktxts:
	.dc.b	"J A C K  K N I F E",0
jktxts:
	.dc.b	"CUT",0
	.dc.b	"COPY",0
	.dc.b	"PASTE",0
	.dc.b	"CLEAR",0
	.dc.b	"F1",0
	.dc.b	"F2",0
	.dc.b	"F3",0
	.dc.b	"F4",0
*
brshtxts:
	.dc.b	"B R U S H E S",0
sprytxts:
	.dc.b	"N O Z Z L E S",0
handtxts:
	.dc.b	"G R A B B E R",0
penctxts:
	.dc.b	"P E N C I L",0
lindtxts:
	.dc.b	"L. button = color",0
	.dc.b	"R. button = ramp",0
	.dc.b	"L I N E  D R A W",0
filltxts:
	.dc.b	"A R E A  F I L L",0
erastxts:
	.dc.b	"E R A S E R",0
shaptxts:
	.dc.b	"S H A P E S",0
anitxts:
	.dc.b	"A N I M A T E",0
	.dc.b	"FILE",0
aniloads:
	.dc.b	"LOAD ",0
	.dc.b	"SAVE ",0
	.dc.b	"NEW",0
	.dc.b	"MAX #",0
	.dc.b	"ADD",0
	.dc.b	"DEL",0
animtxts:
	.dc.b	"  ",0
	.dc.b	"XX",0
	.dc.b	"XX",0
	.dc.b	"XX",0
	.dc.b	"XX",0
*
checktxt:
	.dc.b	8,0			;check mark
*
empmsg:
	.dc.b	" Cut buffer empty ",0
fwtrmsg:
	.dc.b	" File write error ",0
sendmsg:
	.dc.b	"Making:"
filen:
	.dc.b	"FILENAME.S",0
blankmsg:
	.dc.b	"                  ",0
*
undostrg:
	.dc.b	"UNDO",0
*
*memstrng:
*	.dc.b	"FREE MEM: "
*memdigit:
*	.dc.b	"000000",0
*
*
*
textadj:
	.dc.b	0		;extended text access (0-normal,$80-extended)
*
	.even
spath:
	.dc.b	"COPYB*.S",0,0
dma:
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0
nexfile:
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0
*
gridon:
	.dc.b	0		;grid is on if -1, off if 0
xyplot:
	.dc.b	-1		;xyplot is on if -1, off if 0
*
*
*
	.bss
undopalt:
	.ds.w	16		;palette to undo to/from
nrmstack:
	.ds.l	1		;emergency exitstack pointer
snapnbr:
	.ds.w	1		;the x in COPYBx.S
handles:
	.ds.w	1		;COPYBx.S handle
cutfrm:
	.ds.w	1		;frame since last block flash
brshptr:
	.ds.l	1		;ptr to current brush
cutpath:
	.ds.b	40
*

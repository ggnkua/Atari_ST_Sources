**********************************************************
*
*  Animation stuff (controlled from fatmode & fatfun)
*
*
*  These are FATMODE externs & publics
*
	.include	"fatequ.s"
*
*  publics..
*
	.globl	animupd,holdptr,cut_nxln
	.globl	cellhite,cellwid,anibase,scr2cell,cellsize,cellx2sc
	.globl	anisped,cel2phys,curcell,cel2scr,aniend,aninext
	.globl	cellx2scr
*
*  externals..
*
	.globl	needothr,othsame,anistat,cbarx,cbary
	.globl	aniloadd,invanibk,showm,mouseget,hidem,cellcnt,gemready
	.globl	rezset,int_out,addr_in,fsel_inp,txstring,dskalrt0,alertout
	.globl	animtxts,rezclr,adiagy
	.globl	henabl,irqlev,newbox,adiagx
	.globl	aoriginx,aoriginy,shwboxz,anifitx,curscren,othscren
	.globl	dskalrt2,setanitx,putanitx,scr02scr,cutscren,cutx
	.globl	cuty,cutwidth,cpytxtd,physadd,screnswp,cuthite
*
*
**********************************************************
*
*  stuff taken from FATFUN
*
*	public
*
	.globl	anii,anid,aniupd,aniblank,anistrng
*
*	externals
*
	.globl	unundo,screen0,handy,chg2cur,full,chgxcur
	.globl	lastfrm,frmcnt,systxt6,p_block
	.globl	b_width,b_height,plane_ct,fg_col,bg_col,op_tab
	.globl	s_xmin,s_ymin,s_form,s_nxwd,s_nxln,s_nxpl
	.globl	d_xmin,d_ymin,d_form,d_nxwd,d_nxln,d_nxpl
	.globl	p_addr,bitblt
*
*
*
*
*  Animate functions --------------------------------------
*
*   anistat	bit0--1 if box in existence
*		bit1--1 if origin in existence
*		bit2--1 if box size locked (no click cancel)
*		bit3--1 if box contents is being dragged (right button down)
*		bit4--1 if continous animate mode
*		bit5--1 if reverse (right) direction if continuous animate
*		bit6--1 if box contents being dragged (via left button)
*
*
*  cell data structure (doubly linked list):
*
*
*
*		+---------------+---------------+
*  anihdptr --->|   BCD id #	|    Flags	|  D0-active,D1-1st
*		+---------------+---------------+
*		|				|
* cell prev <--	+	Previous cell ptr	+
*		|				|
*		+-------------------------------+
*		|				|
*		+	  Next cell ptr		+ -->cell next
*		|				|
*		+-------------------------------+
*		|				|
*		+	  Grafix data		+
*		|				|
*			.	.	.
*			.	.	.
*			.	.	.
*	
*
anii:
	jsr	unundo
	btst.b	#0,anistat
	beq.s	aniix
	bsr	newbox		;turn on box
	bsr	cel2scr
	movem.l	a0-a1/d4,-(sp)
	move.l	curscren,a0
	move.l	othscren,a1
	move.w	#999,d4
aniilp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d4,aniilp
	movem.l	(sp)+,a0-a1/d4
	move.b	#-1,needothr
aniix:
	rts
*
anid:
	btst.b	#0,anistat
	beq.s	anidx
	bsr	scr2cell	;copy screen to cell
	movem.l	a0-a1/d3-d4,-(sp)
	move.w	aoriginy,d3
	mulu	#160,d3
	movea.l	curscren,a0
	movea.l	screen0,a1
	adda.w	d3,a0
	adda.w	d3,a1
	move.w	handy,d3
	mulu	#160,d3
	adda.w	d3,a1
	move.w	cellhite,d4
	addq.w	#2,d4
	mulu	#10,d4
	bra.s	anidlpi
anidlp:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
anidlpi:
	dbra	d4,anidlp
	movem.l	(sp)+,a0-a1/d3-d4
*	bsr	newbox		;turn off box
*	
anidx:
	rts
*
*********************************************************
*
*  Animation update..
*
*
aniupd:
	tst.b	needothr	;check for othsame need
	beq.s	othok
	clr.b	needothr
	bsr	othsame
othok:
	btst.l	#2,d2		;leading edge on left?
	bne	leftclk
	btst.l	#4,d2		;trailing edge on left?
	beq	notrail		;br if no trailing edge
*
*  trailing edge on left
*
	bclr.b	#6,anistat	;dragging cell?
	beq.s	nocdrag
*
*  stop left button drag
*
	bsr	chg2cur		;go back to previous cursor
	bra	anix		; & exit
*
*	
nocdrag:
	btst.b	#1,anistat	;origin in existence?
	beq	anix		;exit if no origin
*
*  origin exists, set new box in existence
*
	bsr	newbox		;erase old box
	move.w	d0,d3
	andi.w	#$fff0,d3
	addi.w	#$10,d3
	cmpi.w	#320,d3
	bne.s	finbox
	move.w	#320-16,d3
finbox:
	move.w	d3,adiagx
	move.w	d1,adiagy
	bsr	newbox		;new box fixed
	move.b	#1,anistat	;set box in existence flag
*
	movea.l	#curcell,a0	;clear animation memory
	moveq	#5,d4		;ptrs (6 long words)
	moveq	#0,d5
clearani:
	move.l	d5,(a0)+
	dbra	d4,clearani
*
	movea.l	physadd,a0	;clear physadd screen
	move.w	#1999,d4	;for use by left button drag
	moveq	#0,d5
fizclr:
	move.l	d5,(a0)+
	move.l	d5,(a0)+
	move.l	d5,(a0)+
	move.l	d5,(a0)+
	dbra	d4,fizclr
*
	movem.w	d1/d3,-(sp)
*
	move.l	#-1,-(sp)	;see how much memory is available
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp		;d0.l has memory left
*
	movem.w	(sp)+,d1/d3
	move.w	aoriginx,d4
	addq.w	#1,d4
	move.w	d4,ahandx
	sub.w	d4,d3
	move.w	aoriginy,d4
	addq.w	#1,d4
	sub.w	d4,d1
	tst.w	full
	bne.s	skiphadd
	add.w	handy,d4
skiphadd:
	move.w	d4,ahandy
	lsr.w	#1,d3
	move.w	d3,cellwid
	move.w	d1,cellhite
	mulu	d1,d3		;d3=# of bytes needed for each cell
	add.w	#10,d3		;add overhead bytes
	move.w	d3,cellsize
	subi.l	#$A00,d0	;allow enough memory for file-selector
	bpl.s	memook
	moveq	#0,d0
memook:
	divu	d3,d0
	cmpi.w	#100,d0		;greater than 100?
	bcs.s	less100
	move.w	#99,d0
less100:
	mulu	d0,d3		;find size to allocate
	movem.l	d0/d3,-(sp)	;save max cell count
*
	move.l	d3,-(sp)	;allocate d3 bytes
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp		;d0.l has starting address
	move.l	d0,d1
*
	movem.l	(sp)+,d0/d3	;reget max cell count
	move.l	d1,anibase	;save animate buffers base address
	move.l	d1,aninext	;initialize first buffer to base
	add.l	d3,d1
	move.l	d1,aniend	;set end to last address +1
*
	ext.l	d0
	divu	#10,d0
	lea	digtab(pc),a0
	movea.l	#animtxts,a1
	move.b	(a0,d0.w),(a1)+
	swap	d0
	ext.l	d0
	move.b	(a0,d0.w),(a1)
	bsr	putanitx
	movea.l	curscren,a0
	movea.l	othscren,a1
	move.w	#1999,d0
anicpylp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,anicpylp
*
	bra	anix
*
*  no left lead or trailing edge..
*
notrail:
	btst.l	#3,d2		;right leading edge?
	beq	chkrbut		;br if not
*
	btst.b	#0,anistat
	beq	anix		;no box in existence, exit
*
*  start up box contents drag
*
	bset.b	#3,anistat	;tell 'em we're starting a drag
*
	move.w	#1,d0
	bsr	chgxcur		;change to hand cursor
*
*  Blit a box from pristine buffer..
*
aniblit:
	bsr.s	scr0scr
	bra	anix
*
*  Physadd to screen (using ohandy & ohandy)
*
phys2scr:
	move.w	ohandx,d3
	move.w	ohandy,d4
	movea.l	physadd,a0
	bra.s	scr2scr
*
*  called to replace pristine patch in animate window..
*
scr02scr:
	move.w	aoriginx,d0
	addq.w	#1,d0
	move.w	d0,ahandx
	move.w	aoriginy,d0
	addq.w	#1,d0
	tst.w	full
	bne.s	scr00
	add.w	handy,d0
scr00:
	move.w	d0,ahandy
*
*  blit screen0 to screen using ahandy & ahandx
*
scr0scr:
	movea.l	screen0,a0
	move.w	ahandx,d3
	move.w	ahandy,d4
scr2scr:
	movea.l	#p_block,a6		;base ptr for blt parm block
	move.w	cellwid,d0
	lsl.w	#1,d0
	move.w	d0,b_width(a6)		;set width
	move.w	cellhite,b_height(a6)	;set height
	move.l	a0,s_form(a6)		;get patch from virgin
	move.l	othscren,d_form(a6)
	move.w	d3,s_xmin(a6)
	move.w	aoriginx,d0
	addq.w	#1,d0
	move.w	d0,d_xmin(a6)
	move.w	d4,s_ymin(a6)
	move.w	aoriginy,d0
	addq.w	#1,d0
	move.w	d0,d_ymin(a6)
	move.w	#4,plane_ct(a6)		;always refresh plane count
	move.l	#$03030303,op_tab(a6)
*
	move.w	#8,s_nxwd(a6)		;set source normal lo rez screen
	move.w	#160,s_nxln(a6)
	move.w	#2,s_nxpl(a6)
*
	move.w	#8,d_nxwd(a6)		;set destination normal lo rez screen
	move.w	#160,d_nxln(a6)
	move.w	#2,d_nxpl(a6)
*
	move.w	lastfrm,d7
frwait:
	cmp.w	frmcnt,d7
	beq.s	frwait
*
	.dc.w	bitblt			;blit background to cover old copybox
*
	move.w	frmcnt,lastfrm
	bsr	screnswp
	rts
*
*  check if button down
*
chkrbut:
	btst.l	#0,d2		;left button down?
	beq.s	chhrbut		;br if not

	btst.b	#6,anistat	;in left drag mode?
	beq.s	chhrbut		;br if not
*
	sub.w	d0,d3		;check delta x
	add.w	d3,ohandx	;adjust base x
	bpl.s	chhb1
	clr.w	ohandx
chhb1:
	move.w	cellwid,d3
	lsl.w	#1,d3
	add.w	ohandx,d3
	sub.w	#320,d3
	bcs.s	chhb2
	sub.w	d3,ohandx
chhb2:
	sub.w	d1,d4
	add.w	d4,ohandy
	bpl.s	chhb3
	clr.w	ohandy
chhb3:
	move.w	cellhite,d4
	add.w	ohandy,d4
	sub.w	#199,d4
	bcs.s	chhb4
	sub.w	d4,ohandy
chhb4:
	bsr	phys2scr
	bra	anix
chhrbut:
	btst.l	#1,d2		;right button down?
	beq.s	chkrrel		;br if not
	btst.b	#3,anistat	;in drag mode?
	beq.s	chkrrel		;br if not
*
	sub.w	d0,d3		;check delta x
	add.w	d3,ahandx	;adjust base x
	bpl.s	chkrb1
	clr.w	ahandx
chkrb1:
	move.w	cellwid,d3
	lsl.w	#1,d3
	add.w	ahandx,d3
	sub.w	#320,d3
	bcs.s	chkrb2
	sub.w	d3,ahandx
chkrb2:
	sub.w	d1,d4
	add.w	d4,ahandy
	bpl.s	chkrb3
	clr.w	ahandy
chkrb3:
	move.w	cellhite,d4
	add.w	ahandy,d4
	sub.w	#199,d4
	bcs.s	chkrb4
	sub.w	d4,ahandy
chkrb4:
	bra	aniblit
*
*  check right button release..
*
chkrrel:
	btst.l	#5,d2		;right button release?
	beq.s	chklbut
	bclr.b	#3,anistat
	beq.s	chklbut
	bsr	chg2cur		;go back to previous cursor
	bra	anix
*
*  check left button down
*
chklbut:
	btst.l	#0,d2		;left button down?
	beq	anix		;exit if not down
	btst.b	#1,anistat	;origin in existence?
	beq	anix		;no box started, so exit
	bsr	newbox		;erase old box
	move.w	d0,d3
	andi.w	#$fff0,d3
	addi.w	#$10,d3
	cmpi.w	#320,d3
	bne.s	grobox
	move.w	#320-16,d3
grobox:
	move.w	d3,adiagx
	move.w	d1,adiagy
	bsr	newbox
*
*  tell user box size..(entry point used by fatmode ani init)
*
shwboxz:
	move.w	adiagx,d3
	move.w	adiagy,d1
	sub.w	aoriginx,d3
	subq.w	#1,d3
	cmpi.w	#320,d3
	bcs.s	inbnds
	move.w	#999,d3
inbnds:
	move.w	d1,d4
	sub.w	aoriginy,d4
	subq.w	#1,d4
	cmpi.w	#320,d4
	bcs.s	inbndz
	move.w	#999,d4
inbndz:
*
*	d3.w- x:xxx
*	d4.w- y:xxx
*
putcoord:
	tst.w	full
	bne	anix
	movea.l	#aniwid,a0
	ext.l	d3
	divu	#100,d3
	move.b	digtab(pc,d3.w),(a0)+
	swap	d3
	ext.l	d3
	divu	#10,d3
	move.b	digtab(pc,d3.w),(a0)+
	swap	d3
	move.b	digtab(pc,d3.w),(a0)
*
	movea.l	#anihite,a0
	ext.l	d4
	divu	#100,d4
	move.b	digtab(pc,d4.w),(a0)+
	swap	d4
	ext.l	d4
	divu	#10,d4
	move.b	digtab(pc,d4.w),(a0)+
	swap	d4
	move.b	digtab(pc,d4.w),(a0)
	movea.l	#anistrng,a0
blnketry:
	move.w	#cbarx+4,d0
	move.w	#cbary+78,d1
	moveq	#0,d2
	bsr	systxt6
	bra	anix	
*
digtab:
	.dc.b	"0123456789"
*
leftclk:
	btst.b	#0,anistat	;box in existence?
	beq	startbox
	btst.b	#2,anistat	;box size locked?
	beq.s	boxcancl	;br to cancel box if not locked
*
*  left button click (start drag)
*
	move.w	#1,d0
	bsr	chgxcur		;change to hand cursor
	bset.b	#6,anistat	;set left button drag
	bsr	cel2phys	;copy cell contents to physadd buffer
	move.w	aoriginx,d3
	addq.w	#1,d3
	move.w	d3,ohandx
	move.w	aoriginy,d3
	addq.w	#1,d3
	move.w	d3,ohandy
	bsr	phys2scr
	bra	anix
boxcancl:
*
*  cancel box
*
*  free up animation memory
*
	move.l	anibase,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.l	anibase
	clr.l	aninext
	clr.l	aniend
	clr.l	curcell
*
	bsr	newbox
	clr.b	anistat
	move.b	#" ",d0
	move.b	d0,animtxts
	move.b	d0,animtxts+1
	movea.l	#aniblank+9,a0
	move.w	#cbarx+90,d0
	move.w	#cbary+78,d1
	moveq	#0,d2
	bsr	systxt6
	movea.l	#aniblank,a0
	bra	blnketry
*
*  start new box
*
startbox:
	move.w	d0,d3
	andi.w	#$fff0,d3
	subi.w	#$10,d3
	bpl.s	stbox
	moveq	#0,d3
stbox:
	addi.w	#$f,d3
	move.w	d3,aoriginx
	move.w	d1,aoriginy
	addq.w	#1,d3
	move.w	d3,adiagx
	move.w	d1,adiagy
	move.b	#2,anistat
	bsr	newbox
anix:
	rts
*
*
*
**********************************************************
*
*  update animation control box (from FATMODE)
*
animupd:
	tst.b	needothr
	beq.s	othrok
	clr.b	needothr
	bsr	othsame
othrok:
	move.b	anistat,d6	;get status in reg
*
	cmpi.w	#cbarx+74,d0
	bcs	notfile
	cmpi.w	#cbarx+115,d0
	bcc	animxit
	move.w	d1,d5
	subi.w	#cbary+39,d5
	bcs	animxit
	lsr.w	#3,d5
	cmpi.w	#3,d5
	bcc	animxit
*
*  d5 = 0-load, 1-save, 2-new
*
	btst.l	#4,d6		;animation in progress?
	bne	animxit		;exit if so--can't do file access
*
	btst.l	#2,d2			;left click
	beq	animxit			;br if no click
	move.w	d5,d7
	mulu	#6,d7
	movea.l	#aniloadd,a4
	tst.w	(a4,d7.w)
	bne	animxit
	bsr	invanibk		;invert block
	bsr	showm
anifilp:
	move.w	d5,-(sp)		;save block #
	bsr	mouseget
	move.w	(sp)+,d5		;reget block #
	btst.l	#4,d2			;left button released?
	bne.s	anidfido		;br to do if so
	cmpi.w	#cbarx+74,d0
	bcs.s	anifioff
	cmpi.w	#cbarx+113,d0
	bcc.s	anifioff
	move.w	d1,d4
	sub.w	#cbary+39,d4
	bcs.s	anifioff
	lsr.w	#3,d4
	cmpi.w	#3,d4
	bcc.s	anifioff
	cmp.w	d4,d5
	beq.s	anifilp
	tst.w	d5
	bmi.s	d5min
	bsr	hidem
	bsr	invanibk
d5min:
	move.w	d4,d5
	move.w	d5,d7
	mulu	#6,d7
	tst.w	(a4,d7.w)
	beq.s	doinvx
	moveq	#-1,d5
	bra.s	notinv
doinvx:
	bsr	hidem
	bsr	invanibk
notinv:
	bsr	showm
	bra.s	anifilp
anifioff:
	tst.w	d5
	bmi.s	d5min1
	bsr	hidem
	bsr	invanibk		;turn off block
	bsr	showm
d5min1:
	moveq	#-1,d5
	bra.s	anifilp
anidfido:
	bsr	hidem
	tst.w	d5
	bmi	animxit
	bsr	invanibk		;turn off block
*
*  do function specified in d5.w (0-load,1-save,2-new)
*
*
	cmpi.w	#2,d5
	bne.s	filstuff
*
*  do new..
*
	tst.w	cellcnt
	beq	animxit
*
	move.l	anibase,aninext
	clr.l	holdptr
	clr.l	freeptr
	clr.w	cellcnt
	bra	maingone
*
*  load/save
*
filstuff:
	move.w	d5,-(sp)		;load/save save
*
*  get animate filename
*
	bsr	gemready		;disable h-blank, flush buttons
	bsr	hidem
	bsr	rezset
	bsr	showm
*
unbutton:
	bsr	mouseget		;wait till user releases button
	andi.w	#3,d2
	bne.s	unbutton
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
	move.b	#"A",(a0)+
	move.b	#"N",(a0)+
	move.b	#"I",(a0)+
	move.b	#0,(a0)
*
gotpath:
	clr.w	int_out+0
	clr.w	int_out+2
	move.l	#fs_inpat,addr_in
	move.l	#fs_insel,addr_in+4
	bsr	fsel_inp
*
	bsr	hidem
*
	move.w	int_out+2,d0	;check exit type
	cmpi.b	#1,d0		;"ok" on select?
	bne	docancl
*
*  loading/saving new animate file
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
*
	move.w	(sp)+,d5		;reget load/save (0-load, 1-save)
*
*  check read/write
*
	cmpi.w	#1,d5			;save (write)?
	beq	aniwrit			;br if so--do write
*
*  read new anifile
*
	move.w	#0,-(sp)		;open for read
	move.l	#txstring,-(sp)		;use this for total pathname
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handlea
	bpl.s	goodrd
badrd:
	move.l	#dskalrt0,d0
	bsr	alertout
	bra	b2ani
goodrd:
	btst.b	#0,anistat		;is box in existence?
	beq.s	boxno
*
*  de-allocate memory
*
	move.l	anibase,-(sp)
	move.w	#$49,-(sp)		;de-allocate memory
	trap	#1
	addq.l	#6,sp
	clr.l	anibase
	clr.l	curcell
boxno:
	move.l	#aniheadr,-(sp)
	move.l	#aniendr-aniheadr,-(sp)
	move.w	handlea,-(sp)
	move.w	#$3f,-(sp)
	trap	#1			;read header
	add.w	#12,sp
*
	cmpi.w	#aniendr-aniheadr,d0
	bne.s	badrd
*
	move.l	#-1,-(sp)
	move.w	#$48,-(sp)		;see how much memory is left
	trap	#1
	addq.l	#6,sp
*
	subi.l	#$a00,d0
	bpl.s	memoook
	moveq	#0,d0
memoook:
	moveq	#0,d3
	move.w	cellsize,d3
	beq	b2ani
	divu	d3,d0
	cmpi.w	#100,d0
	bcs.s	les100
	moveq	#99,d0
les100:
	cmp.w	cellcnt,d0
	bcc.s	itfitz
	move.l	#sizalrt,d0
	bsr	alertout
	clr.w	cellcnt
	bra	b2ani
itfitz:
	mulu	d0,d3
*
	movem.l	d0/d3,-(sp)
*
	move.l	d3,-(sp)		;allocate this much memory
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
*
	move.l	d0,d1
	movem.l	(sp)+,d0/d3
	move.l	d1,anibase
	move.l	d1,aninext
	add.l	d3,d1
	move.l	d1,aniend
*
	ext.l	d0
	divu	#10,d0
	lea	digtab10(pc),a0
	movea.l	#animtxts,a1
	move.b	(a0,d0.w),(a1)+		;tell user how many max.
	swap	d0
	move.b	(a0,d0.w),(a1)
*
	movea.l	anibase,a0
	move.l	a0,curcell
	moveq	#1,d1
	move.w	cellcnt,d2
	subq.w	#1,d2
	move.w	cellsize,d3
	andi.l	#$FFFF,d3
	subi.l	#10,d3
*
	move.l	a0,a1
	move.b	d1,(a0)+
	clr.b	(a0)+
	move.l	a1,(a0)+
	move.l	a1,(a0)+
	bra.s	celrdlpi
*
cellrdlp:
	lea	(a0,d3),a1	;a1 -> next node
	addq.w	#1,d1		;increment id #
	move.l	-4(a0),a2	;save next node addr from last read
	move.l	a1,-4(a0)	;install new node addr there
	move.l	2(a2),a3	;get prev addr in old next node
	move.l	a1,2(a2)	;put new prev in
*
	move.b	d1,(a1)+	;put in id #
	clr.b	(a1)+		;flags

	move.l	a3,(a1)+	;put in new prev
	move.l	a2,(a1)+	;put in new next
	move.l	a1,a0
*
celrdlpi:
	movem.w	d1-d2,-(sp)
*
	move.l	a0,-(sp)
	move.l	d3,-(sp)
	move.w	handlea,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,d3
	move.l	(sp)+,a0
*
	movem.w	(sp)+,d1-d2
*
	cmp.l	d3,d0
	bne	badrd
	dbra	d2,cellrdlp
*
	move.l	anibase,curcell
	lea	(a0,d3),a0	;a0 -> next node
	move.l	a0,aninext
	clr.l	holdptr
	clr.l	freeptr
*
	bsr	hidem
	bsr	rezclr
*
	move.w	#-1,henabl
	move.w	#$2500,irqlev
*
	btst.b	#0,anistat		;previous box in existence?
	beq.s	nobox1
	bsr	newbox			;erase old box
nobox1:
	move.b	#5,anistat	;set box in existence & box locked bits
	move.w	cellwid,d0
	lsl.w	#1,d0
	addq.w	#1,d0
	add.w	aorgx,d0
	move.w	d0,adiagx
	move.w	cellhite,d0
	add.w	aorgy,d0
	addq.w	#1,d0
	move.w	d0,adiagy
	move.w	aorgx,aoriginx
	move.w	aorgy,aoriginy
*
	bsr	shwboxz			;display new box dimensions
*
	bsr	newbox
*
	move.w	#3,aniloadd		;disable load
	move.w	#0,aniloadd+6		;enable save
	bsr	anifitx
*
	movea.l	curscren,a0
	movea.l	othscren,a1
	move.w	#999,d0
anicop:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,anicop
*
	bra	docello
*
digtab10:
	.dc.b	"0123456789"
*  
*  write new anifile
*
aniwrit:
	move.w	aoriginx,aorgx
	move.w	aoriginy,aorgy
*
	move.w	#0,-(sp)
	move.l	#txstring,-(sp)		;use this for total pathname
	move.w	#$3c,-(sp)		;create new file
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handlea
	bmi.s	badwrit
*
	move.l	#aniheadr,-(sp)
	move.l	#aniendr-aniheadr,-(sp)
	move.w	handlea,-(sp)
	move.w	#$40,-(sp)
	trap	#1			;write header
	add.w	#12,sp
*
	cmpi.w	#aniendr-aniheadr,d0
	beq.s	goodwrt
badwrit:
	move.l	#dskalrt2,d0
	bsr	alertout
	bra.s	b2ani
goodwrt:
	move.w	cellsize,d1
	subi.w	#10,d1
	andi.l	#$FFFF,d1
	movea.l	curcell,a0
	move.b	(a0),d0
	ext.w	d0
	subq.w	#1,d0
	bra.s	onelpi
onelp:
	move.l	2(a0),a0		;get #1 cell
onelpi:
	dbra	d0,onelp
*
	movea.l	a0,a1
cellwrit:
	move.l	a1,-(sp)		;save cell #1 on stack
*
	adda.w	#10,a0
	move.l	a0,-(sp)
	move.l	d1,-(sp)
	move.w	handlea,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	addq.w	#4,sp
	move.l	(sp)+,d1
	move.l	(sp)+,a0
	suba.w	#10,a0
*
	move.l	(sp)+,a1
	cmp.l	d1,d0
	bne.s	badwrit
*
	move.l	6(a0),a0
	cmpa.l	a0,a1
	bne.s	cellwrit
*
	move.w	handlea,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			;close file
	addq.l	#4,sp
*
	bra.s	b2ani
*
*  Cancel goes here..
*
docancl:
	addq.l	#2,sp			;cancel load/save on stack
b2ani:
	bsr	hidem
	bsr	rezclr
*
	move.w	#-1,henabl
	move.w	#$2500,irqlev
*
	bra	animxit
*
*  Do non-file clicks here...
*
notfile:
	move.w	d2,d3
	andi.w	#$C,d3		;left or right click?
	beq	animxit		;br if not
*
*  check ADD box..
*
	cmpi.w	#cbary+30,d1
	bcs	anim1
	cmpi.w	#cbary+39,d1
	bcc	anim1
	cmpi.w	#cbarx+7,d0
	bcs	anim1
	cmpi.w	#cbarx+30,d0
	bcc	anim1
*
*  ADD box clicked..
*
	btst.l	#4,d6		;animation in progress?
	bne	animxit		;exit if so--can't add a box now
	btst.l	#0,d6		;box in existence?
	beq	animxit		;br if not
	bset.b	#2,anistat	;lock box
*
	move.l	freeptr,d0	;check for any in free list
	beq.s	nofree		;br if none on free list
*
*  need to seach free list for next cell..
*
	movea.l	d0,a0
	move.l	6(a0),freeptr	;set free list ptr to next
	bra.s	doalloc1
nofree:
*
	move.l	aninext,a0
	cmpa.l	aniend,a0
	beq	animxit		;exit if ran out of ram
	move.l	a0,d0
	adda.w	cellsize,a0
	move.l	a0,aninext
doalloc1:
	moveq	#0,d2		;set add flag
*
doalloc:
	addq.w	#1,cellcnt
	cmpi.w	#1,cellcnt		;1st cell allocated?
	bne.s	notfirst
*
*  set-up first allocation..
*
	move.w	#3,aniloadd		;disable load
	move.w	#0,aniloadd+6		;enable save
	bsr	anifitx			;display
*
	move.l	d0,curcell
	movea.l	d0,a0
	move.w	#$0101,(a0)+	;give it #1, set flags for active
	move.l	d0,(a0)+	;set up links to itself
	move.l	d0,(a0)+
	tst.w	d2
	beq.s	docelli
*
*  insert new cell but don't clear it (from hold stack)
*
docello:
	bsr	setanitx
	bsr	putanitx
	bsr	cell2scr
	bra	animxit
notfirst:
	bsr	scr2cell	;save old current screen to old current cell
	movea.l	curcell,a0	;get curcell ptr in a0
	move.b	(a0),d1		;get id #
	movea.l	a0,a1
addloop:
	movea.l	6(a1),a1
	cmp.b	(a1),d1		;check other id's for add
	bcc.s	noadd
	addq.b	#1,(a1)
noadd:
	cmpa.l	a0,a1
	bne.s	addloop
	addq.b	#1,d1	
*
	move.l	6(a0),a1	;get next cell ptr in a1
	move.l	d0,2(a1)	;set next cell's prev ptr to new one
	move.l	d0,6(a0)	;set current cell's next ptr to new one
	move.l	d0,curcell
	move.l	d0,a2
	move.b	d1,(a2)		;put id # in
	move.b	#1,1(a2)
	move.l	a0,2(a2)	;set new one's prev pointer to old current
	move.l	a1,6(a2)	;set new one's next pointer to next 
	tst.w	d2		;new one or from hold buffer?
	bne.s	docello
docelli:
	bsr	blk2scr		;blank screen
	bsr	scr2cell	; & cell too
dotex:
	bsr	setanitx
	bsr	putanitx
	bra	animxit
*
*  check DEL box
*
anim1:
	cmpi.w	#cbary+62,d1
	bcs	anim2
	cmpi.w	#cbary+70,d1
	bcc	anim2
	cmpi.w	#cbarx+23,d0
	bcs	anim2
	cmpi.w	#cbarx+46,d0
	bcc	anim2
*
*  DEL box clicked..
*
	btst.l	#4,d6		;animation in progress?
	bne	animxit		;exit if so--no DEL's allowed at this time
	movea.l	#freeptr,a4	;use free list for delete (else, hold list)
delit:
	tst.w	cellcnt
	beq	animxit
*
	move.l	curcell,a0	;get current cell
	move.l	(a4),a1		; & place on free cell list (or hold list)
	move.l	a0,(a4)
*
	move.b	(a0),d3			;get id #
	move.l	2(a0),a2		;prev ptr
	move.l	6(a0),a3		;next ptr
	move.l	a1,6(a0)		;install deleted cell in free list
*
	subq.w	#1,cellcnt
	bne.s	notnull
*
*  nothing left, so put ptr's to sleep
*
maingone:
	clr.l	curcell
	bsr	scr02scr	;put screen0 stuff back here
	tst.l	holdptr		;anything in hold buffer?
	beq.s	setfitx		;br if no-- free memory
	move.w	#3,aniloadd	;disable load
	move.w	#3,aniloadd+6	;disable save
	bra.s	setfitx1	
setfitx:
	bclr.b	#2,anistat	;unlock box so it can be deleted
	move.w	#0,aniloadd	;enable load
	move.w	#3,aniloadd+6	;disable save
setfitx1:
	bsr	anifitx		;display
	bra	dotex
notnull:
	move.l	a3,6(a2)
	move.l	a2,2(a3)	;hook up previous-next
	move.l	a2,curcell
	movea.l	a2,a3
subloop:
	move.l	6(a3),a3
	cmp.b	(a3),d3
	bcc.s	nosub
	subq.b	#1,(a3)
nosub:
	cmpa.l	a3,a2
	bne.s	subloop
*
	bsr	cell2scr
	bsr	dotex
anim2:
*
*  check LEFT box..
*
	cmpi.w	#cbary+46,d1
	bcs	anim3
	cmpi.w	#cbary+55,d1
	bcc	anim3
	cmpi.w	#cbarx+4,d0
	bcs	anim3
	cmpi.w	#cbarx+23,d0
	bcc	anim3
*
*  click on left box
*
	btst.l	#4,d6		;continuous animate?
	bne.s	leftc		;br if continous
*
	btst.l	#2,d2		;left click?
	bne.s	anim2x		;br if so--do single step
*
*  start up animation..
*
	move.w	cellcnt,d0
	cmpi.w	#2,d0
	bcs	animxit		;skip animation if 1 or less cell
	bset.b	#4,anistat	;else, set continous	
	bclr.b	#5,anistat	;moving forward (left)
*
*   put in inverse block here if so inclined
*
*	move.l	curcell,d0
*	beq.s	animxit
*	move.l	d0,a0
*	move.l	6(a0),curcell	;prepare othscren with next animate step
*	bsr	cellx2scr
*
	bra	animxit
*
*  click on left button while in continuous
*
leftc:
	btst.l	#5,d6		;moving reverse (right)?
	bne.s	cstop		;br if so--stop continous
*
*  left click increases/right decreases speed..
*
adsbsped:
	btst.l	#2,d2		;left click?
	bne.s	addsped		;br if left
	addq.w	#1,anisped
	bra	animxit
addsped:
	subq.w	#1,anisped
	bne	animxit
	move.w	#1,anisped
	bra	animxit
*
cstop:
	andi.b	#$cf,d6		;turn off continous (bit4 & bit5)
	move.b	d6,anistat
	bra	dotex
*
anim2x:
	tst.l	curcell
	beq	animxit			;ignore empty clicks
	bsr	scr2cell
	movea.l	curcell,a0
	move.l	6(a0),curcell
	bsr	cell2scr
	bra	dotex
*
anim3:
*
*  check RIGHT box..
*
	cmpi.w	#cbary+46,d1
	bcs	anim4
	cmpi.w	#cbary+55,d1
	bcc.s	anim4
	cmpi.w	#cbarx+50,d0
	bcs.s	anim4
	cmpi.w	#cbarx+69,d0
	bcc.s	anim4
*
*  click on RIGHT box..
*
	btst.l	#4,d6		;continuous animate?
	bne.s	ritec		;br if continous
*
	btst.l	#2,d2		;left click?
	bne.s	anim3x		;br if so--do single step
*
*  start up animation..
*
	move.w	cellcnt,d0
	cmpi.w	#2,d0
	bcs	animxit		;skip animation if 1 or less cell
	bset.b	#4,anistat	;else, set continous	
	bset.b	#5,anistat	;moving in reverse (right)
*
*   put in inverse block here if so inclined
*
*	move.l	curcell,d0
*	beq.s	animxit
*	move.l	d0,a0
*	move.l	2(a0),curcell
*	bsr	cellx2scr
	bra	animxit
*
*
ritec:
	btst.l	#5,d6		;moving in reverse (right)?
	beq.s	cstop		;br if not--stop continous
*
*  left click increases/right decreases speed..
*
	eori.w	#$c,d2
	bra	adsbsped
anim3x:
	tst.l	curcell
	beq	animxit			;ignore empty clicks
	bsr	scr2cell
	movea.l	curcell,a0
	move.l	2(a0),curcell
	bsr	cell2scr
	bra	dotex
*
anim4:
*
*  check HOLD box..
*
	cmpi.w	#cbary+30,d1
	bcs.s	anim5
	cmpi.w	#cbary+39,d1
	bcc.s	anim5
	cmpi.w	#cbarx+36,d0
	bcs.s	anim5
	cmpi.w	#cbarx+52,d0
	bcc.s	anim5
*
*  click on HOLD box
*
	btst.l	#4,d6
	bne	animxit			;skip if continous animation
*
	move.l	holdptr,d0		;check holding stack
	beq	animxit			;exit if none on stack
	move.l	d0,a0
	move.l	6(a0),holdptr		;remove cell from hold list
	moveq	#-1,d2
	bra	doalloc			;allocate new but don't clear it
*
anim5:
*
*  check MAIN box..
*
	cmpi.w	#cbary+45,d1
	bcs.s	anim6
	cmpi.w	#cbary+56,d1
	bcc.s	anim6
	cmpi.w	#cbarx+26,d0
	bcs.s	anim6
	cmpi.w	#cbarx+45,d0
	bcc.s	anim6
*
*  click on MAIN box
*
	btst.l	#4,d6
	bne	animxit			;skip if continous animation
*
	movea.l	#holdptr,a4
	bra	delit			;"delete" it to hold list
*
anim6:
*
*  check COPY box..
*
	cmpi.w	#cbary+63,d1
	bcs	anim7
	cmpi.w	#cbary+74,d1
	bcc.s	anim7
	cmpi.w	#cbarx+60,d0
	bcs.s	anim7
	cmpi.w	#cbarx+71,d0
	bcc.s	anim7
*
*  click on COPY box
*
	btst.l	#4,d6
	bne.s	animxit			;skip if continous animation
*
	movea.l	curscren,a0
	movea.l	cutscren,a1
	move.w	#999,d0
anicplp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,anicplp
*
	move.w	aoriginx,d0
	addq.w	#1,d0
	move.w	d0,cutx
	move.w	aoriginy,d0
	addq.w	#1,d0
	move.w	d0,cuty
	move.w	cellwid,d0
	lsl.w	#1,d0
	move.w	d0,cutwidth
	move.w	cellhite,cuthite
	move.w	#160,cut_nxln
	move.w	#0,cpytxtd+12
*
anim7:
*
animxit:
	rts
*
*
*
cellx2scr:
	movem.l	a0-a6/d0-d7,-(sp)
	movea.l	othscren,a0
	bsr	setcell
	beq	nullcell	;br to blank screen if no cell
	bsr.s	clrclli
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
cel2scr:
	movem.l	a0-a6/d0-d7,-(sp)
	movea.l	curscren,a0
	bsr	setcell
	beq.s	nlcel1		;br to blank screen if no cell
	bsr.s	clrclli
nlcel1:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
cel2phys:
	movem.l	a0-a6/d0-d7,-(sp)
	movea.l	physadd,a0
	bsr	setcell
	beq.s	nlcel2		;br to blank screen if no cell
	bsr.s	clrclli
nlcel2:
	movem.l	(sp)+,a0-a6/d0-d7
	rts

*
*
*
cell2scr:
	movem.l	a0-a6/d0-d7,-(sp)
	movea.l	othscren,a0
	bsr	setcell
	beq.s	nullcell	;br to blank screen if no cell
	bsr.s	clrclli
	bsr	screnswp
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*	
*  tricky entry point at clrclli
*
clrclly:
	move.w	d1,d4
	bra.s	clrcllz
clrcllx:
	move.l	(a1)+,(a0)+
clrcllz:
	dbra	d4,clrcllx
	adda.w	d3,a0
clrclli:
	dbra	d2,clrclly
	rts
*
*
*
blk2scr:
	movem.l	a0-a6/d0-d7,-(sp)
	movea.l	othscren,a0
	bsr.s	setcell
nullcell:
	moveq	#0,d0
	bra.s	clclli
clclly:
	move.w	d1,d4
	bra.s	clcllz
clcllx:
	move.l	d0,(a0)+
clcllz:
	dbra	d4,clcllx
	adda.w	d3,a0
clclli:
	dbra	d2,clclly
	bsr	screnswp
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
scr2cell:
	movem.l	a0-a6/d0-d7,-(sp)
	movea.l	curscren,a0
	bsr.s	setcell
	beq.s	clrcello	;br to exit if no curcell
	bra.s	clrcelli
clrcelly:
	move.w	d1,d4
	bra.s	clrcellz
clrcellx:
	move.l	(a0)+,(a1)+
clrcellz:
	dbra	d4,clrcellx
	adda.w	d3,a0
clrcelli:
	dbra	d2,clrcelly
clrcello:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
setcell:
	move.w	aoriginx,d1
	addq.w	#1,d1
	lsr.w	#1,d1
	move.w	aoriginy,d2
	addq.w	#1,d2
	mulu	#160,d2
	add.w	d1,d2
	adda.w	d2,a0
*
	movea.l	curcell,a1
	adda.w	#10,a1
	move.w	cellwid,d1
	move.w	#160,d3
	sub.w	d1,d3
	move.w	cellhite,d2
	lsr.w	#2,d1
	cmpa.l	#10,a1
	rts
*
*
*  animate file header
*
aniheadr:
	.dc.l	$BABEEBEA	;magic number for anifiles
cellwid:
	.dc.w	0		;# cell bytes/scanline (must be 0 mod 8)
cellhite:
	.dc.w	0		;# scanlines/cell
cellsize:
	.dc.w	0		;# of bytes/cell (including 10 byte overhead)
aorgx:
	.dc.w	0		;xpos of animate box top/left origin
aorgy:
	.dc.w	0		;ypos of animate box top/left origin
cellcnt:
	.dc.w	0		;# of cells
anisped:
	.dc.w	20		;# of frames before next animation change
pathcnt:
	.dc.w	0		;# of path entries
pspeed:
	.dc.w	0		;# of frames before next path entry used
aniendr:
*
*
sizalrt:
	.dc.b	"[3][Not enough RAM for|this .ANI file..][OK]",0
pathgot:
	.dc.b	0
path:
	.dc.b	"ANNIE.ANI",0
*	.ds.b	32
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
*
anistrng:
	.dc.b	"x:"
aniwid:
	.dc.b	"000 y:"
anihite:
	.dc.b	"000",0
anistat:
	.dc.b	0
aniblank:
	.dc.b	"           ",0
needothr:
	.dc.b	0		;0-normal; -1 if animate needs othsame call
*
	.bss
*
*
*  uninitialized data from FATFUN ani stuff
*
*
*
*  animate stuff
*
aoriginx:
	.ds.w	1	;x pos of top/left of animate box
aoriginy:
	.ds.w	1	;y pos of top/left of animate box
adiagx:
	.ds.w	1	;x pos of diagonal corner of animate box
adiagy:
	.ds.w	1	;y pos
ahandx:
	.ds.w	1	;x pos of picture area to copy to animate area
ahandy:
	.ds.w	1	;y pos of picture area to copy to animate area
ohandx:
	.ds.w	1	;x pos of cell area to copy to animate area
ohandy:
	.ds.w	1	;y pos of cell area to copy to animate area
*
*
*
*  animate bss from FATMODE
*
handlea:
	.ds.w	1		;animate file handle
curcell:
	.ds.l	1		;current cell ptr (=0 if none)
holdptr:
	.ds.l	1		;ptr to cell in hold buffer (=0 if none)
freeptr:
	.ds.l	1		;ptr to start of free cell list (=0 if none)
anibase:
	.ds.l	1		;start of ram allocation block (=0 if none)
aninext:
	.ds.l	1		;next cell to be allocated
aniend:
	.ds.l	1		;last cell not to be allocated
fs_inpat:
	.ds.b	70		;file selector input path
fs_insel:
	.ds.b	60		;file selector output selection

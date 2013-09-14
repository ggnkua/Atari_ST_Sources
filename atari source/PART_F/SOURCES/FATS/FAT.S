*********************************
*				*
*	Fat-bits editor		*
*				*
*	Copyright 1986		*
*	Atari "US" Corp.	*
*				*
*********************************
*
*
*    Programmer: Dave Staugas
*	  Start: March 1985
*   Last update: 13 Aug 1986
*
*  Current name: NEOchrome
*
*	.text
*
*
true	equ	-1
false	equ	0
*
	.nlist
	.include	"fatequ.s"
	.list
*
*conditional switches while under development
*
*for Jerome & developers: false,false
*      for demo purposes: true,true
*            for release: false,true
*
nosave	equ	false		;conditional for no file saves allowed
nopass	equ	true		;no password access required
*
*
*  public globals
*
*
	.globl	newtxtmd
	.globl	_scrtchp
	.globl	refunc,lastx,lasty,cpysrc,undopalt
	.globl	texbasy,txtcelht,boxhite,boxsrcy,othrorgy,movebox,touch,dura
	.globl	rexbox,rexboxld,doread,dskalrt0,dskalrt2
*
	.globl	curfont,contrl,curscren,othscren,screen0,cutscren,cpyscren
	.globl	intin,int_in,int_out,colorz
	.globl	_pblock,ptsout,intout
	.globl	ptsin,addr_in,control,aes_pb
	.globl	likesel,undoyet,paletsav
	.globl	physadd,fs_inpat,fs_insel,nofile,path,full
	.globl	blitmask,time3x,upbutx
	.globl	showm,hidem,bigram,funky,cpyafunc,jktxtad
*
*
*  external globals
*
	.globl	vircan,vcanbase,virhandx,virhandy,vcansize,handd,handii
	.globl	vformwd,virtouch,vpixwd,vpixht
*
	.globl	aniblank,anistrng,xyplot
	.globl	grafptrs,drawlayo,drawa,invdrawa,gridon
	.globl	vdicall,alertout,gemready,inotjack,inotbox,iojack
	.globl	objc_drw,form_do,form_alr,graf_mou,fsel_inp
	.globl	appl_int,graf_hdl,appl_ext
	.globl	loadcol,pointcol,leftpt,ritept,unleftpt,unritept
	.globl	unselbox,cutwidth,cuthite,cutx,cuty
	.globl	coninst,conin,cscroll,cscrolr,cscrlupd
	.globl	graftxt,textset,matrix,uncolor,systxt6,systxt8
	.globl	draw,box,invdraw,undraw,mouseget,hotbox,unhotbox
	.globl	drawq,invdrawq,undo,chg2cur,chgxcur,big2palt,setc14
	.globl	back2bot,unlbigbx,bigbx,screnswp,gemready,textd,copyd
	.globl	modeupd,modedraw,clright,cpyrite,getpix,matxupd
*
	.globl	irqlev,henabl,curpalt,half,selctcol,colleft,colrite,cscrolst
	.globl	frmcnt,tcdifsav,tcdif,keysav,midi,timrcsav,lowc,csped
	.globl	hblksav,hblknull,vblksav,vblk,mouse,oldmouse,button,oldbuttn
	.globl	mousped,xpos,ypos,textx,texty,updown,doubtiml,doubtimr
	.globl	p_block,diagx,originx,diagy,originy
	.globl	liconlst,matselx,matsely
*
	.globl	inits,deinits,funcs,bigpalt,paltx,palt,color14,handy
	.globl	copystat,jackstat,msg0,conchar,othsame,getnewfl,texbasx
	.globl	newjack1,canonscn,snapto
	.globl	refile,matupd,copyicon
*
	.globl	rezsav,horzmax,vertmax,colmax,rezset,rezclr,shapesel,pointcnt
*
*
*	.globl	cbarx,cbary
*
criterr	equ	$404
*
*
*  Start of program..
*
*
*
start:
	eor.l	d5,d7			;logic analyzer trigger word ($BB87)
*
	movea.l	sp,a5			;do apll_start code
	movea.l	#stack,sp
	movea.l	4(a5),a5
	lea	$80(a5),a4		;but save command tail ptr
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	a4,-(sp)
*
	move.l	d0,-(sp)		;allocate our program
	move.l	a5,-(sp)		;with setblock
	move.w	d0,-(sp)		;call (yuk!)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#12,sp
*
*
*  1 time program inits...
*
*  set up 5 screens on 256-byte (page) boundaries
*
	move.l	#screenz,d1	;get base of screens ram
	addi.l	#255,d1		;find next age boundary
	clr.b	d1		;d1 -> 1st page boundary
	move.l	#32000,d0
*
*  new code to make curscren & othscren share same hi word in base addr
*  to reduce any perceptable flash during double buffered operations
*
	move.l	d1,d2		;d1 -> 1st avail screen base
	add.l	d0,d2		;d2 -> 2nd avail screen base
	move.l	d2,d3
	add.l	d0,d3		;d3 -> 3rd avail screen base
	move.l	d3,d4
	addi.l	#3840,d4	;add apend memory for rotation scratch
	add.l	d0,d4		;d4 -> 4th avail screen base
*
	swap	d1		;look at hi words of first 3 scr bases
	swap	d2
	swap	d3
*
	cmp.w	d2,d1		;do 1 & 2 have same hi word?
	beq.s	samehi		;br if so
	exg	d1,d3		;  else, exchange 1 & 3
	exg	d1,d2		;  & new cur & othscren
samehi:
	swap	d1		;restore correct word order, hi & lo
	swap	d2
	swap	d3
*
	move.l	d1,curscren	;0 - First display screen (start as current)
	move.l	d2,othscren	;1 - Second display screen (start as alternate)
	cmp.l	d2,d3		;  is screen0 1st allocated?
	blt.s	scr0is1		;    br if so
	addi.l	#3840,d3	;else, its last of three--move it down a bit
scr0is1:
	move.l	d3,screen0	;2 - Main screen, backup used with Undo
	move.l	d4,cutscren	;3 - Cut buffer for use by copybox/jacknife
	addi.l	#17920,d4
	move.l	d4,cpyscren	;4 - Buffer for current copybox/jack source 
*
*   check for RAM-based 512k (small memory)
*    or Meg-RAM/512k-ROM sytem (big memory)
*
	move.l	#-1,-(sp)	;see how much memory there is
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
*
	cmpi.l	#$10000,d0	;less than 64k?
	bcs.s	itsram		;br if so--its small memory
	move.b	#-1,bigram	;set for big memory
	clr.w	cpyafunc	;allow function keys for copy box
	move.w	#3,jktxtad	;allow function keys for jack knife
	move.w	#88,copyicon	;"F10" function key too
*
*  ******new code for virtual canvass
*
	cmpi.l	#vcansize+35840,d0	;enough room for virtual canvas?
	bcs.s	nocanv			;br if not
*
	move.b	#-1,vircan	;tell 'em we have virtual canvas
	move.l	#vcansize,-(sp)	;allocate another buffer for copy source
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
*
	move.l	d0,vcanbase	;gotta bunch of memory for virtual canvas

nocanv:
*
*   ****end of new code
*
	move.l	#35840,-(sp)	;allocate another buffer for copy source
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
*
	move.l	d0,cpyscren	;gotta full screen for copy source
itsram:
*
*
*  install 512 color master pallet...
*
*      check disk for NEO.MCP file, if it exists..
*
	move.w	#0,-(sp)		;for read only
	move.l	#pathbin,-(sp)
	move.w	#$3d,-(sp)		;color pallet file open for read
	trap	#1
	addq.w	#8,sp
*
	move.w	d0,handle		;NEO.MCP file found?
	bmi.s	endpalt			;br if not, skip load pallet from file
*
*
*  read color pallet from NEO.MCP file
*
rdbigp:
	move.l	#bigpalt,-(sp)		;read color pallet
	move.l	#1024,-(sp)		;512 words
	move.w	handle,-(sp)		;use handle from open
	move.w	#$3f,-(sp)		;read cmd
	trap	#1
	add.w	#12,sp
*
	tst.l	d0			;good read?
	bmi.s	frdbad1			;br if no good
	cmpi.w	#1024,d0		;full file read?
	beq.s	endpalt			;br if good, skip error stuff
frdbad1:
	move.l	#dskalrt1,d0		;bad read file
	bsr	alertout
*
endpalt:
*
*  Supervisor set-ups
*
	clr.l	-(sp)			;enter supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,sstackp
*
	move.w	#15,d0			;save colors as found on entry
	movea.l	#hpalet,a0
	movea.l	#paletsav,a1
	movea.l	#undopalt,a2
csavelp:
	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbra	d0,csavelp
*
*	bsr	txbltest
*
	move.l	criterr.l,old_hand	;stop GEM's insane disk error handler
	move.l	#err_hand,criterr.l
*
	move.l	eventmc.l,tcdifsav.l	;intercept timer c differred
	move.l	#tcdif,eventmc.l
*
	move.l	keybrdv.l,keysav.l		;control irq priority on mouse
	move.l	#midi,keybrdv.l
*
	move.l	timercv.l,timrcsav.l	;control irq priority on timer c
	move.l	#lowc,timercv.l
*
	andi.b	#$FE,iera.l		;disable timer B (h-blank counter)
	move.l	hblkcv.l,hblksav.l	;save old h-blank vec
	move.l	#hblknull,hblkcv.l	;put in our "rte" for now
	ori.b	#1,iera.l		;unmask timer B
	ori.b	#1,imra.l		;enable timer B
*
	move.l	vblankv.l,vblksav.l	;install v-blank routine
	move.l	#vblk,vblankv.l
*
	move.l	sstackp,-(sp)		;exit supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
*
*
*  Back to user mode
*
	bsr	appl_int		;init application
	bsr	graf_hdl		;get a handle
*
	movea.l	#intin,a0		;get intin array ready for open virtual
	move.w	#9,d0
virloop:
	move.w	#1,(a0)+
	dbra	d0,virloop
	move.w	#2,(a0)
*
*  Now for the good part --- Open Virtual Workstation!!!
*
	move.l	#contrl,a0
	move.w	#100,(a0)
	move.w	#11,6(a0)
	move.w	int_out+0,12(a0)	;put handle in here
	bsr	vdicall			;open virtual workstation
*
	move.w	#126,(a0)		;exchange mouse movement vector
	clr.w	2(a0)
	clr.w	6(a0)
	move.l	#mouse,14(a0)
	bsr	vdicall
	move.l	18(a0),oldmouse		;save old mouse movement vector
*
	move.w	#125,(a0)		;exchange mouse button vector
	clr.w	2(a0)
	clr.w	6(a0)
	move.l	#button,14(a0)
	bsr	vdicall
*
	move.l	18(a0),oldbuttn		;save old mouse button vector
*
	move.w	#2,-(sp)		;get entry physical base address
	trap	#14
	addq.l	#2,sp
	move.l	d0,physadd
*
*	move.l	d0,_scrtchp
*
	.dc.w	$a000			;get base address of lineA variables
	move.w	-692(a0),horzmax	;save clip horz
	move.w	-690(a0),vertmax	;save clip vert
	move.w	-666(a0),colmax		;save color # max
*
	move.w	#4,-(sp)		;get entry rez (lo-0 or med-1)
	trap	#14
	addq.l	#2,sp
	move.w	d0,rezsav
*
	cmpi.w	#2,d0			;in hi rez?
	bne.s	rezok			;br if not
*
*  in hi rez, can't cope with that..
*
	move.l	#rezalert,d0		;tell 'em no go on hi rez
	bsr	alertout
	bra	exit			;fatal, return to system
rezok:
	bsr	hidem			;hide mouse
*
*  do some tricky initializations
*
	.dc.w	$a000
	move.w	#319,-692(a0)
	move.w	#199,-690(a0)
	move.w	#16,-666(a0)
*
	move.w	#163,-602(a0)		;initial cursor x position
	move.w	#106,-600(a0)		;initial cursor y
*
*
	clr.w	-(sp)			;set lo rez
	move.l	curscren,-(sp)		;physical base
	move.l	curscren,-(sp)		;logical base
	move.w	#5,-(sp)		;set these
	trap	#14
	adda.w	#12,sp
;
;  re-do timer "B"
	clr.l	-(sp)			;enter supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,sstackp
*
	ori.b	#1,iera.l		;unmask timer B
	ori.b	#1,imra.l		;enable timer B
*
	move.l	sstackp,-(sp)		;exit supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
;  end re-do
; 

	move.l	(sp)+,a4		;reget command tail ptr
	clr.w	nofile			;assume no input file
	move.b	(a4)+,d0		;command tail length to d0
	beq.s	notail
	ext.w	d0
	bra.s	leadini
leadin:
	cmpi.b	#"!",(a4)		;skip leading spaces or cntrl chars
	bcc.s	dopath
	addq.l	#1,a4
leadini:
	dbra	d0,leadin
	bra.s	notail
*
*  set-up pathname for input/output file..
*
dopath:
	movea.l	#path,a3
dopath1:
	move.b	(a4)+,(a3)+		;copy pathname from command tail
	dbra	d0,dopath1
	move.b	#0,(a3)+		;terminate with 0
	move.w	#1,nofile		;indicate file name was supplied
notail:	
	tst.w	nofile		;file name already supplied?
	beq	skipread	;br if not, no file to read
*
*  Read disk file
*
getfile:
	clr.w	-(sp)		;for read only
	move.l	#path,-(sp)
	move.w	#$3d,-(sp)	;open for read
	trap	#1
	addq.l	#8,sp
*
*
*  re-entry point from file selector (d0 must be result of open read file)
*
refile:
	move.b	#-1,touch		;indicate file untouched
	clr.w	cscrolst		;stop any color scrolling
*
	move.w	d0,handle
	bpl.s	readnxt
*
	bsr	rezset
	move.l	#dskalrt0,d0
	bsr	alertout
	bsr	rezclr
	clr.w	nofile
	bra	skipread
readnxt:
*
	move.l	othscren,-(sp)		;read file header
	move.l	#128,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.w	#12,sp
*
	tst.l	d0
	bmi	frdbad
	cmpi.w	#128,d0
	bne.s	frdbad
*
	moveq	#31,d0
	moveq	#0,d1
	movea.l	#fileid,a0
	movea.l	othscren,a1
	cmpi.w	#$BABE,(a1)		;allow new id # for virtual canvas
	beq.s	idcopx
	tst.w	(a1)
	bne.s	frdbad			;else, fail if not 0
	tst.w	2(a1)
	bne.s	frdbad
	bra.s	idcop
idcopx:
	tst.b	vircan		;enough ram for virtual canvas?
	beq.s	frdbad		;br if not
	clr.b	virtouch	;else, we're no virgins on virtual canvas
idcop:
	bsr	cunundo		;un UNDO former color palette before clobber
idcopp:
	move.l	(a1),(a0)+
	move.l	d1,(a1)+
	dbra	d0,idcopp
*
	clr.w	duration		;no duration
	clr.w	colsped			;clear color scroll speed
*
	move.w	cpterz,d0		;get color pointers
	bpl.s	skipread		;old format--ignore
	move.w	d0,d1
	andi.w	#$F,d1
	move.w	d1,colrite
	lsr.w	#4,d0
	andi.w	#$f,d0
	move.w	d0,colleft
*
	bra.s	skipread
frdbad:
	bsr	rezset
	move.l	#dskalrt1,d0
	bsr	alertout
	bsr	rezclr
	move.w	#0,nofile
*
skipread:
	move.l	#colorz,curpalt		;set user's color pallet
	move.l	#colorz,-(sp)
	move.w	#6,-(sp)		;set pallet
	trap	#14
	addq.l	#6,sp
*
	tst.w	nofile			;input file?
	beq	skiprd1
*
	bsr	hidem			;hide mouse
*
*  ****new stuff for virtual canvas
*
	move.w	neohite,d0		;get neohite as read
	beq	oldneo			;br if previous filetype
	swap	d0
	move.w	neowidth,d0
	cmpi.l	#(200*$10000)+320,d0
	beq	oldneo
	moveq	#0,d1
	move.w	d0,d1
	add.w	#15,d1
	lsr.w	#4,d1
	lsl.w	#3,d1			;d1 = bytes/line
	swap	d0			;d0 = # of lines
	moveq	#0,d2
	move.l	#vcansize,d3
	lsr.w	#3,d3
	movea.l	vcanbase,a0
	move.l	a0,a1
	bra.s	clrviri			;clear virtual canvas
clrvirlp:
	move.l	d2,(a0)+
	move.l	d2,(a0)+
clrviri:
	dbra	d3,clrvirlp
*
	subq.w	#1,d0			;# lines -1
	move.w	d0,d2
rdlinlp:
	move.w	d2,-(sp)
*
	move.l	a1,-(sp)		;read graphics part of file
	move.l	d1,-(sp)		;1 line at a time
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,d1
	move.l	(sp)+,a1
	adda.w	#vformwd,a1
	move.w	(sp)+,d2
*
	tst.l	d0
	bmi	frdbad
	cmp.w	d1,d0
	bne	frdbad
	dbra	d2,rdlinlp
*
	clr.w	virhandx
	clr.w	virhandy
	bsr	handd			;virtual canvas -> screen0
*
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)		;close file
	trap	#1
	addq.w	#4,sp
*
	move.l	screen0,a1		;main screen
	move.l	curscren,a0		;display screen
	bra.s	docop1
*
oldneo:
*
*  ***end new stuff
*
	move.l	curscren,-(sp)		;read rest of file
	move.l	#32000,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.w	#12,sp
*
	tst.l	d0
	bmi	frdbad
	cmpi.w	#32000,d0
	bne	frdbad
*
finread:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)		;close file
	trap	#1
	addq.w	#4,sp
*
*  set up screen0 (main)...
*
skiprd1:
	move.l	screen0,a0		;main screen
	move.l	curscren,a1		;display screen
docop1:
	move.w	#1999,d0
cop1:
	move.l	(a1)+,(a0)+		;copy display to main
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,cop1
*
	move.w	#-1,henabl		;enable h-blank irq's
	move.w	#$2500,irqlev
*
	move.b	#2,updown
*
	bsr	loadcol			;create fat-bit matrix box and pallette
*
	bsr	showm			;show mouse
*
	bsr	matrix
*
	movea.l	#inits,a0
	move.b	likesel,d7
	lsl.w	#2,d7
	ext.w	d7
	move.l	(a0,d7.w),a0
	clr.b	undoyet
	jsr	(a0)			;initialize new function
*
*
	.if	!nopass
*
*  temp code to stop unauthorized users
*
	bsr	passit			;get user authorization password
*
*  end temp code
*
	.endif
*
*
*  main program loop
*
*
loop:
	bsr	copyrite
	move.l	conchar,d0		;check console input
	beq	nokey			;br if no key available
*
	swap	d0
	cmpi.b	#$61,d0			;"undo" key?
	bne.s	notundo
	bsr.s	newmous
	bne.s	escancel		;cancel undo if mouse buttons down
	bsr	undo
	bra.s	clrkey			;used this key, so clear it
notundo:
	cmpi.b	#1,d0			;esc key?
	bne.s	nokey
*
	bsr.s	newmous

	bne.s	escancel		;cancel esc if mouse buttons down
*
	bsr	hidem			;hide mouse
*
	tst.w	full
	beq	fuller
	moveq	#3,d5
	bra	hafit
*
*
*
newmous:
	clr.l	conchar
	bsr	mouseget
	move.w	d2,d5
	andi.w	#3,d5			;any mouse buttons down?
	beq.s	newmous1		;br if not--need to check special case
	rts
newmous1:
	cmpi.b	#12,likesel		;are we in shapes?
	bne.s	newmous2		;br if not
	cmpi.w	#4,shapesel		;are we poly-line?
	bne.s	newmous2		;br if not
	tst.w	pointcnt		;are we still defining poly?
	bne.s	newmous3		;br if so
newmous2:
	moveq	#0,d5
newmous3:
	rts
*
*
clrkey:
	clr.l	conchar
nokey:
	bsr	cscrlupd		;update color scrolling
*
	bsr	mouseget		;sample mouse button state
escancel:
	move.w	d2,d5
	andi.w	#$C0FC,d5		;change in xy, button state, or keyz
	bne	dopoint			;br if change
*
*  new stuff
*  do xy plot
	tst.w	full
	bne	loop			;skip if full screen
*
	tst.b	xyplot
	beq	loop			;skip if turned off
*
	cmp.w	oldx,d0
	bne.s	xydo
	cmp.w	oldy,d1
	beq	loop
xydo:	
	move.w	d0,oldx
	move.w	d1,oldy
	cmpi.w	#100,d1
	bcs.s	xydoo
	bclr.b	#0,xystat
	beq	loop
	bsr	hidem
	movea.l	#aniblank,a0
	bsr.s	blnkety
	bsr	showm
	bra	loop
digitab:
	.dc.b	"0123456789"
*
xydoo:
	bset.b	#0,xystat
	add.w	handy,d1
*
*  new code added for virtual canvas
*
	add.w	virhandy,d1
	add.w	virhandx,d0
*
*	d0.w- x:xxx
*	d1.w- y:xxx
*
putcoo:
	movea.l	#anistrng+2,a0
	ext.l	d0
	divu	#100,d0
	move.b	digitab(pc,d0.w),(a0)+
	swap	d0
	ext.l	d0
	divu	#10,d0
	move.b	digitab(pc,d0.w),(a0)+
	swap	d0
	move.b	digitab(pc,d0.w),(a0)
*
	addq.l	#4,a0
	ext.l	d1
	divu	#100,d1
	move.b	digitab(pc,d1.w),(a0)+
	swap	d1
	ext.l	d1
	divu	#10,d1
	move.b	digitab(pc,d1.w),(a0)+
	swap	d1
	move.b	digitab(pc,d1.w),(a0)
	suba.w	#10,a0
	bsr.s	blnkety
	bra	loop
*
blnkety:
	move.w	#56,d0
	move.w	#194,d1
	moveq	#0,d2
	bsr	systxt6
	move.l	curscren,a0
	move.l	othscren,a1
	adda.w	#(160*194)+24,a0
	adda.w	#(160*194)+24,a1
	move.w	#5,d0
repolp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	adda.w	#160-40,a0
	adda.w	#160-40,a1
	dbra	d0,repolp
	rts
*

*
*  got an "Event-Multi", do something..
*
dopoint:
	bsr	hidem			;hide cursor
*
*  check for full/half screen
*
	tst.w	full			;full screen on?
	beq	halfchk
*
*  on full screen...
*  just check for corner click (bottom/left or top/rite or bottom/rite)
*
	move.w	#199,d6
	move.w	#319,d7			;get max co-ordinates
	tst.b	gridon			;see if need others
	beq.s	coordok
	subq.w	#7,d6			;get max co-ordinates for grid
	subq.w	#7,d7
coordok:
	tst.w	d0			;cursor click on left edge?
	beq.s	halfchky		;br if so
	cmp.w	d7,d0			;right edge?
	bne.s	abovem			;br if not
	tst.w	d1
	beq.s	halfit			;br if top/rite
halfchky:
	cmp.w	d6,d1
	beq.s	halfit
abovem:
	bra	abovemid		
halfit:
	andi.w	#$4,d5			;check left leading edge
	beq.s	abovem			;br if no leading edge
	tst.b	upbutx			;is polygon shapes active?
	bne.s	abovem			;ignore corner clicks if so
	lsr.w	#2,d5			;else, line up bits to trailing edge 
*
*
*
*************************************************
*
*  Full screen to Half screen exit...
*
*
*  proceed with screen mode change
*
hafit:
	movem.w	d5,-(sp)		;save button we got here on
*
	clr.w	full			;indicate half screen
	move.w	#100,half
*
*
	btst.b	#0,jackstat		;active jacknife?
	beq.s	haffit			;br if no
	bsr	canonscn		;else, make othscren be the big one
haffit:
*
*  put up lower half stuff on othscren
*
*
	move.l	curscren,a0
	move.l	othscren,a1
	move.l	a1,curscren
*
*
	movem.l	a0-a1,-(sp)
	move.w	#-1,-(sp)		;set logical screen to alternate
	move.l	#-1,-(sp)
	move.l	a1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
	bsr	loadcol
*
	movem.l	(sp)+,a0-a1
	move.l	a0,curscren
	move.l	a1,othscren
*
	move.w	#-1,-(sp)		;set logical screen back to current
	move.l	#-1,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
*
	move.b	likesel,d7		;get mode
	cmpi.b	#3,d7			;text mode?
	bne.s	textno
	tst.w	texbasx			;cursor active?
	bmi.s	textno
*
*  text here
*
	move.w	handy,d0
	move.w	texbasy,d1
	cmp.w	d0,d1
	bcc.s	testtx
	subq.w	#5,d1
	bpl.s	texttx1
	moveq	#0,d1
texttx1:
	bra.s	texttx2
testtx:
	move.w	texty,d2
	add.w	txtcelht,d2
	subi.w	#99,d2
	cmp.w	d2,d0
	bge.s	handyok	
	subq.w	#5,d1
	bpl.s	texttx3
	moveq	#0,d1
texttx3:
	cmpi.w	#101,d1
	bcs.s	texttx2
	move.w	#100,d1
texttx2:
	move.w	d1,handy
handyok:
	move.w	handy,d0
	sub.w	d0,texbasy
	bsr	newtxtmd
	bsr	othsame
	bra	finfull
*
*		
textno:
	tst.b	d7		;jacknife mode?
	bne.s	trycp1		;br if no
	btst.b	#0,jackstat	;active jacknife?
	beq	copyno
	bra.s	trycp2
trycp1:
	cmpi.b	#2,d7		;copy mode?
	bne	copyno
	btst.b	#0,copystat	;copybox in existence?
	beq	copyno		;br if not
*
*  special case jacknife & copybox code
*
trycp2:
	move.w	boxhite,d2
	tst.b	bigram		;are we well endowed?
	bne.s	hiteok		;br if yes
*	
	cmpi.w	#100,d2		;bigger than we can handle on half screen?
	bcs.s	hiteok
	move.w	#100,d2
	move.w	d2,boxhite
hiteok:
	move.w	d2,d0
	sub.w	#100,d0
	bpl.s	htok1
	neg.w	d0
htok1:
	lsr.w	#1,d0
*
*  compute new handy value..
*
	move.w	originy,d1
	sub.w	d0,d1
	bpl.s	hndyok
	moveq	#0,d1
	bra.s	hndyok1
hndyok:
	cmpi.w	#101,d1
	bcs.s	hndyok1
	move.w	#100,d1
hndyok1:
	move.w	d1,handy
	sub.w	d1,originy
	move.w	originy,d0
	move.w	d0,othrorgy
	add.w	d2,d0
	subq.w	#1,d0
	move.w	d0,diagy
*
*  Now check copybox source
*
	movea.l	screen0,a0
	cmpa.l	cpysrc,a0		;is source from pristine?
	bne.s	nosrcop			; br if not
*
	movea.l	a0,a2
	move.l	cpyscren,a1
	move.l	a1,cpysrc		;make source from avail cpy buffer
	move.w	boxsrcy,d0
	move.w	d0,d2
	mulu	#160,d0
	adda.w	d0,a0
	clr.w	boxsrcy			;source is top of cpyscren
	move.w	boxhite,d0
	mulu	#10,d0
	bra.s	copilp3i
copilp3:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
copilp3i:
	dbra	d0,copilp3
*
	move.l	a2,a0			;need to move monomask to top also
	lea	blitmask,a2
	move.l	a2,a1
	mulu	#40,d2			;old boxsrcy
	beq.s	nosrcop			;skip if already at top
*
	adda.w	d2,a1
	move.w	boxhite,d0
	bra.s	copilp6i
copilp6:
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
copilp6i:
	dbra	d0,copilp6
nosrcop:
*
*  now do unundo..
*
	move.l	physadd,a0
	move.l	screen0,a1
	move.l	a0,a2
	move.l	a1,a3
	move.w	#1999,d0
copilp4:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,copilp4
*
	move.l	othscren,a0	;copy from screen0 to othscren + physadd
	mulu	#160,d1
	adda.w	d1,a3
	move.w	#999,d0
copilp5:
	move.l	(a3),(a0)+
	move.l	(a3)+,(a2)+
*
	move.l	(a3),(a0)+
	move.l	(a3)+,(a2)+
*
	move.l	(a3),(a0)+
	move.l	(a3)+,(a2)+
*
	move.l	(a3),(a0)+
	move.l	(a3)+,(a2)+
	dbra	d0,copilp5
*
	move.w	(sp)+,d5
fullout1:
	move.w	d5,-(sp)		;save left/right bits
	bsr	mouseget		;wait for buttons up
	move.w	(sp)+,d5
	move.w	d2,d6
	and.w	d5,d6
	bne.s	fullout1		;wait for buttons up
*
	tst.b	likesel			;jacknife?
	bne.s	docopilp		;br if not
*
checkp:
	movem.w	d0-d4,-(sp)
	bsr	iojack			;set proper cursor for jack
	bsr	newjack1		;else, generate new jack stuff
	movem.w	(sp)+,d0-d4
	bsr	othsame
	bra	finfull1
*
docopilp:
	movem.w	d0-d4,-(sp)
	bsr	iobox			;set proper cursor for copybox
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	bsr	movebox
*
	movea.l	physadd,a0
	movea.l	othscren,a1
	move.w	#999,d0
copilp2:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,copilp2
*
	bsr	othsame
*
	movem.w	(sp)+,d0-d4
	bra.s	finfull1
*
*
*
copyno:
*
*  not text or copy, save all changes (unundo)
*
	move.l	curscren,a0
	move.l	screen0,a1
	move.w	#1999,d0
undoit:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,undoit		;un-undo--save work to main buffer
*
	move.l	screen0,a0
	move.l	othscren,a1
	move.w	handy,d0
	mulu	#160,d0
	adda.w	d0,a0
	move.w	#999,d0
halflpp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,halflpp
*
*
finfull:	
	move.w	(sp)+,d5
*
*
fullout:
	move.w	d5,-(sp)		;save left/right bits
	bsr	mouseget		;wait for buttons up
	move.w	(sp)+,d5
	move.w	d2,d6
	and.w	d5,d6
	bne.s	fullout			;wait for buttons up
*
*  got trailing edge
*
	movem.w	d0-d2,-(sp)
	bsr	screnswp
	movem.w	(sp)+,d0-d2		;reget x/y & keys
*
finfull1:
	bsr	snapto			;snap to grid if grid is on
	move.b	#$80,matxupd
	move.w	#-1,henabl
	move.w	#$2500,irqlev
	bra	matupd
*
halfchk:
*
*   Half screen check...  
*
	move.w	half,d7
	cmp.w	d7,d1			;below mid-line?
	bcs	abovemid		;br if above in draw area
*
*  below half-point
*
*	add.w	#10,d7
	add.w	#14,d7
	cmp.w	d7,d1			;within pallet area?
	bcc	belowpal		;br if below pallet
	btst.l	#2,d2			;left leading edge?
	bne	newselc			;br to select new color
	btst.l	#3,d2			;rite leading edge?
	beq	matupd			;br to matrix update if not
*
*  check color pointers
*
	move.w	d0,d5			;check x pos of cursor
	ext.l	d5
	move.w	colleft,d6		;get left color ptr
	move.w	colrite,d7		;rite color pointer
	moveq	#0,d2			;assume left found (z)
	divu	#20,d5			;0-15
	cmp.w	d6,d5			;on left?
	beq.s	gotcol
	moveq	#1,d2			;assume right (nz)
	cmp.w	d7,d5			;on right?
	bne	matupd
gotcol:
	cmp.w	d6,d7			;right/left the same?
	bne.s	docollp
	moveq	#0,d2
	swap	d5
	cmpi.w	#10,d5
	bcs.s	docoll
	moveq	#1,d2
docoll:
	swap	d5
docollp:
	move.w	d2,d7		;save left or right in d7
	bne.s	ritelim
	moveq	#0,d1		;set min
	move.w	colrite,d3
	mulu	#20,d3		;set max
	bra.s	boxnow
ritelim:
	move.w	colleft,d1
	mulu	#20,d1
	move.w	#15*20,d3
boxnow:
	swap	d1
	swap	d3
	swap	d7
	move.w	d5,d0		;top left x
	mulu	#20,d0
	move.w	#101,d1		;top/left y
	move.w	d0,d2
	add.w	#18,d2		;bot/right x
	move.w	#110,d3
	move.w	#$F,d4		;color
	moveq	#2,d5		;xor mode
	moveq	#-1,d6		;mask
	bsr	box
*
	bsr	showm		;show mouse
*
	movem.l	d0-d6,-(sp)
collp1:
	move.l	d7,-(sp)
	bsr	mouseget	;mouseget clobbers d7
	move.l	(sp)+,d7
	andi.w	#$8020,d2	;change in xy or rite trailing edge?
	beq.s	collp1
	btst.l	#5,d2		;trailing edge, rite button?
	bne.s	collpx
*
*  must be motion
*
	sub.w	d3,d0
	move.w	d0,d7
	movem.l	(sp)+,d0-d6
*
	bsr	hidem		;hide cursor
*
	bsr	box
	swap	d1
	swap	d3
	add.w	d7,d2
	add.w	d7,d0
	bmi.s	minnok
	cmp.w	d1,d0		;less than min?
	bcc.s	minok		;br if not 
minnok:
	move.w	d1,d0
	move.w	d1,d2
	addi.w	#18,d2
minok:
	cmp.w	d0,d3		;greater than max
	bcc.s	maxok
	move.w	d3,d0
	move.w	d3,d2
	addi.w	#18,d2
maxok:
	swap	d1
	swap	d3
	bsr	box
*
	bsr	showm		;show mouse
*
	movem.l	d0-d6,-(sp)
	bra.s	collp1
collpx:
	movem.l	(sp)+,d0-d6
	bsr	box
	swap	d7
	add.w	#10,d0
	ext.l	d0
	divu	#20,d0
	tst.w	d7		;left box?
	bne.s	mbrite
	bsr	unleftpt
	move.w	d0,colleft
	bsr	leftpt
	bra.s	colptre
mbrite:
	bsr	unritept
	move.w	d0,colrite
	bsr	ritept
colptre:
	bsr	othsame		;make other screen the same
	bsr	mouseget
	moveq	#0,d7
	cmp.w	half,d1
	bcc.s	colptrex
	moveq	#3,d7
colptrex:
	move.b	d7,updown
	bra	matupd
*
*	Below pallet bar..
*
belowpal:
	move.w	d2,d3
	andi.w	#$00FC,d3	;double/single clicks, right/left?
	beq	matupd		;exit to matrix update if no clicks
*
*  received left/right single or double click
*
*  Check for grid box click
*
	cmpi.w	#iconly-1,d1
	bcs	notxbx
	cmpi.w	#iconly+63,d1
	bcc	notxbx
	cmpi.w	#114,d0
	bcs.s	nogrid
	cmpi.w	#123,d0
	bcc	notxbx
*
*  grid click here
*
	andi.w	#$c,d3
	beq	matupd		;only leading edges please
*
	movem.w	d0-d2,-(sp)
*
*  draw grid box
*
	moveq	#114,d0
	move.w	#iconly,d1
	moveq	#16,d2			;icon #16 is also grid box
	moveq	#15,d3
	move.l	#$FFFF0008,d5
	move.l	#$FFFE0001,d6
	not.b	gridon			;test for grid set
	bne.s	gridnyet
	bsr	drawa
	bra.s	gridn1
gridnyet:
	bsr	invdrawa
gridn1:
	movem.w	(sp)+,d0-d2
	bra	matupd
*
nogrid:
*
*  Check for half to full exit box
*
	cmpi.w	#9,d0
	bcc	notxbx
*
*  click or double click on exit box
*
	move.w	d2,d3			;copy buttons to temp
	andi.w	#$30,d3			;left/right trailing edge?
	beq	notxbx			;br if not
*
*
*
*
**********************************************
*
*  Half to Full screen exit
*
fuller:
	move.b	likesel,d7		;get mode
	tst.b	bigram			;see if RAM-loaded system
	bne.s	fullergo		;br if not
	tst.b	d7			;jacknife?
	beq.s	fullerno		;br if so--can't full this guy
	cmpi.b	#2,d7			;copybox?
	bne.s	fullergo		;br to full if not
*
*  can't full in jacknife/copybox with RAM-loaded systems
*
fullerno:
	bsr	hidem
	movea.l	#deinits,a0
	lsl.w	#2,d7
	ext.w	d7
	move.l	(a0,d7.w),a0
	jsr	(a0)			;de-initialize current function
	bsr	gemready
	bsr	rezset
	bsr	showm
	moveq	#15,d0
	bsr	chgxcur			;change to pointer
	move.l	#jackalrt,d0
	bsr	alertout
	bra	cancel
*
*  do normal full screen convert
*
fullergo:	
	move.b	#-1,cpyrite		;kill copyrite msg
	move.w	#-1,full		;indicate full screen
	move.w	#200,half
*
	cmpi.b	#3,d7			;text mode
	bne.s	notext
	tst.w	texbasx			;cursor active?
	bmi.s	notext			;br if not
*
*  cursor active in text mode
*
	move.w	handy,d0
	add.w	d0,texbasy
	bsr	newtxtmd
	bra	finhalf
*
*
notext:
	cmpi.b	#1,d7			;in grabber hand?
	bne.s	nograb
	bsr	handd			;else, copy from virtual canvas 1st
nograb:
	movea.l	screen0,a0
	movea.l	othscren,a1
	move.w	#1999,d1
xbxlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d1,xbxlp
*
	tst.b	d7			;in jack knife?
	bne.s	trycpy			;br if no
	btst.b	#0,jackstat		;jack knife active?
	beq	ntcopy			;br if not
	bra.s	cpysf
trycpy:
	cmpi.b	#2,d7			;copy mode?
	bne	ntcopy
*
	btst.b	#0,copystat		;box in existence?
	beq	ntcopy			;br if not
*
*  special case half to full screen for jacknife & copybox
*
cpysf:
	movea.l	physadd,a0
	movea.l	othscren,a1
	move.w	handy,d0
	mulu	#160,d0
	adda.w	d0,a1
	move.w	#999,d0
bandlp1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,bandlp1
*	
	movea.l	othscren,a0
	movea.l	physadd,a1
	move.w	#1999,d0
physlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,physlp
*
	move.w	handy,d0
	add.w	d0,originy
	add.w	d0,othrorgy
	add.w	d0,diagy
*
*
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	bsr	movebox
*
	bsr	gemready
*
	movea.l	othscren,a1
	movea.l	physadd,a0
	move.w	#1999,d0
othrlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,othrlp
*
	bsr	snapto			;snap to grid points if grid is on
	tst.b	likesel			;copybox or jacknife?
	bne.s	finha
*
	bsr.s	iojack			;set proper cursor for jack
*
	bsr	newjack1
	bra	matupd
*
*  set proper cursor for copybox
*
iobox:
	bsr	inotbox
	bne.s	otbox
	bset.b	#3,copystat
	bra.s	iobox1
otbox:
	bclr.b	#3,copystat
	bra.s	iobox2
*
*  set proper cursor for jack
*
iojack:
	bsr	inotjack		;cursor inside/outside jack?
	bne.s	otjack
	bset.b	#3,jackstat
iobox1:
	move.w	d0,-(sp)
	moveq	#15,d0
	bsr	chgxcur
	move.w	(sp)+,d0
	bra.s	dnewjk
otjack:
	bclr.b	#3,jackstat
iobox2:
	bsr	chg2cur
dnewjk:
	rts
*
*
finha:
*  check whether inside copybox or not..
*
	bsr	iobox
*	bsr	chg2cur			;use function cursor
	bra	matupd
*
ntcopy:
	movea.l	curscren,a0
	movea.l	othscren,a1
	move.w	handy,d0
	mulu	#160,d0
	adda.w	d0,a1
	move.w	#999,d0
bandlp:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,bandlp
*	
	bsr	screnswp
finhalf:
	bsr	snapto			;sanp to grid points if grid is on
	bsr	gemready
	bsr	chg2cur			;use function cursor
	bra	matupd
*
*
*   end half to full screen switch code
*
*
*
notxbx:
	move.w	d2,d3
	andi.w	#$cc,d3			;positive edges?
	beq	matupd
*
*  Check for color numeric click
*
	move.w	d2,d4
	andi.w	#$c,d4
	beq	notcolnm
	move.w	d0,d3
	move.w	d1,d4
	subi.w	#cbarx+14,d3
	bcs.s	notcolnm		;br if left of numbers
	lsr.w	#3,d3
	cmpi.w	#3,d3
	bcc.s	cpatchk			;br if right of numbers
	subi.w	#cbary+4,d4
	bcs.s	cpatchk
	cmpi.w	#8,d4
	bcc.s	cpatchk
*
*  clicking on numbers..
*
	move.w	color14,d5
	moveq	#2,d4
	sub.w	d3,d4
	lsl.w	#2,d4
	moveq	#1,d3
	lsl.w	d4,d3
	btst	#2,d2		;left button?
	bne.s	clkup
*
*  clicking down..
*
	ori.w	#$888,d5
	sub.w	d3,d5
	bra.s	endclk
clkup:
	add.w	d3,d5
endclk:
	andi.w	#$777,d5
	movem.w	d0-d2,-(sp)
	bsr	searchc
	movem.w	(sp)+,d0-d2
	bsr	othsame		;update other screen too
	bra	matupd
*
*  check color patch click
*
cpatchk:
	move.w	d0,d3
	move.w	d1,d4
	sub.w	#cbarx+40,d3
	bcs.s	notcolnm
	cmpi.w	#25,d3
	bcc.s	notcolnm
	sub.w	#cbary+1,d4
	bcs.s	notcolnm
	cmpi.w	#13,d4
	bcs	putcolor
notcolnm:
	nop
*
*   check left/right color scroll arrows..
*
*
	move.w	cscrolst,d6
	move.w	d2,d7
*
	move.w	d0,d3
	move.w	d1,d4
	sub.w	#cbarx-1,d3
	bcs	notcbar
	sub.w	#cbary,d4
	bcs	notcbar
	cmpi.w	#15,d4
	bcc	notcbar
	cmpi.w	#13,d3
	bcs	leftar
	cmpi.w	#67,d3
	bcs	notcbar
	cmpi.w	#80,d3
	bcc	notcbar
*
*  right arrow clicked..
*
ritear:
	eor.w	#$c,d7
	btst.l	#1,d6		;is color scroll rite continous on?
	bne	spedctrl	;br to speed control if so
	btst.l	#0,d6		;how about continous left?
	beq.s	ritear1		;br if not
*
	clr.w	cscrolst	;else, stop left color scroll continous
	move.w	dura,duration	;save duration in file header
*
	movem.w	d0-d4,-(sp)
	move.w	#cbarx+2,d0
	move.w	#cbary+2,d1
	moveq	#23,d2
	moveq	#15,d3
	bsr	draw		;unselect left arrow
	movem.w	(sp)+,d0-d4
	bsr	othsame
	bra	matupd
ritear1:
	movem.w	d0-d4,-(sp)
	move.w	#cbarx+68,d0
	move.w	#cbary+2,d1
	moveq	#24,d2
	moveq	#15,d3
	bsr	invdraw		;select rite arrow
	movem.w	(sp)+,d0-d4
	btst.l	#3,d2		;right click?
	beq.s	ritear2		;br if not right (must be left)
	bsr	cunundo		;do whole palette undo
	move.w	#2,cscrolst	;set color scroll rite continous
	clr.w	dura
	bra	matupd
ritear2:
	bsr	cunundo		;do whole palette undo
	bsr	cscrolr		;single scroll rite
*
*  loop until button released
*
ritear3:
	bsr	mouseget
	btst.l	#4,d2		;left trailing edge?
	beq.s	ritear3
	movem.w	d0-d4,-(sp)
	move.w	#cbarx+68,d0
	move.w	#cbary+2,d1
	moveq	#24,d2
	moveq	#15,d3
	bsr	draw		;deselect rite arrow
	movem.w	(sp)+,d0-d4
	bra	matupd
*
*
*  left arrow clicked
*
leftar:
	btst.l	#0,d6		;is color scroll left continous on?
	bne	spedctrl	;br to speed control if so
	btst.l	#1,d6		;how about continous right?
	beq.s	leftar1		;br if not
*
	clr.w	cscrolst	;else, stop right color scroll continous
	move.w	dura,duration
*
	movem.w	d0-d4,-(sp)
	move.w	#cbarx+68,d0
	move.w	#cbary+2,d1
	moveq	#24,d2
	moveq	#15,d3
	bsr	draw		;unselect right arrow
	movem.w	(sp)+,d0-d4
	bsr	othsame
	bra	matupd
leftar1:
	movem.w	d0-d4,-(sp)
	move.w	#cbarx+2,d0
	move.w	#cbary+2,d1
	moveq	#23,d2
	moveq	#15,d3
	bsr	invdraw		;select left arrow
	movem.w	(sp)+,d0-d4
	btst.l	#3,d2		;right click?
	beq.s	leftar2		;br if not right (must be left)
	bsr.s	cunundo		;do whole palette undo
	move.w	#1,cscrolst	;set color scroll left continous
	clr.w	dura
	bra	matupd
leftar2:
	bsr.s	cunundo		;do whole palette undo
	bsr	cscroll		;single scroll left
*
*  loop until button released
*
leftar3:
	bsr	mouseget
	btst.l	#4,d2		;left trailing edge?
	beq.s	leftar3
	movem.w	d0-d4,-(sp)
	move.w	#cbarx+2,d0
	move.w	#cbary+2,d1
	moveq	#23,d2
	moveq	#15,d3
	bsr	draw		;deselect left arrow
	movem.w	(sp)+,d0-d4
	bra	matupd
*
*  color un UNDO
*
cunundo:
	movem.l	a0-a1/d0,-(sp)	;do whole palette unundo
	movea.l	#colorz,a0
	movea.l	#undopalt,a1
	moveq	#15,d0
cunundox:
	move.w	(a0)+,(a1)+
	dbra	d0,cunundox
	movem.l	(sp)+,a0-a1/d0
	rts

*  continuous mode, left button is speed up, right is slow down..
*
spedctrl:
	btst.l	#2,d7		;test for left button click
	bne.s	spedup
	addq.w	#1,csped
	bra	matupd
spedup:
	subq.w	#1,csped
	cmpi.w	#1,csped
	bcc	matupd
	move.w	#1,csped
	bra	matupd
notcbar:
*
*  Check for UNDO box click
*
	btst.l	#2,d2		;left click?
	beq.s	noundo
	cmpi.w	#cbarx+81,d0
	bcs.s	noundo
	cmpi.w	#cbarx+114,d0
	bcc.s	noundo
	cmpi.w	#cbary+1,d1
	bcs.s	noundo
	cmpi.w	#cbary+14,d1
	bcc.s	noundo
	bsr	undo
	bra	matupd
noundo:
*
*  Check for sub mode menu click..
*
	move.w	d0,d3
	sub.w	#cbarx,d3		;check horz for within submode menu
	bcs.s	notrb			;br if left of here
	move.w	d1,d4
	sub.w	#cbary+16,d4		;check vert for within submode menu
	bcs.s	notrb
*
	bsr	modeupd			;service sub menu/mouse interaction
	bra	matupd
*
*  Now check position in left icon block
*
notrb:
	move.w	d0,d3			;copy mouse x 
	move.w	d1,d4			;  & y
*
*  re-entrant point for eraser double click
*
refunc:
	subi.w	#iconlx,d3		;subtract left Icon Block minimum
	bcs	notlb			;br if left of IB
	move.w	d3,d5			;move x offset into IB to d5
	ext.l	d5	
	divu	#iconw,d5		;divide by width
	cmpi.w	#iconlw,d5		;beyond iconrw columns to right?
	bcc	notlb			;br if to right of IB
*
	subi.w	#iconly,d4		;same for y co-ord
	bcs	notlb			;br if above IB
	move.w	d4,d6
	ext.l	d6
	divu	#iconh,d6
	cmpi.w	#iconlh,d6
	bcc	notlb
*
*  Within left Icon block, check for icon
*
	movea.l	#liconlst,a0
	move.w	d6,d7
	mulu	#iconlw,d7
	add.w	d5,d7		;d7 = icon index
*
	tst.b	(a0,d7)		;test for 0 icon #
	beq	matupd		;br if no icon present
*
*  Got an icon
*
	swap	d5		;d5 = x offset into icon (divu remandr)
	swap	d6		;d6 = y offset	
	sub.w	d5,d3		;find top/left corner x
	sub.w	d6,d4		;& y of selected icon
	addi.w	#iconlx+1,d3	;add IB base top/left x
	addi.w	#iconly+1,d4	;& IB base top/left y
	move.w	d3,d5		;save x in d5
	move.w	d4,d6		;y in d6
*
*  Icon # determines action taken for single/double click; left/right
*
*  Draw left icon
*
	movem.w	d0-d2,-(sp)
*
	bsr	hidem			;hide cusor
*
	movem.l	d0-d7/a0,-(sp)
	movea.l	#deinits,a0
	move.b	likesel,d7
	lsl.w	#2,d7
	ext.w	d7
	move.l	(a0,d7.w),a0
	jsr	(a0)			;de-initialize old
	movem.l	(sp)+,d0-d7/a0
*
	cmpi.w	#10,d7		;diskette icon?
	bne.s	nwritout	;br if not--do normal
	movem.w	(sp)+,d0-d2	;else, restore stack
	btst.l	#2,d2		;check left button
	bne	writout
	bra	getnewfl
*	bra	writout		;and do save dialog box
*
nwritout:
*
*
	move.w	#15,d3		;color 15
	move.b	likesel,d1	;get previous left icon index selected
	andi.w	#$FF,d1
	move.b	(a0,d1.w),d2	;get previous left icon #
	ext.l	d1
	divu	#iconlw,d1
	swap	d1
	move.w	d1,d0
	swap	d1
	mulu	#iconw,d0
	mulu	#iconh,d1
	addi.w	#iconlx+1,d0
	addi.w	#iconly+1,d1
	cmpi.b	#18,d2		;eraser icon?
	beq.s	eraz
	move.w	d0,lastx
	move.w	d1,lasty
eraz:
	bsr	drawq			;de-select old icon
*
	move.w	d5,d0
	move.w	d6,d1
	move.b	(a0,d7),d2
	andi.w	#$FF,d2
	bsr	invdrawq		;select new
	move.b	d7,likesel		;save new right icon index
*
*	movem.l	d0-d7/a0,-(sp)
	move.w	4(sp),d2		;get buttons back
	movea.l	#inits,a0
	move.b	likesel,d7
	lsl.w	#2,d7
	ext.w	d7
	move.l	(a0,d7.w),a0
	clr.b	undoyet
	jsr	(a0)			;initialize new
	bsr	modedraw		
	tst.b	cpyrite
	bmi.s	modok
	move.b	#$80,cpyrite
	bsr	time3x			;put up "FILENAME.NEO"
modok:
*	movem.l	(sp)+,d0-d7/a0
*
	bsr	othsame		;update other screen too
*
	bra	matupdx
*
*  Check color matrix selection
*
notlb:
	move.w	d0,d3			;copy mouse x 
	move.w	d1,d4			;  & y
	subi.w	#fatblkx1,d3		;subtract Fat matrix x minimum
	bcs	matupd			;br if left of Fat
	move.w	d3,d5			;move x offset into IB to d5
	ext.l	d5	
	divu	#fatpxlw,d5		;divide by width
	cmpi.w	#fatpxlnx,d5		;beyond max # columns to right?
	bcc	matupd			;br if to right of Fat
*
	subi.w	#fatblky1,d4		;same for y co-ord
	bcs	matupd			;br if above Fat
	move.w	d4,d6
	ext.l	d6
	divu	#fatpxlh,d6
	cmpi.w	#fatpxlny-1,d6
	bcc	matupd
*
*  check left or right edge
*
	btst.l	#2,d2			;left button click?
	bne	matcolsl		;br if so
*
*  right button click, do color drag
*
	move.w	#1,d0
	bsr	chgxcur			;change to hand cursor
*
	clr.w	cdragx
*
	bsr	showm			;show mouse
cdraglp:
	bsr	mouseget
	btst.l	#5,d2			;right button trailing trigger?
	bne	cdragi
	move.w	cdragx,d5
	move.b	paltx,d4
	ext.w	d4
	sub.w	d0,d3			;find delta x
	bcc.s	cdragl			;br if dragging left
*
*  dragging right
*
	eor.w	#-1,d3
	addq.w	#1,d3
	add.w	d3,d5			;add to accum
	ext.l	d5
	divu	#5,d5
	sub.w	d5,d4
	bcs.s	cdraglp
	bra.s	newmatrx
*
*  dragging left
*
cdragl:
	add.w	d3,d5			;add to accum
	ext.l	d5
	divu	#5,d5
	add.w	d5,d4
	cmpi.b	#32-12,d4
	bcc.s	cdraglp
newmatrx:
	swap	d5
	move.w	d5,cdragx
	cmp.b	paltx,d4
	beq.s	cdraglp
	bsr	unselbox
	move.b	d4,paltx
	bsr	big2palt
	move.b	matselx,d0
	sub.b	paltx,d0
	bcs.s	newmatrz
	cmpi.b	#fatpxlnx,d0
	bcc.s	newmatrz
	ext.w	d0
	move.b	matsely,d1
	ext.w	d1
	bsr	hotbox
newmatrz:
	bsr	othsame
*
	bsr	showm			;show mouse
*
	bra	cdraglp
cdragi:
	movem.w	d0-d1,-(sp)
*
	bsr	hidem			;test code
	bsr	othsame
*
	moveq	#15,d0
	bsr	chgxcur			;back to arrow cursor
*
	movem.w	(sp)+,d0-d1
	bra	matupd
*
*  left button clicked on matrix color, select it..
*
matcolsl:
	movem.w	d0-d1,-(sp)
	move.b	d5,d0			;copy horz pixel # to d0
	add.b	paltx,d0		;add matrix left edge offset
	cmp.b	matselx,d0		;selecting different?
	bne.s	matcolnw		;br if so
	cmp.b	matsely,d6
	beq.s	matcolod		;br if same as before--allow double clk
matcolnw:
	bclr.l	#6,d2			;force no double click
	bsr	unselbox
	move.b	d0,matselx
	move.b	d6,matsely
	move.w	d5,d0
	move.w	d6,d1
	bsr	hotbox
matcolod:
	movem.w	(sp)+,d0-d1
*
	bsr	setc14			;set up selected color as color14
	bsr	othsame		;update other screen too
*
*
*  entry point if click occurred on color patch..
*
putcolor:
	btst.l	#6,d2			;left double click?
	beq	matupd			;br if no
	clr.b	touch
	movea.l	#colorz,a0
	movea.l	#undopalt,a1
	move.w	selctcol,d5
	lsl.w	d5
	move.w	(a0,d5.w),(a1,d5.w)	;save in undo palette area 1st
	move.w	color14,(a0,d5.w)	;copy bigpalt color to 16 color pallet
	tst.w	d5
	bne	matupd			;br if not background color change
	bsr	back2bot		;else, set phantom bottom row to backg
	bra.s	matupd
*	
*
*
matupdx:
	bsr	showm
*
	movem.w	(sp)+,d0-d2
	bra.s	matupd
*
*
*  get pixel for color selector
*
newselc:
	movem.w	d0-d2,-(sp)
*
	move.w	#104,d1		;15-Jul make y always fall within color palette
*
	bsr	getpix		;get pixel color index at d0,d1 in d3
*
	tst.w	d3
	bne.s	dounc
	cmpi.w	#20,(sp)	;x pos is 1st to pop
	bcc.s	noput
dounc:
	bsr	uncolor
	move.w	d3,selctcol
	bsr	textset
	bsr	pointcol
*	clr.b	touch
	move.b	likesel,d5	;in text mode?
	cmpi.b	#3,d5
	bne.s	noput
*
*  in text mode, do text color change
*
	bsr	othsame
	bsr	newtxtmd
noput:
	btst.b	#6,5(sp)	;test left dclick of d2.w saved as d0-d2,-(sp)
	beq.s	nocolrd		;br if no double click on this pallet entry
	movea.l	#colorz,a0	;ptr to color pallet
	move.w	selctcol,d5	;get currently selected color
	lsl.w	d5		;*2
	move.w	(a0,d5.w),d5	;get color
	bsr	searchc		;search & install color
nocolrd:
	movem.w	(sp)+,d0-d2
	bsr	othsame		;update other screen too
*
*
*
matupd:
	bsr.s	chktext		;check modes & flush text
	beq.s	matupdd		;br if not (textmode & key waiting)
	bra.s	funkdo
abovemid:
	bsr.s	chktext		;check modes & flush text ( likesel -> d5 )
funkdo:
	movea.l	#funcs,a0
	lsl.w	#2,d5
	movea.l	(a0,d5.w),a0
	movem.w	d0-d1,-(sp)
	jsr	(a0)
	movem.w	(sp)+,d0-d1
matupdd:
	bsr	matrix
	bra	loop
*
*
getpix:
	movem.l	a0/d0-d2,-(sp)
	movea.l	curscren,a0
	mulu	#160,d1
	move.w	d0,d2
	lsr.w	#1,d0
	andi.w	#$FFF8,d0
	add.w	d0,d1
	adda.w	d1,a0
	not.w	d2
	andi.w	#$f,d2
	bclr.l	#3,d2
	bne.s	getpix1
	addq.l	#1,a0
getpix1:
	moveq	#0,d3
	move.w	#3,d1
getpix2:
	lsr.w	#1,d3
	btst.b	d2,(a0)
	beq.s	getpix3
	ori.w	#8,d3
getpix3:
	addq.l	#2,a0
	dbra	d1,getpix2
	movem.l	(sp)+,a0/d0-d2
	rts
*
*  Flush extranneous text
*
*  exit:
*       d5 - current left function selected
*	nz if [(textmode & key waiting) or (copymode & function key)] , else z
*
chktext:
	move.b	likesel,d5		;get left icon index (current mode)
	ext.w	d5
	btst	#14,d2		;character waiting?
	beq.s	zexit		;if none, exit z flag
	cmpi.b	#3,d5		;in textmode?
	beq.s	nzexit		;if so, let text entry thru
	move.w	conchar,d6	;get console scan code
	cmpi.b	#$61,d6		;undo char?
	beq.s	zexit
	cmpi.b	#1,d6		;esc char?
	beq.s	zexit
	clr.l	conchar		;flush non undo/esc chars
*
	subi.b	#func1,d6	;was this a function key?
	bcs.s	zexit		;br if not
	addq.w	#1,d6		;maybe it was
	cmpi.b	#11,d6
	bcc.s	zexit		;br if not
	tst.b	bigram
	beq.s	zexit		;br to skip func key save--only little RAM here
	move.b	d6,funky	;save 1-10 for new function key
	cmpi.b	#2,d5		;copybox mode?
	beq.s	nzexit		;if so-- nzexit; do function
	tst.w	d5		;jacknife?
	beq.s	nzexit		;if so-- nzexit; do function
zexit:
	moveq	#0,d6
	rts
nzexit:
	moveq	#1,d6
	rts
*
*
*  entry:
*  	d5 is desired color value
*  exit:
*	d5 is installed in color14, mcp searched and color is selected therein
*
searchc:
	bsr	unselbox	;erase box around previously selected color
	move.w	#511,d6
	movea.l	#bigpalt,a0
colrdlp:
	cmp.w	(a0)+,d5	;found color in pallet?
	beq.s	colfnd		;br if found
	dbra	d6,colrdlp
*
*  color not found, fake out using phantom color
*
	move.w	d5,(a0)		;save desired color in phantom
	move.w	#32,d7
	moveq	#0,d6
	bra.s	nobox		;%%%
colfnd:
	move.w	#511,d7
	sub.w	d6,d7
	move.w	d7,d6
	lsr.w	#4,d7		;/16 -> matselx
	andi.w	#$f,d6		;	matsely
nobox:
	move.b	d7,matselx
	move.b	d6,matsely
	bsr	setc14
	move.b	d7,d0
	sub.b	paltx,d0
	bcs.s	nocolrdx
	cmpi.b	#fatpxlnx,d0
	bcc.s	nocolrdx
	ext.w	d0
	move.b	d6,d1
	ext.w	d1
	bsr	hotbox
nocolrdx:
	rts
*
* Save then exit program
*
rexboxld:
	move.b	#1,saveq		;set to resume picture load after save
	bra.s	rexbox1
rexbox:
	move.b	#-1,saveq		;set to quit after next save
	bra.s	rexbox1
*
******************************************
*
*  Exit program..
*
*
writout:
	bsr	gemready
*
*	bsr	hidem			;hide mouse
	bsr	rezset
	bsr	showm			;show mouse
*
	move.w	d0,-(sp)
	moveq	#15,d0
	bsr	chgxcur			;change to pointer form
	move.w	(sp)+,d0
	clr.b	saveq			;revert to program after save
*
*
*  re-entry point 
*
rexbox1:
	movea.l	#path,a0	;load path name into template
	movea.l	#tplate0,a1
*	movea.l	#owalrt,a2
	moveq	#7,d0
tploop:
	move.b	(a0)+,d1
	cmpi.b	#".",d1
	bne.s	tploop1
	
tploop2:
*	move.b	#" ",(a2)+
	move.b	#0,(a1)+
	dbra	d0,tploop2
	bra.s	tploop3
tploop1:
	move.b	d1,(a1)+
*	move.b	d1,(a2)+
	dbra	d0,tploop
*
tploop3:
	move.w	#obdrxclp,d0
	tst.w	rezsav
	beq.s	lorez
	move.w	#200,d0
lorez:
	move.w	d0,xrepo
	subq.w	#3,d0
*
	movea.l	#int_in,a0
	move.w	#0,(a0)+
	move.w	#8,(a0)+
*	move.w	#obdrxclp-3,(a0)+
	move.w	d0,(a0)+
	move.w	#obdryclp-3,(a0)+
	move.w	#obdrwclp+6,(a0)+
	move.w	#obdrhclp+6,(a0)+
	move.l	#exitbox,addr_in
*
	bsr	objc_drw
*
	move.w	#2,int_in
	move.l	#exitbox,addr_in
	bsr	form_do
*
	move.w	saveflg,d1
	move.w	quitflg,d2
	move.w	canclflg,d3
	move.w	#NORMAL,saveflg
	move.w	#NORMAL,quitflg
	move.w	#NORMAL,canclflg
*
	tst.w	d1
	bne	saveit	
*
	tst.w	d2
	beq.s	cancel
*
	tst.b	touch			;has picture been touched?
	bne	exit			;br if not--exit
*
*  ask user if he's sure he wants to throw touched picture away..
*
	bsr	hidem			;hide mouse
	bsr	rezset
	bsr	showm			;show mouse
*
	move.l	#abndalrt,d0
	bsr	alertout
	move.w	int_out,d1
	cmpi.w	#1,d1
	beq	rexbox			;re-prompt filename & exit if save
	bra	exit
*
*  cancel dialog box & go back to picture in progress...
*
cancel:
	bsr	hidem			;hide mouse
	bsr	rezclr
	bsr	showm			;show cursor
*
	bsr	mouseget		;check cursor position
	cmp.w	half,d1			;above mid-line?
	bcc.s	nocurchg
	bsr	chg2cur
nocurchg:
	move.w	#$FFFF,henabl
	move.w	#$2500,irqlev
*
	bsr	time3x
*
	movea.l	#inits,a0
	move.b	likesel,d7
	lsl.w	#2,d7
	ext.w	d7
	move.l	(a0,d7.w),a0
	clr.b	undoyet
	jsr	(a0)			;re-initialize interrupted function
*
	bra	loop
*
*  save disk file...
*
saveit:
*
*  code for Sig Hartmann's demo
*
*	nop
*
*	.if	!nosave
*
*  end Sig code
*
*	tst.b	mpass			;saves not allowed if
*	beq.s	exit1			;master password not used
*
*  will need to check if copybox is present, & erase it first
*
	movea.l	curscren,a0		;kill last undo first
	movea.l	screen0,a1
	move.w	handy,d0
	mulu	#160,d0
	adda.w	d0,a1
	move.w	#999,d0
splat1:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,splat1
*
	movea.l	#path,a0	;load template into path name
	movea.l	#tplate0,a1
	movea.l	#owalrt,a2
	move.w	#7,d0
tpath0:
	move.b	(a1)+,d1
	beq.s	tpath3x
	cmpi.b	#" ",d1
	beq.s	tpath2
	move.b	d1,(a0)+
	move.b	d1,(a2)+
tpath2:
	dbra	d0,tpath0
	bra.s	tpath3i
*
tpath3x:
	move.b	#" ",(a2)+
tpath3:
	dbra	d0,tpath3x
tpath3i:
	move.b	#".",(a0)+
	move.b	#"N",(a0)+
	move.b	#"E",(a0)+
	move.b	#"O",(a0)+
*
	moveq	#0,d1
	move.w	#12,d0
tpath4:
	move.b	d1,(a0)+
	dbra	d0,tpath4
*
*  new code
*
*  file to write pathname is built--see if this file exists already..
*
*
*
	move.w	#0,-(sp)
	move.l	#path,-(sp)
	move.w	#$3d,-(sp)	;open for read (see if one exists)
	trap	#1
	addq.l	#8,sp
*
	tst.w	d0		;does it exist already?
	bmi.s	noexist		;br if not--don't sweat overwriting existing
*
	move.w	d0,-(sp)
	move.w	#$3e,-(sp)
	trap	#1		;close existing file
	addq.l	#4,sp
*
	bsr	hidem
	bsr	rezset
	bsr	showm
*
	move.l	#ovwtalrt,d0
	bsr	alertout
	move.w	int_out,d1
	cmpi.w	#1,d1
	bne	rexbox1
*
*  end new code
*  
noexist:
	move.w	#0,-(sp)
	move.l	#path,-(sp)
	move.w	#$3c,-(sp)	;create file
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handle
	bpl.s	writnxt
	move.l	#dskalrt3,d0	;disk write-protected?
	bsr	alertout
	cmpi.w	#1,int_out
	beq.s	noexist		;br to retry
	bra	cancel
writnxt:
	move.w	colleft,d0
	lsl.w	#4,d0
	or.w	colrite,d0
	bset.l	#15,d0
	move.w	d0,cpterz	;save color ptrs
*
	move.w	cscrolst,d1	;see if color scrolling?
	beq.s	writnxtx	;skip if not
	move.w	csped,d0
	btst.l	#0,d1		;scrolling left?
	beq.s	writnxty	;br if not--must be right
	neg.b	d0
writnxty:
	andi.w	#$FF,d0
	bset.l	#15,d0
	move.w	d0,colsped
writnxtx:
*
*  ****new virtual canvas stuff
	moveq	#0,d3		;assume screen
	tst.b	virtouch
	bne.s	novtch
*
	move.l	#viralrt,d0	;save canvas or screen?
	bsr	alertout
	moveq	#-1,d3		;assume canvas
	cmpi.w	#1,int_out
	bne.s	docanv		;br if not screen
*
	moveq	#0,d3		;do screen
*	not.b	virtouch	:??????
	bra.s	novtch
*
docanv:
	bsr	handii
	move.w	#vpixwd,d0
	move.w	#vpixht,d1
	move.w	#$BABE,d2
	bra.s	novtch1
novtch:
	move.w	#320,d0
	move.w	#200,d1
	moveq	#0,d2
novtch1:
	movea.l	#neowidth,a0
	move.w	d2,fileid-neowidth(a0)
	move.w	d0,(a0)+
	move.w	d1,(a0)+
*   ***end new
*
	move.w	d3,-(sp)	;save screen or canvas
*
	move.l	#fileid,-(sp)
	move.l	#128,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)	;write 128 bytes of header to file
	trap	#1
	add.w	#12,sp
*
	move.w	(sp)+,d3	;restore screen or canvas
*
	cmpi.w	#128,d0
	bne.s	fwtbad
	tst.l	d0
	bmi.s	fwtbad
*
*  new stuff for virtual canvas
*
*	tst.b	virtouch
*	bne.s	nrmwrgfx
*
	tst.w	d3
	beq.s	nrmwrgfx
*
	movea.l	vcanbase,a0
	move.l	#vformwd,d1
	move.w	#vpixht,d2
	subq.w	#1,d2
vwrtlp:
	move.w	d2,-(sp)
	move.l	a0,-(sp)	;use main screen
	move.l	d1,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)	;write vformwd bytes to file
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,d1
	move.l	(sp)+,a0
	adda.w	d1,a0
	move.w	(sp)+,d2
*
	cmp.w	d1,d0
	bne.s	fwtbad
	tst.l	d0
	bmi.s	fwtbad
	dbra	d2,vwrtlp
	bra.s	writnxt1
nrmwrgfx:
*	
*  end new stuff
*
	move.l	screen0,-(sp)	;use main screen
	move.l	#32000,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)	;write 32000 bytes to file
	trap	#1
	add.w	#12,sp
*
	cmpi.w	#32000,d0
	bne.s	fwtbad
	tst.l	d0
	bpl.s	writnxt1
fwtbad:
	move.l	#dskalrt2,d0
	bsr	alertout
*
	move.l	#path,-(sp)
	move.w	#$41,-(sp)	;delete incomplete file
	trap	#1
	addq.l	#6,sp
*
	bra	cancel
writnxt1:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)	;close file
	trap	#1
	addq.w	#4,sp
	tst.l	d0
	bne.s	fwtbad
	move.b	#-1,touch	;indicate file untouched from saved version
	tst.b	saveq		;exit or return to picture after save?
	beq	cancel		;go back to picture
	bpl	doread		;else, continue loading input picture
*
exit:
exit1:
*
*  end test
*	
	bsr	hidem			;hide mouse
*
	move.l	#paletsav,curpalt
	move.l	#paletsav,-(sp)
	move.w	#6,-(sp)		;set pallet
	trap	#14
	addq.l	#6,sp
*
	movea.l	#contrl,a0
	move.w	#126,(a0)		;old exchange mouse movement vector
	clr.w	2(a0)
	clr.w	6(a0)
	move.l	oldmouse,14(a0)
	bsr	vdicall
*
	move.w	#125,(a0)		;old exchange mouse button vector
	clr.w	2(a0)
	clr.w	6(a0)
	move.l	oldbuttn,14(a0)
	bsr	vdicall
*
	move.w	rezsav,-(sp)
	move.l	physadd,-(sp)
	move.l	physadd,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.w	#12,sp
*
	clr.l	-(sp)		;enter supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,sstackp
*
	.dc.w	$a000			;get base address of lineA variables
	move.w	horzmax,-692(a0)
	move.w	vertmax,-690(a0)
	move.w	colmax,-666(a0)
*
	move.l	old_hand.l,criterr.l	;restore critical error handler
*
	move.l	tcdifsav.l,eventmc.l	;release timer c differed vector
*
	move.l	keysav.l,keybrdv.l	;release keyboard irq
	move.l	timrcsav.l,timercv.l ;release timer c
*
	andi.b	#$FE,iera
	andi.b	#$FE,imra
	move.l	hblksav.l,hblkcv.l	;release h_blank irq
*
	move.l	vblksav.l,vblankv.l	;release v-blank
*
	move.l	sstackp,-(sp)	;exit supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
*
	lea	contrl,a0
	move.w	#101,(a0)
	clr.w	2(a0)
	clr.w	6(a0)
	bsr	vdicall		;close virtual workstation
*
	bsr	appl_ext	;exit application
*
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	rts
*
*  copyright message display
*
copyrite:
	tst.b	cpyrite
	bmi.s	copyrit1
	movem.l	a0/d0-d2,-(sp)
	move.b	cpyrite,d2
	ext.w	d2
	move.w	cpytime(pc,d2.w),d0
	cmp.w	frmcnt,d0
	bcc.s	copyrit2
	subq.b	#2,cpyrite
	bsr	hidem
*	
*	jsr	cpydo(pc,d2.w)		;assembler makes this "bsr cpydo"
*
	.dc.w	$4ebb
rel1:
	.dc.w	$2000+(cpydo-rel1)	;fake out jsr cpydo(pc,d2.w)	

	bsr	showm
copyrit2:
	movem.l	(sp)+,a0/d0-d2
copyrit1:
	rts
*
*	
cpytime:
	.dc.w	17*60,11*60,6*60
cpydo:
	bra.s	time3
	bra.s	time2
time1:
	movea.l	#copymsg,a0
	moveq	#0,d0
	move.w	#182,d1
	bsr	systxt8
	rts
time2:
	movea.l	#msg0,a0
	moveq	#0,d0
	move.w	#182,d1
	bsr	systxt8
	bsr	clright
	movea.l	#grafptrs+160,a4
	bsr	drawlayo
	rts
*
*
*
time3:
	bsr	clright
time3x:
	move.l	curscren,a0
	adda.w	#(160*182),a0
	move.w	#7,d0
	moveq	#0,d1
time3lpx:
	moveq	#13,d2
time3lp:
	move.l	d1,(a0)+	
	dbra	d2,time3lp
	move.l	#$00FF00FF,d2
	and.l	d2,(a0)+
	and.l	d2,(a0)+
	adda.w	#160-64,a0
	dbra	d0,time3lpx
*
	move.l	#path,d1
	move.l	d1,a0
	move.w	#16*4,d0
centerlp:
	subq.w	#4,d0
	tst.b	(a0)+
	bne.s	centerlp
*
	move.l	d1,a0
*	moveq	#0,d0
	move.w	#182,d1
	bsr	systxt8
	rts
*
*
err_hand:
	rts
*
*
	.if	0
*
*  temp code to block unauthorized use
*
passit:
	move.l	#password,a2
	clr.b	mpass
passloop:
	move.l	a2,-(sp)
	bsr	copyrite
	bsr	mouseget
	move.l	(sp)+,a2
	move.l	conchar,d0
	beq.s	chkmous
	clr.l	conchar
	cmpi.b	#"a",d0
	bcs.s	nofold
	cmpi.b	#"z"+1,d0
	bcc.s	nofold
	sub.b	#"a"-"A",d0
nofold:
	cmpi.b	#13,d0		;end?
	beq.s	endpass
	cmp.b	(a2)+,d0
	beq.s	passloop
	cmpa.l	#password+1,a2
	bne.s	userfail
	move.l	#massword,a2
	move.b	#$80,mpass
	bra.s	nofold
endpass:
	tst.b	(a2)
	bne.s	failwrd
	bclr.b	#0,mpass
	bne.s	failwrd
	rts	
chkmous:
	tst.b	d2
	beq.s	passloop
	bra.s	failx
userfail:
	ori.b	#1,mpass
	bra.s	passloop
failwrd:
	subq.b	#1,nfail
	bne.s	passit
failx:
	trap	#15
	move.w	d0,$24
*
*
password:
	.dc.b	"WIZARD",0
massword:
	.dc.b	"GROGLEY",0
*
	.endif
*
	.even
*
*  end police garbage
*
*************************
*  constant data	*
*************************
*
_pblock:
	.dc.l	contrl
	.dc.l	intin
	.dc.l	ptsin
	.dc.l	intout
	.dc.l	ptsout
*
aes_pb:
	.dc.l	control
	.dc.l	global
	.dc.l	int_in
	.dc.l	int_out
	.dc.l	addr_in
	.dc.l	addr_out
*
dskalrt0:
	.dc.b	"[3][ |Disk file not found.][OK]",0
dskalrt1:
	.dc.b	"[3][ |Picture file read is not|correct format..][OK]",0
dskalrt2:
	.dc.b	"[3][ |Disk full error.|Use a disk with more space.][OK]"
	.dc.b	0
dskalrt3:
	.dc.b	"[1][ |Disk may be|write-protected.][Retry|Cancel]"
	.dc.b	0
rezalert:
	.dc.b	"[3][Application does not|support Monochrome monitor...|"
	.dc.b	"Use color monitor][Exit]",0
abndalrt:
	.dc.b	"[2][ |Save changes|before Quitting?][Yes|No]",0
ovwtalrt:
	.dc.b	"[2][ |Overwrite existing|   '"
owalrt:
	.dc.b	"xxxxxxxx.NEO' ?][Yes|No]",0
jackalrt:
	.dc.b	"[3][ |Not enough RAM for|Jack Knife or Copybox...|"
	.dc.b	"Get TOS in ROM at your dealer!][Exit]",0
viralrt:
	.dc.b	"[2][ |Save Screen only|or Full Canvas?][Screen|Canvas]",0
*
*
*
*************************
*  modifiable data	*
*************************
*
	.data
*
	.eject
**********************************************************************
*
*	
*   file header block..
*
fileid:
	.dc.w	0	;static grafix (0) or program (-1) (NEO only takes 0)
resolut:
	.dc.w	0	;resolution (NEO only takes 0)
colorz:
	.dc.w	$000,$700,$730,$750,$770,$470,$070,$075
	.dc.w	$077,$057,$027,$007,$507,$707,$704,$777
progfnam:
	.dc.b	"        "	;file name if program
	.dc.b	".   "
*
cpterz:
	.dc.w	0	;color ramp ptrs (bit15 set if in effect,
*		hi nibble of lo byte is left ptr, lo nibble is right ptr; 0-15)
*
colsped:
	.dc.w	0	;color scroll speed (bit15 set if in effect,
*		lo byte is signed frames/color step, negative for scroll left
*
duration:
	.dc.w	0	;# of color steps til next picture may be displayed
*
*
*
*   Not used (yet!) ...
*
*  Neo picture placement & dimensions
*
neox:
	.dc.w	0	;left-most horz pixel position
neoy:
	.dc.w	0	;top-most vert pixel position
neowidth:
	.dc.w	320	; width of .NEO picture in pixels
neohite:
	.dc.w	200	;height of .NEO picture in pixels
*
*
	.dc.w	0		
	.dc.w	0,0,0,0,0,0,0,0
	.dc.w	0,0,0,0,0,0,0,0
	.dc.w	0,0,0,0,0,0,0,0
	.dc.w	0,0,0,0,0,0,0,0
*
*  end of 128-byte .NEO file header block
*
	.eject
*
full:
	.dc.w	0		;non-zero if full screen editing mode
curfont:
	.dc.w	0		;current font for graftxt to use (0,1,2,3,4,5)
*
*
*
*  "Saving picture as.."
*
exitbox:
	.dc.w	-1,1,5,G_BOX,NONE,OUTLINED
	.dc.l	$00021100
xrepo:
	.dc.w	obdrxclp,obdryclp,obdrwclp,obdrhclp
*
	.dc.w	2,-1,-1,G_STRING,NONE,NORMAL
	.dc.l	savpic
	.dc.w	30,10,20*8,8
*
	.dc.w	3,-1,-1,G_FBOXTX,EDITABLE,NORMAL
	.dc.l	exteddy
	.dc.w	10,30,20*8,8
*
	.dc.w	4,-1,-1,G_BUTTON,$7	;$7=SELECTBL+DEFAULT+EXIT
saveflg:
	.dc.w	NORMAL
	.dc.l	savebox
	.dc.w	10,50,7*8,8
*
	.dc.w	5,-1,-1,G_BUTTON,$5	;$5=SELECTBL+EXIT
quitflg:
	.dc.w	NORMAL
	.dc.l	quitbox
	.dc.w	90,50,7*8,8
*
	.dc.w	0,-1,-1,G_BUTTON,$25	;$25=SELECTBL+EXIT+LASTOB
canclflg:
	.dc.w	NORMAL
	.dc.l	canclbox
	.dc.w	170,50,8*8,8
*
*  exit box TEDINFO
exteddy:
	.dc.l	tplate0,tplate1,tvalid
*	.dc.w	IBM,0,TE_LEFT,SYS_FG,0,0,12,20
	.dc.w	IBM,0,TE_LEFT,SYS_FG,0,0,9,9
*
*  Strings & other dc.b stuff..
*
copymsg:
	.dc.b	" ",$BD
	.dc.b	" 1986 ATARI  ",0
path:
	.dc.b	"PICTURE.NEO",0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
pathbin:
	.dc.b	"NEO.MCP",0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
*
***************************
*
savpic:
	.dc.b	"Saving Picture as...",0
savebox:
	.dc.b	"Save",0
quitbox:
	.dc.b	"Quit",0
canclbox:
	.dc.b	"Cancel",0
*
tplate0:
	.dc.b	"@2345678",0
tplate1:
	.dc.b	"Name:  ________.NEO",0
tvalid:
	.dc.b	"FFFFFFFF",0
string1:
	.dc.b	" ",0
*rikesel:
*	.dc.b	0	;current right selected icon index
likesel:
	.dc.b	4	;current left selected icon index (start with pencil)
matselx:
	.dc.b	14	;currently selected matrix color x (targx+paltx)
matsely:
	.dc.b	8	;currently selected matrix color y (targy)
undoyet:
	.dc.b	0	;0 if haven't begun writing operation yet
paltx:
	.dc.b	8	;current x offset of fat bits viewport into bigpalt
mcpchg:
	.dc.b	0	;master color pallet changed (non-zero if changed)
*mpass:
*	.dc.b	0	;master password given (if non-zero)
nfail:
	.dc.b	2	;number of failed password attempts allowed
cpyrite:
	.dc.b	4	;4=NEO+Dave; 2=Cprt+Dave; 0=NEO+Jim&Jerome; -2=inactive
touch:
	.dc.b	-1	;-1 if picture untouched, 0 if user has modified
bigram:
	.dc.b	0	;0=512k-RAM loaded system; -1 = min 64k unused RAM
*
*  ***new code for virtual canvas
*
vircan:
	.dc.b	0	;0=no virtual canvas; -1 = virtual canvas enabled
*
*  ****end new code
*
funky:
	.dc.b	0	;last func key depressed (1-10) or 0 if none
xystat:
	.dc.b	0	;bit0 = 0 if x: y: indicator is off; else = 1
saveq:
	.dc.b	0	;after save, 0=to picture; -1=exit ; 1=load new picture
*
	.bss
	.even
*
oldx:
	.ds.w	1
oldy:
	.ds.w	1
*
********************************************
old_hand:
	.ds.l	1	;critical error handler vector save
dura:
	.ds.w	1	;# of color scrolls til next screen (for slide show)
*
*  VDI parameter arrays..
*
contrl:
	.ds.w	12
intin:
	.ds.w	128
ptsin:
	.ds.w	128
intout:
	.ds.w	128
ptsout:
	.ds.w	128
*
*
*  AES parameter arrays..
*
control:
	.ds.w	5
global:
	.ds.w	3
	.ds.l	6
int_in:
	.ds.w	16
int_out:
	.ds.w	7
addr_in:
	.ds.l	2
addr_out:
	.ds.l	1
*
*
*  screen pointers
*
screen0:
	.ds.l	1	;Main screen (non-display)
curscren:
	.ds.l	1	;current Display Screen (what you see is what you get)
othscren:
	.ds.l	1	;alternate Display screen (not currently displayed)
cutscren:
	.ds.l	1	;Cut buffer for copy box (16k if RAM-based, else 32k)
cpyscren:
	.ds.l	1	;source of copy box (16k if RAM-based, else 32k)
physadd:
	.ds.l	1	;System screen address (scratch screen)
vcanbase:
	.ds.l	1	;virtual canvas base address (640x400 pixel)
*
*
horzmax:
	.ds.w	1	;system max horz saved on entry
vertmax:
	.ds.w	1	;system max vert
colmax:
	.ds.w	1	;system max color count
*
rezsav:
	.ds.w	1	;(.b) entry resolution (restored on exit)
curbase:
	.ds.l	1	;temp used by write-out (screen base at exit)
nofile:
	.ds.w	1	;0 if no input file (else 1, or -1 if re-entry)
sstackp:
	.ds.l	1	;temp for supervisor stack when entering/exiting super mode
handle:
	.ds.w	1	;file handle used for readin' or writing
paletsav:
	.ds.w	16	;pallet found on entry to be restored at exit
fs_inpat:
	.ds.b	70	;file selector input directory path
fs_insel:
	.ds.b	64	;file selector output selection
cdragx:
	.ds.w	1	;cursor y pos when start of color pallet drag
lastx:
	.ds.w	1	;previous function mouse x position
lasty:
	.ds.w	1	;previous function mouse y position
	.even
	.ds.b	1024	;program stack
stack:
blitmask:
	.ds.b	8320	;monochrome mask (big enough for rotated screen)
screenz:
	.ds.b	256	;fudge for screen base alignment
	.ds.b	125*256	;1 screens' worth
	.ds.b	125*256	;2 screens' worth
	.ds.b	125*256	;3 screens' worth
*
	.ds.b	15*256	;additional memory appended to othscren for rotate
	.ds.b	140*256	;cut buffer/copy source

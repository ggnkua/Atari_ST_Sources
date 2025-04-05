	fopt	prec=s
	opt c- o+
mminx:		equ	0
mmaxx:		equ	319
mminy:		equ	0
mmaxy:		equ	199
cxmin:		equ	0
cxmax:		equ	319
cymin:		equ	0
cymax:		equ	199
NumStars	equ	80
vbl_vec:	equ	$70
key_vec:	equ	$118
hbl_vec:	equ	$120
bpwidth:	equ	320
bpheight:	equ	200
start:
	clr.l   -(SP)           ;Go into supervisor mode
        move.w  #$20,-(SP)
        trap    #1
        addq.l  #6,SP
        move.l  D0,savesup
	dc.w	$a00a

	lea	palsave,a0
	move.l	#$ff8240,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,ressave

	move.w	#0,-(sp)	;set to low res
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	bsr	getscrn
	bsr	plotinit
	lea	greypalette,a0
	bsr	mydocolors
	bsr	putrout
	bsr	putscreen
	move.w	#100,width
	move.w	#100,height

mainloop:
	tst.w	buttondat
	beq	skippp
	move.w	my,d0
	addq.w	#1,d0
	move.w	d0,growthfactory	
	move.w	mx,d0
	addq.w	#1,d0
	move.w	d0,growthfactorx	
	bsr	 grow
skippp:
	move.w	#10,color
	move.w	mx,pixelx
	move.w	my,pixely
	bsr	putpoint
	bsr	keyboard
	bra	mainloop


grow:
	move.w	growthfactorx,d0
	fmove.w	d0,fp2
	fdiv.s	#100,fp2
	move.w	growthfactory,d0
	fmove.w	d0,fp3
	fdiv.s	#100,fp3

	fmove.w	height,fp4
	fmul	fp3,fp4
	fmove.w	fp4,d1
	subq.w	#1,d1
yloop:
	fmove.w	width,fp5
	fmul	fp2,fp5
	fmove.w	fp5,d0
	subq.w	#1,d0
xloop:
	fmove.w	d0,fp0
	fmove.w	d1,fp1
	fdiv	fp2,fp0
	fdiv	fp3,fp1
	fmove.w	fp0,pixelx
	fmove.w	fp1,pixely
	bsr	getpoint
	
	move.w	d0,pixelx
	add.w	#100,pixelx
	move.w	d1,pixely
	bsr	putpoint
	dbf	d0,xloop
	dbf	d1,yloop
	rts






putscreen:
	move.w	#7999,d7
	lea	pic,a0
	move.l	seen,a1
psl:
	move.l	(a0)+,(a1)+
	dbf	d7,psl
	rts





oldcolor:	ds.w	1
newcolor:	ds.w	1

*****************************************************************
*	dofill							*
*	Does a contourfill bounded by color			*
*								*
*****************************************************************
dofill:
	move.w	mx,d0
	move.w	my,d1
*	move.w	#5,d0
*	move.w	#2,d1

*	move.l	currentscreen,a6
	bsr	getpoint		;find what the color is
	move.w	color,oldcolor		;color started on
	move.w	color,d5
	cmp.w	#15,d5
	beq	fillstop
	move.w	oldcolor,d3
	move.w	#15,newcolor
	move.w	newcolor,d4
*	move.l	currentscreen,a1
	move.l	sp,a0			;to tell when stack empty
	move.w	d0,-(sp)		;x and y on stack
	move.w	d1,-(sp)		;and call my scanline routine
	bra	myfill
fillstop:
*	move.w	#-1,oldcoordx
*	move.w	#1,mouseonoff
*	bra	paintloop
	rts


myfill:
	cmp.l	a0,sp		;while stack not empty
	beq	fillfinished
	move.w	(sp)+,d1		;get y
	move.w	(sp)+,d0		;get x, (pop(x,y))
	move.w	newcolor,color
	bsr	putpoint		;pixel(x,y)=fillvalue
	move.w	d0,savex		;savex=x
trackright:			;fill the span to the right
	addq.w	#1,d0			;x=x+1
	cmpi.w	#319,d0
	bgt.s	extremeright
	move.l	a1,a6
	bsr	getpoint
	cmp.w	color,d3		;if pixel(x,y)<>boundry value
	bne.s	extremeright
	move.w	newcolor,color
	bsr	putpoint
	bra.s	trackright
extremeright:				;save extreme right pixel
	move.w	d0,xright		;xright=x-1
	subq.w	#1,xright
	move.w	savex,d0		;x=savex
trackleft:
	subq.w	#1,d0			;x=x-1
	tst.w	d0
	blt.s	extremeleft
	move.l	a1,a6
	bsr	getpoint
	cmp.w	color,d3		;if pixel(x,y)<>boundry value
	bne.s	extremeleft
	move.w	newcolor,color
	bsr	putpoint
	bra.s	trackleft
extremeleft:				;save extreme right pixel
	move.w	d0,xleft		;xright=x-1
	addq.w	#1,xleft
*	move.w	savex,d0		;x=savex
gocheckbelow:	
	move.w	xleft,d0		;start at extremeleft
	move.w	d1,savey		;save y
	addq.w	#1,d1			;line below
	cmp.w	#199,d1
	bgt	myfill
checkbelow:
	moveq	#-1,d7			;flag for was ever oldcolor
	bsr	getpoint		;get the pixel
	move.w	color,d5		;examine with a state change engine
	cmp.w	d3,d5
	bne.s	checkbelowloop
	moveq	#1,d7
checkbelowloop:
	addq.w	#1,d0
	cmp.w	xright,d0
	beq.s	gocheckabove		;only check in the range xl<=x>=xr
	bsr	getpoint		;get this pixel
	cmp.w	color,d3
	bne.s	cbl1
	moveq	#1,d7
cbl1:
	cmp.w	color,d5		;did the state change
	beq.s	checkbelowloop
	cmp.w	d3,d5			;if the state changed from oldcolor
	beq.s	possibleseed1		;to any other this is one to push
	move.w	color,d5
	bra.s	checkbelowloop
possibleseed1:
	move.w	d0,d2
	subq.w	#1,d2
	move.w	d2,-(sp)		;push new seed on stack
	move.w	d1,-(sp)
	move.w	color,d5		;new oldcolor
	bra.s	checkbelowloop
gocheckabove:
	bsr	getpoint		;get this pixel
	cmp.w	color,d3
	bne.s	cbl2
	moveq	#1,d7
cbl2:
	cmp.w	color,d5		;did the state change
	beq.s	cbover
	cmp.w	d3,d5			;if the state changed from oldcolor
	bne.s	cbover			;to any other this is one to push
	subq.w	#1,d0
	move.w	d0,-(sp)	;push the extreme right on
	move.w	d1,-(sp)
	bra	skipextra1
cbover:
	tst.w	d7
	bmi.s	skipextra1
	cmp.w	color,d3
	bne	skipextra1
	subq.w	#1,d0
	move.w	d0,-(sp)	;push the extreme right on
	move.w	d1,-(sp)
skipextra1:
	move.w	xleft,d0		;start at extremeleft
	move.w	savey,d1		;save y
	subq.w	#1,d1			;line below
	tst.w	d1
	blt	myfill

checkabove:
	moveq	#-1,d7			;flag for was ever oldcolor
	bsr	getpoint		;get the pixel
	move.w	color,d5		;examine with a state change engine
	cmp.w	d3,d5
	bne.s	checkaboveloop
	moveq	#1,d7
checkaboveloop:
	addq.w	#1,d0
	cmp.w	xright,d0
	beq	gomyfill		;only check in the range xl<=x>=xr
	bsr	getpoint		;get this pixel
	cmp.w	color,d3
	bne.s	cal1
	moveq	#1,d7
cal1:
	cmp.w	color,d5		;did the state change
	beq.s	checkaboveloop
	cmp.w	d3,d5			;if the state changed from oldcolor
	beq.s	possibleseed2		;to any other this is one to push
	move.w	color,d5
	bra.s	checkaboveloop
possibleseed2:
	move.w	d0,d2
	subq.w	#1,d2
	move.w	d2,-(sp)		;push new seed on stack
	move.w	d1,-(sp)
	move.w	color,d5		;new oldcolor
	bra.s	checkaboveloop
fillfinished:
	rts

gomyfill:
	bsr	getpoint		;get this pixel
	cmp.w	color,d3
	bne.s	cal2
	moveq	#1,d7
cal2:
	cmp.w	color,d5		;did the state change
	beq.s	caover
	cmp.w	d3,d5			;if the state changed from oldcolor
	bne.s	caover			;to any other this is one to push
	subq.w	#1,d0
	move.w	d0,-(sp)	;push the extreme right on
	move.w	d1,-(sp)
	bra	skipextra2
caover:
	tst.w	d7
	bmi.s	skipextra2
	cmp.w	color,d3
	bne	skipextra2
	subq.w	#1,d0
	move.w	d0,-(sp)	;push the extreme right on
	move.w	d1,-(sp)
skipextra2:
	bra	myfill

savex:	ds.w	1
savey:	ds.w	1
xright:	ds.w	1
yright:	ds.w	1
xleft:	ds.w	1
yleft:	ds.w	1



clearscreen:
	move.l	seen,a0
	moveq	#0,d0
	move.w	#199,d7
csl:
	rept	160/4
	move.l	d0,(a0)+
	endr
	dbf	d7,csl
	rts




****************************************
keyboard:
	move.w	#$ff,-(sp)
	move.w	#$6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	beq	keyback
	swap	d0

	cmp.b	#16,d0		*space
	beq	gem		*yes/no
keyback:
	rts

*****************************************
*	number in d0.l			*
*	d1.l is base			*
*	d2,x cursor			*
*	d3,y cursor			*
*****************************************
prtnum:
	movem.l	d0/d1,-(sp)
	lea	posstring,a0
	add.w	#32,d3
	move.b	d3,2(a0)	
	move.b	d3,10(a0)	
	add.w	#32,d2
	move.b	d2,3(a0)
	move.b	d2,11(a0)	
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0/d1

	lea	linebuffer,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
loop1:
	divu	d1,d0
	swap	d0
	addi	#'0',d0
	cmpi.w	#'9',d0
	ble.s	ok
	addq.w	#7,d0
ok:
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	bne	loop1
loop2:
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


linebuffer:
	ds.l	5
digits:
	dc.b	0
posstring:	dc.b	27,'Y',0,0,' ',' ',' ',' ',27,'Y',0,0,0
	even



***********************************
mydocolors:
	move.l	#$ff8240,a1
	moveq	#15,d0
mdcloop:
	move.w	(a0)+,(a1)+
	dbf	d0,mdcloop
	rts

************get screen address***************
getscrn:move.w  #2,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,seen
	rts

oldmouse:	dc.l	0
******************************************
*               RETURN TO GEM
gem:
*	move.b	#%11111110,$ff820a
	move.l	#$ff8240,a0
	lea	palsave,a1
	moveq	#15,d7
rspl:
	move.w	(a1)+,d0
	and.w	#$0777,d0
	move.w	d0,(a0)+
	dbf	d7,rspl

	move.w  #34,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,a0
	move.l	oldmouse,16(a0)

*	move.l	vblslot,a0
*	move.l	#0,(a0)

        move.w  ressave,-(sp)
        move.l  seen,-(sp)
        move.l  seen,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l  #12,sp

	move.l  savesup,-(SP)    ;Back to user mode
        move.w  #$20,-(SP)
        trap    #1
        addq.l  #6,SP
*illegal
	clr.w	-(sp)
	trap	#1

buttondat:	dc.w	0
mx:		dc.w	0
my:	dc.w	0
*************puts my mouse interupt in***************** 
putrout:move.w  #34,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,a0
	move.l	16(a0),oldmouse
        move.l  #myrout,16(a0)
        rts
lastb:		dc.w	-1
mousehasgoneup:	dc.w	0

**************my ubeut mouse interupt*******************
myrout:
	movem.l	d0-d2/a0-a1,-(sp)
	moveq	#0,d0	
	move.b	(a0),d0
	cmpi.b	#$fa,d0
	bne	myr1
	move.w	#1,buttondat
	bra	myrxy
myr1:
	cmpi.b	#$f9,d0
	bne	myr2
	move.w	#2,buttondat
	bra	myrxy
myr2:
	cmpi.b	#$fb,d0
	bne	myr3
	move.w	#3,buttondat
	bra	myrxy
myr3:
	move.w	#1,mousehasgoneup
	move.w	#0,buttondat
myrxy:
	moveq	#0,d0
	move.b	1(a0),d0
	ext.w	d0
	moveq	#0,d1
	move.b	2(a0),d1
	ext.w	d1
	add.w	d0,mx
	add.w	d1,my
*	sub.w	d1,my2
myr4:	move.w	mx,d0
	move.w	my,d1
	bsr	extra
	move.w	d0,mx
	move.w	d1,my
	movem.l	(sp)+,d0-d2/a0-a1
	rts

extra:  cmpi.w	#mminx,d0
        bge	extra1
        move.w	#mminx,d0
        bra	extra2
extra1: cmpi.w   #mmaxx,d0
        ble	extra2
        move.w  #mmaxx,d0
extra2:	cmpi.w  #mminy,d1
        bge	extra3
        move.w  #mminy,d1
        bra	extra4
extra3: cmpi.w   #mmaxy,d1
        ble	extra4
        move.w  #mmaxy,d1
extra4:
        rts



********************************************
* Atari ST hi-speed plotting subroutine    *
* For Low-resolution mode only		   *
********************************************
plotinit:
	move.l	seen,a0
	move.W	#200,d1
	lea	ytable1,a1
iloop:
	move.l	a0,(a1)+
	adda.w	#160,a0
	subq.b	#1,d1
	bne	iloop
	rts


getpoint:
	movem.l d0-d5/a0-a1,-(sp)
	move.w	pixelx,d0
	cmp.w	#cxmax,d0
	bgt	pltxit
	cmpi.w	#cxmin,d0
	blt	pltxit
	move.w	d0,d3
	andi.w	#15,d3
	move.w	pixely,d1
	cmp.w	#cymax,d1
	bgt	pltxit
	cmpi.w	#cymin,d1
	blt	pltxit
	lsl.w	#2,d1

	move.w	d0,d2
	lsr.w	#1,d0
	and.w	#$00f8,d0
	move.w	d0,a0
	lea	ytable1,a1
	adda.l	(a1,d1.w),a0

	and.w	#$000f,d2	;get last 4 pixels
	moveq	#15,d1
	sub.w	d2,d1
	moveq	#0,d0
gp1:
	move.w	(a0)+,d2
	btst	d1,d2
	beq.s	gp2
	or.w	#1,d0
gp2:
	move.w	(a0)+,d2
	btst	d1,d2
	beq.s	gp3
	or.w	#2,d0
gp3:
	move.w	(a0)+,d2
	btst	d1,d2
	beq.s	gp4
	or.w	#4,d0
gp4:
	move.w	(a0)+,d2
	btst	d1,d2
	beq.s	gp5
	or.w	#8,d0
gp5:
	move.w	d0,color
	movem.l	(sp)+,d0-d5/a0-a1
	rts

**********************************************
putpoint:
	movem.l d0-d5/a0-a1,-(sp)
	move.w	pixelx,d0
	cmp.w	#cxmax,d0
	bgt	pltxit
	cmpi.w	#cxmin,d0
	blt	pltxit
	move.w	d0,d3
	andi.w	#15,d3
	move.w	pixely,d1
	cmp.w	#cymax,d1
	bgt	pltxit
	cmpi.w	#cymin,d1
	blt	pltxit
	lsl.w	#2,d1
	move.w	color,d2

	lsr.w	#1,d0
	and.w	#$00f8,d0
	move.w	d0,a0
	lea	ytable1,a1
	adda.l	(a1,d1.w),a0

	move.w #$8000,d4
	lsr.w d3,d4
	move.l #$80008000,d5
	lsr.l d3,d5
	eor.l #$ffffffff,d5
******************************
*    Turn off old pixel!     *
******************************
myphere:
	and.l d5,(a0)	     ;turn off old pixel
	and.l d5,4(a0)	     ;(both longwords)

******************************
* Now turn on the new pixel! *
******************************
	btst #0,d2
	beq bit2
	or.w d4,(a0)
bit2:
	btst #1,d2
	beq bit4
	or.w d4,2(a0)
bit4:
	btst #2,d2
	beq bit8
	or.w d4,4(a0)
bit8:
	btst #3,d2
	beq pltxit
	or.w d4,6(a0)
pltxit:
	movem.l (sp)+,d0-d5/a0-a1
	rts



rvsave:	dc.l	0
resave:	dc.l	0
	even
savesup:	dc.l	0
ressave:	dc.w	0
filename:	dc.l	0
greypalette:
;Palette of ANDROID.NEO: Saved by NEOchrome V2.20 by Chaos, Inc.
		dc.w	$0217,$0777,$0667,$0557,$0447,$0336,$0225,$0114
		dc.w	$0003,$0077,$0106,$0005,$0004,$0323,$0212,$0000


save_usp:
	dc.l	0
wfnc:
	dc.w	0
save_stk:
	dc.l	0
pointer:	dc.l	0
pixelx:		dc.l	0
pixely:		dc.l	0
color:	dc.w	15
flip:	dc.w	0
flip2:	dc.w	0
seen:	dc.l	0
hiden:	dc.l	0
clrbuffseen:	dc.l	0
clrbuffhiden:	dc.l	0
screen:	dc.l	0
	ds.w	16
pic:
	incbin	'copyb2.img'

*	section	bss
x1:	ds.w	1
y1:	ds.w	1
x2:	ds.w	1
y2:	ds.w	1

number:	ds.w	1
palsave:
	ds.w	16
vblslot:	ds.l	1
d7emulator:	ds.w	1
ytable1:	ds.w	400
growthfactorx:	ds.w	1
growthfactory:	ds.w	1
width:		ds.w	1
height:		ds.w	1
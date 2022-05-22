* 3D depth cued dotty objects by The Phantom of Electronic Images.
*
* Now much faster due to the angle lookups being performed only 3 times
* per frame!
*
* Now D2 is added to a4 for speed and horizon moved down to 286 making
* objects bigger.
*
* Screenswop in main code so just in case it goes over a frame it doesn't
* miss erasing some dotz!
*
* Now using Griff's trig tables (sliiiightly smoother).
*

demo	equ 	0

scx	equ	159		* Screen center X.
scy	equ	99-10		* Screen center Y.

	ifeq demo
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp		* Set supervisor mode.
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	#0,$ffff8260.w		* Low resolution pleez!
	endc

	move.w	#$2700,sr		* Off with all interrupts.
	move.l sp,oldsp
	lea stack,sp
	lea	pal(pc),a0
	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	moveq.l	#1,d0
	bsr	mus
	
	lea	xoff,a0
	moveq.l	#0,d0
	move.w	#$f,d3
	move.w	#320-1,d7		* Set up some variables.
	
cxs:	move.w	d0,d1			* Get X coordinate for offset.
	move.w	d0,d2			* get X coordinate for shift.
	and.b	#%11110000,d1		* Mask out naughty bits.
	lsr.w	#1,d1			* And get chunk address.
	move.w	d1,(a0)+		* Store screen offset.
	
	and.w	d3,d2			* Get shift count.
	add.w	d2,d2			* Word access.
	lea	omasks(pc),a1		* Get mask table address.
	move.w	0(a1,d2.w),d1		* Get point data.
	move.w	d1,(a0)+		* Save it.
	
	addq.w	#1,d0
	dbra	d7,cxs			* Do for 20 chunks.

	move.l	a0,scrnpos
	move.l	a0,d0
	add.w	#256,d0
	move.b	#0,d0
	move.l	d0,scrnpos
	add.l	#32000,d0
	move.l	d0,scrn2

	move.b	$fffa07,sa1
	move.b	$fffa09,sa2
	move.b	$fffa13,sa3
	move.b	$fffa19,sa4
	move.b	$fffa1f,sa5
	move.b	$fffa21,sa6
	move.b	$fffa1b,sa7		* Save necessary MFP regs.
	move.b	$fffa15,sa8
	move.b	$fffa1d,sa9
	move.b	$fffa25,sa10
	move.b	#0,$fffa07
	move.b	#0,$fffa09		* Throw out everything!
	
	bclr.b	#3,$fffa17		* Software End Of Interrupt mode.

	lea	text(pc),a5
	move.w	#6,savd0
	clr.l	d0
	move.b	(a5)+,d0
	sub.b	#32,d0
	lsl.w	#3,d0
	move.w	d0,savoff

	move.l	$70.w,oldvbl		* Save old VBL.
	move.l	#vbl,$70.w		* Install my VBL.

	clr.b	$fffffa1b.w
	move.l	$120.w,oldhbl
	move.l	#hbl,$120.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w

	move.w	#$2300,sr

	move.l	scrnpos(pc),a0
	move.w	#4000-1,d0
clean:	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbra	d0,clean		* Clear screen.
	
	lea	sintab(pc),a6
	moveq.w	#6,d2
	
key:	

*	move.w	#$700,$ffff8240.w	* To see how much time it takes...

	tst.b	flip
	bne.s	poo
	move.b	#1,flip
	bra.s	scour
poo:	move.b	#0,flip
	
scour:	moveq.l	#0,d0
	move.l	d0,d1			* Clear registers.
	move.l	scrnpos(pc),a0		* Initialise screen address.
	tst.b	flip
	bne.s	oh2
	bsr	clrrts			* Execute point clear routines.
	bra.s	goon
oh2:	bsr	clrrts2
	
goon:	
	tst.b	flip
	beq.s	seccy
	lea	clrrts2+4(pc),a2	* To save LEA'ing.
	bra.s	pand
seccy:	lea	clrrts+4(pc),a2		* To save LEA'ing.
pand:	
	movem.w	incx(pc),d5-d7
	add.w	d5,xang
	add.w	d6,yang
	add.w	d7,zang

	lea	newcs(pc),a0
	move.l	coff(pc),a1
	move.l	(a1),a1
	addq.l	#2,a1
	rept	112
	move.l	(a1)+,(a0)+
	endr
	move.w	(a1)+,(a0)+

	move.l	coff(pc),a1
	move.l	(a1),a1
	lea	newcs(pc),a4
	move.w	(a1)+,d7
	bsr	rotx		* Rotate X
	move.l	coff(pc),a1
	move.l	(a1),a1
	lea	newcs(pc),a4
	move.w	(a1)+,d7
	bsr	roty		* Rotate Y
	move.l	coff(pc),a1
	move.l	(a1),a1
	lea	newcs(pc),a4
	move.w	(a1)+,d7
	bsr	rotz		* Rotate Z
	
	move.l	coff(pc),a1
	move.l	(a1),a1
	lea	newcs(pc),a4
	move.w	(a1)+,d7
	bsr	perspec		* Do perspective


	move.l	coff(pc),a1
	move.l	(a1),a1
	move.w	(a1)+,d7
	lea	newcs(pc),a4

nexp:	
	move.l	scrnpos(pc),a0		* Get screen address (tee-hee!).
	move.w	2(a4),d6		* Get Y coordinate.
yad:	add.w	#scy,d6
	blt.s	next
nozr:	cmpi.w	#199-10,d6
	bgt.s	next			* Off screen bottom?
	lea	yoffs(pc),a3
	add.w	d6,d6
	move.w	(a3,d6.w),d6
	move.w	(a4),d4			* Get X coordinate.
xad:	add.w	#scx,d4
	blt.s	next
	cmpi.w	#319,d4			* Off screen left?
	bgt.s	next
	lea	xoff(pc),a3		* Get X address of offsets/data.
	add.w	d4,d4
	add.w	d4,d4			* Long access.
	adda.w	d4,a3			* Add to table address.
	add.w	(a3),d6			* Add to total screen offset.
	adda.w	d6,a0			* Now add it to screenbase.
	move.w	d6,(a2)			* Self modify clear routines.
	addq.w	#6,a2			* Increase pointer to clr routs.
	move.w	2(a3),d0		* Get point data.
	move.w	d0,d1			* And store it to D1.
	not.w	d1			* Inverse mask it.
cue:	move.w	4(a4),d3		* Get cue coordinate.
* Depth cue section.
	ext.l	d3			* DIVS needs 32 bitz.
side:	divs	#200,d3			* Divide by 11.
	addq.w	#8,d3			* And make negs positive!
	bgt.s	t15
	moveq.w	#1,d3
	bra.s	docols

* Replacing AND.W #$f,d3
t15:	cmpi.w	#15,d3
	ble.s	docols
	moveq.w	#15,d3

docols:	lea	prouts(pc),a3		* Nab point plot routs taddress.
	lsl.w	#4,d3			* 16 bytes per routine.
	jsr	(a3,d3.w)		* Execute point routine.
	
	
next:	add.w	d2,a4
	dbra	d7,nexp

*	move.w	#$000,$ffff8240.w

	tst.b	pego
	bne.s	cum
	tst.b	member
	bne.s	offit
	tst.b	arun
	beq	outvb
	addq.w	#1,frcount
	cmpi.w	#50*10,frcount
	bne	outvb
	move.b	#1,member

offit:	cmpi.w	#-600,clit+2
	ble.s	lick
	sub.w	#40,clit+2
	subq.w	#1,yad+2
	bra	outvb
lick:	move.b	#0,member
	move.b	#1,pego
	move.w	#scy,yad+2
	move.w	#-104,xad+2
	bra.s	outvb
	
cum:	tst.b	once
	bne.s	buttock
	move.b	#1,once
	
	move.l	coff(pc),a0
	addq.l	#4,a0
	cmpi.l	#-99,(a0)
	bne.s	ok
	lea	caddr(pc),a0
ok:	move.l	a0,coff
	bra.s	outvb

buttock:
	cmpi.w	#4672,clit+2
	bge.s	lick2
	add.w	#40,clit+2
	addq.w	#2,xad+2
	bra.s	outvb
lick2:	move.w	#4672,clit+2
	move.b	#0,pego
	clr.w	frcount
	move.b	#0,once

outvb:



	cmpi.b	#2,$fffffc02.w		* 1 on keyboard.
	bne.s	k2
	move.l	#pal,pptr
k2:	cmpi.b	#3,$fffffc02.w		* 2 on keyboard.
	bne.s	k3
	move.l	#pal2,pptr
k3:	cmpi.b	#4,$fffffc02.w		* 3 on keyboard.
	bne.s	k4
	move.l	#pal3,pptr
k4:	cmpi.b	#5,$fffffc02.w		* 4 on keyboard
	bne.s	xmin
	move.l	#pal4,pptr
xmin:	subq.b	#1,kcount
	bne	help
	move.b	#5,kcount
	cmpi.b	#$0f,$fffffc02.w	* Tab
	bne.s	ooh
	neg.w	side+2
ooh:	cmpi.b	#$4b,$fffffc02.w	* Left cursor key.
	bne.s	xmax
	cmpi.w	#-20,incx
	beq	space
	subq.w	#1,incx
xmax:	cmpi.b	#$4d,$fffffc02.w	* Right cursor key.
	bne.s	ymax
	cmpi.w	#20,incx
	beq	space
	addq.w	#1,incx
ymax:	cmpi.b	#$48,$fffffc02.w	* Up cursor key.
	bne.s	ymin
	cmpi.w	#20,incy
	beq	space
	addq.w	#1,incy
ymin:	cmpi.b	#$50,$fffffc02.w	* Down cursor key.
	bne.s	zmin
	cmpi.w	#-20,incy
	beq	space
	subq.w	#1,incy
zmin:	cmpi.b	#$52,$fffffc02.w	* Insert key.
	bne.s	zmax
	cmpi.w	#-20,incz
	beq	space
	subq.w	#1,incz
zmax:	cmpi.b	#$47,$fffffc02.w	* CLR Home key.
	bne.s	objp
	cmpi.w	#20,incz
	beq	space
	addq.w	#1,incz
objp:	tst.b	arun
	bne.s	help
	cmpi.b	#$4e,$fffffc02.w	* Plus key (numeric keypad)
	bne.s	objm
	move.l	coff(pc),a0
	addq.l	#4,a0
	cmpi.l	#-99,(a0)
	bne.s	okp
	lea	caddr(pc),a0
okp:	move.l	a0,coff	
objm:	cmpi.b	#$4a,$fffffc02.w	* Minus key (numeric keypad)
	bne.s	help
	move.l	coff(pc),a0
	subq.l	#4,a0
	cmpi.l	#-66,(a0)
	bne.s	okm
	lea	caddr+((cend-caddr)-4)(pc),a0
okm:	move.l	a0,coff

help:	cmpi.b	#$62,$fffffc02.w	* Help key.
	bne.s	undo
	move.w	#5,incx
	move.w	#7,incy
	move.w	#5,incz
	move.w	#4,cue+2
	move.w	#200,side+2
	move.w	#0,z1+2
	move.l	#pal,pptr
	move.b	#1,arun
	clr.w	frcount
undo:	cmpi.b	#$61,$fffffc02.w	* Undo key.
	bne.s	escape
	clr.w	incx
	clr.w	incy
	clr.w	incz
escape:	cmpi.b	#1,$fffffc02.w		* Escape key
	bne.s	cuez
	clr.b	arun
cuez:	cmpi.b	#$6d,$fffffc02.w
	bne.s	cuey
	move.w	#4,cue+2
	move.w	#200,side+2
cuey:	cmpi.b	#$6e,$fffffc02.w
	bne.s	cuex
	move.w	#2,cue+2
	move.w	#15,side+2
cuex:	cmpi.b	#$6f,$fffffc02.w
	bne.s	iz
	move.w	#0,cue+2
	move.w	#22,side+2
iz:	cmpi.b	#$63,$fffffc02.w	* Right bracket (keypad) Zoom in.
	bne.s	dz
	cmpi.w	#2000,z1+2
	bge.s	dz
	addq.w	#7,z1+2
dz:	cmpi.b	#$64,$fffffc02.w	* And left bracket (zoom out).
	bne.s	space
	cmpi.w	#-2000,z1+2
	ble.s	space
	subq.w	#7,z1+2
	
space:	move.b	scrnpos+1(pc),$ffff8201.w
	move.b	scrnpos+2(pc),$ffff8203.w
	move.l	scrnpos(pc),-(sp)
	move.l	scrn2,scrnpos
	move.l	(sp)+,scrn2

	move.b	lcount(pc),d0
sync:	cmp.b	lcount(pc),d0
	beq.s	sync			* Wait for beam flyback.

*	move.w	#$0,$ffff8240.w

	cmpi.b	#57,$fffffc02.w
	bne	key			* Repeat if spacebar not pressed.
	
	
flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done					* Flush keyboard.

	move.w	#$2700,sr
	move.b	sa1(pc),$fffa07
	move.b	sa2(pc),$fffa09
	move.b	sa3(pc),$fffa13
	move.b	sa4(pc),$fffa19
	move.b	sa5(pc),$fffa1f
	move.b	sa6(pc),$fffa21
	move.b	sa7(pc),$fffa1b
	move.b	sa8(pc),$fffa15
	move.b	sa9(pc),$fffa1d
	move.b	sa10(pc),$fffa25
	move.l	oldvbl(pc),$70.w	* Re-install old VBL.
	move.l	oldhbl(pc),$120.w
	move.w	#$2300,sr
	
	clr.l	d0
	bsr	mus
	ifeq demo
	move.w	#$777,$ffff8240.w
	move.w	#$000,$ffff8242.w
	move.w	#$000,$ffff8244.w	
	move.w	#$000,$ffff8246.w	* Set colours to 'normal'.
	MOVE.B #7,$FFFF8800.W
	MOVE.B #-1,$FFFF8802.W
	clr.w	-(sp)
	trap	#1			* ... Terminate program.
	endc
	move.l oldsp,sp
	rts
	
vbl:	addq.b	#1,lcount		* Signal flyback has occured.
	bsr	mus+6

	clr.b	$fffffa1b.w
	move.b	#190,$fffffa21.w
	move.b	#8,$fffffa1b.w

	movem.l	a0-a1/d0-d1,-(sp)

	move.l	pptr(pc),a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr

	move.l	scrnpos(pc),a0
	adda.w	#30720+152,a0
	moveq.w	#8-1,d0
scroll:	
	lsl.w	(a0)
jobb	set	-8
	rept	19
	roxl.w	jobb(a0)
jobb	set	jobb-8
	endr
	lea	160(a0),a0
	dbra	d0,scroll

	move.l	scrnpos(pc),a0
	adda.w	#30720+152,a0
	moveq.w	#8-1,d0
scroll2:	
	lsl.w	(a0)
jobb	set	-8
	rept	19
	roxl.w	jobb(a0)
jobb	set	jobb-8
	endr
	lea	160(a0),a0
	dbra	d0,scroll2

	move.l	scrnpos(pc),a0
	adda.w	#30720+153,a0
	move.w	savd0(pc),d0
	lea	chars(pc),a1
	adda.w	savoff(pc),a1
scoff	set	0
	rept	8
	move.b	(a1)+,d1
	lsr.w	d0,d1
	and.b	#%00000011,d1
	or.b	d1,scoff(a0)
scoff	set	scoff+160
	endr
	
	subq.w	#2,d0
	
	bpl.s	nonxt

	move.w	#6,savd0
	tst.b	(a5)
	bne.s	noend
	lea	text(pc),a5
noend:	clr.l	d0
	move.b	(a5)+,d0
	sub.b	#32,d0
	lsl.w	#3,d0
	move.w	d0,savoff
	moveq.w	#6,d0
	
nonxt:	move.w	d0,savd0
	
	move.l	scrnpos(pc),a0
	move.l	scrn2(pc),a1
	adda.w	#30720,a0
	adda.w	#30720,a1
jobb	set	0
	rept	160
	move.w	jobb(a0),jobb(a1)
jobb	set	jobb+8
	endr
	movem.l	(sp)+,a0-a1/d0-d1
	
	rte

hbl:	move.w	#$724,$ffff8242.w
	clr.b	$fffffa1b.w
	rte


* Routine to rotate X,Y,Z around the X axis by angle in XANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

rotx:	move.l	a6,a0
	move.w	xang(pc),d0
	and.w	#1023,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1		* Sin into D1
	add.w	#512,d0
	move.w	(a0,d0.w),d0		* Cos into D0
fxang:	move.w	2(a4),d3		* Get Y
	move.w	4(a4),d4		* Get Z
	move.w	d3,d5			* Store Y
	move.w	d4,d6			* Store Z
	muls	d0,d3			* Y * Cos
	muls	d1,d4			* Z * Sin
	add.l	d3,d4			* Y=Y*Cos+Z*Sin
	add.l	d4,d4
	swap	d4			* Shrink so we can see!
	muls	d0,d6			* Z * Cos
	muls	d1,d5			* Y * Sin
	sub.l	d5,d6			* Z=Z*Cos-Y*Sin
	add.l	d6,d6
	swap	d6			* Shrink so we can see!
	move.w	d4,2(a4)		* Store new Y.
	move.w	d6,4(a4)		* Store new Z.
	add.w	d2,a4
	dbra	d7,fxang
	rts

* Routine to rotate X,Y,Z around the Y axis by angle in XANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

roty:	move.l	a6,a0
	move.w	yang(pc),d0
	and.w	#1023,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1		* Sin into D1
	add.w	#512,d0
	move.w	(a0,d0.w),d0		* Cos into D0
fyang:	move.w	(a4),d3			* Get X
	move.w	4(a4),d4		* Get Z
	move.w	d3,d5			* Store X
	move.w	d4,d6			* Store Z
	muls	d0,d3			* X * Cos
	muls	d1,d4			* Z * Sin
	sub.l	d3,d4			* X=X*Cos-Z*Sin
	add.l	d4,d4
	swap	d4			* Shrink so we can see!
	muls	d1,d5			* X * Sin
	muls	d0,d6			* Z * Cos
	add.l	d5,d6			* Z=Z*Cos+X*Sin
	add.l	d6,d6
	swap	d6			* Shrink so we can see!
	move.w	d4,(a4)			* Store new X.
	move.w	d6,4(a4)		* Store new Z.
	add.w	d2,a4
	dbra	d7,fyang
	rts

* Routine to rotate X,Y,Z around the Z axis by angle in ZANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

rotz:	move.l	a6,a0
	move.w	zang(pc),d0
	and.w	#1023,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1		* Sin into D1
	add.w	#512,d0
	move.w	(a0,d0.w),d0		* Cos into D0
fzang:	move.w	(a4),d3			* Get X
	move.w	2(a4),d4		* Get Y
	move.w	d3,d5			* Store X
	move.w	d4,d6			* Store Y
	muls	d0,d3			* X * Cos
	muls	d1,d4			* Y * Sin
	sub.l	d3,d4			* X=X*Cos-Y*Sin
	add.l	d4,d4
	swap	d4			* Shrink so we can see!
	muls	d1,d5			* X * Sin
	muls	d0,d6			* Y * Cos
	add.l	d6,d5			* Y=Y*Cos+X*Sin
	add.l	d5,d5
	swap	d5 			* Shrink so we can see!
	move.w	d4,(a4)			* Store new X.
	move.w	d5,2(a4)		* Store new Y.
	add.w	d2,a4
	dbra	d7,fzang
	rts


perspec:
*horizon	equ     4800                ; perspective horizon distance
pespp:  
	move.w	(a4),d0
        move.w	2(a4),d1
clit:   move.w  #4672,d3
z1:	add.w	#0,4(a4)
        sub.w   4(a4),d3               ; d3 = persp - (distance away) D2=Z (new)
        muls    d3,d0		; D0=X
        swap	d0               ; re-scale x (divide by horizon)
        muls    d3,d1		; D1=Y
        swap	d1               ; re-scale y
	
	move.w	d0,(a4)
	move.w	d1,2(a4)
	add.w	d2,a4
	dbra	d7,pespp
	rts

	
oldsp:	ds.l	1			* Space for old stack address.
oldvbl:	ds.l	1			* Space for old VBL address.
oldhbl:	ds.l	1

savd0:	ds.w	1
savoff:	ds.w	1

lcount:	ds.w	1			* Space for beam flyback signal.

scrnpos:ds.l	1			* Screen position (crafty place!).
scrn2:	ds.l	1

frcount:dc.w	0

	dc.l	-66
caddr:	dc.l	cylind,cords,penuuu,cube,circ,ei,cross,smiley,triang,box,man
	dc.l	zoob,stairs,sphere,cummel,arrow,spiral,star,sphere2
	dc.l	cum1,flat,cum2,cum3,cum5,krypton
cend:
	dc.l	-99
coff:	dc.l	caddr

cords:	dc.w	46-1
	dc.w	0,80*17,0
	dc.w	0,70*17,0
	dc.w	0,60*17,0
	dc.w	0,50*17,0
	dc.w	0,40*17,0
	dc.w	0,30*17,0
	dc.w	0,20*17,0
	dc.w	0,10*17,0
	dc.w	0,0,0
	dc.w	0,-10*17,0
	dc.w	0,-20*17,0
	dc.w	0,-30*17,0
	dc.w	0,-40*17,0
	dc.w	0,-50*17,0
	dc.w	0,-60*17,0
	dc.w	0,-70*17,0
	dc.w	0,-80*17,0
	dc.w	-10*17,70*17,0
	dc.w	-20*17,60*17,0
	dc.w	-30*17,50*17,0
	dc.w	-40*17,40*17,0
	dc.w	-50*17,30*17,0
	dc.w	-60*17,20*17,0
	dc.w	10*17,70*17,0
	dc.w	20*17,60*17,0
	dc.w	30*17,50*17,0
	dc.w	40*17,40*17,0
	dc.w	50*17,30*17,0
	dc.w	60*17,20*17,0

	dc.w	-80*17,-80*17,30*17
	dc.w	-70*17,-80*17,30*17
	dc.w	-60*17,-80*17,30*17
	dc.w	-50*17,-80*17,30*17
	dc.w	-40*17,-80*17,30*17
	dc.w	-30*17,-80*17,30*17
	dc.w	-20*17,-80*17,30*17
	dc.w	-10*17,-80*17,30*17
	dc.w	0,-80*17,30*17
	dc.w	10*17,-80*17,30*17
	dc.w	20*17,-80*17,30*17
	dc.w	30*17,-80*17,30*17
	dc.w	40*17,-80*17,30*17
	dc.w	50*17,-80*17,30*17
	dc.w	60*17,-80*17,30*17
	dc.w	70*17,-80*17,30*17
	dc.w	80*17,-80*17,30*17

circ:	dc.w	70-1
	incbin	testcirc.dat
cube:	dc.w	64-1
	incbin	cube.dat
ei:	dc.w	70-1
	incbin	ei.dat
cross:	dc.w	70-1
	incbin	cross.dat
smiley:	dc.w	71-1
	incbin	smiley.dat
triang:	dc.w	70-1
	incbin	triang.dat
box:	dc.w	70-1
	incbin	box.dat
man:	dc.w	70-1
	incbin	man.dat
stairs:	dc.w	70-1
	incbin	stairs.dat
arrow:	dc.w	70-1
	incbin	arrow.dat
spiral:	dc.w	70-1
	incbin	spiral.dat
star:	dc.w	70-1
	incbin	star.dat
sphere:	dc.w	75-1
	incbin	sphere.dat
sphere2:dc.w	75-1
	incbin	sphere2.dat
penuuu:	dc.w	75-1
	incbin	penuuu.dat
zoob:	dc.w	75-1
	incbin	zoob.dat
cum1:	dc.w	75-1
	incbin	cum1.dat
cum2:	dc.w	75-1
	incbin	cum2.dat
cum3:	dc.w	75-1
	incbin	cum3.dat
cum5:	dc.w	64-1
	incbin	cum5.dat
krypton:dc.w	72-1
	incbin	krypton.dat
cummel:	dc.w	72-1
	incbin	cummel.dat
cylind:	dc.w	75-1
	incbin	cylinder.dat
flat:	dc.w	64-1
	incbin	flat.dat

chars:	incbin	8font.dat

mus:	incbin	3d_dots.czi

newcs:	ds.w	3*75		* Space for 3 coordinates (X Y Z).
	
xang:	dc.w	0
yang:	dc.w	0
zang:	dc.w	0

incx:	dc.w	4
incy:	dc.w	6
incz:	dc.w	5

colour:	dc.w	1

omasks:	dc.w	%1000000000000000	* Actual point data.
	dc.w	%0100000000000000
	dc.w	%0010000000000000
	dc.w	%0001000000000000
	dc.w	%0000100000000000
	dc.w	%0000010000000000
	dc.w	%0000001000000000
	dc.w	%0000000100000000
	dc.w	%0000000010000000
	dc.w	%0000000001000000
	dc.w	%0000000000100000
	dc.w	%0000000000010000
	dc.w	%0000000000001000
	dc.w	%0000000000000100
	dc.w	%0000000000000010
	dc.w	%0000000000000001

	
******* Routines for plotting the points. D1 contains the inverse mask,
******* and D0 contains the mask proper for the point.
******* Starts from colour 0 to colour 15.

******* Each routine is 10 bytes long. 4 PLANES, remember!
	
prouts:
col0:	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts				* Colour 0.
	dc.l	0
	dc.w	0			* Force each routine to 16 bytes.
col1:	or.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts				* Colour 1.
	dc.l	0
	dc.w	0
col2:	and.w	d1,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts				* Colour 2.
	dc.l	0
	dc.w	0
col3:	or.w	d0,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts				* Colour 3.
	dc.l	0
	dc.w	0
col4:	and.w	d1,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)
	rts				* Colour 4.
	dc.l	0
	dc.w	0
col5:	or.w	d0,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)
	rts				* Colour 5.
	dc.l	0
	dc.w	0
col6:	and.w	d1,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)
	rts				* Colour 6.
	dc.l	0
	dc.w	0
col7:	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)
	rts				* Colour 7.
	dc.l	0
	dc.w	0
col8:	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)
	rts				* Colour 8.
	dc.l	0
	dc.w	0
col9:	or.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)
	rts				* Colour 9.
	dc.l	0
	dc.w	0
col10:	and.w	d1,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)
	rts				* Colour 10.
	dc.l	0
	dc.w	0
col11:	or.w	d0,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)
	rts				* Colour 11.
	dc.l	0
	dc.w	0
col12:	and.w	d1,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts				* Colour 12.
	dc.l	0
	dc.w	0
col13:	or.w	d0,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts				* Colour 13.
	dc.l	0
	dc.w	0
col14:	and.w	d1,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts				* Colour 14.
	dc.l	0
	dc.w	0
col15:	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts				* Colour 15.

clrrts:	rept	75
	movem.l	d0-d1,0(a0)
	endr
	rts

clrrts2:rept	75
	movem.l	d0-d1,0(a0)
	endr
	rts


pptr:	dc.l	pal

pal:	dc.w	$000,$177,$077,$067,$057,$047,$037,$027
	dc.w	$017,$007,$006,$005,$004,$003,$002,$001

pal2:	dc.w	$000,$777,$777,$767,$757,$747,$737,$727
	dc.w	$717,$707,$606,$505,$404,$303,$202,$101

pal3:	dc.w	$000,$177,$077,$076,$075,$074,$073,$072
	dc.w	$071,$070,$060,$050,$040,$030,$020,$010
	
pal4:	dc.w	$000,$771,$770,$760,$750,$740,$730,$720
	dc.w	$710,$700,$600,$500,$400,$300,$200,$100

		ds.l 99
stack		ds.l 1 

sintab		dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 
		dc.w	$7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0 
		dc.w	$7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74 
		dc.w	$7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9 
		dc.w	$7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0 
		dc.w	$7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59 
		dc.w	$7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5 
		dc.w	$7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6 
		dc.w	$7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D 
		dc.w	$7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A 
		dc.w	$73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140 
		dc.w	$70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30 
		dc.w	$6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB 
		dc.w	$6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745 
		dc.w	$66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370 
		dc.w	$62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D 
		dc.w	$5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F 
		dc.w	$5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689 
		dc.w	$55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE 
		dc.w	$5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0 
		dc.w	$4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3 
		dc.w	$471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279 
		dc.w	$41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07 
		dc.w	$3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F 
		dc.w	$36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4 
		dc.w	$30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB 
		dc.w	$2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7 
		dc.w	$2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC 
		dc.w	$1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD 
		dc.w	$18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E 
		dc.w	$12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53 
		dc.w	$0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710 
		dc.w	$0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$00C9 
		dc.w	$0000,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82 
		dc.w	$F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D 
		dc.w	$F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00 
		dc.w	$ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD 
		dc.w	$E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA 
		dc.w	$E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99 
		dc.w	$DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F 
		dc.w	$D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF 
		dc.w	$CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD 
		dc.w	$C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C 
		dc.w	$C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0 
		dc.w	$BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C 
		dc.w	$B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463 
		dc.w	$B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69 
		dc.w	$AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1 
		dc.w	$AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D 
		dc.w	$A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1 
		dc.w	$A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F 
		dc.w	$9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA 
		dc.w	$9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604 
		dc.w	$9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F 
		dc.w	$9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E 
		dc.w	$8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2 
		dc.w	$8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D 
		dc.w	$89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1 
		dc.w	$877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF 
		dc.w	$8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409 
		dc.w	$83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F 
		dc.w	$8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182 
		dc.w	$8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4 
		dc.w	$809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033 
		dc.w	$8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002 
		dc.w	$8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020 
		dc.w	$8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C 
		dc.w	$809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147 
		dc.w	$8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250 
		dc.w	$8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7 
		dc.w	$83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B 
		dc.w	$8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A 
		dc.w	$877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973 
		dc.w	$89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6 
		dc.w	$8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0 
		dc.w	$8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0 
		dc.w	$9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525 
		dc.w	$9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB 
		dc.w	$9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90 
		dc.w	$9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3 
		dc.w	$A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1 
		dc.w	$A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977 
		dc.w	$AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32 
		dc.w	$AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320 
		dc.w	$B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D 
		dc.w	$B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87 
		dc.w	$BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9 
		dc.w	$C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891 
		dc.w	$C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C 
		dc.w	$CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425 
		dc.w	$D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19 
		dc.w	$DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024 
		dc.w	$E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643 
		dc.w	$E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72 
		dc.w	$ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD 
		dc.w	$F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0 
		dc.w	$F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37 
		dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 

text:	dc.b	' If you think this is all,boy you''re so wrong...                                           FUCK OFF YA BASTARD!       Furk orf.  Fekk oerf.       Bloody hell if you expect one of those big headed ''we are little shits'' scrolltexts '
	dc.b	'then go look at the Mind Bum demo by The Lousy Boys.      Oh,before anything,I must thank Russel Payne for getting me started in 3D and all those hints & tips plus Griff for suggesting the expansion of objects so they''d be smoother. '
	dc.b	'   Rite...  Now did you know this demo was controllable?  No?  Neither did I coz this is all ripped code and...      Oh,sorry about that,I thought I was Manikin.       Rite...  Keys are...  Keys 1 to 4 on the keyboard change palettes '
	dc.b	'for the objects.  Keys 1-3 on the keypad (keyPAD!) change the light source from front,top and side respectively.  The TAB key will invert the light source point (so if you have pressed 2 on the keypad and then you press TAB then the '
	dc.b	'light source will change from left to right and vice (chains) versa)    The bracket ( ) keys on the keypad will zoom in and out ''('' bracket for zoom out and the other for in. (Sounds like sex this though I wouldn''t know!)   '
	dc.b	'More!!  The Insert and Clr home keys decrease and increase the Z rotation respectively.  The same for both sets of arrow keys: up & down for Y and left and right for X.  Hitting the UNDO key will stop all rotations,and at any point '
	dc.b	'pressing (or hitting depending if you''re into sado-masochism) the HELP key will restore everything back to normal (and a happy ending when Dorothy gets banged by the Tin Man and gang banged by a pack of schoolchildren)...   You can '
	dc.b	'also step through the objects yourself by using the plus and minus keys (+- for those absolute bastards who think I don''t have a full character set so NAAAAAAAAAAH!) to increase/decrease the object number... Although you have to press '
	dc.b	'the ESCape key first to tell me ole proggy to stop cycling through the objects itself!  As I said,to get it all back to normal just hit the ESCape key.    And now,breasts.   Rite nice old pair they are eh?  I don''t mean the Lost Boys '
	dc.b	'cos they''re tits not breasts (hmm...  How can tits be arseholes too?) and I like the ones with the pointy walnuts on the end and firmola city...  I have been told that the firm ones smell of carnation milk (and taste the same?)...  '
	dc.b	'Well I don''t really know about this (sob and Mr.Limp) so if any gals out there wanna show me otherwise I''ll only be too pleased to smell their breasts!!!!   Umm... And maybe even have sex! What ho? I don''t charge much but I do run! '
	dc.b	'HAHAHAHA  CHARGE!  RUN!  HAHAHAA! Well fuck you if you don''t get it (coz I don''t either) (so fuck me anyone) so I must say now that during the development of this screen I have compiled (well memorised) a list of how many things I '
	dc.b	'have done...  (Well you get all this in demos like how much they''ve consumed)  So here''s my alternative list.  During this demoscreen I have had:   11002 wanks.   11001 orgasms.   342 arrests.   65 convictions.   29 offers of sex '
	dc.b	'with mutton.   50 spankings by Gizmo.   88 accidental treadings on shit.   1 deliberate tread on shit.   2 almost-caught-wanking-encounters.   0 sex encounters.   74838236 extremely pornographic dreams.   74 hard-ons while in motion.   '
	dc.b	'1 piss up.   0 vomits. (hah!) (shoulda seen Gizmo and Master!!!)   84736 Y-front removals.   4 soiled slips.   2 shits.   16 pisses.   5000000 sexual innuendos and insults.   8 pole vaults.   23 marathon runs and a quickie down Le-Mans.'
	dc.b	'   And I guess that''s all I did...  *sigh*    Oh,well mite as well wrap now and watch Master bash some poor seal''s heads in (with Griff,Count Zero and Gizmo bloodthirstily watching) with a very large club.     Club...  Reminds me of '
	dc.b	'me dear pego...    Oohhh!    Ok...   Oh fucking hell now he tells me!!  Music by Count (CUNT!) Zero!  (Fuk orf U fukin'' bustud..... back in the old days we used ter drink out of rolled up newspaper so don''t you fukkin insult me ye '
	dc.b	'nipper... just cos you did all this fukin 3d lark and me just the fukin music and a few fukin wurds yer thinks yer can fukin take fukin over (cont for 120 k)  Count...)  Well OK I apologise so you can fuck off now or I''ll tell'
	dc.b	' ''em all about yer ripping exploits!!! Hahahahaha!   Grab him by the balls!!!  (I wish someone did that to me preferably female)   (Ripping bollocks... you should see the 3d code Griff ripped from the ST Squad Batman demo... Count...) '
	dc.b	'Ooh!!  Mudslinging time!!!   Well it''s all lies but mite as well give one truth: The Lost Boys are a bunch of leather-loving-shirt-lifters!   Oohh...  Remember their vectorballs?   Did you know that was Griffs 3D code?  And '
	dc.b	'there''s more!!  If you want proof,we have it as compared listings!!!!!   And not even a mention to Griff eh?  It''s not my business (fuck off the lot ''o ya!) but WHAT A BUNCH OF ARSEHOLES. (Ok just Manikin! The others seem allright) '
	dc.b	'      Ok...  Mite as well wrap but remember: If any of you girls preferably between 18 and 34,good looking and want some hot Spanish meat then you know who to call!  (Me? Who said that!! Waaaaaaaaaah!!!  Mr frustrato here!)    Oh,life '
	dc.b	'is so joyous and so full of variation!  Okeydoke until the next time when the horizon is clear of obstacles and that faraway paradise is a little closer...   Au revoir and enjoy...  The group which doesn''t steal - INNER CIRCLE     '
	dc.b	'Or to quote Birdy (and mangle it a little tho he said he doesn''t mind as long as we give him money in return)   INNER CIRCLE - The real fucking best!!                       ',0
	dc.b	0

yoffs:	even
yoff	set	0
	rept	200
	dc.w	yoff
yoff	set	yoff+160
	endr

kcount:	dc.b	5

arun:	dc.b	1

member:	dc.b	0

pego:	dc.b	0

once:	dc.b	0

flip:	dc.b	0
sa1:	ds.b	1
sa2:	ds.b	1
sa3:	ds.b	1
sa4:	ds.b	1
sa5:	ds.b	1
sa6:	ds.b	1
sa7:	ds.b	1
sa8:	ds.b	1
sa9:	ds.b	1
sa10:	ds.b	1

xoff:	even
	dc.w	0
	dc.w	0
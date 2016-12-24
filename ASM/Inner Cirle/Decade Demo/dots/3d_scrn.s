scx	equ	159		* Screen center X.
scy	equ	99-10		* Screen center Y.

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp		* Set supervisor mode.
	
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	#0,$ffff8260.w		* Low resolution pleez!

	lea	pal(pc),a0
	lea	$ff8240,a1
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

	move.w	#$2700,sr		* Off with all interrupts.
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

	move.l	$70.w,oldvbl		* Save old VBL.
	move.l	#vbl,$70.w		* Install my VBL.
	move.w	#$2300,sr

	move.l	scrnpos(pc),a0
	move.w	#4000-1,d0
clean:	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbra	d0,clean		* Clear screen.
	
	lea	text(pc),a5
	move.w	#6,savd0
	clr.l	d0
	move.b	(a5)+,d0
	sub.b	#32,d0
	lsl.w	#3,d0
	move.w	d0,savoff

	lea	sintab(pc),a6
	moveq.w	#7,d2
	
key:	move.b	lcount(pc),d0
sync:	cmp.b	lcount(pc),d0
	beq.s	sync			* Wait for beam flyback.

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
	move.l	coff(pc),a1
	move.l	(a1),a1
	lea	newcs(pc),a4
	move.w	(a1)+,d7

	addq.w	#1,xang
	addq.w	#2,yang
	addq.w	#1,zang

	move.w	#$ff,d0
	and.w	d0,xang
	and.w	d0,yang
	and.w	d0,zang

nexp:	move.l	(a1)+,(a4)
	move.w	(a1)+,4(a4)

	bsr	rotx			* Rotate coordinate triplets.
	bsr	roty			* Y rotation.
	bsr	rotz			* Z rotation.
	bsr	perspec

	move.l	scrnpos(pc),a0		* Get screen address (tee-hee!).
	move.w	2(a4),d6		* Get Y coordinate.
	add.w	#scy,d6
	blt.s	next
nozr:	cmpi.w	#199-10,d6
	bgt.s	next			* Off screen bottom?
	lea	yoffs(pc),a3
	add.w	d6,d6
	move.w	(a3,d6.w),d6
	move.w	(a4),d4			* Get X coordinate.
	add.w	#scx,d4
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
	move.w	4(a4),d3		* Get Z coordinate.
* Depth cue section.
	ext.l	d3			* DIVS needs 32 bitz.
	divs	#11,d3			* Divide by 11.
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
	
*	addq.w	#1,colour
*	cmpi.w	#15,colour
*	ble.s	next
*	move.w	#1,colour
	
next:	
	dbra	d7,nexp

	addq.w	#1,frcount
	cmpi.w	#50*10,frcount
	bne.s	outvb
	move.l	coff(pc),a0
	addq.l	#4,a0
	cmpi.l	#-99,(a0)
	bne.s	ok
	lea	caddr(pc),a0
ok:	move.l	a0,coff
	clr.w	frcount
outvb:


	
*	move.w	#$000,$ffff8240.w	* End of timing loop (all points).
	
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
	move.w	#$2300,sr
	
	clr.l	d0
	bsr	mus
	
	move.w	#$777,$ffff8240.w
	move.w	#$000,$ffff8242.w
	move.w	#$000,$ffff8244.w	
	move.w	#$000,$ffff8246.w	* Set colours to 'normal'.

	MOVE.B #7,$FFFF8800.W
	MOVE.B #-1,$FFFF8802.W

	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp			* Old stack & mode.
	
	clr.w	-(sp)
	trap	#1			* ... Terminate program.
	
	
vbl:	move.b	scrn2+1(pc),$ffff8201.w
	move.b	scrn2+2(pc),$ffff8203.w
	move.l	scrnpos(pc),-(sp)
	move.l	scrn2,scrnpos
	move.l	(sp)+,scrn2
	addq.b	#1,lcount		* Signal flyback has occured.
	bsr	mus+6

	movem.l	a0-a1/d0-d1,-(sp)
	move.l	scrnpos(pc),a0
	adda.l	#30720+152,a0
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
	adda.l	#30720+152,a0
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
	adda.l	#30720+153,a0
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
	adda.l	#30720,a0
	adda.l	#30720,a1
jobb	set	0
	rept	160
	move.w	jobb(a0),jobb(a1)
jobb	set	jobb+8
	endr
	movem.l	(sp)+,a0-a1/d0-d1

	rte


* Routine to rotate X,Y,Z around the X axis by angle in XANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

rotx:	move.l	a6,a0
	move.w	xang(pc),d0
	move.b	(a0,d0.w),d1		* Sin into D1
	move.b	64(a0,d0.w),d0		* Cos into D0
	ext.w	d0
	ext.w	d1			* Extend to 16 bitz.
	move.w	2(a4),d3		* Get Y
	move.w	4(a4),d4		* Get Z
	move.w	d3,d5			* Store Y
	move.w	d4,d6			* Store Z
	muls	d0,d3			* Y * Cos
	muls	d1,d4			* Z * Sin
	add.w	d3,d4			* Y=Y*Cos+Z*Sin
	asr.w	d2,d4			* Shrink so we can see!
	muls	d0,d6			* Z * Cos
	muls	d1,d5			* Y * Sin
	sub.w	d5,d6			* Z=Z*Cos-Y*Sin
	asr.w	d2,d6			* Shrink so we can see!
	move.w	d4,2(a4)		* Store new Y.
	move.w	d6,4(a4)		* Store new Z.
	rts

* Routine to rotate X,Y,Z around the Y axis by angle in XANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

roty:	move.l	a6,a0
	move.w	yang(pc),d0
	move.b	(a0,d0.w),d1		* Sin into D1
	move.b	64(a0,d0.w),d0		* Cos into D0
	ext.w	d0
	ext.w	d1			* Extend to 16 bitz.
	move.w	(a4),d3			* Get X
	move.w	4(a4),d4		* Get Z
	move.w	d3,d5			* Store X
	move.w	d4,d6			* Store Z
	muls	d0,d3			* X * Cos
	muls	d1,d4			* Z * Sin
	sub.w	d3,d4			* X=X*Cos-Z*Sin
	asr.w	d2,d4			* Shrink so we can see!
	muls	d1,d5			* X * Sin
	muls	d0,d6			* Z * Cos
	add.w	d5,d6			* Z=Z*Cos+X*Sin
	asr.w	d2,d6			* Shrink so we can see!
	move.w	d4,(a4)			* Store new X.
	move.w	d6,4(a4)		* Store new Z.
	rts

* Routine to rotate X,Y,Z around the Z axis by angle in ZANG
* with start of coordinates in A4
* New coordinates put into A4.
* Smashes a0,d0-d6 but NOT D2!!!

rotz:	move.l	a6,a0
	move.w	zang(pc),d0
	move.b	(a0,d0.w),d1		* Sin into D1
	move.b	64(a0,d0.w),d0		* Cos into D0
	ext.w	d0
	ext.w	d1			* Extend to 16 bitz.
	move.w	(a4),d3			* Get X
	move.w	2(a4),d4		* Get Y
	move.w	d3,d5			* Store X
	move.w	d4,d6			* Store Y
	muls	d0,d3			* X * Cos
	muls	d1,d4			* Y * Sin
	sub.w	d3,d4			* X=X*Cos-Y*Sin
	asr.w	d2,d4			* Shrink so we can see!
	muls	d1,d5			* X * Sin
	muls	d0,d6			* Y * Cos
	add.w	d6,d5			* Y=Y*Cos+X*Sin
	asr.w	d2,d5			* Shrink so we can see!
	move.w	d4,(a4)			* Store new X.
	move.w	d5,2(a4)		* Store new Y.
	rts


perspec:
horizon	equ     256                ; perspective horizon distance
        move.w	(a4),d0
        move.w	2(a4),d1
        move.w  #horizon-128,d3
        sub.w   4(a4),d3               ; d3 = persp - (distance away) D2=Z (new)
        muls    d3,d0		; D0=X
        asr.l   d2,d0               ; re-scale x (divide by horizon)
        muls    d3,d1		; D1=Y
        asr.l   d2,d1               ; re-scale y
	
	move.w	d0,(a4)
	move.w	d1,2(a4)
	rts

	
oldsp:	ds.l	1			* Space for old stack address.
oldvbl:	ds.l	1			* Space for old VBL address.

savd0:	ds.w	1
savoff:	ds.w	1

lcount:	ds.w	1			* Space for beam flyback signal.

scrnpos:ds.l	1			* Screen position (crafty place!).
scrn2:	ds.l	1

frcount:dc.w	0

caddr:	dc.l	cords,cube,circ,ei,cross,smiley,triang,box,rhombi,man
	dc.l	stairs,sphere,arrow,spiral,star
	dc.l	-99
coff:	dc.l	caddr

cords:	dc.w	46-1
	dc.w	0,80,0
	dc.w	0,70,0
	dc.w	0,60,0
	dc.w	0,50,0
	dc.w	0,40,0
	dc.w	0,30,0
	dc.w	0,20,0
	dc.w	0,10,0
	dc.w	0,0,0
	dc.w	0,-10,0
	dc.w	0,-20,0
	dc.w	0,-30,0
	dc.w	0,-40,0
	dc.w	0,-50,0
	dc.w	0,-60,0
	dc.w	0,-70,0
	dc.w	0,-80,0
	dc.w	-10,70,0
	dc.w	-20,60,0
	dc.w	-30,50,0
	dc.w	-40,40,0
	dc.w	-50,30,0
	dc.w	-60,20,0
	dc.w	10,70,0
	dc.w	20,60,0
	dc.w	30,50,0
	dc.w	40,40,0
	dc.w	50,30,0
	dc.w	60,20,0

	dc.w	-80,-80,30
	dc.w	-70,-80,30
	dc.w	-60,-80,30
	dc.w	-50,-80,30
	dc.w	-40,-80,30
	dc.w	-30,-80,30
	dc.w	-20,-80,30
	dc.w	-10,-80,30
	dc.w	0,-80,30
	dc.w	10,-80,30
	dc.w	20,-80,30
	dc.w	30,-80,30
	dc.w	40,-80,30
	dc.w	50,-80,30
	dc.w	60,-80,30
	dc.w	70,-80,30
	dc.w	80,-80,30

circ:	dc.w	70-1
	incbin	testcirc.dat
cube:	dc.w	64-1
	incbin	cube.dat
ei:	dc.w	70-1
	incbin	ei.dat
cross:	dc.w	70-1
	incbin	cross.dat
smiley:	dc.w	70-1
	incbin	smiley.dat
triang:	dc.w	70-1
	incbin	triang.dat
box:	dc.w	70-1
	incbin	box.dat
rhombi:	dc.w	70-1
	incbin	rhombi.dat
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
sphere:	dc.w	70-1
	incbin	sphere.dat

chars:	incbin	8font.dat

mus:	incbin	ic_vectr.czi

newcs:	ds.w	3		* Space for 3 coordinates (X Y Z).
	
xang:	dc.w	0
yang:	dc.w	0
zang:	dc.w	0

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

clrrts:	rept	70
	movem.l	d0-d1,0(a0)
	endr
	rts

clrrts2:rept	70
	movem.l	d0-d1,0(a0)
	endr
	rts

pal:	dc.w	$000,$177,$077,$067,$057,$047,$037,$027
	dc.w	$017,$007,$006,$005,$004,$003,$002,$001

sintab:		* (Stolen from metacomco assembler!)

	dc.b      $00,$03,$06,$09,$0C,$0F,$12,$15   ;   0 to   7
	dc.b      $18,$1B,$1E,$21,$24,$27,$2A,$2D   ;   8 to  15
	dc.b      $30,$33,$36,$39,$3B,$3E,$41,$43   ;  16 to  23
	dc.b      $46,$49,$4B,$4E,$50,$52,$55,$57   ;  24 to  31
	dc.b      $59,$5B,$5E,$60,$62,$64,$66,$67   ;  32 to  39
	dc.b      $69,$6B,$6C,$6E,$70,$71,$72,$74   ;  40 to  47
	dc.b      $75,$76,$77,$78,$79,$7A,$7B,$7B   ;  48 to  55
	dc.b      $7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E   ;  56 to  63
	dc.b      $7E,$7E,$7E,$7E,$7E,$7E,$7D,$7D   ;  64 to  71
	dc.b      $7C,$7B,$7B,$7A,$79,$78,$77,$76   ;  72 to  79
	dc.b      $75,$74,$72,$71,$70,$6E,$6C,$6B   ;  80 to  87
	dc.b      $69,$67,$66,$64,$62,$60,$5E,$5B   ;  88 to  95
	dc.b      $59,$57,$55,$52,$50,$4E,$4B,$49   ;  96 to 103
	dc.b      $46,$43,$41,$3E,$3B,$39,$36,$33   ; 104 to 111
	dc.b      $30,$2D,$2A,$27,$24,$21,$1E,$1B   ; 112 to 119
	dc.b      $18,$15,$12,$0F,$0C,$09,$06,$03   ; 120 to 127
	dc.b      $00,$FD,$FA,$F7,$F4,$F1,$EE,$EB   ; 128 to 135
	dc.b      $E8,$E5,$E2,$DF,$DC,$D9,$D6,$D3   ; 136 to 143
	dc.b      $D0,$CD,$CA,$C7,$C5,$C2,$BF,$BD   ; 144 to 151
	dc.b      $BA,$B7,$B5,$B2,$B0,$AE,$AB,$A9   ; 152 to 159
	dc.b      $A7,$A5,$A2,$A0,$9E,$9C,$9A,$99   ; 160 to 167
	dc.b      $97,$95,$94,$92,$90,$8F,$8E,$8C   ; 168 to 175
	dc.b      $8B,$8A,$89,$88,$87,$86,$85,$85   ; 176 to 183
	dc.b      $84,$83,$83,$82,$82,$82,$82,$82   ; 184 to 191
	dc.b      $82,$82,$82,$82,$82,$82,$83,$83   ; 192 to 199
	dc.b      $84,$85,$85,$86,$87,$88,$89,$8A   ; 200 to 207
	dc.b      $8B,$8C,$8E,$8F,$90,$92,$94,$95   ; 208 to 215
	dc.b      $97,$99,$9A,$9C,$9E,$A0,$A2,$A5   ; 216 to 223
	dc.b      $A7,$A9,$AB,$AE,$B0,$B2,$B5,$B7   ; 224 to 231
	dc.b      $BA,$BD,$BF,$C2,$C5,$C7,$CA,$CD   ; 232 to 239
	dc.b      $D0,$D3,$D6,$D9,$DC,$DF,$E2,$E5   ; 240 to 247
	dc.b      $E8,$EB,$EE,$F1,$F4,$F7,$FA,$FD   ; 248 to 255
	dc.b      $00,$03,$06,$09,$0C,$0F,$12,$15   ; 256 to 263
	dc.b      $18,$1B,$1E,$21,$24,$27,$2A,$2D   ; 264 to 271
	dc.b      $30,$33,$36,$39,$3B,$3E,$41,$43   ; 272 to 279
	dc.b      $46,$49,$4B,$4E,$50,$52,$55,$57   ; 280 to 287
	dc.b      $59,$5B,$5E,$60,$62,$64,$66,$67   ; 288 to 295
	dc.b      $69,$6B,$6C,$6E,$70,$71,$72,$74   ; 296 to 303
	dc.b      $75,$76,$77,$78,$79,$7A,$7B,$7B   ; 304 to 311
	dc.b      $7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E   ; 312 to 319

text:	dc.b	'Hullo punters! Tis Phanty poos here with me first ever 3D screen!   Well,sorry for not removing any borders but the 560 multiplies took care of that!  Oh,well.    Loop... ',0

yoffs:	even
yoff	set	0
	rept	200
	dc.w	yoff
yoff	set	yoff+160
	endr

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
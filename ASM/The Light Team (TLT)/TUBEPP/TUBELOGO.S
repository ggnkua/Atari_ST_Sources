*	The Toothpaste demo by Mr Pp/TLT

 	clr.l	-(sp)			Super
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#2,-(sp)		Get Physbase
	trap	#14
	addq.l	#2,sp
	move.l	D0,phys
	move.w	#3,-(sp)		Get Logbase
	trap	#14
	addq.l	#2,sp
	move.l	D0,log
	move.w	#4,-(sp)		Get rez
	trap	#14
	addq.l	#2,sp
	move.w	D0,rez			...and save'em

	dc.w	$a00a			Disable mouse

	move.w	#0,-(sp)		Set rez and screen addresses
	move.l	#$e8000,-(sp)
	move.l	#$e8000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	movem.l	$ffff8240.w,d0-d7	Save palette
	movem.l	d0-d7,palsave

	movem.l	pal,d0-d7		New palette
	movem.l	d0-d7,$ffff8240.w

	lea	$e8000,A0
	lea	$d3000,A1
	move.w	#9999,D0
clrscr	move.l	#0,(A0)+		Clear
	move.l	#0,(A1)+		both screens
	dbra	D0,clrscr

	lea	savebuf,A5		Get address to buffer for return
	move.l	$70,(A5)+		Vbl
	move.b	$fffa09,(A5)+		Save interrupts

	clr.b	$fffa09			Bye bye, interrupts

	move.l	#vbl,$70		Hi, VBL!

	move.b	$fffffa1b.w,(A5)+	Save HBLs
	move.l	$120,(A5)+
	move.b	$fffffa07.w,(A5)+
	move.b	$fffffa13.w,(A5)+
	move.b	$fffffa21.w,(A5)+

	clr.b	$fffffa1b.w		Set HBL routine
	bset.b	#0,$fffffa07.w
	bset.b	#0,$fffffa13.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr.b	#3,$fffffa17
	move.l	#hbl1,$120

	moveq.w	#1,D0
	lea	musix,A0		Init Musixx
	jsr	(A0)

	clr.w	wait
gloop	cmp.w	#1,wait			Any VBL yet???
	bne	gloop
	clr.w	wait


	cmp.b	#185,$fffffc02.w	Space??????????????????
	bne	gloop

	move.w	#$2700,sr

	move.l	#$8080000,$ffff8800.w	Bye to sound
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	move.l	#$707ff00,$ffff8800.w

 	lea	savebuf,A5		Address to buffer, restore everything

	move.l	(A5)+,$70		VBL
	move.b	(A5)+,$fffa09		Interrupts
	move.b	(A5)+,$fffffa1b.w	HBLs
	move.l	(A5)+,$120
	move.b	(A5)+,$fffffa07.w
	move.b	(A5)+,$fffffa13.w
	move.b	(A5)+,$fffffa21.w

	movem.l	palsave,d0-d7		Pop palette
	movem.l	d0-d7,$ffff8240.w

	move.w	rez,-(sp)		Set old rez and screen addresses
	move.l	phys,-(sp)
	move.l	log,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	savessp,-(sp)		User
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			Byeyeyeyeyeyeyyeeeeee
	trap	#1

*	HBL

hbl1	clr.b $fffffa1b.w		Next  hbl rout
	move.l	#hbl2,$120
	move.b	#198,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte				C.u.l.8.r
	
hbl2	REPT	116			Loborder
	nop
	ENDR
	move.b	#0,$ffff820a.w
	REPT	18
	nop
	ENDR
	move.b	#2,$ffff820a.w

	clr.b	$fffffa1b.w		Next  hbl rout
	move.l	#hbl3,$120
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
 	rte

hbl3	rte

*	VBL

vbl	move.w	#$007,$ffff8240.w

	clr.b	$fffffa1b.w		Set first hbl rout
	move.l	#hbl1,$120
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#1,wait			Flag

	move.l	screen1,D6		Switch screens
	move.l	screen2,D7
	move.l	D7,screen1
	move.l	D6,screen2

	lea	screen2,A0		Set show parameters
	move.b	1(A0),$ffff8201.w
	move.b	2(A0),$ffff8203.w

	lea	musix,A0		Musixx
	jsr	8(A0)

*	Tube

	move.l	screen1,A4		Draw address
	lea	32048-640(A4),A4
	lea	grafx,A1		Read address
	lea	tubebuf,A2		Tube data
	add.w	tuber,A2		Add tube data
	subq.w	#2,tuber		Backwards on reader

	bne	goont			End?
	move.w	#120,tuber		Restore

goont	moveq.w	#59,D0			Counter

loop60	move.l	A4,A0			Restore draw address
	tst.w	(A2)			End of tube buffer?
	bne	noend			Not end of tube buffer, go on
	lea	tubebuf,A2		Restore

noend	add.w	(A2)+,A0		Which line & bitplane
	move.w	(A1)+,(A0)		Draw 1 line
	move.w	(A1)+,8(A0)
	move.w	(A1)+,16(A0)
	move.w	(A1)+,24(A0)
	move.w	(A1)+,32(A0)
	move.w	(A1)+,40(A0)
	move.w	(A1)+,48(A0)
	move.w	(A1)+,56(A0)
	move.w	(A1)+,64(A0)

	dbra	D0,loop60		Loopt this 40 times

	move.w	#$000,$ffff8240.w

	rte				Byeeeeeeeeee

*	DATA

savessp	dc.w	0
rez	dc.w	0
phys	dc.l	0
log	dc.l	0
wait	dc.w	0
savebuf	ds.l	10
screen1	dc.l	$000e8000
screen2	dc.l	$000d3000
pal	dc.w	$000,$000,$777,$000,$444,$000,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000

	even
musix	incbin	c:\musix\delires.mus
	even

palsave	ds.l	8
tubebuf	dc.w	2,162,162,162,162,322,322,482,482,642,802,802,962,1122,1282,1442,1442,1602,1762,1922,2082,2082,2242,2402,2402,2562,2562,2722,2722,2722
	dc.w	2724,2724,2724,2564,2564,2404,2404,2244,2084,2084,1924,1764,1604,1444,1444,1284,1124,964,804,804,644,484,484,324,324,164,164,164,164,4
	dc.w	0,0

tuber	dc.w	40
grafx	incbin	tubelogo.gfx
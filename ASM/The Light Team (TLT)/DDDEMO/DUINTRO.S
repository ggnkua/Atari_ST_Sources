*	The Digiyal Disaster demo by Mr Pp/TLT

*	Hej Carl!! Jag vet att jag kan muktiplicera i f”rv„g och
*	s† men inte orkar lilla jag g”ra det.. Och f”rresten f†r jag
*	f”r mycket vbl tid ”ver d† s† att det kommer o st”r nedre
*	bordern... S†des†!!T

	opt d-,o+,o1+,o2+,ow+,x+,s-,t-,c+,p-

 	clr.l	-(sp)			Super
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	D0,savessp		Save USP

	move.l	sp,savesp		Save SSP
	lea	stack,sp		New SSP

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
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	movem.l	$ffff8240.w,d0-d7	Save palette
	movem.l	d0-d7,palsave

	movem.l	pal,d0-d7		Set palette
	movem.l	d0-d7,$ffff8240.w

	move.l	screen1,A0
	move.l	screen2,A1
	move.w	#9999,D0
clrscr	move.l	#0,(A0)+		Clear
	move.l	#0,(A1)+		both screens
	dbra	D0,clrscr

	lea	zdata,A0		Recalculate
rloop	move.w	(A0),D0
	mulu.w	#4800,D0
	move.w	D0,(A0)+
	cmp.w	#-1,(A0)
	bne.s	rloop

	lea	ybbuf,A0		Recalculate
rrloop	move.w	(A0),D0
	mulu.w	#160,D0
	move.w	D0,(A0)+
	cmp.w	#-1,(A0)
	bne.s	rrloop

*	Construct starfield

	lea	starf,A6		Where to put coordinates for stars
	moveq.w	#31,D7			Construct starfield

starfie	moveq.w	#31,D2			Current Z counter

ztest	lea	starpos,A0		Star positions
	lea	starddd,A4		Star data
	moveq.w	#47,D6			Sprite data counter

sloop	cmp.w	4(A0),D2		Does the deep fit?
	beq	savepos			Yes, calculate and save position
aftsav	addq.l	#6,A0			Next z
	dbra	D6,sloop		Next star

	dbra	D2,ztest

	lea	starpos,A0		Calculate stars that they will come to the screen
	rept	48
	subq.w	#1,4(A0)
	and.w	#%11111,4(A0)		Of under 0 then start again from 32
	addq.l	#6,A0			Next star
	endr

	dbra	D7,starfie		Next starfield

*	Preshift data

	lea	font,A0			Pre shift it

	moveq.w	#50,D1			Counter

preloop	rept	32
	move.l	(A0),192(A0)		Copy letter
	move.w	4(A0),196(A0)
	addq.l	#6,A0
	endr
	lea	-192(A0),A0		Back
	rept	32			Shift it
	move.b	3(A0),4(A0)
	move.b	2(A0),3(A0)
	move.b	1(A0),2(A0)
	move.b	(A0),1(A0)
	clr.b	(A0)
	lea	6(A0),A0
	endr
	lea	192(A0),A0		Next letter
	dbra	D1,preloop

*	Draw "menu"

	lea	gfxzx,A0		Reader
	move.l	screen1,A1		Draw1
	move.l	screen2,A2		Draw2
	lea	10566(A1),A1		Down , bitplane 4
	lea	10566(A2),A2

	move.w	#579,D0			Counter
.loop	move.w	(A0),(A1)
	move.w	(A0)+,(A2)
	addq.l	#8,A1
	addq.l	#8,A2
	dbra	D0,.loop

*	Other installations

	lea	savebuf,A5		Get address to buffer for return
	move.l	$70.w,(A5)+		Vbl
	move.b	$fffa09,(A5)+		Save interrupts
	move.b	$fffffa1b.w,(A5)+	Save HBLs
	move.l	$120.w,(A5)+
	move.b	$fffffa07.w,(A5)+
	move.b	$fffffa13.w,(A5)+
	move.b	$fffffa21.w,(A5)+

	move.w	sr,ssr			Save sr
	move.w	#$2700,sr

	clr.b	$fffffa09.w		Bye bye, interrupts
	move.l	#vbl,$70.w		Hi, VBL!
	clr.b	$fffffa1b.w		Set HBL routine
	bset.b	#0,$fffffa07.w
	bset.b	#0,$fffffa13.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr.b	#3,$fffffa17.w
	move.l	#hbl1,$120.w

	move.w	#$2300,sr

	moveq.w	#1,D0
init	move.l	musix,A0		Init musixx
	jsr	(A0)

	clr.w	wait
gloop	cmp.w	#1,wait			Any VBL yet???
	bne.s	gloop
	clr.w	wait

	move.b	$fffffc02.w,D0		Get key

	cmp.b	#$3b,D0			F1???
	bne.s	notF1
	cmp.w	#1,musch		Already selected?
	beq.s	gloop
	move.w	#1,musch
	moveq.w	#1,D0
	move.l	#musix0,musix
	bra.s	init
notF1	cmp.b	#$3c,D0			F2???
	bne.s	notF2
	cmp.w	#2,musch		Already selected?
	beq.s	gloop
	move.w	#2,musch
	moveq.w	#1,D0
	move.l	#musix1,musix
	bra.s	init
notF2	cmp.b	#$3d,D0			F3???
	bne.s	notF3
	cmp.w	#3,musch		Already selected?
	beq.s	gloop
	move.w	#3,musch
	moveq.w	#2,D0
	move.l	#musix1,musix
	bra	init
notF3	cmp.b	#$3e,D0			F4???
	bne.s	notF4
	cmp.w	#4,musch		Already selected?
	beq	gloop
	move.w	#4,musch
	moveq.w	#3,D0
	move.l	#musix1,musix
	bra	init

notF4	cmp.b	#$67,D0			7?
	bne.s	n1
	btst.b	#3,oscstat		Already off?
	beq	gloop			Yep
	bclr.b	#3,oscstat		Off..
	bra	VAf			Volume A ofF

n1	cmp.b	#$68,D0			8?
	bne.s	n2
	btst.b	#4,oscstat		Already off?
	beq	gloop			Yep
	bclr.b	#4,oscstat		Off..
	bra	VBf			Volume B ofF

n2	cmp.b	#$69,D0			9?
	bne.s	n3
	btst.b	#5,oscstat		Already off?
	beq	gloop			Yep
	bclr.b	#5,oscstat		Off..
	bra	VCf			Volume C ofF

n3	cmp.b	#$6d,D0			1?
	bne.s	n4
	btst.b	#0,oscstat		Already off?
	beq	gloop			Yep
	bclr.b	#0,oscstat		Off..
	bra	FAf			Frequency A ofF

n4	cmp.b	#$6e,D0			2?
	bne.s	n5
	btst.b	#1,oscstat		Already off?
	beq	gloop			Yep
	bclr.b	#1,oscstat		Off..
	bra	FBf			Frequency B ofF

n5	cmp.b	#$6f,D0			3?
	bne.s	n6
	btst.b	#2,oscstat		Already off?
	beq	gloop			Yep
	bclr.b	#2,oscstat		Off..
	bra	FCf			Frequency C ofF

n6	cmp.b	#$63,D0			(?
	bne.s	n7
	btst.b	#3,oscstat		Already oN?
	bne	gloop			Yep
	bset.b	#3,oscstat		on..
	bra	VAn			Volume A oN

n7	cmp.b	#$64,D0			)?
	bne.s	n8
	btst.b	#4,oscstat		Already oN?
	bne	gloop			Yep
	bset.b	#4,oscstat		on..
	bra	VBn			Volume B oN

n8	cmp.b	#$65,D0			/?
	bne.s	n9
	btst.b	#5,oscstat		Already oN?
	bne	gloop			Yep
	bset.b	#5,oscstat		on..
	bra	VCn			Volume C oN

n9	cmp.b	#$6a,D0			4?
	bne.s	n10
	btst.b	#0,oscstat		Already oN?
	bne	gloop			Yep
	bset.b	#0,oscstat		on..
	bra	FAn			Frequency A oN

n10	cmp.b	#$6b,D0			5?
	bne.s	n11
	btst.b	#1,oscstat		Already oN?
	bne	gloop			Yep
	bset.b	#1,oscstat		on..
	bra	FBn			Frequency B oN

n11	cmp.b	#$6c,D0			6?
	bne.s	n12
	btst.b	#2,oscstat		Already oN?
	bne	gloop			Yep
	bset.b	#2,oscstat		on..
	bra	FCn			Frequency C oN

n12	cmp.b	#185,D0			Space??????????????????
	bne	gloop

	move.w	#$2700,sr

	move.l	#$8080000,$ffff8800.w	Bye to sound
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	move.l	#$707ff00,$ffff8800.w

 	lea	savebuf,A5		Address to buffer, restore everything

	move.l	(A5)+,$70.w		VBL
	move.b	(A5)+,$fffa09		Interrupts
	move.b	(A5)+,$fffffa1b.w	HBLs
	move.l	(A5)+,$120.w
	move.b	(A5)+,$fffffa07.w
	move.b	(A5)+,$fffffa13.w
	move.b	(A5)+,$fffffa21.w

	movem.l	palsave,d0-d7		Pop palette
	movem.l	d0-d7,$ffff8240.w

	move.w	ssr,sr

	move.w	rez,-(sp)		Set old rez and screen addresses
	move.l	phys,-(sp)
	move.l	log,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	savesp,sp		Pop old SSP

	move.l	savessp,-(sp)		User
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			Byeyeyeyeyeyeyyeeeeee
	trap	#1

*	HBL

hbl1	clr.b $fffffa1b.w		Next  hbl rout
	move.l	#hbl12,$120.w
	move.b	#29,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte				C.u.l.8.r

hbl12	move.w	#$200,$ffff8250.w

	move.w	#$733,$ffff8242.w
	move.w	#$711,$ffff8244.w
	move.w	#$500,$ffff8246.w

	clr.b $fffffa1b.w		Next  hbl rout
	move.l	#hbl14,$120.w
	move.b	#29,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte				C.u.l.8.r

hbl14	move.w	#$377,$ffff8242.w
	move.w	#$156,$ffff8244.w
	move.w	#$035,$ffff8246.w

	lea	oscrast,A6		Oscilloscope raster
	move.w	#24,line		Counter
	move.w	(A6)+,$ffff8250.w	Change colour

	clr.b $fffffa1b.w		Next  hbl rout
	move.l	#hbl145,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte				C.u.l.8.r

hbl145	move.w	(A6)+,$ffff8250.w	Colour
	subq.w	#1,line			Countdown
	bne.s	hblqk
	clr.b $fffffa1b.w		Next  hbl rout
	move.l	#hbl15,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
hblqk	rte				C.u.l.8.r


hbl15	lea	rastbuf,A6		Reader
	add.w	rastdat,A6		Add rast data
	move.w	(A6)+,$ffff8250.w	Colour
	move.w	#40,line		Counter
	clr.b $fffffa1b.w		Next  hbl rout
	move.l	#hbl16,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte				C.u.l.8.r

hbl16	move.w	(A6)+,$ffff8250.w	Colour
	subq.w	#1,line			Countdown
	bne.s	hblend
	clr.b $fffffa1b.w		Next  hbl rout
	move.l	#hbl17,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
hblend	rte				C.u.l.8.r

hbl17	clr.b $fffffa1b.w		Next  hbl rout
	move.l	#hbl2,$120.w
	move.b	#9,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte				C.u.l.8.r

hbl2	REPT	120			Loborder
	nop
	ENDR
	move.b	#0,$ffff820a.w
	REPT	13 
	nop
	ENDR
	move.b	#2,$ffff820a.w

	lea	iqrast,A6
	move.w	(A6)+,$ffff8250.w

	clr.b	$fffffa1b.w		Next  hbl rout
	move.l	#hbl3,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
 	rte

hbl3	move.w	(A6)+,$ffff8250.w
	rte

*	VBL

vbl	clr.b	$fffffa1b.w		Set first hbl rout
	move.l	#hbl1,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#1,wait			Flag

	movem.l	D0-A5,-(sp)		Guess

	move.l	screen1,D6		Switch screens
	move.l	screen2,D7
	move.l	D7,screen1
	move.l	D6,screen2

	lea	screen1,A0		Set show parameters
	move.b	1(A0),$ffff8201.w
	move.b	2(A0),$ffff8203.w

	move.w	#$775,$ffff8242.w
	move.w	#$553,$ffff8244.w
	move.w	#$331,$ffff8246.w

	move.l	musix,A0		Musixx
	jsr	8(A0)

	move.w	#$777,$ffff8250.w	Colour

*	Raster movements

	move.l	rastpek,A0		Peeker to rast data
	move.w	(A0)+,rastdat		iiiiiiinto buffer
	cmp.w	#-1,(A0)		End????
	bne.s	sunfuck			No
	move.l	#rastadd,rastpek	Restore
sunfuck	addq.l	#2,rastpek		Forward

*	IQlizers

	clr.w	D0			Work reg
	move.b	#8,$ffff8800.w		Get vol A
	move.b	$ffff8800.w,D0
	lsl.w	#5,D0			Multiply with 32
	lea	iqgfx,A0		Grafx
	add.w	D0,A0			Add gfx data
	move.l	screen1,A1		Draw reg
	lea	31046+32(A1),A1		Down on screen
	lea	960(A1),A1

	move.w	(A0),(A1)		Gfx
	move.w	(A0)+,160(A1)
	move.w	(A0),320(A1)
	move.w	(A0)+,480(A1)
	move.w	(A0),640(A1)
	move.w	(A0)+,800(A1)
	move.w	(A0),960(A1)
	move.w	(A0)+,1120(A1)
	move.w	(A0),1280(A1)
	move.w	(A0)+,1440(A1)
	move.w	(A0),1600(A1)
	move.w	(A0)+,1760(A1)
	move.w	(A0),1920(A1)
	move.w	(A0)+,2080(A1)
	move.w	(A0),2240(A1)
	move.w	(A0)+,2400(A1)
	move.w	(A0),2560(A1)
	move.w	(A0)+,2720(A1)
	move.w	(A0),2880(A1)
	move.w	(A0)+,3040(A1)
	move.w	(A0),3200(A1)
	move.w	(A0)+,3360(A1)
	move.w	(A0),3520(A1)
	move.w	(A0)+,3680(A1)
	move.w	(A0),3840(A1)
	move.w	(A0)+,4000(A1)
	move.w	(A0),4160(A1)
	move.w	(A0)+,4320(A1)
	move.w	(A0),4480(A1)
	move.w	(A0)+,4640(A1)
	move.w	(A0),4800(A1)
	move.w	(A0)+,4960(A1)
	addq.l	#8,A1
	lea	-32(A0),A0
	move.w	(A0),(A1)
	move.w	(A0)+,160(A1)
	move.w	(A0),320(A1)
	move.w	(A0)+,480(A1)
	move.w	(A0),640(A1)
	move.w	(A0)+,800(A1)
	move.w	(A0),960(A1)
	move.w	(A0)+,1120(A1)
	move.w	(A0),1280(A1)
	move.w	(A0)+,1440(A1)
	move.w	(A0),1600(A1)
	move.w	(A0)+,1760(A1)
	move.w	(A0),1920(A1)
	move.w	(A0)+,2080(A1)
	move.w	(A0),2240(A1)
	move.w	(A0)+,2400(A1)
	move.w	(A0),2560(A1)
	move.w	(A0)+,2720(A1)
	move.w	(A0),2880(A1)
	move.w	(A0)+,3040(A1)
	move.w	(A0),3200(A1)
	move.w	(A0)+,3360(A1)
	move.w	(A0),3520(A1)
	move.w	(A0)+,3680(A1)
	move.w	(A0),3840(A1)
	move.w	(A0)+,4000(A1)
	move.w	(A0),4160(A1)
	move.w	(A0)+,4320(A1)
	move.w	(A0),4480(A1)
	move.w	(A0)+,4640(A1)
	move.w	(A0),4800(A1)
	move.w	(A0)+,4960(A1)

	clr.w	D0			Work reg
	move.b	#9,$ffff8800.w		Get vol B
	move.b	$ffff8800.w,D0
	lsl.w	#5,D0			Multiply with 32
	lea	iqgfx,A0		Grafx
	add.w	D0,A0			Add gfx data
	move.l	screen1,A1		Draw reg
	lea	31046+56(A1),A1		Down on screen
	lea	960(A1),A1

	move.w	(A0),(A1)		Gfx
	move.w	(A0)+,160(A1)
	move.w	(A0),320(A1)
	move.w	(A0)+,480(A1)
	move.w	(A0),640(A1)
	move.w	(A0)+,800(A1)
	move.w	(A0),960(A1)
	move.w	(A0)+,1120(A1)
	move.w	(A0),1280(A1)
	move.w	(A0)+,1440(A1)
	move.w	(A0),1600(A1)
	move.w	(A0)+,1760(A1)
	move.w	(A0),1920(A1)
	move.w	(A0)+,2080(A1)
	move.w	(A0),2240(A1)
	move.w	(A0)+,2400(A1)
	move.w	(A0),2560(A1)
	move.w	(A0)+,2720(A1)
	move.w	(A0),2880(A1)
	move.w	(A0)+,3040(A1)
	move.w	(A0),3200(A1)
	move.w	(A0)+,3360(A1)
	move.w	(A0),3520(A1)
	move.w	(A0)+,3680(A1)
	move.w	(A0),3840(A1)
	move.w	(A0)+,4000(A1)
	move.w	(A0),4160(A1)
	move.w	(A0)+,4320(A1)
	move.w	(A0),4480(A1)
	move.w	(A0)+,4640(A1)
	move.w	(A0),4800(A1)
	move.w	(A0)+,4960(A1)
	addq.l	#8,A1
	lea	-32(A0),A0
	move.w	(A0),(A1)
	move.w	(A0)+,160(A1)
	move.w	(A0),320(A1)
	move.w	(A0)+,480(A1)
	move.w	(A0),640(A1)
	move.w	(A0)+,800(A1)
	move.w	(A0),960(A1)
	move.w	(A0)+,1120(A1)
	move.w	(A0),1280(A1)
	move.w	(A0)+,1440(A1)
	move.w	(A0),1600(A1)
	move.w	(A0)+,1760(A1)
	move.w	(A0),1920(A1)
	move.w	(A0)+,2080(A1)
	move.w	(A0),2240(A1)
	move.w	(A0)+,2400(A1)
	move.w	(A0),2560(A1)
	move.w	(A0)+,2720(A1)
	move.w	(A0),2880(A1)
	move.w	(A0)+,3040(A1)
	move.w	(A0),3200(A1)
	move.w	(A0)+,3360(A1)
	move.w	(A0),3520(A1)
	move.w	(A0)+,3680(A1)
	move.w	(A0),3840(A1)
	move.w	(A0)+,4000(A1)
	move.w	(A0),4160(A1)
	move.w	(A0)+,4320(A1)
	move.w	(A0),4480(A1)
	move.w	(A0)+,4640(A1)
	move.w	(A0),4800(A1)
	move.w	(A0)+,4960(A1)

	clr.w	D0			Work reg
	move.b	#10,$ffff8800.w		Get vol C
	move.b	$ffff8800.w,D0
	lsl.w	#5,D0			Multiply with 32
	lea	iqgfx,A0		Grafx
	add.w	D0,A0			Add gfx data
	move.l	screen1,A1		Draw reg
	lea	31054+80(A1),A1		Down on screen
	lea	960(A1),A1

	move.w	(A0),(A1)		Gfx
	move.w	(A0)+,160(A1)
	move.w	(A0),320(A1)
	move.w	(A0)+,480(A1)
	move.w	(A0),640(A1)
	move.w	(A0)+,800(A1)
	move.w	(A0),960(A1)
	move.w	(A0)+,1120(A1)
	move.w	(A0),1280(A1)
	move.w	(A0)+,1440(A1)
	move.w	(A0),1600(A1)
	move.w	(A0)+,1760(A1)
	move.w	(A0),1920(A1)
	move.w	(A0)+,2080(A1)
	move.w	(A0),2240(A1)
	move.w	(A0)+,2400(A1)
	move.w	(A0),2560(A1)
	move.w	(A0)+,2720(A1)
	move.w	(A0),2880(A1)
	move.w	(A0)+,3040(A1)
	move.w	(A0),3200(A1)
	move.w	(A0)+,3360(A1)
	move.w	(A0),3520(A1)
	move.w	(A0)+,3680(A1)
	move.w	(A0),3840(A1)
	move.w	(A0)+,4000(A1)
	move.w	(A0),4160(A1)
	move.w	(A0)+,4320(A1)
	move.w	(A0),4480(A1)
	move.w	(A0)+,4640(A1)
	move.w	(A0),4800(A1)
	move.w	(A0)+,4960(A1)
	addq.l	#8,A1
	lea	-32(A0),A0
	move.w	(A0),(A1)
	move.w	(A0)+,160(A1)
	move.w	(A0),320(A1)
	move.w	(A0)+,480(A1)
	move.w	(A0),640(A1)
	move.w	(A0)+,800(A1)
	move.w	(A0),960(A1)
	move.w	(A0)+,1120(A1)
	move.w	(A0),1280(A1)
	move.w	(A0)+,1440(A1)
	move.w	(A0),1600(A1)
	move.w	(A0)+,1760(A1)
	move.w	(A0),1920(A1)
	move.w	(A0)+,2080(A1)
	move.w	(A0),2240(A1)
	move.w	(A0)+,2400(A1)
	move.w	(A0),2560(A1)
	move.w	(A0)+,2720(A1)
	move.w	(A0),2880(A1)
	move.w	(A0)+,3040(A1)
	move.w	(A0),3200(A1)
	move.w	(A0)+,3360(A1)
	move.w	(A0),3520(A1)
	move.w	(A0)+,3680(A1)
	move.w	(A0),3840(A1)
	move.w	(A0)+,4000(A1)
	move.w	(A0),4160(A1)
	move.w	(A0)+,4320(A1)
	move.w	(A0),4480(A1)
	move.w	(A0)+,4640(A1)
	move.w	(A0),4800(A1)
	move.w	(A0)+,4960(A1)

	clr.w	D0			Work reg
	move.b	#6,$ffff8800.w		Get noise
	move.b	$ffff8800.w,D0
	and.w	#$F,D0			Not over 16
	lsl.w	#5,D0			Multiply with 32
	lea	iqgfx,A0		Grafx
	add.w	D0,A0			Add gfx data
	move.l	screen1,A1		Draw reg
	lea	31054+104(A1),A1	Down on screen
	lea	960(A1),A1

	move.w	(A0),(A1)		Gfx
	move.w	(A0)+,160(A1)
	move.w	(A0),320(A1)
	move.w	(A0)+,480(A1)
	move.w	(A0),640(A1)
	move.w	(A0)+,800(A1)
	move.w	(A0),960(A1)
	move.w	(A0)+,1120(A1)
	move.w	(A0),1280(A1)
	move.w	(A0)+,1440(A1)
	move.w	(A0),1600(A1)
	move.w	(A0)+,1760(A1)
	move.w	(A0),1920(A1)
	move.w	(A0)+,2080(A1)
	move.w	(A0),2240(A1)
	move.w	(A0)+,2400(A1)
	move.w	(A0),2560(A1)
	move.w	(A0)+,2720(A1)
	move.w	(A0),2880(A1)
	move.w	(A0)+,3040(A1)
	move.w	(A0),3200(A1)
	move.w	(A0)+,3360(A1)
	move.w	(A0),3520(A1)
	move.w	(A0)+,3680(A1)
	move.w	(A0),3840(A1)
	move.w	(A0)+,4000(A1)
	move.w	(A0),4160(A1)
	move.w	(A0)+,4320(A1)
	move.w	(A0),4480(A1)
	move.w	(A0)+,4640(A1)
	move.w	(A0),4800(A1)
	move.w	(A0)+,4960(A1)
	addq.l	#8,A1
	lea	-32(A0),A0
	move.w	(A0),(A1)
	move.w	(A0)+,160(A1)
	move.w	(A0),320(A1)
	move.w	(A0)+,480(A1)
	move.w	(A0),640(A1)
	move.w	(A0)+,800(A1)
	move.w	(A0),960(A1)
	move.w	(A0)+,1120(A1)
	move.w	(A0),1280(A1)
	move.w	(A0)+,1440(A1)
	move.w	(A0),1600(A1)
	move.w	(A0)+,1760(A1)
	move.w	(A0),1920(A1)
	move.w	(A0)+,2080(A1)
	move.w	(A0),2240(A1)
	move.w	(A0)+,2400(A1)
	move.w	(A0),2560(A1)
	move.w	(A0)+,2720(A1)
	move.w	(A0),2880(A1)
	move.w	(A0)+,3040(A1)
	move.w	(A0),3200(A1)
	move.w	(A0)+,3360(A1)
	move.w	(A0),3520(A1)
	move.w	(A0)+,3680(A1)
	move.w	(A0),3840(A1)
	move.w	(A0)+,4000(A1)
	move.w	(A0),4160(A1)
	move.w	(A0)+,4320(A1)
	move.w	(A0),4480(A1)
	move.w	(A0)+,4640(A1)
	move.w	(A0),4800(A1)
	move.w	(A0)+,4960(A1)

*	Erase former oscilloscope

	move.l	obuf1,D6		Swith bufs
	move.l	obuf2,D7
	move.l	D7,obuf1
	move.l	D6,obuf2

	move.l	obuf1,A0		Erase former sprites
	rept	64
	move.l	(A0)+,A1
	clr.w	(A1)
	endr

*	Calculate and draw oscilloscope

*	Calculate

	btst.b	#0,oscstat		Do A freq?
	beq.s	Bfreq			No
	move.b	#0,$ffff8800.w		Get A frequency
	move.b	$ffff8800.w,D0
	lsr.b	#4,D0			Divide with 16
	add.b	D0,Adat			Add to B data
	move.b	Adat,D0			Get new B data
	and.b	#%111111,D0		Not over 64
	move.b	D0,Adat

Bfreq	btst.b	#1,oscstat		Do B freq?
	beq.s	Cfreq			No
	move.b	#2,$ffff8800.w		Get B frequency
	move.b	$ffff8800.w,D0
	lsr.b	#4,D0			Divide with 16
	add.b	D0,Bdat			Add to B data
	move.b	Bdat,D0			Get new B data
	and.b	#%111111,D0		Not over 64
	move.b	D0,Bdat

Cfreq	btst.b	#2,oscstat		Do C freq?
	beq.s	clro			No
	move.b	#4,$ffff8800.w		Get C frequency
	move.b	$ffff8800.w,D0
	lsr.b	#4,D0			Divide with 16
	add.b	D0,Cdat			Add to C data
	move.b	Cdat,D0			Get new C data
	and.b	#%111111,D0		Not over 64
	move.b	D0,Cdat

clro	lea	oscdata,A0		Clear buf
	rept	16
	clr.l	(A0)+
	endr

	clr.w	D0			Work reg
	clr.w	D1

	btst.b	#3,oscstat		Do A vol?
	beq	Bvol			No
	move.b	#8,$ffff8800.w		Get volume A
	move.b	$ffff8800.w,D0
	and.b	#%1110,D0		Only volume, divided with 2
	lsl.w	#5,D0			Multiply with 32 (64 is needed, but first mul. is in the AND)
	lea	oscillo,A0		Waves
	add.w	D0,A0			Add volume data
	lea	oscdata,A1		Buffer
	move.b	Adat,D1			Frequency
	rept	64
	move.b	(A0,D1.w),D0		Modify buffer
	add.b	D0,(A1)+
	addq.b	#1,D1			Add one
	and.b	#%111111,D1		Not over 64!!
	endr

Bvol	btst.b	#4,oscstat		Do B vol?
	beq	Cvol			No
	clr.w	D0			Work reg
	clr.w	D1
	move.b	#9,$ffff8800.w		Get volume B
	move.b	$ffff8800.w,D0
	and.b	#%1110,D0		Only volume, divided with 2
	lsl.w	#5,D0			Multiply with 32 (64 is needed, but first mul. is in the AND)
	lea	oscillo,A0		Waves
	add.w	D0,A0			Add volume data
	lea	oscdata,A1		Buffer
	move.b	Bdat,D1			Frequency
	rept	64
	move.b	(A0,D1.w),D0		Modify buffer
	add.b	D0,(A1)+
	addq.b	#1,D1			Add one
	and.b	#%111111,D1		Not over 64!!
	endr

Cvol	btst.b	#5,oscstat		Do C vol?
	beq	eend			No
	clr.w	D0			Work reg
	clr.w	D1
	move.b	#10,$ffff8800.w		Get volume C
	move.b	$ffff8800.w,D0
	and.b	#%1110,D0		Only volume, divided with 2
	lsl.w	#5,D0			Multiply with 32 (64 is needed, but first mul. is in the AND)
	lea	oscillo,A0		Waves
	add.w	D0,A0			Add volume data
	lea	oscdata,A1		Buffer
	move.b	Cdat,D1			Frequency
	rept	64
	move.b	(A0,D1.w),D0		Modify buffer
	add.b	D0,(A1)+
	addq.b	#1,D1			Add one
	and.b	#%111111,D1		Not over 64!!
	endr

*	Draw

eend	move.l	obuf1,A2		Buffer
	moveq.w	#96,D4			X
	moveq.w	#80,D1			Y
	lea	oscdata,A3

	rept	64
	move.w	D4,D0			Get coordinates
	add.b	(A3)+,D1

	move.l	screen1,A0		Draw reg
	addq.l	#6,A0			Bitplane 4
	move.w	D1,D5			Work
	mulu.w	#160,D5			Y add reg
	move.w	D0,D3			Work
	and.w	#%1111111111110000,D3	X add reg
	sub.w	D3,D0			Right shift reg (D0)
	lsr.w	#1,D3			Finish calculations
	add.w	D5,A0			Add to draw reg
	add.w	D3,A0			Add to draw reg again
	lsl.w	#1,D0

	lea	plotdot,A1		Gfx buffer
	move.l	A0,(A2)+		Fill erase buffer

	move.w	(A1,D0.w),D0		Get star
	or.w	D0,(A0)			Put star	
	addq.w	#2,D4			Forward
	endr
 
*	Erase former stars

	move.l	sbuf1,D6		Swith bufs
	move.l	sbuf2,D7
	move.l	D7,sbuf1
	move.l	D6,sbuf2

	move.l	sbuf1,A0		Erase former sprites
	rept	48
	move.l	(A0)+,A1
	clr.w	(A1)
	endr

*	Starfield

	move.l	starpek,A3		Get starfield peeker
	move.l	sbuf1,A2		Buffer

	rept	48
	move.w	(A3)+,D0		Get coordinates
	move.w	(A3)+,D1

	move.l	screen1,A0		Draw reg
	lea	4(A0),A0		Bitplane 3
	mulu.w	#160,D1			Y add reg
	move.w	D0,D3			Work
	and.w	#%1111111111110000,D3	X add reg
	sub.w	D3,D0			Right shift reg (D0)
	lsr.w	#1,D3			Finish calculations
	add.w	D1,A0			Add to draw reg
	add.w	D3,A0			Add to draw reg again
	lsl.w	#1,D0

	lea	stardot,A1		Gfx buffer
	move.l	A0,(A2)+		Fill erase buffer

	move.w	(A1,D0.w),D0		Get star
	or.w	D0,(A0)			Put star	
	endr

	add.l	#192,starpek		Next starfield

	subq.w	#1,starc		Countdown
	bne.s	lpalp

	move.l	#starf,starpek		Restore
	move.w	#32,starc

lpalp

*	BIIIIIIIIIG zdist

	move.l	screen1,A0		Draw reg
	move.l	zpeek,A2		Data peeker
	cmp.w	#-1,(A2)		end?
	bne.s	noendZ			No
	lea	zdata,A2		Restore
	move.l	#zdata,zpeek

noendZ	moveq.w	#59,D0			Y reg
	moveq.w	#0,D2			Y draw reg
	moveq.w	#0,D1			Work

Zyloop	move.w	(A2)+,D1		Get Z data
	cmp.w	#-1,(A2)		End?
	bne.s	noendz2			No
	lea	zdata,A2		Restore

noendz2	lea	gfx,A1			Graphics
	add.l	D1,A1			Which line
	move.l	0(A1,D2.w),(A0)		Draw one line
	move.l	4(A1,D2.w),8(A0)
	move.l	8(A1,D2.w),16(A0)
	move.l	12(A1,D2.w),24(A0)
	move.l	16(A1,D2.w),32(A0)
	move.l	20(A1,D2.w),40(A0)
	move.l	24(A1,D2.w),48(A0)
	move.l	28(A1,D2.w),56(A0)
	move.l	32(A1,D2.w),64(A0)
	move.l	36(A1,D2.w),72(A0)
	move.l	40(A1,D2.w),80(A0)
	move.l	44(A1,D2.w),88(A0)
	move.l	48(A1,D2.w),96(A0)
	move.l	52(A1,D2.w),104(A0)
	move.l	56(A1,D2.w),112(A0)
	move.l	60(A1,D2.w),120(A0)
	move.l	64(A1,D2.w),128(A0)
	move.l	68(A1,D2.w),136(A0)
	move.l	72(A1,D2.w),144(A0)
	move.l	76(A1,D2.w),152(A0)
	lea	160(A0),A0		One line down
	add.w	#80,D2
	dbra	D0,Zyloop		All lines
	addq.l	#2,zpeek

*	Erase sprites

	move.l	buf1,D6			Swith bufs
	move.l	buf2,D7
	move.l	D7,buf1
	move.l	D6,buf2

	move.l	buf1,A0			Erase former sprites
	rept	12
	move.l	(A0)+,A1
	clr.l	(A1)
	clr.l	8(A1)
	clr.l	160(A1)
	clr.l	168(A1)
	clr.l	320(A1)
	clr.l	328(A1)
	clr.l	480(A1)
	clr.l	488(A1)
	clr.l	640(A1)
	clr.l	648(A1)
	clr.l	800(A1)
	clr.l	808(A1)
	clr.l	960(A1)
	clr.l	968(A1)
	clr.l	1120(A1)
	clr.l	1128(A1)
	clr.l	1280(A1)
	clr.l	1288(A1)
	clr.l	1440(A1)
	clr.l	1448(A1)
	clr.l	1600(A1)
	clr.l	1608(A1)
	clr.l	1760(A1)
	clr.l	1768(A1)
	clr.l	1920(A1)
	clr.l	1928(A1)
	clr.l	2080(A1)
	clr.l	2088(A1)
	clr.l	2240(A1)
	clr.l	2248(A1)
	clr.l	2400(A1)
	clr.l	2408(A1)
	endr

*	THE LIGHT TEAM sprites

	move.l	buf1,A2			Fill sprite buffer

	move.l	cpos1,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos1,A0
	add.w	(A0),D1
	lea	T,A1			Get read address
	jsr	sprite
	move.l	cpos2,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos2,A0
	add.w	(A0),D1
	lea	H,A1			Get read address
	jsr	sprite
	move.l	cpos3,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos3,A0
	add.w	(A0),D1
	lea	E,A1			Get read address
	jsr	sprite
	move.l	cpos4,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos4,A0
	add.w	(A0),D1
	lea	L,A1			Get read address
	jsr	sprite
	move.l	cpos5,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos5,A0
	add.w	(A0),D1
	lea	I,A1			Get read address
	jsr	sprite
	move.l	cpos6,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos6,A0
	add.w	(A0),D1
	lea	G,A1			Get read address
	jsr	sprite
	move.l	cpos7,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos7,A0
	add.w	(A0),D1
	lea	H,A1			Get read address
	jsr	sprite
	move.l	cpos8,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos8,A0
	add.w	(A0),D1
	lea	T,A1			Get read address
	jsr	sprite
	move.l	cpos9,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos9,A0
	add.w	(A0),D1
	lea	T,A1			Get read address
	jsr	sprite
	move.l	cpos10,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos10,A0
	add.w	(A0),D1
	lea	E,A1			Get read address
	jsr	sprite
	move.l	cpos11,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos11,A0
	add.w	(A0),D1
	lea	A,A1			Get read address
	jsr	sprite
	move.l	cpos12,A0
	move.w	(A0)+,D0
	move.w	(A0)+,D1
	move.l	ypos12,A0
	add.w	(A0),D1
	lea	M,A1			Get read address
	jsr	sprite

	lea	cpos1,A0		Forward on readers
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+
	addq.l	#4,(A0)+

	lea	ypos1,A0
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+
	addq.l	#2,(A0)+

	lea	cpos1,A0		Restore if end (pos peeker)
	moveq.w	#11,D0

rloop2	move.l	(A0),A1
	cmp.w	#-1,(A1)
	bne.s	noend
	move.l	#curve,(A0)
noend	addq.l	#4,A0
	dbra	D0,rloop2

	lea	ypos1,A0		Restore if end (y peeker)
	moveq.w	#11,D0

rloop3	move.l	(A0),A1
	cmp.w	#-1,(A1)
	bne.s	noend2
	move.l	#ycurve,(A0)
noend2	addq.l	#4,A0
	dbra	D0,rloop3


*	Preshift

	move.l	ylpek,A4		Gte Y letter (dist) peeker

	tst.w	flag			This rout?
	bne	notr1			Nop, test 2

*	Rout 1

	moveq.w	#5,D1			Nr of letters
	moveq.w	#0,D2			X data

	move.l	textpek,A3		Get peeker
	move.w	(A3)+,D0		Get letter
	cmp.w	#-1,(A3)		End???
	bne.s	norest			No

	lea	text,A3			Restore
	move.l	#text,textpek		Restore
	move.l	#ylbuf0,ylpek		Restore from 0
	move.l	#ybbuf0,ybpek		Restore from 0

norest	mulu.w	#384,D0			Make to letter size
	lea	font,A2			Get font
	add.w	D0,A2			Add to font peeker
	add.w	count,A2		and add preshift data
	move.l	screen1,A1		Get screen address
	lea	16006(A1),A1
	add.w	yboink,A1		Add y boinker
	add.w	D2,A1			Add x pointer
	add.w	(A4)+,A1		Add y letter
	cmp.w	#-1,(A4)		End?
	bne.s	.noyend			Noooo
	move.l	#ylbuf,A4		Restore
.noyend	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	16(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	176(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	336(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	496(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	656(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	816(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	976(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1136(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)
	clr.w	1296(A1)
	lea	1440(A1),A1

	rept	2
	move.w	(A2)+,(A1)		Draw letter
	move.w	(A2)+,8(A1)
	move.w	(A2)+,16(A1)
	move.w	(A2)+,160(A1)
	move.w	(A2)+,168(A1)
	move.w	(A2)+,176(A1)
	move.w	(A2)+,320(A1)
	move.w	(A2)+,328(A1)
	move.w	(A2)+,336(A1)
	move.w	(A2)+,480(A1)
	move.w	(A2)+,488(A1)
	move.w	(A2)+,496(A1)
	move.w	(A2)+,640(A1)
	move.w	(A2)+,648(A1)
	move.w	(A2)+,656(A1)
	move.w	(A2)+,800(A1)
	move.w	(A2)+,808(A1)
	move.w	(A2)+,816(A1)
	move.w	(A2)+,960(A1)
	move.w	(A2)+,968(A1)
	move.w	(A2)+,976(A1)
	move.w	(A2)+,1120(A1)
	move.w	(A2)+,1128(A1)
	move.w	(A2)+,1136(A1)
	move.w	(A2)+,1280(A1)
	move.w	(A2)+,1288(A1)
	move.w	(A2)+,1296(A1)
	move.w	(A2)+,1440(A1)
	move.w	(A2)+,1448(A1)
	move.w	(A2)+,1456(A1)
	move.w	(A2)+,1600(A1)
	move.w	(A2)+,1608(A1)
	move.w	(A2)+,1616(A1)
	move.w	(A2)+,1760(A1)
	move.w	(A2)+,1768(A1)
	move.w	(A2)+,1776(A1)
	move.w	(A2)+,1920(A1)
	move.w	(A2)+,1928(A1)
	move.w	(A2)+,1936(A1)
	move.w	(A2)+,2080(A1)
	move.w	(A2)+,2088(A1)
	move.w	(A2)+,2096(A1)
	move.w	(A2)+,2240(A1)
	move.w	(A2)+,2248(A1)
	move.w	(A2)+,2256(A1)
	move.w	(A2)+,2400(A1)
	move.w	(A2)+,2408(A1)
	move.w	(A2)+,2416(A1)
	lea	2560(A1),A1
	endr
	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	16(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	176(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	336(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	496(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	656(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	816(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	976(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1136(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)
	clr.w	1296(A1)

	move.w	(A3)+,D0		Get letter
	cmp.w	#-1,(A3)		End???
	bne.s	noress			No

	lea	text,A3


noress	add.w	#24,D2			X data
	dbra	D1,norest		All letters

	mulu.w	#384,D0			Make to letter size
	lea	font,A2			Get font
	add.w	D0,A2			Add to font peeker
	add.w	count,A2		and add preshift data
	move.l	screen1,A1		Get screen address
	lea	16006(A1),A1
	add.w	yboink,A1		Add y boinker
	add.w	D2,A1			Add x pointer
	add.w	(A4)+,A1		Add y letter
	cmp.w	#-1,(A4)		End?
	bne.s	.noyend			Noooo
	move.l	#ylbuf,A4		Restore
.noyend	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)
	lea	1440(A1),A1

	rept	2
	move.w	(A2)+,(A1)		Draw letter
	move.w	(A2)+,8(A1)
	addq.l	#2,A2
	move.w	(A2)+,160(A1)
	move.w	(A2)+,168(A1)
	addq.l	#2,A2
	move.w	(A2)+,320(A1)
	move.w	(A2)+,328(A1)
	addq.l	#2,A2
	move.w	(A2)+,480(A1)
	move.w	(A2)+,488(A1)
	addq.l	#2,A2
	move.w	(A2)+,640(A1)
	move.w	(A2)+,648(A1)
	addq.l	#2,A2
	move.w	(A2)+,800(A1)
	move.w	(A2)+,808(A1)
	addq.l	#2,A2
	move.w	(A2)+,960(A1)
	move.w	(A2)+,968(A1)
	addq.l	#2,A2
	move.w	(A2)+,1120(A1)
	move.w	(A2)+,1128(A1)
	addq.l	#2,A2
	move.w	(A2)+,1280(A1)
	move.w	(A2)+,1288(A1)
	addq.l	#2,A2
	move.w	(A2)+,1440(A1)
	move.w	(A2)+,1448(A1)
	addq.l	#2,A2
	move.w	(A2)+,1600(A1)
	move.w	(A2)+,1608(A1)
	addq.l	#2,A2
	move.w	(A2)+,1760(A1)
	move.w	(A2)+,1768(A1)
	addq.l	#2,A2
	move.w	(A2)+,1920(A1)
	move.w	(A2)+,1928(A1)
	addq.l	#2,A2
	move.w	(A2)+,2080(A1)
	move.w	(A2)+,2088(A1)
	addq.l	#2,A2
	move.w	(A2)+,2240(A1)
	move.w	(A2)+,2248(A1)
	addq.l	#2,A2
	move.w	(A2)+,2400(A1)
	move.w	(A2)+,2408(A1)
	addq.l	#2,A2
	lea	2560(A1),A1
	endr
	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)

 	add.w	#192,count		Add next preshift
	cmp.w	#192*2,count		End ????	
	bne.s	endfnt

	clr.w	count			Restore, next flag
	addq.w	#1,flag

endfnt	bra	end



notr1	cmp.w	#1,flag			This rout?
	bne	notr2			Nop, must b 3

*	Rout 2

	moveq.w	#5,D1			Nr of letters
	moveq.w	#16,D2			X data

	move.l	textpek,A3		Get peeker
	move.w	(A3)+,D0		Get letter
	cmp.w	#-1,(A3)		End???
	bne.s	nores2			No

	lea	text,A3			Restore
	move.l	#text,textpek		Restore
	move.l	#ylbuf0,ylpek		Restore from 0
	move.l	#ybbuf0,ybpek		Restore from 0

nores2	mulu.w	#384,D0			Make to letter size
	lea	font,A2			Get font
	add.w	D0,A2			Add to font peeker
	add.w	count,A2		and add preshift data
	move.l	screen1,A1		Get screen address
	lea	16006(A1),A1
	add.w	yboink,A1		Add y boinker
	add.w	(A4)+,A1		Add y letter
	cmp.w	#-1,(A4)		End?
	bne.s	.noyend			Noooo
	move.l	#ylbuf,A4		Restore
.noyend	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)
	lea	1440(A1),A1

	rept	2
	addq.l	#2,A2
	move.w	(A2)+,(A1)		Draw letter
	move.w	(A2)+,8(A1)
	addq.l	#2,A2
	move.w	(A2)+,160(A1)
	move.w	(A2)+,168(A1)
	addq.l	#2,A2
	move.w	(A2)+,320(A1)
	move.w	(A2)+,328(A1)
	addq.l	#2,A2
	move.w	(A2)+,480(A1)
	move.w	(A2)+,488(A1)
	addq.l	#2,A2
	move.w	(A2)+,640(A1)
	move.w	(A2)+,648(A1)
	addq.l	#2,A2
	move.w	(A2)+,800(A1)
	move.w	(A2)+,808(A1)
	addq.l	#2,A2
	move.w	(A2)+,960(A1)
	move.w	(A2)+,968(A1)
	addq.l	#2,A2
	move.w	(A2)+,1120(A1)
	move.w	(A2)+,1128(A1)
	addq.l	#2,A2
	move.w	(A2)+,1280(A1)
	move.w	(A2)+,1288(A1)
	addq.l	#2,A2
	move.w	(A2)+,1440(A1)
	move.w	(A2)+,1448(A1)
	addq.l	#2,A2
	move.w	(A2)+,1600(A1)
	move.w	(A2)+,1608(A1)
	addq.l	#2,A2
	move.w	(A2)+,1760(A1)
	move.w	(A2)+,1768(A1)
	addq.l	#2,A2
	move.w	(A2)+,1920(A1)
	move.w	(A2)+,1928(A1)
	addq.l	#2,A2
	move.w	(A2)+,2080(A1)
	move.w	(A2)+,2088(A1)
	addq.l	#2,A2
	move.w	(A2)+,2240(A1)
	move.w	(A2)+,2248(A1)
	addq.l	#2,A2
	move.w	(A2)+,2400(A1)
	move.w	(A2)+,2408(A1)
	lea	2560(A1),A1
	endr
	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)

	move.w	(A3)+,D0		Get letter
	cmp.w	#-1,(A3)		End???
	bne.s	nore2			No

	lea	text,A3

nore2	mulu.w	#384,D0			Make to letter size
	lea	font,A2			Get font
	add.w	D0,A2			Add to font peeker
	add.w	count,A2		and add preshift data
	move.l	screen1,A1		Get screen address
	lea	16006(A1),A1
	add.w	yboink,A1		Add y boinker
	add.w	D2,A1			Add x pointer
	add.w	(A4)+,A1		Add y letter
	cmp.w	#-1,(A4)		End?
	bne.s	.noyend			Noooo
	move.l	#ylbuf,A4		Restore
.noyend	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	16(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	176(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	336(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	496(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	656(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	816(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	976(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1136(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)
	clr.w	1296(A1)
	lea	1440(A1),A1

	rept	2
	move.w	(A2)+,(A1)		Draw letter
	move.w	(A2)+,8(A1)
	move.w	(A2)+,16(A1)
	move.w	(A2)+,160(A1)
	move.w	(A2)+,168(A1)
	move.w	(A2)+,176(A1)
	move.w	(A2)+,320(A1)
	move.w	(A2)+,328(A1)
	move.w	(A2)+,336(A1)
	move.w	(A2)+,480(A1)
	move.w	(A2)+,488(A1)
	move.w	(A2)+,496(A1)
	move.w	(A2)+,640(A1)
	move.w	(A2)+,648(A1)
	move.w	(A2)+,656(A1)
	move.w	(A2)+,800(A1)
	move.w	(A2)+,808(A1)
	move.w	(A2)+,816(A1)
	move.w	(A2)+,960(A1)
	move.w	(A2)+,968(A1)
	move.w	(A2)+,976(A1)
	move.w	(A2)+,1120(A1)
	move.w	(A2)+,1128(A1)
	move.w	(A2)+,1136(A1)
	move.w	(A2)+,1280(A1)
	move.w	(A2)+,1288(A1)
	move.w	(A2)+,1296(A1)
	move.w	(A2)+,1440(A1)
	move.w	(A2)+,1448(A1)
	move.w	(A2)+,1456(A1)
	move.w	(A2)+,1600(A1)
	move.w	(A2)+,1608(A1)
	move.w	(A2)+,1616(A1)
	move.w	(A2)+,1760(A1)
	move.w	(A2)+,1768(A1)
	move.w	(A2)+,1776(A1)
	move.w	(A2)+,1920(A1)
	move.w	(A2)+,1928(A1)
	move.w	(A2)+,1936(A1)
	move.w	(A2)+,2080(A1)
	move.w	(A2)+,2088(A1)
	move.w	(A2)+,2096(A1)
	move.w	(A2)+,2240(A1)
	move.w	(A2)+,2248(A1)
	move.w	(A2)+,2256(A1)
	move.w	(A2)+,2400(A1)
	move.w	(A2)+,2408(A1)
	move.w	(A2)+,2416(A1)
	lea	2560(A1),A1
	endr
	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	16(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	176(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	336(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	496(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	656(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	816(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	976(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1136(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)
	clr.w	1296(A1)

	move.w	(A3)+,D0		Get letter
	cmp.w	#-1,(A3)		End???
	bne.s	nore21			No

	lea	text,A3

nore21	add.w	#24,D2			X data
	dbra	D1,nore2		All letters

 	add.w	#192,count		Add next preshift
	cmp.w	#192*2,count		End ????	
	bne.s	endfn2

	clr.w	count			Restore, next flag
	addq.w	#1,flag

endfn2	bra	end


*	Rout 3

notr2	moveq.w	#5,D1			Nr of letters
	moveq.w	#8,D2			X data

	move.l	textpek,A3		Get peeker
	move.w	(A3)+,D0		Get letter
	cmp.w	#-1,(A3)		End???
	bne.s	nores3			No

	lea	textpek,A3		Restore
	move.l	#text,textpek		Restore
	move.l	#ylbuf0,ylpek		Restore from 0
	move.l	#ybbuf0,ybpek		Restore from 0

nores3	mulu.w	#384,D0			Make to letter size
	lea	font,A2			Get font
	add.w	D0,A2			Add to font peeker
	add.w	count,A2		and add preshift data
	move.l	screen1,A1		Get screen address
	lea	16006(A1),A1
	add.w	yboink,A1		Add y boinker
	add.w	(A4)+,A1		Add y letter
	cmp.w	#-1,(A4)		End?
	bne.s	.noyend			Noooo
	move.l	#ylbuf,A4		Restore
.noyend	clr.w	(A1)			Erase
	clr.w	160(A1)
	clr.w	320(A1)
	clr.w	480(A1)
	clr.w	640(A1)
	clr.w	800(A1)
	clr.w	960(A1)
	clr.w	1120(A1)
	clr.w	1280(A1)
	lea	1440(A1),A1

	rept	2
	addq.l	#4,A2
	move.w	(A2)+,(A1)
	addq.l	#4,A2
	move.w	(A2)+,160(A1)
	addq.l	#4,A2
	move.w	(A2)+,320(A1)
	addq.l	#4,A2
	move.w	(A2)+,480(A1)
	addq.l	#4,A2
	move.w	(A2)+,640(A1)
	addq.l	#4,A2
	move.w	(A2)+,800(A1)
	addq.l	#4,A2
	move.w	(A2)+,960(A1)
	addq.l	#4,A2
	move.w	(A2)+,1120(A1)
	addq.l	#4,A2
	move.w	(A2)+,1280(A1)
	addq.l	#4,A2
	move.w	(A2)+,1440(A1)
	addq.l	#4,A2
	move.w	(A2)+,1600(A1)
	addq.l	#4,A2
	move.w	(A2)+,1760(A1)
	addq.l	#4,A2
	move.w	(A2)+,1920(A1)
	addq.l	#4,A2
	move.w	(A2)+,2080(A1)
	addq.l	#4,A2
	move.w	(A2)+,2240(A1)
	addq.l	#4,A2
	move.w	(A2)+,2400(A1)
	lea	2560(A1),A1
	endr
	clr.w	(A1)			Erase
	clr.w	160(A1)
	clr.w	320(A1)
	clr.w	480(A1)
	clr.w	640(A1)
	clr.w	800(A1)
	clr.w	960(A1)
	clr.w	1120(A1)
	clr.w	1280(A1)

	move.w	(A3)+,D0		Get letter
	cmp.w	#-1,(A3)		End???
	bne.s	nore3			No

	lea	text,A3

nore3	mulu.w	#384,D0			Make to letter size
	lea	font,A2			Get font
	add.w	D0,A2			Add to font peeker
	add.w	count,A2		and add preshift data
	move.l	screen1,A1		Get screen address
	lea	16006(A1),A1
	add.w	yboink,A1		Add y boinker
	add.w	D2,A1			Add x pointer
	add.w	(A4)+,A1		Add y letter
	cmp.w	#-1,(A4)		End?
	bne.s	.noyend			Noooo
	move.l	#ylbuf,A4		Restore
.noyend	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	16(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	176(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	336(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	496(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	656(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	816(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	976(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1136(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)
	clr.w	1296(A1)
	lea	1440(A1),A1

	rept	2
	move.w	(A2)+,(A1)		Draw letter
	move.w	(A2)+,8(A1)
	move.w	(A2)+,16(A1)
	move.w	(A2)+,160(A1)
	move.w	(A2)+,168(A1)
	move.w	(A2)+,176(A1)
	move.w	(A2)+,320(A1)
	move.w	(A2)+,328(A1)
	move.w	(A2)+,336(A1)
	move.w	(A2)+,480(A1)
	move.w	(A2)+,488(A1)
	move.w	(A2)+,496(A1)
	move.w	(A2)+,640(A1)
	move.w	(A2)+,648(A1)
	move.w	(A2)+,656(A1)
	move.w	(A2)+,800(A1)
	move.w	(A2)+,808(A1)
	move.w	(A2)+,816(A1)
	move.w	(A2)+,960(A1)
	move.w	(A2)+,968(A1)
	move.w	(A2)+,976(A1)
	move.w	(A2)+,1120(A1)
	move.w	(A2)+,1128(A1)
	move.w	(A2)+,1136(A1)
	move.w	(A2)+,1280(A1)
	move.w	(A2)+,1288(A1)
	move.w	(A2)+,1296(A1)
	move.w	(A2)+,1440(A1)
	move.w	(A2)+,1448(A1)
	move.w	(A2)+,1456(A1)
	move.w	(A2)+,1600(A1)
	move.w	(A2)+,1608(A1)
	move.w	(A2)+,1616(A1)
	move.w	(A2)+,1760(A1)
	move.w	(A2)+,1768(A1)
	move.w	(A2)+,1776(A1)
	move.w	(A2)+,1920(A1)
	move.w	(A2)+,1928(A1)
	move.w	(A2)+,1936(A1)
	move.w	(A2)+,2080(A1)
	move.w	(A2)+,2088(A1)
	move.w	(A2)+,2096(A1)
	move.w	(A2)+,2240(A1)
	move.w	(A2)+,2248(A1)
	move.w	(A2)+,2256(A1)
	move.w	(A2)+,2400(A1)
	move.w	(A2)+,2408(A1)
	move.w	(A2)+,2416(A1)
	lea	2560(A1),A1
	endr
	clr.w	(A1)			Erase
	clr.w	8(A1)
	clr.w	16(A1)
	clr.w	160(A1)
	clr.w	168(A1)
	clr.w	176(A1)
	clr.w	320(A1)
	clr.w	328(A1)
	clr.w	336(A1)
	clr.w	480(A1)
	clr.w	488(A1)
	clr.w	496(A1)
	clr.w	640(A1)
	clr.w	648(A1)
	clr.w	656(A1)
	clr.w	800(A1)
	clr.w	808(A1)
	clr.w	816(A1)
	clr.w	960(A1)
	clr.w	968(A1)
	clr.w	976(A1)
	clr.w	1120(A1)
	clr.w	1128(A1)
	clr.w	1136(A1)
	clr.w	1280(A1)
	clr.w	1288(A1)
	clr.w	1296(A1)

	move.w	(A3)+,D0		Get letter
	cmp.w	#-1,(A3)		End???
	bne.s	nore31			No

	lea	text,A3

nore31	add.w	#24,D2			X data
	dbra	D1,nore3		All letters

	mulu.w	#384,D0			Make to letter size
	lea	font,A2			Get font
	add.w	D0,A2			Add to font peeker
	add.w	count,A2		and add preshift data
	move.l	screen1,A1		Get screen address
	lea	16006(A1),A1
	add.w	yboink,A1		Add y boinker
	add.w	D2,A1			Add x pointer
	add.w	(A4)+,A1		Add y letter
	cmp.w	#-1,(A4)		End?
	bne.s	.noyend			Noooo
	move.l	#ylbuf,A4		Restore
.noyend	clr.w	(A1)			Erase
	clr.w	160(A1)
	clr.w	320(A1)
	clr.w	480(A1)
	clr.w	640(A1)
	clr.w	800(A1)
	clr.w	960(A1)
	clr.w	1120(A1)
	clr.w	1280(A1)
	lea	1440(A1),A1

	rept	2
	move.w	(A2)+,(A1)		Draw letter
	addq.l	#4,A2
	move.w	(A2)+,160(A1)
	addq.l	#4,A2
	move.w	(A2)+,320(A1)
	addq.l	#4,A2
	move.w	(A2)+,480(A1)
	addq.l	#4,A2
	move.w	(A2)+,640(A1)
	addq.l	#4,A2
	move.w	(A2)+,800(A1)
	addq.l	#4,A2
	move.w	(A2)+,960(A1)
	addq.l	#4,A2
	move.w	(A2)+,1120(A1)
	addq.l	#4,A2
	move.w	(A2)+,1280(A1)
	addq.l	#4,A2
	move.w	(A2)+,1440(A1)
	addq.l	#4,A2
	move.w	(A2)+,1600(A1)
	addq.l	#4,A2
	move.w	(A2)+,1760(A1)
	addq.l	#4,A2
	move.w	(A2)+,1920(A1)
	addq.l	#4,A2
	move.w	(A2)+,2080(A1)
	addq.l	#4,A2
	move.w	(A2)+,2240(A1)
	addq.l	#4,A2
	move.w	(A2)+,2400(A1)
	addq.l	#4,A2
	lea	2560(A1),A1
	endr
	clr.w	(A1)			Erase
	clr.w	160(A1)
	clr.w	320(A1)
	clr.w	480(A1)
	clr.w	640(A1)
	clr.w	800(A1)
	clr.w	960(A1)
	clr.w	1120(A1)
	clr.w	1280(A1)

 	add.w	#192,count		Add next preshift
	cmp.w	#192*2,count		End ????	
	bne.s	end

	clr.w	count			Restore count and flag
	clr.w	flag
	addq.l	#2,textpek		Forward in text buf
	move.l	textpek,A3		Get peeker
	cmp.w	#-1,(A3)		End???
	bne.s	end			No

	move.l	#text,textpek		Restore
	move.l	#ylbuf0,ylpek		Restore from 0
	move.l	#ybbuf0,ybpek		Restore from 0

end	move.l	ybpek,A0		Get peeker
	move.w	(A0)+,yboink		Into buffer
	addq.l	#2,ybpek		Forward
	cmp.w	#-1,(A0)		End??
	bne.s	noybend
	move.l	#ybbuf,ybpek		Restore

noybend	addq.l	#2,ylpek		Forward in Y dist buf
	move.l	ylpek,A3		Get peeker
	cmp.b	#-1,(A3)		End???
	bne.s	.noyen			No
	move.l	#ylbuf,ylpek		Restore

.noyen	rept	128*5			WAIT!!! TOO MUCH VBL TIME LEFT!!! FUCK!!!!
	nop
	endr

	movem.l	(sp)+,D0-A5
	rte				Byeeeeeeeeee

*	SUBROUTS

*	Sprite drawing

sprite	move.l	screen1,A0		Draw reg
	lea	9600(A0),A0		Don't disturb the Z dister
	mulu.w	#160,D1			Y add reg
	move.w	D0,D3			Work
	and.w	#%1111111111110000,D3	X add reg
	sub.w	D3,D0			Right shift reg (D0)
	lsr.w	#1,D3			Finish calculations
	add.w	D1,A0			Add to draw reg
	add.w	D3,A0			Add to draw reg again
	lsl.w	#7,D0

	add.w	D0,A1

	move.l	A0,(A2)+		Fill erase buffer

	rept	4
	move.l	(A1)+,D0		Draw sprite
	or.l	D0,(A0)
	move.l	(A1)+,D0
	or.l	D0,8(A0)
	move.l	(A1)+,D0
	or.l	D0,160(A0)
	move.l	(A1)+,D0
	or.l	D0,168(A0)
	move.l	(A1)+,D0
	or.l	D0,320(A0)
	move.l	(A1)+,D0
	or.l	D0,328(A0)
	move.l	(A1)+,D0
	or.l	D0,480(A0)
	move.l	(A1)+,D0
	or.l	D0,488(A0)
	lea	640(A0),A0		Down
	endr
	rts

*	Calculate and save positions

savepos	move.w	(A0),D0			Get x
	move.w	2(A0),D1		Get y
	move.w	D0,D3			Work regs
	move.w	D1,D4

	move.w	(A4)+,D5
	addq.w	#2,D5			Make depth calculations
	add.w	D2,D5			(No comments here, I.E./S.O.T.E. might steal my id‚a!!)
	sub.w	#159,D3
	sub.w	#124,D4
	muls.w	D2,D3
	muls.w	D2,D4
	divs.w	D5,D3
	divs.w	D5,D4
	and.l	#$FFFF,D3
	sub.w	D3,D0
	sub.w	D4,D1

	move.w	D0,(A6)+		Save positions
	move.w	D1,(A6)+

	bra	aftsav			Back to counting

*	Oscilloscope menu gfx operations

VAn	lea	gfxzx,A2		Read reg
	lea	480(A2),A2		Doown
	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12486(A0),A0		Down, bp 4
	lea	12486(A1),A1
	rept	9
	move.w	(A2),(A0)			Draw 1 lajn
	move.w	(A2),(A1)
	move.w	2(A2),8(A0)			Draw 1 lajn
	move.w	2(A2),8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	lea	80(A2),A2
	endr
	bra	gloop
VBn	lea	gfxzx,A2		Read reg
	lea	480+4(A2),A2		Doown
	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12486+16(A0),A0		Down, bp 4
	lea	12486+16(A1),A1
	rept	9
	move.w	(A2),(A0)			Draw 1 lajn
	move.w	(A2),(A1)
	move.w	2(A2),8(A0)			Draw 1 lajn
	move.w	2(A2),8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	lea	80(A2),A2
	endr
	bra	gloop
VCn	lea	gfxzx,A2		Read reg
	lea	480+8(A2),A2		Doown
	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12486+32(A0),A0		Down, bp 4
	lea	12486+32(A1),A1
	rept	9
	move.w	(A2),(A0)			Draw 1 lajn
	move.w	(A2),(A1)
	move.w	2(A2),8(A0)			Draw 1 lajn
	move.w	2(A2),8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	lea	80(A2),A2
	endr
	bra	gloop

VAf	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12486(A0),A0		Down, bp 4
	lea	12486(A1),A1
	rept	9
	clr.w	(A0)			Clr 1 line
	clr.w	(A1)
	clr.w	8(A0)
	clr.w	8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	endr
	bra	gloop
VBf	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12486+16(A0),A0		Down, bp 4
	lea	12486+16(A1),A1
	rept	9
	clr.w	(A0)			Clr 1 line
	clr.w	(A1)
	clr.w	8(A0)
	clr.w	8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	endr
	bra	gloop
VCf	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12486+32(A0),A0		Down, bp 4
	lea	12486+32(A1),A1
	rept	9
	clr.w	(A0)			Clr 1 line
	clr.w	(A1)
	clr.w	8(A0)
	clr.w	8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	endr
	bra	gloop

FAn	lea	gfxzx,A2		Read reg
	lea	508(A2),A2		Doown
	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12598(A0),A0		Down, bp 4
	lea	12598(A1),A1
	rept	9
	move.w	(A2),(A0)			Draw 1 lajn
	move.w	(A2),(A1)
	move.w	2(A2),8(A0)			Draw 1 lajn
	move.w	2(A2),8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	lea	80(A2),A2
	endr
	bra	gloop
FBn	lea	gfxzx,A2		Read reg
	lea	508+4(A2),A2		Doown
	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12598+16(A0),A0		Down, bp 4
	lea	12598+16(A1),A1
	rept	9
	move.w	(A2),(A0)			Draw 1 lajn
	move.w	(A2),(A1)
	move.w	2(A2),8(A0)			Draw 1 lajn
	move.w	2(A2),8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	lea	80(A2),A2
	endr
	bra	gloop
FCn	lea	gfxzx,A2		Read reg
	lea	508+8(A2),A2		Doown
	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12598+32(A0),A0		Down, bp 4
	lea	12598+32(A1),A1
	rept	9
	move.w	(A2),(A0)			Draw 1 lajn
	move.w	(A2),(A1)
	move.w	2(A2),8(A0)			Draw 1 lajn
	move.w	2(A2),8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	lea	80(A2),A2
	endr
	bra	gloop

FAf	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12598(A0),A0		Down, bp 4
	lea	12598(A1),A1
	rept	9
	clr.w	(A0)			Clr 1 line
	clr.w	(A1)
	clr.w	8(A0)
	clr.w	8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	endr
	move.b	#0,Adat
	bra	gloop
FBf	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12598+16(A0),A0		Down, bp 4
	lea	12598+16(A1),A1
	rept	9
	clr.w	(A0)			Clr 1 line
	clr.w	(A1)
	clr.w	8(A0)
	clr.w	8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	endr
	move.b	#1,Bdat
	bra	gloop
FCf	move.l	screen1,A0		Get screen addresses
	move.l	screen2,A1
	lea	12598+32(A0),A0		Down, bp 4
	lea	12598+32(A1),A1
	rept	9
	clr.w	(A0)			Clr 1 line
	clr.w	(A1)
	clr.w	8(A0)
	clr.w	8(A1)
	lea	320(A0),A0
	lea	320(A1),A1
	endr
	move.b	#2,Cdat
	bra	gloop

*	DATA

savessp	dc.l	0
savesp	dc.l	0
	ds.l	50
stack	dc.l	0
rez	dc.w	0
phys	dc.l	0
log	dc.l	0
wait	dc.w	0
savebuf	ds.l	10
screen1	dc.l	$000f4000
screen2	dc.l	$000e4000
pal	dc.w	$000,$377,$503,$705,$776,$776,$776,$776,$070,$377,$156,$035,$776,$776,$776,$776 
line	dc.w	0
musch	dc.w	1
gfxzx	incbin	dddmenu.gfx
musix	dc.l	musix0

musix0	incbin	madmax12.bin
	even
musix1	incbin	madmax13.bin
	even

palsave	ds.l	8
ssr	dc.w	0

*	Zdist

gfx	incbin	dusch.gfx
zpeek	dc.l	zdata
zdata	dc.w	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5
	dc.w	6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,11
	dc.w	12,12,12,12,12,12,12,12,11,11,11,11,11,11,11,10,10,10,10,10,10,9,9,9,9,9,9
	dc.w	8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2
	dc.w	1,1,1,1,1,1,1
	dc.w	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5
	dc.w	6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,11
	dc.w	12,12,12,12,12,12,12,12,11,11,11,11,11,11,11,10,10,10,10,10,10,9,9,9,9,9,9
	dc.w	8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2
	dc.w	1,1,1,1,1,1,1
	dc.w	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5
	dc.w	6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,11
	dc.w	12,12,12,12,12,12,12,12,11,11,11,11,11,11,11,10,10,10,10,10,10,9,9,9,9,9,9
	dc.w	8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2
	dc.w	1,1,1,1,1,1,1
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,0,1,1,1,2,2,2,3,3,4,4,5,6,7,8,9,10,11,12,11,10,9,8,7,6,5,4,4,3,3,2,2,2
	dc.w	0,0,0,0,1,1,1,2,2,2,3,3,4,4,5,6,7,8,9,10,11,12,11,10,9,8,7,6,5,4,4,3,3,2,2,2
	dc.w	0,0,0,0,1,1,1,2,2,2,3,3,4,4,5,6,7,8,9,10,11,12,11,10,9,8,7,6,5,4,4,3,3,2,2,2
	dc.w	0,0,0,0,1,1,1,2,2,2,3,3,4,4,5,6,7,8,9,10,11,12,11,10,9,8,7,6,5,4,4,3,3,2,2,2
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,0,1,1,1,2,2,2,3,3,4,4,5,6,7,8,9,10,11,12,11,10,9,8,7,6,5,4,4,3,3,2,2,2
	dc.w	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5
	dc.w	6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,11
	dc.w	12,12,12,12,12,12,12,12,11,11,11,11,11,11,11,10,10,10,10,10,10,9,9,9,9,9,9
	dc.w	8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2
	dc.w	1,1,1,1,1,1,1
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5
	dc.w	6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,11
	dc.w	12,12,12,12,12,12,12,12,11,11,11,11,11,11,11,10,10,10,10,10,10,9,9,9,9,9,9
	dc.w	8,8,8,8,8,8,7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2
	dc.w	1,1,1,1,1,1,1
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,0,0,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12
	dc.w	0,0,0,0,1,1,1,2,2,3,4,5,6,7,8,9,10,10,11,11,11,12,12,12,12
	dc.w	11,11,11,10,10,9,8,7,6,5,4,3,2,2,1,1,1
	dc.w	-1

*	Sprite data

buf1	dc.l	buffer1
buf2	dc.l	buffer2
buffer1	dcb.l	12,$f4000
buffer2	dcb.l	12,$f4000

cpos1	dc.l	curve+224
cpos2	dc.l	curve+208
cpos3	dc.l	curve+192
cpos4	dc.l	curve+160
cpos5	dc.l	curve+144
cpos6	dc.l	curve+128
cpos7	dc.l	curve+112
cpos8	dc.l	curve+96
cpos9	dc.l	curve+64
cpos10	dc.l	curve+48
cpos11	dc.l	curve+32
cpos12	dc.l	curve+16

ypos1	dc.l	ycurve
ypos2	dc.l	ycurve+8
ypos3	dc.l	ycurve+16
ypos4	dc.l	ycurve+32
ypos5	dc.l	ycurve+40
ypos6	dc.l	ycurve+48
ypos7	dc.l	ycurve+56
ypos8	dc.l	ycurve+64
ypos9	dc.l	ycurve+80
ypos10	dc.l	ycurve+88
ypos11	dc.l	ycurve+96
ypos12	dc.l	ycurve+100

ycurve	dc.w	0,0,0,0,0,1,1,1,1,2,2,2,3,4,5,6,8,10,12,13,14,15,16,17,17,18,18,18,19,19,19,19
	dc.w	18,18,18,17,17,16,15,14,13,12,10,8,6,4,3,2,2,2,1,1,1,1,-1
curve	incbin	intrcurv.buf

T	incbin	t.gfx
H	incbin	h.gfx
I	incbin	i.gfx
L	incbin	l.gfx
E	incbin	e.gfx
G	incbin	g.gfx
A	incbin	a.gfx
M	incbin	m.gfx
	even

*	Star data

starpos	dc.w	12,4,10,60,0,0,95,10,12,117,7,14,143,12,2,196,2,1,265,8,14,310,13,13,319,2,1,45,6,12,187,2,17,291,4,9
	dc.w	2,234,2,30,240,14,65,250,12,137,245,6,173,242,15,186,249,30,285,248,22,300,243,27,23,240,1,89,249,31,319,248,16,14,248,1
	dc.w	10,20,11,4,50,23,7,70,3,6,100,30,4,130,18,3,170,2,7,200,11,9,230,5,4,45,14,2,133,14,8,201,5,3,249,25
	dc.w	310,10,2,315,46,20,312,87,10,313,124,30,315,155,22,319,173,8,317,211,15,312,240,30,319,249,12,164,248,31,223,242,21,12,244,12
starddd	dc.w	11,5,3,9,0,1,3,6,13,5
	dc.w	2,4,9,7,12,15,6,8,6,14
	dc.w	13,2,4,6,1,6,8,9,0,4
	dc.w	10,9,8,5,11,1,4,8,12,6
	dc.w	15,2,4,1,8,7,0,7,3,5
starf	ds.b	6144
stardot	dc.w	%1000000000000000
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
starpek	dc.l	starf
starc	dc.w	32
sbuf1	dc.l	suffer1
sbuf2	dc.l	suffer2
suffer1	dcb.l	48,$f4000
suffer2	dcb.l	48,$f4000

*	Preshift data

font	incbin	dufont.fnt
text	incbin	dddemo.stx
	
count	dc.w	0
flag	dc.w	0
textpek	dc.l	text
yboink	dc.w	0
ybpek	dc.l	ybbuf0
ybbuf0	dcb.w	770,0
ybbuf	dc.w	0,0,0,1,1,2,2,2,3,3,4,5,6,8,10,12,14,17,20,23,26
	dc.w	28,30,32,34,35,36,37,37,38,38,38,39,39,39,39,40,40,40,40,40
	dc.w	39,39,39,39,38,38,38,37,37,36,35,34,32,30,28,26,23,20,17,14
	dc.w	12,10,8,6,5,4,3,3,2,2,2,1,1,1
	dc.w	-1

ylpek	dc.l	ylbuf0
ylbuf0	dcb.w	380,0
ylbuf	dc.w	0,1*160,2*160,4*160,5*160,4*160,2*160,1*160
	dc.w	0,1*160,2*160,4*160,5*160,4*160,2*160,1*160
	dc.w	0*160,0*160,1*160,2*160,4*160,5*160,6*160,6*160,5*160,4*160,2*160,1*160
	dc.w	0*160,0*160,1*160,2*160,4*160,5*160,6*160,6*160,5*160,4*160,2*160,1*160
	dc.w	0,0,0,1*160,1*160,2*160,3*160,5*160,6*160,7*160,7*160,8*160
	dc.w	8*160,8*160,7*160,7*160,6*160,5*160,3*160,2*160,1*160,1*160
	dc.w	0*160,0*160,1*160,2*160,4*160,5*160,6*160,6*160,5*160,4*160,2*160,1*160
	dc.w	0*160,0*160,1*160,2*160,4*160,5*160,6*160,6*160,5*160,4*160,2*160,1*160
	dc.w	0,1*160,2*160,4*160,5*160,4*160,2*160,1*160
	dc.w	0,1*160,2*160,4*160,5*160,4*160,2*160,1*160
	dc.w	-1

*	Raster dealing

rastbuf	dc.w	$777,$776,$775,$774,$773,$772,$770,$671,$572,$473
	dc.w	$374,$275,$176,$077,$167,$257,$347,$437,$527,$617
	dc.w	$707,$716,$725,$725,$734,$743,$752,$761,$770,$761
	dc.w	$752,$743,$734,$734,$725,$716,$707,$607,$507,$407
	dc.w	$307,$207,$107,$007,$017,$027,$037,$047,$057,$067
	dc.w	$077,$176,$275,$374,$473,$572,$671,$770,$760,$750
rastpek	dc.l	rastadd
rastadd	dc.w	0,0,0,0,0,2,2,2,2,4,4,4,6,6,8,10,12,16,20
	dc.w	24,28,30,32,34,36,36,38,38,38,38,40,40,40,40,40
	dc.w	38,38,38,38,36,36,34,32,30,28,24
	dc.w	20,16,12,10,8,6,6,4,4,4,4,2,2,2,2,-1
rastdat	dc.w	0

iqrast	dc.w	$777,$776,$775,$774,$773,$772,$771,$770
	dc.w	$670,$570,$470,$370,$270,$170,$070,$060
iqgfx	dc.w	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	dc.w	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,-1
	dc.w	00,00,00,00,00,00,00,00,00,00,00,00,00,00,-1,-1
	dc.w	00,00,00,00,00,00,00,00,00,00,00,00,00,-1,-1,-1
	dc.w	00,00,00,00,00,00,00,00,00,00,00,00,-1,-1,-1,-1
	dc.w	00,00,00,00,00,00,00,00,00,00,00,-1,-1,-1,-1,-1
	dc.w	00,00,00,00,00,00,00,00,00,00,-1,-1,-1,-1,-1,-1
	dc.w	00,00,00,00,00,00,00,00,00,-1,-1,-1,-1,-1,-1,-1
	dc.w	00,00,00,00,00,00,00,00,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	00,00,00,00,00,00,00,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	00,00,00,00,00,00,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	00,00,00,00,00,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	00,00,00,00,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	00,00,00,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	00,00,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	00,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1

*	Oscilloscope

oscillo	incbin	oscillo.buf
Adat	dc.b	0
Bdat	dc.b	0
Cdat	dc.b	0
oscstat	dc.b	%00111111
obuf1	dc.l	ouffer1
obuf2	dc.l	ouffer2
ouffer1	dcb.l	64,$f4000
ouffer2	dcb.l	64,$f4000
oscdata	ds.b	64
plotdot	dc.w	%1100000000000000
	dc.w	%0110000000000000
	dc.w	%0011000000000000
	dc.w	%0001100000000000
	dc.w	%0000110000000000
	dc.w	%0000011000000000
	dc.w	%0000001100000000
	dc.w	%0000000110000000
	dc.w	%0000000011000000
	dc.w	%0000000001100000
	dc.w	%0000000000110000
	dc.w	%0000000000011000
	dc.w	%0000000000001100
	dc.w	%0000000000000110
	dc.w	%0000000000000011
	dc.w	%0000000000000001
oscrast	dc.w	$100,$300,$500,$700
	dc.w	$710,$730,$750,$760,$770
	dc.w	$772,$774,$776,$777
	dc.w	$677,$577,$477,$277,$177
	dc.w	$077,$057,$037,$027,$017
	dc.w	$007,$006,$005,$004,$002,$001

* GRAV Battles..


	clr.l	-(sp)		* set up the environment
	move.w	#$20,-(sp)
	trap	#1		* supervisor mode
	addq.l	#6,sp
	MOVE.B	$484,OLDKEY
	move.b	#0,$484
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	cmp.l	#$78000,d0
	bgt	moremeg
	move.l	#$78000,d0
moremeg	move.l	d0,physic
	sub.l	#$8000,d0
	move.l	d0,back
	sub.l	#$8000,d0
	move.l	d0,back2
	add.l	#$10000,d0
	move.w	#0,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	pea	palette
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#$22,-(sp)
	trap	#14
	addq.l	#2,sp
	lea	joy,a1
	movea.l	d0,a0
	move.l	a1,$18(a0)
	lea	$fffc00,a1
jloop	move.b	(a1),d1
	btst	#1,d1
	beq	jloop
	move.b	#$14,2(a1)
	bsr	playsam
title	move.w	#19,manon		* title page
	move.b	#%11111,flags
setup	bsr	cls			* clear the screen
	lea	titread+2,a6
	lea	str1,a5
	lea	youdat,a4
	bsr	dotbits			* put p1s bits in text
	lea	titread+23,a6
	lea	str5,a5
	lea	himdat,a4
	bsr	dotbits			* put p2s bits in text
	lea	edbult,a0
	lea	str2,a1
	move.w	bumpbul,d0
	mulu.w	#6,d0
	lea	(a1,d0.w),a1
	moveq	#5,d1
bblp	move.b	(a1)+,(a0)+
	dbra.w	d1,bblp
	lea	edyout,a0
	lea	str3,a1
	move.w	bumpdam,d0
	mulu.w	#6,d0
	lea	(a1,d0.w),a1
	moveq	#5,d1
eylp	move.b	(a1)+,(a0)+
	dbra.w	d1,eylp
	lea	titext,a1
	bsr	domstr		* put the title text
	lea	cursdat,a1
	move.w	manon,d0
	move.b	d0,1(a1)
	move.b	d0,5(a1)
	bsr	domstr
	bsr	swap
	bra	wjoy2
wjoy	bclr	#4,flags		* work the title text
wjoy2	btst	#0,joy1
	beq	notcup
	btst	#0,flags
	bne	notcup2
	bset	#0,flags
	cmp.w	#8,manon
	beq	notcup2
	sub.w	#1,manon
	cmp.w	#17,manon
	blt	setup
	cmp.w	#20,manon
	beq	upto19
	bgt	setup
	move.w	#17,manon
	bra	setup
upto19	lea	cursdat,a0
	move.b	#13,(a0)
	move.b	#25,4(a0)
	move.w	#19,manon
	bra	setup
notcup	bclr	#0,flags
notcup2	btst	#1,joy1
	beq	notcdn
	btst	#1,flags
	bne	notcdn2
	bset	#1,flags
	cmp.w	#22,manon
	beq	notcdn2
	add.w	#1,manon
	cmp.w	#17,manon
	ble	setup
	cmp.w	#20,manon
	bgt	setup
	beq	down21
	move.w	#19,manon
	bra	setup
down21	lea	cursdat,a0
	move.b	#8,(a0)
	move.b	#32,4(a0)
	move.w	#21,manon
	bra	setup
notcdn	bclr	#1,flags
notcdn2	btst	#2,joy1
	beq	notchl
	btst	#2,flags
	bne	notchl2
	bset	#2,flags
	lea	youdat,a0
	bra	chr
notchl	bclr	#2,flags
notchl2	btst	#3,joy1
	beq	notchr
	btst	#3,flags
	bne	notchr2
	bset	#3,flags
	lea	himdat,a0
chr	cmp.w	#9,manon
	blt	shtyp
	beq	wt1
	cmp.w	#11,manon
	blt	wht1
	beq	wr1
	cmp.w	#13,manon
	blt	wt2
	beq	wht2
	cmp.w	#15,manon
	blt	wr2
	beq	armrit
	cmp.w	#17,manon
	blt	thrusty
	beq	turny
	cmp.w	#21,manon
	bgt	edgeyou
	beq	edgebul
	bra	setup
edgeyou	add.w	#1,bumpdam
	cmp.w	#4,bumpdam
	blt	setup
	move.w	#0,bumpdam
	bra	setup
edgebul	add.w	#1,bumpbul
	cmp.w	#3,bumpbul
	blt	setup
	move.w	#0,bumpbul
	bra	setup
thrusty	sub.w	#1,10(a0)
	bcc	setup
	move.w	#2,10(a0)
	bra	setup
turny	add.w	#2,12(a0)
	cmp.w	#10,12(a0)
	blt	setup
	move.w	#4,12(a0)
	bra	setup
armrit	add.w	#1,30(a0)
	cmp.w	#5,30(a0)
	blt	setup
	move.w	#0,30(a0)
	bra	setup
wht1	lea	50(a0),a0
whtr1	move.w	(a0),d0
	divu.w	#3,d0
	move.w	d0,d1
	swap	d0
	add.w	#1,d0
	cmp.w	#3,d0
	blt	okd01
	move.w	#0,d0
okd01	mulu.w	#3,d1
	add.w	d1,d0
	move.w	d0,(a0)
	bra	setup
wr1	lea	48(a0),a0
wrr1	sub.w	#1,(a0)
	bne	setup
	move.w	#3,(a0)
	bra	setup
wht2	lea	58(a0),a0
	bra	whtr1
wr2	lea	56(a0),a0
	bra	wrr1
shtyp	sub.w	#1,64(a0)
	bcc	setup
	move.w	#1,64(a0)
	bra	setup
wt1	lea	50(a0),a0
wtr1	move.w	(a0),d0
	and.l	#$ffff,d0
	divu.w	#3,d0
	move.w	d0,d1
	swap	d0
	subq.w	#1,d1
	bcc	okd11
	moveq.w	#1,d1
okd11	mulu.w	#3,d1
	add.w	d0,d1
	move.w	d1,(a0)
	bra	setup
wt2	lea	58(a0),a0
	bra	wtr1
notchr	bclr	#3,flags
notchr2	btst	#7,joy1
	beq	wjoy
	btst	#4,flags
	bne	wjoy2
	cmp.w	#19,manon
	bne	wjoy2
	bra	copyit
dotbits	move.w	64(a4),d0		* put the details in a string
	mulu.w	#6,d0
	lea	0(a5),a3
	bsr	copstr
	lea	30(a6),a6
	lea	6*2(a5),a3
	move.w	50(a4),d0
	and.l	#$ffff,d0
	divu.w	#3,d0
	mulu.w	#6,d0
	bsr	copstr
	lea	30(a6),a6
	lea	6*4(a5),a3
	move.w	50(a4),d0
	and.l	#$ffff,d0
	divu.w	#3,d0
	swap	d0
	mulu.w	#6,d0
	bsr	copstr
	lea	30(a6),a6
	lea	6*12(a5),a3
	moveq.w	#3,d0
	sub.w	48(a4),d0
	mulu.w	#6,d0
	bsr	copstr
	
	lea	30(a6),a6
	lea	6*2(a5),a3
	move.w	58(a4),d0
	and.l	#$ffff,d0
	divu.w	#3,d0
	mulu.w	#6,d0
	bsr	copstr
	lea	30(a6),a6
	lea	6*4(a5),a3
	move.w	58(a4),d0
	and.l	#$ffff,d0
	divu.w	#3,d0
	swap	d0
	mulu.w	#6,d0
	bsr	copstr
	lea	30(a6),a6
	lea	6*12(a5),a3
	moveq.w	#3,d0
	sub.w	56(a4),d0
	mulu.w	#6,d0
	bsr	copstr
	
	lea	30(a6),a6
	lea	6*7(a5),a3
	move.w	30(a4),d0
	mulu.w	#6,d0
	bsr	copstr
	
	lea	30(a6),a6
	lea	6*12(a5),a3
	move.w	#2,d0
	sub.w	10(a4),d0
	mulu.w	#6,d0
	bsr	copstr
	lea	30(a6),a6
	lea	6*12(a5),a3
	move.w	12(a4),d0
	lsr.w	#1,d0
	subq.w	#2,d0
	mulu.w	#6,d0
	bsr	copstr
	rts
copstr	moveq.w	#5,d1
	lea	(a3,d0.w),a2
copstrl	move.b	(a2,d1.w),(a6,d1.w)
	dbra.w	d1,copstrl
	rts

copyit	lea	youdat,a0	* put stats ready to play
	lea	himdat,a1
	move.w	#256,54(a0)
	move.w	#256,62(a0)
	move.w	#256,54(a1)
	move.w	#256,62(a1)
	move.w	#0,46(a0)
	move.w	#0,46(a1)
	move.l	48(a0),18(a0)
	move.l	52(a0),22(a0)
	move.l	48(a1),18(a1)
	move.l	52(a1),22(a1)
	move.w	#0,joy0
	move.l	#52*64*65536+76*64,(a0)
	move.l	#0,4(a0)
	move.w	#0,8(a0)	
	move.l	#3,14(a0)
	move.l	#256*65536+256,26(a0)
	move.l	#0,32(a0)
	move.l	#0,36(a0)
	move.l	#2,40(a0)
	move.w	#0,44(a0)
	
	move.l	#252*64*65536+100*64,(a1)
	move.l	#0,4(a1)
	move.w	#0,8(a1)	
	move.l	#3,14(a1)
	move.l	#256*65536+256,26(a1)
	move.l	#0,32(a1)
	move.l	#0,36(a1)
	move.l	#2,40(a1)
	move.w	#0,44(a1)
	
	lea	buldat,a0
	moveq.w	#99,d0		* clear bullets
clrblp	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra.w	d0,clrblp
	
main	bsr	cls		* cls
	lea	youdat,a0
	move.b	joy1,d0
	move.w	#0,manon
	bsr	moveyou		* do player 1
	lea	himdat,a0
	move.b	joy0,d0
	move.w	#1,manon
	bsr	moveyou		* do player 2
	bsr	dobul		* do bullets
	bsr	bars		* do bars
	bsr	swap		* swap screens
	add.w	#1,turn		* increase turn counter
	cmp.w	#32,turn
	bne	wait
	move.w	#0,turn
wait	cmp.w	#0,youdam
	ble	gover		* p1 dead?
	cmp.w	#0,himdam
	ble	gover		* p2 dead?
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1		* wait for a key
	addq.l	#4,sp
	cmp.b	#' ',d0
	beq	retgen		* return to gen
	cmp.b	#'q',d0
	beq	title
	cmp.b	#'Q',d0		* quit
	beq	title
	bra	main		* new game turn
	
gover	bsr	cls		* game over
	cmp.w	#0,youdam	* p1 dead?
	ble	youdead		* yes!
	lea	gtxt1,a1	* p2 wins
	bra	deadrj
youdead	cmp.w	#0,himdam	* p2 dead?
	ble	adraw		* yes!
	lea	gtxt2,a1	* p1 wins!
	bra	deadrj
adraw	lea	gtxt3,a1	* a draw!
deadrj	bsr	domstr		* put the text
	lea	govetxt,a0
	adda.l	#3,a0
	lea	youdat,a1	* now do ingame stats
	lea	himdat,a2
	move.w	32(a1),d0
	bsr	puthun
	adda.l	#19,a0
	move.w	32(a2),d0
	bsr	puthun
	adda.l	#8,a0
	move.w	34(a1),d0
	bsr	puthun
	adda.l	#19,a0
	move.w	34(a2),d0
	bsr	puthun
	adda.l	#7,a0
	move.w	#0,d0
	cmp.w	#0,32(a0)
	beq	div02
	move.w	34(a1),d0
	mulu.w	#100,d0
div02	divu.w	32(a1),d0
	bsr	puthun
	adda.l	#20,a0
	move.w	#0,d0
	cmp.w	#0,32(a0)
	beq	div01
	move.w	34(a2),d0
	mulu.w	#100,d0
	divu.w	32(a2),d0
div01	bsr	puthun
	adda.l	#8,a0
	move.w	36(a1),d0
	bsr	puthun
	adda.l	#19,a0
	move.w	36(a2),d0
	bsr	puthun
	adda.l	#8,a0
	move.w	38(a1),d0
	bsr	puthun
	adda.l	#19,a0
	move.w	38(a2),d0
	bsr	puthun
	adda.l	#8,a0
	move.w	40(a1),d0
	bsr	puthun
	adda.l	#19,a0
	move.w	40(a2),d0
	bsr	puthun
	lea	govetxt,a1
	bsr	domstr
	bsr	swap
waitlp	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	cmp.b	#' ',d0
	bne	waitlp
	bra	title

puthun	and.l	#$ffff,d0
	divu.w	#100,d0
	add.w	#'0',d0
	cmp.w	#'0',d0
	bne	noth0
	move.w	#' ',d0
noth0	move.b	d0,(a0)
	swap	d0
	and.l	#$ffff,d0
	divu.w	#10,d0
	add.w	#'0',d0
	cmp.w	#'0',d0
	bne	nott0
	cmp.b	#' ',(a0)
	bne	nott0
	move.w	#' ',d0
nott0	move.b	d0,1(a0)
	swap	d0
	add.w	#'0',d0
	move.b	d0,2(a0)
	rts
	
*************************************

domstr	movea.l	back,a0		* put a string on screen
	moveq	#0,d2
	moveq	#0,d1
	move.b	(a1)+,d2
	cmp.b	#255,d2
	beq	return
	move.b	(a1)+,d1
	mulu.w	#160*8,d1
	move.w	#$ff,d0
	btst	#0,d2
	bne	mrgtone
	not.w	d0
mrgtone	lsr.w	#1,d2
	lsl.w	#3,d2
	add.w	d2,d1
	adda.l	d1,a0
	bsr	putmnms
	bra	domstr
putmnms	moveq	#0,d1
	move.b	(a1)+,d1
	cmp.b	#255,d1
	bne	noret
return	rts
noret	sub.w	#32,d1
	cmp.w	#':'-32,d1
	blt	mnoover
	subq.w	#1,d1
mnoover	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	lsl.w	#4,d1
	lea	text,a2
	adda.l	d1,a2
	move.w	#7,d1
	move.w	d0,d2
	not.w	d2
putmnm2	movem.w	(a2),d3-d7
	or.w	d2,d3
	and.w	d0,d4
	and.w	d0,d5
	and.w	d0,d6
	and.w	d0,d7
	and.w	d3,(a0)
	and.w	d3,2(a0)
	and.w	d3,4(a0)
	and.w	d3,6(a0)
	or.w	d4,(a0)
	or.w	d5,2(a0)
	or.w	d6,4(a0)
	or.w	d7,6(a0)
	adda.l	#160,a0
	adda.l	#10,a2
	dbra.w	d1,putmnm2
	suba.l	#160*8,a0
	not.w	d0
	cmp.w	#$ff00,d0
	bne	putmnms
	adda.l	#8,a0
	bra	putmnms

*************************************

bars	movea.l	back,a0			* put the bars on screen
	adda.l	#160*199,a0
	lea	youdat,a1
	bsr	dobars
	movea.l	back,a0
	adda.l	#160*199+136,a0
	lea	himdat,a1
	bsr	dobars
	rts
dobars	move.w	24(a1),d0		* put a player's bars on screen
	move.w	26(a1),d1
	move.w	28(a1),d2
	addq.w	#7,d0
	addq.w	#7,d1
	addq.w	#7,d2
	lsr.w	#3,d0
	lsr.w	#3,d1
	lsr.w	#3,d2
	move.w	#$0ff0,d5
	move.w	#$f00f,d6
	move.w	#32-1,d3
	moveq.w	#0,d4
barlp	cmp.w	#0,d0
	beq	nolftbr
	cmp.w	#1,46(a1)
	beq	wep2
	and.w	d6,(a0)
	or.w	d5,2(a0)
	or.w	d5,4(a0)
	or.w	d5,6(a0)
wep2ret	subq.w	#1,d0
	bne	nolftbr
	addq.w	#1,d4
nolftbr	cmp.w	#0,d1
	beq	nomidbr
	and.w	d6,8(a0)
	or.w	d5,10(a0)
	or.w	d5,12(a0)
	or.w	d5,14(a0)
	subq.w	#1,d1
	bne	nomidbr
	addq.w	#1,d4
nomidbr	cmp.w	#0,d2
	beq	norgtbr
	and.w	d6,16(a0)
	or.w	d5,18(a0)
	or.w	d5,20(a0)
	or.w	d5,22(a0)
	subq.w	#1,d2
	bne	norgtbr
	addq.w	#1,d4
norgtbr	cmp.w	#3,d4
	beq	barout
	suba.l	#160,a0
	dbra.w	d3,barlp
barout	rts	
wep2	or.w	d5,(a0)
	or.w	d5,2(a0)
	or.w	d5,4(a0)
	or.w	d5,6(a0)
	bra	wep2ret
		
*************************************

dobul	move.w	#99,d0		* do bullets
	lea	buldat,a0
bullp1	cmp.w	#0,(a0)
	beq	nxtbl
	cmp.w	#0,12(a0)
	beq	nothome
	cmp.w	#3,12(a0)
	beq	nothome
	cmp.w	#1,12(a0)
	beq	slow
	cmp.w	#4,12(a0)
	beq	slow
	move.w	#4,d7
slowret	move.w	2(a0),d1
	move.w	4(a0),d2
	lea	himdat,a1
	cmp.w	#0,14(a0)
	beq	itsyrs
	lea	youdat,a1
itsyrs	move.w	(a1),d3
	move.w	2(a1),d4
	add.w	#7*64,d3
	add.w	#7*64,d4
	move.w	6(a0),d5
	move.w	8(a0),d6
	cmp.w	d1,d3
	beq	chkvt
	blt	ltspd
	add.w	d7,d5
	bra	chkvt
ltspd	sub.w	d7,d5
chkvt	cmp.w	d2,d4
	beq	corbvel
	blt	upspd
	add.w	d7,d6
	bra	corbvel
upspd	sub.w	d7,d6
corbvel	cmp.w	#160,d5
	ble	okrt
	move.w	#160,d5
	bra	corbvt
okrt	cmp.w	#-160,d5
	bge	corbvt
	move.w	#-160,d5
corbvt	cmp.w	#160,d6
	ble	okdn
	move.w	#160,d6
	bra	corbdon
okdn	cmp.w	#-160,d6
	bge	corbdon
	move.w	#-160,d6
corbdon	move.w	d5,6(a0)
	move.w	d6,8(a0)
	bra	nothome	
slow	move.w	#1,d7
	bra	slowret
nothome	move.w	2(a0),d4
	move.w	4(a0),d5
	add.w	6(a0),d4
	add.w	8(a0),d5
	cmp.w	#2*64,d4
	bge	noblft
	cmp.w	#1,bumpbul
	beq	killbul
	blt	rebl
	add.w	#317*64,d4
	bra	bvtchck
rebl	neg.w	6(a0)
	move.w	#2*64,d4
	bra	bvtchck
rebr	neg.w	6(a0)
	move.w	#318*64,d4
	bra	bvtchck
noblft	cmp.w	#318*64,d4
	ble	bvtchck
	cmp.w	#1,bumpbul
	beq	killbul
	blt	rebr
	sub.w	#317*64,d4
bvtchck	cmp.w	#2*64,d5
	bge	nobtop
	cmp.w	#1,bumpbul
	beq	killbul
	blt	rebu
	add.w	#188*64,d5
	bra	bcont
rebu	neg.w	8(a0)
	move.w	#2*64,d5
	bra	bcont
rebd	neg.w	8(a0)
	move.w	#189*64,d5
	bra	bcont
nobtop	cmp.w	#189*64,d5
	ble	bcont
	cmp.w	#1,bumpbul
	beq	killbul
	blt	rebd
	sub.w	#188*64,d5
bcont	move.w	d4,2(a0)
	move.w	d5,4(a0)
	lsr.w	#6,d4
	lsr.w	#6,d5
	cmp.w	#2,12(a0)
	bgt	bigbuld
	bsr	point
	cmp.w	#0,d4
	bne	hitsmf
	move.w	2(a0),d4
	move.w	4(a0),d5
	lsr.w	#6,d4
	lsr.w	#6,d5
	move.w	#1,d6
	bsr	orplot
	sub.w	#1,10(a0)
	bcs	killbul
nxtbl	adda.l	#16,a0
	dbra.w	d0,bullp1
	rts
bigbuld	bsr	point4
	cmp.w	#0,d4
	bne	hitsmf
	move.w	2(a0),d4
	move.w	4(a0),d5
	lsr.w	#6,d4
	lsr.w	#6,d5
	move.w	#1,d6
	bsr	plot4
	sub.w	#1,10(a0)
	bcs	killbul
	bra	nxtbl
hitsmf	lea	youdat,a1
	lea	himdat,a3
	move.w	#0,d7
	bsr	hitchck
	cmp.w	#0,d3
	bne	killbul
	lea	himdat,a1
	lea	youdat,a3
	move.w	#1,d7
	bsr	hitchck
	
killbul	move.w	#0,(a0)		* delete a bullet
	bra	nxtbl
hitchck	move.w	(a1),d3
	move.w	2(a1),d1
	sub.w	2(a0),d3
	sub.w	4(a0),d1
	cmp.w	#-16*64,d3
	blt	nothis
	cmp.w	#0*64,d3
	bgt	nothis
	cmp.w	#-16*64,d1
	blt	nothis
	cmp.w	#0*64,d1
	bgt	nothis
	cmp.w	14(a0),d7
	beq	hitself
	add.w	#1,34(a3)
hitself	add.w	#1,36(a1)
	move.w	12(a0),d3
	lea	damtab,a2
	move.w	30(a1),d1
	lsl.w	#3,d1
	cmp.w	#2,d3
	bgt	bbigbul
	moveq	#0,d2
	move.b	(a2,d1.w),d2
	sub.w	d2,28(a1)
	add.w	d2,38(a1)
	bset	#0,newsam
	move.w	#0,d3
	rts
bbigbul	moveq	#0,d2
	move.b	1(a2,d1.w),d2
	sub.w	d2,28(a1)
	add.w	d2,38(a1)
	bset	#0,newsam
	move.w	#0,d3
	rts
nothis	move.w	#0,d3
	rts
	
orplot	move.w	d5,d7		* plot a point
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d5
	lsl.w	#5,d5		*160
	move.w	d4,d7
	lsr.w	#4,d7
	lsl.w	#3,d7
	add.w	d7,d5
	lsl.w	#1,d7
	sub.w	d7,d4
	and.l	#$ffff,d5
	movea.l	back,a5
	adda.l	d5,a5
	move.w	#32768,d7
	lsr.w	d4,d7
	move.w	d7,d4
	not.w	d4
	btst	#0,d6
	bne	orit
	and.w	d4,(a5)+
	bra	bit1
orit	or.w	d7,(a5)+
bit1	btst	#1,d6
	bne	orit2
	and.w	d4,(a5)+
	bra	bit2
orit2	or.w	d7,(a5)+
bit2	btst	#2,d6
	bne	orit3
	and.w	d4,(a5)+
	bra	bit3
orit3	or.w	d7,(a5)+
bit3	btst	#3,d6
	bne	orit4
	and.w	d4,(a5)+
	rts
orit4	or.w	d7,(a5)+
	rts
point	move.w	d5,d7		* test a point
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d5
	lsl.w	#5,d5		*160
	move.w	d4,d7
	lsr.w	#4,d7
	lsl.w	#3,d7
	add.w	d7,d5
	lsl.w	#1,d7
	sub.w	d7,d4
	and.l	#$ffff,d5
	movea.l	back,a5
	adda.l	d5,a5
	move.w	#32768,d7
	lsr.w	d4,d7
	move.w	(a5)+,d4
	or.w	(a5)+,d4
	or.w	(a5)+,d4
	or.w	(a5),d4
	and.w	d7,d4
	rts
plot4	move.w	d5,d7		* plot 4 points
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d5
	lsl.w	#5,d5		*160
	move.w	d4,d7
	lsr.w	#4,d7
	lsl.w	#3,d7
	add.w	d7,d5
	lsl.w	#1,d7
	sub.w	d7,d4
	and.l	#$ffff,d5
	movea.l	back,a5
	adda.l	d5,a5
	move.w	#49152,d7
	cmp.w	#15,d4
	beq	over
	lsr.w	d4,d7
	move.w	d7,d4
	not.w	d4
	btst	#0,d6
	bne	or4it
	and.w	d4,(a5)+
	and.w	d4,158(a5)
	bra	bit41
or4it	or.w	d7,(a5)+
	or.w	d7,158(a5)
bit41	btst	#1,d6
	bne	orit42
	and.w	d4,(a5)+
	and.w	d4,158(a5)
	bra	bit42
orit42	or.w	d7,(a5)+
	or.w	d7,158(a5)
bit42	btst	#2,d6
	bne	orit43
	and.w	d4,(a5)+
	and.w	d4,158(a5)
	bra	bit43
orit43	or.w	d7,(a5)+
	or.w	d7,158(a5)
bit43	btst	#3,d6
	bne	orit44
	and.w	d4,(a5)+
	and.w	d4,158(a5)
	rts
orit44	or.w	d7,(a5)+
	or.w	d7,158(a5)
	rts
over	move.w	#1,d7
	move.w	#65534,d4
	move.w	#32768,d2
	move.w	#32767,d1
	btst	#0,d6
	bne	vor4it
	and.w	d4,(a5)+
	and.w	d1,6(a5)
	and.w	d1,166(a5)
	and.w	d4,158(a5)
	bra	vbit41
vor4it	or.w	d7,(a5)+
	or.w	d2,6(a5)
	or.w	d2,166(a5)
	or.w	d7,158(a5)
vbit41	btst	#1,d6
	bne	vorit42
	and.w	d4,(a5)+
	and.w	d1,6(a5)
	and.w	d1,166(a5)
	and.w	d4,158(a5)
	bra	vbit42
vorit42	or.w	d7,(a5)+
	or.w	d2,6(a5)
	or.w	d2,166(a5)
	or.w	d7,158(a5)
vbit42	btst	#2,d6
	bne	vorit43
	and.w	d4,(a5)+
	and.w	d1,6(a5)
	and.w	d1,166(a5)
	and.w	d4,158(a5)
	bra	vbit43
vorit43	or.w	d7,(a5)+
	or.w	d2,6(a5)
	or.w	d2,166(a5)
	or.w	d7,158(a5)
vbit43	btst	#3,d6
	bne	vorit44
	and.w	d4,(a5)+
	and.w	d1,6(a5)
	and.w	d1,166(a5)
	and.w	d4,158(a5)
	rts
vorit44	or.w	d7,(a5)+
	or.w	d2,6(a5)
	or.w	d2,166(a5)
	or.w	d7,158(a5)
	rts
point4	move.w	d5,d6		* test 4 points
	add.w	d6,d6
	add.w	d6,d6
	add.w	d6,d5
	lsl.w	#5,d5		*160
	move.w	d4,d7
	lsr.w	#4,d7
	lsl.w	#3,d7
	add.w	d7,d5
	lsl.w	#1,d7
	sub.w	d7,d4
	and.l	#$ffff,d5
	movea.l	back,a5
	adda.l	d5,a5
	move.w	#49152,d7
	lsr.w	d4,d7
	cmp.w	#15,d4
	beq	splitpt
	move.w	(a5),d4
	or.w	2(a5),d4
	or.w	4(a5),d4
	or.w	6(a5),d4
	or.w	160(a5),d4
	or.w	162(a5),d4
	or.w	164(a5),d4
	or.w	166(a5),d4
	and.w	d7,d4
	rts
splitpt	move.w	(a5),d4
	or.w	2(a5),d4
	or.w	4(a5),d4
	or.w	6(a5),d4
	or.w	160(a5),d4
	or.w	162(a5),d4
	or.w	164(a5),d4
	or.w	166(a5),d4
	move.w	8(a5),d5
	or.w	10(a5),d5
	or.w	12(a5),d5
	or.w	14(a5),d5
	or.w	168(a5),d5
	or.w	170(a5),d5
	or.w	172(a5),d5
	or.w	174(a5),d5
	and.w	#1,d4
	and.w	#32768,d5
	or.w	d5,d4
	rts



*************************************

moveyou	btst	#2,d0		* move you
	beq	nolturn
	move.w	14(a0),d1
	add.w	12(a0),d1
	move.w	d1,14(a0)
	cmp.w	#turncount,d1
	blt	nolturn
	sub.w	#2*turncount,14(a0)
	sub.w	#1,8(a0)
	bcc	nolturn
	move.w	#15,8(a0)
nolturn	btst	#3,d0
	beq	norturn
	move.w	14(a0),d1
	sub.w	12(a0),d1
	move.w	d1,14(a0)
	cmp.w	#-turncount,d1
	bgt	norturn
	add.w	#2*turncount,14(a0)
	add.w	#1,8(a0)
	cmp.w	#15,8(a0)
	ble	norturn
	move.w	#0,8(a0)
norturn	move.w	4(a0),d2
	move.w	6(a0),d3
	btst	#0,d0
	beq	nothr
	cmp.w	#0,26(a0)
	beq	nothr
	move.w	42(a0),d1
	add.w	d1,44(a0)
	cmp.w	#conrate,44(a0)
	blt	nofused
	sub.w	#conrate,44(a0)
	sub.w	#1,26(a0)
	add.w	#1,40(a0)
nofused	move.w	8(a0),d1
	move.w	10(a0),d4
	lea	thrtab,a1
	lsl.w	#6,d4
	add.w	d1,d1
	add.w	d1,d1
	add.w	d4,d1
	add.w	(a1,d1.w),d2
	add.w	2(a1,d1.w),d3
	bsr	corvel
nothr	add.w	d2,(a0)
	cmp.w	#0,(a0)
	bge	nofflft
	neg.w	d2
	move.w	d2,4(a0)
	move.w	#0,(a0)
	cmp.w	#0,bumpdam
	beq	noffrgt
dodam	move.w	30(a0),d7
	lsl.w	#3,d7
	lea	damtab,a2
	add.w	bumpdam,d7
	moveq	#0,d6
	move.b	1(a2,d7.w),d6
	move.w	4(a0),d7
	cmp.w	#0,d7
	bge	nocorhz
	neg.w	d7
nocorhz	mulu.w	d7,d6
	lsr.w	#7,d6
	sub.w	d6,28(a0)
	bra	noffrgt
nofflft	cmp.w	#304*64,(a0)
	ble	noffrgt
	neg.w	d2
	move.w	d2,4(a0)
	move.w	#304*64,(a0)
	cmp.w	#0,bumpdam
	bne	dodam
noffrgt	add.w	d3,2(a0)
	cmp.w	#0,2(a0)
	bge	nofftop
	neg.w	d3
	move.w	d3,6(a0)
	move.w	#0,2(a0)
	cmp.w	#0,bumpdam
	beq	noffrgt
dodamvt	move.w	30(a0),d7
	lsl.w	#3,d7
	lea	damtab,a2
	add.w	bumpdam,d7
	moveq	#0,d6
	move.b	1(a2,d7.w),d6
	move.w	6(a0),d7
	cmp.w	#0,d7
	bge	nocorvt
	neg.w	d7
nocorvt	mulu.w	d7,d6
	lsr.w	#7,d6
	sub.w	d6,28(a0)
	bra	noffbot
nofftop	cmp.w	#176*64,2(a0)
	ble	noffbot
	neg.w	d3
	move.w	d3,6(a0)
	move.w	#176*64,2(a0)
	cmp.w	#0,bumpdam
	bne	dodamvt
noffbot	btst	#7,d0
	beq	notfire
	move.w	turn,d1
	and.w	18(a0),d1
	bne	notfire
	cmp.w	#0,24(a0)
	beq	notfire
	lea	coltab,a1
	move.w	8(a0),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	dirtab,a2
	move.w	(a2,d1.w),d4
	move.w	2(a2,d1.w),d5
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	move.w	64(a0),d2
	lsl.w	#5,d2
	lsl.w	#4,d2
	add.w	d2,d1
	move.w	24(a1,d1.w),d2
	move.w	26(a1,d1.w),d3
	lsl.w	#6,d2
	lsl.w	#6,d3
	add.w	(a0),d2
	add.w	2(a0),d3
	lea	buldat,a1
	move.w	#99,d1
blfndlp	cmp.w	#0,(a1)
	bne	noblhr
	move.w	#1,(a1)
	move.w	d2,2(a1)
	move.w	d3,4(a1)
	move.w	d4,6(a1)
	move.w	d5,8(a1)
	move.w	22(a0),10(a1)
	move.w	20(a0),12(a1)
	move.w	manon,14(a1)
	bra	dorecl
noblhr	adda.l	#16,a1
	dbra.w	d1,blfndlp
	bra	notfire
dorecl	move.b	#2,newsam
	cmp.w	#2,20(a0)
	ble	nobig
	move.b	#4,newsam
nobig	sub.w	#1,24(a0)
	add.w	#1,32(a0)
	lea	thrtab,a1
	move.w	8(a0),d1
	add.w	#8,d1
	cmp.w	#15,d1
	ble	norsd1
	sub.w	#16,d1
norsd1	add.w	d1,d1
	add.w	d1,d1
	move.w	16(a0),d2
	lsl.w	#6,d2
	add.w	d2,d1
	move.w	4(a0),d2
	move.w	6(a0),d3
	add.w	(a1,d1.w),d2
	add.w	2(a1,d1.w),d3
	bsr	corvel
	cmp.w	#1,64(a0)
	beq	firagn
notfire	
	btst	#1,d0
	beq	nochng
	move.w	turn,d1
	btst	#0,d1
	bne	nochng
	move.w	46(a0),d1
	cmp.w	#0,d1
	beq	pwep2
	move.w	24(a0),62(a0)
	move.l	48(a0),18(a0)
	move.l	52(a0),22(a0)
	move.w	#0,46(a0)
	bra	nochng
pwep2	move.w	24(a0),54(a0)
	move.l	56(a0),18(a0)
	move.l	60(a0),22(a0)
	move.w	#1,46(a0)
nochng	move.w	8(a0),d2
	move.w	64(a0),d3
	lsl.w	#5,d3
	add.w	d3,d2
	btst	#0,d0
	beq	nothrst
	cmp.w	#1,64(a0)
	beq	nothrst
	cmp.w	#0,26(a0)
	beq	nothrst
	add.w	#16,d2
nothrst	move.w	(a0),d0
	move.w	2(a0),d1
	asr.w	#6,d0
	asr.w	#6,d1
	lea	ships,a5
	move.w	#15,d3
	bsr	spr16
	rts
firagn	cmp.w	#0,24(a0)
	beq	notfire
	lea	coltab,a1
	move.w	8(a0),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	dirtab,a2
	move.w	(a2,d1.w),d4
	move.w	2(a2,d1.w),d5
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	#512,d1
	move.w	28(a1,d1.w),d2
	move.w	30(a1,d1.w),d3
	lsl.w	#6,d2
	lsl.w	#6,d3
	add.w	(a0),d2
	add.w	2(a0),d3
	lea	buldat,a1
	move.w	#99,d1
bfndlp2	cmp.w	#0,(a1)
	bne	noblhr2
	move.w	#1,(a1)
	move.w	d2,2(a1)
	move.w	d3,4(a1)
	move.w	d4,6(a1)
	move.w	d5,8(a1)
	move.w	22(a0),10(a1)
	move.w	20(a0),12(a1)
	move.w	manon,14(a1)
	bra	dorecl2
noblhr2	adda.l	#16,a1
	dbra.w	d1,bfndlp2
	bra	notfire
dorecl2	sub.w	#1,24(a0)
	add.w	#1,32(a0)
	lea	thrtab,a1
	move.w	8(a0),d1
	add.w	#8,d1
	cmp.w	#15,d1
	ble	norsd12
	sub.w	#16,d1
norsd12	add.w	d1,d1
	add.w	d1,d1
	move.w	16(a0),d2
	lsl.w	#6,d2
	add.w	d2,d1
	move.w	4(a0),d2
	move.w	6(a0),d3
	add.w	(a1,d1.w),d2
	add.w	2(a1,d1.w),d3
	bsr	corvel
	bra	notfire
	
corvel	cmp.w	#128,d2
	ble	nocor1
	move.w	#128,d2
	bra	cord3
nocor1	cmp.w	#-128,d2
	bge	cord3
	move.w	#-128,d2
cord3	cmp.w	#128,d3
	ble	nocor3
	move.w	#128,d3
	bra	carryon
nocor3	cmp.w	#-128,d3
	bge	carryon
	move.w	#-128,d3
carryon	move.w	d2,4(a0)
	move.w	d3,6(a0)
	rts


dirtab	dc.w	0,-160,61,-148,113,-113,148,-61,161,0,148,61,113,113,61,148
	dc.w	0,160,-61,148,-113,113,-148,61,-160,0,-148,-61,-113,-113,-61,-148
thrtab	dc.w	0,-5,2,-4,3,-3,4,-2,5,0,4,2,3,3,2,4
	dc.w	0,5,-2,4,-3,3,-4,2,-5,0,-4,-2,-3,-3,-2,-4
	dc.w	0,-4,1,-3,2,-2,3,-1,4,0,3,1,2,2,1,3
	dc.w	0,4,-1,3,-2,2,-3,1,-4,0,-3,-1,-2,-2,-1,-3
	dc.w	0,-3,1,-2,2,-2,2,-1,3,0,2,1,2,2,1,2
	dc.w	0,3,-1,2,-2,2,-2,1,-3,0,-2,-1,-2,-2,-1,-2
	dc.w	0,-2,1,-2,1,-1,2,-1,2,0,2,1,1,1,1,2
	dc.w	0,2,-1,2,-1,1,-2,1,-2,0,-2,-1,-1,-1,-1,-2
damtab	dc.b	10,16,16,40,64,0,0,0
	dc.b	9,14,14,36,58,0,0,0
	dc.b	8,13,13,32,51,0,0,0
	dc.b	7,11,11,28,45,0,0,0
	dc.b	5,8,8,20,32,0,0,0
	
*************************************

spr16	movea.l	back,a6			* sprite routine
	moveq	#0,d6		*
	move.w	d2,d6		*	multiply
	add.w	d2,d2		*	sprite
	add.w	d2,d2		*	number
	add.w	d2,d6		*	by 160
	lsl.l	#5,d6		*
	adda.l	d6,a5
	move.w	d1,d6
	cmp.w	#0,d1
	ble	notop
	moveq	#0,d7		*
	move.w	d1,d7		*	multiply
	add.w	d1,d1		*	line
	add.w	d1,d1		*	numer
	add.w	d1,d7		*	by 160
	lsl.l	#5,d7		*
	adda.l	d7,a6
notop	moveq	#0,d1
	moveq	#0,d5
	cmp.w	#0,d0
	bge	onlft
	bset	#0,d5
	suba.l	#8,a6
	bra	onscr
onlft	cmp.w	#304,d0
	ble	onrght
	bset	#1,d5
onrght	move.w	d0,d1
	and.w	#$fff0,d1
	lsr.w	#1,d1
	adda.l	d1,a6
onscr	add.w	d1,d1
	sub.w	d1,d0
	not.w	d0
	and.w	#$f,d0
	add.w	#1,d0		*d0=no. rots left
rows	cmp.w	#0,d6
	blt	nodo
	cmp.w	#192,d6
	bge	sprret
	move.l	#$ffffffff,d1
	move.w	(a5),d1
	rol.l	d0,d1
	btst	#1,d5
	bne	norght1
	and.w	d1,8(a6)
	and.w	d1,10(a6)
	and.w	d1,12(a6)
	and.w	d1,14(a6)
	btst	#0,d5
	bne	nolft1
norght1	swap	d1
	and.w	d1,(a6)
	and.w	d1,2(a6)
	and.w	d1,4(a6)
	and.w	d1,6(a6)
nolft1	movem.w	2(a5),d1/d2/d4/d7
	and.l	#$ffff,d1
	and.l	#$ffff,d2
	and.l	#$ffff,d4
	and.l	#$ffff,d7
	lsl.l	d0,d1
	lsl.l	d0,d2
	lsl.l	d0,d4
	lsl.l	d0,d7
	btst	#1,d5
	bne	norght2
	or.w	d1,8(a6)
	or.w	d2,10(a6)
	or.w	d4,12(a6)
	or.w	d7,14(a6)
	btst	#0,d5
	bne	nolft2
norght2	swap	d1
	swap	d2
	swap	d4
	swap	d7
	or.w	d1,(a6)
	or.w	d2,2(a6)
	or.w	d4,4(a6)
	or.w	d7,6(a6)
nolft2	adda.l	#160,a6
nodo	addq.w	#1,d6
	adda.l	#10,a5
	dbra.w	d3,rows
sprret	rts

*************************************

swap	movea.l	back,a4			* swap screens
	movea.l	physic,a5
	movea.l	back2,a6
	move.l	a4,physic
	move.l	a5,back2
	move.l	a6,back
	move.w	#$2700,sr
	move.l	a4,d4
	lsr.l	#8,d4
	move.b	d4,d5
	and.w	#$ff,d5
	or.w	d5,d4
	lea	$ffff8201,a4
	movep.w	d4,(a4)
	move.w	#$2300,sr
swapvbl	btst	#7,flags
	beq	swapvbl
	bclr	#7,flags
	rts
cls	movea.l	back,a4			* cls (v. slow)
	move.w	#8000-1,d4
cloop	clr.l	(a4)+
	dbra.w	d4,cloop
	rts
retgen	move.b	oldkey,$484		* return to gen
	bsr	samstop
	move.w	#1,-(sp)
	move.l	#$f8000,-(sp)
	move.l	#$f8000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	pea	pal2
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	move.b	#$8,$fffc02
	move.w	#0,-(sp)
	trap	#1
pal2	dc.w	$777,0,0,0
joy	move.l a1,-(sp)			;0=up
	lea joy0,a1			;1=down
	move.b 1(a0),(a1)		;2=left
	move.b 2(a0),1(a1)		;3=right
	movea.l (sp)+,a1		;7=fire
	rts
joy0	dc.b	0
joy1	dc.b	0
palette	dc.w	$000,$555,$444,$333
	dc.w	$222,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$660,$700,$632

physic	dc.l	$f8000
back	dc.l	$f0000
back2	dc.l	$e8000

youdat
youx	dc.w	52*64
youy	dc.w	76*64
youxs	dc.w	0
youys	dc.w	0
youdir	dc.w	0
youthr	dc.w	0
youts	dc.w	8
youtsc	dc.w	0
youiner	dc.w	3
youfrat	dc.w	0
youbult	dc.w	0
youbull	dc.w	0
youammo	dc.w	0
youfuel	dc.w	256
youdam	dc.w	256
youarm	dc.w	4
yousf	dc.w	0
youhg	dc.w	0
youht	dc.w	0
youdt	dc.w	0
youfu	dc.w	0
youfc	dc.w	2
youfcc	dc.w	0
youwin	dc.w	0
youw1d	dc.w	3
	dc.w	3
	dc.w	100
	dc.w	256
youw2d	dc.w	1
	dc.w	0
	dc.w	100
	dc.w	256
youship	dc.w	0
	
himdat
himx	dc.w	252*64
himy	dc.w	100*64
himxs	dc.w	0
himys	dc.w	0
himdir	dc.w	0
himthr	dc.w	0
himts	dc.w	8
himtsc	dc.w	0
himiner	dc.w	3
himfrat	dc.w	0
himbult	dc.w	0
himbull	dc.w	0
himammo	dc.w	0
himfuel	dc.w	256
himdam	dc.w	256
himarm	dc.w	4
himsf	dc.w	0
himhg	dc.w	0
himht	dc.w	0
himdt	dc.w	0
himfu	dc.w	0
himfc	dc.w	2
himfcc	dc.w	0
himwin	dc.w	0
himw1d	dc.w	3
	dc.w	3
	dc.w	100
	dc.w	256
himw2d	dc.w	1
	dc.w	0
	dc.w	100
	dc.w	256
himship	dc.w	0

manon	dc.w	0
turn	dc.w	0

***************************************

cursdat	dc.b	13,8,"*",255,25,8,"*",255,255
titext	dc.b	14,3,"GRAV BATTLES",255
	dc.b	19,4,"BY",255,12,5,"MARTIN BROWNLOW.",255
TITREAD	dc.b	6,8,"  DART   SHIP TYPE   DART  ",255
	dc.b	6,9,"LO-BUL    WEAPON 1   LO-BUL",255
	dc.b	6,10,"   LOW      HOME     LOW   ",255
	dc.b	6,11,"   LOW      RATE     LOW   ",255
	dc.b	6,12,"HI-BUL    WEAPON 2   HI-BUL",255
	dc.b	6,13,"   LOW      HOME     LOW   ",255
	dc.b	6,14,"   LOW      RATE     LOW   ",255
	dc.b	6,15,"   50%     ARMOUR     50%  ",255
	dc.b	6,16,"   LOW    THRUSTER    LOW  ",255
	dc.b	6,17,"   LOW    TURN JET    LOW  ",255
	dc.b	19,19,"OK",255
	dc.b	10,21,"EDGE-BULLETS  "
edbult	dc.b	"BOUNCE",255,10,22,"EDGE-YOU      "
edyout	dc.b	"BOUNCE",255,255
STR1	dc.b	"  DART","  TWIN"
	dc.b	"LO-BUL","HI-BUL"
	dc.b	"  NONE","  SLOW","  FAST"
	dc.b	"  NONE","   10%","   20%","   30%","   50%"
	dc.b	"   LOW","MEDIUM","  HIGH"
STR5	dc.b	"DART  ","TWIN  "
	dc.b	"LO-BUL","HI-BUL"
	dc.b	"NONE  ","SLOW  ","FAST  "
	dc.b	"NONE  ","10%   ","20%   ","30%   ","50%   "
	dc.b	"LOW   ","MEDIUM","HIGH  "
str2	dc.b	"BOUNCE","VANISH","  WRAP"
str3	dc.b	"BOUNCE","DAM-LO","DAM-MD","DAM-HI"


 even
gtxt1	dc.b	13,3,"PLAYER 1 WINS!",255,255
gtxt2	dc.b	13,3,"PLAYER 2 WINS!",255,255
gtxt3	dc.b	16,3,"A DRAW !",255,255
govetxt	dc.b	8,7," 000  SHOTS  FIRED  000 ",255
	dc.b	8,9," 000   HITS GIVEN   000 ",255
	dc.b	8,11,"000%    ACCURACY    000%",255
	dc.b	8,13," 000   HITS TAKEN   000 ",255
	dc.b	8,15," 000  DAMAGE TAKEN  000 ",255
	dc.b	8,17," 000   FUEL  USED   000 ",255
	dc.b	14,21,"PRESS SPACE.",255,255

*****environment set-up variables******

bumpbul	dc.w	0
bumpdam	dc.w	0

***************************************

turncount	equ	8
conrate		equ	8

buldat	ds.b	100*16
flags	dc.b	0
oldkey	dc.b	0

ships	incbin	"a:\battles\data\ships.dat"
coltab	incbin	"a:\battles\data\collide.dat"
	incbin	"a:\battles\data\twincol.dat"
text	incbin	"a:\battles\data\text.dat"
	
	include	"a:\battles\samplay.s"	
	
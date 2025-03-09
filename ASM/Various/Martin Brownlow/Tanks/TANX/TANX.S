	opt	o+
	opt	w-
		
* Defines

x	equ	0
y	equ	2
hits	equ	4
gr	equ	6
elev	equ	8
elevfr	equ	10
reload	equ	12
str	equ	14
ammo	equ	16
maxx	equ	18
minx	equ	20
minf	equ	22
maxf	equ	24
playr	equ	26
damage	equ	28
fire	equ	30
turret	equ	32
gun	equ	34
track	equ	36
dead	equ	38
ftab	equ	40

minstr	equ	64
maxstr	equ	56
maxbul	equ	20
maxprt	equ	50
maxbird	equ	10

* Tank v tank 2 player game
tank
	bsr	setup		* set up environ
	bsr	joys		* set up joysticks
	bsr	playsam		* set up sample player
	moveq	#0,d0
	move.b	$ff8209,d0
	move.w	d0,seed
	bsr	cls		* CLS
	move.w	#1,newload
	bra	loadjn
	
* put title screen here

game	move.w	#0,specon	* start a new game
	move.w	#0,newload
	lea	player1,a0	* reset all data
	lea	player2,a1
	move.w	#20,x(a0)
	move.w	#284,x(a1)
	move.w	#0,gr(a0)
	move.w	#12*80,gr(a1)
	move.w	#0,elev(a0)
	move.w	#0,elev(a1)
	move.w	#4*80,elevfr(a0)
	move.w	#16*80,elevfr(a1)
	move.w	#0,reload(a0)
	move.w	#0,reload(a1)
	move.w	#0,str(a0)
	move.w	#0,str(a1)
	move.w	#56,ammo(a0)
	move.w	#56,ammo(a1)
	move.w	#56,damage(a0)
	move.w	#56,damage(a1)
	move.l	#0,fire(a0)
	move.l	#0,gun(a0)
	move.w	#0,dead(a0)
	move.l	#0,fire(a1)
	move.l	#0,gun(a1)
	move.w	#0,dead(a1)
	lea	bultab,a0
	move.w	#maxbul-1,d0	* clear bullets
bulclp	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.w	#0,(a0)+
	dbra.w	d0,bulclp
	lea	partdat,a0
	move.w	#maxprt-1,d0	* clear particles
prtclp	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.w	#0,(a0)+
	dbra.w	d0,prtclp
	lea	birddat,a0
	move.w	#maxbird-1,d0
brdclp	move.l	#0,(a0)+	* clear birds
	move.w	#0,(a0)+
	dbra.w	d0,brdclp
loadjn	lea	backbuf,a6
	move.l	a6,defscr
	bsr	cls2
	bsr	fract		* draw hill
	lea	stats,a0
	bsr	print		* print stats
	bsr	print
	bsr	print
	lea	player1,a0	* select player 1
	bsr	damgraf		* do damage
	bsr	ammgraf		* do ammo
	lea	player2,a0	* select player 2
	bsr	damgraf		* do damage
	bsr	ammgraf		* do ammo

	move.w	startb,d0
	lea	birddat,a0	* create some birds
	move.w	#1,d1
birdmlp	move.w	d1,(a0)+
	bsr	random
	and.w	#255,d7
	add.w	#32,d7
	move.w	d7,(a0)+
	bsr	random
	and.w	#63,d7
	addq	#1,d7
	move.w	d7,(a0)+
	addq	#1,d1
	cmp.w	#3,d1
	bne	nochf
	moveq	#1,d1
nochf	dbra.w	d0,birdmlp

gamelp	bsr	copbuf		* copy background
	lea	player1,a0	* select p1
	move.b	joy1,d0
	bsr	player		* do him
	move.b	joy0,d0
	lea	player2,a0	* select p2
	bsr	player		* do him
	bsr	dobull		* do bullets
	bsr	doparts		* do particles
	bsr	dobirds		* do birds
	cmpi.w	#0,specon	* special baddy on?
	beq	nospec		* no
	bsr	dospec		* do him
	bra	yesspec		* hop next bit
nospec	bsr	random
	andi.w	#255,d7		* see if should make special baddy
	cmpi.w	#0,d7
	bne	yesspec		* no
	bsr	random		* make him
	andi.w	#3,d7
	cmpi.w	#0,d7
	beq	yesspec
	move.w	d7,specon
	move.w	#0,specgr
	cmpi.w	#1,d7
	beq	issauc
	addq.w	#2,d7
	mulu.w	#160,d7
	move.w	d7,specgr
issauc	bsr	random
	andi.w	#1,d7
	cmpi.w	#0,d7
	beq	gorgt
	move.w	#-16,specx
	move.w	#1,specxs
	bra	gonrgt
gorgt	move.w	#320,specx
	move.w	#-1,specxs
gonrgt	bsr	random
	andi.w	#63,d7
	addi.w	#7,d7
	move.w	d7,specy
	
yesspec	bsr	swap		* swap screen
	cmp.w	#100,p1dead	* been dead long enough?
	beq	govp1		* yes
	blt	nodp1
	move.w	#100,p1dead
nodp1	cmp.w	#100,p2dead	* been dead long enough?
	beq	govp2		* yes
	blt	nodp2
	move.w	#100,p2dead
nodp2	add.w	#1,turn		* increase turn
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)	* key been pressed?
	trap	#1
	addq	#4,sp
	cmp.b	#'a',d0
	beq	game
	cmp.b	#'A',d0
	beq	game
	cmp.b	#'@',d0
	beq	retgen
	bra	gamelp		* game loop

* Game over

govp1	cmp.w	#0,p2dead
	bne	draw		* draw?
	lea	p2win,a0
	bsr	print
comgov	lea	comtxt,a0
	bsr	print
comlp	bsr	copbuf		* repeat game loop
	lea	player1,a0
	move.b	joy1,d0
	bsr	player
	move.b	joy0,d0
	lea	player2,a0
	bsr	player
	bsr	dobull
	bsr	doparts
	bsr	dobirds		* unfortunately, I missed the special code
				* here, sorry...
	
	bsr	swap		* swap screens
	add.w	#1,turn
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)	* wait key
	trap	#1
	addq	#4,sp
	cmp.w	#32,d0
	beq	game		* start game
	bra	comlp

govp2	cmp.w	#0,p1dead
	bne	draw		* draw?
	lea	p1win,a0
	bsr	print
	bra	comgov
draw	move.w	#100,p2dead
	move.w	#100,p1dead
	cmp.w	#1,newload
	beq	titscr
	lea	drawtxt,a0
	bsr	print
	bra	comgov
titscr	lea	titltxt,a0
	bsr	print
	bra	comgov

* Special stuff

dospec	move.w	specx,d0	* routine to handle the special guys
	move.w	specy,d1
	add.w	specxs,d0
	cmpi.w	#-15,d0
	blt	specoff
	cmpi.w	#319,d0
	bgt	specoff
	move.w	d0,specx
	move.w	d1,specy
	move.w	specgr,d2
	moveq.w	#15,d3
	lea	extra,a5
	bsr	spr2
	cmpi.w	#1,specon
	bne	noanim
	bset	#4,newsam
	bsr	random
	andi.w	#15,d7
	cmpi.w	#0,d7
	bne	noufire
	move.w	specx,d3
	move.w	specy,d4
	addq.w	#8,d4
	addq.w	#8,d3
	lsl.w	#5,d3
	lsl.w	#5,d4
	moveq.w	#0,d0
	moveq.w	#64,d1
	moveq.w	#3,d5
	bsr	makebul
noufire	move.w	turn,d0
	andi.w	#3,d0
	bne	noanim
	addi.w	#160,specgr
	cmpi.w	#640,specgr
	bne	noanim
	move.w	#0,specgr
noanim	rts
specoff	move.w	#0,specon
	rts

* Player controls
	
player	cmp.w	#0,dead(a0)	* control the player
	beq	okplay
	addq.w	#1,dead(a0)
	bra	nogun
okplay	bsr	repairs
	cmp.w	#0,reload(a0)
	beq	notdecr
	sub.w	#1,reload(a0)
	bne	notdecr
	exg.l	a0,a1
	lea	norell,a0
	cmp.w	#0,playr(a1)
	beq	nochad2
	lea	norelr,a0
nochad2	move.l	a1,-(sp)
	bsr	print
	movea.l	(sp)+,a0
notdecr	cmp.w	#0,turret(a0)
	bne	noelev
	btst	#0,d0
	bne	incelev
	btst	#1,d0
	bne	decelev
noelev	cmp.w	#0,track(a0)
	bne	hzret
	move.w	#1,d2
	cmp.w	#0,fire(a0)
	beq	oktest
	move.w	#3,d2
oktest	move.w	turn,d1
	and.w	d2,d1
	cmp.w	#0,d1
	bne	hzret
	btst	#2,d0
	bne	lft
	btst	#3,d0
	bne	rgt
vtret
hzret	btst	#7,d0
	beq	fire?
	cmp.w	#0,gun(a0)
	bne	fireret
	cmp.w	#0,reload(a0)
	bne	fireret
	cmp.w	#maxstr,str(a0)
	beq	fireret
	add.w	#1,str(a0)
	bsr	powgraf
fireret	move.w	x(a0),d0
	move.w	y(a0),d1
	subq.w	#4,d1
	move.w	elevfr(a0),d2
	moveq	#5,d3
	bsr	spr16
nogun	move.w	x(a0),d0
	move.w	y(a0),d1
	move.w	gr(a0),d2
	moveq	#7,d3
	bsr	spr16
	cmp.w	#0,fire(a0)
	bne	onfire
plout	rts
onfire	move.w	turn,d1
	move.w	fire(a0),d0
	and.w	#7,d1
	cmp.w	#100,d0
	bgt	often
	cmp.w	#50,d0
	bge	oft2
	cmp.w	#0,d1
	bne	plout
	bra	dofire
oft2	and.w	#3,d1
	cmp.w	#0,d1
	bne	plout
	bra	dofire
often	btst	#0,d1
	bne	plout
dofire	move.w	x(a0),d0
	move.w	y(a0),d1
	addq	#8,d0
	addq	#2,d1
	lsl.w	#5,d0
	lsl.w	#5,d1
	bsr	random
	and.w	#63,d7
	sub.w	#32,d7
	move.w	d7,d3
	bsr	random
	and.w	#31,d7
	sub.w	#32,d7
	move.w	d7,d4
	bsr	makeprt
	rts
fire?	cmp.w	#0,str(a0)
	beq	fireret
	cmp.w	#0,ammo(a0)
	beq	fireret
	move.w	str(a0),d0
	move.w	#0,str(a0)
	move.w	#25,reload(a0)
	add.w	#minstr,d0
	lea	sintab,a1
	move.w	elev(a0),d2
	move.w	d0,d1
	mulu.w	2(a1,d2.w),d0
	mulu.w	(a1,d2.w),d1
	moveq	#14,d3
	lsr.l	d3,d0
	lsr.l	d3,d1
	not.w	d1
	addq.w	#1,d1
	cmp.w	#0,playr(a0)
	beq	notrevr
	not.w	d0
	addq.w	#1,d0
notrevr	and.l	#$fff,d2
	lsr.w	#2,d2
	add.w	#2,d2
	divu.w	#12,d2
	lsl.w	#2,d2
	move.w	x(a0),d3
	move.w	y(a0),d4
	add.w	ftab(a0,d2.w),d3
	add.w	ftab+2(a0,d2.w),d4
	lsl.w	#5,d3
	lsl.w	#5,d4
	move.w	playr(a0),d5
	addq.w	#1,d5
	bsr	makebul
	sub.w	#1,ammo(a0)
	bsr	ammcls
	bsr	ammgraf
	bsr	powcls
	lea	reloadl,a1
	cmp.w	#0,playr(a0)
	beq	noch10
	lea	reloadr,a1
noch10	move.l	a0,-(sp)
	movea.l	a1,a0
	bsr	print
	movea.l	(sp)+,a0
	bset	#2,newsam
	bra	fireret
incelev	add.w	#4,elev(a0)
	cmp.w	#90*4,elev(a0)
	ble	calcefr
	move.w	#90*4,elev(a0)
	bra	vtret
calcefr	move.w	minf(a0),d2
	add.w	#4*80,d2
	move.w	elev(a0),d3
	addq.w	#8,d3
	divu.w	#12*4,d3
	move.w	d3,d4
	add.w	d3,d3
	add.w	d3,d3
	add.w	d4,d3
	lsl.w	#4,d3
	add.w	d3,d2
	move.w	d2,elevfr(a0)
	bra	vtret
decelev	sub.w	#4,elev(a0)
	cmp.w	#0,elev(a0)
	bge	calcefr
	move.w	#0,elev(a0)
	bra	vtret
lft	sub.w	#1,x(a0)
	move.w	x(a0),d1
	cmp.w	minx(a0),d1
	bgt	animl
	move.w	minx(a0),x(a0)
	bra	hzret
animl	sub.w	#80,gr(a0)
	move.w	gr(a0),d1
	cmp.w	minf(a0),d1
	bge	hzret
	move.w	maxf(a0),gr(a0)
	bra	hzret
rgt	add.w	#1,x(a0)
	move.w	x(a0),d1
	cmp.w	maxx(a0),d1
	blt	animr
	move.w	maxx(a0),x(a0)
	bra	hzret
animr	add.w	#80,gr(a0)
	move.w	gr(a0),d1
	cmp.w	maxf(a0),d1
	ble	hzret
	move.w	minf(a0),gr(a0)
	bra	hzret
repairs	and.w	#%10001111,d0
	cmp.w	#0,d0
	bne	noreps
	cmp.w	#0,fire(a0)
	beq	nofire
	sub.w	#1,fire(a0)
nofire	cmp.w	#0,turret(a0)
	beq	noturr
	sub.w	#1,turret(a0)
noturr	cmp.w	#0,track(a0)
	beq	notrak
	sub.w	#1,track(a0)
notrak	cmp.w	#0,gun(a0)
	beq	noreps
	sub.w	#1,gun(a0)
noreps	rts

* Bars
ammgraf	lea	backbuf,a1		* draw ammo bar
	move.w	ammo(a0),d1
	adda.l	#160*1+4,a1
	cmp.w	#0,playr(a0)
	beq	nochad8
	adda.l	#16*8,a1
nochad8	bra	graf
ammcls	lea	backbuf,a1		* clear ammo bar
	move.w	#56,d1
	adda.l	#160*1+4,a1
	cmp.w	#0,playr(a0)
	beq	nochad9
	adda.l	#16*8,a1
nochad9	move.w	#0,d2
	bra	graflp
damgraf	lea	backbuf,a1		* draw damage bar
	move.w	damage(a0),d1
	adda.l	#160*9+4,a1
	cmp.w	#0,playr(a0)
	beq	nochad6
	adda.l	#16*8,a1
nochad6	bra	graf
damcls	lea	backbuf,a1		* clear damage bar
	move.w	#56,d1
	adda.l	#160*9+4,a1
	cmp.w	#0,playr(a0)
	beq	nochad7
	adda.l	#16*8,a1
nochad7	move.w	#0,d2
	bra	graflp
powgraf	lea	backbuf,a1		* draw power bar
	move.w	str(a0),d1
	adda.l	#160*17+4,a1
	cmp.w	#0,playr(a0)
	beq	nochad3
	adda.l	#16*8,a1
nochad3	bra	graf
powcls	lea	backbuf,a1		* clear power bar
	move.w	#56,d1
	adda.l	#160*17+4,a1
	cmp.w	#0,playr(a0)
	beq	nochad5
	adda.l	#16*8,a1
nochad5	move.w	#0,d2
	bra	graflp
graf	cmp.w	#0,d1			* draw a bar
	beq	grafout
	move.w	#65535,d2
graflp	cmp.w	#16,d1
	blt	endbit
	move.w	d2,(a1)
	move.w	d2,160(a1)
	move.w	d2,320(a1)
	move.w	d2,480(a1)
	move.w	d2,640(a1)
	move.w	d2,800(a1)
	addq.l	#8,a1
	sub.w	#16,d1
	bne	graflp
grafout	rts
endbit	moveq	#0,d3
	not.w	d1
	and.w	#15,d1
endlp	add.w	d3,d3
	or.w	#1,d3
	dbra.w	d1,endlp
	not.w	d3
	and.w	d3,d2
	move.w	d2,(a1)
	move.w	d2,160(a1)
	move.w	d2,320(a1)
	move.w	d2,480(a1)
	move.w	d2,640(a1)
	move.w	d2,800(a1)
	rts
	
* Print

print	lea	font,a1		* print an ascii string
prloop	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.w	#0,d0
	bne	prcont
	rts
prcont	cmp.w	#1,d0
	beq	prat
	cmp.w	#32,d0
	beq	space
	cmp.w	#64,d0
	bgt	char
	sub.w	#48,d0
charrej	lsl.w	#4,d0
	move.b	(a1,d0.w),(a2)
	move.b	2(a1,d0.w),160(a2)
	move.b	4(a1,d0.w),320(a2)
	move.b	6(a1,d0.w),480(a2)
	move.b	8(a1,d0.w),640(a2)
	move.b	10(a1,d0.w),800(a2)
	move.b	12(a1,d0.w),960(a2)
	move.b	14(a1,d0.w),1120(a2)
	addq.l	#1,a2
	not.w	d1
	cmp.w	#0,d1
	bne	prloop
	addq.l	#6,a2
	bra	prloop
char	sub.w	#55,d0
	bra	charrej
space	move.w	#36,d0
	bra	charrej
prat	movea.l	defscr,a2
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d1,d2
	lsl.w	#8,d2
	moveq	#0,d1
	btst	#0,d0
	beq	notff
	move.w	#$ffff,d1
	addq.w	#1,d2
notff	and.w	#$fe,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d2
	lea	(a2,d2.w),a2
	bra	prloop
	
* Bullets

makebul	lea	bultab,a1		* make a bullet
	move.w	#maxbul-1,d2
bullp	cmp.w	#0,(a1)
	beq	gotbul
	adda.l	#10,a1
	dbra.w	d2,bullp
	rts
gotbul	move.w	d5,(a1)
	move.w	d3,2(a1)
	move.w	d4,4(a1)
	move.w	d0,6(a1)
	move.w	d1,8(a1)
	rts
	
dobull	lea	bultab,a1		* do bullets
	move.w	#maxbul-1,d2
dobullp	cmp.w	#0,(a1)
	beq	nextbul
	move.w	2(a1),d0
	move.w	4(a1),d1
	add.w	6(a1),d0
	add.w	8(a1),d1
	add.w	#1,8(a1)
	move.w	d0,2(a1)
	move.w	d1,4(a1)
	asr.w	#5,d0
	asr.w	#5,d1
	cmp.w	#0,d0
	blt	deadbul
	cmp.w	#320,d0
	bge	deadbul
	cmp.w	maxhill,d1
	ble	birdch
	bsr	point
	cmp.w	#0,d0
	bne	hitsmf
	bra	nextbul
birdch	cmp.w	#3,(a1)
	beq	nextbul
	lea	birddat,a0
	move.w	#maxbird-1,d3
	subq	#1,d0
	subq	#1,d1
	move.w	d0,d4
	move.w	d1,d5
	addq.w	#4,d4
	addq.w	#3,d5
birdlp2	cmp.w	#0,(a0)
	beq	nxtb2
	cmp.w	2(a0),d0
	bgt	nxtb2
	cmp.w	2(a0),d4
	blt	nxtb2
	cmp.w	4(a0),d1
	bgt	nxtb2
	cmp.w	4(a0),d5
	blt	nxtb2
	move.w	#0,(a0)
	lea	partdat,a2
	move.w	#maxprt-1,d5
	move.w	#15,d4
	move.w	2(a0),d0
	move.w	4(a0),d1
	lsl.w	#5,d0
	lsl.w	#5,d1
prtlp2	cmp.w	#0,(a2)
	bne	nxprt
	move.w	#30,(a2)
	move.w	d0,2(a2)
	move.w	d1,4(a2)
	bsr	random
	and.w	#63,d7
	sub.w	#32,d7
	move.w	d7,6(a2)
	bsr	random
	and.w	#63,d7
	sub.w	#32,d7
	move.w	d7,8(a2)
	sub.w	#1,d4
	beq	carryon
nxprt	adda.l	#10,a2
	dbra.w	d5,prtlp2
carryon	lea	player1,a0
	cmp.w	#1,(a1)
	beq	chplay
	lea	player2,a0
chplay	add.w	#15,ammo(a0)
	cmp.w	#56,ammo(a0)
	ble	okammo
	move.w	#56,ammo(a0)
okammo	move.l	a1,-(sp)
	move.w	d2,-(sp)
	bsr	ammgraf
	move.w	(sp)+,d2
	movea.l	(sp)+,a1
	bset	#1,newsam
	bra	deadbul
nxtb2	addq.l	#6,a0
	dbra.w	d3,birdlp2
	cmpi.w	#0,specon
	beq	nextbul
	move.w	specon,d6
	subq.w	#1,d6
	lsl.w	#3,d6
	lea	coldat,a6
	lea	(a6,d6.w),a6
	move.w	2(a1),d3
	move.w	4(a1),d4
	asr.w	#5,d3
	asr.w	#5,d4
	move.w	specx,d0
	move.w	specy,d1
	add.w	(a6),d0
	add.w	2(a6),d1
	cmp.w	d3,d0
	bgt	nextbul
	cmp.w	d4,d1
	bgt	nextbul
	move.w	specx,d0
	move.w	specy,d1
	add.w	4(a6),d0
	add.w	6(a6),d1
	cmp.w	d3,d0
	blt	nextbul
	cmp.w	d4,d1
	blt	nextbul
	move.w	(a6),d0
	move.w	2(a6),d1
	add.w	4(a6),d0
	add.w	6(a6),d1
	lsr.w	#1,d0
	lsr.w	#1,d1
	add.w	specx,d0
	add.w	specy,d1
	lea	partdat,a2
	move.w	#maxprt-1,d5
	move.w	#24,d4
	lsl.w	#5,d0
	lsl.w	#5,d1
prtlp3	cmp.w	#0,(a2)
	bne	nxprt3
	move.w	#50,(a2)
	move.w	d0,2(a2)
	move.w	d1,4(a2)
	bsr	random
	and.w	#63,d7
	sub.w	#32,d7
	move.w	d7,6(a2)
	bsr	random
	and.w	#63,d7
	sub.w	#32,d7
	move.w	d7,8(a2)
	sub.w	#1,d4
	beq	carry
nxprt3	adda.l	#10,a2
	dbra.w	d5,prtlp3
	
carry
	move.w	6(a1),d0
	lea	player2,a0
	cmp.w	#0,d0
	beq	nohzsp
	blt	rgtplay
	lea	player1,a0
	bra	rgtplay
nohzsp	cmp.w	#160,d3
	bgt	rgtplay
	lea	player1,a0
rgtplay	cmp.w	#2,specon
	beq	gotst
	blt	gotsauc
	move.w	#0,specon
	bset	#5,newsam
	move.l	a1,-(sp)	
	move.w	d2,-(sp)
	bsr	doeff
	move.w	(sp)+,d2
	move.l	(sp)+,a1
	bra	deadbul
gotst	move.w	#0,specon
	bset	#0,newsam
	move.w	#56,damage(a0)
	move.l	a1,-(sp)	
	move.w	d2,-(sp)
	bsr	damgraf
	move.w	(sp)+,d2
	move.l	(sp)+,a1
	bra	deadbul
gotsauc	move.w	#0,specon
	bset	#0,newsam
	bra	deadbul
nextbul	adda.l	#10,a1
	dbra.w	d2,dobullp
	lea	bultab,a1
	move.w	#maxbul-1,d0
bullp2	cmp.w	#0,(a1)
	beq	nxtbul
	move.w	2(a1),d4
	move.w	4(a1),d5
	cmp.w	#0,d5
	blt	nxtbul
	lsr.w	#5,d4
	lsr.w	#5,d5
	move.w	#8,d6
	bsr	plot
nxtbul	adda.l	#10,a1
	dbra.w	d0,bullp2
	rts
hitsmf	move.w	2(a1),d0
	move.w	4(a1),d1
	lsr.w	#5,d0
	lsr.w	#5,d1
	cmp.w	#199,d0
	bgt	otherpl
	cmp.w	#120,d0
	bgt	deadbul
	lea	player1,a0
	move.w	x(a0),d6
	cmp.w	d6,d0
	blt	deadbul
	add.w	#15,d6
	cmp.w	d6,d0
	bgt	deadbul
	move.w	y(a0),d7
	subq.w	#3,d7
	cmp.w	d7,d1
	blt	deadbul
	add.w	#11,d7
	cmp.w	d7,d1
	bgt	deadbul
	bra	dodam
otherpl	lea	player2,a0
	move.w	x(a0),d6
	cmp.w	d6,d0
	blt	deadbul
	add.w	#15,d6
	cmp.w	d6,d0
	bgt	deadbul
	move.w	y(a0),d7
	subq.w	#3,d7
	cmp.w	d7,d1
	blt	deadbul
	add.w	#11,d7
	cmp.w	d7,d1
	bgt	deadbul
dodam	bsr	random
	and.w	#15,d7
	addq.w	#8,d7
	sub.w	d7,damage(a0)
	cmp.w	#0,damage(a0)
	bge	okdam
	move.w	#0,damage(a0)
okdam	cmp.w	#12,d7
	ble	dobar
	bsr	random
	move.w	d7,d0
	and.w	#15,d0
	cmp.w	#6,d0
	blt	cfire
	cmp.w	#10,d0
	blt	tjam
	cmp.w	#13,d0
	blt	gjam
	bsr	random
	and.w	#127,d7
	add.w	#200,d7
	move.w	d7,track(a0)
	bra	dobar
cfire	bsr	random
	and.w	#255,d7
	add.w	#150,d7
	move.w	d7,fire(a0)
	bra	dobar
tjam	bsr	random
	and.w	#63,d7
	add.w	#150,d7
	move.w	d7,turret(a0)
	bra	dobar
gjam	bsr	random
	and.w	#63,d7
	add.w	#200,d7
	move.w	d7,gun(a0)
	bsr	powcls
	move.w	#0,str(a0)
dobar	move.l	a1,-(sp)
	move.w	d2,-(sp)
	bsr	damcls
	bsr	damgraf
	move.w	(sp)+,d2
	movea.l	(sp)+,a1
	move.w	2(a1),d0
	move.w	4(a1),d1
	move.l	a1,-(sp)
	move.w	d2,-(sp)
	moveq	#5,d5
mloop	bsr	random
	and.w	#63,d7
	sub.w	#32,d7
	move.w	d7,d3
	bsr	random
	and.w	#31,d7
	sub.w	#32,d7
	move.w	d7,d4
	bsr	makeprt
	dbra.w	d5,mloop
	move.w	(sp)+,d2
	movea.l	(sp)+,a1
	bset	#3,newsam
	cmp.w	#0,damage(a0)
	beq	deadplx
deadbul	move.w	#0,(a1)
	bra	nextbul
deadplx	cmp.w	#0,dead(a0)
	bne	deadbul
	move.w	#1,dead(a0)
	move.w	#1,fire(a0)
	move.w	x(a0),d0
	move.w	y(a0),d1
	addq	#8,d0
	addq	#1,d1
	lsl.w	#5,d0
	lsl.w	#5,d1
	move.w	#30,d5
mloop2	bsr	random
	and.w	#127,d7
	sub.w	#64,d7
	move.w	d7,d3
	bsr	random
	and.w	#63,d7
	sub.w	#64,d7
	move.w	d7,d4
	bsr	makeprt
	dbra.w	d5,mloop2
	bset	#0,newsam
	rts
doeff	bsr	random
	move.w	d7,d0
	and.w	#15,d0
	cmp.w	#6,d0
	blt	cfire2
	cmp.w	#10,d0
	blt	tjam2
	cmp.w	#13,d0
	blt	gjam2
	bsr	random
	and.w	#127,d7
	add.w	#200,d7
	move.w	d7,track(a0)
	rts
cfire2	bsr	random
	and.w	#255,d7
	add.w	#150,d7
	move.w	d7,fire(a0)
	rts
tjam2	bsr	random
	and.w	#63,d7
	add.w	#150,d7
	move.w	d7,turret(a0)
	rts
gjam2	bsr	random
	and.w	#63,d7
	add.w	#200,d7
	move.w	d7,gun(a0)
	bsr	powcls
	move.w	#0,str(a0)
	rts
	
* Explosion particles

makeprt	lea	partdat,a1		* make a particle
	move.w	#maxprt-1,d2
prtlp	cmp.w	#0,(a1)
	beq	gotprt
	adda.l	#10,a1
	dbra.w	d2,prtlp
	rts
gotprt	move.w	#50,(a1)
	move.w	d0,2(a1)
	move.w	d1,4(a1)
	move.w	d3,6(a1)
	move.w	d4,8(a1)
	rts
doparts	lea	partdat,a1		* do the particles
	move.w	#maxprt-1,d2
partlp	cmp.w	#0,(a1)
	beq	nextprt
	sub.w	#1,(a1)
	move.w	2(a1),d4
	move.w	4(a1),d5
	add.w	#1,8(a1)
	add.w	6(a1),d4
	add.w	8(a1),d5
	move.w	d4,2(a1)
	move.w	d5,4(a1)
	cmp.w	#320*32,d4
	bge	killprt
	cmp.w	#0,d4
	blt	killprt
	cmp.w	#192*32,d5
	bge	killprt
	lsr.w	#5,d5
	lsr.w	#5,d4
	move.w	(a1),d6
	lsr.w	#4,d6
	cmp.w	#3,d6
	bne	okd6
	moveq	#2,d6
okd6	add.w	#12,d6
	bsr	plot
nextprt	adda.l	#10,a1
	dbra.w	d2,partlp
	rts
killprt	move.w	#0,(a1)
	bra	nextprt

* "Birds"

dobirds	lea	birddat,a1		* do the birds
	move.w	#maxbird-1,d2
birdlp	cmp.w	#0,(a1)
	beq	nxtbird
	move.w	d2,-(sp)
	move.w	2(a1),d0
	move.w	4(a1),d1
	move.w	turn,d2
	and.w	#3,d2
	cmp.w	#0,d2
	bne	dont
	moveq	#6,d2
	moveq	#9,d3
	moveq	#6,d4
	moveq	#9,d5
	cmp.w	#120,d0
	blt	morer
	cmp.w	#200,d0
	blt	asisx
	moveq	#10,d2
	moveq	#13,d3
asisx	cmp.w	#16,d1
	blt	mored
	move.w	maxhill,d6
	sub.w	#16,d6
	cmp.w	d6,d1
	blt	asisy
	moveq	#10,d4
	moveq	#13,d5
	cmp.w	maxhill,d1	* Don't go below
	blt	asisy		* hill level!!
	moveq	#15,d4
asisy	bsr	random
	and.w	#15,d7
	cmp.w	d7,d2
	bge	movel
	cmp.w	d7,d3
	bgt	stayx
	addq	#1,d0
stayx	bsr	random
	and.w	#15,d7
	cmp.w	d7,d4
	bge	moveu
	cmp.w	d7,d5
	bgt	stayy
	addq	#1,d1
stayy	move.w	d0,2(a1)
	move.w	d1,4(a1)
	cmp.w	#0,d0
	blt	deadbrd
	cmp.w	#320-3,d0
	bgt	deadbrd
	add.w	#1,(a1)
	cmp.w	#3,(a1)
	bne	wingu
wingd	move.w	#1,(a1)
	move.w	d0,d4
	addq	#1,d1
	move.w	d1,d5
	moveq	#9,d6
	bsr	plot
	move.w	d0,d4
	move.w	d1,d5
	addq	#1,d4
	moveq	#8,d6
	bsr	plot
	move.w	d0,d4
	move.w	d1,d5
	addq	#2,d4
	moveq	#9,d6
	bsr	plot
	bra	nxbird
wingu	move.w	d0,d4
	move.w	d1,d5
	moveq	#8,d6
	bsr	plot
	move.w	d0,d4
	move.w	d1,d5
	addq	#1,d4
	addq	#1,d5
	moveq	#8,d6
	bsr	plot
	move.w	d0,d4
	move.w	d1,d5
	addq	#2,d4
	moveq	#8,d6
	bsr	plot
nxbird	move.w	(sp)+,d2
nxtbird	addq.l	#6,a1
	dbra.w	d2,birdlp
	btst	#0,turn+1
	beq	birdout
	bsr	random
	and.w	#255,d7
	cmp.w	#0,d7
	bne	birdout
	lea	birddat,a1
	move.w	#maxbird-1,d2
bloop	cmp.w	#0,(a1)
	bne	nxb
	move.w	#1,(a1)
	bsr	random
	and.w	#255,d7
	add.w	#32,d7
	move.w	d7,2(a1)
	move.w	#-2,4(a1)
	rts
nxb	addq.l	#6,a1
	dbra.w	d2,bloop
birdout	rts
deadbrd	move.w	#0,(a1)
	bra	nxbird
dont	btst	#0,d2
	beq	stayy
	cmp.w	#1,(a1)
	beq	wingd
	bra	wingu
moveu	subq	#1,d1
	bra	stayy
movel	subq	#1,d0
	bra	stayx
morer	moveq	#2,d2
	moveq	#5,d3
	bra	asisx
mored	moveq	#2,d4
	moveq	#5,d5
	bra	asisy

* "Fractal Hill"
fract	move.w	#319,d0		* make a hill
	lea	htbuf,a0
filllp	move.b	#7,(a0)+
	dbra.w	d0,filllp
	lea	htbuf+120,a0
	bsr	random
	and.w	#63,d7
	add.w	#50,d7
	move.w	#190,d6
	sub.w	d7,d6
	move.w	d6,maxhill
	move.w	d7,fmax
	move.b	d7,39(a0)
	move.b	d7,40(a0)
	moveq	#1,d0
	move.w	#40,d1
	move.w	d7,d5
fraclp1	moveq	#0,d2
	move.w	d5,d2
	moveq	#0,d3
	move.b	-1(a0),d3
	sub.l	d3,d2
	divs.w	d1,d2
	add.w	d3,d2
	bsr	random
	and.w	#7,d7
	sub.w	#3,d7
	add.w	d7,d2
	move.b	d2,(a0)+
	subq.w	#1,d1
	cmp.w	#1,d1
	bne	fraclp1
	lea	htbuf+200,a0
	move.w	#40,d1
	moveq	#0,d5
	move.b	-40(a0),d5
fraclp2	moveq	#0,d2
	move.w	d5,d2
	moveq	#0,d3
	move.b	(a0),d3
	sub.l	d3,d2
	divs.w	d1,d2
	add.w	d3,d2
	bsr	random
	and.w	#7,d7
	sub.w	#3,d7
	add.w	d7,d2
	move.b	d2,-(a0)
	subq.w	#1,d1
	cmp.w	#1,d1
	bne	fraclp2
drawhil	lea	backbuf,a0
	adda.l	#160*199,a0
	lea	htbuf,a1
	move.w	#19,d0
drawlp1	move.w	#32768,d1
drawlp2	moveq	#0,d2
	move.b	(a1)+,d2
	movea.l	a0,a2
drawlp3	or.w	d1,2(a2)
	sub.l	#160,a2
	dbra.w	d2,drawlp3
	lsr.w	#1,d1
	cmp.w	#0,d1
	bne	drawlp2
	adda.l	#8,a0
	dbra.w	d0,drawlp1
	rts
random	movem.l	d0-d3/a0-a3,-(sp)		* guess!!
	move.w	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,d7
	movem.l	(sp)+,d0-d3/a0-a3
	rts
	
setup	dc.w	$a000				* set up the environ
	dc.w	$a00a
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.b	$484,oldkey
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
	addq	#6,sp
	rts
swap	movea.l	back,a4		* screen swap
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
joys	move.w	#$22,-(sp)		* set up joystick
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
	rts
joy	move.l	a1,-(sp)		;0=up	* joystick routine
	lea	joy0,a1			;1=down
	move.b	1(a0),(a1)		;2=left
	move.b	2(a0),1(a1)		;3=right
	movea.l	(sp)+,a1		;7=fire
	rts
joy0	dc.b	0
joy1	dc.b	0
plot	cmp.w	#0,d5			* plot a point
	blt	plotout
	move.w	d5,d7
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
plotout	rts
point	move.w	d1,d7			* test a point
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d1
	lsl.w	#5,d1		*160
	move.w	d0,d7
	lsr.w	#4,d7
	lsl.w	#3,d7
	add.w	d7,d1
	lsl.w	#1,d7
	sub.w	d7,d0
	and.l	#$ffff,d1
	movea.l	back,a5
	adda.l	d1,a5
	move.w	#32768,d7
	lsr.w	d0,d7
	move.w	(a5)+,d0
	or.w	(a5)+,d0
	or.w	(a5)+,d0
	or.w	(a5),d0
	and.w	d7,d0
	rts
cls	movea.l	back,a6		* cls
cls2	move.w	#199,d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	#0,a0
	movea.l	#0,a1
	movea.l	#0,a2
	movea.l	#0,a3
	movea.l	#0,a4
	movea.l	#0,a5
clsloop	movem.l	d0-d6/a0-a5,(a6)
	movem.l	d0-d6/a0-a5,52(a6)
	movem.l	d0-d6/a0-a5,104(a6)
	move.l	d0,156(a6)
	adda.l	#160,a6
	dbra.w	d7,clsloop
	rts
copbuf	lea	backbuf,a0		* copy the buffer
	movea.l	back,a1
	move.w	#199,d0
coploop	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a1)
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48(a1)
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,96(a1)
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,144(a1)
	adda.l	#160,a1
	dbra.w	d0,coploop
	rts
spr16	lea	sprites,a5		* 16x16 sprite
spr2	lea	(a5,d2.w),a5
	movea.l	back,a6
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
retgen	dc.w	$a009			* return to gen
	move.b	#$8,$fffc02
	jsr	samstop
	pea	pal2
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	move.b	oldkey,$484
	move.w	#1,-(sp)
	move.l	#$f8000,-(sp)
	move.l	#$f8000,-(sp)
	move.w	#5,-(Sp)
	trap	#14
	lea	12(sp),sp
	clr.w	-(sp)
	trap	#1
pal2	dc.w	$777,$000,$000,$000
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	
	include	"a:\tanx\samplay.s"
palette	dc.w	$000,$141,$020,$777
	dc.w	$600,$050,$550,$000
	dc.w	$444,$333,$000,$111
	dc.w	$400,$600,$641,$000	
physic	dc.l	$78000
back	dc.l	$70000
back2	dc.l	$68000
defscr	dc.l	$78000
seed	dc.w	0
newload	dc.w	1
maxhill	dc.w	0
fmax	dc.w	0
startb	dc.w	3
turn	dc.w	0
sprites	incbin	"a:\tanx\data\tank.dat"
sintab	incbin	"a:\tanx\data\sintab.dat"
extra	incbin	"a:\tanx\data\tankplus.dat"
font	incbin	"a:\tanx\data\font.dat"
	ds.w	8

* Player data

player1	
p1x	dc.w	20
p1y	dc.w	200-16
p1hits	dc.w	0
p1gr	dc.w	0
p1elev	dc.w	0
p1elevf	dc.w	4*80
reload1	dc.w	0
p1str	dc.w	0
p1ammo	dc.w	56
p1maxx	dc.w	104
p1minx	dc.w	0
p1minf	dc.w	0
p1maxf	dc.w	3*80
p1playr	dc.w	0
p1dam	dc.w	56
p1fire	dc.w	1
p1tur	dc.w	0
p1gun	dc.w	0
p1track	dc.w	0
p1dead	dc.w	99
p1ftab	dc.w	14,1,14,0,13,-1,13,-2,11,-4,10,-4,9,-5,8,-5

player2	
p2x	dc.w	284
p2y	dc.w	200-16
p2hits	dc.w	0
p2gr	dc.w	12*80
p2elev	dc.w	0
p2elevf	dc.w	16*80
reload2	dc.w	0
p2str	dc.w	0
p2ammo	dc.w	56
p2maxx	dc.w	304
p2minx	dc.w	200
p2minf	dc.w	12*80
p2maxf	dc.w	15*80
p2playr	dc.w	1
p2dam	dc.w	56
p2fire	dc.w	1
p2tur	dc.w	0
p2gun	dc.w	0
p2track	dc.w	0
p2dead	dc.w	70
p2ftab	dc.w	1,1,1,0,2,-1,2,-2,4,-4,5,-4,6,-5,7,-5

specials
specon	dc.w	0
specx	dc.w	0
specy	dc.w	0
specxs	dc.w	0
specgr	dc.w	0

coldat	dc.w	0,1,15,8
	dc.w	0,0,15,11
	dc.w	1,1,14,14

* Text
stats
ammol	dc.b	1,0,0,"AMMO",0
ammor	dc.b	1,32,0,"AMMO",0
	dc.b	1,0,2,"POWER"
	dc.b	1,32,2,"POWER"
	dc.b	1,0,1,"DAMAGE"
	dc.b	1,32,1,"DAMAGE",0
reloadl	dc.b	1,0,3,"RELOAD",0
reloadr	dc.b	1,32,3,"RELOAD",0
norell	dc.b	1,0,3,"      ",0
norelr	dc.b	1,32,3,"      ",0
p1win	dc.b	1,5,4,"THE WINNER",0
p2win	dc.b	1,25,4,"THE WINNER",0
comtxt	dc.b	1,14,5,"PRESS SPACE",0
drawtxt	dc.b	1,16,4,"A DRAW",0
titltxt	dc.b	1,5,10,"TANX",1,6,12,"BY"
	dc.b	1,0,13,"MARTIN BROWNLOW"
	dc.b	1,0,15,"TANK SPRITES BY"
	dc.b	1,1,16,"MARK SHILLING"
	dc.b	1,29,10,"CONTROLS"
	dc.b	1,25,12,"UP   FIRE ANGLE"
	dc.b	1,25,13,"DOWN"
	dc.b	1,25,15,"LEFT  MOVE TANK"
	dc.b	1,25,16,"RIGHT"
	dc.b	1,25,18,"FIRE SHOT POWER",0
 even

************************

	SECTION	BSS

oldkey	ds.b	1
flags	ds.w	1
bultab	ds.w	5*maxbul
partdat	ds.w	5*maxprt
birddat	ds.w	3*maxbird
htbuf	ds.b	320	
backbuf	ds.l	8000
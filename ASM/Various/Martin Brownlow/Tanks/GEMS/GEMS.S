* Gems
* Source code by Martin Brownlow (c) 1992
* Music produced using EdSynth

* cheat mode = "playtest"
* on title screen (lower case)
* then keypad does nice things..


* Defines

maxrock	equ	8

philtyp	equ	0
firetyp	equ	4
eyetyp	equ	8
wormtyp	equ	12

stand	equ	0
runl	equ	80
runr	equ	5*80
updown	equ	9*80
falldwn	equ	13*80
maskgr	equ	14*80
rockgr	equ	15*80
splatpl	equ	16*80
splatbl	equ	17*80
blob1	equ	18*80
blob4	equ	21*80
blob5	equ	22*80
angel1	equ	22*80
angel4	equ	25*80
fire1	equ	26*80
fire4	equ	28*80
eye1	equ	29*80
eye4	equ	32*80
splatfl	equ	33*80
phil1	equ	34*80
phil4	equ	37*80
splatph	equ	38*80
worm1	equ	39*80
worm4	equ	42*80

demongr	equ	43*80

diamond	equ	6
gwdiamd	equ	10
wall	equ	11
rock	equ	12

brion	equ	0
bricnt	equ	1
brix	equ	2
briy	equ	4
bridir	equ	6
briint	equ	8
brimty	equ	10
brimvlf	equ	12
brimask	equ	14
brionsq	equ	16

* Program

start	move.l	#1,tune
	bsr	setup		* set it up
	bsr	joys		* set joystick going
	move.w	#0,diffic	* difficulty level
title	bsr	sndres		* reset sound chip
	move.w	#0,cmdis
	move.l	#1,tune		* select no tune
	move.w	#0,tunecnt
titrej	move.b	#0,joy1		* blank joystick (??)
	lea	backbuf,a6
	bsr	cls2		* clear backbuf
	lea	backbuf,a6
	lea	titpic,a0	* draw title screen
	move.w	#7,d1
	bsr	newrow
	lea	highsp,a0	* do high score
	moveq	#0,d0
	move.w	high,d0
	bsr	doasc
	lea	lastsc,a0	* do last score
	moveq	#0,d0
	move.w	score,d0
	bsr	doasc
	lea	tittxt1,a0	* do title screen text
	bsr	print
	lea	easylev,a0
	move.w	#0,level
	cmp.w	#1,diffic
	blt	printlv
	beq	medlev
	lea	hardlev,a0
	move.w	#20,level
	bra	printlv
medlev	lea	normlev,a0
	move.w	#8,level
printlv	bsr	print		* print difficulty text
	bsr	copbuf		* copy buffer to back
	bsr	swap		* swap screens
tloop	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1		* key been pressed? 
	addq	#4,sp
	cmp.w	#32,d0		* space = quit
	beq	retgen
	sub.w	#97,d0		* lower case letter?
	bcs	notcm		* no.
	lea	cheatst,a0	* Is it the next letter in
	move.w	cmdis,d1	* cheat mode?
	cmp.b	(a0,d1.w),d0
	beq	nxtchtc		* yes
	move.w	#0,cmdis	* if no, reset cheat mode string
	bra	notcm
nxtchtc	add.w	#1,cmdis	* next letter
	cmp.w	#8,cmdis	* finished it?
	bne	notcm		* no
	move.w	#1,chon		* put ch mode on
	move.w	#1,flash	* flash screen
notcm	btst	#2,joy1		* left pressed?
	beq	notddf
	cmp.w	#0,diffic	* change difficulty
	beq	notddf
	sub.w	#1,diffic
	bclr	#2,joy1
	bra	titrej
notddf	btst	#3,joy1		* right pressed?
	beq	notindf
	bclr	#3,joy1
	cmp.w	#2,diffic	* change difficulty
	beq	notindf
	add.w	#1,diffic
	bra	titrej
notindf	btst	#7,joy1		* fire?
	beq	tloop		* no, go back to title loop
	
newgame	move.b	#0,dislen	* set stuff up for a new game
	move.l	#0,tune
	move.w	level,baselev
	move.w	#0,bad2typ
	move.w	#0,score
	move.w	#2,lives
	move.w	#1000,ltpnt
	move.w	#0,plane

newlife	bsr	sndres		* new life routine
	move.l	#0,tune		* no tune
	move.w	#0,tunecnt	* set lots of stuff up.
	move.b	#0,dislen
	move.w	#0,turn
	move.w	#0,dead
	move.w	#0,diagot
	move.w	#0,diacar
	move.w	#272,youx
	move.w	#8,youy
	move.w	#0,yougr
	move.w	#0,dir
	bsr	makebad
	move.w	level,d0
	mulu.w	#420,d0
	lea	levels,a0
	adda.l	d0,a0
	bsr	makelev		* print level
	bsr	doscorz		* and scores
	bsr	dodia		* and diamonds
	bsr	dolives		* and lives
	bsr	dolevel
	
	bsr	copbuf		* copy screen
	move.w	bri1x,d0	* this bit prints "BRIAN"
	move.w	bri1y,d1
	add.w	#16,d1
	move.w	#blob1,d2
	moveq	#7,d3
	bsr	spr16		* print him.
	move.w	youx,d0		* this bit prints you
	move.w	youy,d1
	add.w	#16,d1
	move.w	#stand,d2
	moveq	#7,d3
	bsr	spr16		* print you.
	bsr	swap		* swap screen
	move.w	#32,tunecnt
cntlp	cmp.w	#0,tunecnt	* wait for a little bit
	bne	cntlp

gamelp	bsr	copbuf		* copy buffer
	move.b	joy1,contpad	* move joy input to contpad
	bsr	moveyou		* move you
	bsr	rocks		* do any rocks
	lea	brian1,a4	* do brian
	bsr	brian
	bsr	bad2do		* do other baddy
	bsr	demondo		* do demon
	
	bsr	swap		* swap screen
	cmp.w	#0,dead		* are you dead?
	bne	nottop		* yes
	cmp.w	#8,youy		* are you at top?
	bgt	nottop		* no
	cmp.w	#0,diacar	* carrying any diamonds, sory, gems?
	beq	nottop		* no
	move.w	#1,flash	* flash screen
	move.w	diacar,d0
	add.w	d0,d0		* score = score + hold*2
	add.w	d0,score
	jsr	twiddle+4	* play twiddle
	move.l	#twiddle,tune
	lea	chann1,a0	* ??
	move.w	#20,tunecnt	* how long til twiddle done
	lea	chann3,a0
	bsr	nobad2
	move.w	#0,diacar	* empty hold
nottop	move.w	score,d0	* score changed from when
	cmp.w	oldsc,d0	* last printed?
	beq	noscup		* no
	bsr	doscore		* print score
	move.w	score,d0	* has score
	cmp.w	ltpnt,d0	* exceeded that needed for new life?
	blt	noscup		* no
	add.w	#1,lives	* add a new life
	add.w	#1000,ltpnt	* increase target
	bsr	dolives		* print new life
noscup	move.w	diacar,d0	* got any more diamonds?
	cmp.w	olddia,d0
	beq	nodiach		* no
	bsr	dodia		* print new HOLD
nodiach	cmp.w	#0,dead		* are you dead?
	bne	notfinl		* yes
	cmp.w	#5,dir		* are you falling?
	beq	notfinl
	cmp.w	#5,bri1dir	* is brian fallin?
	beq	notfinl
	cmp.w	#5,bad2dir	* is other baddy falling (??)
	beq	notfinl
	cmp.w	#30,diagot	* have you got all diamonds?
	blt	notfinl
	add.w	#1,diagot	* make small delay
	cmp.w	#33,diagot	* finished level?
	beq	nextlev		* yes
		
notfinl	add.w	#1,turn		* increase turn
	cmp.w	#32,turn
	bne	nincint
	move.w	#0,turn
	add.w	#1,bri1int	* make brian a little more "intelligent"
nincint	cmp.w	#0,dead		* are you dead?
	beq	keychk		* no
	btst	#7,contpad	* pressed fire?
	bne	loselif		* yes, goto lose life
	cmp.w	#-32,youy	* angel reached top?
	bgt	keychk		* no
	cmp.w	#0,tunecnt	* wait for tune to end
	bne	keychk
loselif	sub.w	#1,lives	* lose a life
	bcc	newlife
	bra	title
keychk	cmp.w	#110,bri1int	* LIMIT brian's intelligence
	ble	okbi
	move.w	#110,bri1int
okbi	move.w	#$ff,-(sp)	* key been pressed?
	move.w	#6,-(sp)
	trap	#1
	addq	#4,sp
	cmp.w	#32,d0		* space = exit
	beq	retgen
	cmp.w	#0,chon		* cheat mode on?
	beq	gamelp		* no, goto game loop
	swap	d0		* get key scancode
	cmp.w	#$4e,d0		* do nice cheat mode bits
	beq	newlev
	cmp.w	#$4a,d0
	beq	lastlev
	cmp.w	#$63,d0
	beq	baddown
	cmp.w	#$64,d0
	beq	badup
	cmp.w	#$67,d0
	beq	sbrioff
	cmp.w	#$68,d0
	beq	sbadoff
	cmp.w	#$69,d0
	beq	sdemoff
	cmp.w	#$6a,d0
	blt	gamelp
	cmp.w	#$70,d0
	bgt	gamelp
	swap	d0
	sub.w	#48,d0
	move.w	d0,lives
	bra	newlife
sbrioff	cmp.b	#0,bri1on
	beq	sbrion
	move.w	#127,bri1on
	bra	gamelp
sbrion	move.w	#256,bri1on
	move.w	#-16,bri1x
	move.w	#8,bri1y
	move.w	#0,bri1dir
	bra	gamelp
sbadoff	cmp.b	#0,bad2on
	beq	sbadon
	move.w	#127,bad2on
	bra	gamelp
sbadon	move.w	#256,bad2on
	move.w	#320,bad2x
	move.w	#8,bad2y
	move.w	#1,bad2dir
	move.w	#0,bad2gr
	bra	gamelp
sdemoff	cmp.w	#0,demon
	bne	sdemon
	move.w	#1024,demon
	bra	gamelp
sdemon	move.w	#0,demon
	move.w	#200,demony
	move.w	#152,demonx
	bra	gamelp	
baddown	sub.w	#4,bad2typ
	bcc	newlife
	move.w	#12,bad2typ
	bra	newlife
badup	add.w	#4,bad2typ
	cmp.w	#16,bad2typ
	bne	newlife
	move.w	#0,bad2typ
	bra	newlife
lastlev	move.w	level,d0
	cmp.w	baselev,d0
	beq	gamelp
	move.w	#0,bad2typ
	sub.w	#1,level
	bra	newlife
nextlev	add.w	#4,bad2typ	* routine to go up a level
	cmp.w	#36,level
	beq	finishg
	cmp.w	#16,bad2typ
	bne	newlife
newlev	move.w	#0,bad2typ
	add.w	#1,level
	cmp.w	#36,level
	beq	lstlev
	bgt	finishg
	cmp.w	#2,diffic
	beq	newlife
	cmp.w	#20,level
	beq	lstlev
	cmp.w	#1,diffic
	beq	newlife
	cmp.w	#8,level
	bne	newlife
lstlev	move.w	#36,level
	move.w	#4,bad2typ
	bra	newlife
finishg	move.l	#1,tune		* finished game effect
	bsr	sndres
	lea	titpic,a0
	lea	levbuf,a1
	move.w	#419,d0
c9to10l	move.b	(a0,d0.w),(a1,d0.w)
	cmp.b	#9,(a1,d0.w)
	bne	notc9
	move.b	#10,(a1,d0.w)
notc9	dbra.w	d0,c9to10l
	lea	backbuf+16*160,a6
	move.w	#21*8*40,d0
clrlp	clr.l	(a6)+
	dbra.w	d0,clrlp
	lea	backbuf+16*160,a6
	lea	levbuf,a0
	bsr	tlevel
	move.w	#12*8*160+136,d1
	lea	backbuf,a6
	lea	(a6,d1.w),a6
	move.w	#(gwdiamd-1)*64,d2
	bsr	putblok
	move.w	#0,youx
	move.w	#10*8,youy
	move.w	#stand,yougr
	move.w	#0,dir
	move.w	#7,turn
	move.w	#0,level
	add.w	#5000,score
	lea	finsct+3,a0
	moveq	#0,d0
	move.w	score,d0
	bsr	doasc
	bsr	doscorz
	lea	endtxt1,a0
	bsr	print
	cmp.w	#2,diffic
	beq	finlp
	lea	endtxt2,a0
	bsr	print
finlp	bsr	copbuf
	lea	youmve,a0
	move.w	level,d0
	move.b	(a0,d0.w),contpad
	bsr	moveyou
	sub.w	#1,turn
	bcc	okswop
	move.w	#7,turn
	add.w	#1,level
	cmp.w	#21,level
	bne	okswop
	move.w	#15,level
okswop	bsr	swap
	btst	#7,joy1
	beq	finlp
finout	bra	title
	
* Rock control

rocks	lea	rockdat,a6		* rocks controller
	lea	levbuf,a0
	move.w	#maxrock-1,d0		* number rocks
rockslp	cmp.w	#1,(a6)			* falling?
	bgt	cntrock			* yes
	blt	rockout			* end of rocks
	move.w	6(a6),d1
	cmp.b	#0,(a0,d1.w)
	bne	nxtrock
	add.w	#1,(a6)
nxtrock	adda.l	#8,a6
	dbra.w	d0,rockslp
rockout	rts
cntrock	cmp.w	#16,(a6)		* make delay before falling
	bgt	rckfall
	add.w	#1,(a6)
	cmp.w	#17,(a6)
	bne	nxtrock
	move.w	#rockgr,(a6)		* start it falling
	move.w	6(a6),d1
	move.b	#0,-20(a0,d1.w)
	move.l	a6,-(sp)
	move.w	d0,-(sp)
	move.w	2(a6),d0
	move.w	4(a6),d1
	add.w	#16,d1
	bsr	blanksq
	move.w	(sp)+,d0
	movea.l	(sp)+,a6
	bra	nxtrock
rckfall	add.w	#4,4(a6)		* make it fall
	cmp.w	#0,dead
	bne	rnohy
	move.w	2(a6),d2
	move.w	4(a6),d3
	sub.w	#14,d2
	subq	#6,d3
	cmp.w	youx,d2
	bgt	rnohy
	cmp.w	youy,d3
	bgt	rnohy
	add.w	#28,d2
	add.w	#12,d3
	cmp.w	youx,d2
	blt	rnohy
	cmp.w	youy,d3
	blt	rnohy
	move.w	#1,dead
	move.w	#splatpl,(a6)
rnohy	move.w	2(a6),d2
	move.w	4(a6),d3
	add.w	#14,d2
	addq.w	#8,d3
	cmp.w	bri1x,d2
	blt	rnohbri
	cmp.w	bri1y,d3
	blt	rnohbri
	sub.w	#28,d2
	sub.w	#15,d3
	cmp.w	bri1x,d2
	bgt	rnohbri
	cmp.w	bri1y,d3
	bgt	rnohbri
	move.w	#splatbl,(a6)
	add.w	#10,score
	move.w	#100,bri1on
rnohbri	cmp.w	#eyetyp,bad2typ
	beq	rnohbd2
	move.w	2(a6),d2
	move.w	4(a6),d3
	add.w	#14,d2
	addq.w	#7,d3
	cmp.w	bad2x,d2
	blt	rnohbd2
	cmp.w	bad2y,d3
	blt	rnohbd2
	sub.w	#28,d2
	sub.w	#15,d3
	cmp.w	bad2x,d2
	bgt	rnohbd2
	cmp.w	bad2y,d3
	bgt	rnohbd2
	add.w	#20,score
	move.w	#100,bad2on
	cmp.w	#firetyp,bad2typ
	bne	philspl
	move.w	#splatfl,(a6)
	bra	rnohbd2
philspl	move.w	#splatph,(a6)
rnohbd2	movem.l	d0/a6,-(sp)
	move.w	2(a6),d0
	move.w	4(a6),d1
	add.w	#16,d1
	move.w	(a6),d2
	moveq	#7,d3
	bsr	spr16
	movem.l	(sp)+,d0/a6
	move.w	4(a6),d1
	and.w	#7,d1
	cmp.w	#0,d1
	bne	nxtrock
	move.w	4(a6),d1
	move.w	2(a6),d3
	lsr.w	#4,d3
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d1,d1
	add.w	d2,d1
	add.w	d3,d1
	cmp.b	#diamond,(a0,d1.w)
	bge	rockdia
rockret	add.w	#20,d1
	cmp.b	#wall,(a0,d1.w)
	bge	stopfll
	cmp.b	#0,(a0,d1.w)
	beq	nxtrock
	cmp.b	#diamond,(a0,d1.w)
	bge	nxtrock
stopfll	move.w	(a6),d2
	move.w	#1,(a6)
	move.w	d0,-(sp)
	move.l	a6,-(sp)
	move.w	d1,6(a6)
	sub.w	#20,d1
	move.b	#rock,(a0,d1.w)
	move.w	2(a6),d0
	move.w	4(a6),d1
	add.w	#17,d1
	move.w	#rockgr,d2
	moveq	#6,d3
	lea	backbuf,a6
	lea	sprites,a5
	bsr	spr2
	movea.l	(sp)+,a6
	move.w	(sp)+,d0
	bra	nxtrock
rockdia	moveq	#0,d2
	move.b	(a0,d1.w),d2
	sub.w	#diamond-1,d2
	add.w	d2,diagot
	move.b	#0,(a0,d1.w)
	move.w	d0,-(sp)
	move.w	d1,-(sp)
	move.l	a6,-(sp)
	move.w	2(a6),d0
	move.w	4(a6),d1
	add.w	#16,d1
	bsr	blanksq
	movea.l	(sp)+,a6
	move.w	(sp)+,d1
	move.w	(sp)+,d0
	bra	rockret

* Screen updates

doscorz	bsr	doscore			* update score and hiscore
	bsr	dohs
	rts
doscore	lea	scoret1+3,a0		* update score
	moveq	#0,d0
	move.w	score,d0
	bsr	doasc
	lea	scoret1,a0
	bsr	print
	move.w	score,oldsc
	move.w	score,d0
	cmp.w	high,d0
	ble	scout
	move.w	d0,high
	bra	dohs
scout	rts
dohs	lea	highsc+3,a0		* do hiscore
	moveq	#0,d0
	move.w	high,d0
	bsr	doasc
	lea	highsc,a0
	bsr	print
	rts
doasc	divu.w	#10000,d0		* do a score routine
	add.w	#48,d0
	move.b	d0,(a0)
	swap	d0
	and.l	#$ffff,d0
	divu.w	#1000,d0
	add.w	#48,d0
	move.b	d0,1(a0)
	swap	d0
	and.l	#$fff,d0
	divu.w	#100,d0
	add.w	#48,d0
	move.b	d0,2(a0)
	swap	d0
	and.l	#$ff,d0
	divu.w	#10,d0
	add.w	#48,d0
	move.b	d0,3(a0)
	swap	d0
	add.w	#48,d0
	move.b	d0,4(a0)
	rts
dodia	lea	diatxt,a0		* do diamonds (HOLD)
	moveq	#0,d0
	move.w	diacar,d0
	divu.w	#10,d0
	add.w	#48,d0
	move.b	d0,8(a0)
	swap	d0
	add.w	#48,d0
	move.b	d0,9(a0)
	cmp.b	#48,8(a0)
	bne	notpr
	move.b	#32,8(a0)
notpr	bsr	print
	move.w	diacar,olddia
	rts
dolives	move.w	lives,d5		* do your lives
	subq.w	#1,d5
	bcs	liveout
	cmp.w	#5,d5
	ble	oklife
	moveq.w	#5,d5
oklife	lsl.w	#4,d5
	move.w	#304,d0
	sub.w	d5,d0
lifelp	move.w	d0,-(sp)
	move.w	#stand,d2
	moveq	#0,d1
	moveq	#7,d3
	lea	sprites,a5
	lea	backbuf,a6
	bsr	spr2
	move.w	(sp)+,d0
	add.w 	#16,d0
	cmp.w	#320,d0
	bne	lifelp
liveout	rts
dolevel	lea	levtxt,a0		* print level number
	moveq	#0,d0
	move.w	level,d0
	cmp.w	#36,d0
	bne	notlast
	move.b	#32,4(a0)
	move.b	#'F',5(a0)
	bra	prlev
notlast	sub.w	baselev,d0
	addq	#1,d0
	divu.w	#10,d0
	add.w	#32,d0
	cmp.b	#32,d0
	beq	notadd2
	add.w	#16,d0
notadd2	move.b	d0,4(a0)
	swap	d0
	add.w	#48,d0
	move.b	d0,5(a0)
prlev	bsr	print
	rts

* VBL

twinkle	bset	#7,flags		* VBL routine
	bsr	sound			* do sounds
	movem.l	d0-d1/a0,-(sp)
	move.w	twframe,d0
	lea	twdat,a0
	moveq	#0,d1
	move.w	(a0,d0.w),d1
	move.l	d1,$ff8240		* twinkly effect
	move.w	8(a0,d0.w),$ff825c
	move.w	#0,$ff825e
	addq.w	#2,d0
	cmp.w	#8,d0
	bne	getback
	moveq	#0,d0
getback	move.w	d0,twframe
	cmp.w	#0,flash
	beq	noflash
	move.w	#$550,$ff8240
	move.w	#$550,$ff825e
	move.w	#0,flash
noflash	movem.l	(sp)+,d0-d1/a0
	move.l	oldvbl,-(sp)
	rts
	
* Music and sound

sndres	move.b	#8,$ff8800		* reset sound cjip
	move.b	#0,$ff8802
	move.b	#9,$ff8800
	move.b	#0,$ff8802
	move.b	#10,$ff8800
	move.b	#0,$ff8802
	move.b	#7,$ff8800
	move.b	$ff8802,d0
	and.w	#%11000000,d0
	or.w	#%00111000,d0
	move.b	#7,$ff8800
	move.b	d0,$ff8802
	rts
sound	movem.l	d0-d2/a0-a1,-(sp)	* do sound
	cmp.l	#0,tune			* tune playing?
	bne	dotune			* yes
	cmp.w	#0,tunecnt
	bne	stlev
	lea	chann1,a0		* this big bit does all
	cmp.b	#0,dislen		* the SFX
	beq	doyours
	sub.b	#1,dislen
	lea	env6,a1
	cmp.l	(a0),a1
	beq	noyous
	move.l	a1,(a0)
	move.w	#0,4(a0)
	move.w	#128,6(a0)
	move.l	#trem0,8(a0)
	move.w	#0,12(a0)
	bra	noyous
doyours	cmp.w	#0,dead
	bne	youds
	lea	trem1,a1
	cmp.l	(a0),a1
	beq	noaltyt
	move.l	a1,8(a0)
	move.w	#0,12(a0)
noaltyt	lea	env0,a1
	move.w	youy,d0
	cmp.w	#stand,yougr
	bne	mved
	bsr	putenv
	bra	notmved
youds	bsr	nobad2
	bra	noyous
mved	cmp.w	#5,dir
	beq	fell
	lea	env1,a1
	cmp.l	(a0),a1
	beq	notmved
	bsr	putenv
	bra	notmved
fell	lea	env2,a1
	cmp.l	(a0),a1
	beq	notmved
	bsr	putenv
notmved	lsl.w	#3,d0
	add.w	#256,d0
	move.w	d0,6(a0)
noyous	moveq.w	#0,d2
	bsr	dochann
	lea	chann2,a0
	cmp.b	#0,bri1on
	beq	nobrian
	cmp.w	#5,bri1dir
	beq	brifell
	lea	env3,a1
	cmp.l	(a0),a1
	beq	briret
	bsr	putenv
	move.w	#2048,6(a0)
	bra	briret
brifell	move.w	bri1y,d0
	lea	env2,a1
	cmp.w	(a0),a1
	beq	bflnote
	bsr	putenv
bflnote	lsl.w	#3,d0
	add.w	#256,d0
	move.w	d0,6(a0)
briret	moveq.w	#1,d2
	bsr	dochann
	lea	chann3,a0
	lea	bad2snd,a1
	move.w	bad2typ,d0
	movea.l	(a1,d0.w),a1
	jsr	(a1)
	moveq.w	#2,d2
	bsr	dochann
sndout	movem.l	(sp)+,d0-d2/a0-a1
	rts
nobrian	move.l	#env0,(a0)
	move.w	#0,4(a0)
	bra	briret
putenv	move.l	a1,(a0)
	move.w	#0,4(a0)
	rts
philsnd	cmp.b	#0,bad2on
	beq	nobad2
	lea	env4,a1
	cmp.l	(a0),a1
	beq	bad2sot
	bsr	putenv
	move.l	#trem0,8(a0)
	move.w	#0,12(a0)
	move.w	#1024,6(a0)
	rts
firesnd	cmp.b	#0,bad2on
	beq	nobad2
	cmp.l	#env1,(a0)
	beq	nofsnd
	move.l	#env1,(a0)
	move.w	#0,4(a0)
	move.w	#512,6(a0)
	move.l	#trem3,8(a0)
	move.w	#0,12(a0)
	move.b	#7,$ff8800
	move.b	$ff8802,d0
	and.w	#%11011000,d0
	move.b	#7,$ff8800
	move.b	d0,$ff8802
nofsnd	rts
eyesnd	cmp.b	#0,bad2on
	beq	nobad2
	cmp.w	#0,bad2mvl
	beq	bad2sot
	move.w	#0,bad2mvl
	lea	env5,a1
	bsr	putenv
	move.l	#trem2,8(a0)
	move.w	#0,12(a0)
	move.w	#300,6(a0)
	rts
wormsnd	cmp.b	#0,bad2on
	beq	nobad2
	lea	env7,a1
	cmp.l	(a0),a1
	beq	wormout
	move.l	a1,(a0)
	move.w	#0,4(a0)
	move.w	#700,6(a0)
	move.l	#trem4,8(a0)
	move.w	#0,12(a0)
wormout	rts
nobad2	move.l	#env0,(a0)
	move.w	#0,4(a0)
	move.b	#7,$ff8800
	move.b	$ff8802,d0
	and.w	#%11000000,d0
	or.w	#%00111000,d0
	move.b	d0,$ff8802
bad2sot	rts
dotune	cmp.l	#1,tune		* this bit goes in VBL while tune
	bne	playtun		* is playing
	bra	sndout
playtun	move.b	#0,dislen
	movea.l	tune,a0
	jsr	(a0)
	sub.w	#1,tunecnt
	bne	sndout
	move.l	#0,tune
	bra	sndout
dochann	movea.l	(a0),a1
	move.w	4(a0),d0
getvol	move.b	(a1,d0.w),d1
	cmp.b	#15,d1
	bgt	envcomm
	add.w	#1,d0
	cmp.w	#50,d0
	bne	putvolb
	move.w	#49,d0
putvolb	move.w	d0,4(a0)
envret1	move.w	d2,d0
	addq.w	#8,d0
	move.b	d0,$ff8800
	move.b	d1,$ff8802
envret2	movea.l	8(a0),a1
	move.w	12(a0),d1
gettrem	move.w	(a1,d1.w),d0
	cmp.w	#2000,d0
	bgt	tremcom
	add.w	#2,d1
	move.w	d1,12(a0)
tremrt2	move.w	6(a0),d1
	add.w	d0,d1
	add.w	d2,d2
	move.b	d2,$ff8800
	move.b	d1,$ff8802
	addq	#1,d2
	move.b	d2,$ff8800
	lsr.w	#8,d1
	move.b	d1,$ff8802
	rts
envcomm	cmp.b	#17,d1
	blt	envret2
	beq	resetv
	cmp.w	#18,d1
	bne	novol
	move.b	1(a0,d0.w),d0
	bra	getvol
novol	move.w	#0,d1
	bra	envret1
resetv	move.w	#0,d0
	bra	getvol
tremcom	cmp.w	#2002,d0
	blt	tremrg
	beq	tremres
	move.w	2(a0,d1.w),d1
	bra	gettrem
tremres	move.w	#0,d1
	bra	gettrem
tremrg	move.w	#0,d0
	bra	tremrt2
stlev	cmp.w	#32,tunecnt
	bne	nostlev
	lea	chann1,a0
	move.l	#env8,(a0)
	move.w	#0,4(a0)
	move.w	#400,6(a0)
	move.l	#trem1,8(a0)
	move.w	#0,12(a0)
	move.l	#env0,14(a0)
	move.w	#0,18(a0)
	move.l	#env0,28(a0)
	move.w	#0,32(a0)
nostlev	lea	chann1,a0
	moveq	#0,d2
	bsr	dochann
	lea	chann2,a0
	moveq	#1,d2
	bsr	dochann
	lea	chann3,a0
	moveq	#2,d2
	bsr	dochann
	sub.w	#1,tunecnt
	bra	sndout

bad2snd	dc.l	philsnd,firesnd,eyesnd,wormsnd
tune	dc.l	0
tunecnt	dc.w	0
chann1	dc.l	env0
	dc.w	0,0
	dc.l	trem1
	dc.w	0
chann2	dc.l	env0
	dc.w	0,0
	dc.l	trem1
	dc.w	0
chann3	dc.l	env0
	dc.w	0,0
	dc.l	trem0
	dc.w	0
trem0	dc.w	0,2001
trem1	dc.w	-1,0,1,0,2002
trem2	dc.w	10,10,20,30,40,50,60,70,80,90
	dc.w	100,110,120,130,140,150,160,170,180,190
	dc.w	200,210,220,230,240,250,260,270,280,290
	dc.w	300,310,320,330,340,350,360,370,380,390
	dc.w	400,410,420,430,440,450,2001
trem3	dc.w	100,190,90,-50,-100,-150,-130,-10,50,90,2002
trem4	dc.w	0,-100,-200,-300,-400,-300,-200,-100,2002
	
env0	dc.b	0,17
env1	dc.b	15,11,17
env2	dc.b	15,17
env3	dc.b	1,2,3,4,6,8,11,15,11,8,6,0,0,0,0,0,0,0,0,0,0,0,17
env4	dc.b	1,2,4,8,15,8,4,2,1,0,17
env5	dc.b	15,15,15,15,15,14,14,14,14,14
	dc.b	13,13,13,13,12,12,12,12,11,11
	dc.b	11,11,10,10,10,9,9,9,8,8
	dc.b	8,7,7,6,6,5,5,4,4,3
	dc.b	3,2,2,1,1,0,19
env6	dc.b	15,8,2,0,17
env7	dc.b	13,17
env8	dc.b	15,13,11,13,11,9,11,9,17
*env8	dc.b	15,13,11,9,7,5,3,1,17

* Print routine

print	lea	font,a1		* prints an ascii string
prloop	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.w	#0,d0
	bne	prcont
	rts
prcont	cmp.w	#1,d0
	beq	prat
	cmp.w	#2,d0
	beq	plchnge
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
plchnge	moveq	#0,d2
	move.b	(a0)+,d0
	move.w	d0,plane
	bra	prloop
prat	lea	backbuf,a2
	move.w	plane,d0
	lea	(a2,d0.w),a2
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

* Player control

moveyou	cmp.w	#0,dead		* move you routine
	bne	youdead
	cmp.w	#5,dir
	beq	fall
	move.w	#0,falld
	move.w	#0,onsq
	move.w	youx,d0
	and.w	#15,d0
	cmp.w	#0,d0
	bne	nofall
	move.w	youy,d1
	and.w	#7,d1
	cmp.w	#0,d1
	bne	nofall
	bsr	fallchk
	cmp.w	#0,d7
	bne	fall
nofall	cmp.w	#3,dir
	bgt	mvdown
	beq	mvup
	cmp.w	#1,dir
	bgt	mvright
	blt	nomove
mvleft	cmp.w	#1,onsq
	bne	goleft
	move.w	youx,d0
	lsr.w	#4,d0
	move.w	youy,d1
	and.w	#248,d1
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	add.w	d1,d0
	lea	levbuf,a0
	cmp.b	#wall,-1(a0,d0.w)
	bge	nodir
	move.w	#1,mask
	cmp.b	#0,-1(a0,d0.w)
	beq	nml
	cmp.b	#diamond,-1(a0,d0.w)
	blt	notdial
nml	move.w	#0,mask
notdial	bsr	moveitl
	bra	control
goleft	bsr	moveitl
	move.w	youx,d0
	and.w	#15,d0
	cmp.w	#0,d0
	bne	control
	bsr	killon
	move.w	#0,dir
control	btst	#2,contpad
	bne	left
	btst	#3,contpad
	bne	right
	btst	#0,contpad
	bne	up
	btst	#1,contpad
	bne	down
doguy	move.w	youx,d0
	move.w	youy,d1
	add.w	#16,d1
	cmp.w	#24,d1
	ble	nomask
	cmp.w	#0,mask
	beq	nomask
	move.w	#maskgr,d2
	moveq	#7,d3
	lea	sprites,a5
	lea	backbuf,a6
	bsr	spr2
	move.w	youx,d0
	move.w	youy,d1
	add.w	#16,d1
	move.w	#maskgr,d2
	moveq	#7,d3
	bsr	spr16
	move.w	youx,d0
	move.w	youy,d1
	add.w	#16,d1
nomask	moveq	#7,d3
	move.w	yougr,d2
	bsr	spr16
	rts
mvright	cmp.w	#1,onsq
	bne	goright
	move.w	youx,d0
	lsr.w	#4,d0
	move.w	youy,d1
	and.w	#248,d1
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	add.w	d1,d0
	lea	levbuf,a0
	cmp.b	#wall,1(a0,d0.w)
	bge	nodir
	move.w	#1,mask
	cmp.b	#0,1(a0,d0.w)
	beq	nmr
	cmp.b	#diamond,1(a0,d0.w)
	blt	notdiar
nmr	move.w	#0,mask
notdiar	bsr	moveitr
	bra	control
nodir	move.w	#0,dir
	move.w	#stand,yougr
	bra	control
goright	bsr	moveitr
	move.w	youx,d0
	and.w	#15,d0
	cmp.w	#0,d0
	bne	control
	bsr	killon
	move.w	#0,dir
	bra	control
mvup	cmp.w	#1,onsq
	bne	goup
	move.w	youx,d0
	lsr.w	#4,d0
	move.w	youy,d1
	subq.w	#8,d1
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	add.w	d1,d0
	lea	levbuf,a0
	cmp.b	#wall,(a0,d0.w)
	bge	nodir
	move.w	#1,mask
	cmp.b	#0,(a0,d0.w)
	beq	nmu
	cmp.b	#diamond,(a0,d0.w)
	blt	notdiau
nmu	move.w	#0,mask
notdiau	bsr	moveitu
	bra	control
goup	bsr	moveitu
	move.w	youy,d0
	and.w	#7,d0
	cmp.w	#0,d0
	bne	control
	bsr	killon
	move.w	#0,dir
	bra	control
mvdown	cmp.w	#1,onsq
	bne	godown
	move.w	youx,d0
	lsr.w	#4,d0
	move.w	youy,d1
	addq.w	#8,d1
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	add.w	d1,d0
	lea	levbuf,a0
	cmp.b	#wall,(a0,d0.w)
	bge	nodir
	move.w	#1,mask
	cmp.b	#0,(a0,d0.w)
	beq	nmd
	cmp.b	#diamond,(a0,d0.w)
	blt	notdiad
nmd	move.w	#0,mask
notdiad	bsr	moveitd
	bra	control
godown	bsr	moveitd
	move.w	youy,d0
	and.w	#7,d0
	cmp.w	#0,d0
	bne	control
	bsr	killon
	move.w	#0,dir
	bra	control
nomove	move.w	#stand,yougr
	bra	control
killon	move.w	youx,d0
	move.w	youy,d1
	add.w	#16,d1
	cmp.w	#24,d1
	ble	noblank
	bsr	blanksq
noblank	move.w	youx,d0
	lsr.w	#4,d0
	move.w	youy,d1
	and.w	#248,d1
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	add.w	d1,d0
	lea	levbuf,a0
	cmp.b	#diamond,(a0,d0.w)
	bge	dia?
	move.b	#0,(a0,d0.w)
killout	rts
dia?	cmp.b	#wall,(a0,d0.w)
	beq	killout
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	cmp.b	#gwdiamd,(a0,d0.w)
	bne	notgwd
	move.w	#25,diagot
notgwd	move.b	#0,(a0,d0.w)
	subq	#5,d1
	add.w	d1,diagot
	add.w	d1,diacar
	add.w	d1,score
	move.b	#12,dislen
	rts
left	cmp.w	#2,dir
	bgt	doguy
	cmp.w	#0,youx
	beq	doguy
	move.w	#1,dir
	bra	doguy
right	cmp.w	#2,dir
	bgt	doguy
	cmp.w	#304,youx
	beq	doguy
	move.w	#2,dir
	bra	doguy
up	cmp.w	#0,dir
	beq	dirup
	cmp.w	#2,dir
	ble	doguy
dirup	move.w	#3,dir
	bra	doguy
down	cmp.w	#0,dir
	beq	dirdown
	cmp.w	#2,dir
	ble	doguy
dirdown	move.w	#4,dir
	bra	doguy
moveitl	sub.w	#2,youx
	cmp.w	#runl,yougr
	blt	strunl
	cmp.w	#runr,yougr
	bge	strunl
	move.w	turn,d0
	and.w	#3,d0
	cmp.w	#0,d0
	bne	mitlout
	add.w	#80,yougr
	cmp.w	#runr,yougr
	blt	mitlout
strunl	move.w	#runl,yougr
mitlout	rts
moveitr	add.w	#2,youx
	cmp.w	#runr,yougr
	blt	strunr
	cmp.w	#updown,yougr
	bge	strunl
	move.w	turn,d0
	and.w	#3,d0
	cmp.w	#0,d0
	bne	mitrout
	add.w	#80,yougr
	cmp.w	#updown,yougr
	blt	mitrout
strunr	move.w	#runr,yougr
mitrout	rts
moveitd	add.w	#1,youy
	bra	udjoin
moveitu	sub.w	#1,youy
udjoin	cmp.w	#updown,yougr
	blt	strunu
	cmp.w	#falldwn,yougr
	bge	strunu
	move.w	turn,d0
	and.w	#3,d0
	cmp.w	#0,d0
	bne	mituout
	add.w	#80,yougr
	cmp.w	#falldwn,yougr
	blt	mituout
strunu	move.w	#updown,yougr
mituout	rts
fall	move.w	#5,dir
	move.w	#falldwn,yougr
	cmp.w	#8,falld
	bge	fall2
	add.w	#1,youy
fallj	add.w	#1,falld
	move.w	youy,d0
	and.w	#7,d0
	cmp.w	#0,d0
	bne	doguy
	bsr	killon
	bsr	fallchk
	cmp.w	#1,d7
	beq	doguy
	move.w	#0,dir
	bra	doguy
fall2	cmp.w	#16,falld
	bge	fall4
	add.w	#2,youy
	bra	fallj
fall4	add.w	#4,youy
	bra	fallj
fallchk	move.w	youx,d0
	move.w	#1,onsq
	move.w	youy,d1
fallc2	moveq	#0,d7
	lsr.w	#4,d0
	and.w	#248,d1
	lsr.w	#1,d1
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	add.w	d1,d0
	lea	levbuf,a0
	moveq	#0,d1
	lea	-1(a0,d0.w),a0
	bsr	sqchk
	addq.l	#2,a0
	bsr	sqchk
	cmp.w	#2,d1
	beq	nofallc
	moveq	#0,d1
	adda.l	#18,a0
	bsr	sqchk
	addq.l	#2,a0
	bsr	sqchk
	cmp.w	#2,d1
	beq	nofallc
	moveq	#0,d1
	subq.l	#1,a0
	bsr	sqchk
	cmp.w	#0,d1
	bne	nofallc
	addq.l	#1,a0
	bsr	sqchk
	cmp.w	#0,d1
	bne	brthere
	subq.l	#2,a0
	bsr	sqchk
	cmp.w	#0,d1
	bne	blthere
	moveq	#1,d7
nofallc	rts
blthere	suba.l	#18,a0
	moveq	#0,d1
	bsr	sqchk
	cmp.w	#0,d1
	bne	nofallc
	moveq	#1,d7
	rts
brthere	suba.l	#22,a0
	moveq	#0,d1
	bsr	sqchk
	cmp.w	#0,d1
	bne	nofallc
	moveq	#1,d7
	rts
sqchk	cmp.b	#0,(a0)
	beq	sqout
	cmp.b	#wall,(a0)
	bge	sq
	cmp.b	#diamond,(a0)
	bge	sqout
sq	addq.w	#1,d1
sqout	rts
youdead	cmp.w	#1,dead		* this bit does the angel
	bne	notjded
	move.l	#saints,tune
	jsr	saints+4
	move.w	#210,tunecnt
notjded	add.w	#1,dead
	move.w	youx,d0
	move.w	youy,d1
	add.w	#16,d1
	move.w	yougr,d2
	sub.w	#1,youy
	cmp.w	#-32,youy
	beq	deadout
	add.w	#80,d2
	cmp.w	#angel1,d2
	ble	resange
	cmp.w	#angel4,d2
	ble	noresan
resange	move.w	#angel1,d2
noresan	move.w	d2,yougr
	moveq	#7,d3
	bsr	spr16
deadout	rts

* Make and control bad guys

bad2tab	dc.l	phil,fires,eyes,snakes
bad2mve	dc.l	philmve,firemve,firemve,snkemve
lefttab	dc.b	0,4,3,1,2
rghttab	dc.b	0,3,4,2,1
makebad	lea	brian1,a0
	move.w	#256,(a0)+
	move.w	#16,(a0)+
	move.w	#8,(a0)+
	move.w	#0,(a0)+
	move.w	#15,d0
	move.w	level,d1
	add.w	d1,d0
	add.w	d1,d1
	add.w	d1,d0
	move.w	d0,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#1,(a0)+	
	
	move.w	#50,d0
	move.w	level,d1
	sub.w	d1,d0
	lsl.w	#3,d0
	move.w	d0,demon
	bsr	random
	and.w	#127,d7
	add.w	#96,d7
	move.w	d7,demonx
	move.w	#200,demony
	
	move.w	#320,bad2x
	move.w	#8,bad2y
	move.w	#32,bad2on
	move.w	#1,bad2dir
	move.w	bri1int,bad2int
	move.w	#0,bad2mty
	move.w	#0,bad2mvl
	move.w	#0,bad2msk
	move.w	#0,bad2ons
	move.w	#0,bad2gr
	rts
demondo	cmp.w	#0,demon
	bne	nodemon
	move.w	turn,d0
	and.w	#1,d0
	cmp.w	#0,d0
	bne	prdemon
	move.w	demonx,d0
	cmp.w	youx,d0
	blt	demonr
	sub.w	#1,demonx
	bra	demonv
demonr	add.w	#1,demonx
demonv	move.w	turn,d0
	and.w	#3,d0
	cmp.w	#0,d0
	bne	prdemon
	move.w	demony,d0
	sub.w	#12,d0
	cmp.w	youy,d0
	blt	demond
	sub.w	#1,demony
	bra	prdemon
demond	add.w	#1,demony
prdemon	cmp.w	#0,dead
	bne	nodemhy
	move.w	demonx,d0
	sub.w	#14,d0
	cmp.w	youx,d0
	bgt	nodemhy
	add.w	#28,d0
	cmp.w	youx,d0
	blt	nodemhy
	move.w	demony,d0
	sub.w	#23,d0
	cmp.w	youy,d0
	bgt	nodemhy
	add.w	#18,d0
	cmp.w	youy,d0
	blt	nodemhy
	move.w	#1,dead
nodemhy	move.w	demonx,d0
	move.w	demony,d1
	move.w	#demongr,d2
	moveq	#15,d3
	bsr	spr16
	rts
nodemon	sub.w	#1,demon
	rts
bad2do	cmp.b	#0,bad2on
	beq	bad2off
	move.w	#0,bad2ons
	move.w	bad2x,d0
	and.w	#15,d0
	cmp.w	#0,d0
	bne	mvbad2
	move.w	bad2y,d0
	and.w	#7,d0
	cmp.w	#0,d0
	bne	mvbad2
	move.w	#1,bad2ons
	cmp.w	#eyetyp,bad2typ
	bne	noteye
	bsr	random
	and.w	#31,d7
	cmp.w	#2,d7
	ble	fillsq
noteye	cmp.w	#wormtyp,bad2typ
	beq	fillsq
	cmp.w	#philtyp,bad2typ
	bne	jmprout
fillsq	cmp.w	#8,bad2y
	ble	jmprout
	move.w	bad2x,d0
	move.w	bad2y,d1
	lsr.w	#4,d0
	lsr.w	#1,d1
	add.w	d1,d0
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	lea	levels,a0
	lea	levbuf,a1
	moveq	#0,d2
	cmp.b	#0,(a1,d0.w)
	bne	jmprout
	move.b	(a0,d0.w),d2
	move.b	d2,(a1,d0.w)
	subq	#1,d2
	lsl.w	#6,d2
	move.w	bad2x,d0
	move.w	bad2y,d1
	add.w	#16,d1
	move.w	d1,d3
	add.w	d1,d1
	add.w	d1,d1
	add.w	d3,d1
	lsl.w	#5,d1
	lsr.w	#1,d0
notod2	add.w	d0,d1
	lea	backbuf,a6
	lea	(a6,d1.w),a6
	bsr	putblok
	movea.l	back,a6
	lea	(a6,d1.w),a6
	bsr	putblok
jmprout	move.w	bad2typ,d0
	lea	bad2mve,a0
	movea.l	(a0,d0.w),a1
	jsr	(a1)
mvbad2	cmp.w	#3,bad2dir
	bgt	bad2dwn
	beq	bad2up
	cmp.w	#1,bad2dir
	bgt	bad2rgt
	blt	prbad2
bad2lft	sub.w	#2,bad2x
	cmp.w	#-14,bad2x
	bgt	prbad2
	move.w	#50,bad2on
	rts
bad2rgt	add.w	#2,bad2x
	cmp.w	#319,bad2x
	blt	prbad2
	move.w	#50,bad2on
	bra	bad2out
bad2dwn	add.w	#1,bad2y
	bra	prbad2
bad2up	sub.w	#1,bad2y
prbad2	move.w	bad2typ,d0
	lea	bad2tab,a0
	movea.l	(a0,d0.w),a1
	jsr	(a1)
	cmp.w	#0,dead
	bne	nocolb2
	move.w	bad2x,d0
	sub.w	#15,d0
	cmp.w	youx,d0
	bgt	nocolb2
	add.w	#30,d0
	cmp.w	youx,d0
	blt	nocolb2
	move.w	bad2y,d0
	subq.w	#7,d0
	cmp.w	youy,d0
	bgt	nocolb2
	add.w	#14,d0
	cmp.w	youy,d0
	blt	nocolb2
	move.w	#1,dead
nocolb2	move.w	bad2x,d0
	move.w	bad2y,d1
	add.w	#16,d1
	move.w	bad2gr,d2
	moveq	#7,d3
	bsr	spr16
bad2out	rts
snkemve	cmp.w	#8,bad2y
	bgt	snttop
	cmp.w	#304,bad2x
	bge	wgolft
	cmp.w	#0,bad2x
	ble	wgolft
	move.w	bad2x,d0
	lsr.w	#4,d0
	add.w	#40,d0
	lea	levbuf,a0
	cmp.b	#wall,(a0,d0.w)
	bge	wgolft
snttop	move.w	bad2x,d0
	lsr.w	#4,d0
	move.w	bad2y,d1
	lsr.w	#1,d1
	add.w	d1,d0
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	lea	levbuf,a0
	moveq	#0,d1
	bsr	random
	and.w	#15,d7
	cmp.w	#1,d7
	ble	newsdir
dirchk	cmp.w	#2,bad2dir
	blt	wlft
	beq	wrgt
	cmp.w	#3,bad2dir
	bne	wdwn
	move.w	#wall,d1
	cmp.w	#8,bad2y
	beq	wdirrej
	move.b	-20(a0,d0.w),d1
wdirrej	cmp.w	#wall,d1
	bge	newsdir
	rts
wgolft	move.w	#1,bad2dir
	rts
newsdir	cmp.w	#8,bad2y
	beq	wgdwn
wgrand	bsr	random
	and.w	#3,d7
	addq.w	#1,d7
	move.w	d7,bad2dir
	bra	dirchk
wgdwn	cmp.w	#3,bad2dir
	beq	wgrand
	move.w	#4,bad2dir
	bra	dirchk
wlft	move.b	-1(a0,d0.w),d1
	bra	wdirrej
wrgt	move.b	1(a0,d0.w),d1
	bra	wdirrej
wdwn	move.b	20(a0,d0.w),d1
	bra	wdirrej
philmve	move.w	bad2x,d0
	lsr.w	#4,d0
	move.w	bad2y,d1
	lsr.w	#1,d1
	add.w	d1,d0
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	lea	levbuf,a0
	moveq	#0,d1
	moveq	#0,d2
	bsr	countem
	cmp.w	#8,bad2y
	bgt	fbot
	cmp.w	#0,bad2x
	ble	fgolft
	cmp.w	#304,bad2x
	bge	fgolft
	cmp.w	#3,d1
	beq	fgolft
	move.w	#4,bad2dir
	rts
firemve	move.w	bad2x,d0
	lsr.w	#4,d0
	move.w	bad2y,d1
	lsr.w	#1,d1
	add.w	d1,d0
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	lea	levbuf,a0
	moveq	#0,d1
	moveq	#0,d2
	bsr	countem
	cmp.w	#8,bad2y
	ble	ftoprow
fbot	cmp.w	#0,d1
	beq	b2dead?
	cmp.w	#1,d1
	beq	foneway
	cmp.w	#2,d1
	beq	ftwoway
	cmp.w	#3,d1
	beq	ftjunc
fcross	bsr	random
	and.w	#31,d7
	cmp.w	#5,d7
	blt	lone
	cmp.w	26,d7
	bgt	rone
	rts
b2dead?	move.w	#0,bad2dir
	cmp.b	#0,(a0,d0.w)
	beq	lout
	move.w	#50,bad2on
	rts
lone	move.w	bad2dir,d7
	lea	lefttab,a6
	move.b	(a6,d7.w),d7
	move.w	d7,bad2dir
lout	rts
rone	move.w	bad2dir,d7
	lea	rghttab,a6
	move.b	(a6,d7.w),d7
	move.w	d7,bad2dir
	rts
ftjunc	move.w	bad2dir,d0
	btst	d0,d2
	bne	aheadok
	bsr	random
	and.w	#31,d7
	cmp.w	#16,d7
	blt	lone
	bra	rone
aheadok	bsr	random
	and.w	#31,d7
	cmp.w	#25,d7
	blt	lout
ahok2	bsr	lone
	move.w	bad2dir,d0
	btst	d0,d2
	beq	fotherw
	rts
fotherw	bsr	rone
	bra	rone
ftwoway	move.w	bad2dir,d0
	btst	d0,d2
	beq	ahok2
	rts	
foneway	moveq	#1,d0
fonelp	btst	d0,d2
	bne	thisdir
	addq	#1,d0
	bra	fonelp
thisdir	move.w	d0,bad2dir
	rts
ftoprow	cmp.w	#0,bad2x
	ble	fgolft
	cmp.w	#304,bad2x
	bge	fgolft
	cmp.w	#3,d1
	bne	fgodwn?
fgolft	move.w	#1,bad2dir
	rts
fgodwn?	bsr	random
	and.w	#$31,d7
	cmp.w	#25,d7
	bgt	fgolft
	bra	lone
countem	cmp.b	#0,-20(a0,d0.w)
	bne	notabov
	moveq	#1,d1
	bset	#3,d2
notabov	cmp.b	#0,20(a0,d0.w)
	bne	notbelo
	addq	#1,d1
	bset	#4,d2
notbelo	cmp.b	#0,1(a0,d0.w)
	bne	notsid1
	addq	#1,d1
	bset	#2,d2
notsid1	cmp.b	#0,-1(a0,d0.w)
	bne	notsid2
	addq	#1,d1
	bset	#1,d2
notsid2	rts
snakes	cmp.w	#worm1,bad2gr
	blt	resworm
	add.w	#80,bad2gr
	cmp.w	#worm4,bad2gr
	ble	fireout
resworm	move.w	#worm1,bad2gr
	rts
eyes	move.w	bad2dir,d0
	cmp.w	#0,bad2gr
	beq	geteygr
	cmp.w	#0,d0
	beq	randdir
	cmp.w	old2dir,d0
	beq	eyeout
geteygr	move.w	#1,bad2mvl
	move.w	d0,old2dir
	subq	#1,d0
geteyg2	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	lsl.w	#4,d0
	add.w	#eye1,d0
	move.w	d0,bad2gr
eyeout	rts
randdir	bsr	random
	and.w	#1,d7
	move.w	d7,d0
	bra	geteyg2
fires	cmp.w	#fire1,bad2gr
	blt	resfire
	add.w	#80,bad2gr
	cmp.w	#fire4,bad2gr
	ble	fireout
resfire	move.w	#fire1,bad2gr
fireout	rts
phil	cmp.w	#phil1,bad2gr
	blt	resphil
	btst	#0,turn+1
	beq	fireout
	add.w	#80,bad2gr
	cmp.w	#phil4,bad2gr
	ble	fireout
resphil	move.w	#phil1,bad2gr
	rts

bad2off	cmp.w	#0,bad2on
	bne	cntdown
	bsr	random
	and.w	#63,d7
	cmp.w	#0,d7
	bne	stiloff
	move.w	#0,bad2gr
	move.w	#320,bad2x
	move.w	#8,bad2y
	move.w	#1,bad2dir
	move.w	#256,bad2on
	rts
cntdown	sub.w	#1,bad2on
stiloff	rts
	
brian	cmp.b	#0,brion(a4)
	beq	brioff
	cmp.w	#5,bridir(a4)
	beq	brifall
	move.w	#0,brionsq(a4)
	btst	#0,turn+1
	bne	mvbri
	move.w	brix(a4),d0
	and.w	#15,d0
	cmp.w	#0,d0
	bne	mvbri
	move.w	briy(a4),d1
	and.w	#7,d1
	cmp.w	#0,d1
	bne	mvbri
	move.w	#1,brionsq(a4)
	cmp.w	#0,brix(a4)
	bgt	okbrigo
	move.w	#2,bridir(a4)
	bra	mvbri
okbrigo	bsr	bkillon
	move.w	brix(a4),d0
	move.w	briy(a4),d1
	bsr	fallc2
	cmp.w	#0,d7
	bne	brifall
	move.b	#1,brion(a4)
	cmp.w	#0,brimvlf(a4)
	bne	makemv
	bsr	random
	move.w	#1,brimty(a4)
	and.w	#127,d7
	cmp.w	briint(a4),d7
	blt	intmt
	move.w	#0,brimty(a4)
intmt	bsr	random
	and.w	#3,d7
	addq	#1,d7
	move.w	d7,brimvlf(a4)
makemv	cmp.w	#0,brimty(a4)
	bne	intmove
	cmp.w	#5,d0
	beq	randmve
	cmp.w	#0,d0
	beq	randmve
	bsr	random		*keep
	move.w	bridir(a4),d0	*in
	and.w	#31,d7		*same direction
	cmp.w	#26,d7		*alot of the
	ble	chkrmv		*time!!
randmve	move.w	#0,brimty(a4)
	bsr	random
	and.w	#3,d7
	addq	#1,d7
	move.w	d7,d0
chkrmv	bsr	chckmve
	cmp.w	#0,d7
	beq	randmve
	move.w	d0,bridir(a4)
	bra	endmve
chckmve	moveq	#0,d7
	move.w	brix(a4),d1
	move.w	briy(a4),d2
	lsr.w	#4,d1
	lsr.w	#1,d2
	move.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	d3,d2
	add.w	d2,d1
	lea	levbuf,a0
	cmp.w	#2,d0
	beq	chkr
	blt	chkl
	cmp.w	#3,d0
	beq	chkup
chkdwn	add.w	#20,d1
	lea	(a0,d1.w),a0
	moveq	#0,d1
	bsr	sqchk2
	cmp.w	#0,d1
	bne	chkout
	moveq	#1,d7
chkout	rts	
chkup	sub.w	#20,d1
	lea	(a0,d1.w),a0
	moveq	#0,d1
	bsr	sqchk2
	cmp.w	#0,d1
	bne	chkout
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	brix(a4),d0
	move.w	briy(a4),d1
	sub.w	#8,d1	
	bsr	fallc2
	movea.l	(sp)+,a0
	move.w	(sp)+,d0
	move.w	(sp)+,d1
	cmp.w	#0,d7
	bne	chkout2
	moveq	#1,d7
	rts
chkout2	moveq	#0,d7
	rts
chkl	cmp.w	#0,brix(a4)
	ble	chkout
	subq.w	#1,d1
	lea	(a0,d1.w),a0
	moveq	#0,d1
	bsr	sqchk2
	cmp.w	#0,d1
	bne	chkout
	moveq	#1,d7
	rts
chkr	cmp.w	#304,brix(a4)
	bge	chkout
	addq.w	#1,d1
	lea	(a0,d1.w),a0
	moveq	#0,d1
	bsr	sqchk2
	cmp.w	#0,d1
	bne	chkout
	moveq	#1,d7
	rts
sqchk2	cmp.b	#gwdiamd,(a0)
	blt	sqout2
	addq.w	#1,d1
sqout2	rts
intmove	moveq	#0,d7
	cmp.w	#0,dead
	bne	randmve
	moveq.w	#1,d2
	moveq.w	#3,d3
	move.w	brix(a4),d0
	move.w	briy(a4),d1
	sub.w	youx,d0
	sub.w	youy,d1
	cmp.w	#0,d0
	bgt	norvd0
	not.w	d0
	addq	#1,d0
	moveq	#2,d2
norvd0	cmp.w	#0,d1
	bgt	norvd1
	not.w	d1
	addq	#1,d1
	moveq	#4,d3
norvd1	cmp.w	d0,d1
	bgt	updir
	move.w	d2,d0
	move.w	d3,onsq
	bsr	chckmve
	cmp.w	#0,d7
	beq	nxtmove
	move.w	d0,bridir(a4)
	bra	endmve
nxtmove	move.w	onsq,d0
	bra	chkrmv
updir	move.w	d3,d0
	move.w	d2,onsq
	bsr	chckmve
	cmp.w	#0,d7
	beq	nxtmve2
	move.w	d0,bridir(a4)
	bra	endmve
nxtmve2	move.w	onsq,d0
	bra	chkrmv
		
endmve	sub.w	#1,brimvlf(a4)
	move.w	#1,brimask(a4)
	cmp.b	#0,(a0)
	beq	nobmsk
	cmp.b	#diamond,(a0)
	blt	mvbri
	cmp.b	#gwdiamd,(a0)
	bge	mvbri
nobmsk	move.w	#0,brimask(a4)
mvbri	cmp.w	#2,bridir(a4)
	blt	brileft
	beq	brirght
	btst	#0,turn+1
	bne	prbri
	cmp.w	#3,bridir(a4)
	beq	briup
bridown	add.w	#1,briy(a4)
	bra	prbri
briup	sub.w	#1,briy(a4)
	bra	prbri
brileft	cmp.w	#0,bridir(a4)
	beq	prbri
	sub.w	#1,brix(a4)
	bra	prbri
brirght	add.w	#1,brix(a4)
prbri	cmp.w	#0,dead
	bne	nobhity
	move.w	brix(a4),d0
	move.w	briy(a4),d1
	sub.w	#14,d0
	subq	#6,d1
	cmp.w	youx,d0
	bgt	nobhity
	cmp.w	youy,d1
	bgt	nobhity
	add.w	#28,d0
	add.w	#12,d1
	cmp.w	youx,d0
	blt	nobhity
	cmp.w	youy,d1
	blt	nobhity
	move.w	#1,dead
nobhity	move.w	#blob1,d2
	move.w	brix(a4),d0
	lsr.w	#1,d0
	and.w	#7,d0
	cmp.w	#0,d0
	bne	gotgr
	move.w	briy(a4),d0
	and.w	#7,d0
	cmp.w	#0,d0
	beq	gotgr2
gotgr	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	lsl.w	#4,d0
	add.w	d0,d2
	cmp.w	#blob4,d2
	ble	gotgr2
	move.w	#blob5,d3
	sub.w	d2,d3
	exg	d3,d2
	add.w	#blob4,d2
gotgr2	move.w	brix(a4),d0
	move.w	briy(a4),d1
	add.w	#16,d1
	moveq	#7,d3
	cmp.w	#0,brimask(a4)
	beq	nobmask
	move.w	d2,-(sp)
	move.w	#maskgr,d2
	lea	sprites,a5
	lea	backbuf,a6
	bsr	spr2
	move.w	brix(a4),d0
	move.w	briy(a4),d1
	add.w	#16,d1
	moveq	#7,d3
	move.w	(sp)+,d2
nobmask	bsr	spr16
	rts
brioff	cmp.w	#0,brion(a4)
	beq	nodecbr
	sub.w	#1,brion(a4)
	rts
nodecbr	bsr	random
	and.w	#31,d7
	cmp.w	#0,d7
	bne	broff
	move.b	#1,brion(a4)
	move.w	#-16,brix(a4)
	move.w	#8,briy(a4)
	move.w	#0,bridir(a4)
	add.w	#20,briint(a4)
broff	rts
brifall	move.w	#5,bridir(a4)
	add.b	#1,brion(a4)
	cmp.b	#10,brion(a4)
	bge	brif2
	add.w	#1,briy(a4)
	bra	brifrej
brif2	cmp.b	#18,brion(a4)
	bge	brif4
	add.w	#2,briy(a4)
	bra	brifrej
brif4	add.w	#4,briy(a4)
brifrej	move.w	briy(a4),d1
	and.w	#7,d1
	cmp.w	#0,d1
	bne	brifout
	bsr	bkillon
	move.w	briy(a4),d1
	move.w	brix(a4),d0
	bsr	fallc2
	cmp.w	#0,d7
	bne	brifout
	move.w	#0,bridir(a4)
brifout	bra	prbri
bkillon	move.w	brix(a4),d0
	move.w	briy(a4),d1
	cmp.w	#8,d1
	ble	nblank
	add.w	#16,d1
	bsr	blanksq
nblank	move.w	brix(a4),d0
	lsr.w	#4,d0
	move.w	briy(a4),d1
	and.w	#248,d1
	lsr.w	#1,d1
	add.w	d1,d0
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	lea	levbuf,a0
	cmp.b	#diamond,(a0,d0.w)
	bge	diab?
	move.b	#0,(a0,d0.w)
kilbout	rts
diab?	cmp.b	#gwdiamd,(a0,d0.w)
	bge	kilbout
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	move.b	#0,(a0,d0.w)
	subq	#5,d1
	add.w	d1,diagot
	add.w	d1,briint(a4)
	rts

* Make a level and update etc

blanksq	lsr.w	#1,d0		* blank a square
	and.w	#$fff8,d0
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	lsl.w	#5,d1
	add.w	d1,d0
	lea	backbuf,a6
	lea	(a6,d0.w),a6
	moveq	#0,d2
	move.l	d2,(a6)
	move.l	d2,4(a6)
	move.l	d2,160(a6)
	move.l	d2,164(a6)
	move.l	d2,320(a6)
	move.l	d2,324(a6)
	move.l	d2,480(a6)
	move.l	d2,484(a6)
	move.l	d2,640(a6)
	move.l	d2,644(a6)
	move.l	d2,800(a6)
	move.l	d2,804(a6)
	move.l	d2,960(a6)
	move.l	d2,964(a6)
	move.l	d2,1120(a6)
	move.l	d2,1124(a6)
	rts
makelev	lea	levbuf,a1		* make a level
	move.w	#419,d0
coplev	move.b	(a0,d0.w),(a1,d0.w)
	dbra.w	d0,coplev
	cmp.w	#36,level
	beq	putr
	moveq	#diamond,d0
	moveq	#4,d1
diatlp	moveq	#2,d2
dialp	bsr	random
	and.w	#3,d7
	move.w	d7,d3
	add.w	d1,d3
	move.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d3
	lsl.w	#2,d3
newxr	bsr	random
	and.w	#31,d7
	addq	#1,d7
	cmp.w	#18,d7
	bgt	newxr
	add.w	d7,d3
	cmp.b	#diamond,(a1,d3.w)
	bge	dialp
	move.b	d0,(a1,d3.w)
	dbra.w	d2,dialp
	addq	#4,d1
	addq	#1,d0
	cmp.w	#gwdiamd,d0
	bne	diatlp
putr	lea	rockdat,a0
	move.w	#maxrock-1,d0
crocklp	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbra.w	d0,crocklp
	move.w	#5,d0
	lea	rockdat,a0
rocklp	bsr	random
	and.w	#15,d7
	addq.w	#3,d7
	cmp.w	#15,d7
	bge	rocklp
	lsl.w	#2,d7
	move.w	d7,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d7,d1
	move.w	d7,d3		*d3 = yrock
	add.w	d3,d3
	bsr	random
	and.w	#31,d7
	addq	#1,d7
	cmp.w	#18,d7
	bgt	rocklp
	add.w	d7,d1
	lsl.w	#3,d7
	move.w	d7,d4		*d4 = xrock
	add.w	d4,d4
	cmp.b	#0,(a1,d1.w)
	beq	rocklp
	cmp.b	#diamond,(a1,d1.w)
	bge	rocklp
	cmp.b	#0,20(a1,d1.w)
	beq	rocklp
	cmp.b	#diamond,20(a1,d1.w)
	blt	prock
	cmp.b	#wall,20(a1,d1.w)
	blt	rocklp
prock	move.w	d4,d5
	lsr.w	#4,d5
	move.w	#20,d6
cbelolp	cmp.b	#rock,(a1,d5.w)
	beq	rocklp
	add.w	#20,d5
	dbra.w	d6,cbelolp
	move.b	#12,(a1,d1.w)
	move.w	#1,(a0)+
	move.w	d4,(a0)+
	move.w	d3,(a0)+
	add.w	#20,d1
	move.w	d1,(a0)+
	dbra.w	d0,rocklp
	lea	backbuf,a6
	bsr	cls2
	lea	backbuf+16*160,a6
	lea	levbuf,a0
tlevel	move.w	#20,d1
newrow	move.w	#19,d0
newblck	moveq	#0,d2
	move.b	(a0)+,d2
	cmp.b	#diamond,d2
	blt	notpd
	cmp.b	#wall-2,d2
	bge	notpd
	bsr	random
	and.w	#3,d7
	cmp.w	#0,d7
	bne	notpd
	add.w	#(rock-diamond)+1,d2
notpd	subq	#1,d2
	bcs	nograf
	lsl.w	#6,d2
	bsr	putblok
nograf	addq.l	#8,a6
	dbra.w	d0,newblck
	adda.l	#160*7,a6
	dbra.w	d1,newrow
*	lea	levbuf,a1
*	move.b	#0,13(a1)
	rts
putblok	move.l	a6,-(sp)
	lea	backs,a5
	move.w	#7,d7
pblklp	move.l	(a5,d2.w),d3
	move.l	4(a5,d2.w),d4
	move.l	d3,(a6)
	move.l	d4,4(a6)
	addq.l	#8,a5
	adda.l	#160,a6
	dbra.w	d7,pblklp
	movea.l	(sp)+,a6
	rts
	
* Standard Routines

random	moveq	#0,d7		* crap random no generator
	move.b	$ff8209,d7
	add.w	seed,d7
	move.w	d7,d6
	add.w	d6,d6
	add.w	d7,d6
	lsl.w	#8,d7
	sub.w	d6,d7
	and.w	#255,d7
	sub.w	#1,d7
	move.w	d7,seed
	rts
cls	movea.l	back,a6		* Clear the screen
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
copbuf	lea	backbuf,a0		* copy buffer
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
	movea.l	back,a6
spr2	lea	(a5,d2.w),a5
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
	cmp.w	#200,d6
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
joys	move.w	#$22,-(sp)		* joystick set up
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
joy	move.l	a1,-(sp)		;0=up		* joystick routine
	lea	joy0,a1			;1=down
	move.b	1(a0),(a1)		;2=left
	move.b	2(a0),1(a1)		;3=right
	movea.l	(sp)+,a1		;7=fire
	rts
joy0	dc.b	0
joy1	dc.b	0	
retgen	move.l	oldvbl,$70		* return to gen-ST
	bsr	sndres
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
swap	movea.l	back,a4		* swap screens
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
setup	clr.l	-(sp)		* set it up
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
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
	move.l	$70,oldvbl
	move.l	#twinkle,$70
	pea	palette
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
	
* Includes

titpic	ds.b	20
	dc.b	9,9,9,9,0,9,9,9,9,0,9,9,9,9,9,0,9,9,9,9
	dc.b	9,0,0,0,0,9,0,0,0,0,9,0,9,0,9,0,9,0,0,0
	dc.b	9,0,0,9,0,9,9,9,0,0,9,0,9,0,9,0,9,9,9,9
	dc.b	9,0,0,9,0,9,0,0,0,0,9,0,0,0,9,0,0,0,0,9
	dc.b	9,9,9,9,0,9,9,9,9,0,9,0,0,0,9,0,9,9,9,9
	ds.b	5*20
	dc.b	11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
	ds.b	3*20
*	dc.b	9,9,9,9,0,9,9,9,9,0,9,9,9,9,9,0,9,9,9,9
*	dc.b	9,0,0,0,0,9,0,0,0,0,9,0,9,0,9,0,9,0,0,0
*	dc.b	9,0,0,9,0,9,9,9,0,0,9,0,9,0,9,0,9,9,9,9
*	dc.b	9,0,0,9,0,9,0,0,0,0,9,0,0,0,9,0,0,0,0,9
*	dc.b	9,9,9,9,0,9,9,9,9,0,9,0,0,0,9,0,9,9,9,9
	ds.b	5*20
	ds.b	20
	
levels	incbin	"a:\gems\data\levels16.dat"
sprites	incbin	"a:\gems\data\man16x8.dat"
	incbin	"a:\gems\data\demon.dat"
backs	incbin	"a:\gems\data\back16.dat"	
font	incbin	"a:\gems\data\font.dat"
	ds.w	8
saints	incbin	"a:\gems\data\saints.mus"
twiddle	incbin	"a:\gems\data\twiddle.mus"

* Text

cheatst	dc.b	15,11,0,24,19,4,18,19
tittxt1	dc.b	2,2,1,15,10,"WRITTEN BY",2,0
	dc.b	1,13,11,"MARTIN BROWNLOW",2,2
	dc.b	1,14,14,"A VERSION OF",2,0
	dc.b	1,16,15,"DIAMONDS",2,2
	dc.b	1,8,18,"ORIGINALLY BY SIMON HUNT",2,4
	dc.b	1,22,18,"SIMON HUNT",2,6,1,22,18,"SIMON HUNT"
highest	dc.b	2,2,1,12,21,"HIGH SCORE ",2,0,1,23,21
highsp	dc.b	"00000",2,6,1,12,22,"LAST SCORE "
lastsc	dc.b	"00000",0
easylev	dc.b	2,0,1,18,24,"EASY",0
normlev	dc.b	2,2,1,17,24,"NORMAL",0
hardlev	dc.b	2,2,1,18,24,"HARD",2,4,1,18,24,"HARD"
	dc.b	2,6,1,18,24,"HARD",0
scoret1	dc.b	1,0,0,"00000",0
scoret2	dc.b	1,35,0,"00000",0
highsc	dc.b	1,18,0,"00000",0
diatxt	dc.b	1,10,1,"HOLD 00",0
levtxt	dc.b	1,27,1,"L00",0
endtxt1	dc.b	2,6,1,10,15,"CONGRATULATIONS DAN",1,4,17
	dc.b	"YOU HAVE FOUND THE FABLED JEWEL",1,11,19
	dc.b	"BONUS 05000 POINTS",2,4,1,17,19,"05000"
	dc.b	2,2,1,17,19,"05000",2,2,1,5,20,"FINAL SCORE",2,0
finsct	dc.b	1,17,20,"00000",0
endtxt2	dc.b	2,6,1,2,22,"NOW TRY IT ON A MORE DIFFICULT LEVEL",0
 even

* "Variables"

youmve	dc.b	8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,1,0,0,1,0,0
twdat	dc.w	$777,$666,$655,$666
	dc.w	$400,$400,$600,$600
twframe	dc.w	0
oldvbl	dc.l	0
back2	dc.l	$e8000
back	dc.l	$f0000
physic	dc.l	$f8000


palette	dc.w	$000,$666,$050,$030
	dc.w	$034,$013,$544,$222
	dc.w	$444,$210,$310,$320
	dc.w	$660,$440,$400,$000

* "BSS"

	section	BSS

flags	ds.w	1
cmdis	ds.w	1
chon	ds.w	1
diffic	ds.w	1
plane	ds.w	1
flash	ds.w	1
seed	ds.w	1
turn	ds.w	1
score	ds.w	1
oldsc	ds.w	1
high	ds.w	1
level	ds.w	1
baselev	ds.w	1
lives	ds.w	1
ltpnt	ds.w	1
diagot	ds.w	1
diacar	ds.w	1
olddia	ds.w	1
onsq	ds.w	1
falld	ds.w	1
mask	ds.w	1
dead	ds.w	1
dislen	ds.b	1
contpad	ds.b	1

youx	ds.w	1
youy	ds.w	1
yougr	ds.w	1
dir	ds.w	1

brian1	
bri1on	ds.b	1
bri1cnt	ds.b	1
bri1x	ds.w	1
bri1y	ds.w	1
bri1dir	ds.w	1
bri1int	ds.w	1
bri1mty	ds.w	1
bri1mvl	ds.w	1
bri1msk	ds.w	1
bri1ons	ds.w	1

bad2typ	ds.w	1
bad2on	ds.b	1
bad2cnt	ds.b	1
bad2x	ds.w	1
bad2y	ds.w	1
bad2gr	ds.w	1
bad2dir	ds.w	1
bad2int	ds.w	1
bad2mty	ds.w	1
bad2mvl	ds.w	1
bad2msk	ds.w	1
bad2ons	ds.w	1
old2dir	ds.w	1

demon	ds.w	1
demonx	ds.w	1
demony	ds.w	1

rockdat	ds.l	2*maxrock
levbuf	ds.l	10*25
backbuf	ds.l	8000

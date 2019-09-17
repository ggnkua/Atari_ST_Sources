
temp	equ	$30

	move.l	4(sp),a5
	move.l	#end+4096,d0
	move.l	a5,d1
	add.l	d0,d1
	bclr	#0,d1
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	pea	$4a0000
	trap	#1
	lea	12(sp),sp
	tst	d0
	beq.s	okay

	lea	nomem(pc),a1
	bsr	prmes
	bsr	anykey
	bra	exit

okay	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldssp

	dc.w	$a00a

	movem.l	$8240.w,d0-d7
	movem.l	d0-d7,oldpal

	pea	-1.w
	move.l	(sp),-(sp)
	move.l	(sp),-(sp)
	move	#16,-(sp)
	trap	#14
	lea	14(sp),sp
	move.l	d0,a0
	move.l	8(a0),keytable

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,phybase
	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,logbase

	move	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move	d0,oldres
	cmp	#2,d0
	bne.s	colour

	lea	nomono(pc),a1
	bsr	prmes
	bsr	anykey
	bra	exit1

colour	clr	-(sp)
	pea	-1.w
	move.l	(sp),-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move	#$2700,sr
	move.l	$fa06.w,oldier
	clr.b	$fa07.w
	move.b	#$40,$fa09.w
	bclr	#6,$fa0d.w
	bclr	#6,$fa11.w
	bset	#6,$fa15.w
	move.l	$118.w,oldkeyb
	move.l	#keybrd,$118.w
	move.l	$456.w,a0
	move.l	(a0),oldvblq
	move.l	#vbl,(a0)
	move.l	#palette,$45a.w
	move	#$2300,sr
	
	lea	keydat(pc),a0
	moveq	#3-1,d0
	bsr	sendikbd

drawfull
	move.l	#$a0000000,a3
	move.l	#$c0000000,a4
	move.l	#$a3d70a,a1

	bsr	mandel

	bsr	mouseon

* Main loop

main	bsr	wvbl

	move	keys(pc),d0

	cmp	#$13,d0		'r' redraw current
	beq	domand
	cmp	#1,d0		esc exit from program
	beq	desktop
	cmp	#$17,d0		'i' alter iterations
	bne	noti

* Alter iteration

	movem.l	a1/a3/a4,-(sp)
	bsr	screendown
	lea	inpmes(pc),a1
	bsr	prmes

wni	cmp	#$17,keys
	beq.s	wni

	lea	inpbuf(pc),a5
	move.l	a5,a6
nokey	move	keys(pc),d7
	cmp	#$74,d7
	bge.s	nokey
	move.l	keytable(pc),a0
	move.b	0(a0,d7),d1
	beq.s	nokey
	cmp.b	#13,d1
	beq.s	return
	cmp.b	#8,d1
	beq.s	delete
	cmp.l	#inpbuf+10,a6
	beq.s	nokey
	cmp.b	#'0',d1
	blt.s	nokey
	cmp.b	#'9',d1
	bgt.s	nokey
	move.b	d1,(a6)+
	move	d1,d0
	bsr	prchar
waitnk	cmp	keys(pc),d7
	beq.s	waitnk
	bra.s	nokey

delete	cmp.l	a5,a6
	beq.s	nokey
	subq.l	#1,a6
	lea	delmes(pc),a1
	bsr	prmes
	bra.s	waitnk

return	cmp.l	a5,a6		anything in the buffer?
	beq.s	restscr		if not then leave iterations unchanged

	moveq	#0,d0
	moveq	#0,d1
nxtchar	move.b	(a5)+,d0
	sub	#'0',d0
	move.l	d1,d2
	add.l	d1,d1
	add.l	d1,d1
	add.l	d2,d1
	add.l	d1,d1
	add.l	d0,d1
	cmp.l	a5,a6
	bne.s	nxtchar
	move.l	d1,iterations+2

restscr	moveq	#27,d0		put screen back up
	bsr	prchar
	moveq	#'f',d0
	bsr	prchar
	bsr	screenup
	movem.l	(sp)+,a1/a3/a4

noti	cmp	#$21,d0		'f' draw full set
	bne.s	notf

	bsr	mouseoff
	bra	drawfull

notf	cmp	#$61,d0		'undo' redraw last picture
	bne.s	notundo

	movem.l	lastmand(pc),a1/a3/a4
	bra	domand

notundo	cmp	#$2d,d0
	bne.s	notx

	move.l	a1,-(sp)
	bsr	screendown
	lea	xmes(pc),a1
	bsr	prmes
	move.l	a3,d0
	bsr	prhex32
	bsr	space
	move.l	a4,d0
	bsr	prhex32
	bsr	space
	move.l	(sp),d0
	bsr	prhex32
	bsr	space
waitnx	cmp	#$2d,keys
	beq.s	waitnx
waitkey	tst	keys
	beq.s	waitkey
	bsr	screenup
	move.l	(sp)+,a1

notx	cmp	#$39,d0		space
	bne	main

	moveq	#0,d4
	move	box_width(pc),d4
	move.l	a1,d0
	move	d0,d1
	mulu	d4,d1
	swap	d0
	mulu	d4,d0
	swap	d0
	clr	d0
	add.l	d0,d1

* divide d1 by 200
	move.l	#200,d5
	moveq	#0,d2
	moveq	#32-2,d3
	addq	#1,d3
divlp	addx.l	d1,d1
	addx.l	d2,d2
	sub.l	d5,d2
	bcc.s	subok
	add.l	d5,d2
subok	eor	#$10,sr
	dbra	d3,divlp
	addx.l	d1,d1
	tst.l	d1
	bne.s	zoomok

	move	#$2700,sr
	not	$8240.w
	lea	$8800.w,a0
	lea	beepdat(pc),a2
	moveq	#7-1,d0
sndlp	move	(a2)+,d1
	movep	d1,0(a0)
	dbra	d0,sndlp
	not	$8240.w
	move	#$2300,sr
	bra	main

zoomok	movem.l	a1/a3/a4,lastmand

	move	mousex(pc),d2	Calculate top left corner of box, position
	move	mousey(pc),d3	in d2,d3
	sub	d4,d3
	lsl	#3,d4
	divu	#5,d4
	sub	d4,d2

	move.l	a1,d4
	move	d4,d5
	mulu	d2,d5
	swap	d4
	mulu	d2,d4
	swap	d4
	clr	d4
	add.l	d4,d5
	add.l	d5,a3	a3=a3+x*a1

	move.l	a1,d4
	move	d4,d5
	mulu	d3,d5
	swap	d4
	mulu	d3,d4
	swap	d4
	clr	d4
	add.l	d4,d5
	add.l	d5,a4	a4=a4+y*a1

	move.l	d1,a1

domand	bsr	mouseoff

	bsr.s	mandel

	bsr	mouseon
	bra	main

*
* Display portion of Mandelbrot set with top left corner a3+a4i
* height and width a1*200
*

mandel	movem.l	a1/a3/a4/a7,regstor
	move	#1,manding

	move.l	$44e.w,a5

	lea	200*160(a5),a6
	move.l	a6,compare+2

	move.l	a4,d4		bc=sy
	moveq	#2-1,d0
row2lp	move	d0,-(sp)
	move.l	a3,d3		ac=sx
	bsr	calculate
	lea	store1(pc),a2
	move	d1,(a2)+	
	add.l	a1,d3
	bsr	calculate
	move	d1,(a2)+

	move	#318/2-1,d7
pairlp	add.l	a1,d3
	move.l	d3,d2
	add.l	a1,d3
	bsr	calculate
	move	d1,2(a2)
	cmp	-2(a2),d1
	beq.s	same
	exg	d3,d2
	bsr	calculate
	move	d1,(a2)
	move.l	d2,d3
	bra.s	nxt1
same	move	d1,(a2)
nxt1	addq.l	#4,a2
	dbra	d7,pairlp

	lea	store1(pc),a2
	moveq	#20-1,d0
wordlp	move	d0,-(sp)
	moveq	#16-1,d2
bitlp	move	(a2)+,d1
	lsr	#1,d1
	roxl	#1,d0
	lsr	#1,d1
	roxl	#1,d5
	lsr	#1,d1
	roxl	#1,d6
	lsr	#1,d1
	roxl	#1,d7
	dbra	d2,bitlp
	move	d0,(a5)+
	move	d5,(a5)+
	move	d6,(a5)+
	move	d7,(a5)+
	move	(sp)+,d0
	dbra	d0,wordlp

	add.l	a1,d4		
	move	(sp)+,d0
	dbra	d0,row2lp

	lea	store2(pc),a2
	lea	store1(pc),a4
*
* Calculate lines in pairs
*

pair2lp	movem.l	d4/a2/a4,-(sp)
	add.l	a1,d4

	move.l	a3,d3		ac=sx
	bsr	calculate
	move	d1,(a2)+	
	add.l	a1,d3
	bsr	calculate
	move	d1,(a2)+

	move	#318/2-1,d7
pairlp0	add.l	a1,d3
	move.l	d3,d2
	add.l	a1,d3
	bsr	calculate
	move	d1,2(a2)
	cmp	-2(a2),d1
	beq.s	same0
	exg	d3,d2
	bsr	calculate
	move	d1,(a2)
	move.l	d2,d3
	bra.s	nxt10
same0	move	d1,(a2)
nxt10	addq.l	#4,a2
	dbra	d7,pairlp0

	move.l	4(sp),a2
	move.l	a5,a6
	lea	160(a5),a5
	moveq	#20-1,d0
wordlp0	move	d0,-(sp)
	moveq	#16-1,d2
bitlp0	move	(a2)+,d1
	lsr	#1,d1
	roxl	#1,d0
	lsr	#1,d1
	roxl	#1,d5
	lsr	#1,d1
	roxl	#1,d6
	lsr	#1,d1
	roxl	#1,d7
	dbra	d2,bitlp0
	move	d0,(a5)+
	move	d5,(a5)+
	move	d6,(a5)+
	move	d7,(a5)+
	move	(sp)+,d0
	dbra	d0,wordlp0

	move.l	(sp)+,d5
	movem.l (sp),a2/a4
	move.l	d4,-(sp)
	move.l	d5,d4
	move.l	a3,d3
	moveq	#20-1,d0
wordlp1	move	d0,-(sp)
	moveq	#16-1,d2
bitlp1	move	(a2)+,d1
	cmp	(a4)+,d1
	beq.s	same1
	bsr.s	calculate
same1	add.l	a1,d3
	lsr	#1,d1
	roxl	#1,d0
	lsr	#1,d1
	roxl	#1,d5
	lsr	#1,d1
	roxl	#1,d6
	lsr	#1,d1
	roxl	#1,d7
	dbra	d2,bitlp1
	move	d0,(a6)+
	move	d5,(a6)+
	move	d6,(a6)+
	move	d7,(a6)+
	move	(sp)+,d0
	dbra	d0,wordlp1

	movem.l	(sp)+,d4/a2/a4
	exg	a2,a4
	add.l	a1,d4

compare	cmp.l	#0,a5
	bne	pair2lp

mandout	clr	manding
	movem.l	regstor(pc),a1/a3/a4/a7
	rts			done mandelbrot


* Calculate point at d3+d4i

calculate
	movem.l	d0/d2-d7,-(sp)

	move.l	d3,d5
	move.l	d4,d6
	sub.l	a0,a0

calc	move.l	d5,d2
	bsr	square
	bmi.s	out_of_range
	move.l	d2,(temp).w
	move.l	d6,d2
	bsr	square
	bmi.s	out_of_range
	move.l	(temp).w,d1
	add.l	d2,d1
	bcs.s	done
	cmp.l	#$80000000,d1
	bcc.s	out_of_range
iterations
	cmp.l	#100,a0
	beq.s	done
	add.l	d6,d6
	bsr	multiply
	add.l	d4,d6
	move.l	(temp).w,d5
	sub.l	d2,d5
	add.l	d3,d5
	addq	#1,a0
	bra.s	calc

out_of_range
	moveq	#0,d1
	move	a0,d1
	divu	#15,d1
	swap	d1
	addq	#1,d1
	movem.l	(sp)+,d0/d2-d7
	rts

done	moveq	#0,d1
	movem.l	(sp)+,d0/d2-d7
	rts

* Square a number in d2

square	movem.l	d3/d4,-(sp)
	tst.l	d2
	bpl.s	splus
	neg.l	d2
splus	moveq	#0,d0
	moveq	#0,d1
	move.l	d2,d3
	moveq	#0,d4

	move	d2,d3
	move	d2,d0
	mulu	d2,d0
	swap	d2
	move	d2,d1
	mulu	d2,d1
	mulu	d2,d3
	swap	d3
	moveq	#0,d4
	move	d3,d4
	clr	d3
	add.l	d3,d0
	addx.l	d4,d1
	add.l	d3,d0
	addx.l	d4,d1

	rol.l	#3,d0
	and	#7,d0
	cmp.l	#$10000000,d1
	bcc.s	overflow
	lsl.l	#3,d1
	or	d0,d1
	move.l	d1,d2
	movem.l	(sp)+,d3/d4
	rts

overflow
	moveq	#-1,d0
	movem.l	(sp)+,d3-d4
	rts
	
* Multiply d6 by d5

multiply
	movem.l	d2-d4,-(sp)

	moveq	#0,d3
	move.l	d5,d2

	tst.l	d2
	bpl.s	d2plus
	moveq	#1,d3
	neg.l	d2
d2plus	tst.l	d6
	bpl.s	d6plus
	eor	#1,d3
	neg.l	d6
d6plus	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d4
	move	d3,-(sp)

	move	d2,d7
	move	d2,d0
	mulu	d6,d0
	swap	d2
	move	d2,d3
	mulu	d6,d3
	swap	d6
	move	d2,d1
	mulu	d6,d1
	swap	d3
	moveq	#0,d4
	move	d3,d4
	clr	d3
	add.l	d3,d0
	addx.l	d4,d1
	mulu	d6,d7
	swap	d7
	move	d7,d4
	clr	d7
	add.l	d7,d0
	addx.l	d4,d1

	rol.l	#3,d0
	and	#7,d0
	lsl.l	#3,d1
	or	d0,d1
	move.l	d1,d6
	move	(sp)+,d2
	tst	d2
	beq.s	mokay
	neg.l	d6
mokay	movem.l	(sp)+,d2-d4
	rts


* Various routines

screendown
	move.l	phybase(pc),a0
	lea	-1280(a0),a0
	move	#-1,-(sp)
	pea	(a0)
	pea	(a0)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	rts

screenup
	move	#-1,-(sp)
	move.l	phybase(pc),-(sp)
	move.l	(sp),-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	rts

prhex32	move	d0,-(sp)
	swap	d0
	bsr.s	prhex16
	move	(sp)+,d0
prhex16	move	d0,-(sp)
	lsr	#8,d0
	bsr.s	prhex8
	move	(sp)+,d0
prhex8	move	d0,-(sp)
	lsr	#4,d0
	bsr.s	prhex4
	move	(sp)+,d0
prhex4	and	#$f,d0
	move.b	hexdat(pc,d0),d0
	bra.s	prchar

hexdat	dc.b	'0123456789ABCDEF'

space	moveq	#32,d0
prchar	move	d0,-(sp)
	pea	$30002
	trap	#13
	addq.l	#6,sp
	rts

prmes	pea	(a1)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

anykey	lea	anymes(pc),a1
	bsr.s	prmes
	pea	$20002
	trap	#13
	addq.l	#4,sp
	rts

sendikbd
keylp	move.b	(a0)+,d1
	bsr.s	sendkb
	dbra	d0,keylp
	rts

sendkb	btst	#1,$fc00.w
	beq.s	sendkb
	move.b	d1,$fc02.w
	rts
	
wvbl	move.l	$466.w,d0
waitlp	cmp.l	$466.w,d0
	beq.s	waitlp
	rts

mouseon	movem.l	d0-d7/a0-a6,-(sp)
	bsr	drawbox
	bsr	drawm
	move.l	mousex(pc),nmousex
	movem.l	(sp)+,d0-d7/a0-a6
	move	#1,mouse
	rts

mouseoff
	clr	mouse
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	undraw
	bsr	undrawbox
	movem.l	(sp)+,d0-d7/a0-a6
	rts


* Vertical blank handler

vbl	move	keys(pc),d0

	cmp	#$32,d0		m set multi-colours
	bne.s	notm

	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$8240.w

notm	cmp	#$1f,d0		s set up single colours
	bne.s	nots

	lea	$8242.w,a0
	move.l	#$7770606,(a0)+
	move.l	#$7770606,(a0)+
	move.l	#$7770606,(a0)+
	move.l	#$7770606,(a0)+
	move.l	#$7770606,(a0)+
	move.l	#$7770606,(a0)+
	move.l	#$7770606,(a0)+
	move	#$777,(a0)

nots	cmp	#$2e,d0		c start cycling
	bne.s	noc

	move	#1,cycle
	move	#5,tmpdel

noc	cmp	#$2f,d0		v stop cycling
	bne.s	notsp

	clr	cycle

notsp	tst	cycle
	beq.s	nocyc

	cmp	#$4e,d0		+ on keypad speed up cycling	
	bne.s	notdec

	cmp	#1,delay
	beq.s	notdec
	subq	#1,delay

notdec	cmp	#$4a,d0		- on keypad slow down cycling
	bne.s	notinc

	addq	#1,delay

notinc	subq	#1,tmpdel
	bne.s	nocyc
	move	delay(pc),tmpdel
	lea	$8260.w,a0
	lea	$825e.w,a1
	move	(a1),d0
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	-(a1),-(a0)
	move	d0,(a1)

nocyc	tst	mouse
	beq	nomouse

	bsr	undraw
	bsr	undrawbox

	move	keys(pc),d0
	move.l	nmousex(pc),d2
	move.l	d2,d1
	swap	d1
	cmp	#$48,d0
	bne.s	notup
	subq	#1,d2
notup	cmp	#$50,d0
	bne.s	notdown
	addq	#1,d2
notdown	cmp	#$4b,d0
	bne.s	notleft
	subq	#1,d1
notleft	cmp	#$4d,d0
	bne.s	notrigh
	addq	#1,d1

notrigh	tst	d1		make sure d1 & d2 are on screen
	bpl.s	kmxok
	clr	d1
kmxok	cmp	#319,d1
	ble.s	kmxok1
	move	#319,d1
kmxok1	tst	d2
	bpl.s	kmyok
	clr	d2
kmyok	cmp	#199,d2
	ble.s	kmyok1
	move	#199,d2
kmyok1	move	d1,mousex
	move	d2,mousey	

	tst	leftbutton
	beq.s	nolb
	cmp	#1,box_width
	beq.s	nolb
	subq	#1,box_width
nolb	tst	rightbutton
	beq.s	norb
	cmp	#100,box_width
	beq.s	norb
	addq	#1,box_width

norb	move	box_width(pc),d5
	moveq	#0,d6
	move	d5,d6
	lsl	#3,d6
	divu	#5,d6
	cmp	mousex(pc),d6
	ble.s	mxokay
	move	d6,mousex
mxokay	cmp	mousey(pc),d5
	ble.s	myokay
	move	d5,mousey
myokay	bsr	drawbox
	bsr	drawm
	move.l	mousex(pc),nmousex

nomouse	rts

	
drawm	moveq	#0,d0
	move	mousey(pc),d0
	move	d0,d1
	add	d0,d0
	add	d0,d0
	add	d1,d0
	lsl	#5,d0
	move	mousex(pc),d1
	move	d1,d2
	lsr	#1,d1
	and	#$fff8,d1
	add	d1,d0
	move.l	phybase(pc),a0
	add.l	d0,a0
	and	#$f,d2
	lea	trash(pc),a1
	move.l	mousedatapnt(pc),a2
	move.l	a0,(a1)+
	move	#200,d3
	sub	mousey(pc),d3
	cmp	#16,d3
	ble.s	fulsize
	moveq	#16,d3
fulsize	subq	#1,d3
	move	d3,(a1)+
	cmp	#152,d1
	beq.s	rightedge
drawlp	movem.l	(a0),d4-d7
	movem.l	d4-d7,(a1)
	lea	16(a1),a1
	moveq	#0,d0
	move	(a2)+,d0
	not	d0
	swap	d0
	lsr.l	d2,d0
	not.l	d0
	move.l	a0,a4
	swap	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	swap	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	moveq	#0,d0
	move	(a2)+,d0
	swap	d0
	lsr.l	d2,d0
	or	d0,8(a0)
	swap	d0
	or	d0,(a0)
	moveq	#0,d0
	move	(a2)+,d0
	swap	d0
	lsr.l	d2,d0
	or	d0,10(a0)
	swap	d0
	or	d0,2(a0)
	lea	160(a0),a0
	dbra	d3,drawlp
	rts
rightedge
	movem.l	(a0),d4-d7
	movem.l	d4-d7,(a1)
	lea	16(a1),a1
	move	(a2)+,d0
	not	d0
	lsr	d2,d0
	not	d0
	move.l	a0,a4
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	move	(a2)+,d0
	lsr	d2,d0
	or	d0,(a0)
	move	(a2)+,d0
	lsr	d2,d0
	or	d0,2(a0)
	lea	160(a0),a0
	dbra	d3,rightedge
	rts

undraw	lea	trash(pc),a0
	move.l	(a0)+,a1
	move	(a0)+,d4
undrlp	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,(a1)
	lea	160(a1),a1
	dbra	d4,undrlp
	rts

undrawbox
	move.l	oldbxy(pc),d1
	bra.s	db

drawbox	move.l	mousex(pc),d1
	move.l	d1,oldbxy
db	move.l	d1,d0
	swap	d0
	move	box_width(pc),d2
	moveq	#0,d3
	move	d2,d3
	lsl	#3,d3
	divu	#5,d3

	move	d1,d4
	add	d1,d1
	add	d1,d1
	add	d4,d1
	lsl	#5,d1
	move.l	phybase(pc),a0
	add	d1,a0
	move	d0,d7
	and	#$f,d7
	eor	#$f,d7
	lsr	#1,d0
	and	#$fff8,d0
	add	d0,a0		a0=address of bottom right corner of box
	move	d2,d0
	add	d0,d0
	add	d0,d0
	add	d2,d0
	lsl	#5,d0
	neg	d0
	lea	0(a0,d0),a2
	move	d7,d6

	moveq	#0,d1
horizlp	bset	d7,d1
	subq	#1,d3
	bmi.s	donehor
	addq	#1,d7
	cmp	#16,d7
	bne.s	horizlp
	moveq	#0,d7
	eor	d1,(a0)
	eor	d1,0(a0,d0)
	moveq	#0,d1
	subq.l	#8,a0
	bra.s	horizlp

donehor	eor	d1,(a0)
	eor	d1,0(a0,d0)

	add	d0,a0
	cmp	#8,d7
	bge.s	upby
	addq.l	#1,a0
	bra.s	chkd6
upby	and	#7,d7
chkd6	cmp	#8,d6
	bge.s	upby1
	addq.l	#1,a2
	bra.s	vertlp
upby1	and	#7,d6

vertlp	lea	160(a0),a0
	lea	160(a2),a2
	subq	#1,d2
	beq.s	donever
	bchg	d7,(a0)
	bchg	d6,(a2)
	bra.s	vertlp

donever	rts


* Keyboard handler
	
keybrd	movem.l	d0/d1/a0,-(sp)

again	move.b	$fc00.w,d1
	btst	#7,d1
	beq	keyout
	btst	#0,d1
	beq	keyo

	moveq	#0,d0
	move.b	$fc02.w,d0
	tst	length
	beq.s	nopack

	move.l	bufpnt(pc),a0
	move.b	d0,(a0)+
	move.l	a0,bufpnt
	subq	#1,length
	bne	keyo

	lea	keybuf(pc),a0
	and.b	#$fc,(a0)
	cmp.b	#$f8,(a0)+
	bne	keyo

	move.b	(a0)+,d0
	ext	d0
	add	d0,nmousex
	move.b	(a0)+,d0
	ext	d0
	add	d0,nmousey
	bra	keyo

nopack	cmp	#$f6,d0
	blt.s	akey

	lea	keybuf(pc),a0
	move.b	d0,(a0)+
	move.l	a0,bufpnt
	sub	#$f6,d0
	move.b	lengths(pc,d0),d0
	move	d0,length
	bra	keyo

lengths	dc.b	7,5,2,2,2,2,6,2,1,1

akey	cmp	#$52,d0		Test for mouse simulating keys
	beq.s	leftb
	cmp	#$74,d0
	bne.s	notlon
leftb	move	#1,leftbutton
	bra	keyo
notlon	cmp	#$d2,d0
	beq.s	lefto
	cmp	#$f4,d0
	bne.s	notloff
lefto	clr	leftbutton
	bra.s	keyo
notloff	cmp	#$47,d0
	beq.s	rightb
	cmp	#$75,d0
	bne.s	notron
rightb	move	#1,rightbutton
	bra.s	keyo
notron	cmp	#$c7,d0
	beq.s	righto
	cmp	#$f5,d0
	bne.s	notmkey
righto	clr	rightbutton
	bra.s	keyo

* if not a mouse key then it's a keyboard key

notmkey	tst.b	d0		Is it a on or off key
	bmi.s	keyoff

	move	keys(pc),lastkey
	move	d0,keys
	bra.s	keyo

keyoff	and	#$7f,d0
	cmp	keys(pc),d0	Is it current key going off
	bne.s	notkeys

	move	lastkey(pc),keys	bring lastkey into current
	clr	lastkey		current key off
	bra.s	keyo

notkeys	cmp	lastkey(pc),d0
	bne.s	keyo

	clr	lastkey		lastkey off

keyo	move	leftbutton(pc),d0
	and	rightbutton(pc),d0
	beq.s	noexm

	tst	manding
	beq.s	noexm

	move.l	#mandout,14(sp)

noexm	btst	#5,d1
	beq.s	keyout

	tst.b	$fc02.w

keyout	btst	#4,$fa01.w
	beq	again

	movem.l	(sp)+,d0/d1/a0
	bclr	#6,$fa11.w
	rte

* Return to desktop

desktop	move	#$2700,sr
	move.l	oldier(pc),$fa06.w
	move.l	oldkeyb(pc),$118.w
	move.l	$456.w,a0
	move.l	oldvblq(pc),(a0)
	move	#$2300,sr

	lea	keydat1(pc),a0
	moveq	#2-1,d0
	bsr	sendikbd

	movem.l	oldpal(pc),d0-d7
	movem.l	d0-d7,$8240.w

exit1	move	oldres(pc),-(sp)
	move.l	phybase(pc),-(sp)
	move.l	logbase(pc),-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	move.l	oldssp(pc),-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
exit	clr	-(sp)
	trap	#1


* Various data

nomem	dc.b	27,'EOut of memory',0
nomono	dc.b	27,'EColour monitors only',0
anymes	dc.b	13,10,13,10,'Press any key',0
inpmes	dc.b	27,'e',27,'H',27,'b',1,27,'K'
	dc.b	'Enter number of iterations ',0
delmes	dc.b	8,32,8,0
xmes	dc.b	27,'H',27,'K',27,'b',1,0

	even

mousedatapnt
	dc.l	mousedata
mousedata
	dc.w	$7F,$FF80,0,$7F,$FF80,$7F00,$FF,$FF00
	dc.w	$7E00,$1FF,$FE00,$7C00,$3FF,$FC00,$7800,$1FF
	dc.w	$FE00,$7400,$8FF,$F700,$6200,$1C7F,$E380,$4100
	dc.w	$3E3F,$C1C0,$80,$FF1F,$E0,$40,$FF8F,$70
	dc.w	$20,$FFC7,$38,$10,$FFE3,$1C,8,$FFF1
	dc.w	14,4,$FFFB,4,0,$FFFF,0,0

box_width
	dc.w	60

mouse	dc.w	0
keys	dc.w	0
lastkey	dc.w	0
leftbutton	dc.w	0
rightbutton	dc.w	0
mousex	dc.w	120
mousey	dc.w	100
nmousex	dc.w	0
nmousey	dc.w	0
oldbxy	dc.l	0
length	dc.w	0
bufpnt	dc.l	0
keybuf	ds.b	8
keydat	dc.b	7,4,8
keydat1	dc.b	7,0

oldier	dc.l	0
oldkeyb	dc.l	0
oldssp	dc.l	0
oldvblq	dc.l	0
oldres	dc.w	0
phybase	dc.l	0
logbase	dc.l	0
keytable	dc.l	0

beepdat	dc.w	$068,$104,$b00,$c49,$d00,$810,$7fe

palette	dc.w	$000,$072,$062,$153,$243,$234,$324,$415
	dc.w	$414,$413,$412,$500,$410,$320,$241,$062

cycle	dc.w	0
delay	dc.w	5
tmpdel	dc.w	5

pattern	dc.w	$ffff

manding	dc.w	0
regstor	ds.l	4
lastmand
	dc.l	$a3d70a,$a0000000,$c0000000

inpbuf	ds.b	10

oldpal
buffer	equ	oldpal+32
trash	equ	buffer+512
store1	equ	trash+300
store2	equ	store1+640
end	equ	store2+640

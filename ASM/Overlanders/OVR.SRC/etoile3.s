**************************************************************
*                   - The crazy Stars demo -                 *
* Coded by Ziggy STARDUST from OVERLANDERS in december 1989. *
**************************************************************
* Sorry if there is no comment, but I hate write them! 

NTIME	equ	410
DTIME	equ	3
DISTSCR	equ	200
NSPR	equ	7
CENTRE	equ	114
NPOS	equ	75
NPLT	equ	500

	include	\etoiles.ovr\util.s
debut:
	clr.w	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#4,a7
	
 	move.b	#%110,$484
	
	move.b	#18,$fffc02
	
	move.l	$44e,oldec
	move.b	$ffff8260,oldrez
	
	move.l	#ecran,d0
	andi.l	#$ffff00,d0
	move.l	d0,ec1
	addi.l	#46080,d0
	move.l	d0,ec2
	
	move.w	#0,-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	
	lea	logo+128+38*160,a6
	lea	boule,a1
	bsr	decspr
	
	lea	$ffff8240,a0
	rept	8
	clr.l	(a0)+
	endr
	
	lea	ecran,a0
	move.w	#(46080*2+256)/4-1,d0
cls:
	clr.l	(a0)+
	
	dbra	d0,cls
	
	lea	degr+2,a0
	lea	rdegr,a1
	move.w	#19-1,d0
copcol:
	move.w	(a0),(a1)+
	move.w	(a0)+,(a1)+

	dbra	d0,copcol
	move.l	#-1,(a1)+
	
	lea	logo+128,a0
	move.l	ec1,a1
	adda.l	#226*160,a1
	move.w	#34,d0
	bsr	bmove32
	
	move.l	ec1,a0
	move.l	ec2,a1
	move.w	#286,d0
	bsr	bmove32
	
	lea	fontd+36,a0
	move.w	#32000/4-1,d0
cls2:
	clr.l	(a0)+
	
	dbra	d0,cls2
	
	bsr	decl
	
	moveq #1,d0       ; d0=1,2,3.
	bsr player

	move.l	ec1,a0
	adda.l	#100*160+6,a0
	move.l	a0,oad1
	move.l	a0,oad2	
	lea	oldpos,a0
	rept	NSPR*2
	move.l	ec1,(a0)+
	endr
	move.w	#$334,logo+6
	move.l	#$6670667,logo+8
	
	bsr	inter
	bsr	makeplot
	
wtext:
	cmpi.l	#text,ctext
	blt.s	wtext
	movem.l	null(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	stop	#$2300
	move.b	ec1+1,$ffff8201.w
	move.b	ec1+2,$ffff8203.w
	
	move.l	#vbl,$70.w
	
mainloop:
	stop	#$2300
	
	cmpi.b	#$39,$fffffc02.w
	bne.s	mainloop
	
fin:
	bsr	finmfp
	
	lea	$ffff8240,a0
	rept	8
	clr.l	(a0)+
	endr
	
	move.l	#$08000000,$ffff8800.w
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w

	move.b	oldrez,d0
	ext.w	d0
	move.w	d0,-(a7)
	move.l	oldec,-(a7)
	move.l	oldec,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	
	move.b	#8,$fffc02
	
	move.w	#$777,$ff8246

	clr.w	-(a7)
	trap	#1

makeplot:			* Pr‚paration des points
	move.l	ec2,a6
	adda.l	#CENTRE*160,a6
	lea	posxy,a0
	move.w	#NPOS-1,d0	* NPOS positions diff‚rente (1.5 secondes)
loopplt1:
	lea	iposxy,a1
	move.w	#NPLT-1,d1	* NPLT points.
loopplt2:
	move.w	(a1)+,d2
	move.w	(a1)+,d3
	move.w	(a1),d4
	subq.w	#1,d4
	tst.w	d4
	bgt	posiz
	addi.w	#NPOS,d4
posiz:
	move.w	d4,(a1)+
	move.w	d4,d6
	
norot:
	muls	#20,d2
	divs	d6,d2
	muls	#20,d3
	divs	d6,d3

	addi.w	#160,d2
	
	move.w	#%1000000000000000,d5
	
	cmpi.w	#0,d2
	bge	oknx
	move.w	#0,d2
	move.w	#0,d3
	move.w	#0,d5
oknx:
	cmpi.w	#-CENTRE,d3
	bge	okny
	move.w	#0,d2
	move.w	#0,d3
	move.w	#0,d5
okny:
	cmpi.w	#320,d2
	blt	okpx
	move.w	#0,d2
	move.w	#0,d3
	move.w	#0,d5
okpx:
	cmpi.w	#286-CENTRE,d3
	blt	okpy
	move.w	#0,d2
	move.w	#0,d3
	move.w	#0,d5
okpy:
	muls	#160,d3
	move.w	d2,d4
	lsr.w	#4,d2
	lsl.w	#3,d2
	andi.w	#$f,d4
	ext.l	d2
	add.l	d3,d2

	neg.w	d6
	addi.w	#NPOS,d6	
	ext.l	d6
	divs	#NPOS/3,d6
	cmpi.w	#2,d6
	blt	okcol
	move.w	#1,d6
	tst.w	d5
	beq	okcol
	move.w	#%1100000000000000,d5
okcol:
	lsr.w	d4,d5
	lsl.w	#1,d6
	
	move.w	4(a6,d2),d7
	or.w	6(a6,d2),d7
	tst.w	d7
	beq	okmask
	clr.l	d5
	clr.l	d2
	
okmask:
	add.w	d6,d2
	move.w	d2,(a0)+
	move.w	d5,(a0)+

	dbra	d1,loopplt2
	
	lea	4(a2),a2
	
	dbra	d0,loopplt1
	
	rts

affplot:	
	move.l	cposxy,a6
	lea	-4*NPLT*2(a6),a0
	cmpa.l	#posxy,a0
	bge	okxy2
	adda.l	#4*NPLT*NPOS,a0
okxy2:
	move.l	ec1,a5
	adda.l	#CENTRE*160,a5
	move.w	#NPLT/10-1,d7
	moveq.l	#0,d3
loopeffp:
	rept	10
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	d3,(a5,d1.w)
	endr
	
	dbra	d7,loopeffp
	
	move.w	#NPLT/10-1,d7
loopaffp:
	rept	10
	move.w	(a6)+,d1
	move.w	(a6)+,d2
	or.w	d2,(a5,d1.w)
	endr
	
	dbra	d7,loopaffp

	cmpa.l	#fposxy,a6
	blt	okxy
	move.l	#posxy,a6
okxy:
	move.l	a6,cposxy
	
	rts
	
scrolltext:
	move.l	oad2,a0
	move.l	oad1,oad2
	move.l	a0,oad1

	moveq	#18,d0
	moveq	#0,d1
loopcl:
	move.w	d1,(a0)
N	set	8
	rept	19
	move.w	d1,N(a0)
N	set	N+8
	endr
	lea	160(a0),a0

	dbra	d0,loopcl

	move.l	ctext,a0
	move.w	cdec,d0
	subq.w	#4,d0
	tst.w	d0
	bge	okdec
	addi.w	#32,d0
	addq.l	#1,a0
	
	move.b	(a0),d1
	
	cmpi.b	#'a',d1
	blt	nominu
	subi.b	#32,d1
nominu:
	
	cmpi.b	#32,d1
	bge	ok32
	move.b	#32,d1
ok32:
	cmpi.b	#92,d1
	ble	ok92
	move.b	#32,d1
ok92:
	ext.w	d1
	subi.w	#32,d1
	
	lea	tlet+10*4,a1
N	set	0
	rept	10
	move.l	N-4(a1),N(a1)
N	set	N-4
	endr
	
	lea	fontd+36,a1
	muls	#6*19,d1
	lea	(a1,d1),a1
	move.l	a1,tlet
	
	cmpa.l	#ftext,a0
	blt	okdec
	move.l	#text,a0

okdec:
	move.w	d0,cdec
	move.l	a0,ctext
	
	lsr.w	#2,d0
	move.w	d0,d1
	cmpi.w	#4,d1
	blt	ok4
	subi.w	#4,d1
ok4:
	muls	#60*6*19,d1
	
	lea	sinus3,a1
	move.w	tsin,d7
	addq.w	#2,d7
	cmpi.w	#384,d7
	blt	oktsin
	subi.w	#384,d7
oktsin:
	move.w	d7,tsin
	
	lsl.w	#1,d7
	move.w	(a1,d7.w),d7
	muls	#72*2,d7
	asr.l	#8,d7
	asr.l	#6,d7
	tst.l	d7
	blt	okneg
	neg.l	d7
okneg:
	addi.l	#CENTRE*2-20,d7
	move.l	d7,ty
	
	lea	mul160,a1
	asl.l	#2,d7
	move.l	(a1,d7),d7
	
	move.l	ec1,a1
	lea	6(a1,d7.l),a1
	move.l	a1,oad1
	lea	tlet+11*4,a2
	move.l	-(a2),a0
	lea	(a0,d1),a0
	
	cmpi.w	#4,d0
	blt	noleft
	
N	set	0
	rept	19
	lea	2(a0),a0
	move.w	(a0)+,N(a1)
	move.w	(a0)+,N+8(a1)
N	set	N+160
	endr
	lea	8(a1),a1
contleft:

	move.w	#8,d7
loopaffl:
	move.l	-(a2),a0
	lea	(a0,d1),a0
	
N	set	0
	rept	19
	move.w	(a0)+,d2
	or.w	d2,N(a1)
	move.w	(a0)+,N+8(a1)
	move.w	(a0)+,N+16(a1)
N	set	N+160
	endr
	lea	16(a1),a1
	
	dbra	d7,loopaffl
	
	move.l	-(a2),a0
	lea	(a0,d1),a0
	
	cmpi.w	#4,d0
	bge	noright
	
N	set	0
	rept	19
	move.w	(a0)+,d2
	or.w	d2,N(a1)
	move.w	(a0)+,N+8(a1)
	lea	2(a0),a0
N	set	N+160
	endr
contright:

	rts
	
noleft:
N	set	0
	rept	19
	lea	4(a0),a0
	move.w	(a0)+,N(a1)
N	set	N+160
	endr
	bra	contleft
	
noright:
N	set	0
	rept	19
	move.w	(a0)+,d2
	or.w	d2,N(a1)
	lea	4(a0),a0
N	set	N+160
	endr

	bra	contright
	
bmove1p:
N	set	0
	rept	20
	move.w	N(a0),N(a1)
N	set	n+8
	endr
	lea	160(a0),a0
	lea	160(a1),a1
	dbra	d0,bmove1p
	
	rts
	
bmove32:
	rept	40
	move.l	(a0)+,(a1)+
	endr
	dbra	d0,bmove32
	rts

decl:	
	lea	fontd+36,a1
	
	move.w	#12,d0
loopdecal:
	lea	font,a0
	move.w	#60*19-1,d1
loopdecal2:
	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	lsl.l	d0,d2
	lsl.l	d0,d3
	swap	d3
	or.w	d3,d2
	swap	d3
	move.l	d2,(a1)+
	move.w	d3,(a1)+

	dbra	d1,loopdecal2
	
	subq.w	#4,d0
	bge	loopdecal

	rts
	
inter:	
	bsr	initmfp

	move.b	#1,$fffffa07.w
	clr.b	$fffffa09.w
	move.b	#1,$fffffa13.w
	clr.b	$fffffa15.w
	bclr	#3,$fffffa17.w
	
	move.l	#vbl2,$70.w
	rts
	
initmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	move.w	#16,d0
	
savemfp:
	move.b	(a0),(a1)+
	addq.l	#2,a0

	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7		; On sauvegarde les vecteur MFP
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7		; Et 68000...
	movem.l	d0-d7,oldvec+$40
	
	rte
	
finmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
	
restmfp:

	move.b	(a0)+,(a1)
	addq.l	#2,a1

	dbra	d0,restmfp
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58
	
	rte
	
	section	bss
	
	even
oldmfp	ds.b	24
oldvec	ds.l	24
	even

	section	text
		
starthbl:
	clr.b	$fffa1b
	move.b	#1,$fffa21
	move.b	#8,$fffa1b
	move.l	#hbl,$120.w
	rte

hbl:
	move.l	(a4),$ffff8250.w
	ble	hbl2
	move.l	(a4),$ffff8254.w
	move.l	(a4),$ffff8258.w
	move.l	(a4)+,$ffff825c.w
	rte
	
hbl2:
	move.l	logo+4+$0,$ffff8240.w
	move.l	logo+4+$4,$ffff8244.w
	move.l	logo+4+$10,$ffff8250.w
	move.l	logo+4+$14,$ffff8254.w
	move.l	logo+4+$18,$ffff8258.w
	move.l	logo+4+$1c,$ffff825c.w
	clr.b	$fffffa1b.w
	move.b	tty,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#finhbl,$120.w
	rte
	
finhbl:
	clr.b	$fffffa1b.w
	
	move.l	#overs,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	
	stop	#$2500
	
	rte
	
overs:
	move.b	#0,$ffff820a.w
	rept	12
	nop
	endr
	move.b	#2,$ffff820a.w
	
	clr.b	$fffffa1b.w
	rte
	
vbl2:
	movem.l	a0-a6/d0-d7,-(a7)
	
	move.l	#boule,curboule
	move.w	#1,tvbl
	
	move.l	ty,d7
	move.w	d7,d6
	neg.w	d6
	addi.w	#229-20,d6
	move.b	d6,tty 

	move.w	#$777,$ffff8250.w
	
	move.l	logo+4+8,$ffff8248.w
	move.l	logo+4+12,$ffff824c.w
	
	move.l	#$334,$ffff8240.w
	move.l	#$6670667,$ffff8244.w

	bsr	scrolltext
	move.w	#88,tsin	
	
	move.l	ec1,d0
	addi.l	#24*160,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203
	lsr.l	#8,d0
	move.b	d0,$ffff8201
	
	movem.l	(a7)+,a0-a6/d0-d7
	
	rte
	
vbl:
	movem.l	a0-a6/d0-d7,-(a7)
	
	move.l	#boule,curboule
	move.w	#1,tvbl
	
	move.l	ty,d7
	move.w	d7,d6
	neg.w	d6
	addi.w	#229-20,d6
	move.b	d6,tty 

	clr.b	$fffffa1b.w
	move.l	#starthbl,$120.w
	move.b	d7,$fffffa21.w
	move.b	#8,$fffffa1b.w
	lea	rdegr,a4
	
	move.l	logo+4+8,$ffff8248.w
	move.l	logo+4+12,$ffff824c.w
	
	move.l	#$334,$ffff8240.w
	move.l	#$6670667,$ffff8244.w
	
	move.w	#$000,$ffff8240.w
	bsr	effsprites
	rept	363+128*3
	nop
	endr
	move.b	#0,$ffff820a.w
	rept	16
	nop
	endr
	move.b	#2,$ffff820a.w
	move.w	#$000,$ffff8240.w
	bsr	affplot
	bsr	scrolltext
	bsr	sprites
	
	move.l	ec1,a0
	move.l	ec2,ec1
	move.l	a0,ec2
	
	move.l	ec2,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203
	lsr.l	#8,d0
	move.b	d0,$ffff8201
	
	bsr	player+8
	
	movem.l	(a7)+,a0-a6/d0-d7
	
	rte
	
vbl_orig jmp	$0

decspr:
	move.w	#8,d7
decspr1:
	move.w	#15,d0
decspr2:
	move.l	a6,a0
	move.w	#31,d1
decspr3:
N	set	0
	rept	2
	
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	move.w	N(a0),d2
	lsl.l	d0,d2
	move.w	N+8(a0),d3
	lsl.l	d0,d3
	swap	d3
	or.w	d3,d2
	swap	d3
	swap	d2
	move.w	d2,6+N(a1)
	swap	d2
	move.w	d2,10+N(a1)
	move.w	d3,14+N(a1)
	
N	set	n+2
	endr
	
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	move.w	N(a0),d2
	lsl.l	d0,d2
	move.w	N+8(a0),d3
	lsl.l	d0,d3
	swap	d3
	or.w	d3,d2
	swap	d3
	swap	d2
	move.w	d2,d4
	swap	d2
	move.w	d3,d5
	
	move.w	6(a1),d3
	or.w	8(a1),d3
	or.w	d4,d3
	move.w	d3,(a1)
	
	move.w	10(a1),d3
	or.w	12(a1),d3
	or.w	d2,d3
	move.w	d3,2(a1)

	move.w	14(a1),d3
	or.w	16(a1),d3
	move.w	d5,4(a1)
	
	lea	160(a0),a0
	lea	18(a1),a1
	
	dbra	d1,decspr3
	
	dbra	d0,decspr2

	lea	16(a6),a6
	dbra	d7,decspr1
	
	rts
	
affspr:
	move.l	a0,-(a7)
	move.l	ec1,a0
	lea	mul160,a2
	lea	muldec,a3
	
	move.w	d0,d2
	asr.w	#4,d0
	asl.w	#3,d0
	lea	(a0,d0.w),a0
	andi.w	#$f,d2
	lsl.w	#2,d2
	move.l	(a3,d2.w),d2
	adda.l	d2,a1
	lsl.w	#2,d1
	move.l	(a2,d1.w),d1
	adda.l	d1,a0
	move.l	a0,a2
	
N	set	0
	rept	32
	
	movem.w	(a1)+,d0-d2
	or.w	d0,N+4(a0)
	not.w	d0
	and.w	d0,N(a0)
	and.w	d0,N+2(a0)

	or.w	d1,N+4+8(a0)
	not.w	d1
	and.w	d1,N+8(a0)
	and.w	d1,N+2+8(a0)
	
	or.w	d2,N+4+16(a0)
	not.w	d2
	and.w	d2,N+16(a0)
	and.w	d2,N+2+16(a0)

	movem.l	(a1)+,d0-d2	
	or.l	d0,N(a0)
	or.l	d1,N+8(a0)
	or.l	d2,N+16(a0)
	
N	set	N+160
	endr

	move.l	(a7)+,a0
	rts
	
effsprites:
	move.l	opos1,a0
	move.l	opos2,opos1
	move.l	a0,opos2
	
	move.l	opos1,a0
	move.w	#NSPR-1,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
loopeffspr:
	move.l	(a0)+,a1
N	set	0
	rept	32
	movem.l	d1-d6,N(a1)
N	set	N+160
	endr

	dbra	d0,loopeffspr
	
	rts

sprites:
	move.l	cvxyz,a0
	move.w	ctime,d0
	subq.w	#1,d0
	tst.w	d0
	bgt	oktime
	addq.l	#8,a0
	move.w	6(a0),d0
	tst.w	d0
	bgt	oktime
	lea	vxyz,a0
	move.w	6(a0),d0
oktime:
	move.l	a0,cvxyz
	move.w	d0,ctime

	move.l	opos1,a6
	
	lea	sinus2,a5
	move.w	cx,d6
	add.w	(a0),d6
	cmpi.w	#360,d6
	blt	okcx
	subi.w	#360,d6
okcx:
	move.w	d6,cx
	
	move.w	cy,d7
	add.w	2(a0),d7
	cmpi.w	#360,d7
	blt	okcy
	subi.w	#360,d7
okcy:
	move.w	d7,cy

	move.w	cz,d4
	add.w	4(a0),d4
	cmpi.w	#360,d4
	blt	okcz
	subi.w	#360,d4
okcz:
	move.w	d4,cz
	
	lsl.w	#1,d6
	lsl.w	#1,d7
	lsl.w	#1,d4
	
	move.l	cxyz,a3
	addq.l	#6,a3
	cmpa.l	#txyz+NTIME*6,a3
	blt	oktxyz
	lea	-NTIME*6(a3),a3
oktxyz:
	move.l	a3,cxyz
	
	move.w	(a5,d6.w),d0
	move.w	(a5,d7.w),d1
	move.w	(a5,d4.w),d2
	muls	#140,d0
	asr.l	#8,d0
	asr.l	#6,d0
	muls	#65,d1
	asr.l	#8,d1
	asr.l	#6,d1
	
	move.w	d2,d3
	muls	#DISTSCR-101,d2
	asr.l	#8,d2
	asr.l	#6,d2
	addi.w	#DISTSCR,d2
	
	ext.l	d0
	ext.l	d1
	muls	#100,d0
	divs	d2,d0
	muls	#130,d1
	divs	d2,d1
	
	addi.w	#160-32/2,d0
	addi.w	#CENTRE-32/2,d1
	
	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d3,(a3)+
	
	move.w	#NSPR-1,d5
	lea	sprxy,a0
	
loopcalcspr:
	cmpa.l	#txyz+NTIME*6,a3
	blt	oktxyz2
	lea	-NTIME*6(a3),a3
oktxyz2:

	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a3)+,d3
	
	move.w	d3,8(a0)

	muls	#4,d3
	asr.l	#6,d3
	asr.l	#8,d3
	muls	#18*32*16,d3
	
	addi.l	#18*32*16*4,d3

	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.l	d3,(a0)+
	lea	2(a0),a0
	
	lea	DTIME*6(a3),a3
	
	dbra	d5,loopcalcspr
	
	lea	sprxy,a1
	move.w	#NSPR-2,d1	; Triage des boules --->
triobj1:
	move.w	d1,d2
	lea	10(a1),a3
	move.w	8(a1),d3	; On r‚cupere la distance Z
triobj2:
	cmp.w	8(a3),d3	; On compare les distances 1 et 2
	bgt	noswapobj
	move.l	(a1),d4
	move.l	(a3),(a1)
	move.l	d4,(a3)
	
	move.l	4(a1),d4
	move.l	4(a3),4(a1)
	move.l	d4,4(a3)
	
	move.w	8(a3),8(a1)
	move.w	d3,8(a3)
	move.w	8(a1),d3

noswapobj:
	lea	10(a3),a3
	dbra	d2,triobj2

	lea	10(a1),a1
	dbra	d1,triobj1

	
	move.w	#NSPR-1,d5
	lea	sprxy,a0
	move.l	ec1,a2

loopaffspr:
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.l	(a0)+,d2
	lea	2(a0),a0
	tst.w	d0
	blt	nospr2
	move.l	curboule,a1
	adda.l	d2,a1
	bsr	affspr
nospr:
	move.l	a2,(a6)+
	
	dbra	d5,loopaffspr
	
	rts
	
nospr2:
	move.w	#750,d4
wait:
	dbra	d4,wait

	bra	nospr
	
	section	data
	
null	ds.w	16

cposxy:
	dc.l	posxy
	
player:
	incbin	\etoiles.ovr\astaroth.b
iposxy:
	incbin	\etoiles.ovr\posxy2
sinus2:
	incbin	\etoiles.ovr\sinus2
sinus3:
	incbin	\etoiles.ovr\sinus3
font:
	incbin	\etoiles.ovr\font
degr:
	incbin	\etoiles.ovr\degr.pal
fdegr:

fontd:
logo:
	incbin	\etoiles.ovr\logo.neo

dtext:
	dc.b	"          "
	dc.b	"The crazy star demo??     But where are the stars?"
	dc.b	"                   "
text:
	incbin	\etoiles.ovr\texte.s
ftext:
	even

ctext	dc.l	dtext
cdec	dc.w	0
tlet
	rept	11
	dc.l	fontd+36
	endr
cplt	dc.w	$122,$244,$244,$677,$677,$677,$677

N	set	0
mul160:
	rept	300
	dc.l	N
N	set	N+160
	endr
	
N	set	0
muldec:
	rept	16
	dc.l	N
N	set	N+18*32
	endr
opos1:	dc.l	oldpos
opos2:	dc.l	oldpos+NSPR*4

ctime	dc.w	0
cvxyz:	dc.l	vxyz-8
vxyz:
	dc.w	4,3,3,180
	dc.w	5,3,5,180
	dc.w	0,0,36,10
	dc.w	360-6,10,360-6,180
	dc.w	360-6,10,360-12,180
	dc.w	360-4,15,360-4,180
	dc.w	0,0,36,10
	dc.w	6,20,46,180
	dc.w	0,0,36,10
	dc.w	4,8,4,180
	dc.w	3,2,10,180
	dc.w	-1,-1,-1,-1
	
cx	dc.w	90
cy	dc.w	90
cz	dc.w	0

cxyz	dc.l	txyz
txyz	dcb.w	3*NTIME,-1

tsin	dc.w	88

	section	bss
oldrez	ds.w	1
ec1	ds.l	1
ec2	ds.l	1
oldec	ds.l	1
posxy:
	ds.l	NPLT*NPOS
fposxy:

boule	ds.b	32*6*3*16*9
oldpos	ds.l	NSPR*2
sprxy	ds.b	NSPR*10
oad1	ds.l	1
oad2	ds.l	1
ty	ds.l	1
tvbl	ds.w	1
curboule	ds.l	1
tty	ds.w	1
	ds.b	256
ecran	ds.b	46080*2
rdegr	ds.l	19
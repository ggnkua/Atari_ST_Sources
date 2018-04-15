* Braindamage leftouts vol 1
* Wirevector
* Lame coding and doesn't look good so it was kicked out from Braindamage
* during the last week before release. It has powerful realtime maths,
* quite fast horizontal line routine and hidden surfaces... but who really
* cares. Coded by Xenit, additional coding by Rene (ex 7th Son), background
* ball by Owl...
* Press HELP to exit...

	opt	o+,a+

screen	=$a0000				Address for screens
Obsto	=$1000
Obsto2	=Obsto+56*4

	pea	main(pc)
	move.w	#$26,-(sp)
	trap	#14
	move.w	#$4c,(sp)
	trap	#1
mfp1	dc.l	0
mfp2	dc.l	0
vb	dc.l	0

main	move.w	#$2700,sr

	lea	screen.l,a0
	move.w	#256*256*2/4-1,d0
	moveq	#0,d1
hyu	move.l	d1,(a0)+
	dbra	d0,hyu

	lea	Obsto.w,a0
	lea	Stosave(pc),a1
	move.w	#8*7*2+104*3-1,d0
vf	move.w	(a0)+,(a1)+
	dbra	d0,vf

	lea	Viiva_lista(pc),a0
	lea	Obsto2.w,a1
	move.w	#104*3-1,d0
coppa	move.w	(a0)+,(a1)+
	dbra	d0,coppa

	movem.l	revp(pc),d0-7
	movem.l	d0-7,$ffff8240.w

	lea	reva,a0
	lea	screen+$1c00.l,a1
	lea	screen+$1c00+65536.l,a2

	move.w	#197,d2
kilo	moveq	#39,d1
alko	move.l	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbra	d1,alko
	lea	96(a1),a1
	lea	96(a2),a2
	dbra	d2,kilo

	sf	$fffff820f.w
	move.l	usp,a0
	pea	(a0)
	move.l	sp,stack
	move.l	$70.w,vb
	move.l	$fffffa06.w,mfp1
	move.l	$fffffa12.w,mfp2
	clr.l	$fffffa06.w
	clr.l	$fffffa12.w
	move.l	#vbi,$70.w
	move.l	zcreen(pc),$ffff8200.w
	bsr	bnb

	bsr	Create_SCtable
	lea	Testi_objekti(pc),a0
	bsr	Init_obj

	move.w	#$2300,sr
	stop	#$2300
	sf	$ffff8260.w
	move.b	#48,$ffff820f.w
	move.b	#$1c,$ffff8203.w

	sf	vsync
dad	tst.b	vsync
	beq.s	dad
	sf	vsync

	move.w	zcreen,$ffff8204.w
	eor.w	#1,zcreen

	lea	$ffff8a28.w,a0
	moveq	#-1,d0
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	move.l	#$80088+8*2,(a0)+
	move.w	zcreen(pc),(a0)+
	move.w	#8+6+$1c00,(a0)+
	move.l	#$e00c8,(a0)+
	move.l	#$c000,(a0)

	bsr	rt
	bsr	surfaa
	bsr	LineSetups
	bsr	line
	bra.s	dad

quit	move.w	#$2700,sr

	lea	Stosave(pc),a0
	lea	Obsto.w,a1
	move.w	#8*7*2+104*3-1,d0
vf2	move.w	(a0)+,(a1)+
	dbra	d0,vf2

	st	$ffff8240.w
	sf	$ffff8246.w
	move.l	stack(pc),sp
	sf	$ffff820f.w
	move.l	vb(pc),$70.w
	move.l	mfp1(pc),$fffffa06.w
	move.l	mfp2(pc),$fffffa12.w
	move.l	(sp)+,a0
	move.l	a0,usp
	move.w	#$2300,sr
	rts
stack	dc.l	0

vbi	cmp.b	#$62,$fffffc02.w
	bne.s	noret
	move.l	#quit,2(sp)
noret	dcb.w	4*64,$8080
	st	vsync
	rte
vsync	dc.w	0

LineSetups
	lea	$ffff8a28.w,a5
	lea	$ffff8a2a.w,a0
	move.w	#-1,(a0)+
	move.w	#8,2(a0)
	lea	$ffff8a32.w,a6
	move.w	zcreen(pc),(a6)+
	move.l	a6,usp
	lea	$ffff8a3a.w,a6
	move.w	#$f,(a6)+
	move.w	#$f000,d5
	moveq	#-1,d7
	rts

bnb	lea	kerro(pc),a0
	moveq	#-1,d2
	move.w	d2,(a0)+
	clr.w	d2
	swap	d2
	moveq	#2,d0
	move.w	#198,d3
Divide	move.l	d2,d1
	divu	d0,d1
	move.w	d1,(a0)+
	addq.w	#1,d0
	dbra	d3,Divide

	lea	screen+160.l,a0
	lea	screen+160+65536.l,a3
	lea	rout(pc),a1
	move.w	#255,d1
jkasd	lea	(a3),a4
	lea	(a0),a2
gol	move.w	(a1)+,d0
	move.w	d0,(a2)+
	move.w	d0,(a4)+
	cmp.w	#$4ed2,d0
	bne.s	gol
	lea	$2c(a0),a2
	lea	$2c(a3),a4
gol4	move.w	(a1)+,d0
	move.w	d0,(a2)+
	move.w	d0,(a4)+
	cmp.w	#$4e75,d0
	bne.s	gol4
	lea	256(a0),a0
	lea	256(a3),a3
	dbra	d1,jkasd

	lea	$b0000.l,a0

	move.w	#$43e9,d1
	move.w	#$200,d2
	move.w	#65536/2-1,d0
copye	cmp.w	(a0)+,d1
	bne.s	erwe
	sub.w	d2,(a0)
erwe	dbra	d0,copye
	rts

zcreen	dc.l	$a0000
XXF	SET	1

quqqo	MACRO
	lea	Obsto2+XXF.w,a1
	tas	(a1)+
	bne.s	\@1
	move.w	(a1)+,a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a1)+,a2
	move.w	(a2)+,d2
	move.w	(a2)+,d4
	bsr	drawqq
\@1
	ENDM

line	REPT	104
	quqqo
XXF	SET	XXF+6
	ENDR
	rts

drawqq	cmp.w	d0,d2
	bge.s	X2plus
	exg	d0,d2
	exg	d1,d4
X2plus	sub.w	d0,d2

	move.w	#256,d6
	move.w	d0,d3
	moveq	#$a,d0
	sub.w	d1,d4
	bpl.s	Y2plus
	neg.w	d6
	neg.w	d4
	moveq	#$b,d0
Y2plus
	cmp.w	d4,d2
	ble	Pystyyn

	swap	d0
	move.b	d3,-(sp)
	move.w	(sp)+,d0

	lea	endt(pc),a4
	sub.w	d4,a4

	add.w	d4,d4
	lea	kerro(pc),a1
	move.w	0(a1,d4.w),d4
	move.b	d2,-(sp)
	mulu	(sp)+,d4
	swap	d4

	lea	zcreen(pc),a1
	move.b	d1,2(a1)
	move.l	(a1),a1

	add.w	d3,d3
	add.w	d3,d3
	lea	reuna(pc,d3.w),a2
	move.w	(a2)+,d6
	add.w	(a2)+,a1

	move.w	d0,d1
	and.w	d5,d0
	neg.w	d0

	moveq	#$ffffffc0,d2

	add.w	d4,d1
	add.w	d1,d0
	move.b	(a4)+,d0
	move.l	d0,a2
	move.w	d1,d0
	and.w	d5,d0
	neg.w	d0
	jmp	(a2)		8	56

Q	SET	6
reuna	REPT	16
	dc.w	$7fff,Q,$3fff,Q,$1fff,Q
	dc.w	$fff,Q,$7ff,Q,$3ff,Q,$1ff,Q
	dc.w	$ff,Q,$7f,Q,$3f,Q,$1f,Q
	dc.w	$f,Q,7,Q,3,Q,1,Q,0,Q
Q	SET	Q+8
	ENDR

	dc.w	-1
kerro	ds.w	200

	dcb.w	100,$a0a0
endt	dc.w	$cc00

Pystyyn	move.w	d6,$ffff8a30.w
	lea	ByteTabPlane1(pc),a4
	lea	256(a4),a1
	add.w	d3,a4
	add.w	d3,d3
	add.w	d3,a1

	add.w	d2,d2
	lea	kerro(pc),a2
	addq.w	#1,d4
	mulu	(a2,d2.w),d4
	add.w	d2,d2

	move.l	usp,a2
	move.b	d1,-(sp)
	move.w	(sp)+,(a2)

	move.w	d4,d1
	swap	d4
	tst.w	d4
	bgt.s	Huh
	moveq	#1,d4
	moveq	#0,d1
Huh
	moveq	#1,d0
	lea	$ffff8a36.w,a3
	move.w	d0,(a3)+

	moveq	#-1,d3

	moveq	#$ffffffc0,d6
	jmp	nolo(pc,d2.w)

nolo
polo	SET	-18
	REPT	199
	bra.w	QuaylE+polo
polo	SET	polo-18
	ENDR

	REPT	200
	clr.w	d0
	add.w	d1,d3
	addx.w	d4,d0
	move.w	d0,(a3)
	move.w	(a2),d0
	move.b	(a4)+,d0
	move.w	d0,(a2)
	move.w	(a1)+,(a5)
	move.b	d6,(a6)
	ENDR
QuaylE	rts

ByteTabPlane1
HYT	SET	6
	REPT	16
	dcb.b	16,HYT
HYT	SET	HYT+$8
	ENDR

	REPT	16
	dc.w	$8000,$4000,$2000,$1000
	dc.w	$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010
	dc.w	$0008,$0004,$0002,$0001
	ENDR


Zoom	=500
Dee	=485
Zoom2	=1350

xtab	=0+33*12
ytab	=6+33*12
ztab	=65*12+33*6


rt	lea	x(pc),a0
	movem.w	(a0),d0-2
	addq	#8,(a0)+
	addq	#6,(a0)+
	addq	#2,(a0)+

	bsr.s	Matrics
	bsr	B65
	bra.s	Calc

x	dc.w	0,0,0

matrix	ds.w	9

Calc	lea	BBB,a0
	lea	Perspektiivi+Zoom,a2
	lea	Obsto.w,a3
	moveq	#-128,d4
	moveq	#-2,d7
	bra	Rout

Matrics	lea	Sin,a0
	lea	Cos,a1
	move.w	#(prd*4-1)*2,d3
	and.w	d3,d0
	and.w	d3,d1
	and.w	d3,d2
	move.w	d2,d6

	move.w	(a0,d0),d2
	move.w	(a1,d0),d3
	move.w	(a0,d1),d0
	move.w	(a1,d1),d1
	move.w	(a0,d6),d4
	move.w	(a1,d6),d5

	lea	matrix,a0
	move.w  d5,d6		* cos z 	> d6
	move.w  d4,d7		* sin z 	> d7
	muls    d3,d6		* cos x * cos z > d6
	muls    d3,d7		* cos x * sin z > d7
	lsr.l   #8,d6
	lsr.l   #8,d7

	move.w	d6,(a0)		* cosx*cosz > r1 
	move.w	d7,2(a0)	* cos x * sin z	> r2
	move.w	d2,4(a0)	* sin x        	> r3

	move.w  d0,d6		sin y 	> d6
	move.w  d1,d7		cos y	> d7
	muls    d2,d6		sin x * sin y > d6
	muls    d2,d7		sin x * cos y > d7
	lsr.l   #8,d6
	lsr.l   #8,d7

	move.w  d6,a2		sin x * sin y 	> a0
	move.w  d7,a1		sin x * cos y 	> a1
	muls    d5,d6		sin x * sin y * cos z > d6 
	muls    d5,d7		sin x * cos y * cos z > d7

	lsr.l   #8,d6
	lsr.l   #8,d7

	move.w  d6,6(a0)	sin x * sin y * cos z > rd
	move.w  d7,12(a0)	sin x * cos y * cos z > rg

	exg     a2,d6		;sin x * sin y		> d6	
	exg	a1,d7		sin x * cos y		> d7
	muls    d4,d6		sin x * sin y * sin z > d6
	muls    d4,d7		sin x * cos y * sin z > d7

	lsr.l   #8,d6
	lsr.l   #8,d7
	move.w  d6,8(a0)	sin x * sin y * sin z > re
	move.w  d7,14(a0)	sin x * cos y * sin z > rh

	move.w  d1,d6		cos y		> d6
	move.w  d1,d7		cos y		> d7
	muls    d4,d6		sin z * cos y > d6
	muls    d5,d7		cos z * cos y > d7

	lsr.l   #8,d6
	lsr.l   #8,d7
	sub.w   d6,6(a0)	(sinx * siny * cosz)-(sinz * cosy) > rd
	add.w   d7,8(a0)	(sinx * siny * sinz)+(sinz * cosy) > re

	move.w  d0,d6		sin y 	> d6
	move.w  d1,d7		cos y		> d7
	muls    d3,d6		cos x * sin y > d6
	muls    d3,d7		cos x * cos y > d7
	lsr.l   #8,d6
	lsr.l   #8,d7

	move.w  d6,10(a0)	cos x * sin y > rf
	move.w  d7,16(a0)	cos x * cos y > rg

	move.w  d4,d6		sin z 	> d6 
	move.w  d5,d7		cos z		> d7
	muls    d0,d6		sin y * sin z > d6
	muls    d0,d7		sin y * cos z > d7
	lsr.l   #8,d6
	lsr.l   #8,d7
	add.w   d6,12(a0)	(sinx * cosy * cosz)+(siny * sinz) > rg
	sub.w   d7,14(a0)	(sinx * cosy * sinz)-(siny * cosz) > rh
	rts

x1	=2*0
x2	=2*3
x3	=2*6

y1	=2*1
y2	=2*4
y3	=2*7

z1	=2*2
z2	=2*5
z3	=2*8

B65	lea	matrix,a0

	move.w	x1(a0),d0
	move.w	x2(a0),d1
	move.w	x3(a0),d2
	move.w	y1(a0),d3
	move.w	y2(a0),d4
	move.w	y3(a0),d5

	lea	BBB+6*2*65,a6

	move.w	d0,d7
	move.w	d1,a1
	move.w	d2,a2
	move.w	d3,a3
	move.w	d4,a4
	move.w	d5,a5

	asl.w	#5,d0
	asl.w	#5,d1
	asl.w	#5,d2
	asl.w	#5,d3
	asl.w	#5,d4
	asl.w	#5,d5

	rept	65
	sub.w	d7,d0
	sub.w	a1,d1
	sub.w	a2,d2
	sub.w	a3,d3
	sub.w	a4,d4
	sub.w	a5,d5

	movem.w	d0-d5,-(a6)
	endr

	move.w	z1(a0),d0
	move.w	z2(a0),d1
	move.w	z3(a0),d2

	lea	BBB+6*3*65,a6

	move.w	d0,d7
	move.w	d1,a1
	move.w	d2,a2

	asl.w	#5,d0
	asl.w	#5,d1
	asl.w	#5,d2

	rept	65
	sub.w	d7,d0
	sub.w	a1,d1
	sub.w	a2,d2

	movem.w	d0-d2,-(a6)
	endr

	rts

surfaa	lea	Surfst(pc),a0

	moveq	#8*6+2-3,d7

	moveq	#1,d5
	moveq	#0,d6

qyy	movem.w	(a0)+,a2-4
	move.w	(a2)+,d2
	move.w	(a2),d3
	move.w	(a3)+,d0
	move.w	(a3),d1
	neg.w	d2
	neg.w	d3
	add.w	d2,d0
	add.w	d3,d1
	add.w	(a4)+,d2
	add.w	(a4),d3
	muls	d0,d3
	muls	d1,d2
	sub.l	d2,d3
	bmi.s	asf
	movem.w	(a0)+,a1-4
	move.w	d6,(a1)
	move.w	d6,(a2)
	move.w	d6,(a3)
	move.w	d6,(a4)
	movem.w	(a0)+,a1-4
	move.w	d6,(a1)
	move.w	d6,(a2)
	move.w	d6,(a3)
	move.w	d6,(a4)
	dbf	d5,qyy
	bra.s	surfab

asf	lea	16(a0),a0
	dbf	d5,qyy

surfab	movem.w	(a0)+,a2-4
	move.w	(a2)+,d4
	move.w	(a2),d5
	move.w	(a3)+,d0
	move.w	(a3),d1
	neg.w	d4
	neg.w	d5
	add.w	d4,d0
	add.w	d5,d1
	add.w	(a4)+,d4
	add.w	(a4),d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
	bmi.s	asf2
	movem.w	(a0)+,a1-4
	move.w	d6,(a1)
	move.w	d6,(a2)
	move.w	d6,(a3)
	move.w	d6,(a4)
	dbf	d7,surfab
	rts

asf2	addq.w	#8,a0
	dbf	d7,surfab
	rts



Init_obj
	lea	Palanen(pc),a1
	lea	Rout(pc),a2
	move.w	(a0)+,d7
	subq	#1,d7
copy_rout
	move.w	#(Ploppu-Palanen)/2-1,d6
	move.l	a1,a3
	move.l	a2,a4
cr2	move.w	(a3)+,(a2)+
	dbf	d6,cr2

	move.w	(a0)+,d0
	muls.w	#12,d0
	add.w	#xtab,d0
	move.w	d0,2(a4)

	move.w	(a0)+,d0
	muls.w	#12,d0
	add.w	#ytab,d0
	move.w	d0,2+10(a4)

	move.w	(a0)+,d0
	muls.w	#6,d0
	add.w	#ztab,d0
	move.w	d0,2+20(a4)

	dbf	d7,copy_rout
	move.w	#$4e75,(a2)+
	rts

Palanen	lea	-1(a0),a1
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	lea	-1(a0),a1
	add.w	(a1)+,d0
	add.w	(a1)+,d1
	add.w	(a1)+,d2
	lea	-1(a0),a1
	sub.w 	(a1)+,d0
	add.w 	(a1)+,d1
	add.w 	(a1)+,d2	

	asr.w	#5,d2
	and.w	d7,d2

	move.w	(a2,d2),d3
	muls	d3,d0
	muls	d3,d1

	swap	d0
	swap	d1
	
	sub.w	d4,d0
	sub.w	d4,d1
	move.w	d0,(a3)+
	move.w	d1,(a3)+

Ploppu

;-------------------------------
;	SINUS-TABLE
;-------------------------------
							
prd	=256		;t„ysiympyr„=4*prd
pi	=$1921fb54	;pi*2^27
step	=pi/(prd*2)+1

angle	equr	d0
data1	equr	d1
data2	equr	d2
tulos	equr	d3

Create_SCtable

	lea	Sin,a0
	lea	prd*2*2(a0),a1
	move.l	a1,a2
	lea	prd*2*2(a2),a3
	move.l	a3,a4
	moveq	#0,angle
	move.w	#prd-1,d7
jatka
	move.l	angle,data1
	swap	data1
	move.w	data1,tulos
	muls	#6,tulos

	moveq	#2-1,d6
	bsr.s	pot		;x^3
	and.l	#$ffff,data2
	divs	#6/6,data2	;6=3!
	sub.w	data2,tulos

	moveq	#4-1,d6
	bsr.s	pot		;x^5
	and.l	#$ffff,data2
	divs	#120/6,data2	;120=5!
	add.w	data2,tulos

	moveq	#6-1,d6		
	bsr.s	pot		;x^7
	and.l	#$ffff,data2
	divs	#5040/6,data2	;5040=7!
	sub.w	data2,tulos
	addq.w	#1,tulos
	divs	#6,tulos
		
	asr.w	#3,tulos
	move.w	tulos,(a4)+
	move.w	tulos,(a0)+
	move.w	tulos,-(a1)
	neg	tulos
	move.w	tulos,(a2)+
	move.w	tulos,-(a3)
	add.l	#step,angle
	dbf	d7,jatka	

	rts

pot	move.w	data1,data2
	
py”r	mulu	data1,data2
	asr.l	#8,data2
	asr.l	#3,data2
	dbf	d6,py”r
	rts

	DATA

Perspektiivi
	dc.w	Zoom2
co	set	1+Dee
	rept	1000-Dee
	dc.w	(1000*Zoom2*Dee)/co/1000
co	set	co+1
	endr

Stosave	ds.w	8*7*2+104*3

Testi_objekti 
	dc.w	8*7

kierre	macro
	dc.w	+32*es/32,+00*es/32,se
	dc.w	+23*es/32,+23*es/32,se
	dc.w	0*es/32,+32*es/32,se
	dc.w	-23*es/32,+23*es/32,se
	dc.w	-32*es/32,0*es/32,se
	dc.w	-23*es/32,-23*es/32,se
	dc.w	0*es/32,-32*es/32,se
	dc.w	+23*es/32,-23*es/32,se
	endm

se	set	30
es	set	7
	kierre

se	set	24
es	set	19
	kierre

se	set	13
es	set	28
	kierre

se	set	0
es	set	31
	kierre

se	set	-13
es	set	28
	kierre

se	set	-24
es	set	19
	kierre

se	set	-30
es	set	7
	kierre

Surfst
a	set	0
b	set	8
c	set	8*7

	dc.w	1*4+Obsto-4,6*4+Obsto-4,3*4+Obsto-4,1*6-6+Obsto2,2*6-6+Obsto2,3*6-6+Obsto2,4*6-6+Obsto2,5*6-6+Obsto2,6*6-6+Obsto2,7*6-6+Obsto2,8*6-6+Obsto2
	dc.w	49*4+Obsto-4,51*4+Obsto-4,53*4+Obsto-4,49*6-6+Obsto2,50*6-6+Obsto2,51*6-6+Obsto2,52*6-6+Obsto2,53*6-6+Obsto2,54*6-6+Obsto2,55*6-6+Obsto2,56*6-6+Obsto2

	dc.w	(b+2)*4+Obsto-4,(b+1)*4+Obsto-4,(a+1)*4+Obsto-4,(a+1)*6-6+Obsto2,(b+1)*6-6+Obsto2,(c+1)*6-6+Obsto2,(c+2)*6-6+Obsto2
	dc.w	(b+3)*4+Obsto-4,(b+2)*4+Obsto-4,(a+2)*4+Obsto-4,(a+2)*6-6+Obsto2,(b+2)*6-6+Obsto2,(c+2)*6-6+Obsto2,(c+3)*6-6+Obsto2
	dc.w	(b+4)*4+Obsto-4,(b+3)*4+Obsto-4,(a+3)*4+Obsto-4,(a+3)*6-6+Obsto2,(b+3)*6-6+Obsto2,(c+3)*6-6+Obsto2,(c+4)*6-6+Obsto2
	dc.w	(b+5)*4+Obsto-4,(b+4)*4+Obsto-4,(a+4)*4+Obsto-4,(a+4)*6-6+Obsto2,(b+4)*6-6+Obsto2,(c+4)*6-6+Obsto2,(c+5)*6-6+Obsto2
	dc.w	(b+6)*4+Obsto-4,(b+5)*4+Obsto-4,(a+5)*4+Obsto-4,(a+5)*6-6+Obsto2,(b+5)*6-6+Obsto2,(c+5)*6-6+Obsto2,(c+6)*6-6+Obsto2
	dc.w	(b+7)*4+Obsto-4,(b+6)*4+Obsto-4,(a+6)*4+Obsto-4,(a+6)*6-6+Obsto2,(b+6)*6-6+Obsto2,(c+6)*6-6+Obsto2,(c+7)*6-6+Obsto2
	dc.w	(b+8)*4+Obsto-4,(b+7)*4+Obsto-4,(a+7)*4+Obsto-4,(a+7)*6-6+Obsto2,(b+7)*6-6+Obsto2,(c+7)*6-6+Obsto2,(c+8)*6-6+Obsto2
	dc.w	(b+1)*4+Obsto-4,(b+8)*4+Obsto-4,(a+8)*4+Obsto-4,(a+8)*6-6+Obsto2,(b+8)*6-6+Obsto2,(c+8)*6-6+Obsto2,(c+1)*6-6+Obsto2

a	set	a+8
b	set	b+8
c	set	c+8

	rept	5

	dc.w	(a+1)*4+Obsto-4,(a+2)*4+Obsto-4,(b+1)*4+Obsto-4,(a+1)*6-6+Obsto2,(b+1)*6-6+Obsto2,(c+1)*6-6+Obsto2,(c+2)*6-6+Obsto2
	dc.w	(a+2)*4+Obsto-4,(a+3)*4+Obsto-4,(b+2)*4+Obsto-4,(a+2)*6-6+Obsto2,(b+2)*6-6+Obsto2,(c+2)*6-6+Obsto2,(c+3)*6-6+Obsto2
	dc.w	(a+3)*4+Obsto-4,(a+4)*4+Obsto-4,(b+3)*4+Obsto-4,(a+3)*6-6+Obsto2,(b+3)*6-6+Obsto2,(c+3)*6-6+Obsto2,(c+4)*6-6+Obsto2
	dc.w	(a+4)*4+Obsto-4,(a+5)*4+Obsto-4,(b+4)*4+Obsto-4,(a+4)*6-6+Obsto2,(b+4)*6-6+Obsto2,(c+4)*6-6+Obsto2,(c+5)*6-6+Obsto2
	dc.w	(a+5)*4+Obsto-4,(a+6)*4+Obsto-4,(b+5)*4+Obsto-4,(a+5)*6-6+Obsto2,(b+5)*6-6+Obsto2,(c+5)*6-6+Obsto2,(c+6)*6-6+Obsto2
	dc.w	(a+6)*4+Obsto-4,(a+7)*4+Obsto-4,(b+6)*4+Obsto-4,(a+6)*6-6+Obsto2,(b+6)*6-6+Obsto2,(c+6)*6-6+Obsto2,(c+7)*6-6+Obsto2
	dc.w	(a+7)*4+Obsto-4,(a+8)*4+Obsto-4,(b+7)*4+Obsto-4,(a+7)*6-6+Obsto2,(b+7)*6-6+Obsto2,(c+7)*6-6+Obsto2,(c+8)*6-6+Obsto2
	dc.w	(a+8)*4+Obsto-4,(a+1)*4+Obsto-4,(b+8)*4+Obsto-4,(a+8)*6-6+Obsto2,(b+8)*6-6+Obsto2,(c+8)*6-6+Obsto2,(c+1)*6-6+Obsto2

a	set	a+8
b	set	b+8
c	set	c+8

	endr


Viiva_lista
a	set	-1
	REPT	7
	dc.w	$0080,(a+1)*4+Obsto,(a+2)*4+Obsto
	dc.w	$0080,(a+2)*4+Obsto,(a+3)*4+Obsto
	dc.w	$0080,(a+3)*4+Obsto,(a+4)*4+Obsto
	dc.w	$0080,(a+4)*4+Obsto,(a+5)*4+Obsto
	dc.w	$0080,(a+5)*4+Obsto,(a+6)*4+Obsto
	dc.w	$0080,(a+6)*4+Obsto,(a+7)*4+Obsto
	dc.w	$0080,(a+7)*4+Obsto,(a+8)*4+Obsto
	dc.w	$0080,(a+8)*4+Obsto,(a+1)*4+Obsto
a	set	a+8
	ENDR

a	set	0-1
b	set	8-1

	REPT	6
	dc.w	$0080,(a+1)*4+Obsto,(b+1)*4+Obsto
	dc.w	$0080,(a+2)*4+Obsto,(b+2)*4+Obsto
	dc.w	$0080,(a+3)*4+Obsto,(b+3)*4+Obsto
	dc.w	$0080,(a+4)*4+Obsto,(b+4)*4+Obsto
	dc.w	$0080,(a+5)*4+Obsto,(b+5)*4+Obsto
	dc.w	$0080,(a+6)*4+Obsto,(b+6)*4+Obsto
	dc.w	$0080,(a+7)*4+Obsto,(b+7)*4+Obsto
	dc.w	$0080,(a+8)*4+Obsto,(b+8)*4+Obsto
a	set	a+8
b	set	b+8
	ENDR

Sin	
Cos	=Sin+prd*2	
BBB	=Sin+prd*2*5
Rout	=BBB+65*9*2

revp	dc.w	$009,$009,$009,$009
	dc.w	$009,$009,$009,$009
	dc.w	$901,$a81,$b11,$c29
	dc.w	$532,$6c3,$edb,$ffd

rout	incbin	fucken.biz
reva	incbin	pallo.bin

	end

    
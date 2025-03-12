*	Mandel Lake

vp	equ	128
vpshift	equ	7

	bsr	setup
	dc.w	$a000
	dc.w	$a00a
	
	bsr	mkplot
	bsr	mandy
sveout	move.w	#8,-(sp)
	trap	#1
	addq.l	#2,sp
	cmp.b	#'s',d0
	beq	save
	cmp.b	#'S',d0
	beq	save
	dc.w	$a009
	bra	retgen
save	move.w	#$0,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst	d0
	bmi	sveout
	move.w	d0,ty
	pea	res
	move.l	#34,-(sp)
	move.w	d0,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	close
	move.l	physic,-(sp)
	move.l	#32000,-(sp)
	move.w	ty,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
close	move.w	ty,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	bra	sveout
		
mandy	bsr	cls
	move.w	#1,y
mandlpy	move.w	ht,d0
	ext.l	d0
	asl.l	#vpshift,d0
	divs.w	y,d0
	sub.w	#vp,d0
	move.w	d0,d
	
	move.w	my,d1
	ext.l	d1
	move.w	sy,d2
	muls.w	d2,d0
	muls.w	#250,d2
	add.l	d2,d1
	sub.l	d0,d1
	cmp.l	#-32768,d1
	ble	offgry
	cmp.l	#32767,d1
	bge	offgry
	move.w	d1,n
	
	move.w	#-160,x
mandlpx	move.w	x,d0
	muls.w	sx,d0
	move.w	d,d1
	add.w	#vp,d1
	muls.w	d1,d0
	*cmp.l	#32767*vp,d0
	*bge	offgrx
	*cmp.l	#-32768*vp,d0
	*ble	offgrx
	divs.w	#vp,d0
	add.w	mx,d0
	move.w	d0,z
	
	move.w	#0,d7
	move.w	#20000,real
	move.w	#16384,imag
	moveq.w	#14,d0
iterlp	move.w	real,d5
	move.w	imag,d6
	move.w	d5,d3
	move.w	d6,d4
	muls.w	d3,d3
	muls.w	d4,d4
	move.l	d4,d2
	add.l	d3,d2
	cmp.l	#4*16384*16384,d2
	bge	iterout
	sub.l	d4,d3
	asr.l	d0,d3
	add.w	z,d3		* d3 is new real
	muls.w	d6,d5
	asr.l	d0,d5
	asl.w	#1,d5
	add.w	n,d5		* d5 is new imag
	move.w	d5,imag
	move.w	d3,real
	addi.w	#1,d7
	cmp.w	maxit,d7
	bne	iterlp
iterout	move.w	d7,d6
	move.w	maxit,d5
	addq.w	#1,d5
	lsr.w	#1,d5
	sub.w	d5,d6
	cmp.w	#0,d6
	bge	okd6
	not.w	d6
	addq.w	#1,d6
okd6	sub.w	d6,d5
	move.w	d5,d6
	mulu.w	htperit,d6
	
	move.w	ht,d5
	sub.w	d6,d5
	mulu.w	#vp,d5
	move.w	d,d4
	add.w	#vp,d4
	divs.w	d4,d5
	move.w	d5,ty
	
	and.w	#15,d7	*get colour!!
	move.w	real,d6
	and.w	#3,d6
	subq.w	#1,d6
	cmp.w	#2,d6
	beq	okd7
	add.w	d6,d7
	cmpi.w	#0,d7
	bgt	okd72
	moveq.w	#1,d7
	bra	okd7
okd72	cmpi.w	#16,d7
	blt	okd7
	moveq.w	#14,d7
okd7	move.w	x,d0
	move.w	ty,d1
	add.w	#160,d0
	add.w	#50,d1
	cmp.w	#200,d1
	bge	plotout
	move.w	y,d3
	add.w	#50,d3
	cmp.w	#200,d3
	blt	oky
	move.w	#199,d3
oky	sub.w	d1,d3
	mulu.w	#160,d1
	move.w	d0,d2
	andi.w	#65535-15,d2
	lsr.w	#1,d2
	add.w	d2,d1
	andi.w	#15,d0
	mulu.w	#12,d0
	movea.l	physic,a0
	lea	(a0,d1.w),a0
	lea	plotdat,a1
	mulu.w	#12*16,d7
	add.w	d0,d7
	lea	(a1,d7.w),a1
	move.l	(a1)+,d0
	move.l	(a1)+,d1
	move.l	(a1)+,d2
linelp	and.l	d0,(a0)
	and.l	d0,4(a0)
	or.l	d1,(a0)+
	or.l	d2,(a0)+
	lea	152(a0),a0
	dbra.w	d3,linelp
plotout	
offgrx
	add.w	#1,x
	cmp.w	#160,x
	blt	mandlpx
offgry	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	cmp.b	#' ',d0
	beq	mandout
	add.w	#1,y
	cmp.w	#170,y
	bne	mandlpy
mandout	rts
mkplot	lea	plotdat,a0
	moveq.w	#0,d7
collp	move.w	#15,d0
	move.w	#32768,d1
	move.l	#$ffff7fff,d2
mplp	move.w	d2,(a0)+
	move.w	d2,(a0)+
	move.l	#0,(a0)
	move.l	#0,4(a0)
	btst	#0,d7
	beq	nopl1
	move.w	d1,(a0)
nopl1	btst	#1,d7
	beq	nopl2
	move.w	d1,2(a0)
nopl2	btst	#2,d7
	beq	nopl3
	move.w	d1,4(a0)
nopl3	btst	#3,d7
	beq	nopl4
	move.w	d1,6(a0)
nopl4	addq.l	#8,a0
	ror.w	#1,d1
	ror.l	#1,d2
	dbra.w	d0,mplp
	add.w	#1,d7
	cmp.w	#16,d7
	bne	collp
	rts
	
cls	movea.l	physic,a0
	move.w	#8000-1,d0
clslp	move.l	#$ffffffff,(a0)+
	dbra.w	d0,clslp
	rts
setup	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	$484,oldkey
	move.w	#0,$484
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldres
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	cmp.l	#$78000,d0
	bgt	moremeg
	move.l	#$78000,d0
moremeg	move.l	d0,physic
	move.w	#0,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,oldpal
	pea	palette
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
retgen	move.w	oldkey,$484
	move.w	oldres,-(sp)
	move.l	physic,-(sp)
	move.l	physic,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	pea	oldpal
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	clr.w	-(sp)
	trap	#1

res	dc.w	0
palette	dc.w	$000,$030,$040,$050
	dc.w	$111,$222,$333,$444
	dc.w	$555,$666,$777,$666
	dc.w	$555,$444,$044,$055
		
physic	dc.l	0
oldres	dc.w	0
oldkey	dc.w	0
oldpal	ds.l	8

d	dc.w	0
real	dc.w	0
imag	dc.w	0
n	dc.w	0
z	dc.w	0
x	dc.w	0
y	dc.w	0
ty	dc.w	0
sx	dc.w	20
sy	dc.w	20
mx	dc.w	-1000
my	dc.w	13000
ht	dc.w	150
maxit	dc.w	15
htperit	dc.w	2

plotdat	ds.l	3*16*16
filename	dc.b	"c:\pictures\piccies\julialk1.pi1",0

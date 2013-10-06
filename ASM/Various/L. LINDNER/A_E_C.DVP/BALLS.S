ballnum:	equ	12

s:	bra	start

nocursor:
	move.l	scrtab,a6
	move.l	scrtab+4,a5
	lea	1126(a6),a6
	lea	1126(a5),a5
	moveq	#19,d7
.0	clr	(a6)
	clr	(a5)
	clr	1440(a6)
	clr	2880(a6)
	clr	1440(a5)
	clr	2880(a5)
	addq	#8,a5
	addq	#8,a6
	dbra	d7,.0
	rts

showcursor:
	lea	para,a0
	move	curpos,d6
	move	0(a0,d6.w),d7
	move	18(a0,d6.w),d0
	add	#1120,d0
	move	36(a0,d6.w),d1
	move.l	scrtab,a6
	move.l	scrtab+4,a5
	add	d0,a5
	add	d0,a6
	moveq	#-1,d0
.0	move.b	d0,(a5)
	move.b	d0,(a6)
	add	d1,a6
	add	d1,a5
	eor	#6,d1
	dbra	d7,.0
	rts

outnum:	
	tst	parabit
	beq	.99
	moveq	#0,d7
	move	parabit,d6
.0	btst.l	d7,d6
	bne	.1
	addq	#1,d7
	cmp	#9,d7
	bne	.0
.99	rts
.1	bclr.l	d7,d6
	move	d6,parabit
	add	d7,d7
	lea	para,a1
	lea	number,a0
	lea	xs,a2
	moveq	#' ',d6
	move	54(a1,d7.w),d4
	moveq	#0,d5
	move	0(a2,d4.w),d5
	tst	d5
	bpl	.2
	neg	d5
	moveq	#'-',d6
.2	move	18(a1,d7.w),d0
	move	36(a1,d7.w),d1
	moveq	#0,d4
	divu	#1000,d5
	or	#$30,d5
	move.b	d5,1(a0)
	move	d4,d5
	swap	d5
	divu	#100,d5
	or	#$30,d5
	move.b	d5,2(a0)
	move	d4,d5
	swap	d5
	divu	#10,d5
	or	#$30,d5
	move.b	d5,3(a0)
	move	d4,d5
	swap	d5
	or	#$30,d5
	move.b	d5,4(a0)
	move	0(a1,d7.w),d7
	moveq	#4,d5
	sub	d7,d5
	add	d5,a0
	move.b	d6,(a0)
	bra	settxt

setheader:
	moveq	#39,d7
	moveq	#6,d0
	moveq	#1,d1
	lea	header1,a0
	bsr	settxt
	moveq	#39,d7
	move	#9*160+6,d0
	moveq	#1,d1
	lea	header2,a0
	bsr	settxt
	moveq	#39,d7
	move	#18*160+6,d0
	moveq	#1,d1
	lea	header3,a0
	bsr	settxt
	rts

settxt:	move.l	scrtab,a6
	move.l	scrtab+4,a5
	add	d0,a6
	add	d0,a5
.0	lea	font,a1
	moveq	#0,d0
	move.b	(a0)+,d0
	sub	#32,d0
	asl	#3,d0
	add	d0,a1
	move.b	(a1),(a6)
	move.b	(a1)+,(a5)
	move.b	(a1),160(a6)
	move.b	(a1)+,160(a5)
	move.b	(a1),320(a6)
	move.b	(a1)+,320(a5)
	move.b	(a1),480(a6)
	move.b	(a1)+,480(a5)
	move.b	(a1),640(a6)
	move.b	(a1)+,640(a5)
	move.b	(a1),800(a6)
	move.b	(a1)+,800(a5)
	move.b	(a1),960(a6)
	move.b	(a1)+,960(a5)
	add	d1,a5
	add	d1,a6
	eor	#6,d1
	dbra	d7,.0
	rts

sortiere:
	moveq	#ballnum-2,d0
	move	d0,d1
.0	lea	bdata,a0
	moveq	#0,d7
	move	d1,d0
.1	move	(a0),d2
	cmp	8(a0),d2	
	bgt	.2
	movem.l	(a0),d2-d3
	move.l	8(a0),(a0)
	move.l	12(a0),4(a0)
	movem.l	d2-d3,8(a0)
	moveq	#1,d7
.2	addq	#8,a0
	dbra	d0,.1
	subq	#1,d1
	beq	.3
	tst	d7
	bne	.0
.3	rts

loeschen:
	move.l	clrtab,a0
	moveq	#0,d0
	moveq	#ballnum-1,d7
.0	move.l	(a0)+,a6
	moveq	#15,d6
.1	move.l	d0,(a6)
	move.l	d0,8(a6)
	move	d0,4(a6)
	move	d0,12(a6)
	lea	160(a6),a6
	dbra	d6,.1
	dbra	d7,.0
	rts	

ausgabe:
	lea	pixoff,a0
	lea	lineadr,a1
	lea	balladr,a2
	lea	bdata,a3
	move.l	clrtab,a4
	moveq	#ballnum-1,d6
.0	move	2(a3),d2
	move	4(a3),d0
	move	6(a3),d1
	bsr	sprite
	addq	#8,a3
	dbra	d6,.0
	rts

berechne:
	lea	bdata,a0
	lea	sinus,a1
	lea	xs,a6
	move	#$7ff,d6
	move	#$800,d5
	move.l	(a6),18(a6)
	move	4(a6),22(a6)
	movem	18(a6),d0-d2
	moveq	#ballnum-1,d7
.0	tst	d0
	bpl	.1
	add	d5,d0
.1	and	d6,d0
	tst	d1
	bpl	.2
	add	d5,d1
.2	and	d6,d1
	tst	d2
	bpl	.3
	add	d5,d2
.3	and	d6,d2
	movem	d0-d2,18(a6)
	add	d0,d0
	add	d1,d1
	add	d2,d2
	move	0(a1,d0.w),d0
	move	0(a1,d1.w),d1
	move	0(a1,d2.w),d2
	add	#347,d2
	move	d2,(a0)+			;z-koordinate
	move	d2,d3
	lsr	d2
	sub	#219,d3
	asl	#4,d3
	and	#$ff00,d3
	move	d3,(a0)+			;Gr”že
	muls	#130,d0
	divs	d2,d0
	add	#152,d0
	move	d0,(a0)+			;x-koordinate
	muls	#79,d1
	divs	d2,d1
	add	#92,d1
	move	d1,(a0)+			;y-koordinate
	movem	18(a6),d0-d2
	add	6(a6),d0
	add	8(a6),d1
	add	10(a6),d2
	dbra	d7,.0
	movem	(a6),d0-d2
	add	12(a6),d0
	add	14(a6),d1
	add	16(a6),d2
	movem	d0-d2,(a6)
	rts

sprite:	moveq	#15,d7
	move	d0,d3
	and	#$f,d3
	add	d3,d3
	add	d3,d3
	move.l	0(a2,d3.w),a5
	add	d2,a5
	move.l	scrtab,a6
	add	d0,d0
	add	d1,d1
	add	0(a0,d0.w),a6
	add	0(a1,d1.w),a6
	move.l	a6,(a4)+
.0	movem.l	(a5)+,d0-d3
	and	d1,(a6)
	and	d1,2(a6)
	and	d1,4(a6)
	and	d3,8(a6)
	and	d3,10(a6)
	and	d3,12(a6)
	swap	d1
	swap	d3
	or.l	d0,(a6)
	or	d1,4(a6)
	or.l	d2,8(a6)
	or	d3,12(a6)
	lea	160(a6),a6
	dbra	d7,.0
	rts

setrand:
	lea	xs,a6
	lea	randwert,a5
	lea	addwert,a4
	moveq	#8,d7
.0	bsr	random
	and	(a5)+,d0
	sub	(a4)+,d0
	move	d0,(a6)+
	dbra	d7,.0
	move.l	-18(a6),6(a6)
	move	-14(a6),10(a6)
	move	#$1ff,parabit
	rts

random:	
	lea	rand,a0
	move	(a0),d0
	move	d0,4(a0)
	move	2(a0),d1
	eor	d1,d0
	roxl	6(a0)
	roxr	#1,d0
	roxr	6(a0)
	move	d0,(a0)
	move	4(a0),d0
	move	d0,2(a0)
	rts

shift:	lea	ball,a0
	lea	balls,a1
	move	#17*16-1,d0
.0	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	dbra	d0,.0

	lea	balls,a0
	move	#17*16*15-1,d7		;zeilen
.1	move	(a0),d0
	swap	d0
	move	8(a0),d0
	lsr.l	#1,d0
	move	d0,8(a1)
	swap	d0
	move	d0,(a1)
	moveq	#0,d0
	move	2(a0),d0
	swap	d0
	move	10(a0),d0
	lsr.l	#1,d0
	move	d0,10(a1)
	swap	d0
	move	d0,2(a1)
	move	4(a0),d0
	swap	d0
	move	12(a0),d0
	lsr.l	#1,d0
	move	d0,12(a1)
	swap	d0
	move	d0,4(a1)
	clr	6(a1)
	clr	14(a1)
	lea	16(a0),a0
	lea	16(a1),a1
	dbra	d7,.1

	lea	balls,a0
	move	#17*512,d7
.3	move	(a0),d0
	or	2(a0),d0
	or	4(a0),d0
	not	d0
	move	d0,6(a0)
	addq	#8,a0
	dbra	d7,.3

	lea	lineadr,a0
	moveq	#0,d0
	move	#199,d7
.4	move	d0,(a0)+
	add	#160,d0
	dbra	d7,.4

	lea	pixoff,a0
	move	#319,d7
	moveq	#0,d0
.5	move	d0,d1
	lsr	d1
	and	#$fff8,d1
	move	d1,(a0)+
	addq	#1,d0
	dbra	d7,.5
	
	move.l	#buffer,a6
	lea	bdata,a5
	lea	clradr,a0
	lea	clradr+4*ballnum,a1
	moveq	#ballnum-1,d7
.6	move.l	a6,(a0)+
	move.l	a6,(a0)+
	clr.l	(a5)+
	clr.l	(a5)+
	dbra	d7,.6

	move	#0,curpos
	bra	showcursor

logoinit:
	lea	logo,a6
	move.l	scrtab,a5
	move.l	scrtab+4,a4
	lea	41*160+6(a5),a5
	lea	41*160+6(a4),a4
	move	#2399,d0
.0	move	(a6)+,d1
	eor	#$ffff,d1
	move	d1,(a5)
	move	d1,(a4)
	addq	#8,a4
	addq	#8,a5
	dbra	d0,.0
	rts


saveold:
	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,savesp
	bset.b	#1,$ffff820a.w
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	move	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move	d0,res
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,scrtab
	move.l	d0,scadr
	sub.l	#$8000,d0
	move.l	d0,scrtab+4
	clr	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move	#8000,d7
	move.l	scrtab+4,a0
.10	clr.l	(a0)+
	dbra	d7,.10
	pea	nomouse
	clr	-(sp)
	move	#25,-(sp)
	trap	#14
	addq	#8,sp
	movem.l	newpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

setold:
	move	sr,-(sp)
	move	#$2700,sr
	lea	$ffff8800,a0
	moveq	#$a,d0
.1	move.b	d0,(a0)
	clr.b	2(a0)
	dbra	d0,.1
	move.b	#7,(a0)
	move.b	#$c0,2(a0)
	move	(sp)+,sr
	move	res,-(sp)
	move.l	scadr,-(sp)
	move.l	scadr,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	pea	setmouse
	clr	-(sp)
	move	#25,-(sp)
	trap	#14
	addq	#8,sp
	move.l	savesp,-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

waitkey:
	movem.l	d1-a6,-(sp)
	move	#2,-(sp)
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	movem.l	(sp)+,d1-a6
	rts

setdli:	move.l	$120.w,old120
	move.l	$118.w,old118
	move.l	$118.w,nk+2
	move.l	$70.w,old70
	move.l	$70.w,nv+2
	move.b	$fffffa07.w,old7
	move.b	$fffffa09.w,old9
	move.b	$fffffa13.w,old13
	move.b	$fffffa15.w,old15
	move.b	$fffffa1b.w,old1b
	and.b	#$df,$fffffa09.w
	and.b	#$fe,$fffffa07.w
	move.l	#dli,$120.w
	move.l	#vbi,$70.w
	move.l	#key,$118.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	rts

clrdli:	move	sr,-(sp)
	move	#$2700,sr
	move.b	old7,$fffffa07.w
	move.b	old9,$fffffa09.w
	move.b	old13,$fffffa13.w
	move.b	old15,$fffffa15.w
	move.b	old1b,$fffffa1b.w
	move.l	old70,$70.w
	move.l	old118,$118.w
	move.l	old120,$120.w
	move	(sp)+,sr
	rts

key:	move	#$2300,sr
nk:	jmp	$ffffffff

vbi:	move.b	#0,$fffffa1b.w
dist:	move.b	#6,$fffffa21.w
	move.l	#dli,$120.w
	moveq	#0,d0
	move	d0,curcnt
	move	d0,dlicnt
	move	d0,dlicnt2
	addq	#1,count
	move	count,d0
	and	#$3,d0
	bne	.20
	addq	#2,coloff
	cmp	#280,coloff
	bne	.20
	clr	coloff
.20	eor	#3,d0
	moveq	#5,d1
	moveq	#30,d2
	add	d0,d1
	sub	d0,d2
	move.b	d1,anz1
	move.b	d2,anz2
	lea	farbtab,a1
	add	coloff,a1
	move.l	a1,coladr
	move.b	#8,$fffffa1b.w
	movem.l	d0-a6,-(sp)
	move.b	scrtab+1,$ffff8201.w
	move.b	scrtab+2,$ffff8203.w
	clr.b	$ffff8260.w
	clr	$ffff8240.w
	move	#$777,$ffff8250.w
	move.l	scrtab,a3
	lea	160*184+6(a3),a3
	move	scrregs,d0
	move.l	scrregs+2,a0
	bsr	scroller
	move	d0,scrregs
	move.l	a0,scrregs+2
;	move	#$077,$ffff8240.w
	bsr	outnum
;	move	#$707,$ffff8240.w
	move.l	songadr,a0
	jsr	(a0)
;	move	#7,$ffff8240.w
	bsr	berechne
;	move	#$070,$ffff8240.w
	bsr	sortiere
;	move	#$700,$ffff8240.w
	bsr	loeschen
;	move	#$770,$ffff8240.w
	bsr	ausgabe
	move.l	scrtab,d0
	move.l	scrtab+4,scrtab
	move.l	d0,scrtab+4
	move.l	clrtab,d0
	move.l	clrtab+4,clrtab
	move.l	d0,clrtab+4
	move	count,d0
	and	#1,d0
	bne	.31
	lea	curcol,a0
	move	curcol,d0
	move	#9,d7
.30	move	2(a0),(a0)+
	dbra	d7,.30
	move	d0,(a0)
.31	tst	newflg
	beq	.99
	bsr	setrand
	clr	newflg
.99	move	#$000,$ffff8240.w
	movem.l	(sp)+,d0-a6
	rte
nv:	jmp	$ffffffff


dli:	clr.b	$fffffa1b.w
	movem.l	d5-a2,-(sp)
	lea	$fffffa21.w,a0
	move.b	#9,(a0)
	move.b	#8,-6(a0)
	move.b	(a0),d5
.0	cmp.b	(a0),d5
	beq	.0
	move	curcol,$ffff8250.w
	move.b	(a0),d5
.1	cmp.b	(a0),d5
	beq	.1
	move	#$777,$ffff8250.w
	addq	#1,curcnt
	cmp	#4,curcnt
	bne	dex1
	clr.b	-6(a0)
	move.b	anz1,(a0)
	move.b	#8,-6(a0)
	move.l	#dli2,$120.w
dex1:	movem.l	(sp)+,d5-a2
	bclr.b	#0,$fffffa0f.w
	rte

dli2:	clr.b	$fffffa1b.w
	movem.l	d5-a2,-(sp)
	lea	$fffffa21.w,a0
	move.b	#4,(a0)
	move.b	#8,-6(a0)
	move.l	coladr,a1
	move.b	(a0),d5
.0	cmp.b	(a0),d5
	beq	.0
	move	(a1)+,$ffff8250.w
	move.l	a1,coladr
	addq	#1,dlicnt2
	cmp	#29,dlicnt2
	bne	.2
	clr.b	-6(a0)
	move.b	anz2,(a0)
	move.b	#8,-6(a0)
	move.l	#dli3,$120.w
.2	movem.l	(sp)+,d5-a2
	bclr.b	#0,$fffffa0f.w
	rte

dli3:	clr.b	$fffffa1b.w
	movem.l	d5-a2,-(sp)
	lea	$fffffa21.w,a0
	move.b	#240,(a0)
	move.b	#8,-6(a0)
	lea	colors,a1
	moveq	#16,d6
.1	move.b	(a0),d5
.0	cmp.b	(a0),d5
	beq	.0
	move	(a1)+,$ffff8250.w
	dbra	d6,.1
	move.l	#dli,$120.w
	movem.l	(sp)+,d5-a2
	bclr.b	#0,$fffffa0f.w
	rte

dosong:	
	move.l	$4ce,-(sp)
	move.l	#nosng,songadr
	asl	#2,d0
	lea	songtab1,a0
	lea	songtab2,a1
	move.l	0(a1,d0.w),a6
	move.l	a6,a5
	lea	$48(a5),a5
	move.l	0(a0,d0.w),d0
	move	d0,-(sp)
	jsr	(a6)
	addq	#2,sp
	move.l	a5,songadr
	move.l	(sp)+,$4ce
nosng:	rts


start:	dc.w	$a00a
	bsr	saveold
	bsr	logoinit
	lea	char,a0
	lea	chars,a1
	bsr	prescroll
	bsr	shift
	move	#0,scrregs
	move.l	#text,scrregs+2
	move	#17,-(sp)
	trap	#14
	addq	#2,sp
	move	d0,rand
	bsr	setrand
	bsr	setheader
	move.l	#nosng,songadr
	moveq	#$f,d0
	bsr	dosong
	bsr	setdli
.0	bsr	waitkey
	swap	d0
	moveq	#40,d7
	lea	keytab,a0
	lea	keyjmp,a1
.1	cmp	0(a0,d7.w),d0
	beq	.2
	subq	#2,d7
	bpl.s	.1
	bmi.s	.0
.2	add	d7,d7
	move.l	0(a1,d7.w),a0
	jsr	(a0)
	bra.s	.0

exit	bsr	clrdli
	lea	$ffff8800,a0
	moveq	#$a,d0
.1	move.b	d0,(a0)
	clr.b	2(a0)
	dbra	d0,.1
	move.b	#7,(a0)
	move.b	#$c0,2(a0)
	bsr	setold
	dc.w	$a009
	clr	-(sp)
	trap	#1

stwave:	or	#7,parabit
	lea	xs,a0
	move.l	24(a0),(a0)
	move	28(a0),2(a0)
	rts

cup:	bsr	nocursor
	move	curpos,d0
	subq	#2,d0
	bpl	.0
	moveq	#16,d0
.0	move	d0,curpos
	bra	showcursor

cdown:	bsr	nocursor
	move	curpos,d0
	addq	#2,d0
	cmp	#18,d0
	bne	.0
	moveq	#0,d0
.0	move	d0,curpos
	bra	showcursor

m1:	moveq	#1,d0
	bra.s	minus
m10:	moveq	#10,d0
	bra.s	minus
m100:	move	#100,d0
minus:	move	curpos,d7
	lea	para,a0
	lea	xs,a1
	move	54(a0,d7.w),d1
	move	0(a1,d1.w),d2
	sub	d0,d2
	bpl	.0
	neg	d2
	cmp	72(a0,d7.w),d2
	bcs	.1
	move	72(a0,d7.w),d2
.1	neg	d2
.0	move	d2,0(a1,d1.w)
	lsr	#1,d7
	move	parabit,d0
	bset.l	d7,d0
	move	d0,parabit
	rts

p1:	moveq	#1,d0
	bra.s	aplus
p10:	moveq	#10,d0
	bra.s	aplus
p100:	move	#100,d0
aplus:	move	curpos,d7
	lea	para,a0
	lea	xs,a1
	move	54(a0,d7.w),d1
	move	0(a1,d1.w),d2
	add	d0,d2
	bmi	.0
	cmp	90(a0,d7.w),d2
	bcs	.0
	move	90(a0,d7.w),d2
.0	move	d2,0(a1,d1.w)
	lsr	#1,d7
	move	parabit,d0
	bset.l	d7,d0
	move	d0,parabit
	rts

hlp:	addq	#1,newflg
	bsr	random
	and	#$f,d0
	bra	dosong
	

pre:	
	sub	#$3b,d0
	move	d0,-(sp)
	bsr	dosong
	move	(sp)+,d0
	mulu	#18,d0
	lea	prewaves,a0
	add	d0,a0
	lea	xs,a1
	movem.l	(a0),d0-d4
	swap	d4
	movem.l	d0-d3,(a1)
	move	d4,16(a1)
	move.l	(a1),24(a1)
	move	4(a1),28(a1)
	move	#$1ff,parabit
	bra	stwave

prescroll:
	lea	1*64*2*16*2(a1),a2	
	lea	2*64*2*16*2(a1),a3	
	lea	3*64*2*16*2(a1),a4	
	moveq	#64-1,d0		

scroll_16_1_init1:	
	
	moveq	#16-1,d1		

scroll_16_1_init2:

	moveq	#0,d2			
	move.w	(a0)+,d2		
	move.l	d2,(a1)+		
	lsl.l	#4,d2			
	move.l	d2,(a2)+		
	lsl.l	#4,d2			
	move.l	d2,(a3)+		
	lsl.l	#4,d2			
	move.l	d2,(a4)+		
	dbf	d1,scroll_16_1_init2	
	dbf	d0,scroll_16_1_init1	
	rts

scroller:
	lea	chars,a2
	move.w	d0,d1			
	mulu	#64*2*16*2,d1		
	add.w	d1,a2			
	move.l	a0,a4			
	bsr	nextchar		
	bsr	einbauen_1		
	moveq	#19-1,d2		

scrolline_16_1_1:
	
	bsr	nextchar		
	bsr	einbauen_2		
	dbf	d2,scrolline_16_1_1	
	bsr	nextchar		
	bsr	einbauen_3		
	addq.w	#1,d0			
	andi.w	#3,d0			
	bne	scrolline_16_1_2	
	addq.w	#1,a0			
	tst.b	(a0)			
	bpl	scrolline_16_1_2	
	lea	text,a0			

scrolline_16_1_2:
	rts

nextchar:
	moveq	#0,d1
	move.b	(a4)+,d1		
	bpl	nextchar1		
	lea	text,a4			
	bra	nextchar		
nextchar1:
	subi.b	#32,d1			
	lsl.w	#6,d1			
	rts

einbauen_1:
	movem.l	00(a2,d1.w),d3-d6	
	move.w	d3,00*160(a3)		
	move.w	d4,01*160(a3)		
	move.w	d5,02*160(a3)		
	move.w	d6,03*160(a3)		
	movem.l	16(a2,d1.w),d3-d6	
	move.w	d3,04*160(a3)		
	move.w	d4,05*160(a3)		
	move.w	d5,06*160(a3)		
	move.w	d6,07*160(a3)		
	movem.l	32(a2,d1.w),d3-d6	
	move.w	d3,08*160(a3)		
	move.w	d4,09*160(a3)		
	move.w	d5,10*160(a3)		
	move.w	d6,11*160(a3)		
	movem.l	48(a2,d1.w),d3-d6	
	move.w	d3,12*160(a3)		
	move.w	d4,13*160(a3)		
	move.w	d5,14*160(a3)		
	move.w	d6,15*160(a3)		
	rts

einbauen_2:
	movem.l	00(a2,d1.w),d3-d6	
	move.w	d3,00*160+8(a3)		
	move.w	d4,01*160+8(a3)		
	move.w	d5,02*160+8(a3)		
	move.w	d6,03*160+8(a3)		
	swap	d3			
	swap	d4			
	swap	d5			
	swap	d6			
	or.w	d3,00*160(a3)		
	or.w	d4,01*160(a3)		
	or.w	d5,02*160(a3)		
	or.w	d6,03*160(a3)		
	movem.l	16(a2,d1.w),d3-d6	
	move.w	d3,04*160+8(a3)		
	move.w	d4,05*160+8(a3)		
	move.w	d5,06*160+8(a3)		
	move.w	d6,07*160+8(a3)		
	swap	d3			
	swap	d4			
	swap	d5			
	swap	d6			
	or.w	d3,04*160(a3)		
	or.w	d4,05*160(a3)		
	or.w	d5,06*160(a3)		
	or.w	d6,07*160(a3)		
	movem.l	32(a2,d1.w),d3-d6	
	move.w	d3,08*160+8(a3)		
	move.w	d4,09*160+8(a3)		
	move.w	d5,10*160+8(a3)		
	move.w	d6,11*160+8(a3)		
	swap	d3			
	swap	d4			
	swap	d5			
	swap	d6			
	or.w	d3,08*160(a3)		
	or.w	d4,09*160(a3)		
	or.w	d5,10*160(a3)		
	or.w	d6,11*160(a3)		
	movem.l	48(a2,d1.w),d3-d6	
	move.w	d3,12*160+8(a3)		
	move.w	d4,13*160+8(a3)		
	move.w	d5,14*160+8(a3)		
	move.w	d6,15*160+8(a3)		
	swap	d3			
	swap	d4			
	swap	d5			
	swap	d6			
	or.w	d3,12*160(a3)		
	or.w	d4,13*160(a3)		
	or.w	d5,14*160(a3)		
	or.w	d6,15*160(a3)		
	addq.w	#8,a3			
	rts

einbauen_3:
	movem.l	-2(a2,d1.w),d3-d6	
	or.w	d3,00*160(a3)		
	or.w	d4,01*160(a3)		
	or.w	d5,02*160(a3)		
	or.w	d6,03*160(a3)		
	movem.l	14(a2,d1.w),d3-d6	
	or.w	d3,04*160(a3)		
	or.w	d4,05*160(a3)		
	or.w	d5,06*160(a3)		
	or.w	d6,07*160(a3)		
	movem.l	30(a2,d1.w),d3-d6	
	or.w	d3,08*160(a3)		
	or.w	d4,09*160(a3)		
	or.w	d5,10*160(a3)		
	or.w	d6,11*160(a3)		
	movem.l	46(a2,d1.w),d3-d6	
	or.w	d3,12*160(a3)		
	or.w	d4,13*160(a3)		
	or.w	d5,14*160(a3)		
	or.w	d6,15*160(a3)		
	rts

	section data

newpal:		dc.w	$000,$770,$660,$550,$440,$330,$220,$110
		dc.w	$000,$770,$660,$550,$440,$330,$220,$110

header1:	dc.b	"XSTART:+0000    XOFF: +0000    XADD: +00"
header2:	dc.b	"YSTART:+0000    YOFF: +0000    YADD: +00"
header3:	dc.b	"ZSTART:+0000    ZOFF: +0000    ZADD: +00"

nomouse:	dc.b	$12
setmouse:	dc.b	8
 even

sinus:		incbin	"bahn.dat"
ball:		incbin	"ballgr.dat"
logo:		incbin	"logo.img"
farbtab:	incbin	"balls.pal"
colors:		incbin	"nice2.pal"
font:		incbin	"fnt8bit.gr"
char:		incbin	"char.dat"

song1:		incbin	"leather.rip"
song2:		incbin	"enduro.rip"
song3:		incbin	"rampage.rip"
song4:		incbin	"genesis.rip"
song5:		incbin	"xenon.rip"
song6:		incbin	"goldrun2.rip"
song7:		incbin	"tetris.rip"

songtab1:	dc.l	0,1,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,0
songtab2:	dc.l	song1,song1,song2,song2,song3,song3
		dc.l	song4,song6,song5,song5,song6,song6
		dc.l	song7,song7,song1,song2,song3,song4

balladr:	dc.l	balls,balls+$1100,balls+$2200,balls+$3300
		dc.l	balls+$4400,balls+$5500,balls+$6600,balls+$7700
		dc.l	balls+$8800,balls+$9900,balls+$aa00,balls+$bb00
		dc.l	balls+$cc00,balls+$dd00,balls+$ee00,balls+$ff00

randwert:	dc.w	$7ff,$7ff,$1ff,$7ff,$7ff,$7ff,$03f,$03f,$03f
addwert:	dc.w	$000,$000,$000,$400,$400,$400,$020,$020,$020

para:		dc.w	4,4,4,4,4,4,2,2,2		;len
		dc.w	31,1471,2911,94,1534,2974,151,1591,3031
		dc.w	7,7,7,1,1,1,7,7,7
		dc.w	24,26,28,6,8,10,12,14,16
		dc.w	0,0,0,1024,1024,1024,32,32,32
		dc.w	2047,2047,2047,1024,1024,1024,32,32,32

keytab:		dc.w	$48,$50,$4b,$4d,$52,$47,$62,$39,$61,$1c,$72
		dc.w	$3b,$3c,$3d,$3e,$3f,$40,$41,$42,$43,$44
keyjmp:		dc.l	cup,cdown,m1,p1,m10,p10,m100,exit,p100,hlp,stwave
		dc.l	pre,pre,pre,pre,pre,pre,pre,pre,pre,pre

curcol:		dc.w	$100,$200,$300,$400,$500,$600,$700,$600,$500,$300,$200

prewaves:	dc.w	1915,1817,49,916,978,35,24,13,-22
		dc.w	2040,386,317,-673,-719,55,-29,-6,12
		dc.w	794,1861,47,-843,845,1020,-8,-14,-27
		dc.w	1361,45,190,329,1019,-679,-15,-28,10
		dc.w	583,1549,37,20,-744,646,-17,4,21
		dc.w	1799,1408,323,97,145,120,20,-26,25
		dc.w	391,538,462,490,-494,1020,23,-27,25
		dc.w	601,2035,177,-349,-1015,-683,14,29,9
		dc.w	1969,634,229,79,-171,-115,12,16,-18
		dc.w	1718,1490,434,48,43,-275,-4,-14,17
		
scrtab:		dc.l	$1f8000,$1f0000
clrtab:		dc.l	clradr,clradr+4*ballnum

text:		dc.b	"DIES IST EIN 3D BALLMOVER!   DER ERSTE SEINER ART. "
		dc.b	"GESCHRIEBEN VON PETER SABATH  (OH!!! AH!!!)     "
		dc.b	"HANDHABUNG: CURSORBEWEGUNG MIT PFEILTASTEN AUF UND "
		dc.b	"AB, AENDERN MIT PFEIL RECHTS,LINKS INSERT,CLR, HELP UND UNDO. "
		dc.b	"ZUFALLSMUSTER: RETURN, START WAVE: ENTER (ZIFFERNBLOCK) "
		dc.b	"ALLES KLAR? NA DENN BIS DEMNAECHST...         "
		dc.b	"ACH JA, ERREICHEN KOENNEN SIE UNS NATUERLICH AUCH UND ZWAR "
		dc.b	"UNTER FOLGENDER ADRESSE:  ALLGEMEINER ESSENER COMPUTERCLUB E.V.  (AEC)   "
		dc.b	"L. LINDNER  ALFREDSTRASSE 4   4300 ESSEN 1   TELEFON (02 01) 79 04 72"
		dc.b	"                        ",-1

 even
	section bss

old70:		ds.l	1
old118:		ds.l	1
old120		ds.l	1
old7:		ds.b	1
old9:		ds.b	1
old13:		ds.b	1
old15:		ds.b	1
old1b:		ds.b	1
anz1:		ds.b	1
anz2:		ds.b	1
 even
xs:		ds.w	15
res:		ds.w	1
scadr:		ds.l	1
songadr:	ds.l	1
oldpal:		ds.l	8
scrregs:	ds.l	4
savesp:		ds.l	1
count:		ds.w	1
newflg:		ds.w	1
parabit:	ds.w	1
curpos:		ds.w	1
curcnt:		ds.w	1
curcoladr:	ds.l	1
dlicnt:		ds.w	1
dlicnt2:	ds.w	1
coloff:		ds.w	1
coladr:		ds.l	1
rand:		ds.w	4
number:		ds.b	6
bdata:		ds.w	4*ballnum
clradr:		ds.l	2*ballnum
lineadr:	ds.w	200
pixoff:		ds.w	320
chars:		ds.b	16384
balls:		ds.b	17*16*256
buffer:		ds.b	1024

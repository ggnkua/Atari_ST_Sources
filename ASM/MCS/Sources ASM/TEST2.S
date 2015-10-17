	pea	s_stop(pc)
	move	#0,-(sp)
	move	#$19,-(sp)
	trap	#$e
	addq.l	#8,sp

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)

	move.w	#0,-(sp)
	pea	$78000
	pea	$78000
	move.w	#5,-(sp)
	trap	#14
	adda.l	#12,sp


	pea	lirejoy
	move.w	#1,-(sp)
	move.w	#25,-(sp)
 	trap	#14		passage mode joy
	addq.l	#8,sp

	move.w	#34,-(sp)
	trap	#14		recupere adr joy
	addq.l	#2,sp
	add.l	#61,d0
	move.l	d0,adrjoy

	moveq	#0,d7		calcul des 16 positions du vaisseau
	move.l	#sprite,a1
loop2				
	moveq	#40,d0
	move.l	#sp1,a0
loop
LM1	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	ror.l	d7,d1
	ror.l	d7,d2
	ror.l	d7,d3
	ror.l	d7,d4
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	swap	d1
	swap	d2
	swap	d3
	swap	d4

LM2	moveq	#0,d5
	moveq	#0,d6
	move.w	(a0)+,d5
	move.w	(a0)+,d6
	ror.l	d7,d5
	ror.l	d7,d6
	or.w	d1,d5
	or.w	d2,d6
	moveq	#0,d1
	moveq	#0,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	ror.l	d7,d1
	ror.l	d7,d2
	or.w	d3,d1
	or.w	d4,d2
	move.w	d5,(a1)+
	move.w	d6,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	swap	d5
	swap	d6
	swap	d1
	swap	d2

LM3	move.w	d5,(a1)+
	move.w	d6,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+

	dbra	d0,loop

	addq	#1,d7
	cmp.b	#16,d7
	bne	loop2

	move.l	#a4ecran,d0
	and.l	#$ffffff00,d0
	move.l	d0,base
	move.b	base+1,$ff8201
	move.b	base+2,$ff8203
	move.b	base+3,$ff820d
	move.b	#80,$ff820f
	add.l	#160*2,d0 		??????
	move.l	d0,adscreen
	move.l	d0,adscreen1
	
	move.l	d0,a0
	move.l	#400*160/4/3*2,d0
motif	move.l	#$ff00f,(a0)+
	move.l	#$f0ff0,(a0)+
	move.l	#$fff0f,(a0)+
	dbra	d0,motif


	bsr	setmfp
	lea	$fffffa01.w,a5
	and.b	#$de,18(a5)
	and.b	#$de,14(a5)
	and.b	#$de,10(a5)
	and.b	#$de,6(a5)
	clr.b	24(a5)
	clr.b	26(a5)
	lea	timera(pc),a0
	move.l	a0,$134.w
	
	lea	ancit70,a0
	move.l	$70.w,(a0)


	lea	it70(pc),a0
	move.l	a0,$70.w

	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#$d
	addq.l	#4,sp
	


	move	sr,-(sp)
	or	#$700,sr
	move.l	ancit70,$70.w
	
	and.b	#$de,18(a5)
	and.b	#$de,14(a5)
	and.b	#$de,10(a5)
	and.b	#$de,6(a5)
	clr.b	24(a5)
	clr.b	26(a5)
	bsr	resetmfp


	clr.b	$ff820f
	clr.b	$ff8265

	pea	lirejoy+1
	move.w	#1,-(sp)
	move.w	#25,-(sp)
 	trap	#14		hors fonction joy
	addq.l	#8,sp
	
	pea	lirejoy+2
	move.w	#1,-(sp)
	move.w	#25,-(sp)
 	trap	#14		passage mode souris
	addq.l	#8,sp


	move	(sp)+,sr
	
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	s_go(pc)
	move	#0,-(sp)
	move	#$19,-(sp)
	trap	#$e
	addq.l	#8,sp

	clr	-(sp)
	trap	#1

setmfp
	lea	ftimc(pc),a0
	move.l	$114,2(a0)
	lea	timc(pc),a0
	move.l	a0,$114
	lea	fclmi(pc),a0
	move.l	$118,2(a0)
	lea	clmi(pc),a0
	move.l	a0,$118
	rts

resetmfp
	lea	ftimc(pc),a0
	move.l	2(a0),$114
	lea	fclmi(pc),a0
	move.l	2(a0),$118
	rts

timc	or	#$500,sr
	and	#$fdff,sr
ftimc	jmp	$10000
clmi	or	#$500,sr
	and	#$fdff,sr
fclmi	jmp	$10000

it70	move.l	ancit70,-(sp)
	move.b	xe+1,$ff8265
	movem.l	d0-d1/a0,-(sp)
	lea	$ffff8201.w,a0
	movep	0(a0),d0
	movep	4(a0),d1
	cmp	d0,d1
	bne	stoppe
	tst.b	8(a0)
	bne	stoppe
	lea	flag(pc),a0
	tst	(a0)
	beq 	lance
	clr	(a0)
	movem.l	(sp)+,d0-d1/a0

	move.w	#0,$ff8240


	move.w	ye,d0
	addi.b	#1,d0
	cmpi.b	#200,d0
	bne	cestbon
	moveq	#0,d0
cestbon move.w	d0,ye
	mulu.w	#320,d0
	move.l	base,d1
	add.l	#160*2,d1	????
	add.l	d1,d0
	move.l	d0,adscreen1
	moveq	#0,d1
	move.w	xe,d1
	andi.w	#$fff0,d1
	lsr.w	#1,d1		xe/16*8=xe/2
	add.l	d1,d0
	move.l	d0,adscreen

*	cmp.b	#$39,$fffffc02
*	beq 	fin




	move.w	xe,d0
	andi.b	#$f,d0
*	move.b	d0,$ff8265
	beq.s	v80
v76	move.b	#76,$ff820f
	bra.s	aller
v80	move.b	#80,$ff820f
aller	
*	move.b	xe+1,$ff8265
*	move.b	adscreen+1,$ff8205
*	move.b	adscreen+2,$ff8207
*	move.b	adscreen+3,$ff8209

*	bra	joy

	move.b	adscreen+1,$ff8205
	move.b	adscreen+2,$ff8207
	move.b	adscreen+3,$ff8209

	move.w	#$777,$ff8240

	rts





gauche	movem.l	d0-d3,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	move.w	xe,d0
	move.w	x,d1
	cmpi.w	#0,d0
	bne	xesup0
xeeg0	cmpi.w	#0,d1
	beq	suitg
xsup0	subi.w	#1,d1
	bra	suitg
xesup0	cmpi.w	#50,d1		xmin=50
	beq	xegxmin
xsupxmin subi.w	#1,d1
	bra	suitg
xegxmin	subi.w	#1,d0
suitg	move.w	d0,xe
	move.w	d1,x
	movem.l	(sp)+,d0-d3
	rts

droite	movem.l	d0-d3,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	move.w	xe,d0
	move.w	x,d1
	cmpi.w	#320,d0
	bne	xeinf320
xeeg320	cmpi.w	#319-32,d1
	beq	suitd
xinf187	addi.w	#1,d1
	bra	suitd
xeinf320 cmpi.w	#238,d1		xmax=238
	bne	xinfxmax	
xegxmax	addi.w	#1,d0
	bra	suitd
xinfxmax addi.w	#1,d1
suitd	move.w	d0,xe
	move.w	d1,x
	movem.l	(sp)+,d0-d3
	rts






lance	lea	b200(pc),a0
	move.l	a0,$120.w
	lea	$fffffa01.w,a0
	clr.b	26(a0)
	move.b	#199,32(a0)
	move.b	#8,26(a0)
	or.b	#1,6(a0)
	or.b	#1,18(a0)
	movem.l	(sp)+,d0-d1/a0
	rts

stoppe	lea	$fffffa01.w,a0
	and.b	#$de,18(a0)
	and.b	#$de,6(a0)
	clr.b	26(a0)
	clr.b	24(a0)
	lea 	flag(pc),a0
	clr	(a0)
	movem.l	(sp)+,d0-d1/a0
	rts

timera	cmp.b	#1,$fffffa21.w
	bgt.s	timera
*	move.w	#$0,$ff8240
*	move.b	adscreen+1,$ff8205
*	move.b	adscreen+2,$ff8207
*	move.b	adscreen+3,$ff8209
	rept 86
	nop
	endr
*	move.w	#$777,$ff8240
	move.b	#$fc,$ffff820a.w
	rept 8
	nop
	endr
	move.b	#$fe,$ffff820a.w
	movem.l	d0-d2/a0,-(sp)
	lea	$ffff8201.w,a0
	movep.w	0(a0),d1
	movep.w	4(a0),d2
	lea	b229(pc),a0
	move	#228,d0
	tst.b	$ffff8209.w
	bne.s	ok
	cmp	d1,d2
	bne.s	ok
	lea	b200(pc),a0
	move	#199,d0
ok	move.l	a0,$120.w
	lea	$fffffa01.w,a0
	clr.b	26(a0)
	move.b	d0,32(a0)
	move.b	#8,26(a0)
	or.b	#1,6(a0)
	or.b	#1,18(a0)
	clr.b	24(a0)
	bclr	#5,14(a0)
	movem.l	(sp)+,d0-d2/a0
	rte

b200	movem.l	d0/a0-a2,-(sp)
	lea	$fffffa01.w,a0
	lea	$ffff8209.w,a1
	lea	switch(pc),a2
	lea	-222(a2),a2
	moveq	#0,d0
	and.b	#$fe,18(a0)
	and.b	#$fe,6(a0)
	clr.b	26(a0)
	clr.b	24(a0)
wait200	move.b	(a1),d0
	cmp	#222,d0
	blt.s	wait200
	cmp.b	#0,d0
	bgt	rate
	jmp	0(a2,d0)

b229	movem.l	d0/a0-a2,-(sp)
	lea	$fffffa01.w,a0
	lea	$ffff8209.w,a1
	lea	switch(pc),a2
	moveq	#0,d0
	and.b	#$fe,18(a0)
	and.b	#$fe,6(a0)
	clr.b	26(a0)
	clr.b	24(a0)
wait229	move.b	(a1),d0
	cmp.b	#8,d0
	blt.s	wait229
	cmp	#32,d0
*	bgt	rate
	jmp	-8(a2,d0)

switch	rept 25
	nop
	endr
	move.b	#$fc,$ffff820a.w
	nop
	move.b	#$fe,$ffff820a.w
	move.b	#132,32(a0)
	move.b	#6,26(a0)
	move.b	#129,30(a0)
	move.b	#6,24(a0)
	or.b	#$20,6(a0)
	or.b	#$20,18(a0)
	bclr	#0,14(a0)
	lea	flag(pc),a0
	move	#-1,(a0)
	movem.l	(sp)+,d0/a0-a2
	rte

rate	bclr	#0,14(a0)
	lea	flag(pc),a0
	clr	(a0)
	movem.l	(sp)+,d0/a0-a2
	rte

		data
flag	dc.w	0
s_stop	dc.b	$12
s_go	dc.b	$8


savsup	ds.l 1
sp1	incbin	sprite.jeu
sprite	ds.l	16*656
adrjoy	ds.l	1
base	ds.l 	1
adscreen ds.l	1
adscreen1 ds.l	1

lirejoy	dc.b	$0,$14,$15,$8
x	dc.w	160
y	dc.w	100
xe	dc.w	0
ye	dc.w	0

a4ecran	ds.b	32000*4+256


		bss
ancit70	ds.l	1
vbl

		end
		
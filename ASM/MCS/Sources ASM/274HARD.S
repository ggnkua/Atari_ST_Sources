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

		*						*
		*		prepare scroll hard		*
		*						*

	move.l	#a4ecran,d0
	and.l	#$ffffff00,d0
	move.l  d0,d1
	move.b	d1,$ff820d
	lsr.l	#8,d1
	move.b	d1,$ff8203
	lsr.l	#8,d1
	move.b	d1,$ff8201
	move.b	#80,$ff820f
	add.l	#16080,d0	+160*100+80
	move.l	d0,adscreen
	




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
	
	lea	ancit70(pc),a0
	move.l	$70.w,(a0)


	lea	it70(pc),a0
	move.l	a0,$70.w

	move.l	#160*274/4,d0
	move.l	#$78000+160*00,a0
dess	move.l	#$f0f00f0f00f,(a0)+
	dbra	d0,dess


	move	#2,-(sp)
	move	#2,-(sp)
	trap	#$d
	addq.l	#4,sp

	clr.b	$ff820f
	clr.b	$ff8265




	move	sr,-(sp)
	or	#$700,sr
	move.l	ancit70(pc),$70.w
	
	and.b	#$de,18(a5)
	and.b	#$de,14(a5)
	and.b	#$de,10(a5)
	and.b	#$de,6(a5)
	clr.b	24(a5)
	clr.b	26(a5)
	bsr	resetmfp


	move	(sp)+,sr
	
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	s_go(pc)
	move	#0,-(sp)
	move	#$19,-(sp)
	trap	#$e
	addq.l	#8,sp

fin	clr	-(sp)
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

it70
	move.l	adscreen,d0
	move.b	d0,$ff8209
	lsr.l	#8,d0
	move.b	d0,$ff8207
	lsr.l	#8,d0
	move.b	d0,$ff8205
	move.b	variabl,d0
	move.b	d0,$ff8265
	andi.b	#15,d0
	cmpi.b	#0,d0
	beq	v80
v76	move.b	#76,$ff820f
	bra.s	vasy
v80	move.b	#80,$ff820f
vasy	bsr	gdhb



	move.l	ancit70(pc),-(sp)
	movem.l	d0-d1/a0,-(sp)
	lea	$ffff8201.w,a0
	movep	0(a0),d0
	movep	4(a0),d1
	cmp	d0,d1
	bne.s	stoppe
	tst.b	8(a0)
	bne.s	stoppe
	lea	flag(pc),a0
	tst	(a0)
	beq.s	lance
	clr	(a0)
	movem.l	(sp)+,d0-d1/a0
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


		*					*
		*	Gauche-Droite-Haut_Bas		*
		*					*
gdhb	move.l	adscreen,d0	
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.b	pash,d1
	move.w	pasv,d2
	bsr	droite
*	bsr	gauche	
*	add.l	d2,d0
	sub.l	d2,d0
	move.l	d0,adscreen
	rts

droite	move.b	variabl,d3
	subi.b	#1,d3
	move.b	d3,variabl
	andi.b	#15,d3
	cmpi.b	#15,d3
	bne.s	dsuit
	subi.l	#8,d0
dsuit	rts

	


		data
flag	dc.w	0
s_stop	dc.b	$12
s_go	dc.b	$8
variabl dc.b	0
pash	dc.b	4-1
pasv	dc.w	4*160


		bss
ancit70	ds.l	1
a4ecran ds.b	32000*4+256	
adscreen ds.l	1
vbl

		end


	
	opt	o+

	move.w	#2,-(sp)
	trap	#14
	lea	2(sp),sp
	move.l	d0,saveadrecr

	move.w	#4,-(sp)
	trap	#14
	addq	#2,sp
	move.w	d0,saverez

	move.l	a7,a5
	lea	pile(pc),a7
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.w	#0,-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	add.l	#$c,a7

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,-(a7)

	move.l	$44e.w,d1
	move.l	d1,d0
	sub.l	#32000,d0
	cmp.l	$436.w,d1
	bne.s	oqp

	move.l	#-1,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq	#6,sp
	pea	error(pc)
	sub.l	#32000,d0
	bmi	non
	addq	#4,sp
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,-(sp)
	move.l	#32000,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,d7
	move.l	d0,libermem

	move.w	#$49,-(sp)
	trap	#1
	addq	#6,sp

	move.l	$436.w,d0
	sub.l	#32000,d0
	move.l	d0,$436.w
	cmp.l	d0,d7
	beq.s	oqp
	move.l	d0,-(sp)
	move.l	d7,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq	#6,sp
	move.l	(sp)+,d0
	add.l	#32000,$436.w
	lea	mais(pc),a0
	move.b	#13,(a0)

oqp	move.l	d0,d7

	move.w	#-1,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#13,-(sp)
	move.w	#2,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq	#6,sp

	pea	ok(pc)

non	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp

	bra	ensuite

error	dc.b	27,'.',27,'q',13,10,0
ok	dc.b	'.',13,10,0
mais	dc.b	'!',13,10,0

	ds.l	128
pile	ds.l	1

*-----------------------------------------------------------*

ensuite	add.l	#32000,d7

	move.l	d7,ecrttst

	clr.w	-(sp)
	move.l	d7,-(sp)
	move.l	d7,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	sub.l	#32000,d7
	move.l	d7,ecrttst2

	clr.w	-(sp)		*c'est bon
	move.l	d7,-(sp)
	move.l	d7,-(sp)
	move.w	#5,-(sp) 
	trap	#14
	lea	12(sp),sp

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,-(sp)

	move.b	#2,$ffff820a.w

	lea	maintext,a0
	move.b	#46,-1(a0)

	lea	savepalet,a0
	lea	$ffff8240.w,a1
	rept	16
	move.w	(a1)+,(a0)+
	endr

	lea	altelp,a0
	move.l	a0,$502.w

	move.w	#$000,$ffff8240.w	*couleur du fond
	move.w	#$330,$ffff8242.w	*couleur des ptits scrolers
	move.w	#$300,$ffff8244.w	*couleur du megascroller
	move.w	#$555,$ffff8250.w	*couleur du backgrnd
	move.w	#$777,$ffff8248.w	*couleur du main scroller
	move.w	#$300,$ffff8246.w	*intersec. scrolers/mega
	move.w	#$555,$ffff8252.w	*intersec. scrolers/backgr.
	move.w	#$300,$ffff8254.w	*intersec. megascr/backgr.
	move.w	#$777,$ffff824a.w	*intersec. mainscrl/scrlers
	move.w	#$777,$ffff824c.w	*intersec. mainscrl/mega
	move.w	#$777,$ffff824e.w	*intersec. main/mega/scrlrs
	move.w	#$777,$ffff8258.w	*intersec. main/backgrnd
	move.w	#$777,$ffff825a.w	*intersec. main/scrlrs/back
	move.w	#$300,$ffff8256.w	*intersec. mega/back/scrols
	move.w	#$777,$ffff825e.w	*intersec. tous les plans

	lea	hblcolors,a5

	move.b	#$12,$fffffc02.w
	lea	data0,a1
	movea.l	$44e,a2
	move.l	a2,adr_scr
	adda.l	#160*192,a2
	lea	mega_scrol,a3
	lea	scrolerspil,a6
	movem.l	d0-d7/a0-a4,(a6)

	lea	mega_text0,a4
	move.b	#27,d4
	lea	bigscrolpil,a6
	movem.l	d0-d7/a0-a4,(a6)

	lea	backdata0,a1
	lea	backgrndpil,a6
	movem.l	d0-d7/a0-a4,(a6)

	lea	mainscrlpil,a6
	lea	maintext0,a0
	lea	v_dist,a4
	moveq	#5,d1
	lea	rewrite,a3
	rept	20
	move.l	ecrttst,(a3)+
	endr
	movem.l	d0-d7/a0-a4,(a6)

	lea	equalipil,a6
	move.l	ecrttst,equasauv	*attention !!!! (1040)
	movem.l	d0-d7/a0-a4,(a6)

	lea	transpil,a6
	lea	v_dist,a4
	movem.l	d0-d7/a0-a4,(a6)

	lea	logopil,a6
	lea	savelogo,a3
	lea	logo_dist0,a4
	rept	20
	move.l	ecrttst,(a3)+	*attention !!! (1040)
	endr
	movem.l	d0-d7/a0-a4,(a6)

*-----------------------------------------------------------*
*	Rasters	-	Musique		*
*-----------------------------------------------------------*

	move.w	#37,-(sp)
	trap	#$e
	lea	2(sp),sp

	move.w	#$2700,sr
	lea	hblcolors,a5
	lea	$fffffa00.w,a0
	move.b	$7(a0),mfp7
	move.b	$9(a0),mfp9
	clr.b	$7(a0)
	clr.b	$9(a0)	
	lea	sauvhbl,a1
	move.l	$120.w,(a1)
	lea	hbl,a1
	move.l	a1,$120.w

	move.b	#8,$1b(a0)
	move.b	#4,$21(a0)
	bset.b	#0,$7(a0)
	bset.b	#0,$13(a0)	
	move.w	#$2300,sr
	lea	hblcolors,a5
	
	clr.l	$4d2
	moveq	#1,d0
	jsr	music
	move.l	#music+8,$4d2

*------------------------- Scrolers ------------------------*

debut	lea	sav,a6
	movem.l	a0-a5/d0-d7,(a6)
	move.l	$44e,d6
	cmp.l	ecrttst,d6		*f8000
	bne	augmente
	move.l	ecrttst2,d6		*f0300
	bra	debut2
	
augmente	add.l	#1280,d6		*1280, pas 160..

debut2	move.w	#-1,-(sp)
	move.l	d6,-(sp)
	move.l	d6,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	lea	sav,a6
	movem.l	(a6),a0-a5/d0-d7

	*move.w	#$00,$ffff8240.w	*(tps machine invisible)
	move.l	$466.w,d6
vsync	move.l	$466.w,d7
	cmp.l	d6,d7
	beq.s	vsync

	lea	hblcolors,a5

	move.w	#$0,$ffff8240.w

	bsr	transfer
	bsr	logo
	bsr	background
	bsr	ptitscrols
	bsr	equalizers
	bsr	logocl
	bsr	main_scrol

	bra	continue5

ptitscrols	lea	scrolerspil,a6
	movem.l	(a6),d0-d7/a0-a4

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	(a1)+,d0
	cmp.w	#65535,d0
	bne.s	continue
	lea	data,a1
	move.w	(a1)+,d0

continue	lea	scrollers,a0
	movea.l	$44e,a2
	adda.l	#160*192,a2

	move.w	d0,d1		* Exemple: d0=25
	move.w	d0,d2
	and.w	#$fffffff0,d1	* d1=16
	sub.w	d1,d2		* d2=25-16 d2=9 (de 0…15)
	move.w	d2,d4		* d4=9
	lsr.w	#2,d2		* d2=d2/4  d2=2 (rang 0…3)
	move.w	d2,d3
	lsl.w	#2,d3		* d3=d3*4  d3=8 (de 0…12)
	sub.w	d3,d4		* d4=1 (plan 0…3)
	lsr.w	#1,d1		* d1=8 decalage octets
	mulu.w	#5*8*160,d2
	adda.l	d2,a0		* rang‚e
	adda.l	d1,a0		* multiple 16 pix.
	lsl.w	#1,d4
	adda.l	d4,a0		* plan
	bsr	transpose
	suba.l	#32000+8*160,a2
	bsr	transpose

	lea	scrolerspil,a6
	movem.l	d0-d7/a0-a4,(a6)

	bra	continue2

transpose
offset1	set	0
	rept	20
	move.w	offset1(a0),offset1(a2)
	move.w	offset1+800(a0),offset1+160(a2)
	move.w	offset1+1600(a0),offset1+320(a2)
	move.w	offset1+2400(a0),offset1+480(a2)
	move.w	offset1+3200(a0),offset1+640(a2)
	move.w	offset1+4000(a0),offset1+800(a2)
	move.w	offset1+4800(a0),offset1+960(a2)
	move.w	offset1+5600(a0),offset1+1120(a2)
offset1	set	offset1+8
	endr
	rts	

*--------------------- Mega-Scroler ------------------------*

continue2	lea	bigscrolpil,a6
	movem.l	(a6),d0-d7/a0-a4

	cmp.b	#25,d4
	bhs	next_letter
	add.l	#4,d3
	bra	same_letter

next_letter	moveq	#0,d4
	moveq	#0,d3
	move.b	(a4)+,d3
	cmp.b	#$ff,d3
	bne.s	pas_nul
	lea	mega_text,a4
	move.b	(a4)+,d3
pas_nul	subi.b	#65,d3
	lsl.l	#5,d3		*d3=d3*32*4 (*128)
	lsl.l	#2,d3

same_letter	movea.l	$44e.w,a0
	adda.l	#192*160,a0
	adda.l	#16,a0		*on commenc pas au tt debut
	moveq	#0,d7
	moveq	#0,d6
	move.w	#31,d5		*des bits 15 … 0

	lea	mega_scrol,a3 
	adda.l	d3,a3
	move.l	(a3)+,d0

bigscroller	move.l	a3,bigscrolpil+8*4+3*4
	btst.l	d5,d0
	beq	blanc1_
	subi.l	#1,d5
	btst.l	d5,d0
	beq	blanc2
	move.w	#$ffff,d7
	bsr	bigletters
	bra	boucle

blanc1_	subi.l	#1,d5
	btst.l	d5,d0
	beq	blanc1_2
	move.w	#$ff,d7
	bra	bigscroler2
blanc1_2	move.w	#0,d7
bigscroler2	bsr	bigletters
	bra	boucle

blanc2	move.w	#$ff00,d7
	bsr	bigletters

boucle	adda.l	#8,a0
	dbf	d5,bigscroller

*----------------------------------------------------*

continue3	addq	#1,d4		*fragment lettre suivant

	lea	bigscrolpil,a6
	movem.l	d0-d7/a0-a4,(a6)

	rts

	*bra	continue5

*-----------------------------------------------------------*
*		Background			*
*  Utilise:	a0, a1, a2				*
*-----------------------------------------------------------*

background	lea	backgrndpil,a6
	movem.l	(a6),d0-d7/a0-a4

	moveq	#0,d0
	moveq	#0,d1
	lea	backgrnd,a0
	movea.l	$44e.w,a2
	move.b	(a1)+,d0
	cmp.b	#$ff,d0
	bne	back2
	lea	backdata,a1
	move.b	(a1)+,d0
back2	move.b	(a1)+,d1
	mulu.w	#80,d0
	lsl.w	#1,d1	
	adda.l	d0,a0
	adda.l	d1,a0

	move.w	#200-1,d2

backcopie	move.w	(a0)+,6(a2)
	move.w	(a0)+,8+6(a2)
	move.w	(a0)+,16+6(a2)
	move.w	(a0)+,24+6(a2)
	move.w	(a0)+,32+6(a2)
	move.w	(a0)+,40+6(a2)
	move.w	(a0)+,48+6(a2)
	move.w	(a0)+,56+6(a2)
	move.w	(a0)+,64+6(a2)
	move.w	(a0)+,72+6(a2)
	move.w	(a0)+,80+6(a2)
	move.w	(a0)+,88+6(a2)
	move.w	(a0)+,96+6(a2)
	move.w	(a0)+,104+6(a2)
	move.w	(a0)+,112+6(a2)
	move.w	(a0)+,120+6(a2)
	move.w	(a0)+,128+6(a2)
	move.w	(a0)+,136+6(a2)
	move.w	(a0)+,144+6(a2)
	move.w	(a0)+,152+6(a2)
	lea	40(a0),a0
	lea	160(a2),a2

	dbf	d2,backcopie

back3	lea	backgrndpil,a6
	movem.l	d0-d7/a0-a4,(a6)
	rts

*-----------------------------------------------------------*
*		Main Scroller		*
* Utilise:	d0, d1.				*
*	a0, a1, a2, a3, a4			*
*-----------------------------------------------------------*

main_scrol	lea	mainscrlpil,a6
	movem.l	(a6),d0-d7/a0-a4

	cmpi.b	#5,d1
	blo	main_scrol3

	moveq	#1,d1		*autre lettre
	moveq	#0,d0
	move.b	(a0)+,d0
	cmpi.b	#$ff,d0
	bne.s	main_scrol2
	lea	maintext,a0
	move.b	(a0)+,d0
main_scrol2	lea	boulfont,a1
	lea	buffer,a2
	*subi.b	#65,d0

niv_5	cmpi.b	#40,d0
	blo.s	niv_4
	subi.b	#40,d0
	lsl.w	#4,d0
	adda.l	d0,a1
	adda.l	#16*160,a1
	bra.s	main_scrol3

niv_4	cmpi.b	#30,d0
	blo.s	niv_3
	subi.b	#30,d0
	lsl.w	#4,d0
	adda.l	d0,a1
	addq	#6,a1
	bra.s	main_scrol3

niv_3	cmpi.b	#20,d0
	blo.s	niv_2
	subi.b	#20,d0
	lsl.w	#4,d0
	adda.l	d0,a1
	addq	#4,a1
	bra.s	main_scrol3

niv_2	cmpi.b	#10,d0
	blo.s	niv_1
	subi.b	#10,d0
	lsl.w	#4,d0
	adda.l	d0,a1
	addq	#2,a1
	bra.s	main_scrol3

niv_1	lsl.w	#4,d0
	adda.l	d0,a1

main_scrol3
	lea	buffer,a2
	bsr	decal

	cmpi.b	#1,d1
	beq	part1
	cmpi.b	#2,d1
	beq	part2
	cmpi.b	#3,d1
	beq	part3
	bra	part4

main_scrol4	addq.w	#1,d1

	lea	buffer,a2
	*bsr	transfer

	movea.l	$44e.w,a3
	lea	buffer,a2

	bsr	clear
	bra	continue4	

*--------------------------------------------------*

part1
p1	set	0
	rept	16
	move.b	p1(a1),p1+157(a2)
p1	set	p1+160
	endr
	bra	main_scrol4

part2
p2	set	0
	rept	16
	move.b	p2+1(a1),p2+157(a2)
p2	set	p2+160
	endr
	bra	main_scrol4

part3
p3	set	0
	rept	16
	move.b	p3+8(a1),p3+157(a2)
p3	set	p3+160
	endr
	bra	main_scrol4

part4
p4	set	0
	rept	16
	move.b	p4+9(a1),p4+157(a2)
p4	set	p4+160
	endr
	bra	main_scrol4


continue4	lea	mainscrlpil,a6
	movem.l	d0-d7/a0-a4,(a6)

	*move.w	#$110,$ffff8240.w

	rts

*-----------------------------------------------------------*
*		Equalizers			*
*-----------------------------------------------------------*

equalizers	lea	equalipil,a6
	movem.l	(a6),d0-d7/a0-a4

	movea.l	equasauv,a0

	move.w	#2,d0
equa
equaoffset	set	0
	rept	16
	clr.w	equaoffset+4+16(a0)
	clr.w	equaoffset+160+4+16(a0)
	clr.w	equaoffset+320+4+16(a0)
	clr.w	equaoffset+480+4+16(a0)
equaoffset	set	equaoffset+8
	endr
	adda.l	#160*8,a0
	dbf	d0,equa

	movea.l	$44e.w,a0
	adda.l	#22*8*160,a0
	move.l	a0,equasauv

	moveq	#0,d0
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	
	andi.w	#$f,d0

equatrace
offs	set	0
	rept	4
	move.w	#65535,offs+4+16(a0)
offs	set	offs+160
	endr	
	addq.w	#8,a0

	dbf	d0,equatrace

	movea.l	$44e.w,a0
	adda.l	#23*8*160,a0
	
	moveq	#0,d0
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0

	andi.w	#$f,d0

equatrace2
offs2	set	0
	rept	4
	move.w	#65535,offs2+4+16(a0)
offs2	set	offs2+160
	endr
	addq.w	#8,a0
	dbf	d0,equatrace2

	movea.l	$44e.w,a0
	adda.l	#24*8*160,a0
	moveq	#0,d0
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,d0

	andi.w	#$f,d0

equatrace3
offs3	set	0
	rept	4
	move.w	#65535,offs3+4+16(a0)
offs3	set	offs3+160
	endr
	addq.w	#8,a0

	dbf	d0,equatrace3
	
finito	lea	equalipil,a6
	movem.l	d0-d7/a0-a4,(a6)

	*move.w	#$040,$ffff8240.w
	rts

*-----------------------------------------------------------*
*		Routine Hbl			*
*-----------------------------------------------------------*

hbl
	move.l	(a5),$ffff8248.w	*48 - 4a (astuce!)
	move.l	(a5),$ffff8258.w	*58 - 5a
	move.l	(a5),$ffff824c.w	*4c - 4e
	move.l	(a5)+,$ffff825c.w	*5c - 5e
	move.w	(a5)+,$ffff8242.w	*ptits scrolers

	bclr.b	#0,$fffffa0f.w
	rte

continue5	move.b	$fffffc02.w,d0

	*cmp.b	#$01,d0
	*bne.s	continue6
	*move.w	#$20,$ffff8240.w

continue6	cmp.b	#$39,d0
	beq.s	the_end

	bra	debut

the_end	move.w	#120,d7
*pauuuuuse	dbf	d7,pauuuuuse

	clr.l	$4d2
	jsr	music

	move.w	#$2700,sr		*on stoppe le Timer B
	move.l	sauvhbl,$120.w
	move.b	mfp7,$fffffa07.w
	move.b	mfp9,$fffffa09.w
	move.w	#$2300,sr

	move.b	#8,$fffffc02.w

	lea	savepalet,a0
	lea	$ffff8240.w,a1
	rept	16
	move.l	(a0)+,(a1)+
	endr

	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp

	move.w	#7,-(sp)
	move.w	#2,-(sp)
	trap	#1
	lea	4(sp),sp

	move.w	saverez,-(sp)
	move.l	saveadrecr,-(sp)
	move.l	saveadrecr,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.l	libermem,-(sp)
	move.w	#$49,-(sp)
	trap	#14
	lea	6(sp),sp

	clr.w	-(sp)
	trap	#1

bigletters	move.l	a0,sauv_a0

offset2	set	0
	rept	8
	move.w	d7,2+offset2(a0)
offset2	set	offset2+160
	endr

	suba.l	#32000+8*160,a0

offset3	set	0
	rept	8
	move.w	d7,2+offset3(a0)
offset3	set	offset3+160
	endr
	move.l	sauv_a0,a0
	rts

*-----------------------------------------------------------*
*		Logo The Wonderboys		*
*-----------------------------------------------------------*

logo	lea	logopil,a6
	movem.l	(a6),d0-d7/a0-a4

	movea.l	$44e.w,a0
	lea	savelogo,a3
	*lea	logo_dist,a1
	lea	logo_twb,a2
	move.w	#14-1,d0

logo_affich	move.w	(a4)+,d1
	cmpi.w	#65535,d1
	bne.s	logo_aff2
	lea	logo_dist,a4
	move.w	(a4)+,d1

logo_aff2	subi.w	#1,d1
	mulu.w	#160,d1
	adda.w	d1,a0
	move.l	a0,(a3)+


logoff	set	0
	rept	15
	move.w	logoff+24(a2),logoff+24+4(a0)
logoff	set	logoff+160
	endr

	lea	8(a2),a2
	lea	8(a0),a0
	suba.w	d1,a0

	dbf	d0,logo_affich

	lea	-26(a4),a4

	lea	logopil,a6
	movem.l	d0-d7/a0-a4,(a6)

	*move.w	#$400,$ffff8240.w

	rts

*---------------- Effacement du logo --------------------*
logocl	lea	logoclpil,a6
	movem.l	(a6),d0-d7/a0-a4

	lea	savelogo,a0

	move.l	#14-1,d0

logoclear	movea.l	(a0)+,a1
	clr.w	24+4(a1)
	clr.w	24+160+4(a1)
	clr.w	24+320+4(a1)
	clr.w	24+480+4(a1)
	clr.w	24+640+4(a1)
	clr.w	24+800+4(a1)
	clr.w	24+960+4(a1)
	clr.w	24+1120+4(a1)
	clr.w	24+1280+4(a1)
	clr.w	24+1440+4(a1)
	clr.w	24+1600+4(a1)
	clr.w	24+1760+4(a1)
	clr.w	24+1920+4(a1)
	clr.w	24+2080+4(a1)
	clr.w	24+2240+4(a1)

	dbf	d0,logoclear

	lea	logoclpil,a6
	movem.l	d0-d7/a0-a4,(a6)

	rts

*-----------------------------------------------------------*
*	Routine de decalage pour le mainscroller	*
*-----------------------------------------------------------*

decal
d	set	0
	rept	16
	move.b	d+1+4(a2),d+4(a2)
	move.b	d+8+4(a2),d+1+4(a2)
	move.b	d+9+4(a2),d+8+4(a2)
	move.b	d+16+4(a2),d+9+4(a2)
	move.b	d+17+4(a2),d+16+4(a2)
	move.b	d+24+4(a2),d+17+4(a2)
	move.b	d+25+4(a2),d+24+4(a2)
	move.b	d+32+4(a2),d+25+4(a2)
	move.b	d+33+4(a2),d+32+4(a2)
	move.b	d+40+4(a2),d+33+4(a2)
	move.b	d+41+4(a2),d+40+4(a2)
	move.b	d+48+4(a2),d+41+4(a2)
	move.b	d+49+4(a2),d+48+4(a2)
	move.b	d+56+4(a2),d+49+4(a2)
	move.b	d+57+4(a2),d+56+4(a2)
	move.b	d+64+4(a2),d+57+4(a2)
	move.b	d+65+4(a2),d+64+4(a2)
	move.b	d+72+4(a2),d+65+4(a2)
	move.b	d+73+4(a2),d+72+4(a2)
	move.b	d+80+4(a2),d+73+4(a2)
	move.b	d+81+4(a2),d+80+4(a2)
	move.b	d+88+4(a2),d+81+4(a2)
	move.b	d+89+4(a2),d+88+4(a2)
	move.b	d+96+4(a2),d+89+4(a2)
	move.b	d+97+4(a2),d+96+4(a2)
	move.b	d+104+4(a2),d+97+4(a2)
	move.b	d+105+4(a2),d+104+4(a2)
	move.b	d+112+4(a2),d+105+4(a2)
	move.b	d+113+4(a2),d+112+4(a2)
	move.b	d+120+4(a2),d+113+4(a2)
	move.b	d+121+4(a2),d+120+4(a2)
	move.b	d+128+4(a2),d+121+4(a2)
	move.b	d+129+4(a2),d+128+4(a2)
	move.b	d+136+4(a2),d+129+4(a2)
	move.b	d+137+4(a2),d+136+4(a2)
	move.b	d+144+4(a2),d+137+4(a2)
	move.b	d+145+4(a2),d+144+4(a2)
	move.b	d+152+4(a2),d+145+4(a2)
	move.b	d+153+4(a2),d+152+4(a2)
d	set	d+160
	endr
	rts

*-----------------------------------------------*

transfer	lea	transpil,a6
	movem.l	(a6),d0-d7/a0-a4

	move.l	a0,save_a0		*pour economiser 1 registre

	*move.w	40(a4),d5
	*cmpi.w	#65535,d5
	*bne	transf2
	*lea	v_dist,a4

transf2	moveq	#0,d5
	move.w	#20-1,d4

	movea.l	$44e.w,a3
	lea	buffer,a2
	*lea	v_dist,a4
	lea	rewrite,a0

transfer2
	move.w	(a4)+,d5
	cmpi.w	#65535,d5
	bne.s	transfer2b
	lea	v_dist,a4
	move.w	(a4)+,d5

transfer2b	adda.l	d5,a3
	move.l	a3,(a0)+

t	set	0
	rept	16
	move.w	t+4(a2),t+4(a3)
t	set	t+160
	endr

	lea	8(a2),a2
	lea	8(a3),a3
	suba.l	d5,a3
	dbf	d4,transfer2

	movea.l	save_a0,a0		*on economise un registre
	lea	-38(a4),a4

	lea	transpil,a6
	movem.l	d0-d7/a0-a4,(a6)

	*move.w	#$5,$ffff8240.w
	rts

*-----------------------------------------------*

clear	move.w	#20-1,d4
	lea	rewrite,a2

clear2
	movea.l	(a2)+,a3
cl	set	0
	rept	16
	clr.w	cl+4(a3)
cl	set	cl+160
	endr

	dbf	d4,clear2

	rts

altelp	rts

*-----------------------------------------------*
*	Section Data, BSS		*
*-----------------------------------------------*
	even

scrollers	incbin	'scrolers.bin'

backgrnd	incbin	'back_ska.bin'
	incbin	'back_ska.bin'

logo_twb	incbin	'logo.img'

boulfont	incbin	'boulfnt.bin'
buffer	ds.b	160*16


music	incbin	'mm_shaol.snd'

	even

maintext0	incbin	'maintext.dem'

maintext	incbin	'maintex2.dem'
	dc.b	255

	even
	dc.w	17120,16800,16480,16160,15680,15200,14720,14240,13760,13280,12960
	dc.w	12640,12320,12000,11680,11360,11200,11040,10880,10720
v_dist	dc.w	10560,10560,10720,10880,11040,11200,11360,11680,12000,12320,12640,12960,13280,13760,14240,14720,15200,15680,16160,16480,16800,17120,17440,17760,18080,18240,18400,18560,18720,18880,19040
	dc.w	19040,18880,18720,18560,18400,18240,18080,17760,17440,17120,16800,16480,16160,15680,15200,14720,14240,13760,13280,12960
	dc.w	12640,12320,12000,11680,11360,11200,11040,10880,10720
	dc.w	65535

	even


logo_dist0	dcb.w	1,386
	dc.w	1,2,3,5,7,9,12,15,18,21,25,29,33,38,43,48
	dc.w	48,43,38,33,29,25,21,18,15,12,9,7,5,3,2,1
logo_dist	dc.w	1,2,3,5,7,9,12,15,18,21,25,29,33,38,43,48
	dc.w	43,38,33,29,25,21,18,15,12,9,7,5,3,2
	dc.w	1,2,3,5,7,9,12,15,18,21,25,29,33,38,43,48
	dc.w	43,38,34,30,26,23,20,17,15,13,11,10,9,8
	dc.w	9,10,11,13,15,17,20,23,26,30,34,38,43,48
	dc.w	43,39,35,31,27,24,21,18,16,14,13
	dc.w	13,14,16,18,21,24,27,31,35,39,43,48
	dc.w	44,40,36,33,30,27,25,23,21,20
	dc.w	21,23,25,27,30,33,36,40,44,48
	dc.w	45,42,39,37,35,33,32
	dc.w	33,35,37,39,42,45,48
	dc.w	45,42,40,39,38
	dc.w	39,40,42,45,48
	dc.w	46,45
	dc.w	46,48,47,48
	dcb.w	48,40
	dc.w	47
	rept	8
	dc.w	46,45,43,41,38,35,31,27,23,19,16,13,11,9,8,8
	dc.w	9,11,13,16,19,23,27,31,35,38,41,43,45,46
	endr
	dc.w	47
	dcb.w	48,40
	dc.w	48,47,48,46,45,46,48,45,42,40,39,38,39,40,42,45,48,45,42,39,37,35,33
	dc.w	32,33,35,37,39,42,45,48,44,40,36,33,30,27,25,23,21,20,21,23,25,27,30,33
	dc.w	36,40,44,48,43,39,45,31,27,24,21,18,16,14,13
	dc.w	13,14,16,18,21,24,27,31,35,39,43,48,43,38,34,30,26,23,20,17,15,13
	dc.w	11,10,9,8,9,10,11,13,15,17,20,23,26,30,34,38,43,48,43,38,33,29,25,21,18,15,12
	dc.w	9,7,5,3,2,1,2,3,5,7,9,12,15,18,21,25,29,33,38,43
	dc.w	48,43,38,33,29,25,21,18,15,12,9,7,5,3,2,1

	dc.w	65535

	even

	*dec. vertical, horizontal

backdata0	dcb.w	0,386
backdata	dcb.w	0,20

	dc.b	200,0
	dc.b	199,0,198,0,197,0,196,0,195,0,194,0,193,0,192,0,191,0,190,0
	dc.b	188,0,186,0,184,0,182,0,180,0,178,0,176,0,174,0,172,0,170,0
	dc.b	167,0,164,0,161,0,158,0,155,0,152,0,149,0,146,0,143,0,140,0
	dc.b	136,0,132,0,128,0,124,0,120,0,116,0,112,0,108,0,104,0,100,0
	dc.b	95,0,90,0,85,0,80,0,75,0,70,0,65,0,60,0,55,0,50,0
	dc.b	44,0,38,0,32,0,26,0,20,0,14,0,8,0,2,0,196,0,190,0
	dc.b	183,0,176,0,169,0,162,0,155,0,148,0,141,0,134,0,127,0,120,0
	dc.b	112,0,104,0,96,0,88,0,80,0,72,0,64,0,56,0,48,0,40,0
	dc.b	31,0,22,0,13,0,4,0,195,0,186,0,177,0,168,0,159,0,150,0
	dc.b	140,0,130,0,120,0,110,0,100,0,90,0,80,0,70,0,60,0,50,0
	dc.b	40,0,30,0,20,0,10,0,200,0,190,0,180,0,170,0,160,0,150,0
	dc.b	141,0,132,0,123,0,114,0,105,0,96,0,87,0,78,0,69,0,60,0
	dc.b	52,0,44,0,36,0,28,0,20,0,12,0,4,0,196,0,188,0,180,0
	dc.b	173,0,166,0,159,0,152,0,145,0,138,0,131,0,124,0,117,0,110,0
	dc.b	104,0,98,0,92,0,86,0,80,0,74,0,68,0,62,0,56,0,50,0
	dc.b	45,0,40,0,35,0,30,0,25,0,20,0,15,0,10,0,5,0,0,0
	dc.b	196,0,192,0,188,0,184,0,180,0,176,0,172,0,168,0,164,0,160,0
	dc.b	157,0,154,0,151,0,148,0,145,0,142,0,139,0,136,0,133,0,130,0
	dc.b	128,0,126,0,124,0,122,0,120,0,118,0,116,0,114,0,112,0,110,0
	dc.b	109,0,108,0,107,0,106,0,105,0,104,0,103,0,102,0,101,0,100,0

	rept	20
	dc.b	100,0
	endr

	dc.b	99,0,98,0,97,0,96,0,95,0,94,0,93,0,92,0,91,0,90,0
	dc.b	88,0,86,0,84,0,82,0,80,0,78,0,76,0,74,0,72,0,70,0
	dc.b	67,0,64,0,61,0,58,0,55,0,52,0,49,0,46,0,43,0,40,0
	dc.b	36,0,32,0,28,0,24,0,20,0,16,0,12,0,08,0,04,0,00,0

backk	set	195
backk2	set	1
	rept	20
	dc.b	backk,backk2
backk	set	backk-5
backk2	set	backk2+1
	endr

	dc.b	95,19,90,18,85,17,80,16,75,15,70,14,65,13,60,12,55,11,50,10
	dc.b	44,9,38,8,32,7,26,6,20,5,14,4,8,3,2,2,196,1,190,0
	dc.b	183,19,176,18,169,17,162,16,155,15,148,14,141,13,134,12,127,11,120,10
	dc.b	112,10,104,10,96,10,88,10,80,10,72,10,64,10,56,10,48,10,40,10

	dc.b	31,10,22,10,13,10,4,10,195,10,186,10,177,10,168,10,159,10,150,10
	dc.b	140,9,130,8,120,7,110,6,100,5,90,4,80,3,70,2,60,1,50,0
	dc.b	40,19,30,18,20,17,10,16,200,15,190,14,180,13,170,12,160,11,150,10
	dc.b	141,9,132,8,123,7,114,6,105,5,96,4,87,3,78,2,69,1,60,0

	dc.b	52,0,44,0,36,0,28,0,20,0,12,0,4,0,196,0,188,0,180,0
	dc.b	173,0,166,0,159,0,152,0,145,0,138,0,131,0,124,0,117,0,110,0
	dc.b	104,0,98,0,92,0,86,0,80,0,74,0,68,0,62,0,56,0,50,0
	dc.b	45,1,40,2,35,3,30,4,25,5,20,6,15,7,10,8,5,9,0,10
	dc.b	196,11,192,12,188,13,184,14,180,15,176,16,172,17,168,18,164,19,160,0
	dc.b	157,19,154,18,151,17,148,16,145,15,142,14,139,13,136,12,133,11,130,10
	dc.b	128,9,126,8,124,7,122,6,120,5,118,4,116,3,114,2,112,1,110,0
	dc.b	109,0,108,0,107,0,106,0,105,0,104,0,103,0,102,0,101,0,100,0

	rept	20
	dc.b	100,0
	endr

	dc.b	99,0,98,0,96,0,94,0,91,0,88,1,84,2,80,3,75,4,70,5,64,6,58,7,51,8,44,9
	dc.b	37,10,31,11,25,12,20,13,15,14,11,15,8,16,5,17,3,18,2,19,1,0
	dc.b	2,0,4,0,7,0,12,0,18,0,24,0,31,0,38,0,46,0,54,0,63,0,72,0,82,0,92,0,102,0
	dc.b	111,1,120,2,129,3,137,4,145,5,153,6,160,7,167,8,173,9,178,10,182,11,186,12,189,13,192,14,194,15,196,16,197,17,198,18,199,19,0,0
	
	dcb.w	0,15

b1	set	0
b2	set	0
	rept	20
	dc.b	b1,b2
b1	set	b1+5
b2	set	b2+1
	endr

b3	set	100
b4	set	0
	rept	20
	dc.b	b3,b4
b3	set	b3+5
b4	set	b4+1
	endr

b5	set	0
b6	set	0
	rept	20
	dc.b	b5,b6
b5	set	b5+5
b6	set	b6+1
	endr

b7	set	100
b8	set	0
	rept	20
	dc.b	b7,b8
b7	set	b7+5
b8	set	b8+1
	endr

	dc.b	255

	even

data0	dcb.w	0,1544
data
v	set	0
	rept	2
	dc.w	v
	dc.w	v,v+1
	dc.w	v+3,v+5,v+7
	dc.w	v+10,v+13,v+16,v+19
	dc.w	v+23,v+27,v+31,v+35,v+39
	dc.w	v+44,v+49,v+54,v+59,v+64,v+69
	dc.w	v+75,v+81,v+87,v+93,v+99,v+105,v+111
	dc.w	v+118,v+125,v+132,v+139,v+146,v+153,v+160,v+167
	dc.w	v+175,v+183,v+191,v+199,v+207,v+215,v+224,v+231
	dc.w	v+238,v+245,v+252,v+259
	dc.w	v+265,v+271,v+277
	dc.w	v+282,v+287,v+292
	dc.w	v+296,v+300
	dc.w	v+303,v+306
	dc.w	v+308
	dc.w	v+309
	dc.w	v+308
	dc.w	v+306,v+304
	dc.w	v+301,v+298
	dc.w	v+294,v+290
	dc.w	v+285,v+280,v+275
	dc.w	v+269,v+263,v+257
	dc.w	v+250,v+243,v+236
	dc.w	v+230,v+223,v+216
	dc.w	v+210,v+204,v+198
	dc.w	v+193,v+188,v+183
	dc.w	v+179,v+175
	dc.w	v+172,v+169
	dc.w	v+167,v+165
	dc.w	v+164
v	set	v+165
	endr

	dc.w	330,331,332,334,337,340,344,348,353,358
v2	set	0
	rept	70
	dc.w	v2+364
v2	set	v2+6
	endr
	dc.w	783,788,793,798,803,808
	dc.w	813,817,821,825,829,833
	dc.w	836,839,842,845,848
	dc.w	850,852,854,856
	dc.w	857,858,859
	dc.w	859
	dc.w	860

	dc.w	859
	dc.w	858,857,856,855
	dc.w	853,851,849,847,845
	dc.w	842,839,836,833,830,827
	dc.w	823,819,815,811,807,803,799
	dc.w	794,789,784,779,774,769,764,759
	dc.w	753,747,741,735,729,723,717,711,705
	dc.w	698,691,684,677,670,663,656,659,652,645
	dc.w	639,633,627,621,615,609,603,597,591
	dc.w	586,581,576,571,566,561,556,551
	dc.w	547,543,539,535,531,527,523
	dc.w	520,517,514,511,508,505
	dc.w	503,501,499,497,495
	dc.w	494,493,492,491
	dc.w	490
	dc.w	490
	dc.w	491,492,493,494
	dc.w	495,497,499,501,503,505,508,511,514,517,520
	dc.w	523,527,531,535,539,543,547,551,556,561,566
	dc.w	571,576,581,586,591,597,603,609,615,621,627
	dc.w	633,639,645,652,659,656,663,670,677,684,691
	dc.w	698,705,711,717,723,729,735,741,747,753,759
	dc.w	764,769,774,779,784,789,794,799,803,807,811
	dc.w	815,819,823,827,830,833,836,839,842,845,847
	dc.w	849,851,853,855,856,857,858,859,860

	dc.w	859
	dc.w	858,857,856,855
	dc.w	853,851,849,847,845
	dc.w	842,839,836,833,830,827
	dc.w	823,819,815,811,807,803,799
	dc.w	794,789,784,779,774,769,764,759
	dc.w	753,747,741,735,729,723,717,711,705
	dc.w	698,691,684,677,670,663,656,659,652,645
	dc.w	639,633,627,621,615,609,603,597,591
	dc.w	586,581,576,571,566,561,556,551
	dc.w	547,543,539,535,531,527,523
	dc.w	520,517,514,511,508,505
	dc.w	503,501,499,497,495
	dc.w	494,493,492,491
	dc.w	490
	dc.w	490
	dc.w	491,493,496,500
	dc.w	505,509,512,514
	dc.w	515
	dc.w	514,512,509,506
	dc.w	502,498,494,489,484,480,476,472
	dc.w	469,466,463,461,459,458
	dc.w	459,461,463,466,469,473,477,452,457
	dc.w	462,468,474,479,484,488,492,495,498
	dc.w	500,501

	dc.w	502,504,506,509,512,516,520,525,531
	dc.w	537,544,551,557,563,568,573,577,581
	dc.w	584,587,589,590
	dc.w	589,587,584,580,575,569,562,554,547
	dc.w	541,535,530,526,523,521,520
	dc.w	521,523,527,532,538,545,553,562,572
	dc.w	581,589,596,603,609,614,618,621,623
	dc.w	624
	dc.w	623,621,618,614,609,603,596,588,579
	dc.w	569,558,546,533,520,507,494,481,468
	dc.w	456,444,432,421,410,399,389,379,370
	dc.w	361,352,343,335,327,320,313,316,310
	dc.w	305,300,296,293,291,290,289

v4	set	290
	rept	4
	dc.w	v4
	dc.w	v4,v4+1
	dc.w	v4+3,v4+5,v4+7
	dc.w	v4+10,v4+13,v4+16,v4+19
	dc.w	v4+23,v4+27,v4+31,v4+35,v4+39
	dc.w	v4+44,v4+49,v4+54,v4+59,v4+64,v4+69
	dc.w	v4+75,v4+81,v4+87,v4+93,v4+99,v4+105,v4+111
	dc.w	v4+118,v4+125,v4+132,v4+139,v4+146,v4+153,v4+160,v4+167
	dc.w	v4+175,v4+183,v4+191,v4+199,v4+207,v4+215,v4+224,v4+231
	dc.w	v4+238,v4+245,v4+252,v4+259
	dc.w	v4+265,v4+271,v4+277
	dc.w	v4+282,v4+287,v4+292
	dc.w	v4+296,v4+300
	dc.w	v4+303,v4+306
	dc.w	v4+308
	dc.w	v4+309
	dc.w	v4+308
	dc.w	v4+306,v4+304
	dc.w	v4+301,v4+298
	dc.w	v4+294,v4+290
	dc.w	v4+285,v4+280,v4+275
	dc.w	v4+269,v4+263,v4+257
	dc.w	v4+250,v4+243,v4+236
	dc.w	v4+230,v4+223,v4+216
	dc.w	v4+210,v4+204,v4+198
	dc.w	v4+193,v4+188,v4+183
	dc.w	v4+179,v4+175
	dc.w	v4+172,v4+169
	dc.w	v4+167,v4+165
	dc.w	v4+164
v4	set	v4+165
	endr

v5	set	949
	rept	1
	dc.w	v5
	dc.w	v5,v5+1
	dc.w	v5+3,v5+5,v5+7
	dc.w	v5+10,v5+13,v5+16,v5+19
	dc.w	v5+23,v5+27,v5+31,v5+35,v5+39
	dc.w	v5+44,v5+49,v5+54,v5+59,v5+64,v5+69
	dc.w	v5+75,v5+81,v5+87,v5+93,v5+99,v5+105,v5+111
	dc.w	v5+118,v5+125,v5+132,v5+139,v5+146,v5+153,v5+160,v5+167
	dc.w	v5+175,v5+183,v5+191,v5+199,v5+207,v5+215,v5+224,v5+231
	dc.w	v5+238,v5+245,v5+252,v5+259
	dc.w	v5+265,v5+271,v5+277
	dc.w	v5+282,v5+287,v5+292
	dc.w	v5+296,v5+300
	dc.w	v5+303,v5+306
	dc.w	v5+308
	dc.w	v5+309
	endr
	
	dc.w	65535

hblcolors	dc.l	$100010
	dc.w	$77
	dc.l	$200020
	dc.w	$77
	dc.l	$300030
	dc.w	$66
	dc.l	$400040
	dc.w	$66
	dc.l	$500050
	dc.w	$66
	dc.l	$600060
	dc.w	$55
	dc.l	$700070
	dc.w	$55
	dc.l	$700070
	dc.w	$55
	dc.l	$600060
	dc.w	$44
	dc.l	$500050
	dc.w	$44
	dc.l	$400040
	dc.w	$44
	dc.l	$300030
	dc.w	$33
	dc.l	$200020
	dc.w	$33
	dc.l	$100010
	dc.w	$33
	dc.l	$000000
	dc.w	$33
	dc.l	$70007
	dc.w	$22
	dc.l	$70007
	dc.w	$22
	dc.l	$60006
	dc.w	$22
	dc.l	$50005
	dc.w	$11
	dc.l	$40004
	dc.w	$11
	dc.l	$30003
	dc.w	$11
	dc.l	$20002
	dc.w	$11
	dc.l	$10001
	dc.w	$11
	dc.l	$00000
	dc.w	$11
	dc.l	$10001
	dc.w	$22
	dc.l	$20002
	dc.w	$22
	dc.l	$30003
	dc.w	$22
	dc.l	$40004
	dc.w	$33
	dc.l	$50005
	dc.w	$33
	dc.l	$60006
	dc.w	$33
	dc.l	$70007
	dc.w	$44
	dc.l	$60006
	dc.w	$44
	dc.l	$50005
	dc.w	$44
	dc.l	$40004
	dc.w	$55
	dc.l	$30003
	dc.w	$55
	dc.l	$00000
	dc.w	$55
	dc.l	$10001
	dc.w	$66
	dc.l	$20002
	dc.w	$66
	dc.l	$30003
	dc.w	$66
	dc.l	$40004
	dc.w	$77
	dc.l	$50005
	dc.w	$77
	dc.l	$60006
	dc.w	$77
	dc.l	$04040404
	dc.w	$66
	dc.l	$02020202		*equalizer haut
	dc.w	$66
	dc.l	$02020202
	dc.w	$66
	dc.l	$03030303		*milieu
	dc.w	$66
	dc.l	$03030303
	dc.w	$55
	dc.l	$04040404		*bas
	dc.w	$55
	dc.l	$04040404
	dc.w	$55
	dc.l	$00000000
	dc.w	$44

	even
mfp7	ds.b	1
mfp9	ds.b	1

	even
ecrttst	ds.l	1
ecrttst2	ds.l	1
libermem	ds.l	1
saveadrecr	ds.l	1
saverez	ds.w	1
savepalet	ds.w	20
sauvhbl	ds.l	1

smallpil	ds.l	14
logoclpil	ds.l	14
savelogo	ds.l	14		*14 mots de large
logopil	ds.l	14
adr_scr	ds.l	1
bigscrolpil	ds.l	14
scrolerspil	ds.l	14
backgrndpil	ds.l	14
mainscrlpil	ds.l	14
equalipil	ds.l	14
transpil	ds.l	14
sav	ds.l	14
sauv_a0	ds.l	1
save_a0	ds.l	1		*economiser un registre!
rewrite	ds.l	20
equasauv	ds.l	1

	even

mega_text0	rept	77
	dc.b	111
	endr
mega_text	incbin	'megatext.dem'
	dc.b	255

	even 

mega_scrol	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000101111111100000000000
	dc.l	%00000000000101111111100000000000
	dc.l	%00000000001100111111110000000000
	dc.l	%00000000001000111111110000000000
	dc.l	%00000000011000011111111000000000
	dc.l	%00000000010000011111111000000000
	dc.l	%00000000110000001111111100000000
	dc.l	%00000000100000001111111100000000
	dc.l	%00000001100000000111111110000000
	dc.l	%00000001000000000111111110000000
	dc.l	%00000011000000000011111111000000
	dc.l	%00000010111111111111111111000000
	dc.l	%00000110000000000001111111100000
	dc.l	%00000100000000000001111111100000
	dc.l	%00001100000000000000111111110000
	dc.l	%00001000000000000000111111110000
	dc.l	%00011000000000000000011111111000
	dc.l	%00010000000000000000011111111000
	dc.l	%00110000000000000000001111111100
	dc.l	%00110000000000000000001111111100
	dc.l	%11111100000000000000111111111111
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111111111111111000000000
	dc.l	%00111111110000000111111111100000
	dc.l	%00111111110000000000111111111000
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000111111111000
	dc.l	%00111111110000000111111111100000
	dc.l	%00111111110011111111111110000000
	dc.l	%00111111110000000111111111100000
	dc.l	%00111111110000000000111111111000
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000111111111000
	dc.l	%00111111110000000111111111100000
	dc.l	%11111111111111111111111000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000011111111100111111111110
	dc.l	%00000001111111100000000011111110
	dc.l	%00000111111110000000000000111110
	dc.l	%00001111111100000000000000011110
	dc.l	%00011111111000000000000000001110
	dc.l	%00111111111000000000000000000110
	dc.l	%00111111110000000000000000000010
	dc.l	%01111111110000000000000000000010
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111110000000000000000000010
	dc.l	%00111111110000000000000000000010
	dc.l	%00111111111000000000000000000110
	dc.l	%00011111111000000000000000001110
	dc.l	%00001111111100000000000000011110
	dc.l	%00000111111110000000000000111110
	dc.l	%00000001111111100000000011111110
	dc.l	%00000000011111111100111111111110
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111111111111111000000000
	dc.l	%00111111110000000111111110000000
	dc.l	%00111111110000000001111111100000
	dc.l	%00111111110000000000111111110000
	dc.l	%00111111110000000000011111111000
	dc.l	%00111111110000000000011111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000001111111110
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000011111111100
	dc.l	%00111111110000000000011111111000
	dc.l	%00111111110000000000111111110000
	dc.l	%00111111110000000001111111100000
	dc.l	%00111111110000000111111110000000
	dc.l	%11111111111111111111111000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111111111100111111111110
	dc.l	%00111111110000000000000011111110
	dc.l	%00111111110000000000000000111110
	dc.l	%00111111110000000000000000011110
	dc.l	%00111111110000000000000000001110
	dc.l	%00111111110000000000000000000110
	dc.l	%00111111110000000000010000000010
	dc.l	%00111111110000000000010000000010
	dc.l	%00111111110000000000110000000000
	dc.l	%00111111110000000001110000000000
	dc.l	%00111111110000000111110000000000
	dc.l	%00111111111111111111110000000000
	dc.l	%00111111110000000111110000000000
	dc.l	%00111111110000000001110000000000
	dc.l	%00111111110000000000110000000000
	dc.l	%00111111110000000000010000000000
	dc.l	%00111111110000000000010000000010
	dc.l	%00111111110000000000000000000010
	dc.l	%00111111110000000000000000000110
	dc.l	%00111111110000000000000000001110
	dc.l	%00111111110000000000000000011110
	dc.l	%00111111110000000000000000111110
	dc.l	%00111111110000000000000011111110
	dc.l	%11111111111111111100111111111110
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111111111100111111111110
	dc.l	%00111111110000000000000011111110
	dc.l	%00111111110000000000000000111110
	dc.l	%00111111110000000000000000011110
	dc.l	%00111111110000000000000000001110
	dc.l	%00111111110000000000000000000110
	dc.l	%00111111110000000000010000000010
	dc.l	%00111111110000000000010000000010
	dc.l	%00111111110000000000110000000000
	dc.l	%00111111110000000001110000000000
	dc.l	%00111111110000000111110000000000
	dc.l	%00111111111111111111110000000000
	dc.l	%00111111110000000111110000000000
	dc.l	%00111111110000000001110000000000
	dc.l	%00111111110000000000110000000000
	dc.l	%00111111110000000000010000000000
	dc.l	%00111111110000000000010000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%11111111111100000000000000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000011111111100111111111110
	dc.l	%00000001111111100000000011111110
	dc.l	%00000111111110000000000000111110
	dc.l	%00001111111100000000000000011110
	dc.l	%00011111111000000000000000001110
	dc.l	%00111111111000000000000000000110
	dc.l	%00111111110000000000000000000010
	dc.l	%01111111110000000000000000000010
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000000000000000000
	dc.l	%01111111100000000011111111111111
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111110000000000001111111110
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111111000000000011111111100
	dc.l	%00011111111000000000011111111000
	dc.l	%00001111111100000000111111110000
	dc.l	%00000111111110000001111111100000
	dc.l	%00000001111111100111111110000000
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111100000000111111111111
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111111111111111111111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%11111111111100000000111111111111
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000001111111111110000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000001111111111110000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000000000000000111111111111
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00011111111000000000011111111000
	dc.l	%00011111111000000000011111111000
	dc.l	%00001111111100000000111111110000
	dc.l	%00001111111100000000111111110000
	dc.l	%00000111111111000011111111100000
	dc.l	%00000001111111100111111110000000
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111100000000000000111111
	dc.l	%00111111110000000000000000011100
	dc.l	%00111111110000000000000001110000
	dc.l	%00111111110000000000000111000000
	dc.l	%00111111110000000000011100000000
	dc.l	%00111111110000000001110000000000
	dc.l	%00111111110000000111000000000000
	dc.l	%00111111110000011100000000000000
	dc.l	%00111111110001110000000000000000
	dc.l	%00111111110111111000000000000000
	dc.l	%00111111111111111100000000000000
	dc.l	%00111111110111111110000000000000
	dc.l	%00111111110011111111000000000000
	dc.l	%00111111110001111111100000000000
	dc.l	%00111111110000111111110000000000
	dc.l	%00111111110000011111111000000000
	dc.l	%00111111110000001111111100000000
	dc.l	%00111111110000000111111110000000
	dc.l	%00111111110000000011111111000000
	dc.l	%00111111110000000001111111100000
	dc.l	%00111111110000000000111111110000
	dc.l	%00111111110000000000011111111000
	dc.l	%00111111110000000000001111111100
	dc.l	%11111111111100000000111111111111
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111100000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000010
	dc.l	%00111111110000000000000000000010
	dc.l	%00111111110000000000000000000110
	dc.l	%00111111110000000000000000001110
	dc.l	%00111111110000000000000000011110
	dc.l	%00111111110000000000000000111110
	dc.l	%00111111110000000000000011111110
	dc.l	%11111111111111111100111111111110
	dc.l	0
	dcb.l	0,7

	dc.l	%00111110000000000000111111111111
	dc.l	%00011111000000000000011111111100
	dc.l	%00011111100000000000111111111100
	dc.l	%00011111110000000001101111111100
	dc.l	%00011111111000000011001111111100
	dc.l	%00011111111100000110001111111100
	dc.l	%00011111111110001100001111111100
	dc.l	%00011011111111011000001111111100
	dc.l	%00011001111111110000001111111100
	dc.l	%00011000111111100000001111111100
	dc.l	%00011000011111000000001111111100
	dc.l	%00011000001110000000001111111100
	dc.l	%00011000000100000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00111100000000000000001111111100
	dc.l	%11111111000000000000111111111111
	dc.l	0
	dcb.l	0,7

	dc.l	%00111111111000000000000011111111
	dc.l	%00011111111100000000000000111100
	dc.l	%00011111111110000000000000011000
	dc.l	%00011111111111000000000000011000
	dc.l	%00011111111111100000000000011000
	dc.l	%00011111111111110000000000011000
	dc.l	%00011011111111111000000000011000
	dc.l	%00011001111111111100000000011000
	dc.l	%00011000111111111110000000011000
	dc.l	%00011000011111111111000000011000
	dc.l	%00011000001111111111100000011000
	dc.l	%00011000000111111111110000011000
	dc.l	%00011000000011111111111000011000
	dc.l	%00011000000001111111111100011000
	dc.l	%00011000000000111111111110011000
	dc.l	%00011000000000011111111111011000
	dc.l	%00011000000000001111111111111000
	dc.l	%00011000000000000111111111111000
	dc.l	%00011000000000000011111111111000
	dc.l	%00011000000000000001111111111000
	dc.l	%00011000000000000000111111111000
	dc.l	%00011000000000000000011111111000
	dc.l	%00111100000000000000001111111000
	dc.l	%11111111000000000000000111111100
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000011111100111111000000000
	dc.l	%00000001111111100111111110000000
	dc.l	%00000111111110000001111111100000
	dc.l	%00001111111100000000111111110000
	dc.l	%00011111111000000000011111111000
	dc.l	%00111111111000000000011111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%01111111110000000000001111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111110000000000001111111110
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111111000000000011111111100
	dc.l	%00011111111000000000011111111000
	dc.l	%00001111111100000000111111110000
	dc.l	%00000111111110000001111111100000
	dc.l	%00000001111111100111111110000000
	dc.l	%00000000011111100111111000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111111111111111000000000
	dc.l	%00111111110000000111111111100000
	dc.l	%00111111110000000000111111111000
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000111111110000
	dc.l	%00111111110000000111111111000000
	dc.l	%00111111110011111111111100000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%00111111110000000000000000000000
	dc.l	%11111111111100000000000000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000011111100111111000000000
	dc.l	%00000001111111100111111110000000
	dc.l	%00000111111110000001111111100000
	dc.l	%00001111111100000000111111110000
	dc.l	%00011111111000000000011111111000
	dc.l	%00111111111000000000011111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%01111111110000000000001111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000000000111111110
	dc.l	%01111111100000000001100111111110
	dc.l	%01111111100000000111110111111110
	dc.l	%01111111110000001111111111111110
	dc.l	%00111111110000001111111111111100
	dc.l	%00111111111000000111111111111100
	dc.l	%00011111111000000011111111111000
	dc.l	%00001111111100000001111111110000
	dc.l	%00000111111110000001111111100000
	dc.l	%00000001111111100111111111111000
	dc.l	%00000000011111100111111001111110
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111111111111111000000000
	dc.l	%00111111110000000111111111100000
	dc.l	%00111111110000000000111111111000
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000000111111110
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000111111111000
	dc.l	%00111111110000000011111111100000
	dc.l	%00111111110011111111111110000000
	dc.l	%00111111110011111111000000000000
	dc.l	%00111111110001111111100000000000
	dc.l	%00111111110000111111110000000000
	dc.l	%00111111110000011111111000000000
	dc.l	%00111111110000001111111100000000
	dc.l	%00111111110000000111111110000000
	dc.l	%00111111110000000011111111000000
	dc.l	%00111111110000000001111111100000
	dc.l	%00111111110000000000111111110000
	dc.l	%00111111110000000000011111111000
	dc.l	%00111111110000000000001111111100
	dc.l	%11111111111100000000111111111111
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000111111111100111111111110
	dc.l	%00001111111111000000000011111110
	dc.l	%00111111111000000000000000111110
	dc.l	%01111111100000000000000000011110
	dc.l	%11111111000000000000000000001110
	dc.l	%11111111000000000000000000000110
	dc.l	%11111111000000000000000000000010
	dc.l	%11111111000000000000000000000010
	dc.l	%01111111100000000000000000000000
	dc.l	%00111111111000000000000000000000
	dc.l	%00001111111111000000000000000000
	dc.l	%00000000111111111111111110000000
	dc.l	%00000000000000000111111111100000
	dc.l	%00000000000000000000111111111000
	dc.l	%00000000000000000000001111111100
	dc.l	%00000000000000000000000111111110
	dc.l	%10000000000000000000000111111110
	dc.l	%10000000000000000000000111111110
	dc.l	%11000000000000000000000111111110
	dc.l	%11100000000000000000000111111110
	dc.l	%11110000000000000000001111111100
	dc.l	%11111000000000000000111111111000
	dc.l	%11111110000000000111111111100000
	dc.l	%11111111111001111111110000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111110011111111001111111111
	dc.l	%11111110000011111111000001111111
	dc.l	%11111000000011111111000000011111
	dc.l	%11110000000011111111000000001111
	dc.l	%11100000000011111111000000000111
	dc.l	%11000000000011111111000000000011
	dc.l	%10000000000011111111000000000001
	dc.l	%10000000000011111111000000000001
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000001111111111110000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111111100000000111111111111
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00111111110000000000001111111100
	dc.l	%00011111111000000000011111111000
	dc.l	%00011111111000000000011111111000
	dc.l	%00001111111100000000111111110000
	dc.l	%00001111111100000000111111110000
	dc.l	%00000111111111000011111111100000
	dc.l	%00000001111111100111111110000000
	dc.l	0
	dcb.l	0,7

	dc.l	%11111100000000000000111111111111
	dc.l	%00110000000000000000001111111100
	dc.l	%00110000000000000000001111111100
	dc.l	%00010000000000000000011111111000
	dc.l	%00011000000000000000011111111000
	dc.l	%00001000000000000000111111110000
	dc.l	%00001100000000000000111111110000
	dc.l	%00000100000000000001111111100000
	dc.l	%00000110000000000001111111100000
	dc.l	%00000010000000000011111111000000
	dc.l	%00000011000000000011111111000000
	dc.l	%00000001000000000111111110000000
	dc.l	%00000001100000000111111110000000
	dc.l	%00000000100000001111111100000000
	dc.l	%00000000110000001111111100000000
	dc.l	%00000000010000011111111000000000
	dc.l	%00000000011000011111111000000000
	dc.l	%00000000001000111111110000000000
	dc.l	%00000000001100111111110000000000
	dc.l	%00000000000101111111100000000000
	dc.l	%00000000000111111111100000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111000000000000111111111111
	dc.l	%00111100000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000000000000001111111100
	dc.l	%00011000000100000000001111111100
	dc.l	%00011000001110000000001111111100
	dc.l	%00011000011111000000001111111100
	dc.l	%00011000111111100000001111111100
	dc.l	%00011001111111110000001111111100
	dc.l	%00011011111111011000001111111100
	dc.l	%00011111111110001100001111111100
	dc.l	%00011111111100000110001111111100
	dc.l	%00011111111000000011001111111100
	dc.l	%00011111110000000001101111111100
	dc.l	%00011111100000000000111111111100
	dc.l	%00011111000000000000011111111100
	dc.l	%00111110000000000000111111111111
	dc.l	0
	dcb.l	0,7

	dc.l	%11111111110000000000000011111000
	dc.l	%01111111100000000000000001100000
	dc.l	%00111111110000000000000011000000
	dc.l	%00011111111000000000000110000000
	dc.l	%00001111111100000000001100000000
	dc.l	%00000111111110000000011000000000
	dc.l	%00000011111111000000110000000000
	dc.l	%00000001111111100001100000000000
	dc.l	%00000000111111110011000000000000
	dc.l	%00000000011111111010000000000000
	dc.l	%00000000001111111100000000000000
	dc.l	%00000000000111111110000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000001111111100000000000
	dc.l	%00000000000110111111110000000000
	dc.l	%00000000001100011111111000000000
	dc.l	%00000000011000001111111100000000
	dc.l	%00000000110000000111111110000000
	dc.l	%00000001100000000011111111000000
	dc.l	%00000011000000000001111111100000
	dc.l	%00000110000000000000111111110000
	dc.l	%00001100000000000000011111111000
	dc.l	%00011000000000000000001111111100
	dc.l	%01111100000000000000111111111111
	dc.l	0
	dcb.l	0,7

	dc.l	%11111100000000000000111111111111
	dc.l	%00111000000000000000001111111100
	dc.l	%00001100000000000000011111111000
	dc.l	%00000110000000000000111111110000
	dc.l	%00000011000000000001111111100000
	dc.l	%00000001100000000011111111000000
	dc.l	%00000000110000000111111110000000
	dc.l	%00000000011000001111111100000000
	dc.l	%00000000001100011111111000000000
	dc.l	%00000000000110111111110000000000
	dc.l	%00000000000011111111100000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000000011111111000000000000
	dc.l	%00000000001111111111110000000000
	dc.l	0
	dcb.l	0,7
	
	dc.l	%11111111111100111111111111111110
	dc.l	%11111110000000000000111111111110
	dc.l	%11111000000000000000111111111100
	dc.l	%11110000000000000001111111111000
	dc.l	%11100000000000000011111111110000
	dc.l	%11000000000000000111111111100000
	dc.l	%10000000000000001111111111000000
	dc.l	%10000000000000011111111110000000
	dc.l	%00000000000000111111111100000000
	dc.l	%00000000000001111111111000000000
	dc.l	%00000000000011111111110000000000
	dc.l	%00000000000111111111100000000000
	dc.l	%00000000001111111111000000000000
	dc.l	%00000000011111111110000000000000
	dc.l	%00000000111111111100000000000000
	dc.l	%00000001111111111000000000000000
	dc.l	%00000011111111110000000000000010
	dc.l	%00000111111111100000000000000010
	dc.l	%00001111111111000000000000000110
	dc.l	%00011111111110000000000000001110
	dc.l	%00111111111100000000000000011110
	dc.l	%01111111111000000000000000111110
	dc.l	%11111111111000000000000011111110
	dc.l	%11111111111111111100111111111110
	dc.l	0
	dcb.l	0,7

	dcb.l	0,25			*espace (blanc)
	dcb.l	0,7

	dc.l	%00000000000001111100000000000000	*point !
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000111111111000000000000
	dc.l	%00000000000111111111000000000000
	dc.l	%00000000000111111111000000000000
	dc.l	%00000000000111111111000000000000
	dc.l	%00000000000111111111000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000000111000000000000000
	dc.l	%00000000000000111000000000000000
	dc.l	%00000000000000111000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000111000000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000000111000000000000000
	dc.l	0
	dcb.l	0,7

	dcb.l	0,18			*point
	dc.l	%00000000000000111000000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000000111000000000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000011111111111111000000000
	dc.l	%00000111111111100111111111100000
	dc.l	%00011111111100000000111111111000
	dc.l	%00111111111000000000011111111100
	dc.l	%01111111110000000000001111111110
	dc.l	%01111111110000000000001111111110
	dc.l	%00000000000000000000001111111110
	dc.l	%00000000000000000000001111111110
	dc.l	%00000000000000000000011111111100
	dc.l	%00000000000000000001111111110000
	dc.l	%00000000000000001111111111000000
	dc.l	%00000000000111111111110000000000
	dc.l	%00000000000111111110000000000000
	dc.l	%00000000000111111110000000000000
	dc.l	%00000000000111111110000000000000
	dc.l	%00000000000111111110000000000000
	dc.l	%00000000000111111110000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000111000000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000000111000000000000000
	dc.l	0
	dcb.l	0,7

	dc.l	%00000000000000011111000000000000
	dc.l	%00000000000000111111100000000000
	dc.l	%00000000000000111111100000000000
	dc.l	%00000000000000111111100000000000
	dc.l	%00000000000000111111100000000000
	dc.l	%00000000000000111111000000000000
	dc.l	%00000000000000111111000000000000
	dc.l	%00000000000000111110000000000000
	dc.l	%00000000000000111110000000000000
	dc.l	%00000000000000111100000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000001111000000000000000
	dc.l	%00000000000001111000000000000000
	dcb.l	0,12
	dcb.l	0,7

	dcb.l	0,5
	rept	2
	dc.l	%00000000000000111000000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000000111000000000000000
	dcb.l	0,4
	endr

	dcb.l	0,16
	dc.l	%00000000000000111000000000000000
	dc.l	%00000000000001111100000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000011111110000000000000
	dc.l	%00000000000111111110000000000000
	dc.l	%00000000000111111100000000000000
	dc.l	%00000000001111100000000000000000
	dc.l	%00000000111000000000000000000000
	dc.l	0

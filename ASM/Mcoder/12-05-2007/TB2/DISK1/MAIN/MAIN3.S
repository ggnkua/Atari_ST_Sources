
*	si un jour quelqu'un trouve ce main menu bien cod‚ , 
*	ce ne sera pas moi.........

help:	equ	1	* 0 = help=>inverse

nb_depl_sans_coll	equ	1

musique:	equ	1	* 0 = pas de zik

clav:	equ	0	* 0 = joy the stick

distance:	equ	10

nbli:	equ	2
ligne:	equ	17
colonne:	equ	28

rec1:	equ	16
rec2:	equ	16

	opt	o+
	opt	w-
	opt	x+

vsync:	macro
	move.l	$466.w,d0
.lo\@:
	cmp.l	$466.w,d0
	beq.s	.lo\@
	endm


NDAV	equ	3+1
NAV	equ	8	; Nbr d'octets par boucle


essai	equ	0	* don't touch : debugging du hardware

ecart	equ	12 	* a diminuer si la vbl saute !
			* ou si le module fait "cccchhhhhhuuuu"
			* 22 a l'origine
debut	equ	1356-36-160*4-16*24	* don't touch dis !!


* routine 1 = 230 octets	
* routine 2 = 158 octets
* routine 3 = 186 octets	 
* routine 4 = 184 octets	
* routine 5 = 160 octets
* routine 6 = 204 octets	 


Labyrinth:

	move.w	sr,d0
	btst	#13,d0
	bne.s	.passup

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
.passup:

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol

	movem.l	noir,d0-d7
	movem.l	d0-d7,$ffff8240.w



	move.w	#0,$33c.w
	move.w	#0,$342.w
	move.w	#0,$344.w
	move.w	#$4321,$326.w

	cmp.l	#'KATY',$4000.w
	bne.s	.ok1
*	jsr	clearbss
	jsr	from4000tobss
	bra	recol
.ok1:
	move.l	$70.w,svbl
	jsr	save4000to4600

	jsr	init_tab

	move.l	ptmap,d0
	sub.l	#map,d0
	divu	#28,d0
	mulu	#16,d0
	move.w	d0,posyecr
	add.w	posy,d0
	move.w	d0,posynr
	move.w	posx,posxnr


	lea	posx1,a0
	move.w	posx,d0
	move.w	posy,d1
	move.w	#9,d6
loop5:
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq.l	#2,a0
	dbf	d6,loop5

	move.w	posxnr,listco
	move.w	posynr,listco+2

	move.w	posxnr,listco+400
	move.w	posynr,listco+402

	addq.l	#4,ptlistco

	move.l	#fond,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,ecr_fond

	jsr	make_fond

recol:
	lea	listdemo,a0
	lea	map,a1

	move.w	(a0)+,d0		* x
	move.w	(a0)+,d1		* y

	tst.w	2(a0)
	bne.s	.lm1

	mulu	#28,d1
	add.w	d0,d1

	move.l	a1,a2
	adda.w	d1,a2

	move.b	#242,(a2)

.lm1
	addq.w	#4,a0

	move.w	(a0)+,d0		* x
	move.w	(a0)+,d1		* y

	tst.w	2(a0)
	bne.s	.lm2

	mulu	#28,d1
	add.w	d0,d1

	move.l	a1,a2
	adda.w	d1,a2

	move.b	#241,(a2)

	addq.w	#4,a0

.lm2
	move.w	#9,d7
loop14:
	move.w	(a0)+,d0		* x
	move.w	(a0)+,d1		* y

	tst.w	2(a0)
	bne.s	.lm3

	mulu	#28,d1
	add.w	d0,d1

	move.l	a1,a2
	adda.w	d1,a2

	move.b	#240,(a2)
.lm3:
	addq.w	#4,a0

	dbf	d7,loop14
	
	lea	fmap-(ligne*colonne),a0
	lea	map-(ligne*colonne),a1
	move.w	#(ligne*colonne)-1,d0
.loop14441:
	move.b	(a0)+,(a1)+
	dbf	d0,.loop14441
	

	move.b	#$12,$fffffc02.w

	move.l	#vbld,$70.w
	vsync
	move.b	#0,$ffff8260.w
	vsync

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,ecr1
	add.l	#ligne*16*230+nbli*230,d0
	move.l	d0,ecr2
	add.l	#ligne*16*230+nbli*230,d0
	move.l	d0,ecr3

	move.l	ecr1,d0
	sub.l	#ligne*16*230+nbli*230,d0
	move.l	d0,ecr4

	move.l	ecr1,haut
	move.l	ecr4,haut2
	move.l	ecr3,bas

	move.l	ecr3,d0
	add.l	#ligne*16*230+nbli*230,d0
	move.l	d0,bas2

	move.b	ecr1+1,$ffff8201.w
	move.b	ecr1+2,$ffff8203.w
t2:


	bsr	fill

	move.l	#vidos,sauvefond11
	move.l	#vidos,sauvefond12

	move.l	#vidos,sauvefond21
	move.l	#vidos,sauvefond22

	move.l	#vidos,sauvefond31
	move.l	#vidos,sauvefond32

	move.l	#vidos,sauvefond41
	move.l	#vidos,sauvefond42

	move.l	#vidos,sauvefond51
	move.l	#vidos,sauvefond52

	move.l	#vidos,sauvefond61
	move.l	#vidos,sauvefond62

	move.l	#vidos,sauvefond71
	move.l	#vidos,sauvefond72

	move.l	#vidos,sauvefond81
	move.l	#vidos,sauvefond82

	move.l	#vidos,sauvefond91
	move.l	#vidos,sauvefond92

	move.l	#vidos,sauvefond101
	move.l	#vidos,sauvefond102

	move.w	#1,activ1
*	move.w	#1,activ2
*	move.w	#1,activ3
*	move.w	#1,activ4
*	move.w	#1,activ5
*	move.w	#1,activ6
*	move.w	#1,activ7
*	move.w	#1,activ8

	lea	sprite1_1,a0
	lea	sprite1_2,a1
	jsr	predecale

	lea	sprite2_1,a0
	lea	sprite2_2,a1
	jsr	predecale

	lea	sprite3_1,a0
	lea	sprite3_2,a1
	jsr	predecale

	ifne	musique
	jsr	jouerelo
	endc

	jsr	initmfp

	lea	fin2,a0
	lea	savebas,a1
	move.l	$8.w,(a1)+
	move.l	a0,$8.w
	move.l	$c.w,(a1)+
	move.l	a0,$c.w
	move.l	$10.w,(a1)+
	move.l	a0,$10.w
	move.l	$14.w,(a1)+
	move.l	a0,$14.w


	ifeq	clav
	jsr	clavier
	endc



	lea	$ffff8800.w,a5
	lea	pdigit1,a6
	move.l	#hbl,$68.w
	
	stop	#$2300
	move.l	#vbl,$70.w

	vsync
	vsync
	vsync

main:
	tst.w	$342.w
	beq	main2

	lea	activ2,a0
	moveq	#0,d0
.loop1:
	tst.w	(a0)+
	beq.s	.yeah
	addq.l	#4,a0
	addq.w	#1,d0
	cmp.l	#factiv,a0
	blt.s	.loop1
.yeah:

	tst.w	d0
	beq.s	main

	move.w	-6(a0),posxnr
	move.w	-6(a0),posx

	move.w	d0,$346.w


	move.l	ptlistco,a0
	lea	400(a0),a0
	move.l	a0,a1
	mulu	#distance*4,d0
	suba.w	d0,a1
	subq.l	#4,a1

	move.w	2(a1),posynr

.loop2:
	move.l	-(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)+
	
	cmp.l	a0,a1
	blt.s	.loop2

	move.l	ptlistco,a1
	lea	listco,a2
	lea	400(a1),a0
	move.l	a0,a3

.loop6:
	move.l	-(a0),-(a1)
	cmp.l	a2,a1
	bne.s	.oklistco

	lea	flistco2,a1
.oklistco:
	cmp.l	a1,a3
	bne.s	.loop6

	move.w	#0,$342.w

main2:

	tst.w	$344.w
	beq	main

	move.w	$346.w,d0
	lea	pttabpred1,a0
	move.l	a0,a1
	lsl.w	#2,d0
	adda.w	d0,a1
	addq.l	#4,a1

.loop3:
	move.l	(a0),d0
	move.l	-(a1),(a0)+
	move.l	d0,(a1)

	cmp.l	a1,a0
	blt.s	.loop3

	move.w	#0,$344.w

	bra	main
fin:

	move.b	#%00000000,$fffffa07.w
	move.b	#%00000000,$fffffa13.w
	
	move.b	#%00000000,$fffffa09.w
	move.b	#%00000000,$fffffa15.w

	move.l	#vbld,$70.w

	ifeq	clav
.wait:
	btst	#7,$fffffc02.w
	bne.s	.wait
	endc

	ifeq	clav
	move.w	#$2700,sr
	reset
	move.b	#$03,$fffffc02.w
	move.b	#$96,$fffffc02.w
	move.w	#$2300,sr
	endc

error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff

	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:

	jsr	finmfp

	lea	savebas,a0
	move.l	(a0)+,$8.w
	move.l	(a0)+,$c.w
	move.l	(a0)+,$10.w
	move.l	(a0)+,$14.w

	jsr	cleanay
	move.b	#$08,$fffffc02.w
	dc.w	$a009
	move.w	#$777,$ffff8240.w

	vsync
	move.b	#1,$ffff8260.w
	move.b	#2,$ffff820A.w
	movem.l	savcol,d0-d7
	movem.l	d0-d7,$ffff8240.w
	vsync


	cmp.w	#$1234,$326.w
	bne	sortie_reel

	move.w	posxnr,$332.w
	move.w	posynr,$334.w


* calcul du numero de la demo => $320.w

	lea	pttabpred1,a0	* decalage couleurs des boules
	movem.l	(a0),d0-d6/a1-a2
	movem.l	d0-d6/a1-a2,4(a0)


	move.l	$314.w,d0
	move.l	d0,a0
	move.b	#147,(a0)	* mettre le bon numero de bloc a la place de la boule

	sub.l	#map,d0
	move.w	d0,d2
	divu	#28,d0
	move.w	d0,d1
	mulu	#28,d0
	sub.w	d0,d2
	move.w	d2,d0

	move.w	d0,$328.w	* x de la boule de la demo
	move.w	d1,$32a.w	* y de la boule de la demo



	lea	listdemo,a0
	move.w	#11,d7
loopc:
	movem.w	(a0)+,d2-d5

	cmp.w	d0,d2
	bne.s	.ko

	cmp.w	d1,d3
	bne.s	.ko

	cmp.w	#11,d7
	bne.s	.pl1
	move.l	#tabpred3,pttabpred1
	move.w	d4,$320.w
	move.w	#2,$322.w
	move.w	#-1,-2(a0)
	bra.s	.ok
.pl1:
	cmp.w	#10,d7
	bne.s	.pl2

	move.l	#tabpred2,pttabpred1
	move.w	d4,$320.w
	move.w	#3,$322.w
	move.w	#-1,-2(a0)
	bra.s	.ok
.pl2:
	move.w	d4,$320.w
	move.l	#tabpred1,pttabpred1
	move.w	#-1,-2(a0)
	bra.s	.ok

.ko:
	dbf	d7,loopc
	move.w	#-1,$320.w

.ok:

	lea	map,a0
	move.w	$32a.w,d0
	subq.w	#8,d0
	mulu	#28,d0
	adda.w	d0,a0
	move.l	a0,ptmap

	move.w	#0,demi

	move.l	ptmap,d0
	sub.l	#map,d0
	divu	#28,d0
	mulu	#16,d0
	move.w	d0,posyecr
	add.w	#8*16,d0
	move.w	d0,posynr
	move.w	$328.w,d0
	mulu	#16,d0
	move.w	d0,posxnr
	move.w	d0,posx



	lea	activ1,a0
	lea	activ2,a1
	movem.l	(a0)+,d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,(a1)	* 8,6 boules (activ+posx+posy)
	move.w	(a0),52(a1)

	move.w	#1,activ1

	move.l	ptlistco,a0
	move.w	#distance-1,d6

	move.w	$328.w,d0
	mulu	#16,d0
	sub.w	$332.w,d0		delta x

	ext.l	d0
	divs	#distance,d0	avancee a chaque x

	swap	d0
	moveq	#0,d2
	move.w	d0,d2
	swap	d0

	tst.w	d2
	bgt.s	.ng12
	neg.w	d2
.ng12:

	swap	d2
	move.w	#0,d2

	divs	#distance,d2

	tst.w	d0
	bgt.s	.ng112
	neg.l	d2
.ng112

	move.w	d0,a5
	move.w	#distance-2,d0


	move.w	$32a.w,d1
	mulu	#16,d1
	sub.w	$334.w,d1		delta x


	ext.l	d1
	divs	#distance,d1	avancee a chaque x

	swap	d1
	moveq	#0,d3
	move.w	d1,d3
	swap	d1

	tst.w	d3
	bgt.s	.ng1
	neg.w	d3
.ng1:
	swap	d3
	move.w	#0,d3
	divu	#distance,d3

	tst.w	d1
	bgt.s	.ng11
	neg.l	d3
.ng11


	moveq	#0,d4
	moveq	#0,d5

	move.w	$332.w,d6
	move.w	$334.w,d7
.lop1:
	add.w	a5,d6

	add.w	d1,d7

	move.w	d6,400(a0)
	move.w	d7,402(a0)
	move.w	d6,(a0)+
	move.w	d7,(a0)+
	cmp.l	#flistco,a0
	blt.s	.i1
	lea	listco,a0
.i1:
	
	dbf	d0,.lop1

	move.w	$328.w,d6
	mulu	#16,d6
	move.w	$32a.w,d7
	mulu	#16,d7

	move.w	d6,400(a0)
	move.w	d7,402(a0)
	move.w	d6,(a0)+
	move.w	d7,(a0)+
	cmp.l	#flistco,a0
	blt.s	.i12
	lea	listco,a0
.i12:

	move.l	a0,ptlistco

	move.l	ptlistco,a0
	lea	400(a0),a0


	move.w	-4(a0),d0
	move.w	-2(a0),d1

	sub.w	posyecr,d1


	move.w	d0,posx1
	move.w	d1,posy1


	move.w	#nb_depl_sans_coll,$330.w


	lea	activ2,a1

st	set	1
	rept	10
	tst.w	(a1)+
	beq	.pascoor

	move.w	-4-st*(distance*4)(a0),d0
	move.w	-2-st*(distance*4)(a0),d1

	sub.w	posyecr,d1

	move.w	d0,(a1)+
	move.w	d1,(a1)+
st	set	st+1
	endr
*	bra	.i2
.pascoor:
	bra.s	.ok4
	move.w	#1,-2(a1)
	move.w	-4-st*(distance*4)(a0),d0
	move.w	-2-st*(distance*4)(a0),d1
	sub.w	posyecr,d1

	move.w	d0,(a1)+
	move.w	d1,(a1)+
.ok4:


	cmp.l	#posy10+2,a1
	bge.s	.i22

	move.w	posx1,(a1)+
	move.w	posy1,(a1)+
	addq.l	#2,a1
	bra.s	.ok4
.i22:

	move.l	ptlistco,a0

	move.l	(a0),savlastco
	move.l	a0,savptlistco

	jsr	frombssto4000

sortie_retour:
	move.l	pttabpred1,$32c.w
	sub.l	#tabpred2,$32c.w
	bra	Labyrinth

sortie_reel:
	jsr	restore4000to4600

	move.l	svbl,$70.w


	clr.w	-(sp)
	trap	#1

fin2:
	move.w	#5,$306.w
	bra	fin

fill:
	move.l	ecr1,a1
	add.l	#debut,a1
	move.l	ecr2,a2
	add.l	#debut,a2
	move.l	ecr3,a3
	add.l	#debut,a3

	move.l	ptmap,a0

	lea	bri,a5

	move.w	#ligne-1,d7

.loop2:
	move.w	d7,-(sp)

	move.w	#colonne-1,d7
.loop1:
	moveq	#0,d0
	move.b	(a0)+,d0
	lsl.w	#7,d0
	lea	(a5,d0.w),a4

st	set	0
	rept	4
	movem.l	(a4)+,d0-d6/a6
	movem.l	d0-d1,st(a1)
	movem.l	d0-d1,st(a2)
	movem.l	d0-d1,st(a3)
	movem.l	d2-d3,st+230*1(a1)
	movem.l	d2-d3,st+230*1(a2)
	movem.l	d2-d3,st+230*1(a3)
	movem.l	d4-d5,st+230*2(a1)
	movem.l	d4-d5,st+230*2(a2)
	movem.l	d4-d5,st+230*2(a3)
	movem.l	d6/a6,st+230*3(a1)
	movem.l	d6/a6,st+230*3(a2)
	movem.l	d6/a6,st+230*3(a3)
st	set	st+4*230
	endr

	lea	8(a1),a1
	lea	8(a2),a2
	lea	8(a3),a3

	dbf	d7,.loop1

	lea	15*230+6(a1),a1
	lea	15*230+6(a2),a2
	lea	15*230+6(a3),a3

	move.w	(sp)+,d7
	dbf	d7,.loop2

	rts


ici:

scroll_up1:


	move.l	ptmap,a0
	moveq	#0,d4
	move.w	demi,d4
	bne.s	.ok_demi
	move.w	#(16-nbli)*8,d4
	suba.w	#colonne,a0	* on remonte dans la map

	cmp.l	#map-(ligne*colonne),a0
	bgt.s	.benoit_gros_nul
	lea	fmap-((ligne)*colonne),a0	* -28
.benoit_gros_nul:
	bra.s	.save_demi
.ok_demi:
	sub.w	#nbli*8,d4
.save_demi:
	move.w	d4,demi
	move.l	a0,ptmap


	move.l	ecr1,a1	
	move.l	ecr2,a2
	move.l	ecr3,a3

	move.w	#nbli*230,d0
	suba.w	d0,a1
	suba.w	d0,a2
	suba.w	d0,a3

	subq.w	#nbli,posy_ecr	

	* taratata gestion des 3 ecrans 

	cmp.l	haut,a1
	bge.s	.pas_haut_1

	move.l	haut,ecr4
	move.l	ecr3,ecr1
	move.l	bas2,ecr3
	move.w	#ligne*16,posy_ecr

.pas_haut_1:

	cmp.l	haut,a2
	bge.s	.pas_haut_2

	move.l	haut,ecr4
	move.l	ecr3,ecr2
	move.l	bas2,ecr3
	move.w	#ligne*16,posy_ecr

.pas_haut_2:


	move.l	ecr1,a1	
	move.l	ecr2,a2
	move.l	ecr3,a3

	move.l	#nbli*230,d0
	suba.w	d0,a1
	suba.w	d0,a2
	suba.w	d0,a3

	sub.l	d0,ecr4

	move.l	a1,ecr1
	move.l	a2,ecr2
	move.l	a3,ecr3

	adda.w	#debut,a1
	adda.w	#debut,a2
	adda.w	#debut,a3
	movem.l	d4/a0-a3,regscroll
	move.w	#0,$308.w
	rts
	
.fin:
	movem.l	ptnomove,d0-d4
	movem.l	d0-d4,regscroll
	rts
	

scroll_down1:
t:
	move.l	ptmap,a0
	move.w	demi,d4
	cmp.w	#(16-nbli)*8,d4
	bne.s	.ok_demi
	move.w	#0,d4
	adda.w	#colonne,a0	* on descend dans la map

	cmp.l	#fmap-(ligne*colonne),a0
	blt.s	.benoit_gros_nul

	lea	map-(ligne*colonne),a0	* +28
.benoit_gros_nul:
	bra.s	.save_demi
.ok_demi:
	add.w	#nbli*8,d4
.save_demi:
	move.w	d4,demi
	move.l	a0,ptmap
.fin2:


	move.l	ecr1,a1	
	move.l	ecr2,a2
	move.l	ecr4,a3

	move.w	#nbli*230,d0
	adda.w	d0,a1
	adda.w	d0,a2
	adda.w	d0,a3
	addq.w	#nbli,posy_ecr

	* taratata gestion des 3 ecrans 

	cmp.l	bas,a1
	ble.s	.pas_bas_1

	move.l	bas,ecr3
	move.l	ecr4,ecr1
	move.l	haut2,ecr4
	move.w	#0,posy_ecr

.pas_bas_1:

	cmp.l	bas,a2
	ble.s	.pas_bas_2

	move.l	bas,ecr3
	move.l	ecr4,ecr2
	move.l	haut2,ecr4
	move.w	#0,posy_ecr
.pas_bas_2:

	move.l	ecr1,a1	
	move.l	ecr2,a2
	move.l	ecr4,a3

	move.l	#nbli*230,d0
	add.l	d0,ecr1
	add.l	d0,ecr2
	add.l	d0,ecr4
	add.l	d0,ecr3

	adda.w	#debut,a1
	adda.w	#debut,a2
	adda.w	#debut,a3

	add.l	#ligne*16*230,a1
	add.l	#ligne*16*230,a2
	add.l	#ligne*16*230,a3

	adda.w	#colonne*ligne,a0

	movem.l	d4/a0-a3,regscroll
	move.w	#1,$308.w
	rts


.fin:
	movem.l	ptnomove,d0-d4
	movem.l	d0-d4,regscroll
	rts

	
predecale:

	move.w	#14,d7
.loop2:
	move.w	#14,d6
.loop1:
	move.w	4(a0),d1
	swap	d1
	move.w	16(a0),d1
	lsr.l	#1,d1
	move.w	d1,16(a1)
	swap	d1
	move.w	d1,4(a1)
	
	move.w	6(a0),d1
	swap	d1
	move.w	18(a0),d1
	lsr.l	#1,d1
	move.w	d1,18(a1)
	swap	d1
	move.w	d1,6(a1)
	
	move.w	8(a0),d1
	swap	d1
	move.w	20(a0),d1
	lsr.l	#1,d1
	move.w	d1,20(a1)
	swap	d1
	move.w	d1,8(a1)
	
	move.w	10(a0),d1
	swap	d1
	move.w	22(a0),d1
	lsr.l	#1,d1
	move.w	d1,22(a1)
	swap	d1
	move.w	d1,10(a1)
	
	move.w	4(a1),d1
	or.w	6(a1),d1	
	or.w	8(a1),d1	
	or.w	10(a1),d1	
	not.w	d1
	move.w	d1,(a1)
	move.w	d1,2(a1)

	move.w	16(a1),d1
	or.w	18(a1),d1	
	or.w	20(a1),d1	
	or.w	22(a1),d1	
	not.w	d1
	move.w	d1,12(a1)
	move.w	d1,14(a1)

	lea	24(a0),a0
	lea	24(a1),a1
	dbf	d6,.loop1
	dbf	d7,.loop2
	rts

* teste de la collision

collision:

	move.w	#0,collis1

	move.l	ptmap,a2

	move.w	posx,d1
	lsr.w	#4,d1
	move.w	d1,d4
	adda.w	d1,a2
	
	move.w	posy,d1
	lsr.w	#4,d1
	lea	tab28,a3
	add.w	d1,d1
	add.w	(a3,d1.w),a2
	
	lea	tabcol,a3

*	en haut a gauche

	move.l	a3,a4
	
	moveq	#0,d1
	move.l	a2,$314.w
	move.b	(a2)+,d1
	move.b	d1,$30c.w
	move.l	d1,d2
	lsl.w	#8,d1
	lsl.w	#5,d2		no bri = no bri * 288
	add.l	d2,d1

	adda.l	d1,a4

	lsl.w	#4,d4		* coor en x briques mod 16

	move.w	posx,d1
	move.w	demi,d2

	lsr.w	#3,d2

	sub.w	d4,d1		* delta X

	add.w	#rec1,d1
	add.w	#rec2,d2

	add.w	d2,d2		* 2y
	move.w	d2,d3		* 2y
	add.w	d2,d2		* 4y
	add.w	d3,d2		* 4y+2y=6y

	adda.w	d2,a4		* no_brique+y*6

	move.w	d1,d3
	lsr.w	#3,d1		* x/8

	adda.w	d1,a4		* no_brique+x/8

	lsl.w	#3,d1
	sub.w	d1,d3
	move.w	#7,d1
	sub.w	d3,d1
	btst	d1,(a4)
	beq.s	.ok1
	move.w	#$555,$ffff8240.w
	move.w	#1,collis1
	rts
.ok1:

*	en bas a gauche

	move.l	a3,a4


	moveq	#0,d1
	move.l	a2,$314.w
	add.l	#27,$314.w
	move.b	27(a2),d1
	move.b	d1,$30c.w
	move.l	d1,d2
	lsl.w	#8,d1
	lsl.w	#5,d2		no bri = no bri * 288
	add.l	d2,d1

	adda.l	d1,a4


	move.w	posx,d1
	move.w	demi,d2

	lsr.w	#3,d2

	sub.w	d4,d1		* delta X

	add.w	#rec1,d1
*	add.w	#rec2,d2

	add.w	d2,d2		* 2y
	move.w	d2,d3		* 2y
	add.w	d2,d2		* 4y
	add.w	d3,d2		* 4y+2y=6y

	adda.w	d2,a4		* no_brique+y*6

	move.w	d1,d3
	lsr.w	#3,d1		* x/8

	adda.w	d1,a4		* no_brique+x/8

	lsl.w	#3,d1
	sub.w	d1,d3
	move.w	#7,d1
	sub.w	d3,d1
	btst	d1,(a4)
	beq.s	.ok2
	move.w	#$555,$ffff8240.w
	move.w	#1,collis1
	rts
.ok2:

*	en haut a droite

	move.l	a3,a4


	moveq	#0,d1
	move.l	a2,$314.w
	move.b	(a2),d1
	move.b	d1,$30c.w
	move.l	d1,d2
	lsl.w	#8,d1
	lsl.w	#5,d2		no bri = no bri * 288
	add.l	d2,d1

	adda.l	d1,a4


	move.w	posx,d1
	move.w	demi,d2

	lsr.w	#3,d2

	sub.w	d4,d1		* delta Y


*	add.w	#rec1,d1
	add.w	#rec2,d2

	add.w	d2,d2		* 2y
	move.w	d2,d3		* 2y
	add.w	d2,d2		* 4y
	add.w	d3,d2		* 4y+2y=6y

	adda.w	d2,a4		* no_brique+y*6

	move.w	d1,d3
	lsr.w	#3,d1		* x/8

	adda.w	d1,a4		* no_brique+x/8

	lsl.w	#3,d1
	sub.w	d1,d3
	move.w	#7,d1
	sub.w	d3,d1
	btst	d1,(a4)
	beq.s	.ok3
	move.w	#$555,$ffff8240.w
	move.w	#1,collis1
	rts
.ok3:
*	en bas a droite

	move.l	a3,a4


	moveq	#0,d1
	move.l	a2,$314.w
	add.l	#28,$314.w
	move.b	28(a2),d1
	move.b	d1,$30c.w
	move.l	d1,d2
	lsl.w	#8,d1
	lsl.w	#5,d2		no bri = no bri * 288
	add.l	d2,d1

	adda.l	d1,a4


	move.w	posx,d1
	move.w	demi,d2

	lsr.w	#3,d2

	sub.w	d4,d1		* delta X

*	add.w	#rec1,d1
*	add.w	#rec2,d2

	add.w	d2,d2		* 2y
	move.w	d2,d3		* 2y
	add.w	d2,d2		* 4y
	add.w	d3,d2		* 4y+2y=6y

	adda.w	d2,a4		* no_brique+y*6

	move.w	d1,d3
	lsr.w	#3,d1		* x/8

	adda.w	d1,a4		* no_brique+x/8

	lsl.w	#3,d1
	sub.w	d1,d3
	move.w	#7,d1
	sub.w	d3,d1
	btst	d1,(a4)
	beq.s	.ok4
	move.w	#$555,$ffff8240.w
	move.w	#1,collis1
	rts
.ok4:


	rts
la:

hbl:	rte
	
init_tab	lea	table,a0
	lea	tab_rout,a1
	lea	tab_rout2,a3
	lea	table,a2
	moveq	#127,d0
intabs1:
	moveq	#3,d1
intabs2:
	move.l	(a0)+,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a3,d2.w),(a2)+	* ligne sndtrack

	move.l	(a0)+,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a1,d2.w),(a2)+	* ligne normale

	dbra	d1,intabs2
	dbra	d0,intabs1
	rts

	


vbl2:
	movem.l	d0-d6/a0-a5,-(sp)
	move.l	a7,olda7
	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr
	
	lea	$ffff820a.w,a0	Frequence	
	lea	$ffff8260.w,a1	Resolution
	lea	$ffff8209.w,a2
	dcb.w	79,$4e71
	
*~~~~~	Border haut     ~~~~~*
	move.b	#0,(a0)		60 Hz
	dcb.w	15,$4e71
	move.b	#2,(a0)		50 Hz
	bclr	#5,$fffffa0f.w	Mise hors service du timer
	clr.b	$fffffa1b.w	Arret du TIMERB

	dcb.w	20,$4e71
	moveq.w	#0,d1		Synchronisation ecran
	move.b	$ffff8209.w,d1
	neg.w	d1
	lsl.w	d1,d1
	
	moveq.w	#0,d0
	
*~~~~~	1ere Ligne de Fullscreen   ~~~~~*

	dcb.w	26+5,$4e71

	movem.l	pal,d2-d7/a2-a3	* 16+8*8=80

line1	jsr l186
line2	jsr l186
line3	jsr l186
line4	jsr l186
line5	jsr l158
line6	jsr l158
line7	jsr l230
line8	jsr l230


	
	dcb.w	1,$4e71

	move.l	d2,$ffff8240.w

	move.w	a1,(a1)	HIRES	2 nops	|
	nop				| Border gauche
	move.b	d0,(a1)	LOWRES	2 nops	| Ajustement des plans

	movem.l	d3-d6,$ffff8244.w	* 12+8*4=44
	
	dcb.w	1,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop				|
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

	movem.l	d7/a2-a3,$ffff8254.w	* 12+3*8= 36


	dcb.w	49+21-9+19,$4e71

	include	"corpsi.s"

	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.

	dcb.w	13,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop
	move.b	d0,(a1)	LOWRES	3 nops	| Ajustement des plans
	
	dcb.w	12,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

	dcb.w	89,$4e71


	include	"spritei.s"

	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.

	dcb.w	13,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop
	move.b	d0,(a1)	LOWRES	3 nops	| Ajustement des plans
	
	dcb.w	12,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

	dcb.w	89,$4e71


	rept	109-12-83		*109


	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.
	
	move.w	(a6)+,d0	* 2
	add.w	d0,d0	* 1
	add.w	d0,d0	* 1
	add.w	d0,d0	* 1
	lea	snd_out2+4,a0	* 3
	adda.w	d0,a0	* 2
	move.l	(a0)+,d0	* 3
	
	move.w	a1,(a1)	HIRES	2 nops	|
	move.b	#0,(a1)	LOWRES	3 nops	| Ajustement des plans
	
	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 2

	dcb.w	3,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	moveq	#0,d0
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

	dcb.w	89,$4e71

	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.

	dcb.w	13,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop
	move.b	d0,(a1)	LOWRES	3 nops	| Ajustement des plans
	
	dcb.w	12,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

	dcb.w	89,$4e71
	
	endr


	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.

	dcb.w	13,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop
	move.b	d0,(a1)	LOWRES	3 nops	| Ajustement des plans
	
	dcb.w	12,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

	dcb.w	89,$4e71


*~~~~~    Border bas    ~~~~~*
	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.
	
	dcb.w	13,$4e71		X nops
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop				| Border gauche
	move.b	d0,(a1)	LOWRES	2 nops	| Ajustement des plans
	
	move.b	d0,(a0)	60 Hz	2 nops	|- Border bas
	dcb.w	9,$4e71		X nops
	
	move.w	a1,(a1)	HIRES	2 nops	|*
	move.w	a1,(a0)	50 Hz	2 nops	|-
	move.b	d0,(a1)	LOWRES	2 nops	|* Border gauche.
	
	dcb.w	89,$4e71		X nops

	
	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.
	
	move.w	(a6)+,d0	* 2
	add.w	d0,d0	* 1
	add.w	d0,d0	* 1
	add.w	d0,d0	* 1
	lea	snd_out2+4,a0	* 3
	adda.w	d0,a0	* 2
	move.l	(a0)+,d0	* 3
	
	move.w	a1,(a1)	HIRES	2 nops	|
	move.b	#0,(a1)	LOWRES	3 nops	| Ajustement des plans
	
	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 2

	dcb.w	3,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	moveq	#0,d0
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.


*~~~~~ 	Suite du Fullscreen    ~~~~~*

	dcb.w	89,$4e71		X nops

	rept	ecart		* 22  l'origine

	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.
	
	move.w	(a6)+,d0	* 2
	add.w	d0,d0	* 1
	add.w	d0,d0	* 1
	add.w	d0,d0	* 1
	lea	snd_out2+4,a0	* 3
	adda.w	d0,a0	* 2
	move.l	(a0)+,d0	* 3
	
	move.w	a1,(a1)	HIRES	2 nops	|
	move.b	#0,(a1)	LOWRES	3 nops	| Ajustement des plans
	
	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 2

	dcb.w	3,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	moveq	#0,d0
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

	dcb.w	89,$4e71

	
	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.
	
	dcb.w	13,$4e71		X nops
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop				| Border gauche
	move.b	d0,(a1)	LOWRES	2 nops	| Ajustement des plans
	
	dcb.w	12,$4e71		X nops
	
	move.w	a1,(a1)	HIRES	2 nops	|
	nop				|
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

	dcb.w	89,$4e71		X nops
	endr

	move.b	d0,(a0)	60 Hz	2 nops	|
	move.w	a1,(a0)	50 Hz	2 nops	| Border droit.
	
	move.w	(a6)+,d0	* 2
	add.w	d0,d0	* 1
	add.w	d0,d0	* 1
	add.w	d0,d0	* 1
	lea	snd_out2+4,a0	* 3
	adda.w	d0,a0	* 2
	move.l	(a0)+,d0	* 3
	
	move.w	a1,(a1)	HIRES	2 nops	|
	move.b	#0,(a1)	LOWRES	3 nops	| Ajustement des plans
	
	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 2

	dcb.w	3,$4e71
	
	move.w	a1,(a1)	HIRES	2 nops	|
	moveq	#0,d0
	move.b	d0,(a1)	LOWRES	2 nops	| Border gauche.

*	dcb.w	89,$4e71

	lea	$ffff8240.w,a2	* 2
	moveq	#0,d2		* 1
	rept	8
	move.l	d2,(a2)+		* 8*3=24
	endr


	move.l	olda7,a7
	move.w	#$2300,sr

	move.l	ptrestore11,d0
	move.l	ptrestore12,ptrestore11
	move.l	d0,ptrestore12
	
	move.l	ptrestore21,d0
	move.l	ptrestore22,ptrestore21
	move.l	d0,ptrestore22
	
	move.l	ptrestore31,d0
	move.l	ptrestore32,ptrestore31
	move.l	d0,ptrestore32

	move.l	ptrestore41,d0
	move.l	ptrestore42,ptrestore41
	move.l	d0,ptrestore42
	
	move.l	ptrestore51,d0
	move.l	ptrestore52,ptrestore51
	move.l	d0,ptrestore52
	
	move.l	ptrestore61,d0
	move.l	ptrestore62,ptrestore61
	move.l	d0,ptrestore62
	
	move.l	ptrestore71,d0
	move.l	ptrestore72,ptrestore71
	move.l	d0,ptrestore72
	
	move.l	ptrestore81,d0
	move.l	ptrestore82,ptrestore81
	move.l	d0,ptrestore82

	move.l	ptrestore91,d0
	move.l	ptrestore92,ptrestore91
	move.l	d0,ptrestore92
	
	move.l	ptrestore101,d0
	move.l	ptrestore102,ptrestore101
	move.l	d0,ptrestore102
	
	
	move.l	ecr1,d1
	move.l	ecr2,ecr1
	move.l	d1,ecr2


	sub.l	#debut,d1

	move.l	d1,d0
	and.l	#255,d0
	lsl.w	#4,d0
	lea	table,a0
	lea	(a0,d0.w),a0
	move.l	(a0)+,line1+2
	move.l	(a0)+,line2+2
	move.l	(a0)+,line3+2
	move.l	(a0)+,line4+2
	move.l	(a0)+,line5+2
	move.l	(a0)+,line6+2
	move.l	(a0)+,line7+2
	move.l	(a0)+,line8+2
swap_scr	
	swap	d1
	move.b	d1,$ffff8201.w
	rol.l	#8,d1
	move.b	d1,$ffff8203.w




	movem.l	(sp)+,d0-d6/a0-a5
vbld:
	addq.l	#1,$466.w
	rte


*            hardware routine           *

	
tab_rout:
	dc.l	l230
	dc.l	l158
	dc.l	l186
	dc.l	l184
	dc.l	l160
	dc.l	l204

tab_rout2:
	dc.l	l2302
	dc.l	l1582
	dc.l	l1862
	dc.l	l1842
	dc.l	l1602
	dc.l	l2042


l1602:
	move.w	(a6)+,d0		* 2
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	lea	snd_out2+4,a0		* 3
	adda.w	d0,a0		* 2

	move.l	(a0)+,d0		* 3 = 13

	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 3
	moveq	#0,d0		* 1	
	dcb.w	119-23,$4e71

	RTS
l2302:
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)

	move.w	(a6)+,d0		* 2
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	lea	snd_out2+4,a0		* 3
	adda.w	d0,a0		* 2	= 10

	dcb.w	2,$4e71
	MOVE.w	a1,(A1)
	MOVE.B	#0,(A1)

	move.l	(a0)+,d0		* 3

	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 3 = 12
	moveq	#0,d0
	dcb.w	76,$4e71

	MOVE.B	D0,(A0)
	MOVE.w	a1,(A0)
	dcb.w	4,$4e71
	RTS
l1862:
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)		* 5

	move.w	(a6)+,d0		* 2
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	lea	snd_out2+4,a0		* 3
	adda.w	d0,a0		* 2	= 10

	dcb.w	2,$4e71


	MOVE.w	a1,(A1)
	MOVE.B	#0,(A1)		* 5
	move.l	(a0)+,d0		* 3

	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 3 = 12
	moveq	#0,d0
	dcb.w	84,$4e71
	RTS
l1842:
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)		* 5

	move.w	(a6)+,d0		* 2
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	lea	snd_out2+4,a0		* 3
	adda.w	d0,a0		* 2	= 10

	dcb.w	2,$4e71

	MOVE.w	a1,(A1)
	MOVE.B	#0,(A1)

	move.l	(a0)+,d0		* 3
	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 3 = 12
	moveq	#0,d0

	dcb.w	72,$4e71

	MOVE.B	D0,(A0)
	dcb.w	4,$4e71
	MOVE.w	a1,(A0)
	dcb.w	4,$4e71
	RTS

l1582:

	move.w	(a6)+,d0		* 2
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	lea	snd_out2+4,a0		* 3
	adda.w	d0,a0		* 2

	move.l	(a0)+,d0		* 3 = 13

	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 3
	moveq	#0,d0		* 1	

	dcb.w	85,$4e71
	MOVE.B	D0,(A0)
	dcb.w	4,$4e71
	MOVE.w	a1,(A0)
	dcb.w	3,$4e71
	RTS
l2042:
	move.w	(a6)+,d0		* 2
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	add.w	d0,d0		* 1
	lea	snd_out2+4,a0		* 3
	adda.w	d0,a0		* 2

	move.l	(a0)+,d0		* 3 = 13

	movep.l	d0,$800-$260(a1)	* 6
	lea	$ffff820a.w,a0	* 3
	moveq	#0,d0		* 1	


	dcb.w	88,$4e71
	MOVE.B	d0,(A0)
	MOVE.w	a1,(A0)
	dcb.w	4,$4e71
	RTS

	
*	include	"hard.s"		* inclusion des lignes


l160:
	dcb.w	119,$4e71

	RTS
l230:
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)
	dcb.w	12,$4e71
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.B	D0,(A0)
	MOVE.w	a1,(A0)
	NOP
	NOP
	NOP
	NOP
	RTS
l186:
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	RTS
l184:
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.w	a1,(A1)
	NOP
	MOVE.B	D0,(A1)
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.B	D0,(A0)
	NOP
	NOP
	NOP
	NOP
	MOVE.w	a1,(A0)
	NOP
	NOP
	NOP
	NOP
	RTS
l158:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.B	D0,(A0)
	NOP
	NOP
	NOP
	NOP
	MOVE.w	a1,(A0)
	NOP
	NOP
	NOP
	RTS
l204:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.B	D0,(A0)
	MOVE.w	a1,(A0)
	NOP
	NOP
	NOP
	NOP
	RTS
				* de hardware

*      end of the hardware routine     *

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

	bclr	#3,$fffffa17.w
	
	clr.b	$fffffa19.w 	    Arret Timer A (Reg control)
	clr.b	$fffffa1b.w 	    Arret Timer B (Reg control)

	move.b	#%00100001,$fffffa07.w  On lance le timer B seul
	move.b	#%00100001,$fffffa13.w  Pareil avec le masque
	
	move.b	#%00000000,$fffffa09.w  Pas de Timer C et D
	move.b	#%00000000,$fffffa15.w
	
	
	
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
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w

	rte
	
	
	
vbl:
	move.l	#tjoue4v,$134.w
	clr.b	$fffffa19.w
	move.b	#78,$fffffa1f.w
	move.b	#1,$fffffa19.w
	move.b	#%00100000,$fffffa07.w

	move.l	#vbl2,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#98,$fffffa21.w	|
	move.b	#4,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w

	ifne	clav
	cmp.b	#$39,$fffffc02.w
	bne.s	eric
	endc

	ifeq	clav
	btst	#7,$fffffc02.w
	beq.s	eric
	endc

	move.l	#fin,2(a7)
	bra	eric2
eric
	movem.l	d0-a5,-(sp)

	move.b	$fffffc02.w,touche

	movem.l	noir,d0-d6/a0
	movem.l	d0-d6/a0,$ffff8240.w

	move.b	#0,move

	move.l	ecr1,secr1
	move.l	ecr2,secr2
	move.l	ecr3,secr3
	move.l	ecr4,secr4

	move.l	ptmap,sptmap
	move.w	demi,sdemi

	move.w	posxnr,oldxnr
	move.w	posynr,oldynr

	move.w	posx,oldx
	move.w	posy,oldy

	move.w	posyecr,oldyecr

	move.w	posy_ecr,$310.w	* crados non ?

	move.b	touche,d0

	* Bit 7:	Fire
	* Bit 6:	Help
	* Bit 3:	Right
	* Bit 2:	Left
	* Bit 1:	Down
	* Bit 0:	Up

	tst.w	$33c.w
	beq	.deplacement_clavier

	blt.s	.deplace_vers_le_haut

.deplace_vers_le_bas:

	jsr	scroll_down1
	move.b	#1,move
	addq.w	#2,posyecr

	subq.w	#2,posy1
	subq.w	#2,posy2
	subq.w	#2,posy3
	subq.w	#2,posy4
	subq.w	#2,posy5
	subq.w	#2,posy6
	subq.w	#2,posy7
	subq.w	#2,posy8
	subq.w	#2,posy9
	subq.w	#2,posy10

	subq.w	#2,$33c.w
	bne.s	.okt1
	move.w	#-1,$344.w
.okt1:

	bra	clip	

.deplace_vers_le_haut:
	jsr	scroll_up1
	move.b	#1,move
	subq.w	#2,posyecr

	addq.w	#2,posy1
	addq.w	#2,posy2
	addq.w	#2,posy3
	addq.w	#2,posy4
	addq.w	#2,posy5
	addq.w	#2,posy6
	addq.w	#2,posy7
	addq.w	#2,posy8
	addq.w	#2,posy9
	addq.w	#2,posy10

	addq.w	#2,$33c.w
	bne.s	.okt2
	move.w	#-1,$344.w
.okt2:
	bra	clip


.deplacement_clavier:

	ifne	clav
	cmp.b	#$62,d0
	bne.s	.pas_help
	endc
	ifeq	clav
	btst	#6,d0
	beq.s	.pas_help
	endc

	move.w	#$77,$ffff8240.w

	ifeq	help

	move.w	$33e.w,d0
	sub.w	posy1,d0
	move.w	d0,$33c.w
	move.w	d0,$340.w
	move.w	#-1,$342.w
	bra	go_help

	endc

	ifne	help

	and.b	#%11111110,$fffffa07.w	* help normal
	move.l	#help_me_please,2+14*4(a7)
	bra	go_help

	endc
.pas_help:

	ifne	clav

.bg:
	cmp.b	#$6d,d0
	bne.s	.bd
	jsr	scroll_down1
	move.b	#1,move
	addq.w	#2,posynr
	addq.w	#2,posyecr

	cmp.w	#2,posx
	blt.s	.bd
	subq.w	#2,posxnr
	subq.w	#2,posx
	bra	.i
.bd:
	cmp.b	#$6f,d0
	bne.s	.hg
	jsr	scroll_down1
	move.b	#1,move
	addq.w	#2,posynr
	addq.w	#2,posyecr

	cmp.w	#450,posx
	bgt.s	.hg
	addq.w	#2,posxnr
	addq.w	#2,posx
	bra	.i

.hg:
	cmp.b	#$67,d0
	bne.s	.hd
	jsr	scroll_up1
	move.b	#1,move
	subq.w	#2,posynr
	subq.w	#2,posyecr

	cmp.w	#2,posx
	blt.s	.hd
	subq.w	#2,posxnr
	subq.w	#2,posx
	bra	.i

.hd:
	cmp.b	#$69,d0
	bne.s	.up

	jsr	scroll_up1
	move.b	#1,move
	subq.w	#2,posynr
	subq.w	#2,posyecr


	cmp.w	#450,posx
	bgt.s	.up
	addq.w	#2,posxnr
	addq.w	#2,posx
	bra	.i


.up:
	cmp.b	#$68,d0
	bne.s	.down
	jsr	scroll_up1
	move.b	#1,move
	subq.w	#2,posynr
	subq.w	#2,posyecr
	bra	.i
.down:
	cmp.b	#$6e,d0
	bne.s	.space
	jsr	scroll_down1
	move.b	#1,move
	addq.w	#2,posynr
	addq.w	#2,posyecr
	bra	.i
	endc

	ifeq	clav

.up:
	btst	#0,$fffffc02.w
	beq.s	.down
	jsr	scroll_up1
	move.b	#1,move
	subq.w	#2,posynr
	subq.w	#2,posyecr
	bra.s	.i
.down:
	btst	#1,$fffffc02.w
	beq.s	.space
	jsr	scroll_down1
	move.b	#1,move
	addq.w	#2,posynr
	addq.w	#2,posyecr
	bra.s	.i
	endc

.space:
	movem.l	ptnomove,d1-d5
	movem.l	d1-d5,regscroll

	ifne	clav
.i:
.gauche:
	cmp.b	#$6a,d0
	bne.s	.droite
	cmp.w	#2,posx
	blt.s	.droite
	subq.w	#2,posxnr
	subq.w	#2,posx
	move.b	#1,move
.droite:
	cmp.b	#$6c,d0
	bne.s	.rien
	cmp.w	#450,posx
	bgt.s	.rien
	addq.w	#2,posxnr
	addq.w	#2,posx
	move.b	#1,move
.rien:
	endc

	ifeq	clav
.i:
.gauche:
	btst	#2,$fffffc02.w
	beq.s	.droite
	cmp.w	#2,posx
	blt.s	.droite
	subq.w	#2,posxnr
	subq.w	#2,posx
	move.b	#1,move
.droite:
	btst	#3,$fffffc02.w
	beq.s	.rien
	cmp.w	#450,posx
	bgt.s	.rien
	addq.w	#2,posxnr
	addq.w	#2,posx
	move.b	#1,move
.rien:
	endc

	move.b	#0,$30c.w
	jsr	collision

	tst.w	collis1
	beq	.pascol

	* entree dans un ecran

	moveq	#0,d1
	move.b	$30c.w,d1
	cmp.w	#240,d1
	blt.s	.ok111



	move.l	#fin,2+56(a7)
	move.w	#$1234,$326.w

.ok111:
	* il y a eu collision ....
.col:
	move.w	$310.w,posy_ecr

	movem.l	ptnomove,d1-d5
	movem.l	d1-d5,regscroll

	move.l	secr1,ecr1
	move.l	secr2,ecr2
	move.l	secr3,ecr3
	move.l	secr4,ecr4

	move.l	sptmap,ptmap
	move.w	sdemi,demi

	move.w	oldxnr,posxnr
	move.w	oldynr,posynr

	move.w	oldx,posx
	move.w	oldy,posy

	move.w	oldyecr,posyecr


	bra.s	.okcol

.pascol:
	tst.b	move
	beq.s	.okcol

	move.l	ptlistco,a0

	move.l	(a0),savlastco
	move.l	a0,savptlistco

	move.w	posxnr,400(a0)
	move.w	posynr,402(a0)

	move.w	posxnr,(a0)+
	move.w	posynr,(a0)+

	cmp.l	#flistco,a0
	blt.s	.oklistco

	lea	listco,a0

.oklistco:
	move.l	a0,ptlistco

.okcol:

* gestion des 10 pointeurs dans liste coordonn‚es

	movem.l	posx1,d0-d6/a0-a4
	movem.l	d0-d6/a0-a4,sposx1

	movem.l	posx1+12*4,d0-d2
	movem.l	d0-d2,sposx1+12*4


	move.l	ptlistco,a0
	lea	400(a0),a0


	move.w	-4(a0),d0
	move.w	-2(a0),d1

	sub.w	posyecr,d1


	move.w	d0,posx1
	move.w	d1,posy1



	lea	pttabpred2,a2
	lea	activ2,a1

st	set	1
	rept	10
	tst.w	(a1)+
	beq	.pascoor

	move.w	-4-st*(distance*4)(a0),d0
	move.w	-2-st*(distance*4)(a0),d1

	sub.w	posyecr,d1

	move.w	d0,(a1)+
	move.w	d1,(a1)+
	addq.l	#4,a2
st	set	st+1
	endr
*	bra	.i2
.pascoor:

.ok4:

	move.w	d1,$33e.w

	cmp.l	#posy10+2,a1
	bge.s	.i2

	move.w	posx1,(a1)+
	move.w	posy1,(a1)+
	addq.l	#2,a1
	move.l	pttabpred1,(a2)+
	bra.s	.ok4
.i2:

	* teste collision entre boules !

	tst.b	move
	beq.s	.lml

	subq.w	#1,$330.w
	bgt	.test_pas
.lml:

	lea	sprvsspr,a0

	tst.w	activ2
	beq	.pascolspr
	move.w	posx1,d0
	sub.w	posx2,d0

	cmp.w	#16,d0
	bgt	.pascolspr
	
	cmp.w	#-16,d0
	blt	.pascolspr
	
	move.w	posy1,d1
	sub.w	posy2,d1

	cmp.w	#16,d1
	bgt	.pascolspr
	
	cmp.w	#-16,d1
	blt	.pascolspr

	add.w	#16,d0
	add.w	#16,d1

	add.w	d1,d1		* 2y
	move.w	d1,d2		* 2y
	add.w	d1,d1		* 4y
	add.w	d2,d1		* 4y+2y=6y

	adda.w	d1,a0

	move.w	d0,d1
	lsr.w	#3,d1

	adda.w	d1,a0

	and.w	#%111,d0

	move.w	#7,d1
	sub.w	d0,d1
	btst.b	d1,(a0)
	bne	.coli_spr

	bra	.pascolspr

.coli_spr:
	move.w	#$707,$ffff8240.w

	move.l	savptlistco,a0
	move.l	savlastco,(a0)
	move.l	savlastco,400(a0)
	move.l	a0,ptlistco

	movem.l	sposx1,d0-d6/a0-a2
	movem.l	d0-d6/a0-a2,posx1

	movem.l	sposx1+10*4,d0-d4
	movem.l	d0-d4,posx1+10*4

	movem.l	ptnomove,d1-d5
	movem.l	d1-d5,regscroll

	move.l	secr1,ecr1
	move.l	secr2,ecr2
	move.l	secr3,ecr3
	move.l	secr4,ecr4

	move.l	sptmap,ptmap
	move.w	sdemi,demi

	move.w	oldxnr,posxnr
	move.w	oldynr,posynr

	move.w	oldx,posx
	move.w	oldy,posy

	move.w	oldyecr,posyecr


.pascolspr:
.test_pas:

clip:
	move.w	posx1,d2
	move.w	posy1,d3


	lea	posy2,a0
.loopclip:
	move.w	(a0),d0
	cmp.w	#1,d0
	ble.s	.clipmonpote
	cmp.w	#240,d0
	bge.s	.clipmonpote

.okclip:	
	addq.l	#6,a0
	cmp.l	#posy10+2,a0
	blt.s	.loopclip
	bra.s	.i3

.clipmonpote:
	move.w	d2,-2(a0)
	move.w	d3,(a0)
	bra.s	.okclip
	
.i3:

go_help:
	movem.l	(sp)+,d0-a5
vbl_fond:

	ifne	musique
	movem.l	d3-d6,-(sp)
	movem.l	soundreg(pc),d3-d6
	bra.s	tst_end

nobcld1:	move.l	#dsilence,soundreg+(4+2)*4
	moveq	#-2,d3
	clr.l	avance1+2
	bra.s	nocar1
bcld1:	add.l	#0,d3
	bra.s	nocar1

nobcld2:	move.l	#dsilence,soundreg+(4+3)*4
	moveq	#-2,d4
	moveq	#0,d2
	move.l	d2,avance2+2
	bra.s	nocar2
bcld2:	add.l	#0,d4
	bra.s	nocar2
	
nobcld3:	move.l	#dsilence,soundreg+(4+0)*4
	moveq	#-2,d5
	clr.l	avance3+2
	bra.s	nocar3
bcld3:	add.l	#0,d5
	bra.s	nocar3
	
nobcld4:	move.l	#dsilence,soundreg+(4+1)*4
	moveq	#-2,d6
	clr.l	avance4+2
	bra.s	nocar4
bcld4:	add.l	#0,d6
	bra.s	nocar4

	
tst_end:
	
	swap	d3
tstfin1:
	bpl.s	nobcld1
nocar1:
	swap	d3

	swap	d4
tstfin2:
	bpl.s	nobcld2
nocar2:
	swap	d4

	swap	d5
tstfin3:
	bpl.s	nobcld3
nocar3:
	swap	d5

	swap	d6
tstfin4:
	bpl.s	nobcld4
nocar4:
	swap	d6
	movem.l	d3-d6,soundreg

	movem.l	(sp)+,d3-d6


	endc
*	move.w	#$700,$ffff8240.w
	bsr	ttempo
*	move.w	#$70,$ffff8240.w

eric2:

	addq.l	#1,$466.w
	rte

	ifne	musique	
jouerelo:
	bsr.s	relogemodu
	bsr	inisong	
	
	
	move.b	#$12,$fffffc02.w
	bsr	iniprg
	bsr	cleanay

	movem.l	d3-d6/a2-a5,soundreg
	lea	pdigit1,a6
	
	move.w	#$2300,sr

	
	rts
	
relogemodu:
	move.l	#module+8,a0	| a0:digits
	move.l	a0,a1	|
	add.l	-8(a0),a1	| a1:paternes
	move.l	a1,a2	|
	add.l	-4(a0),a2	| a2:chanson
	
****************** reloge chansons ***********************
	
	move.l	a0,a3
	move.l	a0,d1
	move.w	(a3)+,d0	| d0=nb de digits
	subq.w	#1,d0
nextdig:
	add.l	d1,(a3)
	add.l	#16,a3 
	dbf	d0,nextdig
	
********************* reloge paternes **********************
	
	move.l	a1,a3
	move.l	a1,d1
	move.w	(a3)+,d0	| d0=nb de paternes
	subq.w	#1,d0
nextpat:
	add.l	d1,(a3)+
	dbf	d0,nextpat

	rts

	endc
*********************************************
*~~~ Lecture morceau-Remplissage buffers ~~~*
*********************************************
soundreg:	ds.l	16
tmul16:
N	set	0
	rept	256
	dc.w	N
N	set	N+16
	endr

*~~~	Routine tempo 		~~~*
ttempo:	movem.l	d0-a4,-(sp)
	movem.l	soundreg(pc),d3-d6
	
	move.w	sr,-(a7)
	move.w	#$2700,sr
	move.l	cdigit1,a0
	move.l	a6,d0
	sub.l	a0,d0
*	move.w	d0,$41a.w
	moveq	#$12,d0 
	move.l	cdigit2,a6
	move.l	a6,cdigit1
	move.l	a0,cdigit2
	moveq	#3,d2
	move.w	(a7)+,sr

	ifne	musique

	moveq	#0,d1
	
looptrack:
	swap	d3
avance1:	add.l	#0,d3
	swap	d3
	swap	d4
avance2:	add.l	#0,d4
	swap	d4
	swap	d5
avance3:	add.l	#0,d5
	swap	d5
	swap	d6
avance4:	add.l	#0,d6
	swap	d6

	movem.l	soundreg+4*4(pc),a1-a4
	
	adda.w	d3,a3
	adda.w	d4,a4	
	adda.w	d5,a1
	adda.w	d6,a2	
	
av1:	move.b	(a3),d1
	add.b	(a4),d1
	add.b	(a1),d1
	add.b	(a2),d1
	
	move.w	d1,(a0)+
	
av2:	rept	NAV-1
	move.b	1(a3),d1
	add.b	1(a4),d1
	add.b	1(a1),d1
	add.b	1(a2),d1
	
	move.w	d1,(a0)+
	endr
	
	dbra	d0,looptrack	; --> 12 cycles
	
	tst.b	flag
	beq.s	.f1
	
	rept	2
	move	d1,(a0)+
	endr
	
	sf	flag
	
	bra.s	ftrack

.f1:
	st	flag	
	move.l	avance1+2,d0
	lsr.l	#1,d0
	swap	d3
	add.l	d0,d3
	swap	d0
	adda	d0,a3
	swap	d3
	move.l	avance2+2,d0
	lsr.l	#1,d0
	swap	d4
	add.l	d0,d4
	swap	d0
	adda	d0,a4
	swap	d4
	move.l	avance3+2,d0
	lsr.l	#1,d0
	swap	d5
	add.l	d0,d5
	swap	d0
	adda	d0,a1
	swap	d5
	move.l	avance4+2,d0
	lsr.l	#1,d0
	swap	d6
	add.l	d0,d6
	swap	d0
	adda	d0,a2
	swap	d6
	
	moveq	#0,d0
	bra	av2+3*18

flag	dc.b	0
	even
	
ftrack:
	movem.l	soundreg+4*4(pc),a1-a4
	
	subq.b	#1,ctempo
	ble.s	suitetpo
	
	movem.l	d3-d6,soundreg
	endc
	movem.l	(sp)+,d0-a4
	rts

	ifne	musique
prepav:
N	set	0
	rept	NAV-2
	swap	d0
	move.w	d0,N(a2)
	swap	d0
	add.l	d1,d0
N	set	N+18
	endr
	swap	d0
	move.w	d0,N(a2)
	rts

suitetpo:	move.l	a2,d2
	
	tst.w	nbentreeaj
	bgt.s	met3son
	tst.w 	nbrpat
	bgt.s 	nonrecomm
	addq.l 	#4,psong
	move.l 	psong,a0
	move.w	2(a0),nbrpat
	bne.s	nonrecomm
	move.l 	pdsong,psong

nonrecomm:	move.l	psong,a0
	moveq.l	#0,d0
	move.w	(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	ppats,a1
	move.l	(a1,d0.w),a0
 
patsuivante:	move.w	(a0),nbentreeaj
	move.b	3(a0),tempo
	addq.l	#4,a0
	move.l	a0,pentree
	
	subq.w #1,nbrpat

met3son:	move.l	pentree,a0
	move.l	pinstrs,a1

sadtabj2t:	move.l	#0,a2

son1:	moveq.l	#0,d0
	move.b	(a0),d0
	beq.s	noboucle1
	lsl.w	#4,d0
	move.l	(a1,d0.w),a3
	moveq.l	#0,d3
	sub.l	4(a1,d0.w),d3
	sub.l	d3,a3
	move.w	#$6b00+(nobcld1-nocar1),tstfin1
	tst.b	1(a0)
	beq.s	noboucle1
	move.w	#$6b00+(bcld1-nocar1),tstfin1
	sub.l	12(a1,d0.w),a3
	add.w	14(a1,d0.w),d3
	move.w	10(a1,d0.w),d0
	neg.w	d0
	move.w	d0,bcld1+2

noboucle1:	move.w	2(a0),d0
	beq.s	fson1
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a2,d0.w),d0
	move.l	d0,d1
	
	move.l	a2,-(a7)
	lea	av2+2,a2
	bsr	prepav
	move.l	(a7)+,a2

	lsl.l	#NDAV-1,d1
	move.l	d1,avance1+2
	
fson1:
son2:	moveq.l	#0,d0
	move.b	4(a0),d0
	beq.s	noboucle2
	lsl.w	#4,d0
	move.l	(a1,d0.w),a4
	moveq.l	#0,d4
	sub.l	4(a1,d0.w),d4
	sub.l	d4,a4
	move.w	#$6b00+(nobcld2-nocar2),tstfin2
	tst.b	5(a0)
	beq.s	noboucle2
	move.w	#$6b00+(bcld2-nocar2),tstfin2
	sub.l	12(a1,d0.w),a4
	add.w	14(a1,d0.w),d4
	move.w	10(a1,d0.w),d0
	neg.w	d0
	move.w	d0,bcld2+2

noboucle2:	move.w	6(a0),d0
	beq.s	fson2
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a2,d0.w),d0
	move.l	d0,d1
	
	move.l	a2,-(a7)
	lea	av2+6,a2
	bsr	prepav
	move.l	(a7)+,a2

	lsl.l	#NDAV-1,d1
	move.l	d1,avance2+2
fson2:
son3:	move.l	soundreg+4*4(pc),d1
	moveq.l	#0,d0
	move.b	8(a0),d0
	beq.s	noboucle3
	lsl.w	#4,d0
	move.l	(a1,d0.w),d1
	moveq.l	#0,d5
	sub.l	4(a1,d0.w),d5
	sub.l	d5,d1
	move.w	#$6b00+(nobcld3-nocar3),tstfin3
	tst.b	9(a0)
	beq.s	noboucle3
	move.w	#$6b00+(bcld3-nocar3),tstfin3
	sub.l	12(a1,d0.w),d1
	add.w	14(a1,d0.w),d5
	move.w	10(a1,d0.w),d0
	neg.w	d0
	move.w	d0,bcld3+2

noboucle3:	move.l	d1,soundreg+4*4
	move.w	10(a0),d0
	beq.s	fson3
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a2,d0.w),d0
	move.l	d0,d1
	
	move.l	a2,-(a7)
	lea	av2+10,a2
	bsr	prepav
	move.l	(a7)+,a2

	lsl.l	#NDAV-1,d1
	move.l	d1,avance3+2

fson3:	exg	d2,a2

son4:	moveq.l	#0,d0
	move.b	12(a0),d0
	beq.s	noboucle4
	lsl.w	#4,d0
	move.l	(a1,d0.w),a2
	moveq.l	#0,d6
	sub.l	4(a1,d0.w),d6
	sub.l	d6,a2
	move.w	#$6b00+(nobcld4-nocar4),tstfin4
	tst.b	13(a0)
	beq.s	noboucle4
	move.w	#$6b00+(bcld4-nocar4),tstfin4
	sub.l	12(a1,d0.w),a2
	add.w	14(a1,d0.w),d6
	move.w	10(a1,d0.w),d0
	neg.w	d0
	move.w	d0,bcld4+2

noboucle4:	move.w	14(a0),d0
	beq.s	fson4
	add.w	d0,d0
	add.w	d0,d0
	exg	d2,a2
	move.l	(a2,d0.w),d0
	move.l	d0,d1
	
	move.l	a2,-(a7)
	lea	av2+14,a2
	bsr	prepav
	move.l	(a7)+,a2

	lsl.l	#NDAV-1,d1
	move.l	d1,avance4+2
	exg	d2,a2
fson4:

fintpo:	move.b	tempo,ctempo
	add.l	#16,pentree
	subq.w	#1,nbentreeaj

	move.l	soundreg+4*4(pc),a1
	movem.l	d3-d6/a1-a4,soundreg
	movem.l	(sp)+,d0-a4
	rts

	endc
	

*************************************************************
*	     routines jouees en interruption		*
*************************************************************

	
	
**************** tjoue4v ****************
	
tjoue4v:
	move.l	a4,usp
	move.w	(a6)+,d7
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d7

	lea	snd_out2,a4
	adda.w	d7,a4
	move.l	(a4)+,(a5)
	move.l	(a4),d7
	movep.l	d7,(a5)
	
	move.l	usp,a4
	rte

	
snd_out2:
	incbin	d:\main\tracker.s\table2.b2

	
***************************************************
*	decodage de la chanson		*
***************************************************

inisong:
	move.b	#1,ctempo
	
	suba.l	#14,a0	| charge pointeur
	move.l	a0,pinstrs	| block instruments
	addq.l	#2,a1	| charge pointeur
	move.l	a1,ppats	| block paternes
	addq.l	#2,a2	| charge pointeurs
	move.l	a2,pdsong	| block chanson
	subq.l	#4,a2	|
	move.l	a2,psong	|
	clr.w	nbentreeaj	
	clr.w	nbrpat
	
	move.l	#dsilence,a3
	move.l	a3,a4
	move.l	a3,a5
	move.l	a3,a2
	moveq.l	#2,d3
	move.l	d3,d4
	move.l	d3,d5
	move.l	d3,d6
	
	rts

cleanay:
	move.l	a0,-(sp)
	lea	$ffff8800.w,a0
	move.l	#$00000000,(a0)
	move.l	#$01000000,(a0)
	move.l	#$02000000,(a0)
	move.l	#$03000000,(a0)
	move.l	#$04000000,(a0)
	move.l	#$05000000,(a0)
	move.l	#$0700ff00,(a0)
	move.l	(sp)+,a0
	rts

	ifne	musique	
iniprg:
	move.l	#tabj2t-4,a0
	sub.l	#(21-25)*4,a0
	move.l	a0,sadtabj2t+2

	rts

	endc

make_fond:
	move.l	ecr_fond,a1
	lea	43*160(a1),a1
	lea	fond,a0
	lea	43*160(a0),a0
	move.w	#(43*40)-1,d0
.loop1:
	move.l	-(a0),-(a1)
	dbf	d0,.loop1

	move.l	ecr_fond,a0
	lea	43*160(a0),a0
	moveq	#0,d2
	move.l	#(157*40)-1,d1
.cls:
	move.l	d2,(a0)+
	dbf	d1,.cls

	move.l	ecr_fond,a1
	lea	(200-15)*160(a1),a1
	lea	pdigit1,a0
	move.w	#(15*40)-1,d0
.loop2:
	move.l	(a0),(a1)+
	move.l	d2,(a0)+
	dbf	d0,.loop2

	rts

help_me_please:

	stop	#$2300

	movem.l	noir,d0-d6/a0
	movem.l	d0-d6/a0,$ffff8240.w

	move.l	$70.w,$200.w
	move.l	#vbl_fond,$70.w

	vsync
	move.b	#0,$ffff820a.w
	vsync
	move.b	#2,$ffff820a.w

.vide:
	ifne	clav
	move.b	$fffffc02.w,d0
	cmp.b	#$62,d0
	beq.s	.vide
	endc

	ifeq	clav
	move.b	$fffffc02.w,d0
	btst	#6,d0
	bne.s	.vide
	endc




	move.b	$ffff8201.w,$204.w
	move.b	$ffff8203.w,$205.w

	move.b	ecr_fond+1,$ffff8201.w
	move.b	ecr_fond+2,$ffff8203.w


	movem.l	pal_fond,d0-d6/a0
	movem.l	d0-d6/a0,$ffff8240.w

	move.w	#$2300,sr

	lea	texte1,a0
	bsr.s	affiche

	lea	texte2,a0
	bsr.s	affiche

	lea	texte3,a0
	bsr.s	affiche

	lea	texte4,a0
	bsr.s	affiche

	stop	#$2300

	movem.l	noir,d0-d6/a0
	movem.l	d0-d6/a0,$ffff8240.w

	move.b	$204.w,$ffff8201.w
	move.b	$205.w,$ffff8203.w

	move.l	$200.w,$70.w

	jmp	main




affiche:
	move.l	ecr_fond,a1
	move.l	#51*160,d1

	lea	table_fnt,a2

.loop:
	moveq	#0,d0
	move.b	(a0)+,d0
	blt	.sortie
	cmp.b	#$0d,d0
	bne.s	.pas_return

	
	divu	#160,d1
	add.w	#10,d1
	mulu	#160,d1
	
	addq.l	#1,a0
	bra	.next

.pas_return:
	sub.b	#32,d0
	blt	.next
	move.b	(a2,d0.w),d0
	lsl.w	#5,d0		* code fois 8
	lea	font,a4
	adda.w	d0,a4	* a4 = source font

	lea	(a1,d1.w),a3	* a3 = dest sur ecran

st	set	0
	rept	8
	move.b	(a4)+,st(a3)
	move.b	(a4)+,st+2(a3)
	move.b	(a4)+,st+4(a3)
	move.b	(a4)+,st+6(a3)
st	set	st+160
	endr

	btst	#0,d1
	bne.s	.plus_7
.plus_1:
	addq.w	#1,d1
	bra.s	.ok1
.plus_7:
	addq.w	#7,d1

.ok1:
.next:
	bra	.loop

.sortie:

	ifne	clav
.main:	cmp.b	#$62,$fffffc02.w
	bne.s	.main
	endc

	ifeq	clav
.main:	btst	#6,$fffffc02.w
	beq.s	.main
	endc

.vide:
	ifne	clav
	move.b	$fffffc02.w,d0
	cmp.b	#$62,d0
	beq.s	.vide
	endc

	ifeq	clav
	move.b	$fffffc02.w,d0
	btst	#6,d0
	bne.s	.vide
	endc

	move.l	ecr_fond,a0
	lea	51*160(a0),a0
	moveq	#0,d1
	move.w	#(133*40)-1,d0
.loopc:
	move.l	d1,(a0)+
	dbf	d0,.loopc
	
	rts


save4000to4600:
	lea	$4000.w,a0
	lea	save4000,a1
	move.w	#$600-1,d0
.loop1:
	move.b	(a0)+,(a1)+
	dbf	d0,.loop1
	rts

restore4000to4600:
	lea	$4000.w,a0
	lea	save4000,a1
	move.w	#$600-1,d0
.loop1:
	move.b	(a1)+,(a0)+
	dbf	d0,.loop1
	rts


from4000tobss:
	lea	$4000+4.w,a0

	move.l	(a0)+,ptmap
	move.w	(a0)+,demi
	move.w	(a0)+,posx
	move.w	(a0)+,posy
	move.l	(a0)+,pttabpred1
	move.l	(a0)+,pttabpred2
	move.l	(a0)+,pttabpred3
	move.l	(a0)+,pttabpred4
	move.l	(a0)+,pttabpred5
	move.l	(a0)+,pttabpred6
	move.l	(a0)+,pttabpred7
	move.l	(a0)+,pttabpred8
	move.l	(a0)+,pttabpred9
	move.l	(a0)+,pttabpred10
	move.l	(a0)+,ptlistco

	lea	listco,a1
	move.w	#800-1,d0
.loop1:
	move.b	(a0)+,(a1)+
	dbf	d0,.loop1

	move.l	(a0)+,posy_ecr
	move.w	(a0)+,posmapnr
	move.w	(a0)+,posyecr

	lea	activ1,a1
	move.w	#60-1,d0
.loop2:
	move.b	(a0)+,(a1)+
	dbf	d0,.loop2

	move.l	(a0)+,savlastco
	move.l	(a0)+,savptlistco

	rts
	
frombssto4000:
	lea	$4000.w,a0
	move.l	#'KATY',(a0)+

	move.l	ptmap,(a0)+
	move.w	demi,(a0)+
	move.w	posx,(a0)+
	move.w	posy,(a0)+
	move.l	pttabpred1,(a0)+
	move.l	pttabpred2,(a0)+
	move.l	pttabpred3,(a0)+
	move.l	pttabpred4,(a0)+
	move.l	pttabpred5,(a0)+
	move.l	pttabpred6,(a0)+
	move.l	pttabpred7,(a0)+
	move.l	pttabpred8,(a0)+
	move.l	pttabpred9,(a0)+
	move.l	pttabpred10,(a0)+
	move.l	ptlistco,(a0)+

	lea	listco,a1
	move.w	#800-1,d0
.loop1:
	move.b	(a1)+,(a0)+
	dbf	d0,.loop1

	move.l	posy_ecr,(a0)+
	move.w	posmapnr,(a0)+
	move.w	posyecr,(a0)+

	lea	activ1,a1
	move.w	#60-1,d0
.loop2:
	move.b	(a1)+,(a0)+
	dbf	d0,.loop2

	move.l	savlastco,(a0)+
	move.l	savptlistco,(a0)+

	rts
	
clearbss:
	lea	dbss,a0
.loop1
	move.b	#0,(a0)+
	cmp.l	#fbss,a0
	blt.s	.loop1
	rts
	

clavier:
			Move.w	#$2700,SR
			Lea	DataOffset(PC),A6
	* Ikbd Setup Routine
			Lea	Boot(A6),A0
			Move.w	#BootLen-1,D0
			Bsr.s	WriteToIkbd
			Lea	PauseOutput(A6),A0
			Moveq	#$0,D0
			Bsr.s	WriteToIkbd
			Lea	ControllerExecute(A6),A0
			Moveq	#$2,D0
			Bsr.s	WriteToIkbd
			Lea	Loader(A6),A1
			Moveq	#$FF-$BA,D1
SendLoader			Lea	0(A1,D1.w),A0
			Moveq	#$0,D0
			Bsr.s	WriteToIkbd
			Dbra	D1,SendLoader
			Lea	Program(A6),A1
			Moveq	#ProgramLen-1,D1
SendProgram		Lea	0(A1,D1.w),A0
			Moveq	#$0,D0
			Bsr.s	WriteToIkbd
			Dbra	D1,SendProgram
			move.w	#$2300,sr
			rts

WriteToIkbd
			Btst	#1,$FFFFFC00.w
			Beq.s	WriteToIkbd
			Move.b	(A0)+,$FFFFFC02.W
			Dbra	D0,WriteToIkbd
			Rts

	* FFFFFC02.w now reads:
	* Bit 7:	Fire
	* Bit 6:	Help
	* Bit 3:	Right
	* Bit 2:	Left
	* Bit 1:	Down
	* Bit 0:	Up

DataOffset			Equ	*
PauseOutput		Equ	*-DataOffset
			Dc.b	$13
ControllerExecute		Equ	*-DataOffset
			Dc.b	$22,$00,$B0
Boot			Equ	*-DataOffset
			Dc.b	$20,$00,$B0,$0B
			Dc.b	$0F			*B0		Sei
			Dc.b	$BE,$F9,$A1		*B1		LdS	$F9A1
			Dc.b	$DC,$11			*B4	Ready	LdD	$11
			Dc.b	$2A,$FC			*B6		Bpl	RDY
			Dc.b	$37			*B8		PshB
			Dc.b	$20,$F9			*B9		Bra	Ready
BootLen			Equ	(*-DataOffset)-Boot
Loader			Equ	*-DataOffset
			Dc.b	$00
			Dc.b	$DC,$B4			*BB		LdD	$B4
			Dc.b	$DD,$80			*BD		StD	$80
			Dc.b	$DC,$B6			*BF		LdD	$B6
			Dc.b	$DD,$82			*C1		StD	$82
			Dc.b	$DC,$B8			*C3		LdD	$B8
			Dc.b	$DD,$84			*C5		StD	$84
			Dc.b	$86,$F9			*C7		LdaA	#$F9
			Dc.b	$97,$86			*C9		StaA	$86
			Dc.b	$CC,$00,$01		*CB		LdD	#$0001
			Dc.b	$DD,$00			*CE		StD	$00
			Dc.b	$CC,$FF,$FF		*D0		LdD	#$FFFF
			Dc.b	$DD,$04			*D3		StD	$04
			Dc.b	$D7,$06			*D5		StaB	$06
			Dc.b	$8E,$00,ProgramLen+$85	*D7		LdS	#$85+ProgramLen
			Dc.b	$7E,$00,$80		*DA		Jmp	$0080
LoaderLen		Equ	(*-DataOffset)-Loader
			Ds.b	80-((LoaderLen-1)+(BootLen-4))
Program			Equ	*-DataOffset
			Dc.b	$00
Ok			Dc.b	$CC,$FF,$DF		*87	Ok	LdD	#$FFDF
			Dc.b	$97,$03			*		StaA	$03
			Dc.b	$97,$05			*		StaA	$05
			Dc.b	$DD,$06			*		StD	$06
			Dc.b	$96,$02			*		LdaA	$02
			Dc.b	$5F			*		ClrB
Up			Dc.b	$85,$02			*	Up	BitA	#$02
			Dc.b	$26,Down-(*+2)		*		Bne	Down
			Dc.b	$CA,$01			*		OraB	#$02
Down			Dc.b	$85,$10			*	Down	BitA	#$10
			Dc.b	$26,Left-(*+2)		*		Bne	Left
			Dc.b	$CA,$02			*		OraB	#$02
Left			Dc.b	$85,$08			*	Left	BitA	#$08
			Dc.b	$26,Right-(*+2)		*		Bne	Right
			Dc.b	$CA,$04			*		OraB	#$04
Right			Dc.b	$85,$20			*	Right	BitA	#$20
			Dc.b	$26,Help-(*+2)		*		Bne	Help
			Dc.b	$CA,$08			*		OraB	#$08
Help			Dc.b	$86,$EF			*	Help	LdaA	#$EF
			Dc.b	$97,$07			*		StaA	$07
			Dc.b	$96,$02			*		LdaA	$02
			Dc.b	$85,$01			*		BitA	#$02
			Dc.b	$26,Fire-(*+2)		*		Bne	Fire
			Dc.b	$CA,$40			*		OraB	#$40
Fire			Dc.b	$86,$FB			*	Fire	LdaA	#$FB
			Dc.b	$97,$07			*		StaA	$07
			Dc.b	$96,$02			*		LdaA	$02
			Dc.b	$2B,Joy-(*+2)		*		Bmi	Joy
			Dc.b	$CA,$80			*		OraB	#$80
Joy			Dc.b	$D7,$80			*	Joy	StaB	$80
			Dc.b	$86,$FE			*		LdaA	#$FE
			Dc.b	$97,$03			*		StaA	$03
			Dc.b	$4F			*		ClrA
			Dc.b	$97,$05			*		StaA	$05
			Dc.b	$96,$07			*		LdaA	$07
			Dc.b	$43			*		NotA
			Dc.b	$44			*		LsrA
			Dc.b	$44			*		LsrA
			Dc.b	$44			*		LsrA
			Dc.b	$44			*		LsrA
			Dc.b	$84,$0F			*		AndA	#$0F
			Dc.b	$7B,$04,$03		*		Bit	#$04,$03
			Dc.b	$26,Out-(*+2)		*		Bne	Out
			Dc.b	$8A,$80			*		OraA	#$80
Out			Dc.b	$9A,$80			*	Out	OraA	$80
Cts?			Dc.b	$7B,$20,$11		*	Cts?	Bit	#$20,$11
			Dc.b	$27,Cts?-(*+2)		*		Beq	Cts?
			Dc.b	$97,$13			*		StaA	$13
			Dc.b	$20,Ok-(*+2)		*		Bra	Ok
ProgramLen		Equ	(*-DataOffset)-Program

	section	data

font:	incbin	"d:\main\info\fnt"
	even


table_fnt:
	dc.b	51,28,33,51,51,51,51,32,34,35,51
	dc.b	40,31,30,26,36,50,41,42,43,44,45,46,47,48,49
	dc.b	27,51,38,51,37,29,51
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
	dc.b	51,51,51,39
	even

pal_fond:
	DC.W	$000,$223,$334,$445
	DC.W	$6C7,$526,$405,$304
	DC.W	$310,$532,$640,$753
	DC.W	$112,$556,$667,$777

texte1:
	incbin	"d:\main\info\infotex1.s"
	dc.b	-1

texte2:
	incbin	"d:\main\info\infotex2.s"
	dc.b	-1
texte3:
	incbin	"d:\main\info\infotex3.s"
	dc.b	-1
texte4:
	incbin	"d:\main\info\infotex4.s"
	dc.b	-1


	dc.l	$00002000,$000021e7,$000023eb,$0000260d	
	dc.l	$00002851,$00002ab7,$00002d41,$00002ff2	
	dc.l	$000032cb,$000035d1,$00003904,$00003c68	
tabj2t:
	dc.l	$00004000,$000043ce,$000047d6,$00004c1b
	dc.l	$000050a2,$0000556e,$00005a82,$00005fe4
	dc.l	$00006597,$00006ba2,$00007208,$000078d0
	dc.l	$00008000,$0000879c,$00008fac,$00009837
	dc.l	$0000a145,$0000aadc,$0000b504,$0000bfc8
	dc.l	$0000cb2f,$0000d744,$0000e411,$0000f1a1
	
	dc.l	$00010000,$00010f38,$00011f59,$0001306f
	dc.l	$0001428a,$000155b8,$00016a09,$00017f91
	dc.l	$0001965f,$0001ae89,$0001c823,$0001e343
	dc.l	$0001ffff,$00021e71,$00023eb3,$000260df
	dc.l	$00028514,$0002ab70,$0002d413,$0002ff22
	dc.l	$00032cbf,$00035d13,$00039047,$0003c686
	
	dc.l	$0003ffff,$00043ce3,$00047d66,$0004c1bf
	dc.l	$00050a28,$000556e0,$0005a827,$0005fe44
	dc.l	$0006597f,$0006ba27,$0007208f,$00078d0d


	ds.b	256
dsilence
	ds.b	256

cdigit1	dc.l	pdigit1
cdigit2	dc.l	pdigit1+2048
	
	ifne	musique
module:	incbin	d:\main\tracker.s\*.mod
	endc
	even
	
tab230:
st	set	0
	rept	290
	dc.l	st
st	set	st+230
	endr

table:
	incbin	"d:\main\tracker.s\hard_new.tab"

ptnomove:
	dc.l	0
	dc.l	nomove
	dc.l	nomove
	dc.l	nomove
	dc.l	nomove
	dc.l	bri

pal:
	DC.W	$000,$760,$640,$530
	DC.W	$322,$423,$534,$646
	DC.W	$526,$405,$304,$223
	DC.W	$334,$445,$556,$777

bri:
	incbin	"d:\main\krazy.bri"
	incbin	"d:\main\krazy2.bri"
	even

ptmap:	dc.l	map+28*219
sptmap:	dc.l	map+28*219

demi:	dc.w	0*8
sdemi:	dc.w	0*8

	ds.b	ligne*colonne
map:
	incbin	"d:\main\map.ter"
fmap:
	ds.b	colonne
posx:	dc.w	14*16
posy:	dc.w	8*16

posxnr:	dc.w	12*16
posynr:	dc.w	832

oldx:	dc.w	10*16
oldy:	dc.w	12*16

oldxnr:	dc.w	10*16
oldynr:	dc.w	12*16

tabpred1:
	dc.l	sprite1_1
st	set	0
	rept	15
	dc.l	sprite1_2+st
st	set	st+360
	endr

tabpred2:
	dc.l	sprite2_1
st	set	0
	rept	15
	dc.l	sprite2_2+st
st	set	st+360
	endr

tabpred3:
	dc.l	sprite3_1
st	set	0
	rept	15
	dc.l	sprite3_2+st
st	set	st+360
	endr

ptrestore11:	dc.l	sauvefond11
ptrestore12:	dc.l	sauvefond12

ptrestore21:	dc.l	sauvefond21
ptrestore22:	dc.l	sauvefond22

ptrestore31:	dc.l	sauvefond31
ptrestore32:	dc.l	sauvefond32

ptrestore41:	dc.l	sauvefond41
ptrestore42:	dc.l	sauvefond42

ptrestore51:	dc.l	sauvefond51
ptrestore52:	dc.l	sauvefond52

ptrestore61:	dc.l	sauvefond61
ptrestore62:	dc.l	sauvefond62

ptrestore71:	dc.l	sauvefond71
ptrestore72:	dc.l	sauvefond72

ptrestore81:	dc.l	sauvefond81
ptrestore82:	dc.l	sauvefond82

ptrestore91:	dc.l	sauvefond91
ptrestore92:	dc.l	sauvefond92

ptrestore101:	dc.l	sauvefond101
ptrestore102:	dc.l	sauvefond102

full:	dc.w	1

pttabpred1:	dc.l	tabpred1
pttabpred2:	dc.l	tabpred1
pttabpred3:	dc.l	tabpred1
pttabpred4:	dc.l	tabpred1
pttabpred5:	dc.l	tabpred1
pttabpred6:	dc.l	tabpred1
pttabpred7:	dc.l	tabpred1
pttabpred8:	dc.l	tabpred1
pttabpred9:	dc.l	tabpred1
pttabpred10:	dc.l	tabpred1

tab28:
st	set	0
	rept	200
	dc.w	st
st	set	st+28
	endr

tabcol:
	incbin	"d:\main\coltot.ter"
	incbin	"d:\main\coltot2.ter"
	even

sprvsspr:
	incbin	"d:\main\sprvsspr.ter"
	even

ptlistco:			* pointeur liste coordonnees
	dc.l	listco

listdemo:
	dc.w	12,63,8,0	* undead
	dc.w	15,63,7,0	* naos
	dc.w	4,211,1,0
	dc.w	4,193,2,0
	dc.w	23,193,3,0
	dc.w	14,172,4,0
	dc.w	7,115,5,0
	dc.w	21,89,6,0
	dc.w	22,52,9,0
	dc.w	7,43,10,0
	dc.w	6,30,11,0
	dc.w	18,257,12,0

fond:
	incbin	"d:\main\info\haut"	* 6880 octets
	ds.b	32256-6880

pdigit1:
	incbin	"d:\main\info\bas"	* 2400 octets
	ds.w	2048-1200


sprite1_1:
	incbin	"d:\main\sprite1.spr"
sprite1_2:
	ds.b	360*15

sprite2_1:
	incbin	"sprite2.spr"
sprite2_2:
	ds.b	360*15

sprite3_1:
	incbin	"sprite3.spr"

	section	bss
dbss:

sprite3_2:
	ds.b	360*15

listco:
	ds.b	400	* font 1664
flistco:
	ds.b	400
flistco2:

savereg:	ds.l	10	* sauvegarde lien entre remplissage 
			* dans vbl et dans fullscreen
regscroll:	ds.l	5

nomove:	ds.b	230*3

tempo	ds.b	1
ctempo	ds.b	1
nbrpat	ds.w	1
pinstrs	ds.l	1
pdsong	ds.l	1
psong	ds.l	1
ppats	ds.l	1
pentree	ds.l	1
nbentreeaj	ds.w	1

ecr_fond:	ds.l	1


olda7	ds.l	1

inc:	ds.l	1
savvbl:	ds.l	1
savhbl:	ds.l	1
sava7	ds.l	1	
oldmfp	ds.b	24
oldvec	ds.l	24

****** variables ...
noir:	ds.w	16


sauvefond11:	ds.b	16*15+4
sauvefond12:	ds.b	16*15+4

sauvefond21:	ds.b	16*15+4
sauvefond22:	ds.b	16*15+4

sauvefond31:	ds.b	16*15+4
sauvefond32:	ds.b	16*15+4

sauvefond41:	ds.b	16*15+4
sauvefond42:	ds.b	16*15+4

sauvefond51:	ds.b	16*15+4
sauvefond52:	ds.b	16*15+4

sauvefond61:	ds.b	16*15+4
sauvefond62:	ds.b	16*15+4

sauvefond71:	ds.b	16*15+4
sauvefond72:	ds.b	16*15+4

sauvefond81:	ds.b	16*15+4
sauvefond82:	ds.b	16*15+4

sauvefond91:	ds.b	16*15+4
sauvefond92:	ds.b	16*15+4

sauvefond101:	ds.b	16*15+4
sauvefond102:	ds.b	16*15+4

savebas:	ds.l	4

posy_ecr:	ds.l	1

touche:	ds.b	1
move:	ds.b	1
	even

ttr:	ds.l	1

collis1:	ds.w	1

ecr1:	ds.l	1
ecr2:	ds.l	1
ecr3:	ds.l	1
ecr4:	ds.l	1

secr1:	ds.l	1
secr2:	ds.l	1
secr3:	ds.l	1
secr4:	ds.l	1

haut:	ds.l	1
haut2:	ds.l	1
bas:	ds.l	1
bas2:	ds.l	1

posmapnr:	ds.w	1	* position non relative dans la map

posyecr:	ds.w	1
oldyecr:	ds.w	1

activ1:	ds.w	1
posx1:	ds.w	1
posy1:	ds.w	1
activ2:	ds.w	1
posx2:	ds.w	1
posy2:	ds.w	1
activ3:	ds.w	1
posx3:	ds.w	1
posy3:	ds.w	1
activ4:	ds.w	1
posx4:	ds.w	1
posy4:	ds.w	1
activ5:	ds.w	1
posx5:	ds.w	1
posy5:	ds.w	1
activ6:	ds.w	1
posx6:	ds.w	1
posy6:	ds.w	1
activ7:	ds.w	1
posx7:	ds.w	1
posy7:	ds.w	1
activ8:	ds.w	1
posx8:	ds.w	1
posy8:	ds.w	1
activ9:	ds.w	1
posx9:	ds.w	1
posy9:	ds.w	1
activ10:	ds.w	1
posx10:	ds.w	1
posy10:	ds.w	1
factiv:

sposx1:	ds.w	30

savcol:	ds.w	16

save4000:
	ds.b	$600


savlastco:	ds.l	1

savptlistco: ds.l	1

svbl:
	ds.l	1

vidos:
	ds.b	230*16

	ds.b	nbli*230
ecrans:
	ds.b	(ligne*16*230+nbli*230)*3
fbss:
 	end

	lea	tab230,a2
	move.w	posy1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a2,d0.w),d0

	move.w	posx1,d3
	lsr.w	#4,d3
	lsl.w	#3,d3

	move.l	ecr2,a1
	add.l	#debut,a1
	add.l	d0,a1
	adda.w	d3,a1

	move.l	ecr3,a0
	add.l	#debut,a0
	add.l	d0,a0	* posy1
	adda.w	d3,a0	* posx1

	move.w	#(ligne*16),d0
	sub.w	posy_ecr,d0
	sub.w	posy1,d0


	move.w	d0,d1
	
	cmp.w	#15,d1
	ble.s	.ok2
	
	moveq	#15,d1
	moveq	#15,d0
.ok2:
	move.w	#230,d6
.l1:
	subq.w	#1,d1
	blt.s	.ok1
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	adda.w	d6,a0
	adda.w	d6,a1
	move.w	#$70,$ffff8240.w
	bra.s	.l1

.ok1:

	tst.w	d0
	bge.s	.ok5
	moveq	#0,d0
.ok5:

	move.w	#(ligne*16),d2
	sub.w	posy_ecr,d2

	move.l	ecr4,a0
	add.l	#debut,a0

	move.w	posy1,d4
*	sub.w	d2,d4
	add.w	d4,d4
	add.w	d4,d4
	add.l	(a2,d4.w),a0
	

	adda.w	d3,a0	* posx1

	moveq	#15,d1
	sub.w	d0,d1

	add.w	d0,d0
	add.w	d0,d0
	add.l	(a2,d0.w),a0

*	addq.w	#1,d1
.l2:
	subq.w	#1,d1
	blt.s	.ok3
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	adda.w	d6,a0
	adda.w	d6,a1
	move.w	#$707,$ffff8240.w
	bra.s	.l2
	
.ok3:
	*


	ext.l	d1
	divs	#distance,d1	avancee a chaque x

	swap	d1
	moveq	#0,d3
	move.w	d1,d3
	swap	d1

	tst.w	d3
	bgt.s	.ng1
	neg.w	d3
.ng1:
	swap	d3
	move.w	#0,d3
	divu	#distance,d3
	tst.w	d1
	bgt.s	.ng11
	neg.l	d3
.ng11

	nop
	end


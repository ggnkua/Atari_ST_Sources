* Name          : The BOF DEMO (you see why...see the scrolltext)
* Author        : Mister Bee from The Overlanders
* Musax         : Mad Max from TEX (again !!!... )
* Graphix       : Speedlight from The Overlanders
* Inspiration   : The Megamithy Carebears
* Rmq           : All routines by myself
* Assembler     : Devpac ST 2
* Tabulation    : 10
* Included files: 18
*
* (C)decembre 1989/fevrier 1990

* NOW FOR THE COMPIL CODE 2 BY THE OVERLANDERS
* THANKS FOR YOUR DONATIONS
* OUR ADRESS :
* OVERLANDERS
* 27,CHEMIN DES CYCLAMENS
* 73000 CHAMBERY
* FRANCE.

* cette variable permet de mesurer le temp
* time = 1 on mesure le temp
* time = 0 pas de mesure du temp

time	=	0

;	opt	d-		no label in final version please...

	section	text
	
	include	macros.lib

	move.l	sp,savesp		save stack pointer
	lea	stack,sp		new stack
	supexec	main
	move.l	savesp,sp		old stack pointer
	pterm

main	getphy	phybase
	getrez	rez
	getpal	savepal
	mouseoff
	clrpal			efface la palette
	setscr	#0,phybase,#-1	low rez

	lea	font+34,a0
	move.l	phybase,a1
	bsr	unpack		decompresse le jeu de car
	bsr	calchr		effectue quelques calcul sur le set

	bsr	initscr		calcul des ad ecrans
	bsr	clrscrs		efface les ecrans
	clr	ptrscr		raz pointeur ecran courant
	bsr	nxtscr		calcul @ ecran suivant
	bsr	initbuf
	bsr	initscrll		inits for the scrolltext

	move.l	#logo,ptrlogo
	clr	ptrspotx
	clr	ptrspoty
	move	#200,ptrspotx2
	move	#200,ptrspoty2
	bsr	initspot		predecale le spot
	clr	ptrfondx
	clr	ptrfondy
	bsr	initbck		predecale le fond
	clr	ptrscrll
	move.b	tblscrll,d0
	addq.b	#8,d0
	move.b	d0,scrofs
	move.b	d0,scrofs2
	
	bsr	setvum		dessine le vumetre
	bsr	initgrd		init pour la deformation du fond
	bsr	anim_grd		init pour les differents fonds

	move	#$2700,sr		interdit les its

	move.b	$fffffa07.w,sveiera	save iera
	move.b	$fffffa09.w,sveierb	save ctrl timer c/d
	move.b	$fffffa17.w,svevr	save mfp vector register
	bclr	#4,$fffffa09.w	timer c off
	bclr	#5,$fffffa09.w	timer d off
	bclr	#3,$fffffa17.w	"automatic end of it"

	clr.b	$fffffa1b.w	timer b off
	bset	#0,$fffffa07.w	autorise timer b
	bset	#0,$fffffa13.w	demasque timer b

	move.l	$118.w,sve118
	move.l	#rte,$118.w
	move.l	$70.w,sve70
	move.l	#vbl,$70.w

	moveq	#2,d0
	bsr	musix

	move	#$2300,sr		autorise les its

sync1	move	vblsync,d0
sync2	cmp	vblsync,d0
	beq.s	sync2

	ifne	time
	move	#$7,$ff8240
	endc
	bsr	nxtanim		deformation du fond
 	bsr	afond		animation du fond et scrolltext
	bsr	rouleau		animation du rouleau
	bsr	move_spot		animation du spot
	bsr	vumetre		animation du vumetre
	bsr	anim_grd3		gestion des differents fonds
	ifne	time
	move	#$0,$ff8240
	endc

	cmp.b	#$39,$fffffc02.w	espace ?
	bne.s	sync1

	move	#$2700,sr		interdit les its
	clrpal			efface la palette
	soundoff
	bsr	clrhbl		interdit la HBL
	move.b	sveiera,$fffffa07.w
	move.b	sveierb,$fffffa09.w	ctrl timer c/d
	move.b	sveimra,$fffffa13.w
	move.b	svevr,$fffffa17.w
	move.b	svetbcr,$fffffa1b.w
	move.b	svetbdr,$fffffa21.w
	move.l	sve118,$118.w
	move.l	sve70,$70.w

	move	#$2300,sr		autorise les its

	setscr	rez,phybase,#-1
	setpal	savepal
	mouseon			autorise la souris
	rts
	
* routine de vbl 

vbl	movem.l	d0-a4,-(sp)	save regs
	move.l	#hbla,$120.w	routine hbl 1
	move.b	#1,$fffffa21.w	toute les lignes
	move.b	#8,$fffffa1b.w
	bsr	musix+8
	lea	tblrst,a6
	bsr	nxtscr		calcul @ ecran suivant
	setpal	pal_logo

	not	vblsync

	movem.l	(sp)+,d0-a4
rte	rte
	
* et maintenant quelques routines de hbl...

* cette routine change la palette pour le fond

hbla
	ifeq	time
	move	(a6)+,$ffff8240.w
	elseif
	move	(a6)+,$ffff8242.w
	endc
	bpl.s	hbla2
	clr.b	$fffffa1b.w
	move	(a6)+,$fffffa20.w	saute quelques lgs
	bne.s	hbla1
	move.b	#4,$fffffa21.w	quelques lgs plus bas
	move.l	#hblb,$120.w	ad prochaine it hbl
	move.b	#8,$fffffa1b.w
	movem.l	d0-d7,-(sp)
	ifeq	time
	setpal	pal_grd		change la palette pour le fond
	endc
	movem.l	(sp)+,d0-d7
	rte
hbla1	move.b	#8,$fffffa1b.w
hbla2	;bclr	#0,$fffffa0f.w	valide it
	rte
* cette routine fait le 2eme rouleau

hblb
	ifeq	time
	move	(a6),$ffff8240.w
	elseif
	move	(a6),$ffff8242.w
	endc
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w	tte les lgs maintenant
	move.l	#hblb2,$120.w	nouveau vecteur
	move.b	#8,$fffffa1b.w
hblb2
	ifeq	time
	move	(a6)+,$ffff8240.w
	elseif
	move	(a6)+,$ffff8242.w
	endc
	bpl.s	hblb3
	clr.b	$fffffa1b.w
	move.l	#hblc,$120.w	prochaine it hbl
	move.b	scrofs,$fffffa21.w	prochain chgt de palette
	move.b	#8,$fffffa1b.w
hblb3	;bclr	#0,$fffffa0f.w
	rte
	
* cette routine change la palette pour le scroll

hblc	clr.b	$fffffa1b.w
	move.l	#hblh,$120.w	prochaine it
	move.b	#1,$fffffa21.w	c'est l'anim du fond
	move.b	#8,$fffffa1b.w
	movem.l	d0-d7,-(sp)
	ifeq	time
	setpal	font+2		couleurs pour le scroll
	endc
	movem.l	(sp)+,d0-d7
	;bclr	#0,$fffffa0f.w	valide it
	rte


* routine de deformation pour le fond

hblh	clr.b	$fffffa1b.w	timer b off
	move.b	#1,$fffffa21.w
	move.l	#hblh1,$120.w
	move.b	#8,$fffffa1b.w
	move.l	a6,svea6
	move.l	ptranim,a6
hblh1	move.l	(a6)+,a5
	move.l	(a5)+,$ffff8258.w	color 12/13
	move.l	(a5)+,$ffff825c.w	color 14/15
	subq	#1,cptrst
	bne.s	hblh2
	clr.b	$fffffa1b.w
	move.l	svea6,a6
	move.b	#1,$fffffa21.w	change la palette pour le fd
	move.l	#hbld,$120.w
	move.b	#8,$fffffa1b.w
hblh2	;bclr	#0,$fffffa0f.w	valide it
	rte

* cette routine change la palette pour le fond

hbld	clr.b	$fffffa1b.w
	move.l	#hble,$120.w	prochaine it
	move.l	d0,-(sp)
	add.b	#70+34,scrofs
	move.b	#203,d0
	sub.b	scrofs,d0
	move.b	d0,$fffffa21.w	en bas de l'ecran
	move.l	(sp)+,d0
	move	#2,cptrst		apres 2 lignes la bordure
	move.b	#8,$fffffa1b.w
	movem.l	d0-d7,-(sp)
	ifeq	time
	setpal	pal_grd		couleurs pour le fond
	endc
	movem.l	(sp)+,d0-d7
	;bclr	#0,$fffffa0f.w	valide it
	rte

* routine d'interruption HBL (with lower border)

hble
	ifeq	time
	move	(a6),$ffff8240.w
	elseif
	move	(a6),$ffff8242.w
	endc
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w	tte les lgs maintenant
	move.l	#hble0,$120.w	nouveau vecteur
	move.b	#8,$fffffa1b.w
hble0
	ifeq	time
	move	(a6)+,$ffff8240.w
	elseif
	move	(a6)+,$ffff8242.w
	endc
	subq	#1,cptrst
	bne	hble3
	movem.l 	d0/a0,-(sp)
	moveq	#0,d0
	clr.b	$fffffa1b.w
hble1	move.b	$ffff8209,d0
	cmp.b	#$e0,d0
	bls.s	hble1
	lea	hble2-$e0(pc),a0
	jmp	(a0,d0)
hble2	rept	24
	nop
	endr
	ifeq	time
	move	(a6)+,$ffff8240.w
	elseif
	move	(a6)+,$ffff8242.w
	endc
	move.b	#0,$ffff820a.w
	nop
	move.b	#2,$ffff820a.w
	move.l	#hblf,$120.w	on change encore de routine
	move.b	#8,$fffffa1b.w
	movem.l	(sp)+,d0/a0
hble3	;bclr	#0,$fffffa0f.w
	rte

* avant derniere routine hbl (change la palette pour le vu-metre)

hblf
	ifeq	time
	move	(a6)+,$ffff8240.w
	elseif
	move	(a6)+,$ffff8242.w
	endc
	bpl.s	hblf2		on arrete ?
	movem.l	d0-d7,-(sp)
	ifeq	time
	setpal	vupal		couleurs pour le vumetre
	endc
	movem.l	(sp)+,d0-d7
	move.l	#hblg,$120.w	next routine
hblf2	;bclr	#0,$fffffa0f.w	valide it
	rte
	

* derniere routine hbl

hblg
	ifeq	time
	move	(a6)+,$ffff8240.w
	elseif
	move	(a6)+,$ffff8242.w
	endc
	bpl.s	hblg2		on arrete ?
	clr.b	$fffffa1b.w	plus d'it hbl
hblg2	;bclr	#0,$fffffa0f.w	valide it
	rte
	
* interdiction des ITs HBL

clrhbl	move.w	#8,-(sp)		timer B (IT no 8)
	move.w	#$1a,-(sp)	JDISINT (interdiction d'IT)
	trap	#14		XBIOS
	addq.l	#4,sp
	rts

* efface les buffers ecran

clrscrs	move	#4*39424/4-1,d0
	move.l	screen,a0
clrscr2	clr.l	(a0)+
	dbf	d0,clrscr2
	rts
	
* init pointeur screen

initscr	move.l	#bufscr,d0	buffer ecran
	and.l	#$ffffff00,d0	depart de l'ecran sur un multiple de 256
	move.l	d0,screen
	rts
	
* ecran suivant

nxtscr	addq	#1,ptrscr		buffer ecran suivant
	cmp	#4,ptrscr		dernier ?
	bne.s	nxtscr2		non...
	clr	ptrscr		revient au premier
nxtscr2	move	ptrscr,d0
	mulu	#39424,d0		calcul l'ad de debut du buf
	add.l	screen,d0		plus l'ad de depart du buf
	move.l	d0,crt_scr	@ ecran courant
	lsr.l	#8,d0		div 256
	movea	#$8201,a0		shifter
	movep	d0,(a0)		set ad scr
	rts

* place le cadre pour le fond dans le buffer ecran

initbuf	lea	ressorts+34,a0
	move.l	phybase,a1
	bsr	unpack		depack les ressorts

	move.l	phybase,a0
	move.l	screen,a1		ad 1er ecran
	lea	54*160(a1),a1	saute 55 lgs
	move.l	a1,a2
	adda.l	#39424,a2		2eme ecran
	move.l	a2,a3
	adda.l	#39424,a3		3eme ecran
	move.l	a3,a4
	adda.l	#39424,a4		4eme ecran

* affichage ressort haut

	move	#16*160/4-1,d0	16 lignes
initbuf2	move.l	17*160*3(a0),(a4)+
	move.l	17*160*2(a0),(a3)+
	move.l	17*160*1(a0),(a2)+
	move.l	(a0)+,(a1)+
	dbf	d0,initbuf2

* affichage des bords

	lea	-160(a0),a0

	move	#126-1,d0		126 lignes de haut
initbuf3	moveq	#160/4-1,d1	1 ligne
initbuf4	move.l	(a0),(a1)+
	move.l	(a0),(a2)+
	move.l	(a0),(a3)+
	move.l	(a0)+,(a4)+
	dbf	d1,initbuf4
	lea	-160(a0),a0	revient au debut la ligne (130 fois la meme)
	dbf	d0,initbuf3

* affichage ressort bas

	move.l	phybase,a0	pour afficher les bords
	lea	4*17*160(a0),a0

	move	#160*16/4-1,d0		15 lignes
initbuf5	move.l	17*160*3(a0),(a4)+
	move.l	17*160*2(a0),(a3)+
	move.l	17*160*1(a0),(a2)+
	move.l	(a0)+,(a1)+
	dbf	d0,initbuf5

	lea	ground+34,a0
	move.l	phybase,a1
	bsr	unpack		depack les cadres
	rts

* rouleau overlanders

htrlogo	=	50

rouleau	lea	courbe,a0		table de forme pour le rouleau
	move.l	crt_scr,a2	@ ecran
	lea	160(a2),a2
	move	#49,d0		rouleau de 50 lgs
rouleau2	move	(a0)+,d1
	move.l	ptrlogo,a1	ptr logo
	adda	d1,a1

	rept	40
	move.l	(a1)+,(a2)+
	endr
	dbf	d0,rouleau2

rouleau7	subq	#1,tp_roulo
	bne.s	rouleau6
	move	#200,tp_roulo
	neg	dir_roulo
rouleau6	move.l	ptrlogo,a1	ptr logo
	add	dir_roulo,a1
	tst	dir_roulo
	bpl.s	rouleau8
	cmpa.l	#logo,a1		plus haut que le debut du logo ?
	bhi.s	rouleau5
	adda	#htrlogo*160,a1
	bra.s	rouleau5
rouleau8	cmpa.l	#logo+htrlogo*160,a1	plus bas que la fin du logo ?
	bls.s	rouleau5
	suba	#htrlogo*160,a1
rouleau5	move.l	a1,ptrlogo
	rts

* calcul le spot predecale

initspot	lea	spot,a0
	lea	bufcir,a1

	moveq	#20,d1		le spot fait 21 lgs
initspt2	move	(a0),d0		on ne lit qu'un plan
	move	d0,(a1)+
	move	8(a0),d0
	move	d0,(a1)+
	move	16(a0),d0
	move	d0,(a1)+
	lea	32(a0),a0
	dbf	d1,initspt2	ttes les lgs

	lea	-21*6(a1),a0

	moveq	#14,d2		15 positions
initspt3	moveq	#20,d1		21 lgs
initspt4	and	#$ff00,sr		x=0
	move	(a0)+,d0
	roxr	d0
	move	d0,(a1)+
	move	(a0)+,d0
	roxr	d0
	move	d0,(a1)+
	move	(a0)+,d0
	roxr	d0
	move	d0,(a1)+
	dbf	d1,initspt4	32 lignes
	dbf	d2,initspt3
	rts
	
* gestion du spot

move_spot	lea	tblspotx,a0
	move	ptrspotx,d0
	tst	(a0,d0)
	bpl.s	spot2
	clr	ptrspotx
spot2	add	ptrspotx,a0
	move	(a0),d0		pos x

	lea	tblspoty,a0
	move	ptrspoty,d1
	tst	(a0,d1)
	bpl.s	spot3
	clr	ptrspoty
spot3	add	ptrspoty,a0
	move	(a0),d1		pos y

	addq	#2,ptrspotx
	addq	#2,ptrspoty
	
	bsr	drawspot		spot 1

	lea	tblspotx,a0
	move	ptrspotx2,d0
	tst	(a0,d0)
	bpl.s	spot4
	clr	ptrspotx2
spot4	add	ptrspotx2,a0
	move	(a0),d0		pos x

	lea	tblspoty,a0
	move	ptrspoty2,d1
	tst	(a0,d1)
	bpl.s	spot5
	clr	ptrspoty2
spot5	add	ptrspoty2,a0
	move	(a0),d1		pos y

	addq	#2,ptrspotx2
	addq	#2,ptrspoty2
	

* affichage du spot
* parms:
*       d0.w=x
*       d1.w=y

drawspot	move.l	crt_scr,a0	ecran courant
	mulu	#160,d1		ad de lg du spot
	add.l	d1,a0		plus ad ecran

	move	d0,d1
	and	#$fff0,d0
	lsr	d0
	add	d0,a0
	and	#$f,d1
	add	d1,d1
	add	d1,d1
	lea	tblcir,a1
	move.l	(a1,d1),a1
	adda.l	#bufcir,a1
	
	moveq	#20,d3
temp	set	0
drwspt3
	movem	(a1)+,d0-d2
	or	d0,temp+6(a0)
	or	d1,temp+14(a0)
	or	d2,temp+22(a0)
temp	set	temp+160
	lea	160(a0),a0
	dbf	d3,drwspt3
	rts

* predecale le font

initbck	move.l	phybase,a0
	lea	59*160+8(a0),a0	saute 60 lgs,fond 1
	lea	bufgrd,a1
	bsr	initbck1

	move.l	phybase,a0
	lea	59*160+8+32(a0),a0	saute 60 lgs,fond 2
	lea	bufgrd2,a1
	bsr	initbck1

	move.l	phybase,a0
	lea	59*160+8+16(a0),a0	saute 60 lgs,fond 3
	lea	bufgrd3,a1
	
initbck1	moveq	#31,d4
initbck2	movem.l	(a0),d0-d3	recopie le fond
	movem.l	d0-d3,(a1)	dans le 1er buffer
	movem.l	d0-d3,16*32(a1)	en doublant la hauteur (64 lgs)
	lea	16(a1),a1
	lea	160(a0),a0
	dbf	d4,initbck2	32 lignes

	lea	-32*16(a1),a0
	lea	16*32(a1),a1

	moveq	#30,d2		31 positions
initbck3	moveq	#63,d1		64 lgs
initbck4
temp	set	0
	rept	4
	move	8+temp(a0),d0
	roxr	d0
	move	temp(a0),d0
	roxr	d0
	move	d0,temp(a1)
	move	8+temp(a0),d0
	roxr	d0
	move	d0,8+temp(a1)
temp	set	temp+2
	endr
	lea	16(a0),a0
	lea	16(a1),a1	
	dbf	d1,initbck4
	dbf	d2,initbck3
	rts
	
*-------------------*
* animation du fond *
*-------------------*

afond	lea	tblfondx,a0
	adda	ptrfondx,a0
	tst	(a0)
	bpl.s	afond2
	clr	ptrfondx
	bra.s	afond
afond2	move	(a0),d0		pos x
afond3	lea	tblfondy,a0
	adda	ptrfondy,a0
	tst	(a0)
	bpl.s	afond4
	clr	ptrfondy
	bra.s	afond3
afond4	move	(a0),d1		pos y
	addq	#2,ptrfondx
	addq	#2,ptrfondy

afond5	lea	tblscrll,a0
	adda	ptrscrll,a0
	tst.b	(a0)
	bpl.s	afond6
	clr	ptrscrll
	bra.s	afond5
afond6	moveq	#0,d5
	move.b	(a0),d5
* comme la page en cours sera affiche a la prochaine trame
* on se sert de variable pour faire le chgt de palette du
* scroll. on sert de la hauteur precedente a chaque fois
	move.b	scrofs2,scrofs		
	move.b	d5,scrofs2		decalage reutilise en raster
	addq.b	#8,scrofs2
	addq	#1,ptrscrll

	movem.l	d0/d1/d5,-(sp)
	bsr	scrlline
	movem.l	(sp)+,d0/d1/d5

* affichage du fond
* d0=pos en x
* d1=pos en y
* d5=nb de a sauter pour l'affichage du scroll

drawgrd	move.l	crt_scr,a1
	lea	70*160-8(a1),a1
	move.l	ptr_grd,a0	ad du fond courant
	mulu	#32*32,d0		no du buffer=pos en x
	add.l	d0,a0
	lsl	#4,d1		ad lg=no*16
	add	d1,a0
	move.l	phybase,a2
	
* htr:hauteur de scroll
htr	=	44	doit etre>32

	moveq	#4-1,d6
drwgrd3	moveq	#32-1,d7
drwgrd4	dbf	d5,drwgrd5

	lea	-152(a1),a1	revient en debut de lg
	move.l	a1,a3
	sub.l	crt_scr,a3	a3=ad de la lg courante
	add.l	a2,a3		plus ad du buffer
	lea	-10*160(a3),a3
	
* attention ici on ne modifie que trois plan car le cadre
* est trace en gris qui est situe dans les 8 1ere couleurs de la pal

temp	set	-160*14
	rept	14
	move.l	temp(a3),temp(a1)	rectifie le bord gauche en haut
	move	temp+4(a3),temp+4(a1)
	move.l	temp+152(a3),temp+152(a1)	et le bord droit en haut
	move	temp+156(a3),temp+156(a1)
	move.l	temp+(htr+12)*160(a3),temp+(htr+12)*160(a1)	et le bord gauche bas
	move	temp+(htr+12)*160+4(a3),temp+(htr+12)*160+4(a1)
	move.l	temp+(htr+12)*160+152(a3),temp+(htr+12)*160+152(a1)	et le bord droit bas
	move	temp+(htr+12)*160+156(a3),temp+(htr+12)*160+156(a1)
temp	set	temp+160
	endr

* idem ci dessus

temp	set	temp+6*160
	rept	32
	move.l	temp(a2),temp(a1)
	move	temp+4(a2),temp+4(a1)
	move.l	temp+152(a2),temp+152(a1)
	move	temp+156(a2),temp+156(a1)
temp	set	temp+160
	endr
	
	moveq	#5,d4
drwgrd8	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	lea	144(a1),a1
	movem.l	(a2)+,d0-d3
	rept	9
	movem.l	d0-d3,-(a1)
	endr
	lea	144(a1),a1
	lea	128(a2),a2
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	dbf	d4,drwgrd8
	lea	32*160(a1),a1
	lea	32*160(a2),a2
	move	#5,d4
drwgrd9	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	lea	144(a1),a1
	movem.l	(a2)+,d0-d3
	rept	9
	movem.l	d0-d3,-(a1)
	endr
	lea	144(a1),a1
	lea	128(a2),a2
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	dbf	d4,drwgrd9
	lea	152(a1),a1

	lea	htr*16(a0),a0
;	lea	160*htr(a1),a1
	sub	#htr,d7
drwgrd7	bpl.s	drwgrd5
	subq	#1,d6
	add	#32,d7
	lea	-32*16(a0),a0
	bra.s	drwgrd7
drwgrd5	movem.l	(a0)+,d0-d3
	rept	9
	movem.l	d0-d3,-(a1)
	endr
	lea	2*160-16(a1),a1
drwgrd6	dbf	d7,drwgrd4
	lea	-32*16(a0),a0
	tst	d6
	dbmi	d6,drwgrd3
	rts

*--------------------------*
* Routine pour le vu-metre *
*--------------------------*

* met le vumetre en place

setvum	lea	vublk,a0		ad dessin vu-metre
	move.l	screen,a1		ad du 1er ecran
	adda.l	#212*160,a1	a la lg 213
	movea.l	a1,a2
	adda.l	#39424,a2		2eme ecran
	move.l	a2,a3
	adda.l	#39424,a3		3eme ecran
	move.l	a3,a4
	adda.l	#39424,a4		4eme ecran

	move	#31*160/4-1,d0	32 lgs de haut
setvum2	move.l	(a0),(a1)+
	move.l	(a0),(a2)+
	move.l	(a0),(a3)+
	move.l	(a0)+,(a4)+
	dbf	d0,setvum2
	rts
	
	
* cette routine effectue un effet de vumetre pour
* chacune des trois voies du processeur sonore.
* chaque niveau sonore (0 a 15) est represente
* par un rectangle de 8 de large par 7 de haut
* on utilise un effet de transparence en ne modifiant 
* que le 4eme plan.

vumetre	move.b	#8,$ffff8800.w	registre volume voie A
	move.b	$ffff8800.w,d0	lit le volume voie A
	andi	#$f,d0
	move.l	crt_scr,a0
	adda.l	#216*160,a0
	bsr	vumetre2		affiche le niveau

	move.b	#9,$ffff8800.w	registre volume voie B
	move.b	$ffff8800.w,d0	lit le volume voie B
	andi	#$f,d0
	move.l	crt_scr,a0
	adda.l	#224*160,a0
	bsr	vumetre2		affiche le niveau

	move.b	#10,$ffff8800.w	registre volume voie C
	move.b	$ffff8800.w,d0	lit le volume voie C	
	andi	#$f,d0
	move.l	crt_scr,a0
	adda.l	#232*160,a0

	
vumetre2	moveq	#15,d2		compteur pour l'effacement
	lea	8+6(a0),a1	on change le 4eme plan (vers la gauche)
	lea	104-8-2(a0),a0	on change le 4eme plan (vers la droite)
	
	lea	tblvu_g,a2
	lea	tblvu_d,a3
	lsl	#4,d0		vol = vol * 16
	add	d0,a2
	add	d0,a3

	movem	(a2),d0-d7

	move	d0,(a1)
	move	d0,160(a1)
	move	d0,2*160(a1)
	move	d0,3*160(a1)
	move	d0,4*160(a1)
	move	d0,5*160(a1)
	move	d0,6*160(a1)

	move	d1,8(a1)
	move	d1,160+8(a1)
	move	d1,2*160+8(a1)
	move	d1,3*160+8(a1)
	move	d1,4*160+8(a1)
	move	d1,5*160+8(a1)
	move	d1,6*160+8(a1)

	move	d2,16(a1)
	move	d2,160+16(a1)
	move	d2,2*160+16(a1)
	move	d2,3*160+16(a1)
	move	d2,4*160+16(a1)
	move	d2,5*160+16(a1)
	move	d2,6*160+16(a1)

	move	d3,24(a1)
	move	d3,160+24(a1)
	move	d3,2*160+24(a1)
	move	d3,3*160+24(a1)
	move	d3,4*160+24(a1)
	move	d3,5*160+24(a1)
	move	d3,6*160+24(a1)

	move	d4,32(a1)
	move	d4,160+32(a1)
	move	d4,2*160+32(a1)
	move	d4,3*160+32(a1)
	move	d4,4*160+32(a1)
	move	d4,5*160+32(a1)
	move	d4,6*160+32(a1)

	move	d5,40(a1)
	move	d5,160+40(a1)
	move	d5,2*160+40(a1)
	move	d5,3*160+40(a1)
	move	d5,4*160+40(a1)
	move	d5,5*160+40(a1)
	move	d5,6*160+40(a1)

	move	d6,48(a1)
	move	d6,160+48(a1)
	move	d6,2*160+48(a1)
	move	d6,3*160+48(a1)
	move	d6,4*160+48(a1)
	move	d6,5*160+48(a1)
	move	d6,6*160+48(a1)

	move	d7,56(a1)
	move	d7,160+56(a1)
	move	d7,2*160+56(a1)
	move	d7,3*160+56(a1)
	move	d7,4*160+56(a1)
	move	d7,5*160+56(a1)
	move	d7,6*160+56(a1)

	movem	(a3),d0-d7

	move	d0,(a0)
	move	d0,160(a0)
	move	d0,2*160(a0)
	move	d0,3*160(a0)
	move	d0,4*160(a0)
	move	d0,5*160(a0)
	move	d0,6*160(a0)

	move	d1,8(a0)
	move	d1,160+8(a0)
	move	d1,2*160+8(a0)
	move	d1,3*160+8(a0)
	move	d1,4*160+8(a0)
	move	d1,5*160+8(a0)
	move	d1,6*160+8(a0)

	move	d2,16(a0)
	move	d2,160+16(a0)
	move	d2,2*160+16(a0)
	move	d2,3*160+16(a0)
	move	d2,4*160+16(a0)
	move	d2,5*160+16(a0)
	move	d2,6*160+16(a0)

	move	d3,24(a0)
	move	d3,160+24(a0)
	move	d3,2*160+24(a0)
	move	d3,3*160+24(a0)
	move	d3,4*160+24(a0)
	move	d3,5*160+24(a0)
	move	d3,6*160+24(a0)

	move	d4,32(a0)
	move	d4,160+32(a0)
	move	d4,2*160+32(a0)
	move	d4,3*160+32(a0)
	move	d4,4*160+32(a0)
	move	d4,5*160+32(a0)
	move	d4,6*160+32(a0)

	move	d5,40(a0)
	move	d5,160+40(a0)
	move	d5,2*160+40(a0)
	move	d5,3*160+40(a0)
	move	d5,4*160+40(a0)
	move	d5,5*160+40(a0)
	move	d5,6*160+40(a0)

	move	d6,48(a0)
	move	d6,160+48(a0)
	move	d6,2*160+48(a0)
	move	d6,3*160+48(a0)
	move	d6,4*160+48(a0)
	move	d6,5*160+48(a0)
	move	d6,6*160+48(a0)

	move	d7,56(a0)
	move	d7,160+56(a0)
	move	d7,2*160+56(a0)
	move	d7,3*160+56(a0)
	move	d7,4*160+56(a0)
	move	d7,5*160+56(a0)
	move	d7,6*160+56(a0)

	rts
	
*------------------------*
* Routines du scrolltext * 
*------------------------*

* initialisation diverse pour le scroll
	
initscrll	clr	ptrmess		raz pointeur du message
	move	#8,cptchr		pas de car en cours d'affichage

* initialise les 4 ecrans pour le scrolltext
	
	move.l	phybase,a0
	lea	6*160(a0),a0	ad fond pour le scroll
	moveq	#0,d0
	move.b	tblscrll,d0	1ere position de l
	mulu	#160,d0		calcul l'ad de la ligne
	move	d0,lgbuf		position du scroll sur le 1er ecran
	move	d0,lgbuf+2	sur le 2eme
	move	d0,lgbuf+4	sur le 3eme
	move	d0,lgbuf+6	sur le 4eme
	move.l	screen,a1		ad du 1er ecran
	adda.l	d0,a1
	movea.l	a1,a2
	adda.l	#39424,a2		2eme ecran
	move.l	a2,a3
	adda.l	#39424,a3		3eme ecran
	move.l	a3,a4
	adda.l	#39424,a4		4eme ecran
	
	lea	8(a0),a0
	lea	8(a1),a1
	lea	8(a2),a2
	lea	8(a3),a3
	lea	8(a4),a4
	moveq	#32-1,d0		32 lignes de haut
initline1	moveq	#144/4-1,d1	144 octets par ligne
initline2	move.l	(a0),(a1)+	copie le cadre pour le scroll ds le 1er ecran
	move.l	(a0),(a2)+	ds le 2eme
	move.l	(a0),(a3)+	ds le 3eme
	move.l	(a0)+,(a4)+	ds le 4eme
	dbf	d1,initline2
	lea	16(a0),a0
	lea	16(a1),a1
	lea	16(a2),a2
	lea	16(a3),a3
	lea	16(a4),a4
	dbf	d0,initline1
	rts
	
scrlline	move.b	scrofs2,d0
	ext	d0
	add	#67,d0
	mulu	#160,d0
	move	d0,-(sp)
	bsr	scrllbuf
	move	(sp)+,d0
	bsr	scroll
	rts
	
* scroll le buffer courant d'un mot

scrllbuf	lea	lgbuf,a0
	move	ptrscr,d1		ecran courant
	add	d1,d1		word offset
	move	(a0,d1),d2	lit l'ancienne ligne
	move	d0,(a0,d1)	sauve la ligne courante
	
	move.l	crt_scr,a0	@ screen courant
	lea	2*8(a0),a0
	lea	-8(a0),a1
	
	add	d0,a1		@ destination + nouvelle lg
	add	d2,a0		@ source + ancienne lg
	
	cmp	d0,d2		lg destination>lg source ?
	bls.s	scrllbuf4		oui ...
	
	moveq	#31,d0		32 lignes
scrllbuf3	rept	17		largeur du scroll=38 mots
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	lea	3*8(a0),a0	ligne suivante
	lea	3*8(a1),a1
	dbf	d0,scrllbuf3
	rts

scrllbuf4	lea	31*160(a0),a0	on part de la derniere lg
	lea	31*160(a1),a1	et on remonte
	
	moveq	#31,d0		32 lignes
scrllbuf5	rept	17		largeur du scroll=38 mots
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	lea	3*8-160*2(a0),a0	lg precedente
	lea	3*8-160*2(a1),a1
	dbf	d0,scrllbuf5
	rts

* scroll
* methode : on fait un flipping sur 4 pages decalees de 4 pixels
* parms: d0.w = ad de la lg

scroll	addq	#1,cptchr		caractere fini de scroller ?
	cmp	#9,cptchr
	bne.s	scroll3		non...
scroll1	lea	mess,a0
	add	ptrmess,a0
	moveq	#0,d1
	move.b	(a0),d1		lit un char
	bne.s	scroll2
	clr	ptrmess
	bra.s	scroll1
	
scroll2	addq	#1,ptrmess	char suivant	
	sub	#32,d1
	add	d1,d1
	add	d1,d1		long word offset
	lea	tblchr2,a0
	move.l	(a0,d1),adchr	@ du char
	clr	cptchr		debut du car
	
scroll3	moveq	#0,d1
	move	cptchr,d1
	add	d1,d1
	add	d1,d1		long word offset
	lea	tbldec,a0
	move.l	(a0,d1),a0
	add.l	adchr,a0
	
	move	ptrscr,d1		buffer courant
	add	#2,d1		calcul le no du buffer
	and	#3,d1		a recopier dans le bord droit
	move	d1,d2
	mulu	#39424,d1		calcul l'@ du buffer
	add.l	screen,d1
	move.l	d1,a2
	lea	153-8(a2),a2	au bout de la lg
	lea	lgbuf,a3
	add	d2,d2
	move	(a3,d2),d2
	add	d2,a2

	move.l	crt_scr,a1	@ du buffer courant
	lea	152-8(a1),a1	au bout de la lg
	add	d0,a1

	moveq	#31,d0		32 lignes
scroll4	movep.l	(a2),d1		recopie ecran precedent dans ecran
	movep.l	d1,(a1)		courant octet 0 du mot (4 plans)
	movep.l	(a0),d1		mantenant on affiche le char sur
	movep.l	d1,1(a1)		les 8 derniers pixels (4 plans)
	lea	3*8(a0),a0	lg caractere suivant
	lea	160(a2),a2	lg ecran suivante
	lea	160(a1),a1	//   //     //
	dbf	d0,scroll4
	rts
	
* calcul du jeu de caractere avec le font
* l'iamge contenant le je de caractere a ete
* decompresse dans l'ecran pour ne pas occuper de buffer

calchr	lea	bufont1,a1
	lea	bufont2,a2
	lea	tblchr,a3

	moveq	#44,d7		45 chars
calchr2	move.l	(a3)+,a0		@ du chr
	add.l	phybase,a0
	move.l	phybase,a4
	lea	160*144+6*16(a4),a4	ad du fond derriere les lettres
	moveq	#31,d6		32 lignes
calchr3	moveq	#3,d5		4 plans
	movea.l	a0,a5
calchr4	moveq	#0,d2
	or	(a5),d2
	or	2(a5),d2
	or	4(a5),d2
	or	6(a5),d2
	not.l	d2
	move	(a4),d0		lit le fond
	and	d2,d0		mask
	or	(a0),d0		lit la lettre
	move	d0,(a1)		ds le 1er buffer
	moveq	#0,d0
	move	(a0),d0		lit le char
	ror.l	#4,d0		le decale de 4
	ror.l	#4,d2		decale le mask
	move	(a4),d1		lit le fond
	and	d2,d1		mask
	or	d1,d0		fond+char
	move	d0,(a2)		ds le 2eme buffer
	swap	d0		recupere les retenues sans le fond
	swap	d2
	moveq	#0,d3
	or	8(a5),d3
	or	10(a5),d3
	or	12(a5),d3
	or	14(a5),d3
	not.l	d3
	moveq	#0,d1
	move	8(a4),d1		lit le fond
	and	d3,d1		mask
	or	8(a0),d1		fond+char
	move	d1,8(a1)		ds le 1er buffer
	move	8(a4),d1		lit le fond
	ror.l	#4,d3		decale le mask
	and	d2,d1
	or	d0,d1		fond + retenues
	moveq	#0,d0
	move	8(a0),d0		lit le char
	ror.l	#4,d0		decale
	and	d3,d1
	or	d1,d0
	move	d0,8(a2)
	swap	d0
	swap	d3
	move	16(a4),16(a1)
	move	16(a4),d1		lit le fond
	and	d3,d1
	or	d1,d0
	move	d0,16(a2)
	lea	2(a0),a0		plan suivant
	lea	2(a1),a1
	lea	2(a2),a2
	lea	2(a4),a4
	dbf	d5,calchr4	4 plans
	lea	160-8(a4),a4	ligne suivante fond
	lea	160-8(a0),a0
	lea	2*8(a1),a1
	lea	2*8(a2),a2
	dbf	d6,calchr3	toute les lgs
	dbf	d7,calchr2	toutes les lettres
	rts

	
* init la table pour la deformation du fond

initgrd	lea	singrd,a0
	lea	singrd2,a1
	moveq	#32,d0		33 lignes
initgrd2	move.l	(a0)+,(a1)+
	dbf	d0,initgrd2

	lea	singrd,a0
	move.l	#tblcol,d0
initgrd3	add.l	d0,(a0)+
	cmp.l	#singrd2+33*4,a0
	bne.s	initgrd3
	
	clr	ptrsin
	rts


* prepare les vecteurs pour la deformation

nxtanim	move.l	#singrd,d0
	move	ptrsin,d1
	ext.l	d1
	add.l	d1,d0
	move.l	d0,ptranim
	addq	#4,ptrsin
	cmp	#singrd2-singrd,ptrsin
	bne.s	nxtanim2
	clr	ptrsin
nxtanim2	move	#33,cptrst
	rts


* initialisation pour la routine de changement de fond

spd_fade	=	4	vitesse du fondu
wt_fade	=	25	attente entre chaque fondu en 1/50 sec.

anim_grd	move	#wt_fade,wait
	move	#spd_fade,cptvit
	clr	dirfade		commence par un fade-in
	move	#10,ptrgrd	ptr de la table des fonds
	move.l	tblgrd,ptr_grd	ptr fond
	move.l	tblgrd+4,ptr_pal	ptr palette
	move	tblgrd+8,duree
	rts

* gestion des fonds

anim_grd3	tst	wait
	beq.s	anim_grd4
	subq	#1,wait
	rts

anim_grd4	tst	dirfade		direction du fade actuel
	bne	anim_out

* gestion du fade in

anim_in	subq	#1,cptvit		vitesse du fade
	bne	anim_end
	move	#spd_fade,cptvit
	
	move.l	#pal_grd+6*2,a0	encre 7
	move.l	ptr_pal,a1
	moveq	#0,d1
	moveq	#9,d0		10 encres
fadepal	movem	d0-d1,-(sp)

* ----------- *
*   FADE-IN   *
* ----------- *
*
* montee progressive d'un reg couleur vers une couleur d'arrivee
*
* In    : a0.l = ad color reg
*         a1.l = ad color
* Out   : d7.w = 0 : color ok 
*         d7.w <>0 : color not ok
*         a0.l = next color reg
*         a1.l = next color

fadein	move	(a0)+,d0		lit la couleur a modifier
	move	(a1)+,d1		lit la couleur d'arriver
	and	#$777,d0
	and	#$777,d1
	cmp	d1,d0		couleur deja bonne ?
	beq.s	fadein6		oui...
	moveq	#2,d6		3 composantes couleurs (rvb)
	moveq	#1,d2		compteur composante
	moveq	#7,d3		mask composante
fadein4	move	d0,d4
	move	d1,d5
	and	d3,d4		mask la composante couleur(a modifier)
	and	d3,d5		idem(d'arriver)
	cmp	d4,d5		composante ok ?
	beq.s	fadein5		oui...
	add	d2,d0		inc la composante
	and	#$777,d0
fadein5	lsl	#4,d2		compteur composante suivante
	lsl	#4,d3		mask composante suivante
	dbf	d6,fadein4
	move	d0,-2(a0)		et on remet la couleur en place
	moveq	#1,d7		la couleur n'etait pas bonne
	bra.s	fadein7
fadein6	moveq	#0,d7		couleur ok
fadein7

	movem	(sp)+,d0-d1
	add	d7,d1
	dbf	d0,fadepal

	tst	d1		fade_in ok ?
	bne	anim_end		non...

	not	dirfade		passe en fade out
	move	duree,wait
	bra	anim_end

* gestion du fade out

anim_out	subq	#1,cptvit		vitesse du fade
	bne	anim_end
	move	#spd_fade,cptvit
	
	move.l	#pal_grd+6*2,a0	encre 7
	moveq	#0,d1
	moveq	#9,d0		10 encres
fadenoir	movem	d0-d1,-(sp)

* ------------ *
*   FADE-OUT   *
* ------------ *
*
* descente progressive d'un reg couleur vers le noir
*
* In    : a0.l = ad color reg
* Out   : d7.w = 0 : color ok 
*         d7.w <>0 : color not ok
*         a0.l = next color reg
*         a1.l = next color

fadeout	move	(a0)+,d0		lit la couleur a modifier
	and	#$777,d0
	beq.s	fadeout6		couleur deja noire ? oui...
	moveq	#2,d6		3 composantes couleurs (rvb)
	moveq	#1,d2		compteur composante
	moveq	#7,d3		mask composante
fadeout4	move	d0,d4
	and	d3,d4		mask la composante couleur(a modifier)
	beq.s	fadeout5		composante ok ? oui...
	sub	d2,d0		inc la composante
	and	#$777,d0
fadeout5	lsl	#4,d2		compteur composante suivante
	lsl	#4,d3		mask composante suivante
	dbf	d6,fadeout4
	move	d0,-2(a0)		et on remet la couleur en place
	moveq	#1,d7		la couleur n'etait pas bonne
	bra.s	fadeout7
fadeout6	moveq	#0,d7		couleur ok
fadeout7

	movem	(sp)+,d0-d1
	add	d7,d1
	dbf	d0,fadenoir

	tst	d1		fade_in ok ?
	bne.s	anim_end		non...

	not	dirfade		passe en fade in

	lea	tblgrd,a0
	move	ptrgrd,d0
	tst.l	(a0,d0)		fin de la table ?
	bne.s	anim_grd5
	clr	ptrgrd		revient en debut de table
anim_grd5	add	ptrgrd,a0
	add	#10,ptrgrd
	move.l	(a0)+,ptr_grd	nouveau fond
	move.l	(a0)+,ptr_pal	nouvelle palette
	move	(a0),duree	duree
	move	#wt_fade,wait
	
anim_end	rts


	include	unpack.lib
	
	section	data

dir_roulo	dc.w	160	rouleau vers le haut
tp_roulo	dc.w	100
	
dirfade	dc.w	0	direction du fade : 0=in, 1=out
wait	dc.w	0	attente entre les fondus
cptvit	dc.w	0	compteur pour la vitesse du fondu
ptrgrd	dc.w	0	pointeur pour la table des fonds
ptr_pal	dc.l	0	pointeur palette
duree	dc.w	0	variable intermediaire pour la duree du fond

* table pour le changement des fonds avec fade_in/fade_out
* modele:
* (ad du fond predecale).l,(ad de la palette).l,(duree en 1/50 sec.).w
* ...etc...
* 0.l : fin

tblgrd	dc.l	bufgrd,pal1
	dc.w	400
	dc.l	bufgrd2,pal2
	dc.w	250
	dc.l	bufgrd2,pal4
	dc.w	250
	dc.l	bufgrd,pal5
	dc.w	400
	dc.l	bufgrd2,pal3
	dc.w	250
	dc.l	bufgrd3,pal4
	dc.w	400
	dc.l	bufgrd2,pal6
	dc.w	200
	dc.l	bufgrd2,pal5
	dc.w	300
	dc.l	bufgrd,pal1
	dc.w	400
	dc.l	bufgrd3,pal3
	dc.w	400
	dc.l	bufgrd,pal4
	dc.w	300
	dc.l	bufgrd2,pal1
	dc.w	250
	dc.l	bufgrd2,pal2
	dc.w	200
	dc.l	bufgrd3,pal1
	dc.w	350
	dc.l	bufgrd,pal5
	dc.w	400
	dc.l	bufgrd,pal4
	dc.w	300
	dc.l	bufgrd3,pal6
	dc.w	400
	dc.l	bufgrd,pal1
	dc.w	350
	dc.l	bufgrd2,pal6
	dc.w	400
	dc.l	bufgrd2,pal1
	dc.w	250
	
	dc.l	0		fini
	

pal1	dc.w	$750,$740,$630,$520,$401,$300		marron/orange
	dc.w	$333,$444,$555,$666

pal2	dc.w	$764,$654,$544,$334,$224,$003		bleu/jaune
	dc.w	$333,$444,$555,$666

pal3	dc.w	$764,$654,$543,$432,$321,$200		bleu
	dc.w	$320,$430,$540,$650

pal4	dc.w	$707,$606,$505,$403,$302,$100		violet
	dc.w	$333,$444,$555,$666

pal5	dc.w	$074,$064,$053,$042,$031,$020		vert
	dc.w	$333,$444,$555,$666

pal6	dc.w	$764,$654,$544,$433,$323,$202		violet/jaune
	dc.w	$333,$444,$555,$666

pal_grd	dc.w	$000,$777,$666,$555,$444,$333,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

musix	incbin	\bofdemo.ovr\warp2.b
	even

* table pour le vumetre
* avant il etait calcule, mais c'est trop long

tblvu_g	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00ff
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$ffff
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$00ff,$ffff
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$ffff,$ffff
	dc.w	$0000,$0000,$0000,$0000,$0000,$00ff,$ffff,$ffff
	dc.w	$0000,$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff
	dc.w	$0000,$0000,$0000,$0000,$00ff,$ffff,$ffff,$ffff
	dc.w	$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff
	dc.w	$0000,$0000,$0000,$00ff,$ffff,$ffff,$ffff,$ffff
	dc.w	$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$0000,$0000,$00ff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$0000,$0000,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$0000,$00ff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$0000,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$00ff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff

tblvu_d	dc.w	$ff00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ff00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ff00,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ff00,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ff00,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ff00,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ff00,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ff00
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff

tblspotx	incbin	\bofdemo.ovr\spotx.tbl
	dc.w	-1
tblspoty	incbin	\bofdemo.ovr\spoty.tbl
	dc.w	-1
tblfondx	incbin	\bofdemo.ovr\fondx.tbl
	dc.w	-1
tblfondy	incbin	\bofdemo.ovr\fondy.tbl
	dc.w	-1
tblscrll	incbin	\bofdemo.ovr\scroll.tbl
	dc.b	-1
	even

font	incbin	\bofdemo.ovr\metalic.pc1
	even
logo	incbin	\bofdemo.ovr\plaque.blk
	incbin	\bofdemo.ovr\plaque.blk

spot	incbin	\bofdemo.ovr\spot.blk

vublk	incbin	\bofdemo.ovr\vumetre.blk

ground	incbin	\bofdemo.ovr\ground.pc1
	even
ressorts incbin	\bofdemo.ovr\ressorts.pc1
	even
courbe	incbin	\bofdemo.ovr\rouleau.tbl
	even

pal_logo	dc.w	$000,$200,$300,$411,$421,$522,$532,$643	palette pour
	dc.w	$411,$421,$522,$532,$643,$754,$765,$776	la plaque

tblrst	dc.w	$002,$003,$f004,3,$f005,3,$f006,5,$f007,3
	dc.w	$f117,2,$f227,2,$f337,1,$447,$557,$f667,4,$f557,1,$447,$337,$f227,2,$f117,3
	dc.w	$f007,3,$f006,5,$f005,3,$f004,3,$f003,1,$000,$f000,0

	dc.w	$333,$444,$555,$666,$777,$666,$555,$444,$333
	dc.w	$f000		rechgt de routine
	dc.w	$000,$000,$000
	dc.w	$333,$444,$555,$666,$777,$666,$555,$444,$333
	dc.w	$000,$000,$f000	rechgt de routine
	dc.w	$000,$000,$000
	dc.w	$003,$004,$005,$006,$005,$004,$003
	dc.w	$000
	dc.w	$003,$004,$005,$006,$005,$004,$003
	dc.w	$000
	dc.w	$003,$004,$005,$006,$005,$004,$003
	dc.w	$f000		plus de hbl

vupal	dc.w	$000,$000,$003,$004,$005,$006,$006,$005,$004
	dc.w	$000,$000,$440,$550,$660,$770,$777,$777,$777
	
temp	set	0
tblcir	rept	16
	dc.l	temp
temp	set	temp+21*2*3
	endr

	
* table de decalage des caracteres
* largeur d'un car=4*9=36 pix

tbldec	dc.l	bufont2
	dc.l	bufont1
	dc.l	bufont2+1
	dc.l	bufont1+1
	dc.l	bufont2+8
	dc.l	bufont1+8
	dc.l	bufont2+9
	dc.l	bufont1+9
	dc.l	bufont2+16

* table d'ad des lettres

tblchr	dc.l	144*160+16*4	space
temp	set	0
	rept	10
	dc.l	8*160+16*temp	A-J
temp	set	temp+1
	endr
temp	set	0
	rept	10
	dc.l	42*160+16*temp	K-T
temp	set	temp+1
	endr
temp	set	0
	rept	10
	dc.l	76*160+16*temp	U-3
temp	set	temp+1
	endr
temp	set	0
	rept	10
	dc.l	110*160+16*temp	4-9 ? ! : .
temp	set	temp+1
	endr
	dc.l	144*160		(
	dc.l	144*160+16	)
	dc.l	144*160+16*2	,
	dc.l	144*160+16*3	'

tblchr2	dc.l	0		space
	dc.l	3*8*32*38		!
	rept	5
	dc.l	0		"-&
	endr
	dc.l	3*8*32*44		'
	dc.l	3*8*32*41		(
	dc.l	3*8*32*42		)
	dc.l	0		*
	dc.l	0		+
	dc.l	3*8*32*43		,
	dc.l	0		-
	dc.l	3*8*32*40		.
	dc.l	0		/
temp	set	27
	rept	10
	dc.l	3*8*32*temp	0-9
temp	set	temp+1
	endr
	dc.l	3*8*32*39		:
	dc.l	0		;
	dc.l	0		<
	dc.l	0		=
	dc.l	0		>
	dc.l	3*8*32*37		?
	dc.l	0		@
temp	set	1
	rept	26
	dc.l	3*8*32*temp	A-Z
temp	set	temp+1
	endr
	
* table de couleur pour la deformation du fond

tblcol	dc.w	$401,$502,$603,$502
	dc.w	$502,$401,$502,$603
	dc.w	$603,$502,$401,$502
	dc.w	$502,$603,$502,$401

singrd	incbin	\bofdemo.ovr\singrd.tbl
singrd2	ds.l	33

* pas de commande pour le message pour le moment

mess	include	\bofdemo.ovr\text.s
	dc.b	0
	even


	section	bss
	

phybase	ds.l	1
logbase	ds.l	1
rez	ds.w	1
savepal	ds.w	16
ptrlogo	ds.l	1		pointeur logo overlanders
ptrspotx	ds.w	1
ptrspoty	ds.w	1
ptrspotx2	ds.w	1
ptrspoty2	ds.w	1
ptrfondx	ds.w	1
ptrfondy	ds.w	1
ptrscrll	ds.w	1
cptrst	ds.w	1
vblsync	ds.w	1
scrofs	ds.w	1
scrofs2	ds.w	1

sve70	ds.l	1		save ptr vbl
sve118	ds.l	1		save vecteur clavier
sve120	ds.l	1		save ptr hbl
sveierb	ds.b	1		save reg mfp IERB
svetbdr	ds.b	1		save reg mfp TBDR
sveiera	ds.b	1
sveimra	ds.b	1
svetbcr	ds.b	1
svevr	ds.b	1		save mfp vector register
	even
savesp	ds.l	1		save stack pointer
	
ptrmess	ds.w	1
cptchr	ds.w	1
adchr	ds.l	1
lgbuf	ds.w	4

ptrsin	ds.w	1
svea6	ds.l	1
ptranim	ds.l	1

ptr_grd	ds.l	1		ptr sur le buffer du fond courant

bufont1	ds.b	3*8*32*45		45 caracteres/32 lignes
bufont2	ds.b	3*8*32*45

bufcir	ds.b	6*21*16		buffer pour le spot
bufgrd	ds.b	16*32*64		buffer pour le font 1
bufgrd2	ds.b	16*32*64		buffer pour le font 2
bufgrd3	ds.b	16*32*64		buffer pour le font 3

	ds.l	100		stack area
stack	ds.l	1

ptrscr	ds.w	1		compteur d'ecran (1 a 4)
screen	ds.l	1		ad 1ere ecran
crt_scr	ds.l	1		ad ecran courant

* reserve 4 buffers ecrans en 245 lgs
* taille ecran en 245 lgs:32000+45*160=39200 octets
* mais 39200/256=153.125 donc 39200 n'est pas un multiple de 256
* d'ou 154*256=39424 , taille totale:39424*4=157696 octets

	ds.b	256		ad ecran=multiple de 256
bufscr	ds.l	39424

	end

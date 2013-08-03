;
; ce que ce source contient :
;
;	- d‚placement du vaisseau du joueur
;	- cr‚ation des ennemis
;	- d‚placement des ennemis
;	- d‚placement tirs du vaisseau
;	- d‚placement tirs ennemis=memes algos que d‚placements ennemis
;	- test collisions vaisseau/ennemis
;	- test collisions vaisseau/tirs ennemis
;	- test collisions tirs vaisseau/ennemis
;	- test collisions tirs vaisseau/tirs ennemis
;	- test collisions d‚cor/vaisseau
;	- test collisions d‚cor/ennemis
;	- test collisions d‚cor/tirs
;	- test collisions d‚cor/tirs ennemis
;
	ifeq	1
;
; algorithmes d'intelligence divers
;
intel1		;cherche … obtenir Y=Yvaisseau (ne revient pas en arriŠre)
	tst	d1		;direction en Y
	bne.s	1$
	cmp	yvaisseau\w,d4
	sgt	d1		;si  > -> $FFFF
	add.b	d1,d1		;si <= -> $0001
	addq	#1,d1
	ext	d1
1$	add	d1,d4
	cmp	yvaisseau\w,d4
	sgt	d5
	eor.b	d1,d5
	bpl.s	cont		;vaisseau pas d‚pass‚
;
; vaisseau d‚pass‚ -> on se d‚place en X une fois et on bloque la direction
;
	bra	cont
intel1bis
	tst	d1
	beq	bug
	add	d1,d3		;d‚placement en X
	cmp	#350,d3
	bge.s	degage		;X>=320
	cmp	#-50,d3
	ble.s	degage		;X<=-30
	bra	cont
intel2		;cherche … obtenir X=Xvaisseau
	tst	d1		;direction en Y
	bne.s	1$
	cmp	xvaisseau\w,d3
	sgt	d1
	add.b	d1,d1
	addq	#1,d1
	ext	d1
1$
	add	d1,d3
	cmp	xvaisseau\w,d3
	sgt	d5
	eor.b	d1,d5
	bpl.s	cont		;vaisseau pas d‚pass‚
;
; vaisseau d‚pass‚ -> on se d‚place en Y une fois et on bloque la direction
;
	bra	cont
intel2bis
	tst	d1
	beq	bug
	add	d1,d4
	cmp	#250,d4
	bge.s	degage
	cmp	#-50,d4
	ble.s	degage		;si Y>=200 ou Y<=-30 d‚gage
	bra.s	cont
intel3		;cherche … obtenir X=Xvaisseau, Y=Yvaisseau
		;ne revient pas en arriŠre
		;continue sa course … l'infini
;
; calcule le d‚placement :
;
;	d‚placement en X=((Xvaisseau-X)/(Yvaisseau-Y))*16
;	d‚placement en Y=((Yvaisseau-Y)/(Xvaisseau-X))*16
;
;	si +infini -> 0 !!!
;
; d1=pointeur sur table contenant les informations suivantes :
;
;	0.W=d‚placement en X*16
;	2.W=d‚placement en Y*16
;	4.B=d‚cimales X*16
;	5.B=d‚cimales X*16
;
;	move	pentex,d5
;	move	d5,d6
;	asr	#4,d5
;	asl	#4,d6
;	add.b	d6,d‚cimales X
;	addx	d5,x
;
	bra	cont
intel3bis
;
; d‚placement de l'objet
;
	bra	cont

	endc
initgestion
;
; initialise le vaisseau
;
	move	#200-hauvais,coordy\w
	move	#320/2,coordx\w
	move.l	#vitnul,vites\w
	clr	penche\w
;
; initialise les tirs
;
	clr	freqtir\w
	move.l	#tirs,fintir\w
;
; initialise les d‚cors mobiles
;
	clr	freqrot\w
	move.l	#mouvdec,ptrdec\w
;
; initialise les sprites
;
	move.l	#sprites,ptrsprite\w
	clr	freqsprite\w
	move.l	#apparait1,ptrapp\w
	rts
;
; variables pour la gestion des sprites
;
coordx	ds.w	1
coordy	ds.w	1
freqtir	ds.w	1
fintir	ds.l	1
tirs	ds.w	20*10		;num‚ro sprite.W,X.w,Y.w,Dx.w,Dy.w
				; si Y<0 -> pas de tir

freqrot	ds.w	1		;fr‚quence de rotation des canons
ptrdec	ds.l	1
mouvdec	ds.w	3*20		;20 d‚cors en mouvement possibles
				;3 Words par d‚cor (num‚ro et Y et X)
;
; paramŠtres n‚c‚ssaires pour les sprites :
;
;	0.w	type de l'ennemi=offset branchement
;	2.w	ptr dans s‚quence
;		 ou autre si comportement pas d‚bile
;	4.w	num‚ro de sprite
;	6.w	coord X
;	8.w	coord Y
;	10.w	largeur en pixels
;	12.w	hauteur en pixels
;
ptrsprite	ds.l	1
sprites		ds.b	14*maxspr	;cf au-dessus
finsprites	ds.b	0
freqsprite	ds.w	1
ptrapp		ds.l	1		;pointeur apparitions

freqacc	ds.w	1	;frequence pour acc‚l‚rer
vitrel	ds.w	1	;vitesse d'acc‚l‚ration
vites	ds.l	1
penche	ds.w	1		;indique la position pench‚e
posvais	ds.w	1		;indique la position du vaisseau

;
; gestion des sprites
;
appennemis
;
; 1) apparition des sprites
;
	move.l	ptrsprite\w,a0
	cmp.l	#sprites,a0
	bne.s	.deja
	move.l	#apparait1,ptrapp\w
	clr	freqsprite\w
.deja
	subq	#1,freqsprite\w
	bpl.s	.nonew

	cmp.l	#finsprites,a0
	bhs.s	.nonew			;si d‚j… max sprites ‡a suffit...

	move.l	ptrapp\w,a1
	move.b	(a1)+,d0		;nb sprites apparaissant
	beq.s	.nonew

	ext	d0
	moveq	#0,d1
	move.b	(a1)+,d1
	move	d1,freqsprite\w
	lea	comportements(pc),a2
	lea	pixels\w,a3
.genere
	move.b	(a1)+,d1
	add.b	d1,d1
	move	(a2,d1.w),(a0)+		;type d'ennemi
	move.b	(a1)+,d1		;num‚ro du premier sprite
	move	(a1)+,(a0)+		;ptrseq
	addq.b	#vais,d1
	move	d1,(a0)+		;poke rot0
	move	(a1)+,(a0)+		;X0
	move	(a1)+,(a0)+		;Y0

	add	d1,d1
	add	d1,d1
	move.l	(a3,d1),(a0)+		;largeur et hauteur
	subq	#1,d0
	bne.s	.genere

	move.l	a0,ptrsprite\w
	move.l	a1,ptrapp\w
.nonew
	rts
depennemis
;
; 2) d‚placement des sprites
;
	lea	sprites\w,a0
	move.l	a0,a1
	lea	sequence1(pc),a2
movesp
	cmp.l	ptrsprite\w,a0
	bhs.s	nomove
	movem	(a0)+,d0/d1/d2/d3/d4
;
; d0=type d'ennemi
; d1=ptr s‚quence
; d2=num‚ro de sprite
; d3=coord X
; d4=coord Y
;
	tst	d0
	bmi.s	degage
	beq.s	.pabug
	tst	1.w
.pabug
	move.b	vitrel\w,d5
	ext	d5
	add	d5,d4			;Y=Y+vitesse scroll
	jmp	bouge(pc,d0.w)
bouge
debile
	move.l	a2,a3
	add	d1,a3

	move.b	(a3)+,d5
	add.b	d5,d2		;delta rotation
	neg.b	d5
	bvs.s	degage		;teste si $80 !!!
	move.b	(a3)+,d5	;delta X
	ext	d5
	add	d5,d3
	move.b	(a3)+,d5	;delta Y
	ext	d5
	add	d5,d4
	addq	#3,d1
	movem	d0/d1/d2/d3/d4,(a1)
	lea	10(a1),a1
	move.l	(a0)+,(a1)+	;copie taille
	bra.s	movesp
degage
	addq	#4,a0		;skippe taille
	bra.s	movesp
nomove
	move.l	a1,ptrsprite\w
	rts

comportements
	dc.w	debile-bouge	;comportement num‚ro 0

collisions
;
; tests de collisions
;
	lea	tirs\w,a0
	cmp.l	fintir\w,a0
	bhs.s	.notest
	move.l	a0,a1
.test
	addq	#2,a0
	move	(a0)+,d0	;coord X du tir
	move	(a0)+,d1	;coord Y du tir
	move	(a0)+,d2	;largeur DX1
	move	(a0)+,d3	;hauteur DY1

	move	d1,d4
	add	d3,d4
	ble.s	.disp		;si hors ‚cran en Y-> d‚gage

	lea	sprites\w,a2
	cmp.l	ptrsprite\w,a2
	bhs.s	.nodisp
.tst1
;
; disposition bizarre afin de tout traiter en registres
;
; ici d0=X1,d1=Y1,d2=DX1,d3=DY1
;
	tst	(a2)
	bmi.s	.skippe			;si num‚ro sprite n‚gatif->rien
	addq	#6,a2			;skippe type+s‚quence+num‚ro sprite
	movem	(a2)+,d4/d5/d6/d7
;
; d4=coord X2
; d5=coord Y2
; d6=largeur=DX2
; d7=hauteur=DY2
;
; pour tester les 2 carr‚s :
;
;	-DX2<=X2-X1<DX1
;	-DY2<=Y2-Y1<DY1
;
	sub	d0,d4
	cmp	d2,d4
	blo.s	.colis1
	add	d6,d4		;+largeur
	bcc.s	.suivant
.colis1
	sub	d1,d5
	cmp	d3,d5
	blo.s	.collis
	add	d7,d5		;+hauteur
	bcc.s	.suivant
.collis
	move	#-1,-14(a2)	;change type du sprite
	move	#-1,-10(a2)	;change num‚ro de sprite
	bra.s	.disp		;enlŠve tir
.skippe	lea	14(a2),a2	;skippe sprite
.suivant
	cmp.l	ptrsprite\w,a2
	blo.s	.tst1
.nodisp
	move	-10(a0),(a1)+
	move	d0,(a1)+
	move	d1,(a1)+
	move	d2,(a1)+
	move	d3,(a1)+
.disp
	cmp.l	fintir\w,a0
	blo.s	.test
	move.l	a1,fintir\w
.notest
	rts

deplacevaisseau
	movem	xmouse\w,d0-d1
	sub	d0,xmouse\w
	sub	d1,ymouse\w
;	muls	#$7777,d0		;65536*2/5 ???
;	muls	#$7777,d1
;	swap	d0
;	swap	d1

accelere
	btst	#0,lastclk\w
	beq.s	.paacc

	add	d1,freqacc\w
	move	freqacc\w,d1
	cmp	#-resacc,d1
	bge.s	.pa1

	add	#resacc,freqacc\w
	cmp.b	#2,vitrel\w
	bhs.s	.pa2
	addq.b	#1,vitrel\w
	bra.s	.pa2
.pa1
	cmp	#resacc,d1
	ble.s	.pa2

	sub	#resacc,freqacc\w
	tst.b	vitrel\w
	beq.s	.pa2
	subq.b	#1,vitrel\w
.pa2
	moveq	#0,d1
.paacc

;	add	#resx,d0
;	cmp	#resx*2,d0
;	blo.s	.xok1
;	spl	d0
;	and	#resx*2,d0
;.xok1
;	sub	#resx,d0

	cmp	#-resx,d0
	bgt.s	.xok1
	moveq	#-resx,d0
.xok1
	cmp	#resx,d0
	blt.s	.xok2
	moveq	#resx,d0
.xok2

	cmp	#-resy,d1
	bgt.s	.yok1
	moveq	#-resy,d1
.yok1
	cmp	#resy,d1
	blt.s	.yok2
	moveq	#resy,d1
.yok2
	move	penche\w,posvais\w

	move	coordx\w,penche\w

	add	d0,coordx\w
	add	d1,coordy\w

	moveq	#0,d1
	move.l	vites\w,a0
	move.b	(a0)+,d1
	lea	vitnul(pc),a1

	move.b	stick1\w,d0
	tst.b	tabkey+$48\w
	bne.s	.haut
	btst	#0,d0
	beq.s	1$
.haut	sub	d1,coordy\w
	move.l	a0,a1
1$
	tst.b	tabkey+$50\w
	bne.s	.bas
	btst	#1,d0
	beq.s	2$
.bas	add	d1,coordy\w
	move.l	a0,a1
2$
	tst.b	tabkey+$4b\w
	bne.s	.gauche
	btst	#2,d0
	beq.s	3$
.gauche	sub	d1,coordx\w
	move.l	a0,a1
3$
	tst.b	tabkey+$4d\w
	bne.s	.droit
	btst	#3,d0
	beq.s	4$
.droit	add	d1,coordx\w
	move.l	a0,a1
4$
	cmp.l	#vitfin,a1
	blo.s	5$
	subq	#1,a1
5$
	move.l	a1,vites\w

	cmp	#319,coordx\w
	bls.s	.bornex
	sgt	d1
	ext	d1
	and	#319,d1
	move	d1,coordx\w
.bornex
	cmp	#199,coordy\w
	bls.s	.borney
	sgt	d1
	ext	d1
	and	#199,d1
	move	d1,coordy\w
.borney
	move	penche\w,d1
	sub	coordx\w,d1
	beq.s	penche0
	bpl.s	penche1
	moveq	#2,d1
	bra.s	penche0
penche1
	moveq	#1,d1
penche0
	move	d1,penche\w

	and	d1,posvais\w	;AND pour connaitre inclinaison du vaisseau

	subq	#1,freqtir\w
	bpl.s	.patire
	clr	freqtir\w

	tst.b	tabkey+$39\w
	bne.s	.tire		;espace ??
	tst.b	d0
	bmi.s	.tire
	btst.b	#1,lastclk\w
	beq.s	.patire
.tire
	move.l	fintir\w,a0
	moveq	#sprtir,d0
	move	d0,(a0)+
	move	coordx\w,(a0)+
	move	coordy\w,(a0)+
	lea	pixels\w,a1
	add	d0,d0
	add	d0,d0
	move.l	(a1,d0),(a0)+		;dX et dY
	move.l	a0,fintir\w
	move	#5,freqtir\w
.patire
	rts

deplacetirs
;
; d‚place les tirs
;
	lea	tirs\w,a0
	move.l	fintir\w,a1
	cmp.l	a1,a0
	bhs.s	.patir
	move.l	a0,a2
.tirons
	move	4(a0),d0
	subq	#8,d0		;Y change
	move	(a0),(a2)+
	move	2(a0),(a2)+
	move	d0,(a2)+
	move	6(a0),(a2)+	;Dx
	move	8(a0),(a2)+	;Dy
;.disparait
	lea	10(a0),a0
	cmp.l	a1,a0
	blo.s	.tirons
	move.l	a2,fintir\w
.patir
	rts

deplacedecor
;
; r‚affiche le d‚cor qui change
;
	lea	mouvdec\w,a0
	cmp.l	ptrdec\w,a0
	bhs	noafd1
	move.l	screen\w,a6	;adresse ‚cran
	move.l	a0,a1		;ptr de r‚‚criture
afd1
	moveq	#0,d0
	move	(a0)+,d0
	tst	freqrot\w
	bne.s	1$
	addq	#1,d0
	cmp	#62,d0
	bls.s	1$
	moveq	#55,d0
1$	move	d0,(a1)+	;d0=num‚ro du d‚cor

	moveq	#0,d1
	move	(a0)+,d1
	move	d1,(a1)+
	move	(a0)+,d2	;offset X
	move	d2,(a1)+

	sub	cptscr\w,d1
	beq	nxtd1		;si vient juste de rentrer -> rien
	neg	d1

	lea	decor-512,a2
	asl	#8,d0
	add.l	d0,d0		;.W si moins de 128 d‚cors !!!
	add.l	d0,a2
	move.l	a6,a3
	add	d2,a3

	cmp	#32*160,d1
	blo.s	cliphau1
	cmp	#200*160,d1
	blo.s	noclip0

	cmp	#(200+32)*160,d1
	bhs.s	dispart

	add.l	d1,a3
	sub	#160*200,d1
	move.l	d1,d3
	lsr	#4,d1			;/160*10
	divu	#160/16,d3
	add	d3,a2
	jmp	noclipe(pc,d1.w)
dispart
	subq	#6,a1			;disparait de l'‚cran
	bra	nxtd1
cliphau1
	lea	32*160(a3),a3
	sub	#32*160,d1
	neg	d1
	lsr	#4,d1			;/160*10
	jmp	noclipe(pc,d1.w)
noclip0
	add	d1,a3			;OK
noclipe
x	set	-160
	rept	32
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,x(a3)
x	set	x-160
	endr
nxtd1
	cmp.l	ptrdec\w,a0
	blo	afd1
	move.l	a1,ptrdec\w	;nouveau pointeur
noafd1
	subq	#1,freqrot\w
	bpl.s	.norot
	move	#20-1,freqrot\w
.norot
	rts
;
; d‚placement num‚ro 1
;
; les sprites viennent du haut et forment un accent circonflexe
;  puis de barrent vers le haut
;
sequence1:
	rept	50
	dc.b	0,2,2
	endr
	rept	50
	dc.b	0,0,0
	endr
	rept	100
	dc.b	0,0,-5
	endr
	dc.b	$80	;fin s‚quence
	even
sequence2:
	rept	50
	dc.b	0,-2,2
	endr
	rept	50
	dc.b	0,0,0
	endr
	rept	100
	dc.b	0,0,-5
	endr
	dc.b	$80

	even
dy:equ 40
apparait1
	dc.b	10,0	;10 sprites apparaissent
;1
	dc.b	0	;comportement idiot
	dc.b	0	;rot 0
	dc.w	0	;sequence1-sequence1
	dc.w	-20,60-dy	;X0,Y0
;2
	dc.b	0,0
	dc.w	0
	dc.w	0,40-dy
;3
	dc.b	0,0
	dc.w	0
	dc.w	20,20-dy
;4
	dc.b	0,0
	dc.w	0
	dc.w	40,0-dy
;5
	dc.b	0,0
	dc.w	0
	dc.w	60,-20-dy
;6
	dc.b	0,0
	dc.w	sequence2-sequence1
	dc.w	280,-20-dy
;7
	dc.b	0,0
	dc.w	sequence2-sequence1
	dc.w	300,0-dy
;8
	dc.b	0,0
	dc.w	sequence2-sequence1
	dc.w	320,20-dy
;9
	dc.b	0,0
	dc.w	sequence2-sequence1
	dc.w	340,40-dy
;10
	dc.b	0,0
	dc.w	sequence2-sequence1
	dc.w	360,60-dy

	dc.b	0		;no more sprites
	even

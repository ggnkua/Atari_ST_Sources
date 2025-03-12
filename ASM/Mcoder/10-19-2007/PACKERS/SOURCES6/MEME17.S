;
; super-compacteur optimiseur
;  (mono-passe)
;
; compacte 1 fichier en 2 zones :
;	- la zone pr‚fixe contient tous les pr‚fixes de compactage
;	- la zone data contient tous les octets … transf‚rer
;
; optimisation … effectuer :
;
;	- l'optimum ne doit etre g‚n‚r‚ qu'au dernier moment !!!
;	aprŠs toutes les m‚thodes de compactage
;	et non aprŠs chaque essai
;
;	- g‚rer une deuxieme passe pour optimiser le segment
;	PREFIX (notamment les non-compactages de plus de 256)
;
; un codage de Huffmann sur ces 2 zones s‚par‚es
;   doit am‚liorer la m‚thode
;
file:	equ	$60000
fin:	equ	$60000+91784
prefix:	equ	$40000
datas:	equ	$50000

	lea	file,a6
	lea	fin,a3
	lea	prefix,a4
	lea	datas,a5
compact:
;
; on recherche la meilleure m‚thode de compression
;  en commen‡ant par les meilleures !!!
;
; 1) r‚p‚tition d'octets
;
	moveq	#0,d7		;16 octets ???
	moveq	#0,d5		;nb octets gagn‚s
; on m‚morise le premier octet dans D4 pour acc‚l‚rer
	move.b	(a6),d4
rep1:
	cmp.b	1(a6,d7.w),d4
	bne.s	nxtrep

	move.l	a6,a0
	lea	1(a6,d7.w),a1
	moveq	#0,d0
comp0:	addq	#1,d0
	beq.s	comp2
	move	d7,d6
	cmp.l	a3,a1
	bhs.s	comp2
comp1:	cmpm.b	(a0)+,(a1)+
	dbne	d6,comp1
	beq.s	comp0
comp2:	subq	#1,d0
	beq.s	nxtrep
;
; on prend le maximum d'octets gagn‚s par cette m‚thode
;
; ici d0=nb r‚p‚titions-1
;     d7=longueur de la chaine qui se r‚pŠte -1
;     d5=meilleur total d'octets gagn‚s
;
	addq	#1,d7
	move	d0,d1
	mulu	d7,d1	;octets gagn‚s =(nb rep)*(longueur)-longueur-2
	subq.l	#2,d1	;et -1 si nb rep>256
	bls.s	nxtrep		;nb octets gagn‚s <=0 ?
	cmp	#$100,d0
	blo.s	padec1
	subq.l	#1,d1		;-1 si nb rep>256
	bls.s	nxtrep
padec1:
	cmp.l	d5,d1
	bls.s	nxtrep

	move.l	d1,d5		;nouveau best
	move	d7,best1
	move	d0,best2
nxtrep:
	addq	#1,d7
	cmp	#16,d7
	blo.s	rep1

	tst.l	d5		;pas d'octets gagn‚s ???
	beq.s	nextcp1		;oui -> c'est pas la peine

	add.l	d5,nbrep
;
; c'est la bonne m‚thode !!!
;
; dans le cas de la r‚p‚tition :
; best1 contient longueur de la chaine qui se r‚pŠte
; best2 contient le nombre de r‚p‚titions-1
;
	move	best1,d7
	subq	#1,d7
	move	best2,d0

	moveq	#$00,d6
	cmp	#$100,d0
	blo.s	low256
	move	d0,d6
	lsr	#8,d6
	move.b	d6,(a5)+
	moveq	#$40,d6
low256:
	add.b	d7,d6
	move.b	d6,(a4)+
	move.b	d0,(a5)+
	move.l	a6,a0
	move	d7,d6
copy:	move.b	(a0)+,(a5)+
	dbra	d6,copy

	addq	#1,d7
	mulu	d7,d0
	add.l	d0,a6
	add	d7,a6
	bra	compact

nextcp1:
;
; 2) topographie
;
;
; bug :
;	ne prend pas toujours le meilleur !!!
;	dans certains cas, il vaut mieux renoncer … prendre
;	le premier qui nous tombe sous la main
;	parce que le gain est plus lointain
;
;	il suffit de g‚rer un tableau de fr‚quences
;	et … chaque fois de modifier D5 (le maximum local)
;	en fonction du nb d'octets gagneables-1
;	(le -1 sert … ‚viter de bloquer la topo normale)
;
; d6=nb bits-1
; d7=longueur topo
;
	moveq	#-1,d5		;d5 le plus grand possible !!!
;
; (on doit minimiser d5=inverse du pourcentage de compression)
;
	moveq	#0,d7
topo1:	moveq	#0,d6
	moveq	#0,d4		;maximum local
	lea	table(pc),a1
	move.l	a6,a0
	move	d7,d0		;cr‚e le premier noeud
copn:	move.b	(a0)+,(a1)+
	dbra	d0,copn
	clr.b	(a1)+
	bra	next1

topo2:
	lea	2(a2,d7.w),a2
	cmp.l	a1,a2
	blo.s	topo00

	move	d7,d0		;si noeud pas trouv‚
copn2:	move.b	(a0)+,(a1)+	;-> cr‚e nouveau noeud
	dbra	d0,copn2
	clr.b	(a1)+		;avec pr‚sence=0
	bra.L	next1
topo0:
	lea	table(pc),a2
topo00:	move	d7,d0
topo3:	move.b	0(a0,d0.w),d1
	cmp.b	0(a2,d0.w),d1
	bne.s	topo2
	dbra	d0,topo3

	cmp.l	#table,a2
	beq.s	better		;meilleur repeat=premier ???
				;si non -> on optimise en fonction
				;du comptage
	moveq	#0,d1
	move.b	1(a2,d7.w),d1
	addq.b	#1,d1		;incr‚mente fr‚quence
	add.b	d7,d1
	move.b	d1,1(a2,d7.w)
;
; nb octets gagn‚s si pas premier
; =(occurences-1)*longueur-2
;
	subq.l	#3,d1
	bls.s	topo4
	cmp	#8,d6
	blo.s	topo7
	subq.l	#1,d1
	bls.s	topo4
topo7:
;
; D6=NBBITS-1
; d7=longueur topo
;
; inverse du gain en pourcentage :
;
;	((d6+1)*d7)/d1
;
; donc cette valeur doit etre la plus petite possible
;
	move	d6,d0
	addq	#1,d0
	mulu	d7,d0
	divu	d1,d0
	swap	d0
	clr	d0
	swap	d0

	cmp.l	d5,d0
	bhs.s	topo4

	move.l	d0,d5		;nb octets gagn‚s
	move	#$ffff,best2	;longueur topo
	bra.s	topo4		;on marque le noeud
				;en indiquant que l'optimisation est
				;lointaine
better:
	addq	#1,d4
	add	d7,d4		;d4=d4+d7+1
;
; nb octets gagn‚s =
;	d4-2
;	-1 si d6<=8
;	-2 si d6>8
;
	move	d4,d0
	subq	#3,d0
	bls.s	topo4
	cmp	#8,d6
	blo.s	topo5
	subq	#1,d0
	bls.s	topo4
topo5:
	move	d6,d1		;calcul de l'inverse du coeff de
				; compression
	addq	#1,d1
	mulu	d7,d1
	divu	d0,d1
	swap	d1
	clr	d1
	swap	d1

	cmp.l	d5,d1
	bhi.s	topo4

	bne.s	meill
	tst	best2
	bpl.s	topo4
meill:
	move.l	d1,d5		;nb octets gagn‚s
	move	d6,best1	;nb bits
	move	d7,best2	;longueur topo
topo4:
	lea	1(a0,d7.w),a0
next1:
	cmp.l	a3,a0
	bhs.s	endtopo
	addq	#1,d6
	cmp	#20,d6		;16 bits ??
	blo.L	topo0
endtopo:
	addq	#1,d7
	cmp	#16,d7		;10 octets ??
	blo	topo1

	not.l	d5
	beq.s	cpt3
	cmp	#$ffff,best2	;optimisation + loin ???
	beq.s	cpt3		;oui !!!

;	add.l	d5,nbtopo

	move	best1,d6	;nb bits-1
	move	best2,d7	;nb octets-1

	move	d7,d0
	move.l	a6,a0
coptop:	move.b	(a6)+,(a5)+	;copie la topo qui se r‚pŠte
	dbra	d0,coptop

	moveq	#$30,d0
	add	d6,d0
	move.b	d0,(a4)+	;marque topo
	move.b	d7,(a4)+	;nb octets-1

	moveq	#0,d2		;configuration de bits
reptop:
	add	d2,d2
	move	d7,d0
comptop:
	move.b	0(a6,d0.w),d1
	cmp.b	0(a0,d0.w),d1
	bne.s	copyt2
	dbra	d0,comptop
	addq	#1,d2
	lea	1(a6,d7.w),a6
	bra.s	adjt
copyt2:
	move	d7,d0
coplm:	move.b	(a6)+,(a5)+
	dbra	d0,coplm

adjt:	dbra	d6,reptop

	cmp	#8,best1
	blo.s	bits8
	move	d2,d0
	lsr	#8,d0
	move.b	d0,(a4)+
bits8:	move.b	d2,(a4)+	;copie config

cpt3:
;
; 3) corr‚lation
;
; pas encore impl‚ment‚ !!
;  (fait gagner de la place dans les tableaux)
;
; 4) non compactage
;
	cmp.l	a3,a6
	bhs.s	fini
	tst.b	-1(a4)
	bpl.s	parep
	cmp.b	#$ff,-1(a4)
	beq.s	parep
	addq.b	#1,-1(a4)
	bra.s	repl
parep:	move.b	#$80,(a4)+	;suffixe 1 octet non compact‚
repl:	move.b	(a6)+,(a5)+
	cmp.l	a3,a6
	blo	compact
fini:
;
; calcule l'entete
;
	lea	prefix,a0
	moveq	#0,d0
x:	tst.b	(a0)+
	bmi.s	nol
	addq.l	#1,d0
nol:	cmp.l	a4,a0
	blo.s	x
;
; d0=nb octets pr‚fixe (impossible … gagner)
;
	illegal
nbrep:	dc.l	0
nbtopo:	dc.l	0
best1:	dc.w	0
best2:	dc.w	0
table:
; tableau d'octets
;  pour la topographie


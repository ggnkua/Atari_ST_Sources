const1=3	;1,2 ou 3 … v‚rifier !!!!
;
; rajouter compressions suivantes :
;
;	ABAB -> pr‚fixe+code A+code B
;	AAA -> pr‚fixe+code A
;
tstd4:	macro
	tst	d4
	beq.s	t?0
	subq.l	#1,d1		;v‚rifi‚ !!!
t?0:	endm

scanwidth=$200
;blk	macro
;	dcb.\0	\1,\2
;	endm
;
; nouvelle g‚n‚ration de compacteurs
;
; compacte 1 fichier en 2 zones :
;	- la zone pr‚fixe contient tous les pr‚fixes de compactage
;	- la zone data contient tous les octets … transf‚rer
;
; 1Šre passe :
;	- d‚termine les diff‚rentes m‚thodes de compression
;	- calcule les octets les plus fr‚quents (remplissage et topo)
; 2Šme passe :
;	- transforme les compressions en fonction des octets les plus fr‚quents
; 3Šme passe :
;	- codage par Huffmann de la zone data+inclusion zone pr‚fixe
;
;	segment PREFIX contient les m‚thodes de compression :
;
;	0->pas de compression+1 byte (compteur-1)
;	1->pas de compression+2 bytes (compteur-1)
;
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	3->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	4->r‚p‚tition caractŠre pr‚c‚dent+octet … r‚p‚ter+1 byte(compteur-3)
;	5->r‚p‚tition caractŠre pr‚c‚dent+octet … r‚p‚ter+2 bytes(compteur-3)
;	6->r‚p‚tition caractŠre le plus r‚p‚t‚+octet … r‚p‚ter+1 byte(compteur-3)
;	7->r‚p‚tition caractŠre le plus r‚p‚t‚+octet … r‚p‚ter+2 bytes(compteur-3)
;
;	8->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
;	9->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
;	10->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
;	11->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
;
;	12->topo 8 bits+mask+1er octet=octet topo+octets
;	13->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
;	14->topo 8 bits avec octet le plus en topo+mask+octets
;
;	15->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
;	16->corr‚lation 8 bits+1er octet+diff‚rence+2 bytes(compteur-5)
;?	17->corr‚lation 16 bits+1er octet+diff‚rence+1 byte(compteur-5)
;?	18->corr‚lation 16 bits+1er octet+diff‚rence+2 bytes(compteur-5)
;
debut:	equ	$40000
fin:	equ	debut+53078
seg1:	equ	$50000
seg2:	equ	$60000
;
; registres utilis‚s :
;
;	a5=ptr courant
;	a6=ptr sur fin du code
;	a3=ptr sur segment 1
;	a4=ptr sur segment 2
;
;	d7=nb octets gagn‚s
;	d6=meilleure m‚thode
;	d5=offset pour compression de chaines ou octet pour corr‚lation
;	d4=nb octets pour nocomp
;
; pour une meilleure gestion m‚moire :
;	a3 se pr‚d‚cr‚mente
;	a4 se postincr‚mente
;
	lea	debut,a5
	lea	fin,a6
	lea	seg1,a3
	lea	seg2,a4
	moveq	#0,d4
boucle:
	bsr	hexa
	cmp.l	a6,a5
	bhs	fini
	move.b	(a5),d0
	cmp.b	1(a5),d0
	bne.s	padeux
	cmp.b	2(a5),d0
	beq.s	trois
	addq	#1,optim1
	bra.s	padeux
trois:
	cmp.b	3(a5),d0
	beq.s	padeux
	addq	#1,optim3
padeux:
	cmp.b	2(a5),d0
	bne.s	papat
	move.b	1(a5),d0
	cmp.b	3(a5),d0
	bne.s	papat
	addq	#1,optim2
papat:
	moveq	#0,d7		;nb octets gagn‚s
	moveq	#0*4,d6		;meilleure m‚thode
;
; 1) r‚p‚tition de caractŠre
;
;	0->pr‚fixe
;	1->octet … r‚p‚ter
;	2->nb r‚p‚titions (8/16 bits)
;
; gain d'octets si plus de 3 octets se r‚pŠtent (>=3)
;
	move.l	a5,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	(a0)+,d0
	bne.s	parepete
	cmp	lastrep(pc),d0
	beq.s	skip1
	cmp.b	(a0)+,d0
	bne.s	parepete
skip1:	cmp.l	a6,a0
	bhs.s	parepete
; bug
;	cmp.b	(a0)+,d0
;	bne.s	parepete
bcrep:
	cmp.l	a6,a0
	bhs.s	finrep
	cmp.b	(a0)+,d0
	beq.s	bcrep
	subq	#1,a0
finrep:
	move.l	a0,d1
	sub.l	a5,d1
	cmp.l	#256+3,d1
	blo.s	jlx
	subq.l	#1,d1		;si >256+3 octets -> perte de 1 octet
jlx:
	subq.l	#2,d1		;v‚rifi‚ ???
	cmp	lastrep(pc),d0
	beq.s	rep1
	subq.l	#1,d1		;perte de 1 octet si pas lastrep
rep1:
	tstd4			;si nocomp pr‚c‚demment -> perte d'octets

	cmp.l	d7,d1
	ble.s	parepete
	move.l	d1,d7		;nb octets gagn‚s
	moveq	#1*4,d6		;m‚thode 1 !!!
	move.l	a0,ptrfin
	cmp.l	a6,a0		;si jusqu'… la fin
	bhs	comprep		;-> on ne cherche pas plus loin
parepete:
;
; 2) topographie
;
;	0->pr‚fixe
;	1->octet le plus fr‚quent=premier octet
;	2->configuration binaire (masque)
;	3->octets moins fr‚quents...
;
; gain d'octets si le premier octet se r‚pŠte au moins
;   3 fois (>=4)
;
;	bra.s	patopo

	move.l	a5,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#-2,d1		;v‚rifi‚
	cmp	lasttopo(pc),d0
	bne.s	topo1
	addq.l	#1,d1		;gain d'1 octet si lasttopo
topo1:
	tstd4
	cmp.b	(a0)+,d0	;2Šme octet
	bne.s	pat1
	addq.l	#1,d1
pat1:
	cmp.b	(a0)+,d0	;3Šme octet
	bne.s	pat2
	addq.l	#1,d1
pat2:
	cmp.b	(a0)+,d0	;4Šme octet
	bne.s	pat3
	addq.l	#1,d1
pat3:
	cmp.b	(a0)+,d0	;5Šme octet
	bne.s	pat4
	addq.l	#1,d1
pat4:
	cmp.b	(a0)+,d0	;6Šme octet
	bne.s	pat5
	addq.l	#1,d1
pat5:
	cmp.b	(a0)+,d0	;7Šme octet
	bne.s	pat6
	addq.l	#1,d1
pat6:
	cmp.b	(a0)+,d0	;8Šme octet
	bne.s	pat7
	addq.l	#1,d1
pat7:
	cmp.b	(a0)+,d0	;9Šme octet
	bne.s	pat8
	addq.l	#1,d1
pat8:
	cmp.l	d7,d1
	ble.s	patopo
	move.l	d1,d7
	moveq	#2*4,d6
	move.l	a0,ptrfin
patopo:
;
; 3) r‚p‚tition de chaine dans le code pr‚c‚dent
;
;	0->pr‚fixe
;	1->Offset de la chaine (-1 … -65536)
;	2->longueur de la chaine (8/16 bits)
;
; gain d'octets si la chaine contient au moins 3 caractŠres (>=3)
;
	lea	3(a5),a0
	cmp.l	a6,a0		;s'il ne reste que 3 octets
	bhs	finstr		;on n'a rien … faire

	move.l	a5,a0
	sub.l	#scanwidth,a0
	cmp.l	#debut,a0
	bhs.s	cmpcha2
	lea	debut,a0	;a0=d‚but du bloc … explorer
cmpcha2:
	move.l	a5,d3
	sub.l	a0,d3
	bls.s	finstr
	move.b	(a5),d0		;2 premiers octets dans d0/d1
	move.b	1(a5),d1
	move.b	2(a5),d2
	subq	#1,d3
	bmi	bug
cmpchaine:
	cmp.b	(a0)+,d0
	dbeq	d3,cmpchaine
	bne.s	finstr
	cmp.b	(a0),d1
	dbeq	d3,cmpchaine
	bne.s	finstr
	cmp.b	1(a0),d2
	dbeq	d3,cmpchaine
	bne.s	finstr
;	cmp.l	a5,a0
;	bhs.s	finstr

	lea	2(a0),a1
	lea	3(a5),a2
cmpch3:
	cmp.l	a5,a1
	bhs.s	cmpch4
	cmp.l	a6,a2
	bhs.s	cmpch4
	cmpm.b	(a1)+,(a2)+
	beq.s	cmpch3
	subq	#1,a2
cmpch4:
	move.l	a2,d1
	sub.l	a5,d1		;calcule longueur

	cmp.l	#256+3,d1
	blo.s	jlx2
	subq.l	#1,d1		;perte de 1 octet si plus de 256 octets
jlx2:
	subq.l	#2,d1		;v‚rifi‚ !!!

	tstd4
	move.l	a5,d3
	sub.l	a0,d3		;calcule offset
	cmp.l	#256,d3
	blo.s	jlx4
	subq.l	#1,d1		;perte de 1 octet si offset 16 bits
jlx4:
	cmp.l	d7,d1
	ble.s	cmpcha2
	move.l	d1,d7
	moveq	#3*4,d6
	move.l	d3,d5		;m‚morise offset
	subq.l	#1,d5
	move.l	a2,ptrfin	;nouveau pointeur de d‚but
	bra.s	cmpcha2
finstr:
;
; 4) corr‚lation
;
;	0->pr‚fixe
;	1->premier caractŠre
;	2->diff‚rence constante
;	3->nb r‚p‚titions (8/16 bits)
;
; gain d'octets quand plus de 4 octets se suivent (>=4)
;
	move.l	a5,a0
	move.b	(a0)+,d0
	sub.b	(a0),d0
	beq.s	pacorel		;si constante=0 -> r‚p‚tition
	move.b	(a0)+,d1
	sub.b	(a0),d1
	cmp.b	d1,d0
	bne.s	pacorel
	move.b	(a0)+,d1
	sub.b	(a0),d1
	cmp.b	d1,d0
	bne.s	pacorel
	move.b	(a0)+,d1
	sub.b	(a0),d1
	cmp.b	d1,d0
	bne.s	pacorel
;
; bug
;
;	move.b	(a0)+,d1
;	sub.b	(a0),d1
;	cmp.b	d1,d0
;	bne.s	pacorel
	cmp.l	a6,a0
	bhs.s	pacorel
gaincor:
	cmp.l	a6,a0
	bhs.s	fincor
	move.b	(a0)+,d1
	sub.b	(a0),d1
	cmp.b	d1,d0
	beq.s	gaincor
	subq	#1,a0
fincor:
	move.l	a0,d1
	sub.l	a5,d1
	cmp.l	#256+3,d1
	blo.s	corl1
	subq.l	#1,d1		;perte de 1 octet si plus de 256
corl1:
	subq.l	#const1,d1	;gain si 3 octets
	tstd4
	cmp.l	d7,d1
	ble.s	pacorel
	move	d0,d5
	move.l	d1,d7
	moveq	#4*4,d6
	move.l	a0,ptrfin
pacorel:

;
; d6=type de compression … effectuer
; d7=nb octets gagn‚s
; d5=offset pour compression de chaine
; d4=nb octets non compress‚s
;
	jmp	compress(pc,d6.w)

compress:
	bra	nocomp
	bra	comprep
	bra	comptopo
	bra	compstr
	bra	compcor
;
; pas de compression … effectuer
; transfert pur et simple
;
;	0->pr‚fixe
;	1->compteur (8/16 bits)
;	2->octets...
;
; 1) indiquer pas de compression ou incr‚menter flag pas de compression
;    dans seg1
; 2) m‚moriser l'octet non compress‚ dans seg2
;
nocomp:
	tst	d4
	bne.s	incd4
	move.l	a5,ptrdeb
incd4:
	addq	#1,a5
	addq	#1,d4
	bne	boucle
	move.b	#1,(a3)+	;nocomp 16 bits
	move.b	#$ff,(a4)+
	move.b	#$ff,(a4)+
	subq	#1,d4
	move.l	ptrdeb(pc),a0
copy1:
	move.b	(a0)+,(a4)+	;copy 64K
	dbra	d4,copy1
	cmp.l	a5,a0
	bne	bug
	bra	boucle

comprep:
	bsr	fincomp
	move.l	ptrfin(pc),a2

	move.b	#4,(a3)+	;poke type=repeat with lastrep
	moveq	#0,d1
	move.b	(a5)+,d1
	cmp	lastrep(pc),d1
	beq.s	rep2
	subq.b	#2,-1(a3)	;repeat with following byte
	move.b	d1,(a4)+
	move	d1,lastrep
	add	d1,d1
	lea	freqrep(pc),a0
	addq	#1,(a0,d1.w)
rep2:
	move.l	a2,d1
	sub.l	a5,d1
	cmp.l	#$10000+3-1,d1
	blo.s	compre1
	move.l	#$10000+3-1,d1
	lea	0(a5,d1.L),a2	;on borne le compteur
compre1:
	subq	#3,d1		;compteur au minimum=3 !!!!
	move	d1,d0
	lsr	#8,d0
	beq.s	compr1
	addq.b	#1,-1(a3)	;indique offset 16 bits
	move.b	d0,(a4)+
compr1:	move.b	d1,(a4)+	;poke repet
	move.l	a2,a5
	bra	boucle

comptopo:
	bsr	fincomp
	move.b	#12,(a3)+	;poke type=topo with lasttopo
	moveq	#0,d5
	move.b	(a5)+,d5
	cmp	lasttopo(pc),d5
	beq.s	top12
	move	d5,lasttopo
	addq.b	#1,-1(a3)
	move.b	d5,(a4)+	;premier octet=octet le plus fr‚quent
	move	d5,d0
	add	d0,d0
	lea	freqtopo(pc),a0
	addq	#1,(a0,d0.w)
top12:
	move.l	a4,a2
	addq	#1,a4
	moveq	#8-1,d2
top13:
	add.b	d0,d0
	move.b	(a5)+,d1
	cmp.b	d5,d1
	beq.s	top14
	addq.b	#1,d0
	move.b	d1,(a4)+	;poke les octets
top14:
	dbra	d2,top13

	move.b	d0,(a2)		;poke le masque
	cmp.l	ptrfin(pc),a5
	bne	bug
	bra	boucle

compstr:
	bsr	fincomp
	move.l	ptrfin(pc),a2

	move.b	#8,(a3)+	;poke type
	cmp	#256,d5
	blo.s	off8
	addq.b	#2,-1(a3)	;offset 16 bits de la chaine
	move	d5,d0
	lsr	#8,d0
	move.b	d0,(a4)+	;poke poids fort offset
off8:
	move.b	d5,(a4)+	;poke poids faible offset

	move.l	a2,d1
	sub.l	a5,d1		;calcule longueur chaine-3
	subq.l	#3,d1
	cmp	#256,d1
	blo.s	comps1
	addq.b	#1,-2(a3)	;longueur sur 16 bits
	move	d1,d0
	lsr	#8,d0
	move.b	d0,(a4)+
comps1:	move.b	d1,(a4)+	;poke compteur
	move.l	a2,a5
	bra	boucle

compcor:
	bsr	fincomp
	move.l	ptrfin(pc),a2

	move.b	(a5),(a4)+	;1er octet
	move.b	#6,(a3)+	;poke type
	move.b	d5,(a3)+	;poke diff‚rence
	move.l	a2,d1
	sub.l	a5,d1
	cmp.l	#$10000+3-1,d1
	blo.s	compc2
	move.l	#$10000+3-1,d1	;on borne la corr‚lation
	lea	(a5,d1.L),a2
compc2:
	subq.l	#3,d1		;3 au moins
	cmp	#256,d1
	blo.s	compc1
	addq.b	#1,-2(a3)
	move	d1,d0
	lsr	#8,d0
	move.b	d0,(a3)+
compc1:	move.b	d1,(a3)+	;poke compteur
	move.l	a2,a5
	bra	boucle

fini:
;
; indique premiŠre passe finie
;
	bsr	fincomp
	illegal
;
; indique pas de compression
;
; d4=nb octets non compress‚s
;
fincomp:
	tst	d4
	beq.s	fin3
	clr.b	(a3)+
	subq	#1,d4
	move	d4,d0
	lsr	#8,d0
	beq.s	fin2
	addq.b	#1,-1(a3)
	move.b	d0,(a4)+
fin2:	move.b	d4,(a4)+
	move.l	ptrdeb(pc),a0
copy2:
	move.b	(a0)+,(a4)+
	dbra	d4,copy2
	moveq	#0,d4
fin3:	rts

bug:
	illegal
rethex:	rts
hexa:
	cmp.l	lasthex,a5
	blo.s	rethex
	move.l	a5,lasthex
	movem.l	d0-d7/a0-a6,-(sp)

	move.b	lasthex+1(pc),d7
	bsr.s	hexa2
	move.b	lasthex+2(pc),d7
	bsr.s	hexa2
	move.b	lasthex+3(pc),d7
	bsr.s	hexa2
	move	#13,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp

	movem.l	(sp)+,d0-d7/a0-a6
	add.l	#256,lasthex
	rts
hexa2:
	move	d7,d0
	lsr	#4,d0
	bsr.s	puthex
	move	d7,d0
puthex:
	and	#$f,d0
	add	#$30,d0
	cmp	#$3a,d0
	blo.s	put2
	addq	#7,d0
put2:
	move	d0,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp
	rts

lasthex:dc.l	0
lastrep:dc.w	-1
lasttopo:dc.w	-1
ptrdeb:	dc.l	0
ptrfin:	dc.l	0
freqrep:blk.w	256,0
freqtopo:blk.w	256,0
optim1:	dc.w	0	;AA
optim2:	dc.w	0	;ABAB
optim3:	dc.w	0	;AAA

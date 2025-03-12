; si TOPO8=1 -> gaintop=4 puis 3...
; si TOPO8=0 -> gaintop=5 puis 4 puis 3...
; TOPO8=1 plus int‚ressant que 0 !!!
gaintop=4
TOPO8=1			;0=topo 8 bits, 1=topo 9 bits
save=1			;0=pas save, 1=save
debut:	equ	$30000
fin:	equ	debut+53078
segm:	equ	$40000
final:	equ	$60000
scanwidth=$200
;
; am‚liorations du packer :
;
;	+1) augmenter la fr‚quence des topos, il suffit d'autoriser
;	   la topo meme si on ne gagne pas d'octets !
;	   cela permet de diminuer la fr‚quence globale des octets
;	   non compress‚s
;	2) essayer d'enlever les m‚thodes 5 et 7 ???
;	3) compresser le fichier … l'envers (cf BYTE-KILLER)
;	+4) am‚liorer topo 8 bits (voir plus loin)
;
; bug dans SEKA :
;	optimise les bra qui sont dans les IF non assembl‚s !!!
;
; nouvelle g‚n‚ration de compacteurs
;  V2.0 15/09/89
;  V2.1 20/09/89 gestion d'un seul segment, am‚lioration
;		 des offsets (-256), recherche des offsets
;		 les plus petits (pour compstr)
;
; 1Šre passe :
;	- d‚termine les diff‚rentes m‚thodes de compression
;	- calcule les occurrences des m‚thodes de compression
;	- calcule les fr‚quences des octets non compress‚s
; 2Šme passe :
;	- assigne 1 octet parmi les 12 octets les moins fr‚quents
;	  … chaque m‚thode de compression en fonction de leur occurrence
;	  (nocomp n'a pas de code assign‚ !!!)
; 3Šme passe :
;	- g‚nŠre le fichier compress‚ en octet
;	  (les 12 codes de compression sont les 12 premiers octets
;	   du fichier compress‚)
; 4Šme passe :
;	- codage par Huffmann du fichier compress‚ en octets
;
; astuces utilis‚es :
;	- les m‚thodes inutilis‚es ne doivent pas utiliser
;	   d'octet r‚serv‚...
;
; ci-dessous, les diff‚rentes m‚thodes de compression
;
;	0->pas de compression+2 bytes (compteur-1)
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
;	8->chaine de longueur 3+offset 8 bits
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
;
nbmeth=12	;nb m‚thodes de compression
;
; registres utilis‚s :
;
;	a5=ptr courant
;	a6=ptr sur fin du code
;	a4=ptr sur segment compress‚
;
;	d7=nb octets gagn‚s
;	d6=meilleure m‚thode
;	d5=offset pour compression de chaines ou octet pour corr‚lation
;	d4=nb octets pour nocomp
;
	pea	mess1(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	lea	debut,a5
	lea	fin,a6
	lea	segm,a4
	moveq	#0,d4
boucle:
	bsr	hexa
	cmp.l	a6,a5
	bhs	fini

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
	cmp.b	(a0)+,d0
	bne.s	parepete
bcrep:
	cmp.l	a6,a0
	bhs.s	finrep
	cmp.b	(a0)+,d0
	beq.s	bcrep
	subq	#1,a0
finrep:
	move.l	a0,d1
	sub.l	a5,d1
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
;
	subq.l	#2,d1		;perte d'au moins 2 octets (entete)

	cmp.l	#256+3-2,d1	;si len>256 -> perte de 2 octets
	bhs.s	jlx
	cmp	lastrep(pc),d0
	beq.s	rep1		;si lastrep->ok
	subq.l	#1,d1		;si pas lastrep->perte d'1 octet
	bra.s	rep1
jlx:
	subq.l	#2,d1
rep1:
	cmp.l	d7,d1
	ble.s	parepete
	move.l	d1,d7		;nb octets gagn‚s
	moveq	#1*4,d6		;m‚thode 1 !!!
	move.l	a0,ptrfin
	cmp.l	a6,a0		;si jusqu'… la fin
	bhs	comprep		;-> on ne cherche pas plus loin
parepete:
;
; 2) r‚p‚tition de chaine dans le code pr‚c‚dent
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
	bls	finstr
	subq	#2,d3
	blo	finstr
	move.b	(a5),d0		;2 premiers octets dans d0/d1
	move.b	1(a5),d1
	move.b	2(a5),d2
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

	lea	2(a0),a1
	lea	3(a5),a2
cmpch3:
	cmp.l	a6,a1
	bhs.s	cmpch4
	cmp.l	a6,a2
	bhs.s	cmpch4
	cmpm.b	(a1)+,(a2)+
	beq.s	cmpch3
	subq	#1,a2
cmpch4:
	move.l	a2,d1
	sub.l	a5,d1		;calcule longueur
	move.l	a5,d3
	sub.l	a0,d3		;calcule offset-1 (a0)+
;
;	4->chaine+offset 8 bits de la chaine-1+1 byte(compteur-4)
;	5->chaine+offset 8 bits de la chaine-1+2 bytes(compteur-4)
;	6->chaine+offset 16 bits de la chaine-1+1 byte(compteur-5)
;	7->chaine+offset 16 bits de la chaine-1+2 bytes(compteur-5)
;	+8->chaine de longueur 3+offset 8 bits
;
	subq.l	#3,d1		;perte de 3 octets minimum
	bne.s	ch1
	cmp.l	#256,d3
	bhs.s	cmpcha2		;si longueur 3->… suivre...
	moveq	#1,d1		;compression 8=1 octet de gagn‚
	bra.s	setch
ch1:
	cmp.l	#256+4-3,d1
	blo.s	jlx2
	subq.l	#1,d1		;perte de 1 octet si plus de 256 octets
jlx2:
	cmp.l	#256,d3
	blo.s	setch
	subq.l	#1,d1		;perte de 1 octet si offset 16 bits
setch:
	cmp.l	d7,d1

	blt.s	cmpcha2
	bne.s	meil1
	cmp	#2*4,d6
	bne.s	cmpcha2		;essaie de diminuer l'offset !!!
meil1:
	move.l	d1,d7
	moveq	#2*4,d6
	move.l	a2,ptrfin	;nouveau pointeur de d‚but
	move.l	d3,d5		;m‚morise offset-1
	subq.l	#1,d5
	bhs	cmpcha2
	illegal
finstr:
;
; 3) corr‚lation
;
;	0->pr‚fixe
;	1->premier caractŠre
;	2->diff‚rence constante
;	3->nb r‚p‚titions (8/16 bits)
;
; gain d'octets quand plus de 4 octets se suivent (>4)
;
	move.b	1(a5),d0
	sub.b	(a5),d0
	beq.s	pacorel		;si constante=0 -> r‚p‚tition
	lea	1(a5),a0
	move.b	(a0)+,d1
	add.b	d0,d1
	cmp.b	(a0)+,d1
	bne.s	pacorel
	add.b	d0,d1
	cmp.b	(a0)+,d1
	bne.s	pacorel
	add.b	d0,d1
	cmp.b	(a0)+,d1
	bne.s	pacorel

	cmp.l	a6,a0
	bhs.s	pacorel

	lea	256+5(a5),a1	;on ne recherche que dans les 256+5
	cmp.l	a6,a1		;premiers octets...
	bls.s	gaincor
	move.l	a6,a1
gaincor:
	cmp.l	a1,a0
	bhs.s	fincor
	add.b	d0,d1
	cmp.b	(a0)+,d1
	beq.s	gaincor
	subq	#1,a0
fincor:
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
;
	move.l	a0,d1
	sub.l	a5,d1
	subq.l	#4,d1		;4 octets perdus par entete
	cmp.l	d7,d1
	ble.s	pacorel
	move	d0,d5		;stocke diff‚rence
	move.l	d1,d7
	moveq	#3*4,d6
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
	bra	nocomp		;0
	bra	comprep		;1
	bra	compstr		;2
	bra	compcor		;3
;
; pas de compression … effectuer
; transfert pur et simple
;
;	0->pr‚fixe
;	1->compteur (8/16 bits)
;	2->octets...
;
; m‚moriser les limites du bloc non compressible
;  afin d'effectuer une topo dans une seconde passe
;
nocomp:
	tst	d4
	bne.s	incd4
	move.l	a5,ptrdeb
incd4:
	addq	#1,a5
	addq	#1,d4
	bne	boucle
	illegal			;64K sans compression, faut pas pousser
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
;
comprep:
	bsr	fincomp
	move.l	a4,a3
	move.b	#1,(a4)+	;poke type=repeat normal+compteur

	move.l	ptrfin(pc),a2
	move.l	a2,d1
	sub.l	a5,d1
	cmp.l	#$10000+3-1,d1
	blo.s	compre1
	move.l	#$10000+3-1,d1
	lea	0(a5,d1.L),a2	;on borne le compteur
compre1:
	moveq	#0,d0
	move.b	(a5),d0
	move.l	a2,a5

	subq.l	#3,d1		;compteur au minimum=3 !!!!
	blo	bug

	cmp	lastrep(pc),d0
	bne.s	rep2
	cmp.l	#256,d1
	bhs.s	rep2
	addq.b	#2,(a3)		;repeat with lastrep+compteur
	move.b	d1,(a4)+	;poke compteur

	bsr	modify
	bra	boucle
rep2:
	move	d0,lastrep
	move.b	d0,(a4)+
	move	d1,d0
	lsr	#8,d0
	beq.s	compr1

	subq	#1,d0

	addq.b	#1,(a3)		;indique offset 16 bits
	move.b	d0,(a4)+
compr1:	move.b	d1,(a4)+	;poke repet

	bsr	modify
	bra	boucle
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
;	8->chaine de longueur 3+offset 8 bits
;
compstr:
	bsr	fincomp
	move.l	a4,a3

	move.l	ptrfin(pc),a2

	move.l	a2,d1
	sub.l	a5,d1		;calcule longueur chaine-3
	move.l	a2,a5

	cmp	#256,d5
	bhs.s	str1
	cmp.l	#3,d1
	beq.s	cmp3car
str1:
	move.b	#4,(a4)+	;poke type

	cmp	#256,d5
	blo.s	off8
	addq.b	#2,(a3)		;offset 16 bits de la chaine
	move	d5,d0
	lsr	#8,d0

	subq	#1,d0

	move.b	d0,(a4)+	;poke poids fort offset
off8:
	move.b	d5,(a4)+	;poke poids faible offset

	subq.l	#4,d1
	blo	bug

	cmp	#256,d1
	blo.s	comps1
	addq.b	#1,(a3)		;longueur sur 16 bits
	move	d1,d0
	lsr	#8,d0

	subq	#1,d0

	move.b	d0,(a4)+
comps1:	move.b	d1,(a4)+	;poke compteur
	bsr	modify
	bra	boucle
cmp3car:
	move.b	#8,(a4)+	;poke type=chaine de longueur 3
	move.b	d5,(a4)+	;poke poids faible offset
	bsr	modify
	bra	boucle
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
;
compcor:
	bsr	fincomp
	move.l	a4,a3
	move.b	#9,(a4)+	;poke type

	move.l	ptrfin(pc),a2
	move.b	(a5),(a4)+	;1er octet
	move.b	d5,(a4)+	;poke diff‚rence
	move.l	a2,d1
	sub.l	a5,d1
	subq.l	#5,d1		;5 au moins
	blo	bug
	move.b	d1,(a4)+	;poke compteur
	move.l	a2,a5
	bsr	modify
	bra	boucle
;
fini:
;
; indique premiŠre passe finie
;
	bsr	fincomp

	pea	mess2(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	lea	freq(pc),a0
	moveq	#nbmeth-1,d0
	moveq	#0,d2
tstmeth:
	tst	(a0)+
	beq.s	pan
	addq	#1,d2
pan:
	dbra	d0,tstmeth

	tst	d2
	beq	bug		;si pas de compression, bug !!!
;
; ici d2=nb m‚thodes de compressions utilis‚es-1
;
	move	d2,method
	lea	best(pc),a2
	moveq	#0,d3
calfre:
	lea	freq2(pc),a0
	moveq	#-1,d0
	move	#256-1,d1
;
; recherche les d2 octets les moins utilis‚s...
;
min:
	cmp	(a0)+,d0
	bls.s	pamin
	lea	-2(a0),a1
	move	(a1),d0
pamin:
	dbra	d1,min

	move.l	a1,d1
	sub.l	#freq2,d1
	lsr	#1,d1
	move	d1,(a2)+	;poke valeur octet
	move	d0,(a2)+	;poke fr‚quence
	add	d0,d3
	move	#-1,(a1)	;fr‚quence=maximum
	dbra	d2,calfre

	tst	d3
	bne.s	nometh
	moveq	#1,d3
nometh:
	move	d3,freq		;indique nb octets perdus
;
; on assigne … chaque code de compression, un code peu r‚pandu
;   dans le fichier final
;
; a2 pointe sur la fin de best...
;
trions:
	lea	freq(pc),a0	;recherche des codes les plus utilis‚s
	moveq	#nbmeth-1,d1
	moveq	#0,d0
max:
	cmp	(a0)+,d0
	bhs.s	pamax
	lea	-2(a0),a1
	move	(a1),d0
pamax:
	dbra	d1,max

	tst	d0
	beq	bug

	clr	(a1)		;efface la fr‚quence

	subq	#2,a2
	move	-(a2),d0	;on prend le dernier code empil‚
	move.l	a1,d1
	sub.l	#freq,d1
	lea	codes(pc),a0
	add.l	d1,a0
	move	d0,(a0)		;on remplit la table correspondante
	cmp.l	#best,a2
	bne.s	trions
;
	move.l	a4,finsegm
;
; maintenant, on va d‚compresser le fichier afin de g‚n‚rer
;  le fichier final
;
	lea	final,a6
	lea	codes(pc),a0	;on poke d'abord les octets de m‚thodes
	moveq	#nbmeth-1,d0
pokecode:
	move	(a0)+,d1
	bmi.s	setcode		;si m‚thode inutilis‚e,
	move	d1,d2		; on poke l'ancien code
setcode:
	move.b	d2,(a6)+
	dbra	d0,pokecode

	pea	mess3(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	lea	segm,a0		;pointeur sur le segment data
traduit:
	cmp.l	finsegm(pc),a0
	bhs	sure

	moveq	#0,d0
	move.b	(a0)+,d0
	cmp	#12,d0
	bhs	bug
	add	d0,d0
	add	d0,d0
	jmp	methon(pc,d0.w)
methon:
	bra	meth0
	bra	meth1
	bra	meth2
	bra	meth3
	bra	meth4
	bra	meth5
	bra	meth6
	bra	meth7
	bra	meth8
	bra	meth9
	bra	meth10
	bra	meth11
;
;	0->pas de compression+2 bytes (compteur-1)
;
meth0:
	move.b	(a0)+,d0
	asl	#8,d0
	move.b	(a0)+,d0
meth00:
	moveq	#0,d1
	move.b	(a0)+,d1
	lea	codes(pc),a2
	moveq	#nbmeth-1,d2
cmpcode:
	cmp	(a2)+,d1
	dbeq	d2,cmpcode
	bne.s	nxtcode
	move.b	final+0,(a6)+
nxtcode:
	move.b	d1,(a6)+
	dbra	d0,meth00
	bra	traduit
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
meth1:
	move.b	final+1,(a6)+	;code de rept
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
meth2:
	move.b	final+2,(a6)+	;code de rept
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
meth3:
	move.b	final+3,(a6)+	;code de rept
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
meth4:
	move.b	final+4,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
meth5:
	move.b	final+5,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
meth6:
	move.b	final+6,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
meth7:
	move.b	final+7,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	8->chaine de longueur 3+offset 8 bits
meth8:
	move.b	final+8,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
meth9:
	move.b	final+9,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
meth10:
	move.b	final+10,(a6)+
	move.b	(a0)+,(a6)+	;1er octet
	move.b	(a0)+,d0	;mask
	move.b	d0,(a6)+
	moveq	#8-1,d1
msk1:
	add.b	d0,d0
	bcc.s	nomsk1
	move.b	(a0)+,(a6)+
nomsk1:
	dbra	d1,msk1
	bra	traduit
;
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
meth11:
	move.b	final+11,(a6)+
	move.b	(a0)+,d0	;mask
	move.b	d0,(a6)+
	moveq	#8-1,d1
msk2:
	add.b	d0,d0
	bcc.s	nomsk2
	move.b	(a0)+,(a6)+
nomsk2:
	dbra	d1,msk2

	bra	traduit

sure:
	cmp.l	finsegm(pc),a0
	bne	bug
;
; d‚but du code=final
; fin du code=a6
;
	if	save
	pea	file(pc)
	move	#$41,-(sp)	;delete file
	trap	#1
	addq	#6,sp

	clr	-(sp)
	pea	file(pc)
	move	#$3c,-(sp)	;create file
	trap	#1
	addq	#8,sp
	move	d0,d7
	bmi	bug

	pea	final
	move.l	a6,d0
	sub.l	(sp),d0
	move.l	d0,-(sp)	;longueur
	move	d7,-(sp)
	move	#$40,-(sp)	;save block
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	bug

	move	d7,-(sp)
	move	#$3e,-(sp)	;close file
	trap	#1
	addq	#4,sp
	endif

	illegal			;pas d'erreur
bug:
	illegal

fincomp:
	tst	d4
	beq	nomore
;
; quand on a un bloc non compress‚, on lui fait une topographie...
;
	movem.l	d5-d7/a5/a6,-(sp)

	move.l	a5,a6			;nouvelle fin
	move.l	ptrdeb(pc),a5		;nouveau d‚but

	moveq	#0,d4
boucle2:
;	bsr	hexa
	cmp.l	a6,a5
	bhs	fini2

	if	TOPO8
;
; 4) topographie 9 bits
;
;	0->pr‚fixe
;	1->octet le plus fr‚quent=premier octet
;	2->configuration binaire (masque)
;	3->octets moins fr‚quents...
;
; gain d'octets si le premier octet se r‚pŠte au moins
;   3 fois (>=4)
;
	lea	9(a5),a0
	cmp.l	a6,a0
	bhs	patopo

	move.l	a5,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#-gaintop,d1	;entete prend 3 octets
	cmp	lasttopo(pc),d0
	bne.s	pat0
	addq.l	#1,d1		;gain d'1 octet si lasttopo
pat0:
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
	tst.l	d1
	ble	patopo
	bsr	fincomp2
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
;
	move.l	a4,a3
	move.b	#11,(a4)+	;poke type=topo with lasttopo
	moveq	#0,d5
	move.b	(a5)+,d5
	cmp	lasttopo(pc),d5
	beq.s	top121
	move	d5,lasttopo
	subq.b	#1,(a3)
	move.b	d5,(a4)+	;premier octet=new topo
top121:
	move.l	a4,a2
	addq	#1,a4
	moveq	#8-1,d2
top131:
	add.b	d0,d0
	move.b	(a5)+,d1
	cmp.b	d5,d1
	beq.s	top141
	addq.b	#1,d0
	move.b	d1,(a4)+	;poke les octets
top141:
	dbra	d2,top131

	move.b	d0,(a2)		;poke le masque
	bsr	modify
	bra	boucle2

	else
;
; 4) topographie 8 bits
;
;	0->pr‚fixe
;	1->octet le plus fr‚quent=premier octet
;	2->configuration binaire (masque)
;	3->octets moins fr‚quents...
;
; gain d'octets si le premier octet se r‚pŠte au moins
;   3 fois (>=4)
;
	lea	8(a5),a0
	cmp.l	a6,a0
	bhs	patopo
;
; seul bug :
;	2 octets se r‚pŠtent 4 fois chacun
;
	lea	freqtopo(pc),a1
	move.l	a5,a0

	moveq	#0,d0
	move.b	(a0)+,d0	;0
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;1
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;2
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;3
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;4
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;5
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;6
	addq.b	#1,(a1,d0.w)
	move.b	(a0)+,d0	;7
	addq.b	#1,(a1,d0.w)
	subq	#8,a0

	moveq	#0,d1
	moveq	#0,d6
	move.b	(a0)+,d1
	move.b	(a1,d1.w),d6
	clr.b	(a1,d1.w)

	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not2
	move	d0,d1
	move.b	(a1,d0.w),d6
not2:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not3
	move	d0,d1
	move.b	(a1,d0.w),d6
not3:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not4
	move	d0,d1
	move.b	(a1,d0.w),d6
not4:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not5
	move	d0,d1
	move.b	(a1,d0.w),d6
not5:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
	cmp.b	(a1,d0.w),d6
	bhs.s	not6
	move	d0,d1
	move.b	(a1,d0.w),d6
not6:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
; les 2 tests suivants sont inutiles !!!
;	cmp.b	(a1,d0.w),d6
;	bhs.s	not7
;	move	d0,d1
;	move.b	(a1,d0.w),d6
;not7:
	clr.b	(a1,d0.w)
	move.b	(a0)+,d0
;	cmp.b	(a1,d0.w),d6
;	bhs.s	not8
;	move	d0,d1
;	move.b	(a1,d0.w),d6
;not8:
	clr.b	(a1,d0.w)
;
; d6=nb octets gagn‚s
; d1=octet de topo
;
	cmp	lasttopo(pc),d1
	bne.s	topo1
	addq	#1,d6		;on gagne un octet de plus
topo1:
	subq	#gaintop,d6
	bls	patopo		;d6=nb octets gagn‚s
	move	d1,-(sp)
	bsr	fincomp2
	move	(sp)+,d1	;d1=octet topo
;
;	10->topo 8 bits+octet topo+mask+octets
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
;
	move.l	a4,a3
	move.b	#11,(a4)+	;poke type=topo with lasttopo
	cmp	lasttopo(pc),d1
	beq.s	top12
	move	d1,lasttopo
	subq.b	#1,(a3)
	move.b	d1,(a4)+
top12:
	move.l	a4,a2
	addq	#1,a4
	moveq	#8-1,d2
top13:
	add.b	d0,d0
	move.b	(a5)+,d3
	cmp.b	d1,d3
	beq.s	top14
	addq.b	#1,d0
	move.b	d3,(a4)+	;poke les octets
top14:
	dbra	d2,top13

	move.b	d0,(a2)		;poke le masque

	bsr	modify
	bra	boucle2

	endif

patopo:
	tst	d4
	bne.s	incd5
	move.l	a5,ptrdeb
incd5:
	addq	#1,a5
	addq	#1,d4
	bne	boucle2
	illegal			;64K sans compression, faut pas pousser

fini2:
	bsr	fincomp2
	movem.l	(sp)+,d5-d7/a5/a6

	moveq	#0,d4
nomore:
	rts
;
; indique pas de compression
;
; d4=nb octets non compress‚s
;
fincomp2:
	tst	d4
	beq.s	fin3

	move.l	a4,a3
	clr.b	(a4)+
	subq	#1,d4
	move	d4,d0
	lsr	#8,d0
	move.b	d0,(a4)+
	move.b	d4,(a4)+

	move.l	ptrdeb(pc),a0

	lea	freq2(pc),a1
copy2:
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	d0,(a4)+
	add	d0,d0
	addq	#1,(a1,d0.w)
	dbra	d4,copy2
	cmp.l	a5,a0
	bne	bug
	moveq	#0,d4
fin3:	rts

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
rethex:	rts
hexa2:
	move	d7,d0
	lsr	#4,d0
	bsr	puthex
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

modify:
	moveq	#0,d0
	move.b	(a3),d0
	lea	freq(pc),a3
	add	d0,d0
	addq	#1,(a3,d0.w)
	rts

finsegm:dc.l	0
method:	dc.w	0		;nb m‚thodes utilis‚es
lasthex:dc.l	0
lastrep:dc.w	-1
lasttopo:dc.w	-1
ptrdeb:	dc.l	0
ptrfin:	dc.l	0
freq2:	blk.w	256,0		;pour calcul des moins fr‚quents
	if	1-TOPO8
freqtopo:blk.b	256,0
	endif
freq:	blk.w	nbmeth,0
best:	blk.w	nbmeth*2,0
codes:	blk.w	nbmeth,-1

mess1:	dc.b	'compression en octets (rept,str,topo)...',13,10,0
mess2:	dc.b	'assignation des codes les moins fr‚quents',13,10,0
mess3:	dc.b	'g‚n‚ration du code',13,10,0
file:	dc.b	'GEN2.BIN',0

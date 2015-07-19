	opt	o-
;
; am‚liorations apport‚es le 02/04/90
;
;	+ affichage du temps mis pour la compression
;	+ tailles du fichier
;		Longueur originelle
;		Longueur finale
;		Gain en octets
;	- % de packing
;	- offset demand‚ au clavier
;	- nom du fichier demand‚ au clavier
;	- interfa‡age avec HUF11.S
;	- demande du type de compression (Huff+Pack,Huff ou Pack)
;	+ affichage de "Chargement de ..."
;	+ gestion m‚moire incr‚mentale
;	- si 601A demander si on d‚gage l'entete
;	- quand on tape CR -> directory affich‚ !!!
;
; liste des am‚liorations … apporter :
;	on peut packer des fichiers de la taille de la m‚moire centrale !!!!
;	il suffit :
;		1) de faire que ptrfinal=ptrdebut
;		    et g‚rer si on d‚borde
;		      (ce qui signifie que le fichier est plus gros !!!)
;		2) de stocker le fichier le plus en haut possible
;		    et d'effacer … partir du bas de la RAM
;
overlay = 0	;0=overlay final avec debut
entete = 1	;1=enlŠve entete fichiers .PRG
; si TOPO8=1 -> gaintop=4 puis 3...
; si TOPO8=0 -> gaintop=5 puis 4 puis 3...
; TOPO8=1 plus int‚ressant que 0 !!!
gaintop = 4
TOPO8 = 1		;0=topo 8 bits, 1=topo 9 bits
save = 1		;0=pas save, 1=save
;final:	equ	$30000
scanwidth = $100

PRINT	MACRO
	pea	\1(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

	bra	o
filein:	dc.b	'MONST2.TOS',0
fileout:ds.b	128
	EVEN
o:
	PRINT	loadmess
	PRINT	filein
	PRINT	cr

	clr	-(sp)
	pea	filein(pc)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d7
	bmi	bug

	lea	buf_debut,a6
	move.l	a6,ptrdebut

	ifne	entete
	pea	(a6)
	pea	$1c.w		;on charge l'entete pour l'ignorer !!!
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	bug
	endc

	pea	(a6)
	pea	200000		;200 Ko charg‚s
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	bug
	add.l	d0,a6		;a6=fin du fichier charg‚
	move.l	a6,ptrfin1
	move.l	a6,ptrsegm

	move	d7,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp

	ifne	save
;
; rajoute l'extension .PAK
;
	lea	filein(pc),a0
	lea	fileout(pc),a1
searcpt:
	move.b	(a0)+,(a1)+
	bne.s	searcpt

	subq	#1,a1
	move.l	a1,a0
	moveq	#4-1,d0
sev:
	cmp.b	#'.',-(a1)
	beq.s	foundv
	dbra	d0,sev
	move.b	#'.',(a0)+
	bra.s	insv
foundv:
	lea	1(a1),a0
insv:
	move.b	#'P',(a0)+
	move.b	#'A',(a0)+
	move.b	#'K',(a0)+
	clr.b	(a0)+
	endc

	bsr	get_time
	move.l	time,time2
	bsr	packer_byte
	bsr	get_time
	move.l	time,d7
	sub.l	time2,d7
	move.l	d7,time
;
; time.l=nb millisecondes pour compresser
;
	PRINT	mess4
	move.l	time,d7
	bsr	decimal

	PRINT	mess5

	PRINT	mess6

	move.l	ptrfin1,d7
	sub.l	ptrdebut,d7
	bsr	aff_mixte

	PRINT	mess7

	move.l	ptrfin2,d7
	sub.l	ptrfinal,d7
	bsr	aff_mixte

	PRINT	mess8

	move.l	ptrfin1,d7
	sub.l	ptrdebut,d7
	sub.l	ptrfin2,d7
	add.l	ptrfinal,d7
	move.l	d7,-(sp)
	bsr	aff_mixte

	PRINT	mess9

	move.l	ptrfin1,d7
	sub.l	ptrdebut,d7	;d7=nb octets source
	move.l	(sp)+,d6	;d6=nb octets gagn‚s
	bsr	percent
	PRINT	mess10
;
; d‚but du code=ptrfinal
; fin du code=ptrfin2
;
	ifne	save

	PRINT	savemess
	PRINT	fileout
	PRINT	cr

	pea	fileout(pc)
	move	#$41,-(sp)	;delete file
	trap	#1
	addq	#6,sp

	clr	-(sp)
	pea	fileout(pc)
	move	#$3c,-(sp)	;create file
	trap	#1
	addq	#8,sp
	move	d0,d7
	bmi	bug

	move.l	ptrfinal,-(sp)
	move.l	ptrfin2,d0
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
	endc

	illegal			;pas d'erreur

packer_byte:
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
nbmeth = 12	;nb m‚thodes de compression
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
	PRINT	mess1

	move.l	ptrdebut,a5
	move.l	ptrfin1,a6	;a6=fin du fichier
	move.l	ptrsegm,a4
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
	cmp.l	ptrdebut,a0
	bhs.s	cmpcha2
	move.l	ptrdebut,a0	;a0=d‚but du bloc … explorer
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
	bra.w	nocomp		;0
	bra.w	comprep		;1
	bra.w	compstr		;2
	bra.w	compcor		;3
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
	move.l	a5,a2
	add.l	d1,a5		;on borne le compteur
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

	PRINT	mess2

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

	ifeq	overlay
	move.l	ptrdebut,a4
	endc
	move.l	a4,ptrfinal
;
; maintenant, on va d‚compresser le fichier afin de g‚n‚rer
;  le fichier final
;
	move.l	ptrfinal,a6
	lea	codes(pc),a0	;on poke d'abord les octets de m‚thodes
	moveq	#nbmeth-1,d0
pokecode:
	move	(a0)+,d1
	bmi.s	setcode		;si m‚thode inutilis‚e,
	move	d1,d2		; on poke l'ancien code
setcode:
	move.b	d2,(a6)+
	dbra	d0,pokecode

	PRINT	mess3

	move.l	ptrfinal,a3
	move.l	ptrsegm,a0	;pointeur sur le segment data
traduit:
	ifeq	overlay
	cmp.l	a6,a0		;final vient de scratcher segm ????
	blo	bug
	endc

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
	bra.w	meth0
	bra.w	meth1
	bra.w	meth2
	bra.w	meth3
	bra.w	meth4
	bra.w	meth5
	bra.w	meth6
	bra.w	meth7
	bra.w	meth8
	bra.w	meth9
	bra.w	meth10
	bra.w	meth11
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
	move.b	(a3),(a6)+	;final+0
nxtcode:
	move.b	d1,(a6)+
	dbra	d0,meth00
	bra.s	traduit
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
meth1:
	move.b	1(a3),(a6)+	;code de rept=final+1
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra.s	traduit
;
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
meth2:
	move.b	2(a3),(a6)+	;code de rept=final+2
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
meth3:
	move.b	3(a3),(a6)+	;code de rept=final+3
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
meth4:
	move.b	4(a3),(a6)+	;=final+4
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
meth5:
	move.b	5(a3),(a6)+	;=final+5
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
meth6:
	move.b	6(a3),(a6)+	;=final+6
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
meth7:
	move.b	7(a3),(a6)+	;=final+7
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	8->chaine de longueur 3+offset 8 bits
meth8:
	move.b	8(a3),(a6)+	;=final+8
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
meth9:
	move.b	9(a3),(a6)+	;=final+9
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	move.b	(a0)+,(a6)+
	bra	traduit
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
meth10:
	move.b	10(a3),(a6)+	;=final+10
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
	move.b	11(a3),(a6)+	;=final+11
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
	bne.s	bug
***********************************
*
*  FIN DU PACKER EN BYTES
*
***********************************
	move.l	a6,ptrfin2
	rts
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

	ifne	TOPO8
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
	ble.s	patopo
	bsr.s	fincomp2
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

	elseif
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
	bls.s	patopo		;d6=nb octets gagn‚s
	move	d1,-(sp)
	bsr.s	fincomp2
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

	endc

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
	bsr.s	fincomp2
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

	move.l	ptrfin1,d7
	sub.l	lasthex,d7		;nb octets restants
;	move.l	lasthex,d7
;	sub.l	ptrdebut,d7
	bsr.s	aff_hexa

	move	#13,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp

	movem.l	(sp)+,d0-d7/a0-a6
	add.l	#256,lasthex
rethex:	rts

aff_mixte:
	moveq	#'$',d0
	bsr	put2
	bsr	aff_hexa
	moveq	#' ',d0
	bsr	put2
	bra	decimal

aff_hexa:
	rol.l	#8,d7

	bsr.s	hexa2
	bsr.s	hexa2
	bsr.s	hexa2
	bsr.s	hexa2
	bsr	hexa2
hexa2:
	rol.l	#4,d7
	moveq	#$f,d0
	and	d7,d0
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

get_time:
	pea	supexec(pc)
	move	#38,-(sp)
	trap	#14
	addq	#6,sp
	rts
supexec:
	move.l	$4ba.w,d7
	move.l	d7,d0
	add.l	d7,d7
	add.l	d7,d7
	add.l	d0,d7
	MOVE.L	d7,time
	rts
time2:	dc.l	0
time:	dc.l	0
;
; conversion/affichage d'un nombre d‚cimal
;
; entr‚e :
;	d7.L=nb … afficher
;
decimal:
	moveq	#' ',d6
	move.l	#1000000000,d5
	bsr	decime
	move.l	#100000000,d5
	bsr	decime
	move.l	#10000000,d5
	bsr	decime
	move.l	#1000000,d5
	bsr	decime
	move.l	#100000,d5
	bsr	decime
	move.l	#10000,d5
	bsr	decime
	move.l	#1000,d5
	bsr	decime
	move.l	#100,d5
	bsr	decime
	move.l	#10,d5
	bsr	decime

	moveq	#'0',d0
	add	d0,d7
	bra	put2

decime:
	moveq	#-1,d0
deci1:
	addq	#1,d0
	sub.l	d5,d7
	bhs.s	deci1
	add.l	d5,d7
	tst	d0
	beq.s	ok0xxx
	moveq	#'0',d6
ok0xxx:
	add	d6,d0
	bra	put2

;
; d6=nb octets gagn‚s
; d7=nb octets d'origine
;
percent:
	moveq	#' ',d5
	bsr	decim4
	bsr	decim4
	moveq	#',',d0
	bsr	put2
	bsr	decim4
	bsr	decim4
	rts
decim4:
	move.l	d6,d0
	add.l	d6,d6
	add.l	d6,d6
	add.l	d0,d6
	add.l	d6,d6		;d6=d6*10
	moveq	#-1,d0
decim41:
	addq	#1,d0
	sub.l	d7,d6
	bhs.s	decim41
	add.l	d7,d6

	tst	d0
	beq.s	decim42
	moveq	#'0',d5
decim42:
	add	d5,d0
	bra	put2

mess1:	dc.b	"compression en octets (rept,str,topo)...",13,10,0
mess2:	dc.b	'assignation des codes les moins fr‚quents',13,10,0
mess3:	dc.b	'g‚n‚ration du code',13,10,0
mess4:	dc.b	"Temps total de compression : ",0
mess5:	dc.b	"ms",13,10,0
mess6:	dc.b	"Longueur originelle : ",0
mess7:	dc.b	13,10
	dc.b	"Longueur finale     : ",0
mess8:	dc.b	13,10
	dc.b	"Gain en octets      : ",0
mess10:	dc.b	"% de compression",13,10,0
loadmess:dc.b	"Loading file ",0
savemess:dc.b	"Saving file ",0
mess9:
cr:	dc.b	13,10,0


	even
method:	dc.w	0		;nb m‚thodes utilis‚es
lasthex:dc.l	0
lastrep:dc.w	-1
lasttopo:dc.w	-1
ptrdeb:	dc.l	0
ptrfin:	dc.l	0
freq2:	dcb.w	256,0		;pour calcul des moins fr‚quents
	ifne	1-TOPO8
freqtopo:dcb.b	256,0
	endc
freq:	dcb.w	nbmeth,0
best:	dcb.w	nbmeth*2,0
codes:	dcb.w	nbmeth,-1

	even
ptrdebut:dc.l	0
ptrfin1:dc.l	0
ptrsegm:dc.l	0
finsegm:dc.l	0
ptrfinal:dc.l	0
ptrfin2:dc.l	0
	SECTION	BSS
buf_debut:

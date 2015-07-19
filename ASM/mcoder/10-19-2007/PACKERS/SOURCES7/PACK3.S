;blk	macro
;	dcb.\0	\1,\2
;	endm
debut:	equ	$40000
fin:	equ	debut+53078
seg1:	equ	$50000
seg2:	equ	$60000
final:	equ	$70000
;
scanwidth=$200
;
; nouvelle g‚n‚ration de compacteurs
;  V2.0 15/09/89
;
; compacte 1 fichier en 2 zones :
;	- la zone pr‚fixe contient tous les pr‚fixes de compactage
;	- la zone data contient tous les octets … transf‚rer
;
; 1Šre passe :
;	- d‚termine les diff‚rentes m‚thodes de compression
;	- calcule les octets les 11 octets les moins fr‚quents
; 2Šme passe :
;	- assigne 1 octet parmi les 11 … chaque m‚thode de compression
;	   en fonction de leur occurrence
;	  (nocomp n'a pas de code assign‚ !!!)
;	- fusion de la zone pr‚fixe et data
;	  les 11 codes de compression sont les 11 premiers octets
;	   du fichier compress‚
; 3Šme passe :
;	- codage par Huffmann du fichier compress‚ en octets
;
; am‚liorations :
;	- d‚gager les m‚thodes 5 et 7
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
; fr‚quences actuelles de compression sur GENST2 :
;	1=$1B
;	3=$67
;	4=$6A0
;	6=$E5
;	8=$980
;	9=9
; aucun : 2,5,7
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
; d1=nb octets gagn‚s
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
	move.b	(a5),d0		;2 premiers octets dans d0/d1
	move.b	1(a5),d1
	move.b	2(a5),d2
;	subq	#1,d3
	subq	#2,d3
	blo	bug
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
	bhs	cmpcha2		;si longueur 3->… suivre...
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
	ble.s	cmpcha2
	move.l	d1,d7
	moveq	#2*4,d6
	move.l	a2,ptrfin	;nouveau pointeur de d‚but
	move.l	d3,d5		;m‚morise offset-1
	bne	cmpcha2
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

	cmp.l	a6,a0
	bhs.s	pacorel

	lea	256+5(a5),a1	;on ne recherche que dans les 256+5
	cmp.l	a6,a1		;premiers octets...
	bls.s	gaincor
	move.l	a6,a1
gaincor:
	cmp.l	a1,a0
	bhs.s	fincor
	move.b	(a0)+,d1
	sub.b	(a0),d1
	cmp.b	d1,d0
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
	move	d0,d5
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
	illegal			;64K sans compression, faut pas pousser
	clr.b	(a3)+		;nocomp
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
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
;
comprep:
	bsr	fincomp
	move.b	#1,(a3)+	;poke type=repeat normal+compteur

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
	addq.b	#2,-1(a3)	;repeat with lastrep+compteur
	move.b	d1,(a4)+	;poke compteur
	bra	boucle
rep2:
	move	d0,lastrep
	move.b	d0,(a4)+
	move	d1,d0
	lsr	#8,d0
	beq.s	compr1
	addq.b	#1,-1(a3)	;indique offset 16 bits
	move.b	d0,(a4)+
compr1:	move.b	d1,(a4)+	;poke repet
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
	move.l	ptrfin(pc),a2

	move.l	a2,d1
	sub.l	a5,d1		;calcule longueur chaine-3
	move.l	a2,a5

	cmp	#256,d5
	bhs.s	str1
	cmp.l	#3,d1
	beq.s	cmp3car
str1:
	move.b	#4,(a3)+	;poke type

	cmp	#256,d5
	blo.s	off8
	addq.b	#2,-1(a3)	;offset 16 bits de la chaine
	move	d5,d0
	lsr	#8,d0
	move.b	d0,(a4)+	;poke poids fort offset
off8:
	move.b	d5,(a4)+	;poke poids faible offset

	subq.l	#4,d1
	blo	bug

	cmp	#256,d1
	blo.s	comps1
	addq.b	#1,-2(a3)	;longueur sur 16 bits
	move	d1,d0
	lsr	#8,d0
	move.b	d0,(a4)+
comps1:	move.b	d1,(a4)+	;poke compteur
	bra	boucle
cmp3car:
	move.b	#8,(a3)+	;poke type=chaine de longueur 3
	move.b	d5,(a4)+	;poke poids faible offset
	bra	boucle
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
;
compcor:
	bsr	fincomp
	move.b	#9,(a3)+	;poke type

	move.l	ptrfin(pc),a2
	move.b	(a5),(a4)+	;1er octet
	move.b	d5,(a4)+	;poke diff‚rence
	move.l	a2,d1
	sub.l	a5,d1
	subq.l	#5,d1		;3 au moins
	move.b	d1,(a4)+	;poke compteur
	move.l	a2,a5
	bra	boucle
;
fini:
;
; indique premiŠre passe finie
;
	bsr	fincomp

	LEA	$50000,A0
	LEA	freq(PC),A1
	moveq	#0,d7		;compte nb octets NOCOMP
COUNT:
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ.S	SKIP

	ADD	D0,D0
	ADDQ	#1,(A1,D0.W)
	addq	#1,d7
	BRA.S	S
SKIP:
	ADDQ	#2,A0
S:
	CMP.L	A3,A0
	BLO.S	COUNT

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
	move.l	a3,finseg1
	move.l	a4,finseg2
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

	lea	seg1,a0		;pointeur sur le segment de pr‚fix
	lea	seg2,a1		;pointeur sur le segment data
traduit:
	cmp.l	finseg1,a0
	bhs	sure
	cmp.l	finseg2,a1
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
	move.b	(a1)+,d1
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
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
meth2:
	move.b	final+2,(a6)+	;code de rept
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
meth3:
	move.b	final+3,(a6)+	;code de rept
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
meth4:
	move.b	final+4,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
meth5:
	move.b	final+5,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
meth6:
	move.b	final+6,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
meth7:
	move.b	final+7,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	8->chaine de longueur 3+offset 8 bits
meth8:
	move.b	final+8,(a6)+
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
meth9:
	move.b	final+9,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	move.b	(a1)+,(a6)+
	bra	traduit
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
meth10:
	move.l	a1,a2

	move.b	final+10,(a6)+
	move.b	(a1)+,(a6)+	;1er octet
	move.b	(a1)+,d0	;mask
	move.b	d0,(a6)+
	moveq	#8-1,d1
msk1:
	add.b	d0,d0
	bcc.s	nomsk1
	move.b	(a1)+,(a6)+
nomsk1:
	dbra	d1,msk1
	bra	traduit
;
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
meth11:
	move.l	a1,a2

	move.b	final+11,(a6)+
	move.b	(a1)+,d0	;mask
	move.b	d0,(a6)+
	moveq	#8-1,d1
msk2:
	add.b	d0,d0
	bcc.s	nomsk2
	move.b	(a1)+,(a6)+
nomsk2:
	dbra	d1,msk2

	bra	traduit

sure:
	cmp.l	finseg1,a0
	bne	bug
	cmp.l	finseg2,a1
	bne	bug
	illegal

finseg1:dc.l	0
finseg2:dc.l	0
method:	dc.w	0
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
;
; 4) topographie
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
	bhs.s	patopo

	move.l	a5,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#-2,d1		;entete prend 3 octets
	cmp	lasttopo(pc),d0
	bne.s	topo1
	addq.l	#1,d1		;gain d'1 octet si lasttopo
topo1:
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
	bsr	fincomp2
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
;
	move.b	#11,(a3)+	;poke type=topo with lasttopo
	moveq	#0,d5
	move.b	(a5)+,d5
	cmp	lasttopo(pc),d5
	beq.s	top12
	move	d5,lasttopo
	subq.b	#1,-1(a3)
	move.b	d5,(a4)+	;premier octet=new topo
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
	bra	boucle2
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

	clr.b	(a3)+
	subq	#1,d4
	move	d4,d0
	lsr	#8,d0
	move.b	d0,(a3)+
	move.b	d4,(a3)+

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
freq2:	blk.w	256,0		;pour calcul des moins fr‚quents
freq:	blk.w	nbmeth,0
best:	blk.w	nbmeth*2,0
codes:	blk.w	nbmeth,-1

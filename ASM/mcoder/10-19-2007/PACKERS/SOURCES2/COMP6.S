debut:	equ	$40000
fin:	equ	debut+20611
seg1:	equ	$50000
seg2:	equ	$60000
;
; compacte.s
;
; routine de compactage
;
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
;
; liste des compressions possibles :
;
;	0->pas de compression+1 byte (compteur-1)
;	1->pas de compression+2 bytes (compteur-1)
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
;	3->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
;	4->corr‚lation+1er octet+diff‚rence+1 byte(compteur-5)
;	5->corr‚lation+1er octet+diff‚rence+2 bytes(compteur-5)
;	6->chaine+offset de la chaine+1 byte(compteur-4)
;	7->chaine+offset de la chaine+2 bytes(compteur-4)
;
skprep:	equ	3
skpcor:	equ	4
skpstr:	equ	3

cntrep:	equ	3
cntcor:	equ	5
cntstr:	equ	4

	lea	debut,a5
	lea	fin,a6
	lea	seg1,a3
	lea	seg2,a4
	moveq	#0,d4
boucle:
	cmp.l	a6,a5
	bhs	fini
	moveq	#0,d7		;nb octets gagn‚s
	moveq	#0*2,d6		;meilleure m‚thode
;
; 1) r‚p‚tition de caractŠre
;
;	0->pr‚fixe
;	1->octet … r‚p‚ter
;	2->nb r‚p‚titions (8/16 bits)
;
; gain d'octets si plus de 3 octets se r‚pŠtent (>=4)
;
	move.l	a5,a0
	move.b	(a0)+,d0
	cmp.b	(a0)+,d0
	bne.s	parepete
	cmp.b	(a0)+,d0
	bne.s	parepete
	cmp.b	(a0)+,d0
	bne.s	parepete
bcrep:
	cmp.l	a6,a0
	bhs.s	finrep
	cmp.b	(a0)+,d0
	beq.s	bcrep
	subq	#1,a0
finrep:
	move	a0,d1
	sub	a5,d1
	subq	#skprep,d1
	tst	d4
	beq.s	jl1
	subq	#2,d1
jl1:
	cmp	d7,d1
	ble.s	parepete
	move	d1,d7		;nb octets gagn‚s
	moveq	#1*2,d6		;m‚thode 1 !!!
	move.l	a0,a2
parepete:
;
; 2) corr‚lation
;
;	0->pr‚fixe
;	1->premier caractŠre
;	2->diff‚rence constante
;	3->nb r‚p‚titions (8/16 bits)
;
; gain d'octets quand plus de 4 octets se suivent (>=5)
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
	move.b	(a0)+,d1
	sub.b	(a0),d1
	cmp.b	d1,d0
	bne.s	pacorel
gaincor:
	cmp.l	a6,a0
	bhs.s	fincor
	move.b	(a0)+,d1
	sub.b	(a0),d1
	cmp.b	d1,d0
	beq.s	gaincor
	subq	#1,a0
fincor:
	move	a0,d1
	sub	a5,d1
	subq	#skpcor,d1
	tst	d4
	beq.s	jl2
	subq	#2,d1
jl2:
	cmp	d7,d1
	ble.s	pacorel
	move	d0,d5
	move	d1,d7
	moveq	#2*2,d6
	move.l	a0,a2
pacorel:
;
; 3) r‚p‚tition de chaine dans le code pr‚c‚dent
;
;	0->pr‚fixe
;	1->Offset de la chaine (-1 … -256)
;	2->longueur de la chaine (8/16 bits)
;
; gain d'octets si la chaine contient au moins 3 caractŠres (>=4)
;
	move	#-256,d0
cmpchaine:
	move.l	a5,a0
	lea	0(a5,d0.w),a1
cmpch1:
	cmp.l	a6,a0
	bhs.s	cmpch3
	cmpm.b	(a1)+,(a0)+
	beq.s	cmpch1
	subq	#1,a0
cmpch3:
	move	a0,d1
	sub	a5,d1
	subq	#skpstr,d1
	tst	d4
	beq.s	jl3
	subq	#2,d1
jl3:
	cmp	d7,d1
	ble.s	cmpch2
	move	d1,d7
	moveq	#3*2,d6
	move	d0,d5		;m‚morise offset
	move.l	a0,a2
cmpch2:
	addq	#1,d0
	bne.s	cmpchaine
;
; d6=type de compression … effectuer
; d7=nb octets gagn‚s
; d5=offset pour compression de chaine
; d4=nb octets non compress‚s
;
	jmp	compress(pc,d6.w)
compress:
	bra.s	nocomp
	bra.s	comprep
	bra.s	compcor
	bra.s	compstr
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
	move.b	(a5)+,(a4)+
	addq	#1,d4
	bra	boucle

comprep:
	bsr	fincomp
	move.b	(a5),(a4)+	;poke byte
	move.b	#2,(a3)+	;poke type
	move	a2,d1
	sub	a5,d1
	subq	#cntrep,d1
	move	d1,d0
	lsr	#8,d0
	beq.s	compr1
	addq.b	#1,-1(a3)
	move.b	d0,(a3)+
compr1:	move.b	d1,(a3)+	;poke repet
	move.l	a2,a5
	bra	boucle

compcor:
	bsr	fincomp
	move.b	(a5),(a4)+	;1er octet
	move.b	#4,(a3)+	;poke type
	move.b	d5,(a3)+	;poke diff‚rence
	move	a2,d1
	sub	a5,d1
	subq	#cntcor,d1
	move	d1,d0
	lsr	#8,d0
	beq.s	compc1
	addq.b	#1,-2(a3)
	move.b	d0,(a3)+
compc1:	move.b	d1,(a3)+	;poke compteur
	move.l	a2,a5
	bra	boucle

compstr:
	bsr	fincomp
	move.b	#6,(a3)+	;poke type
	move.b	d5,(a3)+	;poke offset
	move	a2,d1
	sub	a5,d1
	move	d1,d0
	lsr	#8,d0
	beq.s	comps1
	addq.b	#1,-2(a3)
	move.b	d0,(a3)+
comps1:	move.b	d1,(a3)+	;poke compteur
	move.l	a2,a5
	bra	boucle

fini:
;
; indique premiŠre passe finie
;
; optimiser le segment 1 (seg1)
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
	move.b	d0,(a3)+
fin2:	move.b	d4,(a3)+
	moveq	#0,d4
fin3:	rts

	end
;
; 4) topographie
;
;	0->pr‚fixe
;	1->configuration binaire
;	2->octet le plus fr‚quent
;	3->octets moins fr‚quents...
;
; gain d'octets si le premier octet se r‚pŠte au moins
;   3 fois (>=4)
;
	move.l	a5,a0
	move.b	(a0)+,d0
	moveq	#-3,d1
	tst	d4
	beq.s	jl4
	subq	#2,d1
jl4:
	cmp.b	(a0)+,d0
	bne.s	pat1
	addq	#1,d1
pat1:
	cmp.b	(a0)+,d0
	bne.s	pat2
	addq	#1,d1
pat2:
	cmp.b	(a0)+,d0
	bne.s	pat3
	addq	#1,d1
pat3:
	cmp.b	(a0)+,d0
	bne.s	pat4
	addq	#1,d1
pat4:
	cmp.b	(a0)+,d0
	bne.s	pat5
	addq	#1,d1
pat5:
	cmp.b	(a0)+,d0
	bne.s	pat6
	addq	#1,d1
pat6:
	cmp.b	(a0)+,d0
	bne.s	pat7
	addq	#1,d1
pat7:
	cmp	d7,d1
	ble.s	patopo
	move	d1,d7
	moveq	#4*2,d6
	move.l	a0,a2
patopo:

TOPO8=1		;0=topo 8 bits, 1=topo 9 bits
;
; macro pour gestion offsets.W-256
;
inc:	macro
	addq.b	#1,d0
	endm
;blk	macro
;	dcb.\0	\1,\2
;	endm
;
debut:	equ	$40000
fin:	equ	debut+16773
final:	equ	$50000
;
nbmeth=12
;
; d‚compacteur d'octets
;
; V1.0 17/09/89
;
; am‚liorations :
;	- d‚gager les m‚thodes 5 et 7
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
; les nbmeth premiers octets d‚signent la compression
;
;
; d6=lastrep
; d7=lasttopo
;
;
; copy les nbmeth m‚thodes
;
	lea	debut,a0
	lea	fin,a1		;pointeur sur fin fichier compress‚
	lea	final,a6	;code g‚n‚r‚
	moveq	#nbmeth-1,d0
	lea	method(pc),a2
copy:	move.b	(a0)+,(a2)+
	dbra	d0,copy

traduit:
	cmp.l	a1,a0
	bhs	sure

	move.b	(a0)+,d0
;	move	d0,d5			;pour d‚buggage
	cmp.b	method+0(pc),d0
	beq.s	meth0
	cmp.b	method+1(pc),d0
	beq.s	meth1
	cmp.b	method+2(pc),d0
	beq.s	meth2
	cmp.b	method+3(pc),d0
	beq.s	meth3
	cmp.b	method+4(pc),d0
	beq.s	meth4
	cmp.b	method+5(pc),d0
	beq.s	meth5
	cmp.b	method+6(pc),d0
	beq	meth6
	cmp.b	method+7(pc),d0
	beq	meth7
	cmp.b	method+8(pc),d0
	beq	meth8
	cmp.b	method+9(pc),d0
	beq	meth9
	cmp.b	method+10(pc),d0
	beq	meth10
	cmp.b	method+11(pc),d0
	beq	meth11
	move.b	d0,(a6)+
	bra.s	traduit
;
;	0->octet suivant … recopier
;
meth0:
	move.b	(a0)+,(a6)+
	bra.s	traduit
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
meth1:
	move.b	(a0)+,d6
;
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
meth3:
	moveq	#0,d0
	move.b	(a0)+,d0
	addq	#2,d0		;compteur-3
meth1x:
	move.b	d6,(a6)+
	dbra	d0,meth1x
	bra.s	traduit
;
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
meth2:
	move.b	(a0)+,d6
	move.b	(a0)+,d0
	inc
	asl	#8,d0
	move.b	(a0)+,d0
	addq	#2,d0
meth2x:
	move.b	d6,(a6)+
	dbra	d0,meth2x
	bra	traduit
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
meth4:
	moveq	#0,d0
	move.b	(a0)+,d0
	neg	d0
	lea	-2(a6,d0.w),a2

	moveq	#0,d1
	move.b	(a0)+,d1
	addq	#3,d1		;compteur-4
meth4x:	move.b	(a2)+,(a6)+
	dbra	d1,meth4x
	bra	traduit
;
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
meth5:
	moveq	#0,d0
	move.b	(a0)+,d0
	neg	d0
	lea	-2(a6,d0.w),a2

	move.b	(a0)+,d0
	inc
	asl	#8,d0
	move.b	(a0)+,d0
	addq	#3,d0		;compteur-4
meth5x:	move.b	(a2)+,(a6)+
	dbra	d0,meth5x

	bra	traduit
;
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
meth6:
	moveq	#0,d0
	move.b	(a0)+,d0
	inc
	asl	#8,d0
	move.b	(a0)+,d0
	neg	d0
	lea	-2(a6,d0.w),a2

	moveq	#0,d0
	move.b	(a0)+,d0
	addq	#3,d0		;compteur-4
meth6x:	move.b	(a2)+,(a6)+
	dbra	d0,meth6x

	bra	traduit
;
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
meth7:
	moveq	#0,d0
	move.b	(a0)+,d0
	inc
	asl	#8,d0
	move.b	(a0)+,d0
	neg	d0
	lea	-2(a6,d0.w),a2

	moveq	#0,d0
	move.b	(a0)+,d0
	inc
	asl	#8,d0
	move.b	(a0)+,d0
	addq	#3,d0		;compteur-4
meth7x:	move.b	(a2)+,(a6)+
	dbra	d0,meth7x
	bra	traduit
;
;	8->chaine de longueur 3+offset 8 bits
meth8:
	moveq	#0,d0
	move.b	(a0)+,d0
	neg	d0
	lea	-2(a6,d0.w),a2

	moveq	#3-1,d0
meth8x:	move.b	(a2)+,(a6)+
	dbra	d0,meth8x
	bra	traduit
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
meth9:
	move.b	(a0)+,d0	;1er octet
	move.b	(a0)+,d1	;diff‚rence
	moveq	#0,d2
	move.b	(a0)+,d2
	addq	#4,d2		;compteur-5
meth9x:
	move.b	d0,(a6)+
	add.b	d1,d0
	dbra	d2,meth9x
	bra	traduit
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
meth10:
	move.b	(a0)+,d7
;
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
meth11:
	if	TOPO8
	move.b	d7,(a6)+
	endif
	move.b	(a0)+,d1
	moveq	#8-1,d2
meth10x:
	move.b	d7,d3
	add.b	d1,d1
	bcc.s	nomsk1
	move.b	(a0)+,d3
nomsk1:
	move.b	d3,(a6)+
	dbra	d2,meth10x
	bra	traduit
sure:
o:
	lea	$60000,a0
	lea	final,a1
comp:
	cmpm.b	(a0)+,(a1)+
	beq.s	comp
bug:
	illegal
method:
	blk.b	nbmeth,0

	opt	o+

RDBYTE	macro
;
; d‚codage d'un octet Huffmann
;
	move.l	a2,a5
	move	d1,d0		;RELIT LA RACINE
\@1	add	d2,d2
	bne.s	\@2
	bsr	waitdma
\@2	bcc.s	\@3		;ON SAUTE 2 OCTETS OU PLUS...
	add	d0,a5		;TOUT BETEMENT
\@3	move	(a5)+,d0
	bpl.s	\@1
;
; D0.B=OCTET DECODE !!!
;
	endm

TOPO8=1		;0=topo 8 bits, 1=topo 9 bits
;
nbmeth=12
;
; d‚compacteur Hyper Fast
;
; V2.0 17/09/89
; V2.1 12/05/90
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
; … utiliser aprŠs avoir compact‚ un fichier avec H25.S
;
; DECOMPACTEUR HUFFMANN 8 BITS OPTIMAL ???
;
; 03/09/89
; 18/09/89
;
; actuellement, le d‚compacteur d‚compresse … une vitesse (th‚orique)
;  de 20 Kilooctets/sec !!!
;
; LA FIN DU FICHIER EST AUTOMATIQUEMENT DETECTEE GRACE
;   AU CODE DE FIN DU FICHIER QUI EST LE DERNIER DANS L'ARBRE
;
; DEFAUTS :
;	- UN OCTET EST SAUVE EN TROP
;
; REGISTRES UTILISES :
;	d0-d7
;	a0-a5
;
; PROFONDEUR DE PILE UTILISEE :
;	NB BITS HUFFMANN MAXIMUM*8
;	+4 POUR LE PREMIER BSR
;	+QUELQUES OCTETS POUR LES INTERRUPTIONS SI MODE SUPERVISEUR
;
;
; entr‚e :
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+12 octets)
;
; used :
;	a3=adresse de fin de l'arbre
;	a4=registre pour d‚compacteur octets
;	a5=registre pour d‚compacteur Huffmann
;	a6=table d'offsets de branchement
;	d4=bits 15 … 8=0 !!!
;	d6=lastrep
;	d7=lasttopo
;
decomp:
;	LEA	table(pc),a2
;	LEA	source,a0
;	LEA	dest,a1
;
	TAS	D0
	NEG	D0		;MET C … 1

	MOVE.L	a2,a3
	BSR	DECODE0		;COLLECTE LES NOEUDS A PARTIR DE a2
;
; ICI :
; a2=DEBUT ARBRE
; a3=FIN ARBRE
;
	MOVE	(a2)+,D1	;STOCKE LA RACINE DANS UN REGISTRE
;	BMI	bug		;SI ARBRE=UN SEUL OCTET (IMPOSSIBLE)
				;C'EST QU'IL N'Y A RIEN A FAIRE !!!
;
; efface les 256 pointeurs de branchement
;
	moveq	#0,d4		;cleare les bits sup‚rieurs
	move.l	a3,a4
	moveq	#256/4-1,d0
clear:	move.l	d4,(a4)+
	dbra	d0,clear
;
; positionne les nbmeth vecteurs
;
	lea	codes2+nbmeth(pc),a4
	moveq	#nbmeth-1,d3
copy:
	bsr	byte
	move.b	d0,d4
	move.b	-(a4),(a3,d4.w)
	dbra	d3,copy
	bra.s	traduit
sure:
	rts
base:
	move.b	d0,(a1)+
traduit:
	RDBYTE

	cmp.l	a3,a5
	bhs.s	sure

	move.b	d0,d4
	move.b	(a3,d4.w),d4
	jmp	base(pc,d4.w)
;
;	0->octet suivant … recopier
;
meth0:
	bsr	byte
	bra.s	base
;
;	1->r‚p‚tition caractŠre+octet … r‚p‚ter+1 byte(compteur-3)
meth1:
	bsr	byte
	move.b	d0,d6
;
;	3->r‚p‚tition caractŠre pr‚c‚dent+1 byte(compteur-3)
meth3:
	moveq	#0,d3
meth30:
	bsr	byte		;lit compteur-3
	move.b	d0,d3

	move.b	d6,(a1)+
	move.b	d6,(a1)+
meth2x:
	move.b	d6,(a1)+
	dbra	d3,meth2x
	bra.s	traduit
;
;	2->r‚p‚tition caractŠre+octet … r‚p‚ter+2 bytes(compteur-3)
meth2:
	bsr	byte
	move.b	d0,d6

	bsr	byte
	addq	#1,d0
	move.b	d0,d3
	asl	#8,d3
	bra.s	meth30
;
;	4->chaine+offset 8 bits de la chaine+1 byte(compteur-4)
meth4:
	moveq	#0,d3
cnt8:
	bsr	byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	moveq	#0,d3
copy40:
	bsr	byte
	move.b	d0,d3
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
meth4x:	move.b	(a4)+,(a1)+
	dbra	d3,meth4x
	bra.s	traduit
;
;	5->chaine+offset 8 bits de la chaine+2 bytes(compteur-4)
meth5:
	moveq	#0,d3
cnt16:
	bsr.s	byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	bsr.s	byte
	addq	#1,d0
	move.b	d0,d3
	asl	#8,d3
	bra.s	copy40
;
;	6->chaine+offset 16 bits de la chaine+1 byte(compteur-5)
meth6:
	bsr.s	byte
	addq	#1,d0
	move.b	d0,d3
	asl	#8,d3
	bra.s	cnt8
;
;	7->chaine+offset 16 bits de la chaine+2 bytes(compteur-5)
meth7:
	bsr.s	byte
	addq	#1,d0
	move.b	d0,d3
	asl	#8,d3
	bra.s	cnt16
;
;	8->chaine de longueur 3+offset 8 bits
meth8:
	bsr.s	byte
	and	#$ff,d0
	neg	d0
	lea	-2(a1,d0.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+

	bra	traduit
;
;	9->corr‚lation 8 bits+1er octet+diff‚rence+1 byte(compteur-5)
meth9:
	bsr.s	byte
	move.b	d0,d5		;1er octet
	bsr.s	byte
	move.b	d0,d4		;diff‚rence
	bsr.s	byte
	and	#$ff,d0
	addq	#4,d0		;compteur-5
meth9x:
	move.b	d5,(a1)+
	add.b	d4,d5
	dbra	d0,meth9x
	bra	traduit
;
;	10->topo 8 bits+1er octet=octet topo+mask+octets
meth10:
	bsr.s	byte
	move.b	d0,d7
;
;	11->topo 8 bits avec octet topo pr‚c‚dent+mask+octets
meth11:
	ifne	TOPO8
	move.b	d7,(a1)+
	endc
	bsr.s	byte
	move.b	d0,d4
	moveq	#8-1,d3
meth10x:
	move.b	d7,d0
	add.b	d4,d4
	bcc.s	nomsk1
	bsr.s	byte
nomsk1:
	move.b	d0,(a1)+
	dbra	d3,meth10x
	bra	traduit
;
; d‚codage d'un octet Huffmann
;
byte:
	MOVE.L	a2,a5
	MOVE	D1,D0		;RELIT LA RACINE
X1:	ADD	D2,D2
	BEQ.S	X2
	BCC.S	X3		;ON SAUTE 2 OCTETS OU PLUS...
	ADD	D0,a5		;TOUT BETEMENT
X3:	MOVE	(a5)+,D0
	BPL.S	X1
;
; D0.B=OCTET DECODE !!!
;
	rts
X2:
	bsr.s	waitdma
;	MOVE	(a0)+,D2
;	ADDX	D2,D2
	BCC.S	X4		;ON SAUTE 2 OCTETS OU PLUS...
	ADD	D0,a5		;TOUT BETEMENT
X4:	MOVE	(a5)+,D0
	BPL.S	X1
	RTS
;
; DECODAGE DE L'ARBRE DE HUFFMANN
;
; ROUTINE RECURSIVE
;
DECODE3:
	ADDQ	#2,a3		;ON RESERVE DE LA PLACE POUR UN POINTEUR
	PEA	(a3)		;MARQUAGE D'UNE BRANCHE
	BSR.S	DECODE		;a3 POINTE SUR LA FEUILLE DE DROITE
	MOVE.L	(A7)+,a5
	MOVE	a3,D0		;NOUVEAU POINTEUR-ANCIEN POINTEUR
	SUB	a5,D0		;TOUJOURS >0 ET <32768 !!!
	MOVE	D0,-(a5)	;POINTE SUR LA FEUILLE DE GAUCHE
DECODE:
	ADD	D2,D2
	BNE.S	TSTCARY2
DECODE0:
	bsr.s	waitdma
;	MOVE	(a0)+,D2
;	ADDX	D2,D2
TSTCARY2:
	BCC.S	DECODE3

	MOVE	#$8001,D0	;MARQUE UN NOEUD TERMINAL (BIT 15)
L1F2EE:	ADD	D2,D2
	BNE.S	TSTCARY3
	bsr.s	waitdma
;	MOVE	(a0)+,D2
;	ADDX	D2,D2
TSTCARY3:
	ADDX.B	D0,D0
	BCC.S	L1F2EE
	MOVE	D0,(a3)+	;ET STOCKE SA VALEUR
	rts
codes2:
	dc.b	meth0-base,meth1-base,meth2-base,meth3-base
	dc.b	meth4-base,meth5-base,meth6-base,meth7-base
	dc.b	meth8-base,meth9-base,meth10-base,meth11-base
;
; tableau pour d‚compression HUFFMANN
;
; taille maximale : 1026=(256+1)*2-1 words
;
; le nombre total de branches de l'arbre est <=2*nb ‚l‚ments
;
;table:
;	blk.b	1026+256,0
waitdma:
;	cmp.l	adload\w,a0
;	bhs.s	waitdma
;	MOVE	(a0)+,D2
;	ADDX	D2,D2
;	rts

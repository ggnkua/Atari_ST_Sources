;
; Programme d'analyse de data
;
; Indicateur du coefficient de compression
;
	bra.s	o
filein:	dc.b	'DEMO.TOS'
	dc.b	0
fileout:dc.b	'DEMO2.TOS'
	dc.b	0
mess1:	dc.b	'Lecture du fichier',13,10,0
mess2:	dc.b	'Calcul des codes de Huffmann',13,10,0

	even
o:
	pea	mess1(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	clr	-(sp)
	pea	filein(pc)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	tst	d0
	bmi	error
	move	d0,d5		;handle dans d5

	pea	debut
	pea	250000		;nb octets … lire
	move	d5,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	error
	move.l	d0,d7

	move	d5,-(sp)
	move	#$3e,-(sp)	;close
	trap	#1
	addq	#4,sp

	lea	ir,a2
	lea	debut,a1
	add.l	d7,a1
	lea	debut,a0
calcir:
	moveq	#0,d0
	move	(a0)+,d0
	add.l	d0,d0
	addq	#1,0(a2,d0.l)
	cmp.l	a1,a0
	blo.s	calcir
;
; Tri des occurences
;  Par ordre d‚croissant num‚rique
;
	lea	freq,a6
search1:
	lea	ir,a0
	lea	finir,a1
	moveq	#0,d7
	lea	0.w,a2
search2:
	cmp	(a0),d7
	bhs.s	pamax
	move	(a0),d7
	move.l	a0,a2
pamax:	cmp.l	a1,a0
	blo.s	search2
	move.l	a2,d0
	beq.s	finsearch
	move	d7,(a6)+
	sub.l	#ir,d0
	lsr.l	#1,d0
	move	d0,(a6)+
	clr.l	(a6)+		;lien nul pour feuille gauche
	clr.l	(a6)+		;lien nul pour feuille droite
	bra.s	search1
finsearch:

;
; Fr‚quence des occurences
;
;Dim P(255)
;For I%=0 To 255
;  P(I%)=Ir%(I%)/Length%
;Next I%
;
; Calcul de l'entropie
;
;E=0
;For I%=0 To 255
;  If P(I%)>0
;    E=E-P(I%)*Log(P(I%))/Log(2)
;  Endif
;Next I%
;B1%=Int(E*Length%+1)        !on ajoute un bit au maximum
;
; nb de bits aprŠs compression :
;
; int(e*length+1)
;
; nb octets aprŠs compression :
;
; int((e*length+1)+7)/8
;
;
; CALCUL DES CODES DE HUFFMANN
;
	pea	mess2(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

;
; Nb%=nb ‚l‚ments apparaissant dans code
;
;Dim Tree%(Nb%*(Nb%+1)/2,2)
;For I%=0 To Nb%
;  Tree%(I%,0)=Ir%(I%)         ! valeur pour Hu-Tucker algorithm
;  Tree%(I%,1)=-1              ! lien nul pour la feuille gauche
;  Tree%(I%,2)=-1              ! lien nul pour la feuille droite
;Next I%
;
; recherche des 2 valeurs les plus petites
;
; Pour cela, on explore tous les noeuds
; et … chaque fois, on calcule la somme des 2 valeurs les plus basses
;
; M1% pointe sur la valeur la plus haute des deux
; M2% pointe donc sur la valeur la plus basse trouv‚e
;

do:
	lea	0.w,a3		;indique qu'il faut trouver
	move.l	a3,a4		; 2 valeurs quelconques
	lea	freq,a5		;a6 pointe sur la fin de freq
fori:
	move	(a5),d0		;si noeud vide > au suivant
	beq.s	nexti

	move.l	a4,d0
	bne.s	paa4
	move.l	a5,a4
	bra.s	nexti
paa4:
	move.l	a3,d0
	bne.s	paa3
	move	(a5),d0
	cmp	(a4),d0
	bhs.s	m2sup
	move.l	a4,a3
	move.l	a5,a4
	bra.s	nexti
m2sup	move.l	a5,a3
	bra.s	nexti
paa3:
	move	(a5),d0
	cmp	(a3),d0
	bhs.s	nexti

	move	(a5),d0
	cmp	(a4),d0
	bhs.s	m1sup
	move.l	a4,a3
	move.l	a5,a4
	bra.s	nexti
m1sup
	move.l	a5,a3
nexti:
	lea	12(a5),a5
	cmp.l	a6,a5
	blo.s	fori

	move.l	a3,d0
	beq.s	exit	;s'il ne reste plus qu'une valeur, c'est fini !!!
;
; A partir des 2 valeurs trouv‚es, on cr‚e un noeud ayant pour valeur
;  la somme des 2 valeurs
;
	move	(a3),d0
	add	(a4),d0
	move	d0,(a6)+
	clr	(a6)+
	move.l	a3,(a6)+	;pointe sur la composante de gauche
	move.l	a4,(a6)+	;pointe sur la composante de droite
;
; Ensuite on efface les 2 noeuds trouv‚s
;   mais on garde leurs pointeurs
	clr	(a3)
	clr	(a4)
	bra.s	do
exit:
;
; A pr‚sent M2% pointe sur la racine de l'arbre
;
; On calcule ici les codes de Huffmann de chaque ‚l‚ment
;
	moveq	#0,d6		;b
	moveq	#0,d7		;n
	move.l	a4,a6
	bsr.s	dicho
	moveq	#0,d0		;tout s'est bien pass‚
error:
	illegal
;
; On parcourt l'arbre … la recherche des noeuds terminaux
;
; I%=numero du noeud examin‚
; B%=code Huffmann en cours de d‚calage
; N%=nombre de bits du code de Huffmann
;
dicho:
; 4(sp).w=b
; 6(sp).w=n
;
	tst.l	4(a6)
	bne.s	paterm
;
; si le noeud examin‚ est un noeud terminal
; on donne imm‚diatement son code
;
; code de i%"="b% avec n% bits
;
	move	d6,d0		;b
	move	d7,d1		;nb de bits
	move	2(a6),d2	;code de d2=%d0 avec d1 bits !!!
	rts
paterm
	addq	#1,d7		;incr‚mente le nb de bits
	add	d6,d6		;ajoute un z‚ro … droite

	pea	(a6)
	move.l	8(a6),a6
	bsr.s	dicho		;… gauche
	move.l	(sp),a6
	move.l	4(a6),a6
	addq	#1,d6		;ajoute un un … droite
	bsr.s	dicho		;… droite
	move.l	(sp)+,a6

	lsr	#1,d6		;restitue la configuration binaire
	subq	#1,d7		;restitue le nb de bits
	rts
	even
ir:
finir:	equ	ir+65536
debut:	equ	finir
freq:	equ	debut+250000
; tableau de taille variable

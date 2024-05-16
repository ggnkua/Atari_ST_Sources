;
; impl‚mentation ultime du codage de Huffmann
;  finie le 02/09/89
;
; m‚thode g‚niale
;
; compression du type Huffmann avec :
;  - codes Huffmann jusqu'… 31 bits
;  - sauvegarde optimale de l'arbre au d‚but du code
;  - compression des bytes
;  - attention un bit … 1 est sauv‚ … la fin du fichier
;  - le code de fin de fichier est r‚serv‚ au dernier noeud
;      de l'arbre pour faciliter le test de d‚compression
;
; astuces :
;	- mettre la carry … 1 : MOVE #$11,CCR
;	    mieux :	TAS Dn NEG.B Dn
;
;
; codage de Huffmann
;
	pea	mess0(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	clr	-(sp)
	pea	filein(pc)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	tst	d0
	bmi.s	error
	move	d0,d5		;handle dans d5

	pea	file(pc)
	pea	250000		;nb octets … lire
	move	d5,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	d0,d7
	bmi.s	error

	move	d5,-(sp)
	move	#$3e,-(sp)	;close
	trap	#1
	addq	#4,sp

	tst.l	d7
	bne.s	paerr
error:
bug:
	illegal			;fichier nul
paerr:
	move.l	d7,const2

	moveq	#0,d6		;nb ‚l‚ments
	lea	file(pc),a5
	add.l	d7,a5
	btst	#0,d7
	beq.s	pair
	addq	#1,a5
pair:
	pea	mess1(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	a5,a6

	lea	file(pc),a0
	move.l	d7,d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
byte1:
	moveq	#0,d3
	move.b	(a0)+,d3
	movem.l	d0-d3/d7/a0,-(sp)
	bsr	insert
	movem.l	(sp)+,d0-d3/d7/a0
	dbra	d0,byte1
	dbra	d1,byte1
;
; pour une compression de bytes, le code de fin de fichier
;   est le dernier
;
	moveq	#-1,d3
	bsr	insnew		;-1=dernier ‚l‚ment
	move.l	d6,element	;sauve nb ‚l‚ments

	move.l	a5,const3
	move.l	a6,const4

	cmp.l	a5,a6
	beq	bug

	pea	mess2(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
;
; deuxiŠme partie :
;
; tri des fr‚quences dans l'ordre croissant
;
	move.l	a6,a1
	lea	4(a5),a3
;
; pour la compression de type 1, on fait en sorte
;  que le code de fin du fichier soit le premier d‚gag‚
;
	lea	-4(a6),a2
suivant:
	move.l	(a2),(a1)+	;fr‚quence
	clr.l	(a1)+		;indique noeud terminal
	move.l	-4(a2),(a1)+	;valeur du noeud terminal
	clr.l	(a2)

sear2:	move.l	(a3),d7
	bne.s	fnd2
	addq	#8,a3
	cmp.l	a6,a3
	blo.s	sear2
	bra.s	finse
fnd2:	move.l	a3,a4
fnd1:	move.l	a4,a2
searc1:	addq	#8,a4
	cmp.l	a6,a4
	bhs.s	suivant
	move.l	(a4),d0
	beq.s	searc1
	cmp.l	d0,d7
	bls.s	searc1
	move.l	d0,d7
	bra.s	fnd1
finse:
	move.l	a1,const5

	pea	mess3(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
;
; fin de l'arbre=const5
;
	move.l	const4(pc),a5
	move.l	const5(pc),a6
code1:	tst.l	(a5)
	bne.s	pasaut
	lea	12(a5),a5
	bra.s	code1
pasaut:	move.l	a5,a4
	sub.l	a2,a2
	move.l	a2,a3
code2:	move.l	(a4),d1
	bne.s	tester
contin:	lea	12(a4),a4
	cmp.l	a6,a4
	blo.s	code2
	move.l	a3,d0
	beq.s	fincod		;ici a2=racine

	move.l	(a3),d0
	add.l	(a2),d0
	move.l	d0,(a6)+	;cr‚e un nouveau noeud
	move.l	a2,(a6)+
	move.l	a3,(a6)+
	clr.l	(a2)
	clr.l	(a3)
	bra.s	code1
;
; a2 et a3 pointent sur les deux plus petites fr‚quences
; a2 pointe sur la plus petite des 2
; d6=(a2)
; d7=(a3)
; d6<=d7
tester:
	move.l	a2,d0
	bne.s	code3
	move.l	a4,a2		;positionne ptr gauche
	move.l	d1,d6
	bra.s	contin
code3:	move.l	a3,d0
	beq.s	code4
	cmp.l	d7,d1
	bhs.s	contin		;si > valeur la plus grande, on continue
code4:	move.l	a4,a3		;positionne ptr droit
	move.l	d1,d7
	cmp.l	d7,d6
	bls.s	contin
	exg	d7,d6
	exg	a2,a3
	bra.s	contin
fincod:
	move.l	a6,const6
;
; ici a2 pointe sur la racine
;
	move.l	a2,a6
	move.l	a6,racine

	pea	mess4(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	moveq	#1,d5		;d‚calage
	move.l	const6(pc),a3	;adresse codage datas

	moveq	#1,d6		;code Huffmann (avec MSB=1 pour compter
	bsr	huffing		;les bits)

	pea	mess5(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	element(pc),d6
	beq	bug
	move.l	const3,a4	;a4 pointe sur les fr‚quences
	move.l	const4,a5	;a5 pointe sur d‚but arbre
	move.l	const5,a6	;a6 pointe sur fin arbre
retri:
	tst.l	4(a5)
	bne	bug
	move.l	8(a5),d3
	bsr	searchd3
	lea	12(a5),a5
	cmp.l	a6,a5
	blo.s	retri

	pea	mess6(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	const3(pc),a4	;d‚but fr‚quences
	move.l	const2(pc),d7	;nb octets
	move.l	element(pc),d6	;nb ‚l‚ments
	beq	bug

	lea	file(pc),a0
	move.l	d7,d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
byte2:
	moveq	#0,d3
	move.b	(a0)+,d3
	movem.l	d0-d3/d7/a0,-(sp)
	bsr.s	insere
	movem.l	(sp)+,d0-d3/d7/a0
	dbra	d0,byte2
	dbra	d1,byte2
	moveq	#-1,d3		;code de fin de fichier !!
	bsr.s	insere
shift:
	tas	d0
	neg.b	d0
;	move	#$11,ccr
shift0:
	addx.l	d5,d5
	bcc.s	shift0
	move.l	d5,(a3)+	;pattern+bit 1 pour finir fichier

	pea	mess8(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	const6(pc),a0
	move.l	a3,a1
	move.l	a3,d0
	sub.l	a0,d0
;
; fin :
;
;	a0=adresse de d‚but du fichier
;	a1=adresse de fin du fichier
;	d0=nb octets du fichier
;
	illegal
insere:
	move.l	d6,d2
	moveq	#0,d1
	subq.l	#1,d2
p1:	cmp.l	d1,d2
	blo	bug
	move.l	d1,d0
	add.l	d2,d0
	lsr.l	#1,d0
	move.l	d0,d4
	asl.l	#3,d4		;*8
	lea	0(a4,d4.l),a2

	cmp.l	(a2),d3
	bhs.s	p2
	move.l	d0,d2		;borne haute change
	beq	bug
	subq.l	#1,d2
	bra.s	p1
p2:	beq.s	p3
	move.l	d0,d1		;borne basse change
	addq.l	#1,d1
	bra.s	p1
p3:	move.l	4(a2),d0	;set Huffmann code
	add.l	d0,d0
decale:	addx.l	d5,d5
	bcc.s	bit2
	move.l	d5,(a3)+
	moveq	#1,d5
bit2:
	add.l	d0,d0
	bne.s	decale
	rts

insert:
;
; d3.l=offset … ins‚rer dans le tableau des fr‚quences
; tri par insertion dichotomique
;
	move.l	d6,d2
	beq.s	insnew
	moveq	#0,d1
	subq.l	#1,d2
ins1:	cmp.l	d1,d2
	blo.s	insnew2
	move.l	d1,d0
	add.l	d2,d0
	lsr.l	#1,d0
	move.l	d0,d4
	asl.l	#3,d4		;*8
	lea	0(a5,d4.l),a2

	cmp.l	(a2),d3
	bhs.s	superieur
	move.l	d0,d2		;borne haute change
	beq.s	insnew2
	subq.l	#1,d2
	bra.s	ins1
superieur:
	beq.s	samecode
	move.l	d0,d1		;borne basse change
	addq.l	#1,d1
	bra.s	ins1
samecode:
	addq.l	#1,4(a2)	;incr‚mente occurence
	rts
insnew:
	move.l	d3,(a6)+
	moveq	#1,d0
	move.l	d0,(a6)+
	addq.l	#1,d6
	rts

insnew2:
	asl.l	#3,d1		;*8
	lea	0(a5,d1.l),a4

	cmp.l	a4,a6
	beq.s	insnew

; move from : (a4)-(a6) to (a4+8)-(a6+8)

	move.l	a6,d0
	sub.l	a4,d0

	move.l	a6,a0
	lea	8(a6),a1

	moveq	#$30,d2
	cmp.l	d2,d0
	blo.s	nomvm
	movem.l	d3/d6/a4-a6,-(sp)
	divu	#$30,d0
	subq	#1,d0
movet1:
	movem.l	-$38(a1),d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-(a1)
	dbra	d0,movet1
	movem.l	(sp)+,d3/d6/a4-a6
	swap	d0
	lea	-8(a1),a0
nomvm:
	tst	d0
	beq.s	mv5

;	bclr	#1,d0
;	beq.s	mv1
;	move	-(a0),-(a1)
;	tst	d0
;	beq.s	mv5
;mv1:
	bclr	#2,d0
	beq.s	mv2
	move.l	-(a0),-(a1)
	tst	d0
	beq.s	mv5
mv2:	bclr	#3,d0
	beq.s	mv3
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	tst	d0
	beq.s	mv5
mv3:	bclr	#4,d0
	beq.s	mv4
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
mv4:	bclr	#5,d0
	beq.s	mv5
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
mv5:
	tst	d0
	bne	bug
	cmp.l	a4,a0
	bne	bug
	move.l	d3,(a4)+
	moveq	#1,d0
	move.l	d0,(a4)+
	addq	#8,a6
	addq.l	#1,d6
	rts
;
; d3.l=offset … chercher dans le tableau des fr‚quences
; tri dichotomique
;
searchd3:
	move.l	d6,d2
	moveq	#0,d1
	subq.l	#1,d2
s1:	cmp.l	d1,d2
	blo	bug
	move.l	d1,d0
	add.l	d2,d0
	lsr.l	#1,d0
	move.l	d0,d4
	asl.l	#3,d4		;*8
	lea	0(a4,d4.l),a2

	cmp.l	(a2),d3
	bhs.s	s2
	move.l	d0,d2		;borne haute change
	beq	bug
	subq.l	#1,d2
	bra.s	s1
s2:	beq.s	s3
	move.l	d0,d1		;borne basse change
	addq.l	#1,d1
	bra.s	s1
s3:	move.l	(a5),4(a2)	;set Huffmann code
	rts

hufg2:
	pea	(a6)
	move.l	d0,a6
	bsr.s	hufg
	move.l	(sp)+,a6
	move.l	8(a6),a6
hufg:
	tst	d1
	bne.s	okhug
	move.l	4(a6),d0
	bne.s	hufg2
	move.l	8(a6),d0
	addq.l	#1,d0
	bne.s	okhug
	moveq	#-1,d1		;merde, on l'a trouv‚
okhug:	rts

huffing:
	move.l	4(a6),d0
	beq.s	termin		;noeud terminal ???

	add.l	d5,d5
	bcc.s	bit0
	move.l	d5,(a3)+
	moveq	#1,d5
bit0:
	pea	(a6)		;non
	move.l	d0,a6
	add.l	d6,d6
	bcs	bug		;bugge si plus de 31 bits !!!
;
; pour am‚liorer le d‚compacteur de Huffmann, une bidouille :
;
;	pour faire en sorte que le code de fin de fichier
;	 soit le dernier code explor‚ dans l'arbre,
;	j'effectue une recherche pour v‚rifier si on emprunte
;	 sa branche
;	si on le voit, on l'‚vite
;
	moveq	#0,d1		;indique si on l'a trouv‚
	bsr.s	hufg
	move.l	(sp),a6
	move.l	4(a6),a6
	tst	d1
	beq.s	paevite		;on l'a pas trouv‚ -> on continue

	move.l	(sp),a6
	move.l	8(a6),a6
	bsr.s	huffing
	move.l	(sp)+,a6
	addq.b	#1,d6
	move.l	4(a6),a6
	bsr.s	huffing		;on emprunte le chemin de la fin...
	lsr.l	#1,d6
	rts

paevite:
	bsr.s	huffing
	move.l	(sp)+,a6
	addq.b	#1,d6
	move.l	8(a6),a6
	bsr.s	huffing
	lsr.l	#1,d6
	rts
termin:
	add.l	d5,d5
	bcc.s	bit1
	addq	#1,d5
	move.l	d5,(a3)+
	moveq	#0,d5
bit1:
	addq	#1,d5

	move.l	8(a6),d0
	moveq	#7,d1
bit4:	add.b	d0,d0
	addx.l	d5,d5
	bcc.s	bit5
	move.l	d5,(a3)+
	moveq	#1,d5
bit5:	dbra	d1,bit4

	tas	d0
	neg.b	d0
	move.l	d6,d0
;	move	#$11,ccr
bitsev:
	addx.l	d0,d0
	bcc.s	bitsev
	move.l	d0,(a6)		;pattern justifi‚ … gauche+bit 1 … droite
	rts
clc:	add.l	d5,d5
	bcc.s	clc1
	move.l	d5,(a3)+
	moveq	#1,d5
clc1:	rts
sec:	add.l	d5,d5
	bcc.s	sec1
	addq	#1,d5
	move.l	d5,(a3)+
	moveq	#0,d5
sec1:	addq	#1,d5
	rts

frequent:dc.w	0
racine:	dc.l	0
element:dc.l	0
const1:	dc.l	file
const2:	dc.l	0		;longueur fichier
const3:	dc.l	0		;adresse d‚but fr‚quences
const4:	dc.l	0		;adresse fin fr‚quences=d‚but arbre tri‚
const5:	dc.l	0		;adresse fin arbre tri‚
const6:	dc.l	0		;adresse fin arbre complet

mess0:	dc.b	"Lecture du fichier",13,10,0
mess1:	dc.b	"Collecte des octets",13,10,0
mess2:	dc.b	"Tri des fr‚quences",13,10,0
mess3:	dc.b	"Cr‚ation de l'arbre de Huffmann",13,10,0
mess4:	dc.b	"Calcul des codes de Huffmann"
	dc.b	" et sauvegarde de l'arbre",13,10,0
mess5:	dc.b	"Tri des codes de Huffmann",13,10,0
mess6:	dc.b	"G‚n‚ration du code",13,10,0
mess8:	dc.b	"Fini...",13,10,0
filein:	dc.b	'GEN3.IMG'
	dc.b	0
	even
file:

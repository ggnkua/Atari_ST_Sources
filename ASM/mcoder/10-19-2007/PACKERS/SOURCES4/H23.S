;
; type=0 compression des offsets ($2044) (536c)
; type=1 compression des bytes ($1850) (4194)
; type=2 compression des words ($1724) (4f0c)
;
type:	equ	1
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
;
; saisie des offsets … coder
;
	pea	mess7(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	d7,const2

	moveq	#0,d6		;nb ‚l‚ments
	lea	file(pc),a5
	add.l	d7,a5
	btst	#0,d7
	beq.s	pair
	addq	#1,a5
pair:
	moveq	#type,d0
	bne.s	pat01
	lea	file(pc),a0
	move.l	d7,d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
;
; comptage des ‚l‚ments
;
	move.l	a5,a1
	moveq	#0,d2
clr1:	clr.l	(a1)+
	addq.b	#1,d2
	bne.s	clr1

	move.l	a5,a1
count:	moveq	#0,d2
	move.b	(a0)+,d2
	add	d2,d2
	add	d2,d2
	addq.l	#1,0(a1,d2.w)
	dbra	d0,count
	dbra	d1,count

	moveq	#0,d2
	moveq	#0,d0		;maximum
max:	move.l	(a1)+,d1
	cmp.l	d0,d1
	bls.s	pamax
	move.l	d1,d0
	move	d2,d3
pamax:	addq.b	#1,d2
	bne.s	max

	move.b	d3,frequent
pat01:
	pea	mess1(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	a5,a6

	moveq	#type,d0
	bne.s	pat02
	moveq	#0,d2
comp1:
	cmp.b	frequent,d2
	beq.s	bottom

	lea	file(pc),a0
	move.l	d7,d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
	move.l	a0,a1
comp2:	cmp.b	(a1)+,d2
	dbeq	d0,comp2
	dbeq	d1,comp2
	bne.s	bottom

	move.l	a1,d3
	sub.l	a0,d3
	movem.l	d0-d3/d7/a0-a1,-(sp)
	bsr	insert
	movem.l	(sp)+,d0-d3/d7/a0-a1
	move.l	a1,a0
	dbra	d0,comp2
	dbra	d1,comp2
bottom:
	moveq	#-1,d3
	movem.l	d0-d3/d7/a0-a1,-(sp)
	bsr.s	insert
	movem.l	(sp)+,d0-d3/d7/a0-a1
	addq.b	#1,d2
	bne.s	comp1

	move.l	d6,element	;sauve nb ‚l‚ments
	bra	second
pat02:
	subq	#1,d0
	bne.s	pat12
	lea	file(pc),a0
	move.l	d7,d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
byte1:
	moveq	#0,d3
	move.b	(a0)+,d3
	movem.l	d0-d3/d7/a0,-(sp)
	bsr.s	insert
	movem.l	(sp)+,d0-d3/d7/a0
	dbra	d0,byte1
	dbra	d1,byte1
	moveq	#-1,d3
	bsr.s	insert
	move.l	d6,element	;sauve nb ‚l‚ments
	bra	second
pat12:
	lea	file(pc),a0
	move.l	d7,d0
	lsr.l	#1,d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
word1:
	moveq	#0,d3
	move	(a0)+,d3
	movem.l	d0-d3/d7/a0,-(sp)
	bsr.s	insert
	movem.l	(sp)+,d0-d3/d7/a0
	dbra	d0,word1
	dbra	d1,word1
	moveq	#-1,d3
	bsr.s	insert
	move.l	d6,element	;sauve nb ‚l‚ments
	bra	second

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

	move.l	a6,a0
	lea	8(a0),a1

	move.l	a6,d0
	sub.l	a4,d0

	moveq	#$30,d2
	cmp.l	d2,d0
	blo.s	nomvm
	movem.l	d3/d6/a4-a6,-(sp)
	divu	#$30,d0
	subq	#1,d0
movet1:	lea	-$30(a0),a0
	movem.l	(a0),d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,-(a1)
	dbra	d0,movet1
	movem.l	(sp)+,d3/d6/a4-a6
	swap	d0
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
second:
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
suivant:
	move.l	(a2),(a1)+	;fr‚quence
	clr.l	(a1)+		;indique noeud terminal
	move.l	-4(a2),(a1)+	;valeur du noeud terminal
	clr.l	(a2)
	bra.s	sear2
finse:
	move.l	a1,const5

	pea	mess3(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
;
; fin de l'arbre=const5
;
	move.l	const4,a5
	move.l	const5,a6
code1:	tst.l	(a5)
	bne.s	pasaut
	lea	12(a5),a5
	bra.s	code1
pasaut:	move.l	a5,a4
	lea	0.w,a2
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
	move.l	const6,a3	;adresse codage datas

	moveq	#0,d7		;nb bits
	moveq	#0,d6		;code Huffmann
	bsr.s	huffing
	bra	retrie

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
	addq	#1,d7
	cmp	#24,d7
	bhi	bug		;>24 bits ???
	add.l	d6,d6
	bsr.s	huffing
	move.l	(sp)+,a6
	addq.b	#1,d6
	move.l	8(a6),a6
	bsr.s	huffing
	lsr.l	#1,d6
	subq	#1,d7
	rts
termin:
	add.l	d5,d5
	bset	#0,d5
	bcc.s	bit1
	move.l	d5,(a3)+
	moveq	#1,d5
bit1:
	moveq	#type,d0
	beq.s	setres
	subq	#1,d0
	bne.s	l16
	move.l	8(a6),d0
	ror.l	#8,d0
	moveq	#7,d1
	bra.s	bit4
l16:	move.l	8(a6),d0
	swap	d0
	moveq	#15,d1
	bra.s	bit4

; type 0 -> longueur=8,16,24 ou 32 bits !!
setres:
	move.l	8(a6),d0
	move.l	d0,d1
	and.l	#$00FFFFFF,d1
	cmp.l	d0,d1
	beq.s	pa32
	bsr.s	sec
	bsr.s	sec
	bsr.s	sec
	moveq	#31,d1
	bra.s	bit4
pa32:
	swap	d1
	tst	d1
	beq.s	pa24
	bsr.s	sec
	bsr.s	sec
	bsr.s	clc
	moveq	#23,d1
	asl.l	#8,d0
	bra.s	bit4
pa24:
	swap	d1
	and	#$00FF,d1
	cmp	d0,d1
	beq.s	pa16
	bsr.s	sec
	bsr.s	clc
	moveq	#15,d1
	swap	d0
	bra.s	bit4
pa16:	bsr.s	clc
	moveq	#7,d1
	ror.l	#8,d0
bit4:	add.l	d0,d0
	addx.l	d5,d5
	bcc.s	bit5
	move.l	d5,(a3)+
	moveq	#1,d5
bit5:	dbra	d1,bit4

	move.l	d6,d0
	ror.l	d7,d0
	move.b	d7,d0
	subq.b	#1,d0		;nb bits-1
	move.l	d0,(a6)
	rts
clc:	add.l	d5,d5
	bcc.s	clc1
	move.l	d5,(a3)+
	moveq	#1,d5
clc1:	rts
sec:	add.l	d5,d5
	bset	#0,d5
	bcc.s	sec1
	move.l	d5,(a3)+
	moveq	#1,d5
sec1:	rts

retrie:
	pea	mess5(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	element,d6
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

	bra.s	gencod
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
gencod:
	pea	mess6(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	const3,a4	;d‚but fr‚quences
	move.l	const2,d7	;nb octets
	move.l	element,d6	;nb ‚l‚ments
	beq	bug

	moveq	#type,d0
	bne.s	pat03
	moveq	#0,d2
gen1:
	cmp.b	frequent,d2
	beq.s	gen3
	lea	file(pc),a0
	move.l	d7,d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
	move.l	a0,a1
gen2:	cmp.b	(a1)+,d2
	dbeq	d0,gen2
	dbeq	d1,gen2
	bne.s	gen3

	move.l	a1,d3
	sub.l	a0,d3
	movem.l	d0-d3/d7/a0-a1,-(sp)
	bsr	insere
	movem.l	(sp)+,d0-d3/d7/a0-a1
	move.l	a1,a0
	dbra	d0,gen2
	dbra	d1,gen2
gen3:	moveq	#-1,d3
	movem.l	d0-d3/d7/a0-a1,-(sp)
	bsr.s	insere
	movem.l	(sp)+,d0-d3/d7/a0-a1
	addq.b	#1,d2
	bne.s	gen1

shift:	add.l	d5,d5
	bcc.s	shift
	move.l	d5,(a3)+

	move.l	a3,d7
	sub.l	const6,d7	;d7=nb octets

	illegal
pat03:
	subq	#1,d0
	bne.s	pat13

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
	moveq	#-1,d3
	bsr.s	insere
	bra.s	shift
pat13:
	lea	file(pc),a0
	move.l	d7,d0
	lsr.l	#1,d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
word2:
	moveq	#0,d3
	move	(a0)+,d3
	movem.l	d0-d3/d7/a0,-(sp)
	bsr.s	insere
	movem.l	(sp)+,d0-d3/d7/a0
	dbra	d0,word2
	dbra	d1,word2
	moveq	#-1,d3
	bsr.s	insere
	bra.s	shift
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
	move	d0,d1
	ext	d1
decale:	add.l	d0,d0
	addx.l	d5,d5
	bcc.s	bit2
	move.l	d5,(a3)+
	moveq	#1,d5
bit2:	dbra	d1,decale
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

filein:	dc.b	'SEKA.TOS'
	dc.b	0
fileout:dc.b	'SEKA2'
	dc.b	0
mess0:	dc.b	'Lecture du fichier',13,10,0
mess7:	dc.b	'Recherche de l octet le plus fr‚quent',13,10,0
mess1:	dc.b	'Collecte des offsets',13,10,0
mess2:	dc.b	'Tri des fr‚quences',13,10,0
mess3:	dc.b	'Cr‚ation de l arbre de Huffmann',13,10,0
mess4:	dc.b	'Calcul des codes de Huffmann'
	dc.b	' et sauvegarde de l arbre',13,10,0
mess5:	dc.b	'Tri des codes de Huffmann',13,10,0
mess6:	dc.b	'G‚n‚ration du code',13,10,0
	even
file:

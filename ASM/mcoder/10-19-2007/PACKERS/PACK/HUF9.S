;blk	macro
;	dcb.\0	\1,\2
;	endm
;
; impl‚mentation ultime du codage de Huffmann
;  finie le 02/09/89
;  revu le 17/09/89 (‡a va 2 fois plus vite maintenant !!!)
;
; am‚liorations :
;	- travailler d5 en .W
;	- afficher : Longueur originale :
;			Longueur finale :
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

	lea	file(pc),a5
	addq.l	#1,d7
	bclr	#0,d7
	add.l	d7,a5
	move.l	a5,const4

	pea	mess1(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	lea	file(pc),a0
	move.l	const2(pc),d0
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
	lea	frequences(pc),a1
byte1:
	moveq	#0,d3
	move.b	(a0)+,d3
	add	d3,d3
	add	d3,d3
	addq.l	#1,(a1,d3.w)
	dbra	d0,byte1
	dbra	d1,byte1
;
; pour une compression de bytes, le code de fin de fichier
;   est le dernier
;
	addq.l	#1,256*4+frequences

	pea	mess2(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
;
; deuxiŠme partie :
;
; tri par insertion des fr‚quences dans l'ordre croissant
;
	move.l	const4(pc),a1
	lea	frequences(pc),a3
	lea	256*4(a3),a6
;
; on fait en sorte que le code de fin du fichier soit le premier d‚gag‚
;
;	lea	256*4(a3),a2
	move.l	a6,a2
suivant:
	move.l	(a2),(a1)+	;fr‚quence
	clr.l	(a1)+		;indique noeud terminal
	clr.l	(a2)

	move.l	a2,d0
	sub.l	#frequences,d0
	lsr.l	#2,d0
	move.l	d0,(a1)+	;valeur du noeud terminal

sear2:	move.l	(a3)+,d7
	bne.s	fnd2
	cmp.l	a6,a3
	blo.s	sear2
	bra.s	finse
fnd2:	move.l	a3,a4
	subq	#4,a3
fnd1:	lea	-4(a4),a2
searc1:	cmp.l	a6,a4
	bhs.s	suivant
	move.l	(a4)+,d0
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
	move.l	a2,racine

	pea	mess4(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	racine(pc),a6
	moveq	#1,d5		;d‚calage
	move.l	const6(pc),a3	;adresse codage datas

	moveq	#1,d6		;code Huffmann (avec MSB=1 pour compter
	bsr	huffing		;les bits)

	pea	mess5(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
;
; pr‚calcule les codes de Huffmann
;
	move.l	const4(pc),a5	;a5 pointe sur d‚but arbre
	move.l	const5(pc),a6	;a6 pointe sur fin arbre
	lea	frequences(pc),a0
retri:
	move.l	(a5)+,d0	;code de Huffmann
	tst.l	(a5)+
	bne	bug
	move.l	(a5)+,d3
;
; ici d3=code de 0 … 256 inclus (256=fin de fichier)
;
	add	d3,d3
	add	d3,d3
	move.l	d0,(a0,d3.w)	;transfŠre Huffmann code

	cmp.l	a6,a5
	blo.s	retri

	pea	mess6(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	lea	file(pc),a0
	move.l	const2(pc),d0	;nb octets
	subq.l	#1,d0
	move.l	d0,d1
	swap	d1
	lea	frequences(pc),a1
	moveq	#0,d2		;optimisation
byte2:
;
; ici d2=0 !!!
;
	move.b	(a0)+,d2
	add	d2,d2
	add	d2,d2
	move.l	(a1,d2.w),d2	;get Huffmann code
	add.l	d2,d2
decale:	addx.l	d5,d5
	bcc.s	bit2
	move.l	d5,(a3)+
	moveq	#1,d5
bit2:
	add.l	d2,d2
	bne.s	decale
	dbra	d0,byte2
	dbra	d1,byte2

	move.l	256*4+frequences(pc),d0		;code de fin de fichier
	add.l	d0,d0
decale2:addx.l	d5,d5
	bcc.s	bit22
	move.l	d5,(a3)+
	moveq	#1,d5
bit22:
	add.l	d0,d0
	bne.s	decale2
shift:
	tas	d0
	neg.b	d0
;	move	#$11,ccr
shift0:
	addx.l	d5,d5
	bcc.s	shift0
	move.l	d5,(a3)+	;pattern+bit 1 pour finir fichier

	tst	-2(a3)
	bne.s	gain2
	subq	#2,a3
gain2:
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
	cmp.l	#256,d0		;code de fin>256 !!!
	blo.s	okhug
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

racine:	dc.l	0
const1:	dc.l	file
const2:	dc.l	0		;longueur fichier
const4:	dc.l	0		;d‚but arbre tri‚
const5:	dc.l	0		;adresse fin arbre tri‚+d‚but arbre complet
const6:	dc.l	0		;adresse fin arbre complet
frequences:
	blk.l	257,0		;+code fin de fichier

mess0:	dc.b	"Lecture du fichier",13,10,0
mess1:	dc.b	"Calcul des fr‚quences",13,10,0
mess2:	dc.b	"Tri des fr‚quences",13,10,0
mess3:	dc.b	"Cr‚ation de l'arbre de Huffmann",13,10,0
mess4:	dc.b	"Calcul des codes de Huffmann"
	dc.b	" et sauvegarde de l'arbre",13,10,0
mess5:	dc.b	"Tri des codes de Huffmann",13,10,0
mess6:	dc.b	"G‚n‚ration du code",13,10,0
mess8:	dc.b	"Fini...",13,10,0
filein:	dc.b	'GEN1.IMG'
	dc.b	0
	even
file:

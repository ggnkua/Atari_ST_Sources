;
; optimisation des lea (a0,d0.w),a1
;
; 12 D‚cembre : int‚gration de 2 astuces
;	MOVE	D1,D0
;	AND	#X,D0
;	devient :
;	MOVEQ	#X,D0
;	AND	D1,D0
; pour X=-128 … +128 !!!
;
; am‚lioration clippings :
;	neg	dn
;	sub	dn,dm	ou	add	dn,dm
;	bge	rts
;
; devient :
;	add	dn,dm	ou	sub	dn,dm
;	bge	rts
;	neg	dn
;
;	routine de sprite optimis‚e par Nick
;
	opt	o+,t-
resacc	equ	50
resx	equ	8
resy	equ	8
PRG	equ	0		;0=programme .prg
DEBUG	equ	0		;0=d‚bugger r‚sident
BORDER	EQU	1		;0=enlŠve bordure
maxspr	equ	16
maxaff	equ	40		;maximum affich‚=40 sprites !!!!
numspr	equ	8
vais	equ	4+1		;nb sprites du vaisseau+nb sprites tir
larvais	equ	33
hauvais	equ	31
DEC	equ	0		;1=d‚compresse d‚cor
sprtir	equ	vais-1

decor	equ	$37300-$F800	;$F800=nb octets de bitmap
;
; shoot'em up commenc‚ le Mardi 1er Aout 1989
;
; ce qu'il faut faire :
;
; num‚roter les d‚cors :
;	0=indique qu'une vague va apparaitre
;	1 … ??=les diff‚rents ennemis
;	?? … 255=les d‚cors fixes
;
;	- optimiser CLIPPE2 :
;		d‚gager d5, si les plans de droite sont 0
;		 utiliser la routine de clipping … droite !!!
;	- copieur : SOURTRK,SOURSID,DESTTRK,DESTSID
;	- sourceur : HELP->‚cran info, get fonte
;	- packer : Overlay … impl‚menter, tester NOTOPO (gain=10)
;	- sprites d‚cal‚s multiples de 16 pixels
;	- mettre un galaxian et un space invaders
;	- tous les sprites non r‚p‚t‚s sont d‚cal‚s en temps r‚el
;	- les bonus qu'on peut avoir sont les 32 bits d'un long
;	- copieur :
;		affchrono	move.l	timer\w,d7
;				cmp.l	lasttime\w,d7
;				beq.s	rts
;				rol.l	#8,d7
;				cmp.b	lasttime\w,d7
;				beq.s	1$
;			1$	move.l	d7,lasttime\w
;
;	- d‚calage des sprites de 2 en 2
;	- acc‚l‚ration dans jeu :
;		HELP/UNDO
;	  ou	SPACE pendant un certain temps
;	- MAP g‚r‚ sur 3 ‚crans de haut (410 octets)
;	- tests de collision pour le vaisseau au pixel prŠs
;	  (vaisseau=2 rectangles !!!)
;	- optimiser SPRITE16.BIN remplacer rts par jmp(An)
;	- rajouter tests collisions avec d‚cor
;	- code g‚n‚r‚ utilis‚ dans le futur... (pour gros sprites ?)
;	- d‚placement diff‚rentiel au clavier et au joystick
;	- acc‚l‚rer pr‚d‚calages pour scrolling horizontal
;		(1er plans, milieu, derniers plans)
;		(dans PRESENTs)
;	- rajouter tests de protection
;	- ds PACKER d‚placer le code … compresser en fin de m‚moire
;	  2 fois (code originel, code compress‚ 1)
;	 +tester si pas ‚cras‚ avec :
;				LEA	-SCANWIDTH(A5),A0
;				CMP.L	A4,A0
;				BLO	BUG
;	- meme chose dans HUF.S
;
; liste des bugs :
;
;	- blocage du scroll impossible (??)
;	- cf dessins de Florent :
;		1) couleur 15->blanc
;		2) voir avec SOURDEC.S
;	- liste des instructions inexistantes d‚sassembl‚es par MONST :
;		OR.L #,SR AND.L #,SR SUB.B #,CCR SUB #,SR SUB.L #,SR
;		ADD.B #,CCR ADD #,SR ADD.L #,SR EOR.L #,SR
;		CMP.B #,CCR CMP #,SR CMP.L #,SR
;		OR.W An,Dn OR.L An,Dn AND.W An,Dn AND.L An,Dn
;	les instructions comportant un ? doivent etre d‚sassembl‚es :
;		DC.W $xxxx
;
; branchement sur code g‚n‚r‚
;
	ifeq	1
;
; affichage d'un sprite par code g‚n‚r‚ (pas de clipping possible)
;
	moveq	#$f,d2
	and	d1,d2
	eor	d2,d1
	or	d2,d0
	lsr	#1,d1
	lea	mul160\w,a0
	add	d2,d2
	add	(a0,d2.w),d1
	move.l	screen\w,a1
	add	d1,a1		;adresse ‚cran
	add	d0,d0
	add	d0,d0
	lea	tabspr\w,a0
	move.l	(a0,d0.w),a0
	move	(a0)+,(a6)+	;adresse effacement
	move	d1,(a6)+	;offset ‚cran
	lea	test1+4,a4
	and	#15*4,d0
	jmp	(a4,d0.w)	;jmp to code g‚n‚r‚
;
; calcul des offsets d'effacement pour code g‚n‚r‚
;
	lea	test1,a3
	moveq	#0,d6
.calcx
	move.l	a6,(a4)+
	movem	(a3),d0/d1	;nb pixels-1
	addq	#1,d1
;	and	#$fff0,d0	;inutile … cause du lsr
	lsr	#4,d0
	addq	#1,d0
;
; d0=nb plans
; d1=nb lignes
;
	moveq	#$f,d2
	and	(a3),d2
	add	d6,d2		;nb pixels aprŠs d‚calage=nb pixels+d‚calage
	cmp	#16,d2		;est-ce que ‡a rajoute un plan ??
	blo.s	.pl1
	addq	#1,d0
.pl1
;
; entr‚e :
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
; sortie :
;	d2.w=offset affichage
;	d3.w=offset effacement
;
	asl	#4,d0
	lea	branche-16(pc),a0
	add	d0,a0

	move	(a0)+,d2
	sub	d1,d2
	mulu	(a0)+,d2
	add	(a0)+,d2	;offset affichage

	move	(a0)+,d3
	sub	d1,d3
	mulu	(a0)+,d3
	add	(a0),d3		;offset effacement

	move	d3,(a6)+	;offset effacement
	move	d2,(a6)+	;offset affichage
	addq	#1,d6
	and	#15,d6
	bne.s	.calcx

	endc
;
; divers :
;	- mettre des indicateurs blancs sur les dangers courants
;	mieux : mettre des obstacles espac‚s
;	 mettre des indicateurs au sol afin d'aider le joueur
;	- quand on meurt, on revient … l'endroit de la derniŠre vague
;	 d'ennemis pass‚s mais sans les ennemis.
;	- nom : ZODIAC,HARD WAR,CLEANER,LIFE LINE
;	- ZODIAC -> 12 ennemis … affronter
;	- zoom en arriŠre
;	- digit disque (cf CARRIER COMMAND)
;	- hyper load (17 secondes)
;	- chargement pendant jeu (tableau,sprites)
;	- d‚compression update du tableau en Huffmann
;	- routine de pr‚d‚calage super balaise
;	- on lit les masques dans les registres Dn
;	- les formes vont dans An
;	- afficher RANK … cot‚ du score
;	- boot : affiche Amiga Emulator Loading...
;	- jeu : voix digit PLAYER 1 GET READY
;	- d‚placement des lettres de PLAYER
;	- move #$2400,sr coupe les interruptions VBL
;	- move #$2600,sr coupe les interruptions 68901
;	- r‚server 2 octets en (sp) pour un compteur
;	   dans le corps du programme
;	- enlever le caps lock dans CLAV.S
;	- enlever les variables bug (pr‚d‚calage...)
;
; conventions d'‚criture :
;
;	- labels locaux= [chiffre]$ ou .label
;	- utiliser equr
;	- mettre code en $8000, data en $430 et bss en $100
;	    (pile=$400)
;
; QUAND ON EST EN MODE UTILISATEUR, ON NE PEUT
;   ACCEDER A LA MEMOIRE QUI EST ENTRE 0 ET $800 !!!!
;    ET APRES $FFFF0000 !!!
;
; ASTUCE :
;  ON PEUT POKER DES LONGS DANS TOUS LES PORTS E/S
;
; memory map :
;
;	0-7		ROM
;	8->$7F		vecteurs
;	$80->$400	routines interruption
;	$400->$E00	section BSS
;	$E00->???	section code+data
;	??->$372ff	contient les ‚l‚ments de d‚cor
;	$37300->$7ffff	9 ‚crans de buffer
;
basemfp		equ	$40		;vecteurs MFP en $80.w
;
; affichage d'un sprite clipp‚
;
; entr‚e :
;	d0=num‚ro sprite
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;
CLIPPE	MACRO
	opt	ow-		;optimisation des branchements

	asl	#4,d0		;num‚ro du sprite

	moveq	#$f,d5
	and	d1,d5
	add	d5,d3		;nb pixels de largeur
	add	d5,d0
	sub	d5,d1

	add	d0,d0
	add	d0,d0
	lea	(tabspr).w,a0
	move.l	(a0,d0.w),a0
	move	(a0)+,d7	;adresse effacement
	move	(a0)+,a4	;adresse affichage

	add	#15,d3
	and	#$FFF0,d3
	lsr	#1,d3		;d3=nboctets/ligne … afficher

	moveq	#0,d5
	cmp	#200,d2
	blo.s	\@1
	bge	\1		;.S automatique

	neg	d2
	sub	d2,d4
	bls	\1		;.S automatique
	mulu	d3,d2
	add	d2,a0
	lsr	#1,d2
	add	d2,a0		;+1/2 pour les masques
	moveq	#1,d5		;indique clipping en Y
	moveq	#0,d2
	bra.s	\@2
\@1
	move	d2,d0
	add	d4,d0

	lea	(mul160).w,a1
	add	d2,d2
	move	(a1,d2.w),d2

	sub	#200,d0
	bls.s	\@2
	sub	d0,d4
	moveq	#1,d5		;clipping en Y
\@2
	asr	#1,d1
	cmp	#160,d1
	blo.s	\@3
	bge.s	\1		;.S automatique
	neg	d1
	sub	d1,d3
	bls.s	\1		;.S automatique
	move	d1,a3		;coefficient de clipping
	lsr	#1,d1
	add	d1,a3		;a3=multiple de 12 !!!
	add	a3,a0		;+1/2 pour mask
	bra.s	\@4
\@3
	add	d1,d2		;offset ‚cran
	add	d3,d1
	sub	#160,d1
	bhs.s	\@6
\@5
	sub.l	a3,a3
	tst	d5
	bne.s	\@4		;clipping en Y ???
	move	d7,(a6)+	;offset effacement
	move	d2,(a6)+	;poke offset ‚cran
	move.l	(screen).w,a1
	add	d2,a1		;adresse ‚cran
	jmp	(a4)		;bsr affdecale
\@6
	move	d1,a3
	sub	d1,d3
	lsr	#1,d1
	add	d1,a3		;a3=multiple de 12 !!!
\@4
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	add	d3,d3
	lea	branche-16(pc),a1
	add	d3,a1

	move	(a1)+,d5
	sub	d4,d5
	mulu	(a1)+,d5
	add	(a1)+,d5	;offset affichage

	move	(a1)+,d6
	sub	d4,d6
	mulu	(a1)+,d6
	add	(a1),d6		;offset effacement

	move	d6,(a6)+	;offset effacement
	move	d2,(a6)+	;poke offset ‚cran

	move.l	(screen).w,a1
	add	d2,a1		;adresse ‚cran
	move	d5,a4
	jmp	(a4)

	opt	ow+
	ENDM


CLIPPE2	MACRO
;
; d0=num‚ro du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
	asl	#4,d0

	add	d0,d0
	add	d0,d0
	lea	(tabspr).w,a0
	move.l	(a0,d0.w),a0

	moveq	#$f,d5
	and	d1,d5
	add	d3,d5

	moveq	#15,d7		;D7=$F (gain=4 cycles)
	add	d7,d5
	add	d7,d3
	not	d7		;D7=$FFF0 (gain=4 cycles)
	and	d7,d5
	and	d7,d3
	lsr	#1,d5		;d5=nb octets pour effacement
	lsr	#1,d3		;d3=nboctets/ligne … afficher
;
; registres en entr‚e :
;
;	A0=adresse Bitmap du sprite
;	A1=adresse base ‚cran
;	D1=coordonn‚e X haut gauche
;	D2=coordonn‚e Y haut gauche
;	D3=nb octets de largeur=((largeur en pixels+15)and $FFF0)/2
;	D4=hauteur du sprite
;
	sub.l	a3,a3

	cmp	#200,d2
	blo.s	cliphau\@
	bge	retsp\@		;trop en bas
	neg	d2
	sub	d2,d4
	bls	retsp\@
	mulu	d3,d2
	add	d2,a0
	lsr	#1,d2
	add	d2,a0		;+1/2 pour masque
	moveq	#0,d2		;d2=offset ‚cran
	bra.s	noclipbas\@
cliphau\@
	move	d2,d0
	add	d4,d0

	add	d2,d2
	lea	(mul160).w,a1
	move	(a1,d2.w),d2	;d2=offset ‚cran

	sub	#200,d0
	bls.s	noclipbas\@
	sub	d0,d4
noclipbas\@

	move	#160,a2
	moveq	#$F,d0		;isole d‚calage et efface flags clipping
	and	d1,d0
	sub	d0,d1
	add	d0,d0		;*4
	add	d0,d0

	asr	#1,d1		;(X and $FFF0)/2
	cmp	a2,d1		;<160 ?
	blo.s	clipgau\@
	bge.s	retsp\@		;sprite trop … droite
	neg	d1
	sub	d1,d3		;calcule nb plans restants
	bls.s	retsp\@
	sub	d1,d5

	move	d1,a3
	lsr	#1,d1
	add	d1,a3
	add	a3,a0
	or.b	#$40,d0		;indique clipping … gauche
	bra.s	noclipdro\@
clipgau\@
	add	d1,d2		;offset Y
	add	d3,d1
	sub	a2,d1		;>nb plans dans une ligne ?
	blo.s	noclipdro\@
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	sub	d1,d5
	move	d1,a3
	lsr	#1,d1
	add	d1,a3
noclipdro\@
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d5=nb plans*8 … effacer
;	d4=nb lignes
;
	cmp	d3,d5
	bne.s	pacl\@
	btst	#6,d0
	bne.s	pacl\@
	tas	d0
pacl\@
	add	d5,d5
	lea	branche-16+6(pc),a1
	add	d5,a1

	move	(a1)+,d7
	sub	d4,d7
	mulu	(a1)+,d7
	add	(a1),d7		;offset effacement
;
	move	d7,(a6)+	;offset effacement
	move	d2,(a6)+	;poke offset ‚cran

	move.l	(screen).w,a1
	add	d2,a1

	sub	d3,a2
	subq	#1,d4
	lsr	#3,d3

	PEA	(A6)
	LEA	newsprite(pc),a6
	jsr	(a6,d0.w)
	MOVE.L	(SP)+,A6
retsp\@
	ENDM


scroll	macro
	move.l	#\@,$10.w
	bra	scrollit
\@	addq	#6,sp
	endm

CPU	macro
	tst.b	(tabkey+$f).w	;teste TAB
	beq.s	\@
	IFEQ	\1
	clr	$ffff8240.w
	elseif
	move	#\1,$ffff8240.w
	endc
\@
	endm

	OUTPUT	GAME.PRG
;
; header de la demo
;
	OPT	P+
start
	IFEQ	PRG
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#4,sp
	move	#$2700,sr

	moveq	#0,d0
	move.l	d0,$ffff8240.w		;tout noir
	move.l	d0,$ffff8244.w
	move.l	d0,$ffff8248.w
	move.l	d0,$ffff824c.w
	move.l	d0,$ffff8250.w
	move.l	d0,$ffff8254.w
	move.l	d0,$ffff8258.w
	move.l	d0,$ffff825c.w

	movem.l	depl1(pc),d0-d7/a0-a6
	movem.l	d0-d7/a0-a6,$78000

	lea	DEBUT\w,a0
	LEA	codes(pc),A6
	move.l	start-$100+$18(pc),a5	;a5=adresse d‚but BSS !!

	jmp	$78000

depl1
1$	movem.l	(a6)+,d0-d7	;octets … transf‚rer en $300.w
	movem.l	d0-d7,(a0)
	lea	32(a0),a0
	cmp.l	a5,a6		;longueur : 22 octets !!
	blo.s	1$
;
	move.b	$ffff820a.w,chmode\w
	move.b	#3,drive\w	;drive B face 0 !!!!
	clr.b	nbside\w
	jmp	GAME\W
codes
	ELSEIF
	INCLUDE COMP17.S
	ENDC

PILE	equ	$500		;pour gagner un peu de place
topsys	equ	$E00
;resetvar=	$430

	OPT	P-
DEBUTCODE
;
	offset	$400
;
; variables r‚sistant au RESET
;
drive	ds.b	1	;drive de BOOT
nbside	ds.b	1	;nb de faces de la disquette
topram	ds.l	1	;contient adresse haut de la m‚moire
chmode	ds.b	1	;contient $FFFF820A
debug1	ds.l	1
debug2	ds.l	1
debug3	ds.l	1

	even
	offset	$500
clearreset
initialise	ds.b	1	;0=faire restore avant tout (avec ROM)
eteint	ds.b	1	;$FF=ne pas toucher … la diode,0=‚teindre la diode
			;$80=on peut toucher … la diode
cligne	ds.b	1	;compteur de clignotement (0=pas de clignotement)
bascule	ds.b	1	;‚tat diode clignotante
	even
dmaptr	ds.l	1	;pointeur pour test drive not ready
cptdisk	ds.w	1	;compteur pour test drive not ready
xmouse	ds.w	1	;coordonn‚e X relative
ymouse	ds.w	1	;coordonn‚e Y relative
tabkey	ds.b	$76	;tableau des touches
lastclk	ds.b	1	;dernier clic souris
stick0	ds.b	1	;‚tat Joystick0
stick1	ds.b	1	;‚tat Joystick1
timer	ds.b	1
waiter	ds.b	1
	EVEN
hz200	ds.l	1

tabspr	ds.l	(numspr+vais)*16
ptrpix	ds.l	1
pixels	ds.l	numspr+vais	;0.W=taille X-1
				;1.W=taille Y-1
score:	ds.l	1		;score
;
; pointeurs pour rafraichissement de l'‚cran
;
scr1	ds.l	1
cptscr1	ds.w	1
bufscr1	ds.l	1
scr2	ds.l	1
cptscr2	ds.w	1
bufscr2	ds.l	1
scr3	ds.l	1
cptscr3	ds.w	1
bufscr3	ds.l	1
screen:	ds.l	1
cptscr	ds.w	1
bufscreen	ds.l	1
;
freshen:ds.l	1
chif	ds.b	8
;
; variables diverses
;
cptrefresh	ds.w	1
ptrdecor	ds.l	1
elements	ds.l	10	;utilis‚ en mode utilisateur !!!!
nbplan	ds.w	1
nblig	ds.w	1
onemore	ds.w	1
debutbuffer	ds.b	maxaff*4*4	;16=nb sprites max,4=nb octets empil‚s,4=nb ‚crans
finbuffer	ds.b	0

bug1	ds.l	1
;ptruse	ds.l	1
;used	ds.b	16*8		;pour savoir quels sprites d‚caler

ptrmap	ds.l	1		;pointeur courant sur MAP
map	ds.b	10*15		;10 colonnes*8 lignes*2 ‚crans-1 ligne
midmap	equ	map+8*10-10

finbss	ds.b	0

	ifgt	finbss-topsys
	fail
	endc

	section	text

skipscreen	macro
	move.l	(screen).w,d0
	add.l	#208*160,d0
	cmp.l	#$78300,d0
	bls.s	\@
	sub.l	#$41500,d0
\@	move.l	d0,(screen).w
	add	#160,(cptscr).w
	endm

	ORG	$80
DEBUT
	BRA	GAME

	INCLUDE	CLAV5.S
	INCLUDE	DOS4.S
;
vbl2
	move.b	chmode\w,$ffff820a.w
	ifeq	BORDER
	CLR.B	$FFFFFA1B.W
	MOVE.B	#199,$FFFFFA21.W
	move.l	#hbl,basemfp+$20\w
	MOVE.B	#8,$FFFFFA1B.W
	OR.B	#1,$FFFFFA13.W
	OR.B	#1,$FFFFFA07.W
	elseif
	addq.b	#1,timer\w
	endc

	tst.b	tabkey+$3b\w
	beq.s	paf1
	clr	music\w
paf1
	tst.b	tabkey+$3c\w
	beq.s	paf2
	move	#1,music\w
paf2
	tst.b	tabkey+$3d\w
	beq.s	paf3
	move	#2,music\w
paf3
	tst.b	tabkey+$3e\w
	beq.s	paf4
	move	#3,music\w
paf4
	move	d0,-(sp)
music		equ	*+2
	move	#0,d0
latchmus	equ	*+2
	cmp	#-1,d0
	beq.s	samemus
	move	d0,latchmus\w
	bsr	glider
	bra.s	same2
samemus
	bsr	glider+4
	cmp.b	#$80,eteint\w
	bne.s	same2
	cmp.b	#12,d0
	blo.s	.aucun
	move.l	#$0e0e0101,$ffff8800.w
	bra.s	same2
.aucun
	move.l	#$0e0e0707,$ffff8800.w
same2:
	move	(sp)+,d0

	tst.b	eteint\w
	bne.s	1$
;	move	#$80,$ffff8606.w	;constante … cet endroit
	move	d0,-(sp)
	move	$ffff8604.w,d0
	tst.b	d0
	bmi.s	3$
	move.l	#$0e0e0707,$ffff8800.w
	tas	eteint\w
3$	move	(sp)+,d0
1$
	tst.b	cligne\w
	beq.s	2$
	subq.b	#1,cligne\w
	bne.s	2$
	move.b	#25,cligne\w		;toutes les 1/2 secondes
	move.l	#$0E0E0707,$ffff8800.w
	not.b	bascule\w
	bpl.s	2$
	move.b	drive\w,$FFFF8802.w
2$	rte
;
; ENLEVEMENT DE LA BORDURE DU BAS
;
	ifeq	BORDER
hbl:
	addq.b	#1,timer\w
	move.l	d0,-(sp)
	moveq	#13,d0
.1	dbra	d0,.1
.2	move.b	$ffff8209.w,d0
	cmp.b	$ffff8209.w,d0
	bne.s	.2
	eor.b	#2,$ffff820a.w
	moveq	#3,d0
.3	dbra	d0,.3
	move.l	(sp)+,d0
	eor.b	#2,$ffff820a.w
	rte
	endc

timerc
	addq.l	#1,hz200\w
	rol	timerol\w
	bpl.s	pa50
; diviseur soft (50 Hz)
	nop
pa50
	rte
timerol	dc.w	%0001000100010001

monochrom
	addq	#7,$ffff8240.w
	bra.s	monochrom

;	ds.b	$426-*
;	dc.l	$31415926	;426
;	DC.L	RESET		;42A

	ds.b	topsys-*
mul160
x	set	0
	rept	200
	dc.w	x
x	set	x+160
	endr

palette
	DC.W	$000,$650,$124,$236,$333,$444,$555,$665
	DC.W	$420,$700,$240,$000,$332,$443,$554,$666
vitnul
	dc.b	1,1,1,1,2,1,2,1,2,2,2,2,3,2,3,2
	dc.b	3,3,3,3,4,3,4,3,4,4,4,4,5,4,5,4
	dc.b	5,5,5,5,6,5,6,5,6,6,6,6
vitfin
	even
planes	DC.L	$00000000,$80008000,$C000C000,$E000E000
	DC.L	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	DC.L	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	DC.L	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE

GAME
	move	#$2700,sr		;oblig‚ sinon plante !!!
	lea	PILE\w,sp		;r‚serve un Word de comptage
	JSR	debugger

	moveq	#0,d1
	bsr	RESET2
;
; test de RAM
;
	move.l	#$12345678,d0
	lea	$80000,a0		;test de m‚moire … partir de 512K
tstram1
	move.l	d0,(a0)			;efface toute la m‚moire pour ‚viter
	sub.l	d0,(a0)			;tout piratage
	bne.s	tstram2
	lea	$1000(a0),a0
	cmp.l	#$400000,a0		;4 M‚gas ???
	blo.s	tstram1
tstram2
	move.l	a0,topram\w

	LEA	clearreset\W,A0
	MOVE	#(finbss-clearreset)/2-1,D0
1$
	clr	(A0)+
	DBRA	D0,1$
;
; routine de pr‚d‚calage
;
	ifeq	1
;
; 1) pr‚calcul des positions utilis‚es
;
	lea	circle(pc),a0
	moveq	#0,d5		;x d‚part
	moveq	#0,d6		;rotation d‚part
	lea	used(pc),a1
.bcl
	add.b	(a0)+,d6	;nouvelle rotation
	move.b	(a0)+,d0
	ext	d0
	add	d0,d5		;nouveau X
	addq	#1,a0		;on saute Y (on s'en fout)

	move	d6,d0
	asl	#4,d0
	moveq	#$f,d1
	and	d5,d1
	add	d1,d0
	addq.b	#1,(a1,d0.w)	;compte le nb de positions utilis‚es

	cmp.l	#fincircle,a0
	blo.s	.bcl
	endc
;
; 2) pr‚d‚calage des sprites utilis‚s
;
;	move.l	#used,ptruse\w

	lea	bufsp,a6		;adresse de stockage
	lea	tabspr\w,a4		;‚criture

	move.l	#pixels,ptrpix\w
;
; on g‚nŠre le vaisseau d'abord
;
; g‚nŠre datas pour sprites … d‚caler en temps r‚el
;
	lea	dessin1,a5
	moveq	#3,d0
	bsr	prepare
;
; ensuite les tirs
;
; a5=adresse bitmap lecture
; d0=nb sprites … saisir
;
	lea	dessin2,a5
	moveq	#2,d0
	bsr	predecale
;
; ensuite les ennemis
;
	lea	dessin3,a5
	moveq	#numspr,d0
	bsr	predecale

	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	#vbl2,$70.w

; timer C … 200 Hz

	move.l	#timerc,basemfp+$14\w
	move.b	#192,$fffffa23.w
	or.b	#$50,$fffffa1d.w

;	or.b	#$20,$fffffa09.w
;	or.b	#$20,$fffffa15.w

	move.l	#monochrom,basemfp+$3c\w
	or.b	#$80,$fffffa07.w
	or.b	#$80,$fffffa13.w

	move.l	#interdisk,basemfp+$1c\w
	or.b	#$80+$20,$fffffa09.w	;autorise disk+timer C
	or.b	#$80+$20,$fffffa15.w

	MOVE	#$2300,SR	;revalide interruptions pour synchro

	clr.l	score\w

	move.l	#debutbuffer,bufscreen\w
;
; init decor
;
; 1) initialise les pointeurs pour la gestion de la MAP
;
; pour ‚viter bug :
;	remplir MAP avec des 0
;
	move.l	#midmap,ptrmap\w
;
; 2) charge le bitmap des d‚cors
;
charge:
;
; exemple type de chargement
;
	ifeq	DEC
decpak	equ	$3f000			;place pour fast d‚comp

	clr.l	hz200\w
	lea	decpak,a0		;source
	lea	decor,a1		;destination
	lea	$37300,a2		;table de 1026+256 octets
	move.l	a0,adload\w		;adresse chargement
	move	#1,track\w		;num‚ro de piste
	clr	sector\w		;num‚ro de secteur
	move	#(11524+$3ff)/$400,nbsec\w	;nb secteurs
	bsr	senddisk
	jsr	decomp
	move.l	hz200\w,debug1\w	;pour connaitre la dur‚e !!!

	cmp.l	#$37300,a1
	bne.s	2$

	tst.b	errdisk\w
	beq.s	1$
	bmi.s	3$
2$
	move.l	a0,debug2\w
	move.l	a1,debug3\w
	addq	#1,$ffff8240.w
	bra.s	2$		;erreur chargement
1$
	moveq	#-1,d0
4$
	addq	#1,$ffff8240.w
	dbra	d0,4$
3$
	clr.b	eteint\w

	elseif
	lea	decpak,a0		;source
	lea	decor,a1		;destination
	lea	$37300,a2		;table de 1026+256 octets
	bsr	decomp
	endc
;
; init scroll
;
	lea	$80000-208*160*9+8*160,a0
	move	#(208*160*9-8*160)/16-1,d0
	moveq	#0,d1
.xc	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,.xc

	lea	$3f000,a0
	move.l	a0,screen\w
	move.l	a0,freshen\w
	clr	cptrefresh\w
	move.l	#pates,ptrdecor\w
;
; initialise le nb d'images/sec
;
	move.b	#1,waiter\w

	bsr	initgestion

gameover
	CPU	$777

	bra.s	4$

	tst.b	errdisk\w
	beq.s	1$
	bmi.s	2$
3$
	move	#$d0,$ffff8604.w	;STOPPE DRIVE
	clr.b	eteint\w		;‚teint la diode
6$	addq	#1,$ffff8240.w
	bra.s	6$
2$
	move.l	#$80000,adload\w
	move	#1,track\w
	clr	sector\w
	move	#5*80,nbsec\w
8$	bsr	senddisk
	clr	cptdisk\w
1$
	move.l	adload\w,d0
	cmp.l	dmaptr\w,d0
	beq.s	5$
	clr	cptdisk\w
	move.l	d0,dmaptr\w
5$
	addq	#1,cptdisk\w
	cmp	#100,cptdisk\w	;si plus de 100 trames (2sec) sans rien faire
	blo.s	4$		; -> no disk in drive
;
; pas de disk dans le drive
;
7$
	addq	#1,$ffff8240.w
	cmp.l	adload\w,d0
	beq.s	7$
	bra.s	8$
4$

	bsr	effscr
	bsr	deplacevaisseau

	move.b	vitrel\w,d0
	beq.s	pascr2		;vitesse lente si dans le tiers du bas

	subq.b	#1,d0		;moyenne si au milieu
	beq.s	scrollagain
	scroll			;rapide si en haut
	skipscreen
scrollagain
	scroll
	skipscreen
pascr2
	scroll

	bsr	deplacetirs

	CPU	$444

	bsr	deplacedecor

	CPU	$707

	bsr	appennemis	;ennemis apparaissent

	bsr	depennemis	;d‚place ennemis

	bsr	collisions

;
; affichage des sprites
;
	lea	sprites\w,a5
	move.l	bufscreen\w,a6
	lea	retour1(pc),a2
retour1:
	cmp.l	ptrsprite\w,a5
	bhs	afg2
	addq	#4,a5		;skippe s‚quence et type
	movem	(a5)+,d0/d1/d2/d3/d4
;
; d0=num‚ro de sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
	tst	d0
	bmi.s	retour1

	CLIPPE	retour1
afg2
	CPU	$777
;
; affichage des tirs
;
	lea	tirs\w,a5
	lea	retour2(pc),a2
retour2:
	cmp.l	fintir\w,a5
	bhs	notir2

	movem	(a5)+,d0-d4
;
; d0=num‚ro de sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
	tst	d0
	bmi.s	retour2

	CLIPPE	retour2

notir2
;
; affichage du vaisseau
;
	move	posvais\w,d0
	move	coordx\w,d1	;coordonn‚e X
	move	coordy\w,d2	;coordonn‚e Y
	move	d0,d5
	add	d5,d5
	add	d5,d5
	lea	pixels\w,a0
	movem	(a0,d5),d3/d4	;largeur et hauteur

	move	d3,d5
	lsr	#1,d5
	sub	d5,d1		;on centre la coordonn‚e X
;
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
	CLIPPE2

	st	(a6)		;fin des sprites

	CPU	$007

	lea	addscore1+4(pc),a1
	lea	score+4\w,a0
	sub	d0,d0			;CLRX
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
affscore
	move.l	screen\w,a6
	lea	160*(200-8)(a6),a6
	lea	chiffres,a5

	lea	chif(pc),a0
	move.l	score\w,d0
	move.l	d0,d1
	and.l	#$F0F0F0F0,d0
	eor.l	d0,d1
	lsr.l	#2,d0
	add.l	d1,d1
	add.l	d1,d1
	movep.l	d0,0(a0)
	movep.l	d1,1(a0)

	moveq	#6,d2
	moveq	#$18,d3
	moveq	#$3C,d4
	moveq	#$66,d5

	moveq	#0,d0

	lea	1$(pc),a1
	move.b	(a0)+,d0
	jmp	(a5,d0.w)
1$
	lea	2$(pc),a1
	move.b	(a0)+,d0
	jmp	(a5,d0.w)
2$	addq	#6,a6
	lea	3$(pc),a1
	move.b	(a0)+,d0
	jmp	(a5,d0.w)
3$	lea	4$(pc),a1
	move.b	(a0)+,d0
	jmp	(a5,d0.w)
4$	addq	#6,a6
	lea	5$(pc),a1
	move.b	(a0)+,d0
	jmp	(a5,d0.w)
5$	lea	6$(pc),a1
	move.b	(a0)+,d0
	jmp	(a5,d0.w)
6$	addq	#6,a6
	lea	7$(pc),a1
	move.b	(a0)+,d0
	jmp	(a5,d0.w)
7$	lea	8$(pc),a1
	move.b	(a0)+,d0
	jmp	(a5,d0.w)
8$
	move	palette(pc),$ffff8240.w
;
; screen=‚cran … switcher
;
	move.b	screen+1\w,$ffff8201.w
	move.b	screen+2\w,$ffff8203.w

	moveq	#0,d0
	move.b	waiter\w,d0
.sync
	cmp.b	timer\w,d0
	bhi.s	.sync
	clr.b	timer\w
changesync
	tst.b	tabkey+$4e\w
	beq.s	2$			;+ ?
	clr.b	tabkey+$4e\w
	addq.b	#1,waiter\w
	bra.s	3$
2$
	tst.b	tabkey+$4a\w
	beq.s	3$			;- ?
	clr.b	tabkey+$4a\w
	tst.b	waiter\w
	beq.s	3$
	subq.b	#1,waiter\w
3$
;
; utiliser des MOVEM.L pour transf‚rer les octets suivants
;
	move.l	scr2\w,scr1\w
	move	cptscr2\w,cptscr1\w
	move.l	bufscr2\w,bufscr1\w

	move.l	scr3\w,scr2\w
	move	cptscr3\w,cptscr2\w
	move.l	bufscr3\w,bufscr2\w

	move.l	screen\w,scr3\w
	move	cptscr\w,cptscr3\w
	move.l	bufscreen\w,bufscr3\w
	skipscreen
	move.l	bufscreen\w,a0
	lea	maxaff*4(a0),a0
	cmp.l	#finbuffer,a0
	blo.s	setbuf
	lea	debutbuffer(pc),a0
setbuf
	move.l	a0,bufscreen\w
	bra	gameover

addscore1	dc.l	1	;constante !!!!

scrollit:
	subq	#1,cptrefresh\w
	bpl.s	noload
	move	#31,cptrefresh\w

	move.l	ptrdecor\w,a0
	tst.b	(a0)
	bpl.s	pabcl
	lea	pates(pc),a0
pabcl
	move.l	ptrdec\w,a3
	moveq	#10-1,d1
	moveq	#0,d2
	lea	elements\w,a1
	lea	decor-512,a2		;pas de d‚cor 0 !!!

	move.l	ptrmap\w,a4
	lea	-10(a4),a4
	cmp.l	#map,a4
	bhs.s	.okmap
	lea	midmap\w,a4
.okmap
	move.l	a4,ptrmap\w
	lea	8*10(a4),a5
	cmp.l	#midmap,a4
	blo.s	1$
	move.l	a4,a5
1$
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	d0,(a4)+		;poke la MAP
	move.b	d0,(a5)+

;	cmp	#55,d0
;	blo.s	2$
;	cmp	#62,d0
;	bhi.s	2$
; d‚cors au sol (55 … 62 inclus)
;	move	d0,(a3)+
;	move	cptscr\w,(a3)+
;	move	d2,(a3)+
;2$
;	add	#16,d2
	asl	#8,d0
	add.l	d0,d0
	add.l	a2,d0
	move.l	d0,(a1)+
	dbra	d1,1$
	move.l	a0,ptrdecor\w
	move.l	a3,ptrdec\w
noload
	move.l	freshen\w,a6
	cmp.l	#$36e00,a6
	bhs.s	1$
	lea	$3f000,a6
1$
	lea	-160(a6),a6
	move.l	a6,freshen\w
;
; la routine ci-dessous est ex‚cut‚e en mode utilisateur !!!
;
; (cela permet de gagner le registre A7)
;
; donc le tableau ELEMENTS doit etre aprŠs $800.w
;
	and	#$ffff-$2000,sr

	lea	209*160,a7		;constante !!!!

	cmp.l	#$37300,a6
	bhs.s	2$
	add.l	a7,a6
2$
	lea	elements\w,a5

	move.l	(a5),a4
	movem.l	(a4)+,d0-d3
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,d4-d7
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,a0-a3
	move.l	a4,(a5)+

	rept	6
	movem.l	d0-d7/a0-a3,(a6)
	add.l	a7,a6
	endr
	movem.l	d0-d7/a0-a3,(a6)

	cmp.l	#$80000-209*160*2,a6
	bhs	cas2

	add.l	a7,a6
	movem.l	d0-d7/a0-a3,(a6)
	movem.l	d0-d7/a0-a3,(a6,a7.l)

	move.l	(a5),a4
	movem.l	(a4)+,d0-d3
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,d4-d7
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,a0-a3
	move.l	a4,(a5)+

	lea	12*4(a6),a6
	movem.l	d0-d7/a0-a3,(a6,a7.l)
	movem.l	d0-d7/a0-a3,(a6)
	rept	7
	sub.l	a7,a6
	movem.l	d0-d7/a0-a3,(a6)
	endr

	move.l	(a5),a4
	movem.l	(a4)+,d0-d3
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,d4-d7
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,a0-a3
	move.l	a4,(a5)+

	lea	12*4(a6),a6
	rept	7
	movem.l	d0-d7/a0-a3,(a6)
	add.l	a7,a6
	endr
	movem.l	d0-d7/a0-a3,(a6)
	movem.l	d0-d7/a0-a3,(a6,a7.l)

	move.l	(a5),a4
	movem.l	(a4)+,d0-d3
	move.l	a4,(a5)+

	lea	12*4(a6),a6
	movem.l	d0-d3,(a6)
	movem.l	d0-d3,(a6,a7.l)
	rept	7
	sub.l	a7,a6
	movem.l	d0-d3,(a6)
	endr

	illegal

cas2
	movem.l	d0-d7/a0-a3,(a6,a7.l)

	move.l	(a5),a4
	movem.l	(a4)+,d0-d3
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,d4-d7
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,a0-a3
	move.l	a4,(a5)+

	lea	12*4(a6),a6
	movem.l	d0-d7/a0-a3,(a6)
	movem.l	d0-d7/a0-a3,(a6,a7.l)
	rept	6
	sub.l	a7,a6
	movem.l	d0-d7/a0-a3,(a6)
	endr

	move.l	(a5),a4
	movem.l	(a4)+,d0-d3
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,d4-d7
	move.l	a4,(a5)+
	move.l	(a5),a4
	movem.l	(a4)+,a0-a3
	move.l	a4,(a5)+

	lea	12*4(a6),a6
	rept	6
	movem.l	d0-d7/a0-a3,(a6)
	add.l	a7,a6
	endr
	movem.l	d0-d7/a0-a3,(a6)
	movem.l	d0-d7/a0-a3,(a6,a7.l)

	move.l	(a5),a4
	movem.l	(a4)+,d0-d3
	move.l	a4,(a5)+

	lea	12*4(a6),a6
	movem.l	d0-d3,(a6)
	movem.l	d0-d3,(a6,a7.l)
	rept	6
	sub.l	a7,a6
	movem.l	d0-d3,(a6)
	endr

	illegal
;
; efface les sprites dans l'‚cran ant‚p‚nultiŠme
;
effscr
	move.l	scr1\w,d0
	beq.s	effrts
	clr.l	scr1\w
;
; effacement du score
;	move.l	d0,a6		;dest
;	move.l	screen\w,a5	;source
;	move	cptscr\w,d0
;	sub	cptscr1\w,d0
;	add	d0,a5
;x	set	160*(200-24)
;	rept	24-8			;tout sauf derniŠres lignes
;	movem.l	x(a5),d0-d7
;	movem.l	d0-d7,x(a6)
;	movem.l	x+32(a5),d0-d7
;	movem.l	d0-d7,x+32(a6)
;x	set	x+160
;	endr
;
; a5=‚cran source
; a6=‚cran destination
;
	move.l	bufscr1\w,d1
	beq.s	effscr1

	CPU	$700

	move.l	d1,a4
	move.l	d0,a6		;dest

	move.l	screen\w,a5	;source
	move	cptscr\w,d0
	sub	cptscr1\w,d0
	add	d0,a5

	lea	clrspr(pc),a2	;retour d'effdecale
clrspr
	move	(a4)+,d0	;offset ‚cran <32000
	bmi.s	effscr1
	move	d0,a3		;adresse effacement
	move	(a4)+,d0	;offset ‚cran
	move.l	a5,a0
	add	d0,a0
	move.l	a6,a1
	add	d0,a1
	jmp	(a3)		;bsr effdecale
effscr1
effrts	rts
;
;	LA ROUTINE DE SPRITES !!!!
;
; toujours le meme principe...
;
;msk	macro
;	move.l	(a0)+,\2
;	move.l	(a1)+,\1
;	and.l	\2,\1
;	or.l	(a0)+,\1
;	and.l	(a1)+,\2
;	or.l	(a0)+,\2
;	endm
msk	macro
	move.l	(a0)+,\1
	move.l	\1,\2
	and.l	(a1)+,\1
	or.l	(a0)+,\1
	and.l	(a1)+,\2
	or.l	(a0)+,\2
	endm
;
; structure de BRANCHE
;
;	0.w=nombre de lignes qu'on peut afficher au maximum
;	2.w=longueur en octets de chaque affichage
;	4.w=offset d'affichage
;	6.w=nombre de lignes qu'on peut effacer au maximum
;	8.w=longueur en octets de chaque effacement
;	10.w=offset d'effacement
;	12.w=unused
;	14.w=unused
;
lgsp16	equ	12*1+8+2	;nb octets de chaque routine
lgsp32	equ	12*2+8+2	;12*n pour msk
lgsp48	equ	12*3+8+2	;+8 pour movem.l et lea
lgsp64	equ	12*4+8+2	;+2 pour clipping
;
; la plus grande valeur fixe les valeurs (clipping)
;
nblig64	equ	32
nblig16	equ	nblig64
nblig32	equ	nblig64
nblig48	equ	nblig64

branche
	dc.w	nblig16,lgsp16,sp16
	dc.w	nblig16,lgeff16,eff16
	dc.w	0,0

	dc.w	nblig32,lgsp32,sp32
	dc.w	nblig32,lgeff32,eff32
	dc.w	0,0

	dc.w	nblig48,lgsp48,sp48
	dc.w	nblig48,lgeff48,eff48
	dc.w	0,0

	dc.w	nblig64,lgsp64,sp64
	dc.w	nblig64,lgeff64,eff64
	dc.w	0,0
;
; routines de sprite
;
; a0=pointeur en lecture (BITMAP)
; a1=pointeur en ‚criture (ECRAN)
; a2=adresse de retour (gain 12 cycles)
;

sp16					;sprite 16 de large
x	set	nblig16
	rept	nblig16
	msk	d0,d1
	movem.l	d0-d1,-(a1)
x	set	x-1
	ifne	x
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	endc
	endr
	jmp	(a2)
sp32					;sprite 32 de large
x	set	nblig32
	rept	nblig32
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
x	set	x-1
	ifne	x
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	endc
	endr
	jmp	(a2)
sp48					;sprite 48 de large
x	set	nblig48
	rept	nblig48
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	movem.l	d0-d5,-(a1)
x	set	x-1
	ifne	x
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	endc
	endr
	jmp	(a2)
sp64					;sprite 64 de large
x	set	nblig64
	rept	nblig64
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-(a1)
x	set	x-1
	ifne	x
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
	endc
	endr
	jmp	(a2)
;
; d0=adresse effacement du sprite
; a0=‚cran source
; a1=‚cran destination
; a2=adresse de retour
;

lgeff16	equ	12
lgeff32	equ	12
lgeff48	equ	12
lgeff64	equ	12

eff16
x	set	nblig16*160
	rept	nblig16-1
x	set	x-160
	move.l	x(a0),x(a1)
	move.l	x+4(a0),x+4(a1)
	endr
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	jmp	(a2)

eff32
x	set	nblig32*160
	rept	nblig32-1
x	set	x-160
	movem.l	x(a0),d0-d3
	movem.l	d0-d3,x(a1)
	endr
	movem.l	(a0),d0-d3
	movem.l	d0-d3,(a1)
	jmp	(a2)

eff48
x	set	nblig48*160
	rept	nblig48-1
x	set	x-160
	movem.l	x(a0),d0-d5
	movem.l	d0-d5,x(a1)
	endr
	movem.l	(a0),d0-d5
	movem.l	d0-d5,(a1)
	jmp	(a2)
eff64
x	set	nblig64*160
	rept	nblig64-1
x	set	x-160
	movem.l	x(a0),d0-d7
	movem.l	d0-d7,x(a1)
	endr
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	jmp	(a2)
;
; nouvelle routine de sprite d‚calant
;
newsprite
	INCBIN	SPRITE16.BIN
;
; routine efficace de pr‚d‚calage de sprites...
;
; entr‚e :
;	d0=nb sprites … pr‚d‚caler
;	a5=adresse bitmap lecture
;
predecale
	move	d0,-(sp)
decale
	move.l	ptrpix\w,a0
	movem	(a5),d0/d1
	addq	#1,d0
	addq	#1,d1
	move	d0,(a0)+	;m‚morise taille en X
	move	d1,(a0)+	;et taille en Y
	move.l	a0,ptrpix\w
	moveq	#0,d6
1$
	move.l	a6,(a4)+	;poke pointeur

	move.l	a5,a3
	movem	(a3),d0/d1	;nb pixels-1

	addq	#1,d1
;	and	#$fff0,d0	;inutile … cause du lsr
	lsr	#4,d0
	addq	#1,d0

	movem	d0-d1,nbplan\w	;nbplan=d0 et nblig=d1
;
; d0=nb plans
; d1=nb lignes
;
	clr	onemore\w
	moveq	#$f,d2
	and	(a3),d2
	add	d6,d2		;nb pixels aprŠs d‚calage=nb pixels+d‚calage
	cmp	#16,d2		;est-ce que ‡a rajoute un plan ??
	blo.s	7$
	st	onemore\w
	addq	#1,d0
7$
;
; entr‚e :
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
; sortie :
;	d2.w=offset affichage
;	d3.w=offset effacement
;
	asl	#4,d0
	lea	branche-16(pc),a0
	add	d0,a0

	move	(a0)+,d2
	sub	d1,d2
	mulu	(a0)+,d2
	add	(a0)+,d2	;offset affichage

	move	(a0)+,d3
	sub	d1,d3
	mulu	(a0)+,d3
	add	(a0)+,d3	;offset effacement

	move	d3,(a6)+	;offset effacement
	move	d2,(a6)+	;offset affichage

	addq	#4,a3
;
; d1=nblig
;
const	equr	d2
mask	equr	d3
reste1	equr	d4
reste2	equr	d5
cptplan	equr	d7

	lea	planes(pc),a1
	move	d6,const
	add	const,const
	add	const,const
	move.l	(a1,const.w),const

	subq	#2,nbplan\w

	move	nblig\w,d1

	clr.l	bug1\w
2$
	move.l	(a3),d0
	move	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,mask
	and.l	const,mask
	eor.l	mask,d0
	or.l	const,d0
	move.l	d0,(a6)+

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+

	move	nbplan\w,cptplan
	bmi.s	4$
3$
;	swap	mask		;inutile poids fort=poids faible !!!
	swap	reste1
	swap	reste2

	move.l	(a3),d0
	move	(a3)+,d0
	ror.l	d6,d0
	eor.l	mask,d0
	eor.l	d0,mask
	and.l	const,mask
	eor.l	mask,d0
	move.l	d0,(a6)+

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste1,d0
	eor.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste2,d0
	eor.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+

	dbra	cptplan,3$
4$
	tst	onemore\w
	beq.s	5$

	not.l	mask
	and.l	const,mask
	not.l	mask

	swap	reste1
	swap	reste2

	move.l	mask,(a6)+
	move.l	reste1,(a6)+
	move.l	reste2,(a6)+
	bra.s	.b1
5$
	not.l	mask
	and.l	const,mask
	not.l	mask
.b1
;
; … d‚gager dŠs que possible
;
	not.l	mask
	or.l	mask,bug1\w
	or.l	reste1,bug1\w
	or.l	reste2,bug1\w

	subq	#1,d1		;dec nblig
	bne	2$

	tst	onemore\w
	bne.s	.b2
	tst.l	bug1\w
	beq.s	.pabug
	tst	1.w
.b2
	tst.l	bug1\w
	bne.s	.pabug
	tst	1.w
.pabug
	addq	#1,d6
	and	#15,d6
	bne	1$

	move.l	a3,a5

	subq	#1,(sp)
	bne	decale
	addq	#2,sp
	rts

prepare
	move	d0,-(sp)
prepare2
	move.l	ptrpix\w,a0
	movem	(a5),d0/d1
	addq	#1,d0
	addq	#1,d1
	move	d0,(a0)+	;m‚morise taille en X
	move	d1,(a0)+	;et taille en Y
	move.l	a0,ptrpix\w

	moveq	#16-1,d2
1$
	move.l	a6,(a4)+	;poke pointeur
	dbra	d2,1$

	move	(a5)+,d0	;largeur-1
	move	(a5)+,d1	;hauteur-1
	lsr	#4,d0		;d0=nb plans
prep1
	move	d0,d2
prep2
	move	(a5),(a6)+
	move	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbra	d2,prep2
	dbra	d1,prep1

	subq	#1,(sp)
	bne.s	prepare2
	addq	#2,sp
	rts
;
; LA ROUTINE DE RESET SUIVANTE PREND A PEU PRES DEUX TRAMES
;  A S'EXECUTER :
;
;	- 1 TRAME POUR LA SYNCHRO POUR LE CHANGEMENT DE MODE
;	- 1 TRAME POUR LES ECHANGES AVEC LE CLAVIER
;	- boucle si on clique avec la souris
;
;	d1=r‚solution d‚sir‚e
;
RESET2
	MOVE	#$2700,SR
	moveq	#0,d0
	LEA	$FFFF8240.W,A0
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+

	lea	$ffff8209.w,a0
1$	move.b	(a0),d7
	moveq	#20,d6
2$	cmp.b	(a0),d7
	dbne	d6,2$
	bne.s	1$

;	move.b	$ffff8001.w,d7		;memconf
	reset
;	move.b	d7,$ffff8001.w		;memconf
	move.b	chmode\w,$ffff820a.w	;50 Hz
	move.b	d1,$ffff8260.w		;320*200 ou 640*200

	move.l	#$0707C0C0,$FFFF8800.w	;define ports A & B to output
	move.l	#$07078383,$FFFF8200.w	;l'ecran est en $78300
;	move.l	#$0E0E0707,$FFFF8800.W	;deselect drives
	move	#$80,$ffff8606.w	;oblig‚

	sub.l	a0,a0
	movep.l	d0,$FFFFFA01(a0)	;impossible autrement ???
	movep.l	d0,$FFFFFA09(a0)	;(pas avec MOVEM.L)

	moveq	#$10,d0			;define MFP vector
	movep.l	d0,$FFFFFA11(a0)
;
;	move.b	#$10,$fffffa17.w	;define MFP vector
; vector=AEI (bit clear‚ automatiquement)
; basemfp=$40
;
	lea	$fffffc00.w,a2
	move.b	#%11,(a2)
	move.b	#%10+$94,(a2)

	moveq	#1,d6
	lea	codes_ikbd(pc),a3
	moveq	#fincodes_ikbd-codes_ikbd-1,d5
3$
	move	#10000,d7
4$
	btst	d6,(a2)
	dbne	d7,4$
	bne.s	6$
7$	addq	#7,$ffff8240.w		;plantage
	bra.s	7$
6$
	move.b	(a3)+,$fffffc02.w
	dbra	d5,3$
;
	move.l	#midikey,veckey-2\w	;initkey
	move.b	#$40,$fffffa09.w	;autorise interruptions clavier
	move.b	#$40,$fffffa15.w
	rts
codes_ikbd:
	dc.b	$07,0		;set mouse button action
	dc.b	$08		;set relative mouse reporting
	dc.b	$0B,1,1		;treshold=seuil
	dc.b	$10		;Y at the top
	dc.b	$14		;joystick event reporting
fincodes_ikbd:
	even
	INCLUDE	GESTION1.S	;gestion des sprites
;
; le processeur n'atterrit ici que s'il plante
; ‚videmment il est recommand‚ de n'utiliser cette routine
; que pour le d‚buggage
;
debugger:
	ifeq	DEBUG
	INCBIN	DEBUGGER.BIN
	ELSEIF
	lea	8.w,a6
	lea	RESET+$2000000,a0
	moveq	#32-2-1,d0
1$	move.l	a0,(a6)+		;mise en place des vecteurs
	add.l	#$1000000,a0
	dbra	d0,1$			;d'interruption
	move.l	#$31415926,$426.w
	move.l	#RESET,$42a.w
	rts
RESET:	move	#$2700,sr
	move.l	2$(pc),8.w
	move.l	2$+4(pc),12.w
	lea	8+8.w,a0
	move.l	4.w,a1
	move	#($10000-8-8)/4-1,d0
	moveq	#0,d1
	jmp	8.w
2$	move.l	d1,(a0)+	;cleare la page $400 pour eviter plantage ROM
	dbra	d0,2$
	jmp	(a1)		;reboot
	ENDC
pates
;	INCBIN	DECORS.BIN
	INCBIN	TAB2.BIN
	dc.b	$ff
	even
glider
	INCBIN	GLIDER2.BIN
chiffres
	INCBIN	FNT.BIN

decomp	INCBIN	DECOMP6.BIN	;d‚compacteur g‚nial
;
; routine d'attente du pointeur DMA
;
	ifeq	DEC
waitdma
	cmp.l	adload\w,a0
	bhs.s	waitdm2
	move	(a0)+,d2
	addx	d2,d2
	rts
waitdm2
	move.l	d0,-(sp)
	pea	(a1)
	sub.l	a1,a1
waitdm1
	addq	#7,$ffff8240.w
	movep.l	$ffff8609(a1),d0
	lsr.l	#8,d0
	cmp.l	d0,a0
	bhs.s	waitdm1

	move.l	(sp)+,a1
	move.l	(sp)+,d0

	tas	d2
	neg	d2
	move	(a0)+,d2
	addx	d2,d2
	rts

	elseif
	move	(a0)+,d2
	addx	d2,d2
	rts
decpak	INCBIN	NEWDEC.IMG
	endc

;fonte
;	INCBIN	FONTE.IMG
dessin1
	INCBIN	SPR1.IMG
dessin2
	INCBIN	TIR2.BIN
dessin3
	INCBIN	ALIEN1.BIN
;	INCBIN	ALIEN2.BIN
;	INCBIN	CARRES.IMG

	IFNE	PRG
startup
	move.b	$ffff820a.w,chmode\w
	move.b	#3,drive\w
	clr.b	nbside\w
	jmp	DEBUT\W
	ENDC

bufsp

	IFNE	PRG
	EVEN
FINCODE
LONGCODE	EQU	FINCODE-DEBUT
	ENDC

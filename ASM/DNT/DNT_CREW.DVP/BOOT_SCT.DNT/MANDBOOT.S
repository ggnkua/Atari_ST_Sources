;Voici le cadeau bonus (?!?).
;Je n'en parle pas dans l'article sur les boot-sectors (car il n'y a plus
;de place dedans, en fait!) , mais ceci est un petit gag vis-…-vis de BMT
;que je me suis permis de faire (rapidement).C'est un g‚n‚rateur de fractal
;selon Mandelbrot, qui possŠde une vitesse d'affichage bof-bof, c'est pas
;vraiment la meilleure mais bon c'est un boot, hein...
;Bref, le titre ‚tait tout trouv‚ !!.
;
;Pour aller plus vite, je ne me sers pas de la routine de multiplication
;d‚j… utilis‚e dans le DRAWBOOT, mais d'un format adapt‚ aux calculs.
;Il s'agit de nombres d‚cimaux cod‚s en 1 bit de signe, 2 bit de partie
;entiŠre et 13 bits de partie d‚cimale.En gros, on stocke dans un mot
;la valeur sign‚e X*2^13 (on peut donc stocker des nombres allant de
;-4 … +3.9999 avec une pr‚cision (!!) de 1.2E-04).C'est suffisant pour
;Mandelbrot qui ne fait appel qu'… des multiplications, quand on calcule
;X*Y on fait donc (X*2^13)*(Y*2^13)=(X.Y)*2^26
;Pour retrouver le format de d‚part, il faut donc d‚caler de 13 bits …
;gauche, pour obtenir (X.Y)*2^13.
;Voil…, c'est tout, et c'est nul (sans aucune optimisation en taille, tout
;rentre du premier coup mˆme en programmant spaghetti !.En optimisant un tant
;soit peu sur la longueur,y'a eu de la place pour 18 courbes (144 octets !!)).
;
;Si vous voulez speeder cette routine, regardez bien les diff‚rents termes
;… calculer et r‚fl‚chissez un tantinet...Puis pensez que les pr‚calculs ne
;sont pas faits pour les chiens...Et revoyez donc vos formules math‚matiques
;(vous savez, les carr‚s parfaits, et autres...).D‚j…, on peut obtenir un
;kernel de calcul qui prend 20 nops (au lieu d'environ 70 dans cette version)
;pour une it‚ration (et avec une pr‚cision un peu meilleure en plus !!).Et,si
;vous avez le temps (j'ai trouv‚ ‡a aujourd'hui, je pense que ca doit ˆtre ce
;qu'utilise Ford Perfect//BMT (heu, en fait, c'est la seule astuce que j'ai
;trouv‚ !)) tracez donc des courbes ferm‚es quelconques sur l'ensemble de
;Mandelbroot,et remarquez une propri‚t‚ int‚ressante..qui doit bien multiplier
;la vitesse par 10 ou par 20 sur certaines images...je n'en dis pas plus, …
;vous de chercher (par contre, ‡a doit ˆtre p‚nible … programmer, et je ne l'
;ai pas fait).
;
;Cet engin ne peut pas cracher du Julia (j'ai pr‚f‚r‚ mettre plus d'images
;et moins d'algorithmes).La prochaine fois peut-ˆtre ?.Essayez vous-mˆme,
;car les espaces de Julia sont plus beaux et vari‚s.L'algorithme ‚tant
;… peu de choses prŠs le mˆme.
;Dans Mandelbrot:
;    _Pour (Xc,Yc) du plan, X0=0 Y0=0
;                           Xn+1=(Xn^2-Yn^2)+Xc
;                           Yn+1=2*Xn*Yn+Yc
;Dans Julia:
;    _Pour (Xc,Yc) du plan, pour (Xz,Yz) fix‚
;                           X0=Xc Y0=Yc
;                           Xn+1=(Xn^2-Yn^2)+Xz
;                           Yn+1=2*Xn*Yn+Yz
;
;(C)oderight NulloS//DNT 1992

TEST	equ	1
	IFEQ	TEST
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	bsr.s	start
	trap	#1
	clr.w	(sp)
	trap	#1
	ENDC

start	movem.l	palette(pc),d0-7	;
	movem.l	d0-7,$ffff8240.w	;
	move.l	$70.w,-(sp)	;sauve la VBL
	movea.l	sp,a6		;conserve la pile
	lea	Mes1(pc),a2	;affiche les petits messages
	bsr.s	TC_OnOff		;....et coupe le timer C !
	moveq	#127,d0		;attendre un peu
	bsr.s	WaitVsync		;
	lea	Mes2(pc),a2	;message suivant
	bsr.s	Aff_ecran		;
	tst.b	$44c.w		;quelle r‚solution ?
	bne.s	Exit		;aie,pas la bonne
	pea	WaitKey_VBL(pc)	;installe VBL de d‚tection
	move.l	(sp),$70.w		;clavier. (pile non r‚tablie)
	bra.s	first_img		;lance l'algorithme


WaitKey_VBL
	tst.b	$fffffc02.w	;touche appuy‚e ?
	bgt.s	The_End		;ouaip
	rte			;
The_End	move.w	(sp),sr		;r‚tablit le SR
Exit	movea.l	a6,sp		;reprend la pile
	move.l	(sp)+,$70.w	;puis VBL
	lea	Mes2(pc),a2	;r‚affiche le message
TC_OnOff	eori.b	#%00100000,$fffffa09.w;interrupteur Timer C
Aff_ecran	move.l	a2,-(sp)		;
	move.w	#9,-(sp)		;
	trap	#1		;
	addq.l	#6,sp		;
	rts			;

WaitVsync	stop	#$2300
	subq.b	#1,d0
	bne.s	WaitVsync
	rts




;En sortie de WaitVsync,D0.w=0
first_img	lea	Coord(pc),a0	;(re)vient au d‚but des coords
	moveq	#127,d0		;Attente suppl‚mentaire
	bsr.s	WaitVsync		;avant de boucler les "images"
main_bcl	movea.l	$44e.w,a1		;adresse ‚cran
	move.w	#200,(sp)		;200 lignes
	movea.l	#(4<<26),a2	;test pendant le calcul...
	move.b	(a0)+,d0		;profondeur : 1 octet
	beq.s	first_img		;si nulle, fin des images !
	move.w	d0,a4		;transform‚e en 1 mot
	move.b	(a0)+,d0		;puis Delta(XC)
	move.w	d0,a5		;hop-l… boum.
	movea.w	(a0)+,a3		;a3.w=START_YC

;Pendant les calculs:
;(D0,D1)=(Xn,Yn) termes de la suite
;(D2,D3)=calculs interm‚diaires
;D4=profondeur (d‚cr‚ment‚e)
;D5,D6=compteur de pixels
;D7=START_XC puis XC courant
;A0,A1=coordonn‚es, ‚cran
;A2=4,0000 (critŠre de divergence pour la suite : Xn^2+Yn^2>=4)
;A3=START_YC puis YC courant
;A4=profondeur (intacte)
;A5=D_XC
;A6=Save_SSP pour la VBL
;(SP)=compteur de lignes
;
y_bcl	moveq	#19,d6		;20 groupes de 16 pixels
	move.l	(a0),d7		;d7.w=START_XC
x_bcl0	moveq	#15,d5		;16 pixels … la fois
x_bcl1	move.w	d7,d0		;X=XC pour ‚viter la premiŠre
	move.w	a3,d1		;Y=YC it‚ration...
	move.w	a4,d4		;Profondeur de calcul
	bra.s	in_calc		;saute dans la boucle
calc_bcl	sub.l	d3,d0		;X=X^2-Y^2+XC
	swap	d0		;normalise le r‚sultat
	rol.l	#3,d0		;(asr #13 = swap+rol #3)
	add.w	d7,d0		;
	swap	d1		;Y=2*X.Y+YC
	rol.l	#4,d1		;
	add.w	a3,d1		;
in_calc	move.w	d1,d3		;
	muls	d0,d1		;X.Y
	muls	d0,d0		;X^2
	muls	d3,d3		;Y^2
	move.l	d0,d2		;sauvegarde D2
	add.l	d3,d2		;X^2+Y^2
	cmp.l	a2,d2		;>=4 ?
	dbge	d4,calc_bcl	;it‚ration suivante
calc_col	not.b	d4		;inverse la couleur
	lsr.b	#1,d4		;fait entrer la couleur
	roxl.w	(a1)+		;dans le bit suivant de l'‚cran
	lsr.b	#1,d4		;(seuls compte le quartet faible
	roxl.w	(a1)+		;donc modulo 16, pour obtenir
	lsr.b	#1,d4		;plus de nuances affich‚es)
	roxl.w	(a1)+		;Et ce dans les 4 plans
	lsr.b	#1,d4		;
	roxl.w	(a1)+		;
	subq.l	#8,a1		;
	add.w	a5,d7		;XC+Delta(XC)
	dbf	d5,x_bcl1		;suivant !
	addq.l	#8,a1		;groupe de 16 pixels suivant
	dbf	d6,x_bcl0		;
	adda.w	(a0),a3		;YC+Delta(YC)
	subq.w	#1,(sp)		;Next one !
	bne.s	y_bcl		;
	moveq	#0,d0		;Attendre un peu
	bsr	WaitVsync		;
	addq.l	#4,a0		;coordonn‚es suivantes
	bra.s	main_bcl		;




;Les coordonn‚es sont stock‚es en X*2^13.
;Dans l'ordre: profondeur,Delta(XC),START_YC,START_XC,Delta(YC)
;START_?? sont les coordonn‚es du point en haut … gauche sur le moniteur
;Delta(??) est la diff‚rence de coordonn‚es entre deux pixels sur les
;deux axes (donc le point en bas … droite du moniteur a pour coordonn‚es
;X=XC+320*Delta(XC) et Y=YC+200*Delta(YC))
;(donc l'origine des Y est en haut, … l'envers par rapport aux habitudes)
;
;La profondeur change le nombre maximal d'it‚rations subit par la formule,
;et donc la finesse du calcul (inutile de d‚passer une valeur style 100,
;la pr‚cision n'est pas suffisante) et la r‚partition des couleurs.
;
;L'ordre des variables n'est a priori pas logique, mais ‡a gagne les 4 ou
;6 octets n‚cessaires pour faire tenir les 18 "images". 
;voil… voil…...
	RSRESET
PROF	rs.b	1
D_XC	rs.b	1
S_YC	rs.w	1
D_YC	rs.w	1
S_XC	rs.w	1
Coord
;1Šre partie:zoom sur l'avant de l'ensemble de Mandelbrot

	dc.b	16-1,102
	dc.w	-12288,122,-16384

	dc.b	32-1,32
	dc.w	-3609,36,-16384

	dc.b	43-1,2
	dc.w	-198,2,-12000

	dc.b	49-1,1
	dc.w	-100,1,-13500


;2Šme partie:on va sur les "d‚chirures" des bords
	dc.b	27-1,12
	dc.w	5894,17,-2971

	dc.b	36-1,10
	dc.w	-3657,9,-10455

	dc.b	44-1,5
	dc.w	-3584,6,-10752

	dc.b	38-1,1
	dc.w	-7020,1,-105

	dc.b	46-1,1
	dc.w	-4884,1,2794

	dc.b	58-1,2
	dc.w	-$155f,2,$ecad



;S‚rie de zoom-in/zoom-out sur ‚toiles et spirales
	dc.b	50-1,1
	dc.w	-898,1,2936

	dc.b	64-1,2
	dc.w	-$eba0,2,$f2d8

	dc.b	39-1,1
	dc.w	-3948,1,-5848

	dc.b	44-1,7
	dc.w	-6366,7,-624

	dc.b	47-1,1
	dc.w	-6248,1,-124


;Apoth‚ose:spirales "d‚zoom‚es"...
	dc.b	32-1,2
	dc.w	-7100,2,-270

	dc.b	56-1,1
	dc.w	-1900,1,-7075

	dc.b	72-1,3
	dc.w	-1842,3,-6848

	dc.b	0

palette	dc.w	$101,$200,$318,$421,$532,$643,$754,$f65
	dc.w	$f6e,$f5f,$747,$636,$525,$414,$303,$202

;Texte bourr‚ de codes VT-52 pour changer les couleurs fond&‚criture
Mes1	dc.b	$1b,$45,$1b,$63,$01,$1b,$62,$05
	dc.b	$1b,$59,32+12,32+9," DNT-Crew present... "
	dc.b	$d,$0
Mes2	dc.b	$1b,$62,$06,$1b,$63,$0e
	dc.b	$1b,$59,32+12,32+8,"TOAST:The TI-30 Emulator"
	dc.b	$d,$1b,$63,$10,$0



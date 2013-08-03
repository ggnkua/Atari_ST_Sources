;C'est avec joie que je vous pr‚sente la version 474 octets du ZOOMBOOT
;(l'ancienne faisait 488 octets, et le combat a ‚t‚ rude pour terrasser
;l'adversaire !!!).Regardez plut“t le paragraphe d‚lirant que je vais
;de ce pas vous mettre dans l'article sur les boot-sectors, je sens que je
;vais ˆtre un brin joyeux...Je sens un plaisir intense qui me transperce
;litt‚ralement, et je sens aussi que ca va chier dans l'article.Actuellement
;je viens juste de terminer les derniŠres optimisations et je viens de
;constater jouissivement que le boot ne fait plus que 474 octets.Et dŠs que
;cette phrase sera finie, je vais faire charger 1ST WORD … la vitesse de l'
;‚clair pour continuer mon d‚lire orgasmique dans un lieu plus appropri‚.
;A tout de suite !!
;Hop.                   (C)oderight NulloS//DNT1992


TEST	equ	0

	IFEQ	TEST
MAIN	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	move.l	$432.w,-(sp)
	move.l	#variables,$432.w
	bsr.w	DEBUT
	move.l	(sp)+,$432.w
	trap	#1
	addq.l	#6,sp
	clr.w	(sp)
	trap	#1
	ENDC
	
	

DEBUT
	move.l	$432.w,a5		;r‚cupŠre base m‚moire
	lea	zoom_buff(a5),a1	;ainsi que les datas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	a1			;adresse bloc m‚moire
;le sprite doit etre super-entrelac‚ !!! (cad 1 bit du plan 0,1 bit du
;plan 1,1 bit du plan 0,... sur une ligne)
;La routine de zoom se charge de desentrelacer les donn‚es pendant l'
;execution.
zoom1616	movea.l	a1,a4		;conserve zoom_buff pour VBL
	moveq	#8,d7		;9 ‚tapes (8+repeat)
	lea	zoom1616_data(pc),a2	;(^-moveq #9,d7 si zoom normal)
zoom_mast	move.b	(a2)+,d0		;r‚cupŠre data pour le zoom
	lea	boule(pc),a0	;prendre adresse sprite
	moveq	#8-1,d1		;nb de lignes en hauteur
	lea	64(a1),a3		;Pour compl‚ter le sprite
zoom_bcl0	move.w	(a0)+,d2		;r‚cupŠre data bitplan 0&1
	btst	d1,d0		;ligne existante ?
	beq.s	zbcl0_end		;oui,on la saute
	moveq	#0,d4		;init r‚sultat bitplan 0
	moveq	#0,d5		;init r‚sultat bitplan 1
	moveq	#8-1,d3		;8 pixels de large
zoom_bcl1	lsr.w	#1,d2		;sort le point
	roxr.w	#1,d4		;et le fait entrer
	lsr.w	#1,d2		;idem pour le bitplan 0
	roxr.l	#1,d5		;hop
	btst	d3,d0		;point existe vraiment ?
	bne.s	zoom_nxt		;oui,on le laisse
	add.w	d4,d4		;non,on le vire m‚chament
	add.l	d5,d5		;en sortant les bits 31 et 15
zoom_nxt	dbf	d3,zoom_bcl1	;point suivant
	move.l	d5,(a1)+		;stocke le bitplan 0
	move.l	d4,(a1)+		;et biplan 1
zbcl0_end	dbf	d1,zoom_bcl0	;hop,ligne suivante
zoom_clr	cmpa.l	a1,a3
	beq.s	zclr_end		;On efface maintenant les
	clr.l	(a1)+		;lignes inexistantes (on les
	bra.s	zoom_clr		;a saut‚es pendant le zoom)
zclr_end	dbf	d7,zoom_mast	;hop,taille suivante

;En sortie,A1=adresse buffer de coordonn‚es
;          D2=D4=D5=0.w
;	A2=motif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Les lettres doivent TOUTES contenir le meme nombre de bits allum‚s
;(sinon,taille flottante pour les coord,d'ou emmerdement en gestion)
make_coord	move.l	a1,(a5)+		;conserve coor_buff pour VBL
	moveq	#9,d7		;increment (d'Alsace)
	moveq	#-9*2,d1		;coord de d‚part en Y
	moveq	#4,d2		;5 lignes de haut.
mc_bcl1	moveq	#16,d3		;17 bits par mot (axe X)
	moveq	#-9*8+5,d4		;coord de d‚part en X
	move.w	(a2)+,d6		;prendre le motif
mc_bcl2	bcs.s	mc_suite		;oui,pas de boule alors
	move.w	d4,(a1)+		;si,stocke les coords
	move.w	d1,(a1)+		;de la boule
mc_suite	add.w	d7,d4
	add.w	d6,d6		;bit occup‚ ? (dans retenue)
	dbf	d3,mc_bcl2
	add.w	d7,d1
	dbf	d2,mc_bcl1
;En sortie,D6=0 DONC LE COMPTEUR DE ROTATION EST INITIALISE !!!
;          D2=D3=-1
;          A2=sinus_tab
;	A1=adresse table sincos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A1=table finale de sinus/cosinus
;32 valeurs ‚chantillonnees a la base: de 0 … 1 (les 2 extremas) sur sinus
;on recopie ensuite ]1..0[ … la suite
;ca fait donc 32 valeurs … "reflechir".
;puis on cree la partie n‚gative de sinus en copiant ]0..1..0[ a la suite
;Soit 32+32=64 valeurs.Vient s'ajouter un cinquieme quart pour le cosinus
;ce qui donne 64+32=96 valeurs.En tout,table de 128 sinus et cosinus...
make_sincos
	move.l	a1,(a5)+		;Conserve table sincos pour VBL
	lea	64(a1),a1		;
	movea.l	a1,a0		;
	moveq	#31,d7		;Recopier 32 valeurs
sin_bcl1	move.b	(a2)+,d5
	move.w	d5,-(a1)
	move.w	d5,(a0)+
	dbf	d7,sin_bcl1	;on a donc sin pour ]0..PI[
	moveq	#95,d7		;copie sur 96 valeurs (cf -^)
sin_bcl2	move.w	(a1)+,(a0)		;pour obtenir la seconde moiti‚.
	neg.w	(a0)+		;ca donne sin pour ]0..2PI[
	dbf	d7,sin_bcl2	;et dans la foul‚e,on rajoute skifo
				;pour le cosinus:cos(x)=sin(x+PI/2)
;En gros,on a construit,… partir de / (1er quart de la courbe sinus) une
;courbe: /\  /
;          \/
;       |base sinus
;        |base cosinus
;En sortie,A0=save1_buff ET D7=-1 DONC COMPTEUR DE VBL INITIALISE !!!!

	clr.w	(a5)+		;init le swapping
;	move.l	#$00203040,d5	;6
;	lea	$ffff8240.w,a1	;4
;	movep.l	d5,0(a1)		;4
	move.l	#$02010321,$ffff8240.w;8
	move.l	#$04320654,$ffff8244.w;8

	move.l	$44e.w,-(sp)
	move.l	(sp),d5
	move.l	d5,(a5)		;ecran1
	lea	256(a0),a6
	bsr.s	aff_ecran
	move.l	a6,d5
	clr.b	d5
	move.l	d5,(NB_SPRITE+1)*4(a5);ecran2
	bsr.s	aff_ecran
	move.l	$70.w,-(sp)
	pea	VBL(pc)
	move.l	(sp)+,$70.w
wait	tst.b	$fffffc02.w
	ble.s	wait
	move.l	(sp)+,$70.w
	move.l	(sp)+,d5
aff_ecran	clr.w	-(sp)
	move.l	d5,-(sp)
	move.l	d5,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
the_end	rts

	


;En VBL,les registres suivants sont bloqu‚s:
;
;	_A2=ecran de la VBL
;	_A3=coordonn‚es des points
;	_A4=sprites zoom‚s (du +petit au +grand)
;	_A5=sauvegarde de la VBL
;	_A6=cosinus
;	_D4=160 (on le conserve pour les calculs)
;	_D5=offset pour la taille du sprite
;	_D6=rotation
;	_D7=compteur ecran
;
VBL	move.l	$432.w,a5
	movea.l	(a5)+,a3
	movea.l	(a5)+,a6
	move.w	#160,d4
	eori.w	#(NB_SPRITE+1)*4,(a5)
	adda.w	(a5)+,a5
	move.l	(a5)+,a2
	movea.l	a5,a1
	tst.w	d7
	ble.s	vbl_noclr
	moveq	#NB_SPRITE-1,d1
vbl_clr0	moveq	#7,d2
	movea.l	(a1)+,a0
vbl_clr1	clr.l	(a0)
	clr.l	8(a0)
	adda.w	d4,a0
	dbf	d2,vbl_clr1
	dbf	d1,vbl_clr0

vbl_noclr	move.l	a2,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	cmp.w	d4,d7
	beq.s	vbl_0
	addq.w	#1,d7
vbl_0	addq.b	#2,d6
	adda.w	d6,a6
	move.l	d7,d5
	lsl.w	#3,d5
	divu.w	d4,d5
	lsl.w	#6,d5	
	move.w	d7,-(sp)		;conserve le compteur VBL
	moveq	#NB_SPRITE-1,d7
vbl_bcl0	move.w	(a3)+,d0
	move.w	(a3)+,d2		;(X,X)-(Y,Y)
	move.w	d0,d1
	move.w	d2,d3
	muls.w	64(a6),d0		;(Xcos,Xsin)/(Ysin,Ycos)
	muls.w	(a6),d1		;rotation:X'=Xcos-Ysin
	muls.w	(a6),d2		;         Y'=Xsin+Ycos
	muls.w	64(a6),d3		;
	sub.w	d2,d0		;Ici,X'
	add.w	d3,d1		;puis Y'
	asr.w	#7,d0		;corrige l'amplitude du
	asr.w	#7,d1		;sinus (128=2^7)
	muls	(sp),d0		;multiplie par le coeff
	muls	(sp),d1		;de profondeur actuel
	divs	d4,d0		;divise par le coeff maximal
	divs	d4,d1		;on simule ainsi l'‚liognement
	add.w	d4,d0		;centre X et Y sur l'‚cran
	addi.w	#100,d1		;

	mulu.w	d4,d1
	movea.l	a2,a0
	ror.l	#4,d0
	lsl.w	#4,d0
	lsr.w	#1,d0
	add.w	d0,d1
	adda.w	d1,a0
	move.l	a0,(a5)+
	rol.l	#4,d0
	movea.l	a4,a1
	adda.w	d5,a1
	moveq	#7,d1

vbl_bcl1	move.l	(a1)+,d2	;pendant le zoom,on a fait rentrer les
	move.l	(a1)+,d3	;pixels du plan0 (D2) dans les bits 31-16
	ror.l	d0,d2	;et ceux du plan1 (D3) dans 15-0.Donc
	ror.l	d0,d3	;aprŠs les rotations D2 contient les parties
	eor.w	d2,d3	;gauche et droite du plan0,et D3 les parties
	eor.w	d3,d2	;droite et gauche.Les 3 EOR.W echange les
	eor.w	d2,d3	;mots bas de D2 et D3, le swap remet dans
	swap	d3	;le bon ordre les deux plans de D3
;Les 3 EOR sont plus rapides que de passer par la pile. (aucun registre libre!)
;Cf l'article "LOGIQUE!" si vous voulez comprendre ce miracle de la techno-
;logie moderne...
	or.l	d2,(a0)
	or.l	d3,8(a0)
	adda.w	d4,a0
	dbf	d1,vbl_bcl1
	dbf	d7,vbl_bcl0
	move.w	(sp)+,d7
	rte
	
;Les donn‚es suivantes sont entrelac‚es bit-…-bit.
boule	dc.w	%0000100101100000
	dc.w	%0001111111011000
	dc.w	%1011111111101010
	dc.w	%0111111101100101
	dc.w	%0101110110011101
	dc.w	%1001010101111110
	dc.w	%0001010111110100
	dc.w	%0000100101100000
	
zoom1616_data	equ	*-1
;	dc.b	%00010000
	dc.b	%01000100
	dc.b	%10010010
	dc.b	%10101010
	dc.b	%10101101
	dc.b	%10111011
	dc.b	%10111111
	dc.b	%11111111
	dc.b	%11111111
;Je vous explique:ceci est la derniŠre optimisation que je viens d'apporter
;Il y a neuf tailles de balle possibles (car l'affichage considŠre les
;tailles de 0 … 8!!) donc il y a deux fois %11111111 (pleine taille).
;Mais neuf octets donnent une adresse impaire.Il faudrait en rajouter un
;10Šme,et perdre 2 octets en tout.Au lieu de cela, on se sert du dernier
;octet de graphisme qui vaut %01100000.Certes, ce n'est pas %00010000, mais
;c'est encore mieux: par un coup de bol ph‚nom‚nal, cela donne un effet de
;flou lorsque le logo DNT est "loin", et cela assure une meilleure tran-
;sition de luminosit‚ qu'avec %00010000.L…, j'avoue que j'ai sacr‚ment de
;la chance...Mais de toute fa‡on mˆme sans cela le boot fait 476 octets,
;donc les pointilleux-du-zoom peuvent remettre le zoom normal...
;Putain, je ne tiens plus, faut que j'aille mettre l'en-tˆte de ce source
;avant d'exploser dans l'article sur les boot-sectors !!.


motif	dc.w	%0001101100100000
	dc.w	%0110100100100000
	dc.w	%0110100000111011
	dc.w	%0110100100111011
	dc.w	%0001100110111011
NB_SPRITE	equ	49

sinus_tab
	dc.b	128,128,127,126,125,123,122,119
	dc.b	117,114,111,108,105,101,097,093
	dc.b	088,084,079,074,068,063,058,052
	dc.b	046,040,034,028,022,016,009,003
	RSRESET
coord	rs.l	1
cosinus	rs.l	1

swap	rs.w	1

ecran1	rs.l	1	;en tout,ca fait NB_SPRITE+1 mot-longs
save1_buff	rs.l	NB_SPRITE	;

ecran2	rs.l	1	;ici aussi
save2_buff	rs.l	NB_SPRITE	;

zoom_buff	rs.l	9*8*8	;sprites 8*8,9 tailles,8 octets/ligne
coor_buff	rs.l	24*3
sico_buff	rs.w	32*5
scre_buff	rs.b	32256

FIN	equ	*
	IFEQ	TEST
	SECTION	BSS
variables	ds.l	40000
	ENDC

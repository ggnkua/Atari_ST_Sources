* routine de clipping de segment de droite
* algorithme de fenˆtrage 2D explicite
* par Golio Junior pour Falk'mag 7

* D‚finition de l'image
Video_mode		equ %000100100	* 40 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 320*200*2
ecran_largeur	equ 320
ecran_hauteur	equ 200
Pas_Fond		equ 0

* zone de clipping
min_x	equ 100
max_x	equ 220
min_y	equ 40
max_y	equ 160

	include "principa.s"

prg_init
				* effacement de l'‚cran
	move.w #ecran_largeur*ecran_hauteur/8-1,d0
	move.l #-1,d1
	movea.l adr_ecran,a0
prg_init_b1
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbra d0,prg_init_b1
				* coloriage de la zone de clipping pour bien voir 
	movea.l adr_ecran,a0
	adda.l #(ecran_largeur*min_y+min_x)*2,a0
	move.l #0,d2
	move.w #max_y-min_y-1,d0
prg_init_b2
	move.w #(max_x-min_x)/8-1,d1
prg_init_b3
	move.l d2,(a0)+
	move.l d2,(a0)+
	move.l d2,(a0)+
	move.l d2,(a0)+
	dbra d1,prg_init_b3
	adda.l #(ecran_largeur-(max_x-min_x))*2,a0
	dbra d0,prg_init_b2
	
	clr.w compteur
	rts

prg
				* prise au hasard des coordonn‚es du segment
	move.w #17,-(sp)
	trap #14
	addq.l #2,sp
	move.w d0,d4
	andi.w #$1FF,d4		* il faut quand mˆme que les coordonn‚es
				* ne soient pas trop exotiques!
	
	move.w #17,-(sp)
	trap #14
	addq.l #2,sp
	move.w d0,d5
	andi.w #$1FF,d5

	move.w #160,d6		* les autres coordonn‚es pour voir quelquechose
	move.w #100,d7

				* d‚but du clipping simple
				* comparaison avec le bord gauche de la fenˆtre
				* pour savoir si les extr‚mit‚s sont … l'int‚rieur
	cmp.w #min_x,d4
	bgt clip_gauche_bis
				* le bord gauche est coup‚ par le 1er point
	cmp.w #min_x,d6
	blt pas_visible
				* mais par un seul point
				* calcul du point d'intersection
				* calcul de la pente
	move.w d6,d0
	sub.w d4,d0		* r‚sultat positif car d6>d4 !
	move.w d7,d1
	sub.w d5,d1
	beq clip_gauche_horizontal	* segment horizontal
	swap d1
	clr.w d1
	ext.l d0
	divs.l d0,d1
				* calcul de dx
	sub.w #min_x,d4
	neg.w d4
	ext.l d4
				* calcul du dy … ajouter
	muls.l d4,d1
	swap d1
	add.w d1,d5

clip_gauche_horizontal		* segment horizontal,
				* donc intersection facile … calculer
	move.w #min_x,d4
	bra clip_droit
clip_gauche_bis
	cmp.w #min_x,d6
	bgt clip_droit
				* le bord gauche est coup‚ par le second point,
				* mais pas par le premier
				* calcul du point d'intersection
				* calcul de la pente
	move.w d4,d0
	sub.w d6,d0		* r‚sultat positif car d4>d6 !
	move.w d5,d1
	sub.w d7,d1
	beq clip_gauche_bis_horizontal	* segment horizontal
	swap d1
	clr.w d1
	ext.l d0
	divs.l d0,d1
				* calcul de dx
	sub.w #min_x,d6
	neg.w d6
	ext.l d6
				* calcul du dy … ajouter
	muls.l d6,d1
	swap d1
	add.w d1,d7

clip_gauche_bis_horizontal		* segment horizontal,
				* donc intersection facile … calculer
	move.w #min_x,d6
clip_droit
				* comparaison avec le bord droit de la fenˆtre
				* pour savoir si les extr‚mit‚s sont … l'int‚rieur
	cmp.w #max_x,d4
	blt clip_droit_bis
				* le bord droit est coup‚ par le 1er point
	cmp.w #max_x,d6
	bgt pas_visible
				* mais par un seul point
				* calcul du point d'intersection
				* calcul de la pente
	move.w d4,d0
	sub.w d6,d0		* r‚sultat positif car d4>d6 !
	move.w d7,d1
	sub.w d5,d1
	beq clip_droit_horizontal	* segment horizontal
	swap d1
	clr.w d1
	ext.l d0
	divs.l d0,d1
				* calcul de dx
	sub.w #max_x,d4
	ext.l d4
				* calcul du dy … ajouter
	muls.l d4,d1
	swap d1
	add.w d1,d5

clip_droit_horizontal			* segment horizontal,
				* donc intersection facile … calculer
	move.w #max_x,d4
	bra clip_haut
clip_droit_bis
	cmp.w #max_x,d6
	blt clip_haut
				* le bord droit est coup‚ par le second point,
				* mais pas par le premier
				* calcul du point d'intersection
				* calcul de la pente
	move.w d6,d0
	sub.w d4,d0		* r‚sultat positif car d6>d4 !
	move.w d5,d1
	sub.w d7,d1
	beq clip_droit_bis_horizontal	* segment horizontal
	swap d1
	clr.w d1
	ext.l d0
	divs.l d0,d1
				* calcul de dx
	sub.w #max_x,d6
	ext.l d6
				* calcul du dy … ajouter
	muls.l d6,d1
	swap d1
	add.w d1,d7

clip_droit_bis_horizontal		* segment horizontal,
				* donc intersection facile … calculer
	move.w #max_x,d6
clip_haut
				* comparaison avec le bord haut de la fenˆtre
				* pour savoir si les extr‚mit‚s sont … l'int‚rieur
	cmp.w #min_y,d5
	bgt clip_haut_bis
				* le bord gauche est coup‚ par le 1er point
	cmp.w #min_y,d7
	blt pas_visible
				* mais par un seul point
				* calcul du point d'intersection
				* calcul de la pente
	move.w d7,d0
	sub.w d5,d0		* r‚sultat positif car d7>d5 !
	move.w d6,d1
	sub.w d4,d1
	beq clip_haut_vertical	* segment vertical
	swap d1
	clr.w d1
	ext.l d0
	divs.l d0,d1
				* calcul de dy
	sub.w #min_y,d5
	neg.w d5
	ext.l d5
				* calcul du dx … ajouter
	muls.l d5,d1
	swap d1
	add.w d1,d4

clip_haut_vertical			* segment vertical,
				* donc intersection facile … calculer
	move.w #min_y,d5
	bra clip_bas
clip_haut_bis
	cmp.w #min_y,d7
	bgt clip_bas
				* le bord haut est coup‚ par le second point,
				* mais pas par le premier
				* calcul du point d'intersection
				* calcul de la pente
	move.w d5,d0
	sub.w d7,d0		* r‚sultat positif car d4>d6 !
	move.w d4,d1
	sub.w d6,d1
	beq clip_haut_bis_vertical	* segment vertical
	swap d1
	clr.w d1
	ext.l d0
	divs.l d0,d1
				* calcul de dy
	sub.w #min_y,d7
	neg.w d7
	ext.l d7
				* calcul du dx … ajouter
	muls.l d7,d1
	swap d1
	add.w d1,d6

clip_haut_bis_vertical		* segment vertical,
				* donc intersection facile … calculer
	move.w #min_y,d7
clip_bas
				* comparaison avec le bord bas de la fenˆtre
				* pour savoir si les extr‚mit‚s sont … l'int‚rieur
	cmp.w #max_y,d5
	blt clip_bas_bis
				* le bord bas est coup‚ par le 1er point
	cmp.w #max_y,d7
	bgt pas_visible
				* mais par un seul point
				* calcul du point d'intersection
				* calcul de la pente
	move.w d5,d0
	sub.w d7,d0		* r‚sultat positif car d5>d7 !
	move.w d6,d1
	sub.w d4,d1
	beq clip_bas_vertical		* segment vertical
	swap d1
	clr.w d1
	ext.l d0
	divs.l d0,d1
				* calcul de dy
	sub.w #max_y,d5
	ext.l d5
				* calcul du dx … ajouter
	muls.l d5,d1
	swap d1
	add.w d1,d4

clip_bas_vertical			* segment vertical,
				* donc intersection facile … calculer
	move.w #max_y,d5
	bra clip_fin
clip_bas_bis
	cmp.w #max_y,d7
	blt clip_fin
				* le bord bas est coup‚ par le second point,
				* mais pas par le premier
				* calcul du point d'intersection
				* calcul de la pente
	move.w d7,d0
	sub.w d5,d0		* r‚sultat positif car d7>d5 !
	move.w d4,d1
	sub.w d6,d1
	beq clip_bas_bis_vertical	* segment vertical
	swap d1
	clr.w d1
	ext.l d0
	divs.l d0,d1
				* calcul de dy
	sub.w #max_y,d7
	ext.l d7
				* calcul du dx … ajouter
	muls.l d7,d1
	swap d1
	add.w d1,d6

clip_bas_bis_vertical			* segment vertical,
				* donc intersection facile … calculer
	move.w #max_y,d7
clip_fin
	move.w d4,d0
	move.w d5,d1
	move.w d6,d2
	move.w d7,d3
	move.l #$F0F0F0F0,d4
	bsr ligne
pas_visible
	rts

* routine de ligne en 65536 couleurs
* recoit en D0 : X, D1 : Y : de d‚part
*           D2 : X, D3 : Y : d'arriv‚e
* D4 : couleur sur 32 bits !!
* modifie D0-D7, A0
ligne
	move.l #ecran_largeur*2,d7	* stockage de yinc
	move.w d2,d5		* calcul de dx dans D5
	sub.w d0,d5
	beq rout5	
	bpl xpasneg1		* si dx est nul, ligne verticale !!
				* si dx negatif, donc d2<d0
				* donc le premier point devient d2,d3
	neg.w d5
	exg.l d2,d0
	exg.l d3,d1
xpasneg1
				* on trace toujours vers les x croissants
				* calcul de dy
	move.w d3,d6
	sub.w d1,d6
	beq rout4			
				* dy est nul, ligne horizontal	
	bpl ypasneg1
				* dy n‚gatif, donc d4<d1
	neg.w d6
				* trac‚ en montant vers la droite
				* donc d7=-ecran_largeur*2
	neg.l d7
ypasneg1
	cmp.w d5,d6
				* comparaison dx et dy
	bmi rout2			* <0
	beq rout3			* =0 : une diagonale !!!

				* … la fin : d5 : dx
				*            d6 : dy
	* routine 1
	* ici dx>0, dy>0 et dy>dx
	* a pus besoin de d2, d3, et dx aprŠs division
rout1
				* si dx = 1 : 2 pixels de large !!
				* donc il faut rajouter 1 … chaque d
	addq.w #1,d5
	addq.w #1,d6
				* d‚calage de 16 bits pour la division
	swap d5
	clr.w d5
	divu.w d6,d5		
				* division de dx par dy + division par 16 bits
				* d5 contient la pente : r‚sultat sur 16 bits
				* boucle sur d6
	subq.w #1,d6
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* somme = 0
	moveq.l #0,d3	
				* rappels des valeur des regsitres a ce point : 
				* d0 : 
				* d1 : 
				* d2 : 
				* d3 : somme
				* d4 : couleur
				* d5 : pente
				* d6 : delta y
				* d7 : offset pour changement de ligne 
ligneb1
	add.w d5,d3
	bcs lignenx1
				* pas de d‚placement suivant x
	move.w d4,(a0)
	adda.l d7,a0
	dbra d6,ligneb1
	rts
lignenx1
	move.w d4,(a0)+
	adda.l d7,a0
	dbra d6,ligneb1
	rts

	* routine 2
	* ici dx>0, dy>0 et dy<dx
	* a pus besoin de d2, d3, et dy aprŠs division
rout2
				* correction de d
	addq.w #1,d5
	addq.w #1,d6
				* d‚calage de 16 bits
	swap d6
	clr.w d6
	divu.w d5,d6
				* division de dy par dx + division par 16 bits
				* d6 contient la pente : r‚sultat sur 16 bits
				* boucle sur d5
	subq.w #1,d5
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* somme = 0
	moveq.l #0,d3
				* d0 : 
				* d1 : 
				* d2 : 
				* d3 : somme
				* d4 : couleur
				* d5 : delta x
				* d6 : pente
				* d7 : offset pour changement de ligne et de pixel
ligneb2
	move.w d4,(a0)+
	add.w d6,d3
	bcc ligneny2			
				* pas de d‚placement suivant y 
	adda.l d7,a0
ligneny2
	dbra d5,ligneb2
	rts

	* ici dx>0, dy>0 et dx=dy
	* une diagonale!!
rout3
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* division par 2 de d5
	lsr.w #1,d5
	bcc ligneb3
				* si retenue alors nombre impair
	move.w d4,(a0)+
	adda.l d7,a0
				* ce qui permet d'afficher 2 points par 2 points
ligneb3
	move.w d4,(a0)+
	adda.l d7,a0
	move.w d4,(a0)+
	adda.l d7,a0
	dbra d5,ligneb3
	rts

	* ici dy est nul
	* et dx positif
	* ligne horizontale
rout4
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* division de d5 par 2
	lsr.w #1,d5
	bcc ligneb4
				* d5 : nombre impaire
	move.w d4,(a0)+
ligneb4
	move.l d4,(a0)+		* 2 pixels d'un coup !
	dbra d5,ligneb4
	rts

	* ici dx est nul
	* et dy est inconnu
	* ligne verticale
rout5
	move.w d3,d6
	sub.w d1,d6
	bmi rout5_yneg
	beq rout6
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* division par 2 de d6
	lsr.w #1,d6
	bcc ligneb5
				* d6 : nombre impaire
	move.w d4,(a0)
	adda.l d7,a0
ligneb5
	move.w d4,(a0)
	adda.l d7,a0
	move.w d4,(a0)
	adda.l d7,a0
	dbra d6,ligneb5
	rts
rout5_yneg
	neg.w d6
	neg.l d7
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
				* division par deux de d6
	lsr.w #1,d6
	bcc ligneb5_yneg
				* d6 : nombre impair
	move.w d4,(a0)
	adda.l d7,a1
ligneb5_yneg
	move.w d4,(a0)
	adda.l d7,a0
	move.w d4,(a0)
	adda.l d7,a0
	dbra d6,ligneb5_yneg
	rts

	* deltax est nul
	* deltay est nul
	* c'est un point
	* OK
rout6
				* calcul d'adresse du 1er point dans a0
	movea.l adr_ecran,a0
	add.w d0,d0
	adda.w d0,a0
	mulu.w #ecran_largeur*2,d1
	adda.l d1,a0
	move.w d4,(a0)
	rts

	include "principh.s"

	section BSS
compteur	ds.w 1

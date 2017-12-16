* routine de tracer de polygone en 320*200 True color
* non connexe, trou‚, non convexe, avec contour auto intersectant
* algorithme de tracer de polygone de Lucas
* algorithme de tracer de ligne : interpolation
* par Golio Junior

* D‚finition de l'image
Video_mode		equ %000100100	* 40 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 320*200*2/4
ecran_largeur	equ 320
ecran_hauteur	equ 200
Pas_Fond		equ 0

	include "principa.s"

* routine d'initialisation
prg_init
	rts

* routine appele a chaque vbl
prg
			* effacement de l'ecran
	move.l	adr_ecran,a0
	move.w	#ecran_largeur*ecran_hauteur/4-1,d0
	moveq.l	#-1,d1		* couleur de remplissage
prg_cls_b1
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,prg_cls_b1

	lea	ecran_tra,a0
	move.w	#ecran_largeur*ecran_hauteur/8-1,d0
	moveq.l	#0,d1		* couleur de remplissage
prg_cls_b2
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra d0,prg_cls_b2
	
			* sauter les aretes horizontales
	lea polygone,a0	* pointeur LP
	lea (a0,4),a1	* pointeur L
saute_horizon
	move.w (a0,2),d0
	cmp.w (a1,2),d0
	bne saute_horizon_fin
	movea.l a1,a0
	addq.l #4,a1
	bra saute_horizon
saute_horizon_fin

	smi.b d7		* UPL
	move.l a1,a0	* LP = L
			* parcour du contour de la tache
parcours
	lea	(a1,4),a2	* A2 : M sommet suivant
	move.w	(a1,2),d0	* comparaison des y
	cmp.w	(a2,2),d0
	bne	pas_horizontal
	move.w	(a1),d0	* ligne horizontal, sens de d‚placement
	sub.w	(a2),d0
	bpl	horizontal_pas_pos
horizontal_pas_neg
			* nombre de point … afficher
	neg.w	d0
	subq.w	#1,d0
			* calcul de la position du 1er point
	move.w	(a1,2),d1
	mulu.w	#ecran_largeur,d1
	add.w	(a1),d1	* attention … la r‚solution!
	lea	ecran_tra,a6
	adda.w	d1,a6
			* en route Simone!
horizontal_pas_neg_b1
	move.b	#2,(a6)+
	dbra	d0,horizontal_pas_neg_b1

	bra	sommet_suivant
horizontal_pas_pos
			* nombre de point … afficher
	subq.w	#1,d0
			* calcul de la position du 1er point
	move.w	(a2,2),d1
	mulu.w	#ecran_largeur,d1
	add.w	(a2),d1	* attention … la r‚solution!
	lea	ecran_tra,a6
	adda.l	d1,a6
			* en route Simone!
horizontal_pas_pos_b1
	move.b #2,(a6)+
	dbra d0,horizontal_pas_pos_b1

	bra sommet_suivant
pas_horizontal
	smi.b d6		* fixe UPM
	cmp.b d6,d7
	sne.b d5		* fixe pointe
	bsr segment
	move.w d6,d7
sommet_suivant
	addq.l	#4,a1
	cmpa.l	#fin_poly,a1
	bne	sommet_suivant_s1
	lea	polygone,a1
sommet_suivant_s1
	cmpa.l	a0,a1
	bne	parcours
parcours_fin

			* affichage brutal du polygone
	move.w	#ecran_hauteur-1,d1	* y
	move.l	adr_ecran,a0
	lea	ecran_tra,a1
affiche_by
	move.w	#ecran_largeur-1,d2	* x
	clr.b	d0	* flag interieur
affiche_bx
	move.b	(a1)+,d6
	cmp.b	#1,d6
	bne	affiche_bx_s1
	not.b	d0
affiche_bx_s2
	move.w	#0,(a0)+
	dbra	d2,affiche_bx
	dbra	d1,affiche_by
	rts
affiche_bx_s1
	tst.b	d0
	bne	affiche_bx_s2
	cmp.b	#2,d6
	beq	affiche_bx_s2
	addq.l	#2,a0
	dbra	d2,affiche_bx
	dbra	d1,affiche_by
	rts
	
segment
* routine de segment pour l'algorithme de tracer de polygone
* recoit en a1 : coordonn‚es du point de d‚part
*           a2 : coordonn‚es du point d'arriv‚e
*           d5 : flag indiquant une pointe
*           A0/D6/D7 : r‚serv‚

			* calcul d'adresse du 1er point dans a3
	lea 	ecran_tra,a3
	adda.w	(a1),a3
	move.w	(a1,2),d4
	mulu.w	#ecran_largeur,d4
	adda.l	d4,a3
	tst.b	d5
	beq	segment_s1
			* une pointe
	cmp.b	#1,(a3)
	beq	segment_s2
	move.b	#2,(a3)
	bra	segment_s2
segment_s1
			* pas une pointe
	cmp.b	#1,(a3)
	bne	segment_s4
	move.b	#2,(a3)
	bra	segment_s2
segment_s4
	move.b	#1,(a3)
segment_s2

	move.l #ecran_largeur,d0	* stockage de yinc
	move.l #1,d1	* stockage de xinc
			* calcul de dx dans D2
	move.w (a2),d2
	sub.w (a1),d2
	beq rout5
			* si dx est nul, ligne verticale !!
	bpl xpasneg1			
			* si dx negatif
	neg.w d2		* alors inversion de dx
	neg.l d1		* changement de l'incr‚ment en x
xpasneg1
			* calcul de dy dans d3
	move.w (a2,2),d3
	sub.w (a1,2),d3
*	beq rout4		* dy est nul, ligne horizontal	
			* ce cas ne doit jamais se produire !
	bpl ypasneg1	* dy n‚gatif

	neg.w d3
	neg.l d0
ypasneg1
	cmp.w d2,d3	* comparaison dx et dy
	bmi rout2    	* <0
	beq rout3    	* =0 : une diagonale !!!

* … la fin : d2 : dx
*            d3 : dy
* routine 1
* ici dx>0, dy>0 et dy>dx
* a pus besoin de d4 et dx aprŠs division
rout1
			* si dx = 1 : 2 pixels de large !!
			* donc il faut rajouter 1 … chaque d
	addq.w #1,d2
	addq.w #1,d3
			* d‚calage de 16 bits pour la division
	swap d2
	clr.w	d2
	divu.w	d3,d2		
			* division de dx par dy + division par 16 bits
			* d2 contient la pente : r‚sultat sur 16 bits
			* boucle sur d3
	subq.w	#3,d3

	move.w 	d2,d4	* somme = 0+pente : pr‚voir pour le premier
			* point
	adda.l	d0,a3	* point suivant!
	add.l	d0,d1
			* d0 : offset pour changement en y
			* d1 : offset pour changement en x et y
			* d2 : pente
			* d3 : delta y
			* d4 : somme
			* d5 : 
			* d6 : r‚serv‚
			* d7 : r‚serv‚
ligneb1
	add.w	d2,d4
	bcs	lignenx1
			* pas de d‚placement suivant x
	cmp.b	#1,(a3)
	bne	ligneb1_s1
	move.b	#2,(a3)
	adda.l	d0,a3
	dbra	d3,ligneb1
	rts
ligneb1_s1
	move.b	#1,(a3)
	adda.l	d0,a3
	dbra	d3,ligneb1
	rts
lignenx1
	cmp.b	#1,(a3)
	bne	lignenx1_s1
	move.b	#2,(a3)
	adda.l	d1,a3
	dbra	d3,ligneb1
	rts
lignenx1_s1
	move.b	#1,(a3)
	adda.l	d1,a3
	dbra	d3,ligneb1
	rts

* routine 2
* ici dx>0, dy>0 et dy<dx
* a pus besoin de d2, d3, et dy aprŠs division
rout2
			* correction de d
	addq.w	#1,d2
	addq.w	#1,d3
			* d‚calage de 16 bits
	swap	d3
	clr.w	d3
	divu.w	d2,d3	* division de dy par dx + division par 16 bits
			* d3 contient la pente : r‚sultat sur 16 bits
			* boucle sur d2
	subq.w	#3,d2

	move.w	d3,d4
	adda.l	d1,a3
	add.l	d1,d0
			* d0 : increment en y+x
			* d1 : increment en x
			* d2 : dx
			* d3 : pente
			* d4 : accu
			* d5 : 
			* d6 : r‚serv‚
			* d7 : r‚serv‚
ligneb2
	add.w	d3,d4
	bcc	ligneny2
			* d‚placement suivant y 
	adda.l	d0,a3
	cmp.b	#1,(a3)
	bne	ligneb2_s1
	move.b	#2,(a3)
	dbra	d2,ligneb2
	rts
ligneb2_s1
	move.b	#1,(a3)
	dbra	d2,ligneb2
	rts

ligneny2			* y constant
	adda.l	d1,a3
	cmp.b	#1,(a3)
	bne	ligneny2_s1
	move.b	#2,(a3)
	dbra	d2,ligneb2
	rts
ligneny2_s1
	move.b	#1,(a3)
	dbra	d2,ligneb2
	rts

* ici dx>0, dy>0 et dx=dy
* une diagonale!!
* OK
rout3
	add.l	d0,d1	* incr‚ment
	subq.w	#2,d2
	adda.l	d1,a3
ligneb3
	cmp.b	#1,(a3)
	bne	ligneb3_s1
	move.b	#2,(a3)
	adda.l	d1,a3
	dbra	d2,ligneb3
	rts
ligneb3_s1
	move.b	#1,(a3)
	adda.l	d1,a3
	dbra	d2,ligneb3
	rts
	
* ici dy est nul
* et dx positif
* ligne horizontale
* ce cas ne se produit jamais, donc pas de code
rout4
	rts

* ici dx est nul
* et dy est inconnu
* ligne verticale
* OK
rout5
	move.w	(a2,2),d3
	sub.w	(a1,2),d3
	bpl	rout5_pos
	beq	rout6

	neg.l	d0
	neg.w	d3
rout5_pos
	subq.w	#2,d3
	adda.l	d0,a3
ligneb5
	cmp.b	#1,(a3)
	bne	ligneb5_s1
	move.b	#2,(a3)
	adda.l	d0,a3
	dbra	d3,ligneb5
	rts
ligneb5_s1
	move.b	#1,(a3)
	adda.l	d0,a3
	dbra	d3,ligneb5
	rts

* deltax est nul
* deltay est nul
* c'est un point qui est d‚ja trait‚!
rout6
	rts

	section data
polygone	dc.w 99,72
	dc.w 113,72
	dc.w 122,91
	dc.w 134,72
	dc.w 137,72
	dc.w 123,95
	dc.w 139,126
	dc.w 126,126
	dc.w 116,106
	dc.w 103,126
	dc.w 100,126
	dc.w 114,103
fin_poly	dc.w 99,72

	section bss
ecran_tra	ds.b ecran_largeur*ecran_hauteur	* zone de travail

	include "principh.s"
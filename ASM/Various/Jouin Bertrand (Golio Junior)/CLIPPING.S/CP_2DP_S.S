* fenˆtrage de polygone r‚entrant
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

			* d‚finition du polygone
nbre_cote	equ 4
couleur	equ $f0f0		* couleur

			* struture definissant une arete
	rsreset
dep_x	rs.w 1
dep_y	rs.w 1
arr_x	rs.w 1
arr_y	rs.w 1
aretes	equ __rs

			* struture definissant une intersection d'arete
	rsreset
coor_x	rs.w 1
pente	rs.l 1
accu	rs.w 1
hauteur	rs.w 1
aretes_inter	equ __rs


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

	rts

prg
	lea polygone,a0
	lea resultat1,a1
	move.w #nbre_cote-1,d0
	bsr clip_gauche
	lea resultat1,a0
	lea resultat2,a1
	move.w d1,d0
	bsr clip_droit
	lea resultat2,a0
	lea resultat1,a1
	move.w d1,d0
	bsr clip_haut
	lea resultat1,a0
	lea resultat2,a1
	move.w d1,d0
	bsr clip_bas
	lea resultat2,a0
	move.w d1,d7
	bsr trace_polygone
	rts
			* routines de clipping : 
			* entr‚e : d0 : Nbre de cot‚ du polygone
			*          a0 : liste des points du polygone
			* sortie : a1 : liste des points du polygone clipp‚
			*          d1 : Nbre de cot‚ du polygone clipp‚
			* clipping sur le bord gauche de la fenˆtre
clip_gauche
	move.l a1,a2
			* initialisation du nombre de cot‚ du polygone clipp‚
	move.w #-1,d1
			* traitement du cas particulier du 1er point
	move.w (a0,dep_x),d4
	move.w (a0,dep_y),d5
	cmp.w #min_x,d4
	blt clip_gauche_1pt	* test de visibilit‚
			* il est visible, il faut donc l'ajouter
	move.w d4,(a1)+
	move.w d5,(a1)+
			* sinon, l'ajout se fera ult‚rieurement
clip_gauche_1pt
clip_gauche_b1
	move.w (a0,dep_x),d4
	move.w (a0,dep_y),d5
	move.w (a0,arr_x),d6
	move.w (a0,arr_y),d7
				* comparaison avec le bord gauche de la fenˆtre
				* test pour savoir si les extr‚mit‚s sont … l'int‚rieur
	cmp.w #min_x,d4
	bgt clip_gauche_bis
				* le bord gauche est coup‚ par le 1er point
	cmp.w #min_x,d6
	blt clip_gauche_pas_visible
				* mais par un seul point
				* on va de la partie invisible vers la partie visible
				* donc ajout de 2 points (2 arˆtes)
				* calcul du point d'intersection
				* calcul de la pente
	move.w d4,d2
	sub.w d6,d2		* r‚sultat positif car d6>d4 !
	move.w d7,d3
	sub.w d5,d3
	beq clip_gauche_horizontal	* segment horizontal
	swap d3
	clr.w d3
	ext.l d2
	divs.l d2,d3
				* calcul de dx
	sub.w #min_x,d4
	ext.l d4
				* calcul du dy … ajouter
	muls.l d4,d3
	swap d3
	add.w d3,d5

clip_gauche_horizontal		* segment horizontal,
				* donc intersection facile … calculer
	move.w #min_x,d4
				* ajout des points dans la liste
	move.w d4,(a1)+
	move.w d5,(a1)+
	move.w d6,(a1)+
	move.w d7,(a1)+
	addq.w #2,d1		* 2 arˆtes supl‚mentaires
	bra clip_gauche_s2
clip_gauche_bis
	cmp.w #min_x,d6
	bgt clip_gauche_s1
				* le bord gauche est coup‚ par le second point,
				* mais pas par le premier
				* donc on va de la partie visible
				* vers la partie invisible
				* donc on ajoute 1 arˆte (le dernier point est significatif)
				* calcul du point d'intersection
				* calcul de la pente
	move.w d4,d2
	sub.w d6,d2		* r‚sultat positif car d4>d6 !
	move.w d5,d3
	sub.w d7,d3
	beq clip_gauche_bis_horizontal	* segment horizontal
	swap d3
	clr.w d3
	ext.l d2
	divs.l d2,d3
				* calcul de dx
	sub.w #min_x,d6
	neg.w d6
	ext.l d6
				* calcul du dy … ajouter
	muls.l d6,d3
	swap d3
	add.w d3,d7

clip_gauche_bis_horizontal		* segment horizontal,
				* donc intersection facile … calculer
	move.w #min_x,d6
				* sauvegarde du dernier point calcul‚
	move.w d6,(a1)+
	move.w d7,(a1)+
	addq.w #1,d1		* une arˆte de plus
	bra clip_gauche_s2
clip_gauche_s1
				* arˆte entiŠrement visible
				* on ajoute le dernier point
	addq.w #1,d1
				* sauvegarde des coordonn‚es clipp‚es
	move.w d6,(a1)+
	move.w d7,(a1)+
clip_gauche_s2
				* passage aux coordonn‚es suivantes
clip_gauche_pas_visible
	adda.l #4,a0
	dbra d0,clip_gauche_b1
				* traitement du dernier point
				* recopie du 1er !
	move.l (a2),(a1)
	rts

			* clipping sur le bord droit de la fenˆtre
clip_droit
	move.l a1,a2
			* initialisation du nombre de cot‚ du polygone clipp‚
	move.w #-1,d1
			* traitement du cas particulier du 1er point
	move.w (a0,dep_x),d4
	move.w (a0,dep_y),d5
	cmp.w #max_x,d4
	bgt clip_droit_1pt	* test de visibilit‚
			* il est visible, il faut donc l'ajouter
	move.w d4,(a1)+
	move.w d5,(a1)+
			* sinon, l'ajout se fera ult‚rieurement
clip_droit_1pt
clip_droit_b1
	move.w (a0,dep_x),d4
	move.w (a0,dep_y),d5
	move.w (a0,arr_x),d6
	move.w (a0,arr_y),d7
				* comparaison avec le bord droit de la fenˆtre
				* test pour savoir si les extr‚mit‚s sont … l'int‚rieur
	cmp.w #max_x,d4
	blt clip_droit_bis
				* le bord droit est coup‚ par le 1er point
	cmp.w #max_x,d6
	bgt clip_droit_pas_visible
				* mais par un seul point
				* on va de la partie invisible vers la partie visible
				* donc ajout de 2 points (2 arˆtes)
				* calcul du point d'intersection
				* calcul de la pente
	move.w d6,d2
	sub.w d4,d2		* r‚sultat positif car d4>d6 !
	move.w d7,d3
	sub.w d5,d3
	beq clip_droit_horizontal	* segment horizontal
	swap d3
	clr.w d3
	ext.l d2
	divs.l d2,d3
				* calcul de dx
	sub.w #max_x,d4
	neg.w d4
	ext.l d4
				* calcul du dy … ajouter
	muls.l d4,d3
	swap d3
	add.w d3,d5

clip_droit_horizontal			* segment horizontal,
				* donc intersection facile … calculer
	move.w #max_x,d4
				* ajout des points dans la liste
	move.w d4,(a1)+
	move.w d5,(a1)+
	move.w d6,(a1)+
	move.w d7,(a1)+
	addq.w #2,d1		* 2 arˆtes supl‚mentaires
	bra clip_droit_s2
clip_droit_bis
	cmp.w #max_x,d6
	blt clip_droit_s1
				* le bord droit est coup‚ par le second point,
				* mais pas par le premier
				* donc on va de la partie visible
				* vers la partie invisible
				* donc on ajoute 1 arˆte (le dernier point est significatif)
				* calcul du point d'intersection
				* calcul de la pente
	move.w d6,d2
	sub.w d4,d2		* r‚sultat positif car d6>d4 !
	move.w d5,d3
	sub.w d7,d3
	beq clip_droit_bis_horizontal	* segment horizontal
	swap d3
	clr.w d3
	ext.l d2
	divs.l d2,d3
				* calcul de dx
	sub.w #max_x,d6
	ext.l d6
				* calcul du dy … ajouter
	muls.l d6,d3
	swap d3
	add.w d3,d7

clip_droit_bis_horizontal		* segment horizontal,
				* donc intersection facile … calculer
	move.w #max_x,d6
				* sauvegarde du dernier point calcul‚
	move.w d6,(a1)+
	move.w d7,(a1)+
	addq.w #1,d1		* une arˆte de plus
	bra clip_droit_s2
clip_droit_s1
				* arˆte entiŠrement visible
				* on ajoute le dernier point
	addq.w #1,d1
				* sauvegarde des coordonn‚es clipp‚es
	move.w d6,(a1)+
	move.w d7,(a1)+
clip_droit_s2
				* passage aux coordonn‚es suivantes
clip_droit_pas_visible
	adda.l #4,a0
	dbra d0,clip_droit_b1
				* traitement du dernier point
				* recopie du 1er !
	move.l (a2),(a1)
	rts
			* clipping sur le bord haut de la fenˆtre
clip_haut	
	move.l a1,a2
			* initialisation du nombre de cot‚ du polygone clipp‚
	move.w #-1,d1
			* traitement du cas particulier du 1er point
	move.w (a0,dep_x),d4
	move.w (a0,dep_y),d5
	cmp.w #min_y,d5
	blt clip_haut_1pt	* test de visibilit‚
			* il est visible, il faut donc l'ajouter
	move.w d4,(a1)+
	move.w d5,(a1)+
			* sinon, l'ajout se fera ult‚rieurement
clip_haut_1pt
clip_haut_b1
	move.w (a0,dep_x),d4
	move.w (a0,dep_y),d5
	move.w (a0,arr_x),d6
	move.w (a0,arr_y),d7
				* comparaison avec le bord haut de la fenˆtre
				* test pour savoir si les extr‚mit‚s sont … l'int‚rieur
	cmp.w #min_y,d5
	bgt clip_haut_bis
				* le bord haut est coup‚ par le 1er point
	cmp.w #min_y,d7
	blt clip_haut_pas_visible
				* mais par un seul point
				* on va de la partie invisible vers la partie visible
				* donc ajout de 2 points (2 arˆtes)
				* calcul du point d'intersection
				* calcul de la pente
	move.w d5,d2
	sub.w d7,d2		* r‚sultat positif car d7>d5 !
	move.w d6,d3
	sub.w d4,d3
	beq clip_haut_vertical	* segment vertical
	swap d3
	clr.w d3
	ext.l d2
	divs.l d2,d3
				* calcul de dy
	sub.w #min_y,d5
	ext.l d5
				* calcul du dx … ajouter
	muls.l d5,d3
	swap d3
	add.w d3,d4

clip_haut_vertical			* segment vertical,
				* donc intersection facile … calculer
	move.w #min_y,d5
				* ajout des points dans la liste
	move.w d4,(a1)+
	move.w d5,(a1)+
	move.w d6,(a1)+
	move.w d7,(a1)+
	addq.w #2,d1		* 2 arˆtes supl‚mentaires
	bra clip_haut_s2
clip_haut_bis
	cmp.w #min_y,d7
	bgt clip_haut_s1
				* le bord haut est coup‚ par le second point,
				* mais pas par le premier
				* donc on va de la partie visible
				* vers la partie invisible
				* donc on ajoute 1 arˆte (le dernier point est significatif)
				* calcul du point d'intersection
				* calcul de la pente
	move.w d5,d2
	sub.w d7,d2		* r‚sultat positif car d5>d7 !
	move.w d4,d3
	sub.w d6,d3
	beq clip_haut_bis_vertical	* segment vertical
	swap d3
	clr.w d3
	ext.l d2
	divs.l d2,d3
				* calcul de dy
	sub.w #min_y,d7
	neg.w d7
	ext.l d7
				* calcul du dx … ajouter
	muls.l d7,d3
	swap d3
	add.w d3,d6

clip_haut_bis_vertical		* segment vertical,
				* donc intersection facile … calculer
	move.w #min_y,d7
				* sauvegarde du dernier point calcul‚
	move.w d6,(a1)+
	move.w d7,(a1)+
	addq.w #1,d1		* une arˆte de plus
	bra clip_haut_s2
clip_haut_s1
				* arˆte entiŠrement visible
				* on ajoute le dernier point
	addq.w #1,d1
				* sauvegarde des coordonn‚es clipp‚es
	move.w d6,(a1)+
	move.w d7,(a1)+
clip_haut_s2
				* passage aux coordonn‚es suivantes
clip_haut_pas_visible
	adda.l #4,a0
	dbra d0,clip_haut_b1
				* traitement du dernier point
				* recopie du 1er !
	move.l (a2),(a1)
	rts

			* clipping sur le bord bas de la fenˆtre
clip_bas
	move.l a1,a2
			* initialisation du nombre de cot‚ du polygone clipp‚
	move.w #-1,d1
			* traitement du cas particulier du 1er point
	move.w (a0,dep_x),d4
	move.w (a0,dep_y),d5
	cmp.w #max_y,d5
	bgt clip_bas_1pt	* test de visibilit‚
			* il est visible, il faut donc l'ajouter
	move.w d4,(a1)+
	move.w d5,(a1)+
			* sinon, l'ajout se fera ult‚rieurement
clip_bas_1pt
clip_bas_b1
	move.w (a0,dep_x),d4
	move.w (a0,dep_y),d5
	move.w (a0,arr_x),d6
	move.w (a0,arr_y),d7
				* comparaison avec le bord bas de la fenˆtre
				* test pour savoir si les extr‚mit‚s sont … l'int‚rieur
	cmp.w #max_y,d5
	blt clip_bas_bis
				* le bord bas est coup‚ par le 1er point
	cmp.w #max_y,d7
	bgt clip_bas_pas_visible
				* mais par un seul point
				* on va de la partie invisible vers la partie visible
				* donc ajout de 2 points (2 arˆtes)
				* calcul du point d'intersection
				* calcul de la pente
	move.w d7,d2
	sub.w d5,d2		* r‚sultat positif car d5>d7 !
	move.w d6,d3
	sub.w d4,d3
	beq clip_bas_vertical		* segment vertical
	swap d3
	clr.w d3
	ext.l d2
	divs.l d2,d3
				* calcul de dy
	sub.w #max_y,d5
	neg.w d5
	ext.l d5
				* calcul du dx … ajouter
	muls.l d5,d3
	swap d3
	add.w d3,d4

clip_bas_vertical			* segment vertical,
				* donc intersection facile … calculer
	move.w #max_y,d5
				* ajout des points dans la liste
	move.w d4,(a1)+
	move.w d5,(a1)+
	move.w d6,(a1)+
	move.w d7,(a1)+
	addq.w #2,d1		* 2 arˆtes supl‚mentaires
	bra clip_bas_s2
clip_bas_bis
	cmp.w #max_y,d7
	blt clip_bas_s1
				* le bord bas est coup‚ par le second point,
				* mais pas par le premier
				* donc on va de la partie visible
				* vers la partie invisible
				* donc on ajoute 1 arˆte (le dernier point est significatif)
				* calcul du point d'intersection
				* calcul de la pente
	move.w d7,d2
	sub.w d5,d2		* r‚sultat positif car d7>d5 !
	move.w d4,d3
	sub.w d6,d3
	beq clip_bas_bis_vertical	* segment vertical
	swap d3
	clr.w d3
	ext.l d2
	divs.l d2,d3
				* calcul de dy
	sub.w #max_y,d7
	ext.l d7
				* calcul du dx … ajouter
	muls.l d7,d3
	swap d3
	add.w d3,d6

clip_bas_bis_vertical			* segment vertical,
				* donc intersection facile … calculer
	move.w #max_y,d7
				* sauvegarde du dernier point calcul‚
	move.w d6,(a1)+
	move.w d7,(a1)+
	addq.w #1,d1		* une arˆte de plus
	bra clip_bas_s2
clip_bas_s1
				* arˆte entiŠrement visible
				* on ajoute le dernier point
	addq.w #1,d1
				* sauvegarde des coordonn‚es clipp‚es
	move.w d6,(a1)+
	move.w d7,(a1)+
clip_bas_s2
				* passage aux coordonn‚es suivantes
clip_bas_pas_visible
	adda.l #4,a0
	dbra d0,clip_bas_b1
				* traitement du dernier point
				* recopie du 1er !
	move.l (a2),(a1)
	rts


trace_polygone
			* entr‚e :
			* a0 : liste des points constituant le polygone
			* d7 : Nbre de cot‚ -1

			* sauter les aretes horizontales
			* orienter les aretes
			* ordonner les aretes
	lea aretes_triees,a2	* pointeur sur la fin de la liste des aretes triees
	move.w #-1,(a2,dep_y)	* initialisation des aretes triees
	move.w #-1,liste_aretes+coor_x	* initialisation de la liste des aretes coup‚e
constitution
			* on recupere les coordonnees de l'arete
	move.l (a0)+,d0	* coordonn‚es sur mot long : X : 16 de poid fort
	move.l (a0),d1	*                            Y : 16 de poid faible
	cmp.w d1,d0
	beq arete_horizontal
	bmi arete_positive
	exg.l d0,d1	* ici l'arete est mal orientee
			* elle monte!
arete_positive
			* recherche de la bonne place
			* tri par insertion dans l'ordre croissant
	lea aretes_triees,a1
arete_suivante
	cmp.w (a1,dep_y),d0
	bmi bonne_place	* bonne place? si oui, alors bonne_place
	addq.l #aretes,a1	* place suivante
	cmpa.l a1,a2	* sort-on de la liste des aretes?
	bgt arete_suivante	* non alors on continue
	move.l d0,(a2)+	* on arrive … la fin de la liste
	move.l d1,(a2)+	* donc on insere l'arete … la fin
	bra arete_horizontal
bonne_place
			* c'est le bon endroit
			* il faut se faire un peut de place
	movea.l a2,a3	* pour se faire un peut de place
	subq.l #aretes,a1	* on va copier l'arete courante dans la place suivante
decalage	move.l (a3),(a3,aretes)	* donc on commence par la fin
	move.l (a3,arr_x),(a3,aretes+arr_x)
	subq.l #aretes,a3
	cmpa.l a3,a1
	blt decalage	* fin du decalage? non alors decalage!
	addq.l #aretes,a2	* nouvelle fin de table
	addq.l #aretes,a1
	move.l d0,(a1)+	* on place l'arete dans la place que l'on
	move.l d1,(a1)+	* vient de faire
arete_horizontal
	dbra d7,constitution	* on continue … constituer la liste des
			* arˆtes

			* a la fin, nous avons :
			* a2 contient l'adresse de la fin de table

			* ici on commence … tracer le polygone
			* 1ere ligne = 1 arete
	lea aretes_triees,a0	* liste des aretes
	move.w (a0,dep_y),d0	* y courant : on commence par le y de la 1ere arete
	move.w d0,d1
	mulu.w #ecran_largeur*2,d1
	movea.l adr_ecran,a1	* a1 pointe sur la ligne ecran courante
	adda.l d1,a1	* adresse de la 1ere ligne
	lea liste_aretes,a3	* fin de la liste d'aretes deja traitee
	clr.w d7		* d7 indique qu'il y a encore des aretes dans
			* la liste des aretes triees
ajout_arete
			* ajout a la liste les aretes qui sont
			* concernees par cette ligne
	cmp.w (a0,dep_y),d0
	bne plus_d_arete
			* calcul des diff‚rents informations
	move.w (a0,arr_y),d1
	sub.w (a0,dep_y),d1	* hauteur
	addq.w #1,d1
	andi.l #$0000FFFF,d1	* la hauteur est toujours positive
	move.w (a0),d2
	move.w d2,d4
	sub.w (a0,arr_x),d2	* largeur
	beq arete_verticale
	neg.w d2
	addq.w #1,d2
	move.w d2,d3
	swap d3
	clr.w d3
	divs.l d1,d3	* pente en virgule fixe : 
			* 16 bits partie entiere
			* 16 bits partie decimale
	bra range_arete
arete_verticale
	clr.l d3		* comme arete verticale, alors la pente est nulle!
			* c'est plus rapide que de faire plein de calcul!
range_arete
	subq.w #2,d1
			* rangement et trie de la nouvelle arete
			* toujours un tri par insertion croissant sur les x
	lea liste_aretes,a4
liste_suivantes
	cmp.w (a4,coor_x),d4
	beq liste_aretes_idem	*arete qui on le meme x? oui alors saut!
	bmi liste_bonne_place
	adda.l #aretes_inter,a4
	cmpa.l a4,a3
	bgt liste_suivantes
	move.w d4,(a3)+
	move.l d3,(a3)+
	clr.w (a3)+
	move.w d1,(a3)+
	bra liste_arete_suivante
liste_aretes_idem
			* ici puisque les x sont egaux, on compare les pentes
			* dans l'ordre croissant
	cmp.l (a4,pente),d3
	ble liste_bonne_place
			* ici il faut inserer avant
	adda.l #aretes_inter,a4
liste_bonne_place		* insertion (cf avant)
	movea.l a3,a5
	suba.l #aretes_inter,a4
liste_decalage
	move.l (a5),(a5,aretes_inter)
	move.l (a5,4),(a5,aretes_inter+4)
	move.w (a5,hauteur),(a5,aretes_inter+hauteur)
	suba.l #aretes_inter,a5
	cmpa.l a5,a4
	blt liste_decalage
	adda.l #aretes_inter,a3
	adda.l #aretes_inter,a4
	move.w d4,(a4)+
	move.l d3,(a4)+
	clr.w (a4)+
	move.w d1,(a4)+
liste_arete_suivante
	adda.l #aretes,a0
	cmpa.l a0,a2
	bne ajout_arete
			* fin de la liste des aretes
	st.b d7		* plus la peine de chercher dans
	clr.w (a0,dep_y)	* l'ensemble d'aretes

plus_d_arete		* tracage proprement dit
	lea liste_aretes,a4
tracage
	cmpa.l a4,a3
	beq fin_tracage
			* on prend 2 intersections -> tracage de ligne
	move.w (a4,coor_x),d1
	move.w d1,d2
	add.w d1,d1
	movea.l a1,a5
	adda.w d1,a5	* a5 : adresse du 1er point
	sub.w (a4,aretes_inter+coor_x),d2
	beq tracage_un_point
	neg.w d2
	subq.w #1,d2	* d2 : nombre de points-1 a afficher
tracage_b
	move.w #couleur,(a5)+	* affichage : vive le True Color!
	dbra d2,tracage_b

	adda.l #aretes_inter*2,a4
	bra tracage
tracage_un_point
	move.w #couleur,(a5)+
	adda.l #aretes_inter*2,a4
	bra tracage
			* enlever les aretes inutiles
fin_tracage
	lea liste_aretes,a4
elimine_arete
	tst.w (a4,hauteur)
	bne y_suivant
			* il faut ‚liminer l'arete en l'ecrasant
	movea.l a4,a5
ecrase_arete
	cmpa.l a5,a3
	beq ecrase_arete_suite
	move.w (a5,aretes_inter),(a5)
	move.l (a5,aretes_inter+pente),(a5,pente)
	move.l (a5,aretes_inter+accu),(a5,accu)
	adda.l #aretes_inter,a5
	bra ecrase_arete
ecrase_arete_suite
	suba.l #aretes_inter,a3
	bra elimine_arete_fin	* il n'y a pas besoin d'ajouter aretes_inter
			* … a4, car la prochaine arete est d‚ja
			* point‚e par a4

			* passage … l'y suivant (calcul des nouveaux x)
y_suivant
			* hypothese : les contours sont non autointersectant
			* sinon : rajouter un tri sur les X
			* lorsque toutes les aretes sont recalculees!
	subq.w #1,(a4,hauteur)
	clr.l d1
	move.w (a4,accu),d1
	add.l (a4,pente),d1
	move.w d1,(a4,accu)
	swap d1
	add.w d1,(a4,coor_x)
	adda.l #aretes_inter,a4
elimine_arete_fin
	cmpa.l a4,a3
	bne elimine_arete
			* passage … la ligne suivante
	addq.w #1,d0	* y suivant
	adda.l #ecran_largeur*2,a1	* adresse suivante

	tst.w d7		* ici plus d'arete dans la liste d'intersection
			* si il y en a encore dans l'ensemble d'arete,
			* alors on passe … y suivant, sinon fin
	bne fin_polygone
	bra ajout_arete
fin_polygone
	cmpa.l #liste_aretes,a3	* liste d'arete_vide?
	bne ajout_arete
	rts
	include "principh.s"

	section DATA
polygone	dc.w 160,0
	dc.w 60,100
	dc.w 160,200
	dc.w 260,100
	dc.w 160,0
	ds.w nbre_cote*2

	section BSS
resultat1	ds.w nbre_cote*2*2
resultat2	ds.w nbre_cote*2*2

	even
aretes_triees	ds.b (12+1)*aretes
	even
		ds.b aretes_inter
liste_aretes	ds.b (12+1)*aretes_inter

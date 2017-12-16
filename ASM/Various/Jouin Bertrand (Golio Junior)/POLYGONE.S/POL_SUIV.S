* routine de tracer de polygone en 320*200 True color
* non connexe, trou‚, non convexe, avec contour non auto intersectant
* algorithme de tracer de suivit de contour
* par Golio Junior

* D‚finition de l'image
Video_mode		equ %000100100	* 40 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 320*200*2/4
ecran_largeur	equ 320
ecran_hauteur	equ 200
Pas_Fond		equ 0

	include "principa.s"

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
*	dbra	d0,prg_cls_b1
debut
			* sauter les aretes horizontales
			* orienter les aretes
			* ordonner les aretes
	lea polygone,a0	* pointeur sur l'ensemble des aretes
	lea aretes_triees,a2	* pointeur sur la fin de la liste des aretes triees
	move.w #-1,(a2,dep_y)	* initialisation des aretes triees
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
	cmpa.l #fin_poly,a0	* encore des sommets dans le polygone?
	bne constitution	* oui alors on continue … constitier la liste des
			* aretes

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
	bmi liste_bonne_place
			* ici il faut inserer avant
	suba.l #aretes_inter,a4
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
	sub.w (a4,aretes_inter+coor_x),d2
	neg.w d2
	subq.w #1,d2	* d2 : nombre de points-1 a afficher
	add.w d1,d1
	movea.l a1,a5
	adda.w d1,a5	* a5 : adresse du 1er point
tracage_b
	move.w #0,(a5)+	* affichage : vive le True Color!
	dbra d2,tracage_b

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

	section data
polygone	dc.w 99,72		* 12 aretes
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
	even
aretes_triees	ds.b (12+1)*aretes
	even
		ds.b aretes_inter
liste_aretes	ds.b (12+1)*aretes_inter

	include "principh.s"
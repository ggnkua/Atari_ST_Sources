* ombrage de Gouraud
* Routine en True Color (320*200)
* par Golio Junior pour Falk'mag 6

* D‚finition de l'image
Video_mode		equ %000100100	* 40 col, 200 lig, 65536 cou, TV Pal
Taille_ecran	equ 320*200*2
ecran_largeur	equ 320
ecran_hauteur	equ 200
Pas_Fond		equ 0

	include "principa.s"

* structure d'un point en 3d
	rsreset
coor_x	rs.w 1
coor_y	rs.w 1
coor_z	rs.w 1
t_coor	equ __rs

* struture definissant une arete
	rsreset
dep_x	rs.w 1		* coordonn‚e x de d‚part
dep_y	rs.w 1		* coordonn‚e y de d‚part
arr_x	rs.w 1		* coordonn‚e x d'arriv‚e
arr_y	rs.w 1		* coordonn‚e y d'arriv‚e
dep_indic	rs.w 1		* indice de couleur de d‚part
arr_indic	rs.w 1		* indice de couleur d'arriv‚e
aretes	equ __rs

* struture definissant une intersection d'arete
	rsreset
coord_x	rs.w 1
pente	rs.l 1
accu	rs.w 1
hauteur	rs.w 1
couleur	rs.w 1
pente_c	rs.l 1
accu_c	rs.w 1
aretes_inter	equ __rs

* point de fuite
p	equ	256/200 

* offset de l'ecran
offset_x	equ 160
offset_y	equ 100

* pas des rotations de la source lumineuse
offset_ang_x	equ 1*256/3
offset_ang_y	equ 2*256/3
offset_ang_z	equ 4*256/3

* nombre de face de l'objet
Nbre_face	equ 6

* routine d'initialisation
prg_init
	clr.w angle_x
	clr.w angle_y
	clr.w angle_z
				* effacement de l'ecran
	movea.l adr_ecran,a0
	move.w #Taille_ecran/16-1,d0
prg_init_b1
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	dbra d0,prg_init_b1
	rts
prg
	bsr precalc_3d
	bsr Gouraud
	
	add.w #offset_ang_x,angle_x
	add.w #offset_ang_y,angle_y
	add.w #offset_ang_z,angle_z
	rts

precalc_3d
	lea cos,a4			* table des cosinus
	lea sin,a5			* table des sinus
				* remplissage des sinus/cosinus des angles
	clr.w d0
	move.b angle_x,d0
	move.w (0,a4,d0.w*2),cos_x
	move.w (0,a5,d0.w*2),sin_x
	move.b angle_y,d0
	move.w (0,a4,d0.w*2),cos_y
	move.w (0,a5,d0.w*2),sin_y
	move.b angle_z,d0
	move.w (0,a4,d0.w*2),cos_z
	move.w (0,a5,d0.w*2),sin_z
	
				* precal des coefficients multiplicateur
				* coefficient de x pour x !
	move.w sin_x,d0
	muls.w sin_y,d0		* d0 en 16 bits decimal
	lsr.l #8,d0		* d0 en 8 bits decimal
	muls.w sin_z,d0		* d0 en 16 bits decimal
	move.w cos_x,d1
	muls.w cos_y,d1		* d1 en 16 bits decimal
	add.l d0,d1
	lsr.l #8,d1		* d1 en 8 bits decimal
	move.w d1,x_coef_x

				* coefficient de y pour x
	move.w cos_z,d0
	muls.w sin_x,d0
	lsr.l #8,d0
	move.w d0,x_coef_y
	
				* coefficient de z pour x
	move.w cos_y,d0
	muls.w sin_x,d0
	lsr.l #8,d0
	muls.w sin_z,d0
	move.w cos_x,d1
	muls.w sin_y,d1
	sub.l d1,d0
	lsr.l #8,d0
	move.w d0,x_coef_z
	
				* coefficient de x pour y
	move.w cos_x,d0
	muls.w sin_y,d0
	lsr.l #8,d0
	muls.w sin_z,d0
	move.w cos_y,d1
	muls.w sin_x,d1
	sub.l d1,d0
	lsr.l #8,d0
	move.w d0,y_coef_x
	
				* coefficient de y pour y
	move.w cos_x,d0
	muls.w cos_z,d0
	lsr.l #8,d0
	move.w d0,y_coef_y

				* coefficient de z pour y
	move.w cos_x,d0
	muls.w cos_y,d0
	lsr.l #8,d0
	muls.w sin_z,d0
	move.w sin_x,d1
	muls.w sin_y,d1
	add.l d1,d0
	lsr.l #8,d0
	move.w d0,y_coef_z
	
				* coefficient de x pour z
	move.w cos_y,d0
	muls.w sin_x,d0
	lsr.l #8,d0
	muls.w sin_z,d0
	move.w cos_x,d1
	muls.w sin_y,d1
	sub.l d1,d0
	lsr.l #8,d0
	move.w d0,z_coef_x
	
				* coefficient de y pour z
	move.w sin_z,d0
	neg.w d0
	move.w d0,z_coef_y
	
				* coefficient de z pour z
	move.w cos_y,d0
	muls.w cos_z,d0
	lsr.l #8,d0
	move.w d0,z_coef_z
	rts

Gouraud
	move.w #Nbre_face,compteur_face
	lea objet_face,a5		* liste des points composant une face
gouraud_b1
	lea objet_point,a4		* ensemble des points
	lea objet_normal,a6		* ensemble des normales associ‚e … chaque point
	lea polygone,a3
				* projection du polygone courant
gouraud_b2
	move.w (a5)+,d0		* No du point courant
	bmi fin_calcul_polygone
				* projection du point
	move.w (coor_z,a4,d0.w*8),d7	* z

				* calcul de q
	muls.w #p,d7		* z/p en 2^16 bits
	asr.l #8,d7
	sub.l #1*256,d7		* z/p-1 en 2^8 bits
	neg.l d7			* 1-z/p en 2^8 bits
	move.l #1*65536,d4
	divs.l d7,d4		* 1/(1-z/p) en 2^8 bits
				* x
	move.w (coor_x,a4,d0.w*8),d1
	muls.w d4,d1
	swap d1
	add.w #offset_x,d1
	move.w d1,(a3)+
				* y
	move.w (coor_y,a4,d0.w*8),d1
	muls.w d4,d1
	swap d1
	add.w #offset_y,d1
	move.w d1,(a3)+
				* calcul de la couleur du point
				* produit scalaire du vecteur normal et du vecteur lumiere
				* Rq. : la rotation du vecteur lumiere ne change pas sa norme
				* rotation du vecteur lumiere (0,0,1)
	move.w x_coef_z,d3		* coordonnees x du vecteur lumiere
	muls.w (coor_x,a6,d0.w*8),d3	* fois composante x du vecteur normal du point
	move.w y_coef_z,d1
	muls.w (coor_y,a6,d0.w*8),d1
	move.w z_coef_z,d2
	muls.w (coor_z,a6,d0.w*8),d2

	add.l d1,d3
	add.l d2,d3
	lsr.l #8,d3		* cosinus de l'angle de l'eclairage et du vecteur normal

	tst.w d3
	blt point_non_eclaire

				* calcul de l'indice de la couleur
				* 32 niveaux de gris donc
	lsr.w #4,d3
	cmp.w #32,d3		* on n'a que 32 niveaux, donc il ne faut pas les depasser
	bmi eclairage_non_saturant
	move.w #31,d3		* ‚clairage saturant
eclairage_non_saturant
	move.w d3,(a3)+		* stockage de la couleur du point
	bra gouraud_b2
point_non_eclaire
	move.w #0,(a3)+		* intensit‚ nulle
	bra gouraud_b2

fin_calcul_polygone
				* on r‚pŠte les premieres coordonn‚es
	lea polygone,a4
	move.l (a4)+,(a3)+		* copie de x et y
	move.w (a4)+,(a3)+		* copie de l'indice de couleur
	move.l #-1,(a3)+		* marquage de fin

				* affichage du polygone courant
	movem.l a5,-(sp)
	bsr trace_polygone
	movem.l (sp)+,a5

	subq.w #1,compteur_face
	tst.w compteur_face
	bne gouraud_b1
	rts

trace_polygone
			* sauter les aretes horizontales
			* orienter les aretes
			* ordonner les aretes
	lea polygone,a0	* pointeur sur l'ensemble des aretes
	lea aretes_triees,a2	* pointeur sur la fin de la liste des aretes triees
	move.w #-1,(a2,dep_y)	* initialisation des aretes triees
constitution
			* on recupere les coordonnees de l'arete
	move.l (a0)+,d0	* coordonn‚es sur mot long : X : 16 de poid fort
			*                            Y : 16 de poid faible
	move.w (a0)+,d2	* indice de la couleur de d‚part
	move.l (a0),d1	* coordonn‚es d'arriv‚e
	move.w (a0,4),d3	* indice de la couleur d'arriv‚e
	cmp.w d1,d0
	beq arete_horizontal
	bmi arete_positive
	exg.l d0,d1	* ici l'arete est mal orientee
	exg.l d2,d3	* elle monte!
arete_positive
			* recherche de la bonne place
			* tri par insertion dans l'ordre croissant
	lea aretes_triees,a1
arete_suivante
	cmp.w (a1,dep_y),d0
	bmi bonne_place	* bonne place? si oui, alors bonne_place
	adda.l #aretes,a1	* place suivante
	cmpa.l a1,a2	* sort-on de la liste des aretes?
	bgt arete_suivante	* non alors on continue
	move.l d0,(a2)+	* on arrive … la fin de la liste
	move.l d1,(a2)+	* donc on insere l'arete … la fin
	move.w d2,(a2)+
	move.w d3,(a2)+
	bra arete_horizontal
bonne_place
			* c'est le bon endroit
			* il faut se faire un peut de place
	movea.l a2,a3	* pour se faire un peut de place
	suba.l #aretes,a1	* on va copier l'arete courante dans la place suivante
decalage	move.l (a3),(a3,aretes)	* donc on commence par la fin
	move.l (a3,arr_x),(a3,aretes+arr_x)
	move.l (a3,dep_indic),(a3,aretes+dep_indic)
	suba.l #aretes,a3
	cmpa.l a3,a1
	blt decalage	* fin du decalage? non alors decalage!
	adda.l #aretes,a2	* nouvelle fin de table
	adda.l #aretes,a1
	move.l d0,(a1)+	* on place l'arete dans la place que l'on
	move.l d1,(a1)+	* vient de faire
	move.w d2,(a1)+
	move.w d3,(a1)+
arete_horizontal
	tst.w (a0,6)	* encore des sommets dans le polygone?
	bpl constitution	* oui alors on continue … constitier la liste des
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

			* calcul de la "pente" de couleur
	move.w (a0,dep_indic),d5
	move.w d5,d6	* d6 contient l'indice de la 1ere couleur
	sub.w (a0,arr_indic),d5
	beq couleur_neutre	* il y aucun changement de couleur
	neg.w d5		* sinon calcul de la "pente"
	addq.w #1,d5	* de la couleur 
	swap d5		* le long de l'arŠte
	clr.w d5		* 16 bits partie entiŠre
	divs.l d1,d5	* 16 bits partie d‚cimale
	bra couleur_suite
couleur_neutre
	clr.l d5
couleur_suite
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
	cmp.w (a4,coord_x),d4
	beq liste_aretes_idem	*arete qui on le meme x? oui alors saut!
	bmi liste_bonne_place
	adda.l #aretes_inter,a4
	cmpa.l a4,a3
	bgt liste_suivantes
	move.w d4,(a3)+
	move.l d3,(a3)+
	clr.w (a3)+
	move.w d1,(a3)+
	move.w d6,(a3)+
	move.l d5,(a3)+
	clr.w (a3)+
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
	move.l (a5,hauteur),(a5,aretes_inter+hauteur)
	move.l (a5,pente_c),(a5,aretes_inter+pente_c)
	move.w (a5,accu_c),(a5,aretes_inter+accu_c)
	suba.l #aretes_inter,a5
	cmpa.l a5,a4
	blt liste_decalage
	adda.l #aretes_inter,a3
	adda.l #aretes_inter,a4
	move.w d4,(a4)+
	move.l d3,(a4)+
	clr.w (a4)+
	move.w d1,(a4)+
	move.w d6,(a4)+
	move.l d5,(a4)+
	clr.w (a4)+
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
	move.w (a4,coord_x),d1
	clr.l d2
	move.w d1,d2
	sub.w (a4,aretes_inter+coord_x),d2
	neg.w d2
	addq.w #1,d2	* d2 : nombre de points+2 a afficher (pour la division)
	lea palette,a6

	move.w (a4,couleur),d6	* calcul de la pente de la couleur
	move.w d6,d5	* pour la ligne courante
	sub.w (a4,aretes_inter+couleur),d6
	beq tracage_c_neutre	* pas de changement de couleur, donc pente nulle
	neg.w d6		* ici on calcul la pente de la couleur
	addq.w #1,d6	* dans la mˆme repr‚sentation
	swap d6
	clr.w d6
	divs.l d2,d6
	bra tracage_c
tracage_c_neutre
	clr.l d6
tracage_c
	swap d5		* d5 : 16 bits poids fort : indice couleur
			*      16 bits poids faible : accu
	clr.w d5		* accu couleur … 0
	subq.w #2,d2	* nombre de points-0 … afficher!
	bmi fin_tracage_b
			* adresse du premier point
	add.w d1,d1
	movea.l a1,a5
	adda.w d1,a5	* a5 : adresse du 1er point
			* d6 : pente de la couleur
			* d5 : indice de la couleur + accu
			* a6 : palette
tracage_b
	swap d5		* affichage suivant l'indice (16 bits de poids fort)
	move.w (a6,d5.w*2),(a5)+	* affichage : vive le True Color!
	swap d5		* retour … la repr‚sentation normal
	add.l d6,d5	* addition de la pente
	dbra d2,tracage_b	* point suivant !
fin_tracage_b
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
	move.l (a5,aretes_inter+couleur),(a5,couleur)
	move.l (a5,aretes_inter+couleur+4),(a5,couleur+4)
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
	add.w d1,(a4,coord_x)
	clr.l d1
	move.w (a4,accu_c),d1
	add.l (a4,pente_c),d1
	move.w d1,(a4,accu_c)
	swap d1
	add.w d1,(a4,couleur)
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
objet_point
	* Struture de l'objet :
	* liste des coordonn‚es de points.
	* Structure d'un point : coordonn‚es x, y, z.
	* Coordonn‚es represent‚es en virgule fixe : 
	*	8 bits partie entiŠre
	*	8 bits partie d‚cimale

			* base de la pyramide tronqu‚e
 	dc.w $0000, $0000, $0000, $0
	dc.w $2800, $0000, $0000, $0
	dc.w $2800, $2800, $0000, $0
	dc.w $0000, $2800, $0000, $0
			* sommet de la pyramide tronqu‚e
	dc.w $0A00, $0A00, $0A00, $0
	dc.w $1E00, $0A00, $0A00, $0
	dc.w $1E00, $1E00, $0A00, $0
	dc.w $0A00, $1E00, $0A00, $0

objet_normal
	* ensemble des vecteurs normaux associe au points
	* Structure d'un vecteur : coordonn‚es x, y, z.
	* Coordonn‚es represent‚es en virgule fixe : 
	*	8 bits partie entiŠre
	*	8 bits partie d‚cimale

			* base de la pyramide tronqu‚e
 	dc.w $FF58, $FF58, $0062, $0
	dc.w $00A8, $FF58, $0062, $0
	dc.w $00A8, $00A8, $0062, $0
	dc.w $FF58, $00A8, $0062, $0
			* sommet de la pyramide tronqu‚e
	dc.w $FFBB, $FFBB, $00ED, $0
	dc.w $0045, $FFBB, $00ED, $0
	dc.w $0045, $0045, $00ED, $0
	dc.w $FFBB, $0045, $00ED, $0

objet_face
	* structure : 
	* liste de point qui constistus une face termin‚ par -1
	dc.w 00, 01, 02, 03, -1	* face arriere
	dc.w 04, 05, 06, 07, -1	* face avant
	
	dc.w 00, 01, 05, 04, -1	* bord haut
	dc.w 01, 02, 06, 05, -1	* bord droit
	dc.w 02, 03, 07, 06, -1	* bord bas
	dc.w 00, 04, 07, 03, -1	* bord gauche

sin	include "sin.dat"

cos	include "cos.dat"

palette	include "palette.dat"

	section BSS
compteur_face	ds.w 1	* nombre de face a dessiner
			* valeur des angles de rotations
angle_x	ds.w 1
angle_y	ds.w 1
angle_z	ds.w 1
			* valeur des sinus/cosinus
sin_x	ds.w 1
cos_x	ds.w 1
sin_y	ds.w 1
cos_y	ds.w 1
sin_z	ds.w 1
cos_z	ds.w 1
			* valeur des precalcs
x_coef_x	ds.w 1
x_coef_y	ds.w 1
x_coef_z	ds.w 1
y_coef_x	ds.w 1
y_coef_y	ds.w 1
y_coef_z	ds.w 1
z_coef_x	ds.w 1
z_coef_y	ds.w 1
z_coef_z	ds.w 1

polygone	ds.w 3*5+2

aretes_triees	ds.b (4+1)*aretes
liste_aretes	ds.b (4+1)*aretes_inter

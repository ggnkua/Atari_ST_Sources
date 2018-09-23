; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion des outils. (1.2)
;
; Les icones suivantes sont disponibles:
;
; - Crayon
; - Gomme [**]
; - Pot de peinture
; - Trac‚ de rectangles
; - Trac‚ de cercles ou d'ellipses [*]
; - Trac‚ de lignes
; - Aerosol
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 section TEXT
 
module_choisie_outils
 move.l ‚cran,‚cran_s‚l
 move largeur_‚cran,largeur_‚cran_s‚l

 bsr cache_zoomer_s‚lecteur
 
 bsr recopie_‚cran

 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_flŠche,adresse_curseur

 move.l #d‚f_outils_s‚lecteur,adresse_ressource
 sf flag_ferme_formulaire

 bsr calcule_minimax
 bsr centre_s‚lecteur

 bsr vsync
 bsr vsync

 bsr initialise_outils 
 bsr d‚code_ressource

 bsr vsync

 relache
 
 bsr gŠre_s‚lecteur

 bsr efface_s‚lecteur

 jsr vide_clavier

 move.l sauvegarde_curseur,adresse_curseur
 bsr colorie_curseur

 bsr s‚lecteur_informations		Met … jour la barre d'infos...
 bsr montre_zoomer_s‚lecteur
 rts



initialise_matrice
 lea matrice_outils,a0

 matrice crayon,dessin,'D',0,0

 matrice rŠgle,ligne,'L',0,1
 matrice rŠgle,kligne,'K',0,1
 matrice rŠgle,rayon,'R',0,1

 matrice peinture,remplissage,'Z',0,0

 matrice compas,cercle,'C',0,2
 matrice compas,disque,'Q',0,2

 matrice equerre,cadre,'F',0,1
 matrice equerre,boite,'B',0,1

 matrice a‚rosol,spray_1,'A',0,2
 matrice a‚rosol,spray_2,0,0,2
 rts



**
** Routines qui sont ex‚cut‚es lorsque l'on change de mode de
** dessin, en appuyant sur une icone, ou en pressant
** la touche correspondante sur le clavier.
**
** On utilise un double systŠme d'indexation:
** - Num‚ro de l'outil (crayon/rŠgle)
** - Num‚ro de la sous fonction (ligne/k-lignes/rayons) 
**

num‚ro_crayon=0
num‚ro_crayon_dessin=0

num‚ro_rŠgle=1
num‚ro_rŠgle_ligne=0
num‚ro_rŠgle_kligne=1
num‚ro_rŠgle_rayon=2

num‚ro_peinture=2
num‚ro_peinture_remplissage=0

num‚ro_compas=3
num‚ro_compas_cercle=0
num‚ro_compas_disque=1

num‚ro_equerre=4
num‚ro_equerre_cadre=0
num‚ro_equerre_boite=1

num‚ro_a‚rosol=5
num‚ro_a‚rosol_spray_1=0
num‚ro_a‚rosol_spray_2=1

adresse_routine_dessin	dc.l routine_crayon_dessin
num‚ro_outils		dc.w 0
num‚ro_effet		dc.w 0

v‚rifie_touche_outils
* move code_scan,d1
 move code_ascii,d0
 beq .touche_non_trouv‚e

 lea matrice_outils,a0
 moveq #0,d7			1er outil
.teste_outils_suivant
 lea 2(a0),a1

 moveq #0,d6			1Šre fonction
.teste_fonction_suivante
 tst.l matrice_icone(a1)	Si la valeur est nulle, plus de fonctions !
 beq.s .fin_outil
 cmp.b matrice_touche(a1),d0	Meme code de touche ???
 beq .outil_trouv‚
 lea matrice_taille(a1),a1
 addq #1,d6
 cmp #matrice_largeur,d6
 bne.s .teste_fonction_suivante

.fin_outil
 lea 2+matrice_largeur*matrice_taille(a0),a0	Outil suivant
 addq #1,d7
 cmp #matrice_hauteur,d7
 bne.s .teste_outils_suivant
.touche_non_trouv‚e
 rts

.outil_trouv‚
 move d7,num‚ro_outils				Num‚ro de l'outil
 move d6,(a0)					Num‚ro de la fonction
 move.l matrice_routine(a1),adresse_routine_dessin
 move.l matrice_curseur(a1),adresse_curseur
 move matrice_infos(a1),type_info_outil
 bsr colorie_curseur
 rts
    
adresse_icone_choisie	dc.l d‚f_outils_crayon
adresse_effet_choisi	dc.l d‚f_outils_effet_1


s‚lectionne_effet_1
 lea str_effet_1,a1
 moveq #0,d0
 bra.s s‚lectionne_effet
s‚lectionne_effet_2
 lea str_effet_2,a1
 moveq #1,d0
 bra.s s‚lectionne_effet
s‚lectionne_effet_3
 lea str_effet_3,a1
 moveq #2,d0
 bra.s s‚lectionne_effet
s‚lectionne_effet_4
 lea str_effet_4,a1
 moveq #3,d0
 bra.s s‚lectionne_effet
s‚lectionne_effet_5
 lea str_effet_5,a1
 moveq #4,d0
 bra.s s‚lectionne_effet
s‚lectionne_effet_6
 lea str_effet_6,a1
 moveq #5,d0
 bra.s s‚lectionne_effet

s‚lectionne_effet
 cmp num‚ro_effet,d0		V‚rifie que l'on ne res‚lectionne pas le
 beq fin_s‚lection_effet	meme effet.(‚vite le r‚affichage moche)

 move d0,num‚ro_effet		M‚morise le nouveau num‚ro d'effet

 lea texte_infos_effet_nom,a2
.copie_chaine
 move.b (a1)+,(a2)+
 bne.s .copie_chaine

 move.l a0,-(sp)
 move.l adresse_effet_choisi,a0
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 move.l (sp)+,a0

 not objet_relief(a0)
 move.l a0,adresse_effet_choisi
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

fin_s‚lection_effet
 rts









initialise_outils 
 move num‚ro_outils,d0
 lea d‚f_outils_crayon,a0
 move d0,d1
 mulu #longueur_d‚f,d1
 add d1,a0
 bra force_s‚lection_outil
 rts


s‚lectionne_outil_0
 moveq #0,d0
 bra.s s‚lectionne_outil
s‚lectionne_outil_1
 moveq #1,d0
 bra.s s‚lectionne_outil
s‚lectionne_outil_2
 moveq #2,d0
 bra.s s‚lectionne_outil
s‚lectionne_outil_3
 moveq #3,d0
 bra.s s‚lectionne_outil
s‚lectionne_outil_4
 moveq #4,d0
 bra.s s‚lectionne_outil
s‚lectionne_outil_5
 moveq #5,d0
 bra.s s‚lectionne_outil


s‚lectionne_outil
 cmp num‚ro_outils,d0		V‚rifie que l'on ne res‚lectionne pas le
 beq fin_s‚lection_outil	meme outil.(‚vite le r‚affichage moche)

 move d0,num‚ro_outils		M‚morise le nouveau num‚ro d'outil

force_s‚lection_outil
 move.l a0,-(sp)
 move.l adresse_icone_choisie,a0
 move #15<<11+31<<5+15,objet_cadre(a0)	* clr objet_cadre(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 move.l (sp)+,a0

 move #31<<11+0<<6+0,objet_cadre(a0)
* move #-1,objet_cadre(a0)
 move.l a0,adresse_icone_choisie
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_outils_fonctions,a0
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚but_liste_icones,a0
 lea matrice_outils,a3
 move num‚ro_outils,d0
 mulu #matrice_largeur*matrice_taille+2,d0
 add d0,a3
 move (a3)+,d0				Fonction choisie
 move d0,d1				Pour savoir quelle icone choisir !
 mulu #matrice_taille,d0
 lea (a3,d0.w),a1			Adresse de la derniŠre icone
 move (a0),d0				Coordonn‚e X d'affichage
.recopie_icone
 tst.l (a3)
 beq.s .fin_copie_icone

 move.l objet_texte(a0),a2
 move.l matrice_icone(a3),objet_texte_icone(a2)
 move d0,(a0)
 add #20,d0				Repositionne X (car -1:Fin RSC)

 move #15<<11+31<<5+15,objet_cadre(a0)	Met l'icone en GRIS.
 tst d1					Est-ce l'icone active ?
 bne.s .pas_cette_icone
 move #31<<11+0<<5+0,objet_cadre(a0)	Si oui, met la en couleur.
.pas_cette_icone
 subq #1,d1
   
 movem.l d0-a6,-(sp)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 movem.l (sp)+,d0-a6
 lea longueur_d‚f(a0),a0		Icone suivante
 lea matrice_taille(a3),a3		Fonction suivante
 bra.s .recopie_icone

.fin_copie_icone
 move #-1,(a0)

 move.l matrice_routine(a1),adresse_routine_dessin
 move.l matrice_curseur(a1),sauvegarde_curseur

 bsr change_titre_fonction
  
* relache
fin_s‚lection_outil
 rts








s‚lectionne_fonction_0
 moveq #0,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_1
 moveq #1,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_2
 moveq #2,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_3
 moveq #3,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_4
 moveq #4,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_5
 moveq #5,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_6
 moveq #6,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_7
 moveq #7,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_8
 moveq #8,d0
 bra.s s‚lectionne_fonction
s‚lectionne_fonction_9
 moveq #9,d0
 bra.s s‚lectionne_fonction
 nop

s‚lectionne_fonction
 lea matrice_outils,a1
 move num‚ro_outils,d1
 mulu #matrice_largeur*matrice_taille+2,d1
 add d1,a1
 move (a1),d1				Num‚ro de l'outil pr‚c‚dent.
 cmp d1,d0				V‚rifie que l'on change de fonction !
 beq .fin_s‚lection			meme outil.(‚vite le r‚affichage moche)
 move d0,(a1)+
 
 move #31<<11+0<<5+0,objet_cadre(a0)	Validation de la nouvelle icone
 bsr calcule_xy_‚l‚ment			Puis r‚affichage
 bsr affichage_‚l‚ment

 lea d‚but_liste_icones,a0
 mulu #longueur_d‚f,d1
 add d1,a0
 move #15<<11+31<<5+15,objet_cadre(a0)	D‚validation de l'ancienne icone
 bsr calcule_xy_‚l‚ment			Puis r‚affichage
 bsr affichage_‚l‚ment

 mulu #matrice_taille,d0		Taille dans la matrice
 add d0,a1				Descripteur de la fonction
 move.l matrice_routine(a1),adresse_routine_dessin
 move.l matrice_curseur(a1),sauvegarde_curseur

 bsr change_titre_fonction
 
* relache
.fin_s‚lection
 rts

* En entr‚e: A1 pointe sur le bon objet de la matrice.
*
*
change_titre_fonction
 lea txt_outils_chaine_nom,a2
 tst.b matrice_touche(a1)
 beq.s .pas_de_raccourcis
 move.b #'[',(a2)+
 move.b matrice_touche(a1),(a2)+	Inscrit le raccourci clavier
 move.w #'] ',(a2)+
.pas_de_raccourcis  
 lea texte_infos_outil_nom,a3		Pour la barre d'infos
 move.l matrice_texte(a1),a1		Ainsi que le texte !
.copie_chaine
 move.b (a1),(a2)+
 move.b (a1)+,(a3)+
 bne.s .copie_chaine

 lea d‚f_outils_infos_fonctions,a0	R‚affiche le titre
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 rts

 



routine_fermeture_outils
 lea d‚f_outils_fermeture,a0
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 relache
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 st flag_ferme_formulaire
 rts

routine_‚crit_fonction
 move.l adresse_icone_choisie,a0
 move.l objet_texte_icone(a0),a0
 lea 652(a0),a0
 lea txt_outils_chaine_nom,a1
.recopie_chaine
 move.b (a0)+,(a1)+ 
 bne.s .recopie_chaine
 rts
 
 section DATA 

 even

icone_crayon_dessin
icone_crayon		incbin fichiers.inc\icones\crayon.icn

icone_rŠgle		incbin fichiers.inc\icones\regle.icn
icone_rŠgle_ligne	incbin fichiers.inc\icones\ligne.icn
icone_rŠgle_kligne	incbin fichiers.inc\icones\kligne.icn
icone_rŠgle_rayon	incbin fichiers.inc\icones\rayon.icn

icone_gomme		incbin fichiers.inc\icones\gomme.icn
icone_gomme_fine	incbin fichiers.inc\icones\gfine.icn
icone_gomme_moyenne	incbin fichiers.inc\icones\gmoyenne.icn

icone_peinture_remplissage
icone_peinture		incbin fichiers.inc\icones\peinture.icn

icone_rotation		incbin fichiers.inc\icones\fleche.icn
icone_rotation_90gauche	incbin fichiers.inc\icones\90gauche.icn
icone_rotation_90droite	incbin fichiers.inc\icones\90droite.icn
icone_rotation_vflip	incbin fichiers.inc\icones\vflip.icn
icone_rotation_hflip	incbin fichiers.inc\icones\hflip.icn

icone_compas		incbin fichiers.inc\icones\compas.icn
icone_compas_cercle	incbin fichiers.inc\icones\cercle.icn
icone_compas_disque	incbin fichiers.inc\icones\disque.icn

icone_effet		incbin fichiers.inc\icones\effet.icn
icone_effet_assombrir
icone_effet_‚claicir
icone_effet_n‚gatif
icone_effet_hflou
icone_effet_gflou
icone_effet_gris	incbin fichiers.inc\icones\gris.icn

icone_equerre		incbin fichiers.inc\icones\equerre.icn
icone_equerre_cadre	incbin fichiers.inc\icones\carre.icn
icone_equerre_boite	incbin fichiers.inc\icones\boite.icn

icone_a‚rosol		incbin fichiers.inc\icones\aerosol.icn
icone_a‚rosol_spray_1	incbin fichiers.inc\icones\spray_1.icn
icone_a‚rosol_spray_2	incbin fichiers.inc\icones\spray_2.icn
 
*
* Explication du format:
* -12 .l (raccourcis)		Liste des raccourcis claviers.
* -8  .l (titre)		Adresse de l'objet titre.
* -4  .l (ext‚rieur)		Routine … ex‚cuter si on clique en dehors.
* {Adresse de base}
* +0  .w (ob_type)		Type de l'objet (R‚f‚renc‚ GEM)
* +2  .w (x,y)			Coordonn‚es du point en haut … gauche
* +4  .w (l,h)			Largeur et hauteur du cadre
* +6  .w (‚paisseur)		Nombre de bordures … tracer
* +8  .w (relief)		Creu (-1) ou bosse (0)
* +10 .w (couleur centre)
* +12 .w (couleur cadre)	Gris (0) ou de la couleur principale (-1)
* +16 .l (s‚lection)		Adresse de la routine de gestion, sinon (0)
* +20 .l (texte)		Adresse d'un chaine de caractŠres, sinon (0)
*
* si en +0 on … -1	-> Fin de la ressource
*		-2	-> Lien vers un autre morceau de ressource.

raccourcis_clavier_outils
 raccourcis 0,27,d‚f_outils_fermeture
 raccourcis 0,32,d‚f_outils_fermeture
 raccourcis $3b,0,d‚f_outils_crayon		F1
 raccourcis $3c,0,d‚f_outils_rŠgle		F2
 raccourcis $3d,0,d‚f_outils_peinture		F3
 raccourcis $3e,0,d‚f_outils_compas		F4
 raccourcis $3f,0,d‚f_outils_equerre		F5
 raccourcis $40,0,d‚f_outils_a‚rosol		F6
 dc.w -1
 
 dc.l raccourcis_clavier_outils
 dc.l d‚f_outils_titre
 dc.l routine_fermeture_outils
d‚f_outils_s‚lecteur
 dc.w g_box
 dc.w 000,000,123,105,0,0	Cadre principal
 code_rvb 16,32,16		GRIS
 dc.w 0
 dc.l 0,0

d‚f_outils_fermeture
 dc.w g_box
 dc.w 001,001,010,010,0,0	Case de fermeture en haut … gauche
 code_rvb 0,32,0		VERT
 dc.w -1
 dc.l routine_fermeture_palette,txt_outils_fermeture

d‚f_outils_titre
 dc.w g_box
 dc.w 013,001,109,010,0,0	Entete pour le titre
 code_rvb 0,32,0		VERT
 dc.w -1
 dc.l routine_d‚place_cadre,txt_outils_titre

 dc.w g_box
 dc.w 001,013,121,21,0,1	Partie inf‚rieure	(182)
 code_rvb 16,32,16		GRIS
 code_rvb 16,32,16
 dc.l 0,0

d‚f_outils_crayon
 dc.w g_box
 dc.w 002,014,019,019,0,1
 code_rvb 31,0,0
 code_rvb 31,0,0
 dc.l s‚lectionne_outil_0,txt_outils_crayon
 
d‚f_outils_rŠgle
 dc.w g_box
 dc.w 022,014,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_outil_1,txt_outils_rŠgle
 
d‚f_outils_peinture
 dc.w g_box
 dc.w 042,014,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_outil_2,txt_outils_peinture
 
d‚f_outils_compas
 dc.w g_box
 dc.w 062,014,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_outil_3,txt_outils_compas
 
d‚f_outils_equerre
 dc.w g_box
 dc.w 082,014,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_outil_4,txt_outils_equerre
 
d‚f_outils_a‚rosol
 dc.w g_box
 dc.w 102,014,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_outil_5,txt_outils_a‚rosol
  

************** Les effets

;d‚f_outils_cadre_base
; dc.w g_box
; dc.w 001,071,121,61,0,0	Cadre du sous menu
; code_rvb 16,32,16		GRIS
; dc.w 0
; dc.l 0,0

d‚f_outils_effet_1
 dc.w g_box
 dc.w 002,071,059,010,0,-1	Case par d‚faut -> Enfonc‚e
 code_rvb 15,31,15
 dc.w 0
 dc.l s‚lectionne_effet_1,txt_outils_effet_1

 dc.w g_box
 dc.w 002,082,059,010,0,0
 code_rvb 15,31,15
 dc.w 0
 dc.l s‚lectionne_effet_2,txt_outils_effet_2

 dc.w g_box
 dc.w 002,093,059,010,0,0
 code_rvb 15,31,15
 dc.w 0
 dc.l s‚lectionne_effet_3,txt_outils_effet_3

 dc.w g_box
 dc.w 062,071,059,010,0,0
 code_rvb 15,31,15
 dc.w 0
 dc.l s‚lectionne_effet_4,txt_outils_effet_4

 dc.w g_box
 dc.w 062,082,059,010,0,0
 code_rvb 15,31,15
 dc.w 0
 dc.l s‚lectionne_effet_5,txt_outils_effet_5

 dc.w g_box
 dc.w 062,093,059,010,0,0
 code_rvb 15,31,15
 dc.w 0
 dc.l s‚lectionne_effet_6,txt_outils_effet_6
	


*
*
* Les sous menus
*
*
d‚f_outils_infos_fonctions
 dc.w g_box
 dc.w 001,036,121,010,0,0	Bande o— apparait le nom de l'outil choisi
 code_rvb 0,32,0		VERT
 dc.w -1
 dc.l 0,txt_outils_nom_outil

d‚f_outils_fonctions
 dc.w g_box
 dc.w 001,048,121,21,0,1	Cadre du sous menu
 code_rvb 16,32,16		GRIS
 code_rvb 16,32,16
 dc.l 0,0

d‚but_liste_icones
d‚f_fonction_1
 dc.w g_box
 dc.w 002,049,019,019,0,1
 code_rvb 31,0,0
 code_rvb 31,0,0
 dc.l s‚lectionne_fonction_0,txt_outils_0

d‚f_fonction_2
 dc.w g_box
 dc.w 022,049,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_fonction_1,txt_outils_1

d‚f_fonction_3
 dc.w g_box
 dc.w 042,049,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_fonction_2,txt_outils_2

d‚f_fonction_4
 dc.w g_box
 dc.w 062,049,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_fonction_3,txt_outils_3

d‚f_fonction_5
 dc.w g_box
 dc.w 082,049,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_fonction_4,txt_outils_4

d‚f_fonction_6
 dc.w g_box
 dc.w 102,049,019,019,0,1
 code_rvb 31,0,0
 code_rvb 15,31,15
 dc.l s‚lectionne_fonction_5,txt_outils_5

 dc.w -1			Fin de la ressource
 
 
* Format des chaines de caractŠre:
* .w (Offset X)
* .w (Offset Y)
* .w (Couleur d'affichage)
* .b... (Texte … afficher suivi de 0)
*   ... Si ‚gal … 0, alors est suivi d'un .L qui est l'adresse d'un bloc
*   ... graphique TRUE COLOR au format suivant:
*   ... .w = Largeur
*   ... .w = Hauteur
*   ... .w... Le dessin lui meme.
 

txt_outils_titre
 dc.w 34,2
 code_rvb 31,63,31
 dc.b "OUTILS",0
 even

txt_outils_fermeture 
 dc.w 2,2
 code_rvb 0,0,0
 dc.b "",0
 even

txt_outils_nom_outil
 dc.w 2,2
 code_rvb 0,0,0
txt_outils_chaine_nom
 dcb.b 80,0
 even

txt_outils_crayon
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon  

txt_outils_rŠgle
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_rŠgle

txt_outils_peinture
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_peinture

txt_outils_compas
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_compas

txt_outils_equerre
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_equerre

txt_outils_a‚rosol
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_a‚rosol


txt_outils_0
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_1
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_2
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_3
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_4
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_5
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_6
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_7
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_8
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

txt_outils_9
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon

********************** Les boites avec les effets possibles

txt_outils_effet_1
 dc.w 2,2
 code_rvb 0,0,0
str_effet_1
 dc.b "REMPLACE",0
 even

txt_outils_effet_2
 dc.w 2,2
 code_rvb 0,0,0
str_effet_2
 dc.b "LUMIERE",0
 even

txt_outils_effet_3
 dc.w 2,2
 code_rvb 0,0,0
str_effet_3
 dc.b "FONDU",0
 even

txt_outils_effet_4
 dc.w 2,2
 code_rvb 0,0,0
str_effet_4
 dc.b "N & B",0
 even

txt_outils_effet_5
 dc.w 2,2
 code_rvb 0,0,0
str_effet_5
 dc.b "FLOU 1",0
 even

txt_outils_effet_6
 dc.w 2,2
 code_rvb 0,0,0
str_effet_6
 dc.b "FLOU 2",0
 even

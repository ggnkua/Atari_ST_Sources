; REMBRANDT 3.0 - ½  Dbug II
;
; Juste un FORM_DO, histoire d'avoir les boites en relief dans
; la ligne d'informations en bas de l'‚cran (c'est plus classe, non ???)
;
 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 section TEXT


s‚lecteur_informations
 movem.l d0-a6,-(sp)
 move.l adresse_zoomer,a0
 add largeur_visible,a0
 move.l a0,‚cran_s‚l
 move largeur_visible,largeur_‚cran_s‚l
 move.l #d‚f_infos,adresse_ressource
 move #0,min_x
 move #319,max_x
 move #0,min_y
 move #8,max_y
 move min_x,affiche_x
 move min_y,affiche_y
 move #320,largeur_ressource
 move #9,hauteur_ressource

 move couleur,d‚f_infos_couleur_1_rvb
 move #16<<11+31<<5+16,d‚f_infos_couleur_2_rvb
 move #16<<11+31<<5+16,d‚f_infos_couleur_3_rvb

;
; Change le drapeau SCROLL on/off
;
 lea texte_infos_scrolling_nom,a0
 move.b #'ð',(a0)
 tst.b flag_scrolling
 beq.s .pas_scroll
 move.b #'',(a0)
.pas_scroll
  
;
; Copie le nom de l'oeuvre ! dans la ligne d'infos...
;
 lea nom_fichier,a0
 lea texte_infos_image_nom,a1
.recopie_nom
 move.b (a0)+,d0
 beq.s .fin_copie
 cmp.b #'.',d0
 beq.s .fin_copie
 move.b d0,(a1)+
 bra.s .recopie_nom
.fin_copie
 clr.b (a1)+

 bsr d‚code_ressource
 movem.l (sp)+,d0-a6
 rts



r‚affiche_cases_couleur
 movem.l d0-a6,-(sp)
 move.l adresse_zoomer,a0
 add largeur_visible,a0
 move.l a0,‚cran_s‚l
 move largeur_visible,largeur_‚cran_s‚l
 move.l #d‚f_infos,adresse_ressource
 move #0,min_x
 move #319,max_x
 move #0,min_y
 move #8,max_y
 move #0,affiche_x
 move #0,affiche_y
 move #320,largeur_ressource
 move #9,hauteur_ressource

 lea d‚f_infos_couleur_1,a0
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_infos_couleur_2,a0
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_infos_couleur_3,a0
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 bsr set_print_rvb
 movem.l (sp)+,d0-a6
 rts


set_print_rvb
 move.l adresse_zoomer,a1
 add.l #2*62,a1
 move largeur_visible,d7
 lea (a1,d7.w*2),a1
 lea (a1,d7.w),a1
 move.l a1,a6
 
 lea texte_zoomer,a0
 move couleur,d0
 rol #5,d0
 and #%11111,d0			Rouge
 ext.l d0
 bsr inscrit_chaine_3x5
 move.b #-1,(a0)+
 move #31<<11,d7		Couleur d'affichage
 lea texte_zoomer,a0
 bsr affiche_3x5 

 lea texte_zoomer,a0
 move couleur,d0
 lsr #5,d0
 and #%111111,d0		Vert
 ext.l d0
 bsr inscrit_chaine_3x5
 move.b #-1,(a0)+
 move #63<<5,d7		Couleur d'affichage
 lea 20(a6),a6
 move.l a6,a1
 lea texte_zoomer,a0
 bsr affiche_3x5 

 lea texte_zoomer,a0
 move couleur,d0
 and #%11111,d0		Bleu
 ext.l d0
 bsr inscrit_chaine_3x5
 move.b #-1,(a0)+
 move #31,d7		Couleur d'affichage
 lea 20(a6),a6
 move.l a6,a1
 lea texte_zoomer,a0
 bsr affiche_3x5 
 rts





; Routine G_USER_DEF.
; A0-> Pointe sur l'‚l‚ment courant
; A1-> Position ‚cran (int‚rieure)
;
affiche_position_souris
 movem.l d0-a6,-(sp)

 lea texte_zoomer,a0
 move mousex,d0
 ext.l d0
 bsr inscrit_chaine_3x5
 move.b #13,(a0)+	®13¯ = ®:¯
 move mousey,d0
 ext.l d0
 bsr inscrit_chaine_3x5
 move.b #-1,(a0)+

 lea texte_zoomer,a0
 lea fonte_3x5,a2
 add #4,a1
 move #$f000,d7		Couleur d'affichage
 
.lettre_suivante
 moveq #0,d0
 move.b (a0)+,d0 	Prends le code ASCII du caractŠre
 bmi .fin_infos		si 0, termin‚
 mulu #30,d0
 lea (a2,d0.w),a4	Adresse du caractŠre d‚sir‚
 move.l a1,a5		Adresse d'affichage du caractŠre
 moveq #5-1,d0
.affiche_lettre

 move (a4)+,d2
 beq .affiche_pas_pixel_1
 move d2,(a5)
.affiche_pas_pixel_1

 move (a4)+,d2
 beq .affiche_pas_pixel_2
 move d2,2(a5)
.affiche_pas_pixel_2

 move (a4)+,d2
 beq .affiche_pas_pixel_3
 move d2,4(a5)
.affiche_pas_pixel_3

 add largeur_visible,a5
 dbra d0,.affiche_lettre 
 addq #8,a1
 bra .lettre_suivante

.fin_infos
 movem.l (sp)+,d0-a6
 rts



  
 section DATA
 even

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

 dc.l -1
 dc.l -1
 dc.l -1
d‚f_infos
; dc.w g_box
; dc.w 000,000,320,9,0,0		Cadre principal
; code_rvb 16,32,16		GRIS
; dc.w neutre
; dc.l no_prog,0

d‚f_infos_scrolling
 dc.w g_box
 dc.w 000,000,009-1,008,0,0	Le symbole indiquant si le scroll est actif ou non
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,texte_infos_scrolling

d‚f_infos_souris
 dc.w g_box
 dc.w 009,000,041-1,008,0,0	La case avec les infos sur la souris (x,y,vitesse)
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,0

d‚f_infos_couleur_1
 dc.w g_box
 dc.w 050,000,010-1,008,0,0	La case qui contient la couleur courante...
d‚f_infos_couleur_1_rvb
 code_rvb 31,0,0		ROUGE
 dc.w color‚
 dc.l no_prog,0

d‚f_infos_rvb
 dc.w g_box
 dc.w 060,000,035-1,008,0,0	La case avec les composantes RVB
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,0

d‚f_infos_couleur_2
 dc.w g_box
 dc.w 095,000,010-1,008,0,0	La case qui contient la couleur en court de capture...
d‚f_infos_couleur_2_rvb
 code_rvb 0,0,0			Noir
 dc.w color‚
 dc.l no_prog,0

d‚f_infos_outil
 dc.w g_box
 dc.w 105,000,051-1,008,0,0	La case avec le nom de l'outil utilis‚...
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,texte_infos_outil

d‚f_infos_couleur_3
 dc.w g_box
 dc.w 156,000,010-1,008,0,0	La case qui contient la couleur moyenne...
d‚f_infos_couleur_3_rvb
 code_rvb 0,0,0			Noir
 dc.w color‚
 dc.l no_prog,0

d‚f_infos_effet
 dc.w g_box
 dc.w 166,000,051-1,008,0,0	La case avec le nom de l'effet appliqu‚
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,texte_infos_effet

d‚f_infos_image
 dc.w g_box
 dc.w 217,000,051-1,008,0,0	La case avec le nom de l'image
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,texte_infos_image

d‚f_infos_m‚moire
 dc.w g_box
 dc.w 268,000,031-1,008,0,0	La case avec la m‚moire libre...
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,texte_infos_m‚moire

d‚f_infos_heure
 dc.w g_box
 dc.w 299,000,021-1,008,0,0	La case avec l'heure
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,texte_infos_heure

 dc.w -1
 
* Format des chaines de caractŠre:
* .w (Offset X)
* .w (Offset Y)
* .w (Couleur d'affichage)

texte_infos_scrolling
 dc.w 1,1,0
texte_infos_scrolling_nom
 dc.b "",0
 even

texte_infos_outil
 dc.w 1,1
 code_rvb 0,0,31
texte_infos_outil_nom
 dc.b "CRAYON  ",0
 even

texte_infos_effet
 dc.w 1,1
 code_rvb 0,0,31
texte_infos_effet_nom
 dc.b "REMPLACE",0
 even

texte_infos_image
 dc.w 1,1
 code_rvb 31,28,0		Un espŠce de orange ‚trange...
texte_infos_image_nom
 dc.b "JURASSIC",0
 even

texte_infos_m‚moire
 dc.w 1,1
 code_rvb 15,31,15
 dc.b "23ko",0
 even

texte_infos_heure
 dc.w 1,1
 code_rvb 15,31,15
 dc.b "1:1",0
 even

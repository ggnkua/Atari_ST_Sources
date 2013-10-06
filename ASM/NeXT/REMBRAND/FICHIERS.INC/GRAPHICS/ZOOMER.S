; REMBRANDT 3.0 - ½  Dbug II
;
; Module d'affichage du zoomer temps r‚el. (1.2)
;
; - Segmentable avec la touche [*]
; - Taille variable avec [-] et [+]
; - Centr‚e sur le curseur de la souris (Indicateur de point central)
;
; - Le zoomer doit etre d‚pla‡able [CONTROL]
; - Ne doit pas afficher ce qui ne fait pas partie de l'image
; - Doit indiquer par la couleur du cadre la couleur courante.
; - Ne doit pas se confondre avec le fonds de l'‚cran.
; - Ne doit pas interf‚rer avec les autres outils
; - Ne doit pas gener les formulaires et la s‚lection des couleurs

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc


 TEXT

affiche_le_zoomer
 movem.l d0-a6,-(sp)
 tst.b flag_affiche_zoomer
 beq.s .no_zoom
 tst.b flag_calcule_zoomer
 beq.s .no_zoom

 move.l compteur_vbl,d0
 cmp.l compteur_vbl_zoomer,d0
 beq.s .no_zoom
 move.l d0,compteur_vbl_zoomer

* iif cpu_time  move.l #$ff000000,$ffff9800.w
 lea liste_routines_zoom,a6	Adresse des routines de zoom
 move taille_grossissement,d0
 lea (a6,d0.w*8),a6		Pointe sur la taille qui correspond
 move.b flag_zoomer_segment‚e,d0
 beq.s .ex‚cute_routine
 addq #4,a6			Passe en mode segment‚...
.ex‚cute_routine
 jsr ([a6]) 
* iif cpu_time  move.l #0,$ffff9800.w
.no_zoom
;
; On teste … tout hasard si l'on effectue un changement de taille
; du zoomer (Appui sur les touches '*' '-' ou '+').
;
 tst.b flag_touche_press‚e
 beq.s .pas_touche_press‚e
 move code_scan_118,d0
 moveq #0,d1
 move.b ([table_normale],d0.w),d1

 cmp #'*',d1
 bne.s .pas_segmentation
 bsr.l modifie_segmentation_zoomer 
 sf flag_touche_press‚e
.pas_segmentation
 cmp #'-',d1
 bne.s .pas_diminution
 bsr.l diminue_zoom_zoomer
 sf flag_touche_press‚e
.pas_diminution
 cmp #'+',d1
 bne.s .pas_augmentation
 bsr.l augmente_zoom_zoomer
 sf flag_touche_press‚e
.pas_augmentation

.pas_touche_press‚e

 movem.l (sp)+,d0-a6
 rts


;1->Largeur
;2->Hauteur
;3->Nombre de pixels de grossissement
;4->0/1 -> Grille / pas grille
;
; d7=couleur de la grille
; d6=offset sur la ligne suivante
;
ex‚cute_zoom_2 macro 
 move couleur_grille,d7
 move largeur_visible,d6
 move hauteur_visible,d5
 sub position_hbl,d5
 sub #8,d5
   
 move.l ‚cran,a0
 move mousex,d0
 sub #\1/2,d0
 lea (a0,d0.w*2),a0
 move mousey,d0
 move d5,d1
 divu #3,d1
 lsr d1
 and.l #$ffff,d1
 sub d1,d0
 muls largeur_‚cran,d0
 add.l d0,a0

 move.l adresse_zoomer,a1
 move d6,d0
 mulu #10,d0
 lea (2,a1,d0.l),a1
 pea (a1)

 move d5,d1
 divu #3,d1
 moveq #3,d1		**** Fuck !
.recopie_zoomer_y
 move.l a0,a2
 move.l a1,a3
 lea (a3,d6.w),a4
 lea (a4,d6.w),a5
  
 moveq #\1/2-1,d0
.recopie_zoomer_x
 move (a2)+,d2
 rept 3
 move d2,(a3)+
 move d2,(a4)+
 move d2,(a5)+
 endr
 move (a2)+,d2
 rept 3
 move d2,(a3)+
 move d2,(a4)+
 move d2,(a5)+
 endr
 dbra d0,.recopie_zoomer_x
 lea (a1,d6.w*2),a1
 add d6,a1
 add largeur_‚cran,a0
 dbra d1,.recopie_zoomer_y   

 move.l (sp)+,a1
; move d5,d1
; divu #3,d1
; lsr d1
; and.l #$ffff,d1
; mulu #3,d1
; move d1,d0
; subq #1,d0
; mulu d6,d0		mulu largeur_‚cran,d0
; subq #2,d0
; add.l d0,a1
; add #\3*(\1/2)*2,a1	Carr‚ du centre
; not (a1)		Rang‚e du haut
; not 2(a1)  
; ifeq \4
;var set 2*\3
; else
;var set 2*\3-2
; endc
 
; not var(a1)  
; not var+2(a1)  
; add d6,a1		add largeur_‚cran,a1
; not (a1)
; not var+2(a1)
; move d6,d0		move largeur_‚cran,d0
; ifeq \4
;   mulu #\3-1,d0
; else
;   mulu #\3-1-1,d0
; endc
; add.l d0,a1
; not (a1)
; not var+2(a1)
; add d6,a1		add largeur_‚cran,a1
; not (a1)		Rang‚e du bas
; not 2(a1)  
; not var(a1)  
; not var+2(a1)  
 endm



ex‚cute_zoom macro 
 move couleur_grille,d7
 move largeur_visible,d6
  
 move.l ‚cran,a0
 move mousex,d0
 sub #\1/2,d0
 lea (a0,d0.w*2),a0
 move mousey,d0
 sub #\2/2,d0
 muls largeur_‚cran,d0
 add.l d0,a0
 
 move.l adresse_zoomer,a1
 move d6,d0		 move largeur_visible,d0
 mulu #10,d0
 lea (2,a1,d0.l),a1
 pea (a1)
  
 moveq #\2-1,d1
.recopie_zoomer_y
 ifeq \4
   moveq #\3-1,d3
 else
   moveq #\3-1-1,d3
 endc
.duplique_verticalement

 move.l a0,a2
 move.l a1,a3
 
 moveq #\1-1,d0
.recopie_zoomer_x
 move (a2)+,d2			R‚cupŠre la couleur … dupliquer...
 ifeq \4
   rept \3
   move d2,(a3)+
   endr
 else
  rept \3-1
  move d2,(a3)+
  endr
  move d7,(a3)+
 endc
 dbra d0,.recopie_zoomer_x
 add d6,a1			add largeur_‚cran,a1
 dbra d3,.duplique_verticalement
****
 ifne \4
   move.l a1,a3
   move d7,(a3)+
   move #\1*\3-1-1,d0
.recopie_bande_noire
   move d7,(a3)+
   dbra d0,.recopie_bande_noire
   add d6,a1
 endc
 add largeur_‚cran,a0
 dbra d1,.recopie_zoomer_y   

 move.l (sp)+,a1
 move #\3*(\2/2),d0
 subq #1,d0
 mulu d6,d0		mulu largeur_‚cran,d0
 subq #2,d0
 add.l d0,a1
 add #\3*(\1/2)*2,a1	Carr‚ du centre
 not (a1)		Rang‚e du haut
 not 2(a1)  
 ifeq \4
var set 2*\3
 else
var set 2*\3-2
 endc
 
 not var(a1)  
 not var+2(a1)  
 add d6,a1		add largeur_‚cran,a1
 not (a1)
 not var+2(a1)
 move d6,d0		move largeur_‚cran,d0
 ifeq \4
   mulu #\3-1,d0
 else
   mulu #\3-1-1,d0
 endc
 add.l d0,a1
 not (a1)
 not var+2(a1)
 add d6,a1		add largeur_‚cran,a1
 not (a1)		Rang‚e du bas
 not 2(a1)  
 not var(a1)  
 not var+2(a1)  
 endm





liste_routines_zoom
 dc.l zoom_x3_non_segment‚	0
 dc.l zoom_x3_segment‚
 dc.l zoom_x4_non_segment‚	1
 dc.l zoom_x4_segment‚
 dc.l zoom_x5_non_segment‚	2
 dc.l zoom_x5_segment‚
 dc.l zoom_x6_non_segment‚	3
 dc.l zoom_x6_segment‚
 dc.l zoom_x8_non_segment‚	4
 dc.l zoom_x8_segment‚
 dc.l zoom_x10_non_segment‚	5
 dc.l zoom_x10_segment‚
 dc.l zoom_x15_non_segment‚	6
 dc.l zoom_x15_segment‚


zoom_x3_non_segment‚
 ex‚cute_zoom 66,29,3,0
 rts
zoom_x3_segment‚
 ex‚cute_zoom 66,29,3,1
 rts

zoom_x4_non_segment‚
 ex‚cute_zoom 50,22,4,0
 rts
zoom_x4_segment‚
 ex‚cute_zoom 50,22,4,1
 rts

zoom_x5_non_segment‚
 ex‚cute_zoom 40,17,5,0
 rts
zoom_x5_segment‚
 ex‚cute_zoom 40,17,5,1
 rts

zoom_x6_non_segment‚
 ex‚cute_zoom 33,14,6,0
 rts
zoom_x6_segment‚
 ex‚cute_zoom 33,14,6,1
 rts

zoom_x8_non_segment‚
 ex‚cute_zoom 25,11,8,0
 rts
zoom_x8_segment‚
 ex‚cute_zoom 25,11,8,1
 rts

zoom_x10_non_segment‚
 ex‚cute_zoom 20,8,10,0
 rts
zoom_x10_segment‚
 ex‚cute_zoom 20,8,10,1
 rts

zoom_x15_non_segment‚
 ex‚cute_zoom 13,5,15,0
 rts
zoom_x15_segment‚
 ex‚cute_zoom 13,5,15,1
 rts





modifie_segmentation_zoomer 
 bsr vsync
 not.b flag_zoomer_segment‚e
 relache
 rts

diminue_zoom_zoomer
 st flag_affiche_zoomer
 tst taille_grossissement
 beq .fin_diminution
 bsr vsync
 subq #1,taille_grossissement
 bsr efface_fonds_zoomer
.fin_diminution
 relache
 rts

augmente_zoom_zoomer
 st flag_affiche_zoomer
 cmp #6,taille_grossissement
 beq .fin_augmentation
 bsr vsync
 addq #1,taille_grossissement
 bsr efface_fonds_zoomer
.fin_augmentation
 relache
 rts



   
cache_zoomer_s‚lecteur 
 move.b flag_affiche_zoomer,flag_remettre_zoomer
 tst.b flag_affiche_zoomer			Effacer le zoomer si active.
 beq.s .pas_de_zoomer
 sf flag_affiche_zoomer
 bsr initialise_zoomer
.pas_de_zoomer
 rts

montre_zoomer_s‚lecteur
 tst.b flag_remettre_zoomer			Effacer le zoomer si active.
 beq.s .pas_remettre_de_zoomer
 bsr affiche_infos
.pas_remettre_de_zoomer
 rts



affiche_infos
 relache
 not.b flag_affiche_zoomer
 beq.s .fin_infos
 bsr s‚lecteur_informations
.fin_infos
 rts



initialise_zoomer
 move.l adresse_zoomer,a0
 moveq #0,d7
 move.l #(640*200)/4,d0
.efface_zoomer
 move.l d7,(a0)+
 subq.l #1,d0
 bne.s .efface_zoomer

 move largeur_visible,d7
 move.l adresse_zoomer,a0
 add d7,a0
 lea (a0,d7.w*8),a1
 move.l a1,a3
 move d7,d6
 move d7,d0
 lsr #2,d0
 subq #1,d0
.trace_lignes_info
 move.l #-1,(a0)+
 move.l #-1,(a1)+
 dbra d0,.trace_lignes_info

 move #90-1,d0
.trace_ligne_verticales
 move #-1,(a3)
 move #-1,(402,a3)
 add d7,a3
 dbra d0,.trace_ligne_verticales
; bsr affiche_256_couleurs
 rts

efface_fonds_zoomer
 moveq #0,d7
 move largeur_visible,d6
 move.l adresse_zoomer,a0
 move d6,d0
 mulu #10,d0
 lea (2,a0,d0.l),a0
 move #89-1,d0
.efface_ligne
 move.l a0,a1
 add d6,a0
 move #400/4-1,d1
.efface_rang‚e
 move.l d7,(a1)+
 dbra d1,.efface_rang‚e
 dbra d0,.efface_ligne
 rts

;
; Signification de la variable TYPE_INFO_ZOOMER
;
; 0) Trac‚ simple, pointage, etc... C'est le mode par d‚faut
;    (mousex,mousey) >>
; 
; 1) Trac‚ de rectangles, d‚coupe de blocs, etc...
;    (x2,y2)-(x1,y1)=[largeur,hauteur] >>
;
; 2) Trac‚ de cercles, a‚rosol, etc...
;    (mousex,mousey)=[rayon] >>
;
; 3) Trac‚ d'ellipses, etc...
;    (mousex,mousey)=[rayonx,rayony]
;
affiche_informations
 move.l adresse_zoomer,a1
 add.l #2*10,a1
 move largeur_visible,d7
 lea (a1,d7.w*2),a1
 lea (a1,d7.w),a1

 lea texte_zoomer,a0
 move.l #$0f0f0f0f,(a0)+	Commence par mettre des espaces partout...
 move.l #$0f0f0f0f,(a0)+
 move.w #$0fff,(a0)+
 
 lea texte_zoomer,a0
 move mousex,d0
 ext.l d0
 bsr inscrit_chaine_3x5
 move.b #13,(a0)+	®13¯ = ®:¯
 move mousey,d0
 ext.l d0
 bsr inscrit_chaine_3x5
 move.b #15,(a0)+		Un espace final

 move.b #-1,texte_zoomer+9
 
 add #4,a1
 move #$ffff,d7		Couleur d'affichage
 bsr affiche_3x5 
 rts



affiche_3x5 
 lea texte_zoomer,a0
 lea fonte_3x5,a2
.lettre_suivante
 moveq #0,d0
 move.b (a0)+,d0 	Prends le code ASCII du caractŠre
 bmi .fin_infos		si 0, termin‚
 mulu #30,d0
 lea (a2,d0.w),a4	Adresse du caractŠre d‚sir‚
 move.l a1,a5		Adresse d'affichage du caractŠre
 moveq #5-1,d0
.affiche_lettre

 move #16<<11+32<<5+16,d2
 move (a4)+,d3
 beq .affiche_pas_pixel_1
 and d7,d3
 move d3,d2
.affiche_pas_pixel_1
 move d2,(a5)

 move #16<<11+32<<5+16,d2
 move (a4)+,d3
 beq .affiche_pas_pixel_2
 and d7,d3
 move d3,d2
.affiche_pas_pixel_2
 move d2,2(a5)

 move #16<<11+32<<5+16,d2
 move (a4)+,d3
 beq .affiche_pas_pixel_3
 and d7,d3
 move d3,d2
.affiche_pas_pixel_3
 move d2,4(a5)

 add largeur_visible,a5
 dbra d0,.affiche_lettre 
 addq #8,a1
 bra .lettre_suivante

.fin_infos
 rts

 

 move.b #'¯',d0
 tst.b vitesse_souris
 beq.s .vitesse_lente
 move.b #'>',d0
.vitesse_lente
 move.b d0,(a0)+

 move.b #-1,(a0)+			Affiche la valeur en blanc
 move.w #31<<11+63<<5+31,(a0)+	

 move mousex,d0
 ext.l d0
 bsr inscrit_chaine
 move.b #',',(a0)+
 move mousey,d0
 ext.l d0
 bsr inscrit_chaine

 move.b #' ',(a0)+
 clr.b (a0)+			Inscrit la chaine
 lea texte_zoomer,a0
 move.l adresse_zoomer,a1
 add.l #2*10,a1
 move largeur_‚cran,-(sp)
 move largeur_visible,d7
 move d7,largeur_‚cran
 lea (a1,d7.w*2),a1
 lea (a1,d7.w),a1
 bsr affiche_chaine_texte 
 move (sp)+,largeur_‚cran
 rts

 
 BSS

type_info_zoomer	ds.w 1
type_info_outil		ds.w 1

compteur_vbl_zoomer	ds.l 1

flag_zoomer_segment‚e	ds.w 1
taille_grossissement	ds.w 1 

couleur_grille		ds.w 1

adresse_zoomer		ds.l 1
texte_zoomer		ds.b 80
buffer_zoomer		ds.l (640*200)/4+1	De quoi faire tenir du 320x100 !

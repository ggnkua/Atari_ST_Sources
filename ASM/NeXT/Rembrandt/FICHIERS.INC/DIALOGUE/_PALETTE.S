; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion des couleurs. (1.1)
;
; - Impl‚mentation des couleurs RVB [reste CMJ et HSV]
; - Copie de couleur avec le bouton gauche
; [- Pr‚voir le d‚grad‚ automatique avec le bouton droit]

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 section TEXT

s‚lecteur_de_couleur
 move.l ‚cran,‚cran_s‚l
 move largeur_‚cran,largeur_‚cran_s‚l

 bsr cache_zoomer_s‚lecteur
 bsr recopie_‚cran
  
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_flŠche,adresse_curseur
 
 move.l #d‚f_s‚lecteur,adresse_ressource
 sf flag_ferme_formulaire

 bsr calcule_minimax

 bsr centre_s‚lecteur

 bsr vsync
 bsr initialise_s‚lecteur

 bsr d‚code_ressource

 relache
 
 bsr gŠre_s‚lecteur

 bsr efface_s‚lecteur

 jsr vide_clavier

 move d‚f_couleur_‚dit‚e+objet_couleur,couleur
 move.l sauvegarde_curseur,adresse_curseur
 bsr colorie_curseur

 bsr s‚lecteur_informations		Met … jour la barre d'infos...
 bsr montre_zoomer_s‚lecteur
 rts
 
routine_pique_couleur
 move.l ‚cran,a0
 add mousex,a0
 add mousex,a0
 move mousey,d0
 mulu largeur_‚cran,d0
 add.l d0,a0

 move (a0),d‚f_couleur_‚dit‚e+objet_couleur

 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu
 lea d‚but_cases,a0			R‚affiche le d‚grad‚ TrueColor
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 rts
  
initialise_s‚lecteur
 move couleur,d‚f_couleur_‚dit‚e+objet_couleur
 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu
 lea d‚but_cases,a0			R‚affiche le d‚grad‚ TrueColor
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 rts


; Routine G_USER_DEF.
; A0-> Pointe sur l'‚l‚ment courant
; A1-> Position ‚cran (int‚rieure)
;
affiche_palette_standard
 movem.l d0-a6,-(sp)

 move.l a1,a3
 
 move d‚f_couleur_‚dit‚e+objet_couleur,d5
 and #31,d5		Bleu
 moveq #64-1,d7		Vert
.recopie_couleurs_y
 move d5,d4

 move.l a1,a2
 moveq #32-1,d6		Rouge
.recopie_couleurs_x
 move d4,(a2)+
 move d4,(a2)+
 add #1<<11,d4		Incr‚mente le rouge
 dbra d6,.recopie_couleurs_x
 add largeur_‚cran,a1
 add #1<<5,d5		Incr‚mente le vert
 dbra d7,.recopie_couleurs_y

 move d‚f_couleur_‚dit‚e+objet_couleur,d0
 move d0,d1
 lsr #5,d0
 and #%111111,d0
 rol #5,d1
 and #%11111,d1
 mulu largeur_‚cran,d0
 move.l a3,a1
 add.l d0,a1
 neg.l (a1,d1.w*4)

 movem.l (sp)+,d0-a6
 rts

fuckkkk
******* C'est la routine qui affiche les 256 teintes de la palette
 movem.l d0-a6,-(sp)
 move largeur_‚cran,d1
 move d1,d2
 mulu #5,d2
 lea couleurs_palette,a0
 moveq #16-1,d7
.recopie_couleurs_y
 move.l a1,a2
 moveq #16-1,d6
.recopie_couleurs_x
 move (a0)+,d0
 move.l a2,a3
 moveq #5-1,d5
.duplique_couleur_y
 move d0,(a3)
 move d0,2(a3)
 move d0,4(a3)
 move d0,6(a3)
 move d0,8(a3)
 add d1,a3
 dbra d5,.duplique_couleur_y
 lea 5*2(a2),a2
 dbra d6,.recopie_couleurs_x
 add d2,a1
 dbra d7,.recopie_couleurs_y
 movem.l (sp)+,d0-a6
 rts


affiche_glissiŠre_rouge
 movem.l d0-a6,-(sp)
 move.l #31<<16,d0
 move.l #00<<16,d1
 move.l #00<<16,d2
 bra affiche_glissiŠre_d‚grad‚e
 
affiche_glissiŠre_vert
 movem.l d0-a6,-(sp)
 move.l #00<<16,d0
 move.l #63<<16,d1
 move.l #00<<16,d2
 bra affiche_glissiŠre_d‚grad‚e

affiche_glissiŠre_bleu
 movem.l d0-a6,-(sp)
 move.l #00<<16,d0
 move.l #00<<16,d1
 move.l #31<<16,d2
 bra affiche_glissiŠre_d‚grad‚e

affiche_glissiŠre_opacit‚
 movem.l d0-a6,-(sp)
 move.l #31<<16,d0
 move.l #63<<16,d1
 move.l #31<<16,d2
 bra affiche_glissiŠre_d‚grad‚e

affiche_glissiŠre_cyan
 movem.l d0-a6,-(sp)
 move.l #00<<16,d0
 move.l #63<<16,d1
 move.l #31<<16,d2
 bra affiche_glissiŠre_d‚grad‚e
 
affiche_glissiŠre_magenta
 movem.l d0-a6,-(sp)
 move.l #31<<16,d0
 move.l #00<<16,d1
 move.l #31<<16,d2
 bra affiche_glissiŠre_d‚grad‚e

affiche_glissiŠre_jaune
 movem.l d0-a6,-(sp)
 move.l #31<<16,d0
 move.l #63<<16,d1
 move.l #00<<16,d2
 bra affiche_glissiŠre_d‚grad‚e



affiche_glissiŠre_d‚grad‚e
 moveq #0,d7
 move hauteur_int‚rieure,d7

 move.l d0,d3			Composante ROUGE
 divs.l d7,d0			-> D‚cr‚ment sur la couleur

 move.l d1,d4			Composante VERT
 divs.l d7,d1			-> D‚cr‚ment sur la couleur

 move.l d2,d5			Composante BLEUE
 divs.l d7,d2			-> D‚cr‚ment sur la couleur

 subq #1,d7
.trace_curseur_y
 move.l a1,a2

 move.l d3,d6			Prend le rouge
 lsr.l #5,d6
 and #%1111100000000000,d6
 move d6,a3

 move.l d4,d6			Prend le vert
 swap d6
 lsl #5,d6
 and #%0000011111100000,d6
 add d6,a3

 move.l d5,d6			Prend le vert
 swap d6
 and #%0000000000011111,d6
 add d6,a3

 move largeur_int‚rieure,d6
 subq #1,d6
.trace_curseur_x
 move a3,(a2)+
 dbra d6,.trace_curseur_x
 add largeur_‚cran,a1
 sub.l d0,d3
 sub.l d1,d4
 sub.l d2,d5
 dbra d7,.trace_curseur_y
 movem.l (sp)+,d0-a6
 rts 


routine_incr‚mente_opacit‚
routine_d‚cr‚mente_opacit‚
routine_curseur_opacit‚
 rts

maximum_curseur		ds.w 1
d‚callage_composante	ds.w 1
masque_composante	ds.w 1
adresse_potar		ds.l 1

initialise_rouge
 move.l #d‚f_curseur_rouge,adresse_potar
 move #31,maximum_curseur
 move #11,d‚callage_composante
 move #%0000011111111111,masque_composante
 rts

initialise_vert
 move.l #d‚f_curseur_vert,adresse_potar
 move #63,maximum_curseur
 move #5,d‚callage_composante
 move #%1111100000011111,masque_composante
 rts

initialise_bleu
 move.l #d‚f_curseur_bleu,adresse_potar
 move #31,maximum_curseur
 move #0,d‚callage_composante
 move #%1111111111100000,masque_composante
 rts
   
routine_curseur_rouge
 bsr initialise_rouge
 bra gŠre_curseur

routine_curseur_vert
 bsr initialise_vert
 bra gŠre_curseur

routine_curseur_bleu
 bsr initialise_bleu
 bra gŠre_curseur

 
gŠre_curseur
 move mousey,click_y

 move d‚f_couleur_‚dit‚e+objet_couleur,d0		R‚cupŠre la couleur ant‚rieure
 move d0,d6			Couleur initiale
 and masque_composante,d6
 move d‚callage_composante,d1
 lsr d1,d0
 and maximum_curseur,d0
 move d0,d7			La composante est isol‚e
 
.loop   
 bsr vsync
 getmouse
 tst mousek
 beq .end_loop

 move click_y,d0		Position de d‚part
 sub mousey,d0			- Position de la souris
 cmp #63,maximum_curseur
 beq .pas_r‚duction
 asr d0
.pas_r‚duction

 add d7,d0			Ajoute la composante initiale
 tst d0				On est n‚gatif ???
 bpl.s .pas_neg
 moveq #0,d0
.pas_neg
 cmp maximum_curseur,d0		Alors on d‚passe ???
 ble.s .pas_max
 move maximum_curseur,d0
.pas_max

 move d‚callage_composante,d1
 lsl d1,d0					R‚cupŠre la bonne valeur 
 add d6,d0					Couleur initiale sans la composante
 move d0,d‚f_couleur_‚dit‚e+objet_couleur
  
 move #0,sens
 movem.l d0-a6,-(sp)
 bsr modifie_couleur
 movem.l (sp)+,d0-a6
 
 bra .loop
.end_loop 
 relache
 rts

* Valeurs de la variable ®SENS¯
*
* -2 = Met au maximum
* -1 = Incr‚mente
*  0 = Positionne
*  1 = D‚cr‚mente
*  2 = Met … 0

routine_incr‚mente_rouge      
 bsr initialise_rouge
 getshift
 and #%11,d0
 bne.s .ok_max
 move #-1,sens
 cmp #2,mousek
 bne .pas_max
.ok_max
 move #-2,sens
.pas_max 
 moveq #3,d0
 bsr tempo
 bra modifie_couleur

  
routine_d‚cr‚mente_rouge      
 bsr initialise_rouge
 getshift
 and #%11,d0
 bne.s .ok_min
 move #1,sens
 cmp #2,mousek
 bne .pas_min
.ok_min
 move #2,sens
.pas_min
 moveq #3,d0
 bsr tempo
 bra modifie_couleur

routine_positionne_rouge
 bsr initialise_rouge
 move #0,sens
 bra modifie_couleur

routine_incr‚mente_vert      
 bsr initialise_vert
 getshift
 and #%11,d0
 bne.s .ok_max
 move #-1,sens
 cmp #2,mousek
 bne .pas_max
.ok_max
 move #-2,sens
.pas_max 
 moveq #3,d0
 bsr tempo
 bra modifie_couleur
 
routine_d‚cr‚mente_vert      
 bsr initialise_vert
 getshift
 and #%11,d0
 bne.s .ok_min
 move #1,sens
 cmp #2,mousek
 bne .pas_min
.ok_min
 move #2,sens
.pas_min
 moveq #3,d0
 bsr tempo

 bra modifie_couleur

routine_positionne_vert
 bsr initialise_vert
 move #0,sens
 bra modifie_couleur

routine_incr‚mente_bleu      
 bsr initialise_bleu
 getshift
 and #%11,d0
 bne.s .ok_max
 move #-1,sens
 cmp #2,mousek
 bne .pas_max
.ok_max
 move #-2,sens
.pas_max 
 moveq #3,d0
 bsr tempo
 bra modifie_couleur
 
routine_d‚cr‚mente_bleu      
 bsr initialise_bleu
 getshift
 and #%11,d0
 bne.s .ok_min
 move #1,sens
 cmp #2,mousek
 bne .pas_min
.ok_min
 move #2,sens
.pas_min
 moveq #3,d0
 bsr tempo
 bra modifie_couleur

routine_positionne_bleu
 bsr initialise_bleu
 move #0,sens
 bra modifie_couleur
 
sens	dc.w 0
 
modifie_couleur
 move d‚f_couleur_‚dit‚e+objet_couleur,d0
 move d0,d6
 and masque_composante,d6	Couleur masqu‚e
 move d‚callage_composante,d1
 lsr d1,d0
 and maximum_curseur,d0		Composante isol‚e

 tst sens
 beq continue_modif_couleur
 bmi .monte_curseur

.descend_curseur 
 cmp #2,sens
 beq .curseur_minimum
 tst d0
 beq continue_modif_couleur
 subq #1,d0
 bra continue_modif_couleur

.curseur_minimum
 moveq #0,d0
 bra continue_modif_couleur

.monte_curseur
 cmp #-2,sens
 beq .curseur_maximum
 cmp maximum_curseur,d0
 beq continue_modif_couleur
 addq #1,d0
 bra continue_modif_couleur

.curseur_maximum
 move maximum_curseur,d0
 bra continue_modif_couleur
 
continue_modif_couleur
 move d0,d7

 move d‚callage_composante,d1
 lsl d1,d7				R‚cupŠre la bonne valeur 
 add d6,d7				Couleur initiale sans la composante
 move d7,d‚f_couleur_‚dit‚e+objet_couleur
 
 lea d‚f_couleur_‚dit‚e,a0		Change la couleur de la case
 bsr calcule_xy_‚l‚ment			de la couleur ‚dit‚e.
 bsr affichage_‚l‚ment

 lea d‚but_cases,a0			R‚affiche le d‚grad‚ TrueColor
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 bsr vsync
****
 move d0,d7			Intensit‚ de la teinte rouge
 cmp #63,maximum_curseur
 beq .pas_augmentation
 add d7,d7
.pas_augmentation

 moveq #64,d6
 sub d7,d6
 move.l adresse_potar,a0
 add objet_y-longueur_d‚f(a0),d6		Position de la glissiŠre
 move d6,objet_y(a0)
 
 move d0,d7
 lsl d1,d7
 bsr change_format_couleur
 move d7,objet_couleur(a0)	Couleur du curseur

 move d0,d1
 bsr inscrit_valeur_curseur	Affiche D1 en un nombre ASCII (00-99)
  
 lea -longueur_d‚f(a0),a0
 bsr calcule_xy_‚l‚ment		R‚affiche la glissiŠre du curseur
 bsr affichage_‚l‚ment

 lea longueur_d‚f(a0),a0
 bsr calcule_xy_‚l‚ment		R‚affiche le curseur lui-meme
 bsr affichage_‚l‚ment

****
 rts

change_format_couleur
 movem d0-d2,-(sp)
 tst mode_visu
 beq.s .pas_changement 
.change_cmj
; move d7,d0
; and #%1111100000000000,d0
; rol #5,d0
; move d7,d1
; and #%0000011111100000,d1
; lsr #5,d1
; move d7,d2
; and #%0000000000011111,d2
;
; D0=ROUGE [0-31]
; D1=VERT  [0-63]
; D2=BLEU  [0-31]
;
 moveq #-1,d0
 sub d7,d0
 move d0,d7   
.pas_changement 
 movem (sp)+,d0-d2
 rts
 
*
* Change l'inscription qui apparait sur le curseur selon l'intensit‚
* 
inscrit_valeur_curseur
 movem.l d0-a6,-(sp)
 move d1,d2
 and.l #$ff,d2
 move.l d2,d0
 move.l objet_texte(a0),a1	Adresse du bloc de texte
 lea objet_texte_message(a1),a1	Adresse de la chaine de texte
 divu #10,d0
 move d0,d3
 add #'0',d3
 move.b d3,(a1)+
 mulu #10,d0
 sub d0,d2
 add #'0',d2
 move.b d2,(a1)+
 movem.l (sp)+,d0-a6
 rts


;%
;% Fonctionnement des cases de couleur.
;% - Clic bouton gauche: Prends la couleur pour l'‚diter
;%
routine_s‚lectionne_couleur
 bsr calcule_xy_‚l‚ment
 movem.l d0-a6,-(sp)
 move.l ‚cran,a6
 move mousex,d0
 lea (a6,d0.w*2),a6
 move mousey,d0 
 mulu largeur_‚cran,d0
 add.l d0,a6

 move (a6),d‚f_couleur_‚dit‚e+objet_couleur
 
 movem.l (sp)+,d0-a6
 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu
 lea d‚but_cases,a0			R‚affiche le d‚grad‚ TrueColor
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
* relache
 rts


mode_visu	dc.w 0	(0=RVB/1=CMJ/2=ROUE/3=GRIS)

;#
;# Visualisation en mode RVB/RGB
;# Les composantes primaires sont le ROUGE, le VERT, et le BLEU.
;# Si les trois composantes sont … saturation minimale, on a du noir.
;# Inversement, une saturation extrŠme donne du blanc.
;#
;# Les couleurs pour les curseurs sont:
;# ROUGE: 20/28/14
;# VERT:  14/40/14
;# BLEU:  14/28/20
;#

routine_choisie_rvb
 tst mode_visu
 beq .fin_rvb
 bsr d‚s‚lectionne_mode_visu
 lea d‚f_bouton_rvb,a0
 move #ROUGE100,objet_couleur(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_glissiŠre_rouge,a0
 move.l #affiche_glissiŠre_rouge,([objet_texte,a0],2)
 lea d‚f_glissiŠre_vert,a0
 move.l #affiche_glissiŠre_vert,([objet_texte,a0],2)
 lea d‚f_glissiŠre_bleu,a0
 move.l #affiche_glissiŠre_bleu,([objet_texte,a0],2)

 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu
 lea d‚but_cases,a0			R‚affiche le d‚grad‚ TrueColor
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 move #0,mode_visu
 relache
.fin_rvb
 rts

;#
;# Visualisation en mode CMJ/CMY
;# Les composantes primaires sont le CYAN, le MAGENTA, et le JAUNE.
;# Si les trois composantes sont … saturation minimale, on a du blanc.
;# Inversement, une saturation extrŠme donne du noir.
;#			 14/20 - 28/40
;# Les couleurs pour les curseurs sont:
;# CYAN (Bleu+Vert):      14/40/20
;# MAGENTA (Rouge+Bleu):  20/28/20
;# JAUNE (Rouge+Vert):    20/40/14
;#
   
routine_choisie_cmj
 cmp #1,mode_visu
 beq .fin_cmj
 bsr d‚s‚lectionne_mode_visu
 lea d‚f_bouton_cmj,a0
 move #ROUGE100,objet_couleur(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_glissiŠre_rouge,a0
 move.l #affiche_glissiŠre_cyan,([objet_texte,a0],2)
 lea d‚f_glissiŠre_vert,a0
 move.l #affiche_glissiŠre_magenta,([objet_texte,a0],2)
 lea d‚f_glissiŠre_bleu,a0
 move.l #affiche_glissiŠre_jaune,([objet_texte,a0],2)

 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu
 lea d‚but_cases,a0			R‚affiche le d‚grad‚ TrueColor
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 move #1,mode_visu
 relache
.fin_cmj
 rts

 
routine_choisie_roue
 cmp #2,mode_visu
 beq .fin_roue
 bsr d‚s‚lectionne_mode_visu
 lea d‚f_bouton_roue,a0
 move #ROUGE100,objet_couleur(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 move #2,mode_visu
 relache
.fin_roue
 rts

routine_choisie_gris
 cmp #3,mode_visu
 beq .fin_gris
 bsr d‚s‚lectionne_mode_visu
 lea d‚f_bouton_gris,a0
 move #ROUGE100,objet_couleur(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 move #3,mode_visu
 relache
.fin_gris
 rts


d‚s‚lectionne_mode_visu
 lea d‚f_bouton_gris,a0
 cmp #3,mode_visu
 beq.s .reset_bouton
 lea d‚f_bouton_roue,a0
 cmp #2,mode_visu
 beq.s .reset_bouton
 lea d‚f_bouton_cmj,a0
 cmp #1,mode_visu
 beq.s .reset_bouton
 lea d‚f_bouton_rvb,a0
.reset_bouton 
 move #GRIS40,objet_couleur(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 rts

routine_fermeture_palette 
 lea d‚f_case_fermeture,a0
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 relache
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 st flag_ferme_formulaire
 rts

 section DATA
 even

icone_mode_rvb		incbin fichiers.inc\icones\mode_rvb.icn
icone_mode_cmj		incbin fichiers.inc\icones\mode_cmj.icn
icone_mode_roue		incbin fichiers.inc\icones\mode_tru.icn
icone_mode_gris		incbin fichiers.inc\icones\mode_gri.icn

couleurs_palette
var set 0
 rept 32		Noir -> Blanc
 code_rvb var,var,var
var set var+1
 endr
 rept 32		Blanc -> Jaune
var set var-1
 code_rvb 31,31,var
 endr
var set 32
 rept 32		Jaune -> Rouge
var set var-1
 code_rvb 31,var,0
 endr
 rept 32		Rouge -> Violet
 code_rvb 31,0,var
var set var+1
 endr
 rept 32		Violet -> Bleu
var set var-1
 code_rvb var,0,31
 endr
 rept 32		Bleu -> Cyan
 code_rvb 0,var,31
var set var+1
 endr
 rept 32		Cyan -> Vert
var set var-1
 code_rvb 0,31,var
 endr
var set 32
 rept 32		Vert -> Noir
var set var-1
 code_rvb 0,var,0
 endr
 
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

raccourcis_clavier_s‚lecteur
 raccourcis 0,27,d‚f_case_fermeture	®ESCAPE¯
 raccourcis 0,32,d‚f_case_fermeture	®ESPACE¯
 raccourcis $52,0,d‚f_augmente_rouge	®INSERT¯
 raccourcis $4b,0,d‚f_diminue_rouge	®FlŠche gauche¯
 raccourcis $48,0,d‚f_augmente_vert	®FlŠche haut¯
 raccourcis $50,0,d‚f_diminue_vert	®FlŠche bas¯
 raccourcis $47,0,d‚f_augmente_bleu	®Clr Home¯
 raccourcis $4d,0,d‚f_diminue_bleu	®FlŠche droite¯
 dc.w -1

def_‚paisseur	set bord_fin
def_hauteur	set _bomb‚ 
 
 dc.l raccourcis_clavier_s‚lecteur
 dc.l d‚f_titre_cadre
 dc.l routine_pique_couleur
d‚f_s‚lecteur		*Cadre principal
 _box 0,0,113+64,150-10,GRIS50,neutre,no_prog

d‚f_case_fermeture	*Case de fermeture en haut … gauche
 _boxtext 1,1,10,10,VERT50,color‚,routine_fermeture_palette,texte_case_fermeture	

d‚f_titre_cadre		*Barre de titre d‚pla‡able
 _boxtext 13,1,163,10,VERT50,color‚,routine_d‚place_cadre,texte_titre_s‚lecteur

			*Partie inf‚rieure grise
 _box 1,13,175,126,GRIS50,neutre,no_prog

d‚f_augmente_rouge	*Bouton ROUGE +
 _boxtext 5,35,18,10,GRIS40,neutre,routine_incr‚mente_rouge,texte_plus_rouge

def_hauteur	set _creu

d‚f_glissiŠre_rouge	*GlissiŠre curseur rouge
 _boxtext 5,47,18,75,GRIS40,neutre,no_prog,texte_glissiŠre_rouge

def_hauteur	set _bomb‚ 

d‚f_curseur_rouge	*Le curseur dans la glissiŠre
 _boxtext 6,48,16,10,ROUGE100,neutre,routine_curseur_rouge,texte_valeur_rouge

d‚f_diminue_rouge	*Bouton ROUGE -
 _boxtext 5,124,18,10,GRIS40,neutre,routine_d‚cr‚mente_rouge,texte_moins_rouge

d‚f_augmente_vert
 _boxtext 27,35,18,10,GRIS40,neutre,routine_incr‚mente_vert,texte_plus_vert

def_hauteur	set _creu
d‚f_glissiŠre_vert
 _boxtext 27,47,18,75,GRIS40,neutre,no_prog,texte_glissiŠre_vert
def_hauteur	set _bomb‚ 

d‚f_curseur_vert
 _boxtext 28,48,16,10,VERT100,neutre,routine_curseur_vert,texte_valeur_vert

d‚f_diminue_vert
 _boxtext 27,124,18,10,GRIS40,neutre,routine_d‚cr‚mente_vert,texte_moins_vert

d‚f_augmente_bleu
 _boxtext 49,35,18,10,GRIS40,neutre,routine_incr‚mente_bleu,texte_plus_bleu
 
def_hauteur	set _creu
d‚f_glissiŠre_bleu
 _boxtext 49,47,18,75,GRIS40,neutre,no_prog,texte_glissiŠre_bleu
def_hauteur	set _bomb‚ 

d‚f_curseur_bleu
 _boxtext 50,48,16,10,BLEU100,neutre,routine_curseur_bleu,texte_valeur_bleu

d‚f_diminue_bleu
 _boxtext 49,124,18,10,GRIS40,neutre,routine_d‚cr‚mente_bleu,texte_moins_bleu

d‚f_augmente_opacit‚
 _boxtext 71,35,18,10,GRIS40,neutre,routine_incr‚mente_opacit‚,texte_plus_opacit‚

def_hauteur	set _creu
d‚f_glissiŠre_opacit‚
 _box 71,47,18,75,GRIS50,color‚,no_prog
def_hauteur	set _bomb‚ 

d‚f_curseur_opaque
 _boxtext 72,48,16,10,GRIS40,neutre,routine_curseur_opacit‚,texte_valeur_opacit‚

d‚f_diminue_opacit‚
 _boxtext 71,124,18,10,GRIS40,neutre,routine_d‚cr‚mente_opacit‚,texte_moins_opacit‚



def_hauteur	set _creu
 _box 005,014,81,17,GRIS40,neutre,no_prog	Un cadre d‚coratif (???)
def_hauteur	set _bomb‚
 
d‚f_bouton_rvb
 _boxtext 006,15,19,15,ROUGE100,color‚,routine_choisie_rvb,texte_icone_rvb

d‚f_bouton_cmj
 _boxtext 26,15,19,15,GRIS40,color‚,routine_choisie_cmj,texte_icone_cmj

d‚f_bouton_roue
 _boxtext 46,15,19,15,GRIS40,color‚,routine_choisie_roue,texte_icone_roue

d‚f_bouton_gris
 _boxtext 66,15,19,15,GRIS40,color‚,routine_choisie_gris,texte_icone_gris


def_hauteur	set _creu
d‚f_couleur_‚dit‚e
 _box 93,118,81,17,ROUGE100,color‚,no_prog

d‚but_cases
 _boxtext 93,35,4*16+1,4*16+1,ROUGE100,neutre,routine_s‚lectionne_couleur,texte_s‚lectionne_couleur
def_hauteur	set _bomb‚
 
 dc.w -1
 
* Format des chaines de caractŠre:
* .w (Offset X)
*   ... Si ‚gal … -1, alors est suivi d'un .L qui est l'adresse d'une
*       routine d'affichage pour l'objet. (G_USER_DEF...)
* .w (Offset Y)
* .w (Couleur d'affichage)
* .b... (Texte … afficher suivi de 0)
*   ... Si ‚gal … 0, alors est suivi d'un .L qui est l'adresse d'un bloc
*       graphique TRUE COLOR au format suivant:
*       .w = Largeur
*       .w = Hauteur
*       .w... Le dessin lui meme.

 even
texte_titre_s‚lecteur
 dc.w 22,2
 code_rvb 31,63,31
 dc.b "PALETTE",0
 even

texte_plus_rouge
 dc.w 6,2
 code_rvb 31,0,0
 dc.b "+",0
 even

texte_moins_rouge
 dc.w 6,2,31*2048
 dc.b "-",0
 even

texte_plus_vert
 dc.w 6,2,63*32
 dc.b "+",0
 even

texte_moins_vert
 dc.w 6,2,63*32
 dc.b "-",0
 even

texte_plus_bleu
 dc.w 6,2,31
 dc.b "+",0
 even

texte_moins_bleu
 dc.w 6,2,31
 dc.b "-",0
 even

texte_plus_opacit‚
 dc.w 6,2,31
 dc.b "+",0
 even

texte_moins_opacit‚
 dc.w 6,2,31
 dc.b "-",0
 even

texte_valeur_rouge
 dc.w 2,2,-1
 dc.b "31",0
 even
 
texte_valeur_vert
 dc.w 2,2,-1
 dc.b "63",0
 even

texte_valeur_bleu
 dc.w 2,2,-1
 dc.b "31",0
 even

texte_valeur_opacit‚
 dc.w 2,2,-1
 dc.b "63",0
 even
 
texte_case_fermeture 
 dc.w 2,2,0
 dc.b "",0
 even

texte_s‚lectionne_couleur
 dc.w -1
 dc.l affiche_palette_standard
 even

texte_glissiŠre_rouge
 dc.w -1
 dc.l affiche_glissiŠre_rouge
 even
texte_glissiŠre_vert
 dc.w -1
 dc.l affiche_glissiŠre_vert
 even
texte_glissiŠre_bleu
 dc.w -1
 dc.l affiche_glissiŠre_bleu
 even
texte_glissiŠre_opacit‚
 dc.w -1
 dc.l affiche_glissiŠre_opacit‚
 even



texte_glissiŠre_cyan
 dc.w -1
 dc.l affiche_glissiŠre_cyan
 even
texte_glissiŠre_magenta
 dc.w -1
 dc.l affiche_glissiŠre_magenta
 even
texte_glissiŠre_jaune
 dc.w -1
 dc.l affiche_glissiŠre_jaune
 even



texte_icone_rvb
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_mode_rvb

texte_icone_cmj
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_mode_cmj

texte_icone_roue
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_mode_roue

texte_icone_gris
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_mode_gris
  
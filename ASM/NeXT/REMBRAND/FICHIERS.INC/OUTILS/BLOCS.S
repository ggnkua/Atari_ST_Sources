;
; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion des blocs. (1.0)
;
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT
 
routine_bloc
 move.l adresse_curseur,-(sp)
 
 move.l #curseur_d‚coupe_bloc,adresse_curseur
 bsr recopie_‚cran
 force_int‚rieur

 move.l mousexy,xy2	et m‚morise pour la suite.

 relache			On attend que le bouton soit relach‚ !

 move #$f0f0,couleur_cycling	Les belles couleurs !!! Pour le cadre qui d‚fille...
 
.boucle_s‚lectionne_zone
 getmouse
 force_int‚rieur
 move.l mousexy,xy1
 bsr teste_shift_equerre

 move #2,type_ligne	On colorie en mode m‚morisation
 bsr trace_cadre_vide
 bsr vsync

 move #1,type_ligne	On redessine avec la bonne couleur
 bsr trace_cadre_vide

 cmp #1,mousek
 beq .valide_loupe
 cmp #2,mousek
 beq .quitte_loupe

 move couleur_cycling,d0
 rol d0
 move d0,couleur_cycling

 bra .boucle_s‚lectionne_zone

.valide_loupe
 relache
 bsr trie_rectangle
* bsr applique_gris
* bsr applique_n‚gatif
 move #110,d3
 bsr applique_lumiŠre
 bsr montre_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 move.l (sp)+,adresse_curseur
 rts

.quitte_loupe
 relache
 move.l (sp)+,adresse_curseur
 rts


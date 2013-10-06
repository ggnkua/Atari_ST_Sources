; REMBRANDT 3.0 - ½  Dbug II
;
; Module outil EQUERRE.  (1.2)
;
; - Trac‚ de cadres vides
; - Trac‚ de cadres pleins en temps r‚el
;
; SHIFT -> Force … tracer un carr‚
; *ALTERNATE -> Inverser les coordonn‚es

 TEXT
 
routine_equerre_cadre
 force_int‚rieur
  
 move.l mousexy,xy2	et m‚morise pour la suite.

 relache		On attend que le bouton soit relach‚ !

 bsr initialise_minimax
 
.cadre_suivant
 getmouse
 force_int‚rieur
 move.l mousexy,xy1
 bsr teste_shift_equerre

 move #0,type_ligne	On colorie en mode m‚morisation
 bsr trace_cadre_vide
 bsr vsync
 bsr attend_mouvement
 cmp #1,mousek
 beq .trace_ce_cadre
 move #1,type_ligne	On redessine avec la bonne couleur
 bsr trace_cadre_vide
 cmp #2,mousek
 beq.s .fin_routine_cadre
 bra .cadre_suivant

.trace_ce_cadre
* move #0,type_ligne	On colorie en couleur... d‚finitive !
* bsr trace_cadre_vide
 move.l xy1,xy2
 st flag_chang‚e
 
.fin_routine_cadre
 relache
 rts


teste_shift_equerre
 getshift
 move d0,d1
 and #%11,d1		Conserve les bits 0 et 1 (SHIFTS)
 beq .pas_shift

 move x2,d0
 sub x1,d0		D0=Largeur (sign‚e)
 move d0,d1
 bpl.s .ok_largeur
 neg d1			D1=|Largeur|
.ok_largeur 

 move y2,d2
 sub y1,d2		D2=Hauteur (sign‚e)
 move d2,d3
 bpl.s .ok_hauteur
 neg d3			D3=|Hauteur|
.ok_hauteur 

 cmp d1,d3
 blt.s .prend_hauteur
 bra.s .prend_largeur
  
.pas_shift
* btst #3,d0		Teste ALTERNATE pour changer le coin de travail.
* beq .pas_alternate
*.attend_relache_alternate
* getshift
* btst #3,d0
* bne .attend_relache_alternate
* move.l xy1,xy2
*.pas_alternate
 rts

.prend_largeur
 move y2,y1
 tst d2			Hauteur n‚gative ?
 bmi.s .hauteur_n‚gative
.hauteur_positive
 sub d1,y1
 rts
.hauteur_n‚gative
 add d1,y1
 rts

.prend_hauteur
 move x2,x1
 tst d0			largeur n‚gative ?
 bmi.s .largeur_n‚gative
.largeur_positive
 sub d3,x1
 rts
.largeur_n‚gative
 add d3,x1
 rts






trace_cadre_vide
 move couleur_cycling,d7
 
 move x1,d0
 move x2,d1
 cmp d1,d0
 bmi .inverse_pas_x
 exg d0,d1
.inverse_pas_x

 add d0,d0 		XGauche x2

 move.l ‚cran,a1
 add d0,a1		Ligne horizontale 1 ‚cran
 move.l a1,a2	  	Ligne horizontale 2
 move.l fichier,a3
 add d0,a3		Ligne horizontale 1 image
 move.l a3,a4	  	Ligne horizontale 2
 
 move y1,d0
 mulu largeur_‚cran,d0
 add.l d0,a1		Incr‚ment vertical
 move y2,d0
 mulu largeur_‚cran,d0
 add.l d0,a2		Incr‚ment vertical

 move y1,d0
 mulu largeur_image,d0
 add.l d0,a3		Incr‚ment vertical
 move y2,d0
 mulu largeur_image,d0
 add.l d0,a4		Incr‚ment vertical
    
 move x1,d0
 sub x2,d0
 bpl .ok
 neg d0
.ok
 move d0,largeur
 addq #1,largeur
 
 tst type_ligne
 beq .ligne_x_trace
 cmp #1,type_ligne
 beq .ligne_x_restaure
 cmp #2,type_ligne
 beq .ligne_x_d‚filante
 
 nop
    
.ligne_x_trace
 move couleur,(a1)+	Lignes horizontales … l'‚cran
 move couleur,(a2)+
 dbra d0,.ligne_x_trace
 bra .trace_cadre_y

.ligne_x_restaure
 move (a3)+,(a1)+	Recopie de l'image vers l'‚cran les horizontales.
 move (a4)+,(a2)+
 dbra d0,.ligne_x_restaure
 bra .trace_cadre_y

.ligne_x_d‚filante
 move d7,(a1)+		Lignes horizontales … l'‚cran
 move d7,(a2)+
 rol d7
 dbra d0,.ligne_x_d‚filante
 bra .trace_cadre_y

 nop
 
.trace_cadre_y
 move y1,d0
 move y2,d1
 cmp d1,d0
 bmi .inverse_pas_y
 exg d0,d1
.inverse_pas_y
 move d0,d1
 
 move.l ‚cran,a1
 mulu largeur_‚cran,d0	YHaut x640
 add.l d0,a1		Ligne verticale 1 ‚cran
 move.l a1,a2	  	Ligne verticale 2

 move.l fichier,a3
 mulu largeur_image,d1	YHaut x640
 add.l d1,a3		Ligne verticale 1 image
 move.l a3,a4	  	Ligne verticale 2
 
 move x1,d0
 add d0,d0		X x2
 add d0,a1		Incr‚ment horizontal ‚cran
 add d0,a3		Incr‚ment horizontal
 move x2,d0
 add d0,d0		X x2
 add d0,a2		Incr‚ment horizontal image
 add d0,a4		Incr‚ment horizontal
    
 move y1,d0
 sub y2,d0
 bpl .ok_y
 neg d0
.ok_y
 move d0,hauteur
 addq #1,hauteur   

 tst type_ligne
 beq .ligne_y_trace
 cmp #1,type_ligne
 beq .ligne_y_restaure
 cmp #2,type_ligne
 beq .ligne_y_d‚filante
 
 nop
   
.ligne_y_trace
 move couleur,(a1)
 move couleur,(a2)
 add largeur_‚cran,a1
 add largeur_‚cran,a2
 dbra d0,.ligne_y_trace
 rts 

.ligne_y_restaure
 move (a3),(a1)
 move (a4),(a2)
 add largeur_‚cran,a1
 add largeur_‚cran,a2
 add largeur_image,a3
 add largeur_image,a4
 dbra d0,.ligne_y_restaure
 rts 

.ligne_y_d‚filante
 move d7,(a1)
 move d7,(a2)
 add largeur_‚cran,a1
 add largeur_‚cran,a2
 rol d7
 dbra d0,.ligne_y_d‚filante
 rts








routine_equerre_boite
 force_int‚rieur
 move.l mousexy,xy2	et m‚morise pour la suite.

 relache		On attend que le bouton soit relach‚ !

 bsr initialise_minimax

.cadre_suivant
 getmouse
 force_int‚rieur
 move.l mousexy,xy1
 bsr teste_shift_equerre

 bsr mise_…_jour_table_rectangle
 bsr affiche_table_polyfill
 bsr vsync
 bsr attend_mouvement
 cmp #2,mousek
 beq.s .fin_routine_cadre
 cmp #1,mousek
 bne .cadre_suivant

.trace_ce_cadre
* bsr m‚morise_table_polyfill
 st flag_chang‚e
 relache
 rts
 
.fin_routine_cadre
 bsr efface_table_polyfill
 relache
 rts



mise_…_jour_table_rectangle
 move x1,d0
 move x2,d1
 cmp d1,d0
 ble.s .inverse_pas_x
 exg d1,d0
.inverse_pas_x

 move y1,d2
 move y2,d3
 cmp d3,d2
 ble.s .inverse_pas_y
 exg d3,d2
.inverse_pas_y

*** Maintenant, on …  D0=Xmin  D1=Xmax
***                   D2=Ymin  D3=Ymax

 move d2,y_min_2
 move d3,y_max_2
 
 lea buffer_minimax,a0		D‚but de la table
 lea (a0,d2.w*8),a0		Pointe en y_min_2
 sub d2,d3			Nombre de lignes … remplir
.remplie_tableau
 move d0,min_2(a0)		Minimum en X
 move d1,max_2(a0)		Maximum en X
 addq #8,a0			Rang‚e suivante...
 dbra d3,.remplie_tableau
 rts

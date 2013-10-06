 TEXT
 even
routine_crayon_dessin
 move #0,type_ligne	On colorie en couleur... d‚finitive !
 force_int‚rieur
 move.l mousexy,xy2	et m‚morise pour la suite.

point_suivant  
 getmouse
 force_int‚rieur
 cmp #1,mousek
 bne sort_routine_draw
 bsr vsync
 move.l mousexy,xy1
 bsr trace_ligne
 move.l xy1,xy2
 bsr affiche_le_zoomer
 bra point_suivant
sort_routine_draw
 st flag_chang‚e
 rts

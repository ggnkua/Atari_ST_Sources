 TEXT

pile		equr a4
fin_pile	equr a3
 
routine_peinture_remplissage
 force_int‚rieur

 move.l ‚cran,a6
 
 move mousey,d6			Position en Y du germe
 mulu largeur_‚cran,d6		x 640
 add.l d6,a6			Adresse de la premiŠre ligne affich‚e ‚cran.

 move mousex,d6			Position en X du germe
 add d6,d6			x 2
 move (a6,d6.w),d5		Couleur … remplir
 move couleur,d7		Couleur de remplissage

 cmp d7,d5			Si les deux sont identiques...
 beq pas_remplissage		on arrete.

 lea pile_peinture,a0
 move.l memoire_libre,d0
 sub.l #1500,d0
 cmp.l #10000,d0
 ble.s .pas_assez 
 move.l d0,taille_pile
 bsr r‚serve_bloc
 beq.s .ok
.pas_assez
 bsr boite_alerte
 rts
  
.ok

 move.l pile_peinture,fin_pile	On ne m‚lange pas la pile systŠme avec celle-la !!!
 add #120,fin_pile

 move.l pile_peinture,pile
 add.l taille_pile,pile

 sf flag_calcule_zoomer

 clr.l -(pile)			Pour indiquer la fin du remplissage...
  
 move   d6,-(pile)		Empile la coordonn‚e X du germe
 move.l a6,-(pile)		et l'adresse de d‚part
 
; a6=pointe sur l'adresse de l'‚cran
; d5=couleur … remplacer
; d6=coordonn‚e X du point germe

boucle_routine
 tst.l (pile)		Lorsque la pile est vide, on a fini...
 beq fin_remplissage

 move.l (pile)+,a6	Retire l'adresse de d‚part
 move   (pile)+,d6	Ainsi que la coordonn‚e X du germe.

 move.w d6,d3

teste_gauche
 cmp -2(a6,d6.w),d5	On arrive … un pixel de la couleur limite ???
 bne.s fin_teste_gauche 
 tst d6			On est sur la bordure de gauche ???
 beq.s fin_teste_gauche
 subq #2,d6
 bra.s teste_gauche
fin_teste_gauche 
 
 move d6,gauche

teste_droite
 cmp 2(a6,d3.w),d5	Pixel de couleur diff‚rente ???
 bne.s fin_teste_droite
 addq #2,d3
 cmp largeur_image,d3	Cot‚ droit de l'image atteint ???
 blt.s teste_droite
 subq #2,d3
fin_teste_droite
 move d3,droite

 move d3,d0		XDroite
 sub d6,d0		- XGauche => Nombre de points
 lsr d0			Divise par 2
 
 lea (a6,d6.w),a1	Adresse du point de gauche … l'image
 move couleur,d1
.trace_points
 move d1,(a1)+
 dbra d0,.trace_points

 cmp.l ‚cran,a6		V‚rifie si l'on est pas d‚ja arrive tout en
 beq fin_boucle_haut	haut de l'image... (Vive les bombes !!!)

 move.l a6,a5
 sub largeur_‚cran,a5	Exploration de la ligne sup‚rieure.

 sf d3
 move gauche(pc),d6
boucle_cherche_haut
 cmp (a5,d6.w),d5
 bne.s couleur_diff‚rente_haut
 tst.b d3
 bne.s fin_test

; Ici, on ne stocke que le premier pixel d'un groupe horizontal de pixels
; de la meme couleur.
;
stocke_pixel_sup‚rieur
 cmp.l a3,pile
 ble.s fin_boucle_haut
; move #$1234,(a5,d6.w)
 move   d6,-(pile)	Empile un nouveau germe
 move.l a5,-(pile)
 st d3
 bra.s fin_test 

; On arrive ici, dans le cas o— le point de la ligne sup‚rieure n'est pas
; de la couleur … remplir.
;
couleur_diff‚rente_haut
 sf d3
fin_test
 cmp droite(pc),d6	On est arriv‚ … droite ???
 beq.s fin_boucle_haut
 addq #2,d6
 bra.s boucle_cherche_haut
fin_boucle_haut      


 move.l ‚cran,a5	Avant de descendre, on v‚rifie que l'on est
 sub largeur_‚cran,a5
 add.l taille_‚cran,a5	pas d‚ja arriv‚ tout en bas de l'image !
 cmp.l a6,a5
 beq fin_boucle_bas
 
 move.l a6,a5
 add largeur_‚cran,a5	Ligne inf‚rieure
 sf d3
 move gauche(pc),d6
boucle_cherche_bas
 cmp (a5,d6),d5
 bne.s couleur_diff‚rente_bas
 tst.b d3
 bne.s fin_test_bas

stocke_pixel_inf‚rieur
 cmp.l a3,pile
 ble.s fin_boucle_bas
; move #$4321,(a5,d6.w)
 move   d6,-(pile)     ; PUSH
 move.l a5,-(pile)
 st d3
 bra.s fin_test_bas

couleur_diff‚rente_bas
 sf d3
fin_test_bas
 cmp droite(pc),d6
 beq.s fin_boucle_bas
 addq #2,d6
 bra.s boucle_cherche_bas
fin_boucle_bas      

 bra boucle_routine

erreur_remplissage
 move #15,d6
.zap_vbl
 move #2000,d7
.zap_screen
 move.l #$ff000000,$ffff9800.w
 move.l #$ffff0000,$ffff9800.w
 move.l #$00ff0000,$ffff9800.w
 move.l #$00ff00ff,$ffff9800.w
 move.l #$000000ff,$ffff9800.w
 move.l #$ff0000ff,$ffff9800.w
 dbra d7,.zap_screen
 bsr vsync
 dbra d6,.zap_vbl
 
fin_remplissage
 lea pile_peinture,a0
 bsr libŠre_bloc

 st flag_chang‚e
 st flag_calcule_zoomer
pas_remplissage
 relache
 rts


gauche  dc.w 0
droite  dc.w 0

 BSS

pile_peinture		ds.l 1
taille_pile		ds.l 1

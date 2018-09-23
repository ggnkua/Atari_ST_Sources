rempli_image
 move #%11111,couleur		Un beau bleu

 lea pile,a0
 lea ecran,a6

 move mousey,d0			Position en Y du germe
 mulu #640,d0			x 640
 add.l d0,a6			Adresse de la premiŠre ligne affich‚e.

 move mousex,d0			Position en X du germe
 add d0,d0			x 2
 move (a6,d0.w),d5		Couleur … remplir
 
 move   d0,(a0)+		Empile la coordonn‚e X du germe
 move.l a6,(a0)+		et l'adresse de d‚part

;*a0=pointeur de pile
; a3=pointe sur la fin de la routine d'affichage (REPT-ENDR)
; a5=pointe sur la table des motifs d'extremit‚ de ligne
; a6=pointe sur l'adresse de l'‚cran
; d3=flag changement de couleur temporaire
; d4=coordon‚es XX/YY temporaires le temps d'un calcul...
;*d5=couleur … remplacer
;*d6=coordonn‚e X du point germe
;*d7=coordonn‚e Y du point germe
;
;
boucle_routine
 cmp.l #pile,a0		Lorsque la pile est vide, on a fini...
 beq fin_routine

* movem.l d0-a6,-(sp)
* move #7,-(sp)
* trap #1
* addq #2,sp
* cmp.b #'*',d0
* beq zap_it 
* movem.l (sp)+,d0-a6
 
 move.l -(a0),a6	Retire l'adresse de d‚part
 move   -(a0),d6	Ainsi que la coordonn‚e X du germe.

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
 cmp largeur_ecran,d3	Cot‚ droit de l'‚cran atteint ???
 beq.s fin_teste_droite
 addq #2,d3
 bra.s teste_droite
fin_teste_droite 
 move d3,droite

trace_line_horizontale
* movem.l d5-d7/a0,-(sp)

 move d3,d0		XDroite
 sub d6,d0		- XGauche => Nombre de points
 lsr d0			Divise par 2
 
 lea (a6,d6),a1		Adresse du point de gauche … l'‚cran
.trace_points
 move couleur,(a1)+
 dbra d0,.trace_points
 
* movem.l (sp)+,d5-d7/a0

 cmp.l #ecran,a6	V‚rifie si l'on est pas d‚ja arrive tout en
 beq fin_boucle_haut	haut de l'‚cran... (Vive les bombes !!!)

 lea -640(a6),a5	Exploration de la ligne sup‚rieure.

 sf d3
 move gauche(pc),d6
boucle_cherche_haut
 cmp (a5,d6.w),d5
 bne.s .test_2
 tst.b d3
 bne.s .fin_test
.test_1

 move   d6,(a0)+	Empile un nouveau germe
 move.l a5,(a0)+
 st d3
 bra.s .fin_test 

.test_2
 sf d3
.fin_test
 cmp droite(pc),d6	On est arriv‚ … droite ???
 beq.s fin_boucle_haut
 addq #2,d6
 bra.s boucle_cherche_haut
fin_boucle_haut      


 lea ecran-640,a5	Avant de descendre, on v‚rifie que l'on est
 add.l taille_ecran,a5	pas d‚ja arriv‚ tout en bas de l'‚cran !
 cmp.l a6,a5
 beq fin_boucle_bas
 
 lea 640(a6),a5		Ligne inf‚rieure
 sf d3
 move gauche(pc),d6
boucle_cherche_bas
 cmp (a5,d6),d5
 bne.s .test_2
 tst.b d3
 bne.s .fin_test
.test_1

 move   d6,(a0)+     ; PUSH
 move.l a5,(a0)+

 st d3
 bra.s .fin_test 
.test_2
 sf d3

.fin_test
 cmp droite(pc),d6
 beq.s fin_boucle_bas
 addq #2,d6
 bra.s boucle_cherche_bas
fin_boucle_bas      

 bra boucle_routine
fin_routine
 rts


zap_it 
 movem.l (sp)+,d0-a6
 rts
 
 section DATA 

largeur_ecran	dc.w 640
hauteur_ecran	dc.w 200
taille_ecran	dc.l 640*200

gauche  dc.w 0
droite  dc.w 0
couleur dc.w 0

 ds.l 10000
pile dcb.l 1000,0
 ds.l 10000
 
image	incbin filltest.tcp

 section BSS

old_video	ds.w 1 
old_adresse	ds.w 1
x_souris	ds.w 1
y_souris	ds.w 1
 ds.l 10000
ecran		ds.l 128000/4
buffer		ds.l 128000/4
 ds.l 10000
 end
 
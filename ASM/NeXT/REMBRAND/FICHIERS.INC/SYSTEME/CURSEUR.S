;
; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion du curseur de la souris. (1.0)
;
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

cache_curseur
 sf flag_curseur
 bsr vsync
 rts

montre_curseur
 st flag_curseur
 bsr vsync
 rts

  
teste_hbl_hard
 bsr vsync
 move sr,-(sp)
 move #$2700,sr
 move.l #routine_hbl_hard_teste,$68.w
 move.l #routine_vbl_teste_1,$70.w
 move.l #routine_hbl_teste,$120.w
 move #$2100,sr
 bsr vsync
 bsr vsync
 bsr vsync
 bsr vsync
 move #$2700,sr
 move.l #routine_hbl_hard,$68.w
 move.l #routine_vbl,$70.w
 move.l #routine_hbl_1,$120.w
 move (sp)+,sr
 bsr vsync
 rts

routine_vbl_teste_1
 st flag_vsync			Pour la routine de synchro verticale
 move.l #routine_vbl_teste,$70.w
 rte
 
routine_vbl_teste
 st flag_vsync			Pour la routine de synchro verticale
 clr offset_hbl
 sf $fffffa1b.w
 move.b #1,$fffffa21.w		Lance la HBL mfp
 move.b #8,$fffffa1b.w
 rte

routine_hbl_hard_teste
 addq #1,offset_hbl
 rte

routine_hbl_teste
 move.l #routine_it_dummy,$68.w
 move.l #routine_vbl_dummy,$70.w
 move.l #routine_it_dummy,$120.w
 sf $fffffa1b.w
 bclr #0,$fffffa0f.w
 rte


routine_vbl_dummy
 st flag_vsync		Pour la routine de synchro verticale
routine_it_dummy
 rte




 
calcule_position_curseur
 move x_scroll,d0
 add mousex_118,d0	***
 move d0,vbl_mousex
 move y_scroll,d0
 add mousey_118,d0	***
 move d0,vbl_mousey
 rts
 
  
routine_hbl_hard_compte
 addq #1,compteur_curseur
 rte
 
routine_hbl_hard
 subq #1,compteur_hbl_hard
 bne .fin_hbl_hard 

 movem.l d0-a6,-(sp)

 move.l ‚cran,a1	+ ADRESSE ‚cran
 move vbl_mousex,d0
 lea (a1,d0.w*2),a1
 move vbl_mousey,d0	+ MOUSEX x640
 mulu largeur_‚cran,d0
 add.l d0,a1		=> adresse d'affichage du sprite

 moveq #2,d2
 
 move largeur_‚cran,d0
 lsr d0
 sub vbl_mousex,d0
 cmp #16,d0
 ble.s .no_clip_x
 moveq #16,d0
 subq #1,d2
.no_clip_x
 subq #1,d0
  
 move hauteur_‚cran,d1
 sub vbl_mousey,d1
 cmp #16,d1
 ble.s .no_clip_y
 moveq #16,d1
 subq #1,d2
.no_clip_y
 subq #1,d1
   
 lea sauve_fonds,a3
 move.l a1,(a3)+		Sauve l'adresse de restauration du fonds
 move d0,(a3)+			Largeur
 move d1,(a3)+			Hauteur

 tst d2				Curseur visible en entier ???
 beq.s .affiche_sans_clipping
 bsr affiche_curseur_clipp‚
 bra.s .fin_affichage
.affiche_sans_clipping
 bsr affiche_curseur_entier
.fin_affichage

 move #$2100,sr
 clr compteur_curseur
 move.l #routine_hbl_hard_compte,$68.w

 bsr affiche_informations
 iif cpu_time move.l #$ff000000,$ffff9800.w
.attend_fin_curseur
 cmp #20,compteur_curseur
 ble.s .attend_fin_curseur

 move #$2500,sr
 move.l #routine_it_dummy,$68.w
 bsr efface_curseur_hbl
 iif cpu_time move.l #$00000000,$ffff9800.w
 movem.l (sp)+,d0-a6

.fin_hbl_hard
 rte



 


;
; Cette routine est n‚c‚ssaire, car mine de rien, afficher un sprite 16x16
; en TrueColor, en mode transparent... ca bouffe du temps machine ! Et un
; curseur qui clignote, ca ne fait vraiment pas s‚rieux...
;
affiche_curseur_entier
 move.l adresse_curseur,a0
 lea sauve_fonds,a3
 move.l (a3)+,a1		Sauve l'adresse de restauration du fonds
 move (a3)+,d0			Largeur
 move (a3)+,d1			Hauteur
.recop_y2
 move.l a1,a2
 rept 8
 move.l (a2)+,(a3)+		Sauve la couleur du fonds.
 move (a0)+,d7			Prends la couleur du sprite
 beq.s *+6 *.couleur_transparente
 move d7,-4(a2)			Si pas noire, alors affiche la.
*.couleur_transparente
 move (a0)+,d7			Prends la couleur du sprite
 beq.s *+6 *.couleur_transparente
 move d7,-2(a2)			Si pas noire, alors affiche la.
*.couleur_transparente
 endr
 add largeur_‚cran,a1
 dbra d1,.recop_y2
 rts


affiche_curseur_clipp‚
 move.l adresse_curseur,a0
 lea sauve_fonds,a3
 move.l (a3)+,a1		Sauve l'adresse de restauration du fonds
 move (a3)+,d0			Largeur
 move (a3)+,d1			Hauteur
.recop_y
 move.l a0,a4
 move.l a1,a2
 move d0,d2
.recop_x
 move (a2)+,(a3)+		Sauve la couleur ant‚rieure
 move (a4)+,d7			Prends la nouvelle
 beq.s .couleur_transparente
 move d7,-2(a2)			Si pas noire, alors affiche la.
.couleur_transparente
 dbra d2,.recop_x
 lea 32(a0),a0
 add largeur_‚cran,a1
 dbra d1,.recop_y   
 rts

efface_curseur_hbl
 lea sauve_fonds,a0		Restauration du fonds sous le curseur
 move.l (a0)+,a1		Adresse d'affichage
 move (a0)+,d0			Largeur
 move (a0)+,d1			Hauteur
.recopie_fonds_y
 move.l a1,a3
 add largeur_‚cran,a1
 move d0,d2
.recopie_fonds_x
 move (a0)+,(a3)+
 dbra d2,.recopie_fonds_x
 dbra d1,.recopie_fonds_y
 rts


 



colorie_curseur
 move couleur,d7			Vu que le noir est transparent...
 bne.s .pas_noir
 move #%0000000000100000,d7		...On y met un vert TRES sombre !!!
.pas_noir 
 move.l adresse_curseur,a0		Adresse de base du curseur
 lea 512(a0),a1				Saute le graphisme
 move (a1)+,d0				Nombre de couleurs … modifier
 beq.s .fin_coloriage
.boucle_coloriage
 move (a1)+,d1				R‚cupŠre l'offset
 move d7,(a0,d1.w)			Change la couleur du pixel.
 subq #1,d0				Couleur suivante
 bne.s .boucle_coloriage
.fin_coloriage 
 rts


adresse_routine_curseur	ds.l 1
 
sauve_fonds		ds.l 1		Pour l'adresse de restauration
			ds.l 1		Pour la largeur
			ds.l 1		Pour la hauteur
			ds.l 512/4 	Les donn‚es elles meme

compteur_hbl_hard	ds.w 1
offset_hbl		ds.w 1

compteur_curseur	ds.w 1		Pour l'affichage du curseur

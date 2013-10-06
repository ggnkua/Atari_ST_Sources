*
*
* Le but est d'afficher un cadre en relief
*
*

*
* 24 Octets de d‚finition
* et la couleur est d‚finie en +12
*
case_couleur macro
 dc.w \1,\2,008,008,0,-1
 dc.w 0,0
 dc.l routine_s‚lectionne_couleur,0
 endm

* Permet de coder facilement une couleur. Na.
* Usage: CODE_RVB rouge vert bleu
*
code_rvb macro
 dc.w \1<<11+\2<<5+\3
 endm
 
;
;
; Quelques constantes pour les modes vid‚os
;
;
col2=0
col4=1
col16=2
col256=3
coltc=4

l40=0
l80=8

tv=0
vga=16
pal=32
overscan=64
st=128
interlace=256

mode=coltc+l40+tv+pal


 pea superviseur
 move #$26,-(sp)
 trap #14
 addq #6,sp
;
; Et quitte
; 
 clr -(sp)
 trap #1



 
superviseur 
;
; R‚cupŠre la r‚solution courante et l'adresse de la m‚moire
; vid‚o
;
 move #-1,-(sp)
 move #88,-(sp)
 trap #14
 addq #4,sp
 move d0,old_video
 
 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,old_adresse

;
; Valide ma propre r‚solution
; et mon propre ecran
; 
 move #37,-(sp)
 trap #14
 addq #2,sp

 move #mode,-(sp)
 move #3,-(sp)
 pea ecran
 pea ecran
 move #5,-(sp)
 trap #14
 add #14,sp

 move #20,affiche_x
 move #25,affiche_y

 bsr affiche_image 
 bsr initialise_s‚lecteur
 bsr cache_souris
 bsr d‚code_ressource
 bsr montre_souris

 
attend_touche
 bsr vsync
 bsr getmouse
 tst.w mousek
 bne.s teste_position
 bra.s attend_touche

teste_position
 move mousex,d0
 cmp min_x,d0
 blt routine_pique_couleur
 cmp max_x,d0
 bgt routine_pique_couleur
 move mousey,d0
 cmp min_y,d0
 blt routine_pique_couleur
 cmp max_y,d0
 bgt routine_pique_couleur

 bsr teste_case
 tst.l d0
 beq .pas_routine
 move.l d0,a0
* move.l cadre_routine(a0),a0
 jsr ([cadre_routine,a0])
.pas_routine 
 tst.b flag_ferme_formulaire
 beq attend_touche

; 
; Si on arrive ici, c'est que l'on cliqu‚ sur la case
; de fermeture de la fenetre.
;
 bsr cache_souris
 
;
; Restaure tout
; 
 bsr vsync
 bsr vsync
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 bsr vsync
 bsr vsync
 rts

routine_pique_couleur
 move.l ‚cran,a0
 add mousex,a0
 add mousex,a0
 move mousey,d0
 mulu #640,d0
 add.l d0,a0
 bsr cache_souris
 move (a0),couleur_‚dit‚e
 bsr montre_souris
 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu
 bsr montre_souris
 bra attend_touche
 
affiche_image
 lea image+44,a0
 move.l ‚cran,a1
 move #128000/4-1,d0
.recop
 move.l (a0)+,(a1)+
 dbra d0,.recop
 rts
  
getmouse
 movem.l d0-a6,-(sp)
 dc.w $a000
 move -602(a0),mousex
 move -600(a0),mousey
 move -596(a0),mousek
 movem.l (sp)+,d0-a6
 rts 

relache
 bsr getmouse
 tst mousek
 bne relache
 rts
 
montre_souris
 movem.l d0-a6,-(sp) 
 dc.w $a000			LINEA INIT
 move.l 4(a0),a1
 move #0,1*2(a1)		CONTRL(1)
 move #1,3*2(a1)		CONTRL(3)
 move.l 8(a0),a1
 move #0,0*2(a1)		INTINT(0)
 dc.w $a009			SHOWM
 movem.l (sp)+,d0-a6
 rts

cache_souris
 movem.l d0-a6,-(sp) 
 dc.w $a00a
 movem.l (sp)+,d0-a6
 rts

vsync
 movem.l d0-a6,-(sp) 
 move #37,-(sp)
 trap #14
 addq #2,sp
 movem.l (sp)+,d0-a6
 rts

tempo
 bsr vsync
 dbra d0,tempo
 rts
   

teste_case
 moveq #0,d0				Pas de case … priori.
 lea d‚f_s‚lecteur,a0
.d‚code_suivant
 tst (a0)
 bmi .fin_d‚codage
 bsr lecture_‚l‚ment
* Teste si l'on a cliqu‚ sur un objet en particulier

 lea 24(a0),a0
 tst.l adresse_routine
 beq .d‚code_suivant
 
 move x1,d1
 move y1,d2
 cmp mousex,d1
 bgt .d‚code_suivant
 cmp mousey,d2
 bgt .d‚code_suivant

 add largeur,d1
 add hauteur,d2
 cmp mousex,d1
 blt .d‚code_suivant
 cmp mousey,d2
 blt .d‚code_suivant

 lea -24(a0),a0				Adresse du bloc de d‚finition
 move.l a0,d0 
.fin_d‚codage 
 rts 






d‚code_ressource
 move #9999,min_x
 move #0,max_x
 move #9999,min_y
 move #0,max_y
 lea d‚f_s‚lecteur,a0
.d‚code_suivant
 tst (a0)
 bmi .fin_d‚codage
 bsr lecture_‚l‚ment
 lea 24(a0),a0
 bsr trace_cadre

 move x1,d0
 move y1,d1
.teste_xmin
 cmp min_x,d0
 bpl .teste_ymin
 move d0,min_x
.teste_ymin 
 cmp min_y,d1
 bpl .teste_xmax
 move d1,min_y
.teste_xmax
 add largeur,d0
 cmp max_x,d0
 blt .teste_ymax
 move d0,max_x
.teste_ymax
 add hauteur,d1
 cmp max_y,d1
 blt .fin_test
 move d1,max_y
.fin_test

 bra .d‚code_suivant
.fin_d‚codage 
 rts


initialise_s‚lecteur
 lea couleurs,a0
 lea table_couleurs,a1
 moveq #4-1,d1
.recopie_couleurs_x
 lea (a1),a2
 addq #4,a1
 moveq #10-1,d0
.recopie_couleurs_y
 move (a0)+,([a2])
 lea 16(a2),a2
 dbra d0,.recopie_couleurs_y
 dbra d1,.recopie_couleurs_x

 move couleur,couleur_‚dit‚e
 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu

 sf flag_ferme_formulaire
 rts

 
trace_cadre
 movem.l d0-a6,-(sp)

 move.l ‚cran,a0	Adresse de l'‚cran
 move x1,d0
 add d0,d0		+ X x2
 add d0,a0
 move y1,d0
 mulu largeur_‚cran,d0	+ Y x640
 add.l d0,a0

*
* Calcule les d‚grad‚s
*   
 move #(16*2048)+(32*32)+(16),d0	Par d‚faut, c'est du gris
 tst couleur_cadre			mais on peut aussi d‚grader
 beq .cadre_gris			le contour par rapport … la
 move couleur_centre,d0			couleur centrale.
.cadre_gris

 move d0,d2
 and #31,d2	Bleu
 mulu #10,d2
 lsr #6,d0
 move d0,d1
 and #31,d1	Vert
 mulu #10,d1
 lsr #5,d0
 and #31,d0	Rouge
 mulu #10,d0
 lea table_d‚grad‚,a1 
 movem (a1,d0.w),d3-d7	Charge le rouge
 lsl #5,d3
 lsl #5,d4
 lsl #5,d5
 lsl #5,d6
 lsl #5,d7
 lea table_d‚grad‚,a1 
 add d1,a1
 or (a1)+,d3	Charge le vert
 or (a1)+,d4
 or (a1)+,d5
 or (a1)+,d6
 or (a1)+,d7
 lsl #6,d3
 lsl #6,d4
 lsl #6,d5
 lsl #6,d6
 lsl #6,d7
 lea table_d‚grad‚,a1 
 add d2,a1
 or (a1)+,d3	Charge le bleu
 or (a1)+,d4
 or (a1)+,d5
 or (a1)+,d6
 or (a1)+,d7
 move d7,a6
 move d6,a5
 move d5,a4
 move d4,d7
 move d3,d6
*
* Commence par remplir l'int‚rieur
*  
 movem.l a0,sauve_regs

 tst flag_relief
 beq.s .ok_relief
 exg d6,a6
 exg d7,a5
.ok_relief
 
 move couleur_centre,d5
 
 move hauteur,d1
.loop_y
 move.l a0,a1
 move largeur,d0
.loop_x
 move d5,(a1)+		La couleur d'origine
 dbra d0,.loop_x
 lea 640(a0),a0
 dbra d1,.loop_y
*
* Puis le pourtour avec l'‚clairage
*
 move ‚paisseur,d3
‚paissie_cadre
 movem.l sauve_regs,a0

 move.l a0,a1
 move d6,(a1)+		Le pixel blanc en haut … gauche
 move largeur,d2
 subq #2,d2
.loop_x_haut
 move d7,(a1)+		La bande gris claire du haut
 dbra d2,.loop_x_haut
 move a4,(a1)+		Le pixel gris en haut … droite

 move hauteur,d1
 subq #2,d1
 move largeur,d2
 add d2,d2
.loop_y_milieu
 add largeur_‚cran,a0
 move d7,(a0)
 move a5,(a0,d2.w)
 dbra d1,.loop_y_milieu

 add largeur_‚cran,a0
 move a4,(a0)+		Le pixel gris en bas … gauche
 move largeur,d2
 subq #2,d2
.loop_x_bas
 move a5,(a0)+		La bande gris sombre du bas
 dbra d2,.loop_x_bas
 move a6,(a0)+		Le pixel noir en bas … droite

 movem.l sauve_regs,a0
 subq #2,largeur
 subq #2,hauteur
 addq #1,x1
 addq #1,y1
 add largeur_‚cran,a0
 addq #2,a0
 movem.l a0,sauve_regs
 dbra d3,‚paissie_cadre

 move.l adresse_texte,a1
 cmp.l #0,a1
 beq pas_de_texte

 move (a1)+,d0		Offset en X
 add d0,d0		… rajouter … l'adresse de l'‚cran
 add d0,a0		
 move (a1)+,d0		+ l'offset vertical, et ca roule...
 mulu largeur_‚cran,d0
 add.l d0,a0
 move (a1)+,d7		d7 = couleur d'affichage du texte
  
 lea fonte,a2
 
lettre_suivante
 moveq #0,d0
 move.b (a1)+,d0 	Prends le code ASCII du caractŠre
 beq pas_de_texte	si 0, termin‚
 mulu #72,d0
 lea (a2,d0.w),a3	Adresse du caractŠre d‚sir‚
 move.l a0,a4		Adresse d'affichage du caractŠre
 moveq #6-1,d0
.affiche_lettre
 moveq #0,d3
 moveq #6-1,d1
.affiche_rang‚e 
 move (a3)+,d2
 beq .affiche_pas_pixel
 move d7,(a4,d3.w)
.affiche_pas_pixel
 addq #2,d3
 dbra d1,.affiche_rang‚e
 add largeur_‚cran,a4
 dbra d0,.affiche_lettre 
 lea 12(a0),a0
 bra lettre_suivante

pas_de_texte 
 movem.l (sp)+,d0-a6
 rts

sauve_regs	ds.l 3

 rsreset
cadre_x		rs.w 1
cadre_y 	rs.w 1
cadre_largeur	rs.w 1
cadre_hauteur	rs.w 1
cadre_‚paisseur	rs.w 1
cadre_relief	rs.w 1
cadre_couleur	rs.w 1
cadre_cadre	rs.w 1
cadre_routine	rs.l 1
cadre_texte	rs.l 1

 rsreset
cadre_texte_x		rs.w 1
cadre_texte_y		rs.w 1
cadre_texte_couleur	rs.w 1
cadre_texte_message	rs.b 1

click_x	ds.w 1
click_y	ds.w 1
click_k	ds.w 1

maximum_curseur		ds.w 1
d‚callage_composante	ds.w 1
masque_composante	ds.w 1
adresse_curseur		ds.l 1

initialise_rouge
 move.l #d‚f_curseur_rouge,adresse_curseur
 move #31,maximum_curseur
 move #11,d‚callage_composante
 move #%0000011111111111,masque_composante
 rts

initialise_vert
 move.l #d‚f_curseur_vert,adresse_curseur
 move #63,maximum_curseur
 move #5,d‚callage_composante
 move #%1111100000011111,masque_composante
 rts

initialise_bleu
 move.l #d‚f_curseur_bleu,adresse_curseur
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

 move couleur_‚dit‚e,d0		R‚cupŠre la couleur ant‚rieure
 move d0,d6			Couleur initiale
 and masque_composante,d6
 move d‚callage_composante,d1
 lsr d1,d0
 and maximum_curseur,d0
 move d0,d7			La composante est isol‚e
 
.loop   
 bsr vsync
 bsr getmouse
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
 move d0,couleur_‚dit‚e
  
 sf sens
 movem.l d0-a6,-(sp)
 bsr modifie_couleur
 movem.l (sp)+,d0-a6
 
 bra .loop
.end_loop 
 bsr relache
 rts




routine_incr‚mente_rouge      
 bsr initialise_rouge
 moveq #4,d0
 bsr tempo
 st sens
 bra modifie_couleur
 
routine_d‚cr‚mente_rouge      
 bsr initialise_rouge
 moveq #4,d0
 bsr tempo
 move.b #1,sens
 bra modifie_couleur

routine_positionne_rouge
 bsr initialise_rouge
 sf sens
 bra modifie_couleur

routine_incr‚mente_vert      
 bsr initialise_vert
 moveq #4,d0
 bsr tempo
 st sens
 bra modifie_couleur
 
routine_d‚cr‚mente_vert      
 bsr initialise_vert
 moveq #4,d0
 bsr tempo
 move.b #1,sens
 bra modifie_couleur

routine_positionne_vert
 bsr initialise_vert
 sf sens
 bra modifie_couleur

routine_incr‚mente_bleu      
 bsr initialise_bleu
 moveq #4,d0
 bsr tempo
 st sens
 bra modifie_couleur
 
routine_d‚cr‚mente_bleu      
 bsr initialise_bleu
 moveq #4,d0
 bsr tempo
 move.b #1,sens
 bra modifie_couleur

routine_positionne_bleu
 bsr initialise_bleu
 sf sens
 bra modifie_couleur
 
sens	dc.w 0
 
modifie_couleur
 move couleur_‚dit‚e,d0
 move d0,d6
 and masque_composante,d6	Couleur masqu‚e
 move d‚callage_composante,d1
 lsr d1,d0
 and maximum_curseur,d0		Composante isol‚e

 tst.b sens
 beq .continue
 bmi .monte_curseur

.descend_curseur 
 tst d0
 beq .continue
 subq #1,d0
 bra .continue

.monte_curseur
 cmp maximum_curseur,d0
 beq .continue
 addq #1,d0
 bra .continue

.continue
 move d0,d7

 move d‚callage_composante,d1
 lsl d1,d7				R‚cupŠre la bonne valeur 
 add d6,d7				Couleur initiale sans la composante
 move d7,couleur_‚dit‚e

 lea d‚f_couleur_‚dit‚e,a0		Change la couleur de la case
 bsr lecture_‚l‚ment			de la couleur ‚dit‚e.
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
 move.l adresse_curseur,a0
 add cadre_y-24(a0),d6		Position de la glissiŠre
 move d6,cadre_y(a0)
 
 move d0,d7
 lsl d1,d7
 move d7,cadre_couleur(a0)	Couleur du curseur

 move d0,d1
 bsr inscrit_valeur_curseur	Affiche D1 en un nombre ASCII (00-99)
  
 lea -24(a0),a0
 bsr lecture_‚l‚ment		R‚affiche la glissiŠre du curseur
 bsr affichage_‚l‚ment

 lea 24(a0),a0
 bsr lecture_‚l‚ment		R‚affiche le curseur lui-meme
 bsr affichage_‚l‚ment

****
 rts

*
* Change l'inscription qui apparait sur le curseur selon l'intensit‚
* 
inscrit_valeur_curseur
 movem.l d0-a6,-(sp)
 move d1,d2
 and.l #$ff,d2
 move.l d2,d0
 move.l cadre_texte(a0),a1	Adresse du bloc de texte
 lea cadre_texte_message(a1),a1	Adresse de la chaine de texte
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

lecture_‚l‚ment
 movem.l d0/a0,-(sp)
 move (a0)+,d0			+0
 add affiche_x,d0
 move d0,x1
 move (a0)+,d0			+4
 add affiche_y,d0
 move d0,y1
 move (a0)+,largeur		
 move (a0)+,hauteur
 move (a0)+,‚paisseur
 move (a0)+,flag_relief
 move (a0)+,couleur_centre
 move (a0)+,couleur_cadre
 move.l (a0)+,adresse_routine
 move.l (a0)+,adresse_texte
 movem.l (sp)+,d0/a0
 rts

affichage_‚l‚ment
 move.l #-1,$ffff9800.w
 bsr cache_souris
 bsr trace_cadre
 bsr montre_souris
 move.l #0,$ffff9800.w
 rts

;%
;% Fonctionnement des cases de couleur.
;% - Clic bouton gauche: Prends la couleur pour l'‚diter
;% - Clic bouton droite: Met la couleur ‚dit‚e … la place.
;% - Reste appuy‚ gauche: Copie la couleur vers une autre case.
;% - Reste appuy‚ droite: Fait un d‚grad‚ jusqu'… une autre case.
;%
routine_s‚lectionne_couleur
 cmp #2,mousek
 beq .bouton_droit
.bouton_gauche
 moveq #10,d0
 bsr tempo
 bsr getmouse
 tst mousek
 beq .‚dite_couleur
.copie_couleur
 lea d‚f_titre_cadre,a0
 move.l #texte_copie_vers,cadre_texte(a0)	Affiche "COPIER VERS..."
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment
 bsr relache					Attend relachement
 bsr getmouse					Nouvelles coordonn‚es
 lea d‚f_titre_cadre,a0
 move.l #texte_titre_s‚lecteur,cadre_texte(a0)	R‚affiche le titre.
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment
 rts
 
.‚dite_couleur 
 move cadre_couleur(a0),couleur_‚dit‚e
 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu
 bsr relache
 rts
 
.bouton_droit 
 move couleur_‚dit‚e,cadre_couleur(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment
 bsr relache
 rts


affiche_x	dc.w 0
affiche_y	dc.w 0

routine_d‚place_cadre
 lea d‚f_titre_cadre,a0
 not cadre_relief(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment

 move mousex,click_x
 move mousey,click_y

 lea d‚f_s‚lecteur,a0
 move cadre_largeur(a0),d6
 move cadre_hauteur(a0),d7

 moveq #0,d0
 move d7,d0
 mulu #640,d0
 moveq #0,d5
 move d6,d5
 add d5,d5
 add.l d0,d5		Offset sur coin inf‚rieur droit du bloc.

 subq #1,d6
 subq #1,d7

 move.l ‚cran,a0
 move affiche_x,d0
 add d0,d0
 add d0,a0
 move affiche_y,d0
 mulu #640,d0
 add.l d0,a0
 move.l a0,a1
   
 bsr cache_souris
.attend_click
 bsr vsync
 bsr getmouse
 tst mousek
 beq .lache_click

 move mousex,d0
 sub click_x,d0

 move affiche_x,d1
 add d0,d1
 bpl .ok_min_x		On ‚vite de sortir par la gauche de l'‚cran !
 moveq #0,d0		Ca fait mauvais genre...
 sub affiche_x,d0
.ok_min_x 

 move affiche_x,d1	On est pas cens‚ non plus sortir par la droite.
 add d0,d1		Mais on ne sait jamais !
 add d6,d1
 cmp #319,d1
 blt .ok_max_x
 move #318,d0
 sub d6,d0
 sub affiche_x,d0
.ok_max_x 

 move d0,d‚placement_lat‚ral
 
 add d0,min_x
 add d0,max_x
 add d0,affiche_x
 add d0,d0
 add d0,a0


 move mousey,d0
 sub click_y,d0

 move affiche_y,d1
 add d0,d1
 bpl .ok_min_y		On ‚vite de sortir par le haut de l'‚cran !
 moveq #0,d0		C'est pas terrible non plus...
 sub affiche_y,d0
.ok_min_y

 move affiche_y,d1	Quand … la sortie par le bas de l'‚cran...
 add d0,d1		La honte !!!
 add d7,d1
 cmp #199,d1
 blt .ok_max_y
 move #198,d0
 sub d7,d0
 sub affiche_y,d0
.ok_max_y

 move d0,d‚placement_vertical
   
 add d0,min_y
 add d0,max_y
 add d0,affiche_y
 muls #640,d0
 add.l d0,a0

**** Transfert de bloc
 cmp.l a1,a0
 beq .pas_transfert
 bmi .remonte_bloc
.descend_bloc
 bsr vsync
 move.l a1,a2
 move.l a0,a3

 add.l d5,a2
 add.l d5,a3
 addq #2,a2
 addq #2,a3
   
 move d7,d4
 addq #1,d4
.copie_y1
 move d6,d3
 addq #1,d3
 move.l a2,a4
 move.l a3,a5
.copie_x1
 move -(a4),-(a5)
 dbra d3,.copie_x1
 lea -640(a2),a2
 lea -640(a3),a3
 dbra d4,.copie_y1
 bra .fin_transfert

.remonte_bloc
 bsr vsync

 move.l a1,a2
 move.l a0,a3

 move d7,d4
 addq #1,d4
.copie_y
 move d6,d3
 addq #1,d3
 move.l a2,a4
 move.l a3,a5
.copie_x
 move (a4)+,(a5)+
 dbra d3,.copie_x
 lea 640(a2),a2
 lea 640(a3),a3
 dbra d4,.copie_y

 bra .fin_transfert


.fin_transfert
 tst d‚placement_lat‚ral
 beq .pas_d‚placement_lat‚ral
 bmi .d‚placement_gauche
.d‚placement_droite
 bsr recopie_bande_gauche
 bra .pas_d‚placement_lat‚ral
.d‚placement_gauche
 bsr recopie_bande_droite
 bra .pas_d‚placement_lat‚ral
.pas_d‚placement_lat‚ral

 tst d‚placement_vertical
 beq .pas_d‚placement_vertical
 bmi .d‚placement_haut
.d‚placement_bas
 bsr recopie_bande_haut
 bra .pas_d‚placement_vertical
.d‚placement_haut
 bsr recopie_bande_bas
 bra .pas_d‚placement_vertical
.pas_d‚placement_vertical

.pas_transfert 
 
**** Fin de transfert de bloc

 move.l a0,a1
 move mousex,click_x
 move mousey,click_y
   
 bra .attend_click

.lache_click
 bsr montre_souris
 
 lea d‚f_titre_cadre,a0
 not cadre_relief(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment
 rts

d‚placement_lat‚ral	ds.w 1
d‚placement_vertical	ds.w 1


recopie_bande_haut
 move.l a1,a4
 sub.l ‚cran,a4
 add.l #image+44,a4 
 move.l a1,a2
 move d‚placement_vertical,d1
 subq #1,d1
.recopie_y
 move d6,d0		Largeur de la bande
 addq #1,d0
 move.l a2,a3
 move.l a4,a5
.recopie_x
 move (a5)+,(a3)+
 dbra d0,.recopie_x
 lea 640(a2),a2
 lea 640(a4),a4
 dbra d1,.recopie_y
 rts

recopie_bande_bas
 move.l a1,a2
 add.l d5,a2
 move.l a2,a4
 sub.l ‚cran,a4
 add.l #image+44,a4 
 addq #2,a2
 addq #2,a4
 move d‚placement_vertical,d1
 neg d1
 subq #1,d1
.recopie_y
 move d6,d0		Largeur de la bande
 addq #1,d0
 move.l a2,a3
 move.l a4,a5
.recopie_x
 move -(a5),-(a3)
 dbra d0,.recopie_x
 lea -640(a2),a2
 lea -640(a4),a4
 dbra d1,.recopie_y
 rts

recopie_bande_gauche
 move.l a1,a2
 move.l a1,a4
 sub.l ‚cran,a4
 add.l #image+44,a4 
 move d‚placement_lat‚ral,d4
 subq #1,d4
 move d7,d1
 addq #1,d1
.recopie_y
 move d4,d0
 move.l a2,a3
 move.l a4,a5
.recopie_x
 move (a5)+,(a3)+
 dbra d0,.recopie_x
 lea 640(a2),a2
 lea 640(a4),a4
 dbra d1,.recopie_y
 rts

recopie_bande_droite    
 move.l a1,a2
 add.l d5,a2
 move.l a2,a4
 sub.l ‚cran,a4
 add.l #image+44,a4 
 addq #2,a2
 addq #2,a4
 move d‚placement_lat‚ral,d4
 neg d4
 subq #1,d4
 move d7,d1
 addq #1,d1
.recopie_y
 move d4,d0
 move.l a2,a3
 move.l a4,a5
.recopie_x
 move -(a5),-(a3)
 dbra d0,.recopie_x
 lea -640(a2),a2
 lea -640(a4),a4
 dbra d1,.recopie_y
 rts

mode_visu	dc.w 0	(0=RVB/1=CMJ/2=HSV)

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
 move #-1,cadre_relief(a0)
 move #22*2048+00*32+00,cadre_couleur(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_glissiŠre_rouge,a0
 move #20*2048+28*32+14,cadre_couleur(a0)
 lea d‚f_glissiŠre_vert,a0
 move #14*2048+40*32+14,cadre_couleur(a0)
 lea d‚f_glissiŠre_bleu,a0
 move #14*2048+28*32+20,cadre_couleur(a0)

 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu

 move #0,mode_visu
 bsr relache
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
 rts
 cmp #1,mode_visu
 beq .fin_cmj
 bsr d‚s‚lectionne_mode_visu
 lea d‚f_bouton_cmj,a0
 move #-1,cadre_relief(a0)
 move #22*2048+00*32+00,cadre_couleur(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_glissiŠre_rouge,a0
 move #14*2048+40*32+20,cadre_couleur(a0)
 lea d‚f_glissiŠre_vert,a0
 move #20*2048+28*32+20,cadre_couleur(a0)
 lea d‚f_glissiŠre_bleu,a0
 move #20*2048+40*32+14,cadre_couleur(a0)

 bsr routine_positionne_rouge
 bsr routine_positionne_vert
 bsr routine_positionne_bleu

 move #1,mode_visu
 bsr relache
.fin_cmj
 rts
 
routine_choisie_hsv
 rts				*** Pas de HSV pour l'instant !
 cmp #2,mode_visu
 beq .fin_hsv
 bsr d‚s‚lectionne_mode_visu
 lea d‚f_bouton_hsv,a0
 move #-1,cadre_relief(a0)
 move #22*2048+00*32+00,cadre_couleur(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment
 move #2,mode_visu
 bsr relache
.fin_hsv
 rts

d‚s‚lectionne_mode_visu
 lea d‚f_bouton_hsv,a0
 cmp #2,mode_visu
 beq.s .reset_bouton
 lea d‚f_bouton_cmj,a0
 cmp #1,mode_visu
 beq.s .reset_bouton
 lea d‚f_bouton_rvb,a0
.reset_bouton 
 clr cadre_relief(a0)
 move #14*2048+28*32+14,cadre_couleur(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment
 rts

routine_fermeture_palette 
 st flag_ferme_formulaire
 rts
    
 section DATA 

 even

image		incbin D:\GRAPHES\<_IMAGES.__>\TCP\FREYDA_2.TCP
 
fonte		incbin ..\fichiers.inc\6x6_fnt.tru
couleurs	incbin couleurs.tru
 dcb 100,-1
 
table_couleur_grise
 code_rvb 31,63,31	Blanc
 code_rvb 24,48,24	Gris clair
 code_rvb 16,32,16	Gris
 code_rvb 12,24,12	Gris sombre
 code_rvb 10,20,10	Noir

table_d‚grad‚
var set 0
 rept 32
var1 set var+(32-var)*50/100
var2 set var+(32-var)*35/100
 dc.w var1,var2
 dc.w var
var1 set var*70/100
var2 set var*50/100
 dc.w var1,var2
var set var+1 
 endr

*
* Explication du format:
* .w (x,y)		Coordonn‚es du point en haut … gauche
* .w (l,h)		Largeur et hauteur du cadre
* .w (‚paisseur)	Nombre de bordures … tracer
* .w (relief)		Creu (-1) ou bosse (0)
* .w (couleur centre)
* .w (couleur cadre)	Gris (0) ou de la couleur principale (-1)
* .l (s‚lection)	Adresse de la routine de gestion, sinon (0)
* .l (texte)		Adresse d'un chaine de caractŠres, sinon (0)

d‚f_s‚lecteur
 dc.w 000,000,113,150,0,0	Cadre principal
 code_rvb 16,32,16		GRIS
 dc.w 0
 dc.l 0,0

 dc.w 001,001,010,010,0,0	Case de fermeture en haut … gauche
 code_rvb 0,32,0		VERT
 dc.w -1
 dc.l routine_fermeture_palette,texte_case_fermeture

d‚f_titre_cadre
 dc.w 013,001,099,010,0,0	Entete pour le titre
 code_rvb 0,32,0		VERT
 dc.w -1
 dc.l routine_d‚place_cadre,texte_titre_s‚lecteur

 dc.w 001,013,111,136,0,0	Partie inf‚rieure
 code_rvb 16,32,16		GRIS
 dc.w 0
 dc.l 0,0

 dc.w 005,017,018,010,0,0	Bouton ROUGE +
 code_rvb 14,28,14		GRIS
 dc.w 0
 dc.l routine_incr‚mente_rouge,texte_plus_rouge

d‚f_glissiŠre_rouge
 dc.w 005,029,018,075,0,-1	GlissiŠre curseur rouge
 code_rvb 20,28,14		ROUGE PALE
 dc.w 0
 dc.l 0,0
d‚f_curseur_rouge
 dc.w 006,030,016,010,0,0	Curseur rouge
 code_rvb 31,0,0		ROUGE
 dc.w 0
 dc.l routine_curseur_rouge,texte_valeur_rouge

 dc.w 005,106,018,010,0,0	Bouton ROUGE -
 code_rvb 14,28,14		GRIS
 dc.w 0
 dc.l routine_d‚cr‚mente_rouge,texte_moins_rouge

 dc.w 027,017,018,010,0,0	Bouton VERT +
 code_rvb 14,28,14		GRIS
 dc.w 0
 dc.l routine_incr‚mente_vert,texte_plus_vert

d‚f_glissiŠre_vert
 dc.w 027,029,018,075,0,-1	GlissiŠre curseur vert
 code_rvb 14,36,14		VERT PALE
 dc.w 0
 dc.l 0,0
d‚f_curseur_vert
 dc.w 028,030,016,010,0,0	Curseur vert
 code_rvb 0,61,0		VERT
 dc.w 0
 dc.l routine_curseur_vert,texte_valeur_vert

 dc.w 027,106,018,010,0,0	Bouton VERT -
 code_rvb 14,28,14		GRIS
 dc.w 0
 dc.l routine_d‚cr‚mente_vert,texte_moins_vert

 dc.w 049,017,018,010,0,0	Bouton BLEU +
 code_rvb 14,28,14		GRIS
 dc.w 0
 dc.l routine_incr‚mente_bleu,texte_plus_bleu
 
d‚f_glissiŠre_bleu
 dc.w 049,029,018,075,0,-1	GlissiŠre curseur bleu
 code_rvb 14,28,20		BLEU PALE
 dc.w 0
 dc.l 0,0
d‚f_curseur_bleu
 dc.w 050,030,016,010,0,0	Curseur bleu
 code_rvb 0,0,31		BLEU
 dc.w 0
 dc.l routine_curseur_bleu,texte_valeur_bleu

 dc.w 049,106,018,010,0,0	Bouton BLEU -
 code_rvb 14,28,14		GRIS
 dc.w 0
 dc.l routine_d‚cr‚mente_bleu,texte_moins_bleu

d‚f_bouton_rvb
 dc.w 071,017,020,008,0,-1	Bouton RVB
 code_rvb 22,0,0		GRIS
 dc.w 0
 dc.l routine_choisie_rvb,texte_rvb

d‚f_bouton_cmj
 dc.w 071,027,020,008,0,0	Bouton CMJ
 code_rvb 14,28,14		GRIS
 dc.w 0
 dc.l routine_choisie_cmj,texte_cmj

d‚f_bouton_hsv
 dc.w 071,037,020,008,0,0	Bouton HSV
 code_rvb 14,28,14		GRIS
 dc.w 0
 dc.l routine_choisie_hsv,texte_hsv

d‚f_couleur_‚dit‚e
 dc.w 005,119,062,020,0,-1	La case qui contient la couleur en
couleur_‚dit‚e
 dc.w 0,-1			cours d'‚dition.
 dc.l 0,0


* dc.w 70,020,064,010,0,-1	Cadre en creu du Bouton
* dc.w (16*2048)+(32*32)+(16),0	Un gris
* dc.l 0,0
* dc.w 71,021,062,008,0,0	Le bouton ECLAIRCIR
* dc.w (16*2048)+(32*32)+(16),0	Un gris
* dc.l 0,texte_bouton_‚claircir

* dc.w 70,040,064,010,0,-1	Cadre en creu du Bouton
* dc.w (16*2048)+(32*32)+(16),0	Un gris
* dc.l 0,0
* dc.w 71,041,062,008,0,0	Le bouton ASSOMBRIR
* dc.w (16*2048)+(32*32)+(16),0	Un gris
* dc.l 0,texte_bouton_assombrir

* dc.w 138,020,048,010,0,-1	Cadre en creu du Bouton pipette
* dc.w (16*2048)+(32*32)+(16),0	Un gris
* dc.l 0,0
* dc.w 139,021,046,008,0,0	Le bouton PIPETTE lui meme
* dc.w (16*2048)+(32*32)+(16),0	Un gris
* dc.l 0,texte_bouton_pipette

***** La s‚rie de 40 cases en creu avec les couleurs accessibles au clavier 

d‚but_cases
y_pos set 48
 rept 10
 case_couleur 071,y_pos
 case_couleur 081,y_pos
 case_couleur 091,y_pos
 case_couleur 101,y_pos
y_pos set y_pos+10
 endr
 
 dc.w -1
 
* Format des chaines de caractŠre:
* .w (Offset X)
* .w (Offset Y)
* .w (Couleur d'affichage)

texte_titre_s‚lecteur
 dc.w 22,2
 code_rvb 31,63,31
 dc.b "PALETTE",0
 even

texte_copie_vers
 dc.w 2,2
 code_rvb 31,0,0
 dc.b "COPIER VERS...",0
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

texte_plus_lumiŠre
 dc.w 6,2,31
 dc.b "+",0
 even

texte_moins_lumiŠre
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

texte_valeur_lumiŠre
 dc.w 2,2,-1
 dc.b "63",0
 even

texte_bouton_‚claircir
 dc.w 0,1,0
 dc.b "ECLAIRCIR",0
 
texte_bouton_assombrir
 dc.w 0,1,0
 dc.b "ASSOMBRIR",0

texte_rvb
 dc.w 1,1
 code_rvb 31,63,31
 dc.b "RVB",0

texte_cmj
 dc.w 1,1
 code_rvb 31,63,31
 dc.b "CMJ",0

texte_hsv
 dc.w 1,1
 code_rvb 31,63,31
 dc.b "HSV",0

texte_case_fermeture 
 dc.w 2,2,0
 dc.b "",0
 even

texte_bouton_pipette
 dc.w 2,1,0
 dc.b "PIPETTE",0
 even
   
 even

  
table_couleurs
var set 0
 rept 40
 dc.l d‚but_cases+var+12
var set var+24
 endr

‚cran		dc.l ecran
largeur_‚cran	dc.w 640
couleur		dc.w (21*2048)+(10*32)+(25)

 section BSS

min_x	ds.w 1
max_x	ds.w 1
min_y	ds.w 1
max_y	ds.w 1

x1	ds.w 1
y1	ds.w 1
x2	ds.w 1
y2	ds.w 1
largeur	ds.w 1
hauteur	ds.w 1
‚paisseur	ds.w 1
flag_relief	ds.w 1
couleur_centre	ds.w 1
couleur_cadre	ds.w 1
adresse_routine	ds.l 1
adresse_texte	ds.l 1

old_video	ds.w 1 
old_adresse	ds.w 1
mousex		ds.w 1
mousey		ds.w 1
mousek		ds.w 1

flag_ferme_formulaire	ds.w 1

 ds.l 10000
 ds.l 128000/4
ecran		ds.l 128000/4
 ds.l 128000/4
 ds.l 10000

 end
 

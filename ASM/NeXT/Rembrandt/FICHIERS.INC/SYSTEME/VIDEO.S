; REMBRANDT 3.0 - Ω  Dbug II
;
; Module de gestion des rÇsolution Falcon. (1.2)
; - ImplÇmentation du scrolling Hard. (DÇbrayable)
; - Mode VGA gÇrÇ
; - Toutes les rÇsolutions systäme acceptÇe (dont Overscan)
;
; Remarques importantes:
; - La fonction XBIOS(5) effectue tous les tests qu'il faut avant
; d'accepter une rÇsolution, tandis que XBIOS(88) ne le fait pas.
; En pratique, on peut donc obtenir 400(480) lignes en RVB comme en VGA
; en utilisant XBIOS(5), avec le meme mot de code si l'on ne prÇcise pas
; que l'on veut du VGA. Si l'on prÇcise que c'est du VGA, on doit inverser
; le bit Ædouble hauteurØ... Pas cool !
;
 ifeq _main_part
 <pREMB_xxx.S>q doit àtre assemblÇ !!!
 END
 endc

 TEXT

trap_88=0
 
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


;
; Ces 3 routines permettent de changer la rÇsolution de l'image directement
; depuis la page de travail (On ne sera pas obligÇ de revenir sous GEM).
;
commute_largeur_Çcran
 tst.s flag_vga
 bne.s .pas_avec_vga
 not.b flag_double_largeur
 bsr recopie_Çcran
 bsr effectue_changement_contexte
.pas_avec_vga
 rts
 
commute_hauteur_Çcran
 not.b flag_double_hauteur
 bsr recopie_Çcran
 bsr effectue_changement_contexte
 rts
 
commute_overscan_Çcran
 tst.s flag_vga
 bne.s .pas_avec_vga
 not.b flag_overscan
 bsr recopie_Çcran
 bsr effectue_changement_contexte
.pas_avec_vga
 rts


effectue_changement_contexte
 bsr cache_zoomer_sÇlecteur
 bsr cache_curseur
 bsr restaure_interruptions

 bsr valide_paramÇtrages

 lea Çcran,a0
 move.l taille_Çcran,d0
 bsr realloc

 
 bsr commute_rÇsolution

 bsr installe_souris_absolu

 bsr installe_interruptions
 bsr teste_hbl_hard
 bsr affiche_image		Affiche l'image Ö l'Çcran
 bsr initialise_zoomer
 bsr montre_curseur
 bsr montre_zoomer_sÇlecteur
 rts






calcule_rÇsolution_spÇciale
 bsr calcule_dimensions
 move dim_largeur_Çcran,largeur_Çcran
 move dim_hauteur_Çcran,hauteur_Çcran
 move dim_largeur_visible,largeur_visible
 move dim_hauteur_visible,hauteur_visible
 move.l dim_taille_Çcran,taille_Çcran
 move dim_mode_rÇsolution,mode_rÇsolution
 move dim_linewidth,linewidth

 bsr calcule_clipping
 clr x_scroll
 clr y_scroll
 rts
 

; A partir des dimensions de l'image, et des indications concernant le mode
; d'affichage, cette fonction calcule les dimensions de l'Çcran (totale/visible),
; la taille de l'Çcran, ainsi que le mot de code pour la fonction Xbios(5).
; Les rÇsultats sont stockÇs dans des variables portant le prÇfixe DIM_
;
calcule_dimensions
 movem.l d0/d1,-(sp)
  
 moveq #4,d0			On est en mode TrueColor 16 bits...	

 tst.b flag_vga			En VGA, le mode 80 colonnes n'est pas
 bne.s .valide_simple_colonnes	accessible...

 tst.b flag_double_largeur	On est en 40 ou en 80 colonnes ???
 beq.s .valide_simple_colonnes	(Broadcast uniquement...)
.valide_double_colonnes
 addq #8,d0			Mode 80 colonnes
 move #1280,dim_largeur_Çcran
 bra.s .teste_double_ligne
.valide_simple_colonnes  
 move #640,dim_largeur_Çcran

.teste_double_ligne
 tst.b flag_double_hauteur
 beq.s .valide_simple_ligne
.valide_double_ligne
 add #256,d0 
 move #400,dim_hauteur_Çcran
 bra.s .teste_overscan
.valide_simple_ligne
 move #200,dim_hauteur_Çcran

.teste_overscan 
 tst.b flag_vga
 bne.s .valide_normal
 tst.b flag_overscan
 beq.s .valide_normal
.valide_overscan
 add #64,d0
 move dim_largeur_Çcran,d1
 mulu #12,d1
 divu #10,d1
 move d1,dim_largeur_Çcran 
 move dim_hauteur_Çcran,d1
 mulu #12,d1
 divu #10,d1
 move d1,dim_hauteur_Çcran 
 bra.s .mÇmorise_rÇsolution
.valide_normal

.mÇmorise_rÇsolution
 tst.b flag_vga			En mode VGA, par contre, on peut
 beq.s .pas_vertical_Çtendu	multiplier par 1,2 la rÇsolution
 move dim_hauteur_Çcran,d1	verticale ! [Mwaii... Bof)
 mulu #12,d1
 divu #10,d1
 move d1,dim_hauteur_Çcran 
 add #16,d0			Mode VGA
 bchg #8,d0			En VGA, le bit Ædouble hauteur a une autre signification !Ø
.pas_vertical_Çtendu

 add #32,d0			Mode PAL (50hz)
 
 move d0,dim_mode_rÇsolution

 clr dim_linewidth
 
 move dim_largeur_Çcran,dim_largeur_visible
 move dim_hauteur_Çcran,dim_hauteur_visible

 move largeur_image,d0
 cmp dim_largeur_Çcran,d0
 ble.s .ok_largeur
 sub dim_largeur_Çcran,d0		DiffÇrence en octets
 lsr d0					DiffÇrence en mots (???)
 btst #0,d0
 beq.s .largeur_paire
 addq #1,d0				On prend le pair supÇrieur
 move d0,dim_linewidth
 move largeur_image,dim_largeur_Çcran	Puis rajoute un pixel sur 
 addq #2,dim_largeur_Çcran			l'Çcran.
 bra.s .ok_largeur
.largeur_paire
 move d0,dim_linewidth
 move largeur_image,dim_largeur_Çcran
.ok_largeur

 move hauteur_image,d0
 cmp dim_hauteur_Çcran,d0
 ble.s .ok_hauteur
 move hauteur_image,dim_hauteur_Çcran
.ok_hauteur
 
 move dim_largeur_Çcran,d0
 mulu dim_hauteur_Çcran,d0
 move.l d0,dim_taille_Çcran

 movem.l (sp)+,d0/d1
 rts

*
* Tous les dÇplacement de blocs ou de ressources doivent se faire dans
* un cadre qui reprÇsente la plus petite taille en X et en Y de l'Çcran
* et de l'image (C'est'y assez clair ???)
*
calcule_clipping
 move largeur_image,d0
 move largeur_Çcran,d1
 cmp d0,d1
 bgt .pas_Çchange_x
 exg d0,d1
.pas_Çchange_x
 move d0,largeur_maximum

 move hauteur_image,d0
 move hauteur_Çcran,d1
 cmp d0,d1
 bgt .pas_Çchange_y
 exg d0,d1
.pas_Çchange_y
 move d0,hauteur_maximum
 rts


 
 

commute_rÇsolution  
 bsr vsync
 clr x_scroll
 clr y_scroll
 ifeq trap_88
   move mode_rÇsolution,-(sp)	Change la rÇsolution comme on le veut...
   move #3,-(sp)
   move.l Çcran,-(sp)
   move.l Çcran,-(sp)
   move #5,-(sp)
   trap #14
   lea 14(sp),sp
 elseif
   move mode_rÇsolution,-(sp)	Change la rÇsolution comme on le veut...
   move #88,-(sp)
   trap #14
   addq #4,sp
   move.l Çcran,d0
   move d0,d1
   lsr.l #8,d0
   move.b d0,$ffff8203.w
   lsr #8,d0
   move.b d0,$ffff8201.w
   move.b d1,$ffff820d.w 
 endc
 move $ffff82c2.w,sauve_vco
 move linewidth,$ffff820e.w
 
 clr.l $ffff9800.w		Met le cadre en noir
 lea Çcran,a0
 bsr efface_bloc
 rts


 
teste_moniteur 
 move #89,-(sp)		C'est utile de savoir si on est en VGA, ou en
 trap #14		mode BROADCAST !!! (Ou en monochrome !)
 addq #2,sp
 move d0,type_moniteur

 sf flag_vga
 cmp #2,d0
 bne .pas_vga
 bsr exÇcute_spÇcifique_vga
.pas_vga
  
 move #objet_type_moniteur*24,d1	Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 lea choix_moniteur,a1
 move.l (a1,d0.w*4),([ob_spec,a0,d1.w])	Change le ptr de texte !
 rts


exÇcute_spÇcifique_vga
 st flag_vga

 move #objet_txt_overscan*24,d1		Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 bset.b #state_disabled,ob_state+1(a0,d1.w)

 move #objet_txt_dbl_largeur*24,d1	Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 bset.b #state_disabled,ob_state+1(a0,d1.w)

 move #objet_overscan*24,d1		Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 bset.b #state_disabled,ob_state+1(a0,d1.w)
 bclr.b #flag_selectable,ob_flags+1(a0,d1.w)

 move #objet_double_largeur*24,d1	Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 bset.b #state_disabled,ob_state+1(a0,d1.w)
 bclr.b #flag_selectable,ob_flags+1(a0,d1.w)
 rts


gäre_scrolling
 tst.b flag_scrolling
 beq .scrolling_terminÇ
 
 move mousex_118,souris_x
 move mousey_118,souris_y

**************** Le scrolling vers la gauche

 move souris_x,d0
 cmp #16,d0
 bpl.s .pas_scroll_gauche
 moveq #16,d1
 sub d0,d1
 sub d1,x_scroll
 bpl.s .pas_scroll_gauche
 clr x_scroll
.pas_scroll_gauche

**************** Le scrolling vers la droite

 move largeur_visible,d7
 lsr d7				Largeur en pixels
 subq #1,d7			CoordonnÇe du dernier pixel Ö droite.

 move souris_x,d0
 move d7,d6
 sub #16,d6			CoordonnÇe du 16äme pixel partant de droite.
 cmp d6,d0
 ble.s .pas_scroll_droite
 sub d6,d0
 add d0,x_scroll
 move largeur_Çcran,d0
 sub largeur_visible,d0
 lsr d0
 cmp x_scroll,d0
 bge.s .pas_scroll_droite
 move d0,x_scroll		* Normalement, 40 pixels (360-320)
.pas_scroll_droite

**************** Le scrolling vers le haut

 move souris_y,d0
 cmp #16,d0
 bpl.s .pas_scroll_haut
 tst y_scroll
 beq.s .pas_scroll_haut
 moveq #16,d1
 sub d0,d1
 sub d1,y_scroll
 bpl.s .pas_scroll_haut
 clr y_scroll
.pas_scroll_haut

**************** Le scrolling vers le bas

 move hauteur_visible,d7
* subq #1,d7			CoordonnÇe du dernier pixel en bas

 move souris_y,d0
 move d7,d6
 sub #16+1,d6			CoordonnÇe du 16äme pixel partant du bas
 cmp d6,d0
 ble.s .pas_scroll_bas
 sub d6,d0
 add d0,y_scroll
 move hauteur_Çcran,d0
 sub d7,d0			hauteur_visible
 cmp y_scroll,d0
 bge.s .pas_scroll_bas
 move d0,y_scroll		* Normalement, 40 pixels (360-320)
.pas_scroll_bas

.scrolling_terminÇ
 bsr dÇplace_Çcran 
 rts


dÇplace_Çcran
 move.l Çcran,d0
 move y_scroll,d1
 muls largeur_Çcran,d1
 add.l d1,d0
 move x_scroll,d1
 bclr #0,d1			Que tous les 2 pixels !
 ext.l d1
 add.l d1,d1
 add.l d1,d0
 move.l d0,Çcran_scroll
 rts

dÇbrayage_scrolling
 not.b flag_scrolling
 bsr sÇlecteur_informations
 rts


   
 DATA
 
 even
 
choix_moniteur
 dc.l txt_moniteur_monochrome
 dc.l txt_moniteur_couleur
 dc.l txt_moniteur_vga
 dc.l txt_moniteur_broadcast
 
txt_moniteur_monochrome	dc.b "VISU N&B",0
txt_moniteur_couleur	dc.b "VISU COULEUR",0
txt_moniteur_vga	dc.b "MONITEUR VGA",0
txt_moniteur_broadcast	dc.b "TêLêVISION",0

 even

 
 BSS

 even
 
type_moniteur		ds.w 1
mode_rÇsolution		ds.w 1 
flag_double_largeur	ds.w 1
flag_double_hauteur	ds.w 1
flag_overscan		ds.w 1
flag_vga		ds.w 1
flag_scrolling		ds.w 1

linewidth		ds.w 1
sauve_vco		ds.w 1

x_scroll		ds.w 1
y_scroll		ds.w 1

souris_x		ds.w 1
souris_y		ds.w 1

largeur_visible		ds.w 1
hauteur_visible		ds.w 1
Çcran_scroll		ds.l 1

sauve_9800		ds.l 1
sauve_linewidth		ds.w 1

dim_largeur_Çcran	ds.w 1
dim_hauteur_Çcran	ds.w 1
dim_largeur_visible	ds.w 1
dim_hauteur_visible	ds.w 1
dim_mode_rÇsolution	ds.w 1
dim_linewidth		ds.w 1
dim_taille_Çcran	ds.l 1

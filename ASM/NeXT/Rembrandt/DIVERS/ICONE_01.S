*
*
* Le but est d'afficher un cadre en relief
*
*

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

 include ressourc.s
 
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

 move.l #s‚lecteur_outils,adresse_ressource
 sf flag_ferme_formulaire

 bsr cache_souris
 bsr d‚code_ressource
 bsr montre_souris

 bsr gere_s‚lecteur
   
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

routine_fermeture_outils
 lea d‚f_case_fermeture,a0
 not cadre_relief(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment
 bsr relache
 not cadre_relief(a0)
 bsr lecture_‚l‚ment
 bsr affichage_‚l‚ment
 st flag_ferme_formulaire
 rts


routine_outils_crayon
 bsr routine_reset_icones
 rts
 
routine_outils_peinture
 bsr routine_reset_icones
 rts
 
routine_outils_carres
 bsr routine_reset_icones
 rts
 
routine_outils_ronds
 rts
 
routine_outils_lignes
 bsr routine_reset_icones
 rts

routine_reset_icones
 move.l adresse_icone_choisie,a0
 clr cadre_cadre(a0)
 rts

adresse_icone_choisie	dc.l 0
     
 section DATA 

 even

image		incbin D:\GRAPHES\<_IMAGES.__>\TCP\FREYDA_2.TCP
icone_crayon	incbin ..\fichiers.inc\crayon.icn
icone_gomme	incbin ..\fichiers.inc\gomme.icn
icone_peinture	incbin ..\fichiers.inc\peinture.icn
icone_carres	incbin ..\fichiers.inc\carres.icn
icone_ronds	incbin ..\fichiers.inc\ronds.icn
icone_lignes	incbin ..\fichiers.inc\lignes.icn
 
*
* Explication du format:
* .w (x,y)		Coordonn‚es du point en haut … gauche
* .w (l,h)		Largeur et hauteur du cadre
* .w (‚paisseur)	Nombre de bordures … tracer
* .w (relief)		Creu (-1) ou bosse (0)
* .w (couleur centre)
* .w (couleur cadre)	Gris (0) ou de la couleur principale (-1)
* .w (touche)		Scan.b + Ascii.b, ou 0 si pas de touche...
* .l (s‚lection)	Adresse de la routine de gestion, sinon (0)
* .l (texte)		Adresse d'un chaine de caractŠres, sinon (0)

 dc.l routine_ferme_outils
s‚lecteur_outils
 dc.w 000,000,104,36,0,0	Cadre principal
 code_rvb 16,32,16		GRIS
 dc.w 0,0
 dc.l 0,0

d‚f_case_fermeture
 dc.w 001,001,010,010,0,0	Case de fermeture en haut … gauche
 code_rvb 0,32,0		VERT
 dc.w -1,0
 dc.l routine_fermeture_palette,texte_case_fermeture

d‚f_titre_cadre
 dc.w 013,001,090,010,0,0	Entete pour le titre
 code_rvb 0,32,0		VERT
 dc.w -1,0
 dc.l routine_d‚place_cadre,texte_titre_s‚lecteur

 dc.w 001,013,102,22,0,0	Partie inf‚rieure
 code_rvb 16,32,16		GRIS
 dc.w 0,0
 dc.l 0,0

d‚f_outils_crayon
 dc.w 002,014,019,019,0,0
 code_rvb 0,0,0
 dc.w 0,0
 dc.l routine_outils_crayon,texte_icone_crayon

  
d‚f_outils_lignes
 dc.w 022,014,019,019,0,0
 code_rvb 31,0,0
 dc.w -1,0
 dc.l routine_outils_lignes,texte_icone_lignes

d‚f_outils_peinture
 dc.w 042,014,019,019,0,0
 code_rvb 0,0,0
 dc.w 0,0
 dc.l routine_outils_peinture,texte_icone_peinture

d‚f_outils_carres
 dc.w 062,014,019,019,0,0
 code_rvb 0,0,0
 dc.w 0,0
 dc.l routine_outils_carres,texte_icone_carres

d‚f_outils_ronds
 dc.w 082,014,019,019,0,0
 code_rvb 0,0,0
 dc.w 0,0
 dc.l routine_outils_ronds,texte_icone_ronds
  
 dc.w -1
 
* Format des chaines de caractŠre:
* .w (Offset X)
* .w (Offset Y)
* .w (Couleur d'affichage)
* .b... (Texte … afficher suivi de 0)
*   ... Si ‚gal … 0, alors est suivi d'un .L qui est l'adresse d'un bloc
*   ... graphique TRUE COLOR au format suivant:
*   ... .w = Largeur
*   ... .w = Hauteur
*   ... .w... Le dessin lui meme.
 

texte_titre_s‚lecteur
 dc.w 22,2
 code_rvb 31,63,31
 dc.b "OUTILS",0
 even

texte_case_fermeture 
 dc.w 2,2
 code_rvb 0,0,0
 dc.b "",0
 even

texte_icone_crayon
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_crayon  

texte_icone_gomme
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_gomme

texte_icone_peinture
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_peinture

texte_icone_carres
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_carres

texte_icone_ronds
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_ronds

texte_icone_lignes
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_lignes

‚cran		dc.l ecran
largeur_‚cran	dc.w 640

 section BSS

old_video	ds.w 1 
old_adresse	ds.w 1
mousex		ds.w 1
mousey		ds.w 1
mousek		ds.w 1

 ds.l 10000
 ds.l 128000/4
 cnop 0,4
 ds.w 1
ecran		ds.l 128000/4
 ds.l 128000/4
 ds.l 10000

 end
 

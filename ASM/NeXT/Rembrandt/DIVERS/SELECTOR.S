*
*
* Gestion du S‚lecteur de couleur
*
*

couleur=0
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
 move #mode,-(sp)
 move #3,-(sp)
 pea ecran
 pea ecran
 move #5,-(sp)
 trap #14
 add #14,sp

 bsr gŠre_s‚lecteur

 move #7,-(sp)
 trap #1
 addq #2,sp
 
;
; Restaure tout
; 
 move #37,-(sp)
 trap #14
 addq #2,sp
  
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 rts
 
 
gŠre_s‚lecteur
 lea s‚lecteur,a0
 move.l ‚cran,a1
 add #40,a1 
 move #151-1,d1
.recopie_y
 move.l a1,a2
 move #183-1,d0
.recopie_x
 move (a0)+,(a2)+
 dbra d0,.recopie_x
 add largeur_‚cran,a1
 dbra d1,.recopie_y 
 rts
   
 section DATA 

s‚lecteur	incbin ..\fichiers.inc\selector.tru
  
‚cran		dc.l ecran
largeur_‚cran	dc.w 640

 section BSS

old_video	ds.w 1 
old_adresse	ds.w 1
 ds.l 10000
ecran		ds.l 128000/4
 end
 
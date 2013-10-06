*
*
* Routine de d‚bugging pour Rembrandt.
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

 bsr affiche_debugging

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
 
 

affiche_debugging
 lea message,a0
 lea fonte,a1
 move.l ‚cran,a2
lettre_suivante
 moveq #0,d0
 move.b (a0)+,d0 
 beq fin_message
 lsl #7,d0
 lea (a1,d0.w),a3
 move.l a2,a4
 moveq #8-1,d0
.affiche_lettre
 move.l (a3)+,(a4)
 move.l (a3)+,4(a4)
 move.l (a3)+,8(a4)
 move.l (a3)+,12(a4)
 add largeur_‚cran,a4
 dbra d0,.affiche_lettre 
 lea 16(a2),a2
 bra lettre_suivante
 
fin_message 
 rts
   
 section DATA 

fonte	incbin fonte.tru

message
 dc.b "Dbug II analysor Ver 0.01 á"
 dc.b 0
  
‚cran		dc.l ecran
largeur_‚cran	dc.w 640

 section BSS

old_video	ds.w 1 
old_adresse	ds.w 1
 ds.l 10000
ecran		ds.l 128000/4
 end
 
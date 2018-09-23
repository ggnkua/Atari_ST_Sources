debug=1
*
*
* Petite routine … la con destin‚e a convertir une image
* DEGAS en image TRUE COLOR
*
*
* bsr trace_ligne

point macro
 move.l ‚cran(pc),a0
 move \1,d0
 add d0,d0
 add d0,a0
 move \2,d0
 mulu #640,d0
 add.l d0,a0
 move #\3,(a0)
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
 ifeq debug
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
 endc
 
attend_touche
 dc.w $a000
 move -602(a0),x2
 move -600(a0),y2
 tst.w -596(a0)
 bne fin_boucle

 move #$7000,$ffff9800.w
 move #50,x1
 move #50,y1
 move #160,x2
 move #0,y2
* move #300,x2
* move #150,y2
 move #$8732,couleur
 move.l #ecran,‚cran
 bsr trace_ligne
 point x1,y1,%1111100000000000
 point x2,y2,%11111
 move #-1,$ffff9800.w

 move #37,-(sp)
 trap #14
 addq #2,sp
 
 bra attend_touche

fin_boucle

;
; Restaure tout
; 
 ifeq debug
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc
 rts
 

 include inc_line.s 
  
 section DATA 

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
 
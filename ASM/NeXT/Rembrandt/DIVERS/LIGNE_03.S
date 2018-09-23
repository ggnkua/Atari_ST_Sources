*
*
* Petite routine … la con destin‚e a convertir une image
* DEGAS en image TRUE COLOR
*
*
* bsr trace_ligne

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

attend_touche
 dc.w $a000
 move -602(a0),x1+2
 move -600(a0),y1+2
 tst.w -596(a0)
 bne.s fin_boucle

 move #$7000,$ffff9800.w
 bsr.s trace_ligne
 move #-1,$ffff9800.w

 move #37,-(sp)
 trap #14
 addq #2,sp
 
 bra.s attend_touche

fin_boucle

;
; Restaure tout
; 
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 rts
 
 

x1	dc.l 1
y1	dc.l 199

x2	dc.l 160
y2	dc.l 100

largeur=45
hauteur=185

*ix=0.2432433243... = 15941 
*iy=1

trace_ligne

 move.l x2,d0
 move.l x1,d1
 sub.l d1,d0 		d0 = Largeur
 bpl.s .largeur_positive
 neg.l d0		d0 = ABS(Largeur)
.largeur_positive
 addq.l #1,d0
   
 move.l y2,d1
 move.l y1,d2
 sub.l d2,d1		d1 = Hauteur
 bpl.s .hauteur_positive
 neg.l d1		d1 = ABS(hauteur)
.hauteur_positive
 addq.l #1,d1

*** d0=ABS(largeur) /DX
*** d1=ABS(hauteur) /DY
*** d5=ix
*** d6=iy
*** d7=nombre de points

 cmp.l d1,d0
 bge.s largeur_max
hauteur_max
 move d1,d7		Nombre de points=hauteur
 subq #1,d7
 move d0,d5
 swap d5
 divu.l d1,d5		IX=DX/DY
 move.l #1*65536,d6	IY=1
 bra.s inverse_incr‚ment
 
largeur_max
 move d0,d7		Nombre de points=largeur
 subq #1,d7
 move.l #1*65536,d5	IX=1
 move d1,d6
 swap d6
 divu.l d0,d6		IY=DY/DX
 bra.s inverse_incr‚ment

 nop
   
inverse_incr‚ment
 moveq #0,d0	Partie d‚cimale de X
 move.l x1,d1	Partie entiŠre de X
 cmp.l x2,d1
 ble ok_x
 neg.l d5
ok_x

 moveq #0,d2	Partie d‚cimale de Y
 move.l y1,d3	Partie entiŠre de Y
 cmp.l y2,d3
 ble ok_y
 neg.l d6
ok_y
 
.loop 
 lea ecran,a0
 add.l d1,a0		X x2
 add.l d1,a0
 move.l d3,d4		Y x640
 mulu.l #640,d4
 add.l d4,a0
 move #couleur,(a0)

 add.l d5,d0		Incr‚mente en X
 add.l d6,d1
 exg d5,a5
 exg d6,a6
 add.l d5,d2		Incr‚mente en Y
 add.l d6,d3
 exg d5,a5
 exg d6,a6
 dbra d7,.loop
 rts
  
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
 
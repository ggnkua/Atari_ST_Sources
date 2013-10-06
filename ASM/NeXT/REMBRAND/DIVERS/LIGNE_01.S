*
*
* Petite routine … la con destin‚e a convertir une image
* DEGAS en image TRUE COLOR
*
*

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

 bsr.s trace_ligne

attend_touche
 dc.w $a000
 move -602(a0),x_souris
 move -600(a0),y_souris
 tst.w -596(a0)
 bne.s fin_boucle

* move #$7000,$ffff9800.w
* move #-1,$ffff9800.w

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
 
 

x1=50
y1=50

x2=70
y2=60
 
trace_ligne

 moveq #1,d6		SX=1
 move.l #x2,d0
 move.l #x1,d1
 sub d1,d0 		d0 = Largeur
 beq.s .largeur_nulle
 bmi.s .largeur_n‚gative
.largeur_positive
 bra.s .fin_largeur
 
.largeur_nulle
 moveq #0,d6		SX=0
 bra .fin_largeur

.largeur_n‚gative
 moveq #-1,d6		SX=-1
 neg d0			d0 = ABS(Largeur)
 bra .fin_largeur

.fin_largeur
  
 moveq #1,d7		SY = 1
 move.l #y2,d1
 move.l #y1,d2
 sub d2,d1		d1 = Hauteur
 beq.s .hauteur_nulle
 bmi.s .hauteur_n‚gative
.hauteur_positive
 bra.s .fin_hauteur
 
.hauteur_nulle
 moveq #0,d7		SY=0
 bra.s .fin_hauteur

.hauteur_n‚gative
 moveq #-1,d6		SY=-1
 neg d1			d1 = ABS(hauteur)
 bra .fin_hauteur

.fin_hauteur

*** d0=ABS(largeur)
*** d1=ABS(hauteur)
*** d6=SX
*** d7=SY

 cmp d1,d0
 bge largeur_max
hauteur_max
 move d1,d7		Nombre de points=hauteur
 
largeur_max
 move d0,d7		Nombre de points=largeur
  
*
* Plus LARGE que haut
* - Incr‚ment en X= ñ 1
* - Incr‚ment en Y= ñ HAUTEUR/LARGEUR
* - Nombre d'it‚rations=LARGEUR
trace_en_x
 move d0,d5		d7=largeur
 subq #1,d5		-> Nombre d'it‚rations

 move.l #1,d6		IX
 swap d6

 divs d0,d2		IY=H/L
 swap d2
 move.l d2,d7
 bra trace
*
* Plus HAUT que large
* - Incr‚ment en X= ñ LARGEUR/HAUTEUR
* - Incr‚ment en Y= ñ 1
* - Nombre d'it‚rations=HAUTEUR
trace_en_y 
 move d2,d5	d7=hauteur
 subq #1,d5	-> Nombre d'it‚rations
 divs d2,d0		IX
 swap d0
 move.l d0,d6		
 move.l #1,d7		IY
 swap d7
 bra trace

trace
 moveq #0,d0
 move #x1,d0
 moveq #0,d1
 move #y1,d1

.loop 
 lea ecran,a0
 move d0,d2
 add d2,d2		X x2
 add d2,a0
 move d1,d2		Y x640
 mulu #640,d2
 add.l d2,a0
 move #0,(a0)
 swap d0
 swap d1
 add.l d6,d0
 add.l d7,d1
 swap d0
 swap d1 
 dbra d5,.loop
 rts
  
 section DATA 

 section BSS

old_video	ds.w 1 
old_adresse	ds.w 1
x_souris	ds.w 1
y_souris	ds.w 1
ecran		ds.l 128000/4
buffer		ds.l 128000/4

 end
 
x2=320
y2=100
'
'
'
FOR a=0 TO 390 STEP 5
  '
  x1=320+90*COSQ(a)
  y1=100+90*SINQ(a)
  '
  dx=ABS(x2-x1)
  dy=ABS(y2-y1)
  '
  IF dx>dy
    n_points=dx
    ix=1
    iy=dy/dx
  ELSE
    n_points=dy
    ix=dx/dy
    iy=1
  ENDIF
  '
  IF x1>x2
    ix=-ix
  ENDIF
  '
  IF y1>y2
    iy=-iy
  ENDIF
  '
  x=x1
  y=y1
  FOR i=1 TO n_points
    PLOT x,y
    ADD x,ix
    ADD y,iy
  NEXT i
  '
NEXT a
 
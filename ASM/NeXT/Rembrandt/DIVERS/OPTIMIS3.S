debug=0
*
* Affichage de lignes en True Color
*
*
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

mode=coltc+l40

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
 move.l #ecran+4,d0
 and #$ffff-3,d0
 move.l d0,‚cran
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
 move.l ‚cran,-(sp)
 move.l ‚cran,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc

 nop

 move #0,x1
 move #0,y1
 move #319,x2
 move #199,y2
  
attend_touche
 dc.w $a000
 tst.w -596(a0)
 bne fin_boucle

 lea table_mulu(pc),a1
 move couleur(pc),d6
 moveq #0,d4
 move.l #$a0000000,d2		Iy

 moveq #32-1,d1
trace_ligne
 add.l #$15ff26,$ffff9800.w

 moveq #0,d5			Iy'=0
 move.l ‚cran(pc),a0
 moveq #0,d3			Y
 move #319,d7
 
trace_horizontal_droite
 move.l (a1,d3.w*4),d0
 move d6,(a0,d0.l)  
 addq #2,a0			Incr‚mente en X
 add.l d2,d5			Fait un incr‚ment sur 32 bits.
 addx d4,d3			Puis ,effectue le d‚placement en +Y
 dbra d7,trace_horizontal_droite
 dbra d1,trace_ligne

 add #100,couleur

 move.l #-1,$ffff9800.w
 
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
 
table_mulu
var set 0
 rept 200
 dc.l var*640
var set var+1
 endr

x			ds.l 1
y			ds.l 1
ix			ds.l 1

x1			ds.w 1
y1			ds.w 1
x2			ds.w 1
y2			ds.w 1

couleur		ds.w 1
‚cran		ds.l 1

  
 section DATA 

 section BSS

old_video	ds.w 1 
old_adresse	ds.w 1
x_souris	ds.w 1
y_souris	ds.w 1
 ds.l 10000
ecran		ds.l 256000/4
 ds.l 10000

 end
 
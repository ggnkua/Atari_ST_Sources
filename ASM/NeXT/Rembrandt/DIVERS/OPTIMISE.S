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

 rept 30
 bsr trace_ligne
 endr
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
 
trace_ligne
initialise_datas
 move.l #$ff000000,$ffff9800.w
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 
 
teste_sens_en_y  
 move y2(pc),d1
 sub y1(pc),d1			D1=hauteur
 bpl.s sens_vertical_correct
 neg d1
 move.l xy1(pc),d2			Si la hauteur est n‚gative, on inverse
 move.l xy2(pc),xy1			les coordonn‚es pour tracer de haut en
 move.l d2,xy2			bas dans tous les cas.
sens_vertical_correct

 move x2(pc),d0
 sub x1(pc),d0			D0=largeur
 spl flag_sens_tra‡age_x	Indique dans quel sens on trace (0:Gauche/1:Droite)
 bpl.s signe_horizontal_correct
 neg d0
signe_horizontal_correct

 cmp d0,d1			Si (D1 ò D0), alors on trace en Y.
 bgt trace_verticalement
 beq trace_diagonalement
 
trace_horizontalement 
 move d0,d7			Il faut tracer [largeur+1] points en DBra.

 addq #1,d0			Il faut rajouter 1 … la largeur et … la
 addq #1,d1			hauteur calcul‚s pr‚c‚dement.

 move d1,d6
 divu.l d0,d6:d2		Ix en 32 bits de pr‚cision.
 moveq #0,d3			Ix'=0
   
 move x1(pc),d0			AprŠs le test initial, on est sur que X1/Y1
 move y1(pc),d1			est le couple le plus haut. (Point d‚part).

 tst.b flag_sens_tra‡age_x 
 beq trace_horizontal_gauche

 move couleur(pc),d6
 move.l #$87654321,$ffff9800.w
 move.l ‚cran(pc),a0
 lea table_mulu(pc),a1
trace_horizontal_droite
 move.l (a1,d1.w*4),d5
 move d6,(a0,d5.l)  
 addq #2,a0			Incr‚mente en X
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 addx d4,d1			Puis ,effectue le d‚placement en +Y
 dbra d7,trace_horizontal_droite
 rts 

table_mulu
var set 0
 rept 200
 dc.l var*640
var set var+1
 endr
 
trace_horizontal_gauche
 bsr trace_point		Affiche le point en (d0,d1)
 subq #1,d0			D‚cr‚mente en X
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 addx.l d4,d1			Puis ,effectue le d‚placement en +Y
 dbra d7,trace_horizontal_gauche
 move.l #-1,$ffff9800.w
 rts 





; D0=x
; D1=y
; D2=ix
; D3=ix'
; D4=registre … z‚ro
; D7=compteur
  
trace_verticalement  
 move d1,d7			Il faut tracer [largeur+1] points en DBra.

 addq #1,d0			Il faut rajouter 1 … la largeur et … la
 addq #1,d1			hauteur calcul‚s pr‚c‚dement.

 move d0,d6
 divu.l d1,d6:d2		Ix en 32 bits de pr‚cision.
 moveq #0,d3			Ix'=0
   
 move x1,d0			AprŠs le test initial, on est sur que X1/Y1
 move y1,d1 			est le couple le plus haut. (Point d‚part).

 tst.b flag_sens_tra‡age_x 
 beq trace_vertical_gauche
 
trace_vertical_droite
 bsr trace_point		Affiche le point en (d0,d1)
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 addx.l d4,d0			Puis ,effectue le d‚placement en -X
 addq #1,d1			Descend d'un cran dans l'image
 dbra d7,trace_vertical_droite
 rts 

trace_vertical_gauche
 bsr trace_point		Affiche le point en (d0,d1)
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 subx.l d4,d0			Puis ,effectue le d‚placement en -X
 addq #1,d1			Descend d'un cran dans l'image
 dbra d7,trace_vertical_gauche
 rts 



trace_diagonalement
 move d1,d7			Il faut tracer [largeur+1] points en DBra.

 move x1,d0			AprŠs le test initial, on est sur que X1/Y1
 move y1,d1 			est le couple le plus haut. (Point d‚part).

 tst.b flag_sens_tra‡age_x 
 beq trace_diagonal_gauche
 
trace_diagonal_droite
 bsr trace_point		Affiche le point en (d0,d1)
 addq #1,d0			Incr‚ment en X
 addq #1,d1			Descend d'un cran dans l'image
 dbra d7,trace_diagonal_droite
 rts 

trace_diagonal_gauche
 bsr trace_point		Affiche le point en (d0,d1)
 subq #1,d0			D‚cr‚mente en X
 addq #1,d1			Descend d'un cran dans l'image
 dbra d7,trace_diagonal_gauche
 rts 


trace_point
 movem.l d0-d6,-(sp)
 move.l ‚cran(pc),a0
 add.l d0,a0
 add.l d0,a0
 mulu #640,d1
 add.l d1,a0
 move couleur,(a0)  
 movem.l (sp)+,d0-d6
 rts


flag_sens_tra‡age_x	ds.w 1	Flag (byte)

x			ds.l 1
y			ds.l 1

xy1
x1			ds.w 1
y1			ds.w 1

xy2
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
 
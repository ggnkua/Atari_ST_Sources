; REMBRANDT 3.0 - ½  Dbug II
;
; Module contenant les routines de tra‡age de ligne. (1.1)
;
 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 even
 
 section TEXT

trace_ligne
 movem.l buffer_vide,d0-a6	Tous registres … z‚ro.
 move.l xy1,xy1_memo		M‚morise les coordonn‚es
 move.l xy2,xy2_memo
 bsr .draw_it
 move.l xy1_memo,xy1		Restaure les coordonn‚es
 move.l xy2_memo,xy2
 rts

.draw_it  
 move.l fichier,a4		Adresse de l'image

 move.l ‚cran,a5		Adresse de l'‚cran
 
 lea routines_trace_point,a6	Commence par charger l'adresse de la
 move type_ligne,d0		routine qui trace le point … l'‚cran.
 move.l (a6,d0.w*4),a6

teste_sens_en_y  
 move y2,d1
 sub y1,d1			D1=hauteur
 bpl.s sens_vertical_correct
 neg d1
 move.l xy1,d2			Si la hauteur est n‚gative, on inverse
 move.l xy2,xy1			les coordonn‚es pour tracer de haut en
 move.l d2,xy2			bas dans tous les cas.
sens_vertical_correct
 move d1,hauteur
 
 move x2,d0
 sub x1,d0			D0=largeur
 spl flag_sens_tra‡age_x	Indique dans quel sens on trace (0:Gauche/1:Droite)
 bpl.s signe_horizontal_correct
 neg d0
signe_horizontal_correct

 addq #1,d0			Il faut rajouter 1 … la largeur et … la
 addq #1,d1			hauteur calcul‚s pr‚c‚dement.
 move d0,largeur
 move d1,hauteur

 cmp d0,d1			Si (D1 ò D0), alors on trace en Y.
 bgt trace_verticalement
 beq trace_diagonalement
 
trace_horizontalement 
 move d0,d7			Il faut tracer [largeur+1] points en DBra.
 subq #1,d7
 
 move d1,d6
 divu.l d0,d6:d2		Ix en 32 bits de pr‚cision.
 moveq #0,d3			Ix'=0
   
 move x1,d0			AprŠs le test initial, on est sur que X1/Y1
 move y1,d1 			est le couple le plus haut. (Point d‚part).

 tst.b flag_sens_tra‡age_x 
 beq trace_horizontal_gauche

trace_horizontal_droite
 jsr (a6)			Affiche le point en (d0,d1)
 addq #1,d0			Incr‚mente en X
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 addx.l d4,d1			Puis ,effectue le d‚placement en +Y
 dbra d7,trace_horizontal_droite
 rts 

trace_horizontal_gauche
 jsr (a6)			Affiche le point en (d0,d1)
 subq #1,d0			D‚cr‚mente en X
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 addx.l d4,d1			Puis ,effectue le d‚placement en +Y
 dbra d7,trace_horizontal_gauche
 rts 





; D0=x
; D1=y
; D2=ix
; D3=ix'
; D4=registre … z‚ro
; D7=compteur
  
trace_verticalement  
 move d1,d7			Il faut tracer [largeur+1] points en DBra.
 subq #1,d7

 move d0,d6
 divu.l d1,d6:d2		Ix en 32 bits de pr‚cision.
 moveq #0,d3			Ix'=0
   
 move x1,d0			AprŠs le test initial, on est sur que X1/Y1
 move y1,d1 			est le couple le plus haut. (Point d‚part).

 tst.b flag_sens_tra‡age_x 
 beq trace_vertical_gauche
 
trace_vertical_droite
 jsr (a6)			Affiche le point en (d0,d1)
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 addx.l d4,d0			Puis ,effectue le d‚placement en -X
 addq #1,d1			Descend d'un cran dans l'image
 dbra d7,trace_vertical_droite
 rts 

trace_vertical_gauche
 jsr (a6)			Affiche le point en (d0,d1)
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 subx.l d4,d0			Puis ,effectue le d‚placement en -X
 addq #1,d1			Descend d'un cran dans l'image
 dbra d7,trace_vertical_gauche
 rts 



trace_diagonalement
 move d1,d7			Il faut tracer [largeur+1] points en DBra.
 subq #1,d7
 
 move x1,d0			AprŠs le test initial, on est sur que X1/Y1
 move y1,d1 			est le couple le plus haut. (Point d‚part).

 tst.b flag_sens_tra‡age_x 
 beq trace_diagonal_gauche
 
trace_diagonal_droite
 jsr (a6)			Affiche le point en (d0,d1)
 addq #1,d0			Incr‚ment en X
 addq #1,d1			Descend d'un cran dans l'image
 dbra d7,trace_diagonal_droite
 rts 

trace_diagonal_gauche
 jsr (a6)			Affiche le point en (d0,d1)
 subq #1,d0			D‚cr‚mente en X
 addq #1,d1			Descend d'un cran dans l'image
 dbra d7,trace_diagonal_gauche
 rts 

routines_trace_point
 dc.l trace_point_color‚
 dc.l trace_point_restaure
 dc.l trace_point_colore_undo


* D0=position X du pixel … tracer
* D1=position Y du pixel … tracer
* D2=ix
* D3=ix'
* D4=registre … z‚ro
* D5=
* D6=
* D7=compteur de pixels
*
* A0=
* A1=
* A2=
* A3=
* A4=adresse de l'image
* A5=adresse de l'‚cran
* A6=adresse de la routine de tra‡age de point
*

*
* Trace sur l'IMAGE et sur l'ECRAN
*
trace_point_color‚
 lea (a5,d0.w*2),a1		(Adresse image) + (X*2)
 move d1,d5			+ (Y*largeur) [image]
 mulu largeur_‚cran,d5
 move couleur,(a1,d5.l)		Trace le pixel … l'‚cran
 rts

*
* Recopie du UNDO vers l'IMAGE et l'ECRAN
*
trace_point_restaure
 lea (a4,d0.w*2),a1		(Adresse image) + (X*2)
 lea (a5,d0.w*2),a2		(Adresse ‚cran) + (X*2)
 move d1,d5			+ (Y*largeur) [image]
 mulu largeur_‚cran,d5
 move d1,d6			+ (Y*largeur) [‚cran]
 mulu largeur_image,d6
 move (a1,d6.l),(a2,d5.l)	Redessine l'ancien pixel sur l'‚cran...
 rts

 
trace_point_colore_undo
 rts

 lea (a4,d0.w*2),a1		(Adresse image) + (X*2)
 lea (a5,d0.w*2),a2		(Adresse ‚cran) + (X*2)
 move d1,d5			+ (Y*largeur) [image]
 mulu largeur_‚cran,d5
 move d1,d6			+ (Y*largeur) [‚cran]
 mulu largeur_image,d6
 move couleur,(a1,d6.l)		Sur image
 move couleur,(a2,d5.l)		Sur ‚cran !
 rts

 BSS

xy1
x1		ds.w 1
y1		ds.w 1

xy2
x2		ds.w 1
y2		ds.w 1

dimensions
largeur		ds.w 1
hauteur		ds.w 1

type_ligne	ds.w 1

xy1_memo	ds.l 1
xy2_memo	ds.l 1

 
initialise_datas
 move #160,x1			Centre de l'‚cran
 move #100,y1

 move #219,x2			En bas au 3/4 … droite
 move #199,y2

teste_sens_en_y  
 move y2,d1
 sub y1,d1			D1=hauteur
 bpl.s sens_vertical_correct
 neg d1
 move.l xy1,d2			Si la hauteur est n‚gative, on inverse
 move.l xy2,xy1			les coordonn‚es pour tracer de haut en
 move.l d2,xy2			bas dans tous les cas.
sens_vertical_correct

 move x2,d0
 sub x1,d0			D0=largeur
 spl flag_sens_tra‡age_x	Indique dans quel sens on trace (0:Gauche/1:Droite)
 bpl.s signe_horizontal_correct
 neg d0
signe_horizontal_correct

 move d1,d7			Il faut tracer [largeur+1] points en DBra.

 addq #1,d0			Il faut rajouter 1 … la largeur et … la
 addq #1,d1			hauteur calcul‚s pr‚c‚dement.
 
 cmp d0,d1			Si (D1 ò D0), alors on trace en Y.
 bge trace_verticalement

trace_horizontalement 
 move d0,d6
 divu.l d1,d6:d2		Ix en 32 bits de pr‚cision.
 moveq #0,d3			Ix'=0
   
 move x1,d0			AprŠs le test initial, on est sur que X1/Y1
 move y1,d1 			est le couple le plus haut. (Point d‚part).

 tst.b flag_sens_tra‡age_x 
 beq trace_horizontal_gauche
 
trace_horizontal_droite
 bsr trace_point		Affiche le point en (d0,d1)
 addq #1,d0			Incr‚mente en X
 add.l d2,d3			Fait un incr‚ment sur 32 bits.
 addx.l d4,d1			Puis ,effectue le d‚placement en +Y
 dbra d7,trace_horizontal_droite
 rts 

trace_horizontal_gauche
 bsr trace_point		Affiche le point en (d0,d1)
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


trace_point
 movem.l d0-d6,-(sp)
 
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

couleur	ds.w 1
‚cran	ds.l 1
 
 
 
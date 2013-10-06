; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion du remplissage formes.  (1.1)
;
; - Utilisation d'un tableau MINIMAX.
; - Utilisable pour RECTANGLES,DISQUES,N-ANGLES
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT
 
*
* Initialise le tableau minimax...
* En fait, on met -1 partout !
*
initialise_minimax
 lea buffer_minimax,a0
 lea fin_buffer_minimax,a1
 moveq #-1,d0
.initialise_minimax
 move.l d0,(a0)+
 move.l d0,(a0)+
 cmpa.l a1,a0
 blt.s .initialise_minimax
 move #16000,y_min_1		Le maximum au minimum...
 move #0000,y_max_1		...et le minimum au maximum !
 rts


erreur_polyfill
 bsr boite_alerte
 rts
 

affiche_table_polyfill
 move y_min_1,d0
 move y_min_2,d1

 move y_max_1,d2
 move y_max_2,d3

 cmp d1,d0			Y_min=MIN(Y_min_1,Y_min_2)
 ble.s .pas_‚change_minimum
 exg d1,d0
.pas_‚change_minimum

 cmp d3,d2			Y_max=MAX(Y_max_1,Y_max_2)
 bge.s .pas_‚change_maximum
 exg d3,d2
.pas_‚change_maximum

 lea buffer_minimax,a0		D‚but de la table
 lea (a0,d0.w*8),a0		Pointe en y_min
 sub d0,d2			Nombre de lignes … remplir

 move couleur,d5		Couleur de remplissage

 move d0,d1			D0=D1=Y_min
 mulu largeur_image,d0		Offset vertical sur l'image
 mulu largeur_‚cran,d1		Offset vertical sur l'‚cran
.analyse_tableau

 cmp.l #-1,(a0)
 beq .fin_rang‚e		Ne devrait jamais arriver !

 cmp #-1,min_2(a0)
 bne.s .gere_nouveau_segment

;
; Si il n'y a pas de segment dans la figure polygonale finale, alors il
; faut effacer l'ancien segment. AprŠs quoi l'on passe … la ligne
; suivante sans se poser plus de questions !
;
.efface_ancien_segment
 move min_1(a0),d3		Efface(min_1,max_1)
 move max_1(a0),d4
 bsr efface_segment
 move #-1,min_1(a0)		Efface le segment du tableau 1
 move #-1,max_1(a0)
 bra .fin_rang‚e


.gere_nouveau_segment
;
; Il y a un segment … tracer sur cette ligne verticale. Alors on s'en
; occupe, en testant tous les cas possibles...
;

 cmp #-1,min_1(a0)
 bne.s .ancien_segment_pr‚sent
;
; Si il n'y avait pas de segment ant‚rieur sur cette ligne, alors on trace
; le nouveau segment, on met … jour les tables, et basta !
;
.ancien_segment_absent
 move min_2(a0),d3		Trace(min_2,max_2)
 move max_2(a0),d4
 bsr trace_segment
 move min_2(a0),min_1(a0)	Inscrit les donn‚es concernant ce segment
 move max_2(a0),max_1(a0)	dans le tableau 1.
 move #-1,min_2(a0)		On oublie pas d'effacer dans le tableau 2 !
 move #-1,max_2(a0)
 bra .fin_rang‚e


.ancien_segment_pr‚sent
;
; Il y avait un ancien segment, et nous devons en mettre un nouveau, donc
; il faut donc, soit:
; - Effacer les morceaux de l'ancien segment qui d‚passeraient … gauche
;   ou … droite. (Qui sont inesth‚tiques !)
; - Compl‚ter le segment d'origine, mais sans retracer un morceau d‚ja
;   pr‚sent. (Ca perd du temps inutilement...)
; - Tracer...
;
 move min_2(a0),d4
 cmp min_1(a0),d4
 ble.s .pas_efface_gauche
;
; L'extr‚mit‚ gauche de l'ancien segment est plus … gauche que celle du
; nouveau, il faut donc effacer ce morceau qui d‚passe !
;
.efface_segment_gauche
 subq #1,d4			Pour ne pas effacer le dernier pixel !
 move min_1(a0),d3		Efface(min_1,MIN(max_1,min_2-1))
 move max_1(a0),d7
 cmp d7,d4
 ble.s .minimum_ok
 exg d7,d4
.minimum_ok   
 bsr efface_segment
.pas_efface_gauche


 move max_2(a0),d3
 cmp max_1(a0),d3
 bge.s .pas_efface_droite
;
; L'extr‚mit‚ droite de l'ancien segment est plus … droite que celle du
; nouveau, il faut donc effacer ce morceau qui d‚passe !
;
.efface_segment_droite
 addq #1,d3			Pour ne pas effacer le premier pixel
 move min_1(a0),d7		Efface(MAX(max_2+1,min_1),max_1)
 cmp d7,d3
 bge.s .maximum_ok
 exg d7,d3
.maximum_ok   
 move max_1(a0),d4
 bsr efface_segment
.pas_efface_droite



.trace_segment_final
;
; Maintenant que l'on a effac‚ les ‚ventuels morceaux de l'ancien
; segment qui auraient pu gacher l'esth‚tique de notre figure, nous
; pouvons donc nous occuper des morceaux qu'il faut r‚ellement tracer !
;
 move min_1(a0),d4
 cmp min_2(a0),d4
 ble .pas_trace_segment_gauche
;
; Si l'extr‚mit‚ gauche de l'ancien segment est moins … gauche que celle
; du nouveau segment, c'est qu'il faut compl‚ter … gauche...
;
.trace_segment_gauche
 subq #1,d4			Pour ‚viter de tracer un point en trop !
 move min_2(a0),d3		Trace(min_2,MIN(max_2,min_1-1))
 move max_2(a0),d7
 cmp d7,d4
 ble.s .minimum_gauche_ok
 exg d7,d4
.minimum_gauche_ok
 bsr trace_segment
.pas_trace_segment_gauche


 move max_1(a0),d3
 cmp max_2(a0),d3
 bge .pas_trace_segment_droite
;
; Si l'extr‚mit‚ droite de l'ancien segment est moins … droite que celle
; du nouveau segment, c'est qu'il faut compl‚ter … gauche...
;
.trace_segment_droite
 addq #1,d3			Pour ‚viter de tracer un point en trop !
 move min_2(a0),d7		Trace(MAX(min_2,max_1+1),max_2)
 cmp d7,d3
 bge.s .maximum_droite_ok
 exg d7,d3
.maximum_droite_ok
 move max_2(a0),d4
 bsr trace_segment
.pas_trace_segment_droite


 move min_2(a0),min_1(a0)	Remplace l'ancienne d‚finition par celle
 move max_2(a0),max_1(a0)	du nouveau segment.
 move #-1,min_2(a0)		Puis d‚truit le second tableau.
 move #-1,max_2(a0)
 
.fin_rang‚e
 addq #8,a0			Rang‚e suivante
 add.l l_largeur_image,d0	Additionne en LONG
 add.l l_largeur_‚cran,d1
 dbra d2,.analyse_tableau

 move y_min_2,y_min_1		!%$÷âùüÀ°... de 80x86... J'ai m‚lang‚
 move y_max_2,y_max_1		®MOV Dest,Source¯ avec ®MOVE Source,Dest¯
 rts  




efface_table_polyfill
 move y_min_1,d0
 move y_max_1,d2

 lea buffer_minimax,a0		D‚but de la table
 lea (a0,d0.w*8),a0		Pointe en y_min
 sub d0,d2			Nombre de lignes … remplir
 move d0,d1
 mulu largeur_image,d0		Offset vertical sur l'image
 mulu largeur_‚cran,d1		Offset vertical sur l'‚cran
.analyse_tableau
 cmp #-1,min_1(a0)
 beq .fin_rang‚e		Ne devrait jamais arriver (en th‚orie !)
 move min_1(a0),d3
 move max_1(a0),d4
 bsr efface_segment
.fin_rang‚e
 addq #8,a0			Rang‚e suivante
 add.l l_largeur_image,d0	Additionne en LONG
 add.l l_largeur_‚cran,d1
 dbra d2,.analyse_tableau
 rts  



*m‚morise_table_polyfill
* move y_min_1,d0
* move y_max_1,d2

* lea buffer_minimax,a0		D‚but de la table
* lea (a0,d0.w*8),a0		Pointe en y_min
* sub d0,d2			Nombre de lignes … remplir
* move couleur,d5		Couleur de remplissage
* move d0,d1
* mulu largeur_image,d0		Offset vertical sur l'image
* mulu largeur_‚cran,d1		Offset vertical sur l'‚cran
*.analyse_tableau
* cmp #-1,min_1(a0)
* beq .fin_rang‚e		Ne devrait jamais arriver (en th‚orie !)
* move min_1(a0),d3
* move max_1(a0),d4
* bsr m‚morise_segment
*.fin_rang‚e	
* addq #8,a0			Rang‚e suivante
* add.l l_largeur_image,d0	Additionne en LONG
* add.l l_largeur_‚cran,d1
* dbra d2,.analyse_tableau
* rts  




* Pour toutes les routines qui suivent, on a:
* D0: Offset vertical sur l'image
* D1: Offset vertical sur l'‚cran
* D2: Compteur de lignes verticales
* D3: D‚but X du segment
* D4: Fin X du segment
* D5: Couleur pour tracer

efface_segment
 move.l fichier,a2
 add.l d0,a2

 move.l ‚cran,a3
 add.l d1,a3

 sub d3,d4		Nombre de points … tracer
 add d3,d3		X1*2
 add d3,a2		Adresse de d‚part (‚cran)
 add d3,a3
.trace_points
 move (a2)+,(a3)+	Redessine sur l'‚cran
 dbra d4,.trace_points
 rts
 
trace_segment
 move.l ‚cran,a2
 add.l d1,a2
 sub d3,d4		Nombre de points … tracer
 add d3,d3
 add d3,a2		Adresse ‚cran + X1*2
.trace_points
 move d5,(a2)+		Trace sur l'‚cran
 dbra d4,.trace_points
 rts

*m‚morise_segment 
* move.l fichier,a1
* add.l d0,a1
* sub d3,d4		Nombre de points … tracer
* lea (a1,d3.w*2),a1	Adresse + X1*2
*.trace_points
* move d5,(a1)+		Trace le segment...
* dbra d4,.trace_points
* rts



 section BSS

 rsreset
min_1			rs.w 1
min_2			rs.w 1
max_1			rs.w 1
max_2			rs.w 1

buffer_minimax		ds.l 2*4000 Pour m‚moriser les X_mini et X_maxi !
fin_buffer_minimax

y_min_1			ds.w 1
y_min_2			ds.w 1
y_max_1			ds.w 1
y_max_2			ds.w 1

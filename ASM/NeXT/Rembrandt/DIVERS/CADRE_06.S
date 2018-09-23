debug=0
*
*
* Affichage d'un rectangle plein en temps r‚el.
* (Bref, comme NeoChrome !)
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

 include E:\PROJETS\REMBRAND\FICHIERS.INC\MACROS.S

 dc.w $a000
 move.l a0,_linebase
  
 pea superviseur
 move #$26,-(sp)
 trap #14
 addq #6,sp
;
; Et quitte
; 
 clr -(sp)
 trap #1

attend_mouvement
 move.l d0,-(sp)
 move.l xy1,d0
.attend_mouvement
 getmouse
 tst mousek
 bne.s .fin_attente 
 cmp.l mousexy,d0
 beq.s .attend_mouvement
.fin_attente
 move.l (sp)+,d0
 rts



 
superviseur 
 move.l #ecran+4,d0
 and #-1-3,d0
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
 move #37,-(sp)
 trap #14
 addq #2,sp

 move #mode,-(sp)
 move #3,-(sp)
 move.l ‚cran,-(sp)
 move.l ‚cran,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc
 
*
* Initialise le tableau minimax...
* En fait, on met -1 partout !
*
 lea buffer_minimax,a0
 lea fin_buffer_minimax,a1
.initialise_minimax
 move.l #-1,(a0)+
 move.l #-1,(a0)+
 cmpa.l a1,a0
 blt.s .initialise_minimax
 move #1000,y_min_1		Le minimum au maximum...
 move #000,y_max_1		...et le maximum au minimum !

 move #0,x1
 move #0,y1
 move #1,x2
 move #1,y2
* bsr mise_…_jour_table
* bsr interprete_table

* move #7,-(sp)
* trap #1
* addq #2,sp

* move #75,x1
* move #75,y1
* move #125,x2
* move #125,y2
* bsr mise_…_jour_table
* bsr interprete_table

* move #7,-(sp)
* trap #1
* addq #2,sp

* move #50,x1
* move #80,y1
* move #100,x2
* move #130,y2
* bsr mise_…_jour_table
* bsr interprete_table

* move #7,-(sp)
* trap #1
* addq #2,sp

* bra fin_boucle 

boucle
 getmouse
 move mousex,x1
 move mousey,y1
 tst.w mousek
 beq .zap
 cmp #2,mousek
 beq fin_boucle
 move.l xy1,xy2
  
.zap
 bsr mise_…_jour_table
 bsr interprete_table
 
 bsr attend_mouvement

 move #37,-(sp)
 trap #14
 addq #2,sp
 bra boucle

fin_boucle
* move #7,-(sp)
* trap #1
* addq #2,sp

 ifeq debug
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
 endc
 rts
 


mise_…_jour_table
 move x1,d0
 move x2,d1
 cmp d1,d0
 bmi .inverse_pas_x
 exg d0,d1
.inverse_pas_x

 move y1,d2
 move y2,d3
 cmp d3,d2
 bmi .inverse_pas_y
 exg d2,d3
.inverse_pas_y

*** Maintenant, on …  D0=Xmin  D1=Xmax
***                   D2=Ymin  D3=Ymax

 move d2,y_min_2
 move d3,y_max_2
 
 lea buffer_minimax,a0		D‚but de la table
 lea (a0,d2.w*8),a0		Pointe en y_min_2
 sub d2,d3			Nombre de lignes … remplir
.remplie_tableau
 move d0,min_2(a0)		Minimum en X
 move d1,max_2(a0)		Maximum en X
 addq #8,a0			Rang‚e suivante...
 dbra d3,.remplie_tableau
 rts



interprete_table
 movem y_min_max,d0/d1/d2/d3	Y_min_1,Y_min_2,Y_max_1,Y_max_2

 cmp d1,d0
 bmi.s .pas_‚change_minimum
 exg d0,d1
.pas_‚change_minimum
 move d0,y_min

 cmp d3,d2
 bpl.s .pas_‚change_maximum
 exg d2,d3
.pas_‚change_maximum
 move d2,y_max

 lea buffer_minimax,a0		D‚but de la table
 lea (a0,d0.w*8),a0		Pointe en y_min
 sub d0,d2			Nombre de lignes … remplir
 move d0,y_deb
.analyse_tableau
 cmp #-1,min_2(a0)
 bne.s .pas_min_2_n‚gatif

.min_2_n‚gatif 
 move min_1(a0),x_deb
 move max_1(a0),x_fin
 bsr efface_segment
 move #-1,min_1(a0)		Efface toute la rang‚e dans le
 move #-1,max_1(a0)		tableau 1
 move #-1,min_2(a0)		Efface toute la rang‚e dans le
 move #-1,max_2(a0)		tableau 2
 bra .fin_rang‚e

.pas_min_2_n‚gatif
 cmp #-1,min_1(a0)
 bne.s .pas_min_1_n‚gatif

.min_1_n‚gatif
 move min_2(a0),x_deb
 move max_2(a0),x_fin
 bsr trace_segment
 move min_2(a0),min_1(a0)	Remplace l'ancienne d‚finition par celle
 move max_2(a0),max_1(a0)	du nouveau segment.
 move #-1,min_2(a0)		Puis d‚truit le second tableau.
 move #-1,max_2(a0)
 bra .fin_rang‚e

.pas_min_1_n‚gatif
 move min_2(a0),d0
 cmp min_1(a0),d0
 ble.s .pas_efface_gauche

* min_1<min_2
.efface_segment_gauche
 move min_1(a0),x_deb
 move max_1(a0),d1
 cmp d1,d0
 bmi.s .minimum_ok
 exg d1,d0
.minimum_ok   
 move d0,x_fin 
 bsr efface_segment
.pas_efface_gauche


 move max_2(a0),d0
 cmp max_1(a0),d0
 bge.s .pas_efface_droite

.efface_segment_droite
 move min_1(a0),d1
 cmp d1,d0
 bgt.s .maximum_ok
 exg d1,d0
.maximum_ok   
 move d0,x_deb
 move max_1(a0),x_fin
 bsr efface_segment
.pas_efface_droite


.trace_segment_final

 move min_2(a0),d0
 cmp min_1(a0),d0
 bgt .pas_trace_segment_gauche

.trace_segment_gauche
 move min_2(a0),x_deb
 move max_2(a0),d0
 move min_1(a0),d1
 cmp d1,d0
 bmi.s .minimum_gauche_ok
 exg d0,d1
.minimum_gauche_ok
 move d0,x_fin
 bsr trace_segment
.pas_trace_segment_gauche

 move max_2(a0),d0
 cmp max_1(a0),d0
 blt .pas_trace_segment_droite

.trace_segment_droite
 move min_2(a0),d0
 move max_1(a0),d1
 cmp d1,d0
 bgt.s .maximum_droite_ok
 exg d0,d1
.maximum_droite_ok
 move d0,x_fin
 move d0,x_deb
 move max_2(a0),x_fin
 bsr trace_segment
.pas_trace_segment_droite





 move min_2(a0),min_1(a0)	Remplace l'ancienne d‚finition par celle
 move max_2(a0),max_1(a0)	du nouveau segment.
 move #-1,min_2(a0)		Puis d‚truit le second tableau.
 move #-1,max_2(a0)
 
.fin_rang‚e
 addq #8,a0			Rang‚e suivante
 addq #1,y_deb
 dbra d2,.analyse_tableau

 add #10,couleur

 move y_min,y_min_1
 move y_max,y_max_1
 rts  


efface_segment
 movem.l d0-a6,-(sp)
 move couleur,d7
 not d7
 moveq #-1,d7
 move.l ‚cran,a0
 move y_deb,d0
 mulu #640,d0
 add.l d0,a0
 move x_deb,d0
 move x_fin,d1
 sub d0,d1		Nombre de points … tracer
 add d0,d0
 add d0,a0		Adresse de d‚part
.trace_points
 move d7,(a0)+		Trace le segment...
 dbra d1,.trace_points
 movem.l (sp)+,d0-a6
 rts
 
trace_segment
 movem.l d0-a6,-(sp)
 move.l ‚cran,a0
 move y_deb,d0
 mulu #640,d0
 add.l d0,a0
 move x_deb,d0
 move x_fin,d1
 sub d0,d1		Nombre de points … tracer
 add d0,d0
 add d0,a0		Adresse de d‚part
.trace_points
 move couleur,(a0)+	Trace le segment...
 dbra d1,.trace_points
 movem.l (sp)+,d0-a6
 rts
 



trace_cadre
 move x1,d0
 move x2,d1
 cmp d1,d0
 bmi .inverse_pas_x
 exg d0,d1
.inverse_pas_x
 add d0,d0 		XGauche x2

 move y1,d1
 move y2,d2
 cmp d2,d1
 bmi .inverse_pas_y
 exg d1,d2
.inverse_pas_y
 mulu #640,d1 		YHaut x640

 move.l ‚cran,a0
 add d0,a0		Position X
 add.l d1,a0		Position Y
   
 move x1,d0
 sub x2,d0
 bpl .ok
 neg d0
.ok

 move y1,d1
 sub y2,d1
 bpl .ok_y
 neg d1
.ok_y
 btst #0,d0
 beq .cadre_paire
  
.cadre_impaire
 lsr d0
 moveq #-1,d7
.loop_y
 move.l a0,a1
 move d0,d2
.loop_x
 eor.l d7,(a1)+
 dbra d2,.loop_x
 eor d7,(a1)+
 lea 640(a0),a0
 dbra d1,.loop_y
 rts

.cadre_paire
 lsr d0
 moveq #-1,d7
.loop_y2
 move.l a0,a1
 move d0,d2
.loop_x2
 eor.l d7,(a1)+
 dbra d2,.loop_x2
 lea 640(a0),a0
 dbra d1,.loop_y2
 rts

  
 section DATA 

xy1
x1	dc 50
y1	dc 50

xy2
x2	dc 160
y2	dc 100

 section BSS

old_video		ds.w 1 
old_adresse		ds.w 1
mousexy
mousex			ds.w 1
mousey			ds.w 1
mousek			ds.w 1
x_scroll		ds.w 1
y_scroll		ds.w 1
_linebase		ds.l 1

‚cran			ds.l 1

 ds.l 10000
ecran			ds.l 128000/4+1
buffer			ds.l 128000/4
 ds.l 10000

 rsreset
min_1	rs.w 1
min_2	rs.w 1
max_1	rs.w 1
max_2	rs.w 1

buffer_minimax		ds.l 2*4000 Pour m‚moriser les X_mini et X_maxi !
fin_buffer_minimax

y_min			ds.w 1
y_max			ds.w 1

y_min_max
y_min_1			ds.w 1
y_min_2			ds.w 1
y_max_1			ds.w 1
y_max_2			ds.w 1

couleur			ds.w 1

x_deb			ds.w 1
x_fin			ds.w 1
y_deb			ds.w 1
 end
 
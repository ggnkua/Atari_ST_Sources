; REMBRANDT 3.0 - ½  Dbug II
;
; Module outil COMPAS.  (1.2)
;
; *- Trac‚ de cercles vides
; - Trac‚ de disques
;
; SHIFT -> Diminue le rayon
; ALTERNATE -> Augmente le rayon

 TEXT
 
routine_compas_cercle
 bsr boite_alerte
 rts


routine_compas_disque
 force_int‚rieur

 relache			On attend que le bouton soit relach‚ !

 bsr initialise_minimax

.disque_suivant
 getmouse
 force_int‚rieur
 move.l mousexy,xy1
 bsr teste_shift_disque

 bsr mise_…_jour_table_disque
 bsr affiche_table_polyfill
 bsr vsync
 bsr attend_mouvement	Attend que l'on bouge la souris
 cmp #2,mousek
 beq.s .fin_routine_disque
 cmp #1,mousek
 bne .disque_suivant

.trace_ce_disque
* bsr m‚morise_table_polyfill
* bsr initialise_minimax
 st flag_chang‚e
 relache
 rts  *bra .disque_suivant
 
  
.fin_routine_disque
 bsr efface_table_polyfill
 relache
 rts


teste_shift_disque
 getshift
 btst #1,d0
 beq.s .pas_zoom_out
 cmp #1,r_cercle
 beq.s .pas_zoom_out
 subq #1,r_cercle
.pas_zoom_out
 btst #3,d0
 beq.s .pas_zoom_in
 move r_cercle,d0
 cmp hauteur_image,d0
 bge.s .pas_zoom_in 
 addq #1,r_cercle
.pas_zoom_in
 rts






mise_…_jour_table_disque
 move #-1,d0
 move d0,y_min_2
 move d0,y_max_2

 move x1,cx
 move y1,cy

 bsr trace_cercle 
 tst y_min_2
 bpl.s .ok_minimum
 move #0,y_min_2
.ok_minimum
 tst y_max_2
 bpl.s .ok_maximum
 move hauteur_image,y_max_2
 subq #1,y_max_2
.ok_maximum
 rts



trace_cercle
 lea buffer_minimax,a0
 move cy,d0
 lea (a0,d0.w*8),a0	Milieu de la table minimax

 move r_cercle,d7	D7: Yi=R

 move d7,d0
 lsl #3,d0		x8
 lea (a0,d0.w),a2	Place tout en bas !
 neg.w d0
 lea (a0,d0.w),a1	Place tout en haut...
   
 moveq #0,d6		D6: Xi=0

 moveq #1,d4		D4: i=2(1-R)
 sub r_cercle,d4
 add d4,d4

 moveq #0,d5		D5: Limite=0

 sf flag_trac‚
 
.point_suivant
 tst.b flag_trac‚
 bne.s .fin_tra‡age

 st flag_trac‚

 move cx,d0		Prend le centre ñXi.
 move d0,d1
 
 sub d6,d0		Xmin
 bpl.s .ok_gauche
 moveq #0,d0		Si on d‚passe … gauche, on force … 0 !
.ok_gauche 

 add d6,d1		Xmax
 move largeur_image,d2
 lsr d2
 cmp d2,d1
 blt.s .ok_droite
 move d2,d1		Si on d‚passe … droite, on force au max !
 subq #1,d1
.ok_droite

 move cy,d2
 sub d7,d2
 bmi.s .clippe_haut
 tst y_min_2
 bpl.s .ok_ymin
 move d2,y_min_2
.ok_ymin
 move d0,min_2(a1)
 move d1,max_2(a1)
.clippe_haut

 move d7,d2
 beq.s .clippe_bas		On ne trace qu'une fois la ligne centrale !
 add cy,d2
 cmp hauteur_image,d2
 bge.s .clippe_bas
 tst y_max_2
 bpl.s .ok_ymax
 move d2,y_max_2
.ok_ymax
 move d0,min_2(a2)
 move d1,max_2(a2)   
.clippe_bas

 addq #8,a1		Vas du haut vers le centre
 subq #8,a2		Vas du bas vers le centre...

.fin_tra‡age

 tst d7
 beq .fin_tra‡age_disque
 
 tst d4
 bmi.s ._2		If i<0 then 2
 beq.s ._20		If i=0 then 20
*			Cas o— i>0
 move d4,d3		D3: ë=2(i+Xi)-1
 add d6,d3
 add d3,d3
 subq #1,d3

 bpl.s ._30		If ë>0 then 30
*			Cas o— ëó0
._20
 addq #1,d6		Xi=Xi+1
 subq #1,d7		Yi=Yi-1

 sf flag_trac‚
 add d6,d4		D4: i=i+2Xi-2Yi+2
 add d6,d4
 sub d7,d4
 sub d7,d4
 addq #2,d4
 bra .point_suivant

 
._2
 move d4,d3		D3: ë=2(i+Yi)-1
 add d7,d3
 add d3,d3
 subq #1,d3

 bpl.s ._20		If ë>0 then 20
*			Cas o— ëó0
 addq #1,d6		Xi=Xi+1
 add d6,d4		D4: i=i+2Xi+1
 add d6,d4
 addq #1,d4
 bra .point_suivant


._30
 subq #1,d7		Yi=Yi-1

 sf flag_trac‚
 sub d7,d4		D4: i=i-2Yi+1
 sub d7,d4
 addq #1,d4
 bra .point_suivant

.fin_tra‡age_disque
 rts

 
 BSS
 
cxy
cx		ds.w 1
cy		ds.w 1
r_cercle	ds.w 1

flag_trac‚	ds.w 1

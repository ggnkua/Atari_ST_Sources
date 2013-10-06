; 0-> Ligne simples
; 1-> Ligne continue
; 2-> Rayons
;

 TEXT
 
routine_rŠgle_ligne
 sf flag_ligne_rayon
 sf flag_ligne_multiple
 bra routine_ligne_globale

routine_rŠgle_kligne
 sf flag_ligne_rayon
 st flag_ligne_multiple
 bra routine_ligne_globale

routine_rŠgle_rayon
 st flag_ligne_rayon
 st flag_ligne_multiple
 bra routine_ligne_globale

routine_ligne_globale
 force_int‚rieur
 move.l mousexy,xy2	et m‚morise pour la suite.

 relache
.ligne_suivante
 getmouse
 force_int‚rieur
 move.l mousexy,xy1
 bsr .teste_shift
 move #0,type_ligne	On affiche les points (‚cran+image)
 bsr trace_ligne
 bsr vsync
 bsr attend_mouvement
 cmp #1,mousek
 beq.s .trace_cette_ligne
 move #1,type_ligne	On restaure (UNDO)  (‚cran+image)
 bsr trace_ligne
 cmp #2,mousek
 beq.s .fin_routine_ligne
 bra .ligne_suivante

.trace_cette_ligne
 move #2,type_ligne	On colorie en couleur... d‚finitive !
 bsr trace_ligne
 relache
 tst.b flag_ligne_rayon
 bne.s .conserve_d‚part
 move.l xy1,xy2
.conserve_d‚part
 st flag_chang‚e
 tst.b flag_ligne_multiple
 bne .ligne_suivante
 
.fin_routine_ligne
 relache
 rts

.teste_shift
 getshift
 and #%11,d0		Conserve les bits 0 et 1 (SHIFTS)
 beq .pas_shift

 move x2,d0
 sub x1,d0		D0=Largeur (sign‚e)
 move d0,d1
 bpl.s .ok_largeur
 neg d1			D1=|Largeur|
.ok_largeur 

 move y2,d2
 sub y1,d2		D2=Hauteur (sign‚e)
 move d2,d3
 bpl.s .ok_hauteur
 neg d3			D3=|Hauteur|
.ok_hauteur 

 move d1,d4		D4=Largeur*2
 add d4,d4
 cmp d4,d3		hauteur>largeur*2 ???
 bgt .ligne_verticale
 move d3,d4		D4=Hauteur*2	
 add d4,d4
 cmp d4,d1		largeur<hauteur*2 ???
 bgt .ligne_horizontale
 bra .ligne_diagonale
   
.pas_shift 
 rts

.ligne_horizontale
 move y2,y1
 rts

.ligne_verticale
 move x2,x1
 rts
 
.ligne_diagonale
 cmp d1,d3		Compare |hargeur| et |hauteur|
 bgt.s .pas_‚change
 move d3,d1		D1 = min(|hauteur|,|largeur|)
.pas_‚change  
 move x2,x1
 move y2,y1
 tst d0			Signe de la largeur
 bmi.s .teste_droite
.teste_gauche 
 tst d2
 bmi.s .bas_gauche
.haut_gauche
 sub d1,x1
 sub d1,y1
 rts
.bas_gauche
 sub d1,x1
 add d1,y1
 rts

.teste_droite
 tst d2
 bmi.s .bas_droite
.haut_droite
 add d1,x1
 sub d1,y1
 rts
.bas_droite
 add d1,x1
 add d1,y1
 rts
  
 BSS
 
flag_ligne_rayon	ds.w 1
flag_ligne_multiple	ds.w 1
 
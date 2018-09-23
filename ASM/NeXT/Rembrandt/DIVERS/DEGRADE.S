* sf flag_curseur	Controle manuel
* getmouse
* move.l ‚cran,a0
* move mousex,d0
* lea (a0,d0*2),a0
* move mousey,d0
* mulu #640,d0
* move (a0,d0.l),d7
* move d7,couleur

* getshift		On teste les touches du clavier
* btst #3,d0
* beq .pas_alternate
* move d7,dst_couleur
*.pas_alternate
* btst #1,d0
* beq .pas_shift_gauche
* move d7,src_couleur
*.pas_shift_gauche
   
*
* Trace une barre de couleurs en bas de l'‚cran
*
* move.l #buffer_informations,adresse_barre
** move.l ‚cran,adresse_barre
** add.l #640*190,adresse_barre
* st flag_affiche_infos
* move.b #180,position_hbl
* bsr affiche_barre

* bsr vsync
* bsr vsync
* bsr vsync
* bsr affiche_curseur
* st flag_curseur	Controle automatique
* jmp loop


affiche_barre
;
; Les couleurs extremes
;
 lea src_composantes,a0		D‚compose la couleur source
 move src_couleur,d0
 bsr decompose_couleur

 lea dst_composantes,a0		D‚compose la couleur d'arriv‚e
 move dst_couleur,d0
 bsr decompose_couleur

;
; Calcule les incr‚ments/d‚cr‚ments pour aller de l'un a l'autre...
;
 lea src_rouge,a0
 lea dst_rouge,a1
 lea inc_rouge,a2
 bsr calcule_incr‚ment
 lea src_vert,a0
 lea dst_vert,a1
 lea inc_vert,a2
 bsr calcule_incr‚ment
 lea src_bleu,a0
 lea dst_bleu,a1
 lea inc_bleu,a2
 bsr calcule_incr‚ment

;
; Et puis on trace !!!
;  (La foule arrete de respirer... L'ambiance est lourde.)
;
 move.l adresse_barre,a0
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 move src_rouge,d0
 move src_vert,d1
 move src_bleu,d2
 move.l inc_rouge,d3
 move.l inc_vert,d4
 move.l inc_bleu,d5

 move d0,d6
 lsl #6,d6
 or d1,d6
 lsl #5,d6
 or d2,d6
 move d6,a1	M‚morise la couleur courante
 
 move #320-1,d7
trace_x
 move d0,d6
 lsl #6,d6
 or d1,d6
 lsl #5,d6
 or d2,d6

 cmp a1,d6
 beq .ok
 move d6,a1
 move #-1,d6
.ok
   
var set 0
 rept 10
 move d6,var(a0)
var set var+640 
 endr

 swap d0		On passe … la couleur suivante
 swap d1
 swap d2
 add.l d3,d0
 add.l d4,d1
 add.l d5,d2
 swap d0
 swap d1
 swap d2

 addq #2,a0
 dbra d7,trace_x 
 rts


decompose_couleur
 move d0,d1
 and.w #%11111,d1
 move d1,4(a0)
 lsr #5,d0
 move d0,d1
 and.w #%111111,d1
 move d1,2(a0)
 lsr #6,d0
 move d0,d1
 and.w #%11111,d1
 move d1,(a0)
 rts 

calcule_incr‚ment  
 moveq #0,d0
 move (a0),d0
 swap d0
 moveq #0,d1
 move (a1),d1
 swap d1
 sub.l d0,d1		On a la diff‚rence
 divs.l #320,d1		Et le pas
 move.l d1,(a2)
 rts 

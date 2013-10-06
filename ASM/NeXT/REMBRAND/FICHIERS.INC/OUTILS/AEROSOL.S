; REMBRANDT 3.0 - ½  Dbug II
;
; Module outil AEROSOL.  (1.1)
;
; SHIFT -> Diminue le rayon
; ALTERNATE -> Augmente le rayon
;
; Routine destin‚e … simuler une bombe a‚rosol contenant de la peinture.
; Voici la m‚thode … utiliser:
;
; Soit R le rayon d'action de l'a‚rosol.
; Soit V la vitesse d'action. (Dur‚e pour passer de la couleur d'origine
; … la couleur de l'a‚rosol.
;
; - L'a‚rosol projete les points dans un cercle de rayon R.
; - Pour chaque point du cercle:
;   - Calculer la distance entre ce point et le centre du cercle.
;     [ Dý=Xý+Yý  D=û(X+Y) ]
;     Ce qui permet d'ailleur de r‚utiliser ma formule de calcul de racine
;     carr‚e en asm ! (Chouette)
;   - En d‚duire la probabilit‚ [0;1] que ce point soit touch‚ par de la
;     peinture. Il est ‚vident que les points du centre ont plus de chances
;     d'etre color‚s que ceux du pourtour ! (On prend une r‚partition
;     lin‚raire de la pulv‚risation, allant de 1 au centre, jusqu'… 0 sur
;     le pourtour.
;     [ F=1-(D/R ]
;   - Changer la couleur du point !
;
; Hum. Cette routine ne fait pas tout ca ! En fait, elle travaille de
; fa‡on homogene sur un disque de rayon variable, a une vitesse elle...
; aussi variable.
;
; Utilisation:
; - Pulv‚risation avec le bouton gauche
; - R‚glage de la taille avec [SHIFT GAUCHE] et [Alternate]
; - Changement de la vitesse avec ???? Je sais pas encore !

 TEXT
 
routine_a‚rosol_spray_1
 force_int‚rieur

 relache			On attend que le bouton soit relach‚ !

.boucle_pulv‚rise_a‚rosol
 bsr teste_shift_a‚rosol
 getmouse
 force_int‚rieur
 cmp #3,mousek
 beq .fin_affichage
 cmp #1,mousek
 bne .continue_trace
 move mousex,cx
 move mousey,cy
 bsr pssshhhhiiiittt
 bsr vsync
 bsr vsync
 st flag_chang‚e
 bsr affiche_le_zoomer
 bra .boucle_pulv‚rise_a‚rosol

.continue_trace
 cmp #2,mousek
 beq .fin_affichage

 move.l mousexy,xy1
 move.l xy1,cxy
 bsr trace_cercle_fantome
 bsr attend_mouvement
 bsr vsync
 bsr trace_cercle_fantome
 bra .boucle_pulv‚rise_a‚rosol
 
.fin_affichage
 relache
 rts

routine_a‚rosol_spray_2
 bsr boite_alerte
 rts

teste_shift_a‚rosol
 getshift
 btst #1,d0
 beq.s .pas_zoom_out
 cmp #1,r_a‚rosol
 beq.s .pas_zoom_out
 subq #1,r_a‚rosol
.pas_zoom_out
 btst #3,d0
 beq.s .pas_zoom_in
 move r_a‚rosol,d0
 cmp hauteur_image,d0
 bge.s .pas_zoom_in 
 addq #1,r_a‚rosol
.pas_zoom_in
 rts



pssshhhhiiiittt
 move r_a‚rosol,d7	D7: Yi=R

 move.l ‚cran,a0
 move cy,d0
 mulu largeur_‚cran,d0
 add.l d0,a0		Milieu de l'‚cran
 move d7,d0
 mulu largeur_‚cran,d0
 lea (a0,d0.l),a1	Place tout en bas !
 neg.l d0
 lea (a0,d0.l),a0	Place tout en haut...

; a0	- Trace sur l'‚cran
; a1

 moveq #0,d6		D6: Xi=0

 moveq #1,d4		D4: i=2(1-R)
 sub r_a‚rosol,d4
 add d4,d4

 moveq #0,d5		D5: Limite=0

 sf flag_trac‚
 
.point_suivant
 tst.b flag_trac‚
 bne .pas_tra‡age

 st flag_trac‚

.teste_bas
 move cy,d1
 add d7,d1
 cmp hauteur_image,d1
 bge .teste_haut
.trace_en_bas
 move.l a1,a5		Adresse ‚cran
 move cx,d0	D‚but
 sub d6,d0
 move cx,d1  	Fin
 add d6,d1
 bsr trace_segment_spray


.teste_haut
 tst d7
 beq .fin_tra‡age_disque
 move cy,d1
 sub d7,d1
 bmi .fin_tra‡age
.trace_en_haut
 move.l a0,a5		Adresse ‚cran
 move cx,d0
 sub d6,d0
 move cx,d1  	Fin
 add d6,d1
 bsr trace_segment_spray

.fin_tra‡age
 add largeur_‚cran,a0
 sub largeur_‚cran,a1
 
.pas_tra‡age

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





trace_segment_spray
 movem.l d0-a6,-(sp)

 tst d0			Teste la limite de gauche
 bpl .pas_x_n‚gatif
 moveq #0,d0
.pas_x_n‚gatif

 move largeur_image,d2 
 lsr d2
 cmp d2,d1		Teste la limite de droite
 blt .pas_x_maximum
 move d2,d1
 subq #1,d1
.pas_x_maximum

 sub d0,d1		Nombre de points … tracer
 add d0,d0		Xx2
 add d0,a5		Position sur l'‚cran

 move couleur,d5
 move d5,d7
 and #%11111,d7		D7=bleu de la couleur a mettre
 move d5,d6
 lsr #5,d6
 and #%111111,d6	D6=vert de la couleur a mettre
 rol #5,d5
 and #%11111,d5		D5=rouge de la couleur a mettre


.trace_point   
 move (a5),d2		Prend la couleur sur l'image
 move d2,d4
 and #%11111,d4		D4=bleu initial
 move d2,d3
 lsr #5,d3
 and #%111111,d3	D3=vert initial
 rol #5,d2
 and #%11111,d2		D2=rouge initial
*
 cmp d7,d4
 beq.s .fin_rouge
 bmi.s .plus_rouge
.moins_rouge
 subq #1,d4
 bra.s .fin_rouge 
.plus_rouge
 addq #1,d4
.fin_rouge 

 cmp d6,d3
 beq.s .fin_vert
 bmi.s .plus_vert
.moins_vert
 subq #1,d3
 bra.s .fin_vert 
.plus_vert
 addq #1,d3
.fin_vert 

 cmp d5,d2
 beq.s .fin_bleu
 bmi.s .plus_bleu
.moins_bleu
 subq #1,d2
 bra.s .fin_bleu 
.plus_bleu
 addq #1,d2
.fin_bleu 

*
 ror #5,d2	Le rouge
 lsl #5,d3	Le vert
 or d4,d2
 or d3,d2
*
 move d2,(a5)+		Trace le point sur l'‚cran
 dbra d1,.trace_point   
 movem.l (sp)+,d0-a6
 rts










trace_cercle_fantome
 move.l ‚cran,a0

 move cy,d0
 mulu largeur_‚cran,d0
 add.l d0,a0

 move cx,d0
 add d0,d0
 add d0,a0		A0=Adresse du point central


 moveq #0,d6		D6: Xi=0
 move r_a‚rosol,d7	D7: Yi=R

 moveq #1,d4		D4: i=2(1-R)
 sub r_a‚rosol,d4
 add d4,d4

 moveq #0,d5		D5: Limite=0
 
._11
 move d7,d0		Plot (Xi,Yi)
 mulu largeur_‚cran,d0
 lea (a0,d0.l),a1
 neg.l d0
 lea (a0,d0.l),a2
 move d6,d0
 add d0,d0

 move cx,d1		Cx+Rx' < 320 ???
 add d6,d1
 move largeur_‚cran,d2
 lsr d2
 cmp d2,d1
 bge .clippe_droite 
   move cy,d1
   add d7,d1
   cmp hauteur_‚cran,d1
   bge .clippe_droite_bas
     not (a1,d0.w) Bas droite
.clippe_droite_bas
   move cy,d1
   sub d7,d1
   bmi .clippe_droite_haut
     not (a2,d0.w) Haut droite
.clippe_droite_haut
.clippe_droite

 move cx,d1		Cx-Rx' > 0 ?
 sub d6,d1
 bmi .clippe_gauche
   neg.w d0
   move cy,d1
   add d7,d1
   cmp hauteur_‚cran,d1
   bge .clippe_gauche_bas
     not (a1,d0.w) Bas gauche
.clippe_gauche_bas
   move cy,d1
   sub d7,d1
   bmi .clippe_gauche_haut
     not (a2,d0.w) Haut gauche
.clippe_gauche_haut
.clippe_gauche

 cmp d5,d7		If YióLimite then 4
 ble .fin_tra‡age_disque

 tst d4
 bmi ._22			If i<0 then 2
 beq ._220		If i=0 then 20
 bra ._33			If i>0 then 3

 
._22
 move d4,d3		D3: ë=2(i+Yi)-1
 add d7,d3
 add d3,d3
 subq #1,d3

 bpl ._220		If ë>0 then 20
 bra ._110		If ëó0 then 10

 
._33
 move d4,d3		D3: ë=2(i+Xi)-1
 add d6,d3
 add d3,d3
 subq #1,d3

 bpl ._330		If ë>0 then 30
 bra ._220		If ëó0 then 20


._110
 addq #1,d6		Xi=Xi+1

 add d6,d4		D4: i=i+2Xi+1
 add d6,d4
 addq #1,d4
 
 bra ._11


._220
 addq #1,d6		Xi=Xi+1
 subq #1,d7		Yi=Yi-1

 add d6,d4		D4: i=i+2Xi-2Yi+2
 add d6,d4
 sub d7,d4
 sub d7,d4
 addq #2,d4
 
 bra ._11


._330
 subq #1,d7		Yi=Yi-1

 sub d7,d4		D4: i=i-2Yi+1
 sub d7,d4
 addq #1,d4
 
 bra ._11

.fin_tra‡age_disque
 rts

 BSS

r_a‚rosol	ds.w 1

; REMBRANDT 3.0 - ½ / Dbug II
;
; Module de gestion clavier. (1.0)
;
; Routine clavier/souris pour Rembrandt.
;
; Doit g‚rer:
; - La souris
;   - Vitesse variable
;   - Inversion des boutons pour les gauchers
;
; - Le clavier
;   - Appui+Relachement des touches
;   - R‚p‚tition clavier
;   - Gestion des touches mortes
;   - D‚tection d'appuis multiple
;   - Combinaisons sp‚ciales (RESET...)
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

change_vitesse_souris
 not vitesse_souris

installe_souris_absolu
 sf flag_souris_libre
 bsr vsync

 move largeur_visible,d0
 lsr d0
 move hauteur_visible,d1

 tst vitesse_souris
 beq.s .vitesse_normale
 add d0,d0
 add d1,d1
.vitesse_normale

 move d0,d2
 lsr d2
 move d1,d3
 lsr d3
  
 subq #1,d0
 subq #1,d1
 subq #1,d2
 subq #1,d3

 move d0,data_kybd_xmax
 move d1,data_kybd_ymax
 move d2,data_kybd_xpos
 move d3,data_kybd_ypos

 pea data_kybd_absolu
 move #14-1,-(sp)
 move #25,-(sp)
 trap #14
 addq #8,sp

 bsr vsync
 st flag_souris_libre
 rts

  
; lea data_kybd_absolu_fin,a1
; lea $fffffc00.w,a2
; lea $fffffa23.w,a3
;.boucle_envoie_clavier
; move.b (a2),d2
; btst #1,d2
; beq.s demande_position_souris
; move #$bf,d0
;.boucle_temporise
; move.b (a3),d2
;.attend_changement
; cmp.b (a3),d2
; beq.s .attend_changement
; dbra d0,.boucle_temporise
; move.b (a0)+,2(a2)
; cmpa.l a1,a0
; blt.s .boucle_envoie_clavier
; rts

 dc.b 0
data_kybd_absolu
 dc.b 9
data_kybd_xmax
 dc.w 319
data_kybd_ymax
 dc.w 199
 dc.b $0e,0
data_kybd_xpos
 dc.w 160
data_kybd_ypos
 dc.w 100
 dc.b $0c
 dc.b 1
 dc.b 1

 even
 
installe_souris_relative
 pea data_kybd_relative
 move #1-1,-(sp)
 move #25,-(sp)
 trap #14
 addq #8,sp
 rts
 
data_kybd_relative
 dc.b 8

 even
 
demande_position_souris
 tst.b flag_souris_libre
 beq.s .souris_pas_libre
.attend_clavier_disponible
 btst #1,$fffffc00.w		Attend que le clavier soit libre
 beq.s .attend_clavier_disponible
 move.b #$0d,$fffffc02.w	Demande de positionnement absolu
.souris_pas_libre
 rts 
    
routine_clavier
; movem.l d0-a6,-(sp)
; not.l $ffff9800.w
; andi #$f8ff,sr		Masque le niveau d'IPL
; ori #$500,sr		Puis valide un niveau 5
 move.l d0,-(sp)
 move.l d1,-(sp)
 moveq #0,d0
 moveq #0,d1
debut
 move.b $fffffc00.w,d0
 bpl.s fin_2  ; -> si le bit 7 est nul,alors pas d'interrupt clavier.
 
 btst #0,d0
 beq.s fin_1  ; -> si le bit 0 est nul,alors pas d'octet en attente.

 tst.b longueur_pack
 bne.s lecture_pack 

 move.b $fffffc02.w,d1
 bmi gŠre_code_n‚gatif
 move d1,code_scan_118	** .b
 st (‚tat_touches,d1.w)
 st flag_touche_press‚e
fin_1
 and.b #$20,d0
 beq.s fin_2
 move.b $fffffc02.w,d0
fin_2
 btst #4,$fffffa01.w
 beq.s debut
 bclr #6,$fffffa11.w
 move.l (sp)+,d1
 move.l (sp)+,d0
; not.l $ffff9800.w
; movem.l (sp)+,d0-a6
 rte

lecture_pack
 jmp ([routine_lecture_pack])





routine_dummy
 move.b $fffffc02.w,d1
 subq.b #1,longueur_pack 
 bra.s fin_2

routine_lecture_b
 move.b $fffffc02.w,d1
 move boutons_118(pc),d0

 btst #0,d0
 beq.s .teste_appui_gauche

.teste_relache_gauche
 btst #3,d1
 beq.s .fin_test_gauche
 bclr #0,d0
 bra.s .fin_test_gauche

.teste_appui_gauche
 btst #2,d1
 beq.s .fin_test_gauche
 bset #0,d0
 bra.s .fin_test_gauche

 nop
.fin_test_gauche  

 btst #1,d0
 beq.s .teste_appui_droit

.teste_relache_droit
 btst #1,d1
 beq.s .fin_test_droit
 bclr #1,d0
 bra.s .fin_test_droit

.teste_appui_droit
 btst #0,d1
 beq.s .fin_test_droit
 bset #1,d0
 bra.s .fin_test_droit

 nop
.fin_test_droit


 move d0,boutons_118
 move.l #routine_lecture_x1,routine_lecture_pack
 subq.b #1,longueur_pack 
 bra fin_2



routine_lecture_x1
 move.b $fffffc02.w,mousex_118
 move.l #routine_lecture_x2,routine_lecture_pack
 subq.b #1,longueur_pack 
 bra fin_2


routine_lecture_x2
 move.b $fffffc02.w,mousex_118+1
 tst vitesse_souris
 beq.s .vitesse_normale
 lsr mousex_118
.vitesse_normale
 move.l #routine_lecture_y1,routine_lecture_pack
 subq.b #1,longueur_pack 
 bra fin_2


routine_lecture_y1
 move.b $fffffc02.w,mousey_118
 move.l #routine_lecture_y2,routine_lecture_pack
 subq.b #1,longueur_pack 
 bra fin_2


routine_lecture_y2
 move.b $fffffc02.w,mousey_118+1
 tst vitesse_souris
 beq.s .vitesse_normale
 lsr mousey_118
.vitesse_normale
 move.l #routine_dummy,routine_lecture_pack
 subq.b #1,longueur_pack 
 bra fin_2

     
gŠre_code_n‚gatif
 cmp #$f7,d1
 beq.s gŠre_header_1
gŠre_code_relachement
 bclr #7,d1
 sf (‚tat_touches,d1.w)
 sf flag_touche_press‚e
 bra fin_2

gŠre_header_1
 move.l #routine_lecture_b,routine_lecture_pack
 move.b #5,longueur_pack
 bra fin_2

routine_lecture_pack	dc.l routine_dummy
boutons_118		ds.w 1
  
* f6 -> lecture m‚moire

* f7 -> souris absolue

* f8 -> souris relative
* f9 ->
* fa ->
* fb ->

* fc -> valeur de l'horloge
 
* fd ->

* fe -> joy 0
* ff -> joy 1

 BSS

 even
‚tat_touches		ds.b 127
   
cpt			ds.w 1

mousex_118		ds.w 1
mousey_118		ds.w 1

code_scan_118		ds.w 1

vitesse_souris		ds.w 1

flag_touche_press‚e	ds.b 1
longueur_pack 		ds.b 1


 even

;0 - $36 - SHIFT droit
;1 - $2a - SHIFT gauche
;2 - $1d - CONTROL
;3 - $38 - ALTERNATE
;4 - $3a - CAPS LOCK
;5 - $47 - CLR HOME (bouton droit)
;6 - $52 - INSERT (bouton gauche)
  
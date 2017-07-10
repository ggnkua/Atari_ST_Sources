module_soundtrack
;
;
;               Routine de replay Soundtrack STE 
;
;     ½ NeXT /, Coding by MIT, Optimisations by Dbug II (!!)
;
;
;          REGISTRES UTILISS DANS LE ®BIT DIST¯ SCREEN
;
; d0 --> Adresse volume Voie 1 // sf.b -> Basse R‚z|60 Hz
; d1 -> Adresse volume Voie 2
; d2 -> Boucle Dbra
; d3 -> Contient 2.b -> Haute R‚z|50 Hz
; d4 -> Utilis‚ pour les calculs temporaires (.l)
; d5/a5 --> $ffff820a.w (Fr‚quence)             // Sample Voie 4
; d6/a6 --> Pointeur sur la table de distort // Buffer de replay DMA
; d7 -> Adresse de base de l'‚cran (.l)
;
; a0 -> Table de volume
; a1 --> // $ffff8260.w (R‚solution) -7 -> $ffff8203.w (Compteurs vid‚o)
; a2 -> Sample Voie 1
; a3 -> Sample Voie 2
; a4 -> Sample Voie 3
; a5/d5 --> Sample Voie 4         // $ffff820a.w (Fr‚quence)
; a6/d6 --> Buffer de replay DMA // pointeur sur la table de distort
; ** A7:LIBRE ** Pile
;
; USP:LIBRE
;
base_systeme   = $1000
adr_volume_tab equ base_systeme
adr_replay     equ base_systeme+256*65
nb_oct_ste     = 126*2
nb_write_ste   = 126

************************************************************************
************************************************************************
************************************************************************
fin_ech = 800    * attente apres la fin du sample
 rsreset
note                   rs.l 1
adr_debut_sample       rs.l 1
adr_fin_sample         rs.l 1
adr_fin_sample_bis     rs.l 1
adr_debut_boucle       rs.l 1
adr_fin_boucle         rs.l 1
lenght_boucle          rs.l 1        *x2
lenght_boucle_bis      rs.l 1        *x2
lenght_intrument       rs.l 1
frq                    rs.l 1
* .w
nnote                  rs.w 1
volume                 rs.w 1
adr_volume             rs.w 1
instrument             rs.b 1
commande               rs.b 1       
parametre_commande     rs.b 1       
 rs.b 1
lenght_pack=__rs

sauvegarde_systeme
 lea (adr_volume_tab).w,a0
 lea sauve_systeme,a1
 move #(256*65)-1,d0
.sauve
 move.b (a0)+,(a1)+
 dbra d0,.sauve

 lea (adr_replay).w,a0
 lea aaa,a1
 lea bbb,a2
.echange_code
 move.l (a0),d0
 move.l (a1),d1
 exg d0,d1
 move.l d0,(a0)+
 move.l d1,(a1)+
 cmpa.l a2,a1
 blt.s .echange_code
 rts

restaure_systeme
 lea sauve_systeme,a0
 lea (adr_volume_tab).w,a1
 move #(256*65)-1,d0
.sauve
 move.b (a0)+,(a1)+
 dbra d0,.sauve

 lea (adr_replay).w,a0
 lea aaa,a1
 lea bbb,a2
.echange_code
 move.l (a0),d0
 move.l (a1),d1
 exg d0,d1
 move.l d0,(a0)+
 move.l d1,(a1)+
 cmpa.l a2,a1
 blt.s .echange_code
 rts
  
init
* Initialisation des buffers de replay DMA
 lea buffer,a0
 move.l a0,buffer1
 lea (nb_oct_ste+1)*2(a0),a1
 move.l a1,buffer2

 move #(nb_oct_ste+1)*2-1,d0
 move #$7f7f,d1          **>Znort $ffff
.clear1
 move d1,(a0)+
 dbra d0,.clear1

* Cr‚ation de la table des valeurs pour le volume
 lea (adr_volume_tab).w,a0
 moveq #65-1,d7
 moveq #0,d4       moveq #1,d4 ??? Pas de volume 0 ???
.table_suivante
 moveq #0,d6
.valeur_suivante
 move.l d6,d1
 moveq #65,d3
 mulu d4,d1
 divu d3,d1
 eor.b #$80,d1
 asr.b #1,d1
 move.b d1,(a0)+
 addq.w #1,d6
 cmp.w #256,d6
 blt .valeur_suivante
 addq #1,d4
 dbra d7,.table_suivante

* on clear des pointeur
 lea info_voie_1,a1
 bsr net_voice
 lea info_voie_2,a1
 bsr net_voice
 lea info_voie_3,a1
 bsr net_voice
 lea info_voie_4,a1
 bsr net_voice

 bsr init_pointeur 
 rts

net_voice
 clr (a1)
 lea sample_nul,a0
 move.l a0,adr_debut_sample(a1)
 move.l a0,adr_debut_boucle(a1)
 lea fin_ech(a0),a0
 move.l a0,adr_fin_sample(a1)
 move.l a0,adr_fin_sample_bis(a1)
 move.l a0,adr_fin_boucle(a1)
 clr.l lenght_boucle_bis(a1)
 clr.l lenght_boucle(a1)
 sf instrument(a1)
 clr volume(a1)
 sf commande(a1)
 sf parametre_commande(a1)
 move #adr_volume_tab,adr_volume(a1)
 rts

init_pointeur
 lea modfile+4,a0   * On saute le "OLLH"
 lea vitesse,a1
 move (a0)+,(a1)
 lea 20(a0),a0
 lea nb_in,a1
 move (a0)+,(a1)
 lea nb_pos,a1
 move (a0)+,(a1)
 lea pos_restart,a1
 move (a0)+,(a1)
 lea nb_pat,a1
 move (a0)+,(a1)

 lea modfile+28+6,a0
 moveq #22,d0
 mulu nb_in,d0
 add d0,a0
 lea info_instruments,a1
 move.l a0,(a1)
 moveq #0,d0
 move nb_in,d0
 lsl.l #4,d0
 add d0,a0
 lea adr_positions_pattern,a1
 move.l a0,(a1)

 moveq #0,d2
 move nb_pos,d2
 add.l d2,d2
 add.l d2,a0
 lea adr_contenu_pattern,a1
 move.l a0,(a1)

 moveq #0,d2
 move nb_pat,d2
 swap d2
 lsr.l #6,d2
 add.l a0,d2

 lea adr_buffer_debut_sample,a1
 lea buffer_fin_sample,a2
 move.l info_instruments,a0
 move nb_in,d0
 subq #1,d0
 move.l d2,a3       * adr du debut des sample
take_instruments_sample_adr
 move.l d2,(a1)+  * met l'adresse du sample de l'intruments ds le buffer
 add.l (a0),d2   *pointe sur la longueur de l'intrument
 move.l d2,(a2)+
 tst.b 14(a0)
 beq.s .rin
 add.l #fin_ech,d2
.rin
 lea 16(a0),a0
 dbra d0,take_instruments_sample_adr

 moveq #31,d0
 sub nb_in,d0
 beq.s .deja_31_instruments
 subq #1,d0
 lea sample_nul,a6
.ajout_son_nul
 move.l a6,(a1)+
 move.l a6,(a2)
 add.l #fin_ech,(a2)+
 dbra d0,.ajout_son_nul
.deja_31_instruments 

* d2 adr fin des samples
* converti les samples si ste..

;
; Reglage Interface Microwire
;
; Master  = 1216+(<=40)
; V Gauche= 1344+(<=20)
; V Droit = 1280+(<=20)
; Aigue   = 1152+(<=12)
; Grave   = 1088+(<=12)
; Mixage  = 1024+(<=3)
 move #$7ff,$ffff8924.w
 move #1256,d0  ; Master
 bsr teste_masque
 move #1364,d0  ; V Gauche 
 bsr teste_masque
 move #1300,d0  ; V Droit
 bsr teste_masque
 move #1152+06,d0  ; Aigues
 bsr teste_masque
 move #1088+10,d0  ; Basses
 bsr teste_masque
 move #1025,d0  ; Mixage
 bsr teste_masque
 move.b #1,$ffff8921.w   * 12.5 Khz

 lea offset_sur_position_pattern,a0
 clr (a0)
 move.l adr_positions_pattern,a1
 moveq #0,d1
 move (a1)+,d1
 swap d1
 lsr.l #6,d1
 add.l adr_contenu_pattern,d1
 lea adr_positions_pattern_courante,a2
 move.l d1,(a2)
;* multiplie par 1024


 lea offset_ds_pattern,a2
 clr (a2)
 lea compteur_vbl,a2
 clr (a2)

 lea sample_nul,a2
 move.l a2,a3
 move #fin_ech-1,d0
 move #$7f7f,d1
.loop
 move d1,(a3)+
 dbra d0,.loop

 move.l a2,a3 * a2 voie 1
 move.l a3,a4 * a3 voie 2
 move.l a4,a5 * a4 voie 3
              * a5 voie 4
 lea registre,a0
 movem.l a2-a5,(a0)
 rts

;
; Reglage Interface Microwire
;
; Master  = 1216+(<=40)
; V Gauche= 1344+(<=20)
; V Droit = 1280+(<=20)
; Aigue   = 1152+(<=12)
; Grave   = 1088+(<=12)
; Mixage  = 1024+(<=3)
restaure_microwire
 move #$7ff,$ffff8924.w
 move #1152,d0  ; Aigues
 bsr teste_masque
 move #1088,d0  ; Basses
 bsr teste_masque
 rts
 
teste_masque 
 cmp.w #$7ff,$ffff8924.w
 bne teste_masque
 move d0,$ffff8922.w
 rts

prepare_registres
 movem.l registre,a2-a5      5+4*2=5+8 -> 13
; a2
; a3
; a4
; a5/d5
 move.l buffer1,d1 5
 move.l buffer2,a6 5
 exg d1,a6         2
 move.l d1,buffer1 5
 move.l a6,buffer2 5 -> 22

 move.l d1,d0                  1
 addi.l #(nb_oct_ste*2)-1,d1   4
 lea $ffff8900.w,a0     3
 sf 1(a0)               4
 move.b d0,7(a0)        3          
 lsr.w #8,d0            6
 move.b d0,5(a0)        3
 swap d0                1
 move.b d0,3(a0)        3    - 28
*
 move.b d1,$13(a0)      3
 lsr.w #8,d1            6
 move.b d1,$11(a0)      3
 swap d1                1
 move.b d1,$f(a0)       3
 move.b #1,1(a0)        4  - 20

*calcul: 1/4 3/2
 move info_voie_1+adr_volume,d0   (1   4
 swap d0                                 1
 move info_voie_4+adr_volume,d0   (4   4
 move info_voie_3+adr_volume,d1   (3   4
 swap d1                                 1 
 move info_voie_2+adr_volume,d1   (2   4   - 18
 
 exg d5,a5
 exg d6,a6
 rts

routine_calcul
 bsr calc_digit
 bsr gere_voi_3_4

 lea compteur_vbl,a0
 addq #1,(a0)
 move (a0),d0
 cmp vitesse,d0
 bne .pas_gestion_module
 jmp gestion_module
.pas_gestion_module
* pas de gestion...

 lea info_voie_1,a1
 tst.b parametre_commande(a1)
 beq.s effet_vbl_voi1
 bsr.s gere_effet_vbl
effet_vbl_voi1

 lea info_voie_2,a1
 tst.b parametre_commande(a1)
 beq.s effet_vbl_voi2
 bsr.s gere_effet_vbl
effet_vbl_voi2

 lea info_voie_3,a1
 tst.b parametre_commande(a1)
 beq.s effet_vbl_voi3
 bsr.s gere_effet_vbl
effet_vbl_voi3

 lea info_voie_4,a1
 tst.b parametre_commande(a1)
 beq.s effet_vbl_voi4
 bsr.s gere_effet_vbl
effet_vbl_voi4
 rts

gere_effet_vbl
 rts

 moveq #0,d0
 move.b commande(a1),d0
* tst d0
 beq arpegio
 cmp #1,d0
 beq portamento_up
 cmp #2,d0
 beq portamento_down
*; cmp #3,d0
*; beq change_arpegio_speed
 rts

*;change_arpegio_speed
*; rts

portamento_up
 move.b parametre_commande(a1),d0
 sub.w d0,frq(a1)
 cmp.w #$71,frq(a1)
 bpl.s mt_ok1
 move #$71,frq(a1)
mt_ok1
 move frq(a1),d0
 add d0,d0
 add d0,d0
 adda.w d0,a1
 move.l (a1),2(a0)
 rts

portamento_down
 move.b parametre_commande(a1),d0
 add.w d0,frq(a1)
 cmp.w #$358,frq(a1)
 bmi.s mt_ok2
 move #$358,frq(a1)
mt_ok2
 bra mt_ok1


arpegio
 move.b parametre_commande(a1),d0
 beq.s pas_arpegio
 move compteur_vbl,d0
 cmp.w #1,d0
 beq.s mt_loop2
 cmp.w #2,d0
 beq.s mt_loop3
 cmp.w #3,d0
 beq.s mt_loop4
 cmp.w #4,d0
 beq.s mt_loop2
 cmp.w #5,d0
 beq.s mt_loop3
pas_arpegio
 rts

mt_loop2
 move.b parametre_commande(a1),d0
 lsr.b #4,d0
 bra.s mt_cont

mt_loop3
 move.b parametre_commande(a1),d0
 and.w #$f,d0
 bra.s mt_cont

mt_loop4
 move frq(a1),d1
 bra.s mt_endpart

mt_cont
 add.w d0,d0
 move frq(a1),d1

.cherche
 cmp.w (a1)+,d1
 bne.s .cherche
 move -2(a1,d0.w),d1

mt_endpart

 rts
* l'arpegio merde , donc pour l'instant je le retire .... 
 
; lea mt_frequences,a1
 add d1,d1
 add d1,d1
 move.l (a1,d1.w),2(a0)
 rts


decrypte_mod_voie
 move.l d2,a0
 addq.l #4,d2
  
 move.b (a0)+,commande(a1)
 move.b (a0)+,parametre_commande(a1)

* cmp.b #$8,commande(a1)
* blt.s .okay
* eor #$7,$ffff8240.w
*.okay
 move.b (a0)+,d1 

 moveq #0,d0
 move.b (a0)+,d0

 cmp #36,d0
 ble.s .arg_note
 moveq #36,d0
* eor #$77,$ffff8240.w
.arg_note


 cmp.b #3,commande(a1)
 beq info_intrument_non_change *car portamento
 move d0,nnote(a1)
 add d0,d0
 add d0,d0
 move.l a6,a0
 adda.w d0,a0
 move.l (a0),frq(a1)
.pas_joue_note

 tst.b d1 
 beq info_intrument_non_change

 move.l (a0),(a1)

 and #$1f,d1
 subq #1,d1
 move.b d1,instrument(a1)
 move d1,d0
 add d1,d1
 add d1,d1
 lea adr_buffer_debut_sample,a0
 move.l (a0,d1.w),adr_debut_sample(a1)

 move.l 31*4(a0,d1.w),adr_fin_sample(a1)

 lsl #4,d0         * 16 octets par instruments
 move.l info_instruments,a0
 adda.w d0,a0
 move.l (a0),lenght_intrument(a1)

 move.l 6(a0),d1
 add.l adr_debut_sample(a1),d1
 move.l d1,adr_debut_boucle(a1)
 move.l d1,adr_fin_boucle(a1)
  
 moveq #0,d1
 move 4(a0),d1
 move d1,volume(a1)
 beq.s .volume_zero
 cmp #64,d1
 ble.s .volume_gere
 moveq #64,d1
.volume_gere
 lsl #8,d1
.volume_zero
 add.w #adr_volume_tab,d1
 move d1,adr_volume(a1)

 move.l 10(a0),d1         *lenght boucle/2
 move.l d1,lenght_boucle(a1)
 add.l d1,adr_fin_boucle(a1)

info_intrument_non_change 
 moveq #0,d0
 move.b commande(a1),d0 * octet de commande

 cmp.b #$a,d0
 beq volume_slide
 cmp.b #$b,d0
 beq commande_jump
 cmp.b #$c,d0
 beq commande_set_volume
 cmp.b #$d,d0
 beq commande_break_pattern
 cmp.b #$f,d0
 beq commande_set_vitesse
 rts

volume_slide
 move volume(a1),d0
 move.b parametre_commande(a1),d1
 and #$f,d1
 sub d1,d0
 move.b parametre_commande(a1),d1
 lsr #4,d1
 add d1,d0
 move d0,volume(a1)

 move.l d0,d1
 beq.s .zero_volume_effet
 subq #1,d1
 cmp #64,d1
 ble.s .volume_gere_effet
 moveq #64,d1
.volume_gere_effet
 lsl #8,d1
.zero_volume_effet
 add.w #adr_volume_tab,d1
 move d1,adr_volume(a1)
* elseif
 tst d0
 bne mt_back
 lea sample_nul,a0
 move.l a0,adr_debut_sample(a1)
 lea fin_ech(a0),a0
 move.l a0,adr_fin_sample(a1)
 clr.l lenght_boucle_bis(a1)
 rts
 
commande_jump
 move.b parametre_commande(a1),d0
 lea offset_sur_position_pattern,a0
 move d0,(a0)
 move.l adr_positions_pattern,a1
 add d0,d0
 add d0,a1
 moveq #0,d1
 move (a1),d1
 swap d1
 lsr.l #6,d1
 add.l adr_contenu_pattern,d1
 lea adr_positions_pattern_courante,a1
 move.l d1,(a1)
 lea offset_ds_pattern,a1
 move #-16,(a1)
 rts

commande_set_volume
 moveq #0,d0
 move.b parametre_commande(a1),d0
 move d0,volume(a1)
 move.l d0,d1
 beq.s .zero_volume_effet
 subq #1,d1
 cmp #64,d1
 ble.s .volume_gere_effet
 moveq #64,d1
.volume_gere_effet
 lsl #8,d1
.zero_volume_effet
 add.w #adr_volume_tab,d1
 move d1,adr_volume(a1)
* elseif
 tst.b d0
 bne mt_back
 lea sample_nul,a0
 move.l a0,adr_debut_sample(a1)
 lea fin_ech(a0),a0
 move.l a0,adr_fin_sample(a1)
 clr.l lenght_boucle_bis(a1)
 rts

commande_break_pattern
 lea offset_sur_position_pattern,a0
 move (a0),d0
 addq #1,d0
 cmp nb_pos,d0
 blt.s ok_pas_fin_mus
 move pos_restart,d0
ok_pas_fin_mus
 move d0,(a0)
 move.l adr_positions_pattern,a1
 add d0,d0
 add d0,a1
 moveq #0,d1
 move (a1),d1
 swap d1
 lsr.l #6,d1
 add.l adr_contenu_pattern,d1
 lea adr_positions_pattern_courante,a1
 move.l d1,(a1)
 lea offset_ds_pattern,a1
 move #-16,(a1)
 rts

commande_set_vitesse
 move.b parametre_commande(a1),d0
 and #$f,d0
 beq.s mt_back
 lea compteur_vbl,a1
 clr (a1)
 lea vitesse,a1
 move d0,(a1)
mt_back
 rts


 
 opt o+
calc_digit
;
; On s'occupe de savoir si les samples sont finis
; 
; Voie 1
 lea info_voie_1,a6
 cmp.l adr_fin_sample_bis(a6),a2
 blt.s no_ini1
 tst.l lenght_boucle_bis(a6)
 beq.s nul1
 sub.l lenght_boucle_bis(a6),a2
 bra.s no_ini1
nul1
 lea sample_nul,a2
 move.l a2,adr_fin_sample_bis(a6)
 add.l #fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)

; Voie 2
no_ini1
 cmp.l adr_fin_sample_bis+lenght_pack(a6),a3
 blt.s no_ini2
 tst.l lenght_boucle_bis+lenght_pack(a6)
 beq.s nul2
 sub.l lenght_boucle_bis+lenght_pack(a6),a3
 bra.s no_ini2
nul2
 lea sample_nul,a3
 move.l a3,adr_fin_sample_bis+lenght_pack(a6)
 add.l #fin_ech,adr_fin_sample_bis+lenght_pack(a6)
 clr.l lenght_boucle_bis+lenght_pack(a6)

; Voie 3
no_ini2
 cmp.l adr_fin_sample_bis+lenght_pack*2(a6),a4
 blt.s no_ini3
 tst.l lenght_boucle_bis+lenght_pack*2(a6)
 beq.s nul3
 sub.l lenght_boucle_bis+lenght_pack*2(a6),a4
 bra.s no_ini3
nul3
 lea sample_nul,a4
 move.l a4,adr_fin_sample_bis+lenght_pack*2(a6)
 add.l #fin_ech,adr_fin_sample_bis+lenght_pack*2(a6)
 clr.l lenght_boucle_bis+lenght_pack*2(a6)

; Voie 4
no_ini3
 cmp.l adr_fin_sample_bis+lenght_pack*3(a6),a5
 blt.s No_ini4
 tst.l lenght_boucle_bis+lenght_pack*3(a6)
 beq.s nul4
 sub.l lenght_boucle_bis+lenght_pack*3(a6),a5
 bra.s no_ini4
nul4
 lea sample_nul,a5
 move.l a5,adr_fin_sample_bis+lenght_pack*3(a6)
 add.l #fin_ech,adr_fin_sample_bis+lenght_pack*3(a6)
 clr.l lenght_boucle_bis+lenght_pack*3(a6)

no_ini4
 movem.l a2-a5,registre
 rts
  
 opt o-
aaa
debut_bloc
 exg d5,a5
 exg d6,a6
 swap d0
voic_ste1 = *+2
 move.b 0(a2),d0  3  Sample voie 1
 move d0,a0     1  On modifie l'adresse sur la table volume 1
 move.b (a0),d1   2  On r‚cupŠre le bon volume
 swap d0
voic_ste4 = *+2 
 move.b 0(a5),d0  3  Sample voie 4
 move d0,a0     1  Table volume 4
 add.b (a0),d1    2
 move.b d1,(a6)+  2  Stocke la valeur 1+4 dans le buffer (Gauche)
 swap d1
voic_ste3 = *+2
 move.b 0(a4),d1    Sample voie 3
 move d1,a0       Table volume 3
 move.b (a0),d0
 swap d1
voic_ste2 = *+2
 move.b 0(a3),d1    Sample voie 2
 move d1,a0       Table volume 2
 add.b (a0),d0
 move.b d0,(a6)+    Stocke la valeur 2+3 dans le buffer (Droit)

 swap d0
voic_ste1a = *+2
 move.b 0(a2),d0  3  Sample voie 1
 move d0,a0     1  On modifie l'adresse sur la table volume 1
 move.b (a0),d1   2  On r‚cupŠre le bon volume
 swap d0
voic_ste4a = *+2 
 move.b 0(a5),d0  3  Sample voie 4
 move d0,a0     1  Table volume 4
 add.b (a0),d1    2
 move.b d1,(a6)+  2  Stocke la valeur 1+4 dans le buffer (Gauche)
 swap d1
voic_ste3a = *+2
 move.b 0(a4),d1    Sample voie 3
 move d1,a0       Table volume 3
 move.b (a0),d0
 swap d1
voic_ste2a = *+2
 move.b 0(a3),d1    Sample voie 2
 move d1,a0       Table volume 2
 add.b (a0),d0
 move.b d0,(a6)+    Stocke la valeur 2+3 dans le buffer (Droit)
 exg d5,a5
 exg d6,a6
 sf d0
 rts
fin_bloc
longueur_bloc equ fin_bloc-debut_bloc
 
 rept 61
 exg d5,a5
 exg d6,a6
 swap d0
 move.b 0(a2),d0
 move d0,a0
 move.b (a0),d1
 swap d0
 move.b 0(a5),d0
 move d0,a0
 add.b (a0),d1
 move.b d1,(a6)+
 swap d1
 move.b 0(a4),d1
 move d1,a0
 move.b (a0),d0
 swap d1
 move.b 0(a3),d1
 move d1,a0
 add.b (a0),d0
 move.b d0,(a6)+
*
 swap d0
 move.b 0(a2),d0
 move d0,a0
 move.b (a0),d1
 swap d0
 move.b 0(a5),d0
 move d0,a0
 add.b (a0),d1
 move.b d1,(a6)+
 swap d1
 move.b 0(a4),d1
 move d1,a0
 move.b (a0),d0
 swap d1
 move.b 0(a3),d1
 move d1,a0
 add.b (a0),d0
 move.b d0,(a6)+
 exg d5,a5
 exg d6,a6
 sf d0
 rts
 endr

debut_octet
 exg d5,a5
 exg d6,a6
 swap d0
 move.b 0(a2),d0
 move d0,a0
 move.b (a0),d1
 swap d0
 move.b 0(a5),d0
 move d0,a0
 add.b (a0),d1
 move.b d1,(a6)+
 swap d1
 move.b 0(a4),d1
 move d1,a0
 move.b (a0),d0
 swap d1
 move.b 0(a3),d1
 move d1,a0
 add.b (a0),d0
 move.b d0,(a6)+   => 32 nops
*
ajvoic_ste1 = *+2
 lea 0(a2),a2          2
ajvoic_ste2 = *+2
 lea 0(a3),a3          2
ajvoic_ste3 = *+2
 lea 0(a4),a4          2
ajvoic_ste4 = *+2
 lea 0(a5),a5          2 => 8 nops // reste 24 nops … trouver (96 cycles) 
 move.l fuck,fuck  36/9
 move.l fuck,fuck  36/9
 move.l (a6),(a6)  20/5
 nop                4/1 => 24 nops
 exg d5,a5
 exg d6,a6
 sf d0
 rts
fin_octet
 dcb longueur_bloc-(fin_octet-debut_octet),$4e71  On bourre la fin !!!

dernier_octet
 exg d5,a5
 exg d6,a6
 swap d0
 move.b (a2),d0
 move d0,a0
 move.b (a0),d1
 swap d0
 move.b (a5),d0
 move d0,a0
 add.b (a0),d1
 move.b d1,(a6)+
 swap d1
 move.b (a4),d1
 move d1,a0
 move.b (a0),d0
 swap d1
 move.b (a3),d1
 move d1,a0
 add.b (a0),d0
 move.b d0,(a6)+
*
 move.l fuck,fuck  36/9
 move.l fuck,fuck  36/9
 move.l fuck,fuck  36/9
 move.l -4(a6),-4(a6)  20/5
 exg d5,a5
 exg d6,a6
 sf d0
 rts
bbb

gestion_module
 clr (a0)

 moveq #0,d1
 move offset_ds_pattern,d1
 add.l adr_positions_pattern_courante,d1
 move.l d1,d2

 lea tfreq_ste,a6
 lea info_voie_1,a1
 bsr decrypte_mod_voie

 lea info_voie_2,a1
 bsr decrypte_mod_voie

 lea info_voie_3,a1
 bsr decrypte_mod_voie

 lea info_voie_4,a1
 bsr decrypte_mod_voie
 
gestion_offset_ds_pattern
 lea offset_ds_pattern,a0
 add #16,(a0)
 cmp #64*16,(a0)
 bne.s pas_new_pattern

 clr (a0)
 lea offset_sur_position_pattern,a0
 moveq #0,d0
 move (a0),d1
 addq #1,d1
 cmp nb_pos,d1
 blt.s pas_fin_musike
 move pos_restart,d1
pas_fin_musike
 move d1,(a0)
*
 move.l adr_positions_pattern,a1
 add d1,d1
 add d1,a1
 moveq #0,d1
 move (a1),d1
 swap d1
 lsr.l #6,d1
;* mulu #1024,d1
 add.l adr_contenu_pattern,d1
 lea adr_positions_pattern_courante,a1
 move.l d1,(a1)
;* multiplie par 1024
*
pas_new_pattern

 bsr gere_voi_1_2
 rts

gere_voi_1_2
 lea info_voie_1,a1
 move.l (a1),d0
 beq fin_gere_voi_1
 clr.l (a1)
 lea registre,a0
 move.l adr_debut_sample(a1),(a0)
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0

;
; Ici, les routines qui automodifient le code
;
 lea (adr_replay+voic_ste1-aaa).w,a2
 lea (adr_replay+voic_ste1a-aaa).w,a3
x set 0
 rept 62
 move (a0)+,x(a2)
 move (a0)+,x(a3)
x set x+longueur_bloc
 endr
 move (a0)+,x(a2)
 move (a0),(adr_replay+ajvoic_ste1-aaa).w
fin_gere_voi_1

 lea info_voie_2,a1
 move.l (a1),d0
 beq gere_voie_3
 clr.l (a1)
 lea registre+4,a0
 move.l adr_debut_sample(a1),(a0)
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0

 lea (adr_replay+voic_ste2-aaa).w,a2
 lea (adr_replay+voic_ste2a-aaa).w,a3
x set 0
 rept 62
 move (a0)+,x(a2)
 move (a0)+,x(a3)
x set x+longueur_bloc
 endr
 move (a0)+,x(a2)
 move (a0),(adr_replay+ajvoic_ste2-aaa).w
gere_voie_3
 rts


gere_voi_3_4
 lea info_voie_3,a1
 move.l (a1),d0
 beq gere_la_voie_4
 clr.l (a1)
 lea registre+4*2,a0
 move.l adr_debut_sample(a1),(a0)
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0

 lea (adr_replay+voic_ste3-aaa).w,a2
 lea (adr_replay+voic_ste3a-aaa).w,a3
x set 0
 rept 62
 move (a0)+,x(a2)
 move (a0)+,x(a3)
x set x+longueur_bloc
 endr
 move (a0)+,x(a2)
 move (a0),(adr_replay+ajvoic_ste3-aaa).w
gere_la_voie_4

 lea info_voie_4,a1
 move.l (a1),d0
 beq fin_fgere_voi_2_3_4
 clr.l (a1)
 lea registre+4*3,a0
 move.l adr_debut_sample(a1),(a0)
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0

.voie_4ste
 lea (adr_replay+voic_ste4-aaa).w,a2
 lea (adr_replay+voic_ste4a-aaa).w,a3
x set 0
 rept 62
 move (a0)+,x(a2)
 move (a0)+,x(a3)
x set x+longueur_bloc
 endr
 move (a0)+,x(a2)
 move (a0),(adr_replay+ajvoic_ste4-aaa).w
fin_fgere_voi_2_3_4
 rts

bgt
  opt w+,o+,d+,ow-   ****,p+
 bra init
 bra routine_calcul
 bra fin
 
* commande gere actuellement
 * $b break patternand jump to next position
 * $c set volume
 * $d break pattern
 * $f set speed

* frequence ste
* 0  6258 Hz
* 1 12517 Hz
* 2 25033 Hz
* 3 50066 Hz
freq_ste = 0 * 12517 hz
 
* doit-on sauvegarder les registres mfp
save_registers = 1








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
adr_volume			   rs.l 1
instrument             rs.b 1
commande               rs.b 1       
parametre_commande     rs.b 1       
 rs.b 1
lenght_pack=__rs


*frequence ste 
 ifeq freq_ste
 include tb1267d.s
nb_oct_ste = 126
nb_write_ste = 126
 endc
 ifeq freq_ste-1
 include tb12619d.s
nb_oct_ste = 126*2
nb_write_ste = 126
 endc
 ifeq freq_ste-2
 include tb25130d.s
nb_oct_ste = 251*2
nb_write_ste = 251
 endc
 ifeq freq_ste-3
* include tb25142d.s
*nb_oct_ste = 251*4
*nb_write_ste = 251
 include tb50142d.s
nb_oct_ste = 501*2
nb_write_ste = 501
 endc


tfreq
tfreq_ste
 dc.l nste0-tfreq,nste1-tfreq,nste2-tfreq
 dc.l nste3-tfreq,nste4-tfreq,nste5-tfreq,nste6-tfreq,nste7-tfreq,nste8-tfreq,nste9-tfreq,nste10-tfreq,nste11-tfreq,nste12-tfreq,nste13-tfreq,nste14-tfreq,nste15-tfreq,nste16-tfreq,nste17-tfreq,nste18-tfreq,nste19-tfreq,nste20-tfreq
 dc.l nste21-tfreq,nste22-tfreq,nste23-tfreq,nste24-tfreq,nste25-tfreq,nste26-tfreq,nste27-tfreq,nste28-tfreq,nste29-tfreq,nste30-tfreq,nste31-tfreq,nste32-tfreq,nste33-tfreq,nste34-tfreq,nste35-tfreq,nste36-tfreq
ftfreq
 
adr_volume_tab ds.l 1
volume_tab ds.b 256*65+256

init

 move #$2700,sr
 lea ftfreq(pc),a0
 move.l a0,d1
 lea tfreq_ste(pc),a0
 move.l a0,d0
.loiu
 cmp.l d1,a0
 bge.s .fonloui
 add.l d0,(a0)+
 bra.s .loiu
.fonloui 


* init buffer
 lea buffer(pc),a0
 lea buffer1(pc),a6
 move.l a0,(a6)
 lea (nb_oct_ste+1)*2(a0),a1
 lea buffer2(pc),a6
 move.l a1,(a6)
 move.l a1,d0
 move.l a1,d1
 clr.b $ffff8901.w
 add.l #(nb_oct_ste*2)-1,d1
 move.b d0,$ffff8907.w
 lsr.l #8,d0
 move.b d0,$ffff8905.w
 lsr #8,d0
 move.b d0,$ffff8903.w
*
 move.b d1,$ffff8913.w
 lsr.l #8,d1
 move.b d1,$ffff8911.w
 lsr #8,d1
 move.b d1,$ffff890f.w

 move #(nb_oct_ste+1)*2-1,d0
 move #$ffff,d1
.clear1
 move d1,(a0)+
 dbra d0,.clear1

* Cr‚ation de la table des valeurs pour le volume
 lea volume_tab(pc),a0
 move.l a0,d0
 st d0
 addq.l #1,d0
 lea adr_volume_tab(pc),a0
 move.l d0,(a0)
 move.l d0,a0
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
 lea info_voie_1(pc),a1
 bsr net_voice
 lea info_voie_2(pc),a1
 bsr net_voice
 lea info_voie_3(pc),a1
 bsr net_voice
 lea info_voie_4(pc),a1
 bsr net_voice

 bsr init_pointeur 

*
 clr.b $fffffa07.w
 clr.b $fffffa09.w

 lea $ffff8800.w,a0
 move.l #$08000000,(a0)
 move.l #$09000000,(a0)
 move.l #$0a000000,(a0)

 move #$2300,sr
 stop #$2300
 move.b #1,$ffff8901.w
 rts

 ifne save_registers
s_smfp ds.l 2
 endc
buffer

 ds.w (nb_oct_ste+1)*2
fin
 move #$2700,sr
 clr.b $ffff8901.w

 move #$2300,sr
 rts

net_voice
 clr.w (a1)
 lea sample_nul(pc),a0
 move.l a0,adr_debut_sample(a1)
 move.l a0,adr_debut_boucle(a1)
 lea fin_ech(a0),a0
 move.l a0,adr_fin_sample(a1)
 move.l a0,adr_fin_sample_bis(a1)
 move.l a0,adr_fin_boucle(a1)
 clr.l lenght_boucle_bis(a1)
 clr.l lenght_boucle(a1)
 clr.b instrument(a1)
 clr.w volume(a1)
 clr.b commande(a1)
 clr.b parametre_commande(a1)

 move.l adr_volume_tab(pc),adr_volume(a1)
 rts

* code

init_pointeur
 lea modfile(pc),a0
 cmp.l #"OLLH",(a0)+
 beq.s .okmen
 move #$700,$ffff8240.w
.okmen0
 cmp.b #$61,$fffffc02.w
 bne.s .okmen0
 rts
.okmen
 lea vitesse(pc),a1
 move (a0)+,(a1)
 lea 20(a0),a0
 lea nb_in(pc),a1
 move (a0)+,(a1)
 lea nb_pos(pc),a1
 move (a0)+,(a1)
 lea pos_restart(pc),a1
 move (a0)+,(a1)
 lea nb_pat(pc),a1
 move (a0)+,(a1)

 lea modfile+28+6(pc),a0
 moveq #22,d0
 mulu nb_in(pc),d0
 add d0,a0
 lea info_instruments(pc),a1
 move.l a0,(a1)
 moveq #0,d0
 move nb_in(pc),d0
 lsl.l #4,d0
 add d0,a0
 lea adr_positions_pattern(pc),a1
 move.l a0,(a1)

 moveq #0,d2
 move nb_pos(pc),d2
 add.l d2,d2
 add.l d2,a0
 lea adr_contenu_pattern(pc),a1
 move.l a0,(a1)

 moveq #0,d2
 move nb_pat(pc),d2
 swap d2
 lsr.l #6,d2
 add.l a0,d2

 lea adr_buffer_debut_sample(pc),a1
 lea buffer_fin_sample(pc),a2
 move.l info_instruments(pc),a0
 move nb_in(pc),d0
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
 sub nb_in(pc),d0
 beq.s .deja_31_instruments
 subq #1,d0
 lea sample_nul(pc),a6
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
 move #1152+2,d0  ; Aigues
 bsr teste_masque
 move #1088,d0  ; Basses
 bsr teste_masque
 move #1025,d0  ; Mixage
 bsr teste_masque
* bit 7 a 1 si mono
*  1 frequence 12517 Hz
*  2 frequence 25033 Hz
 move.b #freq_ste,$ffff8921.w

 lea offset_sur_position_pattern(pc),a0
 clr (a0)
 move.l adr_positions_pattern(pc),a1
 moveq #0,d1
 move (a1)+,d1
 swap d1
 lsr.l #6,d1
 add.l adr_contenu_pattern(pc),d1
 lea adr_positions_pattern_courante(pc),a2
 move.l d1,(a2)
;* multiplie par 1024


 lea offset_ds_pattern(pc),a2
 clr (a2)
 lea compteur_vbl(pc),a2
 clr (a2)

 lea sample_nul(pc),a2
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
 lea registre(pc),a0
 movem.l a2-a5,(a0)
 rts

teste_masque 
 cmp.w #$7ff,$ffff8924.w
 bne teste_masque
 move.w d0,$ffff8922.w
 rts



routine_calcul
 movem.l d0-a6,-(sp)
 bsr cacl_digit
 bsr gere_voi_3_4

 lea compteur_vbl(pc),a0
 addq #1,(a0)
 move (a0),d0
 cmp vitesse(pc),d0
 bne .pas_gestion_module
 bra gestion_module
.pas_gestion_module
* pas de gestion...

 lea info_voie_1(pc),a1
 tst.b parametre_commande(a1)
 beq.s effet_vbl_voi1
 bsr.s gere_effet_vbl
effet_vbl_voi1

 lea info_voie_2(pc),a1
 tst.b parametre_commande(a1)
 beq.s effet_vbl_voi2
 bsr.s gere_effet_vbl
effet_vbl_voi2

 lea info_voie_3(pc),a1
 tst.b parametre_commande(a1)
 beq.s effet_vbl_voi3
 bsr.s gere_effet_vbl
effet_vbl_voi3

 lea info_voie_4(pc),a1
 tst.b parametre_commande(a1)
 beq.s effet_vbl_voi4
 bsr.s gere_effet_vbl
effet_vbl_voi4

 movem.l (sp)+,d0-a6
 rts

gere_effet_vbl
 rts

 moveq #0,d0
 move.b commande(a1),d0
 tst d0
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
 move.w #$71,frq(a1)
mt_ok1
 move.w frq(a1),d0
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
 move.w #$358,frq(a1)
mt_ok2
 bra mt_ok1


arpegio
 move.b parametre_commande(a1),d0
 beq.s pas_arpegio
 move.w compteur_vbl(pc),d0
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
 move.w frq(a1),d1
 bra.s mt_endpart

mt_cont
 add.w d0,d0
 move.w frq(a1),d1

.cherche
 cmp.w (a1)+,d1
 bne.s .cherche
 move.w -2(a1,d0.w),d1

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
 eor #$77,$ffff8240.w
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
 lea adr_buffer_debut_sample(pc),a0
 move.l (a0,d1.w),adr_debut_sample(a1)

 move.l 31*4(a0,d1.w),adr_fin_sample(a1)

 lsl #4,d0         * 16 octets par instruments
 move.l info_instruments(pc),a0
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
 add.l adr_volume_tab(pc),d1
 move.l d1,adr_volume(a1)

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
 add.l adr_volume_tab(pc),d1
 move.l d1,adr_volume(a1)
* elseif
 tst d0
 bne mt_back
 lea sample_nul(pc),a0
 move.l a0,adr_debut_sample(a1)
 lea fin_ech(a0),a0
 move.l a0,adr_fin_sample(a1)
 clr.l lenght_boucle_bis(a1)
 rts
 
commande_jump
 move.b parametre_commande(a1),d0
 lea offset_sur_position_pattern(pc),a0
 move d0,(a0)
 move.l adr_positions_pattern(pc),a1
 add d0,d0
 add d0,a1
 moveq #0,d1
 move (a1),d1
 swap d1
 lsr.l #6,d1
 add.l adr_contenu_pattern(pc),d1
 lea adr_positions_pattern_courante(pc),a1
 move.l d1,(a1)
 lea offset_ds_pattern(pc),a1
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
 add.l adr_volume_tab(pc),d1
 move.l d1,adr_volume(a1)
* elseif
 tst.b d0
 bne mt_back
 lea sample_nul(pc),a0
 move.l a0,adr_debut_sample(a1)
 lea fin_ech(a0),a0
 move.l a0,adr_fin_sample(a1)
 clr.l lenght_boucle_bis(a1)
 rts

commande_break_pattern
 lea offset_sur_position_pattern(pc),a0
 move (a0),d0
 addq #1,d0
 cmp nb_pos(pc),d0
 blt.s ok_pas_fin_mus
 move pos_restart(pc),d0
ok_pas_fin_mus
 move d0,(a0)
 move.l adr_positions_pattern(pc),a1
 add d0,d0
 add d0,a1
 moveq #0,d1
 move (a1),d1
 swap d1
 lsr.l #6,d1
 add.l adr_contenu_pattern(pc),d1
 lea adr_positions_pattern_courante(pc),a1
 move.l d1,(a1)
 lea offset_ds_pattern(pc),a1
 move #-16,(a1)
 rts

commande_set_vitesse
 move.b parametre_commande(a1),d0
 and #$f,d0
 beq.s mt_back
 lea compteur_vbl(pc),a1
 clr (a1)
 lea vitesse(pc),a1
 move d0,(a1)
mt_back
 rts


cacl_digit
 movem.l registre(pc),a2-a5

* on echange les buffers
 move.l buffer2(pc),a6
 move.l buffer1(pc),d1
 lea buffer2(pc),a0
 move.l d1,(a0)
 lea buffer1(pc),a0
 move.l a6,(a0)

 move.l d1,d0
 add.l #(nb_oct_ste*2)-1,d1
 clr.b $ffff8901.w
 move.b d0,$ffff8907.w
 lsr.l #8,d0
 move.b d0,$ffff8905.w
 lsr #8,d0
 move.b d0,$ffff8903.w
*
 move.b d1,$ffff8913.w
 lsr.l #8,d1
 move.b d1,$ffff8911.w
 lsr #8,d1
 move.b d1,$ffff890f.w
 move.b #1,$ffff8901.w

 move.l info_voie_1+adr_volume(pc),d0
 move.l info_voie_2+adr_volume(pc),d1
 move.l info_voie_3+adr_volume(pc),d2
 move.l info_voie_4+adr_volume(pc),d3
 moveq #0,d7
 opt o-

 move #(nb_oct_ste/nb_write_ste)-1,d5
loop_ste
* avec volume
voic_ste1 = *+2
 move.b 0(a2),d0  3  Sample voie 1
 move.l d0,a0     1  On modifie l'adresse sur la table volume 1
 move.b (a0),d0   2  On r‚cupŠre le bon volume
voic_ste4 = *+2 
 move.b 0(a5),d3  3  Sample voie 4
 move.l d3,a0     1  Table volume 4
 add.b (a0),d0    2
 move.b d0,(a6)+  2  Stocke la valeur 1+4 dans le buffer (Gauche)
voic_ste3 = *+2
 move.b 0(a4),d2    Sample voie 3
 move.l d2,a0       Table volume 3
 move.b (a0),d0
voic_ste2 = *+2
 move.b 0(a3),d1    Sample voie 2
 move.l d1,a0       Table volume 2
 add.b (a0),d0
 move.b d0,(a6)+    Stocke la valeur 2+3 dans le buffer (Droit)
fvoice_ste equ 2+(*-voic_ste1)

 rept nb_write_ste-2
 move.b 0(a2),d0
 move.l d0,a0
 move.b (a0),d0
 move.b 0(a5),d3
 move.l d3,a0
 add.b (a0),d0
 move.b d0,(a6)+
 move.b 0(a4),d2
 move.l d2,a0
 move.b (a0),d0
 move.b 0(a3),d1
 move.l d1,a0
 add.b (a0),d0
 move.b d0,(a6)+
 endr 

ajvoic_ste1 = *+2
 lea 0(a2),a2 
ajvoic_ste2 = *+2
 lea 0(a3),a3 
ajvoic_ste3 = *+2
 lea 0(a4),a4 
ajvoic_ste4 = *+2
 lea 0(a5),a5 

 move.b (a2),d0
 move.l d0,a0
 move.b (a0),d0
 move.b (a5),d3
 move.l d3,a0
 add.b (a0),d0
 move.b d0,(a6)+
 move.b (a4),d2
 move.l d2,a0
 move.b (a0),d0
 move.b (a3),d1
 move.l d1,a0
 add.b (a0),d0
 move.b d0,(a6)+
 dbra d5,loop_ste

 opt o+
 
 lea info_voie_1(pc),a6
 cmp.l adr_fin_sample_bis(a6),a2
 blt.s no_ini1
 tst.l lenght_boucle_bis(a6)
 beq.s nul1
 sub.l lenght_boucle_bis(a6),a2
 bra.s no_ini1
nul1
 lea sample_nul(pc),a2
 move.l a2,adr_fin_sample_bis(a6)
 add.l #fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)
no_ini1


 lea info_voie_2(pc),a6
 cmp.l adr_fin_sample_bis(a6),a3
 blt.s no_ini2
 tst.l lenght_boucle_bis(a6)
 beq.s nul2
 sub.l lenght_boucle_bis(a6),a3
 bra.s no_ini2
nul2
 lea sample_nul(pc),a3
 move.l a3,adr_fin_sample_bis(a6)
 add.l #fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)
no_ini2

 lea info_voie_3(pc),a6
 cmp.l adr_fin_sample_bis(a6),a4
 blt.s no_ini3
 tst.l lenght_boucle_bis(a6)
 beq.s nul3
 sub.l lenght_boucle_bis(a6),a4
 bra.s no_ini3
nul3
 lea sample_nul(pc),a4
 move.l a4,adr_fin_sample_bis(a6)
 add.l #fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)
no_ini3


 lea info_voie_4(pc),a6
 cmp.l adr_fin_sample_bis(a6),a5
 blt.s No_ini4
 tst.l lenght_boucle_bis(a6)
 beq.s nul4
 sub.l lenght_boucle_bis(a6),a5
 bra.s no_ini4
nul4
 lea sample_nul(pc),a5
 move.l a5,adr_fin_sample_bis(a6)
 add.l #fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)
no_ini4

 lea registre(pc),a0
 movem.l a2-a5,(a0)
 rts
  




gestion_module
 clr.w (a0)

 moveq #0,d1
 move offset_ds_pattern(pc),d1
 add.l adr_positions_pattern_courante(pc),d1
 move.l d1,d2

 lea tfreq_ste(pc),a6
.table_note_stf
 lea info_voie_1(pc),a1
 bsr decrypte_mod_voie

 lea info_voie_2(pc),a1
 bsr decrypte_mod_voie

 lea info_voie_3(pc),a1
 bsr decrypte_mod_voie

 lea info_voie_4(pc),a1
 bsr decrypte_mod_voie
 
gestion_offset_ds_pattern
 lea offset_ds_pattern(pc),a0
 add #16,(a0)
 cmp #64*16,(a0)
 bne.s pas_new_pattern

 clr (a0)
 lea offset_sur_position_pattern(pc),a0
 moveq #0,d0
 move (a0),d1
 addq #1,d1
 cmp nb_pos(pc),d1
 blt.s pas_fin_musike
 move pos_restart(pc),d1
pas_fin_musike
 move d1,(a0)
*
 move.l adr_positions_pattern(pc),a1
 add d1,d1
 add d1,a1
 moveq #0,d1
 move (a1),d1
 swap d1
 lsr.l #6,d1
;* mulu #1024,d1
 add.l adr_contenu_pattern(pc),d1
 lea adr_positions_pattern_courante(pc),a1
 move.l d1,(a1)
;* multiplie par 1024
*
pas_new_pattern

 bsr gere_voi_1_2
 movem.l (sp)+,d0-a6
 rts

gere_voi_1_2
 lea info_voie_1(pc),a1
 move.l (a1),d0
 beq fin_gere_voi_1
 clr.l (a1)
 lea registre(pc),a0
 move.l adr_debut_sample(a1),(a0)
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0
 lea voic_ste1(pc),a2
x set 0
 rept nb_write_ste-1
 move (a0)+,x(a2)
x set x+fvoice_ste
 endr
 lea ajvoic_ste1(pc),a1
 move (a0)+,(a1)
fin_gere_voi_1


 lea info_voie_2(pc),a1
 move.l (a1),d0
 beq gere_voie_3
 clr.l (a1)
 lea registre+4(pc),a0
 move.l adr_debut_sample(a1),(a0)
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0

 lea voic_ste2(pc),a2
x set 0
 rept nb_write_ste-1
 move (a0)+,x(a2)
x set x+fvoice_ste
 endr
 lea ajvoic_ste2(pc),a1
 move (a0)+,(a1)
gere_voie_3
 rts


gere_voi_3_4
 lea info_voie_3(pc),a1
 move.l (a1),d0
 beq gere_la_voie_4
 clr.l (a1)
 lea registre+4*2(pc),a0
 move.l adr_debut_sample(a1),(a0)
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0
 lea voic_ste3(pc),a2
x set 0
 rept nb_write_ste-1
 move (a0)+,x(a2)
x set x+fvoice_ste
 endr
 lea ajvoic_ste3(pc),a1
 move (a0)+,(a1)
gere_la_voie_4

 lea info_voie_4(pc),a1
 move.l (a1),d0
 beq fin_fgere_voi_2_3_4
 clr.l (a1)
 lea registre+4*3(pc),a0
 move.l adr_debut_sample(a1),(a0)
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0

 lea voic_ste4(pc),a2
x set 0
 rept nb_write_ste-1
 move (a0)+,x(a2)
x set x+fvoice_ste
 endr
 lea ajvoic_ste4(pc),a1
 move (a0)+,(a1)
fin_fgere_voi_2_3_4

 rts

 even


 even
info_voie_1 ds.b lenght_pack
 even
info_voie_2 ds.b lenght_pack
 even
info_voie_3 ds.b lenght_pack
 even
info_voie_4 ds.b lenght_pack
 even

offset_sur_position_pattern ds.w 1
offset_ds_pattern ds.w 1
compteur_vbl ds.w 1

adr_buffer_debut_sample ds.l 31
buffer_fin_sample   ds.l 31

mt_register ds.l 1
position_pattern_courante ds.l 1
mt_debpat ds.l 1
mt_adrsave ds.l 1

vitesse ds.w 1
adr_positions_pattern ds.l 1
adr_positions_pattern_courante ds.l 1
adr_contenu_pattern ds.l 1
buffer1 ds.l 1
buffer2 ds.l 1
sample_nul ds.w fin_ech
registre ds.l 9
nb_in ds.w 1
nb_pat ds.w 1
nb_pos ds.w 1
pos_restart ds.w 1
info_instruments ds.l 1
sym ds.w 1
 even
modfile incbin beast1.low
fmode

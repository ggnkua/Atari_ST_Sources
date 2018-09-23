fin_ech = 800    * attente apres la fin du sample
nb_oct  = 205    * nb d'octet joue par vbl
  opt w-,o+,d+
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
instrument             rs.b 1
commande               rs.b 1       
parametre_commande     rs.b 1       
 rs.b 1
lenght_pack=__rs

test_carte
 move.b $fffb0001,d7
 move.b d7,d6
 and.b #$f0,d6
 cmp.b #$70,d6
 bne.s testbat
 move.b #1,streplay
 move.b #0,bat
 bra.s fin_test_select
testbat
 cmp.b #$ff,d7       * bat
 beq.s monitor_outpout
 move.b #0,streplay
 move.b #1,bat
 bra.s fin_test_select
monitor_outpout   * moniteur
 move.b #0,streplay
 move.b #0,bat
fin_test_select
 rts


joue_strk
 clr rout
* init buffer
 move.l #buffer,d0
 move.l d0,buffer1
 move.l d0,a0
 add.l #nb_oct*2,d0
 move.l d0,buffer2
 move.l d0,adr_replay

 move #nb_oct-1,d0
.clear
 clr.w (a0)+
 dbra d0,.clear

* on clear des pointeur
 lea info_voie_1,a1
 bsr net_voice
 lea info_voie_2,a1
 bsr net_voice
 lea info_voie_3,a1
 bsr net_voice
 lea info_voie_4,a1
 bsr net_voice
 
 lea modfile,a0
 bsr init_pointeur 

 move sr,-(sp)
 move #$2700,sr
 move.l $70.w,s_70
 move.l #vbl,$70.w
 move.b $fffffa07.w,s_smfp
 move.b $fffffa09.w,s_smfp+1
 move.b $fffffa13.w,s_smfp+2
 move.b $fffffa17.w,s_smfp+3

* init yamaha ...
 lea $ffff8800.w,a0
 move.l #00000000,(a0)
 move.l #01000000,(a0)
 move.l #02000000,(a0)
 move.l #03000000,(a0)
 move.l #04000000,(a0)
 move.l #05000000,(a0)
 move.l #06000000,(a0)
 move.b #7,(a0)
 move.b 2(a0),sym
 move.b #$ff,2(a0)

 move.b #1,$fffffa19.w
 move.b #60,$fffffa1f.w
 bclr #3,$fffffa17.w
 or.b #$20,$fffffa07.w
 or.b #$20,$fffffa13.w
 move.l #Routine_timer_a,$134.w
 move (sp)+,sr
 rts
 

stop_strk
 move sr,-(sp)
 move.w #$2700,sr
 move.l s_70,$70.w
 lea $ffff8800.w,a0
 move.b #7,(a0)
 move.b sym,2(a0)
 lea s_smfp,a0
 move.b (a0)+,$fffffa07.w
 move.b (a0)+,$fffffa09.w
 move.b (a0)+,$fffffa13.w
 move.b (a0)+,$fffffa17.w
 move (sp)+,sr
 rts

net_voice
 clr.w (a1)
 move.l #sample_nul,adr_debut_sample(a1)
 move.l #sample_nul+fin_ech,adr_fin_sample(a1)
 move.l #sample_nul+fin_ech,adr_fin_sample_bis(a1)
 move.l #sample_nul,adr_debut_boucle(a1)
 move.l #sample_nul+fin_ech,adr_fin_boucle(a1)
 clr.l lenght_boucle_bis(a1)
 clr.l lenght_boucle(a1)
 clr.b instrument(a1)
 clr.w volume(a1)
 clr.b commande(a1)
 clr.b parametre_commande(a1)
 rts

* code

init_pointeur


* format a l'instant du .low:
* 4 octets "OLLH"
* 2 octets nb de d'intruments (x)
* x*16 les intruments......
    * 2 octets longueur en mots
    * 2 octets volume
    * 2 octets offset pour la boucle en mots aussi
    * 2 octets longueur de la boucle en mots aussi
    * si 1 alors pas boucle .......
* 1 octet nb d'octets ds la partition des patern (x) ki suit
* x chaque octet represente le numero du pattern a jouer
* on met aune adr paire
* pattern puis sample... la pas de probleme.....

 lea modfile,a0
 cmp.l #"OLLH",(a0)+
 beq.s .okmen
 illegal
.okmen

 move.w (a0)+,d0
 move d0,d1
 lsl #4,d1
 lea modfile+6,a1
 adda.w d1,a1
 moveq #0,d1
 move.b (a1)+,d1
 move d1,nb_max_positions
 move.l a1,adr_positions_pattern
 moveq #0,d2
 move.b (a1),d2
 subq #1,d1
 moveq #0,d3
.boch
 move.b (a1)+,d3
 cmp d2,d3
 ble.s .boch1
 move d3,d2
.boch1
 dbra d1,.boch
 
 move.l a1,d1
 and.w #$fffe,d1
 addq.l #2,d1
 move.l d1,a1
*
 move.l a1,adr_contenu_pattern

* d2 n max de pattern 
 addq.l #1,d2
 swap d2
 lsr.l #6,d2
 add.l a1,d2

 lea adr_buffer_debut_sample,a1
 lea buffer_fin_sample,a2
 lea modfile+6,a0
 subq #1,d0
 move d0,d7
take_instruments_sample_adr
 move.l d2,(a1)+  * met l'adresse du sample de l'intruments ds le buffer
 add.l (a0),d2   *pointe sur la longueur de l'intrument en mots
 move.l d2,(a2)+
 tst.b 14(a0)
 beq.s .rin
 add.l #fin_ech,d2
.rin
 lea 16(a0),a0
 dbra d0,take_instruments_sample_adr

* adr debut des samples
* adr fin des samples


 lea offset_sur_position_pattern,a0
 clr (a0)
 moveq #0,d1
 move.b (a1)+,d1
 move.l adr_positions_pattern,a1
 swap d1
 lsr.l #6,d1
;* mulu #1024,d1
 add.l adr_contenu_pattern,d1
 move.l d1,adr_positions_pattern_courante
;* multiplie par 1024


 clr.w offset_ds_pattern
 clr.w compteur_vbl
 move.w #6,vitesse

 lea sample_nul,a2
 move.l a2,a3
 move #fin_ech-1,d0
.loop
 move.w #$7f7f,(a3)+
 dbra d0,.loop
 

 move.l a2,a3 * a2 voie 1
 move.l a3,a4 * a3 voie 2
 move.l a4,a5 * a4 voie 3
              * a5 voie 4
 movem.l a2-a5,registre
 rts


routimer
 dc.l calc_digit0,calc_digit1

vbl
 movem.l d0-a6,-(sp)

 move rout,d0
 move.l routimer(pc,d0.w),a0
 jsr (a0)

 bsr gere_voi_3_4
 lea compteur_vbl,a0
 addq #1,(a0)
 move (a0),d0
 cmp.w vitesse,d0
 beq gestion_module
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

 movem.l (sp)+,d0-a6
 move.l s_70,-(sp)
 rts


gere_effet_vbl
 rts

 moveq #0,d0
 move.b commande(a1),d0
 cmp #1,d0
 beq portamento_up
 cmp #2,d0
 beq portamento_down
 rts


portamento_up
 rts

portamento_down
 rts


decrypte_mod_voie
 move.l d2,a0
 addq.l #4,d2
*  
 move.b (a0)+,commande(a1)
 move.b (a0)+,parametre_commande(a1)
*
 move.b (a0)+,d1 
 move.b (a0)+,d0
*
 lea tfreq,a0
 move d0,nnote(a1)
 add d0,d0
 add d0,d0
 adda.w d0,a0
 move.l (a0),frq(a1)
*
 tst.b d1 
 beq info_intrument_non_change
*
 move.l (a0),(a1)
*
 and #$1f,d1
 subq #1,d1
 move.b d1,instrument(a1)
 move d1,d0
 add d1,d1
 add d1,d1
 lea adr_buffer_debut_sample,a0
 move.l (a0,d1.w),adr_debut_sample(a1)
 move.l 31*4(a0,d1.w),adr_fin_sample(a1)
*
 lsl #4,d0         * 8 octets par instruments
 lea modfile+6,a0
 adda.w d0,a0
 move.l (a0),lenght_intrument(a1)
*
 move.l 6(a0),d1
 add.l adr_debut_sample(a1),d1
 move.l d1,adr_debut_boucle(a1)
 move.l d1,adr_fin_boucle(a1)
* 
 move.w 4(a0),volume(a1)
*
 move.l 10(a0),d1         *lenght boucle/2
 move.l d1,lenght_boucle(a1)
 add.l d1,adr_fin_boucle(a1)
*
info_intrument_non_change 
* test commande
 moveq #0,d0
 move.b commande(a1),d0 * octet de commande

 cmp.b #$b,d0
 beq.s commande_jump
 cmp.b #$c,d0
 beq.s commande_set_volume
 cmp.b #$d,d0
 beq.s commande_break_pattern
 cmp.b #$f,d0
 beq commande_set_vitesse
 rts

commande_jump
 move.b parametre_commande(a1),d0
 lea offset_sur_position_pattern,a0
 move.w d0,(a0)
 move.l adr_positions_pattern,a1
 adda.w d0,a1
 moveq #0,d1
 move.b (a1),d1
 swap d1
 lsr.l #6,d1
;* mulu #1024,d1
 add.l adr_contenu_pattern,d1
 move.l d1,adr_positions_pattern_courante
;* multiplie par 1024
 rts

commande_set_volume
 ; perhaps another time
 moveq #0,d0
 move.b parametre_commande(a1),d0
 tst.b d0
 bne mt_back
 move.l #sample_nul,adr_debut_sample(a1)
 move.l #sample_nul+fin_ech,adr_fin_sample(a1)
 clr.l lenght_boucle_bis(a1)
 rts

commande_break_pattern
 lea offset_sur_position_pattern,a0
 move (a0),d0
 addq #1,d0
 cmp nb_max_positions,d0
 blt.s ok_pas_fin_mus
 clr d0
ok_pas_fin_mus
 move d0,(a0)
 move.l adr_positions_pattern,a1
 adda.w d0,a1
 moveq #0,d1
 move.b (a1),d1
 swap d1
 lsr.l #6,d1
;* mulu #1024,d1
 add.l adr_contenu_pattern,d1
 move.l d1,adr_positions_pattern_courante
;* multiplie par 1024
 rts

commande_set_vitesse
 move.b parametre_commande(a1),d0
 and.b #$f,d0
 beq.s mt_back
 clr.w compteur_vbl
 move d0,vitesse
mt_back
 rts






Routine_timer_a
 move.l a0,-(sp)
 move.l d0,-(sp)
 move.l adr_replay(pc),a0
 addq.l #2,adr_replay
 move.w (a0)+,d0
 and.w #$fffc,d0
 add d0,d0
 lea $ffff8800.w,a0
 move.l digitab(pc,d0.w),(a0)
 move.l digitab+4(pc,d0.w),d0
 movep.l d0,(a0)
 move.l (sp)+,d0
 move.l (sp)+,a0
 rte
* pour gagner du temps kelkes variable vont etre ici !
adr_replay ds.l 1
digitab  incbin digital.bin
 even


************** routine 5 Khz




calc_digit1
 movem.l registre,a2-a5
* on echange les buffers
 move.l buffer2,a6
 move.l buffer1,d1
 move.l d1,buffer2
 move.l a6,buffer1
 move.l d1,adr_replay
*
 opt d-,o-
 moveq #0,d7
 moveq #0,d1
 move.b #120,$fffffa1f.w *5Khz
 bra calc_digit



calc_digit0
 move.b #60,$fffffa1f.w *10Khz
 movem.l registre,a2-a5
* on echange les buffers
 move.l buffer2,a6
 move.l buffer1,d1
 move.l d1,buffer2
 move.l a6,buffer1
 move.l d1,adr_replay
*
 opt d-,o-
 moveq #0,d7
 moveq #2-1,d1

calc_digit

voic1 = *+2
 move.b 0(a2),d7
 move.w d7,d6
voic2 = *+2
 move.b 0(a3),d7
 add.w d7,d6
voic3 = *+2
 move.b 0(a4),d7
 add.w d7,d6
voic4 = *+2
 move.b 0(a5),d7
 add.w d7,d6
 move d6,(a6)+
fvoice equ 2+(*-voic1)

loop_sound

 rept 103-2
 move.b 0(a2),d7
 move.w d7,d6
 move.b 0(a3),d7
 add.w d7,d6
 move.b 0(a4),d7
 add.w d7,d6
 move.b 0(a5),d7
 add.w d7,d6
 move d6,(a6)+
 endr 


ajvoic1 = *+2
 lea 0(a2),a2 
ajvoic2 = *+2
 lea 0(a3),a3 
ajvoic3 = *+2
 lea 0(a4),a4 
ajvoic4 = *+2
 lea 0(a5),a5 

 move.b (a2),d7
 move.w d7,d6
 move.b (a3),d7
 add.w d7,d6
 move.b (a4),d7
 add.w d7,d6
 move.b (a5),d7
 add.w d7,d6
 move d6,(a6)+

 dbra d1,loop_sound


fin_calc
 opt d+,o+
 
 lea info_voie_1,a6
 cmp.l adr_fin_sample_bis(a6),a2
 blt.s no_ini1
 tst.l lenght_boucle_bis(a6)
 beq.s nul1
 sub.l lenght_boucle_bis(a6),a2
 bra.s no_ini1
nul1
 move.l #sample_nul,a2
 move.l #sample_nul+fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)
no_ini1


 lea info_voie_2,a6
 cmp.l adr_fin_sample_bis(a6),a3
 blt.s no_ini2
 tst.l lenght_boucle_bis(a6)
 beq.s nul2
 sub.l lenght_boucle_bis(a6),a3
 bra.s no_ini2
nul2
 move.l #sample_nul,a3
 move.l #sample_nul+fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)
no_ini2

 lea info_voie_3,a6
 cmp.l adr_fin_sample_bis(a6),a4
 blt.s no_ini3
 tst.l lenght_boucle_bis(a6)
 beq.s nul3
 sub.l lenght_boucle_bis(a6),a4
 bra.s no_ini3
nul3
 move.l #sample_nul,a4
 move.l #sample_nul+fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)
no_ini3


 lea info_voie_4,a6
 cmp.l adr_fin_sample_bis(a6),a5
 blt.s No_ini4
 tst.l lenght_boucle_bis(a6)
 beq.s nul4
 sub.l lenght_boucle_bis(a6),a5
 bra.s no_ini4
nul4
 move.l #sample_nul,a5
 move.l #sample_nul+fin_ech,adr_fin_sample_bis(a6)
 clr.l lenght_boucle_bis(a6)
no_ini4

 movem.l a2-a5,registre
 rts
  




gestion_module
 clr.w (a0)

 moveq #0,d1
 move offset_ds_pattern,d1
 add.l adr_positions_pattern_courante,d1
 move.l d1,d2

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
 move.w (a0),d1
 addq.w #1,d1
 cmp.w nb_max_positions,d1
 blt.s pas_fin_musike
 clr.w d1
pas_fin_musike
 move d1,(a0)
*
 move.l adr_positions_pattern,a1
 adda.w (a0),a1
 moveq #0,d1
 move.b (a1),d1
 swap d1
 lsr.l #6,d1
;* mulu #1024,d1
 add.l adr_contenu_pattern,d1
 move.l d1,adr_positions_pattern_courante
;* multiplie par 1024
*
pas_new_pattern

 bsr gere_voi_1_2

 movem.l (sp)+,d0-a6
 move.l s_70,-(sp)
 rts


gere_voi_1_2

 lea info_voie_1,a1
 move.l (a1),d0
 beq fin_gere_voi_1
 clr.l (a1)
 move.l adr_debut_sample(a1),registre
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0
 lea voic1,a2
x set 0
 rept 103-1
 move (a0)+,x(a2)
x set x+fvoice
 endr
 move (a0)+,ajvoic1
fin_gere_voi_1


 lea info_voie_2,a1
 move.l (a1),d0
 beq gere_voie_3
 clr.l (a1)
 move.l adr_debut_sample(a1),registre+4
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0
 lea voic2,a2
x set 0
 rept 103-1
 move (a0)+,x(a2)
x set x+fvoice
 endr
 move (a0)+,ajvoic2
; bra fin_fgere_voi_2_3_4
gere_voie_3
 rts


gere_voi_3_4

 lea info_voie_3,a1
 move.l (a1),d0
 beq gere_la_voie_4
 clr.l (a1)
 move.l adr_debut_sample(a1),registre+4*2
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0
 lea voic3,a2
x set 0
 rept 103-1
 move (a0)+,x(a2)
x set x+fvoice
 endr
 move (a0)+,ajvoic3
; bra fin_fgere_voi_2_3_4

gere_la_voie_4

 lea info_voie_4,a1
 move.l (a1),d0
 beq fin_fgere_voi_2_3_4
 clr.l (a1)
 move.l adr_debut_sample(a1),registre+4*3
 move.l adr_fin_sample(a1),adr_fin_sample_bis(a1)
 move.l lenght_boucle(a1),lenght_boucle_bis(a1)
 move.l d0,a0
 lea voic4,a2
x set 0
 rept 103-1
 move (a0)+,x(a2)
x set x+fvoice
 endr
 move (a0)+,ajvoic4
fin_fgere_voi_2_3_4
 rts





st_replay
 lsr.w #1,d6
 move.b (a6,d6.w),d6
 rte

carte_bat
 add.w d6,d6
 add.w d6,d6
 move.b (a6,d6.w),d6
 rte

 even
 include tab10315.s
 even

tfreq
 dc.l n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20
 dc.l n21,n22,n23,n24,n25,n26,n27,n28,n29,n30,n31,n32,n33,n34,n35,n36

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

nb_max_positions ds.w 1
mt_register ds.l 1
position_pattern_courante ds.l 1
mt_debpat ds.l 1
mt_adrsave ds.l 1

s_smfp ds.l 1
s_70 ds.l 1
sym ds.w 1 
bat ds.b 1
streplay ds.b 1
vitesse ds.w 1
adr_positions_pattern ds.l 1
adr_positions_pattern_courante ds.l 1
adr_contenu_pattern ds.l 1
buffer1 ds.l 1
buffer2 ds.l 1
adr_car ds.l 1
adr_ecr ds.l 1
sample_nul ds.w fin_ech
registre ds.l 9
rout ds.w 1
 even
buffer
 ds.w nb_oct*2
  
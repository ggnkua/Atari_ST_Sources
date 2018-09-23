 opt w-,o+,d+,m+
nombre_de_notes_geres=37
fin_ech = 800
 rsreset * par rapport a ,tailein
lenghtins     rs.l 1 *0
volumein      rs.w 1 *4
debbou        rs.l 1 *6
offset_finbou rs.l 1 *10
indic_surplus rs.w 1

************************ ici toutes les macros de mon prg
* kelkes macro ....
ye macro
 move.b (a2)+,(a3)+
 bne.s .\@
 move.b #$20,-1(a3)
.\@
 endm

recuptext macro
 moveq #\1-1,d0
.\@
 move.b (a0)+,d1
 beq.s .\@@
 cmp.b #"@",d1
 beq.s .\@@
 move.b d1,(a1)+
 dbra d0,.\@
 bra.s .\@@@
.\@@
 move.b #"_",(a1)+
 dbra d0,.\@@
.\@@@
 endm
 
atake macro
 tst.l d3
 bmi.s .\@@
 cmp.b #"@",d0
 beq.s .\@@@@@@@@@@@@@@@@@@@
 tst.b d0
 bne.s .\@@@@@@@@@@@@@@@@@@@@
.\@@@@@@@@@@@@@@@@@@@
 moveq #-1,d3
 bra.s .\@@
.\@@@@@@@@@@@@@@@@@@@@
 cmp.b #"_",d0
 beq.s .\@@
 cmp.b #" ",d0
 beq.s .\@@
 cmp.b #"0",d0
 blt.s .\@@
 cmp.b #"9",d0
 bgt.s .\@
 sub.b #"0",d0
 and.l #$f,d0
 bra.s .\@@@@
.\@
 cmp.b #"f",d0
 bgt.s .\@@
 cmp.b #"a",d0
 blt.s .\@@@
 sub.b #"a"-10,d0
 and.l #$f,d0
 bra.s .\@@@@
.\@@@
 cmp.b #"F",d0
 bgt.s .\@@
 cmp.b #"A",d0
 blt.s .\@@
 sub.b #"A"-10,d0
 and.l #$f,d0
 bra.s .\@@@@
.\@@
 moveq #-1,d0
.\@@@@
 endm
 
take macro
 move.b (a2)+,d0
 cmp.b #$ff,d0
 beq.s .\@
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a0)+
 move.b (a3,d1.w),(a0)+
 bra .\@@
.\@
 move.b #"_",(a0)+
 move.b #"_",(a0)+
.\@@
 endm

dtake macro
 move.b (a2)+,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a0)+
 move.b (a3,d1.w),(a0)+
 endm

dtakea macro
 move d7,d0
 lsr #8,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a0)+
 move.b (a3,d1.w),(a0)+
 move d7,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a0)+
 move.b (a3,d1.w),(a0)+
 endm

dtakea1 macro
 move d7,d1
 lsr #4,d7
 and #$f,d7
 and #$f,d1
 move.b (a3,d7.w),(a0)+
 move.b (a3,d1.w),(a0)+
 endm

dtakeb macro
 move d7,d0
 lsr #8,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a1)+
 move.b (a3,d1.w),(a1)+
 move d7,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a1)+
 move.b (a3,d1.w),(a1)+
 endm

dtakeb1 macro
 move d7,d1
 lsr #4,d7
 and #$f,d7
 and #$f,d1
 move.b (a3,d7.w),(a1)+
 move.b (a3,d1.w),(a1)+
 endm


dtakec macro
 swap d7
 move d7,d0
 lsr #8,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a1)+
 move.b (a3,d1.w),(a1)+
 move d7,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a1)+
 move.b (a3,d1.w),(a1)+
 swap d7
 move d7,d0
 lsr #8,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a1)+
 move.b (a3,d1.w),(a1)+
 move d7,d0
 move d0,d1
 lsr #4,d0
 and #$f,d0
 and #$f,d1
 move.b (a3,d0.w),(a1)+
 move.b (a3,d1.w),(a1)+
 endm


take1 macro
 move.b (a2)+,d0
 cmp.b #$ff,d0
 beq.s .\@
 and #$f,d0
 move.b (a3,d0.w),(a0)+
 bra .\@@
.\@
 move.b #"_",(a0)+
.\@@
 endm

macsplit macro
 moveq #-1,d2
 move.b (a0)+,d0
 atake
 tst.l d0
 bmi.s .\@@@@@
 moveq #0,d2
 move d0,d2
.\@@@@@
 move.b (a0)+,d0
 atake
 tst.l d0
 bmi.s .\@@@@@@@
 tst.l d2
 bmi.s .\@@@@@@
 lsl #4,d2
 or.b d0,d2
 bra.s .\@@@@@@@
.\@@@@@@
 moveq #0,d2
 move d0,d2
.\@@@@@@@
 move.b d2,(a2)+
 endm

macsplit1 macro
 move.b (a0)+,d0
 atake
 move.b d0,(a2)+
 endm


macsplit2 macro
 moveq #-1,d2

 move.b (a0)+,d0
 atake
 tst.l d0
 bmi.s .\@@@@@
 moveq #0,d2
 move d0,d2
.\@@@@@

 move.b (a0)+,d0
 atake
 tst.l d0
 bmi.s .\@@@@@@@
 tst.l d2
 bmi.s .\@@@@@@
 lsl #4,d2
 or.b d0,d2
 bra.s .\@@@@@@@
.\@@@@@@
 moveq #0,d2
 move d0,d2
.\@@@@@@@

 move.b (a0)+,d0
 atake
 tst.l d0
 bmi.s .\@@@@@@@@@
 tst.l d2
 bmi.s .\@@@@@@@@
 lsl #4,d2
 or.b d0,d2
 bra.s .\@@@@@@@@@
.\@@@@@@@@
 moveq #0,d2
 move d0,d2
.\@@@@@@@@@

 move.b (a0)+,d0
 atake
 tst.l d0
 bmi.s .\@@@@@@@@@@@
 tst.l d2
 bmi.s .\@@@@@@@@@@
 lsl #4,d2
 or.b d0,d2
 bra.s .\@@@@@@@@@@@
.\@@@@@@@@@@
 moveq #0,d2
 move d0,d2
.\@@@@@@@@@@@
 move d2,(a2)+
 endm






***** donc a cette version je m'arrange pour ne pas effacer ce k'il
***** y a en haut , ok ?
***** les form_dial #0 et frm_dial #3 ont ete carement supprime , merci !
c_partiiii
********************************************************************
*******************  programm de moulinexisation    ****************
************************ by mit format .mod to format .low
 include moulinex.hs
* format a l'instant du .low:
* 4 octets "OLLH"
* 2 octets nb de d'instruments (x)
* instruments
* 1 octet nb d'octets ds la partition des patern (x) ki suit
* x chaque octet represente le numero du pattern a jouer
* mais sur l'adr paire suivante...
* pattern puis sample... la pas de probleme.....



 include gemmacro.s

 move.l 4(a7),a3
 lea a7_pile,a7
 move.l $c(a3),d0
 add.l $14(a3),d0
 add.l $1c(a3),d0
 add.l #5000,d0
 move.l d0,-(sp)
 move.l a3,-(sp)
 clr.w -(sp)
 move.w #$4a,-(sp)
 trap #1
 lea 12(sp),sp

 dc.w $a000
 move.l 4(a1),a1
 move.l 76(a1),adr_car

* pour la destination pour l'instant c'est un buffer
* mais il faut veiller a ce ke cela soit un malloc par la suite... merci !
 lea buffersource,a1
 move.l a1,dest



 appl_init
 move.w d0,ap_id


 move #3,-(sp)
 trap #14
 addq.l #2,sp
 move.l d0,ecran

* inti path
 move #$19,-(sp)
 trap #1
 addq.l #2,sp
 moveq #"A",d1
 add.b d0,d1 
 move.b d1,path

* 
 move #4,-(sp)
 trap #14
 addq.l #2,sp
 cmp.b #1,d0
 beq.s .moyenne_reso
 form_alert #1,#only_moyenne
 bra.s .autre_reso
.moyenne_reso
 jsr debut
.autre_reso

 rsrc_free

 appl_exit

 clr -(sp)
 trap #1
 
debut
 pea instore
 move #$26,-(sp)
 trap #14
 addq.l #6,sp

* init

* frequence de depart 10.24 Khz
 move #freq3,frequence_choisi
 move.b #60,gum
  
 graf_mouse #0,#0
 rsrc_load #nom_rsc
 tst int_out
 bne.s ok_load_rsc
 form_alert #1,#pas_rsc
 bra fin_tout_court
ok_load_rsc
 rsrc_gaddr #0,#form1
 move.l addr_out,adr_form1

 rsrc_gaddr #0,#form2
 move.l addr_out,adr_form2

 rsrc_gaddr #0,#form3
 move.l addr_out,adr_form3

 rsrc_gaddr #0,#form4
 move.l addr_out,adr_form4

 rsrc_gaddr #0,#form5
 move.l addr_out,adr_form5

fuck
 rsrc_gaddr #0,#midi
 move.l addr_out,adr_midi

 rsrc_gaddr #0,#pitch
 move.l addr_out,adr_pitch

 rsrc_gaddr #0,#speed
 move.l addr_out,adr_speed

 rsrc_gaddr #0,#pattern
 move.l addr_out,adr_pattern

 rsrc_gaddr #0,#instrum
 move.l addr_out,adr_instrum

 rsrc_gaddr #0,#midi_rec
 move.l addr_out,adr_midi_rec

 rsrc_gaddr #0,#first_loading
 move.l addr_out,adr_first_loading

 rsrc_gaddr #0,#saving
 move.l addr_out,adr_saving

 rsrc_gaddr #0,#saving_mod
 move.l addr_out,adr_saving_mod
 


 form_center adr_form1
 move int_out+2,x_center
 move int_out+4,y_center
 move int_out+6,w_center
 move int_out+8,h_center

 form_center adr_form2
 move int_out+2,xcenter0
 move int_out+4,ycenter0
 move int_out+6,wcenter0
 move int_out+8,hcenter0

 form_center adr_form3
 move int_out+2,xcenter1
 move int_out+4,ycenter1
 move int_out+6,wcenter1
 move int_out+8,hcenter1

 form_center adr_form4
 move int_out+2,xcenter2
 move int_out+4,ycenter2
 move int_out+6,wcenter2
 move int_out+8,hcenter2

 form_center adr_form5
 move int_out+2,xcenter3
 move int_out+4,ycenter3
 move int_out+6,wcenter3
 move int_out+8,hcenter3

 form_center adr_instrum
 move int_out+2,xcenter_instrum
 move int_out+4,ycenter_instrum
 move int_out+6,wcenter_instrum
 move int_out+8,hcenter_instrum

 form_center adr_pitch
 move int_out+2,xcenter_pitch
 move int_out+4,ycenter_pitch
 move int_out+6,wcenter_pitch
 move int_out+8,hcenter_pitch

 form_center adr_midi
 move int_out+2,xcenter_midi
 move int_out+4,ycenter_midi
 move int_out+6,wcenter_midi
 move int_out+8,hcenter_midi

 form_center adr_speed
 move int_out+2,xcenter_speed
 move int_out+4,ycenter_speed
 move int_out+6,wcenter_speed
 move int_out+8,hcenter_speed

 form_center adr_pattern
 move int_out+2,xcenter_pattern
 move int_out+4,ycenter_pattern
 move int_out+6,wcenter_pattern
 move int_out+8,hcenter_pattern

 form_center adr_midi_rec
 move int_out+2,xcenter_midi_rec
 move int_out+4,ycenter_midi_rec
 move int_out+6,wcenter_midi_rec
 move int_out+8,hcenter_midi_rec

 form_center adr_first_loading
 move int_out+2,xcenter_first_loading
 move int_out+4,ycenter_first_loading
 move int_out+6,wcenter_first_loading
 move int_out+8,hcenter_first_loading

 form_center adr_saving
 move int_out+2,xcenter_saving
 move int_out+4,ycenter_saving
 move int_out+6,wcenter_saving
 move int_out+8,hcenter_saving

 form_center adr_saving_mod
 move int_out+2,xcenter_saving_mod
 move int_out+4,ycenter_saving_mod
 move int_out+6,wcenter_saving_mod
 move int_out+8,hcenter_saving_mod
 
 form_alert #1,#presente

 jsr utilitaire

fin_tout_court
 pea restore
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
 rts

instore
 move.b $484.w,s_484
 move.b #%0010,$484.w
 movem.l $ffff8240.w,d0-d7
 movem.l d0-a7,s_color
 move.l #$7770007,$ffff8240.w
 move.l #$0700000,$ffff8244.w
; move.l usp,a0
; move.l a0,s_usp
; lea usp_pile,a0
; move.l a0,usp
 rts
 
restore
 movem.l s_color,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.b s_484,$484.w
; move.l s_usp,a0
; move.l a0,usp
 rts
 


**********************************************************************
***************              *****************************************
***************   utilitaire *****************************************
***************              *****************************************
**********************************************************************
utilitaire
 lea path+1,a0
 move.b #":",(a0)+
 move.b #"\",(a0)+
 move.b #"*",(a0)+
 move.b #".",(a0)+


boucle
* init pour pattern rec
 clr pos_rec_start
 clr pos_rec_end
 lea pos,a0
 move #15000-1,d0
 moveq #0,d1
.cle_pos
 move d1,(a0)+
 addq #1,d1
 dbra d0,.cle_pos
* init des noms des instruments !
 lea name_instruments,a0
 move #256-1,d0
.clearname_instruments
 rept 5
 move.l #"____",(a0)+
 endr
 move #"__",(a0)+
 dbra d0,.clearname_instruments
 
* init la table pitch split
 lea table_pitch_split,a0
 move #(128*4)-1,d0
.eff_pitch
 move.l #-1,(a0)+
 dbra d0,.eff_pitch
* init la table des track par defaut pour le pitch split
 lea def_track,a0
 rept 4
 move.b #1,(a0)+
 move.b #2,(a0)+
 move.b #3,(a0)+
 move.b #4,(a0)+
 endr
 lea def_note,a0
 moveq #15,d0
.ec_note
 move.b #$30,(a0)+
 dbra d0,.ec_note
 lea def_note_off,a0
 moveq #15,d0
.ec_note_off
 move.b #1,(a0)+
 dbra d0,.ec_note_off
  
 bsr eff_ecran
 clr auto?

 form_alert #2,#opt0
 move int_out,d0
 cmp #1,d0
 beq fin_nana
 move d0,type_fichier

 lea path+1,a0
 move.b #":",(a0)+
 move.b #"\",(a0)+
 move.b #"*",(a0)+
 move.b #".",(a0)+

 lea type,a1
 cmp #2,type_fichier
 bne.s .c_bien_mod
 addq.l #4,a1
.c_bien_mod
 rept 3
 move.b (a1)+,(a0)+
 endr
 clr.b (a0)+
 clr.b sourcename

 fsel_input #path,#sourcename
 tst int_out+2
 beq boucle
 bsr eff_ecran
 bsr clean_path
* a0 :path
* a1 :name
 lea path,a0
 lea sourcename,a1
 bsr open
 tst d0
 beq.s .no_probleme
 form_alert #1,#pas_file
 bra boucle
.no_probleme  


**** ok ici on se separe celon le type du fichier a loader
 cmp #2,type_fichier
 beq .pas_low_load
* lit un .low
 move.l dest,a1
 moveq #4,d1
 bsr read
 move.l dest,a1
 cmp.l #"OLLH",(a1)
 beq.s .ko_low
 bsr close
 form_alert #1,#pas_fichier_low
 bra boucle
.ko_low
 move.l #"OLLH",type_mod

 lea vitesse,a1          * vitesse par defaut
 moveq #2,d1
 bsr read
 lea musicname,a1       * nom de la musique
 moveq #20,d1
 bsr read
 lea nb_in,a1           * nb_in
 moveq #2,d1
 bsr read
 lea nb_pos,a1          * nb_pos
 moveq #2,d1
 bsr read
 lea pos_restart,a1     * pos_restart
 moveq #2,d1
 bsr read
 lea nb_pat,a1          * nb_pat
 moveq #2,d1
 bsr read
********* affich tt ce ki est neccessaire
 move.l adr_first_loading,a2
 lea tabc(pc),a3
 move.l 12+fmusname*24(a2),a0
 addq.l #7,a0
 lea musicname,a1
 moveq #19,d0
.rut1
 move.b (a1)+,(a0)+
 dbra d0,.rut1 
 move nb_in,d7
 move.l 12+finstrument*24(a2),a0
 lea 21(a0),a0
 dtakea
 move nb_pos,d7
 move.l 12+fposition*24(a2),a0
 lea 19(a0),a0
 dtakea
 move pos_restart,d7
 move.l 12+frestart*24(a2),a0
 lea 20-10(a0),a0
 dtakea
 move nb_pat,d7
 move.l 12+fpattern*24(a2),a0
 lea 18(a0),a0
 dtakea
 move vitesse,d7
 move.l 12+fspeed*24(a2),a0
 lea 17(a0),a0
 dtakea1

 form_dial #1,#0,#0,#0,#0,xcenter_first_loading,ycenter_first_loading,wcenter_first_loading,hcenter_first_loading
 objc_draw adr_first_loading,#0,#4,xcenter_first_loading,ycenter_first_loading,wcenter_first_loading,hcenter_first_loading
 lea name_instruments,a1 * noms de tts les instruments ...
 moveq #0,d1
 move nb_in,d1
 mulu #22,d1
 bsr read
 lea tailein,a1          * informations sur tts les instruments
 moveq #0,d1
 move nb_in,d1
 lsl.l #4,d1
 bsr read
 
 lea pos,a1              * ttes les positions du module
 moveq #0,d1
 move nb_pos,d1
 lsl.l d1
 bsr read
 move.l dest,a1          * load tts les patterns du module...
 moveq #0,d1
 move nb_pat,d1
 lsl.l #8,d1
 lsl.l #2,d1
 move.l a1,a2
 adda.l d1,a2
*
 move.l a2,-(sp)
 bsr read
 move.l (sp)+,a1
* 
 bra fin_loading_partoch   *on rejoind l'autre a un endroit fini
.pas_low_load
 move #6,vitesse

* lit nom de la zik
 lea musicname,a1
 moveq #20,d1
* a1 :adr ou loader
* d1 : nd d'octet loader
 bsr read

 move.l adr_first_loading,a0
 move.l 12+24*fmusname(a0),a2
 addq.l #7,a2
 lea musicname,a1
 moveq #19,d0
.lop
 tst.b (a1)
 bne.s .oklop
 move.b #$20,(a1)
.oklop
 move.b (a1)+,(a2)+
 dbra d0,.lop 

* cherche en seek $438 si music ancienne ou non
 movem.l d0-a6,-(sp)
 move #$438,d1
 bsr seek
 lea type_mod,a1
 moveq #4,d1
 bsr read
 movem.l (sp)+,d0-a6

 moveq #15,d7
 cmp.l #"M.K.",type_mod
 bne.s .anc
 moveq #31,d7
.anc
 move d7,nb_in
*
 movem.l d0-a6,-(sp)
 move.l adr_first_loading,a0
 lea tabc(pc),a3
 move.l 12+finstrument*24(a0),a0
 lea 21(a0),a0
 dtakea
 form_dial #1,#0,#0,#0,#0,xcenter_first_loading,ycenter_first_loading,wcenter_first_loading,hcenter_first_loading
 objc_draw adr_first_loading,#0,#1,xcenter_first_loading,ycenter_first_loading,wcenter_first_loading,hcenter_first_loading
 movem.l (sp)+,d0-a6


 movem.l d0-a6,-(sp) 
 moveq #20,d1
 bsr seek
 movem.l (sp)+,d0-a6 
* 
* phase 2 : instruments infos
phase_2
 subq #1,d7

 lea tailein,a2
 lea name_instruments,a3
 moveq #0,d2    * init max size
******
 movem.l d0-a6,-(sp) 
 lea buff_boulo,a1
 moveq #0,d1
 move nb_in,d1
 mulu #30,d1
 bsr read
 movem.l (sp)+,d0-a6 
******
 lea buff_boulo,a0
.lopin
*
 move 22+6(a0),d0
 cmp #1,d0
 bne.s .bof
 clr 22+6(a0)
.bof
*
 moveq #0,d0         * lenght
 move 22(a0),d0
 add.l d0,d0
 cmp.l d2,d0
 ble.s .pas_plus
 move.l d0,d2
.pas_plus
* illegal
 move.l d0,lenghtins(a2)
*
 move 24(a0),volumein(a2)  * volume
*
 moveq #0,d0         * offset debut boucle
 move 26(a0),d0
 add.l d0,d0
 move.l d0,debbou(a2)
*
 moveq #0,d0         * offset fin boucle par arpport au precedant
 move 28(a0),d0
 add.l d0,d0
 bne.s .pas_boucle
 tst.l debbou(a2)
 beq.s .pas_boucle
.boucle
 move.l lenghtins(a2),d0
 sub.l debbou(a2),d0
 bra.s .suite_boucle
.pas_boucle
 cmp #4,d0
 bgt.s .suite_boucle
 clr.l debbou(a2)
 moveq #0,d0
.suite_boucle
 move.l d0,offset_finbou(a2)
*
 clr.w indic_surplus(a2)
*
x set 0
 rept 11
 move.w x(a0),(a3)+
x set x+2
 endr
 lea 16(a2),a2
 lea 30(a0),a0
 dbra d7,.lopin

phase
******
 movem.l d0-a6,-(sp) 
 lea buff_boulo,a1
 move.l #130,d1
 bsr read
 movem.l (sp)+,d0-a6 
******
 lea buff_boulo,a0
 moveq #0,d7
 move.b (a0)+,d7
 cmp #128,d7
 ble.s .ok_pos_lo
 move #128,d7
.ok_pos_lo
 tst d7
 bgt.s .ok_pos_hi
 moveq #1,d7
.ok_pos_hi 
 move d7,nb_pos

 moveq #0,d7
 move.b (a0)+,d7
 cmp #128,d7
 ble.s .ok_pos_restart_lo
 move #127,d7
.ok_pos_restart_lo
 tst d7
 bgt.s .ok_pos_restart_hi
 moveq #0,d7
.ok_pos_restart_hi 

 cmp nb_pos,d7
 ble.s .oka_y_restart_pos
 moveq #0,d7
.oka_y_restart_pos
 move d7,pos_restart

 move nb_pos,d7
 subq #1,d7
 moveq #0,d0
 moveq #0,d1
 move.b (a0),d1
 lea pos,a1
.loppos
 move.b (a0)+,d0
 cmp.b d1,d0
 ble.s .loppos1
 move d0,d1
.loppos1
 move d0,(a1)+
 dbra d7,.loppos
 move d1,nb_pat
 addq #1,nb_pat

******
 movem.l d0-a6,-(sp)
 cmp.l #"M.K.",type_mod
 bne.s .phase_4
 moveq #4,d1
 bsr rseek
.phase_4
* affiche n pattern et n partition
 move.l adr_first_loading,a2
 lea tabc(pc),a3
 move nb_pos,d7
 move.l 12+fposition*24(a2),a0
 lea 19(a0),a0
 dtakea
 move pos_restart,d7
 move.l 12+frestart*24(a2),a0
 lea 20(a0),a0
 dtakea
 move nb_pat,d7
 move.l 12+fpattern*24(a2),a0
 lea 18(a0),a0
 dtakea
 move vitesse,d7
 move.l 12+fspeed*24(a2),a0
 lea 17(a0),a0
 dtakea1
 objc_draw adr_first_loading,#fpat,#4,xcenter_first_loading,ycenter_first_loading,wcenter_first_loading,hcenter_first_loading
 movem.l (sp)+,d0-a6 
******

phase_4
 move.l dest,a1
.contenu_pattern
******
 movem.l d0-a6,-(sp)
 lea buff_boulo,a1
 move.l #256*4,d1
 bsr read
 movem.l (sp)+,d0-a6
******
 lea buff_boulo,a2
 move #255,d0

.contenu0
 move.b (a2),d2
 moveq #0,d3

 btst #4,d2
 beq.s .pas_plus_16
 moveq #16,d3
.pas_plus_16 

 move (a2)+,d2
 and #$3ff,d2
 lea table,a6
 moveq #0,d7
.chstable
 addq #1,d7
 cmp #39,d7
 beq.s .aille
 cmp (a6)+,d2
 bne.s .chstable
 bra.s .okaille
.aille
 bsr close
 form_alert #1,#pas_mod
 bra boucle
.okaille
 subq #1,D7

 move.b (a2),d2
 lsr.b #4,d2
 add.b d3,d2

 move.b (a2)+,d3
 move.b (a2)+,d6

 and #$f,d3
*d2 num inst
*d7 num note 
 move.b d3,(a1)+        * commande
 move.b d6,(a1)+        * parametre
 move.b d2,(a1)+        * n d'intrument
 move.b d7,(a1)+        * note
 dbra d0,.contenu0
 dbra d1,.contenu_pattern

fin_loading_partoch

*************** gestion midi (si oui)
 movem.l d1-a6,-(sp)
 form_alert #1,#mess_midi
 movem.l (sp)+,d1-a6
 cmp #1,d0
 beq.s .pas_midi
 movem.l d1-a6,-(sp)
 bsr midi_routs
 movem.l (sp)+,d1-a6
.pas_midi
******************* fin gestion midi

 movem.l d0-a6,-(sp)
 objc_draw adr_form1,#form1,#3,x_center,y_center,w_center,h_center
 movem.l (sp)+,d0-a6

 move nb_in,d7
 subq #1,d7
**
 moveq #1,d0
 lea tailein,a0
 lea name_instruments,a6
 move.l a1,adr_sample
.loop
 move.l a0,info_instrument
 move.l a1,reste
 move d0,num_ins
**
 move.l lenghtins(a0),d1

 tst.b indic_surplus(a0)
 beq.s .pas_plus
 add.l #fin_ech,d1
.pas_plus

 tst.l d1
 beq .loom4

 movem.l d0-a6,-(sp)
 move.l adr_form1,a2
 lea tabc,a3
* a6 adr name instrument
 move.l 12+24*nameint(a2),a1
 move.l (a1),a1
 lea name_instruments,a6
 moveq #0,d7
 move num_ins,d7
 subq #1,d7
 mulu #22,d7
 adda d7,a6
 moveq #21,d7
.rut
 move.b (a6)+,(a1)+
 dbra d7,.rut
 move d0,d7                   * numero instrument
 move.l 12+24*numeroin(a2),a1
 addq.l #3,a1
 dtakeb
 move.l 12+24*numeromax(a2),a1  * nb maximum d'intrument existant
 move nb_in,d7
 addq.l #5,a1
 dtakeb
 move volumein(a0),d7                   * volume par default
 move.l 12+24*volume_inf(a2),a1
 move.l (a1),a1
 dtakeb1
 move.l lenghtins(a0),d7      * lenght_instrument
 move.l 12+24*taillein(a2),a1
 addq.l #8,a1
 dtakec
 move.l debbou(a0),d7         * debut loop
 move.l 12+24*offsetin(a2),a1
 lea 14(a1),a1
 dtakec
 move.l offset_finbou(a0),d7    * lenght loop
 move.l 12+24*lenghtloo(a2),a1
 lea 15(a1),a1
 dtakec
 objc_draw adr_form1,#finfoin,#2,x_center,y_center,w_center,h_center
 movem.l (sp)+,d0-a6
.loom01
**
 move.l reste,a1
 movem.l d0-a6,-(sp) 
 bsr read
 movem.l (sp)+,d0-a6 
**
 tst.b indic_surplus(a0)
 bmi.s .lopoa
.lopo
 eor.b #$80,(a1)+
 subq.l #1,d1
 bne.s .lopo
.lopoa
**
 tst auto?
 bne .loom1
.loom
 movem.l d0-a6,-(sp)
 bsr gestion_instrument
 movem.l (sp)+,d0-a6

 movem.l d0-a6,-(sp)
* recupere le nom
 lea name_instruments,a1
 moveq #0,d0
 move num_ins,d0
 subq #1,d0
 mulu #22,d0
 adda d0,a1
 move.l adr_form1,a0
 move.l 12+24*nameint(a0),a0
 move.l (a0),a0
 recuptext 22
* recupere le volume par defaut
 move.l adr_form1,a1
 move.l 12+volume_inf*24(a1),a0
 move.l (a0),a0
 move.l info_instrument,a2
 addq.l #1+volumein,a2
 macsplit

 movem.l (sp)+,d0-a6
 tst retour
 bne .loom
.loom1
 
 tst.b indic_surplus(a0)
 bmi.s .pas_bou

* fin d'echantillon ...
 move.l reste,a1
 tst.l offset_finbou(a0)  * existe t'il une boucle ?
 bne.s .bou

 adda.l lenghtins(a0),a1
 tst.l lenghtins(a0)
 beq.s .loom4   * taille de l'echantillon = 0??
 move #fin_ech-1,d1
.loomcop
 move.b #$7f,(a1)+
 dbra d1,.loomcop
 bra.s .pas_bou

.bou
* attention je coupe la fin (a ne faire ke pour un point low)
 move.l debbou(a0),d1
 add.l offset_finbou(a0),d1
 move.l d1,lenghtins(a0)
* snif , voila , c fait ......


 move.l a1,a2
 adda.l debbou(a0),a2
 adda.l lenghtins(a0),a1
 move.l a2,a3
 move.l offset_finbou(a0),d2
 move #fin_ech-1,d1

.bou1
 move.b (a3)+,(a1)+
 subq.l #1,d2
 bne.s .gr_bou
 move.l offset_finbou(a0),d2
 move.l a2,a3
.gr_bou
 dbra d1,.bou1

.pas_bou
 st indic_surplus(a0)
 add.l #fin_ech,reste
.loom4
 addq #1,d0
 move.l reste,a1
 adda.l lenghtins(a0),a1
 lea 16(a0),a0
 lea 22(a6),a6
 dbra d7,.loop
 bra .loom6
*
 move nb_in,d1
 sub d0,d1
 beq .der_instrument * c'etait le dernier instrument a traiter
 subq #1,d1
 move d1,d2
 move.l a0,a2
 move.l a6,a3
.recop_sur
 rept 4
 move.l 16(a2),(a2)+   * info (tailein)
 endr 
 rept 5
 move.l 22(a3),(a3)+
 endr
 move 22(a3),(a3)+
 dbra d2,.recop_sur
.der_instrument
 subq #1,nb_in
 move.l reste,a1
 dbra d7,.loop

.loom6
 movem.l d0-a6,-(sp)     * fini on ferme le 1er fichier ....
 bsr close
 movem.l (sp)+,d0-a6


****** phase final , le saving ......
 sub.l dest,a1
 move.l a1,taile

 movem.l d1-a6,-(sp)
 lea sourcename,a0
 lea destname,a1
 rept 7
 move.w (a0)+,(a1)+
 endr
 form_alert #1,#opt2
 movem.l (sp)+,d1-a6

 cmp #2,d0
 beq boucle
* movem.l (sp)+,d0-a6
.save_boucle
 movem.l d0-a6,-(sp)
** apres inserer parametre de sauvegarde ici ! 
**** biensur en affichage ........
 bsr eff_ecran
* converti les infos
 move.l adr_saving,a2
 lea tabc(pc),a3
 move.l 12+smusname*24(a2),a0
 move.l (a0),a0
 lea musicname,a1
 moveq #19,d0
.rut1
 move.b (a1)+,(a0)+
 dbra d0,.rut1 
*
 move nb_in,d7
 move.l 12+sin*24(a2),a0
 lea 21(a0),a0
 dtakea
*
 move nb_pos,d7
 move.l 12+spos*24(a2),a0
 lea 19(a0),a0
 dtakea
*
 move pos_restart,d7
 move.l 12+srestart*24(a2),a0
 move.l (a0),a0
 dtakea
*
 move nb_pat,d7
 move.l 12+spat*24(a2),a0
 lea 18(a0),a0
 dtakea
*
 move vitesse,d7
 move.l 12+sspeed*24(a2),a0
 move.l (a0),a0
 dtakea1
*
 moveq #0,d7
 move nb_pat,d7
 lsl.l #8,d7
 lsl.l #2,d7
 move.l 12+24*slenpat(a2),a1
 lea 19+8(a1),a1
 bsr change_dec
*
 moveq #0,d7
 move nb_pos,d7
 lsl.l d7
 move.l 12+24*slenpos(a2),a1
 lea 20+8(a1),a1
 bsr change_dec
*
 moveq #0,d7
 lea tailein,a0
 move nb_in,d0
 subq #1,d0
.b_aj_ins
 add.l lenghtins(a0),d7
 lea 16(a0),a0
 dbra d0,.b_aj_ins
 move.l 12+24*slenin(a2),a1
 lea 18+8(a1),a1
 bsr change_dec
*
 move.l taile,d7 * pattern+sample instrument
 add.l #4+2+20+6,d7 * index+nom de la mus+nb_in+nb_pos_nb_pat
 moveq #0,d0
 move nb_in,d0
 mulu #22,d0
 add.l d0,d7
 moveq #0,d0
 move nb_in,d0
 lsl.l #4,d0
 add.l d0,d7
 moveq #0,d0
 move nb_pos,d0
 lsl.l d0
 add.l d0,d7
 move.l 12+24*stotallen(a2),a1
 lea 16+8(a1),a1
 bsr change_dec
 form_dial #1,#0,#0,#0,#0,xcenter_saving,ycenter_saving,wcenter_saving,hcenter_saving
 objc_draw adr_saving,#0,#4,xcenter_saving,ycenter_saving,wcenter_saving,hcenter_saving
* gestion du tout
 form_do adr_saving,#0 *saving

 movem.l d0-a6,-(sp)
 mulu #24,d0
 move.l adr_saving,a0
 bclr #0,11(a0,d0.w)
* recupere nom de la musique et vitesse par default
 move.l adr_saving,a2
 move.l 12+24*smusname(a2),a0
 move.l (a0),a0
 lea musicname,a1
 recuptext 20
 move.l 12+24*sspeed(a2),a0
 move.l (a0),a0
 lea vitesse+1,a2
 macsplit

 move.l adr_saving,a2
 move.l 12+24*srestart(a2),a0
 move.l (a0),a0
 lea pos_restart,a2
 macsplit2
 movem.l (sp)+,d0-a6

 cmp #cancel_save_mod,d0
 bne.s .pas_boucle
 movem.l (sp)+,d0-a6
 bra boucle
.pas_boucle
******
 lea type,a0
 move.l adr_saving,a2
 btst #0,11+24*bslow(a2)
 bne.s .loip
 addq.l #4,a0
.loip
 lea destname,a1
.loip1
 cmp.b #".",(a1)
 beq.s .loip2
 tst.b (a1)+
 bne.s .loip1
 move.b #".",-(a1)
.loip2
 addq.l #1,a1 
 move.b (a0)+,(a1)+
 move.b (a0)+,(a1)+
 move.b (a0)+,(a1)+
 clr.b (a1)+
 subq.l #3,a0
 lea path,a1
.bouli
 tst.b (a1)+
 bne.s .bouli
.boulia
 cmp.b #"\",-(a1)
 bne.s .boulia
 addq.l #1,a1
 move.b #"*",(a1)+
 move.b #".",(a1)+
 move.b (a0)+,(a1)+
 move.b (a0)+,(a1)+
 move.b (a0)+,(a1)+
 clr.b (a1)+
 fsel_input #path,#destname
 tst int_out+2
 beq .save_boucle
*
 bsr eff_ecran
 form_dial #1,#0,#0,#0,#0,xcenter_saving,ycenter_saving,wcenter_saving,hcenter_saving
 objc_draw adr_saving,#0,#3,xcenter_saving,ycenter_saving,wcenter_saving,hcenter_saving
 movem.l (sp)+,d0-a6

 bsr clean_path

* path : a0
* name : a1
 lea path,a0
 lea destname,a1
 bsr open_save
 tst d0
 bmi .problemesave
 
* reconnaissance du format ...
 move.l adr_saving,a2
 btst #0,11+24*bslow(a2)
 bne .save_low

* save obligatiorement .mod
 bsr eff_ecran
 objc_draw adr_saving_mod,#0,#3,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
 move #12,line_indic
 sf error?

* car pour l'instant pas d'autre options !!
 cmp #31,nb_in
 ble.s .ok_in_save
 lea trop_instrument,a0
 bsr insere
.ok_in_save


*** bon on fait comme si tt etait correct ...
 movem.l d0-a6,-(sp)
 lea operation1,a0
 bsr recopie
 objc_draw adr_saving_mod,#trace_operation,#2,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
 movem.l (sp)+,d0-a6

 lea musicname,a2       * sauve le nom de la musique
 move.l #20,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave


 movem.l d0-a6,-(sp)
 lea operation2,a0
 bsr recopie
 objc_draw adr_saving_mod,#trace_operation,#2,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
 movem.l (sp)+,d0-a6

 move nb_in,d7
 cmp #31,d7
 ble.s .ok_int
 moveq #31,d7
.ok_int
 moveq #0,d6
 lea name_instruments,a0  * noms de tts les instruments
 lea tailein,a1           * ttes les informations concernant tts les instruments
 subq #1,d7
.bou_save_instrume

 addq #1,d6
 lea buff_boulo,a2
 moveq #21,d0
.rec_om
 move.b (a0)+,(a2)+
 dbra d0,.rec_om
 move.l lenghtins(a1),d0

 cmp.l #65535,d0
 ble.s .ok_taille
 move.l a0,-(sp)
 move.l a1,-(sp)
 lea instrument_too_long,a0
 lea n_instrument_too_long,a1
 bsr insere_change
 move.l (sp)+,a1
 move.l (sp)+,a0
.ok_taille

 lsr.l d0
 move d0,(a2)+
 move volumein(a1),(a2)+
 move.l debbou(a1),d0
 lsr.l d0
 move d0,(a2)+
 move.l offset_finbou(a1),d0
 lsr.l d0
 tst d0
 bne .boule_exist
 move #1,d0 
.boule_exist
 move d0,(a2)+
 lea 16(a1),a1
 movem.l a0/a1/d7/d6,-(sp)
*
 lea buff_boulo,a2
 move.l #30,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave
*
 movem.l (sp)+,a0/a1/d7/d6
 dbra d7,.bou_save_instrume

 move nb_in,d0
 moveq #15,d1
 sf type_format
 cmp d1,d0
 ble.s .ancien_format
 moveq #31,d1
 st type_format
 cmp #31,d0
 ble.s .ancien_format
 moveq #31,d0
.ancien_format
 sub d0,d1
 beq .ok_rien_a_clearer
 subq #1,d1
 lea buff_boulo,a2
 moveq #13,d0
.clear_buf_boulo
 clr (a2)+
 dbra d0,.clear_buf_boulo
 move #1,(a2)+
.clearer
 move d1,-(sp)
*
 lea buff_boulo,a2
 move.l #30,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave
*
 move (sp)+,d1
 dbra d1,.clearer
.ok_rien_a_clearer


 movem.l d0-a6,-(sp)
 lea operation3,a0
 bsr recopie
 objc_draw adr_saving_mod,#trace_operation,#2,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
 movem.l (sp)+,d0-a6

* maintenant sauve les positions
 lea buff_boulo,a1
 lea pos,a0
 move nb_pos,d0
 cmp #128,d0
 ble.s .ok_posl
 moveq #128,d0
.ok_posl
 move.b d0,(a1)+

 move pos_restart,d0
 cmp #128,d0
 ble.s .ok_posl_restart
 moveq #128,d0
 movem.l d0-a6,-(sp)
 lea position_restart_too_big,a0
 bsr insere
 movem.l (sp)+,d0-a6
.ok_posl_restart
 move.b d0,(a1)+

 move.l a1,a2
 moveq #127,d7
.clear_pos
 clr.b (a2)+
 dbra d7,.clear_pos

 move nb_pos,d7
 beq.s .pas_clear_pos
 cmp #128,d7
 ble.s .ok_nb_pos
 move.l a0,-(sp)
 lea too_many_pos,a0
 bsr insere
 move.l (sp)+,a0
 moveq #128,d7
.ok_nb_pos
 subq #1,d7
.decode_pos
 move (a0)+,d0
 move.b d0,(a1)+
 dbra d7,.decode_pos
.pas_clear_pos
*
 lea buff_boulo,a2
 move.l #130,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave

 tst.b type_format
 beq .pas_nouveau_format
 lea type_mod,a2
 move.l #"M.K.",(a2)     * save indicateur de fichier .mod
 move.l #4,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave
.pas_nouveau_format


 movem.l d0-a6,-(sp)
 lea operation4,a0
 bsr recopie
 objc_draw adr_saving_mod,#trace_operation,#2,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
 movem.l (sp)+,d0-a6

* sauve maintenant les patterns
 move nb_pat,d7
 cmp #256,d7
 ble.s .ok_patl
 move #256,d7
 move.l a0,-(sp)
 lea too_many_pattern,a0
 bsr insere
 move.l (sp)+,a0
.ok_patl
 subq #1,d7
 move.l dest,a1
 moveq #0,d5
 sf indic_pat_error
.boucle_sauve_pattern
 lea buff_boulo,a2
 lea table,a3
 move #255,d6
.decode_patterns
 clr.l (a2)
* cmp.b #9,(a1)
* bne.s .okau
* illegal
*.okau
 move.b (a1)+,2(a2) * commande
 move.b (a1)+,3(a2) * parametre
 moveq #0,d0
 move.b (a1)+,d0    * numero d'instrument

 cmp #31,D0
 ble.s .ok_intl
 st indic_pat_error
 moveq #31,d0
.ok_intl

 cmp #16,d0
 blt.s .ok_num_inf
 sub #16,d0
 bset #4,(a2)
.ok_num_inf

 lsl #4,d0
 or.b d0,2(a2)
 moveq #0,d0
 move.b (a1)+,d0    * numero de note (0-39)
 add d0,d0
 move (a3,d0.w),d0
 and #$3ff,d0
 or d0,(a2)
 addq.l #4,a2
 dbra d6,.decode_patterns
*
 tst.b indic_pat_error
 beq.s .yeah_pat
 movem.l a0/a1/d6,-(sp)
 lea inst_sup_31_pat,a0
 lea ninst_sup_31_pat,a1
 move d5,d6
 bsr insere_change
 sf indic_pat_error
 movem.l (sp)+,a0/a1/d6
.yeah_pat
*
 addq #1,d5
 movem.l d7/a0-a6/d5,-(sp)
 lea buff_boulo,a2
 move.l #256*4,taile_write
 bsr write_save
 movem.l (sp)+,d7/a0-a6/d5
 cmp.l taile_write,d0
 bne .problemesave
*
 dbra d7,.boucle_sauve_pattern


 movem.l d0-a6,-(sp)
 lea operation5,a0
 bsr recopie
 objc_draw adr_saving_mod,#trace_operation,#2,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
 movem.l (sp)+,d0-a6

* maintenant sauve les instruments
 lea tailein,a0
 move.l adr_sample,a1
 move nb_in,d7
 cmp #31,d7
 ble.s .ok_intm
 moveq #31,d7
.ok_intm
 subq #1,d7
.sauve_instrument_mod
*
 movem.l d7/a0-a6,-(sp)
 move.l a1,a2
 move.l lenghtins(a0),d0
 and #$fffe,d0
 move.l d0,taile_write
 beq.s .fin_eora
 subq #1,d0
.eora
 eor.b #$80,(a1)+
 dbra d0,.eora
.fin_eora
 bsr write_save
 movem.l (sp)+,d7/a0-a6
 cmp.l taile_write,d0
 bne .problemesave
*
 add.l lenghtins(a0),a1
 add.l #fin_ech,a1
 lea 16(a0),a0
 dbra d7,.sauve_instrument_mod
 tst.b error?
 beq .fin_save
 bsr close_write
*
 form_alert #1,#file_not_good
*
 bra .save_boucle
.save_low
* a2 ou il faut sauve , taile_write ce k'il fo sauver

 lea type_mod,a2
 move.l #"OLLH",(a2)     * save indicateur de fichier .low
 move.l #4,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave

 lea vitesse,a2         * vitesse par defaut
 move.l #2,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave

 lea musicname,a2       * sauve le nom de la musique
 move.l #20,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave

 lea nb_in,a2            * nb_in
 move.l #2,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave

 lea nb_pos,a2            * nb_pos
 move.l #2,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave

 lea pos_restart,a2            * pos_restart
 move.l #2,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave

 lea nb_pat,a2            * nb_pat
 move.l #2,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne .problemesave

 lea name_instruments,a2  * noms de tts les instruments
 moveq #0,d1
 move nb_in,d1
 mulu #22,d1
 move.l d1,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne.s .problemesave

 lea tailein,a2           * ttes les informations concernant tts les instruments
 moveq #0,d1
 move nb_in,d1
 lsl.l #4,d1
 move.l d1,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne.s .problemesave

 lea pos,a2               * sauve ttes les positions du module
 moveq #0,d1
 move nb_pos,d1
 lsl.l d1
 move.l d1,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne.s .problemesave
  
 move.l dest,a2           * sauve les patterns ainsi ke les sample des instruments
 move.l taile,taile_write
 bsr write_save
 cmp.l taile_write,d0
 bne.s .problemesave

.fin_save
 bsr close_write
 bra boucle

.problemesave
 form_alert #1,#merde_kan_sauve
 bsr close_write
 bra .save_boucle
fin_nana
 rts
 
 
 *************************************************************
 *************  routine anexe !!! ****************************
 *************************************************************

change_dec
 movem.l d0-a6,-(sp)
 move.l d7,d0
 moveq #7,d7
.lop
 move.l d0,d1
 divu #10,d1
 moveq #0,d0
 move d1,d0
 swap d1
 move.b .tabc(pc,d1.w),-(a1)
 dbra d7,.lop
 movem.l (sp)+,d0-a6
 rts
.tabc dc.b "0123456789"




gestion_instrument
;
 bsr write
;
 movem.l d0-a6,-(sp)

 form_do adr_form1,#0 *form1
 
 move int_out,obj
 movem.l (sp)+,d0-a6

* on cleen le retour
 clr retour
;
********************* ici on gere toutes les options **********
 movem.l d0-a6,-(sp)
 move obj,d0
 st auto?
 cmp #end_instr,d0
 beq .fin_options
 clr auto?
 cmp #next_instr,d0
 beq .fin_options
 st retour
* bien ici ttes les options
 cmp #hear,d0
 bne .pas_hear

*
 form_dial #1,#0,#0,#0,#0,xcenter0,ycenter0,wcenter0,hcenter0
*
 objc_draw adr_form2,#0,#2,xcenter0,ycenter0,wcenter0,hcenter0
*
 pea replay
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
*
*
 form_dial #2,#0,#0,#0,#0,xcenter0,ycenter0,wcenter0,hcenter0
*

 bra .fin_options
.pas_hear
 cmp #filter,d0
 bne .pas_filter
 movem.l d0-a6,-(sp)
*
 form_dial #1,#0,#0,#0,#0,xcenter1,ycenter1,wcenter1,hcenter1
*
 objc_draw adr_form3,#0,#2,xcenter1,ycenter1,wcenter1,hcenter1
*
 movem.l (sp)+,d0-a6

 moveq #0,d0
 move.l (a0),d0
 subq #3,d0
 addq.l #2,a1
.filtre
* formule : filtre passe-bas de Tchebychev d'ondulation en bande pass‚e de 1dB
*
* k_b=[1.103*k(a1)+(0.1747521275*(fe/fc)+0.05066059182*(fe^2/fc^2)*k-1(a1)-0.02533029591*(fe^2/fc^2)*k-2(a1)]
*
* k(a1)=1/(1.103+0.1747521275*(fe/fc)+0.02533029591*(fe^2/fc^2))*k_b
*
* Autres filtres : Butterworth, Legendre, Lagrange, Hermite 
*
* fe : fr‚quence d'‚chantillonnage ; fc : fr‚quence de coupure (<fe/2)
*
*  

* fe^2/fc^2  	
* OPERATION DECIMAL , 9 DECIMAL :

addc macro  *d0,d1 + d2,d3
 move.l d0,-(sp)
 move.l d1,-(sp)
 add.l d0,d2
 move.l #max,d0
 sub.l d2,d0
 add.l d0,d3
 cmp.l #max,d3
 ble.s .\@
 sub.l #max,d3
 addq.l #1,d2
.\@
 move.l (sp)+,d1
 move.l (sp)+,d0
 endm

subc macro  *d2,d3 - d0,d1
 move.l d0,-(sp)
 move.l d1,-(sp)
 sub.l d0,d2
 move.l #max,d0
 sub.l d2,d0
 sub.l d0,d3
 bpl.s .\@
 add.l #max,d3
 subq.l #1,d2
.\@
 move.l (sp)+,d1
 move.l (sp)+,d0
 endm

mulc macro  *d0,d1*d2,d3
 movem.l d0/d1/d4/d5,-(sp)
 move.l #max,d4
 sub.l d1,d4
 move.l d4,d1
 move.l #max,d4
 sub.l d3,d4
 move.l d4,d3
*
 * a,b*c,d = a*d + c*b + a*c + b*d = a*(d,c) + d*(c,b)          

***********************
 movem.l d0-d3,-(sp)
;;; = a*(d,c)		
 move.l d0,d4
 move.l d2,d0
 move.l d3,d1
 bne.s .\@
 moveq #0,d2
 moveq #0,d3
 bra.s .\@@
.\@
* 
.\@@@
 addc
 subq.l #1,d4
 bne.s .\@@@

.\@@
 movem.l (sp)+,d0-d3

 movem.l d2-d3,-(sp)
**********************
; phase 2 : d*(c,b)
 move.l d3,d0
 move.l d1,d3
; 0,d0*(d2,d3) ==> (d0*d2)/10^9+(d0*d3)/10^18

;(d0*d2)/10^9
 moveq #0,d4
.\@@@@ 
 add.l d0,d3
 bcs .\@@@@@
 addq.l #1,d4
.\@@@@@
 subq.l #1,d1
 bne.s .\@@@@
 
 
* final 
 movem.l (sp)+,d0-d1
 addc

 movem.l (sp)+,d0/d1/d4/d5
 endm





 mulc 
 dbra d0,.filtre
*
 movem.l d0-a6,-(sp)
 form_dial #2,#0,#0,#0,#0,xcenter1,ycenter1,wcenter1,hcenter1
 movem.l (sp)+,d0-a6
 bra .fin_options
.pas_filter

 cmp #sam,d0
 bne .pas_sample
 movem.l d0-a6,-(sp)
 form_dial #1,#0,#0,#0,#0,xcenter3,ycenter3,wcenter3,hcenter3
 objc_draw adr_form5,#0,#3,xcenter3,ycenter3,wcenter3,hcenter3
 form_do adr_form5,#0 *form5
*
 pea digit
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
*
 form_dial #2,#0,#0,#0,#0,xcenter3,ycenter3,wcenter3,hcenter3
 movem.l (sp)+,d0-a6
 bra .fin_options
.pas_sample

 cmp #setfreq,d0
 bne .set_freq
 movem.l d0-a6,-(sp)
 form_dial #1,#0,#0,#0,#0,xcenter2,ycenter2,wcenter2,hcenter2
 objc_draw adr_form4,#0,#3,xcenter2,ycenter2,wcenter2,hcenter2
 form_do adr_form4,#0 *form4
*
 move int_out,d0
 move.l adr_form4,a0
 move frequence_choisi,d4
 mulu #24,d4
 bclr #0,11(a0,d4.l)
 move d0,d4 
 move d4,frequence_choisi
 mulu #24,d4
 bset #0,11(a0,d4.l)
 lea frequence,a0
 lea frequence1,a1
.loop
 move.l (a1)+,d2
 move.l (a1)+,d3
 move.l (a0)+,d1
 cmp d0,d1
 bne.s .loop
 swap d1
 move.b d1,gum
 move.l d2,frequ1       * ca c debile pour l'instant ,
 move.l d3,frequ2       *  voir filtre .........
*
 form_dial #2,#0,#0,#0,#0,xcenter2,ycenter2,wcenter2,hcenter2
 movem.l (sp)+,d0-a6

 bra .fin_options
.set_freq




.fin_options


 movem.l (sp)+,d0-a6
*********** on a fini de gerer toutes les options ...........
;
 movem.l d0-a6,-(sp)
 objc_change adr_form1,obj,x_center,y_center,w_center,h_center,#0,#1,#0
 dc.w $a00a
 move.l ecran,a0
 lea (200-128)*160(a0),a0
 move #(128*160/4)-1,d0
.lop
 clr.l (a0)+
 dbra d0,.lop
 dc.w $a009
 movem.l (sp)+,d0-a6
 rts

timer_bis
 move.l d0,-(sp)
 move.l a0,-(sp)
 tst oto
 bne .pas_sample
 move.l adr_replay,a0
 cmp.l fin_sample,a0
 bne.s .joue
 move #1,oto
 bra .pas_sample
.joue
 moveq #0,d0
 move.b $fffb0001,d0
 tst oto1
 beq.s .paav
 move.b d0,(a0)+ 
.paav
 move.l a0,adr_replay
 lsl #3,d0
 lea $ffff8800.w,a0
 move.l digi(pc,d0.w),(a0)
 move.l digi+4(pc,d0.w),d0
 movep.l d0,(a0)
.pas_sample
 move.l (sp)+,a0
 move.l (sp)+,d0
 rte

timer
 move.l d0,-(sp)
 move.l a0,-(sp)
 move.l adr_replay,a0
 cmp.l fin_sample_bis,a0
 bne.s .joue
 move.l debut_boucle,a0
 move.l fin_boucle,fin_sample_bis
.joue
 moveq #0,d0
 move.b (a0)+,d0
 move.l a0,adr_replay
 lsl #3,d0
 lea $ffff8800.w,a0
 move.l digi(pc,d0.w),(a0)
 move.l digi+4(pc,d0.w),d0
 movep.l d0,(a0)
 move.l (sp)+,a0
 move.l (sp)+,d0
 rte
digi
 incbin digital.bin
merdouille dc.w $8080

digit
 move.l reste,adr_replay
 move.l reste,d0
 add.l #65535,d0
 move.l d0,fin_sample
 
 move.l $134.w,s_134
;
 move #$2700,sr
 move.b $fffffa07.w,s_mfp
 move.b $fffffa09.w,s_mfp+1
 move.b $fffffa19.w,s_mfp+2
 move.b $fffffa1f.w,s_mfp+3
 bset #5,$fffffa07.w
 bset #5,$fffffa13.w
 bclr #3,$fffffa17.w
 move.l #timer_bis,$134.w
 move.b #1,$fffffa19.w
 move.b gum,$fffffa1f.w

 lea $ffff8800.w,a0
 move.l #00000000,(a0)
 move.l #01000000,(a0)
 move.l #02000000,(a0)
 move.l #03000000,(a0)
 move.l #04000000,(a0)
 move.l #05000000,(a0)
 move.l #06000000,(a0)
 move.b #7,(a0)
 move.b 2(a0),s_ym
 move.b #$ff,2(a0)
 clr oto
 clr oto1
 move #$2300,sr
;
.loop
 move #7,-(sp)
 trap #1
 addq.l #2,sp
 cmp.b #" ",d0
 beq.s .sui
 cmp.b #"S",d0
 beq.s .ok
 cmp.b #"s",d0
 bne.s .loop
.ok
 st oto1
 move #7,-(sp)
 trap #1
 addq.l #2,sp
 move.l info_instrument,a0
 move.l adr_replay,d0
 sub.l reste,d0
 move.l d0,(a0)
 clr.l 4+2(a0)
 clr.l 4+2+4(a0)

;
.sui
 move #$2700,sr
 move.b s_mfp,$fffffa07.w
 move.b s_mfp+1,$fffffa13.w
 move.b s_mfp+2,$fffffa19.w
 move.b s_mfp+3,$fffffa1f.w
 move.l s_134,$134.w
 lea $ffff8800.w,a0
 move.b #7,(a0)
 move.b s_ym,2(a0)

 move #$2300,sr
*
 rts

replay
 move.l info_instrument,a0
 move.l reste,debut_sample
 move.l reste,adr_replay
 move.l reste,debut_boucle

 move.l (a0),d0
 add.l reste,d0
 move.l d0,fin_sample 
 move.l d0,fin_sample_bis

 move.l 4+2(a0),d0
 add.l d0,debut_boucle
 move.l debut_boucle,fin_boucle

 move.l 4+2+4(a0),d0
 add.l d0,fin_boucle
 move.l debut_boucle,d0
 cmp.l fin_boucle,d0
 bne.s .okli
 move.l #merdouille,debut_boucle
 move.l #merdouille+2,fin_boucle
.okli
 move.l $134.w,s_134
;
 move #$2700,sr
 move.b $fffffa07.w,s_mfp
 move.b $fffffa09.w,s_mfp+1
 move.b $fffffa19.w,s_mfp+2
 move.b $fffffa1f.w,s_mfp+3
 bset #5,$fffffa07.w
 bset #5,$fffffa13.w
 bclr #3,$fffffa17.w
 move.l #timer,$134.w
 move.b #1,$fffffa19.w
 move.b gum,$fffffa1f.w

 lea $ffff8800.w,a0
 move.l #00000000,(a0)
 move.l #01000000,(a0)
 move.l #02000000,(a0)
 move.l #03000000,(a0)
 move.l #04000000,(a0)
 move.l #05000000,(a0)
 move.l #06000000,(a0)
 move.b #7,(a0)
 move.b 2(a0),s_ym
 move.b #$ff,2(a0)

 move #$2300,sr
;
.bou
 move #7,-(sp)
 trap #1
 addq.l #2,sp
 cmp.b #"R",d0
 beq.s .pquit
 cmp.b #"r",d0
 bne.s .quit
.pquit
 move.l debut_sample,adr_replay
 move.l fin_sample,fin_sample_bis
 bra.s .bou
.quit
;
 move #$2700,sr
 move.b s_mfp,$fffffa07.w
 move.b s_mfp+1,$fffffa13.w
 move.b s_mfp+2,$fffffa19.w
 move.b s_mfp+3,$fffffa1f.w
 move.l s_134,$134.w
 lea $ffff8800.w,a0
 move.b #7,(a0)
 move.b s_ym,2(a0)

 move #$2300,sr
 rts
 
  
write
 movem.l d0-a6,-(sp)
 dc.w $a00a
 movem.l (sp)+,d0-a6

 movem.l d0-a6,-(sp)
 move.l reste,a2
 move.l ecran,a1
 lea 160*(200-63)(a1),a1

 move.l a1,a4
 moveq #-1,d6
 move #160/4-1,d5
.lop
 move.l d6,(a4)+
 dbra d5,.lop

 moveq #0,d6
 move.l (a0),d6
 divu #640,d6
 move d6,div
 move #639,d6
 moveq #0,d5
 clr plot
trace
;
 move d5,d4
 lsr #4,d4
 lsl #2,d4
 lea 0(a1,d4.w),a3
 move d5,d4
 and #$f,d4
 moveq #15,d3
 sub d4,d3
*
 moveq #0,d2

 move.b (a2),d2
 eor.b #$80,d2 
 adda div,a2
 ext.w d2
 asr d2
 move d2,d0
 move plot,d4
 sub d2,d4
 move d2,plot
 move d4,d2

 mulu #160,d0
 lea 2(a3,d0.w),a3

 move.l a3,a4
 move d2,d0
 bpl.s .pos
 neg d0
.pos
 beq.s .pas_sub
 subq #1,d0
.pas_sub
*
 move (a4),d4
 bset d3,d4
 move d4,(a4)
*
 tst d2
 bmi.s .mi
 lea 160(a4),a4
 bra.s .ma
.mi
 lea -160(a4),a4
.ma
*
 dbra d0,.pas_sub
;
 addq #1,d5
 dbra d6,trace

 movem.l (sp)+,d0-a6

 movem.l d0-a6,-(sp)
 dc.w $a009
 movem.l (sp)+,d0-a6

 rts
;

choix
 moveq #3,d4
.choi
 lsl.l #8,d3
 rept 4
 lsl d1
 roxl d2
 endr
 and #$f,d2
 move.b .ch(pc,d2.w),d3
 dbra d4,.choi
 move.l d3,d1
 rts
.ch dc.b "0123456789ABCDEF"

print
 movem.l d0-a6,-(sp)
 dc.w $a00a
 movem.l (sp)+,d0-a6

 movem.l d0-a6,-(sp)
 move.l adr_car,a1
 move.l ecran,a2

* d0=x , d1=y
 mulu #160,d1
 move d0,d2
 and #$fffe,d0
 add d0,d0
 and #1,d2
 add d2,d0
 
.loop
 moveq #0,d7
 move.b (a0)+,d7
 beq.s .end
* options
 cmp #1,d7
 bne.s .pas_saut
 add #160*8,d1
 moveq #0,d0
 bra.s .loop
.pas_saut
 cmp #2,d7
 bne.s .pas_efface 
 moveq #0,d0
 move.l ecran,a3
 move.l a3,a2
 move #(32000/4)-1,d7
.eff
 clr.l (a3)+
 dbra d7,.eff
 bra.s .loop
.pas_efface
* fini options

* print
 move d1,d5
 add d0,d5
 moveq #7,d6
.print
 move.b (a1,d7.w),(a2,d5.w)
 move.b (a1,d7.w),2(a2,d5.w)
 add #256,d7
 add #160,d5
 dbra d6,.print
* ajout
 cmp #160-3,d0
 blt .aj_loop0
 moveq #0,d0
 add #160*8,d1
 bra .loop
.aj_loop0
 btst #0,d0
 beq.s .aj0  
 addq #2,d0
.aj0
 addq #1,d0
*
 bra.s .loop
.end
 movem.l (sp)+,d0-a6

 movem.l d0-a6,-(sp)
 dc.w $a009
 movem.l (sp)+,d0-a6
 rts

waitkey
 move #7,-(sp)
 trap #1
 addq.l #2,sp
 rts

clean_path
 lea path,a0
.lop
 tst.b (a0)+
 bne.s .lop
.lop1
 cmp.b #"\",-(a0)
 bne.s .lop1
 clr.b 1(a0)
 rts

open
* a0 :path
* a1 :name

 move.l a0,-(sp)

 moveq #0,d0
 move.b (a0),d0
 cmp.b #"a",d0
 blt.s .okli
 sub.b #32,d0
.okli
 sub.b #65,d0
 movem.l d0-a6,-(sp)
 move d0,-(sp)
 move #$e,-(sp)
 trap #1
 addq.l #4,sp
 movem.l (sp)+,d0-a6
 
.verifie
 tst.b (a0)+
 bne.s .verifie
.verifie1
 cmp.b #"\",-(a0)
 bne.s .verifie1
 clr.b 1(a0)
 move.l (sp)+,a0
 
 move.l a1,-(sp)
 move.l a0,-(sp)
 move #$3b,-(sp)
 trap #1
 addq.l #6,sp
 move.l (sp),a1

 move #0,-(sp)
 move.l a1,-(sp)
 move #$4e,-(sp)
 trap #1
 addq.l #8,sp

 move.l (sp)+,a1
 tst d0
 bne .pas_fichier
 move #0,-(sp)
 move.l a1,-(sp)
 move #$3d,-(sp)
 trap #1
 addq.l #8,sp
 tst d0
 bmi .pas_fichier
 move d0,handle_disk
 moveq #0,d0
.pas_fichier
 rts

seek
 move #0,-(sp) * relatif au debut du fichier
 move handle_disk,-(sp)
 move.l d1,-(sp)
 move #$42,-(sp)
 trap #1
 lea 10(sp),sp
 rts

rseek
 move #1,-(sp) * relatif a la position actuelle du pointeur ds le fichier
 move handle_disk,-(sp)
 move.l d1,-(sp)
 move #$42,-(sp)
 trap #1
 lea 10(sp),sp
 rts
  
read
 move.l a1,-(sp)
 move.l d1,-(sp)
 move handle_disk,-(sp)
 move #$3f,-(sp)
 trap #1
 lea 12(sp),sp
 rts

close
 move handle_disk,-(sp)
 move #$3e,-(sp)
 trap #1
 addq.l #4,sp  
 rts

save_as
 bsr open_save
 tst d0
 bmi .pas_save
 bsr write_save
 cmp.l taile_write,d0
 bne.s .pas_save
 bsr close_write
 moveq #0,d0
.pas_save
 rts
 
 
open_save
* path : a0
* name : a1
* lieu ou il faut sauver : a2
 move.l a0,-(sp)

 moveq #0,d0
 move.b (a0),d0
 cmp.b #"a",d0
 blt.s .okli
 sub.b #32,d0
.okli
 sub.b #65,d0
 movem.l d0-a6,-(sp)
 move d0,-(sp)
 move #$e,-(sp)
 trap #1
 addq.l #4,sp
 movem.l (sp)+,d0-a6

.verifie
 tst.b (a0)+
 bne.s .verifie
.verifie1
 cmp.b #"\",-(a0)
 bne.s .verifie1 
 clr.b 1(a0)
 move.l (sp)+,a0
 move.l a2,-(sp)
 move.l a1,-(sp)
 move.l a0,-(sp)
 move #$3b,-(sp)
 trap #1
 addq.l #6,sp
 move.l (sp)+,a1
 move #0,-(sp)
 move.l a1,-(sp)
 move #$3c,-(sp)
 trap #1
 addq.l #8,sp
 move.l (sp)+,a2
 move d0,handle_disk_write
 rts
 
write_save
 move.l a2,-(sp)
 move.l taile_write,-(sp)
 move handle_disk_write,-(sp)
 move #$40,-(sp)
 trap #1
 lea 12(sp),sp
 rts

close_write
 move handle_disk_write,-(sp)
 move #$3e,-(sp)
 trap #1
 addq.l #4,sp
 rts
 
eff_ecran
* eff l'ecran
 movem.l d0-a6,-(sp)
 dc.w $a00a
 pea disp
 move #9,-(sp)
 trap #1
 addq.l #6,sp
 dc.w $a009
 movem.l (sp)+,d0-a6
* suite
 rts

************************* gestion midi ************

midi_routs
 movem.l d0-a6,-(sp)
.b_midi
 bsr eff_ecran
 objc_draw adr_midi,#0,#4,xcenter_midi,ycenter_midi,wcenter_midi,hcenter_midi
 form_do adr_midi,#0 *midi
 move int_out,d0

******************* patch plit
 cmp #patchgo,d0
 bne .pas_pitch
 bsr eff_ecran
 clr canal_midi

.gere_pitch_split

* affichage du canal midi ...
 move.l adr_pitch,a0
 move.l chalmidi*24+12(a0),a0
 move canal_midi,d0
 lea tabc(pc),a3
 move.b (a3,d0.w),(a0)

* affichage du track par default
 lea def_track,a0
 add canal_midi,a0
 moveq #0,d0
 move.b (a0),d0
 move.l adr_pitch,a0
 move.l 12+deftrack*24(a0),a0
 move.b (a3,d0.w),1(a0)

* note off on ou off
 lea def_note_off,a0
 add canal_midi,a0
 move.b (a0),d0
 move.l adr_pitch,a0
 bclr #0,11+tnoteoff*24(a0)
 and #1,d0
 or.b d0,11+tnoteoff*24(a0)
 
 lea def_note,a2
 add canal_midi,a2
 move.l adr_pitch,a0
 move.l 12+mi_st*24(a0),a0
 addq.l #2,a0
 dtake
  
* affichage de toutes les informations midi necessaires ....
 lea table_pitch_split,a2
 move canal_midi,d0
 lsl #7,d0
 adda d0,a2

 lea table_note,a1
 moveq #nombre_de_notes_geres-1,d7
.boucle_car
 move.l adr_pitch,a0
 adda.w (a1)+,a0
 move.l (a0),a0
 move.l (a0),a0
* a0 a les 5 caracteres de suites ...
 take
 take
 take1
 dbra d7,.boucle_car
*
 objc_draw adr_pitch,#0,#4,xcenter_pitch,ycenter_pitch,wcenter_pitch,hcenter_pitch

.gere_pitch_split_on
 form_do adr_pitch,#0 *pitch
 move int_out,d0
*
 cmp #canalplu,d0
 bne.s .pas_aj
 cmp #15,canal_midi
 beq .gere_pitch_split
 bsr .recup_split
 addq #1,canal_midi
 bra .gere_pitch_split
.pas_aj

 cmp #canalmoi,d0
 bne.s .pas_sub
 tst canal_midi
 beq .gere_pitch_split
 bsr .recup_split
 subq #1,canal_midi
 bra .gere_pitch_split
.pas_sub

 cmp #exitsplit,d0
 bne .pas_fou
 bsr .recup_split
 move.l adr_pitch,a0
 bclr #0,exitsplit*24+10+1(a0)
 bra .b_midi
.pas_fou

 cmp #deftrackp,d0
 bne .pas_defp
 move.l adr_pitch,a0
 bclr #0,1+deftrackp*24+10(a0)
 lea def_track,a0
 adda canal_midi,a0
 cmp.b #4,(a0)
 beq .gere_pitch_split_def_trck
 addq.b #1,(a0)

* affichage du track par default
 lea def_track,a0
 adda canal_midi,a0
 moveq #0,d0
 move.b (a0),d0
 move.l adr_pitch,a0
 move.l 12+deftrack*24(a0),a0
 move.b (a3,d0.w),1(a0)
.gere_pitch_split_def_trck
 objc_draw adr_pitch,#af_def_track,#4,xcenter_pitch,ycenter_pitch,wcenter_pitch,hcenter_pitch
 bra .gere_pitch_split_on
.pas_defp

 cmp #deftrackm,d0
 bne .pas_defm
 move.l adr_pitch,a0
 bclr #0,1+deftrackm*24+10(a0)
 lea def_track,a0
 adda canal_midi,a0
 cmp.b #1,(a0)
 beq .gere_pitch_split_def_trck
 subq.b #1,(a0)

* affichage du track par default
 lea def_track,a0
 adda canal_midi,a0
 moveq #0,d0
 move.b (a0),d0
 move.l adr_pitch,a0
 move.l 12+deftrack*24(a0),a0
 move.b (a3,d0.w),1(a0)
 objc_draw adr_pitch,#af_def_track,#4,xcenter_pitch,ycenter_pitch,wcenter_pitch,hcenter_pitch
 bra .gere_pitch_split_on
.pas_defm
 
 cmp #mi_st_m,d0
 bne .pas_mi_st_m
 bclr #0,1+mi_st_m*24+10(a0)
 lea def_note,a0
 adda canal_midi,a0
 cmp.b #1,(a0)
 beq .gere_pitch_split_def_note
 subq.b #1,(a0)
 lea def_note,a2
 adda canal_midi,a2
 move.l adr_pitch,a0
 move.l 12+mi_st*24(a0),a0
 addq.l #2,a0
 dtake
.gere_pitch_split_def_note
 objc_draw adr_pitch,#af_def_note,#4,xcenter_pitch,ycenter_pitch,wcenter_pitch,hcenter_pitch
 bra .gere_pitch_split_on
.pas_mi_st_m
 
 cmp #mi_st_p,d0
 bne .pas_mi_st_p
 bclr #0,1+mi_st_p*24+10(a0)
 lea def_note,a0
 adda canal_midi,a0
 cmp.b #255-nombre_de_notes_geres,(a0)
 beq .gere_pitch_split_def_note
 addq.b #1,(a0)
 lea def_note,a2
 adda canal_midi,a2
 move.l adr_pitch,a0
 move.l 12+mi_st*24(a0),a0
 addq.l #2,a0
 dtake
 objc_draw adr_pitch,#af_def_note,#4,xcenter_pitch,ycenter_pitch,wcenter_pitch,hcenter_pitch
 bra .gere_pitch_split_on
.pas_mi_st_p

 cmp #loadpitch,d0
 bne .pas_loadpitch
 bsr .recup_split
 form_alert #1,#confirm_loadpitch
 cmp #1,d0
 beq .ouf_pas_load
* la on load le pitch .....
 lea path,a0
 lea path1,a1
.boipa
 tst.b (a0)
 beq.s .boipa1
 move.b (a0)+,(a1)+
 bra.s .boipa
.boipa1 
 cmp.b #"\",-(a1)
 bne.s .boipa1
 addq.l #1,a1
 move.b #"*",(a1)+
 move.b #".",(a1)+
 move.b #"P",(a1)+
 move.b #"I",(a1)+
 move.b #"T",(a1)+
 clr.b (a1)+
 clr.b namepitch
 fsel_input #path1,#namepitch
 bsr eff_ecran
 tst int_out+2
 beq .ouf_pas_load
* a0 :path
* a1 :name
 move handle_disk,-(sp)
 lea path1,a0
 lea namepitch,a1
 bsr open
 tst d0
 beq.s .no_probeleme_loadpitch
 form_alert #1,#probleme_loadpitch
 bra.s .probleme_loadpitch
.no_probeleme_loadpitch
* a1 :adr ou loader
* d1 : nd d'octet loader
 lea table_pitch_split,a1
 move.l #128*16,d1
 bsr read
 bsr close
.probleme_loadpitch
 move (sp)+,handle_disk
*
.ouf_pas_load

 move.l adr_pitch,a0
 bclr #0,1+loadpitch*24+10(a0)
 bra .gere_pitch_split
.pas_loadpitch

 cmp #savepitch,d0
 bne .pas_savepitch
 bsr .recup_split

 form_alert #1,#confirm_savepitch
 cmp #1,d0
 beq .ouf_pas_save
* la on save le pitch .....
 lea path,a0
 lea path1,a1
.boipaa
 tst.b (a0)
 beq.s .boipa1a
 move.b (a0)+,(a1)+
 bra.s .boipaa
.boipa1a
 cmp.b #"\",-(a1)
 bne.s .boipa1a
 addq.l #1,a1
 move.b #"*",(a1)+
 move.b #".",(a1)+
 move.b #"P",(a1)+
 move.b #"I",(a1)+
 move.b #"T",(a1)+
 clr.b (a1)+
 clr.b namepitch
 fsel_input #path1,#namepitch
 bsr eff_ecran
 tst int_out+2
 beq .ouf_pas_save

* path : a0
* name : a1
* lieu ou il faut sauver : a2
 move.l #128*16,taile_write
 lea path1,a0
 lea namepitch,a1
 lea table_pitch_split,a2
 move handle_disk,-(sp)
 bsr save_as
 move (sp)+,handle_disk
 tst d0
 beq.s .no_probleme_savepitch
 form_alert #1,#probleme_savepitch
.no_probleme_savepitch
*
.ouf_pas_save
 move.l adr_pitch,a0
 bclr #0,1+savepitch*24+10(a0)
 bra .gere_pitch_split
.pas_savepitch

 cmp #linstrum,d0
 bne.s .pas_l_instrum
 bsr .gere_instrum
 move.l adr_pitch,a0
 bclr #0,1+linstrum*24+10(a0)
 bsr eff_ecran
 bra .gere_pitch_split
.pas_l_instrum

 bra .gere_pitch_split

.recup_split
* recuperation de toutes les informations midi necessaires ....
 lea tabc,a3
 lea table_pitch_split,a2
 move canal_midi,d0
 lsl #7,d0
 adda d0,a2
 lea table_note,a1
 moveq #nombre_de_notes_geres-1,d7
.boucle_car1
 move.l adr_pitch,a0
 adda.w (a1)+,a0
 move.l (a0),a0
 move.l (a0),a0
* a0 a les 5 caracteres de suites ...
 moveq #0,d3 * au cas ou le resutats est zero....

 macsplit
 macsplit
 macsplit1
 cmp.b #4,-1(a2)
 ble.s .ok_track_only4
 move.b #4,-1(a2)
.ok_track_only4
 dbra d7,.boucle_car1
* recupere la gestion du note off
 move.l adr_pitch,a0
 move.b 11+24*tnoteoff(a0),d0
 and #1,d0
 lea def_note_off,a0
 add canal_midi,a0
 move.b d0,(a0)
 rts





.pas_pitch

******************* speed
 cmp #speedgo,d0
 bne .pas_speed
 bsr eff_ecran
 lea tabc(pc),a3
 move.l adr_speed,a0
 move.l 12+24*viteedit(a0),a0
 move.l (a0),a0
 lea vitesse+1,a2
 take 
 objc_draw adr_speed,#0,#4,xcenter_speed,ycenter_speed,wcenter_speed,hcenter_speed
 form_do adr_speed,#0 *speed
 move int_out,d0
 lea vitesse,a2
 clr.b (a2)+
 move.l adr_speed,a0
 move.l 12+24*viteedit(a0),a0
 move.l (a0),a0
 move vitesse,d7
 moveq #0,d3 * au cas ou le resutats est zero....
 macsplit
 tst.l d2
 bpl.s .arg_speed
 move d7,vitesse
.arg_speed
 move.l adr_speed,a0
 bclr #0,exitspeed*24+10+1(a0)
 bra .b_midi
.pas_speed

******************* pattern & positions
 cmp #pattrec,d0
 bne .pas_pattern
 bsr eff_ecran
*
 lea tabc,a3
 lea nb_pos,a2
 move.l adr_pattern,a0
 move.l 12+24*posmod(a0),a0
 dtake
 dtake
 lea nb_pat,a2
 move.l adr_pattern,a0
 move.l 12+24*patmod(a0),a0
 dtake
 dtake
* init
 clr pos_edit


.boucle_pattern
*
 move.l adr_pattern,a4
 move.l 12+24*posnumb(a4),a0
 move.l (a0),a0
 lea pos_edit,a2
 dtake
 dtake
 move.l 12+24*recposstart(a4),a0
 move.l (a0),a0
 lea pos_rec_start,a2
 dtake
 dtake
 move.l 12+24*recposend(a4),a0
 move.l (a0),a0
 lea pos_rec_end,a2
 dtake
 dtake
 move.l 12+24*patnum(a4),a0
 move.l (a0),a0
 lea pos,a2
 move pos_edit,d0
 add d0,d0
 adda d0,a2
 dtake
 dtake


 objc_draw adr_pattern,#0,#4,xcenter_pattern,ycenter_pattern,wcenter_pattern,hcenter_pattern
 form_do adr_pattern,#0 *pattern
 move int_out,d0


 cmp #exitpattern,d0
 bne.s .pas_fin_pattern
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*exitpattern(a0)
* na !
 bra .b_midi
.pas_fin_pattern

 cmp #posplus,d0
 bne.s .pas_pos_plus
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*posplus(a0)
 cmp #15000-1,pos_edit
 beq .boucle_pattern
 addq #1,pos_edit
 bra .boucle_pattern
.pas_pos_plus

 cmp #posmoin,d0
 bne.s .pas_pos_moin
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*posmoin(a0)
 tst pos_edit
 beq .boucle_pattern
 subq #1,pos_edit
 bra .boucle_pattern
.pas_pos_moin


 cmp #recposplus,d0
 bne.s .pas_recpos_plus
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*recposplus(a0)
 cmp #15000-1,pos_rec_start
 beq .boucle_pattern
 addq #1,pos_rec_start
 move pos_rec_start,d0
 cmp pos_rec_end,d0
 ble .boucle_pattern
 move d0,pos_rec_end
 bra .boucle_pattern
.pas_recpos_plus

 cmp #recposmoin,d0
 bne.s .pas_recpos_moin
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*recposmoin(a0)
 tst pos_rec_start
 beq .boucle_pattern
 subq #1,pos_rec_start
 bra .boucle_pattern
.pas_recpos_moin

 cmp #patmoin,d0
 bne.s .pas_sub_patpos
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*patmoin(a0)
 lea pos,a0
 move pos_edit,d0
 add d0,d0
 adda d0,a0
 tst (a0)
 ble.s .creve_sub_patpos
 subq #1,(a0)
.creve_sub_patpos
 bra .boucle_pattern
.pas_sub_patpos

 cmp #patplus,d0
 bne.s .pas_aj_patpos
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*patplus(a0)
 lea pos,a0
 move pos_edit,d0
 add d0,d0
 adda d0,a0
 cmp #32767,(a0)
 bge.s .creve_aj_patpos
 addq #1,(a0)
.creve_aj_patpos
 bra .boucle_pattern
.pas_aj_patpos

 cmp #clearpos,d0
 bne .pas_clear_pos
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*clearpos(a0)
 form_alert #1,#confirm_clear_pos
 cmp #1,d0
 beq .boucle_pattern
 move d0,d7
 lea pos,a0
 move #15000-1,d0
 moveq #0,d1
.cle_pos
 move d1,(a0)+
 addq #1,d1
 dbra d0,.cle_pos
 clr pos_rec_start
 clr pos_rec_end
 clr pos_edit
 cmp #3,d7
 bne .boucle_pattern
* recopie des positions deja existante ds le module .
 move nb_pos,d0
 beq .boucle_pattern
 subq #1,d0
 moveq #0,d1
 lea pos,a1
 move.l adr_pos,a0
.rec_pos_ex
 move.b (a0)+,d1
 move d1,(a1)+
 dbra d0,.rec_pos_ex
 bra .boucle_pattern
.pas_clear_pos 


 cmp #confsaisi,d0
 bne.s .pas_confsaisi
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*confsaisi(a0)
 bra .boucle_pattern
.pas_confsaisi

 cmp #recposendplus,d0
 bne.s .pas_recposend_plus
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*recposendplus(a0)
 cmp #15000-1,pos_rec_end
 beq .boucle_pattern
 addq #1,pos_rec_end
 bra .boucle_pattern
.pas_recposend_plus

 cmp #recposendmoin,d0
 bne.s .pas_recposend_moin
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*recposendmoin(a0)
 move pos_rec_end,d0
 tst d0
 beq .boucle_pattern
 cmp pos_rec_start,d0
 ble .boucle_pattern
 subq #1,pos_rec_end
 bra .boucle_pattern
.pas_recposend_moin

* load & save pattern .....................
 cmp #savepos,d0
 bne .pas_savepos
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*savepos(a0)
*
 form_alert #1,#confirm_save_pos
 cmp #1,d0
 beq .boucle_pattern
* save
 clr save_startpos
 move #15000-1,save_endpos
 cmp #3,d0
 bne.s .pas_save_define
 move pos_rec_start,save_startpos
 move pos_rec_end,save_endpos
 addq #1,save_endpos
.pas_save_define
 lea path,a0
 lea path1,a1
.boipab
 tst.b (a0)
 beq.s .boipa1b
 move.b (a0)+,(a1)+
 bra.s .boipab
.boipa1b
 cmp.b #"\",-(a1)
 bne.s .boipa1b
 addq.l #1,a1
 move.b #"*",(a1)+
 move.b #".",(a1)+
 move.b #"P",(a1)+
 move.b #"O",(a1)+
 move.b #"S",(a1)+
 clr.b (a1)+
 clr.b namepitch
 fsel_input #path1,#namepitch
 bsr eff_ecran
 tst int_out+2
 beq .boucle_pattern
* path : a0
* name : a1
* lieu ou il faut sauver : a2
 moveq #0,d1
 move save_endpos,d1 
 sub save_startpos,d1
 add d1,d1
 addq.l #4,d1
 move.l d1,taile_write
 lea path1,a0
 lea namepitch,a1
 lea save_startpos,a2
 moveq #0,d0
 move save_startpos,d0
 beq.s .ok_save_dep_debut
* oups ca etre coton ............. regulariser 
 move.l save_startpos,d2
 move.l d2,-(sp)
 add d0,d0
 adda d0,a2
 move.l a2,-(sp)
 move.l (a2),-(sp)
 move.l d2,(a2)
 bsr save_as
 move.l (sp)+,d1
 move.l (sp)+,a2
 move.l d1,(a2)
 move.l (sp)+,save_startpos
 bra.s .finsave_pos
.ok_save_dep_debut
 bsr save_as
.finsave_pos
 tst d0
 beq.s .no_probleme_savepos
 form_alert #1,#probleme_savepitch
.no_probleme_savepos
 bra .boucle_pattern
.pas_savepos

 cmp #loadpos,d0
 bne .pas_loadpos
 bsr .recup_donnee_pattern
 move.l adr_pattern,a0
 bclr #0,1+10+24*loadpos(a0)
*
 form_alert #1,#confirm_load_pos
 cmp #1,d0
 beq .boucle_pattern


* la on load le pitch .....
 lea path,a0
 lea path1,a1
.boipc
 tst.b (a0)
 beq.s .boipc1
 move.b (a0)+,(a1)+
 bra.s .boipc
.boipc1 
 cmp.b #"\",-(a1)
 bne.s .boipc1
 addq.l #1,a1
 move.b #"*",(a1)+
 move.b #".",(a1)+
 move.b #"P",(a1)+
 move.b #"O",(a1)+
 move.b #"S",(a1)+
 clr.b (a1)+
 clr.b namepitch
 fsel_input #path1,#namepitch
 bsr eff_ecran
 tst int_out+2
 beq .boucle_pattern
* a0 :path
* a1 :name
 move handle_disk,-(sp)
 lea path1,a0
 lea namepitch,a1
 bsr open
 tst d0
 beq.s .no_probeleme_loadpos
 form_alert #1,#probleme_loadpitch
 bra .boucle_pattern
.no_probeleme_loadpos
* a1 :adr ou loader
* d1 : nd d'octet loader
 lea save_startpos,a1
 moveq #4,d1
 bsr read
 moveq #0,d1
 move save_endpos,d1
 sub save_startpos,d1
 add d1,d1
 lea pos,a1
 cmp #15000,save_endpos
 beq .ok_fermepos
 movem.l a1/d1,-(sp)
 form_alert #1,#ou_load_pos
 movem.l (sp)+,a1/d1
 cmp #1,d0
 beq .ok_fermepos1
 cmp #3,d0
 beq.s .ok_fermepos0
* 2 saved
 moveq #0,d2
 move save_startpos,d2
 add d2,d2
 adda d2,a1
 move save_startpos,pos_rec_start
 move save_startpos,pos_edit
 move save_endpos,pos_rec_end
 bra .ok_fermepos1
.ok_fermepos0

 moveq #0,d2
 move pos_edit,d2
 add d2,d2
 adda d2,a1

 move pos_edit,d2
 add save_endpos,d2
 sub save_startpos,d2
 cmp #15000,d2
 ble.s .tout_go_pos
 movem.l d0-a6,-(sp)
 form_alert #1,#cut_file_pos
 movem.l (sp)+,d0-a6
 sub #15000,d2
 move save_endpos,d3
 sub save_startpos,d3
 sub d2,d3
 add d3,d3
 move d3,d1
 sub d2,save_endpos
.tout_go_pos

 move pos_edit,pos_rec_start
 move pos_edit,d0
 add save_endpos,d0
 sub save_startpos,d0
 move d0,pos_rec_end
.ok_fermepos1
* clear ??
 movem.l d1/a1,-(sp)
 form_alert #1,#clear_rest_pos
 movem.l (sp)+,d1/a1
 cmp #1,d0
 beq .ok_fermepos
 move d0,d7
 lea pos,a0
 move #15000-1,d0
 moveq #0,d3
.cle_posc
 move d3,(a0)+
 addq #1,d3
 dbra d0,.cle_posc
 cmp #3,d7
 bne .ok_fermepos
* recopie des positions deja existante ds le module .
 move nb_pos,d0
 beq .boucle_pattern
 subq #1,d0
 moveq #0,d2
 lea pos,a2
 move.l adr_pos,a0
.rec_pos_exc
 move.b (a0)+,d2
 move d2,(a2)+
 dbra d0,.rec_pos_exc
.ok_fermepos
 bsr read
 bsr close
 move (sp)+,handle_disk
*
 bra .boucle_pattern
.pas_loadpos

 bsr .recup_donnee_pattern
 bra .boucle_pattern



* rout exertne
.recup_donnee_pattern
 move.l adr_pattern,a4

 move.l 12+24*recposstart(a4),a0
 move.l (a0),a0
 lea pos_rec_start,a2
 move (a2),d7
 moveq #0,d3
 macsplit2
 cmp #-1,-(a2)
 bne.s .recup_pat1
 move d7,(a2)
.recup_pat1
 cmp #15000,(a2)
 ble.s .recup_pata1
 move #15000,(a2)
.recup_pata1
 move pos_rec_end,d0
 cmp (a2),d0
 bgt.s .recup_patb1
 move (a2),pos_rec_end
.recup_patb1

 move.l 12+24*patnum(a4),a0
 move.l (a0),a0
 lea pos,a2
 move pos_edit,d0
 add d0,d0
 adda d0,a2
 move (a2),d7
 moveq #0,d3
 macsplit2
 cmp #-1,-(a2)
 bne.s .recup_pat2
 move d7,(a2)
.recup_pat2
 cmp #32767,(a2)
 ble.s .recup_pata2
 move #32767,(a2)
.recup_pata2

 move.l 12+24*posnumb(a4),a0
 move.l (a0),a0
 lea pos_edit,a2
 move (a2),d7
 moveq #0,d3
 macsplit2 
 cmp #-1,-(a2)
 bne.s .recup_pat0
 move d7,(a2)
.recup_pat0
 cmp #15000-1,(a2)
 ble.s .recup_pata0
 move #15000-1,(a2)
.recup_pata0

 move.l 12+24*recposend(a4),a0
 move.l (a0),a0
 lea pos_rec_end,a2
 move (a2),d7
 moveq #0,d3
 macsplit2
 cmp #-1,-(a2)
 bne.s .recup_pat3
 move d7,(a2)
.recup_pat3
 cmp #15000-1,(a2)
 ble.s .recup_pata3
 move #15000-1,(a2)
.recup_pata3
 move pos_rec_start,d0
 cmp (a2),d0
 blt.s .recup_patb3
 move pos_rec_start,(a2)
.recup_patb3
 rts
 
 
 
 
.pas_pattern

******************* instruments names
 cmp #insna,d0
 bne .pas_instrum
 bsr .gere_instrum
 bra .b_midi

* routines annexes
.gere_instrum
 clr num_ins
 lea tabc(pc),a3
 move.l adr_instrum,a0
 move.l 12+24*nbim(a0),a0
 lea nb_in,a2
 clr.b (a2)+
 dtake 

 bsr eff_ecran

.boucle_namein
* aff nbcour
 lea tabc(pc),a3
 move.l adr_instrum,a0
 move.l 12+24*nbcour(a0),a0
 lea num_ins,a2
 clr.b (a2)+
 dtake
*
 lea name_instruments,a0
 move num_ins,d0
 mulu #22,d0
 adda d0,a0
 move.l adr_instrum,a1
 move.l 12+24*inedit(a1),a1
 move.l (a1),a1
 moveq #21,d0
.bnote
 move.b (a0)+,(a1)+
 dbra d0,.bnote
*
 objc_draw adr_instrum,#0,#4,xcenter_instrum,ycenter_instrum,wcenter_instrum,hcenter_instrum
 form_do adr_instrum,#0 *instrum
 move int_out,d0

 cmp #inplus,d0
 bne.s .pas_sub_instruments
 move.l adr_instrum,a0
 bclr #0,1+10+24*inplus(a0)
 bsr .recup_namein
 cmp #255,num_ins
 beq .boucle_namein
 addq #1,num_ins
 bra .boucle_namein
.pas_sub_instruments

 cmp #inmoin,d0
 bne.s .pas_add_instruments
 move.l adr_instrum,a0
 bclr #0,1+10+24*inmoin(a0)
 bsr .recup_namein
 tst num_ins
 beq .boucle_namein
 subq #1,num_ins
 bra .boucle_namein
.pas_add_instruments

 moveq #0,d1
 cmp #exitins1,d0
 beq.s .fin_namein
 cmp #exitins0,d0
 bne .pas_fin_namein
.fin_namein
 bsr .recup_namein
 move.l adr_instrum,a0
 bclr #0,1+10+24*exitins0(a0)
 bclr #0,1+10+24*exitins1(a0)
 moveq #-1,d1
.pas_fin_namein
 tst.l d1
 beq .boucle_namein
 rts

.recup_namein
 lea name_instruments,a1
 moveq #0,d0
 move num_ins,d0
 mulu #22,d0
 adda d0,a1
 move.l adr_instrum,a0
 move.l 12+24*inedit(a0),a0
 move.l (a0),a0
 recuptext 22
*
 rts




.pas_instrum

***********************  midi start or cancel
* prend les 3 bouttons pour les init

 move d0,-(sp)
 move.l adr_midi,a0
 move 10+velocity*24(a0),d0
 and #%1,d0
 move d0,velocityflag
 move 10+modulati*24(a0),d0
 and #%1,d0
 move d0,modulatiflag
 move 10+pitchben*24(a0),d0
 and #%1,d0
 move d0,pitchbenflag
 move (sp)+,d0
 
 cmp #reccanc,d0
 beq .fin

 cmp #recstart,d0
 bne .b_midi

.syncsrt 
*********** ici le midi
 move pos_rec_start,rec_start
 move pos_rec_end,rec_end
 clr offset_pat
 clr synchro_on_start
 move.l adr_midi_rec,a0
 bclr #0,11+24*midi_rec_sync(a0)
.b_midi_rec
 bsr eff_ecran
 objc_draw adr_midi_rec,#0,#4,xcenter_midi_rec,ycenter_midi_rec,wcenter_midi_rec,hcenter_midi_rec

 bsr ecrit_info_pattern_midi

 lea operation_wait,a0
 moveq #64,d0
 moveq #38+10,d1
 bsr print
 
 form_do adr_midi_rec,#0 *midi_rec

 cmp #exit_rec,d0
 beq .fin_rec

 cmp #start_midi_rec,d0
 bne .pas_start_midi_rec

* init midi
* arg test si debut ..........
 lea note_voie,a0
 bsr eff_voie
 lea volume_voie,a0
 bsr eff_voie
 lea instrument_voie,a0
 bsr eff_voie
 lea effect_voie,a0
 bsr eff_voie
 clr canal_receive

 move pos_rec_start,rec_start
 move pos_rec_end,rec_end
 clr offset_pat
* test si on doit attendre des infos en midi
 tst synchro_on_start
 bra ._synchro_midi
* bne ._synchro_midi
 st start_midi
 lea operation_start,a0
 moveq #64,d0
 moveq #38+10,d1
 bsr print
._synchro_midi
 bsr midi_take
 lea adr_midi_rec,a0
 bclr #0,11+24*start_midi_rec(a0)
 bra .b_midi_rec
.pas_start_midi_rec
 
 cmp #midi_rec_sync,d0
 bne.s .pas_rec_sync
 eor #1,synchro_on_start
 move synchro_on_start,d0
 move.l adr_midi_rec,a0
 bclr #0,11+24*midi_rec_sync(a0)
 or d0,10+24*midi_rec_sync(a0)
 bra .b_midi_rec
.pas_rec_sync

 bra .b_midi_rec
 
 
 
.fin_rec
 move.l adr_midi_rec,a0
 bclr #0,11+24*exit_rec(a0) 
 bra .b_midi
.fin
 bsr eff_ecran
 objc_draw adr_first_loading,#0,#3,xcenter_first_loading,ycenter_first_loading,wcenter_first_loading,hcenter_first_loading
 movem.l (sp)+,d0-a6
 rts

******************* midi
eff_voie
 rept 8
 clr.l (a0)+
 endr
 rts
 
ecrit_info_pattern_midi
 lea tabc(pc),a3
 lea ecrit_tout,a0
 lea rec_start,a2
 dtake
 dtake
 clr.b (a0)+
 lea ecrit_tout,a0
 moveq #56,d0
 moveq #39,d1
 bsr print

 lea pos,a2
 lea ecrit_tout,a0
 adda rec_start,a2
 adda rec_start,a2
 dtake
 dtake
 clr.b (a0)+
 lea ecrit_tout,a0
 moveq #56,d0
 moveq #39+10,d1
 bsr print

 lea offset_pat,a2
 lea ecrit_tout,a0
 dtake
 clr.b (a0)+
 lea ecrit_tout,a0
 moveq #56,d0
 moveq #39+20,d1
 bsr print
 rts

ecrit_info_midi_receive
* canal
 lea tabc(pc),a3
 lea ecrit_tout,a0
 lea canal_receive+1,a2
 dtake
 clr.b (a0)+
 lea ecrit_tout,a0
 moveq #20,d0
 moveq #47,d1
 bsr print

* note
 lea ecrit_tout,a0
 lea note_voie,a1
 move canal_receive,d0
 add d0,d0
 add d0,a1
 move (a1),d0
 
 lea def_note,a2
 add canal_receive,a2
 moveq #0,d7
 move.b (a2),d7
* addq #1,d7
 cmp d7,d0
 bge.s .superieure_depart_synthe
 moveq #-1,d0
.superieure_depart_synthe
 add #nombre_de_notes_geres,d7
 cmp d7,d0
 blt.s .note_inferieure_good
 moveq #-1,d0
.note_inferieure_good

 sub #nombre_de_notes_geres,d7
 sub d7,d0
 move.b d0,(a1)
 bmi .pas_ecrit_note_annule 
 lea write_note,a1
 muls #3,d0
 add d0,a1
 move.b (a1)+,(a0)+
 move.b (a1)+,(a0)+
 move.b (a1)+,(a0)+
 clr.b (a0)+
 lea ecrit_tout,a0
 moveq #29,d0
 moveq #47,d1
 bsr print


* volume
 lea tabc(pc),a3
 lea ecrit_tout,a0
 lea volume_voie,a2
 move canal_receive,d0
 add d0,d0
 add d0,a2
 dtake
 dtake
 clr.b (a0)+
 lea ecrit_tout,a0
 moveq #25,d0
 moveq #56,d1
 bsr print

* instrument
 lea tabc(pc),a3
 lea ecrit_tout,a0
 lea instrument_voie,a2
 move canal_receive,d0
 add d0,d0
 add d0,a2
 dtake
 dtake
 clr.b (a0)+
 lea ecrit_tout,a0
 moveq #25,d0
 moveq #57+8,d1
 bsr print

* effect
 lea effect_voie,a1
 lea table_effect,a0
 add canal_receive,a1
 moveq #0,d0
 move.b (a1),d0
 mulu #14,d0  * 13 caracteres + 0
 add d0,a0
 moveq #25-6,d0
 moveq #66+8,d1
 bsr print

.pas_ecrit_note_annule
 rts


n_70
 movem.l d0-a6,-(sp)
* tst cmpt_vbl
* bne .fcmpt_vbl
* move vitesse,cmpt_vbl  
* 
*.fcmpt_vbl
* subq #1,cmpt_vbl
* 

 movem.l (sp)+,d0-a6
 move.l s_70,-(sp)
 rts

n_118
 movem.l d0/a0/a1,-(sp)

 lea $fffffc00,a0
 btst #7,(a0)
 beq .midi_inter
 btst #5,(a0)
 bne .midi_inter
 btst #0,(a0)
 beq .midi_inter
 move.b 2(a0),d0
 lea buffer_clavier,a1
 add nb_octets_clavier,a1
 cmp #400,nb_octets_clavier
 beq.s .midi_inter
 addq #1,nb_octets_clavier
 move.b d0,(a1)
.midi_inter

 lea $fffffc04.w,a0
 btst #7,(a0)
 beq .f_118
* clavier
 btst #5,(a0)
 bne .f_118
 btst #0,(a0)
 beq .f_118
 move.b 2(a0),d0
 lea buffer_midi,a1
 add nb_octets_midi,a1
 cmp #400,nb_octets_midi
 beq.s .f_118
 addq #1,nb_octets_midi
 move.b d0,(a1)
.f_118
 movem.l (sp)+,a0/a1/d0
 rte

***************************************
midi_take
 pea .midi_take
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
 rts

.midi_take
 move sr,-(sp)
 move #$2700,sr
 move vitesse,cmpt_vbl
 move.l $70.w,s_70
 move.l $118.w,s_118
 move.b $fffffa07.w,s_mfp
 move.b $fffffa13.w,s_mfp+1
 move.b $fffffa19.w,s_mfp+2
 move.b $fffffa1f.w,s_mfp+3
 move.b $fffffa17.w,s_mfp+4
 move.b $fffffa09.w,s_mfp+5
 move.b $fffffa15.w,s_mfp+6
 bclr #3,$fffffa17.w
 move.l #n_70,$70.w
 move.l #n_118,$118.w
 clr.b $fffffa07.w
 move.b #%01000000,$fffffa09.w
 or.b #%01000000,$fffffa15.w
 move #$2300,sr
* JE CLEAR LE BUFFER MIDI
 clr nb_octets_midi    * facile non ?? hehehehehe
 clr nb_octets_clavier * facile non ?? hehehehehe

wait_midi

* debugging midi
* move #7,-(sp)
* trap #1
* addq.l #2,sp
* cmp.b #" ",d0
* beq .fin
;
* canal_receive , canal sur lekel on a recu la derniere information
* des k'on recoit une informations on a juste a faire :
* bsr ecrit_info_midi_receive * et ca imperime ttes les info
* sur la derniere voie sur lakellle a ete recu la derniere info ....






 bsr prend
 tst indic_shift
 bne .fin
*

 cmp.b #$fa,d0 *start
 bne.s .pas_start
 st start_midi
 lea operation_start,a0
 moveq #64,d0
 moveq #38+10,d1
 bsr print
* fodra penser a initialiser ici ttes les variables , gnarf , gnarf
 bra wait_midi
.pas_start

 cmp.b #$fb,d0 *continue
 bne.s .pas_continue
 st start_midi
 lea operation_continue,a0
 moveq #64,d0
 moveq #38+10,d1
 bsr print
 bra wait_midi
.pas_continue

 cmp.b #$fc,d0 *stop
 bne.s .pas_stop
 sf start_midi
 lea operation_stop,a0
 moveq #64,d0
 moveq #38+10,d1
 bsr print
 bra wait_midi
.pas_stop

* pour l'instant on va pa plus loin

 move d0,d2
 and #$f,d0    * canal midi
 move d0,canal_receive
 lsr #4,d2     * fonctions
 lea fonctions,a0
 and #$f,d2
 add d2,d2
 add d2,d2
 adda d2,a0
 move.l (a0),a0
 jsr (a0)

 bsr ecrit_info_midi_receive

 tst indic_shift
 beq wait_midi
.fin
 move #$2700,sr
 move.b s_mfp,$fffffa07.w
 move.b s_mfp+1,$fffffa13.w
 move.b s_mfp+2,$fffffa19.w
 move.b s_mfp+3,$fffffa1f.w
 move.b s_mfp+4,$fffffa17.w
 move.b s_mfp+5,$fffffa09.w
 move.b s_mfp+6,$fffffa15.w
 move.l s_118,$118.w
 move.l s_70,$70.w
 move (sp)+,sr
 rts

*********************** sous routines MIDI
 
prend
.wait_midi
* ici fodra tester le clavier
 tst nb_octets_clavier
 beq.s .pas_sorti
;
 lea buffer_clavier,a0
 subq #1,nb_octets_clavier
 bsr take_on_buffer
;
 cmp.b #$39,d0
 bne.s .pas_sorti
 st indic_shift
 bra.s .prend
.pas_sorti
* ici la midi , nananere.......
 tst nb_octets_midi * teste si nombre d'octets ds le buffer est de 0
 beq .wait_midi
;
 lea buffer_midi,a0
 subq #1,nb_octets_midi
 bsr take_on_buffer
;
 cmp.b #$fe,d0       * active sensign
 beq.s .wait_midi
 cmp.b #$f8,d0       * horloge
 beq.s .wait_midi
.prend
 rts

take_on_buffer
 moveq #0,d0
 move.b (a0),d0
 move d0,-(sp)
 move #398,d0
.take
 move.b 1(a0),(a0)+
 dbra d0,.take
 move (sp)+,d0
 rts

note_off  * 2 octets
 bsr prend * note
 tst indic_shift
 bne.s fnote_off
 move d0,-(sp)
 bsr prend * velocity
 move (sp)+,d0
note_off_2
 tst indic_shift
 bne.s fnote_off
 lea note_voie,a1
 add canal_receive,a1
 add canal_receive,a1
* addq #1,d0
 cmp (a1),d0
 bne fnote_off
 lea pedale_contrl,a0
 add canal_receive,a0
 add canal_receive,a0
 tst.b (a0)+
 beq.s fnote_off2
 st (a0)
 bra fnote_off
fnote_off2
 lea def_note_off,a0
 add canal_receive,a0
 tst.b (a0)
 beq fnote_off
 clr (a1)
fnote_off
 rts

note_on    * 2 octets
 bsr prend * note 
 tst indic_shift
 bne.s .fnote_on
 lea note_voie,a1
 add canal_receive,a1
 add canal_receive,a1
* addq #1,d0
 move d0,(a1)
 bsr prend * velocity
           * si velocity = 0 alors note_off
 tst d0
 bne.s .fnote_on0
 lea note_voie,a1
 add canal_receive,a1
 add canal_receive,a1
 move (a1),d0
 bra note_off_2
.fnote_on0
 tst velocityflag
 beq .fnote_on
 lea volume_voie,a1
 add canal_receive,a1
 add canal_receive,a1
 lsr d0
 move d0,(a1)
.fnote_on
 rts

control_change * 2 octets
* $40 $7f : pedale enfonce
* $40 $00 : pedale relache
* pedale : prolonge la duree de la derniere note sur son dernier canal midi 
* donc ne pas tenir compte du note off

* $01 $val , vibrato , $val/2

* $02 $val , vibrato , $val/2

* $07 $val , volume , $val/2

 bsr prend * numero 
 tst indic_shift
 bne .fcontrl
 cmp.b #$40,d0
 bne.s .pas_pedale
 bsr prend * valeur
 tst indic_shift
 bne.s .fcontrl
 tst d0
 beq .pedale_relache
* PEDALE ENFONCE 
 lea pedale_contrl,a0
 add canal_receive,a0
 add canal_receive,a0
 st (a0)
 bra .fcontrl
.pedale_relache 
 lea pedale_contrl,a0
 add canal_receive,a0
 add canal_receive,a0
 sf (a0)+
 tst.b (a0)
 beq .fcontrl
 sf (a0)
 lea note_voie,a1
 add canal_receive,a1
 add canal_receive,a1
 bra fnote_off2 
.pas_pedale
 
 cmp #$7,d0
 bne .pas_volume_set
 bsr prend * valeur
 tst indic_shift
 bne.s .fcontrl
 lea volume_voie,a1
 add canal_receive,a1
 add canal_receive,a1
 lsr d0
 move d0,(a1)
 bra .fcontrl
.pas_volume_set

.fcontrl
 rts
  
programm_change * 1 octets
* ne pas ne tenir compte juste avertir
 bsr prend * numero du programmm
 rts

pression * 1 octets
* $val vibrato , $val/2
 bsr prend * valeur de la pression
 rts

pitch_bend * 2 octets  
 bsr prend * octets de poid fort
 tst indic_shift
 bne.s .fpitch
 bsr prend * octets de poid faible
.fpitch
 rts

test_shift
 move #-1,-(sp)
 move #11,-(sp)
 trap #13
 addq.l #4,sp
 and #%11,d0
 clr indic_shift
 cmp #%11,d0
 bne.s .test
 move #3,indic_shift
.test
rts
 rts


insere
 st error?
 movem.l d0-a6,-(sp)
 moveq #1,d0
 cmp #12,line_indic
 bne.s .aj
 moveq #0,d0 
 lea info_saving_mod,a1
 move #(25*13)-1,d1
.scroll_info
 move #"  ",(a1)+
 dbra d1,.scroll_info
 clr line_indic
.aj
 add d0,line_indic

 lea info_saving_mod,a1
 move line_indic,d0
 mulu #50,d0
 add d0,a1
 moveq #49,d0
.rec_mess
 move.b (a0)+,(a1)+
 dbra d0,.rec_mess


 lea info_saving_mod,a2
 move.l adr_saving_mod,a0
 move.l 12+24*line1(a0),a1
 bsr .copie
 move.l 12+24*line2(a0),a1
 bsr .copie
 move.l 12+24*line3(a0),a1
 bsr .copie
 move.l 12+24*line4(a0),a1
 bsr .copie
 move.l 12+24*line5(a0),a1
 bsr .copie
 move.l 12+24*line6(a0),a1
 bsr .copie
 move.l 12+24*line7(a0),a1
 bsr .copie
 move.l 12+24*line8(a0),a1
 bsr .copie
 move.l 12+24*line9(a0),a1
 bsr .copie
 move.l 12+24*line10(a0),a1
 bsr .copie
 move.l 12+24*line11(a0),a1
 bsr .copie
 move.l 12+24*line12(a0),a1
 bsr .copie
 move.l 12+24*line13(a0),a1
 bsr .copie
 move line_indic,d0
 add d0,d0

 tst line_indic
 bne.s .pas_aff_indic
 objc_draw adr_saving_mod,#0,#3,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
.pas_aff_indic
 move line_indic,d0
 add d0,d0
 move .line_in(pc,d0.w),d0
 objc_draw adr_saving_mod,d0,#0,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
 movem.l (sp)+,d0-a6
 rts
.line_in
 dc.w line1,line2,line3,line4,line5,line6,line7,line8,line9,line10,line11,line12,line13
.copie
 moveq #49,d0
.bcopie
 move.b (a2)+,(a1)+
 dbra d0,.bcopie
 rts
 

insere_change
 st error?
 movem.l d0-a6,-(sp)
 lea tabc,a2
 move d6,d5
 and #$f,d5
 lsr #4,d6
 and #$f,d6
 move.b (a2,d6.w),(a1)+
 move.b (a2,d5.w),(a1)+

 moveq #1,d0
 cmp #12,line_indic
 bne.s .aj
 moveq #0,d0 
 lea info_saving_mod,a1
 move #(25*13)-1,d1
.scroll_info
 move #"  ",(a1)+
 dbra d1,.scroll_info
 clr line_indic
.aj
 add d0,line_indic

 lea info_saving_mod,a1
 move line_indic,d0
 mulu #50,d0
 add d0,a1
 moveq #49,d0
.rec_mess
 move.b (a0)+,(a1)+
 dbra d0,.rec_mess


 lea info_saving_mod,a2
 move.l adr_saving_mod,a0
 move.l 12+24*line1(a0),a1
 bsr .copie
 move.l 12+24*line2(a0),a1
 bsr .copie
 move.l 12+24*line3(a0),a1
 bsr .copie
 move.l 12+24*line4(a0),a1
 bsr .copie
 move.l 12+24*line5(a0),a1
 bsr .copie
 move.l 12+24*line6(a0),a1
 bsr .copie
 move.l 12+24*line7(a0),a1
 bsr .copie
 move.l 12+24*line8(a0),a1
 bsr .copie
 move.l 12+24*line9(a0),a1
 bsr .copie
 move.l 12+24*line10(a0),a1
 bsr .copie
 move.l 12+24*line11(a0),a1
 bsr .copie
 move.l 12+24*line12(a0),a1
 bsr .copie
 move.l 12+24*line13(a0),a1
 bsr .copie
 move line_indic,d0
 add d0,d0

 tst line_indic
 bne.s .pas_aff_indic
 objc_draw adr_saving_mod,#0,#3,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
.pas_aff_indic
 move line_indic,d0
 add d0,d0
 move .line_in(pc,d0.w),d0
 objc_draw adr_saving_mod,d0,#0,xcenter_saving_mod,ycenter_saving_mod,wcenter_saving_mod,hcenter_saving_mod
 movem.l (sp)+,d0-a6
 rts
.line_in
 dc.w line1,line2,line3,line4,line5,line6,line7,line8,line9,line10,line11,line12,line13
.copie
 moveq #49,d0
.bcopie
 move.b (a2)+,(a1)+
 dbra d0,.bcopie
 rts

recopie
 move.l adr_saving_mod,a1
 move.l 12+24*operation(a1),a1
 moveq #19,d0
.recopie
 move.b (a0)+,(a1)+
 dbra d0,.recopie
 rts
 
fonctions
 dc.l rts,rts,rts,rts,rts,rts,rts,rts
 dc.l note_off,note_on,rts,control_change,programm_change
 dc.l pression,pitch_bend

*** maintenant les datas



* section data
tabc dc.b "0123456789ABCDEF"
 even

disp
 dc.b 27,"f",27,"E",27,"b",1,0
 even

table
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
 dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
 dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
 dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
 dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000

commande
 dc.b 0    *0
 dc.b 1    *1
 dc.b 2    *2
 dc.b -1   *3
 dc.b -1   *4
 dc.b -1   *5
 dc.b -1   *6
 dc.b -1   *7
 dc.b -1   *8
 dc.b -1   *9
 dc.b 3    *a
 dc.b 4    *b
 dc.b 5    *c
 dc.b 6    *d
 dc.b -1   *e
 dc.b 7    *f


table_effect * normalement 16 effects
 * fodra mettre les noms des vraies commandes , merci !
 rept 16
 dc.b "EFFET........",0
 endr
 
 even
nom_rsc           dc.b "moulinex.rsc",0
 even 
modload             dc.b "[3][Loading MOD|"
musicname           dc.b "                    ][Ah Yeah]"
merde_kan_sauve     dc.b "[1][AArrrggg ,|Error on Saving !!|operation Aborted][Gasp.]",0
pas_file            dc.b "[1][This file isn't|on the disk][Arf...]",0
presente            dc.b "[1][Programme Moulinex|Code by MIT|½1991][~Ah Yeah~]",0
opt0                dc.b "[2][What do you want|do load ??][EXIT|.MOD|.LOW]",0
opt1                dc.b "[2][Which Operation ?][LOAD|NEW|EXIT]",0
pas_rsc             dc.b "[1][.rsc missing !!!|programm aborted][ok]",0
only_moyenne        dc.b "[1][This programm|only work in|middle resolution][Beurk.]",0
opt2                dc.b "[2][Do you want to|save this|module ???][YES|ABORD]",0
pas_mod             dc.b "[1][Not a good|module][ABORD]",0
pasloadmod          dc.b "[1][Sorry this fonction|don't work][Gasp.]",0
mess_midi           dc.b "[2][Edit and |transform pattern| with MIDI ??][NO...|OKAY!]",0
confirm_loadpitch   dc.b "[2][Do you want really|to load a|pitch split  ??][NO|YES]",0
confirm_savepitch   dc.b "[2][Do you want really|to save a|pitch split  ??][NO|YES]",0
probleme_loadpitch  dc.b "[1][The file isn't|on the disk !!][Arrgg..]",0
probleme_savepitch  dc.b "[1][Error on|saving file !|operation aborted][! OK !]",0
confirm_clear_pos   dc.b "[2][clear all |positions ??|and restore existing|positions'module ??][ NO |CLEAR|&RESTORE]",0
confirm_save_pos    dc.b "[2][What do you want |exactly to save ??|All or between |start & end pointeurs][ABORT|ALL|  POS ]",0
confirm_load_pos    dc.b "[2][Do you want really|to load this file|as positions ???][ NO ! | OK! ]",0
ou_load_pos         dc.b "[2][Do you want to load the|positions at first one ??|the saved positions ??|or the actual edit position ??][START|SAVED|ACTUAL]",0
clear_rest_pos      dc.b "[2][Do you want to clear |the rest of positions ??|and restore the current|module one ??][ NO | CLEAR |&RESTORE]",0
cut_file_pos        dc.b "[1][Arg , the file is too big| I must cut the end ...][ OKAY ]",0
pas_fichier_low     dc.b "[1][This isn't a|good .low file !!][ABORT]",0
file_not_good       dc.b "[1][The saved file is WRONG|save it in .LOW format|and then corrige|to try again][OKAY]",0


trop_instrument            dc.b " Error : Too many instrument !!!                  "
instrument_too_long        dc.b "Error the instrument $                            "
n_instrument_too_long      dc.b "00 is so big (>65535 Bytes)                       "
too_many_pos               dc.b " Error : too many positions  !!!  (>128)          "
position_restart_too_big   dc.b " The Restart-Position is so big (>128)            "
too_many_pattern           dc.b " Error : too many pattern !!! (>256)              "
inst_sup_31_pat            dc.b " Wrong instrument number (>31) , on pattern $"
ninst_sup_31_pat           dc.b "00   "

operation1 dc.b "Saving Music Name   "
operation2 dc.b "Saving Info Instruments"
operation3 dc.b "Saving all positions"
operation4 dc.b "Saving all patterns "
operation5 dc.b "Saving Sample       "

operation_wait     dc.b " Waiting",0
operation_start    dc.b "  Start ",0
operation_stop     dc.b "  Stop  ",0
operation_continue dc.b "Continue",0

 even
type
 dc.b "LOW "
 dc.b "MOD "
 even

frequence
 dc.w 123,freq0
 dc.w 82,freq1
 dc.w 73,freq2
 dc.w 60,freq3
 dc.w 49,freq4
 dc.w 43,freq5
 dc.w 41,freq6
 dc.w 31,freq7
 dc.w 25,freq8
 dc.w 39,freq9

frequence1 * 9 decimal
max = 999999999
 dc.l 4995
 dc.l max-121951000
 dc.l 7492
 dc.l max-682927000
 dc.l 8416
 dc.l max-438356000
 dc.l 10240
 dc.l max-0
 dc.l 12538
 dc.l max-775510000
 dc.l 14288
 dc.l max-372090000
 dc.l 14985
 dc.l max-365850000
 dc.l 19819
 dc.l max-354840000
 dc.l 24576
 dc.l max-0
 dc.l 15753
 dc.l max-846150000

 dc.b "   "
write_note
 dc.b "C3 "
 dc.b "#C3"
 dc.b "D3 "
 dc.b "#D3"
 dc.b "E3 "
 dc.b "F3 "
 dc.b "#F3"
 dc.b "G3 "
 dc.b "#G3"
 dc.b "A3 "
 dc.b "#A3"
 dc.b "B3 "
 dc.b "C4 "
 dc.b "#C4"
 dc.b "D4 "
 dc.b "#D4"
 dc.b "E4 "
 dc.b "F4 "
 dc.b "#F4"
 dc.b "G4 "
 dc.b "#G4"
 dc.b "A4 "
 dc.b "#A4"
 dc.b "B4 "
 dc.b "C5 "
 dc.b "#C5"
 dc.b "D5 "
 dc.b "#D5"
 dc.b "E5 "
 dc.b "F5 "
 dc.b "#F5"
 dc.b "G5 "
 dc.b "#G5"
 dc.b "A5 "
 dc.b "#A5"
 dc.b "B5 "
 dc.b "C6 "

 even

table_note 
 dc.w 12+24*c3
 dc.w 12+24*c_3
 dc.w 12+24*d3
 dc.w 12+24*d_3
 dc.w 12+24*e3
 dc.w 12+24*f3
 dc.w 12+24*f_3
 dc.w 12+24*g3
 dc.w 12+24*g_3
 dc.w 12+24*a3
 dc.w 12+24*a_3
 dc.w 12+24*b3
 dc.w 12+24*c4
 dc.w 12+24*c_4
 dc.w 12+24*d4
 dc.w 12+24*d_4
 dc.w 12+24*e4
 dc.w 12+24*f4
 dc.w 12+24*f_4
 dc.w 12+24*g4
 dc.w 12+24*g_4
 dc.w 12+24*a4
 dc.w 12+24*a_4
 dc.w 12+24*b4
 dc.w 12+24*c5
 dc.w 12+24*c_5
 dc.w 12+24*d5
 dc.w 12+24*d_5
 dc.w 12+24*e5
 dc.w 12+24*f5
 dc.w 12+24*f_5
 dc.w 12+24*g5
 dc.w 12+24*g_5
 dc.w 12+24*a5
 dc.w 12+24*a_5
 dc.w 12+24*b5
 dc.w 12+24*c6

 even
 include vdilib.s
 include aeslib.s

 section bss
def_track = *+nombre_de_notes_geres*3
def_note = *+128++nombre_de_notes_geres*3
def_note_off = *+128*2++nombre_de_notes_geres*3
table_pitch_split ds.b 128*16
dest ds.l 1
taile ds.l 1
        
info_saving_mod ds.w 25*13

tailein ds.l 4*256           * 16 octets par info instruments
name_instruments ds.w 11*256 * 22 caracteres par noms d'instruments

ecran ds.l 1
div ds.w 1
plot ds.w 1
reste ds.l 1
s_color ds.l 8
adr_car ds.l 1
s_mouse ds.l 16
ap_id ds.w 1
s_usp ds.l 1
s_sr ds.w 1
type_fichier ds.w 1
commande_op ds.w 1

adr_form1 ds.l 1
adr_form2 ds.l 1
adr_form3 ds.l 1
adr_form4 ds.l 1
adr_form5 ds.l 1
adr_instrum ds.l 1
adr_midi ds.l 1
adr_pitch ds.l 1
adr_speed ds.l 1
adr_pattern ds.l 1
adr_midi_rec ds.l 1
adr_first_loading ds.l 1
adr_saving ds.l 1
adr_saving_mod ds.l 1

x_center ds.w 1
y_center ds.w 1
w_center ds.w 1
h_center ds.w 1
xcenter0 ds.w 1
ycenter0 ds.w 1
wcenter0 ds.w 1
hcenter0 ds.w 1
xcenter1 ds.w 1
ycenter1 ds.w 1
wcenter1 ds.w 1
hcenter1 ds.w 1
xcenter2 ds.w 1
ycenter2 ds.w 1
wcenter2 ds.w 1
hcenter2 ds.w 1
xcenter3 ds.w 1
ycenter3 ds.w 1
wcenter3 ds.w 1
hcenter3 ds.w 1
xcenter_instrum ds.w 1
ycenter_instrum ds.w 1
wcenter_instrum ds.w 1
hcenter_instrum ds.w 1
xcenter_midi ds.w 1
ycenter_midi ds.w 1
wcenter_midi ds.w 1
hcenter_midi ds.w 1
xcenter_pitch ds.w 1
ycenter_pitch ds.w 1
wcenter_pitch ds.w 1
hcenter_pitch ds.w 1
xcenter_speed ds.w 1
ycenter_speed ds.w 1
wcenter_speed ds.w 1
hcenter_speed ds.w 1
xcenter_pattern ds.w 1
ycenter_pattern ds.w 1
wcenter_pattern ds.w 1
hcenter_pattern ds.w 1
xcenter_midi_rec ds.w 1
ycenter_midi_rec ds.w 1
wcenter_midi_rec ds.w 1
hcenter_midi_rec ds.w 1
xcenter_first_loading ds.w 1
ycenter_first_loading ds.w 1
wcenter_first_loading ds.w 1
hcenter_first_loading ds.w 1
xcenter_saving ds.w 1
ycenter_saving ds.w 1
wcenter_saving ds.w 1
hcenter_saving ds.w 1
xcenter_saving_mod ds.w 1
ycenter_saving_mod ds.w 1
wcenter_saving_mod ds.w 1
hcenter_saving_mod ds.w 1

debut_sample ds.l 1
fin_sample ds.l 1
fin_sample_bis ds.l 1
debut_boucle ds.l 1
fin_boucle ds.l 1
adr_replay ds.l 1
objadr ds.l 1
s_134 ds.l 1
s_mfp ds.l 2
s_484 ds.w 1
obj ds.w 1
oto ds.w 1
retour ds.w 1
s_ym ds.w 1
gum ds.w 1
w_handle ds.w 1
twind ds.w 4

path ds.b 200
path1 ds.b 200

namepitch ds.b 14
sourcename ds.b 14
destname ds.b 14

info_instrument ds.l 1
oto1 ds.w 1
auto? ds.w 1
nb_in ds.w 1
type_mod ds.l 1
handle_disk ds.w 1
handle_disk_write ds.w 1
frequ1 ds.l 1
frequ2 ds.l 1
* flag
velocityflag ds.w 1
modulatiflag ds.w 1
pitchbenflag ds.w 1
canal_midi ds.w 1
vitesse ds.w 1
num_ins ds.w 1
pos_restart ds.w 1
nb_pos ds.w 1
nb_pat ds.w 1
pos_rec_start ds.w 1
pos_rec_end ds.w 1
pos_edit ds.w 1
rec_start ds.w 1
rec_end ds.w 1
offset_pat ds.w 1
s_70 ds.l 1
indic_shift ds.w 1
cmpt_vbl ds.w 1
adr_sample ds.l 1
taile_write ds.l 1
frequence_choisi ds.w 1
type_format ds.w 1
line_indic ds.w 1
indic_pat_error ds.w 1
error? ds.w 1


* midi in
synchro_on_start ds.w 1
start_midi ds.w 1
ecrit_tout ds.w 4
canal_receive ds.w 1
note_voie ds.l 8
volume_voie ds.l 8
instrument_voie ds.l 8
effect_voie ds.l 8
nb_octets_midi ds.w 1
nb_octets_clavier ds.w 1
buffer_midi ds.l 100
buffer_clavier ds.l 100
s_118 ds.l 1
pedale_contrl ds.w 16
***************** ne jamais separer
save_startpos ds.w 1
save_endpos ds.w 1
pos ds.w 15000  * en tout maximum 15000 positions....
***************** fin de la der al
buff_boulo ds.w 256*2
adr_pos ds.l 1
 ds.l 2000
a7_pile
buffersource ds.l 70000

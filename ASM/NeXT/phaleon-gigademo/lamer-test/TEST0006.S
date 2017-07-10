finale =0
vit_souris = 6
tempo = 0
debug =0
init_disk=0

choix macro
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 bsr calcule_index
 move.l a1,a6
 bsr print0
 bsr efface_tout
 endm

choixmit macro
 lea mitidx,a0
 lea mittxt,a1
 move langue,d0
 bsr calcule_index
 move.l a1,a6
 bsr print0
 bsr efface_tout
 endm

choixmusic macro
 lea musicidx,a0
 lea musictxt,a1
 move langue,d0
 bsr calcule_index
 move.l a1,a6
 bsr print0
 bsr efface_tout
 endm

choixcoder macro
 lea coderidx,a0
 lea codertxt,a1
 move langue,d0
 bsr calcule_index
 move.l a1,a6
 bsr print0
 bsr efface_tout
 endm

choixlamer macro
 lea lameridx,a0
 lea lamertxt,a1
 move langue,d0
 bsr calcule_index
 move.l a1,a6
 bsr print0
 bsr efface_tout
 endm

choixgraph macro
 lea graphidx,a0
 lea graphtxt,a1
 move langue,d0
 bsr calcule_index
 move.l a1,a6
 bsr print0
 bsr efface_tout
 endm

hlogo = 60

color_select =$00040007
* pour les etoiles
nb_plan = 3
nb_star = 170+100
precision = 15
max_speed = 13
xmin = 0
xmax = 320
ymin = hlogo+5
ymax = 200


*
nb_spr = 2
 ifeq finale
 pea debut(pc)
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
 move #1,-(sp)
 pea -1
 pea -1
 move #5,-(sp)
 trap #14
 lea 12(sp),sp
 clr -(sp)
 trap #1
 elseif
drive_use = ($600+12+640+4) *2
bgt
 org $5000
 move #$2700,sr
 clr.b $fffffa07.w
 clr.b $fffffa09.w
 move drive_use,d0
 add d0,d0
 or #1,d0
 move d0,n_drive 
 jsr debut
 dc.l "NEXT","BACK"
 endc
 include star.s
debut
 ifeq finale
 bra.s .oui1
.oui0
 tst.b $fffffc02.w
.oui1
 btst #0,$fffffc00.w
 bne.s .oui0
 move #2,n_drive
 or #1,n_drive
 endc
 move sr,s_sr
 move.l a7,s_a7
 move.l usp,a0
 move.l a0,s_usp
 lea pile,a7
 move #$2700,sr
 jsr save
 jsr programme
 jsr restore

 move.b #$3,$fffffc00.w
 move.b #$96,$fffffc00.w
.lop
 tst.b $fffffc02.w
 btst #4,$fffffa01.w
 beq.s .lop
 btst #0,$fffffc00.w
 bne.s .lop

 move #$2700,sr
 move.l s_usp,a0
 move.l a0,usp
 move.l s_a7,a7
 move s_sr,sr
 rts
************ arf ca commence !  
programme
 ifne debug
 illegal
 endc
 lea $ffff8240.w,a0
 moveq #7,d7
.cfg
 clr.l (a0)+
 dbra d7,.cfg
 clr.b $fffffa07.w
 clr.b $fffffa09.w
 move.l #vbl_nul,$70.w
.lko
 tst.b $fffffc02.w
 btst #4,$fffffa01.w
 beq.s .lko
 clr flag_clavier
 bsr prepare_tout
 move.l #clavier,$118.w
 move.b #$40,$fffffa17.w
 lea sequence,a0
 bsr envoie_clavier
* init
 move.l #courbe0,adr_c0
 move #1,langue
 clr autre_raster
 move.l #vbl,$70.w
 move #$2300,sr
 stop #$2300
 clr donne_aj
 clr.b $ffff8260.w
 bsr vsync
 clr.b $ffff820a.w
 bsr vsync
 move.b #2,$ffff820a.w
 moveq #22,d0
 jsr Killing_Game_1+2
 move.l #Killing_Game_1+6+2,adr_music
 moveq #14,d7
.deg0
 bsr vsync
 bsr vsync
 add.l #32,couleurs_logo
 dbra d7,.deg0

 move.b #$3,$fffffc00.w
 move.b #$96,$fffffc00.w
.lop
 tst.b $fffffc02.w
 btst #4,$fffffa01.w
 beq.s .lop
 btst #0,$fffffc00.w
 bne.s .lop

 ifne init_disk
 bsr save_hi_score
 endc
 bsr load_hi_score

*d0 -> Num‚ro de langue
*d1 -> Num‚ro de question
*a0 -> Adresse du fichier index
*a1 -> Adresse du fichier texte correspondant
*a1 <- Pointe sur le bloc 'Question' demand‚

 bsr menu_general
*.wait
* bsr take_octet
* bclr #7,d0
* cmp.b #$39,d0
* bne.s .wait

 moveq #14,d7
.deg1
 bsr vsync
 bsr vsync
 sub.l #32,couleurs_logo
 dbra d7,.deg1
 lea sequence1,a0
 bsr envoie_clavier
 lea $ffff8800.w,a0
 move.l #$08080000,(a0)
 move.l #$09090000,(a0)
 move.l #$0a0a0000,(a0)
 rts


menu_general
 moveq #0,d1
 choix
 tst d0
 bmi menu_general
 lea adr_main_rout(pc),a0
 add d0,d0
 add d0,d0
 add d0,a0
 move.l (a0),a0
 jsr (a0)
 tst d0
 beq.s menu_general
 rts
adr_main_rout
 dc.l rts
 dc.l tests
 dc.l gere_langage
 dc.l score
 dc.l changemusic
 dc.l quit

rts rts


changemusic
 moveq #6,d1
 choix
 tst d0
 bmi .sort
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d1
 cmp #2,d1
 blt.s .sort
*
 add d0,d0
 lea table_auteur-4,a0
 add d0,a0
 move.l (a0),a0
 jsr (a0)
*
 bra.s changemusic
.sort
 moveq #0,d0
 rts
table_auteur
 dc.l countzero
 dc.l madmax
 dc.l davidw
 dc.l robh
 dc.l crisppy

countzero
 moveq #7,d1
 choix
 tst d0
 bmi .sort
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d1
 cmp #2,d1
 blt.s .sort
***** change
 lea .datam,a0
 add d0,d0
 add d0,d0
 subq #8,d0
 add d0,a0
 move.l (a0)+,d0
 move.l (a0)+,a0
 move.l a0,a1
 add (a0)+,a0
 move.l a0,adr_music
 jsr 2(a1)
 bra.s countzero
.sort
 rts
.datam
 dc.l 22
 dc.l Killing_Game_1
 dc.l 23
 dc.l Killing_Game_1
 dc.l 24
 dc.l Killing_Game_1
 dc.l 1
 dc.l Decade_Intro
 dc.l 1
 dc.l Mad_Max_Remix
 dc.l 1
 dc.l Decade_Reset


madmax
 moveq #8,d1
 choix
 tst d0
 bmi .sort
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d1
 cmp #2,d1
 blt.s .sort
***** change
 lea .datam,a0
 add d0,d0
 add d0,d0
 subq #8,d0
 add d0,a0
 move.l (a0)+,d0
 move.l (a0)+,a0
 move.l a0,a1
 add (a0)+,a0
 move.l a0,adr_music
 jsr 2(a1)
 bra.s madmax
.sort
 rts
.datam
 dc.l 1
 dc.l Atomino_1
 dc.l 1
 dc.l Atomino_2
 dc.l 2
 dc.l Atomino_2
 dc.l 1
 dc.l Atomino_4
 dc.l 1
 dc.l Syntax





davidw
 moveq #9,d1
 choix
 tst d0
 bmi .sort
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d1
 cmp #2,d1
 blt.s .sort
***** change
 lea .datam,a0
 add d0,d0
 add d0,d0
 subq #8,d0
 add d0,a0
 move.l (a0)+,d0
 move.l (a0)+,a0
 move.l a0,a1
 add (a0)+,a0
 move.l a0,adr_music
 jsr 2(a1)
 bra.s davidw
.sort
 rts
.datam
 dc.l 0
 dc.l Goldrunner_II
 dc.l 0
 dc.l Platoon_0
 dc.l 1
 dc.l Platoon_0
 dc.l 2
 dc.l Platoon_0
 dc.l 3
 dc.l Platoon_0
 dc.l 4
 dc.l Platoon_0
 dc.l 5
 dc.l Platoon_0
 dc.l 6
 dc.l Platoon_0


robh
 moveq #10,d1
 choix
 tst d0
 bmi .sort
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d1
 cmp #2,d1
 blt.s .sort
***** change
 lea .datam,a0
 add d0,d0
 add d0,d0
 subq #8,d0
 add d0,a0
 move.l (a0)+,d0
 move.l (a0)+,a0
 move.l a0,a1
 add (a0)+,a0
 move.l a0,adr_music
 jsr 2(a1)
 bra.s robh
.sort
 rts
.datam
 dc.l 0
 dc.l Warhawk

crisppy
 moveq #11,d1
 choix
 tst d0
 bmi .sort
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d1
 cmp #2,d1
 blt.s .sort
***** change
 lea .datam,a0
 add d0,d0
 add d0,d0
 subq #8,d0
 add d0,a0
 move.l (a0)+,d0
 move.l (a0)+,a0
 move.l a0,a1
 add (a0)+,a0
 move.l a0,adr_music
 jsr 2(a1)
 bra.s crisppy
.sort
 rts
.datam
 dc.l 0
 dc.l Hybris



********** fini pour le change mus
tests
 moveq #3,d1
 choix
 tst d0
 bmi.s .sort
 subq #1,d0
 lea adr_tests,a0
 add d0,d0
 add d0,d0
 add d0,a0
 move.l (a0),a0
 jsr (a0)
*
.sort
 moveq #0,d0
 rts
adr_tests
 dc.l coder_test
 dc.l graph_test
 dc.l music_test
 dc.l mit_test
 dc.l lamer_test


messg dc.b "Please enter your name :",0
space dc.b " ",0
name dc.b "-                    ",0
 even
ask_name
 pea (a0)
 bsr efface_tout
 st autre_raster
 move #11,ecart
 move #2,nb_line
 move #8*3,offset_car
 lea messg,a6
.loop
 tst.b (a6)
 beq.s .loopf
 move.b (a6),d6
 move d6,d0
 bsr converti
 move.b d0,(a6)
 bsr print_car
 move.b d6,(a6)
 bsr add_car
 bra.s .loop
.loopf

 move #3,nb_line
 lea name,a6
 clr.b 1(a6)
 move #8*2,offset_car
 move.b (a6),d0
 bsr converti
 move.b d0,(a6)
 bsr print_car
 move.b d6,(a6)
 bsr add_car
 moveq #0,d7
.loop0 
 bsr take_octet
 cmp.b #$e,d0
 bne.s .pas_back
 cmp #8*2+1,offset_car
 ble.s .loop0
 bsr sub_car
 clr.b (a6)
 pea (a6)
 lea space,a6
 move.b (a6),d0
 bsr converti
 move.b d0,(a6)
 bsr print_car
 move.l (sp)+,a6
 subq #1,d7
 bra.s .loop0
.pas_back
 cmp.b #$1c,d0
 beq.s .fin
 cmp.b #$72,d0
 beq.s .fin
 cmp #20,d7
 bge.s .loop0
 lea .tabln,a0
 move langue,d1
 add d1,d1
 add d1,d1
 add d1,a0
 move.l (a0),a0
 and #$ff,d0
 move.b (a0,d0.w),d0
 cmp.b #"a",d0
 blt.s .ouf
 cmp.b #"z",d0
 bgt.s .loop0
 sub.b #"a"-"A",d0
.ouf
 cmp.b #" ",d0
 beq.s .ouf1
 cmp.b #"A",d0
 blt.s .loop0
 cmp.b #"Z",d0
 bgt .loop0
.ouf1
 move d0,d6
 bsr converti
 move.b d0,(a6)
 addq #1,d7
 bsr print_car
 move.b d6,(a6)
 bsr add_car
 bra .loop0
.fin
 move.l (sp)+,a0
 move d7,-(sp)
 lea -36+4(a0),a1
 move.l a1,a2
 moveq #20-1,d7
.cf1
 move.b #".",(a1)+
 dbra d7,.cf1
 
 move (sp)+,d7
 beq.s .fincf2
 subq #1,d7
 lea name+1,a1
.cf2
 move.b (a1)+,(a2)+
 dbra d7,.cf2
.fincf2
 bsr efface_tout
 st autre_raster 
 rts
.tabln
 dc.l .conv_carmaj
 dc.l .conv_carmaje
 dc.l .conv_carmaje1

.conv_carmaj
 dc.b 0,1,"1234567890",0,0,2,0,"AZERTYUIOP",0,"$",1,0,"QSDFGHJKLM%"
 dc.b "-",3,0,"WXCVBN?./+",3,0,0," ",3,4,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,"-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"()/*7894561230.",1,0,0,0,0,0,0,0
.conv_carmaje
 dc.b 0,1,"&‚",22,27,"(",0,"Š!‡…)",0,2,0,"QWERTYUIOP",0,"$",1,0,"ASDFGHJKL?%"
 dc.b "-",3,0,"ZXCVBNM./+",3,0,0," ",3,4,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,"-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"()/*7894561230.",1,0,0,0,0,0,0,0
.conv_carmaje1
 dc.b 0,1,"&‚",22,27,"(",0,"Š!‡…)",0,2,0,"QWERTZUIOP",0,"$",1,0,"ASDFGHJKL?%"
 dc.b "-",3,0,"YXCVBNM./+",3,0,0," ",3,4,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,"-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"()/*7894561230.",1,0,0,0,0,0,0,0




change
 move.l a0,a1
 subq #1,a1
.lch
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 move.b .tabch(pc,d7.w),-(a1)
 swap d7
 tst d7
 bne.s .lch
 rts
.tabch dc.b "0123456789"


lamer_test
 move lamertxt,d0
 subq #1,d0
 moveq #0,d1
 moveq #0,d7
.loop_mit
 movem d0-d6/a0-a6,-(sp)
 move d7,-(sp)
 choixlamer
 move (sp)+,d7
 tst d0
 bmi .ggin
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d0
 cmp #2,d0
 blt.s .pas_gagne
 addq #1,d7 
 cmp #3,d0
 blt.s .gagne
 addq #1,d7 
 bra.s .gagne
.pas_gagne 
 tst.b d0
 bne.s .gagne
 tst d7
 ble.s .gagne
 subq #1,d7
.gagne
 movem (sp)+,d0-d6/a0-a6
 addq #1,d1
 dbra d0,.loop_mit
 move d7,-(sp)
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 move.l a1,a2
.ch0
 cmp.b #1,(a1)+
 bne.s .ch0
 cmp.b #2,(a1)
 bne.s .ch0
 cmp.b #3,1(a1)
 bne.s .ch0
 cmp.b #4,2(a1)
 bne.s .ch0
 cmp.b #5,3(a1)
 bne.s .ch0
 cmp.b #6,4(a1)
 bne.s .ch0
 subq #1,a1
 sub.l a1,a2
 move a2,nb_scr
 moveq #26-1,d7
.lock
 clr.b (a1)+
 dbra d7,.lock
*
 move (sp)+,d7
 move d7,nb_bon
 lea -26+10(a1),a1
 *31
 move.l a1,a0
 moveq #-1,d6
.lodiv
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv
 tst d6
 beq.s .rien
 subq #1,d6
 move.l a1,a2
.lodiva
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva
 move.l a2,a1
.rien
 move.b #77,(a1)+

 move.l a1,a0
 moveq #-1,d6
 moveq #17,d7
.lodiv1
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv1
 tst d6
 beq.s .rien1
 subq #1,d6
.lodiva1
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva1
.rien1

*insere
 moveq #0,d7
 move nb_bon,d7
 mulu #(100/17),d7
 lea bestlamer+36,a0
 moveq #10-1,d0
.loop
 cmp (a0),d7
 ble.s .db
 pea (a0)
 move d7,-(sp)
 pea (a1)
 move.l a0,a1
 move d0,d1
 mulu #38,d1
 lea -36(a1),a1
 add d1,a1
.ouig
 moveq #19-1,d6
.ouig1
 move -38(a1),(a1)+
 dbra d6,.ouig1
 lea -38*2(a1),a1
 dbra d0,.ouig

 lea bestlamer,a1
 moveq #9-1,d0
 moveq #"1",d1
.chj
 move.b d1,(a1)
 move.b #" ",1(a1)
 addq #1,d1
 lea 38(a1),a1
 dbra d0,.chj
 move.b #"1",(a1)+
 move.b #"0",(a1)+
 move.l (sp)+,a1
 bsr change
 bsr ask_name
 moveq #0,d0
 move (sp)+,d7
 move.l (sp)+,a0
 move d7,(a0)
.db
 lea 38(a0),a0
 dbra d0,.loop
 
 lea bestlamer,a0
 bsr best_score

 moveq #5,d1
 choix
 cmp #4,d0
 bne.s .pas_save
 bsr save_hi_score
.pas_save
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 sub nb_scr,a1
 moveq #26-1,d7
 moveq #1,d0
.lock1
 move.b d0,(a1)+
 addq #1,d0
 dbra d7,.lock1


 movem d0-d6/a0-a6,-(sp)
.ggin
 movem (sp)+,d0-d6/a0-a6
 moveq #0,d0
 rts
.ggin1
 move (sp)+,d0
 moveq #0,d0
 rts

save_hi_score
 bsr efface_tout
 bsr insert_disk_one
 bsr eor_disk
*** loading
* d3 nb secteur
* d4 nb piste to begin
* d5 nb secteurs to begin
 lea bestcoder,a0
 moveq #4,d3
 moveq #70,d4
 moveq #7,d5
 bsr disk_write
 tst d1
 beq.s .pas_erreur
 moveq #13,d1
 choix 
.pas_erreur
 bsr eor_disk
 rts

insert_disk_one
 clr.l buffer_disk+2+2
 move n_drive,d0
 move d0,-(sp)
 bclr #0,d0
 move d0,n_drive
 lea buffer_disk,a0
 moveq #1,d3
 moveq #0,d4
 moveq #1,d5
 bsr disk_read
 move (sp)+,n_drive
 cmp.l #"al_1",buffer_disk+2+2
 beq.s .ouf_disk1
 moveq #12,d1
 choix 
 bra.s insert_disk_one
.ouf_disk1
 rts

load_hi_score
 bsr efface_tout
 bsr insert_disk_one
*** loading
* d3 nb secteur
* d4 nb piste to begin
* d5 nb szecteurs to begin
 lea bestcoder,a0
 moveq #4,d3
 moveq #70,d4
 moveq #7,d5
 bsr disk_read
 tst d1
 beq.s .pas_erreur
 moveq #13,d1
 choix 
.pas_erreur
 bsr eor_disk
 rts

eor_disk
 lea bestcoder,a0
 move #(4*512)/2-1,d7
 moveq #12,d0
 moveq #29,d1
.eor
 eor.b d0,(a0)+
 eor.b d1,(a0)+
 addq #5,d0
 addq #3,d1
 dbra d7,.eor
 rts


coder_test
* illegal
 move codertxt,d0
 subq #1,d0
 moveq #0,d1
 moveq #0,d7
.loop_mit
 movem d0-d6/a0-a6,-(sp)
 move d7,-(sp)
 choixcoder
 move (sp)+,d7
 tst d0
 bmi .ggin
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d0
 cmp #2,d0
 blt.s .pas_gagne
 addq #1,d7 
 cmp #3,d0
 blt.s .gagne
 addq #1,d7 
 bra.s .gagne
.pas_gagne 
 tst.b d0
 bne.s .gagne
 tst d7
 ble.s .gagne
 subq #1,d7
.gagne
 movem (sp)+,d0-d6/a0-a6
 addq #1,d1
 dbra d0,.loop_mit
 move d7,-(sp)
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 move.l a1,a2
.ch0
 cmp.b #1,(a1)+
 bne.s .ch0
 cmp.b #2,(a1)
 bne.s .ch0
 cmp.b #3,1(a1)
 bne.s .ch0
 cmp.b #4,2(a1)
 bne.s .ch0
 cmp.b #5,3(a1)
 bne.s .ch0
 cmp.b #6,4(a1)
 bne.s .ch0
 subq #1,a1
 sub.l a1,a2
 move a2,nb_scr
 moveq #26-1,d7
.lock
 clr.b (a1)+
 dbra d7,.lock
*
 move (sp)+,d7
 move d7,nb_bon
 lea -26+10(a1),a1
 *31
 move.l a1,a0
 moveq #-1,d6
.lodiv
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv
 tst d6
 beq.s .rien
 subq #1,d6
 move.l a1,a2
.lodiva
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva
 move.l a2,a1
.rien
 move.b #77,(a1)+

 move.l a1,a0
 moveq #-1,d6
 moveq #18,d7
.lodiv1
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv1
 tst d6
 beq.s .rien1
 subq #1,d6
.lodiva1
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva1
.rien1

*insere
 moveq #0,d7
 move nb_bon,d7
 mulu #(100/18),d7
 lea bestcoder+36,a0
 moveq #10-1,d0
.loop
 cmp (a0),d7
 ble.s .db
 pea (a0)
 move d7,-(sp)
 pea (a1)
 move.l a0,a1
 move d0,d1
 mulu #38,d1
 lea -36(a1),a1
 add d1,a1
.ouig
 moveq #19-1,d6
.ouig1
 move -38(a1),(a1)+
 dbra d6,.ouig1
 lea -38*2(a1),a1
 dbra d0,.ouig

 lea bestcoder,a1
 moveq #9-1,d0
 moveq #"1",d1
.chj
 move.b d1,(a1)
 move.b #" ",1(a1)
 addq #1,d1
 lea 38(a1),a1
 dbra d0,.chj
 move.b #"1",(a1)+
 move.b #"0",(a1)+
 move.l (sp)+,a1
 bsr change
 bsr ask_name
 moveq #0,d0
 move (sp)+,d7
 move.l (sp)+,a0
 move d7,(a0)
.db
 lea 38(a0),a0
 dbra d0,.loop
 
 lea bestcoder,a0
 bsr best_score

 moveq #5,d1
 choix
 cmp #4,d0
 bne.s .pas_save
 bsr save_hi_score
.pas_save
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 sub nb_scr,a1
 moveq #26-1,d7
 moveq #1,d0
.lock1
 move.b d0,(a1)+
 addq #1,d0
 dbra d7,.lock1


 movem d0-d6/a0-a6,-(sp)
.ggin
 movem (sp)+,d0-d6/a0-a6
 moveq #0,d0
 rts
.ggin1
 move (sp)+,d0
 moveq #0,d0
 rts


graph_test
* illegal
 move graphtxt,d0
 subq #1,d0
 moveq #0,d1
 moveq #0,d7
.loop_mit
 movem d0-d6/a0-a6,-(sp)
 move d7,-(sp)
 choixgraph
 move (sp)+,d7
 tst d0
 bmi .ggin
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d0
 cmp #2,d0
 blt.s .pas_gagne
 addq #1,d7 
 cmp #3,d0
 blt.s .gagne
 addq #1,d7 
 bra.s .gagne
.pas_gagne 
 tst.b d0
 bne.s .gagne
 tst d7
 ble.s .gagne
 subq #1,d7
.gagne
 movem (sp)+,d0-d6/a0-a6
 addq #1,d1
 dbra d0,.loop_mit
 move d7,-(sp)
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 move.l a1,a2
.ch0
 cmp.b #1,(a1)+
 bne.s .ch0
 cmp.b #2,(a1)
 bne.s .ch0
 cmp.b #3,1(a1)
 bne.s .ch0
 cmp.b #4,2(a1)
 bne.s .ch0
 cmp.b #5,3(a1)
 bne.s .ch0
 cmp.b #6,4(a1)
 bne.s .ch0
 subq #1,a1
 sub.l a1,a2
 move a2,nb_scr
 moveq #26-1,d7
.lock
 clr.b (a1)+
 dbra d7,.lock
*
 move (sp)+,d7
 move d7,nb_bon
 lea -26+10(a1),a1
 *31
 move.l a1,a0
 moveq #-1,d6
.lodiv
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv
 tst d6
 beq.s .rien
 subq #1,d6
 move.l a1,a2
.lodiva
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva
 move.l a2,a1
.rien
 move.b #77,(a1)+

 move.l a1,a0
 moveq #-1,d6
 moveq #20,d7
.lodiv1
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv1
 tst d6
 beq.s .rien1
 subq #1,d6
.lodiva1
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva1
.rien1

*insere
 moveq #0,d7
 move nb_bon,d7
 mulu #(100/20),d7
 lea bestgraph+36,a0
 moveq #10-1,d0
.loop
 cmp (a0),d7
 ble.s .db
 pea (a0)
 move d7,-(sp)
 pea (a1)
 move.l a0,a1
 move d0,d1
 mulu #38,d1
 lea -36(a1),a1
 add d1,a1
.ouig
 moveq #19-1,d6
.ouig1
 move -38(a1),(a1)+
 dbra d6,.ouig1
 lea -38*2(a1),a1
 dbra d0,.ouig

 lea bestgraph,a1
 moveq #9-1,d0
 moveq #"1",d1
.chj
 move.b d1,(a1)
 move.b #" ",1(a1)
 addq #1,d1
 lea 38(a1),a1
 dbra d0,.chj
 move.b #"1",(a1)+
 move.b #"0",(a1)+
 move.l (sp)+,a1
 bsr change
 bsr ask_name
 moveq #0,d0
 move (sp)+,d7
 move.l (sp)+,a0
 move d7,(a0)
.db
 lea 38(a0),a0
 dbra d0,.loop
 
 lea bestgraph,a0
 bsr best_score

 moveq #5,d1
 choix
 cmp #4,d0
 bne.s .pas_save
 bsr save_hi_score
.pas_save
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 sub nb_scr,a1
 moveq #26-1,d7
 moveq #1,d0
.lock1
 move.b d0,(a1)+
 addq #1,d0
 dbra d7,.lock1


 movem d0-d6/a0-a6,-(sp)
.ggin
 movem (sp)+,d0-d6/a0-a6
 moveq #0,d0
 rts
.ggin1
 move (sp)+,d0
 moveq #0,d0
 rts


music_test
* illegal
 move musictxt,d0
 subq #1,d0
 moveq #0,d1
 moveq #0,d7
.loop_mit
 movem d0-d6/a0-a6,-(sp)
 move d7,-(sp)
 choixmusic
 move (sp)+,d7
 tst d0
 bmi .ggin
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d0
 cmp #2,d0
 blt.s .pas_gagne
 addq #1,d7 
 cmp #3,d0
 blt.s .gagne
 addq #1,d7 
 bra.s .gagne
.pas_gagne 
 tst.b d0
 bne.s .gagne
 tst d7
 ble.s .gagne
 subq #1,d7
.gagne
 movem (sp)+,d0-d6/a0-a6
 addq #1,d1
 dbra d0,.loop_mit
 move d7,-(sp)
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 move.l a1,a2
.ch0
 cmp.b #1,(a1)+
 bne.s .ch0
 cmp.b #2,(a1)
 bne.s .ch0
 cmp.b #3,1(a1)
 bne.s .ch0
 cmp.b #4,2(a1)
 bne.s .ch0
 cmp.b #5,3(a1)
 bne.s .ch0
 cmp.b #6,4(a1)
 bne.s .ch0
 subq #1,a1
 sub.l a1,a2
 move a2,nb_scr
 moveq #26-1,d7
.lock
 clr.b (a1)+
 dbra d7,.lock
*
 move (sp)+,d7
 move d7,nb_bon
 lea -26+10(a1),a1
 *31
 move.l a1,a0
 moveq #-1,d6
.lodiv
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv
 tst d6
 beq.s .rien
 subq #1,d6
 move.l a1,a2
.lodiva
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva
 move.l a2,a1
.rien
 move.b #77,(a1)+

 move.l a1,a0
 moveq #-1,d6
 moveq #11,d7
.lodiv1
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv1
 tst d6
 beq.s .rien1
 subq #1,d6
.lodiva1
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva1
.rien1

*insere
 moveq #0,d7
 move nb_bon,d7
 mulu #(100/11),d7
 lea bestmusic+36,a0
 moveq #10-1,d0
.loop
 cmp (a0),d7
 ble.s .db
 pea (a0)
 move d7,-(sp)
 pea (a1)
 move.l a0,a1
 move d0,d1
 mulu #38,d1
 lea -36(a1),a1
 add d1,a1
.ouig
 moveq #19-1,d6
.ouig1
 move -38(a1),(a1)+
 dbra d6,.ouig1
 lea -38*2(a1),a1
 dbra d0,.ouig

 lea bestmusic,a1
 moveq #9-1,d0
 moveq #"1",d1
.chj
 move.b d1,(a1)
 move.b #" ",1(a1)
 addq #1,d1
 lea 38(a1),a1
 dbra d0,.chj
 move.b #"1",(a1)+
 move.b #"0",(a1)+
 move.l (sp)+,a1
 bsr change
 bsr ask_name
 moveq #0,d0
 move (sp)+,d7
 move.l (sp)+,a0
 move d7,(a0)
.db
 lea 38(a0),a0
 dbra d0,.loop
 
 lea bestmusic,a0
 bsr best_score

 moveq #5,d1
 choix
 cmp #4,d0
 bne.s .pas_save
 bsr save_hi_score
.pas_save
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 sub nb_scr,a1
 moveq #26-1,d7
 moveq #1,d0
.lock1
 move.b d0,(a1)+
 addq #1,d0
 dbra d7,.lock1


 movem d0-d6/a0-a6,-(sp)
.ggin
 movem (sp)+,d0-d6/a0-a6
 moveq #0,d0
 rts
.ggin1
 move (sp)+,d0
 moveq #0,d0
 rts

mit_test
* illegal
 move mittxt,d0
 subq #1,d0
 moveq #0,d1
 moveq #0,d7
.loop_mit
 movem d0-d6/a0-a6,-(sp)
 move d7,-(sp)
 choixmit
 move (sp)+,d7
 tst d0
 bmi .ggin
 lea selectablite,a0
 add d0,d0
 add d0,a0
 move (a0),d0
 cmp #2,d0
 blt.s .pas_gagne
 addq #1,d7 
 cmp #3,d0
 blt.s .gagne
 addq #1,d7 
 bra.s .gagne
.pas_gagne 
 tst.b d0
 bne.s .gagne
 tst d7
 ble.s .gagne
 subq #1,d7
.gagne
 movem (sp)+,d0-d6/a0-a6
 addq #1,d1
 dbra d0,.loop_mit
 move d7,-(sp)
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 move.l a1,a2
.ch0
 cmp.b #1,(a1)+
 bne.s .ch0
 cmp.b #2,(a1)
 bne.s .ch0
 cmp.b #3,1(a1)
 bne.s .ch0
 cmp.b #4,2(a1)
 bne.s .ch0
 cmp.b #5,3(a1)
 bne.s .ch0
 cmp.b #6,4(a1)
 bne.s .ch0
 subq #1,a1
 sub.l a1,a2
 move a2,nb_scr
 moveq #26-1,d7
.lock
 clr.b (a1)+
 dbra d7,.lock
*
 move (sp)+,d7
 move d7,nb_bon
 lea -26+10(a1),a1
 *31
 move.l a1,a0
 moveq #-1,d6
.lodiv
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv
 tst d6
 beq.s .rien
 subq #1,d6
 move.l a1,a2
.lodiva
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva
 move.l a2,a1
.rien
 move.b #77,(a1)+

 move.l a1,a0
 moveq #-1,d6
 moveq #13,d7
.lodiv1
 addq #1,d6
 and.l #$ffff,d7
 divu #10,d7
 swap d7
 add #31,d7
 move.b d7,(a1)+
 swap d7
 tst d7
 bne.s .lodiv1
 tst d6
 beq.s .rien1
 subq #1,d6
.lodiva1
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva1
.rien1

*insere
 moveq #0,d7
 move nb_bon,d7
 mulu #(100/13),d7
 lea bestmit+36,a0
 moveq #10-1,d0
.loop
 cmp (a0),d7
 ble.s .db
 pea (a0)
 move d7,-(sp)
 pea (a1)
 move.l a0,a1
 move d0,d1
 mulu #38,d1
 lea -36(a1),a1
 add d1,a1
.ouig
 moveq #19-1,d6
.ouig1
 move -38(a1),(a1)+
 dbra d6,.ouig1
 lea -38*2(a1),a1
 dbra d0,.ouig


 lea bestmit,a1
 moveq #9-1,d0
 moveq #"1",d1
.chj
 move.b d1,(a1)
 move.b #" ",1(a1)
 addq #1,d1
 lea 38(a1),a1
 dbra d0,.chj
 move.b #"1",(a1)+
 move.b #"0",(a1)+
 move.l (sp)+,a1
 bsr change
 bsr ask_name
 moveq #0,d0
 move (sp)+,d7
 move.l (sp)+,a0
 move d7,(a0)
.db
 lea 38(a0),a0
 dbra d0,.loop
 
 lea bestmit,a0
 bsr best_score

 moveq #5,d1
 choix
 cmp #4,d0
 bne.s .pas_save
 bsr save_hi_score
.pas_save
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 sub nb_scr,a1
 moveq #26-1,d7
 moveq #1,d0
.lock1
 move.b d0,(a1)+
 addq #1,d0
 dbra d7,.lock1


 movem d0-d6/a0-a6,-(sp)
.ggin
 movem (sp)+,d0-d6/a0-a6
 moveq #0,d0
 rts
.ggin1
 move (sp)+,d0
 moveq #0,d0
 rts

score
 moveq #4,d1
 choix
 lea best,a0
 subq #1,d0
 add d0,d0
 add d0,d0
 add d0,a0
 move.l (a0),a0
 bsr best_score
 moveq #0,d0
 rts
best
 dc.l bestcoder
 dc.l bestgraph
 dc.l bestmusic
 dc.l bestmit
 dc.l bestlamer
 even


gere_langage
 moveq #1,d1
 choix
 subq #1,d0
 move d0,langue
*
 moveq #0,d0
 rts

quit
 moveq #2,d1
 choix
 subq #4,d0
 rts


 include routinea.s 
 include include.s
 include fdcw.s
 include fdcr.s
 data
couleur_text
 rept 5
 dc.w $123
 dc.w $234
 dc.w $345
 dc.w $456
 dc.w $567
*
 dc.w $321
 dc.w $432
 dc.w $543
 dc.w $654
 dc.w $765
 endr
 even
menuidx incbin menu.idx
 even
menutxt incbin menu.txt
 even
sequence dc.b $a,vit_souris,vit_souris,-1
sequence1 dc.b $8,-1
off dc.b $13,-1
 even
next_m incbin next_m.dat
next_mpal incbin next_m.pal
font ds.b 8
 incbin pfont.dat
sprite incbin psprite.dat
courbe0 incbin courbe1.dat
menustxt incbin menu.txt
menusidx incbin menu.idx
mitidx incbin m_i_t.idx
mittxt incbin m_i_t.txt
lameridx incbin question.idx
lamertxt incbin question.txt
coderidx incbin coder.idx
codertxt incbin coder.txt
musicidx incbin music.idx
musictxt incbin music.txt
graphidx incbin gfx.idx
graphtxt incbin gfx.txt

* music ici

* count zero
Killing_Game_1
 dc.w 6
 incbin znort.mus\count.snd
 even
*Killing_Game_2
*Killing_Game_3
Decade_Intro
 dc.w 2
 incbin znort.mus\intro.snd
 even
Mad_Max_Remix
 dc.w 224
 incbin znort.mus\maggie_5.snd
 even
Decade_Reset
 dc.w 2
 incbin znort.mus\reset.snd
 even

* mad max
Atomino_1
 dc.w 8
 incbin znort.mus\atomino.snd
 even
Atomino_2
 dc.w 8
 incbin znort.mus\atomino2.snd
 even
*Atomino_3
Atomino_4
 dc.w 8
 incbin znort.mus\atomino3.snd
 even
Syntax
 dc.w 8
 incbin znort.mus\tex.snd
 even

* David Whittaker
 even
Goldrunner_II
 dc.w $10a
 incbin znort.mus\goldrun2.snd
 even
Platoon_0
 dc.w 14
 incbin znort.mus\platoon.snd
 even
*Platoon_1
*Platoon_2
*Platoon_3
*Platoon_4
*Platoon_5
*Platoon_6

* Rob Hubbard
Warhawk
 dc.w $60
 incbin znort.mus\warhawk.snd
 even

*Crispy Noodle
Hybris
 dc.w 168
 incbin znort.mus\megaball.snd
 even


bestcoder
 dc.b " 1 -FREE..........................0%",0,0
 dc.b " 2 -FREE..........................0%",0,0
 dc.b " 3 -FREE..........................0%",0,0
 dc.b " 4 -FREE..........................0%",0,0
 dc.b " 5 -FREE..........................0%",0,0
 dc.b " 6 -FREE..........................0%",0,0
 dc.b " 7 -FREE..........................0%",0,0
 dc.b " 8 -FREE..........................0%",0,0
 dc.b " 9 -FREE..........................0%",0,0
 dc.b "10 -FREE..........................0%",0,0

bestgraph
 dc.b " 1 -FREE..........................0%",0,0
 dc.b " 2 -FREE..........................0%",0,0
 dc.b " 3 -FREE..........................0%",0,0
 dc.b " 4 -FREE..........................0%",0,0
 dc.b " 5 -FREE..........................0%",0,0
 dc.b " 6 -FREE..........................0%",0,0
 dc.b " 7 -FREE..........................0%",0,0
 dc.b " 8 -FREE..........................0%",0,0
 dc.b " 9 -FREE..........................0%",0,0
 dc.b "10 -FREE..........................0%",0,0

bestmusic
 dc.b " 1 -FREE..........................0%",0,0
 dc.b " 2 -FREE..........................0%",0,0
 dc.b " 3 -FREE..........................0%",0,0
 dc.b " 4 -FREE..........................0%",0,0
 dc.b " 5 -FREE..........................0%",0,0
 dc.b " 6 -FREE..........................0%",0,0
 dc.b " 7 -FREE..........................0%",0,0
 dc.b " 8 -FREE..........................0%",0,0
 dc.b " 9 -FREE..........................0%",0,0
 dc.b "10 -FREE..........................0%",0,0

bestmit
 dc.b " 1 -FREE..........................0%",0,0
 dc.b " 2 -FREE..........................0%",0,0
 dc.b " 3 -FREE..........................0%",0,0
 dc.b " 4 -FREE..........................0%",0,0
 dc.b " 5 -FREE..........................0%",0,0
 dc.b " 6 -FREE..........................0%",0,0
 dc.b " 7 -FREE..........................0%",0,0
 dc.b " 8 -FREE..........................0%",0,0
 dc.b " 9 -FREE..........................0%",0,0
 dc.b "10 -FREE..........................0%",0,0


bestlamer
 dc.b " 1 -FREE..........................0%",0,0
 dc.b " 2 -FREE..........................0%",0,0
 dc.b " 3 -FREE..........................0%",0,0
 dc.b " 4 -FREE..........................0%",0,0
 dc.b " 5 -FREE..........................0%",0,0
 dc.b " 6 -FREE..........................0%",0,0
 dc.b " 7 -FREE..........................0%",0,0
 dc.b " 8 -FREE..........................0%",0,0
 dc.b " 9 -FREE..........................0%",0,0
 dc.b "10 -FREE..........................0%",0,0

 ds.b (4*512)-(*-bestcoder)


 bss
mit
s_usp ds.l 1
s_sr ds.w 1
s_a7 ds.l 1
buf_save ds.w 30+2
 ds.l 1000
pile
* la bss commence veritablement a partir d'ici !!
touche_clavier ds.w 1
flag_clavier ds.w 1
cp_vbl ds.w 1
adr_ecr ds.l 1
adr_ecr1 ds.l 1
langue ds.w 1
autre_raster ds.w 1

* etoiles (starfield)
var_random ds.l 1
starapp ds.w 1
adr_animation ds.l 1
eras_buf1 ds.l 1
eras_buf2 ds.l 1
eras ds.l nb_star*2
buffer_star ds.l 6*nb_star
merde ds.l 2
tablex ds.w precision*(320+2*max_speed)
tabley ds.w precision*(200+2*max_speed)

*text
ecart ds.w 1
nb_line ds.w 1
offset_car ds.w 1
nb_scr ds.w 1
nb_bon ds.w 1
*spr
adr_c0 ds.l 1
donne_aj ds.w 1

*disk
n_drive ds.w 1
buffer_disk ds.w 256

*scores
buffer_inter ds.l (36*10*10)/4

ecrans ds.b 256+32000*2
end_bss
 
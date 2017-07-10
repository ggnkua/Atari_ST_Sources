finale =0
vit_souris = 6
tempo = 0
debug =0

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

hlogo = 60

color_select =$00040007
* pour les etoiles
nb_plan = 3
nb_star = 120
precision = 10
max_speed = 10
xmin = 0
xmax = 320
ymin = hlogo+5
ymax = 200


*
nb_spr = 1
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
 include star.s
debut
 ifeq finale
 bra.s .oui1
.oui0
 tst.b $fffffc02.w
.oui1
 btst #0,$fffffc00.w
 bne.s .oui0
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
 clr.b $fffffa07.w
 clr.b $fffffa09.w
 move.l #vbl_nul,$70.w
 move #$2300,sr
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
 clr donne_aj
 clr.b $ffff8260.w
 bsr vsync
 clr.b $ffff820a.w
 bsr vsync
 move.b #2,$ffff820a.w
 
 moveq #14,d7
.deg0
 bsr vsync
 bsr vsync
 add.l #32,couleurs_logo
 dbra d7,.deg0


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
 rts


menu_general
 moveq #0,d1
 choix
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
 dc.l quit

rts rts

tests
 moveq #3,d1
 choix
 subq #1,d0
 lea adr_tests,a0
 add d0,d0
 add d0,d0
 add d0,a0
 move.l (a0),a0
 jsr (a0)
*
 moveq #0,d0
 rts
adr_tests
 dc.l coder_test
 dc.l graph_test
 dc.l music_test
 dc.l mit_test

coder_test
 moveq #0,d0
 rts
graph_test
 moveq #0,d0
 rts
music_test
 moveq #0,d0
 rts

mit_test
 move mittxt,d0
 subq #1,d0
 moveq #0,d1
 move d0,-(sp)
 choixmit
 cmp #-2,d0
 ble .ggin1
 move (sp)+,d0
 subq #1,d0
 moveq #1,d1
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
.pas_gagne 
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
 moveq #26-1,d7
.lock
 clr.b (a1)+
 dbra d7,.lock
*
 move (sp)+,d7
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
.lodiva
 move.b -(a1),d7
 move.b (a0),(a1)
 move.b d7,(a0)+
 dbra d6,.lodiva
 move.l a0,a1
.rien
 move.b #77,(a1)+

 move.l a1,a0
 moveq #-1,d6
 move mittxt,d7
 subq #1,d7
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
 moveq #5,d1
 choix
*
 lea menuidx,a0
 lea menutxt,a1
 move langue,d0
 moveq #5,d1
 bsr calcule_index 
 move mittxt,d7
 subq #1,d7
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
courbe0 incbin courbe.dat
menustxt incbin menu.txt
menusidx incbin menu.idx
mitidx incbin m_i_t.idx
mittxt incbin m_i_t.txt
 even
bestcoder
 dc.b " 1 -MIT.........................100%"
 dc.b " 2 -DBUG II.....................100%"
 dc.b " 3 -MIT.........................100%"
 dc.b " 4 -MIT.........................100%"
 dc.b " 5 -MIT.........................100%"
 dc.b " 6 -MIT.........................100%"
 dc.b " 7 -MIT.........................100%"
 dc.b " 8 -MIT.........................100%"
 dc.b " 9 -MIT.........................100%"
 dc.b "10 -MIT.........................100%"

bestgraph
 dc.b " 1 -CHROMIX.....................100%"
 dc.b " 2 -PULSAR......................100%"
 dc.b " 3 -Chromix.....................100%"
 dc.b " 4 -Chromix.....................100%"
 dc.b " 5 -Chromix.....................100%"
 dc.b " 6 -Chromix.....................100%"
 dc.b " 7 -Chromix.....................100%"
 dc.b " 8 -Chromix.....................100%"
 dc.b " 9 -Chromix.....................100%"
 dc.b "10 -Chromix.....................100%"

bestmusic
 dc.b " 1 -LAP.........................100%"
 dc.b " 2 -FFT.........................100%"
 dc.b " 3 -Lap.........................100%"
 dc.b " 4 -Lap.........................100%"
 dc.b " 5 -Lap.........................100%"
 dc.b " 6 -Lap.........................100%"
 dc.b " 7 -Lap.........................100%"
 dc.b " 8 -Lap.........................100%"
 dc.b " 9 -Lap.........................100%"
 dc.b "10 -Lap.........................100%"

bestmit
 dc.b " 1 -FFT.........................100%"
 dc.b " 2 -FFT.........................100%"
 dc.b " 3 -FFT.........................100%"
 dc.b " 4 -FFT.........................100%"
 dc.b " 5 -FFT.........................100%"
 dc.b " 6 -FFT.........................100%"
 dc.b " 7 -FFT.........................100%"
 dc.b " 8 -FFT.........................100%"
 dc.b " 9 -FFT.........................100%"
 dc.b "10 -FFT.........................100%"




 bss
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

*spr
adr_c0 ds.l 1
donne_aj ds.w 1

*scores
buffer_inter ds.l (36*10*10)/4

ecrans ds.b 256+32000*2
end_bss
 
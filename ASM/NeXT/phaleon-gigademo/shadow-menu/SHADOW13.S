pause macro
t6 set (\1)/6
t5 set (\1-t6*6)/5
t4 set (\1-t6*6-t5*5)/4
t3 set (\1-t6*6-t5*5-t4*4)/3
t2 set (\1-t6*6-t5*5-t4*4-t3*3)/2
t1 set (\1-t6*6-t5*5-t4*4-t3*3-t2*2)
 dcb.w t6,$e188
 dcb.w t5,$ed88
 dcb.w t4,$e988  ; 
 dcb.w t3,$1090  ; move.b (a0),(a0)
 dcb.w t2,$8080  ; move.b d0,d0
 dcb.w t1,$4e71  ; nop
 endm
finale = 0

tempo = 0
pos_x_depart = 6
* nombre de couleurs du degrade de fond
nombre_couleurs=186*2
nb_block = 120
* nb message maximum par carte !!
max_msg = 37

nb_bande =7 * dont 1 en haut en masque 2 en bas en and..
vitesse_spr =5

 opt w+,o-,d+,p-,a-
*pause macro
* dcb \1,$4e71
* endm

aff_bande macro
 move (a6)+,d7
 move.l a2,a0
 addq #4,a6
 add.l (a6)+,a0
.\@
 move (a0)+,d0
 move d0,(a1)
 move.l d6,2(a1)
 move d6,6(a1)
 move d0,160(a1)
x set 8
 move (a0)+,d0
 move d0,x(a1)
 move d0,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,x(a1)
 move d0,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,x(a1)
 move d0,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,x(a1)
 move d0,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,x(a1)
 move d0,160+x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move (a0)+,x(a1)
x set x+8
 move.l d6,208-6(a1)
 move d6,208-2(a1)
 lea 230(a1),a1
 lea 40(a0),a0
 lea 80(a2),a2
 dbra d7,.\@
 endm

aff_and_bande macro
 move (a6)+,d7
 move.l a2,a0
 addq #4,a6
 add.l (a6)+,a0
.\@
 move (a0)+,d0
 move d0,d1
 and 40(a3),d1
 and (a3)+,d0
 or d0,(a1)
 or d1,160(a1)
x set 8
 move (a0)+,d0
 move d0,d1
 and 40(a3),d1
 and (a3)+,d0
 or d0,x(a1)
 or d1,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,d1
 and 40(a3),d1
 and (a3)+,d0
 or d0,x(a1)
 or d1,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,d1
 and 40(a3),d1
 and (a3)+,d0
 or d0,x(a1)
 or d1,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,d1
 and 40(a3),d1
 and (a3)+,d0
 or d0,x(a1)
 or d1,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,d1
 and 40(a3),d1
 and (a3)+,d0
 or d0,x(a1)
 or d1,160+x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)
x set x+8
 move (a0)+,d0
 and (a3)+,d0
 or d0,x(a1)

 lea 26*2+6*2(a3),a3
 lea 230(a1),a1
 lea 40(a0),a0
 lea 80(a2),a2
 dbra d7,.\@
 endm

 ifeq finale
 pea debutd
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1
 elseif
xecran_anc =    ($600+12+640+18) *2
sens_spr   =    ($600+12+640+20) *2
sens_spr_new =  ($600+12+640+22) *2
xecran       =  ($600+12+640+24) *2
map_courrante = ($600+12+640+26) *2
map_precedante= ($600+12+640+28) *2
cheat         = ($600+12+640+30) *2
bgt
 org $5000
 endc
debutd
 move sr,s_sr
 move #$2700,sr
 move.l a7,s_a7
 move.l usp,a0
 move.l a0,s_usp
 lea pile,a7
 jsr save
 jsr refait_hard
* met l'ecran en place
 lea ecrans+160*7,a0
 move.l a0,d0
 move.l d0,buf1
 move.l d0,buf2
 move.l d0,a0
 move.l d0,adr_buf
 add.l #186*230+160*7+160*14,d0
 move.l d0,adr_buf+4
 add.l #186*230+160*7+160*14,d0
 move.l d0,adr_buf+4*2
 add.l #186*230+160*7+160*14,d0
 move.l d0,adr_buf+4*3
 add.l #186*230+160*7+160*14,d0
 move.l d0,adr_buf+4*4
 add.l #186*230+160*7+160*14,d0
 move.l d0,adr_buf+4*5
 add.l #186*230+160*7+160*4,d0
 move.l d0,adr_buf+4*6
 add.l #186*230+160*7+160*4,d0
 move.l d0,adr_buf+4*7




 lea precaclgfx,a0
 move.l a0,d1
 st d1
 addq.l #1,d1
 move.l d1,a1
 lea precaclgfx+32000,a0
 lea 32000(a1),a1
 move #7999,d7
.erc
 move.l -(a0),-(a1)
 dbra d7,.erc

 jsr calc_hard
 bsr masque_bar

 clr.b $fffffa07.w
 clr.b $fffffa09.w
*
 lea sequence,a0
 move (a0)+,nb_map * combien de map en tout

 ifeq finale
 clr map_courrante
 move #-1,map_precedante
 move #-1,xecran
 clr cheat
 
 endc
*xecran_anc
*sens_spr
*sens_spr_new
*xecran
*map_courrante
*map_precedante

 move.l #dragon_merde,s_adr_dragon
 move.l #rte,$70.w
 move #$2300,sr



.boucle
 move.l #rte,$70.w
 stop #$2300
 move.l #$08080000,$ffff8800.w
 move.l #$09090000,$ffff8800.w
 move.l #$0a0a0000,$ffff8800.w
 stop #$2300
 clr.b $ffff820a.w
 stop #$2300
 move.b #2,$ffff820a.w
 lea $ffff8240.w,a0
 moveq #7,d7
.clt
 clr.l (a0)+
 dbra d7,.clt
 
 lea precaclgfx,a0
 move.l a0,d1
 st d1
 addq.l #1,d1
 lea $ffff8201.w,a6
 lsr.l #8,d1
 movep d1,(a6)

 lea precaclpal,a0
 moveq #15,d0
.yoi0
 stop #$2300
 stop #$2300
 movem.l (a0)+,d1-d7/a1
 movem.l d1-d7/a1,$ffff8240.w
 dbra d0,.yoi0 



 move.l #buf_save,adr_save
 clr n_anim_dragon
 move #vitesse_spr,vit_spr_cpt


* clear_screen
 lea ecrans,a0
 lea fecrans,a1
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 move.l d7,a2
 move.l d7,a3
 move.l d7,a4
 move.l d7,a5
 move.l d7,a6
.clear_screen
 movem.l d1-d7/a2-a6,(a0)
 movem.l d1-d7/a2-a6,12*4(a0)
 movem.l d1-d7/a2-a6,24*4(a0)
 movem.l d1-d7/a2-a6,36*4(a0)
 lea 12*4*4(a0),a0
 cmp.l a1,a0
 blt.s .clear_screen


*
 lea sequence+2,a0
 move map_courrante,d0
 mulu #7*4,d0
 add d0,a0
 move.l (a0)+,adr_zik
 move.l (a0)+,adr_map
 move.l (a0)+,adr_map_msg
 move.l (a0)+,adr_msg
 move.l (a0)+,adr_raster
 move.l (a0)+,adr_decor
 move.l (a0)+,a1
 move.l a1,pal_scroll
 lea 16*32+4(a1),a1
 move.l a1,pal_spr
 move.l #adr_pal_barriere+4,pal_barriere

 jsr prepare_map
 move.l adr_zik,a0
 jsr (a0)




 lea precaclpal+15*32,a0
 moveq #15-1,d0
.yoi1
 stop #$2300
 stop #$2300
 movem.l (a0),d1-d7/a1
 movem.l d1-d7/a1,$ffff8240.w
 lea -32(a0),a0
 dbra d0,.yoi1

 move.l s_adr_dragon,a0
 moveq #19,d0
 moveq #0,d1
.cf
 move d1,-8(a0)
 move d1,(a0)
 move d1,8(a0)
 move d1,16(a0)
 move d1,24(a0)
 move d1,32(a0)
 lea 230(a0),a0
 dbra d0,.cf
 move.l #dragon_merde,s_adr_dragon

 st aff_pr
 stop #$2300
 move.l #routine_vbl,$70.w
 st aff_pr
 stop #$2300
 st aff_pr
 bsr deg0
 st aff_pr
.wait
 stop #$2300
 tst.b exit_flag
 beq.s .wait
 bmi.s .casse_toi
 btst #7,n_nmsg
 bne.s .casse_toi
 sf exit_flag
 bra.s .wait
.casse_toi

 bsr deg1
 move map_courrante,map_precedante

 move nb_map,d1
 move.b exit_flag,d0
 cmp.b #-2,d0
 bne.s .pas_ajcarte
 cmp map_courrante,d1
 beq .boucle
 addq #1,map_courrante
 bra .boucle
.pas_ajcarte
 cmp.b #-1,d0
 bne.s .pas_deccarte
 tst map_courrante
 beq .boucle
 subq #1,map_courrante
 bra .boucle
.pas_deccarte
 
 move #$2700,sr
 move.l #$08080000,$ffff8800.w
 move.l #$09090000,$ffff8800.w
 move.l #$0a0a0000,$ffff8800.w
*
 jsr restore
 ifeq finale
 move.l s_a7,a7
 move.l s_usp,a0
 move.l a0,usp
 move s_sr,sr 
 rts
 elseif
 move #$2700,sr
 moveq #0,d0
 move.b exit_flag,d0
 subq #1,d0
 jmp $1002.w
 endc

 
save
 lea s_mfp,a0
 move.b $fffffa07.w,(a0)+
 move.b $fffffa09.w,(a0)+
 move.b $fffffa0b.w,(a0)+
 move.b $fffffa0d.w,(a0)+
 move.b $fffffa0f.w,(a0)+
 move.b $fffffa11.w,(a0)+
 move.b $fffffa13.w,(a0)+
 move.b $fffffa15.w,(a0)+
 move.b $fffffa17.w,(a0)+
 move.b $fffffa19.w,(a0)+
 move.b $fffffa1b.w,(a0)+
 move.b $fffffa1d.w,(a0)+
 move.b $fffffa1f.w,(a0)+
 move.b $fffffa21.w,(a0)+
* 14 
 move.l $70.w,(a0)+
 move.l $134.w,(a0)+
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,(a0)
 lea 32(a0),a0
 rts

restore
 lea s_mfp,a0
 move.b (a0)+,$fffffa07.w
 move.b (a0)+,$fffffa09.w
 move.b (a0)+,$fffffa0b.w
 move.b (a0)+,$fffffa0d.w
 move.b (a0)+,$fffffa0f.w
 move.b (a0)+,$fffffa11.w
 move.b (a0)+,$fffffa13.w
 move.b (a0)+,$fffffa15.w
 move.b (a0)+,$fffffa17.w
 move.b (a0)+,$fffffa19.w
 move.b (a0)+,$fffffa1b.w
 move.b (a0)+,$fffffa1d.w
 move.b (a0)+,$fffffa1f.w
 move.b (a0)+,$fffffa21.w
* 14 
 move.l (a0)+,$70.w
 move.l (a0)+,$134.w
 movem.l (a0)+,d0-d7
 movem.l d0-d7,$ffff8240.w
 rts

masque_bar
 lea barrier0,a0
 lea masque0,a1
 bsr msq
 lea barrier1,a0
 lea masque1,a1
 bsr msq
 rts
msq
 move #52*11-1,d7
.msq
 move (a0)+,d0
 or (a0)+,d0
 or (a0)+,d0
 or (a0)+,d0
 not d0
 move d0,(a1)+
 dbra d7,.msq
 rts

deg0
 moveq #15-1,d7
.deg
 stop #$2300
 stop #$2300
 add.l #32,pal_scroll
 add.l #32,pal_barriere
 add.l #32,pal_spr
 add.l #nombre_couleurs*2,source_rst
 cmp.l #palfont+15*32,pal_font
 bge.s .ohk
 add.l #32,pal_font
.ohk
 dbra d7,.deg
 rts

deg1
 moveq #15-1,d7
.deg
 stop #$2300
 stop #$2300
 sub.l #32,pal_scroll
 sub.l #32,pal_barriere
 sub.l #32,pal_spr
 sub.l #nombre_couleurs*2,source_rst
 cmp.l #palfont,pal_font
 ble.s .oaui
 sub.l #32,pal_font
.oaui
 dbra d7,.deg
 rts

*routine de degrade ...
calcule_offsets_fading
 move.l #source,source_rst
 move.l adr_raster,a0
 lea dest,a1
 move #nombre_couleurs-1,d7
.hy
 move (a0)+,(a1)+
 dbra d7,.hy

 lea source,a0
 lea dest,a1
 lea offsets,a2           Buffers pour les offsets
 lea table_to_stf,a3      Table de conversion
 lea x_source,a4          Palette source d‚compos‚e en (R.l)+(V.l)+(B.l)
 move #nombre_couleurs-1,d7
offset_couleur_suivante
 move (a0)+,d0
 move d0,d2
 and #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5       Bleu de d‚part
 swap d5
 move.l d5,(a4)+
 move (a1)+,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6       Bleu d'arriv‚e
 swap d6   
 sub.l d5,d6
 asr.l #4,d6               Offset bleu
 move.l d6,(a2)+
 
 lsr #4,d0
 move d0,d2
 and.w #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5       Vert de d‚part
 swap d5
 move.l d5,(a4)+
 lsr #4,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6       Vert d'arriv‚e
 swap d6
 sub.l d5,d6
 asr.l #4,d6               Offset vert
 move.l d6,(a2)+

 lsr #4,d0
 move d0,d2
 and #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5       Rouge de d‚part
 swap d5
 move.l d5,(a4)+
 lsr #4,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6       Rouge d'arriv‚e
 swap d6
 sub.l d5,d6
 asr.l #4,d6               Offset rouge
 move.l d6,(a2)+
    
 dbra d7,offset_couleur_suivante 

;#######################
; Puis le fading lui meme
;#######################

calcule_fading_palette
 lea x_source,a0
 lea source,a1        Palette source
 lea offsets,a2
 lea table_to_ste,a3
 move #nombre_couleurs,compteur_couleur
couleur_suivante
 move.l a1,a4
 addq.w #2,a1
 move.l (a2)+,d0      Incr‚ment Bleu
 move.l (a2)+,d1      Incr‚ment Vert
 move.l (a2)+,d2      Incr‚ment Rouge
 move.l (a0)+,d3      Courant Bleu
 move.l (a0)+,d4      Courant Vert
 move.l (a0)+,d5      Courant Rouge
 move #16,compteur_phase
degr‚_suivant
 moveq #0,d7
 swap d5
 move.b (a3,d5.w),d6   Rouge converti en STE
 move.b d6,d7
 lsl #4,d7
 swap d5

 swap d4
 move.b (a3,d4.w),d6   Vert converti en STE
 or.b d6,d7
 lsl #4,d7
 swap d4

 swap d3
 move.b (a3,d3.w),d6   Bleu converti en STE
 or.b d6,d7
 swap d3
 move.w d7,(a4)       On sauve dans le buffer
 lea nombre_couleurs*2(a4),a4

 add.l d0,d3
 add.l d1,d4
 add.l d2,d5
    
 subq.w #1,compteur_phase
 bne degr‚_suivant
 subq.w #1,compteur_couleur
 bne couleur_suivante
 rts
   
compteur_couleur ds.w 1
compteur_phase   ds.w 1


table_to_stf
 dc.b 0
 dc.b 2
 dc.b 4
 dc.b 6
 dc.b 8
 dc.b 10
 dc.b 12
 dc.b 14
 dc.b 1
 dc.b 3
 dc.b 5
 dc.b 7
 dc.b 9
 dc.b 11
 dc.b 13
 dc.b 15


table_to_ste
 dc.b 0
 dc.b 8
 dc.b 1
 dc.b 9
 dc.b 2
 dc.b 10
 dc.b 3
 dc.b 11
 dc.b 4
 dc.b 12
 dc.b 5
 dc.b 13
 dc.b 6
 dc.b 14
 dc.b 7
 dc.b 15

 even


prepare_map
 clr nmsg
 clr n_nmsg
 jsr aff_block
 jsr prepare_msg
 jsr calcule_offsets_fading
 rts

rck dc.b " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?(),-",0
 even
prepare_msg
 lea buf_txt,a6
 move.l adr_msg,a1
 move (a1)+,d7
.loop0
*
 move.l a6,a5
 moveq #20-1,d6
.loop1
 moveq #0,d0
 lea beast_font,a0
 move.b (a1)+,d0
 lea rck,a2
.lok
 move.b (a2)+,d1
 beq.s .ark
 cmp.b d0,d1
 bne.s .lok
 sub.l #rck+1,a2
 move a2,d0
 bra.s .ark1
.ark
 moveq #0,d0
.ark1
* moveq #2,d0
 mulu #8*6,d0
 add.l d0,a0
 move.l a5,a4
 moveq #6-1,d5
.loop2
 move.l (a0)+,(a4)
 move.l (a0)+,4(a4)
 lea 160(a4),a4
 dbra d5,.loop2
 addq #8,a5
 dbra d6,.loop1
*
 lea 160*6(a6),a6
 dbra d7,.loop0
 rts

predecale_block
* a0
 lea block0,a1
 moveq #nb_block-1,d7
.loop0a
 move d7,-(sp)
 moveq #15,d7
.loop0
 move.l a1,a2
 movem (a0)+,d0-d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #7,d6
.loop1
 lsr d0
 roxr d3
 lsr d0
 roxr d3
*
 lsr d1
 roxr d4
 lsr d1
 roxr d4
*
 lsr d2
 roxr d5
 lsr d2
 roxr d5
 exg d2,d3
 movem d0-d5,(a2)
 exg d2,d3
 lea block1-block0(a2),a2
 dbra d6,.loop1
 lea 12(a1),a1
 dbra d7,.loop0
 move (sp)+,d7
 dbra d7,.loop0a
 rts

* a6 *map
* d0 nb block en longueur
aff_block
 move.l adr_map,a1
 move.l adr_decor,a0
* mulu #nb_block*16*6,d0
* add d0,a0
 bsr predecale_block


 lea mul_192,a5
 move.l adr_map,a6
 move (a6)+,d0
 move d0,d1
 sub #26,d1
 lsl #3,d1
 move d1,max_xecran


**********************
* test selon la map precedante ou il doit ce trouver maintenant
* ce putain de shadow ....
 move d0,-(sp)
 clr exit_flag
 move map_precedante,d0
 cmp map_courrante,d0
 bgt.s .oui
 bne.s .pas_tyu
 tst xecran
 bge.s .ayj
.pas_tyu
 move #-1,xecran_anc
 move #-1,sens_spr
 move #1,sens_spr_new
 move #8*pos_x_depart,xecran
.ayj
 clr offset_sprite
 st aff_pr
 bra.s .non 
.oui
 move #-1,sens_spr
 move #-1,sens_spr_new
 move #-1,xecran_anc
 move max_xecran,d0
 sub #(26-11+pos_x_depart)*8,d0
 move d0,xecran
 move #1248*7,offset_sprite
 st aff_pr
.non
 move (sp)+,d0
***********************

 lea block0,a0
 move.l adr_buf,a1
 move.l a6,-(sp)
 bsr aff
 move.l (sp)+,a6

 lea block1,a0
 move.l adr_buf+4,a1
 move.l a6,-(sp)
 bsr aff
 move.l (sp)+,a6

 lea block2,a0
 move.l adr_buf+8,a1
 move.l a6,-(sp)
 bsr aff
 move.l (sp)+,a6

 lea block3,a0
 move.l adr_buf+12,a1
 move.l a6,-(sp)
 bsr aff
 move.l (sp)+,a6

 lea block4,a0
 move.l adr_buf+16,a1
 move.l a6,-(sp)
 bsr aff
 move.l (sp)+,a6

 lea block5,a0
 move.l adr_buf+20,a1
 move.l a6,-(sp)
 bsr aff
 move.l (sp)+,a6

 lea block6,a0
 move.l adr_buf+24,a1
 move.l a6,-(sp)
 bsr aff
 move.l (sp)+,a6

 lea block7,a0
 move.l adr_buf+28,a1
 bsr aff
 rts

aff_lignev
 moveq #0,d4
 lea mul_192,a5
 lea 230*2(a1),a1
 clr.l -230(a1)
 clr.l -230+4(a1)
 subq #1,d0
 moveq #9-1,d6
.boucle

 moveq #0,d1
 move.b (a6)+,d1
 move.l a0,a2
 add d1,d1
 add (a5,d1),a2

 rept 16
 movem.l (a2)+,d1-d3
 move d4,(a1)+
 or.l d1,(a1)+
 or d2,(a1)+
 swap d2
 move d4,(a1)+
 move d2,(a1)+
 move.l d3,(a1)+
 lea 230-16(a1),a1
 endr

 add d0,a6
 dbra d6,.boucle
 rts

aff_lignev1
* illegal
 moveq #0,d4
 lea mul_192,a5
 lea 230*2(a1),a1
 moveq #9-1,d6
 subq #1,d0
.boucle

 moveq #0,d1
 move.b (a6)+,d1
 move.l a0,a2
 add d1,d1
 add (a5,d1),a2

 rept 16
 movem.l (a2)+,d1-d3
 move d4,(a1)+
 move.l d1,(a1)+
 move d2,(a1)+
 swap d2
 move d4,(a1)+
 or d2,(a1)+
 or.l d3,(a1)+
 lea 230-16(a1),a1
 endr

 add d0,a6
 dbra d6,.boucle
 clr.l (a1)+
 clr.l (a1)+
 rts


aff
 move xecran,d6
 move d6,d7
 lsr #3,d7
 add d7,a6  * et si...
 and #$7ff8,d6
 add d6,a1
 moveq #0,d4
 lea 230*2(a1),a1
 moveq #9-1,d6
.boucle
 moveq #26-1,d7
 move.l a1,a3

.boucle1
 moveq #0,d1
 move.b (a6)+,d1
 move.l a0,a2
 add d1,d1
 add (a5,d1),a2
*
 moveq #15,d5
.boucle2
 movem.l (a2)+,d1-d3
 move d4,(a3)+
 or.l d1,(a3)+
 or d2,(a3)+
 swap d2
 move d4,(a3)+
 move d2,(a3)+
 move.l d3,(a3)+
 lea 230-16(a3),a3
 dbra d5,.boucle2

*
 lea -230*16+8(a3),a3
 dbra d7,.boucle1
 lea -26(a6),a6
 add d0,a6
 lea 230*16(a1),a1
 dbra d6,.boucle
 rts

go_herbe_droite
 lea data_herbe+2,a0
 lea mul_2720,a1
 move #nb_bande-1,d7
.loop
 moveq #0,d0
 moveq #0,d1
 move (a0)+,d0
 move (a0),d1
 add d0,d1
 cmp #320,d1
 blt.s .okau
 sub #320,d1
.okau
 move d1,(a0)+
 move d1,d0
 and #$f,d1
 lsr #4,d0
 add d0,d0
 add d1,d1
 add d1,d1
 add.l (a1,d1.w),d0
 move.l d0,(a0)+
 addq #2,a0
 dbra d7,.loop
 rts

go_herbe_gauche
 lea data_herbe+2,a0
 lea mul_2720,a1
 move #nb_bande-1,d7
.loop
 moveq #0,d0
 moveq #0,d1
 move (a0)+,d0
 move (a0),d1
 sub d0,d1
 tst d1
 bge.s .okau
 add #320,d1
.okau
 move d1,(a0)+
 move d1,d0
 and #$f,d1
 lsr #4,d0
 add d0,d0
 add d1,d1
 add d1,d1
 add.l (a1,d1.w),d0
 move.l d0,(a0)+
 addq #2,a0
 dbra d7,.loop
 rts

routine_vbl
 move.w #$2700,sr
******************

 movem.l d0-a6,-(sp)

* pour l'instant le clavier est ici ...
 move xecran_anc,xecran_anc1
 move xecran,xecran_anc
* btst #0,$fffffc00.w
* beq .pas_clavier
 move.b $fffffc02.w,d0 
 cmp.b #$1c,d0
 beq .si_sorti
 cmp.b #$72,d0
 beq .si_sorti
 cmp.b #$39,d0
 bne .aps_sorti
.si_sorti
 move.b n_nmsg,d0
 and #$7f,d0
 move.b d0,exit_flag
 bra .pas_clavier
.aps_sorti

 cmp.b #$4b,d0
 bne.s .pas_g
 move sens_spr_new,d0
 move #-1,sens_spr_new
 cmp #-1,d0
 bne .pas_clavier
 moveq #5,d1
 move xecran,d0
 cmp d1,d0
 bgt.s .suite_sub
 btst #7,n_nmsg
 beq .pas_clavier
 move.b #-1,exit_flag
 bra .pas_clavier
.suite_sub
 subq #1,xecran
 bra .pas_clavier
.pas_g

 cmp.b #$4d,d0
 bne.s .pas_d
 move sens_spr_new,d0
 move #1,sens_spr_new
 cmp #1,d0
 bne .pas_clavier
 move xecran,d0
 move max_xecran,d1
 subq #3,d1
 cmp d1,d0
 blt.s .suite_addq
 btst #7,n_nmsg
 beq .pas_clavier
 move.b #-2,exit_flag
 bra .pas_clavier
.suite_addq
 addq #1,xecran
 bra .pas_clavier
.pas_d

 cmp #7,cheat
 bne.s .pas_mapp
* eor #$3,$ffff8240.w
 cmp.b #$3c,d0
 bne.s .pas_maps
 move nb_map,d1
 cmp map_courrante,d1
 beq .pas_clavier
 move.b #-2,exit_flag
 bra.s .pas_clavier
.pas_maps

 cmp.b #$3b,d0
 bne.s .pas_mapp
 tst map_courrante
 beq .pas_clavier
 move.b #-1,exit_flag
 bra.s .pas_clavier
.pas_mapp

 cmp.b #$62,d0
 bne.s .pas_undo
 or #1,cheat
* eor #$70,$ffff8240.w
 bra .pas_clavier
.pas_undo

 cmp.b #$61,d0
 bne.s .pas_help
 or #%10,cheat
* eor #$700,$ffff8240.w
 bra .pas_clavier
.pas_help

 cmp.b #$44,d0
 bne.s .pas_f10
 or #%100,cheat
* eor #$7,$ffff8240.w
 bra .pas_clavier
.pas_f10

.pas_clavier
 moveq #0,d1
 move xecran_anc,d1
 lsr #3,d1
 lsl #3,d1
 move.l buf1,d0
 add.l d1,d0
 move.l d0,buf1
 move.l d0,a0
 move.l a0,usp

*** maintenant eclate la ligne du bas pendant le changement de couleur en noir
* en ligne 180
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 move.l d7,a2
 move.l d7,a3
 move.l d7,a4
 move.l d7,a5

* move.l usp,a1
* add.l #186*230+48*4,a1
* movem.l d0-d7/a2-a5,-(a1)
* movem.l d0-d7/a2-a5,-(a1)
* movem.l d0-d7/a2-a5,-(a1)
* movem.l d0-d7/a2-a5,-(a1)

 move.l usp,a1
 lea 230(a1),a1
 movem.l d0-d7/a2-a5,-(a1)
 movem.l d0-d7/a2-a5,-(a1)
* movem.l d0-d7/a2-a5,-(a1)
* movem.l d0-d7/a2-a5,-(a1)
*
* maintenant juste audessus de la barriere
* move.l usp,a1
* add.l #208-8,a1
* move.l d0,(a1)+
* move.l d0,(a1)+
* move.l d0,(a1)+
* movem.l d0-d7/a2-a5,-(a1)
* movem.l d0-d7/a2-a5,-(a1)

***
 move xecran_anc,d0
 cmp xecran_anc1,d0
 beq .pas_bouge
 blt .bouge_gauche
* a droite
 move.l adr_map,a6
 move (a6)+,d0
 move xecran_anc,d1
 lsr #3,d1
 add d1,a6
 lea 25(a6),a6
 move.l usp,a1
 lea 25*8(a1),a1
 lea adrblock,a0
 move xecran_anc,d1
 and #$7,d1
 neg d1
 addq #7,d1
 add d1,d1
 add d1,d1
 add d1,a0
 move.l (a0),a0
 jsr aff_lignev
 bsr go_herbe_droite
 addq #1,x_monts
 cmp #320,x_monts
 blt.s .pas_bouge
 sub #320,x_monts
 bra .pas_bouge

.bouge_gauche
* a gauche
 move.l adr_map,a6
 move (a6)+,d0
 move xecran_anc,d1
 lsr #3,d1
 add d1,a6
 move.l usp,a1
 lea adrblock,a0
 move xecran_anc,d1
 and #$7,d1
 neg d1
 addq #7,d1
 add d1,d1
 add d1,d1
 add d1,a0
 move.l (a0),a0
 jsr aff_lignev1

 bsr go_herbe_gauche
 subq #1,x_monts
 tst x_monts
 bge.s .pas_bouge
 add #320,x_monts
.pas_bouge


*** operation de calcul pour la barriere
 move.l usp,a1
 add.l #165*230,a1
 lea barrier0,a0
 move xecran_anc,d0
* bit 0 ou 1 pour le decalage de 8 pixels
 lsr d0
 bcs.s .pas_decalage
 lea barrier1,a0
.pas_decalage
 divu #26,d0
 swap d0
 lsl #3,d0
 add d0,a0
 move.l a0,adr_bar
 tst aff_pr
 bne.s .boucge
 move xecran_anc,d0
 cmp xecran_anc1,d0
 bne .boucge
 lea vide,a1
.boucge
 move.l a1,adr_ecr

 tst aff_pr
 bne.s .yo0
 move xecran_anc,d0
 cmp xecran_anc1,d0
 beq .pas_herbe_00
.yo0
*** herbe
 move.l usp,a1
 add.l #(2+16*8+12+1)*230,a1
 lea data_herbe,a6
 lea herbe,a2
 moveq #0,d6
 move (a6)+,d7
 move.l a2,a0
 addq #4,a6
 add.l (a6)+,a0
.herbe0
 move 2(a1),d1
 or 4(a1),d1
 or 6(a1),d1
 not d1
 move (a0)+,d0
 move d0,d2
 and d1,d0
 move d0,(a1)
 move 160+2(a1),d1
 or 160+4(a1),d1
 or 160+6(a1),d1
 not d1
 and d1,d2
 move d2,160(a1)
x set 8
 move (a0)+,d0
 move d0,d2
 move 2+x(a1),d1
 or 4+x(a1),d1
 or 6+x(a1),d1
 not d1
 and d1,d0
 move d0,x(a1)
 move 162+x(a1),d1
 or 164+x(a1),d1
 or 166+x(a1),d1
 not d1
 and d1,d2
 move d2,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,d2
 move 2+x(a1),d1
 or 4+x(a1),d1
 or 6+x(a1),d1
 not d1
 and d1,d0
 move d0,x(a1)
 move 162+x(a1),d1
 or 164+x(a1),d1
 or 166+x(a1),d1
 not d1
 and d1,d2
 move d2,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,d2
 move 2+x(a1),d1
 or 4+x(a1),d1
 or 6+x(a1),d1
 not d1
 and d1,d0
 move d0,x(a1)
 move 162+x(a1),d1
 or 164+x(a1),d1
 or 166+x(a1),d1
 not d1
 and d1,d2
 move d2,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,d2
 move 2+x(a1),d1
 or 4+x(a1),d1
 or 6+x(a1),d1
 not d1
 and d1,d0
 move d0,x(a1)
 move 162+x(a1),d1
 or 164+x(a1),d1
 or 166+x(a1),d1
 not d1
 and d1,d2
 move d2,160+x(a1)
x set x+8
 move (a0)+,d0
 move d0,d2
 move 2+x(a1),d1
 or 4+x(a1),d1
 or 6+x(a1),d1
 not d1
 and d1,d0
 move d0,x(a1)
 move 162+x(a1),d1
 or 164+x(a1),d1
 or 166+x(a1),d1
 not d1
 and d1,d2
 move d2,160+x(a1)
x set x+8
 rept 14
 move (a0)+,d0
 move 2+x(a1),d1
 or 4+x(a1),d1
 or 6+x(a1),d1
 not d1
 and d1,d0
 move d0,x(a1)
x set x+8
 endr
 lea 230(a1),a1
 lea 80(a2),a2
 lea 40(a0),a0
 dbra d7,.herbe0

 rept 7-3-2
 aff_bande
 endr
 move.l a1,suite_ecr_herbe
 move.l a2,suite_gfx_herbe
 move.l a6,suite_data_herbe
.pas_herbe_00


 tst sens_spr_new
 bmi.s .gauche_spr
** gestion du mouvement du shadow
 tst sens_spr
 bgt.s .deja_d
 clr offset_sprite
.deja_d
 move xecran_anc,d0
 cmp xecran_anc1,d0
 beq .bouge_pas
 subq #1,vit_spr_cpt
 tst vit_spr_cpt
 bgt .fin_gere
 move #vitesse_spr,vit_spr_cpt
 cmp #1248*5,offset_sprite
 ble.s .oufd
 clr offset_sprite
.oufd
 add #1248,offset_sprite
 move #1,sens_spr
 bra .fin_gere
.bouge_pas  
 clr vit_spr_cpt
 clr offset_sprite
 move #1,sens_spr
 bra.s .fin_gere

** gestion du mouvement du shadow a gauche
.gauche_spr
 tst sens_spr
 bmi.s .deja_g
 move #1248*7,offset_sprite
.deja_g
 move xecran_anc,d0
 cmp xecran_anc1,d0
 beq .bouge_pasg
 subq #1,vit_spr_cpt
 tst vit_spr_cpt
 bgt.s .fin_gere
 move #vitesse_spr,vit_spr_cpt
 cmp #1248*(7+5),offset_sprite
 ble.s .oufdg
 move #1248*7,offset_sprite
.oufdg
 add #1248,offset_sprite
 move #-1,sens_spr
 bra.s .fin_gere
.bouge_pasg
 move #-1,sens_spr
 clr vit_spr_cpt
 move #1248*7,offset_sprite
.fin_gere
 move sens_spr_new,sens_spr


* dragon
 move n_anim_dragon,d0
 addq #1,d0
 cmp #4*15,d0
 blt.s .okay_anim
 moveq #0,d0
.okay_anim
 move d0,n_anim_dragon
 lsr #2,d0
 lea dragon,a0
 lea mul_160,a1
 add d0,d0
 add d0,a1
 add (a1),a0

 move x_dragon,d1
 addq #1,d1
 cmp #(26+3)*16,d1
 blt.s .ouf
 moveq #0,d1
.ouf
 move d1,x_dragon
 move d1,d0
 and #$f,d0
 lsr #4,d1
*
 lea mul_2560,a1
 add d0,d0
 add d0,d0
 add d0,a1
 add.l (a1),a0


 move.l a0,adr_gfx_dragon

 move.l usp,a0
 lea 230*5(a0),a0
 move d1,d0
 subq #3,d1
 asl #3,d1
 tst d1
 bge.s .oi
 moveq #0,d1
.oi
 add d1,a0
 move.l a0,adr_ecr_dragon

 lea tab_aff_dragon,a1
 add d0,d0
 add d0,d0
 add d0,a1
 move.l (a1),a0

 lea af_dragon,a1
x set 2
 rept 10
 move.l a0,x(a1)
x set x+6
 endr

 ifne tempo
 eor #$777,$ffff8240.w
 pause 10
 eor #$777,$ffff8240.w
 endc



******* fini
 clr.b $fffffa19.w
 clr.b $fffffa07.w
 lea $ffff8260.w,a0
 lea $ffff820a.w,a1
 moveq #0,d0
 moveq #2,d1

 moveq #16,d2
.syncro
 move.b $ffff8209.w,d3   ; syncro
 beq.s .syncro
 sub.b d3,d2
 lsl.b d2,d3
 dcb 96-4-(5+8*2+2),$4e71
*5+2n
pal_scroll = *+4
 movem.l $7894562,d2-d7/a2-a3
 lea $ffff8240.w,a4
 opt o-
jsr_hard
 rept 6
 jsr 0
 endr
 move.l d2,(a4)+
 nop
*********** debut
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 pause 89
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11

 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
*2+2n
 pause 89-(2+7*2)-5
 move.l a7,s_pile
 movem.l d3-d7/a2-a3,(a4)
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13-5
 lea $ffff8240.w,a3
source_rst =*+2
 lea source,a2
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11-6
* init affichage barriere
adr_ecr = *+2
 lea $7894562,a5
adr_bar = *+2
 lea $7894562,a4

 include aff_barr.s  *10*5+3 hbl
* finde la derniere hbl .... init pour le sprite
 pause 40-(1+2+4+1+2+3+1+1+2+3+3+2+4+1+2)
 move.l usp,a5
 lea 230*59(a5),a5
 move x_monts,d2
 move d2,d3
 and #$f,d2
 lea mul_3200,a4
 add d2,d2
 add d2,d2
 add d2,a4
 move.l (a4),d2
 lea montagnes,a4
 add.l d2,a4
 lsr #4,d3
 add d3,d3
 add d3,a4
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11


 rept 40
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem (a4)+,d2-d7
 move d2,(a5)

 move d2,160(a5)
 move d3,8(a5)
 move d3,168(a5)
 move d4,16(a5)
 move d4,176(a5)
 move d5,24(a5)
 move d5,184(a5)
 move d6,32(a5)
 move d6,192(a5)
 move d7,40(a5)
 move d7,200(a5)
 move (a4)+,48(a5)
 move (a4)+,56(a5)
 move (a4)+,64(a5)
 move (a4)+,72(a5)
 move (a4)+,80(a5)
 move (a4)+,88(a5)
 move (a4)+,96(a5)
 move (a4)+,104(a5)
 move (a4)+,112(a5)
 move (a4)+,120(a5)
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 move (a4)+,128(a5)
 move (a4)+,136(a5)
 move (a4)+,144(a5)
 pause 1
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 move (a4)+,152(a5)
 lea 230(a5),a5
 lea 40(a4),a4
 pause 3
 endr
 
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 pause 84
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11-5-5
 move.l s_pile,a7
 rept 4-1
 jsr full_normal
 endr
 pause 5




***** changement de couleur pour le shadow ...
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 pause 84-(5+14)
*5+6
pal_spr=*+4
 movem.l pal_chateau+4+16*32,d2-d7/a4
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 4
 movem.l d2-d4,$ffff8244.w
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 movem.l d5-d7/a4,($ffff8244+3*4).w


 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 pause 84
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11-5-5
 move.l s_pile,a7
 rept 10
 jsr full_normal
 endr
 pause 5


 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 pause 84-1-2-3-5-5-3-(5)
 move.l usp,a5
 lea 230*100+8*12(a5),a5
 lea sprited,a4
 add offset_sprite,a4
 move.l adr_save,a7
 move.l a5,adr_save
 lea buf_save,a6
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11

* affichage de la bete
 rept 52
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem.l (a6)+,d2-d5
 movem.l d2-d5,(a7)
 movem.l (a5),d2-d5
 movem.l d2-d5,-8*2(a6)

 move.l (a4)+,d6
 and.l d6,d2
 and.l d6,d3
 or.l (a4)+,d2
 or.l (a4)+,d3
 move.l (a4)+,d6
 and.l d6,d4
 and.l d6,d5
 or.l (a4)+,d4
 or.l (a4)+,d5
 movem.l d2-d5,(a5)
 pause 1
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 lea 230(a5),a5
 lea 230(a7),a7
 pause 13-4
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11
 endr






***** changement de couleur pour la barriere
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 pause 84-(5+14)
*5+6
pal_barriere=*+4
 movem.l adr_pal_barriere+4,d2-d7/a4
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 4
 movem.l d2-d4,$ffff8244.w
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 movem.l d5-d7/a4,($ffff8244+3*4).w


* 64 *20 dragon
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 pause 84-6-5
adr_gfx_dragon = *+2
 lea dragon,a4
adr_ecr_dragon = *+2
 lea $78942,a5
 move.l s_pile,a7
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13-10
 move.l s_adr_dragon,a6
 move.l a5,s_adr_dragon
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11-5
af_dragon
 rept 10
 jsr aff_dragon_0
 endr


 rept 10
 jsr full_normal
 endr
 
 pause 5


 rept 8
 move.l d0,(a3)+
 endr


* gestion du degrade de la font.....
 move deg_fnt,d0
 beq.s .rien
 bmi.s .degv
 cmp.l #palfont+15*32,pal_font
 bge.s .saj
 add.l #32,pal_font
.saj
 subq #1,deg_fnt
 bra.s .rien
.degv
 cmp.l #palfont,pal_font
 ble.s .sde
 sub.l #32,pal_font
.sde
 addq #1,deg_fnt
 bne.s .rien
 move n_nmsg,nmsg
 move #16,deg_fnt
.rien
 move.l adr_map_msg,a1
 move xecran_anc,d0
 lsr #3,d0
 add d0,a1
 lea 13(a1),a1
 moveq #0,d0
 move.b (a1),d0
 move d0,d1
 and #$7f,d1
 move.b n_nmsg,d2
 and #$7f,d2
 cmp.b d2,d1
 beq.s .meme
 move #-15,deg_fnt
.meme
 move.b d0,n_nmsg
 move.b nmsg,d0
 and #$7f,d0
 lea mul_960,a0
 add d0,d0
 add d0,d0
 add d0,a0
 move.l (a0),d0
 lea buf_txt,a0
 add.l d0,a0
 move.l usp,a1
 add.l #186*230+160,a1


*** intermede degrade
pal_font =*+4
 movem.l palfont,d0-d7
 movem.l d0-d7,$ffff8240.w
**** yeh !

x set 0
 rept 20
 movem.l (a0)+,d0-d7/a2-a5
 movem.l d0-d7/a2-a5,x(a1)
x set x+12*4
 endr

 moveq #0,d0
 lea $ffff8240.w,a0
 rept 8
 move.l d0,(a0)+
 endr
 ifne tempo
 eor #$7,$ffff8240.w
 endc



 move xecran,d0
 cmp xecran_anc,d0
 bne .dragon_aff
 tst.b aff_pr
 bne.s .dragon_aff
 move.l #dragon_merde,s_adr_dragon
.dragon_aff

 tst aff_pr
 bne.s .yo1
 move xecran_anc,d0
 cmp xecran_anc1,d0
 beq .pas_herbe
.yo1
*** herbe
suite_ecr_herbe =*+2
 lea $92000,a1
suite_data_herbe =*+2
 lea data_herbe,a6
suite_gfx_herbe =*+2
 lea herbe,a2
 moveq #0,d6

 rept 1+1
 aff_bande
 endr
 lea masque0,a3
 move xecran_anc,d0
* bit 0 ou 1 pour le decalage de 8 pixels
 lsr d0
 bcs.s .pas_decalage
 lea masque1,a3
.pas_decalage
 divu #26,d0
 swap d0
 add d0,d0
 add d0,a3
 rept 2
 aff_and_bande
 endr
* bra .herbec
.pas_herbe
*.herbec

* music
 move.l adr_zik,a0
 jsr 34(a0)

****** changement d'ecran et calcul du hard ....
 jsr calc_hard

 clr aff_pr
 movem.l (sp)+,d0-a6
 ifne tempo
 eor #$7,$ffff8240.w
 endc
 rte
rte
 clr.b $ffff8260.w
 rte
 include hard1.s

 even
full_normal
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 pause 84
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11-4-5
 rts


aff_dragon_0
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem (a4)+,d2-d5 *3+4
 move d2,(a5)      *2
 move d3,8(a5)     *3
 move d4,16(a5)    *3
 move d5,24(a5)    *3  = 21
 move d0,(a6)
 move d0,8(a6)
 move d0,16(a6)
 move d0,24(a6)
* 29

 movem (a4)+,d2-d5 *3+4
 move d2,230(a5)      *2
 move d3,230+8(a5)     *3
 move d4,230+16(a5)    *3
 move d5,230+24(a5)    *3  = 21
 move d0,230(a6)
 move d0,230+8(a6)
 move d0,230+16(a6)
 move d0,230+24(a6)
*31
 lea 230*2(a5),a5
 lea 230*2(a6),a6
 pause 24-4
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 2
 rts

aff_dragon_1
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem (a4)+,d2-d5 *3+4
 move d5,(a5)    *3  = 21
 move d0,(a6)
* 29

 movem (a4)+,d2-d5 *3+4
 move d5,230(a5)    *3  = 21
 move d0,230(a6)
*31
 lea 230*2(a5),a5
 lea 230*2(a6),a6
 pause 24-4+(8+9)+5+6*2+2
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 2
 rts

aff_dragon_2
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem (a4)+,d2-d5 *3+4
 move d4,(a5)    *3
 move d5,8(a5)    *3  = 21
 move d0,(a6)
* 29

 movem (a4)+,d2-d5 *3+4
 move d4,230(a5)    *3
 move d5,230+8(a5)    *3  = 21
 move d0,230(a6)
*31
 lea 230*2(a5),a5
 lea 230*2(a6),a6
 pause 24-4+(8+9)+5+6+2
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 2
 rts

aff_dragon_3
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem (a4)+,d2-d5 *3+4
 move d3,(a5)     *3
 move d4,8(a5)    *3
 move d5,16(a5)    *3  = 21
 move d0,(a6)
 move d0,8(a6)
* 29

 movem (a4)+,d2-d5 *3+4
 move d3,230(a5)     *3
 move d4,230+8(a5)    *3
 move d5,230+16(a5)    *3  = 21
 move d0,230(a6)
 move d0,230+8(a6)
*31
 lea 230*2(a5),a5
 lea 230*2(a6),a6
 pause 24-4+(8+9)-6+5+2
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 2
 rts

aff_dragon_4
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem (a4)+,d2-d5 *3+4
 move d2,(a5)      *2
 move d3,8(a5)     *3
 move d4,16(a5)    *3
* move d5,24(a5)    *3  = 21
 move d0,(a6)
 move d0,8(a6)
 move d0,16(a6)
 move d0,24(a6)
* 29

 movem (a4)+,d2-d5 *3+4
 move d2,230(a5)      *3
 move d3,230+8(a5)     *3
 move d4,230+16(a5)    *3
* move d5,230+24(a5)    *3  = 21
 move d0,230(a6)
 move d0,230+8(a6)
 move d0,230+16(a6)
 move d0,230+24(a6)
*31
 lea 230*2(a5),a5
 lea 230*2(a6),a6
 pause 24-4+6
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 2
 rts

aff_dragon_5
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem (a4)+,d2-d5 *3+4
 move d2,(a5)      *2
 move d3,8(a5)     *3
* move d4,16(a5)    *3
* move d5,24(a5)    *3  = 21
 move d0,(a6)
 move d0,8(a6)
 move d0,16(a6)
* move d0,24(a6)
* 29

 movem (a4)+,d2-d5 *3+4
 move d2,230(a5)      *3
 move d3,230+8(a5)     *3
* move d4,230+16(a5)    *3
* move d5,230+24(a5)    *3  = 21
 move d0,230(a6)
 move d0,230+8(a6)
 move d0,230+16(a6)
* move d0,230+24(a6)
*31
 lea 230*2(a5),a5
 lea 230*2(a6),a6
 pause 24-4+6*2*2-6
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 2
 rts

aff_dragon_6
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem (a4)+,d2-d5 *3+4
 move d2,(a5)      *2
* move d3,8(a5)     *3
* move d4,16(a5)    *3
* move d5,24(a5)    *3  = 21
 move d0,(a6)
 move d0,8(a6)
* move d0,16(a6)
* move d0,24(a6)
* 29

 movem (a4)+,d2-d5 *3+4
 move d2,230(a5)      *3
* move d3,230+8(a5)     *3
* move d4,230+16(a5)    *3
* move d5,230+24(a5)    *3  = 21
 move d0,230(a6)
 move d0,230+8(a6)
* move d0,230+16(a6)
* move d0,230+24(a6)
*31
 lea 230*2(a5),a5
 lea 230*2(a6),a6
 pause 24-4+6*6-6
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 pause 13
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 2
 rts

tab_aff_dragon
 dc.l aff_dragon_1
 dc.l aff_dragon_2
 dc.l aff_dragon_3
 rept 23
 dc.l aff_dragon_0
 endr
 dc.l aff_dragon_4
 dc.l aff_dragon_5
 dc.l aff_dragon_6
 even

sequence
 dc.w 3-1

 dc.l zik1
 dc.l map0
 dc.l map_msg0
 dc.l msg0
 dc.l raster2
 dc.l chateau_blk
 dc.l pal_chateau

 dc.l zik0
 dc.l map1
 dc.l map_msg1
 dc.l msg1
 dc.l raster1
 dc.l statue_blk
 dc.l pal_statue

 dc.l zik1
 dc.l map2
 dc.l map_msg2
 dc.l msg2
 dc.l raster0
 dc.l arbres_blk
 dc.l pal_arbres

******
map0
 incbin monde_1.map
 even
map1
 incbin monde_2.map
 even
map2
 incbin monde_3.map
 even
map_msg0 incbin monde_1.mtx
 even
map_msg1 incbin monde_2.mtx
 even
map_msg2 incbin monde_3.mtx
 even
msg0 incbin monde_1.txt
 even
msg1 incbin monde_2.txt
 even
msg2 incbin monde_3.txt
 even
raster0 include coloris1.s
raster1 include coloris3.s
raster2 include coloris2.s
 even
chateau_blk incbin chateau.blk
statue_blk incbin statublk.blk
arbres_blk incbin arbreblk.blk
 even
* ici les autres blocks
pal_chateau
 incbin chateau.pal
 incbin chatespr.pal
pal_statue
 incbin statue.pal
 incbin statuspr.pal
pal_arbres
 incbin arbres.pal
 incbin arbrespr.pal



hard incbin syncscro.tbl 
herbe incbin herbe.dat

adr_pal_barriere incbin barriere.pal

barrier0 incbin barrier0.dat
barrier1 incbin barrier1.dat
sprited incbin sprited.dat
montagnes incbin montagne.dat
palfont incbin font_000.pal
beast_font ds.l 2*6
 incbin beast.fnt
 even
dragon incbin dragon.ani *=64*20
 even
precaclgfx
 incbin precalc.dat
 ds.w 128
precaclpal incbin precalc.pal

 even
adrblock
 dc.l block0
 dc.l block1
 dc.l block2
 dc.l block3
 dc.l block4
 dc.l block5
 dc.l block6
 dc.l block7

x_monts dc.w 1

data_herbe
*23
 dc 3-1 * nb de pix de haut -1
 dc 1   * nb de pix de rapidite
 dc 0   * ce ki doit etre increment‚
 dc.l 0   * offset sur le buffer herbe en pixels
*20
 dc 4-1 * nb de pix de haut -1
 dc 2   * nb de pix de rapidite
 dc 0   * ce ki doit etre increment‚
 dc.l 0   * offset sur le buffer herbe en pixels
*16
 dc 4-1 * nb de pix de haut -1
 dc 3   * nb de pix de rapidite
 dc 0   * ce ki doit etre increment‚
 dc.l 0   * offset sur le buffer herbe en pixels
*12
 dc 4-1 * nb de pix de haut -1
 dc 4   * nb de pix de rapidite
 dc 0   * ce ki doit etre increment‚
 dc.l 0   * offset sur le buffer herbe en pixels
*6
 dc 7-1 * nb de pix de haut -1
 dc 5   * nb de pix de rapidite
 dc 0   * ce ki doit etre increment‚
 dc.l 0   * offset sur le buffer herbe en pixels

*0
 dc 7-1 * nb de pix de haut -1
 dc 6   * nb de pix de rapidite
 dc 0   * ce ki doit etre increment‚
 dc.l 0   * offset sur le buffer herbe en pixels
*0
 dc 3-1 * nb de pix de haut -1
 dc 7   * nb de pix de rapidite
 dc 0   * ce ki doit etre increment‚
 dc.l 0   * offset sur le buffer herbe en pixels
*0
 
mul_960
x set 0
 rept max_msg
 dc.l x
x set x+960
 endr
 
mul_3200
x set 0
 rept 16
 dc.l x
x set x+3200
 endr

mul_160
x set 0
 rept 20
 dc x
x set x+160
 endr

mul_2560
x set 0
 rept 16
 dc.l x
x set x+2560
 endr

mul_2720
x set 0
 rept 16
 dc.l x
x set x+2720
 endr
mul_192
x set 0
 rept nb_block
 dc x
x set x+192
 endr
 even
zik1 incbin zik.bin
 even
zik0 incbin zik1.bin
 even
 bss
mit
s_sr ds.w 1
s_a7 ds.l 1
s_usp ds.l 1
 ds.l 2000
pile
s_mfp ds.b (14+8+32)
 even
buf1 ds.l 1
buf2 ds.l 1
adr_buf ds.l 8

*sprite
adr_save ds.l 1
s_pile ds.l 1
offset_sprite ds.w 1
vit_spr_cpt ds.w 1
 ifeq finale
sens_spr_new ds.w 1
sens_spr ds.w 1
 endc
buf_save ds.l 2990     * pour la premiere fois !!


* MAP
adr_map ds.l 1
adr_decor ds.l 1
 ifeq finale
map_courrante ds.l 1
map_precedante ds.l 1
 endc
nb_map ds.w 1

* message
buf_txt ds.l (960*max_msg)/4
adr_map_msg ds.l 1
adr_msg ds.l 1
nmsg ds.w 1
n_nmsg ds.w 1
deg_fnt ds.w 1

* bss pour le deplacement
 ifeq finale
cheat ds.w 1
xecran ds.w 1
xecran_anc ds.w 1
 endc
xecran_anc1 ds.w 1
max_xecran ds.w 1

*bss pour le masque de la barriere (11 ligne)
vide ds.l (230*21)/4
masque0 ds.w 52*11
masque1 ds.w 52*11

* bss pour les blocks
block0 ds.l (192*nb_block)/4
block1 ds.l (192*nb_block)/4
block2 ds.l (192*nb_block)/4
block3 ds.l (192*nb_block)/4
block4 ds.l (192*nb_block)/4
block5 ds.l (192*nb_block)/4
block6 ds.l (192*nb_block)/4
block7 ds.l (192*nb_block)/4

* pour le dregrade
adr_raster ds.l 1
x_source         ds.l nombre_couleurs*3
offsets          ds.l nombre_couleurs*3
source
 ds.w nombre_couleurs*16
dest =*-nombre_couleurs*2

*dragon
s_adr_dragon ds.l 1
dragon_merde ds.l (230*20)/4
n_anim_dragon ds.w 1
x_dragon ds.w 1

*zik
adr_zik ds.l 1
* merde
exit_flag ds.w 1

aff_pr ds.w 1
ecrans ds.l (186*230+14*160+7*160)*2
	ds.l 2300
fecrans
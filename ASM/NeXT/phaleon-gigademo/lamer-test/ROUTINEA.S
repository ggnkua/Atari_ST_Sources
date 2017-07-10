vbl_nul
 addq #1,cp_vbl
 rte
vbl
 movem.l d0-a6,-(sp)
 addq #1,cp_vbl
 bset #6,$fffffa09.w
 bset #6,$fffffa15.w
 bset #0,$fffffa07.w
 bset #0,$fffffa13.w


couleurs_logo = *+4
 movem.l next_mpal,d0-d7
 movem.l d0-d7,$ffff8240.w
 clr.b $fffffa1b.w
 move.b #ymin-1,$ffffffa21.w
 move.b #8,$ffffffa1b.w
 move.l #hbl0,$120.w
* star field
 bsr star

 lea donne,a2
 add donne_aj,a2
 rept nb_spr
 bsr eff_sprite
 endr

 lea donne,a2
 add donne_aj,a2
x set 0
 rept nb_spr
 lea sprite+x,a3
 bsr aff_sprite
x set x+7*24
 endr
 eor #nb_spr*4,donne_aj

 change_ecr
adr_music = *+2
 jsr rts
 ifne tempo
 eor #$7,$ffff8240.w
 eor #$7,$ffff8240.w
 endc
 movem.l (sp)+,d0-a6
 rte
*rts rts
hbl0
 clr.b $fffffa1b.w
 move.l #hble,$120.w
 move.b ecart+1,$fffffa21.w
 subq.b #1,$fffffa21.w
 move.b #8,$fffffa1b.w
 pea (a0)
 lea $ffff8242.w,a0
 ifeq nb_plan-3
 move #$111,(a0)+
 move.l #$2220333,(a0)+
 move.l #$4440555,(a0)+
 move.l #$6660777,(a0)+
 elseif
 move.l #$333,(a0)+
 move.l #$4440777,(a0)+
 endc
 move.l #couleur_fond_index,couleur_fond
 move #1,line_rast
 tst autre_raster
 bne.s .autre_rast
 move.l (sp)+,a0
 rte
.autre_rast
 move d0,-(sp)
 clr.b $fffffa1b.w
 move.l #hbl1text,$120.w
 move.b #2,$fffffa21.w
 move.b #8,$fffffa1b.w
 lea couleur_text,a0
 move (a0)+,d0
 move.l a0,adr_couleur_fond_text
 lea ($ffff8240+8*2).w,a0
 rept 8
 move d0,(a0)+
 endr
 move (sp)+,d0
 move.l (sp)+,a0
 rte



hble
 move d0,-(sp)
 pea (a0)
couleur_fond = *+2
 lea couleur_fond,a0
 move (a0)+,d0
 move (a0),couleur_fond1
 beq.s .rien
 lea $ffff8240.w,a0
 rept 8
 move d0,(a0)+
 endr
.rien
 move d0,couleur_fond_bis
 clr.b $fffffa1b.w
 move.l #hbl1a,$120.w
 move.b #1,$fffffa21.w
 move.b #8,$fffffa1b.w
 move.l #couleur,adr_rast
 move.l (sp)+,a0
 move (sp)+,d0
 rte

hbl1a
 move d0,-(sp)
 pea (a0)
couleur_fond1 = *+2
 move #$7894,d0
 beq.s .rien
 lea $ffff8240.w,a0
 rept 8
 move d0,(a0)+
 endr
.rien
 clr.b $fffffa1b.w
 move.l #hbl1,$120.w
 move.b #1,$fffffa21.w
 move.b #8,$fffffa1b.w
 move.l (sp)+,a0
 move (sp)+,d0
 rte
 
hbl1
 pea (a0)
 move d0,-(sp)
adr_rast = *+2
 move couleur,d0
 beq.s .rien
 lea ($ffff8240+8*2).w,a0
 rept 8
 move d0,(a0)+
 endr
.rien
 addq.l #2,adr_rast
 cmp.l #fcouleur,adr_rast
 blt.s .rte
 clr.b $fffffa1b.w
 move.l #hble1,$120.w
 move.b #2,$fffffa21.w
 move.b #8,$fffffa1b.w
.rte
 move (sp)+,d0
 move.l (sp)+,a0
 rte
line_rast dc.w 0
hble1
 move d0,-(sp)
 pea (a0)
couleur_fond_bis = *+2
 move #$7894,d0
 beq.s .rien
 lea $ffff8240.w,a0
 rept 8
 move d0,(a0)+
 endr
.rien
 clr.b $fffffa1b.w
 move.l #hble2,$120.w
 move.b #1,$fffffa21.w
 move.b #8,$fffffa1b.w
 move.l (sp)+,a0
 move (sp)+,d0
 rte

hble2
 pea (a0)
 lea $ffff8240.w,a0
 clr (a0)+
 ifeq nb_plan-3
 move #$111,(a0)+
 move.l #$2220333,(a0)+
 move.l #$4440555,(a0)+
 move.l #$6660777,(a0)+
 elseif
 move.l #$333,(a0)+
 move.l #$4440777,(a0)+
 endc
 clr.b $fffffa1b.w
 move d0,-(sp)
 addq #1,line_rast
 move line_rast,d0
 cmp nb_line_tout,d0
 bgt.s .rte
 move.l #hble,$120.w
 move.b ecart+1,$fffffa21.w
 subq.b #4,$fffffa21.w
 move.b #8,$fffffa1b.w
 addq.l #4,couleur_fond
.rte
 move (sp)+,d0
 move.l (sp)+,a0
 rte

hbl1text
 move d0,-(sp)
 pea (a0)
adr_couleur_fond_text = *+2
 move $78894562,d0
 lea ($ffff8240+8*2).w,a0
 rept 8
 move d0,(a0)+
 endr
 addq.l #2,adr_couleur_fond_text
 move.l (sp)+,a0
 move (sp)+,d0
 rte 

couleur
 dc $0707,$0716,$0725,$0734,$0743,$0752,$0761,$0770
fcouleur

couleur_fond_index
 dcb.l 12,0

efface_tout
 lea couleur_fond_index,a0
 moveq #12-1,d7
.dfcol
 clr.l (a0)+
 dbra d7,.dfcol
* ne pas touche a d0 autrment QUICK !
 move.l adr_ecr,a0
 move.l adr_ecr1,a1
 lea 6+ymin*160(a0),a0
 lea 6+ymin*160(a1),a1
 lea (ymax-ymin-2)*160(a0),a2
 lea (ymax-ymin-2)*160(a1),a3
 move #(ymax-ymin)/4,d7
.looopeff
 bsr vsync
 moveq #20*2-1,d6
.eff0
 clr (a2)
 clr (a3)
 clr (a1)
 clr (a0)
 addq #8,a2
 addq #8,a3
 addq #8,a0
 addq #8,a1
 dbra d6,.eff0
 lea -160*4(a2),a2
 lea -160*4(a3),a3
 dbra d7,.looopeff
 rts

print0
 lea buffer_infos+2,a5
 bsr print

 lea buffer_infos,a5
 clr (a5)+
 move (a5)+,d7
 subq #1,d7
 addq #4,a5
 moveq #0,d6
 moveq #1,d5
 moveq #0,d4
 lea couleur_fond_index,a6
.loop0
 clr.l (a6)
 tst (a5)
 blt.s .pas_selectable
 tst d4
 bne .pas_selectable
 move.l #color_select,(a6)
 addq #1,d4
 move d5,buffer_infos
.pas_selectable
 addq #4,a6
 addq #2,a5
 addq #1,d5
 dbra d7,.loop0
.select_table_trouve

* la on gere la souris et clavie d'ailleur
.wait
 bsr take_octet
 cmp.b #$48,d0
 bne.s .pas_haut
 move buffer_infos,d0
.loop_haut
 subq #1,d0
 tst d0
 ble .wait
 move d0,d1
 subq #1,d1
 add d1,d1
 lea selectablite,a0
 add d1,a0
 tst (a0)
 blt.s .loop_haut
.valid
 move buffer_infos,d1
 subq #1,d1
 add d1,d1
 add d1,d1
 lea couleur_fond_index,a0
 clr.l 0(a0,d1.w)
 move d0,buffer_infos
 subq #1,d0
 add d0,d0
 add d0,d0
 move.l #color_select,0(a0,d0.w)
 bra .wait
.pas_haut


 cmp.b #$50,d0
 bne.s .pas_bas
 move buffer_infos,d0
.loop_bas
 addq #1,d0
 cmp nb_line_tout,d0
 bgt .wait
 move d0,d1
 subq #1,d1
 add d1,d1
 lea selectablite,a0
 add d1,a0
 tst (a0)
 blt.s .loop_bas
 bra .valid
.pas_bas
* 
 cmp #1,d0
 beq.s .fin_wait1
 cmp.b #$74,d0
 beq.s .fin_wait
 cmp.b #$1c,d0
 beq.s .fin_wait
 cmp.b #$72,d0
 beq.s .fin_wait
 cmp.b #$52,d0
 beq.s .fin_wait
 cmp.b #$39,d0
 beq.s .fin_wait
 cmp.b #$75,d0
 bne .wait
.fin_wait
 move buffer_infos,d0
 subq #1,d0
 rts
.fin_wait1
 moveq #-1,d0
 rts

wait_key
.wait
 bsr take_octet
 cmp.b #$74,d0
 beq.s .fin_wait
 cmp.b #$72,d0
 beq.s .fin_wait
 cmp.b #$1c,d0
 beq.s .fin_wait
 cmp.b #$39,d0
 beq.s .fin_wait
 cmp.b #$75,d0
 bne .wait
.fin_wait
 rts




buffer_infos
 dc.w 0 * ligne selctionne actuellement
nb_line_tout
 dc.w 0 * nb line de text sans compter la derniere
 dc.w 0 * nb line de text en tout !!!

 dc.w 0 * ecart entre les lignes
selectablite
 dcb 12,0 * effet de chaque ligne 12 au max (meme 10....)

print * a6 adr_text
 moveq #0,d7
 move.b (a6)+,d7
 ext d7
 tst d7
 bmi.s .ok
 move d7,(a5)+
 move d7,(a5)+
 move d7,d6
 bra.s .ok1
.ok
 neg d7
 move d7,(a5)+
 move d7,d6
 addq #1,d6
 move d6,(a5)+
.ok1
 moveq #0,d5
 move #ymax-ymin,d5
 move d6,d4
 addq #1,d6
 lsl #3,d4
 sub d4,d5
 divu d6,d5
 move d5,ecart
 move d5,(a5)+
 clr nb_line
.loop_0_print
 clr offset_car
 addq #1,nb_line
 moveq #0,d6
 move.b (a6)+,d6
 ext d6
 move d6,(a5)+
 moveq #0,d6
 move.b (a6)+,d6
 beq .loop_print
 moveq #40,d5
 sub d6,d5
 lsr d5
 btst #0,d5
 beq.s .loopPrint0
 lsr d5
 lsl #3,d5
 addq #1,d5
 move d5,offset_car
 bra.s .loop_print
.loopPrint0
 lsr d5
 lsl #3,d5
 move d5,offset_car
.loop_print
 bsr vsync
 bsr print_car
 bsr add_car
 subq #1,d6
 bne.s .loop_print
 subq #1,d7
 bne.s .loop_0_print
 rts

print_car  *(a6)
* a6
* offset_car
* bsr add_car

 moveq #0,d0
 move.b (a6),d0
 lea font,a0
 lsl #3,d0
 add d0,a0
 move.l adr_ecr,a1
 move.l adr_ecr1,a2
 lea 6+ymin*160(a1),a1
 lea 6+ymin*160(a2),a2
 add offset_car,a1
 add offset_car,a2
 move nb_line,d0
 mulu ecart,d0
 move nb_line,d1
 subq #1,d1
 lsl #3,d1
 add d1,d0
 mulu #160,d0
 add d0,a1
 add d0,a2
x set 0
 rept 8
 move.b (a0)+,d0
 move.b d0,x(a1)
 move.b d0,x(a2)
x set x+160
 endr
 rts

add_car
 addq #1,a6
 move offset_car,d0
 btst #0,d0
 beq.s .yu
 addq #7,offset_car
 rts
.yu
 addq #1,offset_car
 rts

sub_car
 subq #1,a6
 move offset_car,d0
 btst #0,d0
 beq.s .yu
 subq #1,offset_car
 rts
.yu
 subq #7,offset_car
 rts

*d0 -> Num‚ro de langue
*d1 -> Num‚ro de question
*a0 -> Adresse du fichier index
*a1 -> Adresse du fichier texte correspondant
*a1 <- Pointe sur le bloc 'Question' demand‚

calcule_index
 add.w d0,d0 
 add.w (a0,d0.w),a0
 add.w d1,d1
 move.w (a0,d1.w),d1
 add.w d1,d1
 add.w d1,d1
 addq.w #2,a1
 add.w d1,a1                 Pointe au bon endroit normalement
 rts


best_score
 st autre_raster
* a0
 lea buffer_inter,a1
 moveq #10-1,d7
.aff0
 moveq #36-1,d6
 move.l a1,a2
.aff1
 move.b (a0)+,d0
 bsr converti
 bsr print_letter
 addq #1,a2
 dbra d6,.aff1
 addq #2,a0
 lea 36*10(a1),a1
 dbra d7,.aff0

 lea buffer_inter,a2
 move.l adr_ecr,a0
 move.l adr_ecr1,a1
 lea 6+ymin*160+8(a0),a0
 lea 6+ymin*160+8(a1),a1
 moveq #(10*10)-1,d7
.line0
 moveq #18-1,d6
.line1
 move (a2),(a0)
 move (a2)+,(a1)
 addq #8,a0
 addq #8,a1
 dbra d6,.line1
 lea 8*2(a0),a0
 lea 8*2(a1),a1
 dbra d7,.line0
 
.tr
 bsr take_octet
 cmp.b #$39,d0
 beq.s .tr1
 cmp.b #$1c,d0
 beq.s .tr1
 cmp.b #$52,d0
 beq.s .tr1
 cmp.b #$73,d0
 beq.s .tr1
 cmp.b #$75,d0
 beq.s .tr1
 cmp.b #$74,d0
 bne.s .tr
.tr1
 bsr efface_tout
 sf autre_raster
 rts

print_letter
 pea (a0)
 lea font,a0
 lsl #3,d0
 add d0,a0
x set 0
 rept 8
 move.b (a0)+,x(a2)
x set x+36
 endr
 move.l (sp)+,a0
 rts


fntc dc.b " ABCDEFGHIJKLMNOPQRSTUVWXYZ!?.,0123456789%#'",$22,"ý&î„‰‹”°± ‚…Š—ƒˆŒ“–ž´$‡():-+/*ï=abcdefghijklmnopqrstuvwxyz",0
 even
converti
 movem.l a0/d1-d2,-(sp)
 lea fntc,a0
 moveq #0,d1
.con
 move.b (a0)+,d2
 beq.s .fin_ark
 cmp.b d0,d2
 beq.s .fin
 addq #1,d1
 bra.s .con
.fin
 move d1,d0
 movem.l (sp)+,a0/d1-d2
 rts
.fin_ark
 moveq #0,d0
 movem.l (sp)+,a0/d1-d2
 rts

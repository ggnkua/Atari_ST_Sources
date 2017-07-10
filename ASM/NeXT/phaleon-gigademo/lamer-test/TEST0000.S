vit_souris = 6
tempo = 1
debug =0
* pour les etoiles
nb_plan = 3
nb_star = 160
precision = 10
max_speed = 10
xmin = 0
xmax = 320
ymin = 102
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
 lea off,a0
 bsr envoie_clavier
 clr flag_clavier
 bsr prepare_tout
 move.l #clavier,$118.w
 move.b #$40,$fffffa17.w
 lea sequence,a0
 bsr envoie_clavier
* init
 move.l #courbe0,adr_c0

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

 lea mess0,a6
 bsr print0
.wait
 bsr take_octet
 bclr #7,d0
 cmp.b #$39,d0
 bne.s .wait

 moveq #14,d7
.deg1
 bsr vsync
 bsr vsync
 sub.l #32,couleurs_logo
 dbra d7,.deg1
 lea sequence1,a0
 bsr envoie_clavier
 rts

mess0
 dc.b 2
 dc.b -1,40 
 dc.b 1,2,3,4,5,6,0,7,8,9,10,11,12,13,14,0,15,16,17,18
 dc.b 1,2,3,4,5,6,0,7,8,9,10,11,12,13,14,0,15,16,17,18
 dc.b 0,34
 dc.b 1,2,3,4,5,6,0,7,8,9,10,11,12,13,14,0,15,16,17,18
 dc.b 1,2,3,4,5,6,0,7,8,9,10,11,12,13,14,0,15,16,17,18
 even
 
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

 bsr eff_sprite
 bsr aff_sprite
 eor #nb_spr*4,donne_aj

 change_ecr
 ifne tempo
 eor #$7,$ffff8240.w
 eor #$7,$ffff8240.w
 endc
 movem.l (sp)+,d0-a6
 rte

hbl0
 clr.b $fffffa1b.w
 move.l #hble,$120.w
 move.b ecart+1,$fffffa21.w
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
 move.l (sp)+,a0
 rte

hble
 clr.b $fffffa1b.w
 move.l #hbl1,$120.w
 move.b #1,$fffffa21.w
 move.b #8,$fffffa1b.w
 move.l #couleur,adr_rast
 rte
 
hbl1
couleur_fond = *+2
 move #$0,$ffff8240.w
 pea (a0)
 move d0,-(sp)
adr_rast = *+2
 move couleur,d0
 lea ($ffff8240+8*2).w,a0
* move d0,$ffff8240.w
* move #$777,d0
 rept 8
 move d0,(a0)+
 endr
 addq.l #2,adr_rast
 cmp.l #fcouleur,adr_rast
 blt.s .rte
 clr.b $fffffa1b.w
 move.l #hble,$120.w
 move.b ecart+1,$fffffa21.w
 subq.b #1,$fffffa21.w
 move.b #8,$fffffa1b.w
.rte
 move (sp)+,d0
 move.l (sp)+,a0
 rte
couleur
 dc $0707,$0716,$0725,$0734,$0743,$0752,$0761,$0770,-1
fcouleur

couleur_fond_index
 dcb 12,0
print0
 move #$0,couleur_fond
 lea buffer_infos,a5
 bsr print

 lea buffer_infos,a5
 move (a5)+,d7
 subq #1,d7
 addq #2,a5
 moveq #0,d6
 moveq #0,d5
 moveq #0,d4
 lea couleur_fond_index,a6
.loop0
 clr (a6)
 tst (a5)
 blt.s .pas_selectable
 tst d4
 beq .pas_selectable
 move (a5),(a6)
 addq #1,d4
.pas_selectable
 addq #2,a6
 addq #2,a5
 addq #1,d5
 dbra d7,.loop0
.select_table_trouve
* la on gere la souris et clavie d'ailleur
.wait
 bsr take_octet
 cmp.b #$74,d0
 beq.s .fin_wait
 cmp.b #$75,d0
 bne.s .wait
 rts


buffer_infos
 dc.w 0 * nb line de text
 dc.w 0 * ecart entre les lignes
 dcb 12,0 * effet de chaque ligne 12 au max (meme 10....)

print * a6 adr_text
 moveq #0,d7
 move.b (a6)+,d7
 move d7,(a5)+
 move d7,d6
 moveq #ymax-ymin,d5
 addq #1,d6
 move d7,d4
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
 move d6,(a5)+
 move.b (a6)+,d6
 moveq #40,d5
 sub d6,d5
 lsr d5
 lsr d5
 beq.s .loopPrint0
 lsl #3,d5
 addq #1,d5
 move d5,offset_car
 bra.s .loop_print
.loopPrint0
 lsl #3,d5
 move d5,offset_car
.loop_print
 bsr vsync
 bsr print_car
 bsr vsync
 bsr print_car

 bsr add_car
 subq #1,d6
 bne.s .loop_print
 subq #1,d7
 bne.s .loop_0_print
 rts

print_car  *(a6)
*
 moveq #0,d0
 move.b (a6),d0
 lea font,a0
 lsl #3,d0
 add d0,a0
 move.l adr_ecr,a1
 lea 6+ymin*160(a1),a1
 add offset_car,a1
 move nb_line,d0
 mulu ecart,d0
 move nb_line,d1
 subq #1,d1
 lsl #3,d1
 add d1,d0
 mulu #160,d0
 add d0,a1
x set 0
 rept 8
 move.b (a0)+,x(a1)
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
  
 include include.s

 data
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

ecrans ds.b 256+32000*2
end_bss
 
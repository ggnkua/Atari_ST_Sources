* $74 boutton gauche
* $75 boutton droit
clavier
 move d0,-(sp)
.loop
 move.b $fffffc00.w,d0
* btst #0,d0
* beq.s .end_clavier
 move.b $fffffc02.w,d0
 btst #7,d0
 bne.s .end_clavier
 move.b d0,touche_clavier
 st touche_clavier+1
.end_clavier 
 btst #4,$fffffa01.w
 beq.s .loop
 move (sp)+,d0
 rte

take_octet
 moveq #0,d0
 tst.b touche_clavier+1
 beq.s .end_take
 move.b touche_clavier,d0
 sf touche_clavier+1
.end_take
 rts
vsync
 move d0,-(sp)
 move cp_vbl,d0
.vsync
 cmp cp_vbl,d0
 beq.s .vsync
 move (sp)+,d0
 rts
 
prepare_tout
 lea ecrans,a0
 lea end_bss,a1
 moveq #0,d0
.efface_bss
 move.l d0,(a0)+
 move.l d0,(a0)+
 cmp.l a1,a0
 blt.s .efface_bss
 
 move.l #ecrans,d0
 st d0
 addq.l #1,d0
 move.l d0,adr_ecr
 add.l #32000,d0
 move.l d0,adr_ecr1
 lsr.l #8,d0
 lea $ffff8201.w,a0
 movep d0,(a0)

 lea $ffff8240.w,a0
 moveq #7,d7
.cle_color
 clr.l (a0)+
 dbra d7,.cle_color
* affiche le next en haut des deux ecrans
 lea next_m,a0
 move.l adr_ecr,a1
 move.l adr_ecr1,a2
 move #(hlogo*160)/4-1,d7
.aff0
 move.l (a0),(a1)+
 move.l (a0)+,(a2)+
 dbra d7,.aff0
 bsr init_all
 rts

envoie_clavier
 sf flag_clavier	; marque "on cause au clavier" pour la vbl
 move.b (a0)+,d1
 cmp.b #-1,d1
 beq.s .fin_envoie
 lea $fffffc00.w,a1
.attend
 move.b (a1),d2
 btst #1,d2
 beq.s .attend
 move #$1b6,d2 * $3b6
.temporisation
 bsr .comme_le_systeme
 dbra d2,.temporisation
 move.b d1,2(a1)
 bra.s envoie_clavier
.fin_envoie
 st flag_clavier
 rts
.comme_le_systeme
 rts

eff_sprite
 lea next_m,a3
 move.l adr_ecr,a4
.loop
 move.l a3,a0
 move.l a4,a1
 addq #1,a2
 moveq #0,d0
 move.b (a2)+,d0   * x offset(16)*8
 add (a2)+,d0      * offset y*160
 add d0,a0
 add d0,a1
x set 0
 rept 7
 movem.l x(a0),d0-d3
 movem.l d0-d3,x(a1)
x set x+160
 endr
 rts

gere
 tst (a0)
 bpl.s .ou
 move.l a1,a0
.ou
 move.l (a0)+,(a2)+
 rts
tablem
x set 0
 rept 16
 dc x
x set x+(16+8)*14
 endr
aff_sprite
 lea courbe0,a1
 move.l adr_c0,a0
 bsr gere
 move.l a0,adr_c0
 subq #4,a2 
 move.l adr_ecr,a4
.loop
 move.l a3,a0
 move.l a4,a1
 moveq #0,d1
 move.b (a2)+,d1   * (x and $f)*2
 moveq #0,d0
 move.b (a2)+,d0   * x offset(16)*8
 add tablem(pc,d1.w),a0
 add (a2)+,d0      * offset y*160
 add d0,a1
x set 0
 rept 7
 movem.l x(a1),d0-d3
 movem.l (a0)+,d4-d7
 and.l d4,d0
 and.l d4,d1
 and.l d5,d2
 and.l d5,d3
 or.l d6,d0
 or.l d7,d1
 or.l (a0)+,d2
 or.l (a0)+,d3
 movem.l d0-d3,x(a1)
x set x+160
 endr
 rts
donne
 rept nb_spr*2
 dc.w 0,0
 endr

save
 lea buf_save,a0
 lea $ffff8201.w,a1
 movep (a1),d0
 move d0,(a0)+
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,(a0)
 lea 4*8(a0),a0
 move.b $fffffa07.w,(a0)+
 move.b $fffffa09.w,(a0)+
 move.b $fffffa0f.w,(a0)+
 move.b $fffffa11.w,(a0)+
 move.b $fffffa13.w,(a0)+
 move.b $fffffa15.w,(a0)+
 move.b $fffffa17.w,(a0)+
 move.b $fffffa1b.w,(a0)+
 move.b $fffffa1d.w,(a0)+
 move.b $fffffa1f.w,(a0)+
 move.b $fffffa21.w,(a0)+
 move.b $fffffa25.w,(a0)+
* 16 .b
 move.l $70.w,(a0)+
 move.l $120.w,(a0)+
 move.l $110.w,(a0)+
 move.l $118.w,(a0)+
 move.b $ffff8260.w,(a0)+
 rts

restore
 lea buf_save,a0
 lea $ffff8201.w,a1
 move (a0)+,d0
 movep d0,(a1)
 movem.l (a0)+,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.b (a0)+,$fffffa07.w
 move.b (a0)+,$fffffa09.w
 move.b (a0)+,$fffffa0f.w
 move.b (a0)+,$fffffa11.w
 move.b (a0)+,$fffffa13.w
 move.b (a0)+,$fffffa15.w
 move.b (a0)+,$fffffa17.w
 move.b (a0)+,$fffffa1b.w
 move.b (a0)+,$fffffa1d.w
 move.b (a0)+,$fffffa1f.w
 move.b (a0)+,$fffffa21.w
 move.b (a0)+,$fffffa25.w
* 16 .b
 move.l (a0)+,$70.w
 move.l (a0)+,$120.w
 move.l (a0)+,$110.w
 move.l (a0)+,$118.w
 move.b (a0)+,$ffff8260.w
 rts

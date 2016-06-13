 	opt o+
	
	include m_ligne.s
	
	section text
	
	pea main(pc)
	move.w #$26,-(sp)
	trap #14
	addq.l #6,sp
	
	clr.l -(sp)
	trap #1
	
tst_stf	move.b #2,chg_typ1+3
	move.b #1,chg_typ2+3
	lea 10(sp),sp
	rts

main	move.l 8.w,d7
	move.l #tst_stf,8.w
	
	sf $ffff8901.w

	move.l d7,8.w
	
no_stf	lea buffer,a0
	lea fin,a1
eff_bss	clr.w (a0)+
	cmp.l a0,a1
	bne.s eff_bss
	
	move.b $ffff8260.w,res
	move.b $ffff820a.w,anc_freq
	move.l $44e.w,anc_ecr
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,anc_pal
	
	movem.l eff_pal,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	move.b $fffffa07.w,mfp1
	move.b $fffffa09.w,mfp2
	move.b $fffffa0f.w,mfp3
	move.b $fffffa11.w,mfp4
	move.b $fffffa13.w,mfp5
	move.b $fffffa15.w,mfp6
	move.b $fffffa17.w,mfp7
	move.b $fffffa1b.w,mfp8
	move.b $fffffa21.w,mfp9
	
	bclr #3,$fffffa17.w
	
	sf $fffffa07.w
	sf $fffffa09.w
	sf $fffffa13.w
	sf $fffffa15.w
	
	move.b #$12,$fffffc02.w
	
	moveq #1,d0
	bsr musique
	
	move.l $70.w,anc_vbl
	move.l $68.w,anc_hbl
	move.l $118.w,anc_kbd
	
            move.l #new_vbl,$70.w
            move.l #new_hbl,$68.w
            
            move.l #buffer+256,d0
            clr.b d0
	move.l d0,ecran
	add.l #32000,d0
	move.l d0,ecran1
	add.l #32000,d0
	move.l d0,ecran2 
	
	move.l ecran,a1
	lea 32(a1),a1
	lea 32000(a1),a2
	lea present,a0
	move.w #199,d0
aff_pres	movem.l (a0)+,d1-d7/a3-a6
	movem.l d1-d7/a3-a6,(a1)
	movem.l d1-d7/a3-a6,(a2)
	movem.l (a0)+,d1-d7/a3-a6
	movem.l d1-d7/a3-a6,44(a1)
	movem.l d1-d7/a3-a6,44(a2)
	movem.l (a0)+,d1-d4
	movem.l d1-d4,88(a1)
	movem.l d1-d4,88(a2)
	lea 160(a1),a1
	lea 160(a2),a2
	dbf d0,aff_pres
	
	vsync
	sf $ffff8260.w
	move.b #2,$ffff820a.w
	vsync
	
	move.l ecran,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	
	lea pal_pres,a6
	bsr colorin
	
no_space	vsync

	bsr aff_3d
		
	cmp.b #$39,$fffffc02.w
	bne.s no_space
	
.error_kbd	btst #5,$fffffc00.w
	beq.s .no_error
	
	tst.b $fffffc02.w
	bra.s .error_kbd
	
.no_error	btst #0,$fffffc00.w
	beq.s .vide_buf
	
	tst.b $fffffc02.w
	bra.s .error_kbd
	
.vide_buf	lea pal_pres,a6
	bsr colorout
	
	movem.l eff_pal,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	tst.w langue
	bne.s no_french
	
francais	move.l #mes_fr,mes_pnt
	move.l #mes_fr,again+2

no_french	bsr pred_spr
	bsr calc_curv
			
	move.l ecran2,a0
	lea base,a1
	move.w #3999,d0
aff_base	move.l (a1)+,(a0)+
	move.w (a1)+,(a0)+
	addq.l #2,a0
	dbf d0,aff_base
	
	move.l ecran,a0
	move.l ecran1,a1
	move.w #1999,d0
eff_ecr	rept 4
	clr.l (a0)+
	clr.l (a1)+
	endr
	dbf d0,eff_ecr
	
	move.l ecran,a0
	lea 122*160(a0),a0
	move.l ecran1,a1
	lea 122*160(a1),a1
	lea base+(122*120),a2
	move.w #1559,d0
aff_logo	move.l (a2),(a0)+
	move.l (a2)+,(a1)+
	move.w (a2),(a0)+
	move.w (a2)+,(a1)+
	addq.l #2,a0
	addq.l #2,a1
	dbf d0,aff_logo
	
	move.l $120.w,anc_tb
	move.l #vbl,$70.w 
	move.l #t_b,$120.w
	
	sf $fffffa1b.w
	
	bset #0,$fffffa07.w
	bset #0,$fffffa13.w
	
speed1	vsync

speed2	vsync

speed3	vsync

speed4	move.l ecran,d0
	move.l ecran1,d1
	move.l d0,ecran1
	move.l d1,ecran
	
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	
	subq.b #1,pal_cycle
	bge.s _cont_pal
	
ch_cycle	move.b #$3c,pal_cycle

	addq.l #2,pal_pos
new_pal	cmp.l #fin_pal,pal_pos
	bne.s _cont_pal

pal_pos1	move.l #pal_fix,pal_pos

_cont_pal	move.l pal_pos,ch_pal1+2

	vsync

	move.l ecran,a6
	lea 122*160(a6),a6
	movem.l eff_pal,d0-d7/a0-a5

	rept 116
	movem.l d0-d7/a0-a5,-(a6)
	movem.l d0-d7/a0-a5,-(a6)
	movem.l d0-d7/a0-a5,-(a6)
	endr
	movem.l d0-d7,-(a6)
	
	move.l color1,a0
	tst.w (a0)
	bge.s jump3
	lea posxy,a0
jump3	movem.w (a0)+,d0-d3
	move.l a0,color1
	move.l #ligne1_1,ch_l1+2
	move.l #ligne1_2,ch_l2+2
	move.l #chg_l1_1+1,change_1+4
	move.l #chg_l1_2+1,change_2+4
	bsr lucas
	
	move.l color2,a0
	tst.w (a0)
	bge.s jump4
	lea posxy,a0
jump4	movem.w (a0)+,d0-d3
	move.l a0,color2
	move.l #ligne2_1,ch_l1+2
	move.l #ligne2_2,ch_l2+2
	move.l #chg_l2_1+1,change_1+4
	move.l #chg_l2_2+1,change_2+4
	bsr lucas
	
	move.l color3,a0
	tst.w (a0)
	bge.s jump5
	lea posxy,a0
jump5	movem.w (a0)+,d0-d3
	move.l a0,color3
	move.l #ligne3_1,ch_l1+2
	move.l #ligne3_2,ch_l2+2
	move.l #chg_l3_1+1,change_1+4
	move.l #chg_l3_2+1,change_2+4
	bsr lucas
	
	move.l color4,a0
	tst.w (a0)
	bge.s jump6
	lea posxy,a0
jump6	movem.w (a0)+,d0-d3
	move.l a0,color4
	move.l #ligne4_1,ch_l1+2
	move.l #ligne4_2,ch_l2+2
	move.l #chg_l4_1+1,change_1+4
	move.l #chg_l4_2+1,change_2+4
	bsr lucas
	
	move.l color5,a0
	tst.w (a0)
	bge.s jump7
	lea posxy,a0
jump7	movem.w (a0)+,d0-d3
	move.l a0,color5
	move.l #ligne5_1,ch_l1+2
	move.l #ligne5_2,ch_l2+2
	move.l #chg_l5_1+1,change_1+4
	move.l #chg_l5_2+1,change_2+4
	bsr lucas
	
	move.l color6,a0
	tst.w (a0)
	bge.s jump8
	lea posxy,a0
jump8	movem.w (a0)+,d0-d3
	move.l a0,color6
	move.l #ligne6_1,ch_l1+2
	move.l #ligne6_2,ch_l2+2
	move.l #chg_l6_1+1,change_1+4
	move.l #chg_l6_2+1,change_2+4
	bsr lucas
	
	move.l color7,a0
	tst.w (a0)
	bge.s jump9
	lea posxy,a0
jump9	movem.w (a0)+,d0-d3
	move.l a0,color7
	move.l #ligne7_1,ch_l1+2
	move.l #ligne7_2,ch_l2+2
	move.l #chg_l7_1+1,change_1+4
	move.l #chg_l7_2+1,change_2+4
	bsr lucas
	
	move.l color8,a0
	tst.w (a0)
	bge.s jumpa
	lea posxy,a0
jumpa	movem.w (a0)+,d0-d3
	move.l a0,color8
	move.l #ligne8_1,ch_l1+2
	move.l #ligne8_2,ch_l2+2
	move.l #chg_l8_1+1,change_1+4
	move.l #chg_l8_2+1,change_2+4
	bsr lucas
	
	move.l color9,a0
	tst.w (a0)
	bge.s jumpb
	lea posxy,a0
jumpb	movem.w (a0)+,d0-d3
	move.l a0,color9
	move.l #ligne9_1,ch_l1+2
	move.l #ligne9_2,ch_l2+2
	move.l #chg_l9_1+1,change_1+4
	move.l #chg_l9_2+1,change_2+4
	bsr lucas
	
	move.l colora,a0
	tst.w (a0)
	bge.s jumpc
	lea posxy,a0
jumpc	movem.w (a0)+,d0-d3
	move.l a0,colora
	move.l #lignea_1,ch_l1+2
	move.l #lignea_2,ch_l2+2
	move.l #chg_la_1+1,change_1+4
	move.l #chg_la_2+1,change_2+4
	bsr lucas
	
	move.l colorb,a0
	tst.w (a0)
	bge.s jumpd
	lea posxy,a0
jumpd	movem.w (a0)+,d0-d3
	move.l a0,colorb
	move.l #ligneb_1,ch_l1+2
	move.l #ligneb_2,ch_l2+2
	move.l #chg_lb_1+1,change_1+4
	move.l #chg_lb_2+1,change_2+4
	bsr lucas
	
	move.l colorc,a0
	tst.w (a0)
	bge.s jumpe
	lea posxy,a0
jumpe	movem.w (a0)+,d0-d3
	move.l a0,colorc
	move.l #lignec_1,ch_l1+2
	move.l #lignec_2,ch_l2+2
	move.l #chg_lc_1+1,change_1+4
	move.l #chg_lc_2+1,change_2+4
	bsr lucas
	
	move.l colord,a0
	tst.w (a0)
	bge.s jumpf
	lea posxy,a0
jumpf	movem.w (a0)+,d0-d3
	move.l a0,colord
	move.l #ligned_1,ch_l1+2
	move.l #ligned_2,ch_l2+2
	move.l #chg_ld_1+1,change_1+4
	move.l #chg_ld_2+1,change_2+4
	bsr lucas
	
	move.l colore,a0
	tst.w (a0)
	bge.s jumpg
	lea posxy,a0
jumpg	movem.w (a0)+,d0-d3
	move.l a0,colore
	move.l #lignee_1,ch_l1+2
	move.l #lignee_2,ch_l2+2
	move.l #chg_le_1+1,change_1+4
	move.l #chg_le_2+1,change_2+4
	bsr lucas
	
	move.l colorf,a0
	tst.w (a0)
	bge.s jumph
	lea posxy,a0
jumph	movem.w (a0)+,d0-d3
	move.l a0,colorf
	move.l #lignef_1,ch_l1+2
	move.l #lignef_2,ch_l2+2
	move.l #chg_lf_1+1,change_1+4
	move.l #chg_lf_2+1,change_2+4
	bsr lucas
		
	cmp.b #$62,$fffffc02.w
	beq menu
	
	cmp.b #$39,$fffffc02.w
	beq.s quit
	
no_press	;cmp.b #$2a,$fffffc02.w
	;bne.s no_press

ch_speed	jmp speed2

quit	move.w #$2700,sr

	move.l #stop_vbl,$70.w
	move.l anc_tb,$120.w
	move.l anc_kbd,$118.w
	
	move.b mfp1,$fffffa07.w
	move.b mfp2,$fffffa09.w
	move.b mfp3,$fffffa0f.w
	move.b mfp4,$fffffa11.w
	move.b mfp5,$fffffa13.w
	move.b mfp6,$fffffa15.w
	move.b mfp7,$fffffa17.w
	move.b mfp8,$fffffa1b.w
	move.b mfp9,$fffffa21.w
	
	move.w #$2300,sr
	
	moveq #0,d0
	bsr musique
	
	vsync
	
	move.l anc_ecr,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	
	movem.l anc_pal,d0-d7
	movem.l d0-d7,$ffff8240.w

	vsync
	
	move.b res,$ffff8260.w
	move.b anc_freq,$ffff820a.w
	
	move.l anc_hbl,$68.w
	move.l anc_vbl,$70.w
	
.error_kbd	btst #5,$fffffc00.w
	beq.s .no_error
	
	tst.b $fffffc02.w
	bra.s .error_kbd
	
.no_error	btst #0,$fffffc00.w
	beq.s .vide_buf
	
	tst.b $fffffc02.w
	bra.s .error_kbd
	
.vide_buf	move.b #8,$fffffc02.w
	
	rts
	
menu	move.l #autr_vbl,$70.w

	move.l ecran,a0
	move.l ecran1,a1
	move.w #(122*40)-1,d0
efface	clr.l (a0)+
	clr.l (a1)+
	dbf d0,efface
	
	move.l #pal_opt,menu_pal+2
	
	move.l ecran,a0
	move.l ecran1,a1
	move.l ecran2,a2
	moveq #121,d1
aff_opt	movem.l (a2)+,d2-d7/a3-a6
	movem.l d2-d7/a3-a6,(a0)
	movem.l d2-d7/a3-a6,(a1)
	movem.l (a2)+,d2-d7/a3-a6
	movem.l d2-d7/a3-a6,40(a0)
	movem.l d2-d7/a3-a6,40(a1)
	movem.l (a2)+,d2-d7/a3-a6
	movem.l d2-d7/a3-a6,80(a0)
	movem.l d2-d7/a3-a6,80(a1)
	movem.l (a2)+,d2-d7/a3-a6
	movem.l d2-d7/a3-a6,120(a0)
	movem.l d2-d7/a3-a6,120(a1)
	lea 160(a0),a0
	lea 160(a1),a1
	vsync
	dbf d1,aff_opt
	vsync
	
	move.l #it_kbd,$118.w
	move.l #snd_vbl,$70.w

	bset #6,$fffffa09.w
	bset #6,$fffffa15.w
	
	bsr set_kbd
	
rien	vsync

	move.b $fffffc02.w,d0
	
	cmp.w #4,mousek		;souris bouton gauche
	bne.s _jump1
	moveq #1,d7
	bra chg_val
	
_jump1	cmp.w #1,mousek		;souris bouton droit
 	bne.s _jump2
 	st d7
 	bra chg_val
 	
_jump2	cmp.b #$39,key
	beq quit
	
	cmp.b #$62,key
	bne.s rien
	
bye	vsync
	
	sf $fffffa09.w
	sf $fffffa15.w
	move.l anc_kbd,$118.w
	move.l #autr_vbl,$70.w
	
	bsr calc_curv
	bsr eff_curs
	bsr eff_spr2
	bsr eff_spr
	
	move.l ecran,d0
	move.l ecran1,d1
	move.l d0,ecran1
	move.l d1,ecran
	move.l pos_spr1,d0
	move.l pos_spr2,d1
	move.l d0,pos_spr2
	move.l d1,pos_spr1
	move.l pos_spr3,d0
	move.l pos_spr4,d1
	move.l d0,pos_spr4
	move.l d1,pos_spr3
	move.l pos_curs1,d0
	move.l pos_curs2,d1
	move.l d0,pos_curs2
	move.l d1,pos_curs1
	
	bsr eff_curs
	bsr eff_spr2
	bsr eff_spr

	move.l ecran1,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w

	move.l ecran,a0
	move.l ecran1,a1
	moveq #121,d1
	moveq #0,d2
	move.l d2,d3
	move.l d2,d4
	move.l d2,d5
	move.l d2,d6
	move.l d2,d7
	move.l d2,a3
	move.l d2,a4
	move.l d2,a5
	move.l d2,a6
	
eff_menu	movem.l d2-d7/a3-a6,(a0)
	movem.l d2-d7/a3-a6,(a1)
	movem.l d2-d7/a3-a6,40(a0)
	movem.l d2-d7/a3-a6,40(a1)
	movem.l d2-d7/a3-a6,80(a0)
	movem.l d2-d7/a3-a6,80(a1)
	movem.l d2-d7/a3-a6,120(a0)
	movem.l d2-d7/a3-a6,120(a1)
	lea 160(a0),a0
	lea 160(a1),a1
	vsync
	dbf d1,eff_menu
	
	move.l #vbl,$70.w
	bra speed4
	
aff_3d	cmp.b #$30,$fffffc02.w
	beq.s aff_3d
		
	lea present,a0
	move.l ecran,a1
	lea 32(a1),a1
	move.w #199,d0
aff_pres2	movem.l (a0)+,d1-d7/a2-a6
	movem.l d1-d7/a2-a6,(a1)
	movem.l (a0)+,d1-d7/a2-a6
	movem.l d1-d7/a2-a6,48(a1)
	movem.l (a0)+,d1-d2
	movem.l d1-d2,96(a1)
	lea 160(a1),a1
	dbf d0,aff_pres2
	
	move.l pos_3d,a0
	cmp.b #-1,(a0)
	bne.s cont_3d
	move.l #datas_3d,pos_3d
cont_3d	moveq #28,d7
loop_3d	clr.w d0
	clr.w d1
	clr.w d2
	clr.w d3
	move.l pos_3d,a0
	move.b (a0)+,d0
	move.b (a0)+,d1
	move.b (a0)+,d2
	move.b (a0)+,d3
	move.l a0,pos_3d
	cmp.b #$23,$fffffc02.w
	beq.s no_lignes
	move.w d7,-(sp)
	bsr lucas
	move.w (sp)+,d7
no_lignes	dbf d7,loop_3d
	
	move.l ecran,d0
	move.l ecran1,d1
	move.l d1,ecran
	move.l d0,ecran1
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	rts
	
new_vbl	movem.l d0-d7/a0-a6,-(sp)
	bsr musique+8
	movem.l (sp)+,d0-d7/a0-a6
stop_vbl	addq.l #1,_vsync
new_hbl	rte
	
snd_vbl	movem.l d0-d7/a0-a6,-(sp)
	
	move.l ecran1,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	
	move.l ecran,d0
	move.l ecran1,d1
	move.l d0,ecran1
	move.l d1,ecran
	move.l pos_spr1,d0
	move.l pos_spr2,d1
	move.l d0,pos_spr2
	move.l d1,pos_spr1
	move.l pos_spr3,d0
	move.l pos_spr4,d1
	move.l d0,pos_spr4
	move.l d1,pos_spr3
	move.l pos_curs1,d0
	move.l pos_curs2,d1
	move.l d0,pos_curs2
	move.l d1,pos_curs1

	sf $fffffa1b.w
	
	move.b #122,$fffffa21.w
	move.b #8,$fffffa1b.w
	
	bsr rd_mouse
	
	lea pal_opt,a0
	movem.l (a0)+,d0-d6
	movem.l d0-d6,$ffff8242.w
	move.w (a0)+,$ffff825e.w
	
	addq.l #4,s_pos_pal
	cmp.l #f_pal_scr,s_pos_pal
	bne.s cont_pal1
	
	move.l #pal_scroll,s_pos_pal
	
cont_pal1	move.l s_pos_pal,pos_pal

	move.w #1000,d0
wait	dbf d0,wait

	bsr eff_curs
	bsr eff_spr2
	bsr eff_spr
	bsr ombre_curs
	bsr aff_curs
	bsr ombre_2
	bsr aff_spr2
	bsr ombre_1
	bsr aff_spr1
	
	bra.s scroll
	
autr_vbl	movem.l d0-d7/a0-a6,-(sp)

menu_pal	lea eff_pal,a0
	bra.s vbl_suit
	
vbl	movem.l d0-d7/a0-a6,-(sp)

ch_pal1	lea d_pal_fix,a0
vbl_suit	movem.l (a0)+,d0-d6
	movem.l d0-d6,$ffff8242.w
	move.w (a0)+,$ffff825e.w
	
	addq.l #4,s_pos_pal
	cmp.l #f_pal_scr,s_pos_pal
	bne.s cont_pal
	
	move.l #pal_scroll,s_pos_pal
	
cont_pal	move.l s_pos_pal,pos_pal
	
	sf $fffffa1b.w
	
	move.b #122,$fffffa21.w
	move.b #8,$fffffa1b.w
	
scroll	move.l ecran,a4
	lea 163*160(a4),a4
	move.l ecran1,a5
	lea 163*160(a5),a5
	
chg_car	lea fonte+(116*16),a3

n	set 0
	rept 16

	move.b 14+n(a4),7+n(a4)
	move.b 14+n(a5),7+n(a5)
	move.b 15+n(a4),14+n(a4)
	move.b 15+n(a5),14+n(a5)
	move.b 22+n(a4),15+n(a4)
	move.b 22+n(a5),15+n(a5)
	move.b 23+n(a4),22+n(a4)
	move.b 23+n(a5),22+n(a5)
	move.b 30+n(a4),23+n(a4)
	move.b 30+n(a5),23+n(a5)
	move.b 31+n(a4),30+n(a4)
	move.b 31+n(a5),30+n(a5)
	move.b 38+n(a4),31+n(a4)
	move.b 38+n(a5),31+n(a5)
	move.b 39+n(a4),38+n(a4)
	move.b 39+n(a5),38+n(a5)
	move.b 46+n(a4),39+n(a4)
	move.b 46+n(a5),39+n(a5)
	move.b 47+n(a4),46+n(a4)
	move.b 47+n(a5),46+n(a5)
	move.b 54+n(a4),47+n(a4)
	move.b 54+n(a5),47+n(a5)
	move.b 55+n(a4),54+n(a4)
	move.b 55+n(a5),54+n(a5)
	move.b 62+n(a4),55+n(a4)
	move.b 62+n(a5),55+n(a5)
	move.b 63+n(a4),62+n(a4)
	move.b 63+n(a5),62+n(a5)
	move.b 70+n(a4),63+n(a4)
	move.b 70+n(a5),63+n(a5)
	move.b 71+n(a4),70+n(a4)
	move.b 71+n(a5),70+n(a5)
	move.b 78+n(a4),71+n(a4)
	move.b 78+n(a5),71+n(a5)
	move.b 79+n(a4),78+n(a4)
	move.b 79+n(a5),78+n(a5)
	move.b 86+n(a4),79+n(a4)
	move.b 86+n(a5),79+n(a5)
	move.b 87+n(a4),86+n(a4)
	move.b 87+n(a5),86+n(a5)
	move.b 94+n(a4),87+n(a4)
	move.b 94+n(a5),87+n(a5)
	move.b 95+n(a4),94+n(a4)
	move.b 95+n(a5),94+n(a5)
	move.b 102+n(a4),95+n(a4)
	move.b 102+n(a5),95+n(a5)
	move.b 103+n(a4),102+n(a4)
	move.b 103+n(a5),102+n(a5)
	move.b 110+n(a4),103+n(a4)
	move.b 110+n(a5),103+n(a5)
	move.b 111+n(a4),110+n(a4)
	move.b 111+n(a5),110+n(a5)
	move.b 118+n(a4),111+n(a4)
	move.b 118+n(a5),111+n(a5)
	move.b 119+n(a4),118+n(a4)
	move.b 119+n(a5),118+n(a5)
	move.b 126+n(a4),119+n(a4)
	move.b 126+n(a5),119+n(a5)
	move.b 127+n(a4),126+n(a4)
	move.b 127+n(a5),126+n(a5)
	move.b 134+n(a4),127+n(a4)
	move.b 134+n(a5),127+n(a5)
	move.b 135+n(a4),134+n(a4)
	move.b 135+n(a5),134+n(a5)
	move.b 142+n(a4),135+n(a4)
	move.b 142+n(a5),135+n(a5)
	move.b 143+n(a4),142+n(a4)
	move.b 143+n(a5),142+n(a5)
	move.b 150+n(a4),143+n(a4)
	move.b 150+n(a5),143+n(a5)
	move.b 151+n(a4),150+n(a4)
	move.b 151+n(a5),150+n(a5)
	move.b 158+n(a4),151+n(a4)
	move.b 158+n(a5),151+n(a5)
	move.b (a3),158+n(a4)
	move.b (a3)+,158+n(a5)

n	set n+160
	endr

nextchar	moveq #0,d0
	move.l mes_pnt,a0
	move.b (a0)+,d0
	move.l a0,mes_pnt
	
	cmp.b #-1,d0
	beq.s again
	
	lsl.w #2,d0
	
	lea tab_font,a0
	move.l (a0,d0.w),chg_car+2
	
	bsr musique+8
	
	movem.l (sp)+,d0-d7/a0-a6
	
	addq.l #1,_vsync
	rte
	
again	move.l #mes_uk,mes_pnt
	bra.s nextchar
	
	
t_b	move.w #$111,$ffff8242.w
	move.l #$2110222,$ffff8244.w
	move.l #$3220333,$ffff8248.w
	move.l #$4330444,$ffff824c.w
	sf $fffffa1b.w
	move.b #40,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #t_b1,$120.w
	bclr #0,$fffffa0f.w
	rte
	
t_b1	move.b #$11,compt
	sf $fffffa1b.w
	move.b #1,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #t_b2,$120.w
	bclr #0,$fffffa0f.w
	rte
	
t_b2	subq.b #1,compt
	beq.s t_b3
	
	move.l a6,-(sp)
	move.l pos_pal,a6
	move.l (a6),$ffff8250.w
	move.l (a6),$ffff8254.w
	move.l (a6),$ffff8258.w
	move.l (a6)+,$ffff825c.w
	move.l a6,pos_pal
	move.l (sp)+,a6
	bclr #0,$fffffa0f.w
	rte
	
t_b3	sf $fffffa1b.w
	move.l #t_b,$120.w
	bclr #0,$fffffa0f.w
	rte
	
it_kbd	tst.w m_flag
	beq.s it_kbd3
	
	movem.l d0-a0,-(sp)
	lea mouse_buf,a0
	move.w m_flag,d0
	move.b $fffffc02.w,(a0,d0.w)
	movem.l (sp)+,d0-a0
	
	cmp.w #5,m_flag
	bne.s it_kbd4
	
	clr.w m_flag
	move.l mouse_buf,mousek
	move.w mouse_buf+4,mousey
	bra.s it_kbd5
	
it_kbd3	move.b $fffffc02.w,key
	cmp.b #$f7,key
	bne.s it_kbd5
	
it_kbd4	addq.w #1,m_flag
it_kbd5	bclr #6,$fffffa11.w
	rte
	
rd_mouse	btst #1,$fffffc00.w
	beq.s rd_mouse
	
	clr.w m_flag
	move.b #$d,$fffffc02.w
	move.l d0,-(sp)
	move.w mousek,d0
	btst #0,d0
	beq.s fff1
	not.b bouton_d
fff1	btst #1,d0
	beq.s fff2
	not.b bouton_d
fff2	move.l (sp)+,d0
	rts
	
set_kbd	move.l mousex,org_pos
	lea tbl_kbd,a0
	move.w len_kbd,d0
	
wait_free	btst #1,$fffffc00.w
	beq.s wait_free
	move.b (a0)+,$fffffc02.w
	dbf d0,wait_free
	rts
	
chg_val	move.w mousey,d0
	move.w d0,d1
	lsl.w #4,d0
	lsl.w #2,d1
	add.w d1,d0
	
	move.w mousex,d1
	addq.w #8,d1
	and.w #$fff0,d1
	lsr.w #4,d1
	add.w d1,d0
	lsl.w #2,d0
	
	lea tab_pos,a0
	move.l (a0,d0.w),a0
	
	moveq #0,d0
	jmp (a0)
	
s_x1	move.b x1_1+3,d0
	add.b d7,d0
	and.b #$f,d0
	move.b d0,x1_1+3
	lea $718.w,a4
	bra simple_car
	
s_x1_sin	move.b sin1_x1+3,d0
	lea $728.w,a6
	tst.b d0
	beq.s cos1
	clr.b sin1_x1+3
	bra aff_sin
cos1	move.b #90,sin1_x1+3
	bra aff_cos
	 
s_x2	move.b x2_1+3,d0
	add.b d7,d0
	and.b #$f,d0
	move.b d0,x2_1+3
	lea $750.w,a4
	bra simple_car
	
s_x2_sin	move.b sin2_x1+3,d0
	lea $760.w,a6
	tst.b d0
	beq.s cos2
	clr.b sin2_x1+3
	bra aff_sin
cos2	move.b #90,sin2_x1+3
	bra aff_cos
	 
s_y1	move.b y1_1+3,d0
	add.b d7,d0
	and.b #$f,d0
	move.b d0,y1_1+3
	lea $12f8.w,a4
	bra simple_car
	
s_y1_sin	move.b sin1_y1+3,d0
	lea $1308.w,a6
	tst.b d0
	beq.s cos3
	clr.b sin1_y1+3
	bra aff_sin
cos3	move.b #90,sin1_y1+3
	bra aff_cos
	 
s_y2	move.b y2_1+3,d0
	add.b d7,d0
	and.b #$f,d0
	move.b d0,y2_1+3
	lea $1330.w,a4
	bra simple_car
	
s_y2_sin	move.b sin2_y1+3,d0
	lea $1340.w,a6
	tst.b d0
	beq.s cos4
	clr.b sin2_y1+3
	bra aff_sin
cos4	move.b #90,sin1_x1+3
	bra aff_cos
	 
e_x1	move.b x1_2+3,d0
	add.b d7,d0
	and.b #$f,d0
	move.b d0,x1_2+3
	lea $21f8.w,a4
	bra simple_car
	
e_x1_sin	move.b sin1_x2+3,d0
	lea $2208.w,a6
	tst.b d0
	beq.s cos5
	clr.b sin1_x2+3
	bra aff_sin
cos5	move.b #90,sin1_x2+3
	bra aff_cos
	 
e_x2	move.b x2_2+3,d0
	add.b d7,d0
	and.b #$f,d0
	move.b d0,x2_2+3
	lea $2230.w,a4
	bra simple_car
	
e_x2_sin	move.b sin2_x2+3,d0
	lea $2240.w,a6
	tst.b d0
	beq.s cos6
	clr.b sin2_x2+3
	bra aff_sin
cos6	move.b #90,sin2_x2+3
	bra aff_cos
	 
e_y1	move.b y1_2+3,d0
	add.b d7,d0
	and.b #$f,d0
	move.b d0,y1_2+3
	lea $2dd8.w,a4
	bra simple_car
	
e_y1_sin	move.b sin1_y2+3,d0
	lea $2de8.w,a6
	tst.b d0
	beq.s cos7
	clr.b sin1_y2+3
	bra aff_sin
cos7	move.b #90,sin1_y2+3
	bra aff_cos
	 
e_y2	move.b y2_2+3,d0
	add.b d7,d0
	and.b #$f,d0
	move.b d0,y2_2+3
	lea $2e10.w,a4
	bra simple_car
	
e_y2_sin	move.b sin2_y2+3,d0
	lea $2e20.w,a6
	tst.b d0
	beq.s cos8
	clr.b sin2_y2+3
	bra aff_sin
cos8	move.b #90,sin2_y2+3
	bra aff_cos
	
color_typ	move.b sav_col_typ,d0
	add.b d7,d0
chg_typ1	cmp.b #3,d0
	blt.s cont_typ
	clr.b d0
	bra.s cont_typ2
cont_typ	cmp.b #-1,d0
	bgt.s cont_typ2
chg_typ2	move.b #2,d0
cont_typ2	move.b d0,sav_col_typ
	lea $3cf8.w,a6
	lea choix_pal,a0
	lsl.b #2,d0
	move.l (a0,d0.w),a0
	jmp (a0)
	
speed	move.b vitesse,d0
	add.b d7,d0
	cmp.b #5,d0
	blt.s s_1
	move.b #1,d0
	bra.s s_2
s_1	tst.b d0
	bgt.s s_2
	move.b #4,d0
s_2	move.b d0,vitesse
	cmp.b #1,d0
	bne.s speed_1
	move.l #speed1,ch_speed+2
speed_1	cmp.b #2,d0
	bne.s speed_2
	move.l #speed2,ch_speed+2
speed_2	cmp.b #3,d0
	bne.s speed_3
	move.l #speed3,ch_speed+2
speed_3	cmp.b #4,d0
	bne.s speed_4
	move.l #speed4,ch_speed+2
speed_4	lea $3cc8.w,a4
	bra.s simple_car
	
cycle	move.b ch_cycle+3,d0
	lsr.b #2,d0
	sub.b d7,d0
	and.b #$f,d0
	move.b d0,d1
	not.b d0
	and.b #$f,d0
	lsl.b #2,d1
	move.b d1,ch_cycle+3
	move.b d1,pal_cycle
	lea $3d30.w,a4
	
simple_car	lea tab_car,a0
	lsl.b #2,d0
	move.l (a0,d0.w),a0
	lea (a0),a5
	move.l ecran,a1
	move.l ecran1,a2
	move.l ecran2,a3
	add.w a4,a1
	add.w a4,a2
	add.w a4,a3
	
n	set 0
	rept 14
	move.l (a0),n(a2)
	move.l (a0)+,n(a3)
	move.w (a0),4+n(a2)
	move.w (a0)+,4+n(a3)
n	set n+160
	endr
	
	vsync
	
n	set 0
	rept 14
	move.l (a5)+,n(a1)
	move.w (a5)+,4+n(a1)
n	set n+160
	endr
	 
	vsync
	vsync
	vsync
	bra rien

aff_fix	move.l #pal_fix,pal_pos
	move.l #pal_fix,pal_pos1+2
	move.l #fin_pal,new_pal+2

	lea cf,a0
	lea c1,a1
	lea cx,a2
	
	bra mult_car
	
aff_stf	move.l #pal_stf,pal_pos
	move.l #pal_stf,pal_pos1+2
	move.l #end_stf,new_pal+2

	lea cs,a0
	lea ct,a1
	lea cf,a2
	
	bra.s mult_car
	
aff_ste	move.l #pal_ste,pal_pos
	move.l #pal_ste,pal_pos1+2
	move.l #end_ste,new_pal+2

	lea cs,a0
	lea ct,a1
	lea ce,a2
	
	bra.s mult_car
	
aff_cos	lea cc,a0
	lea c0,a1
	lea cs,a2
	
	bra.s mult_car
	
aff_sin	lea cs,a0
	lea c1,a1
	lea cn,a2
	
mult_car	move.l ecran,a3
	move.l ecran1,a4
	move.l ecran2,a5
	
	add.w a6,a3
	add.w a6,a4
	add.w a6,a5
	
	movem.l a0-a2,-(sp)

n	set 0
	rept 14
	
	move.l (a0),n(a4)
	move.l (a0)+,n(a5)
	move.w (a0),4+n(a4)
	move.w (a0)+,4+n(a5)
	move.l (a1),8+n(a4)
	move.l (a1)+,8+n(a5)
	move.w (a1),12+n(a4)
	move.w (a1)+,12+n(a5)
	move.l (a2),16+n(a4)
	move.l (a2)+,16+n(a5)
	move.w (a2),20+n(a4)
	move.w (a2)+,20+n(a5)
	
n	set n+160
	endr
	
	vsync
	
	movem.l (sp)+,a0-a2
	
n	set 0
	rept 14
	
	move.l (a0)+,n(a3)
	move.w (a0)+,4+n(a3)
	move.l (a1)+,8+n(a3)
	move.w (a1)+,12+n(a3)
	move.l (a2)+,16+n(a3)
	move.w (a2)+,20+n(a3)
	
n	set n+160
	endr
	
	vsync
	vsync
	vsync
	bra rien
	
lucas	move.l ecran,a6
	lea tab_ligne,a2
	lea tab_dec_spr,a0
	lea tab_dec_msk,a1
	
	cmp.w d2,d0
	blt.s no_exg
	
	exg d0,d2
	exg d1,d3
	
no_exg	move.w d3,d4
	add.w d4,d4
	move.w (a2,d4.w),d4
	lea (a6,d4.w),a5
	
	move.w d1,d4
	add.w d4,d4
	move.w (a2,d4.w),d4
	lea (a6,d4.w),a6
		
	move.w d2,d7
	sub.w d0,d2
	bge.s saut_1
	neg.w d2
	
saut_1	sub.w d1,d3
	bmi.s saut_2
	
	lea 160.w,a3
	bra.s saut_3
	
saut_2	lea -160.w,a3
	neg.w d3
	
saut_3	cmp.w d3,d2
	bls.s sinon
	
	move.w d2,d4
	lsr.w #1,d4
	neg.w d4
	subq.w #1,d4
	
	move.w d7,d5
	and.w #$fff0,d7
	lsr.w #1,d7
	lea (a5,d7.w),a5
	
	and.w #$f,d5
	eor.b #$f,d5
	lsl.w #2,d5
	 move.l (a1,d5.w),d6
	move.l (a0,d5.w),d5
	
	move.w d0,d1
	and.w #$fff0,d1
	lsr.w #1,d1
	lea (a6,d1.w),a6
	
	and.w #$f,d0
	eor.b #$f,d0
	lsl.w #2,d0
	move.l (a1,d0.w),d1
	move.l (a0,d0.w),d0
	
	move.w d2,d7
	lsr.w #1,d7
	
	bcs.s ch_l1
	subq.w #1,d7
change_1	move.b #$71,chg_l4_1+1
ch_l1	jmp ligne4_1
 
sinon	move.w d3,d4
	lsr.w #1,d4
	neg.w d4
	subq.w #1,d4
	
	move.w d7,d5
	and.w #$fff0,d7
	lsr.w #1,d7
	lea (a5,d7.w),a5
	
	and.w #$f,d5
	eor.b #$f,d5
	lsl.w #2,d5
	move.l (a1,d5.w),d6
	move.l (a0,d5.w),d5
	
	move.w d0,d1
	and.w #$fff0,d1
	lsr.w #1,d1
	lea (a6,d1.w),a6
	
	and.w #$f,d0
	eor.b #$f,d0
	lsl.w #2,d0
	move.l (a1,d0.w),d1
	move.l (a0,d0.w),d0
	
	move.w d3,d7
	lsr.w #1,d7
	
	bcs.s ch_l2
	subq.w #1,d7
change_2	move.b #$71,chg_l4_2+1
ch_l2	jmp ligne4_2
	
ligne1_1	ligne_1_0
	dbf d7,ligne1_1
chg_l1_1	rts
	or.w d5,(a5)
	and.l d6,2(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l1_1+1
	rts
	
ligne1_2	ligne_1_1
	dbf d7,ligne1_2
chg_l1_2	rts
	or.w d5,(a5)
	and.l d6,2(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l1_2+1
	rts
	
ligne2_1	ligne_2_0
	dbf d7,ligne2_1
chg_l2_1	rts
	and.w d6,(a5)
	or.w d5,2(a5)
	and.l d6,4(a5)
	move.b #$75,chg_l2_1+1
	rts
	
ligne2_2	ligne_2_1
	dbf d7,ligne2_2
chg_l2_2	rts
	and.w d6,(a5)
	or.w d5,2(a5)
	and.l d6,4(a5)
	move.b #$75,chg_l2_2+1
	rts
	
ligne3_1	ligne_3_0
	dbf d7,ligne3_1
chg_l3_1	rts
	or.l d5,(a5)
	and.l d6,4(a5)
	move.b #$75,chg_l3_1+1
	rts
	
ligne3_2	ligne_3_1
	dbf d7,ligne3_2
chg_l3_2	rts
	or.l d5,(a5)
	and.l d6,4(a5)
	move.b #$75,chg_l3_2+1
	rts
	
ligne4_1	ligne_4_0
	dbf d7,ligne4_1
chg_l4_1	rts
	and.l d6,(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l4_1+1
	rts
	
ligne4_2	ligne_4_1
	dbf d7,ligne4_2
chg_l4_2	rts
	and.l d6,(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l4_2+1
	rts
	
ligne5_1	ligne_5_0
	dbf d7,ligne5_1
chg_l5_1	rts
	or.w d5,(a5)
	and.w d6,2(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l5_1+1
	rts
	
ligne5_2	ligne_5_1
	dbf d7,ligne5_2
chg_l5_2	rts
	or.w d5,(a5)
	and.w d6,2(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l5_2+1
	rts
	
ligne6_1	ligne_6_0
	dbf d7,ligne6_1
chg_l6_1	rts
	and.w d6,(a5)
	or.l d5,2(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l6_1+1
	rts
	
ligne6_2	ligne_6_1
	dbf d7,ligne6_2
chg_l6_2	rts
	and.w d6,(a5)
	or.l d5,2(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l6_2+1
	rts
	
ligne7_1	ligne_7_0
	dbf d7,ligne7_1
chg_l7_1	rts
	or.l d5,(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l7_1+1
	rts
	
ligne7_2	ligne_7_1
	dbf d7,ligne7_2
chg_l7_2	rts
	or.l d5,(a5)
	or.w d5,4(a5)
	and.w d6,6(a5)
	move.b #$75,chg_l7_2+1
	rts
	
ligne8_1	ligne_8_0
	dbf d7,ligne8_1
chg_l8_1	rts
	and.l d6,(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	move.b #$75,chg_l8_1+1
	rts
	
ligne8_2	ligne_8_1
	dbf d7,ligne8_2
chg_l8_2	rts
	and.l d6,(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	move.b #$75,chg_l8_2+1
	rts
	
ligne9_1	ligne_9_0
	dbf d7,ligne9_1
chg_l9_1	rts
	or.w d5,(a5)
	and.l d6,2(a5)
	or.w d5,6(a5)
	move.b #$75,chg_l9_1+1
	rts
	
ligne9_2	ligne_9_1
	dbf d7,ligne9_2
chg_l9_2	rts
	or.w d5,(a5)
	and.l d6,2(a5)
	or.w d5,6(a5)
	move.b #$75,chg_l9_2+1
	rts
	
lignea_1	ligne_a_0
	dbf d7,lignea_1
chg_la_1	rts
	and.w d6,(a5)
	or.w d5,2(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	move.b #$75,chg_la_1+1
	rts
	
lignea_2	ligne_a_1
	dbf d7,lignea_2
chg_la_2	rts
	and.w d6,(a5)
	or.w d5,2(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	move.b #$75,chg_la_2+1
	rts
	
ligneb_1	ligne_b_0
	dbf d7,ligneb_1
chg_lb_1	rts
	or.l d5,(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	move.b #$75,chg_lb_1+1
	rts
	
ligneb_2	ligne_b_1
	dbf d7,ligneb_2
chg_lb_2	rts
	or.l d5,(a5)
	and.w d6,4(a5)
	or.w d5,6(a5)
	move.b #$75,chg_lb_2+1
	rts
	
lignec_1	ligne_c_0
	dbf d7,lignec_1
chg_lc_1	rts
	and.l d6,(a5)
	or.l d5,4(a5)
	move.b #$75,chg_lc_1+1
	rts
	
lignec_2	ligne_c_1
	dbf d7,lignec_2
chg_lc_2	rts
	and.l d6,(a5)
	or.l d5,4(a5)
	move.b #$75,chg_lc_2+1
	rts
	
ligned_1	ligne_d_0
	dbf d7,ligned_1
chg_ld_1	rts
	or.w d5,(a5)
	and.w d6,2(a5)
	or.l d5,4(a5)
	move.b #$75,chg_ld_1+1
	rts
	
ligned_2	ligne_d_1
	dbf d7,ligned_2
chg_ld_2	rts
	or.w d5,(a5)
	and.w d6,2(a5)
	or.l d5,4(a5)
	move.b #$75,chg_ld_2+1
	rts
	
lignee_1	ligne_e_0
	dbf d7,lignee_1
chg_le_1	rts
	and.w d6,(a5)
	or.l d5,2(a5)
	or.w d5,6(a5)
	move.b #$75,chg_le_1+1
	rts
	
lignee_2	ligne_e_1
	dbf d7,lignee_2
chg_le_2	rts
	and.w d6,(a5)
	or.l d5,2(a5)
	or.w d5,6(a5)
	move.b #$75,chg_le_2+1
	rts
	
lignef_1	ligne_f_0
	dbf d7,lignef_1
chg_lf_1	rts
	or.l d5,(a5)
	or.l d5,4(a5)
	move.b #$75,chg_lf_1+1
	rts
	
lignef_2	ligne_f_1
	dbf d7,lignef_2
chg_lf_2	rts
	or.l d5,(a5)
	or.l d5,4(a5)
	move.b #$75,chg_lf_2+1
	rts

ombre_curs	move.l ecran,a0
	lea tab_blk2,a1
	
	move.w mousex,d0
	add.w #9,d0
	move.w d0,d1
	and.w #$fff0,d0
	and.w #$f,d1
	lsr.w #1,d0
	lsl.w #2,d1
	move.l (a1,d1.w),a1
	lea (a0,d0.w),a0
	
	move.w mousey,d0
	add.w #9,d0
	lea tab_ligne,a5
	add.w d0,d0
	move.w (a5,d0.w),d0
	lea (a0,d0.w),a0
	
n	set 6
	rept 16
	move.w (a1)+,n(a0)
	move.w (a1)+,8+n(a0)
n	set n+160
	endr
	
	rts
	
ombre_1	move.l ecran,a0
	lea tab_blk1,a1
	
	move.l pos_spr,a4
	move.w (a4)+,d0
	subq.w #7,d0
	move.w d0,d1
	and.w #$fff0,d0
	and.w #$f,d1
	lsr.w #1,d0
	lsl.w #2,d1
	move.l (a1,d1.w),a1
	lea (a0,d0.w),a0
	
	move.w (a4)+,d0
	addq.w #7,d0
	bra.s aff_ombre
	  
ombre_2	move.l ecran,a0
	lea tab_blk1,a1
	
recomm	move.l pos_spr,a4
	move.w (a4)+,d0
	cmp.w #-1,d0
	bne.s cont_ombre
	
	move.l #posxy,pos_spr
	bra.s recomm
	
cont_ombre	sub.w #10,d0
	move.w d0,d1
	and.w #$fff0,d0
	and.w #$f,d1
	lsr.w #1,d0
	lsl.w #2,d1
	move.l (a1,d1.w),a1
	lea (a0,d0.w),a0
	
	move.w (a4)+,d0
	addq.w #4,d0
	
aff_ombre	lea tab_ligne,a5
	add.w d0,d0
	move.w (a5,d0.w),d0
	lea (a0,d0.w),a0
	
n	set 6
	rept 32
	move.w (a1)+,d0
	or.w d0,n(a0)
	move.w (a1)+,d0
	or.w d0,8+n(a0)
	move.w (a1)+,d0
	or.w d0,16+n(a0)
n	set n+160
	endr
	
	rts
	
aff_curs	move.l ecran,a0
	lea (a0),a6
	lea tab_spr2,a1
	lea tab_msk2,a3
	
	move.w mousex,d0
	addq.w #8,d0
	move.w d0,d1
	and.w #$fff0,d0
	and.w #$f,d1
	lsr.w #1,d0
	lsl.w #2,d1
	move.l (a1,d1.w),a1
	move.l (a3,d1.w),a3
	lea (a0,d0.w),a0
	
	move.w mousey,d0
	addq.w #8,d0
	lea tab_ligne,a5
	add.w d0,d0
	move.w (a5,d0.w),d0
	lea (a0,d0.w),a0
	lea (a0),a5
	
	move.l pos_curs1,a4
	sub.w a6,a5
	move.w a5,(a4)
	
	rept 15
	sprite
	sprite
	lea 144(a0),a0
	endr
	sprite
	sprite
	
	rts
	
aff_spr1	move.l ecran,a0
	lea (a0),a6
	lea tab_spr1,a1
	lea tab_msk1,a3
	
	move.l pos_spr,a4
	move.w (a4)+,d0
	sub.w #14,d0
	move.w d0,d1
	and.w #$fff0,d0
	and.w #$f,d1
	lsr.w #1,d0
	lsl.w #2,d1
	move.l (a1,d1.w),a1
	move.l (a3,d1.w),a3
	lea (a0,d0.w),a0
	
	move.w (a4)+,d0
	move.l a4,pos_spr
	
	lea tab_ligne,a5
	add.w d0,d0
	move.w (a5,d0.w),d0
	lea (a0,d0.w),a0
	lea (a0),a5
	
	move.l pos_spr1,a4
	sub.w a6,a5
	move.w a5,(a4)
	bra.s aff_spr
	
aff_spr2	move.l ecran,a0
	lea (a0),a6
	lea tab_spr1,a1
	lea tab_msk1,a3
	
	move.l pos_spr,a4
	move.w (a4)+,d0
	sub.w #14,d0
	move.w d0,d1
	and.w #$fff0,d0
	and.w #$f,d1
	lsr.w #1,d0
	lsl.w #2,d1
	move.l (a1,d1.w),a1
	move.l (a3,d1.w),a3
	lea (a0,d0.w),a0
	
	move.w (a4)+,d0
	move.l a4,pos_spr
	
	lea tab_ligne,a5
	add.w d0,d0
	move.w (a5,d0.w),d0
	lea (a0,d0.w),a0
	lea (a0),a5
	
	move.l pos_spr3,a4
	sub.w a6,a5
	move.w a5,(a4)

aff_spr	rept 31
	sprite
	sprite
	sprite
	lea 136(a0),a0
	endr
	sprite
	sprite
	sprite
	
	rts
	
eff_curs	move.l pos_curs1,a2
	move.l ecran,a0
	move.l ecran2,a1
	move.w (a2),d0
	lea (a0,d0.w),a0
	lea (a1,d0.w),a1
	
n	set 0
	rept 17
	movem.l n(a1),d0-d5
	movem.l d0-d5,n(a0)
n	set n+160
	endr
	
	rts
	
eff_spr	move.l pos_spr1,a2
	move.l ecran,a0
	move.l ecran2,a1
	move.w (a2),d0
	lea (a0,d0.w),a0
	lea (a1,d0.w),a1
	
n	set 0
	rept 42
	movem.l n(a1),d0-d7
	movem.l d0-d7,n(a0)
n	set n+160
	endr
	
	rts
	
eff_spr2	move.l pos_spr3,a2
	move.l ecran,a0
	move.l ecran2,a1
	move.w (a2),d0
	lea (a0,d0.w),a0
	lea (a1,d0.w),a1

n	set 0
	rept 39
	movem.l n(a1),d0-d7
	movem.l d0-d7,n(a0)
n	set n+160
	endr
	
	rts

calc_curv	moveq #0,d0
	lea sin_tab,a0
	lea posxy,a1

cont_calc	move.w d0,d1
x1_1	muls #8,d1
sin1_x1	add.w #90,d1
reduit_1	cmp.w #360,d1
	bmi.s ok_1
	sub.w #360,d1
	bra.s reduit_1
ok_1	add.w d1,d1
	move.w (a0,d1.w),d1
	muls #65,d1
	lsl.l #2,d1
	swap d1

	move.w d0,d2
x2_1	muls #6,d2
sin2_x1	add.w #0,d2
reduit_2	cmp.w #360,d2
	bmi.s ok_2
	sub.w #360,d2
	bra.s reduit_2
ok_2	add.w d2,d2
	move.w (a0,d2.w),d2
	muls #65,d2
	lsl.l #2,d2
	swap d2
	add.w d2,d1
	add.w #155,d1
	move.w d1,(a1)+

	move.w d0,d1
y1_1	muls #8,d1
sin1_y1	add.w #0,d1
reduit_3	cmp.w #360,d1
	bmi.s ok_3
	sub.w #360,d1
	bra.s reduit_3
ok_3	add.w d1,d1
	move.w (a0,d1.w),d1
	muls #25,d1
	lsl.l #2,d1
	swap d1
	
	move.w d0,d2
y2_1	muls #8,d2
sin2_y1	add.w #90,d2
reduit_4	cmp.w #360,d2
	bmi.s ok_4
	sub.w #360,d2
	bra.s reduit_4
ok_4	add.w d2,d2
	move.w (a0,d2.w),d2
	muls #25,d2
	lsl.l #2,d2
	swap d2
	add.w d2,d1
	add.w #50,d1
	move.w d1,(a1)+

	move.w d0,d1
x1_2	muls #4,d1
sin1_x2	add.w #90,d1
reduit_5	cmp.w #360,d1
	bmi.s ok_5
	sub.w #360,d1
	bra.s reduit_5
ok_5	add.w d1,d1
	move.w (a0,d1.w),d1
	muls #55,d1
	lsl.l #2,d1
	swap d1

	move.w d0,d2
x2_2	muls #2,d2
sin2_x2	add.w #0,d2
reduit_6	cmp.w #360,d2
	bmi.s ok_6
	sub.w #360,d2
	bra.s reduit_6
ok_6	add.w d2,d2
	move.w (a0,d2.w),d2
	muls #55,d2
	lsl.l #2,d2
	swap d2
	add.w d2,d1
	add.w #170,d1
	move.w d1,(a1)+

	move.w d0,d1
y1_2	muls #15,d1
sin1_y2	add.w #0,d1
reduit_7	cmp.w #360,d1
	bmi.s ok_7
	sub.w #360,d1
	bra.s reduit_7
ok_7	add.w d1,d1
	move.w (a0,d1.w),d1
	muls #30,d1
	lsl.l #2,d1
	swap d1

	move.w d0,d2
y2_2	muls #1,d2
sin2_y2	add.w #90,d2
reduit_8	cmp.w #360,d2
	bmi.s ok_8
	sub.w #360,d2
	bra.s reduit_8
ok_8	add.w d2,d2
	move.w (a0,d2.w),d2
	muls #30,d2
	lsl.l #2,d2
	swap d2
	add.w d2,d1
	add.w #61,d1
	move.w d1,(a1)+
	
	addq.w #1,d0
	cmp.w #359,d0
	bls cont_calc
	move.w #-1,(a1)+
	rts
	
pred_spr	lea _sprite,a0
	lea buf_spr,a1
	moveq #31,d0
predec1	movem.l (a0)+,d2-d4
	movem.l d2-d4,(a1)
	lea 18(a1),a1
	dbf d0,predec1
	
	lea -576(a1),a0
	moveq #14,d0
predec2	moveq #31,d1
predec3	movem.l (a0)+,d2-d5
	movem.l d2-d5,(a1)
	move.w (a0)+,16(a1)
	roxr (a1)  
	roxr 6(a1)  
	roxr 12(a1)
	roxr 2(a1)  
	roxr 8(a1)  
	roxr 14(a1)  
	roxr 4(a1)  
	roxr 10(a1)  
	roxr 16(a1)  
	lea 18(a1),a1
	dbf d1,predec3
	dbf d0,predec2
	
	lea masque,a0
	lea buf_blk,a1
	lea buf_msk,a2
	moveq #31,d0
predec4	move.l (a0),(a1)
	move.w (a0)+,(a2)
	move.w (a0)+,4(a2)
	move.w (a2),2(a2)
	not.l (a2)+
	move.w (a2),2(a2)
	not.l (a2)+
	not.l (a2)+
	addq.l #6,a1
	dbf d0,predec4
	 
	lea -192(a1),a0
	moveq #14,d0
predec5	moveq #31,d1
predec6	move.l (a0)+,(a1)
	move.w (a0)+,4(a1)
	roxr (a1)+
	roxr (a1)+
	roxr (a1)+
	dbf d1,predec6
	dbf d0,predec5
	
	lea buf_msk,a0
	lea 384(a0),a1
	moveq #14,d0
predec7	moveq #31,d1
predec8	ori.w #$10,sr
	move.l (a0)+,(a1)
	move.l (a0)+,4(a1)
	move.l (a0)+,8(a1)
	roxr (a1)
	roxr 4(a1)
	roxr 8(a1)
	move.w (a1),2(a1)
	move.w 4(a1),6(a1)
	move.w 8(a1),10(a1)
	lea 12(a1),a1
	dbf d1,predec8
	dbf d0,predec7
	
	lea curs,a0
	lea buf_curs,a1
	moveq #15,d0
predec9	move.l (a0)+,(a1)+
	move.w (a0)+,(a1)+
	addq.l #6,a1
	dbf d0,predec9
	
	lea -192(a1),a0
	moveq #14,d0
predeca	moveq #15,d1
predecb	movem.l (a0)+,d2-d4
	movem.l d2-d4,(a1)
	roxr (a1)
	roxr 6(a1)
	roxr 2(a1)
	roxr 8(a1)
	roxr 4(a1)
	roxr 10(a1)
	lea 12(a1),a1
	dbf d1,predecb
	dbf d0,predeca
	
	lea curs_msk,a0
	lea curs_blk,a1
	lea curs_msk1,a2
	moveq #15,d0
predecc	move.w (a0),(a1)
	move.w (a0)+,(a2)
	move.w (a2),2(a2)
	not.l (a2)+
	not.l (a2)+
	addq.l #4,a1
	dbf d0,predecc
	
	lea -64(a1),a0
            moveq #14,d0
predecd	moveq #15,d1
predece	move.l (a0)+,(a1)
	roxr (a1)+
	roxr (a1)+
	dbf d1,predece
	dbf d0,predecd
	
	lea curs_msk1,a0
	lea 128(a0),a1
	moveq #14,d0
predecf	moveq #15,d1
predecg	ori.w #$10,sr
	move.l (a0)+,(a1)
	move.l (a0)+,4(a1)
	roxr (a1)
	roxr 4(a1)
	move.w (a1),2(a1)
	move.w 4(a1),6(a1)
	addq.l #8,a1
	dbf d1,predecg
	dbf d0,predecf
	rts
	
colorin	move.w #0,d7
bo_in	rept 3
	vsync
	movem.l d7/a6,-(sp)
	bsr aff_3d
	movem.l (sp)+,d7/a6
	endr
	move.w d7,d0
	move.l a6,a0
	bsr.s fade
	addq.w #1,d7
	cmp.w #8,d0
	ble.s bo_in
	rts

colorout	move.w #8,d7
bo_out	rept 3
	vsync
	movem.l d7/a6,-(sp)
	bsr aff_3d
	movem.l (sp)+,d7/a6
	endr
	move.w d7,d0
	move.l a6,a0
	bsr.s fade
	subq.w #1,d7
	tst.w d0
	bge.s bo_out
	rts

fade	lea $ffff8240.w,a1
	move.w #15,d1
loopf	move.w (a0)+,d2
	move.w d2,d3
	lsr.w #8,d3
	and.w #15,d3
	move.w d2,d4
	lsr.w #4,d4
	and.w #15,d4
	move.w d2,d5
	and.w #15,d5
	muls d0,d3
	divs #8,d3
	lsl.w #8,d3
	muls d0,d4
	divs #8,d4
	lsl.w #4,d4
	muls d0,d5
	divs #8,d5
	move.w d3,d2
	add.w d4,d2
	add.w d5,d2
	move.w d2,(a1)+
	dbf d1,loopf
	rts

musique	incbin 'prehis_1.mus'

	section data

len_kbd	dc.w end_kbd-tbl_kbd-1

tbl_kbd	dc.b $12,9
	dc.w 295,105
	dc.b $e,0
org_pos	dc.w 0,0
end_kbd
	
sin_tab	incbin 'sintab.bin'

pal_pres	dc.w $000,$776,$775,$764,$653,$120,$220,$543
	dc.w $432,$321,$210,$100,$110,$200,$300,$400
	
pal_opt	dc.w $111,$211,$222,$322,$333,$433,$444,$000
	dc.w $000,$000,$111,$211,$222,$322,$333

d_pal_fix	dc.w $000

pal_fix	dc.w $300
fin_pal	dc.w $700,$730,$770,$370,$070,$073,$077,$037
	dc.w $007,$307,$707,$737,$303,$777
	
pal_scroll	dc.w $000,$000,$800,$800,$100,$100,$900,$900
	dc.w $200,$200,$a00,$a00,$300,$300,$b00,$b00
	dc.w $400,$400,$c00,$c00,$500,$500,$d00,$d00
	dc.w $600,$600,$e00,$e00,$700,$700,$f00,$f00
	dc.w $f00,$f00,$700,$700,$e00,$e00,$600,$600
	dc.w $d00,$d00,$500,$500,$c00,$c00,$400,$400
	dc.w $b00,$b00,$300,$300,$a00,$a00,$200,$200
	dc.w $900,$900,$100,$100,$800,$800,$000,$000
	dc.w $000,$000,$800,$800,$990,$990,$110,$110
	dc.w $aa0,$aa0,$220,$220,$bb0,$bb0,$330,$330
	dc.w $440,$440,$cc0,$cc0,$550,$550,$dd0,$dd0
	dc.w $660,$660,$ee0,$ee0,$770,$770,$ff0,$ff0
	dc.w $ff0,$ff0,$770,$770,$ee0,$ee0,$660,$660
	dc.w $dd0,$dd0,$550,$550,$cc0,$cc0,$440,$440
	dc.w $bb0,$bb0,$330,$330,$aa0,$aa0,$220,$220
	dc.w $990,$990,$110,$110,$880,$880,$000,$000
	dc.w $000,$000,$080,$080,$010,$010,$090,$090
	dc.w $020,$020,$0a0,$0a0,$030,$030,$0b0,$0b0
	dc.w $040,$040,$0c0,$0c0,$050,$050,$0d0,$0d0
	dc.w $060,$060,$0e0,$0e0,$070,$070,$0f0,$0f0
	dc.w $0f0,$0f0,$070,$070,$0e0,$0e0,$060,$060
	dc.w $0d0,$0d0,$050,$050,$0c0,$0c0,$040,$040
	dc.w $0b0,$0b0,$030,$030,$0a0,$0a0,$020,$020
	dc.w $090,$090,$010,$010,$080,$080,$000,$000
	dc.w $000,$000,$088,$088,$011,$011,$099,$099
	dc.w $022,$022,$0aa,$0aa,$033,$033,$0bb,$0bb
	dc.w $044,$044,$0cc,$0cc,$055,$055,$0dd,$0dd
	dc.w $066,$066,$0ee,$0ee,$077,$077,$0ff,$0ff
	dc.w $0ff,$0ff,$077,$077,$0ee,$0ee,$066,$066
	dc.w $0dd,$0dd,$055,$055,$0cc,$0cc,$044,$044
	dc.w $0bb,$0bb,$033,$033,$0aa,$0aa,$022,$022
	dc.w $099,$099,$011,$011,$088,$088,$000,$000
	dc.w $000,$000,$008,$008,$001,$001,$009,$009
	dc.w $002,$002,$00a,$00a,$003,$003,$00b,$00b
	dc.w $004,$004,$00c,$00c,$005,$005,$00d,$00d
	dc.w $006,$006,$00e,$00e,$007,$007,$00f,$00f
	dc.w $00f,$00f,$007,$007,$00e,$00e,$006,$006
 	dc.w $00d,$00d,$005,$005,$00c,$00c,$004,$004
	dc.w $00b,$00b,$003,$003,$00a,$00a,$002,$002
	dc.w $009,$009,$001,$001,$008,$008,$000,$000
	dc.w $000,$000,$808,$808,$101,$101,$909,$909
	dc.w $202,$202,$a0a,$a0a,$303,$303,$b0b,$b0b
	dc.w $404,$404,$c0c,$c0c,$505,$505,$d0d,$d0d
	dc.w $606,$606,$e0e,$e0e,$707,$707,$f0f,$f0f
	dc.w $f0f,$f0f,$707,$707,$e0e,$e0e,$606,$606
	dc.w $d0d,$d0d,$505,$505,$c0c,$c0c,$404,$404
	dc.w $b0b,$b0b,$303,$303,$a0a,$a0a,$202,$202
	dc.w $909,$909,$101,$101,$808,$808,$000,$000
	dc.w $000,$000,$888,$888,$111,$111,$999,$999
	dc.w $222,$222,$aaa,$aaa,$333,$333,$bbb,$bbb
	dc.w $444,$444,$ccc,$ccc,$555,$555,$ddd,$ddd
	dc.w $666,$666,$eee,$eee,$777,$777,$fff,$fff
	dc.w $fff,$fff,$777,$777,$eee,$eee,$666,$666
	dc.w $ddd,$ddd,$555,$555,$ccc,$ccc,$444,$444
	dc.w $bbb,$bbb,$333,$333,$aaa,$aaa,$222,$222
	dc.w $999,$999,$111,$111,$888,$888,$000,$000
	dc.w $000,$000,$800,$800,$300,$300,$b00,$b00
	dc.w $400,$400,$c00,$c00,$510,$510,$d90,$d90
	dc.w $520,$520,$da0,$da0,$630,$630,$eb0,$eb0
	dc.w $640,$640,$ec0,$ec0,$750,$750,$fd0,$fd0
	dc.w $fd0,$fd0,$750,$750,$ec0,$ec0,$640,$640
	dc.w $eb0,$eb0,$630,$630,$da0,$da0,$520,$520
	dc.w $d90,$d90,$510,$510,$c00,$c00,$400,$400
	dc.w $b00,$b00,$300,$300,$800,$800,$000,$000
	dc.w $000,$000,$800,$800,$100,$100,$980,$980
	dc.w $210,$210,$a98,$a98,$321,$321,$ba9,$ba9
	dc.w $432,$432,$cba,$cba,$543,$543,$dcb,$dcb
	dc.w $654,$654,$edc,$edc,$765,$765,$fed,$fed
	dc.w $fed,$fed,$765,$765,$edc,$edc,$654,$654
	dc.w $dcb,$dcb,$543,$543,$cba,$cba,$432,$432
	dc.w $ba9,$ba9,$321,$321,$a98,$a98,$210,$210
	dc.w $980,$980,$100,$100,$800,$800,$000,$000
	dc.w $000,$000,$800,$800,$100,$100,$908,$908
	dc.w $201,$201,$a89,$a89,$312,$312,$b9a,$b9a
	dc.w $423,$423,$cab,$cab,$534,$534,$dbc,$dbc
	dc.w $645,$645,$ecd,$ecd,$756,$756,$fde,$fde
	dc.w $fde,$fde,$756,$756,$ecd,$ecd,$645,$645
	dc.w $dbc,$dbc,$534,$534,$cab,$cab,$423,$423
	dc.w $b9a,$b9a,$312,$312,$a89,$a89,$201,$201
	dc.w $908,$908,$100,$100,$800,$800,$000,$00
	dc.w $000,$000,$080,$080,$010,$010,$098,$098
	dc.w $021,$021,$8a9,$8a9,$132,$132,$9ba,$9ba
	dc.w $243,$243,$acb,$acb,$354,$354,$bdc,$bdc
	dc.w $465,$465,$ced,$ced,$576,$576,$dfe,$dfe
	dc.w $dfe,$dfe,$576,$576,$ced,$ced,$465,$465
	dc.w $bdc,$bdc,$354,$354,$acb,$acb,$243,$243
	dc.w $9ba,$9ba,$132,$132,$8a9,$8a9,$021,$021
	dc.w $098,$098,$010,$010,$080,$080,$000,$000
	dc.w $000,$000,$080,$080,$010,$010,$890,$890
	dc.w $120,$120,$9a8,$9a8,$231,$231,$ab9,$ab9
	dc.w $342,$342,$bca,$bca,$453,$453,$cdb,$cdb
	dc.w $564,$564,$dec,$dec,$675,$675,$efd,$efd
	dc.w $efd,$efd,$675,$675,$dec,$dec,$564,$564
	dc.w $cdb,$cdb,$453,$453,$bca,$bca,$342,$342
	dc.w $ab9,$ab9,$231,$231,$9a8,$9a8,$120,$120
	dc.w $890,$890,$010,$010,$080,$080,$000,$000
	dc.w $000,$000,$008,$008,$001,$001,$089,$089
	dc.w $012,$012,$89a,$89a,$123,$123,$9ab,$9ab
	dc.w $234,$234,$abc,$abc,$345,$345,$bcd,$bcd
	dc.w $456,$456,$cde,$cde,$567,$567,$def,$def
	dc.w $def,$def,$567,$567,$cde,$cde,$456,$456
	dc.w $bcd,$bcd,$345,$345,$abc,$abc,$234,$234
	dc.w $9ab,$9ab,$123,$123,$89a,$89a,$012,$012
	dc.w $089,$089,$001,$001,$008,$008,$000,$000
	dc.w $000,$000,$008,$008,$001,$001,$809,$809
	dc.w $102,$102,$98a,$98a,$213,$213,$a9b,$a9b
	dc.w $324,$324,$bac,$bac,$435,$435,$cbd,$cbd
	dc.w $546,$546,$dce,$dce,$657,$657,$edf,$edf
	dc.w $edf,$edf,$657,$657,$dce,$dec,$546,$546
	dc.w $cbd,$cbd,$435,$435,$bac,$bac,$324,$324
	dc.w $a9b,$a9b,$213,$213,$98a,$98a,$102,$102
	dc.w $809,$809,$001,$001,$008,$008,$000,$000
	dc.w $000,$000,$800,$800,$100,$100,$900,$900
	dc.w $200,$200,$a88,$a88,$311,$311,$b99,$b99
	dc.w $422,$422,$caa,$caa,$533,$533,$dbb,$dbb
	dc.w $644,$644,$ecc,$ecc,$755,$755,$fdd,$fdd
	dc.w $fdd,$fdd,$755,$755,$ecc,$ecc,$644,$644
	dc.w $dbb,$dbb,$533,$533,$caa,$caa,$422,$422
	dc.w $b99,$b99,$311,$311,$a88,$a88,$200,$200
	dc.w $900,$900,$100,$100,$800,$800,$000,$000
	dc.w $000,$000,$888,$888,$111,$111,$999,$999
	dc.w $222,$222,$aaa,$aaa,$333,$333,$bbb,$bbb
	dc.w $444,$444,$ccc,$ccc,$555,$555,$ddd,$ddd
	dc.w $666,$666,$eee,$eee,$777,$777,$fff,$fff
	dc.w $fff,$fff,$777,$777,$eee,$eee,$666,$666
	dc.w $ddd,$ddd,$555,$555,$ccc,$ccc,$444,$444
	dc.w $bbb,$bbb,$333,$333,$aaa,$aaa,$222,$222
	dc.w $999,$999,$111,$111,$888,$888,$000,$000
f_pal_scr	dc.w $000,$000,$800,$800,$100,$100,$900,$900
	dc.w $200,$200,$a00,$a00,$300,$300,$b00,$b00
	dc.w $400,$400,$c00,$c00,$500,$500,$d00,$d00
	dc.w $600,$600,$e00,$e00,$700,$700,$f00,$f00

pal_ste	dc.w $800,$100,$900,$200,$a00,$300,$b00,$400
	dc.w $c00,$500,$d00,$600,$e00,$700,$f00,$700
	dc.w $e00,$600,$d00,$500,$c00,$400,$b00,$300
	dc.w $a00,$200,$900,$100,$800,$880,$110,$990
	dc.w $220,$aa0,$330,$bb0,$440,$cc0,$550,$dd0
	dc.w $660
	dc.w $ee0,$770,$ff0,$770,$ee0,$660,$dd0,$550
	dc.w $cc0,$440,$bb0,$330,$aa0,$220,$990,$110
	dc.w $880,$080,$010,$090,$020,$0a0,$030,$0b0
	dc.w $040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
	dc.w $070,$0e0,$060,$0d0,$050,$0c0,$040,$0b0
	dc.w $030,$0a0,$020,$090,$010,$080,$088,$011
	dc.w $099,$022,$0aa,$033,$0bb,$044,$0cc,$055
	dc.w $0dd,$066,$0ee,$077,$0ff,$077,$0ee,$066
	dc.w $0dd,$055,$0cc,$044,$0bb,$033,$0aa,$022
	dc.w $099,$011,$088,$008,$001,$009,$002,$00a
	dc.w $003,$00b,$004,$00c,$005,$00d,$006,$00e
	dc.w $007,$00f,$007,$00e,$006,$00d,$005,$00c
	dc.w $004,$00b,$003,$00a,$002,$009,$001,$008
	dc.w $808,$101,$909,$202,$a0a,$303,$b0b,$404
	dc.w $c0c,$505,$d0d,$606,$e0e,$707,$f0f,$707
	dc.w $e0e,$606,$d0d,$505,$c0c,$404,$b0b,$303
	dc.w $a0a,$202,$909,$101,$808,$888,$111
	dc.w $999,$222,$aaa,$333,$bbb,$444,$ccc,$555
	dc.w $ddd,$666,$eee,$777,$fff,$777,$eee,$666
	dc.w $ddd,$555,$ccc,$444,$bbb,$333,$aaa,$222
	dc.w $999,$111,$888,$800,$300,$b00,$400,$c00
	dc.w $510,$d90,$520,$da0,$630,$eb0,$640,$ec0
	dc.w $750,$fd0,$750,$ec0,$640,$eb0,$630,$da0
	dc.w $520,$d90,$510,$c00,$400,$b00,$300,$800
	dc.w $800,$100,$980,$210,$a98,$321,$ba9,$432
	dc.w $cba,$543,$dcb,$654,$edc,$765,$fed,$765
	dc.w $edc,$654,$dcb,$543,$cba,$432,$ba9,$321
	dc.w $a98,$210,$980,$100,$800,$100,$908,$201
	dc.w $a89,$312,$b9a,$423,$cab,$534,$dbc,$645
	dc.w $ecd,$756,$fde,$756,$ecd,$645,$dbc,$534
	dc.w $cab,$423,$b9a,$312,$a89,$201,$908,$100
	dc.w $800,$080,$010,$098,$021,$8a9,$132,$9ba
	dc.w $243,$acb,$354,$bdc,$465,$ced,$576,$dfe
	dc.w $576,$ced,$465,$bdc,$354,$acb,$243,$9ba
	dc.w $132,$8a9,$021,$098,$010,$080,$010,$890
	dc.w $120,$9a8,$231,$ab9,$342,$bca,$453,$cdb
	dc.w $564,$dec,$675,$efd,$675,$dec,$564,$cdb
	dc.w $453,$bca,$342,$ab9,$231,$9a8,$120,$890
	dc.w $010,$080,$008,$001,$089,$012,$89a,$123
	dc.w $9ab,$234,$abc,$345,$bcd,$456,$cde,$567
	dc.w $def,$567,$cde,$456,$bcd,$345,$abc,$234
	dc.w $9ab,$123,$89a,$012,$089,$001,$008,$001
	dc.w $809,$102,$98a,$213,$a9b,$324,$bac,$435
	dc.w $cbd,$546,$dce,$657,$edf,$657,$dce,$546
	dc.w $cbd,$435,$bac,$324,$a9b,$213,$98a,$102
	dc.w $809,$001,$008,$800,$100,$900,$200,$a88
	dc.w $311,$b99,$422,$caa,$533,$dbb,$644,$ecc
	dc.w $755,$fdd,$755,$ecc,$644,$dbb,$533,$caa
	dc.w $422,$b99,$311,$a88,$200,$900,$100,$800
	dc.w $888,$111,$999,$222,$aaa,$333,$bbb,$444
	dc.w $ccc,$555,$ddd,$666,$eee,$777,$fff,$777
	dc.w $eee,$666,$ddd,$555,$ccc,$444,$bbb,$333
	dc.w $aaa,$222,$999,$111,$888
end_ste	dc.w $800,$100,$900,$200,$a00,$300,$b00,$400
	dc.w $c00,$500,$d00,$600,$e00,$700,$f00

pal_stf	dc.w $100,$200,$300,$400,$500,$600,$700,$700
	dc.w $600,$500,$400,$300,$200,$100,$110,$220
	dc.w $330,$440,$550,$660,$770,$660,$550,$440
	dc.w $330,$220,$110,$010,$020,$030,$040,$050
	dc.w $060,$070,$060,$050,$040,$030,$020,$010
	dc.w $011,$022,$033,$044,$055,$066,$077,$066
	dc.w $055,$044,$033,$022,$011,$001,$002,$003
	dc.w $004,$005,$006,$007,$006,$005,$004,$003
	dc.w $002,$001,$101,$202,$303,$404,$505,$606
	dc.w $707,$606,$505,$404,$303,$202,$101,$111
	dc.w $222,$333,$444,$555,$666,$777,$666,$555
	dc.w $444,$333,$222,$111,$300,$400,$510,$520
	dc.w $630,$640,$750,$640,$630,$520,$510,$400
	dc.w $300,$100,$210,$321,$432,$543,$654,$765
	dc.w $654,$543,$432,$321,$210,$100,$201,$312
	dc.w $423,$534,$645,$756,$645,$534,$423,$312
	dc.w $201,$100,$010,$021,$132,$243,$354,$465
	dc.w $576,$465,$354,$243,$132,$021,$010,$120
	dc.w $231,$342,$453,$564,$675,$564,$453,$342
	dc.w $231,$120,$010,$001,$012,$123,$234,$345
	dc.w $456,$567,$456,$345,$234,$123,$012,$001
	dc.w $102,$213,$324,$435,$546,$657,$546,$435
	dc.w $324,$213,$102,$001,$100,$200,$311,$422
	dc.w $533,$644,$755,$644,$533,$422,$311,$200
	dc.w $100,$111,$222,$333,$444,$555,$666,$777
	dc.w $666,$555,$444,$333,$222,$111
end_stf	dc.w $100,$200,$300,$400,$500,$600,$700,$700
	dc.w $600,$500,$400,$300,$200,$100,$110

eff_pal	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    
_sprite	dc.w $FE33,$A2CC,$FFFF,$BFE6,$5A99,$FFFE,$2EDF,$BE27
	dc.w $FFFF,$F39D,$81AE,$FFFC,$0CC7,$3C41,$63BE,$7F3C
	dc.w $AD06,$52F8,$24C7,$1CD8,$6327,$D3A4,$C7A0,$385A
	dc.w $2706,$3AEF,$3410,$F180,$1A00,$047C,$37C8,$23AF
	dc.w $3C10,$49E8,$0640,$B0F4,$0980,$1280,$1C00,$01D0
	dc.w $0180,$01E8,$0780,$1D00,$1A00,$00C8,$0090,$01E0
	dc.w $0280,$0C00,$0F40,$0240,$0130,$03C0,$0900,$0E80
	dc.w $0D40,$0040,$0260,$0390,$0100,$05C0,$0620,$0560
	dc.w $0640,$0780,$0180,$07C0,$0620,$0460,$0600,$0780
	dc.w $0000,$0330,$03C0,$09C0,$0440,$0F00,$03C0,$02D0
	dc.w $0320,$0CC0,$0100,$0E00,$00A0,$0178,$0180,$0600
	dc.w $0580,$1A00,$0038,$0148,$01A0,$1480,$0D00,$1A00
	dc.w $00BC,$002C,$00D0,$1000,$3F00,$3000,$00EC,$0038
	dc.w $00C0,$0000,$2100,$3E00,$002E,$0066,$0078,$7400
	dc.w $6200,$7800,$0040,$0006,$0078,$1200,$5E00,$6000
	dc.w $002C,$001D,$0032,$2400,$0000,$3800,$003F,$0025
	dc.w $0038,$0400,$2800,$3000,$001E,$001D,$001A,$1800
	dc.w $0000,$9000,$001A,$0004,$001B,$1800,$8800,$1000
	dc.w $0001,$0008,$000F,$4000,$C000,$0000,$0007,$0003
	dc.w $000C,$8000,$C000,$0000,$0003,$0005,$0006,$2000
	dc.w $0000,$C000,$0004,$0002,$0007,$A000,$8000,$4000
	dc.w $0002,$0000,$0003,$0000,$7000,$8000,$0000,$0003
	dc.w $0003,$C000,$E000,$1000,$0000,$0001,$0001,$1000
	dc.w $8800,$6000,$0001,$0001,$0000,$1800,$F000,$0000
	
masque	dc.w $FFFF,$FFFF,$FFFF,$FFFF,$7FFF,$FFFE,$7FFF,$FFFE
	dc.w $3FFF,$FFFC,$3FFF,$FFFC,$1F80,$01F8,$1F80,$01F8
	dc.w $0FC0,$03F0,$0FC0,$03F0,$07E0,$07E0,$07E0,$07E0
	dc.w $03F0,$0FC0,$03F0,$0FC0,$01F8,$1F80,$01F8,$1F80
	dc.w $00FC,$3F00,$00FC,$3F00,$007E,$7E00,$007E,$7E00
	dc.w $003F,$3C00,$003F,$3C00,$001F,$9800,$001F,$9800
	dc.w $000F,$C000,$000F,$C000,$0007,$E000,$0007,$E000
	dc.w $0003,$F000,$0003,$F000,$0001,$F800,$0001,$F800

curs	dc.w $FFF0,$FFD0,$FFE0,$FFE0,$FFA0,$8040,$CCC0,$DCC0
	dc.w $A380,$E580,$FD80,$8300,$E780,$C980,$B700,$F7C0
	dc.w $D0C0,$AF80,$C9E0,$CB60,$B4C0,$DFB0,$E4B0,$9B60
	dc.w $FE98,$F4D8,$AB30,$E70C,$A64C,$C5B8,$C306,$43AE
	dc.w $8254,$8193,$01B7,$814A,$00C6,$00C6,$00BC,$006C
	dc.w $006C,$0058,$0038,$0008,$0030,$0010,$0010,$0000

curs_msk	dc.w $FFF0,$FFE0,$FFC0,$FF80,$FF80,$FFC0,$FFE0,$FFF0
	dc.w $FFF8,$E7FC,$C3FE,$81FF,$00FE,$007C,$0038,$0010

carac	include 'carac.s'

base	incbin 'base.3p'

present	incbin 'g_dead.4p'

fonte	incbin 'fonte_01.dat'

datas_3d	incbin '3d_prism.dat'

mes_uk	incbin 'textdemo.cod'

mes_fr	incbin 'text_fr.cod'
	even

tab_font	
n	set 0
	rept 117
	dc.l fonte+n
n	set n+16
	endr

tab_ligne
n	set 0
	rept 200
	dc.w n
n	set n+160
	endr

tab_spr1
n	set 0
	rept 16
	dc.l buf_spr+n
n	set n+576
	endr

tab_msk1
n	set 0
	rept 16
	dc.l buf_msk+n
n	set n+384
	endr

tab_blk1
n	set 0
	rept 16
	dc.l buf_blk+n
n	set n+192
	endr

tab_spr2
n	set 0
	rept 16
	dc.l buf_curs+n
n	set n+192
	endr

tab_msk2
n	set 0
	rept 16
	dc.l curs_msk1+n
n	set n+128
	endr

tab_blk2
n	set 0
	rept 16
	dc.l curs_blk+n
n	set n+64
	endr

tab_dec_spr	dc.l $00010001,$00020002,$00040004,$00080008
	dc.l $00100010,$00200020,$00400040,$00800080
	dc.l $01000100,$02000200,$04000400,$08000800
	dc.l $10001000,$20002000,$40004000,$80008000
	
tab_dec_msk	dc.l $fffefffe,$fffdfffd,$fffbfffb,$fff7fff7
	dc.l $ffefffef,$ffdfffdf,$ffbfffbf,$ff7fff7f
	dc.l $fefffeff,$fdfffdff,$fbfffbff,$f7fff7ff
	dc.l $efffefff,$dfffdfff,$bfffbfff,$7fff7fff
	
choix_pal	dc.l aff_fix,aff_stf,aff_ste

tab_car	dc.l c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,ca,cb,cc
	dc.l cd,ce,cf
									
tab_pos	rept 2
	dc.l bye,rien,rien,rien,rien,rien,rien,rien,rien,rien
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	endr
	rept 6
	dc.l bye,rien,rien,rien,rien,rien,rien,s_x1,rien,s_x1_sin
	dc.l s_x1_sin,s_x1_sin,rien,rien,s_x2,rien,s_x2_sin,s_x2_sin
	dc.l s_x2_sin,rien
	endr
	rept 10
	dc.l rien,rien,rien,rien,rien,rien,rien,s_x1,rien,s_x1_sin
	dc.l s_x1_sin,s_x1_sin,rien,rien,s_x2,rien,s_x2_sin,s_x2_sin
	dc.l s_x2_sin,rien
	endr
	rept 3
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	endr
	rept 16
	dc.l rien,rien,rien,rien,rien,rien,rien,s_y1,rien,s_y1_sin
	dc.l s_y1_sin,s_y1_sin,rien,rien,s_y2,rien,s_y2_sin,s_y2_sin
	dc.l s_y2_sin,rien
	endr
	rept 8
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	endr
	rept 16
	dc.l rien,rien,rien,rien,rien,rien,rien,e_x1,rien,e_x1_sin
	dc.l e_x1_sin,e_x1_sin,rien,rien,e_x2,rien,e_x2_sin,e_x2_sin
	dc.l e_x2_sin,rien
	endr
	rept 3
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	endr
	rept 16
	dc.l rien,rien,rien,rien,rien,rien,rien,e_y1,rien,e_y1_sin
	dc.l e_y1_sin,e_y1_sin,rien,rien,e_y2,rien,e_y2_sin,e_y2_sin
	dc.l e_y2_sin,rien
	endr
	rept 8
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	endr
	rept 16
	dc.l rien,rien,rien,rien,rien,speed,rien,rien,rien,rien
	dc.l rien,color_typ,color_typ,color_typ,rien,rien,rien,rien
	dc.l cycle,rien
	endr
	rept 10
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	dc.l rien,rien,rien,rien,rien,rien,rien,rien,rien,rien
	endr
	
langue	dc.w 1
pal_cycle	dc.b $3c
vitesse	dc.b 2
pos_3d	dc.l datas_3d
s_pos_pal	dc.l pal_scroll
pal_pos	dc.l pal_fix
pos_spr1	dc.l pos1
pos_spr2	dc.l pos2
pos_spr3	dc.l pos3
pos_spr4	dc.l pos4
pos_curs1	dc.l curs1
pos_curs2	dc.l curs2
pos_spr	dc.l posxy
color1	dc.l posxy+16
color2	dc.l posxy+24
color3	dc.l posxy+32
color4	dc.l posxy+40
color5	dc.l posxy+48
color6	dc.l posxy+56
color7	dc.l posxy+64
color8	dc.l posxy+72
color9	dc.l posxy+80
colora	dc.l posxy+88
colorb	dc.l posxy+96
colorc	dc.l posxy+104
colord	dc.l posxy+112
colore	dc.l posxy+120
colorf	dc.l posxy+128
mes_pnt	dc.l mes_uk

	section bss
	
buffer	ds.b 96256
posxy	ds.b 2882
buf_spr	ds.b 576*16
buf_msk	ds.b 384*16
buf_blk	ds.b 192*16
buf_curs	ds.b 192*16
curs_msk1	ds.b 128*16
curs_blk	ds.b 64*16
anc_pal	ds.l 16
anc_vbl	ds.l 1
anc_tb	ds.l 1
anc_hbl	ds.l 1
anc_kbd	ds.l 1
anc_ecr	ds.l 1
_vsync	ds.l 1
ecran	ds.l 1
ecran1	ds.l 1
ecran2	ds.l 1
pos_pal	ds.l 1
pos1	ds.w 1
pos2	ds.w 1
pos3	ds.w 1
pos4	ds.w 1
curs1	ds.w 1
curs2	ds.w 1
mouse_buf	ds.w 3
mousek	ds.w 1
mousex	ds.w 1
mousey	ds.w 1
key	ds.w 1
m_flag	ds.w 1
bouton_d	ds.w 1
sav_col_typ	ds.w 1
res	ds.b 1
anc_freq	ds.b 1
mfp1	ds.b 1
mfp2	ds.b 1
mfp3	ds.b 1
mfp4	ds.b 1
mfp5	ds.b 1
mfp6	ds.b 1
mfp7	ds.b 1
mfp8	ds.b 1
mfp9	ds.b 1
compt	ds.b 1
fin	even
	end
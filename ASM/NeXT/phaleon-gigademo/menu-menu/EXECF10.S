finale = 1
nb_mul_scroll = 20 * nombre de multiple du scroll en bas
tempo = 0

wait_fin_degarde macro
.\@
 tst app_menu
 bne.s .\@
 endm
bgt
 ifne finale
 org $5000
 endc
 opt ow-
*******************************************************************
 ifeq finale
 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,s_ecr
 pea debut(pc)
 move #$26,-(sp)
 trap #14
 addq #6,sp
 move #1,-(sp)
 pea -1
 pea -1
 move #5,-(sp)
 trap #14
 lea 12(sp),sp
 clr -(sp)
 trap #1
sauve
 lea s_smfp,a0
 move.b $fffffa07.w,(a0)+
 move.b $fffffa09.w,(a0)+
 move.b $fffffa13.w,(a0)+
 move.b $fffffa17.w,(a0)+
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,s_color
 rts
restore
 lea s_smfp,a0
 move.b (a0)+,$fffffa07.w
 move.b (a0)+,$fffffa09.w
 move.b (a0)+,$fffffa13.w
 move.b (a0)+,$fffffa17.w
 movem.l s_color,d0-d7
 movem.l d0-d7,$ffff8240.w
 rts

debut
 bsr sauve
 endc
 move sr,-(sp)
 move #$2700,sr

* clavier
 move.b #$3,$fffffc00.w
 move.b #$96,$fffffc00.w
.lop
 tst.b $fffffc02.w
 btst #4,$fffffa01.w
 beq.s .lop
 btst #0,$fffffc00.w
 bne.s .lop
 move.b #$12,$fffffc02.w


 lea $ffff8240.w,a0
 moveq #7,d0
.clc
 clr.l (a0)+
 dbra d0,.clc
 clr.b $fffffa07.w
 clr.b $fffffa09.w
 move.b #$12,$fffffc02.w
 move.l a7,s_a7
 lea pile,a7
 move.l $70.w,s_70
 jsr init
 move #$2700,sr
 move.l $120.w,s_120
******** init de variable ******
 move.l #logo0_pal,palette0
 move.l #logo0a_pal,palette0a
 move.l #font_pal+15*32,palette2
 clr cp_vbl
 move.l #scroll,adr_scroll
 move.l #buffer_scroll,adr_buffer
 clr offset_scroll
 move.l #mess,adr_mess
 clr n_car
 clr n_car1
 clr n_car3
 move #8,n_car2
********************************
 clr app_menu
* init n_menu
 clr n_menu
 move #1,memory
 lea $80000,a0
 move.l (a0),d0
 move.l #"MIT.",(a0)
 move.l (a0),d1
 cmp.l #"MIT.",d1
 beq.s .okay_1040
 clr memory
.okay_1040 
 move.l d0,(a0)
* clear bss
 lea buffer_scroll,a0
 lea fin_ecr,a1
 moveq #0,d0
.clearb
 move.l d0,(a0)+
 cmp.l a1,a0
 blt.s .clearb
 clr hblauto
 
 lea $ffff8240.w,a0
 moveq #7,d0
.cleen
 clr.l (a0)+
 dbra d0,.cleen
 move.l #ecran,d0
 st d0
 addq.l #1,d0
 move.l d0,a0
 move.l d0,buf1
 lsr.l #8,d0
 lea $ffff8201.w,a1
 movep d0,(a1)
 move #(32000+60*160)/4-1,d0
.clear
 clr.l (a0)+
 dbra d0,.clear

 move.l buf1,a1
 lea logo0_graph,a0
 move #(113*160/8)-1,d0
.copy
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 dbra d0,.copy

 lea adr_menu,a0
 move n_menu,d0
 mulu #12,d0
 add d0,a0
 move.l (a0),palette1
 move.l (a0)+,palette1a
 move.l (a0)+,a1
 move.l (a0)+,a2
 jsr inscrit_demo

*
 lea traject0,a0
 move.l a0,adr_p
 lea 8*4(a0),a0
 move.l a0,adr_h
 lea 8*4(a0),a0
 move.l a0,adr_a
 lea 8*4(a0),a0
 move.l a0,adr_l
 lea 8*4(a0),a0
 move.l a0,adr_e
 lea 8*4(a0),a0
 move.l a0,adr_o
 lea 8*4(a0),a0
 move.l a0,adr_n

 lea traject1,a0
 move.l a0,adr_d1
 lea 8*4(a0),a0
 move.l a0,adr_e1
 lea 8*4(a0),a0
 move.l a0,adr_m1
 lea 8*4(a0),a0
 move.l a0,adr_o1
 
 move.l #vbl0,$70.w
 lea ste?,a0
 tst.b (a0)
 beq.s .pas_lane_replay_ste
 move.b #1,$ffff8901.w
 bra.s .stehehe
.pas_lane_replay_ste
 move.b #diviseur_timer,$fffffa19.w
 move.b #data_timer,$fffffa1f.w
 bclr #3,$fffffa17.w
 bset #5,$fffffa07.w
 bset #5,$fffffa13.w
 lea Routine_timer_a,a0
 move.l a0,$134.w
.stehehe

 move #$2300,sr
*** programme enfin ici.......

* on fait apparaitre le gros logo NeXT en fondu de couleur
 moveq #15-1,d7
.app0
 jsr vsync
 jsr vsync
 jsr vsync
 add.l #32,palette0
 add.l #32,palette0a
 dbra d7,.app0
 move #1,app_menu
 wait_fin_degarde
.loop
 jsr vsync
 jsr vsync
 jsr vsync
 move.b $fffffc02.w,d7
 tst memory
 bne.s .ark0
 tst n_menu
 beq.s .ark1
.ark0
 cmp.b #$b9,d7
 beq .fin
 cmp.b #$9c,d7
 beq .fin
 cmp.b #$f2,d7
 beq .fin
.ark1
 cmp.b #$50,d7
 bne.s .pas_fleche_bas
 cmp #3,n_menu
 blt.s .ret_0
 clr n_menu
 bra .fleche_haut
.ret_0
 addq #1,n_menu
.fleche_haut
 move #-1,app_menu
 wait_fin_degarde
 lea adr_menu,a0
 move n_menu,d0
 mulu #12,d0
 add d0,a0
 move.l (a0),palette1
 move.l (a0)+,palette1a
 move.l (a0)+,a1
 move.l (a0)+,a2
 jsr inscrit_demo
 move #1,app_menu
 wait_fin_degarde
 bra .loop
.pas_fleche_bas

 cmp.b #$48,d7
 bne.s .pas_fleche_haut
 moveq #1,d0
 tst n_menu
 bgt.s .preglo
 move #3,n_menu
 bra.s .fleche_bas
.preglo
 subq #1,n_menu
.fleche_bas
 move #-1,app_menu
 wait_fin_degarde
 lea adr_menu,a0
 move n_menu,d0
 mulu #12,d0
 add d0,a0
 move.l (a0),palette1
 move.l (a0)+,palette1a
 move.l (a0)+,a1
 move.l (a0)+,a2
 jsr inscrit_demo
 move #1,app_menu
 wait_fin_degarde
 bra .loop
.pas_fleche_haut


 bra .loop
******************************
.fin
 move #-1,app_menu
 wait_fin_degarde
*** type du loader
 clr type_loader
 st hblauto
 jsr vsync
 lea $ffff8240.w,a0
 moveq #7,d0
.fg
 clr.l (a0)+
 dbra d0,.fg
 
 move.l buf1,a0
 move #3999,d0
.clfg
 clr.l (a0)+
 clr.l (a0)+
 dbra d0,.clfg

 lea choi,a0
 move.l buf1,a1
 lea $ffff8240.w,a2
 moveq #7,d0
.tu0
 move.l (a0)+,(a2)+
 dbra d0,.tu0
 lea 160*60(a1),a1
 move #(160*16)/4-1,d0
.ty1
 move.l (a0)+,(a1)+
 dbra d0,.ty1
 lea 160*60(a1),a1
 move #(160*16)/4-1,d0
.ty2
 move.l (a0)+,(a1)+
 dbra d0,.ty2


 jsr aff_fleche
.waitu
 jsr vsync
 jsr vsync
 btst #0,$fffffc00.w
 beq.s .waitu
 move.b $fffffc02.w,d0
 cmp.b #$50,d0
 bne.s .pas_b
.hut
 eor #1,type_loader
 jsr aff_fleche
 bra.s .waitu
.pas_b
 cmp.b #$48,d0
 beq.s .hut 
 cmp.b #$1c,d0
 beq.s .pwaitu
 cmp.b #$72,d0
 beq.s .pwaitu
 cmp.b #$39,d0
 bne.s .waitu
.pwaitu

.fin_fin
 jsr fin
 move #$2700,sr
 ifeq finale
 bsr restore
 move.l s_120,$120.w
 move.l s_70,$70.w
 move.l s_a7,a7
 move (sp)+,sr
 rts
 elseif
 move.l #rte,s_70
* suite !!!!!!!!!!!!!!!!!!!!!!!!!!!!
 lea menu_dungeon,a0
 cmp #3,n_menu
 bne.s .pas_menu_amiga
 lea menu_amiga,a0
.pas_menu_amiga
 cmp #2,n_menu
 bne.s .pas_menu_list
 lea menu_list,a0
.pas_menu_list
 tst n_menu
 bgt.s .pas_shad
 lea menu_shad,a0
.pas_shad
 move type_loader,2(a0)
 eor #1,2(a0)
 jmp (a0)
menu_dungeon incbin execf0.dat
 even
menu_amiga incbin execf10.dat
 even
menu_list incbin execf20.dat
 even
menu_shad incbin execf30.dat
 opt p-,o+,w+
 endc
vsync
 move cp_vbl,d0
.vsync
 cmp cp_vbl,d0
 beq.s .vsync
 rts
rte rte
aff_fleche
 move.l buf1,a1
 lea flech,a0
 move type_loader,d0
 mulu #60+16,d0
 add #60-1,d0
 mulu #160,d0
 add d0,a1
x set 0
 rept 18
 move.l (a0)+,x+144(a1)
 move.l (a0)+,x+4+144(a1)
 move.l (a0)+,x+8+144(a1)
 move.l (a0)+,x+12+144(a1)
 move.l (a0)+,x(a1)
 move.l (a0)+,x+4(a1)
 move.l (a0)+,x+8(a1)
 move.l (a0)+,x+12(a1)
x set x+160
 endr

 move.l buf1,a1
 move type_loader,d0
 eor #1,d0
 mulu #60+16,d0
 add #60-1,d0
 mulu #160,d0
 add d0,a1
 moveq #0,d0
x set 0
 rept 18
 move.l d0,x+144(a1)
 move.l d0,x+4+144(a1)
 move.l d0,x+8+144(a1)
 move.l d0,x+12+144(a1)
 move.l d0,x(a1)
 move.l d0,x+4(a1)
 move.l d0,x+8(a1)
 move.l d0,x+12(a1)
x set x+160
 endr
 rts


vhbl0a = 49
vhbl0b = 61
******** vbl
vbl0        * tt ce ki doit se faire en haut de vbl !
 clr.b $ffff8260.w
 movem.l d0-a6,-(sp)
*
 addq #1,cp_vbl

 clr.b $fffffa1b.w
 tst hblauto
 bne.s .pas_hbl
 move.l palette0,a0
 movem.l (a0),d0-d7
 movem.l d0-d7,$ffff8240.w
* on install la hbl
 move.l #hbl0a,$120.w
 bset #0,$fffffa07.w
 bset #0,$fffffa13.w
 move.b #$40,$fffffa17.w
 move.b #vhbl0a,$fffffa21.w
 move.b #8,$fffffa1b.w
*
* bra.s .pas_hbl1
.pas_hbl
*.pas_hbl1

* movem.l d0-a6,-(sp)
 jsr routine_calcul

 tst hblauto
 bne .rien__0
* recopie scrolltext en bas !!! seulement 18 multiples
 move.l adr_buffer,a0
 move offset_scroll,d0
 lsl #3,d0
 add d0,a0
 move.l buf1,a1
 lea 202*160(a1),a1 *-31 au lieu de -15
*x set 0
* rept 31
 moveq #31-1,d7
.loop
 movem.l (a0)+,d0-d6/a2-a6
 movem.l d0-d6/a2-a6,(a1)
 movem.l (a0)+,d0-d6/a2-a6
 movem.l d0-d6/a2-a6,12*4(a1)
 movem.l (a0)+,d0-d6/a2-a6
 movem.l d0-d6/a2-a6,24*4(a1)
 movem.l (a0)+,d0-d3
 movem.l d0-d3,36*4(a1)
 lea 160(a1),a1
*x set x+160
 lea 8*(nb_mul_scroll)(a0),a0
 dbra d7,.loop
* endr

 move.l adr_buffer,d0
 cmp.l #buffer_scroll,d0
 bgt .pas_change
 add.l #(31*8*nb_mul_scroll*2),adr_buffer



 bsr recopie_mul

 move offset_scroll,d0
 addq #1,d0
 move d0,offset_scroll
 btst #0,d0
 bne.s .pas_write_car
 cmp #nb_mul_scroll,d0
 blt.s .ok_pas_fin
 clr offset_scroll
.ok_pas_fin
 bsr write_car
.pas_write_car


 bra.s .pas_changef
.pas_change 
 sub.l #(31*8*nb_mul_scroll*2),adr_buffer
.pas_changef

 move app_menu,d0
 beq .tout_va_bien1
 tst d0
 bmi .baisse
 move d0,d1
 lsr d1
 lsl #5,d1
 move.l palette1,a0
 add d1,a0
 move.l a0,palette1a
 addq #1,d0
 cmp #16*2,d0
 blt.s .tout_va_bien0
 moveq #0,d0
 bra .tout_va_bien0
.baisse
 move #16*2,d1
 add d0,d1
 lsr d1
 lsl #5,d1
 move.l palette1,a0
 add d1,a0
 move.l a0,palette1a
 subq #1,d0
 cmp #-16*2,d0
 bgt.s .tout_va_bien0
 moveq #0,d0
.tout_va_bien0
 move d0,app_menu
.tout_va_bien1
** 

 bsr efface_sprites
 bsr affiche_gere_sprites
 bsr efface_sprites1
 bsr affiche_gere_sprites1
 cmp #8,n_car2
 blt.s .eff_car
 bsr affiche_car
 bra.s .pas_eff_car
.eff_car
 bsr eff_car
.pas_eff_car
.rien__0
 ifne tempo
 eor #$777,$ffff8240.w
 dcb 20,$4e71
 eor #$777,$ffff8240.w
 endc
 movem.l (sp)+,d0-a6
 rte


hbl0a
 clr.b $fffffa1b.w
 move.b #vhbl0b-vhbl0a,$fffffa21.w
 move.b #8,$fffffa1b.w
 move.l #hbl0b,$120.w
 move.l #$7040705,$ffff8242.w
 move.l #$7060707,$ffff8246.w
 rte

hbl0b
 clr.b $fffffa1b.w
 move.b #113-vhbl0b,$fffffa21.w
 move.b #8,$fffffa1b.w
 move.l #hbl0,$120.w
 pea (a0)
 move.l palette0a,a0
 addq #2,a0
 move.l (a0)+,$ffff8242.w
 move.l (a0)+,$ffff8246.w
 move.l (sp)+,a0
 rte


hbl0
 clr.b $fffffa1b.w
 pea (a0)
 pea (a1)

 move.b #199-113-2,$fffffa21.w
 move.b #8,$fffffa1b.w
 move.l #hbl1,$120.w
 move.l palette1a,a0
 lea $ffff8240.w,a1
 rept 8
 move.l (a0)+,(a1)+
 endr

 move.l (sp)+,a1
 move.l (sp)+,a0
 rte

hbl1
 clr.b $fffffa1b.w
 movem.l a0/d0/d1/a1,-(sp)
 lea $ffff8205.w,a0
 move.l buf1,d0
 add.l #$7c00,d0
 lsr.l #8,d0
 moveq #0,d1
.pol0
 movep (a0),d1
 cmp.l d0,d1
 bne.s .pol0
 moveq #40,d1
 dcb 20,$4e71
 move sr,-(sp)
 move #$2700,sr
 lea $ffff8209.w,a0
 moveq #0,d0
.polm
 move.b (a0),d0
 sub.b #$b0+20,d0
 bmi.s .polm
 sub d0,d1
 lsl d1,d0
 clr.b $ffff820a.w
 dcb 30,$4e71        *ou 39
 move.b #2,$ffff820a.w
 move (sp)+,sr
 move.l palette2,a0
 lea $ffff8240.w,a1
 rept 8
 move.l (a0)+,(a1)+
 endr
 movem.l (sp)+,a0/d0/d1/a1
 rte


write_car
 moveq #0,d0
 move.l adr_scroll,a1
 move.b (a1)+,d0
 bne.s .suite_car
 lea scroll,a1
 move.b (a1)+,d0
.suite_car
 move.l a1,adr_scroll

 cmp.b #",",d0
 bne.s .pas_vir
 moveq #26,d0
 bra .pas_space
.pas_vir

 cmp.b #".",d0
 bne.s .pas_vir0
 moveq #27,d0
 bra .pas_space
.pas_vir0

 cmp.b #"!",d0
 bne.s .pas_vir1
 moveq #28,d0
 bra .pas_space
.pas_vir1

 cmp.b #"?",d0
 bne.s .pas_vir2
 moveq #29,d0
 bra .pas_space
.pas_vir2

 cmp.b #"0",d0
 bne.s .pas_vir3
 moveq #14,d0
 bra .pas_space
.pas_vir3

 cmp.b #"1",d0
 bne.s .pas_vir4
 moveq #8,d0
 bra .pas_space
.pas_vir4

 cmp.b #"2",d0
 bne.s .pas_vir5
 moveq #30,d0
 bra .pas_space
.pas_vir5

 cmp.b #"3",d0
 bne.s .pas_vir6
 moveq #31,d0
 bra .pas_space
.pas_vir6

 cmp.b #"4",d0
 bne.s .pas_vir7
 moveq #32,d0
 bra .pas_space
.pas_vir7

 cmp.b #"5",d0
 bne.s .pas_vir8
 moveq #18,d0
 bra.s .pas_space
.pas_vir8

 cmp.b #"6",d0
 bne.s .pas_vir9
 moveq #33,d0
 bra.s .pas_space
.pas_vir9

 cmp.b #"7",d0
 bne.s .pas_vir10
 moveq #34,d0
 bra.s .pas_space
.pas_vir10

 cmp.b #"8",d0
 bne.s .pas_vir11
 moveq #35,d0
 bra.s .pas_space
.pas_vir11

 cmp.b #"9",d0
 bne.s .pas_vir12
 moveq #6,d0
 bra.s .pas_space
.pas_vir12


 cmp.b #"'",d0
 bne.s .pas_vir13
 moveq #36,d0
 bra.s .pas_space
.pas_vir13

 cmp.b #":",d0
 bne.s .pas_vir14
 moveq #37,d0
 bra.s .pas_space
.pas_vir14

 cmp.b #"(",d0
 bne.s .pas_vir15
 moveq #38,d0
 bra.s .pas_space
.pas_vir15

 cmp.b #")",d0
 bne.s .pas_vir16
 moveq #39,d0
 bra.s .pas_space
.pas_vir16

 cmp.b #"-",d0
 bne.s .pas_vir17
 moveq #40,d0
 bra.s .pas_space
.pas_vir17

 cmp.b #";",d0
 bne.s .pas_vir18
 moveq #41,d0
 bra.s .pas_space
.pas_vir18

 sub.b #"A",d0
 bmi.s .space
 cmp.b #"Z",d0
 bgt.s .space
 cmp.b #" ",d0
 bne.s .pas_space
.space
 moveq #42,d0
.pas_space
 mulu #8*(2+3)*31,d0


 lea buffer_scroll+nb_mul_scroll*8,a1
 lea (31*8*nb_mul_scroll*2)(a1),a2
 move offset_scroll,d1
 lsl #3,d1
 add d1,a1
 add d1,a2
 
 lea font,a0
 add.l d0,a0

x set 0
 rept 31
 movem.l (a0)+,d0-d3
 movem.l d0-d3,x(a2)
x set x+nb_mul_scroll*2*8
 endr

x set 0
 rept 31
 movem.l (a0)+,d0-d5
 movem.l d2-d5,x(a1)
 or.l d0,x-8(a1)
 or.l d1,x-4(a1)
x set x+nb_mul_scroll*2*8
 endr

 rts

inscrit_demo
 move.l buf1,a3
 lea 160*116(a3),a3
 move #(86*160)/2-1,d7
 moveq #0,d0
.clr
 move d0,(a3)+
 dbra d7,.clr

 move.l buf1,a3
 lea 160*116(a3),a3
.copya
 move.b (a1)+,(a3)+
 cmp.l a2,a1
 blt.s .copya

 move.l buf1,a0
 lea 160*116(a0),a0
 bsr depack

 tst memory
 bne.s .pas_520
 tst n_menu
 bne.s .pas_520
 move.l buf1,a1
 lea 160*116(a1),a1
 moveq #84-1,d1
* move.l #$aaaaaaaa,d2
 move.l #$88888888,d2
 move.l #$88888888,d3
.copyb
 moveq #160/8-1,d0
 move.l d2,d4
 or.l d3,d4
.copyc
 and.l d4,(a1)+
 and.l d4,(a1)+
 dbra d0,.copyc
 ror.l d2
 rol.l d3
 dbra d1,.copyb
.pas_520

 rts

recopie_mul
**** recopie le 16 pixel a droite de pointeur+largeur_buffer a sa gauche
 lea buffer_scroll,a1
 move.l a1,a0
 lea nb_mul_scroll*8(a0),a0
*
 lea buffer_scroll+(31*8*nb_mul_scroll*2),a3
 move.l a3,a2
 lea nb_mul_scroll*8(a2),a2
*
 move offset_scroll,d0
 lsl #3,d0
 add d0,a0
 add d0,a1
 add d0,a2
 add d0,a3
x set 0
 rept 31
 move.l x-8(a0),x-8(a1)
 move.l x-4(a0),x-4(a1)
 move.l x(a0),x(a1)
 move.l x+4(a0),x+4(a1)

 move.l x(a2),x(a3)
 move.l x+4(a2),x+4(a3)
x set x+nb_mul_scroll*2*8
 endr
 rts




gere
 move.l (a0),a1
 move.l (a1)+,d0
 tst.l d0
 bpl.s .ps
 lea traject0,a1
 move.l a1,(a0)
 move.l (a1)+,d0
.ps
 move.l d0,(a2)+
 move.l a1,(a0)
 rts

gere1
 move.l (a0),a1
 move.l (a1)+,d0
 tst.l d0
 bpl.s .ps
 lea traject1,a1
 move.l a1,(a0)
 move.l (a1)+,d0
.ps
 move.l d0,(a2)+
 move.l a1,(a0)
 rts
 
affiche_gere_sprites
* gere la courbe
 lea buffer_coord0,a2
 lea adr_p,a0
 bsr gere
 lea adr_h,a0
 bsr gere
 lea adr_a,a0
 bsr gere
 lea adr_l,a0
 bsr gere
 lea adr_e,a0
 bsr gere
 lea adr_o,a0
 bsr gere
 lea adr_n,a0
 bsr gere

 lea sprite,a0
 moveq #7-1,d7
 move #6*12*16,d6
 lea buffer_coord0,a4
.affsp
 move.l buf1,a1
 move (a4)+,d0
 add d0,d0
 add .tabley160(pc,d0.w),a1
 bra .pas_t
.tabley160
x set 0
 rept 50
 dc x
x set x+160
 endr
.pas_t
 move.l a0,a3
 move (a4)+,d0
 move d0,d1
 and #$f,d0
 and #$fff0,d1
 lsr d1
 add d1,a1
 add d0,d0
 add .tablex1440(pc,d0.w),a3
 bra.s .pas_t1
.tablex1440
x set 0
 rept 16
 dc x
x set x+1440
 endr
.pas_t1
 move.l a3,a2
 lea 8*12(a2),a2
 add d6,a2
 rept 12
 movem.l (a1),d0-d3
 move.l (a3)+,d4
 and.l d4,d0
 and.l d4,d1
 or.l (a2)+,d0
 or.l (a2)+,d1
 move.l (a3)+,d4
 and.l d4,d2
 and.l d4,d3
 or.l (a2)+,d2
 or.l (a2)+,d3
 movem.l d0-d3,(a1)
 lea 160(a1),a1
 endr
 sub #12*16,d6
 dbra d7,.affsp
 rts

affiche_gere_sprites1
* gere la courbe
 lea buffer_coord1,a2
 lea adr_d1,a0
 bsr gere1
 lea adr_e1,a0
 bsr gere1
 lea adr_m1,a0
 bsr gere1
 lea adr_o1,a0
 bsr gere1

 lea sprite1,a0
 moveq #4-1,d7
 move #3*12*16,d6
 lea buffer_coord1,a4
.affsp
 move.l buf1,a1
 add (a4)+,a1
 move.l a0,a2

 moveq #0,d0
 move.b (a4)+,d0
 add d0,a1

 move.b (a4)+,d0
 add .tablex768(pc,d0.w),a2
 lea sprite,a3
 add .tablex768+2(pc,d0.w),a3
 bra.s .pas_t1
.tablex768
x set 0
x1 set 0
 rept 16
 dc x,x1
x set x+768
x1 set x1+1440
 endr
.pas_t1
 add d6,a2
 rept 12
 movem.l (a1),d0-d3
 move.l (a3)+,d4
 and.l d4,d0
 and.l d4,d1
 or.l (a2)+,d0
 or.l (a2)+,d1
 move.l (a3)+,d4
 and.l d4,d2
 and.l d4,d3
 or.l (a2)+,d2
 or.l (a2)+,d3
 movem.l d0-d3,(a1)
 lea 160(a1),a1
 endr
 sub #12*16,d6
 dbra d7,.affsp
 rts


efface_sprites
 moveq #7-1,d7
 lea buffer_coord0,a4
.affsp
 move.l buf1,a1
 move (a4)+,d0
 add d0,d0
 lea logo0_graph,a0
 move .tabley160(pc,d0.w),d0
 add d0,a1
 add d0,a0
 bra .pas_t
.tabley160
x set 0
 rept 50
 dc x
x set x+160
 endr
.pas_t
 move (a4)+,d0
 and #$fff0,d0
 lsr d0
 add d0,a1
 add d0,a0
 rept 12
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 lea 160-16(a1),a1
 lea 160-16(a0),a0
 endr
 dbra d7,.affsp
 rts

efface_sprites1
 moveq #4-1,d7
 lea buffer_coord1,a4
.affsp
 move.l buf1,a1
 lea logo0_graph,a0
 move (a4)+,d0
 add d0,a1
 add d0,a0
 moveq #0,d0
 move.b (a4)+,d0
 add d0,a1
 add d0,a0
 rept 12
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 lea 160-16(a1),a1
 lea 160-16(a0),a0
 endr
 addq #1,a4
 dbra d7,.affsp
 rts





buffer_coord0
 dc.w 30,100
 dc.w 21,100-13
 dc.w 18,70
 dc.w 17,56
 dc.w 16,42
 dc.w 15,28
 dc.w 14,14

buffer_coord1
 dc.w 20,160
 dc.w 20,160
 dc.w 20,160
 dc.w 20,160



affiche_car
 lea logo0_graph,a0
 lea (vhbl0a+3)*160(a0),a0
 move.l buf1,a2
 lea (vhbl0a+3)*160(a2),a2
 move n_car,d0
 cmp #40,d0
 blt.s .okl
 clr n_car2
 moveq #0,d0
 move d0,n_car
 add #256,n_car3
 cmp #5*256,n_car3
 blt.s .okl
 clr n_car3
.okl
 move d0,d1
 and #$fffe,d0
 add d0,d0
 add d0,d0
 add d0,a0
 add d0,a2
 and #1,d1
 add d1,a0
 add d1,a2
 moveq #0,d1
 move.l adr_mess,a3
 move.b (a3),d1
 bne.s .ok1
 lea mess,a3
 move.b (a3),d1
 move.l a3,adr_mess
.ok1 
 lea dat_car,a4
 moveq #0,d0
 bra.s .ok3
.ok2
 add #64,d0
.ok3
 cmp.l #edat_car,a4
 bge .ad_mess
 cmp.b (a4)+,d1
 bne.s .ok2
 lea pfont,a1
 add d0,a1
 move n_car1,d1
 lea matrice,a3
 add n_car3,a3
 lsl #5,d1
 add d1,a3
x set 0
 rept 8
 move.l (a3)+,d2
 movep.l x(a0),d0
 move.l (a1)+,d1
 move.l (a1)+,d3
 and.l d2,d3
 not.l d2
 or.l d2,d1
 and.l d1,d0

 or.l d3,d0
 movep.l d0,x(a2)
x set x+160
 endr
 bra.s .gere
.ad_mess
x set 0
 rept 8
 movep.l x(a0),d0
 movep.l d0,x(a2)
x set x+160
 endr
.gere
 addq #1,n_car1
 cmp #8,n_car1
 blt.s .ok4
 clr n_car1
 addq #1,n_car
 addq.l #1,adr_mess
.ok4
 rts

eff_car
 lea logo0_graph,a0
 lea (vhbl0a+3)*160(a0),a0
 move.l buf1,a1
 lea (vhbl0a+3)*160(a1),a1
 move n_car2,d0
 move d0,d1
 lsr d1
 mulu #160,d1
 btst #0,d0
 beq.s .lop
 lea 160*7(a0),a0
 lea 160*7(a1),a1
 neg d1
.lop
 add d1,a0
 add d1,a1
x set 0
 rept 4
 movem.l (a0)+,d0-d7/a2-a3
 movem.l d0-d7/a2-a3,x(a1)
x set x+10*4
 endr
 addq #1,n_car2
 rts
taille ds.l 1
 include decrunch.s
 even
 include strkmit7.s
 data
dat_car dc.b "ABCDEFGHIJKLMNOPQRSTUVWXYZ?½!., 0123456789"
edat_car
 even
matrice
 incbin mat0.dat
 incbin mat1.dat
 incbin mat2.dat
 incbin mat3.dat
 incbin mat4.dat
 even
**** dc.b "                                        ",0
mess dc.b "    WELCOME TO THE MENU OF THE MENUS    "
     dc.b " PRESS ARROWS TO SELECT AND SPACE TO GO "
     dc.b "  THIS MENU WAS ENTIRELY CODED BY MIT   "
     DC.B "        ALL GRAPHICS BY CHROMIX         "
     DC.B " EXCEPT THE FONT BY JUMPING JACK FLASH  "       
     DC.B "             MUSIC  BEAT                "
     DC.B "            ½ NEXT APRIL 1992           "
     DC.B "  NOW SOME INFORMATION ABOUT THE MENUS  "
     DC.B "   SHADOW MENU , YOU MOVE THE BEAST     "
     DC.B "WITH THE ARROWS, WHEN YOU WANT TO SEE A "
     DC.B "  SCREEN, PRESS SPACE, RETURN OR ENTER  "
     DC.B "   DUNGEON MENU , FIND ALL THE DOORS    "
     DC.B "    BEWARE OF THE TELEPORTING AREAS,    "
     DC.B " THE ROTATIVE PADS ,AND THE DUMMY WALLS "
     DC.B "THERE ARE SOME HIDDEN SCREENS, FIND THEM"
     DC.B "THE ALTERNATIVE MENU ,YOU CANNOT SELECT "
     DC.B "   THE HIDDEN SCREEN WITH THIS MENU !!  "
     DC.B " THE AMIGA MENU , LIKE THE AMIGA DEMOS  "
     DC.B " THE SCREENS ARE LOADED, NO SELECTION   "
     DC.B "YOU CANNOT SEE THE HIDDEN SCREENS, LIKE "
     DC.B "IN THE ALTERNATIVE MENU ,  GOOD LUCK !!!"
     DC.B " WE WERE PROUD TO RELEASE THIS DEMO !!  "
     DC.B " ENJOY IT OR SCRATCH IT , BUT PLEASE  , "
     DC.B "      RESPECT OUR HARD WORK !!!         "
     DC.B "SEE YOU SOON PERHAPS IN OUR NEW GAME OR "
     DC.B "    IN OUR NEXT DEMO OR CHARTS !!!!     "
     DC.B "   BYE !!! SEE THE LOWER SCROLL TO SEE  "
     DC.B "     ALL THE GREETINGS !!!!!!!!!!!      "
     DC.B "                                        "
     DC.B "                                        ",0 
 even
 even
pfont incbin pfont.dat
sprite incbin sprite0.dat
sprite1 incbin sprite1.dat
 even
adr_menu
 dc.l shadow_pal,shadow,fshadow
 dc.l dungeon_pal,dungeon,alternative
 dc.l alternative_pal,alternative,amiga
 dc.l amiga_pal,amiga,shadow

traject1 incbin  traject2.dat
traject0 incbin  traj1.dat
logo0_graph incbin logo0.dat
logo0_pal incbin logo0.pal
logo0a_pal incbin logo0a.pal
font incbin font.dat
  ds.l 31*10

font_pal incbin font.pal

dungeon_pal incbin dungeon.pal
amiga_pal incbin amiga.pal
alternative_pal incbin alternat.pal
shadow_pal incbin shadow.pal

dungeon incbin dungeon.dat
alternative  incbin alt.dat
amiga incbin ami.dat
shadow incbin shadow.dat
fshadow

choi incbin fontchoi.dat
flech incbin flechoi.dat
 even
scroll
* dc.b "  ABCDEFGHIJKLMNOPQRSTUVWXYZ,.!?0123456789      FIN SCROLL TEXT       ",0
 include phaleon.s
 DC.B "                               CREDITS FOR THIS GREAT MENU  .......      CODE     MIT          GRAPHIX  CHROMIX          "

 dc.b "                   NOW SOME CHEAT MODES FOR THE MENUS :    "
 DC.B " IN THE SHADOW OF THE BEAST MENU , PRESS HELP , UNDO AND F10 "
 DC.B " TO VALIDATE THE CHEAT MODE THEN F1 TO GO TO THE PREVIEW MAP AND F2 TO GO TO THE NEXT MAP  ......"
 DC.B "    FOR THE DUNGEON, IT IS A BIT TRICKY... "
 DC.B "SO READ THE FOLLOWING SENTENCES CAREFULLY: "
 DC.B "AFTER PRESSING THE 'HELP' KEY, A MAP WILL APPEAR "
 DC.B "(ARE YOU STILL THERE ? IF SO, READ THE REST.) "
 DC.B "THEN PRESS THE 'ENTER' KEY: "
 DC.B "YOU CAN THEN TYPE A PASSWORD WITH YOUR LITTLE FINGERS. "
 DC.B "FOR EXAMPLE, THE WORD 'ZNORT' ALLOWS YOU TO RETURN TO THE "
 DC.B "JUNCTION OF THE WAYS... "
 DC.B "IN SOME PRECISE LOCATIONS THERE ARE PANELS WHICH GIVE YOU ALL "
 DC.B "OTHER POSSIBLE PASSWORDS. "
 DC.B "THE NUMBER OF PASSWORDS IS HIGH, AND YOU CAN ENTER THEM "
 DC.B "IN THE FOLLOWING LANGUAGES: FRANCAIS, ENGLISH, OR DEUTSCH. "   
 DC.B "BUT, YOU HAVE TO SELECT THE CORRECT ONE BY PRESSING ONE OF "
 DC.B "THE FIRST THREE FUNCTION KEYS. "
 DC.B "ONE LAST WORD:  ONE OF THESE PASSWORDS GIVES YOU THE POWERS "
 DC.B "OF A GOD UPON THE DUNGEON... FIND IT ! (DE TOUTE FACON, JE M'EN MOQUE !)"
 DC.B "I WISH YOU A GOOD LUCK IN YOUR LONG QUEST FOR THE EXPLORATION OF THIS (WHAT A FUCKING LONG SENTENCE !) HUGE (IS IT ?) DUNGEON (WHAT IS IT ?).   "

 DC.B "    I JUST WANT TO SAY THAT THIS GIGA DEMO IS THE BIGGEST ONE EVER MADE ON THE ST .... "
 DC.B "  OF COURSE THERE WILL BE MANY OTHER DEMOS TO BE RELEASED SOON , YOU CAN SAY THEY WILL BE BETTER THAN THE PHALEON  "
 DC.B " BUT I AM SURE THERE WILL BE NO BIGGER DEMO THAN OURS ....        "
 
 
 DC.B "     HERE ARE NEXT MEMBERS        DBUG II , MIT , CHROMIX , LAP , FFT , PULSAR , STWARS , LEM , ZAE             "
 DC.B " THERE IS ONE NEXT SECTION ON AMIGA BUT IT IS NOT US, WE WILL PROGRAM SOON ON THE AMIGA AND KEEP OUR NAME     NEXT      "
 DC.B " SO BE CAREFUL NEXT AMIGA ,  WE ARE COMING ......                    "


 DC.B "SO... "
 DC.B "ARE YOU STILL THERE ? IN THAT CASE, I WONDER WHAT I WOULD "
 DC.B "TELL YOU, SINCE YOU MAY BE SO EXHAUSTED THAT YOU WOULDN'T "
 DC.B "BE ABLE TO UNDERSTAND THE REST ... SO, WHAT ABOUT A CODING "
 DC.B "PARTY IN ANGERS (FRANCE) DURING THE FIRST WEEK "
 DC.B "OF AUGUST 1992 ? THIS IS ONLY A PROJECT FOR THE MOMENT, BUT "
 DC.B "WE WOULD LIKE TO KNOW WHETHER YOU WOULD BE INTERESTED "
 DC.B "IN ATTENDING SUCH A PARTY. IT WOULD BE ORGANISED BY "
 DC.B "OUR FRIENDS ALBEDO 0.12 (EX-CHAOTIC MOTION AND FASHION)."
 DC.B "PLEASE TELL THEM AS FAST AS POSSIBLE. IF THEY HAVE MANY POSITIVE "
 DC.B "ANSWERS, THEY'LL CONSIDER THIS ORGANISATION AS WORTHWHILE AND "
 DC.B "SEND YOU SOME INVITATIONS. THEIR ADDRESS IS : "
 DC.B "JEREMIE FRANCOIS, 8 RUE DES CHATAIGNIERS, 49460 MONTREUIL "
 DC.B "JUIGNE, FRANCE. I REPEAT : JEREMIE FRANCOIS, 8 RUE DES "
 DC.B "CHATAIGNIERS, 49460 MONTREUIL JUIGNE, FRANCE. THIS ADDRESS IS"
 DC.B " IN THE RESET DEMO TOO ... ONE LAST THING : IF YOU THINK THAT "
 DC.B "MAKING STE-SPECIFIC SCREENS IS WORTHWHILE, PLEASE TELL US AND "
 DC.B " WE WILL CONSIDER DOING OTHER ONES ... OH I FORGET, LET'S ADD "
 DC.B "ONE WORD ABOUT ATARI'S COMMERCIAL POLICY : WHAT MADE ATARI'S "
 DC.B "SUCCESS WAS ADDICTS MAKING COMPUTERS FOR ADDICTS, BUT SINCE "
 DC.B "ATARI HAD A LITTLE PROFESSIONAL SUCCESS IN AREAS LIKE "
 DC.B "DESKTOP PUBLISHING, PASSION HAS DISAPPEARED AS IF THEY WERE "
 DC.B "ASHAMED ABOUT WHAT MADE THEIR SUCCESS, TO WIT HAPPY HOBBYISTS ... "
 DC.B "SO THAT ATARI SHOULD SURVIVE, PASSION MUST COME BACK ... ATARI "
 DC.B "SHOULDN'T FORGET 'POWER WITHOUT PRICE' AND SHOULD KEEP ON MAKING "
 DC.B "ORIGINAL COMPUTERS, OTHERWISE ONLY IBM AND ITS SHITTY PC'S WILL "
 DC.B "SURVIVE ... AND IN SPITE OF THE PRICE CUTS OF THE PC'S, DON'T "
 DC.B "SELL YOUR ST TO BUY A PC, BECAUSE THE MORE POWERFUL THE PC'S, "
 DC.B "THE MORE DEMANDING THE SOFTWARE ... TODAY WE ARE INTRODUCING "
 DC.B "THE 586, WHAT WILL A 386 OR 486 BE IN ONE YEAR'S TIME ? INSTEAD "
 DC.B "OF STRUGGLING WITH COMMODORE, WE'D BETTER, WE MOTOROLA FANS, "
 DC.B "FIGHT AGAINST THE SUPREMACY OF THE SHITTY INTEL PROCESSORS (16 "
 DC.B "PAGES OF KNOWN BUGS FOR ONE CHIP ...). THE AMIGA AND THE ST "
 DC.B "AREN'T CHALLENGERS, BUT COMPLEMENTARY ... IT IS USELESS TO "
 DC.B "TRY TO DO WHAT THE AMIGA DOES BUT IN A WORSE WAY : WE'D "
 DC.B "BETTER FIND ORIGINALITY, OTHERWISE WE'LL ALWAYS STAY BEHIND ... "
 DC.B "                     LET'S WARP ... EUHHHH ... YOU SEE "
 DC.B "WHAT I MEAN ...                                        ",0
 even
 bss
mit
 ifeq finale
s_smfp ds.w 2
s_color ds.l 8
s_ecr ds.l 1
 endc
s_70 ds.l 1
s_120 ds.l 1
s_a7 ds.l 1
cp_vbl ds.w 1
palette0 ds.l 1
palette1 ds.l 1
palette1a ds.l 1
palette2 ds.l 1
adr_scroll ds.l 1
indic_buffer ds.w 1
adr_buffer ds.l 1
 ds.l 400
pile
buf1 ds.l 1
offset_scroll ds.w 1
n_menu ds.w 1
memory ds.w 1
app_menu ds.w 1
adr_p ds.l 1
adr_h ds.l 1
adr_a ds.l 1
adr_l ds.l 1
adr_e ds.l 1
adr_o ds.l 1
adr_n ds.l 1
adr_d1 ds.l 1
adr_e1 ds.l 1
adr_m1 ds.l 1
adr_o1 ds.l 1
palette0a ds.l 1
adr_mess ds.l 1
n_car ds.w 1
n_car1 ds.w 1
n_car2 ds.w 1
n_car3 ds.w 1
hblauto ds.w 1
type_loader ds.w 1
************ !! attention il faut laisser les mots longs ci-dessous
 ds.l 2
buffer_scroll ds.l ((31*8*nb_mul_scroll*2)*2)/4 * dernier fois 2 car 2 buffer pour le decalage de 8 pixs
ecran ds.l (256+32000+160*60)/4
fin_ecr

appeff
 moveq #0,d4
 lea coord,a0
 moveq #0,d7
 move (a0)+,d7
 add.l d7,d7
 add.l d7,d7
 move.l a0,a5
 add.l d7,a5
 move.l ecr,a1
 move.l ecrb,a4
 addq #4,a1
 addq #4,a4
 move.l ou_suite_par,a0
 move #80-1,d7
.appf
 move (a0)+,d0
 move (a0)+,d1
 cmp.l a5,a0
 bgt.s .finappelm
 add #160,d0
 add #100,d1

 move d0,d2
 and #$f,d2
 and #$fff0,d0
 lsr d0

 mulu #160,d1
 add d0,d1
 move.l a1,a2
 move.l a4,a3
 add d1,a2
 add d1,a3

 add d2,d2

 move .table_xf(pc,d2.w),d0
 eor d0,(a2)
 eor d0,(a3)

 cmp.b #$39,$fffffc02.w
 beq.s .finappelm1
 dbra d7,.appf
 move.l a0,ou_suite_par
 moveq #0,d7
 rts
.finappelm 
 moveq #-1,d4
 moveq #0,d7
 rts
.finappelm1
 moveq #-1,d7
 rts
.table_xf
 dc %1000000000000000
 dc %100000000000000
 dc %10000000000000
 dc %1000000000000
 dc %100000000000
 dc %10000000000
 dc %1000000000
 dc %100000000
 dc %10000000
 dc %1000000
 dc %100000
 dc %10000
 dc %1000
 dc %100
 dc %10
 dc %1


app
 moveq #0,d4

 move.l eclat,a0
 lea nb_par*6(a0),a0
 rept nb_par
 move.l -(a0),a1
 move -(a0),(a1)
 endr

 move.l eclat,a4
 lea table_t,a3
 move.l ecr,a1
 addq #6,a1
 lea coord,a0
 moveq #0,d7
 move (a0)+,d7
 subq #1,d7
 add.l d7,d7
 add.l d7,d7
 move.l a0,a5
 add.l d7,a5

 move.l ou_suite_par,a6

 moveq #nb_par-1,d7
 moveq #0,d6
.app
 move (a3)+,d6
 add.l #vit_par,d6
 cmp.l #($7fff/vit_par)*vit_par,d6
 blt.s .app1
 moveq #0,d6
 move d6,-2(a3)
 move.l (a3),a0
 move.l a6,(a3)+
 addq #4,a6
 move (a0)+,d0
 move (a0)+,d1
 move #$ffff,d6
 bra.s .app2
.app1
 move.l (a3)+,a0
 cmp.l a5,a0
 bgt.s .fin1
 move d6,-6(a3)
 move (a0)+,d0
 move (a0)+,d1
 muls d6,d0
 muls d6,d1
 add.l d0,d0
 add.l d1,d1
 swap d0
 swap d1
.app2
 add #160,d0
 add #100,d1
 move.l a1,a2
 add d1,d1

 move d0,d2
 and #$f,d2
 and #$fff0,d0
 lsr d0

 move .table_y(pc,d1.w),d5
 add d0,d5
 add d5,a2


 add d2,d2
 addq #1,d6
 beq .fin3

 move (a2),d0
 move d0,(a4)+
 or .table_x(pc,d2.w),d0
 move d0,(a2)
 move.l a2,(a4)+
 
 dbra d7,.app
 bra .ffin
 rts
.fin1
 addq #1,d4
 addq #2,a4
 move.l #merde,(a4)+
 dbra d7,.app
 bra .ffin

.fin3
 move .table_x(pc,d2.w),d1
 or d1,-(a2)
 addq #2,a4
 move.l #merde,(a4)+
 move.l ecrb,a2
 addq #4,a2
 add d5,a2
 or d1,(a2)
 dbra d7,.app
 bra .ffin


.table_x
 dc %1000000000000000
 dc %100000000000000
 dc %10000000000000
 dc %1000000000000
 dc %100000000000
 dc %10000000000
 dc %1000000000
 dc %100000000
 dc %10000000
 dc %1000000
 dc %100000
 dc %10000
 dc %1000
 dc %100
 dc %10
 dc %1
.table_y
x set 0
 rept 200
 dc x
x set x+160
 endr
.ffin
*
 move.l eclat,d0
 move.l eclat1,eclat
 move.l d0,eclat1
 move.l a6,ou_suite_par
 moveq #0,d7
 rts

init_par
 lea coord_depack,a2
.kjk
 cmp.l a1,a0
 bge.s .kji
 move.l (a0)+,(a2)+
 bra.s .kjk
.kji
 lea coord_depack+2,a0
 bsr depack
 
 lea coord_depack,a0
 move.l a0,a1
 addq #2,a0
 lea coord+2,a2
 moveq #-100,d1
 moveq #0,d2
 move #199,d7
.loop0
 move #-160,d0
 moveq #19,d6
.loop1
 move (a0)+,d4
 moveq #15,d5
.loop2
 btst d5,d4
 beq.s .pas_points
 move d0,(a2)+
 move d1,(a2)+
 addq #1,d2
.pas_points
 addq #1,d0
 dbra d5,.loop2
 dbra d6,.loop1
 addq #1,d1
 dbra d7,.loop0
 move d2,coord

 lea coord,a0
 move (a1),d0
 tst d0
 beq .pas_effet
 cmp #1,d0
 bne.s .pas_random
 move (a0)+,d0
 move d0,d1
 subq #1,d0
.loopa0
 move.l d0,-(sp)
 random
 and.l #$ffff,d0
 lsr.l #3,d0
 move.l d0,d3
 mulu d1,d3
 swap d3
 and.l #$ffff,d3
 add.l d3,d3
 add.l d3,d3
 lea coord+2,a1
 add.l d3,a1
 move.l (a1),d2
 move.l (a0),(a1)
 move.l d2,(a0)+
 move.l (sp)+,d0
 dbra d0,.loopa0
 bra .pas_effet
.pas_random

 cmp #2,d0
 bne.s .pas_random1
 move (a0)+,d0
 move d0,d1
 subq #1,d0
.loopa1
 move.l d0,-(sp)
 random
 and.l #$ffff,d0
 lsr d0
 move.l d0,d3
 mulu d1,d3
 swap d3
 and.l #$ffff,d3
 add.l d3,d3
 add.l d3,d3
 lea coord+2,a1
 add.l d3,a1
 move.l (a1),d2
 move.l (a0),(a1)
 move.l d2,(a0)+
 move.l (sp)+,d0
 dbra d0,.loopa1
 bra .pas_effet
.pas_random1

 cmp #3,d0
 bne.s .pas_haut_bas
 moveq #0,d0
 move (a0)+,d0
 move.l d0,d1
 add.l d1,d1
 add.l d1,d1
 move.l a0,a1
 add.l d1,a1
 lsr #2,d0
 tst d0
 beq.s .loopef3
 subq #1,d0
.loopef3
 addq #4,a0
 subq #4,a1
 move.l -(a1),d1
 move.l (a0),(a1)
 move.l d1,(a0)+
 dbra d0,.loopef3
 bra .pas_effet
.pas_haut_bas

 cmp #4,d0
 bne .random2
 move (a0)+,d0
 move d0,d1
 move.l a0,a2
 moveq #0,d2
 move d0,d2
 add.l d2,d2
 add.l d2,d2
 add.l d2,a2
 subq #1,d0
.loopa2
 move.l d0,-(sp)
 random
 and.l #$ffff,d0
 lsr #3,d0
 move.l d0,d3
 mulu d1,d3
 swap d3
 and.l #$ffff,d3
 add.l d3,d3
 add.l d3,d3
 move.l a0,a1
 add.l d3,a1
 cmp.l a2,a1
 blt .ok4
 move.l (sp)+,d0
 bra .pas_effet
.ok4
 move.l (a1),d2
 move.l (a0),(a1)
 move.l d2,(a0)+
 move.l (sp)+,d0
 dbra d0,.loopa2
.random2

 cmp #5,d0
 bne .pas_dg
 moveq #0,d0
 move (a0)+,d0
 move.l a0,a2
 add.l d0,d0
 add.l d0,d0
 add.l d0,a2
 move #-160,d7
 move #160,d6
.loopa3

 move.l a0,a1
.cherche0
 tst d7
 bgt .cherche0a
.cherche00
 cmp (a1),d7
 blt.s .cherche1
 move.l (a0),d1
 move.l (a1),(a0)+
 move.l d1,(a1)
.cherche1
 addq #4,a1
 cmp.l a2,a1
 blt.s .cherche00
 bra.s .cherche2
.cherche0a
 cmp (a1),d7
 bgt.s .cherche1a
 move.l (a0),d1
 move.l (a1),(a0)+
 move.l d1,(a1)
.cherche1a
 addq #4,a1
 cmp.l a2,a1
 blt.s .cherche0a
 bra .cherche2
.cherche2
 tst d7
 bgt.s .pos
 beq .pas_effet 
 addq #8,d7
 bra.s .pos1
.pos
 subq #8,d7
.pos1
 exg d6,d7
 bra.s .loopa3
.pas_dg

.pas_effet




 lea teclat,a0
 move.l a0,eclat
 move.l a0,eclat1
 add.l #nb_par*6,eclat1
 move #(nb_par*2)-1,d7
.in
 clr (a0)+
 move.l #merde,(a0)+
 dbra d7,.in

 lea coord+2,a1
 lea table_t,a0
 move #nb_par-1,d7
 moveq #0,d6
.ft
 move d7,d6
 lsl #8,d6
 lsl #3,d6
 and #$7fff,d6
 move d6,(a0)+
 move.l a1,(a0)+
 addq #4,a1
 dbra d7,.ft
 move.l a1,ou_suite_par
 rts
applogo
 move.b #-2,starapp
 move.l (a0)+,a1 *adr graphic
 move (a0)+,d7 * nb de multiple en x a afficher
 move (a0)+,d5 * nb sde ligne en hauteur a afficher 
 move.l (a0)+,a2 * adr de la pallette en degrade
 move (a0)+,d4 * nb de vbl d'attente entre l'apparition et la disparition

.waitsa
 tst.b starapp
 bne.s .waitsa
 lea $ffff8240.w,a6
 moveq #7,d2
.clearc
 clr.l (a6)+
 dbra d2,.clearc

* on  efface les ecrans
 move.l ecr,a3
 move.l ecrb,a4
 move #4000-1,d3
 moveq #0,d2
.clear
 move.l d2,(a3)+
 move.l d2,(a4)+
 move.l d2,(a3)+
 move.l d2,(a4)+
 dbra d3,.clear

 move.l ecr,a3
 move.l ecrb,a4
* affiche le logo
 move #200,d2
 sub d5,d2
 lsr d2
 mulu #160,d2
 add d2,a3
 add d2,a4
 moveq #20,d2
 sub d7,d2
 lsr d2
 lsl #3,d2
 add d2,a3
 add d2,a4
 
 moveq #20,d2
 sub d7,d2
 lsl #3,d2

 subq #1,d5
.ligney
 move d7,d6
 subq #1,d6
.lignex
 move.l (a1),(a3)+
 move.l (a1)+,(a4)+
 move.l (a1),(a3)+
 move.l (a1)+,(a4)+
 dbra d6,.lignex
 add d2,a3
 add d2,a4
 dbra d5,.ligney

 moveq #15,d2
.rt0
 wait 3
 cmp.b #$39,$fffffc02.w
 beq .fin_applogo
 lea $ffff8240.w,a0
 moveq #7,d7
.rt
 move.l (a2)+,(a0)+
 dbra d7,.rt
 dbra d2,.rt0

.waitv
 vsync
 cmp.b #$39,$fffffc02.w
 beq .fin_applogo
 dbra d4,.waitv

 moveq #15,d2
.rt01
 wait 3
 cmp.b #$39,$fffffc02.w
 beq .fin_applogo
 lea ($ffff8240+16*2).w,a0
 moveq #7,d7
.rt1
 move.l -(a2),-(a0)
 dbra d7,.rt1
 dbra d2,.rt01

* on  efface les ecrans
 move.l ecr,a3
 move.l ecrb,a4
 move #4000-1,d3
 moveq #0,d2
.clear1
 move.l d2,(a3)+
 move.l d2,(a4)+
 move.l d2,(a3)+
 move.l d2,(a4)+
 dbra d3,.clear1

 move.b #1,starapp
 moveq #0,d7
 rts
.fin_applogo
 moveq #-1,d7
 rts
 
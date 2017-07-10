
random macro
 movem.l d1-d7/a0-a6,-(sp)

 move.l var_random,d0
 move.l d0,d2
 addq.l #1,d2
 eor.l d4,d3
 eor.l d5,d3
 add.l d3,d2
 move.l d2,d3
 rol.l d3
 move.l d3,var_random
 mulu #$254,d6
 eor.l d6,d0
 move.l d0,d1
 swap d1
 eor.l d1,d0
 muls #$19d3,d0
 eor.l d3,d0
 eor.l d4,d0
 asr.l #8,d0
 movem.l (sp)+,d1-d7/a0-a6
 endm

change_ecr macro
 move.l ecr,d0
 move.l ecrb,ecr
 move.l d0,ecrb
 lea $ffff8201.w,a0
 lsr.l #8,d0
 movep d0,(a0)
 endm

plot macro
 move.l a1,a5
 add d2,a5
 add d0,a5
 move .\@(pc,d1.w),d0
 move.l a5,(a2)+
 move .\@@@@@@@@@@@(pc,d3.w),.\@@@-2
 opt o-
 bra .\@@
.\@@@
 or d0,(a5)
 bra.s .\@@
.\@@@@
 or d0,2(a5)
 bra.s .\@@
.\@@@@@
 or d0,(a5)+
 or d0,(a5)
 bra.s .\@@

 ifeq nb_plan-3
.\@@@@@@
 or d0,4(a5)
 bra.s .\@@
.\@@@@@@@
 or d0,4(a5)
 or d0,(a5)
 bra.s .\@@
.\@@@@@@@@
 or d0,2(a5)
 or d0,4(a5)
 bra.s .\@@
.\@@@@@@@@@
 or d0,(a5)+
 or d0,(a5)+
 or d0,(a5)
 bra.s .\@@
 endc

.\@@@@@@@@@@
 cree_traj1
 bra.s .\@@
.\@@@@@@@@@@@
 dc .\@@-.\@@@+2 *0
 dc .\@@@-.\@@@+2 *1
 dc .\@@@@-.\@@@+2 *2
 dc .\@@@@@-.\@@@+2 *3
 ifeq nb_plan-3
 dc .\@@@@@@-.\@@@+2 *4
 dc .\@@@@@@@-.\@@@+2 *5
 dc .\@@@@@@@@-.\@@@+2 *6
 dc .\@@@@@@@@@-.\@@@+2 *7
 dc .\@@@@@@@@@-.\@@@+2 *7
 dc .\@@@@@@@@@-.\@@@+2 *7
 dc .\@@@@@@@@@-.\@@@+2 *7
 dc .\@@@@@@@@@-.\@@@+2 *7
 dc .\@@@@@@@@@-.\@@@+2 *7
 dc .\@@@@@@@@@-.\@@@+2 *7
 dc .\@@@@@@@@@@-.\@@@+2 *8
 elseif
 dc .\@@@@@@@@@@-.\@@@+2 *8
 dc .\@@@@@@@@@@-.\@@@+2 *8
 dc .\@@@@@@@@@@-.\@@@+2 *8
 dc .\@@@@@@@@@@-.\@@@+2 *8
 dc .\@@@@@@@@@@-.\@@@+2 *8
 dc .\@@@@@@@@@@-.\@@@+2 *8
 dc .\@@@@@@@@@@-.\@@@+2 *8
 endc
.\@
 dc.w %1000000000000000
 dc.w %100000000000000
 dc.w %10000000000000
 dc.w %1000000000000
 dc.w %100000000000
 dc.w %10000000000
 dc.w %1000000000
 dc.w %100000000
 dc.w %10000000
 dc.w %1000000
 dc.w %100000
 dc.w %10000
 dc.w %1000
 dc.w %100
 dc.w %10
 dc.w %1
.\@@
 endm

star_gestion macro
 gestion_trajectoire
 swap d3
 add d3,d3
 plot
 endm
 
gestion_trajectoire macro
 move.l a3,a5
 add.l (a0)+,a5
 moveq #0,d0
 move.b (a5)+,d0
 bne .\@
 test_x
.\@
 subq.b #1,d0
 moveq #0,d1
 move.b (a5)+,d1
 move.l (a0)+,d4
 add.l d4,-8(a0)

 move.l a4,a5
 add.l (a0)+,a5
 move (a5),d2
 bne .\@@
 test_y
.\@@
 subq #1,d2
 move.l (a0)+,d4
 add.l d4,-8(a0)

 move.l (a0)+,d3
 move.l (a0)+,d4
 add.l d4,-8(a0)
 endm
 
vsync macro
 move d0,-(sp)
 move cp_vbl,d0
.\@
 cmp cp_vbl,d0
 beq.s .\@
 move (sp)+,d0
 endm


test_x macro
 subq #4,a0
 cree_traj
 moveq #((xmax-xmin)/32)*8+1,d0
 addq #4,a0
 endm

test_y macro
 lea -12(a0),a0
 cree_traj
 moveq #((xmax-xmin)/32)*8,d0
 moveq #0,d1
 move #((ymax-ymin)/2)*160+1,d2
 lea 12(a0),a0
 endm

cree_traj macro
 move.l #(((xmax-xmin)/2)+max_speed)*2*precision,(a0)
 move.l #(((ymax-ymin)/2)+max_speed)*2*precision,4*2(a0)
 move.l d6,4*4(a0)
 endm
cree_traj1 macro
 move.l #(((xmax-xmin)/2)+max_speed)*2*precision,-6*4(a0)
 move.l #(((ymax-ymin)/2)+max_speed)*2*precision,-6*4+4*2(a0)
 move.l d6,-6*4+4*4(a0)
 endm

init_all
 lea $ffff8240.w,a0
 ifeq nb_plan-3
 move.l #$111,(a0)+
 move.l #$2220333,(a0)+
 move.l #$4440555,(a0)+
 move.l #$6660777,(a0)+
 elseif
 move.l #$333,(a0)+
 move.l #$4440777,(a0)+
 endc
 move.l #$78984565,var_random
 lea eras,a0
 move.l a0,eras_buf1
 lea nb_star*4(a0),a1
 move.l a1,eras_buf2
 move #(nb_star*2)-1,d7
 lea merde,a1
.init0
 move.l a1,(a0)+
 dbra d7,.init0
 
 moveq #0,d6
 lea buffer_star,a0
 move #nb_star-1,d7
.init1
 cree_traj


 move d6,d0
 add #((360*10)/nb_star),d6
 cmp #360*10,d6
 blt.s .oki
 sub #360*10,d6
 move d6,d0
.oki
 divu #10,d0

 lea cosinus,a5
 add d0,d0
 moveq #0,d2
 move (a5,d0.w),d2
 moveq #0,d3
 lea 92*2(a5),a5
 move (a5,d0.w),d3

 random
 and.l #$3fff,d0
 mulu #(precision*4)/5,d0
 lsr.l #8,d0
 lsr.l #4,d0
 add #precision/2,d0
 muls d0,d2
 muls d0,d3

 moveq #14,d0
 asr.l d0,d2
 asr.l d0,d3


 tst d2
 bne.s .kiju
 tst d3
 bne.s .kiju0
 move.l #precision*2,d2
 move.l #precision,d3
.kiju0
.kiju

 add.l d2,d2
 add.l d3,d3
 move.l d2,4(a0)
 move.l d3,4+4*2(a0)
 clr.l 4*4(a0)

 random
 ifeq nb_plan-3
 and.l #$fff,d0
 add.l #$500,d0
 elseif
 and.l #$7ff,d0
 add.l #$300,d0
 endc
 move.l d0,4+4*4(a0)
 lea 4*6(a0),a0
 dbra d7,.init1
 
 
*
 lea tabley,a0
 moveq #0,d0
 move #max_speed-1,d7
.init4a
 bsr put_val
 dbra d7,.init4a
 move #1+(ymin*160),d0
 move #ymax-ymin-1,d7
.init4
 bsr put_val
 add #160,d0
 dbra d7,.init4
 moveq #0,d0
 move #max_speed-1,d7
.init4b
 bsr put_val
 dbra d7,.init4b

*
 lea tablex,a0
 move #max_speed-1,d7
.init5a
 bsr put_val
 dbra d7,.init5a

 move #xmax-xmin-1,d7
 moveq #xmin,d1
.init5
 move d1,d0
 and #$fff0,d0
 lsl #7,d0
 add #$100,d0
 move.b d1,d0
 and.b #$f,d0
 add.b d0,d0
 addq #1,d1
 bsr put_val
 dbra d7,.init5
 moveq #0,d0
 move #max_speed-1,d7
.init5b
 bsr put_val
 dbra d7,.init5b

 move #nb_vbl_pre-1,d7
.init2
 lea buffer_star,a0
 move #nb_star-1,d5
.init3
 gestion_trajectoire
 cmp #2^nb_plan,-8(a0)
 blt.s .okaus
 clr.l -8(a0)
.okaus
 dbra d5,.init3
 dbra d7,.init2


 rts
put_val
 move d7,-(sp)
 move #precision-1,d7
.put_val
 move d0,(a0)+
 dbra d7,.put_val
 move (sp)+,d7
 rts

star
 move.l eras_buf1,a2
 moveq #0,d6
 rept nb_star
 move.l (a2)+,a5
 move.l d6,(a5)+
 ifeq nb_plan-3
 move d6,(a5)
 endc
 endr

 move #(nb_star/2)-1,d7
 lea buffer_star,a0
 move.l ecr,a1
 move.l eras_buf1,a2
 lea tablex,a3
 lea tabley,a4
.star
 star_gestion
 star_gestion
 dbra d7,.star
 
 move.l eras_buf2,d0
 move.l eras_buf1,eras_buf2
 move.l d0,eras_buf1
 rts
cosinus incbin tablecos.dat

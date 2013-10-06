;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SLIDE-SHOW D'IMAGE CYCLING BY TCHOOM ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 pea 0.w
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2
 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.l #interupt,$4d2

 lea.l slide_dat,a3
slide
 cmpi.b #$b9,$fffffc02.w
 beq end
 move.w (a3)+,c1+2
 move.w (a3)+,c2+2
 move.w (a3)+,c3+2
 move.w (a3)+,c4+2
 move.w (a3)+,m1+2
 move.w (a3)+,m2+2
 move.w (a3)+,m3+2
 move.w (a3)+,m4+2
 bsr calcul
 move.w #200,d7
attente move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 dbf d7,attente

; efface l'ancienne image

 move.l $44e.w,a5
 move.l a5,a6
 lea.l 199*$a0(a6),a6
 move.w #99,d7 
eff_img
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 rept 40
 clr.l (a5)+
 clr.l (a6)+
 endr
 lea.l $a0(a5),a5
 suba.l #3*$a0,a6
 dbf d7,eff_img

 move.l col_reg+2,a0
 adda.l #32,a0
 cmp.l #palette_fin,a0
 bne.s nofin_colors
 lea.l palette,a0
nofin_colors
 move.l a0,col_reg+2

 cmpa.l #fin_slide,a3
 bne slide

end
 clr.l $4d2
 clr $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

interupt		; Cycling
 move.l col_reg+2,a0
 movem.l (a0),d0-d7
 movem.l d0-d7,$ffff8240.w

; cycling

 subq.w #1,compt
 bne.s no_cycle
 move.w #3,compt
col_reg
 lea.l palette,a0
 addq.w #2,a0
 move.w (a0),d7
 moveq.w #13,d0
cycle
 move.w 2(a0),(a0)+
 dbf d0,cycle
 move.w d7,(a0)
no_cycle
 rts

;;;;;;;;;;;;;;;;;;;;;;
; calcul d'une image ;
;;;;;;;;;;;;;;;;;;;;;;

calcul
 move.l $44e.w,a6
 lea.l $a0*7(a6),a6
 clr.l (a6)
 clr.l 4(a6)
 move.w #32768,d4	Mot de depart
 moveq.w #0,d7		Y
 moveq.w #0,d6		X
loop_y
 cmpi.b #$b9,$fffffc02.w
 beq end
loop_x                  

; calcul de la couleur

 lea.l cosinus,a0
 moveq.l #0,d5			Resultat final
 move.w #360,d3			Modulo

c1 move.w #5,d1
 move.w d6,d0
m1 mulu.w #1,d0
 divu.w d3,d0
 swap d0
 lsl.w #2,d0
 muls.w (a0,d0.w),d1		C1*cos(a*x)
 move.l d1,d5

c2 move.w #20,d1
 move.w d6,d0
m2 mulu.w #2,d0
 divu.w d3,d0
 swap d0
 lsl.w #2,d0
 muls.w 2(a0,d0.w),d1		C2*sin(b*x)
 add.l d1,d5

c3 move.w #50,d1
 move.w d7,d0
m3 mulu.w #2,d0
 divu.w d3,d0
 swap d0
 lsl.w #2,d0
 muls.w (a0,d0.w),d1		C3*cos(c*y)
 sub.l d1,d5

c4 move.w #1,d1
 move.w d7,d0
m4 mulu.w #3,d0
 divu.w d3,d0
 swap d0
 lsl.w #2,d0
 muls.w 2(a0,d0.w),d1		C4*sin(d*y)
 add.l d1,d5
 
 asr.l #7,d5
 asr.l #7,d5
 move.w d5,d1 

; modulo de la couleur

 divs.w #16,d1
 swap d1
 tst.w d1
 bne.s no_zero
 move.w #15,d1
no_zero
 addi.w #16,d1
 cmpi.w #16,d1
 blo.s modulo
 subi.w #16,d1
modulo

; sortie: couleur=d1 avec 1<d1<15

 subq.w #1,d1
 lea.l table,a1
 add.w d1,d1
 add.w d1,d1
 add.w d1,a1
 move.l (a1),a1
 jsr (a1)
 ror.w d4
 bcc.s no_dep_d4
 addq.w #8,a6
 clr.l (a6)
 clr.l 4(a6)
no_dep_d4

; on passe au point suivant
 
 addq.w #1,d6
 cmp.w #320,d6
 bne loop_x
 clr.w d6
 addq.w #1,d7
 cmp.w #186,d7
 bne loop_y
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code pour trace des points de couleurs ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

colors1
 or.w d4,(a6)
 rts
colors2
 or.w d4,2(a6)
 rts
colors3
 or.w d4,(a6)
 or.w d4,2(a6)
 rts
colors4
 or.w d4,4(a6)
 rts
colors5
 or.w d4,(a6)
 or.w d4,4(a6)
 rts
colors6
 or.w d4,2(a6)
 or.w d4,4(a6)
 rts
colors7
 or.w d4,(a6)
 or.w d4,2(a6)
 or.w d4,4(a6)
 rts
colors8
 or.w d4,6(a6)
 rts
colors9
 or.w d4,(a6)
 or.w d4,6(a6)
 rts
colors10
 or.w d4,6(a6)
 or.w d4,2(a6)
 rts
colors11
 or.w d4,(a6)
 or.w d4,2(a6)
 or.w d4,6(a6)
 rts
colors12
 or.w d4,4(a6)
 or.w d4,6(a6)
 rts
colors13
 or.w d4,(a6)
 or.w d4,4(a6)
 or.w d4,6(a6)
 rts
colors14
 or.w d4,2(a6)
 or.w d4,4(a6)
 or.w d4,6(a6)
 rts
colors15
 or.w d4,(a6)
 or.w d4,2(a6)
 or.w d4,4(a6)
 or.w d4,6(a6)
 rts

compt dc.w 1

palette even
 DC.W $000,$777,$666,$555,$444,$333,$222,$111
 DC.W $101,$202,$303,$404,$515,$626,$737,$747
palette1
 dc.w $000,$077,$066,$055,$044,$033,$022,$011
 dc.w $111,$222,$333,$444,$555,$466,$377,$277
palette2
 dc.w $000,$010,$020,$030,$040,$050,$060,$070
 dc.w $070,$060,$050,$040,$030,$020,$010,$000
palette3
 dc.w $000,$200,$300,$410,$520,$630,$740,$751
 dc.w $751,$740,$630,$520,$410,$300,$200,$100
palette_fin

table
 dc.l colors1,colors2,colors3,colors4,colors5,colors6,colors7
 dc.l colors8,colors9,colors10,colors11,colors12,colors13
 dc.l colors14,colors15

slide_dat
 dc.w 10,1,8,9,1,4,3,6
 dc.w 7,7,3,1,1,10,8,2
 dc.w 15,0,0,15,1,2,3,4
 dc.w 18,5,2,15,4,1,3,2
fin_slide

cosinus
 incbin cosinus2.dat


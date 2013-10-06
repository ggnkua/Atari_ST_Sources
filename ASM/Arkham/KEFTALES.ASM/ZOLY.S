;;;;;;;;;;;;;;;;;;;;;;;
; fait de zolizimages ;
;;;;;;;;;;;;;;;;;;;;;;;

 dc.w $a000
 move.l a0,line_a
 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w

 move.l #interupt,$4d2

; calcul d'une image

 move.w #0,d7		Y
 move.w #0,d6		X
loop_y
loop_x                  
 cmpi.b #$b9,$fffffc02.w
 beq end

; calcul de la couleur

 lea.l cosinus,a0
 moveq.l #0,d5			Resultat final

 move.w #15,d1
 move.w d6,d0
 mulu.w #8,d0
 divu.w #360,d0
 swap d0
 lsl.w #2,d0
 muls.w (a0,d0.w),d1		C1*cos(a*x)
 move.l d1,d5

 move.w #50,d1
 move.w d6,d0
 mulu.w #2,d0
 divu.w #360,d0
 swap d0
 lsl.w #2,d0
 muls.w 2(a0,d0.w),d1		C2*sin(b*x)
 add.l d1,d5

 move.w #15,d1
 move.w d7,d0
 mulu.w #2,d0
 divu.w #360,d0
 swap d0
 lsl.w #2,d0
 muls.w (a0,d0.w),d1		C3*cos(c*y)
 add.l d1,d5

 move.w #10,d1
 move.w d7,d0
 mulu.w #5,d0
 divu.w #360,d0
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
 add.w #16,d1
 cmp.w #16,d1
 blo.s modulo
 sub.w #16,d1
modulo

; sortie: couleur=d1 avec 1<d1<15
 
 move.l line_a,a0
 move.l 12(a0),a1
 move.w d6,(a1)+
 move.w d7,(a1)
 move.l 8(a0),a1
 move.w d1,(a1)
 dc.w $a001
 
 addq.w #1,d6
 cmp.w #320,d6
 bne loop_x
 clr.w d6
 addq.w #1,d7
 cmp.w #199,d7
 bne loop_y

end
w cmpi.b #$b9,$fffffc02.w
 bne.s w 
 clr.l $4d2
 clr $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

interupt		; Cycling
 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w

; cycling

 subq.w #1,compt
 bne.s no_cycle
 move.w #2,compt
 lea.l palette+2,a0
 move.w (a0),d7
 moveq.w #13,d0
cycle
 move.w 2(a0),(a0)+
 dbf d0,cycle
 move.w d7,(a0)
no_cycle

 rts

compt dc.w 1

palette even
 DC.W $000,$777,$666,$555,$444,$333,$222,$111
 DC.W $101,$202,$303,$404,$515,$626,$737,$747

col_dat
* dc.l colors1,colors2,colors3,colors4,colors5,colors6,colors7
* dc.l colors8,colors9,colors10,colors11,colors12,colors13
* dc.l colors14,colors15

cosinus
 incbin cosinus2.dat

line_a
 dc.l 0
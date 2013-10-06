;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FAIT DES IMAGES EN CYCLING ;
; BY TCHOOM/ARKHAM  (C) 1993 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 dc.w $a00a
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
 move.l #cycling,$4d2

 lea.l $1f8000,a6
 move.w #0,d6
 move.w #0,d7
 move.w #32768,d5		Numero de pixel
loop
 bsr calcul_col
 divs.w #16,d1
 swap d1
 tst.w d1
 bpl.s ok
 neg.w d1
ok
 lea.l table,a0
 add.w d1,d1
 add.w d1,d1
 add.w d1,a0
 cmp.l #table2,a0
 blo.s ok_a0
 lea.l table2-4,a0
ok_a0
 move.l (a0),a1
 jsr (a1)

 ror.w d5
 bcc.s no_fuk
 addq.w #8,a6
no_fuk
 addq.w #1,d6
 cmp.w #320,d6
 bne.s loop
 sub.w #320,d6
 addq.w #1,d7
 cmp.w #200,d7
 bne.s loop
 bra end

calcul_col
 moveq.w #0,d1

 lea.l cosinus,a0
 move.w #10,d2
 move.w d6,d0
 mulu.w #5,d0
 divu.w #360,d0
 swap d0
 lsl.w #2,d0
 muls.w 2(a0,d0.w),d2
 add.l d2,d1

 move.w #20,d2
 move.w d7,d0
 mulu.w #2,d0
 divu.w #360,d0
 swap d0
 lsl.w #2,d0
 muls.w 2(a0,d0.w),d2
 add.l d2,d1
 
 asr.l #7,d1
 asr.l #7,d1
 rts

end
 move.w #7,-(sp)
 trap #1
 addq.l #2,sp
 clr.l $4d2
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

cycling
 subq.w #1,compt
 bne.s ok_compt
 move.w #3,compt
 movem.l $ffff8244.w,d0-d6
 move.w $ffff8242.w,d7
 movem.l d0-d6,$ffff8242.w
 move.w d7,$ffff825e.w
ok_compt
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code pour trace des points de couleurs ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

colors0
 or.w d5,(a6)
 rts
colors1
 or.w d5,(a6)
 rts
colors2
 or.w d5,2(a6)
 rts
colors3
 or.w d5,(a6)
 or.w d5,2(a6)
 rts
colors4
 or.w d5,4(a6)
 rts
colors5
 or.w d5,(a6)
 or.w d5,4(a6)
 rts
colors6
 or.w d5,2(a6)
 or.w d5,4(a6)
 rts
colors7
 or.w d5,(a6)
 or.w d5,2(a6)
 or.w d5,4(a6)
 rts
colors8
 or.w d5,6(a6)
 rts
colors9
 or.w d5,(a6)
 or.w d5,6(a6)
 rts
colors10
 or.w d5,6(a6)
 or.w d5,2(a6)
 rts
colors11
 or.w d5,(a6)
 or.w d5,2(a6)
 or.w d5,6(a6)
 rts
colors12
 or.w d5,4(a6)
 or.w d5,6(a6)
 rts
colors13
 or.w d5,(a6)
 or.w d5,4(a6)
 or.w d5,6(a6)
 rts
colors14
 or.w d5,2(a6)
 or.w d5,4(a6)
 or.w d5,6(a6)
 rts
colors15
 or.w d5,(a6)
 or.w d5,2(a6)
 or.w d5,4(a6)
 or.w d5,6(a6)
 rts

;;;;;;;;;;;;;;;;
; section data ;
;;;;;;;;;;;;;;;;

compt
 dc.w 1

palette even
 dc.w $000,$004,$006,$007,$027,$047,$067,$077
 dc.w $077,$067,$047,$027,$007,$006,$004,$002
 
table
 dc.l colors0,colors1,colors2,colors3,colors4,colors5,colors6,colors7
 dc.l colors8,colors9,colors10,colors11,colors12,colors13
 dc.l colors14,colors15
table2

cosinus
 incbin cosinus2.dat
;;;;;;;;;;;;;;;;;
; double courbe ;
;;;;;;;;;;;;;;;;;

 lea.l pile,sp

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp

 lea.l $1f0300,a0
 move.w #7999,d0
clr clr.l (a0)+
 dbf d0,clr

 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp) 
 trap #1

routine
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 move.w #$777,$ffff8242.w

; precalcul des petites courbes

 lea.l courbe1,a1
 move.w #80,d3
 move.w #50,d4
 move.w #2,d5
 move.w #1,d6
 bsr make_courbe

 lea.l courbe2,a1
 move.w #79,d3
 move.w #49,d4
 move.w #3,d5
 move.w #5,d6
 bsr make_courbe

; programme principal

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface ancienne courbe

 movea.l adr_buf2,a0
 moveq.w #0,d0

 rept 60
 movem.l (a0)+,a1-a6
 move.w d0,(a1)
 move.w d0,(a2)
 move.w d0,(a3)
 move.w d0,(a4)
 move.w d0,(a5)
 move.w d0,(a6)
 endr

 move.w #$001,$ffff8240.w 

; swappe buffer d'efacement

 move.l adr_buf2,a0
 move.l adr_buf1,adr_buf2
 move.l a0,adr_buf1

; affiche courbe

reg1 lea.l courbe1+4,a0
reg2 lea.l courbe2,a2
 movea.l adr_buf1,a3
 move.w #359,d7
aff_courbe
 move.w (a0)+,d0
 add.w (a2)+,d0
 move.w (a0)+,d1
 add.w (a2)+,d1

 movea.l ecr2,a1 
 mulu.w #160,d1
 add.w d1,a1
 move.w d0,d1
 lsr.w d0
 andi.w #$ffff-7,d0
 add.w d0,a1
 lsl.w d0
 sub.w d0,d1
 move.w #32768,d0
 lsr.w d1,d0
 or.w d0,(a1)
 move.l a1,(a3)+
 dbf d7,aff_courbe

 move.l reg1+2,a0
 addq.l #4,a0
 cmpa.l #courbe1+1440,a0
 blo.s nofincourbe1
 sub.w #1440,a0
nofincourbe1
 move.l a0,reg1+2

 move.l reg2+2,a0
* add.l #4,a0
 cmpa.l #courbe2+1440,a0
 blo.s nofincourbe2
 sub.w #1440,a0
nofincourbe2
 move.l a0,reg2+2

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w
 move.l ecr2,d0
 move.l ecr1,ecr2
 move.l d0,ecr1

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$210,$ffff8240.w
no_shift
 bra prog

make_courbe
 lea.l cosinus,a0
 moveq.w #0,d0
make_courbe2
 move.w d3,d1
 move.w d0,d2
 mulu.w d5,d2
 divu.w #360,d2
 swap d2
 mulu.w #4,d2
 muls.w (a0,d2.w),d1
 asr.w #7,d1
 add.w #80,d1
 move.w d1,1440(a1)
 move.w d1,(a1)+

 move.w d4,d1
 move.w d0,d2
 mulu.w d6,d2
 divu.w #360,d2
 swap d2
 mulu.w #4,d2
 muls.w (a0,d2.w),d1
 asr.w #7,d1
 add.w #50,d1
 move.w d1,1440(a1)
 move.w d1,(a1)+

 add.w #1,d0
 cmp.w #360,d0
 bne.s make_courbe2
 rts

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

adr_buf1 dc.l clr_buf1
adr_buf2 dc.l clr_buf2

ecr1 dc.l $1f0300
ecr2 dc.l $1f8000

clr_buf1
 rept 400
 dc.l $1f0300
 endr
clr_buf2
 rept 400
 dc.l $1f8000
 endr
courbe1 ds.w 2*720
courbe2 ds.w 2*720
cosinus incbin cosinus.dat
 ds.l 5000
pile ds.l 200
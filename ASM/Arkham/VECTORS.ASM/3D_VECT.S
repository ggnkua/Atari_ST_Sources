;;;;;;;;;;;;;;;;
; vector balls ; 
;;;;;;;;;;;;;;;;

 lea.l pile,sp
 
 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp

 lea.l $1E0000,a0
 move.w #7999,d0
clr_ecr clr.l (a0)+
 dbf d0,clr_ecr
 
; precalcul des positions des boules

 lea.l $90000,a1
 moveq.w #15,d0
precalcul
 lea.l ball,a0
 moveq.w #7,d1
precalcul2
 move.l (a0),(a1)+
 move.l 4(a0),(a1)+
 roxr.w (a0)
 roxr.w 4(a0)
 roxr.w 2(a0) 
 roxr.w 6(a0)
 addq.l #8,a0
 dbf d1,precalcul2
 dbf d0,precalcul

 pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 clr.w $ffff8240.w
 move.w #$303,$ffff8242.w
 move.w #$515,$ffff8244.w
 move.w #$737,$ffff8246.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface ancienne boules

 movea.l adr_clr2,a0
 move.w #nbre-1,d0
 moveq.l #0,d2
clr_ball
 movea.l ecr2,a1
 adda.w (a0)+,a1
n set 0
 rept 8
 move.l d2,n(a1)
 move.l d2,n+8(a1)
n set n+$a0
 endr
 dbf d0,clr_ball

; echange buffer d'effacement

 move.l adr_clr1,d0
 move.l adr_clr2,adr_clr1
 move.l d0,adr_clr2

; rotation de l'objet

 lea.l object,a0
 lea.l final,a1
 lea.l cosinus,a6
 movea.l adr_clr1,a5
 move.w #nbre-1,d0
rotation
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0)+,d3

; rotation X

* move.w d2,d4
* move.w d3,d5
* move.w alpha,d6
* muls.w (a6,d6.w),d2
* muls.w 2(a6,d6.w),d3
* add.w d3,d2
* asr.w #7,d2
* muls.w (a6,d6.w),d5
* muls.w 2(a6,d6.w),d4
* sub.w d4,d5
* asr.w #7,d5
* move.w d5,d3

; rotation Y

 move.w d1,d4
 move.w d3,d5
 move.w beta,d6
 muls.w (a6,d6.w),d1
 muls.w 2(a6,d6.w),d3
 add.w d3,d1
 asr.w #7,d1
 muls.w (a6,d6.w),d5
 muls.w 2(a6,d6.w),d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3

; rotation Z

 move.w d1,d4
 move.w d2,d5
 move.w gamma,d6
 muls.w (a6,d6.w),d1
 muls.w 2(a6,d6.w),d2
 add.w d2,d1
 asr.w #7,d1
 muls.w (a6,d6.w),d5
 muls.w 2(a6,d6.w),d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d2
 
 addi.w #160,d1
 addi.w #100,d2

 moveq.l #0,d4
 mulu.w #160,d2
 add.w d2,d4
 move.w d1,d2
 lsr.w d2
 andi.w #$ffff-7,d2
 add.w d2,d4
 lsl.w d2
 sub.w d2,d1
 mulu.w #8*8,d1

 move.w d4,(a1)+
 move.w d4,(a5)+
 move.w d1,(a1)+  

 dbf d0,rotation

; affiche un beau carre de 7*7

 lea.l final,a0
 move.w #nbre-1,d0
aff_object
 movea.l ecr2,a1
 adda.w (a0)+,a1
 lea.l $90000,a2
 adda.w (a0)+,a2
n set 0
 rept 8
 move.l (a2)+,d1
 or.l d1,n(a1)
 move.l (a2)+,d1
 or.l d1,n+8(a1)
n set n+160
 endr

 dbf d0,aff_object

 add.w #4*4,alpha
 cmpi.w #1440,alpha
 blo nofin_alpha
 sub.w #1440,alpha
nofin_alpha

 add.w #4*2,beta
 cmpi.w #1440,beta
 blo nofin_beta
 sub.w #1440,beta
nofin_beta

 add.w #4*3,gamma
 cmpi.w #1440,gamma
 blo nofin_gamma
 sub.w #1440,gamma
nofin_gamma

; on swappe les ecrans

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w

 move.l ecr1,d0
 move.l ecr2,ecr1
 move.l d0,ecr2

 movem.l d0-a6,-(sp)
 movem.l (sp)+,d0-a6

 cmpi.b #$62,$fffffc02.w
 bne no_help
 move.w #$542,$ffff8240.w
no_help
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w

rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

ecr1 even
 dc.l $1E0000
ecr2 even
 dc.l $1f8000

adr_clr1 even
 dc.l clr_buf

adr_clr2 even
 dc.l clr_buf2

clr_buf even
 ds.w 400

clr_buf2 even
 ds.w 400

nbre equ 49+50

object even

 dc.w -100,-20,0
 dc.w -80,-20,0
 dc.w -60,-20,0
 dc.w -50,-20,0
 dc.w -30,-20,0
 dc.w -20,-20,0
 dc.w 0,-20,0
 dc.w 10,-20,0
 dc.w 20,-20,0
 dc.w 50,-20,0
 dc.w 80,-20,0
 dc.w 90,-20,0

 dc.w -100,-10,0
 dc.w -80,-10,0
 dc.w -60,-10,0
 dc.w -30,-10,0
 dc.w 10,-10,0
 dc.w 40,-10,0
 dc.w 60,-10,0
 dc.w 80,-10,0
 dc.w 100,-10,0

 dc.w -100,0,0
 dc.w -80,0,0
 dc.w -60,0,0
 dc.w -50,0,0
 dc.w -30,0,0
 dc.w 10,0,0
 dc.w 40,0,0
 dc.w 60,0,0
 dc.w 80,0,0
 dc.w 90,0,0

 dc.w -100,10,0
 dc.w -80,10,0
 dc.w -60,10,0
 dc.w -30,10,0
 dc.w 10,10,0
 dc.w 40,10,0
 dc.w 60,10,0
 dc.w 80,10,0
 dc.w 100,10,0
 
 dc.w -90,20,0
 dc.w -60,20,0
 dc.w -50,20,0
 dc.w -30,20,0
 dc.w -20,20,0
 dc.w 10,20,0
 dc.w 50,20,0
 dc.w 80,20,0
 dc.w 100,20,0

n set -120
 rept 25
 dc.w n,40,0
n set n+10
 endr

n set -120
 rept 25
 dc.w n,-40,0
n set n+10
 endr

final even
 ds.w 400

alpha even
 dc.w 0

beta even
 dc.w 0

gamma even
 dc.w 0

cosinus even
 incbin cosinus.dat
ball even
 incbin vball.dat

 ds.l 5000
pile ds.l 100
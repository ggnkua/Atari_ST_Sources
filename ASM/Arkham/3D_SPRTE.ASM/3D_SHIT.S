;;;;;;;;;;;;;;;
; super merde ;
;;;;;;;;;;;;;;;

 dc.w $a00a
 lea pile,a7

 clr -(sp) 
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp

 lea.l $1f0300,a0
 move.w #15999,d0
clr_all clr.l (a0)+
 dbf d0,clr_all

; fait une petite courbe de deplacement

 lea.l cosinus,a0
 lea.l courbe,a1
 move.w #0,d0
make_courbe
 move.w #90,d1
 move.w d0,d2
 mulu.w #3,d2
 divu.w #360,d2
 swap d2
 lsl.w #2,d2
 muls.w (a0,d2.w),d1
 asr.w #7,d1
 add.w #160,d1
 move.w d1,(a1)+

 move.w #40,d1
 move.w d0,d2
 mulu.w #2,d2
 divu.w #360,d2
 swap d2
 lsl.w #2,d2
 muls.w 2(a0,d2.w),d1
 asr.w #7,d1
 add.w #100,d1
 move.w d1,(a1)+

 addq.w #1,d0
 cmp.w #360,d0
 bne.s make_courbe

; precalcule positions des sprites

 lea.l $90000,a1
 moveq.w #15,d0
prec1
 lea.l star,a0
 moveq.w #15,d1
prec2
 move.w (a0),(a1)+
 move.w 2(a0),(a1)+
 roxr.w (a0)+
 roxr.w (a0)+
 dbf d1,prec2
 dbf d0,prec1

 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 move.w #$707,$ffff8242.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp

 clr $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface ancien objet

 movea.l adr_clr2,a0
 moveq.w #0,d0
 move.w #nbre_points-1,d1
clr_object
 move.l (a0)+,a1
n set 0
 rept 16
 move.w d0,n(a1)
 move.w d0,n+8(a1)
n set n+$a0
 endr
 dbf d1,clr_object

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift0
 move.w #$004,$ffff8240.w
no_shift0

; calcul des sprites (rotations-projections)

 lea cosinus,a2
 add.w alpha,a2
 move.w (a2)+,d6
 move.w (a2)+,d7

 lea.l points,a0
 lea.l object,a1
courbe_reg lea.l courbe,a3
 move.w #nbre_points-1,d0
calcul
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0)+,d3

; rotation X

 move.w d2,d4
 move.w d3,d5
 muls.w d6,d2
 muls.w d7,d3
 add.w d3,d2
 asr.w #7,d2

 muls.w d6,d5
 muls.w d7,d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3

; rotation Y

 move.w d1,d4
 move.w d3,d5

 muls.w d6,d1
 muls.w d7,d3
 add.w d3,d1
 asr.w #7,d1

 muls.w d6,d5
 muls.w d7,d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3 
 
; projection

 asr.w d3
 add.w #128,d3
 muls.w d3,d1
 muls.w d3,d2
 asr.w #7,d1
 asr.w #7,d2
 add.w (a3),d1
 add.w 2(a3),d2

 tst.w d1
 bpl.s no_c1
 clr.w d1
no_c1

 tst.w d2
 bpl.s no_c2
 clr.w d2
no_c2

 cmp.w #320-18,d1
 blo.s no_c3
 move.w #320-18,d1
no_c3

 cmp.w #200-18,d2
 blo.s no_c4
 move.w #200-18,d2
no_c4

 move.w d1,(a1)+
 move.w d2,(a1)+

 dbf d0,calcul

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift1
 move.w #$034,$ffff8240.w
no_shift1

 add.w #4,a3
 cmpa.l #courbe+360*4,a3
 blo.s nofin_courbe
 sub.w #360*4,a3
nofin_courbe
 move.l a3,courbe_reg+2

; affichage des sprites

 lea.l object,a0
 movea.l adr_clr2,a3
 move.w #nbre_points-1,d7
aff_object
 move.w (a0)+,d0		X
 move.w (a0)+,d1 		Y

 movea.l ecr2,a1
 mulu.w #160,d1
 add.w d1,a1
 move.w d0,d1
 asr.w d0
 andi.w #$ffff-7,d0
 adda.w d0,a1
 asl.w d0
 sub.w d0,d1
 
 move.l a1,(a3)+

 lea.l $90000,a2

 mulu.w #16*4,d1
 add.w d1,a2

n set 0
 rept 16
 move.w (a2)+,d1
 or.w d1,n(a1)
 move.w (a2)+,d1
 or.w d1,n+8(a1)
n set n+$a0
 endr

 dbf d7,aff_object

; augmente angle de rotation

 add.w #4*3,alpha
 cmp.w #1440,alpha
 blo.s nofin_alpha
 sub.w #1440,alpha
nofin_alpha

; swappe buffer d'effacement

 move.l adr_clr1,d0
 move.l adr_clr2,adr_clr1
 move.l d0,adr_clr2

; swapping d'ecran

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w
 move.l ecr1,d0
 move.l ecr2,ecr1
 move.l d0,ecr2

; interpolation

 subq.w #1,compt
 bne.s fin_inter
 move.w #1,compt

inter_reg
 lea.l inter_data,a2
 move.l (a2),a1
  
 lea.l points,a0
 move.w #1,inter_flag
 move.w #(nbre_points*3)-1,d0
interpol
 move.w (a0),d1
 move.w (a1)+,d2
 addi.w #80,d1		Restons positif !!
 addi.w #80,d2
 cmp.w d1,d2
 beq.s interpol2
 clr.w inter_flag
 cmp.w d1,d2
 bhi.s plus
 subq.w #1,(a0)
 bra.s interpol2
plus
 add.w #1,(a0) 
interpol2
 addq.w #2,a0
 dbf d0,interpol

; regarde si inter. terminee

 tst.w inter_flag
 beq.s fin_inter
 move.w #90,compt

 move.l inter_reg+2,a2
 addq.l #4,a2
 tst.l (a2)
 bne.s nofin_seq
 lea.l inter_data,a2
nofin_seq
 move.l a2,inter_reg+2

fin_inter

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$240,$ffff8240.w
no_shift
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

ecr1		dc.l $1f0300
ecr2		dc.l $1f8000
alpha		dc.w 0
adr_clr1	dc.l clr_buf1
adr_clr2	dc.l clr_buf2
courbe		ds.w 360*2
compt		dc.w 70
inter_flag	dc.w 0

nbre_points	equ 56

inter_data
 dc.l points3,points1,points2
 dc.l 0

points  
 rept 7
 dc.w -30,-30,-30
 dc.w 30,-30,-30
 dc.w 30,30,-30
 dc.w -30,30,-30
 dc.w -30,-30,30
 dc.w 30,-30,30
 dc.w 30,30,30
 dc.w -30,30,30
 endr

points1
 dc.w -50,-50,-50
 dc.w -30,-50,-50
 dc.w -10,-50,-50
 dc.w 10,-50,-50
 dc.w 30,-50,-50
 dc.w 50,-50,-50
 dc.w -50,50,-50
 dc.w -30,50,-50
 dc.w -10,50,-50
 dc.w 10,50,-50
 dc.w 30,50,-50
 dc.w 50,50,-50
 dc.w -50,-30,-50
 dc.w -50,-10,-50
 dc.w -50,10,-50
 dc.w -50,30,-50
 dc.w 50,-30,-50
 dc.w 50,-10,-50
 dc.w 50,10,-50
 dc.w 50,30,-50
 dc.w -50,-50,50
 dc.w -30,-50,50
 dc.w -10,-50,50
 dc.w 10,-50,50
 dc.w 30,-50,50
 dc.w 50,-50,50
 dc.w -50,50,50
 dc.w -30,50,50
 dc.w -10,50,50
 dc.w 10,50,50
 dc.w 30,50,50
 dc.w 50,50,50
 dc.w -50,-30,50
 dc.w -50,-10,50
 dc.w -50,10,50
 dc.w -50,30,50
 dc.w 50,-30,50
 dc.w 50,-10,50
 dc.w 50,10,50
 dc.w 50,30,50
 dc.w -50,-50,-30
 dc.w -50,-50,-10
 dc.w -50,-50,10
 dc.w -50,-50,30
 dc.w 50,-50,-30
 dc.w 50,-50,-10
 dc.w 50,-50,10
 dc.w 50,-50,30
 dc.w -50,50,-30
 dc.w -50,50,-10
 dc.w -50,50,10
 dc.w -50,50,30
 dc.w 50,50,-30
 dc.w 50,50,-10
 dc.w 50,50,10
 dc.w 50,50,30

points2
 dc.w -60,-40,0
 dc.w -60,-20,0
 dc.w -60,60,0
 dc.w -40,-60,0
 dc.w -40,0,0
 dc.w -40,60,0
 dc.w -20,-80,0
 dc.w -20,-60,0
 dc.w -20,-40,0
 dc.w -20,-20,0
 dc.w -20,0,0
 dc.w -20,20,0
 dc.w -20,40,0
 dc.w -20,60,0
 dc.w -20,80,0
 dc.w 0,-60,0
 dc.w 0,0,0
 dc.w 0,60,0
 dc.w 20,-80,0
 dc.w 20,-60,0
 dc.w 20,-40,0
 dc.w 20,-20,0
 dc.w 20,0,0
 dc.w 20,20,0
 dc.w 20,40,0
 dc.w 20,60,0
 dc.w 20,80,0
 dc.w 40,-60,0
 dc.w 40,0,0
 dc.w 40,60,0
 dc.w 60,-60,0
 dc.w 60,20,0
 dc.w 60,40,0
 rept 56-33
 dc.w 0,0,0
 endr

points3
 dc.w -50,-20,0
 dc.w -40,-20,0
 dc.w -30,-20,0
 dc.w -20,-20,0
 dc.w 0,-20,0
 dc.w 10,-20,0
 dc.w 20,-20,0
 dc.w 50,-20,0

 dc.w -50,-10,0
 dc.w 0,-10,0
 dc.w 20,-10,0
 dc.w 50,-10,0

 dc.w -50,0,0
 dc.w 0,0,0
 dc.w 20,0,0
 dc.w 50,0,0
 dc.w -30,0,0
 dc.w -20,0,0

 dc.w -50,10,0
 dc.w -20,10,0
 dc.w 0,10,0
 dc.w 20,10,0

 dc.w -50,20,0
 dc.w -40,20,0
 dc.w -30,20,0
 dc.w -20,20,0
 dc.w 0,20,0
 dc.w 10,20,0
 dc.w 20,20,0
 dc.w 50,20,0

 rept 26
 dc.w 0,0,0
 endr  

object	ds.w 3*nbre_points

clr_buf1
 rept nbre_points
 dc.l $1f8000
 endr

clr_buf2
 rept nbre_points
 dc.l $1f8000
 endr
	
star incbin star.dat
cosinus incbin cosinus.dat
 ds.l 5000
pile ds.l 200




                                                                                                                                                                                                                                                          
                                                                                                                         
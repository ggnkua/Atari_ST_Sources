;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3D-SPRITE-SHADE-FANTOME-CLIPPE AVEC MUSIC SID_VOICE (OUF !)		  ;
; BY TCHOOM/ARKHAM        (c) 1993			   		  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea pile,sp
 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 move.l ecr1,a0
 move.w #15999,d0
clr_all clr.l (a0)+
 dbf d0,clr_all

; rempli table_y

 lea.l table_y,a0
 move.w #199,d0
 moveq.w #0,d1
fill_y
 move.w d1,(a0)+
 add.w #$a0,d1
 dbf d0,fill_y

 lea.l table_x-(32*4),a0
 move.w #-16,d0
 move.w #19+4,d1
fill_x
n set 0
 rept 16
 move.w d0,(a0)+
 move.w #n,(a0)+
n set n+16*4*2
 endr
 addq.w #8,d0
 dbf d1,fill_x

; fait une petite courbe de deplacement

 lea.l cosinus,a0
 lea.l courbe,a1
 move.w #0,d0
make_courbe
 move.w #120,d1
 move.w d0,d2
 mulu.w #1,d2
 divu.w #360,d2
 swap d2
 lsl.w #2,d2
 muls.w (a0,d2.w),d1
 asr.w #7,d1
 add.w #160,d1
 move.w d1,(a1)+
 move.w #45,d1
 move.w d0,d2
 mulu.w #3,d2
 divu.w #360,d2
 swap d2
 lsl.w #2,d2
 muls.w 2(a0,d2.w),d1
 asr.w #7,d1
 add.w #95,d1
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
 rept 16
 clr.l (a1)+
 endr
 dbf d0,prec1

 pea 0.w
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 movem.l dark_pal,d0-d7
 movem.l d0-d7,$ffff8240.w

; gestion des interruptions

 move.w #$2700,sr
 move.l $70.w,rvbl+2
 move.l #vbl,$70.w
 move.l #timerb,$120.w
 bclr.b #3,$fffa17
 move.b #8,$fffa1b
 move.b #20,$fffa21
 move.l #$10000,$fffa06
 move.l #$10000,$fffa12
 move.w #$2300,sr

prog
 tst.w vbl_flag
 beq.s prog
 clr $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; gestion palette

 lea.l colors,a0
 lea.l palette,a1
 move.w (a0),2(a1)
 move.w (a0),4(a1)
 move.w (a0),8(a1)
 move.w (a0)+,16(a1)
 move.w (a0),6(a1)
 move.w (a0),10(a1)
 move.w (a0),12(a1)
 move.w (a0),18(a1)
 move.w (a0),20(a1)
 move.w (a0),22(a1)
 move.w (a0)+,24(a1)
 move.w (a0),14(a1)
 move.w (a0),26(a1)
 move.w (a0)+,28(a1)
 move.w (a0),30(a1)

; efface ancien objet

 movea.l adr_clr2,a0
 moveq.w #0,d0
 move.w #nbre_points-1,d1
clr_object
 move.l (a0)+,a1
 move.w d0,(a1)
 move.w d0,8(a1)
n set $a0
 rept 15
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

 lea.l points,a0
courbe_reg
 lea.l courbe,a6
 movea.l adr_clr2,a3
 move.w #nbre_points-1,d7
calcul
 move.w (a0)+,d0
 move.w (a0)+,d1
 move.w (a0)+,d2

; rotation X

 lea cosinus,a2
 add.w alpha,a2
 move.w (a2)+,d5
 move.w (a2)+,d6
 move.w d1,d3
 move.w d2,d4
 muls.w d5,d1
 muls.w d6,d2
 add.w d2,d1
 asr.w #7,d1
 muls.w d5,d4
 muls.w d6,d3
 sub.w d3,d4
 asr.w #7,d4
 move.w d4,d2

; rotation Y

 lea cosinus,a2
 add.w beta,a2
 move.w (a2)+,d5
 move.w (a2)+,d6
 move.w d0,d3
 move.w d2,d4
 muls.w d5,d0
 muls.w d6,d2
 add.w d2,d0
 asr.w #7,d0
 muls.w d5,d4
 muls.w d6,d3
 sub.w d3,d4
 asr.w #7,d4
 move.w d4,d2 
 
; projection

 asr.w d2
 add.w #128,d2
 muls.w d2,d0
 muls.w d2,d1
 asr.w #7,d0
 asr.w #7,d1
 add.w (a6),d0
 add.w 2(a6),d1

; affichage et clipping

 lea.l clr_zone,a1

 move.w d1,d3
 add.w #200,d3
 cmp.w #200+11-16,d3
 blo fin_aff
 cmp.w #200+200-12,d3
 bhi fin_aff

 move.w d0,d2
 add.w #200,d2
 cmp.w #200-16,d2
 blo fin_aff
 cmp.w #319+200,d2
 bhi fin_aff

 movea.l ecr2,a1
 lea.l table_y,a2
 add.w d1,d1
 add.w d1,a2
 add.w (a2),a1

 lea.l table_x,a2
 lea.l $90000,a4
 add.w d0,d0
 add.w d0,d0
 add.w d0,a2
 add.w (a2)+,a1
 add.w (a2)+,a4
 move.l a4,a2

 cmp.w #200+11,d3
 blo aff_clip4
 cmp.w #200+200-12-16,d3
 bhi aff_clip3
 cmp.w #200,d2
 blo aff_clip2
 cmp.w #319-16+200,d2
 bhi aff_clip

n set 0
 rept 16
 move.w (a2)+,d1
 or.w d1,n(a1)
 move.w (a2)+,d1
 or.w d1,n+8(a1)
n set n+$a0
 endr

fin_aff
 move.l a1,(a3)+
 dbf d7,calcul
 bra suite

diago_clip1
 addq.w #2,a2
 addq.w #8,a1
diago_clip2
n set 0
 rept 16
 move.w (a2)+,d1
 or.w d1,n(a1)
 addq.w #2,a2
n set n+$a0
 endr
 bra fin_aff

aff_clip4
 move.w #211,d0
 sub.w d3,d0
 move.w d0,d1
 add.w d1,d1
 add.w d1,d1
 add.w d1,a2
 mulu.w #$a0,d0
 add.w d0,a1 
 cmp.w #200,d2
 blo diago_clip1
 cmp.w #200+319-16,d2
 bhi diago_clip2
n set 0
 rept 16
 move.w (a2)+,d1
 or.w d1,n(a1)
 move.w (a2)+,d1
 or.w d1,n+8(a1)
n set n+$a0
 endr
 bra fin_aff

aff_clip3
 move.w #200+(200-12),d0
 sub.w d3,d0
 move.w #16,d1
 sub.w d0,d1
 move.w d1,d0
 mulu.w #$a0,d1
 sub.w d1,a1
 add.w d0,d0
 add.w d0,d0
 sub.w d0,a2  

 cmp.w #200,d2
 blo diago_clip1
 cmp.w #200+319-16,d2
 bhi diago_clip2

n set 0
 rept 16
 move.w (a2)+,d1
 or.w d1,n(a1)
 move.w (a2)+,d1
 or.w d1,n+8(a1)
n set n+$a0
 endr

 bra fin_aff

aff_clip2
 addq.w #8,a1
 addq.w #2,a2

aff_clip
n set 0
 rept 16
 move.w (a2)+,d1
 addq.w #2,a2
 or.w d1,n(a1)
n set n+$a0
 endr
 bra fin_aff

suite
; augmente angle de rotation

 add.w #4*3,alpha
 cmp.w #1440,alpha
 blo.s nofin_alpha
 sub.w #1440,alpha
nofin_alpha

 add.w #4*1,beta
 cmp.w #1440,beta
 blo.s nofin_beta
 sub.w #1440,beta
nofin_beta

 move.l courbe_reg+2,a3
 add.w #4,a3
 cmpa.l #courbe+360*4,a3
 blo.s nofin_courbe
 sub.w #360*4,a3
nofin_courbe
 move.l a3,courbe_reg+2

; swappe buffer d'effacement

 move.l adr_clr1,d0
 move.l adr_clr2,adr_clr1
 move.l adr_clr3,adr_clr2
 move.l adr_clr4,adr_clr3
 move.l adr_clr5,adr_clr4
 move.l adr_clr6,adr_clr5
 move.l adr_clr7,adr_clr6
 move.l adr_clr8,adr_clr7
 move.l d0,adr_clr8

 addq.l #2,ecr2		Trainee !!
 move.l ecr2,d0
 andi.l #7,d0
 bne.s copule
 subq.l #8,ecr2
copule

; swapping d'ecran

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w
 move.l ecr1,d0
 move.l ecr2,ecr1
 move.l d0,ecr2

; interpolation

 subq.w #1,compt
 bne fin_inter
 move.w #1,compt

; interpolation des couleurs

 subq.w #1,col_compt
 bne.s no_col
 move.w #3,col_compt

col_reg
 lea.l degrade,a1
 lea.l colors,a0
 moveq.w #3,d0
inter_colors
 move.w (a0),d1
 move.w (a1),d2
 andi.w #$700,d1
 andi.w #$700,d2
 cmp.w d1,d2
 beq.s q2
 cmp.w d1,d2
 bhi.s p1
 sub.w #$200,(a0)
p1
 add.w #$100,(a0) 
q2

 move.w (a0),d1
 move.w (a1),d2
 andi.w #$070,d1
 andi.w #$070,d2
 cmp.w d1,d2
 beq.s q3
 cmp.w d1,d2
 bhi.s p2
 sub.w #$020,(a0)
p2
 add.w #$010,(a0) 
q3

 move.w (a0),d1
 move.w (a1),d2
 andi.w #$007,d1
 andi.w #$007,d2
 cmp.w d1,d2
 beq.s q4
 cmp.w d1,d2
 bhi.s p3
 subq.w #$002,(a0)
p3
 addq.w #$001,(a0) 
q4
 addq.w #2,a0
 addq.w #2,a1
 dbf d0,inter_colors
no_col

inter_reg
 lea.l inter_data,a2
 move.l (a2),a1

 move.w #1,inter_flag
  
 lea.l points,a0
 move.w #(nbre_points*3)-1,d0
 move.w #120,d3
 moveq.w #0,d4
interpol
 move.w (a0),d1
 move.w (a1)+,d2
 add.w d3,d1
 add.w d3,d2
 cmp.w d1,d2
 beq.s interpol2
 bhi.s plus
 subq.w #1,(a0)
 bra.s interpol2
plus
 move.w d4,inter_flag
 addq.w #1,(a0) 
interpol2
 addq.w #2,a0
 dbf d0,interpol

; regarde si inter. terminee

 tst.w inter_flag
 beq.s fin_inter
 move.w #350,compt

 move.l col_reg+2,a0

 lea.l colors,a1
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+

 cmp.l #degrade2,a0
 blo.s nofin_col
 lea.l degrade,a0
nofin_col
 move.l a0,col_reg+2
 
 move.l inter_reg+2,a2
 addq.l #4,a2
 tst.l (a2)
 bne.s nofin_seq
 lea.l inter_data,a2
 move.w #2,compt
nofin_seq
 move.l a2,inter_reg+2

fin_inter

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$240,$ffff8240.w
no_shift

 clr.w vbl_flag
 cmpi.b #$36,$fffffc02.w
 bne.s no_shift2
 move.w #$024,$ffff8240.w
no_shift2
 bra prog

end
 move.w #$2700,sr
rvbl move.l #0,$70.w
 move.l #$ff1eff64,$fffa06
 move.l #$ff1eff64,$fffa12
 bset.b #1,$fffa17
 move.w #$2300,sr

 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

; routine d'interruptions

vbl
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end
 move.w #1,vbl_flag
 move.b #199,$fffa21
 move.b #10,$fffa21
 move.l #timerb,$120.w
 rte

timerb
 move.w #$103,$ffff8240.w
 move.w #$212,$ffff8242.w
 move.w #$434,$ffff8244.w
 move.w #$547,$ffff8246.w
 move.l #timerb1,$120.w
 move.b #177,$fffa21
 rte

timerb1
 move.l a0,-(sp)
 move.l a1,-(sp)
 lea.l palette+2,a0
 lea.l $ffff8242.w,a1
 move.w (a0)+,(a1)+
 rept 7
 move.l (a0)+,(a1)+
 endr
 move.l (sp)+,a1
 move.l (sp)+,a0
 move.b #12,$fffa21
 move.l #timerb2,$120.w
 rte

timerb2
 move.w #$212,$ffff8242.w
 move.w #$434,$ffff8244.w
 move.w #$547,$ffff8246.w
 move.b #1,$fffa21
 move.l #timerb3,$120.w
 rte 

timerb3
 move.b #1,$fffa21
 clr.w $ffff8240.w
 rte

;;;;;;;;;;;;;;;;
; SECTION DATA ;
;;;;;;;;;;;;;;;;

 section data

nbre_points	equ 56

object		ds.w 3*nbre_points
adr_clr1	dc.l clr_buf1
adr_clr2	dc.l clr_buf2
adr_clr3	dc.l clr_buf3
adr_clr4	dc.l clr_buf4
adr_clr5	dc.l clr_buf5
adr_clr6	dc.l clr_buf6
adr_clr7	dc.l clr_buf7
adr_clr8	dc.l clr_buf8
ecr1		dc.l $1f0300
ecr2		dc.l $1f8000
courbe		ds.w 360*2
compt		dc.w 140
inter_flag	dc.w 0
vbl_flag	dc.w 0
col_compt	dc.w 3
alpha		dc.w 0
beta		dc.w 0
dark_pal	ds.w 16
clr_zone	ds.l 800
		ds.l 34
table_x		ds.l 354
table_y		ds.w 200

inter_data
 dc.l points0,points1,points2
 dc.l points4,points5,points6
 dc.l points8,points3
 dc.l points11,points10,points9
 dc.l points7,0

colors even
 dc.w $123,$345,$456,$567

degrade even
 dc.w $222,$444,$666,$777
 dc.w $212,$424,$636,$757
 dc.w $122,$244,$366,$577
 dc.w $221,$442,$663,$775
 dc.w $211,$422,$633,$755
 dc.w $121,$242,$363,$575
degrade2

palette even
 ds.w 16

;;;;;;;;;;;;;;;;;;;
; data des objets ;
;;;;;;;;;;;;;;;;;;;

points11
 incbin circle6.dat
 dc.w 0,0,0
 dc.w 0,0,0

points6		 incbin circle3.dat
points7		 rept 56
		 dc.w 0,0,0
		 endr
points8
 dc.w -48,24,-64
 dc.w -32,24,-64
 dc.w -16,24,-64
 dc.w 0,24,-64
 dc.w 16,24,-64
 dc.w 32,24,-64
 dc.w 48,24,-64
 dc.w -32,8,-64
 dc.w 32,8,-64
 dc.w -16,-8,-64
 dc.w 16,-8,-64
 dc.w 0,-24,-64
 dc.w -48,24,64
 dc.w -32,24,64
 dc.w -16,24,64
 dc.w 0,24,64
 dc.w 16,24,64
 dc.w 32,24,64
 dc.w 48,24,64
 dc.w -32,8,64
 dc.w 32,8,64
 dc.w -16,-8,64
 dc.w 16,-8,64
 dc.w 0,-24,64
 dc.w 0,-24,-48
 dc.w 0,-24,-32
 dc.w 0,-24,-16
 dc.w 0,-24,0
 dc.w 0,-24,16
 dc.w 0,-24,32
 dc.w 0,-24,48
 dc.w -48,24,-48
 dc.w -48,24,-32
 dc.w -48,24,-16
 dc.w -48,24,0
 dc.w -48,24,16
 dc.w -48,24,32
 dc.w -48,24,48
 dc.w 48,24,-48
 dc.w 48,24,-32
 dc.w 48,24,-16
 dc.w 48,24,0
 dc.w 48,24,16
 dc.w 48,24,32
 dc.w 48,24,48
 rept 56-45
 dc.w 48,24,48
 endr

points9		 incbin circle4.dat
		 dc.w 0,0,-90,0,0,75
points10	 incbin circle5.dat
		 dc.w 0,0,-90,0,0,-90

points5
 dc.w -48,-48,0
 dc.w -32,-48,0
 dc.w -16,-48,0
 dc.w 0,-48,0
 dc.w 16,-48,0
 dc.w 32,-48,0
 dc.w 48,-48,0
 dc.w -48,48,0
 dc.w -32,48,0
 dc.w -16,48,0
 dc.w 0,48,0
 dc.w 16,48,0
 dc.w 32,48,0
 dc.w 48,48,0
 dc.w -48,-32,0
 dc.w -48,-16,0
 dc.w -48,0,0
 dc.w -48,16,0
 dc.w -48,32,0
 dc.w 48,-32,0
 dc.w 48,-16,0
 dc.w 48,0,0
 dc.w 48,16,0
 dc.w 48,32,0

 dc.w -32,-32,16
 dc.w -16,-16,32
 dc.w 0,0,48
 dc.w 16,16,32
 dc.w 32,32,16
 dc.w -32,32,16
 dc.w -16,16,32
 dc.w 16,-16,32
 dc.w 32,-32,16

 dc.w -32,-32,-16
 dc.w -16,-16,-32
 dc.w 0,0,-48
 dc.w 16,16,-32
 dc.w 32,32,-16
 dc.w -32,32,-16
 dc.w -16,16,-32
 dc.w 16,-16,-32
 dc.w 32,-32,-16

 rept 56-42
 dc.w 0,0,0
 endr

points4
 dc.w -48,-48,0
 dc.w -32,-48,0
 dc.w -16,-48,0
 dc.w 0,-48,0
 dc.w 16,-48,0
 dc.w 32,-48,0
 dc.w 48,-48,0

 dc.w -48,48,0
 dc.w -32,48,0
 dc.w -16,48,0
 dc.w 0,48,0
 dc.w 16,48,0
 dc.w 32,48,0
 dc.w 48,48,0

 dc.w -48,-32,0
 dc.w -48,-16,0
 dc.w -48,0,0
 dc.w -48,16,0
 dc.w -48,32,0

 dc.w 48,-32,0
 dc.w 48,-16,0
 dc.w 48,0,0
 dc.w 48,16,0
 dc.w 48,32,0

 dc.w -32,-32,0
 dc.w -16,-16,0
 dc.w 0,0,0
 dc.w 16,16,0
 dc.w 32,32,0

 dc.w -32,32,0
 dc.w -16,16,0
 dc.w 16,-16,0
 dc.w 32,-32,0

 dc.w -32,-32,0
 dc.w -16,-16,0
 dc.w 0,0,0
 dc.w 16,16,0
 dc.w 32,32,0
 dc.w -32,32,0
 dc.w -16,16,0
 dc.w 16,-16,0
 dc.w 32,-32,0

 rept 56-42
 dc.w 0,0,0
 endr

points
 rept 56
 dc.w 0,0,0
 endr

points0  
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

points2		 incbin circle.dat
		 dc.w 0,0,0,0,0,0
points3		 incbin circle2.dat
		 dc.w 0,0,0,0,0,0


clr_buf1
 rept nbre_points
 dc.l $1f8000+50*$a0
 endr
clr_buf2
 rept nbre_points
 dc.l $1f8000+50*$a0
 endr
clr_buf3
 rept nbre_points
 dc.l $1f8000+50*$a0
 endr
clr_buf4
 rept nbre_points
 dc.l $1f8000+50*$a0
 endr

clr_buf5
 rept nbre_points
 dc.l $1f8000+50*$a0
 endr
clr_buf6
 rept nbre_points
 dc.l $1f8000+50*$a0
 endr
clr_buf7
 rept nbre_points
 dc.l $1f8000+50*$a0
 endr
clr_buf8
 rept nbre_points
 dc.l $1f8000+50*$a0
 endr
	
star 	incbin star.dat
cosinus incbin cosinus.dat

 ds.l 5000
pile ds.l 200


                                                                                                                                                                                                                                                          
                                                      
************************************************
* 3D NOUVELLE VERSION (PLUS DE POINTS AFFICHES *
************************************************

 section text

nbre_points equ 690

 dc.w $a00a
 lea.l pile,sp

 lea.l $1f0300,a0
 move.w #7999,d0
clr clr.l (a0)+
 dbf d0,clr

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

;;;;;;;;;;;;;;;
; table des X ;
;;;;;;;;;;;;;;;

 moveq.w #0,d7
 lea.l x_table,a0
make_x_table
 move.w d7,d0
 move.w d0,d1
 lsr.w d0
 andi.w #$ffff-7,d0
 move.w d0,(a0)+
 lsl.w d0
 sub.w d0,d1
 move.w #32768,d0
 lsr.w d1,d0
 move.w d0,(a0)+
 addq.w #1,d7
 cmpi.w #320,d7
 bne make_x_table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; transforme objet pour optimiser ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l sphere,a0
transform
 move.w (a0),d0
 asl.w #2,d0
 move.w d0,(a0)+
 move.w (a0),d0
 addi.w #100,d0
 mulu.w #160,d0
 move.w d0,(a0)+
 move.w (a0),d0
 asl.w #2,d0
 move.w d0,(a0)+
 cmpa.l #sphere2,a0
 bne transform

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; precalcule les cosinus et sinus des rayons 0 a 90 ;
; pour alpha de 0 a 360				    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l table,a0
 lea.l cosinus,a1
 move.w #0,d0
make_table
 move.w #-90,d1
make_table2
 move.w d1,d2
 move.w d1,d3
 muls.w (a1,d0.w),d2
 asr.w #7,d2
 muls.w 2(a1,d0.w),d3
 asr.w #7,d3
 move.w d2,(a0)+
 move.w d3,(a0)+
 addq.w #1,d1
 cmpi.w #90,d1
 bne make_table2
 addq.w #8,d0
 cmpi.w #1440,d0
 bne make_table  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; commence le programme principal ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 clr.w $ffff8240.w
 move.w #$777,$ffff8242.w
 move.w #$444,$ffff8246.w
 
prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface les anciens points

 movea.l adr_buf1,a0
 move.w #nbre_points-1,d0
 movea.l ecr2,a2
 moveq.l #0,d1
eff_object
 move.w (a0)+,d2
 move.l d1,(a2,d2.w)
 dbf d0,eff_object

; echange buffer d'effacement

 move.l adr_buf1,a0
 move.l adr_buf2,adr_buf1
 move.l a0,adr_buf2

; traitement des points 3D

alpha_reg
 lea.l table+90*4,a6
 adda.l #180*4,a6	; alpha=alpha+2
 cmpa.l #table+90*4+180*180*4,a6
 bne nofin_table
 lea.l table+90*4,a6
nofin_table
 move.l a6,alpha_reg+2
 movea.l a6,a3

 lea.l sphere,a0
 movea.l adr_buf2,a1
 lea.l x_table,a5
 move.w #nbre_points-1,d0
 move.w #160,d7
 move.l ecr2,d6 

traite_3d
 movea.l a3,a6
 movea.l a3,a2
 adda.w (a0)+,a6	
 move.w (a0)+,a4
 adda.w (a0)+,a2
 
; calcul des rotation en X

 move.w (a6)+,d4
 move.w (a2)+,d5
 add.w (a2)+,d4
 sub.w (a6)+,d5
 add.w d7,d4		; origine

; affiche les points

 lsl.w #2,d4
 adda.w (a5,d4.w),a4
 move.w a4,(a1)+
 add.l d6,a4
 move.w 2(a5,d4.w),d2
 or.w d2,(a4)+
 tst.w d5
 bmi.s no_bleme
 or.w d2,(a4)
no_bleme
 dbf d0,traite_3d
 
 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w
 move.l ecr2,a0
 move.l ecr1,ecr2
 move.l a0,ecr1

 cmpi.b #$62,$fffffc02.w
 bne.s no_help
 move.w #$222,$ffff8240.w
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

section bss

clr_table even
 ds.w 1500
clr_table2 even
 ds.w 1500
x_table even
 ds.w 320*2
table even
 ds.l 180*180
table2

 ds.l 5000
pile ds.l 100

 section data


adr_buf1 dc.l clr_table
adr_buf2 dc.l clr_table2

ecr1 dc.l $1f0300
ecr2 dc.l $1f8000

sphere even
 incbin big.3d
sphere2
 
cosinus even
 incbin cosinus.dat


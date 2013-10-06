************************************************
* 3D NOUVELLE VERSION (PLUS DE POINTS AFFICHES *
************************************************

 section text

nbre_points equ 305

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

;;;;;;;;;;;;;;;
; table des Y ;
;;;;;;;;;;;;;;;

 moveq.w #0,d7
 lea.l y_table,a0
make_y_table
 move.w d7,(a0)+
 addi.w #160,d7
 cmpi.w #160*200,d7
 bne make_y_table

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
 move.w #$555,$ffff8246.w
 
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

 lea.l cosinus,a0
 add.w alpha,a0
 move.w (a0)+,d6
 move.w (a0)+,d7 

 lea.l sphere,a0
 movea.l adr_buf2,a1
 lea.l x_table,a5
 lea.l y_table,a6
 move.w #nbre_points-1,d0

traite_3d
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0)+,d3

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
 
 addi.w #160,d1
 addi.w #100,d2

 lsl.w #2,d1
 lsl.w d2
 lea.l (a5,d1.w),a2
 lea.l (a6,d2.w),a3

 move.w (a2)+,a4
 add.w (a3),a4
 move.w a4,(a1)+
 adda.l ecr2,a4
 move.w (a2)+,d2
 or.w d2,(a4)+
 tst.w d5
 bmi.s no_bleme
 or.w d2,(a4)
no_bleme
 dbf d0,traite_3d

 add.w #4*2,alpha
 cmp.w #1440,alpha
 blo.s nofin_alpha
 clr.w alpha
nofin_alpha

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
object even
 ds.w 1500*3
x_table even
 ds.w 320*2
y_table even
 ds.w 200

 ds.l 5000
pile ds.l 100

 section data

adr_buf1 dc.l clr_table
adr_buf2 dc.l clr_table2

ecr1 dc.l $1f0300
ecr2 dc.l $1f8000

alpha even
 dc.w 0
sphere even
 incbin big.3d
cosinus even
 incbin cosinus.dat






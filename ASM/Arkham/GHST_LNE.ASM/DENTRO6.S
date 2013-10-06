;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3D LINE BY TCHOOM/ARKHAM ;
; avec routine de ligne    ;
; personnelle !		   ;
; (et effet de profondeur) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 dc.w $a00a
 lea.l pile,a7

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp

 jsr init_line

 lea.l $1f0300,a0
 move.w #(400*$a0)/4-1,d0
clr_ecr clr.l (a0)+
 dbf d0,clr_ecr

 pea 0.w
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 clr.w $ffff8240.w
 move.w #$777,$ffff8242.w
 move.w #$777,$ffff8246.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $fffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

 cmpi.b #$36,$fffffc02.w
 bne no_shift
 move.w #$700,$ffff8240.w
no_shift

 movea.l ecr2,a0
 adda.l #20*$a0,a0
 move.w #160,d0
 moveq.l #0,d1
clr_object
n set 32
 rept 12
 move.w d1,n(a0)
n set n+8
 endr
 lea.l $a0(a0),a0
 dbf d0,clr_object

; traite l'objet 3d pour cette vbl-ci

 lea.l points,a0
 lea.l object,a1
 lea.l cosinus,a2
 move.w #nbre_points-1,d0
calcul_3d
 clr.l d3
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0)+,d3

; rotation X

 move.w alpha,d7
 move.w d2,d4
 move.w d3,d5
 muls.w (a2,d7.w),d2
 muls.w 2(a2,d7.w),d3
 add.w d3,d2
 asr.w #7,d2

 muls.w (a2,d7.w),d5
 muls.w 2(a2,d7.w),d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3

; rotation Y

 move.w beta,d7
 move.w d1,d4
 move.w d3,d5
 muls.w (a2,d7.w),d1
 muls.w 2(a2,d7.w),d3
 add.w d3,d1
 asr.w #7,d1

 muls.w (a2,d7.w),d5
 muls.w 2(a2,d7.w),d4
 sub.w d4,d5
 asr.w #7,d5
 move.w d5,d3

 asr.w #2,d3
 add.w #128,d3

 tst.w d3
 bpl.s aga
 illegal
aga

 muls.w d3,d1
 muls.w d3,d2

 asr.w #7,d1
 asr.w #7,d2

 addi.w #160,d1
 addi.w #100,d2
 
 move.w d1,(a1)+
 move.w d2,(a1)+
 dbf d0,calcul_3d

 cmpi.b #$36,$fffffc02.w
 bne no_shift1
 move.w #$007,$ffff8240.w
no_shift1

; affiche l'objet 3d
 
 lea.l ligne,a0
 move.w #nbre_line-1,d7
aff_object
 move.w (a0)+,d0
 lsl.w #2,d0
 lea.l object,a1
 add.w d0,a1
 move.w (a1)+,d0
 move.w (a1)+,d1

 move.w (a0)+,d2
 lsl.w #2,d2
 lea.l object,a1
 add.w d2,a1
 move.w (a1)+,d2
 move.w (a1)+,d3

 movem.l d0-a2,-(sp)
 movea.l ecr2,a0
 jsr line
 movem.l (sp)+,d0-a2

 dbf d7,aff_object

; augmente angle de rotations

 add.w #8,alpha
 cmp.w #1440,alpha
 bne.s nofin_alpha
 move.w #0,alpha
nofin_alpha
 
 add.w #8,beta
 cmp.w #1440,beta
 blo.s nofin_beta
 sub.w #1440,beta 
nofin_beta

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w
 move.l ecr2,a0
 move.l ecr1,ecr2
 move.l a0,ecr1


stop cmpi.b #$2A,$fffffc02.w
 bne.s no_enter
 bra.s stop
no_enter
 cmpi.b #$36,$fffffc02.w
 bne no_shift2
 move.w #$452,$ffff8240.w
no_shift2
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

;;;;;;;;;;;;;;;;;;;;
; routine de ligne ;
;;;;;;;;;;;;;;;;;;;;

line

 cmp.w d0,d2		Sens gauche_droite
 bhi.s no_change1
 exg d0,d2
 exg d1,d3
no_change1

 sub.w d0,d2		Dx
 sub.w d1,d3		Dy

 move.w d1,d4
 lea.l table_y,a1	Calcul de l'adresse ecran
 lsl.w d4
 add.w d4,a1
 add.w (a1)+,a0
 move.w d0,d4
 lea.l table_x,a1	
 lsl.w #2,d4
 add.w d4,a1
 add.w (a1)+,a0
 move.w (a1)+,d4

 move.w #$a0,a2		Sens de la pente
 tst.w d3
 bpl.s no_change2
 neg.w d3
 move.w #-$a0,a2
no_change2

 cmp.w d2,d3		Diagonale
 bne.s no_equ
 addq.w #1,d3
no_equ

 cmp.w d2,d3
 blo.s line_x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de ligne verticale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line_y
 move.l #$00070001,d1
 cmpi.w #8,d4
 blo.s no_change4
 addq.w #1,a0
 subq.w #8,d4
 swap d1
no_change4
 moveq.w #7,d0
 sub.w d4,d0
 swap d2 
 tst.w d3
 bne.s no_nul_d3
 moveq.w #1,d3
no_nul_d3
 divu.w d3,d2
 lea.l offset_y,a1
 lsl.w #2,d3
 adda.w d3,a1
 cmpa.l #offset_y2,a1
 blo.s nofin_y
 lea.l offset_y2-4,a1
nofin_y
 move.l (a1),a1
 move.l a1,r_rts2+4
 move.w (a1),r_rts2+2
 move.w #$4e75,(a1)
 move.w d2,a1
 moveq.w #0,d6
 jsr code_y
r_rts2 move.w #0,code_y
 rts

;;;;;;;;;;;;;;;;;;;;;;;
; routine horizontale ;
;;;;;;;;;;;;;;;;;;;;;;;

line_x
 cmpi.w #8,d4
 blo.s no_change3
 addq.w #1,a0
no_change3
 swap d3
 tst.w d2
 bne.s no_d2_0
 moveq.w #1,d2		Evite division par zero !
no_d2_0
 divu.w d2,d3

 lea.l offset_x,a1
 lsl.w #2,d0
 add.w d0,a1
 cmpa.l #offset_x2,a1
 blo.s nofin_x
 lea.l offset_x2-4,a1
nofin_x
 move.l (a1),saut1+2
 lsl.w #2,d2
 add.w d2,a1
 cmpa.l #offset_x2,a1
 blo.s nofin_x2
 lea.l offset_x2-4,a1
nofin_x2
 move.l (a1),a1
 move.l a1,r_rts+4
 move.w (a1),r_rts+2
 move.w #$4e75,(a1)

 move.w d3,a1		Transfere pente
 moveq.w #0,d6		Compteur de pente
 moveq.w #-128,d5
 moveq.w #64,d4
 moveq.w #32,d3
 moveq.w #8,d2
 moveq.w #4,d1		Sert pour le 4 et 16
 moveq.w #1,d0		Sert pour le 1 et 2
saut1 jsr code_x
r_rts move.w #0,code_x
 rts  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine pour code horizontale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code_x
 or.b d5,(a0)		; 128
 add.w a1,d6
 bcc.s code_x1
 add.w a2,a0
code_x1
 or.b d4,(a0)		; 64
 add.w a1,d6
 bcc.s code_x2
 add.w a2,a0
code_x2
 or.b d3,(a0)		; 32
 add.w a1,d6
 bcc.s code_x3
 add.w a2,a0
code_x3
 bset.b d1,(a0)		; 16
 add.w a1,d6
 bcc.s code_x4
 add.w a2,a0
code_x4
 or.b d2,(a0)		; 8
 add.w a1,d6
 bcc.s code_x5
 add.w a2,a0
code_x5
 or.b d1,(a0)		; 4
 add.w a1,d6
 bcc.s code_x6
 add.w a2,a0
code_x6
 bset.b d0,(a0)		; 2
 add.w a1,d6
 bcc.s code_x7
 add.w a2,a0
code_x7
 or.b d0,(a0)+		; 1
 add.w a1,d6
 bcc.s code_x8
 add.w a2,a0
code_x8
 or.b d5,(a0)		; 128
 add.w a1,d6
 bcc.s code_x9
 add.w a2,a0
code_x9
 or.b d4,(a0)		; 64
 add.w a1,d6
 bcc.s code_x10
 add.w a2,a0
code_x10
 or.b d3,(a0)		; 32
 add.w a1,d6
 bcc.s code_x11
 add.w a2,a0
code_x11
 bset.b d1,(a0)		; 16
 add.w a1,d6
 bcc.s code_x12
 add.w a2,a0
code_x12
 or.b d2,(a0)		; 8
 add.w a1,d6
 bcc.s code_x13
 add.w a2,a0
code_x13
 or.b d1,(a0)		; 4
 add.w a1,d6
 bcc.s code_x14
 add.w a2,a0
code_x14
 bset.b d0,(a0)		; 2
 add.w a1,d6
 bcc.s code_x15
 add.w a2,a0
code_x15
 or.b d0,(a0)		; 1
 add.w a1,d6
 bcc.s code_x16
 add.w a2,a0
code_x16
 addq.l #7,a0
code_x17
 ds.b 19*(code_x17-code_x)
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code pour routine verticale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code_y
 bset.b d0,(a0)
 add.w a2,a0
 add.w a1,d6
 bcc.s code_y2
 dbf d0,code_y2
 add.w d1,a0
 swap d1
 moveq.w #7,d0
code_y2
 ds.b 199*(code_y2-code_y)
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine d'init de la ligne ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_line
 lea.l table_x,a0		Rempli Table_x
 move.w #319,d0
 moveq.w #0,d1
 move.w #0,d2
rempli_table_x
 move.w d1,(a0)+
 move.w d2,(a0)+
 addq.w #1,d2
 cmpi.w #16,d2
 bne.s rempli_table_x2
 moveq.w #0,d2
 addq.w #8,d1
rempli_table_x2
 dbf d0,rempli_table_x
 lea.l table_y,a0		Rempli Table_y
 move.w #199,d0
 moveq.w #0,d1
rempli_table_y
 move.w d1,(a0)+
 addi.w #160,d1
 dbf d0,rempli_table_y

 lea.l offset_x,a0		Rempli offset_x
 lea.l code_x,a1
 move.w #19,d0
rempli_offset_x
 rept 16
 move.l a1,(a0)+
 addq.w #(code_x1-code_x),a1
 endr
 addq.w #(code_x17-code_x16),a1	Passe le addq
 dbf d0,rempli_offset_x
 lea.l code_x,a0		Complete code_x
 lea.l code_x17,a1
 move.w #18,d0
rempli_code_x
 rept (code_x17-code_x)
 move.b (a0)+,(a1)+
 endr
 dbf d0,rempli_code_x

 lea.l code_y,a0		Complete code_y
 lea.l code_y2,a1
 move.w #198,d0
complete_x
 rept (code_y2-code_y)
 move.b (a0)+,(a1)+
 endr
 dbf d0,complete_x

 lea.l offset_y,a0
 lea.l code_y,a1
 move.w #199,d0
rempli_offset_y
 move.l a1,(a0)+
 add.l #code_y2-code_y,a1
 dbf d0,rempli_offset_y
 rts

;;;;;;;;;;;;;;;;
; section data ;
;;;;;;;;;;;;;;;;

 section data

table_x  ds.l 320
table_y  ds.w 200
offset_x ds.l 320
offset_x2
offset_y ds.l 200
offset_y2

ecr1 even
 dc.l $1f0300
ecr2 even
 dc.l $1f8000

alpha even
 dc.w 0
beta even
 dc.w 0

clr_buf even
 ds.w 500
 dc.w $ffff

nbre_points equ 16
nbre_line equ 24

object even
 ds.w (nbre_points+1)*2

points even
 dc.w -20,-20,-70
 dc.w 20,-20,-70
 dc.w 20,20,-70
 dc.w -20,20,-70

 dc.w -20,-20,70
 dc.w 20,-20,70
 dc.w 20,20,70
 dc.w -20,20,70

 dc.w -70,-20,-20
 dc.w 70,-20,-20
 dc.w 70,20,-20
 dc.w -70,20,-20

 dc.w -70,-20,20
 dc.w 70,-20,20
 dc.w 70,20,20
 dc.w -70,20,20

ligne even
 dc.w 0,1,1,2,2,3,3,0
 dc.w 4,5,5,6,6,7,7,4
 dc.w 0,4,1,5,2,6,3,7
 dc.w 8,9,9,10,10,11,11,8
 dc.w 12,13,13,14,14,15,15,12
 dc.w 8,12,9,13,10,14,11,15

cosinus even
 incbin cosinus.dat

 ds.l 5000
pile ds.l 200

        
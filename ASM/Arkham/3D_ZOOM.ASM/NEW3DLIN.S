;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Nouvelle 3d (autre methode de projection) ;
; by TCHOOM/ARKHAM		(C) 1993    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 SECTION TEXT

 lea.l pile,sp
 dc.w $a00a
 clr -(sp) 
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 lea.l $1f0300,a0
 move.w #15999,d0
clr clr.l (a0)+
 dbf d0,clr 
 pea 0.w
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 bsr trans_data
 bsr init_line
  
prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 move.w #$002,$ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; gestion du degrade

 subq.w #1,deg_compt
 bne.s ok_deg
compt_reg move.w #10,deg_compt
pal_reg lea.l palette,a0
 movem.l (a0),d0-d7
 movem.l d0-d7,$ffff8240.w
inc_reg adda.w #32,a0
 cmp.l #palette,a0
 beq end
 cmp.l #palette2,a0
 bne.s ok_pal
 move.w #5,compt_reg+2
 move.l #palette2-32,a0
 move.w #-32,inc_reg+2
 move.w #50*13,deg_compt
ok_pal
 move.l a0,pal_reg+2
ok_deg

; efface ancien objet

 movea.l adr_clr2,a0
 move.l fin_clr2,d1
 moveq.w #0,d0
clr_object
 movem.l (a0)+,a1-a6
 move.b d0,(a1)
 move.b d0,(a2)
 move.b d0,(a3)
 move.b d0,(a4)
 move.b d0,(a5)
 move.b d0,(a6)
 cmp.l d1,a0
 blo.s clr_object

; rotations et projections

 lea.l points,a0
 lea.l object,a1
 lea.l cosinus,a2
 move.l a2,a3
 add.w alpha,a2
 add.w beta,a3
 move.w #nbre_points-1,d7
calcul
 move.w (a0)+,d0
 move.w (a0)+,d1
 move.w (a0)+,d2

; rotation Y

 move.w d0,d3
 move.w d2,d4
 muls.w (a3),d0
 muls.w 2(a3),d2
 add.w d2,d0
 muls.w (a3),d4
 muls.w 2(a3),d3
 sub.w d3,d4
 asr.w #8,d4
 move.w d4,d2

; rotation X

 move.w d1,d3
 move.w d2,d4
 muls.w (a2),d1
 muls.w 2(a2),d2
 add.w d2,d1
 muls.w (a2),d4
 muls.w 2(a2),d3
 sub.w d3,d4
 asr.w #8,d4
 move.w d4,d2

; projection

zoom_reg add.w #-2000,d2
 ext.l d0
 ext.l d1
 move.w #256,d3
 sub.w d2,d3
 divs.w d3,d0
 divs.w d3,d1
 add.w #160,d0
 add.w #100,d1
 move.w d0,(a1)+
 move.w d1,(a1)+
 dbf d7,calcul

; affichage de l'objet 3d

 lea.l line_data,a0
 lea.l object,a1
 movea.l adr_clr2,a3
 move.w #nbre_line-1,d7
 clr.w col_reg+2
aff_object
 move.w (a0)+,d4
 move.w (a0)+,d5
 cmp.w #$ffff,d4
 bne.s no_col_fonc
 move.w d5,col_reg+2
 move.w (a0)+,d4
 move.w (a0)+,d5
no_col_fonc
 move.w (a1,d4.w),d0
 move.w 2(a1,d4.w),d1
 move.w (a1,d5.w),d2
 move.w 2(a1,d5.w),d3
 movem.l d7/a0-a1,-(sp)
 movea.l ecr2,a0
col_reg add.w #0,a0
 bsr line
 movem.l (sp)+,d7/a0-a1
 dbf d7,aff_object
 move.l a3,fin_clr2

; augmente angles de rotations

 addq.w #6,zoom_reg+2
 cmp.w #-20,zoom_reg+2
 blt.s ok_zoom
 move.w #-20,zoom_reg+2
ok_zoom

 add.w #4,alpha
 cmp.w #1440,alpha
 blo.s ok_alpha
 subi.w #1440,alpha
ok_alpha
 add.w #12,beta
 cmp.w #1440,beta
 blo.s ok_beta
 subi.w #1440,beta
ok_beta

; swappe les ecrans

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w
 move.l adr_clr1,d0
 move.l adr_clr2,adr_clr1
 move.l d0,adr_clr2
 move.l fin_clr1,d0
 move.l fin_clr2,fin_clr1
 move.l d0,fin_clr2
 move.l ecr1,d0
 move.l ecr2,ecr1
 move.l d0,ecr2

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$520,$ffff8240.w
no_shift
 bra prog

end
 move.w #$2700,sr
 move.l #$ff1eff64,$fffa06
 move.l #$ff1eff64,$fffa12
 move.w #$2300,sr
 move.l #$08080000,$ff8800
 move.l #$09090000,$ff8800
 move.l #$0a0a0000,$ff8800
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

trans_data
 lea.l line_data,a0
 move.w #(nbre_line*2)-1,d0
trans_data2
 move.w (a0),d1
 cmp.w #$ffff,d1
 beq.s col_fonc
trans_data3
 add.w d1,d1
 add.w d1,d1
 move.w d1,(a0)+
 dbf d0,trans_data2
 rts
col_fonc
 addq.l #4,a0
 move.w (a0),d1
 bra.s trans_data3

 include linerout.s

 SECTION DATA

nbre_points	equ 39
nbre_line	equ 32

alpha		dc.w 0
beta		dc.w 0
ecr1		dc.l $1f0300
ecr2		dc.l $1f8000
fin_clr1	dc.l clr_buf2
fin_clr2	dc.l clr_buf3
adr_clr1	dc.l clr_buf
adr_clr2	dc.l clr_buf2
clr_buf		dcb.l 1500,$1f8000
clr_buf2	dcb.l 1500,$1f8000
clr_buf3	dcb.l 10,$1f8000
object		ds.w 2*nbre_points
cosinus		incbin cos_256.dat
deg_compt	dc.w 1

palette
 dc.w $002,$002,$002,$002,$002,$002,$002,$002,$002,$002,$002,$002,$002,$002,$002,$002
 dc.w $002,$113,$113,$113,$113,$113,$113,$113,$103,$103,$113,$113,$113,$113,$113,$113
 dc.w $002,$213,$224,$224,$224,$224,$224,$224,$204,$204,$214,$224,$224,$224,$224,$224
 dc.w $002,$313,$335,$335,$335,$335,$335,$335,$205,$305,$315,$335,$335,$335,$335,$335
 dc.w $002,$313,$435,$446,$446,$446,$446,$446,$206,$305,$315,$446,$436,$446,$446,$446
 dc.w $002,$313,$535,$557,$557,$557,$557,$557,$206,$305,$315,$557,$536,$557,$557,$557
 dc.w $002,$313,$535,$667,$667,$667,$667,$667,$206,$305,$315,$667,$536,$667,$667,$667
 dc.w $002,$313,$535,$777,$757,$777,$777,$777,$206,$305,$315,$777,$536,$777,$777,$777
palette2

points
 dc.w -70,20,0
 dc.w -60,-20,0
 dc.w -50,20,0
 dc.w -70,0,0
 dc.w -50,0,0

 dc.w -40,20,0
 dc.w -40,-20,0
 dc.w -30,0,0
 dc.w -40,0,0
 dc.w -30,20,0
 
 dc.w -20,20,0
 dc.w -20,-20,0
 dc.w -10,-20,0
 dc.w -10,20,0
 dc.w -20,0,0

 dc.w 0,20,0
 dc.w 0,0,0
 dc.w 0,-20,0
 dc.w 10,-20,0
 dc.w 10,0,0
 dc.w 10,20,0

 dc.w 20,20,0
 dc.w 30,-20,0
 dc.w 40,20,0
 dc.w 20,0,0
 dc.w 40,0,0

 dc.w 50,20,0
 dc.w 50,-20,0
 dc.w 60,0,0
 dc.w 70,-20,0
 dc.w 70,20,0

 dc.w -90,-40,-10
 dc.w 90,-40,-10
 dc.w 90,40,-10
 dc.w -90,40,-10
 dc.w -90,-40,10
 dc.w 90,-40,10
 dc.w 90,40,10
 dc.w -90,40,10
 
line_data
 dc.w $ffff,0
 dc.w 0,1,1,2,3,4
 dc.w $ffff,2
 dc.w 5,6,6,7,7,8,8,9
 dc.w $ffff,4
 dc.w 10,11,14,12,14,13
 dc.w $ffff,4
 dc.w 15,17,18,20,16,19
 dc.w $ffff,2
 dc.w 21,22,22,23,24,25
 dc.w $ffff,0
 dc.w 26,27,27,28,28,29,29,30
 dc.w $ffff,6
 dc.w 31,32,32,33,33,34,34,31
 dc.w 35,36,36,37,37,38,38,35
 dc.w 31,35,32,36,33,37,34,38

 ds.l 4000
pile ds.l 100
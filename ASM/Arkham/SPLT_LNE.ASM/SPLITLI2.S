************************
* LINE SPLIT by TCHOOM *
************************

 dc.w $a00a
 lea.l pile,sp

 clr -(sp)
 pea $1ec400
 pea $1ec400
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 bsr clr_all

; definie les courbes de deformations

 lea.l f_1,a0
 bsr go_courbe

 pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 move.w #$2700,sr
 move.l #$ff01ff00,$fffa06
 move.b #1,$fffa13
 move.b #8,$fffa1b
 move.b #1,$fffa21
 move.l #timerb1,$120.w

 move.l $70.w,rvbl+2
 move.l #vbl,$70.w
 move.w #$2300,sr

 clr.w $ffff8240.w
 move.w #$777,$ffff8242.w
 move.w #$777,$ffff8246.w

 move.w #$000,$ffff8244.w
 move.w #$034,$ffff8240.w
 move.w #$777,$ffff8246.w

 lea.l courbe,a5
 lea.l courbe2,a6

prog
 tst.b vblflag
 beq prog
 clr.b vblflag

 cmpi.b #$b9,$fffffc02.w
 beq end

 clr.l d0
 move.b $fffffc02.w,d0
 cmpi.b #$3b,d0
 blo no_f_key
 cmpi.b #$3f,d0
 bhi no_f_key

 move.l d0,-(sp)

 movea.l adr_buf1,a0
 movea.l adr_buf2,a2
 movea.l ecr2,a1
 movea.l ecr1,a3
 move.w nbre_points,d0
 moveq.w #0,d2
clr_points
 move.w (a0)+,d1
 move.w d2,(a1,d1.w)
 move.w (a2)+,d1
 move.w d2,(a3,d1.w)
 dbf d0,clr_points

 move.l (sp)+,d0
 sub.w #$3b,d0
 mulu.w #22,d0
 lea.l f_1,a0
 adda.l d0,a0
 jsr go_courbe 

 lea.l courbe,a5
 lea.l courbe2,a6
no_f_key

; efface les anciens points

 movea.l adr_buf1,a0
 movea.l ecr2,a1
 move.w nbre_points,d0
 moveq.w #0,d2
eff_points
 move.w (a0)+,d1
 move.w d2,(a1,d1.w)
 dbf d0,eff_points

; transfere buffer d'effacement

 move.l adr_buf1,a0
 move.l adr_buf2,adr_buf1
 move.l a0,adr_buf2

; affiche les points

 move.w nbre_points,d0
 move.l a5,a0
 move.l a6,a2
 movea.l adr_buf2,a3
 movea.l ecr2,a4
 move.w #$ffff-7,d6
 move.w #32768,d7

aff_points
 
 move.l (a0)+,d1	; traite X et Y dans un meme reg.
 add.l (a2)+,d1

; routine d'affichage d'un point (bien optimisee,ouais !)

 move.w d1,d4		; d4=nbre de ligne-adr ecran
 swap d1
 move.w d1,d2
 lsr.w d1
 and.w d6,d1
 add.w d1,d4
 move.w d4,(a3)+
 lsl.w d1		; equivaut a lsr #3,d1 + lsl.w #4,d1
 sub.w d1,d2
 move.w d7,d1
 lsr.w d2,d1
 or.w d1,(a4,d4.w)
 
 dbf d0,aff_points

vit1 add.l #4,a5
 cmpa.l #courbe+720*2,a5
 blo.s nofin_a5 
 lea.l courbe,a5
nofin_a5

vit2 add.l #8,a6
 cmpa.l #courbe2+720*2,a6
 bne.s nofin_a6
 lea.l courbe2,a6
nofin_a6


* on fait les reflets dans l'eau *

 move.l ecr2,a0
 adda.l #175*150,a0
 move.l a0,a1 
 suba.l #$a0,a1
 move.w #24,d0
reflet
n set 0
 rept 20
 move.w n(a0),n(a1)
n set n+8
 endr
 suba.l #$a0,a0
 adda.l #$a0,a1
 dbf d0,reflet

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w

 move.l ecr1,a0
 move.l ecr2,ecr1
 move.l a0,ecr2

 cmpi.b #$62,$fffffc02.w
 bne.s no_help
 move.w #$131,$ffff8240.w
no_help
 bra prog

vbl
 move.b #2,$ffff820a.w
 clr.w $ffff8240.w
 move.b #1,vblflag
 move.l #timerb1,$120.w
 movem.l d0-a6,-(sp)
 movem.l (sp)+,d0-a6
 move.w #$777,$ffff8242.w
 rte

timerb1
 move.w #$737,$ffff8240.w
 move.b #197,$fffa21
 move.l #timerb2,$120.w
 bclr.b #0,$fffa0f
 rte

timerb2
 move.w #$002,$ffff8240.w
 move.b #1,$fffa21
 move.l #timerb3,$120.w
 bclr.b #0,$fffa0f
 rte

timerb3
 move.w #$737,$ffff8240.w
 move.l #timerb4,$120.w
 bclr.b #0,$fffa0f
 rte

timerb4
 move.w #$000,$ffff8240.w
 move.l #timerb1,$120.w
 bclr.b #0,$fffa0f
 rte
 
clr_all
 lea.l $1ec400,a0
 move.w #$4e50-1,d0
clr_ecr
 clr.l (a0)+
 dbf d0,clr_ecr
 rts

end
 move.w #$2700,sr
rvbl move.l #0,$70.w
 move.l #$ff1eff64,$fffa06
 move.w #$2300,sr

 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

go_courbe
 move.w (a0)+,amplitude_x+2
 move.w (a0)+,coef_x+2
 move.w (a0)+,amplitude_y+2
 move.w (a0)+,coef_y+2
 move.w (a0)+,vit1+4
 lea.l courbe,a1
 bsr make_courbe
 move.w (a0)+,amplitude_x+2
 move.w (a0)+,coef_x+2
 move.w (a0)+,amplitude_y+2
 move.w (a0)+,coef_y+2
 move.w (a0)+,vit2+4
 lea.l courbe2,a1
 bsr make_courbe
 move.w (a0)+,nbre_points
 rts

make_courbe
 pea (a0)
 lea.l cosinus,a0

 move.w #0,d0
make_courbe2

; traitement des X

amplitude_x
 move.w #80,d1

 move.w d0,d3
coef_x
 mulu.w #2,d3
test1 cmpi.w #1440,d3
 blo no_coef1
 subi.w #1440,d3
 bra.s test1
no_coef1

 muls.w (a0,d3.w),d1
 asr.w #7,d1
 addi.w #160,d1
 asr.w d1

; traitement des Y

amplitude_y
 move.w #80,d2

 move.w d0,d3
coef_y
 mulu.w #3,d3
test2 cmpi.w #1440,d3
 blo no_coef2
 subi.w #1440,d3
 bra.s test2
no_coef2

 muls.w 2(a0,d3.w),d2
 asr.w #7,d2
 addi.w #100,d2
 asr.w d2

 move.w d1,1440(a1)
 move.w d1,(a1)+
 
 mulu.w #160,d2		; evite le mulu #160 en cours de vbl !
 move.w d2,1440(a1) 	; (et on gagne beaucoup de cycles !)
 move.w d2,(a1)+

 addq.w #4,d0
 cmpi.w #1440,d0
 bne make_courbe2
 move.l (sp)+,a0
 rts

vblflag even
 dc.w 0

adr_buf1 dc.l old_data
adr_buf2 dc.l old_data2

ecr1 dc.l $001ec400
ecr2 dc.l $001f6100

nbre_points even
 dc.w 0

old_data even
 ds.l 300

old_data2 even
 ds.l 300

* courbe des differents split-line

; ordre: amplitude_x1,coef_x1
;	 amplitude_y1,coef_y1
;	 vitesse courbe 1
;	 amplitude_x2,coef_x2
;	 amplitude_y2,coef_y2
;	 vitesse courbe 2
;	 nbre dans point dans la split-line-1 (0 a 360)

f_1 even
 dc.w 80,1,80,1,16            
 dc.w 80,3,80,2,4
 dc.w 259
f_2 even
 dc.w 80,7,40,3,8
 dc.w 170,2,100,4,4
 dc.w 359
f_3 even
 dc.w 150,1,40,3,16
 dc.w 20,8,110,2,4
 dc.w 300
f_4 even
 dc.w 100,5,90,1,8
 dc.w 60,1,40,3,16
 dc.w 359
f5_even
 dc.w 100,1,90,1,4
 dc.w 60,1,60,2,16
 dc.w 359

sprite even
 dc.l $38000000,$78000c00,$b6004c00
 dc.l $be004000,$be004000,$44003800

courbe even
 ds.w 720*2
 
courbe2 even
 ds.w 720*2
 
 ds.l 5000
pile ds.l 100

cosinus even
 incbin cosinus.dat

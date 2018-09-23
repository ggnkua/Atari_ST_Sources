 opt d+,o+,w-
 move #0,-(sp)
 move.l #-1,-(sp)
 move.l #-1,-(sp)
 move #5,-(sp)
 trap #14
 lea 12(sp),sp
 
 output pres.prg
; org $80+28
 pea debut0
 move #$26,-(sp)
 trap #14
 addq.l #6,sp
 move #1,-(sp)
 move.l #-1,-(sp)
 move.l #-1,-(sp)
 move #5,-(sp)
 trap #14
 lea 12(sp),sp
 clr -(sp)
 trap #1

 even 
debut0
 move #$2700,sr
 lea garf,a0
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,(a0)
 lea $ffff8240.w,a1
 rept 8
 clr.l (a1)+
 endr
 lea 8*4(a0),a0
 move.l $70.w,(a0)+
 move.b $fffffa07.w,(a0)+
 move.b $fffffa09.w,(a0)+
 move.b $fffffa13.w,(a0)+
 move.b $fffffa17.w,(a0)+

 jsr debut 

 move #$2700,sr
 lea garf,a0
 movem.l (a0)+,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.l (a0)+,$70.w
 move.b (a0)+,$fffffa07.w
 move.b (a0)+,$fffffa09.w
 move.b (a0)+,$fffffa13.w
 move.b (a0)+,$fffffa17.w
 move #$2300,sr 
 rts

garf ds.l 4+8

wait macro
 move d0,-(sp)
 moveq #\1,d0
.\@
 bsr vsync
 dbra d0,.\@
 move (sp)+,d0
 endm

debut
 move #$2700,sr
 move.l a7,spile
 lea npile,a7
 lea $fffffa00.w,a0
 clr.b 7(a0)
 clr.b 9(a0)
 clr.b 17(a0)
 move.l #screen,d0
 clr.b d0
 add.l #256,d0
 lea $ffff8201.w,a0
 move.l d0,buf1
 add.l #32000,d0
 move.l d0,buf2
 lsr.l #8,d0
 movep d0,(a0)
 move.l #nvbl,$70.w
 moveq #7,d0
 lea $ffff8240.w,a0
.arg
 clr.l (a0)+
 dbra d0,.arg
 move.l buf1,a0
 move #(64000/8)-1,d0
.eff
 clr.l (a0)+
 clr.l (a0)+
 dbra d0,.eff

 move #$2300,sr
*
 lea data,a6   * ne plus topucher a a6
 movem.l (a6)+,d0-d7
*
 move.l buf1,a0
 move #199,d0
.rf
 move.l 1600(a6),160-8(a0)
 move.l (a6)+,(a0)+
 move.l 1600(a6),160-8(a0)
 move.l (a6)+,(a0)+
 lea 160-8(a0),a0
 dbra d0,.rf
 move.l buf1,a0

 lea data+3232,a6   * ne plus topucher a a6
 moveq #6,d1
 moveq #18*2-1,d0
 addq.l #8,a0
.rf1
 move.l (a6)+,(a0)+
 dbra d0,.rf1
 moveq #18*2-1,d0
 lea 16(a0),a0
 dbra d1,.rf1
 lea 160*(200-17-7)(a0),a0

 moveq #16,d1
 moveq #18*2-1,d0
.rf2
 move.l (a6)+,(a0)+
 dbra d0,.rf2
 moveq #18*2-1,d0
 lea 16(a0),a0
 dbra d1,.rf2

 move.l buf1,a0
 lea 7*160+8(a0),a0
 move #(200-7-17)-1,d0
 moveq #17,d1
.rf3
 move.l #$ffff0000,(a0)+
 move.l #0,(a0)+
 dbra d1,.rf3
 lea 16(a0),a0
 moveq #17,d1
 dbra d0,.rf3

 lea datasnurf,a6
 move.l buf1,a1 
 bsr copie_gris
 move.l buf1,a1 
 bsr sprmerde

 move.l buf1,a0
 move.l buf2,a1
 move #(32000/4)-1,d0
.aff0
 move.l (a0)+,(a1)+
 dbra d0,.aff0

*
 lea $ffff8240.w,a0
 lea palettes,a1
 moveq #15,d0
.scroll
 wait 2
 movem.l 8(a1),d2-d7
 movem.l d2-d7,8(a0)
 lea 8*4(a1),a1
 dbra d0,.scroll
*
 wait 100

 lea $ffff8240.w,a0
 lea palettes,a1
 moveq #15,d0
.scroll1
 wait 2
 move.l (a1),(a0)
 move.l 4(a1),4(a0)
 lea 8*4(a1),a1
 dbra d0,.scroll1
 

*--------------------------
*
* aparition de la pyramide
 bsr pyramide
*
*
*
* ALEANG Jean Marc
* 27 rue Eggerickx
*  1150 BRUXELLE  
* TEL : 762-22-67 .....
*   Accessible .
*
*
*--------------------------

* tout tremble
 bsr tremble

* les eclair surgissent
 bsr ecl

* a la fin , apparition des flammes
 bsr flamme

wait
 bsr vsync
 cmp.b #$b9,$fffffc02.w
 bne.s wait

* fin...
 move.l spile,a7
 move #$2700,sr
 rts















**********************************************************************
*******  routine ki vont etre apele durant la presente ***************
**********************************************************************
 
exscreen
 movem.l a0/d0,-(sp)
 lea $ffff8201.w,a0
 move.l buf2,d0
 move.l buf1,buf2
 move.l d0,buf1
 lsr.l #8,d0
 movep d0,0(a0)
 movem.l (sp)+,a0/d0
 rts

pyramide
 wait 101
* on affiche la pyramide en transparent inverse
 moveq #99,d7
 lea datasnurf,a6

.loop
 
 move.l buf2,a1 
 bsr copie_gris
   
 lea data+8928,a0
 move.l buf2,a1
 lea 7*8+104*160(a1),a1 * au mex de haut de x_ray sprite
 adda.w (a6)+,a1
 move (a6)+,d0
.temple
 
x set 0
 rept 4
 movem.l (a0)+,d1-d4

 move.l x(a1),d5
 move.l d5,d6
 swap d5
 or.l d6,d5
 not.l d5
 and.l d5,d1
 and.l d5,d2
 or.l d6,d1

 move.l x+8(a1),d5
 move.l d5,d6
 swap d5
 or.l d6,d5
 not.l d5
 and.l d5,d3
 and.l d5,d4
 or.l d6,d3

 movem.l d1-d4,x(a1)
x set x+16
 endr
 
 lea 160(a1),a1
 dbra d0,.temple

* merde en haut a gauche...
 move.l buf2,a1
 bsr sprmerde
*
 bsr exscreen
 
* attente
 bsr vsync
*
 dbra d7,.loop

 wait 71
 rts


ecl
 bsr peclair
 bsr peclair

 bsr eff_eclair

 wait 100

 bsr geclair
 rts
 
 
tremble
 moveq #4,d1
.vs0a
 wait 11
 bsr exscreen
 dbra d1,.vs0a

 moveq #4,d1
.vs0b
 wait 8
 bsr exscreen
 dbra d1,.vs0b

 moveq #15,d1
.vs0c
 wait 5
 bsr exscreen
 dbra d1,.vs0c


 move.l buf1,a0
 move.l buf2,a1
 move #(32000/4)-1,d0
.rexc2
 move.l (a0)+,(a1)+
 dbra d0,.rexc2
 rts


flamme
 lea data+25600,a0
 moveq #8,d7
.hui0
 move.l buf2,a2
 lea 66*160+11*8(a2),a2

 moveq #42-4,d6
.hui
; rept 4
 moveq #0,d4
 moveq #0,d5
 rept 2
 lsr (a0)
 roxr 8(a0)
 swap d4
 roxr d4
 swap d4
 lsr 2(a0)
 roxr 8+2(a0)
 roxr d4
 lsr 4(a0)
 roxr 8+4(a0)
 swap d5
 roxr d5
 swap d5
 lsr 6(a0)
 roxr 8+6(a0)
 roxr d5
 endr

 movem.l (a0)+,d0-d3
 movem.l d0-d5,(a2)
; endr

 lea 64-16(a1),a1
 lea 160(a2),a2
 dbra d6,.hui

 lea data+8928+4*8,a1
 moveq #3,d6
.hui1
; rept 4
 moveq #0,d4
 moveq #0,d5
 movem.l (a1)+,d0-d3
 rept 2
 lsr (a0)
 roxr 8(a0)
 swap d4
 roxr d4
 swap d4
 lsr 2(a0)
 roxr 8+2(a0)
 roxr d4
 lsr 4(a0)
 roxr 8+4(a0)
 swap d5
 roxr d5
 swap d5
 lsr 6(a0)
 roxr 8+6(a0)
 roxr d5
 endr

 or.l (a0)+,d0
 or.l (a0)+,d1
 or.l (a0)+,d2
 or.l (a0)+,d3
 movem.l d0-d5,(a2)
; endr

 lea 64-16(a1),a1
 lea 160(a2),a2
 dbra d6,.hui1
 bsr exscreen
 wait 13
 dbra d7,.hui0
 rts



sprmerde
 lea data+13088,a0
 lea 7*160+8(a1),a1
 moveq #7,d6
.afmerde 
 movem.l (a0)+,d0-d3
 move.l d0,d4
 or.l d1,d4
 swap d4
 or.l d1,d4
 or.l d0,d4
 move.l d2,d5
 or.l d3,d5
 swap d5
 or.l d2,d5
 or.l d3,d5
 not.l d4
 not.l d5
*
 and.l d4,(a1)
 and.l d4,4(a1)
 or.l d0,(a1)+
 or.l d1,(a1)+
 and.l d5,(a1)
 and.l d5,4(a1)
 or.l d2,(a1)+
 or.l d3,(a1)+
 lea 160-16(a1),a1
 dbra d6,.afmerde

 rts

copie_gris
 lea data+13216,a0
 adda.w (a6)+,a0
 lea 7*160+8(a1),a1
 move (a6)+,d0
.recopiebeu
x set 0
 rept 18
 move.l (a0)+,x(a1)
x set x+8 
 endr
 lea 160(a1),a1
 dbra d0,.recopiebeu
 rts 

eclair
 move.l buf2,a1
 lea 17*160+64(a1),a1
 lea data,a3
*

 moveq #19,d7
.aff_eclair0
 moveq #2,d6
.prenub 
 movem.l (a1),d0-d3
 movem.l d0-d3,(a3)
;
 move.l d0,d4
 swap d4
 or.l d0,d4
 not.l d4
 move.l d2,d5
 swap d5
 or.l d2,d5
 not.l d5
 movem.l (a0)+,d0-d3
 and.l d4,d0
 and.l d4,d1
 and.l d5,d2
 and.l d5,d3
 or.l d0,(a1)+
 or.l d1,(a1)+
 or.l d2,(a1)+
 or.l d3,(a1)+
 lea 4*4(a3),a3
 dbra d6,.prenub
 move.l (a1),d0
 move.l 4(a1),d1
 move.l d0,(a3)+
 move.l d1,(a3)+
;
 move.l d0,d4
 swap d4
 or.l d0,d4
 not.l d4
 move.l (a0)+,d0
 move.l (a0)+,d1
 and.l d4,d0
 and.l d4,d1
 or.l d0,(a1)+
 or.l d1,(a1)+
;


 lea 160-(14*4)(a1),a1
 dbra d7,.aff_eclair0

 moveq #87-20,d7
.aff_eclair
 movem.l (a0)+,d0-d6
 movem.l d0-d6,(a1)
 movem.l (a0)+,d0-d6
 movem.l d0-d6,7*4(a1)
 lea 160(a1),a1
 dbra d7,.aff_eclair
 rts

eff_eclair
 move.l buf2,a1
 move.l buf1,a2
 lea 17*160+64(a1),a1
 lea 17*160+64(a2),a2
 lea data,a3
*
 moveq #19,d7
.aff_eclair0
 movem.l (a3)+,d0-d6
 movem.l d0-d6,(a1)
 movem.l d0-d6,(a2)
 movem.l (a3)+,d0-d6
 movem.l d0-d6,7*4(a1)
 movem.l d0-d6,7*4(a2)
 lea 160(a1),a1
 lea 160(a2),a2
 dbra d7,.aff_eclair0
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #87-20,d7
.aff_eclair
 movem.l d0-d6,(a1)
 movem.l d0-d6,(a2)
 movem.l d0-d6,7*4(a1)
 movem.l d0-d6,7*4(a2)
 lea 160(a1),a1
 lea 160(a2),a2
 dbra d7,.aff_eclair
 rts

eff_eclair0
 move.l buf2,a1
 lea 17*160+64(a1),a1
 lea data,a3
*
 moveq #19,d7
.aff_eclair0
 movem.l (a3)+,d0-d6
 movem.l d0-d6,(a1)
 movem.l (a3)+,d0-d6
 movem.l d0-d6,7*4(a1)
 lea 160(a1),a1
 dbra d7,.aff_eclair0
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #87-20,d7
.aff_eclair
 movem.l d0-d6,(a1)
 movem.l d0-d6,7*4(a1)
 lea 160(a1),a1
 dbra d7,.aff_eclair
 rts


peclair
 lea data+31792,a0
 moveq #5,d7
.peclair
 move d7,-(sp)
 bsr eclair
 move (sp)+,d7
 bsr exscreen
 move d7,-(sp)
 bsr eff_eclair0
 move (sp)+,d7
 wait 9
 dbra d7,.peclair
 wait 10

 bsr eff_eclair
 wait 24
 rts

bouge macro
 moveq #0,d0
 moveq #15,d1
.\@
 lsr (a1)
 roxl d0
 dbra d1,.\@
 move d0,(a1)+
 endm

bouge1 macro
 move.l \1(a1),d0
 move.l \2(a1),\1(a1)
 move.l d0,\2(a1)
 endm

ret_g_eclair
 lea data+61360,a1
 moveq #90,d7
.ret0

 moveq #(9*4)-1,d2
.ret1
 bouge
 dbra d2,.ret1

 lea -9*8(a1),a1

 bouge1 0,8*8
 bouge1 4,8*8+4
 
 bouge1 8,7*8
 bouge1 8+4,7*8+4
 
 bouge1 8*2,6*8
 bouge1 8*2+4,6*8+4

 bouge1 8*3,5*8
 bouge1 8*3+4,5*8+4
 lea 9*8(a1),a1
 dbra d7,.ret0
 rts
 
aff_g_eclair
 lea data+61360,a0
 lea data,a3
*
 moveq #90,d7
.aff_eclair0
 moveq #8,d6
.prenub 
 move.l (a1),d0
 move.l 4(a1),d1
 move.l d0,(a3)+
 move.l d1,(a3)+
;
 move.l d0,d2
 swap d2
 or.l d0,d2
 not.l d2
 move.l (a0)+,d0
 move.l (a0)+,d1
 and.l d2,d0
 and.l d2,d1
 or.l d0,(a1)+
 or.l d1,(a1)+
 dbra d6,.prenub
 lea 160-(9*8)(a1),a1
 dbra d7,.aff_eclair0
 rts


eff_g_eclair
 lea data,a3
*
 moveq #90,d7
.eff_eclair0
 moveq #8,d6
.prenub 
 move.l (a3),(a2)+
 move.l (a3)+,(a1)+
 move.l (a3),(a2)+
 move.l (a3)+,(a1)+
 dbra d6,.prenub
 lea 160-(9*8)(a1),a1
 lea 160-(9*8)(a2),a2
 dbra d7,.eff_eclair0
 rts

geclair
 move.l buf2,a1
 lea 18*160+80(a1),a1
 bsr aff_g_eclair
 bsr exscreen
 wait 15
 bsr exscreen
 wait 5
 bsr exscreen

 bsr ret_g_eclair
 wait 2

 move.l buf2,a1
 move.l buf1,a2
 lea 18*160+80(a1),a1
 lea 18*160+80(a2),a2
 bsr eff_g_eclair

 move.l buf2,a1
 lea 16*160+32(a1),a1
 bsr aff_g_eclair
 bsr exscreen
 wait 10


; bsr ret_g_eclair
 wait 20

 move.l buf2,a1
 move.l buf1,a2
 lea 16*160+32(a1),a1
 lea 16*160+32(a2),a2
 bsr eff_g_eclair
 move.l buf2,a1
 lea 39*160+16(a1),a1
 bsr aff_g_eclair
 bsr exscreen
 wait 10


 move.l buf2,a1
 move.l buf1,a2
 lea 39*160+16(a1),a1
 lea 39*160+16(a2),a2
 bsr eff_g_eclair

 wait 50
 rts

nvbl
 eor #1,vs
 rte 

vsync
 move d0,-(sp)
 move vs,d0
.loop
 cmp vs,d0
 beq.s .loop
 move (sp)+,d0
 rts

palettes 
 incbin palettes.dat"
 even
data
 incbin da1.dat"
 even

 even
datasnurf
x set 0
 rept 100-65
 dc.w 72*(172-72-x),71+x,65*160,0
x set x+1
 endr
 rept 65
 dc.w 72*(172-72-x),71+x,65*160-((x-(100-65))*160),x-(100-65)
x set x+1
 endr
 
 section bss
 even
screen ds.b 32000*2+256 
vs ds.w 1
buf1 ds.l 1
buf2 ds.l 1
spile ds.l 1
 ds.l 400
npile
